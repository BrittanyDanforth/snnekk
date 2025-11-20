-- ClientAISnakeLOD v3.0: Slither.io-inspired ultra-smooth LOD system (stabilized)

local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ==================================
-- SLITHER.IO STYLE CONFIGURATION
-- ==================================
local UPDATE_RATE = 30
local UPDATE_INTERVAL = 1 / UPDATE_RATE

local FADE_START_DISTANCE = 150
local FADE_END_DISTANCE = 1200
local OUTLINE_FADE_DISTANCE = 1500

local COMPRESSION_START = 400
local MAX_COMPRESSION_RATIO = 0.3

local MAX_VISIBLE_SNAKES = 200
local VISIBILITY_CHECK_RADIUS = 1800

local FADE_SMOOTHNESS = 0.15
local GLOW_DISTANCE_MULTIPLIER = 1.2
local MIN_HEAD_VISIBILITY = 0.15

-- ==================================
-- Utility Functions
-- ==================================
local function smoothStep(edge0, edge1, x)
	x = math.clamp((x - edge0) / (edge1 - edge0), 0, 1)
	return x * x * (3 - 2 * x)
end

local function calculateSegmentVisibility(segmentDistance, isHead)
	if segmentDistance < FADE_START_DISTANCE then
		return 1
	elseif segmentDistance > FADE_END_DISTANCE then
		return isHead and MIN_HEAD_VISIBILITY or 0
	else
		local fade = smoothStep(FADE_START_DISTANCE, FADE_END_DISTANCE, segmentDistance)
		if isHead then
			return math.max(MIN_HEAD_VISIBILITY, 1 - fade)
		else
			return 1 - fade
		end
	end
end

local function calculateCompressionRatio(distance)
	if distance < COMPRESSION_START then
		return 1
	else
		local compressionFactor = smoothStep(COMPRESSION_START, FADE_END_DISTANCE, distance)
		return math.max(MAX_COMPRESSION_RATIO, 1 - compressionFactor * (1 - MAX_COMPRESSION_RATIO))
	end
end

local function getHeadPosition(model, snake)
	local attr = model:GetAttribute("HeadPosition")
	if typeof(attr) == "Vector3" then
		return attr
	elseif snake and snake.head then
		return snake.head.Position
	end
	return model:GetPivot().Position
end

-- ==================================
-- ClientSnake Class (Slither.io Style)
-- ==================================
local ClientSnake = {}
ClientSnake.__index = ClientSnake

function ClientSnake.new(model)
	local head = model:FindFirstChild("Segment0_Head")
	if not head then
		head = model:FindFirstChild("Head")
	end

	if not head then
		-- Head might not be replicated yet; defer tracking
		return nil, "no_head"
	end

	local self = setmetatable({}, ClientSnake)

	self.model = model
	self.head = head

	self.segments = {}
	self.segmentData = {}
	self.segmentOrder = {}
	self.beams = {}
	self.beamBaseWidths = {}
	self.glows = {}
	self.eyes = {}

	-- Collect segments
	local partsToSort = {}
	for _, child in ipairs(model:GetChildren()) do
		if child:IsA("BasePart") and child.Name:match("^Segment") then
			local index = tonumber(child.Name:match("%d+"))
			if index then
				table.insert(partsToSort, {index = index, part = child})
			end
		end
	end
	table.sort(partsToSort, function(a, b) return a.index < b.index end)

	for _, data in ipairs(partsToSort) do
		local part = data.part
		local index = data.index

		self.segments[index] = part
		table.insert(self.segmentOrder, index)
		self.segmentData[index] = {
			lastTransparency = 1,
			targetTransparency = 1,
			currentTransparency = 1,
		}

		local glow = part:FindFirstChild("Glow")
		if glow then
			self.glows[index] = glow
			glow.Brightness = 2
		end
	end

	self.totalLength = #self.segmentOrder

	-- Collect beams
	local beamHolder = model:FindFirstChild("BeamHolder")
	if beamHolder then
		for _, beam in ipairs(beamHolder:GetChildren()) do
			if beam:IsA("Beam") then
				local index = tonumber(beam.Name:match("%d+"))
				if index then
					self.beams[index] = beam
					self.beamBaseWidths[index] = {Width0 = beam.Width0, Width1 = beam.Width1}
				end
			end
		end
	end

	for _, name in ipairs({"LeftEye", "RightEye", "LeftEyePupil", "RightEyePupil"}) do
		local eye = model:FindFirstChild(name)
		if eye then
			table.insert(self.eyes, eye)
		end
	end

	self.lastHeadDistance = math.huge
	self.updateAccumulator = 0
	self.compressionRatio = 1

	self:SetInitialVisibility()

	return self
end

function ClientSnake:SetInitialVisibility()
	for _, index in ipairs(self.segmentOrder) do
		local segment = self.segments[index]
		if segment then
			segment.Transparency = 1
		end
		local data = self.segmentData[index]
		if data then
			data.currentTransparency = 1
			data.targetTransparency = 1
		end
		local glow = self.glows[index]
		if glow then
			glow.Enabled = false
		end
	end

	for _, beam in pairs(self.beams) do
		beam.Transparency = NumberSequence.new(1)
	end

	for _, eye in ipairs(self.eyes) do
		eye.Transparency = 1
	end
end

function ClientSnake:UpdateSegmentVisibility(dt, cameraPos)
	local headPos = getHeadPosition(self.model, self)
	local headDistance = (cameraPos - headPos).Magnitude

	if headDistance > VISIBILITY_CHECK_RADIUS then
		if self.lastHeadDistance <= VISIBILITY_CHECK_RADIUS then
			self:SetInitialVisibility()
		end
		self.lastHeadDistance = headDistance
		return
	end

	self.lastHeadDistance = headDistance
	self.compressionRatio = calculateCompressionRatio(headDistance)

	local totalSegments = math.max(1, #self.segmentOrder)
	local visibleSegmentCount = math.max(1, math.floor(totalSegments * self.compressionRatio))
	local segmentStep = totalSegments / visibleSegmentCount
	local visibleIndex = 0

	for orderIndex, segmentIndex in ipairs(self.segmentOrder) do
		local segment = self.segments[segmentIndex]
		local data = self.segmentData[segmentIndex]

		if segment and data then
			local shouldShow = true
			local compressionAlpha = 1

			if self.compressionRatio < 1 then
				local targetIndex = math.floor(visibleIndex * segmentStep) + 1
				shouldShow = (orderIndex >= targetIndex and orderIndex <= targetIndex + 1) and (visibleIndex < visibleSegmentCount)

				if shouldShow then
					local nextTargetIndex = math.floor((visibleIndex + 1) * segmentStep) + 1
					if orderIndex > targetIndex and nextTargetIndex > targetIndex then
						compressionAlpha = 1 - (orderIndex - targetIndex) / (nextTargetIndex - targetIndex)
					end
					visibleIndex = visibleIndex + 1
				end
			end

			local segmentDistance = (cameraPos - segment.Position).Magnitude
			local distanceAlpha = calculateSegmentVisibility(segmentDistance, segmentIndex == 0)
			local targetAlpha = shouldShow and (distanceAlpha * compressionAlpha) or 0
			data.targetTransparency = 1 - targetAlpha

			local diff = data.targetTransparency - data.currentTransparency
			if math.abs(diff) > 0.001 then
				data.currentTransparency += diff * FADE_SMOOTHNESS
				segment.Transparency = data.currentTransparency
				self:UpdateSegmentVisuals(segmentIndex, data.currentTransparency, segmentDistance)
			end
		end
	end
end

function ClientSnake:UpdateSegmentVisuals(index, transparency, distance)
	local beam = self.beams[index]
	if beam then
		local baseWidth = self.beamBaseWidths[index]
		if baseWidth then
			local widthMultiplier = math.max(0.5, 1 - (distance / FADE_END_DISTANCE) * 0.5)
			beam.Width0 = baseWidth.Width0 * widthMultiplier
			beam.Width1 = baseWidth.Width1 * widthMultiplier
		end

		local nextData = self.segmentData[index + 1]
		local beamTransparency = transparency
		if nextData then
			beamTransparency = (transparency + nextData.currentTransparency) / 2
		end
		beam.Transparency = NumberSequence.new(beamTransparency)
	end

	local glow = self.glows[index]
	if glow then
		local glowDistance = distance * GLOW_DISTANCE_MULTIPLIER
		local glowAlpha = calculateSegmentVisibility(glowDistance, index == 0)
		glow.Enabled = glowAlpha > 0.1
		if glow.Enabled then
			glow.Brightness = 2 * glowAlpha
			glow.Range = 15 * glowAlpha
		end
	end

	if index == 0 then
		local eyeAlpha = 1 - transparency
		for _, eye in ipairs(self.eyes) do
			eye.Transparency = math.max(0.8, 1 - eyeAlpha)
		end
	end
end

function ClientSnake:Update(dt, cameraPos)
	self.updateAccumulator += dt

	if self.updateAccumulator >= UPDATE_INTERVAL then
		self:UpdateSegmentVisibility(self.updateAccumulator, cameraPos)
		self.updateAccumulator = 0
	end
end

function ClientSnake:Destroy()
	self:SetInitialVisibility()
	for k in pairs(self) do
		self[k] = nil
	end
end

-- ==================================
-- SnakeManager (Performance Optimized)
-- ==================================
local SnakeManager = {}
local trackedSnakes = {}
local snakeArray = {}
local pendingHeadConnections = {}
local lastUpdateTime = 0

local function waitForHeadAndTrack(model)
	if pendingHeadConnections[model] then
		return
	end

	local connection
	connection = model.ChildAdded:Connect(function(child)
		if child.Name == "Segment0_Head" or child.Name == "Head" then
			connection:Disconnect()
			pendingHeadConnections[model] = nil
			SnakeManager.Track(model)
		end
	end)
	pendingHeadConnections[model] = connection

	task.delay(5, function()
		if pendingHeadConnections[model] == connection then
			connection:Disconnect()
			pendingHeadConnections[model] = nil
		end
	end)
end

function SnakeManager.Track(model)
	if trackedSnakes[model] then
		return
	end

	local snake, reason = ClientSnake.new(model)
	if not snake then
		if reason == "no_head" then
			waitForHeadAndTrack(model)
		end
		return
	end

	trackedSnakes[model] = snake
	table.insert(snakeArray, {model = model, snake = snake})
	SnakeManager.SortSnakes()
end

function SnakeManager.Untrack(model)
	if trackedSnakes[model] then
		trackedSnakes[model]:Destroy()
		trackedSnakes[model] = nil
	end

	for i = #snakeArray, 1, -1 do
		if snakeArray[i].model == model then
			table.remove(snakeArray, i)
			break
		end
	end

	if pendingHeadConnections[model] then
		pendingHeadConnections[model]:Disconnect()
		pendingHeadConnections[model] = nil
	end
end

function SnakeManager.SortSnakes()
	local cameraPos = camera.CFrame.Position
	table.sort(snakeArray, function(a, b)
		local headPosA = getHeadPosition(a.model, a.snake)
		local headPosB = getHeadPosition(b.model, b.snake)
		return (headPosA - cameraPos).Magnitude < (headPosB - cameraPos).Magnitude
	end)
end

function SnakeManager.Update()
	local currentTime = tick()
	local dt = currentTime - lastUpdateTime
	lastUpdateTime = currentTime

	local cameraPos = camera.CFrame.Position
	local processed = 0

	for i = #snakeArray, 1, -1 do
		local data = snakeArray[i]
		if not data.model or not data.model.Parent then
			SnakeManager.Untrack(data.model)
		end
	end

	for _, data in ipairs(snakeArray) do
		if data.model and data.model.Parent then
			if processed < MAX_VISIBLE_SNAKES then
				data.snake:Update(dt, cameraPos)
				processed += 1
			else
				data.snake:SetInitialVisibility()
			end
		end
	end

	if currentTime % 1 < dt then
		SnakeManager.SortSnakes()
	end
end

lastUpdateTime = tick()

for _, model in ipairs(CollectionService:GetTagged("AISnake")) do
	SnakeManager.Track(model)
end

CollectionService:GetInstanceAddedSignal("AISnake"):Connect(SnakeManager.Track)
CollectionService:GetInstanceRemovedSignal("AISnake"):Connect(SnakeManager.Untrack)
RunService.Heartbeat:Connect(SnakeManager.Update)

print("🐍 ClientAISnakeLOD v3.0: Slither.io-style ultra-smooth LOD initialized!")
print("   ✨ Distance-based fading | 🎯 Segment compression | ⚡ 30Hz updates")
