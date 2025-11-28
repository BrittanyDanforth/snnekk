-- ActivitiesScreen.lua
-- BitLife-style Activities screen with SERVER VALIDATION
-- Uses remotes - no more toddlers at nightclubs!

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ActivitiesScreen = {}
ActivitiesScreen.__index = ActivitiesScreen

----------------------------------------------------------------
-- REMOTES
----------------------------------------------------------------

local remotesFolder = ReplicatedStorage:WaitForChild("LifeRemotes", 10)
local DoActivity = remotesFolder and remotesFolder:FindFirstChild("DoActivity")
local CommitCrime = remotesFolder and remotesFolder:FindFirstChild("CommitCrime")
local Gamble = remotesFolder and remotesFolder:FindFirstChild("Gamble")

----------------------------------------------------------------
-- COLORS
----------------------------------------------------------------

local Colors = {
	BitLifeBlue      = Color3.fromRGB(37, 99, 235),
	ActivitiesPurple = Color3.fromRGB(139, 92, 246),
	ActivitiesPurpleDark = Color3.fromRGB(109, 40, 217),
	MindBodyGreen    = Color3.fromRGB(16, 185, 129),
	CrimeRed         = Color3.fromRGB(220, 38, 38),
	SocialBlue       = Color3.fromRGB(59, 130, 246),
	EntertainmentOrange = Color3.fromRGB(249, 115, 22),
	SuccessGreen     = Color3.fromRGB(34, 197, 94),
	ErrorRed         = Color3.fromRGB(239, 68, 68),
	White            = Color3.fromRGB(255, 255, 255),
	CardWhite        = Color3.fromRGB(255, 255, 255),
	LightGray        = Color3.fromRGB(243, 244, 246),
	MediumGray       = Color3.fromRGB(156, 163, 175),
	DarkGray         = Color3.fromRGB(75, 85, 99),
	DarkerGray       = Color3.fromRGB(55, 65, 81),
	TextBlack        = Color3.fromRGB(17, 24, 39),
	ScreenBg         = Color3.fromRGB(241, 245, 249),
	OverlayDark      = Color3.fromRGB(0, 0, 0),
	WarningYellow    = Color3.fromRGB(254, 243, 199),
	WarningText      = Color3.fromRGB(146, 64, 14),
}

local Fonts = {
	Title = Enum.Font.GothamBold,
	Body = Enum.Font.Gotham,
	BodyMedium = Enum.Font.GothamMedium,
	Button = Enum.Font.GothamBold,
}

----------------------------------------------------------------
-- DATA WITH AGE REQUIREMENTS
----------------------------------------------------------------

local MindBodyActivities = {
	{ id = "tv", name = "Watch TV", emoji = "📺", minAge = 2, cost = 0, desc = "Relax" },
	{ id = "read", name = "Read a Book", emoji = "📚", minAge = 5, cost = 0, desc = "+Smarts" },
	{ id = "games", name = "Play Video Games", emoji = "🎮", minAge = 5, cost = 0, desc = "Fun!" },
	{ id = "run", name = "Go for a Run", emoji = "🏃", minAge = 6, cost = 0, desc = "+Health" },
	{ id = "meditate", name = "Meditate", emoji = "🧘", minAge = 8, cost = 0, desc = "+Happiness" },
	{ id = "yoga", name = "Yoga", emoji = "🧘‍♀️", minAge = 10, cost = 0, desc = "+Health/Happy" },
	{ id = "salon", name = "Salon Visit", emoji = "💇", minAge = 12, cost = 80, desc = "+Looks" },
	{ id = "gym", name = "Go to the Gym", emoji = "🏋️", minAge = 14, cost = 0, desc = "+Health/Looks" },
	{ id = "spa", name = "Spa Day", emoji = "💆", minAge = 16, cost = 200, desc = "+Looks/Happy" },
}

local SocialActivities = {
	{ id = "hangout", name = "Hang Out", emoji = "👥", minAge = 5, cost = 0, desc = "With friends" },
	{ id = "party", name = "Go to a Party", emoji = "🎉", minAge = 14, cost = 0, desc = "Social!" },
	{ id = "host_party", name = "Host a Party", emoji = "🏠", minAge = 16, cost = 300, desc = "Be the host" },
	{ id = "nightclub", name = "Nightclub", emoji = "🕺", minAge = 21, cost = 50, desc = "21+ only!" },
}

local EntertainmentActivities = {
	{ id = "movies", name = "Go to Movies", emoji = "🎬", minAge = 5, cost = 20, desc = "Cinema" },
	{ id = "concert", name = "Concert", emoji = "🎸", minAge = 12, cost = 150, desc = "Live music!" },
	{ id = "vacation", name = "Vacation", emoji = "✈️", minAge = 5, cost = 2000, desc = "Travel!" },
	{ id = "casino", name = "Casino", emoji = "🎰", minAge = 21, cost = 100, desc = "Gambling" },
}

local CrimeActivities = {
	{ id = "shoplift", name = "Shoplift", emoji = "🛒", minAge = 8, risk = 25, reward = "$20-150" },
	{ id = "porch_pirate", name = "Porch Pirate", emoji = "📦", minAge = 10, risk = 20, reward = "$10-200" },
	{ id = "pickpocket", name = "Pickpocket", emoji = "👛", minAge = 10, risk = 35, reward = "$30-300" },
	{ id = "burglary", name = "Burglary", emoji = "🏠", minAge = 16, risk = 50, reward = "$500-5K" },
	{ id = "gta", name = "Grand Theft Auto", emoji = "🚗", minAge = 16, risk = 60, reward = "$2K-20K" },
	{ id = "bank_robbery", name = "Bank Robbery", emoji = "🏦", minAge = 18, risk = 80, reward = "$10K-500K" },
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
	if amount >= 1000 then return "$" .. string.format("%.0fK", amount / 1000) end
	return "$" .. amount
end

----------------------------------------------------------------
-- SCREEN
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

function ActivitiesScreen:getPlayerAge()
	return self.playerState and self.playerState.Age or 0
end

function ActivitiesScreen:getPlayerMoney()
	return self.playerState and self.playerState.Money or 0
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
	
	-- Info bar
	local infoBar = Instance.new("Frame")
	infoBar.Size = UDim2.new(1, -32, 0, 50)
	infoBar.Position = UDim2.new(0, 16, 0, 70)
	infoBar.BackgroundColor3 = Colors.CardWhite
	infoBar.ZIndex = 82
	infoBar.Parent = self.overlay
	createUICorner(infoBar, 12)
	createUIStroke(infoBar, 1, 0.8, Colors.ActivitiesPurple)
	
	self.infoLabel = Instance.new("TextLabel")
	self.infoLabel.Size = UDim2.fromScale(1, 1)
	self.infoLabel.BackgroundTransparency = 1
	self.infoLabel.Font = Fonts.BodyMedium
	self.infoLabel.TextSize = 14
	self.infoLabel.TextColor3 = Colors.ActivitiesPurple
	self.infoLabel.Text = "📅 Age: 0 | 💰 Money: $0"
	self.infoLabel.ZIndex = 83
	self.infoLabel.Parent = infoBar
	
	-- Content
	local contentScroll = Instance.new("ScrollingFrame")
	contentScroll.Size = UDim2.new(1, 0, 1, -130)
	contentScroll.Position = UDim2.new(0, 0, 0, 130)
	contentScroll.BackgroundTransparency = 1
	contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	contentScroll.ScrollBarThickness = 4
	contentScroll.ZIndex = 81
	contentScroll.Parent = self.overlay
	
	createUIPadding(contentScroll, 16, 16, 0, 16)
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 16)
	layout.Parent = contentScroll
	
	self.contentScroll = contentScroll
	
	self:createActivitySection("Mind & Body", "🧠", Colors.MindBodyGreen, MindBodyActivities, 1)
	self:createActivitySection("Social", "👥", Colors.SocialBlue, SocialActivities, 2)
	self:createActivitySection("Entertainment", "🎉", Colors.EntertainmentOrange, EntertainmentActivities, 3)
	self:createCrimeSection(4)
end

function ActivitiesScreen:updateInfoBar()
	local age = self:getPlayerAge()
	local money = self:getPlayerMoney()
	self.infoLabel.Text = "📅 Age: " .. age .. " | 💰 Money: " .. formatMoney(money)
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
	
	for i, activity in ipairs(activities) do
		self:createActivityCard(activity, color, i + 1, section)
	end
end

function ActivitiesScreen:createActivityCard(activity, color, order, parent)
	local card = Instance.new("Frame")
	card.Name = "Activity_" .. activity.id
	card.Size = UDim2.new(1, 0, 0, 60)
	card.BackgroundColor3 = Colors.CardWhite
	card.LayoutOrder = order
	card.Parent = parent
	createUICorner(card, 14)
	createUIStroke(card, 1, 0.85, Color3.fromRGB(229, 231, 235))
	
	local emoji = Instance.new("TextLabel")
	emoji.Size = UDim2.new(0, 36, 0, 36)
	emoji.Position = UDim2.new(0, 12, 0.5, -18)
	emoji.BackgroundTransparency = 1
	emoji.Font = Fonts.Body
	emoji.TextSize = 24
	emoji.Text = activity.emoji
	emoji.Parent = card
	
	local name = Instance.new("TextLabel")
	name.Size = UDim2.new(0.4, 0, 0, 18)
	name.Position = UDim2.new(0, 54, 0, 10)
	name.BackgroundTransparency = 1
	name.Font = Fonts.Title
	name.TextSize = 13
	name.TextColor3 = Colors.TextBlack
	name.TextXAlignment = Enum.TextXAlignment.Left
	name.Text = activity.name
	name.Parent = card
	
	local infoText = "Age " .. activity.minAge .. "+"
	if activity.cost and activity.cost > 0 then
		infoText = infoText .. " | " .. formatMoney(activity.cost)
	end
	if activity.desc then
		infoText = infoText .. " | " .. activity.desc
	end
	
	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(0.5, 0, 0, 14)
	info.Position = UDim2.new(0, 54, 0, 30)
	info.BackgroundTransparency = 1
	info.Font = Fonts.Body
	info.TextSize = 10
	info.TextColor3 = Colors.MediumGray
	info.TextXAlignment = Enum.TextXAlignment.Left
	info.Text = infoText
	info.Parent = card
	
	local goBtn = Instance.new("TextButton")
	goBtn.Size = UDim2.new(0, 50, 0, 28)
	goBtn.AnchorPoint = Vector2.new(1, 0.5)
	goBtn.Position = UDim2.new(1, -12, 0.5, 0)
	goBtn.BackgroundColor3 = color
	goBtn.Font = Fonts.Button
	goBtn.TextSize = 11
	goBtn.TextColor3 = Colors.White
	goBtn.Text = "Go"
	goBtn.AutoButtonColor = false
	goBtn.Parent = card
	createPillCorner(goBtn)
	
	goBtn.MouseButton1Click:Connect(function()
		self:showConfirm("activity", activity, color)
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
	warning.Size = UDim2.new(1, 0, 0, 36)
	warning.BackgroundColor3 = Colors.WarningYellow
	warning.LayoutOrder = 2
	warning.Parent = section
	createUICorner(warning, 10)
	
	local warnText = Instance.new("TextLabel")
	warnText.Size = UDim2.fromScale(1, 1)
	warnText.BackgroundTransparency = 1
	warnText.Font = Fonts.Body
	warnText.TextSize = 11
	warnText.TextColor3 = Colors.WarningText
	warnText.Text = "⚠️ Crime is risky! You could go to PRISON!"
	warnText.Parent = warning
	
	for i, crime in ipairs(CrimeActivities) do
		self:createCrimeCard(crime, i + 2, section)
	end
end

function ActivitiesScreen:createCrimeCard(crime, order, parent)
	local card = Instance.new("Frame")
	card.Name = "Crime_" .. crime.id
	card.Size = UDim2.new(1, 0, 0, 70)
	card.BackgroundColor3 = Colors.CardWhite
	card.LayoutOrder = order
	card.Parent = parent
	createUICorner(card, 14)
	createUIStroke(card, 1, 0.85, Color3.fromRGB(229, 231, 235))
	
	local emoji = Instance.new("TextLabel")
	emoji.Size = UDim2.new(0, 40, 0, 40)
	emoji.Position = UDim2.new(0, 12, 0.5, -20)
	emoji.BackgroundTransparency = 1
	emoji.Font = Fonts.Body
	emoji.TextSize = 26
	emoji.Text = crime.emoji
	emoji.Parent = card
	
	local name = Instance.new("TextLabel")
	name.Size = UDim2.new(0.4, 0, 0, 18)
	name.Position = UDim2.new(0, 58, 0, 10)
	name.BackgroundTransparency = 1
	name.Font = Fonts.Title
	name.TextSize = 13
	name.TextColor3 = Colors.TextBlack
	name.TextXAlignment = Enum.TextXAlignment.Left
	name.Text = crime.name
	name.Parent = card
	
	local riskColor = crime.risk < 30 and Colors.SuccessGreen or crime.risk < 60 and Colors.EntertainmentOrange or Colors.CrimeRed
	local risk = Instance.new("TextLabel")
	risk.Size = UDim2.new(0.5, 0, 0, 14)
	risk.Position = UDim2.new(0, 58, 0, 28)
	risk.BackgroundTransparency = 1
	risk.Font = Fonts.BodyMedium
	risk.TextSize = 11
	risk.TextColor3 = riskColor
	risk.TextXAlignment = Enum.TextXAlignment.Left
	risk.Text = "⚠️ " .. crime.risk .. "% Risk | Age " .. crime.minAge .. "+"
	risk.Parent = card
	
	local reward = Instance.new("TextLabel")
	reward.Size = UDim2.new(0.5, 0, 0, 14)
	reward.Position = UDim2.new(0, 58, 0, 44)
	reward.BackgroundTransparency = 1
	reward.Font = Fonts.Body
	reward.TextSize = 10
	reward.TextColor3 = Colors.SuccessGreen
	reward.TextXAlignment = Enum.TextXAlignment.Left
	reward.Text = "💰 " .. crime.reward
	reward.Parent = card
	
	local commitBtn = Instance.new("TextButton")
	commitBtn.Size = UDim2.new(0, 60, 0, 30)
	commitBtn.AnchorPoint = Vector2.new(1, 0.5)
	commitBtn.Position = UDim2.new(1, -12, 0.5, 0)
	commitBtn.BackgroundColor3 = Colors.CrimeRed
	commitBtn.Font = Fonts.Button
	commitBtn.TextSize = 11
	commitBtn.TextColor3 = Colors.White
	commitBtn.Text = "Commit"
	commitBtn.AutoButtonColor = false
	commitBtn.Parent = card
	createPillCorner(commitBtn)
	
	commitBtn.MouseButton1Click:Connect(function()
		self:showConfirm("crime", crime, Colors.CrimeRed)
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
	layout.Padding = UDim.new(0, 12)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = self.confirmModal
	
	self.confirmEmoji = Instance.new("TextLabel")
	self.confirmEmoji.Size = UDim2.new(0, 50, 0, 50)
	self.confirmEmoji.BackgroundTransparency = 1
	self.confirmEmoji.Font = Fonts.Body
	self.confirmEmoji.TextSize = 40
	self.confirmEmoji.Text = "🎮"
	self.confirmEmoji.LayoutOrder = 1
	self.confirmEmoji.Parent = self.confirmModal
	
	self.confirmTitle = Instance.new("TextLabel")
	self.confirmTitle.Size = UDim2.new(1, 0, 0, 24)
	self.confirmTitle.BackgroundTransparency = 1
	self.confirmTitle.Font = Fonts.Title
	self.confirmTitle.TextSize = 18
	self.confirmTitle.TextColor3 = Colors.TextBlack
	self.confirmTitle.Text = "Do Activity?"
	self.confirmTitle.LayoutOrder = 2
	self.confirmTitle.Parent = self.confirmModal
	
	self.confirmInfo = Instance.new("TextLabel")
	self.confirmInfo.Size = UDim2.new(1, 0, 0, 0)
	self.confirmInfo.AutomaticSize = Enum.AutomaticSize.Y
	self.confirmInfo.BackgroundTransparency = 1
	self.confirmInfo.Font = Fonts.Body
	self.confirmInfo.TextSize = 13
	self.confirmInfo.TextColor3 = Colors.DarkGray
	self.confirmInfo.TextWrapped = true
	self.confirmInfo.Text = ""
	self.confirmInfo.LayoutOrder = 3
	self.confirmInfo.Parent = self.confirmModal
	
	local btnContainer = Instance.new("Frame")
	btnContainer.Size = UDim2.new(1, 0, 0, 44)
	btnContainer.BackgroundTransparency = 1
	btnContainer.LayoutOrder = 4
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
	cancelBtn.TextSize = 14
	cancelBtn.TextColor3 = Colors.DarkGray
	cancelBtn.Text = "Cancel"
	cancelBtn.AutoButtonColor = false
	cancelBtn.Parent = btnContainer
	createPillCorner(cancelBtn)
	cancelBtn.MouseButton1Click:Connect(function() self:hideConfirm() end)
	
	self.confirmBtn = Instance.new("TextButton")
	self.confirmBtn.Size = UDim2.new(0.45, 0, 1, 0)
	self.confirmBtn.BackgroundColor3 = Colors.BitLifeBlue
	self.confirmBtn.Font = Fonts.Button
	self.confirmBtn.TextSize = 14
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
	self.resultEmoji.Size = UDim2.new(0, 50, 0, 50)
	self.resultEmoji.BackgroundTransparency = 1
	self.resultEmoji.Font = Fonts.Body
	self.resultEmoji.TextSize = 40
	self.resultEmoji.Text = "✅"
	self.resultEmoji.LayoutOrder = 1
	self.resultEmoji.Parent = self.resultModal
	
	self.resultTitle = Instance.new("TextLabel")
	self.resultTitle.Size = UDim2.new(1, 0, 0, 24)
	self.resultTitle.BackgroundTransparency = 1
	self.resultTitle.Font = Fonts.Title
	self.resultTitle.TextSize = 18
	self.resultTitle.TextColor3 = Colors.SuccessGreen
	self.resultTitle.Text = "Success!"
	self.resultTitle.LayoutOrder = 2
	self.resultTitle.Parent = self.resultModal
	
	self.resultText = Instance.new("TextLabel")
	self.resultText.Size = UDim2.new(1, 0, 0, 0)
	self.resultText.AutomaticSize = Enum.AutomaticSize.Y
	self.resultText.BackgroundTransparency = 1
	self.resultText.Font = Fonts.Body
	self.resultText.TextSize = 14
	self.resultText.TextColor3 = Colors.DarkerGray
	self.resultText.TextWrapped = true
	self.resultText.Text = ""
	self.resultText.LayoutOrder = 3
	self.resultText.Parent = self.resultModal
	
	local okBtn = Instance.new("TextButton")
	okBtn.Size = UDim2.new(1, 0, 0, 44)
	okBtn.BackgroundColor3 = Colors.BitLifeBlue
	okBtn.Font = Fonts.Button
	okBtn.TextSize = 15
	okBtn.TextColor3 = Colors.White
	okBtn.Text = "OK"
	okBtn.AutoButtonColor = false
	okBtn.LayoutOrder = 4
	okBtn.Parent = self.resultModal
	createPillCorner(okBtn)
	okBtn.MouseButton1Click:Connect(function() self:hideResult() end)
end

function ActivitiesScreen:showConfirm(actionType, data, color)
	self.currentType = actionType
	self.currentData = data
	
	local age = self:getPlayerAge()
	local money = self:getPlayerMoney()
	local canDo = age >= data.minAge
	local canAfford = not data.cost or money >= data.cost
	
	self.confirmEmoji.Text = data.emoji
	self.confirmTitle.Text = data.name
	
	if actionType == "crime" then
		self.confirmInfo.Text = "⚠️ " .. data.risk .. "% chance of getting caught!\nPotential reward: " .. data.reward .. "\nYour age: " .. age .. " (Req: " .. data.minAge .. "+)"
		self.confirmBtn.Text = canDo and "Commit!" or "Age " .. data.minAge .. "+"
		self.confirmBtn.BackgroundColor3 = canDo and Colors.CrimeRed or Colors.MediumGray
	else
		local infoText = "Your age: " .. age .. " (Req: " .. data.minAge .. "+)"
		if data.cost and data.cost > 0 then
			infoText = infoText .. "\nCost: " .. formatMoney(data.cost) .. " | Your cash: " .. formatMoney(money)
		end
		self.confirmInfo.Text = infoText
		
		if not canDo then
			self.confirmBtn.Text = "Age " .. data.minAge .. "+"
			self.confirmBtn.BackgroundColor3 = Colors.MediumGray
		elseif not canAfford then
			self.confirmBtn.Text = "Can't Afford"
			self.confirmBtn.BackgroundColor3 = Colors.MediumGray
		else
			self.confirmBtn.Text = "Do It!"
			self.confirmBtn.BackgroundColor3 = color
		end
	end
	
	if self.confirmConn then self.confirmConn:Disconnect() end
	self.confirmConn = self.confirmBtn.MouseButton1Click:Connect(function()
		if (actionType == "crime" and canDo) or (canDo and canAfford) then
			self:hideConfirm()
			task.delay(0.2, function()
				self:executeAction()
			end)
		end
	end)
	
	self.confirmOverlay.Visible = true
	tween(self.confirmModal, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.fromScale(0.5, 0.5) })
end

function ActivitiesScreen:hideConfirm()
	self.confirmOverlay.Visible = false
end

function ActivitiesScreen:executeAction()
	local result
	
	if self.currentType == "crime" then
		if CommitCrime then
			result = CommitCrime:InvokeServer(self.currentData.id)
		else
			result = { success = false, message = "Server not available" }
		end
	elseif self.currentData.id == "casino" then
		if Gamble then
			result = Gamble:InvokeServer(100)
		else
			result = { success = false, message = "Server not available" }
		end
	else
		if DoActivity then
			result = DoActivity:InvokeServer(self.currentData.id)
		else
			result = { success = false, message = "Server not available" }
		end
	end
	
	self:showResult(result)
end

function ActivitiesScreen:showResult(result)
	local isGood = result.success and not result.caught
	
	if result.caught then
		self.resultEmoji.Text = "🚔"
		self.resultTitle.Text = "BUSTED!"
		self.resultTitle.TextColor3 = Colors.CrimeRed
	elseif result.success then
		self.resultEmoji.Text = self.currentType == "crime" and "💰" or "✅"
		self.resultTitle.Text = "Success!"
		self.resultTitle.TextColor3 = Colors.SuccessGreen
	else
		self.resultEmoji.Text = "❌"
		self.resultTitle.Text = "Failed"
		self.resultTitle.TextColor3 = Colors.ErrorRed
	end
	
	self.resultText.Text = result.message or ""
	
	self.resultOverlay.Visible = true
	tween(self.resultModal, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.fromScale(0.5, 0.5) })
	
	self:updateInfoBar()
end

function ActivitiesScreen:hideResult()
	self.resultOverlay.Visible = false
end

function ActivitiesScreen:show()
	if self.isVisible then return end
	self.isVisible = true
	self:updateInfoBar()
	self.overlay.Visible = true
	self.overlay.Position = UDim2.new(1, 0, 0, 0)
	tween(self.overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.new(0, 0, 0, 0) })
end

function ActivitiesScreen:hide()
	if not self.isVisible then return end
	self.isVisible = false
	self.confirmOverlay.Visible = false
	self.resultOverlay.Visible = false
	local t = tween(self.overlay, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Position = UDim2.new(1, 0, 0, 0) })
	t.Completed:Connect(function() self.overlay.Visible = false end)
end

function ActivitiesScreen:toggle()
	if self.isVisible then self:hide() else self:show() end
end

return ActivitiesScreen
