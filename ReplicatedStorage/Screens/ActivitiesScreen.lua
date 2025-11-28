-- ActivitiesScreen.lua
-- BitLife-style Activities screen with FULL INTERACTIVITY
-- Every activity shows confirmation and results

local TweenService = game:GetService("TweenService")

local ActivitiesScreen = {}
ActivitiesScreen.__index = ActivitiesScreen

----------------------------------------------------------------
-- COLORS
----------------------------------------------------------------

local Colors = {
	BitLifeBlue      = Color3.fromRGB(37, 99, 235),
	BitLifeBlueDark  = Color3.fromRGB(29, 78, 216),
	
	ActivitiesPurple = Color3.fromRGB(139, 92, 246),
	ActivitiesPurpleDark = Color3.fromRGB(109, 40, 217),
	MindBodyGreen    = Color3.fromRGB(16, 185, 129),
	MindBodyGreenDark = Color3.fromRGB(5, 150, 105),
	CrimeRed         = Color3.fromRGB(220, 38, 38),
	CrimeRedDark     = Color3.fromRGB(185, 28, 28),
	SocialBlue       = Color3.fromRGB(59, 130, 246),
	EntertainmentOrange = Color3.fromRGB(249, 115, 22),
	MoneyGreen       = Color3.fromRGB(34, 197, 94),
	
	White            = Color3.fromRGB(255, 255, 255),
	CardWhite        = Color3.fromRGB(255, 255, 255),
	LightGray        = Color3.fromRGB(243, 244, 246),
	MediumGray       = Color3.fromRGB(156, 163, 175),
	DarkGray         = Color3.fromRGB(75, 85, 99),
	DarkerGray       = Color3.fromRGB(55, 65, 81),
	TextBlack        = Color3.fromRGB(17, 24, 39),
	ScreenBg         = Color3.fromRGB(241, 245, 249),
	OverlayDark      = Color3.fromRGB(0, 0, 0),
}

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
	{ name = "Read a Book", emoji = "📚", description = "Expand your knowledge", category = "Mind", effects = { Smarts = {2, 5}, Happiness = {1, 3} } },
	{ name = "Meditate", emoji = "🧘", description = "Find inner peace", category = "Mind", effects = { Happiness = {3, 8}, Health = {1, 3} } },
	{ name = "Study", emoji = "📖", description = "Hit the books hard", category = "Mind", effects = { Smarts = {4, 8} } },
	{ name = "Go to the Gym", emoji = "🏋️", description = "Build strength", category = "Body", effects = { Health = {3, 7}, Looks = {1, 3} } },
	{ name = "Go for a Run", emoji = "🏃", description = "Cardio workout", category = "Body", effects = { Health = {2, 5}, Happiness = {1, 3} } },
	{ name = "Yoga", emoji = "🧘‍♀️", description = "Flexibility & mindfulness", category = "Body", effects = { Health = {2, 4}, Happiness = {2, 5} } },
	{ name = "Spa Day", emoji = "💆", description = "Pamper yourself", category = "Beauty", cost = 200, effects = { Looks = {3, 6}, Happiness = {4, 8} } },
	{ name = "Salon Visit", emoji = "💇", description = "Get a fresh look", category = "Beauty", cost = 80, effects = { Looks = {2, 5}, Happiness = {1, 3} } },
}

local SocialActivities = {
	{ name = "Go to a Party", emoji = "🎉", description = "Have fun & meet people", effects = { Happiness = {4, 10} } },
	{ name = "Hang Out", emoji = "👥", description = "Quality time with friends", effects = { Happiness = {3, 7} } },
	{ name = "Nightclub", emoji = "🕺", description = "Dance the night away", cost = 50, effects = { Happiness = {3, 8}, Health = {-2, 0} } },
	{ name = "Host a Party", emoji = "🏠", description = "Throw a bash", cost = 300, effects = { Happiness = {5, 12} } },
}

local EntertainmentActivities = {
	{ name = "Watch TV", emoji = "📺", description = "Binge your shows", effects = { Happiness = {1, 4} } },
	{ name = "Play Video Games", emoji = "🎮", description = "Gaming session", effects = { Happiness = {2, 6}, Smarts = {0, 2} } },
	{ name = "Go to Movies", emoji = "🎬", description = "Catch a film", cost = 20, effects = { Happiness = {3, 6} } },
	{ name = "Concert", emoji = "🎸", description = "See live music", cost = 150, effects = { Happiness = {6, 15} } },
	{ name = "Vacation", emoji = "✈️", description = "Take a trip!", cost = 2000, effects = { Happiness = {10, 25}, Health = {2, 5} } },
	{ name = "Casino", emoji = "🎰", description = "Try your luck", cost = 100, gambling = true },
}

local CrimeActivities = {
	{ name = "Shoplift", emoji = "🛒", description = "Five-finger discount", risk = 25, reward = {20, 150}, jailYears = {0.1, 0.5} },
	{ name = "Pickpocket", emoji = "👛", description = "Lift someone's wallet", risk = 35, reward = {30, 300}, jailYears = {0.2, 1} },
	{ name = "Burglary", emoji = "🏠", description = "Break into a house", risk = 50, reward = {500, 5000}, jailYears = {1, 5} },
	{ name = "Grand Theft Auto", emoji = "🚗", description = "Steal a vehicle", risk = 60, reward = {2000, 20000}, jailYears = {2, 8} },
	{ name = "Bank Robbery", emoji = "🏦", description = "Rob a bank", risk = 80, reward = {10000, 500000}, jailYears = {10, 25} },
	{ name = "Porch Pirate", emoji = "📦", description = "Steal packages", risk = 20, reward = {10, 200}, jailYears = {0.1, 0.3} },
}

----------------------------------------------------------------
-- OUTCOME TEXTS
----------------------------------------------------------------

local ActivityOutcomes = {
	["Read a Book"] = { "You read an interesting novel!", "You learned something new!", "What a page-turner!" },
	["Meditate"] = { "You feel at peace.", "Your mind is clear.", "Inner calm achieved." },
	["Study"] = { "You feel smarter!", "That was productive!", "Knowledge gained!" },
	["Go to the Gym"] = { "Great workout!", "You're getting stronger!", "Gains!" },
	["Go for a Run"] = { "Refreshing jog!", "You feel energized!", "Good cardio!" },
	["Yoga"] = { "Namaste!", "So relaxing!", "Perfect stretch!" },
	["Spa Day"] = { "Pure relaxation!", "You feel pampered!", "What a treat!" },
	["Salon Visit"] = { "Looking fresh!", "New look, new you!", "Stylish!" },
	["Go to a Party"] = { "What a night!", "So much fun!", "Party animal!" },
	["Hang Out"] = { "Good times with friends!", "Laughter all around!", "Quality time!" },
	["Nightclub"] = { "Danced all night!", "The music was amazing!", "Epic night out!" },
	["Host a Party"] = { "Everyone had a blast!", "Best party ever!", "Great host!" },
	["Watch TV"] = { "Binge complete!", "That show is so good!", "Couch potato mode!" },
	["Play Video Games"] = { "High score!", "Epic gaming session!", "One more game..." },
	["Go to Movies"] = { "Great film!", "Worth every penny!", "Popcorn was perfect!" },
	["Concert"] = { "AMAZING show!", "Best night ever!", "Your ears are ringing!" },
	["Vacation"] = { "Best trip ever!", "So many memories!", "Totally refreshed!" },
}

local CrimeOutcomes = {
	success = {
		"You got away clean!",
		"Nobody saw a thing!",
		"Perfect crime!",
		"Easy money!",
	},
	caught = {
		"The police caught you!",
		"You've been arrested!",
		"Busted!",
		"A witness called the cops!",
	}
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
	if amount >= 1000000 then return string.format("$%.1fM", amount / 1000000)
	elseif amount >= 1000 then return string.format("$%.1fK", amount / 1000)
	else return "$" .. tostring(amount) end
end

local function randomRange(min, max)
	return math.random(min, max)
end

local function randomFrom(tbl)
	return tbl[math.random(1, #tbl)]
end

----------------------------------------------------------------
-- SCREEN CREATION
----------------------------------------------------------------

function ActivitiesScreen.new(screenGui, blurOverlay, showBlurFunc, hideBlurFunc, playerState)
	local self = setmetatable({}, ActivitiesScreen)
	
	self.screenGui = screenGui
	self.playerState = playerState
	self.isVisible = false
	
	self:createUI()
	self:createConfirmModal()
	self:createResultModal()
	
	return self
end

function ActivitiesScreen:createUI()
	self.overlay = Instance.new("Frame")
	self.overlay.Name = "ActivitiesOverlay"
	self.overlay.Size = UDim2.fromScale(1, 1)
	self.overlay.BackgroundColor3 = Colors.ScreenBg
	self.overlay.Visible = false
	self.overlay.ZIndex = 80
	self.overlay.Parent = self.screenGui
	
	-- Header
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 60)
	header.BackgroundColor3 = Colors.ActivitiesPurple
	header.BorderSizePixel = 0
	header.ZIndex = 85
	header.Parent = self.overlay
	
	local headerGrad = Instance.new("UIGradient")
	headerGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Colors.ActivitiesPurple), ColorSequenceKeypoint.new(1, Colors.ActivitiesPurpleDark) })
	headerGrad.Rotation = 90
	headerGrad.Parent = header
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -80, 1, 0)
	titleLabel.Position = UDim2.new(0, 16, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Fonts.Title
	titleLabel.TextSize = 20
	titleLabel.TextColor3 = Colors.White
	titleLabel.Text = "🎭 Activities"
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 86
	titleLabel.Parent = header
	
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 44, 0, 44)
	closeBtn.AnchorPoint = Vector2.new(1, 0.5)
	closeBtn.Position = UDim2.new(1, -10, 0.5, 0)
	closeBtn.BackgroundColor3 = Colors.White
	closeBtn.BackgroundTransparency = 0.9
	closeBtn.Font = Fonts.Title
	closeBtn.TextSize = 24
	closeBtn.TextColor3 = Colors.White
	closeBtn.Text = "✕"
	closeBtn.AutoButtonColor = false
	closeBtn.ZIndex = 86
	closeBtn.Parent = header
	createUICorner(closeBtn, 22)
	
	closeBtn.MouseEnter:Connect(function() tween(closeBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0.7 }) end)
	closeBtn.MouseLeave:Connect(function() tween(closeBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0.9 }) end)
	closeBtn.MouseButton1Click:Connect(function() self:hide() end)
	
	-- Content
	local contentScroll = Instance.new("ScrollingFrame")
	contentScroll.Size = UDim2.new(1, 0, 1, -60)
	contentScroll.Position = UDim2.new(0, 0, 0, 60)
	contentScroll.BackgroundTransparency = 1
	contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	contentScroll.ScrollBarThickness = 4
	contentScroll.ZIndex = 81
	contentScroll.Parent = self.overlay
	
	createUIPadding(contentScroll, 16, 16, 16, 16)
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 16)
	layout.Parent = contentScroll
	
	self.contentScroll = contentScroll
	
	-- Create sections
	self:createActivitySection("Mind & Body", "🧠", Colors.MindBodyGreen, MindBodyActivities, 1)
	self:createActivitySection("Social", "👥", Colors.SocialBlue, SocialActivities, 2)
	self:createActivitySection("Entertainment", "🎉", Colors.EntertainmentOrange, EntertainmentActivities, 3)
	self:createCrimeSection(4)
end

function ActivitiesScreen:createActivitySection(title, emoji, color, activities, order)
	local section = Instance.new("Frame")
	section.Name = title:gsub(" ", "") .. "Section"
	section.Size = UDim2.new(1, 0, 0, 0)
	section.AutomaticSize = Enum.AutomaticSize.Y
	section.BackgroundTransparency = 1
	section.LayoutOrder = order
	section.Parent = self.contentScroll
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.Parent = section
	
	-- Header
	local headerFrame = Instance.new("Frame")
	headerFrame.Size = UDim2.new(1, 0, 0, 44)
	headerFrame.BackgroundColor3 = color
	headerFrame.LayoutOrder = 1
	headerFrame.Parent = section
	createUICorner(headerFrame, 12)
	
	local headerText = Instance.new("TextLabel")
	headerText.Size = UDim2.fromScale(1, 1)
	headerText.BackgroundTransparency = 1
	headerText.Font = Fonts.Title
	headerText.TextSize = 16
	headerText.TextColor3 = Colors.White
	headerText.Text = emoji .. "  " .. title
	headerText.Parent = headerFrame
	
	-- Activity cards
	for i, activity in ipairs(activities) do
		self:createActivityCard(activity, color, i + 1, section)
	end
end

function ActivitiesScreen:createActivityCard(activity, color, order, parent)
	local card = Instance.new("Frame")
	card.Name = "Activity_" .. activity.name:gsub(" ", "_")
	card.Size = UDim2.new(1, 0, 0, 70)
	card.BackgroundColor3 = Colors.CardWhite
	card.LayoutOrder = order
	card.Parent = parent
	createUICorner(card, 14)
	createUIStroke(card, 1, 0.85, Color3.fromRGB(229, 231, 235))
	
	-- Emoji circle
	local emojiCircle = Instance.new("Frame")
	emojiCircle.Size = UDim2.new(0, 46, 0, 46)
	emojiCircle.Position = UDim2.new(0, 14, 0.5, -23)
	emojiCircle.BackgroundColor3 = Color3.new(color.R * 1.3, color.G * 1.3, color.B * 1.3)
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
	nameLabel.Size = UDim2.new(0.5, 0, 0, 20)
	nameLabel.Position = UDim2.new(0, 70, 0, 12)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Fonts.Title
	nameLabel.TextSize = 14
	nameLabel.TextColor3 = Colors.TextBlack
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = activity.name
	nameLabel.Parent = card
	
	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(0.5, 0, 0, 16)
	descLabel.Position = UDim2.new(0, 70, 0, 32)
	descLabel.BackgroundTransparency = 1
	descLabel.Font = Fonts.Body
	descLabel.TextSize = 12
	descLabel.TextColor3 = Colors.MediumGray
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.Text = activity.description
	descLabel.Parent = card
	
	-- Cost if any
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
	goBtn.Size = UDim2.new(0, 60, 0, 34)
	goBtn.AnchorPoint = Vector2.new(1, 0.5)
	goBtn.Position = UDim2.new(1, -14, 0.5, 0)
	goBtn.BackgroundColor3 = color
	goBtn.Font = Fonts.Button
	goBtn.TextSize = 13
	goBtn.TextColor3 = Colors.White
	goBtn.Text = "Go"
	goBtn.AutoButtonColor = false
	goBtn.Parent = card
	createPillCorner(goBtn)
	
	goBtn.MouseEnter:Connect(function()
		tween(goBtn, TweenInfo.new(0.1), { BackgroundColor3 = Color3.new(color.R * 0.85, color.G * 0.85, color.B * 0.85) })
	end)
	goBtn.MouseLeave:Connect(function()
		tween(goBtn, TweenInfo.new(0.1), { BackgroundColor3 = color })
	end)
	
	goBtn.MouseButton1Click:Connect(function()
		self:showConfirmModal(activity, "activity")
	end)
end

function ActivitiesScreen:createCrimeSection(order)
	local section = Instance.new("Frame")
	section.Name = "CrimeSection"
	section.Size = UDim2.new(1, 0, 0, 0)
	section.AutomaticSize = Enum.AutomaticSize.Y
	section.BackgroundTransparency = 1
	section.LayoutOrder = order
	section.Parent = self.contentScroll
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.Parent = section
	
	-- Header
	local headerFrame = Instance.new("Frame")
	headerFrame.Size = UDim2.new(1, 0, 0, 44)
	headerFrame.BackgroundColor3 = Colors.CrimeRed
	headerFrame.LayoutOrder = 1
	headerFrame.Parent = section
	createUICorner(headerFrame, 12)
	
	local headerText = Instance.new("TextLabel")
	headerText.Size = UDim2.fromScale(1, 1)
	headerText.BackgroundTransparency = 1
	headerText.Font = Fonts.Title
	headerText.TextSize = 16
	headerText.TextColor3 = Colors.White
	headerText.Text = "🔪 Crime"
	headerText.Parent = headerFrame
	
	-- Warning
	local warning = Instance.new("Frame")
	warning.Size = UDim2.new(1, 0, 0, 40)
	warning.BackgroundColor3 = Color3.fromRGB(254, 243, 199)
	warning.LayoutOrder = 2
	warning.Parent = section
	createUICorner(warning, 10)
	
	local warnText = Instance.new("TextLabel")
	warnText.Size = UDim2.fromScale(1, 1)
	warnText.BackgroundTransparency = 1
	warnText.Font = Fonts.Body
	warnText.TextSize = 12
	warnText.TextColor3 = Color3.fromRGB(146, 64, 14)
	warnText.Text = "⚠️ Crime is risky! You could go to prison!"
	warnText.Parent = warning
	
	-- Crime cards
	for i, crime in ipairs(CrimeActivities) do
		self:createCrimeCard(crime, i + 2, section)
	end
end

function ActivitiesScreen:createCrimeCard(crime, order, parent)
	local card = Instance.new("Frame")
	card.Name = "Crime_" .. crime.name:gsub(" ", "_")
	card.Size = UDim2.new(1, 0, 0, 85)
	card.BackgroundColor3 = Colors.CardWhite
	card.LayoutOrder = order
	card.Parent = parent
	createUICorner(card, 14)
	createUIStroke(card, 1, 0.85, Color3.fromRGB(229, 231, 235))
	
	-- Emoji
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
	
	-- Risk
	local riskColor = crime.risk < 30 and Colors.MoneyGreen or crime.risk < 60 and Colors.EntertainmentOrange or Colors.CrimeRed
	local riskLabel = Instance.new("TextLabel")
	riskLabel.Size = UDim2.new(0, 80, 0, 14)
	riskLabel.Position = UDim2.new(0, 74, 0, 48)
	riskLabel.BackgroundTransparency = 1
	riskLabel.Font = Fonts.BodyMedium
	riskLabel.TextSize = 11
	riskLabel.TextColor3 = riskColor
	riskLabel.TextXAlignment = Enum.TextXAlignment.Left
	riskLabel.Text = "⚠️ " .. crime.risk .. "% Risk"
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
	rewardLabel.Text = "💰 " .. formatMoney(crime.reward[1]) .. " - " .. formatMoney(crime.reward[2])
	rewardLabel.Parent = card
	
	-- Commit button
	local commitBtn = Instance.new("TextButton")
	commitBtn.Size = UDim2.new(0, 70, 0, 36)
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
		tween(commitBtn, TweenInfo.new(0.1), { BackgroundColor3 = Colors.CrimeRedDark })
	end)
	commitBtn.MouseLeave:Connect(function()
		tween(commitBtn, TweenInfo.new(0.1), { BackgroundColor3 = Colors.CrimeRed })
	end)
	
	commitBtn.MouseButton1Click:Connect(function()
		self:showConfirmModal(crime, "crime")
	end)
end

function ActivitiesScreen:createConfirmModal()
	self.confirmOverlay = Instance.new("Frame")
	self.confirmOverlay.Name = "ConfirmOverlay"
	self.confirmOverlay.Size = UDim2.fromScale(1, 1)
	self.confirmOverlay.BackgroundColor3 = Colors.OverlayDark
	self.confirmOverlay.BackgroundTransparency = 0.4
	self.confirmOverlay.Visible = false
	self.confirmOverlay.ZIndex = 90
	self.confirmOverlay.Parent = self.screenGui
	
	self.confirmModal = Instance.new("Frame")
	self.confirmModal.Size = UDim2.new(0, 320, 0, 0)
	self.confirmModal.AutomaticSize = Enum.AutomaticSize.Y
	self.confirmModal.AnchorPoint = Vector2.new(0.5, 0.5)
	self.confirmModal.Position = UDim2.fromScale(0.5, 0.5)
	self.confirmModal.BackgroundColor3 = Colors.CardWhite
	self.confirmModal.ZIndex = 91
	self.confirmModal.Parent = self.confirmOverlay
	createUICorner(self.confirmModal, 20)
	
	createUIPadding(self.confirmModal, 24, 24, 24, 24)
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 16)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = self.confirmModal
	
	self.confirmEmoji = Instance.new("TextLabel")
	self.confirmEmoji.Size = UDim2.new(0, 60, 0, 60)
	self.confirmEmoji.BackgroundTransparency = 1
	self.confirmEmoji.Font = Fonts.Body
	self.confirmEmoji.TextSize = 50
	self.confirmEmoji.Text = "🎮"
	self.confirmEmoji.LayoutOrder = 1
	self.confirmEmoji.Parent = self.confirmModal
	
	self.confirmTitle = Instance.new("TextLabel")
	self.confirmTitle.Size = UDim2.new(1, 0, 0, 28)
	self.confirmTitle.BackgroundTransparency = 1
	self.confirmTitle.Font = Fonts.Title
	self.confirmTitle.TextSize = 20
	self.confirmTitle.TextColor3 = Colors.TextBlack
	self.confirmTitle.Text = "Activity Name"
	self.confirmTitle.LayoutOrder = 2
	self.confirmTitle.Parent = self.confirmModal
	
	self.confirmDesc = Instance.new("TextLabel")
	self.confirmDesc.Size = UDim2.new(1, 0, 0, 0)
	self.confirmDesc.AutomaticSize = Enum.AutomaticSize.Y
	self.confirmDesc.BackgroundTransparency = 1
	self.confirmDesc.Font = Fonts.Body
	self.confirmDesc.TextSize = 14
	self.confirmDesc.TextColor3 = Colors.DarkerGray
	self.confirmDesc.TextWrapped = true
	self.confirmDesc.Text = "Description here"
	self.confirmDesc.LayoutOrder = 3
	self.confirmDesc.Parent = self.confirmModal
	
	self.confirmCost = Instance.new("TextLabel")
	self.confirmCost.Size = UDim2.new(1, 0, 0, 24)
	self.confirmCost.BackgroundTransparency = 1
	self.confirmCost.Font = Fonts.Title
	self.confirmCost.TextSize = 16
	self.confirmCost.TextColor3 = Colors.MoneyGreen
	self.confirmCost.Text = ""
	self.confirmCost.LayoutOrder = 4
	self.confirmCost.Parent = self.confirmModal
	
	-- Buttons
	local btnContainer = Instance.new("Frame")
	btnContainer.Size = UDim2.new(1, 0, 0, 48)
	btnContainer.BackgroundTransparency = 1
	btnContainer.LayoutOrder = 5
	btnContainer.Parent = self.confirmModal
	
	local btnLayout = Instance.new("UIListLayout")
	btnLayout.FillDirection = Enum.FillDirection.Horizontal
	btnLayout.Padding = UDim.new(0, 12)
	btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	btnLayout.Parent = btnContainer
	
	local cancelBtn = Instance.new("TextButton")
	cancelBtn.Size = UDim2.new(0.45, 0, 1, 0)
	cancelBtn.BackgroundColor3 = Colors.LightGray
	cancelBtn.Font = Fonts.Button
	cancelBtn.TextSize = 15
	cancelBtn.TextColor3 = Colors.DarkGray
	cancelBtn.Text = "Cancel"
	cancelBtn.AutoButtonColor = false
	cancelBtn.Parent = btnContainer
	createPillCorner(cancelBtn)
	
	cancelBtn.MouseButton1Click:Connect(function()
		self:hideConfirmModal()
	end)
	
	self.confirmBtn = Instance.new("TextButton")
	self.confirmBtn.Size = UDim2.new(0.45, 0, 1, 0)
	self.confirmBtn.BackgroundColor3 = Colors.BitLifeBlue
	self.confirmBtn.Font = Fonts.Button
	self.confirmBtn.TextSize = 15
	self.confirmBtn.TextColor3 = Colors.White
	self.confirmBtn.Text = "Do It!"
	self.confirmBtn.AutoButtonColor = false
	self.confirmBtn.Parent = btnContainer
	createPillCorner(self.confirmBtn)
end

function ActivitiesScreen:createResultModal()
	self.resultOverlay = Instance.new("Frame")
	self.resultOverlay.Name = "ResultOverlay"
	self.resultOverlay.Size = UDim2.fromScale(1, 1)
	self.resultOverlay.BackgroundColor3 = Colors.OverlayDark
	self.resultOverlay.BackgroundTransparency = 0.5
	self.resultOverlay.Visible = false
	self.resultOverlay.ZIndex = 95
	self.resultOverlay.Parent = self.screenGui
	
	self.resultModal = Instance.new("Frame")
	self.resultModal.Size = UDim2.new(0, 320, 0, 0)
	self.resultModal.AutomaticSize = Enum.AutomaticSize.Y
	self.resultModal.AnchorPoint = Vector2.new(0.5, 0.5)
	self.resultModal.Position = UDim2.fromScale(0.5, 0.5)
	self.resultModal.BackgroundColor3 = Colors.CardWhite
	self.resultModal.ZIndex = 96
	self.resultModal.Parent = self.resultOverlay
	createUICorner(self.resultModal, 20)
	
	createUIPadding(self.resultModal, 24, 24, 24, 24)
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 16)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = self.resultModal
	
	self.resultEmoji = Instance.new("TextLabel")
	self.resultEmoji.Size = UDim2.new(0, 60, 0, 60)
	self.resultEmoji.BackgroundTransparency = 1
	self.resultEmoji.Font = Fonts.Body
	self.resultEmoji.TextSize = 50
	self.resultEmoji.Text = "✅"
	self.resultEmoji.LayoutOrder = 1
	self.resultEmoji.Parent = self.resultModal
	
	self.resultTitle = Instance.new("TextLabel")
	self.resultTitle.Size = UDim2.new(1, 0, 0, 28)
	self.resultTitle.BackgroundTransparency = 1
	self.resultTitle.Font = Fonts.Title
	self.resultTitle.TextSize = 20
	self.resultTitle.TextColor3 = Colors.TextBlack
	self.resultTitle.Text = "Result!"
	self.resultTitle.LayoutOrder = 2
	self.resultTitle.Parent = self.resultModal
	
	self.resultText = Instance.new("TextLabel")
	self.resultText.Size = UDim2.new(1, 0, 0, 0)
	self.resultText.AutomaticSize = Enum.AutomaticSize.Y
	self.resultText.BackgroundTransparency = 1
	self.resultText.Font = Fonts.Body
	self.resultText.TextSize = 15
	self.resultText.TextColor3 = Colors.DarkerGray
	self.resultText.TextWrapped = true
	self.resultText.Text = "Something happened!"
	self.resultText.LayoutOrder = 3
	self.resultText.Parent = self.resultModal
	
	self.resultStats = Instance.new("TextLabel")
	self.resultStats.Size = UDim2.new(1, 0, 0, 0)
	self.resultStats.AutomaticSize = Enum.AutomaticSize.Y
	self.resultStats.BackgroundTransparency = 1
	self.resultStats.Font = Fonts.BodyMedium
	self.resultStats.TextSize = 14
	self.resultStats.TextColor3 = Colors.MoneyGreen
	self.resultStats.Text = ""
	self.resultStats.LayoutOrder = 4
	self.resultStats.Parent = self.resultModal
	
	local okBtn = Instance.new("TextButton")
	okBtn.Size = UDim2.new(1, 0, 0, 48)
	okBtn.BackgroundColor3 = Colors.BitLifeBlue
	okBtn.Font = Fonts.Button
	okBtn.TextSize = 16
	okBtn.TextColor3 = Colors.White
	okBtn.Text = "OK"
	okBtn.AutoButtonColor = false
	okBtn.LayoutOrder = 5
	okBtn.Parent = self.resultModal
	createPillCorner(okBtn)
	
	okBtn.MouseButton1Click:Connect(function()
		self:hideResultModal()
	end)
end

function ActivitiesScreen:showConfirmModal(data, actType)
	self.currentActivity = data
	self.currentActivityType = actType
	
	self.confirmEmoji.Text = data.emoji
	self.confirmTitle.Text = data.name
	self.confirmDesc.Text = data.description
	
	if actType == "crime" then
		self.confirmCost.Text = "⚠️ " .. data.risk .. "% chance of getting caught!"
		self.confirmCost.TextColor3 = Colors.CrimeRed
		self.confirmBtn.Text = "Commit!"
		self.confirmBtn.BackgroundColor3 = Colors.CrimeRed
	elseif data.cost then
		self.confirmCost.Text = "💰 Cost: " .. formatMoney(data.cost)
		self.confirmCost.TextColor3 = Colors.MoneyGreen
		self.confirmBtn.Text = "Do It!"
		self.confirmBtn.BackgroundColor3 = Colors.BitLifeBlue
	else
		self.confirmCost.Text = ""
		self.confirmBtn.Text = "Do It!"
		self.confirmBtn.BackgroundColor3 = Colors.BitLifeBlue
	end
	
	-- Disconnect old connection
	if self.confirmConnection then
		self.confirmConnection:Disconnect()
	end
	
	self.confirmConnection = self.confirmBtn.MouseButton1Click:Connect(function()
		self:hideConfirmModal()
		task.delay(0.2, function()
			if actType == "crime" then
				self:performCrime(data)
			else
				self:performActivity(data)
			end
		end)
	end)
	
	self.confirmOverlay.Visible = true
	self.confirmModal.Position = UDim2.new(0.5, 0, 0.5, 30)
	tween(self.confirmModal, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.5)
	})
end

function ActivitiesScreen:hideConfirmModal()
	self.confirmOverlay.Visible = false
end

function ActivitiesScreen:performActivity(activity)
	-- Calculate stat changes
	local statChanges = {}
	if activity.effects then
		for stat, range in pairs(activity.effects) do
			local change = randomRange(range[1], range[2])
			if change ~= 0 then
				statChanges[stat] = change
			end
		end
	end
	
	-- Gambling special case
	if activity.gambling then
		local won = math.random() < 0.4
		if won then
			local winnings = randomRange(50, 500)
			self:showResult("🎰", "Jackpot!", "You won " .. formatMoney(winnings) .. "!", "+$" .. winnings, true)
		else
			self:showResult("🎰", "Better luck next time!", "You lost your bet.", "-$" .. activity.cost, false)
		end
		return
	end
	
	-- Get outcome text
	local outcomes = ActivityOutcomes[activity.name] or { "You did the activity!" }
	local outcomeText = randomFrom(outcomes)
	
	-- Build stats text
	local statsText = ""
	for stat, change in pairs(statChanges) do
		if change > 0 then
			statsText = statsText .. "+" .. change .. "% " .. stat .. "\n"
		end
	end
	if activity.cost then
		statsText = statsText .. "-$" .. activity.cost
	end
	
	self:showResult(activity.emoji, activity.name, outcomeText, statsText, true)
end

function ActivitiesScreen:performCrime(crime)
	local caught = math.random(100) <= crime.risk
	
	if caught then
		local jailTime = randomRange(crime.jailYears[1] * 12, crime.jailYears[2] * 12) / 12
		local jailText = jailTime < 1 and string.format("%.0f months", jailTime * 12) or string.format("%.1f years", jailTime)
		self:showResult("🚔", "BUSTED!", randomFrom(CrimeOutcomes.caught), "⛓️ Sentenced to " .. jailText .. " in prison!", false)
	else
		local reward = randomRange(crime.reward[1], crime.reward[2])
		self:showResult("💰", "Success!", randomFrom(CrimeOutcomes.success), "+$" .. formatMoney(reward), true)
	end
end

function ActivitiesScreen:showResult(emoji, title, text, stats, success)
	self.resultEmoji.Text = emoji
	self.resultTitle.Text = title
	self.resultTitle.TextColor3 = success and Colors.MoneyGreen or Colors.CrimeRed
	self.resultText.Text = text
	self.resultStats.Text = stats
	self.resultStats.TextColor3 = success and Colors.MoneyGreen or Colors.CrimeRed
	
	self.resultOverlay.Visible = true
	self.resultModal.Position = UDim2.new(0.5, 0, 0.5, 30)
	tween(self.resultModal, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.5)
	})
end

function ActivitiesScreen:hideResultModal()
	self.resultOverlay.Visible = false
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
	
	self.confirmOverlay.Visible = false
	self.resultOverlay.Visible = false
	
	local t = tween(self.overlay, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		Position = UDim2.new(1, 0, 0, 0)
	})
	t.Completed:Connect(function()
		self.overlay.Visible = false
	end)
end

function ActivitiesScreen:toggle()
	if self.isVisible then self:hide() else self:show() end
end

return ActivitiesScreen
