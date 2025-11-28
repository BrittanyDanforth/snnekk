-- StarterPlayerScripts / LifeClient (LocalScript)
-- BitLife-style UI: gender + name intro, life feed, stats, age button, event popups.

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local player = Players.LocalPlayer

----------------------------------------------------------------
-- REMOTES
----------------------------------------------------------------

local remotesFolder   = ReplicatedStorage:WaitForChild("LifeRemotes")
local RequestAgeUp    = remotesFolder:WaitForChild("RequestAgeUp")
local PresentEvent    = remotesFolder:WaitForChild("PresentEvent")
local SubmitChoice    = remotesFolder:WaitForChild("SubmitChoice")
local SyncState       = remotesFolder:WaitForChild("SyncState")
local SetLifeInfo     = remotesFolder:WaitForChild("SetLifeInfo")

----------------------------------------------------------------
-- STATE
----------------------------------------------------------------

local currentState    = nil
local awaitingEvent   = false
local hasShownAgeHint = false

----------------------------------------------------------------
-- HELPERS
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
-- ROOT GUI + BACKGROUND (light, not phone-frame)
----------------------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LifeGui"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local bg = Instance.new("Frame")
bg.Size = UDim2.fromScale(1, 1)
bg.BackgroundColor3 = Color3.fromRGB(232, 238, 248)
bg.Parent = screenGui

local bgGrad = Instance.new("UIGradient")
bgGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(244, 248, 255)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(229, 246, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(243, 232, 255)),
})
bgGrad.Rotation = 25
bgGrad.Parent = bg

-- main card
local root = Instance.new("Frame")
root.Name = "RootCard"
root.AnchorPoint = Vector2.new(0.5, 0.5)
root.Position = UDim2.fromScale(0.5, 0.5)
root.Size = UDim2.new(0.96, 0, 0.94, 0)
root.BackgroundColor3 = Color3.fromRGB(249, 250, 255)
root.Parent = bg
createUICorner(root, 28)
createUIStroke(root, 2, 0.8, Color3.fromRGB(203, 213, 225))

----------------------------------------------------------------
-- HEADER (avatar + name + age/year, money chip right)
----------------------------------------------------------------

local header = Instance.new("Frame")
header.Name = "Header"
header.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
header.Size = UDim2.new(1, -32, 0, 70)
header.Position = UDim2.new(0, 16, 0, 14)
header.Parent = root
createUICorner(header, 22)
createUIStroke(header, 1, 0.8, Color3.fromRGB(221, 231, 247))

local headerPad = Instance.new("UIPadding")
headerPad.PaddingLeft  = UDim.new(0, 16)
headerPad.PaddingRight = UDim.new(0, 16)
headerPad.Parent = header

local headerLayout = Instance.new("UIListLayout")
headerLayout.FillDirection = Enum.FillDirection.Horizontal
headerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
headerLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
headerLayout.Padding = UDim.new(0, 12)
headerLayout.Parent = header

local avatarFrame = Instance.new("Frame")
avatarFrame.Size = UDim2.new(0, 46, 0, 46)
avatarFrame.BackgroundColor3 = Color3.fromRGB(237, 244, 255)
avatarFrame.Parent = header
createUICorner(avatarFrame, 23)
createUIStroke(avatarFrame, 1, 0.7, Color3.fromRGB(191, 219, 254))

local avatarEmoji = Instance.new("TextLabel")
avatarEmoji.BackgroundTransparency = 1
avatarEmoji.Size = UDim2.fromScale(1, 1)
avatarEmoji.Font = BODY_FONT
avatarEmoji.TextSize = 26
avatarEmoji.TextColor3 = Color3.fromRGB(55, 65, 81)
avatarEmoji.Text = "👶"
avatarEmoji.Parent = avatarFrame

local nameAgeFrame = Instance.new("Frame")
nameAgeFrame.BackgroundTransparency = 1
nameAgeFrame.Size = UDim2.new(0.6, 0, 1, 0)
nameAgeFrame.Parent = header

local nameAgeLayout = Instance.new("UIListLayout")
nameAgeLayout.FillDirection = Enum.FillDirection.Vertical
nameAgeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
nameAgeLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
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
moneyChip.AnchorPoint = Vector2.new(1, 0.5)
moneyChip.Position = UDim2.new(1, -4, 0.5, 0)
moneyChip.Size = UDim2.new(0, 120, 0, 40)
moneyChip.Text = "$0"
moneyChip.Parent = header
createUICorner(moneyChip, 20)

----------------------------------------------------------------
-- MIDDLE: feed (center) + stats bar at bottom
----------------------------------------------------------------

-- Feed card
local feedCard = Instance.new("Frame")
feedCard.Name = "FeedCard"
feedCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
feedCard.Size = UDim2.new(1, -32, 1, -210)
feedCard.Position = UDim2.new(0, 16, 0, 96)
feedCard.Parent = root
createUICorner(feedCard, 22)
createUIStroke(feedCard, 1, 0.82, Color3.fromRGB(221, 231, 247))

local feedPad = Instance.new("UIPadding")
feedPad.PaddingLeft   = UDim.new(0, 18)
feedPad.PaddingRight  = UDim.new(0, 18)
feedPad.PaddingTop    = UDim.new(0, 14)
feedPad.PaddingBottom = UDim.new(0, 14)
feedPad.Parent = feedCard

local feedTitle = Instance.new("TextLabel")
feedTitle.BackgroundTransparency = 1
feedTitle.Size = UDim2.new(1, 0, 0, 26)
feedTitle.Font = TITLE_FONT
feedTitle.TextSize = 18
feedTitle.TextXAlignment = Enum.TextXAlignment.Left
feedTitle.TextColor3 = Color3.fromRGB(31, 41, 55)
feedTitle.Text = "Life Feed"
feedTitle.Parent = feedCard

local feedScroll = Instance.new("ScrollingFrame")
feedScroll.Name = "FeedScroll"
feedScroll.BackgroundTransparency = 1
feedScroll.Size = UDim2.new(1, 0, 1, -32)
feedScroll.Position = UDim2.new(0, 0, 0, 30)
feedScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
feedScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
feedScroll.ScrollBarThickness = 6
feedScroll.Parent = feedCard

local feedLayout = Instance.new("UIListLayout")
feedLayout.FillDirection = Enum.FillDirection.Vertical
feedLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
feedLayout.VerticalAlignment   = Enum.VerticalAlignment.Top
feedLayout.Padding = UDim.new(0, 8)
feedLayout.SortOrder = Enum.SortOrder.LayoutOrder
feedLayout.Parent = feedScroll

local function addFeedEntry(text)
	if not text or text == "" then
		return
	end

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
	tween(bubble, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
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
-- STATS BAR (bottom of screen)
----------------------------------------------------------------

local statsBar = Instance.new("Frame")
statsBar.Name = "StatsBar"
statsBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
statsBar.Size = UDim2.new(1, -32, 0, 70)
statsBar.AnchorPoint = Vector2.new(0.5, 1)
statsBar.Position = UDim2.new(0.5, 0, 1, -140)
statsBar.Parent = root
createUICorner(statsBar, 20)
createUIStroke(statsBar, 1, 0.85, Color3.fromRGB(221, 231, 247))

local statsPad = Instance.new("UIPadding")
statsPad.PaddingLeft  = UDim.new(0, 16)
statsPad.PaddingRight = UDim.new(0, 16)
statsPad.Parent = statsBar

local statsLayout = Instance.new("UIListLayout")
statsLayout.FillDirection = Enum.FillDirection.Horizontal
statsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
statsLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
statsLayout.Padding = UDim.new(0, 16)
statsLayout.Parent = statsBar

local statMeta = {
	{ key = "Happiness", icon = "😊", label = "Happiness" },
	{ key = "Health",    icon = "❤️", label = "Health"    },
	{ key = "Smarts",    icon = "🧠", label = "Smarts"    },
	{ key = "Looks",     icon = "✨", label = "Looks"     },
}

local statCards = {}

for _, info in ipairs(statMeta) do
	local holder = Instance.new("Frame")
	holder.BackgroundTransparency = 1
	holder.Size = UDim2.new(0.24, 0, 1, 0)
	holder.Parent = statsBar

	local nameLabelStat = Instance.new("TextLabel")
	nameLabelStat.BackgroundTransparency = 1
	nameLabelStat.Size = UDim2.new(1, 0, 0, 20)
	nameLabelStat.Font = BODY_FONT
	nameLabelStat.TextSize = 13
	nameLabelStat.TextXAlignment = Enum.TextXAlignment.Left
	nameLabelStat.TextColor3 = Color3.fromRGB(55, 65, 81)
	nameLabelStat.Text = info.label
	nameLabelStat.Parent = holder

	local valueLabel = Instance.new("TextLabel")
	valueLabel.BackgroundTransparency = 1
	valueLabel.Size = UDim2.new(0, 32, 0, 16)
	valueLabel.Position = UDim2.new(0, 0, 0, 22)
	valueLabel.Font = BODY_FONT
	valueLabel.TextSize = 12
	valueLabel.TextXAlignment = Enum.TextXAlignment.Left
	valueLabel.TextColor3 = Color3.fromRGB(107, 114, 128)
	valueLabel.Text = "0"
	valueLabel.Parent = holder

	local barBg = Instance.new("Frame")
	barBg.BackgroundColor3 = Color3.fromRGB(229, 231, 235)
	barBg.Size = UDim2.new(1, -40, 0, 8)
	barBg.Position = UDim2.new(0, 34, 0, 24)
	barBg.Parent = holder
	createUICorner(barBg, 4)

	local barFill = Instance.new("Frame")
	barFill.BackgroundColor3 = Color3.fromRGB(56, 189, 248)
	barFill.Size = UDim2.new(0, 0, 1, 0)
	barFill.Parent = barBg
	createUICorner(barFill, 4)

	statCards[info.key] = {
		valueLabel = valueLabel,
		barFill    = barFill,
	}
end

----------------------------------------------------------------
-- BOTTOM NAV + AGE BUTTON (BitLife style)
----------------------------------------------------------------

local bottom = Instance.new("Frame")
bottom.Name = "Bottom"
bottom.BackgroundTransparency = 1
bottom.Size = UDim2.new(1, -32, 0, 110)
bottom.AnchorPoint = Vector2.new(0.5, 1)
bottom.Position = UDim2.new(0.5, 0, 1, -10)
bottom.Parent = root

local navBar = Instance.new("Frame")
navBar.Name = "NavBar"
navBar.AnchorPoint = Vector2.new(0.5, 1)
navBar.Position = UDim2.new(0.5, 0, 1, 0)
navBar.Size = UDim2.new(1, 0, 0, 70)
navBar.BackgroundColor3 = Color3.fromRGB(27, 42, 89)
navBar.Parent = bottom
createUICorner(navBar, 22)

local navLayout = Instance.new("UIListLayout")
navLayout.FillDirection = Enum.FillDirection.Horizontal
navLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
navLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
navLayout.Padding = UDim.new(0, 18)
navLayout.Parent = navBar

local navItems = {
	{ icon = "📚", text = "Occupation" },
	{ icon = "💼", text = "Assets"     },
	{ icon = "❤️", text = "Relationships" },
	{ icon = "🎭", text = "Activities" },
	{ icon = "📊", text = "Stats"      },
}

for _, info in ipairs(navItems) do
	local btn = Instance.new("TextButton")
	btn.BackgroundTransparency = 1
	btn.AutoButtonColor = false
	btn.Size = UDim2.new(0, 80, 0, 48)
	btn.Parent = navBar

	local v = Instance.new("UIListLayout")
	v.FillDirection = Enum.FillDirection.Vertical
	v.HorizontalAlignment = Enum.HorizontalAlignment.Center
	v.VerticalAlignment   = Enum.VerticalAlignment.Center
	v.Parent = btn

	local icon = Instance.new("TextLabel")
	icon.BackgroundTransparency = 1
	icon.Size = UDim2.new(1, 0, 0, 22)
	icon.Font = BODY_FONT
	icon.TextSize = 18
	icon.TextColor3 = Color3.fromRGB(248, 250, 252)
	icon.Text = info.icon
	icon.Parent = btn

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 0, 18)
	label.Font = BODY_FONT
	label.TextSize = 11
	label.TextColor3 = Color3.fromRGB(148, 163, 184)
	label.Text = info.text
	label.Parent = btn

	btn.MouseEnter:Connect(function()
		icon.TextColor3 = Color3.fromRGB(251, 191, 36)
	end)
	btn.MouseLeave:Connect(function()
		icon.TextColor3 = Color3.fromRGB(248, 250, 252)
	end)
end

-- big green Age button sitting above nav bar
local ageButton = Instance.new("TextButton")
ageButton.Name = "AgeButton"
ageButton.AnchorPoint = Vector2.new(0.5, 1)
ageButton.Position = UDim2.new(0.5, 0, 0, -6)
ageButton.Size = UDim2.new(0, 110, 0, 110)
ageButton.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
ageButton.AutoButtonColor = false
ageButton.Text = ""
ageButton.ZIndex = 2
ageButton.Parent = bottom
createUICorner(ageButton, 55)
createUIStroke(ageButton, 3, 0.2, Color3.fromRGB(21, 128, 61))

local agePlus = Instance.new("TextLabel")
agePlus.BackgroundTransparency = 1
agePlus.Size = UDim2.new(1, 0, 0, 40)
agePlus.Position = UDim2.new(0, 0, 0, 18)
agePlus.Font = TITLE_FONT
agePlus.TextSize = 34
agePlus.TextColor3 = Color3.new(1, 1, 1)
agePlus.Text = "+"
agePlus.Parent = ageButton

local ageText = Instance.new("TextLabel")
ageText.BackgroundTransparency = 1
ageText.Size = UDim2.new(1, 0, 0, 30)
ageText.Position = UDim2.new(0, 0, 0, 56)
ageText.Font = CHIP_FONT
ageText.TextSize = 20
ageText.TextColor3 = Color3.new(1, 1, 1)
ageText.Text = "Age"
ageText.Parent = ageButton

-- small hint text above Age (BitLife tutorial vibe)
local ageHint = Instance.new("TextLabel")
ageHint.BackgroundTransparency = 1
ageHint.Size = UDim2.new(1, 0, 0, 40)
ageHint.AnchorPoint = Vector2.new(0.5, 1)
ageHint.Position = UDim2.new(0.5, 0, 0, -118)
ageHint.Font = BODY_FONT
ageHint.TextSize = 16
ageHint.TextColor3 = Color3.fromRGB(55, 65, 81)
ageHint.Text = "Press Age to grow older one year at a time."
ageHint.Visible = false
ageHint.Parent = bottom

----------------------------------------------------------------
-- EVENT MODAL (BitLife-style red header + blue buttons)
----------------------------------------------------------------

local eventOverlay = Instance.new("Frame")
eventOverlay.Name = "EventOverlay"
eventOverlay.Size = UDim2.fromScale(1, 1)
eventOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
eventOverlay.BackgroundTransparency = 0.45
eventOverlay.Visible = false
eventOverlay.ZIndex = 20
eventOverlay.Parent = screenGui

local eventCard = Instance.new("Frame")
eventCard.AnchorPoint = Vector2.new(0.5, 0.5)
eventCard.Position = UDim2.fromScale(0.5, 0.5)
eventCard.Size = UDim2.new(0, 360, 0, 440)
eventCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
eventCard.Parent = eventOverlay
createUICorner(eventCard, 24)
createUIStroke(eventCard, 2, 0.25, Color3.fromRGB(209, 213, 219))

local eventHeader = Instance.new("Frame")
eventHeader.BackgroundColor3 = Color3.fromRGB(239, 68, 68) -- red strip top
eventHeader.Size = UDim2.new(1, 0, 0, 70)
eventHeader.Parent = eventCard
createUICorner(eventHeader, 24)
eventHeader.ClipsDescendants = true

local eventEmoji = Instance.new("TextLabel")
eventEmoji.BackgroundTransparency = 1
eventEmoji.Size = UDim2.new(0, 40, 0, 40)
eventEmoji.Position = UDim2.new(0, 18, 0, 15)
eventEmoji.Font = BODY_FONT
eventEmoji.TextSize = 32
eventEmoji.TextColor3 = Color3.new(1, 1, 1)
eventEmoji.Text = "🙂"
eventEmoji.Parent = eventHeader

local eventTitle = Instance.new("TextLabel")
eventTitle.BackgroundTransparency = 1
eventTitle.Size = UDim2.new(1, -80, 0, 40)
eventTitle.Position = UDim2.new(0, 70, 0, 16)
eventTitle.Font = TITLE_FONT
eventTitle.TextSize = 20
eventTitle.TextXAlignment = Enum.TextXAlignment.Left
eventTitle.TextColor3 = Color3.new(1, 1, 1)
eventTitle.Text = "Life Event"
eventTitle.Parent = eventHeader

local eventBody = Instance.new("TextLabel")
eventBody.BackgroundTransparency = 1
eventBody.Size = UDim2.new(1, -40, 0, 100)
eventBody.Position = UDim2.new(0, 20, 0, 90)
eventBody.Font = BODY_FONT
eventBody.TextSize = 16
eventBody.TextWrapped = true
eventBody.TextXAlignment = Enum.TextXAlignment.Left
eventBody.TextYAlignment = Enum.TextYAlignment.Top
eventBody.TextColor3 = Color3.fromRGB(31, 41, 55)
eventBody.Text = "Event text here"
eventBody.Parent = eventCard

local choicesHolder = Instance.new("Frame")
choicesHolder.BackgroundTransparency = 1
choicesHolder.Size = UDim2.new(1, -40, 0, 220)
choicesHolder.Position = UDim2.new(0, 20, 0, 190)
choicesHolder.Parent = eventCard

local choicesLayout = Instance.new("UIListLayout")
choicesLayout.FillDirection = Enum.FillDirection.Vertical
choicesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
choicesLayout.VerticalAlignment   = Enum.VerticalAlignment.Top
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

local function showEvent(payload)
	awaitingEvent = true
	currentEventId = payload.id

	eventEmoji.Text = "🙂"
	eventTitle.Text = (payload.title or "Unfriended")
	if payload.id == "first_steps" then
		eventTitle.Text = "First Steps!"
	end

	eventBody.Text = payload.text or ""
	clearChoices()

	for _, choice in ipairs(payload.choices or {}) do
		local btn = Instance.new("TextButton")
		btn.BackgroundColor3 = Color3.fromRGB(37, 99, 235) -- blue pill
		btn.AutoButtonColor = false
		btn.Size = UDim2.new(1, 0, 0, 48)
		btn.Font = CHIP_FONT
		btn.TextSize = 16
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Text = choice.text
		btn.Parent = choicesHolder
		createUICorner(btn, 22)
		createUIStroke(btn, 1, 0.15, Color3.fromRGB(30, 64, 175))

		table.insert(activeChoiceButtons, btn)

		btn.MouseEnter:Connect(function()
			btn.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
		end)
		btn.MouseLeave:Connect(function()
			btn.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
		end)

		btn.MouseButton1Click:Connect(function()
			if not awaitingEvent then
				return
			end
			awaitingEvent = false

			for _, other in ipairs(activeChoiceButtons) do
				other.AutoButtonColor = false
				other.Active = false
			end

			SubmitChoice:FireServer(payload.id, choice.id)
			eventOverlay.Visible = false
		end)
	end

	eventOverlay.Visible = true
end

----------------------------------------------------------------
-- INTRO FLOW: gender → name (3 pills)
----------------------------------------------------------------

local maleFirst = {
	"Anthony","Scott","Logan","Ethan","Noah","Liam","Mason","Jayden","Caleb","Damian",
}
local femaleFirst = {
	"Olivia","Emma","Ava","Sophia","Mia","Amelia","Isabella","Charlotte","Luna","Stella",
}
local lastNames = {
	"Russell","Allen","Flores","Cooper","Parker","Reed","Mitchell","Walker","Gray","Brooks",
}

local selectedGender = nil
local selectedName   = nil

-- overlay 1: gender
local genderOverlay = Instance.new("Frame")
genderOverlay.Name = "GenderOverlay"
genderOverlay.Size = UDim2.fromScale(1, 1)
genderOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
genderOverlay.BackgroundTransparency = 0.4
genderOverlay.Visible = false
genderOverlay.ZIndex = 15
genderOverlay.Parent = screenGui

local genderCard = Instance.new("Frame")
genderCard.AnchorPoint = Vector2.new(0.5, 0.5)
genderCard.Position = UDim2.fromScale(0.5, 0.5)
genderCard.Size = UDim2.new(0, 380, 0, 240)
genderCard.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
genderCard.BackgroundTransparency = 0.15
genderCard.Parent = genderOverlay
createUICorner(genderCard, 22)
createUIStroke(genderCard, 2, 0.25, Color3.fromRGB(0, 0, 0))

local genderTitle = Instance.new("TextLabel")
genderTitle.BackgroundTransparency = 1
genderTitle.Size = UDim2.new(1, 0, 0, 40)
genderTitle.Position = UDim2.new(0, 0, 0, 28)
genderTitle.Font = BODY_FONT
genderTitle.TextSize = 18
genderTitle.TextColor3 = Color3.fromRGB(252, 211, 77)
genderTitle.Text = "Start by picking a gender."
genderTitle.Parent = genderCard

local genderButtonsHolder = Instance.new("Frame")
genderButtonsHolder.BackgroundTransparency = 1
genderButtonsHolder.Size = UDim2.new(1, -40, 0, 120)
genderButtonsHolder.Position = UDim2.new(0, 20, 0, 80)
genderButtonsHolder.Parent = genderCard

local genderButtonsLayout = Instance.new("UIListLayout")
genderButtonsLayout.FillDirection = Enum.FillDirection.Vertical
genderButtonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
genderButtonsLayout.VerticalAlignment   = Enum.VerticalAlignment.Top
genderButtonsLayout.Padding = UDim.new(0, 10)
genderButtonsLayout.Parent = genderButtonsHolder

local function createGenderButton(text, emoji, color, value)
	local btn = Instance.new("TextButton")
	btn.BackgroundColor3 = color
	btn.AutoButtonColor = false
	btn.Size = UDim2.new(1, 0, 0, 44)
	btn.Font = CHIP_FONT
	btn.TextSize = 18
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Text = emoji .. "  " .. text
	btn.Parent = genderButtonsHolder
	createUICorner(btn, 22)

	btn.MouseButton1Click:Connect(function()
		selectedGender = value
		genderOverlay.Visible = false
		-- open name overlay next
		selectedName = nil
		-- generate name options based on gender
		-- (implemented below, after name overlay is created)
	end)

	return btn
end

local maleBtn   = createGenderButton("Male",   "♂", Color3.fromRGB(56, 189, 248), "Male")
local femaleBtn = createGenderButton("Female", "♀", Color3.fromRGB(244, 114, 182), "Female")

-- overlay 2: 3 names
local nameOverlay = Instance.new("Frame")
nameOverlay.Name = "NameOverlay"
nameOverlay.Size = UDim2.fromScale(1, 1)
nameOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
nameOverlay.BackgroundTransparency = 0.4
nameOverlay.Visible = false
nameOverlay.ZIndex = 16
nameOverlay.Parent = screenGui

local nameCard = Instance.new("Frame")
nameCard.AnchorPoint = Vector2.new(0.5, 0.5)
nameCard.Position = UDim2.fromScale(0.5, 0.5)
nameCard.Size = UDim2.new(0, 380, 0, 260)
nameCard.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
nameCard.BackgroundTransparency = 0.12
nameCard.Parent = nameOverlay
createUICorner(nameCard, 22)
createUIStroke(nameCard, 2, 0.25, Color3.fromRGB(0, 0, 0))

local nameTitle = Instance.new("TextLabel")
nameTitle.BackgroundTransparency = 1
nameTitle.Size = UDim2.new(1, 0, 0, 40)
nameTitle.Position = UDim2.new(0, 0, 0, 24)
nameTitle.Font = BODY_FONT
nameTitle.TextSize = 18
nameTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
nameTitle.Text = "Now, pick someone to become."
nameTitle.Parent = nameCard

local namesHolder = Instance.new("Frame")
namesHolder.BackgroundTransparency = 1
namesHolder.Size = UDim2.new(1, -40, 0, 150)
namesHolder.Position = UDim2.new(0, 20, 0, 74)
namesHolder.Parent = nameCard

local namesLayout = Instance.new("UIListLayout")
namesLayout.FillDirection = Enum.FillDirection.Vertical
namesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
namesLayout.VerticalAlignment   = Enum.VerticalAlignment.Top
namesLayout.Padding = UDim.new(0, 8)
namesLayout.Parent = namesHolder

local nameButtons = {}

local function clearNameButtons()
	for _, b in ipairs(nameButtons) do
		b:Destroy()
	end
	table.clear(nameButtons)
end

local function randomFrom(list)
	return list[math.random(1, #list)]
end

local function generateNameOptions()
	clearNameButtons()
	if not selectedGender then
		return
	end

	for i = 1, 3 do
		local firstList = (selectedGender == "Female") and femaleFirst or maleFirst
		local fullName = randomFrom(firstList) .. " " .. randomFrom(lastNames)

		local btn = Instance.new("TextButton")
		btn.AutoButtonColor = false
		btn.Size = UDim2.new(1, 0, 0, 40)
		btn.Font = CHIP_FONT
		btn.TextSize = 18
		btn.TextColor3 = Color3.new(1, 1, 1)

		if i == 1 then
			btn.BackgroundColor3 = Color3.fromRGB(34, 197, 94) -- green
		elseif i == 2 then
			btn.BackgroundColor3 = Color3.fromRGB(234, 179, 8) -- yellow
		else
			btn.BackgroundColor3 = Color3.fromRGB(249, 115, 22) -- orange
		end

		btn.Text = fullName
		btn.Parent = namesHolder
		createUICorner(btn, 22)

		table.insert(nameButtons, btn)

		btn.MouseButton1Click:Connect(function()
			selectedName = fullName
			-- send to server
			SetLifeInfo:FireServer(selectedName, selectedGender)
			nameOverlay.Visible = false
			ageHint.Visible = true
		end)
	end
end

-- hook gender buttons to open name overlay + generate list
maleBtn.MouseButton1Click:Connect(function()
	selectedGender = "Male"
	genderOverlay.Visible = false
	nameOverlay.Visible = true
	generateNameOptions()
end)

femaleBtn.MouseButton1Click:Connect(function()
	selectedGender = "Female"
	genderOverlay.Visible = false
	nameOverlay.Visible = true
	generateNameOptions()
end)

----------------------------------------------------------------
-- STATE SYNC / UPDATE
----------------------------------------------------------------

local function updateFromState()
	if not currentState then
		return
	end

	local stats = currentState.Stats or {}

	for key, card in pairs(statCards) do
		local v = math.floor(stats[key] or 0)
		card.valueLabel.Text = tostring(v) .. "%"
		local pct = math.clamp(v / 100, 0, 1)
		card.barFill:TweenSize(
			UDim2.new(pct, 0, 1, 0),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Quad,
			0.15,
			true
		)
	end

	local displayName = currentState.Name or "New Life"
	nameLabel.Text = displayName

	local age  = currentState.Age or 0
	local year = currentState.Year or 2025
	ageYearLabel.Text = string.format("Age %d • Year %d", age, year)

	local money = currentState.Money or 0
	moneyChip.Text = "$" .. tostring(money)

	-- show intro overlays if name not set
	if not currentState.Name then
		ageButton.Visible   = false
		ageHint.Visible     = false
		genderOverlay.Visible = true
		nameOverlay.Visible   = false
	else
		ageButton.Visible = true
	end
end

SyncState.OnClientEvent:Connect(function(state, lastFeedText)
	currentState = state
	updateFromState()
	if lastFeedText then
		addFeedEntry(lastFeedText)
	end
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

local function pulseAgeButton()
	local ti = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	tween(ageButton, ti, { Size = UDim2.new(0, 118, 0, 118) }).Completed:Wait()
	tween(ageButton, ti, { Size = UDim2.new(0, 110, 0, 110) })
end

ageButton.MouseButton1Click:Connect(function()
	if awaitingEvent then
		return
	end
	if currentState and not currentState.Name then
		return
	end

	pulseAgeButton()
	ageHint.Visible = false
	RequestAgeUp:FireServer()
end)
