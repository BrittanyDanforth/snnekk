-- AssetsScreen.lua
-- Premium AAA-quality Assets & Shop screen with gambling minigame

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AssetsScreen = {}
AssetsScreen.__index = AssetsScreen

local remotesFolder = ReplicatedStorage:WaitForChild("LifeRemotes", 10)
local BuyAsset = remotesFolder and remotesFolder:FindFirstChild("BuyAsset")
local SellAsset = remotesFolder and remotesFolder:FindFirstChild("SellAsset")
local Gamble = remotesFolder and remotesFolder:FindFirstChild("Gamble")

-- Premium Colors
local C = {
	Teal = Color3.fromRGB(20, 184, 166),
	TealDark = Color3.fromRGB(13, 148, 136),
	TealPale = Color3.fromRGB(204, 251, 241),
	TealLight = Color3.fromRGB(153, 246, 228),
	Blue = Color3.fromRGB(37, 99, 235),
	BlueDark = Color3.fromRGB(29, 78, 216),
	BluePale = Color3.fromRGB(219, 234, 254),
	Green = Color3.fromRGB(34, 197, 94),
	GreenDark = Color3.fromRGB(22, 163, 74),
	GreenPale = Color3.fromRGB(220, 252, 231),
	Amber = Color3.fromRGB(245, 158, 11),
	AmberDark = Color3.fromRGB(217, 119, 6),
	AmberPale = Color3.fromRGB(254, 243, 199),
	Purple = Color3.fromRGB(147, 51, 234),
	PurpleDark = Color3.fromRGB(124, 58, 237),
	PurplePale = Color3.fromRGB(243, 232, 255),
	Red = Color3.fromRGB(239, 68, 68),
	RedDark = Color3.fromRGB(220, 38, 38),
	RedPale = Color3.fromRGB(254, 226, 226),
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
	Gold = Color3.fromRGB(234, 179, 8),
	GoldDark = Color3.fromRGB(202, 138, 4),
	GoldPale = Color3.fromRGB(254, 249, 195),
}

local F = { Title = Enum.Font.GothamBold, Body = Enum.Font.Gotham, Medium = Enum.Font.GothamMedium, Button = Enum.Font.GothamBold }

-- Asset Data
local Properties = {
	{ id = "apartment", name = "Small Apartment", emoji = "🏢", price = 50000, income = 500, desc = "Cozy studio" },
	{ id = "house", name = "Suburban House", emoji = "🏠", price = 250000, income = 1500, desc = "3 bed, 2 bath" },
	{ id = "mansion", name = "Luxury Mansion", emoji = "🏰", price = 2000000, income = 8000, desc = "Dream home" },
	{ id = "penthouse", name = "City Penthouse", emoji = "🌆", price = 5000000, income = 15000, desc = "Top floor living" },
}

local Vehicles = {
	{ id = "bicycle", name = "Bicycle", emoji = "🚲", price = 500, minAge = 5 },
	{ id = "scooter", name = "Motor Scooter", emoji = "🛵", price = 3000, minAge = 16 },
	{ id = "sedan", name = "Family Sedan", emoji = "🚗", price = 25000, minAge = 16 },
	{ id = "sports", name = "Sports Car", emoji = "🏎️", price = 150000, minAge = 18 },
	{ id = "luxury", name = "Luxury SUV", emoji = "🚙", price = 80000, minAge = 18 },
	{ id = "supercar", name = "Supercar", emoji = "🚘", price = 500000, minAge = 21 },
	{ id = "yacht", name = "Yacht", emoji = "🛥️", price = 2000000, minAge = 25 },
}

local Shop = {
	{ id = "phone", name = "Smartphone", emoji = "📱", price = 1200 },
	{ id = "laptop", name = "Laptop", emoji = "💻", price = 2000 },
	{ id = "watch", name = "Luxury Watch", emoji = "⌚", price = 15000 },
	{ id = "jewelry", name = "Diamond Jewelry", emoji = "💎", price = 50000 },
	{ id = "pet", name = "Pet Dog", emoji = "🐕", price = 3000 },
}

-- Helpers
local function corner(p, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r); c.Parent = p; return c end
local function pill(p) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0.5, 0); c.Parent = p; return c end
local function stroke(p, t, tr, col) local s = Instance.new("UIStroke"); s.Thickness = t; s.Transparency = tr or 0; s.Color = col or C.White; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = p; return s end
local function pad(p, l, r, t, b) local pd = Instance.new("UIPadding"); pd.PaddingLeft = UDim.new(0, l or 0); pd.PaddingRight = UDim.new(0, r or 0); pd.PaddingTop = UDim.new(0, t or 0); pd.PaddingBottom = UDim.new(0, b or 0); pd.Parent = p; return pd end
local function tween(o, i, p) local t = TweenService:Create(o, i, p); t:Play(); return t end

local function formatMoney(n)
	if not n then return "$0" end
	if n >= 1000000 then return "$" .. string.format("%.1f", n/1000000) .. "M"
	elseif n >= 1000 then return "$" .. string.format("%.0f", n/1000) .. "K"
	else return "$" .. tostring(math.floor(n)) end
end

function AssetsScreen.new(screenGui, blurOverlay, showBlurFunc, hideBlurFunc, playerState)
	local self = setmetatable({}, AssetsScreen)
	self.screenGui = screenGui
	self.playerState = playerState
	self.showBlur = showBlurFunc
	self.hideBlur = hideBlurFunc
	self.isVisible = false
	self.currentTab = "property"
	self:createUI()
	self:createResultModal()
	self:createGamblingModal()
	return self
end

function AssetsScreen:updateState(newState)
	if newState then self.playerState = newState end
end

function AssetsScreen:getAge()
	local state = self.playerState
	if not state then return 0 end
	return state.Age or (state.Stats and state.Stats.Age) or 0
end

function AssetsScreen:getMoney()
	local state = self.playerState
	if not state then return 0 end
	return state.Money or (state.Stats and state.Stats.Money) or 0
end

function AssetsScreen:getAssets()
	local state = self.playerState
	if not state then return {} end
	return state.Assets or {}
end

function AssetsScreen:createUI()
	self.overlay = Instance.new("Frame")
	self.overlay.Name = "AssetsOverlay"
	self.overlay.Size = UDim2.fromScale(1, 1)
	self.overlay.BackgroundColor3 = C.Bg
	self.overlay.Visible = false
	self.overlay.ZIndex = 80
	self.overlay.Parent = self.screenGui
	
	-- Header (offset down for Roblox UI)
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, -16, 0, 60)
	header.Position = UDim2.new(0, 8, 0, 44)
	header.BackgroundColor3 = C.Teal
	header.ZIndex = 85
	header.Parent = self.overlay
	corner(header, 18)
	
	local hGrad = Instance.new("UIGradient")
	hGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, C.Teal), ColorSequenceKeypoint.new(1, C.TealDark) })
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
	title.Text = "🏠 Assets & Shop"
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
	closeBtn.TextColor3 = C.TealDark
	closeBtn.Text = "X"
	closeBtn.AutoButtonColor = false
	closeBtn.ZIndex = 86
	closeBtn.Parent = header
	corner(closeBtn, 20)
	
	closeBtn.MouseButton1Click:Connect(function() self:hide() end)
	closeBtn.MouseEnter:Connect(function() tween(closeBtn, TweenInfo.new(0.1), { BackgroundTransparency = 0 }) end)
	closeBtn.MouseLeave:Connect(function() tween(closeBtn, TweenInfo.new(0.1), { BackgroundTransparency = 0.1 }) end)
	
	-- Balance bar (adjusted for header offset)
	local contentTopOffset = 44 + 60 + 8 -- header offset + height + spacing
	
	self.balanceBar = Instance.new("Frame")
	self.balanceBar.Size = UDim2.new(1, -20, 0, 70)
	self.balanceBar.Position = UDim2.new(0, 10, 0, contentTopOffset)
	self.balanceBar.BackgroundColor3 = C.White
	self.balanceBar.ZIndex = 84
	self.balanceBar.Parent = self.overlay
	corner(self.balanceBar, 16)
	stroke(self.balanceBar, 1, 0.92, C.Gray200)
	
	local balanceIcon = Instance.new("TextLabel")
	balanceIcon.Size = UDim2.new(0, 50, 0, 50)
	balanceIcon.Position = UDim2.new(0, 14, 0.5, -25)
	balanceIcon.BackgroundTransparency = 1
	balanceIcon.Font = F.Body
	balanceIcon.TextSize = 36
	balanceIcon.Text = "💰"
	balanceIcon.ZIndex = 85
	balanceIcon.Parent = self.balanceBar
	
	local balanceLabelTxt = Instance.new("TextLabel")
	balanceLabelTxt.Size = UDim2.new(0.5, 0, 0, 20)
	balanceLabelTxt.Position = UDim2.new(0, 70, 0, 14)
	balanceLabelTxt.BackgroundTransparency = 1
	balanceLabelTxt.Font = F.Body
	balanceLabelTxt.TextSize = 12
	balanceLabelTxt.TextColor3 = C.Gray500
	balanceLabelTxt.TextXAlignment = Enum.TextXAlignment.Left
	balanceLabelTxt.Text = "Your Balance"
	balanceLabelTxt.ZIndex = 85
	balanceLabelTxt.Parent = self.balanceBar
	
	self.balanceValue = Instance.new("TextLabel")
	self.balanceValue.Size = UDim2.new(0.6, 0, 0, 30)
	self.balanceValue.Position = UDim2.new(0, 70, 0, 32)
	self.balanceValue.BackgroundTransparency = 1
	self.balanceValue.Font = F.Title
	self.balanceValue.TextSize = 26
	self.balanceValue.TextColor3 = C.GreenDark
	self.balanceValue.TextXAlignment = Enum.TextXAlignment.Left
	self.balanceValue.Text = "$0"
	self.balanceValue.ZIndex = 85
	self.balanceValue.Parent = self.balanceBar
	
	-- Casino button
	local casinoBtn = Instance.new("TextButton")
	casinoBtn.Size = UDim2.new(0, 75, 0, 48)
	casinoBtn.AnchorPoint = Vector2.new(1, 0.5)
	casinoBtn.Position = UDim2.new(1, -14, 0.5, 0)
	casinoBtn.BackgroundColor3 = C.Gold
	casinoBtn.Font = F.Button
	casinoBtn.TextSize = 12
	casinoBtn.TextColor3 = C.White
	casinoBtn.Text = "🎰 Casino"
	casinoBtn.AutoButtonColor = false
	casinoBtn.ZIndex = 85
	casinoBtn.Parent = self.balanceBar
	corner(casinoBtn, 12)
	
	casinoBtn.MouseButton1Click:Connect(function() self:showGambling() end)
	casinoBtn.MouseEnter:Connect(function() tween(casinoBtn, TweenInfo.new(0.1), { BackgroundColor3 = C.GoldDark }) end)
	casinoBtn.MouseLeave:Connect(function() tween(casinoBtn, TweenInfo.new(0.1), { BackgroundColor3 = C.Gold }) end)
	
	-- Tab bar
	local tabBar = Instance.new("Frame")
	tabBar.Size = UDim2.new(1, -20, 0, 50)
	tabBar.Position = UDim2.new(0, 10, 0, contentTopOffset + 78)
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
	local tabs = {
		{ id = "property", text = "🏠 Property", color = C.Teal },
		{ id = "vehicles", text = "🚗 Vehicles", color = C.Blue },
		{ id = "shop", text = "🛒 Shop", color = C.Purple },
	}
	
	for i, tab in ipairs(tabs) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0.31, 0, 1, 0)
		btn.BackgroundColor3 = i == 1 and tab.color or C.White
		btn.Font = F.Button
		btn.TextSize = 12
		btn.TextColor3 = i == 1 and C.White or C.Gray600
		btn.Text = tab.text
		btn.AutoButtonColor = false
		btn.LayoutOrder = i
		btn.ZIndex = 85
		btn.Parent = tabBar
		corner(btn, 10)
		
		self.tabBtns[tab.id] = { btn = btn, color = tab.color }
		btn.MouseButton1Click:Connect(function() self:switchTab(tab.id) end)
	end
	
	-- Content
	local scrollTop = contentTopOffset + 78 + 58 -- balance bar + tab bar + spacing
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
	
	self:populateProperty()
end

function AssetsScreen:updateBalanceBar()
	self.balanceValue.Text = formatMoney(self:getMoney())
end

function AssetsScreen:switchTab(tabId)
	self.currentTab = tabId
	
	for id, data in pairs(self.tabBtns) do
		local isActive = id == tabId
		tween(data.btn, TweenInfo.new(0.15), {
			BackgroundColor3 = isActive and data.color or C.White,
			TextColor3 = isActive and C.White or C.Gray600
		})
	end
	
	for _, child in ipairs(self.contentScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	
	if tabId == "property" then self:populateProperty()
	elseif tabId == "vehicles" then self:populateVehicles()
	else self:populateShop() end
end

function AssetsScreen:createAssetCard(parent, item, order, cardType, accentColor, bgColor)
	local age = self:getAge()
	local money = self:getMoney()
	local assets = self:getAssets()
	
	local minAge = item.minAge or 0
	local meetsAge = age >= minAge
	local canAfford = money >= item.price
	local alreadyOwns = assets[item.id] ~= nil
	local canBuy = meetsAge and canAfford and not alreadyOwns
	
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 100)
	card.BackgroundColor3 = C.White
	card.LayoutOrder = order
	card.ZIndex = 82
	card.Parent = parent
	corner(card, 16)
	stroke(card, 1, alreadyOwns and 0.5 or 0.92, alreadyOwns and C.Green or C.Gray200)
	
	-- Icon
	local iconFrame = Instance.new("Frame")
	iconFrame.Size = UDim2.new(0, 60, 0, 60)
	iconFrame.Position = UDim2.new(0, 14, 0.5, -30)
	iconFrame.BackgroundColor3 = alreadyOwns and C.GreenPale or bgColor
	iconFrame.ZIndex = 83
	iconFrame.Parent = card
	corner(iconFrame, 16)
	
	local iconLbl = Instance.new("TextLabel")
	iconLbl.Size = UDim2.fromScale(1, 1)
	iconLbl.BackgroundTransparency = 1
	iconLbl.Font = F.Body
	iconLbl.TextSize = 32
	iconLbl.Text = item.emoji
	iconLbl.ZIndex = 84
	iconLbl.Parent = iconFrame
	
	-- Owned badge
	if alreadyOwns then
		local ownedBadge = Instance.new("Frame")
		ownedBadge.Size = UDim2.new(0, 65, 0, 20)
		ownedBadge.Position = UDim2.new(0, 84, 0, 8)
		ownedBadge.BackgroundColor3 = C.Green
		ownedBadge.ZIndex = 84
		ownedBadge.Parent = card
		pill(ownedBadge)
		
		local ownedLbl = Instance.new("TextLabel")
		ownedLbl.Size = UDim2.fromScale(1, 1)
		ownedLbl.BackgroundTransparency = 1
		ownedLbl.Font = F.Button
		ownedLbl.TextSize = 10
		ownedLbl.TextColor3 = C.White
		ownedLbl.Text = "✓ OWNED"
		ownedLbl.ZIndex = 85
		ownedLbl.Parent = ownedBadge
	end
	
	-- Name
	local nameLbl = Instance.new("TextLabel")
	nameLbl.Size = UDim2.new(0.5, 0, 0, 22)
	nameLbl.Position = UDim2.new(0, 84, 0, alreadyOwns and 30 or 12)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Font = F.Title
	nameLbl.TextSize = 15
	nameLbl.TextColor3 = C.Gray900
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.Text = item.name
	nameLbl.ZIndex = 83
	nameLbl.Parent = card
	
	-- Price badge
	local priceBadge = Instance.new("Frame")
	priceBadge.Size = UDim2.new(0, 75, 0, 24)
	priceBadge.Position = UDim2.new(0, 84, 0, alreadyOwns and 54 or 36)
	priceBadge.BackgroundColor3 = canAfford and C.GreenPale or C.RedPale
	priceBadge.ZIndex = 83
	priceBadge.Parent = card
	pill(priceBadge)
	
	local priceLbl = Instance.new("TextLabel")
	priceLbl.Size = UDim2.fromScale(1, 1)
	priceLbl.BackgroundTransparency = 1
	priceLbl.Font = F.Medium
	priceLbl.TextSize = 11
	priceLbl.TextColor3 = canAfford and C.GreenDark or C.RedDark
	priceLbl.Text = formatMoney(item.price)
	priceLbl.ZIndex = 84
	priceLbl.Parent = priceBadge
	
	-- Extra info (income, description)
	if item.income then
		local incomeBadge = Instance.new("Frame")
		incomeBadge.Size = UDim2.new(0, 80, 0, 24)
		incomeBadge.Position = UDim2.new(0, 164, 0, alreadyOwns and 54 or 36)
		incomeBadge.BackgroundColor3 = C.AmberPale
		incomeBadge.ZIndex = 83
		incomeBadge.Parent = card
		pill(incomeBadge)
		
		local incomeLbl = Instance.new("TextLabel")
		incomeLbl.Size = UDim2.fromScale(1, 1)
		incomeLbl.BackgroundTransparency = 1
		incomeLbl.Font = F.Medium
		incomeLbl.TextSize = 10
		incomeLbl.TextColor3 = C.AmberDark
		incomeLbl.Text = "+" .. formatMoney(item.income) .. "/yr"
		incomeLbl.ZIndex = 84
		incomeLbl.Parent = incomeBadge
	end
	
	-- Requirements
	if not alreadyOwns and minAge > 0 then
		local reqLbl = Instance.new("TextLabel")
		reqLbl.Size = UDim2.new(0.4, 0, 0, 18)
		reqLbl.Position = UDim2.new(0, 84, 0, 64)
		reqLbl.BackgroundTransparency = 1
		reqLbl.Font = F.Body
		reqLbl.TextSize = 11
		reqLbl.TextColor3 = meetsAge and C.Gray500 or C.Red
		reqLbl.TextXAlignment = Enum.TextXAlignment.Left
		reqLbl.Text = "Age " .. minAge .. "+"
		reqLbl.ZIndex = 83
		reqLbl.Parent = card
	end
	
	-- Buy button
	if not alreadyOwns then
		local buyBtn = Instance.new("TextButton")
		buyBtn.Size = UDim2.new(0, 68, 0, 42)
		buyBtn.AnchorPoint = Vector2.new(1, 0.5)
		buyBtn.Position = UDim2.new(1, -14, 0.5, 0)
		buyBtn.BackgroundColor3 = canBuy and accentColor or C.Gray300
		buyBtn.Font = F.Button
		buyBtn.TextSize = 13
		buyBtn.TextColor3 = canBuy and C.White or C.Gray500
		buyBtn.Text = canBuy and "Buy" or (not meetsAge and "Age " .. minAge .. "+" or "Need $")
		buyBtn.AutoButtonColor = false
		buyBtn.ZIndex = 83
		buyBtn.Parent = card
		pill(buyBtn)
		
		if canBuy then
			buyBtn.MouseEnter:Connect(function() 
				tween(buyBtn, TweenInfo.new(0.1), { Size = UDim2.new(0, 74, 0, 46) })
			end)
			buyBtn.MouseLeave:Connect(function() 
				tween(buyBtn, TweenInfo.new(0.1), { Size = UDim2.new(0, 68, 0, 42) })
			end)
			buyBtn.MouseButton1Click:Connect(function()
				self:buyAsset(item, cardType)
			end)
		end
	end
end

function AssetsScreen:populateProperty()
	self:updateBalanceBar()
	for i, item in ipairs(Properties) do
		self:createAssetCard(self.contentScroll, item, i, "property", C.Teal, C.TealPale)
	end
end

function AssetsScreen:populateVehicles()
	self:updateBalanceBar()
	for i, item in ipairs(Vehicles) do
		self:createAssetCard(self.contentScroll, item, i, "vehicle", C.Blue, C.BluePale)
	end
end

function AssetsScreen:populateShop()
	self:updateBalanceBar()
	for i, item in ipairs(Shop) do
		self:createAssetCard(self.contentScroll, item, i, "item", C.Purple, C.PurplePale)
	end
end

function AssetsScreen:buyAsset(item, itemType)
	if not BuyAsset then
		self:showResult(false, "Server not available", "❌")
		return
	end
	
	local result = BuyAsset:InvokeServer(item.id, itemType)
	if result then
		self:showResult(result.success, result.message, result.success and "🎉" or "😔")
	else
		self:showResult(false, "Server error", "❌")
	end
end

function AssetsScreen:createGamblingModal()
	self.gamblingOverlay = Instance.new("Frame")
	self.gamblingOverlay.Size = UDim2.fromScale(1, 1)
	self.gamblingOverlay.BackgroundColor3 = C.Black
	self.gamblingOverlay.BackgroundTransparency = 0.3
	self.gamblingOverlay.Visible = false
	self.gamblingOverlay.ZIndex = 96
	self.gamblingOverlay.Parent = self.screenGui
	
	self.gamblingCard = Instance.new("Frame")
	self.gamblingCard.Size = UDim2.new(0.92, 0, 0, 420)
	self.gamblingCard.AnchorPoint = Vector2.new(0.5, 0.5)
	self.gamblingCard.Position = UDim2.fromScale(0.5, 0.5)
	self.gamblingCard.BackgroundColor3 = Color3.fromRGB(26, 32, 44)
	self.gamblingCard.ZIndex = 97
	self.gamblingCard.Parent = self.gamblingOverlay
	corner(self.gamblingCard, 24)
	
	-- Header with gradient
	local gamblingHeader = Instance.new("Frame")
	gamblingHeader.Size = UDim2.new(1, 0, 0, 60)
	gamblingHeader.BackgroundColor3 = C.Gold
	gamblingHeader.ZIndex = 98
	gamblingHeader.Parent = self.gamblingCard
	corner(gamblingHeader, 24)
	
	local headerFix = Instance.new("Frame")
	headerFix.Size = UDim2.new(1, 0, 0, 30)
	headerFix.Position = UDim2.new(0, 0, 0, 35)
	headerFix.BackgroundColor3 = C.Gold
	headerFix.ZIndex = 98
	headerFix.Parent = gamblingHeader
	
	local hGrad = Instance.new("UIGradient")
	hGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, C.Gold), ColorSequenceKeypoint.new(1, C.GoldDark) })
	hGrad.Rotation = 90
	hGrad.Parent = gamblingHeader
	
	local gamblingTitle = Instance.new("TextLabel")
	gamblingTitle.Size = UDim2.new(1, 0, 1, 0)
	gamblingTitle.BackgroundTransparency = 1
	gamblingTitle.Font = F.Title
	gamblingTitle.TextSize = 22
	gamblingTitle.TextColor3 = C.White
	gamblingTitle.Text = "🎰 Lucky Slots"
	gamblingTitle.ZIndex = 99
	gamblingTitle.Parent = gamblingHeader
	
	-- Close button (clean X)
	local gamblingClose = Instance.new("TextButton")
	gamblingClose.Size = UDim2.new(0, 38, 0, 38)
	gamblingClose.AnchorPoint = Vector2.new(1, 0.5)
	gamblingClose.Position = UDim2.new(1, -10, 0.5, 0)
	gamblingClose.BackgroundColor3 = C.White
	gamblingClose.BackgroundTransparency = 0.1
	gamblingClose.Font = F.Title
	gamblingClose.TextSize = 16
	gamblingClose.TextColor3 = C.GoldDark
	gamblingClose.Text = "X"
	gamblingClose.AutoButtonColor = false
	gamblingClose.ZIndex = 99
	gamblingClose.Parent = gamblingHeader
	corner(gamblingClose, 19)
	
	gamblingClose.MouseButton1Click:Connect(function() self:hideGambling() end)
	gamblingClose.MouseEnter:Connect(function() tween(gamblingClose, TweenInfo.new(0.1), { BackgroundTransparency = 0 }) end)
	gamblingClose.MouseLeave:Connect(function() tween(gamblingClose, TweenInfo.new(0.1), { BackgroundTransparency = 0.1 }) end)
	
	-- Slot display
	self.slotContainer = Instance.new("Frame")
	self.slotContainer.Size = UDim2.new(0.9, 0, 0, 100)
	self.slotContainer.AnchorPoint = Vector2.new(0.5, 0)
	self.slotContainer.Position = UDim2.new(0.5, 0, 0, 80)
	self.slotContainer.BackgroundColor3 = Color3.fromRGB(45, 55, 72)
	self.slotContainer.ZIndex = 98
	self.slotContainer.Parent = self.gamblingCard
	corner(self.slotContainer, 16)
	
	local slotLayout = Instance.new("UIListLayout")
	slotLayout.FillDirection = Enum.FillDirection.Horizontal
	slotLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	slotLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	slotLayout.Padding = UDim.new(0, 16)
	slotLayout.Parent = self.slotContainer
	
	self.slotLabels = {}
	local slotSymbols = { "🍒", "🍋", "🍊" }
	for i = 1, 3 do
		local slotFrame = Instance.new("Frame")
		slotFrame.Size = UDim2.new(0, 75, 0, 80)
		slotFrame.BackgroundColor3 = C.White
		slotFrame.LayoutOrder = i
		slotFrame.ZIndex = 99
		slotFrame.Parent = self.slotContainer
		corner(slotFrame, 12)
		
		local slotLbl = Instance.new("TextLabel")
		slotLbl.Size = UDim2.fromScale(1, 1)
		slotLbl.BackgroundTransparency = 1
		slotLbl.Font = F.Body
		slotLbl.TextSize = 50
		slotLbl.Text = slotSymbols[i]
		slotLbl.ZIndex = 100
		slotLbl.Parent = slotFrame
		
		self.slotLabels[i] = slotLbl
	end
	
	-- Bet amount
	self.betDisplay = Instance.new("Frame")
	self.betDisplay.Size = UDim2.new(0.9, 0, 0, 50)
	self.betDisplay.AnchorPoint = Vector2.new(0.5, 0)
	self.betDisplay.Position = UDim2.new(0.5, 0, 0, 195)
	self.betDisplay.BackgroundColor3 = Color3.fromRGB(45, 55, 72)
	self.betDisplay.ZIndex = 98
	self.betDisplay.Parent = self.gamblingCard
	corner(self.betDisplay, 12)
	
	local betLabel = Instance.new("TextLabel")
	betLabel.Size = UDim2.new(0.4, 0, 1, 0)
	betLabel.BackgroundTransparency = 1
	betLabel.Font = F.Medium
	betLabel.TextSize = 14
	betLabel.TextColor3 = C.Gray400
	betLabel.Text = "Your Bet:"
	betLabel.ZIndex = 99
	betLabel.Parent = self.betDisplay
	
	self.betAmount = 100
	self.betAmountLabel = Instance.new("TextLabel")
	self.betAmountLabel.Size = UDim2.new(0.6, 0, 1, 0)
	self.betAmountLabel.Position = UDim2.new(0.4, 0, 0, 0)
	self.betAmountLabel.BackgroundTransparency = 1
	self.betAmountLabel.Font = F.Title
	self.betAmountLabel.TextSize = 22
	self.betAmountLabel.TextColor3 = C.Gold
	self.betAmountLabel.TextXAlignment = Enum.TextXAlignment.Left
	self.betAmountLabel.Text = "$100"
	self.betAmountLabel.ZIndex = 99
	self.betAmountLabel.Parent = self.betDisplay
	
	-- Bet controls
	local betControls = Instance.new("Frame")
	betControls.Size = UDim2.new(0.9, 0, 0, 45)
	betControls.AnchorPoint = Vector2.new(0.5, 0)
	betControls.Position = UDim2.new(0.5, 0, 0, 255)
	betControls.BackgroundTransparency = 1
	betControls.ZIndex = 98
	betControls.Parent = self.gamblingCard
	
	local controlLayout = Instance.new("UIListLayout")
	controlLayout.FillDirection = Enum.FillDirection.Horizontal
	controlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	controlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	controlLayout.Padding = UDim.new(0, 8)
	controlLayout.Parent = betControls
	
	local betAmounts = { 100, 500, 1000, 5000 }
	for i, amt in ipairs(betAmounts) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 65, 0, 38)
		btn.BackgroundColor3 = self.betAmount == amt and C.Gold or Color3.fromRGB(45, 55, 72)
		btn.Font = F.Button
		btn.TextSize = 12
		btn.TextColor3 = C.White
		btn.Text = formatMoney(amt)
		btn.AutoButtonColor = false
		btn.LayoutOrder = i
		btn.ZIndex = 99
		btn.Parent = betControls
		corner(btn, 10)
		
		btn.MouseButton1Click:Connect(function()
			self.betAmount = amt
			self.betAmountLabel.Text = formatMoney(amt)
			for _, child in ipairs(betControls:GetChildren()) do
				if child:IsA("TextButton") then
					child.BackgroundColor3 = Color3.fromRGB(45, 55, 72)
				end
			end
			btn.BackgroundColor3 = C.Gold
		end)
	end
	
	-- Spin button
	self.spinBtn = Instance.new("TextButton")
	self.spinBtn.Size = UDim2.new(0.8, 0, 0, 58)
	self.spinBtn.AnchorPoint = Vector2.new(0.5, 0)
	self.spinBtn.Position = UDim2.new(0.5, 0, 0, 315)
	self.spinBtn.BackgroundColor3 = C.Green
	self.spinBtn.Font = F.Title
	self.spinBtn.TextSize = 20
	self.spinBtn.TextColor3 = C.White
	self.spinBtn.Text = "🎰 SPIN!"
	self.spinBtn.AutoButtonColor = false
	self.spinBtn.ZIndex = 98
	self.spinBtn.Parent = self.gamblingCard
	corner(self.spinBtn, 16)
	
	self.isSpinning = false
	self.spinBtn.MouseButton1Click:Connect(function() self:spin() end)
	self.spinBtn.MouseEnter:Connect(function() 
		if not self.isSpinning then tween(self.spinBtn, TweenInfo.new(0.1), { BackgroundColor3 = C.GreenDark }) end
	end)
	self.spinBtn.MouseLeave:Connect(function() 
		if not self.isSpinning then tween(self.spinBtn, TweenInfo.new(0.1), { BackgroundColor3 = C.Green }) end
	end)
	
	-- Result text
	self.spinResult = Instance.new("TextLabel")
	self.spinResult.Size = UDim2.new(1, 0, 0, 30)
	self.spinResult.AnchorPoint = Vector2.new(0.5, 0)
	self.spinResult.Position = UDim2.new(0.5, 0, 0, 380)
	self.spinResult.BackgroundTransparency = 1
	self.spinResult.Font = F.Title
	self.spinResult.TextSize = 16
	self.spinResult.TextColor3 = C.White
	self.spinResult.Text = ""
	self.spinResult.ZIndex = 98
	self.spinResult.Parent = self.gamblingCard
end

function AssetsScreen:showGambling()
	if self:getAge() < 21 then
		self:showResult(false, "You must be 21 or older to gamble!", "🔞")
		return
	end
	
	self.gamblingOverlay.Visible = true
	self.gamblingCard.Position = UDim2.new(0.5, 0, 0.5, 50)
	self.gamblingCard.BackgroundTransparency = 1
	self.spinResult.Text = ""
	
	tween(self.gamblingCard, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 0
	})
end

function AssetsScreen:hideGambling()
	local t = tween(self.gamblingCard, TweenInfo.new(0.2), {
		Position = UDim2.new(0.5, 0, 0.5, 50),
		BackgroundTransparency = 1
	})
	t.Completed:Connect(function()
		self.gamblingOverlay.Visible = false
		self:updateBalanceBar()
		self:switchTab(self.currentTab)
	end)
end

function AssetsScreen:spin()
	if self.isSpinning then return end
	if self:getMoney() < self.betAmount then
		self.spinResult.Text = "Not enough money!"
		self.spinResult.TextColor3 = C.Red
		return
	end
	
	self.isSpinning = true
	self.spinBtn.BackgroundColor3 = C.Gray500
	self.spinResult.Text = ""
	
	local symbols = { "🍒", "🍋", "🍊", "🍇", "⭐", "7️⃣", "💎" }
	local finalSymbols = {}
	
	-- Animation
	for spin = 1, 20 do
		task.wait(0.05 + spin * 0.01)
		for i = 1, 3 do
			local sym = symbols[math.random(1, #symbols)]
			self.slotLabels[i].Text = sym
			if spin == 20 then
				finalSymbols[i] = sym
			end
		end
	end
	
	-- Call server
	task.delay(0.3, function()
		if Gamble then
			local result = Gamble:InvokeServer(self.betAmount, finalSymbols)
			if result then
				if result.success then
					self.spinResult.Text = "🎉 You won " .. formatMoney(result.winnings) .. "!"
					self.spinResult.TextColor3 = C.Green
				else
					self.spinResult.Text = result.message or "Better luck next time!"
					self.spinResult.TextColor3 = C.Red
				end
			end
		else
			-- Local calculation fallback
			local won = finalSymbols[1] == finalSymbols[2] and finalSymbols[2] == finalSymbols[3]
			if won then
				self.spinResult.Text = "🎉 JACKPOT! You won " .. formatMoney(self.betAmount * 5) .. "!"
				self.spinResult.TextColor3 = C.Green
			elseif finalSymbols[1] == finalSymbols[2] or finalSymbols[2] == finalSymbols[3] then
				self.spinResult.Text = "Nice! You won " .. formatMoney(self.betAmount) .. "!"
				self.spinResult.TextColor3 = C.Gold
			else
				self.spinResult.Text = "Better luck next time!"
				self.spinResult.TextColor3 = C.Red
			end
		end
		
		self.isSpinning = false
		self.spinBtn.BackgroundColor3 = C.Green
		self:updateBalanceBar()
	end)
end

function AssetsScreen:createResultModal()
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
	self.resultShell.BackgroundColor3 = C.Teal
	self.resultShell.ZIndex = 99
	self.resultShell.Parent = self.resultOverlay
	corner(self.resultShell, 24)
	
	self.resultShellStroke = stroke(self.resultShell, 3, 0, C.TealDark)
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
	self.resultTitle.Text = "Purchase Complete!"
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
	self.resultOkBtn.BackgroundColor3 = C.Teal
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
	self.resultOkBtn.MouseEnter:Connect(function() tween(self.resultOkBtn, TweenInfo.new(0.1), { BackgroundColor3 = C.TealDark }) end)
	self.resultOkBtn.MouseLeave:Connect(function() tween(self.resultOkBtn, TweenInfo.new(0.1), { BackgroundColor3 = C.Teal }) end)
end

function AssetsScreen:showResult(success, message, emoji)
	-- Set shell color based on success
	local shellColor = success and C.Green or C.Red
	local shellStrokeColor = success and C.GreenDark or C.RedDark
	
	self.resultShell.BackgroundColor3 = shellColor
	self.resultShellStroke.Color = shellStrokeColor
	
	self.resultEmoji.Text = emoji or (success and "🎉" or "😔")
	self.resultEmojiFrame.BackgroundColor3 = success and C.GreenPale or C.RedPale
	self.resultTitle.Text = success and "Purchase Complete!" or "Uh oh..."
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

function AssetsScreen:hideResultModal()
	local t = tween(self.resultShell, TweenInfo.new(0.2), {
		Position = UDim2.new(0.5, 0, 0.5, 40),
		BackgroundTransparency = 1
	})
	tween(self.resultCard, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
	t.Completed:Connect(function()
		self.resultOverlay.Visible = false
		self:updateBalanceBar()
		self:switchTab(self.currentTab)
	end)
end

function AssetsScreen:show()
	self.overlay.Visible = true
	self.overlay.Position = UDim2.new(1, 0, 0, 0)
	self:updateBalanceBar()
	self:switchTab(self.currentTab)
	tween(self.overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { 
		Position = UDim2.fromScale(0, 0) 
	})
	self.isVisible = true
end

function AssetsScreen:hide()
	local t = tween(self.overlay, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { 
		Position = UDim2.new(1, 0, 0, 0) 
	})
	t.Completed:Connect(function()
		self.overlay.Visible = false
		self.resultOverlay.Visible = false
		self.gamblingOverlay.Visible = false
	end)
	self.isVisible = false
end

return AssetsScreen
