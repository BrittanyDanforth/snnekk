-- AssetsScreen.lua
-- Premium AAA-quality Assets screen with server validation

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AssetsScreen = {}
AssetsScreen.__index = AssetsScreen

local remotesFolder = ReplicatedStorage:WaitForChild("LifeRemotes", 10)
local BuyProperty = remotesFolder and remotesFolder:FindFirstChild("BuyProperty")
local BuyVehicle = remotesFolder and remotesFolder:FindFirstChild("BuyVehicle")
local BuyItem = remotesFolder and remotesFolder:FindFirstChild("BuyItem")
local SellAsset = remotesFolder and remotesFolder:FindFirstChild("SellAsset")

-- Premium Colors
local C = {
	Teal = Color3.fromRGB(20, 184, 166),
	TealDark = Color3.fromRGB(13, 148, 136),
	TealPale = Color3.fromRGB(204, 251, 241),
	Blue = Color3.fromRGB(37, 99, 235),
	BlueDark = Color3.fromRGB(29, 78, 216),
	Green = Color3.fromRGB(34, 197, 94),
	GreenDark = Color3.fromRGB(22, 163, 74),
	GreenPale = Color3.fromRGB(220, 252, 231),
	Orange = Color3.fromRGB(249, 115, 22),
	OrangePale = Color3.fromRGB(255, 237, 213),
	Purple = Color3.fromRGB(139, 92, 246),
	PurplePale = Color3.fromRGB(237, 233, 254),
	Red = Color3.fromRGB(239, 68, 68),
	RedPale = Color3.fromRGB(254, 226, 226),
	Yellow = Color3.fromRGB(234, 179, 8),
	YellowPale = Color3.fromRGB(254, 249, 195),
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
local Properties = {
	{ id = "apartment", name = "Studio Apartment", price = 80000, emoji = "🏢", minAge = 18 },
	{ id = "condo", name = "Luxury Condo", price = 350000, emoji = "🏙️", minAge = 21 },
	{ id = "house", name = "Suburban House", price = 450000, emoji = "🏠", minAge = 21 },
	{ id = "mansion", name = "Mansion", price = 2500000, emoji = "🏰", minAge = 25 },
}

local Vehicles = {
	{ id = "bike", name = "Bicycle", price = 500, emoji = "🚲", minAge = 10 },
	{ id = "scooter", name = "Motor Scooter", price = 3000, emoji = "🛵", minAge = 16 },
	{ id = "sedan", name = "Sedan", price = 25000, emoji = "🚗", minAge = 18 },
	{ id = "sports", name = "Sports Car", price = 85000, emoji = "🏎️", minAge = 21 },
	{ id = "yacht", name = "Yacht", price = 500000, emoji = "🛥️", minAge = 30 },
}

local ShopItems = {
	{ id = "phone", name = "Smartphone", price = 1200, emoji = "📱", minAge = 10 },
	{ id = "laptop", name = "Gaming Laptop", price = 2500, emoji = "💻", minAge = 12 },
	{ id = "watch", name = "Luxury Watch", price = 15000, emoji = "⌚", minAge = 18 },
	{ id = "jewelry", name = "Diamond Jewelry", price = 50000, emoji = "💎", minAge = 21 },
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
	return self
end

function AssetsScreen:getAge() return self.playerState and self.playerState.Age or 0 end
function AssetsScreen:getMoney() return self.playerState and self.playerState.Money or 0 end

function AssetsScreen:createUI()
	self.overlay = Instance.new("Frame")
	self.overlay.Name = "AssetsOverlay"
	self.overlay.Size = UDim2.fromScale(1, 1)
	self.overlay.BackgroundColor3 = C.Bg
	self.overlay.Visible = false
	self.overlay.ZIndex = 80
	self.overlay.Parent = self.screenGui
	
	-- Header
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 56)
	header.BackgroundColor3 = C.Teal
	header.ZIndex = 85
	header.Parent = self.overlay
	
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
	title.Text = "🏠 Assets"
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
	
	-- Balance display
	self.balanceBar = Instance.new("Frame")
	self.balanceBar.Size = UDim2.new(1, -16, 0, 60)
	self.balanceBar.Position = UDim2.new(0, 8, 0, 64)
	self.balanceBar.BackgroundColor3 = C.White
	self.balanceBar.ZIndex = 84
	self.balanceBar.Parent = self.overlay
	corner(self.balanceBar, 14)
	stroke(self.balanceBar, 1, 0.9, C.Gray200)
	
	local balanceIcon = Instance.new("Frame")
	balanceIcon.Size = UDim2.new(0, 44, 0, 44)
	balanceIcon.Position = UDim2.new(0, 8, 0.5, -22)
	balanceIcon.BackgroundColor3 = C.GreenPale
	balanceIcon.ZIndex = 85
	balanceIcon.Parent = self.balanceBar
	corner(balanceIcon, 10)
	
	local balanceEmoji = Instance.new("TextLabel")
	balanceEmoji.Size = UDim2.fromScale(1, 1)
	balanceEmoji.BackgroundTransparency = 1
	balanceEmoji.Font = F.Body
	balanceEmoji.TextSize = 22
	balanceEmoji.Text = "💰"
	balanceEmoji.ZIndex = 86
	balanceEmoji.Parent = balanceIcon
	
	local balanceLbl = Instance.new("TextLabel")
	balanceLbl.Size = UDim2.new(0, 80, 0, 16)
	balanceLbl.Position = UDim2.new(0, 60, 0, 12)
	balanceLbl.BackgroundTransparency = 1
	balanceLbl.Font = F.Body
	balanceLbl.TextSize = 12
	balanceLbl.TextColor3 = C.Gray500
	balanceLbl.TextXAlignment = Enum.TextXAlignment.Left
	balanceLbl.Text = "Your Balance"
	balanceLbl.ZIndex = 85
	balanceLbl.Parent = self.balanceBar
	
	self.moneyLbl = Instance.new("TextLabel")
	self.moneyLbl.Size = UDim2.new(0.5, 0, 0, 26)
	self.moneyLbl.Position = UDim2.new(0, 60, 0, 28)
	self.moneyLbl.BackgroundTransparency = 1
	self.moneyLbl.Font = F.Title
	self.moneyLbl.TextSize = 22
	self.moneyLbl.TextColor3 = C.GreenDark
	self.moneyLbl.TextXAlignment = Enum.TextXAlignment.Left
	self.moneyLbl.Text = "$0"
	self.moneyLbl.ZIndex = 85
	self.moneyLbl.Parent = self.balanceBar
	
	self.ageLbl = Instance.new("TextLabel")
	self.ageLbl.Size = UDim2.new(0, 70, 0, 28)
	self.ageLbl.AnchorPoint = Vector2.new(1, 0.5)
	self.ageLbl.Position = UDim2.new(1, -12, 0.5, 0)
	self.ageLbl.BackgroundColor3 = C.TealPale
	self.ageLbl.Font = F.Medium
	self.ageLbl.TextSize = 12
	self.ageLbl.TextColor3 = C.TealDark
	self.ageLbl.Text = "Age 0"
	self.ageLbl.ZIndex = 85
	self.ageLbl.Parent = self.balanceBar
	pill(self.ageLbl)
	
	-- Tab bar
	local tabBar = Instance.new("Frame")
	tabBar.Size = UDim2.new(1, -16, 0, 42)
	tabBar.Position = UDim2.new(0, 8, 0, 132)
	tabBar.BackgroundColor3 = C.Gray100
	tabBar.ZIndex = 84
	tabBar.Parent = self.overlay
	corner(tabBar, 12)
	
	pad(tabBar, 4, 4, 4, 4)
	
	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	tabLayout.Padding = UDim.new(0, 4)
	tabLayout.Parent = tabBar
	
	self.tabBtns = {}
	local tabs = { { id = "property", text = "🏠 Property" }, { id = "vehicles", text = "🚗 Vehicles" }, { id = "shop", text = "🛒 Shop" } }
	
	for i, tab in ipairs(tabs) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0.32, 0, 1, 0)
		btn.BackgroundColor3 = i == 1 and C.Teal or C.White
		btn.Font = F.Button
		btn.TextSize = 11
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
	self.contentScroll.Size = UDim2.new(1, -16, 1, -196)
	self.contentScroll.Position = UDim2.new(0, 8, 0, 182)
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
	
	self:populateProperty()
end

function AssetsScreen:updateBalanceBar()
	self.moneyLbl.Text = formatMoney(self:getMoney())
	self.ageLbl.Text = "Age " .. self:getAge()
end

function AssetsScreen:switchTab(tabId)
	self.currentTab = tabId
	
	for id, btn in pairs(self.tabBtns) do
		local isActive = id == tabId
		tween(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = isActive and C.Teal or C.White,
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

function AssetsScreen:createItemCard(parent, item, order, bgColor, buyFunc, remote)
	local age = self:getAge()
	local money = self:getMoney()
	local canBuy = age >= item.minAge and money >= item.price
	
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 80)
	card.BackgroundColor3 = C.White
	card.LayoutOrder = order
	card.ZIndex = 82
	card.Parent = parent
	corner(card, 14)
	stroke(card, 1, 0.9, C.Gray200)
	
	-- Icon
	local iconFrame = Instance.new("Frame")
	iconFrame.Size = UDim2.new(0, 54, 0, 54)
	iconFrame.Position = UDim2.new(0, 12, 0.5, -27)
	iconFrame.BackgroundColor3 = bgColor
	iconFrame.ZIndex = 83
	iconFrame.Parent = card
	corner(iconFrame, 12)
	
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
	nameLbl.Position = UDim2.new(0, 76, 0, 16)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Font = F.Title
	nameLbl.TextSize = 15
	nameLbl.TextColor3 = C.Gray900
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.Text = item.name
	nameLbl.ZIndex = 83
	nameLbl.Parent = card
	
	-- Price
	local priceBadge = Instance.new("Frame")
	priceBadge.Size = UDim2.new(0, 80, 0, 24)
	priceBadge.Position = UDim2.new(0, 76, 0, 42)
	priceBadge.BackgroundColor3 = money >= item.price and C.GreenPale or C.RedPale
	priceBadge.ZIndex = 83
	priceBadge.Parent = card
	pill(priceBadge)
	
	local priceLbl = Instance.new("TextLabel")
	priceLbl.Size = UDim2.fromScale(1, 1)
	priceLbl.BackgroundTransparency = 1
	priceLbl.Font = F.Medium
	priceLbl.TextSize = 11
	priceLbl.TextColor3 = money >= item.price and C.GreenDark or C.Red
	priceLbl.Text = formatMoney(item.price)
	priceLbl.ZIndex = 84
	priceLbl.Parent = priceBadge
	
	-- Buy button
	local buyBtn = Instance.new("TextButton")
	buyBtn.Size = UDim2.new(0, 65, 0, 36)
	buyBtn.AnchorPoint = Vector2.new(1, 0.5)
	buyBtn.Position = UDim2.new(1, -12, 0.5, 0)
	buyBtn.BackgroundColor3 = canBuy and C.Teal or C.Gray300
	buyBtn.Font = F.Button
	buyBtn.TextSize = 12
	buyBtn.TextColor3 = canBuy and C.White or C.Gray500
	buyBtn.Text = canBuy and "Buy" or (age < item.minAge and "Age " .. item.minAge .. "+" or "Need $")
	buyBtn.AutoButtonColor = false
	buyBtn.ZIndex = 83
	buyBtn.Parent = card
	pill(buyBtn)
	
	if canBuy then
		buyBtn.MouseEnter:Connect(function() tween(buyBtn, TweenInfo.new(0.1), { BackgroundColor3 = C.TealDark }) end)
		buyBtn.MouseLeave:Connect(function() tween(buyBtn, TweenInfo.new(0.1), { BackgroundColor3 = C.Teal }) end)
		buyBtn.MouseButton1Click:Connect(function()
			if remote then
				local result = remote:InvokeServer(item.id)
				if result then
					self:showResult(result.success, result.message)
				else
					self:showResult(false, "Server error")
				end
			end
		end)
	end
end

function AssetsScreen:populateProperty()
	self:updateBalanceBar()
	for i, item in ipairs(Properties) do
		self:createItemCard(self.contentScroll, item, i, C.TealPale, "BuyProperty", BuyProperty)
	end
end

function AssetsScreen:populateVehicles()
	self:updateBalanceBar()
	for i, item in ipairs(Vehicles) do
		self:createItemCard(self.contentScroll, item, i, C.PurplePale, "BuyVehicle", BuyVehicle)
	end
end

function AssetsScreen:populateShop()
	self:updateBalanceBar()
	for i, item in ipairs(ShopItems) do
		self:createItemCard(self.contentScroll, item, i, C.YellowPale, "BuyItem", BuyItem)
	end
end

function AssetsScreen:createResultModal()
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
	okBtn.BackgroundColor3 = C.Teal
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
	okBtn.MouseEnter:Connect(function() tween(okBtn, TweenInfo.new(0.1), { BackgroundColor3 = C.TealDark }) end)
	okBtn.MouseLeave:Connect(function() tween(okBtn, TweenInfo.new(0.1), { BackgroundColor3 = C.Teal }) end)
end

function AssetsScreen:showResult(success, message)
	self.resultEmoji.Text = success and "🎉" or "❌"
	self.resultTitle.Text = success and "Purchase Complete!" or "Can't Buy"
	self.resultTitle.TextColor3 = success and C.Green or C.Red
	self.resultMsg.Text = message or ""
	
	self.resultOverlay.Visible = true
	self.resultCard.Position = UDim2.new(0.5, 0, 0.5, 30)
	tween(self.resultCard, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.fromScale(0.5, 0.5) })
end

function AssetsScreen:hideResultModal()
	local t = tween(self.resultCard, TweenInfo.new(0.15), { Position = UDim2.new(0.5, 0, 0.5, 30) })
	t.Completed:Connect(function()
		self.resultOverlay.Visible = false
		self:switchTab(self.currentTab)
	end)
end

function AssetsScreen:show()
	self.overlay.Visible = true
	self.overlay.Position = UDim2.new(1, 0, 0, 0)
	self:updateBalanceBar()
	self:switchTab(self.currentTab)
	tween(self.overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.fromScale(0, 0) })
	self.isVisible = true
end

function AssetsScreen:hide()
	local t = tween(self.overlay, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Position = UDim2.new(1, 0, 0, 0) })
	t.Completed:Connect(function()
		self.overlay.Visible = false
		self.resultOverlay.Visible = false
	end)
	self.isVisible = false
end

return AssetsScreen
