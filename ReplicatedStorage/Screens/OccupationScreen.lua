-- OccupationScreen.lua
-- Premium AAA-quality Occupation/Career screen with server validation

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OccupationScreen = {}
OccupationScreen.__index = OccupationScreen

local remotesFolder = ReplicatedStorage:WaitForChild("LifeRemotes", 10)
local ApplyForJob = remotesFolder and remotesFolder:FindFirstChild("ApplyForJob")
local DoWork = remotesFolder and remotesFolder:FindFirstChild("DoWork")
local EnrollEducation = remotesFolder and remotesFolder:FindFirstChild("EnrollEducation")
local QuitJob = remotesFolder and remotesFolder:FindFirstChild("QuitJob")

-- Premium Colors
local C = {
	Navy = Color3.fromRGB(30, 58, 138),
	NavyDark = Color3.fromRGB(23, 37, 84),
	NavyPale = Color3.fromRGB(219, 234, 254),
	Blue = Color3.fromRGB(37, 99, 235),
	BlueDark = Color3.fromRGB(29, 78, 216),
	Green = Color3.fromRGB(34, 197, 94),
	GreenDark = Color3.fromRGB(22, 163, 74),
	GreenPale = Color3.fromRGB(220, 252, 231),
	Orange = Color3.fromRGB(249, 115, 22),
	OrangePale = Color3.fromRGB(255, 237, 213),
	Purple = Color3.fromRGB(139, 92, 246),
	PurplePale = Color3.fromRGB(237, 233, 254),
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
	Gray900 = Color3.fromRGB(17, 24, 39),
	Black = Color3.fromRGB(0, 0, 0),
	Bg = Color3.fromRGB(241, 245, 249),
}

local F = { Title = Enum.Font.GothamBold, Body = Enum.Font.Gotham, Medium = Enum.Font.GothamMedium, Button = Enum.Font.GothamBold }

-- Sample Data
local Jobs = {
	{ id = "fastfood", title = "Cashier", company = "BurgerBit", salary = 22000, minAge = 16, education = "None" },
	{ id = "retail", title = "Sales Associate", company = "MegaMart", salary = 28000, minAge = 16, education = "None" },
	{ id = "office", title = "Office Assistant", company = "PaperCorp", salary = 38000, minAge = 18, education = "HighSchool" },
	{ id = "tech", title = "Junior Developer", company = "TechStart Inc", salary = 65000, minAge = 18, education = "Degree" },
	{ id = "doctor", title = "Resident Doctor", company = "City Hospital", salary = 85000, minAge = 24, education = "Medical" },
}

local Education = {
	{ id = "highschool", name = "High School", duration = "4 years", minAge = 14, maxAge = 18, cost = 0 },
	{ id = "college", name = "College", duration = "4 years", minAge = 18, maxAge = 30, cost = 50000 },
	{ id = "medical", name = "Medical School", duration = "4 years", minAge = 22, maxAge = 35, cost = 150000, prereq = "Degree" },
	{ id = "law", name = "Law School", duration = "3 years", minAge = 22, maxAge = 35, cost = 120000, prereq = "Degree" },
}

-- Helpers
local function corner(p, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r); c.Parent = p; return c end
local function pill(p) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0.5, 0); c.Parent = p; return c end
local function stroke(p, t, tr, col) local s = Instance.new("UIStroke"); s.Thickness = t; s.Transparency = tr or 0; s.Color = col or C.White; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = p; return s end
local function pad(p, l, r, t, b) local pd = Instance.new("UIPadding"); pd.PaddingLeft = UDim.new(0, l or 0); pd.PaddingRight = UDim.new(0, r or 0); pd.PaddingTop = UDim.new(0, t or 0); pd.PaddingBottom = UDim.new(0, b or 0); pd.Parent = p; return pd end
local function tween(o, i, p) local t = TweenService:Create(o, i, p); t:Play(); return t end

local function formatMoney(n)
	if n >= 1000000 then return "$" .. string.format("%.1f", n/1000000) .. "M"
	elseif n >= 1000 then return "$" .. string.format("%.0f", n/1000) .. "K"
	else return "$" .. n end
end

function OccupationScreen.new(screenGui, blurOverlay, showBlurFunc, hideBlurFunc, playerState)
	local self = setmetatable({}, OccupationScreen)
	self.screenGui = screenGui
	self.playerState = playerState
	self.showBlur = showBlurFunc
	self.hideBlur = hideBlurFunc
	self.isVisible = false
	self.currentTab = "jobs"
	self:createUI()
	self:createJobModal()
	self:createResultModal()
	return self
end

function OccupationScreen:getAge() return self.playerState and self.playerState.Age or 0 end
function OccupationScreen:getMoney() return self.playerState and self.playerState.Money or 0 end
function OccupationScreen:getEducation() return self.playerState and self.playerState.Education or "None" end

function OccupationScreen:createUI()
	self.overlay = Instance.new("Frame")
	self.overlay.Name = "OccupationOverlay"
	self.overlay.Size = UDim2.fromScale(1, 1)
	self.overlay.BackgroundColor3 = C.Bg
	self.overlay.Visible = false
	self.overlay.ZIndex = 80
	self.overlay.Parent = self.screenGui
	
	-- Header
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 56)
	header.BackgroundColor3 = C.Navy
	header.ZIndex = 85
	header.Parent = self.overlay
	
	local hGrad = Instance.new("UIGradient")
	hGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, C.Navy), ColorSequenceKeypoint.new(1, C.NavyDark) })
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
	title.Text = "💼 Career"
	title.ZIndex = 86
	title.Parent = header
	
	-- Close button
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
	
	-- Info bar (shows age, money, education)
	self.infoBar = Instance.new("Frame")
	self.infoBar.Size = UDim2.new(1, -16, 0, 44)
	self.infoBar.Position = UDim2.new(0, 8, 0, 64)
	self.infoBar.BackgroundColor3 = C.White
	self.infoBar.ZIndex = 84
	self.infoBar.Parent = self.overlay
	corner(self.infoBar, 12)
	stroke(self.infoBar, 1, 0.9, C.Gray200)
	
	pad(self.infoBar, 12, 12, 0, 0)
	
	local infoLayout = Instance.new("UIListLayout")
	infoLayout.FillDirection = Enum.FillDirection.Horizontal
	infoLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	infoLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	infoLayout.Padding = UDim.new(0, 16)
	infoLayout.Parent = self.infoBar
	
	self.ageInfo = self:createInfoChip(self.infoBar, "👤", "Age 0", 1)
	self.moneyInfo = self:createInfoChip(self.infoBar, "💵", "$0", 2)
	self.eduInfo = self:createInfoChip(self.infoBar, "🎓", "None", 3)
	
	-- Tab bar
	local tabBar = Instance.new("Frame")
	tabBar.Size = UDim2.new(1, -16, 0, 42)
	tabBar.Position = UDim2.new(0, 8, 0, 116)
	tabBar.BackgroundColor3 = C.Gray100
	tabBar.ZIndex = 84
	tabBar.Parent = self.overlay
	corner(tabBar, 12)
	
	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	tabLayout.Padding = UDim.new(0, 4)
	tabLayout.Parent = tabBar
	
	pad(tabBar, 4, 4, 4, 4)
	
	self.tabBtns = {}
	local tabs = { { id = "jobs", text = "💼 Jobs" }, { id = "education", text = "🎓 Education" } }
	
	for i, tab in ipairs(tabs) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0.48, 0, 1, 0)
		btn.BackgroundColor3 = i == 1 and C.Blue or C.White
		btn.Font = F.Button
		btn.TextSize = 13
		btn.TextColor3 = i == 1 and C.White or C.Gray600
		btn.Text = tab.text
		btn.AutoButtonColor = false
		btn.LayoutOrder = i
		btn.ZIndex = 85
		btn.Parent = tabBar
		corner(btn, 10)
		
		self.tabBtns[tab.id] = btn
		
		btn.MouseButton1Click:Connect(function() self:switchTab(tab.id) end)
	end
	
	-- Content area
	self.contentScroll = Instance.new("ScrollingFrame")
	self.contentScroll.Size = UDim2.new(1, -16, 1, -180)
	self.contentScroll.Position = UDim2.new(0, 8, 0, 166)
	self.contentScroll.BackgroundTransparency = 1
	self.contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	self.contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	self.contentScroll.ScrollBarThickness = 3
	self.contentScroll.ScrollBarImageColor3 = C.Gray300
	self.contentScroll.ZIndex = 81
	self.contentScroll.Parent = self.overlay
	
	self.contentLayout = Instance.new("UIListLayout")
	self.contentLayout.Padding = UDim.new(0, 10)
	self.contentLayout.Parent = self.contentScroll
	
	self:populateJobs()
end

function OccupationScreen:createInfoChip(parent, icon, text, order)
	local chip = Instance.new("Frame")
	chip.Size = UDim2.new(0, 90, 0, 32)
	chip.BackgroundColor3 = C.Gray50
	chip.LayoutOrder = order
	chip.ZIndex = 85
	chip.Parent = parent
	corner(chip, 8)
	
	local iconLbl = Instance.new("TextLabel")
	iconLbl.Size = UDim2.new(0, 24, 1, 0)
	iconLbl.Position = UDim2.new(0, 6, 0, 0)
	iconLbl.BackgroundTransparency = 1
	iconLbl.Font = F.Body
	iconLbl.TextSize = 14
	iconLbl.Text = icon
	iconLbl.ZIndex = 86
	iconLbl.Parent = chip
	
	local textLbl = Instance.new("TextLabel")
	textLbl.Name = "Text"
	textLbl.Size = UDim2.new(1, -32, 1, 0)
	textLbl.Position = UDim2.new(0, 28, 0, 0)
	textLbl.BackgroundTransparency = 1
	textLbl.Font = F.Medium
	textLbl.TextSize = 12
	textLbl.TextColor3 = C.Gray700
	textLbl.TextXAlignment = Enum.TextXAlignment.Left
	textLbl.Text = text
	textLbl.ZIndex = 86
	textLbl.Parent = chip
	
	return textLbl
end

function OccupationScreen:updateInfoBar()
	self.ageInfo.Text = "Age " .. self:getAge()
	self.moneyInfo.Text = formatMoney(self:getMoney())
	self.eduInfo.Text = self:getEducation()
end

function OccupationScreen:switchTab(tabId)
	self.currentTab = tabId
	
	for id, btn in pairs(self.tabBtns) do
		local isActive = id == tabId
		tween(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = isActive and C.Blue or C.White,
			TextColor3 = isActive and C.White or C.Gray600
		})
	end
	
	for _, child in ipairs(self.contentScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	
	if tabId == "jobs" then
		self:populateJobs()
	else
		self:populateEducation()
	end
end

function OccupationScreen:populateJobs()
	self:updateInfoBar()
	local age = self:getAge()
	local edu = self:getEducation()
	
	for i, job in ipairs(Jobs) do
		local canApply = age >= job.minAge
		local hasEdu = job.education == "None" or edu == job.education or (job.education == "HighSchool" and (edu == "HighSchool" or edu == "Degree"))
		
		local card = Instance.new("Frame")
		card.Size = UDim2.new(1, 0, 0, 90)
		card.BackgroundColor3 = C.White
		card.LayoutOrder = i
		card.ZIndex = 82
		card.Parent = self.contentScroll
		corner(card, 14)
		stroke(card, 1, 0.9, C.Gray200)
		
		-- Company badge
		local badge = Instance.new("Frame")
		badge.Size = UDim2.new(0, 50, 0, 50)
		badge.Position = UDim2.new(0, 14, 0.5, -25)
		badge.BackgroundColor3 = C.NavyPale
		badge.ZIndex = 83
		badge.Parent = card
		corner(badge, 12)
		
		local badgeLbl = Instance.new("TextLabel")
		badgeLbl.Size = UDim2.fromScale(1, 1)
		badgeLbl.BackgroundTransparency = 1
		badgeLbl.Font = F.Title
		badgeLbl.TextSize = 20
		badgeLbl.TextColor3 = C.Navy
		badgeLbl.Text = job.company:sub(1, 2):upper()
		badgeLbl.ZIndex = 84
		badgeLbl.Parent = badge
		
		-- Job info
		local titleLbl = Instance.new("TextLabel")
		titleLbl.Size = UDim2.new(0.5, 0, 0, 20)
		titleLbl.Position = UDim2.new(0, 74, 0, 14)
		titleLbl.BackgroundTransparency = 1
		titleLbl.Font = F.Title
		titleLbl.TextSize = 15
		titleLbl.TextColor3 = C.Gray900
		titleLbl.TextXAlignment = Enum.TextXAlignment.Left
		titleLbl.Text = job.title
		titleLbl.ZIndex = 83
		titleLbl.Parent = card
		
		local companyLbl = Instance.new("TextLabel")
		companyLbl.Size = UDim2.new(0.5, 0, 0, 16)
		companyLbl.Position = UDim2.new(0, 74, 0, 34)
		companyLbl.BackgroundTransparency = 1
		companyLbl.Font = F.Body
		companyLbl.TextSize = 12
		companyLbl.TextColor3 = C.Gray500
		companyLbl.TextXAlignment = Enum.TextXAlignment.Left
		companyLbl.Text = job.company
		companyLbl.ZIndex = 83
		companyLbl.Parent = card
		
		-- Salary
		local salaryBadge = Instance.new("Frame")
		salaryBadge.Size = UDim2.new(0, 80, 0, 24)
		salaryBadge.Position = UDim2.new(0, 74, 0, 56)
		salaryBadge.BackgroundColor3 = C.GreenPale
		salaryBadge.ZIndex = 83
		salaryBadge.Parent = card
		pill(salaryBadge)
		
		local salaryLbl = Instance.new("TextLabel")
		salaryLbl.Size = UDim2.fromScale(1, 1)
		salaryLbl.BackgroundTransparency = 1
		salaryLbl.Font = F.Medium
		salaryLbl.TextSize = 11
		salaryLbl.TextColor3 = C.GreenDark
		salaryLbl.Text = formatMoney(job.salary) .. "/yr"
		salaryLbl.ZIndex = 84
		salaryLbl.Parent = salaryBadge
		
		-- Apply button
		local canApplyFull = canApply and hasEdu
		local applyBtn = Instance.new("TextButton")
		applyBtn.Size = UDim2.new(0, 70, 0, 36)
		applyBtn.AnchorPoint = Vector2.new(1, 0.5)
		applyBtn.Position = UDim2.new(1, -14, 0.5, 0)
		applyBtn.BackgroundColor3 = canApplyFull and C.Blue or C.Gray300
		applyBtn.Font = F.Button
		applyBtn.TextSize = 12
		applyBtn.TextColor3 = canApplyFull and C.White or C.Gray500
		applyBtn.Text = canApplyFull and "Apply" or (not canApply and "Age " .. job.minAge .. "+" or "Need Edu")
		applyBtn.AutoButtonColor = false
		applyBtn.ZIndex = 83
		applyBtn.Parent = card
		pill(applyBtn)
		
		if canApplyFull then
			applyBtn.MouseEnter:Connect(function() tween(applyBtn, TweenInfo.new(0.1), { BackgroundColor3 = C.BlueDark }) end)
			applyBtn.MouseLeave:Connect(function() tween(applyBtn, TweenInfo.new(0.1), { BackgroundColor3 = C.Blue }) end)
			applyBtn.MouseButton1Click:Connect(function() self:applyForJob(job) end)
		end
	end
end

function OccupationScreen:populateEducation()
	self:updateInfoBar()
	local age = self:getAge()
	local money = self:getMoney()
	local currentEdu = self:getEducation()
	
	for i, edu in ipairs(Education) do
		local canEnroll = age >= edu.minAge and age <= edu.maxAge and money >= edu.cost
		if edu.prereq and currentEdu ~= edu.prereq then canEnroll = false end
		
		local card = Instance.new("Frame")
		card.Size = UDim2.new(1, 0, 0, 90)
		card.BackgroundColor3 = C.White
		card.LayoutOrder = i
		card.ZIndex = 82
		card.Parent = self.contentScroll
		corner(card, 14)
		stroke(card, 1, 0.9, C.Gray200)
		
		-- Icon
		local iconFrame = Instance.new("Frame")
		iconFrame.Size = UDim2.new(0, 50, 0, 50)
		iconFrame.Position = UDim2.new(0, 14, 0.5, -25)
		iconFrame.BackgroundColor3 = C.PurplePale
		iconFrame.ZIndex = 83
		iconFrame.Parent = card
		corner(iconFrame, 12)
		
		local iconLbl = Instance.new("TextLabel")
		iconLbl.Size = UDim2.fromScale(1, 1)
		iconLbl.BackgroundTransparency = 1
		iconLbl.Font = F.Body
		iconLbl.TextSize = 24
		iconLbl.Text = "🎓"
		iconLbl.ZIndex = 84
		iconLbl.Parent = iconFrame
		
		-- Info
		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size = UDim2.new(0.5, 0, 0, 20)
		nameLbl.Position = UDim2.new(0, 74, 0, 14)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Font = F.Title
		nameLbl.TextSize = 15
		nameLbl.TextColor3 = C.Gray900
		nameLbl.TextXAlignment = Enum.TextXAlignment.Left
		nameLbl.Text = edu.name
		nameLbl.ZIndex = 83
		nameLbl.Parent = card
		
		local durationLbl = Instance.new("TextLabel")
		durationLbl.Size = UDim2.new(0.5, 0, 0, 16)
		durationLbl.Position = UDim2.new(0, 74, 0, 34)
		durationLbl.BackgroundTransparency = 1
		durationLbl.Font = F.Body
		durationLbl.TextSize = 12
		durationLbl.TextColor3 = C.Gray500
		durationLbl.TextXAlignment = Enum.TextXAlignment.Left
		durationLbl.Text = edu.duration .. " • Ages " .. edu.minAge .. "-" .. edu.maxAge
		durationLbl.ZIndex = 83
		durationLbl.Parent = card
		
		-- Cost badge
		local costBadge = Instance.new("Frame")
		costBadge.Size = UDim2.new(0, 70, 0, 24)
		costBadge.Position = UDim2.new(0, 74, 0, 56)
		costBadge.BackgroundColor3 = edu.cost > 0 and C.OrangePale or C.GreenPale
		costBadge.ZIndex = 83
		costBadge.Parent = card
		pill(costBadge)
		
		local costLbl = Instance.new("TextLabel")
		costLbl.Size = UDim2.fromScale(1, 1)
		costLbl.BackgroundTransparency = 1
		costLbl.Font = F.Medium
		costLbl.TextSize = 11
		costLbl.TextColor3 = edu.cost > 0 and C.Orange or C.GreenDark
		costLbl.Text = edu.cost > 0 and formatMoney(edu.cost) or "Free"
		costLbl.ZIndex = 84
		costLbl.Parent = costBadge
		
		-- Enroll button
		local enrollBtn = Instance.new("TextButton")
		enrollBtn.Size = UDim2.new(0, 70, 0, 36)
		enrollBtn.AnchorPoint = Vector2.new(1, 0.5)
		enrollBtn.Position = UDim2.new(1, -14, 0.5, 0)
		enrollBtn.BackgroundColor3 = canEnroll and C.Purple or C.Gray300
		enrollBtn.Font = F.Button
		enrollBtn.TextSize = 12
		enrollBtn.TextColor3 = canEnroll and C.White or C.Gray500
		enrollBtn.Text = canEnroll and "Enroll" or (age < edu.minAge and "Age " .. edu.minAge .. "+" or age > edu.maxAge and "Too Old" or money < edu.cost and "Need $" or "N/A")
		enrollBtn.AutoButtonColor = false
		enrollBtn.ZIndex = 83
		enrollBtn.Parent = card
		pill(enrollBtn)
		
		if canEnroll then
			enrollBtn.MouseEnter:Connect(function() tween(enrollBtn, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(124, 58, 237) }) end)
			enrollBtn.MouseLeave:Connect(function() tween(enrollBtn, TweenInfo.new(0.1), { BackgroundColor3 = C.Purple }) end)
			enrollBtn.MouseButton1Click:Connect(function() self:enrollEducation(edu) end)
		end
	end
end

function OccupationScreen:createJobModal()
	-- Reuse result modal pattern
end

function OccupationScreen:createResultModal()
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
	okBtn.MouseEnter:Connect(function() tween(okBtn, TweenInfo.new(0.1), { BackgroundColor3 = C.BlueDark }) end)
	okBtn.MouseLeave:Connect(function() tween(okBtn, TweenInfo.new(0.1), { BackgroundColor3 = C.Blue }) end)
end

function OccupationScreen:applyForJob(job)
	if not ApplyForJob then
		self:showResult(false, "Server not available")
		return
	end
	
	local result = ApplyForJob:InvokeServer(job.id)
	if result then
		self:showResult(result.success, result.message)
	else
		self:showResult(false, "No response from server")
	end
end

function OccupationScreen:enrollEducation(edu)
	if not EnrollEducation then
		self:showResult(false, "Server not available")
		return
	end
	
	local result = EnrollEducation:InvokeServer(edu.id)
	if result then
		self:showResult(result.success, result.message)
	else
		self:showResult(false, "No response from server")
	end
end

function OccupationScreen:showResult(success, message)
	self.resultEmoji.Text = success and "🎉" or "😔"
	self.resultTitle.Text = success and "Success!" or "Not This Time"
	self.resultTitle.TextColor3 = success and C.Green or C.Red
	self.resultMsg.Text = message or ""
	
	self.resultOverlay.Visible = true
	self.resultCard.Position = UDim2.new(0.5, 0, 0.5, 30)
	tween(self.resultCard, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.fromScale(0.5, 0.5) })
end

function OccupationScreen:hideResultModal()
	local t = tween(self.resultCard, TweenInfo.new(0.15), { Position = UDim2.new(0.5, 0, 0.5, 30) })
	t.Completed:Connect(function()
		self.resultOverlay.Visible = false
		self:switchTab(self.currentTab) -- Refresh
	end)
end

function OccupationScreen:show()
	self.overlay.Visible = true
	self.overlay.Position = UDim2.new(1, 0, 0, 0)
	self:updateInfoBar()
	self:switchTab(self.currentTab)
	tween(self.overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.fromScale(0, 0) })
	self.isVisible = true
end

function OccupationScreen:hide()
	local t = tween(self.overlay, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Position = UDim2.new(1, 0, 0, 0) })
	t.Completed:Connect(function()
		self.overlay.Visible = false
		self.resultOverlay.Visible = false
	end)
	self.isVisible = false
end

return OccupationScreen
