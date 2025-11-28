-- StarterPlayerScripts / LifeClient (LocalScript)
-- BitLife-style UI: 1:1 copy of BitLife interface

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")

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

----------------------------------------------------------------
-- STATE
----------------------------------------------------------------

local currentState    = nil
local awaitingEvent   = false
local hasShownAgeHint = false

----------------------------------------------------------------
-- COLORS & STYLING (BitLife exact)
----------------------------------------------------------------

local COLORS = {
	-- Main cards
	WHITE_CARD = Color3.fromRGB(255, 255, 255),
	
	-- Relationship banner
	RED_ORANGE = Color3.fromRGB(255, 87, 34), -- BitLife red-orange
	
	-- Buttons
	BITLIFE_BLUE = Color3.fromRGB(33, 150, 243), -- Primary blue
	GREEN_AGE = Color3.fromRGB(76, 175, 80), -- Age button green
	PINK_FEMALE = Color3.fromRGB(233, 30, 99), -- Female pink
	BLUE_MALE = Color3.fromRGB(33, 150, 243), -- Male blue
	
	-- Text
	BRIGHT_YELLOW = Color3.fromRGB(255, 235, 59),
	DARK_GREY = Color3.fromRGB(97, 97, 97),
	LIGHT_GREY = Color3.fromRGB(189, 189, 189),
	
	-- Stat bars
	STAT_BG = Color3.fromRGB(224, 224, 224),
	STAT_FILL_GOOD = Color3.fromRGB(76, 175, 80),
	STAT_FILL_BAD = Color3.fromRGB(244, 67, 54),
	BOOST_ORANGE = Color3.fromRGB(255, 152, 0),
	
	-- Name pills
	GREEN_NAME = Color3.fromRGB(76, 175, 80),
	YELLOW_NAME = Color3.fromRGB(255, 193, 7),
	ORANGE_NAME = Color3.fromRGB(255, 152, 0),
}

local FONTS = {
	TITLE = Enum.Font.GothamBold,
	BODY = Enum.Font.Gotham,
	BUTTON = Enum.Font.GothamMedium,
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

local function createBlur(parent, size)
	local blur = Instance.new("BlurEffect")
	blur.Size = size
	blur.Parent = parent
	return blur
end

local function tween(obj, info, props)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

----------------------------------------------------------------
-- ROOT GUI (Main game screen - white card on light bg)
----------------------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LifeGui"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Light background (visible when not blurred)
local bg = Instance.new("Frame")
bg.Name = "Background"
bg.Size = UDim2.fromScale(1, 1)
bg.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
bg.Parent = screenGui

-- Main white card (centered, rounded)
local root = Instance.new("Frame")
root.Name = "RootCard"
root.AnchorPoint = Vector2.new(0.5, 0.5)
root.Position = UDim2.fromScale(0.5, 0.5)
root.Size = UDim2.new(0.95, 0, 0.92, 0)
root.BackgroundColor3 = COLORS.WHITE_CARD
root.Parent = bg
createUICorner(root, 20)
createUIStroke(root, 1, 0.3, Color3.fromRGB(200, 200, 200))

----------------------------------------------------------------
-- HEADER (avatar + name + money chip)
----------------------------------------------------------------

local header = Instance.new("Frame")
header.Name = "Header"
header.BackgroundColor3 = COLORS.WHITE_CARD
header.Size = UDim2.new(1, -32, 0, 70)
header.Position = UDim2.new(0, 16, 0, 16)
header.Parent = root
createUICorner(header, 18)

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

-- Avatar circle
local avatarFrame = Instance.new("Frame")
avatarFrame.Size = UDim2.new(0, 50, 0, 50)
avatarFrame.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
avatarFrame.Parent = header
createUICorner(avatarFrame, 25)

local avatarEmoji = Instance.new("TextLabel")
avatarEmoji.BackgroundTransparency = 1
avatarEmoji.Size = UDim2.fromScale(1, 1)
avatarEmoji.Font = FONTS.BODY
avatarEmoji.TextSize = 28
avatarEmoji.TextColor3 = Color3.fromRGB(50, 50, 50)
avatarEmoji.Text = "👶"
avatarEmoji.Parent = avatarFrame

-- Name label
local nameLabel = Instance.new("TextLabel")
nameLabel.BackgroundTransparency = 1
nameLabel.Size = UDim2.new(0, 200, 0, 50)
nameLabel.Font = FONTS.TITLE
nameLabel.TextSize = 22
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.TextColor3 = Color3.fromRGB(20, 20, 20)
nameLabel.Text = "New Life"
nameLabel.Parent = header

-- Money chip (right side)
local moneyChip = Instance.new("TextLabel")
moneyChip.BackgroundColor3 = COLORS.BITLIFE_BLUE
moneyChip.Font = FONTS.BUTTON
moneyChip.TextSize = 16
moneyChip.TextColor3 = Color3.new(1, 1, 1)
moneyChip.TextXAlignment = Enum.TextXAlignment.Center
moneyChip.AnchorPoint = Vector2.new(1, 0.5)
moneyChip.Position = UDim2.new(1, -4, 0.5, 0)
moneyChip.Size = UDim2.new(0, 100, 0, 36)
moneyChip.Text = "$0"
moneyChip.Parent = header
createUICorner(moneyChip, 18)

----------------------------------------------------------------
-- FEED AREA (Life feed with "Age: X years" entries)
----------------------------------------------------------------

local feedCard = Instance.new("Frame")
feedCard.Name = "FeedCard"
feedCard.BackgroundColor3 = COLORS.WHITE_CARD
feedCard.Size = UDim2.new(1, -32, 1, -280)
feedCard.Position = UDim2.new(0, 16, 0, 98)
feedCard.Parent = root
createUICorner(feedCard, 18)

local feedPad = Instance.new("UIPadding")
feedPad.PaddingLeft   = UDim.new(0, 20)
feedPad.PaddingRight  = UDim.new(0, 20)
feedPad.PaddingTop    = UDim.new(0, 16)
feedPad.PaddingBottom = UDim.new(0, 16)
feedPad.Parent = feedCard

local feedScroll = Instance.new("ScrollingFrame")
feedScroll.Name = "FeedScroll"
feedScroll.BackgroundTransparency = 1
feedScroll.Size = UDim2.new(1, 0, 1, 0)
feedScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
feedScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
feedScroll.ScrollBarThickness = 4
feedScroll.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
feedScroll.Parent = feedCard

local feedLayout = Instance.new("UIListLayout")
feedLayout.FillDirection = Enum.FillDirection.Vertical
feedLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
feedLayout.VerticalAlignment   = Enum.VerticalAlignment.Top
feedLayout.Padding = UDim.new(0, 12)
feedLayout.SortOrder = Enum.SortOrder.LayoutOrder
feedLayout.Parent = feedScroll

local currentAgeEntry = nil
local ageEntryCount = 0

local function addFeedEntry(text, age)
	if not text or text == "" then
		return
	end
	
	-- If this is an age entry, create "Age: X years" header
	if age ~= nil and (not currentAgeEntry or currentAgeEntry.age ~= age) then
		ageEntryCount = ageEntryCount + 1
		
		-- Age header
		local ageHeader = Instance.new("TextLabel")
		ageHeader.BackgroundTransparency = 1
		ageHeader.Size = UDim2.new(1, 0, 0, 24)
		ageHeader.Font = FONTS.TITLE
		ageHeader.TextSize = 18
		ageHeader.TextXAlignment = Enum.TextXAlignment.Left
		ageHeader.TextColor3 = COLORS.BITLIFE_BLUE
		ageHeader.Text = string.format("Age: %d years", age)
		ageHeader.LayoutOrder = ageEntryCount * 1000
		ageHeader.Parent = feedScroll
		
		currentAgeEntry = { age = age, header = ageHeader, entries = {} }
	end
	
	-- Feed entry bullet point
	local entry = Instance.new("TextLabel")
	entry.BackgroundTransparency = 1
	entry.Size = UDim2.new(1, -20, 0, 0)
	entry.AutomaticSize = Enum.AutomaticSize.Y
	entry.Font = FONTS.BODY
	entry.TextSize = 15
	entry.TextWrapped = true
	entry.TextXAlignment = Enum.TextXAlignment.Left
	entry.TextYAlignment = Enum.TextYAlignment.Top
	entry.TextColor3 = Color3.fromRGB(60, 60, 60)
	entry.Text = "• " .. text
	
	local entryCount = 0
	if currentAgeEntry and currentAgeEntry.entries then
		entryCount = #currentAgeEntry.entries
	end
	
	-- If no age provided, use a high layout order so it appears at top
	if age == nil then
		entry.LayoutOrder = -1000 + entryCount
	else
		entry.LayoutOrder = (ageEntryCount * 1000) + entryCount + 1
	end
	
	entry.Parent = feedScroll
	
	if currentAgeEntry then
		table.insert(currentAgeEntry.entries, entry)
	end
	
	-- Auto scroll
	task.delay(0.1, function()
		feedScroll.CanvasPosition = Vector2.new(
			0,
			math.max(0, feedScroll.AbsoluteCanvasSize.Y - feedScroll.AbsoluteWindowSize.Y)
		)
	end)
end

----------------------------------------------------------------
-- STATS PANEL (bottom, with Boost buttons)
----------------------------------------------------------------

local statsBar = Instance.new("Frame")
statsBar.Name = "StatsBar"
statsBar.BackgroundColor3 = COLORS.WHITE_CARD
statsBar.Size = UDim2.new(1, -32, 0, 90)
statsBar.AnchorPoint = Vector2.new(0.5, 1)
statsBar.Position = UDim2.new(0.5, 0, 1, -150)
statsBar.Parent = root
createUICorner(statsBar, 18)

local statsPad = Instance.new("UIPadding")
statsPad.PaddingLeft  = UDim.new(0, 16)
statsPad.PaddingRight = UDim.new(0, 16)
statsPad.PaddingTop   = UDim.new(0, 12)
statsPad.PaddingBottom = UDim.new(0, 12)
statsPad.Parent = statsBar

local statsLayout = Instance.new("UIListLayout")
statsLayout.FillDirection = Enum.FillDirection.Horizontal
statsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
statsLayout.VerticalAlignment   = Enum.VerticalAlignment.Top
statsLayout.Padding = UDim.new(0, 12)
statsLayout.Parent = statsBar

local statMeta = {
	{ key = "Happiness", icon = "😀", label = "Happiness" },
	{ key = "Health",    icon = "❤️", label = "Health"    },
	{ key = "Smarts",    icon = "🧠", label = "Smarts"    },
	{ key = "Looks",     icon = "💄", label = "Looks"     },
}

local statCards = {}

for _, info in ipairs(statMeta) do
	local holder = Instance.new("Frame")
	holder.BackgroundTransparency = 1
	holder.Size = UDim2.new(0.23, 0, 1, 0)
	holder.Parent = statsBar
	
	local statLayout = Instance.new("UIListLayout")
	statLayout.FillDirection = Enum.FillDirection.Vertical
	statLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	statLayout.VerticalAlignment   = Enum.VerticalAlignment.Top
	statLayout.Padding = UDim.new(0, 4)
	statLayout.Parent = holder
	
	-- Label row (emoji + text)
	local labelRow = Instance.new("Frame")
	labelRow.BackgroundTransparency = 1
	labelRow.Size = UDim2.new(1, 0, 0, 20)
	labelRow.Parent = holder
	
	local labelLayout = Instance.new("UIListLayout")
	labelLayout.FillDirection = Enum.FillDirection.Horizontal
	labelLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	labelLayout.Padding = UDim.new(0, 4)
	labelLayout.Parent = labelRow
	
	local emojiLabel = Instance.new("TextLabel")
	emojiLabel.BackgroundTransparency = 1
	emojiLabel.Size = UDim2.new(0, 18, 0, 18)
	emojiLabel.Font = FONTS.BODY
	emojiLabel.TextSize = 14
	emojiLabel.Text = info.icon
	emojiLabel.Parent = labelRow
	
	local nameLabelStat = Instance.new("TextLabel")
	nameLabelStat.BackgroundTransparency = 1
	nameLabelStat.Size = UDim2.new(1, -22, 0, 18)
	nameLabelStat.Font = FONTS.BODY
	nameLabelStat.TextSize = 12
	nameLabelStat.TextXAlignment = Enum.TextXAlignment.Left
	nameLabelStat.TextColor3 = COLORS.DARK_GREY
	nameLabelStat.Text = info.label
	nameLabelStat.Parent = labelRow
	
	-- Percentage text
	local valueLabel = Instance.new("TextLabel")
	valueLabel.BackgroundTransparency = 1
	valueLabel.Size = UDim2.new(1, 0, 0, 16)
	valueLabel.Font = FONTS.BUTTON
	valueLabel.TextSize = 13
	valueLabel.TextXAlignment = Enum.TextXAlignment.Left
	valueLabel.TextColor3 = COLORS.DARK_GREY
	valueLabel.Text = "100%"
	valueLabel.Parent = holder
	
	-- Bar container
	local barContainer = Instance.new("Frame")
	barContainer.BackgroundTransparency = 1
	barContainer.Size = UDim2.new(1, 0, 0, 20)
	barContainer.Parent = holder
	
	local barBg = Instance.new("Frame")
	barBg.BackgroundColor3 = COLORS.STAT_BG
	barBg.Size = UDim2.new(1, -50, 0, 8)
	barBg.Position = UDim2.new(0, 0, 0, 6)
	barBg.Parent = barContainer
	createUICorner(barBg, 4)
	
	local barFill = Instance.new("Frame")
	barFill.BackgroundColor3 = COLORS.STAT_FILL_GOOD
	barFill.Size = UDim2.new(1, 0, 1, 0)
	barFill.Parent = barBg
	createUICorner(barFill, 4)
	
	-- Boost button (hidden by default, shown when stat is low)
	local boostBtn = Instance.new("TextButton")
	boostBtn.BackgroundColor3 = COLORS.BOOST_ORANGE
	boostBtn.Size = UDim2.new(0, 45, 0, 20)
	boostBtn.AnchorPoint = Vector2.new(1, 0.5)
	boostBtn.Position = UDim2.new(1, 0, 0.5, 0)
	boostBtn.Font = FONTS.BUTTON
	boostBtn.TextSize = 10
	boostBtn.TextColor3 = Color3.new(1, 1, 1)
	boostBtn.Text = "+ Boost!"
	boostBtn.Visible = false
	boostBtn.AutoButtonColor = false
	boostBtn.Parent = barContainer
	createUICorner(boostBtn, 10)
	
	statCards[info.key] = {
		valueLabel = valueLabel,
		barFill    = barFill,
		barBg      = barBg,
		boostBtn   = boostBtn,
	}
end

----------------------------------------------------------------
-- BOTTOM NAV + AGE BUTTON (BitLife style)
----------------------------------------------------------------

local bottom = Instance.new("Frame")
bottom.Name = "Bottom"
bottom.BackgroundTransparency = 1
bottom.Size = UDim2.new(1, -32, 0, 120)
bottom.AnchorPoint = Vector2.new(0.5, 1)
bottom.Position = UDim2.new(0.5, 0, 1, -20)
bottom.Parent = root

-- Navigation bar (blue)
local navBar = Instance.new("Frame")
navBar.Name = "NavBar"
navBar.AnchorPoint = Vector2.new(0.5, 1)
navBar.Position = UDim2.new(0.5, 0, 1, 0)
navBar.Size = UDim2.new(1, 0, 0, 70)
navBar.BackgroundColor3 = COLORS.BITLIFE_BLUE
navBar.Parent = bottom
createUICorner(navBar, 18)

local navLayout = Instance.new("UIListLayout")
navLayout.FillDirection = Enum.FillDirection.Horizontal
navLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
navLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
navLayout.Padding = UDim.new(0, 20)
navLayout.Parent = navBar

local navItems = {
	{ icon = "💼", text = "Occupation" },
	{ icon = "🏠", text = "Assets"     },
	{ icon = "❤️", text = "Relationships" },
	{ icon = "🎭", text = "Activities" },
}

for _, info in ipairs(navItems) do
	local btn = Instance.new("TextButton")
	btn.BackgroundTransparency = 1
	btn.AutoButtonColor = false
	btn.Size = UDim2.new(0, 70, 0, 60)
	btn.Parent = navBar
	
	local v = Instance.new("UIListLayout")
	v.FillDirection = Enum.FillDirection.Vertical
	v.HorizontalAlignment = Enum.HorizontalAlignment.Center
	v.VerticalAlignment   = Enum.VerticalAlignment.Center
	v.Padding = UDim.new(0, 2)
	v.Parent = btn
	
	local icon = Instance.new("TextLabel")
	icon.BackgroundTransparency = 1
	icon.Size = UDim2.new(1, 0, 0, 24)
	icon.Font = FONTS.BODY
	icon.TextSize = 20
	icon.TextColor3 = Color3.new(1, 1, 1)
	icon.Text = info.icon
	icon.Parent = btn
	
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 0, 16)
	label.Font = FONTS.BODY
	label.TextSize = 10
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Text = info.text
	label.Parent = btn
end

-- Big green Age button (overlaps nav bar)
local ageButton = Instance.new("TextButton")
ageButton.Name = "AgeButton"
ageButton.AnchorPoint = Vector2.new(0.5, 1)
ageButton.Position = UDim2.new(0.5, 0, 0, -8)
ageButton.Size = UDim2.new(0, 120, 0, 120)
ageButton.BackgroundColor3 = COLORS.GREEN_AGE
ageButton.AutoButtonColor = false
ageButton.Text = ""
ageButton.ZIndex = 2
ageButton.Parent = bottom
createUICorner(ageButton, 60)

-- White outer ring
local ageRing = Instance.new("UIStroke")
ageRing.Thickness = 4
ageRing.Transparency = 0
ageRing.Color = Color3.new(1, 1, 1)
ageRing.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ageRing.Parent = ageButton

-- Plus sign
local agePlus = Instance.new("TextLabel")
agePlus.BackgroundTransparency = 1
agePlus.Size = UDim2.new(1, 0, 0, 50)
agePlus.Position = UDim2.new(0, 0, 0, 20)
agePlus.Font = FONTS.TITLE
agePlus.TextSize = 42
agePlus.TextColor3 = Color3.new(1, 1, 1)
agePlus.Text = "+"
agePlus.Parent = ageButton

-- "Age" text
local ageText = Instance.new("TextLabel")
ageText.BackgroundTransparency = 1
ageText.Size = UDim2.new(1, 0, 0, 28)
ageText.Position = UDim2.new(0, 0, 0, 68)
ageText.Font = FONTS.BUTTON
ageText.TextSize = 18
ageText.TextColor3 = Color3.new(1, 1, 1)
ageText.Text = "Age"
ageText.Parent = ageButton

-- Age button highlight ring (for tutorial - red circle)
local ageHighlight = Instance.new("Frame")
ageHighlight.Name = "AgeHighlight"
ageHighlight.BackgroundTransparency = 1
ageHighlight.Size = UDim2.new(1.3, 0, 1.3, 0)
ageHighlight.AnchorPoint = Vector2.new(0.5, 0.5)
ageHighlight.Position = UDim2.new(0.5, 0, 0.5, 0)
ageHighlight.Visible = false
ageHighlight.ZIndex = 1
ageHighlight.Parent = ageButton

local highlightStroke = Instance.new("UIStroke")
highlightStroke.Thickness = 3
highlightStroke.Transparency = 0.2
highlightStroke.Color = Color3.fromRGB(244, 67, 54) -- Red
highlightStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
highlightStroke.Parent = ageHighlight

----------------------------------------------------------------
-- AGE TUTORIAL OVERLAY
----------------------------------------------------------------

local tutorialOverlay = Instance.new("Frame")
tutorialOverlay.Name = "TutorialOverlay"
tutorialOverlay.Size = UDim2.fromScale(1, 1)
tutorialOverlay.BackgroundTransparency = 1
tutorialOverlay.Visible = false
tutorialOverlay.ZIndex = 10
tutorialOverlay.Parent = screenGui

local tutorialText = Instance.new("TextLabel")
tutorialText.BackgroundTransparency = 1
tutorialText.Size = UDim2.new(0, 400, 0, 100)
tutorialText.AnchorPoint = Vector2.new(0.5, 0.5)
tutorialText.Position = UDim2.new(0.5, 0, 0.3, 0)
tutorialText.Font = FONTS.BODY
tutorialText.TextSize = 18
tutorialText.TextColor3 = COLORS.BRIGHT_YELLOW
tutorialText.TextWrapped = true
tutorialText.TextXAlignment = Enum.TextXAlignment.Center
tutorialText.Text = "Press Age to grow older one year at a time.\nMake choices as you go.\nLive your best (or worst) life."
tutorialText.Parent = tutorialOverlay

-- Pointing hand emoji above Age button
local pointingHand = Instance.new("TextLabel")
pointingHand.BackgroundTransparency = 1
pointingHand.Size = UDim2.new(0, 40, 0, 40)
pointingHand.AnchorPoint = Vector2.new(0.5, 1)
pointingHand.Position = UDim2.new(0.5, 0, 0.75, 0)
pointingHand.Font = FONTS.BODY
pointingHand.TextSize = 32
pointingHand.Text = "👉"
pointingHand.Parent = tutorialOverlay

----------------------------------------------------------------
-- RELATIONSHIP EVENT MODAL (BitLife "Unfriended" style)
----------------------------------------------------------------

local eventOverlay = Instance.new("Frame")
eventOverlay.Name = "EventOverlay"
eventOverlay.Size = UDim2.fromScale(1, 1)
eventOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
eventOverlay.BackgroundTransparency = 0.5
eventOverlay.Visible = false
eventOverlay.ZIndex = 20
eventOverlay.Parent = screenGui

-- Blur effect
local eventBlur = createBlur(eventOverlay, 24)

-- Tall white card
local eventCard = Instance.new("Frame")
eventCard.AnchorPoint = Vector2.new(0.5, 0.5)
eventCard.Position = UDim2.fromScale(0.5, 0.5)
eventCard.Size = UDim2.new(0, 380, 0, 520)
eventCard.BackgroundColor3 = COLORS.WHITE_CARD
eventCard.Parent = eventOverlay
createUICorner(eventCard, 20)

-- Drop shadow effect (using multiple strokes)
local shadow1 = createUIStroke(eventCard, 2, 0.7, Color3.new(0, 0, 0))
local shadow2 = Instance.new("UIStroke")
shadow2.Thickness = 1
shadow2.Transparency = 0.5
shadow2.Color = COLORS.RED_ORANGE
shadow2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
shadow2.Parent = eventCard

-- Header strip (top 15-20% with red banner)
local eventHeader = Instance.new("Frame")
eventHeader.BackgroundColor3 = COLORS.WHITE_CARD
eventHeader.Size = UDim2.new(1, 0, 0, 100)
eventHeader.Parent = eventCard
createUICorner(eventHeader, 20)
eventHeader.ClipsDescendants = true

-- Red/orange banner pill on right
local bannerPill = Instance.new("Frame")
bannerPill.BackgroundColor3 = COLORS.RED_ORANGE
bannerPill.Size = UDim2.new(0, 140, 0, 40)
bannerPill.AnchorPoint = Vector2.new(1, 0.5)
bannerPill.Position = UDim2.new(1, 0, 0.5, 0)
bannerPill.Parent = eventHeader
createUICorner(bannerPill, 20)

local bannerText = Instance.new("TextLabel")
bannerText.BackgroundTransparency = 1
bannerText.Size = UDim2.fromScale(1, 1)
bannerText.Font = FONTS.BUTTON
bannerText.TextSize = 14
bannerText.TextColor3 = Color3.new(1, 1, 1)
bannerText.Text = "Best Friend"
bannerText.Parent = bannerPill

-- Avatar circle (left side)
local eventAvatar = Instance.new("Frame")
eventAvatar.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
eventAvatar.Size = UDim2.new(0, 50, 0, 50)
eventAvatar.Position = UDim2.new(0, 20, 0, 25)
eventAvatar.Parent = eventHeader
createUICorner(eventAvatar, 25)
createUIStroke(eventAvatar, 2, 0.3, Color3.fromRGB(200, 200, 200))

local eventAvatarEmoji = Instance.new("TextLabel")
eventAvatarEmoji.BackgroundTransparency = 1
eventAvatarEmoji.Size = UDim2.fromScale(1, 1)
eventAvatarEmoji.Font = FONTS.BODY
eventAvatarEmoji.TextSize = 28
eventAvatarEmoji.Text = "👤"
eventAvatarEmoji.Parent = eventAvatar

-- Name text (left of banner)
local eventName = Instance.new("TextLabel")
eventName.BackgroundTransparency = 1
eventName.Size = UDim2.new(1, -160, 0, 50)
eventName.Position = UDim2.new(0, 80, 0, 25)
eventName.Font = FONTS.TITLE
eventName.TextSize = 20
eventName.TextXAlignment = Enum.TextXAlignment.Left
eventName.TextColor3 = Color3.fromRGB(20, 20, 20)
eventName.Text = "Bradley Allen"
eventName.Parent = eventHeader

-- Emoji + Title (centered below header)
local eventEmoji = Instance.new("TextLabel")
eventEmoji.BackgroundTransparency = 1
eventEmoji.Size = UDim2.new(1, 0, 0, 50)
eventEmoji.Position = UDim2.new(0, 0, 0, 110)
eventEmoji.Font = FONTS.BODY
eventEmoji.TextSize = 40
eventEmoji.TextColor3 = Color3.fromRGB(50, 50, 50)
eventEmoji.Text = "🙂"
eventEmoji.Parent = eventCard

local eventTitle = Instance.new("TextLabel")
eventTitle.BackgroundTransparency = 1
eventTitle.Size = UDim2.new(1, 0, 0, 40)
eventTitle.Position = UDim2.new(0, 0, 0, 160)
eventTitle.Font = FONTS.TITLE
eventTitle.TextSize = 24
eventTitle.TextColor3 = Color3.fromRGB(20, 20, 20)
eventTitle.Text = "Unfriended"
eventTitle.Parent = eventCard

-- Description text (centered, multiline)
local eventBody = Instance.new("TextLabel")
eventBody.BackgroundTransparency = 1
eventBody.Size = UDim2.new(1, -40, 0, 80)
eventBody.Position = UDim2.new(0, 20, 0, 210)
eventBody.Font = FONTS.BODY
eventBody.TextSize = 16
eventBody.TextWrapped = true
eventBody.TextXAlignment = Enum.TextXAlignment.Center
eventBody.TextYAlignment = Enum.TextYAlignment.Top
eventBody.TextColor3 = Color3.fromRGB(60, 60, 60)
eventBody.Text = "Your best friend, Bradley, has unfriended you.\nWhat will you do?"
eventBody.Parent = eventCard

-- Choices holder
local choicesHolder = Instance.new("Frame")
choicesHolder.BackgroundTransparency = 1
choicesHolder.Size = UDim2.new(1, -40, 0, 200)
choicesHolder.Position = UDim2.new(0, 20, 0, 300)
choicesHolder.Parent = eventCard

local choicesLayout = Instance.new("UIListLayout")
choicesLayout.FillDirection = Enum.FillDirection.Vertical
choicesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
choicesLayout.VerticalAlignment   = Enum.VerticalAlignment.Top
choicesLayout.Padding = UDim.new(0, 12)
choicesLayout.Parent = choicesHolder

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
	
	-- Handle "unfriended" event specifically
	if payload.id == "unfriended" then
		eventName.Text = "Bradley Allen"
		bannerText.Text = "Best Friend"
		eventEmoji.Text = "🙂"
		eventTitle.Text = "Unfriended"
		eventBody.Text = "Your best friend, Bradley, has unfriended you.\nWhat will you do?"
	else
		-- Generic event
		eventName.Text = currentState and currentState.Name or "Friend"
		bannerText.Text = "Life Event"
		eventEmoji.Text = payload.emoji or "🙂"
		eventTitle.Text = payload.title or "Life Event"
		eventBody.Text = payload.text or ""
	end
	
	clearChoices()
	
	for _, choice in ipairs(payload.choices or {}) do
		local btn = Instance.new("TextButton")
		btn.BackgroundColor3 = COLORS.BITLIFE_BLUE
		btn.AutoButtonColor = false
		btn.Size = UDim2.new(1, 0, 0, 50)
		btn.Font = FONTS.BUTTON
		btn.TextSize = 16
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Text = choice.text
		btn.Parent = choicesHolder
		createUICorner(btn, 24)
		createUIStroke(btn, 1, 0.2, Color3.fromRGB(25, 118, 210))
		
		table.insert(activeChoiceButtons, btn)
		
		btn.MouseEnter:Connect(function()
			btn.BackgroundColor3 = Color3.fromRGB(66, 165, 245)
		end)
		btn.MouseLeave:Connect(function()
			btn.BackgroundColor3 = COLORS.BITLIFE_BLUE
		end)
		
		btn.MouseButton1Click:Connect(function()
			if not awaitingEvent then
				return
			end
			awaitingEvent = false
			
			for _, other in ipairs(activeChoiceButtons) do
				other.Active = false
			end
			
			SubmitChoice:FireServer(payload.id, choice.id)
			eventOverlay.Visible = false
		end)
	end
	
	-- "Surprise me!" button (tiny, grey, at bottom)
	local surpriseBtn = Instance.new("TextButton")
	surpriseBtn.BackgroundTransparency = 1
	surpriseBtn.Size = UDim2.new(1, 0, 0, 30)
	surpriseBtn.Position = UDim2.new(0, 0, 1, -40)
	surpriseBtn.Font = FONTS.BODY
	surpriseBtn.TextSize = 13
	surpriseBtn.TextColor3 = COLORS.DARK_GREY
	surpriseBtn.Text = "Surprise me!"
	surpriseBtn.TextXAlignment = Enum.TextXAlignment.Center
	surpriseBtn.AutoButtonColor = false
	surpriseBtn.Parent = eventCard
	
	local surpriseUnderline = Instance.new("Frame")
	surpriseUnderline.BackgroundColor3 = COLORS.DARK_GREY
	surpriseUnderline.Size = UDim2.new(0, 80, 0, 1)
	surpriseUnderline.AnchorPoint = Vector2.new(0.5, 1)
	surpriseUnderline.Position = UDim2.new(0.5, 0, 1, -2)
	surpriseUnderline.Parent = surpriseBtn
	
	surpriseBtn.MouseButton1Click:Connect(function()
		if not awaitingEvent or #activeChoiceButtons == 0 then
			return
		end
		-- Random choice
		local randomChoice = activeChoiceButtons[math.random(1, #activeChoiceButtons)]
		randomChoice.MouseButton1Click:Fire()
	end)
	
	eventOverlay.Visible = true
end

----------------------------------------------------------------
-- GENDER PICK SCREEN (blurred background)
----------------------------------------------------------------

local genderOverlay = Instance.new("Frame")
genderOverlay.Name = "GenderOverlay"
genderOverlay.Size = UDim2.fromScale(1, 1)
genderOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
genderOverlay.BackgroundTransparency = 0.45
genderOverlay.Visible = false
genderOverlay.ZIndex = 15
genderOverlay.Parent = screenGui

-- Strong blur
local genderBlur = createBlur(genderOverlay, 30)

-- Title text (bright yellow)
local genderTitle = Instance.new("TextLabel")
genderTitle.BackgroundTransparency = 1
genderTitle.Size = UDim2.new(0, 500, 0, 50)
genderTitle.AnchorPoint = Vector2.new(0.5, 0.5)
genderTitle.Position = UDim2.new(0.5, 0, 0.25, 0)
genderTitle.Font = FONTS.TITLE
genderTitle.TextSize = 22
genderTitle.TextColor3 = COLORS.BRIGHT_YELLOW
genderTitle.Text = "Start by picking a gender."
genderTitle.Parent = genderOverlay

-- Gender buttons holder
local genderButtonsHolder = Instance.new("Frame")
genderButtonsHolder.BackgroundTransparency = 1
genderButtonsHolder.Size = UDim2.new(0, 400, 0, 200)
genderButtonsHolder.AnchorPoint = Vector2.new(0.5, 0.5)
genderButtonsHolder.Position = UDim2.new(0.5, 0, 0.6, 0)
genderButtonsHolder.Parent = genderOverlay

local genderButtonsLayout = Instance.new("UIListLayout")
genderButtonsLayout.FillDirection = Enum.FillDirection.Vertical
genderButtonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
genderButtonsLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
genderButtonsLayout.Padding = UDim.new(0, 16)
genderButtonsLayout.Parent = genderButtonsHolder

local selectedGender = nil

local function createGenderButton(text, emoji, color, value)
	local btn = Instance.new("TextButton")
	btn.BackgroundColor3 = color
	btn.AutoButtonColor = false
	btn.Size = UDim2.new(1, 0, 0, 80)
	btn.Font = FONTS.BUTTON
	btn.TextSize = 24
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Text = emoji .. "  " .. text
	btn.Parent = genderButtonsHolder
	createUICorner(btn, 40) -- Full pill
	createUIStroke(btn, 2, 0.2, Color3.new(1, 1, 1))
	
	btn.MouseEnter:Connect(function()
		local glow = Instance.new("UIStroke")
		glow.Thickness = 3
		glow.Transparency = 0
		glow.Color = Color3.new(1, 1, 1)
		glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		glow.Parent = btn
	end)
	
	btn.MouseLeave:Connect(function()
		for _, child in ipairs(btn:GetChildren()) do
			if child:IsA("UIStroke") and child.Thickness == 3 then
				child:Destroy()
			end
		end
	end)
	
	return btn
end

local maleBtn   = createGenderButton("Male",   "♂", COLORS.BLUE_MALE, "Male")
local femaleBtn = createGenderButton("Female", "♀", COLORS.PINK_FEMALE, "Female")

----------------------------------------------------------------
-- NAME PICK SCREEN (3 colored pills)
----------------------------------------------------------------

local nameOverlay = Instance.new("Frame")
nameOverlay.Name = "NameOverlay"
nameOverlay.Size = UDim2.fromScale(1, 1)
nameOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
nameOverlay.BackgroundTransparency = 0.45
nameOverlay.Visible = false
nameOverlay.ZIndex = 16
nameOverlay.Parent = screenGui

-- Strong blur
local nameBlur = createBlur(nameOverlay, 30)

-- Title (bright yellow)
local nameTitle = Instance.new("TextLabel")
nameTitle.BackgroundTransparency = 1
nameTitle.Size = UDim2.new(0, 500, 0, 50)
nameTitle.AnchorPoint = Vector2.new(0.5, 0.5)
nameTitle.Position = UDim2.new(0.5, 0, 0.25, 0)
nameTitle.Font = FONTS.TITLE
nameTitle.TextSize = 22
nameTitle.TextColor3 = COLORS.BRIGHT_YELLOW
nameTitle.Text = "Now, pick someone to become."
nameTitle.Parent = nameOverlay

-- Names holder
local namesHolder = Instance.new("Frame")
namesHolder.BackgroundTransparency = 1
namesHolder.Size = UDim2.new(0, 400, 0, 200)
namesHolder.AnchorPoint = Vector2.new(0.5, 0.5)
namesHolder.Position = UDim2.new(0.5, 0, 0.6, 0)
namesHolder.Parent = nameOverlay

local namesLayout = Instance.new("UIListLayout")
namesLayout.FillDirection = Enum.FillDirection.Vertical
namesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
namesLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
namesLayout.Padding = UDim.new(0, 12)
namesLayout.Parent = namesHolder

local nameButtons = {}
local selectedName = nil

local maleFirst = {
	"Anthony", "Scott", "Logan", "Ethan", "Noah", "Liam", "Mason", "Jayden", "Caleb", "Damian",
	"Ionut", "Bradley", "Michael", "David", "James", "Robert", "John", "William", "Richard", "Joseph",
}
local femaleFirst = {
	"Olivia", "Emma", "Ava", "Sophia", "Mia", "Amelia", "Isabella", "Charlotte", "Luna", "Stella",
	"Emily", "Harper", "Evelyn", "Abigail", "Elizabeth", "Sofia", "Avery", "Ella", "Madison", "Scarlett",
}
local lastNames = {
	"Russell", "Allen", "Flores", "Cooper", "Parker", "Reed", "Mitchell", "Walker", "Gray", "Brooks",
	"Smelley", "Florea", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez",
}

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
	if not selectedGender then
		return
	end
	
	local firstList = (selectedGender == "Female") and femaleFirst or maleFirst
	local colors = { COLORS.GREEN_NAME, COLORS.YELLOW_NAME, COLORS.ORANGE_NAME }
	local emojis = { "👨", "👨‍🦰", "👨‍🦱" }
	if selectedGender == "Female" then
		emojis = { "👩", "👩‍🦰", "👩‍🦱" }
	end
	
	for i = 1, 3 do
		local fullName = randomFrom(firstList) .. " " .. randomFrom(lastNames)
		
		local btn = Instance.new("TextButton")
		btn.AutoButtonColor = false
		btn.Size = UDim2.new(1, 0, 0, 60)
		btn.Font = FONTS.BUTTON
		btn.TextSize = 20
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.BackgroundColor3 = colors[i]
		btn.Text = emojis[i] .. "  " .. fullName
		btn.Parent = namesHolder
		createUICorner(btn, 30)
		createUIStroke(btn, 1, 0.3, Color3.new(1, 1, 1))
		
		table.insert(nameButtons, btn)
		
		btn.MouseButton1Click:Connect(function()
			selectedName = fullName
			SetLifeInfo:FireServer(selectedName, selectedGender)
			nameOverlay.Visible = false
			-- Show tutorial after name is set
			task.wait(0.5)
			if not hasShownAgeHint then
				tutorialOverlay.Visible = true
				ageHighlight.Visible = true
				hasShownAgeHint = true
				-- Hide after 5 seconds
				task.delay(5, function()
					tutorialOverlay.Visible = false
					ageHighlight.Visible = false
				end)
			end
		end)
	end
end

-- Hook gender buttons
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
-- STATE SYNC / UPDATE
----------------------------------------------------------------

local function updateFromState()
	if not currentState then
		return
	end
	
	local stats = currentState.Stats or {}
	
	-- Update stats with Boost button visibility
	for key, card in pairs(statCards) do
		local v = math.floor(stats[key] or 0)
		card.valueLabel.Text = tostring(v) .. "%"
		local pct = math.clamp(v / 100, 0, 1)
		
		-- Animate bar fill
		card.barFill:TweenSize(
			UDim2.new(pct, 0, 1, 0),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Quad,
			0.2,
			true
		)
		
		-- Color based on value
		if v < 30 then
			card.barFill.BackgroundColor3 = COLORS.STAT_FILL_BAD
		else
			card.barFill.BackgroundColor3 = COLORS.STAT_FILL_GOOD
		end
		
		-- Show Boost button if stat is very low
		if v <= 10 then
			card.boostBtn.Visible = true
		else
			card.boostBtn.Visible = false
		end
	end
	
	-- Update header
	local displayName = currentState.Name or "New Life"
	nameLabel.Text = displayName
	
	-- Update avatar emoji based on age/gender
	local age = currentState.Age or 0
	local gender = currentState.Gender or "Unknown"
	if age < 2 then
		avatarEmoji.Text = "👶"
	elseif age < 13 then
		avatarEmoji.Text = gender == "Female" and "👧" or "👦"
	elseif age < 18 then
		avatarEmoji.Text = gender == "Female" and "👩" or "👨"
	else
		avatarEmoji.Text = gender == "Female" and "👩" or "👨"
	end
	
	local money = currentState.Money or 0
	moneyChip.Text = "$" .. tostring(money)
	
	-- Show intro overlays if name not set
	if not currentState.Name then
		ageButton.Visible = false
		tutorialOverlay.Visible = false
		ageHighlight.Visible = false
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
		addFeedEntry(lastFeedText, state.Age)
	end
end)

PresentEvent.OnClientEvent:Connect(function(eventData, ageFeedText)
	if ageFeedText then
		addFeedEntry(ageFeedText, currentState and currentState.Age or 0)
	end
	showEvent(eventData)
end)

----------------------------------------------------------------
-- INPUT
----------------------------------------------------------------

local function pulseAgeButton()
	local ti = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	tween(ageButton, ti, { Size = UDim2.new(0, 128, 0, 128) }).Completed:Wait()
	tween(ageButton, ti, { Size = UDim2.new(0, 120, 0, 120) })
end

ageButton.MouseButton1Click:Connect(function()
	if awaitingEvent then
		return
	end
	if currentState and not currentState.Name then
		return
	end
	
	pulseAgeButton()
	tutorialOverlay.Visible = false
	ageHighlight.Visible = false
	RequestAgeUp:FireServer()
end)
