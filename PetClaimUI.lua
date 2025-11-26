--[[
    PET CLAIM UI (Wide Bottom Banner)
    - Shows "Axolotl / Legendary pet obtained!" bar
    - Pet in circle faces camera + scaled correctly
    - UI pops up BEFORE follower pet spawns

    Place as LocalScript (e.g. in StarterPlayerScripts).
]]

local Players        = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService   = game:GetService("TweenService")

local player  = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--------------------------------------------------------
-- Shared PET + RARITY CONFIGS (small subset)
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

	-- main bar
	local frame = Instance.new("Frame")
	frame.Name = "Main"
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Size = UDim2.new(0, 820, 0, 230)
	frame.Position = UDim2.new(0.5, 0, 0.78, 0)
	frame.BackgroundColor3 = Color3.fromRGB(10, 12, 26)
	frame.BackgroundTransparency = 0.08
	frame.BorderSizePixel = 0
	frame.ZIndex = 9500
	frame.Visible = false
	frame.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 40)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Name = "Outline"
	stroke.Thickness = 4
	stroke.Color = Color3.fromRGB(255, 215, 0)
	stroke.Transparency = 0.15
	stroke.Parent = frame

	local gradient = Instance.new("UIGradient")
	gradient.Rotation = 0
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
	left.Size = UDim2.new(0.6, -30, 1, -40)
	left.Position = UDim2.new(0, 30, 0, 20)
	left.ZIndex = 9510
	left.Parent = frame

	-- pet name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "PetName"
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size = UDim2.new(1, 0, 0, 60)
	nameLabel.Position = UDim2.new(0, 0, 0, 0)
	nameLabel.Font = Enum.Font.GothamBlack
	nameLabel.TextSize = 48
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
	subtitle.Size = UDim2.new(1, 0, 0, 60)
	subtitle.Position = UDim2.new(0, 0, 0, 60)
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
	rarity.Size = UDim2.new(1, 0, 0, 40)
	rarity.Position = UDim2.new(0, 0, 1, -40)
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
	right.Position = UDim2.new(1, -40, 0.5, 0)
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

	-- viewport
	local viewport = Instance.new("ViewportFrame")
	viewport.Name = "Preview"
	viewport.BackgroundTransparency = 1
	viewport.Size = UDim2.new(0.8, 0, 0.8, 0)
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

	self.Gui            = gui
	self.Frame          = frame
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

	return self
end

function PetClaimUI:ClearModel()
	if self.CurrentModel then
		self.CurrentModel:Destroy()
		self.CurrentModel = nil
	end
end

-- *** key part: face camera + bigger ***
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

function PetClaimUI:Show(petKey, rarityConfig, duration)
	local petConfig = PET_CONFIGS[petKey] or PET_CONFIGS.Axolotl
	rarityConfig = rarityConfig or ScreenRarityConfig.Legendary
	duration = duration or 3.5

	local rarityName = "Legendary"
	for name, cfg in pairs(ScreenRarityConfig) do
		if cfg == rarityConfig then
			rarityName = name
			break
		end
	end

	self.Gui.Enabled = true
	self.Frame.Visible = true
	self.IsShowing = true

	self.NameLabel.Text = petConfig.displayName or petKey
	self.NameLabel.TextColor3 = rarityConfig.nameColor or rarityConfig.color or Color3.new(1,1,1)
	self.SubtitleLabel.Text = petConfig.subtitle or "A magical companion that will follow you!"
	self.RarityLabel.Text = string.upper(rarityName) .. " PET OBTAINED!"
	self.RarityLabel.TextColor3 = rarityConfig.accentColor or rarityConfig.color or Color3.new(1,1,0.6)

	local color = rarityConfig.color or Color3.fromRGB(255,215,0)
	self.OutlineStroke.Color = color
	self.CircleStroke.Color = color

	self.Frame.Position = UDim2.new(0.5, 0, 0.9, 40)
	self.Frame.Size = UDim2.new(0, 0, 0, 0)
	self.NameLabel.TextTransparency = 1
	self.SubtitleLabel.TextTransparency = 1
	self.RarityLabel.TextTransparency = 1

	self:UpdatePetModel(petConfig)

	TweenService:Create(
		self.Frame,
		TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Size     = UDim2.new(0, 820, 0, 230),
			Position = UDim2.new(0.5, 0, 0.78, 0)
		}
	):Play()

	TweenService:Create(self.NameLabel, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
	TweenService:Create(self.SubtitleLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
	TweenService:Create(self.RarityLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()

	task.delay(duration, function()
		TweenService:Create(
			self.Frame,
			TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				Size     = UDim2.new(0, 0, 0, 0),
				Position = UDim2.new(0.5, 0, 0.9, 40)
			}
		):Play()

		TweenService:Create(self.NameLabel, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
		TweenService:Create(self.SubtitleLabel, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
		TweenService:Create(self.RarityLabel, TweenInfo.new(0.2), {TextTransparency = 1}):Play()

		task.delay(0.3, function()
			self:ClearModel()
			self.Frame.Visible = false
			self.Gui.Enabled = false
			self.IsShowing = false
		end)
	end)
end

--------------------------------------------------------
-- init + hook global
--------------------------------------------------------
local claimUI = PetClaimUI.new()

_G.ShowPetPreview = function(petKey, rarityConfig, duration)
	claimUI:Show(petKey or "Axolotl", rarityConfig, duration)
end

print("✅ PetClaimUI (wide banner) loaded – waiting for _G.ShowPetPreview calls")
