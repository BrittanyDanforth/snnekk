-- ClientAISnakeLOD v5.0 – Cinematic-quality streaming for massive snakes

local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ==================================
-- GLOBAL SETTINGS
-- ==================================
local MAX_VISIBLE_SNAKES = 220
local MAX_STREAM_DISTANCE = 1800
local HEARTBEAT_SAMPLE = 1 / 30
local TRANSPARENCY_LERP = 0.18

local LOD_PROFILES = {
	{distance = 200, stride = 1, fade = 1.0, beamFade = 1.0, maxSegments = math.huge, headFocus = 12},
	{distance = 400, stride = 2, fade = 0.92, beamFade = 0.85, maxSegments = 400, headFocus = 10},
	{distance = 650, stride = 3, fade = 0.75, beamFade = 0.65, maxSegments = 250, headFocus = 8},
	{distance = 900, stride = 5, fade = 0.55, beamFade = 0.45, maxSegments = 150, headFocus = 6},
	{distance = 1200, stride = 7, fade = 0.35, beamFade = 0.25, maxSegments = 100, headFocus = 4},
	{distance = 1500, stride = 12, fade = 0.18, beamFade = 0.12, maxSegments = 60, headFocus = 3},
}

local HIDDEN_PROFILE = {distance = math.huge, stride = math.huge, fade = 0, beamFade = 0, maxSegments = 0, headFocus = 0, forceHide = true}

local function getLodProfile(distance)
	for _, profile in ipairs(LOD_PROFILES) do
		if distance <= profile.distance then
			return profile
		end
	end
	return HIDDEN_PROFILE
end

local function lerpNumber(current, target, alpha)
	return current + (target - current) * alpha
end

local function smoothVisibility(distance, isHead)
	if distance <= 150 then
		return 1
	elseif distance >= 1200 then
		return isHead and 0.2 or 0
	else
		local alpha = (distance - 150) / (1200 - 150)
		local eased = alpha * alpha * (3 - 2 * alpha)
		local value = 1 - eased
		return isHead and math.max(0.2, value) or value
	end
end

local ClientSnake = {}
ClientSnake.__index = ClientSnake

function ClientSnake.new(model)
	local self = setmetatable({}, ClientSnake)
	self.model = model
	self.head = nil
	self.segments = {}
	self.segmentOrder = {}
	self.segmentState = {}
	self.beams = {}
	self.beamBaseWidths = {}
	self.glows = {}
	self.eyes = {}
	self.lastDistance = math.huge
	self.accumulator = 0
	self.lodProfile = HIDDEN_PROFILE
	self.dead = false

	self:_hydrate()
	return self
end

function ClientSnake:_resolveHead()
	return self.model:FindFirstChild("Segment0_Head") or self.model:FindFirstChild("Head")
end

function ClientSnake:_hydrate()
	self.head = self:_resolveHead()
	if not self.head then
		return
	end

	self.beams = {}
	self.beamBaseWidths = {}

	-- Check Head for Beam 0
	local headBeam = self.head:FindFirstChild("Beam0")
	if headBeam then
		self.beams[0] = headBeam
		self.beamBaseWidths[0] = {Width0 = headBeam.Width0, Width1 = headBeam.Width1}
	end

	local parts = {}
	for _, child in ipairs(self.model:GetChildren()) do
		if child:IsA("BasePart") and child.Name:match("^Segment") then
			local index = tonumber(child.Name:match("%d+"))
			if index then
				parts[#parts + 1] = {index = index, part = child}

				-- Check Segment for Beam
				local beam = child:FindFirstChild("Beam" .. index)
				if beam then
					self.beams[index] = beam
					self.beamBaseWidths[index] = {Width0 = beam.Width0, Width1 = beam.Width1}
				end
			end
		end
	end
	table.sort(parts, function(a, b)
		return a.index < b.index
	end)

	for _, info in ipairs(parts) do
		self.segments[info.index] = info.part
		self.segmentOrder[#self.segmentOrder + 1] = info.index
		self.segmentState[info.index] = {
			current = 1,
			target = 1,
		}
		local glow = info.part:FindFirstChild("Glow")
		if glow then
			self.glows[info.index] = glow
		end
	end

	self.eyes = {}
	for _, name in ipairs({"LeftEye", "RightEye", "LeftEyePupil", "RightEyePupil"}) do
		local eye = self.model:FindFirstChild(name)
		if eye then
			table.insert(self.eyes, eye)
		end
	end
end

function ClientSnake:_setInvisible()
	for _, index in ipairs(self.segmentOrder) do
		local seg = self.segments[index]
		if seg then
			seg.Transparency = 1
		end
		local state = self.segmentState[index]
		if state then
			state.current = 1
			state.target = 1
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

function ClientSnake:_applySegmentVisibility(cameraPos)
	local headPos = self.head.Position
	local distance = (cameraPos - headPos).Magnitude
	self.lastDistance = distance

	if not self.head.Parent or distance > MAX_STREAM_DISTANCE then
		self.lodProfile = HIDDEN_PROFILE
		self:_setInvisible()
		return
	end

	local profile = getLodProfile(distance)
	self.lodProfile = profile

	local visibleBudget = profile.maxSegments
	local stride = profile.stride
	local headFocus = profile.headFocus
	local processed = 0

	for orderIndex, segmentIndex in ipairs(self.segmentOrder) do
		local seg = self.segments[segmentIndex]
		if not seg or not seg.Parent then
			continue
		end

		local isHead = segmentIndex <= headFocus
		local renderSlot = (orderIndex % stride == 0) or isHead

		if profile.forceHide then
			renderSlot = false
		elseif renderSlot then
			processed += 1
			if processed > visibleBudget then
				renderSlot = false
			end
		end

		local state = self.segmentState[segmentIndex]
		if not state then
			state = {current = 1, target = 1}
			self.segmentState[segmentIndex] = state
		end

		local targetAlpha = 0
		if renderSlot then
			local distanceAlpha = smoothVisibility((cameraPos - seg.Position).Magnitude, segmentIndex == 0)
			targetAlpha = distanceAlpha * profile.fade
		end

		state.target = 1 - targetAlpha
		state.current = lerpNumber(state.current, state.target, TRANSPARENCY_LERP)
		seg.Transparency = state.current

		local glow = self.glows[segmentIndex]
		if glow then
			if targetAlpha <= 0.05 then
				glow.Enabled = false
			else
				glow.Enabled = true
				glow.Brightness = 1.5 * targetAlpha
				glow.Range = 12 * targetAlpha
			end
		end

		local beam = self.beams[segmentIndex]
		if beam then
			local base = self.beamBaseWidths[segmentIndex]
			if base then
				local widthMultiplier = 0.5 + targetAlpha * 0.5
				beam.Width0 = base.Width0 * widthMultiplier
				beam.Width1 = base.Width1 * widthMultiplier
			end
			beam.Transparency = NumberSequence.new(1 - (targetAlpha * profile.beamFade))
		end
	end

	for _, eye in ipairs(self.eyes) do
		eye.Transparency = lerpNumber(eye.Transparency, 1 - profile.fade, 0.25)
	end
end

function ClientSnake:step(dt, cameraPos)
	if self.dead then
		return
	end

	if not self.head or not self.head.Parent then
		self.head = self:_resolveHead()
		if not self.head then
			self:_setInvisible()
			return
		end
	end

	self.accumulator += dt
	if self.accumulator < HEARTBEAT_SAMPLE then
		return
	end
	self.accumulator = 0

	self:_applySegmentVisibility(cameraPos)
end

function ClientSnake:destroy()
	self.dead = true
	self:_setInvisible()
	for k in pairs(self) do
		self[k] = nil
	end
end

-- ==================================
-- Snake Manager
-- ==================================
local SnakeManager = {}
SnakeManager.__index = SnakeManager

function SnakeManager.new()
	return setmetatable({
		tracked = {},
		sorted = {},
		lastSort = 0,
	}, SnakeManager)
end

function SnakeManager:_track(model)
	if self.tracked[model] then
		return
	end

	local snake = ClientSnake.new(model)
	if not snake.head then
		local connection
		connection = model.ChildAdded:Connect(function(child)
			if child.Name == "Segment0_Head" or child.Name == "Head" then
				connection:Disconnect()
				self:_track(model)
			end
		end)
		task.delay(5, function()
			if connection.Connected then
				connection:Disconnect()
			end
		end)
		return
	end

	self.tracked[model] = snake
	table.insert(self.sorted, snake)
end

function SnakeManager:_untrack(model)
	local snake = self.tracked[model]
	if not snake then
		return
	end

	snake:destroy()
	self.tracked[model] = nil

	for i = #self.sorted, 1, -1 do
		if self.sorted[i] == snake then
			table.remove(self.sorted, i)
			break
		end
	end
end

function SnakeManager:_resort()
	local cameraPos = camera.CFrame.Position
	table.sort(self.sorted, function(a, b)
		return a.lastDistance < b.lastDistance
	end)

	for i = MAX_VISIBLE_SNAKES + 1, #self.sorted do
		self.sorted[i]:_setInvisible()
	end
end

function SnakeManager:start()
	for _, model in ipairs(CollectionService:GetTagged("AISnake")) do
		self:_track(model)
	end

	CollectionService:GetInstanceAddedSignal("AISnake"):Connect(function(model)
		self:_track(model)
	end)

	CollectionService:GetInstanceRemovedSignal("AISnake"):Connect(function(model)
		self:_untrack(model)
	end)

	RunService.Heartbeat:Connect(function(dt)
		self:update(dt)
	end)
end

function SnakeManager:update(dt)
	local cameraPos = camera.CFrame.Position

	for model, snake in pairs(self.tracked) do
		if not model.Parent then
			self:_untrack(model)
		else
			snake:step(dt, cameraPos)
		end
	end

	self.lastSort += dt
	if self.lastSort >= 0.5 then
		self.lastSort = 0
		self:_resort()
	end
end

local manager = SnakeManager.new()
manager:start()

print("🐍 ClientAISnakeLOD v5.0 initialized – ultra-smooth streaming engaged.")