-- ActivitiesScreen.lua
-- BitLife-style Activities screen with hobbies, actions, crime, mind & body
-- Full-screen overlay with scrollable content sections

local TweenService = game:GetService("TweenService")

local ActivitiesScreen = {}
ActivitiesScreen.__index = ActivitiesScreen

----------------------------------------------------------------
-- COLORS (BitLife Palette)
----------------------------------------------------------------

local Colors = {
	-- Primary
	BitLifeBlue      = Color3.fromRGB(37, 99, 235),
	BitLifeBlueDark  = Color3.fromRGB(29, 78, 216),
	
	-- Section Colors
	ActivitiesPurple = Color3.fromRGB(139, 92, 246),
	ActivitiesPurpleDark = Color3.fromRGB(109, 40, 217),
	MindBodyGreen    = Color3.fromRGB(16, 185, 129),
	MindBodyGreenDark = Color3.fromRGB(5, 150, 105),
	CrimeRed         = Color3.fromRGB(220, 38, 38),
	CrimeRedDark     = Color3.fromRGB(185, 28, 28),
	SocialBlue       = Color3.fromRGB(59, 130, 246),
	EntertainmentOrange = Color3.fromRGB(249, 115, 22),
	LoveRed          = Color3.fromRGB(236, 72, 153),
	MoneyGreen       = Color3.fromRGB(34, 197, 94),
	
	-- UI Elements
	White            = Color3.fromRGB(255, 255, 255),
	CardWhite        = Color3.fromRGB(255, 255, 255),
	LightGray        = Color3.fromRGB(243, 244, 246),
	MediumGray       = Color3.fromRGB(156, 163, 175),
	DarkGray         = Color3.fromRGB(75, 85, 99),
	DarkerGray       = Color3.fromRGB(55, 65, 81),
	TextDark         = Color3.fromRGB(31, 41, 55),
	TextBlack        = Color3.fromRGB(17, 24, 39),
	
	-- Background
	ScreenBg         = Color3.fromRGB(241, 245, 249),
}

----------------------------------------------------------------
-- FONTS
----------------------------------------------------------------

local Fonts = {
	Title = Enum.Font.GothamBold,
	Body = Enum.Font.Gotham,
	BodyMedium = Enum.Font.GothamMedium,
	Button = Enum.Font.GothamBold,
}

----------------------------------------------------------------
-- ACTIVITY DATA
----------------------------------------------------------------

local MindBodyActivities = {
	-- Mind
	{
		name = "Read a Book",
		emoji = "📚",
		description = "Expand your knowledge",
		category = "Mind",
		effects = { Smarts = 3, Happiness = 1 },
	},
	{
		name = "Meditate",
		emoji = "🧘",
		description = "Find inner peace",
		category = "Mind",
		effects = { Happiness = 5, Health = 1 },
	},
	{
		name = "Learn a Language",
		emoji = "🗣️",
		description = "Become multilingual",
		category = "Mind",
		effects = { Smarts = 4 },
	},
	{
		name = "Study",
		emoji = "📖",
		description = "Hit the books",
		category = "Mind",
		effects = { Smarts = 5 },
	},
	{
		name = "Play Chess",
		emoji = "♟️",
		description = "Strategic thinking",
		category = "Mind",
		effects = { Smarts = 2, Happiness = 1 },
	},
	-- Body
	{
		name = "Go to the Gym",
		emoji = "🏋️",
		description = "Build strength and stamina",
		category = "Body",
		effects = { Health = 5, Looks = 2 },
	},
	{
		name = "Go for a Walk",
		emoji = "🚶",
		description = "Light exercise and fresh air",
		category = "Body",
		effects = { Health = 2, Happiness = 2 },
	},
	{
		name = "Go for a Run",
		emoji = "🏃",
		description = "Cardio workout",
		category = "Body",
		effects = { Health = 4, Happiness = 1 },
	},
	{
		name = "Martial Arts",
		emoji = "🥋",
		description = "Learn self-defense",
		category = "Body",
		effects = { Health = 3, Smarts = 1 },
	},
	{
		name = "Yoga",
		emoji = "🧘‍♀️",
		description = "Flexibility and mindfulness",
		category = "Body",
		effects = { Health = 3, Happiness = 3 },
	},
	{
		name = "Swimming",
		emoji = "🏊",
		description = "Full body workout",
		category = "Body",
		effects = { Health = 4, Looks = 1 },
	},
	-- Beauty
	{
		name = "Spa Day",
		emoji = "💆",
		description = "Pamper yourself",
		category = "Beauty",
		effects = { Looks = 3, Happiness = 4 },
		cost = 200,
	},
	{
		name = "Salon Visit",
		emoji = "💇",
		description = "Get a new look",
		category = "Beauty",
		effects = { Looks = 4, Happiness = 2 },
		cost = 80,
	},
	{
		name = "Plastic Surgery",
		emoji = "💉",
		description = "Cosmetic enhancement",
		category = "Beauty",
		effects = { Looks = 15 },
		cost = 15000,
		risky = true,
	},
}

local SocialActivities = {
	{
		name = "Go to a Party",
		emoji = "🎉",
		description = "Have fun and meet people",
		effects = { Happiness = 5 },
		canMeetPeople = true,
	},
	{
		name = "Hang Out with Friends",
		emoji = "👥",
		description = "Quality time with buddies",
		effects = { Happiness = 4 },
	},
	{
		name = "Go on a Date",
		emoji = "💕",
		description = "Romantic evening out",
		effects = { Happiness = 3 },
		requiresPartner = true,
	},
	{
		name = "Speed Dating",
		emoji = "⏱️",
		description = "Meet many potential partners quickly",
		effects = { Happiness = 1 },
		canMeetPeople = true,
		minAge = 18,
	},
	{
		name = "Nightclub",
		emoji = "🕺",
		description = "Dance the night away",
		effects = { Happiness = 4, Health = -1 },
		canMeetPeople = true,
		minAge = 21,
	},
	{
		name = "Host a Party",
		emoji = "🏠",
		description = "Invite people to your place",
		effects = { Happiness = 3 },
		cost = 500,
	},
}

local EntertainmentActivities = {
	{
		name = "Watch TV",
		emoji = "📺",
		description = "Binge your favorite shows",
		effects = { Happiness = 2 },
	},
	{
		name = "Play Video Games",
		emoji = "🎮",
		description = "Gaming session",
		effects = { Happiness = 3, Smarts = 1 },
	},
	{
		name = "Go to the Movies",
		emoji = "🎬",
		description = "Catch the latest film",
		effects = { Happiness = 3 },
		cost = 20,
	},
	{
		name = "Concert",
		emoji = "🎸",
		description = "See live music",
		effects = { Happiness = 6 },
		cost = 150,
	},
	{
		name = "Amusement Park",
		emoji = "🎢",
		description = "Thrills and fun",
		effects = { Happiness = 5 },
		cost = 100,
	},
	{
		name = "Vacation",
		emoji = "✈️",
		description = "Take a trip",
		effects = { Happiness = 10, Health = 2 },
		cost = 3000,
	},
	{
		name = "Casino",
		emoji = "🎰",
		description = "Try your luck",
		effects = { Happiness = 2 },
		minAge = 21,
		gambling = true,
	},
	{
		name = "Browse Social Media",
		emoji = "📱",
		description = "Scroll through feeds",
		effects = { Happiness = 1 },
	},
}

local CrimeActivities = {
	{
		name = "Shoplift",
		emoji = "🛒",
		description = "Five-finger discount",
		risk = "Low",
		reward = "$50-200",
		jailTime = "1-3 months",
	},
	{
		name = "Pickpocket",
		emoji = "👛",
		description = "Lift someone's wallet",
		risk = "Medium",
		reward = "$20-500",
		jailTime = "3-6 months",
	},
	{
		name = "Burglary",
		emoji = "🏠",
		description = "Break into a house",
		risk = "High",
		reward = "$500-5000",
		jailTime = "1-5 years",
	},
	{
		name = "Grand Theft Auto",
		emoji = "🚗",
		description = "Steal a vehicle",
		risk = "High",
		reward = "$5000-50000",
		jailTime = "2-10 years",
	},
	{
		name = "Bank Robbery",
		emoji = "🏦",
		description = "Rob a bank",
		risk = "Extreme",
		reward = "$10000-1000000",
		jailTime = "10-25 years",
	},
	{
		name = "Porch Pirate",
		emoji = "📦",
		description = "Steal delivered packages",
		risk = "Low",
		reward = "$10-500",
		jailTime = "1-6 months",
	},
	{
		name = "Drug Dealing",
		emoji = "💊",
		description = "Sell illegal substances",
		risk = "High",
		reward = "$100-10000",
		jailTime = "5-20 years",
	},
}

local SpecialActivities = {
	{
		name = "Lottery",
		emoji = "🎟️",
		description = "Buy a lottery ticket",
		cost = 5,
		gambling = true,
	},
	{
		name = "Emigrate",
		emoji = "🌍",
		description = "Move to another country",
		minAge = 18,
	},
	{
		name = "Time Machine",
		emoji = "⏰",
		description = "Go back in time (Bitizen only)",
		premium = true,
	},
	{
		name = "Surrender",
		emoji = "🏳️",
		description = "Turn yourself in to police",
		requiresWanted = true,
	},
	{
		name = "Witch Doctor",
		emoji = "🧙",
		description = "Seek alternative healing",
		cost = 5000,
	},
}

----------------------------------------------------------------
-- HELPER FUNCTIONS
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
	if amount >= 1000000 then
		return string.format("$%.1fM", amount / 1000000)
	elseif amount >= 1000 then
		return string.format("$%.0fK", amount / 1000)
	else
		return "$" .. tostring(amount)
	end
end

local function getRiskColor(risk)
	if risk == "Low" then
		return Colors.MoneyGreen
	elseif risk == "Medium" then
		return Colors.EntertainmentOrange
	elseif risk == "High" then
		return Colors.CrimeRed
	else -- Extreme
		return Color3.fromRGB(127, 29, 29)
	end
end

----------------------------------------------------------------
-- SCREEN CREATION
----------------------------------------------------------------

function ActivitiesScreen.new(screenGui, blurOverlay, showBlurFunc, hideBlurFunc, playerState)
	local self = setmetatable({}, ActivitiesScreen)
	
	self.screenGui = screenGui
	self.blurOverlay = blurOverlay
	self.showBlur = showBlurFunc
	self.hideBlur = hideBlurFunc
	self.playerState = playerState
	self.isVisible = false
	
	self:createUI()
	
	return self
end

function ActivitiesScreen:createUI()
	-- Main overlay container
	self.overlay = Instance.new("Frame")
	self.overlay.Name = "ActivitiesOverlay"
	self.overlay.Size = UDim2.fromScale(1, 1)
	self.overlay.BackgroundColor3 = Colors.ScreenBg
	self.overlay.BackgroundTransparency = 0
	self.overlay.Visible = false
	self.overlay.ZIndex = 80
	self.overlay.Parent = self.screenGui
	
	-- Header bar
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 60)
	header.BackgroundColor3 = Colors.ActivitiesPurple
	header.BorderSizePixel = 0
	header.ZIndex = 85
	header.Parent = self.overlay
	
	local headerGrad = Instance.new("UIGradient")
	headerGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Colors.ActivitiesPurple),
		ColorSequenceKeypoint.new(1, Colors.ActivitiesPurpleDark),
	})
	headerGrad.Rotation = 90
	headerGrad.Parent = header
	
	-- Back button
	local backBtn = Instance.new("TextButton")
	backBtn.Name = "BackBtn"
	backBtn.Size = UDim2.new(0, 50, 0, 40)
	backBtn.Position = UDim2.new(0, 10, 0.5, -20)
	backBtn.BackgroundTransparency = 1
	backBtn.Font = Fonts.Title
	backBtn.TextSize = 24
	backBtn.TextColor3 = Colors.White
	backBtn.Text = "←"
	backBtn.ZIndex = 86
	backBtn.Parent = header
	
	backBtn.MouseButton1Click:Connect(function()
		self:hide()
	end)
	
	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -120, 1, 0)
	titleLabel.Position = UDim2.new(0, 60, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Fonts.Title
	titleLabel.TextSize = 20
	titleLabel.TextColor3 = Colors.White
	titleLabel.Text = "🎭 Activities"
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 86
	titleLabel.Parent = header
	
	-- Scrolling content
	local contentScroll = Instance.new("ScrollingFrame")
	contentScroll.Name = "ContentScroll"
	contentScroll.Size = UDim2.new(1, 0, 1, -60)
	contentScroll.Position = UDim2.new(0, 0, 0, 60)
	contentScroll.BackgroundTransparency = 1
	contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	contentScroll.ScrollBarThickness = 4
	contentScroll.ScrollBarImageColor3 = Colors.MediumGray
	contentScroll.ZIndex = 81
	contentScroll.Parent = self.overlay
	
	local contentPadding = createUIPadding(contentScroll, 16, 16, 16, 16)
	
	local contentLayout = Instance.new("UIListLayout")
	contentLayout.FillDirection = Enum.FillDirection.Vertical
	contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	contentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	contentLayout.Padding = UDim.new(0, 16)
	contentLayout.Parent = contentScroll
	
	self.contentScroll = contentScroll
	
	-- Create sections
	self:createMindBodySection()
	self:createSocialSection()
	self:createEntertainmentSection()
	self:createCrimeSection()
	self:createSpecialSection()
end

function ActivitiesScreen:createSectionHeader(parent, title, emoji, color, layoutOrder)
	local section = Instance.new("Frame")
	section.Name = title:gsub(" ", "") .. "Section"
	section.Size = UDim2.new(1, 0, 0, 0)
	section.AutomaticSize = Enum.AutomaticSize.Y
	section.BackgroundTransparency = 1
	section.LayoutOrder = layoutOrder
	section.Parent = parent
	
	local sectionLayout = Instance.new("UIListLayout")
	sectionLayout.FillDirection = Enum.FillDirection.Vertical
	sectionLayout.Padding = UDim.new(0, 8)
	sectionLayout.Parent = section
	
	local headerFrame = Instance.new("Frame")
	headerFrame.Size = UDim2.new(1, 0, 0, 44)
	headerFrame.BackgroundColor3 = color
	headerFrame.LayoutOrder = 1
	headerFrame.Parent = section
	createUICorner(headerFrame, 12)
	
	local headerGrad = Instance.new("UIGradient")
	headerGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color),
		ColorSequenceKeypoint.new(1, Color3.new(
			math.max(0, color.R - 0.1),
			math.max(0, color.G - 0.1),
			math.max(0, color.B - 0.1)
		)),
	})
	headerGrad.Rotation = 90
	headerGrad.Parent = headerFrame
	
	local headerText = Instance.new("TextLabel")
	headerText.Size = UDim2.fromScale(1, 1)
	headerText.BackgroundTransparency = 1
	headerText.Font = Fonts.Title
	headerText.TextSize = 16
	headerText.TextColor3 = Colors.White
	headerText.Text = emoji .. "  " .. title
	headerText.Parent = headerFrame
	
	return section, sectionLayout
end

function ActivitiesScreen:createActivityCard(activity, color, layoutOrder)
	local card = Instance.new("TextButton")
	card.Name = "Activity_" .. activity.name:gsub(" ", "_")
	card.Size = UDim2.new(1, 0, 0, 70)
	card.BackgroundColor3 = Colors.CardWhite
	card.LayoutOrder = layoutOrder
	card.AutoButtonColor = false
	card.Text = ""
	createUICorner(card, 14)
	createUIStroke(card, 1, 0.85, Color3.fromRGB(229, 231, 235))
	
	-- Emoji circle
	local emojiCircle = Instance.new("Frame")
	emojiCircle.Size = UDim2.new(0, 46, 0, 46)
	emojiCircle.Position = UDim2.new(0, 14, 0.5, -23)
	emojiCircle.BackgroundColor3 = Color3.new(
		math.min(1, color.R + 0.4),
		math.min(1, color.G + 0.4),
		math.min(1, color.B + 0.4)
	)
	emojiCircle.Parent = card
	createUICorner(emojiCircle, 23)
	
	local emojiLabel = Instance.new("TextLabel")
	emojiLabel.Size = UDim2.fromScale(1, 1)
	emojiLabel.BackgroundTransparency = 1
	emojiLabel.Font = Fonts.Body
	emojiLabel.TextSize = 24
	emojiLabel.Text = activity.emoji
	emojiLabel.Parent = emojiCircle
	
	-- Info
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.55, 0, 0, 20)
	nameLabel.Position = UDim2.new(0, 70, 0, 14)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Fonts.Title
	nameLabel.TextSize = 14
	nameLabel.TextColor3 = Colors.TextBlack
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = activity.name
	nameLabel.Parent = card
	
	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(0.55, 0, 0, 16)
	descLabel.Position = UDim2.new(0, 70, 0, 34)
	descLabel.BackgroundTransparency = 1
	descLabel.Font = Fonts.Body
	descLabel.TextSize = 12
	descLabel.TextColor3 = Colors.MediumGray
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.Text = activity.description
	descLabel.Parent = card
	
	-- Cost if applicable
	if activity.cost then
		local costLabel = Instance.new("TextLabel")
		costLabel.Size = UDim2.new(0, 80, 0, 16)
		costLabel.Position = UDim2.new(0, 70, 0, 50)
		costLabel.BackgroundTransparency = 1
		costLabel.Font = Fonts.BodyMedium
		costLabel.TextSize = 11
		costLabel.TextColor3 = Colors.MoneyGreen
		costLabel.TextXAlignment = Enum.TextXAlignment.Left
		costLabel.Text = "💰 " .. formatMoney(activity.cost)
		costLabel.Parent = card
	end
	
	-- Go button
	local goBtn = Instance.new("TextButton")
	goBtn.Size = UDim2.new(0, 60, 0, 32)
	goBtn.AnchorPoint = Vector2.new(1, 0.5)
	goBtn.Position = UDim2.new(1, -14, 0.5, 0)
	goBtn.BackgroundColor3 = color
	goBtn.Font = Fonts.Button
	goBtn.TextSize = 12
	goBtn.TextColor3 = Colors.White
	goBtn.Text = "Go"
	goBtn.AutoButtonColor = false
	goBtn.Parent = card
	createPillCorner(goBtn)
	
	goBtn.MouseEnter:Connect(function()
		tween(goBtn, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.new(
				math.max(0, color.R - 0.1),
				math.max(0, color.G - 0.1),
				math.max(0, color.B - 0.1)
			)
		})
	end)
	goBtn.MouseLeave:Connect(function()
		tween(goBtn, TweenInfo.new(0.15), { BackgroundColor3 = color })
	end)
	
	goBtn.MouseButton1Click:Connect(function()
		self:doActivity(activity)
	end)
	
	-- Card hover
	card.MouseEnter:Connect(function()
		tween(card, TweenInfo.new(0.15), { BackgroundColor3 = Colors.LightGray })
	end)
	card.MouseLeave:Connect(function()
		tween(card, TweenInfo.new(0.15), { BackgroundColor3 = Colors.CardWhite })
	end)
	
	return card
end

function ActivitiesScreen:createCrimeCard(crime, layoutOrder)
	local card = Instance.new("TextButton")
	card.Name = "Crime_" .. crime.name:gsub(" ", "_")
	card.Size = UDim2.new(1, 0, 0, 85)
	card.BackgroundColor3 = Colors.CardWhite
	card.LayoutOrder = layoutOrder
	card.AutoButtonColor = false
	card.Text = ""
	createUICorner(card, 14)
	createUIStroke(card, 1, 0.85, Color3.fromRGB(229, 231, 235))
	
	-- Emoji circle (darker for crime)
	local emojiCircle = Instance.new("Frame")
	emojiCircle.Size = UDim2.new(0, 50, 0, 50)
	emojiCircle.Position = UDim2.new(0, 14, 0.5, -25)
	emojiCircle.BackgroundColor3 = Color3.fromRGB(254, 226, 226)
	emojiCircle.Parent = card
	createUICorner(emojiCircle, 25)
	
	local emojiLabel = Instance.new("TextLabel")
	emojiLabel.Size = UDim2.fromScale(1, 1)
	emojiLabel.BackgroundTransparency = 1
	emojiLabel.Font = Fonts.Body
	emojiLabel.TextSize = 26
	emojiLabel.Text = crime.emoji
	emojiLabel.Parent = emojiCircle
	
	-- Info
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.5, 0, 0, 20)
	nameLabel.Position = UDim2.new(0, 74, 0, 10)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Fonts.Title
	nameLabel.TextSize = 14
	nameLabel.TextColor3 = Colors.TextBlack
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = crime.name
	nameLabel.Parent = card
	
	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(0.5, 0, 0, 14)
	descLabel.Position = UDim2.new(0, 74, 0, 30)
	descLabel.BackgroundTransparency = 1
	descLabel.Font = Fonts.Body
	descLabel.TextSize = 11
	descLabel.TextColor3 = Colors.MediumGray
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.Text = crime.description
	descLabel.Parent = card
	
	-- Risk indicator
	local riskColor = getRiskColor(crime.risk)
	
	local riskLabel = Instance.new("TextLabel")
	riskLabel.Size = UDim2.new(0, 80, 0, 14)
	riskLabel.Position = UDim2.new(0, 74, 0, 48)
	riskLabel.BackgroundTransparency = 1
	riskLabel.Font = Fonts.BodyMedium
	riskLabel.TextSize = 11
	riskLabel.TextColor3 = riskColor
	riskLabel.TextXAlignment = Enum.TextXAlignment.Left
	riskLabel.Text = "⚠️ " .. crime.risk .. " Risk"
	riskLabel.Parent = card
	
	-- Reward
	local rewardLabel = Instance.new("TextLabel")
	rewardLabel.Size = UDim2.new(0, 100, 0, 14)
	rewardLabel.Position = UDim2.new(0, 74, 0, 64)
	rewardLabel.BackgroundTransparency = 1
	rewardLabel.Font = Fonts.Body
	rewardLabel.TextSize = 10
	rewardLabel.TextColor3 = Colors.MoneyGreen
	rewardLabel.TextXAlignment = Enum.TextXAlignment.Left
	rewardLabel.Text = "💰 " .. crime.reward
	rewardLabel.Parent = card
	
	-- Commit button
	local commitBtn = Instance.new("TextButton")
	commitBtn.Size = UDim2.new(0, 70, 0, 34)
	commitBtn.AnchorPoint = Vector2.new(1, 0.5)
	commitBtn.Position = UDim2.new(1, -14, 0.5, 0)
	commitBtn.BackgroundColor3 = Colors.CrimeRed
	commitBtn.Font = Fonts.Button
	commitBtn.TextSize = 12
	commitBtn.TextColor3 = Colors.White
	commitBtn.Text = "Commit"
	commitBtn.AutoButtonColor = false
	commitBtn.Parent = card
	createPillCorner(commitBtn)
	
	commitBtn.MouseEnter:Connect(function()
		tween(commitBtn, TweenInfo.new(0.15), { BackgroundColor3 = Colors.CrimeRedDark })
	end)
	commitBtn.MouseLeave:Connect(function()
		tween(commitBtn, TweenInfo.new(0.15), { BackgroundColor3 = Colors.CrimeRed })
	end)
	
	commitBtn.MouseButton1Click:Connect(function()
		self:commitCrime(crime)
	end)
	
	return card
end

function ActivitiesScreen:createMindBodySection()
	local section, layout = self:createSectionHeader(
		self.contentScroll,
		"Mind & Body",
		"🧠",
		Colors.MindBodyGreen,
		1
	)
	
	for i, activity in ipairs(MindBodyActivities) do
		local card = self:createActivityCard(activity, Colors.MindBodyGreen, i + 1)
		card.Parent = section
	end
end

function ActivitiesScreen:createSocialSection()
	local section, layout = self:createSectionHeader(
		self.contentScroll,
		"Social",
		"👥",
		Colors.SocialBlue,
		2
	)
	
	for i, activity in ipairs(SocialActivities) do
		local card = self:createActivityCard(activity, Colors.SocialBlue, i + 1)
		card.Parent = section
	end
end

function ActivitiesScreen:createEntertainmentSection()
	local section, layout = self:createSectionHeader(
		self.contentScroll,
		"Entertainment",
		"🎉",
		Colors.EntertainmentOrange,
		3
	)
	
	for i, activity in ipairs(EntertainmentActivities) do
		local card = self:createActivityCard(activity, Colors.EntertainmentOrange, i + 1)
		card.Parent = section
	end
end

function ActivitiesScreen:createCrimeSection()
	local section, layout = self:createSectionHeader(
		self.contentScroll,
		"Crime",
		"🔪",
		Colors.CrimeRed,
		4
	)
	
	-- Warning card
	local warningCard = Instance.new("Frame")
	warningCard.Size = UDim2.new(1, 0, 0, 50)
	warningCard.BackgroundColor3 = Color3.fromRGB(254, 243, 199)
	warningCard.LayoutOrder = 2
	warningCard.Parent = section
	createUICorner(warningCard, 10)
	
	local warningLabel = Instance.new("TextLabel")
	warningLabel.Size = UDim2.fromScale(1, 1)
	warningLabel.BackgroundTransparency = 1
	warningLabel.Font = Fonts.Body
	warningLabel.TextSize = 12
	warningLabel.TextColor3 = Color3.fromRGB(146, 64, 14)
	warningLabel.Text = "⚠️ Crime is risky! You could get caught and go to prison."
	warningLabel.TextWrapped = true
	warningLabel.Parent = warningCard
	
	for i, crime in ipairs(CrimeActivities) do
		local card = self:createCrimeCard(crime, i + 2)
		card.Parent = section
	end
end

function ActivitiesScreen:createSpecialSection()
	local section, layout = self:createSectionHeader(
		self.contentScroll,
		"Special",
		"⭐",
		Colors.ActivitiesPurple,
		5
	)
	
	for i, activity in ipairs(SpecialActivities) do
		local card = self:createActivityCard(activity, Colors.ActivitiesPurple, i + 1)
		card.Parent = section
	end
end

function ActivitiesScreen:doActivity(activity)
	-- TODO: Send to server, process activity
	print("Doing activity:", activity.name)
end

function ActivitiesScreen:commitCrime(crime)
	-- TODO: Send to server, process crime with risk calculation
	print("Committing crime:", crime.name)
end

----------------------------------------------------------------
-- VISIBILITY
----------------------------------------------------------------

function ActivitiesScreen:show()
	if self.isVisible then return end
	self.isVisible = true
	
	self.overlay.Visible = true
	self.overlay.Position = UDim2.new(1, 0, 0, 0)
	
	tween(self.overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 0, 0, 0)
	})
end

function ActivitiesScreen:hide()
	if not self.isVisible then return end
	self.isVisible = false
	
	local t = tween(self.overlay, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		Position = UDim2.new(1, 0, 0, 0)
	})
	
	t.Completed:Connect(function()
		self.overlay.Visible = false
	end)
end

function ActivitiesScreen:toggle()
	if self.isVisible then
		self:hide()
	else
		self:show()
	end
end

return ActivitiesScreen
