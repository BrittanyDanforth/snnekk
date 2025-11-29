-- StarterPlayerScripts / LifeClient (LocalScript)
-- BitLife-style UI: POLISHED AAA-quality recreation
-- Fixed: Header avoids Roblox logo, stats don't conflict with Age button
-- Professional modals, smooth animations, premium feel

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local player = Players.LocalPlayer

----------------------------------------------------------------
-- SCREEN MODULES (with error handling)
----------------------------------------------------------------

local ScreensFolder = ReplicatedStorage:WaitForChild("Screens", 10)

local OccupationScreen, AssetsScreen, RelationshipsScreen, ActivitiesScreen, StoryPathsScreen
local MinigamesModule

if ScreensFolder then
	local function safeRequire(name)
		local s, r = pcall(function() return require(ScreensFolder:WaitForChild(name, 5)) end)
		return s and r or nil
	end
	OccupationScreen   = safeRequire("OccupationScreen")
	AssetsScreen       = safeRequire("AssetsScreen")
	RelationshipsScreen= safeRequire("RelationshipsScreen")
	ActivitiesScreen   = safeRequire("ActivitiesScreen")
	StoryPathsScreen   = safeRequire("StoryPathsScreen")
end

-- Minigames module (directly in ReplicatedStorage)
local function safeRequireRS(name)
	local s, r = pcall(function() return require(ReplicatedStorage:WaitForChild(name, 5)) end)
	return s and r or nil
end
MinigamesModule = safeRequireRS("Minigames")

----------------------------------------------------------------
-- REMOTES
----------------------------------------------------------------

local remotesFolder  = ReplicatedStorage:WaitForChild("LifeRemotes", 10) or ReplicatedStorage:WaitForChild("Life", 10)
local RequestAgeUp   = remotesFolder:WaitForChild("RequestAgeUp")
local PresentEvent   = remotesFolder:WaitForChild("PresentEvent")
local SubmitChoice   = remotesFolder:WaitForChild("SubmitChoice")
local SyncState      = remotesFolder:WaitForChild("SyncState")
local SetLifeInfo    = remotesFolder:WaitForChild("SetLifeInfo")
local MinigameResult = remotesFolder:WaitForChild("MinigameResult", 5)

----------------------------------------------------------------
-- STATE
----------------------------------------------------------------

local currentState = {
	Name = nil, Age = 0, Money = 0,
	Happiness = 50, Health = 100, Smarts = 50, Looks = 50,
	Education = "None", Experience = 0, CurrentJob = nil, InJail = false,
}

local awaitingEvent          = false
local hasShownAgeHint        = false
local introComplete          = false
local selectedGender         = nil

local occupationScreenInstance, assetsScreenInstance, relationshipsScreenInstance, activitiesScreenInstance, storyPathsScreenInstance
local minigamesInstance
local pendingMinigameEventId     = nil
local pendingMinigameChoiceIndex = nil

-- Forward declarations
local showEvent, hideEvent
local showIntro, hideIntro
local showTutorial, hideTutorial
local updateNameButtons

----------------------------------------------------------------
-- COLORS (Premium BitLife Palette)
----------------------------------------------------------------

local C = {
	-- Primary Blues
	Blue      = Color3.fromRGB(37, 99, 235),
	BlueDark  = Color3.fromRGB(29, 78, 216),
	BlueLight = Color3.fromRGB(96, 165, 250),
	BluePale  = Color3.fromRGB(219, 234, 254),

	-- Greens
	Green      = Color3.fromRGB(34, 197, 94),
	GreenDark  = Color3.fromRGB(22, 163, 74),
	GreenRing  = Color3.fromRGB(21, 128, 61),
	GreenPale  = Color3.fromRGB(220, 252, 231),

	-- Accents
	Red     = Color3.fromRGB(239, 68, 68),
	RedDark = Color3.fromRGB(220, 38, 38),
	Orange  = Color3.fromRGB(249, 115, 22),
	Pink    = Color3.fromRGB(244, 114, 182),
	Purple  = Color3.fromRGB(168, 85, 247),
	Yellow  = Color3.fromRGB(253, 224, 71),

	-- Gender
	Male   = Color3.fromRGB(56, 189, 248),
	Female = Color3.fromRGB(244, 114, 182),

	-- Neutrals
	White   = Color3.fromRGB(255, 255, 255),
	OffWhite= Color3.fromRGB(250, 250, 250),
	Gray50  = Color3.fromRGB(249, 250, 251),
	Gray100 = Color3.fromRGB(243, 244, 246),
	Gray200 = Color3.fromRGB(229, 231, 235),
	Gray300 = Color3.fromRGB(209, 213, 219),
	Gray400 = Color3.fromRGB(156, 163, 175),
	Gray500 = Color3.fromRGB(107, 114, 128),
	Gray600 = Color3.fromRGB(75, 85, 99),
	Gray700 = Color3.fromRGB(55, 65, 81),
	Gray800 = Color3.fromRGB(31, 41, 55),
	Gray900 = Color3.fromRGB(17, 24, 39),

	-- Nav
	NavBlue = Color3.fromRGB(30, 58, 138),
	NavDark = Color3.fromRGB(23, 37, 84),

	-- Overlay
	Black = Color3.fromRGB(0, 0, 0),
}

local F = {
	Title  = Enum.Font.GothamBold,
	Body   = Enum.Font.Gotham,
	Medium = Enum.Font.GothamMedium,
	Button = Enum.Font.GothamBold,
}

----------------------------------------------------------------
-- HELPERS
----------------------------------------------------------------

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

local function tween(o, i, p)
	local t = TweenService:Create(o, i, p)
	t:Play()
	return t
end

local function formatMoney(n)
	if not n then return "$0" end
	if n >= 1000000 then
		return string.format("$%.1fM", n/1000000)
	elseif n >= 1000 then
		return string.format("$%.1fK", n/1000)
	else
		return "$"..math.floor(n)
	end
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

----------------------------------------------------------------
-- SCREEN GUI
----------------------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BitLifeUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local blurOverlay = Instance.new("Frame")
blurOverlay.Name = "BlurOverlay"
blurOverlay.Size = UDim2.fromScale(1, 1)
blurOverlay.BackgroundColor3 = C.Black
blurOverlay.BackgroundTransparency = 1
blurOverlay.ZIndex = 50
blurOverlay.Parent = screenGui

local function showBlur()
	tween(blurOverlay, TweenInfo.new(0.25), { BackgroundTransparency = 0.6 })
end

local function hideBlur()
	tween(blurOverlay, TweenInfo.new(0.25), { BackgroundTransparency = 1 })
end

----------------------------------------------------------------
-- MAIN CONTAINER
----------------------------------------------------------------

local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.Size = UDim2.fromScale(1, 1)
mainContainer.BackgroundColor3 = C.Gray100
mainContainer.BorderSizePixel = 0
mainContainer.ZIndex = 1
mainContainer.Parent = screenGui

----------------------------------------------------------------
-- SCREEN SHAKE EFFECT (for negative outcomes like BitLife)
----------------------------------------------------------------

local shakeActive = false

local function shakeScreen(intensity, duration)
	if shakeActive then return end
	shakeActive = true
	
	local originalPos = mainContainer.Position
	local elapsed = 0
	local shakeIntensity = intensity or 8
	
	task.spawn(function()
		while elapsed < (duration or 0.4) do
			local offsetX = math.random(-shakeIntensity, shakeIntensity)
			local offsetY = math.random(-shakeIntensity, shakeIntensity)
			mainContainer.Position = UDim2.new(
				originalPos.X.Scale, originalPos.X.Offset + offsetX,
				originalPos.Y.Scale, originalPos.Y.Offset + offsetY
			)
			task.wait(0.02)
			elapsed = elapsed + 0.02
			shakeIntensity = math.max(1, shakeIntensity - 0.5)
		end
		mainContainer.Position = originalPos
		shakeActive = false
	end)
end

----------------------------------------------------------------
-- FLASH OVERLAY (red for damage, green for good)
----------------------------------------------------------------

local flashOverlay = Instance.new("Frame")
flashOverlay.Size = UDim2.fromScale(1, 1)
flashOverlay.BackgroundColor3 = C.Red
flashOverlay.BackgroundTransparency = 1
flashOverlay.ZIndex = 100
flashOverlay.Name = "FlashOverlay"
flashOverlay.Parent = screenGui

local function flashScreen(color, intensity, duration)
	flashOverlay.BackgroundColor3 = color or C.Red
	flashOverlay.BackgroundTransparency = intensity or 0.7
	tween(flashOverlay, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1
	})
end

----------------------------------------------------------------
-- RESULT POPUP (BitLife-style card matching event modal)
----------------------------------------------------------------

local resultOverlay, resultShadowFrame, resultShell, resultCard
local resultEmoji, resultTitle, resultBody, resultOkBtn, resultStatsPreview
local resultVisible = false
local resultCallback = nil

-- Forward declare hideResultPopup
local hideResultPopup

local function createResultPopup()
	-- Overlay
	resultOverlay = Instance.new("Frame")
	resultOverlay.Name = "ResultOverlay"
	resultOverlay.Size = UDim2.fromScale(1, 1)
	resultOverlay.BackgroundColor3 = C.Black
	resultOverlay.BackgroundTransparency = 0.45
	resultOverlay.Visible = false
	resultOverlay.ZIndex = 80
	resultOverlay.Parent = screenGui
	
	-- Shadow frame (matches event modal)
	resultShadowFrame = Instance.new("Frame")
	resultShadowFrame.Size = UDim2.new(0, 320, 0, 0)
	resultShadowFrame.AutomaticSize = Enum.AutomaticSize.Y
	resultShadowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	resultShadowFrame.Position = UDim2.fromScale(0.5, 0.5)
	resultShadowFrame.BackgroundColor3 = C.Black
	resultShadowFrame.BackgroundTransparency = 0.92
	resultShadowFrame.ZIndex = 81
	resultShadowFrame.Parent = resultOverlay
	corner(resultShadowFrame, 28)
	
	-- Green/Red shell (outer border - matches event style)
	resultShell = Instance.new("Frame")
	resultShell.Name = "ResultShell"
	resultShell.Size = UDim2.new(1, -6, 1, -6)
	resultShell.Position = UDim2.new(0, 3, 0, 3)
	resultShell.BackgroundColor3 = C.Green
	resultShell.ZIndex = 82
	resultShell.Parent = resultShadowFrame
	corner(resultShell, 26)
	stroke(resultShell, 2, 0.4, C.GreenDark)
	createShadow(resultShell, 4, 16, C.Black, 0.9)
	
	-- Inner white card
	resultCard = Instance.new("Frame")
	resultCard.Name = "ResultCard"
	resultCard.Size = UDim2.new(1, -10, 1, -10)
	resultCard.Position = UDim2.new(0, 5, 0, 5)
	resultCard.BackgroundColor3 = C.White
	resultCard.ZIndex = 83
	resultCard.Parent = resultShell
	corner(resultCard, 22)
	
	local cardLayout = Instance.new("UIListLayout")
	cardLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	cardLayout.Padding = UDim.new(0, 10)
	cardLayout.Parent = resultCard
	pad(resultCard, 20, 20, 20, 20)
	
	-- Emoji
	resultEmoji = Instance.new("TextLabel")
	resultEmoji.Size = UDim2.new(0, 60, 0, 60)
	resultEmoji.BackgroundTransparency = 1
	resultEmoji.Font = F.Body
	resultEmoji.TextSize = 48
	resultEmoji.Text = "✨"
	resultEmoji.LayoutOrder = 1
	resultEmoji.ZIndex = 84
	resultEmoji.Parent = resultCard
	
	-- Title
	resultTitle = Instance.new("TextLabel")
	resultTitle.Size = UDim2.new(1, 0, 0, 32)
	resultTitle.BackgroundTransparency = 1
	resultTitle.Font = F.Title
	resultTitle.TextSize = 24
	resultTitle.TextColor3 = C.Gray900
	resultTitle.Text = "Result"
	resultTitle.TextWrapped = true
	resultTitle.LayoutOrder = 2
	resultTitle.ZIndex = 84
	resultTitle.Parent = resultCard
	
	-- Body
	resultBody = Instance.new("TextLabel")
	resultBody.Size = UDim2.new(1, 0, 0, 0)
	resultBody.AutomaticSize = Enum.AutomaticSize.Y
	resultBody.BackgroundTransparency = 1
	resultBody.Font = F.Body
	resultBody.TextSize = 16
	resultBody.TextColor3 = C.Gray600
	resultBody.TextWrapped = true
	resultBody.TextXAlignment = Enum.TextXAlignment.Center
	resultBody.LineHeight = 1.4
	resultBody.RichText = true
	resultBody.Text = ""
	resultBody.LayoutOrder = 3
	resultBody.ZIndex = 84
	resultBody.Parent = resultCard
	
	-- Stats container
	resultStatsPreview = Instance.new("Frame")
	resultStatsPreview.Name = "StatsPreview"
	resultStatsPreview.Size = UDim2.new(1, 0, 0, 0)
	resultStatsPreview.AutomaticSize = Enum.AutomaticSize.Y
	resultStatsPreview.BackgroundTransparency = 1
	resultStatsPreview.LayoutOrder = 4
	resultStatsPreview.ZIndex = 84
	resultStatsPreview.Parent = resultCard
	
	local statsLayout = Instance.new("UIListLayout")
	statsLayout.Padding = UDim.new(0, 4)
	statsLayout.Parent = resultStatsPreview
	
	-- OK Button
	resultOkBtn = Instance.new("TextButton")
	resultOkBtn.Size = UDim2.new(1, 0, 0, 48)
	resultOkBtn.BackgroundColor3 = C.Green
	resultOkBtn.Font = F.Button
	resultOkBtn.TextSize = 16
	resultOkBtn.TextColor3 = C.White
	resultOkBtn.Text = "OK"
	resultOkBtn.AutoButtonColor = false
	resultOkBtn.LayoutOrder = 5
	resultOkBtn.ZIndex = 84
	resultOkBtn.Parent = resultCard
	corner(resultOkBtn, 10)
	
	resultOkBtn.MouseEnter:Connect(function()
		tween(resultOkBtn, TweenInfo.new(0.1), { BackgroundColor3 = C.GreenDark })
	end)
	resultOkBtn.MouseLeave:Connect(function()
		tween(resultOkBtn, TweenInfo.new(0.1), { BackgroundColor3 = C.Green })
	end)
	
	resultOkBtn.MouseButton1Click:Connect(function()
		hideResultPopup()
		if resultCallback then
			resultCallback()
			resultCallback = nil
		end
	end)
end

hideResultPopup = function()
	if not resultOverlay then return end
	resultVisible = false
	
	tween(resultShadowFrame, TweenInfo.new(0.2), {
		Position = UDim2.new(0.5, 0, 0.5, 40),
		BackgroundTransparency = 1,
	})
	tween(resultShell, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
	tween(resultCard, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
	
	task.delay(0.2, function()
		if resultOverlay then
			resultOverlay.Visible = false
		end
	end)
end

local function showResultPopup(data, callback)
	if not resultOverlay then createResultPopup() end
	
	resultCallback = callback
	
	local isPositive = (data.happiness or 0) >= 0 and (data.health or 0) >= 0
	local shellColor = isPositive and C.Green or C.Red
	local shellStrokeColor = isPositive and C.GreenDark or C.RedDark
	
	resultShell.BackgroundColor3 = shellColor
	local shellStroke = resultShell:FindFirstChildOfClass("UIStroke")
	if shellStroke then shellStroke.Color = shellStrokeColor end
	resultOkBtn.BackgroundColor3 = shellColor
	
	resultEmoji.Text = data.emoji or (isPositive and "✨" or "😢")
	resultTitle.Text = data.title or "What Happened"
	resultBody.Text = data.body or "Life goes on..."
	
	-- Clear old stat previews
	for _, child in ipairs(resultStatsPreview:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	
	-- Add stat changes (compact style)
	local statChanges = {
		{ key = "Happiness", icon = "😀", delta = data.happiness },
		{ key = "Health", icon = "❤️", delta = data.health },
		{ key = "Smarts", icon = "🧠", delta = data.smarts },
		{ key = "Looks", icon = "💄", delta = data.looks },
	}
	
	for _, stat in ipairs(statChanges) do
		if stat.delta and stat.delta ~= 0 then
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, 0, 0, 24)
			row.BackgroundTransparency = 1
			row.ZIndex = 85
			row.Parent = resultStatsPreview
			
			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(0.5, 0, 1, 0)
			lbl.BackgroundTransparency = 1
			lbl.Font = F.Medium
			lbl.TextSize = 14
			lbl.TextColor3 = C.Gray600
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Text = stat.icon .. " " .. stat.key
			lbl.ZIndex = 86
			lbl.Parent = row
			
			local val = Instance.new("TextLabel")
			val.Size = UDim2.new(0.5, 0, 1, 0)
			val.Position = UDim2.new(0.5, 0, 0, 0)
			val.BackgroundTransparency = 1
			val.Font = F.Title
			val.TextSize = 14
			val.TextColor3 = stat.delta > 0 and C.Green or C.Red
			val.TextXAlignment = Enum.TextXAlignment.Right
			val.Text = (stat.delta > 0 and "+" or "") .. stat.delta
			val.ZIndex = 86
			val.Parent = row
		end
	end
	
	-- Money change
	if data.money and data.money ~= 0 then
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 24)
		row.BackgroundTransparency = 1
		row.ZIndex = 85
		row.Parent = resultStatsPreview
		
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0.5, 0, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.Font = F.Medium
		lbl.TextSize = 14
		lbl.TextColor3 = C.Gray600
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Text = "💵 Money"
		lbl.ZIndex = 86
		lbl.Parent = row
		
		local val = Instance.new("TextLabel")
		val.Size = UDim2.new(0.5, 0, 1, 0)
		val.Position = UDim2.new(0.5, 0, 0, 0)
		val.BackgroundTransparency = 1
		val.Font = F.Title
		val.TextSize = 14
		val.TextColor3 = data.money > 0 and C.Green or C.Red
		val.TextXAlignment = Enum.TextXAlignment.Right
		val.Text = (data.money > 0 and "+" or "") .. formatMoney(data.money)
		val.ZIndex = 86
		val.Parent = row
	end
	
	-- Show with animation
	resultOverlay.Visible = true
	resultShadowFrame.Position = UDim2.new(0.5, 0, 0.5, 40)
	resultShadowFrame.BackgroundTransparency = 1
	resultShell.BackgroundTransparency = 1
	resultCard.BackgroundTransparency = 1
	
	tween(resultShadowFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 0.92,
	})
	tween(resultShell, TweenInfo.new(0.25), { BackgroundTransparency = 0 })
	tween(resultCard, TweenInfo.new(0.25), { BackgroundTransparency = 0 })
	
	-- Visual feedback
	if not isPositive then
		shakeScreen(8, 0.25)
		flashScreen(C.Red, 0.6, 0.3)
	end
	
	resultVisible = true
end

----------------------------------------------------------------
-- HEADER BAR (Offset to avoid Roblox logo)
----------------------------------------------------------------

local headerBar = Instance.new("Frame")
headerBar.Name = "Header"
headerBar.Size = UDim2.new(1, -16, 0, 70)
headerBar.Position = UDim2.new(0, 8, 0, 44)
headerBar.BackgroundColor3 = C.White
headerBar.ZIndex = 5
headerBar.Parent = mainContainer
corner(headerBar, 18)

-- subtle shadow
local headerShadow = Instance.new("Frame")
headerShadow.Size = UDim2.new(1, 4, 0, 74)
headerShadow.Position = UDim2.new(0, 6, 0, 46)
headerShadow.BackgroundColor3 = C.Black
headerShadow.BackgroundTransparency = 0.95
headerShadow.ZIndex = 4
headerShadow.Parent = mainContainer
corner(headerShadow, 20)

-- avatar circle
local avatarCircle = Instance.new("Frame")
avatarCircle.Size = UDim2.new(0, 50, 0, 50)
avatarCircle.Position = UDim2.new(0, 14, 0.5, -25)
avatarCircle.BackgroundColor3 = C.BluePale
avatarCircle.ZIndex = 6
avatarCircle.Parent = headerBar
corner(avatarCircle, 25)
stroke(avatarCircle, 2, 0.5, C.BlueLight)

local avatarEmoji = Instance.new("TextLabel")
avatarEmoji.Size = UDim2.fromScale(1, 1)
avatarEmoji.BackgroundTransparency = 1
avatarEmoji.Font = F.Body
avatarEmoji.TextSize = 26
avatarEmoji.Text = "👶"
avatarEmoji.ZIndex = 7
avatarEmoji.Parent = avatarCircle

-- name + age
local nameContainer = Instance.new("Frame")
nameContainer.Size = UDim2.new(0.5, -90, 1, 0)
nameContainer.Position = UDim2.new(0, 74, 0, 0)
nameContainer.BackgroundTransparency = 1
nameContainer.ZIndex = 6
nameContainer.Parent = headerBar

local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(1, 0, 0, 24)
nameLabel.Position = UDim2.new(0, 0, 0.5, -14)
nameLabel.BackgroundTransparency = 1
nameLabel.Font = F.Title
nameLabel.TextSize = 17
nameLabel.TextColor3 = C.Gray900
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.Text = "New Life"
nameLabel.ZIndex = 7
nameLabel.Parent = nameContainer

local ageYearLabel = Instance.new("TextLabel")
ageYearLabel.Size = UDim2.new(1, 0, 0, 16)
ageYearLabel.Position = UDim2.new(0, 0, 0.5, 8)
ageYearLabel.BackgroundTransparency = 1
ageYearLabel.Font = F.Body
ageYearLabel.TextSize = 12
ageYearLabel.TextColor3 = C.Gray500
ageYearLabel.TextXAlignment = Enum.TextXAlignment.Left
ageYearLabel.Text = "Age 0 • 2025"
ageYearLabel.ZIndex = 7
ageYearLabel.Parent = nameContainer

-- money display
local moneyContainer = Instance.new("Frame")
moneyContainer.Size = UDim2.new(0, 110, 0, 44)
moneyContainer.AnchorPoint = Vector2.new(1, 0.5)
moneyContainer.Position = UDim2.new(1, -12, 0.5, 0)
moneyContainer.BackgroundColor3 = C.GreenPale
moneyContainer.ZIndex = 6
moneyContainer.Parent = headerBar
corner(moneyContainer, 14)
stroke(moneyContainer, 2, 0.6, C.Green)

local moneyIcon = Instance.new("TextLabel")
moneyIcon.Size = UDim2.new(0, 30, 1, 0)
moneyIcon.BackgroundTransparency = 1
moneyIcon.Font = F.Body
moneyIcon.TextSize = 20
moneyIcon.Text = "💵"
moneyIcon.ZIndex = 7
moneyIcon.Parent = moneyContainer

local moneyLabel = Instance.new("TextLabel")
moneyLabel.Size = UDim2.new(1, -34, 1, 0)
moneyLabel.Position = UDim2.new(0, 30, 0, 0)
moneyLabel.BackgroundTransparency = 1
moneyLabel.Font = F.Title
moneyLabel.TextSize = 15
moneyLabel.TextColor3 = C.GreenDark
moneyLabel.TextXAlignment = Enum.TextXAlignment.Left
moneyLabel.Text = "$0"
moneyLabel.ZIndex = 7
moneyLabel.Parent = moneyContainer

----------------------------------------------------------------
-- LIFE FEED AREA
----------------------------------------------------------------

local feedContainer = Instance.new("Frame")
feedContainer.Name = "FeedContainer"
feedContainer.Size = UDim2.new(1, -16, 1, -290)
feedContainer.Position = UDim2.new(0, 8, 0, 122)
feedContainer.BackgroundColor3 = C.White
feedContainer.ZIndex = 3
feedContainer.Parent = mainContainer
corner(feedContainer, 16)
pad(feedContainer, 14, 14, 12, 12)

local feedScroll = Instance.new("ScrollingFrame")
feedScroll.Size = UDim2.fromScale(1, 1)
feedScroll.BackgroundTransparency = 1
feedScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
feedScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
feedScroll.ScrollBarThickness = 3
feedScroll.ScrollBarImageColor3 = C.Gray300
feedScroll.Parent = feedContainer

local feedLayout = Instance.new("UIListLayout")
feedLayout.Padding = UDim.new(0, 8)
feedLayout.SortOrder = Enum.SortOrder.LayoutOrder
feedLayout.Parent = feedScroll

local feedEntryCount = 0

local function addFeedEntry(text)
	if not text or text == "" then return end
	feedEntryCount += 1

	local entry = Instance.new("Frame")
	entry.Size = UDim2.new(1, 0, 0, 0)
	entry.AutomaticSize = Enum.AutomaticSize.Y
	entry.BackgroundColor3 = C.Gray50
	entry.LayoutOrder = feedEntryCount
	entry.Parent = feedScroll
	corner(entry, 10)
	pad(entry, 12, 12, 10, 10)

	local isAge = text:match("years old")

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 0)
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.BackgroundTransparency = 1
	label.Font = isAge and F.Title or F.Body
	label.TextSize = isAge and 14 or 13
	label.TextColor3 = isAge and C.Blue or C.Gray700
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextWrapped = true
	label.Text = text
	label.Parent = entry

	entry.BackgroundTransparency = 1
	label.TextTransparency = 1
	tween(entry, TweenInfo.new(0.2), { BackgroundTransparency = 0 })
	tween(label, TweenInfo.new(0.2), { TextTransparency = 0 })

	task.defer(function()
		feedScroll.CanvasPosition = Vector2.new(
			0,
			math.max(0, feedScroll.AbsoluteCanvasSize.Y - feedScroll.AbsoluteWindowSize.Y)
		)
	end)
end

----------------------------------------------------------------
-- BOTTOM SECTION: Stats + Nav + Age Button
----------------------------------------------------------------

local statsRow = Instance.new("Frame")
statsRow.Name = "StatsRow"
statsRow.Size = UDim2.new(1, -16, 0, 52)
statsRow.AnchorPoint = Vector2.new(0.5, 1)
statsRow.Position = UDim2.new(0.5, 0, 1, -88)
statsRow.BackgroundColor3 = C.White
statsRow.ZIndex = 8
statsRow.Parent = mainContainer
corner(statsRow, 14)
stroke(statsRow, 1, 0.85, C.Gray200)

-- left stats
local statsLeft = Instance.new("Frame")
statsLeft.Name = "StatsLeft"
statsLeft.Size = UDim2.new(0.5, -55, 1, 0)
statsLeft.Position = UDim2.new(0, 0, 0, 0)
statsLeft.BackgroundTransparency = 1
statsLeft.ZIndex = 9
statsLeft.Parent = statsRow
pad(statsLeft, 8, 8, 6, 6)

local statsLeftLayout = Instance.new("UIListLayout")
statsLeftLayout.FillDirection = Enum.FillDirection.Horizontal
statsLeftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
statsLeftLayout.VerticalAlignment = Enum.VerticalAlignment.Center
statsLeftLayout.Padding = UDim.new(0, 6)
statsLeftLayout.Parent = statsLeft

-- right stats
local statsRight = Instance.new("Frame")
statsRight.Name = "StatsRight"
statsRight.Size = UDim2.new(0.5, -55, 1, 0)
statsRight.Position = UDim2.new(0.5, 55, 0, 0)
statsRight.BackgroundTransparency = 1
statsRight.ZIndex = 9
statsRight.Parent = statsRow
pad(statsRight, 8, 8, 6, 6)

local statsRightLayout = Instance.new("UIListLayout")
statsRightLayout.FillDirection = Enum.FillDirection.Horizontal
statsRightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
statsRightLayout.VerticalAlignment = Enum.VerticalAlignment.Center
statsRightLayout.Padding = UDim.new(0, 6)
statsRightLayout.Parent = statsRight

local statCards = {}

local function createStatCard(info, parent, order)
	local statCard = Instance.new("Frame")
	statCard.Name = "Stat_" .. info.key
	statCard.Size = UDim2.new(0, 76, 0, 40)
	statCard.BackgroundColor3 = C.Gray50
	statCard.LayoutOrder = order
	statCard.ZIndex = 10
	statCard.Parent = parent
	corner(statCard, 10)

	local iconLbl = Instance.new("TextLabel")
	iconLbl.Size = UDim2.new(0, 22, 0, 22)
	iconLbl.Position = UDim2.new(0, 4, 0, 3)
	iconLbl.BackgroundTransparency = 1
	iconLbl.Font = F.Body
	iconLbl.TextSize = 15
	iconLbl.Text = info.icon
	iconLbl.ZIndex = 11
	iconLbl.Parent = statCard

	local percentLbl = Instance.new("TextLabel")
	percentLbl.Name = "Percent"
	percentLbl.Size = UDim2.new(0, 38, 0, 16)
	percentLbl.Position = UDim2.new(0, 26, 0, 4)
	percentLbl.BackgroundTransparency = 1
	percentLbl.Font = F.Title
	percentLbl.TextSize = 12
	percentLbl.TextColor3 = info.col
	percentLbl.TextXAlignment = Enum.TextXAlignment.Left
	percentLbl.Text = "100%"
	percentLbl.ZIndex = 11
	percentLbl.Parent = statCard

	local barBg = Instance.new("Frame")
	barBg.Size = UDim2.new(1, -10, 0, 6)
	barBg.Position = UDim2.new(0, 5, 1, -11)
	barBg.BackgroundColor3 = C.Gray200
	barBg.ZIndex = 11
	barBg.Parent = statCard
	corner(barBg, 3)

	local barFill = Instance.new("Frame")
	barFill.Name = "Fill"
	barFill.Size = UDim2.new(1, 0, 1, 0)
	barFill.BackgroundColor3 = info.col
	barFill.ZIndex = 12
	barFill.Parent = barBg
	corner(barFill, 3)

	statCards[info.key] = {
		percentLabel = percentLbl,
		barFill      = barFill,
		color        = info.col,
	}
	return statCard
end

createStatCard({ key = "Happiness", icon = "😀", col = C.Green  }, statsLeft, 1)
createStatCard({ key = "Health",    icon = "❤️", col = C.Red    }, statsLeft, 2)
createStatCard({ key = "Smarts",    icon = "🧠", col = C.Purple }, statsRight, 1)
createStatCard({ key = "Looks",     icon = "💄", col = C.Pink   }, statsRight, 2)

----------------------------------------------------------------
-- NAV BAR
----------------------------------------------------------------

local navBar = Instance.new("Frame")
navBar.Name = "NavBar"
navBar.Size = UDim2.new(1, 0, 0, 80)
navBar.AnchorPoint = Vector2.new(0.5, 1)
navBar.Position = UDim2.new(0.5, 0, 1, 0)
navBar.BackgroundColor3 = C.NavBlue
navBar.ZIndex = 6
navBar.Parent = mainContainer

local navGrad = Instance.new("UIGradient")
navGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, C.NavBlue),
	ColorSequenceKeypoint.new(1, C.NavDark),
})
navGrad.Rotation = 90
navGrad.Parent = navBar

local navLeft = Instance.new("Frame")
navLeft.Name = "NavLeft"
navLeft.Size = UDim2.new(0.5, -50, 1, 0)
navLeft.Position = UDim2.new(0, 0, 0, 0)
navLeft.BackgroundTransparency = 1
navLeft.ZIndex = 7
navLeft.Parent = navBar
pad(navLeft, 8, 15, 6, 20)

local navLeftLayout = Instance.new("UIListLayout")
navLeftLayout.FillDirection = Enum.FillDirection.Horizontal
navLeftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
navLeftLayout.VerticalAlignment = Enum.VerticalAlignment.Center
navLeftLayout.Padding = UDim.new(0, 6)
navLeftLayout.Parent = navLeft

local navRight = Instance.new("Frame")
navRight.Name = "NavRight"
navRight.Size = UDim2.new(0.5, -50, 1, 0)
navRight.Position = UDim2.new(0.5, 50, 0, 0)
navRight.BackgroundTransparency = 1
navRight.ZIndex = 7
navRight.Parent = navBar
pad(navRight, 15, 8, 6, 20)

local navRightLayout = Instance.new("UIListLayout")
navRightLayout.FillDirection = Enum.FillDirection.Horizontal
navRightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
navRightLayout.VerticalAlignment = Enum.VerticalAlignment.Center
navRightLayout.Padding = UDim.new(0, 6)
navRightLayout.Parent = navRight

local navBtnRefs = {}

local function createNavButton(info, parent, order)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 56, 0, 48)
	btn.BackgroundTransparency = 1
	btn.AutoButtonColor = false
	btn.LayoutOrder = order
	btn.Text = ""
	btn.ZIndex = 8
	btn.Parent = parent

	local btnLayout = Instance.new("UIListLayout")
	btnLayout.FillDirection = Enum.FillDirection.Vertical
	btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	btnLayout.Padding = UDim.new(0, 1)
	btnLayout.Parent = btn

	local iconLbl = Instance.new("TextLabel")
	iconLbl.Size = UDim2.new(1, 0, 0, 24)
	iconLbl.BackgroundTransparency = 1
	iconLbl.Font = F.Body
	iconLbl.TextSize = 20
	iconLbl.TextColor3 = C.White
	iconLbl.Text = info.icon
	iconLbl.ZIndex = 9
	iconLbl.Parent = btn

	local textLbl = Instance.new("TextLabel")
	textLbl.Size = UDim2.new(1, 0, 0, 14)
	textLbl.BackgroundTransparency = 1
	textLbl.Font = F.Medium
	textLbl.TextSize = 10
	textLbl.TextColor3 = Color3.fromRGB(148, 163, 184)
	textLbl.Text = info.text
	textLbl.ZIndex = 9
	textLbl.Parent = btn

	btn.MouseEnter:Connect(function()
		iconLbl.TextColor3 = C.Yellow
		textLbl.TextColor3 = C.White
	end)
	btn.MouseLeave:Connect(function()
		iconLbl.TextColor3 = C.White
		textLbl.TextColor3 = Color3.fromRGB(148, 163, 184)
	end)

	btn.MouseButton1Click:Connect(function()
		print("[LifeClient] Nav button clicked:", info.screen)
		if info.screen == "occupation" and occupationScreenInstance then
			occupationScreenInstance:show()
		elseif info.screen == "assets" and assetsScreenInstance then
			assetsScreenInstance:show()
		elseif info.screen == "relationships" and relationshipsScreenInstance then
			relationshipsScreenInstance:show()
		elseif info.screen == "activities" then
			if activitiesScreenInstance then
				print("[LifeClient] Opening activities screen...")
				activitiesScreenInstance:show()
			else
				warn("[LifeClient] ❌ activitiesScreenInstance is nil!")
			end
		elseif info.screen == "storypaths" and storyPathsScreenInstance then
			storyPathsScreenInstance:show()
		end
	end)

	navBtnRefs[info.screen] = btn
	return btn
end

-- BitLife-style nav: Jobs, Assets, Relationships, Activities
createNavButton({ icon = "💼", text = "Jobs",       screen = "occupation"   }, navLeft,  1)
createNavButton({ icon = "🏠", text = "Assets",     screen = "assets"       }, navLeft,  2)
createNavButton({ icon = "👥", text = "Relations",  screen = "relationships"}, navRight, 1)
createNavButton({ icon = "⚡", text = "Activities", screen = "activities"   }, navRight, 2)

----------------------------------------------------------------
-- AGE BUTTON
----------------------------------------------------------------

local ageBtnContainer = Instance.new("Frame")
ageBtnContainer.Size = UDim2.new(0, 90, 0, 90)
ageBtnContainer.AnchorPoint = Vector2.new(0.5, 0.5)
ageBtnContainer.Position = UDim2.new(0.5, 0, 1, -70)
ageBtnContainer.BackgroundTransparency = 1
ageBtnContainer.ZIndex = 15
ageBtnContainer.Parent = mainContainer

local ageOuterRing = Instance.new("Frame")
ageOuterRing.Size = UDim2.new(1, 8, 1, 8)
ageOuterRing.AnchorPoint = Vector2.new(0.5, 0.5)
ageOuterRing.Position = UDim2.fromScale(0.5, 0.5)
ageOuterRing.BackgroundColor3 = C.White
ageOuterRing.ZIndex = 15
ageOuterRing.Parent = ageBtnContainer
corner(ageOuterRing, 50)

local ageShadow = Instance.new("Frame")
ageShadow.Size = UDim2.new(1, 16, 1, 16)
ageShadow.AnchorPoint = Vector2.new(0.5, 0.5)
ageShadow.Position = UDim2.new(0.5, 0, 0.5, 4)
ageShadow.BackgroundColor3 = C.Black
ageShadow.BackgroundTransparency = 0.9
ageShadow.ZIndex = 14
ageShadow.Parent = ageBtnContainer
corner(ageShadow, 54)

local ageButton = Instance.new("TextButton")
ageButton.Size = UDim2.new(1, -6, 1, -6)
ageButton.AnchorPoint = Vector2.new(0.5, 0.5)
ageButton.Position = UDim2.fromScale(0.5, 0.5)
ageButton.BackgroundColor3 = C.Green
ageButton.AutoButtonColor = false
ageButton.Text = ""
ageButton.ZIndex = 16
ageButton.Parent = ageBtnContainer
corner(ageButton, 45)
stroke(ageButton, 3, 0, C.GreenRing)

local ageGrad = Instance.new("UIGradient")
ageGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(74, 222, 128)),
	ColorSequenceKeypoint.new(1, C.Green),
})
ageGrad.Rotation = 90
ageGrad.Parent = ageButton

local agePlus = Instance.new("TextLabel")
agePlus.Size = UDim2.new(1, 0, 0, 32)
agePlus.Position = UDim2.new(0, 0, 0, 12)
agePlus.BackgroundTransparency = 1
agePlus.Font = F.Title
agePlus.TextSize = 32
agePlus.TextColor3 = C.White
agePlus.Text = "+"
agePlus.ZIndex = 17
agePlus.Parent = ageButton

local ageText = Instance.new("TextLabel")
ageText.Size = UDim2.new(1, 0, 0, 18)
ageText.Position = UDim2.new(0, 0, 0, 44)
ageText.BackgroundTransparency = 1
ageText.Font = F.Button
ageText.TextSize = 16
ageText.TextColor3 = C.White
ageText.Text = "Age"
ageText.ZIndex = 17
ageText.Parent = ageButton

local tutorialRing = Instance.new("Frame")
tutorialRing.Size = UDim2.new(1, 26, 1, 26)
tutorialRing.AnchorPoint = Vector2.new(0.5, 0.5)
tutorialRing.Position = UDim2.fromScale(0.5, 0.5)
tutorialRing.BackgroundTransparency = 1
tutorialRing.Visible = false
tutorialRing.ZIndex = 14
tutorialRing.Parent = ageBtnContainer
corner(tutorialRing, 60)
stroke(tutorialRing, 3, 0, C.Red)

----------------------------------------------------------------
-- TUTORIAL OVERLAY
----------------------------------------------------------------

local tutorialOverlay = Instance.new("Frame")
tutorialOverlay.Size = UDim2.fromScale(1, 1)
tutorialOverlay.BackgroundTransparency = 1
tutorialOverlay.Visible = false
tutorialOverlay.ZIndex = 40
tutorialOverlay.Parent = screenGui

local tutTextCont = Instance.new("Frame")
tutTextCont.Size = UDim2.new(0.85, 0, 0, 100)
tutTextCont.AnchorPoint = Vector2.new(0.5, 0.5)
tutTextCont.Position = UDim2.new(0.5, 0, 0.35, 0)
tutTextCont.BackgroundTransparency = 1
tutTextCont.Parent = tutorialOverlay

local tutLayout = Instance.new("UIListLayout")
tutLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tutLayout.Padding = UDim.new(0, 6)
tutLayout.Parent = tutTextCont

local tutLines = {
	"👇",
	"Press Age to grow older one year at a time.",
	"Make choices as you go.",
	"Live your best (or worst) life.",
}
for i, line in ipairs(tutLines) do
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0, i == 1 and 32 or 20)
	lbl.BackgroundTransparency = 1
	lbl.Font = i == 1 and F.Body or F.Medium
	lbl.TextSize = i == 1 and 28 or 15
	lbl.TextColor3 = i == 2 and C.Yellow or C.White
	lbl.Text = line
	lbl.LayoutOrder = i
	lbl.Parent = tutTextCont
end

showTutorial = function()
	if hasShownAgeHint then return end
	hasShownAgeHint = true
	tutorialOverlay.Visible = true
	tutorialRing.Visible = true
	local pulse = TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
	local s = tutorialRing:FindFirstChildOfClass("UIStroke")
	if s then
		tween(s, pulse, { Transparency = 0.6 })
	end
end

hideTutorial = function()
	tutorialOverlay.Visible = false
	tutorialRing.Visible = false
end

----------------------------------------------------------------
-- PREMIUM EVENT MODAL (BitLife-style red card)
----------------------------------------------------------------

local eventOverlay = Instance.new("Frame")
eventOverlay.Name = "EventOverlay"
eventOverlay.Size = UDim2.fromScale(1, 1)
eventOverlay.BackgroundColor3 = C.Black
eventOverlay.BackgroundTransparency = 0.45
eventOverlay.Visible = false
eventOverlay.ZIndex = 60
eventOverlay.Parent = screenGui

-- outer shadow frame
local eventShadowFrame = Instance.new("Frame")
eventShadowFrame.Size = UDim2.new(0, 340, 0, 0)
eventShadowFrame.AutomaticSize = Enum.AutomaticSize.Y
eventShadowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
eventShadowFrame.Position = UDim2.fromScale(0.5, 0.5)
eventShadowFrame.BackgroundColor3 = C.Black
eventShadowFrame.BackgroundTransparency = 0.92
eventShadowFrame.ZIndex = 61
eventShadowFrame.Parent = eventOverlay
corner(eventShadowFrame, 28)

-- red shell (outer border)
local eventShell = Instance.new("Frame")
eventShell.Name = "EventShell"
eventShell.Size = UDim2.new(1, -6, 1, -6)
eventShell.Position = UDim2.new(0, 3, 0, 3)
eventShell.BackgroundColor3 = C.Red
eventShell.ZIndex = 62
eventShell.Parent = eventShadowFrame
corner(eventShell, 30)
stroke(eventShell, 2, 0.4, C.RedDark)
createShadow(eventShell, 4, 18, C.Black, 0.9)

-- inner white card
local eventCard = Instance.new("Frame")
eventCard.Name = "EventCard"
eventCard.Size = UDim2.new(1, -10, 1, -10)
eventCard.Position = UDim2.new(0, 5, 0, 5)
eventCard.BackgroundColor3 = C.White
eventCard.ZIndex = 63
eventCard.Parent = eventShell
corner(eventCard, 26)

local eventLayout = Instance.new("UIListLayout")
eventLayout.Padding = UDim.new(0, 0)
eventLayout.Parent = eventCard

-- header with avatar + relation tag
local eventHeader = Instance.new("Frame")
eventHeader.Name = "Header"
eventHeader.Size = UDim2.new(1, 0, 0, 76)
eventHeader.BackgroundColor3 = C.White
eventHeader.LayoutOrder = 1
eventHeader.Visible = false
eventHeader.ZIndex = 64
eventHeader.Parent = eventCard
pad(eventHeader, 20, 20, 16, 12)

local eventAvatar = Instance.new("Frame")
eventAvatar.Size = UDim2.new(0, 50, 0, 50)
eventAvatar.BackgroundColor3 = Color3.fromRGB(254, 226, 226)
eventAvatar.ZIndex = 65
eventAvatar.Parent = eventHeader
corner(eventAvatar, 25)
stroke(eventAvatar, 2, 0.3, C.Red)

local eventAvatarEmoji = Instance.new("TextLabel")
eventAvatarEmoji.Size = UDim2.fromScale(1, 1)
eventAvatarEmoji.BackgroundTransparency = 1
eventAvatarEmoji.Font = F.Body
eventAvatarEmoji.TextSize = 26
eventAvatarEmoji.Text = "👤"
eventAvatarEmoji.ZIndex = 66
eventAvatarEmoji.Parent = eventAvatar

local eventNameLbl = Instance.new("TextLabel")
eventNameLbl.Size = UDim2.new(0.6, 0, 0, 22)
eventNameLbl.Position = UDim2.new(0, 60, 0, 8)
eventNameLbl.BackgroundTransparency = 1
eventNameLbl.Font = F.Title
eventNameLbl.TextSize = 16
eventNameLbl.TextColor3 = C.Gray900
eventNameLbl.TextXAlignment = Enum.TextXAlignment.Left
eventNameLbl.Text = "Person Name"
eventNameLbl.ZIndex = 65
eventNameLbl.Parent = eventHeader

local relationBanner = Instance.new("Frame")
relationBanner.Size = UDim2.new(0, 115, 0, 26)
relationBanner.AnchorPoint = Vector2.new(1, 0)
relationBanner.Position = UDim2.new(1, 0, 0, 8)
relationBanner.BackgroundColor3 = C.Red
relationBanner.ZIndex = 65
relationBanner.Parent = eventHeader
pill(relationBanner)

local relationLbl = Instance.new("TextLabel")
relationLbl.Size = UDim2.fromScale(1, 0.9)
relationLbl.Position = UDim2.new(0, 0, 0.05, 0)
relationLbl.BackgroundTransparency = 1
relationLbl.Font = F.Button
relationLbl.TextSize = 11
relationLbl.TextColor3 = C.White
relationLbl.Text = "Classmate"
relationLbl.ZIndex = 66
relationLbl.Parent = relationBanner

-- title section (emoji + event title)
local titleSection = Instance.new("Frame")
titleSection.Size = UDim2.new(1, 0, 0, 100)
titleSection.BackgroundTransparency = 1
titleSection.LayoutOrder = 2
titleSection.ZIndex = 64
titleSection.Parent = eventCard

local titleLayout = Instance.new("UIListLayout")
titleLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
titleLayout.VerticalAlignment = Enum.VerticalAlignment.Center
titleLayout.Padding = UDim.new(0, 8)
titleLayout.Parent = titleSection

local eventEmoji = Instance.new("TextLabel")
eventEmoji.Size = UDim2.new(0, 72, 0, 72)
eventEmoji.BackgroundTransparency = 1
eventEmoji.Font = F.Body
eventEmoji.TextSize = 60  -- BIGGER emoji
eventEmoji.Text = "🙂"
eventEmoji.LayoutOrder = 1
eventEmoji.ZIndex = 65
eventEmoji.Parent = titleSection

local eventTitle = Instance.new("TextLabel")
eventTitle.Size = UDim2.new(0.95, 0, 0, 38)
eventTitle.BackgroundTransparency = 1
eventTitle.Font = F.Title
eventTitle.TextSize = 32  -- 20% BIGGER (was 26)
eventTitle.TextColor3 = C.Gray900
eventTitle.Text = "Life Event"
eventTitle.TextWrapped = true
eventTitle.LayoutOrder = 2
eventTitle.ZIndex = 65
eventTitle.Parent = titleSection

-- body + "What will you do?" question
local bodySection = Instance.new("Frame")
bodySection.Size = UDim2.new(1, 0, 0, 0)
bodySection.AutomaticSize = Enum.AutomaticSize.Y
bodySection.BackgroundTransparency = 1
bodySection.LayoutOrder = 3
bodySection.ZIndex = 64
bodySection.Parent = eventCard
pad(bodySection, 28, 28, 0, 12)

local bodyLayout = Instance.new("UIListLayout")
bodyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
bodyLayout.VerticalAlignment = Enum.VerticalAlignment.Top
bodyLayout.Padding = UDim.new(0, 10)
bodyLayout.Parent = bodySection

local eventBody = Instance.new("TextLabel")
eventBody.Size = UDim2.new(1, 0, 0, 0)
eventBody.AutomaticSize = Enum.AutomaticSize.Y
eventBody.BackgroundTransparency = 1
eventBody.Font = F.Body
eventBody.TextSize = 20  -- 20% BIGGER (was 16)
eventBody.TextColor3 = C.Gray600
eventBody.TextWrapped = true
eventBody.TextXAlignment = Enum.TextXAlignment.Center
eventBody.LineHeight = 1.5
eventBody.RichText = true
eventBody.Text = ""
eventBody.LayoutOrder = 1
eventBody.ZIndex = 65
eventBody.Parent = bodySection

local eventQuestion = Instance.new("TextLabel")
eventQuestion.Name = "EventQuestion"
eventQuestion.Size = UDim2.new(1, 0, 0, 28)
eventQuestion.BackgroundTransparency = 1
eventQuestion.Font = F.Title
eventQuestion.TextSize = 18  -- BIGGER (was 15)
eventQuestion.TextColor3 = C.Gray800
eventQuestion.Text = "What will you do?"
eventQuestion.TextXAlignment = Enum.TextXAlignment.Center
eventQuestion.LayoutOrder = 2
eventQuestion.ZIndex = 65
eventQuestion.Parent = bodySection

-- choices
local choicesSection = Instance.new("Frame")
choicesSection.Size = UDim2.new(1, 0, 0, 0)
choicesSection.AutomaticSize = Enum.AutomaticSize.Y
choicesSection.BackgroundTransparency = 1
choicesSection.LayoutOrder = 4
choicesSection.ZIndex = 64
choicesSection.Parent = eventCard

pad(choicesSection, 22, 22, 4, 24)

local choicesLayout = Instance.new("UIListLayout")
choicesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
choicesLayout.Padding = UDim.new(0, 10)
choicesLayout.Parent = choicesSection

local activeChoiceButtons = {}
local currentEventId       = nil
local surpriseConnection   = nil

local function clearChoices()
	for _, b in ipairs(activeChoiceButtons) do
		b:Destroy()
	end
	table.clear(activeChoiceButtons)

	if surpriseConnection then
		surpriseConnection:Disconnect()
		surpriseConnection = nil
	end
end

-- Surprise me (bottom link)
local surpriseBtn = Instance.new("TextButton")
surpriseBtn.Size = UDim2.new(1, 0, 0, 36)
surpriseBtn.BackgroundTransparency = 1
surpriseBtn.Font = F.Medium
surpriseBtn.TextSize = 14
surpriseBtn.TextColor3 = C.Gray400
surpriseBtn.Text = "✨ Surprise me!"
surpriseBtn.AutoButtonColor = false
surpriseBtn.LayoutOrder = 100
surpriseBtn.ZIndex = 65
surpriseBtn.Parent = choicesSection

surpriseBtn.MouseEnter:Connect(function()
	surpriseBtn.TextColor3 = C.Blue
end)
surpriseBtn.MouseLeave:Connect(function()
	surpriseBtn.TextColor3 = C.Gray400
end)

----------------------------------------------------------------
-- EVENT FUNCTIONS
------------------------------------------------------------------

showEvent = function(payload)
	awaitingEvent = true
	currentEventId = payload.id
	clearChoices()

	-- header
	eventHeader.Visible = payload.showRelationship or false
	if payload.showRelationship and payload.relationName then
		eventNameLbl.Text = payload.relationName
		relationLbl.Text  = payload.relationship or "Friend"
	end

	eventEmoji.Text     = payload.emoji or "🙂"
	eventTitle.Text     = payload.title or "Life Event"
	eventBody.Text      = payload.text or ""
	eventQuestion.Text  = payload.question or "What will you do?"

	local choiceHandlers = {}

	for i, choice in ipairs(payload.choices or {}) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 58)  -- BIGGER buttons
		btn.BackgroundColor3 = C.Blue
		btn.Font = F.Button
		btn.TextSize = 18  -- BIGGER text (was 15)
		btn.TextColor3 = C.White
		btn.Text = choice.text
		btn.AutoButtonColor = false
		btn.LayoutOrder = i
		btn.ZIndex = 65
		btn.Parent = choicesSection

		corner(btn, 14)
		stroke(btn, 2, 0.5, C.BlueLight)

		if choice.minigame then
			btn.Text = "🎮 " .. choice.text
		end

		btn.MouseEnter:Connect(function()
			tween(btn, TweenInfo.new(0.1), { BackgroundColor3 = C.BlueDark, Size = UDim2.new(1, 0, 0, 62) })
		end)
		btn.MouseLeave:Connect(function()
			tween(btn, TweenInfo.new(0.1), { BackgroundColor3 = C.Blue, Size = UDim2.new(1, 0, 0, 58) })
		end)

		local choiceIndex = choice.index or i
		local minigameType = choice.minigame

		local function handleChoice()
			if not currentEventId then return end

			if minigameType and minigamesInstance then
				pendingMinigameEventId     = currentEventId
				pendingMinigameChoiceIndex = choiceIndex
				hideEvent()

				minigamesInstance:play(minigameType, function(won, data)
					SubmitChoice:FireServer(pendingMinigameEventId, pendingMinigameChoiceIndex)
					if MinigameResult then
						MinigameResult:FireServer(won, data)
					end
					pendingMinigameEventId     = nil
					pendingMinigameChoiceIndex = nil
				end)
			else
				SubmitChoice:FireServer(currentEventId, choiceIndex)
				hideEvent()
			end
		end

		btn.MouseButton1Click:Connect(handleChoice)
		table.insert(choiceHandlers, handleChoice)
		table.insert(activeChoiceButtons, btn)
	end

	surpriseConnection = surpriseBtn.MouseButton1Click:Connect(function()
		if currentEventId and #choiceHandlers > 0 then
			local handler = choiceHandlers[math.random(1, #choiceHandlers)]
			handler()
		end
	end)

	eventOverlay.Visible = true
	eventShadowFrame.Position = UDim2.new(0.5, 0, 0.5, 40)
	eventShadowFrame.BackgroundTransparency = 1
	eventShell.BackgroundTransparency = 1
	eventCard.BackgroundTransparency = 1

	tween(eventShadowFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 0.92,
	})
	tween(eventShell, TweenInfo.new(0.25), { BackgroundTransparency = 0 })
	tween(eventCard, TweenInfo.new(0.25), { BackgroundTransparency = 0 })
end

hideEvent = function()
	awaitingEvent  = false
	currentEventId = nil

	local t = tween(eventShadowFrame, TweenInfo.new(0.2), {
		Position = UDim2.new(0.5, 0, 0.5, 40),
		BackgroundTransparency = 1,
	})
	tween(eventShell, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
	tween(eventCard, TweenInfo.new(0.2), { BackgroundTransparency = 1 })

	t.Completed:Connect(function()
		eventOverlay.Visible = false
	end)
end

----------------------------------------------------------------
-- INTRO (gender + name)
----------------------------------------------------------------

local introOverlay = Instance.new("Frame")
introOverlay.Size = UDim2.fromScale(1, 1)
introOverlay.BackgroundColor3 = C.Black
introOverlay.BackgroundTransparency = 0.5
introOverlay.Visible = false
introOverlay.ZIndex = 70
introOverlay.Parent = screenGui

local introContent = Instance.new("Frame")
introContent.Size = UDim2.new(0.9, 0, 0, 0)
introContent.AutomaticSize = Enum.AutomaticSize.Y
introContent.AnchorPoint = Vector2.new(0.5, 0.5)
introContent.Position = UDim2.fromScale(0.5, 0.5)
introContent.BackgroundTransparency = 1
introContent.ZIndex = 71
introContent.Parent = introOverlay

local introLayout = Instance.new("UIListLayout")
introLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
introLayout.Padding = UDim.new(0, 20)
introLayout.Parent = introContent

local genderTitle = Instance.new("TextLabel")
genderTitle.Size = UDim2.new(1, 0, 0, 36)
genderTitle.BackgroundTransparency = 1
genderTitle.Font = F.Title
genderTitle.TextSize = 24
genderTitle.TextColor3 = C.Gray900  -- was yellow; now black-ish so it doesn't look neon
genderTitle.Text = "Start by picking a gender"
genderTitle.LayoutOrder = 1
genderTitle.ZIndex = 72
genderTitle.Parent = introContent

local genderBtns = Instance.new("Frame")
genderBtns.Size = UDim2.new(1, 0, 0, 140)
genderBtns.BackgroundTransparency = 1
genderBtns.LayoutOrder = 2
genderBtns.ZIndex = 71
genderBtns.Parent = introContent

local genderBtnLayout = Instance.new("UIListLayout")
genderBtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
genderBtnLayout.Padding = UDim.new(0, 14)
genderBtnLayout.Parent = genderBtns

local nameBtns = Instance.new("Frame")
nameBtns.Name = "NameBtns"
nameBtns.Size = UDim2.new(1, 0, 0, 200)
nameBtns.BackgroundTransparency = 1
nameBtns.Visible = false
nameBtns.LayoutOrder = 3
nameBtns.ZIndex = 71
nameBtns.Parent = introContent

local nameBtnLayout = Instance.new("UIListLayout")
nameBtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
nameBtnLayout.Padding = UDim.new(0, 12)
nameBtnLayout.Parent = nameBtns

local maleNames   = { "James Wilson", "Marcus Chen", "David Thompson" }
local femaleNames = { "Emma Rodriguez", "Sophia Kim", "Olivia Brown" }
local nameColors  = { C.Green, Color3.fromRGB(234, 179, 8), C.Orange }

for i = 1, 3 do
	local nameBtn = Instance.new("TextButton")
	nameBtn.Name = "NameBtn" .. i
	nameBtn.Size = UDim2.new(0.85, 0, 0, 54)
	nameBtn.BackgroundColor3 = nameColors[i]
	nameBtn.Font = F.Title
	nameBtn.TextSize = 18
	nameBtn.TextColor3 = C.White
	nameBtn.Text = ""
	nameBtn.AutoButtonColor = false
	nameBtn.LayoutOrder = i
	nameBtn.ZIndex = 72
	nameBtn.Parent = nameBtns
	pill(nameBtn)
	stroke(nameBtn, 2, 0.6, C.White)

	-- subtle size pulse is fine here
	nameBtn.MouseEnter:Connect(function()
		tween(nameBtn, TweenInfo.new(0.1), { Size = UDim2.new(0.88, 0, 0, 58) })
	end)
	nameBtn.MouseLeave:Connect(function()
		tween(nameBtn, TweenInfo.new(0.1), { Size = UDim2.new(0.85, 0, 0, 54) })
	end)

	nameBtn.MouseButton1Click:Connect(function()
		local chosenName = nameBtn.Text:match("^.-%s(.+)$") or nameBtn.Text
		SetLifeInfo:FireServer(chosenName, selectedGender)
		introComplete = true
		hideIntro()
	end)
end

updateNameButtons = function()
	local names = selectedGender == "Male" and maleNames or femaleNames
	local emoji = selectedGender == "Male" and "👨" or "👩"
	for _, child in ipairs(nameBtns:GetChildren()) do
		if child:IsA("TextButton") then
			local idx = tonumber(child.Name:match("%d+"))
			if idx and names[idx] then
				child.Text = emoji .. " " .. names[idx]
			end
		end
	end
end

local genderData = {
	{ gender = "Male",   icon = "♂", color = C.Male   },
	{ gender = "Female", icon = "♀", color = C.Female },
}

for _, g in ipairs(genderData) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.85, 0, 0, 58)
	btn.BackgroundColor3 = g.color
	btn.Font = F.Title
	btn.TextSize = 22
	btn.TextColor3 = C.White
	btn.Text = g.icon .. " " .. g.gender
	btn.AutoButtonColor = false
	btn.ZIndex = 72
	btn.Parent = genderBtns
	pill(btn)
	stroke(btn, 2, 0.5, C.White)

	-- FIXED: no insane Y scale; just a small pulse
	btn.MouseEnter:Connect(function()
		tween(btn, TweenInfo.new(0.1), { Size = UDim2.new(0.88, 0, 0, 62) })
	end)
	btn.MouseLeave:Connect(function()
		tween(btn, TweenInfo.new(0.1), { Size = UDim2.new(0.85, 0, 0, 58) }) -- 0,58 not 58,0
	end)

	btn.MouseButton1Click:Connect(function()
		selectedGender = g.gender
		genderTitle.Text = "Now, pick someone to become"
		genderBtns.Visible = false
		nameBtns.Visible  = true
		updateNameButtons()
	end)
end

showIntro = function()
	if introComplete then return end
	introOverlay.Visible = true
	showBlur()
	genderTitle.Text = "Start by picking a gender"
	genderBtns.Visible = true
	nameBtns.Visible  = false
end

hideIntro = function()
	introOverlay.Visible = false
	hideBlur()
	if not hasShownAgeHint then
		task.delay(0.5, showTutorial)
	end
end

genderBtns.ChildAdded:Connect(function() end)
task.spawn(function()
	while true do
		if selectedGender and not nameBtns.Visible then
			updateNameButtons()
		end
		task.wait(0.1)
	end
end)

----------------------------------------------------------------
-- UPDATE UI FROM STATE
----------------------------------------------------------------

local function updateFromState()
	if not currentState then return end

	nameLabel.Text = currentState.Name or "New Life"
	ageYearLabel.Text = string.format(
		"Age %d • %d",
		currentState.Age or 0,
		2025 + (currentState.Age or 0)
	)
	moneyLabel.Text = formatMoney(currentState.Money or 0)

	avatarEmoji.Text =
		(currentState.Age < 3  and "👶") or
		(currentState.Age < 13 and "🧒") or
		(currentState.Age < 20 and "🧑") or
		(currentState.Age < 60 and "👨") or
		"👴"

	for key, card in pairs(statCards) do
		local val = currentState[key] or (currentState.Stats and currentState.Stats[key]) or 50
		card.percentLabel.Text = val .. "%"
		tween(card.barFill, TweenInfo.new(0.3), {
			Size = UDim2.new(math.clamp(val/100, 0, 1), 0, 1, 0),
		})
	end
end

----------------------------------------------------------------
-- REMOTE HANDLERS
----------------------------------------------------------------

-- Track previous state for change detection
local previousState = {}

SyncState.OnClientEvent:Connect(function(state, lastFeedText, resultData)
	if state then
		-- Calculate deltas for result popup
		local deltas = {}
		if previousState.Happiness and state.Happiness then
			deltas.happiness = state.Happiness - previousState.Happiness
		end
		if previousState.Health and state.Health then
			deltas.health = state.Health - previousState.Health
		end
		if previousState.Smarts and state.Smarts then
			deltas.smarts = state.Smarts - previousState.Smarts
		end
		if previousState.Looks and state.Looks then
			deltas.looks = state.Looks - previousState.Looks
		end
		if previousState.Money and state.Money then
			deltas.money = state.Money - previousState.Money
		end
		
		-- Update current state
		for k, v in pairs(state) do
			currentState[k] = v
			previousState[k] = v
		end
		if state.Stats then
			for k, v in pairs(state.Stats) do
				currentState[k] = v
				previousState[k] = v
			end
		end

		if storyPathsScreenInstance and storyPathsScreenInstance.visible then
			storyPathsScreenInstance:updateUI()
		end
		
		-- Show result popup if we have result data from server
		if resultData and resultData.showPopup then
			showResultPopup({
				emoji = resultData.emoji or "📋",
				title = resultData.title or "Result",
				body = resultData.body or lastFeedText or "Life continues...",
				happiness = resultData.happiness or deltas.happiness,
				health = resultData.health or deltas.health,
				smarts = resultData.smarts or deltas.smarts,
				looks = resultData.looks or deltas.looks,
				money = resultData.money or deltas.money,
			})
		elseif deltas.health and deltas.health < -10 then
			-- Auto-show popup for significant negative health
			shakeScreen(8, 0.3)
			flashScreen(C.Red, 0.6, 0.3)
		elseif deltas.money and deltas.money > 10000 then
			-- Flash green for big money gains
			flashScreen(C.Green, 0.7, 0.3)
		end
	end

	updateFromState()
	if lastFeedText and not (resultData and resultData.showPopup) then
		addFeedEntry(lastFeedText)
	end

	if not introComplete and not currentState.Name then
		showIntro()
	elseif currentState.Name and introOverlay.Visible then
		hideIntro()
	end
end)

-- New: ShowResult remote for explicit result popups
local ShowResult = remotesFolder:FindFirstChild("ShowResult")
if ShowResult then
	ShowResult.OnClientEvent:Connect(function(data)
		showResultPopup({
			emoji = data.emoji or "📋",
			title = data.title or "Result",
			body = data.body or "Something happened...",
			happiness = data.happiness,
			health = data.health,
			smarts = data.smarts,
			looks = data.looks,
			money = data.money,
		}, function()
			-- Callback when popup closed
			if data.feedText then
				addFeedEntry(data.feedText)
			end
		end)
	end)
end

PresentEvent.OnClientEvent:Connect(function(eventData, ageFeedText)
	hideTutorial()
	if ageFeedText then
		addFeedEntry(ageFeedText)
	end
	
	-- Flash effect when event appears
	flashScreen(C.Blue, 0.85, 0.2)
	
	showEvent({
		id               = eventData.id,
		text             = eventData.text,
		choices          = eventData.choices,
		emoji            = eventData.emoji or "🙂",
		title            = eventData.title or "Life Event",
		showRelationship = eventData.showRelationship or false,
		relationName     = eventData.relationName,
		relationship     = eventData.relationship,
		question         = eventData.question,
	})
end)

----------------------------------------------------------------
-- AGE BUTTON LOGIC
----------------------------------------------------------------

local function pulseAge()
	local ti = TweenInfo.new(0.08, Enum.EasingStyle.Quad)
	tween(ageButton, ti, { Size = UDim2.new(1, -2, 1, -2) }).Completed:Wait()
	tween(ageButton, ti, { Size = UDim2.new(1, -6, 1, -6) })
end

ageButton.MouseButton1Click:Connect(function()
	if awaitingEvent or not currentState.Name then return end
	hideTutorial()
	pulseAge()
	RequestAgeUp:FireServer()
end)

ageButton.MouseEnter:Connect(function()
	tween(ageOuterRing, TweenInfo.new(0.15), { Size = UDim2.new(1, 12, 1, 12) })
end)
ageButton.MouseLeave:Connect(function()
	tween(ageOuterRing, TweenInfo.new(0.15), { Size = UDim2.new(1, 8, 1, 8) })
end)

----------------------------------------------------------------
-- SCREEN MODULE INIT
----------------------------------------------------------------

local function safeNew(mod, name, ...)
	if mod and mod.new then
		local s, r = pcall(mod.new, ...)
		if s and r then
			print("[LifeClient] ✅ " .. name .. " initialized")
			return r
		else
			warn("[LifeClient] ❌ Failed to initialize " .. name .. ": " .. tostring(r))
			return nil
		end
	end
	warn("[LifeClient] ❌ Module not found: " .. name)
	return nil
end

occupationScreenInstance    = safeNew(OccupationScreen,    "OccupationScreen",    screenGui, blurOverlay, showBlur, hideBlur, currentState)
assetsScreenInstance        = safeNew(AssetsScreen,        "AssetsScreen",        screenGui, blurOverlay, showBlur, hideBlur, currentState)
relationshipsScreenInstance = safeNew(RelationshipsScreen, "RelationshipsScreen", screenGui, blurOverlay, showBlur, hideBlur, currentState)
activitiesScreenInstance    = safeNew(ActivitiesScreen,    "ActivitiesScreen",    screenGui, blurOverlay, showBlur, hideBlur, currentState)
storyPathsScreenInstance    = safeNew(StoryPathsScreen,    "StoryPathsScreen",    screenGui, currentState)

if MinigamesModule then
	local ok, mg = pcall(MinigamesModule.new, MinigamesModule, screenGui)
	if ok and mg then
		minigamesInstance = mg
		print("[LifeClient] ✅ Minigames initialized!")
	else
		warn("[LifeClient] ⚠️ Failed to initialize minigames")
	end
end

----------------------------------------------------------------
-- INITIAL STATE
----------------------------------------------------------------

ageBtnContainer.Visible = false

task.delay(0.5, function()
	ageBtnContainer.Visible = true
	if not currentState.Name then
		showIntro()
	end
end)

print("[LifeClient] ✅ Premium UI Loaded!")
