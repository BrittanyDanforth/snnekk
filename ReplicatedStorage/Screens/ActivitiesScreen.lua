-- ActivitiesScreen.lua
-- Premium BitLife-style Activities screen
-- Triple AAA polished UI with minigames and crime

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UI = require(ReplicatedStorage:WaitForChild("UIComponents"))
local C = UI.Colors
local F = UI.Fonts

local ActivitiesScreen = {}
ActivitiesScreen.__index = ActivitiesScreen

-- Remotes
local remotesFolder = ReplicatedStorage:WaitForChild("LifeRemotes", 30)
local DoActivity = remotesFolder and remotesFolder:WaitForChild("DoActivity", 15)
local CommitCrime = remotesFolder and remotesFolder:WaitForChild("CommitCrime", 15)
local DoPrisonAction = remotesFolder and remotesFolder:WaitForChild("DoPrisonAction", 15)

-- Activity Data
local MindBody = {
	{ id = "gym", name = "Hit the Gym", emoji = "Gym", effect = "+Health +Looks", minAge = 12, cost = 0, hasMinigame = true },
	{ id = "meditate", name = "Meditate", emoji = "Zen", effect = "+Happiness +Health", minAge = 10, cost = 0 },
	{ id = "study", name = "Study Hard", emoji = "Book", effect = "+Smarts", minAge = 6, cost = 0, hasMinigame = true },
	{ id = "spa", name = "Spa Day", emoji = "Spa", effect = "+Looks +Happiness", minAge = 16, cost = 200 },
	{ id = "walk", name = "Go for Walk", emoji = "Walk", effect = "+Health +Happiness", minAge = 5, cost = 0 },
	{ id = "martial_arts", name = "Martial Arts", emoji = "Karate", effect = "+Health +Smarts", minAge = 8, cost = 100 },
	{ id = "yoga", name = "Yoga Class", emoji = "Yoga", effect = "+Health +Looks", minAge = 14, cost = 50 },
	{ id = "read", name = "Read a Book", emoji = "Read", effect = "+Smarts +Happiness", minAge = 6, cost = 0 },
}

local Social = {
	{ id = "party", name = "Go to Party", emoji = "Party", effect = "+Happiness", minAge = 16, cost = 0 },
	{ id = "date", name = "Go on Date", emoji = "Date", effect = "+Happiness", minAge = 16, cost = 100 },
	{ id = "club", name = "Night Club", emoji = "Club", effect = "+Happiness -Health", minAge = 21, cost = 150 },
	{ id = "hangout", name = "Hang with Friends", emoji = "Friends", effect = "+Happiness", minAge = 5, cost = 0 },
	{ id = "volunteer", name = "Volunteer", emoji = "Help", effect = "+Happiness +Smarts", minAge = 12, cost = 0 },
	{ id = "networking", name = "Networking Event", emoji = "Network", effect = "+Smarts", minAge = 18, cost = 50 },
}

local Entertainment = {
	{ id = "movie", name = "Watch Movie", emoji = "Movie", effect = "+Happiness", minAge = 5, cost = 20 },
	{ id = "concert", name = "Go to Concert", emoji = "Music", effect = "+Happiness", minAge = 12, cost = 100 },
	{ id = "vacation", name = "Take Vacation", emoji = "Travel", effect = "+Happiness +Health", minAge = 10, cost = 2000 },
	{ id = "gaming", name = "Play Games", emoji = "Game", effect = "+Happiness", minAge = 5, cost = 0 },
	{ id = "camping", name = "Go Camping", emoji = "Camp", effect = "+Happiness +Health", minAge = 8, cost = 300 },
	{ id = "museum", name = "Visit Museum", emoji = "Museum", effect = "+Smarts", minAge = 6, cost = 25 },
	{ id = "theme_park", name = "Theme Park", emoji = "Ride", effect = "+Happiness", minAge = 8, cost = 150 },
}

local Crimes = {
	{ id = "shoplift", name = "Shoplift", emoji = "Steal", risk = 30, reward = "$50-$200", minAge = 10 },
	{ id = "pickpocket", name = "Pickpocket", emoji = "Wallet", risk = 45, reward = "$100-$500", minAge = 12 },
	{ id = "burglary", name = "Burglary", emoji = "House", risk = 60, reward = "$500-$5K", minAge = 16 },
	{ id = "robbery", name = "Armed Robbery", emoji = "Gun", risk = 80, reward = "$5K-$50K", minAge = 18 },
	{ id = "car_theft", name = "Grand Theft Auto", emoji = "Car", risk = 65, reward = "$5K-$25K", minAge = 16 },
	{ id = "drug_deal", name = "Drug Deal", emoji = "Pills", risk = 55, reward = "$1K-$10K", minAge = 16 },
	{ id = "bank_heist", name = "Bank Heist", emoji = "Bank", risk = 95, reward = "$50K-$500K", minAge = 21, hasMinigame = true },
}

local PrisonActivities = {
	{ id = "prison_escape", name = "Escape Prison", emoji = "Key", effect = "Freedom!", minAge = 0, risk = 90, hasMinigame = true },
	{ id = "prison_workout", name = "Yard Workout", emoji = "Strong", effect = "+Health +Looks", minAge = 0 },
	{ id = "prison_study", name = "Get GED", emoji = "Study", effect = "+Smarts", minAge = 0 },
	{ id = "prison_gang", name = "Join Prison Gang", emoji = "Gang", effect = "+Respect -Health", minAge = 0 },
	{ id = "prison_riot", name = "Start Riot", emoji = "Fire", effect = "Dangerous!", minAge = 0, risk = 85 },
	{ id = "prison_snitch", name = "Snitch", emoji = "Rat", effect = "-Sentence +Risk", minAge = 0 },
	{ id = "prison_appeal", name = "Appeal Sentence", emoji = "Law", effect = "Legal Help", minAge = 0, cost = 5000 },
	{ id = "prison_goodbehavior", name = "Good Behavior", emoji = "Good", effect = "-Sentence Time", minAge = 0 },
}

function ActivitiesScreen.new(screenGui, blurOverlay, showBlurFunc, hideBlurFunc, playerState)
	local self = setmetatable({}, ActivitiesScreen)
	self.screenGui = screenGui
	self.playerState = playerState or {}
	self.showBlur = showBlurFunc
	self.hideBlur = hideBlurFunc
	self.isVisible = false
	self.currentTab = "mindbody"
	self:createUI()
	return self
end

function ActivitiesScreen:updateState(newState)
	if newState then self.playerState = newState end
end

function ActivitiesScreen:getAge()
	local state = self.playerState
	if not state then return 18 end
	return state.Age or (state.Stats and state.Stats.Age) or 18
end

function ActivitiesScreen:getMoney()
	local state = self.playerState
	if not state then return 1000 end
	return state.Money or (state.Stats and state.Stats.Money) or 1000
end

function ActivitiesScreen:isInJail()
	local state = self.playerState
	if not state then return false end
	return state.InJail or (state.Flags and state.Flags.in_prison) or false
end

function ActivitiesScreen:createUI()
	-- Main overlay
	self.overlay = Instance.new("Frame")
	self.overlay.Name = "ActivitiesOverlay"
	self.overlay.Size = UDim2.fromScale(1, 1)
	self.overlay.BackgroundColor3 = C.Bg
	self.overlay.Visible = false
	self.overlay.ZIndex = 80
	self.overlay.Parent = self.screenGui
	
	-- Premium header
	local headerData = UI.createScreenHeader(self.overlay, {
		title = "Activities",
		color = C.Amber,
		colorDark = C.AmberDark,
		zIndex = 85
	})
	headerData.closeButton.MouseButton1Click:Connect(function() self:hide() end)
	headerData.closeButton.MouseEnter:Connect(function()
		UI.tween(headerData.closeButton, TweenInfo.new(0.12), { BackgroundTransparency = 0 })
	end)
	headerData.closeButton.MouseLeave:Connect(function()
		UI.tween(headerData.closeButton, TweenInfo.new(0.12), { BackgroundTransparency = 0.1 })
	end)
	
	-- Info bar (simplified - no shadow)
	self.infoBar = Instance.new("Frame")
	self.infoBar.Name = "InfoBar"
	self.infoBar.Size = UDim2.new(1, -16, 0, 52)
	self.infoBar.Position = UDim2.new(0, 8, 0, 116)
	self.infoBar.BackgroundColor3 = C.White
	self.infoBar.ZIndex = 84
	self.infoBar.Parent = self.overlay
	UI.corner(self.infoBar, 14)
	UI.stroke(self.infoBar, 1, 0.9, C.Gray200)
	
	local infoLayout = Instance.new("UIListLayout")
	infoLayout.FillDirection = Enum.FillDirection.Horizontal
	infoLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	infoLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	infoLayout.Padding = UDim.new(0, 10)
	infoLayout.Parent = self.infoBar
	
	self.ageChip = UI.createInfoChip(self.infoBar, {
		name = "AgeChip", icon = "", text = "Age 18",
		bgColor = C.BluePale, textColor = C.BlueDark, order = 1, width = 80
	})
	self.ageChip.icon.Text = ""
	self.ageChip.text.Text = "Age 18"
	self.ageChip.text.Position = UDim2.new(0, 8, 0, 0)
	self.ageChip.text.Size = UDim2.new(1, -16, 1, 0)
	self.ageChip.text.TextXAlignment = Enum.TextXAlignment.Center
	
	self.moneyChip = UI.createInfoChip(self.infoBar, {
		name = "MoneyChip", icon = "", text = "$1,000",
		bgColor = C.GreenPale, textColor = C.GreenDark, order = 2, width = 90
	})
	self.moneyChip.icon.Text = ""
	self.moneyChip.text.Text = "$1,000"
	self.moneyChip.text.Position = UDim2.new(0, 8, 0, 0)
	self.moneyChip.text.Size = UDim2.new(1, -16, 1, 0)
	self.moneyChip.text.TextXAlignment = Enum.TextXAlignment.Center
	
	self.statusChip = UI.createInfoChip(self.infoBar, {
		name = "StatusChip", icon = "", text = "Free",
		bgColor = C.GreenPale, textColor = C.GreenDark, order = 3, width = 75
	})
	self.statusChip.icon.Text = ""
	self.statusChip.text.Text = "Free"
	self.statusChip.text.Position = UDim2.new(0, 8, 0, 0)
	self.statusChip.text.Size = UDim2.new(1, -16, 1, 0)
	self.statusChip.text.TextXAlignment = Enum.TextXAlignment.Center
	
	-- Tab bar
	self.tabBar = Instance.new("Frame")
	self.tabBar.Name = "TabBar"
	self.tabBar.Size = UDim2.new(1, -16, 0, 52)
	self.tabBar.Position = UDim2.new(0, 8, 0, 176)
	self.tabBar.BackgroundColor3 = C.Gray100
	self.tabBar.ZIndex = 84
	self.tabBar.Parent = self.overlay
	UI.corner(self.tabBar, 14)
	UI.pad(self.tabBar, 5, 5, 5, 5)
	
	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	tabLayout.Padding = UDim.new(0, 6)
	tabLayout.Parent = self.tabBar
	
	self.tabBtns = {}
	self:rebuildTabs()
	
	-- Scroll area
	self.contentScroll = Instance.new("ScrollingFrame")
	self.contentScroll.Name = "ContentScroll"
	self.contentScroll.Size = UDim2.new(1, -16, 1, -250)
	self.contentScroll.Position = UDim2.new(0, 8, 0, 240)
	self.contentScroll.BackgroundTransparency = 1
	self.contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	self.contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	self.contentScroll.ScrollBarThickness = 4
	self.contentScroll.ScrollBarImageColor3 = C.Gray300
	self.contentScroll.ZIndex = 81
	self.contentScroll.Parent = self.overlay
	
	local contentLayout = Instance.new("UIListLayout")
	contentLayout.Padding = UDim.new(0, 12)
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	contentLayout.Parent = self.contentScroll
	
	-- Modals
	self:createResultModal()
	self:createMinigameModal()
	
	-- Initial populate
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
		tabs = {
			{ id = "prison", text = "Prison", color = C.Gray700 },
			{ id = "mindbody", text = "Exercise", color = C.Cyan },
		}
		self.currentTab = "prison"
	else
		tabs = {
			{ id = "mindbody", text = "Mind", color = C.Cyan },
			{ id = "social", text = "Social", color = C.Pink },
			{ id = "fun", text = "Fun", color = C.Purple },
			{ id = "crime", text = "Crime", color = C.Red },
		}
	end
	
	local tabWidth = 0.95 / #tabs
	
	for i, tab in ipairs(tabs) do
		local btn = Instance.new("TextButton")
		btn.Name = tab.id
		btn.Size = UDim2.new(tabWidth, 0, 1, 0)
		btn.BackgroundColor3 = i == 1 and tab.color or C.White
		btn.Font = F.Button
		btn.TextSize = 14
		btn.TextColor3 = i == 1 and C.White or C.Gray600
		btn.Text = tab.text
		btn.AutoButtonColor = false
		btn.LayoutOrder = i
		btn.ZIndex = 85
		btn.Parent = self.tabBar
		UI.corner(btn, 10)
		
		self.tabBtns[tab.id] = { btn = btn, color = tab.color }
		btn.MouseButton1Click:Connect(function() self:switchTab(tab.id) end)
	end
end

function ActivitiesScreen:updateInfoBar()
	self.ageChip.text.Text = "Age " .. self:getAge()
	self.moneyChip.text.Text = UI.formatMoney(self:getMoney())
	
	local inJail = self:isInJail()
	self.statusChip.text.Text = inJail and "In Jail" or "Free"
	self.statusChip.chip.BackgroundColor3 = inJail and C.RedPale or C.GreenPale
	self.statusChip.text.TextColor3 = inJail and C.RedDark or C.GreenDark
end

function ActivitiesScreen:switchTab(tabId)
	self.currentTab = tabId
	
	for id, data in pairs(self.tabBtns) do
		local isActive = id == tabId
		UI.tween(data.btn, TweenInfo.new(0.15), {
			BackgroundColor3 = isActive and data.color or C.White,
			TextColor3 = isActive and C.White or C.Gray600
		})
	end
	
	-- Clear content
	for _, child in ipairs(self.contentScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	
	if tabId == "prison" then self:populatePrison()
	elseif tabId == "mindbody" then self:populateMindBody()
	elseif tabId == "social" then self:populateSocial()
	elseif tabId == "fun" then self:populateFun()
	elseif tabId == "crime" then self:populateCrime() end
end

function ActivitiesScreen:populateMindBody()
	self:updateInfoBar()
	
	-- Section card
	local section = Instance.new("Frame")
	section.Name = "MindBodySection"
	section.Size = UDim2.new(1, 0, 0, 0)
	section.AutomaticSize = Enum.AutomaticSize.Y
	section.BackgroundColor3 = C.White
	section.LayoutOrder = 1
	section.ZIndex = 82
	section.Parent = self.contentScroll
	UI.corner(section, 18)
	UI.stroke(section, 1, 0.88, C.Gray200)
	UI.pad(section, 14, 14, 14, 16)
	
	local sectionLayout = Instance.new("UIListLayout")
	sectionLayout.Padding = UDim.new(0, 10)
	sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
	sectionLayout.Parent = section
	
	-- Header
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 36)
	header.BackgroundTransparency = 1
	header.LayoutOrder = 0
	header.ZIndex = 83
	header.Parent = section
	
	local badge = Instance.new("Frame")
	badge.Size = UDim2.new(0, 120, 0, 32)
	badge.BackgroundColor3 = C.Cyan
	badge.ZIndex = 84
	badge.Parent = header
	UI.pill(badge)
	
	local badgeLabel = Instance.new("TextLabel")
	badgeLabel.Size = UDim2.fromScale(1, 1)
	badgeLabel.BackgroundTransparency = 1
	badgeLabel.Font = F.Button
	badgeLabel.TextSize = 14
	badgeLabel.TextColor3 = C.White
	badgeLabel.Text = "Mind & Body"
	badgeLabel.ZIndex = 85
	badgeLabel.Parent = badge
	
	local countLabel = Instance.new("TextLabel")
	countLabel.Size = UDim2.new(0, 80, 1, 0)
	countLabel.Position = UDim2.new(0, 130, 0, 0)
	countLabel.BackgroundTransparency = 1
	countLabel.Font = F.Medium
	countLabel.TextSize = 13
	countLabel.TextColor3 = C.Gray400
	countLabel.TextXAlignment = Enum.TextXAlignment.Left
	countLabel.Text = #MindBody .. " activities"
	countLabel.ZIndex = 84
	countLabel.Parent = header
	
	for i, item in ipairs(MindBody) do
		self:createActivityCard(section, item, i, C.Cyan, C.CyanPale)
	end
end

function ActivitiesScreen:populateSocial()
	self:updateInfoBar()
	
	local section = Instance.new("Frame")
	section.Name = "SocialSection"
	section.Size = UDim2.new(1, 0, 0, 0)
	section.AutomaticSize = Enum.AutomaticSize.Y
	section.BackgroundColor3 = C.White
	section.LayoutOrder = 1
	section.ZIndex = 82
	section.Parent = self.contentScroll
	UI.corner(section, 18)
	UI.stroke(section, 1, 0.88, C.Gray200)
	UI.pad(section, 14, 14, 14, 16)
	
	local sectionLayout = Instance.new("UIListLayout")
	sectionLayout.Padding = UDim.new(0, 10)
	sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
	sectionLayout.Parent = section
	
	-- Header
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 36)
	header.BackgroundTransparency = 1
	header.LayoutOrder = 0
	header.ZIndex = 83
	header.Parent = section
	
	local badge = Instance.new("Frame")
	badge.Size = UDim2.new(0, 90, 0, 32)
	badge.BackgroundColor3 = C.Pink
	badge.ZIndex = 84
	badge.Parent = header
	UI.pill(badge)
	
	local badgeLabel = Instance.new("TextLabel")
	badgeLabel.Size = UDim2.fromScale(1, 1)
	badgeLabel.BackgroundTransparency = 1
	badgeLabel.Font = F.Button
	badgeLabel.TextSize = 14
	badgeLabel.TextColor3 = C.White
	badgeLabel.Text = "Social"
	badgeLabel.ZIndex = 85
	badgeLabel.Parent = badge
	
	local countLabel = Instance.new("TextLabel")
	countLabel.Size = UDim2.new(0, 80, 1, 0)
	countLabel.Position = UDim2.new(0, 100, 0, 0)
	countLabel.BackgroundTransparency = 1
	countLabel.Font = F.Medium
	countLabel.TextSize = 13
	countLabel.TextColor3 = C.Gray400
	countLabel.TextXAlignment = Enum.TextXAlignment.Left
	countLabel.Text = #Social .. " activities"
	countLabel.ZIndex = 84
	countLabel.Parent = header
	
	for i, item in ipairs(Social) do
		self:createActivityCard(section, item, i, C.Pink, C.PinkPale)
	end
end

function ActivitiesScreen:populateFun()
	self:updateInfoBar()
	
	local section = Instance.new("Frame")
	section.Name = "FunSection"
	section.Size = UDim2.new(1, 0, 0, 0)
	section.AutomaticSize = Enum.AutomaticSize.Y
	section.BackgroundColor3 = C.White
	section.LayoutOrder = 1
	section.ZIndex = 82
	section.Parent = self.contentScroll
	UI.corner(section, 18)
	UI.stroke(section, 1, 0.88, C.Gray200)
	UI.pad(section, 14, 14, 14, 16)
	
	local sectionLayout = Instance.new("UIListLayout")
	sectionLayout.Padding = UDim.new(0, 10)
	sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
	sectionLayout.Parent = section
	
	-- Header
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 36)
	header.BackgroundTransparency = 1
	header.LayoutOrder = 0
	header.ZIndex = 83
	header.Parent = section
	
	local badge = Instance.new("Frame")
	badge.Size = UDim2.new(0, 125, 0, 32)
	badge.BackgroundColor3 = C.Purple
	badge.ZIndex = 84
	badge.Parent = header
	UI.pill(badge)
	
	local badgeLabel = Instance.new("TextLabel")
	badgeLabel.Size = UDim2.fromScale(1, 1)
	badgeLabel.BackgroundTransparency = 1
	badgeLabel.Font = F.Button
	badgeLabel.TextSize = 14
	badgeLabel.TextColor3 = C.White
	badgeLabel.Text = "Entertainment"
	badgeLabel.ZIndex = 85
	badgeLabel.Parent = badge
	
	local countLabel = Instance.new("TextLabel")
	countLabel.Size = UDim2.new(0, 80, 1, 0)
	countLabel.Position = UDim2.new(0, 135, 0, 0)
	countLabel.BackgroundTransparency = 1
	countLabel.Font = F.Medium
	countLabel.TextSize = 13
	countLabel.TextColor3 = C.Gray400
	countLabel.TextXAlignment = Enum.TextXAlignment.Left
	countLabel.Text = #Entertainment .. " options"
	countLabel.ZIndex = 84
	countLabel.Parent = header
	
	for i, item in ipairs(Entertainment) do
		self:createActivityCard(section, item, i, C.Purple, C.PurplePale)
	end
end

function ActivitiesScreen:populateCrime()
	self:updateInfoBar()
	
	-- Warning card
	local warningCard = Instance.new("Frame")
	warningCard.Size = UDim2.new(1, 0, 0, 75)
	warningCard.BackgroundColor3 = C.RedPale
	warningCard.LayoutOrder = 0
	warningCard.ZIndex = 82
	warningCard.Parent = self.contentScroll
	UI.corner(warningCard, 16)
	UI.stroke(warningCard, 1, 0.7, C.Red)
	
	local warnIcon = Instance.new("TextLabel")
	warnIcon.Size = UDim2.new(0, 50, 0, 50)
	warnIcon.Position = UDim2.new(0, 14, 0.5, -25)
	warnIcon.BackgroundTransparency = 1
	warnIcon.Font = F.Title
	warnIcon.TextSize = 24
	warnIcon.Text = "WARNING"
	warnIcon.TextColor3 = C.Red
	warnIcon.ZIndex = 83
	warnIcon.Parent = warningCard
	
	local warnText = Instance.new("TextLabel")
	warnText.Size = UDim2.new(1, -80, 1, -16)
	warnText.Position = UDim2.new(0, 70, 0, 8)
	warnText.BackgroundTransparency = 1
	warnText.Font = F.Body
	warnText.TextSize = 13
	warnText.TextColor3 = C.RedDark
	warnText.TextXAlignment = Enum.TextXAlignment.Left
	warnText.TextWrapped = true
	warnText.Text = "Crime is risky! You can get caught and go to prison. Higher risk = higher reward."
	warnText.ZIndex = 83
	warnText.Parent = warningCard
	
	-- Crime section
	local section = Instance.new("Frame")
	section.Name = "CrimeSection"
	section.Size = UDim2.new(1, 0, 0, 0)
	section.AutomaticSize = Enum.AutomaticSize.Y
	section.BackgroundColor3 = C.White
	section.LayoutOrder = 1
	section.ZIndex = 82
	section.Parent = self.contentScroll
	UI.corner(section, 18)
	UI.stroke(section, 1, 0.88, C.Gray200)
	UI.pad(section, 14, 14, 14, 16)
	
	local sectionLayout = Instance.new("UIListLayout")
	sectionLayout.Padding = UDim.new(0, 10)
	sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
	sectionLayout.Parent = section
	
	-- Header
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 36)
	header.BackgroundTransparency = 1
	header.LayoutOrder = 0
	header.ZIndex = 83
	header.Parent = section
	
	local badge = Instance.new("Frame")
	badge.Size = UDim2.new(0, 125, 0, 32)
	badge.BackgroundColor3 = C.Red
	badge.ZIndex = 84
	badge.Parent = header
	UI.pill(badge)
	
	local badgeLabel = Instance.new("TextLabel")
	badgeLabel.Size = UDim2.fromScale(1, 1)
	badgeLabel.BackgroundTransparency = 1
	badgeLabel.Font = F.Button
	badgeLabel.TextSize = 14
	badgeLabel.TextColor3 = C.White
	badgeLabel.Text = "Criminal Acts"
	badgeLabel.ZIndex = 85
	badgeLabel.Parent = badge
	
	for i, item in ipairs(Crimes) do
		self:createCrimeCard(section, item, i)
	end
end

function ActivitiesScreen:populatePrison()
	self:updateInfoBar()
	
	-- Prison status header
	local headerCard = Instance.new("Frame")
	headerCard.Size = UDim2.new(1, 0, 0, 85)
	headerCard.BackgroundColor3 = C.Gray800
	headerCard.LayoutOrder = 0
	headerCard.ZIndex = 82
	headerCard.Parent = self.contentScroll
	UI.corner(headerCard, 18)
	
	local headerIcon = Instance.new("TextLabel")
	headerIcon.Size = UDim2.new(0, 55, 0, 55)
	headerIcon.Position = UDim2.new(0, 16, 0.5, -27.5)
	headerIcon.BackgroundTransparency = 1
	headerIcon.Font = F.Title
	headerIcon.TextSize = 28
	headerIcon.Text = "PRISON"
	headerIcon.TextColor3 = C.White
	headerIcon.ZIndex = 83
	headerIcon.Parent = headerCard
	
	local headerText = Instance.new("TextLabel")
	headerText.Size = UDim2.new(1, -85, 0, 26)
	headerText.Position = UDim2.new(0, 80, 0, 16)
	headerText.BackgroundTransparency = 1
	headerText.Font = F.Title
	headerText.TextSize = 20
	headerText.TextColor3 = C.White
	headerText.TextXAlignment = Enum.TextXAlignment.Left
	headerText.Text = "You're in Prison"
	headerText.ZIndex = 83
	headerText.Parent = headerCard
	
	local headerSub = Instance.new("TextLabel")
	headerSub.Size = UDim2.new(1, -85, 0, 20)
	headerSub.Position = UDim2.new(0, 80, 0, 44)
	headerSub.BackgroundTransparency = 1
	headerSub.Font = F.Body
	headerSub.TextSize = 14
	headerSub.TextColor3 = C.Gray400
	headerSub.TextXAlignment = Enum.TextXAlignment.Left
	headerSub.Text = "Choose your actions wisely..."
	headerSub.ZIndex = 83
	headerSub.Parent = headerCard
	
	-- Prison section
	local section = Instance.new("Frame")
	section.Name = "PrisonSection"
	section.Size = UDim2.new(1, 0, 0, 0)
	section.AutomaticSize = Enum.AutomaticSize.Y
	section.BackgroundColor3 = C.White
	section.LayoutOrder = 1
	section.ZIndex = 82
	section.Parent = self.contentScroll
	UI.corner(section, 18)
	UI.stroke(section, 1, 0.88, C.Gray200)
	UI.pad(section, 14, 14, 14, 16)
	
	local sectionLayout = Instance.new("UIListLayout")
	sectionLayout.Padding = UDim.new(0, 10)
	sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
	sectionLayout.Parent = section
	
	-- Header
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 36)
	header.BackgroundTransparency = 1
	header.LayoutOrder = 0
	header.ZIndex = 83
	header.Parent = section
	
	local badge = Instance.new("Frame")
	badge.Size = UDim2.new(0, 130, 0, 32)
	badge.BackgroundColor3 = C.Gray600
	badge.ZIndex = 84
	badge.Parent = header
	UI.pill(badge)
	
	local badgeLabel = Instance.new("TextLabel")
	badgeLabel.Size = UDim2.fromScale(1, 1)
	badgeLabel.BackgroundTransparency = 1
	badgeLabel.Font = F.Button
	badgeLabel.TextSize = 14
	badgeLabel.TextColor3 = C.White
	badgeLabel.Text = "Prison Actions"
	badgeLabel.ZIndex = 85
	badgeLabel.Parent = badge
	
	for i, item in ipairs(PrisonActivities) do
		self:createPrisonCard(section, item, i)
	end
end

function ActivitiesScreen:createActivityCard(parent, item, order, accentColor, paleColor)
	local age = self:getAge()
	local money = self:getMoney()
	local cost = item.cost or 0
	local canDo = age >= item.minAge and money >= cost and not self:isInJail()
	
	local card = Instance.new("Frame")
	card.Name = item.id
	card.Size = UDim2.new(1, 0, 0, 85)
	card.BackgroundColor3 = C.White
	card.LayoutOrder = order
	card.ZIndex = 83
	card.Parent = parent
	UI.corner(card, 14)
	UI.stroke(card, 1, canDo and 0.7 or 0.88, canDo and accentColor or C.Gray200)
	
	-- Icon frame
	local iconFrame = Instance.new("Frame")
	iconFrame.Size = UDim2.new(0, 54, 0, 54)
	iconFrame.Position = UDim2.new(0, 12, 0.5, -27)
	iconFrame.BackgroundColor3 = paleColor
	iconFrame.ZIndex = 84
	iconFrame.Parent = card
	UI.corner(iconFrame, 12)
	
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.fromScale(1, 1)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Font = F.Medium
	iconLabel.TextSize = 11
	iconLabel.TextColor3 = accentColor
	iconLabel.Text = item.emoji
	iconLabel.ZIndex = 85
	iconLabel.Parent = iconFrame
	
	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0.5, 0, 0, 22)
	titleLabel.Position = UDim2.new(0, 78, 0, 12)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = F.Title
	titleLabel.TextSize = 15
	titleLabel.TextColor3 = canDo and C.Gray900 or C.Gray500
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = item.name
	titleLabel.ZIndex = 84
	titleLabel.Parent = card
	
	-- Effect badge
	local effectBadge = Instance.new("Frame")
	effectBadge.Size = UDim2.new(0, cost > 0 and 135 or 105, 0, 24)
	effectBadge.Position = UDim2.new(0, 78, 0, 38)
	effectBadge.BackgroundColor3 = cost > 0 and C.AmberPale or C.GreenPale
	effectBadge.ZIndex = 84
	effectBadge.Parent = card
	UI.pill(effectBadge)
	
	local effectLabel = Instance.new("TextLabel")
	effectLabel.Size = UDim2.fromScale(1, 1)
	effectLabel.BackgroundTransparency = 1
	effectLabel.Font = F.Medium
	effectLabel.TextSize = 11
	effectLabel.TextColor3 = cost > 0 and C.AmberDark or C.GreenDark
	effectLabel.Text = item.effect .. (cost > 0 and " | $" .. cost or "")
	effectLabel.ZIndex = 85
	effectLabel.Parent = effectBadge
	
	-- Minigame indicator
	if item.hasMinigame then
		local miniLabel = Instance.new("TextLabel")
		miniLabel.Size = UDim2.new(0, 80, 0, 16)
		miniLabel.Position = UDim2.new(0, 78, 0, 65)
		miniLabel.BackgroundTransparency = 1
		miniLabel.Font = F.Body
		miniLabel.TextSize = 11
		miniLabel.TextColor3 = C.Purple
		miniLabel.TextXAlignment = Enum.TextXAlignment.Left
		miniLabel.Text = "Minigame!"
		miniLabel.ZIndex = 84
		miniLabel.Parent = card
	end
	
	-- Action button
	local actionBtn = Instance.new("TextButton")
	actionBtn.Size = UDim2.new(0, 68, 0, 42)
	actionBtn.AnchorPoint = Vector2.new(1, 0.5)
	actionBtn.Position = UDim2.new(1, -12, 0.5, 0)
	actionBtn.BackgroundColor3 = canDo and accentColor or C.Gray300
	actionBtn.Font = F.Button
	actionBtn.TextSize = 14
	actionBtn.TextColor3 = canDo and C.White or C.Gray500
	actionBtn.AutoButtonColor = false
	actionBtn.ZIndex = 84
	actionBtn.Parent = card
	UI.corner(actionBtn, 12)
	
	if canDo then
		actionBtn.Text = "Go!"
		actionBtn.MouseEnter:Connect(function()
			UI.tween(actionBtn, TweenInfo.new(0.12), { BackgroundColor3 = accentColor:Lerp(C.Black, 0.15) })
		end)
		actionBtn.MouseLeave:Connect(function()
			UI.tween(actionBtn, TweenInfo.new(0.12), { BackgroundColor3 = accentColor })
		end)
		actionBtn.MouseButton1Click:Connect(function()
			if item.hasMinigame then
				self:showMinigame(item, accentColor)
			else
				self:doActivity(item)
			end
		end)
	else
		actionBtn.Text = age < item.minAge and "Age " .. item.minAge or (money < cost and "Need $" or "Jailed")
	end
end

function ActivitiesScreen:createCrimeCard(parent, item, order)
	local age = self:getAge()
	local canDo = age >= item.minAge and not self:isInJail()
	
	local card = Instance.new("Frame")
	card.Name = item.id
	card.Size = UDim2.new(1, 0, 0, 90)
	card.BackgroundColor3 = C.White
	card.LayoutOrder = order
	card.ZIndex = 83
	card.Parent = parent
	UI.corner(card, 14)
	UI.stroke(card, canDo and 1 or 1, canDo and 0.7 or 0.88, canDo and C.Red or C.Gray200)
	
	-- Icon
	local iconFrame = Instance.new("Frame")
	iconFrame.Size = UDim2.new(0, 56, 0, 56)
	iconFrame.Position = UDim2.new(0, 12, 0.5, -28)
	iconFrame.BackgroundColor3 = C.RedPale
	iconFrame.ZIndex = 84
	iconFrame.Parent = card
	UI.corner(iconFrame, 12)
	
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.fromScale(1, 1)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Font = F.Medium
	iconLabel.TextSize = 11
	iconLabel.TextColor3 = C.Red
	iconLabel.Text = item.emoji
	iconLabel.ZIndex = 85
	iconLabel.Parent = iconFrame
	
	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0.5, 0, 0, 22)
	titleLabel.Position = UDim2.new(0, 80, 0, 10)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = F.Title
	titleLabel.TextSize = 15
	titleLabel.TextColor3 = canDo and C.Gray900 or C.Gray500
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = item.name
	titleLabel.ZIndex = 84
	titleLabel.Parent = card
	
	-- Risk badge
	local riskColor = item.risk >= 60 and C.RedPale or item.risk >= 40 and C.AmberPale or C.GreenPale
	local riskText = item.risk >= 60 and C.RedDark or item.risk >= 40 and C.AmberDark or C.GreenDark
	
	local riskBadge = Instance.new("Frame")
	riskBadge.Size = UDim2.new(0, 85, 0, 24)
	riskBadge.Position = UDim2.new(0, 80, 0, 34)
	riskBadge.BackgroundColor3 = riskColor
	riskBadge.ZIndex = 84
	riskBadge.Parent = card
	UI.pill(riskBadge)
	
	local riskLabel = Instance.new("TextLabel")
	riskLabel.Size = UDim2.fromScale(1, 1)
	riskLabel.BackgroundTransparency = 1
	riskLabel.Font = F.Medium
	riskLabel.TextSize = 11
	riskLabel.TextColor3 = riskText
	riskLabel.Text = "Risk: " .. item.risk .. "%"
	riskLabel.ZIndex = 85
	riskLabel.Parent = riskBadge
	
	-- Reward
	local rewardLabel = Instance.new("TextLabel")
	rewardLabel.Size = UDim2.new(0.4, 0, 0, 18)
	rewardLabel.Position = UDim2.new(0, 80, 0, 62)
	rewardLabel.BackgroundTransparency = 1
	rewardLabel.Font = F.Body
	rewardLabel.TextSize = 12
	rewardLabel.TextColor3 = C.Gray500
	rewardLabel.TextXAlignment = Enum.TextXAlignment.Left
	rewardLabel.Text = "Reward: " .. item.reward
	rewardLabel.ZIndex = 84
	rewardLabel.Parent = card
	
	-- Action button
	local actionBtn = Instance.new("TextButton")
	actionBtn.Size = UDim2.new(0, 78, 0, 44)
	actionBtn.AnchorPoint = Vector2.new(1, 0.5)
	actionBtn.Position = UDim2.new(1, -12, 0.5, 0)
	actionBtn.BackgroundColor3 = canDo and C.Red or C.Gray300
	actionBtn.Font = F.Button
	actionBtn.TextSize = 13
	actionBtn.TextColor3 = canDo and C.White or C.Gray500
	actionBtn.AutoButtonColor = false
	actionBtn.ZIndex = 84
	actionBtn.Parent = card
	UI.corner(actionBtn, 12)
	
	if canDo then
		actionBtn.Text = "Commit"
		actionBtn.MouseEnter:Connect(function()
			UI.tween(actionBtn, TweenInfo.new(0.12), { BackgroundColor3 = C.RedDark })
		end)
		actionBtn.MouseLeave:Connect(function()
			UI.tween(actionBtn, TweenInfo.new(0.12), { BackgroundColor3 = C.Red })
		end)
		actionBtn.MouseButton1Click:Connect(function()
			self:doCrime(item)
		end)
	else
		actionBtn.Text = age < item.minAge and "Age " .. item.minAge .. "+" or "Jailed"
	end
end

function ActivitiesScreen:createPrisonCard(parent, item, order)
	local money = self:getMoney()
	local cost = item.cost or 0
	local canDo = money >= cost
	
	local card = Instance.new("Frame")
	card.Name = item.id
	card.Size = UDim2.new(1, 0, 0, 90)
	card.BackgroundColor3 = C.White
	card.LayoutOrder = order
	card.ZIndex = 83
	card.Parent = parent
	UI.corner(card, 14)
	UI.stroke(card, 1, 0.88, C.Gray200)
	
	-- Icon
	local iconFrame = Instance.new("Frame")
	iconFrame.Size = UDim2.new(0, 56, 0, 56)
	iconFrame.Position = UDim2.new(0, 12, 0.5, -28)
	iconFrame.BackgroundColor3 = item.risk and C.RedPale or C.Gray100
	iconFrame.ZIndex = 84
	iconFrame.Parent = card
	UI.corner(iconFrame, 12)
	
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.fromScale(1, 1)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Font = F.Medium
	iconLabel.TextSize = 11
	iconLabel.TextColor3 = item.risk and C.Red or C.Gray600
	iconLabel.Text = item.emoji
	iconLabel.ZIndex = 85
	iconLabel.Parent = iconFrame
	
	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0.5, 0, 0, 22)
	titleLabel.Position = UDim2.new(0, 80, 0, 12)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = F.Title
	titleLabel.TextSize = 15
	titleLabel.TextColor3 = C.Gray900
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = item.name
	titleLabel.ZIndex = 84
	titleLabel.Parent = card
	
	-- Badge
	local badgeText = item.risk and ("Risk: " .. item.risk .. "%") or item.effect
	local badgeBg = item.risk and C.RedPale or C.GreenPale
	local badgeColor = item.risk and C.RedDark or C.GreenDark
	
	local effectBadge = Instance.new("Frame")
	effectBadge.Size = UDim2.new(0, 115, 0, 24)
	effectBadge.Position = UDim2.new(0, 80, 0, 38)
	effectBadge.BackgroundColor3 = badgeBg
	effectBadge.ZIndex = 84
	effectBadge.Parent = card
	UI.pill(effectBadge)
	
	local effectLabel = Instance.new("TextLabel")
	effectLabel.Size = UDim2.fromScale(1, 1)
	effectLabel.BackgroundTransparency = 1
	effectLabel.Font = F.Medium
	effectLabel.TextSize = 11
	effectLabel.TextColor3 = badgeColor
	effectLabel.Text = badgeText .. (cost > 0 and " | $" .. cost or "")
	effectLabel.ZIndex = 85
	effectLabel.Parent = effectBadge
	
	-- Action button
	local actionBtn = Instance.new("TextButton")
	actionBtn.Size = UDim2.new(0, 68, 0, 42)
	actionBtn.AnchorPoint = Vector2.new(1, 0.5)
	actionBtn.Position = UDim2.new(1, -12, 0.5, 0)
	actionBtn.BackgroundColor3 = canDo and (item.risk and C.Red or C.Amber) or C.Gray300
	actionBtn.Font = F.Button
	actionBtn.TextSize = 14
	actionBtn.TextColor3 = canDo and C.White or C.Gray500
	actionBtn.Text = canDo and "Go!" or "Need $"
	actionBtn.AutoButtonColor = false
	actionBtn.ZIndex = 84
	actionBtn.Parent = card
	UI.corner(actionBtn, 12)
	
	if canDo then
		actionBtn.MouseButton1Click:Connect(function()
			self:doPrisonActivity(item)
		end)
	end
end

function ActivitiesScreen:createResultModal()
	self.resultModal = UI.createModalCard(self.screenGui, {
		name = "ActivitiesResult",
		accentColor = C.Green,
		accentDark = C.GreenDark,
		accentPale = C.GreenPale,
		zIndex = 98
	})
	
	self.resultModal.closeArea.MouseButton1Click:Connect(function()
		UI.hideModal(self.resultModal, function() self:switchTab(self.currentTab) end)
	end)
	self.resultModal.okButton.MouseButton1Click:Connect(function()
		UI.hideModal(self.resultModal, function() self:switchTab(self.currentTab) end)
	end)
end

function ActivitiesScreen:createMinigameModal()
	self.minigameOverlay = Instance.new("Frame")
	self.minigameOverlay.Size = UDim2.fromScale(1, 1)
	self.minigameOverlay.BackgroundColor3 = C.Black
	self.minigameOverlay.BackgroundTransparency = 0.4
	self.minigameOverlay.Visible = false
	self.minigameOverlay.ZIndex = 96
	self.minigameOverlay.Parent = self.screenGui
	
	local card = Instance.new("Frame")
	card.Size = UDim2.new(0.9, 0, 0, 400)
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.fromScale(0.5, 0.5)
	card.BackgroundColor3 = C.White
	card.ZIndex = 97
	card.Parent = self.minigameOverlay
	UI.corner(card, 24)
	self.minigameCard = card
	
	-- Title
	self.minigameTitle = Instance.new("TextLabel")
	self.minigameTitle.Size = UDim2.new(1, 0, 0, 55)
	self.minigameTitle.BackgroundTransparency = 1
	self.minigameTitle.Font = F.Title
	self.minigameTitle.TextSize = 24
	self.minigameTitle.TextColor3 = C.Gray900
	self.minigameTitle.Text = "Tap to Workout!"
	self.minigameTitle.ZIndex = 98
	self.minigameTitle.Parent = card
	
	-- Progress bar
	local progressBg = Instance.new("Frame")
	progressBg.Size = UDim2.new(0.85, 0, 0, 26)
	progressBg.AnchorPoint = Vector2.new(0.5, 0)
	progressBg.Position = UDim2.new(0.5, 0, 0, 60)
	progressBg.BackgroundColor3 = C.Gray200
	progressBg.ZIndex = 98
	progressBg.Parent = card
	UI.pill(progressBg)
	
	self.progressFill = Instance.new("Frame")
	self.progressFill.Size = UDim2.new(0, 0, 1, 0)
	self.progressFill.BackgroundColor3 = C.Green
	self.progressFill.ZIndex = 99
	self.progressFill.Parent = progressBg
	UI.pill(self.progressFill)
	
	-- Tap area
	self.tapArea = Instance.new("TextButton")
	self.tapArea.Size = UDim2.new(0.65, 0, 0, 190)
	self.tapArea.AnchorPoint = Vector2.new(0.5, 0)
	self.tapArea.Position = UDim2.new(0.5, 0, 0, 100)
	self.tapArea.BackgroundColor3 = C.Cyan
	self.tapArea.Font = F.Title
	self.tapArea.TextSize = 50
	self.tapArea.TextColor3 = C.White
	self.tapArea.Text = "TAP!"
	self.tapArea.AutoButtonColor = false
	self.tapArea.ZIndex = 98
	self.tapArea.Parent = card
	UI.corner(self.tapArea, 24)
	
	-- Counter
	self.tapCounter = Instance.new("TextLabel")
	self.tapCounter.Size = UDim2.new(1, 0, 0, 45)
	self.tapCounter.AnchorPoint = Vector2.new(0.5, 0)
	self.tapCounter.Position = UDim2.new(0.5, 0, 0, 300)
	self.tapCounter.BackgroundTransparency = 1
	self.tapCounter.Font = F.Title
	self.tapCounter.TextSize = 32
	self.tapCounter.TextColor3 = C.Gray700
	self.tapCounter.Text = "0 / 20"
	self.tapCounter.ZIndex = 98
	self.tapCounter.Parent = card
	
	-- Instructions
	local instr = Instance.new("TextLabel")
	instr.Size = UDim2.new(1, 0, 0, 30)
	instr.AnchorPoint = Vector2.new(0.5, 0)
	instr.Position = UDim2.new(0.5, 0, 0, 350)
	instr.BackgroundTransparency = 1
	instr.Font = F.Body
	instr.TextSize = 15
	instr.TextColor3 = C.Gray500
	instr.Text = "Tap as fast as you can!"
	instr.ZIndex = 98
	instr.Parent = card
	
	-- Variables
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
		
		-- Pulse
		UI.tween(self.tapArea, TweenInfo.new(0.05), { Size = UDim2.new(0.62, 0, 0, 185) })
		task.delay(0.05, function()
			UI.tween(self.tapArea, TweenInfo.new(0.1), { Size = UDim2.new(0.65, 0, 0, 190) })
		end)
		
		-- Progress
		local progress = math.clamp(self.tapCount / self.tapGoal, 0, 1)
		UI.tween(self.progressFill, TweenInfo.new(0.1), { Size = UDim2.new(progress, 0, 1, 0) })
		
		-- Win check
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
	
	local title = item.id == "gym" and "Tap to Workout!" or "Tap to Study!"
	
	self.minigameTitle.Text = title
	self.tapArea.Text = "TAP!"
	self.tapArea.BackgroundColor3 = accentColor
	self.progressFill.BackgroundColor3 = accentColor
	self.progressFill.Size = UDim2.new(0, 0, 1, 0)
	self.tapCounter.Text = "0 / " .. self.tapGoal
	
	self.minigameOverlay.Visible = true
	self.minigameCard.Position = UDim2.new(0.5, 0, 0.5, 50)
	self.minigameCard.BackgroundTransparency = 1
	
	UI.tween(self.minigameCard, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
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
		
		if success then
			self:doActivity(self.currentMinigameItem, true)
		else
			self:showResult(false, "You gave up halfway through. No gains today!", "Failed")
		end
	end)
end

function ActivitiesScreen:doActivity(item, bonus)
	if not DoActivity then
		self:showResult(false, "Server not available", "Error")
		return
	end
	
	local result = DoActivity:InvokeServer(item.id, bonus or false)
	if result then
		self:showResult(result.success, result.message, result.success and "Done!" or "Failed")
	else
		self:showResult(false, "Server error", "Error")
	end
end

function ActivitiesScreen:doCrime(item)
	if not CommitCrime then
		self:showResult(false, "Server not available", "Error")
		return
	end
	
	local result = CommitCrime:InvokeServer(item.id)
	if result then
		local emoji = result.caught and "Caught!" or (result.success and "Success!" or "Failed")
		self:showResult(result.success, result.message, emoji)
	else
		self:showResult(false, "Server error", "Error")
	end
end

function ActivitiesScreen:doPrisonActivity(item)
	if not DoPrisonAction then
		self:showResult(false, "Server not available", "Error")
		return
	end
	
	local result = DoPrisonAction:InvokeServer(item.id)
	if result then
		local emoji = result.success and "Done!" or "Failed"
		if item.id == "prison_escape" then emoji = result.success and "Free!" or "Caught!" end
		if item.id == "prison_riot" then emoji = result.success and "Chaos!" or "Caught!" end
		self:showResult(result.success, result.message, emoji)
	else
		self:showResult(false, "Server error", "Error")
	end
end

function ActivitiesScreen:showResult(success, message, emoji)
	local shellColor = success and C.Green or C.Red
	local shellStroke = success and C.GreenDark or C.RedDark
	local pale = success and C.GreenPale or C.RedPale
	
	self.resultModal.shell.BackgroundColor3 = shellColor
	self.resultModal.shellStroke.Color = shellStroke
	self.resultModal.emojiFrame.BackgroundColor3 = pale
	self.resultModal.emojiLabel.Text = emoji or (success and "OK" or "X")
	self.resultModal.titleLabel.Text = success and "Success!" or "Uh oh..."
	self.resultModal.titleLabel.TextColor3 = success and C.GreenDark or C.RedDark
	self.resultModal.messageLabel.Text = message or ""
	self.resultModal.okButton.BackgroundColor3 = shellColor
	
	UI.showModal(self.resultModal)
end

function ActivitiesScreen:show()
	self:updateInfoBar()
	self:rebuildTabs()
	self:switchTab(self.currentTab)
	UI.slideInScreen(self.overlay, "right")
	self.isVisible = true
end

function ActivitiesScreen:hide()
	UI.slideOutScreen(self.overlay, "right", function()
		self.resultModal.overlay.Visible = false
		self.minigameOverlay.Visible = false
	end)
	self.isVisible = false
end

return ActivitiesScreen
