-- RelationshipsScreen.lua
-- BitLife-style Relationships screen with SERVER VALIDATION
-- Uses remotes for all interactions - no more baby gifting $50!

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RelationshipsScreen = {}
RelationshipsScreen.__index = RelationshipsScreen

----------------------------------------------------------------
-- REMOTES
----------------------------------------------------------------

local remotesFolder = ReplicatedStorage:WaitForChild("LifeRemotes", 10)
local InteractPerson = remotesFolder and remotesFolder:FindFirstChild("InteractPerson")
local GiveMoney = remotesFolder and remotesFolder:FindFirstChild("GiveMoney")

----------------------------------------------------------------
-- COLORS
----------------------------------------------------------------

local Colors = {
	BitLifeBlue      = Color3.fromRGB(37, 99, 235),
	FamilyPink       = Color3.fromRGB(236, 72, 153),
	FamilyPinkDark   = Color3.fromRGB(219, 39, 119),
	FriendsBlue      = Color3.fromRGB(59, 130, 246),
	EnemiesOrange    = Color3.fromRGB(249, 115, 22),
	ExcellentGreen   = Color3.fromRGB(34, 197, 94),
	GoodBlue         = Color3.fromRGB(59, 130, 246),
	NeutralYellow    = Color3.fromRGB(234, 179, 8),
	PoorOrange       = Color3.fromRGB(249, 115, 22),
	TerribleRed      = Color3.fromRGB(239, 68, 68),
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
-- RELATIONSHIP DATA
----------------------------------------------------------------

local FamilyMembers = {
	{ id = "father", name = "Robert Russell", relationship = "Father", emoji = "👨", age = 52, status = 85 },
	{ id = "mother", name = "Margaret Russell", relationship = "Mother", emoji = "👩", age = 48, status = 92 },
	{ id = "sister", name = "Sarah Russell", relationship = "Sister", emoji = "👧", age = 14, status = 70 },
	{ id = "grandpa", name = "George Russell", relationship = "Grandfather", emoji = "👴", age = 78, status = 65 },
	{ id = "grandma", name = "Eleanor Russell", relationship = "Grandmother", emoji = "👵", age = 75, status = 80 },
}

local Friends = {
	{ id = "friend1", name = "Bradley Allen", relationship = "Best Friend", emoji = "👦", age = 18, status = 95 },
	{ id = "friend2", name = "Jessica Martinez", relationship = "Close Friend", emoji = "👧", age = 17, status = 78 },
	{ id = "friend3", name = "Marcus Johnson", relationship = "Friend", emoji = "👦", age = 19, status = 62 },
}

local Enemies = {
	{ id = "enemy1", name = "Derek Thompson", relationship = "Nemesis", emoji = "😠", age = 19, status = 15, reason = "He bullied you in middle school." },
}

----------------------------------------------------------------
-- ACTION DEFINITIONS (with age requirements)
----------------------------------------------------------------

local ActionDefs = {
	Compliment = { text = "🤗 Compliment", minAge = 3, cost = 0 },
	Insult = { text = "🤬 Insult", minAge = 5, cost = 0 },
	Gift = { text = "🎁 Give Gift ($50)", minAge = 5, cost = 50 },
	SpendTime = { text = "🕐 Spend Time", minAge = 2, cost = 0 },
	Argue = { text = "😤 Argue", minAge = 5, cost = 0 },
	Apologize = { text = "🙏 Apologize", minAge = 4, cost = 0 },
	AskMoney = { text = "💰 Ask for Money", minAge = 5, cost = 0 },
	Conversation = { text = "💬 Conversation", minAge = 3, cost = 0 },
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

local function getStatusColor(status)
	if status >= 80 then return Colors.ExcellentGreen
	elseif status >= 60 then return Colors.GoodBlue
	elseif status >= 40 then return Colors.NeutralYellow
	elseif status >= 20 then return Colors.PoorOrange
	else return Colors.TerribleRed end
end

----------------------------------------------------------------
-- SCREEN CREATION
----------------------------------------------------------------

function RelationshipsScreen.new(screenGui, blurOverlay, showBlurFunc, hideBlurFunc, playerState)
	local self = setmetatable({}, RelationshipsScreen)
	
	self.screenGui = screenGui
	self.playerState = playerState -- Reference to shared state
	self.isVisible = false
	
	self:createUI()
	self:createInteractionModal()
	self:createResultModal()
	
	return self
end

function RelationshipsScreen:getPlayerAge()
	if self.playerState and self.playerState.Age then
		return self.playerState.Age
	end
	return 0
end

function RelationshipsScreen:getPlayerMoney()
	if self.playerState and self.playerState.Money then
		return self.playerState.Money
	end
	return 0
end

function RelationshipsScreen:createUI()
	self.overlay = Instance.new("Frame")
	self.overlay.Name = "RelationshipsOverlay"
	self.overlay.Size = UDim2.fromScale(1, 1)
	self.overlay.BackgroundColor3 = Colors.ScreenBg
	self.overlay.Visible = false
	self.overlay.ZIndex = 80
	self.overlay.Parent = self.screenGui
	
	-- Header
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 60)
	header.BackgroundColor3 = Colors.FamilyPink
	header.BorderSizePixel = 0
	header.ZIndex = 85
	header.Parent = self.overlay
	
	local headerGrad = Instance.new("UIGradient")
	headerGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Colors.FamilyPink), ColorSequenceKeypoint.new(1, Colors.FamilyPinkDark) })
	headerGrad.Rotation = 90
	headerGrad.Parent = header
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -80, 1, 0)
	titleLabel.Position = UDim2.new(0, 16, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Fonts.Title
	titleLabel.TextSize = 20
	titleLabel.TextColor3 = Colors.White
	titleLabel.Text = "❤️ Relationships"
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
	
	-- Content
	local contentScroll = Instance.new("ScrollingFrame")
	contentScroll.Size = UDim2.new(1, 0, 1, -60)
	contentScroll.Position = UDim2.new(0, 0, 0, 60)
	contentScroll.BackgroundTransparency = 1
	contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	contentScroll.ScrollBarThickness = 4
	contentScroll.ZIndex = 81
	contentScroll.Parent = self.overlay
	
	createUIPadding(contentScroll, 16, 16, 16, 16)
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 16)
	layout.Parent = contentScroll
	
	self.contentScroll = contentScroll
	
	self:createSection("Family", "👨‍👩‍👧‍👦", Colors.FamilyPink, FamilyMembers, "Family", 1)
	self:createSection("Friends", "👥", Colors.FriendsBlue, Friends, "Friends", 2)
	self:createSection("Enemies", "😠", Colors.EnemiesOrange, Enemies, "Enemies", 3)
end

function RelationshipsScreen:createSection(title, emoji, color, people, category, order)
	local section = Instance.new("Frame")
	section.Name = title .. "Section"
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
	headerFrame.BackgroundColor3 = color
	headerFrame.LayoutOrder = 1
	headerFrame.Parent = section
	createUICorner(headerFrame, 12)
	
	local headerText = Instance.new("TextLabel")
	headerText.Size = UDim2.fromScale(1, 1)
	headerText.BackgroundTransparency = 1
	headerText.Font = Fonts.Title
	headerText.TextSize = 16
	headerText.TextColor3 = Colors.White
	headerText.Text = emoji .. "  " .. title
	headerText.Parent = headerFrame
	
	for i, person in ipairs(people) do
		self:createPersonCard(person, category, i + 1, section)
	end
end

function RelationshipsScreen:createPersonCard(person, category, order, parent)
	local card = Instance.new("TextButton")
	card.Name = "Person_" .. person.id
	card.Size = UDim2.new(1, 0, 0, 80)
	card.BackgroundColor3 = Colors.CardWhite
	card.LayoutOrder = order
	card.AutoButtonColor = false
	card.Text = ""
	card.Parent = parent
	createUICorner(card, 14)
	createUIStroke(card, 1, 0.85, Color3.fromRGB(229, 231, 235))
	
	-- Avatar
	local bgColor = category == "Family" and Color3.fromRGB(253, 242, 248) or
	                category == "Friends" and Color3.fromRGB(239, 246, 255) or
	                Color3.fromRGB(254, 243, 199)
	
	local avatar = Instance.new("Frame")
	avatar.Size = UDim2.new(0, 50, 0, 50)
	avatar.Position = UDim2.new(0, 14, 0.5, -25)
	avatar.BackgroundColor3 = bgColor
	avatar.Parent = card
	createUICorner(avatar, 25)
	
	local avatarEmoji = Instance.new("TextLabel")
	avatarEmoji.Size = UDim2.fromScale(1, 1)
	avatarEmoji.BackgroundTransparency = 1
	avatarEmoji.Font = Fonts.Body
	avatarEmoji.TextSize = 26
	avatarEmoji.Text = person.emoji
	avatarEmoji.Parent = avatar
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.5, 0, 0, 20)
	nameLabel.Position = UDim2.new(0, 74, 0, 12)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Fonts.Title
	nameLabel.TextSize = 15
	nameLabel.TextColor3 = Colors.TextBlack
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = person.name
	nameLabel.Parent = card
	
	local relationLabel = Instance.new("TextLabel")
	relationLabel.Size = UDim2.new(0.5, 0, 0, 16)
	relationLabel.Position = UDim2.new(0, 74, 0, 32)
	relationLabel.BackgroundTransparency = 1
	relationLabel.Font = Fonts.Body
	relationLabel.TextSize = 12
	relationLabel.TextColor3 = Colors.MediumGray
	relationLabel.TextXAlignment = Enum.TextXAlignment.Left
	relationLabel.Text = person.relationship
	relationLabel.Parent = card
	
	-- Status bar
	local statusBg = Instance.new("Frame")
	statusBg.Size = UDim2.new(0.35, 0, 0, 8)
	statusBg.Position = UDim2.new(0, 74, 0, 54)
	statusBg.BackgroundColor3 = Colors.LightGray
	statusBg.Parent = card
	createUICorner(statusBg, 4)
	
	local statusFill = Instance.new("Frame")
	statusFill.Size = UDim2.new(math.clamp(person.status / 100, 0, 1), 0, 1, 0)
	statusFill.BackgroundColor3 = getStatusColor(person.status)
	statusFill.Parent = statusBg
	createUICorner(statusFill, 4)
	
	local arrow = Instance.new("TextLabel")
	arrow.Size = UDim2.new(0, 30, 1, 0)
	arrow.AnchorPoint = Vector2.new(1, 0)
	arrow.Position = UDim2.new(1, -10, 0, 0)
	arrow.BackgroundTransparency = 1
	arrow.Font = Fonts.Title
	arrow.TextSize = 18
	arrow.TextColor3 = Colors.MediumGray
	arrow.Text = "→"
	arrow.Parent = card
	
	card.MouseEnter:Connect(function()
		tween(card, TweenInfo.new(0.15), { BackgroundColor3 = Colors.LightGray })
	end)
	card.MouseLeave:Connect(function()
		tween(card, TweenInfo.new(0.15), { BackgroundColor3 = Colors.CardWhite })
	end)
	
	card.MouseButton1Click:Connect(function()
		self:showInteractionModal(person, category)
	end)
end

function RelationshipsScreen:createInteractionModal()
	self.interactionOverlay = Instance.new("Frame")
	self.interactionOverlay.Name = "InteractionOverlay"
	self.interactionOverlay.Size = UDim2.fromScale(1, 1)
	self.interactionOverlay.BackgroundColor3 = Colors.OverlayDark
	self.interactionOverlay.BackgroundTransparency = 0.4
	self.interactionOverlay.Visible = false
	self.interactionOverlay.ZIndex = 90
	self.interactionOverlay.Parent = self.screenGui
	
	self.interactionModal = Instance.new("Frame")
	self.interactionModal.Size = UDim2.new(0, 340, 0, 0)
	self.interactionModal.AutomaticSize = Enum.AutomaticSize.Y
	self.interactionModal.AnchorPoint = Vector2.new(0.5, 0.5)
	self.interactionModal.Position = UDim2.fromScale(0.5, 0.5)
	self.interactionModal.BackgroundColor3 = Colors.CardWhite
	self.interactionModal.ZIndex = 91
	self.interactionModal.Parent = self.interactionOverlay
	createUICorner(self.interactionModal, 20)
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 0)
	layout.Parent = self.interactionModal
	
	-- Header
	self.modalHeader = Instance.new("Frame")
	self.modalHeader.Size = UDim2.new(1, 0, 0, 100)
	self.modalHeader.BackgroundColor3 = Colors.FamilyPink
	self.modalHeader.LayoutOrder = 1
	self.modalHeader.Parent = self.interactionModal
	createUICorner(self.modalHeader, 20)
	
	local headerFix = Instance.new("Frame")
	headerFix.Size = UDim2.new(1, 0, 0, 20)
	headerFix.Position = UDim2.new(0, 0, 1, -20)
	headerFix.BackgroundColor3 = Colors.FamilyPink
	headerFix.BorderSizePixel = 0
	headerFix.Parent = self.modalHeader
	
	local modalClose = Instance.new("TextButton")
	modalClose.Size = UDim2.new(0, 36, 0, 36)
	modalClose.AnchorPoint = Vector2.new(1, 0)
	modalClose.Position = UDim2.new(1, -10, 0, 10)
	modalClose.BackgroundColor3 = Colors.White
	modalClose.BackgroundTransparency = 0.8
	modalClose.Font = Fonts.Title
	modalClose.TextSize = 20
	modalClose.TextColor3 = Colors.White
	modalClose.Text = "✕"
	modalClose.AutoButtonColor = false
	modalClose.ZIndex = 92
	modalClose.Parent = self.modalHeader
	createUICorner(modalClose, 18)
	modalClose.MouseButton1Click:Connect(function() self:hideInteractionModal() end)
	
	self.modalAvatar = Instance.new("Frame")
	self.modalAvatar.Size = UDim2.new(0, 60, 0, 60)
	self.modalAvatar.Position = UDim2.new(0, 20, 0.5, -30)
	self.modalAvatar.BackgroundColor3 = Colors.White
	self.modalAvatar.Parent = self.modalHeader
	createUICorner(self.modalAvatar, 30)
	
	self.modalAvatarEmoji = Instance.new("TextLabel")
	self.modalAvatarEmoji.Size = UDim2.fromScale(1, 1)
	self.modalAvatarEmoji.BackgroundTransparency = 1
	self.modalAvatarEmoji.Font = Fonts.Body
	self.modalAvatarEmoji.TextSize = 32
	self.modalAvatarEmoji.Text = "👤"
	self.modalAvatarEmoji.Parent = self.modalAvatar
	
	self.modalName = Instance.new("TextLabel")
	self.modalName.Size = UDim2.new(0.6, 0, 0, 24)
	self.modalName.Position = UDim2.new(0, 90, 0, 26)
	self.modalName.BackgroundTransparency = 1
	self.modalName.Font = Fonts.Title
	self.modalName.TextSize = 18
	self.modalName.TextColor3 = Colors.White
	self.modalName.TextXAlignment = Enum.TextXAlignment.Left
	self.modalName.Text = "Name"
	self.modalName.Parent = self.modalHeader
	
	self.modalRelation = Instance.new("TextLabel")
	self.modalRelation.Size = UDim2.new(0.6, 0, 0, 18)
	self.modalRelation.Position = UDim2.new(0, 90, 0, 50)
	self.modalRelation.BackgroundTransparency = 1
	self.modalRelation.Font = Fonts.Body
	self.modalRelation.TextSize = 13
	self.modalRelation.TextColor3 = Color3.new(1, 1, 1)
	self.modalRelation.TextTransparency = 0.2
	self.modalRelation.TextXAlignment = Enum.TextXAlignment.Left
	self.modalRelation.Text = "Relationship"
	self.modalRelation.Parent = self.modalHeader
	
	-- Actions container
	self.actionsContainer = Instance.new("Frame")
	self.actionsContainer.Name = "Actions"
	self.actionsContainer.Size = UDim2.new(1, 0, 0, 0)
	self.actionsContainer.AutomaticSize = Enum.AutomaticSize.Y
	self.actionsContainer.BackgroundTransparency = 1
	self.actionsContainer.LayoutOrder = 2
	self.actionsContainer.Parent = self.interactionModal
	
	createUIPadding(self.actionsContainer, 16, 16, 16, 16)
	
	self.actionsLayout = Instance.new("UIListLayout")
	self.actionsLayout.Padding = UDim.new(0, 10)
	self.actionsLayout.Parent = self.actionsContainer
end

function RelationshipsScreen:createResultModal()
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
	self.resultEmoji.Text = "😊"
	self.resultEmoji.LayoutOrder = 1
	self.resultEmoji.Parent = self.resultModal
	
	self.resultTitle = Instance.new("TextLabel")
	self.resultTitle.Size = UDim2.new(1, 0, 0, 28)
	self.resultTitle.BackgroundTransparency = 1
	self.resultTitle.Font = Fonts.Title
	self.resultTitle.TextSize = 20
	self.resultTitle.TextColor3 = Colors.TextBlack
	self.resultTitle.Text = "Result"
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
	self.resultText.Text = "Something happened!"
	self.resultText.LayoutOrder = 3
	self.resultText.Parent = self.resultModal
	
	self.resultStatChange = Instance.new("TextLabel")
	self.resultStatChange.Size = UDim2.new(1, 0, 0, 24)
	self.resultStatChange.BackgroundTransparency = 1
	self.resultStatChange.Font = Fonts.Title
	self.resultStatChange.TextSize = 16
	self.resultStatChange.TextColor3 = Colors.ExcellentGreen
	self.resultStatChange.Text = ""
	self.resultStatChange.LayoutOrder = 4
	self.resultStatChange.Parent = self.resultModal
	
	local okBtn = Instance.new("TextButton")
	okBtn.Size = UDim2.new(1, 0, 0, 48)
	okBtn.BackgroundColor3 = Colors.BitLifeBlue
	okBtn.Font = Fonts.Button
	okBtn.TextSize = 16
	okBtn.TextColor3 = Colors.White
	okBtn.Text = "OK"
	okBtn.AutoButtonColor = false
	okBtn.LayoutOrder = 5
	okBtn.Parent = self.resultModal
	createPillCorner(okBtn)
	okBtn.MouseButton1Click:Connect(function() self:hideResultModal() end)
end

function RelationshipsScreen:showInteractionModal(person, category)
	self.currentPerson = person
	self.currentCategory = category
	
	local age = self:getPlayerAge()
	local money = self:getPlayerMoney()
	
	self.modalAvatarEmoji.Text = person.emoji
	self.modalName.Text = person.name
	self.modalRelation.Text = person.relationship
	
	local headerColor = category == "Family" and Colors.FamilyPink or
	                    category == "Friends" and Colors.FriendsBlue or
	                    Colors.EnemiesOrange
	self.modalHeader.BackgroundColor3 = headerColor
	self.modalHeader:FindFirstChild("Frame").BackgroundColor3 = headerColor
	
	-- Clear old actions
	for _, child in ipairs(self.actionsContainer:GetChildren()) do
		if child:IsA("TextButton") or child:IsA("TextLabel") then
			child:Destroy()
		end
	end
	
	-- Add age info
	local ageInfo = Instance.new("TextLabel")
	ageInfo.Name = "AgeInfo"
	ageInfo.Size = UDim2.new(1, 0, 0, 20)
	ageInfo.BackgroundTransparency = 1
	ageInfo.Font = Fonts.Body
	ageInfo.TextSize = 12
	ageInfo.TextColor3 = Colors.MediumGray
	ageInfo.Text = "Your age: " .. age .. " | Your money: $" .. money
	ageInfo.LayoutOrder = 0
	ageInfo.Parent = self.actionsContainer
	
	-- Build actions based on category and age
	local actions = {}
	if category == "Family" then
		actions = { "Conversation", "Compliment", "Gift", "SpendTime", "AskMoney", "Argue", "Insult" }
	elseif category == "Friends" then
		actions = { "Conversation", "Compliment", "Gift", "SpendTime", "Insult" }
	else
		actions = { "Apologize", "Conversation", "Insult", "Argue" }
	end
	
	local colorMap = {
		Conversation = Colors.BitLifeBlue,
		Compliment = Colors.ExcellentGreen,
		Gift = Colors.FamilyPink,
		SpendTime = Colors.FriendsBlue,
		AskMoney = Colors.NeutralYellow,
		Argue = Colors.EnemiesOrange,
		Insult = Colors.TerribleRed,
		Apologize = Colors.ExcellentGreen,
	}
	
	for i, actionKey in ipairs(actions) do
		local def = ActionDefs[actionKey]
		if def then
			local canDo = age >= def.minAge
			local canAfford = money >= def.cost
			
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 0, 46)
			btn.BackgroundColor3 = (canDo and canAfford) and colorMap[actionKey] or Colors.MediumGray
			btn.Font = Fonts.Button
			btn.TextSize = 14
			btn.TextColor3 = Colors.White
			btn.AutoButtonColor = false
			btn.LayoutOrder = i
			btn.Parent = self.actionsContainer
			createPillCorner(btn)
			
			if not canDo then
				btn.Text = def.text .. " (Age " .. def.minAge .. "+)"
			elseif not canAfford then
				btn.Text = def.text .. " (Need $" .. def.cost .. ")"
			else
				btn.Text = def.text
			end
			
			if canDo and canAfford then
				btn.MouseEnter:Connect(function()
					tween(btn, TweenInfo.new(0.1), { Size = UDim2.new(1, 4, 0, 50) })
				end)
				btn.MouseLeave:Connect(function()
					tween(btn, TweenInfo.new(0.1), { Size = UDim2.new(1, 0, 0, 46) })
				end)
				
				btn.MouseButton1Click:Connect(function()
					self:performAction(actionKey, person, category)
				end)
			end
		end
	end
	
	self.interactionOverlay.Visible = true
	self.interactionModal.Position = UDim2.new(0.5, 0, 0.5, 50)
	tween(self.interactionModal, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.5)
	})
end

function RelationshipsScreen:hideInteractionModal()
	local t = tween(self.interactionModal, TweenInfo.new(0.2), { Position = UDim2.new(0.5, 0, 0.5, 50) })
	t.Completed:Connect(function()
		self.interactionOverlay.Visible = false
	end)
end

function RelationshipsScreen:performAction(actionKey, person, category)
	self:hideInteractionModal()
	
	-- Call server
	task.delay(0.3, function()
		local result
		
		if actionKey == "AskMoney" and GiveMoney then
			result = GiveMoney:InvokeServer(person.id)
		elseif InteractPerson then
			result = InteractPerson:InvokeServer(person.id, actionKey)
		else
			-- Fallback if no remote
			result = { success = false, message = "Server not available" }
		end
		
		if result then
			local emoji = result.isPositive and "😊" or "😢"
			local title = result.isPositive and "Success!" or "Uh oh..."
			
			if actionKey == "AskMoney" and result.amount then
				emoji = result.success and "💵" or "🙅"
			end
			
			self.resultEmoji.Text = emoji
			self.resultTitle.Text = title
			self.resultTitle.TextColor3 = result.isPositive and Colors.ExcellentGreen or Colors.TerribleRed
			self.resultText.Text = result.message or "Something happened."
			
			if result.statChange then
				local sign = result.statChange > 0 and "+" or ""
				self.resultStatChange.Text = sign .. result.statChange .. "% Relationship"
				self.resultStatChange.TextColor3 = result.statChange > 0 and Colors.ExcellentGreen or Colors.TerribleRed
			else
				self.resultStatChange.Text = ""
			end
			
			self.resultOverlay.Visible = true
			self.resultModal.Position = UDim2.new(0.5, 0, 0.5, 30)
			tween(self.resultModal, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Position = UDim2.fromScale(0.5, 0.5)
			})
		end
	end)
end

function RelationshipsScreen:hideResultModal()
	self.resultOverlay.Visible = false
end

function RelationshipsScreen:show()
	if self.isVisible then return end
	self.isVisible = true
	self.overlay.Visible = true
	self.overlay.Position = UDim2.new(1, 0, 0, 0)
	tween(self.overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.new(0, 0, 0, 0) })
end

function RelationshipsScreen:hide()
	if not self.isVisible then return end
	self.isVisible = false
	self.interactionOverlay.Visible = false
	self.resultOverlay.Visible = false
	local t = tween(self.overlay, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Position = UDim2.new(1, 0, 0, 0) })
	t.Completed:Connect(function() self.overlay.Visible = false end)
end

function RelationshipsScreen:toggle()
	if self.isVisible then self:hide() else self:show() end
end

return RelationshipsScreen
