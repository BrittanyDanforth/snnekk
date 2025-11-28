-- StarterPlayerScripts / LifeClient (LocalScript)
-- BitLife-style UI: gender + name intro, life feed, stats, age button, event popups.

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local Lighting          = game:GetService("Lighting")

local player = Players.LocalPlayer

----------------------------------------------------------------
-- REMOTES
----------------------------------------------------------------

local remotesFolder = ReplicatedStorage:FindFirstChild("Life") or ReplicatedStorage:FindFirstChild("LifeRemotes")
if not remotesFolder then
	remotesFolder = ReplicatedStorage:WaitForChild("Life", 5)
end
if not remotesFolder then
	remotesFolder = ReplicatedStorage:WaitForChild("LifeRemotes")
end

local RequestAgeUp = remotesFolder:WaitForChild("RequestAgeUp")
local PresentEvent = remotesFolder:WaitForChild("PresentEvent")
local SubmitChoice = remotesFolder:WaitForChild("SubmitChoice")
local SyncState    = remotesFolder:WaitForChild("SyncState")
local SetLifeInfo  = remotesFolder:WaitForChild("SetLifeInfo")

----------------------------------------------------------------
-- STATE
----------------------------------------------------------------

local currentState    = nil
local awaitingEvent   = false
local hasShownAgeHint = false

----------------------------------------------------------------
-- HELPERS
----------------------------------------------------------------

local TITLE_FONT = Enum.Font.FredokaOne
local BODY_FONT  = Enum.Font.Ubuntu
local CHIP_FONT  = Enum.Font.Roboto

local Colors = {
	Background    = Color3.fromRGB(232, 238, 248),
	CardWhite     = Color3.fromRGB(255, 255, 255),
	TextDark      = Color3.fromRGB(31, 41, 55),
	TextMuted     = Color3.fromRGB(107, 114, 128),
	BitLifeBlue   = Color3.fromRGB(37, 99, 235),
	BitLifeBlueHi = Color3.fromRGB(59, 130, 246),
	BitLifeGreen  = Color3.fromRGB(34, 197, 94),
	BitLifePink   = Color3.fromRGB(244, 114, 182),
	BitLifeOrange = Color3.fromRGB(249, 115, 22),
	BitLifeYellow = Color3.fromRGB(252, 211, 77),
	BitLifeRed    = Color3.fromRGB(234, 88, 12),
	SoftGrey      = Color3.fromRGB(229, 231, 235),
	StatBarGrey   = Color3.fromRGB(209, 213, 219),
}

local function createUICorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
	return c
end

local function createUIStroke(parent, thickness, transparency, color)
	local s = Instance.new("UIStroke")
	s.Thickness = thickness
	s.Transparency = transparency
	s.Color = color
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function tween(obj, info, props)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

local blurEffect = Lighting:FindFirstChild("LifeOverlayBlur")
if not blurEffect then
	blurEffect = Instance.new("BlurEffect")
	blurEffect.Name = "LifeOverlayBlur"
	blurEffect.Parent = Lighting
end
blurEffect.Size = 0

local overlayVisibility = {}
local overlayBlurMap = {}
local activeOverlayCount = 0

local function updateBlur()
	local target = activeOverlayCount > 0 and 20 or 0
	tween(blurEffect, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = target,
	})
end

local function registerOverlay(frame, affectsBlur)
	overlayVisibility[frame] = false
	overlayBlurMap[frame] = affectsBlur
	frame.Visible = false
end

local function setOverlayVisible(frame, shouldShow)
	if not frame then
		return
	end

	if overlayVisibility[frame] == shouldShow then
		frame.Visible = shouldShow
		return
	end

	overlayVisibility[frame] = shouldShow
	frame.Visible = shouldShow

	if overlayBlurMap[frame] then
		if shouldShow then
			activeOverlayCount += 1
		else
			activeOverlayCount = math.max(0, activeOverlayCount - 1)
		end
		updateBlur()
	end
end

----------------------------------------------------------------
-- ROOT GUI + BACKGROUND (light, not phone-frame)
----------------------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LifeGui"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local bg = Instance.new("Frame")
bg.Size = UDim2.fromScale(1, 1)
bg.BackgroundColor3 = Colors.Background
bg.Parent = screenGui

local bgGrad = Instance.new("UIGradient")
bgGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(244, 248, 255)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(229, 246, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(243, 232, 255)),
})
bgGrad.Rotation = 25
bgGrad.Parent = bg

-- main card
local root = Instance.new("Frame")
root.Name = "RootCard"
root.AnchorPoint = Vector2.new(0.5, 0.5)
root.Position = UDim2.fromScale(0.5, 0.5)
root.Size = UDim2.new(0.96, 0, 0.94, 0)
root.BackgroundColor3 = Color3.fromRGB(249, 250, 255)
root.Parent = bg
createUICorner(root, 28)
createUIStroke(root, 2, 0.8, Color3.fromRGB(203, 213, 225))

----------------------------------------------------------------
-- HEADER (avatar + name + age/year, money chip right)
----------------------------------------------------------------

local header = Instance.new("Frame")
header.Name = "Header"
header.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
header.Size = UDim2.new(1, -32, 0, 70)
header.Position = UDim2.new(0, 16, 0, 14)
header.Parent = root
createUICorner(header, 22)
createUIStroke(header, 1, 0.8, Color3.fromRGB(221, 231, 247))

local headerPad = Instance.new("UIPadding")
headerPad.PaddingLeft  = UDim.new(0, 16)
headerPad.PaddingRight = UDim.new(0, 16)
headerPad.Parent = header

local headerLayout = Instance.new("UIListLayout")
headerLayout.FillDirection = Enum.FillDirection.Horizontal
headerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
headerLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
headerLayout.Padding = UDim.new(0, 12)
headerLayout.Parent = header

local avatarFrame = Instance.new("Frame")
avatarFrame.Size = UDim2.new(0, 46, 0, 46)
avatarFrame.BackgroundColor3 = Color3.fromRGB(237, 244, 255)
avatarFrame.Parent = header
createUICorner(avatarFrame, 23)
createUIStroke(avatarFrame, 1, 0.7, Color3.fromRGB(191, 219, 254))

local avatarEmoji = Instance.new("TextLabel")
avatarEmoji.BackgroundTransparency = 1
avatarEmoji.Size = UDim2.fromScale(1, 1)
avatarEmoji.Font = BODY_FONT
avatarEmoji.TextSize = 26
avatarEmoji.TextColor3 = Color3.fromRGB(55, 65, 81)
avatarEmoji.Text = "👶"
avatarEmoji.Parent = avatarFrame

local nameAgeFrame = Instance.new("Frame")
nameAgeFrame.BackgroundTransparency = 1
nameAgeFrame.Size = UDim2.new(0.6, 0, 1, 0)
nameAgeFrame.Parent = header

local nameAgeLayout = Instance.new("UIListLayout")
nameAgeLayout.FillDirection = Enum.FillDirection.Vertical
nameAgeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
nameAgeLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
nameAgeLayout.Padding = UDim.new(0, 2)
nameAgeLayout.Parent = nameAgeFrame

local nameLabel = Instance.new("TextLabel")
nameLabel.BackgroundTransparency = 1
nameLabel.Size = UDim2.new(1, 0, 0.55, 0)
nameLabel.Font = TITLE_FONT
nameLabel.TextSize = 20
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.TextColor3 = Color3.fromRGB(15, 23, 42)
nameLabel.Text = "New Life"
nameLabel.Parent = nameAgeFrame

local ageYearLabel = Instance.new("TextLabel")
ageYearLabel.BackgroundTransparency = 1
ageYearLabel.Size = UDim2.new(1, 0, 0.45, 0)
ageYearLabel.Font = BODY_FONT
ageYearLabel.TextSize = 14
ageYearLabel.TextXAlignment = Enum.TextXAlignment.Left
ageYearLabel.TextColor3 = Color3.fromRGB(107, 114, 128)
ageYearLabel.Text = "Age 0 • Year 2025"
ageYearLabel.Parent = nameAgeFrame

local moneyChip = Instance.new("TextLabel")
moneyChip.BackgroundColor3 = Color3.fromRGB(22, 163, 74)
moneyChip.Font = CHIP_FONT
moneyChip.TextSize = 18
moneyChip.TextColor3 = Color3.new(1, 1, 1)
moneyChip.TextXAlignment = Enum.TextXAlignment.Center
moneyChip.AnchorPoint = Vector2.new(1, 0.5)
moneyChip.Position = UDim2.new(1, -4, 0.5, 0)
moneyChip.Size = UDim2.new(0, 120, 0, 40)
moneyChip.Text = "$0"
moneyChip.Parent = header
createUICorner(moneyChip, 20)

----------------------------------------------------------------
-- MIDDLE: feed (center) + stats bar at bottom
----------------------------------------------------------------

-- Feed card
local feedCard = Instance.new("Frame")
feedCard.Name = "FeedCard"
feedCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
feedCard.Size = UDim2.new(1, -32, 1, -210)
feedCard.Position = UDim2.new(0, 16, 0, 96)
feedCard.Parent = root
createUICorner(feedCard, 22)
createUIStroke(feedCard, 1, 0.82, Color3.fromRGB(221, 231, 247))

local feedPad = Instance.new("UIPadding")
feedPad.PaddingLeft   = UDim.new(0, 18)
feedPad.PaddingRight  = UDim.new(0, 18)
feedPad.PaddingTop    = UDim.new(0, 14)
feedPad.PaddingBottom = UDim.new(0, 14)
feedPad.Parent = feedCard

local feedTitle = Instance.new("TextLabel")
feedTitle.BackgroundTransparency = 1
feedTitle.Size = UDim2.new(1, 0, 0, 26)
feedTitle.Font = TITLE_FONT
feedTitle.TextSize = 18
feedTitle.TextXAlignment = Enum.TextXAlignment.Left
feedTitle.TextColor3 = Color3.fromRGB(31, 41, 55)
feedTitle.Text = "Life Feed"
feedTitle.Parent = feedCard

local feedScroll = Instance.new("ScrollingFrame")
feedScroll.Name = "FeedScroll"
feedScroll.BackgroundTransparency = 1
feedScroll.Size = UDim2.new(1, 0, 1, -32)
feedScroll.Position = UDim2.new(0, 0, 0, 30)
feedScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
feedScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
feedScroll.ScrollBarThickness = 6
feedScroll.Parent = feedCard

local feedLayout = Instance.new("UIListLayout")
feedLayout.FillDirection = Enum.FillDirection.Vertical
feedLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
feedLayout.VerticalAlignment   = Enum.VerticalAlignment.Top
feedLayout.Padding = UDim.new(0, 8)
feedLayout.SortOrder = Enum.SortOrder.LayoutOrder
feedLayout.Parent = feedScroll

local function addFeedEntry(text)
	if not text or text == "" then
		return
	end

	local bubble = Instance.new("Frame")
	bubble.BackgroundColor3 = Color3.fromRGB(248, 250, 252)
	bubble.Size = UDim2.new(1, 0, 0, 44)
	bubble.AutomaticSize = Enum.AutomaticSize.Y
	bubble.Parent = feedScroll
	createUICorner(bubble, 16)
	createUIStroke(bubble, 1, 0.9, Color3.fromRGB(229, 231, 235))

	local pad = Instance.new("UIPadding")
	pad.PaddingLeft   = UDim.new(0, 10)
	pad.PaddingRight  = UDim.new(0, 10)
	pad.PaddingTop    = UDim.new(0, 6)
	pad.PaddingBottom = UDim.new(0, 6)
	pad.Parent = bubble

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 0, 0)
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.Font = BODY_FONT
	label.TextSize = 15
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.TextColor3 = Color3.fromRGB(55, 65, 81)
	label.Text = text
	label.Parent = bubble

	bubble.BackgroundTransparency = 1
	tween(bubble, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0
	})

	task.delay(0.05, function()
		feedScroll.CanvasPosition = Vector2.new(
			0,
			math.max(0, feedScroll.AbsoluteCanvasSize.Y - feedScroll.AbsoluteWindowSize.Y)
		)
	end)
end

----------------------------------------------------------------
-- STATS BAR (bottom of screen)
----------------------------------------------------------------

local statsBar = Instance.new("Frame")
statsBar.Name = "StatsBar"
statsBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
statsBar.Size = UDim2.new(1, -32, 0, 70)
statsBar.AnchorPoint = Vector2.new(0.5, 1)
statsBar.Position = UDim2.new(0.5, 0, 1, -140)
statsBar.Parent = root
createUICorner(statsBar, 20)
createUIStroke(statsBar, 1, 0.85, Color3.fromRGB(221, 231, 247))

local statsPad = Instance.new("UIPadding")
statsPad.PaddingLeft  = UDim.new(0, 16)
statsPad.PaddingRight = UDim.new(0, 16)
statsPad.Parent = statsBar

local statsLayout = Instance.new("UIListLayout")
statsLayout.FillDirection = Enum.FillDirection.Horizontal
statsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
statsLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
statsLayout.Padding = UDim.new(0, 16)
statsLayout.Parent = statsBar

local statMeta = {
	{ key = "Happiness", icon = "😊", label = "Happiness" },
	{ key = "Health",    icon = "❤️", label = "Health"    },
	{ key = "Smarts",    icon = "🧠", label = "Smarts"    },
	{ key = "Looks",     icon = "✨", label = "Looks"     },
}

local statCards = {}

for _, info in ipairs(statMeta) do
	local holder = Instance.new("Frame")
	holder.BackgroundTransparency = 1
	holder.Size = UDim2.new(0.24, -8, 1, 0)
	holder.Parent = statsBar

	local headerRow = Instance.new("Frame")
	headerRow.BackgroundTransparency = 1
	headerRow.Size = UDim2.new(1, 0, 0, 20)
	headerRow.Parent = holder

	local nameLabelStat = Instance.new("TextLabel")
	nameLabelStat.BackgroundTransparency = 1
	nameLabelStat.Size = UDim2.new(0.65, 0, 1, 0)
	nameLabelStat.Font = BODY_FONT
	nameLabelStat.TextSize = 13
	nameLabelStat.TextXAlignment = Enum.TextXAlignment.Left
	nameLabelStat.TextColor3 = Colors.TextDark
	nameLabelStat.Text = string.format("%s %s", info.icon, info.label)
	nameLabelStat.Parent = headerRow

	local valueLabel = Instance.new("TextLabel")
	valueLabel.BackgroundTransparency = 1
	valueLabel.Size = UDim2.new(0.35, 0, 1, 0)
	valueLabel.Position = UDim2.new(0.65, 0, 0, 0)
	valueLabel.Font = BODY_FONT
	valueLabel.TextSize = 13
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.TextColor3 = Colors.TextMuted
	valueLabel.Text = "0%"
	valueLabel.Parent = headerRow

	local barRow = Instance.new("Frame")
	barRow.BackgroundTransparency = 1
	barRow.Size = UDim2.new(1, 0, 0, 28)
	barRow.Position = UDim2.new(0, 0, 0, 24)
	barRow.Parent = holder

	local barBg = Instance.new("Frame")
	barBg.AnchorPoint = Vector2.new(0, 0.5)
	barBg.Position = UDim2.new(0, 0, 0.5, 0)
	barBg.Size = UDim2.new(1, -84, 0, 10)
	barBg.BackgroundColor3 = Colors.SoftGrey
	barBg.Parent = barRow
	createUICorner(barBg, 5)

	local barFill = Instance.new("Frame")
	barFill.BackgroundColor3 = Colors.BitLifeBlueHi
	barFill.Size = UDim2.new(0, 0, 1, 0)
	barFill.Parent = barBg
	createUICorner(barFill, 5)

	local boostButton = Instance.new("TextButton")
	boostButton.AnchorPoint = Vector2.new(1, 0.5)
	boostButton.Position = UDim2.new(1, 0, 0.5, 0)
	boostButton.Size = UDim2.new(0, 72, 0, 24)
	boostButton.BackgroundColor3 = Colors.BitLifeOrange
	boostButton.AutoButtonColor = false
	boostButton.Font = CHIP_FONT
	boostButton.TextSize = 12
	boostButton.TextColor3 = Color3.new(1, 1, 1)
	boostButton.Text = "+ Boost!"
	boostButton.Parent = barRow
	boostButton.Visible = false
	createUICorner(boostButton, 50)

	boostButton.MouseButton1Click:Connect(function()
		addFeedEntry(string.format("You boosted your %s temporarily.", info.label))
	end)

	statCards[info.key] = {
		valueLabel = valueLabel,
		barFill    = barFill,
		boost      = boostButton,
	}
end

----------------------------------------------------------------
-- BOTTOM NAV + AGE BUTTON (BitLife style)
----------------------------------------------------------------

local bottom = Instance.new("Frame")
bottom.Name = "Bottom"
bottom.BackgroundTransparency = 1
bottom.Size = UDim2.new(1, -32, 0, 110)
bottom.AnchorPoint = Vector2.new(0.5, 1)
bottom.Position = UDim2.new(0.5, 0, 1, -10)
bottom.Parent = root

local navBar = Instance.new("Frame")
navBar.Name = "NavBar"
navBar.AnchorPoint = Vector2.new(0.5, 1)
navBar.Position = UDim2.new(0.5, 0, 1, 0)
navBar.Size = UDim2.new(1, 0, 0, 70)
navBar.BackgroundColor3 = Color3.fromRGB(27, 42, 89)
navBar.Parent = bottom
createUICorner(navBar, 22)

local navLayout = Instance.new("UIListLayout")
navLayout.FillDirection = Enum.FillDirection.Horizontal
navLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
navLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
navLayout.Padding = UDim.new(0, 18)
navLayout.Parent = navBar

local navItems = {
	{ icon = "📚", text = "Occupation" },
	{ icon = "💼", text = "Assets"     },
	{ icon = "❤️", text = "Relationships" },
	{ icon = "🎭", text = "Activities" },
	{ icon = "📊", text = "Stats"      },
}

for _, info in ipairs(navItems) do
	local btn = Instance.new("TextButton")
	btn.BackgroundTransparency = 1
	btn.AutoButtonColor = false
	btn.Size = UDim2.new(0, 80, 0, 48)
	btn.Parent = navBar

	local v = Instance.new("UIListLayout")
	v.FillDirection = Enum.FillDirection.Vertical
	v.HorizontalAlignment = Enum.HorizontalAlignment.Center
	v.VerticalAlignment   = Enum.VerticalAlignment.Center
	v.Parent = btn

	local icon = Instance.new("TextLabel")
	icon.BackgroundTransparency = 1
	icon.Size = UDim2.new(1, 0, 0, 22)
	icon.Font = BODY_FONT
	icon.TextSize = 18
	icon.TextColor3 = Color3.fromRGB(248, 250, 252)
	icon.Text = info.icon
	icon.Parent = btn

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 0, 18)
	label.Font = BODY_FONT
	label.TextSize = 11
	label.TextColor3 = Color3.fromRGB(148, 163, 184)
	label.Text = info.text
	label.Parent = btn

	btn.MouseEnter:Connect(function()
		icon.TextColor3 = Color3.fromRGB(251, 191, 36)
	end)
	btn.MouseLeave:Connect(function()
		icon.TextColor3 = Color3.fromRGB(248, 250, 252)
	end)
end

-- big green Age button sitting above nav bar with white perch + glow ring
local ageButtonRing = Instance.new("Frame")
ageButtonRing.Name = "AgeButtonRing"
ageButtonRing.AnchorPoint = Vector2.new(0.5, 1)
ageButtonRing.Position = UDim2.new(0.5, 0, 0, -6)
ageButtonRing.Size = UDim2.new(0, 136, 0, 136)
ageButtonRing.BackgroundColor3 = Color3.new(1, 1, 1)
ageButtonRing.ZIndex = 1
ageButtonRing.Visible = false
ageButtonRing.Parent = bottom
createUICorner(ageButtonRing, 68)
createUIStroke(ageButtonRing, 1.8, 0.5, Color3.fromRGB(226, 232, 240))

local ageFocusRing = Instance.new("Frame")
ageFocusRing.Name = "AgeFocusRing"
ageFocusRing.AnchorPoint = Vector2.new(0.5, 0.5)
ageFocusRing.Position = UDim2.fromScale(0.5, 0.5)
ageFocusRing.Size = UDim2.new(1, 32, 1, 32)
ageFocusRing.BackgroundTransparency = 1
ageFocusRing.ZIndex = 0
ageFocusRing.Visible = false
ageFocusRing.Parent = ageButtonRing
local ageFocusStroke = createUIStroke(ageFocusRing, 3, 0, Colors.BitLifeRed)
ageFocusStroke.LineJoinMode = Enum.LineJoinMode.Round

local tutorialHand = Instance.new("TextLabel")
tutorialHand.BackgroundTransparency = 1
tutorialHand.Size = UDim2.new(0, 60, 0, 60)
tutorialHand.AnchorPoint = Vector2.new(0.5, 1)
tutorialHand.Position = UDim2.new(0.5, 0, 0, -8)
tutorialHand.Font = BODY_FONT
tutorialHand.TextSize = 44
tutorialHand.TextColor3 = Colors.BitLifeYellow
tutorialHand.Text = "☝️"
tutorialHand.Visible = false
tutorialHand.ZIndex = 3
tutorialHand.Parent = ageButtonRing

local ageButton = Instance.new("TextButton")
ageButton.Name = "AgeButton"
ageButton.AnchorPoint = Vector2.new(0.5, 0.5)
ageButton.Position = UDim2.fromScale(0.5, 0.5)
ageButton.Size = UDim2.new(0, 110, 0, 110)
ageButton.BackgroundColor3 = Colors.BitLifeGreen
ageButton.AutoButtonColor = false
ageButton.Text = ""
ageButton.ZIndex = 2
ageButton.Parent = ageButtonRing
createUICorner(ageButton, 55)
createUIStroke(ageButton, 3, 0.15, Color3.fromRGB(21, 128, 61))

local agePlus = Instance.new("TextLabel")
agePlus.BackgroundTransparency = 1
agePlus.Size = UDim2.new(1, 0, 0, 40)
agePlus.Position = UDim2.new(0, 0, 0, 18)
agePlus.Font = TITLE_FONT
agePlus.TextSize = 34
agePlus.TextColor3 = Color3.new(1, 1, 1)
agePlus.Text = "+"
agePlus.Parent = ageButton

local ageText = Instance.new("TextLabel")
ageText.BackgroundTransparency = 1
ageText.Size = UDim2.new(1, 0, 0, 30)
ageText.Position = UDim2.new(0, 0, 0, 56)
ageText.Font = CHIP_FONT
ageText.TextSize = 20
ageText.TextColor3 = Color3.new(1, 1, 1)
ageText.Text = "Age"
ageText.Parent = ageButton

local tutorialOverlay = Instance.new("Frame")
tutorialOverlay.Name = "AgeTutorial"
tutorialOverlay.Size = UDim2.new(1, 0, 0, 200)
tutorialOverlay.AnchorPoint = Vector2.new(0.5, 0)
tutorialOverlay.Position = UDim2.new(0.5, 0, 0, 0)
tutorialOverlay.BackgroundTransparency = 1
tutorialOverlay.ZIndex = 8
tutorialOverlay.Visible = false
tutorialOverlay.Parent = screenGui

local tutorialText = Instance.new("TextLabel")
tutorialText.BackgroundTransparency = 1
tutorialText.Size = UDim2.new(0.7, 0, 0, 120)
tutorialText.AnchorPoint = Vector2.new(0.5, 0)
tutorialText.Position = UDim2.new(0.5, 0, 0, 26)
tutorialText.Font = BODY_FONT
tutorialText.TextSize = 20
tutorialText.TextColor3 = Colors.BitLifeYellow
tutorialText.TextWrapped = true
tutorialText.Text = "Press Age to grow older one year at a time.\nMake choices as you go.\nLive your best (or worst) life."
tutorialText.Parent = tutorialOverlay

registerOverlay(tutorialOverlay, false)

local function pulseFocusRing()
	if not ageFocusRing.Visible then
		ageFocusRing.Visible = true
	end

	ageFocusRing.Size = UDim2.new(1, 10, 1, 10)
	tween(ageFocusRing, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true), {
		Size = UDim2.new(1.12, 28, 1.12, 28),
	})
end

local function hideAgeTutorial()
	setOverlayVisible(tutorialOverlay, false)
	ageFocusRing.Visible = false
	tutorialHand.Visible = false
end

local function showAgeTutorial()
	if hasShownAgeHint then
		return
	end

	hasShownAgeHint = true
	setOverlayVisible(tutorialOverlay, true)
	tutorialHand.Visible = true
	pulseFocusRing()
end

----------------------------------------------------------------
-- EVENT MODAL (BitLife-style red header + blue buttons)
----------------------------------------------------------------

local eventOverlay = Instance.new("Frame")
eventOverlay.Name = "EventOverlay"
eventOverlay.Size = UDim2.fromScale(1, 1)
eventOverlay.BackgroundTransparency = 1
eventOverlay.Visible = false
eventOverlay.ZIndex = 25
eventOverlay.Parent = screenGui
registerOverlay(eventOverlay, true)

local eventDim = Instance.new("Frame")
eventDim.Size = UDim2.fromScale(1, 1)
eventDim.BackgroundColor3 = Color3.new(0, 0, 0)
eventDim.BackgroundTransparency = 0.45
eventDim.Parent = eventOverlay

local eventShadow = Instance.new("Frame")
eventShadow.AnchorPoint = Vector2.new(0.5, 0.5)
eventShadow.Position = UDim2.fromScale(0.5, 0.5)
eventShadow.Size = UDim2.new(0, 386, 0, 466)
eventShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
eventShadow.BackgroundTransparency = 0.85
eventShadow.Parent = eventOverlay
createUICorner(eventShadow, 26)

local eventCard = Instance.new("Frame")
eventCard.AnchorPoint = Vector2.new(0.5, 0.5)
eventCard.Position = UDim2.fromScale(0.5, 0.5)
eventCard.Size = UDim2.new(0, 360, 0, 440)
eventCard.BackgroundColor3 = Colors.CardWhite
eventCard.Parent = eventOverlay
createUICorner(eventCard, 26)
local eventBorder = createUIStroke(eventCard, 2, 0, Colors.BitLifeRed)
eventBorder.Color = Colors.BitLifeRed

local eventHeaderStrip = Instance.new("Frame")
eventHeaderStrip.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
eventHeaderStrip.Size = UDim2.new(1, 0, 0, 110)
eventHeaderStrip.Parent = eventCard
createUICorner(eventHeaderStrip, 26)
eventHeaderStrip.ClipsDescendants = true

local headerRow = Instance.new("Frame")
headerRow.BackgroundTransparency = 1
headerRow.Size = UDim2.new(1, -40, 0, 70)
headerRow.Position = UDim2.new(0, 20, 0, 18)
headerRow.Parent = eventHeaderStrip

local headerLayout = Instance.new("UIListLayout")
headerLayout.FillDirection = Enum.FillDirection.Horizontal
headerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
headerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
headerLayout.Padding = UDim.new(0, 12)
headerLayout.Parent = headerRow

local headerAvatar = Instance.new("Frame")
headerAvatar.Size = UDim2.new(0, 56, 0, 56)
headerAvatar.BackgroundColor3 = Color3.fromRGB(255, 247, 237)
headerAvatar.Parent = headerRow
createUICorner(headerAvatar, 28)
createUIStroke(headerAvatar, 1.2, 0.5, Colors.BitLifeOrange)

local headerAvatarEmoji = Instance.new("TextLabel")
headerAvatarEmoji.BackgroundTransparency = 1
headerAvatarEmoji.Size = UDim2.fromScale(1, 1)
headerAvatarEmoji.Font = BODY_FONT
headerAvatarEmoji.TextSize = 32
headerAvatarEmoji.TextColor3 = Colors.TextDark
headerAvatarEmoji.Text = "🙂"
headerAvatarEmoji.Parent = headerAvatar

local headerNameColumn = Instance.new("Frame")
headerNameColumn.BackgroundTransparency = 1
headerNameColumn.Size = UDim2.new(0.7, 0, 1, 0)
headerNameColumn.Parent = headerRow

local headerNameLayout = Instance.new("UIListLayout")
headerNameLayout.FillDirection = Enum.FillDirection.Vertical
headerNameLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
headerNameLayout.VerticalAlignment = Enum.VerticalAlignment.Center
headerNameLayout.Padding = UDim.new(0, 2)
headerNameLayout.Parent = headerNameColumn

local personNameLabel = Instance.new("TextLabel")
personNameLabel.BackgroundTransparency = 1
personNameLabel.Size = UDim2.new(1, 0, 0, 30)
personNameLabel.Font = TITLE_FONT
personNameLabel.TextSize = 22
personNameLabel.TextXAlignment = Enum.TextXAlignment.Left
personNameLabel.TextColor3 = Colors.TextDark
personNameLabel.Text = "Bradley Allen"
personNameLabel.Parent = headerNameColumn

local relationshipLabel = Instance.new("TextLabel")
relationshipLabel.BackgroundTransparency = 1
relationshipLabel.Size = UDim2.new(1, 0, 0, 20)
relationshipLabel.Font = BODY_FONT
relationshipLabel.TextSize = 15
relationshipLabel.TextColor3 = Colors.TextMuted
relationshipLabel.TextXAlignment = Enum.TextXAlignment.Left
relationshipLabel.Text = "Relationship"
relationshipLabel.Parent = headerNameColumn

local badgeBacking = Instance.new("Frame")
badgeBacking.AnchorPoint = Vector2.new(1, 0.5)
badgeBacking.Position = UDim2.new(1, -20, 0.5, 0)
badgeBacking.Size = UDim2.new(0, 160, 0, 46)
badgeBacking.BackgroundColor3 = Colors.BitLifeRed
badgeBacking.Parent = eventHeaderStrip
createUICorner(badgeBacking, 30)

local relationshipBadge = Instance.new("TextLabel")
relationshipBadge.BackgroundTransparency = 1
relationshipBadge.Size = UDim2.new(1, -20, 1, -8)
relationshipBadge.AnchorPoint = Vector2.new(0.5, 0.5)
relationshipBadge.Position = UDim2.fromScale(0.5, 0.5)
relationshipBadge.Font = CHIP_FONT
relationshipBadge.TextSize = 16
relationshipBadge.TextColor3 = Color3.new(1, 1, 1)
relationshipBadge.TextXAlignment = Enum.TextXAlignment.Center
relationshipBadge.Text = "BEST FRIEND"
relationshipBadge.Parent = badgeBacking

local eventEmoji = Instance.new("TextLabel")
eventEmoji.BackgroundTransparency = 1
eventEmoji.Size = UDim2.new(1, 0, 0, 60)
eventEmoji.Position = UDim2.new(0, 0, 0, 120)
eventEmoji.Font = BODY_FONT
eventEmoji.TextSize = 44
eventEmoji.TextColor3 = Colors.TextDark
eventEmoji.Text = "🙂"
eventEmoji.TextYAlignment = Enum.TextYAlignment.Center
eventEmoji.Parent = eventCard

local eventTitle = Instance.new("TextLabel")
eventTitle.BackgroundTransparency = 1
eventTitle.Size = UDim2.new(1, -40, 0, 40)
eventTitle.Position = UDim2.new(0, 20, 0, 170)
eventTitle.Font = TITLE_FONT
eventTitle.TextSize = 28
eventTitle.TextXAlignment = Enum.TextXAlignment.Center
eventTitle.TextColor3 = Colors.TextDark
eventTitle.Text = "Unfriended"
eventTitle.Parent = eventCard

local eventBody = Instance.new("TextLabel")
eventBody.BackgroundTransparency = 1
eventBody.Size = UDim2.new(1, -60, 0, 90)
eventBody.Position = UDim2.new(0, 30, 0, 210)
eventBody.Font = BODY_FONT
eventBody.TextSize = 17
eventBody.TextWrapped = true
eventBody.TextXAlignment = Enum.TextXAlignment.Center
eventBody.TextYAlignment = Enum.TextYAlignment.Top
eventBody.TextColor3 = Colors.TextDark
eventBody.Text = "Event description"
eventBody.Parent = eventCard

local choicesHolder = Instance.new("Frame")
choicesHolder.BackgroundTransparency = 1
choicesHolder.Size = UDim2.new(1, -60, 0, 220)
choicesHolder.Position = UDim2.new(0, 30, 0, 310)
choicesHolder.Parent = eventCard

local choicesLayout = Instance.new("UIListLayout")
choicesLayout.FillDirection = Enum.FillDirection.Vertical
choicesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
choicesLayout.VerticalAlignment   = Enum.VerticalAlignment.Top
choicesLayout.Padding = UDim.new(0, 10)
choicesLayout.Parent = choicesHolder

local surpriseButton = Instance.new("TextButton")
surpriseButton.BackgroundTransparency = 1
surpriseButton.AutoButtonColor = false
surpriseButton.Size = UDim2.new(1, 0, 0, 26)
surpriseButton.Font = BODY_FONT
surpriseButton.TextSize = 16
surpriseButton.TextColor3 = Colors.BitLifeBlue
surpriseButton.Text = "Surprise me!"
surpriseButton.Parent = eventCard
surpriseButton.Position = UDim2.new(0.5, 0, 1, -24)
surpriseButton.AnchorPoint = Vector2.new(0.5, 1)
surpriseButton.Visible = false

local activeChoiceButtons = {}
local currentEventId = nil

local function clearChoices()
	for _, entry in ipairs(activeChoiceButtons) do
		if entry.button then
			entry.button:Destroy()
		end
	end
	table.clear(activeChoiceButtons)
end

local function resolveChoice(payloadId, choiceId)
	if not awaitingEvent then
		return
	end

	awaitingEvent = false

	for _, entry in ipairs(activeChoiceButtons) do
		entry.button.AutoButtonColor = false
		entry.button.Active = false
	end

	SubmitChoice:FireServer(payloadId, choiceId)
	setOverlayVisible(eventOverlay, false)
end

local function renderChoiceButton(choice, payload)
	local btn = Instance.new("TextButton")
	btn.BackgroundColor3 = Colors.BitLifeBlue
	btn.AutoButtonColor = false
	btn.Size = UDim2.new(1, 0, 0, 54)
	btn.Font = CHIP_FONT
	btn.TextSize = 17
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Text = choice.text
	btn.Parent = choicesHolder
	createUICorner(btn, 24)
	createUIStroke(btn, 1, 0.3, Color3.fromRGB(20, 53, 170))

	table.insert(activeChoiceButtons, {
		button = btn,
		choice = choice,
		payload = payload,
	})

	btn.MouseEnter:Connect(function()
		btn.BackgroundColor3 = Colors.BitLifeBlueHi
	end)
	btn.MouseLeave:Connect(function()
		btn.BackgroundColor3 = Colors.BitLifeBlue
	end)

	btn.MouseButton1Click:Connect(function()
		resolveChoice(payload.id, choice.id)
	end)
end

local function showEvent(payload)
	awaitingEvent = true
	currentEventId = payload.id

	local badgeText = (payload.relationshipLabel or "Best Friend"):upper()
	local personName = payload.personName or payload.actorName or "Bradley Allen"
	local avatarEmoji = payload.avatarEmoji or "🙂"
	local accentColor = payload.badgeColor or Colors.BitLifeRed

	headerAvatarEmoji.Text = avatarEmoji
	personNameLabel.Text = personName
	relationshipLabel.Text = payload.relationshipLabel or "Relationship"
	relationshipBadge.Text = badgeText
	badgeBacking.BackgroundColor3 = accentColor
	eventBorder.Color = accentColor
	eventEmoji.Text = payload.emoji or "🙂"
	eventTitle.Text = payload.title or "Unfriended"
	eventBody.Text = payload.text or ""

	clearChoices()

	for _, choice in ipairs(payload.choices or {}) do
		renderChoiceButton(choice, payload)
	end

	surpriseButton.Visible = #activeChoiceButtons > 1

	setOverlayVisible(eventOverlay, true)
end

surpriseButton.MouseButton1Click:Connect(function()
	if not awaitingEvent or #activeChoiceButtons == 0 then
		return
	end

	local randomIndex = math.random(1, #activeChoiceButtons)
	local entry = activeChoiceButtons[randomIndex]
	if entry and entry.choice and entry.payload then
		resolveChoice(entry.payload.id, entry.choice.id)
	end
end)

----------------------------------------------------------------
-- INTRO FLOW: gender → name (3 pills)
----------------------------------------------------------------

local maleFirst = {
	"Anthony","Scott","Logan","Ethan","Noah","Liam","Mason","Jayden","Caleb","Damian",
}
local femaleFirst = {
	"Olivia","Emma","Ava","Sophia","Mia","Amelia","Isabella","Charlotte","Luna","Stella",
}
local lastNames = {
	"Russell","Allen","Flores","Cooper","Parker","Reed","Mitchell","Walker","Gray","Brooks",
}

local selectedGender = nil
local selectedName   = nil

local nameOverlay
local generateNameOptions

-- overlay 1: gender
local genderOverlay = Instance.new("Frame")
genderOverlay.Name = "GenderOverlay"
genderOverlay.Size = UDim2.fromScale(1, 1)
genderOverlay.BackgroundTransparency = 1
genderOverlay.Visible = false
genderOverlay.ZIndex = 15
genderOverlay.Parent = screenGui
registerOverlay(genderOverlay, true)

local genderDim = Instance.new("Frame")
genderDim.Size = UDim2.fromScale(1, 1)
genderDim.BackgroundColor3 = Color3.new(0, 0, 0)
genderDim.BackgroundTransparency = 0.45
genderDim.Parent = genderOverlay

local genderTitle = Instance.new("TextLabel")
genderTitle.BackgroundTransparency = 1
genderTitle.Size = UDim2.new(0.9, 0, 0, 60)
genderTitle.AnchorPoint = Vector2.new(0.5, 0)
genderTitle.Position = UDim2.new(0.5, 0, 0.18, 0)
genderTitle.Font = TITLE_FONT
genderTitle.TextSize = 26
genderTitle.TextColor3 = Colors.BitLifeYellow
genderTitle.Text = "Start by picking a gender."
genderTitle.Parent = genderOverlay

local genderButtonsHolder = Instance.new("Frame")
genderButtonsHolder.BackgroundTransparency = 1
genderButtonsHolder.Size = UDim2.new(0.8, 0, 0, 220)
genderButtonsHolder.AnchorPoint = Vector2.new(0.5, 0)
genderButtonsHolder.Position = UDim2.new(0.5, 0, 0.32, 0)
genderButtonsHolder.Parent = genderOverlay

local genderButtonsLayout = Instance.new("UIListLayout")
genderButtonsLayout.FillDirection = Enum.FillDirection.Vertical
genderButtonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
genderButtonsLayout.VerticalAlignment   = Enum.VerticalAlignment.Top
genderButtonsLayout.Padding = UDim.new(0, 16)
genderButtonsLayout.Parent = genderButtonsHolder

local function createGenderButton(text, emoji, color, value)
	local btn = Instance.new("TextButton")
	btn.BackgroundColor3 = color
	btn.AutoButtonColor = false
	btn.Size = UDim2.new(1, 0, 0, 80)
	btn.Font = CHIP_FONT
	btn.TextSize = 26
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Text = string.format("%s  %s", emoji, text)
	btn.Parent = genderButtonsHolder
	createUICorner(btn, 999)
	createUIStroke(btn, 2, 0.4, Color3.new(1, 1, 1))

	local baseColor = color
	btn.MouseEnter:Connect(function()
		btn.BackgroundColor3 = baseColor:Lerp(Color3.new(1, 1, 1), 0.08)
	end)
	btn.MouseLeave:Connect(function()
		btn.BackgroundColor3 = baseColor
	end)

	btn.MouseButton1Click:Connect(function()
		selectedGender = value
		selectedName = nil
		setOverlayVisible(genderOverlay, false)
		setOverlayVisible(nameOverlay, true)
		generateNameOptions()
	end)

	return btn
end

local maleBtn   = createGenderButton("Male",   "♂", Colors.BitLifeBlue, "Male")
local femaleBtn = createGenderButton("Female", "♀", Colors.BitLifePink, "Female")

-- overlay 2: 3 names
nameOverlay = Instance.new("Frame")
nameOverlay.Name = "NameOverlay"
nameOverlay.Size = UDim2.fromScale(1, 1)
nameOverlay.BackgroundTransparency = 1
nameOverlay.Visible = false
nameOverlay.ZIndex = 16
nameOverlay.Parent = screenGui
registerOverlay(nameOverlay, true)

local nameDim = Instance.new("Frame")
nameDim.Size = UDim2.fromScale(1, 1)
nameDim.BackgroundColor3 = Color3.new(0, 0, 0)
nameDim.BackgroundTransparency = 0.45
nameDim.Parent = nameOverlay

local nameTitle = Instance.new("TextLabel")
nameTitle.BackgroundTransparency = 1
nameTitle.Size = UDim2.new(0.9, 0, 0, 60)
nameTitle.AnchorPoint = Vector2.new(0.5, 0)
nameTitle.Position = UDim2.new(0.5, 0, 0.18, 0)
nameTitle.Font = TITLE_FONT
nameTitle.TextSize = 26
nameTitle.TextColor3 = Colors.BitLifeYellow
nameTitle.Text = "Now, pick someone to become."
nameTitle.Parent = nameOverlay

local namesHolder = Instance.new("Frame")
namesHolder.BackgroundTransparency = 1
namesHolder.Size = UDim2.new(0.8, 0, 0, 260)
namesHolder.AnchorPoint = Vector2.new(0.5, 0)
namesHolder.Position = UDim2.new(0.5, 0, 0.32, 0)
namesHolder.Parent = nameOverlay

local namesLayout = Instance.new("UIListLayout")
namesLayout.FillDirection = Enum.FillDirection.Vertical
namesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
namesLayout.VerticalAlignment   = Enum.VerticalAlignment.Top
namesLayout.Padding = UDim.new(0, 12)
namesLayout.Parent = namesHolder

local nameButtons = {}

local function clearNameButtons()
	for _, b in ipairs(nameButtons) do
		b:Destroy()
	end
	table.clear(nameButtons)
end

local function randomFrom(list)
	return list[math.random(1, #list)]
end

generateNameOptions = function()
	clearNameButtons()
	if not selectedGender then
		return
	end

	for i = 1, 3 do
		local firstList = (selectedGender == "Female") and femaleFirst or maleFirst
		local fullName = randomFrom(firstList) .. " " .. randomFrom(lastNames)

		local btn = Instance.new("TextButton")
		btn.AutoButtonColor = false
		btn.Size = UDim2.new(1, 0, 0, 72)
		btn.Font = CHIP_FONT
		btn.TextSize = 22
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.TextXAlignment = Enum.TextXAlignment.Center

		if i == 1 then
			btn.BackgroundColor3 = Colors.BitLifeGreen
		elseif i == 2 then
			btn.BackgroundColor3 = Colors.BitLifeYellow
		else
			btn.BackgroundColor3 = Colors.BitLifeOrange
		end

		local emoji = (selectedGender == "Female") and "👩‍🦰" or "👨‍🦰"
		btn.Text = emoji .. "  " .. fullName
		btn.Parent = namesHolder
		createUICorner(btn, 999)
		createUIStroke(btn, 2, 0.25, Color3.new(1, 1, 1))

		table.insert(nameButtons, btn)

		local baseColor = btn.BackgroundColor3

		btn.MouseButton1Click:Connect(function()
			selectedName = fullName
			-- send to server
			SetLifeInfo:FireServer(selectedName, selectedGender)
			setOverlayVisible(nameOverlay, false)
		end)

		btn.MouseEnter:Connect(function()
			btn.BackgroundColor3 = baseColor:Lerp(Color3.new(1, 1, 1), 0.08)
		end)
		btn.MouseLeave:Connect(function()
			btn.BackgroundColor3 = baseColor
		end)
	end
end

----------------------------------------------------------------
-- STATE SYNC / UPDATE
----------------------------------------------------------------

local function updateFromState()
	if not currentState then
		return
	end

	local stats = currentState.Stats or {}

	for key, card in pairs(statCards) do
		local v = math.floor(stats[key] or 0)
		card.valueLabel.Text = tostring(v) .. "%"
		local pct = math.clamp(v / 100, 0, 1)
		card.barFill:TweenSize(
			UDim2.new(pct, 0, 1, 0),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Quad,
			0.15,
			true
		)

		if card.boost then
			card.boost.Visible = v <= 30
		end
	end

	local displayName = currentState.Name or "New Life"
	nameLabel.Text = displayName

	local age  = currentState.Age or 0
	local year = currentState.Year or 2025
	ageYearLabel.Text = string.format("Age %d • Year %d", age, year)

	local money = currentState.Money or 0
	moneyChip.Text = "$" .. tostring(money)

	-- show intro overlays if name not set
	if not currentState.Name then
		ageButtonRing.Visible   = false
		hasShownAgeHint = false
		hideAgeTutorial()
		setOverlayVisible(genderOverlay, true)
		setOverlayVisible(nameOverlay, false)
	else
		ageButtonRing.Visible = true
		setOverlayVisible(genderOverlay, false)
		setOverlayVisible(nameOverlay, false)
		if not hasShownAgeHint then
			showAgeTutorial()
		end
	end
end

SyncState.OnClientEvent:Connect(function(state, lastFeedText)
	currentState = state
	updateFromState()
	if lastFeedText then
		addFeedEntry(lastFeedText)
	end
end)

PresentEvent.OnClientEvent:Connect(function(eventData, ageFeedText)
	if ageFeedText then
		addFeedEntry(ageFeedText)
	end
	showEvent(eventData)
end)

----------------------------------------------------------------
-- INPUT
----------------------------------------------------------------

local function pulseAgeButton()
	local ti = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	tween(ageButton, ti, { Size = UDim2.new(0, 118, 0, 118) }).Completed:Wait()
	tween(ageButton, ti, { Size = UDim2.new(0, 110, 0, 110) })
end

ageButton.MouseButton1Click:Connect(function()
	if awaitingEvent then
		return
	end
	if currentState and not currentState.Name then
		return
	end

	pulseAgeButton()
	hideAgeTutorial()
	RequestAgeUp:FireServer()
end)
