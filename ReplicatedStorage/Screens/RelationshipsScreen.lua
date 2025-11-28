-- RelationshipsScreen.lua
-- BitLife-style Relationships screen with family, friends, and romantic partners
-- Full-screen overlay with scrollable content sections

local TweenService = game:GetService("TweenService")

local RelationshipsScreen = {}
RelationshipsScreen.__index = RelationshipsScreen

----------------------------------------------------------------
-- COLORS (BitLife Palette)
----------------------------------------------------------------

local Colors = {
	-- Primary
	BitLifeBlue      = Color3.fromRGB(37, 99, 235),
	BitLifeBlueDark  = Color3.fromRGB(29, 78, 216),
	
	-- Section Colors
	FamilyPink       = Color3.fromRGB(236, 72, 153),
	FamilyPinkDark   = Color3.fromRGB(219, 39, 119),
	FriendsBlue      = Color3.fromRGB(59, 130, 246),
	FriendsBlueDark  = Color3.fromRGB(37, 99, 235),
	LoveRed          = Color3.fromRGB(239, 68, 68),
	LoveRedDark      = Color3.fromRGB(220, 38, 38),
	EnemiesOrange    = Color3.fromRGB(249, 115, 22),
	CoworkersGray    = Color3.fromRGB(107, 114, 128),
	
	-- Relationship Status Colors
	ExcellentGreen   = Color3.fromRGB(34, 197, 94),
	GoodBlue         = Color3.fromRGB(59, 130, 246),
	NeutralYellow    = Color3.fromRGB(234, 179, 8),
	PoorOrange       = Color3.fromRGB(249, 115, 22),
	TerribleRed      = Color3.fromRGB(239, 68, 68),
	
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
-- RELATIONSHIP DATA (Sample data - would come from server in real game)
----------------------------------------------------------------

local FamilyMembers = {
	{
		name = "Robert Russell",
		relationship = "Father",
		emoji = "👨",
		age = 52,
		status = 85,
		alive = true,
		occupation = "Accountant",
	},
	{
		name = "Margaret Russell",
		relationship = "Mother",
		emoji = "👩",
		age = 48,
		status = 92,
		alive = true,
		occupation = "Teacher",
	},
	{
		name = "Sarah Russell",
		relationship = "Sister",
		emoji = "👧",
		age = 14,
		status = 70,
		alive = true,
		occupation = "Student",
	},
	{
		name = "George Russell",
		relationship = "Grandfather",
		emoji = "👴",
		age = 78,
		status = 65,
		alive = true,
		occupation = "Retired",
	},
	{
		name = "Eleanor Russell",
		relationship = "Grandmother",
		emoji = "👵",
		age = 75,
		status = 80,
		alive = true,
		occupation = "Retired",
	},
}

local Friends = {
	{
		name = "Bradley Allen",
		relationship = "Best Friend",
		emoji = "👦",
		age = 0, -- Same as player
		status = 95,
		metAt = "School",
		years = 5,
	},
	{
		name = "Jessica Martinez",
		relationship = "Close Friend",
		emoji = "👧",
		age = 0,
		status = 78,
		metAt = "School",
		years = 3,
	},
	{
		name = "Marcus Johnson",
		relationship = "Friend",
		emoji = "👦",
		age = 0,
		status = 62,
		metAt = "Neighborhood",
		years = 2,
	},
}

local RomanticPartners = {
	-- Empty by default - player finds partners through activities
}

local Enemies = {
	{
		name = "Derek Thompson",
		relationship = "Nemesis",
		emoji = "😠",
		age = 0,
		status = 15,
		reason = "He bullied you in middle school",
	},
}

----------------------------------------------------------------
-- INTERACTION OPTIONS
----------------------------------------------------------------

local InteractionOptions = {
	Family = {
		{ text = "💬 Have a conversation", action = "conversation" },
		{ text = "🎁 Give a gift", action = "gift" },
		{ text = "🍽️ Spend time together", action = "spend_time" },
		{ text = "💰 Ask for money", action = "ask_money" },
		{ text = "🤗 Compliment", action = "compliment" },
		{ text = "😤 Argue", action = "argue" },
		{ text = "🚪 Move out", action = "move_out", minAge = 18 },
	},
	Friends = {
		{ text = "💬 Have a conversation", action = "conversation" },
		{ text = "🎁 Give a gift", action = "gift" },
		{ text = "🎉 Hang out", action = "hang_out" },
		{ text = "🤗 Compliment", action = "compliment" },
		{ text = "💕 Confess feelings", action = "confess" },
		{ text = "😤 Insult", action = "insult" },
		{ text = "👋 Unfriend", action = "unfriend" },
	},
	Romantic = {
		{ text = "💬 Have a conversation", action = "conversation" },
		{ text = "🎁 Give a gift", action = "gift" },
		{ text = "💑 Go on a date", action = "date" },
		{ text = "💋 Show affection", action = "affection" },
		{ text = "💍 Propose", action = "propose" },
		{ text = "💔 Break up", action = "breakup" },
	},
	Enemies = {
		{ text = "🤝 Apologize", action = "apologize" },
		{ text = "😤 Insult", action = "insult" },
		{ text = "👊 Fight", action = "fight" },
		{ text = "🙄 Ignore", action = "ignore" },
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

local function getStatusColor(status)
	if status >= 80 then
		return Colors.ExcellentGreen
	elseif status >= 60 then
		return Colors.GoodBlue
	elseif status >= 40 then
		return Colors.NeutralYellow
	elseif status >= 20 then
		return Colors.PoorOrange
	else
		return Colors.TerribleRed
	end
end

local function getStatusText(status)
	if status >= 90 then
		return "Excellent"
	elseif status >= 70 then
		return "Good"
	elseif status >= 50 then
		return "Okay"
	elseif status >= 30 then
		return "Poor"
	else
		return "Terrible"
	end
end

----------------------------------------------------------------
-- SCREEN CREATION
----------------------------------------------------------------

function RelationshipsScreen.new(screenGui, blurOverlay, showBlurFunc, hideBlurFunc, playerState)
	local self = setmetatable({}, RelationshipsScreen)
	
	self.screenGui = screenGui
	self.blurOverlay = blurOverlay
	self.showBlur = showBlurFunc
	self.hideBlur = hideBlurFunc
	self.playerState = playerState
	self.isVisible = false
	
	self:createUI()
	
	return self
end

function RelationshipsScreen:createUI()
	-- Main overlay container
	self.overlay = Instance.new("Frame")
	self.overlay.Name = "RelationshipsOverlay"
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
	header.BackgroundColor3 = Colors.FamilyPink
	header.BorderSizePixel = 0
	header.ZIndex = 85
	header.Parent = self.overlay
	
	local headerGrad = Instance.new("UIGradient")
	headerGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Colors.FamilyPink),
		ColorSequenceKeypoint.new(1, Colors.FamilyPinkDark),
	})
	headerGrad.Rotation = 90
	headerGrad.Parent = header
	
	-- Title (left side)
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
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
	
	-- Close button (TOP RIGHT - away from Roblox buttons)
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseBtn"
	closeBtn.Size = UDim2.new(0, 44, 0, 44)
	closeBtn.AnchorPoint = Vector2.new(1, 0.5)
	closeBtn.Position = UDim2.new(1, -10, 0.5, 0)
	closeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.BackgroundTransparency = 0.9
	closeBtn.Font = Fonts.Title
	closeBtn.TextSize = 24
	closeBtn.TextColor3 = Colors.White
	closeBtn.Text = "✕"
	closeBtn.AutoButtonColor = false
	closeBtn.ZIndex = 86
	closeBtn.Parent = header
	createUICorner(closeBtn, 22)
	
	closeBtn.MouseEnter:Connect(function()
		tween(closeBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0.7 })
	end)
	closeBtn.MouseLeave:Connect(function()
		tween(closeBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0.9 })
	end)
	
	closeBtn.MouseButton1Click:Connect(function()
		self:hide()
	end)
	
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
	self:createFamilySection()
	self:createFriendsSection()
	self:createRomanticSection()
	self:createEnemiesSection()
	self:createFindPeopleSection()
end

function RelationshipsScreen:createSectionHeader(parent, title, emoji, color, layoutOrder)
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

function RelationshipsScreen:createPersonCard(person, category, layoutOrder)
	local card = Instance.new("TextButton")
	card.Name = "Person_" .. person.name:gsub(" ", "_")
	card.Size = UDim2.new(1, 0, 0, 85)
	card.BackgroundColor3 = Colors.CardWhite
	card.LayoutOrder = layoutOrder
	card.AutoButtonColor = false
	card.Text = ""
	createUICorner(card, 14)
	createUIStroke(card, 1, 0.85, Color3.fromRGB(229, 231, 235))
	
	-- Avatar circle
	local avatarCircle = Instance.new("Frame")
	avatarCircle.Size = UDim2.new(0, 52, 0, 52)
	avatarCircle.Position = UDim2.new(0, 14, 0.5, -26)
	avatarCircle.BackgroundColor3 = category == "Family" and Color3.fromRGB(253, 242, 248) or
	                                 category == "Friends" and Color3.fromRGB(239, 246, 255) or
	                                 category == "Romantic" and Color3.fromRGB(254, 226, 226) or
	                                 Color3.fromRGB(254, 243, 199)
	avatarCircle.Parent = card
	createUICorner(avatarCircle, 26)
	
	local avatarEmoji = Instance.new("TextLabel")
	avatarEmoji.Size = UDim2.fromScale(1, 1)
	avatarEmoji.BackgroundTransparency = 1
	avatarEmoji.Font = Fonts.Body
	avatarEmoji.TextSize = 28
	avatarEmoji.Text = person.emoji
	avatarEmoji.Parent = avatarCircle
	
	-- Name and relationship
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.55, 0, 0, 20)
	nameLabel.Position = UDim2.new(0, 76, 0, 12)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Fonts.Title
	nameLabel.TextSize = 15
	nameLabel.TextColor3 = Colors.TextBlack
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = person.name
	nameLabel.Parent = card
	
	local relationLabel = Instance.new("TextLabel")
	relationLabel.Size = UDim2.new(0.55, 0, 0, 16)
	relationLabel.Position = UDim2.new(0, 76, 0, 32)
	relationLabel.BackgroundTransparency = 1
	relationLabel.Font = Fonts.Body
	relationLabel.TextSize = 12
	relationLabel.TextColor3 = Colors.MediumGray
	relationLabel.TextXAlignment = Enum.TextXAlignment.Left
	relationLabel.Text = person.relationship
	relationLabel.Parent = card
	
	-- Status bar
	local statusBg = Instance.new("Frame")
	statusBg.Size = UDim2.new(0.35, 0, 0, 10)
	statusBg.Position = UDim2.new(0, 76, 0, 54)
	statusBg.BackgroundColor3 = Colors.LightGray
	statusBg.Parent = card
	createUICorner(statusBg, 5)
	
	local statusColor = getStatusColor(person.status)
	
	local statusFill = Instance.new("Frame")
	statusFill.Size = UDim2.new(person.status / 100, 0, 1, 0)
	statusFill.BackgroundColor3 = statusColor
	statusFill.Parent = statusBg
	createUICorner(statusFill, 5)
	
	-- Status text
	local statusText = Instance.new("TextLabel")
	statusText.Size = UDim2.new(0, 50, 0, 14)
	statusText.Position = UDim2.new(0, 76 + statusBg.Size.X.Offset + 8, 0, 52)
	statusText.BackgroundTransparency = 1
	statusText.Font = Fonts.BodyMedium
	statusText.TextSize = 11
	statusText.TextColor3 = statusColor
	statusText.TextXAlignment = Enum.TextXAlignment.Left
	statusText.Text = person.status .. "%"
	statusText.Parent = card
	
	-- Age (if applicable)
	if person.age and person.age > 0 then
		local ageLabel = Instance.new("TextLabel")
		ageLabel.Size = UDim2.new(0, 60, 0, 16)
		ageLabel.Position = UDim2.new(0, 76, 0, 68)
		ageLabel.BackgroundTransparency = 1
		ageLabel.Font = Fonts.Body
		ageLabel.TextSize = 11
		ageLabel.TextColor3 = Colors.DarkGray
		ageLabel.TextXAlignment = Enum.TextXAlignment.Left
		ageLabel.Text = "Age " .. person.age
		ageLabel.Parent = card
	end
	
	-- Arrow indicator
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
	
	-- Hover effect
	card.MouseEnter:Connect(function()
		tween(card, TweenInfo.new(0.15), { BackgroundColor3 = Colors.LightGray })
		arrow.TextColor3 = Colors.TextDark
	end)
	card.MouseLeave:Connect(function()
		tween(card, TweenInfo.new(0.15), { BackgroundColor3 = Colors.CardWhite })
		arrow.TextColor3 = Colors.MediumGray
	end)
	
	-- Click to open interaction modal
	card.MouseButton1Click:Connect(function()
		self:showInteractionModal(person, category)
	end)
	
	return card
end

function RelationshipsScreen:createFamilySection()
	local section, layout = self:createSectionHeader(
		self.contentScroll,
		"Family",
		"👨‍👩‍👧‍👦",
		Colors.FamilyPink,
		1
	)
	
	for i, person in ipairs(FamilyMembers) do
		local card = self:createPersonCard(person, "Family", i + 1)
		card.Parent = section
	end
	
	self.familySection = section
end

function RelationshipsScreen:createFriendsSection()
	local section, layout = self:createSectionHeader(
		self.contentScroll,
		"Friends",
		"👥",
		Colors.FriendsBlue,
		2
	)
	
	if #Friends == 0 then
		local emptyCard = Instance.new("Frame")
		emptyCard.Size = UDim2.new(1, 0, 0, 70)
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
		emptyLabel.Text = "😔 You have no friends yet.\nTry meeting people through activities!"
		emptyLabel.TextWrapped = true
		emptyLabel.Parent = emptyCard
	else
		for i, person in ipairs(Friends) do
			local card = self:createPersonCard(person, "Friends", i + 1)
			card.Parent = section
		end
	end
	
	self.friendsSection = section
end

function RelationshipsScreen:createRomanticSection()
	local section, layout = self:createSectionHeader(
		self.contentScroll,
		"Love Life",
		"💕",
		Colors.LoveRed,
		3
	)
	
	if #RomanticPartners == 0 then
		local emptyCard = Instance.new("Frame")
		emptyCard.Size = UDim2.new(1, 0, 0, 70)
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
		emptyLabel.Text = "💔 You're single.\nFind love through dating activities!"
		emptyLabel.TextWrapped = true
		emptyLabel.Parent = emptyCard
	else
		for i, person in ipairs(RomanticPartners) do
			local card = self:createPersonCard(person, "Romantic", i + 1)
			card.Parent = section
		end
	end
	
	self.romanticSection = section
end

function RelationshipsScreen:createEnemiesSection()
	local section, layout = self:createSectionHeader(
		self.contentScroll,
		"Enemies",
		"😠",
		Colors.EnemiesOrange,
		4
	)
	
	if #Enemies == 0 then
		local emptyCard = Instance.new("Frame")
		emptyCard.Size = UDim2.new(1, 0, 0, 60)
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
		emptyLabel.Text = "😊 You have no enemies. Keep it that way!"
		emptyLabel.Parent = emptyCard
	else
		for i, person in ipairs(Enemies) do
			local card = self:createPersonCard(person, "Enemies", i + 1)
			card.Parent = section
		end
	end
	
	self.enemiesSection = section
end

function RelationshipsScreen:createFindPeopleSection()
	local section, layout = self:createSectionHeader(
		self.contentScroll,
		"Find Someone",
		"🔍",
		Colors.BitLifeBlue,
		5
	)
	
	local findOptions = {
		{ text = "📱 Dating App", emoji = "💕", description = "Swipe through potential matches" },
		{ text = "🏫 School/Work", emoji = "👥", description = "Meet people through daily life" },
		{ text = "🎉 Social Events", emoji = "🎊", description = "Attend parties and gatherings" },
		{ text = "💻 Online", emoji = "🌐", description = "Meet people on the internet" },
	}
	
	for i, option in ipairs(findOptions) do
		local card = Instance.new("TextButton")
		card.Size = UDim2.new(1, 0, 0, 65)
		card.BackgroundColor3 = Colors.CardWhite
		card.LayoutOrder = i + 1
		card.AutoButtonColor = false
		card.Text = ""
		card.Parent = section
		createUICorner(card, 14)
		createUIStroke(card, 1, 0.85, Color3.fromRGB(229, 231, 235))
		
		local emojiLabel = Instance.new("TextLabel")
		emojiLabel.Size = UDim2.new(0, 50, 1, 0)
		emojiLabel.Position = UDim2.new(0, 10, 0, 0)
		emojiLabel.BackgroundTransparency = 1
		emojiLabel.Font = Fonts.Body
		emojiLabel.TextSize = 28
		emojiLabel.Text = option.emoji
		emojiLabel.Parent = card
		
		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(0.6, 0, 0, 20)
		textLabel.Position = UDim2.new(0, 65, 0, 12)
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Fonts.Title
		textLabel.TextSize = 14
		textLabel.TextColor3 = Colors.TextBlack
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.Text = option.text
		textLabel.Parent = card
		
		local descLabel = Instance.new("TextLabel")
		descLabel.Size = UDim2.new(0.6, 0, 0, 16)
		descLabel.Position = UDim2.new(0, 65, 0, 34)
		descLabel.BackgroundTransparency = 1
		descLabel.Font = Fonts.Body
		descLabel.TextSize = 11
		descLabel.TextColor3 = Colors.MediumGray
		descLabel.TextXAlignment = Enum.TextXAlignment.Left
		descLabel.Text = option.description
		descLabel.Parent = card
		
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
	end
end

function RelationshipsScreen:showInteractionModal(person, category)
	-- TODO: Create interaction modal with options
	print("Interact with:", person.name, "Category:", category)
end

----------------------------------------------------------------
-- VISIBILITY
----------------------------------------------------------------

function RelationshipsScreen:show()
	if self.isVisible then return end
	self.isVisible = true
	
	self.overlay.Visible = true
	self.overlay.Position = UDim2.new(1, 0, 0, 0)
	
	tween(self.overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 0, 0, 0)
	})
end

function RelationshipsScreen:hide()
	if not self.isVisible then return end
	self.isVisible = false
	
	local t = tween(self.overlay, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		Position = UDim2.new(1, 0, 0, 0)
	})
	
	t.Completed:Connect(function()
		self.overlay.Visible = false
	end)
end

function RelationshipsScreen:toggle()
	if self.isVisible then
		self:hide()
	else
		self:show()
	end
end

return RelationshipsScreen
