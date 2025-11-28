-- ActivitiesScreen.lua
-- Premium AAA-quality Activities screen with server validation

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ActivitiesScreen = {}
ActivitiesScreen.__index = ActivitiesScreen

local remotesFolder = ReplicatedStorage:WaitForChild("LifeRemotes", 10)
local DoActivity = remotesFolder and remotesFolder:FindFirstChild("DoActivity")
local CommitCrime = remotesFolder and remotesFolder:FindFirstChild("CommitCrime")
local Gamble = remotesFolder and remotesFolder:FindFirstChild("Gamble")

-- Premium Colors
local C = {
	Amber = Color3.fromRGB(245, 158, 11),
	AmberDark = Color3.fromRGB(217, 119, 6),
	AmberPale = Color3.fromRGB(254, 243, 199),
	Blue = Color3.fromRGB(37, 99, 235),
	BlueDark = Color3.fromRGB(29, 78, 216),
	BluePale = Color3.fromRGB(219, 234, 254),
	Green = Color3.fromRGB(34, 197, 94),
	GreenDark = Color3.fromRGB(22, 163, 74),
	GreenPale = Color3.fromRGB(220, 252, 231),
	Purple = Color3.fromRGB(139, 92, 246),
	PurplePale = Color3.fromRGB(237, 233, 254),
	Red = Color3.fromRGB(239, 68, 68),
	RedDark = Color3.fromRGB(220, 38, 38),
	RedPale = Color3.fromRGB(254, 226, 226),
	Pink = Color3.fromRGB(236, 72, 153),
	PinkPale = Color3.fromRGB(252, 231, 243),
	Cyan = Color3.fromRGB(6, 182, 212),
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
	Gray900 = Color3.fromRGB(17, 24, 39),
	Black = Color3.fromRGB(0, 0, 0),
	Bg = Color3.fromRGB(241, 245, 249),
}

local F = { Title = Enum.Font.GothamBold, Body = Enum.Font.Gotham, Medium = Enum.Font.GothamMedium, Button = Enum.Font.GothamBold }

-- Sample Data
local MindBody = {
	{ id = "gym", name = "Hit the Gym", emoji = "🏋️", effect = "+Health", minAge = 12, cost = 0 },
	{ id = "meditate", name = "Meditate", emoji = "🧘", effect = "+Happiness", minAge = 10, cost = 0 },
	{ id = "study", name = "Study", emoji = "📚", effect = "+Smarts", minAge = 6, cost = 0 },
	{ id = "spa", name = "Visit Spa", emoji = "💆", effect = "+Looks", minAge = 16, cost = 200 },
}

local Social = {
	{ id = "party", name = "Go to Party", emoji = "🎉", effect = "+Happiness", minAge = 16, cost = 0 },
	{ id = "date", name = "Go on a Date", emoji = "💕", effect = "+Happiness", minAge = 16, cost = 100 },
	{ id = "club", name = "Night Club", emoji = "🕺", effect = "+Happiness", minAge = 21, cost = 150 },
}

local Entertainment = {
	{ id = "movie", name = "Watch Movie", emoji = "🎬", effect = "+Happiness", minAge = 5, cost = 20 },
	{ id = "concert", name = "Concert", emoji = "🎤", effect = "+Happiness", minAge = 12, cost = 100 },
	{ id = "vacation", name = "Vacation", emoji = "✈️", effect = "+Happiness", minAge = 10, cost = 2000 },
}

local Crimes = {
	{ id = "shoplift", name = "Shoplift", emoji = "🛒", risk = 30, reward = "up to $100", minAge = 10 },
	{ id = "pickpocket", name = "Pickpocket", emoji = "👛", risk = 40, reward = "up to $500", minAge = 12 },
	{ id = "burglary", name = "Burglary", emoji = "🏠", risk = 60, reward = "up to $5,000", minAge = 16 },
	{ id = "robbery", name = "Armed Robbery", emoji = "🔫", risk = 80, reward = "up to $50,000", minAge = 18 },
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
	return self
end

function ActivitiesScreen:getAge() return self.playerState and self.playerState.Age or 0 end
function ActivitiesScreen:getMoney() return self.playerState and self.playerState.Money or 0 end
function ActivitiesScreen:isInJail() return self.playerState and self.playerState.InJail or false end

function ActivitiesScreen:createUI()
	self.overlay = Instance.new("Frame")
	self.overlay.Name = "ActivitiesOverlay"
	self.overlay.Size = UDim2.fromScale(1, 1)
	self.overlay.BackgroundColor3 = C.Bg
	self.overlay.Visible = false
	self.overlay.ZIndex = 80
	self.overlay.Parent = self.screenGui
	
	-- Header
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 56)
	header.BackgroundColor3 = C.Amber
	header.ZIndex = 85
	header.Parent = self.overlay
	
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
	
	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 44, 0, 44)
	closeBtn.AnchorPoint = Vector2.new(1, 0.5)
	closeBtn.Position = UDim2.new(1, -8, 0.5, 0)
	closeBtn.BackgroundColor3 = C.White
	closeBtn.BackgroundTransparency = 0.9
	closeBtn.Font = F.Title
	closeBtn.TextSize = 22
	closeBtn.TextColor3 = C.White
	closeBtn.Text = "✕"
	closeBtn.AutoButtonColor = false
	closeBtn.ZIndex = 86
	closeBtn.Parent = header
	corner(closeBtn, 22)
	
	closeBtn.MouseButton1Click:Connect(function() self:hide() end)
	closeBtn.MouseEnter:Connect(function() tween(closeBtn, TweenInfo.new(0.1), { BackgroundTransparency = 0.7 }) end)
	closeBtn.MouseLeave:Connect(function() tween(closeBtn, TweenInfo.new(0.1), { BackgroundTransparency = 0.9 }) end)
	
	-- Info bar
	self.infoBar = Instance.new("Frame")
	self.infoBar.Size = UDim2.new(1, -16, 0, 44)
	self.infoBar.Position = UDim2.new(0, 8, 0, 64)
	self.infoBar.BackgroundColor3 = C.White
	self.infoBar.ZIndex = 84
	self.infoBar.Parent = self.overlay
	corner(self.infoBar, 12)
	stroke(self.infoBar, 1, 0.9, C.Gray200)
	
	local infoLayout = Instance.new("UIListLayout")
	infoLayout.FillDirection = Enum.FillDirection.Horizontal
	infoLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	infoLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	infoLayout.Padding = UDim.new(0, 16)
	infoLayout.Parent = self.infoBar
	
	self.ageChip = self:createInfoChip(self.infoBar, "👤", "Age 0", 1)
	self.moneyChip = self:createInfoChip(self.infoBar, "💵", "$0", 2)
	self.statusChip = self:createInfoChip(self.infoBar, "✓", "Free", 3)
	
	-- Tab bar
	local tabBar = Instance.new("Frame")
	tabBar.Size = UDim2.new(1, -16, 0, 42)
	tabBar.Position = UDim2.new(0, 8, 0, 116)
	tabBar.BackgroundColor3 = C.Gray100
	tabBar.ZIndex = 84
	tabBar.Parent = self.overlay
	corner(tabBar, 12)
	
	pad(tabBar, 3, 3, 4, 4)
	
	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	tabLayout.Padding = UDim.new(0, 3)
	tabLayout.Parent = tabBar
	
	self.tabBtns = {}
	local tabs = {
		{ id = "mindbody", text = "🧘 Mind" },
		{ id = "social", text = "🎉 Social" },
		{ id = "fun", text = "🎬 Fun" },
		{ id = "crime", text = "💀 Crime" },
	}
	
	for i, tab in ipairs(tabs) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0.24, 0, 1, 0)
		btn.BackgroundColor3 = i == 1 and C.Amber or C.White
		btn.Font = F.Button
		btn.TextSize = 10
		btn.TextColor3 = i == 1 and C.White or C.Gray600
		btn.Text = tab.text
		btn.AutoButtonColor = false
		btn.LayoutOrder = i
		btn.ZIndex = 85
		btn.Parent = tabBar
		corner(btn, 10)
		
		self.tabBtns[tab.id] = btn
		btn.MouseButton1Click:Connect(function() self:switchTab(tab.id) end)
	end
	
	-- Content
	self.contentScroll = Instance.new("ScrollingFrame")
	self.contentScroll.Size = UDim2.new(1, -16, 1, -180)
	self.contentScroll.Position = UDim2.new(0, 8, 0, 166)
	self.contentScroll.BackgroundTransparency = 1
	self.contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	self.contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	self.contentScroll.ScrollBarThickness = 3
	self.contentScroll.ScrollBarImageColor3 = C.Gray300
	self.contentScroll.ZIndex = 81
	self.contentScroll.Parent = self.overlay
	
	self.contentLayout = Instance.new("UIListLayout")
	self.contentLayout.Padding = UDim.new(0, 10)
	self.contentLayout.Parent = self.contentScroll
	
	self:populateMindBody()
end

function ActivitiesScreen:createInfoChip(parent, icon, text, order)
	local chip = Instance.new("Frame")
	chip.Size = UDim2.new(0, 85, 0, 32)
	chip.BackgroundColor3 = C.Gray50
	chip.LayoutOrder = order
	chip.ZIndex = 85
	chip.Parent = parent
	corner(chip, 8)
	
	local iconLbl = Instance.new("TextLabel")
	iconLbl.Size = UDim2.new(0, 22, 1, 0)
	iconLbl.Position = UDim2.new(0, 6, 0, 0)
	iconLbl.BackgroundTransparency = 1
	iconLbl.Font = F.Body
	iconLbl.TextSize = 13
	iconLbl.Text = icon
	iconLbl.ZIndex = 86
	iconLbl.Parent = chip
	
	local textLbl = Instance.new("TextLabel")
	textLbl.Name = "Text"
	textLbl.Size = UDim2.new(1, -28, 1, 0)
	textLbl.Position = UDim2.new(0, 26, 0, 0)
	textLbl.BackgroundTransparency = 1
	textLbl.Font = F.Medium
	textLbl.TextSize = 11
	textLbl.TextColor3 = C.Gray700
	textLbl.TextXAlignment = Enum.TextXAlignment.Left
	textLbl.Text = text
	textLbl.ZIndex = 86
	textLbl.Parent = chip
	
	return textLbl
end

function ActivitiesScreen:updateInfoBar()
	self.ageChip.Text = "Age " .. self:getAge()
	self.moneyChip.Text = formatMoney(self:getMoney())
	self.statusChip.Text = self:isInJail() and "In Jail" or "Free"
	local chip = self.statusChip.Parent
	chip.BackgroundColor3 = self:isInJail() and C.RedPale or C.GreenPale
end

function ActivitiesScreen:switchTab(tabId)
	self.currentTab = tabId
	
	for id, btn in pairs(self.tabBtns) do
		local isActive = id == tabId
		tween(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = isActive and (tabId == "crime" and C.Red or C.Amber) or C.White,
			TextColor3 = isActive and C.White or C.Gray600
		})
	end
	
	for _, child in ipairs(self.contentScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	
	if tabId == "mindbody" then self:populateMindBody()
	elseif tabId == "social" then self:populateSocial()
	elseif tabId == "fun" then self:populateFun()
	else self:populateCrime() end
end

function ActivitiesScreen:createActivityCard(parent, item, order, bgColor, accentColor)
	local age = self:getAge()
	local money = self:getMoney()
	local cost = item.cost or 0
	local canDo = age >= item.minAge and money >= cost and not self:isInJail()
	
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 76)
	card.BackgroundColor3 = C.White
	card.LayoutOrder = order
	card.ZIndex = 82
	card.Parent = parent
	corner(card, 14)
	stroke(card, 1, 0.9, C.Gray200)
	
	-- Icon
	local iconFrame = Instance.new("Frame")
	iconFrame.Size = UDim2.new(0, 50, 0, 50)
	iconFrame.Position = UDim2.new(0, 12, 0.5, -25)
	iconFrame.BackgroundColor3 = bgColor
	iconFrame.ZIndex = 83
	iconFrame.Parent = card
	corner(iconFrame, 12)
	
	local iconLbl = Instance.new("TextLabel")
	iconLbl.Size = UDim2.fromScale(1, 1)
	iconLbl.BackgroundTransparency = 1
	iconLbl.Font = F.Body
	iconLbl.TextSize = 26
	iconLbl.Text = item.emoji
	iconLbl.ZIndex = 84
	iconLbl.Parent = iconFrame
	
	-- Name
	local nameLbl = Instance.new("TextLabel")
	nameLbl.Size = UDim2.new(0.5, 0, 0, 20)
	nameLbl.Position = UDim2.new(0, 72, 0, 14)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Font = F.Title
	nameLbl.TextSize = 14
	nameLbl.TextColor3 = C.Gray900
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.Text = item.name
	nameLbl.ZIndex = 83
	nameLbl.Parent = card
	
	-- Effect/Cost
	local effectBadge = Instance.new("Frame")
	effectBadge.Size = UDim2.new(0, 80, 0, 22)
	effectBadge.Position = UDim2.new(0, 72, 0, 40)
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
	
	-- Do button
	local doBtn = Instance.new("TextButton")
	doBtn.Size = UDim2.new(0, 60, 0, 34)
	doBtn.AnchorPoint = Vector2.new(1, 0.5)
	doBtn.Position = UDim2.new(1, -12, 0.5, 0)
	doBtn.BackgroundColor3 = canDo and accentColor or C.Gray300
	doBtn.Font = F.Button
	doBtn.TextSize = 12
	doBtn.TextColor3 = canDo and C.White or C.Gray500
	doBtn.Text = canDo and "Go" or (age < item.minAge and "Age " .. item.minAge .. "+" or money < cost and "Need $" or "Jailed")
	doBtn.AutoButtonColor = false
	doBtn.ZIndex = 83
	doBtn.Parent = card
	pill(doBtn)
	
	if canDo then
		doBtn.MouseEnter:Connect(function() tween(doBtn, TweenInfo.new(0.1), { Size = UDim2.new(0, 66, 0, 38) }) end)
		doBtn.MouseLeave:Connect(function() tween(doBtn, TweenInfo.new(0.1), { Size = UDim2.new(0, 60, 0, 34) }) end)
		doBtn.MouseButton1Click:Connect(function()
			if DoActivity then
				local result = DoActivity:InvokeServer(item.id)
				if result then
					self:showResult(result.success, result.message, result.emoji)
				else
					self:showResult(false, "Server error")
				end
			end
		end)
	end
end

function ActivitiesScreen:createCrimeCard(parent, item, order)
	local age = self:getAge()
	local canDo = age >= item.minAge and not self:isInJail()
	
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 80)
	card.BackgroundColor3 = C.White
	card.LayoutOrder = order
	card.ZIndex = 82
	card.Parent = parent
	corner(card, 14)
	stroke(card, 1, 0.9, canDo and C.Red or C.Gray200)
	
	-- Icon
	local iconFrame = Instance.new("Frame")
	iconFrame.Size = UDim2.new(0, 50, 0, 50)
	iconFrame.Position = UDim2.new(0, 12, 0.5, -25)
	iconFrame.BackgroundColor3 = C.RedPale
	iconFrame.ZIndex = 83
	iconFrame.Parent = card
	corner(iconFrame, 12)
	
	local iconLbl = Instance.new("TextLabel")
	iconLbl.Size = UDim2.fromScale(1, 1)
	iconLbl.BackgroundTransparency = 1
	iconLbl.Font = F.Body
	iconLbl.TextSize = 26
	iconLbl.Text = item.emoji
	iconLbl.ZIndex = 84
	iconLbl.Parent = iconFrame
	
	-- Name
	local nameLbl = Instance.new("TextLabel")
	nameLbl.Size = UDim2.new(0.5, 0, 0, 18)
	nameLbl.Position = UDim2.new(0, 72, 0, 12)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Font = F.Title
	nameLbl.TextSize = 14
	nameLbl.TextColor3 = C.Gray900
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.Text = item.name
	nameLbl.ZIndex = 83
	nameLbl.Parent = card
	
	-- Risk badge
	local riskBadge = Instance.new("Frame")
	riskBadge.Size = UDim2.new(0, 70, 0, 20)
	riskBadge.Position = UDim2.new(0, 72, 0, 34)
	riskBadge.BackgroundColor3 = item.risk >= 60 and C.RedPale or item.risk >= 40 and C.AmberPale or C.GreenPale
	riskBadge.ZIndex = 83
	riskBadge.Parent = card
	pill(riskBadge)
	
	local riskLbl = Instance.new("TextLabel")
	riskLbl.Size = UDim2.fromScale(1, 1)
	riskLbl.BackgroundTransparency = 1
	riskLbl.Font = F.Medium
	riskLbl.TextSize = 10
	riskLbl.TextColor3 = item.risk >= 60 and C.RedDark or item.risk >= 40 and C.AmberDark or C.GreenDark
	riskLbl.Text = "⚠️ " .. item.risk .. "% risk"
	riskLbl.ZIndex = 84
	riskLbl.Parent = riskBadge
	
	-- Reward
	local rewardLbl = Instance.new("TextLabel")
	rewardLbl.Size = UDim2.new(0.4, 0, 0, 16)
	rewardLbl.Position = UDim2.new(0, 72, 0, 56)
	rewardLbl.BackgroundTransparency = 1
	rewardLbl.Font = F.Body
	rewardLbl.TextSize = 10
	rewardLbl.TextColor3 = C.Gray500
	rewardLbl.TextXAlignment = Enum.TextXAlignment.Left
	rewardLbl.Text = "💰 " .. item.reward
	rewardLbl.ZIndex = 83
	rewardLbl.Parent = card
	
	-- Commit button
	local commitBtn = Instance.new("TextButton")
	commitBtn.Size = UDim2.new(0, 70, 0, 36)
	commitBtn.AnchorPoint = Vector2.new(1, 0.5)
	commitBtn.Position = UDim2.new(1, -12, 0.5, 0)
	commitBtn.BackgroundColor3 = canDo and C.Red or C.Gray300
	commitBtn.Font = F.Button
	commitBtn.TextSize = 11
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
			if CommitCrime then
				local result = CommitCrime:InvokeServer(item.id)
				if result then
					local emoji = result.caught and "🚔" or "💰"
					self:showResult(result.success, result.message, emoji)
				else
					self:showResult(false, "Server error")
				end
			end
		end)
	end
end

function ActivitiesScreen:populateMindBody()
	self:updateInfoBar()
	for i, item in ipairs(MindBody) do
		self:createActivityCard(self.contentScroll, item, i, C.CyanPale, C.Cyan)
	end
end

function ActivitiesScreen:populateSocial()
	self:updateInfoBar()
	for i, item in ipairs(Social) do
		self:createActivityCard(self.contentScroll, item, i, C.PinkPale, C.Pink)
	end
end

function ActivitiesScreen:populateFun()
	self:updateInfoBar()
	for i, item in ipairs(Entertainment) do
		self:createActivityCard(self.contentScroll, item, i, C.PurplePale, C.Purple)
	end
end

function ActivitiesScreen:populateCrime()
	self:updateInfoBar()
	for i, item in ipairs(Crimes) do
		self:createCrimeCard(self.contentScroll, item, i)
	end
end

function ActivitiesScreen:createResultModal()
	self.resultOverlay = Instance.new("Frame")
	self.resultOverlay.Size = UDim2.fromScale(1, 1)
	self.resultOverlay.BackgroundColor3 = C.Black
	self.resultOverlay.BackgroundTransparency = 0.5
	self.resultOverlay.Visible = false
	self.resultOverlay.ZIndex = 95
	self.resultOverlay.Parent = self.screenGui
	
	self.resultCard = Instance.new("Frame")
	self.resultCard.Size = UDim2.new(0.85, 0, 0, 0)
	self.resultCard.AutomaticSize = Enum.AutomaticSize.Y
	self.resultCard.AnchorPoint = Vector2.new(0.5, 0.5)
	self.resultCard.Position = UDim2.fromScale(0.5, 0.5)
	self.resultCard.BackgroundColor3 = C.White
	self.resultCard.ZIndex = 96
	self.resultCard.Parent = self.resultOverlay
	corner(self.resultCard, 24)
	
	local layout = Instance.new("UIListLayout")
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Padding = UDim.new(0, 12)
	layout.Parent = self.resultCard
	
	pad(self.resultCard, 24, 24, 28, 24)
	
	self.resultEmoji = Instance.new("TextLabel")
	self.resultEmoji.Size = UDim2.new(0, 60, 0, 60)
	self.resultEmoji.BackgroundTransparency = 1
	self.resultEmoji.Font = F.Body
	self.resultEmoji.TextSize = 50
	self.resultEmoji.Text = "✅"
	self.resultEmoji.LayoutOrder = 1
	self.resultEmoji.ZIndex = 97
	self.resultEmoji.Parent = self.resultCard
	
	self.resultTitle = Instance.new("TextLabel")
	self.resultTitle.Size = UDim2.new(1, 0, 0, 28)
	self.resultTitle.BackgroundTransparency = 1
	self.resultTitle.Font = F.Title
	self.resultTitle.TextSize = 22
	self.resultTitle.TextColor3 = C.Gray900
	self.resultTitle.Text = "Result"
	self.resultTitle.LayoutOrder = 2
	self.resultTitle.ZIndex = 97
	self.resultTitle.Parent = self.resultCard
	
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
	self.resultMsg.ZIndex = 97
	self.resultMsg.Parent = self.resultCard
	
	local okBtn = Instance.new("TextButton")
	okBtn.Size = UDim2.new(1, 0, 0, 48)
	okBtn.BackgroundColor3 = C.Amber
	okBtn.Font = F.Button
	okBtn.TextSize = 16
	okBtn.TextColor3 = C.White
	okBtn.Text = "OK"
	okBtn.AutoButtonColor = false
	okBtn.LayoutOrder = 4
	okBtn.ZIndex = 97
	okBtn.Parent = self.resultCard
	pill(okBtn)
	
	okBtn.MouseButton1Click:Connect(function() self:hideResultModal() end)
	okBtn.MouseEnter:Connect(function() tween(okBtn, TweenInfo.new(0.1), { BackgroundColor3 = C.AmberDark }) end)
	okBtn.MouseLeave:Connect(function() tween(okBtn, TweenInfo.new(0.1), { BackgroundColor3 = C.Amber }) end)
end

function ActivitiesScreen:showResult(success, message, emoji)
	self.resultEmoji.Text = emoji or (success and "✅" or "❌")
	self.resultTitle.Text = success and "Done!" or "Uh Oh..."
	self.resultTitle.TextColor3 = success and C.Green or C.Red
	self.resultMsg.Text = message or ""
	
	self.resultOverlay.Visible = true
	self.resultCard.Position = UDim2.new(0.5, 0, 0.5, 30)
	tween(self.resultCard, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.fromScale(0.5, 0.5) })
end

function ActivitiesScreen:hideResultModal()
	local t = tween(self.resultCard, TweenInfo.new(0.15), { Position = UDim2.new(0.5, 0, 0.5, 30) })
	t.Completed:Connect(function()
		self.resultOverlay.Visible = false
		self:switchTab(self.currentTab)
	end)
end

function ActivitiesScreen:show()
	self.overlay.Visible = true
	self.overlay.Position = UDim2.new(1, 0, 0, 0)
	self:updateInfoBar()
	self:switchTab(self.currentTab)
	tween(self.overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.fromScale(0, 0) })
	self.isVisible = true
end

function ActivitiesScreen:hide()
	local t = tween(self.overlay, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Position = UDim2.new(1, 0, 0, 0) })
	t.Completed:Connect(function()
		self.overlay.Visible = false
		self.resultOverlay.Visible = false
	end)
	self.isVisible = false
end

return ActivitiesScreen
