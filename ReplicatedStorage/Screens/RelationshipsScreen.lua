-- RelationshipsScreen.lua
-- Premium AAA-quality Relationships screen with server validation

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
	Blue = Color3.fromRGB(37, 99, 235),
	BluePale = Color3.fromRGB(219, 234, 254),
	Orange = Color3.fromRGB(249, 115, 22),
	OrangePale = Color3.fromRGB(255, 237, 213),
	Green = Color3.fromRGB(34, 197, 94),
	GreenPale = Color3.fromRGB(220, 252, 231),
	Yellow = Color3.fromRGB(234, 179, 8),
	Red = Color3.fromRGB(239, 68, 68),
	White = Color3.fromRGB(255, 255, 255),
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
	Bg = Color3.fromRGB(241, 245, 249),
}

local F = { Title = Enum.Font.GothamBold, Body = Enum.Font.Gotham, Medium = Enum.Font.GothamMedium, Button = Enum.Font.GothamBold }

-- Sample Data
local FamilyMembers = {
	{ id = "father", name = "Robert Russell", rel = "Father", emoji = "👨", age = 52, status = 85 },
	{ id = "mother", name = "Margaret Russell", rel = "Mother", emoji = "👩", age = 48, status = 92 },
	{ id = "sister", name = "Sarah Russell", rel = "Sister", emoji = "👧", age = 14, status = 70 },
}

local Friends = {
	{ id = "friend1", name = "Bradley Allen", rel = "Best Friend", emoji = "🧑", age = 18, status = 95 },
	{ id = "friend2", name = "Jessica Martinez", rel = "Close Friend", emoji = "👩", age = 17, status = 78 },
}

local Enemies = {
	{ id = "enemy1", name = "Derek Thompson", rel = "Nemesis", emoji = "😠", age = 19, status = 15, reason = "Bullied you in school" },
}

local ActionDefs = {
	Compliment = { text = "🤗 Compliment", minAge = 3, cost = 0 },
	Insult = { text = "🤬 Insult", minAge = 5, cost = 0 },
	Gift = { text = "🎁 Give Gift ($50)", minAge = 5, cost = 50 },
	SpendTime = { text = "🕐 Spend Time", minAge = 2, cost = 0 },
	Argue = { text = "😤 Argue", minAge = 5, cost = 0 },
	Apologize = { text = "🙏 Apologize", minAge = 4, cost = 0 },
	AskMoney = { text = "💰 Ask for Money", minAge = 5, cost = 0 },
	Conversation = { text = "💬 Have a Chat", minAge = 3, cost = 0 },
}

-- Helpers
local function corner(p, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r); c.Parent = p; return c end
local function pill(p) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0.5, 0); c.Parent = p; return c end
local function stroke(p, t, tr, col) local s = Instance.new("UIStroke"); s.Thickness = t; s.Transparency = tr or 0; s.Color = col or C.White; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = p; return s end
local function pad(p, l, r, t, b) local pd = Instance.new("UIPadding"); pd.PaddingLeft = UDim.new(0, l or 0); pd.PaddingRight = UDim.new(0, r or 0); pd.PaddingTop = UDim.new(0, t or 0); pd.PaddingBottom = UDim.new(0, b or 0); pd.Parent = p; return pd end
local function tween(o, i, p) local t = TweenService:Create(o, i, p); t:Play(); return t end

local function statusColor(s)
	if s >= 80 then return C.Green elseif s >= 60 then return C.Blue elseif s >= 40 then return C.Yellow elseif s >= 20 then return C.Orange else return C.Red end
end

function RelationshipsScreen.new(screenGui, blurOverlay, showBlurFunc, hideBlurFunc, playerState)
	local self = setmetatable({}, RelationshipsScreen)
	self.screenGui = screenGui
	self.playerState = playerState
	self.showBlur = showBlurFunc
	self.hideBlur = hideBlurFunc
	self.isVisible = false
	self:createUI()
	self:createInteractionModal()
	self:createResultModal()
	return self
end

function RelationshipsScreen:getAge() return self.playerState and self.playerState.Age or 0 end
function RelationshipsScreen:getMoney() return self.playerState and self.playerState.Money or 0 end

function RelationshipsScreen:createUI()
	self.overlay = Instance.new("Frame")
	self.overlay.Name = "RelationshipsOverlay"
	self.overlay.Size = UDim2.fromScale(1, 1)
	self.overlay.BackgroundColor3 = C.Bg
	self.overlay.Visible = false
	self.overlay.ZIndex = 80
	self.overlay.Parent = self.screenGui
	
	-- Header
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 56)
	header.Position = UDim2.new(0, 0, 0, 0)
	header.BackgroundColor3 = C.Pink
	header.ZIndex = 85
	header.Parent = self.overlay
	
	local hGrad = Instance.new("UIGradient")
	hGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, C.Pink), ColorSequenceKeypoint.new(1, C.PinkDark) })
	hGrad.Rotation = 90
	hGrad.Parent = header
	
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -100, 1, 0)
	title.Position = UDim2.new(0, 20, 0, 0)
	title.BackgroundTransparency = 1
	title.Font = F.Title
	title.TextSize = 20
	title.TextColor3 = C.White
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = "❤️ Relationships"
	title.ZIndex = 86
	title.Parent = header
	
	-- Close Button (TOP RIGHT)
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 44, 0, 44)
	closeBtn.AnchorPoint = Vector2.new(1, 0.5)
	closeBtn.Position = UDim2.new(1, -8, 0.5, 0)
	closeBtn.BackgroundColor3 = C.White
	closeBtn.BackgroundTransparency = 0.9
	closeBtn.Font = F.Title
	closeBtn.TextSize = 22
	closeBtn.TextColor3 = C.White
	closeBtn.Text = "✕"
	closeBtn.AutoButtonColor = false
	closeBtn.ZIndex = 86
	closeBtn.Parent = header
	corner(closeBtn, 22)
	
	closeBtn.MouseButton1Click:Connect(function() self:hide() end)
	closeBtn.MouseEnter:Connect(function() tween(closeBtn, TweenInfo.new(0.1), { BackgroundTransparency = 0.7 }) end)
	closeBtn.MouseLeave:Connect(function() tween(closeBtn, TweenInfo.new(0.1), { BackgroundTransparency = 0.9 }) end)
	
	-- Content scroll
	local content = Instance.new("ScrollingFrame")
	content.Size = UDim2.new(1, -16, 1, -72)
	content.Position = UDim2.new(0, 8, 0, 64)
	content.BackgroundTransparency = 1
	content.CanvasSize = UDim2.new(0, 0, 0, 0)
	content.AutomaticCanvasSize = Enum.AutomaticSize.Y
	content.ScrollBarThickness = 3
	content.ScrollBarImageColor3 = C.Gray300
	content.ZIndex = 81
	content.Parent = self.overlay
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 12)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = content
	
	self:createSection(content, "Family", C.Pink, C.PinkPale, FamilyMembers, 1)
	self:createSection(content, "Friends", C.Blue, C.BluePale, Friends, 2)
	self:createSection(content, "Enemies", C.Orange, C.OrangePale, Enemies, 3)
end

function RelationshipsScreen:createSection(parent, name, accentColor, bgColor, people, order)
	local section = Instance.new("Frame")
	section.Size = UDim2.new(1, 0, 0, 0)
	section.AutomaticSize = Enum.AutomaticSize.Y
	section.BackgroundColor3 = C.White
	section.LayoutOrder = order
	section.ZIndex = 82
	section.Parent = parent
	corner(section, 16)
	stroke(section, 1, 0.9, C.Gray200)
	
	pad(section, 14, 14, 14, 14)
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.Parent = section
	
	-- Section header
	local headerRow = Instance.new("Frame")
	headerRow.Size = UDim2.new(1, 0, 0, 32)
	headerRow.BackgroundTransparency = 1
	headerRow.LayoutOrder = 0
	headerRow.ZIndex = 83
	headerRow.Parent = section
	
	local badge = Instance.new("Frame")
	badge.Size = UDim2.new(0, 90, 0, 28)
	badge.BackgroundColor3 = accentColor
	badge.ZIndex = 84
	badge.Parent = headerRow
	pill(badge)
	
	local badgeLbl = Instance.new("TextLabel")
	badgeLbl.Size = UDim2.fromScale(1, 1)
	badgeLbl.BackgroundTransparency = 1
	badgeLbl.Font = F.Button
	badgeLbl.TextSize = 13
	badgeLbl.TextColor3 = C.White
	badgeLbl.Text = name
	badgeLbl.ZIndex = 85
	badgeLbl.Parent = badge
	
	local countLbl = Instance.new("TextLabel")
	countLbl.Size = UDim2.new(0, 40, 1, 0)
	countLbl.Position = UDim2.new(0, 100, 0, 0)
	countLbl.BackgroundTransparency = 1
	countLbl.Font = F.Medium
	countLbl.TextSize = 12
	countLbl.TextColor3 = C.Gray400
	countLbl.TextXAlignment = Enum.TextXAlignment.Left
	countLbl.Text = "(" .. #people .. ")"
	countLbl.ZIndex = 84
	countLbl.Parent = headerRow
	
	-- Person cards
	for i, person in ipairs(people) do
		local card = Instance.new("TextButton")
		card.Size = UDim2.new(1, 0, 0, 70)
		card.BackgroundColor3 = bgColor
		card.Font = F.Body
		card.Text = ""
		card.AutoButtonColor = false
		card.LayoutOrder = i
		card.ZIndex = 83
		card.Parent = section
		corner(card, 14)
		
		-- Avatar
		local avatar = Instance.new("Frame")
		avatar.Size = UDim2.new(0, 50, 0, 50)
		avatar.Position = UDim2.new(0, 10, 0.5, -25)
		avatar.BackgroundColor3 = C.White
		avatar.ZIndex = 84
		avatar.Parent = card
		corner(avatar, 25)
		stroke(avatar, 2, 0.6, accentColor)
		
		local emojiLbl = Instance.new("TextLabel")
		emojiLbl.Size = UDim2.fromScale(1, 1)
		emojiLbl.BackgroundTransparency = 1
		emojiLbl.Font = F.Body
		emojiLbl.TextSize = 26
		emojiLbl.Text = person.emoji
		emojiLbl.ZIndex = 85
		emojiLbl.Parent = avatar
		
		-- Name & relation
		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size = UDim2.new(0.5, 0, 0, 20)
		nameLbl.Position = UDim2.new(0, 70, 0, 12)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Font = F.Title
		nameLbl.TextSize = 15
		nameLbl.TextColor3 = C.Gray900
		nameLbl.TextXAlignment = Enum.TextXAlignment.Left
		nameLbl.Text = person.name
		nameLbl.ZIndex = 84
		nameLbl.Parent = card
		
		local relLbl = Instance.new("TextLabel")
		relLbl.Size = UDim2.new(0.5, 0, 0, 16)
		relLbl.Position = UDim2.new(0, 70, 0, 32)
		relLbl.BackgroundTransparency = 1
		relLbl.Font = F.Body
		relLbl.TextSize = 12
		relLbl.TextColor3 = C.Gray500
		relLbl.TextXAlignment = Enum.TextXAlignment.Left
		relLbl.Text = person.rel .. " • Age " .. person.age
		relLbl.ZIndex = 84
		relLbl.Parent = card
		
		-- Status bar
		local barBg = Instance.new("Frame")
		barBg.Size = UDim2.new(0, 80, 0, 8)
		barBg.Position = UDim2.new(0, 70, 0, 52)
		barBg.BackgroundColor3 = C.Gray200
		barBg.ZIndex = 84
		barBg.Parent = card
		corner(barBg, 4)
		
		local barFill = Instance.new("Frame")
		barFill.Size = UDim2.new(person.status/100, 0, 1, 0)
		barFill.BackgroundColor3 = statusColor(person.status)
		barFill.ZIndex = 85
		barFill.Parent = barBg
		corner(barFill, 4)
		
		local statusLbl = Instance.new("TextLabel")
		statusLbl.Size = UDim2.new(0, 40, 0, 14)
		statusLbl.Position = UDim2.new(0, 155, 0, 49)
		statusLbl.BackgroundTransparency = 1
		statusLbl.Font = F.Medium
		statusLbl.TextSize = 11
		statusLbl.TextColor3 = statusColor(person.status)
		statusLbl.TextXAlignment = Enum.TextXAlignment.Left
		statusLbl.Text = person.status .. "%"
		statusLbl.ZIndex = 84
		statusLbl.Parent = card
		
		-- Interact button
		local interactBtn = Instance.new("TextButton")
		interactBtn.Size = UDim2.new(0, 70, 0, 32)
		interactBtn.AnchorPoint = Vector2.new(1, 0.5)
		interactBtn.Position = UDim2.new(1, -10, 0.5, 0)
		interactBtn.BackgroundColor3 = accentColor
		interactBtn.Font = F.Button
		interactBtn.TextSize = 11
		interactBtn.TextColor3 = C.White
		interactBtn.Text = "Interact"
		interactBtn.AutoButtonColor = false
		interactBtn.ZIndex = 84
		interactBtn.Parent = card
		pill(interactBtn)
		
		interactBtn.MouseEnter:Connect(function() tween(interactBtn, TweenInfo.new(0.1), { Size = UDim2.new(0, 76, 0, 36) }) end)
		interactBtn.MouseLeave:Connect(function() tween(interactBtn, TweenInfo.new(0.1), { Size = UDim2.new(0, 70, 0, 32) }) end)
		interactBtn.MouseButton1Click:Connect(function() self:showInteractionModal(person, name) end)
		
		card.MouseEnter:Connect(function() tween(card, TweenInfo.new(0.1), { BackgroundColor3 = C.White }) end)
		card.MouseLeave:Connect(function() tween(card, TweenInfo.new(0.1), { BackgroundColor3 = bgColor }) end)
	end
end

function RelationshipsScreen:createInteractionModal()
	self.interactionOverlay = Instance.new("Frame")
	self.interactionOverlay.Size = UDim2.fromScale(1, 1)
	self.interactionOverlay.BackgroundColor3 = C.Black
	self.interactionOverlay.BackgroundTransparency = 0.5
	self.interactionOverlay.Visible = false
	self.interactionOverlay.ZIndex = 90
	self.interactionOverlay.Parent = self.screenGui
	
	-- Modal card
	self.interactionCard = Instance.new("Frame")
	self.interactionCard.Size = UDim2.new(0.9, 0, 0, 0)
	self.interactionCard.AutomaticSize = Enum.AutomaticSize.Y
	self.interactionCard.AnchorPoint = Vector2.new(0.5, 0.5)
	self.interactionCard.Position = UDim2.fromScale(0.5, 0.5)
	self.interactionCard.BackgroundColor3 = C.White
	self.interactionCard.ZIndex = 91
	self.interactionCard.Parent = self.interactionOverlay
	corner(self.interactionCard, 24)
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 0)
	layout.Parent = self.interactionCard
	
	-- Person header
	self.modalHeader = Instance.new("Frame")
	self.modalHeader.Size = UDim2.new(1, 0, 0, 90)
	self.modalHeader.BackgroundColor3 = C.Gray50
	self.modalHeader.ClipsDescendants = true
	self.modalHeader.LayoutOrder = 1
	self.modalHeader.ZIndex = 92
	self.modalHeader.Parent = self.interactionCard
	corner(self.modalHeader, 24)
	
	local headerFix = Instance.new("Frame")
	headerFix.Size = UDim2.new(1, 0, 0, 30)
	headerFix.Position = UDim2.new(0, 0, 1, -30)
	headerFix.BackgroundColor3 = C.Gray50
	headerFix.ZIndex = 92
	headerFix.Parent = self.modalHeader
	
	pad(self.modalHeader, 20, 20, 20, 16)
	
	self.modalAvatar = Instance.new("Frame")
	self.modalAvatar.Size = UDim2.new(0, 56, 0, 56)
	self.modalAvatar.BackgroundColor3 = C.PinkPale
	self.modalAvatar.ZIndex = 93
	self.modalAvatar.Parent = self.modalHeader
	corner(self.modalAvatar, 28)
	stroke(self.modalAvatar, 2, 0.4, C.Pink)
	
	self.modalEmoji = Instance.new("TextLabel")
	self.modalEmoji.Size = UDim2.fromScale(1, 1)
	self.modalEmoji.BackgroundTransparency = 1
	self.modalEmoji.Font = F.Body
	self.modalEmoji.TextSize = 30
	self.modalEmoji.Text = "👤"
	self.modalEmoji.ZIndex = 94
	self.modalEmoji.Parent = self.modalAvatar
	
	self.modalName = Instance.new("TextLabel")
	self.modalName.Size = UDim2.new(0.6, 0, 0, 24)
	self.modalName.Position = UDim2.new(0, 66, 0, 6)
	self.modalName.BackgroundTransparency = 1
	self.modalName.Font = F.Title
	self.modalName.TextSize = 18
	self.modalName.TextColor3 = C.Gray900
	self.modalName.TextXAlignment = Enum.TextXAlignment.Left
	self.modalName.Text = "Person Name"
	self.modalName.ZIndex = 93
	self.modalName.Parent = self.modalHeader
	
	self.modalRel = Instance.new("TextLabel")
	self.modalRel.Size = UDim2.new(0.6, 0, 0, 18)
	self.modalRel.Position = UDim2.new(0, 66, 0, 30)
	self.modalRel.BackgroundTransparency = 1
	self.modalRel.Font = F.Body
	self.modalRel.TextSize = 13
	self.modalRel.TextColor3 = C.Gray500
	self.modalRel.TextXAlignment = Enum.TextXAlignment.Left
	self.modalRel.Text = "Relationship"
	self.modalRel.ZIndex = 93
	self.modalRel.Parent = self.modalHeader
	
	self.modalBadge = Instance.new("Frame")
	self.modalBadge.Size = UDim2.new(0, 80, 0, 26)
	self.modalBadge.AnchorPoint = Vector2.new(1, 0)
	self.modalBadge.Position = UDim2.new(1, 20, 0, 10)
	self.modalBadge.BackgroundColor3 = C.Pink
	self.modalBadge.ZIndex = 93
	self.modalBadge.Parent = self.modalHeader
	pill(self.modalBadge)
	
	self.modalBadgeLbl = Instance.new("TextLabel")
	self.modalBadgeLbl.Size = UDim2.fromScale(1, 1)
	self.modalBadgeLbl.BackgroundTransparency = 1
	self.modalBadgeLbl.Font = F.Button
	self.modalBadgeLbl.TextSize = 11
	self.modalBadgeLbl.TextColor3 = C.White
	self.modalBadgeLbl.Text = "Family"
	self.modalBadgeLbl.ZIndex = 94
	self.modalBadgeLbl.Parent = self.modalBadge
	
	-- Close modal button
	local closeModal = Instance.new("TextButton")
	closeModal.Size = UDim2.new(0, 36, 0, 36)
	closeModal.AnchorPoint = Vector2.new(1, 0)
	closeModal.Position = UDim2.new(1, -10, 0, 10)
	closeModal.BackgroundColor3 = C.Gray200
	closeModal.BackgroundTransparency = 0.5
	closeModal.Font = F.Title
	closeModal.TextSize = 18
	closeModal.TextColor3 = C.Gray600
	closeModal.Text = "✕"
	closeModal.AutoButtonColor = false
	closeModal.ZIndex = 95
	closeModal.Parent = self.interactionCard
	corner(closeModal, 18)
	
	closeModal.MouseButton1Click:Connect(function() self:hideInteractionModal() end)
	
	-- Actions section
	self.actionsSection = Instance.new("Frame")
	self.actionsSection.Size = UDim2.new(1, 0, 0, 0)
	self.actionsSection.AutomaticSize = Enum.AutomaticSize.Y
	self.actionsSection.BackgroundTransparency = 1
	self.actionsSection.LayoutOrder = 2
	self.actionsSection.ZIndex = 92
	self.actionsSection.Parent = self.interactionCard
	
	pad(self.actionsSection, 18, 18, 8, 20)
	
	self.actionsLayout = Instance.new("UIListLayout")
	self.actionsLayout.Padding = UDim.new(0, 8)
	self.actionsLayout.Parent = self.actionsSection
	
	self.actionButtons = {}
end

function RelationshipsScreen:createResultModal()
	self.resultOverlay = Instance.new("Frame")
	self.resultOverlay.Size = UDim2.fromScale(1, 1)
	self.resultOverlay.BackgroundColor3 = C.Black
	self.resultOverlay.BackgroundTransparency = 0.5
	self.resultOverlay.Visible = false
	self.resultOverlay.ZIndex = 95
	self.resultOverlay.Parent = self.screenGui
	
	self.resultCard = Instance.new("Frame")
	self.resultCard.Size = UDim2.new(0.85, 0, 0, 0)
	self.resultCard.AutomaticSize = Enum.AutomaticSize.Y
	self.resultCard.AnchorPoint = Vector2.new(0.5, 0.5)
	self.resultCard.Position = UDim2.fromScale(0.5, 0.5)
	self.resultCard.BackgroundColor3 = C.White
	self.resultCard.ZIndex = 96
	self.resultCard.Parent = self.resultOverlay
	corner(self.resultCard, 24)
	
	local layout = Instance.new("UIListLayout")
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Padding = UDim.new(0, 12)
	layout.Parent = self.resultCard
	
	pad(self.resultCard, 24, 24, 28, 24)
	
	self.resultEmoji = Instance.new("TextLabel")
	self.resultEmoji.Size = UDim2.new(0, 60, 0, 60)
	self.resultEmoji.BackgroundTransparency = 1
	self.resultEmoji.Font = F.Body
	self.resultEmoji.TextSize = 50
	self.resultEmoji.Text = "✅"
	self.resultEmoji.LayoutOrder = 1
	self.resultEmoji.ZIndex = 97
	self.resultEmoji.Parent = self.resultCard
	
	self.resultTitle = Instance.new("TextLabel")
	self.resultTitle.Size = UDim2.new(1, 0, 0, 28)
	self.resultTitle.BackgroundTransparency = 1
	self.resultTitle.Font = F.Title
	self.resultTitle.TextSize = 22
	self.resultTitle.TextColor3 = C.Gray900
	self.resultTitle.Text = "Result"
	self.resultTitle.LayoutOrder = 2
	self.resultTitle.ZIndex = 97
	self.resultTitle.Parent = self.resultCard
	
	self.resultMsg = Instance.new("TextLabel")
	self.resultMsg.Size = UDim2.new(1, 0, 0, 0)
	self.resultMsg.AutomaticSize = Enum.AutomaticSize.Y
	self.resultMsg.BackgroundTransparency = 1
	self.resultMsg.Font = F.Body
	self.resultMsg.TextSize = 15
	self.resultMsg.TextColor3 = C.Gray600
	self.resultMsg.TextWrapped = true
	self.resultMsg.LineHeight = 1.4
	self.resultMsg.Text = ""
	self.resultMsg.LayoutOrder = 3
	self.resultMsg.ZIndex = 97
	self.resultMsg.Parent = self.resultCard
	
	local okBtn = Instance.new("TextButton")
	okBtn.Size = UDim2.new(1, 0, 0, 48)
	okBtn.BackgroundColor3 = C.Blue
	okBtn.Font = F.Button
	okBtn.TextSize = 16
	okBtn.TextColor3 = C.White
	okBtn.Text = "OK"
	okBtn.AutoButtonColor = false
	okBtn.LayoutOrder = 4
	okBtn.ZIndex = 97
	okBtn.Parent = self.resultCard
	pill(okBtn)
	
	okBtn.MouseButton1Click:Connect(function() self:hideResultModal() end)
	okBtn.MouseEnter:Connect(function() tween(okBtn, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(29, 78, 216) }) end)
	okBtn.MouseLeave:Connect(function() tween(okBtn, TweenInfo.new(0.1), { BackgroundColor3 = C.Blue }) end)
end

function RelationshipsScreen:showInteractionModal(person, category)
	self.currentPerson = person
	self.currentCategory = category
	
	local accentColor = category == "Family" and C.Pink or category == "Friends" and C.Blue or C.Orange
	local bgColor = category == "Family" and C.PinkPale or category == "Friends" and C.BluePale or C.OrangePale
	
	self.modalEmoji.Text = person.emoji
	self.modalName.Text = person.name
	self.modalRel.Text = person.rel .. " • Age " .. person.age
	self.modalBadgeLbl.Text = category
	self.modalBadge.BackgroundColor3 = accentColor
	self.modalAvatar.BackgroundColor3 = bgColor
	stroke(self.modalAvatar, 2, 0.4, accentColor)
	
	-- Clear old buttons
	for _, btn in ipairs(self.actionButtons) do btn:Destroy() end
	self.actionButtons = {}
	
	local age = self:getAge()
	local money = self:getMoney()
	
	local actions = { "Conversation", "Compliment", "SpendTime" }
	if category == "Enemies" then
		actions = { "Insult", "Argue", "Apologize" }
	elseif category == "Family" then
		table.insert(actions, "Gift")
		table.insert(actions, "AskMoney")
	elseif category == "Friends" then
		table.insert(actions, "Gift")
	end
	
	for i, actionKey in ipairs(actions) do
		local def = ActionDefs[actionKey]
		if not def then continue end
		
		local canDo = age >= def.minAge and (def.cost == 0 or money >= def.cost)
		
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 48)
		btn.BackgroundColor3 = canDo and accentColor or C.Gray300
		btn.Font = F.Button
		btn.TextSize = 14
		btn.TextColor3 = canDo and C.White or C.Gray500
		btn.Text = def.text .. (not canDo and (age < def.minAge and " (Age " .. def.minAge .. "+)" or " (Need $" .. def.cost .. ")") or "")
		btn.AutoButtonColor = false
		btn.LayoutOrder = i
		btn.ZIndex = 93
		btn.Parent = self.actionsSection
		pill(btn)
		
		if canDo then
			btn.MouseEnter:Connect(function() tween(btn, TweenInfo.new(0.1), { Size = UDim2.new(1, 0, 0, 52) }) end)
			btn.MouseLeave:Connect(function() tween(btn, TweenInfo.new(0.1), { Size = UDim2.new(1, 0, 0, 48) }) end)
			btn.MouseButton1Click:Connect(function() self:performAction(actionKey) end)
		end
		
		table.insert(self.actionButtons, btn)
	end
	
	self.interactionOverlay.Visible = true
	self.interactionCard.Position = UDim2.new(0.5, 0, 0.5, 40)
	tween(self.interactionCard, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.fromScale(0.5, 0.5) })
end

function RelationshipsScreen:hideInteractionModal()
	local t = tween(self.interactionCard, TweenInfo.new(0.2), { Position = UDim2.new(0.5, 0, 0.5, 40) })
	t.Completed:Connect(function() self.interactionOverlay.Visible = false end)
end

function RelationshipsScreen:performAction(actionKey)
	self:hideInteractionModal()
	
	local def = ActionDefs[actionKey]
	if not def then return end
	
	local result = nil
	
	if actionKey == "Gift" and GiveMoney then
		result = GiveMoney:InvokeServer(self.currentPerson.id, 50)
	elseif InteractPerson then
		result = InteractPerson:InvokeServer(self.currentPerson.id, actionKey)
	end
	
	if result then
		local success = result.success
		self.resultEmoji.Text = success and "✅" or "❌"
		self.resultTitle.Text = success and "Success!" or "Failed"
		self.resultTitle.TextColor3 = success and C.Green or C.Red
		self.resultMsg.Text = result.message or "Something happened."
	else
		self.resultEmoji.Text = "❓"
		self.resultTitle.Text = "No Response"
		self.resultTitle.TextColor3 = C.Gray600
		self.resultMsg.Text = "The server didn't respond. Try again."
	end
	
	self.resultOverlay.Visible = true
	self.resultCard.Position = UDim2.new(0.5, 0, 0.5, 30)
	tween(self.resultCard, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.fromScale(0.5, 0.5) })
end

function RelationshipsScreen:hideResultModal()
	local t = tween(self.resultCard, TweenInfo.new(0.15), { Position = UDim2.new(0.5, 0, 0.5, 30) })
	t.Completed:Connect(function() self.resultOverlay.Visible = false end)
end

function RelationshipsScreen:show()
	self.overlay.Visible = true
	self.overlay.Position = UDim2.new(1, 0, 0, 0)
	tween(self.overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.fromScale(0, 0) })
	self.isVisible = true
end

function RelationshipsScreen:hide()
	local t = tween(self.overlay, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Position = UDim2.new(1, 0, 0, 0) })
	t.Completed:Connect(function()
		self.overlay.Visible = false
		self.interactionOverlay.Visible = false
		self.resultOverlay.Visible = false
	end)
	self.isVisible = false
end

return RelationshipsScreen
