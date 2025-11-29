-- AssetsScreen.lua
-- Premium BitLife-style Assets & Shop screen
-- Triple AAA polished UI with gambling minigame

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UI = require(ReplicatedStorage:WaitForChild("UIComponents"))
local C = UI.Colors
local F = UI.Fonts

local AssetsScreen = {}
AssetsScreen.__index = AssetsScreen

-- Debug logging
local DEBUG = true
local function log(...)
	if DEBUG then print("[AssetsScreen]", ...) end
end
local function logWarn(...)
	warn("[AssetsScreen]", ...)
end

-- Remotes
local remotesFolder = ReplicatedStorage:WaitForChild("LifeRemotes", 30)
local BuyProperty = remotesFolder and remotesFolder:WaitForChild("BuyProperty", 15)
local BuyVehicle = remotesFolder and remotesFolder:WaitForChild("BuyVehicle", 15)
local BuyItem = remotesFolder and remotesFolder:WaitForChild("BuyItem", 15)
local SellAsset = remotesFolder and remotesFolder:WaitForChild("SellAsset", 15)
local Gamble = remotesFolder and remotesFolder:WaitForChild("Gamble", 15)

-- Asset Data
local Properties = {
	{ id = "apartment", name = "Small Apartment", emoji = "🏢", price = 50000, income = 500, desc = "Cozy studio" },
	{ id = "house", name = "Suburban House", emoji = "🏠", price = 250000, income = 1500, desc = "3 bed, 2 bath" },
	{ id = "mansion", name = "Luxury Mansion", emoji = "🏰", price = 2000000, income = 8000, desc = "Dream home" },
	{ id = "penthouse", name = "City Penthouse", emoji = "🌆", price = 5000000, income = 15000, desc = "Top floor" },
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

function AssetsScreen.new(screenGui, blurOverlay, showBlurFunc, hideBlurFunc, playerState)
	log("=== CREATING AssetsScreen ===")
	local self = setmetatable({}, AssetsScreen)
	self.screenGui = screenGui
	self.playerState = playerState or {}
	self.showBlur = showBlurFunc
	self.hideBlur = hideBlurFunc
	self.isVisible = false
	self.currentTab = "property"
	log("Initial state - Age:", self:getAge(), "Money:", self:getMoney())
	self:createUI()
	log("✅ AssetsScreen created successfully")
	return self
end

function AssetsScreen:updateState(newState)
	log("Updating state...")
	if newState then 
		self.playerState = newState
		log("State updated - Age:", self:getAge(), "Money:", self:getMoney())
	end
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
	-- Main overlay
	self.overlay = Instance.new("Frame")
	self.overlay.Name = "AssetsOverlay"
	self.overlay.Size = UDim2.fromScale(1, 1)
	self.overlay.BackgroundColor3 = C.Bg
	self.overlay.Visible = false
	self.overlay.ZIndex = 80
	self.overlay.Parent = self.screenGui
	
	-- Premium header
	local headerData = UI.createScreenHeader(self.overlay, {
		title = "🏠 Assets & Shop",
		color = C.Teal,
		colorDark = C.TealDark,
		zIndex = 85
	})
	headerData.closeButton.MouseButton1Click:Connect(function() self:hide() end)
	headerData.closeButton.MouseEnter:Connect(function()
		UI.tween(headerData.closeButton, TweenInfo.new(0.12), { BackgroundTransparency = 0 })
	end)
	headerData.closeButton.MouseLeave:Connect(function()
		UI.tween(headerData.closeButton, TweenInfo.new(0.12), { BackgroundTransparency = 0.1 })
	end)
	
	-- Balance bar with casino button
	self.balanceBar = Instance.new("Frame")
	self.balanceBar.Size = UDim2.new(1, -16, 0, 75)
	self.balanceBar.Position = UDim2.new(0, 8, 0, 116)
	self.balanceBar.BackgroundColor3 = C.White
	self.balanceBar.ZIndex = 84
	self.balanceBar.Parent = self.overlay
	UI.corner(self.balanceBar, 18)
	UI.stroke(self.balanceBar, 1, 0.88, C.Gray200)
	UI.createShadow(self.balanceBar, 3, 10, C.Black, 0.93)
	
	-- Balance icon
	local balanceIcon = Instance.new("TextLabel")
	balanceIcon.Size = UDim2.new(0, 55, 0, 55)
	balanceIcon.Position = UDim2.new(0, 14, 0.5, -27.5)
	balanceIcon.BackgroundTransparency = 1
	balanceIcon.Font = F.Body
	balanceIcon.TextSize = 38
	balanceIcon.Text = "💰"
	balanceIcon.ZIndex = 85
	balanceIcon.Parent = self.balanceBar
	
	-- Balance text
	local balanceLabel = Instance.new("TextLabel")
	balanceLabel.Size = UDim2.new(0.4, 0, 0, 20)
	balanceLabel.Position = UDim2.new(0, 75, 0, 14)
	balanceLabel.BackgroundTransparency = 1
	balanceLabel.Font = F.Body
	balanceLabel.TextSize = 13
	balanceLabel.TextColor3 = C.Gray500
	balanceLabel.TextXAlignment = Enum.TextXAlignment.Left
	balanceLabel.Text = "Your Balance"
	balanceLabel.ZIndex = 85
	balanceLabel.Parent = self.balanceBar
	
	self.balanceValue = Instance.new("TextLabel")
	self.balanceValue.Size = UDim2.new(0.5, 0, 0, 32)
	self.balanceValue.Position = UDim2.new(0, 75, 0, 34)
	self.balanceValue.BackgroundTransparency = 1
	self.balanceValue.Font = F.Title
	self.balanceValue.TextSize = 28
	self.balanceValue.TextColor3 = C.GreenDark
	self.balanceValue.TextXAlignment = Enum.TextXAlignment.Left
	self.balanceValue.Text = "$0"
	self.balanceValue.ZIndex = 85
	self.balanceValue.Parent = self.balanceBar
	
	-- Casino button
	local casinoBtn = Instance.new("TextButton")
	casinoBtn.Size = UDim2.new(0, 90, 0, 50)
	casinoBtn.AnchorPoint = Vector2.new(1, 0.5)
	casinoBtn.Position = UDim2.new(1, -14, 0.5, 0)
	casinoBtn.BackgroundColor3 = C.Gold
	casinoBtn.Font = F.Button
	casinoBtn.TextSize = 13
	casinoBtn.TextColor3 = C.White
	casinoBtn.Text = "🎰 Casino"
	casinoBtn.AutoButtonColor = false
	casinoBtn.ZIndex = 85
	casinoBtn.Parent = self.balanceBar
	UI.corner(casinoBtn, 14)
	UI.gradient(casinoBtn, C.Gold, C.GoldDark, 90)
	
	casinoBtn.MouseButton1Click:Connect(function() self:showGambling() end)
	casinoBtn.MouseEnter:Connect(function()
		UI.tween(casinoBtn, TweenInfo.new(0.12), { Size = UDim2.new(0, 96, 0, 54) })
	end)
	casinoBtn.MouseLeave:Connect(function()
		UI.tween(casinoBtn, TweenInfo.new(0.12), { Size = UDim2.new(0, 90, 0, 50) })
	end)
	
	-- Tab bar
	self.tabBar = UI.createTabBar(self.overlay, { topOffset = 200, zIndex = 84 })
	self.tabBtns = {}
	
	local tabs = {
		{ id = "property", text = "🏠 Property", color = C.Teal },
		{ id = "vehicles", text = "🚗 Vehicles", color = C.Blue },
		{ id = "shop", text = "🛒 Shop", color = C.Purple }
	}
	
	for i, tab in ipairs(tabs) do
		local btn = UI.createTabButton(self.tabBar, {
			id = tab.id, text = tab.text, color = tab.color,
			active = i == 1, order = i, width = 0.31, zIndex = 84
		})
		self.tabBtns[tab.id] = { btn = btn, color = tab.color }
		btn.MouseButton1Click:Connect(function() self:switchTab(tab.id) end)
	end
	
	-- Scroll area
	self.contentScroll = UI.createScrollArea(self.overlay, { topOffset = 264, zIndex = 81 })
	
	-- Modals
	self:createResultModal()
	self:createGamblingModal()
	
	-- Initial populate
	self:populateProperty()
end

function AssetsScreen:createResultModal()
	self.resultModal = UI.createModalCard(self.screenGui, {
		name = "AssetsResult",
		accentColor = C.Green,
		accentDark = C.GreenDark,
		accentPale = C.GreenPale,
		zIndex = 96
	})
	
	self.resultModal.closeArea.MouseButton1Click:Connect(function()
		UI.hideModal(self.resultModal, function() self:switchTab(self.currentTab) end)
	end)
	self.resultModal.okButton.MouseButton1Click:Connect(function()
		UI.hideModal(self.resultModal, function() self:switchTab(self.currentTab) end)
	end)
end

function AssetsScreen:createGamblingModal()
	self.gamblingOverlay = Instance.new("Frame")
	self.gamblingOverlay.Size = UDim2.fromScale(1, 1)
	self.gamblingOverlay.BackgroundColor3 = C.Black
	self.gamblingOverlay.BackgroundTransparency = 0.3
	self.gamblingOverlay.Visible = false
	self.gamblingOverlay.ZIndex = 96
	self.gamblingOverlay.Parent = self.screenGui
	
	-- Casino card
	local card = Instance.new("Frame")
	card.Size = UDim2.new(0.92, 0, 0, 440)
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.fromScale(0.5, 0.5)
	card.BackgroundColor3 = Color3.fromRGB(26, 32, 44)
	card.ZIndex = 97
	card.Parent = self.gamblingOverlay
	UI.corner(card, 24)
	UI.createShadow(card, 8, 24, C.Black, 0.8)
	self.gamblingCard = card
	
	-- Gold header
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 65)
	header.BackgroundColor3 = C.Gold
	header.ZIndex = 98
	header.Parent = card
	UI.corner(header, 24)
	UI.gradient(header, C.Gold, C.GoldDark, 0)
	
	-- Fix header bottom
	local headerFix = Instance.new("Frame")
	headerFix.Size = UDim2.new(1, 0, 0, 30)
	headerFix.Position = UDim2.new(0, 0, 0, 40)
	headerFix.BackgroundColor3 = C.GoldDark
	headerFix.ZIndex = 98
	headerFix.Parent = header
	
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 1, 0)
	title.BackgroundTransparency = 1
	title.Font = F.Title
	title.TextSize = 24
	title.TextColor3 = C.White
	title.Text = "🎰 Lucky Slots"
	title.ZIndex = 99
	title.Parent = header
	
	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 40, 0, 40)
	closeBtn.AnchorPoint = Vector2.new(1, 0.5)
	closeBtn.Position = UDim2.new(1, -12, 0.5, 0)
	closeBtn.BackgroundColor3 = C.White
	closeBtn.BackgroundTransparency = 0.15
	closeBtn.Font = F.Title
	closeBtn.TextSize = 18
	closeBtn.TextColor3 = C.GoldDark
	closeBtn.Text = "X"
	closeBtn.AutoButtonColor = false
	closeBtn.ZIndex = 100
	closeBtn.Parent = header
	UI.corner(closeBtn, 20)
	
	closeBtn.MouseButton1Click:Connect(function() self:hideGambling() end)
	
	-- Slot display
	local slotContainer = Instance.new("Frame")
	slotContainer.Size = UDim2.new(0.9, 0, 0, 110)
	slotContainer.AnchorPoint = Vector2.new(0.5, 0)
	slotContainer.Position = UDim2.new(0.5, 0, 0, 85)
	slotContainer.BackgroundColor3 = Color3.fromRGB(45, 55, 72)
	slotContainer.ZIndex = 98
	slotContainer.Parent = card
	UI.corner(slotContainer, 18)
	
	local slotLayout = Instance.new("UIListLayout")
	slotLayout.FillDirection = Enum.FillDirection.Horizontal
	slotLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	slotLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	slotLayout.Padding = UDim.new(0, 18)
	slotLayout.Parent = slotContainer
	
	self.slotLabels = {}
	local slotSymbols = { "🍒", "🍋", "🍊" }
	for i = 1, 3 do
		local slotFrame = Instance.new("Frame")
		slotFrame.Size = UDim2.new(0, 80, 0, 85)
		slotFrame.BackgroundColor3 = C.White
		slotFrame.LayoutOrder = i
		slotFrame.ZIndex = 99
		slotFrame.Parent = slotContainer
		UI.corner(slotFrame, 14)
		
		local slotLabel = Instance.new("TextLabel")
		slotLabel.Size = UDim2.fromScale(1, 1)
		slotLabel.BackgroundTransparency = 1
		slotLabel.Font = F.Body
		slotLabel.TextSize = 55
		slotLabel.Text = slotSymbols[i]
		slotLabel.ZIndex = 100
		slotLabel.Parent = slotFrame
		
		self.slotLabels[i] = slotLabel
	end
	
	-- Bet display
	local betDisplay = Instance.new("Frame")
	betDisplay.Size = UDim2.new(0.9, 0, 0, 55)
	betDisplay.AnchorPoint = Vector2.new(0.5, 0)
	betDisplay.Position = UDim2.new(0.5, 0, 0, 210)
	betDisplay.BackgroundColor3 = Color3.fromRGB(45, 55, 72)
	betDisplay.ZIndex = 98
	betDisplay.Parent = card
	UI.corner(betDisplay, 14)
	
	local betLabel = Instance.new("TextLabel")
	betLabel.Size = UDim2.new(0.4, 0, 1, 0)
	betLabel.BackgroundTransparency = 1
	betLabel.Font = F.Medium
	betLabel.TextSize = 15
	betLabel.TextColor3 = C.Gray400
	betLabel.Text = "Your Bet:"
	betLabel.ZIndex = 99
	betLabel.Parent = betDisplay
	
	self.betAmount = 100
	self.betAmountLabel = Instance.new("TextLabel")
	self.betAmountLabel.Size = UDim2.new(0.6, 0, 1, 0)
	self.betAmountLabel.Position = UDim2.new(0.4, 0, 0, 0)
	self.betAmountLabel.BackgroundTransparency = 1
	self.betAmountLabel.Font = F.Title
	self.betAmountLabel.TextSize = 26
	self.betAmountLabel.TextColor3 = C.Gold
	self.betAmountLabel.TextXAlignment = Enum.TextXAlignment.Left
	self.betAmountLabel.Text = "$100"
	self.betAmountLabel.ZIndex = 99
	self.betAmountLabel.Parent = betDisplay
	
	-- Bet controls
	local betControls = Instance.new("Frame")
	betControls.Size = UDim2.new(0.9, 0, 0, 50)
	betControls.AnchorPoint = Vector2.new(0.5, 0)
	betControls.Position = UDim2.new(0.5, 0, 0, 275)
	betControls.BackgroundTransparency = 1
	betControls.ZIndex = 98
	betControls.Parent = card
	
	local controlLayout = Instance.new("UIListLayout")
	controlLayout.FillDirection = Enum.FillDirection.Horizontal
	controlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	controlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	controlLayout.Padding = UDim.new(0, 10)
	controlLayout.Parent = betControls
	
	local betAmounts = { 100, 500, 1000, 5000 }
	self.betBtns = {}
	for i, amt in ipairs(betAmounts) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 70, 0, 42)
		btn.BackgroundColor3 = self.betAmount == amt and C.Gold or Color3.fromRGB(45, 55, 72)
		btn.Font = F.Button
		btn.TextSize = 13
		btn.TextColor3 = C.White
		btn.Text = UI.formatMoney(amt)
		btn.AutoButtonColor = false
		btn.LayoutOrder = i
		btn.ZIndex = 99
		btn.Parent = betControls
		UI.corner(btn, 12)
		
		self.betBtns[amt] = btn
		
		btn.MouseButton1Click:Connect(function()
			self.betAmount = amt
			self.betAmountLabel.Text = UI.formatMoney(amt)
			for _, b in pairs(self.betBtns) do
				b.BackgroundColor3 = Color3.fromRGB(45, 55, 72)
			end
			btn.BackgroundColor3 = C.Gold
		end)
	end
	
	-- Spin button
	self.spinBtn = Instance.new("TextButton")
	self.spinBtn.Size = UDim2.new(0.8, 0, 0, 60)
	self.spinBtn.AnchorPoint = Vector2.new(0.5, 0)
	self.spinBtn.Position = UDim2.new(0.5, 0, 0, 340)
	self.spinBtn.BackgroundColor3 = C.Green
	self.spinBtn.Font = F.Title
	self.spinBtn.TextSize = 22
	self.spinBtn.TextColor3 = C.White
	self.spinBtn.Text = "🎰 SPIN!"
	self.spinBtn.AutoButtonColor = false
	self.spinBtn.ZIndex = 98
	self.spinBtn.Parent = card
	UI.corner(self.spinBtn, 16)
	UI.gradient(self.spinBtn, C.Green, C.GreenDark, 90)
	
	self.isSpinning = false
	self.spinBtn.MouseButton1Click:Connect(function() self:spin() end)
	
	-- Result text
	self.spinResult = Instance.new("TextLabel")
	self.spinResult.Size = UDim2.new(1, 0, 0, 30)
	self.spinResult.AnchorPoint = Vector2.new(0.5, 0)
	self.spinResult.Position = UDim2.new(0.5, 0, 0, 405)
	self.spinResult.BackgroundTransparency = 1
	self.spinResult.Font = F.Title
	self.spinResult.TextSize = 17
	self.spinResult.TextColor3 = C.White
	self.spinResult.Text = ""
	self.spinResult.ZIndex = 98
	self.spinResult.Parent = card
end

function AssetsScreen:updateBalanceBar()
	self.balanceValue.Text = UI.formatMoney(self:getMoney())
end

function AssetsScreen:switchTab(tabId)
	self.currentTab = tabId
	
	for id, data in pairs(self.tabBtns) do
		local isActive = id == tabId
		UI.tween(data.btn, TweenInfo.new(0.15), {
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

function AssetsScreen:populateProperty()
	self:updateBalanceBar()
	
	local section = UI.createSectionCard(self.contentScroll, {
		name = "PropertySection",
		title = "Real Estate",
		subtitle = #Properties .. " properties",
		accentColor = C.Teal,
		badgeWidth = 100,
		order = 1,
		zIndex = 82
	})
	
	for i, item in ipairs(Properties) do
		self:createAssetCard(section, item, i, "property", C.Teal, C.TealPale)
	end
end

function AssetsScreen:populateVehicles()
	self:updateBalanceBar()
	
	local section = UI.createSectionCard(self.contentScroll, {
		name = "VehiclesSection",
		title = "Vehicles",
		subtitle = #Vehicles .. " options",
		accentColor = C.Blue,
		badgeWidth = 85,
		order = 1,
		zIndex = 82
	})
	
	for i, item in ipairs(Vehicles) do
		self:createAssetCard(section, item, i, "vehicle", C.Blue, C.BluePale)
	end
end

function AssetsScreen:populateShop()
	self:updateBalanceBar()
	
	local section = UI.createSectionCard(self.contentScroll, {
		name = "ShopSection",
		title = "Shop",
		subtitle = #Shop .. " items",
		accentColor = C.Purple,
		badgeWidth = 70,
		order = 1,
		zIndex = 82
	})
	
	for i, item in ipairs(Shop) do
		self:createAssetCard(section, item, i, "item", C.Purple, C.PurplePale)
	end
end

function AssetsScreen:createAssetCard(parent, item, order, itemType, accentColor, paleColor)
	local age = self:getAge()
	local money = self:getMoney()
	local assets = self:getAssets()
	
	local minAge = item.minAge or 0
	local meetsAge = age >= minAge
	local canAfford = money >= item.price
	local alreadyOwns = assets[item.id] ~= nil
	local canBuy = meetsAge and canAfford and not alreadyOwns
	
	local card = Instance.new("Frame")
	card.Name = item.id
	card.Size = UDim2.new(1, 0, 0, 105)
	card.BackgroundColor3 = C.White
	card.LayoutOrder = order
	card.ZIndex = 83
	card.Parent = parent
	UI.corner(card, 16)
	UI.stroke(card, alreadyOwns and 2 or 1, alreadyOwns and 0.3 or 0.88, alreadyOwns and C.Green or C.Gray200)
	
	-- Icon
	local iconFrame = Instance.new("Frame")
	iconFrame.Size = UDim2.new(0, 62, 0, 62)
	iconFrame.Position = UDim2.new(0, 16, 0.5, -31)
	iconFrame.BackgroundColor3 = alreadyOwns and C.GreenPale or paleColor
	iconFrame.ZIndex = 84
	iconFrame.Parent = card
	UI.corner(iconFrame, 16)
	
	if not alreadyOwns then
		UI.gradient(iconFrame, paleColor, paleColor:Lerp(C.White, 0.3), 135)
	end
	
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.fromScale(1, 1)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Font = F.Body
	iconLabel.TextSize = 34
	iconLabel.Text = item.emoji
	iconLabel.ZIndex = 85
	iconLabel.Parent = iconFrame
	
	-- Owned badge
	if alreadyOwns then
		local badge = Instance.new("Frame")
		badge.Size = UDim2.new(0, 85, 0, 24)
		badge.Position = UDim2.new(0, 92, 0, 10)
		badge.BackgroundColor3 = C.Green
		badge.ZIndex = 85
		badge.Parent = card
		UI.pill(badge)
		
		local badgeLabel = Instance.new("TextLabel")
		badgeLabel.Size = UDim2.fromScale(1, 1)
		badgeLabel.BackgroundTransparency = 1
		badgeLabel.Font = F.Button
		badgeLabel.TextSize = 11
		badgeLabel.TextColor3 = C.White
		badgeLabel.Text = "✓ OWNED"
		badgeLabel.ZIndex = 86
		badgeLabel.Parent = badge
	end
	
	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0.5, 0, 0, 24)
	titleLabel.Position = UDim2.new(0, 92, 0, alreadyOwns and 36 or 14)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = F.Title
	titleLabel.TextSize = 16
	titleLabel.TextColor3 = C.Gray900
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = item.name
	titleLabel.ZIndex = 84
	titleLabel.Parent = card
	
	-- Badges
	local badgeY = alreadyOwns and 64 or 42
	
	-- Price badge
	local priceBadge = Instance.new("Frame")
	priceBadge.Size = UDim2.new(0, 85, 0, 26)
	priceBadge.Position = UDim2.new(0, 92, 0, badgeY)
	priceBadge.BackgroundColor3 = canAfford and C.GreenPale or C.RedPale
	priceBadge.ZIndex = 84
	priceBadge.Parent = card
	UI.pill(priceBadge)
	
	local priceLabel = Instance.new("TextLabel")
	priceLabel.Size = UDim2.fromScale(1, 1)
	priceLabel.BackgroundTransparency = 1
	priceLabel.Font = F.Medium
	priceLabel.TextSize = 12
	priceLabel.TextColor3 = canAfford and C.GreenDark or C.RedDark
	priceLabel.Text = "💵 " .. UI.formatMoney(item.price)
	priceLabel.ZIndex = 85
	priceLabel.Parent = priceBadge
	
	-- Income badge (for property)
	if item.income then
		local incomeBadge = Instance.new("Frame")
		incomeBadge.Size = UDim2.new(0, 85, 0, 26)
		incomeBadge.Position = UDim2.new(0, 182, 0, badgeY)
		incomeBadge.BackgroundColor3 = C.AmberPale
		incomeBadge.ZIndex = 84
		incomeBadge.Parent = card
		UI.pill(incomeBadge)
		
		local incomeLabel = Instance.new("TextLabel")
		incomeLabel.Size = UDim2.fromScale(1, 1)
		incomeLabel.BackgroundTransparency = 1
		incomeLabel.Font = F.Medium
		incomeLabel.TextSize = 11
		incomeLabel.TextColor3 = C.AmberDark
		incomeLabel.Text = "+" .. UI.formatMoney(item.income) .. "/yr"
		incomeLabel.ZIndex = 85
		incomeLabel.Parent = incomeBadge
	end
	
	-- Age requirement
	if not alreadyOwns and minAge > 0 then
		local reqLabel = Instance.new("TextLabel")
		reqLabel.Size = UDim2.new(0.3, 0, 0, 18)
		reqLabel.Position = UDim2.new(0, 92, 0, badgeY + 30)
		reqLabel.BackgroundTransparency = 1
		reqLabel.Font = F.Body
		reqLabel.TextSize = 11
		reqLabel.TextColor3 = meetsAge and C.Gray500 or C.Red
		reqLabel.TextXAlignment = Enum.TextXAlignment.Left
		reqLabel.Text = "Age " .. minAge .. "+"
		reqLabel.ZIndex = 84
		reqLabel.Parent = card
	end
	
	-- Buy button
	if not alreadyOwns then
		local buyBtn = Instance.new("TextButton")
		buyBtn.Size = UDim2.new(0, 78, 0, 46)
		buyBtn.AnchorPoint = Vector2.new(1, 0.5)
		buyBtn.Position = UDim2.new(1, -14, 0.5, 0)
		buyBtn.BackgroundColor3 = canBuy and accentColor or C.Gray300
		buyBtn.Font = F.Button
		buyBtn.TextSize = 14
		buyBtn.TextColor3 = canBuy and C.White or C.Gray500
		buyBtn.AutoButtonColor = false
		buyBtn.ZIndex = 84
		buyBtn.Parent = card
		UI.corner(buyBtn, 14)
		
		if canBuy then
			buyBtn.Text = "Buy"
			buyBtn.MouseEnter:Connect(function()
				UI.tween(buyBtn, TweenInfo.new(0.12), { 
					Size = UDim2.new(0, 84, 0, 50),
					BackgroundColor3 = accentColor:Lerp(C.Black, 0.15)
				})
			end)
			buyBtn.MouseLeave:Connect(function()
				UI.tween(buyBtn, TweenInfo.new(0.12), { 
					Size = UDim2.new(0, 78, 0, 46),
					BackgroundColor3 = accentColor
				})
			end)
			buyBtn.MouseButton1Click:Connect(function()
				self:buyAsset(item, itemType)
			end)
		else
			buyBtn.Text = not meetsAge and "Age " .. minAge or "Need $"
		end
	end
end

function AssetsScreen:buyAsset(item, itemType)
	local remote = nil
	if itemType == "property" then remote = BuyProperty
	elseif itemType == "vehicle" then remote = BuyVehicle
	else remote = BuyItem end
	
	if not remote then
		self:showResult(false, "Server not available", "❌")
		return
	end
	
	local result = remote:InvokeServer(item.id)
	if result then
		self:showResult(result.success, result.message, result.success and "🎉" or "😔")
	else
		self:showResult(false, "Server error", "❌")
	end
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
	
	UI.tween(self.gamblingCard, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 0
	})
end

function AssetsScreen:hideGambling()
	local t = UI.tween(self.gamblingCard, TweenInfo.new(0.2), {
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
	
	for spin = 1, 20 do
		task.wait(0.05 + spin * 0.01)
		for i = 1, 3 do
			local sym = symbols[math.random(1, #symbols)]
			self.slotLabels[i].Text = sym
			if spin == 20 then finalSymbols[i] = sym end
		end
	end
	
	task.delay(0.3, function()
		if Gamble then
			local result = Gamble:InvokeServer(self.betAmount, finalSymbols)
			if result then
				if result.success then
					self.spinResult.Text = "🎉 You won " .. UI.formatMoney(result.winnings) .. "!"
					self.spinResult.TextColor3 = C.Green
				else
					self.spinResult.Text = result.message or "Better luck next time!"
					self.spinResult.TextColor3 = C.Red
				end
			end
		else
			local won = finalSymbols[1] == finalSymbols[2] and finalSymbols[2] == finalSymbols[3]
			if won then
				self.spinResult.Text = "🎉 JACKPOT! You won " .. UI.formatMoney(self.betAmount * 5) .. "!"
				self.spinResult.TextColor3 = C.Green
			elseif finalSymbols[1] == finalSymbols[2] or finalSymbols[2] == finalSymbols[3] then
				self.spinResult.Text = "Nice! You won " .. UI.formatMoney(self.betAmount) .. "!"
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

function AssetsScreen:showResult(success, message, emoji)
	local shellColor = success and C.Green or C.Red
	local shellStroke = success and C.GreenDark or C.RedDark
	local pale = success and C.GreenPale or C.RedPale
	
	self.resultModal.shell.BackgroundColor3 = shellColor
	self.resultModal.shellStroke.Color = shellStroke
	self.resultModal.emojiFrame.BackgroundColor3 = pale
	self.resultModal.emojiLabel.Text = emoji or (success and "🎉" or "😔")
	self.resultModal.titleLabel.Text = success and "Purchase Complete!" or "Uh oh..."
	self.resultModal.titleLabel.TextColor3 = success and C.GreenDark or C.RedDark
	self.resultModal.messageLabel.Text = message or ""
	self.resultModal.okButton.BackgroundColor3 = shellColor
	
	UI.showModal(self.resultModal)
end

function AssetsScreen:show()
	log("=== SHOWING AssetsScreen ===")
	log("Current state - Age:", self:getAge(), "Money:", self:getMoney())
	self:updateBalanceBar()
	self:switchTab(self.currentTab)
	UI.slideInScreen(self.overlay, "right")
	self.isVisible = true
	log("✅ AssetsScreen is now visible")
end

function AssetsScreen:hide()
	log("=== HIDING AssetsScreen ===")
	UI.slideOutScreen(self.overlay, "right", function()
		self.resultModal.overlay.Visible = false
		self.gamblingOverlay.Visible = false
		log("✅ AssetsScreen hidden, modals cleaned up")
	end)
	self.isVisible = false
end

return AssetsScreen
