--[[
    PET CLAIM UI (Centered Square Modal)
    - Shows "Axolotl / Legendary pet obtained!" in the CENTER
    - Pet preview in circle faces camera + scaled correctly
    - UI pops up BEFORE follower pet spawns
    - Stays on screen until player presses "CLAIM PET"
    - On CLAIM, it closes and calls _G.EquipPet(petKey) (from PetFollower.client.lua)

    Place as LocalScript in StarterPlayerScripts.
]]

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--------------------------------------------------------
-- PET + RARITY CONFIGS (subset; can expand)
--------------------------------------------------------
local DEFAULT_FOLLOW_OFFSET      = Vector3.new(4, 2.3, -4)
local DEFAULT_FOLLOW_SMOOTHNESS  = 6
local DEFAULT_BOB_SPEED          = 1.8
local DEFAULT_BOB_HEIGHT         = 0.35
local DEFAULT_MIN_FLAT_DISTANCE  = 5

local PET_CONFIGS = {
	Axolotl = {
		displayName       = "Axolotl",
		templatePath      = {"Pets", "Axolotl"},
		subtitle          = "A magical companion that will float gracefully by your side!",
		offset            = DEFAULT_FOLLOW_OFFSET,
		followSmoothness  = DEFAULT_FOLLOW_SMOOTHNESS,
		bobSpeed          = DEFAULT_BOB_SPEED,
		bobHeight         = DEFAULT_BOB_HEIGHT,
		minFlatDistance   = DEFAULT_MIN_FLAT_DISTANCE,
	},
}

local ScreenRarityConfig = {
	Common = {
		color       = Color3.fromRGB(180, 180, 200),
		accentColor = Color3.fromRGB(220, 220, 240),
		nameColor   = Color3.fromRGB(255, 255, 255),
		titleText   = "NEW PET OBTAINED!",
	},
	Rare = {
		color       = Color3.fromRGB(0, 180, 255),
		accentColor = Color3.fromRGB(100, 220, 255),
		nameColor   = Color3.fromRGB(200, 240, 255),
		titleText   = "RARE PET OBTAINED!",
	},
	Epic = {
		color       = Color3.fromRGB(160, 60, 255),
		accentColor = Color3.fromRGB(220, 140, 255),
		nameColor   = Color3.fromRGB(255, 220, 255),
		titleText   = "EPIC PET OBTAINED!",
	},
	Legendary = {
		color       = Color3.fromRGB(255, 200, 0),
		accentColor = Color3.fromRGB(255, 240, 120),
		nameColor   = Color3.fromRGB(255, 255, 180),
		titleText   = "LEGENDARY PET OBTAINED!",
	},
}

--------------------------------------------------------
-- Helpers
--------------------------------------------------------
local function resolveTemplate(pathTable)
	if typeof(pathTable) ~= "table" then return nil end
	local obj = ReplicatedStorage
	for _, name in ipairs(pathTable) do
		obj = obj:FindFirstChild(name)
		if not obj then return nil end
	end
	return obj
end

--------------------------------------------------------
-- Claim UI Class
--------------------------------------------------------
local PetClaimUI = {}
PetClaimUI.__index = PetClaimUI

function PetClaimUI.new()
	local self = setmetatable({}, PetClaimUI)

	local gui = Instance.new("ScreenGui")
	gui.Name = "PetClaimGui"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Enabled = false
	gui.Parent = playerGui

	-- dim background
	local dim = Instance.new("Frame")
	dim.Name = "Dim"
	dim.Size = UDim2.fromScale(1, 1)
	dim.Position = UDim2.fromScale(0, 0)
	dim.BackgroundColor3 = Color3.new(0, 0, 0)
	dim.BackgroundTransparency = 1
	dim.ZIndex = 9400
	dim.Visible = false
	dim.Parent = gui

	-- main centered "square" modal
	local frame = Instance.new("Frame")
	frame.Name = "Main"
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Size = UDim2.new(0, 640, 0, 360) -- more square, not pill
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.BackgroundColor3 = Color3.fromRGB(10, 12, 26)
	frame.BackgroundTransparency = 0.02
	frame.BorderSizePixel = 0
	frame.ZIndex = 9500
	frame.Visible = false
	frame.Parent = gui

	local corner = Instance.new("UICorner")
	-- smaller radius so it's more square, not a capsule
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Name = "Outline"
	stroke.Thickness = 4
	stroke.Color = Color3.fromRGB(255, 215, 0)
	stroke.Transparency = 0.15
	stroke.Parent = frame

	local gradient = Instance.new("UIGradient")
	gradient.Rotation = 0
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 20, 80)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 20, 40)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 20, 80))
	})
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(0.5, 0.15),
		NumberSequenceKeypoint.new(1, 0.35)
	})
	gradient.Parent = frame

	-- left text container
	local left = Instance.new("Frame")
	left.Name = "Left"
	left.BackgroundTransparency = 1
	left.Size = UDim2.new(0.6, -30, 1, -90)
	left.Position = UDim2.new(0, 30, 0, 40)
	left.ZIndex = 9510
	left.Parent = frame

	-- small title at top
	local topLabel = Instance.new("TextLabel")
	topLabel.Name = "TopTitle"
	topLabel.BackgroundTransparency = 1
	topLabel.Size = UDim2.new(1, 0, 0, 24)
	topLabel.Position = UDim2.new(0, 0, 0, 0)
	topLabel.Font = Enum.Font.GothamSemibold
	topLabel.TextSize = 20
	topLabel.TextColor3 = Color3.fromRGB(255, 240, 200)
	topLabel.TextXAlignment = Enum.TextXAlignment.Left
	topLabel.TextYAlignment = Enum.TextYAlignment.Top
	topLabel.Text = "New pet unlocked!"
	topLabel.ZIndex = 9520
	topLabel.TextTransparency = 1
	topLabel.Parent = left

	-- pet name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "PetName"
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size = UDim2.new(1, 0, 0, 60)
	nameLabel.Position = UDim2.new(0, 0, 0, 24)
	nameLabel.Font = Enum.Font.GothamBlack
	nameLabel.TextSize = 46
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextYAlignment = Enum.TextYAlignment.Bottom
	nameLabel.Text = "Axolotl"
	nameLabel.ZIndex = 9520
	nameLabel.TextTransparency = 1
	nameLabel.Parent = left

	local nameStroke = Instance.new("UIStroke")
	nameStroke.Thickness = 3
	nameStroke.Color = Color3.fromRGB(0, 0, 0)
	nameStroke.Transparency = 0.6
	nameStroke.Parent = nameLabel

	-- subtitle
	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"
	subtitle.BackgroundTransparency = 1
	subtitle.Size = UDim2.new(1, 0, 0, 80)
	subtitle.Position = UDim2.new(0, 0, 0, 88)
	subtitle.Font = Enum.Font.Gotham
	subtitle.TextSize = 18
	subtitle.TextColor3 = Color3.fromRGB(210, 210, 230)
	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	subtitle.TextYAlignment = Enum.TextYAlignment.Top
	subtitle.TextWrapped = true
	subtitle.Text = "A magical companion that will float gracefully by your side!"
	subtitle.ZIndex = 9520
	subtitle.TextTransparency = 1
	subtitle.Parent = left

	-- rarity line
	local rarity = Instance.new("TextLabel")
	rarity.Name = "Rarity"
	rarity.BackgroundTransparency = 1
	rarity.Size = UDim2.new(1, 0, 0, 30)
	rarity.Position = UDim2.new(0, 0, 1, -30)
	rarity.Font = Enum.Font.GothamSemibold
	rarity.TextSize = 20
	rarity.TextColor3 = Color3.fromRGB(255, 230, 150)
	rarity.TextXAlignment = Enum.TextXAlignment.Left
	rarity.TextYAlignment = Enum.TextYAlignment.Center
	rarity.Text = "LEGENDARY PET OBTAINED!"
	rarity.ZIndex = 9520
	rarity.TextTransparency = 1
	rarity.Parent = left

	-- right preview circle
	local right = Instance.new("Frame")
	right.Name = "Right"
	right.AnchorPoint = Vector2.new(1, 0.5)
	right.Size = UDim2.new(0, 240, 0, 240)
	right.Position = UDim2.new(1, -30, 0.5, 0)
	right.BackgroundTransparency = 1
	right.ZIndex = 9510
	right.Parent = frame

	local circle = Instance.new("Frame")
	circle.Name = "Circle"
	circle.Size = UDim2.new(1, 0, 1, 0)
	circle.Position = UDim2.new(0, 0, 0, 0)
	circle.BackgroundColor3 = Color3.fromRGB(12, 16, 30)
	circle.BorderSizePixel = 0
	circle.ZIndex = 9520
	circle.Parent = right

	local circleCorner = Instance.new("UICorner")
	circleCorner.CornerRadius = UDim.new(1, 0)
	circleCorner.Parent = circle

	local circleStroke = Instance.new("UIStroke")
	circleStroke.Thickness = 5
	circleStroke.Color = Color3.fromRGB(255, 215, 0)
	circleStroke.Transparency = 0.15
	circleStroke.Parent = circle

	-- viewport for pet preview
	local viewport = Instance.new("ViewportFrame")
	viewport.Name = "Preview"
	viewport.BackgroundTransparency = 1
	viewport.Size = UDim2.new(0.82, 0, 0.82, 0)
	viewport.AnchorPoint = Vector2.new(0.5, 0.5)
	viewport.Position = UDim2.new(0.5, 0, 0.5, 0)
	viewport.ZIndex = 9530
	viewport.Ambient = Color3.new(1, 1, 1)
	viewport.LightColor = Color3.new(1, 1, 1)
	viewport.Parent = circle

	local vCorner = Instance.new("UICorner")
	vCorner.CornerRadius = UDim.new(1, 0)
	vCorner.Parent = viewport

	local vStroke = Instance.new("UIStroke")
	vStroke.Thickness = 2
	vStroke.Color = Color3.fromRGB(255, 255, 255)
	vStroke.Transparency = 0.7
	vStroke.Parent = viewport

	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = viewport

	local cam = Instance.new("Camera")
	cam.Name = "PreviewCamera"
	cam.Parent = viewport
	viewport.CurrentCamera = cam

	-- CLAIM BUTTON (bottom right of modal)
	local claimButton = Instance.new("TextButton")
	claimButton.Name = "ClaimButton"
	claimButton.AnchorPoint = Vector2.new(1, 1)
	claimButton.Size = UDim2.new(0, 210, 0, 56)
	claimButton.Position = UDim2.new(1, -30, 1, -25)
	claimButton.BackgroundColor3 = Color3.fromRGB(255, 214, 80)
	claimButton.AutoButtonColor = false
	claimButton.Text = "CLAIM PET"
	claimButton.Font = Enum.Font.GothamBold
	claimButton.TextSize = 22
	claimButton.TextColor3 = Color3.fromRGB(40, 30, 0)
	claimButton.ZIndex = 9550
	claimButton.TextTransparency = 1
	claimButton.Parent = frame

	local claimCorner = Instance.new("UICorner")
	claimCorner.CornerRadius = UDim.new(0, 14)
	claimCorner.Parent = claimButton

	local claimStroke = Instance.new("UIStroke")
	claimStroke.Thickness = 2
	claimStroke.Color = Color3.fromRGB(255, 240, 160)
	claimStroke.Transparency = 0.1
	claimStroke.Parent = claimButton

	-- hover animation
	claimButton.MouseEnter:Connect(function()
		if not frame.Visible then return end
		TweenService:Create(
			claimButton,
			TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Size = UDim2.new(0, 220, 0, 60)}
		):Play()
	end)

	claimButton.MouseLeave:Connect(function()
		if not frame.Visible then return end
		TweenService:Create(
			claimButton,
			TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Size = UDim2.new(0, 210, 0, 56)}
		):Play()
	end)

	self.Gui            = gui
	self.Dim            = dim
	self.Frame          = frame
	self.TopLabel       = topLabel
	self.NameLabel      = nameLabel
	self.SubtitleLabel  = subtitle
	self.RarityLabel    = rarity
	self.CircleStroke   = circleStroke
	self.OutlineStroke  = stroke
	self.Viewport       = viewport
	self.ViewportCamera = cam
	self.WorldModel     = worldModel
	self.CurrentModel   = nil
	self.IsShowing      = false
	self.ClaimButton    = claimButton
	self.ActiveCallback = nil
	self.ActivePetKey   = nil

	-- claim button handler
	claimButton.MouseButton1Click:Connect(function()
		if not self.IsShowing then return end
		self:Close("claim")
	end)

	return self
end

function PetClaimUI:ClearModel()
	if self.CurrentModel then
		self.CurrentModel:Destroy()
		self.CurrentModel = nil
	end
end

-- *** key part: face camera + bigger (same logic) ***
function PetClaimUI:UpdatePetModel(petConfig)
	self:ClearModel()
	if not petConfig or not petConfig.templatePath then return end

	local template = resolveTemplate(petConfig.templatePath)
	if not template or not template:IsA("Model") then
		warn("[PetClaimUI] Could not find pet template for preview:", petConfig.displayName or "unknown")
		return
	end

	local model = template:Clone()
	model.Parent = self.WorldModel
	self.CurrentModel = model

	local primary = model.PrimaryPart
		or model:FindFirstChild("HumanoidRootPart")
		or model:FindFirstChildWhichIsA("BasePart")

	if not primary then
		warn("[PetClaimUI] Pet model has no root part")
		return
	end

	model:PivotTo(CFrame.new(0, 0, 0))

	local _, size = model:GetBoundingBox()
	local maxDim = math.max(size.X, size.Y, size.Z)

	if maxDim < 5 then
		local scaleFactor = 5 / math.max(maxDim, 0.01)
		model:ScaleTo(scaleFactor)
		model:PivotTo(CFrame.new(0, 0, 0))
		_, size = model:GetBoundingBox()
		maxDim = math.max(size.X, size.Y, size.Z)
	end

	local dist   = maxDim * 1.4
	local focusY = size.Y * 0.5

	-- camera in front of pet, so pet faces us
	local camPos = Vector3.new(0, focusY + maxDim * 0.15, -dist)
	local lookAt = Vector3.new(0, focusY * 0.8, 0)

	self.ViewportCamera.CFrame = CFrame.new(camPos, lookAt)
end

function PetClaimUI:Close(reason)
	if not self.IsShowing then return end
	self.IsShowing = false

	local cb     = self.ActiveCallback
	local petKey = self.ActivePetKey

	self.ActiveCallback = nil
	self.ActivePetKey   = nil

	-- disable clicks so no double-claim
	self.ClaimButton.Active = false
	self.ClaimButton.AutoButtonColor = false

	-- close animations
	TweenService:Create(
		self.Frame,
		TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{
			Size     = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(0.5, 0, 0.5, 40)
		}
	):Play()

	TweenService:Create(self.TopLabel,      TweenInfo.new(0.18), {TextTransparency = 1}):Play()
	TweenService:Create(self.NameLabel,     TweenInfo.new(0.18), {TextTransparency = 1}):Play()
	TweenService:Create(self.SubtitleLabel, TweenInfo.new(0.18), {TextTransparency = 1}):Play()
	TweenService:Create(self.RarityLabel,   TweenInfo.new(0.18), {TextTransparency = 1}):Play()
	TweenService:Create(self.ClaimButton,   TweenInfo.new(0.18), {TextTransparency = 1}):Play()

	TweenService:Create(
		self.Dim,
		TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{BackgroundTransparency = 1}
	):Play()

	task.delay(0.25, function()
		self:ClearModel()
		self.Frame.Visible = false
		self.Gui.Enabled = false
		self.Dim.Visible = false
	end)

	-- actually give the pet AFTER the close anim kicks off
	if cb then
		task.defer(cb, petKey, reason or "claim")
	else
		-- default behaviour: use your global EquipPet from PetFollower.client.lua
		if typeof(_G.EquipPet) == "function" then
			task.defer(_G.EquipPet, petKey or "Axolotl")
		end
	end
end

-- Show only closes when CLAIM pressed (no auto fade)
function PetClaimUI:Show(petKey, rarityConfig, onClaim)
	local petConfig = PET_CONFIGS[petKey] or PET_CONFIGS.Axolotl
	rarityConfig = rarityConfig or ScreenRarityConfig.Legendary

	if typeof(onClaim) ~= "function" then
		onClaim = nil
	end

	local rarityName = "Legendary"
	for name, cfg in pairs(ScreenRarityConfig) do
		if cfg == rarityConfig then
			rarityName = name
			break
		end
	end

	self.Gui.Enabled = true
	self.Frame.Visible = true
	self.Dim.Visible = true
	self.IsShowing = true
	self.ActiveCallback = onClaim
	self.ActivePetKey   = petKey or "Axolotl"

	self.ClaimButton.Active = true

	self.TopLabel.Text = rarityConfig.titleText or ("NEW " .. string.upper(rarityName) .. " PET!")
	self.TopLabel.TextTransparency = 1

	self.NameLabel.Text = petConfig.displayName or petKey
	self.NameLabel.TextColor3 = rarityConfig.nameColor or rarityConfig.color or Color3.new(1,1,1)
	self.NameLabel.TextTransparency = 1

	self.SubtitleLabel.Text = petConfig.subtitle or "A magical companion that will follow you!"
	self.SubtitleLabel.TextTransparency = 1

	self.RarityLabel.Text = string.upper(rarityName) .. " PET OBTAINED!"
	self.RarityLabel.TextColor3 = rarityConfig.accentColor or rarityConfig.color or Color3.new(1,1,0.6)
	self.RarityLabel.TextTransparency = 1

	self.ClaimButton.TextTransparency = 1

	local color = rarityConfig.color or Color3.fromRGB(255,215,0)
	self.OutlineStroke.Color = color
	self.CircleStroke.Color = color

	-- reset positions / dim
	self.Frame.Position = UDim2.new(0.5, 0, 0.5, 40)
	self.Frame.Size = UDim2.new(0, 0, 0, 0)
	self.Dim.BackgroundTransparency = 1

	self:UpdatePetModel(petConfig)

	-- open animations
	TweenService:Create(
		self.Dim,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{BackgroundTransparency = 0.35}
	):Play()

	TweenService:Create(
		self.Frame,
		TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Size     = UDim2.new(0, 640, 0, 360),
			Position = UDim2.new(0.5, 0, 0.5, 0)
		}
	):Play()

	TweenService:Create(self.TopLabel,      TweenInfo.new(0.22), {TextTransparency = 0}):Play()
	TweenService:Create(self.NameLabel,     TweenInfo.new(0.25), {TextTransparency = 0}):Play()
	TweenService:Create(self.SubtitleLabel, TweenInfo.new(0.28), {TextTransparency = 0}):Play()
	TweenService:Create(self.RarityLabel,   TweenInfo.new(0.28), {TextTransparency = 0}):Play()
	TweenService:Create(self.ClaimButton,   TweenInfo.new(0.28), {TextTransparency = 0}):Play()
end

--------------------------------------------------------
-- init + hook global
--------------------------------------------------------
local claimUI = PetClaimUI.new()

_G.ShowPetPreview = function(petKey, rarityConfig, onClaim)
	claimUI:Show(petKey or "Axolotl", rarityConfig, onClaim)
end

print("✅ PetClaimUI (centered modal, claim-only close) loaded – use _G.ShowPetPreview")
