-- AISnake Module: INTELLIGENT BRAIN (V5.0) + AAA BODY (V9.5)
-- MERGED: All 3k lines of Brain Logic + Optimized AAA Visuals
-- Fixed: Visual sync with player body (uses SnakeConfig)
-- Fixed: Missing attributes for Leaderboard

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")

local SnakeConfig = require(ReplicatedStorage:WaitForChild("SnakeConfig"))
local OrbUtils -- Lazy loaded

-- Load modules
local AISnakeOrbPickup
pcall(function()
	local module = ReplicatedStorage:FindFirstChild("AISnakeOrbPickup") or game.ServerScriptService:FindFirstChild("AISnakeOrbPickup")
	if module then AISnakeOrbPickup = require(module) end
end)

local SnakeUpgrades
pcall(function()
	local module = ReplicatedStorage:FindFirstChild("SnakeUpgrades")
	if module then SnakeUpgrades = require(module) end
end)

-- Optimization Locals
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
local mathClamp = math.clamp
local mathFloor = math.floor
local mathSin = math.sin
local mathCos = math.cos

-- === CONFIGURATION (SYNCED WITH SNAKECONFIG) ===
local MIN_RECORD_DIST = 0.5
local MAX_SEGMENTS = 3000
local BULK_MOVE_THRESHOLD = 50

-- Derived Constants from SnakeConfig for 1:1 Visual Match
-- If Config values are missing, fallback to defaults
local CFG_SEG_SIZE = SnakeConfig.SegmentSize and SnakeConfig.SegmentSize.X or 2.5
local CFG_HEAD_SIZE = SnakeConfig.HeadSize and SnakeConfig.HeadSize.X or 3.0
local CFG_SPACING = SnakeConfig.SegmentSpacing or 2.2

local BASE_SIZE = CFG_SEG_SIZE
local HEAD_SIZE_MULTIPLIER = CFG_HEAD_SIZE / BASE_SIZE
local SEGMENT_SPACING_FACTOR = CFG_SPACING / BASE_SIZE

-- Visual Constants (AAA)
local GLOW_INTENSITY = 2
local GLOW_RANGE_BASE = 15
local BEAM_SEGMENTS = 10
local BEAM_WIDTH_BASE = 0.95
local BEAM_TAPER_STRENGTH = 0.15
local HEAD_BLEND_SEGMENTS = 12
local GLOW_FALLOFF_START = 50
local AI_HEIGHT = 5

-- Visual Enhancements
local BEAM_TEXTURE_SPEED = 2
local BEAM_TEXTURES = {
	gradient = "rbxasset://textures/ui/LuaChat/9-slice/kit-modal-highlight.png"
}

-- LOD
local FORCE_RENDER_SEGMENTS = 200
local LOD_DISTANCE_FAR = 600

-- === BRAIN CONFIGURATION ===
local MAX_AI_SNAKES = 15
local SPATIAL_GRID_UPDATE_RATE = 0.1
local BRAIN_UPDATES_PER_FRAME = 3
local AI_UPDATE_DISTANCE = 1500

-- Helpers
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
	return typeof(vec) == "Vector3" and vec.X == vec.X and vec.Y == vec.Y and vec.Z == vec.Z
end

local function sanitizeVector(vec, fallback)
	if not isValidVector(vec) or vec.Magnitude < 0.0001 then
		return fallback or Vector3new(0, 0, 1)
	end
	return vec
end

local MAX_TURN_DEG = 90 
local HARD_TURN_DEG = 120

local function limitTurnAngle(currentDir, desiredDir, allowHardTurn)
	if not (isValidVector(currentDir) and isValidVector(desiredDir)) then return desiredDir end
	currentDir = currentDir.Unit
	desiredDir = desiredDir.Unit
	local maxAngle = mathRad(allowHardTurn and HARD_TURN_DEG or MAX_TURN_DEG)
	local dot = mathClamp(currentDir:Dot(desiredDir), -1, 1)
	if dot >= mathCos(maxAngle) then return desiredDir end
	local right = currentDir:Cross(Vector3new(0, 1, 0))
	if right.Magnitude < 0.001 then return desiredDir end
	local turnDir = right:Dot(desiredDir) >= 0 and 1 or -1
	local currentAngle = mathAtan2(currentDir.X, currentDir.Z)
	local limitedAngle = currentAngle + maxAngle * turnDir
	return Vector3new(mathSin(limitedAngle), 0, mathCos(limitedAngle))
end

local function perpendicular(vector)
	return Vector3new(-vector.Z, 0, vector.X)
end

-- Naming
local LETTERS = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"}
local usedAINames = {}
local function pickAIName()
	local name = ""
	for i=1, mathRandom(5,8) do name = name .. LETTERS[mathRandom(1,#LETTERS)] end
	return name:gsub("^%l", string.upper)
end
local function releaseAIName(name) usedAINames[name] = nil end

local function scoreOrbCandidate(orb, distance)
	distance = math.max(distance, 1)
	local baseValue = 1
	local valueObj = orb:FindFirstChild("Value")
	if valueObj and typeof(valueObj.Value) == "number" then
		baseValue = math.max(valueObj.Value, 0.1)
	elseif orb:GetAttribute("Value") then
		baseValue = math.max(tonumber(orb:GetAttribute("Value")) or 1, 0.1)
	end
	if orb.Name == "DeathOrb" then baseValue = baseValue * 15
	elseif orb.Name == "UpgradeOrb" then baseValue = baseValue * 10 end
	return baseValue / distance
end

-- Map Bounds
local MAP_BOUNDS = {minX = -1450, maxX = 1450, minZ = -1450, maxZ = 1450}
local function updateMapBounds()
	local ground = Workspace:FindFirstChild("SlitherIOGround")
	if ground and ground:IsA("BasePart") then
		local halfX = ground.Size.X / 2
		local halfZ = ground.Size.Z / 2
		MAP_BOUNDS.minX = ground.Position.X - halfX + 30
		MAP_BOUNDS.maxX = ground.Position.X + halfX - 30
		MAP_BOUNDS.minZ = ground.Position.Z - halfZ + 30
		MAP_BOUNDS.maxZ = ground.Position.Z + halfZ - 30
	end
end
updateMapBounds()

-- Wall Avoidance
local function getWallAvoidanceVector(headPos)
	local avoidVec = Vector3new(0,0,0)
	local strength = 0
	local buffer = 50
	
	if headPos.X < MAP_BOUNDS.minX + buffer then
		avoidVec = avoidVec + Vector3new(1,0,0)
		strength = mathMax(strength, 1 - (headPos.X - MAP_BOUNDS.minX)/buffer)
	elseif headPos.X > MAP_BOUNDS.maxX - buffer then
		avoidVec = avoidVec + Vector3new(-1,0,0)
		strength = mathMax(strength, 1 - (MAP_BOUNDS.maxX - headPos.X)/buffer)
	end
	
	if headPos.Z < MAP_BOUNDS.minZ + buffer then
		avoidVec = avoidVec + Vector3new(0,0,1)
		strength = mathMax(strength, 1 - (headPos.Z - MAP_BOUNDS.minZ)/buffer)
	elseif headPos.Z > MAP_BOUNDS.maxZ - buffer then
		avoidVec = avoidVec + Vector3new(0,0,-1)
		strength = mathMax(strength, 1 - (MAP_BOUNDS.maxZ - headPos.Z)/buffer)
	end
	
	if strength > 0 then return avoidVec.Unit, strength end
	return nil, 0
end

-- === SPATIAL GRID ===
local SpatialGrid = {}
do
	local CELL_SIZE = 75
	local grid = {}
	
	local function getCellCoords(position)
		local x = mathFloor((position.X - MAP_BOUNDS.minX) / CELL_SIZE)
		local z = mathFloor((position.Z - MAP_BOUNDS.minZ) / CELL_SIZE)
		return x, z
	end

	function SpatialGrid.Clear()
		grid = {}
	end

	function SpatialGrid.Insert(part, owner, type)
		if not part or not part.Parent then return end
		local x, z = getCellCoords(part.Position)
		if not grid[x] then grid[x] = {} end
		if not grid[x][z] then grid[x][z] = {} end
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

-- === AISNAKE CLASS ===
local AISnake = {}
AISnake.__index = AISnake
AISnake._activeSnakes = {}
AISnake._orbTargets = {}

-- === PERSONALITIES & SKILLS ===
AISnake.PersonalityTypes = {"Collector", "Explorer", "Predator", "Opportunist", "Farmer", "Raider", "Guardian", "Nomad"}
AISnake.PersonalityDefinitions = {
	Collector = {Type = "Collector", TargetOrbs = true, TargetPlayers = false, AvoidOthers = true, OrbSeekRadius = 300, SpeedMultiplier=1.05, TurnBias=0.015, BoostChance=0.04},
	Explorer = {Type = "Explorer", TargetOrbs = true, TargetPlayers = false, AvoidOthers = false, OrbSeekRadius = 200, SpeedMultiplier=1.15, TurnBias=0.02, BoostChance=0.05},
	Predator = {Type = "Predator", TargetOrbs = true, TargetPlayers = true, AvoidOthers = false, OrbSeekRadius = 400, SpeedMultiplier=1.2, TurnBias=0.025, BoostChance=0.08},
	Opportunist = {Type = "Opportunist", TargetOrbs = true, TargetPlayers = true, AvoidOthers = false, OrbSeekRadius = 450, SpeedMultiplier=1.18, TurnBias=0.03, BoostChance=0.07},
	Farmer = {Type = "Farmer", TargetOrbs = true, TargetPlayers = false, AvoidOthers = true, OrbSeekRadius = 600, SpeedMultiplier=1.0, TurnBias=0.01, BoostChance=0.02},
	Raider = {Type = "Raider", TargetOrbs = true, TargetPlayers = true, AvoidOthers = false, OrbSeekRadius = 350, SpeedMultiplier=1.25, TurnBias=0.04, BoostChance=0.1},
	Guardian = {Type = "Guardian", TargetOrbs = true, TargetPlayers = true, AvoidOthers = false, OrbSeekRadius = 400, SpeedMultiplier=1.1, TurnBias=0.02, BoostChance=0.05},
	Nomad = {Type = "Nomad", TargetOrbs = true, TargetPlayers = false, AvoidOthers = false, OrbSeekRadius = 500, SpeedMultiplier=1.12, TurnBias=0.025, BoostChance=0.06},
}

local function buildSkillProfile()
	local roll = randomFloat(0, 1)
	if roll < 0.25 then
		return {label="Rookie", reactionLag=0.2, turnMultiplier=0.8, errorChance=0.4}
	elseif roll < 0.7 then
		return {label="Nominal", reactionLag=0.1, turnMultiplier=1.0, errorChance=0.2}
	elseif roll < 0.9 then
		return {label="Veteran", reactionLag=0.05, turnMultiplier=1.15, errorChance=0.1}
	else
		return {label="Elite", reactionLag=0.01, turnMultiplier=1.3, errorChance=0.05}
	end
end

local function deepCopy(orig)
	local copy
	if type(orig) == "table" then
		copy = {}
		for k, v in pairs(orig) do copy[k] = deepCopy(v) end
	else
		copy = orig
	end
	return copy
end

local function getOrCreateSnakeModel(aiId)
	local modelName = "AISnakeModel_" .. tostring(aiId)
	local folder = Workspace:FindFirstChild("Snakes") or Instance.new("Folder", Workspace)
	folder.Name = "Snakes"
	local model = folder:FindFirstChild(modelName) or Instance.new("Model")
	model.Name = modelName
	model.Parent = folder
	CollectionService:AddTag(model, "AISnake")
	return model
end

-- Colors
local AISnakeColors = {
	{HeadColor = Color3.fromRGB(255,255,102), BodyColors = {Color3.fromRGB(255,255,51)}},
	{HeadColor = Color3.fromRGB(102,255,102), BodyColors = {Color3.fromRGB(60,180,80)}},
	{HeadColor = Color3.fromRGB(102,178,255), BodyColors = {Color3.fromRGB(51,153,255)}},
	{HeadColor = Color3.fromRGB(255,178,102), BodyColors = {Color3.fromRGB(255,153,51)}}
}

local function getRandomAIColor()
	return AISnakeColors[mathRandom(1, #AISnakeColors)]
end

-- === BRAIN METHODS ===
function AISnake:findBestOrb()
	local seekRadius = self.Personality.OrbSeekRadius or 50
	local scanRadius = seekRadius * 2
	local headPos = self.Position
	local bestScore, bestOrb, bestDist = -math.huge, nil, math.huge

	local function considerOrb(orb)
		if not orb or not orb.Parent then return end
		local dist = (orb.Position - headPos).Magnitude
		if dist > scanRadius then return end
		local val = scoreOrbCandidate(orb, dist)
		if val > bestScore then
			bestScore = val
			bestOrb = orb
			bestDist = dist
		end
	end

	local nearby = SpatialGrid.QueryRadius(headPos, scanRadius)
	for _, e in ipairs(nearby) do
		if e.type == "ORB" and e.part then considerOrb(e.part) end
	end
	
	if #nearby == 0 then
		local orbFolder = Workspace:FindFirstChild("OrbFolder")
		if orbFolder then
			for _, orb in ipairs(orbFolder:GetChildren()) do
				considerOrb(orb)
			end
		end
	end

	return bestOrb, bestDist
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
	local headPos = self.Position
	local threats = {}
	local nearby = SpatialGrid.QueryRadius(headPos, 80)
	
	for _, e in ipairs(nearby) do
		if (e.type == "AI_HEAD" or e.type == "PLAYER_HEAD") and e.owner ~= self then
			local dist = (e.part.Position - headPos).Magnitude
			local enemyLength = 0
			
			if e.type == "AI_HEAD" and e.owner.CurrentLength then
				enemyLength = e.owner.CurrentLength
			elseif e.type == "PLAYER_HEAD" then
				local leaderstats = e.owner:FindFirstChild("leaderstats")
				local lengthStat = leaderstats and leaderstats:FindFirstChild("Length")
				enemyLength = lengthStat and lengthStat.Value or 10
			end
			
			local lengthDiff = enemyLength - self.CurrentLength
			table.insert(threats, {part=e.part, distance=dist, lengthDiff=lengthDiff})
		end
	end
	return threats
end

function AISnake:startBoost(duration)
	if self.Boosting then return end
	self.Boosting = true
	self.BoostEndTime = tick() + (duration or 1.5)
	self.BoostCooldown = self.BoostEndTime + mathRandom(1,3)
	if self.HeadParts.boostParticles then self.HeadParts.boostParticles.Enabled = true end
end

function AISnake:isPathSafe(targetPos, checkDist)
	local dir = (targetPos - self.Position).Unit
	local check = self.Position + dir * mathMin(checkDist, 50)
	local nearby = SpatialGrid.QueryRadius(check, 10)
	for _, e in ipairs(nearby) do
		if (e.type:match("SEGMENT") or e.type:match("HEAD")) and e.owner ~= self then
			return false
		end
	end
	return true
end

function AISnake:getSmartFleeDirection(threats)
	if #threats == 0 then return self.Direction end
	local fleeDir = Vector3new(0,0,0)
	for _, t in ipairs(threats) do
		local away = (self.Position - t.part.Position).Unit
		fleeDir = fleeDir + away
	end
	return fleeDir.Unit
end

function AISnake:_ensureMotionState()
	if self.MotionState then return self.MotionState end
	self.MotionState = {
		currentDirection = self.Direction,
		smoothedSteer = self.Direction,
		desiredDirection = self.Direction,
		lastPosition = self.Position,
		stuckTime = 0,
	}
	return self.MotionState
end

function AISnake:_setSteerTarget(steer)
	local motion = self:_ensureMotionState()
	motion.desiredDirection = sanitizeVector(steer, self.Direction).Unit
	self.SteerDirection = motion.desiredDirection
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
	local turnSign = mathRandom(0, 1) == 0 and -1 or 1
	local turnRadians = mathRad(randomFloat(25, 45) * turnSign)
	local currentDir = self.Direction
	local cosA, sinA = mathCos(turnRadians), mathSin(turnRadians)
	self.Direction = Vector3new(currentDir.X*cosA - currentDir.Z*sinA, 0, currentDir.X*sinA + currentDir.Z*cosA).Unit
	self.TargetOrb = nil
end

function AISnake:applySafetySteer(steerVector)
	if not steerVector or steerVector.Magnitude < 0.01 then return self.Direction end
	local safeProbe = self.Position + steerVector.Unit * 28
	if self:isPathSafe(safeProbe, 28) then return steerVector end
	local left = perpendicular(steerVector).Unit
	if self:isPathSafe(self.Position + left * 24, 24) then return left end
	local right = perpendicular(-steerVector).Unit
	if self:isPathSafe(self.Position + right * 24, 24) then return right end
	return steerVector
end

function AISnake:monitorProgress(dt)
	if not self.ProgressWatch then return end
	local watch = self.ProgressWatch
	local delta = (self.Position - watch.lastPos).Magnitude
	if delta < 1.0 then
		watch.stagnation = watch.stagnation + dt
	else
		watch.stagnation = 0
		watch.lastPos = self.Position
	end
	if watch.stagnation > 2.4 then self:forceCourseCorrection("stagnation") end
end

function AISnake:_determineAction()
	local now = tick()
	local p = self.Personality
	
	if self.Avoiding and now < self.AvoidExpire then
		return "FLEE", self.AvoidDir
	end
	self.Avoiding = false
	
	-- Map Bounds
	local pos = self.Position
	if pos.X < MAP_BOUNDS.minX + 80 or pos.X > MAP_BOUNDS.maxX - 80 or
	   pos.Z < MAP_BOUNDS.minZ + 80 or pos.Z > MAP_BOUNDS.maxZ - 80 then
		local center = Vector3new(0, AI_HEIGHT, 0)
		return "AVOID_BOUNDARY", (center - pos).Unit
	end
	
	-- Wall Avoidance
	local wallVec, wallStr = getWallAvoidanceVector(pos)
	if wallVec and wallStr > 0.3 then
		return "AVOID_WALL", wallVec
	end
	
	-- Threats
	local threats = self:findNearbyThreats()
	if #threats > 0 then
		local closest = threats[1]
		if closest.distance < 30 and closest.lengthDiff > 0 then
			self.Avoiding = true
			self.AvoidExpire = now + 2
			self.AvoidDir = self:getSmartFleeDirection(threats)
			self:startBoost(1.5)
			return "FLEE", self.AvoidDir
		end
	end
	
	-- Orbs
	if p.TargetOrbs then
		local orb, dist = self:findBestOrb()
		if orb then
			self.TargetOrb = orb
			return "SEEK_ORB", (orb.Position - pos).Unit
		end
	end
	
	-- Wander
	if not self._lastTurn or now - self._lastTurn > (self.RandomTurnInterval or 2) then
		self._lastTurn = now
		local angle = mathRandom() * mathPi * 2
		self.WanderDir = Vector3new(mathSin(angle), 0, mathCos(angle))
	end
	
	return "WANDER", self.WanderDir or self.Direction
end

function AISnake:updateBrain()
	local state, steer = self:_determineAction()
	self.State = state
	self:_setSteerTarget(steer)
end

-- === NEW BODY LOGIC (AAA DISTANCE BASED) ===

function AISnake.new(startPosition, preservedPersonalityType, preservedSkillTier)
	if #AISnake._activeSnakes >= MAX_AI_SNAKES then return nil end
	local self = setmetatable({}, AISnake)

	-- Personality & Skill
	local pType = preservedPersonalityType or AISnake.PersonalityTypes[mathRandom(1, #AISnake.PersonalityTypes)]
	self.Personality = deepCopy(AISnake.PersonalityDefinitions[pType])
	self.SkillProfile = buildSkillProfile()
	if preservedSkillTier then
		for i=1,20 do
			if self.SkillProfile.label == preservedSkillTier then break end
			self.SkillProfile = buildSkillProfile()
		end
	end
	self.SkillTier = self.SkillProfile.label
	self.SkillReactionLag = self.SkillProfile.reactionLag or 0.1

	local colorData = AISnakeColors[mathRandom(1, #AISnakeColors)]
	self.Config = deepCopy(SnakeConfig)
	self.Config.HeadColor = colorData.HeadColor
	self.Config.BodyColors = colorData.BodyColors
	
	self.Position = startPosition or Vector3new(0, AI_HEIGHT, 0)
	self.Direction = Vector3new(0, 0, 1)
	self.Speed = self.Config.AI.BaseSpeed or 18
	self.TurnSpeed = self.Config.AI.TurnSpeed or 4.5
	self.DisplayName = pickAIName()
	self.State = "WANDER"
	self._active = true
	self._destroyed = false
	
	self.CurrentLength = self.Config.InitialLength or 85 -- Match player default roughly
	self.TargetLength = self.CurrentLength
	self.growthFactor = 1
	
	-- === AAA DISTANCE PATHING ===
	self.pathPoints = {} 
	self.totalPathDistance = 0
	self.lastRecordPos = self.Position
	table.insert(self.pathPoints, {
		position = self.Position,
		cframe = CFramenew(self.Position),
		totalDist = 0
	})
	
	self.Model = getOrCreateSnakeModel(tostring(self) .. "_" .. mathRandom(10000,99999))
	for _, c in ipairs(self.Model:GetChildren()) do c:Destroy() end
	
	self.Model:SetAttribute("AIName", self.DisplayName)
	self.Model:SetAttribute("IsAI", true)
	-- LEADERBOARD RESTORATION: Set critical attributes
	self.Model:SetAttribute("Length", self.CurrentLength)
	self.Model:SetAttribute("CurrentLength", self.CurrentLength)
	self.Model:SetAttribute("SkillTier", self.SkillTier)
	
	self.Segments = {}
	self.Beams = {}
	self.Attachments = {}
	self.Glows = {}
	self.visibleSegmentCount = 0
	
	self:createUnifiedBody()
	
	-- Pre-fill history
	for i=1, 50 do
		local p = self.Position + self.Direction * (i * 0.5)
		self:_recordPathPoint(p, true)
	end
	self.Position = self.pathPoints[#self.pathPoints].position
	
	-- Spawn Protection
	self._spawnProtection = os.clock() + 5
	self.HeadParts.head:SetAttribute("SpawnProtectionExpiry", self._spawnProtection)
	task.spawn(function()
		if self.HeadParts.head then self.HeadParts.head.Transparency = 0.5 end
		task.wait(5)
		if self._active and self.HeadParts.head then self.HeadParts.head.Transparency = 0 end
	end)
	
	-- === INIT BRAIN HELPERS ===
	self.MotionState = {
		currentDirection = self.Direction,
		smoothedSteer = self.Direction,
		desiredDirection = self.Direction,
		lastPosition = self.Position,
		stuckTime = 0,
	}

	self.ProgressWatch = {
		lastPos = self.Position,
		stagnation = 0,
		oscillationAnchor = self.Position,
		oscillationTimer = 0
	}
	
	table.insert(AISnake._activeSnakes, self)
	return self
end

-- === AAA MOVEMENT HISTORY ===
function AISnake:_recordPathPoint(position, force)
	local dist = (position - self.lastRecordPos).Magnitude
	if dist >= MIN_RECORD_DIST or force then
		self.totalPathDistance = self.totalPathDistance + dist
		table.insert(self.pathPoints, {
			position = position,
			cframe = CFramelookAt(position, position + self.Direction),
			totalDist = self.totalPathDistance
		})
		self.lastRecordPos = position
		
		-- Prune history
		local maxNeeded = MAX_SEGMENTS * (BASE_SIZE * 3.5 * SEGMENT_SPACING_FACTOR) + 200
		while #self.pathPoints > 2 and (self.totalPathDistance - self.pathPoints[2].totalDist) > maxNeeded do
			table.remove(self.pathPoints, 1)
		end
	end
end

-- COMPATIBILITY WRAPPER: Map old _samplePath calls to new logic
function AISnake:_samplePath(distanceBehind)
	return self:_getPointAtDistance(distanceBehind)
end

function AISnake:_getPointAtDistance(distBehindHead)
	local targetDist = self.totalPathDistance - distBehindHead
	if targetDist >= self.totalPathDistance then return self.Position, CFramelookAt(self.Position, self.Position + self.Direction) end
	
	local points = self.pathPoints
	if #points < 2 then return points[1].position, points[1].cframe end
	
	-- Binary Search
	local low, high, idx = 1, #points, 1
	while low <= high do
		local mid = mathFloor((low + high) / 2)
		if points[mid].totalDist < targetDist then
			idx = mid
			low = mid + 1
		else
			high = mid - 1
		end
	end
	
	local p1 = points[idx]
	local p2 = points[idx + 1]
	if not p2 then return p1.position, p1.cframe end
	
	local alpha = (targetDist - p1.totalDist) / (p2.totalDist - p1.totalDist)
	return p1.position:Lerp(p2.position, alpha), p1.cframe:Lerp(p2.cframe, alpha)
end

-- === AAA VISUALS ===
function AISnake:calculateGrowthFactor()
	-- MATCHED TO PLAYER LOGIC
	local length = self.CurrentLength
	if length <= 50 then return 1.0
	elseif length <= 200 then return 1.0 + (length - 50) / 150 * 0.5
	elseif length <= 1000 then return 1.5 + (length - 200) / 800 * 1.0
	elseif length <= 5000 then return 2.5 + (length - 1000) / 4000 * 0.5
	else return 3.0 + math.min((length - 5000) / 10000 * 0.5, 0.5) end
end

function AISnake:getSegmentSize(index, baseSize)
	if index == 0 then return baseSize * HEAD_SIZE_MULTIPLIER
	elseif index <= HEAD_BLEND_SEGMENTS then
		local blend = index / HEAD_BLEND_SEGMENTS
		local hs = baseSize * HEAD_SIZE_MULTIPLIER
		local bs = baseSize * (1 - 0.05 * blend)
		return hs + (bs - hs) * (blend ^ 0.5)
	else
		local taper = 1 - (index / mathMax(self.visibleSegmentCount, 100)) * 0.2
		return baseSize * (1 - (1-taper)^1.5)
	end
end

function AISnake:getSegmentColor(index)
	if index == 0 then return self.Config.HeadColor end
	if index <= HEAD_BLEND_SEGMENTS then
		local blend = (index / HEAD_BLEND_SEGMENTS) ^ 0.7
		return self.Config.HeadColor:Lerp(self.Config.BodyColors[1], blend)
	end
	return self.Config.BodyColors[((index - 1) % #self.Config.BodyColors) + 1]
end

function AISnake:createUnifiedBody()
	-- Removed AttachmentPart logic to parent directly to segments
	
	-- Head
	local head = Instance.new("Part")
	head.Name = "Segment0_Head"
	head.Shape = Enum.PartType.Ball
	head.Material = Enum.Material.Neon
	head.Size = Vector3new(BASE_SIZE, BASE_SIZE, BASE_SIZE) * HEAD_SIZE_MULTIPLIER
	head.CanCollide = false
	head.CanTouch = true
	head.Anchored = true
	head.Parent = self.Model
	
	self.HeadParts = {head = head}
	self.Segments[0] = head
	
	-- Head Glow
	local glow = Instance.new("PointLight")
	glow.Name = "Glow"
	glow.Brightness = GLOW_INTENSITY
	glow.Range = GLOW_RANGE_BASE
	glow.Parent = head
	self.Glows[0] = glow
	
	-- Eyes
	local function createEye(xOffset)
		local eye = Instance.new("Part")
		eye.Name = xOffset > 0 and "RightEye" or "LeftEye"
		eye.Shape = Enum.PartType.Ball
		eye.Material = Enum.Material.Neon
		eye.Color = Color3.new(1, 1, 1)
		eye.Size = Vector3new(0.5, 0.5, 0.5)
		eye.CanCollide = false
		eye.Anchored = true
		eye.Parent = self.Model
		
		local pupil = Instance.new("Part")
		pupil.Name = eye.Name .. "Pupil"
		pupil.Shape = Enum.PartType.Ball
		pupil.Material = Enum.Material.Neon
		pupil.Color = Color3.new(0, 0, 0)
		pupil.Size = Vector3new(0.25, 0.25, 0.25)
		pupil.CanCollide = false
		pupil.Anchored = true
		pupil.Parent = self.Model
		
		return eye, pupil
	end
	
	self.HeadParts.leftEye, self.HeadParts.leftPupil = createEye(-0.6)
	self.HeadParts.rightEye, self.HeadParts.rightPupil = createEye(0.6)
	
	-- Particles
	local boostParticles = Instance.new("ParticleEmitter")
	boostParticles.Name = "BoostParticles"
	boostParticles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	boostParticles.Color = ColorSequence.new(head.Color)
	boostParticles.Lifetime = NumberRange.new(0.5, 1)
	boostParticles.Rate = 50
	boostParticles.Enabled = false
	boostParticles.Parent = head
	self.HeadParts.boostParticles = boostParticles
	
	-- Attachments (Head)
	local att = Instance.new("Attachment")
	att.Name = "Attachment0"
	att.Parent = head
	self.Attachments[0] = att
	
	self.visibleSegmentCount = 0
	self.RootPart = head 
	
	self:addSegments(mathMin(mathFloor(self.CurrentLength), MAX_SEGMENTS))
end

function AISnake:addSegments(count)
	local currentCount = self.visibleSegmentCount
	local limit = mathMin(currentCount + count, MAX_SEGMENTS)
	
	if not self.Segments then self.Segments = {} end
	if not self.Glows then self.Glows = {} end
	if not self.Attachments then self.Attachments = {} end
	if not self.Beams then self.Beams = {} end
	
	for i = currentCount + 1, limit do
		local seg = Instance.new("Part")
		seg.Name = "Segment" .. i 
		seg.Shape = Enum.PartType.Ball
		seg.Material = Enum.Material.Neon
		seg.CanCollide = false
		seg.CanTouch = true
		seg.Anchored = true
		seg.Transparency = 0
		seg.Parent = self.Model
		
		CollectionService:AddTag(seg, "SnakeSegment")
		seg:SetAttribute("SegmentIndex", i)
		seg:SetAttribute("IsAISnake", true) 
		
		self.Segments[i] = seg
		
		local hasGlow = false
		if i <= GLOW_FALLOFF_START then hasGlow = true
		elseif i <= 100 then hasGlow = i % 2 == 0
		elseif i <= 200 then hasGlow = i % 3 == 0
		else hasGlow = i % 5 == 0 end
		
		if hasGlow then
			local g = Instance.new("PointLight")
			g.Brightness = GLOW_INTENSITY * 0.8
			g.Range = GLOW_RANGE_BASE * 0.8
			g.Shadows = false
			g.Parent = seg
			self.Glows[i] = g
		end
		
		local att = Instance.new("Attachment")
		att.Name = "Attachment" .. i
		att.Parent = seg
		self.Attachments[i] = att
		
		if self.Attachments[i-1] then
			local beam = Instance.new("Beam")
			beam.Name = "Beam" .. (i-1)
			beam.Attachment0 = self.Attachments[i-1]
			beam.Attachment1 = att
			beam.FaceCamera = true
			beam.Segments = BEAM_SEGMENTS
			beam.Texture = BEAM_TEXTURES.gradient
			beam.TextureMode = Enum.TextureMode.Wrap
			beam.TextureLength = 2
			beam.TextureSpeed = BEAM_TEXTURE_SPEED
			beam.LightEmission = 1
			beam.LightInfluence = 0
			beam.Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 0.1)
			}
			-- Parent beam to previous segment (or head)
			if i-1 == 0 then
				beam.Parent = self.HeadParts.head
			else
				beam.Parent = self.Segments[i-1]
			end
			self.Beams[i-1] = beam
		end
	end
	
	self.visibleSegmentCount = limit
end

function AISnake:updateUnifiedBody()
	local req = mathMin(mathFloor(self.CurrentLength), MAX_SEGMENTS)
	if req > self.visibleSegmentCount then
		self:addSegments(1)
	end
	
	local curBaseSize = BASE_SIZE * self.growthFactor
	local spacing = curBaseSize * SEGMENT_SPACING_FACTOR
	
	-- Head
	local head = self.HeadParts.head
	if head then
		head.CFrame = CFramelookAt(self.Position, self.Position + self.Direction)
		head.Size = Vector3new(1,1,1) * self:getSegmentSize(0, curBaseSize)
		head.Color = self:getSegmentColor(0)
		if self.Glows[0] then self.Glows[0].Color = head.Color end
		
		-- Note: Attachment0 is parented to head, so it moves with head automatically. 
		-- But we need to ensure it's centered.
		if self.Attachments[0] then self.Attachments[0].Position = Vector3new(0,0,0) end
		
		if self.HeadParts.leftEye then
			local hs = head.Size.X
			local es = hs / BASE_SIZE * 0.5
			local eo = hs * 0.3
			local ef = -hs * 0.35
			local cf = head.CFrame
			
			self.HeadParts.leftEye.Size = Vector3new(es,es,es)
			self.HeadParts.rightEye.Size = Vector3new(es,es,es)
			self.HeadParts.leftPupil.Size = Vector3new(es*0.5,es*0.5,es*0.5)
			self.HeadParts.rightPupil.Size = Vector3new(es*0.5,es*0.5,es*0.5)
			
			self.HeadParts.leftEye.CFrame = cf * CFramenew(-eo, eo*0.5, ef)
			self.HeadParts.rightEye.CFrame = cf * CFramenew(eo, eo*0.5, ef)
			self.HeadParts.leftPupil.CFrame = self.HeadParts.leftEye.CFrame * CFramenew(0,0,-es*0.3)
			self.HeadParts.rightPupil.CFrame = self.HeadParts.rightEye.CFrame * CFramenew(0,0,-es*0.3)
		end
	end
	
	-- Bulk Move
	local bulkParts = {}
	local bulkCFrames = {}
	
	for i = 1, self.visibleSegmentCount do
		local seg = self.Segments[i]
		if seg and seg.Parent then
			local dist = i * spacing
			local pos, cf = self:_getPointAtDistance(dist)
			
			if i <= FORCE_RENDER_SEGMENTS or i % 2 == 0 then
				table.insert(bulkParts, seg)
				table.insert(bulkCFrames, cf)
				
				seg.Size = Vector3new(1,1,1) * self:getSegmentSize(i, curBaseSize)
				seg.Color = self:getSegmentColor(i)
				
				-- Attachments are parented to segments, so we don't need to move them explicitly
				-- IF the segment moves correctly.
				
				local beam = self.Beams[i-1]
				if beam then
					local w = self:getSegmentSize(i, curBaseSize) * BEAM_WIDTH_BASE
					beam.Width0 = w; beam.Width1 = w
					beam.Color = ColorSequence.new(self:getSegmentColor(i))
					beam.Enabled = true
				end
			end
		end
	end
	
	if #bulkParts > 0 then
		Workspace:BulkMoveTo(bulkParts, bulkCFrames, Enum.BulkMoveMode.FireCFrameChanged)
	end
end

function AISnake:grow(amount)
	self.TargetLength = mathMin(self.TargetLength + (amount or 1), MAX_SEGMENTS)
end

function AISnake:Destroy()
	self._destroyed = true
	self._active = false
	if self.Model then self.Model:Destroy() end
	releaseAIName(self.DisplayName)
	
	for i, snake in ipairs(AISnake._activeSnakes) do
		if snake == self then
			table.remove(AISnake._activeSnakes, i)
			break
		end
	end
	self.Segments = nil
	self.Attachments = nil
	self.Beams = nil
	self.Glows = nil
	self.pathPoints = nil
end

-- === UPDATE LOOP (ADAPTED) ===
function AISnake:updateMovement(dt)
	if self._destroyed then return end
	dt = sanitizeNumber(dt, 0.033)
	if dt <= 0 then
		dt = 0.016
	end

	if not self._active or not self.HeadParts.head or not self.HeadParts.head.Parent then
		self:Destroy()
		return
	end
	
	local now = tick()
	if self._spawnStabilizing and now < self._spawnStabilizing then return end
	
	-- BRAIN UPDATE (Steering)
	if not self.Personality then self.Personality = deepCopy(AISnake.PersonalityDefinitions["Nomad"]) end
	local state = self.State
	local steer = self.SteerDirection or self.Direction
	
	if not steer or steer.Magnitude < 0.1 then
		steer = self.Direction
	end

	steer = self:applySafetySteer(steer)

	local baseTurnSpeed = sanitizeNumber(self.TurnSpeed, 4.5)
	if self.State == "COLLISION_AVOID" then baseTurnSpeed = baseTurnSpeed * 2.0 end
	
	local turnRate = baseTurnSpeed * dt * 0.9
	local currentDir = self.Direction
	local desiredDir = sanitizeVector(steer, self.Direction).Unit
	
	currentDir = Vector3new(currentDir.X, 0, currentDir.Z).Unit
	desiredDir = Vector3new(desiredDir.X, 0, desiredDir.Z).Unit
	
	desiredDir = limitTurnAngle(currentDir, desiredDir, false)
	
	local newDir = currentDir:Lerp(desiredDir, turnRate)
	if newDir.Magnitude > 0.001 then self.Direction = newDir.Unit end
	
	-- MOVE HEAD
	local speed = self.Speed or 18 -- Safety fallback
	if self.Boosting then speed = self.BoostSpeed or 40 end
	
	local moveDist = speed * dt
	local newPos = self.Position + self.Direction * moveDist
	
	-- Bounds
	if newPos.X < MAP_BOUNDS.minX or newPos.X > MAP_BOUNDS.maxX or newPos.Z < MAP_BOUNDS.minZ or newPos.Z > MAP_BOUNDS.maxZ then
		local safeX = mathClamp(newPos.X, MAP_BOUNDS.minX+50, MAP_BOUNDS.maxX-50)
		local safeZ = mathClamp(newPos.Z, MAP_BOUNDS.minZ+50, MAP_BOUNDS.maxZ-50)
		newPos = Vector3new(safeX, AI_HEIGHT, safeZ)
		local angle = mathAtan2(self.Direction.X, self.Direction.Z) + mathPi
		self.Direction = Vector3new(mathSin(angle), 0, mathCos(angle))
		self.SteerDirection = self.Direction
		
		-- Fix: Reset motion state on boundary hit
		if self.MotionState then
			self.MotionState.currentDirection = self.Direction
			self.MotionState.smoothedSteer = self.Direction
		end
	else
		newPos = Vector3new(newPos.X, AI_HEIGHT, newPos.Z)
	end
	self.Position = newPos
	
	-- Stuck Check
	local actualDelta = (self.Position - (self.MotionState and self.MotionState.lastPosition or self.Position)).Magnitude
	self:_updateStuckTimer(dt, actualDelta)
	if self.MotionState then self.MotionState.lastPosition = self.Position end
	
	-- RECORD HISTORY
	self:_recordPathPoint(self.Position)
	
	-- GROWTH
	if self.CurrentLength < self.TargetLength then
		self.CurrentLength = self.CurrentLength + (self.TargetLength - self.CurrentLength) * 0.25
	end
	self.growthFactor = self:calculateGrowthFactor()
	
	-- UPDATE BODY
	self:updateUnifiedBody()
	
	-- ORBS
	local headPos = self.Position
	for _, orb in ipairs(Workspace:GetChildren()) do
		if orb.Name == "Orb" or orb.Name == "DeathOrb" then
			if (orb.Position - headPos).Magnitude < 8 then
				if not orb:GetAttribute("Collected") then
					orb:SetAttribute("Collected", true)
					local val = 1
					local valObj = orb:FindFirstChild("Value")
					if valObj then val = valObj.Value end
					self:grow(val)
					if self.HeadParts.boostParticles then self.HeadParts.boostParticles:Emit(5) end
					orb:Destroy()
				end
			end
		end
	end
	
	if self.Boosting and now > self.BoostEndTime then
		self.Boosting = false
		self.HeadParts.boostParticles.Enabled = false
	end
	
	-- LEADERBOARD SYNC
	self.Model:SetAttribute("Length", mathFloor(self.CurrentLength))
	self.Model:SetAttribute("CurrentLength", self.CurrentLength)
	self.Model:SetAttribute("HeadPosition", self.Position)
	
	self:monitorProgress(dt)
end

-- === LOOPS ===
local brainUpdateCounter = 0
AISnake._movementConnection = RunService.Heartbeat:Connect(function(dt)
	local snakes = AISnake._activeSnakes
	brainUpdateCounter = brainUpdateCounter + 1
	if brainUpdateCounter >= 30 then
		brainUpdateCounter = 0
		for _, snake in ipairs(snakes) do
			if snake._active then snake:updateBrain() end
		end
	end
	for _, snake in ipairs(snakes) do
		if snake._active then snake:updateMovement(dt) end
	end
end)

AISnake._spatialConnection = RunService.Stepped:Connect(function(t, dt)
	if #AISnake._activeSnakes == 0 then return end
	SpatialGrid.Clear()
	for _, snake in ipairs(AISnake._activeSnakes) do
		if snake._active and snake.HeadParts.head then
			SpatialGrid.Insert(snake.HeadParts.head, snake, "AI_HEAD")
			if snake.Segments then
				for i = 1, snake.visibleSegmentCount, 4 do
					local seg = snake.Segments[i]
					if seg then SpatialGrid.Insert(seg, snake, "AI_SEGMENT") end
				end
			end
		end
	end
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			local head = player.Character:FindFirstChild("HumanoidRootPart")
			if head then SpatialGrid.Insert(head, player, "PLAYER_HEAD") end
			for _, part in ipairs(player.Character:GetChildren()) do
				if part.Name:match("Segment") then SpatialGrid.Insert(part, player, "PLAYER_SEGMENT") end
			end
		end
	end
end)

return AISnake