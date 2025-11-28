-- AssetsScreen.lua
-- BitLife-style Assets screen with properties, vehicles, and items
-- Full-screen overlay with scrollable content sections

local TweenService = game:GetService("TweenService")

local AssetsScreen = {}
AssetsScreen.__index = AssetsScreen

----------------------------------------------------------------
-- COLORS (BitLife Palette)
----------------------------------------------------------------

local Colors = {
	-- Primary
	BitLifeBlue      = Color3.fromRGB(37, 99, 235),
	BitLifeBlueDark  = Color3.fromRGB(29, 78, 216),
	
	-- Section Colors
	PropertyGreen    = Color3.fromRGB(16, 185, 129),
	PropertyGreenDark = Color3.fromRGB(5, 150, 105),
	VehicleBlue      = Color3.fromRGB(59, 130, 246),
	VehicleBlueDark  = Color3.fromRGB(37, 99, 235),
	ItemsOrange      = Color3.fromRGB(245, 158, 11),
	ItemsOrangeDark  = Color3.fromRGB(217, 119, 6),
	LuxuryPurple     = Color3.fromRGB(168, 85, 247),
	LuxuryPurpleDark = Color3.fromRGB(139, 92, 246),
	CryptoGold       = Color3.fromRGB(251, 191, 36),
	SellRed          = Color3.fromRGB(239, 68, 68),
	
	-- Net Worth
	NetWorthGreen    = Color3.fromRGB(34, 197, 94),
	DebtRed          = Color3.fromRGB(220, 38, 38),
	
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
	OverlayBlack     = Color3.fromRGB(0, 0, 0),
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
-- ASSET DATA
----------------------------------------------------------------

local PropertyListings = {
	-- Apartments
	{
		name = "Studio Apartment",
		type = "Apartment",
		price = 85000,
		emoji = "🏢",
		location = "Downtown",
		sqft = 450,
		condition = "Good",
	},
	{
		name = "1BR Apartment",
		type = "Apartment",
		price = 150000,
		emoji = "🏢",
		location = "Midtown",
		sqft = 700,
		condition = "Excellent",
	},
	{
		name = "Luxury Penthouse",
		type = "Apartment",
		price = 2500000,
		emoji = "🌆",
		location = "Upper East Side",
		sqft = 3500,
		condition = "Excellent",
	},
	-- Houses
	{
		name = "Starter Home",
		type = "House",
		price = 220000,
		emoji = "🏠",
		location = "Suburbs",
		sqft = 1200,
		condition = "Fair",
	},
	{
		name = "Family Home",
		type = "House",
		price = 450000,
		emoji = "🏡",
		location = "Suburbs",
		sqft = 2400,
		condition = "Good",
	},
	{
		name = "McMansion",
		type = "House",
		price = 1200000,
		emoji = "🏰",
		location = "Gated Community",
		sqft = 5500,
		condition = "Excellent",
	},
	{
		name = "Beach House",
		type = "House",
		price = 3500000,
		emoji = "🏖️",
		location = "Malibu",
		sqft = 4200,
		condition = "Excellent",
	},
	{
		name = "Private Island",
		type = "Estate",
		price = 50000000,
		emoji = "🏝️",
		location = "Caribbean",
		sqft = 25000,
		condition = "Pristine",
	},
}

local VehicleListings = {
	-- Budget
	{
		name = "Used Sedan",
		brand = "Honda Civic",
		price = 8500,
		emoji = "🚗",
		year = 2015,
		miles = 85000,
		condition = "Fair",
	},
	{
		name = "Economy Car",
		brand = "Toyota Corolla",
		price = 22000,
		emoji = "🚙",
		year = 2024,
		miles = 0,
		condition = "New",
	},
	-- Mid-range
	{
		name = "SUV",
		brand = "Ford Explorer",
		price = 45000,
		emoji = "🚙",
		year = 2024,
		miles = 0,
		condition = "New",
	},
	{
		name = "Electric Car",
		brand = "Tesla Model 3",
		price = 52000,
		emoji = "⚡",
		year = 2024,
		miles = 0,
		condition = "New",
	},
	-- Luxury
	{
		name = "Luxury Sedan",
		brand = "BMW 7 Series",
		price = 95000,
		emoji = "🚘",
		year = 2024,
		miles = 0,
		condition = "New",
	},
	{
		name = "Sports Car",
		brand = "Porsche 911",
		price = 180000,
		emoji = "🏎️",
		year = 2024,
		miles = 0,
		condition = "New",
	},
	{
		name = "Supercar",
		brand = "Lamborghini Huracán",
		price = 320000,
		emoji = "🏎️",
		year = 2024,
		miles = 0,
		condition = "New",
	},
	{
		name = "Hypercar",
		brand = "Bugatti Chiron",
		price = 3200000,
		emoji = "🚀",
		year = 2024,
		miles = 0,
		condition = "New",
	},
	-- Other
	{
		name = "Motorcycle",
		brand = "Harley Davidson",
		price = 25000,
		emoji = "🏍️",
		year = 2024,
		miles = 0,
		condition = "New",
	},
	{
		name = "Yacht",
		brand = "Sunseeker 76",
		price = 2500000,
		emoji = "🛥️",
		year = 2023,
		condition = "Excellent",
	},
	{
		name = "Private Jet",
		brand = "Gulfstream G650",
		price = 65000000,
		emoji = "✈️",
		year = 2024,
		condition = "New",
	},
}

local ItemListings = {
	-- Electronics
	{
		name = "Smartphone",
		brand = "iPhone 15 Pro",
		price = 1200,
		emoji = "📱",
		category = "Electronics",
	},
	{
		name = "Gaming PC",
		brand = "Custom Build",
		price = 3500,
		emoji = "🖥️",
		category = "Electronics",
	},
	{
		name = "VR Headset",
		brand = "Meta Quest Pro",
		price = 1000,
		emoji = "🥽",
		category = "Electronics",
	},
	-- Luxury
	{
		name = "Designer Watch",
		brand = "Rolex Submariner",
		price = 15000,
		emoji = "⌚",
		category = "Luxury",
	},
	{
		name = "Diamond Ring",
		brand = "Tiffany & Co",
		price = 25000,
		emoji = "💍",
		category = "Luxury",
	},
	{
		name = "Designer Handbag",
		brand = "Hermès Birkin",
		price = 45000,
		emoji = "👜",
		category = "Luxury",
	},
	-- Collectibles
	{
		name = "Art Painting",
		brand = "Contemporary Art",
		price = 50000,
		emoji = "🖼️",
		category = "Collectibles",
	},
	{
		name = "Rare Wine Collection",
		brand = "Vintage Bordeaux",
		price = 35000,
		emoji = "🍷",
		category = "Collectibles",
	},
	-- Crypto
	{
		name = "Bitcoin",
		brand = "BTC",
		price = 0, -- Market price
		emoji = "₿",
		category = "Crypto",
		volatile = true,
	},
	{
		name = "Ethereum",
		brand = "ETH",
		price = 0,
		emoji = "Ξ",
		category = "Crypto",
		volatile = true,
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
	if amount >= 1000000000 then
		return string.format("$%.1fB", amount / 1000000000)
	elseif amount >= 1000000 then
		return string.format("$%.1fM", amount / 1000000)
	elseif amount >= 1000 then
		return string.format("$%.0fK", amount / 1000)
	else
		return "$" .. tostring(amount)
	end
end

----------------------------------------------------------------
-- SCREEN CREATION
----------------------------------------------------------------

function AssetsScreen.new(screenGui, blurOverlay, showBlurFunc, hideBlurFunc, playerState)
	local self = setmetatable({}, AssetsScreen)
	
	self.screenGui = screenGui
	self.blurOverlay = blurOverlay
	self.showBlur = showBlurFunc
	self.hideBlur = hideBlurFunc
	self.playerState = playerState
	self.isVisible = false
	
	-- Player's owned assets
	self.ownedProperties = {}
	self.ownedVehicles = {}
	self.ownedItems = {}
	
	self:createUI()
	
	return self
end

function AssetsScreen:createUI()
	-- Main overlay container
	self.overlay = Instance.new("Frame")
	self.overlay.Name = "AssetsOverlay"
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
	header.BackgroundColor3 = Colors.PropertyGreen
	header.BorderSizePixel = 0
	header.ZIndex = 85
	header.Parent = self.overlay
	
	local headerGrad = Instance.new("UIGradient")
	headerGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Colors.PropertyGreen),
		ColorSequenceKeypoint.new(1, Colors.PropertyGreenDark),
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
	titleLabel.Text = "🏠 Assets"
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
	self:createNetWorthSection()
	self:createOwnedAssetsSection()
	self:createPropertyMarketSection()
	self:createVehicleMarketSection()
	self:createItemsSection()
end

function AssetsScreen:createSectionHeader(parent, title, emoji, color, layoutOrder)
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

function AssetsScreen:createNetWorthSection()
	-- Net worth card at top
	local netWorthCard = Instance.new("Frame")
	netWorthCard.Name = "NetWorthCard"
	netWorthCard.Size = UDim2.new(1, 0, 0, 110)
	netWorthCard.BackgroundColor3 = Colors.CardWhite
	netWorthCard.LayoutOrder = 0
	netWorthCard.Parent = self.contentScroll
	createUICorner(netWorthCard, 16)
	createUIStroke(netWorthCard, 2, 0, Colors.NetWorthGreen)
	
	local cardPadding = createUIPadding(netWorthCard, 20, 20, 16, 16)
	
	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0, 20)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Fonts.BodyMedium
	titleLabel.TextSize = 14
	titleLabel.TextColor3 = Colors.MediumGray
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = "💰 Total Net Worth"
	titleLabel.Parent = netWorthCard
	
	-- Amount
	self.netWorthLabel = Instance.new("TextLabel")
	self.netWorthLabel.Size = UDim2.new(1, 0, 0, 40)
	self.netWorthLabel.Position = UDim2.new(0, 0, 0, 24)
	self.netWorthLabel.BackgroundTransparency = 1
	self.netWorthLabel.Font = Fonts.Title
	self.netWorthLabel.TextSize = 32
	self.netWorthLabel.TextColor3 = Colors.NetWorthGreen
	self.netWorthLabel.TextXAlignment = Enum.TextXAlignment.Left
	self.netWorthLabel.Text = "$0"
	self.netWorthLabel.Parent = netWorthCard
	
	-- Breakdown
	local breakdownLabel = Instance.new("TextLabel")
	breakdownLabel.Size = UDim2.new(1, 0, 0, 18)
	breakdownLabel.Position = UDim2.new(0, 0, 0, 68)
	breakdownLabel.BackgroundTransparency = 1
	breakdownLabel.Font = Fonts.Body
	breakdownLabel.TextSize = 12
	breakdownLabel.TextColor3 = Colors.DarkGray
	breakdownLabel.TextXAlignment = Enum.TextXAlignment.Left
	breakdownLabel.Text = "🏠 Properties: $0  •  🚗 Vehicles: $0  •  📦 Items: $0"
	breakdownLabel.Parent = netWorthCard
	
	self.breakdownLabel = breakdownLabel
end

function AssetsScreen:createOwnedAssetsSection()
	local section, layout = self:createSectionHeader(
		self.contentScroll,
		"My Assets",
		"📋",
		Colors.BitLifeBlue,
		1
	)
	
	-- Empty state card
	local emptyCard = Instance.new("Frame")
	emptyCard.Name = "EmptyCard"
	emptyCard.Size = UDim2.new(1, 0, 0, 80)
	emptyCard.BackgroundColor3 = Colors.CardWhite
	emptyCard.LayoutOrder = 2
	emptyCard.Parent = section
	createUICorner(emptyCard, 14)
	createUIStroke(emptyCard, 1, 0.8, Colors.LightGray)
	
	local emptyLabel = Instance.new("TextLabel")
	emptyLabel.Size = UDim2.fromScale(1, 1)
	emptyLabel.BackgroundTransparency = 1
	emptyLabel.Font = Fonts.BodyMedium
	emptyLabel.TextSize = 14
	emptyLabel.TextColor3 = Colors.MediumGray
	emptyLabel.Text = "📭 You don't own any assets yet.\nBrowse the market below!"
	emptyLabel.TextWrapped = true
	emptyLabel.Parent = emptyCard
	
	self.ownedAssetsSection = section
	self.emptyAssetsCard = emptyCard
end

function AssetsScreen:createPropertyMarketSection()
	local section, layout = self:createSectionHeader(
		self.contentScroll,
		"Property Market",
		"🏘️",
		Colors.PropertyGreen,
		2
	)
	
	for i, property in ipairs(PropertyListings) do
		local card = self:createPropertyCard(property, i + 1)
		card.Parent = section
	end
end

function AssetsScreen:createPropertyCard(property, layoutOrder)
	local card = Instance.new("Frame")
	card.Name = "Property_" .. property.name:gsub(" ", "_")
	card.Size = UDim2.new(1, 0, 0, 100)
	card.BackgroundColor3 = Colors.CardWhite
	card.LayoutOrder = layoutOrder
	createUICorner(card, 14)
	createUIStroke(card, 1, 0.85, Color3.fromRGB(229, 231, 235))
	
	-- Emoji circle
	local emojiCircle = Instance.new("Frame")
	emojiCircle.Size = UDim2.new(0, 54, 0, 54)
	emojiCircle.Position = UDim2.new(0, 14, 0.5, -27)
	emojiCircle.BackgroundColor3 = Color3.fromRGB(236, 253, 245)
	emojiCircle.Parent = card
	createUICorner(emojiCircle, 27)
	
	local emojiLabel = Instance.new("TextLabel")
	emojiLabel.Size = UDim2.fromScale(1, 1)
	emojiLabel.BackgroundTransparency = 1
	emojiLabel.Font = Fonts.Body
	emojiLabel.TextSize = 28
	emojiLabel.Text = property.emoji
	emojiLabel.Parent = emojiCircle
	
	-- Info
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.5, 0, 0, 20)
	nameLabel.Position = UDim2.new(0, 78, 0, 12)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Fonts.Title
	nameLabel.TextSize = 15
	nameLabel.TextColor3 = Colors.TextBlack
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = property.name
	nameLabel.Parent = card
	
	local locationLabel = Instance.new("TextLabel")
	locationLabel.Size = UDim2.new(0.5, 0, 0, 16)
	locationLabel.Position = UDim2.new(0, 78, 0, 32)
	locationLabel.BackgroundTransparency = 1
	locationLabel.Font = Fonts.Body
	locationLabel.TextSize = 12
	locationLabel.TextColor3 = Colors.MediumGray
	locationLabel.TextXAlignment = Enum.TextXAlignment.Left
	locationLabel.Text = "📍 " .. property.location
	locationLabel.Parent = card
	
	local detailsLabel = Instance.new("TextLabel")
	detailsLabel.Size = UDim2.new(0.5, 0, 0, 16)
	detailsLabel.Position = UDim2.new(0, 78, 0, 50)
	detailsLabel.BackgroundTransparency = 1
	detailsLabel.Font = Fonts.Body
	detailsLabel.TextSize = 11
	detailsLabel.TextColor3 = Colors.DarkGray
	detailsLabel.TextXAlignment = Enum.TextXAlignment.Left
	detailsLabel.Text = string.format("📐 %s sqft • %s", tostring(property.sqft), property.condition)
	detailsLabel.Parent = card
	
	local priceLabel = Instance.new("TextLabel")
	priceLabel.Size = UDim2.new(0.5, 0, 0, 20)
	priceLabel.Position = UDim2.new(0, 78, 0, 70)
	priceLabel.BackgroundTransparency = 1
	priceLabel.Font = Fonts.Title
	priceLabel.TextSize = 16
	priceLabel.TextColor3 = Colors.PropertyGreen
	priceLabel.TextXAlignment = Enum.TextXAlignment.Left
	priceLabel.Text = formatMoney(property.price)
	priceLabel.Parent = card
	
	-- Buy button
	local buyBtn = Instance.new("TextButton")
	buyBtn.Name = "BuyBtn"
	buyBtn.Size = UDim2.new(0, 70, 0, 36)
	buyBtn.AnchorPoint = Vector2.new(1, 0.5)
	buyBtn.Position = UDim2.new(1, -14, 0.5, 0)
	buyBtn.BackgroundColor3 = Colors.PropertyGreen
	buyBtn.Font = Fonts.Button
	buyBtn.TextSize = 13
	buyBtn.TextColor3 = Colors.White
	buyBtn.Text = "Buy"
	buyBtn.AutoButtonColor = false
	buyBtn.Parent = card
	createPillCorner(buyBtn)
	
	buyBtn.MouseEnter:Connect(function()
		tween(buyBtn, TweenInfo.new(0.15), { BackgroundColor3 = Colors.PropertyGreenDark })
	end)
	buyBtn.MouseLeave:Connect(function()
		tween(buyBtn, TweenInfo.new(0.15), { BackgroundColor3 = Colors.PropertyGreen })
	end)
	
	return card
end

function AssetsScreen:createVehicleMarketSection()
	local section, layout = self:createSectionHeader(
		self.contentScroll,
		"Vehicle Dealership",
		"🚗",
		Colors.VehicleBlue,
		3
	)
	
	for i, vehicle in ipairs(VehicleListings) do
		local card = self:createVehicleCard(vehicle, i + 1)
		card.Parent = section
	end
end

function AssetsScreen:createVehicleCard(vehicle, layoutOrder)
	local card = Instance.new("Frame")
	card.Name = "Vehicle_" .. vehicle.name:gsub(" ", "_")
	card.Size = UDim2.new(1, 0, 0, 90)
	card.BackgroundColor3 = Colors.CardWhite
	card.LayoutOrder = layoutOrder
	createUICorner(card, 14)
	createUIStroke(card, 1, 0.85, Color3.fromRGB(229, 231, 235))
	
	-- Emoji circle
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
	emojiLabel.Text = vehicle.emoji
	emojiLabel.Parent = emojiCircle
	
	-- Info
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.5, 0, 0, 20)
	nameLabel.Position = UDim2.new(0, 74, 0, 14)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Fonts.Title
	nameLabel.TextSize = 14
	nameLabel.TextColor3 = Colors.TextBlack
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = vehicle.brand
	nameLabel.Parent = card
	
	local yearLabel = Instance.new("TextLabel")
	yearLabel.Size = UDim2.new(0.5, 0, 0, 16)
	yearLabel.Position = UDim2.new(0, 74, 0, 34)
	yearLabel.BackgroundTransparency = 1
	yearLabel.Font = Fonts.Body
	yearLabel.TextSize = 12
	yearLabel.TextColor3 = Colors.MediumGray
	yearLabel.TextXAlignment = Enum.TextXAlignment.Left
	yearLabel.Text = string.format("📅 %d • %s", vehicle.year, vehicle.condition)
	yearLabel.Parent = card
	
	local priceLabel = Instance.new("TextLabel")
	priceLabel.Size = UDim2.new(0.5, 0, 0, 18)
	priceLabel.Position = UDim2.new(0, 74, 0, 54)
	priceLabel.BackgroundTransparency = 1
	priceLabel.Font = Fonts.Title
	priceLabel.TextSize = 15
	priceLabel.TextColor3 = Colors.VehicleBlue
	priceLabel.TextXAlignment = Enum.TextXAlignment.Left
	priceLabel.Text = formatMoney(vehicle.price)
	priceLabel.Parent = card
	
	-- Buy button
	local buyBtn = Instance.new("TextButton")
	buyBtn.Size = UDim2.new(0, 70, 0, 34)
	buyBtn.AnchorPoint = Vector2.new(1, 0.5)
	buyBtn.Position = UDim2.new(1, -14, 0.5, 0)
	buyBtn.BackgroundColor3 = Colors.VehicleBlue
	buyBtn.Font = Fonts.Button
	buyBtn.TextSize = 13
	buyBtn.TextColor3 = Colors.White
	buyBtn.Text = "Buy"
	buyBtn.AutoButtonColor = false
	buyBtn.Parent = card
	createPillCorner(buyBtn)
	
	buyBtn.MouseEnter:Connect(function()
		tween(buyBtn, TweenInfo.new(0.15), { BackgroundColor3 = Colors.VehicleBlueDark })
	end)
	buyBtn.MouseLeave:Connect(function()
		tween(buyBtn, TweenInfo.new(0.15), { BackgroundColor3 = Colors.VehicleBlue })
	end)
	
	return card
end

function AssetsScreen:createItemsSection()
	local section, layout = self:createSectionHeader(
		self.contentScroll,
		"Shopping",
		"🛍️",
		Colors.ItemsOrange,
		4
	)
	
	for i, item in ipairs(ItemListings) do
		local card = self:createItemCard(item, i + 1)
		card.Parent = section
	end
end

function AssetsScreen:createItemCard(item, layoutOrder)
	local card = Instance.new("Frame")
	card.Name = "Item_" .. item.name:gsub(" ", "_")
	card.Size = UDim2.new(1, 0, 0, 75)
	card.BackgroundColor3 = Colors.CardWhite
	card.LayoutOrder = layoutOrder
	createUICorner(card, 14)
	createUIStroke(card, 1, 0.85, Color3.fromRGB(229, 231, 235))
	
	-- Emoji circle
	local bgColor = item.category == "Luxury" and Color3.fromRGB(250, 245, 255) or
	                item.category == "Crypto" and Color3.fromRGB(254, 252, 232) or
	                Color3.fromRGB(255, 251, 235)
	
	local emojiCircle = Instance.new("Frame")
	emojiCircle.Size = UDim2.new(0, 44, 0, 44)
	emojiCircle.Position = UDim2.new(0, 14, 0.5, -22)
	emojiCircle.BackgroundColor3 = bgColor
	emojiCircle.Parent = card
	createUICorner(emojiCircle, 22)
	
	local emojiLabel = Instance.new("TextLabel")
	emojiLabel.Size = UDim2.fromScale(1, 1)
	emojiLabel.BackgroundTransparency = 1
	emojiLabel.Font = Fonts.Body
	emojiLabel.TextSize = 22
	emojiLabel.Text = item.emoji
	emojiLabel.Parent = emojiCircle
	
	-- Info
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.5, 0, 0, 18)
	nameLabel.Position = UDim2.new(0, 68, 0, 14)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Fonts.Title
	nameLabel.TextSize = 14
	nameLabel.TextColor3 = Colors.TextBlack
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = item.name
	nameLabel.Parent = card
	
	local brandLabel = Instance.new("TextLabel")
	brandLabel.Size = UDim2.new(0.5, 0, 0, 14)
	brandLabel.Position = UDim2.new(0, 68, 0, 32)
	brandLabel.BackgroundTransparency = 1
	brandLabel.Font = Fonts.Body
	brandLabel.TextSize = 11
	brandLabel.TextColor3 = Colors.MediumGray
	brandLabel.TextXAlignment = Enum.TextXAlignment.Left
	brandLabel.Text = item.brand
	brandLabel.Parent = card
	
	local priceColor = item.category == "Luxury" and Colors.LuxuryPurple or
	                   item.category == "Crypto" and Colors.CryptoGold or
	                   Colors.ItemsOrange
	
	local priceLabel = Instance.new("TextLabel")
	priceLabel.Size = UDim2.new(0.5, 0, 0, 16)
	priceLabel.Position = UDim2.new(0, 68, 0, 48)
	priceLabel.BackgroundTransparency = 1
	priceLabel.Font = Fonts.Title
	priceLabel.TextSize = 14
	priceLabel.TextColor3 = priceColor
	priceLabel.TextXAlignment = Enum.TextXAlignment.Left
	priceLabel.Text = item.volatile and "Market Price" or formatMoney(item.price)
	priceLabel.Parent = card
	
	-- Buy button
	local buyBtn = Instance.new("TextButton")
	buyBtn.Size = UDim2.new(0, 65, 0, 32)
	buyBtn.AnchorPoint = Vector2.new(1, 0.5)
	buyBtn.Position = UDim2.new(1, -14, 0.5, 0)
	buyBtn.BackgroundColor3 = priceColor
	buyBtn.Font = Fonts.Button
	buyBtn.TextSize = 12
	buyBtn.TextColor3 = Colors.White
	buyBtn.Text = item.volatile and "Invest" or "Buy"
	buyBtn.AutoButtonColor = false
	buyBtn.Parent = card
	createPillCorner(buyBtn)
	
	return card
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
	
	local t = tween(self.overlay, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		Position = UDim2.new(1, 0, 0, 0)
	})
	
	t.Completed:Connect(function()
		self.overlay.Visible = false
	end)
end

function AssetsScreen:toggle()
	if self.isVisible then
		self:hide()
	else
		self:show()
	end
end

return AssetsScreen
