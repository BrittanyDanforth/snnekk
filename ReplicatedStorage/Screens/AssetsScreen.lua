-- AssetsScreen.lua
-- BitLife-style Assets screen with FULL INTERACTIVITY
-- Buy properties, vehicles, items, and manage your wealth

local TweenService = game:GetService("TweenService")

local AssetsScreen = {}
AssetsScreen.__index = AssetsScreen

----------------------------------------------------------------
-- COLORS
----------------------------------------------------------------

local Colors = {
	BitLifeBlue      = Color3.fromRGB(37, 99, 235),
	BitLifeBlueDark  = Color3.fromRGB(29, 78, 216),
	
	AssetsGreen      = Color3.fromRGB(16, 185, 129),
	AssetsGreenDark  = Color3.fromRGB(5, 150, 105),
	AssetsGreenLight = Color3.fromRGB(209, 250, 229),
	
	PropertyBlue     = Color3.fromRGB(59, 130, 246),
	VehicleOrange    = Color3.fromRGB(249, 115, 22),
	ShoppingPink     = Color3.fromRGB(236, 72, 153),
	CryptoYellow     = Color3.fromRGB(234, 179, 8),
	
	MoneyGreen       = Color3.fromRGB(34, 197, 94),
	MoneyRed         = Color3.fromRGB(239, 68, 68),
	
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
-- ASSET DATA
----------------------------------------------------------------

local Properties = {
	{ name = "Studio Apartment", emoji = "🏢", price = 85000, type = "Apartment", bedrooms = 0, sqft = 450, location = "Downtown" },
	{ name = "1BR Condo", emoji = "🏠", price = 175000, type = "Condo", bedrooms = 1, sqft = 750, location = "Suburbs" },
	{ name = "Family House", emoji = "🏡", price = 350000, type = "House", bedrooms = 3, sqft = 1800, location = "Suburbs" },
	{ name = "Luxury Penthouse", emoji = "🏙️", price = 2500000, type = "Penthouse", bedrooms = 4, sqft = 4000, location = "Downtown" },
	{ name = "Beach House", emoji = "🏖️", price = 1200000, type = "Beach", bedrooms = 3, sqft = 2200, location = "Beachfront" },
	{ name = "Mansion", emoji = "🏰", price = 8500000, type = "Mansion", bedrooms = 8, sqft = 12000, location = "Hills" },
}

local Vehicles = {
	{ name = "Used Honda Civic", emoji = "🚗", price = 8000, year = 2015, type = "Sedan", speed = "Slow" },
	{ name = "Toyota Camry", emoji = "🚙", price = 28000, year = 2023, type = "Sedan", speed = "Normal" },
	{ name = "BMW 3 Series", emoji = "🚘", price = 55000, year = 2024, type = "Luxury", speed = "Fast" },
	{ name = "Tesla Model S", emoji = "⚡", price = 95000, year = 2024, type = "Electric", speed = "Very Fast" },
	{ name = "Porsche 911", emoji = "🏎️", price = 180000, year = 2024, type = "Sports", speed = "Very Fast" },
	{ name = "Lamborghini Huracán", emoji = "🐂", price = 280000, year = 2024, type = "Supercar", speed = "Insane" },
	{ name = "Ferrari F8", emoji = "🏁", price = 350000, year = 2024, type = "Supercar", speed = "Insane" },
	{ name = "Yacht", emoji = "🛥️", price = 2000000, year = 2024, type = "Boat", speed = "Cruising" },
	{ name = "Private Jet", emoji = "✈️", price = 15000000, year = 2024, type = "Aircraft", speed = "Flying" },
}

local ShopItems = {
	{ name = "Designer Watch", emoji = "⌚", price = 5000, category = "Jewelry" },
	{ name = "Gold Necklace", emoji = "📿", price = 3500, category = "Jewelry" },
	{ name = "Diamond Ring", emoji = "💍", price = 15000, category = "Jewelry" },
	{ name = "Designer Bag", emoji = "👜", price = 2500, category = "Fashion" },
	{ name = "Sneakers", emoji = "👟", price = 350, category = "Fashion" },
	{ name = "Gaming PC", emoji = "🖥️", price = 3000, category = "Electronics" },
	{ name = "iPhone", emoji = "📱", price = 1200, category = "Electronics" },
	{ name = "Grand Piano", emoji = "🎹", price = 50000, category = "Music" },
}

local Crypto = {
	{ name = "Bitcoin", emoji = "₿", price = 67500, symbol = "BTC", change = 2.5 },
	{ name = "Ethereum", emoji = "Ξ", price = 3800, symbol = "ETH", change = -1.2 },
	{ name = "Dogecoin", emoji = "🐕", price = 0.12, symbol = "DOGE", change = 8.7 },
	{ name = "Solana", emoji = "◎", price = 175, symbol = "SOL", change = 5.1 },
}

----------------------------------------------------------------
-- PLAYER ASSETS (simulated)
----------------------------------------------------------------

local OwnedAssets = {
	properties = {},
	vehicles = {},
	items = {},
	crypto = {},
	cash = 50000,
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
	if amount >= 1000000 then return string.format("$%.2fM", amount / 1000000)
	elseif amount >= 1000 then return string.format("$%.1fK", amount / 1000)
	else return "$" .. string.format("%.2f", amount) end
end

local function formatPrice(amount)
	local str = tostring(math.floor(amount))
	local formatted = ""
	local count = 0
	for i = #str, 1, -1 do
		count = count + 1
		formatted = str:sub(i, i) .. formatted
		if count % 3 == 0 and i > 1 then
			formatted = "," .. formatted
		end
	end
	return "$" .. formatted
end

----------------------------------------------------------------
-- SCREEN CREATION
----------------------------------------------------------------

function AssetsScreen.new(screenGui, blurOverlay, showBlurFunc, hideBlurFunc, playerState)
	local self = setmetatable({}, AssetsScreen)
	
	self.screenGui = screenGui
	self.playerState = playerState
	self.isVisible = false
	
	self:createUI()
	self:createPurchaseModal()
	self:createResultModal()
	
	return self
end

function AssetsScreen:createUI()
	self.overlay = Instance.new("Frame")
	self.overlay.Name = "AssetsOverlay"
	self.overlay.Size = UDim2.fromScale(1, 1)
	self.overlay.BackgroundColor3 = Colors.ScreenBg
	self.overlay.Visible = false
	self.overlay.ZIndex = 80
	self.overlay.Parent = self.screenGui
	
	-- Header
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 60)
	header.BackgroundColor3 = Colors.AssetsGreen
	header.BorderSizePixel = 0
	header.ZIndex = 85
	header.Parent = self.overlay
	
	local headerGrad = Instance.new("UIGradient")
	headerGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Colors.AssetsGreen), ColorSequenceKeypoint.new(1, Colors.AssetsGreenDark) })
	headerGrad.Rotation = 90
	headerGrad.Parent = header
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -80, 1, 0)
	titleLabel.Position = UDim2.new(0, 16, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Fonts.Title
	titleLabel.TextSize = 20
	titleLabel.TextColor3 = Colors.White
	titleLabel.Text = "💰 Assets"
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
	
	-- Net Worth Card
	local netWorthCard = Instance.new("Frame")
	netWorthCard.Size = UDim2.new(1, -32, 0, 100)
	netWorthCard.Position = UDim2.new(0, 16, 0, 70)
	netWorthCard.BackgroundColor3 = Colors.CardWhite
	netWorthCard.ZIndex = 82
	netWorthCard.Parent = self.overlay
	createUICorner(netWorthCard, 16)
	createUIStroke(netWorthCard, 2, 0.6, Colors.AssetsGreen)
	
	local netWorthGrad = Instance.new("UIGradient")
	netWorthGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Colors.AssetsGreenLight) })
	netWorthGrad.Rotation = 90
	netWorthGrad.Parent = netWorthCard
	
	local nwTitle = Instance.new("TextLabel")
	nwTitle.Size = UDim2.new(1, 0, 0, 24)
	nwTitle.Position = UDim2.new(0, 0, 0, 14)
	nwTitle.BackgroundTransparency = 1
	nwTitle.Font = Fonts.Body
	nwTitle.TextSize = 13
	nwTitle.TextColor3 = Colors.DarkGray
	nwTitle.Text = "💎 NET WORTH"
	nwTitle.ZIndex = 83
	nwTitle.Parent = netWorthCard
	
	self.netWorthLabel = Instance.new("TextLabel")
	self.netWorthLabel.Size = UDim2.new(1, 0, 0, 40)
	self.netWorthLabel.Position = UDim2.new(0, 0, 0, 38)
	self.netWorthLabel.BackgroundTransparency = 1
	self.netWorthLabel.Font = Fonts.Title
	self.netWorthLabel.TextSize = 32
	self.netWorthLabel.TextColor3 = Colors.AssetsGreen
	self.netWorthLabel.Text = formatPrice(OwnedAssets.cash)
	self.netWorthLabel.ZIndex = 83
	self.netWorthLabel.Parent = netWorthCard
	
	local cashLabel = Instance.new("TextLabel")
	cashLabel.Size = UDim2.new(1, 0, 0, 18)
	cashLabel.Position = UDim2.new(0, 0, 0, 76)
	cashLabel.BackgroundTransparency = 1
	cashLabel.Font = Fonts.Body
	cashLabel.TextSize = 12
	cashLabel.TextColor3 = Colors.MediumGray
	cashLabel.Text = "💵 Cash: " .. formatPrice(OwnedAssets.cash)
	cashLabel.ZIndex = 83
	cashLabel.Parent = netWorthCard
	
	-- Content
	local contentScroll = Instance.new("ScrollingFrame")
	contentScroll.Size = UDim2.new(1, 0, 1, -180)
	contentScroll.Position = UDim2.new(0, 0, 0, 180)
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
	
	-- Create sections
	self:createPropertySection(1)
	self:createVehicleSection(2)
	self:createShoppingSection(3)
	self:createCryptoSection(4)
end

function AssetsScreen:createPropertySection(order)
	local section = Instance.new("Frame")
	section.Name = "PropertySection"
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
	headerFrame.BackgroundColor3 = Colors.PropertyBlue
	headerFrame.LayoutOrder = 1
	headerFrame.Parent = section
	createUICorner(headerFrame, 12)
	
	local headerText = Instance.new("TextLabel")
	headerText.Size = UDim2.fromScale(1, 1)
	headerText.BackgroundTransparency = 1
	headerText.Font = Fonts.Title
	headerText.TextSize = 16
	headerText.TextColor3 = Colors.White
	headerText.Text = "🏠 Property Market"
	headerText.Parent = headerFrame
	
	for i, prop in ipairs(Properties) do
		self:createPropertyCard(prop, i + 1, section)
	end
end

function AssetsScreen:createPropertyCard(prop, order, parent)
	local card = Instance.new("Frame")
	card.Name = "Property_" .. prop.name:gsub(" ", "_")
	card.Size = UDim2.new(1, 0, 0, 95)
	card.BackgroundColor3 = Colors.CardWhite
	card.LayoutOrder = order
	card.Parent = parent
	createUICorner(card, 14)
	createUIStroke(card, 1, 0.85, Color3.fromRGB(229, 231, 235))
	
	local emojiCircle = Instance.new("Frame")
	emojiCircle.Size = UDim2.new(0, 50, 0, 50)
	emojiCircle.Position = UDim2.new(0, 14, 0.5, -25)
	emojiCircle.BackgroundColor3 = Color3.fromRGB(239, 246, 255)
	emojiCircle.Parent = card
	createUICorner(emojiCircle, 25)
	
	local emojiLabel = Instance.new("TextLabel")
	emojiLabel.Size = UDim2.fromScale(1, 1)
	emojiLabel.BackgroundTransparency = 1
	emojiLabel.Font = Fonts.Body
	emojiLabel.TextSize = 26
	emojiLabel.Text = prop.emoji
	emojiLabel.Parent = emojiCircle
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.5, 0, 0, 20)
	nameLabel.Position = UDim2.new(0, 74, 0, 10)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Fonts.Title
	nameLabel.TextSize = 14
	nameLabel.TextColor3 = Colors.TextBlack
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = prop.name
	nameLabel.Parent = card
	
	local detailLabel = Instance.new("TextLabel")
	detailLabel.Size = UDim2.new(0.5, 0, 0, 14)
	detailLabel.Position = UDim2.new(0, 74, 0, 30)
	detailLabel.BackgroundTransparency = 1
	detailLabel.Font = Fonts.Body
	detailLabel.TextSize = 11
	detailLabel.TextColor3 = Colors.MediumGray
	detailLabel.TextXAlignment = Enum.TextXAlignment.Left
	detailLabel.Text = prop.bedrooms .. " bed • " .. string.format("%,d", prop.sqft) .. " sq ft"
	detailLabel.Parent = card
	
	local locLabel = Instance.new("TextLabel")
	locLabel.Size = UDim2.new(0.5, 0, 0, 14)
	locLabel.Position = UDim2.new(0, 74, 0, 46)
	locLabel.BackgroundTransparency = 1
	locLabel.Font = Fonts.Body
	locLabel.TextSize = 11
	locLabel.TextColor3 = Colors.MediumGray
	locLabel.TextXAlignment = Enum.TextXAlignment.Left
	locLabel.Text = "📍 " .. prop.location
	locLabel.Parent = card
	
	local priceLabel = Instance.new("TextLabel")
	priceLabel.Size = UDim2.new(0.5, 0, 0, 18)
	priceLabel.Position = UDim2.new(0, 74, 0, 66)
	priceLabel.BackgroundTransparency = 1
	priceLabel.Font = Fonts.Title
	priceLabel.TextSize = 14
	priceLabel.TextColor3 = Colors.MoneyGreen
	priceLabel.TextXAlignment = Enum.TextXAlignment.Left
	priceLabel.Text = formatPrice(prop.price)
	priceLabel.Parent = card
	
	local buyBtn = Instance.new("TextButton")
	buyBtn.Size = UDim2.new(0, 60, 0, 34)
	buyBtn.AnchorPoint = Vector2.new(1, 0.5)
	buyBtn.Position = UDim2.new(1, -14, 0.5, 0)
	buyBtn.BackgroundColor3 = Colors.PropertyBlue
	buyBtn.Font = Fonts.Button
	buyBtn.TextSize = 13
	buyBtn.TextColor3 = Colors.White
	buyBtn.Text = "Buy"
	buyBtn.AutoButtonColor = false
	buyBtn.Parent = card
	createPillCorner(buyBtn)
	
	buyBtn.MouseEnter:Connect(function() tween(buyBtn, TweenInfo.new(0.1), { BackgroundColor3 = Colors.BitLifeBlueDark }) end)
	buyBtn.MouseLeave:Connect(function() tween(buyBtn, TweenInfo.new(0.1), { BackgroundColor3 = Colors.PropertyBlue }) end)
	
	buyBtn.MouseButton1Click:Connect(function()
		self:showPurchaseModal(prop, "property")
	end)
end

function AssetsScreen:createVehicleSection(order)
	local section = Instance.new("Frame")
	section.Name = "VehicleSection"
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
	headerFrame.BackgroundColor3 = Colors.VehicleOrange
	headerFrame.LayoutOrder = 1
	headerFrame.Parent = section
	createUICorner(headerFrame, 12)
	
	local headerText = Instance.new("TextLabel")
	headerText.Size = UDim2.fromScale(1, 1)
	headerText.BackgroundTransparency = 1
	headerText.Font = Fonts.Title
	headerText.TextSize = 16
	headerText.TextColor3 = Colors.White
	headerText.Text = "🚗 Vehicle Dealership"
	headerText.Parent = headerFrame
	
	for i, vehicle in ipairs(Vehicles) do
		self:createVehicleCard(vehicle, i + 1, section)
	end
end

function AssetsScreen:createVehicleCard(vehicle, order, parent)
	local card = Instance.new("Frame")
	card.Name = "Vehicle_" .. vehicle.name:gsub(" ", "_")
	card.Size = UDim2.new(1, 0, 0, 85)
	card.BackgroundColor3 = Colors.CardWhite
	card.LayoutOrder = order
	card.Parent = parent
	createUICorner(card, 14)
	createUIStroke(card, 1, 0.85, Color3.fromRGB(229, 231, 235))
	
	local emojiCircle = Instance.new("Frame")
	emojiCircle.Size = UDim2.new(0, 50, 0, 50)
	emojiCircle.Position = UDim2.new(0, 14, 0.5, -25)
	emojiCircle.BackgroundColor3 = Color3.fromRGB(255, 247, 237)
	emojiCircle.Parent = card
	createUICorner(emojiCircle, 25)
	
	local emojiLabel = Instance.new("TextLabel")
	emojiLabel.Size = UDim2.fromScale(1, 1)
	emojiLabel.BackgroundTransparency = 1
	emojiLabel.Font = Fonts.Body
	emojiLabel.TextSize = 26
	emojiLabel.Text = vehicle.emoji
	emojiLabel.Parent = emojiCircle
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.5, 0, 0, 20)
	nameLabel.Position = UDim2.new(0, 74, 0, 12)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Fonts.Title
	nameLabel.TextSize = 14
	nameLabel.TextColor3 = Colors.TextBlack
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = vehicle.name
	nameLabel.Parent = card
	
	local detailLabel = Instance.new("TextLabel")
	detailLabel.Size = UDim2.new(0.5, 0, 0, 14)
	detailLabel.Position = UDim2.new(0, 74, 0, 32)
	detailLabel.BackgroundTransparency = 1
	detailLabel.Font = Fonts.Body
	detailLabel.TextSize = 11
	detailLabel.TextColor3 = Colors.MediumGray
	detailLabel.TextXAlignment = Enum.TextXAlignment.Left
	detailLabel.Text = vehicle.year .. " • " .. vehicle.type .. " • " .. vehicle.speed
	detailLabel.Parent = card
	
	local priceLabel = Instance.new("TextLabel")
	priceLabel.Size = UDim2.new(0.5, 0, 0, 18)
	priceLabel.Position = UDim2.new(0, 74, 0, 52)
	priceLabel.BackgroundTransparency = 1
	priceLabel.Font = Fonts.Title
	priceLabel.TextSize = 14
	priceLabel.TextColor3 = Colors.MoneyGreen
	priceLabel.TextXAlignment = Enum.TextXAlignment.Left
	priceLabel.Text = formatPrice(vehicle.price)
	priceLabel.Parent = card
	
	local buyBtn = Instance.new("TextButton")
	buyBtn.Size = UDim2.new(0, 60, 0, 34)
	buyBtn.AnchorPoint = Vector2.new(1, 0.5)
	buyBtn.Position = UDim2.new(1, -14, 0.5, 0)
	buyBtn.BackgroundColor3 = Colors.VehicleOrange
	buyBtn.Font = Fonts.Button
	buyBtn.TextSize = 13
	buyBtn.TextColor3 = Colors.White
	buyBtn.Text = "Buy"
	buyBtn.AutoButtonColor = false
	buyBtn.Parent = card
	createPillCorner(buyBtn)
	
	buyBtn.MouseEnter:Connect(function() tween(buyBtn, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(234, 88, 12) }) end)
	buyBtn.MouseLeave:Connect(function() tween(buyBtn, TweenInfo.new(0.1), { BackgroundColor3 = Colors.VehicleOrange }) end)
	
	buyBtn.MouseButton1Click:Connect(function()
		self:showPurchaseModal(vehicle, "vehicle")
	end)
end

function AssetsScreen:createShoppingSection(order)
	local section = Instance.new("Frame")
	section.Name = "ShoppingSection"
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
	headerFrame.BackgroundColor3 = Colors.ShoppingPink
	headerFrame.LayoutOrder = 1
	headerFrame.Parent = section
	createUICorner(headerFrame, 12)
	
	local headerText = Instance.new("TextLabel")
	headerText.Size = UDim2.fromScale(1, 1)
	headerText.BackgroundTransparency = 1
	headerText.Font = Fonts.Title
	headerText.TextSize = 16
	headerText.TextColor3 = Colors.White
	headerText.Text = "🛍️ Shopping"
	headerText.Parent = headerFrame
	
	for i, item in ipairs(ShopItems) do
		self:createShopItemCard(item, i + 1, section)
	end
end

function AssetsScreen:createShopItemCard(item, order, parent)
	local card = Instance.new("Frame")
	card.Name = "Item_" .. item.name:gsub(" ", "_")
	card.Size = UDim2.new(1, 0, 0, 70)
	card.BackgroundColor3 = Colors.CardWhite
	card.LayoutOrder = order
	card.Parent = parent
	createUICorner(card, 14)
	createUIStroke(card, 1, 0.85, Color3.fromRGB(229, 231, 235))
	
	local emojiCircle = Instance.new("Frame")
	emojiCircle.Size = UDim2.new(0, 46, 0, 46)
	emojiCircle.Position = UDim2.new(0, 14, 0.5, -23)
	emojiCircle.BackgroundColor3 = Color3.fromRGB(253, 242, 248)
	emojiCircle.Parent = card
	createUICorner(emojiCircle, 23)
	
	local emojiLabel = Instance.new("TextLabel")
	emojiLabel.Size = UDim2.fromScale(1, 1)
	emojiLabel.BackgroundTransparency = 1
	emojiLabel.Font = Fonts.Body
	emojiLabel.TextSize = 24
	emojiLabel.Text = item.emoji
	emojiLabel.Parent = emojiCircle
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.5, 0, 0, 20)
	nameLabel.Position = UDim2.new(0, 70, 0, 14)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Fonts.Title
	nameLabel.TextSize = 14
	nameLabel.TextColor3 = Colors.TextBlack
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = item.name
	nameLabel.Parent = card
	
	local catLabel = Instance.new("TextLabel")
	catLabel.Size = UDim2.new(0.5, 0, 0, 14)
	catLabel.Position = UDim2.new(0, 70, 0, 34)
	catLabel.BackgroundTransparency = 1
	catLabel.Font = Fonts.Body
	catLabel.TextSize = 11
	catLabel.TextColor3 = Colors.MediumGray
	catLabel.TextXAlignment = Enum.TextXAlignment.Left
	catLabel.Text = "📦 " .. item.category
	catLabel.Parent = card
	
	local priceLabel = Instance.new("TextLabel")
	priceLabel.Size = UDim2.new(0, 80, 0, 24)
	priceLabel.AnchorPoint = Vector2.new(1, 0.5)
	priceLabel.Position = UDim2.new(1, -80, 0.5, 0)
	priceLabel.BackgroundTransparency = 1
	priceLabel.Font = Fonts.Title
	priceLabel.TextSize = 14
	priceLabel.TextColor3 = Colors.MoneyGreen
	priceLabel.TextXAlignment = Enum.TextXAlignment.Right
	priceLabel.Text = formatPrice(item.price)
	priceLabel.Parent = card
	
	local buyBtn = Instance.new("TextButton")
	buyBtn.Size = UDim2.new(0, 54, 0, 32)
	buyBtn.AnchorPoint = Vector2.new(1, 0.5)
	buyBtn.Position = UDim2.new(1, -14, 0.5, 0)
	buyBtn.BackgroundColor3 = Colors.ShoppingPink
	buyBtn.Font = Fonts.Button
	buyBtn.TextSize = 12
	buyBtn.TextColor3 = Colors.White
	buyBtn.Text = "Buy"
	buyBtn.AutoButtonColor = false
	buyBtn.Parent = card
	createPillCorner(buyBtn)
	
	buyBtn.MouseEnter:Connect(function() tween(buyBtn, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(219, 39, 119) }) end)
	buyBtn.MouseLeave:Connect(function() tween(buyBtn, TweenInfo.new(0.1), { BackgroundColor3 = Colors.ShoppingPink }) end)
	
	buyBtn.MouseButton1Click:Connect(function()
		self:showPurchaseModal(item, "item")
	end)
end

function AssetsScreen:createCryptoSection(order)
	local section = Instance.new("Frame")
	section.Name = "CryptoSection"
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
	headerFrame.BackgroundColor3 = Colors.CryptoYellow
	headerFrame.LayoutOrder = 1
	headerFrame.Parent = section
	createUICorner(headerFrame, 12)
	
	local headerText = Instance.new("TextLabel")
	headerText.Size = UDim2.fromScale(1, 1)
	headerText.BackgroundTransparency = 1
	headerText.Font = Fonts.Title
	headerText.TextSize = 16
	headerText.TextColor3 = Colors.TextBlack
	headerText.Text = "🪙 Crypto Exchange"
	headerText.Parent = headerFrame
	
	for i, crypto in ipairs(Crypto) do
		self:createCryptoCard(crypto, i + 1, section)
	end
end

function AssetsScreen:createCryptoCard(crypto, order, parent)
	local card = Instance.new("Frame")
	card.Name = "Crypto_" .. crypto.symbol
	card.Size = UDim2.new(1, 0, 0, 70)
	card.BackgroundColor3 = Colors.CardWhite
	card.LayoutOrder = order
	card.Parent = parent
	createUICorner(card, 14)
	createUIStroke(card, 1, 0.85, Color3.fromRGB(229, 231, 235))
	
	local emojiCircle = Instance.new("Frame")
	emojiCircle.Size = UDim2.new(0, 46, 0, 46)
	emojiCircle.Position = UDim2.new(0, 14, 0.5, -23)
	emojiCircle.BackgroundColor3 = Color3.fromRGB(254, 249, 195)
	emojiCircle.Parent = card
	createUICorner(emojiCircle, 23)
	
	local emojiLabel = Instance.new("TextLabel")
	emojiLabel.Size = UDim2.fromScale(1, 1)
	emojiLabel.BackgroundTransparency = 1
	emojiLabel.Font = Fonts.Title
	emojiLabel.TextSize = 22
	emojiLabel.Text = crypto.emoji
	emojiLabel.Parent = emojiCircle
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.4, 0, 0, 20)
	nameLabel.Position = UDim2.new(0, 70, 0, 14)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Fonts.Title
	nameLabel.TextSize = 14
	nameLabel.TextColor3 = Colors.TextBlack
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = crypto.name .. " (" .. crypto.symbol .. ")"
	nameLabel.Parent = card
	
	local changeColor = crypto.change >= 0 and Colors.MoneyGreen or Colors.MoneyRed
	local changeLabel = Instance.new("TextLabel")
	changeLabel.Size = UDim2.new(0.4, 0, 0, 14)
	changeLabel.Position = UDim2.new(0, 70, 0, 34)
	changeLabel.BackgroundTransparency = 1
	changeLabel.Font = Fonts.BodyMedium
	changeLabel.TextSize = 12
	changeLabel.TextColor3 = changeColor
	changeLabel.TextXAlignment = Enum.TextXAlignment.Left
	changeLabel.Text = (crypto.change >= 0 and "▲ +" or "▼ ") .. string.format("%.1f%%", crypto.change)
	changeLabel.Parent = card
	
	local priceLabel = Instance.new("TextLabel")
	priceLabel.Size = UDim2.new(0, 100, 0, 20)
	priceLabel.AnchorPoint = Vector2.new(1, 0.5)
	priceLabel.Position = UDim2.new(1, -80, 0.5, 0)
	priceLabel.BackgroundTransparency = 1
	priceLabel.Font = Fonts.Title
	priceLabel.TextSize = 14
	priceLabel.TextColor3 = Colors.TextBlack
	priceLabel.TextXAlignment = Enum.TextXAlignment.Right
	priceLabel.Text = formatPrice(crypto.price)
	priceLabel.Parent = card
	
	local buyBtn = Instance.new("TextButton")
	buyBtn.Size = UDim2.new(0, 54, 0, 32)
	buyBtn.AnchorPoint = Vector2.new(1, 0.5)
	buyBtn.Position = UDim2.new(1, -14, 0.5, 0)
	buyBtn.BackgroundColor3 = Colors.CryptoYellow
	buyBtn.Font = Fonts.Button
	buyBtn.TextSize = 12
	buyBtn.TextColor3 = Colors.TextBlack
	buyBtn.Text = "Buy"
	buyBtn.AutoButtonColor = false
	buyBtn.Parent = card
	createPillCorner(buyBtn)
	
	buyBtn.MouseEnter:Connect(function() tween(buyBtn, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(202, 138, 4) }) end)
	buyBtn.MouseLeave:Connect(function() tween(buyBtn, TweenInfo.new(0.1), { BackgroundColor3 = Colors.CryptoYellow }) end)
	
	buyBtn.MouseButton1Click:Connect(function()
		self:showPurchaseModal(crypto, "crypto")
	end)
end

function AssetsScreen:createPurchaseModal()
	self.purchaseOverlay = Instance.new("Frame")
	self.purchaseOverlay.Name = "PurchaseOverlay"
	self.purchaseOverlay.Size = UDim2.fromScale(1, 1)
	self.purchaseOverlay.BackgroundColor3 = Colors.OverlayDark
	self.purchaseOverlay.BackgroundTransparency = 0.4
	self.purchaseOverlay.Visible = false
	self.purchaseOverlay.ZIndex = 90
	self.purchaseOverlay.Parent = self.screenGui
	
	self.purchaseModal = Instance.new("Frame")
	self.purchaseModal.Size = UDim2.new(0, 320, 0, 0)
	self.purchaseModal.AutomaticSize = Enum.AutomaticSize.Y
	self.purchaseModal.AnchorPoint = Vector2.new(0.5, 0.5)
	self.purchaseModal.Position = UDim2.fromScale(0.5, 0.5)
	self.purchaseModal.BackgroundColor3 = Colors.CardWhite
	self.purchaseModal.ZIndex = 91
	self.purchaseModal.Parent = self.purchaseOverlay
	createUICorner(self.purchaseModal, 20)
	
	createUIPadding(self.purchaseModal, 24, 24, 24, 24)
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 12)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = self.purchaseModal
	
	self.purchaseEmoji = Instance.new("TextLabel")
	self.purchaseEmoji.Size = UDim2.new(0, 60, 0, 60)
	self.purchaseEmoji.BackgroundTransparency = 1
	self.purchaseEmoji.Font = Fonts.Body
	self.purchaseEmoji.TextSize = 50
	self.purchaseEmoji.Text = "🏠"
	self.purchaseEmoji.LayoutOrder = 1
	self.purchaseEmoji.Parent = self.purchaseModal
	
	self.purchaseTitle = Instance.new("TextLabel")
	self.purchaseTitle.Size = UDim2.new(1, 0, 0, 24)
	self.purchaseTitle.BackgroundTransparency = 1
	self.purchaseTitle.Font = Fonts.Title
	self.purchaseTitle.TextSize = 18
	self.purchaseTitle.TextColor3 = Colors.TextBlack
	self.purchaseTitle.Text = "Item Name"
	self.purchaseTitle.LayoutOrder = 2
	self.purchaseTitle.Parent = self.purchaseModal
	
	self.purchaseDesc = Instance.new("TextLabel")
	self.purchaseDesc.Size = UDim2.new(1, 0, 0, 0)
	self.purchaseDesc.AutomaticSize = Enum.AutomaticSize.Y
	self.purchaseDesc.BackgroundTransparency = 1
	self.purchaseDesc.Font = Fonts.Body
	self.purchaseDesc.TextSize = 13
	self.purchaseDesc.TextColor3 = Colors.DarkGray
	self.purchaseDesc.TextWrapped = true
	self.purchaseDesc.Text = "Details about the item"
	self.purchaseDesc.LayoutOrder = 3
	self.purchaseDesc.Parent = self.purchaseModal
	
	self.purchasePrice = Instance.new("TextLabel")
	self.purchasePrice.Size = UDim2.new(1, 0, 0, 32)
	self.purchasePrice.BackgroundTransparency = 1
	self.purchasePrice.Font = Fonts.Title
	self.purchasePrice.TextSize = 24
	self.purchasePrice.TextColor3 = Colors.MoneyGreen
	self.purchasePrice.Text = "$0"
	self.purchasePrice.LayoutOrder = 4
	self.purchasePrice.Parent = self.purchaseModal
	
	self.purchaseCash = Instance.new("TextLabel")
	self.purchaseCash.Size = UDim2.new(1, 0, 0, 20)
	self.purchaseCash.BackgroundTransparency = 1
	self.purchaseCash.Font = Fonts.Body
	self.purchaseCash.TextSize = 12
	self.purchaseCash.TextColor3 = Colors.MediumGray
	self.purchaseCash.Text = "Your cash: $0"
	self.purchaseCash.LayoutOrder = 5
	self.purchaseCash.Parent = self.purchaseModal
	
	local btnContainer = Instance.new("Frame")
	btnContainer.Size = UDim2.new(1, 0, 0, 48)
	btnContainer.BackgroundTransparency = 1
	btnContainer.LayoutOrder = 6
	btnContainer.Parent = self.purchaseModal
	
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
		self:hidePurchaseModal()
	end)
	
	self.confirmPurchaseBtn = Instance.new("TextButton")
	self.confirmPurchaseBtn.Size = UDim2.new(0.45, 0, 1, 0)
	self.confirmPurchaseBtn.BackgroundColor3 = Colors.MoneyGreen
	self.confirmPurchaseBtn.Font = Fonts.Button
	self.confirmPurchaseBtn.TextSize = 15
	self.confirmPurchaseBtn.TextColor3 = Colors.White
	self.confirmPurchaseBtn.Text = "Buy!"
	self.confirmPurchaseBtn.AutoButtonColor = false
	self.confirmPurchaseBtn.Parent = btnContainer
	createPillCorner(self.confirmPurchaseBtn)
end

function AssetsScreen:createResultModal()
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
	self.resultTitle.TextColor3 = Colors.MoneyGreen
	self.resultTitle.Text = "Purchase Complete!"
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
	self.resultText.Text = "You bought something!"
	self.resultText.LayoutOrder = 3
	self.resultText.Parent = self.resultModal
	
	local okBtn = Instance.new("TextButton")
	okBtn.Size = UDim2.new(1, 0, 0, 48)
	okBtn.BackgroundColor3 = Colors.BitLifeBlue
	okBtn.Font = Fonts.Button
	okBtn.TextSize = 16
	okBtn.TextColor3 = Colors.White
	okBtn.Text = "Awesome!"
	okBtn.AutoButtonColor = false
	okBtn.LayoutOrder = 4
	okBtn.Parent = self.resultModal
	createPillCorner(okBtn)
	
	okBtn.MouseButton1Click:Connect(function()
		self:hideResultModal()
	end)
end

function AssetsScreen:showPurchaseModal(item, itemType)
	self.currentItem = item
	self.currentItemType = itemType
	
	self.purchaseEmoji.Text = item.emoji
	self.purchaseTitle.Text = item.name
	self.purchasePrice.Text = formatPrice(item.price)
	self.purchaseCash.Text = "Your cash: " .. formatPrice(OwnedAssets.cash)
	
	-- Set description based on type
	local desc = ""
	if itemType == "property" then
		desc = item.bedrooms .. " bedroom " .. item.type .. " in " .. item.location .. "\n" .. string.format("%,d", item.sqft) .. " square feet"
	elseif itemType == "vehicle" then
		desc = item.year .. " " .. item.type .. "\nSpeed: " .. item.speed
	elseif itemType == "crypto" then
		desc = "Buy 1 " .. item.symbol .. " at current market price"
	else
		desc = item.category .. " item"
	end
	self.purchaseDesc.Text = desc
	
	-- Check if can afford
	local canAfford = OwnedAssets.cash >= item.price
	self.confirmPurchaseBtn.BackgroundColor3 = canAfford and Colors.MoneyGreen or Colors.MediumGray
	self.purchaseCash.TextColor3 = canAfford and Colors.MediumGray or Colors.MoneyRed
	
	-- Disconnect old connection
	if self.purchaseConnection then
		self.purchaseConnection:Disconnect()
	end
	
	self.purchaseConnection = self.confirmPurchaseBtn.MouseButton1Click:Connect(function()
		if canAfford then
			self:completePurchase(item, itemType)
		else
			-- Show can't afford message
			self:showResult("😢", "Can't Afford!", "You don't have enough money for this purchase.", false)
			self:hidePurchaseModal()
		end
	end)
	
	self.purchaseOverlay.Visible = true
	self.purchaseModal.Position = UDim2.new(0.5, 0, 0.5, 30)
	tween(self.purchaseModal, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.5)
	})
end

function AssetsScreen:hidePurchaseModal()
	self.purchaseOverlay.Visible = false
end

function AssetsScreen:completePurchase(item, itemType)
	self:hidePurchaseModal()
	
	-- Deduct money
	OwnedAssets.cash = OwnedAssets.cash - item.price
	
	-- Add to owned assets
	if itemType == "property" then
		table.insert(OwnedAssets.properties, item)
	elseif itemType == "vehicle" then
		table.insert(OwnedAssets.vehicles, item)
	elseif itemType == "item" then
		table.insert(OwnedAssets.items, item)
	elseif itemType == "crypto" then
		table.insert(OwnedAssets.crypto, { coin = item, amount = 1 })
	end
	
	-- Update net worth display
	self.netWorthLabel.Text = formatPrice(OwnedAssets.cash)
	
	-- Show success
	task.delay(0.2, function()
		local message = ""
		if itemType == "property" then
			message = "You are now the proud owner of a " .. item.name .. "!"
		elseif itemType == "vehicle" then
			message = "Congratulations on your new " .. item.name .. "!"
		elseif itemType == "crypto" then
			message = "You purchased 1 " .. item.symbol .. "!"
		else
			message = "You bought a " .. item.name .. "!"
		end
		self:showResult(item.emoji, "Purchase Complete!", message, true)
	end)
end

function AssetsScreen:showResult(emoji, title, text, success)
	self.resultEmoji.Text = emoji
	self.resultTitle.Text = title
	self.resultTitle.TextColor3 = success and Colors.MoneyGreen or Colors.MoneyRed
	self.resultText.Text = text
	
	self.resultOverlay.Visible = true
	self.resultModal.Position = UDim2.new(0.5, 0, 0.5, 30)
	tween(self.resultModal, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.5)
	})
end

function AssetsScreen:hideResultModal()
	self.resultOverlay.Visible = false
end

----------------------------------------------------------------
-- VISIBILITY
----------------------------------------------------------------

function AssetsScreen:show()
	if self.isVisible then return end
	self.isVisible = true
	
	self.overlay.Visible = true
	self.overlay.Position = UDim2.new(1, 0, 0, 0)
	
	tween(self.overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 0, 0, 0)
	})
end

function AssetsScreen:hide()
	if not self.isVisible then return end
	self.isVisible = false
	
	self.purchaseOverlay.Visible = false
	self.resultOverlay.Visible = false
	
	local t = tween(self.overlay, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		Position = UDim2.new(1, 0, 0, 0)
	})
	t.Completed:Connect(function()
		self.overlay.Visible = false
	end)
end

function AssetsScreen:toggle()
	if self.isVisible then self:hide() else self:show() end
end

return AssetsScreen
