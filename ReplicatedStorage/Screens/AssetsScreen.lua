-- AssetsScreen.lua
-- BitLife-style Assets screen with SERVER VALIDATION
-- Uses remotes - no more broke babies buying mansions!

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AssetsScreen = {}
AssetsScreen.__index = AssetsScreen

----------------------------------------------------------------
-- REMOTES
----------------------------------------------------------------

local remotesFolder = ReplicatedStorage:WaitForChild("LifeRemotes", 10)
local BuyProperty = remotesFolder and remotesFolder:FindFirstChild("BuyProperty")
local BuyVehicle = remotesFolder and remotesFolder:FindFirstChild("BuyVehicle")
local BuyItem = remotesFolder and remotesFolder:FindFirstChild("BuyItem")
local BuyCrypto = remotesFolder and remotesFolder:FindFirstChild("BuyCrypto")

----------------------------------------------------------------
-- COLORS
----------------------------------------------------------------

local Colors = {
	BitLifeBlue      = Color3.fromRGB(37, 99, 235),
	AssetsGreen      = Color3.fromRGB(16, 185, 129),
	AssetsGreenDark  = Color3.fromRGB(5, 150, 105),
	PropertyBlue     = Color3.fromRGB(59, 130, 246),
	VehicleOrange    = Color3.fromRGB(249, 115, 22),
	ShoppingPink     = Color3.fromRGB(236, 72, 153),
	CryptoYellow     = Color3.fromRGB(234, 179, 8),
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

local Properties = {
	{ id = "studio", name = "Studio Apartment", emoji = "🏢", price = 85000, minAge = 18, bedrooms = 0, location = "Downtown" },
	{ id = "1br_condo", name = "1BR Condo", emoji = "🏠", price = 175000, minAge = 18, bedrooms = 1, location = "Suburbs" },
	{ id = "family_house", name = "Family House", emoji = "🏡", price = 350000, minAge = 18, bedrooms = 3, location = "Suburbs" },
	{ id = "penthouse", name = "Luxury Penthouse", emoji = "🏙️", price = 2500000, minAge = 21, bedrooms = 4, location = "Downtown" },
	{ id = "beach_house", name = "Beach House", emoji = "🏖️", price = 1200000, minAge = 21, bedrooms = 3, location = "Beachfront" },
	{ id = "mansion", name = "Mansion", emoji = "🏰", price = 8500000, minAge = 21, bedrooms = 8, location = "Hills" },
}

local Vehicles = {
	{ id = "used_civic", name = "Used Honda Civic", emoji = "🚗", price = 8000, minAge = 16 },
	{ id = "camry", name = "Toyota Camry", emoji = "🚙", price = 28000, minAge = 16 },
	{ id = "bmw", name = "BMW 3 Series", emoji = "🚘", price = 55000, minAge = 18 },
	{ id = "tesla", name = "Tesla Model S", emoji = "⚡", price = 95000, minAge = 18 },
	{ id = "porsche", name = "Porsche 911", emoji = "🏎️", price = 180000, minAge = 21 },
	{ id = "lambo", name = "Lamborghini", emoji = "🐂", price = 280000, minAge = 21 },
	{ id = "yacht", name = "Yacht", emoji = "🛥️", price = 2000000, minAge = 25 },
	{ id = "jet", name = "Private Jet", emoji = "✈️", price = 15000000, minAge = 25 },
}

local ShopItems = {
	{ id = "sneakers", name = "Sneakers", emoji = "👟", price = 350, minAge = 10, category = "Fashion" },
	{ id = "iphone", name = "iPhone", emoji = "📱", price = 1200, minAge = 10, category = "Electronics" },
	{ id = "gaming_pc", name = "Gaming PC", emoji = "🖥️", price = 3000, minAge = 10, category = "Electronics" },
	{ id = "bag", name = "Designer Bag", emoji = "👜", price = 2500, minAge = 14, category = "Fashion" },
	{ id = "watch", name = "Designer Watch", emoji = "⌚", price = 5000, minAge = 16, category = "Jewelry" },
	{ id = "necklace", name = "Gold Necklace", emoji = "📿", price = 3500, minAge = 16, category = "Jewelry" },
	{ id = "ring", name = "Diamond Ring", emoji = "💍", price = 15000, minAge = 18, category = "Jewelry" },
	{ id = "piano", name = "Grand Piano", emoji = "🎹", price = 50000, minAge = 18, category = "Music" },
}

local Crypto = {
	{ id = "btc", name = "Bitcoin", emoji = "₿", price = 67500, symbol = "BTC", minAge = 18 },
	{ id = "eth", name = "Ethereum", emoji = "Ξ", price = 3800, symbol = "ETH", minAge = 18 },
	{ id = "doge", name = "Dogecoin", emoji = "🐕", price = 0.12, symbol = "DOGE", minAge = 18 },
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

local function formatPrice(amount)
	if amount >= 1000000 then return string.format("$%.1fM", amount / 1000000) end
	if amount >= 1000 then return string.format("$%.0fK", amount / 1000) end
	return "$" .. amount
end

----------------------------------------------------------------
-- SCREEN
----------------------------------------------------------------

function AssetsScreen.new(screenGui, blurOverlay, showBlurFunc, hideBlurFunc, playerState)
	local self = setmetatable({}, AssetsScreen)
	
	self.screenGui = screenGui
	self.playerState = playerState
	self.isVisible = false
	
	self:createUI()
	self:createConfirmModal()
	self:createResultModal()
	
	return self
end

function AssetsScreen:getPlayerAge()
	return self.playerState and self.playerState.Age or 0
end

function AssetsScreen:getPlayerMoney()
	return self.playerState and self.playerState.Money or 0
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
	
	-- Info bar
	local infoBar = Instance.new("Frame")
	infoBar.Size = UDim2.new(1, -32, 0, 50)
	infoBar.Position = UDim2.new(0, 16, 0, 70)
	infoBar.BackgroundColor3 = Colors.CardWhite
	infoBar.ZIndex = 82
	infoBar.Parent = self.overlay
	createUICorner(infoBar, 12)
	createUIStroke(infoBar, 1, 0.8, Colors.AssetsGreen)
	
	self.infoLabel = Instance.new("TextLabel")
	self.infoLabel.Size = UDim2.fromScale(1, 1)
	self.infoLabel.BackgroundTransparency = 1
	self.infoLabel.Font = Fonts.BodyMedium
	self.infoLabel.TextSize = 14
	self.infoLabel.TextColor3 = Colors.AssetsGreen
	self.infoLabel.Text = "💵 Cash: $0 | 📅 Age: 0"
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
	
	self:createPropertySection(1)
	self:createVehicleSection(2)
	self:createShoppingSection(3)
	self:createCryptoSection(4)
end

function AssetsScreen:updateInfoBar()
	local age = self:getPlayerAge()
	local money = self:getPlayerMoney()
	self.infoLabel.Text = "💵 Cash: " .. formatPrice(money) .. " | 📅 Age: " .. age
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
		self:createAssetCard(prop, "property", Colors.PropertyBlue, i + 1, section)
	end
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
		self:createAssetCard(vehicle, "vehicle", Colors.VehicleOrange, i + 1, section)
	end
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
		self:createAssetCard(item, "item", Colors.ShoppingPink, i + 1, section)
	end
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
	headerText.Text = "🪙 Crypto (Age 18+)"
	headerText.Parent = headerFrame
	
	for i, crypto in ipairs(Crypto) do
		self:createAssetCard(crypto, "crypto", Colors.CryptoYellow, i + 1, section)
	end
end

function AssetsScreen:createAssetCard(item, assetType, color, order, parent)
	local card = Instance.new("Frame")
	card.Name = assetType .. "_" .. item.id
	card.Size = UDim2.new(1, 0, 0, 70)
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
	emoji.Text = item.emoji
	emoji.Parent = card
	
	local name = Instance.new("TextLabel")
	name.Size = UDim2.new(0.4, 0, 0, 18)
	name.Position = UDim2.new(0, 54, 0, 12)
	name.BackgroundTransparency = 1
	name.Font = Fonts.Title
	name.TextSize = 13
	name.TextColor3 = Colors.TextBlack
	name.TextXAlignment = Enum.TextXAlignment.Left
	name.Text = item.name
	name.Parent = card
	
	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(0.5, 0, 0, 14)
	info.Position = UDim2.new(0, 54, 0, 30)
	info.BackgroundTransparency = 1
	info.Font = Fonts.Body
	info.TextSize = 11
	info.TextColor3 = Colors.MediumGray
	info.TextXAlignment = Enum.TextXAlignment.Left
	info.Text = formatPrice(item.price) .. " | Age " .. item.minAge .. "+"
	info.Parent = card
	
	local buyBtn = Instance.new("TextButton")
	buyBtn.Size = UDim2.new(0, 50, 0, 28)
	buyBtn.AnchorPoint = Vector2.new(1, 0.5)
	buyBtn.Position = UDim2.new(1, -12, 0.5, 0)
	buyBtn.BackgroundColor3 = color
	buyBtn.Font = Fonts.Button
	buyBtn.TextSize = 11
	buyBtn.TextColor3 = assetType == "crypto" and Colors.TextBlack or Colors.White
	buyBtn.Text = "Buy"
	buyBtn.AutoButtonColor = false
	buyBtn.Parent = card
	createPillCorner(buyBtn)
	
	buyBtn.MouseButton1Click:Connect(function()
		self:showConfirm(assetType, item, color)
	end)
end

function AssetsScreen:createConfirmModal()
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
	self.confirmEmoji.Text = "🏠"
	self.confirmEmoji.LayoutOrder = 1
	self.confirmEmoji.Parent = self.confirmModal
	
	self.confirmTitle = Instance.new("TextLabel")
	self.confirmTitle.Size = UDim2.new(1, 0, 0, 24)
	self.confirmTitle.BackgroundTransparency = 1
	self.confirmTitle.Font = Fonts.Title
	self.confirmTitle.TextSize = 18
	self.confirmTitle.TextColor3 = Colors.TextBlack
	self.confirmTitle.Text = "Buy Item?"
	self.confirmTitle.LayoutOrder = 2
	self.confirmTitle.Parent = self.confirmModal
	
	self.confirmPrice = Instance.new("TextLabel")
	self.confirmPrice.Size = UDim2.new(1, 0, 0, 28)
	self.confirmPrice.BackgroundTransparency = 1
	self.confirmPrice.Font = Fonts.Title
	self.confirmPrice.TextSize = 22
	self.confirmPrice.TextColor3 = Colors.SuccessGreen
	self.confirmPrice.Text = "$0"
	self.confirmPrice.LayoutOrder = 3
	self.confirmPrice.Parent = self.confirmModal
	
	self.confirmInfo = Instance.new("TextLabel")
	self.confirmInfo.Size = UDim2.new(1, 0, 0, 18)
	self.confirmInfo.BackgroundTransparency = 1
	self.confirmInfo.Font = Fonts.Body
	self.confirmInfo.TextSize = 12
	self.confirmInfo.TextColor3 = Colors.MediumGray
	self.confirmInfo.Text = "Your cash: $0"
	self.confirmInfo.LayoutOrder = 4
	self.confirmInfo.Parent = self.confirmModal
	
	local btnContainer = Instance.new("Frame")
	btnContainer.Size = UDim2.new(1, 0, 0, 44)
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
	cancelBtn.TextSize = 14
	cancelBtn.TextColor3 = Colors.DarkGray
	cancelBtn.Text = "Cancel"
	cancelBtn.AutoButtonColor = false
	cancelBtn.Parent = btnContainer
	createPillCorner(cancelBtn)
	cancelBtn.MouseButton1Click:Connect(function() self:hideConfirm() end)
	
	self.confirmBtn = Instance.new("TextButton")
	self.confirmBtn.Size = UDim2.new(0.45, 0, 1, 0)
	self.confirmBtn.BackgroundColor3 = Colors.SuccessGreen
	self.confirmBtn.Font = Fonts.Button
	self.confirmBtn.TextSize = 14
	self.confirmBtn.TextColor3 = Colors.White
	self.confirmBtn.Text = "Buy!"
	self.confirmBtn.AutoButtonColor = false
	self.confirmBtn.Parent = btnContainer
	createPillCorner(self.confirmBtn)
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
	okBtn.Text = "Awesome!"
	okBtn.AutoButtonColor = false
	okBtn.LayoutOrder = 4
	okBtn.Parent = self.resultModal
	createPillCorner(okBtn)
	okBtn.MouseButton1Click:Connect(function() self:hideResult() end)
end

function AssetsScreen:showConfirm(assetType, item, color)
	self.currentType = assetType
	self.currentItem = item
	
	local age = self:getPlayerAge()
	local money = self:getPlayerMoney()
	local canAfford = money >= item.price
	local oldEnough = age >= item.minAge
	
	self.confirmEmoji.Text = item.emoji
	self.confirmTitle.Text = "Buy " .. item.name .. "?"
	self.confirmPrice.Text = formatPrice(item.price)
	self.confirmInfo.Text = "Your cash: " .. formatPrice(money) .. " | Age: " .. age
	self.confirmInfo.TextColor3 = (canAfford and oldEnough) and Colors.MediumGray or Colors.ErrorRed
	
	self.confirmBtn.BackgroundColor3 = (canAfford and oldEnough) and color or Colors.MediumGray
	
	if not oldEnough then
		self.confirmBtn.Text = "Age " .. item.minAge .. "+"
	elseif not canAfford then
		self.confirmBtn.Text = "Can't Afford"
	else
		self.confirmBtn.Text = "Buy!"
	end
	
	if self.confirmConn then self.confirmConn:Disconnect() end
	self.confirmConn = self.confirmBtn.MouseButton1Click:Connect(function()
		if canAfford and oldEnough then
			self:hideConfirm()
			task.delay(0.2, function()
				self:executePurchase()
			end)
		end
	end)
	
	self.confirmOverlay.Visible = true
	tween(self.confirmModal, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.fromScale(0.5, 0.5) })
end

function AssetsScreen:hideConfirm()
	self.confirmOverlay.Visible = false
end

function AssetsScreen:executePurchase()
	local result
	local remote
	
	if self.currentType == "property" then remote = BuyProperty
	elseif self.currentType == "vehicle" then remote = BuyVehicle
	elseif self.currentType == "item" then remote = BuyItem
	elseif self.currentType == "crypto" then remote = BuyCrypto
	end
	
	if remote then
		result = remote:InvokeServer(self.currentItem.id)
	else
		result = { success = false, message = "Server not available" }
	end
	
	self:showResult(result)
end

function AssetsScreen:showResult(result)
	self.resultEmoji.Text = result.success and "🎉" or "❌"
	self.resultTitle.Text = result.success and "Purchase Complete!" or "Failed"
	self.resultTitle.TextColor3 = result.success and Colors.SuccessGreen or Colors.ErrorRed
	self.resultText.Text = result.message or ""
	
	self.resultOverlay.Visible = true
	tween(self.resultModal, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.fromScale(0.5, 0.5) })
	
	self:updateInfoBar()
end

function AssetsScreen:hideResult()
	self.resultOverlay.Visible = false
end

function AssetsScreen:show()
	if self.isVisible then return end
	self.isVisible = true
	self:updateInfoBar()
	self.overlay.Visible = true
	self.overlay.Position = UDim2.new(1, 0, 0, 0)
	tween(self.overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.new(0, 0, 0, 0) })
end

function AssetsScreen:hide()
	if not self.isVisible then return end
	self.isVisible = false
	self.confirmOverlay.Visible = false
	self.resultOverlay.Visible = false
	local t = tween(self.overlay, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Position = UDim2.new(1, 0, 0, 0) })
	t.Completed:Connect(function() self.overlay.Visible = false end)
end

function AssetsScreen:toggle()
	if self.isVisible then self:hide() else self:show() end
end

return AssetsScreen
