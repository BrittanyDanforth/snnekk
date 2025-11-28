-- LifeClient.client.lua
-- AAA-ish UI revamp + name/gender setup. All UI built in code.

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local player = Players.LocalPlayer

----------------------------------------------------------------
-- REMOTES
----------------------------------------------------------------

local remotesFolder = ReplicatedStorage:WaitForChild("LifeRemotes")
local RequestAgeUp  = remotesFolder:WaitForChild("RequestAgeUp")
local PresentEvent  = remotesFolder:WaitForChild("PresentEvent")
local SubmitChoice  = remotesFolder:WaitForChild("SubmitChoice")
local SyncState     = remotesFolder:WaitForChild("SyncState")
local SetLifeInfo   = remotesFolder:WaitForChild("SetLifeInfo")

local currentState = nil
local awaitingEvent = false

----------------------------------------------------------------
-- STYLE HELPERS
----------------------------------------------------------------

local TITLE_FONT = Enum.Font.FredokaOne
local BODY_FONT  = Enum.Font.Ubuntu
local CHIP_FONT  = Enum.Font.Roboto

local function createUICorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
	return c
end

local function createUIStroke(parent, thickness, transparency, color)
	local s = Instance.new("UIStroke")
	s.Thickness = thickness
	s.Transparency = transparency
	s.Color = color
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function tween(obj, info, props)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

----------------------------------------------------------------
-- ROOT SCREEN + BACKGROUND
----------------------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LifeGui"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local bg = Instance.new("Frame")
bg.Size = UDim2.fromScale(1, 1)
bg.BackgroundColor3 = Color3.fromRGB(235, 241, 255)
bg.Parent = screenGui

local bgGrad = Instance.new("UIGradient")
bgGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0,   Color3.fromRGB(244, 248, 255)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(229, 246, 255)),
	ColorSequenceKeypoint.new(1,   Color3.fromRGB(243, 232, 255)),
})
bgGrad.Rotation = 25
bgGrad.Parent = bg

-- main container (soft card, not heavy "phone")
local root = Instance.new("Frame")
root.Name = "RootCard"
root.AnchorPoint = Vector2.new(0.5, 0.5)
root.Position = UDim2.fromScale(0.5, 0.5)
root.Size = UDim2.new(0.94, 0, 0.9, 0)
root.BackgroundColor3 = Color3.fromRGB(248, 250, 255)
root.Parent = bg
createUICorner(root, 30)
createUIStroke(root, 2, 0.75, Color3.fromRGB(203, 213, 225))

----------------------------------------------------------------
-- HEADER
----------------------------------------------------------------

local header = Instance.new("Frame")
header.Name = "Header"
header.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
header.Size = UDim2.new(1, -32, 0, 68)
header.Position = UDim2.new(0, 16, 0, 14)
header.Parent = root
createUICorner(header, 24)
createUIStroke(header, 1, 0.8, Color3.fromRGB(221, 231, 247))

local headerPadding = Instance.new("UIPadding")
headerPadding.PaddingLeft = UDim.new(0, 16)
headerPadding.PaddingRight = UDim.new(0, 16)
headerPadding.Parent = header

local headerLayout = Instance.new("UIListLayout")
headerLayout.FillDirection = Enum.FillDirection.Horizontal
headerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
headerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
headerLayout.Padding = UDim.new(0, 12)
headerLayout.Parent = header

local avatarFrame = Instance.new("Frame")
avatarFrame.Size = UDim2.new(0, 44, 0, 44)
avatarFrame.BackgroundColor3 = Color3.fromRGB(239, 246, 255)
avatarFrame.Parent = header
createUICorner(avatarFrame, 22)
createUIStroke(avatarFrame, 1, 0.7, Color3.fromRGB(191, 219, 254))

local avatarEmoji = Instance.new("TextLabel")
avatarEmoji.BackgroundTransparency = 1
avatarEmoji.Size = UDim2.fromScale(1, 1)
avatarEmoji.Font = BODY_FONT
avatarEmoji.TextSize = 26
avatarEmoji.TextColor3 = Color3.fromRGB(59, 130, 246)
avatarEmoji.Text = "👶"
avatarEmoji.Parent = avatarFrame

local nameAgeFrame = Instance.new("Frame")
nameAgeFrame.BackgroundTransparency = 1
nameAgeFrame.Size = UDim2.new(0.6, 0, 1, 0)
nameAgeFrame.Parent = header

local nameAgeLayout = Instance.new("UIListLayout")
nameAgeLayout.FillDirection = Enum.FillDirection.Vertical
nameAgeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
nameAgeLayout.VerticalAlignment = Enum.VerticalAlignment.Center
nameAgeLayout.Padding = UDim.new(0, 2)
nameAgeLayout.Parent = nameAgeFrame

local nameLabel = Instance.new("TextLabel")
nameLabel.BackgroundTransparency = 1
nameLabel.Size = UDim2.new(1, 0, 0.55, 0)
nameLabel.Font = TITLE_FONT
nameLabel.TextSize = 20
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.TextColor3 = Color3.fromRGB(15, 23, 42)
nameLabel.Text = "New Life"
nameLabel.Parent = nameAgeFrame

local ageYearLabel = Instance.new("TextLabel")
ageYearLabel.BackgroundTransparency = 1
ageYearLabel.Size = UDim2.new(1, 0, 0.45, 0)
ageYearLabel.Font = BODY_FONT
ageYearLabel.TextSize = 14
ageYearLabel.TextXAlignment = Enum.TextXAlignment.Left
ageYearLabel.TextColor3 = Color3.fromRGB(107, 114, 128)
ageYearLabel.Text = "Age 0 • Year 2025"
ageYearLabel.Parent = nameAgeFrame

local moneyChip = Instance.new("TextLabel")
moneyChip.BackgroundColor3 = Color3.fromRGB(22, 163, 74)
moneyChip.Font = CHIP_FONT
moneyChip.TextSize = 18
moneyChip.TextColor3 = Color3.new(1, 1, 1)
moneyChip.TextXAlignment = Enum.TextXAlignment.Center
moneyChip.Text = "$0"
moneyChip.AnchorPoint = Vector2.new(1, 0.5)
moneyChip.Size = UDim2.new(0, 120, 0, 40)
moneyChip.Position = UDim2.new(1, -2, 0.5, 0)
moneyChip.Parent = header
createUICorner(moneyChip, 20)

----------------------------------------------------------------
-- MIDDLE AREA (stats + feed)
----------------------------------------------------------------

local middle = Instance.new("Frame")
middle.Name = "Middle"
middle.BackgroundTransparency = 1
middle.Size = UDim2.new(1, -32, 1, -210)
middle.Position = UDim2.new(0, 16, 0, 94)
middle.Parent = root

local middleLayout = Instance.new("UIListLayout")
middleLayout.FillDirection = Enum.FillDirection.Horizontal
middleLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
middleLayout.VerticalAlignment = Enum.VerticalAlignment.Top
middleLayout.Padding = UDim.new(0, 16)
middleLayout.Parent = middle

----------------------------------------------------------------
-- STATS COLUMN
----------------------------------------------------------------

local statsColumn = Instance.new("Frame")
statsColumn.Name = "StatsColumn"
statsColumn.BackgroundTransparency = 1
statsColumn.Size = UDim2.new(0.28, 0, 1, 0)
statsColumn.Parent = middle

local statsLayout = Instance.new("UIListLayout")
statsLayout.FillDirection = Enum.FillDirection.Vertical
statsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
statsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
statsLayout.Padding = UDim.new(0, 10)
statsLayout.Parent = statsColumn

local statCards = {}

local statMeta = {
	{ key = "Happiness", icon = "😊", label = "Happiness" },
	{ key = "Health",    icon = "❤️", label = "Health" },
	{ key = "Looks",     icon = "✨", label = "Looks" },
	{ key = "Smarts",    icon = "🧠", label = "Smarts" },
}

for _, info in ipairs(statMeta) do
	local card = Instance.new("Frame")	
	card.Name = info.key .. "Card"
	card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	card.Size = UDim2.new(1, 0, 0, 76)
	card.Parent = statsColumn
	createUICorner(card, 20)
	createUIStroke(card, 1, 0.85, Color3.fromRGB(221, 231, 247))

	local pad = Instance.new("UIPadding")
	pad.PaddingLeft   = UDim.new(0, 10)
	pad.PaddingRight  = UDim.new(0, 10)
	pad.PaddingTop    = UDim.new(0, 8)
	pad.PaddingBottom = UDim.new(0, 10)
	pad.Parent = card

	local iconLabel = Instance.new("TextLabel")
	iconLabel.BackgroundTransparency = 1
	iconLabel.Size = UDim2.new(0, 26, 0, 26)
	iconLabel.Font = BODY_FONT
	iconLabel.TextSize = 22
	iconLabel.TextColor3 = Color3.fromRGB(15, 23, 42)
	iconLabel.Text = info.icon
	iconLabel.Parent = card

	local textFrame = Instance.new("Frame")
	textFrame.BackgroundTransparency = 1
	textFrame.Size = UDim2.new(1, -32, 1, 0)
	textFrame.Position = UDim2.new(0, 30, 0, 0)
	textFrame.Parent = card

	local vLayout = Instance.new("UIListLayout")
	vLayout.FillDirection = Enum.FillDirection.Vertical
	vLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	vLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	vLayout.Padding = UDim.new(0, 4)
	vLayout.Parent = textFrame

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, 0, 0, 18)
	title.Font = CHIP_FONT
	title.TextSize = 14
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = Color3.fromRGB(55, 65, 81)
	title.Text = info.label
	title.Parent = textFrame

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Name = "ValueLabel"
	valueLabel.BackgroundTransparency = 1
	valueLabel.Size = UDim2.new(1, 0, 0, 16)
	valueLabel.Font = BODY_FONT
	valueLabel.TextSize = 13
	valueLabel.TextXAlignment = Enum.TextXAlignment.Left
	valueLabel.TextColor3 = Color3.fromRGB(107, 114, 128)
	valueLabel.Text = "0"
	valueLabel.Parent = textFrame

	local barBg = Instance.new("Frame")
	barBg.Name = "BarBg"
	barBg.BackgroundColor3 = Color3.fromRGB(229, 231, 235)
	barBg.Size = UDim2.new(1, -4, 0, 6)
	barBg.AnchorPoint = Vector2.new(0, 1)
	barBg.Position = UDim2.new(0, 2, 1, -2)
	barBg.Parent = card
	createUICorner(barBg, 3)

	local barFill = Instance.new("Frame")
	barFill.Name = "BarFill"
	barFill.BackgroundColor3 = Color3.fromRGB(56, 189, 248)
	barFill.Size = UDim2.new(0, 0, 1, 0)
	barFill.Parent = barBg
	createUICorner(barFill, 3)

	statCards[info.key] = {
		valueLabel = valueLabel,
		barFill    = barFill,
	}
end

----------------------------------------------------------------
-- FEED CARD
----------------------------------------------------------------

local feedCard = Instance.new("Frame")
feedCard.Name = "FeedCard"
feedCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
feedCard.Size = UDim2.new(0.72, 0, 1, 0)
feedCard.Parent = middle
createUICorner(feedCard, 24)
createUIStroke(feedCard, 1, 0.8, Color3.fromRGB(221, 231, 247))

local feedPad = Instance.new("UIPadding")
feedPad.PaddingLeft   = UDim.new(0, 16)
feedPad.PaddingRight  = UDim.new(0, 16)
feedPad.PaddingTop    = UDim.new(0, 12)
feedPad.PaddingBottom = UDim.new(0, 12)
feedPad.Parent = feedCard

local feedTitle = Instance.new("TextLabel")
feedTitle.BackgroundTransparency = 1
feedTitle.Size = UDim2.new(1, 0, 0, 28)
feedTitle.Font = TITLE_FONT
feedTitle.TextSize = 18
feedTitle.TextXAlignment = Enum.TextXAlignment.Left
feedTitle.TextColor3 = Color3.fromRGB(31, 41, 55)
feedTitle.Text = "Life Feed"
feedTitle.Parent = feedCard

local feedScroll = Instance.new("ScrollingFrame")
feedScroll.Name = "FeedScroll"
feedScroll.BackgroundTransparency = 1
feedScroll.Size = UDim2.new(1, 0, 1, -36)
feedScroll.Position = UDim2.new(0, 0, 0, 32)
feedScroll.ScrollBarThickness = 6
feedScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
feedScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
feedScroll.Parent = feedCard

local feedLayout = Instance.new("UIListLayout")
feedLayout.FillDirection = Enum.FillDirection.Vertical
feedLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
feedLayout.VerticalAlignment = Enum.VerticalAlignment.Top
feedLayout.Padding = UDim.new(0, 8)
feedLayout.SortOrder = Enum.SortOrder.LayoutOrder
feedLayout.Parent = feedScroll

local function addFeedEntry(text)
	if not text or text == "" then return end

	local bubble = Instance.new("Frame")
	bubble.BackgroundColor3 = Color3.fromRGB(248, 250, 252)
	bubble.Size = UDim2.new(1, 0, 0, 44)
	bubble.AutomaticSize = Enum.AutomaticSize.Y
	bubble.Parent = feedScroll
	createUICorner(bubble, 16)
	createUIStroke(bubble, 1, 0.9, Color3.fromRGB(229, 231, 235))

	local pad = Instance.new("UIPadding")
	pad.PaddingLeft   = UDim.new(0, 10)
	pad.PaddingRight  = UDim.new(0, 10)
	pad.PaddingTop    = UDim.new(0, 6)
	pad.PaddingBottom = UDim.new(0, 6)
	pad.Parent = bubble

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 0, 0)
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.Font = BODY_FONT
	label.TextSize = 15
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.TextColor3 = Color3.fromRGB(55, 65, 81)
	label.Text = text
	label.Parent = bubble

	bubble.BackgroundTransparency = 1
	tween(bubble, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0
	})

	task.delay(0.05, function()
		feedScroll.CanvasPosition = Vector2.new(
			0,
			math.max(0, feedScroll.AbsoluteCanvasSize.Y - feedScroll.AbsoluteWindowSize.Y)
		)
	end)
end

----------------------------------------------------------------
-- BOTTOM (AGE BUTTON + NAV)
----------------------------------------------------------------

local bottom = Instance.new("Frame")
bottom.Name = "Bottom"
bottom.BackgroundTransparency = 1
bottom.Size = UDim2.new(1, -32, 0, 120)
bottom.AnchorPoint = Vector2.new(0.5, 1)
bottom.Position = UDim2.new(0.5, 0, 1, -10)
bottom.Parent = root

local navBar = Instance.new("Frame")
navBar.Name = "NavBar"
navBar.AnchorPoint = Vector2.new(0.5, 1)
navBar.Position = UDim2.new(0.5, 0, 1, 0)
navBar.Size = UDim2.new(1, 0, 0, 70)
navBar.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
navBar.BackgroundTransparency = 0.02
navBar.ZIndex = 1
navBar.Parent = bottom
createUICorner(navBar, 24)

local navLayout = Instance.new("UIListLayout")
navLayout.FillDirection = Enum.FillDirection.Horizontal
navLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
navLayout.VerticalAlignment = Enum.VerticalAlignment.Center
navLayout.Padding = UDim.new(0, 10)
navLayout.Parent = navBar

local navItems = {
	{ icon = "🎓", text = "Education" },
	{ icon = "💼", text = "Career" },
	{ icon = "🏃", text = "Activities" },
	{ icon = "❤️", text = "Relationships" },
	{ icon = "💰", text = "Money" },
	{ icon = "🚓", text = "Crime" },
	{ icon = "⭐", text = "Special" },
	{ icon = "📈", text = "Progress" },
}

for _, info in ipairs(navItems) do
	local btn = Instance.new("TextButton")
	btn.BackgroundTransparency = 1
	btn.AutoButtonColor = false
	btn.Size = UDim2.new(0, 78, 0, 50)
	btn.Parent = navBar

	local v = Instance.new("UIListLayout")
	v.FillDirection = Enum.FillDirection.Vertical
	v.HorizontalAlignment = Enum.HorizontalAlignment.Center
	v.VerticalAlignment = Enum.VerticalAlignment.Center
	v.Parent = btn

	local icon = Instance.new("TextLabel")
	icon.BackgroundTransparency = 1
	icon.Size = UDim2.new(1, 0, 0.55, 0)
	icon.Font = BODY_FONT
	icon.TextSize = 18
	icon.TextColor3 = Color3.fromRGB(248, 250, 252)
	icon.Text = info.icon
	icon.Parent = btn

	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(1, 0, 0.45, 0)
	textLabel.Font = BODY_FONT
	textLabel.TextSize = 11
	textLabel.TextColor3 = Color3.fromRGB(148, 163, 184)
	textLabel.Text = info.text
	textLabel.Parent = btn

	btn.MouseEnter:Connect(function()
		icon.TextColor3 = Color3.fromRGB(251, 191, 36)
	end)
	btn.MouseLeave:Connect(function()
		icon.TextColor3 = Color3.fromRGB(248, 250, 252)
	end)
end

local ageButton = Instance.new("TextButton")
ageButton.Name = "AgeUpButton"
ageButton.AnchorPoint = Vector2.new(0.5, 1)
ageButton.Position = UDim2.new(0.5, 0, 0, -8)
ageButton.Size = UDim2.new(0, 210, 0, 60)
ageButton.BackgroundColor3 = Color3.fromRGB(22, 163, 74)
ageButton.AutoButtonColor = false
ageButton.Text = "+ Age Up"
ageButton.TextColor3 = Color3.new(1, 1, 1)
ageButton.Font = CHIP_FONT
ageButton.TextSize = 20
ageButton.ZIndex = 2
ageButton.Parent = bottom
createUICorner(ageButton, 30)
createUIStroke(ageButton, 2, 0.25, Color3.fromRGB(16, 95, 57))

local function pulseAgeButton()
	local ti = TweenInfo.new(0.09, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	tween(ageButton, ti, { Size = UDim2.new(0, 222, 0, 64) }).Completed:Wait()
	tween(ageButton, ti, { Size = UDim2.new(0, 210, 0, 60) })
end

----------------------------------------------------------------
-- EVENT MODAL
----------------------------------------------------------------

local overlay = Instance.new("Frame")
overlay.Name = "EventOverlay"
overlay.Size = UDim2.fromScale(1, 1)
overlay.BackgroundColor3 = Color3.new(0, 0, 0)
overlay.BackgroundTransparency = 0.4
overlay.Visible = false
overlay.ZIndex = 10
overlay.Parent = screenGui

local modal = Instance.new("Frame")
modal.Name = "EventModal"
modal.AnchorPoint = Vector2.new(0.5, 0.5)
modal.Position = UDim2.fromScale(0.5, 0.5)
modal.Size = UDim2.new(0.7, 0, 0.55, 0)
modal.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
modal.Parent = overlay
createUICorner(modal, 26)

local modalInner = Instance.new("Frame")
modalInner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
modalInner.Size = UDim2.new(1, -6, 1, -6)
modalInner.Position = UDim2.new(0, 3, 0, 3)
modalInner.Parent = modal
createUICorner(modalInner, 24)
createUIStroke(modalInner, 2, 0.4, Color3.fromRGB(59, 130, 246))

local modalHeader = Instance.new("Frame")
modalHeader.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
modalHeader.Size = UDim2.new(1, 0, 0, 50)
modalHeader.Parent = modalInner
createUICorner(modalHeader, 24)
modalHeader.ClipsDescendants = true

local modalTitle = Instance.new("TextLabel")
modalTitle.BackgroundTransparency = 1
modalTitle.Size = UDim2.new(1, -24, 1, 0)
modalTitle.Position = UDim2.new(0, 12, 0, 0)
modalTitle.Font = TITLE_FONT
modalTitle.TextSize = 20
modalTitle.TextXAlignment = Enum.TextXAlignment.Left
modalTitle.TextColor3 = Color3.new(1, 1, 1)
modalTitle.Text = "Life Event"
modalTitle.Parent = modalHeader

local modalBody = Instance.new("TextLabel")
modalBody.BackgroundTransparency = 1
modalBody.Size = UDim2.new(1, -32, 0, 80)
modalBody.Position = UDim2.new(0, 16, 0, 64)
modalBody.Font = BODY_FONT
modalBody.TextSize = 18
modalBody.TextWrapped = true
modalBody.TextXAlignment = Enum.TextXAlignment.Left
modalBody.TextYAlignment = Enum.TextYAlignment.Top
modalBody.TextColor3 = Color3.fromRGB(31, 41, 55)
modalBody.Text = "Event text here..."
modalBody.Parent = modalInner

local choicesHolder = Instance.new("Frame")
choicesHolder.BackgroundTransparency = 1
choicesHolder.Size = UDim2.new(1, -32, 1, -160)
choicesHolder.Position = UDim2.new(0, 16, 0, 150)
choicesHolder.Parent = modalInner

local choicesLayout = Instance.new("UIListLayout")
choicesLayout.FillDirection = Enum.FillDirection.Vertical
choicesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
choicesLayout.VerticalAlignment = Enum.VerticalAlignment.Top
choicesLayout.Padding = UDim.new(0, 10)
choicesLayout.Parent = choicesHolder

local activeChoiceButtons = {}
local currentEventId = nil

local function clearChoices()
	for _, b in ipairs(activeChoiceButtons) do
		b:Destroy()
	end
	table.clear(activeChoiceButtons)
end

local function showEvent(eventData)
	awaitingEvent = true
	currentEventId = eventData.id

	if eventData.id == "first_steps" then
		modalTitle.Text = "🍪 First Steps!"
	else
		modalTitle.Text = "📅 Life Event"
	end

	modalBody.Text = eventData.text or ""
	clearChoices()

	for _, choice in ipairs(eventData.choices or {}) do
		local btn = Instance.new("TextButton")
		btn.BackgroundColor3 = Color3.fromRGB(248, 250, 252)
		btn.AutoButtonColor = false
		btn.Size = UDim2.new(1, 0, 0, 52)
		btn.Font = CHIP_FONT
		btn.TextSize = 16
		btn.TextColor3 = Color3.fromRGB(30, 64, 175)
		btn.Text = choice.text
		btn.Parent = choicesHolder
		btn.ZIndex = overlay.ZIndex + 1
		createUICorner(btn, 14)
		createUIStroke(btn, 1, 0.6, Color3.fromRGB(191, 219, 254))

		table.insert(activeChoiceButtons, btn)

		btn.MouseEnter:Connect(function()
			btn.BackgroundColor3 = Color3.fromRGB(239, 246, 255)
		end)
		btn.MouseLeave:Connect(function()
			btn.BackgroundColor3 = Color3.fromRGB(248, 250, 252)
		end)

		btn.MouseButton1Click:Connect(function()
			if not awaitingEvent then return end
			awaitingEvent = false

			for _, b in ipairs(activeChoiceButtons) do
				b.Active = false
				b.AutoButtonColor = false
				b.BackgroundColor3 = Color3.fromRGB(229, 231, 235)
			end

			SubmitChoice:FireServer(eventData.id, choice.id)
			overlay.Visible = false
		end)
	end

	overlay.Visible = true
	tween(modal, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0.72, 0, 0.58, 0)
	}).Completed:Wait()
	tween(modal, TweenInfo.new(0.09, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0.7, 0, 0.55, 0)
	})
end

----------------------------------------------------------------
-- SETUP OVERLAY (gender + name)
----------------------------------------------------------------

local maleNames = {
	"Liam","Noah","Ethan","Logan","Mason","Lucas","Aiden","James","Leo","Kai",
	"Jaxon","Owen","Ezra","Miles","Caleb","Henry","Elijah","Jayden","Nolan","Damian"
}

local femaleNames = {
	"Olivia","Emma","Ava","Sophia","Mia","Amelia","Isabella","Charlotte","Harper","Luna",
	"Ella","Aria","Chloe","Layla","Mila","Scarlett","Zoey","Nova","Stella","Riley"
}

local setupOverlay = Instance.new("Frame")
setupOverlay.Name = "SetupOverlay"
setupOverlay.Size = UDim2.fromScale(1, 1)
setupOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
setupOverlay.BackgroundTransparency = 0.45
setupOverlay.Visible = false
setupOverlay.ZIndex = 20
setupOverlay.Parent = screenGui

local setupCard = Instance.new("Frame")
setupCard.Name = "SetupCard"
setupCard.AnchorPoint = Vector2.new(0.5, 0.5)
setupCard.Position = UDim2.fromScale(0.5, 0.5)
setupCard.Size = UDim2.new(0.6, 0, 0.6, 0)
setupCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
setupCard.Parent = setupOverlay
createUICorner(setupCard, 26)
createUIStroke(setupCard, 2, 0.4, Color3.fromRGB(191, 219, 254))

local setupPad = Instance.new("UIPadding")
setupPad.PaddingLeft   = UDim.new(0, 20)
setupPad.PaddingRight  = UDim.new(0, 20)
setupPad.PaddingTop    = UDim.new(0, 20)
setupPad.PaddingBottom = UDim.new(0, 20)
setupPad.Parent = setupCard

local setupTitle = Instance.new("TextLabel")
setupTitle.BackgroundTransparency = 1
setupTitle.Size = UDim2.new(1, 0, 0, 32)
setupTitle.Font = TITLE_FONT
setupTitle.TextSize = 24
setupTitle.TextXAlignment = Enum.TextXAlignment.Left
setupTitle.TextColor3 = Color3.fromRGB(15, 23, 42)
setupTitle.Text = "Create Your Life"
setupTitle.Parent = setupCard

local setupSubtitle = Instance.new("TextLabel")
setupSubtitle.BackgroundTransparency = 1
setupSubtitle.Size = UDim2.new(1, 0, 0, 24)
setupSubtitle.Position = UDim2.new(0, 0, 0, 34)
setupSubtitle.Font = BODY_FONT
setupSubtitle.TextSize = 16
setupSubtitle.TextXAlignment = Enum.TextXAlignment.Left
setupSubtitle.TextColor3 = Color3.fromRGB(107, 114, 128)
setupSubtitle.Text = "Choose your gender and pick a name."
setupSubtitle.Parent = setupCard

local genderLabel = Instance.new("TextLabel")
genderLabel.BackgroundTransparency = 1
genderLabel.Size = UDim2.new(1, 0, 0, 22)
genderLabel.Position = UDim2.new(0, 0, 0, 70)
genderLabel.Font = BODY_FONT
genderLabel.TextSize = 15
genderLabel.TextXAlignment = Enum.TextXAlignment.Left
genderLabel.TextColor3 = Color3.fromRGB(31, 41, 55)
genderLabel.Text = "Gender"
genderLabel.Parent = setupCard

local genderRow = Instance.new("Frame")
genderRow.BackgroundTransparency = 1
genderRow.Size = UDim2.new(1, 0, 0, 46)
genderRow.Position = UDim2.new(0, 0, 0, 94)
genderRow.Parent = setupCard

local genderLayout = Instance.new("UIListLayout")
genderLayout.FillDirection = Enum.FillDirection.Horizontal
genderLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
genderLayout.VerticalAlignment = Enum.VerticalAlignment.Center
genderLayout.Padding = UDim.new(0, 10)
genderLayout.Parent = genderRow

local selectedGender = nil
local selectedName   = nil
local nameButtons    = {}

local function clearNameButtons()
	for _, b in ipairs(nameButtons) do
		b:Destroy()
	end
	table.clear(nameButtons)
end

local function randomThreeNames(list)
	local copy = {}
	for _, n in ipairs(list) do
		table.insert(copy, n)
	end
	local result = {}
	for i = 1, 3 do
		if #copy == 0 then break end
		local idx = math.random(1, #copy)
		table.insert(result, copy[idx])
		table.remove(copy, idx)
	end
	return result
end

local namesLabel = Instance.new("TextLabel")
namesLabel.BackgroundTransparency = 1
namesLabel.Size = UDim2.new(1, 0, 0, 22)
namesLabel.Position = UDim2.new(0, 0, 0, 148)
namesLabel.Font = BODY_FONT
namesLabel.TextSize = 15
namesLabel.TextXAlignment = Enum.TextXAlignment.Left
namesLabel.TextColor3 = Color3.fromRGB(31, 41, 55)
namesLabel.Text = "Pick a name"
namesLabel.Parent = setupCard

local namesHolder = Instance.new("Frame")
namesHolder.BackgroundTransparency = 1
namesHolder.Size = UDim2.new(1, 0, 0, 120)
namesHolder.Position = UDim2.new(0, 0, 0, 174)
namesHolder.Parent = setupCard

local namesLayout = Instance.new("UIListLayout")
namesLayout.FillDirection = Enum.FillDirection.Vertical
namesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
namesLayout.VerticalAlignment = Enum.VerticalAlignment.Top
namesLayout.Padding = UDim.new(0, 8)
namesLayout.Parent = namesHolder

local function generateNameOptions()
	clearNameButtons()
	selectedName = nil

	local sourceList = selectedGender == "Female" and femaleNames or maleNames
	local options = randomThreeNames(sourceList)

	for _, name in ipairs(options) do
		local btn = Instance.new("TextButton")
		btn.BackgroundColor3 = Color3.fromRGB(248, 250, 252)
		btn.AutoButtonColor = false
		btn.Size = UDim2.new(1, 0, 0, 34)
		btn.Font = CHIP_FONT
		btn.TextSize = 16
		btn.TextColor3 = Color3.fromRGB(55, 65, 81)
		btn.Text = name
		btn.Parent = namesHolder
		createUICorner(btn, 16)
		createUIStroke(btn, 1, 0.8, Color3.fromRGB(209, 213, 219))

		table.insert(nameButtons, btn)

		btn.MouseButton1Click:Connect(function()
			if not selectedGender then return end
			selectedName = name
			for _, other in ipairs(nameButtons) do
				other.BackgroundColor3 = Color3.fromRGB(248, 250, 252)
				other.TextColor3 = Color3.fromRGB(55, 65, 81)
			end
			btn.BackgroundColor3 = Color3.fromRGB(219, 234, 254)
			btn.TextColor3 = Color3.fromRGB(30, 64, 175)
		end)
	end
end

local function makeGenderButton(text, emoji, value)
	local btn = Instance.new("TextButton")
	btn.BackgroundColor3 = Color3.fromRGB(248, 250, 252)
	btn.AutoButtonColor = false
	btn.Size = UDim2.new(0.5, -5, 1, 0)
	btn.Font = CHIP_FONT
	btn.TextSize = 16
	btn.TextColor3 = Color3.fromRGB(55, 65, 81)
	btn.Text = emoji .. "  " .. text
	btn.Parent = genderRow
	createUICorner(btn, 18)
	createUIStroke(btn, 1, 0.8, Color3.fromRGB(209, 213, 219))

	btn.MouseButton1Click:Connect(function()
		selectedGender = value
		for _, child in ipairs(genderRow:GetChildren()) do
			if child:IsA("TextButton") then
				child.BackgroundColor3 = Color3.fromRGB(248, 250, 252)
				child.TextColor3 = Color3.fromRGB(55, 65, 81)
			end
		end
		btn.BackgroundColor3 = Color3.fromRGB(219, 234, 254)
		btn.TextColor3 = Color3.fromRGB(30, 64, 175)

		generateNameOptions()
	end)
end

makeGenderButton("Male",   "♂", "Male")
makeGenderButton("Female", "♀", "Female")

local rerollButton = Instance.new("TextButton")
rerollButton.BackgroundTransparency = 1
rerollButton.AutoButtonColor = false
rerollButton.Size = UDim2.new(0, 100, 0, 24)
rerollButton.Position = UDim2.new(1, -110, 0, 146)
rerollButton.Font = BODY_FONT
rerollButton.TextSize = 13
rerollButton.TextXAlignment = Enum.TextXAlignment.Right
rerollButton.TextColor3 = Color3.fromRGB(59, 130, 246)
rerollButton.Text = "↻ Randomize"
rerollButton.Parent = setupCard

rerollButton.MouseButton1Click:Connect(function()
	if selectedGender then
		generateNameOptions()
	end
end)

local confirmButton = Instance.new("TextButton")
confirmButton.BackgroundColor3 = Color3.fromRGB(22, 163, 74)
confirmButton.AutoButtonColor = false
confirmButton.Size = UDim2.new(1, 0, 0, 46)
confirmButton.AnchorPoint = Vector2.new(0.5, 1)
confirmButton.Position = UDim2.new(0.5, 0, 1, -4)
confirmButton.Font = CHIP_FONT
confirmButton.TextSize = 18
confirmButton.TextColor3 = Color3.new(1, 1, 1)
confirmButton.Text = "Begin Life"
confirmButton.Parent = setupCard
createUICorner(confirmButton, 20)
createUIStroke(confirmButton, 1, 0.25, Color3.fromRGB(16, 95, 57))

confirmButton.MouseButton1Click:Connect(function()
	if not selectedGender or not selectedName then
		return
	end

	SetLifeInfo:FireServer(selectedName, selectedGender)
	setupOverlay.Visible = false
	ageButton.Visible = true
end)

local function openSetupIfNeeded()
	if currentState and not currentState.Name then
		ageButton.Visible = false
		setupOverlay.Visible = true
		selectedGender = nil
		selectedName = nil
		clearNameButtons()
	else
		ageButton.Visible = true
		setupOverlay.Visible = false
	end
end

----------------------------------------------------------------
-- STATE SYNC + UPDATES
----------------------------------------------------------------

local function updateStats()
	if not currentState then return end

	local stats = currentState.Stats or {}
	for key, data in pairs(statCards) do
		local v = math.floor(stats[key] or 0)
		data.valueLabel.Text = tostring(v)
		local pct = math.clamp(v / 100, 0, 1)
		data.barFill:TweenSize(
			UDim2.new(pct, 0, 1, 0),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Quad,
			0.12,
			true
		)
	end

	local displayName = currentState.Name or "New Life"
	nameLabel.Text = displayName
	ageYearLabel.Text = string.format("Age %d • Year %d", currentState.Age or 0, currentState.Year or 0)
	moneyChip.Text = "$" .. tostring(currentState.Money or 0)
end

SyncState.OnClientEvent:Connect(function(state, lastFeedText)
	currentState = state
	updateStats()
	if lastFeedText then
		addFeedEntry(lastFeedText)
	end
	openSetupIfNeeded()
end)

PresentEvent.OnClientEvent:Connect(function(eventData, ageFeedText)
	if ageFeedText then
		addFeedEntry(ageFeedText)
	end
	showEvent(eventData)
end)

----------------------------------------------------------------
-- INPUT
----------------------------------------------------------------

ageButton.MouseButton1Click:Connect(function()
	if awaitingEvent or (currentState and not currentState.Name) then
		return
	end
	pulseAgeButton()
	RequestAgeUp:FireServer()
end)
