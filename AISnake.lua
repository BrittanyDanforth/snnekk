-- AISnake Module: SMOOTH AI MOVEMENT V5.0 - COMBINED & LEADERBOARD READY
-- Completely redesigned AI brain for smooth, intelligent movement with leaderboard integration

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local SnakeConfig = require(ReplicatedStorage:WaitForChild("SnakeConfig"))
local OrbUtils -- Lazy loaded to prevent cyclic dependency

-- Load the orb pickup module
local AISnakeOrbPickup
pcall(function()
	local module = ReplicatedStorage:FindFirstChild("AISnakeOrbPickup") or game.ServerScriptService:FindFirstChild("AISnakeOrbPickup")
	if module then
		AISnakeOrbPickup = require(module)
	end
end)

-- Load SnakeUpgrades module for upgrade orbs
local SnakeUpgrades
pcall(function()
	local module = ReplicatedStorage:FindFirstChild("SnakeUpgrades")
	if module then
		SnakeUpgrades = require(module)
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

local function randomFloat(minValue, maxValue)
	return minValue + (maxValue - minValue) * mathRandom()
end

local function sanitizeNumber(value, defaultValue)
	if typeof(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge then
		return value
	end
	return defaultValue or 0
end

local function isValidVector(vec)
	return typeof(vec) == "Vector3"
		and vec.X == vec.X
		and vec.Y == vec.Y
		and vec.Z == vec.Z
end

local function sanitizeVector(vec, fallback)
	if not isValidVector(vec) or vec.Magnitude < 0.0001 then
		return fallback or Vector3new(0, 0, 1)
	end
	return vec
end

local MAX_TURN_DEG = 90 -- Increased for sharper turns
local HARD_TURN_DEG = 120 -- Increased for emergency evasion

local function limitTurnAngle(currentDir, desiredDir, allowHardTurn)
	if not (isValidVector(currentDir) and isValidVector(desiredDir)) then
		return desiredDir
	end

	currentDir = currentDir.Unit
	desiredDir = desiredDir.Unit

	local maxAngle = mathRad(allowHardTurn and HARD_TURN_DEG or MAX_TURN_DEG)
	local cosMax = mathCos(maxAngle)
	local dot = mathClamp(currentDir:Dot(desiredDir), -1, 1)
	if dot >= cosMax then
		return desiredDir
	end

	local right = currentDir:Cross(Vector3new(0, 1, 0))
	if right.Magnitude < 0.001 then
		return desiredDir
	end
	right = right.Unit

	local turnDir = right:Dot(desiredDir) >= 0 and 1 or -1
	local currentAngle = mathAtan2(currentDir.X, currentDir.Z)
	local limitedAngle = currentAngle + maxAngle * turnDir
	return Vector3new(mathSin(limitedAngle), 0, mathCos(limitedAngle))
end

local LETTERS = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"}
local NAME_SUFFIXES = {"x","z","n","l","r","q","k"}
local usedAINames = {}

local function generateAIUsername()
	local baseLength = mathRandom(8, 10)
	local chars = {}

	for i = 1, baseLength do
		local letter = LETTERS[mathRandom(#LETTERS)]
		if i == 1 then
			letter = letter:upper()
		elseif mathRandom() < 0.15 then
			letter = letter:upper()
		end
		chars[i] = letter
	end

	if mathRandom() < 0.45 and #chars < 12 then
		local suffix = tostring(mathRandom(10, 99))
		for i = 1, #suffix do
			if #chars >= 12 then break end
			chars[#chars + 1] = suffix:sub(i, i)
		end
	elseif #chars < 10 then
		chars[#chars + 1] = NAME_SUFFIXES[mathRandom(#NAME_SUFFIXES)]
	end

	local username = table.concat(chars)
	if #username > 12 then
		username = username:sub(1, 12)
	end
	return username
end

local function releaseAIName(name)
	if name then
		usedAINames[name] = nil
	end
end

local function getUniqueAIName()
	for _ = 1, 8 do
		local candidate = generateAIUsername()
		if not usedAINames[candidate] then
			usedAINames[candidate] = true
			return candidate
		end
	end

	local fallback = string.format("AISnake%05d", mathRandom(10000, 99999))
	usedAINames[fallback] = true
	return fallback
end

local function scoreOrbCandidate(orb, distance)
	distance = math.max(distance, 1)
	local baseValue = 1

	local valueObj = orb:FindFirstChild("Value")
	if valueObj and typeof(valueObj.Value) == "number" then
		baseValue = math.max(valueObj.Value, 0.1)
	elseif orb:GetAttribute("Value") then
		baseValue = math.max(tonumber(orb:GetAttribute("Value")) or 1, 0.1)
	end

	if orb.Name == "DeathOrb" then
		baseValue = baseValue * 15 -- Heavily prioritize death orbs
	elseif orb.Name == "UpgradeOrb" then
		baseValue = baseValue * 10 -- Prioritize upgrades
	end

	return baseValue / distance
end

local function perpendicular(vector)
	return Vector3new(-vector.Z, 0, vector.X)
end

local AISnake = {}
AISnake.__index = AISnake

-- === OPTIMIZED SETTINGS ===
local MAX_AI_SNAKES = 15 -- matches runtime limits
local SPATIAL_GRID_UPDATE_RATE = 0.1 -- UPDATED: Faster updates (10Hz) for better reaction to cut-offs
local BRAIN_UPDATES_PER_FRAME = 3 -- multiple brains per step
local DEBUG_UPDATE_RATE = 5.0
local AI_HEIGHT = 5
local SEGMENT_UPDATE_SKIP = 2
local LONG_SNAKE_THRESHOLD = 100
local VERY_LONG_SNAKE_THRESHOLD = 300
local AI_UPDATE_DISTANCE = 1500 -- Increased significantly to keep distant AI active
local SEGMENT_POOL_MAX = 500

-- LOD Constants
local VISIBILITY_CHECK_INTERVAL = 5
local RENDER_DISTANCE = 1000
local LOD_DISTANCE_NEAR = 200
local LOD_DISTANCE_MID = 400
local LOD_DISTANCE_FAR = 600
local LOD_DISTANCE_MINIMAL = 800
local BEAM_SYNC_INTERVAL = 3
local FORCE_RENDER_SEGMENTS = 150
local MIN_VISIBLE_SEGMENTS = 10
local MAX_VISIBLE_SEGMENTS = 2000
local DYNAMIC_SEGMENT_LIMIT = 800

local VISIBILITY_PERCENTAGES = {
	near = 1.0,
	mid = 0.7,
	far = 0.4,
	minimal = 0.2,
	veryFar = 0.1,
}

-- Visual Constants
local BASE_SIZE = 3.5
local MAX_SIZE_MULTIPLIER = 3.5
local GLOW_INTENSITY = 2
local GLOW_RANGE_BASE = 15
local BEAM_SEGMENTS = 10
local BEAM_WIDTH_BASE = 0.95
local BEAM_TAPER_STRENGTH = 0.15
local HEAD_SIZE_MULTIPLIER = 1.05
local HEAD_BLEND_SEGMENTS = 8
local GLOW_FALLOFF_START = 50
local VISUAL_SMOOTHING_FACTOR = 0.6

-- Growth Animation Constants
local GROWTH_SPEED = 0.15
local SEGMENT_GROWTH_DELAY = 0.05
local GROWTH_PULSE_STRENGTH = 0.1
local GROWTH_WAVE_SPEED = 10

-- Visual Enhancement Constants
local BEAM_TEXTURE_SPEED = 2
local PARTICLE_VELOCITY_INHERITANCE = 0.7
local PARTICLE_DRAG = 3
local BOOST_PARTICLE_SIZE = NumberSequence.new{
	NumberSequenceKeypoint.new(0, 0.5),
	NumberSequenceKeypoint.new(0.5, 1),
	NumberSequenceKeypoint.new(1, 0)
}
local MOBILE_PARTICLE_RATE = 100
local DESKTOP_PARTICLE_RATE = 200

local BEAM_TEXTURES = {
	gradient = "rbxasset://textures/ui/LuaChat/9-slice/kit-modal-highlight.png",
	flow = "rbxasset://textures/ui/GuiImagePlaceholder.png",
	energy = "rbxasset://textures/particles/sparkles_main.dds",
	smooth = "rbxasset://textures/ui/LuaChat/icons/ic-gift.png"
}

AISnake._activeSnakes = {}
AISnake._orbTargets = {}

-- Snakes folder support
local SnakesFolder = Workspace:FindFirstChild("Snakes")
if not SnakesFolder then
	SnakesFolder = Instance.new("Folder")
	SnakesFolder.Name = "Snakes"
	SnakesFolder.Parent = Workspace
end

-- === SPATIAL GRID ===
local SpatialGrid = {}
local gridGeneration = 0
local entityPositionCache = {}
local partSizeCache = {}
do
	local CELL_SIZE = 75
	local grid = {}
	local ground = Workspace:FindFirstChild("SlitherIOGround")
	local mapSize = ground and ground.Size or Vector3new(3000, 10, 3000) -- Default larger map if not found
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
						for _, entity in ipairs(grid[x][z]) do
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

-- === SEGMENT POOLING ===
local SegmentPool = {}
local PoolSize = 0
local MAX_POOL_SIZE = 1000
local SEGMENT_PARENT = Workspace:FindFirstChild("AISegmentContainer") or Instance.new("Folder", Workspace)
SEGMENT_PARENT.Name = "AISegmentContainer"

local function resetSegment(segment, config)
	segment.Anchored = true
	segment.CanCollide = false
	segment.CanTouch = false
	segment.CanQuery = false
	segment.Transparency = 0
	segment.Size = config.SegmentSize
	segment.Material = config.BodyMaterial or Enum.Material.Neon
	segment.Shape = Enum.PartType.Ball
	segment.TopSurface = Enum.SurfaceType.Smooth
	segment.BottomSurface = Enum.SurfaceType.Smooth
	segment.Name = "AISegment"
	for _, child in ipairs(segment:GetChildren()) do
		child:Destroy()
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
	for _, child in ipairs(segment:GetChildren()) do
		child:Destroy()
	end
	if PoolSize >= MAX_POOL_SIZE then
		segment:Destroy()
		return
	end
	segment.Transparency = 1
	segment.CanCollide = false
	segment.CanQuery = false
	segment.CanTouch = false
	segment.Anchored = true
	segment.Color = Color3.new()
	segment.Material = Enum.Material.Neon
	segment.Size = Vector3.new(3.5, 3.5, 4)
	segment.Parent = SEGMENT_PARENT
	PoolSize = PoolSize + 1
	SegmentPool[PoolSize] = segment
end

-- === HELPER FUNCTIONS ===
local function getOrCreateSnakeModel(aiId)
	local modelName = "AISnakeModel_" .. tostring(aiId)
	local existing = SnakesFolder:FindFirstChild(modelName)
	if existing and existing:IsA("Model") then
		return existing
	end
	local model = Instance.new("Model")
	model.Name = modelName
	model.Parent = SnakesFolder
	CollectionService:AddTag(model, "AISnake")
	return model
end

local AISnakeColors = {
	{
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
	if mathRandom() < 0.5 then
		return AISnakeColors[1]
	else
		return AISnakeColors[mathRandom(2, #AISnakeColors)]
	end
end

local function deepCopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == "table" then
		copy = {}
		for orig_key, orig_value in pairs(orig) do
			copy[orig_key] = deepCopy(orig_value)
		end
	else
		copy = orig
	end
	return copy
end

local function pickAIName()
	return getUniqueAIName()
end

-- === VISUAL CREATION ===
local function createVisualHead(config, parentModel)
	local headPart = Instance.new("Part")
	headPart.Name = "Head"
	headPart.Size = Vector3.new(BASE_SIZE * HEAD_SIZE_MULTIPLIER, BASE_SIZE * HEAD_SIZE_MULTIPLIER, BASE_SIZE * HEAD_SIZE_MULTIPLIER)
	headPart.Material = Enum.Material.Neon
	headPart.Color = config.HeadColor
	headPart.Shape = Enum.PartType.Ball
	headPart.CanCollide = false
	headPart.CanTouch = true
	headPart.CanQuery = true
	headPart.Anchored = true
	headPart.TopSurface = Enum.SurfaceType.Smooth
	headPart.BottomSurface = Enum.SurfaceType.Smooth
	headPart.Transparency = 0
	headPart.Parent = parentModel

	local headLight = Instance.new("PointLight")
	headLight.Name = "Glow"
	headLight.Color = config.HeadColor
	headLight.Brightness = GLOW_INTENSITY
	headLight.Range = GLOW_RANGE_BASE * 1.1
	headLight.Shadows = false
	headLight.Parent = headPart

	local boostParticles = Instance.new("ParticleEmitter")
	boostParticles.Name = "BoostParticles"
	boostParticles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	boostParticles.Color = ColorSequence.new(config.HeadColor)
	boostParticles.Lifetime = NumberRange.new(0.5, 1)
	boostParticles.Rate = 0
	boostParticles.Speed = NumberRange.new(5, 10)
	boostParticles.SpreadAngle = Vector2.new(180, 180)
	boostParticles.VelocityInheritance = PARTICLE_VELOCITY_INHERITANCE
	boostParticles.Drag = PARTICLE_DRAG
	boostParticles.Size = BOOST_PARTICLE_SIZE
	boostParticles.Rotation = NumberRange.new(0, 360)
	boostParticles.RotSpeed = NumberRange.new(-180, 180)
	boostParticles.Enabled = false
	boostParticles.LightEmission = 1
	boostParticles.LightInfluence = 0
	boostParticles.ZOffset = 1
	boostParticles.Parent = headPart

	local function createEye(xOffset)
		local eye = Instance.new("Part")
		eye.Name = xOffset > 0 and "RightEye" or "LeftEye"
		eye.Shape = Enum.PartType.Ball
		eye.Material = Enum.Material.Neon
		eye.Color = Color3.fromRGB(255, 255, 255)
		eye.Size = Vector3.new(0.5, 0.5, 0.5)
		eye.Transparency = 0
		eye.CanCollide = false
		eye.Anchored = true
		eye:SetAttribute("AlwaysRender", true)
		eye.Parent = parentModel

		local pupil = Instance.new("Part")
		pupil.Name = eye.Name .. "Pupil"
		pupil.Shape = Enum.PartType.Ball
		pupil.Material = Enum.Material.Neon
		pupil.Color = Color3.fromRGB(0, 0, 0)
		pupil.Size = Vector3.new(0.25, 0.25, 0.25)
		pupil.Transparency = 0
		pupil.CanCollide = false
		pupil.Anchored = true
		pupil:SetAttribute("AlwaysRender", true)
		pupil.Parent = parentModel

		return eye, pupil
	end

	local leftEye, leftPupil = createEye(-1)
	local rightEye, rightPupil = createEye(1)

	return {
		head = headPart,
		headLight = headLight,
		boostParticles = boostParticles,
		leftEye = leftEye,
		rightEye = rightEye,
		leftPupil = leftPupil,
		rightPupil = rightPupil,
	}
end

local function createSegment(index, position, color, config, parentModel, currentLength)
	local segment = getSegment(config)
	segment.Name = "AISegment" .. index
	segment.Shape = Enum.PartType.Ball
	segment.Material = Enum.Material.Neon
	segment.Size = Vector3.new(BASE_SIZE, BASE_SIZE, BASE_SIZE)
	segment.Color = color
	segment.CFrame = CFramenew(position)
	segment.Parent = parentModel
	segment.Transparency = 0
	segment.CanCollide = false
	segment.CanTouch = index <= 50
	segment.CanQuery = false
	segment.Anchored = true

	segment:SetAttribute("IsSnakeSegment", true)
	segment:SetAttribute("SegmentIndex", index)
	segment:SetAttribute("IsAISnake", true)

	local shouldHaveGlow = false
	if index <= GLOW_FALLOFF_START then
		shouldHaveGlow = true
	elseif index <= 100 then
		shouldHaveGlow = index % 2 == 0
	elseif index <= 200 then
		shouldHaveGlow = index % 3 == 0
	else
		shouldHaveGlow = index % 5 == 0
	end

	if shouldHaveGlow then
		local light = segment:FindFirstChild("Glow") or Instance.new("PointLight")
		light.Name = "Glow"
		light.Color = color
		light.Brightness = GLOW_INTENSITY * 0.9
		light.Range = GLOW_RANGE_BASE * (0.9 - (index / (currentLength or 100)) * 0.1)
		light.Shadows = false
		light.Enabled = true
		light.Parent = segment
	else
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
	for _, child in ipairs(player.Character:GetChildren()) do
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

local WALL_NAMES = {"SlitherIOWall_Left", "SlitherIOWall_Right", "SlitherIOWall_Top", "SlitherIOWall_Bottom"}
local wallParts = {}

task.spawn(function()
	task.wait(0.1)
	for _, wallName in ipairs(WALL_NAMES) do
		local wall = Workspace:FindFirstChild(wallName)
		if wall and wall:IsA("BasePart") then
			table.insert(wallParts, wall)
		end
	end
end)

local MAP_BOUNDS = {
	minX = -1450,
	maxX = 1450,
	minZ = -1450,
	maxZ = 1450
}

local function updateMapBounds()
	local ground = Workspace:FindFirstChild("SlitherIOGround")
	if ground and ground:IsA("BasePart") then
		local halfSizeX = ground.Size.X / 2
		local halfSizeZ = ground.Size.Z / 2
		MAP_BOUNDS.minX = ground.Position.X - halfSizeX + 30
		MAP_BOUNDS.maxX = ground.Position.X + halfSizeX - 30
		MAP_BOUNDS.minZ = ground.Position.Z - halfSizeZ + 30
		MAP_BOUNDS.maxZ = ground.Position.Z + halfSizeZ - 30
		return true
	end
	-- Fallback: Keep default large bounds
	return false
end

updateMapBounds()

task.spawn(function()
	while true do
		task.wait(30)
		local oldBounds = {minX = MAP_BOUNDS.minX, maxX = MAP_BOUNDS.maxX, minZ = MAP_BOUNDS.minZ, maxZ = MAP_BOUNDS.maxZ}
		if updateMapBounds() then
			if oldBounds.minX ~= MAP_BOUNDS.minX or oldBounds.maxX ~= MAP_BOUNDS.maxX or
				oldBounds.minZ ~= MAP_BOUNDS.minZ or oldBounds.maxZ ~= MAP_BOUNDS.maxZ then
				warn("MAP BOUNDS CHANGED", oldBounds, MAP_BOUNDS)
			end
		end
	end
end)

local function getWallAvoidanceVector(headPos)
	local avoidVec = Vector3new(0, 0, 0)
	local avoidStrength = 0

	local boundaryThreshold = 50
	local strongThreshold = 25

	if headPos.X < MAP_BOUNDS.minX + boundaryThreshold then
		local dist = MAP_BOUNDS.minX - headPos.X + boundaryThreshold
		avoidVec = avoidVec + Vector3new(1, 0, 0) * (dist / boundaryThreshold)
		avoidStrength = math.max(avoidStrength, dist < strongThreshold and 1 or 0.5)
	elseif headPos.X > MAP_BOUNDS.maxX - boundaryThreshold then
		local dist = headPos.X - MAP_BOUNDS.maxX + boundaryThreshold
		avoidVec = avoidVec + Vector3new(-1, 0, 0) * (dist / boundaryThreshold)
		avoidStrength = math.max(avoidStrength, dist < strongThreshold and 1 or 0.5)
	end

	if headPos.Z < MAP_BOUNDS.minZ + boundaryThreshold then
		local dist = MAP_BOUNDS.minZ - headPos.Z + boundaryThreshold
		avoidVec = avoidVec + Vector3new(0, 0, 1) * (dist / boundaryThreshold)
		avoidStrength = math.max(avoidStrength, dist < strongThreshold and 1 or 0.5)
	elseif headPos.Z > MAP_BOUNDS.maxZ - boundaryThreshold then
		local dist = headPos.Z - MAP_BOUNDS.maxZ + boundaryThreshold
		avoidVec = avoidVec + Vector3new(0, 0, -1) * (dist / boundaryThreshold)
		avoidStrength = math.max(avoidStrength, dist < strongThreshold and 1 or 0.5)
	end

	if avoidStrength > 0 then
		return avoidVec.Unit * avoidStrength * 2, avoidStrength
	end

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

-- (rest of file continues...)
-- === ENHANCED AI PERSONALITIES ===
AISnake.PersonalityTypes = {
	"Collector", "Explorer", "Predator", "Opportunist", "Farmer", "Raider", "Guardian", "Nomad"
}

AISnake.PersonalityDefinitions = {
	Collector = {
		Type = "Collector",
		TargetPlayers = false,
		TargetOrbs = true,
		AvoidOthers = true,
		SpeedMultiplier = 1.05,
		TurnBias = 0.015,
		BoostChance = 0.04,
		CombatRadius = 20,
		RandomTurnInterval = 4.0,
		OrbSeekRadius = 300,
		Description = "Efficient orb collector",
		FleeThreshold = 10,
		AggressionLevel = 0.0,
		PatrolRadius = 500,
		MovementPattern = "spiral",
		PreferEdgeOrbs = true,
		MinStraightDistance = 100,
	},
	Explorer = {
		Type = "Explorer",
		TargetPlayers = false,
		TargetOrbs = true,
		AvoidOthers = false,
		SpeedMultiplier = 1.15,
		TurnBias = 0.02,
		BoostChance = 0.05,
		CombatRadius = 30,
		RandomTurnInterval = 5.0,
		OrbSeekRadius = 200,
		Description = "Map explorer",
		FleeThreshold = 15,
		AggressionLevel = 0.1,
		PatrolRadius = 600,
		MovementPattern = "zigzag",
		ExplorationSectors = 8,
		CurrentSector = 1,
		MinStraightDistance = 150,
	},
	Predator = {
		Type = "Predator",
		TargetPlayers = true,
		TargetOrbs = true,
		AvoidOthers = false,
		SpeedMultiplier = 1.2,
		TurnBias = 0.025,
		BoostChance = 0.08,
		CombatRadius = 60,
		RandomTurnInterval = 3.0,
		OrbSeekRadius = 400, -- Increased from 150
		Description = "Smart hunter",
		FleeThreshold = 20,
		AggressionLevel = 0.8,
		PatrolRadius = 300,
		MovementPattern = "patrol",
		AmbushPoints = {},
		PreferCenterHunting = true,
		MinStraightDistance = 80,
	},
	Opportunist = {
		Type = "Opportunist",
		TargetPlayers = true,
		TargetOrbs = true,
		AvoidOthers = false,
		SpeedMultiplier = 1.18,
		TurnBias = 0.03,
		BoostChance = 0.07,
		CombatRadius = 50,
		RandomTurnInterval = 3.5,
		OrbSeekRadius = 450, -- Increased from 180
		Description = "Adaptive hunter",
		FleeThreshold = 15,
		AggressionLevel = 0.6,
		PatrolRadius = 350,
		MovementPattern = "adaptive",
		OpportunityRadius = 100,
		MinStraightDistance = 90,
	},
	Farmer = {
		Type = "Farmer",
		TargetPlayers = false,
		TargetOrbs = true,
		AvoidOthers = true,
		SpeedMultiplier = 1.0,
		TurnBias = 0.01,
		BoostChance = 0.02,
		CombatRadius = 15,
		RandomTurnInterval = 5.0,
		OrbSeekRadius = 600, -- Increased from 400
		Description = "Peaceful farmer",
		FleeThreshold = 5,
		AggressionLevel = 0.0,
		PatrolRadius = 250,
		MovementPattern = "grid",
		GridSize = 100,
		CurrentGridX = 0,
		CurrentGridZ = 0,
		MinStraightDistance = 120,
	},
	Raider = {
		Type = "Raider",
		TargetPlayers = true,
		TargetOrbs = true,
		AvoidOthers = false,
		SpeedMultiplier = 1.25,
		TurnBias = 0.04,
		BoostChance = 0.1,
		CombatRadius = 45,
		RandomTurnInterval = 2.5,
		OrbSeekRadius = 350, -- Increased from 120
		Description = "Aggressive raider",
		FleeThreshold = 25,
		AggressionLevel = 0.9,
		PatrolRadius = 400,
		MovementPattern = "hitandrun",
		RaidCooldown = 10,
		LastRaidTime = 0,
		MinStraightDistance = 70,
	},
	Guardian = {
		Type = "Guardian",
		TargetPlayers = true,
		TargetOrbs = true,
		AvoidOthers = false,
		SpeedMultiplier = 1.1,
		TurnBias = 0.02,
		BoostChance = 0.05,
		CombatRadius = 70,
		RandomTurnInterval = 4.0,
		OrbSeekRadius = 400, -- Increased from 160
		Description = "Territory defender",
		FleeThreshold = 30,
		AggressionLevel = 0.5,
		PatrolRadius = 200,
		MovementPattern = "circular",
		TerritoryCenter = Vector3.new(0, 0, 0),
		TerritoryRadius = 150,
		PatrolAngle = 0,
		MinStraightDistance = 60,
	},
	Nomad = {
		Type = "Nomad",
		TargetPlayers = false,
		TargetOrbs = true,
		AvoidOthers = false,
		SpeedMultiplier = 1.12,
		TurnBias = 0.025,
		BoostChance = 0.06,
		CombatRadius = 35,
		RandomTurnInterval = 6.0,
		OrbSeekRadius = 500, -- Increased from 220
		Description = "Wandering nomad",
		FleeThreshold = 20,
		AggressionLevel = 0.3,
		PatrolRadius = 700,
		MovementPattern = "wander",
		WanderTargets = {},
		CurrentWanderTarget = 1,
		MinStraightDistance = 200,
	},
}

local function buildSkillProfile()
	local roll = randomFloat(0, 1)
	if roll < 0.25 then
		return {
			label = "Rookie",
			turnMultiplier = randomFloat(0.65, 0.85),
			speedMultiplier = randomFloat(0.85, 0.95),
			boostMultiplier = randomFloat(0.5, 0.75),
			errorChance = randomFloat(0.3, 0.45),
			reactionLag = randomFloat(0.12, 0.25),
			dodgeBias = randomFloat(0.75, 0.9)
		}
	elseif roll < 0.7 then
		return {
			label = "Nominal",
			turnMultiplier = randomFloat(0.85, 1.05),
			speedMultiplier = randomFloat(0.95, 1.05),
			boostMultiplier = randomFloat(0.8, 1.0),
			errorChance = randomFloat(0.12, 0.25),
			reactionLag = randomFloat(0.06, 0.14),
			dodgeBias = randomFloat(0.9, 1.05)
		}
	elseif roll < 0.9 then
		return {
			label = "Veteran",
			turnMultiplier = randomFloat(1.05, 1.2),
			speedMultiplier = randomFloat(1.05, 1.15),
			boostMultiplier = randomFloat(1.0, 1.2),
			errorChance = randomFloat(0.05, 0.12),
			reactionLag = randomFloat(0.04, 0.1),
			dodgeBias = randomFloat(1.05, 1.2)
		}
	else
		return {
			label = "Elite",
			turnMultiplier = randomFloat(1.2, 1.35),
			speedMultiplier = randomFloat(1.1, 1.25),
			boostMultiplier = randomFloat(1.1, 1.35),
			errorChance = randomFloat(0.02, 0.08),
			reactionLag = randomFloat(0.02, 0.06),
			dodgeBias = randomFloat(1.15, 1.3)
		}
	end
end

-- === AI METHODS ===
function AISnake:findBestOrb()
	local seekRadius = self.Personality.OrbSeekRadius or 50
	local scanRadius = seekRadius * 2
	local headPos = (self.HeadParts and self.HeadParts.head and self.HeadParts.head.Position) or self.Position

	local targetedOrbs = {}
	for ai, orb in pairs(AISnake._orbTargets) do
		if ai ~= self and orb and orb.Parent then
			targetedOrbs[orb] = true
		end
	end

	local bestScore = -math.huge
	local bestOrb = nil
	local bestDistance = math.huge

	local function considerOrb(orb)
		if not orb or targetedOrbs[orb] then
			return
		end
		local dist = (orb.Position - headPos).Magnitude
		
		-- Vision range check
		if dist > scanRadius then
			return
		end
		
		local score = scoreOrbCandidate(orb, dist)
		
		-- Hysteresis: New orb must be significantly better than current target to switch
		-- This prevents jittering but allows switching to high value targets
		if score > bestScore then
			bestScore = score
			bestOrb = orb
			bestDistance = dist
		end
	end

	local orbFolder = Workspace:FindFirstChild("OrbFolder")
	if orbFolder then
		if not OrbUtils then OrbUtils = require(ReplicatedStorage:WaitForChild("OrbUtils")) end
		for _, orb in ipairs(orbFolder:GetChildren()) do
			if orb:IsA("BasePart") and (orb.Name == "UpgradeOrb" or orb.Name == "DeathOrb") then
				considerOrb(orb)
			end
		end
	end

	local nearbyEntities = SpatialGrid.QueryRadius(headPos, scanRadius)
	for _, entity in ipairs(nearbyEntities) do
		if entity.type == "ORB" and entity.part then
			considerOrb(entity.part)
		end
	end

	return bestOrb, bestDistance
end

function AISnake:findNearestSnakeHead()
	local myHead = self.HeadParts and self.HeadParts.head
	if not myHead then return nil, math.huge end
	local myPos = myHead.Position
	local minDist = math.huge
	local nearest = nil

	local nearbyEntities = SpatialGrid.QueryRadius(myPos, self.Personality.CombatRadius or 60)

	for _, entity in ipairs(nearbyEntities) do
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

	local threatRadius = 80
	local nearbyEntities = SpatialGrid.QueryRadius(myPos, threatRadius)

	for _, entity in ipairs(nearbyEntities) do
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
					position = entity.part.Position,
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
	self.BoostCooldown = self.BoostEndTime + mathRandom(15, 30) / 10

	if self.HeadParts and self.HeadParts.boostParticles then
		self.HeadParts.boostParticles.Enabled = true
		local isMobile = game:GetService("UserInputService").TouchEnabled
		self.HeadParts.boostParticles.Rate = isMobile and MOBILE_PARTICLE_RATE or DESKTOP_PARTICLE_RATE

		task.delay(duration, function()
			if self.HeadParts and self.HeadParts.boostParticles then
				self.HeadParts.boostParticles.Enabled = false
			end
		end)
	end
end

function AISnake:getFleeVector()
	local myHead = self.HeadParts and self.HeadParts.head
	if not myHead then return Vector3new(0, 0, 1) end

	local headPos = myHead.Position
	local threats = self:findNearbyThreats()
	local wallVec, wallStrength = getWallAvoidanceVector(headPos)

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
		local totalThreatVector = Vector3new(0, 0, 0)
		local totalWeight = 0

		for _, threat in ipairs(threats) do
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

	if wallVec and wallStrength > 0.2 then
		if fleeDir then
			fleeDir = (fleeDir + wallVec.Unit * 2).Unit
		else
			fleeDir = wallVec.Unit
		end
	end

	if not fleeDir then
		local mapCenter = Vector3new(0, headPos.Y, 0)
		local toCenter = (mapCenter - headPos)
		local distFromCenter = toCenter.Magnitude

		if distFromCenter > 150 then
			fleeDir = toCenter.Unit
		else
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

	local mapCenter = Vector3new(0, headPos.Y, 0)
	local distFromCenter = (mapCenter - headPos).Magnitude
	if distFromCenter > 400 and fleeDir then
		local toCenter = (mapCenter - headPos).Unit
		fleeDir = (fleeDir + toCenter * 0.1).Unit
	end

	return fleeDir
end

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

	for d = stepSize, checkDist, stepSize do
		local checkPos = myPos + direction * d
		local nearbyEntities = SpatialGrid.QueryRadius(checkPos, 8)
		for _, entity in ipairs(nearbyEntities) do
			if entity.type == "AI_SEGMENT" or entity.type == "PLAYER_SEGMENT" then
				if entity.owner ~= self then
					return false
				end
			elseif entity.type == "AI_HEAD" or entity.type == "PLAYER_HEAD" then
				if entity.owner ~= self then
					local theirVel = entity.part.AssemblyLinearVelocity or Vector3.zero
					local timeToReach = d / self.Speed
					local theirFuturePos = entity.part.Position + theirVel * timeToReach

					if (checkPos - theirFuturePos).Magnitude < 10 then
						return false
					end
				end
			end
		end
	end

	return true
end

function AISnake:getSmartFleeDirection(threats)
	if not self.HeadParts or not self.HeadParts.head then
		return Vector3new(mathRandom(-1, 1), 0, mathRandom(-1, 1)).Unit
	end

	local myPos = self.HeadParts.head.Position

	local dangerVectors = {}
	for _, threat in ipairs(threats) do
		if threat.part and threat.part.Parent then
			local threatPos = threat.part.Position
			local awayFromThreat = (myPos - threatPos).Unit
			local weight = 1 / mathMax(threat.distance, 5)
			if threat.lengthDiff > 20 then
				weight = weight * 2
			end
			table.insert(dangerVectors, {
				direction = awayFromThreat,
				weight = weight
			})
		end
	end

	local fleeDir = Vector3.zero
	local totalWeight = 0

	for _, danger in ipairs(dangerVectors) do
		fleeDir = fleeDir + danger.direction * danger.weight
		totalWeight = totalWeight + danger.weight
	end

	local toCenter = Vector3new(0, myPos.Y, 0) - myPos
	local distFromCenter = toCenter.Magnitude
	if distFromCenter > 200 then
		local centerWeight = (distFromCenter - 200) / 100
		fleeDir = fleeDir + toCenter.Unit * centerWeight
		totalWeight = totalWeight + centerWeight
	end

	if totalWeight > 0 then
		fleeDir = (fleeDir / totalWeight).Unit

		if not self:isPathSafe(myPos + fleeDir * 30, 30) then
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

	return toCenter.Unit
end

function AISnake:_initPathSystem()
	local spacing = self.PathSpacing or self.SegmentSpacing or 2.2
	local maxSegments = self.Config.MaxSegments or DYNAMIC_SEGMENT_LIMIT
	local path = {
		points = {},
		totalDistance = 0,
		lastRecordedPos = self.Position,
		minRecordDistance = mathMax(spacing * 0.5, 0.35),
		maxDistance = spacing * (maxSegments + 25)
	}
	path.points[1] = {position = self.Position, distance = 0}
	self.PathSystem = path
end

function AISnake:_recordPathPoint(position, force)
	local path = self.PathSystem
	if not path then return end

	local moved = (position - path.lastRecordedPos).Magnitude
	if not force and moved < path.minRecordDistance then
		local lastEntry = path.points[#path.points]
		if lastEntry then
			lastEntry.position = position
		end
		return
	end

	path.totalDistance = path.totalDistance + moved
	table.insert(path.points, {position = position, distance = path.totalDistance})
	path.lastRecordedPos = position

	local points = path.points
	local maxDistance = path.maxDistance
	while #points > 2 and (path.totalDistance - points[1].distance) > maxDistance do
		table.remove(points, 1)
	end
end

function AISnake:_samplePath(distanceBehind)
	local path = self.PathSystem
	if not path or #path.points == 0 then
		return self.Position, self.Direction
	end

	local targetDistance = path.totalDistance - mathMax(distanceBehind, 0)
	local points = path.points
	if targetDistance <= points[1].distance then
		local nextPoint = points[2] or points[1]
		local dir = nextPoint.position - points[1].position
		if dir.Magnitude < 0.001 then
			dir = self.Direction
		else
			dir = dir.Unit
		end
		return points[1].position, dir
	end

	local left, right = 1, #points
	while left < right do
		local mid = mathFloor((left + right) / 2)
		if points[mid].distance < targetDistance then
			left = mid + 1
		else
			right = mid
		end
	end

	local idx = math.max(2, left)
	local prev = points[idx - 1]
	local curr = points[idx]
	local span = curr.distance - prev.distance
	local alpha = span > 0 and (targetDistance - prev.distance) / span or 0
	local basePos = prev.position:Lerp(curr.position, alpha)
	local directionVec = curr.position - prev.position
	if directionVec.Magnitude < 0.001 then
		directionVec = self.Direction
	else
		directionVec = directionVec.Unit
	end

	local nextPoint = points[idx + 1]
	if nextPoint then
		local blend = curr.position:Lerp(nextPoint.position, alpha)
		basePos = basePos:Lerp(blend, 0.35)
	end

	return basePos, directionVec
end

function AISnake:_ensureMotionState()
	if self.MotionState then
		return self.MotionState
	end

	local initialDir = sanitizeVector(self.Direction, Vector3new(0, 0, 1)).Unit
	self.MotionState = {
		currentDirection = initialDir,
		smoothedSteer = initialDir,
		desiredDirection = initialDir,
		lastPosition = self.Position,
		stuckTime = 0,
	}
	return self.MotionState
end

function AISnake:_setSteerTarget(steer)
	local fallback = self.Direction or Vector3new(0, 0, 1)
	local sanitized = sanitizeVector(steer, fallback)
	if sanitized.Magnitude > 0 then
		sanitized = sanitized.Unit
	else
		sanitized = fallback
	end

	local motion = self:_ensureMotionState()
	motion.desiredDirection = sanitized
	self.SteerDirection = sanitized
end

function AISnake:_blendSteer(dt, baseSteer)
	local motion = self:_ensureMotionState()
	local fallback = self.Direction or Vector3new(0, 0, 1)
	local sanitized = sanitizeVector(baseSteer, fallback).Unit

	local now = tick()
	local allowHardTurn = motion.allowHardTurnUntil and motion.allowHardTurnUntil > now
	sanitized = limitTurnAngle(motion.currentDirection or fallback, sanitized, allowHardTurn)
	if motion.allowHardTurnUntil and motion.allowHardTurnUntil <= now then
		motion.allowHardTurnUntil = nil
	end

	if not motion.smoothedSteer then
		motion.smoothedSteer = sanitized
	else
		local baseSmooth = self.Config.PathSmoothness or 0.85
		local smoothing = mathClamp(
			baseSmooth + (self.SkillReactionLag or 0) * 0.5,
			0.6,
			0.97
		)
		motion.smoothedSteer = motion.smoothedSteer:Lerp(sanitized, smoothing)
	end

	motion.desiredDirection = sanitized
	return motion.smoothedSteer
end

function AISnake:_updateStuckTimer(dt, moveDelta)
	local motion = self:_ensureMotionState()
	local minDelta = mathMax(0.35, self.Speed * dt * 0.35)
	if moveDelta < minDelta then
		motion.stuckTime = (motion.stuckTime or 0) + dt
		if motion.stuckTime > 0.55 then
			self:forceCourseCorrection("stuck")
			motion.stuckTime = 0
		end
	else
		motion.stuckTime = mathMax(0, (motion.stuckTime or 0) - dt * 0.5)
	end
end

function AISnake:forceCourseCorrection(reason)
	if self._destroyed then return end

	local turnSign = mathRandom(0, 1) == 0 and -1 or 1
	local turnDegrees = randomFloat(25, 45) * turnSign
	local turnRadians = mathRad(turnDegrees)
	local motion = self:_ensureMotionState()
	local currentDir = motion.currentDirection or self.Direction
	local cosAngle = mathCos(turnRadians)
	local sinAngle = mathSin(turnRadians)
	local rotatedDir = Vector3new(
		currentDir.X * cosAngle - currentDir.Z * sinAngle,
		0,
		currentDir.X * sinAngle + currentDir.Z * cosAngle
	).Unit
	self.Direction = rotatedDir
	self.TargetYaw = mathAtan2(rotatedDir.X, rotatedDir.Z)
	self.CurrentYaw = self.TargetYaw
	self.TargetOrb = nil
	self.TargetSnake = nil
	self.Avoiding = false
	motion.currentDirection = self.Direction
	motion.smoothedSteer = self.Direction
	motion.desiredDirection = self.Direction
	motion.allowHardTurnUntil = tick() + 0.25

	if self.ProgressWatch then
		self.ProgressWatch.stagnation = 0
		self.ProgressWatch.lastPos = self.Position
		self.ProgressWatch.oscillationTimer = 0
		self.ProgressWatch.oscillationAnchor = self.Position
	end

	if not self.Boosting then
		self:startBoost(randomFloat(0.5, 1))
	end

	if self.SkillMistakeChance and mathRandom() < self.SkillMistakeChance * 0.25 then
		self.SkillMistakeChance = math.max(self.SkillMistakeChance - 0.02, 0.05)
	end
end

function AISnake:applySafetySteer(steerVector)
	if not steerVector or steerVector.Magnitude < 0.01 then
		return self.Direction
	end

	local safeProbe = self.Position + steerVector.Unit * 28
	if self:isPathSafe(safeProbe, 28) then
		return steerVector
	end

	local left = perpendicular(steerVector).Unit
	if self:isPathSafe(self.Position + left * 24, 24) then
		return left
	end

	local right = perpendicular(-steerVector).Unit
	if self:isPathSafe(self.Position + right * 24, 24) then
		return right
	end

	return steerVector
end

function AISnake:monitorProgress(dt)
	if not self.ProgressWatch then
		return
	end

	local watch = self.ProgressWatch
	local delta = (self.Position - watch.lastPos).Magnitude
	if delta < (self.Config.SegmentSpacing or 2) * 0.5 then
		watch.stagnation = watch.stagnation + dt
	else
		watch.stagnation = 0
		watch.lastPos = self.Position
	end

	watch.oscillationTimer = watch.oscillationTimer + dt
	if watch.oscillationTimer >= 3.0 then
		local drift = (self.Position - watch.oscillationAnchor).Magnitude
		if drift < 45 then
			self:forceCourseCorrection("oscillation")
		end
		watch.oscillationAnchor = self.Position
		watch.oscillationTimer = 0
	end

	if watch.stagnation > 2.4 then
		self:forceCourseCorrection("stagnation")
	end
end
function AISnake:_determineAction()
	local headPos = self.HeadParts.head.Position
	local p = self.Personality
	local now = tick()
	local state = "WANDER"
	local steer = self.Direction

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

	local boundaryBuffer = 80
	local strongBuffer = 40
	local edgeSteer = nil

	if headPos.X > MAP_BOUNDS.maxX - boundaryBuffer then
		local strength = 1 - (MAP_BOUNDS.maxX - headPos.X) / boundaryBuffer
		edgeSteer = Vector3new(-1, 0, 0) * strength
	elseif headPos.X < MAP_BOUNDS.minX + boundaryBuffer then
		local strength = 1 - (headPos.X - MAP_BOUNDS.minX) / boundaryBuffer
		edgeSteer = Vector3new(1, 0, 0) * strength
	end

	if headPos.Z > MAP_BOUNDS.maxZ - boundaryBuffer then
		local strength = 1 - (MAP_BOUNDS.maxZ - headPos.Z) / boundaryBuffer
		local zSteer = Vector3new(0, 0, -1) * strength
		edgeSteer = edgeSteer and (edgeSteer + zSteer).Unit or zSteer
	elseif headPos.Z < MAP_BOUNDS.minZ + boundaryBuffer then
		local strength = 1 - (headPos.Z - MAP_BOUNDS.minZ) / boundaryBuffer
		local zSteer = Vector3new(0, 0, 1) * strength
		edgeSteer = edgeSteer and (edgeSteer + zSteer).Unit or zSteer
	end

	if edgeSteer and (
		headPos.X > MAP_BOUNDS.maxX - strongBuffer or
			headPos.X < MAP_BOUNDS.minX + strongBuffer or
			headPos.Z > MAP_BOUNDS.maxZ - strongBuffer or
			headPos.Z < MAP_BOUNDS.minZ + strongBuffer
		) then
		local randomAngle = mathRandom(-30, 30) * mathPi / 180
		local cosA = mathCos(randomAngle)
		local sinA = mathSin(randomAngle)
		local rotatedSteer = Vector3new(
			edgeSteer.X * cosA - edgeSteer.Z * sinA,
			0,
			edgeSteer.X * sinA + edgeSteer.Z * cosA
		)

		self.TargetSnake = nil
		self.TargetOrb = nil
		return "AVOID_BOUNDARY", rotatedSteer.Unit
	end

	local wallVec, wallStrength = getWallAvoidanceVector(headPos)
	if wallVec and wallStrength > 0.3 then
		self.TargetSnake = nil
		return "AVOID_WALL", wallVec.Unit
	end

	local lookAheadDist = self.Speed * 1.5 * (self.SkillDodgeBias or 1)
	local futurePos = headPos + self.Direction * lookAheadDist

	local nearbyDanger = SpatialGrid.QueryRadius(futurePos, 15)
	local collisionThreat = nil
	local minCollisionTime = math.huge

	for _, entity in ipairs(nearbyDanger) do
		if entity.owner ~= self and (entity.type:match("HEAD") or entity.type:match("SEGMENT")) then
			local theirPos = entity.part.Position
			local relPos = theirPos - headPos
			local relVel = self.Direction * self.Speed

			if entity.part.AssemblyLinearVelocity then
				relVel = relVel - entity.part.AssemblyLinearVelocity
			end

			local relVelDot = relVel:Dot(relVel)
			if relVelDot > 0 then
				local timeToCollision = relPos:Dot(relVel) / relVelDot

				if timeToCollision > 0 and timeToCollision < 2 then
					local collisionPos = headPos + self.Direction * self.Speed * timeToCollision
					local theirFuturePos = theirPos

					if entity.part.AssemblyLinearVelocity then
						theirFuturePos = theirPos + entity.part.AssemblyLinearVelocity * timeToCollision
					end

					local collisionDist = (collisionPos - theirFuturePos).Magnitude

					if collisionDist < 8 and timeToCollision < minCollisionTime then
						minCollisionTime = timeToCollision
						collisionThreat = entity
					end
				end
			end
		end
	end

	if collisionThreat and minCollisionTime < 1 then
		if self.SkillMistakeChance and mathRandom() < self.SkillMistakeChance * 0.5 then
			collisionThreat = nil
		end
	end

	if collisionThreat and minCollisionTime < 1 then
		local threatPos = collisionThreat.part.Position
		local avoidDir = (headPos - threatPos).Unit
		local perpDir = Vector3new(-avoidDir.Z, 0, avoidDir.X)

		local leftClear = self:isPathSafe(headPos + perpDir * 20, 20)
		local rightClear = self:isPathSafe(headPos - perpDir * 20, 20)

		if leftClear and not rightClear then
			steer = perpDir
		elseif rightClear and not leftClear then
			steer = -perpDir
		else
			steer = avoidDir
		end

		self.TargetOrb = nil
		return "COLLISION_AVOID", steer
	end

	local threats = self:findNearbyThreats()
	local shouldFlee = false
	local fleeReason = ""

	if #threats > 0 then
		local closestThreat = threats[1]

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

		if shouldFlee and (p.Type == "Aggressor" or p.Type == "Hunter") then
			if closestThreat.lengthDiff < 10 and closestThreat.distance > 20 then
				shouldFlee = false
			end
		end
	end

	if shouldFlee and self.SkillMistakeChance and mathRandom() < self.SkillMistakeChance * 0.35 then
		shouldFlee = false
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

	if p.TargetOrbs and not shouldFlee then
		local orb, dist = self:findBestOrb()

		if orb then
			-- Switch if we found a valid orb (it's already the best score)
			-- We rely on findBestOrb to handle the scoring
			if orb ~= self.TargetOrb then
				self.TargetOrb = orb
				self.TargetOrbExpire = now + mathRandom(30, 60) / 10
				AISnake._orbTargets[self] = orb
			end
		end

		if self.TargetOrb and self.TargetOrb.Parent then
			state = "SEEK_ORB"
			local toOrb = Vector3new(self.TargetOrb.Position.X, headPos.Y, self.TargetOrb.Position.Z) - headPos
			local orbDist = toOrb.Magnitude

			if orbDist < 50 then
				steer = toOrb.Unit
				if orbDist < 20 and not self.Boosting and mathRandom() < 0.3 then
					self:startBoost(0.5)
				end
			else
				steer = toOrb.Unit
			end

			self.TargetSnake = nil
			return state, steer
		end
	end

	if state == "WANDER" then
		if not self._lastStraightDistance then
			self._lastStraightDistance = 0
			self._lastTurnPosition = headPos
		end

		local distanceSinceTurn = (headPos - self._lastTurnPosition).Magnitude

		local minStraight = p.MinStraightDistance or 100
		local movementPattern = p.MovementPattern or "wander"

		if movementPattern == "spiral" then
			if not self._spiralAngle then self._spiralAngle = 0 end
			if not self._spiralRadius then self._spiralRadius = 50 end

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
			if not self._zigzagDirection then self._zigzagDirection = 1 end

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
			local gridSize = p.GridSize or 100
			if not self._gridDirection then self._gridDirection = 0 end

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
			if not p.PatrolAngle then p.PatrolAngle = 0 end
			p.PatrolAngle = p.PatrolAngle + 0.02
			local radius = p.TerritoryRadius or 150
			local center = p.TerritoryCenter
			local targetX = center.X + mathCos(p.PatrolAngle) * radius
			local targetZ = center.Z + mathSin(p.PatrolAngle) * radius
			local targetPos = Vector3new(targetX, headPos.Y, targetZ)
			steer = (targetPos - headPos).Unit

		else
			-- FORCE turn if wandering too long in same direction regardless of personality
			if distanceSinceTurn > 600 then
				-- Force a 90 degree turn if we've gone 600 studs straight
				local forceTurn = mathRandom(0, 1) == 0 and mathPi/2 or -mathPi/2
				self.TargetYaw = self.TargetYaw + forceTurn
				self.LastTurn = now
				self._lastTurnPosition = headPos
				steer = Vector3new(mathSin(self.TargetYaw), 0, mathCos(self.TargetYaw))
			elseif (now - (self.LastTurn or 0) > p.RandomTurnInterval) and distanceSinceTurn > minStraight then
				local maxTurn = 30
				local turnAmount = mathRandom(-maxTurn, maxTurn)

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

		local edgeBuffer = 100
		if headPos.X > MAP_BOUNDS.maxX - edgeBuffer then
			steer = steer + Vector3new(-1, 0, 0)
			steer = steer.Unit
		elseif headPos.X < MAP_BOUNDS.minX + edgeBuffer then
			steer = steer + Vector3new(1, 0, 0)
			steer = steer.Unit
		end
		if headPos.Z > MAP_BOUNDS.maxZ - edgeBuffer then
			steer = steer + Vector3new(0, 0, -1)
			steer = steer.Unit
		elseif headPos.Z < MAP_BOUNDS.minZ + edgeBuffer then
			steer = steer + Vector3new(0, 0, 1)
			steer = steer.Unit
		end
	end

	return state, steer
end

function AISnake:updateBrain()
	if not self._active or not self.HeadParts or not self.HeadParts.head or not self.HeadParts.head.Parent then
		return
	end

	self._lastBrainUpdate = tick()

	local state, steer = self:_determineAction()
	self.State = state
	self:_setSteerTarget(steer)
end
function AISnake.new(startPosition, preservedPersonalityType)
	if #AISnake._activeSnakes >= MAX_AI_SNAKES then
		warn("AI Snake limit reached", MAX_AI_SNAKES)
		return nil
	end

	local self = setmetatable({}, AISnake)

	local colorData = getRandomAIColor()

	self.Config = deepCopy(SnakeConfig)
	self.Config.HeadColor = colorData.HeadColor
	self.Config.BodyColors = colorData.BodyColors
	self.Config.HeadMaterial = colorData.HeadMaterial
	self.Config.BodyMaterial = colorData.BodyMaterial

	updateMapBounds()

	self.Position = startPosition or Vector3new(0, AI_HEIGHT, 0)
	self.Direction = Vector3new(0, 0, 1)

	local aiConfig = self.Config.AI or {}
	self.Speed = aiConfig.BaseSpeed or self.Config.BaseSpeed or 18 -- Increased base speed
	self.NormalSpeed = aiConfig.BaseSpeed or self.Config.BaseSpeed or 18
	self.BoostSpeed = aiConfig.BoostSpeed or self.Config.BoostSpeed or 40 -- Increased boost speed
	self.TurnSpeed = aiConfig.TurnSpeed or self.Config.TurnSpeed or 4.5 -- Matches user preference (was 1.8)
	self._targetSpeed = self.Speed
	self._smoothSpeed = self.Speed

	self.RandomTurnInterval = 1.5
	self.LastTurn = tick()
	self.TargetYaw = 0
	self.CurrentYaw = 0
	self.LastDirection = self.Direction
	self.DirectionChangeTime = 0

	self.FollowSpeed = self.Config.FollowSpeed or 0.95
	self.BoostFollowSpeed = self.Config.BoostFollowSpeed or 0.98
	self.SegmentSpacing = self.Config.SegmentSpacing or 1.8 -- Reduced from 2.2 for better compression
	self.VisualSpacingFactor = mathClamp(self.Config.VisualSpacingFactor or 0.4, 0.15, 1)
	self.PathSpacing = mathMax(self.SegmentSpacing * self.VisualSpacingFactor, 0.2)
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

	self.MotionState = {
		currentDirection = self.Direction,
		smoothedSteer = self.Direction,
		desiredDirection = self.Direction,
		lastPosition = self.Position,
		stuckTime = 0,
	}

	local pType
	if preservedPersonalityType and AISnake.PersonalityDefinitions[preservedPersonalityType] then
		pType = preservedPersonalityType
		warn("Restoring personality", pType)
	else
		pType = AISnake.PersonalityTypes[mathRandom(1, #AISnake.PersonalityTypes)]
	end
	self.Personality = deepCopy(AISnake.PersonalityDefinitions[pType])
	self._personalityType = pType

	if self.Personality.Type == "Guardian" then
		local territoryAngle = mathRandom() * 2 * mathPi
		local territoryRadius = mathRandom(100, 200)
		self.Personality.TerritoryCenter = Vector3new(
			mathCos(territoryAngle) * territoryRadius,
			0,
			mathSin(territoryAngle) * territoryRadius
		)
	end

	self.SkillProfile = buildSkillProfile()
	self.SkillTier = self.SkillProfile.label
	self.SkillMistakeChance = self.SkillProfile.errorChance
	self.SkillTurnMultiplier = self.SkillProfile.turnMultiplier
	self.SkillDodgeBias = self.SkillProfile.dodgeBias
	if self.SkillProfile.label == "Elite" or self.SkillProfile.label == "Veteran" then
		self.SkillReactionLag = 0.01 -- Almost instant reaction
		self.TurnSpeed = self.TurnSpeed * 1.5 -- Faster turning
	end

	self.Personality.SpeedMultiplier = (self.Personality.SpeedMultiplier or 1) * self.SkillProfile.speedMultiplier
	self.Personality.BoostChance = math.max(0.01, (self.Personality.BoostChance or 0.05) * self.SkillProfile.boostMultiplier)
	self.TurnSpeed = self.TurnSpeed * self.SkillTurnMultiplier * 0.8
	self.RandomTurnInterval = self.RandomTurnInterval * (1 + self.SkillReactionLag)

	self.DisplayName = pickAIName()

	self.Model = getOrCreateSnakeModel(tostring(self) .. "_" .. mathRandom(100000,999999))
	for _, obj in ipairs(self.Model:GetChildren()) do
		obj:Destroy()
	end

	self.Model.Parent = SnakesFolder
	self.Model:SetAttribute("AIName", self.DisplayName)
	self.Model:SetAttribute("Length", 0)
	self.Model:SetAttribute("IsAI", true)
	self.Model:SetAttribute("SkillTier", self.SkillTier)

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

	self.CurrentLength = self.Config.InitialLength or 10

	self.growthFactor = self:calculateGrowthFactor()

	self:_initPathSystem()

	-- Removed AttachmentPart to fix rendering issues
	-- Attachments and Beams are now parented directly to Head and Segments

	self.Attachments = {}
	self.Beams = {}

	local headAttachment = Instance.new("Attachment")
	headAttachment.Name = "Attachment0"
	headAttachment.Parent = self.HeadParts.head
	headAttachment.Position = Vector3.new(0, 0, 0)
	self.Attachments[0] = headAttachment

	self.Segments[0] = self.HeadParts.head

	local currentBaseSize = BASE_SIZE * self.growthFactor

	local headSize = self:getSegmentSize(0, currentBaseSize)
	self.HeadParts.head.Size = Vector3.new(headSize, headSize, headSize)

	local initialSegmentCount = math.min(self.CurrentLength, DYNAMIC_SEGMENT_LIMIT)

	for i = 1, initialSegmentCount do
		local pos = self.Position
		local color = self:getSegmentColor(i)
		local segment = createSegment(i, pos, color, self.Config, self.Model, i)
		self.Segments[i] = segment

		local segmentSize = self:getSegmentSize(i, currentBaseSize)
		segment.Size = Vector3.new(segmentSize, segmentSize, segmentSize)
		segment.Transparency = 1
		segment.CFrame = CFramenew(pos)

		local attachment = Instance.new("Attachment")
		attachment.Name = "Attachment" .. i
		attachment.Parent = segment
		attachment.Position = Vector3.new(0, 0, 0)
		self.Attachments[i] = attachment
	end

	for i = 0, initialSegmentCount - 1 do
		local beam = Instance.new("Beam")
		beam.Name = "Beam" .. i
		
		-- Fix: Attachments table is not fully populated if initialSegmentCount > 1
		-- We must ensure Attachments[i+1] exists for the beam to connect
		if not self.Attachments[i+1] then
			-- This should have been created in the loop above, but just in case:
			warn("Missing attachment for beam", i, "creating fallback")
			local nextSeg = self.Segments[i+1]
			if nextSeg then
				local att = Instance.new("Attachment")
				att.Name = "Attachment" .. (i+1)
				att.Parent = nextSeg
				att.Position = Vector3.new(0,0,0)
				self.Attachments[i+1] = att
			end
		end

		if self.Attachments[i] and self.Attachments[i+1] then
			beam.Attachment0 = self.Attachments[i]
			beam.Attachment1 = self.Attachments[i+1]

			local beamWidth = self:getBeamWidth(i, currentBaseSize)
			beam.Width0 = beamWidth
			beam.Width1 = beamWidth
			beam.CurveSize0 = 0
			beam.CurveSize1 = 0
			beam.FaceCamera = true
			beam.Segments = BEAM_SEGMENTS
			beam.Texture = BEAM_TEXTURES.gradient
			beam.TextureMode = Enum.TextureMode.Wrap
			beam.TextureLength = 2
			beam.TextureSpeed = BEAM_TEXTURE_SPEED
			beam.LightEmission = 1
			beam.LightInfluence = 0
			beam.Brightness = 2
			beam.Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0.5),
				NumberSequenceKeypoint.new(0.5, 0.3),
				NumberSequenceKeypoint.new(1, 0.5)
			}

			if i == 0 then
				local headColor = self:getSegmentColor(0)
				local seg1Color = self:getSegmentColor(1)
				beam.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, headColor),
					ColorSequenceKeypoint.new(0.3, headColor:Lerp(seg1Color, 0.3)),
					ColorSequenceKeypoint.new(0.7, headColor:Lerp(seg1Color, 0.7)),
					ColorSequenceKeypoint.new(1, seg1Color)
				})
			else
				beam.Color = ColorSequence.new(self:getSegmentColor(i))
			end

			-- Parent beam to the start segment of the pair (Head for 0, Segment i for others)
			if i == 0 then
				beam.Parent = self.HeadParts.head
			else
				beam.Parent = self.Segments[i]
			end
			self.Beams[i] = beam
		end
	end

	self.actualSegmentCount = initialSegmentCount

	self.Model:SetAttribute("CurrentLength", self.CurrentLength)
	self.Model:SetAttribute("HeadPosition", self.Position)
	self.Model:SetAttribute("Length", self.CurrentLength)

	-- Initialize position immediately to prevent 0,0,0 jump
	if self.RootPart then self.RootPart.Position = self.Position end
	if self.HeadParts and self.HeadParts.head then
		local headOffset = self.Direction * 1.5
		local headPos = self.Position + headOffset
		self.HeadParts.head.CFrame = CFrame.lookAt(headPos, headPos + self.Direction)
	end
	
	-- Force update attachments immediately
	if self.Attachments then
		for _, att in pairs(self.Attachments) do
			att.Position = Vector3.new(0,0,0)
		end
	end

	task.defer(function()
		task.wait(0.1)
		
		-- CRITICAL FIX: Force update attachments before movement starts
		if self.Segments then
			local currentBaseSize = BASE_SIZE * self.growthFactor
			for i = 0, initialSegmentCount - 1 do
				if self.Beams[i] and self.Attachments[i] and self.Attachments[i+1] then
					self.Beams[i].Attachment0 = self.Attachments[i]
					self.Beams[i].Attachment1 = self.Attachments[i+1]
				end
			end
		end

		for step = 1, 20 do
			local moveDistance = self.SegmentSpacing * 0.1
			local newPos = self.Position + self.Direction * moveDistance
			self.Position = newPos
			if self.RootPart and self.RootPart.Parent then
				self.RootPart.Position = newPos
			end

			-- Force update attachments during spawn movement
			if self.Attachments then
				if self.Attachments[0] then 
					self.Attachments[0].Position = Vector3.new(0,0,0) 
				end
				for k, att in pairs(self.Attachments) do
					if k > 0 then att.Position = Vector3.new(0,0,0) end
				end
			end

			if self.HeadParts and self.HeadParts.head then
				local headOffset = self.Direction * 1.5
				self.HeadParts.head.CFrame = CFramelookAt(self.Position + headOffset, self.Position + headOffset + self.Direction)
			end

			self:_recordPathPoint(self.Position, true)
			task.wait(0.02)
		end

		self._spawnStabilizing = nil
		self.State = "WANDER"
		self.TargetOrb = nil
		self.TargetSnake = nil
		self.Avoiding = false
		self.AvoidExpire = 0

		local randomTurn = mathRandom() * mathPi * 2
		self.TargetYaw = randomTurn
		self.CurrentYaw = randomTurn
		self.Direction = Vector3new(mathSin(randomTurn), 0, mathCos(randomTurn))

		self.LastTurn = tick()
		self.BoostCooldown = tick() + 2

		self._lastBrainUpdate = tick()
		self:updateBrain()

		if typeof(self.Segments) == "table" then
			for _, segment in pairs(self.Segments) do
				if segment and segment.Parent then
					task.spawn(function()
						local fadeSteps = 10
						for step = 1, fadeSteps do
							if segment and segment.Parent then
								segment.Transparency = 1 - (step / fadeSteps)
							end
							task.wait(0.02)
						end
						if segment and segment.Parent then
							segment.Transparency = 0
						end
					end)
				end
			end
		end
	end)

	table.insert(AISnake._activeSnakes, self)
	self._active = true

	self._lastPositions = {}
	self._stuckCheckTime = 0
	self._lastStuckCheck = tick()

	local spawnDuration = 5 -- Increased to 5 seconds
	self._spawnProtection = tick() + spawnDuration
	self._spawnStabilizing = tick() + 0.5

	-- Set attribute for collision handler (using os.clock() for consistency)
	if self.HeadParts and self.HeadParts.head then
		self.HeadParts.head:SetAttribute("SpawnProtectionExpiry", os.clock() + spawnDuration)
		
		-- Visual feedback for spawn protection (Ghost Mode)
		task.spawn(function()
			local head = self.HeadParts.head
			if not head then return end
			
			-- Make semi-transparent
			head.Transparency = 0.5
			
			-- Wait for protection to expire
			task.wait(spawnDuration)
			
			if self._active and not self._destroyed and head and head.Parent then
				head.Transparency = 0
				-- Ensure segments are also reset if we add segment transparency later
				if self.Segments then
					for _, seg in pairs(self.Segments) do
						if seg and seg.Parent then seg.Transparency = 0 end
					end
				end
			end
		end)
	end

	self.ProgressWatch = {
		lastPos = self.Position,
		stagnation = 0,
		oscillationAnchor = self.Position,
		oscillationTimer = 0
	}

	return self
end
function AISnake:grow(amount)
	amount = amount or 5

	for i = 1, amount do
		if self.CurrentLength < self.Config.MaxSegments then
			self.CurrentLength = self.CurrentLength + 1

			if self.CurrentLength <= DYNAMIC_SEGMENT_LIMIT then
				self.growthFactor = self:calculateGrowthFactor()
				local currentBaseSize = BASE_SIZE * self.growthFactor

				local color = self:getSegmentColor(self.CurrentLength)
				local spawnDistance = self.CurrentLength * (self.PathSpacing or self.SegmentSpacing)
				local samplePos, sampleDir = self:_samplePath(spawnDistance)
				local lastSegment = self.Segments[self.CurrentLength - 1]
				local newPos = samplePos or (lastSegment and lastSegment.Position) or self.Position
				local segment = createSegment(self.CurrentLength, newPos, color, self.Config, self.Model, self.CurrentLength)
				self.Segments[self.CurrentLength] = segment

				segment.Material = self.Config.BodyMaterial or Enum.Material.Neon
				segment.Color = color

				segment.Transparency = 1
				segment.Size = Vector3new(0.1, 0.1, 0.1)
				if sampleDir then
					segment.CFrame = CFramenew(newPos, newPos + sampleDir)
				end

				if self.Attachments then
					local attachment = Instance.new("Attachment")
					attachment.Name = "Attachment" .. self.CurrentLength
					attachment.Parent = segment
					attachment.Position = Vector3.new(0, 0, 0)
					self.Attachments[self.CurrentLength] = attachment

					if self.CurrentLength > 1 and self.Beams then
						local prevIndex = self.CurrentLength - 1
						local prevAttachment = self.Attachments[prevIndex]
						local prevSegment = self.Segments[prevIndex]

						if not prevAttachment and prevSegment then
							prevAttachment = Instance.new("Attachment")
							prevAttachment.Name = "Attachment" .. prevIndex
							prevAttachment.Parent = prevSegment
							prevAttachment.Position = Vector3.new(0, 0, 0)
							self.Attachments[prevIndex] = prevAttachment
						end

						if prevAttachment then
						local beam = Instance.new("Beam")
						beam.Name = "Beam" .. prevIndex
						beam.Attachment0 = prevAttachment
						beam.Attachment1 = attachment

						local beamWidth = self:getBeamWidth(prevIndex, currentBaseSize)
						beam.Width0 = beamWidth
						beam.Width1 = beamWidth
						beam.CurveSize0 = 0
						beam.CurveSize1 = 0
						beam.FaceCamera = true
						beam.Segments = BEAM_SEGMENTS
						beam.Texture = BEAM_TEXTURES.gradient
						beam.TextureMode = Enum.TextureMode.Wrap
						beam.TextureLength = 2
						beam.TextureSpeed = BEAM_TEXTURE_SPEED
						beam.LightEmission = 1
						beam.LightInfluence = 0
						beam.Brightness = 2
						beam.Transparency = NumberSequence.new{
							NumberSequenceKeypoint.new(0, 0.5),
							NumberSequenceKeypoint.new(0.5, 0.3),
							NumberSequenceKeypoint.new(1, 0.5)
						}

						local prevColor = self:getSegmentColor(prevIndex)
						local currColor = self:getSegmentColor(self.CurrentLength)

							if not prevColor or not currColor then
								beam.Color = ColorSequence.new(Color3.fromRGB(255, 255, 51))
							elseif prevColor == currColor then
								beam.Color = ColorSequence.new(currColor)
							else
								beam.Color = ColorSequence.new({
									ColorSequenceKeypoint.new(0, prevColor),
									ColorSequenceKeypoint.new(1, currColor)
								})
							end

							beam.Parent = prevSegment -- Parent to previous segment
							self.Beams[prevIndex] = beam
						end
					end
				end

				local finalSize = self:getSegmentSize(self.CurrentLength, currentBaseSize)

				task.spawn(function()
					if not segment or not segment.Parent then return end
					local growTime = 0.18
					local t = 0
					local startSize = Vector3new(0.1, 0.1, 0.1)
					while t < growTime do
						t = t + RunService.Heartbeat:Wait()
						if not segment or not segment.Parent then return end
						local alpha = mathMin(t / growTime, 1)
						segment.Size = startSize:Lerp(Vector3new(finalSize, finalSize, finalSize), alpha)
						segment.Transparency = 1 - alpha
					end
					if segment and segment.Parent then
						segment.Size = Vector3new(finalSize, finalSize, finalSize)
						segment.Transparency = 0
					end
				end)

				self.actualSegmentCount = self.CurrentLength
			end
		end
	end

	if amount > 0 then
		self.growthFactor = self:calculateGrowthFactor()
		local currentBaseSize = BASE_SIZE * self.growthFactor

		task.spawn(function()
			for i = 0, math.min(self.CurrentLength, FORCE_RENDER_SEGMENTS) do
				local segment = self.Segments[i]
				if segment and segment.Parent then
					local targetSize = self:getSegmentSize(i, currentBaseSize)
					local tween = TweenService:Create(
						segment,
						TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{Size = Vector3.new(targetSize, targetSize, targetSize)}
					)
					tween:Play()
				end
			end

			task.wait(0.1)
			for i = 0, math.min(self.CurrentLength - 1, FORCE_RENDER_SEGMENTS) do
				local beam = self.Beams[i]
				if beam and beam.Parent then
					local beamWidth = self:getBeamWidth(i, currentBaseSize)
					local beamTween = TweenService:Create(
						beam,
						TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{Width0 = beamWidth, Width1 = beamWidth}
					)
					beamTween:Play()
				end
			end
		end)
	end

	self.Model:SetAttribute("Length", self.CurrentLength)
end

function AISnake:setConfidenceBuff()
	if not self._active then return end
	self.isConfident = true
	self.confidenceEndTime = tick() + 8
	self.killCount = self.killCount + 1
	self.lastKillTime = tick()

	if self.HeadParts and self.HeadParts.headOutline then
		self.HeadParts.headOutline.Color3 = Color3.fromRGB(255, 255, 0)
		self.HeadParts.headOutline.LineThickness = 0.3
		self.HeadParts.headOutline.Transparency = 0.3
	end
end

function AISnake:Destroy()
	if not self._active then return end
	self._active = false
	self._destroyed = true
	releaseAIName(self.DisplayName)

	if AISnakeOrbPickup then
		pcall(function()
			AISnakeOrbPickup.UntrackSnake(self)
		end)
	end

	for i = #AISnake._activeSnakes, 1, -1 do
		if AISnake._activeSnakes[i] == self then
			table.remove(AISnake._activeSnakes, i)
			break
		end
	end
	AISnake._orbTargets[self] = nil

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

	task.spawn(function()
		if not OrbUtils then
			pcall(function() OrbUtils = require(ReplicatedStorage:WaitForChild("OrbUtils")) end)
		end
		
		if OrbUtils and OrbUtils.spawnOrb then
			for i = 1, #orbSpawnData do
				local data = orbSpawnData[i]
				pcall(function()
					OrbUtils.spawnOrb(data.position, data.size, data.color)
				end)
			end
		end
	end)

	for i = 1, #self.Segments do
		local segment = self.Segments[i]
		if segment then
			pcall(function()
				returnSegment(segment)
			end)
		end
	end
	self.Segments = {}

	-- Beams and Attachments are children of Segments/Head, so they are destroyed automatically
	self.Beams = {}
	self.Attachments = {}
	self.AttachmentPart = nil -- Should be nil already but ensuring safety

	if self.HeadParts then
		for _, part in pairs(self.HeadParts) do
			if typeof(part) == "Instance" and part.Parent then
				pcall(function()
					part:Destroy()
				end)
			end
		end
	end

	if self.Model and self.Model.Parent then
		pcall(function()
			for _, descendant in ipairs(self.Model:GetDescendants()) do
				if descendant:IsA("BasePart") then
					descendant:Destroy()
				end
			end
			self.Model:Destroy()
		end)
	end

	self.Model = nil
	self.HeadParts = nil
	self.RootPart = nil
	self.Segments = nil
end
function AISnake:updateMovement(dt)
	if self._destroyed then return end
	dt = sanitizeNumber(dt, 0.033)
	if dt <= 0 then
		dt = 0.016
	end

	if not self._active or not self.HeadParts or not self.HeadParts.head or not self.HeadParts.head.Parent then
		if self._active and not self._destroyed then
			self:Destroy()
		end
		return
	end

	local now = tick()

	if self._spawnStabilizing and now < self._spawnStabilizing then
		return
	end
	local p = self.Personality

	if not p then
		warn("AI Snake lost personality, reassigning")
		local pType = AISnake.PersonalityTypes[mathRandom(1, #AISnake.PersonalityTypes)]
		self.Personality = deepCopy(AISnake.PersonalityDefinitions[pType])
		p = self.Personality
	end

	local state = self.State
	local motion = self:_ensureMotionState()
	local steer = self.SteerDirection

	if not steer or steer.Magnitude < 0.1 then
		steer = self.Direction
	end

	steer = self:applySafetySteer(steer)
	-- steer = self:_blendSteer(dt, steer) -- Removing old blending

	local baseTurnSpeed = sanitizeNumber(self.TurnSpeed, 4.5)
	if state == "SEEK_ORB" and self.TargetOrb then
		local dist = (self.TargetOrb.Position - self.Position).Magnitude
		if dist < 20 then
			baseTurnSpeed = baseTurnSpeed * 1.25
		end
	elseif state == "AVOID_WALL" then
		baseTurnSpeed = baseTurnSpeed * 1.15
	elseif state == "AVOID_BOUNDARY" then
		baseTurnSpeed = baseTurnSpeed * 1.2
	elseif state == "COLLISION_AVOID" then
		baseTurnSpeed = baseTurnSpeed * 2.0 -- Much faster response to collision threats
	end

	if self.Boosting then
		baseTurnSpeed = baseTurnSpeed * 0.85
	end

	-- BUTTERY SMOOTH TURNING LOGIC (from user script)
	local turnRate = baseTurnSpeed * dt * 0.9
	if state == "COLLISION_AVOID" then
		turnRate = turnRate * 1.5 -- Sharper turn when avoiding collision
	end

	local currentDir = motion.currentDirection or self.Direction
	local desiredDir = sanitizeVector(steer, self.Direction).Unit
	
	-- Force Y=0 for planar movement
	currentDir = Vector3new(currentDir.X, 0, currentDir.Z).Unit
	desiredDir = Vector3new(desiredDir.X, 0, desiredDir.Z).Unit
	
	local allowHardTurn = motion.allowHardTurnUntil and motion.allowHardTurnUntil > now
	desiredDir = limitTurnAngle(currentDir, desiredDir, allowHardTurn)

	-- Lerp logic
	local newDirection = currentDir:Lerp(desiredDir, turnRate)
	if newDirection.Magnitude > 0.001 then
		motion.currentDirection = Vector3new(newDirection.X, 0, newDirection.Z).Unit
	else
		motion.currentDirection = Vector3new(self.Direction.X, 0, self.Direction.Z).Unit
	end
	
	self.Direction = motion.currentDirection

	if self._lastBrainUpdate then
		local timeSinceLastBrain = now - self._lastBrainUpdate
		if timeSinceLastBrain > 2.0 then
			warn("AI Snake brain frozen for", timeSinceLastBrain, "forcing update")
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
				warn("Re-added frozen snake to active list")
			end
		end
	else
		self:updateBrain()
		self._lastBrainUpdate = now
	end

	local isSpawnProtected = now < (self._spawnProtection or 0)

	if not isSpawnProtected then
		if self.Position.X < MAP_BOUNDS.minX - 10 or self.Position.X > MAP_BOUNDS.maxX + 10 or
			self.Position.Z < MAP_BOUNDS.minZ - 10 or self.Position.Z > MAP_BOUNDS.maxZ + 10 then
			local safeX = mathClamp(self.Position.X, MAP_BOUNDS.minX + 50, MAP_BOUNDS.maxX - 50)
			local safeZ = mathClamp(self.Position.Z, MAP_BOUNDS.minZ + 50, MAP_BOUNDS.maxZ - 50)
			self.Position = Vector3new(safeX, self.Position.Y, safeZ)
			self.Direction = Vector3new(mathRandom() - 0.5, 0, mathRandom() - 0.5).Unit
			motion.currentDirection = self.Direction
			self.State = "WANDER"
			return
		end
	end

	self.CurrentYaw = mathAtan2(self.Direction.X, self.Direction.Z)
	self.TargetYaw = self.CurrentYaw

	if not isSpawnProtected then
		local lookAheadTime = 1.0
		local futurePos = self.Position + self.Direction * self.Speed * lookAheadTime

		local boundaryForce = Vector3new(0, 0, 0)
		local boundaryStrength = 0

		if futurePos.X > MAP_BOUNDS.maxX - 50 then
			local dist = MAP_BOUNDS.maxX - futurePos.X
			boundaryStrength = mathMax(boundaryStrength, 1 - (dist / 50))
			boundaryForce = boundaryForce + Vector3new(-1, 0, 0)
		elseif futurePos.X < MAP_BOUNDS.minX + 50 then
			local dist = futurePos.X - MAP_BOUNDS.minX
			boundaryStrength = mathMax(boundaryStrength, 1 - (dist / 50))
			boundaryForce = boundaryForce + Vector3new(1, 0, 0)
		end

		if futurePos.Z > MAP_BOUNDS.maxZ - 50 then
			local dist = MAP_BOUNDS.maxZ - futurePos.Z
			boundaryStrength = mathMax(boundaryStrength, 1 - (dist / 50))
			boundaryForce = boundaryForce + Vector3new(0, 0, -1)
		elseif futurePos.Z < MAP_BOUNDS.minZ + 50 then
			local dist = futurePos.Z - MAP_BOUNDS.minZ
			boundaryStrength = mathMax(boundaryStrength, 1 - (dist / 50))
			boundaryForce = boundaryForce + Vector3new(0, 0, 1)
		end

		if boundaryStrength > 0.1 then
			boundaryForce = boundaryForce.Unit
			local blend = mathClamp(boundaryStrength * 0.5, 0, 0.4)
			self.Direction = (self.Direction * (1 - blend) + boundaryForce * blend).Unit
			motion.currentDirection = self.Direction
			if boundaryStrength > 0.7 then
				self.State = "AVOID_BOUNDARY"
				self.TargetOrb = nil
				self.TargetSnake = nil
			end
		end
	end

	self.Direction = sanitizeVector(self.Direction, Vector3new(0, 0, 1))
	motion.currentDirection = self.Direction
	self.CurrentYaw = mathAtan2(self.Direction.X, self.Direction.Z)
	self.TargetYaw = self.CurrentYaw

	if self.Boosting and now > self.BoostEndTime then
		self.Boosting = false
		self.IsBoosting = false
	end

	if not self.Boosting and now > self.BoostCooldown then
		local shouldBoost = false
		local boostDuration = 1.2

		if state == "AVOID_WALL" then
			shouldBoost = true
			boostDuration = 0.8
		elseif state == "SEEK_ORB" then
			if mathRandom() < 0.02 then
				shouldBoost = true
				boostDuration = 0.5
			end
		elseif state == "FLEE" then
			if mathRandom() < 0.3 then
				shouldBoost = true
				boostDuration = 1.5
			end
		elseif state == "COLLISION_AVOID" then
			-- Always boost when avoiding collisions if we can
			shouldBoost = true
			boostDuration = 0.8
		else
			if mathRandom() < (p.BoostChance or 0) * 0.3 then
				shouldBoost = true
			end
		end

		if shouldBoost then
			self:startBoost(boostDuration)
		end
	end

	local speedMultiplier = p.SpeedMultiplier or 1
	local desiredSpeed = (self.Boosting and self.BoostSpeed or self.NormalSpeed) * speedMultiplier
	self._targetSpeed = desiredSpeed
	local accel = self.Boosting and 10 or 6
	local lerpAlpha = mathClamp(dt * accel, 0, 1)
	self._smoothSpeed = self._smoothSpeed + (desiredSpeed - self._smoothSpeed) * lerpAlpha
	self.Speed = self._smoothSpeed

	local moveDistance = self.Speed * dt
	local previousPosition = self.Position
	local newPosition = previousPosition + self.Direction * moveDistance

	if not isSpawnProtected then
		local margin = 20
		local clampedX = mathClamp(newPosition.X, MAP_BOUNDS.minX + margin, MAP_BOUNDS.maxX - margin)
		local clampedZ = mathClamp(newPosition.Z, MAP_BOUNDS.minZ + margin, MAP_BOUNDS.maxZ - margin)

		if clampedX ~= newPosition.X or clampedZ ~= newPosition.Z then
			local escapeAngle = mathRandom() * mathPi - mathPi/2
			local currentAngle = mathAtan2(self.Direction.X, self.Direction.Z)
			local newAngle = currentAngle + escapeAngle

			self.Direction = Vector3new(mathSin(newAngle), 0, mathCos(newAngle))
			motion.currentDirection = self.Direction
			self.CurrentYaw = newAngle
			self.TargetYaw = newAngle

			self.TargetOrb = nil
			self.TargetSnake = nil
			self.State = "WANDER"
		end

		self.Position = Vector3new(clampedX, AI_HEIGHT, clampedZ)
	else
		self.Position = Vector3new(newPosition.X, AI_HEIGHT, newPosition.Z)
	end

	local actualDelta = (self.Position - previousPosition).Magnitude
	self:_updateStuckTimer(dt, actualDelta)
	motion.lastPosition = self.Position

	self.RootPart.Position = self.Position

	local headOffset = self.Direction * 1.5
	local newHeadPos = self.Position + headOffset
	self.HeadParts.head.CFrame = CFramelookAt(newHeadPos, newHeadPos + self.Direction)

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

	self.HeadParts.head.AssemblyLinearVelocity = self.Direction * self.Speed
	local headPos = self.HeadParts.head.Position
	local pickupRadius = 8

	local orbsToCheck = {}

	for _, obj in pairs(Workspace:GetChildren()) do
		if obj:IsA("BasePart") and (obj.Name == "Orb" or obj.Name == "UpgradeOrb" or obj.Name == "DeathOrb") then
			-- Filter out orbs that are too high or low
			if mathAbs(obj.Position.Y - AI_HEIGHT) < 15 then
				table.insert(orbsToCheck, obj)
			end
		end
	end

	local orbFolder = Workspace:FindFirstChild("OrbFolder") or Workspace:FindFirstChild("Orbs")
	if orbFolder then
		for _, orb in ipairs(orbFolder:GetChildren()) do
			if orb:IsA("BasePart") then
				if mathAbs(orb.Position.Y - AI_HEIGHT) < 15 then
					table.insert(orbsToCheck, orb)
				end
			end
		end
	end

	for _, orb in ipairs(orbsToCheck) do
		if orb:IsA("BasePart") and orb.Parent then
			local dist = (orb.Position - headPos).Magnitude

			if dist <= pickupRadius then
				local isBeingCollected = orb:GetAttribute("BeingCollected")
				if isBeingCollected then
					continue
				end

				orb:SetAttribute("BeingCollected", true)

				local valueObj = orb:FindFirstChild("Value")
				local orbValue = valueObj and valueObj.Value or 1

				if orb.Name == "UpgradeOrb" then
					if SnakeUpgrades then
						warn("AI Snake collecting upgrade orb")
						SnakeUpgrades.GiveUpgrade(self)
					end
				else
					self:grow(orbValue)
				end

				orb:Destroy()
				break
			end
		end
	end

	if self.PathSystem then
		local path = self.PathSystem
		local delta = self.Position - path.lastRecordedPos
		local dist = delta.Magnitude
		if dist > path.minRecordDistance * 1.5 then
			local step = path.minRecordDistance
			local dir = dist > 0 and delta.Unit or self.Direction
			local travelled = step
			while travelled < dist do
				local interpPos = path.lastRecordedPos + dir * travelled
				self:_recordPathPoint(interpPos, true)
				travelled += step
			end
		end
		self:_recordPathPoint(self.Position, true)
	end

	local followSpeed = self.IsBoosting and self.BoostFollowSpeed or self.FollowSpeed

	self._segmentUpdateFrame = (self._segmentUpdateFrame or 0) + 1

	self.Model:SetAttribute("CurrentLength", self.CurrentLength)
	self.Model:SetAttribute("HeadPosition", self.Position)
	self.Model:SetAttribute("Length", self.CurrentLength)

	local currentBaseSize = BASE_SIZE * self.growthFactor

	-- VISUAL POLISH: Check visibility and enforce it
	if not isSpawnProtected then
		if self.HeadParts and self.HeadParts.head then
			self.HeadParts.head.Transparency = 0
		end
		-- Force segments visible if they might have stuck transparency
		if self._segmentUpdateFrame % 30 == 0 then
			for i = 1, self.CurrentLength do
				local seg = self.Segments[i]
				if seg and seg.Parent and seg.Transparency > 0.1 then
					seg.Transparency = 0
				end
			end
		end
	end

	local segmentSkip = 1
	if self.CurrentLength > VERY_LONG_SNAKE_THRESHOLD then
		segmentSkip = 4
	elseif self.CurrentLength > LONG_SNAKE_THRESHOLD then
		segmentSkip = 2
	end

	local updateOffset = self._segmentUpdateFrame % segmentSkip

	if not self.CurrentLength then
		warn("AISnake:updateMovement missing CurrentLength")
		return
	end
	local maxSegmentToUpdate = math.min(self.CurrentLength, DYNAMIC_SEGMENT_LIMIT)

	for i = 1 + updateOffset, maxSegmentToUpdate, segmentSkip do
		local segment = self:ensureSegmentExists(i)
		if segment and segment.Parent then
			local targetPos, targetDir = self:_samplePath(i * (self.PathSpacing or self.SegmentSpacing))
			targetDir = targetDir or self.Direction
			if targetPos then
				local newPos = segment.Position:Lerp(targetPos, followSpeed)
				segment.CFrame = CFramenew(newPos, newPos + targetDir)
				
				-- Force visible if needed
				if not isSpawnProtected and segment.Transparency > 0.1 then
					segment.Transparency = 0
				end
			end
		end
	end

	-- Re-validate visibility for skipped segments occasionally
	if segmentSkip > 1 and self._segmentUpdateFrame % 10 == 0 then
		for i = 1, maxSegmentToUpdate do
			local segment = self.Segments[i]
			if segment and segment.Parent and not isSpawnProtected and segment.Transparency > 0.1 then
				segment.Transparency = 0
			end
		end
	end

	-- Skipped segments don't need attachment updates as attachments are parented to segments

	self:monitorProgress(dt)
end
if AISnake._movementConnection then AISnake._movementConnection:Disconnect() end
if AISnake._brainConnection then AISnake._brainConnection:Disconnect() end

local brainUpdateCounter = 0

AISnake._movementConnection = RunService.Heartbeat:Connect(function(dt)
	local snakesToUpdate = {}
	for i = 1, #AISnake._activeSnakes do
		local snake = AISnake._activeSnakes[i]
		if snake and snake._active then
			table.insert(snakesToUpdate, snake)
		end
	end

	brainUpdateCounter = brainUpdateCounter + 1
	if brainUpdateCounter >= 30 then
		brainUpdateCounter = 0
		for i = 1, #snakesToUpdate do
			local snake = snakesToUpdate[i]
			if snake and snake._active then
				snake:updateBrain()
			end
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

local lastCleanup = 0
local CLEANUP_INTERVAL = 10

AISnake._brainConnection = RunService.Stepped:Connect(function(time, deltaTime)
	AISnake._spatialGridTimer = AISnake._spatialGridTimer + deltaTime

	if time - lastCleanup > CLEANUP_INTERVAL then
		lastCleanup = time
		local removed = 0
		for i = #AISnake._activeSnakes, 1, -1 do
			local snake = AISnake._activeSnakes[i]
			if not snake or not snake._active or snake._destroyed then
				table.remove(AISnake._activeSnakes, i)
				removed = removed + 1
			end
		end
		if removed > 0 then
			warn("Cleaned up", removed, "invalid AI snakes")
		end
	end

	if AISnake._spatialGridTimer >= SPATIAL_GRID_UPDATE_RATE then
		AISnake._spatialGridTimer = 0

		SpatialGrid.Clear()

		for _, snake in ipairs(AISnake._activeSnakes) do
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

		for _, player in ipairs(Players:GetPlayers()) do
			if player.Character then
				local head = player.Character:FindFirstChild("HumanoidRootPart")
				if head then
					SpatialGrid.Insert(head, player, "PLAYER_HEAD")
				end

				local segmentCount = 0
				for _, part in ipairs(player.Character:GetChildren()) do
					if part:IsA("BasePart") and part.Name:match("Segment") then
						segmentCount = segmentCount + 1
						if segmentCount % 4 == 1 then
							SpatialGrid.Insert(part, player, "PLAYER_SEGMENT")
						end
					end
				end
			end
		end

		if not OrbUtils then 
			pcall(function() OrbUtils = require(ReplicatedStorage:WaitForChild("OrbUtils")) end)
		end
		
		if OrbUtils and OrbUtils.orbs then
			for _, orb in ipairs(OrbUtils.orbs) do
				SpatialGrid.Insert(orb, orb, "ORB")
			end
		end
	end

	local snakes = AISnake._activeSnakes
	if #snakes == 0 then
		AISnake._brainUpdateIndex = 1
		return
	end

	local nearestPlayerPos = nil
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			nearestPlayerPos = player.Character.HumanoidRootPart.Position
			break
		end
	end

	for i = 1, BRAIN_UPDATES_PER_FRAME do
		if AISnake._brainUpdateIndex > #snakes then
			AISnake._brainUpdateIndex = 1
		end
		if AISnake._brainUpdateIndex < 1 then
			AISnake._brainUpdateIndex = 1
		end

		local snake = snakes[AISnake._brainUpdateIndex]
		if snake and snake._active then
			local shouldUpdate = true
			if nearestPlayerPos and snake.Position then
				local dist = (snake.Position - nearestPlayerPos).Magnitude
				if dist > AI_UPDATE_DISTANCE then
					shouldUpdate = false
				end
			end

			if shouldUpdate then
				snake:updateBrain()
			end
		end

		AISnake._brainUpdateIndex = AISnake._brainUpdateIndex + 1
	end
end)
function AISnake:getSegmentColor(index)
	if not self.Config or not self.Config.BodyColors or #self.Config.BodyColors == 0 then
		return Color3.fromRGB(255, 255, 51)
	end

	if index == 0 then
		return self.Config.HeadColor or self.Config.BodyColors[1]
	elseif index <= HEAD_BLEND_SEGMENTS then
		local blendFactor = (index / HEAD_BLEND_SEGMENTS) ^ 0.7
		local headColor = self.Config.HeadColor or self.Config.BodyColors[1]
		local bodyColor = self.Config.BodyColors[1]
		return headColor:Lerp(bodyColor, blendFactor)
	else
		local colorIndex = ((index - 1) % #self.Config.BodyColors) + 1
		return self.Config.BodyColors[colorIndex]
	end
end

function AISnake:calculateGrowthFactor()
	local length = self.CurrentLength

	if length <= 50 then
		return 1.0
	elseif length <= 200 then
		return 1.0 + (length - 50) / 150 * 0.5
	elseif length <= 1000 then
		return 1.5 + (length - 200) / 800 * 1.0
	elseif length <= 5000 then
		return 2.5 + (length - 1000) / 4000 * 0.5
	else
		return 3.0 + math.min((length - 5000) / 10000 * 0.5, 0.5)
	end
end

function AISnake:getSegmentSize(index, baseSize)
	if index == 0 then
		return baseSize * HEAD_SIZE_MULTIPLIER
	elseif index <= HEAD_BLEND_SEGMENTS then
		local blendFactor = index / HEAD_BLEND_SEGMENTS
		local headSize = baseSize * HEAD_SIZE_MULTIPLIER
		local bodySize = baseSize * (1 - 0.05 * blendFactor)
		return (headSize + (bodySize - headSize) * (blendFactor ^ 0.5))
	else
		local taperFactor = 1 - (index / self.CurrentLength) * 0.2
		taperFactor = 1 - (1 - taperFactor) ^ 1.5
		return baseSize * taperFactor
	end
end

function AISnake:getBeamWidth(index, baseSize)
	local segmentSize1 = self:getSegmentSize(index, baseSize)
	local segmentSize2 = self:getSegmentSize(index + 1, baseSize)

	local avgSize = (segmentSize1 + segmentSize2) / 2
	local beamTaper = 1 - (index / self.CurrentLength) * BEAM_TAPER_STRENGTH
	local aiConfig = self.Config.AI or {}
	local beamWidthBase = aiConfig.BeamWidthMultiplier or BEAM_WIDTH_BASE * 0.7 -- Reduced from 0.9 to 0.7

	return avgSize * beamWidthBase * beamTaper
end

function AISnake:ensureSegmentExists(index)
	if index > DYNAMIC_SEGMENT_LIMIT or index > self.CurrentLength then
		return nil
	end

	local segment = self.Segments[index]
	if segment and segment.Parent then
		return segment
	end

	local targetPos, targetDir = self:_samplePath(index * (self.PathSpacing or self.SegmentSpacing))
	if not targetPos then
		return nil
	end

	local color = self:getSegmentColor(index)
	segment = createSegment(index, targetPos, color, self.Config, self.Model, self.CurrentLength)

	local currentBaseSize = BASE_SIZE * self.growthFactor
	local segmentSize = self:getSegmentSize(index, currentBaseSize)
	segment.Size = Vector3.new(segmentSize, segmentSize, segmentSize)
	targetDir = targetDir or self.Direction
	segment.CFrame = CFramenew(targetPos, targetPos + targetDir)

	segment.Transparency = 0
	segment.CanTouch = index <= 50
	segment.CanQuery = index <= 10

	self.Segments[index] = segment

	if not self.Attachments[index] then
		local attachment = Instance.new("Attachment")
		attachment.Name = "Attachment" .. index
		attachment.Parent = segment
		attachment.Position = Vector3.new(0, 0, 0)
		self.Attachments[index] = attachment
	end

	if index > 0 and not self.Beams[index - 1] then
		local prevAttachment = self.Attachments[index - 1]
		if prevAttachment then
			local beam = Instance.new("Beam")
			beam.Name = "Beam" .. (index - 1)
			beam.Attachment0 = prevAttachment
			beam.Attachment1 = self.Attachments[index]

			local beamWidth = self:getBeamWidth(index - 1, currentBaseSize)
			beam.Width0 = beamWidth
			beam.Width1 = beamWidth
			beam.CurveSize0 = 0
			beam.CurveSize1 = 0
			beam.FaceCamera = true
			beam.Segments = BEAM_SEGMENTS
			beam.Texture = BEAM_TEXTURES.gradient
			beam.TextureMode = Enum.TextureMode.Wrap
			beam.TextureLength = 2
			beam.TextureSpeed = BEAM_TEXTURE_SPEED
			beam.LightEmission = 1
			beam.LightInfluence = 0
			beam.Brightness = 2
			beam.Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0.5),
				NumberSequenceKeypoint.new(0.5, 0.3),
				NumberSequenceKeypoint.new(1, 0.5)
			}
			beam.Color = ColorSequence.new(color)

			if index - 1 == 0 then
				beam.Parent = self.HeadParts.head
			else
				local prevSeg = self.Segments[index - 1]
				if prevSeg and prevSeg.Parent then
					beam.Parent = prevSeg
				else
					beam.Parent = segment
				end
			end
			self.Beams[index - 1] = beam
			beam.Enabled = true
		end
	end

	return segment
end

return AISnake
