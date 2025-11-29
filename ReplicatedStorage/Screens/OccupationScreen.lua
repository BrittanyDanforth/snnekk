-- OccupationScreen.lua
-- Premium BitLife-style Occupation screen
-- Triple AAA polished UI for jobs and education

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UI = require(ReplicatedStorage:WaitForChild("UIComponents"))
local C = UI.Colors
local F = UI.Fonts

local OccupationScreen = {}
OccupationScreen.__index = OccupationScreen

-- Remotes
local remotesFolder = ReplicatedStorage:WaitForChild("LifeRemotes", 30)
local ApplyForJob = remotesFolder and remotesFolder:WaitForChild("ApplyForJob", 15)
local QuitJob = remotesFolder and remotesFolder:WaitForChild("QuitJob", 15)
local EnrollEducation = remotesFolder and remotesFolder:WaitForChild("EnrollEducation", 15)

-- Job Data - Must match server's JobListings IDs exactly!
local Jobs = {
	-- Entry Level (No Requirements)
	{ id = "fastfood", name = "Fast Food Worker", company = "Burger Palace", emoji = "🍔", salary = 22000, minAge = 14, requirement = nil },
	{ id = "retail", name = "Retail Associate", company = "MegaMart", emoji = "🛒", salary = 26000, minAge = 16, requirement = nil },
	{ id = "janitor", name = "Janitor", company = "CleanCo Services", emoji = "🧹", salary = 28000, minAge = 18, requirement = nil },
	
	-- Office Jobs (High School)
	{ id = "receptionist", name = "Receptionist", company = "Corporate Office", emoji = "📞", salary = 32000, minAge = 18, requirement = "high_school" },
	{ id = "office", name = "Office Assistant", company = "Business Solutions", emoji = "📋", salary = 35000, minAge = 18, requirement = "high_school" },
	
	-- Professional (Bachelor's)
	{ id = "accountant_jr", name = "Junior Accountant", company = "Financial Services", emoji = "📊", salary = 48000, minAge = 22, requirement = "bachelor" },
	{ id = "marketing", name = "Marketing Associate", company = "AdVenture Agency", emoji = "📈", salary = 52000, minAge = 22, requirement = "bachelor" },
	{ id = "developer", name = "Software Developer", company = "TechStart Inc", emoji = "💻", salary = 85000, minAge = 22, requirement = "bachelor" },
	{ id = "senior_dev", name = "Senior Developer", company = "BigTech Corp", emoji = "🖥️", salary = 140000, minAge = 26, requirement = "bachelor" },
	
	-- Advanced Degrees
	{ id = "doctor", name = "Doctor", company = "City Hospital", emoji = "🩺", salary = 250000, minAge = 30, requirement = "medical" },
	{ id = "lawyer", name = "Lawyer", company = "Smith & Associates", emoji = "⚖️", salary = 180000, minAge = 28, requirement = "law" },
}

-- Education Data - Must match server's EducationOptions IDs!
local Education = {
	{ id = "community", name = "Community College", emoji = "🏫", duration = 2, cost = 15000, minAge = 18, requirement = "high_school" },
	{ id = "bachelor", name = "Bachelor's Degree", emoji = "🎓", duration = 4, cost = 80000, minAge = 18, requirement = "high_school" },
	{ id = "master", name = "Master's Degree", emoji = "📚", duration = 2, cost = 60000, minAge = 22, requirement = "bachelor" },
	{ id = "law", name = "Law School", emoji = "⚖️", duration = 3, cost = 150000, minAge = 22, requirement = "bachelor" },
	{ id = "medical", name = "Medical School", emoji = "🏥", duration = 4, cost = 200000, minAge = 22, requirement = "bachelor" },
	{ id = "phd", name = "PhD Program", emoji = "🎓", duration = 5, cost = 100000, minAge = 24, requirement = "master" },
}

-- Debug logging
local DEBUG = true
local function log(...)
	if DEBUG then print("[OccupationScreen]", ...) end
end
local function logWarn(...)
	warn("[OccupationScreen]", ...)
end

function OccupationScreen.new(screenGui, blurOverlay, showBlurFunc, hideBlurFunc, playerState)
	log("=== CREATING OccupationScreen ===")
	local self = setmetatable({}, OccupationScreen)
	self.screenGui = screenGui
	self.playerState = playerState or {}
	self.showBlur = showBlurFunc
	self.hideBlur = hideBlurFunc
	self.isVisible = false
	self.currentTab = "jobs"
	log("Initial state - Age:", self:getAge(), "Money:", self:getMoney(), "Job:", self:getCurrentJob() or "None")
	self:createUI()
	log("✅ OccupationScreen created successfully")
	return self
end

function OccupationScreen:updateState(newState)
	log("Updating state...")
	if newState then 
		self.playerState = newState 
		log("State updated - Age:", self:getAge(), "Money:", self:getMoney(), "Job:", self:getCurrentJob() or "None")
	end
end

function OccupationScreen:getAge()
	local state = self.playerState
	if not state then return 18 end
	return state.Age or (state.Stats and state.Stats.Age) or 18
end

function OccupationScreen:getMoney()
	local state = self.playerState
	if not state then return 0 end
	return state.Money or (state.Stats and state.Stats.Money) or 0
end

function OccupationScreen:getCurrentJob()
	local state = self.playerState
	if not state then return nil end
	return state.Job or (state.Career and state.Career.current)
end

function OccupationScreen:getEducationLevel()
	local state = self.playerState
	if not state then return "high_school" end
	return state.Education or (state.Career and state.Career.education) or "high_school"
end

function OccupationScreen:isEnrolled()
	local state = self.playerState
	if not state then return false end
	return state.Enrolled or (state.Career and state.Career.enrolled) or false
end

function OccupationScreen:createUI()
	-- Main overlay
	self.overlay = Instance.new("Frame")
	self.overlay.Name = "OccupationOverlay"
	self.overlay.Size = UDim2.fromScale(1, 1)
	self.overlay.BackgroundColor3 = C.Bg
	self.overlay.Visible = false
	self.overlay.ZIndex = 80
	self.overlay.Parent = self.screenGui
	
	-- Premium header
	local headerData = UI.createScreenHeader(self.overlay, {
		title = "Career & Education",
		color = C.Blue,
		colorDark = C.BlueDark,
		zIndex = 85
	})
	self.header = headerData.header
	headerData.closeButton.MouseButton1Click:Connect(function() self:hide() end)
	headerData.closeButton.MouseEnter:Connect(function()
		UI.tween(headerData.closeButton, TweenInfo.new(0.12), { BackgroundTransparency = 0 })
	end)
	headerData.closeButton.MouseLeave:Connect(function()
		UI.tween(headerData.closeButton, TweenInfo.new(0.12), { BackgroundTransparency = 0.1 })
	end)
	
	-- Info bar (no shadow for layout elements)
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
		name = "AgeChip", icon = "Age", text = "18",
		bgColor = C.BluePale, textColor = C.BlueDark, order = 1, width = 75
	})
	self.ageChip.icon.Text = ""
	self.ageChip.text.Text = "Age 18"
	self.ageChip.text.Position = UDim2.new(0, 10, 0, 0)
	self.ageChip.text.Size = UDim2.new(1, -20, 1, 0)
	self.ageChip.text.TextXAlignment = Enum.TextXAlignment.Center
	
	self.moneyChip = UI.createInfoChip(self.infoBar, {
		name = "MoneyChip", icon = "$", text = "$0",
		bgColor = C.GreenPale, textColor = C.GreenDark, order = 2, width = 90
	})
	self.moneyChip.icon.Text = ""
	self.moneyChip.text.Text = "$0"
	self.moneyChip.text.Position = UDim2.new(0, 10, 0, 0)
	self.moneyChip.text.Size = UDim2.new(1, -20, 1, 0)
	self.moneyChip.text.TextXAlignment = Enum.TextXAlignment.Center
	
	self.jobChip = UI.createInfoChip(self.infoBar, {
		name = "JobChip", icon = "Job", text = "None",
		bgColor = C.AmberPale, textColor = C.AmberDark, order = 3, width = 100
	})
	self.jobChip.icon.Text = ""
	self.jobChip.text.Text = "Unemployed"
	self.jobChip.text.Position = UDim2.new(0, 10, 0, 0)
	self.jobChip.text.Size = UDim2.new(1, -20, 1, 0)
	self.jobChip.text.TextXAlignment = Enum.TextXAlignment.Center
	
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
	tabLayout.Padding = UDim.new(0, 8)
	tabLayout.Parent = self.tabBar
	
	-- Jobs tab
	self.jobsTab = Instance.new("TextButton")
	self.jobsTab.Name = "JobsTab"
	self.jobsTab.Size = UDim2.new(0.46, 0, 1, 0)
	self.jobsTab.BackgroundColor3 = C.Blue
	self.jobsTab.Font = F.Button
	self.jobsTab.TextSize = 15
	self.jobsTab.TextColor3 = C.White
	self.jobsTab.Text = "Jobs"
	self.jobsTab.AutoButtonColor = false
	self.jobsTab.LayoutOrder = 1
	self.jobsTab.ZIndex = 85
	self.jobsTab.Parent = self.tabBar
	UI.corner(self.jobsTab, 10)
	
	-- Education tab
	self.eduTab = Instance.new("TextButton")
	self.eduTab.Name = "EduTab"
	self.eduTab.Size = UDim2.new(0.46, 0, 1, 0)
	self.eduTab.BackgroundColor3 = C.White
	self.eduTab.Font = F.Button
	self.eduTab.TextSize = 15
	self.eduTab.TextColor3 = C.Gray600
	self.eduTab.Text = "Education"
	self.eduTab.AutoButtonColor = false
	self.eduTab.LayoutOrder = 2
	self.eduTab.ZIndex = 85
	self.eduTab.Parent = self.tabBar
	UI.corner(self.eduTab, 10)
	
	self.jobsTab.MouseButton1Click:Connect(function() self:switchTab("jobs") end)
	self.eduTab.MouseButton1Click:Connect(function() self:switchTab("education") end)
	
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
	
	-- Result modal
	self:createResultModal()
	
	-- Initial populate
	self:populateJobs()
end

function OccupationScreen:updateInfoBar()
	local age = self:getAge()
	local money = self:getMoney()
	local job = self:getCurrentJob()
	
	self.ageChip.text.Text = "Age " .. age
	self.moneyChip.text.Text = UI.formatMoney(money)
	
	if job then
		-- Find job name
		local jobName = "Employed"
		for _, j in ipairs(Jobs) do
			if j.id == job then
				jobName = j.name
				break
			end
		end
		self.jobChip.text.Text = jobName
		self.jobChip.chip.BackgroundColor3 = C.GreenPale
		self.jobChip.text.TextColor3 = C.GreenDark
	else
		self.jobChip.text.Text = "Unemployed"
		self.jobChip.chip.BackgroundColor3 = C.AmberPale
		self.jobChip.text.TextColor3 = C.AmberDark
	end
end

function OccupationScreen:switchTab(tabId)
	log("Switching tab to:", tabId)
	self.currentTab = tabId
	
	if tabId == "jobs" then
		log("Animating to Jobs tab")
		UI.tween(self.jobsTab, TweenInfo.new(0.15), { BackgroundColor3 = C.Blue, TextColor3 = C.White })
		UI.tween(self.eduTab, TweenInfo.new(0.15), { BackgroundColor3 = C.White, TextColor3 = C.Gray600 })
		self:populateJobs()
	else
		log("Animating to Education tab")
		UI.tween(self.jobsTab, TweenInfo.new(0.15), { BackgroundColor3 = C.White, TextColor3 = C.Gray600 })
		UI.tween(self.eduTab, TweenInfo.new(0.15), { BackgroundColor3 = C.Purple, TextColor3 = C.White })
		self:populateEducation()
	end
end

function OccupationScreen:populateJobs()
	self:updateInfoBar()
	
	-- Clear content
	for _, child in ipairs(self.contentScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	
	local age = self:getAge()
	local currentJob = self:getCurrentJob()
	local eduLevel = self:getEducationLevel()
	
	-- Current job section (if employed)
	if currentJob then
		local currentSection = Instance.new("Frame")
		currentSection.Name = "CurrentJobSection"
		currentSection.Size = UDim2.new(1, 0, 0, 0)
		currentSection.AutomaticSize = Enum.AutomaticSize.Y
		currentSection.BackgroundColor3 = C.GreenPale
		currentSection.LayoutOrder = 0
		currentSection.ZIndex = 82
		currentSection.Parent = self.contentScroll
		UI.corner(currentSection, 18)
		UI.stroke(currentSection, 2, 0.6, C.Green)
		UI.pad(currentSection, 16, 16, 16, 16)
		
		local currentLayout = Instance.new("UIListLayout")
		currentLayout.Padding = UDim.new(0, 10)
		currentLayout.Parent = currentSection
		
		-- Find current job data
		local jobData = nil
		for _, j in ipairs(Jobs) do
			if j.id == currentJob then
				jobData = j
				break
			end
		end
		
		if jobData then
			self:createCurrentJobCard(currentSection, jobData)
		end
	end
	
	-- Available jobs section
	local section = Instance.new("Frame")
	section.Name = "AvailableJobsSection"
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
	
	-- Section header
	local headerFrame = Instance.new("Frame")
	headerFrame.Name = "Header"
	headerFrame.Size = UDim2.new(1, 0, 0, 36)
	headerFrame.BackgroundTransparency = 1
	headerFrame.LayoutOrder = 0
	headerFrame.ZIndex = 83
	headerFrame.Parent = section
	
	local badge = Instance.new("Frame")
	badge.Size = UDim2.new(0, 120, 0, 32)
	badge.BackgroundColor3 = C.Blue
	badge.ZIndex = 84
	badge.Parent = headerFrame
	UI.pill(badge)
	
	local badgeLabel = Instance.new("TextLabel")
	badgeLabel.Size = UDim2.fromScale(1, 1)
	badgeLabel.BackgroundTransparency = 1
	badgeLabel.Font = F.Button
	badgeLabel.TextSize = 14
	badgeLabel.TextColor3 = C.White
	badgeLabel.Text = "Available Jobs"
	badgeLabel.ZIndex = 85
	badgeLabel.Parent = badge
	
	-- Add jobs
	local order = 1
	for _, job in ipairs(Jobs) do
		if job.id ~= currentJob then
			self:createJobCard(section, job, order, age, eduLevel)
			order = order + 1
		end
	end
end

function OccupationScreen:createCurrentJobCard(parent, job)
	local card = Instance.new("Frame")
	card.Name = "CurrentJob"
	card.Size = UDim2.new(1, 0, 0, 100)
	card.BackgroundColor3 = C.White
	card.LayoutOrder = 1
	card.ZIndex = 83
	card.Parent = parent
	UI.corner(card, 16)
	
	-- Icon
	local iconFrame = Instance.new("Frame")
	iconFrame.Size = UDim2.new(0, 64, 0, 64)
	iconFrame.Position = UDim2.new(0, 14, 0.5, -32)
	iconFrame.BackgroundColor3 = C.GreenPale
	iconFrame.ZIndex = 84
	iconFrame.Parent = card
	UI.corner(iconFrame, 14)
	
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.fromScale(1, 1)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Font = F.Body
	iconLabel.TextSize = 32
	iconLabel.Text = job.emoji
	iconLabel.ZIndex = 85
	iconLabel.Parent = iconFrame
	
	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0.5, 0, 0, 24)
	titleLabel.Position = UDim2.new(0, 92, 0, 16)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = F.Title
	titleLabel.TextSize = 17
	titleLabel.TextColor3 = C.Gray900
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = job.name
	titleLabel.ZIndex = 84
	titleLabel.Parent = card
	
	-- Current job badge
	local currentBadge = Instance.new("Frame")
	currentBadge.Size = UDim2.new(0, 95, 0, 26)
	currentBadge.Position = UDim2.new(0, 92, 0, 44)
	currentBadge.BackgroundColor3 = C.Green
	currentBadge.ZIndex = 84
	currentBadge.Parent = card
	UI.pill(currentBadge)
	
	local currentLabel = Instance.new("TextLabel")
	currentLabel.Size = UDim2.fromScale(1, 1)
	currentLabel.BackgroundTransparency = 1
	currentLabel.Font = F.Medium
	currentLabel.TextSize = 11
	currentLabel.TextColor3 = C.White
	currentLabel.Text = "Current Job"
	currentLabel.ZIndex = 85
	currentLabel.Parent = currentBadge
	
	-- Salary
	local salaryLabel = Instance.new("TextLabel")
	salaryLabel.Size = UDim2.new(0, 100, 0, 20)
	salaryLabel.Position = UDim2.new(0, 92, 0, 72)
	salaryLabel.BackgroundTransparency = 1
	salaryLabel.Font = F.Body
	salaryLabel.TextSize = 13
	salaryLabel.TextColor3 = C.GreenDark
	salaryLabel.TextXAlignment = Enum.TextXAlignment.Left
	salaryLabel.Text = UI.formatMoney(job.salary) .. "/year"
	salaryLabel.ZIndex = 84
	salaryLabel.Parent = card
	
	-- Quit button
	local quitBtn = Instance.new("TextButton")
	quitBtn.Size = UDim2.new(0, 72, 0, 44)
	quitBtn.AnchorPoint = Vector2.new(1, 0.5)
	quitBtn.Position = UDim2.new(1, -14, 0.5, 0)
	quitBtn.BackgroundColor3 = C.Red
	quitBtn.Font = F.Button
	quitBtn.TextSize = 14
	quitBtn.TextColor3 = C.White
	quitBtn.Text = "Quit"
	quitBtn.AutoButtonColor = false
	quitBtn.ZIndex = 84
	quitBtn.Parent = card
	UI.corner(quitBtn, 12)
	
	quitBtn.MouseEnter:Connect(function()
		UI.tween(quitBtn, TweenInfo.new(0.12), { BackgroundColor3 = C.RedDark })
	end)
	quitBtn.MouseLeave:Connect(function()
		UI.tween(quitBtn, TweenInfo.new(0.12), { BackgroundColor3 = C.Red })
	end)
	quitBtn.MouseButton1Click:Connect(function()
		self:quitJob()
	end)
end

function OccupationScreen:createJobCard(parent, job, order, age, eduLevel)
	local meetsAge = age >= job.minAge
	local meetsEdu = true
	local eduNeeded = nil
	
	-- Check education requirement
	if job.requirement then
		local eduRanks = { none = 0, high_school = 1, community_college = 2, university = 3, graduate_school = 4, law_school = 4, medical_school = 4, mba = 4 }
		local playerRank = eduRanks[eduLevel] or 1
		local jobRank = eduRanks[job.requirement] or 0
		meetsEdu = playerRank >= jobRank
		if not meetsEdu then
			eduNeeded = job.requirement:gsub("_", " "):gsub("^%l", string.upper)
		end
	end
	
	local canApply = meetsAge and meetsEdu
	
	local card = Instance.new("Frame")
	card.Name = job.id
	card.Size = UDim2.new(1, 0, 0, 90)
	card.BackgroundColor3 = C.White
	card.LayoutOrder = order
	card.ZIndex = 83
	card.Parent = parent
	UI.corner(card, 14)
	UI.stroke(card, 1, canApply and 0.7 or 0.88, canApply and C.Blue or C.Gray200)
	
	-- Icon
	local iconFrame = Instance.new("Frame")
	iconFrame.Size = UDim2.new(0, 56, 0, 56)
	iconFrame.Position = UDim2.new(0, 12, 0.5, -28)
	iconFrame.BackgroundColor3 = canApply and C.BluePale or C.Gray100
	iconFrame.ZIndex = 84
	iconFrame.Parent = card
	UI.corner(iconFrame, 12)
	
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.fromScale(1, 1)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Font = F.Body
	iconLabel.TextSize = 28
	iconLabel.Text = job.emoji
	iconLabel.TextTransparency = canApply and 0 or 0.3
	iconLabel.ZIndex = 85
	iconLabel.Parent = iconFrame
	
	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0.5, 0, 0, 22)
	titleLabel.Position = UDim2.new(0, 80, 0, 12)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = F.Title
	titleLabel.TextSize = 15
	titleLabel.TextColor3 = canApply and C.Gray900 or C.Gray500
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = job.name
	titleLabel.ZIndex = 84
	titleLabel.Parent = card
	
	-- Salary badge
	local salaryBadge = Instance.new("Frame")
	salaryBadge.Size = UDim2.new(0, 85, 0, 24)
	salaryBadge.Position = UDim2.new(0, 80, 0, 36)
	salaryBadge.BackgroundColor3 = C.GreenPale
	salaryBadge.ZIndex = 84
	salaryBadge.Parent = card
	UI.pill(salaryBadge)
	
	local salaryLabel = Instance.new("TextLabel")
	salaryLabel.Size = UDim2.fromScale(1, 1)
	salaryLabel.BackgroundTransparency = 1
	salaryLabel.Font = F.Medium
	salaryLabel.TextSize = 11
	salaryLabel.TextColor3 = C.GreenDark
	salaryLabel.Text = UI.formatMoney(job.salary) .. "/yr"
	salaryLabel.ZIndex = 85
	salaryLabel.Parent = salaryBadge
	
	-- Requirements
	local reqText = ""
	if not meetsAge then
		reqText = "Age " .. job.minAge .. "+"
	elseif not meetsEdu then
		reqText = "Need " .. eduNeeded
	else
		reqText = "Age " .. job.minAge .. "+"
	end
	
	local reqLabel = Instance.new("TextLabel")
	reqLabel.Size = UDim2.new(0.4, 0, 0, 18)
	reqLabel.Position = UDim2.new(0, 80, 0, 62)
	reqLabel.BackgroundTransparency = 1
	reqLabel.Font = F.Body
	reqLabel.TextSize = 11
	reqLabel.TextColor3 = canApply and C.Gray400 or C.Red
	reqLabel.TextXAlignment = Enum.TextXAlignment.Left
	reqLabel.Text = reqText
	reqLabel.ZIndex = 84
	reqLabel.Parent = card
	
	-- Apply button
	local applyBtn = Instance.new("TextButton")
	applyBtn.Size = UDim2.new(0, 72, 0, 44)
	applyBtn.AnchorPoint = Vector2.new(1, 0.5)
	applyBtn.Position = UDim2.new(1, -12, 0.5, 0)
	applyBtn.BackgroundColor3 = canApply and C.Blue or C.Gray300
	applyBtn.Font = F.Button
	applyBtn.TextSize = 14
	applyBtn.TextColor3 = canApply and C.White or C.Gray500
	applyBtn.Text = canApply and "Apply" or "Locked"
	applyBtn.AutoButtonColor = false
	applyBtn.ZIndex = 84
	applyBtn.Parent = card
	UI.corner(applyBtn, 12)
	
	if canApply then
		applyBtn.MouseEnter:Connect(function()
			UI.tween(applyBtn, TweenInfo.new(0.12), { BackgroundColor3 = C.BlueDark })
			UI.tween(card, TweenInfo.new(0.12), { BackgroundColor3 = C.BluePale:Lerp(C.White, 0.7) })
		end)
		applyBtn.MouseLeave:Connect(function()
			UI.tween(applyBtn, TweenInfo.new(0.12), { BackgroundColor3 = C.Blue })
			UI.tween(card, TweenInfo.new(0.12), { BackgroundColor3 = C.White })
		end)
		applyBtn.MouseButton1Click:Connect(function()
			self:applyForJob(job.id)
		end)
	end
end

function OccupationScreen:populateEducation()
	self:updateInfoBar()
	
	-- Clear content
	for _, child in ipairs(self.contentScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	
	local age = self:getAge()
	local money = self:getMoney()
	local eduLevel = self:getEducationLevel()
	local enrolled = self:isEnrolled()
	
	-- Auto education info
	local autoSection = Instance.new("Frame")
	autoSection.Name = "AutoEducation"
	autoSection.Size = UDim2.new(1, 0, 0, 85)
	autoSection.BackgroundColor3 = C.PurplePale
	autoSection.LayoutOrder = 0
	autoSection.ZIndex = 82
	autoSection.Parent = self.contentScroll
	UI.corner(autoSection, 18)
	UI.stroke(autoSection, 1, 0.7, C.Purple)
	
	local autoIcon = Instance.new("TextLabel")
	autoIcon.Size = UDim2.new(0, 55, 0, 55)
	autoIcon.Position = UDim2.new(0, 16, 0.5, -27.5)
	autoIcon.BackgroundTransparency = 1
	autoIcon.Font = F.Body
	autoIcon.TextSize = 32
	autoIcon.Text = "📖"
	autoIcon.ZIndex = 83
	autoIcon.Parent = autoSection
	
	local autoTitle = Instance.new("TextLabel")
	autoTitle.Size = UDim2.new(0.7, 0, 0, 24)
	autoTitle.Position = UDim2.new(0, 80, 0, 16)
	autoTitle.BackgroundTransparency = 1
	autoTitle.Font = F.Title
	autoTitle.TextSize = 15
	autoTitle.TextColor3 = C.PurpleDark
	autoTitle.TextXAlignment = Enum.TextXAlignment.Left
	autoTitle.Text = "Basic Education"
	autoTitle.ZIndex = 83
	autoTitle.Parent = autoSection
	
	local autoDesc = Instance.new("TextLabel")
	autoDesc.Size = UDim2.new(0.8, 0, 0, 36)
	autoDesc.Position = UDim2.new(0, 80, 0, 42)
	autoDesc.BackgroundTransparency = 1
	autoDesc.Font = F.Body
	autoDesc.TextSize = 12
	autoDesc.TextColor3 = C.Purple
	autoDesc.TextXAlignment = Enum.TextXAlignment.Left
	autoDesc.TextWrapped = true
	autoDesc.Text = "Elementary, Middle, and High School enroll automatically based on your age."
	autoDesc.ZIndex = 83
	autoDesc.Parent = autoSection
	
	-- Current education status
	local statusSection = Instance.new("Frame")
	statusSection.Name = "StatusSection"
	statusSection.Size = UDim2.new(1, 0, 0, 70)
	statusSection.BackgroundColor3 = C.White
	statusSection.LayoutOrder = 1
	statusSection.ZIndex = 82
	statusSection.Parent = self.contentScroll
	UI.corner(statusSection, 16)
	UI.stroke(statusSection, 1, 0.88, C.Gray200)
	
	local statusLabel = Instance.new("TextLabel")
	statusLabel.Size = UDim2.new(0.5, 0, 0, 24)
	statusLabel.Position = UDim2.new(0, 18, 0, 14)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Font = F.Title
	statusLabel.TextSize = 14
	statusLabel.TextColor3 = C.Gray700
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.Text = "Current Education Level"
	statusLabel.ZIndex = 83
	statusLabel.Parent = statusSection
	
	local eduDisplay = eduLevel:gsub("_", " "):gsub("^%l", string.upper)
	if eduDisplay == "High school" then eduDisplay = "High School Graduate" end
	
	local levelBadge = Instance.new("Frame")
	levelBadge.Size = UDim2.new(0, 160, 0, 28)
	levelBadge.Position = UDim2.new(0, 18, 0, 38)
	levelBadge.BackgroundColor3 = C.Purple
	levelBadge.ZIndex = 83
	levelBadge.Parent = statusSection
	UI.pill(levelBadge)
	
	local levelLabel = Instance.new("TextLabel")
	levelLabel.Size = UDim2.fromScale(1, 1)
	levelLabel.BackgroundTransparency = 1
	levelLabel.Font = F.Button
	levelLabel.TextSize = 12
	levelLabel.TextColor3 = C.White
	levelLabel.Text = eduDisplay
	levelLabel.ZIndex = 84
	levelLabel.Parent = levelBadge
	
	if enrolled then
		local enrolledBadge = Instance.new("Frame")
		enrolledBadge.Size = UDim2.new(0, 85, 0, 28)
		enrolledBadge.AnchorPoint = Vector2.new(1, 0.5)
		enrolledBadge.Position = UDim2.new(1, -18, 0.5, 0)
		enrolledBadge.BackgroundColor3 = C.Amber
		enrolledBadge.ZIndex = 83
		enrolledBadge.Parent = statusSection
		UI.pill(enrolledBadge)
		
		local enrolledLabel = Instance.new("TextLabel")
		enrolledLabel.Size = UDim2.fromScale(1, 1)
		enrolledLabel.BackgroundTransparency = 1
		enrolledLabel.Font = F.Medium
		enrolledLabel.TextSize = 11
		enrolledLabel.TextColor3 = C.White
		enrolledLabel.Text = "Enrolled"
		enrolledLabel.ZIndex = 84
		enrolledLabel.Parent = enrolledBadge
	end
	
	-- Higher education section
	local section = Instance.new("Frame")
	section.Name = "HigherEducation"
	section.Size = UDim2.new(1, 0, 0, 0)
	section.AutomaticSize = Enum.AutomaticSize.Y
	section.BackgroundColor3 = C.White
	section.LayoutOrder = 2
	section.ZIndex = 82
	section.Parent = self.contentScroll
	UI.corner(section, 18)
	UI.stroke(section, 1, 0.88, C.Gray200)
	UI.pad(section, 14, 14, 14, 16)
	
	local sectionLayout = Instance.new("UIListLayout")
	sectionLayout.Padding = UDim.new(0, 10)
	sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
	sectionLayout.Parent = section
	
	-- Section header
	local headerFrame = Instance.new("Frame")
	headerFrame.Name = "Header"
	headerFrame.Size = UDim2.new(1, 0, 0, 36)
	headerFrame.BackgroundTransparency = 1
	headerFrame.LayoutOrder = 0
	headerFrame.ZIndex = 83
	headerFrame.Parent = section
	
	local badge = Instance.new("Frame")
	badge.Size = UDim2.new(0, 145, 0, 32)
	badge.BackgroundColor3 = C.Purple
	badge.ZIndex = 84
	badge.Parent = headerFrame
	UI.pill(badge)
	
	local badgeLabel = Instance.new("TextLabel")
	badgeLabel.Size = UDim2.fromScale(1, 1)
	badgeLabel.BackgroundTransparency = 1
	badgeLabel.Font = F.Button
	badgeLabel.TextSize = 14
	badgeLabel.TextColor3 = C.White
	badgeLabel.Text = "Higher Education"
	badgeLabel.ZIndex = 85
	badgeLabel.Parent = badge
	
	-- Add education options
	local order = 1
	for _, edu in ipairs(Education) do
		self:createEducationCard(section, edu, order, age, money, eduLevel, enrolled)
		order = order + 1
	end
end

function OccupationScreen:createEducationCard(parent, edu, order, age, money, eduLevel, enrolled)
	local meetsAge = age >= edu.minAge
	local meetsMoney = money >= edu.cost
	local meetsReq = true
	
	-- Check prerequisite
	if edu.requirement then
		local eduRanks = { none = 0, high_school = 1, community_college = 2, university = 3, graduate_school = 4, law_school = 4, medical_school = 4, mba = 4 }
		local playerRank = eduRanks[eduLevel] or 1
		local reqRank = eduRanks[edu.requirement] or 0
		meetsReq = playerRank >= reqRank
	end
	
	local canEnroll = meetsAge and meetsMoney and meetsReq and not enrolled
	
	local card = Instance.new("Frame")
	card.Name = edu.id
	card.Size = UDim2.new(1, 0, 0, 95)
	card.BackgroundColor3 = C.White
	card.LayoutOrder = order
	card.ZIndex = 83
	card.Parent = parent
	UI.corner(card, 14)
	UI.stroke(card, 1, canEnroll and 0.7 or 0.88, canEnroll and C.Purple or C.Gray200)
	
	-- Icon
	local iconFrame = Instance.new("Frame")
	iconFrame.Size = UDim2.new(0, 58, 0, 58)
	iconFrame.Position = UDim2.new(0, 12, 0.5, -29)
	iconFrame.BackgroundColor3 = canEnroll and C.PurplePale or C.Gray100
	iconFrame.ZIndex = 84
	iconFrame.Parent = card
	UI.corner(iconFrame, 14)
	
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.fromScale(1, 1)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Font = F.Body
	iconLabel.TextSize = 30
	iconLabel.Text = edu.emoji
	iconLabel.TextTransparency = canEnroll and 0 or 0.3
	iconLabel.ZIndex = 85
	iconLabel.Parent = iconFrame
	
	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0.5, 0, 0, 22)
	titleLabel.Position = UDim2.new(0, 84, 0, 12)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = F.Title
	titleLabel.TextSize = 15
	titleLabel.TextColor3 = canEnroll and C.Gray900 or C.Gray500
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = edu.name
	titleLabel.ZIndex = 84
	titleLabel.Parent = card
	
	-- Cost badge
	local costBadge = Instance.new("Frame")
	costBadge.Size = UDim2.new(0, 80, 0, 24)
	costBadge.Position = UDim2.new(0, 84, 0, 36)
	costBadge.BackgroundColor3 = meetsMoney and C.GreenPale or C.RedPale
	costBadge.ZIndex = 84
	costBadge.Parent = card
	UI.pill(costBadge)
	
	local costLabel = Instance.new("TextLabel")
	costLabel.Size = UDim2.fromScale(1, 1)
	costLabel.BackgroundTransparency = 1
	costLabel.Font = F.Medium
	costLabel.TextSize = 11
	costLabel.TextColor3 = meetsMoney and C.GreenDark or C.RedDark
	costLabel.Text = UI.formatMoney(edu.cost)
	costLabel.ZIndex = 85
	costLabel.Parent = costBadge
	
	-- Duration badge
	local durBadge = Instance.new("Frame")
	durBadge.Size = UDim2.new(0, 65, 0, 24)
	durBadge.Position = UDim2.new(0, 170, 0, 36)
	durBadge.BackgroundColor3 = C.BluePale
	durBadge.ZIndex = 84
	durBadge.Parent = card
	UI.pill(durBadge)
	
	local durLabel = Instance.new("TextLabel")
	durLabel.Size = UDim2.fromScale(1, 1)
	durLabel.BackgroundTransparency = 1
	durLabel.Font = F.Medium
	durLabel.TextSize = 11
	durLabel.TextColor3 = C.BlueDark
	durLabel.Text = edu.duration .. " years"
	durLabel.ZIndex = 85
	durLabel.Parent = durBadge
	
	-- Requirement text
	local reqText = ""
	if not meetsAge then
		reqText = "Age " .. edu.minAge .. "+"
	elseif not meetsReq then
		reqText = "Need " .. (edu.requirement or ""):gsub("_", " ")
	elseif enrolled then
		reqText = "Already enrolled"
	else
		reqText = "Age " .. edu.minAge .. "+"
	end
	
	local reqLabel = Instance.new("TextLabel")
	reqLabel.Size = UDim2.new(0.4, 0, 0, 18)
	reqLabel.Position = UDim2.new(0, 84, 0, 64)
	reqLabel.BackgroundTransparency = 1
	reqLabel.Font = F.Body
	reqLabel.TextSize = 11
	reqLabel.TextColor3 = canEnroll and C.Gray400 or C.Red
	reqLabel.TextXAlignment = Enum.TextXAlignment.Left
	reqLabel.Text = reqText
	reqLabel.ZIndex = 84
	reqLabel.Parent = card
	
	-- Enroll button
	local enrollBtn = Instance.new("TextButton")
	enrollBtn.Size = UDim2.new(0, 72, 0, 46)
	enrollBtn.AnchorPoint = Vector2.new(1, 0.5)
	enrollBtn.Position = UDim2.new(1, -12, 0.5, 0)
	enrollBtn.BackgroundColor3 = canEnroll and C.Purple or C.Gray300
	enrollBtn.Font = F.Button
	enrollBtn.TextSize = 14
	enrollBtn.TextColor3 = canEnroll and C.White or C.Gray500
	enrollBtn.Text = canEnroll and "Enroll" or "Locked"
	enrollBtn.AutoButtonColor = false
	enrollBtn.ZIndex = 84
	enrollBtn.Parent = card
	UI.corner(enrollBtn, 12)
	
	if canEnroll then
		enrollBtn.MouseEnter:Connect(function()
			UI.tween(enrollBtn, TweenInfo.new(0.12), { BackgroundColor3 = C.PurpleDark })
			UI.tween(card, TweenInfo.new(0.12), { BackgroundColor3 = C.PurplePale:Lerp(C.White, 0.7) })
		end)
		enrollBtn.MouseLeave:Connect(function()
			UI.tween(enrollBtn, TweenInfo.new(0.12), { BackgroundColor3 = C.Purple })
			UI.tween(card, TweenInfo.new(0.12), { BackgroundColor3 = C.White })
		end)
		enrollBtn.MouseButton1Click:Connect(function()
			self:enrollEducation(edu.id)
		end)
	end
end

function OccupationScreen:createResultModal()
	self.resultModal = UI.createModalCard(self.screenGui, {
		name = "OccupationResult",
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

function OccupationScreen:applyForJob(jobId)
	log("=== APPLYING FOR JOB ===")
	log("Job ID:", jobId)
	log("Player Age:", self:getAge(), "Money:", self:getMoney())
	
	if not ApplyForJob then
		logWarn("ApplyForJob remote not available!")
		self:showResult(false, "Server not available. Please try again later.", "X")
		return
	end
	
	log("Invoking server ApplyForJob...")
	local result = ApplyForJob:InvokeServer(jobId)
	log("Server response:", result and "received" or "nil")
	
	if result then
		log("Success:", result.success, "Message:", result.message)
		self:showResult(result.success, result.message, result.success and "Hired!" or "Rejected")
	else
		logWarn("Server returned nil!")
		self:showResult(false, "Server error. Please try again.", "X")
	end
end

function OccupationScreen:quitJob()
	log("=== QUITTING JOB ===")
	log("Current job:", self:getCurrentJob() or "None")
	
	if not QuitJob then
		logWarn("QuitJob remote not available!")
		self:showResult(false, "Server not available.", "X")
		return
	end
	
	log("Invoking server QuitJob...")
	local result = QuitJob:InvokeServer()
	log("Server response:", result and "received" or "nil")
	
	if result then
		log("Success:", result.success, "Message:", result.message)
		self:showResult(result.success, result.message, result.success and "Done" or "Error")
	else
		logWarn("Server returned nil!")
		self:showResult(false, "Server error.", "X")
	end
end

function OccupationScreen:enrollEducation(eduId)
	log("=== ENROLLING IN EDUCATION ===")
	log("Education ID:", eduId)
	log("Player Age:", self:getAge(), "Money:", self:getMoney(), "Current Edu:", self:getEducationLevel())
	
	if not EnrollEducation then
		logWarn("EnrollEducation remote not available!")
		self:showResult(false, "Server not available.", "X")
		return
	end
	
	log("Invoking server EnrollEducation...")
	local result = EnrollEducation:InvokeServer(eduId)
	log("Server response:", result and "received" or "nil")
	
	if result then
		log("Success:", result.success, "Message:", result.message)
		self:showResult(result.success, result.message, result.success and "Enrolled!" or "Failed")
	else
		logWarn("Server returned nil!")
		self:showResult(false, "Server error.", "X")
	end
end

function OccupationScreen:showResult(success, message, emoji)
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

function OccupationScreen:show()
	log("=== SHOWING OccupationScreen ===")
	log("Current state - Age:", self:getAge(), "Money:", self:getMoney(), "Job:", self:getCurrentJob() or "None")
	self:updateInfoBar()
	self:switchTab(self.currentTab)
	UI.slideInScreen(self.overlay, "right")
	self.isVisible = true
	log("✅ OccupationScreen is now visible")
end

function OccupationScreen:hide()
	log("=== HIDING OccupationScreen ===")
	UI.slideOutScreen(self.overlay, "right", function()
		self.resultModal.overlay.Visible = false
		log("✅ OccupationScreen hidden, modal cleaned up")
	end)
	self.isVisible = false
end

return OccupationScreen
