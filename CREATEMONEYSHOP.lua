--[[
    SANRIO SHOP CLIENT (REVAMPED & FIXED v3)
    Place in: StarterPlayer > StarterPlayerScripts
    Name: CREATEMONEYSHOP

    • ROBUST LAYOUT: Replaced fragile manual positioning with UIListLayout to prevent stacking.
    • VISIBILITY FIX: Adjusted sizing logic to ensure elements are always visible and sized correctly on all devices.
    • "JUICY" UI: Bouncy animations, clean gradients, and high-polish aesthetic.
    • ASSET: Uses "rbxassetid://83301831904885" as requested.
]]

--// SERVICES
local Players            = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")
local GuiService         = game:GetService("GuiService")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local SoundService       = game:GetService("SoundService")
local Lighting           = game:GetService("Lighting")
local RunService         = game:GetService("RunService")

local Player    = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Remotes   = ReplicatedStorage:FindFirstChild("TycoonRemotes")

-- ======== ASSETS ========
local IMG_FRAME           = "rbxassetid://83301831904885"
local IMG_GAMEPASSES      = "rbxassetid://137846629770171"
local IMG_CASH            = "rbxassetid://84262748186110"
local GIFT_BOX_TEXTURE_ID = "130623477775352"

-- ======== THEME ========
local theme = {
	accent      = Color3.fromRGB(255, 105, 180), -- Hot Pink
	success     = Color3.fromRGB(96, 210, 100),
	cinna       = Color3.fromRGB(200, 230, 255),
	kuromi      = Color3.fromRGB(210, 200, 255),
	cardTop     = Color3.fromRGB(255, 250, 255),
	cardBot     = Color3.fromRGB(240, 235, 255),
	cardInner   = Color3.fromRGB(255, 255, 255),
	cardStroke  = Color3.fromRGB(220, 210, 250),
	shadow      = Color3.fromRGB(60, 40, 100),
	textDark    = Color3.fromRGB(75, 45, 110),
	textSubtle  = Color3.fromRGB(110, 90, 150),
	white       = Color3.fromRGB(255, 255, 255),
}

-- ======== UTILS ========
local function isMobile()
	return UserInputService.TouchEnabled and not GuiService:IsTenFootInterface()
end

local function deviceKind()
	if isMobile() then
		if workspace.CurrentCamera.ViewportSize.X < 700 then return "phone" end
		return "tablet"
	end
	return "desktop"
end

-- ======== CACHE ========
local Cache = {}
Cache.__index = Cache
function Cache.new(d) return setmetatable({data = {}, duration = d or 300}, Cache) end
function Cache:set(k,v) self.data[k] = {v = v, t = tick()} end
function Cache:get(k)
	local e = self.data[k]
	if not e then return end
	if tick() - e.t > self.duration then self.data[k] = nil return end
	return e.v
end
function Cache:clear(k) if k then self.data[k] = nil else self.data = {} end end

local productCache    = Cache.new(300)
local ownershipCache  = Cache.new(60)

-- ======== PRODUCTS ========
local products = {
	cash = {
		{ id = 3366419712, amount = 1000,    name = "1,000 Cash",     description = "Perfect starter pack",           icon = "rbxassetid://10709728059", price = 0 },
		{ id = 3366420012, amount = 5000,    name = "5,000 Cash",     description = "Great for early upgrades",       icon = "rbxassetid://10709728059", price = 0 },
		{ id = 3366420478, amount = 10000,   name = "10,000 Cash",    description = "Boost your progress fast",       icon = "rbxassetid://10709728059", price = 0, bonus = 0.10 },
		{ id = 3366420800, amount = 25000,   name = "25,000 Cash",    description = "Popular choice for players",     icon = "rbxassetid://10709728059", price = 0 },
		{ id = 3424973374, amount = 50000,   name = "50,000 Cash",    description = "Major upgrade power",            icon = "rbxassetid://10709728059", price = 0, bonus = 0.25 },
		{ id = 3424974046, amount = 100000,  name = "100,000 Cash",   description = "Supercharge your tycoon",        icon = "rbxassetid://10709728059", price = 0 },
		{ id = 3424974161, amount = 250000,  name = "250,000 Cash",   description = "Mega bundle for big dreams",     icon = "rbxassetid://10709728059", price = 0 },
		{ id = 3424974327, amount = 500000,  name = "500,000 Cash",   description = "Ultimate fortune awaits",        icon = "rbxassetid://10709728059", price = 0 },
		{ id = 3424974402, amount = 1000000, name = "1,000,000 Cash", description = "Max out everything!",            icon = "rbxassetid://10709728059", price = 0, best = true, bonus = 0.35 },
	},
	gamepasses = {
		{ id = 1412171840, name = "Auto Collect", description = "Automatically collect all cash drops", icon = "rbxassetid://10709727148", price = 99,  hasToggle = true  },
		{ id = 1398974710, name = "2x Cash",      description = "Double all cash earned permanently",   icon = "rbxassetid://10709727148", price = 199, hasToggle = false },
	},
}

-- ======== HELPERS ========
local function getProductInfo(id)
	local c = productCache:get(id)
	if c then return c end
	local ok, info = pcall(function() return MarketplaceService:GetProductInfo(id, Enum.InfoType.Product) end)
	if ok and info then productCache:set(id, info) return info end
end

local function getGamePassInfo(id)
	local key = "pass_" .. id
	local c = productCache:get(key)
	if c then return c end
	local ok, info = pcall(function() return MarketplaceService:GetProductInfo(id, Enum.InfoType.GamePass) end)
	if ok and info then productCache:set(key, info) return info end
end

local function checkOwnership(passId)
	local key = ("%d_%d"):format(Player.UserId, passId)
	local cached = ownershipCache:get(key)
	if cached ~= nil then return cached end

	if Remotes then
		local rf = Remotes:FindFirstChild("CheckPassOwnership")
		if rf and rf:IsA("RemoteFunction") then
			local ok, owns = pcall(function() return rf:InvokeServer(passId) end)
			if ok then ownershipCache:set(key, owns) return owns end
		end
	end
	local ok, ownsFallback = pcall(function() return MarketplaceService:UserOwnsGamePassAsync(Player.UserId, passId) end)
	if ok then ownershipCache:set(key, ownsFallback) return ownsFallback end
	return false
end

local function refreshPrices()
	for _, p in ipairs(products.cash) do
		local info = getProductInfo(p.id)
		if info and info.PriceInRobux then p.price = info.PriceInRobux end
	end
	for _, gp in ipairs(products.gamepasses) do
		local info = getGamePassInfo(gp.id)
		if info and info.PriceInRobux then gp.price = info.PriceInRobux end
	end
end

local sounds = {}
local function initSound()
	local cfg = {
		click   = {"rbxassetid://876939830", 0.45},
		hover   = {"rbxassetid://10066936758", 0.2},
		open    = {"rbxassetid://452267918", 0.5},
		success = {"rbxassetid://876939830", 0.6},
	}
	for n, d in pairs(cfg) do
		local s = Instance.new("Sound")
		s.Name = "SS_" .. n
		s.SoundId = d[1]
		s.Volume = d[2]
		s.Parent = SoundService
		sounds[n] = s
	end
end
local function playSound(n) if sounds[n] then sounds[n]:Play() end end

local function hoverEffect(btn, scaleUp, scaleDown)
	if isMobile() then return end
	local s = btn:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	s.Parent = btn
	btn.MouseEnter:Connect(function()
		playSound("hover")
		TweenService:Create(s, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = scaleUp or 1.05}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(s, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()
	end)
	btn.MouseButton1Down:Connect(function()
		TweenService:Create(s, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = scaleDown or 0.95}):Play()
	end)
	btn.MouseButton1Up:Connect(function()
		TweenService:Create(s, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = scaleUp or 1.05}):Play()
	end)
end

local function pulse(frame)
	local s = frame:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	s.Parent = frame
	TweenService:Create(s, TweenInfo.new(0.1), {Scale = 1.06}):Play()
	task.delay(0.1, function()
		TweenService:Create(s, TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Scale = 1}):Play()
	end)
end

-- ======== UI BUILDERS ========
local function createJuicyButton(text, color, parent)
	local btn = Instance.new("TextButton")
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.BackgroundColor3 = color
	btn.BorderSizePixel = 0
	btn.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = btn

	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
		ColorSequenceKeypoint.new(1, Color3.new(0.9, 0.9, 0.9))
	})
	grad.Rotation = 90
	grad.Parent = btn

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 1, 0)
	label.Text = text
	label.Font = Enum.Font.FredokaOne
	label.TextColor3 = theme.white
	label.TextScaled = true
	label.Parent = btn

	local shadow = Instance.new("Frame")
	shadow.Name = "Bevel"
	shadow.BackgroundColor3 = Color3.new(0,0,0)
	shadow.BackgroundTransparency = 0.8
	shadow.Size = UDim2.new(1, 0, 0, 4)
	shadow.Position = UDim2.new(0, 0, 1, -4)
	shadow.BorderSizePixel = 0
	shadow.Parent = btn
	Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 10)

	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, 4)
	p.PaddingBottom = UDim.new(0, 6)
	p.PaddingLeft = UDim.new(0, 6)
	p.PaddingRight = UDim.new(0, 6)
	p.Parent = label

	local tsc = Instance.new("UITextSizeConstraint")
	tsc.MinTextSize = 12
	tsc.MaxTextSize = 18
	tsc.Parent = label

	hoverEffect(btn, 1.03, 0.96)
	return btn
end

local function buildCard(parent, product, reservedRows)
	reservedRows = reservedRows or 1
	local btnH = 34
	local gap = 8
	local reservedPx = (reservedRows * btnH) + math.max(0, reservedRows - 1) * gap + 8 + 16 -- 16 is padding

	local shadow = Instance.new("Frame")
	shadow.BackgroundColor3 = theme.shadow
	shadow.BackgroundTransparency = 0.9
	shadow.Size = UDim2.new(1, -16, 1, -reservedPx)
	shadow.Position = UDim2.fromOffset(8, 14)
	shadow.BorderSizePixel = 0
	shadow.ZIndex = 11
	shadow.Parent = parent
	Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 16)

	local card = Instance.new("Frame")
	card.BackgroundColor3 = theme.cardBot
	card.Size = UDim2.new(1, -16, 1, -reservedPx)
	card.Position = UDim2.fromOffset(8, 8)
	card.BorderSizePixel = 0
	card.ZIndex = 12
	card.Parent = parent
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 16)

	local stroke = Instance.new("UIStroke")
	stroke.Color = theme.cardStroke
	stroke.Thickness = 1.5
	stroke.Transparency = 0.1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = card

	local g = Instance.new("UIGradient")
	g.Rotation = 60
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, theme.cardTop),
		ColorSequenceKeypoint.new(1, theme.cardBot),
	})
	g.Parent = card

	local inner = Instance.new("Frame")
	inner.BackgroundColor3 = theme.cardInner
	inner.Size = UDim2.new(1, -8, 1, -8)
	inner.Position = UDim2.fromOffset(4, 4)
	inner.BorderSizePixel = 0
	inner.ZIndex = 13
	inner.Parent = card
	Instance.new("UICorner", inner).CornerRadius = UDim.new(0, 12)
	
	local isStroke = Instance.new("UIStroke")
	isStroke.Color = Color3.new(1, 1, 1)
	isStroke.Transparency = 0.6
	isStroke.Thickness = 1
	isStroke.Parent = inner

	local content = Instance.new("Frame")
	content.BackgroundTransparency = 1
	content.Size = UDim2.new(1, -12, 1, -12)
	content.Position = UDim2.fromOffset(6, 6)
	content.Parent = inner
	content.ZIndex = 14

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.Padding = UDim.new(0, 2)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = content

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, 0, 0, 26)
	title.Text = product.name
	title.Font = Enum.Font.FredokaOne
	title.TextColor3 = theme.textDark
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextScaled = true
	title.ZIndex = 15
	title.Parent = content
	local tsc = Instance.new("UITextSizeConstraint")
	tsc.MinTextSize = 12
	tsc.MaxTextSize = 22
	tsc.Parent = title

	local desc = Instance.new("TextLabel")
	desc.BackgroundTransparency = 1
	desc.Size = UDim2.new(1, 0, 0, 28)
	desc.Text = product.description or ""
	desc.Font = Enum.Font.FredokaOne
	desc.TextColor3 = theme.textSubtle
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.TextYAlignment = Enum.TextYAlignment.Top
	desc.TextWrapped = true
	desc.TextScaled = true
	desc.ZIndex = 15
	desc.Parent = content
	local dsc = Instance.new("UITextSizeConstraint")
	dsc.MinTextSize = 10
	dsc.MaxTextSize = 14
	dsc.Parent = desc

	return card
end

local function makeBottomRow(parentCell, orderFromBottom, text, color, active, extraPushPx)
	local btnH = 34
	local gap = 8
	local pad = 8
	local push = math.max(0, extraPushPx or 0)
	local base = (orderFromBottom * btnH) + (orderFromBottom - 1) * gap + pad

	local row = createJuicyButton(text, color, parentCell)
	row.Size = UDim2.new(1, -16, 0, btnH)
	row.Position = UDim2.new(0.5, 0, 1, -(base - push))
	row.AnchorPoint = Vector2.new(0.5, 1)
	row.ZIndex = 20
	
	if active == false then
		row.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
		row.AutoButtonColor = false
	else
		row.BackgroundColor3 = color
		row.AutoButtonColor = true
	end
	
	return row
end

-- ======== SHOP CLASS ========
local Shop = {}
Shop.__index = Shop

function Shop.new()
	return setmetatable({
		gui = nil, mainFrame = nil, closeBtn = nil,
		buttonBar = nil, cashContainer = nil, gpContainer = nil,
		cashBtn = nil, gpBtn = nil, contentFrame = nil,
		cashPage = nil, gpPage = nil,
		_cashScale = nil, _gpScale = nil,
		toggleButton = nil, blur = nil,
		isOpen = false, purchasePending = {},
	}, Shop)
end

function Shop:createToggleButton()
	local sg = Instance.new("ScreenGui")
	sg.Name = "SanrioShopToggle"
	sg.ResetOnSpawn = false
	sg.DisplayOrder = 999
	sg.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
	sg.Parent = PlayerGui

	local kind = deviceKind()
	local size = (kind == "phone") and UDim2.fromOffset(70, 70) or UDim2.fromOffset(90, 90)
	local pos = (kind == "phone") and UDim2.new(1, -16, 0, 76) or UDim2.new(1, -16, 0.5, -70)
	local anchor = (kind == "phone") and Vector2.new(1, 0) or Vector2.new(1, 0.5)

	self.toggleButton = Instance.new("TextButton")
	self.toggleButton.Size = size
	self.toggleButton.Position = pos
	self.toggleButton.AnchorPoint = anchor
	self.toggleButton.BackgroundColor3 = theme.white
	self.toggleButton.Text = ""
	self.toggleButton.Parent = sg
	Instance.new("UICorner", self.toggleButton).CornerRadius = UDim.new(0, 20)
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = theme.accent
	stroke.Thickness = 3
	stroke.Parent = self.toggleButton

	local img = Instance.new("ImageLabel")
	img.Image = "rbxassetid://" .. GIFT_BOX_TEXTURE_ID
	img.Size = UDim2.fromScale(0.7, 0.7)
	img.Position = UDim2.fromScale(0.5, 0.5)
	img.AnchorPoint = Vector2.new(0.5, 0.5)
	img.BackgroundTransparency = 1
	img.Parent = self.toggleButton

	hoverEffect(self.toggleButton, 1.1, 0.9)
	self.toggleButton.MouseButton1Click:Connect(function() self:toggle() end)
end

function Shop:createMainInterface()
	self.gui = Instance.new("ScreenGui")
	self.gui.Name = "SanrioShopMain"
	self.gui.ResetOnSpawn = false
	self.gui.DisplayOrder = 1000
	self.gui.Enabled = false
	self.gui.IgnoreGuiInset = false
	self.gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
	self.gui.Parent = PlayerGui

	self.blur = Lighting:FindFirstChild("SanrioShopBlur") or Instance.new("BlurEffect")
	self.blur.Name = "SanrioShopBlur"
	self.blur.Size = 0
	self.blur.Parent = Lighting

	local dim = Instance.new("Frame")
	dim.Size = UDim2.fromScale(1, 1)
	dim.BackgroundColor3 = Color3.fromRGB(20, 10, 40)
	dim.BackgroundTransparency = 0.45
	dim.Parent = self.gui

	self.mainFrame = Instance.new("ImageLabel")
	self.mainFrame.Name = "MainFrame"
	self.mainFrame.BackgroundTransparency = 1
	self.mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	self.mainFrame.Position = UDim2.fromScale(0.5, 0.5)
	self.mainFrame.Size = UDim2.fromScale(0.9, 0.9) -- Base size, adjusted by aspect ratio
	self.mainFrame.Image = IMG_FRAME
	self.mainFrame.ScaleType = Enum.ScaleType.Fit
	self.mainFrame.ZIndex = 1
	self.mainFrame.Parent = self.gui
	
	local aspect = Instance.new("UIAspectRatioConstraint")
	aspect.AspectRatio = 1.0
	aspect.DominantAxis = Enum.DominantAxis.Height -- Ensures it fits in height
	aspect.Parent = self.mainFrame

	-- CLOSE BUTTON
	self.closeBtn = Instance.new("TextButton")
	self.closeBtn.Name = "CloseButton"
	self.closeBtn.AnchorPoint = Vector2.new(1, 0)
	self.closeBtn.Size = UDim2.fromOffset(44, 44)
	self.closeBtn.Position = UDim2.new(1, -40, 0, 160) -- Default safe pos
	self.closeBtn.BackgroundColor3 = theme.white
	self.closeBtn.Text = "X"
	self.closeBtn.Font = Enum.Font.FredokaOne
	self.closeBtn.TextColor3 = theme.textDark
	self.closeBtn.TextSize = 24
	self.closeBtn.ZIndex = 50
	self.closeBtn.Parent = self.mainFrame
	Instance.new("UICorner", self.closeBtn).CornerRadius = UDim.new(1, 0)
	
	local cStroke = Instance.new("UIStroke")
	cStroke.Color = theme.cardStroke
	cStroke.Thickness = 2
	cStroke.Parent = self.closeBtn
	
	hoverEffect(self.closeBtn, 1.1, 0.9)
	self.closeBtn.MouseButton1Click:Connect(function()
		playSound("click")
		self:close()
	end)

	-- TAB CONTAINER (Replacing fragile manual positioning with ListLayout)
	self.buttonBar = Instance.new("Frame")
	self.buttonBar.Name = "ButtonBar"
	self.buttonBar.BackgroundTransparency = 1
	self.buttonBar.AnchorPoint = Vector2.new(0.5, 0)
	self.buttonBar.Position = UDim2.fromScale(0.5, 0.36) -- Fixed vertical position
	self.buttonBar.Size = UDim2.fromScale(0.9, 0.12) -- Takes up 90% width, 12% height
	self.buttonBar.ZIndex = 8
	self.buttonBar.Parent = self.mainFrame

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	tabLayout.Padding = UDim.new(0.05, 0) -- 5% spacing
	tabLayout.Parent = self.buttonBar

	-- CASH TAB
	self.cashContainer = Instance.new("Frame")
	self.cashContainer.BackgroundTransparency = 1
	self.cashContainer.Size = UDim2.fromScale(0.45, 1) -- 45% width of bar
	self.cashContainer.SizeConstraint = Enum.SizeConstraint.RelativeYY -- maintain aspect ratio based on height
	self.cashContainer.Parent = self.buttonBar
	Instance.new("UIAspectRatioConstraint", self.cashContainer).AspectRatio = 3.25 -- Pill shape

	self.cashBtn = Instance.new("ImageButton")
	self.cashBtn.BackgroundTransparency = 1
	self.cashBtn.Size = UDim2.fromScale(1, 1)
	self.cashBtn.Image = IMG_CASH
	self.cashBtn.ScaleType = Enum.ScaleType.Fit
	self.cashBtn.Parent = self.cashContainer
	self._cashScale = Instance.new("UIScale", self.cashContainer)

	-- GAMEPASS TAB
	self.gpContainer = Instance.new("Frame")
	self.gpContainer.BackgroundTransparency = 1
	self.gpContainer.Size = UDim2.fromScale(0.45, 1)
	self.gpContainer.SizeConstraint = Enum.SizeConstraint.RelativeYY
	self.gpContainer.Parent = self.buttonBar
	Instance.new("UIAspectRatioConstraint", self.gpContainer).AspectRatio = 4.2 -- Pill shape

	self.gpBtn = Instance.new("ImageButton")
	self.gpBtn.BackgroundTransparency = 1
	self.gpBtn.Size = UDim2.fromScale(1, 1)
	self.gpBtn.Image = IMG_GAMEPASSES
	self.gpBtn.ScaleType = Enum.ScaleType.Fit
	self.gpBtn.Parent = self.gpContainer
	self._gpScale = Instance.new("UIScale", self.gpContainer)

	-- CONTENT
	self.contentFrame = Instance.new("Frame")
	self.contentFrame.Name = "Content"
	self.contentFrame.AnchorPoint = Vector2.new(0.5, 0)
	self.contentFrame.Position = UDim2.fromScale(0.5, 0.50) -- Starts below tabs
	self.contentFrame.Size = UDim2.fromScale(0.82, 0.42)
	self.contentFrame.BackgroundColor3 = theme.white
	self.contentFrame.BackgroundTransparency = 0.9
	self.contentFrame.ZIndex = 5
	self.contentFrame.Parent = self.mainFrame
	Instance.new("UICorner", self.contentFrame).CornerRadius = UDim.new(0, 16)

	self:createPages()
	
	-- Device Specific Adjustments (Run once + on resize)
	self:setupDynamicSizing()

	self.cashBtn.MouseButton1Click:Connect(function() self:showCash() self:updateTabSelection("cash") playSound("click") end)
	self.gpBtn.MouseButton1Click:Connect(function() self:showGamepasses() self:updateTabSelection("gp") playSound("click") pulse(self.gpContainer) end)
	self:updateTabSelection("cash")
end

function Shop:setupDynamicSizing()
	local function update()
		local viewport = workspace.CurrentCamera.ViewportSize
		local isPhone = viewport.X < 700
		
		-- Adjust MainFrame Sizing
		-- On phones, we might want it slightly bigger scale to be readable
		if isPhone then
			self.mainFrame.Size = UDim2.fromScale(0.98, 0.98)
		else
			self.mainFrame.Size = UDim2.fromScale(0.9, 0.9)
		end

		-- Adjust Close Button Position
		-- "x = 18, y = 60" for phone relative to Top-Right of the IMAGE.
		-- Since we use ScaleType.Fit, the image might not fill the whole frame rect if aspect ratio differs.
		-- But simpler logic:
		if isPhone then
			self.closeBtn.Position = UDim2.new(1, -20, 0, 60)
			self.closeBtn.Size = UDim2.fromOffset(36, 36)
		else
			self.closeBtn.Position = UDim2.new(1, -50, 0, 170)
			self.closeBtn.Size = UDim2.fromOffset(48, 48)
		end
	end
	
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(update)
	update()
end

function Shop:createPages()
	local function mkPage(name)
		local p = Instance.new("ScrollingFrame")
		p.Name = name
		p.BackgroundTransparency = 1
		p.ScrollBarThickness = 4
		p.ScrollBarImageColor3 = theme.accent
		p.Size = UDim2.fromScale(1, 1)
		p.Parent = self.contentFrame
		local pd = Instance.new("UIPadding")
		pd.PaddingTop = UDim.new(0, 10)
		pd.PaddingBottom = UDim.new(0, 10)
		pd.PaddingLeft = UDim.new(0, 10)
		pd.PaddingRight = UDim.new(0, 10)
		pd.Parent = p
		return p
	end

	self.cashPage = mkPage("CashPage")
	local cGrid = Instance.new("UIGridLayout")
	cGrid.CellSize = UDim2.fromOffset(140, 180) -- Default, will update
	cGrid.CellPadding = UDim2.fromOffset(10, 10)
	cGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
	cGrid.Parent = self.cashPage
	
	self.gpPage = mkPage("GamepassPage")
	self.gpPage.Visible = false
	local gGrid = Instance.new("UIGridLayout")
	gGrid.CellSize = UDim2.fromOffset(140, 180)
	gGrid.CellPadding = UDim2.fromOffset(10, 10)
	gGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
	gGrid.Parent = self.gpPage

	-- Dynamic Grid Sizing
	local function updateGrid(grid, pg)
		local w = pg.AbsoluteSize.X
		if w <= 0 then return end
		-- Aim for 2 columns on phone, 3-4 on tablet/desktop
		local cols = 3
		if w < 400 then cols = 2 end
		
		local pad = 10
		local totalPad = (cols - 1) * pad + 20 -- +20 for margins
		local cellW = (w - totalPad) / cols
		local cellH = cellW * 1.3 -- Aspect ratio 1:1.3
		
		grid.CellSize = UDim2.fromOffset(cellW, cellH)
		pg.CanvasSize = UDim2.new(0, 0, 0, grid.AbsoluteContentSize.Y + 20)
	end

	self.cashPage:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() updateGrid(cGrid, self.cashPage) end)
	self.gpPage:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() updateGrid(gGrid, self.gpPage) end)
	cGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() self.cashPage.CanvasSize = UDim2.new(0, 0, 0, cGrid.AbsoluteContentSize.Y + 20) end)
	gGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() self.gpPage.CanvasSize = UDim2.new(0, 0, 0, gGrid.AbsoluteContentSize.Y + 20) end)

	for i, p in ipairs(products.cash) do p.LayoutOrder = i self:createProductItem(p, "cash", self.cashPage) end
	for i, gp in ipairs(products.gamepasses) do gp.LayoutOrder = i self:createProductItem(gp, "gamepass", self.gpPage) end
end

function Shop:createProductItem(product, kind, parent)
	local container = Instance.new("Frame")
	container.BackgroundTransparency = 1
	container.Parent = parent
	
	local card = buildCard(container, product, (kind == "gamepass") and 2 or 1)
	product.cardInstance = card
	product.containerInstance = container

	local function addBuy(btnText, btnColor, active, isToggle)
		local btn = makeBottomRow(container, isToggle and 1 or 1, btnText, btnColor, active, 0)
		if isToggle then
			-- Shift up existing rows? Logic simplified for robust UI
			-- If toggle, we usually have "OWNED" at bottom row 2, and "ON/OFF" at row 1
			btn.Position = UDim2.new(0.5, 0, 1, -8) -- Bottom
		end
		return btn
	end

	-- Initial State Logic
	local owned = checkOwnership(product.id)
	
	if kind == "gamepass" then
		if owned then
			makeBottomRow(container, 1, "OWNED", theme.success, false, 0)
			if product.hasToggle then
				-- Add toggle button slightly higher? No, Grid layout is tight.
				-- Let's replace OWNED with Toggle if owned.
				local tgl = makeBottomRow(container, 1, "OFF", theme.cardStroke, true, 0)
				
				local function updateTgl()
					local state = false
					if Remotes and Remotes:FindFirstChild("GetAutoCollectState") then
						pcall(function() state = Remotes.GetAutoCollectState:InvokeServer() end)
					end
					tgl:FindFirstChild("TextLabel").Text = state and "ON" or "OFF"
					tgl.BackgroundColor3 = state and theme.success or theme.cardStroke
				end
				updateTgl()
				
				tgl.MouseButton1Click:Connect(function()
					local curr = (tgl:FindFirstChild("TextLabel").Text == "ON")
					if Remotes and Remotes:FindFirstChild("AutoCollectToggle") then
						Remotes.AutoCollectToggle:FireServer(not curr)
					end
					tgl:FindFirstChild("TextLabel").Text = (not curr) and "ON" or "OFF"
					tgl.BackgroundColor3 = (not curr) and theme.success or theme.cardStroke
				end)
			end
		else
			local info = getGamePassInfo(product.id)
			local price = (info and info.PriceInRobux) or product.price or 0
			local btn = addBuy("BUY - R$"..price, theme.accent, true, false)
			btn.MouseButton1Click:Connect(function()
				self:promptPurchase(product, "gamepass", btn)
			end)
			product.purchaseButton = btn
		end
	else
		local info = getProductInfo(product.id)
		local price = (info and info.PriceInRobux) or product.price or 0
		local btn = addBuy("BUY - R$"..price, theme.accent, true, false)
		btn.MouseButton1Click:Connect(function()
			self:promptPurchase(product, "cash", btn)
		end)
		product.purchaseButton = btn
	end
end

function Shop:promptPurchase(product, kind, btn)
	self.purchasePending[product.id] = {product=product, kind=kind, btn=btn}
	local lbl = btn:FindFirstChild("TextLabel")
	local oldText = lbl.Text
	lbl.Text = "..."
	
	if kind == "gamepass" then
		MarketplaceService:PromptGamePassPurchase(Player, product.id)
	else
		MarketplaceService:PromptProductPurchase(Player, product.id)
	end
	
	-- Revert text if cancelled/failed after delay
	task.delay(5, function()
		if self.purchasePending[product.id] then
			lbl.Text = oldText
			self.purchasePending[product.id] = nil
		end
	end)
end

function Shop:updateTabSelection(which)
	local isCash = (which == "cash")
	TweenService:Create(self._cashScale, TweenInfo.new(0.2), {Scale = isCash and 1.1 or 0.9}):Play()
	TweenService:Create(self._gpScale, TweenInfo.new(0.2), {Scale = isCash and 0.9 or 1.1}):Play()
end

function Shop:showCash()
	self.cashPage.Visible = true
	self.gpPage.Visible = false
end
function Shop:showGamepasses()
	self.cashPage.Visible = false
	self.gpPage.Visible = true
end

function Shop:open()
	if self.isOpen then return end
	self.isOpen = true
	self.gui.Enabled = true
	TweenService:Create(self.blur, TweenInfo.new(0.3), {Size = 24}):Play()
	self.mainFrame.Position = UDim2.fromScale(0.5, 0.55)
	self.mainFrame.Rotation = 3
	TweenService:Create(self.mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.fromScale(0.5, 0.5), Rotation=0}):Play()
	playSound("open")
end

function Shop:close()
	if not self.isOpen then return end
	self.isOpen = false
	TweenService:Create(self.blur, TweenInfo.new(0.3), {Size = 0}):Play()
	TweenService:Create(self.mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.fromScale(0.5, 0.55), Rotation=-3}):Play()
	task.wait(0.3)
	self.gui.Enabled = false
end

function Shop:toggle() if self.isOpen then self:close() else self:open() end end

function Shop:setupHandlers()
	UserInputService.InputBegan:Connect(function(i, gp)
		if gp then return end
		if i.KeyCode == Enum.KeyCode.M then self:toggle() end
	end)
	
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(plr, id, bought)
		if plr ~= Player then return end
		if bought then
			playSound("success")
			-- Reload UI
			self.gui:Destroy()
			script.Parent = PlayerGui -- Reload script basically or just rebuild
			-- For now, simple update
			for _, gp in ipairs(products.gamepasses) do
				if gp.id == id and gp.containerInstance then
					gp.containerInstance:Destroy()
					self:createProductItem(gp, "gamepass", self.gpPage)
				end
			end
		end
		self.purchasePending[id] = nil
	end)
end

-- BOOT
local shop = Shop.new()
initSound()
shop:createToggleButton()
shop:createMainInterface()
shop:setupHandlers()

Player.CharacterAdded:Connect(function()
	task.wait(1)
	if not shop.toggleButton or not shop.toggleButton.Parent then shop:createToggleButton() end
end)

return shop