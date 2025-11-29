-- StarterPlayerScripts / LifeClient (LocalScript)
-- BitLife-style UI: Complete with Jobs, Crimes, Activities, and AAA polish.

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local player = Players.LocalPlayer

----------------------------------------------------------------
-- REMOTES
----------------------------------------------------------------

local remotesFolder   = ReplicatedStorage:WaitForChild("LifeRemotes")
local RequestAgeUp    = remotesFolder:WaitForChild("RequestAgeUp")
local PresentEvent    = remotesFolder:WaitForChild("PresentEvent")
local SubmitChoice    = remotesFolder:WaitForChild("SubmitChoice")
local SyncState       = remotesFolder:WaitForChild("SyncState")
local SetLifeInfo     = remotesFolder:WaitForChild("SetLifeInfo")

-- Job remotes
local GetJobs         = remotesFolder:WaitForChild("GetJobs")
local ApplyForJob     = remotesFolder:WaitForChild("ApplyForJob")
local QuitJob         = remotesFolder:WaitForChild("QuitJob")

-- Crime remotes
local GetCrimes       = remotesFolder:WaitForChild("GetCrimes")
local CommitCrime     = remotesFolder:WaitForChild("CommitCrime")

-- Activity remotes
local GetActivities   = remotesFolder:WaitForChild("GetActivities")
local DoActivity      = remotesFolder:WaitForChild("DoActivity")

----------------------------------------------------------------
-- STATE
----------------------------------------------------------------

local currentState    = nil
local awaitingEvent   = false

----------------------------------------------------------------
-- DESIGN SYSTEM
----------------------------------------------------------------

local TITLE_FONT = Enum.Font.GothamBold
local BODY_FONT  = Enum.Font.Gotham
local CHIP_FONT  = Enum.Font.GothamMedium

-- Color palette
local Colors = {
	-- Primary
	Primary = Color3.fromRGB(59, 130, 246),
	PrimaryHover = Color3.fromRGB(37, 99, 235),
	PrimaryDark = Color3.fromRGB(30, 64, 175),
	
	-- Success
	Success = Color3.fromRGB(34, 197, 94),
	SuccessHover = Color3.fromRGB(22, 163, 74),
	SuccessDark = Color3.fromRGB(21, 128, 61),
	
	-- Danger
	Danger = Color3.fromRGB(239, 68, 68),
	DangerHover = Color3.fromRGB(220, 38, 38),
	DangerDark = Color3.fromRGB(185, 28, 28),
	
	-- Warning
	Warning = Color3.fromRGB(251, 191, 36),
	WarningHover = Color3.fromRGB(245, 158, 11),
	
	-- Purple (for activities)
	Purple = Color3.fromRGB(147, 51, 234),
	PurpleHover = Color3.fromRGB(126, 34, 206),
	
	-- Orange
	Orange = Color3.fromRGB(249, 115, 22),
	OrangeHover = Color3.fromRGB(234, 88, 12),
	
	-- Backgrounds
	BgLight = Color3.fromRGB(248, 250, 252),
	BgCard = Color3.fromRGB(255, 255, 255),
	BgDark = Color3.fromRGB(15, 23, 42),
	BgNavy = Color3.fromRGB(30, 41, 59),
	
	-- Text
	TextPrimary = Color3.fromRGB(15, 23, 42),
	TextSecondary = Color3.fromRGB(100, 116, 139),
	TextMuted = Color3.fromRGB(148, 163, 184),
	TextWhite = Color3.fromRGB(248, 250, 252),
	
	-- Borders
	Border = Color3.fromRGB(226, 232, 240),
	BorderLight = Color3.fromRGB(241, 245, 249),
}

----------------------------------------------------------------
-- HELPERS
----------------------------------------------------------------

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

local function createUIPadding(parent, l, r, t, b)
	local p = Instance.new("UIPadding")
	p.PaddingLeft = UDim.new(0, l or 0)
	p.PaddingRight = UDim.new(0, r or 0)
	p.PaddingTop = UDim.new(0, t or 0)
	p.PaddingBottom = UDim.new(0, b or 0)
	p.Parent = parent
	return p
end

local function createUIListLayout(parent, dir, hAlign, vAlign, padding, sortOrder)
	local l = Instance.new("UIListLayout")
	l.FillDirection = dir or Enum.FillDirection.Vertical
	l.HorizontalAlignment = hAlign or Enum.HorizontalAlignment.Left
	l.VerticalAlignment = vAlign or Enum.VerticalAlignment.Top
	l.Padding = UDim.new(0, padding or 0)
	l.SortOrder = sortOrder or Enum.SortOrder.LayoutOrder
	l.Parent = parent
	return l
end

local function tween(obj, info, props)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

local function formatMoney(amount)
	local formatted = tostring(math.abs(amount))
	local k
	while true do
		formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
		if k == 0 then break end
	end
	if amount < 0 then
		return "-$" .. formatted
	end
	return "$" .. formatted
end

local function createShadow(parent)
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://6015897843"
	shadow.ImageColor3 = Color3.new(0, 0, 0)
	shadow.ImageTransparency = 0.85
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(49, 49, 450, 450)
	shadow.Size = UDim2.new(1, 30, 1, 30)
	shadow.Position = UDim2.new(0, -15, 0, -5)
	shadow.ZIndex = -1
	shadow.Parent = parent
	return shadow
end

----------------------------------------------------------------
-- ROOT GUI + BACKGROUND
----------------------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LifeGui"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local bg = Instance.new("Frame")
bg.Size = UDim2.fromScale(1, 1)
bg.BackgroundColor3 = Color3.fromRGB(241, 245, 249)
bg.Parent = screenGui

local bgGrad = Instance.new("UIGradient")
bgGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(248, 250, 255)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(241, 248, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(250, 245, 255)),
})
bgGrad.Rotation = 135
bgGrad.Parent = bg

-- Main container
local root = Instance.new("Frame")
root.Name = "RootCard"
root.AnchorPoint = Vector2.new(0.5, 0.5)
root.Position = UDim2.fromScale(0.5, 0.5)
root.Size = UDim2.new(0.96, 0, 0.96, 0)
root.BackgroundColor3 = Colors.BgCard
root.Parent = bg
createUICorner(root, 24)
createUIStroke(root, 1, 0.9, Colors.Border)

----------------------------------------------------------------
-- HEADER
----------------------------------------------------------------

local header = Instance.new("Frame")
header.Name = "Header"
header.BackgroundColor3 = Colors.BgCard
header.Size = UDim2.new(1, -32, 0, 80)
header.Position = UDim2.new(0, 16, 0, 16)
header.Parent = root
createUICorner(header, 20)
createUIStroke(header, 1, 0.85, Colors.Border)

local headerShadow = Instance.new("Frame")
headerShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
headerShadow.BackgroundTransparency = 0.97
headerShadow.Size = UDim2.new(1, 0, 0, 4)
headerShadow.Position = UDim2.new(0, 0, 1, 0)
headerShadow.BorderSizePixel = 0
headerShadow.Parent = header

createUIPadding(header, 16, 16, 0, 0)

-- Avatar
local avatarFrame = Instance.new("Frame")
avatarFrame.Size = UDim2.new(0, 56, 0, 56)
avatarFrame.Position = UDim2.new(0, 0, 0.5, 0)
avatarFrame.AnchorPoint = Vector2.new(0, 0.5)
avatarFrame.BackgroundColor3 = Color3.fromRGB(239, 246, 255)
avatarFrame.Parent = header
createUICorner(avatarFrame, 28)
createUIStroke(avatarFrame, 2, 0.7, Color3.fromRGB(191, 219, 254))

local avatarEmoji = Instance.new("TextLabel")
avatarEmoji.BackgroundTransparency = 1
avatarEmoji.Size = UDim2.fromScale(1, 1)
avatarEmoji.Font = BODY_FONT
avatarEmoji.TextSize = 30
avatarEmoji.TextColor3 = Colors.TextPrimary
avatarEmoji.Text = "👶"
avatarEmoji.Parent = avatarFrame

-- Name + Info
local nameAgeFrame = Instance.new("Frame")
nameAgeFrame.BackgroundTransparency = 1
nameAgeFrame.Size = UDim2.new(0.5, 0, 1, 0)
nameAgeFrame.Position = UDim2.new(0, 70, 0, 0)
nameAgeFrame.Parent = header

createUIListLayout(nameAgeFrame, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center, 2)

local nameLabel = Instance.new("TextLabel")
nameLabel.BackgroundTransparency = 1
nameLabel.Size = UDim2.new(1, 0, 0, 26)
nameLabel.Font = TITLE_FONT
nameLabel.TextSize = 22
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.TextColor3 = Colors.TextPrimary
nameLabel.Text = "New Life"
nameLabel.Parent = nameAgeFrame

local ageYearLabel = Instance.new("TextLabel")
ageYearLabel.BackgroundTransparency = 1
ageYearLabel.Size = UDim2.new(1, 0, 0, 20)
ageYearLabel.Font = BODY_FONT
ageYearLabel.TextSize = 14
ageYearLabel.TextXAlignment = Enum.TextXAlignment.Left
ageYearLabel.TextColor3 = Colors.TextSecondary
ageYearLabel.Text = "Age 0 • Year 2025"
ageYearLabel.Parent = nameAgeFrame

local jobLabel = Instance.new("TextLabel")
jobLabel.BackgroundTransparency = 1
jobLabel.Size = UDim2.new(1, 0, 0, 16)
jobLabel.Font = BODY_FONT
jobLabel.TextSize = 12
jobLabel.TextXAlignment = Enum.TextXAlignment.Left
jobLabel.TextColor3 = Colors.TextMuted
jobLabel.Text = "Unemployed"
jobLabel.Parent = nameAgeFrame

-- Money chip
local moneyChip = Instance.new("Frame")
moneyChip.BackgroundColor3 = Colors.Success
moneyChip.AnchorPoint = Vector2.new(1, 0.5)
moneyChip.Position = UDim2.new(1, 0, 0.5, 0)
moneyChip.Size = UDim2.new(0, 130, 0, 44)
moneyChip.Parent = header
createUICorner(moneyChip, 22)

local moneyGrad = Instance.new("UIGradient")
moneyGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 197, 94)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 163, 74)),
})
moneyGrad.Rotation = 90
moneyGrad.Parent = moneyChip

local moneyLabel = Instance.new("TextLabel")
moneyLabel.BackgroundTransparency = 1
moneyLabel.Size = UDim2.fromScale(1, 1)
moneyLabel.Font = TITLE_FONT
moneyLabel.TextSize = 18
moneyLabel.TextColor3 = Colors.TextWhite
moneyLabel.Text = "$0"
moneyLabel.Parent = moneyChip

----------------------------------------------------------------
-- FEED CARD
----------------------------------------------------------------

local feedCard = Instance.new("Frame")
feedCard.Name = "FeedCard"
feedCard.BackgroundColor3 = Colors.BgCard
feedCard.Size = UDim2.new(1, -32, 1, -270)
feedCard.Position = UDim2.new(0, 16, 0, 108)
feedCard.Parent = root
createUICorner(feedCard, 20)
createUIStroke(feedCard, 1, 0.85, Colors.Border)

createUIPadding(feedCard, 16, 16, 14, 14)

local feedHeader = Instance.new("Frame")
feedHeader.BackgroundTransparency = 1
feedHeader.Size = UDim2.new(1, 0, 0, 28)
feedHeader.Parent = feedCard

local feedTitle = Instance.new("TextLabel")
feedTitle.BackgroundTransparency = 1
feedTitle.Size = UDim2.new(0.5, 0, 1, 0)
feedTitle.Font = TITLE_FONT
feedTitle.TextSize = 16
feedTitle.TextXAlignment = Enum.TextXAlignment.Left
feedTitle.TextColor3 = Colors.TextPrimary
feedTitle.Text = "📜 Life Feed"
feedTitle.Parent = feedHeader

local feedScroll = Instance.new("ScrollingFrame")
feedScroll.Name = "FeedScroll"
feedScroll.BackgroundTransparency = 1
feedScroll.Size = UDim2.new(1, 0, 1, -34)
feedScroll.Position = UDim2.new(0, 0, 0, 32)
feedScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
feedScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
feedScroll.ScrollBarThickness = 4
feedScroll.ScrollBarImageColor3 = Colors.TextMuted
feedScroll.Parent = feedCard

createUIListLayout(feedScroll, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top, 8)

local function addFeedEntry(text)
	if not text or text == "" then return end

	local bubble = Instance.new("Frame")
	bubble.BackgroundColor3 = Color3.fromRGB(248, 250, 252)
	bubble.Size = UDim2.new(1, 0, 0, 0)
	bubble.AutomaticSize = Enum.AutomaticSize.Y
	bubble.Parent = feedScroll
	createUICorner(bubble, 14)
	createUIStroke(bubble, 1, 0.92, Colors.Border)

	createUIPadding(bubble, 14, 14, 10, 10)

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 0, 0)
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.Font = BODY_FONT
	label.TextSize = 14
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.TextColor3 = Colors.TextPrimary
	label.Text = text
	label.Parent = bubble

	bubble.BackgroundTransparency = 1
	tween(bubble, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { BackgroundTransparency = 0 })

	task.delay(0.05, function()
		feedScroll.CanvasPosition = Vector2.new(0, math.max(0, feedScroll.AbsoluteCanvasSize.Y - feedScroll.AbsoluteWindowSize.Y))
	end)
end

----------------------------------------------------------------
-- STATS BAR
----------------------------------------------------------------

local statsBar = Instance.new("Frame")
statsBar.Name = "StatsBar"
statsBar.BackgroundColor3 = Colors.BgCard
statsBar.Size = UDim2.new(1, -32, 0, 70)
statsBar.AnchorPoint = Vector2.new(0.5, 1)
statsBar.Position = UDim2.new(0.5, 0, 1, -130)
statsBar.Parent = root
createUICorner(statsBar, 18)
createUIStroke(statsBar, 1, 0.85, Colors.Border)

createUIPadding(statsBar, 16, 16, 10, 10)

local statsLayout = Instance.new("UIListLayout")
statsLayout.FillDirection = Enum.FillDirection.Horizontal
statsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
statsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
statsLayout.Padding = UDim.new(0, 12)
statsLayout.Parent = statsBar

local statMeta = {
	{ key = "Happiness", icon = "😊", color = Color3.fromRGB(251, 191, 36) },
	{ key = "Health",    icon = "❤️", color = Color3.fromRGB(239, 68, 68) },
	{ key = "Smarts",    icon = "🧠", color = Color3.fromRGB(147, 51, 234) },
	{ key = "Looks",     icon = "✨", color = Color3.fromRGB(236, 72, 153) },
}

local statCards = {}

for _, info in ipairs(statMeta) do
	local holder = Instance.new("Frame")
	holder.BackgroundTransparency = 1
	holder.Size = UDim2.new(0.23, 0, 1, 0)
	holder.Parent = statsBar

	local iconLabel = Instance.new("TextLabel")
	iconLabel.BackgroundTransparency = 1
	iconLabel.Size = UDim2.new(0, 24, 0, 24)
	iconLabel.Position = UDim2.new(0, 0, 0, 2)
	iconLabel.Font = BODY_FONT
	iconLabel.TextSize = 18
	iconLabel.Text = info.icon
	iconLabel.Parent = holder

	local statName = Instance.new("TextLabel")
	statName.BackgroundTransparency = 1
	statName.Size = UDim2.new(1, -28, 0, 16)
	statName.Position = UDim2.new(0, 28, 0, 0)
	statName.Font = BODY_FONT
	statName.TextSize = 11
	statName.TextXAlignment = Enum.TextXAlignment.Left
	statName.TextColor3 = Colors.TextSecondary
	statName.Text = info.key
	statName.Parent = holder

	local valueLabel = Instance.new("TextLabel")
	valueLabel.BackgroundTransparency = 1
	valueLabel.Size = UDim2.new(1, -28, 0, 14)
	valueLabel.Position = UDim2.new(0, 28, 0, 14)
	valueLabel.Font = CHIP_FONT
	valueLabel.TextSize = 12
	valueLabel.TextXAlignment = Enum.TextXAlignment.Left
	valueLabel.TextColor3 = Colors.TextPrimary
	valueLabel.Text = "0%"
	valueLabel.Parent = holder

	local barBg = Instance.new("Frame")
	barBg.BackgroundColor3 = Color3.fromRGB(241, 245, 249)
	barBg.Size = UDim2.new(1, 0, 0, 6)
	barBg.Position = UDim2.new(0, 0, 0, 38)
	barBg.Parent = holder
	createUICorner(barBg, 3)

	local barFill = Instance.new("Frame")
	barFill.BackgroundColor3 = info.color
	barFill.Size = UDim2.new(0, 0, 1, 0)
	barFill.Parent = barBg
	createUICorner(barFill, 3)

	statCards[info.key] = {
		valueLabel = valueLabel,
		barFill = barFill,
	}
end

----------------------------------------------------------------
-- BOTTOM NAV + AGE BUTTON
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
navBar.BackgroundColor3 = Colors.BgNavy
navBar.Parent = bottom
createUICorner(navBar, 20)

local navGrad = Instance.new("UIGradient")
navGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 41, 59)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 23, 42)),
})
navGrad.Rotation = 90
navGrad.Parent = navBar

local navLayout = Instance.new("UIListLayout")
navLayout.FillDirection = Enum.FillDirection.Horizontal
navLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
navLayout.VerticalAlignment = Enum.VerticalAlignment.Center
navLayout.Padding = UDim.new(0, 8)
navLayout.Parent = navBar

local navItems = {
	{ icon = "💼", text = "Jobs", action = "jobs" },
	{ icon = "🎯", text = "Activities", action = "activities" },
	{ icon = "😈", text = "Crime", action = "crime" },
	{ icon = "📊", text = "Stats", action = "stats" },
}

local navButtons = {}

for _, info in ipairs(navItems) do
	local btn = Instance.new("TextButton")
	btn.BackgroundTransparency = 1
	btn.AutoButtonColor = false
	btn.Size = UDim2.new(0, 75, 0, 56)
	btn.Parent = navBar

	createUIListLayout(btn, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center, 2)

	local icon = Instance.new("TextLabel")
	icon.BackgroundTransparency = 1
	icon.Size = UDim2.new(1, 0, 0, 24)
	icon.Font = BODY_FONT
	icon.TextSize = 20
	icon.TextColor3 = Colors.TextWhite
	icon.Text = info.icon
	icon.Parent = btn

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 0, 14)
	label.Font = BODY_FONT
	label.TextSize = 11
	label.TextColor3 = Colors.TextMuted
	label.Text = info.text
	label.Parent = btn

	navButtons[info.action] = { btn = btn, icon = icon, label = label }

	btn.MouseEnter:Connect(function()
		icon.TextColor3 = Colors.Warning
		label.TextColor3 = Colors.TextWhite
	end)
	btn.MouseLeave:Connect(function()
		icon.TextColor3 = Colors.TextWhite
		label.TextColor3 = Colors.TextMuted
	end)
end

-- Age button
local ageButton = Instance.new("TextButton")
ageButton.Name = "AgeButton"
ageButton.AnchorPoint = Vector2.new(0.5, 1)
ageButton.Position = UDim2.new(0.5, 0, 0, 0)
ageButton.Size = UDim2.new(0, 100, 0, 100)
ageButton.BackgroundColor3 = Colors.Success
ageButton.AutoButtonColor = false
ageButton.Text = ""
ageButton.ZIndex = 2
ageButton.Parent = bottom
createUICorner(ageButton, 50)
createUIStroke(ageButton, 4, 0, Color3.fromRGB(21, 128, 61))

local ageGrad = Instance.new("UIGradient")
ageGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(74, 222, 128)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(34, 197, 94)),
})
ageGrad.Rotation = 135
ageGrad.Parent = ageButton

local agePlus = Instance.new("TextLabel")
agePlus.BackgroundTransparency = 1
agePlus.Size = UDim2.new(1, 0, 0, 36)
agePlus.Position = UDim2.new(0, 0, 0, 16)
agePlus.Font = TITLE_FONT
agePlus.TextSize = 36
agePlus.TextColor3 = Colors.TextWhite
agePlus.Text = "+"
agePlus.Parent = ageButton

local ageText = Instance.new("TextLabel")
ageText.BackgroundTransparency = 1
ageText.Size = UDim2.new(1, 0, 0, 24)
ageText.Position = UDim2.new(0, 0, 0, 52)
ageText.Font = CHIP_FONT
ageText.TextSize = 16
ageText.TextColor3 = Colors.TextWhite
ageText.Text = "Age"
ageText.Parent = ageButton

local ageHint = Instance.new("TextLabel")
ageHint.BackgroundTransparency = 1
ageHint.Size = UDim2.new(1, 0, 0, 30)
ageHint.AnchorPoint = Vector2.new(0.5, 1)
ageHint.Position = UDim2.new(0.5, 0, 0, -108)
ageHint.Font = BODY_FONT
ageHint.TextSize = 14
ageHint.TextColor3 = Colors.TextSecondary
ageHint.Text = "👆 Press to grow older one year!"
ageHint.Visible = false
ageHint.Parent = bottom

----------------------------------------------------------------
-- MODAL SYSTEM
----------------------------------------------------------------

local function createModal(name, headerColor, headerEmoji, headerTitle)
	local overlay = Instance.new("Frame")
	overlay.Name = name
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 0.5
	overlay.Visible = false
	overlay.ZIndex = 50
	overlay.Parent = screenGui

	local card = Instance.new("Frame")
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.fromScale(0.5, 0.5)
	card.Size = UDim2.new(0, 420, 0, 520)
	card.BackgroundColor3 = Colors.BgCard
	card.ZIndex = 51
	card.Parent = overlay
	createUICorner(card, 24)
	createShadow(card)

	local headerFrame = Instance.new("Frame")
	headerFrame.BackgroundColor3 = headerColor
	headerFrame.Size = UDim2.new(1, 0, 0, 70)
	headerFrame.ZIndex = 52
	headerFrame.Parent = card
	createUICorner(headerFrame, 24)

	-- Cover bottom corners of header
	local headerBottom = Instance.new("Frame")
	headerBottom.BackgroundColor3 = headerColor
	headerBottom.Size = UDim2.new(1, 0, 0, 24)
	headerBottom.Position = UDim2.new(0, 0, 1, -24)
	headerBottom.BorderSizePixel = 0
	headerBottom.ZIndex = 52
	headerBottom.Parent = headerFrame

	local headerGrad = Instance.new("UIGradient")
	headerGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 220, 220)),
	})
	headerGrad.Rotation = 90
	headerGrad.Parent = headerFrame

	local emojiLabel = Instance.new("TextLabel")
	emojiLabel.BackgroundTransparency = 1
	emojiLabel.Size = UDim2.new(0, 50, 0, 50)
	emojiLabel.Position = UDim2.new(0, 16, 0.5, 0)
	emojiLabel.AnchorPoint = Vector2.new(0, 0.5)
	emojiLabel.Font = BODY_FONT
	emojiLabel.TextSize = 36
	emojiLabel.Text = headerEmoji
	emojiLabel.ZIndex = 53
	emojiLabel.Parent = headerFrame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1, -140, 0, 30)
	titleLabel.Position = UDim2.new(0, 70, 0.5, 0)
	titleLabel.AnchorPoint = Vector2.new(0, 0.5)
	titleLabel.Font = TITLE_FONT
	titleLabel.TextSize = 22
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextColor3 = Colors.TextWhite
	titleLabel.Text = headerTitle
	titleLabel.ZIndex = 53
	titleLabel.Parent = headerFrame

	local closeBtn = Instance.new("TextButton")
	closeBtn.BackgroundColor3 = Color3.new(0, 0, 0)
	closeBtn.BackgroundTransparency = 0.7
	closeBtn.Size = UDim2.new(0, 36, 0, 36)
	closeBtn.Position = UDim2.new(1, -14, 0.5, 0)
	closeBtn.AnchorPoint = Vector2.new(1, 0.5)
	closeBtn.Font = TITLE_FONT
	closeBtn.TextSize = 20
	closeBtn.TextColor3 = Colors.TextWhite
	closeBtn.Text = "✕"
	closeBtn.AutoButtonColor = false
	closeBtn.ZIndex = 53
	closeBtn.Parent = headerFrame
	createUICorner(closeBtn, 18)

	closeBtn.MouseButton1Click:Connect(function()
		overlay.Visible = false
	end)

	closeBtn.MouseEnter:Connect(function()
		closeBtn.BackgroundTransparency = 0.5
	end)
	closeBtn.MouseLeave:Connect(function()
		closeBtn.BackgroundTransparency = 0.7
	end)

	local contentFrame = Instance.new("Frame")
	contentFrame.BackgroundTransparency = 1
	contentFrame.Size = UDim2.new(1, -32, 1, -90)
	contentFrame.Position = UDim2.new(0, 16, 0, 78)
	contentFrame.ZIndex = 52
	contentFrame.Parent = card

	return overlay, card, contentFrame, emojiLabel, titleLabel
end

----------------------------------------------------------------
-- EVENT MODAL
----------------------------------------------------------------

local eventOverlay, eventCard, eventContent = createModal("EventOverlay", Colors.Danger, "🎲", "Life Event")

local eventBody = Instance.new("TextLabel")
eventBody.BackgroundTransparency = 1
eventBody.Size = UDim2.new(1, 0, 0, 80)
eventBody.Position = UDim2.new(0, 0, 0, 10)
eventBody.Font = BODY_FONT
eventBody.TextSize = 16
eventBody.TextWrapped = true
eventBody.TextXAlignment = Enum.TextXAlignment.Left
eventBody.TextYAlignment = Enum.TextYAlignment.Top
eventBody.TextColor3 = Colors.TextPrimary
eventBody.Text = ""
eventBody.ZIndex = 53
eventBody.Parent = eventContent

local choicesHolder = Instance.new("Frame")
choicesHolder.BackgroundTransparency = 1
choicesHolder.Size = UDim2.new(1, 0, 0, 320)
choicesHolder.Position = UDim2.new(0, 0, 0, 100)
choicesHolder.ZIndex = 52
choicesHolder.Parent = eventContent

createUIListLayout(choicesHolder, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, 12)

local activeChoiceButtons = {}
local currentEventId = nil

local function clearChoices()
	for _, b in ipairs(activeChoiceButtons) do
		b:Destroy()
	end
	table.clear(activeChoiceButtons)
end

local function showEvent(payload)
	awaitingEvent = true
	currentEventId = payload.id

	eventBody.Text = payload.text or ""
	clearChoices()

	for i, choice in ipairs(payload.choices or {}) do
		local btn = Instance.new("TextButton")
		btn.BackgroundColor3 = Colors.Primary
		btn.AutoButtonColor = false
		btn.Size = UDim2.new(1, 0, 0, 54)
		btn.Font = CHIP_FONT
		btn.TextSize = 16
		btn.TextColor3 = Colors.TextWhite
		btn.Text = choice.text
		btn.ZIndex = 53
		btn.Parent = choicesHolder
		createUICorner(btn, 14)

		local btnGrad = Instance.new("UIGradient")
		btnGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Colors.Primary),
			ColorSequenceKeypoint.new(1, Colors.PrimaryDark),
		})
		btnGrad.Rotation = 90
		btnGrad.Parent = btn

		table.insert(activeChoiceButtons, btn)

		btn.MouseEnter:Connect(function()
			btnGrad.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Colors.PrimaryHover),
				ColorSequenceKeypoint.new(1, Colors.PrimaryDark),
			})
		end)
		btn.MouseLeave:Connect(function()
			btnGrad.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Colors.Primary),
				ColorSequenceKeypoint.new(1, Colors.PrimaryDark),
			})
		end)

		btn.MouseButton1Click:Connect(function()
			if not awaitingEvent then return end
			awaitingEvent = false

			for _, other in ipairs(activeChoiceButtons) do
				other.Active = false
			end

			SubmitChoice:FireServer(payload.id, choice.id)
			eventOverlay.Visible = false
		end)
	end

	eventOverlay.Visible = true
end

----------------------------------------------------------------
-- JOBS MODAL
----------------------------------------------------------------

local jobsOverlay, jobsCard, jobsContent = createModal("JobsOverlay", Colors.Primary, "💼", "Career Center")

local currentJobFrame = Instance.new("Frame")
currentJobFrame.BackgroundColor3 = Color3.fromRGB(240, 253, 244)
currentJobFrame.Size = UDim2.new(1, 0, 0, 70)
currentJobFrame.ZIndex = 52
currentJobFrame.Parent = jobsContent
createUICorner(currentJobFrame, 14)
createUIStroke(currentJobFrame, 1, 0.8, Color3.fromRGB(187, 247, 208))

createUIPadding(currentJobFrame, 14, 14, 0, 0)

local currentJobTitle = Instance.new("TextLabel")
currentJobTitle.BackgroundTransparency = 1
currentJobTitle.Size = UDim2.new(0.7, 0, 0, 20)
currentJobTitle.Position = UDim2.new(0, 0, 0, 12)
currentJobTitle.Font = TITLE_FONT
currentJobTitle.TextSize = 14
currentJobTitle.TextXAlignment = Enum.TextXAlignment.Left
currentJobTitle.TextColor3 = Colors.TextPrimary
currentJobTitle.Text = "🚫 Unemployed"
currentJobTitle.ZIndex = 53
currentJobTitle.Parent = currentJobFrame

local currentJobSalary = Instance.new("TextLabel")
currentJobSalary.BackgroundTransparency = 1
currentJobSalary.Size = UDim2.new(0.7, 0, 0, 18)
currentJobSalary.Position = UDim2.new(0, 0, 0, 34)
currentJobSalary.Font = BODY_FONT
currentJobSalary.TextSize = 13
currentJobSalary.TextXAlignment = Enum.TextXAlignment.Left
currentJobSalary.TextColor3 = Colors.TextSecondary
currentJobSalary.Text = "No income"
currentJobSalary.ZIndex = 53
currentJobSalary.Parent = currentJobFrame

local quitJobBtn = Instance.new("TextButton")
quitJobBtn.BackgroundColor3 = Colors.Danger
quitJobBtn.Size = UDim2.new(0, 80, 0, 36)
quitJobBtn.Position = UDim2.new(1, -80, 0.5, 0)
quitJobBtn.AnchorPoint = Vector2.new(0, 0.5)
quitJobBtn.Font = CHIP_FONT
quitJobBtn.TextSize = 13
quitJobBtn.TextColor3 = Colors.TextWhite
quitJobBtn.Text = "Quit"
quitJobBtn.Visible = false
quitJobBtn.ZIndex = 53
quitJobBtn.Parent = currentJobFrame
createUICorner(quitJobBtn, 10)

quitJobBtn.MouseButton1Click:Connect(function()
	QuitJob:FireServer()
	task.wait(0.2)
	refreshJobsUI()
end)

local jobsScroll = Instance.new("ScrollingFrame")
jobsScroll.BackgroundTransparency = 1
jobsScroll.Size = UDim2.new(1, 0, 1, -90)
jobsScroll.Position = UDim2.new(0, 0, 0, 82)
jobsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
jobsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
jobsScroll.ScrollBarThickness = 4
jobsScroll.ZIndex = 52
jobsScroll.Parent = jobsContent

createUIListLayout(jobsScroll, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, 10)

local function createJobCard(job)
	local card = Instance.new("Frame")
	card.BackgroundColor3 = Colors.BgCard
	card.Size = UDim2.new(1, 0, 0, 100)
	card.ZIndex = 53
	card.Parent = jobsScroll
	createUICorner(card, 14)
	createUIStroke(card, 1, 0.85, Colors.Border)

	createUIPadding(card, 14, 14, 12, 12)

	local emoji = Instance.new("TextLabel")
	emoji.BackgroundTransparency = 1
	emoji.Size = UDim2.new(0, 40, 0, 40)
	emoji.Font = BODY_FONT
	emoji.TextSize = 28
	emoji.Text = job.emoji
	emoji.ZIndex = 54
	emoji.Parent = card

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(0.6, 0, 0, 20)
	title.Position = UDim2.new(0, 48, 0, 0)
	title.Font = TITLE_FONT
	title.TextSize = 15
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = Colors.TextPrimary
	title.Text = job.title
	title.ZIndex = 54
	title.Parent = card

	local company = Instance.new("TextLabel")
	company.BackgroundTransparency = 1
	company.Size = UDim2.new(0.6, 0, 0, 16)
	company.Position = UDim2.new(0, 48, 0, 20)
	company.Font = BODY_FONT
	company.TextSize = 12
	company.TextXAlignment = Enum.TextXAlignment.Left
	company.TextColor3 = Colors.TextSecondary
	company.Text = job.company
	company.ZIndex = 54
	company.Parent = card

	local salary = Instance.new("TextLabel")
	salary.BackgroundTransparency = 1
	salary.Size = UDim2.new(0.5, 0, 0, 16)
	salary.Position = UDim2.new(0, 48, 0, 38)
	salary.Font = CHIP_FONT
	salary.TextSize = 13
	salary.TextXAlignment = Enum.TextXAlignment.Left
	salary.TextColor3 = Colors.Success
	salary.Text = formatMoney(job.salary) .. "/year"
	salary.ZIndex = 54
	salary.Parent = card

	local applyBtn = Instance.new("TextButton")
	applyBtn.BackgroundColor3 = job.canApply and Colors.Success or Color3.fromRGB(203, 213, 225)
	applyBtn.Size = UDim2.new(0, 90, 0, 38)
	applyBtn.Position = UDim2.new(1, -90, 0, 0)
	applyBtn.Font = CHIP_FONT
	applyBtn.TextSize = 14
	applyBtn.TextColor3 = Colors.TextWhite
	applyBtn.Text = job.canApply and "Apply" or "Locked"
	applyBtn.Active = job.canApply
	applyBtn.ZIndex = 54
	applyBtn.Parent = card
	createUICorner(applyBtn, 10)

	if job.canApply then
		applyBtn.MouseButton1Click:Connect(function()
			applyBtn.Text = "..."
			applyBtn.Active = false
			local result = ApplyForJob:InvokeServer(job.id)
			if result then
				if result.success then
					applyBtn.Text = "✓"
					applyBtn.BackgroundColor3 = Colors.Success
				else
					applyBtn.Text = "Apply"
					applyBtn.Active = true
				end
			end
			task.wait(1)
			refreshJobsUI()
		end)
	end

	-- Requirements
	local reqText = ""
	if job.requirements then
		for stat, val in pairs(job.requirements) do
			if reqText ~= "" then reqText = reqText .. ", " end
			reqText = reqText .. stat .. " " .. val .. "%"
		end
	end
	if reqText == "" then reqText = "No requirements" end
	reqText = "Age " .. job.minAge .. "+ • " .. reqText

	local req = Instance.new("TextLabel")
	req.BackgroundTransparency = 1
	req.Size = UDim2.new(1, -100, 0, 14)
	req.Position = UDim2.new(0, 0, 1, -14)
	req.Font = BODY_FONT
	req.TextSize = 11
	req.TextXAlignment = Enum.TextXAlignment.Left
	req.TextColor3 = Colors.TextMuted
	req.Text = reqText
	req.ZIndex = 54
	req.Parent = card

	return card
end

function refreshJobsUI()
	for _, child in ipairs(jobsScroll:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Update current job display
	if currentState and currentState.Job then
		currentJobTitle.Text = currentState.Job.emoji .. " " .. currentState.Job.title
		currentJobSalary.Text = "at " .. currentState.Job.company .. " • " .. formatMoney(currentState.Job.salary) .. "/year"
		currentJobFrame.BackgroundColor3 = Color3.fromRGB(240, 253, 244)
		quitJobBtn.Visible = true
	else
		currentJobTitle.Text = "🚫 Unemployed"
		currentJobSalary.Text = "Visit the career center to find work!"
		currentJobFrame.BackgroundColor3 = Color3.fromRGB(254, 242, 242)
		quitJobBtn.Visible = false
	end

	local jobs = GetJobs:InvokeServer()
	if jobs then
		for _, job in ipairs(jobs) do
			createJobCard(job)
		end
	end
end

navButtons["jobs"].btn.MouseButton1Click:Connect(function()
	refreshJobsUI()
	jobsOverlay.Visible = true
end)

----------------------------------------------------------------
-- CRIME MODAL
----------------------------------------------------------------

local crimeOverlay, crimeCard, crimeContent = createModal("CrimeOverlay", Color3.fromRGB(127, 29, 29), "😈", "Crime")

local crimeWarning = Instance.new("TextLabel")
crimeWarning.BackgroundTransparency = 1
crimeWarning.Size = UDim2.new(1, 0, 0, 40)
crimeWarning.Font = BODY_FONT
crimeWarning.TextSize = 13
crimeWarning.TextWrapped = true
crimeWarning.TextColor3 = Colors.TextSecondary
crimeWarning.Text = "⚠️ Crime doesn't pay... or does it? Get caught and you'll go to prison!"
crimeWarning.ZIndex = 53
crimeWarning.Parent = crimeContent

local crimeScroll = Instance.new("ScrollingFrame")
crimeScroll.BackgroundTransparency = 1
crimeScroll.Size = UDim2.new(1, 0, 1, -52)
crimeScroll.Position = UDim2.new(0, 0, 0, 48)
crimeScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
crimeScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
crimeScroll.ScrollBarThickness = 4
crimeScroll.ZIndex = 52
crimeScroll.Parent = crimeContent

createUIListLayout(crimeScroll, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, 10)

local function createCrimeCard(crime)
	local card = Instance.new("Frame")
	card.BackgroundColor3 = Colors.BgCard
	card.Size = UDim2.new(1, 0, 0, 90)
	card.ZIndex = 53
	card.Parent = crimeScroll
	createUICorner(card, 14)
	createUIStroke(card, 1, 0.85, Colors.Border)

	createUIPadding(card, 14, 14, 10, 10)

	local emoji = Instance.new("TextLabel")
	emoji.BackgroundTransparency = 1
	emoji.Size = UDim2.new(0, 36, 0, 36)
	emoji.Font = BODY_FONT
	emoji.TextSize = 26
	emoji.Text = crime.emoji
	emoji.ZIndex = 54
	emoji.Parent = card

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(0.6, 0, 0, 20)
	title.Position = UDim2.new(0, 44, 0, 0)
	title.Font = TITLE_FONT
	title.TextSize = 15
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = Colors.TextPrimary
	title.Text = crime.name
	title.ZIndex = 54
	title.Parent = card

	local desc = Instance.new("TextLabel")
	desc.BackgroundTransparency = 1
	desc.Size = UDim2.new(0.6, 0, 0, 16)
	desc.Position = UDim2.new(0, 44, 0, 20)
	desc.Font = BODY_FONT
	desc.TextSize = 12
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.TextColor3 = Colors.TextSecondary
	desc.Text = crime.description
	desc.ZIndex = 54
	desc.Parent = card

	local payout = Instance.new("TextLabel")
	payout.BackgroundTransparency = 1
	payout.Size = UDim2.new(0.5, 0, 0, 14)
	payout.Position = UDim2.new(0, 44, 0, 38)
	payout.Font = CHIP_FONT
	payout.TextSize = 12
	payout.TextXAlignment = Enum.TextXAlignment.Left
	payout.TextColor3 = Colors.Success
	payout.Text = formatMoney(crime.minPayout) .. " - " .. formatMoney(crime.maxPayout)
	payout.ZIndex = 54
	payout.Parent = card

	local risk = Instance.new("TextLabel")
	risk.BackgroundTransparency = 1
	risk.Size = UDim2.new(1, 0, 0, 14)
	risk.Position = UDim2.new(0, 0, 1, -14)
	risk.Font = BODY_FONT
	risk.TextSize = 11
	risk.TextXAlignment = Enum.TextXAlignment.Left
	risk.TextColor3 = Colors.Danger
	risk.Text = "⛓️ " .. crime.jailYears .. " years if caught • Age " .. crime.minAge .. "+"
	risk.ZIndex = 54
	risk.Parent = card

	local commitBtn = Instance.new("TextButton")
	commitBtn.BackgroundColor3 = crime.canDo and Color3.fromRGB(127, 29, 29) or Color3.fromRGB(203, 213, 225)
	commitBtn.Size = UDim2.new(0, 80, 0, 36)
	commitBtn.Position = UDim2.new(1, -80, 0, 0)
	commitBtn.Font = CHIP_FONT
	commitBtn.TextSize = 13
	commitBtn.TextColor3 = Colors.TextWhite
	commitBtn.Text = crime.canDo and "Commit" or "Locked"
	commitBtn.Active = crime.canDo
	commitBtn.ZIndex = 54
	commitBtn.Parent = card
	createUICorner(commitBtn, 10)

	if crime.canDo then
		commitBtn.MouseButton1Click:Connect(function()
			commitBtn.Text = "..."
			commitBtn.Active = false
			local result = CommitCrime:InvokeServer(crime.id)
			if result then
				if result.success then
					commitBtn.Text = "💰"
					commitBtn.BackgroundColor3 = Colors.Success
				else
					if result.caught then
						commitBtn.Text = "🚔"
						commitBtn.BackgroundColor3 = Colors.Danger
					else
						commitBtn.Text = "Commit"
						commitBtn.Active = true
					end
				end
			end
			task.wait(1.5)
			refreshCrimeUI()
		end)
	end

	return card
end

function refreshCrimeUI()
	for _, child in ipairs(crimeScroll:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	if currentState and currentState.InJail then
		crimeWarning.Text = "🔒 You're in prison! " .. (currentState.JailYearsLeft or 0) .. " years remaining. Age up to serve your sentence."
	else
		crimeWarning.Text = "⚠️ Crime doesn't pay... or does it? Get caught and you'll go to prison!"
	end

	local crimes = GetCrimes:InvokeServer()
	if crimes then
		for _, crime in ipairs(crimes) do
			createCrimeCard(crime)
		end
	end
end

navButtons["crime"].btn.MouseButton1Click:Connect(function()
	refreshCrimeUI()
	crimeOverlay.Visible = true
end)

----------------------------------------------------------------
-- ACTIVITIES MODAL
----------------------------------------------------------------

local activitiesOverlay, activitiesCard, activitiesContent = createModal("ActivitiesOverlay", Colors.Purple, "🎯", "Activities")

local activityScroll = Instance.new("ScrollingFrame")
activityScroll.BackgroundTransparency = 1
activityScroll.Size = UDim2.new(1, 0, 1, -8)
activityScroll.Position = UDim2.new(0, 0, 0, 4)
activityScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
activityScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
activityScroll.ScrollBarThickness = 4
activityScroll.ZIndex = 52
activityScroll.Parent = activitiesContent

createUIListLayout(activityScroll, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, 10)

local function createActivityCard(activity)
	local card = Instance.new("Frame")
	card.BackgroundColor3 = Colors.BgCard
	card.Size = UDim2.new(1, 0, 0, 85)
	card.ZIndex = 53
	card.Parent = activityScroll
	createUICorner(card, 14)
	createUIStroke(card, 1, 0.85, Colors.Border)

	createUIPadding(card, 14, 14, 10, 10)

	local emoji = Instance.new("TextLabel")
	emoji.BackgroundTransparency = 1
	emoji.Size = UDim2.new(0, 36, 0, 36)
	emoji.Font = BODY_FONT
	emoji.TextSize = 26
	emoji.Text = activity.emoji
	emoji.ZIndex = 54
	emoji.Parent = card

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(0.55, 0, 0, 20)
	title.Position = UDim2.new(0, 44, 0, 0)
	title.Font = TITLE_FONT
	title.TextSize = 15
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = Colors.TextPrimary
	title.Text = activity.name
	title.ZIndex = 54
	title.Parent = card

	local category = Instance.new("TextLabel")
	category.BackgroundTransparency = 1
	category.Size = UDim2.new(0.5, 0, 0, 16)
	category.Position = UDim2.new(0, 44, 0, 20)
	category.Font = BODY_FONT
	category.TextSize = 12
	category.TextXAlignment = Enum.TextXAlignment.Left
	category.TextColor3 = Colors.TextSecondary
	category.Text = activity.category
	category.ZIndex = 54
	category.Parent = card

	-- Effects display
	local effectsText = ""
	for stat, val in pairs(activity.effects or {}) do
		if effectsText ~= "" then effectsText = effectsText .. " " end
		local sign = val > 0 and "+" or ""
		effectsText = effectsText .. stat:sub(1, 3) .. " " .. sign .. val
	end

	local effects = Instance.new("TextLabel")
	effects.BackgroundTransparency = 1
	effects.Size = UDim2.new(1, -100, 0, 14)
	effects.Position = UDim2.new(0, 0, 1, -14)
	effects.Font = BODY_FONT
	effects.TextSize = 11
	effects.TextXAlignment = Enum.TextXAlignment.Left
	effects.TextColor3 = Colors.TextMuted
	effects.Text = effectsText .. (activity.cost > 0 and (" • " .. formatMoney(activity.cost)) or " • Free")
	effects.ZIndex = 54
	effects.Parent = card

	local doBtn = Instance.new("TextButton")
	doBtn.BackgroundColor3 = activity.canDo and Colors.Purple or Color3.fromRGB(203, 213, 225)
	doBtn.Size = UDim2.new(0, 70, 0, 36)
	doBtn.Position = UDim2.new(1, -70, 0, 0)
	doBtn.Font = CHIP_FONT
	doBtn.TextSize = 13
	doBtn.TextColor3 = Colors.TextWhite
	doBtn.Text = activity.canDo and "Do" or "Locked"
	doBtn.Active = activity.canDo
	doBtn.ZIndex = 54
	doBtn.Parent = card
	createUICorner(doBtn, 10)

	if activity.canDo then
		doBtn.MouseButton1Click:Connect(function()
			doBtn.Text = "..."
			doBtn.Active = false
			local result = DoActivity:InvokeServer(activity.id)
			if result then
				if result.success then
					doBtn.Text = "✓"
					doBtn.BackgroundColor3 = Colors.Success
				else
					doBtn.Text = "Do"
					doBtn.Active = true
				end
			end
			task.wait(1)
			refreshActivitiesUI()
		end)
	end

	return card
end

function refreshActivitiesUI()
	for _, child in ipairs(activityScroll:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local activities = GetActivities:InvokeServer()
	if activities then
		for _, activity in ipairs(activities) do
			createActivityCard(activity)
		end
	end
end

navButtons["activities"].btn.MouseButton1Click:Connect(function()
	refreshActivitiesUI()
	activitiesOverlay.Visible = true
end)

----------------------------------------------------------------
-- STATS MODAL
----------------------------------------------------------------

local statsOverlay, statsCard, statsContent = createModal("StatsOverlay", Colors.Orange, "📊", "Full Stats")

local statsDetailScroll = Instance.new("ScrollingFrame")
statsDetailScroll.BackgroundTransparency = 1
statsDetailScroll.Size = UDim2.new(1, 0, 1, -8)
statsDetailScroll.Position = UDim2.new(0, 0, 0, 4)
statsDetailScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
statsDetailScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
statsDetailScroll.ScrollBarThickness = 4
statsDetailScroll.ZIndex = 52
statsDetailScroll.Parent = statsContent

createUIListLayout(statsDetailScroll, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, 12)

local function createStatDetailCard(icon, name, value, color)
	local card = Instance.new("Frame")
	card.BackgroundColor3 = Colors.BgCard
	card.Size = UDim2.new(1, 0, 0, 70)
	card.ZIndex = 53
	card.Parent = statsDetailScroll
	createUICorner(card, 14)
	createUIStroke(card, 1, 0.85, Colors.Border)

	createUIPadding(card, 16, 16, 0, 0)

	local iconLabel = Instance.new("TextLabel")
	iconLabel.BackgroundTransparency = 1
	iconLabel.Size = UDim2.new(0, 40, 0, 40)
	iconLabel.Position = UDim2.new(0, 0, 0.5, 0)
	iconLabel.AnchorPoint = Vector2.new(0, 0.5)
	iconLabel.Font = BODY_FONT
	iconLabel.TextSize = 28
	iconLabel.Text = icon
	iconLabel.ZIndex = 54
	iconLabel.Parent = card

	local nameL = Instance.new("TextLabel")
	nameL.BackgroundTransparency = 1
	nameL.Size = UDim2.new(0.5, 0, 0, 24)
	nameL.Position = UDim2.new(0, 50, 0, 12)
	nameL.Font = TITLE_FONT
	nameL.TextSize = 16
	nameL.TextXAlignment = Enum.TextXAlignment.Left
	nameL.TextColor3 = Colors.TextPrimary
	nameL.Text = name
	nameL.ZIndex = 54
	nameL.Parent = card

	local valueL = Instance.new("TextLabel")
	valueL.BackgroundTransparency = 1
	valueL.Size = UDim2.new(0, 60, 0, 24)
	valueL.Position = UDim2.new(1, -60, 0, 12)
	valueL.Font = TITLE_FONT
	valueL.TextSize = 18
	valueL.TextXAlignment = Enum.TextXAlignment.Right
	valueL.TextColor3 = color
	valueL.Text = value .. "%"
	valueL.ZIndex = 54
	valueL.Parent = card

	local barBg = Instance.new("Frame")
	barBg.BackgroundColor3 = Color3.fromRGB(241, 245, 249)
	barBg.Size = UDim2.new(1, -50, 0, 10)
	barBg.Position = UDim2.new(0, 50, 0, 44)
	barBg.ZIndex = 54
	barBg.Parent = card
	createUICorner(barBg, 5)

	local barFill = Instance.new("Frame")
	barFill.BackgroundColor3 = color
	barFill.Size = UDim2.new(math.clamp(value / 100, 0, 1), 0, 1, 0)
	barFill.ZIndex = 55
	barFill.Parent = barBg
	createUICorner(barFill, 5)

	return card
end

function refreshStatsUI()
	for _, child in ipairs(statsDetailScroll:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	if not currentState then return end

	local stats = currentState.Stats or {}
	
	createStatDetailCard("😊", "Happiness", stats.Happiness or 0, Color3.fromRGB(251, 191, 36))
	createStatDetailCard("❤️", "Health", stats.Health or 0, Color3.fromRGB(239, 68, 68))
	createStatDetailCard("🧠", "Smarts", stats.Smarts or 0, Color3.fromRGB(147, 51, 234))
	createStatDetailCard("✨", "Looks", stats.Looks or 0, Color3.fromRGB(236, 72, 153))

	-- Additional info
	local infoCard = Instance.new("Frame")
	infoCard.BackgroundColor3 = Color3.fromRGB(248, 250, 252)
	infoCard.Size = UDim2.new(1, 0, 0, 120)
	infoCard.ZIndex = 53
	infoCard.Parent = statsDetailScroll
	createUICorner(infoCard, 14)

	createUIPadding(infoCard, 16, 16, 12, 12)

	local infoTitle = Instance.new("TextLabel")
	infoTitle.BackgroundTransparency = 1
	infoTitle.Size = UDim2.new(1, 0, 0, 20)
	infoTitle.Font = TITLE_FONT
	infoTitle.TextSize = 14
	infoTitle.TextXAlignment = Enum.TextXAlignment.Left
	infoTitle.TextColor3 = Colors.TextPrimary
	infoTitle.Text = "📋 Life Info"
	infoTitle.ZIndex = 54
	infoTitle.Parent = infoCard

	local infoText = Instance.new("TextLabel")
	infoText.BackgroundTransparency = 1
	infoText.Size = UDim2.new(1, 0, 0, 80)
	infoText.Position = UDim2.new(0, 0, 0, 26)
	infoText.Font = BODY_FONT
	infoText.TextSize = 13
	infoText.TextXAlignment = Enum.TextXAlignment.Left
	infoText.TextYAlignment = Enum.TextYAlignment.Top
	infoText.TextColor3 = Colors.TextSecondary
	infoText.TextWrapped = true
	infoText.ZIndex = 54
	infoText.Parent = infoCard

	local lines = {
		"Age: " .. (currentState.Age or 0) .. " years old",
		"Year: " .. (currentState.Year or 2025),
		"Net Worth: " .. formatMoney(currentState.Money or 0),
		"Criminal Record: " .. (currentState.CrimeRecord or 0) .. " offenses",
	}
	if currentState.InJail then
		table.insert(lines, "Status: 🔒 In Prison (" .. (currentState.JailYearsLeft or 0) .. " years left)")
	elseif currentState.Job then
		table.insert(lines, "Status: " .. currentState.Job.emoji .. " " .. currentState.Job.title)
	else
		table.insert(lines, "Status: Unemployed")
	end

	infoText.Text = table.concat(lines, "\n")
end

navButtons["stats"].btn.MouseButton1Click:Connect(function()
	refreshStatsUI()
	statsOverlay.Visible = true
end)

----------------------------------------------------------------
-- INTRO OVERLAYS
----------------------------------------------------------------

local maleFirst = { "Anthony", "Scott", "Logan", "Ethan", "Noah", "Liam", "Mason", "Jayden", "Caleb", "Damian" }
local femaleFirst = { "Olivia", "Emma", "Ava", "Sophia", "Mia", "Amelia", "Isabella", "Charlotte", "Luna", "Stella" }
local lastNames = { "Russell", "Allen", "Flores", "Cooper", "Parker", "Reed", "Mitchell", "Walker", "Gray", "Brooks" }

local selectedGender = nil
local selectedName = nil

-- Gender overlay
local genderOverlay = Instance.new("Frame")
genderOverlay.Name = "GenderOverlay"
genderOverlay.Size = UDim2.fromScale(1, 1)
genderOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
genderOverlay.BackgroundTransparency = 0.5
genderOverlay.Visible = false
genderOverlay.ZIndex = 60
genderOverlay.Parent = screenGui

local genderCard = Instance.new("Frame")
genderCard.AnchorPoint = Vector2.new(0.5, 0.5)
genderCard.Position = UDim2.fromScale(0.5, 0.5)
genderCard.Size = UDim2.new(0, 380, 0, 280)
genderCard.BackgroundColor3 = Colors.BgCard
genderCard.ZIndex = 61
genderCard.Parent = genderOverlay
createUICorner(genderCard, 24)
createShadow(genderCard)

local genderHeader = Instance.new("Frame")
genderHeader.BackgroundColor3 = Colors.Primary
genderHeader.Size = UDim2.new(1, 0, 0, 60)
genderHeader.ZIndex = 62
genderHeader.Parent = genderCard
createUICorner(genderHeader, 24)

local genderHeaderBottom = Instance.new("Frame")
genderHeaderBottom.BackgroundColor3 = Colors.Primary
genderHeaderBottom.Size = UDim2.new(1, 0, 0, 24)
genderHeaderBottom.Position = UDim2.new(0, 0, 1, -24)
genderHeaderBottom.BorderSizePixel = 0
genderHeaderBottom.ZIndex = 62
genderHeaderBottom.Parent = genderHeader

local genderTitle = Instance.new("TextLabel")
genderTitle.BackgroundTransparency = 1
genderTitle.Size = UDim2.new(1, 0, 1, 0)
genderTitle.Font = TITLE_FONT
genderTitle.TextSize = 20
genderTitle.TextColor3 = Colors.TextWhite
genderTitle.Text = "👶 Start Your New Life"
genderTitle.ZIndex = 63
genderTitle.Parent = genderHeader

local genderSubtitle = Instance.new("TextLabel")
genderSubtitle.BackgroundTransparency = 1
genderSubtitle.Size = UDim2.new(1, 0, 0, 30)
genderSubtitle.Position = UDim2.new(0, 0, 0, 70)
genderSubtitle.Font = BODY_FONT
genderSubtitle.TextSize = 15
genderSubtitle.TextColor3 = Colors.TextSecondary
genderSubtitle.Text = "Choose your gender to begin"
genderSubtitle.ZIndex = 62
genderSubtitle.Parent = genderCard

local genderButtonsHolder = Instance.new("Frame")
genderButtonsHolder.BackgroundTransparency = 1
genderButtonsHolder.Size = UDim2.new(1, -48, 0, 140)
genderButtonsHolder.Position = UDim2.new(0, 24, 0, 110)
genderButtonsHolder.ZIndex = 62
genderButtonsHolder.Parent = genderCard

createUIListLayout(genderButtonsHolder, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, 12)

local function createGenderButton(text, emoji, color)
	local btn = Instance.new("TextButton")
	btn.BackgroundColor3 = color
	btn.AutoButtonColor = false
	btn.Size = UDim2.new(1, 0, 0, 56)
	btn.Font = CHIP_FONT
	btn.TextSize = 18
	btn.TextColor3 = Colors.TextWhite
	btn.Text = emoji .. "  " .. text
	btn.ZIndex = 63
	btn.Parent = genderButtonsHolder
	createUICorner(btn, 16)
	return btn
end

local maleBtn = createGenderButton("Male", "♂", Color3.fromRGB(56, 189, 248))
local femaleBtn = createGenderButton("Female", "♀", Color3.fromRGB(244, 114, 182))

-- Name overlay
local nameOverlay = Instance.new("Frame")
nameOverlay.Name = "NameOverlay"
nameOverlay.Size = UDim2.fromScale(1, 1)
nameOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
nameOverlay.BackgroundTransparency = 0.5
nameOverlay.Visible = false
nameOverlay.ZIndex = 61
nameOverlay.Parent = screenGui

local nameCard = Instance.new("Frame")
nameCard.AnchorPoint = Vector2.new(0.5, 0.5)
nameCard.Position = UDim2.fromScale(0.5, 0.5)
nameCard.Size = UDim2.new(0, 380, 0, 320)
nameCard.BackgroundColor3 = Colors.BgCard
nameCard.ZIndex = 62
nameCard.Parent = nameOverlay
createUICorner(nameCard, 24)
createShadow(nameCard)

local nameHeader = Instance.new("Frame")
nameHeader.BackgroundColor3 = Colors.Success
nameHeader.Size = UDim2.new(1, 0, 0, 60)
nameHeader.ZIndex = 63
nameHeader.Parent = nameCard
createUICorner(nameHeader, 24)

local nameHeaderBottom = Instance.new("Frame")
nameHeaderBottom.BackgroundColor3 = Colors.Success
nameHeaderBottom.Size = UDim2.new(1, 0, 0, 24)
nameHeaderBottom.Position = UDim2.new(0, 0, 1, -24)
nameHeaderBottom.BorderSizePixel = 0
nameHeaderBottom.ZIndex = 63
nameHeaderBottom.Parent = nameHeader

local nameTitle = Instance.new("TextLabel")
nameTitle.BackgroundTransparency = 1
nameTitle.Size = UDim2.new(1, 0, 1, 0)
nameTitle.Font = TITLE_FONT
nameTitle.TextSize = 20
nameTitle.TextColor3 = Colors.TextWhite
nameTitle.Text = "✨ Choose Your Identity"
nameTitle.ZIndex = 64
nameTitle.Parent = nameHeader

local nameSubtitle = Instance.new("TextLabel")
nameSubtitle.BackgroundTransparency = 1
nameSubtitle.Size = UDim2.new(1, 0, 0, 30)
nameSubtitle.Position = UDim2.new(0, 0, 0, 70)
nameSubtitle.Font = BODY_FONT
nameSubtitle.TextSize = 15
nameSubtitle.TextColor3 = Colors.TextSecondary
nameSubtitle.Text = "Who will you become?"
nameSubtitle.ZIndex = 63
nameSubtitle.Parent = nameCard

local namesHolder = Instance.new("Frame")
namesHolder.BackgroundTransparency = 1
namesHolder.Size = UDim2.new(1, -48, 0, 180)
namesHolder.Position = UDim2.new(0, 24, 0, 110)
namesHolder.ZIndex = 63
namesHolder.Parent = nameCard

createUIListLayout(namesHolder, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, 12)

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

local function generateNameOptions()
	clearNameButtons()
	if not selectedGender then return end

	local colors = {
		Color3.fromRGB(34, 197, 94),
		Color3.fromRGB(251, 191, 36),
		Color3.fromRGB(249, 115, 22),
	}

	for i = 1, 3 do
		local firstList = (selectedGender == "Female") and femaleFirst or maleFirst
		local fullName = randomFrom(firstList) .. " " .. randomFrom(lastNames)

		local btn = Instance.new("TextButton")
		btn.AutoButtonColor = false
		btn.Size = UDim2.new(1, 0, 0, 52)
		btn.Font = CHIP_FONT
		btn.TextSize = 18
		btn.TextColor3 = Colors.TextWhite
		btn.BackgroundColor3 = colors[i]
		btn.Text = fullName
		btn.ZIndex = 64
		btn.Parent = namesHolder
		createUICorner(btn, 14)

		table.insert(nameButtons, btn)

		btn.MouseButton1Click:Connect(function()
			selectedName = fullName
			SetLifeInfo:FireServer(selectedName, selectedGender)
			nameOverlay.Visible = false
			ageHint.Visible = true
		end)
	end
end

maleBtn.MouseButton1Click:Connect(function()
	selectedGender = "Male"
	genderOverlay.Visible = false
	nameOverlay.Visible = true
	generateNameOptions()
end)

femaleBtn.MouseButton1Click:Connect(function()
	selectedGender = "Female"
	genderOverlay.Visible = false
	nameOverlay.Visible = true
	generateNameOptions()
end)

----------------------------------------------------------------
-- STATE SYNC
----------------------------------------------------------------

local function updateFromState()
	if not currentState then return end

	local stats = currentState.Stats or {}

	for key, card in pairs(statCards) do
		local v = math.floor(stats[key] or 0)
		card.valueLabel.Text = tostring(v) .. "%"
		local pct = math.clamp(v / 100, 0, 1)
		card.barFill:TweenSize(
			UDim2.new(pct, 0, 1, 0),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Quad,
			0.2,
			true
		)
	end

	local displayName = currentState.Name or "New Life"
	nameLabel.Text = displayName

	local age = currentState.Age or 0
	local year = currentState.Year or 2025
	ageYearLabel.Text = string.format("Age %d • Year %d", age, year)

	-- Update avatar based on age
	if age < 3 then
		avatarEmoji.Text = "👶"
	elseif age < 13 then
		avatarEmoji.Text = currentState.Gender == "Female" and "👧" or "👦"
	elseif age < 20 then
		avatarEmoji.Text = currentState.Gender == "Female" and "👩" or "👨"
	elseif age < 60 then
		avatarEmoji.Text = currentState.Gender == "Female" and "👩" or "👨"
	else
		avatarEmoji.Text = currentState.Gender == "Female" and "👵" or "👴"
	end

	-- Update job label
	if currentState.InJail then
		jobLabel.Text = "🔒 In Prison (" .. (currentState.JailYearsLeft or 0) .. " years left)"
		jobLabel.TextColor3 = Colors.Danger
	elseif currentState.Job then
		jobLabel.Text = currentState.Job.emoji .. " " .. currentState.Job.title .. " at " .. currentState.Job.company
		jobLabel.TextColor3 = Colors.TextMuted
	else
		jobLabel.Text = "🚫 Unemployed"
		jobLabel.TextColor3 = Colors.TextMuted
	end

	local money = currentState.Money or 0
	moneyLabel.Text = formatMoney(money)
	
	if money < 0 then
		moneyChip.BackgroundColor3 = Colors.Danger
	else
		moneyChip.BackgroundColor3 = Colors.Success
	end

	-- Show intro if name not set
	if not currentState.Name then
		ageButton.Visible = false
		ageHint.Visible = false
		genderOverlay.Visible = true
		nameOverlay.Visible = false
	else
		ageButton.Visible = true
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
	local ti = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	tween(ageButton, ti, { Size = UDim2.new(0, 108, 0, 108) }).Completed:Wait()
	tween(ageButton, ti, { Size = UDim2.new(0, 100, 0, 100) })
end

ageButton.MouseButton1Click:Connect(function()
	if awaitingEvent then return end
	if currentState and not currentState.Name then return end

	pulseAgeButton()
	ageHint.Visible = false
	RequestAgeUp:FireServer()
end)

ageButton.MouseEnter:Connect(function()
	tween(ageButton, TweenInfo.new(0.15), { Size = UDim2.new(0, 106, 0, 106) })
end)

ageButton.MouseLeave:Connect(function()
	tween(ageButton, TweenInfo.new(0.15), { Size = UDim2.new(0, 100, 0, 100) })
end)
