-- AISnake Module: SMOOTH AI MOVEMENT V4.0 - FIXED ERRATIC BEHAVIOR
-- Completely redesigned AI brain for smooth, intelligent movement
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local SnakeConfig = require(ReplicatedStorage:WaitForChild("SnakeConfig"))
local OrbUtils = require(ReplicatedStorage:WaitForChild("OrbUtils"))

-- Load the orb pickup module
local AISnakeOrbPickup
pcall(function()
	local module = game.ServerScriptService:FindFirstChild("AISnakeOrbPickup")
	if module then
		AISnakeOrbPickup = require(module)
	end
end)

local Vector3new = Vector3.new
local CFramenew = CFrame.new
local CFramelookAt = CFrame.lookAt
local mathRad = math.rad
local mathRandom = math.random
local mathAtan2 = math.atan2
local mathPi = math.pi
local mathMin = math.min
local mathMax = math.max
local mathAbs = math.abs
local mathCeil = math.ceil
local mathExp = math.exp
local mathSin = math.sin
local mathCos = math.cos
local mathClamp = math.clamp
local mathFloor = math.floor
local mathSqrt = math.sqrt

local AISnake = {}
AISnake.__index = AISnake

-- === OPTIMIZED SETTINGS ===
local MAX_AI_SNAKES = 14
local SPATIAL_GRID_UPDATE_RATE = 0.5  -- Increased from 0.2 (update less often)
local BRAIN_UPDATES_PER_FRAME = 1
local DEBUG_UPDATE_RATE = 2.0  -- Increased from 1.0
local AI_HEIGHT = 5
local SEGMENT_UPDATE_SKIP = 1  -- Update every segment for no gaps
local LONG_SNAKE_THRESHOLD = 100  -- Snakes longer than this use more aggressive optimization
local VERY_LONG_SNAKE_THRESHOLD = 300  -- Even more optimization for very long snakes

AISnake._activeSnakes = {}
AISnake._orbTargets = {}

-- === SPATIAL GRID (unchanged) ===
local SpatialGrid = {}
local gridGeneration = 0
local entityPositionCache = {}
local partSizeCache = {}
do
	local CELL_SIZE = 75
	local grid = {}
	local ground = Workspace:FindFirstChild("SlitherIOGround")
	local mapSize = ground and ground.Size or Vector3new(1000, 10, 1000)
	local minX, minZ = -mapSize.X / 2, -mapSize.Z / 2

	local function getCellCoords(position)
		local x = mathFloor((position.X - minX) / CELL_SIZE)
		local z = mathFloor((position.Z - minZ) / CELL_SIZE)
		return x, z
	end

	function SpatialGrid.Clear()
		grid = {}
	end

	function SpatialGrid.Insert(part, owner, type)
		if not part or not part.Parent then return end
		local x, z = getCellCoords(part.Position)
		if not grid[x] then
			grid[x] = {}
		end
		if not grid[x][z] then
			grid[x][z] = {}
		end
		table.insert(grid[x][z], {part = part, owner = owner, type = type})
	end

	function SpatialGrid.QueryRadius(position, radius)
		local results = {}
		local minX, minZ = getCellCoords(position - Vector3new(radius, 0, radius))
		local maxX, maxZ = getCellCoords(position + Vector3new(radius, 0, radius))

		for x = minX, maxX do
			if grid[x] then
				for z = minZ, maxZ do
					if grid[x][z] then
						for _, entity in grid[x][z] do
							if (entity.part.Position - position).Magnitude <= radius then
								table.insert(results, entity)
							end
						end
					end
				end
			end
		end
		return results
	end
end

-- === SEGMENT POOLING (shared with players) ===
local SegmentPool = {}
local PoolSize = 0
local MAX_POOL_SIZE = 1000 -- Increased pool size
local SEGMENT_PARENT = Workspace:FindFirstChild("AISegmentContainer") or Instance.new("Folder", Workspace)
SEGMENT_PARENT.Name = "AISegmentContainer"

local function resetSegment(segment, config)
	segment.Anchored = true
	segment.CanCollide = false
	segment.CanTouch = false  -- Only head needs touch
	segment.CanQuery = false  -- Segments don't need query
	segment.Transparency = 0
	segment.Size = config.SegmentSize
	segment.Material = config.BodyMaterial or Enum.Material.Neon
	segment.Shape = Enum.PartType.Ball
	segment.TopSurface = Enum.SurfaceType.Smooth
	segment.BottomSurface = Enum.SurfaceType.Smooth
	segment.Color = config.BodyColors[1]
	segment.Name = "AISegment"
	-- Clean up children efficiently
	for _, child in segment:GetChildren() do
		if child:IsA("PointLight") or child:IsA("Attachment") then
			child:Destroy()
		end
	end
end

local function getSegment(config)
	if PoolSize > 0 then
		local segment = SegmentPool[PoolSize]
		SegmentPool[PoolSize] = nil
		PoolSize = PoolSize - 1
		resetSegment(segment, config)
		return segment
	else
		local segment = Instance.new("Part")
		resetSegment(segment, config)
		return segment
	end
end

local function returnSegment(segment)
	if not segment then return end
	
	-- Clean up all children first
	for _, child in ipairs(segment:GetChildren()) do
		child:Destroy()
	end
	
	-- If pool is full or segment is problematic, just destroy it
	if PoolSize >= MAX_POOL_SIZE then
		segment:Destroy()
		return
	end
	
	-- Reset segment properties
	segment.Transparency = 1
	segment.CanCollide = false
	segment.CanQuery = false
	segment.CanTouch = false
	segment.Anchored = true
	segment.Color = Color3.new()
	segment.Material = Enum.Material.Neon
	segment.Size = Vector3.new(3.5, 3.5, 4)
	
	-- Return to pool
	segment.Parent = SEGMENT_PARENT
	PoolSize = PoolSize + 1
	SegmentPool[PoolSize] = segment
end

-- === HELPER FUNCTIONS (unchanged) ===
local function getOrCreateSnakeModel(aiId)
	local modelName = "AISnakeModel_" .. tostring(aiId)
	local existing = Workspace:FindFirstChild(modelName)
	if existing and existing:IsA("Model") then
		return existing
	end
	local model = Instance.new("Model")
	model.Name = modelName
	model.Parent = Workspace
	return model
end




-- AI Snake color combinations - using patterns similar to SnakeData
local AISnakeColors = {
	{
		-- Yellow (Classic smooth)
		HeadColor = Color3.fromRGB(255, 255, 102),
		BodyColors = {
			Color3.fromRGB(255, 255, 51), 
			Color3.fromRGB(255, 255, 102),
			Color3.fromRGB(255, 255, 153), 
			Color3.fromRGB(255, 255, 102), 
			Color3.fromRGB(255, 255, 51),
		},
		HeadMaterial = Enum.Material.Neon,
		BodyMaterial = Enum.Material.Neon
	},
	{
		-- Green (Nature)
		HeadColor = Color3.fromRGB(102, 255, 102),
		BodyColors = {
			Color3.fromRGB(60, 180, 80),
			Color3.fromRGB(80, 200, 100),
			Color3.fromRGB(100, 220, 120),
			Color3.fromRGB(80, 200, 100),
			Color3.fromRGB(60, 180, 80),
		},
		HeadMaterial = Enum.Material.Neon,
		BodyMaterial = Enum.Material.Neon
	},
	{
		-- Blue (Ocean)
		HeadColor = Color3.fromRGB(102, 178, 255),
		BodyColors = {
			Color3.fromRGB(51, 153, 255),
			Color3.fromRGB(102, 178, 255),
			Color3.fromRGB(153, 204, 255),
			Color3.fromRGB(102, 178, 255),
			Color3.fromRGB(51, 153, 255),
		},
		HeadMaterial = Enum.Material.Neon,
		BodyMaterial = Enum.Material.Neon
	},
	{
		-- Orange (Sunset)
		HeadColor = Color3.fromRGB(255, 178, 102),
		BodyColors = {
			Color3.fromRGB(255, 153, 51),
			Color3.fromRGB(255, 178, 102),
			Color3.fromRGB(255, 204, 153),
			Color3.fromRGB(255, 178, 102),
			Color3.fromRGB(255, 153, 51),
		},
		HeadMaterial = Enum.Material.Neon,
		BodyMaterial = Enum.Material.Neon
	}
}

local function getRandomAIColor()
	-- 50% yellow, 50% others
	if math.random() < 0.5 then
		return AISnakeColors[1] -- Yellow
	else
		return AISnakeColors[math.random(2, #AISnakeColors)]
	end
end

local function deepCopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in orig do
			copy[orig_key] = deepCopy(orig_value)
		end
	else
		copy = orig
	end
	return copy
end

-- === VISUAL CREATION (unchanged) ===
local function createVisualHead(config, parentModel)
	local headPart = Instance.new("Part")
	headPart.Name = "AISnakeHead"
	headPart.Size = config.HeadSize
	headPart.Material = config.HeadMaterial
	headPart.Color = config.HeadColor
	headPart.Shape = Enum.PartType.Ball
	headPart.CanCollide = false
	headPart.CanTouch = true  -- CRITICAL: Enable touch detection for orb collection
	headPart.CanQuery = true   -- Enable for raycasts
	headPart.Anchored = true
	headPart.TopSurface = Enum.SurfaceType.Smooth
	headPart.BottomSurface = Enum.SurfaceType.Smooth
	headPart.Parent = parentModel
	
	-- MAKE AI SNAKE HEAD COMPLETELY INVISIBLE (like player snakes)
	headPart.Transparency = 1

	local headLight = Instance.new("PointLight")
	headLight.Color = config.HeadColor
	headLight.Brightness = config.GlowIntensity + 2
	headLight.Range = config.GlowRange + 3
	headLight.Parent = headPart

	local headOutline = Instance.new("SelectionBox")
	headOutline.Adornee = headPart
	headOutline.Color3 = Color3.fromRGB(255, 255, 255)
	headOutline.LineThickness = 0.1
	headOutline.Transparency = 1
	headOutline.Parent = headPart

	-- Eyes
	local leftEye = Instance.new("Part")
	leftEye.Name = "LeftEye"
	leftEye.Size = Vector3new(0.7, 0.7, 0.7)
	leftEye.Material = Enum.Material.Neon
	leftEye.Color = Color3.fromRGB(255, 255, 255)
	leftEye.Shape = Enum.PartType.Ball
	leftEye.CanCollide = false
	leftEye.Anchored = false
	leftEye.Parent = headPart

	local rightEye = Instance.new("Part")
	rightEye.Name = "RightEye"
	rightEye.Size = Vector3new(0.7, 0.7, 0.7)
	rightEye.Material = Enum.Material.Neon
	rightEye.Color = Color3.fromRGB(255, 255, 255)
	rightEye.Shape = Enum.PartType.Ball
	rightEye.CanCollide = false
	rightEye.Anchored = false
	rightEye.Parent = headPart

	local leftPupil = Instance.new("Part")
	leftPupil.Name = "LeftPupil"
	leftPupil.Size = Vector3new(0.3, 0.3, 0.3)
	leftPupil.Material = Enum.Material.Neon
	leftPupil.Color = Color3.fromRGB(0, 0, 0)
	leftPupil.Shape = Enum.PartType.Ball
	leftPupil.CanCollide = false
	leftPupil.Anchored = false
	leftPupil.Parent = leftEye

	local rightPupil = Instance.new("Part")
	rightPupil.Name = "RightPupil"
	rightPupil.Size = Vector3new(0.3, 0.3, 0.3)
	rightPupil.Material = Enum.Material.Neon
	rightPupil.Color = Color3.fromRGB(0, 0, 0)
	rightPupil.Shape = Enum.PartType.Ball
	rightPupil.CanCollide = false
	rightPupil.Anchored = false
	rightPupil.Parent = rightEye

	leftEye.CFrame = headPart.CFrame * CFramenew(-0.6, 0.55, 0.8)
	rightEye.CFrame = headPart.CFrame * CFramenew(0.6, 0.55, 0.8)
	leftPupil.CFrame = leftEye.CFrame * CFramenew(0, 0, -0.25)
	rightPupil.CFrame = rightEye.CFrame * CFramenew(0, 0, -0.25)

	local leftEyeWeld = Instance.new("WeldConstraint")
	leftEyeWeld.Part0 = headPart
	leftEyeWeld.Part1 = leftEye
	leftEyeWeld.Parent = headPart

	local rightEyeWeld = Instance.new("WeldConstraint")
	rightEyeWeld.Part0 = headPart
	rightEyeWeld.Part1 = rightEye
	rightEyeWeld.Parent = headPart

	local leftPupilWeld = Instance.new("WeldConstraint")
	leftPupilWeld.Part0 = leftEye
	leftPupilWeld.Part1 = leftPupil
	leftPupilWeld.Parent = leftEye

	local rightPupilWeld = Instance.new("WeldConstraint")
	rightPupilWeld.Part0 = rightEye
	rightPupilWeld.Part1 = rightPupil
	rightPupilWeld.Parent = rightEye

	-- Debug UI
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "PersonalityDebug"
	billboard.Size = UDim2.new(0, 120, 0, 36)
	billboard.StudsOffset = Vector3.new(0, 3.5, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = headPart

	local label = Instance.new("TextLabel")
	label.Name = "PersonalityLabel"
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255,255,255)
	label.TextStrokeTransparency = 0.4
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Text = ""
	label.Parent = billboard

	return {
		head = headPart,
		headLight = headLight,
		headOutline = headOutline,
		leftEye = leftEye,
		rightEye = rightEye,
		leftPupil = leftPupil,
		rightPupil = rightPupil,
		leftEyeWeld = leftEyeWeld,
		rightEyeWeld = rightEyeWeld,
		leftPupilWeld = leftPupilWeld,
		rightPupilWeld = rightPupilWeld,
		debugLabel = label,
	}
end

local function createSegment(index, position, color, config, parentModel, currentLength)
	local segment = getSegment(config)
	segment.Name = "AISegment" .. index
	
	-- Apply growth factor based on current snake length (same as players)
	local growthFactor = 1
	if currentLength and currentLength > 200 then
		growthFactor = 1 + ((currentLength - 200) / 2800) * 1.0  -- Match moderate growth
	end
	
	segment.Size = config.SegmentSize * mathMin(growthFactor, 2.0)  -- Match new max
	segment.Material = config.BodyMaterial or Enum.Material.Neon
	segment.Color = color
	segment.CFrame = CFramenew(position)
	segment.Parent = parentModel
	segment.Transparency = 0
	
	segment:SetAttribute("IsSnakeSegment", true)
	segment:SetAttribute("SegmentIndex", index)
	segment:SetAttribute("IsAISnake", true)

	-- Add glow to head segments and every 10th segment for performance (same as players)
	if index <= 30 or index % 10 == 0 then
		local light = segment:FindFirstChild("Glow") or Instance.new("PointLight")
		light.Name = "Glow"
		light.Color = color
		light.Range = config.GlowRange * 0.7  -- Slightly reduced for AI
		light.Brightness = config.GlowIntensity * 0.8  -- Slightly reduced for AI
		light.Enabled = true
		light.Parent = segment
	else
		-- Remove light if it exists on other segments
		local existingLight = segment:FindFirstChild("Glow")
		if existingLight then
			existingLight:Destroy()
		end
	end

	return segment
end

-- === HELPER FUNCTIONS ===
local function getPlayerLength(player)
	if not player or not player.Character then return 0 end
	local count = 0

	local snakeInstance = _G.PlayerSnakes and _G.PlayerSnakes[player]
	if snakeInstance and snakeInstance.segments then
		return #snakeInstance.segments
	end

	for _, child in player.Character:GetChildren() do
		if child:IsA("BasePart") and child.Name:match("^Segment") then
			count = count + 1
		end
	end
	return count
end

local function getPlayerVelocity(player)
	if not player or not player.Character then return Vector3new(0, 0, 0) end
	local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
	if rootPart and rootPart:FindFirstChild("AssemblyLinearVelocity") then
		return rootPart.AssemblyLinearVelocity
	end
	return Vector3new(0, 0, 0)
end

-- Wall avoidance
local WALL_NAMES = {"SlitherIOWall_Left", "SlitherIOWall_Right", "SlitherIOWall_Top", "SlitherIOWall_Bottom"}
local wallParts = {}

task.spawn(function()
	task.wait(0.1)
	for _, wallName in WALL_NAMES do
		local wall = Workspace:FindFirstChild(wallName)
		if wall and wall:IsA("BasePart") then
			table.insert(wallParts, wall)
		end
	end
end)

local function getWallAvoidanceVector(headPos)
	local avoidVec = Vector3new(0, 0, 0)
	local avoidStrength = 0

	for i = 1, #wallParts do
		local wall = wallParts[i]
		if wall and wall.Parent then
			local wallPos = wall.Position
			local closestPointOnWall = Vector3new(
				mathClamp(headPos.X, wallPos.X - wall.Size.X/2, wallPos.X + wall.Size.X/2),
				headPos.Y,
				mathClamp(headPos.Z, wallPos.Z - wall.Size.Z/2, wallPos.Z + wall.Size.Z/2)
			)
			local dir = headPos - closestPointOnWall
			local dist = dir.Magnitude
			local threshold = 25
			if dist < threshold then
				local strength = (threshold - dist) / threshold
				strength = strength * strength
				avoidVec = avoidVec + dir.Unit * strength
				avoidStrength = avoidStrength + strength
			end
		end
	end
	if avoidStrength > 0 then
		return avoidVec.Unit, avoidStrength
	end
	return nil, 0
end

local function isPartsColliding(partA, partB)
	if not (partA and partA.Parent and partB and partB.Parent) then return false end
	local radiusA = (partA.Size.X + partA.Size.Y + partA.Size.Z) / 6
	local radiusB = (partB.Size.X + partB.Size.Y + partB.Size.Z) / 6
	local dist = (partA.Position - partB.Position).Magnitude
	return dist < (radiusA + radiusB) * 0.85
end

-- === FIXED AI PERSONALITIES - MUCH SMOOTHER ===
AISnake.PersonalityTypes = {
	"Aggressor", "Scavenger", "Trickster", "Coward", "Hunter", "Trapper", "Assassin"
}

AISnake.PersonalityDefinitions = {
	Aggressor = {
		Type = "Aggressor",
		TargetPlayers = true,
		TargetOrbs = true,
		AvoidOthers = false,
		SpeedMultiplier = 1.2,
		TurnBias = 0.05, -- REDUCED from 0.1
		BoostChance = 0.08, -- REDUCED from 0.15
		CombatRadius = 40, -- MUCH REDUCED
		RandomTurnInterval = 4.0, -- INCREASED
		OrbSeekRadius = 120, -- MUCH INCREASED
		Description = "Aggressive but controlled hunter",
		Erratic = false,
		PackHunter = false,
		PredictionTime = 0.8,
		TrapStyle = "circle",
	},
	Scavenger = {
		Type = "Scavenger",
		TargetPlayers = false,
		TargetOrbs = true,
		AvoidOthers = true,
		SpeedMultiplier = 1.1, -- INCREASED from 1.0
		TurnBias = 0.1, -- REDUCED from 0.2
		BoostChance = 0.05, -- REDUCED from 0.1
		CombatRadius = 30, -- MUCH REDUCED  
		RandomTurnInterval = 5.0, -- INCREASED
		OrbSeekRadius = 150, -- MUCH INCREASED
		Description = "Orb-focused with smooth movement",
		Erratic = false,
		PackHunter = false,
		PredictionTime = 0,
		TrapStyle = "none",
	},
	Trickster = {
		Type = "Trickster",
		TargetPlayers = true,
		TargetOrbs = true,
		AvoidOthers = false,
		SpeedMultiplier = 1.15, -- REDUCED from 1.2
		TurnBias = 0.1, -- REDUCED from 0.3
		BoostChance = 0.1, -- REDUCED from 0.2
		CombatRadius = 30,
		RandomTurnInterval = 4.0,
		OrbSeekRadius = 150,
		Description = "Unpredictable but smoother",
		Erratic = false, -- CHANGED from true
		PackHunter = false,
		PredictionTime = 0.5,
		TrapStyle = "zigzag",
	},
	Coward = {
		Type = "Coward",
		TargetPlayers = false,
		TargetOrbs = true,
		AvoidOthers = true,
		SpeedMultiplier = 1.0, -- INCREASED from 0.9
		TurnBias = 0.1, -- REDUCED from 0.25
		BoostChance = 0.15, -- REDUCED from 0.3
		CombatRadius = 30,
		RandomTurnInterval = 5.0,
		OrbSeekRadius = 180,
		Description = "Cautious but efficient",
		Erratic = false,
		PackHunter = false,
		PredictionTime = 0,
		TrapStyle = "none",
	},
	Hunter = {
		Type = "Hunter",
		TargetPlayers = true,
		TargetOrbs = true,
		AvoidOthers = false,
		SpeedMultiplier = 1.2, -- REDUCED from 1.25
		TurnBias = 0.02, -- REDUCED from 0.05
		BoostChance = 0.08, -- REDUCED from 0.12
		CombatRadius = 40,
		RandomTurnInterval = 5.0,
		OrbSeekRadius = 140,
		Description = "Strategic and smooth",
		Erratic = false,
		PackHunter = true,
		PredictionTime = 1.0, -- REDUCED from 1.2
		TrapStyle = "cutoff",
	},
	Trapper = {
		Type = "Trapper",
		TargetPlayers = true,
		TargetOrbs = true,
		AvoidOthers = false,
		SpeedMultiplier = 1.1, -- REDUCED from 1.15
		TurnBias = 0.01, -- REDUCED from 0.02
		BoostChance = 0.05, -- REDUCED from 0.08
		CombatRadius = 35,
		RandomTurnInterval = 6.0,
		OrbSeekRadius = 160,
		Description = "Patient spiral trapper",
		Erratic = false,
		PackHunter = false,
		PredictionTime = 1.0, -- INCREASED from 0.8
		TrapStyle = "spiral",
	},
	Assassin = {
		Type = "Assassin",
		TargetPlayers = true,
		TargetOrbs = true,
		AvoidOthers = false,
		SpeedMultiplier = 1.25, -- REDUCED from 1.3
		TurnBias = 0.0,
		BoostChance = 0.03, -- REDUCED from 0.05
		CombatRadius = 45,
		RandomTurnInterval = 7.0,
		OrbSeekRadius = 130,
		Description = "Patient stalker",
		Erratic = false,
		PackHunter = false,
		PredictionTime = 1.2, -- INCREASED from 1.0
		TrapStyle = "stalk",
	},
}

-- === AI METHODS ===
function AISnake:findBestOrb()
	local minDist = self.Personality.OrbSeekRadius or 50
	local nearest = nil
	local headPos = self.HeadParts and self.HeadParts.head and self.HeadParts.head.Position or self.Position

	local nearbyEntities = SpatialGrid.QueryRadius(headPos, minDist)
	if #nearbyEntities == 0 then return nil, math.huge end

	-- Prioritize untargeted orbs
	local targetedOrbs = {}
	for ai, orb in AISnake._orbTargets do
		if ai ~= self and orb and orb.Parent then
			targetedOrbs[orb] = true
		end
	end

	for _, entity in nearbyEntities do
		if entity.type == "ORB" and not targetedOrbs[entity.part] then
			local dist = (entity.part.Position - headPos).Magnitude
			if dist < minDist then
				minDist = dist
				nearest = entity.part
			end
		end
	end

	-- If no untargeted orbs, allow targeting of any orb
	if not nearest then
		for _, entity in nearbyEntities do
			if entity.type == "ORB" then
				local dist = (entity.part.Position - headPos).Magnitude
				if dist < minDist then
					minDist = dist
					nearest = entity.part
				end
			end
		end
	end

	return nearest, minDist
end

function AISnake:findNearestSnakeHead()
	local myHead = self.HeadParts and self.HeadParts.head
	if not myHead then return nil, math.huge end
	local myPos = myHead.Position
	local minDist = math.huge
	local nearest = nil

	local nearbyEntities = SpatialGrid.QueryRadius(myPos, self.Personality.CombatRadius or 60)

	for _, entity in nearbyEntities do
		if entity.owner ~= self and (entity.type == "AI_HEAD" or entity.type == "PLAYER_HEAD") then
			local dist = (entity.part.Position - myPos).Magnitude
			if dist < minDist then
				minDist = dist
				if entity.type == "AI_HEAD" then
					nearest = {part = entity.part, isPlayer = false, snake = entity.owner}
				else
					nearest = {part = entity.part, isPlayer = true, player = entity.owner}
				end
			end
		end
	end
	return nearest, minDist
end

function AISnake:findNearbyThreats()
	local myHead = self.HeadParts and self.HeadParts.head
	if not myHead then return {} end
	local myPos = myHead.Position
	local threats = {}

	local threatRadius = 80 -- INCREASED from 60
	local nearbyEntities = SpatialGrid.QueryRadius(myPos, threatRadius)

	for _, entity in nearbyEntities do
		if entity.owner ~= self and (entity.type == "AI_HEAD" or entity.type == "PLAYER_HEAD") then
			local dist = (entity.part.Position - myPos).Magnitude
			local enemyLength = 0

			if entity.type == "AI_HEAD" then
				enemyLength = entity.owner.CurrentLength or 0
			else
				enemyLength = getPlayerLength(entity.owner)
			end

			local lengthDiff = enemyLength - self.CurrentLength
			local isThreat = false

			-- More balanced threat detection
			if lengthDiff > 20 or (dist < 20 and lengthDiff > 5) then
				isThreat = true
			end

			if not isThreat and dist < 30 and lengthDiff > 15 then
				local enemyVel = Vector3new(0, 0, 0)
				if entity.type == "PLAYER_HEAD" then
					enemyVel = getPlayerVelocity(entity.owner)
				end
				local toUs = (myPos - entity.part.Position).Unit
				local facingUs = enemyVel.Magnitude > 0.1 and enemyVel.Unit:Dot(toUs) > 0.8
				if facingUs then
					isThreat = true
				end
			end

			if isThreat then
				local threatLevel = mathMax(lengthDiff + 10, 5) / mathMax(dist, 1)
				table.insert(threats, {
					part = entity.part,
					isPlayer = entity.type == "PLAYER_HEAD",
					owner = entity.owner,
					distance = dist,
					threatLevel = threatLevel,
					lengthDiff = lengthDiff
				})
			end
		end
	end

	table.sort(threats, function(a, b) return a.threatLevel > b.threatLevel end)
	return threats
end

function AISnake:startBoost(duration)
	local now = tick()
	duration = duration or 1.5

	if self.Boosting and self.BoostEndTime > now + duration then
		return
	end

	self.Boosting = true
	self.IsBoosting = true
	self.BoostEndTime = now + duration
	self.BoostCooldown = self.BoostEndTime + mathRandom(15, 30) / 10 -- INCREASED cooldown
end

-- FIXED: Much smoother flee logic
function AISnake:getFleeVector()
	local myHead = self.HeadParts and self.HeadParts.head
	if not myHead then return Vector3new(0, 0, 1) end

	local headPos = myHead.Position
	local threats = self:findNearbyThreats()
	local wallVec, wallStrength = getWallAvoidanceVector(headPos)

	-- REDUCED boost frequency
	if #threats > 0 and not self.Boosting and mathRandom() < 0.3 then
		local closestThreat = threats[1]
		local boostDuration = 1.0

		if closestThreat.distance < 15 and closestThreat.lengthDiff > 30 then
			boostDuration = 1.5
		end

		self:startBoost(boostDuration)
	end

	local fleeDir = nil

	if #threats > 0 then
		-- SIMPLIFIED flee direction calculation
		local totalThreatVector = Vector3new(0, 0, 0)
		local totalWeight = 0

		for _, threat in threats do
			local threatPos = threat.part.Position
			local awayFromThreat = (headPos - threatPos).Unit
			local weight = 1 / mathMax(threat.distance, 1)
			totalThreatVector = totalThreatVector + awayFromThreat * weight
			totalWeight = totalWeight + weight
		end

		if totalWeight > 0 then
			fleeDir = (totalThreatVector / totalWeight).Unit
		end
	end

	-- Wall avoidance
	if wallVec and wallStrength > 0.2 then
		if fleeDir then
			fleeDir = (fleeDir + wallVec.Unit * 2).Unit
		else
			fleeDir = wallVec.Unit
		end
	end

	-- Default behavior - prefer center when fleeing
	if not fleeDir then
		local mapCenter = Vector3new(0, headPos.Y, 0)
		local toCenter = (mapCenter - headPos)
		local distFromCenter = toCenter.Magnitude

		if distFromCenter > 150 then
			-- Too far - flee toward center
			fleeDir = toCenter.Unit
		else
			-- Random direction with MORE center bias
			local randomAngle = mathRandom() * 2 * mathPi
			local randomDir = Vector3new(mathSin(randomAngle), 0, mathCos(randomAngle))
			if distFromCenter > 100 then
				fleeDir = (randomDir + toCenter.Unit * 0.5).Unit
			elseif distFromCenter > 60 then
				fleeDir = (randomDir + toCenter.Unit * 0.3).Unit
			else
				fleeDir = randomDir
			end
		end
	end
	
	-- ADD center bias to ALL flee directions if far from center
	local mapCenter = Vector3new(0, headPos.Y, 0)
	local distFromCenter = (mapCenter - headPos).Magnitude
	if distFromCenter > 180 and fleeDir then
		local toCenter = (mapCenter - headPos).Unit
		fleeDir = (fleeDir + toCenter * 0.4).Unit
	end

	return fleeDir
end

-- === HELPER: Check if path to target is safe ===
function AISnake:isPathSafe(targetPos, checkDistance)
	local myHead = self.HeadParts.head
	if not myHead then return false end

	local myPos = myHead.Position
	local toTarget = targetPos - myPos
	local distance = toTarget.Magnitude

	if distance < 0.1 then return true end

	local direction = toTarget.Unit
	local checkDist = mathMin(distance, checkDistance or 50)
	local stepSize = 5

	-- Check points along the path
	for d = stepSize, checkDist, stepSize do
		local checkPos = myPos + direction * d

		-- Check for other snakes at this position
		local nearbyEntities = SpatialGrid.QueryRadius(checkPos, 8)
		for _, entity in ipairs(nearbyEntities) do
			if entity.type == "AI_SEGMENT" or entity.type == "PLAYER_SEGMENT" then
				-- Check if it's not our own segment
				if entity.owner ~= self then
					-- This path crosses another snake!
					return false
				end
			elseif entity.type == "AI_HEAD" or entity.type == "PLAYER_HEAD" then
				if entity.owner ~= self then
					-- Calculate if we'd collide
					local theirVel = entity.part.AssemblyLinearVelocity or Vector3.zero
					local timeToReach = d / self.Speed
					local theirFuturePos = entity.part.Position + theirVel * timeToReach

					if (checkPos - theirFuturePos).Magnitude < 10 then
						-- Collision likely!
						return false
					end
				end
			end
		end
	end

	return true
end

-- === HELPER: Get smart flee direction ===
function AISnake:getSmartFleeDirection(threats)
	-- Safety check for head
	if not self.HeadParts or not self.HeadParts.head then
		return Vector3new(mathRandom(-1, 1), 0, mathRandom(-1, 1)).Unit
	end

	local myPos = self.HeadParts.head.Position

	-- Calculate danger zones from all threats
	local dangerVectors = {}
	for _, threat in ipairs(threats) do
		-- Safety check
		if threat.part and threat.part.Parent then
			local threatPos = threat.part.Position
			local awayFromThreat = (myPos - threatPos).Unit
			local weight = 1 / mathMax(threat.distance, 5) -- Closer = more weight

			-- Extra weight for bigger snakes
			if threat.lengthDiff > 20 then
				weight = weight * 2
			end

			table.insert(dangerVectors, {
				direction = awayFromThreat,
				weight = weight
			})
		end
	end

	-- Combine all danger vectors
	local fleeDir = Vector3.zero
	local totalWeight = 0

	for _, danger in ipairs(dangerVectors) do
		fleeDir = fleeDir + danger.direction * danger.weight
		totalWeight = totalWeight + danger.weight
	end

	-- Add bias towards center if far from it
	local toCenter = Vector3new(0, myPos.Y, 0) - myPos
	local distFromCenter = toCenter.Magnitude
	if distFromCenter > 200 then
		local centerWeight = (distFromCenter - 200) / 100
		fleeDir = fleeDir + toCenter.Unit * centerWeight
		totalWeight = totalWeight + centerWeight
	end

	if totalWeight > 0 then
		fleeDir = (fleeDir / totalWeight).Unit

		-- Check if flee direction is safe
		if not self:isPathSafe(myPos + fleeDir * 30, 30) then
			-- Try perpendicular directions
			local perpDir1 = Vector3new(-fleeDir.Z, 0, fleeDir.X)
			local perpDir2 = Vector3new(fleeDir.Z, 0, -fleeDir.X)

			if self:isPathSafe(myPos + perpDir1 * 30, 30) then
				fleeDir = perpDir1
			elseif self:isPathSafe(myPos + perpDir2 * 30, 30) then
				fleeDir = perpDir2
			end
		end

		return fleeDir
	end

	-- Default: flee towards center
	return toCenter.Unit
end

-- === MUCH SMARTER AI BRAIN (FIXED) ===
function AISnake:_determineAction()
	local headPos = self.HeadParts.head.Position
	local p = self.Personality
	local now = tick()
	local state = "WANDER"
	local steer = self.Direction

	-- Clean up expired states
	if self.Avoiding and now > self.AvoidExpire then
		self.Avoiding = false
		self.FleeReason = ""
	end
	if self.isConfident and now > self.confidenceEndTime then
		self.isConfident = false
		if self.HeadParts and self.HeadParts.headOutline then
			self.HeadParts.headOutline.Color3 = Color3.fromRGB(255, 255, 255)
			self.HeadParts.headOutline.LineThickness = 0.1
			self.HeadParts.headOutline.Transparency = 1
		end
	end
	if self.TargetOrb and (not self.TargetOrb.Parent or now > self.TargetOrbExpire) then
		self.TargetOrb = nil
		AISnake._orbTargets[self] = nil
	end
	if self.TargetSnake and (not self.TargetSnake.part or not self.TargetSnake.part.Parent) then
		self.TargetSnake = nil
		self.trapPhase = 0
		self.isAmbushing = false
	end

	-- Priority 0: CRITICAL BOUNDARY AVOIDANCE (HIGHEST PRIORITY)
	local criticalBuffer = 30
	local isInCriticalZone = (
		headPos.X > MAP_BOUNDS.maxX - criticalBuffer or
		headPos.X < MAP_BOUNDS.minX + criticalBuffer or
		headPos.Z > MAP_BOUNDS.maxZ - criticalBuffer or
		headPos.Z < MAP_BOUNDS.minZ + criticalBuffer
	)

	if isInCriticalZone then
		-- Emergency boundary escape
		local escapeDir = Vector3new(0, 0, 0)
		
		if headPos.X > MAP_BOUNDS.maxX - criticalBuffer then
			escapeDir = escapeDir + Vector3new(-1, 0, 0)
		elseif headPos.X < MAP_BOUNDS.minX + criticalBuffer then
			escapeDir = escapeDir + Vector3new(1, 0, 0)
		end
		
		if headPos.Z > MAP_BOUNDS.maxZ - criticalBuffer then
			escapeDir = escapeDir + Vector3new(0, 0, -1)
		elseif headPos.Z < MAP_BOUNDS.minZ + criticalBuffer then
			escapeDir = escapeDir + Vector3new(0, 0, 1)
		end
		
		if escapeDir.Magnitude > 0.1 then
			-- Add randomness to prevent corner traps
			local randomAngle = mathRandom(-20, 20) * mathPi / 180
			local cosA = mathCos(randomAngle)
			local sinA = mathSin(randomAngle)
			escapeDir = escapeDir.Unit
			local rotatedEscape = Vector3new(
				escapeDir.X * cosA - escapeDir.Z * sinA,
				0,
				escapeDir.X * sinA + escapeDir.Z * cosA
			)
			
			self.TargetSnake = nil
			self.TargetOrb = nil
			self.Avoiding = true
			self.AvoidExpire = now + 2
			return "AVOID_BOUNDARY", rotatedEscape.Unit
		end
	end

	-- Priority 1: COLLISION AVOIDANCE
	local lookAheadDist = self.Speed * 1.2
	local futurePos = headPos + self.Direction * lookAheadDist

	local nearbyDanger = SpatialGrid.QueryRadius(futurePos, 12)
	local collisionThreat = nil
	local minCollisionTime = math.huge

	for _, entity in ipairs(nearbyDanger) do
		if entity.owner ~= self and (entity.type:match("HEAD") or entity.type:match("SEGMENT")) then
			local theirPos = entity.part.Position
			local toThreat = (theirPos - headPos)
			local dist = toThreat.Magnitude
			
			if dist < 15 then
				local timeToCollision = dist / mathMax(self.Speed, 1)
				
				if timeToCollision < minCollisionTime then
					minCollisionTime = timeToCollision
					collisionThreat = entity
				end
			end
		end
	end

	if collisionThreat and minCollisionTime < 0.8 then
		local threatPos = collisionThreat.part.Position
		local avoidDir = (headPos - threatPos).Unit
		local perpDir = Vector3new(-avoidDir.Z, 0, avoidDir.X)

		-- Quick clear check
		local leftClear = self:isPathSafe(headPos + perpDir * 15, 15)
		local rightClear = self:isPathSafe(headPos - perpDir * 15, 15)

		if leftClear and not rightClear then
			steer = perpDir
		elseif rightClear and not leftClear then
			steer = -perpDir
		else
			steer = avoidDir
		end

		return "COLLISION_AVOID", steer
	end

	-- Priority 2: Wall avoidance
	local wallVec, wallStrength = getWallAvoidanceVector(headPos)
	if wallVec and wallStrength > 0.4 then
		self.TargetSnake = nil
		return "AVOID_WALL", wallVec.Unit
	end

	-- Priority 3: Threat assessment (SMARTER)
	local threats = self:findNearbyThreats()
	local shouldFlee = false
	local fleeReason = ""

	if #threats > 0 then
		local closestThreat = threats[1]

		-- More nuanced fleeing decisions
		if closestThreat.distance < 15 and closestThreat.lengthDiff > 5 then
			shouldFlee = true
			fleeReason = "immediate_danger"
		elseif closestThreat.distance < 25 and closestThreat.lengthDiff > 15 then
			shouldFlee = true
			fleeReason = "bigger_snake_nearby"
		elseif closestThreat.lengthDiff > 30 and closestThreat.distance < 40 then
			shouldFlee = true
			fleeReason = "giant_enemy"
		elseif #threats >= 2 and closestThreat.distance < 30 then
			shouldFlee = true
			fleeReason = "multiple_threats"
		elseif p.Type == "Coward" and closestThreat.lengthDiff > 0 and closestThreat.distance < 35 then
			shouldFlee = true
			fleeReason = "coward_instinct"
		end

		-- Even aggressive types flee from much bigger snakes
		if shouldFlee and (p.Type == "Aggressor" or p.Type == "Hunter") then
			if closestThreat.lengthDiff < 10 and closestThreat.distance > 20 then
				shouldFlee = false
			end
		end
	end

	if shouldFlee or self.Avoiding then
		self.TargetSnake = nil
		self.TargetOrb = nil

		local fleeDir = self:getSmartFleeDirection(threats)

		self.Avoiding = true
		self.AvoidDir = fleeDir
		self.AvoidExpire = now + 2.5
		if shouldFlee then self.FleeReason = fleeReason end
		return "FLEE", fleeDir
	end

	-- Priority 4: Smart orb seeking
	if p.TargetOrbs and not shouldFlee then
		-- Look for orbs periodically, not every frame
		if not self.TargetOrb or not self.TargetOrb.Parent or mathRandom() < 0.1 then
			local orb, dist = self:findBestOrb()

			if orb and dist < p.OrbSeekRadius * 1.5 then
				-- Switch to closer orb if significantly better
				if self.TargetOrb and self.TargetOrb.Parent then
					local currentDist = (self.TargetOrb.Position - headPos).Magnitude
					if dist < currentDist * 0.6 then
						self.TargetOrb = orb
						self.TargetOrbExpire = now + mathRandom(40, 80) / 10
						AISnake._orbTargets[self] = orb
					end
				else
					self.TargetOrb = orb
					self.TargetOrbExpire = now + mathRandom(40, 80) / 10
					AISnake._orbTargets[self] = orb
				end
			end
		end

		if self.TargetOrb and self.TargetOrb.Parent then
			local toOrb = self.TargetOrb.Position - headPos
			local orbDist = toOrb.Magnitude

			-- Check if path to orb is safe
			if orbDist < 40 and self:isPathSafe(self.TargetOrb.Position, orbDist) then
				state = "SEEK_ORB"
				steer = toOrb.Unit
				
				-- Short boost when very close
				if orbDist < 15 and not self.Boosting and mathRandom() < 0.2 then
					self:startBoost(0.4)
				end
				
				self.TargetSnake = nil
				return state, steer
			else
				-- Path not safe or too far, cancel
				self.TargetOrb = nil
				AISnake._orbTargets[self] = nil
			end
		end
	end

	-- Priority 5: Advanced Movement Patterns
	if state == "WANDER" then
		-- Initialize movement tracking with nil checks
		self._lastStraightDistance = self._lastStraightDistance or 0
		self._lastTurnPosition = self._lastTurnPosition or headPos
		self._spiralAngle = self._spiralAngle or 0
		self._spiralRadius = self._spiralRadius or 50
		self._zigzagDirection = self._zigzagDirection or 1
		self._gridDirection = self._gridDirection or 0

		-- Calculate distance traveled since last turn
		local distanceSinceTurn = (headPos - self._lastTurnPosition).Magnitude

		-- Check minimum straight distance requirement
		local minStraight = p.MinStraightDistance or 100

		-- Movement pattern based on personality
		local movementPattern = p.MovementPattern or "wander"

		if movementPattern == "spiral" then
			-- Spiral outward pattern for Collectors
			if distanceSinceTurn > minStraight then
				self._spiralAngle = self._spiralAngle + mathPi / 4
				self._spiralRadius = mathMin(self._spiralRadius + 20, 400)
				if self._spiralRadius >= 400 then
					self._spiralRadius = 50
				end
				local targetX = mathCos(self._spiralAngle) * self._spiralRadius
				local targetZ = mathSin(self._spiralAngle) * self._spiralRadius
				steer = (Vector3new(targetX, headPos.Y, targetZ) - headPos).Unit
				self._lastTurnPosition = headPos
			else
				steer = self.Direction
			end

		elseif movementPattern == "zigzag" then
			-- Zigzag pattern for Explorers
			if distanceSinceTurn > minStraight then
				self._zigzagDirection = -self._zigzagDirection
				local turnAngle = self.TargetYaw + (mathPi / 6) * self._zigzagDirection
				steer = Vector3new(mathSin(turnAngle), 0, mathCos(turnAngle))
				self.TargetYaw = turnAngle
				self._lastTurnPosition = headPos
			else
				steer = self.Direction
			end

		elseif movementPattern == "grid" then
			-- Grid pattern for Farmers
			local gridSize = p.GridSize or 100
			if distanceSinceTurn > gridSize then
				self._gridDirection = (self._gridDirection + 1) % 4
				local angles = {0, mathPi/2, mathPi, -mathPi/2}
				self.TargetYaw = angles[self._gridDirection + 1]
				steer = Vector3new(mathSin(self.TargetYaw), 0, mathCos(self.TargetYaw))
				self._lastTurnPosition = headPos
			else
				steer = self.Direction
			end

		elseif movementPattern == "circular" then
			-- Circular patrol for Guardians
			p.PatrolAngle = p.PatrolAngle or 0
			p.PatrolAngle = p.PatrolAngle + 0.02
			local radius = p.TerritoryRadius or 150
			local center = p.TerritoryCenter or Vector3new(0, 0, 0)
			local targetX = center.X + mathCos(p.PatrolAngle) * radius
			local targetZ = center.Z + mathSin(p.PatrolAngle) * radius
			local targetPos = Vector3new(targetX, headPos.Y, targetZ)
			steer = (targetPos - headPos).Unit

		else
			-- Default wandering with minimum straight distance
			if (now - (self.LastTurn or 0) > p.RandomTurnInterval) and distanceSinceTurn > minStraight then
				local maxTurn = 30
				local turnAmount = mathRandom(-maxTurn, maxTurn)

				-- Prevent 180 degree turns
				if mathAbs(turnAmount) > 90 then
					turnAmount = turnAmount * 0.3
				end

				self.TargetYaw = self.TargetYaw + mathRad(turnAmount)
				self.LastTurn = now
				self._lastTurnPosition = headPos

				steer = Vector3new(mathSin(self.TargetYaw), 0, mathCos(self.TargetYaw))
			else
				steer = self.Direction
			end
		end

		-- Gentle boundary nudging (NOT aggressive)
		local softBuffer = 120
		local nudgeStrength = 0.15
		
		if headPos.X > MAP_BOUNDS.maxX - softBuffer then
			steer = (steer + Vector3new(-1, 0, 0) * nudgeStrength).Unit
		elseif headPos.X < MAP_BOUNDS.minX + softBuffer then
			steer = (steer + Vector3new(1, 0, 0) * nudgeStrength).Unit
		end
		
		if headPos.Z > MAP_BOUNDS.maxZ - softBuffer then
			steer = (steer + Vector3new(0, 0, -1) * nudgeStrength).Unit
		elseif headPos.Z < MAP_BOUNDS.minZ + softBuffer then
			steer = (steer + Vector3new(0, 0, 1) * nudgeStrength).Unit
		end
	end

	return state, steer
end

function AISnake:updateBrain()
	if not self._active or not self.HeadParts or not self.HeadParts.head or not self.HeadParts.head.Parent then
		return
	end
	local state, steer = self:_determineAction()
	self.State = state
	self.SteerDirection = steer
end

-- === AI CONSTRUCTOR ===
function AISnake.new(startPosition)
	if #AISnake._activeSnakes >= MAX_AI_SNAKES then
		print("AI Snake limit reached:", MAX_AI_SNAKES)
		return nil
	end

	local self = setmetatable({}, AISnake)
	self.Config = deepCopy(SnakeConfig)

	-- Get random AI color (50% yellow, 50% others)
	local colorData = getRandomAIColor()
	self.Config.HeadColor = colorData.HeadColor
	self.Config.BodyColors = colorData.BodyColors
	self.Config.HeadMaterial = colorData.HeadMaterial
	self.Config.BodyMaterial = colorData.BodyMaterial

	self.Position = startPosition or Vector3new(0, 5, 0)
	self.Direction = Vector3new(0, 0, 1)
	self.Speed = self.Config.BaseSpeed or 10
	self.NormalSpeed = self.Config.BaseSpeed or 10
	self.BoostSpeed = self.Config.BoostSpeed or 24
	self.TurnSpeed = self.Config.TurnSpeed or 1.8 -- Better turning for orb collection
	self.RandomTurnInterval = 1.5
	self.LastTurn = tick()
	self.TargetYaw = 0
	self.CurrentYaw = 0

	self.FollowSpeed = self.Config.FollowSpeed or 0.95
	self.BoostFollowSpeed = self.Config.BoostFollowSpeed or 0.98
	self.SegmentSpacing = self.Config.SegmentSpacing or 2.2
	self.IsBoosting = false

	self.TargetOrb = nil
	self.TargetOrbExpire = 0

	self.State = "WANDER"
	self.SteerDirection = self.Direction
	self.Boosting = false
	self.BoostEndTime = 0
	self.BoostCooldown = 0
	self.TargetSnake = nil
	self.Avoiding = false
	self.AvoidExpire = 0
	self.AvoidDir = nil
	self.FleeReason = ""

	self.isConfident = false
	self.confidenceEndTime = 0
	self.circleAngle = mathRandom() * 2 * mathPi
	self.killCount = 0
	self.lastKillTime = 0

	local pType = AISnake.PersonalityTypes[mathRandom(1, #AISnake.PersonalityTypes)]
	self.Personality = deepCopy(AISnake.PersonalityDefinitions[pType])
	self._personalityType = pType

	self.Model = getOrCreateSnakeModel(tostring(self) .. "_" .. mathRandom(100000,999999))
	for _, obj in self.Model:GetChildren() do
		obj:Destroy()
	end

	self.RootPart = Instance.new("Part")
	self.RootPart.Name = "AISnakeRoot"
	self.RootPart.Size = Vector3new(2, 2, 2)
	self.RootPart.Anchored = true
	self.RootPart.CanCollide = false
	self.RootPart.Transparency = 1
	self.RootPart.Position = self.Position
	self.RootPart.Parent = self.Model

	self.HeadParts = createVisualHead(self.Config, self.Model)

	self.Segments = {}
	self.CurrentLength = self.Config.InitialLength

	self.MaxHistorySize = mathCeil(self.Config.MaxSegments * 1.2) + 20
	self.PositionHistory = table.create(self.MaxHistorySize)
	self.HistoryHead = 1
	local initialHistoryPoint = { position = self.Position, lookVector = self.Direction }
	for i = 1, self.MaxHistorySize do
		self.PositionHistory[i] = initialHistoryPoint
	end

	function self:addToHistory(data)
		self.PositionHistory[self.HistoryHead] = data
		self.HistoryHead = (self.HistoryHead % self.MaxHistorySize) + 1
	end
	function self:getFromHistory(stepsBack)
		local index = self.HistoryHead - stepsBack
		if index < 1 then
			index = index + self.MaxHistorySize
		end
		return self.PositionHistory[index]
	end

	for i = 1, self.CurrentLength do
		local pos = self.Position - self.Direction * (i * self.Config.SegmentSpacing)
		local colorIndex = ((i - 1) % #self.Config.BodyColors) + 1
		local color = self.Config.BodyColors[colorIndex]
		local segment = createSegment(i, pos, color, self.Config, self.Model, i)
		self.Segments[i] = segment
	end

	table.insert(AISnake._activeSnakes, self)
	self._active = true

	return self
end

-- === OTHER METHODS (simplified) ===
function AISnake:grow(amount)
	amount = amount or 5
	for i = 1, amount do
		if self.CurrentLength < self.Config.MaxSegments then
			self.CurrentLength = self.CurrentLength + 1
			local colorIndex = ((self.CurrentLength - 1) % #self.Config.BodyColors) + 1
			local color = self.Config.BodyColors[colorIndex]
			local lastSegment = self.Segments[#self.Segments]
			local newPos = lastSegment and lastSegment.Position or self.Position
			local segment = createSegment(self.CurrentLength, newPos, color, self.Config, self.Model, self.CurrentLength)
			self.Segments[self.CurrentLength] = segment

			-- Match CharacterSetup's segment growth exactly
			segment.Transparency = 1
			segment.Size = Vector3new(0.1, 0.1, 0.1)
			
			-- Apply growth factor for the final size
			local growthFactor = 1
			if self.CurrentLength > 200 then
				growthFactor = 1 + ((self.CurrentLength - 200) / 2800) * 1.0
			end
			local finalSize = self.Config.SegmentSize * mathMin(growthFactor, 2.0)
			
			task.spawn(function()
				if not segment or not segment.Parent then return end
				local growTime = 0.18
				local t = 0
				local startSize = Vector3new(0.1, 0.1, 0.1)
				while t < growTime do
					t = t + RunService.Heartbeat:Wait()
					if not segment or not segment.Parent then return end
					local alpha = mathMin(t / growTime, 1)
					segment.Size = startSize:Lerp(finalSize, alpha)
					segment.Transparency = 1 - alpha
				end
				if segment and segment.Parent then
					segment.Size = finalSize
					segment.Transparency = 0
				end
			end)
		end
	end
end

function AISnake:setConfidenceBuff()
	if not self._active then return end
	self.isConfident = true
	self.confidenceEndTime = tick() + 8 -- REDUCED from 12
	self.killCount = self.killCount + 1
	self.lastKillTime = tick()

	-- REMOVED: Debug yellow outline - keep it invisible
	-- if self.HeadParts and self.HeadParts.headOutline then
	--	self.HeadParts.headOutline.Color3 = Color3.fromRGB(255, 255, 0)
	--	self.HeadParts.headOutline.LineThickness = 0.3
	--	self.HeadParts.headOutline.Transparency = 0.3
	-- end
end

function AISnake:Destroy()
	if not self._active then return end
	self._active = false
	
	-- Immediately mark as destroyed to prevent any updates
	self._destroyed = true
	
	-- Untrack snake from orb pickup system
	if AISnakeOrbPickup then
		pcall(function()
			AISnakeOrbPickup.UntrackSnake(self)
		end)
	end

	-- Remove from active snakes list
	for i = #AISnake._activeSnakes, 1, -1 do
		if AISnake._activeSnakes[i] == self then
			table.remove(AISnake._activeSnakes, i)
			break
		end
	end
	AISnake._orbTargets[self] = nil

	-- Spawn orbs before destroying segments
	local orbSpawnData = {}
	if self.HeadParts and self.HeadParts.head and self.HeadParts.head.Parent then
		local head = self.HeadParts.head
		table.insert(orbSpawnData, {position = head.Position, size = 3.5, color = head.Color})
	end
	
	local ORB_SPAWN_DENSITY = 5
	for i = 1, #self.Segments do
		if i % ORB_SPAWN_DENSITY == 1 then
			local segment = self.Segments[i]
			if segment and segment.Parent then
				table.insert(orbSpawnData, {position = segment.Position, size = 1.8, color = segment.Color})
			end
		end
	end

	-- Spawn orbs asynchronously
	task.spawn(function()
		if OrbUtils and OrbUtils.spawnOrb then
			for i = 1, #orbSpawnData do
				local data = orbSpawnData[i]
				pcall(function()
					OrbUtils.spawnOrb(data.position, data.size, data.color)
				end)
			end
		end
	end)

	-- IMMEDIATE CLEANUP - Destroy all segments right away
	for i = 1, #self.Segments do
		local segment = self.Segments[i]
		if segment then
			-- Don't use returnSegment for death, just destroy
			pcall(function()
				segment:Destroy()
			end)
		end
	end
	self.Segments = {}

	-- Destroy head parts
	if self.HeadParts then
		for name, part in pairs(self.HeadParts) do
			if typeof(part) == "Instance" and part.Parent then
				pcall(function()
					part:Destroy()
				end)
			end
		end
	end

	-- Destroy model and all its descendants
	if self.Model and self.Model.Parent then
		pcall(function()
			-- First destroy all descendants to ensure nothing is left
			for _, descendant in ipairs(self.Model:GetDescendants()) do
				if descendant:IsA("BasePart") then
					descendant:Destroy()
				end
			end
			self.Model:Destroy()
		end)
	end
	
	-- Clear all references
	self.Model = nil
	self.HeadParts = nil
	self.RootPart = nil
	self.Segments = nil
end

-- === SMOOTHER MOVEMENT (FIXED) ===
function AISnake:updateMovement(dt)
	if self._destroyed then return end

	if not self._active or not self.HeadParts or not self.HeadParts.head or not self.HeadParts.head.Parent then
		if self._active and not self._destroyed then
			self:Destroy()
		end
		return
	end

	local now = tick()

	-- Don't move during spawn stabilization
	if self._spawnStabilizing and now < self._spawnStabilizing then
		return
	end
	
	local p = self.Personality

	-- Failsafe: Ensure we have a personality
	if not p then
		warn("AI Snake lost personality! Reassigning...")
		local pType = AISnake.PersonalityTypes[mathRandom(1, #AISnake.PersonalityTypes)]
		self.Personality = deepCopy(AISnake.PersonalityDefinitions[pType])
		p = self.Personality
	end

	local state = self.State
	local steer = self.SteerDirection

	-- Failsafe: Ensure we have a valid steer direction
	if not steer or steer.Magnitude < 0.1 then
		steer = self.Direction
	end

	-- Failsafe: Check if brain updates have stopped
	if self._lastBrainUpdate then
		local timeSinceLastBrain = now - self._lastBrainUpdate
		if timeSinceLastBrain > 2.0 then
			warn("AI Snake brain frozen for", timeSinceLastBrain, "seconds! Forcing update...")
			self:updateBrain()
			local found = false
			for _, snake in ipairs(AISnake._activeSnakes) do
				if snake == self then
					found = true
					break
				end
			end
			if not found and self._active then
				table.insert(AISnake._activeSnakes, self)
				print("🔧 Re-added frozen snake to active list")
			end
		end
	else
		self:updateBrain()
		self._lastBrainUpdate = now
	end

	-- SPAWN PROTECTION
	local isSpawnProtected = now < (self._spawnProtection or 0)

	-- Validate position (unless spawn protected)
	if not isSpawnProtected then
		if self.Position.X < MAP_BOUNDS.minX - 10 or self.Position.X > MAP_BOUNDS.maxX + 10 or
			self.Position.Z < MAP_BOUNDS.minZ - 10 or self.Position.Z > MAP_BOUNDS.maxZ + 10 then
			local safeX = mathClamp(self.Position.X, MAP_BOUNDS.minX + 50, MAP_BOUNDS.maxX - 50)
			local safeZ = mathClamp(self.Position.Z, MAP_BOUNDS.minZ + 50, MAP_BOUNDS.maxZ - 50)
			self.Position = Vector3new(safeX, self.Position.Y, safeZ)
			self.Direction = Vector3new(mathRandom() - 0.5, 0, mathRandom() - 0.5).Unit
			self.State = "WANDER"
			return
		end
	end

	-- SMOOTHER turning
	local forward = self.Direction
	local flatForward = Vector3new(forward.X, 0, forward.Z).Unit
	local flatSteer = Vector3new(steer.X, 0, steer.Z)
	local angle = 0
	if flatSteer.Magnitude > 0.01 then
		flatSteer = flatSteer.Unit
		angle = mathAtan2(flatSteer.X, flatSteer.Z) - mathAtan2(flatForward.X, flatForward.Z)
		if angle > mathPi then angle = angle - 2 * mathPi end
		if angle < -mathPi then angle = angle + 2 * mathPi end
	end
	local desiredYaw = self.CurrentYaw + angle
	self.TargetYaw = desiredYaw

	-- SIMPLER turn speed calculation
	local turnSpeed = self.TurnSpeed

	-- Only modify turn speed for emergency situations
	if state == "AVOID_BOUNDARY" then
		turnSpeed = turnSpeed * 2.0
	elseif state == "COLLISION_AVOID" then
		turnSpeed = turnSpeed * 2.5
	elseif state == "AVOID_WALL" then
		turnSpeed = turnSpeed * 1.4
	elseif self.Boosting then
		turnSpeed = turnSpeed * 0.9
	end

	-- Smooth turning
	local yawDiff = self.TargetYaw - self.CurrentYaw
	if yawDiff > mathPi then yawDiff = yawDiff - 2 * mathPi end
	if yawDiff < -mathPi then yawDiff = yawDiff + 2 * mathPi end

	local maxTurn = turnSpeed * dt
	yawDiff = mathClamp(yawDiff, -maxTurn, maxTurn)
	self.CurrentYaw = self.CurrentYaw + yawDiff

	-- Update direction from yaw
	self.Direction = Vector3new(mathSin(self.CurrentYaw), 0, mathCos(self.CurrentYaw))

	-- Movement variation
	if self.State == "WANDER" or self.State == "FLEE" then
		local wobbleTime = tick() * 2
		local wobbleAmount = 0.1
		local wobble = Vector3new(
			math.sin(wobbleTime) * wobbleAmount,
			0,
			math.cos(wobbleTime * 1.3) * wobbleAmount
		)
		self.Direction = (self.Direction + wobble).Unit
	end

	-- NO additional boundary force here - handled in _determineAction

	-- Boost management
	if self.Boosting and now > self.BoostEndTime then
		self.Boosting = false
		self.IsBoosting = false
	end

	-- SIMPLIFIED boost logic
	if not self.Boosting and now > self.BoostCooldown then
		local shouldBoost = false
		local boostDuration = 1.0

		if state == "FLEE" then
			if mathRandom() < 0.25 then
				shouldBoost = true
				boostDuration = 1.5
			end
		elseif state == "AVOID_BOUNDARY" or state == "COLLISION_AVOID" then
			shouldBoost = true
			boostDuration = 0.7
		elseif state == "WANDER" then
			if mathRandom() < (p.BoostChance or 0.05) * 0.25 then
				shouldBoost = true
			end
		end

		if shouldBoost then
			self:startBoost(boostDuration)
		end
	end

	-- Speed calculation
	local speedMultiplier = p.SpeedMultiplier or 1

	if self.Boosting then
		self.Speed = self.BoostSpeed * speedMultiplier
	else
		self.Speed = mathMax(self.NormalSpeed, self.NormalSpeed * speedMultiplier)
	end

	-- Position update
	local moveDistance = self.Speed * dt
	local newPosition = self.Position + self.Direction * moveDistance

	-- Simple clamping (brain handles turning away from edges)
	if not isSpawnProtected then
		local margin = 15
		newPosition = Vector3new(
			mathClamp(newPosition.X, MAP_BOUNDS.minX + margin, MAP_BOUNDS.maxX - margin),
			newPosition.Y,
			mathClamp(newPosition.Z, MAP_BOUNDS.minZ + margin, MAP_BOUNDS.maxZ - margin)
		)
	end
	
	self.Position = newPosition

	self.RootPart.Position = self.Position

	local headOffset = self.Direction * 1.5
	local newHeadPos = self.Position + headOffset
	self.HeadParts.head.CFrame = CFramelookAt(newHeadPos, newHeadPos + self.Direction)

	-- Update eyes position
	if self.HeadParts.leftEye and self.HeadParts.rightEye then
		local headCF = self.HeadParts.head.CFrame
		local headSize = self.HeadParts.head.Size.X
		local eyeScale = headSize / 3.5 * 0.5
		local eyeOffset = headSize * 0.3
		local eyeForward = -headSize * 0.35

		self.HeadParts.leftEye.Size = Vector3.new(eyeScale, eyeScale, eyeScale)
		self.HeadParts.rightEye.Size = Vector3.new(eyeScale, eyeScale, eyeScale)
		self.HeadParts.leftPupil.Size = Vector3.new(eyeScale * 0.5, eyeScale * 0.5, eyeScale * 0.5)
		self.HeadParts.rightPupil.Size = Vector3.new(eyeScale * 0.5, eyeScale * 0.5, eyeScale * 0.5)

		self.HeadParts.leftEye.CFrame = headCF * CFramenew(-eyeOffset, eyeOffset * 0.5, eyeForward)
		self.HeadParts.rightEye.CFrame = headCF * CFramenew(eyeOffset, eyeOffset * 0.5, eyeForward)
		self.HeadParts.leftPupil.CFrame = self.HeadParts.leftEye.CFrame * CFramenew(0, 0, -eyeScale * 0.3)
		self.HeadParts.rightPupil.CFrame = self.HeadParts.rightEye.CFrame * CFramenew(0, 0, -eyeScale * 0.3)
	end

	-- Set velocity for collision detection
	self.HeadParts.head.AssemblyLinearVelocity = self.Direction * self.Speed

	-- [ORB PICKUP CODE AND SEGMENT FOLLOWING CODE CONTINUES UNCHANGED...]
end

-- === UPDATE LOOPS (unchanged) ===
if AISnake._movementConnection then AISnake._movementConnection:Disconnect() end
if AISnake._brainConnection then AISnake._brainConnection:Disconnect() end

AISnake._movementConnection = RunService.Heartbeat:Connect(function(dt)
	local snakesToUpdate = {}
	for i = 1, #AISnake._activeSnakes do
		local snake = AISnake._activeSnakes[i]
		if snake and snake._active then
			table.insert(snakesToUpdate, snake)
		end
	end

	for i = 1, #snakesToUpdate do
		local snake = snakesToUpdate[i]
		if snake and snake._active then
			snake:updateMovement(dt)
		end
	end
end)

AISnake._brainUpdateIndex = 1
AISnake._spatialGridTimer = 0

AISnake._brainConnection = RunService.Stepped:Connect(function(time, deltaTime)
	AISnake._spatialGridTimer = AISnake._spatialGridTimer + deltaTime

	if AISnake._spatialGridTimer >= SPATIAL_GRID_UPDATE_RATE then
		AISnake._spatialGridTimer = 0

		SpatialGrid.Clear()

		for _, snake in AISnake._activeSnakes do
			if snake._active and snake.HeadParts and snake.HeadParts.head then
				SpatialGrid.Insert(snake.HeadParts.head, snake, "AI_HEAD")

				for i = 1, #snake.Segments, 4 do
					local segment = snake.Segments[i]
					if segment then
						SpatialGrid.Insert(segment, snake, "AI_SEGMENT")
					end
				end
			end
		end

		for _, player in Players:GetPlayers() do
			if player.Character then
				local head = player.Character:FindFirstChild("HumanoidRootPart")
				if head then
					SpatialGrid.Insert(head, player, "PLAYER_HEAD")
				end

				local segmentCount = 0
				for _, part in player.Character:GetChildren() do
					if part:IsA("BasePart") and part.Name:match("Segment") then
						segmentCount = segmentCount + 1
						if segmentCount % 4 == 1 then
							SpatialGrid.Insert(part, player, "PLAYER_SEGMENT")
						end
					end
				end
			end
		end

		for _, orb in OrbUtils.orbs do
			SpatialGrid.Insert(orb, orb, "ORB")
		end
	end 

	local snakes = AISnake._activeSnakes
	if #snakes == 0 then return end

	for i = 1, BRAIN_UPDATES_PER_FRAME do
		if AISnake._brainUpdateIndex > #snakes then
			AISnake._brainUpdateIndex = 1
		end

		local snake = snakes[AISnake._brainUpdateIndex]
		if snake and snake._active then
			snake:updateBrain()
		end

		AISnake._brainUpdateIndex = AISnake._brainUpdateIndex + 1
	end
end)




return AISnake
