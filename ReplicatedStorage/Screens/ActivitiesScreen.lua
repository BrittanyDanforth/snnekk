-- ActivitiesScreen.lua
-- Premium AAA-quality Activities screen with minigames

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ActivitiesScreen = {}
ActivitiesScreen.__index = ActivitiesScreen

local remotesFolder = ReplicatedStorage:WaitForChild("LifeRemotes", 30)
local DoActivity = remotesFolder and remotesFolder:WaitForChild("DoActivity", 15)
local CommitCrime = remotesFolder and remotesFolder:WaitForChild("CommitCrime", 15)
local Gamble = remotesFolder and remotesFolder:WaitForChild("Gamble", 15)
local DoPrisonAction = remotesFolder and remotesFolder:WaitForChild("DoPrisonAction", 15)

print("[ActivitiesScreen] Remotes loaded:", DoActivity and "✓" or "✗", CommitCrime and "✓" or "✗")

-- Premium Colors
local C = {
	Amber = Color3.fromRGB(245, 158, 11),
	AmberDark = Color3.fromRGB(217, 119, 6),
	AmberPale = Color3.fromRGB(254, 243, 199),
	AmberLight = Color3.fromRGB(253, 230, 138),
	Blue = Color3.fromRGB(37, 99, 235),
	BlueDark = Color3.fromRGB(29, 78, 216),
	BluePale = Color3.fromRGB(219, 234, 254),
	Green = Color3.fromRGB(34, 197, 94),
	GreenDark = Color3.fromRGB(22, 163, 74),
	GreenPale = Color3.fromRGB(220, 252, 231),
	Purple = Color3.fromRGB(139, 92, 246),
	PurpleDark = Color3.fromRGB(124, 58, 237),
	PurplePale = Color3.fromRGB(237, 233, 254),
	Red = Color3.fromRGB(239, 68, 68),
	RedDark = Color3.fromRGB(220, 38, 38),
	RedPale = Color3.fromRGB(254, 226, 226),
	Pink = Color3.fromRGB(236, 72, 153),
	PinkPale = Color3.fromRGB(252, 231, 243),
	Cyan = Color3.fromRGB(6, 182, 212),
	CyanDark = Color3.fromRGB(8, 145, 178),
	CyanPale = Color3.fromRGB(207, 250, 254),
	White = Color3.fromRGB(255, 255, 255),
	Gray50 = Color3.fromRGB(249, 250, 251),
	Gray100 = Color3.fromRGB(243, 244, 246),
	Gray200 = Color3.fromRGB(229, 231, 235),
	Gray300 = Color3.fromRGB(209, 213, 219),
	Gray400 = Color3.fromRGB(156, 163, 175),
	Gray500 = Color3.fromRGB(107, 114, 128),
	Gray600 = Color3.fromRGB(75, 85, 99),
	Gray700 = Color3.fromRGB(55, 65, 81),
	Gray800 = Color3.fromRGB(31, 41, 55),
	Gray900 = Color3.fromRGB(17, 24, 39),
	Black = Color3.fromRGB(0, 0, 0),
	Bg = Color3.fromRGB(248, 250, 252),
}

local F = { Title = Enum.Font.GothamBold, Body = Enum.Font.Gotham, Medium = Enum.Font.GothamMedium, Button = Enum.Font.GothamBold }

-- Activity Data
local MindBody = {
	{ id = "gym", name = "Hit the Gym", emoji = "🏋️", effect = "+Health +Looks", minAge = 12, cost = 0, hasMinigame = true },
	{ id = "meditate", name = "Meditate", emoji = "🧘", effect = "+Happiness +Health", minAge = 10, cost = 0 },
	{ id = "study", name = "Study Hard", emoji = "📚", effect = "+Smarts", minAge = 6, cost = 0, hasMinigame = true },
	{ id = "spa", name = "Spa Day", emoji = "💆", effect = "+Looks +Happiness", minAge = 16, cost = 200 },
	{ id = "walk", name = "Go for Walk", emoji = "🚶", effect = "+Health +Happiness", minAge = 5, cost = 0 },
	{ id = "martial_arts", name = "Martial Arts", emoji = "🥋", effect = "+Health +Smarts", minAge = 8, cost = 100 },
	{ id = "yoga", name = "Yoga Class", emoji = "🧘‍♀️", effect = "+Health +Looks", minAge = 14, cost = 50 },
	{ id = "read", name = "Read a Book", emoji = "📖", effect = "+Smarts +Happiness", minAge = 6, cost = 0 },
}

local Social = {
	{ id = "party", name = "Go to Party", emoji = "🎉", effect = "+Happiness", minAge = 16, cost = 0 },
	{ id = "date", name = "Go on Date", emoji = "💕", effect = "+Happiness", minAge = 16, cost = 100 },
	{ id = "club", name = "Night Club", emoji = "🕺", effect = "+Happiness -Health", minAge = 21, cost = 150 },
	{ id = "hangout", name = "Hang with Friends", emoji = "👥", effect = "+Happiness", minAge = 5, cost = 0 },
	{ id = "volunteer", name = "Volunteer", emoji = "🤝", effect = "+Happiness +Smarts", minAge = 12, cost = 0 },
	{ id = "networking", name = "Networking Event", emoji = "🤵", effect = "+Smarts", minAge = 18, cost = 50 },
}

local Entertainment = {
	{ id = "movie", name = "Watch Movie", emoji = "🎬", effect = "+Happiness", minAge = 5, cost = 20 },
	{ id = "concert", name = "Go to Concert", emoji = "🎤", effect = "+Happiness", minAge = 12, cost = 100 },
	{ id = "vacation", name = "Take Vacation", emoji = "✈️", effect = "+Happiness +Health", minAge = 10, cost = 2000 },
	{ id = "gaming", name = "Play Games", emoji = "🎮", effect = "+Happiness", minAge = 5, cost = 0 },
	{ id = "camping", name = "Go Camping", emoji = "🏕️", effect = "+Happiness +Health", minAge = 8, cost = 300 },
	{ id = "museum", name = "Visit Museum", emoji = "🏛️", effect = "+Smarts", minAge = 6, cost = 25 },
	{ id = "theme_park", name = "Theme Park", emoji = "🎢", effect = "+Happiness", minAge = 8, cost = 150 },
}

local Crimes = {
	{ id = "shoplift", name = "Shoplift", emoji = "🛒", risk = 30, reward = "$50-$200", minAge = 10 },
	{ id = "pickpocket", name = "Pickpocket", emoji = "👛", risk = 45, reward = "$100-$500", minAge = 12 },
	{ id = "burglary", name = "Burglary", emoji = "🏠", risk = 60, reward = "$500-$5K", minAge = 16 },
	{ id = "robbery", name = "Armed Robbery", emoji = "🔫", risk = 80, reward = "$5K-$50K", minAge = 18 },
	{ id = "car_theft", name = "Grand Theft Auto", emoji = "🚗", risk = 65, reward = "$5K-$25K", minAge = 16 },
	{ id = "drug_deal", name = "Drug Deal", emoji = "💊", risk = 55, reward = "$1K-$10K", minAge = 16 },
	{ id = "bank_heist", name = "Bank Heist", emoji = "🏦", risk = 95, reward = "$50K-$500K", minAge = 21, hasMinigame = true },
}

-- PRISON ACTIVITIES (shown when in jail)
local PrisonActivities = {
	{ id = "prison_escape", name = "Escape Prison", emoji = "🔐", effect = "Freedom!", minAge = 0, risk = 90, hasMinigame = true },
	{ id = "prison_workout", name = "Yard Workout", emoji = "💪", effect = "+Health +Looks", minAge = 0 },
	{ id = "prison_study", name = "Get GED", emoji = "📚", effect = "+Smarts", minAge = 0 },
	{ id = "prison_gang", name = "Join Prison Gang", emoji = "⛓️", effect = "+Respect -Health", minAge = 0 },
	{ id = "prison_riot", name = "Start Riot", emoji = "🔥", effect = "Dangerous!", minAge = 0, risk = 85 },
	{ id = "prison_snitch", name = "Snitch", emoji = "🐀", effect = "-Sentence +Risk", minAge = 0 },
	{ id = "prison_appeal", name = "Appeal Sentence", emoji = "⚖️", effect = "Legal Help", minAge = 0, cost = 5000 },
	{ id = "prison_goodbehavior", name = "Good Behavior", emoji = "😇", effect = "-Sentence Time", minAge = 0 },
}

-- Helpers
local function corner(p, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r); c.Parent = p; return c end
local function pill(p) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0.5, 0); c.Parent = p; return c end
local function stroke(p, t, tr, col) local s = Instance.new("UIStroke"); s.Thickness = t; s.Transparency = tr or 0; s.Color = col or C.White; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = p; return s end
local function pad(p, l, r, t, b) local pd = Instance.new("UIPadding"); pd.PaddingLeft = UDim.new(0, l or 0); pd.PaddingRight = UDim.new(0, r or 0); pd.PaddingTop = UDim.new(0, t or 0); pd.PaddingBottom = UDim.new(0, b or 0); pd.Parent = p; return pd end
local function tween(o, i, p) local t = TweenService:Create(o, i, p); t:Play(); return t end

local function formatMoney(n)
	if n >= 1000000 then return "$" .. string.format("%.1f", n/1000000) .. "M"
	elseif n >= 1000 then return "$" .. string.format("%.0f", n/1000) .. "K"
	else return "$" .. n end
end

function ActivitiesScreen.new(screenGui, blurOverlay, showBlurFunc, hideBlurFunc, playerState)
	local self = setmetatable({}, ActivitiesScreen)
	self.screenGui = screenGui
	self.playerState = playerState
	self.showBlur = showBlurFunc
	self.hideBlur = hideBlurFunc
	self.isVisible = false
	self.currentTab = "mindbody"
	self:createUI()
	self:createResultModal()
	self:createMinigameModal()
	return self
end

function ActivitiesScreen:updateState(newState)
	if newState then self.playerState = newState end
end

function ActivitiesScreen:getAge()
	local state = self.playerState
	if not state then return 0 end
	return state.Age or (state.Stats and state.Stats.Age) or 0
end

function ActivitiesScreen:getMoney()
	local state = self.playerState
	if not state then return 0 end
	return state.Money or (state.Stats and state.Stats.Money) or 0
end

function ActivitiesScreen:isInJail()
	local state = self.playerState
	if not state then return false end
	return state.InJail or (state.Flags and state.Flags.in_prison) or false
end

function ActivitiesScreen:createUI()
	self.overlay = Instance.new("Frame")
	self.overlay.Name = "ActivitiesOverlay"
	self.overlay.Size = UDim2.fromScale(1, 1)
	self.overlay.BackgroundColor3 = C.Bg
	self.overlay.Visible = false
	self.overlay.ZIndex = 80
	self.overlay.Parent = self.screenGui
	
	-- Header (offset down for Roblox UI)
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, -16, 0, 60)
	header.Position = UDim2.new(0, 8, 0, 44)
	header.BackgroundColor3 = C.Amber
	header.ZIndex = 85
	header.Parent = self.overlay
	corner(header, 18)
	
	local hGrad = Instance.new("UIGradient")
	hGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, C.Amber), ColorSequenceKeypoint.new(1, C.AmberDark) })
	hGrad.Rotation = 90
	hGrad.Parent = header
	
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -100, 1, 0)
	title.Position = UDim2.new(0, 20, 0, 0)
	title.BackgroundTransparency = 1
	title.Font = F.Title
	title.TextSize = 20
	title.TextColor3 = C.White
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = "🎭 Activities"
	title.ZIndex = 86
	title.Parent = header
	
	-- Close button (clean X)
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 40, 0, 40)
	closeBtn.AnchorPoint = Vector2.new(1, 0.5)
	closeBtn.Position = UDim2.new(1, -10, 0.5, 0)
	closeBtn.BackgroundColor3 = C.White
	closeBtn.BackgroundTransparency = 0.1
	closeBtn.Font = F.Title
	closeBtn.TextSize = 18
	closeBtn.TextColor3 = C.AmberDark
	closeBtn.Text = "X"
	closeBtn.AutoButtonColor = false
	closeBtn.ZIndex = 86
	closeBtn.Parent = header
	corner(closeBtn, 20)
	
	closeBtn.MouseButton1Click:Connect(function() self:hide() end)
	closeBtn.MouseEnter:Connect(function() tween(closeBtn, TweenInfo.new(0.1), { BackgroundTransparency = 0 }) end)
	closeBtn.MouseLeave:Connect(function() tween(closeBtn, TweenInfo.new(0.1), { BackgroundTransparency = 0.1 }) end)
	
	-- Info bar (adjusted for header offset)
	self.contentTopOffset = 44 + 60 + 8 -- header offset + height + spacing
	
	self.infoBar = Instance.new("Frame")
	self.infoBar.Size = UDim2.new(1, -20, 0, 48)
	self.infoBar.Position = UDim2.new(0, 10, 0, self.contentTopOffset)
	self.infoBar.BackgroundColor3 = C.White
	self.infoBar.ZIndex = 84
	self.infoBar.Parent = self.overlay
	corner(self.infoBar, 14)
	stroke(self.infoBar, 1, 0.92, C.Gray200)
	
	local infoLayout = Instance.new("UIListLayout")
	infoLayout.FillDirection = Enum.FillDirection.Horizontal
	infoLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	infoLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	infoLayout.Padding = UDim.new(0, 12)
	infoLayout.Parent = self.infoBar
	
	self.ageChip = self:createInfoChip(self.infoBar, "👤", "Age 0", C.BluePale, C.Blue, 1)
	self.moneyChip = self:createInfoChip(self.infoBar, "💵", "$0", C.GreenPale, C.GreenDark, 2)
	self.statusChip = self:createInfoChip(self.infoBar, "✓", "Free", C.GreenPale, C.GreenDark, 3)
	
	-- Tab bar
	local tabBar = Instance.new("Frame")
	tabBar.Size = UDim2.new(1, -20, 0, 46)
	tabBar.Position = UDim2.new(0, 10, 0, self.contentTopOffset + 56)
	tabBar.BackgroundColor3 = C.Gray100
	tabBar.ZIndex = 84
	tabBar.Parent = self.overlay
	corner(tabBar, 14)
	
	pad(tabBar, 4, 4, 4, 4)
	
	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	tabLayout.Padding = UDim.new(0, 4)
	tabLayout.Parent = tabBar
	
	self.tabBtns = {}
	self.tabBar = tabBar  -- Store reference for dynamic updates
	self.currentTab = "mindbody"  -- Set default tab
	
	self:rebuildTabs()
	self:createContentScroll()
	self:populateMindBody()
end

function ActivitiesScreen:rebuildTabs()
	-- Clear existing tabs
	for _, child in ipairs(self.tabBar:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	self.tabBtns = {}
	
	local inJail = self:isInJail()
	local tabs
	
	if inJail then
		-- Show Prison tab prominently when in jail
		tabs = {
			{ id = "prison", text = "⛓️ Prison", color = C.Gray700 },
			{ id = "mindbody", text = "💪 Exercise", color = C.Cyan },
		}
		self.currentTab = "prison"
	else
		tabs = {
			{ id = "mindbody", text = "🧘 Mind", color = C.Cyan },
			{ id = "social", text = "🎉 Social", color = C.Pink },
			{ id = "fun", text = "🎬 Fun", color = C.Purple },
			{ id = "crime", text = "💀 Crime", color = C.Red },
		}
		-- Only set default if not already set
		if not self.currentTab then
			self.currentTab = "mindbody"
		end
	end
	
	local tabWidth = 1 / #tabs - 0.01
	
	for i, tab in ipairs(tabs) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(tabWidth, 0, 1, 0)
		btn.BackgroundColor3 = i == 1 and tab.color or C.White
		btn.Font = F.Button
		btn.TextSize = 11
		btn.TextColor3 = i == 1 and C.White or C.Gray600
		btn.Text = tab.text
		btn.AutoButtonColor = false
		btn.LayoutOrder = i
		btn.ZIndex = 85
		btn.Parent = self.tabBar
		corner(btn, 10)
		
		self.tabBtns[tab.id] = { btn = btn, color = tab.color }
		btn.MouseButton1Click:Connect(function() self:switchTab(tab.id) end)
	end
end

function ActivitiesScreen:createContentScroll()
	-- Only create once
	if self.contentScroll then return end
	
	-- Content
	local scrollTop = self.contentTopOffset + 56 + 54 -- info bar + tab bar + spacing
	self.contentScroll = Instance.new("ScrollingFrame")
	self.contentScroll.Size = UDim2.new(1, -20, 1, -(scrollTop + 12))
	self.contentScroll.Position = UDim2.new(0, 10, 0, scrollTop)
	self.contentScroll.BackgroundTransparency = 1
	self.contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	self.contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	self.contentScroll.ScrollBarThickness = 4
	self.contentScroll.ScrollBarImageColor3 = C.Gray300
	self.contentScroll.ZIndex = 81
	self.contentScroll.Parent = self.overlay
	
	self.contentLayout = Instance.new("UIListLayout")
	self.contentLayout.Padding = UDim.new(0, 12)
	self.contentLayout.Parent = self.contentScroll
end

function ActivitiesScreen:createInfoChip(parent, icon, text, bgColor, textColor, order)
	local chip = Instance.new("Frame")
	chip.Size = UDim2.new(0, 95, 0, 36)
	chip.BackgroundColor3 = bgColor
	chip.LayoutOrder = order
	chip.ZIndex = 85
	chip.Parent = parent
	corner(chip, 10)
	
	local iconLbl = Instance.new("TextLabel")
	iconLbl.Size = UDim2.new(0, 26, 1, 0)
	iconLbl.Position = UDim2.new(0, 8, 0, 0)
	iconLbl.BackgroundTransparency = 1
	iconLbl.Font = F.Body
	iconLbl.TextSize = 15
	iconLbl.Text = icon
	iconLbl.ZIndex = 86
	iconLbl.Parent = chip
	
	local textLbl = Instance.new("TextLabel")
	textLbl.Name = "Text"
	textLbl.Size = UDim2.new(1, -36, 1, 0)
	textLbl.Position = UDim2.new(0, 32, 0, 0)
	textLbl.BackgroundTransparency = 1
	textLbl.Font = F.Button
	textLbl.TextSize = 12
	textLbl.TextColor3 = textColor
	textLbl.TextXAlignment = Enum.TextXAlignment.Left
	textLbl.Text = text
	textLbl.ZIndex = 86
	textLbl.Parent = chip
	
	return chip
end

function ActivitiesScreen:updateInfoBar()
	local ageText = self.ageChip:FindFirstChild("Text")
	local moneyText = self.moneyChip:FindFirstChild("Text")
	local statusText = self.statusChip:FindFirstChild("Text")
	
	if ageText then ageText.Text = "Age " .. self:getAge() end
	if moneyText then moneyText.Text = formatMoney(self:getMoney()) end
	if statusText then 
		local inJail = self:isInJail()
		statusText.Text = inJail and "In Jail" or "Free"
		self.statusChip.BackgroundColor3 = inJail and C.RedPale or C.GreenPale
		statusText.TextColor3 = inJail and C.RedDark or C.GreenDark
	end
end

function ActivitiesScreen:switchTab(tabId)
	self.currentTab = tabId
	
	for id, data in pairs(self.tabBtns) do
		local isActive = id == tabId
		tween(data.btn, TweenInfo.new(0.15), {
			BackgroundColor3 = isActive and data.color or C.White,
			TextColor3 = isActive and C.White or C.Gray600
		})
	end
	
	-- Clear content - ensure contentScroll exists
	if self.contentScroll then
		for _, child in ipairs(self.contentScroll:GetChildren()) do
			if child:IsA("Frame") then child:Destroy() end
		end
	end
	
	if tabId == "prison" then self:populatePrison()
	elseif tabId == "mindbody" then self:populateMindBody()
	elseif tabId == "social" then self:populateSocial()
	elseif tabId == "fun" then self:populateFun()
	elseif tabId == "crime" then self:populateCrime() end
end

-- PRISON ACTIVITIES TAB
function ActivitiesScreen:populatePrison()
	-- Prison status header
	local headerCard = Instance.new("Frame")
	headerCard.Size = UDim2.new(1, 0, 0, 80)
	headerCard.BackgroundColor3 = C.Gray800
	headerCard.LayoutOrder = 0
	headerCard.ZIndex = 82
	headerCard.Parent = self.contentScroll
	corner(headerCard, 16)
	
	local headerIcon = Instance.new("TextLabel")
	headerIcon.Size = UDim2.new(0, 50, 0, 50)
	headerIcon.Position = UDim2.new(0, 14, 0.5, -25)
	headerIcon.BackgroundTransparency = 1
	headerIcon.Font = F.Body
	headerIcon.TextSize = 36
	headerIcon.Text = "⛓️"
	headerIcon.ZIndex = 83
	headerIcon.Parent = headerCard
	
	local headerText = Instance.new("TextLabel")
	headerText.Size = UDim2.new(1, -80, 0, 24)
	headerText.Position = UDim2.new(0, 70, 0, 14)
	headerText.BackgroundTransparency = 1
	headerText.Font = F.Title
	headerText.TextSize = 18
	headerText.TextColor3 = C.White
	headerText.TextXAlignment = Enum.TextXAlignment.Left
	headerText.Text = "You're in Prison"
	headerText.ZIndex = 83
	headerText.Parent = headerCard
	
	local headerSub = Instance.new("TextLabel")
	headerSub.Size = UDim2.new(1, -80, 0, 20)
	headerSub.Position = UDim2.new(0, 70, 0, 40)
	headerSub.BackgroundTransparency = 1
	headerSub.Font = F.Body
	headerSub.TextSize = 13
	headerSub.TextColor3 = C.Gray400
	headerSub.TextXAlignment = Enum.TextXAlignment.Left
	headerSub.Text = "Choose your actions wisely..."
	headerSub.ZIndex = 83
	headerSub.Parent = headerCard
	
	-- Prison activities
	for i, item in ipairs(PrisonActivities) do
		self:createPrisonCard(self.contentScroll, item, i)
	end
end

function ActivitiesScreen:createPrisonCard(parent, item, order)
	local money = self:getMoney()
	local cost = item.cost or 0
	local canDo = money >= cost
	
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 88)
	card.BackgroundColor3 = C.White
	card.LayoutOrder = order
	card.ZIndex = 82
	card.Parent = parent
	corner(card, 16)
	stroke(card, 1, 0.92, C.Gray200)
	
	-- Icon
	local iconFrame = Instance.new("Frame")
	iconFrame.Size = UDim2.new(0, 54, 0, 54)
	iconFrame.Position = UDim2.new(0, 14, 0.5, -27)
	iconFrame.BackgroundColor3 = item.risk and C.RedPale or C.Gray100
	iconFrame.ZIndex = 83
	iconFrame.Parent = card
	corner(iconFrame, 14)
	
	local iconLbl = Instance.new("TextLabel")
	iconLbl.Size = UDim2.fromScale(1, 1)
	iconLbl.BackgroundTransparency = 1
	iconLbl.Font = F.Body
	iconLbl.TextSize = 28
	iconLbl.Text = item.emoji
	iconLbl.ZIndex = 84
	iconLbl.Parent = iconFrame
	
	-- Name
	local nameLbl = Instance.new("TextLabel")
	nameLbl.Size = UDim2.new(0.5, 0, 0, 24)
	nameLbl.Position = UDim2.new(0, 78, 0, 14)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Font = F.Title
	nameLbl.TextSize = 16
	nameLbl.TextColor3 = C.Gray900
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.Text = item.name
	nameLbl.ZIndex = 83
	nameLbl.Parent = card
	
	-- Effect/Risk badge
	local badgeText = item.risk and ("Risk: " .. item.risk .. "%") or item.effect
	local badgeBg = item.risk and C.RedPale or C.GreenPale
	local badgeColor = item.risk and C.RedDark or C.GreenDark
	
	local effectBadge = Instance.new("Frame")
	effectBadge.Size = UDim2.new(0, 110, 0, 24)
	effectBadge.Position = UDim2.new(0, 78, 0, 42)
	effectBadge.BackgroundColor3 = badgeBg
	effectBadge.ZIndex = 83
	effectBadge.Parent = card
	pill(effectBadge)
	
	local effectLbl = Instance.new("TextLabel")
	effectLbl.Size = UDim2.fromScale(1, 1)
	effectLbl.BackgroundTransparency = 1
	effectLbl.Font = F.Medium
	effectLbl.TextSize = 11
	effectLbl.TextColor3 = badgeColor
	effectLbl.Text = badgeText .. (cost > 0 and " • $" .. cost or "")
	effectLbl.ZIndex = 84
	effectLbl.Parent = effectBadge
	
	-- Minigame indicator
	if item.hasMinigame then
		local miniLabel = Instance.new("TextLabel")
		miniLabel.Size = UDim2.new(0, 80, 0, 16)
		miniLabel.Position = UDim2.new(0, 78, 0, 68)
		miniLabel.BackgroundTransparency = 1
		miniLabel.Font = F.Body
		miniLabel.TextSize = 10
		miniLabel.TextColor3 = C.Purple
		miniLabel.TextXAlignment = Enum.TextXAlignment.Left
		miniLabel.Text = "🎮 Minigame"
		miniLabel.ZIndex = 83
		miniLabel.Parent = card
	end
	
	-- Action button
	local btnText = "Go!"
	local btnColor = item.risk and C.Red or C.Amber
	
	if cost > 0 and not canDo then
		btnText = "Need $"
		btnColor = C.Gray300
	end
	
	local doBtn = Instance.new("TextButton")
	doBtn.Size = UDim2.new(0, 68, 0, 40)
	doBtn.AnchorPoint = Vector2.new(1, 0.5)
	doBtn.Position = UDim2.new(1, -14, 0.5, 0)
	doBtn.BackgroundColor3 = canDo and btnColor or C.Gray300
	doBtn.Font = F.Button
	doBtn.TextSize = 13
	doBtn.TextColor3 = canDo and C.White or C.Gray500
	doBtn.Text = canDo and btnText or "Need $"
	doBtn.AutoButtonColor = false
	doBtn.ZIndex = 83
	doBtn.Parent = card
	pill(doBtn)
	
	if canDo then
		doBtn.MouseEnter:Connect(function() 
			tween(doBtn, TweenInfo.new(0.1), { Size = UDim2.new(0, 74, 0, 44) })
		end)
		doBtn.MouseLeave:Connect(function() 
			tween(doBtn, TweenInfo.new(0.1), { Size = UDim2.new(0, 68, 0, 40) })
		end)
		doBtn.MouseButton1Click:Connect(function()
			self:doPrisonActivity(item)
		end)
	end
end

function ActivitiesScreen:doPrisonActivity(item)
	if item.hasMinigame and item.id == "prison_escape" then
		-- Trigger prison escape minigame through client
		local MinigameResult = remotesFolder and remotesFolder:FindFirstChild("MinigameResult")
		local DoPrisonAction = remotesFolder and remotesFolder:FindFirstChild("DoPrisonAction")
		
		if DoPrisonAction then
			-- The minigame will be handled by the client's minigames module
			-- For now, just call the server action which may trigger the minigame
			local result = DoPrisonAction:InvokeServer(item.id)
			if result then
				local emoji = result.success and "🔓" or "🚔"
				self:showResult(result.success, result.message, emoji)
			else
				self:showResult(false, "Prison escape failed!", "🚔")
			end
		else
			self:showResult(false, "Action not available", "❌")
		end
	else
		-- Regular prison activity
		local DoPrisonAction = remotesFolder and remotesFolder:FindFirstChild("DoPrisonAction")
		if DoPrisonAction then
			local result = DoPrisonAction:InvokeServer(item.id)
			if result then
				local emoji = result.success and "✅" or "❌"
				if item.id == "prison_riot" then emoji = result.success and "🔥" or "🚔" end
				if item.id == "prison_gang" then emoji = result.success and "⛓️" or "😵" end
				self:showResult(result.success, result.message, emoji)
			else
				self:showResult(false, "Server error", "❌")
			end
		else
			self:showResult(false, "Action not available", "❌")
		end
	end
end

function ActivitiesScreen:createActivityCard(parent, item, order, accentColor, bgColor)
	local age = self:getAge()
	local money = self:getMoney()
	local cost = item.cost or 0
	local canDo = age >= item.minAge and money >= cost and not self:isInJail()
	
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 82)
	card.BackgroundColor3 = C.White
	card.LayoutOrder = order
	card.ZIndex = 82
	card.Parent = parent
	corner(card, 16)
	stroke(card, 1, 0.92, C.Gray200)
	
	-- Icon
	local iconFrame = Instance.new("Frame")
	iconFrame.Size = UDim2.new(0, 54, 0, 54)
	iconFrame.Position = UDim2.new(0, 14, 0.5, -27)
	iconFrame.BackgroundColor3 = bgColor
	iconFrame.ZIndex = 83
	iconFrame.Parent = card
	corner(iconFrame, 14)
	
	local iconLbl = Instance.new("TextLabel")
	iconLbl.Size = UDim2.fromScale(1, 1)
	iconLbl.BackgroundTransparency = 1
	iconLbl.Font = F.Body
	iconLbl.TextSize = 28
	iconLbl.Text = item.emoji
	iconLbl.ZIndex = 84
	iconLbl.Parent = iconFrame
	
	-- Name
	local nameLbl = Instance.new("TextLabel")
	nameLbl.Size = UDim2.new(0.5, 0, 0, 22)
	nameLbl.Position = UDim2.new(0, 78, 0, 14)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Font = F.Title
	nameLbl.TextSize = 15
	nameLbl.TextColor3 = C.Gray900
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.Text = item.name
	nameLbl.ZIndex = 83
	nameLbl.Parent = card
	
	-- Effect badge
	local effectBadge = Instance.new("Frame")
	effectBadge.Size = UDim2.new(0, 100, 0, 24)
	effectBadge.Position = UDim2.new(0, 78, 0, 38)
	effectBadge.BackgroundColor3 = cost > 0 and C.AmberPale or C.GreenPale
	effectBadge.ZIndex = 83
	effectBadge.Parent = card
	pill(effectBadge)
	
	local effectLbl = Instance.new("TextLabel")
	effectLbl.Size = UDim2.fromScale(1, 1)
	effectLbl.BackgroundTransparency = 1
	effectLbl.Font = F.Medium
	effectLbl.TextSize = 10
	effectLbl.TextColor3 = cost > 0 and C.AmberDark or C.GreenDark
	effectLbl.Text = item.effect .. (cost > 0 and " • $" .. cost or "")
	effectLbl.ZIndex = 84
	effectLbl.Parent = effectBadge
	
	-- Minigame indicator
	if item.hasMinigame then
		local miniLabel = Instance.new("TextLabel")
		miniLabel.Size = UDim2.new(0, 50, 0, 16)
		miniLabel.Position = UDim2.new(0, 78, 0, 64)
		miniLabel.BackgroundTransparency = 1
		miniLabel.Font = F.Body
		miniLabel.TextSize = 10
		miniLabel.TextColor3 = C.Purple
		miniLabel.TextXAlignment = Enum.TextXAlignment.Left
		miniLabel.Text = "🎮 Minigame"
		miniLabel.ZIndex = 83
		miniLabel.Parent = card
	end
	
	-- Do button
	local doBtn = Instance.new("TextButton")
	doBtn.Size = UDim2.new(0, 68, 0, 40)
	doBtn.AnchorPoint = Vector2.new(1, 0.5)
	doBtn.Position = UDim2.new(1, -14, 0.5, 0)
	doBtn.BackgroundColor3 = canDo and accentColor or C.Gray300
	doBtn.Font = F.Button
	doBtn.TextSize = 13
	doBtn.TextColor3 = canDo and C.White or C.Gray500
	doBtn.Text = canDo and "Go!" or (age < item.minAge and "Age " .. item.minAge .. "+" or money < cost and "Need $" or "Jailed")
	doBtn.AutoButtonColor = false
	doBtn.ZIndex = 83
	doBtn.Parent = card
	pill(doBtn)
	
	if canDo then
		doBtn.MouseEnter:Connect(function() 
			tween(doBtn, TweenInfo.new(0.1), { Size = UDim2.new(0, 74, 0, 44) })
		end)
		doBtn.MouseLeave:Connect(function() 
			tween(doBtn, TweenInfo.new(0.1), { Size = UDim2.new(0, 68, 0, 40) })
		end)
		doBtn.MouseButton1Click:Connect(function()
			if item.hasMinigame then
				self:showMinigame(item, accentColor)
			else
				self:doActivity(item)
			end
		end)
	end
end

function ActivitiesScreen:createCrimeCard(parent, item, order)
	local age = self:getAge()
	local canDo = age >= item.minAge and not self:isInJail()
	
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 88)
	card.BackgroundColor3 = C.White
	card.LayoutOrder = order
	card.ZIndex = 82
	card.Parent = parent
	corner(card, 16)
	stroke(card, canDo and 1 or 1, canDo and 0.7 or 0.92, canDo and C.Red or C.Gray200)
	
	-- Icon
	local iconFrame = Instance.new("Frame")
	iconFrame.Size = UDim2.new(0, 54, 0, 54)
	iconFrame.Position = UDim2.new(0, 14, 0.5, -27)
	iconFrame.BackgroundColor3 = C.RedPale
	iconFrame.ZIndex = 83
	iconFrame.Parent = card
	corner(iconFrame, 14)
	
	local iconLbl = Instance.new("TextLabel")
	iconLbl.Size = UDim2.fromScale(1, 1)
	iconLbl.BackgroundTransparency = 1
	iconLbl.Font = F.Body
	iconLbl.TextSize = 28
	iconLbl.Text = item.emoji
	iconLbl.ZIndex = 84
	iconLbl.Parent = iconFrame
	
	-- Name
	local nameLbl = Instance.new("TextLabel")
	nameLbl.Size = UDim2.new(0.5, 0, 0, 20)
	nameLbl.Position = UDim2.new(0, 78, 0, 12)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Font = F.Title
	nameLbl.TextSize = 15
	nameLbl.TextColor3 = C.Gray900
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.Text = item.name
	nameLbl.ZIndex = 83
	nameLbl.Parent = card
	
	-- Risk badge
	local riskColor = item.risk >= 60 and C.RedPale or item.risk >= 40 and C.AmberPale or C.GreenPale
	local riskTextColor = item.risk >= 60 and C.RedDark or item.risk >= 40 and C.AmberDark or C.GreenDark
	
	local riskBadge = Instance.new("Frame")
	riskBadge.Size = UDim2.new(0, 75, 0, 22)
	riskBadge.Position = UDim2.new(0, 78, 0, 34)
	riskBadge.BackgroundColor3 = riskColor
	riskBadge.ZIndex = 83
	riskBadge.Parent = card
	pill(riskBadge)
	
	local riskLbl = Instance.new("TextLabel")
	riskLbl.Size = UDim2.fromScale(1, 1)
	riskLbl.BackgroundTransparency = 1
	riskLbl.Font = F.Medium
	riskLbl.TextSize = 10
	riskLbl.TextColor3 = riskTextColor
	riskLbl.Text = "⚠️ " .. item.risk .. "% risk"
	riskLbl.ZIndex = 84
	riskLbl.Parent = riskBadge
	
	-- Reward
	local rewardLbl = Instance.new("TextLabel")
	rewardLbl.Size = UDim2.new(0.4, 0, 0, 18)
	rewardLbl.Position = UDim2.new(0, 78, 0, 58)
	rewardLbl.BackgroundTransparency = 1
	rewardLbl.Font = F.Body
	rewardLbl.TextSize = 11
	rewardLbl.TextColor3 = C.Gray500
	rewardLbl.TextXAlignment = Enum.TextXAlignment.Left
	rewardLbl.Text = "💰 " .. item.reward
	rewardLbl.ZIndex = 83
	rewardLbl.Parent = card
	
	-- Commit button
	local commitBtn = Instance.new("TextButton")
	commitBtn.Size = UDim2.new(0, 75, 0, 42)
	commitBtn.AnchorPoint = Vector2.new(1, 0.5)
	commitBtn.Position = UDim2.new(1, -14, 0.5, 0)
	commitBtn.BackgroundColor3 = canDo and C.Red or C.Gray300
	commitBtn.Font = F.Button
	commitBtn.TextSize = 12
	commitBtn.TextColor3 = canDo and C.White or C.Gray500
	commitBtn.Text = canDo and "Commit" or (age < item.minAge and "Age " .. item.minAge .. "+" or "Jailed")
	commitBtn.AutoButtonColor = false
	commitBtn.ZIndex = 83
	commitBtn.Parent = card
	pill(commitBtn)
	
	if canDo then
		commitBtn.MouseEnter:Connect(function() tween(commitBtn, TweenInfo.new(0.1), { BackgroundColor3 = C.RedDark }) end)
		commitBtn.MouseLeave:Connect(function() tween(commitBtn, TweenInfo.new(0.1), { BackgroundColor3 = C.Red }) end)
		commitBtn.MouseButton1Click:Connect(function()
			self:doCrime(item)
		end)
	end
end

function ActivitiesScreen:populateMindBody()
	self:updateInfoBar()
	for i, item in ipairs(MindBody) do
		self:createActivityCard(self.contentScroll, item, i, C.Cyan, C.CyanPale)
	end
end

function ActivitiesScreen:populateSocial()
	self:updateInfoBar()
	for i, item in ipairs(Social) do
		self:createActivityCard(self.contentScroll, item, i, C.Pink, C.PinkPale)
	end
end

function ActivitiesScreen:populateFun()
	self:updateInfoBar()
	for i, item in ipairs(Entertainment) do
		self:createActivityCard(self.contentScroll, item, i, C.Purple, C.PurplePale)
	end
end

function ActivitiesScreen:populateCrime()
	self:updateInfoBar()
	for i, item in ipairs(Crimes) do
		self:createCrimeCard(self.contentScroll, item, i)
	end
end

function ActivitiesScreen:createMinigameModal()
	self.minigameOverlay = Instance.new("Frame")
	self.minigameOverlay.Size = UDim2.fromScale(1, 1)
	self.minigameOverlay.BackgroundColor3 = C.Black
	self.minigameOverlay.BackgroundTransparency = 0.4
	self.minigameOverlay.Visible = false
	self.minigameOverlay.ZIndex = 96
	self.minigameOverlay.Parent = self.screenGui
	
	self.minigameCard = Instance.new("Frame")
	self.minigameCard.Size = UDim2.new(0.9, 0, 0, 380)
	self.minigameCard.AnchorPoint = Vector2.new(0.5, 0.5)
	self.minigameCard.Position = UDim2.fromScale(0.5, 0.5)
	self.minigameCard.BackgroundColor3 = C.White
	self.minigameCard.ZIndex = 97
	self.minigameCard.Parent = self.minigameOverlay
	corner(self.minigameCard, 24)
	
	-- Title
	self.minigameTitle = Instance.new("TextLabel")
	self.minigameTitle.Size = UDim2.new(1, 0, 0, 50)
	self.minigameTitle.BackgroundTransparency = 1
	self.minigameTitle.Font = F.Title
	self.minigameTitle.TextSize = 22
	self.minigameTitle.TextColor3 = C.Gray900
	self.minigameTitle.Text = "🏋️ Tap to Workout!"
	self.minigameTitle.ZIndex = 98
	self.minigameTitle.Parent = self.minigameCard
	
	-- Progress bar background
	self.progressBg = Instance.new("Frame")
	self.progressBg.Size = UDim2.new(0.85, 0, 0, 24)
	self.progressBg.AnchorPoint = Vector2.new(0.5, 0)
	self.progressBg.Position = UDim2.new(0.5, 0, 0, 55)
	self.progressBg.BackgroundColor3 = C.Gray200
	self.progressBg.ZIndex = 98
	self.progressBg.Parent = self.minigameCard
	pill(self.progressBg)
	
	-- Progress bar fill
	self.progressFill = Instance.new("Frame")
	self.progressFill.Size = UDim2.new(0, 0, 1, 0)
	self.progressFill.BackgroundColor3 = C.Green
	self.progressFill.ZIndex = 99
	self.progressFill.Parent = self.progressBg
	pill(self.progressFill)
	
	-- Tap area (big button)
	self.tapArea = Instance.new("TextButton")
	self.tapArea.Size = UDim2.new(0.7, 0, 0, 180)
	self.tapArea.AnchorPoint = Vector2.new(0.5, 0)
	self.tapArea.Position = UDim2.new(0.5, 0, 0, 95)
	self.tapArea.BackgroundColor3 = C.Cyan
	self.tapArea.Font = F.Title
	self.tapArea.TextSize = 60
	self.tapArea.TextColor3 = C.White
	self.tapArea.Text = "💪"
	self.tapArea.AutoButtonColor = false
	self.tapArea.ZIndex = 98
	self.tapArea.Parent = self.minigameCard
	corner(self.tapArea, 24)
	
	-- Tap counter
	self.tapCounter = Instance.new("TextLabel")
	self.tapCounter.Size = UDim2.new(1, 0, 0, 40)
	self.tapCounter.AnchorPoint = Vector2.new(0.5, 0)
	self.tapCounter.Position = UDim2.new(0.5, 0, 0, 285)
	self.tapCounter.BackgroundTransparency = 1
	self.tapCounter.Font = F.Title
	self.tapCounter.TextSize = 28
	self.tapCounter.TextColor3 = C.Gray700
	self.tapCounter.Text = "0 / 20"
	self.tapCounter.ZIndex = 98
	self.tapCounter.Parent = self.minigameCard
	
	-- Instructions
	self.minigameInstructions = Instance.new("TextLabel")
	self.minigameInstructions.Size = UDim2.new(1, 0, 0, 30)
	self.minigameInstructions.AnchorPoint = Vector2.new(0.5, 0)
	self.minigameInstructions.Position = UDim2.new(0.5, 0, 0, 330)
	self.minigameInstructions.BackgroundTransparency = 1
	self.minigameInstructions.Font = F.Body
	self.minigameInstructions.TextSize = 14
	self.minigameInstructions.TextColor3 = C.Gray500
	self.minigameInstructions.Text = "Tap as fast as you can!"
	self.minigameInstructions.ZIndex = 98
	self.minigameInstructions.Parent = self.minigameCard
	
	-- Variables for minigame
	self.tapCount = 0
	self.tapGoal = 20
	self.minigameActive = false
	self.currentMinigameItem = nil
	self.minigameAccent = C.Cyan
	
	-- Tap handler
	self.tapArea.MouseButton1Click:Connect(function()
		if not self.minigameActive then return end
		self.tapCount = self.tapCount + 1
		self.tapCounter.Text = self.tapCount .. " / " .. self.tapGoal
		
		-- Pulse animation
		tween(self.tapArea, TweenInfo.new(0.05), { Size = UDim2.new(0.68, 0, 0, 175) })
		task.delay(0.05, function()
			tween(self.tapArea, TweenInfo.new(0.1), { Size = UDim2.new(0.7, 0, 0, 180) })
		end)
		
		-- Update progress
		local progress = math.clamp(self.tapCount / self.tapGoal, 0, 1)
		tween(self.progressFill, TweenInfo.new(0.1), { Size = UDim2.new(progress, 0, 1, 0) })
		
		-- Check win
		if self.tapCount >= self.tapGoal then
			self.minigameActive = false
			self:completeMinigame(true)
		end
	end)
end

function ActivitiesScreen:showMinigame(item, accentColor)
	self.currentMinigameItem = item
	self.minigameAccent = accentColor
	self.tapCount = 0
	self.tapGoal = item.id == "gym" and 25 or 15
	self.minigameActive = true
	
	-- Set up visuals
	local emoji = item.id == "gym" and "💪" or "📚"
	local title = item.id == "gym" and "🏋️ Tap to Workout!" or "📖 Tap to Study!"
	
	self.minigameTitle.Text = title
	self.tapArea.Text = emoji
	self.tapArea.BackgroundColor3 = accentColor
	self.progressFill.BackgroundColor3 = accentColor
	self.progressFill.Size = UDim2.new(0, 0, 1, 0)
	self.tapCounter.Text = "0 / " .. self.tapGoal
	
	self.minigameOverlay.Visible = true
	self.minigameCard.Position = UDim2.new(0.5, 0, 0.5, 50)
	self.minigameCard.BackgroundTransparency = 1
	tween(self.minigameCard, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 0
	})
	
	-- Timeout
	task.delay(10, function()
		if self.minigameActive and self.minigameOverlay.Visible then
			self.minigameActive = false
			self:completeMinigame(self.tapCount >= self.tapGoal * 0.5)
		end
	end)
end

function ActivitiesScreen:completeMinigame(success)
	task.delay(0.3, function()
		self.minigameOverlay.Visible = false
		
		-- Do the activity with bonus if successful
		if success then
			self:doActivity(self.currentMinigameItem, true)
		else
			self:showResult(false, "You gave up halfway through. No gains today!", "😓")
		end
	end)
end

function ActivitiesScreen:doActivity(item, bonus)
	if not DoActivity then
		self:showResult(false, "Server not available", "❌")
		return
	end
	
	local result = DoActivity:InvokeServer(item.id, bonus or false)
	if result then
		local emoji = result.success and "🎉" or "😔"
		self:showResult(result.success, result.message, emoji)
	else
		self:showResult(false, "Server error", "❌")
	end
end

function ActivitiesScreen:doCrime(item)
	if not CommitCrime then
		self:showResult(false, "Server not available", "❌")
		return
	end
	
	local result = CommitCrime:InvokeServer(item.id)
	if result then
		local emoji = result.caught and "🚔" or (result.success and "💰" or "😔")
		self:showResult(result.success, result.message, emoji)
	else
		self:showResult(false, "Server error", "❌")
	end
end

function ActivitiesScreen:createResultModal()
	self.resultOverlay = Instance.new("Frame")
	self.resultOverlay.Size = UDim2.fromScale(1, 1)
	self.resultOverlay.BackgroundColor3 = C.Black
	self.resultOverlay.BackgroundTransparency = 0.5
	self.resultOverlay.Visible = false
	self.resultOverlay.ZIndex = 98
	self.resultOverlay.Parent = self.screenGui
	
	-- Click outside to close
	local resultCloseArea = Instance.new("TextButton")
	resultCloseArea.Size = UDim2.fromScale(1, 1)
	resultCloseArea.BackgroundTransparency = 1
	resultCloseArea.Text = ""
	resultCloseArea.ZIndex = 98
	resultCloseArea.Parent = self.resultOverlay
	resultCloseArea.MouseButton1Click:Connect(function()
		self:hideResultModal()
	end)
	
	-- Outer colored shell (BitLife-style)
	self.resultShell = Instance.new("Frame")
	self.resultShell.Size = UDim2.new(0.88, 0, 0, 0)
	self.resultShell.AutomaticSize = Enum.AutomaticSize.Y
	self.resultShell.AnchorPoint = Vector2.new(0.5, 0.5)
	self.resultShell.Position = UDim2.fromScale(0.5, 0.5)
	self.resultShell.BackgroundColor3 = C.Amber
	self.resultShell.ZIndex = 99
	self.resultShell.Parent = self.resultOverlay
	corner(self.resultShell, 24)
	
	self.resultShellStroke = stroke(self.resultShell, 3, 0, C.AmberDark)
	pad(self.resultShell, 4, 4, 4, 4)
	
	-- Inner white card
	self.resultCard = Instance.new("Frame")
	self.resultCard.Size = UDim2.new(1, 0, 0, 0)
	self.resultCard.AutomaticSize = Enum.AutomaticSize.Y
	self.resultCard.BackgroundColor3 = C.White
	self.resultCard.ZIndex = 100
	self.resultCard.Parent = self.resultShell
	corner(self.resultCard, 20)
	
	local content = Instance.new("Frame")
	content.Size = UDim2.new(1, 0, 0, 0)
	content.AutomaticSize = Enum.AutomaticSize.Y
	content.BackgroundTransparency = 1
	content.ZIndex = 101
	content.Parent = self.resultCard
	
	pad(content, 24, 24, 28, 24)
	
	local layout = Instance.new("UIListLayout")
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Padding = UDim.new(0, 14)
	layout.Parent = content
	
	self.resultEmojiFrame = Instance.new("Frame")
	self.resultEmojiFrame.Size = UDim2.new(0, 72, 0, 72)
	self.resultEmojiFrame.BackgroundColor3 = C.GreenPale
	self.resultEmojiFrame.LayoutOrder = 1
	self.resultEmojiFrame.ZIndex = 102
	self.resultEmojiFrame.Parent = content
	corner(self.resultEmojiFrame, 36)
	
	self.resultEmoji = Instance.new("TextLabel")
	self.resultEmoji.Size = UDim2.fromScale(1, 1)
	self.resultEmoji.BackgroundTransparency = 1
	self.resultEmoji.Font = F.Body
	self.resultEmoji.TextSize = 38
	self.resultEmoji.Text = "🎉"
	self.resultEmoji.ZIndex = 103
	self.resultEmoji.Parent = self.resultEmojiFrame
	
	self.resultTitle = Instance.new("TextLabel")
	self.resultTitle.Size = UDim2.new(1, 0, 0, 28)
	self.resultTitle.BackgroundTransparency = 1
	self.resultTitle.Font = F.Title
	self.resultTitle.TextSize = 22
	self.resultTitle.TextColor3 = C.Gray900
	self.resultTitle.Text = "Done!"
	self.resultTitle.LayoutOrder = 2
	self.resultTitle.ZIndex = 102
	self.resultTitle.Parent = content
	
	self.resultMsg = Instance.new("TextLabel")
	self.resultMsg.Size = UDim2.new(1, 0, 0, 0)
	self.resultMsg.AutomaticSize = Enum.AutomaticSize.Y
	self.resultMsg.BackgroundTransparency = 1
	self.resultMsg.Font = F.Body
	self.resultMsg.TextSize = 15
	self.resultMsg.TextColor3 = C.Gray600
	self.resultMsg.TextWrapped = true
	self.resultMsg.LineHeight = 1.4
	self.resultMsg.Text = ""
	self.resultMsg.LayoutOrder = 3
	self.resultMsg.ZIndex = 102
	self.resultMsg.Parent = content
	
	local spacer = Instance.new("Frame")
	spacer.Size = UDim2.new(1, 0, 0, 6)
	spacer.BackgroundTransparency = 1
	spacer.LayoutOrder = 4
	spacer.Parent = content
	
	self.resultOkBtn = Instance.new("TextButton")
	self.resultOkBtn.Size = UDim2.new(1, 0, 0, 50)
	self.resultOkBtn.BackgroundColor3 = C.Amber
	self.resultOkBtn.Font = F.Button
	self.resultOkBtn.TextSize = 16
	self.resultOkBtn.TextColor3 = C.White
	self.resultOkBtn.Text = "Continue"
	self.resultOkBtn.AutoButtonColor = false
	self.resultOkBtn.LayoutOrder = 5
	self.resultOkBtn.ZIndex = 102
	self.resultOkBtn.Parent = content
	corner(self.resultOkBtn, 12)
	
	self.resultOkBtn.MouseButton1Click:Connect(function() self:hideResultModal() end)
	self.resultOkBtn.MouseEnter:Connect(function() tween(self.resultOkBtn, TweenInfo.new(0.1), { BackgroundColor3 = C.AmberDark }) end)
	self.resultOkBtn.MouseLeave:Connect(function() tween(self.resultOkBtn, TweenInfo.new(0.1), { BackgroundColor3 = C.Amber }) end)
end

function ActivitiesScreen:showResult(success, message, emoji)
	-- Set shell color based on success
	local shellColor = success and C.Green or C.Red
	local shellStrokeColor = success and C.GreenDark or C.RedDark
	
	self.resultShell.BackgroundColor3 = shellColor
	self.resultShellStroke.Color = shellStrokeColor
	
	self.resultEmoji.Text = emoji or (success and "🎉" or "😔")
	self.resultEmojiFrame.BackgroundColor3 = success and C.GreenPale or C.RedPale
	self.resultTitle.Text = success and "Success!" or "Uh oh..."
	self.resultTitle.TextColor3 = success and C.GreenDark or C.RedDark
	self.resultMsg.Text = message or ""
	self.resultOkBtn.BackgroundColor3 = success and C.Green or C.Red
	
	self.resultOverlay.Visible = true
	self.resultShell.Position = UDim2.new(0.5, 0, 0.5, 40)
	self.resultShell.BackgroundTransparency = 1
	self.resultCard.BackgroundTransparency = 1
	
	tween(self.resultShell, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 0
	})
	tween(self.resultCard, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0
	})
end

function ActivitiesScreen:hideResultModal()
	local t = tween(self.resultShell, TweenInfo.new(0.2), {
		Position = UDim2.new(0.5, 0, 0.5, 40),
		BackgroundTransparency = 1
	})
	tween(self.resultCard, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
	t.Completed:Connect(function()
		self.resultOverlay.Visible = false
		self:switchTab(self.currentTab)
	end)
end

function ActivitiesScreen:show()
	self.overlay.Visible = true
	self.overlay.Position = UDim2.new(1, 0, 0, 0)
	self:updateInfoBar()
	self:rebuildTabs()  -- Rebuild tabs based on jail status
	self:createContentScroll()  -- Ensure content scroll exists
	self:switchTab(self.currentTab)
	tween(self.overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { 
		Position = UDim2.fromScale(0, 0) 
	})
	self.isVisible = true
end

function ActivitiesScreen:hide()
	local t = tween(self.overlay, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { 
		Position = UDim2.new(1, 0, 0, 0) 
	})
	t.Completed:Connect(function()
		self.overlay.Visible = false
		self.resultOverlay.Visible = false
		self.minigameOverlay.Visible = false
	end)
	self.isVisible = false
end

return ActivitiesScreen
