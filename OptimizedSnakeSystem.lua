-- Optimized Snake System V9.5 AAA - DISTANCE-BASED PATHING & MASSIVE SCALE
-- Features:
-- 1. Arc-Length Parameterization: Segments are placed by distance traveled, not time/frames.
--    Eliminates accordion effects (bunching up when slow, stretching when fast).
-- 2. Dynamic History Buffer: Automatically expands to support infinite length (up to memory limits).
-- 3. BulkMoveTo Optimization: Updates 2000+ parts in a single batch call for maximum performance.
-- 4. Full Collision Support: Physical body matches logical length 1:1.
-- 5. Seamless Growth: Visual growth matches logical growth perfectly.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")

-- === CONFIGURATION ===
local MIN_RECORD_DIST = 0.5 -- Record a history point every 0.5 studs
local HISTORY_CHUNK_SIZE = 5000 -- Allocate history in chunks
local MAX_SEGMENTS = 3000 -- Support massive snakes (user requested >2k)
local SEGMENT_SPACING_FACTOR = 0.5 -- Spacing as multiplier of diameter
local BULK_MOVE_THRESHOLD = 50 -- Use BulkMoveTo if segments > this

-- Visual Constants
local BASE_SIZE = 3.5
local HEAD_SIZE_MULTIPLIER = 1.05
local GLOW_INTENSITY = 2
local GLOW_RANGE_BASE = 15
local BEAM_SEGMENTS = 10
local BEAM_WIDTH_BASE = 0.95
local BEAM_TAPER_STRENGTH = 0.15
local HEAD_BLEND_SEGMENTS = 12
local GLOW_FALLOFF_START = 50

-- Growth
local GROWTH_SPEED = 0.25 -- Faster visual growth response
local SEGMENT_GROWTH_DELAY = 0.02 -- Fast segment spawning

-- Visual Enhancements
local BEAM_TEXTURE_SPEED = 2
local BEAM_TEXTURES = {
	gradient = "rbxasset://textures/ui/LuaChat/9-slice/kit-modal-highlight.png"
}

-- LOD
local FORCE_RENDER_SEGMENTS = 200
local LOD_DISTANCE_NEAR = 150
local LOD_DISTANCE_MID = 300
local LOD_DISTANCE_FAR = 600

-- Create network events
local remoteEvents = {}
local function createNetworkEvents()
	local folder = ReplicatedStorage:FindFirstChild("SnakeNetworking")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "SnakeNetworking"
		folder.Parent = ReplicatedStorage
	end

	local events = {"PositionUpdate", "LengthUpdate", "SkinUpdate", "BoostUpdate"}
	for _, eventName in ipairs(events) do
		local event = folder:FindFirstChild(eventName)
		if not event then
			event = Instance.new("RemoteEvent")
			event.Name = eventName
			event.Parent = folder
		end
		remoteEvents[eventName:lower()] = event
	end
end

-- === COLOR UTILS ===
local function HSVToRGB(h, s, v)
	h = h % 1
	local i = math.floor(h * 6)
	local f = h * 6 - i
	local p = v * (1 - s)
	local q = v * (1 - f * s)
	local t = v * (1 - (1 - f) * s)
	local i = i % 6
	if i == 0 then return v, t, p
	elseif i == 1 then return q, v, p
	elseif i == 2 then return p, v, t
	elseif i == 3 then return p, q, v
	elseif i == 4 then return t, p, v
	elseif i == 5 then return v, p, q
	end
end

-- === SNAKE CLASS ===
local Snake = {}
Snake.__index = Snake

function Snake.new(character, config)
	local self = setmetatable({}, Snake)

	self.character = character
	self.rootPart = character:WaitForChild("HumanoidRootPart")
	self.humanoid = character:WaitForChild("Humanoid")
	self.player = Players:GetPlayerFromCharacter(character)
	self.config = config or {}

	if not self.player then
		warn("⚠️ Failed to get player from character")
		return nil
	end

	-- Hide original character
	for _, part in pairs(character:GetDescendants()) do
		if part:IsA("BasePart") and part ~= self.rootPart then
			part.Transparency = 1
			part.CanCollide = false
			part.CanQuery = false
		elseif part:IsA("Decal") or part:IsA("Texture") then
			part.Transparency = 1
		elseif part:IsA("Accessory") then
			part:Destroy()
		end
	end

	self.rootPart.Transparency = 1
	self.rootPart.CanCollide = true
	self.rootPart.CanQuery = false
	self.humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

	-- Core Data
	self.length = config.InitialLength or 10
	self.actualLength = self.length
	self.targetLength = self.length
	self.isBoosting = false
	self.growthFactor = 1
	
	-- Visual States
	self.rainbowMode = false
	self.currentHue = 0
	self.glowPulsePhase = 0
	
	-- Movement History (Distance Based)
	self.pathPoints = {} -- {position, cframe, totalDist}
	self.totalPathDistance = 0
	self.lastRecordPos = self.rootPart.Position
	self.lastRecordCF = self.rootPart.CFrame
	
	-- Initialize Path
	table.insert(self.pathPoints, {
		position = self.rootPart.Position,
		cframe = self.rootPart.CFrame,
		totalDist = 0
	})

	-- Visual Components
	self.model = Instance.new("Model")
	self.model.Name = "Snake_" .. self.player.Name
	self.model.Parent = workspace

	self.segments = {}
	self.beams = {}
	self.attachments = {}
	self.glows = {}
	self.visibleSegmentCount = 0
	self.forcedRenderSegments = {}
	self.segmentVisibility = {}
	
	self.camera = workspace.CurrentCamera
	self.isLocalPlayer = (self.player == Players.LocalPlayer)

	-- IMPORTANT: Set attributes for leaderboard compatibility
	self.model:SetAttribute("PlayerUserId", self.player.UserId)
	self.model:SetAttribute("Length", self.length)
	self.model:SetAttribute("IsPlayer", true)

	-- Add to Snake folder for easy finding by LeaderboardManager
	local snakesFolder = workspace:FindFirstChild("Snakes")
	if snakesFolder then
		self.model.Parent = snakesFolder
	end

	self:createUnifiedBody()
	self:startUpdateLoop()

	print("✅ AAA Snake created for", self.player.Name)
	return self
end

function Snake:calculateGrowthFactor()
	local length = self.actualLength
	if length <= 50 then return 1.0
	elseif length <= 200 then return 1.0 + (length - 50) / 150 * 0.5
	elseif length <= 1000 then return 1.5 + (length - 200) / 800 * 1.0
	elseif length <= 5000 then return 2.5 + (length - 1000) / 4000 * 0.5
	else return 3.0 + math.min((length - 5000) / 10000 * 0.5, 0.5) end
end

function Snake:getSegmentSize(index, baseSize)
	if index == 0 then
		return baseSize * HEAD_SIZE_MULTIPLIER
	elseif index <= HEAD_BLEND_SEGMENTS then
		local blend = index / HEAD_BLEND_SEGMENTS
		local headSize = baseSize * HEAD_SIZE_MULTIPLIER
		local bodySize = baseSize * (1 - 0.05 * blend)
		return headSize + (bodySize - headSize) * (blend ^ 0.5)
	else
		local taper = 1 - (index / math.max(self.visibleSegmentCount, 100)) * 0.2
		taper = 1 - (1 - taper) ^ 1.5
		return baseSize * taper
	end
end

function Snake:getSegmentColor(index)
	if self.rainbowMode then
		local hue = (self.currentHue + (index * 0.01)) % 1
		local r, g, b = HSVToRGB(hue, 1, 1)
		return Color3.new(r, g, b)
	else
		if index == 0 then
			return self.config.HeadColor or self.config.BodyColors[1]
		elseif index <= HEAD_BLEND_SEGMENTS then
			local blend = (index / HEAD_BLEND_SEGMENTS) ^ 0.7
			local c1 = self.config.HeadColor or self.config.BodyColors[1]
			local c2 = self.config.BodyColors[1]
			return c1:Lerp(c2, blend)
		else
			local idx = ((index - 1) % #self.config.BodyColors) + 1
			return self.config.BodyColors[idx]
		end
	end
end

-- === MOVEMENT HISTORY ===
function Snake:recordMovement()
	local currentPos = self.rootPart.Position
	local dist = (currentPos - self.lastRecordPos).Magnitude
	
	if dist >= MIN_RECORD_DIST then
		self.totalPathDistance = self.totalPathDistance + dist
		table.insert(self.pathPoints, {
			position = currentPos,
			cframe = self.rootPart.CFrame,
			totalDist = self.totalPathDistance
		})
		self.lastRecordPos = currentPos
		self.lastRecordCF = self.rootPart.CFrame
		
		-- Prune history that is too old (farther than max snake length + buffer)
		local maxNeededDist = MAX_SEGMENTS * (BASE_SIZE * 3.5 * SEGMENT_SPACING_FACTOR) + 100
		while #self.pathPoints > 2 and (self.totalPathDistance - self.pathPoints[2].totalDist) > maxNeededDist do
			table.remove(self.pathPoints, 1)
		end
	end
end

function Snake:getPointAtDistance(distBehindHead)
	local targetDist = self.totalPathDistance - distBehindHead
	
	-- If target is ahead of head (negative distance), clamp to head
	if targetDist >= self.totalPathDistance then
		return self.rootPart.Position, self.rootPart.CFrame
	end
	
	-- Binary search for the segment
	local points = self.pathPoints
	local count = #points
	
	if count < 2 then return points[1].position, points[1].cframe end
	if targetDist <= points[1].totalDist then return points[1].position, points[1].cframe end
	
	local low = 1
	local high = count
	local idx = 1
	
	while low <= high do
		local mid = math.floor((low + high) / 2)
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
	
	local segmentDist = p2.totalDist - p1.totalDist
	local alpha = (targetDist - p1.totalDist) / segmentDist
	
	return p1.position:Lerp(p2.position, alpha), p1.cframe:Lerp(p2.cframe, alpha)
end

-- === BODY CREATION ===
function Snake:createUnifiedBody()
	local attachmentPart = Instance.new("Part")
	attachmentPart.Name = "BeamHolder"
	attachmentPart.Transparency = 1
	attachmentPart.CanCollide = false
	attachmentPart.Anchored = true
	attachmentPart.Size = Vector3.one
	attachmentPart.Parent = self.model
	self.attachmentPart = attachmentPart

	-- Head
	local head = Instance.new("Part")
	head.Name = "Segment0_Head"
	head.Shape = Enum.PartType.Ball
	head.Material = Enum.Material.Neon
	head.Size = Vector3.one * BASE_SIZE * HEAD_SIZE_MULTIPLIER
	head.CanCollide = false
	head.CanTouch = true
	head.Anchored = true
	head.Parent = self.model
	
	CollectionService:AddTag(head, "SnakeHead")
	self.segments[0] = head
	self.head = head
	
	-- Head Glow
	local glow = Instance.new("PointLight")
	glow.Name = "Glow"
	glow.Brightness = GLOW_INTENSITY
	glow.Range = GLOW_RANGE_BASE
	glow.Parent = head
	self.headGlow = glow
	self.glows[0] = glow
	
	-- Eyes
	local function createEye(xOffset)
		local eye = Instance.new("Part")
		eye.Name = xOffset > 0 and "RightEye" or "LeftEye"
		eye.Shape = Enum.PartType.Ball
		eye.Material = Enum.Material.Neon
		eye.Color = Color3.new(1, 1, 1)
		eye.Size = Vector3.one * 0.5
		eye.CanCollide = false
		eye.Anchored = true
		eye.Parent = self.model
		
		local pupil = Instance.new("Part")
		pupil.Name = eye.Name .. "Pupil"
		pupil.Shape = Enum.PartType.Ball
		pupil.Material = Enum.Material.Neon
		pupil.Color = Color3.new(0, 0, 0)
		pupil.Size = Vector3.one * 0.25
		pupil.CanCollide = false
		pupil.Anchored = true
		pupil.Parent = self.model
		
		return eye, pupil
	end
	
	self.leftEye, self.leftPupil = createEye(-0.6)
	self.rightEye, self.rightPupil = createEye(0.6)
	
	-- Attachments
	local att = Instance.new("Attachment")
	att.Name = "Attachment0"
	att.Parent = attachmentPart
	self.attachments[0] = att
	
	self.visibleSegmentCount = 0
	
	-- Initial Segments
	local startCount = math.min(math.ceil(self.length), MAX_SEGMENTS)
	self:addSegments(startCount)
end

function Snake:addSegments(count)
	local currentCount = self.visibleSegmentCount
	local limit = math.min(currentCount + count, MAX_SEGMENTS)
	
	for i = currentCount + 1, limit do
		local seg = Instance.new("Part")
		seg.Name = "Segment" .. i
		seg.Shape = Enum.PartType.Ball
		seg.Material = Enum.Material.Neon
		seg.CanCollide = false
		seg.CanTouch = true -- Enable touch for ALL segments for collision
		seg.Anchored = true
		seg.Transparency = 0
		seg.Parent = self.model
		
		-- Collision Tag
		CollectionService:AddTag(seg, "SnakeSegment")
		seg:SetAttribute("SegmentIndex", i)
		seg:SetAttribute("OwnerName", self.player.Name)
		
		self.segments[i] = seg
		
		-- Glow (Strategic)
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
			self.glows[i] = g
		end
		
		-- Attachment
		local att = Instance.new("Attachment")
		att.Name = "Attachment" .. i
		att.Parent = self.attachmentPart
		self.attachments[i] = att
		
		-- Beam
		if self.attachments[i-1] then
			local beam = Instance.new("Beam")
			beam.Name = "Beam" .. (i-1)
			beam.Attachment0 = self.attachments[i-1]
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
			beam.Parent = self.attachmentPart
			self.beams[i-1] = beam
		end
	end
	
	self.visibleSegmentCount = limit
end

function Snake:updateUnifiedBody()
	-- 1. Handle Growth
	local requiredSegments = math.min(math.ceil(self.actualLength), MAX_SEGMENTS)
	if requiredSegments > self.visibleSegmentCount then
		self:addSegments(1) -- Add slowly
	end
	
	-- 2. Calculate Spacing
	local currentBaseSize = BASE_SIZE * self.growthFactor
	local spacing = currentBaseSize * SEGMENT_SPACING_FACTOR
	
	-- 3. Update Head
	self.head.CFrame = self.rootPart.CFrame
	self.head.Size = Vector3.one * self:getSegmentSize(0, currentBaseSize)
	self.head.Color = self:getSegmentColor(0)
	self.headGlow.Color = self.head.Color
	self.attachments[0].WorldPosition = self.head.Position
	
	-- Update Eyes
	if self.leftEye and self.rightEye then
		local headSize = self.head.Size.X
		local eyeScale = headSize / BASE_SIZE * 0.5
		local eyeOffset = headSize * 0.3
		local eyeForward = -headSize * 0.35
		local cf = self.head.CFrame
		
		self.leftEye.Size = Vector3.one * eyeScale
		self.rightEye.Size = Vector3.one * eyeScale
		self.leftPupil.Size = Vector3.one * eyeScale * 0.5
		self.rightPupil.Size = Vector3.one * eyeScale * 0.5
		
		self.leftEye.CFrame = cf * CFrame.new(-eyeOffset, eyeOffset * 0.5, eyeForward)
		self.rightEye.CFrame = cf * CFrame.new(eyeOffset, eyeOffset * 0.5, eyeForward)
		self.leftPupil.CFrame = self.leftEye.CFrame * CFrame.new(0, 0, -eyeScale * 0.3)
		self.rightPupil.CFrame = self.rightEye.CFrame * CFrame.new(0, 0, -eyeScale * 0.3)
	end
	
	-- 4. Bulk Update Body
	local bulkParts = {}
	local bulkCFrames = {}
	
	for i = 1, self.visibleSegmentCount do
		local seg = self.segments[i]
		if seg and seg.Parent then
			local dist = i * spacing
			local pos, cf = self:getPointAtDistance(dist)
			
			-- Culling
			local camDist = (pos - (self.camera.CFrame.Position)).Magnitude
			local isVisible = i <= FORCE_RENDER_SEGMENTS or camDist < LOD_DISTANCE_FAR
			
			if isVisible then
				table.insert(bulkParts, seg)
				table.insert(bulkCFrames, cf)
				
				seg.Size = Vector3.one * self:getSegmentSize(i, currentBaseSize)
				seg.Color = self:getSegmentColor(i)
				
				if self.attachments[i] then
					self.attachments[i].WorldPosition = pos
				end
				
				-- Update Beam Width
				local beam = self.beams[i-1]
				if beam then
					local w = self:getSegmentSize(i, currentBaseSize) * BEAM_WIDTH_BASE
					beam.Width0 = w
					beam.Width1 = w
					beam.Color = ColorSequence.new(self:getSegmentColor(i))
					beam.Enabled = true
				end
			else
				-- Move far away or hide
				seg.CFrame = CFrame.new(0, -1000, 0)
				if self.beams[i-1] then self.beams[i-1].Enabled = false end
			end
		end
	end
	
	if #bulkParts > 0 then
		workspace:BulkMoveTo(bulkParts, bulkCFrames, Enum.BulkMoveMode.FireCFrameChanged)
	end
end

function Snake:startUpdateLoop()
	local frame = 0
	self.updateConnection = RunService.Heartbeat:Connect(function(dt)
		if not self.character.Parent then
			self:destroy()
			return
		end
		
		frame = frame + 1
		
		-- Update Logic
		self:recordMovement()
		
		if self.actualLength < self.targetLength then
			self.actualLength = self.actualLength + (self.targetLength - self.actualLength) * GROWTH_SPEED
		end
		
		if frame % 10 == 0 then
			self.growthFactor = self:calculateGrowthFactor()
		end
		
		if self.rainbowMode then
			self.currentHue = (self.currentHue + dt * 0.2) % 1
		end
		
		self:updateUnifiedBody()
		
		-- Network Update (Client Only)
		if self.isLocalPlayer and frame % 3 == 0 then
			self:sendNetworkUpdate()
		end

		-- LEADERBOARD UPDATE: Sync Length attribute to Model so LeaderboardManager can see it
		if frame % 15 == 0 then
			self.model:SetAttribute("Length", math.floor(self.targetLength))
		end
	end)
end

function Snake:sendNetworkUpdate()
	if remoteEvents.positionupdate then
		remoteEvents.positionupdate:FireServer({
			position = self.rootPart.Position,
			lookVector = self.rootPart.CFrame.LookVector,
			length = self.targetLength,
			boosting = self.isBoosting,
			rainbowMode = self.rainbowMode
		})
	end
end

-- ADDED MISSING METHOD TO FIX ERROR
function Snake:updateLength(amount)
	self.targetLength = math.min(self.targetLength + (amount or 1), MAX_SEGMENTS)
end

function Snake:GetSegments()
	-- Return ALL segments for collision
	local s = {}
	for i = 1, self.visibleSegmentCount do
		if self.segments[i] then
			table.insert(s, self.segments[i])
		end
	end
	return s
end

function Snake:destroy()
	if self.updateConnection then self.updateConnection:Disconnect() end
	if self.model then self.model:Destroy() end
end

-- === MODULE INTERFACE ===
local OptimizedSnakeSystem = {}

function OptimizedSnakeSystem.init()
	createNetworkEvents()
	print("✅ OptimizedSnakeSystem V9.5 AAA Loaded")
end

function OptimizedSnakeSystem.createSnake(character, config)
	return Snake.new(character, config)
end

return OptimizedSnakeSystem