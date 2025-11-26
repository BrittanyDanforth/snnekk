--[[
    UNIFIED PET + VFX CLIENT (v2 – REVAMPED + WINGS, SYNCED FLOAT)
    COMPLETELY REDESIGNED BEAUTIFUL UI

    Put this LocalScript in StarterPlayerScripts.
    Remove/disable old PetFollower or egg VFX client scripts.
]]

----------------------------------------------------------------
-- SERVICES
----------------------------------------------------------------
local RS               = game:GetService("ReplicatedStorage")
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local CollectionService= game:GetService("CollectionService")
local TweenService     = game:GetService("TweenService")
local Debris           = game:GetService("Debris")

local player           = Players.LocalPlayer
local character        = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local camera           = workspace.CurrentCamera

player.CharacterAdded:Connect(function(char)
	character = char
	humanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)

print("🔥 UNIFIED PET + VFX CLIENT v2 (REVAMPED + WINGS SYNC) - Loading...")

----------------------------------------------------------------
-- GLOBAL PET-FOLLOW DEFAULTS
----------------------------------------------------------------
local DEFAULT_FOLLOW_OFFSET      = Vector3.new(4, 2.3, -4)
local DEFAULT_FOLLOW_SMOOTHNESS  = 6
local DEFAULT_BOB_SPEED          = 1.8
local DEFAULT_BOB_HEIGHT         = 0.35
local DEFAULT_MIN_FLAT_DISTANCE  = 5

----------------------------------------------------------------
-- RARITY CONFIGS (PREMIUM DESIGN)
----------------------------------------------------------------
local ScreenRarityConfig = {
	Common = {
		color           = Color3.fromRGB(180, 180, 200),
		accentColor     = Color3.fromRGB(220, 220, 240),
		particleCount   = 40,
		ringCount       = 3,
		beamCount       = 12,
		shakeIntensity  = 0.4,
		flashIntensity  = 0.25,
		blurSize        = 12,
		bloomIntensity  = 0.4,
		duration        = 1.8,
		text            = "COMMON",
		buildupTime     = 0.4,
		titleText       = "NEW PET OBTAINED!",
		nameColor       = Color3.fromRGB(255, 255, 255),
		glowIntensity   = 0.3,
	},
	Rare = {
		color           = Color3.fromRGB(0, 180, 255),
		accentColor     = Color3.fromRGB(100, 220, 255),
		particleCount   = 100,
		ringCount       = 5,
		beamCount       = 20,
		shakeIntensity  = 1.2,
		flashIntensity  = 0.45,
		blurSize        = 28,
		bloomIntensity  = 0.9,
		duration        = 2.8,
		text            = "RARE",
		buildupTime     = 0.9,
		titleText       = "RARE PET OBTAINED!",
		nameColor       = Color3.fromRGB(200, 240, 255),
		glowIntensity   = 0.6,
	},
	Epic = {
		color           = Color3.fromRGB(160, 60, 255),
		accentColor     = Color3.fromRGB(220, 140, 255),
		particleCount   = 180,
		ringCount       = 7,
		beamCount       = 36,
		shakeIntensity  = 2.5,
		flashIntensity  = 0.65,
		blurSize        = 45,
		bloomIntensity  = 1.4,
		duration        = 3.8,
		text            = "EPIC",
		buildupTime     = 1.4,
		titleText       = "EPIC PET OBTAINED!",
		nameColor       = Color3.fromRGB(255, 220, 255),
		glowIntensity   = 0.9,
	},
	Legendary = {
		color           = Color3.fromRGB(255, 200, 0),
		accentColor     = Color3.fromRGB(255, 240, 120),
		particleCount   = 250,
		ringCount       = 9,
		beamCount       = 52,
		shakeIntensity  = 3.5,
		flashIntensity  = 0.85,
		blurSize        = 55,
		bloomIntensity  = 2.2,
		duration        = 4.5,
		text            = "LEGENDARY",
		buildupTime     = 2.0,
		titleText       = "LEGENDARY PET OBTAINED!",
		nameColor       = Color3.fromRGB(255, 255, 180),
		glowIntensity   = 1.2,
	},
}

----------------------------------------------------------------
-- PET CONFIGS
----------------------------------------------------------------
local PET_CONFIGS = {
	Axolotl = {
		displayName       = "Axolotl",
		templatePath      = {"Pets", "Axolotl"},
		offset            = DEFAULT_FOLLOW_OFFSET,
		followSmoothness  = DEFAULT_FOLLOW_SMOOTHNESS,
		bobSpeed          = DEFAULT_BOB_SPEED,
		bobHeight         = DEFAULT_BOB_HEIGHT,
		minFlatDistance   = DEFAULT_MIN_FLAT_DISTANCE,
		subtitle          = "A magical companion that will float gracefully by your side!",
	},
}

----------------------------------------------------------------
-- WING / BONE FLAP CONFIG
----------------------------------------------------------------
local WING_BONE_CONFIGS = {
	Axolotl = {
		wingsModelName = "WINGS1",
		leftChainNames  = { "Wing L", "Wing L.1", "Wing L.3" },
		rightChainNames = { "Wing R", "Wing R.1", "Wing R.2" },
		speed     = 3.2,
		amplitude = 28,
		axis      = "Z",
	},
}

----------------------------------------------------------------
-- TEMPLATE RESOLVER
----------------------------------------------------------------
local function resolveTemplate(pathTable)
	if typeof(pathTable) ~= "table" then return nil end
	local obj = RS
	for _, name in ipairs(pathTable) do
		obj = obj:FindFirstChild(name)
		if not obj then return nil end
	end
	return obj
end

----------------------------------------------------------------
-- PREMIUM SCREEN VFX SYSTEM (REDESIGNED)
----------------------------------------------------------------
local ScreenVFXSystem = {}
ScreenVFXSystem.__index = ScreenVFXSystem

function ScreenVFXSystem.new()
	local self = setmetatable({}, ScreenVFXSystem)
	self.ScreenGui = self:CreateScreenGui()
	self.Camera = camera
	self.IsTriggering = false
	return self
end

function ScreenVFXSystem:CreateScreenGui()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "UnifiedVFXGui"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.IgnoreGuiInset = true
	local playerGui = player:WaitForChild("PlayerGui")
	screenGui.Parent = playerGui
	return screenGui
end

function ScreenVFXSystem:ScreenShake(intensity, duration)
	task.spawn(function()
		local baseCFrame = self.Camera.CFrame
		local elapsed = 0
		local conn
		conn = RunService.RenderStepped:Connect(function(dt)
			elapsed += dt
			if elapsed >= duration then
				self.Camera.CFrame = baseCFrame
				conn:Disconnect()
				return
			end
			local t = 1 - (elapsed / duration)
			local power = intensity * t
			local dx = (math.random() - 0.5) * 2 * power
			local dy = (math.random() - 0.5) * 2 * power
			self.Camera.CFrame = baseCFrame * CFrame.new(dx, dy, 0)
		end)
	end)
end

function ScreenVFXSystem:ColorFlash(color, duration, intensity)
	local flash = Instance.new("Frame")
	flash.Size = UDim2.new(1, 0, 1, 0)
	flash.BackgroundColor3 = color
	flash.BackgroundTransparency = 1 - intensity
	flash.BorderSizePixel = 0
	flash.ZIndex = 10000
	flash.Parent = self.ScreenGui

	TweenService:Create(flash, TweenInfo.new(duration, Enum.EasingStyle.Exponential), {
		BackgroundTransparency = 1
	}):Play()

	Debris:AddItem(flash, duration + 0.1)
end

function ScreenVFXSystem:RadialBlur(maxSize, duration, bloomIntensity)
	local blur = Instance.new("BlurEffect")
	blur.Size = 0
	blur.Parent = self.Camera

	local bloom = Instance.new("BloomEffect")
	bloom.Intensity = 0
	bloom.Size = 24
	bloom.Threshold = 0.8
	bloom.Parent = self.Camera

	local colorCorrect = Instance.new("ColorCorrectionEffect")
	colorCorrect.Brightness = 0
	colorCorrect.Saturation = 0
	colorCorrect.Parent = self.Camera

	local infoIn = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(blur, infoIn, {Size = maxSize}):Play()
	TweenService:Create(bloom, infoIn, {Intensity = bloomIntensity}):Play()
	TweenService:Create(colorCorrect, infoIn, {Brightness = 0.15, Saturation = 0.25}):Play()

	task.wait(0.15)

	local infoOut = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	TweenService:Create(blur, infoOut, {Size = 0}):Play()
	TweenService:Create(bloom, infoOut, {Intensity = 0}):Play()
	TweenService:Create(colorCorrect, infoOut, {Brightness = 0, Saturation = 0}):Play()

	task.delay(duration, function()
		blur:Destroy()
		bloom:Destroy()
		colorCorrect:Destroy()
	end)
end

function ScreenVFXSystem:ScreenParticles(color, count, duration)
	for i = 1, count do
		task.spawn(function()
			local particle = Instance.new("Frame")
			local size = math.random(4, 12)
			particle.Size = UDim2.new(0, size, 0, size)
			particle.Position = UDim2.fromScale(0.5, 0.5)
			particle.BackgroundColor3 = color
			particle.BorderSizePixel = 0
			particle.ZIndex = 9900 + i
			particle.Parent = self.ScreenGui

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(1, 0)
			corner.Parent = particle

			local glow = Instance.new("UIStroke")
			glow.Color = color
			glow.Thickness = 2.5
			glow.Transparency = 0
			glow.Parent = particle

			local angle = math.rad(math.random(0, 360))
			local distance = math.random(250, 700)
			local targetX = 0.5 + (math.cos(angle) * distance) / self.Camera.ViewportSize.X
			local targetY = 0.5 + (math.sin(angle) * distance) / self.Camera.ViewportSize.Y
				+ math.random(150, 400) / self.Camera.ViewportSize.Y

			task.wait(math.random() * 0.4)

			TweenService:Create(particle, TweenInfo.new(duration, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Position = UDim2.fromScale(targetX, targetY),
				Size = UDim2.new(0, 0, 0, 0),
				BackgroundTransparency = 1
			}):Play()

			TweenService:Create(glow, TweenInfo.new(duration * 0.7), {
				Transparency = 1
			}):Play()

			Debris:AddItem(particle, duration + 0.5)
		end)
	end
end

function ScreenVFXSystem:ScreenBeams(color, count, duration)
	local center = UDim2.fromScale(0.5, 0.5)
	local maxLen = math.max(self.Camera.ViewportSize.X, self.Camera.ViewportSize.Y) * 0.9
	local growTime = 0.35

	for i = 1, count do
		local angle = (i - 1) * (360 / count)

		local beam = Instance.new("Frame")
		beam.AnchorPoint = Vector2.new(0.5, 1)
		beam.Position = center
		beam.Size = UDim2.new(0, 5, 0, 0)
		beam.BackgroundColor3 = color
		beam.BorderSizePixel = 0
		beam.Rotation = angle
		beam.ZIndex = 9800
		beam.Parent = self.ScreenGui

		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(255, 255, 255)
		stroke.Thickness = 2.5
		stroke.Transparency = 0
		stroke.Parent = beam

		local gradient = Instance.new("UIGradient")
		gradient.Rotation = 90
		gradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.7, 0),
			NumberSequenceKeypoint.new(1, 1)
		})
		gradient.Parent = beam

		task.delay(0.03 * i, function()
			TweenService:Create(beam, TweenInfo.new(growTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 5, 0, maxLen)
			}):Play()

			task.wait(growTime)

			TweenService:Create(beam, TweenInfo.new(duration - growTime, Enum.EasingStyle.Quad), {
				BackgroundTransparency = 1
			}):Play()

			TweenService:Create(stroke, TweenInfo.new(duration - growTime), {
				Transparency = 1
			}):Play()

			Debris:AddItem(beam, duration + 0.1)
		end)
	end
end

function ScreenVFXSystem:CircularWaves(color, count, duration)
	for i = 1, count do
		task.wait(0.25)

		local wave = Instance.new("Frame")
		wave.Size = UDim2.new(0, 60, 0, 60)
		wave.Position = UDim2.new(0.5, -30, 0.5, -30)
		wave.BackgroundTransparency = 1
		wave.ZIndex = 9990 + i
		wave.Parent = self.ScreenGui

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = wave

		local stroke = Instance.new("UIStroke")
		stroke.Color = color
		stroke.Thickness = 5 + (i * 2.5)
		stroke.Transparency = 0
		stroke.Parent = wave

		TweenService:Create(wave, TweenInfo.new(duration, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 1800, 0, 1800),
			Position = UDim2.new(0.5, -900, 0.5, -900)
		}):Play()

		TweenService:Create(stroke, TweenInfo.new(duration), {
			Transparency = 1
		}):Play()

		Debris:AddItem(wave, duration + 0.1)
	end
end

function ScreenVFXSystem:TextPopup(text, color, duration)
	local label = Instance.new("TextLabel")
	label.Text = text
	label.Font = Enum.Font.GothamBlack
	label.TextSize = 140
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.TextStrokeThickness = 6
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(0, 1000, 0, 220)
	label.Position = UDim2.new(0.5, -500, 0.32, -110)
	label.TextTransparency = 1
	label.TextStrokeTransparency = 1
	label.ZIndex = 10001
	label.Parent = self.ScreenGui

	local glow = Instance.new("UIStroke")
	glow.Color = color
	glow.Thickness = 12
	glow.Transparency = 1
	glow.Parent = label

	TweenService:Create(label, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		TextTransparency = 0,
		TextStrokeTransparency = 0,
		TextSize = 160
	}):Play()

	TweenService:Create(glow, TweenInfo.new(0.4), {Transparency = 0.3}):Play()

	task.wait(0.6)

	TweenService:Create(label, TweenInfo.new(duration - 1, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
		Position = UDim2.new(0.5, -500, 0.08, -110),
		TextTransparency = 1,
		TextStrokeTransparency = 1
	}):Play()

	TweenService:Create(glow, TweenInfo.new(duration - 1), {Transparency = 1}):Play()

	Debris:AddItem(label, duration + 0.1)
end

function ScreenVFXSystem:VignettePulse(color, duration)
	local vignette = Instance.new("Frame")
	vignette.Size = UDim2.new(1, 0, 1, 0)
	vignette.BackgroundColor3 = color
	vignette.BackgroundTransparency = 1
	vignette.BorderSizePixel = 0
	vignette.ZIndex = 9700
	vignette.Parent = self.ScreenGui

	local gradient = Instance.new("UIGradient")
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.65, 0.4),
		NumberSequenceKeypoint.new(1, 0)
	})
	gradient.Rotation = 90
	gradient.Parent = vignette

	local tween = TweenService:Create(
		vignette,
		TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{BackgroundTransparency = 0.25}
	)
	tween:Play()

	tween.Completed:Connect(function()
		TweenService:Create(vignette, TweenInfo.new(duration * 0.6, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 1
		}):Play()
	end)

	Debris:AddItem(vignette, duration * 1.6 + 0.1)
end

function ScreenVFXSystem:BuildupAnimation(color, duration)
	local circle = Instance.new("Frame")
	circle.Size = UDim2.new(0, 120, 0, 120)
	circle.Position = UDim2.new(0.5, -60, 0.5, -60)
	circle.BackgroundTransparency = 0.4
	circle.BackgroundColor3 = color
	circle.BorderSizePixel = 0
	circle.ZIndex = 10002
	circle.Parent = self.ScreenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = circle

	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = 5
	stroke.Parent = circle

	local pulseCount = 0
	local maxPulses = math.floor(duration / 0.7)

	local function pulse()
		if pulseCount >= maxPulses then
			circle:Destroy()
			return
		end
		pulseCount += 1

		TweenService:Create(circle, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 180, 0, 180),
			Position = UDim2.new(0.5, -90, 0.5, -90),
			BackgroundTransparency = 0.15
		}):Play()

		task.wait(0.35)

		TweenService:Create(circle, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 120, 0, 120),
			Position = UDim2.new(0.5, -60, 0.5, -60),
			BackgroundTransparency = 0.4
		}):Play()

		task.wait(0.35)
		pulse()
	end

	pulse()
end

function ScreenVFXSystem:PlaySound(soundId, volume)
	pcall(function()
		local sound = Instance.new("Sound")
		sound.SoundId = soundId
		sound.Volume = volume or 0.5
		sound.Parent = self.Camera
		pcall(function() sound:Play() end)
		Debris:AddItem(sound, 3)
	end)
end

function ScreenVFXSystem:TriggerVFX(rarity)
	if self.IsTriggering then return end
	self.IsTriggering = true

	rarity = rarity or "Epic"
	local config = ScreenRarityConfig[rarity] or ScreenRarityConfig.Common

	print("🔥 SCREEN VFX TRIGGERED - RARITY:", rarity)
	task.spawn(function()
		self:BuildupAnimation(config.color, config.buildupTime)
	end)

	self:PlaySound("rbxassetid://9113880795", 0.3)
	task.wait(config.buildupTime)

	self:ScreenShake(config.shakeIntensity, config.duration)
	self:ColorFlash(config.color, config.duration * 0.65, config.flashIntensity)
	self:RadialBlur(config.blurSize, config.duration, config.bloomIntensity)
	self:VignettePulse(config.color, config.duration * 0.45)

	task.spawn(function()
		self:ScreenParticles(config.color, config.particleCount, config.duration)
	end)
	task.spawn(function()
		self:ScreenBeams(config.color, config.beamCount, config.duration * 0.85)
	end)
	task.spawn(function()
		self:CircularWaves(config.color, config.ringCount, config.duration)
	end)
	task.spawn(function()
		self:TextPopup(config.text, config.color, config.duration)
	end)

	self:PlaySound("rbxassetid://9114221327", 0.5)

	task.wait(config.duration + 0.5)
	self.IsTriggering = false
end

local screenVfxSystem = ScreenVFXSystem.new()
print("✅ Screen VFX System Loaded!")

----------------------------------------------------------------
-- PET FOLLOWER SYSTEM + SYNCED WINGS
----------------------------------------------------------------
local PetFollowerSystem = {}
PetFollowerSystem.__index = PetFollowerSystem

function PetFollowerSystem.new()
	local self = setmetatable({}, PetFollowerSystem)
	self.petModel   = nil
	self.followConn = nil
	self.wingState  = nil
	self.motionTime = 0
	return self
end

function PetFollowerSystem:Cleanup()
	if self.followConn then
		self.followConn:Disconnect()
		self.followConn = nil
	end
	self.wingState = nil
	self.motionTime = 0
	if self.petModel then
		self.petModel:Destroy()
		self.petModel = nil
	end
end

function PetFollowerSystem:SetupWings(petKey)
	self.wingState = nil

	local cfg = WING_BONE_CONFIGS[petKey]
	if not cfg then return end
	if not self.petModel then return end

	local wingsRoot
	if cfg.wingsModelName then
		wingsRoot = self.petModel:FindFirstChild(cfg.wingsModelName, true)
	end
	wingsRoot = wingsRoot or self.petModel
	if not wingsRoot then return end

	local function getBonesFromNames(nameList)
		local result = {}
		for _, boneName in ipairs(nameList) do
			local inst = wingsRoot:FindFirstChild(boneName, true)
			if inst and inst:IsA("Bone") then
				table.insert(result, inst)
			end
		end
		return result
	end

	local leftBones  = getBonesFromNames(cfg.leftChainNames or {})
	local rightBones = getBonesFromNames(cfg.rightChainNames or {})

	if #leftBones == 0 and #rightBones == 0 then
		return
	end

	local restTransforms = {}
	for _, b in ipairs(leftBones) do
		restTransforms[b] = b.Transform
	end
	for _, b in ipairs(rightBones) do
		restTransforms[b] = b.Transform
	end

	self.wingState = {
		leftBones      = leftBones,
		rightBones     = rightBones,
		restTransforms = restTransforms,
		speed          = cfg.speed or 3,
		amplitude      = cfg.amplitude or 25,
		axis           = cfg.axis or "Z",
		t              = 0,
	}

	print("🪽 Wing system armed for pet:", petKey, "bones L/R:", #leftBones, #rightBones)
end

function PetFollowerSystem:UpdateWings(dt)
	local state = self.wingState
	if not state then return end

	local baseTime = self.motionTime or 0
	local flapAngle = math.sin(baseTime * state.speed) * state.amplitude

	local leftAngle  = flapAngle
	local rightAngle = flapAngle

	local axis = state.axis
	local rotL, rotR
	if axis == "X" then
		rotL = CFrame.Angles(math.rad(leftAngle), 0, 0)
		rotR = CFrame.Angles(math.rad(rightAngle), 0, 0)
	elseif axis == "Y" then
		rotL = CFrame.Angles(0, math.rad(leftAngle), 0)
		rotR = CFrame.Angles(0, math.rad(rightAngle), 0)
	else
		rotL = CFrame.Angles(0, 0, math.rad(leftAngle))
		rotR = CFrame.Angles(0, 0, math.rad(rightAngle))
	end

	for _, bone in ipairs(state.leftBones) do
		local rest = state.restTransforms[bone] or CFrame.new()
		bone.Transform = rest * rotL
	end
	for _, bone in ipairs(state.rightBones) do
		local rest = state.restTransforms[bone] or CFrame.new()
		bone.Transform = rest * rotR
	end
end

function PetFollowerSystem:EquipPet(petKey)
	local config = PET_CONFIGS[petKey]
	if not config then
		warn("[PetFollowerSystem] Unknown pet key:", petKey)
		return
	end

	self:Cleanup()

	local template = resolveTemplate(config.templatePath)
	if not template or not template:IsA("Model") then
		warn("[PetFollowerSystem] Template not found or not a Model for pet:", petKey)
		return
	end

	local pet = template:Clone()
	pet.Name = (config.displayName or petKey) .. "Pet"
	pet.Parent = workspace
	self.petModel = pet

	local root = pet.PrimaryPart
		or pet:FindFirstChild("HumanoidRootPart")
		or pet:FindFirstChildWhichIsA("BasePart")

	if not root then
		warn("[PetFollowerSystem] Pet model has no root part:", petKey)
		self:Cleanup()
		return
	end

	pet.PrimaryPart = root

	for _, part in ipairs(pet:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
			part.CanCollide = false
			part.Massless = true
		end
	end

	self:SetupWings(petKey)

	self.motionTime = 0
	local currentCF = nil

	self.followConn = RunService.RenderStepped:Connect(function(dt)
		self.motionTime += dt

		local char = player.Character
		if not char or not char.Parent then
			return
		end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then
			return
		end

		local t = self.motionTime

		local wingSpeed = (self.wingState and self.wingState.speed) or nil
		local bobSpeed = wingSpeed and (wingSpeed * 0.5) or (config.bobSpeed or DEFAULT_BOB_SPEED)
		local bobHeight = config.bobHeight or DEFAULT_BOB_HEIGHT
		local bob = math.sin(t * bobSpeed) * bobHeight

		local offset = config.offset or DEFAULT_FOLLOW_OFFSET
		local targetCF = hrp.CFrame * CFrame.new(
			offset.X,
			offset.Y + bob,
			offset.Z
		)

		if not currentCF then
			currentCF = targetCF
		else
			local smooth = config.followSmoothness or DEFAULT_FOLLOW_SMOOTHNESS
			local alpha = math.clamp(dt * smooth, 0, 1)
			currentCF = currentCF:Lerp(targetCF, alpha)
		end

		local hrpPos = hrp.Position
		local petPos = currentCF.Position
		local flatDelta = Vector3.new(petPos.X - hrpPos.X, 0, petPos.Z - hrpPos.Z)
		local flatDist = flatDelta.Magnitude
		local minDist = config.minFlatDistance or DEFAULT_MIN_FLAT_DISTANCE

		if flatDist > 0 and flatDist < minDist then
			local push = minDist - flatDist
			local adjust = flatDelta.Unit * push
			petPos += Vector3.new(adjust.X, 0, adjust.Z)
		end

		local lookDir = hrp.CFrame.LookVector
		local flatLook = Vector3.new(lookDir.X, 0, lookDir.Z)
		if flatLook.Magnitude < 0.01 then
			flatLook = Vector3.new(0, 0, -1)
		else
			flatLook = flatLook.Unit
		end

		local lookAt = petPos + flatLook
		local finalCF = CFrame.new(petPos, lookAt)
		self.petModel:PivotTo(finalCF)

		self:UpdateWings(dt)
	end)

	print("🐾 Equipped pet:", config.displayName or petKey)
end

local petFollower = PetFollowerSystem.new()

----------------------------------------------------------------
-- PREMIUM PET PREVIEW UI (COMPLETELY REDESIGNED)
----------------------------------------------------------------
local PetPreviewUI = {}
PetPreviewUI.__index = PetPreviewUI

function PetPreviewUI.new()
	local self = setmetatable({}, PetPreviewUI)

	local gui = Instance.new("ScreenGui")
	gui.Name = "PetPreviewGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local playerGui = player:WaitForChild("PlayerGui")
	gui.Parent = playerGui

	-- Premium dim overlay with gradient
	local dim = Instance.new("Frame")
	dim.Name = "Dim"
	dim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	dim.BackgroundTransparency = 1
	dim.Size = UDim2.new(1, 0, 1, 0)
	dim.BorderSizePixel = 0
	dim.ZIndex = 8900
	dim.Visible = false
	dim.Parent = gui

	local dimGradient = Instance.new("UIGradient")
	dimGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.6),
		NumberSequenceKeypoint.new(0.5, 0.5),
		NumberSequenceKeypoint.new(1, 0.7)
	})
	dimGradient.Rotation = 45
	dimGradient.Parent = dim

	-- Main card with glassmorphism
	local card = Instance.new("Frame")
	card.Name = "Card"
	card.Size = UDim2.new(0, 0, 0, 0)
	card.Position = UDim2.new(0.5, 0, 0.5, 0)
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	card.BackgroundTransparency = 0.15
	card.BorderSizePixel = 0
	card.ZIndex = 8910
	card.Visible = false
	card.Parent = gui

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 32)
	cardCorner.Parent = card

	-- Premium gradient background
	local cardGradient = Instance.new("UIGradient")
	cardGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.85),
		NumberSequenceKeypoint.new(0.5, 0.9),
		NumberSequenceKeypoint.new(1, 0.95)
	})
	cardGradient.Rotation = 135
	cardGradient.Parent = card

	-- Animated glow stroke
	local cardStroke = Instance.new("UIStroke")
	cardStroke.Name = "GlowStroke"
	cardStroke.Color = Color3.fromRGB(255, 255, 255)
	cardStroke.Thickness = 4
	cardStroke.Transparency = 1
	cardStroke.Parent = card

	-- Inner glow effect
	local innerGlow = Instance.new("Frame")
	innerGlow.Name = "InnerGlow"
	innerGlow.Size = UDim2.new(1, -8, 1, -8)
	innerGlow.Position = UDim2.new(0, 4, 0, 4)
	innerGlow.BackgroundTransparency = 1
	innerGlow.BorderSizePixel = 0
	innerGlow.ZIndex = 8911
	innerGlow.Parent = card

	local innerStroke = Instance.new("UIStroke")
	innerStroke.Color = Color3.fromRGB(255, 255, 255)
	innerStroke.Thickness = 2
	innerStroke.Transparency = 1
	innerStroke.Parent = innerGlow

	local innerCorner = Instance.new("UICorner")
	innerCorner.CornerRadius = UDim.new(0, 28)
	innerCorner.Parent = innerGlow

	-- Title label (premium typography)
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, -40, 0, 36)
	title.Position = UDim2.new(0, 20, 0, 20)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextYAlignment = Enum.TextYAlignment.Center
	title.TextColor3 = Color3.fromRGB(200, 200, 220)
	title.TextTransparency = 1
	title.TextStrokeTransparency = 0.8
	title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	title.ZIndex = 8920
	title.Parent = card

	-- Pet name (large, bold, premium)
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "PetName"
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size = UDim2.new(1, -40, 0, 64)
	nameLabel.Position = UDim2.new(0, 20, 0, 64)
	nameLabel.Font = Enum.Font.GothamBlack
	nameLabel.TextSize = 48
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextYAlignment = Enum.TextYAlignment.Center
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextTransparency = 1
	nameLabel.TextStrokeTransparency = 0.5
	nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	nameLabel.ZIndex = 8920
	nameLabel.Parent = card

	-- Name glow effect
	local nameGlow = Instance.new("UIStroke")
	nameGlow.Color = Color3.fromRGB(255, 255, 255)
	nameGlow.Thickness = 6
	nameGlow.Transparency = 1
	nameGlow.Parent = nameLabel

	-- Subtitle (elegant description)
	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"
	subtitle.BackgroundTransparency = 1
	subtitle.Size = UDim2.new(1, -40, 0, 60)
	subtitle.Position = UDim2.new(0, 20, 0, 136)
	subtitle.Font = Enum.Font.Gotham
	subtitle.TextSize = 16
	subtitle.TextWrapped = true
	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	subtitle.TextYAlignment = Enum.TextYAlignment.Top
	subtitle.TextColor3 = Color3.fromRGB(180, 180, 200)
	subtitle.TextTransparency = 1
	subtitle.TextStrokeTransparency = 0.7
	subtitle.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	subtitle.ZIndex = 8920
	subtitle.Parent = card

	-- Premium viewport frame
	local viewport = Instance.new("ViewportFrame")
	viewport.Name = "Preview"
	viewport.BackgroundTransparency = 1
	viewport.Size = UDim2.new(0, 220, 0, 220)
	viewport.Position = UDim2.new(1, -240, 0, 20)
	viewport.ZIndex = 8920
	viewport.Ambient = Color3.fromRGB(255, 255, 255)
	viewport.LightColor = Color3.fromRGB(255, 255, 255)
	viewport.Parent = card

	local vCorner = Instance.new("UICorner")
	vCorner.CornerRadius = UDim.new(1, 0)
	vCorner.Parent = viewport

	-- Premium viewport stroke with glow
	local vStroke = Instance.new("UIStroke")
	vStroke.Color = Color3.fromRGB(255, 255, 255)
	vStroke.Thickness = 4
	vStroke.Transparency = 1
	vStroke.Parent = viewport

	-- Viewport glow gradient
	local vGlow = Instance.new("UIGradient")
	vGlow.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.4, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	})
	vGlow.Rotation = 0
	vGlow.Parent = viewport

	-- Camera for viewport
	local cam = Instance.new("Camera")
	cam.Name = "PreviewCamera"
	cam.Parent = viewport
	viewport.CurrentCamera = cam

	gui.Enabled = false

	self.Gui = gui
	self.Dim = dim
	self.Card = card
	self.CardStroke = cardStroke
	self.InnerStroke = innerStroke
	self.TitleLabel = title
	self.PetNameLabel = nameLabel
	self.NameGlow = nameGlow
	self.SubtitleLabel = subtitle
	self.Viewport = viewport
	self.ViewportCamera = cam
	self.ViewportStroke = vStroke
	self.CurrentModel = nil
	self.IsShowing = false

	return self
end

function PetPreviewUI:ClearPreviewModel()
	if self.CurrentModel then
		self.CurrentModel:Destroy()
		self.CurrentModel = nil
	end
end

function PetPreviewUI:UpdatePetModel(petConfig)
	self:ClearPreviewModel()
	if not self.Viewport or not self.ViewportCamera then return end
	if not petConfig or not petConfig.templatePath then return end

	local template = resolveTemplate(petConfig.templatePath)
	if not template or not template:IsA("Model") then
		warn("[PetPreviewUI] Cannot resolve pet template for preview:", petConfig.displayName or "Unknown")
		return
	end

	local model = template:Clone()
	model.Parent = self.Viewport
	self.CurrentModel = model

	local primary = model.PrimaryPart
		or model:FindFirstChild("HumanoidRootPart")
		or model:FindFirstChildWhichIsA("BasePart")

	if not primary then
		warn("[PetPreviewUI] Pet model preview has no root part")
		return
	end

	model:PivotTo(CFrame.new(0, 0, 0))

	local _, size = model:GetBoundingBox()
	local maxDim = math.max(size.X, size.Y, size.Z)
	if maxDim < 4 then
		local scaleFactor = 4 / math.max(maxDim, 0.01)
		model:ScaleTo(scaleFactor)
		model:PivotTo(CFrame.new(0, 0, 0))
		_, size = model:GetBoundingBox()
		maxDim = math.max(size.X, size.Y, size.Z)
	end

	local dist = maxDim * 1.7
	local focusY = size.Y * 0.5
	local camPos = Vector3.new(0, focusY, dist)

	local camCF = CFrame.new(camPos, Vector3.new(0, focusY, 0)) * CFrame.Angles(0, math.rad(180), 0)
	self.ViewportCamera.CFrame = camCF
end

function PetPreviewUI:Show(petConfig, rarityConfig, duration)
	if self.IsShowing then
		self:ClearPreviewModel()
	end

	self.IsShowing = true
	duration = duration or 3.0
	rarityConfig = rarityConfig or ScreenRarityConfig.Epic

	-- Update text
	self.TitleLabel.Text = rarityConfig.titleText or "NEW PET OBTAINED!"
	self.TitleLabel.TextColor3 = rarityConfig.accentColor or rarityConfig.color
	self.PetNameLabel.Text = petConfig.displayName or "Mystery Pet"
	self.PetNameLabel.TextColor3 = rarityConfig.nameColor or rarityConfig.color
	self.SubtitleLabel.Text = petConfig.subtitle or "A magical companion that will follow you!"

	-- Update colors
	if self.ViewportStroke then
		self.ViewportStroke.Color = rarityConfig.color
		self.ViewportStroke.Transparency = 1
	end
	self.CardStroke.Color = rarityConfig.color
	self.CardStroke.Transparency = 1
	self.InnerStroke.Color = rarityConfig.accentColor or rarityConfig.color
	self.InnerStroke.Transparency = 1
	self.NameGlow.Color = rarityConfig.color
	self.NameGlow.Transparency = 1

	-- Update model
	self:UpdatePetModel(petConfig)

	-- Show UI
	self.Gui.Enabled = true
	self.Dim.Visible = true
	self.Card.Visible = true

	-- Reset states
	self.Dim.BackgroundTransparency = 1
	self.Card.BackgroundTransparency = 0.15
	self.Card.Size = UDim2.new(0, 0, 0, 0)
	self.Card.Position = UDim2.new(0.5, 0, 0.5, 0)

	self.TitleLabel.TextTransparency = 1
	self.PetNameLabel.TextTransparency = 1
	self.SubtitleLabel.TextTransparency = 1

	-- Premium entrance animation
	local dimTween = TweenService:Create(
		self.Dim,
		TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{BackgroundTransparency = 0.5}
	)

	local cardTween = TweenService:Create(
		self.Card,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Size = UDim2.new(0, 600, 0, 260),
			Position = UDim2.new(0.5, -300, 0.5, -130),
		}
	)

	local strokeTween = TweenService:Create(
		self.CardStroke,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad),
		{Transparency = 0.2}
	)

	local innerTween = TweenService:Create(
		self.InnerStroke,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad),
		{Transparency = 0.4}
	)

	local titleTween = TweenService:Create(
		self.TitleLabel,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{TextTransparency = 0}
	)

	local nameTween = TweenService:Create(
		self.PetNameLabel,
		TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{TextTransparency = 0, TextSize = 52}
	)

	local nameGlowTween = TweenService:Create(
		self.NameGlow,
		TweenInfo.new(0.4, Enum.EasingStyle.Quad),
		{Transparency = 0.5}
	)

	local subtitleTween = TweenService:Create(
		self.SubtitleLabel,
		TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{TextTransparency = 0}
	)

	dimTween:Play()
	cardTween:Play()
	strokeTween:Play()
	innerTween:Play()
	titleTween:Play()
	nameTween:Play()
	nameGlowTween:Play()
	subtitleTween:Play()

	if self.ViewportStroke then
		TweenService:Create(self.ViewportStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
			Transparency = 0.2
		}):Play()
	end

	-- Exit animation after duration
	task.delay(duration, function()
		local dimOut = TweenService:Create(
			self.Dim,
			TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{BackgroundTransparency = 1}
		)

		local cardOut = TweenService:Create(
			self.Card,
			TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				Size = UDim2.new(0, 0, 0, 0),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				BackgroundTransparency = 1
			}
		)

		local strokeOut = TweenService:Create(
			self.CardStroke,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad),
			{Transparency = 1}
		)

		local innerOut = TweenService:Create(
			self.InnerStroke,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad),
			{Transparency = 1}
		)

		local titleOut = TweenService:Create(
			self.TitleLabel,
			TweenInfo.new(0.25, Enum.EasingStyle.Quad),
			{TextTransparency = 1}
		)

		local nameOut = TweenService:Create(
			self.PetNameLabel,
			TweenInfo.new(0.25, Enum.EasingStyle.Quad),
			{TextTransparency = 1}
		)

		local nameGlowOut = TweenService:Create(
			self.NameGlow,
			TweenInfo.new(0.25, Enum.EasingStyle.Quad),
			{Transparency = 1}
		)

		local subtitleOut = TweenService:Create(
			self.SubtitleLabel,
			TweenInfo.new(0.25, Enum.EasingStyle.Quad),
			{TextTransparency = 1}
		)

		dimOut:Play()
		cardOut:Play()
		strokeOut:Play()
		innerOut:Play()
		titleOut:Play()
		nameOut:Play()
		nameGlowOut:Play()
		subtitleOut:Play()

		if self.ViewportStroke then
			TweenService:Create(self.ViewportStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
		end

		task.delay(0.4, function()
			self:ClearPreviewModel()
			self.Card.Visible = false
			self.Dim.Visible = false
			self.Gui.Enabled = false
			self.IsShowing = false
		end)
	end)
end

local petPreview = PetPreviewUI.new()

----------------------------------------------------------------
-- HATCH SEQUENCE HELPERS
----------------------------------------------------------------
local isSequenceRunning = false

local function playScreenOnlySequence(rarity)
	if isSequenceRunning or screenVfxSystem.IsTriggering then return end
	isSequenceRunning = true

	local config = ScreenRarityConfig[rarity] or ScreenRarityConfig.Common
	screenVfxSystem:TriggerVFX(rarity)

	task.delay((config.duration or 2) + 1, function()
		isSequenceRunning = false
	end)
end

local function playPetHatchSequence(rarity, petKey)
	if isSequenceRunning or screenVfxSystem.IsTriggering then return end
	petKey = petKey or "Axolotl"
	local petConfig = PET_CONFIGS[petKey]
	if not petConfig then
		warn("No pet config for:", petKey)
		playScreenOnlySequence(rarity)
		return
	end

	isSequenceRunning = true
	rarity = rarity or "Epic"
	local config = ScreenRarityConfig[rarity] or ScreenRarityConfig.Epic

	screenVfxSystem:TriggerVFX(rarity)

	task.spawn(function()
		task.wait((config.buildupTime or 0.5) * 0.7)
		petPreview:Show(petConfig, config, 3.2)
	end)

	task.spawn(function()
		local delayTime = (config.buildupTime or 0.5) + 1.8
		task.wait(delayTime)
		petFollower:EquipPet(petKey)

		local total = (config.duration or 3) + 1.5
		task.wait(math.max(total - delayTime, 0.5))
		isSequenceRunning = false
	end)
end

----------------------------------------------------------------
-- INTERACTION SYSTEM
----------------------------------------------------------------
local currentInteractable = nil
local interactionRange = 10
local interactiveParts = {}
local lastPromptUpdate = 0
local PROMPT_UPDATE_THROTTLE = 0.1

for _, inst in ipairs(CollectionService:GetTagged("VFXInteractive")) do
	if inst:IsA("BasePart") then
		table.insert(interactiveParts, inst)
	end
end

CollectionService:GetInstanceAddedSignal("VFXInteractive"):Connect(function(inst)
	if inst:IsA("BasePart") then
		table.insert(interactiveParts, inst)
		print("✨ VFXInteractive added:", inst.Name)
	end
end)

CollectionService:GetInstanceRemovedSignal("VFXInteractive"):Connect(function(inst)
	local idx = table.find(interactiveParts, inst)
	if idx then
		table.remove(interactiveParts, idx)
	end
	if currentInteractable == inst then
		currentInteractable = nil
	end
end)

local function createInteractionPrompt()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "InteractionPrompt"
	screenGui.ResetOnSpawn = false
	local playerGui = player:WaitForChild("PlayerGui")
	screenGui.Parent = playerGui

	local frame = Instance.new("Frame")
	frame.Name = "PromptFrame"
	frame.Size = UDim2.new(0, 300, 0, 72)
	frame.Position = UDim2.new(0.5, -150, 0.82, 0)
	frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.ZIndex = 1000
	frame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = frame

	local bgGradient = Instance.new("UIGradient")
	bgGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 0.3)
	})
	bgGradient.Rotation = 45
	bgGradient.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Name = "Stroke"
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Thickness = 3
	stroke.Transparency = 1
	stroke.Parent = frame

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(1, -20, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = "[E] Hatch Pet"
	label.Font = Enum.Font.GothamBold
	label.TextSize = 28
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextTransparency = 1
	label.TextStrokeTransparency = 0.5
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.ZIndex = 1010
	label.Parent = frame

	return screenGui, frame, stroke, label
end

local interactionPrompt, promptFrame, promptStroke, promptLabel = createInteractionPrompt()
print("✅ Interaction system ready! Looking for parts tagged 'VFXInteractive'...")
print("📍 Current interactive parts:", #interactiveParts)

RunService.Heartbeat:Connect(function()
	local now = tick()
	if now - lastPromptUpdate < PROMPT_UPDATE_THROTTLE then return end
	lastPromptUpdate = now

	if not promptFrame then return end

	if not character or not humanoidRootPart
		or isSequenceRunning or screenVfxSystem.IsTriggering then
		if promptFrame.Visible then
			promptFrame.Visible = false
			promptFrame.BackgroundTransparency = 0.2
			promptStroke.Transparency = 1
			promptLabel.TextTransparency = 1
		end
		currentInteractable = nil
		return
	end

	local closestPart = nil
	local closestDistance = interactionRange
	local playerPos = humanoidRootPart.Position

	for _, part in ipairs(interactiveParts) do
		if part.Parent then
			local distance = (playerPos - part.Position).Magnitude
			if distance < closestDistance then
				closestPart = part
				closestDistance = distance
			end
		end
	end

	local shouldShow = (closestPart ~= nil)
	local wasVisible = promptFrame.Visible

	if shouldShow ~= wasVisible then
		currentInteractable = closestPart
		promptFrame.Visible = shouldShow

		if shouldShow then
			local rarityAttr = closestPart:GetAttribute("VFXRarity")
			local rarity = (typeof(rarityAttr) == "string" and rarityAttr) or "Common"
			local config = ScreenRarityConfig[rarity] or ScreenRarityConfig.Common

			promptStroke.Color = config.color
			local petAttr = closestPart:GetAttribute("PetName")
			local petName = (typeof(petAttr) == "string" and petAttr ~= "") and petAttr or "Pet"
			promptLabel.Text = "[E] Hatch " .. petName
			promptLabel.TextColor3 = config.color

			TweenService:Create(promptFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
				BackgroundTransparency = 0.2
			}):Play()
			TweenService:Create(promptStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
				Transparency = 0.3
			}):Play()
			TweenService:Create(promptLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
				TextTransparency = 0
			}):Play()
		else
			TweenService:Create(promptFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				BackgroundTransparency = 0.2
			}):Play()
			TweenService:Create(promptStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			TweenService:Create(promptLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				TextTransparency = 1
			}):Play()
		end
	elseif shouldShow and closestPart then
		local rarityAttr = closestPart:GetAttribute("VFXRarity")
		local rarity = (typeof(rarityAttr) == "string" and rarityAttr) or "Common"
		local config = ScreenRarityConfig[rarity] or ScreenRarityConfig.Common

		promptStroke.Color = config.color
		local petAttr = closestPart:GetAttribute("PetName")
		local petName = (typeof(petAttr) == "string" and petAttr ~= "") and petAttr or "Pet"
		promptLabel.Text = "[E] Hatch " .. petName
		promptLabel.TextColor3 = config.color
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or isSequenceRunning or screenVfxSystem.IsTriggering then return end
	if input.KeyCode ~= Enum.KeyCode.E then return end
	if not currentInteractable then return end

	local rarityAttr = currentInteractable:GetAttribute("VFXRarity")
	local rarity = (typeof(rarityAttr) == "string" and rarityAttr) or "Common"

	local petAttr = currentInteractable:GetAttribute("PetName")
	local petName = (typeof(petAttr) == "string" and petAttr ~= "") and petAttr or "Axolotl"

	local vfxAttr = currentInteractable:GetAttribute("VFXType")
	local vfxType = vfxAttr and string.lower(tostring(vfxAttr)) or nil

	local hasPetConfig = PET_CONFIGS[petName] ~= nil

	local mode
	if vfxType == "screenonly" then
		mode = "screen"
	elseif hasPetConfig then
		mode = "pet"
	elseif vfxType == "screen" then
		mode = "screen"
	else
		mode = hasPetConfig and "pet" or "screen"
	end

	print(("🎮 E pressed on %s rarity:%s pet:%s type:%s (hasPetConfig=%s, mode=%s)"):format(
		currentInteractable.Name,
		rarity,
		petName,
		tostring(vfxType or "nil"),
		tostring(hasPetConfig),
		mode
		))

	if promptFrame then
		promptFrame.Visible = false
		promptFrame.BackgroundTransparency = 0.2
		promptStroke.Transparency = 1
		promptLabel.TextTransparency = 1
	end

	if mode == "pet" then
		playPetHatchSequence(rarity, petName)
	else
		playScreenOnlySequence(rarity)
	end
end)

----------------------------------------------------------------
-- GLOBAL TEST FUNCTIONS
----------------------------------------------------------------
_G.TriggerVFX = function(rarity)
	rarity = rarity or "Epic"
	print("🎮 _G.TriggerVFX called with:", rarity)
	playScreenOnlySequence(rarity)
end

_G.TestEggReveal = function(rarity, petName)
	rarity = rarity or "Epic"
	petName = petName or "Axolotl"
	print("🥚 _G.TestEggReveal -> Hatch:", rarity, petName)
	playPetHatchSequence(rarity, petName)
end

----------------------------------------------------------------
-- DONE
----------------------------------------------------------------
print("✅ UNIFIED VFX SYSTEM + PET FOLLOWER v2 (REVAMPED + WINGS SYNC) LOADED!")
print("💡 Press E near eggs (tagged 'VFXInteractive') to hatch.")
print("💡 Or test in console: _G.TestEggReveal('Epic','Axolotl')")
