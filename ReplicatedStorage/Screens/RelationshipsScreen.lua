-- RelationshipsScreen.lua
-- Premium AAA-quality Relationships screen with beautiful modals

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RelationshipsScreen = {}
RelationshipsScreen.__index = RelationshipsScreen

local remotesFolder = ReplicatedStorage:WaitForChild("LifeRemotes", 10)
local InteractPerson = remotesFolder and remotesFolder:FindFirstChild("InteractPerson")
local GiveMoney = remotesFolder and remotesFolder:FindFirstChild("GiveMoney")

-- Premium Color Palette
local C = {
	Pink = Color3.fromRGB(236, 72, 153),
	PinkDark = Color3.fromRGB(219, 39, 119),
	PinkPale = Color3.fromRGB(252, 231, 243),
	PinkLight = Color3.fromRGB(251, 207, 232),

	Blue = Color3.fromRGB(37, 99, 235),
	BlueDark = Color3.fromRGB(29, 78, 216),
	BluePale = Color3.fromRGB(219, 234, 254),
	BlueLight = Color3.fromRGB(147, 197, 253),

	Orange = Color3.fromRGB(249, 115, 22),
	OrangeDark = Color3.fromRGB(234, 88, 12),
	OrangePale = Color3.fromRGB(255, 237, 213),

	Green = Color3.fromRGB(34, 197, 94),
	GreenDark = Color3.fromRGB(22, 163, 74),
	GreenPale = Color3.fromRGB(220, 252, 231),

	Yellow = Color3.fromRGB(234, 179, 8),

	Red = Color3.fromRGB(239, 68, 68),
	RedDark = Color3.fromRGB(220, 38, 38),
	RedPale = Color3.fromRGB(254, 226, 226),

	Purple = Color3.fromRGB(147, 51, 234),
	PurplePale = Color3.fromRGB(243, 232, 255),

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
	Bg = Color3.fromRGB(248, 250, 252),
}

local F = {
	Title = Enum.Font.GothamBold,
	Body = Enum.Font.Gotham,
	Medium = Enum.Font.GothamMedium,
	Button = Enum.Font.GothamBold,
}

-- Sample Data (you can replace with real data later)
local FamilyMembers = {
	{ id = "father", name = "Robert Russell",   rel = "Father", emoji = "👨", age = 52, status = 85 },
	{ id = "mother", name = "Margaret Russell", rel = "Mother", emoji = "👩", age = 48, status = 92 },
	{ id = "sister", name = "Sarah Russell",    rel = "Sister", emoji = "👧", age = 14, status = 70 },
}

local Friends = {
	{ id = "friend1", name = "Bradley Allen",   rel = "Best Friend",  emoji = "🧑", age = 18, status = 95 },
	{ id = "friend2", name = "Jessica Martinez",rel = "Close Friend", emoji = "👩", age = 17, status = 78 },
}

local Enemies = {
	{ id = "enemy1", name = "Derek Thompson",   rel = "Nemesis", emoji = "😠", age = 19, status = 15, reason = "Bullied you in school" },
}

local ActionDefs = {
	Compliment   = { text = "Compliment",  emoji = "🤗", minAge = 3, cost = 0,  desc = "Say something nice" },
	Insult       = { text = "Insult",      emoji = "🤬", minAge = 5, cost = 0,  desc = "Say something mean" },
	Gift         = { text = "Give Gift",   emoji = "🎁", minAge = 5, cost = 50, desc = "Give a $50 gift" },
	SpendTime    = { text = "Spend Time",  emoji = "🕐", minAge = 2, cost = 0,  desc = "Hang out together" },
	Argue        = { text = "Argue",       emoji = "😤", minAge = 5, cost = 0,  desc = "Start an argument" },
	Apologize    = { text = "Apologize",   emoji = "🙏", minAge = 4, cost = 0,  desc = "Say sorry" },
	AskMoney     = { text = "Ask for $",   emoji = "💰", minAge = 5, cost = 0,  desc = "Ask for money" },
	Conversation = { text = "Chat",        emoji = "💬", minAge = 3, cost = 0,  desc = "Have a conversation" },
}

-- Helpers
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
	pd.PaddingLeft   = UDim.new(0, l or 0)
	pd.PaddingRight  = UDim.new(0, r or 0)
	pd.PaddingTop    = UDim.new(0, t or 0)
	pd.PaddingBottom = UDim.new(0, b or 0)
	pd.Parent = p
	return pd
end

local function tween(o, info, props)
	local t = TweenService:Create(o, info, props)
	t:Play()
	return t
end

local function statusColor(s)
	if s >= 80 then
		return C.Green
	elseif s >= 60 then
		return C.Blue
	elseif s >= 40 then
		return C.Yellow
	elseif s >= 20 then
		return C.Orange
	else
		return C.Red
	end
end

local function statusText(s)
	if s >= 90 then
		return "Excellent"
	elseif s >= 70 then
		return "Good"
	elseif s >= 50 then
		return "Okay"
	elseif s >= 30 then
		return "Poor"
	else
		return "Terrible"
	end
end

---------------------------------------------------------------------
-- Constructor
---------------------------------------------------------------------

function RelationshipsScreen.new(screenGui, blurOverlay, showBlurFunc, hideBlurFunc, playerState)
	local self = setmetatable({}, RelationshipsScreen)

	self.screenGui = screenGui
	self.playerState = playerState or {}
	self.showBlur = showBlurFunc
	self.hideBlur = hideBlurFunc
	self.isVisible = false

	self:createUI()
	self:createInteractionModal()
	self:createResultModal()

	return self
end

function RelationshipsScreen:updateState(newState)
	if newState then self.playerState = newState end
end

function RelationshipsScreen:getAge()
	local state = self.playerState
	if not state then return 0 end
	return state.Age or (state.Stats and state.Stats.Age) or 0
end

function RelationshipsScreen:getMoney()
	return self.playerState and self.playerState.Money or 0
end

---------------------------------------------------------------------
-- Main UI
---------------------------------------------------------------------

function RelationshipsScreen:createUI()
	self.overlay = Instance.new("Frame")
	self.overlay.Name = "RelationshipsOverlay"
	self.overlay.Size = UDim2.fromScale(1, 1)
	self.overlay.BackgroundColor3 = C.Bg
	self.overlay.Visible = false
	self.overlay.ZIndex = 80
	self.overlay.Parent = self.screenGui

	-- Header, offset down so Roblox core UI doesn't cover it
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, -16, 0, 60)
	header.Position = UDim2.new(0, 8, 0, 44)
	header.BackgroundColor3 = C.Pink
	header.ZIndex = 85
	header.Parent = self.overlay
	corner(header, 18)

	local hGrad = Instance.new("UIGradient")
	hGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, C.Pink),
		ColorSequenceKeypoint.new(1, C.PinkDark),
	})
	hGrad.Rotation = 90
	hGrad.Parent = header

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -120, 1, 0)
	title.Position = UDim2.new(0, 20, 0, 0)
	title.BackgroundTransparency = 1
	title.Font = F.Title
	title.TextSize = 20
	title.TextColor3 = C.White
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = "❤️ Relationships"
	title.ZIndex = 86
	title.Parent = header

	-- Close button (real visible X)
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 40, 0, 40)
	closeBtn.AnchorPoint = Vector2.new(1, 0.5)
	closeBtn.Position = UDim2.new(1, -10, 0.5, 0)
	closeBtn.BackgroundColor3 = C.White
	closeBtn.BackgroundTransparency = 0.1
	closeBtn.Font = F.Title
	closeBtn.TextSize = 20
	closeBtn.TextColor3 = C.PinkDark
	closeBtn.Text = "X"
	closeBtn.AutoButtonColor = false
	closeBtn.ZIndex = 86
	closeBtn.Parent = header
	corner(closeBtn, 20)
	stroke(closeBtn, 1, 0.85, C.PinkDark)

	closeBtn.MouseButton1Click:Connect(function()
		self:hide()
	end)

	closeBtn.MouseEnter:Connect(function()
		tween(closeBtn, TweenInfo.new(0.12), { BackgroundTransparency = 0 })
	end)

	closeBtn.MouseLeave:Connect(function()
		tween(closeBtn, TweenInfo.new(0.12), { BackgroundTransparency = 0.1 })
	end)

	-- Scroll area, placed under header with margin
	local contentTopOffset = 44 + 60 + 8 -- header offset + height + spacing
	local contentBottomPadding = 12

	local content = Instance.new("ScrollingFrame")
	content.Name = "Content"
	content.Size = UDim2.new(1, -16, 1, - (contentTopOffset + contentBottomPadding))
	content.Position = UDim2.new(0, 8, 0, contentTopOffset)
	content.BackgroundTransparency = 1
	content.CanvasSize = UDim2.new(0, 0, 0, 0)
	content.AutomaticCanvasSize = Enum.AutomaticSize.Y
	content.ScrollBarThickness = 4
	content.ScrollBarImageColor3 = C.Gray300
	content.ZIndex = 81
	content.Parent = self.overlay

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 14)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = content

	self:createSection(content, "Family", C.Pink, C.PinkPale, C.PinkLight, FamilyMembers, 1)
	self:createSection(content, "Friends", C.Blue, C.BluePale, C.BlueLight, Friends, 2)
	self:createSection(content, "Enemies", C.Orange, C.OrangePale, Color3.fromRGB(254, 215, 170), Enemies, 3)
end

function RelationshipsScreen:createSection(parent, name, accentColor, bgColor, hoverColor, people, order)
	local section = Instance.new("Frame")
	section.Name = name .. "Section"
	section.Size = UDim2.new(1, 0, 0, 0)
	section.AutomaticSize = Enum.AutomaticSize.Y
	section.BackgroundColor3 = C.White
	section.LayoutOrder = order
	section.ZIndex = 82
	section.Parent = parent
	corner(section, 18)
	stroke(section, 1, 0.92, C.Gray200)
	pad(section, 16, 16, 16, 16)

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 12)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = section

	-- Header row
	local headerRow = Instance.new("Frame")
	headerRow.Size = UDim2.new(1, 0, 0, 36)
	headerRow.BackgroundTransparency = 1
	headerRow.LayoutOrder = 0
	headerRow.ZIndex = 83
	headerRow.Parent = section

	local badge = Instance.new("Frame")
	badge.Size = UDim2.new(0, 95, 0, 32)
	badge.BackgroundColor3 = accentColor
	badge.ZIndex = 84
	badge.Parent = headerRow
	pill(badge)

	local badgeLbl = Instance.new("TextLabel")
	badgeLbl.Size = UDim2.fromScale(1, 1)
	badgeLbl.BackgroundTransparency = 1
	badgeLbl.Font = F.Button
	badgeLbl.TextSize = 14
	badgeLbl.TextColor3 = C.White
	badgeLbl.Text = name
	badgeLbl.ZIndex = 85
	badgeLbl.Parent = badge

	local count = 0
	if people then
		count = #people
	end

	local countLbl = Instance.new("TextLabel")
	countLbl.Size = UDim2.new(0, 150, 1, 0)
	countLbl.Position = UDim2.new(0, 105, 0, 0)
	countLbl.BackgroundTransparency = 1
	countLbl.Font = F.Medium
	countLbl.TextSize = 13
	countLbl.TextColor3 = C.Gray400
	countLbl.TextXAlignment = Enum.TextXAlignment.Left
	if count > 0 then
		countLbl.Text = tostring(count) .. " people"
	else
		countLbl.Text = "No " .. string.lower(name) .. " yet"
	end
	countLbl.ZIndex = 84
	countLbl.Parent = headerRow

	people = people or {}

	if count == 0 then
		-- Small hint text instead of giant blank
		local emptyLbl = Instance.new("TextLabel")
		emptyLbl.Size = UDim2.new(1, 0, 0, 32)
		emptyLbl.BackgroundTransparency = 1
		emptyLbl.Font = F.Body
		emptyLbl.TextSize = 13
		emptyLbl.TextColor3 = C.Gray400
		emptyLbl.TextXAlignment = Enum.TextXAlignment.Left
		emptyLbl.Text = "• You don't have any " .. string.lower(name) .. " here yet."
		emptyLbl.LayoutOrder = 1
		emptyLbl.ZIndex = 83
		emptyLbl.Parent = section
		return
	end

	-- Person cards
	for i, person in ipairs(people) do
		local card = Instance.new("TextButton")
		card.Name = person.id .. "_Card"
		card.Size = UDim2.new(1, 0, 0, 76)
		card.BackgroundColor3 = bgColor
		card.Font = F.Body
		card.Text = ""
		card.AutoButtonColor = false
		card.LayoutOrder = i
		card.ZIndex = 83
		card.Parent = section
		corner(card, 16)

		-- Avatar circle
		local avatar = Instance.new("Frame")
		avatar.Size = UDim2.new(0, 52, 0, 52)
		avatar.Position = UDim2.new(0, 12, 0.5, -26)
		avatar.BackgroundColor3 = C.White
		avatar.ZIndex = 84
		avatar.Parent = card
		corner(avatar, 26)
		stroke(avatar, 2, 0.5, accentColor)

		local emojiLbl = Instance.new("TextLabel")
		emojiLbl.Size = UDim2.fromScale(1, 1)
		emojiLbl.BackgroundTransparency = 1
		emojiLbl.Font = F.Body
		emojiLbl.TextSize = 28
		emojiLbl.Text = person.emoji or "👤"
		emojiLbl.ZIndex = 85
		emojiLbl.Parent = avatar

		-- Name & relation
		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size = UDim2.new(0.5, 0, 0, 22)
		nameLbl.Position = UDim2.new(0, 74, 0, 12)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Font = F.Title
		nameLbl.TextSize = 16
		nameLbl.TextColor3 = C.Gray900
		nameLbl.TextXAlignment = Enum.TextXAlignment.Left
		nameLbl.Text = person.name or "Unknown"
		nameLbl.ZIndex = 84
		nameLbl.Parent = card

		local relLbl = Instance.new("TextLabel")
		relLbl.Size = UDim2.new(0.5, 0, 0, 16)
		relLbl.Position = UDim2.new(0, 74, 0, 34)
		relLbl.BackgroundTransparency = 1
		relLbl.Font = F.Body
		relLbl.TextSize = 12
		relLbl.TextColor3 = C.Gray500
		relLbl.TextXAlignment = Enum.TextXAlignment.Left
		relLbl.Text = (person.rel or "Relation") .. " • Age " .. tostring(person.age or "?")
		relLbl.ZIndex = 84
		relLbl.Parent = card

		-- Status indicator
		local statusFrame = Instance.new("Frame")
		statusFrame.Size = UDim2.new(0, 110, 0, 22)
		statusFrame.Position = UDim2.new(0, 74, 0, 52)
		statusFrame.BackgroundColor3 = statusColor(person.status or 50)
		statusFrame.BackgroundTransparency = 0.85
		statusFrame.ZIndex = 84
		statusFrame.Parent = card
		pill(statusFrame)

		local statusLbl = Instance.new("TextLabel")
		statusLbl.Size = UDim2.fromScale(1, 1)
		statusLbl.BackgroundTransparency = 1
		statusLbl.Font = F.Medium
		statusLbl.TextSize = 11
		statusLbl.TextColor3 = statusColor(person.status or 50)
		statusLbl.Text = statusText(person.status or 50) .. " " .. tostring(person.status or 50) .. "%"
		statusLbl.ZIndex = 85
		statusLbl.Parent = statusFrame

		-- Interact button
		local interactBtn = Instance.new("TextButton")
		interactBtn.Size = UDim2.new(0, 90, 0, 40)
		interactBtn.AnchorPoint = Vector2.new(1, 0.5)
		interactBtn.Position = UDim2.new(1, -12, 0.5, 0)
		interactBtn.BackgroundColor3 = accentColor
		interactBtn.Font = F.Button
		interactBtn.TextSize = 13
		interactBtn.TextColor3 = C.White
		interactBtn.Text = "Interact"
		interactBtn.AutoButtonColor = false
		interactBtn.ZIndex = 84
		interactBtn.Parent = card
		pill(interactBtn)

		interactBtn.MouseEnter:Connect(function()
			tween(interactBtn, TweenInfo.new(0.12), { BackgroundColor3 = accentColor:Lerp(C.White, 0.12) })
		end)

		interactBtn.MouseLeave:Connect(function()
			tween(interactBtn, TweenInfo.new(0.12), { BackgroundColor3 = accentColor })
		end)

		interactBtn.MouseButton1Click:Connect(function()
			self:showInteractionModal(person, name, accentColor, bgColor)
		end)

		card.MouseEnter:Connect(function()
			tween(card, TweenInfo.new(0.12), { BackgroundColor3 = hoverColor })
		end)

		card.MouseLeave:Connect(function()
			tween(card, TweenInfo.new(0.12), { BackgroundColor3 = bgColor })
		end)
	end
end

---------------------------------------------------------------------
-- Interaction Modal
---------------------------------------------------------------------

function RelationshipsScreen:createInteractionModal()
	self.interactionOverlay = Instance.new("Frame")
	self.interactionOverlay.Size = UDim2.fromScale(1, 1)
	self.interactionOverlay.BackgroundColor3 = C.Black
	self.interactionOverlay.BackgroundTransparency = 0.4
	self.interactionOverlay.Visible = false
	self.interactionOverlay.ZIndex = 90
	self.interactionOverlay.Parent = self.screenGui

	-- Click outside to close
	local closeArea = Instance.new("TextButton")
	closeArea.Size = UDim2.fromScale(1, 1)
	closeArea.BackgroundTransparency = 1
	closeArea.Text = ""
	closeArea.ZIndex = 90
	closeArea.Parent = self.interactionOverlay
	closeArea.MouseButton1Click:Connect(function()
		self:hideInteractionModal()
	end)

	-- Modal card
	self.interactionCard = Instance.new("Frame")
	self.interactionCard.Size = UDim2.new(0.92, 0, 0, 0)
	self.interactionCard.AutomaticSize = Enum.AutomaticSize.Y
	self.interactionCard.AnchorPoint = Vector2.new(0.5, 0.5)
	self.interactionCard.Position = UDim2.fromScale(0.5, 0.5)
	self.interactionCard.BackgroundColor3 = C.White
	self.interactionCard.ZIndex = 92
	self.interactionCard.Parent = self.interactionOverlay
	corner(self.interactionCard, 24)

	-- Top accent bar
	self.modalAccent = Instance.new("Frame")
	self.modalAccent.Size = UDim2.new(1, 0, 0, 6)
	self.modalAccent.BackgroundColor3 = C.Pink
	self.modalAccent.ZIndex = 93
	self.modalAccent.Parent = self.interactionCard
	corner(self.modalAccent, 24)

	local accentFix = Instance.new("Frame")
	accentFix.Size = UDim2.new(1, 0, 0, 4)
	accentFix.Position = UDim2.new(0, 0, 0, 4)
	accentFix.BackgroundColor3 = C.Pink
	accentFix.ZIndex = 93
	accentFix.Parent = self.modalAccent
	self.accentFix = accentFix

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 0)
	layout.Parent = self.interactionCard

	-- Person header
	self.modalHeader = Instance.new("Frame")
	self.modalHeader.Size = UDim2.new(1, 0, 0, 100)
	self.modalHeader.BackgroundTransparency = 1
	self.modalHeader.LayoutOrder = 1
	self.modalHeader.ZIndex = 93
	self.modalHeader.Parent = self.interactionCard

	-- Close button for modal (clean X)
	local modalClose = Instance.new("TextButton")
	modalClose.Size = UDim2.new(0, 34, 0, 34)
	modalClose.AnchorPoint = Vector2.new(1, 0)
	modalClose.Position = UDim2.new(1, -12, 0, 16)
	modalClose.BackgroundColor3 = C.Gray100
	modalClose.Font = F.Title
	modalClose.TextSize = 18
	modalClose.TextColor3 = C.Gray500
	modalClose.Text = "X"
	modalClose.AutoButtonColor = false
	modalClose.ZIndex = 95
	modalClose.Parent = self.modalHeader
	corner(modalClose, 17)

	modalClose.MouseButton1Click:Connect(function()
		self:hideInteractionModal()
	end)

	modalClose.MouseEnter:Connect(function()
		tween(modalClose, TweenInfo.new(0.1), { BackgroundColor3 = C.Gray200 })
	end)

	modalClose.MouseLeave:Connect(function()
		tween(modalClose, TweenInfo.new(0.1), { BackgroundColor3 = C.Gray100 })
	end)

	self.modalAvatar = Instance.new("Frame")
	self.modalAvatar.Size = UDim2.new(0, 64, 0, 64)
	self.modalAvatar.Position = UDim2.new(0.5, -32, 0, 20)
	self.modalAvatar.BackgroundColor3 = C.PinkPale
	self.modalAvatar.ZIndex = 94
	self.modalAvatar.Parent = self.modalHeader
	corner(self.modalAvatar, 32)

	self.modalAvatarStroke = stroke(self.modalAvatar, 3, 0.3, C.Pink)

	self.modalEmoji = Instance.new("TextLabel")
	self.modalEmoji.Size = UDim2.fromScale(1, 1)
	self.modalEmoji.BackgroundTransparency = 1
	self.modalEmoji.Font = F.Body
	self.modalEmoji.TextSize = 34
	self.modalEmoji.Text = "👤"
	self.modalEmoji.ZIndex = 95
	self.modalEmoji.Parent = self.modalAvatar

	-- Name + relation
	self.modalInfoContainer = Instance.new("Frame")
	self.modalInfoContainer.Size = UDim2.new(1, 0, 0, 50)
	self.modalInfoContainer.BackgroundTransparency = 1
	self.modalInfoContainer.LayoutOrder = 2
	self.modalInfoContainer.ZIndex = 93
	self.modalInfoContainer.Parent = self.interactionCard

	self.modalName = Instance.new("TextLabel")
	self.modalName.Size = UDim2.new(1, 0, 0, 26)
	self.modalName.BackgroundTransparency = 1
	self.modalName.Font = F.Title
	self.modalName.TextSize = 20
	self.modalName.TextColor3 = C.Gray900
	self.modalName.Text = "Person Name"
	self.modalName.ZIndex = 94
	self.modalName.Parent = self.modalInfoContainer

	self.modalRel = Instance.new("TextLabel")
	self.modalRel.Size = UDim2.new(1, 0, 0, 20)
	self.modalRel.Position = UDim2.new(0, 0, 0, 26)
	self.modalRel.BackgroundTransparency = 1
	self.modalRel.Font = F.Body
	self.modalRel.TextSize = 13
	self.modalRel.TextColor3 = C.Gray500
	self.modalRel.Text = "Relationship • Age"
	self.modalRel.ZIndex = 94
	self.modalRel.Parent = self.modalInfoContainer

	-- Divider
	local divider = Instance.new("Frame")
	divider.Size = UDim2.new(1, -40, 0, 1)
	divider.Position = UDim2.new(0, 20, 0, 0)
	divider.BackgroundColor3 = C.Gray200
	divider.LayoutOrder = 3
	divider.ZIndex = 93
	divider.Parent = self.interactionCard

	-- Actions grid
	self.actionsContainer = Instance.new("Frame")
	self.actionsContainer.Size = UDim2.new(1, 0, 0, 0)
	self.actionsContainer.AutomaticSize = Enum.AutomaticSize.Y
	self.actionsContainer.BackgroundTransparency = 1
	self.actionsContainer.LayoutOrder = 4
	self.actionsContainer.ZIndex = 93
	self.actionsContainer.Parent = self.interactionCard

	pad(self.actionsContainer, 16, 16, 16, 20)

	self.actionsGrid = Instance.new("Frame")
	self.actionsGrid.Size = UDim2.new(1, 0, 0, 0)
	self.actionsGrid.AutomaticSize = Enum.AutomaticSize.Y
	self.actionsGrid.BackgroundTransparency = 1
	self.actionsGrid.ZIndex = 94
	self.actionsGrid.Parent = self.actionsContainer

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0.48, 0, 0, 72)
	gridLayout.CellPadding = UDim2.new(0.04, 0, 0, 10)
	gridLayout.FillDirection = Enum.FillDirection.Horizontal
	gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.Parent = self.actionsGrid

	self.actionButtons = {}
end

---------------------------------------------------------------------
-- Result Modal (BitLife-style card with colored shell)
---------------------------------------------------------------------

function RelationshipsScreen:createResultModal()
	self.resultOverlay = Instance.new("Frame")
	self.resultOverlay.Size = UDim2.fromScale(1, 1)
	self.resultOverlay.BackgroundColor3 = C.Black
	self.resultOverlay.BackgroundTransparency = 0.5
	self.resultOverlay.Visible = false
	self.resultOverlay.ZIndex = 96
	self.resultOverlay.Parent = self.screenGui

	-- Click outside to close
	local resultCloseArea = Instance.new("TextButton")
	resultCloseArea.Size = UDim2.fromScale(1, 1)
	resultCloseArea.BackgroundTransparency = 1
	resultCloseArea.Text = ""
	resultCloseArea.ZIndex = 96
	resultCloseArea.Parent = self.resultOverlay
	resultCloseArea.MouseButton1Click:Connect(function()
		self:hideResultModal()
	end)

	-- Outer colored shell (changes based on success/fail)
	self.resultShell = Instance.new("Frame")
	self.resultShell.Size = UDim2.new(0.88, 0, 0, 0)
	self.resultShell.AutomaticSize = Enum.AutomaticSize.Y
	self.resultShell.AnchorPoint = Vector2.new(0.5, 0.5)
	self.resultShell.Position = UDim2.fromScale(0.5, 0.5)
	self.resultShell.BackgroundColor3 = C.Green
	self.resultShell.ZIndex = 97
	self.resultShell.Parent = self.resultOverlay
	corner(self.resultShell, 24)

	self.resultShellStroke = stroke(self.resultShell, 3, 0, C.GreenDark)

	-- Shell padding
	pad(self.resultShell, 4, 4, 4, 4)

	-- Inner white card
	self.resultCard = Instance.new("Frame")
	self.resultCard.Size = UDim2.new(1, 0, 0, 0)
	self.resultCard.AutomaticSize = Enum.AutomaticSize.Y
	self.resultCard.BackgroundColor3 = C.White
	self.resultCard.ZIndex = 98
	self.resultCard.Parent = self.resultShell
	corner(self.resultCard, 20)

	-- Content container
	local resultContent = Instance.new("Frame")
	resultContent.Size = UDim2.new(1, 0, 0, 0)
	resultContent.AutomaticSize = Enum.AutomaticSize.Y
	resultContent.BackgroundTransparency = 1
	resultContent.ZIndex = 99
	resultContent.Parent = self.resultCard

	pad(resultContent, 24, 24, 28, 24)

	local layout = Instance.new("UIListLayout")
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Padding = UDim.new(0, 14)
	layout.Parent = resultContent

	-- Emoji circle
	self.resultEmojiFrame = Instance.new("Frame")
	self.resultEmojiFrame.Size = UDim2.new(0, 72, 0, 72)
	self.resultEmojiFrame.BackgroundColor3 = C.GreenPale
	self.resultEmojiFrame.LayoutOrder = 1
	self.resultEmojiFrame.ZIndex = 100
	self.resultEmojiFrame.Parent = resultContent
	corner(self.resultEmojiFrame, 36)

	self.resultEmoji = Instance.new("TextLabel")
	self.resultEmoji.Size = UDim2.fromScale(1, 1)
	self.resultEmoji.BackgroundTransparency = 1
	self.resultEmoji.Font = F.Body
	self.resultEmoji.TextSize = 38
	self.resultEmoji.Text = "😊"
	self.resultEmoji.ZIndex = 101
	self.resultEmoji.Parent = self.resultEmojiFrame

	-- Title
	self.resultTitle = Instance.new("TextLabel")
	self.resultTitle.Size = UDim2.new(1, 0, 0, 28)
	self.resultTitle.BackgroundTransparency = 1
	self.resultTitle.Font = F.Title
	self.resultTitle.TextSize = 22
	self.resultTitle.TextColor3 = C.Gray900
	self.resultTitle.Text = "It went well!"
	self.resultTitle.LayoutOrder = 2
	self.resultTitle.ZIndex = 100
	self.resultTitle.Parent = resultContent

	-- Message
	self.resultMsg = Instance.new("TextLabel")
	self.resultMsg.Size = UDim2.new(1, 0, 0, 0)
	self.resultMsg.AutomaticSize = Enum.AutomaticSize.Y
	self.resultMsg.BackgroundTransparency = 1
	self.resultMsg.Font = F.Body
	self.resultMsg.TextSize = 15
	self.resultMsg.TextColor3 = C.Gray600
	self.resultMsg.TextWrapped = true
	self.resultMsg.LineHeight = 1.4
	self.resultMsg.Text = "Your relationship has improved."
	self.resultMsg.LayoutOrder = 3
	self.resultMsg.ZIndex = 100
	self.resultMsg.Parent = resultContent

	-- Spacer
	local spacer = Instance.new("Frame")
	spacer.Size = UDim2.new(1, 0, 0, 6)
	spacer.BackgroundTransparency = 1
	spacer.LayoutOrder = 4
	spacer.Parent = resultContent

	-- Continue button
	self.resultOkBtn = Instance.new("TextButton")
	self.resultOkBtn.Size = UDim2.new(1, 0, 0, 50)
	self.resultOkBtn.BackgroundColor3 = C.Green
	self.resultOkBtn.Font = F.Button
	self.resultOkBtn.TextSize = 16
	self.resultOkBtn.TextColor3 = C.White
	self.resultOkBtn.Text = "Continue"
	self.resultOkBtn.AutoButtonColor = false
	self.resultOkBtn.LayoutOrder = 5
	self.resultOkBtn.ZIndex = 100
	self.resultOkBtn.Parent = resultContent
	corner(self.resultOkBtn, 12)

	self.resultOkBtn.MouseButton1Click:Connect(function()
		self:hideResultModal()
	end)

	self.resultOkBtn.MouseEnter:Connect(function()
		tween(self.resultOkBtn, TweenInfo.new(0.1), { BackgroundColor3 = C.GreenDark })
	end)

	self.resultOkBtn.MouseLeave:Connect(function()
		tween(self.resultOkBtn, TweenInfo.new(0.1), { BackgroundColor3 = C.Green })
	end)
end

---------------------------------------------------------------------
-- Interaction behaviour
---------------------------------------------------------------------

function RelationshipsScreen:showInteractionModal(person, category, accentColor, bgColor)
	self.currentPerson = person
	self.currentCategory = category
	self.currentAccent = accentColor

	self.modalAccent.BackgroundColor3 = accentColor
	self.accentFix.BackgroundColor3 = accentColor
	self.modalAvatar.BackgroundColor3 = bgColor
	self.modalAvatarStroke.Color = accentColor

	self.modalEmoji.Text = person.emoji or "👤"
	self.modalName.Text = person.name or "Unknown"
	self.modalRel.Text = (person.rel or "Relationship") ..
		" • Age " .. tostring(person.age or "?") ..
		" • " .. statusText(person.status or 50) .. " " .. tostring(person.status or 50) .. "%"

	-- Clear old buttons
	for _, btn in ipairs(self.actionButtons) do
		btn:Destroy()
	end
	self.actionButtons = {}

	local age = self:getAge()
	local money = self:getMoney()

	local actions

	if category == "Enemies" then
		actions = { "Insult", "Argue", "Apologize", "Conversation" }
	elseif category == "Family" then
		actions = { "Conversation", "Compliment", "SpendTime", "Gift", "AskMoney", "Apologize" }
	elseif category == "Friends" then
		actions = { "Conversation", "Compliment", "SpendTime", "Gift", "Argue" }
	else
		actions = { "Conversation", "Compliment", "SpendTime", "Apologize" }
	end

	for i, actionKey in ipairs(actions) do
		local def = ActionDefs[actionKey]
		if def then
			local canDo = age >= def.minAge and (def.cost == 0 or money >= def.cost)

			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 1, 0)
			btn.BackgroundColor3 = canDo and C.White or C.Gray100
			btn.Font = F.Button
			btn.Text = ""
			btn.AutoButtonColor = false
			btn.LayoutOrder = i
			btn.ZIndex = 95
			btn.Parent = self.actionsGrid
			corner(btn, 14)
			stroke(btn, 1, canDo and 0.85 or 0.95, canDo and accentColor or C.Gray300)

			local emojiLbl = Instance.new("TextLabel")
			emojiLbl.Size = UDim2.new(1, 0, 0, 28)
			emojiLbl.Position = UDim2.new(0, 0, 0, 10)
			emojiLbl.BackgroundTransparency = 1
			emojiLbl.Font = F.Body
			emojiLbl.TextSize = 24
			emojiLbl.Text = def.emoji
			emojiLbl.ZIndex = 96
			emojiLbl.Parent = btn

			local textLbl = Instance.new("TextLabel")
			textLbl.Size = UDim2.new(1, 0, 0, 18)
			textLbl.Position = UDim2.new(0, 0, 0, 38)
			textLbl.BackgroundTransparency = 1
			textLbl.Font = F.Button
			textLbl.TextSize = 12
			textLbl.TextColor3 = canDo and C.Gray800 or C.Gray400
			textLbl.Text = def.text
			textLbl.ZIndex = 96
			textLbl.Parent = btn

			if not canDo then
				local reqLbl = Instance.new("TextLabel")
				reqLbl.Size = UDim2.new(1, 0, 0, 14)
				reqLbl.Position = UDim2.new(0, 0, 0, 54)
				reqLbl.BackgroundTransparency = 1
				reqLbl.Font = F.Body
				reqLbl.TextSize = 10
				reqLbl.TextColor3 = C.Red
				if age < def.minAge then
					reqLbl.Text = "Age " .. def.minAge .. "+"
				else
					reqLbl.Text = "Need $" .. def.cost
				end
				reqLbl.ZIndex = 96
				reqLbl.Parent = btn
			end

			if canDo then
				btn.MouseEnter:Connect(function()
					tween(btn, TweenInfo.new(0.1), { BackgroundColor3 = bgColor })
				end)

				btn.MouseLeave:Connect(function()
					tween(btn, TweenInfo.new(0.1), { BackgroundColor3 = C.White })
				end)

				btn.MouseButton1Click:Connect(function()
					self:performAction(actionKey)
				end)
			end

			table.insert(self.actionButtons, btn)
		end
	end

	self.interactionOverlay.Visible = true
	self.interactionCard.Position = UDim2.new(0.5, 0, 0.5, 50)
	self.interactionCard.BackgroundTransparency = 1

	tween(self.interactionCard, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 0,
	})
end

function RelationshipsScreen:hideInteractionModal()
	local t = tween(self.interactionCard, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = UDim2.new(0.5, 0, 0.5, 50),
		BackgroundTransparency = 1,
	})
	t.Completed:Connect(function()
		self.interactionOverlay.Visible = false
	end)
end

function RelationshipsScreen:performAction(actionKey)
	self:hideInteractionModal()

	local def = ActionDefs[actionKey]
	if not def then
		return
	end

	local result

	if actionKey == "Gift" and GiveMoney then
		result = GiveMoney:InvokeServer(self.currentPerson.id, 50)
	elseif InteractPerson then
		result = InteractPerson:InvokeServer(self.currentPerson.id, actionKey)
	end

	task.delay(0.25, function()
		local success = result and result.success or false
		
		-- Set shell color based on success
		local shellColor = success and C.Green or C.Red
		local shellStrokeColor = success and C.GreenDark or C.RedDark
		
		self.resultShell.BackgroundColor3 = shellColor
		self.resultShellStroke.Color = shellStrokeColor
		
		if result then
			self.resultEmoji.Text = success and "😊" or "😔"
			self.resultEmojiFrame.BackgroundColor3 = success and C.GreenPale or C.RedPale
			self.resultTitle.Text = success and "It went well!" or "That didn't go well..."
			self.resultTitle.TextColor3 = success and C.GreenDark or C.RedDark
			self.resultMsg.Text = result.message or "Something happened."
			self.resultOkBtn.BackgroundColor3 = success and C.Green or C.Red
		else
			self.resultShell.BackgroundColor3 = C.Gray500
			self.resultShellStroke.Color = C.Gray600
			self.resultEmoji.Text = "❓"
			self.resultEmojiFrame.BackgroundColor3 = C.Gray100
			self.resultTitle.Text = "No response"
			self.resultTitle.TextColor3 = C.Gray700
			self.resultMsg.Text = "The server didn't respond. Try again."
			self.resultOkBtn.BackgroundColor3 = C.Gray500
		end

		self.resultOverlay.Visible = true
		self.resultShell.Position = UDim2.new(0.5, 0, 0.5, 40)
		self.resultShell.BackgroundTransparency = 1
		self.resultCard.BackgroundTransparency = 1

		tween(self.resultShell, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 0,
		})
		tween(self.resultCard, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0,
		})
	end)
end

function RelationshipsScreen:hideResultModal()
	local t = tween(self.resultShell, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = UDim2.new(0.5, 0, 0.5, 40),
		BackgroundTransparency = 1,
	})
	tween(self.resultCard, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
	t.Completed:Connect(function()
		self.resultOverlay.Visible = false
	end)
end

---------------------------------------------------------------------
-- Show / hide
---------------------------------------------------------------------

function RelationshipsScreen:show()
	self.overlay.Visible = true
	self.overlay.Position = UDim2.new(1, 0, 0, 0)

	if self.showBlur then
		self.showBlur()
	end

	tween(self.overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0, 0),
	})

	self.isVisible = true
end

function RelationshipsScreen:hide()
	local t = tween(self.overlay, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		Position = UDim2.new(1, 0, 0, 0),
	})
	t.Completed:Connect(function()
		self.overlay.Visible = false
		self.interactionOverlay.Visible = false
		self.resultOverlay.Visible = false
	end)

	if self.hideBlur then
		self.hideBlur()
	end

	self.isVisible = false
end

return RelationshipsScreen
