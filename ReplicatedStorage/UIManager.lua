-- UIManager.lua
-- Centralized UI management for BitLife-style cards, toasts, and popups
-- Ensures consistent visual style across all screens and interactions

local TweenService = game:GetService("TweenService")

local UIManager = {}
UIManager.__index = UIManager

----------------------------------------------------------------------
-- PREMIUM COLOR PALETTE
----------------------------------------------------------------------

UIManager.Colors = {
	-- Primary Blues
	Blue = Color3.fromRGB(37, 99, 235),
	BlueDark = Color3.fromRGB(29, 78, 216),
	BlueLight = Color3.fromRGB(96, 165, 250),
	BluePale = Color3.fromRGB(219, 234, 254),

	-- Greens
	Green = Color3.fromRGB(34, 197, 94),
	GreenDark = Color3.fromRGB(22, 163, 74),
	GreenLight = Color3.fromRGB(74, 222, 128),
	GreenPale = Color3.fromRGB(220, 252, 231),

	-- Reds
	Red = Color3.fromRGB(239, 68, 68),
	RedDark = Color3.fromRGB(220, 38, 38),
	RedLight = Color3.fromRGB(252, 129, 129),
	RedPale = Color3.fromRGB(254, 226, 226),

	-- Amber/Orange
	Amber = Color3.fromRGB(245, 158, 11),
	AmberDark = Color3.fromRGB(217, 119, 6),
	AmberLight = Color3.fromRGB(251, 191, 36),
	AmberPale = Color3.fromRGB(254, 243, 199),
	Orange = Color3.fromRGB(249, 115, 22),

	-- Purple
	Purple = Color3.fromRGB(147, 51, 234),
	PurpleDark = Color3.fromRGB(124, 58, 237),
	PurplePale = Color3.fromRGB(243, 232, 255),

	-- Pink
	Pink = Color3.fromRGB(236, 72, 153),
	PinkDark = Color3.fromRGB(219, 39, 119),
	PinkPale = Color3.fromRGB(252, 231, 243),

	-- Cyan/Teal
	Cyan = Color3.fromRGB(6, 182, 212),
	CyanDark = Color3.fromRGB(8, 145, 178),
	CyanPale = Color3.fromRGB(207, 250, 254),
	Teal = Color3.fromRGB(20, 184, 166),
	TealDark = Color3.fromRGB(13, 148, 136),

	-- Neutrals
	White = Color3.fromRGB(255, 255, 255),
	OffWhite = Color3.fromRGB(250, 250, 250),
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

	-- Nav
	NavBlue = Color3.fromRGB(30, 58, 138),
	NavDark = Color3.fromRGB(23, 37, 84),

	-- Category colors
	Education = Color3.fromRGB(59, 130, 246),  -- Blue
	Work = Color3.fromRGB(16, 185, 129),       -- Green
	Relationship = Color3.fromRGB(244, 114, 182), -- Pink
	Crime = Color3.fromRGB(239, 68, 68),       -- Red
	Health = Color3.fromRGB(239, 68, 68),      -- Red
	Social = Color3.fromRGB(168, 85, 247),     -- Purple
	Money = Color3.fromRGB(34, 197, 94),       -- Green
	Random = Color3.fromRGB(107, 114, 128),    -- Gray
}

UIManager.Fonts = {
	Title = Enum.Font.GothamBold,
	Body = Enum.Font.Gotham,
	Medium = Enum.Font.GothamMedium,
	Button = Enum.Font.GothamBold,
}

----------------------------------------------------------------------
-- CATEGORY CONFIG
----------------------------------------------------------------------

UIManager.CategoryConfig = {
	education = { emoji = "📚", color = UIManager.Colors.Blue, label = "Education" },
	school = { emoji = "🏫", color = UIManager.Colors.Blue, label = "School" },
	work = { emoji = "💼", color = UIManager.Colors.Teal, label = "Work" },
	job = { emoji = "💼", color = UIManager.Colors.Teal, label = "Job" },
	career = { emoji = "📈", color = UIManager.Colors.Teal, label = "Career" },
	family = { emoji = "👨‍👩‍👧", color = UIManager.Colors.Pink, label = "Family" },
	relationship = { emoji = "💕", color = UIManager.Colors.Pink, label = "Relationship" },
	social = { emoji = "🎉", color = UIManager.Colors.Purple, label = "Social" },
	friend = { emoji = "👋", color = UIManager.Colors.Purple, label = "Friend" },
	classmate = { emoji = "🎓", color = UIManager.Colors.Blue, label = "Classmate" },
	crime = { emoji = "💀", color = UIManager.Colors.Red, label = "Crime" },
	prison = { emoji = "⛓️", color = UIManager.Colors.Gray700, label = "Prison" },
	health = { emoji = "🏥", color = UIManager.Colors.Red, label = "Health" },
	money = { emoji = "💰", color = UIManager.Colors.Green, label = "Money" },
	random = { emoji = "🎲", color = UIManager.Colors.Amber, label = "Life Event" },
	political = { emoji = "🏛️", color = UIManager.Colors.NavBlue, label = "Politics" },
	racing = { emoji = "🏎️", color = UIManager.Colors.Orange, label = "Racing" },
	art = { emoji = "🎨", color = UIManager.Colors.Purple, label = "Art" },
	hacker = { emoji = "💻", color = UIManager.Colors.Cyan, label = "Hacking" },
	teacher = { emoji = "📖", color = UIManager.Colors.Amber, label = "Teaching" },
}

----------------------------------------------------------------------
-- HELPER FUNCTIONS
----------------------------------------------------------------------

local C = UIManager.Colors
local F = UIManager.Fonts

local function corner(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = p
	return c
end

local function pill(p)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0.5, 0)
	c.Parent = p
	return c
end

local function stroke(p, t, tr, col)
	local s = Instance.new("UIStroke")
	s.Thickness = t
	s.Transparency = tr or 0
	s.Color = col or C.White
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = p
	return s
end

local function pad(p, l, r, t, b)
	local pd = Instance.new("UIPadding")
	pd.PaddingLeft = UDim.new(0, l or 0)
	pd.PaddingRight = UDim.new(0, r or 0)
	pd.PaddingTop = UDim.new(0, t or 0)
	pd.PaddingBottom = UDim.new(0, b or 0)
	pd.Parent = p
	return pd
end

local function tween(o, i, p)
	local t = TweenService:Create(o, i, p)
	t:Play()
	return t
end

local function createShadow(parent, offset, blur, color, transparency)
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.Size = UDim2.new(1, blur*2, 1, blur*2)
	shadow.Position = UDim2.new(0, -blur + (offset or 0), 0, -blur + (offset or 4))
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://5554236805"
	shadow.ImageColor3 = color or C.Black
	shadow.ImageTransparency = transparency or 0.85
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(23, 23, 277, 277)
	shadow.ZIndex = parent.ZIndex - 1
	shadow.Parent = parent
	return shadow
end

-- Expose helpers
UIManager.corner = corner
UIManager.pill = pill
UIManager.stroke = stroke
UIManager.pad = pad
UIManager.tween = tween
UIManager.createShadow = createShadow

----------------------------------------------------------------------
-- CONSTRUCTOR
----------------------------------------------------------------------

function UIManager.new(screenGui)
	local self = setmetatable({}, UIManager)
	self.screenGui = screenGui
	self.toastQueue = {}
	self.activeToast = nil
	self.statToasts = {}
	return self
end

----------------------------------------------------------------------
-- GET CATEGORY INFO
----------------------------------------------------------------------

function UIManager:getCategoryInfo(category)
	category = category and string.lower(category) or "random"
	return UIManager.CategoryConfig[category] or UIManager.CategoryConfig.random
end

----------------------------------------------------------------------
-- CREATE BITLIFE-STYLE EVENT CARD
----------------------------------------------------------------------

function UIManager:createEventCard(config)
	--[[
	config = {
		parent = Frame,
		zIndex = number,
		category = string,
		headerLabel = string (optional),
		emoji = string,
		title = string,
		text = string,
		choices = { { text = string }, ... },
		showSurpriseMe = boolean,
		onChoice = function(choiceIndex),
		onClose = function(),
	}
	]]
	
	local categoryInfo = self:getCategoryInfo(config.category)
	local accentColor = categoryInfo.color
	local accentDark = accentColor  -- We can darken later if needed
	
	-- Overlay
	local overlay = Instance.new("Frame")
	overlay.Name = "EventCardOverlay"
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = C.Black
	overlay.BackgroundTransparency = 0.45
	overlay.ZIndex = config.zIndex or 60
	overlay.Parent = config.parent
	
	-- Shadow frame
	local shadowFrame = Instance.new("Frame")
	shadowFrame.Name = "ShadowFrame"
	shadowFrame.Size = UDim2.new(0.92, 0, 0, 0)
	shadowFrame.AutomaticSize = Enum.AutomaticSize.Y
	shadowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	shadowFrame.Position = UDim2.fromScale(0.5, 0.5)
	shadowFrame.BackgroundColor3 = C.Black
	shadowFrame.BackgroundTransparency = 0.92
	shadowFrame.ZIndex = config.zIndex + 1
	shadowFrame.Parent = overlay
	corner(shadowFrame, 28)
	
	-- Colored shell (outer border)
	local shell = Instance.new("Frame")
	shell.Name = "Shell"
	shell.Size = UDim2.new(1, -6, 1, -6)
	shell.Position = UDim2.new(0, 3, 0, 3)
	shell.BackgroundColor3 = accentColor
	shell.ZIndex = config.zIndex + 2
	shell.Parent = shadowFrame
	corner(shell, 26)
	stroke(shell, 2, 0.3, accentDark)
	createShadow(shell, 4, 16, C.Black, 0.88)
	
	-- Inner white card
	local card = Instance.new("Frame")
	card.Name = "Card"
	card.Size = UDim2.new(1, -10, 1, -10)
	card.Position = UDim2.new(0, 5, 0, 5)
	card.BackgroundColor3 = C.White
	card.ZIndex = config.zIndex + 3
	card.Parent = shell
	corner(card, 22)
	
	-- Category header strip
	local headerStrip = Instance.new("Frame")
	headerStrip.Name = "HeaderStrip"
	headerStrip.Size = UDim2.new(1, 0, 0, 36)
	headerStrip.BackgroundColor3 = accentColor
	headerStrip.ZIndex = config.zIndex + 4
	headerStrip.Parent = card
	corner(headerStrip, 22)
	
	-- Fix bottom corners of header
	local headerFix = Instance.new("Frame")
	headerFix.Size = UDim2.new(1, 0, 0, 18)
	headerFix.Position = UDim2.new(0, 0, 0, 20)
	headerFix.BackgroundColor3 = accentColor
	headerFix.ZIndex = config.zIndex + 4
	headerFix.Parent = headerStrip
	
	-- Header text
	local headerLabel = Instance.new("TextLabel")
	headerLabel.Size = UDim2.new(1, 0, 1, 0)
	headerLabel.BackgroundTransparency = 1
	headerLabel.Font = F.Button
	headerLabel.TextSize = 13
	headerLabel.TextColor3 = C.White
	headerLabel.Text = (categoryInfo.emoji .. " " .. (config.headerLabel or categoryInfo.label)):upper()
	headerLabel.ZIndex = config.zIndex + 5
	headerLabel.Parent = headerStrip
	
	-- Content container
	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.new(1, 0, 0, 0)
	content.AutomaticSize = Enum.AutomaticSize.Y
	content.Position = UDim2.new(0, 0, 0, 36)
	content.BackgroundTransparency = 1
	content.ZIndex = config.zIndex + 4
	content.Parent = card
	pad(content, 20, 20, 16, 20)
	
	local contentLayout = Instance.new("UIListLayout")
	contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	contentLayout.Padding = UDim.new(0, 12)
	contentLayout.Parent = content
	
	-- Emoji
	local emojiLabel = Instance.new("TextLabel")
	emojiLabel.Name = "Emoji"
	emojiLabel.Size = UDim2.new(0, 70, 0, 70)
	emojiLabel.BackgroundTransparency = 1
	emojiLabel.Font = F.Body
	emojiLabel.TextSize = 56
	emojiLabel.Text = config.emoji or "📋"
	emojiLabel.LayoutOrder = 1
	emojiLabel.ZIndex = config.zIndex + 5
	emojiLabel.Parent = content
	
	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, 0, 0, 0)
	titleLabel.AutomaticSize = Enum.AutomaticSize.Y
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = F.Title
	titleLabel.TextSize = 26
	titleLabel.TextColor3 = C.Gray900
	titleLabel.TextWrapped = true
	titleLabel.Text = config.title or "Event"
	titleLabel.LayoutOrder = 2
	titleLabel.ZIndex = config.zIndex + 5
	titleLabel.Parent = content
	
	-- Body text
	local bodyLabel = Instance.new("TextLabel")
	bodyLabel.Name = "Body"
	bodyLabel.Size = UDim2.new(1, 0, 0, 0)
	bodyLabel.AutomaticSize = Enum.AutomaticSize.Y
	bodyLabel.BackgroundTransparency = 1
	bodyLabel.Font = F.Body
	bodyLabel.TextSize = 17
	bodyLabel.TextColor3 = C.Gray600
	bodyLabel.TextWrapped = true
	bodyLabel.LineHeight = 1.4
	bodyLabel.Text = config.text or ""
	bodyLabel.LayoutOrder = 3
	bodyLabel.ZIndex = config.zIndex + 5
	bodyLabel.Parent = content
	
	-- Spacer
	local spacer = Instance.new("Frame")
	spacer.Size = UDim2.new(1, 0, 0, 8)
	spacer.BackgroundTransparency = 1
	spacer.LayoutOrder = 4
	spacer.Parent = content
	
	-- Choices container
	local choicesContainer = Instance.new("Frame")
	choicesContainer.Name = "Choices"
	choicesContainer.Size = UDim2.new(1, 0, 0, 0)
	choicesContainer.AutomaticSize = Enum.AutomaticSize.Y
	choicesContainer.BackgroundTransparency = 1
	choicesContainer.LayoutOrder = 5
	choicesContainer.ZIndex = config.zIndex + 5
	choicesContainer.Parent = content
	
	local choiceLayout = Instance.new("UIListLayout")
	choiceLayout.Padding = UDim.new(0, 10)
	choiceLayout.Parent = choicesContainer
	
	local choiceButtons = {}
	
	for i, choice in ipairs(config.choices or {}) do
		local btn = Instance.new("TextButton")
		btn.Name = "Choice" .. i
		btn.Size = UDim2.new(1, 0, 0, 52)
		btn.BackgroundColor3 = accentColor
		btn.Font = F.Button
		btn.TextSize = 16
		btn.TextColor3 = C.White
		btn.TextWrapped = true
		btn.Text = choice.text or ("Choice " .. i)
		btn.AutoButtonColor = false
		btn.LayoutOrder = i
		btn.ZIndex = config.zIndex + 6
		btn.Parent = choicesContainer
		corner(btn, 14)
		
		-- Hover effect
		btn.MouseEnter:Connect(function()
			tween(btn, TweenInfo.new(0.1), { 
				BackgroundColor3 = accentDark,
				Size = UDim2.new(1, 0, 0, 54),
			})
		end)
		btn.MouseLeave:Connect(function()
			tween(btn, TweenInfo.new(0.1), { 
				BackgroundColor3 = accentColor,
				Size = UDim2.new(1, 0, 0, 52),
			})
		end)
		
		btn.MouseButton1Click:Connect(function()
			if config.onChoice then
				config.onChoice(i)
			end
		end)
		
		table.insert(choiceButtons, btn)
	end
	
	-- Surprise Me button
	if config.showSurpriseMe then
		local surpriseBtn = Instance.new("TextButton")
		surpriseBtn.Name = "SurpriseMe"
		surpriseBtn.Size = UDim2.new(1, 0, 0, 36)
		surpriseBtn.BackgroundTransparency = 1
		surpriseBtn.Font = F.Medium
		surpriseBtn.TextSize = 14
		surpriseBtn.TextColor3 = C.Gray500
		surpriseBtn.Text = "🎲 Surprise me!"
		surpriseBtn.AutoButtonColor = false
		surpriseBtn.LayoutOrder = #(config.choices or {}) + 1
		surpriseBtn.ZIndex = config.zIndex + 6
		surpriseBtn.Parent = choicesContainer
		
		surpriseBtn.MouseEnter:Connect(function()
			tween(surpriseBtn, TweenInfo.new(0.1), { TextColor3 = accentColor })
		end)
		surpriseBtn.MouseLeave:Connect(function()
			tween(surpriseBtn, TweenInfo.new(0.1), { TextColor3 = C.Gray500 })
		end)
		
		surpriseBtn.MouseButton1Click:Connect(function()
			local randomChoice = math.random(1, #(config.choices or {1}))
			if config.onChoice then
				config.onChoice(randomChoice)
			end
		end)
	end
	
	-- Animation in
	shadowFrame.Position = UDim2.new(0.5, 0, 0.5, 50)
	shadowFrame.BackgroundTransparency = 1
	shell.BackgroundTransparency = 1
	card.BackgroundTransparency = 1
	overlay.BackgroundTransparency = 1
	
	tween(overlay, TweenInfo.new(0.2), { BackgroundTransparency = 0.45 })
	tween(shadowFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 0.92,
	})
	tween(shell, TweenInfo.new(0.25), { BackgroundTransparency = 0 })
	tween(card, TweenInfo.new(0.25), { BackgroundTransparency = 0 })
	
	return {
		overlay = overlay,
		shadowFrame = shadowFrame,
		shell = shell,
		card = card,
		emoji = emojiLabel,
		title = titleLabel,
		body = bodyLabel,
		choiceButtons = choiceButtons,
		accentColor = accentColor,
		
		hide = function()
			tween(overlay, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
			tween(shadowFrame, TweenInfo.new(0.2), {
				Position = UDim2.new(0.5, 0, 0.5, 40),
				BackgroundTransparency = 1,
			})
			tween(shell, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
			tween(card, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
			
			task.delay(0.2, function()
				if overlay then
					overlay:Destroy()
				end
			end)
			
			if config.onClose then
				config.onClose()
			end
		end,
		
		destroy = function()
			if overlay then
				overlay:Destroy()
			end
		end,
	}
end

----------------------------------------------------------------------
-- CREATE RESULT CARD (Success/Failure popup)
----------------------------------------------------------------------

function UIManager:createResultCard(config)
	--[[
	config = {
		parent = Frame,
		zIndex = number,
		success = boolean,
		emoji = string,
		title = string,
		body = string,
		statChanges = { happiness = number, health = number, ... },
		moneyChange = number,
		onDismiss = function(),
	}
	]]
	
	local isPositive = config.success ~= false
	local accentColor = isPositive and C.Green or C.Red
	local accentDark = isPositive and C.GreenDark or C.RedDark
	local accentPale = isPositive and C.GreenPale or C.RedPale
	
	-- Overlay
	local overlay = Instance.new("Frame")
	overlay.Name = "ResultOverlay"
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = C.Black
	overlay.BackgroundTransparency = 0.5
	overlay.ZIndex = config.zIndex or 80
	overlay.Parent = config.parent
	
	-- Click outside to close
	local closeArea = Instance.new("TextButton")
	closeArea.Size = UDim2.fromScale(1, 1)
	closeArea.BackgroundTransparency = 1
	closeArea.Text = ""
	closeArea.ZIndex = config.zIndex
	closeArea.Parent = overlay
	
	-- Shadow frame
	local shadowFrame = Instance.new("Frame")
	shadowFrame.Size = UDim2.new(0.88, 0, 0, 0)
	shadowFrame.AutomaticSize = Enum.AutomaticSize.Y
	shadowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	shadowFrame.Position = UDim2.fromScale(0.5, 0.5)
	shadowFrame.BackgroundColor3 = C.Black
	shadowFrame.BackgroundTransparency = 0.92
	shadowFrame.ZIndex = config.zIndex + 1
	shadowFrame.Parent = overlay
	corner(shadowFrame, 26)
	
	-- Colored shell
	local shell = Instance.new("Frame")
	shell.Size = UDim2.new(1, -6, 1, -6)
	shell.Position = UDim2.new(0, 3, 0, 3)
	shell.BackgroundColor3 = accentColor
	shell.ZIndex = config.zIndex + 2
	shell.Parent = shadowFrame
	corner(shell, 24)
	stroke(shell, 2, 0.3, accentDark)
	createShadow(shell, 4, 14, C.Black, 0.9)
	
	-- Inner white card
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, -8, 1, -8)
	card.Position = UDim2.new(0, 4, 0, 4)
	card.BackgroundColor3 = C.White
	card.ZIndex = config.zIndex + 3
	card.Parent = shell
	corner(card, 20)
	pad(card, 20, 20, 20, 20)
	
	local cardLayout = Instance.new("UIListLayout")
	cardLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	cardLayout.Padding = UDim.new(0, 10)
	cardLayout.Parent = card
	
	-- Emoji circle
	local emojiCircle = Instance.new("Frame")
	emojiCircle.Size = UDim2.new(0, 72, 0, 72)
	emojiCircle.BackgroundColor3 = accentPale
	emojiCircle.LayoutOrder = 1
	emojiCircle.ZIndex = config.zIndex + 4
	emojiCircle.Parent = card
	corner(emojiCircle, 36)
	
	local emojiLabel = Instance.new("TextLabel")
	emojiLabel.Size = UDim2.fromScale(1, 1)
	emojiLabel.BackgroundTransparency = 1
	emojiLabel.Font = F.Body
	emojiLabel.TextSize = 40
	emojiLabel.Text = config.emoji or (isPositive and "✅" or "❌")
	emojiLabel.ZIndex = config.zIndex + 5
	emojiLabel.Parent = emojiCircle
	
	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0, 28)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = F.Title
	titleLabel.TextSize = 22
	titleLabel.TextColor3 = C.Gray900
	titleLabel.Text = config.title or (isPositive and "Success!" or "Failed")
	titleLabel.LayoutOrder = 2
	titleLabel.ZIndex = config.zIndex + 4
	titleLabel.Parent = card
	
	-- Body
	if config.body and config.body ~= "" then
		local bodyLabel = Instance.new("TextLabel")
		bodyLabel.Size = UDim2.new(1, 0, 0, 0)
		bodyLabel.AutomaticSize = Enum.AutomaticSize.Y
		bodyLabel.BackgroundTransparency = 1
		bodyLabel.Font = F.Body
		bodyLabel.TextSize = 15
		bodyLabel.TextColor3 = C.Gray600
		bodyLabel.TextWrapped = true
		bodyLabel.LineHeight = 1.4
		bodyLabel.Text = config.body
		bodyLabel.LayoutOrder = 3
		bodyLabel.ZIndex = config.zIndex + 4
		bodyLabel.Parent = card
	end
	
	-- Stat changes
	local statChanges = config.statChanges or {}
	local statOrder = { "Happiness", "Health", "Smarts", "Looks" }
	local statIcons = { Happiness = "😀", Health = "❤️", Smarts = "🧠", Looks = "💄" }
	
	local hasChanges = false
	for _, stat in ipairs(statOrder) do
		local delta = statChanges[stat] or statChanges[string.lower(stat)]
		if delta and delta ~= 0 then
			hasChanges = true
			
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, 0, 0, 24)
			row.BackgroundTransparency = 1
			row.LayoutOrder = 4 + _
			row.ZIndex = config.zIndex + 4
			row.Parent = card
			
			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(0.6, 0, 1, 0)
			lbl.BackgroundTransparency = 1
			lbl.Font = F.Medium
			lbl.TextSize = 14
			lbl.TextColor3 = C.Gray600
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Text = (statIcons[stat] or "📊") .. " " .. stat
			lbl.ZIndex = config.zIndex + 5
			lbl.Parent = row
			
			local val = Instance.new("TextLabel")
			val.Size = UDim2.new(0.4, 0, 1, 0)
			val.Position = UDim2.new(0.6, 0, 0, 0)
			val.BackgroundTransparency = 1
			val.Font = F.Title
			val.TextSize = 14
			val.TextColor3 = delta > 0 and C.Green or C.Red
			val.TextXAlignment = Enum.TextXAlignment.Right
			val.Text = (delta > 0 and "+" or "") .. delta
			val.ZIndex = config.zIndex + 5
			val.Parent = row
		end
	end
	
	-- Money change
	local moneyChange = config.moneyChange
	if moneyChange and moneyChange ~= 0 then
		hasChanges = true
		
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 24)
		row.BackgroundTransparency = 1
		row.LayoutOrder = 10
		row.ZIndex = config.zIndex + 4
		row.Parent = card
		
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0.6, 0, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.Font = F.Medium
		lbl.TextSize = 14
		lbl.TextColor3 = C.Gray600
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Text = "💵 Money"
		lbl.ZIndex = config.zIndex + 5
		lbl.Parent = row
		
		local formatted = "$" .. tostring(math.abs(moneyChange))
		if math.abs(moneyChange) >= 1000000 then
			formatted = string.format("$%.1fM", math.abs(moneyChange) / 1000000)
		elseif math.abs(moneyChange) >= 1000 then
			formatted = string.format("$%.1fK", math.abs(moneyChange) / 1000)
		end
		
		local val = Instance.new("TextLabel")
		val.Size = UDim2.new(0.4, 0, 1, 0)
		val.Position = UDim2.new(0.6, 0, 0, 0)
		val.BackgroundTransparency = 1
		val.Font = F.Title
		val.TextSize = 14
		val.TextColor3 = moneyChange > 0 and C.Green or C.Red
		val.TextXAlignment = Enum.TextXAlignment.Right
		val.Text = (moneyChange > 0 and "+" or "-") .. formatted
		val.ZIndex = config.zIndex + 5
		val.Parent = row
	end
	
	-- Spacer
	local spacer = Instance.new("Frame")
	spacer.Size = UDim2.new(1, 0, 0, hasChanges and 6 or 0)
	spacer.BackgroundTransparency = 1
	spacer.LayoutOrder = 15
	spacer.Parent = card
	
	-- OK Button
	local okBtn = Instance.new("TextButton")
	okBtn.Size = UDim2.new(1, 0, 0, 48)
	okBtn.BackgroundColor3 = accentColor
	okBtn.Font = F.Button
	okBtn.TextSize = 16
	okBtn.TextColor3 = C.White
	okBtn.Text = "Continue"
	okBtn.AutoButtonColor = false
	okBtn.LayoutOrder = 20
	okBtn.ZIndex = config.zIndex + 4
	okBtn.Parent = card
	corner(okBtn, 12)
	
	okBtn.MouseEnter:Connect(function()
		tween(okBtn, TweenInfo.new(0.1), { BackgroundColor3 = accentDark })
	end)
	okBtn.MouseLeave:Connect(function()
		tween(okBtn, TweenInfo.new(0.1), { BackgroundColor3 = accentColor })
	end)
	
	local function dismiss()
		tween(overlay, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
		tween(shadowFrame, TweenInfo.new(0.2), {
			Position = UDim2.new(0.5, 0, 0.5, 40),
			BackgroundTransparency = 1,
		})
		tween(shell, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
		tween(card, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
		
		task.delay(0.2, function()
			if overlay then overlay:Destroy() end
		end)
		
		if config.onDismiss then
			config.onDismiss()
		end
	end
	
	okBtn.MouseButton1Click:Connect(dismiss)
	closeArea.MouseButton1Click:Connect(dismiss)
	
	-- Animation in
	shadowFrame.Position = UDim2.new(0.5, 0, 0.5, 50)
	shadowFrame.BackgroundTransparency = 1
	shell.BackgroundTransparency = 1
	card.BackgroundTransparency = 1
	overlay.BackgroundTransparency = 1
	
	tween(overlay, TweenInfo.new(0.2), { BackgroundTransparency = 0.5 })
	tween(shadowFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 0.92,
	})
	tween(shell, TweenInfo.new(0.25), { BackgroundTransparency = 0 })
	tween(card, TweenInfo.new(0.25), { BackgroundTransparency = 0 })
	
	return {
		overlay = overlay,
		dismiss = dismiss,
		destroy = function()
			if overlay then overlay:Destroy() end
		end,
	}
end

----------------------------------------------------------------------
-- STAT TOAST (BitLife-style "Much Smarter" popup)
----------------------------------------------------------------------

function UIManager:showStatToast(config)
	--[[
	config = {
		parent = Frame,
		statName = string,
		oldValue = number,
		newValue = number,
		reason = string,
		duration = number,
	}
	]]
	
	local statColors = {
		Happiness = C.Green,
		Health = C.Red,
		Smarts = C.Purple,
		Looks = C.Pink,
	}
	
	local statIcons = {
		Happiness = "😀",
		Health = "❤️",
		Smarts = "🧠",
		Looks = "💄",
	}
	
	local statPhrases = {
		Happiness = { up = "Feeling Happier", down = "Feeling Sadder" },
		Health = { up = "Healthier", down = "Less Healthy" },
		Smarts = { up = "Much Smarter", down = "Brain Fog" },
		Looks = { up = "Looking Better", down = "Looking Worse" },
	}
	
	local color = statColors[config.statName] or C.Blue
	local icon = statIcons[config.statName] or "📊"
	local delta = config.newValue - config.oldValue
	local phrase = statPhrases[config.statName] or { up = "Improved", down = "Decreased" }
	local title = delta > 0 and phrase.up or phrase.down
	
	-- Toast container
	local toast = Instance.new("Frame")
	toast.Name = "StatToast"
	toast.Size = UDim2.new(0.9, 0, 0, 120)
	toast.AnchorPoint = Vector2.new(0.5, 0)
	toast.Position = UDim2.new(0.5, 0, 0, -130)
	toast.BackgroundColor3 = C.White
	toast.ZIndex = 95
	toast.Parent = config.parent
	corner(toast, 16)
	stroke(toast, 2, 0.5, color)
	createShadow(toast, 4, 12, C.Black, 0.85)
	pad(toast, 16, 16, 12, 12)
	
	-- Icon
	local iconLbl = Instance.new("TextLabel")
	iconLbl.Size = UDim2.new(0, 40, 0, 40)
	iconLbl.Position = UDim2.new(0, 0, 0, 0)
	iconLbl.BackgroundTransparency = 1
	iconLbl.Font = F.Body
	iconLbl.TextSize = 30
	iconLbl.Text = icon
	iconLbl.ZIndex = 96
	iconLbl.Parent = toast
	
	-- Title
	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1, -50, 0, 24)
	titleLbl.Position = UDim2.new(0, 45, 0, 0)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Font = F.Title
	titleLbl.TextSize = 16
	titleLbl.TextColor3 = C.Gray900
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Text = title
	titleLbl.ZIndex = 96
	titleLbl.Parent = toast
	
	-- Reason (if provided)
	if config.reason then
		local reasonLbl = Instance.new("TextLabel")
		reasonLbl.Size = UDim2.new(1, -50, 0, 30)
		reasonLbl.Position = UDim2.new(0, 45, 0, 22)
		reasonLbl.BackgroundTransparency = 1
		reasonLbl.Font = F.Body
		reasonLbl.TextSize = 12
		reasonLbl.TextColor3 = C.Gray500
		reasonLbl.TextXAlignment = Enum.TextXAlignment.Left
		reasonLbl.TextWrapped = true
		reasonLbl.Text = config.reason
		reasonLbl.ZIndex = 96
		reasonLbl.Parent = toast
	end
	
	-- Progress bars
	local barY = config.reason and 58 or 48
	
	-- Old value bar
	local oldBarBg = Instance.new("Frame")
	oldBarBg.Size = UDim2.new(1, -16, 0, 12)
	oldBarBg.Position = UDim2.new(0, 0, 0, barY)
	oldBarBg.BackgroundColor3 = C.Gray200
	oldBarBg.ZIndex = 96
	oldBarBg.Parent = toast
	pill(oldBarBg)
	
	local oldBarFill = Instance.new("Frame")
	oldBarFill.Size = UDim2.new(config.oldValue / 100, 0, 1, 0)
	oldBarFill.BackgroundColor3 = Color3.new(color.R * 0.6, color.G * 0.6, color.B * 0.6)
	oldBarFill.ZIndex = 97
	oldBarFill.Parent = oldBarBg
	pill(oldBarFill)
	
	-- New value bar
	local newBarBg = Instance.new("Frame")
	newBarBg.Size = UDim2.new(1, -16, 0, 16)
	newBarBg.Position = UDim2.new(0, 0, 0, barY + 18)
	newBarBg.BackgroundColor3 = C.Gray200
	newBarBg.ZIndex = 96
	newBarBg.Parent = toast
	pill(newBarBg)
	
	local newBarFill = Instance.new("Frame")
	newBarFill.Size = UDim2.new(config.oldValue / 100, 0, 1, 0)
	newBarFill.BackgroundColor3 = color
	newBarFill.ZIndex = 97
	newBarFill.Parent = newBarBg
	pill(newBarFill)
	
	-- Value labels
	local valueLbl = Instance.new("TextLabel")
	valueLbl.Size = UDim2.new(0, 50, 0, 16)
	valueLbl.AnchorPoint = Vector2.new(1, 0)
	valueLbl.Position = UDim2.new(1, 0, 0, barY + 18)
	valueLbl.BackgroundTransparency = 1
	valueLbl.Font = F.Title
	valueLbl.TextSize = 13
	valueLbl.TextColor3 = color
	valueLbl.TextXAlignment = Enum.TextXAlignment.Right
	valueLbl.Text = config.newValue .. "%"
	valueLbl.ZIndex = 98
	valueLbl.Parent = toast
	
	-- Animation
	tween(toast, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0, 50)
	})
	
	-- Animate new bar filling
	task.delay(0.3, function()
		tween(newBarFill, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(math.min(1, config.newValue / 100), 0, 1, 0)
		})
	end)
	
	-- Auto dismiss
	task.delay(config.duration or 3, function()
		tween(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.new(0.5, 0, 0, -130)
		})
		task.delay(0.3, function()
			if toast then toast:Destroy() end
		end)
	end)
	
	return toast
end

----------------------------------------------------------------------
-- FEED ENTRY TOAST (Brief notification at bottom)
----------------------------------------------------------------------

function UIManager:showFeedToast(config)
	--[[
	config = {
		parent = Frame,
		emoji = string,
		text = string,
		duration = number,
	}
	]]
	
	local toast = Instance.new("Frame")
	toast.Name = "FeedToast"
	toast.Size = UDim2.new(0.9, 0, 0, 50)
	toast.AnchorPoint = Vector2.new(0.5, 1)
	toast.Position = UDim2.new(0.5, 0, 1, 60)
	toast.BackgroundColor3 = C.Gray800
	toast.ZIndex = 90
	toast.Parent = config.parent
	corner(toast, 12)
	pad(toast, 14, 14, 0, 0)
	
	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.new(0, 30, 1, 0)
	icon.BackgroundTransparency = 1
	icon.Font = F.Body
	icon.TextSize = 20
	icon.Text = config.emoji or "📜"
	icon.ZIndex = 91
	icon.Parent = toast
	
	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1, -40, 1, 0)
	text.Position = UDim2.new(0, 35, 0, 0)
	text.BackgroundTransparency = 1
	text.Font = F.Body
	text.TextSize = 14
	text.TextColor3 = C.White
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.TextWrapped = true
	text.Text = config.text or ""
	text.ZIndex = 91
	text.Parent = toast
	
	-- Animation
	tween(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 1, -100)
	})
	
	task.delay(config.duration or 2.5, function()
		tween(toast, TweenInfo.new(0.3), {
			Position = UDim2.new(0.5, 0, 1, 60)
		})
		task.delay(0.3, function()
			if toast then toast:Destroy() end
		end)
	end)
	
	return toast
end

----------------------------------------------------------------------
-- CLOSE BUTTON HELPER
----------------------------------------------------------------------

function UIManager:createCloseButton(parent, config)
	--[[
	config = {
		position = UDim2,
		size = UDim2,
		zIndex = number,
		color = Color3,
		hoverColor = Color3,
		onClick = function(),
	}
	]]
	
	config = config or {}
	
	local btn = Instance.new("TextButton")
	btn.Name = "CloseButton"
	btn.Size = config.size or UDim2.new(0, 40, 0, 40)
	btn.AnchorPoint = Vector2.new(1, 0.5)
	btn.Position = config.position or UDim2.new(1, -10, 0.5, 0)
	btn.BackgroundColor3 = C.White
	btn.BackgroundTransparency = 0.1
	btn.Font = F.Title
	btn.TextSize = 18
	btn.TextColor3 = config.color or C.Gray600
	btn.Text = "X"
	btn.AutoButtonColor = false
	btn.ZIndex = config.zIndex or 86
	btn.Parent = parent
	corner(btn, 20)
	
	btn.MouseEnter:Connect(function()
		tween(btn, TweenInfo.new(0.1), { BackgroundTransparency = 0 })
	end)
	btn.MouseLeave:Connect(function()
		tween(btn, TweenInfo.new(0.1), { BackgroundTransparency = 0.1 })
	end)
	
	if config.onClick then
		btn.MouseButton1Click:Connect(config.onClick)
	end
	
	return btn
end

return UIManager
