-- StarterPlayerScripts/LeaderboardUI.lua
-- Triple AAA Polished Leaderboard UI
-- Smooth animations, glassmorphism, responsive layout

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Configuration
local CONFIG = {
	MaxEntries = 10,
	UpdateSpeed = 0.3, -- Interpolation speed
	Theme = {
		Background = Color3.fromRGB(15, 15, 20),
		BackgroundTransparency = 0.3, -- Glass effect
		Text = Color3.fromRGB(255, 255, 255),
		TextSecondary = Color3.fromRGB(180, 180, 180),
		Accent = Color3.fromRGB(70, 130, 255), -- Blue accent
		Gold = Color3.fromRGB(255, 215, 0),
		Silver = Color3.fromRGB(192, 192, 192),
		Bronze = Color3.fromRGB(205, 127, 50),
		Self = Color3.fromRGB(50, 70, 90)
	},
	MobileScale = 0.85
}

-- Create UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModernLeaderboard"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = playerGui

local Container = Instance.new("Frame")
Container.Name = "Container"
Container.BackgroundColor3 = CONFIG.Theme.Background
Container.BackgroundTransparency = CONFIG.Theme.BackgroundTransparency
Container.BorderSizePixel = 0
Container.Position = UDim2.new(1, -270, 0, 60) -- Top Right
Container.Size = UDim2.new(0, 250, 0, 0) -- Height auto-adjusts
Container.ClipsDescendants = true
Container.Parent = ScreenGui

-- Rounded Corners
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Container

-- Padding
local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 10)
UIPadding.PaddingBottom = UDim.new(0, 10)
UIPadding.PaddingLeft = UDim.new(0, 10)
UIPadding.PaddingRight = UDim.new(0, 10)
UIPadding.Parent = Container

-- Stroke (Border)
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.new(1, 1, 1)
UIStroke.Transparency = 0.9
UIStroke.Thickness = 1
UIStroke.Parent = Container

-- List Layout
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.Parent = Container

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Font = Enum.Font.GothamBold
Title.Text = "LEADERBOARD"
Title.TextColor3 = CONFIG.Theme.TextSecondary
Title.TextSize = 12
Title.LayoutOrder = -1
Title.Parent = Container

-- Template Entry (Hidden)
local Template = Instance.new("Frame")
Template.Name = "Template"
Template.BackgroundColor3 = Color3.new(1, 1, 1)
Template.BackgroundTransparency = 1 -- Default transparent
Template.Size = UDim2.new(1, 0, 0, 24)
Template.Visible = false
Template.Parent = Container

local TemplateRank = Instance.new("TextLabel")
TemplateRank.Name = "RankLabel"
TemplateRank.BackgroundTransparency = 1
TemplateRank.Position = UDim2.new(0, 0, 0, 0)
TemplateRank.Size = UDim2.new(0, 25, 1, 0)
TemplateRank.Font = Enum.Font.GothamBold
TemplateRank.Text = "1"
TemplateRank.TextColor3 = CONFIG.Theme.Text
TemplateRank.TextSize = 14
TemplateRank.TextXAlignment = Enum.TextXAlignment.Left
TemplateRank.Parent = Template

local TemplateName = Instance.new("TextLabel")
TemplateName.Name = "NameLabel"
TemplateName.BackgroundTransparency = 1
TemplateName.Position = UDim2.new(0, 30, 0, 0)
TemplateName.Size = UDim2.new(1, -90, 1, 0)
TemplateName.Font = Enum.Font.GothamMedium
TemplateName.Text = "PlayerName"
TemplateName.TextColor3 = CONFIG.Theme.Text
TemplateName.TextSize = 14
TemplateName.TextXAlignment = Enum.TextXAlignment.Left
TemplateName.TextTruncate = Enum.TextTruncate.AtEnd
TemplateName.Parent = Template

local TemplateScore = Instance.new("TextLabel")
TemplateScore.Name = "ScoreLabel"
TemplateScore.BackgroundTransparency = 1
TemplateScore.Position = UDim2.new(1, -60, 0, 0)
TemplateScore.Size = UDim2.new(0, 60, 1, 0)
TemplateScore.Font = Enum.Font.GothamBold
TemplateScore.Text = "1000"
TemplateScore.TextColor3 = CONFIG.Theme.Accent
TemplateScore.TextSize = 14
TemplateScore.TextXAlignment = Enum.TextXAlignment.Right
TemplateScore.Parent = Template

local TemplateCorner = Instance.new("UICorner")
TemplateCorner.CornerRadius = UDim.new(0, 6)
TemplateCorner.Parent = Template

-- Entries Pool
local entriesUI = {}

-- State
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Adjust for Mobile
if isMobile then
	Container.Position = UDim2.new(0, 10, 0, 10) -- Top Left
	Container.Size = UDim2.new(0, 180, 0, 0) -- Smaller width
	Title.TextSize = 10
	TemplateRank.TextSize = 12
	TemplateName.TextSize = 12
	TemplateScore.TextSize = 12
	ScreenGui.Scale = CONFIG.MobileScale
end

-- Update Function
local function updateLeaderboard(data)
	if not data then return end

	-- Hide all existing
	for _, frame in pairs(entriesUI) do
		frame.Visible = false
	end

	local totalHeight = 35 -- Title padding

	for i, entry in ipairs(data) do
		if i > CONFIG.MaxEntries then break end

		local frame = entriesUI[i]
		if not frame then
			frame = Template:Clone()
			frame.Name = "Entry_" .. i
			frame.Parent = Container
			entriesUI[i] = frame
		end

		frame.Visible = true
		frame.LayoutOrder = i
		frame.NameLabel.Text = entry.Name
		frame.ScoreLabel.Text = tostring(entry.Score)
		frame.RankLabel.Text = tostring(i)

		-- Colors
		if i == 1 then
			frame.RankLabel.TextColor3 = CONFIG.Theme.Gold
		elseif i == 2 then
			frame.RankLabel.TextColor3 = CONFIG.Theme.Silver
		elseif i == 3 then
			frame.RankLabel.TextColor3 = CONFIG.Theme.Bronze
		else
			frame.RankLabel.TextColor3 = CONFIG.Theme.TextSecondary
		end

		-- Highlight Local Player
		if entry.IsPlayer and entry.PlayerId == localPlayer.UserId then
			frame.BackgroundTransparency = 0.8
			frame.BackgroundColor3 = CONFIG.Theme.Accent
			frame.NameLabel.TextColor3 = CONFIG.Theme.Accent
		else
			frame.BackgroundTransparency = 1
			frame.NameLabel.TextColor3 = CONFIG.Theme.Text
		end

		totalHeight = totalHeight + 28 -- Entry height + padding
	end

	-- Smooth Height Resize
	TweenService:Create(Container, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, Container.Size.X.Offset, 0, totalHeight)
	}):Play()
end

-- Listen for Updates
local Event = ReplicatedStorage:WaitForChild("LeaderboardUpdated")
Event.OnClientEvent:Connect(updateLeaderboard)

print("✅ AAA Client Leaderboard Loaded")