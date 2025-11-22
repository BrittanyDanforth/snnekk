-- ClientAISnakeLOD v6.0 – Triple AAA Polish & Fixes
-- Now supports beams parented to segments (no BeamHolder)
-- Uses LocalTransparencyModifier to avoid server fighting
-- Hard beam cutoff for clean distance rendering

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
local BEAM_CUTOFF_DIST = 1500 -- Increased to match fade-out distance

local LOD_PROFILES = {
	{distance = 200, stride = 1, fade = 1.0, beamFade = 1.0, maxSegments = math.huge, headFocus = 12},
	{distance = 400, stride = 2, fade = 0.92, beamFade = 0.85, maxSegments = 400, headFocus = 10},
	{distance = 650, stride = 3, fade = 0.75, beamFade = 0.65, maxSegments = 250, headFocus = 8},
	{distance = 900, stride = 5, fade = 0.55, beamFade = 0.45, maxSegments = 150, headFocus = 6},
	{distance = 1200, stride = 7, fade = 0.35, beamFade = 0.25, maxSegments = 100, headFocus = 4},
	{distance = 1500, stride = 12, fade = 0.15, beamFade = 0.0, maxSegments = 60, headFocus = 3},
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
	self.culled = false

	self:_hydrate()
	return self
end

function ClientSnake:_onChildAdded(child)
	if self.dead then return end

	-- New segment
	if child:IsA("BasePart") and (child.Name:match("^AISegment") or child.Name:match("^Segment")) then
		-- Init invisible to prevent flash
		child.LocalTransparencyModifier = 1

		local index = tonumber(child.Name:match("%d+"))
		if index and not self.segments[index] then
			self.segments[index] = child
			table.insert(self.segmentOrder, index)
			table.sort(self.segmentOrder)

			self.segmentState[index] = {current = 1, target = 1}

			local glow = child:FindFirstChild("Glow")
			if glow then
				self.glows[index] = glow
			end

			-- Any beams added under this segment
			for _, b in ipairs(child:GetChildren()) do
				if b:IsA("Beam") then
					local beamIdx = tonumber(b.Name:match("%d+"))
					if beamIdx then
						self.beams[beamIdx] = b
						self.beamBaseWidths[beamIdx] = {
							Width0 = b.Width0,
							Width1 = b.Width1,
						}
					end
				end
			end
		end

		-- Beam added later (usually on head or previous segment)
	elseif child:IsA("Beam") then
		local beamIdx = tonumber(child.Name:match("%d+"))
		if beamIdx then
			self.beams[beamIdx] = child
			self.beamBaseWidths[beamIdx] = {
				Width0 = child.Width0,
				Width1 = child.Width1,
			}
		end
	end
end

function ClientSnake:_resolveHead()
	return self.model:FindFirstChild("Head") or self.model:FindFirstChild("Segment0_Head")
end

function ClientSnake:_hydrate()
	self.head = self:_resolveHead()
	if not self.head then
		return
	end

	self.segments = {}
	self.segmentOrder = {}
	self.segmentState = {}
	self.glows = {}
	self.beams = {}
	self.beamBaseWidths = {}

	-- 1. Find Segments (AISegment%d+)
	local parts = {}
	for _, child in ipairs(self.model:GetChildren()) do
		if child:IsA("BasePart") and (child.Name:match("^AISegment") or child.Name:match("^Segment")) then
			local index = tonumber(child.Name:match("%d+"))
			if index then
				parts[#parts + 1] = {index = index, part = child}
			end
		end
	end
	table.sort(parts, function(a, b)
		return a.index < b.index
	end)

	-- 2. Populate Segments and find Beams inside them
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

		-- Find beam (Beam{index}) inside Segment{index}
		-- Let's look for ANY beam inside the part and index it by name
		for _, child in ipairs(info.part:GetChildren()) do
			if child:IsA("Beam") then
				local beamIdx = tonumber(child.Name:match("%d+"))
				if beamIdx then
					self.beams[beamIdx] = child
					self.beamBaseWidths[beamIdx] = {Width0 = child.Width0, Width1 = child.Width1}
				end
			end
		end
	end

	-- 3. Find Beams inside Head (Beam0 usually)
	for _, child in ipairs(self.head:GetChildren()) do
		if child:IsA("Beam") then
			local beamIdx = tonumber(child.Name:match("%d+"))
			if beamIdx then
				self.beams[beamIdx] = child
				self.beamBaseWidths[beamIdx] = {Width0 = child.Width0, Width1 = child.Width1}
			end
		end
	end

	self.eyes = {}
	for _, name in ipairs({"LeftEye", "RightEye", "LeftEyePupil", "RightEyePupil"}) do
		local eye = self.model:FindFirstChild(name)
		if eye then
			table.insert(self.eyes, eye)
		end
	end

	if not self._childConn then
		self._childConn = self.model.ChildAdded:Connect(function(child)
			self:_onChildAdded(child)
		end)
	end
end

function ClientSnake:_setInvisible()
	if self.head then
		self.head.LocalTransparencyModifier = 1
		local headGlow = self.head:FindFirstChild("Glow")
		if headGlow then
			headGlow.Enabled = false
		end
	end

	for _, index in ipairs(self.segmentOrder) do
		local seg = self.segments[index]
		if seg then
			seg.LocalTransparencyModifier = 1
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
		beam.Enabled = false
		beam.Transparency = NumberSequence.new(1)
	end

	for _, eye in ipairs(self.eyes) do
		eye.LocalTransparencyModifier = 1
	end
end

function ClientSnake:_applySegmentVisibility(cameraPos)
	local distance = self.lastDistance or (cameraPos - self.head.Position).Magnitude

	-- Fully hide if too far or head missing
	if not self.head.Parent or distance > MAX_STREAM_DISTANCE then
		self.lodProfile = HIDDEN_PROFILE
		self:_setInvisible()
		return
	end

	local profile = getLodProfile(distance)
	self.lodProfile = profile

	-- Head fade
	local headAlpha = smoothVisibility(distance, true) * profile.fade
	self.head.LocalTransparencyModifier = 1 - headAlpha

	-- Global flag: once we’re far enough, NO beams at all
	local hideAllBeams = (distance > BEAM_CUTOFF_DIST) or profile.forceHide

	local visibleBudget = profile.maxSegments
	local stride = profile.stride
	local headFocus = profile.headFocus
	local processed = 0

	for orderIndex, segmentIndex in ipairs(self.segmentOrder) do
		local seg = self.segments[segmentIndex]
		if not seg or not seg.Parent then
			continue
		end

		local isHeadSegment = segmentIndex <= headFocus

		-- Decide if this segment is even considered for rendering
		local renderSlot = (orderIndex % stride == 0) or isHeadSegment
		if profile.forceHide then
			renderSlot = false
		elseif renderSlot then
			processed += 1
			if processed > visibleBudget then
				renderSlot = false
			end
		end

		-- Get state (for smooth lerp)
		local state = self.segmentState[segmentIndex]
		if not state then
			state = {current = 1, target = 1}
			self.segmentState[segmentIndex] = state
		end

		-- Target visibility for this segment (0 = invisible, 1 = fully visible)
		local targetAlpha = 0
		if renderSlot then
			local segDist = (cameraPos - seg.Position).Magnitude
			local distanceAlpha = smoothVisibility(segDist, isHeadSegment)
			targetAlpha = distanceAlpha * profile.fade
		end

		-- SEGMENTS: fade via local modifier so we don’t fight server transparency
		state.target = 1 - targetAlpha
		state.current = lerpNumber(state.current, state.target, TRANSPARENCY_LERP)
		state.current = math.clamp(state.current, 0, 1)
		seg.LocalTransparencyModifier = state.current

		-- GLOW: follow segment visibility
		local glow = self.glows[segmentIndex]
		if glow then
			if targetAlpha <= 0.05 or profile.forceHide then
				glow.Enabled = false
			else
				glow.Enabled = true
				glow.Brightness = 1.5 * targetAlpha
				glow.Range = 12 * targetAlpha
			end
		end

		-- BEAMS: NEVER more visible than their segment, and hard cut at distance
		local beam = self.beams[segmentIndex]
		if beam then
			if hideAllBeams or targetAlpha <= 0.02 then
				beam.Enabled = false
				beam.Transparency = NumberSequence.new(1)
			else
				beam.Enabled = true

				local base = self.beamBaseWidths[segmentIndex]
				if base then
					local widthMultiplier = 0.5 + (targetAlpha * profile.beamFade)
					beam.Width0 = base.Width0 * widthMultiplier
					beam.Width1 = base.Width1 * widthMultiplier
				end

				local beamAlpha = math.clamp(targetAlpha * profile.beamFade, 0, 1)
				beam.Transparency = NumberSequence.new(1 - beamAlpha)
			end
		end
	end

	-- HEAD BEAM (Beam0) – it wasn’t LOD’d before
	local headBeam = self.beams[0]
	if headBeam then
		-- Re-use headAlpha (calculated above)
		if hideAllBeams or headAlpha <= 0.05 or profile.forceHide then
			headBeam.Enabled = false
			headBeam.Transparency = NumberSequence.new(1)
		else
			headBeam.Enabled = true
			local base = self.beamBaseWidths[0]
			if base then
				local widthMult = 0.5 + (headAlpha * profile.beamFade)
				headBeam.Width0 = base.Width0 * widthMult
				headBeam.Width1 = base.Width1 * widthMult
			end
			local beamAlpha0 = math.clamp(headAlpha * profile.beamFade, 0, 1)
			headBeam.Transparency = NumberSequence.new(1 - beamAlpha0)
		end
	end

	-- Eyes: just fade with overall profile
	for _, eye in ipairs(self.eyes) do
		eye.LocalTransparencyModifier = lerpNumber(eye.LocalTransparencyModifier or 0, 1 - profile.fade, 0.25)
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

	-- Always update distance for sorting, even if culled
	self.lastDistance = (cameraPos - self.head.Position).Magnitude

	if self.culled then
		return
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
	if self._childConn then
		self._childConn:Disconnect()
		self._childConn = nil
	end
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
			if child.Name == "Head" or child.Name == "Segment0_Head" then
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

	for i, snake in ipairs(self.sorted) do
		if i <= MAX_VISIBLE_SNAKES then
			-- Should be active
			if snake.culled then
				snake.culled = false
				-- no need to immediately fade in; next step() will handle it
			end
		else
			-- Should be culled
			if not snake.culled then
				snake.culled = true
				snake:_setInvisible()
			end
		end
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
	if self.lastSort >= 0.2 then
		self.lastSort = 0
		self:_resort()
	end
end

local manager = SnakeManager.new()
manager:start()

print("🐍 ClientAISnakeLOD v6.0 initialized – ultra-smooth streaming engaged.")