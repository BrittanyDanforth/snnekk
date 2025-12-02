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

-- Debug logging
local DEBUG = true
local function log(...)
	if DEBUG then print("[RelationshipsScreen]", ...) end
end
local function logWarn(...)
	warn("[RelationshipsScreen]", ...)
end

-- Remotes
local remotesFolder = ReplicatedStorage:WaitForChild("LifeRemotes", 30)
local DoInteraction = remotesFolder and remotesFolder:WaitForChild("DoInteraction", 15)

-- Relationship Actions
local FamilyActions = {
	{ id = "hug", name = "Hug", emoji = "Hug", effect = "+Relationship" },
	{ id = "talk", name = "Talk", emoji = "Talk", effect = "+Relationship" },
	{ id = "gift", name = "Give Gift", emoji = "Gift", effect = "+Relationship", cost = 100 },
	{ id = "argue", name = "Argue", emoji = "Argue", effect = "-Relationship" },
	{ id = "money", name = "Ask for Money", emoji = "Money", effect = "+Money maybe" },
	{ id = "vacation", name = "Vacation", emoji = "Travel", effect = "+Relationship", cost = 2000 },
	{ id = "apologize", name = "Apologize", emoji = "Sorry", effect = "+Relationship" },
}

local RomanceActions = {
	{ id = "date", name = "Go on Date", emoji = "Date", effect = "+Relationship", cost = 100 },
	{ id = "gift", name = "Give Gift", emoji = "Gift", effect = "+Relationship", cost = 200 },
	{ id = "kiss", name = "Kiss", emoji = "Kiss", effect = "+Relationship" },
	{ id = "propose", name = "Propose", emoji = "Ring", effect = "Marriage", cost = 5000 },
	{ id = "breakup", name = "Break Up", emoji = "Break", effect = "End Relationship" },
	{ id = "flirt", name = "Flirt", emoji = "Flirt", effect = "+Relationship" },
	{ id = "compliment", name = "Compliment", emoji = "Nice", effect = "+Relationship" },
}

local FriendActions = {
	{ id = "hangout", name = "Hang Out", emoji = "Party", effect = "+Relationship" },
	{ id = "gift", name = "Give Gift", emoji = "Gift", effect = "+Relationship", cost = 50 },
	{ id = "support", name = "Support", emoji = "Help", effect = "+Relationship" },
	{ id = "party", name = "Party Together", emoji = "Dance", effect = "+Relationship" },
	{ id = "betray", name = "Betray", emoji = "Bad", effect = "-Relationship" },
	{ id = "ghost", name = "Ghost", emoji = "Ghost", effect = "End Friendship" },
}

local EnemyActions = {
	{ id = "insult", name = "Insult", emoji = "Angry", effect = "-Relationship" },
	{ id = "fight", name = "Fight", emoji = "Fight", effect = "Physical!" },
	{ id = "forgive", name = "Forgive", emoji = "Peace", effect = "Make Peace" },
	{ id = "prank", name = "Prank", emoji = "Prank", effect = "-Relationship" },
	{ id = "ignore", name = "Ignore", emoji = "Ignore", effect = "Nothing" },
}

function RelationshipsScreen.new(screenGui, blurOverlay, showBlurFunc, hideBlurFunc, playerState)
	log("=== CREATING RelationshipsScreen ===")
	local self = setmetatable({}, RelationshipsScreen)
	self.screenGui = screenGui
	self.playerState = playerState or {}
	self.showBlur = showBlurFunc
	self.hideBlur = hideBlurFunc
	self.isVisible = false
	self.currentTab = "family"
	log("Initial state - Age:", self:getAge(), "Money:", self:getMoney())
	self:createUI()
	log("✅ RelationshipsScreen created successfully")
	return self
end

function RelationshipsScreen:updateState(newState)
	log("Updating state...")
	if newState then 
		self.playerState = newState 
		log("State updated - Age:", self:getAge(), "Money:", self:getMoney())
		
		-- Debug: Log relationships
		local rels = self:getRelationships()
		local relCount = 0
		for id, rel in pairs(rels) do
			relCount = relCount + 1
			log("  Relationship:", id, "Type:", rel.type, "Name:", rel.name)
		end
		log("Total relationships in state:", relCount)
		
		-- IMPORTANT: Refresh the screen if visible to show new relationships
		if self.isVisible then
			log("Screen is visible - refreshing current tab:", self.currentTab)
			self:updateInfoBar()
			self:switchTab(self.currentTab)
		end
	end
end

function RelationshipsScreen:getAge()
	local state = self.playerState
	if not state then return 18 end
	return state.Age or (state.Stats and state.Stats.Age) or 18
end

function RelationshipsScreen:getMoney()
	local state = self.playerState
	if not state then return 1000 end
	return state.Money or (state.Stats and state.Stats.Money) or 1000
end

function RelationshipsScreen:getRelationships()
	local state = self.playerState
	if not state then return {} end
	return state.Relationships or {}
end

function RelationshipsScreen:getPlayerName()
	local state = self.playerState
	if state and state.Name then return state.Name end
	return "Player"
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
		title = "Relationships",
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
	
	-- Info bar (no shadow)
	self.infoBar = Instance.new("Frame")
	self.infoBar.Name = "InfoBar"
	self.infoBar.Size = UDim2.new(1, -16, 0, 52)
	self.infoBar.Position = UDim2.new(0, 8, 0, 116)
	self.infoBar.BackgroundColor3 = C.White
	self.infoBar.ZIndex = 84
	self.infoBar.Parent = self.overlay
	UI.corner(self.infoBar, 14)
	UI.stroke(self.infoBar, 1, 0.9, C.Gray200)
	
	local infoLayout = Instance.new("UIListLayout")
	infoLayout.FillDirection = Enum.FillDirection.Horizontal
	infoLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	infoLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	infoLayout.Padding = UDim.new(0, 10)
	infoLayout.Parent = self.infoBar
	
	self.ageChip = UI.createInfoChip(self.infoBar, {
		name = "AgeChip", icon = "", text = "Age 18",
		bgColor = C.BluePale, textColor = C.BlueDark, order = 1, width = 75
	})
	self.ageChip.icon.Text = ""
	self.ageChip.text.Text = "Age 18"
	self.ageChip.text.Position = UDim2.new(0, 8, 0, 0)
	self.ageChip.text.Size = UDim2.new(1, -16, 1, 0)
	self.ageChip.text.TextXAlignment = Enum.TextXAlignment.Center
	
	self.moneyChip = UI.createInfoChip(self.infoBar, {
		name = "MoneyChip", icon = "", text = "$1,000",
		bgColor = C.GreenPale, textColor = C.GreenDark, order = 2, width = 85
	})
	self.moneyChip.icon.Text = ""
	self.moneyChip.text.Text = "$1,000"
	self.moneyChip.text.Position = UDim2.new(0, 8, 0, 0)
	self.moneyChip.text.Size = UDim2.new(1, -16, 1, 0)
	self.moneyChip.text.TextXAlignment = Enum.TextXAlignment.Center
	
	self.relationChip = UI.createInfoChip(self.infoBar, {
		name = "RelationChip", icon = "", text = "0",
		bgColor = C.PinkPale, textColor = C.PinkDark, order = 3, width = 85
	})
	self.relationChip.icon.Text = ""
	self.relationChip.text.Text = "0 People"
	self.relationChip.text.Position = UDim2.new(0, 8, 0, 0)
	self.relationChip.text.Size = UDim2.new(1, -16, 1, 0)
	self.relationChip.text.TextXAlignment = Enum.TextXAlignment.Center
	
	-- Tab bar
	self.tabBar = Instance.new("Frame")
	self.tabBar.Name = "TabBar"
	self.tabBar.Size = UDim2.new(1, -16, 0, 52)
	self.tabBar.Position = UDim2.new(0, 8, 0, 176)
	self.tabBar.BackgroundColor3 = C.Gray100
	self.tabBar.ZIndex = 84
	self.tabBar.Parent = self.overlay
	UI.corner(self.tabBar, 14)
	UI.pad(self.tabBar, 5, 5, 5, 5)
	
	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	tabLayout.Padding = UDim.new(0, 6)
	tabLayout.Parent = self.tabBar
	
	local tabs = {
		{ id = "family", text = "Family", color = C.Cyan },
		{ id = "romance", text = "Romance", color = C.Pink },
		{ id = "friends", text = "Friends", color = C.Purple },
		{ id = "enemies", text = "Enemies", color = C.Red },
	}
	
	self.tabBtns = {}
	for i, tab in ipairs(tabs) do
		local btn = Instance.new("TextButton")
		btn.Name = tab.id
		btn.Size = UDim2.new(0.23, 0, 1, 0)
		btn.BackgroundColor3 = i == 1 and tab.color or C.White
		btn.Font = F.Button
		btn.TextSize = 13
		btn.TextColor3 = i == 1 and C.White or C.Gray600
		btn.Text = tab.text
		btn.AutoButtonColor = false
		btn.LayoutOrder = i
		btn.ZIndex = 85
		btn.Parent = self.tabBar
		UI.corner(btn, 10)
		
		self.tabBtns[tab.id] = { btn = btn, color = tab.color }
		btn.MouseButton1Click:Connect(function() self:switchTab(tab.id) end)
	end
	
	-- Scroll area
	self.contentScroll = Instance.new("ScrollingFrame")
	self.contentScroll.Name = "ContentScroll"
	self.contentScroll.Size = UDim2.new(1, -16, 1, -250)
	self.contentScroll.Position = UDim2.new(0, 8, 0, 240)
	self.contentScroll.BackgroundTransparency = 1
	self.contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	self.contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	self.contentScroll.ScrollBarThickness = 4
	self.contentScroll.ScrollBarImageColor3 = C.Gray300
	self.contentScroll.ZIndex = 81
	self.contentScroll.Parent = self.overlay
	
	local contentLayout = Instance.new("UIListLayout")
	contentLayout.Padding = UDim.new(0, 12)
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	contentLayout.Parent = self.contentScroll
	
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
	
	-- Count actual relationship entries (those with a type property)
	for id, rel in pairs(rels) do
		if type(rel) == "table" and rel.type then
			count = count + 1
		end
	end
	
	-- Get family count (family is either stored or generated with defaults)
	local family = self:getFamily()
	local familyCount = #family
	
	-- Total people = stored relationships + family members
	local totalPeople = count + familyCount
	if totalPeople == 0 then totalPeople = 2 end -- Minimum (parents)
	
	self.relationChip.text.Text = totalPeople .. " People"
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
	
	-- Clear content
	for _, child in ipairs(self.contentScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	
	if tabId == "family" then self:populateFamily()
	elseif tabId == "romance" then self:populateRomance()
	elseif tabId == "friends" then self:populateFriends()
	elseif tabId == "enemies" then self:populateEnemies() end
end

-- Family emoji mapping
local FamilyEmojis = {
	mother = "👩",
	father = "👨", 
	grandmother = "👵",
	grandfather = "👴",
	brother = "👦",
	sister = "👧",
	son = "👦",
	daughter = "👧",
	baby = "👶",
	spouse = "💑",
	wife = "👩",
	husband = "👨",
}

function RelationshipsScreen:getFamilyEmoji(role)
	local lowerRole = role:lower()
	if lowerRole:find("mother") or lowerRole:find("mom") then return "👩" end
	if lowerRole:find("father") or lowerRole:find("dad") then return "👨" end
	if lowerRole:find("grandmother") or lowerRole:find("grandma") then return "👵" end
	if lowerRole:find("grandfather") or lowerRole:find("grandpa") then return "👴" end
	if lowerRole:find("brother") then return "👦" end
	if lowerRole:find("sister") then return "👧" end
	if lowerRole:find("son") then return "👦" end
	if lowerRole:find("daughter") then return "👧" end
	if lowerRole:find("baby") then return "👶" end
	if lowerRole:find("wife") then return "👩" end
	if lowerRole:find("husband") then return "👨" end
	if lowerRole:find("spouse") then return "💑" end
	return "👤"
end

function RelationshipsScreen:getFamily()
	local rels = self:getRelationships()
	local age = self:getAge()
	local family = {}
	
	-- Check for stored family
	for id, rel in pairs(rels) do
		if rel.type == "family" then
			table.insert(family, {
				id = id,
				name = rel.name,
				role = rel.role or "Family",
				emoji = self:getFamilyEmoji(rel.role or ""),
				relationship = rel.relationship or 75,
				age = rel.age or age,
				alive = rel.alive ~= false
			})
		end
	end
	
	-- Default family if none stored (always have parents)
	if #family == 0 then
		local motherAge = math.max(age + 22, 22)
		local fatherAge = math.max(age + 25, 25)
		
		family = {
			{ id = "mother", name = "Mom", role = "Mother", emoji = "👩", relationship = 80, age = motherAge, alive = motherAge < 90 },
			{ id = "father", name = "Dad", role = "Father", emoji = "👨", relationship = 75, age = fatherAge, alive = fatherAge < 85 },
		}
		
		-- Add siblings based on age pattern
		if age > 5 then
			local hasBrother = (age % 4 == 0) or (age % 7 == 1)
			local hasSister = (age % 5 == 0) or (age % 6 == 2)
			
			if hasBrother then
				local sibAge = math.max(age + (age % 2 == 0 and -3 or 2), 1)
				local sibRole = sibAge > age and "Older Brother" or "Younger Brother"
				table.insert(family, {
					id = "brother",
					name = sibAge > age and "Big Bro" or "Lil Bro",
					role = sibRole,
					emoji = "👦",
					relationship = 65,
					age = sibAge,
					alive = true
				})
			end
			
			if hasSister then
				local sibAge = math.max(age + (age % 3 == 0 and 2 or -2), 1)
				local sibRole = sibAge > age and "Older Sister" or "Younger Sister"
				table.insert(family, {
					id = "sister",
					name = sibAge > age and "Big Sis" or "Lil Sis",
					role = sibRole,
					emoji = "👧",
					relationship = 68,
					age = sibAge,
					alive = true
				})
			end
		end
		
		-- Add grandparents if young enough for them to be alive
		if age < 30 then
			local grandmaAge = motherAge + 25
			local grandpaAge = fatherAge + 28
			table.insert(family, { 
				id = "grandma", 
				name = "Grandma", 
				role = "Grandmother", 
				emoji = "👵",
				relationship = 70, 
				age = grandmaAge, 
				alive = grandmaAge < 88 
			})
			table.insert(family, { 
				id = "grandpa", 
				name = "Grandpa", 
				role = "Grandfather", 
				emoji = "👴",
				relationship = 65, 
				age = grandpaAge, 
				alive = grandpaAge < 85 
			})
		end
		
		-- Add children if old enough (married with kids scenario)
		if age >= 25 then
			local hasKid = (age % 3 == 0) or (age >= 30)
			if hasKid then
				local kidAge = math.max(age - 25, 1)
				local isBoy = age % 2 == 0
				table.insert(family, {
					id = "child1",
					name = isBoy and "Son" or "Daughter",
					role = isBoy and "Son" or "Daughter",
					emoji = kidAge < 3 and "👶" or (isBoy and "👦" or "👧"),
					relationship = 85,
					age = kidAge,
					alive = true
				})
			end
		end
	end
	
	return family
end

function RelationshipsScreen:populateFamily()
	self:updateInfoBar()
	
	local family = self:getFamily()
	
	-- Section
	local section = Instance.new("Frame")
	section.Name = "FamilySection"
	section.Size = UDim2.new(1, 0, 0, 0)
	section.AutomaticSize = Enum.AutomaticSize.Y
	section.BackgroundColor3 = C.White
	section.LayoutOrder = 1
	section.ZIndex = 82
	section.Parent = self.contentScroll
	UI.corner(section, 18)
	UI.stroke(section, 1, 0.88, C.Gray200)
	UI.pad(section, 14, 14, 14, 16)
	
	local sectionLayout = Instance.new("UIListLayout")
	sectionLayout.Padding = UDim.new(0, 10)
	sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
	sectionLayout.Parent = section
	
	-- Header
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 36)
	header.BackgroundTransparency = 1
	header.LayoutOrder = 0
	header.ZIndex = 83
	header.Parent = section
	
	local badge = Instance.new("Frame")
	badge.Size = UDim2.new(0, 130, 0, 32)
	badge.BackgroundColor3 = C.Cyan
	badge.ZIndex = 84
	badge.Parent = header
	UI.pill(badge)
	
	local badgeLabel = Instance.new("TextLabel")
	badgeLabel.Size = UDim2.fromScale(1, 1)
	badgeLabel.BackgroundTransparency = 1
	badgeLabel.Font = F.Button
	badgeLabel.TextSize = 14
	badgeLabel.TextColor3 = C.White
	badgeLabel.Text = "Family Members"
	badgeLabel.ZIndex = 85
	badgeLabel.Parent = badge
	
	local countLabel = Instance.new("TextLabel")
	countLabel.Size = UDim2.new(0, 80, 1, 0)
	countLabel.Position = UDim2.new(0, 140, 0, 0)
	countLabel.BackgroundTransparency = 1
	countLabel.Font = F.Medium
	countLabel.TextSize = 13
	countLabel.TextColor3 = C.Gray400
	countLabel.TextXAlignment = Enum.TextXAlignment.Left
	countLabel.Text = #family .. " people"
	countLabel.ZIndex = 84
	countLabel.Parent = header
	
	for i, person in ipairs(family) do
		self:createPersonCard(section, person, i, C.Cyan, C.CyanPale, "family")
	end
end

function RelationshipsScreen:populateRomance()
	self:updateInfoBar()
	
	local age = self:getAge()
	
	if age < 16 then
		-- Too young message
		local tooYoung = Instance.new("Frame")
		tooYoung.Size = UDim2.new(1, 0, 0, 120)
		tooYoung.BackgroundColor3 = C.PinkPale
		tooYoung.LayoutOrder = 1
		tooYoung.ZIndex = 82
		tooYoung.Parent = self.contentScroll
		UI.corner(tooYoung, 18)
		UI.stroke(tooYoung, 1, 0.7, C.Pink)
		
		local icon = Instance.new("TextLabel")
		icon.Size = UDim2.new(1, 0, 0, 45)
		icon.Position = UDim2.new(0, 0, 0, 20)
		icon.BackgroundTransparency = 1
		icon.Font = F.Title
		icon.TextSize = 32
		icon.TextColor3 = C.Pink
		icon.Text = "Too Young!"
		icon.ZIndex = 83
		icon.Parent = tooYoung
		
		local text = Instance.new("TextLabel")
		text.Size = UDim2.new(1, -40, 0, 30)
		text.Position = UDim2.new(0, 20, 0, 70)
		text.BackgroundTransparency = 1
		text.Font = F.Body
		text.TextSize = 14
		text.TextColor3 = C.PinkDark
		text.Text = "Come back when you're 16 for romance!"
		text.ZIndex = 83
		text.Parent = tooYoung
		
		return
	end
	
	local romances = {}
	local rels = self:getRelationships()
	for id, rel in pairs(rels) do
		if rel.type == "romance" then
			table.insert(romances, {
				id = id,
				name = rel.name,
				role = rel.role or "Partner",
				relationship = rel.relationship or 50,
				age = rel.age or age,
				alive = rel.alive ~= false
			})
		end
	end
	
	-- Meet someone card
	local meetCard = Instance.new("Frame")
	meetCard.Size = UDim2.new(1, 0, 0, 75)
	meetCard.BackgroundColor3 = C.PinkPale
	meetCard.LayoutOrder = 0
	meetCard.ZIndex = 82
	meetCard.Parent = self.contentScroll
	UI.corner(meetCard, 16)
	UI.stroke(meetCard, 1, 0.7, C.Pink)
	
	local meetIcon = Instance.new("TextLabel")
	meetIcon.Size = UDim2.new(0, 50, 0, 50)
	meetIcon.Position = UDim2.new(0, 14, 0.5, -25)
	meetIcon.BackgroundTransparency = 1
	meetIcon.Font = F.Body
	meetIcon.TextSize = 32
	meetIcon.TextColor3 = C.Pink
	meetIcon.Text = "💕"
	meetIcon.ZIndex = 83
	meetIcon.Parent = meetCard
	
	local meetTitle = Instance.new("TextLabel")
	meetTitle.Size = UDim2.new(0.5, 0, 0, 26)
	meetTitle.Position = UDim2.new(0, 74, 0.5, -13)
	meetTitle.BackgroundTransparency = 1
	meetTitle.Font = F.Title
	meetTitle.TextSize = 16
	meetTitle.TextColor3 = C.PinkDark
	meetTitle.TextXAlignment = Enum.TextXAlignment.Left
	meetTitle.Text = "Meet Someone New"
	meetTitle.ZIndex = 83
	meetTitle.Parent = meetCard
	
	local meetBtn = Instance.new("TextButton")
	meetBtn.Size = UDim2.new(0, 80, 0, 40)
	meetBtn.AnchorPoint = Vector2.new(1, 0.5)
	meetBtn.Position = UDim2.new(1, -14, 0.5, 0)
	meetBtn.BackgroundColor3 = C.Pink
	meetBtn.Font = F.Button
	meetBtn.TextSize = 14
	meetBtn.TextColor3 = C.White
	meetBtn.Text = "Find"
	meetBtn.AutoButtonColor = false
	meetBtn.ZIndex = 83
	meetBtn.Parent = meetCard
	UI.corner(meetBtn, 12)
	
	meetBtn.MouseEnter:Connect(function()
		UI.tween(meetBtn, TweenInfo.new(0.12), { BackgroundColor3 = C.PinkDark })
	end)
	meetBtn.MouseLeave:Connect(function()
		UI.tween(meetBtn, TweenInfo.new(0.12), { BackgroundColor3 = C.Pink })
	end)
	meetBtn.MouseButton1Click:Connect(function()
		self:doInteraction("meet_someone", "romance", nil)
	end)
	
	if #romances > 0 then
		local section = Instance.new("Frame")
		section.Name = "RomanceSection"
		section.Size = UDim2.new(1, 0, 0, 0)
		section.AutomaticSize = Enum.AutomaticSize.Y
		section.BackgroundColor3 = C.White
		section.LayoutOrder = 1
		section.ZIndex = 82
		section.Parent = self.contentScroll
		UI.corner(section, 18)
		UI.stroke(section, 1, 0.88, C.Gray200)
		UI.pad(section, 14, 14, 14, 16)
		
		local sectionLayout = Instance.new("UIListLayout")
		sectionLayout.Padding = UDim.new(0, 10)
		sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
		sectionLayout.Parent = section
		
		-- Header
		local header = Instance.new("Frame")
		header.Size = UDim2.new(1, 0, 0, 36)
		header.BackgroundTransparency = 1
		header.LayoutOrder = 0
		header.ZIndex = 83
		header.Parent = section
		
		local badge = Instance.new("Frame")
		badge.Size = UDim2.new(0, 145, 0, 32)
		badge.BackgroundColor3 = C.Pink
		badge.ZIndex = 84
		badge.Parent = header
		UI.pill(badge)
		
		local badgeLabel = Instance.new("TextLabel")
		badgeLabel.Size = UDim2.fromScale(1, 1)
		badgeLabel.BackgroundTransparency = 1
		badgeLabel.Font = F.Button
		badgeLabel.TextSize = 14
		badgeLabel.TextColor3 = C.White
		badgeLabel.Text = "Romantic Partners"
		badgeLabel.ZIndex = 85
		badgeLabel.Parent = badge
		
		for i, person in ipairs(romances) do
			self:createPersonCard(section, person, i, C.Pink, C.PinkPale, "romance")
		end
	else
		-- No partners message
		local noPartners = Instance.new("Frame")
		noPartners.Size = UDim2.new(1, 0, 0, 80)
		noPartners.BackgroundColor3 = C.White
		noPartners.LayoutOrder = 1
		noPartners.ZIndex = 82
		noPartners.Parent = self.contentScroll
		UI.corner(noPartners, 16)
		UI.stroke(noPartners, 1, 0.88, C.Gray200)
		
		local noText = Instance.new("TextLabel")
		noText.Size = UDim2.new(1, -40, 1, 0)
		noText.Position = UDim2.new(0, 20, 0, 0)
		noText.BackgroundTransparency = 1
		noText.Font = F.Body
		noText.TextSize = 14
		noText.TextColor3 = C.Gray500
		noText.Text = "No romantic partners yet.\nTap 'Find' above to meet someone!"
		noText.ZIndex = 83
		noText.Parent = noPartners
	end
end

function RelationshipsScreen:populateFriends()
	self:updateInfoBar()
	
	local friends = {}
	local rels = self:getRelationships()
	for id, rel in pairs(rels) do
		if rel.type == "friend" then
			table.insert(friends, {
				id = id,
				name = rel.name,
				role = "Friend",
				relationship = rel.relationship or 60,
				age = rel.age or self:getAge(),
				alive = rel.alive ~= false
			})
		end
	end
	
	-- Make friend card
	local makeCard = Instance.new("Frame")
	makeCard.Size = UDim2.new(1, 0, 0, 75)
	makeCard.BackgroundColor3 = C.PurplePale
	makeCard.LayoutOrder = 0
	makeCard.ZIndex = 82
	makeCard.Parent = self.contentScroll
	UI.corner(makeCard, 16)
	UI.stroke(makeCard, 1, 0.7, C.Purple)
	
	local makeIcon = Instance.new("TextLabel")
	makeIcon.Size = UDim2.new(0, 50, 0, 50)
	makeIcon.Position = UDim2.new(0, 14, 0.5, -25)
	makeIcon.BackgroundTransparency = 1
	makeIcon.Font = F.Body
	makeIcon.TextSize = 32
	makeIcon.TextColor3 = C.Purple
	makeIcon.Text = "🤝"
	makeIcon.ZIndex = 83
	makeIcon.Parent = makeCard
	
	local makeTitle = Instance.new("TextLabel")
	makeTitle.Size = UDim2.new(0.5, 0, 0, 26)
	makeTitle.Position = UDim2.new(0, 74, 0.5, -13)
	makeTitle.BackgroundTransparency = 1
	makeTitle.Font = F.Title
	makeTitle.TextSize = 16
	makeTitle.TextColor3 = C.PurpleDark
	makeTitle.TextXAlignment = Enum.TextXAlignment.Left
	makeTitle.Text = "Make a New Friend"
	makeTitle.ZIndex = 83
	makeTitle.Parent = makeCard
	
	local makeBtn = Instance.new("TextButton")
	makeBtn.Size = UDim2.new(0, 80, 0, 40)
	makeBtn.AnchorPoint = Vector2.new(1, 0.5)
	makeBtn.Position = UDim2.new(1, -14, 0.5, 0)
	makeBtn.BackgroundColor3 = C.Purple
	makeBtn.Font = F.Button
	makeBtn.TextSize = 14
	makeBtn.TextColor3 = C.White
	makeBtn.Text = "Meet"
	makeBtn.AutoButtonColor = false
	makeBtn.ZIndex = 83
	makeBtn.Parent = makeCard
	UI.corner(makeBtn, 12)
	
	makeBtn.MouseEnter:Connect(function()
		UI.tween(makeBtn, TweenInfo.new(0.12), { BackgroundColor3 = C.PurpleDark })
	end)
	makeBtn.MouseLeave:Connect(function()
		UI.tween(makeBtn, TweenInfo.new(0.12), { BackgroundColor3 = C.Purple })
	end)
	makeBtn.MouseButton1Click:Connect(function()
		self:doInteraction("make_friend", "friend", nil)
	end)
	
	if #friends > 0 then
		local section = Instance.new("Frame")
		section.Name = "FriendsSection"
		section.Size = UDim2.new(1, 0, 0, 0)
		section.AutomaticSize = Enum.AutomaticSize.Y
		section.BackgroundColor3 = C.White
		section.LayoutOrder = 1
		section.ZIndex = 82
		section.Parent = self.contentScroll
		UI.corner(section, 18)
		UI.stroke(section, 1, 0.88, C.Gray200)
		UI.pad(section, 14, 14, 14, 16)
		
		local sectionLayout = Instance.new("UIListLayout")
		sectionLayout.Padding = UDim.new(0, 10)
		sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
		sectionLayout.Parent = section
		
		-- Header
		local header = Instance.new("Frame")
		header.Size = UDim2.new(1, 0, 0, 36)
		header.BackgroundTransparency = 1
		header.LayoutOrder = 0
		header.ZIndex = 83
		header.Parent = section
		
		local badge = Instance.new("Frame")
		badge.Size = UDim2.new(0, 90, 0, 32)
		badge.BackgroundColor3 = C.Purple
		badge.ZIndex = 84
		badge.Parent = header
		UI.pill(badge)
		
		local badgeLabel = Instance.new("TextLabel")
		badgeLabel.Size = UDim2.fromScale(1, 1)
		badgeLabel.BackgroundTransparency = 1
		badgeLabel.Font = F.Button
		badgeLabel.TextSize = 14
		badgeLabel.TextColor3 = C.White
		badgeLabel.Text = "Friends"
		badgeLabel.ZIndex = 85
		badgeLabel.Parent = badge
		
		for i, person in ipairs(friends) do
			self:createPersonCard(section, person, i, C.Purple, C.PurplePale, "friend")
		end
	else
		-- No friends message
		local noFriends = Instance.new("Frame")
		noFriends.Size = UDim2.new(1, 0, 0, 80)
		noFriends.BackgroundColor3 = C.White
		noFriends.LayoutOrder = 1
		noFriends.ZIndex = 82
		noFriends.Parent = self.contentScroll
		UI.corner(noFriends, 16)
		UI.stroke(noFriends, 1, 0.88, C.Gray200)
		
		local noText = Instance.new("TextLabel")
		noText.Size = UDim2.new(1, -40, 1, 0)
		noText.Position = UDim2.new(0, 20, 0, 0)
		noText.BackgroundTransparency = 1
		noText.Font = F.Body
		noText.TextSize = 14
		noText.TextColor3 = C.Gray500
		noText.Text = "No friends yet.\nTap 'Meet' above to make a friend!"
		noText.ZIndex = 83
		noText.Parent = noFriends
	end
end

function RelationshipsScreen:populateEnemies()
	self:updateInfoBar()
	
	local enemies = {}
	local rels = self:getRelationships()
	for id, rel in pairs(rels) do
		if rel.type == "enemy" then
			table.insert(enemies, {
				id = id,
				name = rel.name,
				role = "Enemy",
				relationship = rel.relationship or 20,
				age = rel.age or self:getAge(),
				alive = rel.alive ~= false
			})
		end
	end
	
	if #enemies > 0 then
		local section = Instance.new("Frame")
		section.Name = "EnemiesSection"
		section.Size = UDim2.new(1, 0, 0, 0)
		section.AutomaticSize = Enum.AutomaticSize.Y
		section.BackgroundColor3 = C.White
		section.LayoutOrder = 1
		section.ZIndex = 82
		section.Parent = self.contentScroll
		UI.corner(section, 18)
		UI.stroke(section, 1, 0.88, C.Gray200)
		UI.pad(section, 14, 14, 14, 16)
		
		local sectionLayout = Instance.new("UIListLayout")
		sectionLayout.Padding = UDim.new(0, 10)
		sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
		sectionLayout.Parent = section
		
		-- Header
		local header = Instance.new("Frame")
		header.Size = UDim2.new(1, 0, 0, 36)
		header.BackgroundTransparency = 1
		header.LayoutOrder = 0
		header.ZIndex = 83
		header.Parent = section
		
		local badge = Instance.new("Frame")
		badge.Size = UDim2.new(0, 90, 0, 32)
		badge.BackgroundColor3 = C.Red
		badge.ZIndex = 84
		badge.Parent = header
		UI.pill(badge)
		
		local badgeLabel = Instance.new("TextLabel")
		badgeLabel.Size = UDim2.fromScale(1, 1)
		badgeLabel.BackgroundTransparency = 1
		badgeLabel.Font = F.Button
		badgeLabel.TextSize = 14
		badgeLabel.TextColor3 = C.White
		badgeLabel.Text = "Enemies"
		badgeLabel.ZIndex = 85
		badgeLabel.Parent = badge
		
		for i, person in ipairs(enemies) do
			self:createPersonCard(section, person, i, C.Red, C.RedPale, "enemy")
		end
	else
		-- No enemies (good!)
		local noEnemies = Instance.new("Frame")
		noEnemies.Size = UDim2.new(1, 0, 0, 100)
		noEnemies.BackgroundColor3 = C.GreenPale
		noEnemies.LayoutOrder = 1
		noEnemies.ZIndex = 82
		noEnemies.Parent = self.contentScroll
		UI.corner(noEnemies, 16)
		UI.stroke(noEnemies, 1, 0.7, C.Green)
		
		local icon = Instance.new("TextLabel")
		icon.Size = UDim2.new(1, 0, 0, 40)
		icon.Position = UDim2.new(0, 0, 0, 18)
		icon.BackgroundTransparency = 1
		icon.Font = F.Title
		icon.TextSize = 26
		icon.TextColor3 = C.Green
		icon.Text = "No Enemies!"
		icon.ZIndex = 83
		icon.Parent = noEnemies
		
		local text = Instance.new("TextLabel")
		text.Size = UDim2.new(1, -40, 0, 30)
		text.Position = UDim2.new(0, 20, 0, 60)
		text.BackgroundTransparency = 1
		text.Font = F.Body
		text.TextSize = 14
		text.TextColor3 = C.GreenDark
		text.Text = "Everyone likes you... for now!"
		text.ZIndex = 83
		text.Parent = noEnemies
	end
end

function RelationshipsScreen:createPersonCard(parent, person, order, accentColor, paleColor, relType)
	local card = Instance.new("Frame")
	card.Name = person.id
	card.Size = UDim2.new(1, 0, 0, 100)
	card.BackgroundColor3 = C.White
	card.LayoutOrder = order
	card.ZIndex = 83
	card.Parent = parent
	UI.corner(card, 16)
	UI.stroke(card, 1, 0.7, accentColor)
	
	-- Avatar with emoji
	local avatarFrame = Instance.new("Frame")
	avatarFrame.Size = UDim2.new(0, 60, 0, 60)
	avatarFrame.Position = UDim2.new(0, 14, 0.5, -30)
	avatarFrame.BackgroundColor3 = paleColor
	avatarFrame.ZIndex = 84
	avatarFrame.Parent = card
	UI.corner(avatarFrame, 14)
	
	-- Use emoji if available, otherwise generate from role
	local emoji = person.emoji or self:getFamilyEmoji(person.role or "")
	
	local avatarLabel = Instance.new("TextLabel")
	avatarLabel.Size = UDim2.fromScale(1, 1)
	avatarLabel.BackgroundTransparency = 1
	avatarLabel.Font = F.Body
	avatarLabel.TextSize = 32
	avatarLabel.TextColor3 = accentColor
	avatarLabel.Text = emoji
	avatarLabel.ZIndex = 85
	avatarLabel.Parent = avatarFrame
	
	-- Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.4, 0, 0, 22)
	nameLabel.Position = UDim2.new(0, 88, 0, 12)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = F.Title
	nameLabel.TextSize = 16
	nameLabel.TextColor3 = C.Gray900
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = person.name
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.ZIndex = 84
	nameLabel.Parent = card
	
	-- Role badge
	local roleBadge = Instance.new("Frame")
	roleBadge.Size = UDim2.new(0, 85, 0, 24)
	roleBadge.Position = UDim2.new(0, 88, 0, 38)
	roleBadge.BackgroundColor3 = paleColor
	roleBadge.ZIndex = 84
	roleBadge.Parent = card
	UI.pill(roleBadge)
	
	local roleLabel = Instance.new("TextLabel")
	roleLabel.Size = UDim2.fromScale(1, 1)
	roleLabel.BackgroundTransparency = 1
	roleLabel.Font = F.Medium
	roleLabel.TextSize = 11
	roleLabel.TextColor3 = accentColor
	roleLabel.Text = person.role
	roleLabel.ZIndex = 85
	roleLabel.Parent = roleBadge
	
	-- Relationship bar
	local relPct = math.clamp((person.relationship or 50) / 100, 0, 1)
	local relColor = relPct >= 0.7 and C.Green or relPct >= 0.4 and C.Amber or C.Red
	
	local relBarBg = Instance.new("Frame")
	relBarBg.Size = UDim2.new(0.28, 0, 0, 10)
	relBarBg.Position = UDim2.new(0, 88, 0, 68)
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
	relLabel.Size = UDim2.new(0, 45, 0, 18)
	relLabel.Position = UDim2.new(0, 88 + (parent.AbsoluteSize.X * 0.28) + 8, 0, 64)
	relLabel.BackgroundTransparency = 1
	relLabel.Font = F.Medium
	relLabel.TextSize = 12
	relLabel.TextColor3 = relColor
	relLabel.TextXAlignment = Enum.TextXAlignment.Left
	relLabel.Text = math.floor(person.relationship or 50) .. "%"
	relLabel.ZIndex = 84
	relLabel.Parent = card
	
	-- Alive/Dead indicator
	if not person.alive then
		local deceasedBadge = Instance.new("Frame")
		deceasedBadge.Size = UDim2.new(0, 70, 0, 22)
		deceasedBadge.Position = UDim2.new(0, 88, 0, 82)
		deceasedBadge.BackgroundColor3 = C.Gray400
		deceasedBadge.ZIndex = 84
		deceasedBadge.Parent = card
		UI.pill(deceasedBadge)
		
		local deceasedLabel = Instance.new("TextLabel")
		deceasedLabel.Size = UDim2.fromScale(1, 1)
		deceasedLabel.BackgroundTransparency = 1
		deceasedLabel.Font = F.Medium
		deceasedLabel.TextSize = 10
		deceasedLabel.TextColor3 = C.White
		deceasedLabel.Text = "Deceased"
		deceasedLabel.ZIndex = 85
		deceasedLabel.Parent = deceasedBadge
	end
	
	-- Interact button
	local interactBtn = Instance.new("TextButton")
	interactBtn.Size = UDim2.new(0, 78, 0, 44)
	interactBtn.AnchorPoint = Vector2.new(1, 0.5)
	interactBtn.Position = UDim2.new(1, -14, 0.5, 0)
	interactBtn.BackgroundColor3 = person.alive and accentColor or C.Gray300
	interactBtn.Font = F.Button
	interactBtn.TextSize = 14
	interactBtn.TextColor3 = person.alive and C.White or C.Gray500
	interactBtn.Text = person.alive and "Interact" or "Gone"
	interactBtn.AutoButtonColor = false
	interactBtn.ZIndex = 84
	interactBtn.Parent = card
	UI.corner(interactBtn, 12)
	
	if person.alive then
		interactBtn.MouseEnter:Connect(function()
			UI.tween(interactBtn, TweenInfo.new(0.12), { BackgroundColor3 = accentColor:Lerp(C.Black, 0.15) })
			UI.tween(card, TweenInfo.new(0.12), { BackgroundColor3 = paleColor:Lerp(C.White, 0.6) })
		end)
		interactBtn.MouseLeave:Connect(function()
			UI.tween(interactBtn, TweenInfo.new(0.12), { BackgroundColor3 = accentColor })
			UI.tween(card, TweenInfo.new(0.12), { BackgroundColor3 = C.White })
		end)
		interactBtn.MouseButton1Click:Connect(function()
			self:showInteractionModal(person, relType, accentColor, paleColor)
		end)
	end
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
	card.Size = UDim2.new(0.92, 0, 0, 450)
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.fromScale(0.5, 0.5)
	card.BackgroundColor3 = C.White
	card.ZIndex = 95
	card.Parent = self.interactOverlay
	UI.corner(card, 24)
	self.interactCard = card
	
	-- Header
	self.interactHeader = Instance.new("Frame")
	self.interactHeader.Size = UDim2.new(1, 0, 0, 85)
	self.interactHeader.BackgroundColor3 = C.Pink
	self.interactHeader.ZIndex = 96
	self.interactHeader.Parent = card
	UI.corner(self.interactHeader, 24)
	
	-- Bottom cover
	local headerCover = Instance.new("Frame")
	headerCover.Name = "HeaderCover"
	headerCover.Size = UDim2.new(1, 0, 0, 30)
	headerCover.Position = UDim2.new(0, 0, 1, -30)
	headerCover.BackgroundColor3 = C.Pink
	headerCover.BorderSizePixel = 0
	headerCover.ZIndex = 96
	headerCover.Parent = self.interactHeader
	
	-- Name in header
	self.interactName = Instance.new("TextLabel")
	self.interactName.Size = UDim2.new(0.65, 0, 0, 28)
	self.interactName.Position = UDim2.new(0, 20, 0, 20)
	self.interactName.BackgroundTransparency = 1
	self.interactName.Font = F.Title
	self.interactName.TextSize = 22
	self.interactName.TextColor3 = C.White
	self.interactName.TextXAlignment = Enum.TextXAlignment.Left
	self.interactName.Text = "Name"
	self.interactName.ZIndex = 97
	self.interactName.Parent = self.interactHeader
	
	-- Status in header
	self.interactStatus = Instance.new("TextLabel")
	self.interactStatus.Size = UDim2.new(0.6, 0, 0, 22)
	self.interactStatus.Position = UDim2.new(0, 20, 0, 50)
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
	closeBtn.Text = "X"
	closeBtn.AutoButtonColor = false
	closeBtn.ZIndex = 98
	closeBtn.Parent = self.interactHeader
	UI.corner(closeBtn, 10)
	closeBtn.MouseButton1Click:Connect(function()
		self:hideInteractionModal()
	end)
	
	-- Actions scroll
	self.actionsScroll = Instance.new("ScrollingFrame")
	self.actionsScroll.Size = UDim2.new(1, -28, 1, -100)
	self.actionsScroll.Position = UDim2.new(0, 14, 0, 95)
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
	self.interactHeader:FindFirstChild("HeaderCover").BackgroundColor3 = accentColor
	self.interactName.Text = person.name
	self.interactStatus.Text = person.role .. " | " .. math.floor(person.relationship or 50) .. "% Relationship"
	
	-- Clear old actions
	for _, child in ipairs(self.actionsScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	
	-- Get actions based on relationship type
	local actions = {}
	if relType == "family" then
		actions = FamilyActions
	elseif relType == "romance" then
		actions = RomanceActions
	elseif relType == "friend" then
		actions = FriendActions
	elseif relType == "enemy" then
		actions = EnemyActions
	end
	
	for i, action in ipairs(actions) do
		self:createActionButton(action, i, accentColor, paleColor, person)
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

function RelationshipsScreen:createActionButton(action, order, accentColor, paleColor, person)
	local money = self:getMoney()
	local cost = action.cost or 0
	-- Free actions (cost = 0) are always available!
	local canAfford = (cost == 0) or (money >= cost)
	
	local card = Instance.new("Frame")
	card.Name = action.id
	card.Size = UDim2.new(1, 0, 0, 62)
	card.BackgroundColor3 = C.White
	card.LayoutOrder = order
	card.ZIndex = 97
	card.Parent = self.actionsScroll
	UI.corner(card, 14)
	UI.stroke(card, 1, canAfford and 0.7 or 0.88, canAfford and accentColor or C.Gray200)
	
	-- Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.5, 0, 0, 22)
	nameLabel.Position = UDim2.new(0, 16, 0, 10)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = F.Title
	nameLabel.TextSize = 15
	nameLabel.TextColor3 = C.Gray900
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = action.name
	nameLabel.ZIndex = 98
	nameLabel.Parent = card
	
	-- Effect badge - show FREE for no-cost actions
	local effectText = action.effect
	local badgeBg = paleColor
	local badgeTextColor = accentColor
	
	if cost > 0 then
		effectText = action.effect .. " | $" .. cost
		badgeBg = canAfford and C.AmberPale or C.RedPale
		badgeTextColor = canAfford and C.AmberDark or C.RedDark
	else
		effectText = action.effect .. " | FREE"
		badgeBg = C.GreenPale
		badgeTextColor = C.GreenDark
	end
	
	local effectBadge = Instance.new("Frame")
	effectBadge.Size = UDim2.new(0, math.clamp(#effectText * 7 + 20, 100, 180), 0, 24)
	effectBadge.Position = UDim2.new(0, 16, 0, 34)
	effectBadge.BackgroundColor3 = badgeBg
	effectBadge.ZIndex = 98
	effectBadge.Parent = card
	UI.pill(effectBadge)
	
	local effectLabel = Instance.new("TextLabel")
	effectLabel.Size = UDim2.fromScale(1, 1)
	effectLabel.BackgroundTransparency = 1
	effectLabel.Font = F.Medium
	effectLabel.TextSize = 11
	effectLabel.TextColor3 = badgeTextColor
	effectLabel.Text = effectText
	effectLabel.ZIndex = 99
	effectLabel.Parent = effectBadge
	
	-- Button
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 60, 0, 38)
	btn.AnchorPoint = Vector2.new(1, 0.5)
	btn.Position = UDim2.new(1, -12, 0.5, 0)
	btn.BackgroundColor3 = canAfford and accentColor or C.Gray300
	btn.Font = F.Button
	btn.TextSize = 13
	btn.TextColor3 = canAfford and C.White or C.Gray500
	btn.Text = canAfford and "Do" or "Need $"
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
				self:doInteraction(action.id, self.currentInteractType, person)
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
	log("=== DOING INTERACTION ===")
	log("Action ID:", actionId, "Relation Type:", relType)
	log("Person:", person and person.name or "None", "Person ID:", person and person.id or "None")
	log("Player Money:", self:getMoney())
	
	if not DoInteraction then
		logWarn("DoInteraction remote not available!")
		self:showResult(false, "Server not available", "Error")
		return
	end
	
	local personId = person and person.id or nil
	log("Invoking server DoInteraction...")
	local result = DoInteraction:InvokeServer(actionId, relType, personId)
	log("Server response:", result and "received" or "nil")
	
	if result then
		log("Success:", result.success, "Message:", result.message)
		self:showResult(result.success, result.message, result.success and "Done!" or "Failed")
	else
		logWarn("Server returned nil!")
		self:showResult(false, "Server error", "Error")
	end
end

function RelationshipsScreen:showResult(success, message, emoji)
	local shellColor = success and C.Green or C.Red
	local shellStroke = success and C.GreenDark or C.RedDark
	local pale = success and C.GreenPale or C.RedPale
	
	self.resultModal.shell.BackgroundColor3 = shellColor
	self.resultModal.shellStroke.Color = shellStroke
	self.resultModal.emojiFrame.BackgroundColor3 = pale
	self.resultModal.emojiLabel.Text = emoji or (success and "OK" or "X")
	self.resultModal.titleLabel.Text = success and "Success!" or "Uh oh..."
	self.resultModal.titleLabel.TextColor3 = success and C.GreenDark or C.RedDark
	self.resultModal.messageLabel.Text = message or ""
	self.resultModal.okButton.BackgroundColor3 = shellColor
	
	UI.showModal(self.resultModal)
end

function RelationshipsScreen:show()
	log("=== SHOWING RelationshipsScreen ===")
	log("Current state - Age:", self:getAge(), "Money:", self:getMoney())
	local family = self:getFamily()
	log("Family members:", #family)
	for _, f in ipairs(family) do
		log("  -", f.name, "(", f.role, ") Age:", f.age, "Alive:", f.alive)
	end
	self:updateInfoBar()
	self:switchTab(self.currentTab)
	UI.slideInScreen(self.overlay, "right")
	self.isVisible = true
	log("✅ RelationshipsScreen is now visible")
end

function RelationshipsScreen:hide()
	log("=== HIDING RelationshipsScreen ===")
	UI.slideOutScreen(self.overlay, "right", function()
		self.resultModal.overlay.Visible = false
		self.interactOverlay.Visible = false
		log("✅ RelationshipsScreen hidden, modals cleaned up")
	end)
	self.isVisible = false
end

return RelationshipsScreen
