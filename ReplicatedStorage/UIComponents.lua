-- UIComponents.lua
-- Shared premium BitLife-style UI components for all screens
-- Triple AAA polished components matching LifeClient's quality

local TweenService = game:GetService("TweenService")

local UIComponents = {}

----------------------------------------------------------------
-- PREMIUM COLOR PALETTE (BitLife-style)
----------------------------------------------------------------

UIComponents.Colors = {
	-- Primary Blues
	Blue = Color3.fromRGB(37, 99, 235),
	BlueDark = Color3.fromRGB(29, 78, 216),
	BlueLight = Color3.fromRGB(96, 165, 250),
	BluePale = Color3.fromRGB(219, 234, 254),
	
	-- Greens
	Green = Color3.fromRGB(34, 197, 94),
	GreenDark = Color3.fromRGB(22, 163, 74),
	GreenRing = Color3.fromRGB(21, 128, 61),
	GreenPale = Color3.fromRGB(220, 252, 231),
	
	-- Reds
	Red = Color3.fromRGB(239, 68, 68),
	RedDark = Color3.fromRGB(220, 38, 38),
	RedPale = Color3.fromRGB(254, 226, 226),
	
	-- Oranges / Amber
	Orange = Color3.fromRGB(249, 115, 22),
	OrangeDark = Color3.fromRGB(234, 88, 12),
	OrangePale = Color3.fromRGB(255, 237, 213),
	Amber = Color3.fromRGB(245, 158, 11),
	AmberDark = Color3.fromRGB(217, 119, 6),
	AmberPale = Color3.fromRGB(254, 243, 199),
	
	-- Pinks
	Pink = Color3.fromRGB(236, 72, 153),
	PinkDark = Color3.fromRGB(219, 39, 119),
	PinkPale = Color3.fromRGB(252, 231, 243),
	
	-- Purples
	Purple = Color3.fromRGB(147, 51, 234),
	PurpleDark = Color3.fromRGB(124, 58, 237),
	PurplePale = Color3.fromRGB(243, 232, 255),
	
	-- Cyans / Teals
	Cyan = Color3.fromRGB(6, 182, 212),
	CyanDark = Color3.fromRGB(8, 145, 178),
	CyanPale = Color3.fromRGB(207, 250, 254),
	Teal = Color3.fromRGB(20, 184, 166),
	TealDark = Color3.fromRGB(13, 148, 136),
	TealPale = Color3.fromRGB(204, 251, 241),
	
	-- Navy
	Navy = Color3.fromRGB(30, 58, 138),
	NavyDark = Color3.fromRGB(23, 37, 84),
	NavyPale = Color3.fromRGB(224, 231, 255),
	
	-- Golds
	Gold = Color3.fromRGB(234, 179, 8),
	GoldDark = Color3.fromRGB(202, 138, 4),
	GoldPale = Color3.fromRGB(254, 249, 195),
	
	-- Neutrals
	White = Color3.fromRGB(255, 255, 255),
	OffWhite = Color3.fromRGB(250, 250, 252),
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
	
	-- Special
	Bg = Color3.fromRGB(248, 250, 252),
	CardBg = Color3.fromRGB(255, 255, 255),
}

UIComponents.Fonts = {
	Title = Enum.Font.GothamBold,
	Body = Enum.Font.Gotham,
	Medium = Enum.Font.GothamMedium,
	Button = Enum.Font.GothamBold,
}

----------------------------------------------------------------
-- UTILITY FUNCTIONS
----------------------------------------------------------------

function UIComponents.corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
	return c
end

function UIComponents.pill(parent)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0.5, 0)
	c.Parent = parent
	return c
end

function UIComponents.stroke(parent, thickness, transparency, color)
	local s = Instance.new("UIStroke")
	s.Thickness = thickness
	s.Transparency = transparency or 0
	s.Color = color or UIComponents.Colors.White
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

function UIComponents.pad(parent, left, right, top, bottom)
	local p = Instance.new("UIPadding")
	p.PaddingLeft = UDim.new(0, left or 0)
	p.PaddingRight = UDim.new(0, right or 0)
	p.PaddingTop = UDim.new(0, top or 0)
	p.PaddingBottom = UDim.new(0, bottom or 0)
	p.Parent = parent
	return p
end

function UIComponents.gradient(parent, color1, color2, rotation)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(color1, color2)
	g.Rotation = rotation or 90
	g.Parent = parent
	return g
end

function UIComponents.tween(object, info, properties)
	local t = TweenService:Create(object, info, properties)
	t:Play()
	return t
end

function UIComponents.formatMoney(n)
	if not n then return "$0" end
	if n >= 1000000 then
		return string.format("$%.1fM", n/1000000)
	elseif n >= 1000 then
		return string.format("$%.1fK", n/1000)
	else
		return "$" .. math.floor(n)
	end
end

----------------------------------------------------------------
-- SHADOW COMPONENT
----------------------------------------------------------------

function UIComponents.createShadow(parent, offset, blur, color, transparency)
	-- Create shadow as sibling, not child, to avoid layout issues
	local shadow = Instance.new("ImageLabel")
	shadow.Name = parent.Name .. "_Shadow"
	shadow.Size = UDim2.new(0, parent.AbsoluteSize.X + blur * 2, 0, parent.AbsoluteSize.Y + blur * 2)
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://5554236805"
	shadow.ImageColor3 = color or UIComponents.Colors.Black
	shadow.ImageTransparency = transparency or 0.85
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(23, 23, 277, 277)
	shadow.ZIndex = parent.ZIndex - 1
	
	-- For elements inside layouts, we skip shadow to avoid layout disruption
	-- Only add shadow to elements that have fixed positioning
	if parent.Parent and parent.Parent:FindFirstChildOfClass("UIListLayout") then
		-- Don't add shadow for layout children - it breaks positioning
		shadow:Destroy()
		return nil
	end
	
	shadow.Parent = parent.Parent
	
	-- Position relative to parent
	local function updateShadowPos()
		if shadow and shadow.Parent then
			shadow.Position = UDim2.new(
				parent.Position.X.Scale, 
				parent.Position.X.Offset - blur + (offset or 0),
				parent.Position.Y.Scale,
				parent.Position.Y.Offset - blur + (offset or 4)
			)
			shadow.Size = UDim2.new(0, parent.AbsoluteSize.X + blur * 2, 0, parent.AbsoluteSize.Y + blur * 2)
		end
	end
	
	updateShadowPos()
	parent:GetPropertyChangedSignal("Position"):Connect(updateShadowPos)
	parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateShadowPos)
	
	return shadow
end

----------------------------------------------------------------
-- BITLIFE-STYLE MODAL CARD
-- Premium popup card with colored shell border
----------------------------------------------------------------

function UIComponents.createModalCard(parent, config)
	local C = UIComponents.Colors
	local F = UIComponents.Fonts
	config = config or {}
	
	-- Overlay background
	local overlay = Instance.new("Frame")
	overlay.Name = config.name or "ModalOverlay"
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = C.Black
	overlay.BackgroundTransparency = 0.4
	overlay.Visible = false
	overlay.ZIndex = config.zIndex or 96
	overlay.Parent = parent
	
	-- Click to close area
	local closeArea = Instance.new("TextButton")
	closeArea.Size = UDim2.fromScale(1, 1)
	closeArea.BackgroundTransparency = 1
	closeArea.Text = ""
	closeArea.ZIndex = config.zIndex or 96
	closeArea.Parent = overlay
	
	-- Shadow frame (BitLife-style soft shadow)
	local shadowFrame = Instance.new("Frame")
	shadowFrame.Name = "ShadowFrame"
	shadowFrame.Size = UDim2.new(0.82, 0, 0, 0)
	shadowFrame.AutomaticSize = Enum.AutomaticSize.Y
	shadowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	shadowFrame.Position = UDim2.fromScale(0.5, 0.5)
	shadowFrame.BackgroundColor3 = C.Black
	shadowFrame.BackgroundTransparency = 0.88
	shadowFrame.ZIndex = (config.zIndex or 96) + 1
	shadowFrame.Parent = overlay
	UIComponents.corner(shadowFrame, 30)
	
	-- Outer colored shell (BitLife signature red outline style)
	local shell = Instance.new("Frame")
	shell.Name = "Shell"
	shell.Size = UDim2.new(1, -8, 0, 0)
	shell.AutomaticSize = Enum.AutomaticSize.Y
	shell.AnchorPoint = Vector2.new(0.5, 0.5)
	shell.Position = UDim2.new(0.5, 0, 0.5, -4)
	shell.BackgroundColor3 = config.accentColor or C.Green
	shell.ZIndex = (config.zIndex or 96) + 2
	shell.Parent = shadowFrame
	UIComponents.corner(shell, 26)
	local shellStroke = UIComponents.stroke(shell, 2, 0.3, config.accentDark or C.GreenDark)
	
	-- Inner padding frame
	UIComponents.pad(shell, 4, 4, 4, 4)
	
	-- Inner white card
	local card = Instance.new("Frame")
	card.Name = "Card"
	card.Size = UDim2.new(1, 0, 0, 0)
	card.AutomaticSize = Enum.AutomaticSize.Y
	card.BackgroundColor3 = C.White
	card.ZIndex = (config.zIndex or 96) + 3
	card.Parent = shell
	UIComponents.corner(card, 22)
	
	-- Content container
	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.new(1, 0, 0, 0)
	content.AutomaticSize = Enum.AutomaticSize.Y
	content.BackgroundTransparency = 1
	content.ZIndex = (config.zIndex or 96) + 4
	content.Parent = card
	UIComponents.pad(content, 20, 20, 24, 20)
	
	local layout = Instance.new("UIListLayout")
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Padding = UDim.new(0, 10)
	layout.Parent = content
	
	-- Emoji circle (BitLife-style prominent)
	local emojiFrame = Instance.new("Frame")
	emojiFrame.Name = "EmojiFrame"
	emojiFrame.Size = UDim2.new(0, 64, 0, 64)
	emojiFrame.BackgroundColor3 = config.accentPale or C.GreenPale
	emojiFrame.LayoutOrder = 1
	emojiFrame.ZIndex = (config.zIndex or 96) + 5
	emojiFrame.Parent = content
	UIComponents.corner(emojiFrame, 32)
	
	local emojiLabel = Instance.new("TextLabel")
	emojiLabel.Name = "Emoji"
	emojiLabel.Size = UDim2.fromScale(1, 1)
	emojiLabel.BackgroundTransparency = 1
	emojiLabel.Font = F.Body
	emojiLabel.TextSize = 34
	emojiLabel.Text = config.emoji or "✨"
	emojiLabel.ZIndex = (config.zIndex or 96) + 6
	emojiLabel.Parent = emojiFrame
	
	-- Title (BitLife-style bold)
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, 0, 0, 26)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = F.Title
	titleLabel.TextSize = 20
	titleLabel.TextColor3 = C.Gray900
	titleLabel.Text = config.title or "Result"
	titleLabel.LayoutOrder = 2
	titleLabel.ZIndex = (config.zIndex or 96) + 5
	titleLabel.Parent = content
	
	-- Message (centered text)
	local messageLabel = Instance.new("TextLabel")
	messageLabel.Name = "Message"
	messageLabel.Size = UDim2.new(1, 0, 0, 0)
	messageLabel.AutomaticSize = Enum.AutomaticSize.Y
	messageLabel.BackgroundTransparency = 1
	messageLabel.Font = F.Body
	messageLabel.TextSize = 14
	messageLabel.TextColor3 = C.Gray600
	messageLabel.TextWrapped = true
	messageLabel.LineHeight = 1.35
	messageLabel.Text = config.message or ""
	messageLabel.LayoutOrder = 3
	messageLabel.ZIndex = (config.zIndex or 96) + 5
	messageLabel.Parent = content
	
	-- Spacer
	local spacer = Instance.new("Frame")
	spacer.Size = UDim2.new(1, 0, 0, 4)
	spacer.BackgroundTransparency = 1
	spacer.LayoutOrder = 4
	spacer.Parent = content
	
	-- OK Button (BitLife-style rounded)
	local okBtn = Instance.new("TextButton")
	okBtn.Name = "OkButton"
	okBtn.Size = UDim2.new(1, 0, 0, 46)
	okBtn.BackgroundColor3 = config.accentColor or C.Green
	okBtn.Font = F.Button
	okBtn.TextSize = 16
	okBtn.TextColor3 = C.White
	okBtn.Text = config.buttonText or "Continue"
	okBtn.AutoButtonColor = false
	okBtn.LayoutOrder = 5
	okBtn.ZIndex = (config.zIndex or 96) + 5
	okBtn.Parent = content
	UIComponents.corner(okBtn, 12)
	
	return {
		overlay = overlay,
		shadowFrame = shadowFrame,
		shell = shell,
		shellStroke = shellStroke,
		card = card,
		content = content,
		emojiFrame = emojiFrame,
		emojiLabel = emojiLabel,
		titleLabel = titleLabel,
		messageLabel = messageLabel,
		okButton = okBtn,
		closeArea = closeArea,
	}
end

----------------------------------------------------------------
-- PREMIUM ITEM CARD
-- Beautiful card for list items (jobs, activities, etc)
----------------------------------------------------------------

function UIComponents.createItemCard(parent, config)
	local C = UIComponents.Colors
	local F = UIComponents.Fonts
	config = config or {}
	
	local card = Instance.new("Frame")
	card.Name = config.id or "ItemCard"
	card.Size = UDim2.new(1, 0, 0, config.height or 90)
	card.BackgroundColor3 = C.White
	card.LayoutOrder = config.order or 1
	card.ZIndex = config.zIndex or 82
	card.Parent = parent
	UIComponents.corner(card, 18)
	UIComponents.stroke(card, 1, 0.88, config.highlighted and (config.accentColor or C.Green) or C.Gray200)
	UIComponents.createShadow(card, 2, 8, C.Black, 0.94)
	
	-- Icon container with gradient background
	local iconSize = config.iconSize or 56
	local iconFrame = Instance.new("Frame")
	iconFrame.Name = "IconFrame"
	iconFrame.Size = UDim2.new(0, iconSize, 0, iconSize)
	iconFrame.Position = UDim2.new(0, 16, 0.5, -iconSize/2)
	iconFrame.BackgroundColor3 = config.iconBg or C.BluePale
	iconFrame.ZIndex = (config.zIndex or 82) + 1
	iconFrame.Parent = card
	UIComponents.corner(iconFrame, 14)
	
	if config.iconGradient then
		UIComponents.gradient(iconFrame, config.iconGradient[1], config.iconGradient[2], 135)
	end
	
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Name = "Icon"
	iconLabel.Size = UDim2.fromScale(1, 1)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Font = F.Body
	iconLabel.TextSize = config.iconTextSize or 28
	iconLabel.Text = config.emoji or "📋"
	iconLabel.ZIndex = (config.zIndex or 82) + 2
	iconLabel.Parent = iconFrame
	
	-- Content area
	local contentX = 16 + iconSize + 14
	
	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(0.55, 0, 0, 22)
	titleLabel.Position = UDim2.new(0, contentX, 0, config.titleY or 14)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = F.Title
	titleLabel.TextSize = 16
	titleLabel.TextColor3 = C.Gray900
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
	titleLabel.Text = config.title or "Item"
	titleLabel.ZIndex = (config.zIndex or 82) + 1
	titleLabel.Parent = card
	
	-- Subtitle/Description line
	if config.subtitle then
		local subtitleLabel = Instance.new("TextLabel")
		subtitleLabel.Name = "Subtitle"
		subtitleLabel.Size = UDim2.new(0.55, 0, 0, 18)
		subtitleLabel.Position = UDim2.new(0, contentX, 0, (config.titleY or 14) + 22)
		subtitleLabel.BackgroundTransparency = 1
		subtitleLabel.Font = F.Body
		subtitleLabel.TextSize = 12
		subtitleLabel.TextColor3 = C.Gray500
		subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
		subtitleLabel.Text = config.subtitle
		subtitleLabel.ZIndex = (config.zIndex or 82) + 1
		subtitleLabel.Parent = card
	end
	
	-- Badges container
	local badgesFrame = Instance.new("Frame")
	badgesFrame.Name = "Badges"
	badgesFrame.Size = UDim2.new(0.6, 0, 0, 26)
	badgesFrame.Position = UDim2.new(0, contentX, 1, -38)
	badgesFrame.BackgroundTransparency = 1
	badgesFrame.ZIndex = (config.zIndex or 82) + 1
	badgesFrame.Parent = card
	
	local badgeLayout = Instance.new("UIListLayout")
	badgeLayout.FillDirection = Enum.FillDirection.Horizontal
	badgeLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	badgeLayout.Padding = UDim.new(0, 8)
	badgeLayout.Parent = badgesFrame
	
	-- Action button
	local actionBtn = Instance.new("TextButton")
	actionBtn.Name = "ActionButton"
	actionBtn.Size = UDim2.new(0, config.buttonWidth or 76, 0, config.buttonHeight or 44)
	actionBtn.AnchorPoint = Vector2.new(1, 0.5)
	actionBtn.Position = UDim2.new(1, -14, 0.5, 0)
	actionBtn.BackgroundColor3 = config.buttonColor or C.Blue
	actionBtn.Font = F.Button
	actionBtn.TextSize = 14
	actionBtn.TextColor3 = C.White
	actionBtn.Text = config.buttonText or "Action"
	actionBtn.AutoButtonColor = false
	actionBtn.ZIndex = (config.zIndex or 82) + 1
	actionBtn.Parent = card
	UIComponents.corner(actionBtn, 12)
	
	if config.buttonDisabled then
		actionBtn.BackgroundColor3 = C.Gray300
		actionBtn.TextColor3 = C.Gray500
	end
	
	return {
		card = card,
		iconFrame = iconFrame,
		iconLabel = iconLabel,
		titleLabel = titleLabel,
		badgesFrame = badgesFrame,
		actionButton = actionBtn,
	}
end

----------------------------------------------------------------
-- PREMIUM BADGE
-- Small pill-shaped tag for status/info
----------------------------------------------------------------

function UIComponents.createBadge(parent, config)
	local C = UIComponents.Colors
	local F = UIComponents.Fonts
	config = config or {}
	
	local badge = Instance.new("Frame")
	badge.Name = config.name or "Badge"
	badge.Size = UDim2.new(0, config.width or 80, 0, config.height or 26)
	badge.BackgroundColor3 = config.bgColor or C.GreenPale
	badge.LayoutOrder = config.order or 1
	badge.ZIndex = config.zIndex or 83
	badge.Parent = parent
	UIComponents.pill(badge)
	
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = F.Medium
	label.TextSize = config.textSize or 11
	label.TextColor3 = config.textColor or C.GreenDark
	label.Text = config.text or "Badge"
	label.ZIndex = (config.zIndex or 83) + 1
	label.Parent = badge
	
	return { frame = badge, label = label }
end

----------------------------------------------------------------
-- SCREEN HEADER
-- Premium gradient header with close button
----------------------------------------------------------------

function UIComponents.createScreenHeader(parent, config)
	local C = UIComponents.Colors
	local F = UIComponents.Fonts
	config = config or {}
	
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, -16, 0, 64)
	header.Position = UDim2.new(0, 8, 0, 44) -- Offset for Roblox UI
	header.BackgroundColor3 = config.color or C.Blue
	header.ZIndex = config.zIndex or 85
	header.Parent = parent
	UIComponents.corner(header, 18)
	UIComponents.createShadow(header, 4, 12, C.Black, 0.9)
	
	if config.gradient ~= false then
		UIComponents.gradient(header, config.color or C.Blue, config.colorDark or C.BlueDark, 90)
	end
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -110, 1, 0)
	title.Position = UDim2.new(0, 20, 0, 0)
	title.BackgroundTransparency = 1
	title.Font = F.Title
	title.TextSize = 20
	title.TextColor3 = C.White
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = config.title or "Screen"
	title.ZIndex = (config.zIndex or 85) + 1
	title.Parent = header
	
	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.Size = UDim2.new(0, 42, 0, 42)
	closeBtn.AnchorPoint = Vector2.new(1, 0.5)
	closeBtn.Position = UDim2.new(1, -10, 0.5, 0)
	closeBtn.BackgroundColor3 = C.White
	closeBtn.BackgroundTransparency = 0.1
	closeBtn.Font = F.Title
	closeBtn.TextSize = 22
	closeBtn.TextColor3 = config.colorDark or C.BlueDark
	closeBtn.Text = "X"
	closeBtn.AutoButtonColor = false
	closeBtn.ZIndex = (config.zIndex or 85) + 1
	closeBtn.Parent = header
	UIComponents.corner(closeBtn, 21)
	
	return { header = header, title = title, closeButton = closeBtn }
end

----------------------------------------------------------------
-- INFO BAR
-- Row of info chips (age, money, status)
----------------------------------------------------------------

function UIComponents.createInfoBar(parent, config)
	local C = UIComponents.Colors
	config = config or {}
	
	local bar = Instance.new("Frame")
	bar.Name = "InfoBar"
	bar.Size = UDim2.new(1, -16, 0, 52)
	bar.Position = UDim2.new(0, 8, 0, config.topOffset or 116)
	bar.BackgroundColor3 = C.White
	bar.ZIndex = config.zIndex or 84
	bar.Parent = parent
	UIComponents.corner(bar, 14)
	UIComponents.stroke(bar, 1, 0.9, C.Gray200)
	UIComponents.createShadow(bar, 2, 6, C.Black, 0.95)
	
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 10)
	layout.Parent = bar
	
	return bar
end

----------------------------------------------------------------
-- INFO CHIP
-- Single stat/info display
----------------------------------------------------------------

function UIComponents.createInfoChip(parent, config)
	local C = UIComponents.Colors
	local F = UIComponents.Fonts
	config = config or {}
	
	local chip = Instance.new("Frame")
	chip.Name = config.name or "InfoChip"
	chip.Size = UDim2.new(0, config.width or 100, 0, 40)
	chip.BackgroundColor3 = config.bgColor or C.BluePale
	chip.LayoutOrder = config.order or 1
	chip.ZIndex = config.zIndex or 85
	chip.Parent = parent
	UIComponents.corner(chip, 12)
	
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Name = "Icon"
	iconLabel.Size = UDim2.new(0, 28, 1, 0)
	iconLabel.Position = UDim2.new(0, 8, 0, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Font = F.Body
	iconLabel.TextSize = 16
	iconLabel.Text = config.icon or "📋"
	iconLabel.ZIndex = (config.zIndex or 85) + 1
	iconLabel.Parent = chip
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Text"
	textLabel.Size = UDim2.new(1, -40, 1, 0)
	textLabel.Position = UDim2.new(0, 34, 0, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = F.Button
	textLabel.TextSize = 12
	textLabel.TextColor3 = config.textColor or C.BlueDark
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Text = config.text or "Info"
	textLabel.ZIndex = (config.zIndex or 85) + 1
	textLabel.Parent = chip
	
	return { chip = chip, icon = iconLabel, text = textLabel }
end

----------------------------------------------------------------
-- TAB BAR
-- Premium segmented control
----------------------------------------------------------------

function UIComponents.createTabBar(parent, config)
	local C = UIComponents.Colors
	local F = UIComponents.Fonts
	config = config or {}
	
	local bar = Instance.new("Frame")
	bar.Name = "TabBar"
	bar.Size = UDim2.new(1, -16, 0, 52)
	bar.Position = UDim2.new(0, 8, 0, config.topOffset or 176)
	bar.BackgroundColor3 = C.Gray100
	bar.ZIndex = config.zIndex or 84
	bar.Parent = parent
	UIComponents.corner(bar, 14)
	UIComponents.pad(bar, 5, 5, 5, 5)
	
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 6)
	layout.Parent = bar
	
	return bar
end

----------------------------------------------------------------
-- TAB BUTTON
----------------------------------------------------------------

function UIComponents.createTabButton(parent, config)
	local C = UIComponents.Colors
	local F = UIComponents.Fonts
	config = config or {}
	
	local btn = Instance.new("TextButton")
	btn.Name = config.id or "Tab"
	btn.Size = UDim2.new(config.width or 0.3, 0, 1, 0)
	btn.BackgroundColor3 = config.active and (config.color or C.Blue) or C.White
	btn.Font = F.Button
	btn.TextSize = 13
	btn.TextColor3 = config.active and C.White or C.Gray600
	btn.Text = config.text or "Tab"
	btn.AutoButtonColor = false
	btn.LayoutOrder = config.order or 1
	btn.ZIndex = (config.zIndex or 84) + 1
	btn.Parent = parent
	UIComponents.corner(btn, 10)
	
	return btn
end

----------------------------------------------------------------
-- SCROLLING CONTENT AREA
----------------------------------------------------------------

function UIComponents.createScrollArea(parent, config)
	local C = UIComponents.Colors
	config = config or {}
	
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "ContentScroll"
	scroll.Size = UDim2.new(1, -16, 1, -(config.topOffset or 240))
	scroll.Position = UDim2.new(0, 8, 0, config.topOffset or 240)
	scroll.BackgroundTransparency = 1
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ScrollBarThickness = 4
	scroll.ScrollBarImageColor3 = C.Gray300
	scroll.ZIndex = config.zIndex or 81
	scroll.Parent = parent
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 14)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scroll
	
	return scroll
end

----------------------------------------------------------------
-- SECTION CARD
-- Container for grouped items
----------------------------------------------------------------

function UIComponents.createSectionCard(parent, config)
	local C = UIComponents.Colors
	local F = UIComponents.Fonts
	config = config or {}
	
	local card = Instance.new("Frame")
	card.Name = config.name or "Section"
	card.Size = UDim2.new(1, 0, 0, 0)
	card.AutomaticSize = Enum.AutomaticSize.Y
	card.BackgroundColor3 = C.White
	card.LayoutOrder = config.order or 1
	card.ZIndex = config.zIndex or 82
	card.Parent = parent
	UIComponents.corner(card, 20)
	UIComponents.stroke(card, 1, 0.88, C.Gray200)
	UIComponents.createShadow(card, 3, 10, C.Black, 0.93)
	UIComponents.pad(card, 16, 16, 16, 18)
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 12)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = card
	
	-- Section header
	if config.title then
		local headerFrame = Instance.new("Frame")
		headerFrame.Name = "Header"
		headerFrame.Size = UDim2.new(1, 0, 0, 36)
		headerFrame.BackgroundTransparency = 1
		headerFrame.LayoutOrder = 0
		headerFrame.ZIndex = (config.zIndex or 82) + 1
		headerFrame.Parent = card
		
		local badge = Instance.new("Frame")
		badge.Size = UDim2.new(0, config.badgeWidth or 100, 0, 32)
		badge.BackgroundColor3 = config.accentColor or C.Blue
		badge.ZIndex = (config.zIndex or 82) + 2
		badge.Parent = headerFrame
		UIComponents.pill(badge)
		
		local badgeLabel = Instance.new("TextLabel")
		badgeLabel.Size = UDim2.fromScale(1, 1)
		badgeLabel.BackgroundTransparency = 1
		badgeLabel.Font = F.Button
		badgeLabel.TextSize = 14
		badgeLabel.TextColor3 = C.White
		badgeLabel.Text = config.title
		badgeLabel.ZIndex = (config.zIndex or 82) + 3
		badgeLabel.Parent = badge
		
		if config.subtitle then
			local subtitleLabel = Instance.new("TextLabel")
			subtitleLabel.Size = UDim2.new(0.5, 0, 1, 0)
			subtitleLabel.Position = UDim2.new(0, (config.badgeWidth or 100) + 12, 0, 0)
			subtitleLabel.BackgroundTransparency = 1
			subtitleLabel.Font = F.Medium
			subtitleLabel.TextSize = 13
			subtitleLabel.TextColor3 = C.Gray400
			subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
			subtitleLabel.Text = config.subtitle
			subtitleLabel.ZIndex = (config.zIndex or 82) + 2
			subtitleLabel.Parent = headerFrame
		end
	end
	
	return card
end

----------------------------------------------------------------
-- ANIMATION HELPERS
----------------------------------------------------------------

function UIComponents.showModal(modal, startY)
	startY = startY or 40
	modal.overlay.Visible = true
	
	-- Use shadowFrame if available, otherwise fall back to shell
	local mainFrame = modal.shadowFrame or modal.shell
	mainFrame.Position = UDim2.new(0.5, 0, 0.5, startY)
	mainFrame.BackgroundTransparency = 1
	modal.shell.BackgroundTransparency = 1
	modal.card.BackgroundTransparency = 1
	
	UIComponents.tween(mainFrame, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 0.88
	})
	UIComponents.tween(modal.shell, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0
	})
	UIComponents.tween(modal.card, TweenInfo.new(0.25), {
		BackgroundTransparency = 0
	})
end

function UIComponents.hideModal(modal, callback)
	local mainFrame = modal.shadowFrame or modal.shell
	
	local t = UIComponents.tween(mainFrame, TweenInfo.new(0.2), {
		Position = UDim2.new(0.5, 0, 0.5, 40),
		BackgroundTransparency = 1
	})
	UIComponents.tween(modal.shell, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
	UIComponents.tween(modal.card, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
	
	t.Completed:Connect(function()
		modal.overlay.Visible = false
		if callback then callback() end
	end)
end

function UIComponents.slideInScreen(overlay, direction)
	direction = direction or "right"
	overlay.Visible = true
	
	if direction == "right" then
		overlay.Position = UDim2.new(1, 0, 0, 0)
	elseif direction == "left" then
		overlay.Position = UDim2.new(-1, 0, 0, 0)
	elseif direction == "up" then
		overlay.Position = UDim2.new(0, 0, 1, 0)
	else
		overlay.Position = UDim2.new(0, 0, -1, 0)
	end
	
	UIComponents.tween(overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0, 0)
	})
end

function UIComponents.slideOutScreen(overlay, direction, callback)
	direction = direction or "right"
	
	local targetPos
	if direction == "right" then
		targetPos = UDim2.new(1, 0, 0, 0)
	elseif direction == "left" then
		targetPos = UDim2.new(-1, 0, 0, 0)
	elseif direction == "up" then
		targetPos = UDim2.new(0, 0, -1, 0)
	else
		targetPos = UDim2.new(0, 0, 1, 0)
	end
	
	local t = UIComponents.tween(overlay, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		Position = targetPos
	})
	
	t.Completed:Connect(function()
		overlay.Visible = false
		if callback then callback() end
	end)
end

function UIComponents.pulseButton(btn, scale)
	scale = scale or 0.95
	local origSize = btn.Size
	UIComponents.tween(btn, TweenInfo.new(0.08), {
		Size = UDim2.new(origSize.X.Scale * scale, origSize.X.Offset, origSize.Y.Scale * scale, origSize.Y.Offset)
	}).Completed:Wait()
	UIComponents.tween(btn, TweenInfo.new(0.1), { Size = origSize })
end

return UIComponents
