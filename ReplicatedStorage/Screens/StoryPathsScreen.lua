-- StoryPathsScreen.lua
-- Shows story path progress (President / Criminal) with special actions

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StoryPathsScreen = {}
StoryPathsScreen.__index = StoryPathsScreen

-- Premium Colors
local C = {
	Navy = Color3.fromRGB(30, 58, 138),
	NavyDark = Color3.fromRGB(23, 37, 84),
	Blue = Color3.fromRGB(37, 99, 235),
	BluePale = Color3.fromRGB(219, 234, 254),
	Green = Color3.fromRGB(34, 197, 94),
	GreenDark = Color3.fromRGB(22, 163, 74),
	GreenPale = Color3.fromRGB(220, 252, 231),
	Red = Color3.fromRGB(239, 68, 68),
	RedPale = Color3.fromRGB(254, 226, 226),
	Purple = Color3.fromRGB(147, 51, 234),
	PurpleDark = Color3.fromRGB(126, 34, 206),
	PurplePale = Color3.fromRGB(243, 232, 255),
	Gold = Color3.fromRGB(234, 179, 8),
	GoldDark = Color3.fromRGB(202, 138, 4),
	Amber = Color3.fromRGB(245, 158, 11),
	Crimson = Color3.fromRGB(185, 28, 28),
	CrimsonDark = Color3.fromRGB(153, 27, 27),
	White = Color3.fromRGB(255, 255, 255),
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
}

local F = { Title = Enum.Font.GothamBold, Body = Enum.Font.Gotham, Medium = Enum.Font.GothamMedium, Button = Enum.Font.GothamBold }

-- Helpers
local function corner(p, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r); c.Parent = p; return c end
local function pill(p) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0.5, 0); c.Parent = p; return c end
local function stroke(p, t, tr, col) local s = Instance.new("UIStroke"); s.Thickness = t; s.Transparency = tr or 0; s.Color = col or C.White; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = p; return s end
local function pad(p, l, r, t, b) local pd = Instance.new("UIPadding"); pd.PaddingLeft = UDim.new(0, l or 0); pd.PaddingRight = UDim.new(0, r or 0); pd.PaddingTop = UDim.new(0, t or 0); pd.PaddingBottom = UDim.new(0, b or 0); pd.Parent = p; return pd end
local function tween(o, i, p) local t = TweenService:Create(o, i, p); t:Play(); return t end
local function gradient(p, c1, c2, rot) local g = Instance.new("UIGradient"); g.Color = ColorSequence.new(c1, c2); g.Rotation = rot or 90; g.Parent = p; return g end

function StoryPathsScreen.new(screenGui, state)
	local self = setmetatable({}, StoryPathsScreen)
	self.screenGui = screenGui
	self.state = state
	self.visible = false
	
	self.remotesFolder = ReplicatedStorage:WaitForChild("LifeRemotes", 5)
	
	self:createUI()
	return self
end

function StoryPathsScreen:createUI()
	-- Main container
	self.container = Instance.new("Frame")
	self.container.Name = "StoryPathsScreen"
	self.container.Size = UDim2.fromScale(1, 1)
	self.container.Position = UDim2.fromScale(0, 1)
	self.container.BackgroundColor3 = C.Gray100
	self.container.Visible = false
	self.container.ZIndex = 100
	self.container.Parent = self.screenGui
	
	-- Header
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 70)
	header.BackgroundColor3 = C.Purple
	header.ZIndex = 101
	header.Parent = self.container
	corner(header, 0)
	gradient(header, C.PurpleDark, C.Purple, 0)
	
	local headerTitle = Instance.new("TextLabel")
	headerTitle.Size = UDim2.new(1, 0, 1, 0)
	headerTitle.BackgroundTransparency = 1
	headerTitle.Font = F.Title
	headerTitle.TextSize = 24
	headerTitle.TextColor3 = C.White
	headerTitle.Text = "🌟 LIFE PATHS"
	headerTitle.ZIndex = 102
	headerTitle.Parent = header
	
	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 44, 0, 44)
	closeBtn.AnchorPoint = Vector2.new(1, 0.5)
	closeBtn.Position = UDim2.new(1, -12, 0.5, 0)
	closeBtn.BackgroundColor3 = C.White
	closeBtn.BackgroundTransparency = 0.8
	closeBtn.Font = F.Title
	closeBtn.TextSize = 22
	closeBtn.TextColor3 = C.White
	closeBtn.Text = "✕"
	closeBtn.AutoButtonColor = false
	closeBtn.ZIndex = 103
	closeBtn.Parent = header
	corner(closeBtn, 22)
	
	closeBtn.MouseButton1Click:Connect(function()
		self:hide()
	end)
	
	-- Scrolling content
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, 0, 1, -70)
	scroll.Position = UDim2.new(0, 0, 0, 70)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 4
	scroll.ScrollBarImageColor3 = C.Gray400
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ZIndex = 101
	scroll.Parent = self.container
	pad(scroll, 16, 16, 20, 100)
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 20)
	layout.Parent = scroll
	
	self.scroll = scroll
	
	-- Create path cards
	self:createPathCard(scroll, "political", {
		title = "🏛️ Political Career",
		subtitle = "Rise to become the President!",
		gradient1 = C.Navy,
		gradient2 = C.Blue,
		levels = {
			{ name = "Citizen", icon = "👤", progress = 0 },
			{ name = "Student Council", icon = "📋", progress = 5 },
			{ name = "Political Intern", icon = "📚", progress = 15 },
			{ name = "City Council", icon = "🏙️", progress = 30 },
			{ name = "State Senator", icon = "🏛️", progress = 50 },
			{ name = "Congressman", icon = "🗳️", progress = 70 },
			{ name = "U.S. Senator", icon = "⭐", progress = 85 },
			{ name = "President", icon = "🎖️", progress = 100 },
		}
	})
	
	self:createPathCard(scroll, "criminal", {
		title = "🔫 Criminal Empire",
		subtitle = "Build your criminal organization!",
		gradient1 = C.CrimsonDark,
		gradient2 = C.Crimson,
		levels = {
			{ name = "Law-Abiding", icon = "😇", progress = 0 },
			{ name = "Petty Criminal", icon = "🤏", progress = 10 },
			{ name = "Car Thief", icon = "🚗", progress = 20 },
			{ name = "Gang Member", icon = "👥", progress = 35 },
			{ name = "Made Member", icon = "💪", progress = 50 },
			{ name = "Underboss", icon = "🎖️", progress = 75 },
			{ name = "Crime Boss", icon = "👑", progress = 100 },
		}
	})
	
	-- Special actions section
	self:createActionsSection(scroll)
end

function StoryPathsScreen:createPathCard(parent, pathId, config)
	local card = Instance.new("Frame")
	card.Name = pathId .. "Card"
	card.Size = UDim2.new(1, 0, 0, 280)
	card.BackgroundColor3 = C.White
	card.LayoutOrder = pathId == "political" and 1 or 2
	card.ZIndex = 102
	card.Parent = parent
	corner(card, 20)
	stroke(card, 1, 0.9, C.Gray300)
	
	-- Header
	local cardHeader = Instance.new("Frame")
	cardHeader.Size = UDim2.new(1, 0, 0, 80)
	cardHeader.BackgroundColor3 = config.gradient1
	cardHeader.ZIndex = 103
	cardHeader.Parent = card
	corner(cardHeader, 20)
	gradient(cardHeader, config.gradient1, config.gradient2, 0)
	
	-- Fix bottom corners of header
	local headerFix = Instance.new("Frame")
	headerFix.Size = UDim2.new(1, 0, 0, 30)
	headerFix.Position = UDim2.new(0, 0, 1, -25)
	headerFix.BackgroundColor3 = config.gradient2
	headerFix.ZIndex = 103
	headerFix.Parent = cardHeader
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -20, 0, 35)
	titleLabel.Position = UDim2.new(0, 10, 0, 12)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = F.Title
	titleLabel.TextSize = 22
	titleLabel.TextColor3 = C.White
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = config.title
	titleLabel.ZIndex = 104
	titleLabel.Parent = cardHeader
	
	local subtitleLabel = Instance.new("TextLabel")
	subtitleLabel.Size = UDim2.new(1, -20, 0, 20)
	subtitleLabel.Position = UDim2.new(0, 10, 0, 45)
	subtitleLabel.BackgroundTransparency = 1
	subtitleLabel.Font = F.Body
	subtitleLabel.TextSize = 13
	subtitleLabel.TextColor3 = C.White
	subtitleLabel.TextTransparency = 0.2
	subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	subtitleLabel.Text = config.subtitle
	subtitleLabel.ZIndex = 104
	subtitleLabel.Parent = cardHeader
	
	-- Current level label
	local levelLabel = Instance.new("TextLabel")
	levelLabel.Name = "LevelLabel"
	levelLabel.Size = UDim2.new(1, -20, 0, 30)
	levelLabel.Position = UDim2.new(0, 10, 0, 90)
	levelLabel.BackgroundTransparency = 1
	levelLabel.Font = F.Button
	levelLabel.TextSize = 16
	levelLabel.TextColor3 = C.Gray800
	levelLabel.TextXAlignment = Enum.TextXAlignment.Left
	levelLabel.Text = "Current: 👤 Citizen"
	levelLabel.ZIndex = 104
	levelLabel.Parent = card
	
	if pathId == "political" then
		self.politicalLevelLabel = levelLabel
	else
		self.criminalLevelLabel = levelLabel
	end
	
	-- Progress bar background
	local progressBg = Instance.new("Frame")
	progressBg.Size = UDim2.new(1, -20, 0, 16)
	progressBg.Position = UDim2.new(0, 10, 0, 125)
	progressBg.BackgroundColor3 = C.Gray200
	progressBg.ZIndex = 103
	progressBg.Parent = card
	pill(progressBg)
	
	-- Progress bar fill
	local progressFill = Instance.new("Frame")
	progressFill.Name = "ProgressFill"
	progressFill.Size = UDim2.new(0, 0, 1, 0)
	progressFill.BackgroundColor3 = config.gradient2
	progressFill.ZIndex = 104
	progressFill.Parent = progressBg
	pill(progressFill)
	
	if pathId == "political" then
		self.politicalProgress = progressFill
	else
		self.criminalProgress = progressFill
	end
	
	-- Progress percentage
	local percentLabel = Instance.new("TextLabel")
	percentLabel.Name = "PercentLabel"
	percentLabel.Size = UDim2.new(1, -20, 0, 20)
	percentLabel.Position = UDim2.new(0, 10, 0, 145)
	percentLabel.BackgroundTransparency = 1
	percentLabel.Font = F.Medium
	percentLabel.TextSize = 12
	percentLabel.TextColor3 = C.Gray500
	percentLabel.TextXAlignment = Enum.TextXAlignment.Right
	percentLabel.Text = "0%"
	percentLabel.ZIndex = 104
	percentLabel.Parent = card
	
	if pathId == "political" then
		self.politicalPercent = percentLabel
	else
		self.criminalPercent = percentLabel
	end
	
	-- Milestone icons
	local milestonesContainer = Instance.new("Frame")
	milestonesContainer.Size = UDim2.new(1, -20, 0, 80)
	milestonesContainer.Position = UDim2.new(0, 10, 0, 175)
	milestonesContainer.BackgroundTransparency = 1
	milestonesContainer.ZIndex = 103
	milestonesContainer.Parent = card
	
	local milestoneLayout = Instance.new("UIListLayout")
	milestoneLayout.FillDirection = Enum.FillDirection.Horizontal
	milestoneLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	milestoneLayout.Padding = UDim.new(0, 6)
	milestoneLayout.Parent = milestonesContainer
	
	local milestones = {}
	for i, level in ipairs(config.levels) do
		local milestone = Instance.new("Frame")
		milestone.Size = UDim2.new(0, 38, 0, 50)
		milestone.BackgroundColor3 = C.Gray100
		milestone.LayoutOrder = i
		milestone.ZIndex = 104
		milestone.Parent = milestonesContainer
		corner(milestone, 8)
		
		local msIcon = Instance.new("TextLabel")
		msIcon.Size = UDim2.new(1, 0, 0, 28)
		msIcon.BackgroundTransparency = 1
		msIcon.Font = F.Body
		msIcon.TextSize = 20
		msIcon.TextColor3 = C.Gray400
		msIcon.Text = level.icon
		msIcon.ZIndex = 105
		msIcon.Parent = milestone
		
		local msLine = Instance.new("Frame")
		msLine.Size = UDim2.new(0.6, 0, 0, 3)
		msLine.AnchorPoint = Vector2.new(0.5, 0)
		msLine.Position = UDim2.new(0.5, 0, 1, -8)
		msLine.BackgroundColor3 = C.Gray300
		msLine.ZIndex = 105
		msLine.Parent = milestone
		pill(msLine)
		
		milestones[i] = { frame = milestone, icon = msIcon, line = msLine, level = level }
	end
	
	if pathId == "political" then
		self.politicalMilestones = milestones
	else
		self.criminalMilestones = milestones
	end
end

function StoryPathsScreen:createActionsSection(parent)
	local section = Instance.new("Frame")
	section.Name = "ActionsSection"
	section.Size = UDim2.new(1, 0, 0, 200)
	section.BackgroundColor3 = C.White
	section.LayoutOrder = 3
	section.ZIndex = 102
	section.Parent = parent
	corner(section, 20)
	stroke(section, 1, 0.9, C.Gray300)
	
	local sectionTitle = Instance.new("TextLabel")
	sectionTitle.Size = UDim2.new(1, -20, 0, 40)
	sectionTitle.Position = UDim2.new(0, 10, 0, 10)
	sectionTitle.BackgroundTransparency = 1
	sectionTitle.Font = F.Title
	sectionTitle.TextSize = 18
	sectionTitle.TextColor3 = C.Gray800
	sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
	sectionTitle.Text = "⚡ Special Actions"
	sectionTitle.ZIndex = 103
	sectionTitle.Parent = section
	
	self.actionsContainer = Instance.new("Frame")
	self.actionsContainer.Size = UDim2.new(1, -20, 0, 130)
	self.actionsContainer.Position = UDim2.new(0, 10, 0, 55)
	self.actionsContainer.BackgroundTransparency = 1
	self.actionsContainer.ZIndex = 103
	self.actionsContainer.Parent = section
	
	local actionsLayout = Instance.new("UIGridLayout")
	actionsLayout.CellSize = UDim2.new(0.48, 0, 0, 55)
	actionsLayout.CellPadding = UDim2.new(0.04, 0, 0, 10)
	actionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	actionsLayout.Parent = self.actionsContainer
	
	self.actionsSection = section
	self.noActionsLabel = Instance.new("TextLabel")
	self.noActionsLabel.Size = UDim2.new(1, 0, 0, 80)
	self.noActionsLabel.Position = UDim2.new(0, 0, 0, 55)
	self.noActionsLabel.BackgroundTransparency = 1
	self.noActionsLabel.Font = F.Body
	self.noActionsLabel.TextSize = 14
	self.noActionsLabel.TextColor3 = C.Gray400
	self.noActionsLabel.Text = "Progress on a life path to unlock special actions!"
	self.noActionsLabel.ZIndex = 103
	self.noActionsLabel.Parent = section
end

function StoryPathsScreen:updateUI()
	if not self.state then return end
	
	local paths = self.state.StoryPaths or {}
	local political = paths.political or { level = "Citizen", progress = 0 }
	local criminal = paths.criminal or { level = "Law-Abiding", progress = 0 }
	
	-- Update political path
	if self.politicalLevelLabel then
		self.politicalLevelLabel.Text = "Current: " .. (political.level or "Citizen")
	end
	if self.politicalProgress then
		local prog = (political.progress or 0) / 100
		tween(self.politicalProgress, TweenInfo.new(0.5, Enum.EasingStyle.Quad), { Size = UDim2.new(prog, 0, 1, 0) })
	end
	if self.politicalPercent then
		self.politicalPercent.Text = tostring(political.progress or 0) .. "%"
	end
	
	-- Update political milestones
	if self.politicalMilestones then
		for i, ms in ipairs(self.politicalMilestones) do
			local reached = (political.progress or 0) >= ms.level.progress
			ms.frame.BackgroundColor3 = reached and C.BluePale or C.Gray100
			ms.icon.TextColor3 = reached and C.Navy or C.Gray400
			ms.line.BackgroundColor3 = reached and C.Navy or C.Gray300
		end
	end
	
	-- Update criminal path
	if self.criminalLevelLabel then
		self.criminalLevelLabel.Text = "Current: " .. (criminal.level or "Law-Abiding")
	end
	if self.criminalProgress then
		local prog = (criminal.progress or 0) / 100
		tween(self.criminalProgress, TweenInfo.new(0.5, Enum.EasingStyle.Quad), { Size = UDim2.new(prog, 0, 1, 0) })
	end
	if self.criminalPercent then
		self.criminalPercent.Text = tostring(criminal.progress or 0) .. "%"
	end
	
	-- Update criminal milestones
	if self.criminalMilestones then
		for i, ms in ipairs(self.criminalMilestones) do
			local reached = (criminal.progress or 0) >= ms.level.progress
			ms.frame.BackgroundColor3 = reached and C.RedPale or C.Gray100
			ms.icon.TextColor3 = reached and C.Crimson or C.Gray400
			ms.line.BackgroundColor3 = reached and C.Crimson or C.Gray300
		end
	end
	
	-- Update special actions
	self:updateActions()
end

function StoryPathsScreen:updateActions()
	-- Clear existing action buttons
	for _, child in ipairs(self.actionsContainer:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	
	-- Get special actions from server
	local actions = {}
	if self.remotesFolder then
		local getActions = self.remotesFolder:FindFirstChild("GetSpecialActions")
		if getActions and getActions:IsA("RemoteFunction") then
			local ok, result = pcall(function()
				return getActions:InvokeServer()
			end)
			if ok and result then
				actions = result
			end
		end
	end
	
	-- Show/hide no actions label
	self.noActionsLabel.Visible = #actions == 0
	
	-- Create action buttons
	for i, action in ipairs(actions) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0.48, 0, 0, 55)
		btn.BackgroundColor3 = action.type == "political" and C.Navy or C.Crimson
		btn.Font = F.Button
		btn.TextSize = 13
		btn.TextColor3 = C.White
		btn.Text = action.emoji .. " " .. action.name
		btn.TextWrapped = true
		btn.AutoButtonColor = false
		btn.LayoutOrder = i
		btn.ZIndex = 104
		btn.Parent = self.actionsContainer
		corner(btn, 12)
		
		btn.MouseEnter:Connect(function()
			tween(btn, TweenInfo.new(0.15), { BackgroundColor3 = action.type == "political" and C.Blue or C.Red })
		end)
		btn.MouseLeave:Connect(function()
			tween(btn, TweenInfo.new(0.15), { BackgroundColor3 = action.type == "political" and C.Navy or C.Crimson })
		end)
		
		btn.MouseButton1Click:Connect(function()
			self:doAction(action.id)
		end)
	end
	
	-- Resize section based on content
	local rows = math.ceil(#actions / 2)
	local height = math.max(rows * 65 + 65, 120)
	self.actionsSection.Size = UDim2.new(1, 0, 0, height)
end

function StoryPathsScreen:doAction(actionId)
	if not self.remotesFolder then return end
	
	local doAction = self.remotesFolder:FindFirstChild("DoSpecialAction")
	if doAction and doAction:IsA("RemoteFunction") then
		local ok, result = pcall(function()
			return doAction:InvokeServer(actionId)
		end)
		
		if ok and result then
			self:showResult(result.success, result.message)
		end
	end
end

function StoryPathsScreen:showResult(success, message)
	-- Create result overlay
	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = C.Black
	overlay.BackgroundTransparency = 0.4
	overlay.ZIndex = 200
	overlay.Parent = self.container
	
	local resultCard = Instance.new("Frame")
	resultCard.Size = UDim2.new(0.85, 0, 0, 200)
	resultCard.AnchorPoint = Vector2.new(0.5, 0.5)
	resultCard.Position = UDim2.fromScale(0.5, 0.5)
	resultCard.BackgroundColor3 = C.White
	resultCard.ZIndex = 201
	resultCard.Parent = overlay
	corner(resultCard, 24)
	
	local emojiCircle = Instance.new("Frame")
	emojiCircle.Size = UDim2.new(0, 60, 0, 60)
	emojiCircle.AnchorPoint = Vector2.new(0.5, 0)
	emojiCircle.Position = UDim2.new(0.5, 0, 0, 20)
	emojiCircle.BackgroundColor3 = success and C.GreenPale or C.RedPale
	emojiCircle.ZIndex = 202
	emojiCircle.Parent = resultCard
	corner(emojiCircle, 30)
	
	local emoji = Instance.new("TextLabel")
	emoji.Size = UDim2.fromScale(1, 1)
	emoji.BackgroundTransparency = 1
	emoji.Font = F.Body
	emoji.TextSize = 32
	emoji.Text = success and "✅" or "❌"
	emoji.ZIndex = 203
	emoji.Parent = emojiCircle
	
	local msgLabel = Instance.new("TextLabel")
	msgLabel.Size = UDim2.new(0.9, 0, 0, 60)
	msgLabel.AnchorPoint = Vector2.new(0.5, 0)
	msgLabel.Position = UDim2.new(0.5, 0, 0, 95)
	msgLabel.BackgroundTransparency = 1
	msgLabel.Font = F.Medium
	msgLabel.TextSize = 15
	msgLabel.TextColor3 = C.Gray700
	msgLabel.TextWrapped = true
	msgLabel.Text = message or "Action completed."
	msgLabel.ZIndex = 202
	msgLabel.Parent = resultCard
	
	local okBtn = Instance.new("TextButton")
	okBtn.Size = UDim2.new(0.7, 0, 0, 44)
	okBtn.AnchorPoint = Vector2.new(0.5, 0)
	okBtn.Position = UDim2.new(0.5, 0, 0, 150)
	okBtn.BackgroundColor3 = success and C.Green or C.Red
	okBtn.Font = F.Button
	okBtn.TextSize = 16
	okBtn.TextColor3 = C.White
	okBtn.Text = "Continue"
	okBtn.AutoButtonColor = false
	okBtn.ZIndex = 202
	okBtn.Parent = resultCard
	corner(okBtn, 12)
	
	okBtn.MouseButton1Click:Connect(function()
		overlay:Destroy()
		self:updateUI()
	end)
end

function StoryPathsScreen:show()
	self.visible = true
	self.container.Visible = true
	self.container.Position = UDim2.fromScale(0, 1)
	
	self:updateUI()
	
	tween(self.container, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0, 0)
	})
end

function StoryPathsScreen:hide()
	self.visible = false
	
	tween(self.container, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = UDim2.fromScale(0, 1)
	})
	
	task.delay(0.25, function()
		if not self.visible then
			self.container.Visible = false
		end
	end)
end

function StoryPathsScreen:toggle()
	if self.visible then
		self:hide()
	else
		self:show()
	end
end

return StoryPathsScreen
