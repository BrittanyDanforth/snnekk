-- AISnake Module: POLISHED COMBINED VERSION - EXTREME AI BEHAVIOR
-- Combines best features from both versions with leaderboard integration

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

-- Constants
local SEGMENT_POOL_SIZE = 50
local MAX_SEGMENTS = 200
local BASE_SPEED = 16
local BOOST_SPEED_MULTIPLIER = 2.5
local BOOST_DURATION = 2
local BOOST_COOLDOWN = 5
local ORB_SEEK_RANGE = 150
local THREAT_DETECTION_RANGE = 100
local FLEE_RANGE = 80
local COLLISION_CHECK_DISTANCE = 25
local WALL_AVOIDANCE_DISTANCE = 30
local BOUNDARY_MARGIN = 50
local UPDATE_INTERVAL = 0.1
local SEGMENT_UPDATE_INTERVAL = 0.05

local SnakeConfig
pcall(function()
	local configModule = ReplicatedStorage:FindFirstChild("SnakeConfig")
	if configModule then
		SnakeConfig = require(configModule)
	end
end)

local DEFAULT_CONFIG = {
	BaseSpeed = BASE_SPEED,
	BoostSpeed = BASE_SPEED * BOOST_SPEED_MULTIPLIER,
	TurnSpeed = 4.5,
	SegmentGap = 3.0,
	PathSmoothness = 0.85
}

local function cloneTable(source)
	local copy = {}
	for key, value in pairs(source) do
		copy[key] = value
	end
	return copy
end

local Config = table.clone and table.clone(DEFAULT_CONFIG) or cloneTable(DEFAULT_CONFIG)
if typeof(SnakeConfig) == "table" then
	for key, value in pairs(DEFAULT_CONFIG) do
		if typeof(SnakeConfig[key]) == "number" then
			Config[key] = SnakeConfig[key]
		end
	end
end

local function sanitizeDirection(vector, fallback)
	if typeof(vector) ~= "Vector3" then
		return fallback or Vector3.new(0, 0, -1)
	end
	local flat = Vector3.new(vector.X, 0, vector.Z)
	if flat.Magnitude < 0.001 or flat.Magnitude ~= flat.Magnitude then
		if fallback then
			return sanitizeDirection(fallback)
		end
		return Vector3.new(0, 0, -1)
	end
	return flat.Unit
end

local function limitHorizontalTurn(currentDir, desiredDir, maxDegrees)
	currentDir = sanitizeDirection(currentDir, desiredDir)
	desiredDir = sanitizeDirection(desiredDir, currentDir)

	local maxAngle = math.rad(maxDegrees or 135)
	local maxDot = math.cos(maxAngle)
	local dot = math.clamp(currentDir:Dot(desiredDir), -1, 1)
	if dot >= maxDot then
		return desiredDir
	end

	local crossY = currentDir.X * desiredDir.Z - currentDir.Z * desiredDir.X
	local turnSign = crossY >= 0 and 1 or -1
	local currentYaw = math.atan2(currentDir.Z, currentDir.X)
	local limitedYaw = currentYaw + maxAngle * turnSign
	return Vector3.new(math.cos(limitedYaw), 0, math.sin(limitedYaw)).Unit
end

-- LOD Constants
local LOD_DISTANCE_NEAR = 50
local LOD_DISTANCE_MEDIUM = 150
local LOD_DISTANCE_FAR = 300

-- Personality Types (Combined from both versions)
local Personality = {
	-- From newer version
	Collector = {
		name = "Collector",
		orbSeekWeight = 1.5,
		threatAvoidanceWeight = 0.8,
		aggressionLevel = 0.3,
		speedMultiplier = 1.0,
		boostFrequency = 0.4,
		color = Color3.fromRGB(100, 200, 255)
	},
	Explorer = {
		name = "Explorer",
		orbSeekWeight = 0.8,
		threatAvoidanceWeight = 0.6,
		aggressionLevel = 0.4,
		speedMultiplier = 1.2,
		boostFrequency = 0.6,
		color = Color3.fromRGB(150, 100, 200)
	},
	Predator = {
		name = "Predator",
		orbSeekWeight = 0.6,
		threatAvoidanceWeight = 0.3,
		aggressionLevel = 1.0,
		speedMultiplier = 1.3,
		boostFrequency = 0.8,
		color = Color3.fromRGB(255, 100, 100)
	},
	Opportunist = {
		name = "Opportunist",
		orbSeekWeight = 1.2,
		threatAvoidanceWeight = 0.9,
		aggressionLevel = 0.5,
		speedMultiplier = 1.1,
		boostFrequency = 0.5,
		color = Color3.fromRGB(255, 200, 100)
	},
	Farmer = {
		name = "Farmer",
		orbSeekWeight = 1.4,
		threatAvoidanceWeight = 1.0,
		aggressionLevel = 0.2,
		speedMultiplier = 0.9,
		boostFrequency = 0.3,
		color = Color3.fromRGB(100, 255, 150)
	},
	Raider = {
		name = "Raider",
		orbSeekWeight = 0.9,
		threatAvoidanceWeight = 0.4,
		aggressionLevel = 0.9,
		speedMultiplier = 1.4,
		boostFrequency = 0.9,
		color = Color3.fromRGB(255, 150, 50)
	},
	Guardian = {
		name = "Guardian",
		orbSeekWeight = 0.7,
		threatAvoidanceWeight = 0.2,
		aggressionLevel = 0.8,
		speedMultiplier = 1.2,
		boostFrequency = 0.7,
		color = Color3.fromRGB(100, 150, 255)
	},
	Nomad = {
		name = "Nomad",
		orbSeekWeight = 0.5,
		threatAvoidanceWeight = 0.7,
		aggressionLevel = 0.3,
		speedMultiplier = 1.5,
		boostFrequency = 0.6,
		color = Color3.fromRGB(200, 200, 100)
	},
	-- From older version
	Aggressor = {
		name = "Aggressor",
		orbSeekWeight = 0.5,
		threatAvoidanceWeight = 0.2,
		aggressionLevel = 1.0,
		speedMultiplier = 1.4,
		boostFrequency = 0.9,
		color = Color3.fromRGB(255, 50, 50)
	},
	Scavenger = {
		name = "Scavenger",
		orbSeekWeight = 1.3,
		threatAvoidanceWeight = 0.9,
		aggressionLevel = 0.3,
		speedMultiplier = 0.95,
		boostFrequency = 0.4,
		color = Color3.fromRGB(150, 150, 255)
	},
	Trickster = {
		name = "Trickster",
		orbSeekWeight = 1.0,
		threatAvoidanceWeight = 0.6,
		aggressionLevel = 0.6,
		speedMultiplier = 1.3,
		boostFrequency = 0.7,
		color = Color3.fromRGB(255, 200, 50)
	},
	Coward = {
		name = "Coward",
		orbSeekWeight = 0.7,
		threatAvoidanceWeight = 1.2,
		aggressionLevel = 0.1,
		speedMultiplier = 1.1,
		boostFrequency = 0.5,
		color = Color3.fromRGB(100, 100, 255)
	},
	Hunter = {
		name = "Hunter",
		orbSeekWeight = 0.8,
		threatAvoidanceWeight = 0.4,
		aggressionLevel = 0.9,
		speedMultiplier = 1.35,
		boostFrequency = 0.85,
		color = Color3.fromRGB(200, 50, 50)
	},
	Trapper = {
		name = "Trapper",
		orbSeekWeight = 1.1,
		threatAvoidanceWeight = 0.7,
		aggressionLevel = 0.7,
		speedMultiplier = 1.15,
		boostFrequency = 0.6,
		color = Color3.fromRGB(150, 100, 200)
	},
	Assassin = {
		name = "Assassin",
		orbSeekWeight = 0.6,
		threatAvoidanceWeight = 0.3,
		aggressionLevel = 0.95,
		speedMultiplier = 1.5,
		boostFrequency = 0.95,
		color = Color3.fromRGB(100, 0, 100)
	}
}

-- State Machine
local State = {
	WANDER = "WANDER",
	FLEE = "FLEE",
	SEEK_ORB = "SEEK_ORB",
	AVOID_BOUNDARY = "AVOID_BOUNDARY",
	AVOID_WALL = "AVOID_WALL",
	COLLISION_AVOID = "COLLISION_AVOID",
	HUNT = "HUNT",
	CIRCLE = "CIRCLE"
}

-- Spatial Grid for performance
local SpatialGrid = {}
SpatialGrid.__index = SpatialGrid

function SpatialGrid.new(cellSize)
	local self = setmetatable({}, SpatialGrid)
	self.cellSize = cellSize or 50
	self.cells = {}
	return self
end

function SpatialGrid:getCellKey(position)
	local x = math.floor(position.X / self.cellSize)
	local z = math.floor(position.Z / self.cellSize)
	return tostring(x) .. "," .. tostring(z)
end

function SpatialGrid:insert(object, position)
	local key = self:getCellKey(position)
	if not self.cells[key] then
		self.cells[key] = {}
	end
	table.insert(self.cells[key], object)
end

function SpatialGrid:query(position, radius)
	local results = {}
	local minX = math.floor((position.X - radius) / self.cellSize)
	local maxX = math.floor((position.X + radius) / self.cellSize)
	local minZ = math.floor((position.Z - radius) / self.cellSize)
	local maxZ = math.floor((position.Z + radius) / self.cellSize)
	
	for x = minX, maxX do
		for z = minZ, maxZ do
			local key = tostring(x) .. "," .. tostring(z)
			if self.cells[key] then
				for _, obj in ipairs(self.cells[key]) do
					table.insert(results, obj)
				end
			end
		end
	end
	return results
end

function SpatialGrid:clear()
	self.cells = {}
end

-- Segment Pool
local SegmentPool = {}
local segmentPool = {}

local function createSegmentPart()
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Shape = Enum.PartType.Ball
	return part
end

local function getPooledSegment()
	if #segmentPool > 0 then
		return table.remove(segmentPool)
	else
		return createSegmentPart()
	end
end

local function returnSegmentToPool(segment)
	if segment and segment.Parent then
		segment:ClearAllChildren()
		segment.Parent = nil
		table.insert(segmentPool, segment)
	end
end

-- AISnake Module
local AISnake = {}
AISnake.__index = AISnake

-- Get all personality names
local personalityNames = {}
for name, _ in pairs(Personality) do
	table.insert(personalityNames, name)
end

-- Helper function to get random personality
function AISnake.getRandomPersonality()
	return personalityNames[math.random(1, #personalityNames)]
end

function AISnake.new(spawnPosition, personalityName)
	local self = setmetatable({}, AISnake)
	
	-- Personality
	local selectedPersonality = Personality[personalityName] or Personality.Collector
	self.personality = selectedPersonality
	self.personalityName = selectedPersonality.name
	
	-- Model for leaderboard integration
	self.model = Instance.new("Model")
	self.model.Name = "AISnake_" .. self.personalityName
	self.model:SetAttribute("Length", 1)
	self.model:SetAttribute("AIName", self.personalityName)
	self.model:SetAttribute("IsAI", true)
	self.model.Parent = Workspace:FindFirstChild("Snakes") or Workspace
	
	-- Core properties
	self.head = Instance.new("Part")
	self.head.Name = "Head"
	self.head.Size = Vector3.new(2, 2, 2)
	self.head.Position = spawnPosition
	self.head.Anchored = true
	self.head.CanCollide = false
	self.head.Material = Enum.Material.Neon
	self.head.BrickColor = BrickColor.new(selectedPersonality.color)
	self.head.Shape = Enum.PartType.Ball
	self.head.Parent = self.model
	
	-- Head light
	local pointLight = Instance.new("PointLight")
	pointLight.Color = selectedPersonality.color
	pointLight.Brightness = 0.5
	pointLight.Range = 10
	pointLight.Parent = self.head
	
	-- Selection box for outline
	local selectionBox = Instance.new("SelectionBox")
	selectionBox.Adornee = self.head
	selectionBox.Color3 = selectedPersonality.color
	selectionBox.Transparency = 0.5
	selectionBox.LineThickness = 0.1
	selectionBox.Parent = self.head
	
	-- Eyes
	self.leftEye = Instance.new("Part")
	self.leftEye.Name = "LeftEye"
	self.leftEye.Size = Vector3.new(0.3, 0.3, 0.3)
	self.leftEye.Material = Enum.Material.Neon
	self.leftEye.BrickColor = BrickColor.new("Bright red")
	self.leftEye.Shape = Enum.PartType.Ball
	self.leftEye.Anchored = true
	self.leftEye.CanCollide = false
	self.leftEye.Parent = self.head
	
	self.rightEye = Instance.new("Part")
	self.rightEye.Name = "RightEye"
	self.rightEye.Size = Vector3.new(0.3, 0.3, 0.3)
	self.rightEye.Material = Enum.Material.Neon
	self.rightEye.BrickColor = BrickColor.new("Bright red")
	self.rightEye.Shape = Enum.PartType.Ball
	self.rightEye.Anchored = true
	self.rightEye.CanCollide = false
	self.rightEye.Parent = self.head
	
	-- Movement
	self.position = spawnPosition
	self.velocity = Vector3.new(0, 0, 0)
	self.direction = sanitizeDirection(Vector3.new(math.random(-1, 1), 0, math.random(-1, 1)), Vector3.new(0, 0, 1))
	self.currentDirection = self.direction
	self.targetDirection = self.direction
	self.baseSpeed = (Config.BaseSpeed or BASE_SPEED) * selectedPersonality.speedMultiplier
	self.boostSpeed = Config.BoostSpeed or (self.baseSpeed * BOOST_SPEED_MULTIPLIER)
	self.turnSpeed = Config.TurnSpeed or 4.5
	self.currentSpeed = self.baseSpeed
	self.targetSpeed = self.baseSpeed
	self.smoothSpeed = self.baseSpeed
	self.segmentSpacing = math.max(Config.SegmentGap or 3.0, 1.5)
	self.pathPoints = {
		{position = self.position - self.currentDirection * self.segmentSpacing, distance = 0},
		{position = self.position, distance = self.segmentSpacing}
	}
	self.totalPathDistance = self.segmentSpacing
	self.maxPathDistance = self.segmentSpacing * (MAX_SEGMENTS + 10)
	self.lastPathPosition = self.position
	
	-- Segments
	self.segments = {}
	self.length = 1
	self.targetLength = 1
	
	-- State
	self.state = State.WANDER
	self.stateTimer = 0
	self.lastStateChange = os.clock()
	
	-- Boost
	self.isBoosting = false
	self.boostEndTime = 0
	self.lastBoostTime = 0
	
	-- AI
	self.lastUpdate = 0
	self.lastSegmentUpdate = 0
	self.targetOrb = nil
	self.nearbyThreats = {}
	self.isDead = false
	self.wanderTarget = nil
	
	-- Spatial grid reference (shared)
	if not AISnake.spatialGrid then
		AISnake.spatialGrid = SpatialGrid.new(50)
	end
	
	-- Register in spatial grid
	AISnake.spatialGrid:insert(self, self.position)
	
	-- Collision detection
	self.lastCollisionCheck = 0
	self.collisionCheckInterval = 0.05
	
	-- Update loop
	self.connection = RunService.Heartbeat:Connect(function(dt)
		if not self.isDead then
			self:update(dt)
		end
	end)
	
	return self
end

function AISnake:update(dt)
	if self.isDead then
		return
	end
	
	local currentTime = os.clock()
	
	-- Check collisions and death
	if currentTime - self.lastCollisionCheck >= self.collisionCheckInterval then
		if self:checkCollisions() then
			self:die()
			return
		end
		self.lastCollisionCheck = currentTime
	end
	
	-- Check orb collection
	self:checkOrbCollection()
	
	-- Update state machine
	if currentTime - self.lastUpdate >= UPDATE_INTERVAL then
		self:updateAI()
		self.lastUpdate = currentTime
	end
	
	-- Update movement
	self:updateMovement(dt)
	
	-- Update segments
	if currentTime - self.lastSegmentUpdate >= SEGMENT_UPDATE_INTERVAL then
		self:updateSegments(dt)
		self.lastSegmentUpdate = currentTime
	end
	
	-- Update boost
	if self.isBoosting and currentTime >= self.boostEndTime then
		self:endBoost()
	end
	
	-- Update model attributes for leaderboard
	if self.model then
		self.model:SetAttribute("Length", self.length)
		self.model:SetAttribute("AIName", self.personalityName)
	end
end

function AISnake:updateAI()
	-- Find nearby threats
	self.nearbyThreats = self:findNearbyThreats()
	
	-- State machine logic
	if #self.nearbyThreats > 0 and self.personality.threatAvoidanceWeight > 0.5 then
		local closestThreat = self.nearbyThreats[1]
		local distanceToThreat = (self.position - closestThreat.position).Magnitude
		
		if distanceToThreat < FLEE_RANGE then
			self:setState(State.FLEE)
		elseif distanceToThreat < THREAT_DETECTION_RANGE then
			self:setState(State.AVOID_BOUNDARY)
		end
	else
		-- Check boundaries
		local boundaryCheck = self:checkBoundaries()
		if boundaryCheck.needsAvoidance then
			self:setState(State.AVOID_BOUNDARY)
		else
			-- Find best orb
			self.targetOrb = self:findBestOrb()
			if self.targetOrb then
				self:setState(State.SEEK_ORB)
			else
				self:setState(State.WANDER)
			end
		end
	end
	
	-- Update target direction based on state
	self:updateTargetDirection()

	if not self.isBoosting then
		local stateSpeedMultiplier = 1
		if self.state == State.FLEE then
			stateSpeedMultiplier = 1.1
		elseif self.state == State.AVOID_BOUNDARY or self.state == State.AVOID_WALL then
			stateSpeedMultiplier = 1.05
		elseif self.state == State.SEEK_ORB then
			stateSpeedMultiplier = 1
		end
		self.targetSpeed = self.baseSpeed * stateSpeedMultiplier
	end
	
	-- Boost logic
	if not self.isBoosting and os.clock() - self.lastBoostTime >= BOOST_COOLDOWN then
		if math.random() < self.personality.boostFrequency * 0.1 then
			self:startBoost()
		end
	end
end

function AISnake:updateTargetDirection()
	local desiredDirection = Vector3.new(0, 0, 0)
	local weightSum = 0
	
	-- Priority 1: Collision avoidance (highest priority)
	local collisionDir = self:getCollisionAvoidanceDirection()
	if collisionDir and collisionDir.Magnitude > 0 then
		desiredDirection = desiredDirection + collisionDir * 3.0
		weightSum = weightSum + 3.0
	end
	
	-- Priority 2: State-based behavior
	if self.state == State.FLEE then
		local fleeDir = self:getFleeVector()
		if fleeDir.Magnitude > 0 then
			desiredDirection = desiredDirection + fleeDir * (self.personality.threatAvoidanceWeight * 2.5)
			weightSum = weightSum + (self.personality.threatAvoidanceWeight * 2.5)
		end
	elseif self.state == State.SEEK_ORB then
		if self.targetOrb and self.targetOrb.Parent then
			local toOrb = (self.targetOrb.Position - self.position)
			local distance = toOrb.Magnitude
			if distance > 0 and distance < ORB_SEEK_RANGE then
				toOrb = toOrb / distance
				desiredDirection = desiredDirection + toOrb * self.personality.orbSeekWeight
				weightSum = weightSum + self.personality.orbSeekWeight
			else
				-- Orb out of range or destroyed, clear target
				self.targetOrb = nil
			end
		end
	elseif self.state == State.AVOID_BOUNDARY then
		local boundaryCheck = self:checkBoundaries()
		if boundaryCheck.avoidDirection then
			desiredDirection = desiredDirection + boundaryCheck.avoidDirection * 2.0
			weightSum = weightSum + 2.0
		end
	elseif self.state == State.WANDER then
		-- Wander behavior with some persistence
		if not self.wanderTarget or (self.position - self.wanderTarget).Magnitude < 5 then
			local wanderAngle = math.random() * math.pi * 2
			local wanderDistance = 20 + math.random() * 30
			self.wanderTarget = self.position + Vector3.new(
				math.cos(wanderAngle) * wanderDistance,
				0,
				math.sin(wanderAngle) * wanderDistance
			)
		end
		
		if self.wanderTarget then
			local toWander = (self.wanderTarget - self.position)
			local distance = toWander.Magnitude
			if distance > 0 then
				toWander = toWander / distance
				desiredDirection = desiredDirection + toWander * 0.6
				weightSum = weightSum + 0.6
			end
		end
	end
	
	-- Normalize and smooth
	if weightSum > 0 then
		desiredDirection = desiredDirection / weightSum
		if desiredDirection.Magnitude > 0.1 then
			desiredDirection = sanitizeDirection(desiredDirection)
			local referenceDir = self.currentDirection or self.direction
			desiredDirection = limitHorizontalTurn(referenceDir, desiredDirection, 135)
			-- Smooth direction change based on speed
			local smoothFactor = self.isBoosting and 0.45 or Config.PathSmoothness
			self.targetDirection = sanitizeDirection(self.targetDirection * smoothFactor + desiredDirection * (1 - smoothFactor), desiredDirection)
		else
			-- Very small direction change, maintain current
			self.targetDirection = sanitizeDirection(self.targetDirection * 0.95 + self.direction * 0.05, self.direction)
		end
	else
		-- Default forward movement
		self.targetDirection = sanitizeDirection(self.targetDirection * 0.9 + self.direction * 0.1, self.direction)
	end
end

function AISnake:findNearbyThreats()
	local threats = {}
	local nearbySnakes = AISnake.spatialGrid:query(self.position, THREAT_DETECTION_RANGE)
	
	for _, snake in ipairs(nearbySnakes) do
		if snake ~= self and snake.length and snake.length > self.length * 0.8 then
			local distance = (snake.position - self.position).Magnitude
			if distance < THREAT_DETECTION_RANGE then
				table.insert(threats, {
					snake = snake,
					position = snake.position,
					distance = distance
				})
			end
		end
	end
	
	-- Also check player snakes
	local snakesFolder = Workspace:FindFirstChild("Snakes")
	if snakesFolder then
		for _, snakeModel in ipairs(snakesFolder:GetChildren()) do
			if snakeModel ~= self.model and snakeModel:FindFirstChild("Head") then
				local head = snakeModel.Head
				local distance = (head.Position - self.position).Magnitude
				if distance < THREAT_DETECTION_RANGE then
					local snakeLength = snakeModel:GetAttribute("Length") or 1
					if snakeLength > self.length * 0.8 then
						table.insert(threats, {
							snake = snakeModel,
							position = head.Position,
							distance = distance
						})
					end
				end
			end
		end
	end
	
	-- Sort by distance
	table.sort(threats, function(a, b)
		return a.distance < b.distance
	end)
	
	return threats
end

function AISnake:findBestOrb()
	local bestOrb = nil
	local bestScore = -math.huge
	local orbsFolder = Workspace:FindFirstChild("Orbs")
	
	if not orbsFolder then
		return nil
	end
	
	for _, orb in ipairs(orbsFolder:GetChildren()) do
		if orb:IsA("BasePart") then
			local distance = (orb.Position - self.position).Magnitude
			if distance < ORB_SEEK_RANGE then
				-- Check if path is safe
				if self:isPathSafe(orb.Position) then
					local score = 1 / (distance + 1) -- Closer = better
					-- Prefer orbs that are not near threats
					for _, threat in ipairs(self.nearbyThreats) do
						local threatDistance = (threat.position - orb.Position).Magnitude
						if threatDistance < 30 then
							score = score * 0.3 -- Penalize dangerous orbs
						end
					end
					
					if score > bestScore then
						bestScore = score
						bestOrb = orb
					end
				end
			end
		end
	end
	
	return bestOrb
end

function AISnake:isPathSafe(targetPosition)
	local direction = (targetPosition - self.position)
	local distance = direction.Magnitude
	if distance == 0 then return true end
	
	direction = direction / distance
	local checkDistance = math.min(distance, COLLISION_CHECK_DISTANCE)
	local checkPosition = self.position + direction * checkDistance
	
	-- Check for walls
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.FilterDescendantsInstances = {self.model}
	
	local raycast = Workspace:Raycast(self.position, direction * checkDistance, rayParams)
	if raycast then
		return false
	end
	
	-- Check for nearby threats along path
	for _, threat in ipairs(self.nearbyThreats) do
		local threatDistance = (threat.position - checkPosition).Magnitude
		if threatDistance < 20 then
			return false
		end
	end
	
	return true
end

function AISnake:getFleeVector()
	if #self.nearbyThreats == 0 then
		return Vector3.new(0, 0, 0)
	end
	
	local fleeDirection = Vector3.new(0, 0, 0)
	
	for _, threat in ipairs(self.nearbyThreats) do
		local awayFromThreat = (self.position - threat.position)
		local distance = awayFromThreat.Magnitude
		if distance > 0 then
			awayFromThreat = awayFromThreat / distance
			local weight = 1 / (distance + 1)
			fleeDirection = fleeDirection + awayFromThreat * weight
		end
	end
	
	if fleeDirection.Magnitude > 0 then
		fleeDirection = fleeDirection.Unit
	end
	
	return fleeDirection
end

function AISnake:getCollisionAvoidanceDirection()
	local avoidanceDir = Vector3.new(0, 0, 0)
	local checkDistance = COLLISION_CHECK_DISTANCE
	
	-- Check forward
	local forwardCheck = self.position + self.direction * checkDistance
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.FilterDescendantsInstances = {self.model}
	
	local forwardRay = Workspace:Raycast(self.position, self.direction * checkDistance, rayParams)
	if forwardRay then
		local normal = forwardRay.Normal
		avoidanceDir = avoidanceDir + Vector3.new(normal.X, 0, normal.Z) * 2.0
	end
	
	-- Check left and right
	local rightDir = Vector3.new(-self.direction.Z, 0, self.direction.X)
	local leftDir = -rightDir
	
	local rightRay = Workspace:Raycast(self.position, rightDir * (checkDistance * 0.5), rayParams)
	if rightRay then
		avoidanceDir = avoidanceDir + leftDir * 1.0
	end
	
	local leftRay = Workspace:Raycast(self.position, leftDir * (checkDistance * 0.5), rayParams)
	if leftRay then
		avoidanceDir = avoidanceDir + rightDir * 1.0
	end
	
	if avoidanceDir.Magnitude > 0 then
		avoidanceDir = avoidanceDir.Unit
	end
	
	return avoidanceDir
end

function AISnake:checkBoundaries()
	local camera = Workspace.CurrentCamera
	if not camera then
		return {needsAvoidance = false}
	end
	
	local cameraCFrame = camera.CFrame
	local cameraPosition = cameraCFrame.Position
	local viewportSize = camera.ViewportSize
	
	-- Estimate boundary (simplified - adjust based on your game's boundary system)
	local boundarySize = 500 -- Adjust to match your game
	local margin = BOUNDARY_MARGIN
	
	local needsAvoidance = false
	local avoidDirection = nil
	
	if math.abs(self.position.X - cameraPosition.X) > boundarySize - margin then
		needsAvoidance = true
		avoidDirection = Vector3.new(
			(cameraPosition.X - self.position.X) > 0 and 1 or -1,
			0,
			0
		)
	elseif math.abs(self.position.Z - cameraPosition.Z) > boundarySize - margin then
		needsAvoidance = true
		avoidDirection = Vector3.new(
			0,
			0,
			(cameraPosition.Z - self.position.Z) > 0 and 1 or -1
		)
	end
	
	return {
		needsAvoidance = needsAvoidance,
		avoidDirection = avoidDirection
	}
end

function AISnake:setState(newState)
	if self.state ~= newState then
		self.state = newState
		self.lastStateChange = os.clock()
		self.stateTimer = 0
	end
end

function AISnake:updateMovement(dt)
	if dt <= 0 then
		return
	end

	local desiredDir = sanitizeDirection(self.targetDirection, self.currentDirection or self.direction)
	desiredDir = limitHorizontalTurn(self.currentDirection or self.direction, desiredDir, 135)

	local turnRate = math.clamp((self.turnSpeed or Config.TurnSpeed) * dt, 0, 1)
	local blended = self.currentDirection:Lerp(desiredDir, turnRate)
	if blended.Magnitude > 0.001 then
		self.currentDirection = blended.Unit
	end
	self.direction = self.currentDirection

	if self.isBoosting then
		self.targetSpeed = self.boostSpeed
	end

	local accelRate = math.clamp(dt * 6, 0, 1)
	self.smoothSpeed = self.smoothSpeed + (self.targetSpeed - self.smoothSpeed) * accelRate
	self.currentSpeed = self.smoothSpeed

	self.velocity = self.direction * self.currentSpeed
	self.position = self.position + self.velocity * dt
	self:_recordPathPoint(self.position)
	
	-- Update head
	self.head.Position = self.position
	self.head.CFrame = CFrame.lookAt(self.position, self.position + self.direction)
	
	-- Update eyes
	if self.leftEye and self.rightEye then
		local eyeOffset = 0.4
		local lookDirection = self.direction
		local rightVector = Vector3.new(-lookDirection.Z, 0, lookDirection.X)
		local upVector = Vector3.new(0, 1, 0)
		local leftEyePos = self.position + rightVector * -eyeOffset + upVector * 0.3
		local rightEyePos = self.position + rightVector * eyeOffset + upVector * 0.3
		self.leftEye.Position = leftEyePos
		self.rightEye.Position = rightEyePos
	end
	
	-- Update spatial grid
	AISnake.spatialGrid:insert(self, self.position)
end

function AISnake:_recordPathPoint(newPosition)
	if not self.pathPoints then
		self.pathPoints = {{position = newPosition, distance = 0}}
		self.totalPathDistance = 0
		self.lastPathPosition = newPosition
	end

	local delta = (newPosition - self.lastPathPosition).Magnitude
	if delta < 0.001 then
		local lastEntry = self.pathPoints[#self.pathPoints]
		if lastEntry then
			lastEntry.position = newPosition
			lastEntry.distance = self.totalPathDistance or 0
		end
		return
	end

	self.totalPathDistance = (self.totalPathDistance or 0) + delta
	table.insert(self.pathPoints, {position = newPosition, distance = self.totalPathDistance})
	self.lastPathPosition = newPosition

	local maxDistance = self.maxPathDistance or (self.segmentSpacing * (MAX_SEGMENTS + 10))
	while #self.pathPoints > 2 and self.totalPathDistance - self.pathPoints[1].distance > maxDistance do
		table.remove(self.pathPoints, 1)
	end
end

function AISnake:_samplePath(distanceBehind)
	if not self.pathPoints or #self.pathPoints == 0 then
		return self.position
	end

	local history = self.pathPoints
	local totalDistance = self.totalPathDistance or 0
	local targetDistance = totalDistance - distanceBehind

	if targetDistance <= history[1].distance then
		return history[1].position
	end

	for idx = #history, 2, -1 do
		local prev = history[idx - 1]
		local curr = history[idx]
		if targetDistance >= prev.distance then
			local span = curr.distance - prev.distance
			local alpha = span > 0 and (targetDistance - prev.distance) / span or 0
			return prev.position:Lerp(curr.position, alpha)
		end
	end

	return history[1].position
end

function AISnake:updateSegments(dt)
	local desiredSegments = math.min(self.targetLength, MAX_SEGMENTS)

	while #self.segments < desiredSegments do
		self:grow()
	end

	while #self.segments > desiredSegments do
		local lastSegment = table.remove(self.segments)
		if lastSegment then
			returnSegmentToPool(lastSegment)
		end
	end

	if not self.pathPoints or #self.pathPoints < 2 then
		self.length = #self.segments
		return
	end

	local totalDistance = self.totalPathDistance or 0
	local history = self.pathPoints
	local historyIndex = #history
	local followAlpha = self.isBoosting and 0.35 or 0.5

	for i, segment in ipairs(self.segments) do
		local targetDistance = totalDistance - (i * self.segmentSpacing)
		local targetPos

		if targetDistance <= history[1].distance then
			targetPos = history[1].position
		else
			while historyIndex > 1 and targetDistance < history[historyIndex - 1].distance do
				historyIndex -= 1
			end

			if historyIndex < 2 then
				historyIndex = 2
			end

			local newer = history[historyIndex]
			local older = history[historyIndex - 1]
			local span = newer.distance - older.distance
			local alpha = span > 0 and (targetDistance - older.distance) / span or 0
			targetPos = older.position:Lerp(newer.position, alpha)
		end

		if segment and segment.Parent and targetPos then
			if segment.Position.Magnitude == segment.Position.Magnitude then
				segment.Position = segment.Position:Lerp(targetPos, followAlpha)
			else
				segment.Position = targetPos
			end
		end
	end

	self.length = #self.segments
end

function AISnake:grow()
	local newSegment = getPooledSegment()
	newSegment.Size = self:getSegmentSize()
	newSegment.BrickColor = BrickColor.new(self.personality.color)
	newSegment.Parent = self.model
	
	-- Add beam between segments
	if #self.segments > 0 then
		local prevSegment = self.segments[#self.segments]
		local attachment0 = Instance.new("Attachment")
		attachment0.Parent = prevSegment
		local attachment1 = Instance.new("Attachment")
		attachment1.Parent = newSegment
		
		local beam = Instance.new("Beam")
		beam.Attachment0 = attachment0
		beam.Attachment1 = attachment1
		beam.Color = ColorSequence.new(self.personality.color)
		beam.Transparency = NumberSequence.new(0.3)
		beam.Width0 = self:getBeamWidth()
		beam.Width1 = self:getBeamWidth()
		beam.Parent = prevSegment
	end
	
	table.insert(self.segments, newSegment)
	
	-- Set initial position
	local spawnDistance = (#self.segments + 1) * self.segmentSpacing
	newSegment.Position = self:_samplePath(spawnDistance) or self.position
end

function AISnake:getSegmentSize()
	local baseSize = 1.5
	local growthFactor = self:calculateGrowthFactor()
	return Vector3.new(baseSize * growthFactor, baseSize * growthFactor, baseSize * growthFactor)
end

function AISnake:calculateGrowthFactor()
	-- Segments get slightly smaller towards the tail
	return 0.9 + (self.length / MAX_SEGMENTS) * 0.1
end

function AISnake:getBeamWidth()
	return 0.3 + (self.length / MAX_SEGMENTS) * 0.2
end

function AISnake:startBoost()
	if self.isBoosting or os.clock() - self.lastBoostTime < BOOST_COOLDOWN then
		return
	end
	
	self.isBoosting = true
	self.targetSpeed = self.boostSpeed
	self.boostEndTime = os.clock() + BOOST_DURATION
	self.lastBoostTime = os.clock()
	
	-- Boost particles
	local particles = Instance.new("ParticleEmitter")
	particles.Parent = self.head
	particles.Texture = "rbxasset://textures/particles/smoke_main.dds"
	particles.Color = ColorSequence.new(self.personality.color)
	particles.Size = NumberSequence.new(0.5)
	particles.Lifetime = NumberRange.new(0.5)
	particles.Rate = 50
	particles.Speed = NumberRange.new(5)
	
	task.delay(BOOST_DURATION, function()
		if particles and particles.Parent then
			particles:Destroy()
		end
	end)
end

function AISnake:endBoost()
	self.isBoosting = false
	self.targetSpeed = self.baseSpeed
end

function AISnake:checkCollisions()
	-- Check collision with other snakes (head collision)
	local snakesFolder = Workspace:FindFirstChild("Snakes")
	if snakesFolder then
		for _, snakeModel in ipairs(snakesFolder:GetChildren()) do
			if snakeModel ~= self.model and snakeModel.Parent then
				local head = snakeModel:FindFirstChild("Head")
				if head and head.Parent then
					local distance = (head.Position - self.position).Magnitude
					local collisionRadius = (self.head.Size.X + head.Size.X) * 0.5
					if distance < collisionRadius then
						-- Check if other snake is larger
						local otherLength = snakeModel:GetAttribute("Length") or 1
						if otherLength > self.length * 0.9 then
							return true -- Collision with larger snake = death
						end
					end
				end
				
				-- Check collision with body segments (more efficient check)
				if snakeModel:IsA("Model") then
					for _, part in ipairs(snakeModel:GetDescendants()) do
						if part:IsA("BasePart") and part.Name ~= "Head" and part.Name ~= "LeftEye" and part.Name ~= "RightEye" then
							local distance = (part.Position - self.position).Magnitude
							local collisionRadius = (self.head.Size.X + part.Size.X) * 0.4
							if distance < collisionRadius then
								return true -- Hit body = death
							end
						end
					end
				end
			end
		end
	end
	
	-- Check collision with own body (skip first few segments to avoid false positives)
	for i = math.max(3, math.floor(self.length * 0.1)), #self.segments do
		local segment = self.segments[i]
		if segment and segment.Parent then
			local distance = (segment.Position - self.position).Magnitude
			local collisionRadius = (self.head.Size.X + segment.Size.X) * 0.4
			if distance < collisionRadius then
				return true -- Hit own body = death
			end
		end
	end
	
	-- Check collision with walls/boundaries
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.FilterDescendantsInstances = {self.model}
	
	local checkDistance = self.head.Size.X * 0.5 + 1
	local forwardRay = Workspace:Raycast(self.position, self.direction * checkDistance, rayParams)
	if forwardRay then
		-- Check if it's a wall (not just terrain/baseplate)
		local hitPart = forwardRay.Instance
		if hitPart and hitPart.Name ~= "Baseplate" and hitPart.Name ~= "Terrain" and not hitPart:IsA("Terrain") then
			-- Additional check: if it's a solid part, it's a wall
			if hitPart.CanCollide and hitPart.Transparency < 0.5 then
				return true -- Hit wall = death
			end
		end
	end
	
	return false
end

function AISnake:checkOrbCollection()
	local orbsFolder = Workspace:FindFirstChild("Orbs")
	if not orbsFolder then
		return
	end
	
	for _, orb in ipairs(orbsFolder:GetChildren()) do
		if orb:IsA("BasePart") then
			local distance = (orb.Position - self.position).Magnitude
			if distance < 2.5 then
				-- Collect orb
				orb:Destroy()
				self.targetLength = math.min(self.targetLength + 1, MAX_SEGMENTS)
				
				-- Visual feedback
				if self.head then
					local originalSize = self.head.Size
					TweenService:Create(
						self.head,
						TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{Size = originalSize * 1.2}
					):Play()
					
					task.delay(0.1, function()
						if self.head then
							TweenService:Create(
								self.head,
								TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{Size = originalSize}
							):Play()
						end
					end)
				end
				
				break -- Only collect one orb per check
			end
		end
	end
end

function AISnake:die()
	if self.isDead then
		return
	end
	
	self.isDead = true
	
	-- Visual death effect
	if self.head then
		-- Explosion effect
		local explosion = Instance.new("Explosion")
		explosion.Position = self.position
		explosion.BlastRadius = 5
		explosion.BlastPressure = 0
		explosion.Parent = Workspace
		
		-- Fade out
		for _, part in ipairs(self.model:GetDescendants()) do
			if part:IsA("BasePart") then
				TweenService:Create(
					part,
					TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{Transparency = 1}
				):Play()
			end
		end
	end
	
	-- Clean up after delay
	task.delay(0.5, function()
		self:Destroy()
	end)
end

function AISnake:Destroy()
	-- Disconnect update loop
	if self.connection then
		self.connection:Disconnect()
		self.connection = nil
	end
	
	-- Return segments to pool
	for _, segment in ipairs(self.segments) do
		returnSegmentToPool(segment)
	end
	self.segments = {}
	
	-- Remove from spatial grid
	-- (Spatial grid will be cleared periodically or on snake death)
	
	-- Destroy model
	if self.model then
		self.model:Destroy()
		self.model = nil
	end
	
	-- Clean up
	self.head = nil
	self.leftEye = nil
	self.rightEye = nil
	self.targetOrb = nil
	self.nearbyThreats = {}
	self.wanderTarget = nil
end

-- Export
return AISnake
