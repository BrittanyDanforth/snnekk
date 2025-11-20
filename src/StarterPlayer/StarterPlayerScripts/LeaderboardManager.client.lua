local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

local CharacterPreview
local previewWarningShown = false
do
	local previewModule = ReplicatedStorage:FindFirstChild("CharacterPreview")
	if previewModule then
		CharacterPreview = require(previewModule)
	else
		if not previewWarningShown then
			previewWarningShown = true
			warn("[Leaderboard] CharacterPreview module not found – continuing without previews")
		end
		CharacterPreview = {
			update = function() end,
			destroy = function() end,
		}
	end
end

local localPlayer = Players.LocalPlayer
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local LeaderboardUpdated = ReplicatedStorage:WaitForChild("LeaderboardUpdated")

local UPDATE_INTERVAL = 1.5
local MAX_VISIBLE_PLAYERS = 5
local lastUpdateTime = 0
local isUpdating = false

local function create(instanceType, properties)
    local inst = Instance.new(instanceType)
    for prop, value in pairs(properties) do
        inst[prop] = value
    end
    return inst
end

local leaderboardGui = create("ScreenGui", {
    Name = "LeaderboardGUI",
    Parent = localPlayer:WaitForChild("PlayerGui"),
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    ResetOnSpawn = false,
    Enabled = false,
    IgnoreGuiInset = true,
})

local topBarInset = GuiService:GetGuiInset()

local container = create("Frame", {
    Name = "Container",
    Parent = leaderboardGui,
    AnchorPoint = isMobile and Vector2.new(0, 0) or Vector2.new(1, 0),
    Position = isMobile and UDim2.new(0, 10, 0, topBarInset.Y + 10) or UDim2.new(1, -15, 0, topBarInset.Y + 10),
    Size = isMobile and UDim2.new(0.85, 0, 0, 400) or UDim2.new(0, 300, 0, 450),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ClipsDescendants = true,
})

if isMobile then
    local screenSize = workspace.CurrentCamera.ViewportSize
    local maxWidth = math.min(screenSize.X - 20, 350)
    container.Size = UDim2.new(0, maxWidth, 0, 400)
end

local headerButton = create("TextButton", {
    Name = "HeaderButton",
    Parent = container,
    Size = UDim2.new(1, 0, 0, 45),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = Color3.fromRGB(25, 25, 35),
    BorderSizePixel = 0,
    Text = "",
    AutoButtonColor = false,
})

create("UICorner", { Parent = headerButton, CornerRadius = UDim.new(0, 12) })
create("UIStroke", { Parent = headerButton, Color = Color3.fromRGB(70, 130, 255), Transparency = 0.3, Thickness = 2 })

local headerContent = create("Frame", {
    Name = "HeaderContent",
    Parent = headerButton,
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
})

create("UIPadding", {
    Parent = headerContent,
    PaddingLeft = UDim.new(0, 15),
    PaddingRight = UDim.new(0, 15),
})

local titleLabel = create("TextLabel", {
    Name = "Title",
    Parent = headerContent,
    Size = UDim2.new(1, -30, 1, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "LEADERBOARD",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = isMobile and 16 or 18,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center,
})

local expandIcon = create("TextLabel", {
    Name = "ExpandIcon",
    Parent = headerContent,
    Size = UDim2.new(0, 20, 0, 20),
    Position = UDim2.new(1, -25, 0.5, -10),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "\226\150\182",
    TextColor3 = Color3.fromRGB(70, 130, 255),
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Center,
    TextYAlignment = Enum.TextYAlignment.Center,
})

local mainContent = create("Frame", {
    Name = "MainContent",
    Parent = container,
    Position = UDim2.new(0, 0, 0, 55),
    Size = UDim2.new(1, 0, 1, -55),
    BackgroundColor3 = Color3.fromRGB(20, 20, 30),
    BorderSizePixel = 0,
    ClipsDescendants = true,
})

create("UICorner", { Parent = mainContent, CornerRadius = UDim.new(0, 12) })
create("UIStroke", { Parent = mainContent, Color = Color3.fromRGB(70, 130, 255), Transparency = 0.5, Thickness = 1 })
create("UIPadding", { Parent = mainContent, PaddingTop = UDim.new(0, 15), PaddingBottom = UDim.new(0, 15), PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15) })

local contentLayout = create("UIListLayout", {
    Parent = mainContent,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 12),
    FillDirection = Enum.FillDirection.Vertical,
})

local yourRankSection = create("Frame", {
    Name = "YourRankSection",
    Parent = mainContent,
    Size = UDim2.new(1, 0, 0, isMobile and 60 or 80),
    BackgroundColor3 = Color3.fromRGB(35, 35, 50),
    BorderSizePixel = 0,
    LayoutOrder = 1,
})

create("UICorner", { Parent = yourRankSection, CornerRadius = UDim.new(0, 8) })
create("UIStroke", { Parent = yourRankSection, Color = Color3.fromRGB(70, 130, 255), Transparency = 0.6, Thickness = 1 })
create("UIPadding", { Parent = yourRankSection, PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) })

local yourInfoContainer = create("Frame", {
    Name = "YourInfoContainer",
    Parent = yourRankSection,
    Size = UDim2.new(1, isMobile and -60 or -70, 1, 0),
    BackgroundTransparency = 1,
})

yourInfoContainer.AutomaticSize = Enum.AutomaticSize.None

yourRankSection.AutomaticSize = Enum.AutomaticSize.None

yourInfoContainer.ZIndex = 2

yourInfoContainer.ClipsDescendants = false

local yourRankLabel = create("TextLabel", {
    Name = "YourRankLabel",
    Parent = yourInfoContainer,
    Size = UDim2.new(1, 0, 0.5, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "Your Rank: #1",
    TextColor3 = Color3.fromRGB(255, 215, 0),
    TextSize = isMobile and 14 or 16,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center,
})

local yourScoreLabel = create("TextLabel", {
    Name = "YourScoreLabel",
    Parent = yourInfoContainer,
    Size = UDim2.new(1, 0, 0.5, 0),
    Position = UDim2.new(0, 0, 0.5, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "Score: 0",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    TextSize = isMobile and 12 or 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center,
})

local topPlayersSection = create("Frame", {
    Name = "TopPlayersSection",
    Parent = mainContent,
    Size = UDim2.new(1, 0, 1, isMobile and -80 or -100),
    BackgroundTransparency = 1,
    LayoutOrder = 2,
})

local topPlayersHeader = create("TextLabel", {
    Name = "TopPlayersHeader",
    Parent = topPlayersSection,
    Size = UDim2.new(1, 0, 0, 25),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "TOP PLAYERS",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = isMobile and 14 or 16,
    TextXAlignment = Enum.TextXAlignment.Center,
    TextYAlignment = Enum.TextYAlignment.Center,
})

local playerList = create("ScrollingFrame", {
    Name = "PlayerList",
    Parent = topPlayersSection,
    Position = UDim2.new(0, 0, 0, 30),
    Size = UDim2.new(1, 0, 1, -30),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollBarImageColor3 = Color3.fromRGB(70, 130, 255),
    ScrollBarThickness = 4,
    ScrollBarImageTransparency = 0.3,
    ScrollingDirection = Enum.ScrollingDirection.Y,
})

create("UIListLayout", {
    Parent = playerList,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 4),
    FillDirection = Enum.FillDirection.Vertical,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
})

local template = create("Frame", {
    Name = "PlayerEntryTemplate",
    Parent = playerList,
    Visible = false,
    Size = UDim2.new(1, -8, 0, isMobile and 35 or 40),
    BackgroundColor3 = Color3.fromRGB(30, 30, 40),
    BorderSizePixel = 0,
})

create("UICorner", { Parent = template, CornerRadius = UDim.new(0, 6) })

create("UIListLayout", {
    Parent = template,
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 8),
})

create("UIPadding", {
    Parent = template,
    PaddingLeft = UDim.new(0, 12),
    PaddingRight = UDim.new(0, 12),
})

local rankBadge = create("Frame", {
    Name = "RankBadge",
    Parent = template,
    Size = UDim2.new(0, isMobile and 25 or 30, 0, isMobile and 25 or 30),
    BackgroundColor3 = Color3.fromRGB(70, 130, 255),
    BorderSizePixel = 0,
    LayoutOrder = 1,
})

create("UICorner", { Parent = rankBadge, CornerRadius = UDim.new(0.5, 0) })

local rankText = create("TextLabel", {
    Name = "RankText",
    Parent = rankBadge,
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "1",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = isMobile and 12 or 14,
    TextXAlignment = Enum.TextXAlignment.Center,
    TextYAlignment = Enum.TextYAlignment.Center,
})

local playerNameLabel = create("TextLabel", {
    Name = "PlayerName",
    Parent = template,
    Size = UDim2.new(1, isMobile and -80 or -100, 1, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "Player",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = isMobile and 13 or 15,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center,
    TextTruncate = Enum.TextTruncate.AtEnd,
    LayoutOrder = 2,
})

local scoreLabel = create("TextLabel", {
    Name = "Score",
    Parent = template,
    Size = UDim2.new(0, 40, 1, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "0",
    TextColor3 = Color3.fromRGB(255, 215, 0),
    TextSize = isMobile and 12 or 14,
    TextXAlignment = Enum.TextXAlignment.Right,
    TextYAlignment = Enum.TextYAlignment.Center,
    LayoutOrder = 3,
})

local playerEntries = {}
local isExpanded = not isMobile

local lastPlayerData = { skin = nil }

local function getEntryKey(data)
	if data.IsPlayer and data.PlayerId and data.PlayerId ~= -1 then
		return ("player_%s"):format(data.PlayerId)
	end
	return ("ai_%s"):format(data.Name or "AI")
end

local function toggleExpansion()
    if container:GetAttribute("Animating") then return end
    container:SetAttribute("Animating", true)

    isExpanded = not isExpanded

    local targetSize = isExpanded and UDim2.new(1, 0, 1, -55) or UDim2.new(1, 0, 0, 0)
    local iconRotation = isExpanded and 0 or 180

    TweenService:Create(mainContent, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
    TweenService:Create(expandIcon, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = iconRotation}):Play()

    task.delay(0.3, function()
        container:SetAttribute("Animating", false)
    end)
end

headerButton.MouseButton1Click:Connect(toggleExpansion)

local function updateLeaderboard(entries)
	if not entries or #entries == 0 then
		return
	end
    if isUpdating then return end
    local currentTime = tick()
    if currentTime - lastUpdateTime < UPDATE_INTERVAL then
        return
    end

    isUpdating = true
    lastUpdateTime = currentTime

    local topPlayers = entries or {}

    local localPlayerRank = 0
    local localPlayerScore = 0

    for i, data in ipairs(topPlayers) do
        if data.PlayerId == localPlayer.UserId then
            localPlayerRank = i
            localPlayerScore = data.Score
            break
        end
    end

    yourRankLabel.Text = localPlayerRank > 0 and ("Your Rank: #" .. localPlayerRank) or "Your Rank: Unranked"
    yourScoreLabel.Text = "Score: " .. localPlayerScore

    local localPlayerSkin = localPlayer:GetAttribute("SelectedSkin") or "Default"
    if lastPlayerData.skin ~= localPlayerSkin then
        CharacterPreview.update(localPlayerSkin)
        lastPlayerData.skin = localPlayerSkin
    end

	local activePlayers = {}
    for rank, data in ipairs(topPlayers) do
        if rank > MAX_VISIBLE_PLAYERS then break end
		local entryKey = getEntryKey(data)
		local entry = playerEntries[entryKey]
		if not entry then
			entry = template:Clone()
			playerEntries[entryKey] = entry
		end
        entry.Parent = playerList
        entry.Visible = true

        entry.RankBadge.RankText.Text = tostring(rank)
        entry.PlayerName.Text = data.Name
        entry.Score.Text = tostring(data.Score)
        entry.LayoutOrder = rank

        local badgeColor
        if rank == 1 then
            badgeColor = Color3.fromRGB(255, 215, 0)
        elseif rank == 2 then
            badgeColor = Color3.fromRGB(192, 192, 192)
        elseif rank == 3 then
            badgeColor = Color3.fromRGB(205, 127, 50)
        else
            badgeColor = Color3.fromRGB(70, 130, 255)
        end
        entry.RankBadge.BackgroundColor3 = badgeColor

        entry.BackgroundColor3 = (data.PlayerId == localPlayer.UserId) and Color3.fromRGB(50, 50, 70) or Color3.fromRGB(30, 30, 40)

		activePlayers[entryKey] = true
    end

	for entryKey, entry in pairs(playerEntries) do
		if not activePlayers[entryKey] then
            entry:Destroy()
			playerEntries[entryKey] = nil
        end
    end

    local visibleCount = math.min(#topPlayers, MAX_VISIBLE_PLAYERS)
    local perEntry = isMobile and 39 or 44
    playerList.CanvasSize = UDim2.new(0, 0, 0, visibleCount * perEntry)

    isUpdating = false
end

LeaderboardUpdated.OnClientEvent:Connect(function(entries)
    updateLeaderboard(entries)
end)

Players.PlayerRemoving:Connect(function(player)
    local entry = playerEntries[player.UserId]
    if entry then
        entry:Destroy()
        playerEntries[player.UserId] = nil
    end
end)

leaderboardGui.AncestryChanged:Connect(function()
    if not leaderboardGui.Parent then
        CharacterPreview.destroy()
    end
end)

local function onCharacterAdded(character)
    leaderboardGui.Enabled = true

    if isMobile and isExpanded then
        task.delay(2, function()
            if isExpanded then
                toggleExpansion()
            end
        end)
    end

    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        leaderboardGui.Enabled = false
    end)
end

localPlayer.CharacterAdded:Connect(onCharacterAdded)
if localPlayer.Character then
    onCharacterAdded(localPlayer.Character)
end

if not isExpanded then
    mainContent.Size = UDim2.new(1, 0, 0, 0)
    expandIcon.Rotation = 180
end

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    if isMobile then
        local screenSize = workspace.CurrentCamera.ViewportSize
        local maxWidth = math.min(screenSize.X - 20, 350)
        container.Size = UDim2.new(0, maxWidth, 0, 400)
    end
end)

print("Optimized Mobile Leaderboard Loaded")
