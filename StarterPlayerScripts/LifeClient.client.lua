-- StarterPlayerScripts / LifeClient (LocalScript)
-- BitLife-style UI: Complete recreation with blur overlays, gender + name intro,
-- life feed, stats, age button, event popups with relationship headers.
-- Now with full Occupation, Assets, Relationships, Activities screens.

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local player = Players.LocalPlayer

----------------------------------------------------------------
-- SCREEN MODULES (with error handling and debug logging)
----------------------------------------------------------------

local ScreensFolder = ReplicatedStorage:WaitForChild("Screens", 10)

local OccupationScreen = nil
local AssetsScreen = nil
local RelationshipsScreen = nil
local ActivitiesScreen = nil

if ScreensFolder then
	print("[LifeClient] Found Screens folder, loading modules...")
	
	local success1, result1 = pcall(function()
		return require(ScreensFolder:WaitForChild("OccupationScreen", 5))
	end)
	if success1 then 
		OccupationScreen = result1 
		print("[LifeClient] ✅ OccupationScreen loaded")
	else
		warn("[LifeClient] ❌ OccupationScreen failed:", result1)
	end
	
	local success2, result2 = pcall(function()
		return require(ScreensFolder:WaitForChild("AssetsScreen", 5))
	end)
	if success2 then 
		AssetsScreen = result2 
		print("[LifeClient] ✅ AssetsScreen loaded")
	else
		warn("[LifeClient] ❌ AssetsScreen failed:", result2)
	end
	
	local success3, result3 = pcall(function()
		return require(ScreensFolder:WaitForChild("RelationshipsScreen", 5))
	end)
	if success3 then 
		RelationshipsScreen = result3 
		print("[LifeClient] ✅ RelationshipsScreen loaded")
	else
		warn("[LifeClient] ❌ RelationshipsScreen failed:", result3)
	end
	
	local success4, result4 = pcall(function()
		return require(ScreensFolder:WaitForChild("ActivitiesScreen", 5))
	end)
	if success4 then 
		ActivitiesScreen = result4 
		print("[LifeClient] ✅ ActivitiesScreen loaded")
	else
		warn("[LifeClient] ❌ ActivitiesScreen failed:", result4)
	end
else
	warn("[LifeClient] ❌ Could not find Screens folder in ReplicatedStorage!")
end

----------------------------------------------------------------
-- REMOTES
----------------------------------------------------------------

local remotesFolder = ReplicatedStorage:WaitForChild("LifeRemotes", 10)
if not remotesFolder then
	remotesFolder = ReplicatedStorage:WaitForChild("Life", 10)
end

local RequestAgeUp    = remotesFolder:WaitForChild("RequestAgeUp")
local PresentEvent    = remotesFolder:WaitForChild("PresentEvent")
local SubmitChoice    = remotesFolder:WaitForChild("SubmitChoice")
local SyncState       = remotesFolder:WaitForChild("SyncState")
local SetLifeInfo     = remotesFolder:WaitForChild("SetLifeInfo")

----------------------------------------------------------------
-- STATE (shared with screen modules)
----------------------------------------------------------------

-- This state table is passed to all screen modules so they can check age/money
local currentState = {
	Name = nil,
	Age = 0,
	Money = 0,
	Happiness = 50,
	Health = 100,
	Smarts = 50,
	Looks = 50,
	Education = "None",
	Experience = 0,
	CurrentJob = nil,
	InJail = false,
}

local awaitingEvent     = false
local hasShownAgeHint   = false
local introComplete     = false
local selectedGender    = nil

-- Screen instances
local occupationScreenInstance = nil
local assetsScreenInstance = nil
local relationshipsScreenInstance = nil
local activitiesScreenInstance = nil

----------------------------------------------------------------
-- COLORS (BitLife Palette)
----------------------------------------------------------------

local Colors = {
	-- Primary
	BitLifeBlue      = Color3.fromRGB(37, 99, 235),
	BitLifeBlueDark  = Color3.fromRGB(29, 78, 216),
	BitLifeBlueLight = Color3.fromRGB(59, 130, 246),
	
	-- Age Button Green
	AgeGreen         = Color3.fromRGB(34, 197, 94),
	AgeGreenDark     = Color3.fromRGB(22, 163, 74),
	AgeGreenRing     = Color3.fromRGB(21, 128, 61),
	
	-- Event/Relationship Red-Orange
	RelationshipRed  = Color3.fromRGB(239, 68, 68),
	RelationshipRedDark = Color3.fromRGB(220, 38, 38),
	BestFriendOrange = Color3.fromRGB(249, 115, 22),
	
	-- Gender
	MaleBlue         = Color3.fromRGB(56, 189, 248),
	FemalePink       = Color3.fromRGB(244, 114, 182),
	
	-- Name Pills
	NameGreen        = Color3.fromRGB(34, 197, 94),
	NameYellow       = Color3.fromRGB(234, 179, 8),
	NameOrange       = Color3.fromRGB(249, 115, 22),
	
	-- Money
	MoneyGreen       = Color3.fromRGB(22, 163, 74),
	
	-- Boost
	BoostOrange      = Color3.fromRGB(251, 146, 60),
	
	-- Tutorial Yellow
	TutorialYellow   = Color3.fromRGB(253, 224, 71),
	
	-- UI Elements
	White            = Color3.fromRGB(255, 255, 255),
	CardWhite        = Color3.fromRGB(255, 255, 255),
	LightGray        = Color3.fromRGB(243, 244, 246),
	MediumGray       = Color3.fromRGB(156, 163, 175),
	DarkGray         = Color3.fromRGB(75, 85, 99),
	DarkerGray       = Color3.fromRGB(55, 65, 81),
	TextDark         = Color3.fromRGB(31, 41, 55),
	TextBlack        = Color3.fromRGB(17, 24, 39),
	
	-- Stat Bar Colors
	StatGreen        = Color3.fromRGB(34, 197, 94),
	StatRed          = Color3.fromRGB(239, 68, 68),
	StatBarBg        = Color3.fromRGB(229, 231, 235),
	
	-- Nav Bar
	NavBarBlue       = Color3.fromRGB(30, 58, 138),
	NavBarDark       = Color3.fromRGB(23, 37, 84),
	
	-- Overlay
	OverlayBlack     = Color3.fromRGB(0, 0, 0),
}

----------------------------------------------------------------
-- FONTS
----------------------------------------------------------------

local Fonts = {
	Title = Enum.Font.GothamBold,
	TitleAlt = Enum.Font.FredokaOne,
	Body = Enum.Font.Gotham,
	BodyMedium = Enum.Font.GothamMedium,
	Button = Enum.Font.GothamBold,
	Chip = Enum.Font.GothamMedium,
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

local function createPillCorner(parent)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0.5, 0)
	c.Parent = parent
	return c
end

local function createUIStroke(parent, thickness, transparency, color)
	local s = Instance.new("UIStroke")
	s.Thickness = thickness
	s.Transparency = transparency or 0
	s.Color = color or Colors.White
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function createUIPadding(parent, left, right, top, bottom)
	local p = Instance.new("UIPadding")
	p.PaddingLeft = UDim.new(0, left or 0)
	p.PaddingRight = UDim.new(0, right or 0)
	p.PaddingTop = UDim.new(0, top or 0)
	p.PaddingBottom = UDim.new(0, bottom or 0)
	p.Parent = parent
	return p
end

local function tween(obj, info, props)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

local function formatMoney(amount)
	if amount >= 1000000000 then
		return string.format("$%.1fB", amount / 1000000000)
	elseif amount >= 1000000 then
		return string.format("$%.1fM", amount / 1000000)
	elseif amount >= 1000 then
		return string.format("$%.1fK", amount / 1000)
	else
		return "$" .. tostring(amount)
	end
end

----------------------------------------------------------------
-- ROOT GUI
----------------------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LifeGui"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

----------------------------------------------------------------
-- MAIN GAME BACKGROUND
----------------------------------------------------------------

local gameBackground = Instance.new("Frame")
gameBackground.Name = "GameBackground"
gameBackground.Size = UDim2.fromScale(1, 1)
gameBackground.BackgroundColor3 = Color3.fromRGB(240, 242, 245)
gameBackground.ZIndex = 1
gameBackground.Parent = screenGui

local bgGradient = Instance.new("UIGradient")
bgGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(248, 250, 252)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(241, 245, 249)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(248, 250, 252)),
})
bgGradient.Rotation = 180
bgGradient.Parent = gameBackground

----------------------------------------------------------------
-- BLUR OVERLAY (Used when modals are open)
----------------------------------------------------------------

local blurOverlay = Instance.new("Frame")
blurOverlay.Name = "BlurOverlay"
blurOverlay.Size = UDim2.fromScale(1, 1)
blurOverlay.BackgroundColor3 = Colors.OverlayBlack
blurOverlay.BackgroundTransparency = 1
blurOverlay.ZIndex = 50
blurOverlay.Visible = false
blurOverlay.Parent = screenGui

local function showBlur(darkOverlay)
	blurOverlay.Visible = true
	blurOverlay.BackgroundTransparency = 1
	local targetTransparency = darkOverlay and 0.5 or 0.4
	tween(blurOverlay, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = targetTransparency
	})
end

local function hideBlur()
	tween(blurOverlay, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1
	}).Completed:Connect(function()
		blurOverlay.Visible = false
	end)
end

----------------------------------------------------------------
-- MAIN GAME CONTAINER
----------------------------------------------------------------

local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.Size = UDim2.fromScale(1, 1)
mainContainer.BackgroundTransparency = 1
mainContainer.ZIndex = 2
mainContainer.Parent = gameBackground

----------------------------------------------------------------
-- HEADER BAR
----------------------------------------------------------------

local headerBar = Instance.new("Frame")
headerBar.Name = "HeaderBar"
headerBar.Size = UDim2.new(1, 0, 0, 72)
headerBar.Position = UDim2.new(0, 0, 0, 0)
headerBar.BackgroundColor3 = Colors.White
headerBar.BorderSizePixel = 0
headerBar.ZIndex = 10
headerBar.Parent = mainContainer

local headerBorder = Instance.new("Frame")
headerBorder.Size = UDim2.new(1, 0, 0, 1)
headerBorder.Position = UDim2.new(0, 0, 1, 0)
headerBorder.BackgroundColor3 = Color3.fromRGB(229, 231, 235)
headerBorder.BorderSizePixel = 0
headerBorder.Parent = headerBar

local headerPadding = createUIPadding(headerBar, 16, 16, 12, 12)

-- Avatar circle
local avatarCircle = Instance.new("Frame")
avatarCircle.Name = "Avatar"
avatarCircle.Size = UDim2.new(0, 48, 0, 48)
avatarCircle.Position = UDim2.new(0, 0, 0.5, -24)
avatarCircle.BackgroundColor3 = Color3.fromRGB(219, 234, 254)
avatarCircle.Parent = headerBar
createUICorner(avatarCircle, 24)
createUIStroke(avatarCircle, 2, 0, Color3.fromRGB(147, 197, 253))

local avatarEmoji = Instance.new("TextLabel")
avatarEmoji.Name = "Emoji"
avatarEmoji.Size = UDim2.fromScale(1, 1)
avatarEmoji.BackgroundTransparency = 1
avatarEmoji.Font = Fonts.Body
avatarEmoji.TextSize = 28
avatarEmoji.Text = "👶"
avatarEmoji.Parent = avatarCircle

-- Name container
local nameContainer = Instance.new("Frame")
nameContainer.Name = "NameContainer"
nameContainer.Size = UDim2.new(0.5, -80, 1, 0)
nameContainer.Position = UDim2.new(0, 60, 0, 0)
nameContainer.BackgroundTransparency = 1
nameContainer.Parent = headerBar

local nameLabel = Instance.new("TextLabel")
nameLabel.Name = "NameLabel"
nameLabel.Size = UDim2.new(1, 0, 0, 24)
nameLabel.Position = UDim2.new(0, 0, 0.5, -16)
nameLabel.BackgroundTransparency = 1
nameLabel.Font = Fonts.Title
nameLabel.TextSize = 18
nameLabel.TextColor3 = Colors.TextBlack
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.Text = "New Life"
nameLabel.Parent = nameContainer

local ageYearLabel = Instance.new("TextLabel")
ageYearLabel.Name = "AgeYear"
ageYearLabel.Size = UDim2.new(1, 0, 0, 18)
ageYearLabel.Position = UDim2.new(0, 0, 0.5, 6)
ageYearLabel.BackgroundTransparency = 1
ageYearLabel.Font = Fonts.Body
ageYearLabel.TextSize = 13
ageYearLabel.TextColor3 = Colors.MediumGray
ageYearLabel.TextXAlignment = Enum.TextXAlignment.Left
ageYearLabel.Text = "Age 0 • Year 2025"
ageYearLabel.Parent = nameContainer

-- Money chip
local moneyChip = Instance.new("Frame")
moneyChip.Name = "MoneyChip"
moneyChip.Size = UDim2.new(0, 100, 0, 36)
moneyChip.AnchorPoint = Vector2.new(1, 0.5)
moneyChip.Position = UDim2.new(1, 0, 0.5, 0)
moneyChip.BackgroundColor3 = Colors.BitLifeBlue
moneyChip.Parent = headerBar
createPillCorner(moneyChip)

local moneyLabel = Instance.new("TextLabel")
moneyLabel.Name = "MoneyLabel"
moneyLabel.Size = UDim2.fromScale(1, 1)
moneyLabel.BackgroundTransparency = 1
moneyLabel.Font = Fonts.Button
moneyLabel.TextSize = 16
moneyLabel.TextColor3 = Colors.White
moneyLabel.Text = "$0"
moneyLabel.Parent = moneyChip

----------------------------------------------------------------
-- LIFE FEED AREA
----------------------------------------------------------------

local feedContainer = Instance.new("Frame")
feedContainer.Name = "FeedContainer"
feedContainer.Size = UDim2.new(1, 0, 1, -260)
feedContainer.Position = UDim2.new(0, 0, 0, 72)
feedContainer.BackgroundColor3 = Colors.White
feedContainer.BorderSizePixel = 0
feedContainer.ZIndex = 3
feedContainer.Parent = mainContainer

local feedPadding = createUIPadding(feedContainer, 16, 16, 12, 12)

local feedScroll = Instance.new("ScrollingFrame")
feedScroll.Name = "FeedScroll"
feedScroll.Size = UDim2.fromScale(1, 1)
feedScroll.BackgroundTransparency = 1
feedScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
feedScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
feedScroll.ScrollBarThickness = 4
feedScroll.ScrollBarImageColor3 = Colors.MediumGray
feedScroll.BorderSizePixel = 0
feedScroll.Parent = feedContainer

local feedLayout = Instance.new("UIListLayout")
feedLayout.FillDirection = Enum.FillDirection.Vertical
feedLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
feedLayout.VerticalAlignment = Enum.VerticalAlignment.Top
feedLayout.Padding = UDim.new(0, 8)
feedLayout.SortOrder = Enum.SortOrder.LayoutOrder
feedLayout.Parent = feedScroll

local feedEntryCount = 0

local function addFeedEntry(text)
	if not text or text == "" then return end
	
	feedEntryCount = feedEntryCount + 1
	
	local entryFrame = Instance.new("Frame")
	entryFrame.Name = "Entry_" .. feedEntryCount
	entryFrame.Size = UDim2.new(1, 0, 0, 0)
	entryFrame.AutomaticSize = Enum.AutomaticSize.Y
	entryFrame.BackgroundColor3 = Colors.LightGray
	entryFrame.LayoutOrder = feedEntryCount
	entryFrame.Parent = feedScroll
	createUICorner(entryFrame, 12)
	
	createUIPadding(entryFrame, 14, 14, 10, 10)
	
	local isAgeLine = text:match("^Age") or text:match("years old")
	
	local entryLabel = Instance.new("TextLabel")
	entryLabel.Size = UDim2.new(1, 0, 0, 0)
	entryLabel.AutomaticSize = Enum.AutomaticSize.Y
	entryLabel.BackgroundTransparency = 1
	entryLabel.Font = isAgeLine and Fonts.Title or Fonts.Body
	entryLabel.TextSize = isAgeLine and 15 or 14
	entryLabel.TextColor3 = isAgeLine and Colors.BitLifeBlue or Colors.DarkerGray
	entryLabel.TextXAlignment = Enum.TextXAlignment.Left
	entryLabel.TextYAlignment = Enum.TextYAlignment.Top
	entryLabel.TextWrapped = true
	entryLabel.Text = text
	entryLabel.Parent = entryFrame
	
	entryFrame.BackgroundTransparency = 1
	entryLabel.TextTransparency = 1
	tween(entryFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0
	})
	tween(entryLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0
	})
	
	task.delay(0.05, function()
		feedScroll.CanvasPosition = Vector2.new(
			0,
			math.max(0, feedScroll.AbsoluteCanvasSize.Y - feedScroll.AbsoluteWindowSize.Y)
		)
	end)
end

----------------------------------------------------------------
-- STATS BAR
----------------------------------------------------------------

local statsBar = Instance.new("Frame")
statsBar.Name = "StatsBar"
statsBar.Size = UDim2.new(1, -24, 0, 90)
statsBar.AnchorPoint = Vector2.new(0.5, 1)
statsBar.Position = UDim2.new(0.5, 0, 1, -100)
statsBar.BackgroundColor3 = Colors.White
statsBar.ZIndex = 8
statsBar.Parent = mainContainer
createUICorner(statsBar, 20)
createUIStroke(statsBar, 1, 0.8, Color3.fromRGB(229, 231, 235))

local statsPadding = createUIPadding(statsBar, 12, 12, 8, 8)

local statsLayout = Instance.new("UIListLayout")
statsLayout.FillDirection = Enum.FillDirection.Vertical
statsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
statsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
statsLayout.Padding = UDim.new(0, 4)
statsLayout.Parent = statsBar

local statMeta = {
	{ key = "Happiness", icon = "😀", label = "Happiness", color = Colors.StatGreen },
	{ key = "Health",    icon = "❤️", label = "Health",    color = Color3.fromRGB(239, 68, 68) },
	{ key = "Smarts",    icon = "🧠", label = "Smarts",    color = Color3.fromRGB(168, 85, 247) },
	{ key = "Looks",     icon = "💄", label = "Looks",     color = Color3.fromRGB(236, 72, 153) },
}

local statCards = {}

for i, info in ipairs(statMeta) do
	local statRow = Instance.new("Frame")
	statRow.Name = "Stat_" .. info.key
	statRow.Size = UDim2.new(1, 0, 0, 18)
	statRow.BackgroundTransparency = 1
	statRow.LayoutOrder = i
	statRow.Parent = statsBar
	
	local labelText = Instance.new("TextLabel")
	labelText.Size = UDim2.new(0, 90, 1, 0)
	labelText.BackgroundTransparency = 1
	labelText.Font = Fonts.BodyMedium
	labelText.TextSize = 12
	labelText.TextColor3 = Colors.DarkGray
	labelText.TextXAlignment = Enum.TextXAlignment.Left
	labelText.Text = info.icon .. " " .. info.label
	labelText.Parent = statRow
	
	local percentLabel = Instance.new("TextLabel")
	percentLabel.Name = "Percent"
	percentLabel.Size = UDim2.new(0, 40, 1, 0)
	percentLabel.AnchorPoint = Vector2.new(1, 0)
	percentLabel.Position = UDim2.new(1, 0, 0, 0)
	percentLabel.BackgroundTransparency = 1
	percentLabel.Font = Fonts.BodyMedium
	percentLabel.TextSize = 12
	percentLabel.TextColor3 = Colors.MediumGray
	percentLabel.TextXAlignment = Enum.TextXAlignment.Right
	percentLabel.Text = "100%"
	percentLabel.Parent = statRow
	
	local barBg = Instance.new("Frame")
	barBg.Name = "BarBg"
	barBg.Size = UDim2.new(1, -140, 0, 8)
	barBg.Position = UDim2.new(0, 95, 0.5, -4)
	barBg.BackgroundColor3 = Colors.StatBarBg
	barBg.Parent = statRow
	createUICorner(barBg, 4)
	
	local barFill = Instance.new("Frame")
	barFill.Name = "BarFill"
	barFill.Size = UDim2.new(1, 0, 1, 0)
	barFill.BackgroundColor3 = info.color
	barFill.Parent = barBg
	createUICorner(barFill, 4)
	
	local boostBtn = Instance.new("TextButton")
	boostBtn.Name = "BoostBtn"
	boostBtn.Size = UDim2.new(0, 60, 0, 22)
	boostBtn.AnchorPoint = Vector2.new(1, 0.5)
	boostBtn.Position = UDim2.new(1, -45, 0.5, 0)
	boostBtn.BackgroundColor3 = Colors.BoostOrange
	boostBtn.Font = Fonts.Button
	boostBtn.TextSize = 10
	boostBtn.TextColor3 = Colors.White
	boostBtn.Text = "+ Boost!"
	boostBtn.AutoButtonColor = false
	boostBtn.Visible = false
	boostBtn.ZIndex = 10
	boostBtn.Parent = statRow
	createPillCorner(boostBtn)
	
	statCards[info.key] = {
		percentLabel = percentLabel,
		barFill = barFill,
		boostBtn = boostBtn,
		color = info.color,
	}
end

----------------------------------------------------------------
-- NAVIGATION BAR
----------------------------------------------------------------

local navBar = Instance.new("Frame")
navBar.Name = "NavBar"
navBar.Size = UDim2.new(1, 0, 0, 80)
navBar.AnchorPoint = Vector2.new(0.5, 1)
navBar.Position = UDim2.new(0.5, 0, 1, 0)
navBar.BackgroundColor3 = Colors.NavBarBlue
navBar.ZIndex = 6
navBar.Parent = mainContainer

local navGradient = Instance.new("UIGradient")
navGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Colors.NavBarBlue),
	ColorSequenceKeypoint.new(1, Colors.NavBarDark),
})
navGradient.Rotation = 90
navGradient.Parent = navBar

local navPadding = createUIPadding(navBar, 16, 16, 8, 20)

local navLayout = Instance.new("UIListLayout")
navLayout.FillDirection = Enum.FillDirection.Horizontal
navLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
navLayout.VerticalAlignment = Enum.VerticalAlignment.Center
navLayout.Padding = UDim.new(0, 0)
navLayout.Parent = navBar

local navItems = {
	{ icon = "💼", text = "Occupation", screen = "occupation" },
	{ icon = "🏠", text = "Assets", screen = "assets" },
	{ icon = "❤️", text = "Relations", screen = "relationships" },
	{ icon = "🎭", text = "Activities", screen = "activities" },
}

local navItemWidth = 70
local navButtonRefs = {}

for idx, info in ipairs(navItems) do
	if idx == 3 then
		local spacer = Instance.new("Frame")
		spacer.Size = UDim2.new(0, 90, 0, 1)
		spacer.BackgroundTransparency = 1
		spacer.LayoutOrder = idx
		spacer.Parent = navBar
	end
	
	local navBtn = Instance.new("TextButton")
	navBtn.Name = info.text
	navBtn.Size = UDim2.new(0, navItemWidth, 0, 50)
	navBtn.BackgroundTransparency = 1
	navBtn.AutoButtonColor = false
	navBtn.LayoutOrder = idx < 3 and idx or idx + 1
	navBtn.Text = ""
	navBtn.Parent = navBar
	
	local navBtnLayout = Instance.new("UIListLayout")
	navBtnLayout.FillDirection = Enum.FillDirection.Vertical
	navBtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	navBtnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	navBtnLayout.Padding = UDim.new(0, 2)
	navBtnLayout.Parent = navBtn
	
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Name = "Icon"
	iconLabel.Size = UDim2.new(1, 0, 0, 24)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Font = Fonts.Body
	iconLabel.TextSize = 20
	iconLabel.TextColor3 = Colors.White
	iconLabel.Text = info.icon
	iconLabel.Parent = navBtn
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Label"
	textLabel.Size = UDim2.new(1, 0, 0, 14)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Fonts.Body
	textLabel.TextSize = 10
	textLabel.TextColor3 = Color3.fromRGB(148, 163, 184)
	textLabel.Text = info.text
	textLabel.Parent = navBtn
	
	navBtn.MouseEnter:Connect(function()
		iconLabel.TextColor3 = Colors.TutorialYellow
	end)
	navBtn.MouseLeave:Connect(function()
		iconLabel.TextColor3 = Colors.White
	end)
	
	navBtn.MouseButton1Click:Connect(function()
		if info.screen == "occupation" and occupationScreenInstance then
			occupationScreenInstance:show()
		elseif info.screen == "assets" and assetsScreenInstance then
			assetsScreenInstance:show()
		elseif info.screen == "relationships" and relationshipsScreenInstance then
			relationshipsScreenInstance:show()
		elseif info.screen == "activities" and activitiesScreenInstance then
			activitiesScreenInstance:show()
		end
	end)
	
	navButtonRefs[info.screen] = navBtn
end

----------------------------------------------------------------
-- AGE BUTTON
----------------------------------------------------------------

local ageButtonContainer = Instance.new("Frame")
ageButtonContainer.Name = "AgeButtonContainer"
ageButtonContainer.Size = UDim2.new(0, 100, 0, 100)
ageButtonContainer.AnchorPoint = Vector2.new(0.5, 0.5)
ageButtonContainer.Position = UDim2.new(0.5, 0, 1, -80)
ageButtonContainer.BackgroundTransparency = 1
ageButtonContainer.ZIndex = 15
ageButtonContainer.Parent = mainContainer

local ageOuterRing = Instance.new("Frame")
ageOuterRing.Name = "OuterRing"
ageOuterRing.Size = UDim2.new(1, 10, 1, 10)
ageOuterRing.AnchorPoint = Vector2.new(0.5, 0.5)
ageOuterRing.Position = UDim2.fromScale(0.5, 0.5)
ageOuterRing.BackgroundColor3 = Colors.White
ageOuterRing.Parent = ageButtonContainer
createUICorner(ageOuterRing, 55)

local ageButton = Instance.new("TextButton")
ageButton.Name = "AgeButton"
ageButton.Size = UDim2.new(1, -6, 1, -6)
ageButton.AnchorPoint = Vector2.new(0.5, 0.5)
ageButton.Position = UDim2.fromScale(0.5, 0.5)
ageButton.BackgroundColor3 = Colors.AgeGreen
ageButton.AutoButtonColor = false
ageButton.Text = ""
ageButton.ZIndex = 16
ageButton.Parent = ageButtonContainer
createUICorner(ageButton, 50)
createUIStroke(ageButton, 3, 0, Colors.AgeGreenRing)

local ageGradient = Instance.new("UIGradient")
ageGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(74, 222, 128)),
	ColorSequenceKeypoint.new(1, Colors.AgeGreen),
})
ageGradient.Rotation = 90
ageGradient.Parent = ageButton

local agePlus = Instance.new("TextLabel")
agePlus.Name = "Plus"
agePlus.Size = UDim2.new(1, 0, 0, 36)
agePlus.Position = UDim2.new(0, 0, 0, 14)
agePlus.BackgroundTransparency = 1
agePlus.Font = Fonts.Title
agePlus.TextSize = 36
agePlus.TextColor3 = Colors.White
agePlus.Text = "+"
agePlus.ZIndex = 17
agePlus.Parent = ageButton

local ageText = Instance.new("TextLabel")
ageText.Name = "AgeText"
ageText.Size = UDim2.new(1, 0, 0, 22)
ageText.Position = UDim2.new(0, 0, 0, 50)
ageText.BackgroundTransparency = 1
ageText.Font = Fonts.Button
ageText.TextSize = 18
ageText.TextColor3 = Colors.White
ageText.Text = "Age"
ageText.ZIndex = 17
ageText.Parent = ageButton

local tutorialRing = Instance.new("Frame")
tutorialRing.Name = "TutorialRing"
tutorialRing.Size = UDim2.new(1, 30, 1, 30)
tutorialRing.AnchorPoint = Vector2.new(0.5, 0.5)
tutorialRing.Position = UDim2.fromScale(0.5, 0.5)
tutorialRing.BackgroundTransparency = 1
tutorialRing.Visible = false
tutorialRing.ZIndex = 14
tutorialRing.Parent = ageButtonContainer
createUICorner(tutorialRing, 65)
createUIStroke(tutorialRing, 4, 0, Colors.RelationshipRed)

----------------------------------------------------------------
-- AGE TUTORIAL OVERLAY
----------------------------------------------------------------

local tutorialOverlay = Instance.new("Frame")
tutorialOverlay.Name = "TutorialOverlay"
tutorialOverlay.Size = UDim2.fromScale(1, 1)
tutorialOverlay.BackgroundTransparency = 1
tutorialOverlay.Visible = false
tutorialOverlay.ZIndex = 40
tutorialOverlay.Parent = screenGui

local tutorialTextContainer = Instance.new("Frame")
tutorialTextContainer.Size = UDim2.new(0.8, 0, 0, 120)
tutorialTextContainer.AnchorPoint = Vector2.new(0.5, 0.5)
tutorialTextContainer.Position = UDim2.new(0.5, 0, 0.35, 0)
tutorialTextContainer.BackgroundTransparency = 1
tutorialTextContainer.Parent = tutorialOverlay

local tutorialLayout = Instance.new("UIListLayout")
tutorialLayout.FillDirection = Enum.FillDirection.Vertical
tutorialLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tutorialLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tutorialLayout.Padding = UDim.new(0, 8)
tutorialLayout.Parent = tutorialTextContainer

local pointingHand = Instance.new("TextLabel")
pointingHand.Size = UDim2.new(0, 40, 0, 40)
pointingHand.BackgroundTransparency = 1
pointingHand.Font = Fonts.Body
pointingHand.TextSize = 32
pointingHand.Text = "👇"
pointingHand.LayoutOrder = 1
pointingHand.Parent = tutorialTextContainer

local tutorialLines = {
	"Press Age to grow older one year at a time.",
	"Make choices as you go.",
	"Live your best (or worst) life.",
}

for i, line in ipairs(tutorialLines) do
	local lineLabel = Instance.new("TextLabel")
	lineLabel.Size = UDim2.new(1, 0, 0, 24)
	lineLabel.BackgroundTransparency = 1
	lineLabel.Font = Fonts.BodyMedium
	lineLabel.TextSize = 16
	lineLabel.TextColor3 = i == 1 and Colors.TutorialYellow or Colors.White
	lineLabel.Text = line
	lineLabel.LayoutOrder = i + 1
	lineLabel.Parent = tutorialTextContainer
end

local function showTutorial()
	if hasShownAgeHint then return end
	hasShownAgeHint = true
	
	tutorialOverlay.Visible = true
	tutorialRing.Visible = true
	
	local pulseInfo = TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
	local ringStroke = tutorialRing:FindFirstChildOfClass("UIStroke")
	if ringStroke then
		tween(ringStroke, pulseInfo, { Transparency = 0.5 })
	end
end

local function hideTutorial()
	tutorialOverlay.Visible = false
	tutorialRing.Visible = false
end

----------------------------------------------------------------
-- EVENT MODAL (Fixed - no shadow as child causing layout issues)
----------------------------------------------------------------

local eventOverlay = Instance.new("Frame")
eventOverlay.Name = "EventOverlay"
eventOverlay.Size = UDim2.fromScale(1, 1)
eventOverlay.BackgroundColor3 = Colors.OverlayBlack
eventOverlay.BackgroundTransparency = 0.5
eventOverlay.Visible = false
eventOverlay.ZIndex = 60
eventOverlay.Parent = screenGui

local eventCard = Instance.new("Frame")
eventCard.Name = "EventCard"
eventCard.Size = UDim2.new(0, 340, 0, 0)
eventCard.AutomaticSize = Enum.AutomaticSize.Y
eventCard.AnchorPoint = Vector2.new(0.5, 0.5)
eventCard.Position = UDim2.fromScale(0.5, 0.5)
eventCard.BackgroundColor3 = Colors.CardWhite
eventCard.ZIndex = 62
eventCard.Parent = eventOverlay
createUICorner(eventCard, 22)
createUIStroke(eventCard, 2, 0, Colors.RelationshipRed)

-- Event card internal layout
local eventCardLayout = Instance.new("UIListLayout")
eventCardLayout.FillDirection = Enum.FillDirection.Vertical
eventCardLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
eventCardLayout.VerticalAlignment = Enum.VerticalAlignment.Top
eventCardLayout.Padding = UDim.new(0, 0)
eventCardLayout.Parent = eventCard

-- Header section (Avatar + Name + Relationship banner)
local eventHeader = Instance.new("Frame")
eventHeader.Name = "Header"
eventHeader.Size = UDim2.new(1, 0, 0, 70)
eventHeader.BackgroundColor3 = Colors.CardWhite
eventHeader.ClipsDescendants = true
eventHeader.LayoutOrder = 1
eventHeader.Visible = false
eventHeader.Parent = eventCard
createUICorner(eventHeader, 22)

local headerInnerPadding = createUIPadding(eventHeader, 18, 0, 15, 15)

local eventAvatar = Instance.new("Frame")
eventAvatar.Name = "Avatar"
eventAvatar.Size = UDim2.new(0, 44, 0, 44)
eventAvatar.Position = UDim2.new(0, 0, 0.5, -22)
eventAvatar.BackgroundColor3 = Color3.fromRGB(254, 226, 226)
eventAvatar.Parent = eventHeader
createUICorner(eventAvatar, 22)
createUIStroke(eventAvatar, 2, 0, Color3.fromRGB(252, 165, 165))

local eventAvatarEmoji = Instance.new("TextLabel")
eventAvatarEmoji.Size = UDim2.fromScale(1, 1)
eventAvatarEmoji.BackgroundTransparency = 1
eventAvatarEmoji.Font = Fonts.Body
eventAvatarEmoji.TextSize = 24
eventAvatarEmoji.Text = "👤"
eventAvatarEmoji.Parent = eventAvatar

local eventNameLabel = Instance.new("TextLabel")
eventNameLabel.Name = "NameLabel"
eventNameLabel.Size = UDim2.new(0.5, 0, 0, 20)
eventNameLabel.Position = UDim2.new(0, 54, 0.5, -10)
eventNameLabel.BackgroundTransparency = 1
eventNameLabel.Font = Fonts.Title
eventNameLabel.TextSize = 16
eventNameLabel.TextColor3 = Colors.TextBlack
eventNameLabel.TextXAlignment = Enum.TextXAlignment.Left
eventNameLabel.Text = "Bradley Allen"
eventNameLabel.Parent = eventHeader

local relationshipBanner = Instance.new("Frame")
relationshipBanner.Name = "RelationshipBanner"
relationshipBanner.Size = UDim2.new(0, 100, 0, 28)
relationshipBanner.AnchorPoint = Vector2.new(1, 0.5)
relationshipBanner.Position = UDim2.new(1, 22, 0.5, 0)
relationshipBanner.BackgroundColor3 = Colors.BestFriendOrange
relationshipBanner.Parent = eventHeader
createUICorner(relationshipBanner, 14)

local relationshipLabel = Instance.new("TextLabel")
relationshipLabel.Size = UDim2.fromScale(1, 1)
relationshipLabel.BackgroundTransparency = 1
relationshipLabel.Font = Fonts.Button
relationshipLabel.TextSize = 11
relationshipLabel.TextColor3 = Colors.White
relationshipLabel.Text = "Best Friend"
relationshipLabel.Parent = relationshipBanner

-- Title section
local titleSection = Instance.new("Frame")
titleSection.Name = "TitleSection"
titleSection.Size = UDim2.new(1, 0, 0, 90)
titleSection.BackgroundTransparency = 1
titleSection.LayoutOrder = 2
titleSection.Parent = eventCard

local titleLayout = Instance.new("UIListLayout")
titleLayout.FillDirection = Enum.FillDirection.Vertical
titleLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
titleLayout.VerticalAlignment = Enum.VerticalAlignment.Center
titleLayout.Padding = UDim.new(0, 6)
titleLayout.Parent = titleSection

local eventEmoji = Instance.new("TextLabel")
eventEmoji.Name = "Emoji"
eventEmoji.Size = UDim2.new(0, 50, 0, 50)
eventEmoji.BackgroundTransparency = 1
eventEmoji.Font = Fonts.Body
eventEmoji.TextSize = 42
eventEmoji.Text = "🙂"
eventEmoji.LayoutOrder = 1
eventEmoji.Parent = titleSection

local eventTitle = Instance.new("TextLabel")
eventTitle.Name = "Title"
eventTitle.Size = UDim2.new(0.9, 0, 0, 28)
eventTitle.BackgroundTransparency = 1
eventTitle.Font = Fonts.Title
eventTitle.TextSize = 24
eventTitle.TextColor3 = Colors.TextBlack
eventTitle.Text = "Life Event"
eventTitle.LayoutOrder = 2
eventTitle.Parent = titleSection

-- Description section
local descSection = Instance.new("Frame")
descSection.Name = "DescSection"
descSection.Size = UDim2.new(1, 0, 0, 0)
descSection.AutomaticSize = Enum.AutomaticSize.Y
descSection.BackgroundTransparency = 1
descSection.LayoutOrder = 3
descSection.Parent = eventCard

local descPadding = createUIPadding(descSection, 24, 24, 0, 16)

local eventBody = Instance.new("TextLabel")
eventBody.Name = "Body"
eventBody.Size = UDim2.new(1, 0, 0, 0)
eventBody.AutomaticSize = Enum.AutomaticSize.Y
eventBody.BackgroundTransparency = 1
eventBody.Font = Fonts.Body
eventBody.TextSize = 15
eventBody.TextColor3 = Colors.DarkerGray
eventBody.TextWrapped = true
eventBody.TextXAlignment = Enum.TextXAlignment.Center
eventBody.TextYAlignment = Enum.TextYAlignment.Top
eventBody.Text = ""
eventBody.RichText = true
eventBody.LineHeight = 1.3
eventBody.Parent = descSection

-- Choices section
local choicesSection = Instance.new("Frame")
choicesSection.Name = "ChoicesSection"
choicesSection.Size = UDim2.new(1, 0, 0, 0)
choicesSection.AutomaticSize = Enum.AutomaticSize.Y
choicesSection.BackgroundTransparency = 1
choicesSection.LayoutOrder = 4
choicesSection.Parent = eventCard

local choicesPadding = createUIPadding(choicesSection, 20, 20, 8, 20)

local choicesLayout = Instance.new("UIListLayout")
choicesLayout.FillDirection = Enum.FillDirection.Vertical
choicesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
choicesLayout.VerticalAlignment = Enum.VerticalAlignment.Top
choicesLayout.Padding = UDim.new(0, 10)
choicesLayout.Parent = choicesSection

local activeChoiceButtons = {}
local currentEventId = nil

local function clearChoices()
	for _, b in ipairs(activeChoiceButtons) do
		b:Destroy()
	end
	table.clear(activeChoiceButtons)
end

-- Surprise me button
local surpriseMeBtn = Instance.new("TextButton")
surpriseMeBtn.Name = "SurpriseMe"
surpriseMeBtn.Size = UDim2.new(1, 0, 0, 32)
surpriseMeBtn.BackgroundTransparency = 1
surpriseMeBtn.Font = Fonts.Body
surpriseMeBtn.TextSize = 14
surpriseMeBtn.TextColor3 = Colors.MediumGray
surpriseMeBtn.Text = "Surprise me!"
surpriseMeBtn.AutoButtonColor = false
surpriseMeBtn.LayoutOrder = 100
surpriseMeBtn.Parent = choicesSection

local surpriseUnderline = Instance.new("Frame")
surpriseUnderline.Size = UDim2.new(0, 80, 0, 1)
surpriseUnderline.AnchorPoint = Vector2.new(0.5, 0)
surpriseUnderline.Position = UDim2.new(0.5, 0, 1, -6)
surpriseUnderline.BackgroundColor3 = Colors.MediumGray
surpriseUnderline.Parent = surpriseMeBtn

surpriseMeBtn.MouseEnter:Connect(function()
	surpriseMeBtn.TextColor3 = Colors.BitLifeBlue
	surpriseUnderline.BackgroundColor3 = Colors.BitLifeBlue
end)
surpriseMeBtn.MouseLeave:Connect(function()
	surpriseMeBtn.TextColor3 = Colors.MediumGray
	surpriseUnderline.BackgroundColor3 = Colors.MediumGray
end)

local currentPayloadChoices = {}

local function showEvent(payload)
	awaitingEvent = true
	currentEventId = payload.id
	currentPayloadChoices = payload.choices or {}
	
	eventEmoji.Text = payload.emoji or "🙂"
	eventTitle.Text = payload.title or "Life Event"
	eventBody.Text = payload.text or ""
	
	eventHeader.Visible = payload.showRelationship or false
	if payload.relationName then
		eventNameLabel.Text = payload.relationName
	end
	if payload.relationship then
		relationshipLabel.Text = payload.relationship
	end
	
	clearChoices()
	
	for i, choice in ipairs(payload.choices or {}) do
		local btn = Instance.new("TextButton")
		btn.Name = "Choice_" .. (choice.id or i)
		btn.Size = UDim2.new(1, 0, 0, 50)
		btn.BackgroundColor3 = Colors.BitLifeBlue
		btn.AutoButtonColor = false
		btn.Font = Fonts.Button
		btn.TextSize = 15
		btn.TextColor3 = Colors.White
		btn.Text = choice.text
		btn.LayoutOrder = i
		btn.Parent = choicesSection
		createPillCorner(btn)
		createUIStroke(btn, 1, 0.5, Colors.BitLifeBlueDark)
		
		table.insert(activeChoiceButtons, btn)
		
		btn.MouseEnter:Connect(function()
			tween(btn, TweenInfo.new(0.1), { BackgroundColor3 = Colors.BitLifeBlueLight })
		end)
		btn.MouseLeave:Connect(function()
			tween(btn, TweenInfo.new(0.1), { BackgroundColor3 = Colors.BitLifeBlue })
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
	
	eventCard.Position = UDim2.new(0.5, 0, 0.5, 50)
	tween(eventCard, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.5)
	})
end

surpriseMeBtn.MouseButton1Click:Connect(function()
	if not awaitingEvent or #currentPayloadChoices == 0 then return end
	
	local randomChoice = currentPayloadChoices[math.random(1, #currentPayloadChoices)]
	awaitingEvent = false
	
	SubmitChoice:FireServer(currentEventId, randomChoice.id)
	eventOverlay.Visible = false
end)

----------------------------------------------------------------
-- GENDER SELECTION OVERLAY
----------------------------------------------------------------

local genderOverlay = Instance.new("Frame")
genderOverlay.Name = "GenderOverlay"
genderOverlay.Size = UDim2.fromScale(1, 1)
genderOverlay.BackgroundColor3 = Colors.OverlayBlack
genderOverlay.BackgroundTransparency = 0.45
genderOverlay.Visible = false
genderOverlay.ZIndex = 70
genderOverlay.Parent = screenGui

local genderCard = Instance.new("Frame")
genderCard.Name = "GenderCard"
genderCard.Size = UDim2.new(0, 320, 0, 220)
genderCard.AnchorPoint = Vector2.new(0.5, 0.5)
genderCard.Position = UDim2.fromScale(0.5, 0.5)
genderCard.BackgroundTransparency = 1
genderCard.Parent = genderOverlay

local genderTitle = Instance.new("TextLabel")
genderTitle.Size = UDim2.new(1, 0, 0, 40)
genderTitle.Position = UDim2.new(0, 0, 0, 0)
genderTitle.BackgroundTransparency = 1
genderTitle.Font = Fonts.BodyMedium
genderTitle.TextSize = 20
genderTitle.TextColor3 = Colors.TutorialYellow
genderTitle.Text = "Start by picking a gender."
genderTitle.Parent = genderCard

local genderButtons = Instance.new("Frame")
genderButtons.Size = UDim2.new(1, 0, 0, 140)
genderButtons.Position = UDim2.new(0, 0, 0, 60)
genderButtons.BackgroundTransparency = 1
genderButtons.Parent = genderCard

local genderButtonsLayout = Instance.new("UIListLayout")
genderButtonsLayout.FillDirection = Enum.FillDirection.Vertical
genderButtonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
genderButtonsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
genderButtonsLayout.Padding = UDim.new(0, 14)
genderButtonsLayout.Parent = genderButtons

local function createGenderButton(symbol, text, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 56)
	btn.BackgroundColor3 = color
	btn.AutoButtonColor = false
	btn.Font = Fonts.Button
	btn.TextSize = 20
	btn.TextColor3 = Colors.White
	btn.Text = symbol .. "  " .. text
	btn.Parent = genderButtons
	createPillCorner(btn)
	createUIStroke(btn, 2, 0, Colors.White)
	
	btn.MouseEnter:Connect(function()
		local stroke = btn:FindFirstChildOfClass("UIStroke")
		if stroke then
			tween(stroke, TweenInfo.new(0.15), { Thickness = 4 })
		end
	end)
	btn.MouseLeave:Connect(function()
		local stroke = btn:FindFirstChildOfClass("UIStroke")
		if stroke then
			tween(stroke, TweenInfo.new(0.15), { Thickness = 2 })
		end
	end)
	
	return btn
end

local maleBtn = createGenderButton("♂", "Male", Colors.MaleBlue)
local femaleBtn = createGenderButton("♀", "Female", Colors.FemalePink)

----------------------------------------------------------------
-- NAME SELECTION OVERLAY
----------------------------------------------------------------

local nameOverlay = Instance.new("Frame")
nameOverlay.Name = "NameOverlay"
nameOverlay.Size = UDim2.fromScale(1, 1)
nameOverlay.BackgroundColor3 = Colors.OverlayBlack
nameOverlay.BackgroundTransparency = 0.45
nameOverlay.Visible = false
nameOverlay.ZIndex = 75
nameOverlay.Parent = screenGui

local nameCard = Instance.new("Frame")
nameCard.Name = "NameCard"
nameCard.Size = UDim2.new(0, 320, 0, 280)
nameCard.AnchorPoint = Vector2.new(0.5, 0.5)
nameCard.Position = UDim2.fromScale(0.5, 0.5)
nameCard.BackgroundTransparency = 1
nameCard.Parent = nameOverlay

local nameTitle = Instance.new("TextLabel")
nameTitle.Size = UDim2.new(1, 0, 0, 40)
nameTitle.Position = UDim2.new(0, 0, 0, 0)
nameTitle.BackgroundTransparency = 1
nameTitle.Font = Fonts.BodyMedium
nameTitle.TextSize = 20
nameTitle.TextColor3 = Colors.TutorialYellow
nameTitle.Text = "Now, pick someone to become."
nameTitle.Parent = nameCard

local nameButtons = Instance.new("Frame")
nameButtons.Size = UDim2.new(1, 0, 0, 200)
nameButtons.Position = UDim2.new(0, 0, 0, 60)
nameButtons.BackgroundTransparency = 1
nameButtons.Parent = nameCard

local nameButtonsLayout = Instance.new("UIListLayout")
nameButtonsLayout.FillDirection = Enum.FillDirection.Vertical
nameButtonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
nameButtonsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
nameButtonsLayout.Padding = UDim.new(0, 12)
nameButtonsLayout.Parent = nameButtons

local maleFirstNames = {
	"Anthony", "Scott", "Logan", "Ethan", "Noah", "Liam", "Mason", "Jayden", "Caleb", "Damian",
	"Oliver", "James", "William", "Benjamin", "Lucas", "Henry", "Alexander", "Sebastian", "Jack", "Aiden",
}

local femaleFirstNames = {
	"Olivia", "Emma", "Ava", "Sophia", "Mia", "Amelia", "Isabella", "Charlotte", "Luna", "Stella",
	"Harper", "Evelyn", "Aria", "Chloe", "Ella", "Scarlett", "Grace", "Lily", "Zoey", "Penelope",
}

local lastNames = {
	"Russell", "Allen", "Flores", "Cooper", "Parker", "Reed", "Mitchell", "Walker", "Gray", "Brooks",
	"Smelley", "Florea", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez",
}

local nameButtonInstances = {}

local function clearNameButtons()
	for _, b in ipairs(nameButtonInstances) do
		b:Destroy()
	end
	table.clear(nameButtonInstances)
end

local function randomFrom(tbl)
	return tbl[math.random(1, #tbl)]
end

local function generateNameOptions()
	clearNameButtons()
	
	local firstNameList = selectedGender == "Female" and femaleFirstNames or maleFirstNames
	local colors = { Colors.NameGreen, Colors.NameYellow, Colors.NameOrange }
	local emojis = selectedGender == "Female" and {"👩", "👧", "👩‍🦱"} or {"👨", "👦", "👨‍🦱"}
	
	for i = 1, 3 do
		local firstName = randomFrom(firstNameList)
		local lastName = randomFrom(lastNames)
		local fullName = firstName .. " " .. lastName
		
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 52)
		btn.BackgroundColor3 = colors[i]
		btn.AutoButtonColor = false
		btn.Font = Fonts.Button
		btn.TextSize = 18
		btn.TextColor3 = Colors.White
		btn.Text = emojis[i] .. "  " .. fullName
		btn.LayoutOrder = i
		btn.Parent = nameButtons
		createPillCorner(btn)
		createUIStroke(btn, 2, 0.5, Color3.new(1, 1, 1))
		
		table.insert(nameButtonInstances, btn)
		
		btn.MouseEnter:Connect(function()
			tween(btn, TweenInfo.new(0.1), { Size = UDim2.new(1, 8, 0, 56) })
		end)
		btn.MouseLeave:Connect(function()
			tween(btn, TweenInfo.new(0.1), { Size = UDim2.new(1, 0, 0, 52) })
		end)
		
		btn.MouseButton1Click:Connect(function()
			local selectedName = fullName
			nameOverlay.Visible = false
			
			SetLifeInfo:FireServer(selectedName, selectedGender)
			
			introComplete = true
			task.delay(0.5, function()
				showTutorial()
			end)
		end)
	end
end

maleBtn.MouseButton1Click:Connect(function()
	selectedGender = "Male"
	avatarEmoji.Text = "👶"
	genderOverlay.Visible = false
	nameOverlay.Visible = true
	generateNameOptions()
end)

femaleBtn.MouseButton1Click:Connect(function()
	selectedGender = "Female"
	avatarEmoji.Text = "👶"
	genderOverlay.Visible = false
	nameOverlay.Visible = true
	generateNameOptions()
end)

----------------------------------------------------------------
-- STATE UPDATE FUNCTIONS
----------------------------------------------------------------

local function updateStats()
	if not currentState or not currentState.Stats then return end
	
	for key, card in pairs(statCards) do
		local value = math.floor(currentState.Stats[key] or 0)
		card.percentLabel.Text = tostring(value) .. "%"
		
		local pct = math.clamp(value / 100, 0, 1)
		tween(card.barFill, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(pct, 0, 1, 0)
		})
		
		card.boostBtn.Visible = value < 25
		
		if value < 25 then
			card.barFill.BackgroundColor3 = Colors.StatRed
		else
			card.barFill.BackgroundColor3 = card.color
		end
	end
end

local function updateHeader()
	if not currentState then return end
	
	nameLabel.Text = currentState.Name or "New Life"
	
	local age = currentState.Age or 0
	local year = currentState.Year or 2025
	ageYearLabel.Text = string.format("Age %d • Year %d", age, year)
	
	local money = currentState.Money or 0
	moneyLabel.Text = formatMoney(money)
	
	if age < 3 then
		avatarEmoji.Text = "👶"
	elseif age < 13 then
		avatarEmoji.Text = selectedGender == "Female" and "👧" or "👦"
	elseif age < 20 then
		avatarEmoji.Text = selectedGender == "Female" and "👩" or "👨"
	elseif age < 50 then
		avatarEmoji.Text = selectedGender == "Female" and "👩" or "👨"
	else
		avatarEmoji.Text = selectedGender == "Female" and "👵" or "👴"
	end
end

local function updateFromState()
	if not currentState then return end
	
	updateHeader()
	updateStats()
	
	if not currentState.Name and not introComplete then
		ageButtonContainer.Visible = false
		genderOverlay.Visible = true
		nameOverlay.Visible = false
	else
		ageButtonContainer.Visible = true
		genderOverlay.Visible = false
		nameOverlay.Visible = false
	end
end

----------------------------------------------------------------
-- REMOTE EVENT HANDLERS
----------------------------------------------------------------

SyncState.OnClientEvent:Connect(function(state, lastFeedText)
	-- Update currentState table IN PLACE so screen modules see changes
	-- (They hold a reference to this table)
	if state then
		currentState.Name = state.Name or currentState.Name
		currentState.Age = state.Age or currentState.Age or 0
		currentState.Money = state.Money or currentState.Money or 0
		currentState.Happiness = state.Happiness or currentState.Happiness or 50
		currentState.Health = state.Health or currentState.Health or 100
		currentState.Smarts = state.Smarts or currentState.Smarts or 50
		currentState.Looks = state.Looks or currentState.Looks or 50
		currentState.Education = state.Education or currentState.Education or "None"
		currentState.Experience = state.Experience or currentState.Experience or 0
		currentState.CurrentJob = state.CurrentJob
		currentState.InJail = state.InJail or false
		
		-- Copy any other fields from server state
		for k, v in pairs(state) do
			if currentState[k] == nil then
				currentState[k] = v
			end
		end
	end
	
	updateFromState()
	
	if lastFeedText then
		addFeedEntry(lastFeedText)
	end
	
	print("[LifeClient] State synced - Age:", currentState.Age, "Money:", currentState.Money)
end)

PresentEvent.OnClientEvent:Connect(function(eventData, ageFeedText)
	hideTutorial()
	
	if ageFeedText then
		addFeedEntry(ageFeedText)
	end
	
	local payload = {
		id = eventData.id,
		text = eventData.text,
		choices = eventData.choices,
		emoji = eventData.emoji or "🙂",
		title = eventData.title or "Life Event",
		showRelationship = eventData.showRelationship or false,
		relationName = eventData.relationName,
		relationship = eventData.relationship,
	}
	
	showEvent(payload)
end)

----------------------------------------------------------------
-- AGE BUTTON INTERACTION
----------------------------------------------------------------

local function pulseAgeButton()
	local ti = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	tween(ageButton, ti, { Size = UDim2.new(1, 2, 1, 2) }).Completed:Wait()
	tween(ageButton, ti, { Size = UDim2.new(1, -6, 1, -6) })
end

ageButton.MouseButton1Click:Connect(function()
	if awaitingEvent then return end
	if currentState and not currentState.Name then return end
	
	hideTutorial()
	pulseAgeButton()
	RequestAgeUp:FireServer()
end)

ageButton.MouseEnter:Connect(function()
	tween(ageOuterRing, TweenInfo.new(0.15), { Size = UDim2.new(1, 14, 1, 14) })
end)

ageButton.MouseLeave:Connect(function()
	tween(ageOuterRing, TweenInfo.new(0.15), { Size = UDim2.new(1, 10, 1, 10) })
end)

----------------------------------------------------------------
-- INITIALIZE SCREEN MODULES (with error handling and debug logging)
----------------------------------------------------------------

print("[LifeClient] Initializing screen instances...")

if OccupationScreen and OccupationScreen.new then
	local success, instance = pcall(function()
		return OccupationScreen.new(screenGui, blurOverlay, showBlur, hideBlur, currentState)
	end)
	if success then 
		occupationScreenInstance = instance 
		print("[LifeClient] ✅ OccupationScreen instance created")
	else
		warn("[LifeClient] ❌ OccupationScreen.new() failed:", instance)
	end
else
	warn("[LifeClient] ⚠️ OccupationScreen module not available")
end

if AssetsScreen and AssetsScreen.new then
	local success, instance = pcall(function()
		return AssetsScreen.new(screenGui, blurOverlay, showBlur, hideBlur, currentState)
	end)
	if success then 
		assetsScreenInstance = instance 
		print("[LifeClient] ✅ AssetsScreen instance created")
	else
		warn("[LifeClient] ❌ AssetsScreen.new() failed:", instance)
	end
else
	warn("[LifeClient] ⚠️ AssetsScreen module not available")
end

if RelationshipsScreen and RelationshipsScreen.new then
	local success, instance = pcall(function()
		return RelationshipsScreen.new(screenGui, blurOverlay, showBlur, hideBlur, currentState)
	end)
	if success then 
		relationshipsScreenInstance = instance 
		print("[LifeClient] ✅ RelationshipsScreen instance created")
	else
		warn("[LifeClient] ❌ RelationshipsScreen.new() failed:", instance)
	end
else
	warn("[LifeClient] ⚠️ RelationshipsScreen module not available")
end

if ActivitiesScreen and ActivitiesScreen.new then
	local success, instance = pcall(function()
		return ActivitiesScreen.new(screenGui, blurOverlay, showBlur, hideBlur, currentState)
	end)
	if success then 
		activitiesScreenInstance = instance 
		print("[LifeClient] ✅ ActivitiesScreen instance created")
	else
		warn("[LifeClient] ❌ ActivitiesScreen.new() failed:", instance)
	end
else
	warn("[LifeClient] ⚠️ ActivitiesScreen module not available")
end

print("[LifeClient] Screen initialization complete!")

----------------------------------------------------------------
-- INITIAL STATE
----------------------------------------------------------------

ageButtonContainer.Visible = false
