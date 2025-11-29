-- RelationshipsScreen.lua
-- Premium BitLife-style Relationships screen
-- Triple AAA polished UI for family, friends, and romantic connections

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UI = require(ReplicatedStorage:WaitForChild("UIComponents"))
local C = UI.Colors
local F = UI.Fonts

local RelationshipsScreen = {}
RelationshipsScreen.__index = RelationshipsScreen

-- Remotes
local remotesFolder = ReplicatedStorage:WaitForChild("LifeRemotes", 30)
local DoInteraction = remotesFolder and remotesFolder:WaitForChild("DoInteraction", 15)

-- Relationship Actions
local ActionDefs = {
	-- Family actions
	family_hug = { name = "Hug", emoji = "🤗", effect = "+Relationship" },
	family_talk = { name = "Talk", emoji = "💬", effect = "+Relationship" },
	family_gift = { name = "Give Gift", emoji = "🎁", effect = "+Relationship", cost = 100 },
	family_argue = { name = "Argue", emoji = "😤", effect = "-Relationship" },
	family_money = { name = "Ask for Money", emoji = "💰", effect = "+Money maybe" },
	family_vacation = { name = "Vacation Together", emoji = "✈️", effect = "+Relationship", cost = 2000 },
	family_apologize = { name = "Apologize", emoji = "🙏", effect = "+Relationship" },
	
	-- Romance actions
	romance_date = { name = "Go on Date", emoji = "💕", effect = "+Relationship", cost = 100 },
	romance_gift = { name = "Give Gift", emoji = "🎁", effect = "+Relationship", cost = 200 },
	romance_kiss = { name = "Kiss", emoji = "💋", effect = "+Relationship" },
	romance_propose = { name = "Propose", emoji = "💍", effect = "Marriage", cost = 5000 },
	romance_breakup = { name = "Break Up", emoji = "💔", effect = "End Relationship" },
	romance_marry = { name = "Get Married", emoji = "👰", effect = "Marriage", cost = 10000 },
	romance_flirt = { name = "Flirt", emoji = "😘", effect = "+Relationship" },
	romance_compliment = { name = "Compliment", emoji = "😊", effect = "+Relationship" },
	
	-- Friend actions
	friend_hangout = { name = "Hang Out", emoji = "🎉", effect = "+Relationship" },
	friend_gift = { name = "Give Gift", emoji = "🎁", effect = "+Relationship", cost = 50 },
	friend_betray = { name = "Betray", emoji = "🗡️", effect = "-Relationship" },
	friend_support = { name = "Support", emoji = "🤝", effect = "+Relationship" },
	friend_ghost = { name = "Ghost", emoji = "👻", effect = "End Friendship" },
	friend_party = { name = "Party Together", emoji = "🎊", effect = "+Relationship" },
	
	-- Enemy actions
	enemy_insult = { name = "Insult", emoji = "😤", effect = "-Relationship" },
	enemy_fight = { name = "Fight", emoji = "👊", effect = "Physical!" },
	enemy_forgive = { name = "Forgive", emoji = "🕊️", effect = "Peace" },
	enemy_prank = { name = "Prank", emoji = "🃏", effect = "-Relationship" },
	enemy_ignore = { name = "Ignore", emoji = "🙈", effect = "Nothing" },
}

function RelationshipsScreen.new(screenGui, blurOverlay, showBlurFunc, hideBlurFunc, playerState)
	local self = setmetatable({}, RelationshipsScreen)
	self.screenGui = screenGui
	self.playerState = playerState or {}
	self.showBlur = showBlurFunc
	self.hideBlur = hideBlurFunc
	self.isVisible = false
	self.currentTab = "family"
	self:createUI()
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
	local state = self.playerState
	if not state then return 0 end
	return state.Money or (state.Stats and state.Stats.Money) or 0
end

function RelationshipsScreen:getRelationships()
	local state = self.playerState
	if not state then return {} end
	return state.Relationships or {}
end

function RelationshipsScreen:createUI()
	-- Main overlay
	self.overlay = Instance.new("Frame")
	self.overlay.Name = "RelationshipsOverlay"
	self.overlay.Size = UDim2.fromScale(1, 1)
	self.overlay.BackgroundColor3 = C.Bg
	self.overlay.Visible = false
	self.overlay.ZIndex = 80
	self.overlay.Parent = self.screenGui
	
	-- Premium header
	local headerData = UI.createScreenHeader(self.overlay, {
		title = "💕 Relationships",
		color = C.Pink,
		colorDark = C.PinkDark,
		zIndex = 85
	})
	headerData.closeButton.MouseButton1Click:Connect(function() self:hide() end)
	headerData.closeButton.MouseEnter:Connect(function()
		UI.tween(headerData.closeButton, TweenInfo.new(0.12), { BackgroundTransparency = 0 })
	end)
	headerData.closeButton.MouseLeave:Connect(function()
		UI.tween(headerData.closeButton, TweenInfo.new(0.12), { BackgroundTransparency = 0.1 })
	end)
	
	-- Info bar
	self.infoBar = UI.createInfoBar(self.overlay, { topOffset = 116, zIndex = 84 })
	
	self.ageChip = UI.createInfoChip(self.infoBar, {
		name = "AgeChip", icon = "👤", text = "Age 0",
		bgColor = C.BluePale, textColor = C.BlueDark, order = 1, width = 80
	})
	self.moneyChip = UI.createInfoChip(self.infoBar, {
		name = "MoneyChip", icon = "💵", text = "$0",
		bgColor = C.GreenPale, textColor = C.GreenDark, order = 2, width = 85
	})
	self.relationChip = UI.createInfoChip(self.infoBar, {
		name = "RelationChip", icon = "❤️", text = "0",
		bgColor = C.PinkPale, textColor = C.PinkDark, order = 3, width = 65
	})
	
	-- Tab bar
	self.tabBar = UI.createTabBar(self.overlay, { topOffset = 176, zIndex = 84 })
	
	local tabs = {
		{ id = "family", text = "👨‍👩‍👧 Family", color = C.Cyan },
		{ id = "romance", text = "💕 Romance", color = C.Pink },
		{ id = "friends", text = "👥 Friends", color = C.Purple },
		{ id = "enemies", text = "👿 Enemies", color = C.Red },
	}
	
	self.tabBtns = {}
	for i, tab in ipairs(tabs) do
		local btn = UI.createTabButton(self.tabBar, {
			id = tab.id, text = tab.text, color = tab.color,
			active = i == 1, order = i, width = 0.23, zIndex = 84
		})
		self.tabBtns[tab.id] = { btn = btn, color = tab.color }
		btn.MouseButton1Click:Connect(function() self:switchTab(tab.id) end)
	end
	
	-- Scroll area
	self.contentScroll = UI.createScrollArea(self.overlay, { topOffset = 240, zIndex = 81 })
	
	-- Modals
	self:createInteractionModal()
	self:createResultModal()
	
	-- Initial populate
	self:populateFamily()
end

function RelationshipsScreen:updateInfoBar()
	self.ageChip.text.Text = "Age " .. self:getAge()
	self.moneyChip.text.Text = UI.formatMoney(self:getMoney())
	
	local rels = self:getRelationships()
	local count = 0
	for _ in pairs(rels) do count = count + 1 end
	self.relationChip.text.Text = count
end

function RelationshipsScreen:switchTab(tabId)
	self.currentTab = tabId
	
	for id, data in pairs(self.tabBtns) do
		local isActive = id == tabId
		UI.tween(data.btn, TweenInfo.new(0.15), {
			BackgroundColor3 = isActive and data.color or C.White,
			TextColor3 = isActive and C.White or C.Gray600
		})
	end
	
	for _, child in ipairs(self.contentScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	
	if tabId == "family" then self:populateFamily()
	elseif tabId == "romance" then self:populateRomance()
	elseif tabId == "friends" then self:populateFriends()
	elseif tabId == "enemies" then self:populateEnemies() end
end

function RelationshipsScreen:getRelByType(relType)
	local rels = self:getRelationships()
	local filtered = {}
	
	-- Mock some relationships if none exist (for UI demo)
	if not rels or next(rels) == nil then
		if relType == "family" then
			filtered = {
				{ id = "mother", name = "Your Mother", type = "family", relationship = 85, age = self:getAge() + 25, emoji = "👩" },
				{ id = "father", name = "Your Father", type = "family", relationship = 80, age = self:getAge() + 27, emoji = "👨" },
			}
		elseif relType == "romance" and self:getAge() >= 16 then
			filtered = {
				{ id = "partner1", name = "Potential Partner", type = "romance", relationship = 0, age = self:getAge(), emoji = "💕", status = "Single" },
			}
		end
		return filtered
	end
	
	for id, rel in pairs(rels) do
		if rel.type == relType then
			table.insert(filtered, { id = id, name = rel.name, type = rel.type, relationship = rel.relationship or 50, age = rel.age or 0, emoji = rel.emoji or "👤", status = rel.status })
		end
	end
	
	return filtered
end

function RelationshipsScreen:populateFamily()
	self:updateInfoBar()
	
	local family = self:getRelByType("family")
	
	if #family == 0 then
		local emptyCard = self:createEmptyCard("No family members", "👨‍👩‍👧 Start a family to see them here", C.Cyan)
		emptyCard.Parent = self.contentScroll
	else
		local section = UI.createSectionCard(self.contentScroll, {
			name = "FamilySection",
			title = "Family Members",
			subtitle = #family .. " people",
			accentColor = C.Cyan,
			badgeWidth = 85,
			order = 1,
			zIndex = 82
		})
		
		for i, person in ipairs(family) do
			self:createPersonCard(section, person, i, C.Cyan, C.CyanPale, "family")
		end
	end
end

function RelationshipsScreen:populateRomance()
	self:updateInfoBar()
	
	local age = self:getAge()
	
	if age < 16 then
		local emptyCard = self:createEmptyCard("Too Young for Romance", "💕 Come back when you're 16!", C.Pink)
		emptyCard.Parent = self.contentScroll
		return
	end
	
	local romances = self:getRelByType("romance")
	
	-- Add "Meet Someone" option
	local meetCard = self:createMeetCard()
	meetCard.Parent = self.contentScroll
	meetCard.LayoutOrder = 0
	
	if #romances > 0 then
		local section = UI.createSectionCard(self.contentScroll, {
			name = "RomanceSection",
			title = "Romantic Partners",
			subtitle = #romances .. " connections",
			accentColor = C.Pink,
			badgeWidth = 105,
			order = 1,
			zIndex = 82
		})
		
		for i, person in ipairs(romances) do
			self:createPersonCard(section, person, i, C.Pink, C.PinkPale, "romance")
		end
	end
end

function RelationshipsScreen:populateFriends()
	self:updateInfoBar()
	
	local friends = self:getRelByType("friend")
	
	-- Add "Make Friend" option
	local makeCard = self:createMakeFriendCard()
	makeCard.Parent = self.contentScroll
	makeCard.LayoutOrder = 0
	
	if #friends > 0 then
		local section = UI.createSectionCard(self.contentScroll, {
			name = "FriendsSection",
			title = "Friends",
			subtitle = #friends .. " buddies",
			accentColor = C.Purple,
			badgeWidth = 80,
			order = 1,
			zIndex = 82
		})
		
		for i, person in ipairs(friends) do
			self:createPersonCard(section, person, i, C.Purple, C.PurplePale, "friend")
		end
	else
		local emptyCard = self:createEmptyCard("No Friends Yet", "👥 Make some friends to see them here", C.Purple)
		emptyCard.LayoutOrder = 1
		emptyCard.Parent = self.contentScroll
	end
end

function RelationshipsScreen:populateEnemies()
	self:updateInfoBar()
	
	local enemies = self:getRelByType("enemy")
	
	if #enemies == 0 then
		local emptyCard = self:createEmptyCard("No Enemies", "😊 Everyone likes you... for now", C.Green)
		emptyCard.Parent = self.contentScroll
	else
		local section = UI.createSectionCard(self.contentScroll, {
			name = "EnemiesSection",
			title = "Enemies",
			subtitle = #enemies .. " rivals",
			accentColor = C.Red,
			badgeWidth = 75,
			order = 1,
			zIndex = 82
		})
		
		for i, person in ipairs(enemies) do
			self:createPersonCard(section, person, i, C.Red, C.RedPale, "enemy")
		end
	end
end

function RelationshipsScreen:createEmptyCard(title, subtitle, color)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 100)
	card.BackgroundColor3 = C.White
	card.ZIndex = 82
	UI.corner(card, 18)
	UI.stroke(card, 1, 0.8, color)
	
	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.new(0, 60, 0, 60)
	icon.Position = UDim2.new(0, 20, 0.5, -30)
	icon.BackgroundTransparency = 1
	icon.Font = F.Body
	icon.TextSize = 40
	icon.Text = self.currentTab == "family" and "👨‍👩‍👧" or self.currentTab == "romance" and "💕" or self.currentTab == "friends" and "👥" or "😊"
	icon.ZIndex = 83
	icon.Parent = card
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0.6, 0, 0, 26)
	titleLabel.Position = UDim2.new(0, 90, 0, 22)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = F.Title
	titleLabel.TextSize = 17
	titleLabel.TextColor3 = C.Gray800
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = title
	titleLabel.ZIndex = 83
	titleLabel.Parent = card
	
	local subLabel = Instance.new("TextLabel")
	subLabel.Size = UDim2.new(0.7, 0, 0, 22)
	subLabel.Position = UDim2.new(0, 90, 0, 50)
	subLabel.BackgroundTransparency = 1
	subLabel.Font = F.Body
	subLabel.TextSize = 13
	subLabel.TextColor3 = C.Gray500
	subLabel.TextXAlignment = Enum.TextXAlignment.Left
	subLabel.Text = subtitle
	subLabel.ZIndex = 83
	subLabel.Parent = card
	
	return card
end

function RelationshipsScreen:createMeetCard()
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 75)
	card.BackgroundColor3 = C.PinkPale
	card.ZIndex = 82
	UI.corner(card, 18)
	UI.stroke(card, 1, 0.7, C.Pink)
	
	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.new(0, 50, 0, 50)
	icon.Position = UDim2.new(0, 14, 0.5, -25)
	icon.BackgroundTransparency = 1
	icon.Font = F.Body
	icon.TextSize = 32
	icon.Text = "💑"
	icon.ZIndex = 83
	icon.Parent = card
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0.5, 0, 0, 26)
	titleLabel.Position = UDim2.new(0, 74, 0.5, -13)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = F.Title
	titleLabel.TextSize = 16
	titleLabel.TextColor3 = C.PinkDark
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = "Meet Someone New"
	titleLabel.ZIndex = 83
	titleLabel.Parent = card
	
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 80, 0, 40)
	btn.AnchorPoint = Vector2.new(1, 0.5)
	btn.Position = UDim2.new(1, -14, 0.5, 0)
	btn.BackgroundColor3 = C.Pink
	btn.Font = F.Button
	btn.TextSize = 14
	btn.TextColor3 = C.White
	btn.Text = "Find"
	btn.AutoButtonColor = false
	btn.ZIndex = 83
	btn.Parent = card
	UI.corner(btn, 12)
	
	btn.MouseEnter:Connect(function()
		UI.tween(btn, TweenInfo.new(0.12), { BackgroundColor3 = C.PinkDark })
	end)
	btn.MouseLeave:Connect(function()
		UI.tween(btn, TweenInfo.new(0.12), { BackgroundColor3 = C.Pink })
	end)
	btn.MouseButton1Click:Connect(function()
		self:doInteraction("meet_someone", "romance")
	end)
	
	return card
end

function RelationshipsScreen:createMakeFriendCard()
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 75)
	card.BackgroundColor3 = C.PurplePale
	card.ZIndex = 82
	UI.corner(card, 18)
	UI.stroke(card, 1, 0.7, C.Purple)
	
	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.new(0, 50, 0, 50)
	icon.Position = UDim2.new(0, 14, 0.5, -25)
	icon.BackgroundTransparency = 1
	icon.Font = F.Body
	icon.TextSize = 32
	icon.Text = "🤝"
	icon.ZIndex = 83
	icon.Parent = card
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0.5, 0, 0, 26)
	titleLabel.Position = UDim2.new(0, 74, 0.5, -13)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = F.Title
	titleLabel.TextSize = 16
	titleLabel.TextColor3 = C.PurpleDark
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = "Make a New Friend"
	titleLabel.ZIndex = 83
	titleLabel.Parent = card
	
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 80, 0, 40)
	btn.AnchorPoint = Vector2.new(1, 0.5)
	btn.Position = UDim2.new(1, -14, 0.5, 0)
	btn.BackgroundColor3 = C.Purple
	btn.Font = F.Button
	btn.TextSize = 14
	btn.TextColor3 = C.White
	btn.Text = "Meet"
	btn.AutoButtonColor = false
	btn.ZIndex = 83
	btn.Parent = card
	UI.corner(btn, 12)
	
	btn.MouseEnter:Connect(function()
		UI.tween(btn, TweenInfo.new(0.12), { BackgroundColor3 = C.PurpleDark })
	end)
	btn.MouseLeave:Connect(function()
		UI.tween(btn, TweenInfo.new(0.12), { BackgroundColor3 = C.Purple })
	end)
	btn.MouseButton1Click:Connect(function()
		self:doInteraction("make_friend", "friend")
	end)
	
	return card
end

function RelationshipsScreen:createPersonCard(parent, person, order, accentColor, paleColor, relType)
	local card = Instance.new("Frame")
	card.Name = person.id
	card.Size = UDim2.new(1, 0, 0, 105)
	card.BackgroundColor3 = C.White
	card.LayoutOrder = order
	card.ZIndex = 83
	card.Parent = parent
	UI.corner(card, 18)
	UI.stroke(card, 1, 0.88, C.Gray200)
	UI.createShadow(card, 2, 6, C.Black, 0.95)
	
	-- Avatar
	local avatarFrame = Instance.new("Frame")
	avatarFrame.Size = UDim2.new(0, 64, 0, 64)
	avatarFrame.Position = UDim2.new(0, 16, 0.5, -32)
	avatarFrame.BackgroundColor3 = paleColor
	avatarFrame.ZIndex = 84
	avatarFrame.Parent = card
	UI.corner(avatarFrame, 16)
	UI.gradient(avatarFrame, paleColor, paleColor:Lerp(C.White, 0.35), 135)
	
	local avatarLabel = Instance.new("TextLabel")
	avatarLabel.Size = UDim2.fromScale(1, 1)
	avatarLabel.BackgroundTransparency = 1
	avatarLabel.Font = F.Body
	avatarLabel.TextSize = 36
	avatarLabel.Text = person.emoji or "👤"
	avatarLabel.ZIndex = 85
	avatarLabel.Parent = avatarFrame
	
	-- Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.45, 0, 0, 24)
	nameLabel.Position = UDim2.new(0, 94, 0, 14)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = F.Title
	nameLabel.TextSize = 16
	nameLabel.TextColor3 = C.Gray900
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = person.name
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.ZIndex = 84
	nameLabel.Parent = card
	
	-- Relationship bar
	local relPct = math.clamp((person.relationship or 50) / 100, 0, 1)
	local relColor = relPct >= 0.7 and C.Green or relPct >= 0.4 and C.Amber or C.Red
	
	local relBarBg = Instance.new("Frame")
	relBarBg.Size = UDim2.new(0.35, 0, 0, 10)
	relBarBg.Position = UDim2.new(0, 94, 0, 42)
	relBarBg.BackgroundColor3 = C.Gray200
	relBarBg.ZIndex = 84
	relBarBg.Parent = card
	UI.pill(relBarBg)
	
	local relBarFill = Instance.new("Frame")
	relBarFill.Size = UDim2.new(relPct, 0, 1, 0)
	relBarFill.BackgroundColor3 = relColor
	relBarFill.ZIndex = 85
	relBarFill.Parent = relBarBg
	UI.pill(relBarFill)
	
	-- Percentage
	local relLabel = Instance.new("TextLabel")
	relLabel.Size = UDim2.new(0, 50, 0, 18)
	relLabel.Position = UDim2.new(0, 94 + (parent.AbsoluteSize.X * 0.35) + 8, 0, 38)
	relLabel.BackgroundTransparency = 1
	relLabel.Font = F.Medium
	relLabel.TextSize = 12
	relLabel.TextColor3 = relColor
	relLabel.TextXAlignment = Enum.TextXAlignment.Left
	relLabel.Text = math.floor(person.relationship or 50) .. "%"
	relLabel.ZIndex = 84
	relLabel.Parent = card
	
	-- Status badge
	local status = person.status or (relType == "romance" and "Dating" or relType == "family" and "Family" or "Friend")
	local statusBadge = Instance.new("Frame")
	statusBadge.Size = UDim2.new(0, 75, 0, 24)
	statusBadge.Position = UDim2.new(0, 94, 0, 60)
	statusBadge.BackgroundColor3 = paleColor
	statusBadge.ZIndex = 84
	statusBadge.Parent = card
	UI.pill(statusBadge)
	
	local statusLabel = Instance.new("TextLabel")
	statusLabel.Size = UDim2.fromScale(1, 1)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Font = F.Medium
	statusLabel.TextSize = 11
	statusLabel.TextColor3 = accentColor:Lerp(C.Black, 0.3)
	statusLabel.Text = status
	statusLabel.ZIndex = 85
	statusLabel.Parent = statusBadge
	
	-- Interact button
	local interactBtn = Instance.new("TextButton")
	interactBtn.Size = UDim2.new(0, 80, 0, 46)
	interactBtn.AnchorPoint = Vector2.new(1, 0.5)
	interactBtn.Position = UDim2.new(1, -14, 0.5, 0)
	interactBtn.BackgroundColor3 = accentColor
	interactBtn.Font = F.Button
	interactBtn.TextSize = 14
	interactBtn.TextColor3 = C.White
	interactBtn.Text = "Interact"
	interactBtn.AutoButtonColor = false
	interactBtn.ZIndex = 84
	interactBtn.Parent = card
	UI.corner(interactBtn, 14)
	
	interactBtn.MouseEnter:Connect(function()
		UI.tween(interactBtn, TweenInfo.new(0.12), { 
			Size = UDim2.new(0, 86, 0, 50),
			BackgroundColor3 = accentColor:Lerp(C.Black, 0.15)
		})
		UI.tween(card, TweenInfo.new(0.12), { BackgroundColor3 = paleColor:Lerp(C.White, 0.6) })
	end)
	interactBtn.MouseLeave:Connect(function()
		UI.tween(interactBtn, TweenInfo.new(0.12), { 
			Size = UDim2.new(0, 80, 0, 46),
			BackgroundColor3 = accentColor
		})
		UI.tween(card, TweenInfo.new(0.12), { BackgroundColor3 = C.White })
	end)
	interactBtn.MouseButton1Click:Connect(function()
		self:showInteractionModal(person, relType, accentColor, paleColor)
	end)
end

function RelationshipsScreen:createInteractionModal()
	self.interactOverlay = Instance.new("Frame")
	self.interactOverlay.Size = UDim2.fromScale(1, 1)
	self.interactOverlay.BackgroundColor3 = C.Black
	self.interactOverlay.BackgroundTransparency = 0.4
	self.interactOverlay.Visible = false
	self.interactOverlay.ZIndex = 94
	self.interactOverlay.Parent = self.screenGui
	
	-- Close on background tap
	local closeArea = Instance.new("TextButton")
	closeArea.Size = UDim2.fromScale(1, 1)
	closeArea.BackgroundTransparency = 1
	closeArea.Text = ""
	closeArea.ZIndex = 94
	closeArea.Parent = self.interactOverlay
	closeArea.MouseButton1Click:Connect(function()
		self:hideInteractionModal()
	end)
	
	-- Card
	local card = Instance.new("Frame")
	card.Size = UDim2.new(0.92, 0, 0, 480)
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.fromScale(0.5, 0.5)
	card.BackgroundColor3 = C.White
	card.ZIndex = 95
	card.Parent = self.interactOverlay
	UI.corner(card, 24)
	UI.createShadow(card, 6, 20, C.Black, 0.85)
	self.interactCard = card
	
	-- Header
	self.interactHeader = Instance.new("Frame")
	self.interactHeader.Size = UDim2.new(1, 0, 0, 90)
	self.interactHeader.BackgroundColor3 = C.Pink
	self.interactHeader.ZIndex = 96
	self.interactHeader.Parent = card
	UI.corner(self.interactHeader, 24)
	
	-- Bottom cover (square off bottom of header)
	local headerCover = Instance.new("Frame")
	headerCover.Size = UDim2.new(1, 0, 0, 30)
	headerCover.Position = UDim2.new(0, 0, 1, -30)
	headerCover.BackgroundColor3 = C.Pink
	headerCover.BorderSizePixel = 0
	headerCover.ZIndex = 96
	headerCover.Parent = self.interactHeader
	
	-- Avatar in header
	self.interactAvatar = Instance.new("Frame")
	self.interactAvatar.Size = UDim2.new(0, 60, 0, 60)
	self.interactAvatar.Position = UDim2.new(0, 18, 0.5, -30)
	self.interactAvatar.BackgroundColor3 = C.White
	self.interactAvatar.ZIndex = 97
	self.interactAvatar.Parent = self.interactHeader
	UI.corner(self.interactAvatar, 14)
	
	self.interactAvatarEmoji = Instance.new("TextLabel")
	self.interactAvatarEmoji.Size = UDim2.fromScale(1, 1)
	self.interactAvatarEmoji.BackgroundTransparency = 1
	self.interactAvatarEmoji.Font = F.Body
	self.interactAvatarEmoji.TextSize = 32
	self.interactAvatarEmoji.Text = "👤"
	self.interactAvatarEmoji.ZIndex = 98
	self.interactAvatarEmoji.Parent = self.interactAvatar
	
	-- Name in header
	self.interactName = Instance.new("TextLabel")
	self.interactName.Size = UDim2.new(0.55, 0, 0, 28)
	self.interactName.Position = UDim2.new(0, 90, 0, 20)
	self.interactName.BackgroundTransparency = 1
	self.interactName.Font = F.Title
	self.interactName.TextSize = 20
	self.interactName.TextColor3 = C.White
	self.interactName.TextXAlignment = Enum.TextXAlignment.Left
	self.interactName.Text = "Name"
	self.interactName.ZIndex = 97
	self.interactName.Parent = self.interactHeader
	
	-- Status in header
	self.interactStatus = Instance.new("TextLabel")
	self.interactStatus.Size = UDim2.new(0.5, 0, 0, 22)
	self.interactStatus.Position = UDim2.new(0, 90, 0, 50)
	self.interactStatus.BackgroundTransparency = 1
	self.interactStatus.Font = F.Body
	self.interactStatus.TextSize = 14
	self.interactStatus.TextColor3 = Color3.new(1, 1, 1)
	self.interactStatus.TextTransparency = 0.2
	self.interactStatus.TextXAlignment = Enum.TextXAlignment.Left
	self.interactStatus.Text = "Status"
	self.interactStatus.ZIndex = 97
	self.interactStatus.Parent = self.interactHeader
	
	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 36, 0, 36)
	closeBtn.AnchorPoint = Vector2.new(1, 0)
	closeBtn.Position = UDim2.new(1, -14, 0, 14)
	closeBtn.BackgroundColor3 = C.White
	closeBtn.BackgroundTransparency = 0.1
	closeBtn.Font = F.Title
	closeBtn.TextSize = 20
	closeBtn.TextColor3 = C.Pink
	closeBtn.Text = "✕"
	closeBtn.AutoButtonColor = false
	closeBtn.ZIndex = 98
	closeBtn.Parent = self.interactHeader
	UI.corner(closeBtn, 10)
	closeBtn.MouseButton1Click:Connect(function()
		self:hideInteractionModal()
	end)
	
	-- Actions scroll
	self.actionsScroll = Instance.new("ScrollingFrame")
	self.actionsScroll.Size = UDim2.new(1, -28, 1, -105)
	self.actionsScroll.Position = UDim2.new(0, 14, 0, 100)
	self.actionsScroll.BackgroundTransparency = 1
	self.actionsScroll.ScrollBarThickness = 4
	self.actionsScroll.ScrollBarImageColor3 = C.Gray400
	self.actionsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	self.actionsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	self.actionsScroll.ZIndex = 96
	self.actionsScroll.Parent = card
	
	local actionsLayout = Instance.new("UIListLayout")
	actionsLayout.Padding = UDim.new(0, 10)
	actionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	actionsLayout.Parent = self.actionsScroll
	
	local actionsPad = Instance.new("UIPadding")
	actionsPad.PaddingBottom = UDim.new(0, 16)
	actionsPad.Parent = self.actionsScroll
	
	self.currentInteractPerson = nil
	self.currentInteractType = nil
end

function RelationshipsScreen:showInteractionModal(person, relType, accentColor, paleColor)
	self.currentInteractPerson = person
	self.currentInteractType = relType
	
	-- Update header
	self.interactHeader.BackgroundColor3 = accentColor
	self.interactHeader:FindFirstChild("Frame", true).BackgroundColor3 = accentColor -- header cover
	self.interactAvatar.BackgroundColor3 = paleColor
	self.interactAvatarEmoji.Text = person.emoji or "👤"
	self.interactName.Text = person.name
	self.interactStatus.Text = (person.status or "Relationship") .. " • " .. math.floor(person.relationship or 50) .. "% ❤️"
	
	-- Clear old actions
	for _, child in ipairs(self.actionsScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	
	-- Add actions based on relationship type
	local actions = {}
	if relType == "family" then
		actions = { "family_hug", "family_talk", "family_gift", "family_argue", "family_money", "family_vacation", "family_apologize" }
	elseif relType == "romance" then
		actions = { "romance_date", "romance_gift", "romance_kiss", "romance_flirt", "romance_compliment", "romance_propose", "romance_breakup" }
	elseif relType == "friend" then
		actions = { "friend_hangout", "friend_gift", "friend_support", "friend_party", "friend_betray", "friend_ghost" }
	elseif relType == "enemy" then
		actions = { "enemy_insult", "enemy_fight", "enemy_prank", "enemy_ignore", "enemy_forgive" }
	end
	
	for i, actionId in ipairs(actions) do
		local action = ActionDefs[actionId]
		if action then
			self:createActionButton(actionId, action, i, accentColor, paleColor)
		end
	end
	
	-- Show modal
	self.interactOverlay.Visible = true
	self.interactCard.Position = UDim2.new(0.5, 0, 0.5, 50)
	self.interactCard.BackgroundTransparency = 1
	
	UI.tween(self.interactCard, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 0
	})
end

function RelationshipsScreen:hideInteractionModal()
	UI.tween(self.interactCard, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = UDim2.new(0.5, 0, 0.5, 30),
		BackgroundTransparency = 1
	})
	task.delay(0.2, function()
		self.interactOverlay.Visible = false
	end)
end

function RelationshipsScreen:createActionButton(actionId, action, order, accentColor, paleColor)
	local money = self:getMoney()
	local cost = action.cost or 0
	local canAfford = money >= cost
	
	local card = Instance.new("Frame")
	card.Name = actionId
	card.Size = UDim2.new(1, 0, 0, 65)
	card.BackgroundColor3 = canAfford and C.White or C.Gray100
	card.LayoutOrder = order
	card.ZIndex = 97
	card.Parent = self.actionsScroll
	UI.corner(card, 14)
	UI.stroke(card, 1, 0.88, C.Gray200)
	
	-- Emoji
	local emojiLabel = Instance.new("TextLabel")
	emojiLabel.Size = UDim2.new(0, 50, 0, 50)
	emojiLabel.Position = UDim2.new(0, 10, 0.5, -25)
	emojiLabel.BackgroundTransparency = 1
	emojiLabel.Font = F.Body
	emojiLabel.TextSize = 28
	emojiLabel.Text = action.emoji
	emojiLabel.ZIndex = 98
	emojiLabel.Parent = card
	
	-- Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.45, 0, 0, 22)
	nameLabel.Position = UDim2.new(0, 64, 0, 10)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = F.Title
	nameLabel.TextSize = 15
	nameLabel.TextColor3 = canAfford and C.Gray900 or C.Gray500
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = action.name
	nameLabel.ZIndex = 98
	nameLabel.Parent = card
	
	-- Effect badge
	local effectText = action.effect .. (cost > 0 and " • $" .. cost or "")
	local effectBadge = Instance.new("Frame")
	effectBadge.Size = UDim2.new(0, math.clamp(#effectText * 7 + 20, 80, 160), 0, 24)
	effectBadge.Position = UDim2.new(0, 64, 0, 34)
	effectBadge.BackgroundColor3 = cost > 0 and C.AmberPale or paleColor
	effectBadge.ZIndex = 98
	effectBadge.Parent = card
	UI.pill(effectBadge)
	
	local effectLabel = Instance.new("TextLabel")
	effectLabel.Size = UDim2.fromScale(1, 1)
	effectLabel.BackgroundTransparency = 1
	effectLabel.Font = F.Medium
	effectLabel.TextSize = 11
	effectLabel.TextColor3 = cost > 0 and C.AmberDark or accentColor:Lerp(C.Black, 0.3)
	effectLabel.Text = effectText
	effectLabel.ZIndex = 99
	effectLabel.Parent = effectBadge
	
	-- Button
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 60, 0, 40)
	btn.AnchorPoint = Vector2.new(1, 0.5)
	btn.Position = UDim2.new(1, -10, 0.5, 0)
	btn.BackgroundColor3 = canAfford and accentColor or C.Gray300
	btn.Font = F.Button
	btn.TextSize = 13
	btn.TextColor3 = canAfford and C.White or C.Gray500
	btn.Text = canAfford and "Do" or "No $"
	btn.AutoButtonColor = false
	btn.ZIndex = 98
	btn.Parent = card
	UI.corner(btn, 10)
	
	if canAfford then
		btn.MouseEnter:Connect(function()
			UI.tween(btn, TweenInfo.new(0.1), { BackgroundColor3 = accentColor:Lerp(C.Black, 0.15) })
			UI.tween(card, TweenInfo.new(0.1), { BackgroundColor3 = paleColor:Lerp(C.White, 0.6) })
		end)
		btn.MouseLeave:Connect(function()
			UI.tween(btn, TweenInfo.new(0.1), { BackgroundColor3 = accentColor })
			UI.tween(card, TweenInfo.new(0.1), { BackgroundColor3 = C.White })
		end)
		btn.MouseButton1Click:Connect(function()
			self:hideInteractionModal()
			task.delay(0.3, function()
				self:doInteraction(actionId, self.currentInteractType, self.currentInteractPerson)
			end)
		end)
	end
end

function RelationshipsScreen:createResultModal()
	self.resultModal = UI.createModalCard(self.screenGui, {
		name = "RelationshipsResult",
		accentColor = C.Green,
		accentDark = C.GreenDark,
		accentPale = C.GreenPale,
		zIndex = 98
	})
	
	self.resultModal.closeArea.MouseButton1Click:Connect(function()
		UI.hideModal(self.resultModal, function() self:switchTab(self.currentTab) end)
	end)
	self.resultModal.okButton.MouseButton1Click:Connect(function()
		UI.hideModal(self.resultModal, function() self:switchTab(self.currentTab) end)
	end)
end

function RelationshipsScreen:doInteraction(actionId, relType, person)
	if not DoInteraction then
		self:showResult(false, "Server not available", "❌")
		return
	end
	
	local personId = person and person.id or nil
	local result = DoInteraction:InvokeServer(actionId, relType, personId)
	
	if result then
		self:showResult(result.success, result.message, result.success and "💕" or "😔")
	else
		self:showResult(false, "Server error", "❌")
	end
end

function RelationshipsScreen:showResult(success, message, emoji)
	local shellColor = success and C.Green or C.Red
	local shellStroke = success and C.GreenDark or C.RedDark
	local pale = success and C.GreenPale or C.RedPale
	
	self.resultModal.shell.BackgroundColor3 = shellColor
	self.resultModal.shellStroke.Color = shellStroke
	self.resultModal.emojiFrame.BackgroundColor3 = pale
	self.resultModal.emojiLabel.Text = emoji or (success and "💕" or "😔")
	self.resultModal.titleLabel.Text = success and "Success!" or "Uh oh..."
	self.resultModal.titleLabel.TextColor3 = success and C.GreenDark or C.RedDark
	self.resultModal.messageLabel.Text = message or ""
	self.resultModal.okButton.BackgroundColor3 = shellColor
	
	UI.showModal(self.resultModal)
end

function RelationshipsScreen:show()
	self:updateInfoBar()
	self:switchTab(self.currentTab)
	UI.slideInScreen(self.overlay, "right")
	self.isVisible = true
end

function RelationshipsScreen:hide()
	UI.slideOutScreen(self.overlay, "right", function()
		self.resultModal.overlay.Visible = false
		self.interactOverlay.Visible = false
	end)
	self.isVisible = false
end

return RelationshipsScreen
