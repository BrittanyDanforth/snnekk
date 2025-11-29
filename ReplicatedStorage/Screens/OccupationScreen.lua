-- OccupationScreen.lua
-- Premium AAA-quality Occupation & Education screen

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OccupationScreen = {}
OccupationScreen.__index = OccupationScreen

local remotesFolder = ReplicatedStorage:WaitForChild("LifeRemotes", 10)
local ApplyJob = remotesFolder and remotesFolder:FindFirstChild("ApplyJob")
local EnrollEducation = remotesFolder and remotesFolder:FindFirstChild("EnrollEducation")

-- Premium Colors
local C = {
	Navy = Color3.fromRGB(30, 58, 138),
	NavyDark = Color3.fromRGB(23, 37, 84),
	NavyPale = Color3.fromRGB(224, 231, 255),
	NavyLight = Color3.fromRGB(199, 210, 254),
	Blue = Color3.fromRGB(37, 99, 235),
	BlueDark = Color3.fromRGB(29, 78, 216),
	BluePale = Color3.fromRGB(219, 234, 254),
	Green = Color3.fromRGB(34, 197, 94),
	GreenDark = Color3.fromRGB(22, 163, 74),
	GreenPale = Color3.fromRGB(220, 252, 231),
	Purple = Color3.fromRGB(147, 51, 234),
	PurpleDark = Color3.fromRGB(124, 58, 237),
	PurplePale = Color3.fromRGB(243, 232, 255),
	Amber = Color3.fromRGB(245, 158, 11),
	AmberDark = Color3.fromRGB(217, 119, 6),
	AmberPale = Color3.fromRGB(254, 243, 199),
	Red = Color3.fromRGB(239, 68, 68),
	RedDark = Color3.fromRGB(220, 38, 38),
	RedPale = Color3.fromRGB(254, 226, 226),
	White = Color3.fromRGB(255, 255, 255),
	Gray50 = Color3.fromRGB(249, 250, 251),
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
	Bg = Color3.fromRGB(248, 250, 252),
}

local F = { Title = Enum.Font.GothamBold, Body = Enum.Font.Gotham, Medium = Enum.Font.GothamMedium, Button = Enum.Font.GothamBold }

-- Job Data
local Jobs = {
	{ id = "fastfood", name = "Fast Food Worker", emoji = "🍔", salary = 800, minAge = 14, requirement = nil },
	{ id = "retail", name = "Retail Associate", emoji = "🛒", salary = 1200, minAge = 16, requirement = nil },
	{ id = "waiter", name = "Waiter/Waitress", emoji = "🍽️", salary = 1400, minAge = 16, requirement = nil },
	{ id = "lifeguard", name = "Lifeguard", emoji = "🏊", salary = 1600, minAge = 16, requirement = nil },
	{ id = "tutor", name = "Tutor", emoji = "📚", salary = 2000, minAge = 16, requirement = "High School" },
	{ id = "office", name = "Office Assistant", emoji = "💼", salary = 2500, minAge = 18, requirement = "High School" },
	{ id = "developer", name = "Software Developer", emoji = "💻", salary = 8000, minAge = 22, requirement = "College" },
	{ id = "doctor", name = "Doctor", emoji = "👨‍⚕️", salary = 15000, minAge = 28, requirement = "Medical School" },
	{ id = "lawyer", name = "Lawyer", emoji = "⚖️", salary = 12000, minAge = 26, requirement = "Law School" },
}

local Education = {
	{ id = "elementary", name = "Elementary School", emoji = "🏫", cost = 0, minAge = 5, maxAge = 11, duration = "6 years" },
	{ id = "middle", name = "Middle School", emoji = "📖", cost = 0, minAge = 11, maxAge = 14, duration = "3 years" },
	{ id = "high", name = "High School", emoji = "🎓", cost = 0, minAge = 14, maxAge = 18, duration = "4 years" },
	{ id = "college", name = "College", emoji = "🎓", cost = 50000, minAge = 18, maxAge = 30, duration = "4 years" },
	{ id = "medical", name = "Medical School", emoji = "🏥", cost = 200000, minAge = 22, maxAge = 35, duration = "4 years", prereq = "College" },
	{ id = "law", name = "Law School", emoji = "⚖️", cost = 150000, minAge = 22, maxAge = 35, duration = "3 years", prereq = "College" },
	{ id = "business", name = "Business School (MBA)", emoji = "📊", cost = 120000, minAge = 22, maxAge = 40, duration = "2 years", prereq = "College" },
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
	self:createResultModal()
	return self
end

function OccupationScreen:updateState(newState)
	if newState then
		self.playerState = newState
	end
end

function OccupationScreen:getAge()
	local state = self.playerState
	if not state then return 0 end
	-- Check both direct Age and nested Stats.Age
	return state.Age or (state.Stats and state.Stats.Age) or 0
end

function OccupationScreen:getMoney()
	local state = self.playerState
	if not state then return 0 end
	return state.Money or (state.Stats and state.Stats.Money) or 0
end

function OccupationScreen:getEducation()
	local state = self.playerState
	if not state then return "None" end
	-- Check Education directly, in Career, or in Flags
	if state.Education then
		if type(state.Education) == "table" then
			return state.Education.level or state.Education.schoolLevel or "None"
		end
		return state.Education
	end
	if state.Career and state.Career.education then return state.Career.education end
	-- Check flags for education level
	local flags = state.Flags or {}
	if flags.college_graduate or flags.has_degree then return "College" end
	if flags.high_school_graduate then return "High School" end
	if flags.in_high_school then return "High School" end
	if flags.in_middle_school then return "Middle School" end
	return "None"
end

function OccupationScreen:getCurrentJob()
	local state = self.playerState
	if not state then return nil end
	if state.Job then return state.Job end
	if state.Career and state.Career.jobTitle then return state.Career.jobTitle end
	return nil
end

function OccupationScreen:createUI()
	self.overlay = Instance.new("Frame")
	self.overlay.Name = "OccupationOverlay"
	self.overlay.Size = UDim2.fromScale(1, 1)
	self.overlay.BackgroundColor3 = C.Bg
	self.overlay.Visible = false
	self.overlay.ZIndex = 80
	self.overlay.Parent = self.screenGui
	
	-- Header (offset down for Roblox UI)
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, -16, 0, 60)
	header.Position = UDim2.new(0, 8, 0, 44)
	header.BackgroundColor3 = C.Navy
	header.ZIndex = 85
	header.Parent = self.overlay
	corner(header, 18)
	
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
	title.Text = "💼 Career & Education"
	title.ZIndex = 86
	title.Parent = header
	
	-- Close button (clean X)
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 40, 0, 40)
	closeBtn.AnchorPoint = Vector2.new(1, 0.5)
	closeBtn.Position = UDim2.new(1, -10, 0.5, 0)
	closeBtn.BackgroundColor3 = C.White
	closeBtn.BackgroundTransparency = 0.1
	closeBtn.Font = F.Title
	closeBtn.TextSize = 18
	closeBtn.TextColor3 = C.NavyDark
	closeBtn.Text = "X"
	closeBtn.AutoButtonColor = false
	closeBtn.ZIndex = 86
	closeBtn.Parent = header
	corner(closeBtn, 20)
	
	closeBtn.MouseButton1Click:Connect(function() self:hide() end)
	closeBtn.MouseEnter:Connect(function() tween(closeBtn, TweenInfo.new(0.1), { BackgroundTransparency = 0 }) end)
	closeBtn.MouseLeave:Connect(function() tween(closeBtn, TweenInfo.new(0.1), { BackgroundTransparency = 0.1 }) end)
	
	-- Info bar (adjusted for header offset)
	local contentTopOffset = 44 + 60 + 8 -- header offset + height + spacing
	
	self.infoBar = Instance.new("Frame")
	self.infoBar.Size = UDim2.new(1, -20, 0, 48)
	self.infoBar.Position = UDim2.new(0, 10, 0, contentTopOffset)
	self.infoBar.BackgroundColor3 = C.White
	self.infoBar.ZIndex = 84
	self.infoBar.Parent = self.overlay
	corner(self.infoBar, 14)
	stroke(self.infoBar, 1, 0.92, C.Gray200)
	
	local infoLayout = Instance.new("UIListLayout")
	infoLayout.FillDirection = Enum.FillDirection.Horizontal
	infoLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	infoLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	infoLayout.Padding = UDim.new(0, 10)
	infoLayout.Parent = self.infoBar
	
	self.ageChip = self:createInfoChip(self.infoBar, "👤", "Age 0", C.BluePale, C.Blue, 1)
	self.moneyChip = self:createInfoChip(self.infoBar, "💵", "$0", C.GreenPale, C.GreenDark, 2)
	self.eduChip = self:createInfoChip(self.infoBar, "🎓", "None", C.PurplePale, C.PurpleDark, 3)
	
	-- Tab bar
	local tabBar = Instance.new("Frame")
	tabBar.Size = UDim2.new(1, -20, 0, 50)
	tabBar.Position = UDim2.new(0, 10, 0, contentTopOffset + 56)
	tabBar.BackgroundColor3 = C.Gray100
	tabBar.ZIndex = 84
	tabBar.Parent = self.overlay
	corner(tabBar, 14)
	
	pad(tabBar, 5, 5, 5, 5)
	
	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	tabLayout.Padding = UDim.new(0, 6)
	tabLayout.Parent = tabBar
	
	self.tabBtns = {}
	local tabs = { { id = "jobs", text = "💼 Jobs", color = C.Navy }, { id = "education", text = "🎓 Education", color = C.Purple } }
	
	for i, tab in ipairs(tabs) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0.47, 0, 1, 0)
		btn.BackgroundColor3 = i == 1 and tab.color or C.White
		btn.Font = F.Button
		btn.TextSize = 14
		btn.TextColor3 = i == 1 and C.White or C.Gray600
		btn.Text = tab.text
		btn.AutoButtonColor = false
		btn.LayoutOrder = i
		btn.ZIndex = 85
		btn.Parent = tabBar
		corner(btn, 10)
		
		self.tabBtns[tab.id] = { btn = btn, color = tab.color }
		btn.MouseButton1Click:Connect(function() self:switchTab(tab.id) end)
	end
	
	-- Content
	local scrollTop = contentTopOffset + 56 + 58 -- info bar + tab bar + spacing
	self.contentScroll = Instance.new("ScrollingFrame")
	self.contentScroll.Size = UDim2.new(1, -20, 1, -(scrollTop + 12))
	self.contentScroll.Position = UDim2.new(0, 10, 0, scrollTop)
	self.contentScroll.BackgroundTransparency = 1
	self.contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	self.contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	self.contentScroll.ScrollBarThickness = 4
	self.contentScroll.ScrollBarImageColor3 = C.Gray300
	self.contentScroll.ZIndex = 81
	self.contentScroll.Parent = self.overlay
	
	self.contentLayout = Instance.new("UIListLayout")
	self.contentLayout.Padding = UDim.new(0, 12)
	self.contentLayout.Parent = self.contentScroll
	
	self:populateJobs()
end

function OccupationScreen:createInfoChip(parent, icon, text, bgColor, textColor, order)
	local chip = Instance.new("Frame")
	chip.Size = UDim2.new(0, 90, 0, 36)
	chip.BackgroundColor3 = bgColor
	chip.LayoutOrder = order
	chip.ZIndex = 85
	chip.Parent = parent
	corner(chip, 10)
	
	local iconLbl = Instance.new("TextLabel")
	iconLbl.Size = UDim2.new(0, 22, 1, 0)
	iconLbl.Position = UDim2.new(0, 6, 0, 0)
	iconLbl.BackgroundTransparency = 1
	iconLbl.Font = F.Body
	iconLbl.TextSize = 14
	iconLbl.Text = icon
	iconLbl.ZIndex = 86
	iconLbl.Parent = chip
	
	local textLbl = Instance.new("TextLabel")
	textLbl.Name = "Text"
	textLbl.Size = UDim2.new(1, -30, 1, 0)
	textLbl.Position = UDim2.new(0, 26, 0, 0)
	textLbl.BackgroundTransparency = 1
	textLbl.Font = F.Button
	textLbl.TextSize = 11
	textLbl.TextColor3 = textColor
	textLbl.TextXAlignment = Enum.TextXAlignment.Left
	textLbl.Text = text
	textLbl.ZIndex = 86
	textLbl.Parent = chip
	
	return chip
end

function OccupationScreen:updateInfoBar()
	local ageText = self.ageChip:FindFirstChild("Text")
	local moneyText = self.moneyChip:FindFirstChild("Text")
	local eduText = self.eduChip:FindFirstChild("Text")
	
	if ageText then ageText.Text = "Age " .. self:getAge() end
	if moneyText then moneyText.Text = formatMoney(self:getMoney()) end
	if eduText then eduText.Text = self:getEducation() or "None" end
end

function OccupationScreen:switchTab(tabId)
	self.currentTab = tabId
	
	for id, data in pairs(self.tabBtns) do
		local isActive = id == tabId
		tween(data.btn, TweenInfo.new(0.15), {
			BackgroundColor3 = isActive and data.color or C.White,
			TextColor3 = isActive and C.White or C.Gray600
		})
	end
	
	for _, child in ipairs(self.contentScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	
	if tabId == "jobs" then self:populateJobs() else self:populateEducation() end
end

function OccupationScreen:createJobCard(parent, job, order)
	local age = self:getAge()
	local edu = self:getEducation()
	local currentJob = self:getCurrentJob()
	
	local meetsAge = age >= job.minAge
	local meetsEdu = not job.requirement or edu == job.requirement or (edu == "College" and job.requirement == "High School")
	local canApply = meetsAge and meetsEdu and currentJob ~= job.id
	local hasJob = currentJob == job.id
	
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 94)
	card.BackgroundColor3 = C.White
	card.LayoutOrder = order
	card.ZIndex = 82
	card.Parent = parent
	corner(card, 16)
	stroke(card, 1, hasJob and 0.5 or 0.92, hasJob and C.Green or C.Gray200)
	
	-- Icon
	local iconFrame = Instance.new("Frame")
	iconFrame.Size = UDim2.new(0, 58, 0, 58)
	iconFrame.Position = UDim2.new(0, 14, 0.5, -29)
	iconFrame.BackgroundColor3 = hasJob and C.GreenPale or C.NavyPale
	iconFrame.ZIndex = 83
	iconFrame.Parent = card
	corner(iconFrame, 16)
	
	local iconLbl = Instance.new("TextLabel")
	iconLbl.Size = UDim2.fromScale(1, 1)
	iconLbl.BackgroundTransparency = 1
	iconLbl.Font = F.Body
	iconLbl.TextSize = 30
	iconLbl.Text = job.emoji
	iconLbl.ZIndex = 84
	iconLbl.Parent = iconFrame
	
	-- Current job badge
	if hasJob then
		local currentBadge = Instance.new("Frame")
		currentBadge.Size = UDim2.new(0, 70, 0, 20)
		currentBadge.Position = UDim2.new(0, 82, 0, 8)
		currentBadge.BackgroundColor3 = C.Green
		currentBadge.ZIndex = 84
		currentBadge.Parent = card
		pill(currentBadge)
		
		local badgeLbl = Instance.new("TextLabel")
		badgeLbl.Size = UDim2.fromScale(1, 1)
		badgeLbl.BackgroundTransparency = 1
		badgeLbl.Font = F.Button
		badgeLbl.TextSize = 10
		badgeLbl.TextColor3 = C.White
		badgeLbl.Text = "CURRENT"
		badgeLbl.ZIndex = 85
		badgeLbl.Parent = currentBadge
	end
	
	-- Name
	local nameLbl = Instance.new("TextLabel")
	nameLbl.Size = UDim2.new(0.5, 0, 0, 22)
	nameLbl.Position = UDim2.new(0, 82, 0, hasJob and 30 or 12)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Font = F.Title
	nameLbl.TextSize = 15
	nameLbl.TextColor3 = C.Gray900
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.Text = job.name
	nameLbl.ZIndex = 83
	nameLbl.Parent = card
	
	-- Salary badge
	local salaryBadge = Instance.new("Frame")
	salaryBadge.Size = UDim2.new(0, 80, 0, 24)
	salaryBadge.Position = UDim2.new(0, 82, 0, hasJob and 54 or 36)
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
	salaryLbl.Text = formatMoney(job.salary) .. "/year"
	salaryLbl.ZIndex = 84
	salaryLbl.Parent = salaryBadge
	
	-- Requirements
	if not hasJob then
		local reqText = "Age " .. job.minAge .. "+"
		if job.requirement then reqText = reqText .. " • " .. job.requirement end
		
		local reqLbl = Instance.new("TextLabel")
		reqLbl.Size = UDim2.new(0.5, 0, 0, 18)
		reqLbl.Position = UDim2.new(0, 82, 0, 62)
		reqLbl.BackgroundTransparency = 1
		reqLbl.Font = F.Body
		reqLbl.TextSize = 11
		reqLbl.TextColor3 = canApply and C.Gray500 or C.Red
		reqLbl.TextXAlignment = Enum.TextXAlignment.Left
		reqLbl.Text = reqText
		reqLbl.ZIndex = 83
		reqLbl.Parent = card
	end
	
	-- Apply button
	if not hasJob then
		local applyBtn = Instance.new("TextButton")
		applyBtn.Size = UDim2.new(0, 72, 0, 42)
		applyBtn.AnchorPoint = Vector2.new(1, 0.5)
		applyBtn.Position = UDim2.new(1, -14, 0.5, 0)
		applyBtn.BackgroundColor3 = canApply and C.Navy or C.Gray300
		applyBtn.Font = F.Button
		applyBtn.TextSize = 13
		applyBtn.TextColor3 = canApply and C.White or C.Gray500
		applyBtn.Text = canApply and "Apply" or (not meetsAge and "Age " .. job.minAge .. "+" or "Need Edu")
		applyBtn.AutoButtonColor = false
		applyBtn.ZIndex = 83
		applyBtn.Parent = card
		pill(applyBtn)
		
		if canApply then
			applyBtn.MouseEnter:Connect(function() 
				tween(applyBtn, TweenInfo.new(0.1), { Size = UDim2.new(0, 78, 0, 46) })
			end)
			applyBtn.MouseLeave:Connect(function() 
				tween(applyBtn, TweenInfo.new(0.1), { Size = UDim2.new(0, 72, 0, 42) })
			end)
			applyBtn.MouseButton1Click:Connect(function()
				self:applyJob(job)
			end)
		end
	end
end

function OccupationScreen:createEducationCard(parent, edu, order)
	local age = self:getAge()
	local money = self:getMoney()
	local currentEdu = self:getEducation()
	
	local meetsAge = age >= edu.minAge and age <= (edu.maxAge or 100)
	local canAfford = money >= (edu.cost or 0)
	local meetsPrereq = not edu.prereq or currentEdu == edu.prereq
	local alreadyHas = currentEdu == edu.name
	local canEnroll = meetsAge and canAfford and meetsPrereq and not alreadyHas
	
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 100)
	card.BackgroundColor3 = C.White
	card.LayoutOrder = order
	card.ZIndex = 82
	card.Parent = parent
	corner(card, 16)
	stroke(card, 1, alreadyHas and 0.5 or 0.92, alreadyHas and C.Purple or C.Gray200)
	
	-- Icon
	local iconFrame = Instance.new("Frame")
	iconFrame.Size = UDim2.new(0, 58, 0, 58)
	iconFrame.Position = UDim2.new(0, 14, 0.5, -29)
	iconFrame.BackgroundColor3 = alreadyHas and C.PurplePale or C.NavyPale
	iconFrame.ZIndex = 83
	iconFrame.Parent = card
	corner(iconFrame, 16)
	
	local iconLbl = Instance.new("TextLabel")
	iconLbl.Size = UDim2.fromScale(1, 1)
	iconLbl.BackgroundTransparency = 1
	iconLbl.Font = F.Body
	iconLbl.TextSize = 30
	iconLbl.Text = edu.emoji
	iconLbl.ZIndex = 84
	iconLbl.Parent = iconFrame
	
	-- Completed badge
	if alreadyHas then
		local doneBadge = Instance.new("Frame")
		doneBadge.Size = UDim2.new(0, 80, 0, 20)
		doneBadge.Position = UDim2.new(0, 82, 0, 8)
		doneBadge.BackgroundColor3 = C.Purple
		doneBadge.ZIndex = 84
		doneBadge.Parent = card
		pill(doneBadge)
		
		local badgeLbl = Instance.new("TextLabel")
		badgeLbl.Size = UDim2.fromScale(1, 1)
		badgeLbl.BackgroundTransparency = 1
		badgeLbl.Font = F.Button
		badgeLbl.TextSize = 10
		badgeLbl.TextColor3 = C.White
		badgeLbl.Text = "✓ COMPLETED"
		badgeLbl.ZIndex = 85
		badgeLbl.Parent = doneBadge
	end
	
	-- Name
	local nameLbl = Instance.new("TextLabel")
	nameLbl.Size = UDim2.new(0.5, 0, 0, 22)
	nameLbl.Position = UDim2.new(0, 82, 0, alreadyHas and 30 or 10)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Font = F.Title
	nameLbl.TextSize = 15
	nameLbl.TextColor3 = C.Gray900
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.Text = edu.name
	nameLbl.ZIndex = 83
	nameLbl.Parent = card
	
	-- Duration & cost badges row
	local badgeY = alreadyHas and 54 or 34
	
	local durationBadge = Instance.new("Frame")
	durationBadge.Size = UDim2.new(0, 65, 0, 22)
	durationBadge.Position = UDim2.new(0, 82, 0, badgeY)
	durationBadge.BackgroundColor3 = C.BluePale
	durationBadge.ZIndex = 83
	durationBadge.Parent = card
	pill(durationBadge)
	
	local durLbl = Instance.new("TextLabel")
	durLbl.Size = UDim2.fromScale(1, 1)
	durLbl.BackgroundTransparency = 1
	durLbl.Font = F.Medium
	durLbl.TextSize = 10
	durLbl.TextColor3 = C.BlueDark
	durLbl.Text = edu.duration
	durLbl.ZIndex = 84
	durLbl.Parent = durationBadge
	
	if edu.cost > 0 then
		local costBadge = Instance.new("Frame")
		costBadge.Size = UDim2.new(0, 70, 0, 22)
		costBadge.Position = UDim2.new(0, 152, 0, badgeY)
		costBadge.BackgroundColor3 = canAfford and C.AmberPale or C.RedPale
		costBadge.ZIndex = 83
		costBadge.Parent = card
		pill(costBadge)
		
		local costLbl = Instance.new("TextLabel")
		costLbl.Size = UDim2.fromScale(1, 1)
		costLbl.BackgroundTransparency = 1
		costLbl.Font = F.Medium
		costLbl.TextSize = 10
		costLbl.TextColor3 = canAfford and C.AmberDark or C.RedDark
		costLbl.Text = formatMoney(edu.cost)
		costLbl.ZIndex = 84
		costLbl.Parent = costBadge
	end
	
	-- Requirements (if not already enrolled)
	if not alreadyHas then
		local reqParts = {}
		table.insert(reqParts, "Age " .. edu.minAge .. "-" .. edu.maxAge)
		if edu.prereq then table.insert(reqParts, edu.prereq) end
		
		local reqLbl = Instance.new("TextLabel")
		reqLbl.Size = UDim2.new(0.5, 0, 0, 18)
		reqLbl.Position = UDim2.new(0, 82, 0, 60)
		reqLbl.BackgroundTransparency = 1
		reqLbl.Font = F.Body
		reqLbl.TextSize = 11
		reqLbl.TextColor3 = canEnroll and C.Gray500 or C.Red
		reqLbl.TextXAlignment = Enum.TextXAlignment.Left
		reqLbl.Text = table.concat(reqParts, " • ")
		reqLbl.ZIndex = 83
		reqLbl.Parent = card
	end
	
	-- Enroll button
	if not alreadyHas then
		local enrollBtn = Instance.new("TextButton")
		enrollBtn.Size = UDim2.new(0, 72, 0, 42)
		enrollBtn.AnchorPoint = Vector2.new(1, 0.5)
		enrollBtn.Position = UDim2.new(1, -14, 0.5, 0)
		enrollBtn.BackgroundColor3 = canEnroll and C.Purple or C.Gray300
		enrollBtn.Font = F.Button
		enrollBtn.TextSize = 13
		enrollBtn.TextColor3 = canEnroll and C.White or C.Gray500
		
		local btnText = "Enroll"
		if not meetsAge then btnText = "Age " .. edu.minAge .. "+"
		elseif not canAfford then btnText = "Need $"
		elseif not meetsPrereq then btnText = edu.prereq end
		enrollBtn.Text = canEnroll and "Enroll" or btnText
		enrollBtn.AutoButtonColor = false
		enrollBtn.ZIndex = 83
		enrollBtn.Parent = card
		pill(enrollBtn)
		
		if canEnroll then
			enrollBtn.MouseEnter:Connect(function() 
				tween(enrollBtn, TweenInfo.new(0.1), { Size = UDim2.new(0, 78, 0, 46) })
			end)
			enrollBtn.MouseLeave:Connect(function() 
				tween(enrollBtn, TweenInfo.new(0.1), { Size = UDim2.new(0, 72, 0, 42) })
			end)
			enrollBtn.MouseButton1Click:Connect(function()
				self:enrollEducation(edu)
			end)
		end
	end
end

function OccupationScreen:populateJobs()
	self:updateInfoBar()
	
	-- Debug: print state info when populating jobs
	local age = self:getAge()
	local edu = self:getEducation()
	print("[OccupationScreen] PopulateJobs - Player Age:", age, "Education:", edu)
	if self.playerState then
		print("[OccupationScreen] playerState.Age:", self.playerState.Age)
		print("[OccupationScreen] playerState keys:", table.concat(
			(function()
				local keys = {}
				for k, v in pairs(self.playerState) do
					table.insert(keys, tostring(k) .. "=" .. tostring(type(v) == "table" and "table" or v))
				end
				return keys
			end)(), ", "
		))
	else
		print("[OccupationScreen] playerState is nil!")
	end
	
	for i, job in ipairs(Jobs) do
		self:createJobCard(self.contentScroll, job, i)
	end
end

function OccupationScreen:populateEducation()
	self:updateInfoBar()
	for i, edu in ipairs(Education) do
		self:createEducationCard(self.contentScroll, edu, i)
	end
end

function OccupationScreen:applyJob(job)
	if not ApplyJob then
		self:showResult(false, "Server not available", "❌")
		return
	end
	
	local result = ApplyJob:InvokeServer(job.id)
	if result then
		self:showResult(result.success, result.message, result.success and "🎉" or "😔")
	else
		self:showResult(false, "Server error", "❌")
	end
end

function OccupationScreen:enrollEducation(edu)
	if not EnrollEducation then
		self:showResult(false, "Server not available", "❌")
		return
	end
	
	local result = EnrollEducation:InvokeServer(edu.id)
	if result then
		self:showResult(result.success, result.message, result.success and "🎓" or "😔")
	else
		self:showResult(false, "Server error", "❌")
	end
end

function OccupationScreen:createResultModal()
	self.resultOverlay = Instance.new("Frame")
	self.resultOverlay.Size = UDim2.fromScale(1, 1)
	self.resultOverlay.BackgroundColor3 = C.Black
	self.resultOverlay.BackgroundTransparency = 0.5
	self.resultOverlay.Visible = false
	self.resultOverlay.ZIndex = 96
	self.resultOverlay.Parent = self.screenGui
	
	-- Click outside to close
	local resultCloseArea = Instance.new("TextButton")
	resultCloseArea.Size = UDim2.fromScale(1, 1)
	resultCloseArea.BackgroundTransparency = 1
	resultCloseArea.Text = ""
	resultCloseArea.ZIndex = 96
	resultCloseArea.Parent = self.resultOverlay
	resultCloseArea.MouseButton1Click:Connect(function()
		self:hideResultModal()
	end)
	
	-- Outer colored shell (BitLife-style)
	self.resultShell = Instance.new("Frame")
	self.resultShell.Size = UDim2.new(0.88, 0, 0, 0)
	self.resultShell.AutomaticSize = Enum.AutomaticSize.Y
	self.resultShell.AnchorPoint = Vector2.new(0.5, 0.5)
	self.resultShell.Position = UDim2.fromScale(0.5, 0.5)
	self.resultShell.BackgroundColor3 = C.Navy
	self.resultShell.ZIndex = 97
	self.resultShell.Parent = self.resultOverlay
	corner(self.resultShell, 24)
	
	self.resultShellStroke = stroke(self.resultShell, 3, 0, C.NavyDark)
	pad(self.resultShell, 4, 4, 4, 4)
	
	-- Inner white card
	self.resultCard = Instance.new("Frame")
	self.resultCard.Size = UDim2.new(1, 0, 0, 0)
	self.resultCard.AutomaticSize = Enum.AutomaticSize.Y
	self.resultCard.BackgroundColor3 = C.White
	self.resultCard.ZIndex = 98
	self.resultCard.Parent = self.resultShell
	corner(self.resultCard, 20)
	
	local content = Instance.new("Frame")
	content.Size = UDim2.new(1, 0, 0, 0)
	content.AutomaticSize = Enum.AutomaticSize.Y
	content.BackgroundTransparency = 1
	content.ZIndex = 99
	content.Parent = self.resultCard
	
	pad(content, 24, 24, 28, 24)
	
	local layout = Instance.new("UIListLayout")
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Padding = UDim.new(0, 14)
	layout.Parent = content
	
	self.resultEmojiFrame = Instance.new("Frame")
	self.resultEmojiFrame.Size = UDim2.new(0, 72, 0, 72)
	self.resultEmojiFrame.BackgroundColor3 = C.GreenPale
	self.resultEmojiFrame.LayoutOrder = 1
	self.resultEmojiFrame.ZIndex = 100
	self.resultEmojiFrame.Parent = content
	corner(self.resultEmojiFrame, 36)
	
	self.resultEmoji = Instance.new("TextLabel")
	self.resultEmoji.Size = UDim2.fromScale(1, 1)
	self.resultEmoji.BackgroundTransparency = 1
	self.resultEmoji.Font = F.Body
	self.resultEmoji.TextSize = 38
	self.resultEmoji.Text = "🎉"
	self.resultEmoji.ZIndex = 101
	self.resultEmoji.Parent = self.resultEmojiFrame
	
	self.resultTitle = Instance.new("TextLabel")
	self.resultTitle.Size = UDim2.new(1, 0, 0, 28)
	self.resultTitle.BackgroundTransparency = 1
	self.resultTitle.Font = F.Title
	self.resultTitle.TextSize = 22
	self.resultTitle.TextColor3 = C.Gray900
	self.resultTitle.Text = "Success!"
	self.resultTitle.LayoutOrder = 2
	self.resultTitle.ZIndex = 100
	self.resultTitle.Parent = content
	
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
	self.resultMsg.ZIndex = 100
	self.resultMsg.Parent = content
	
	local spacer = Instance.new("Frame")
	spacer.Size = UDim2.new(1, 0, 0, 6)
	spacer.BackgroundTransparency = 1
	spacer.LayoutOrder = 4
	spacer.Parent = content
	
	self.resultOkBtn = Instance.new("TextButton")
	self.resultOkBtn.Size = UDim2.new(1, 0, 0, 50)
	self.resultOkBtn.BackgroundColor3 = C.Navy
	self.resultOkBtn.Font = F.Button
	self.resultOkBtn.TextSize = 16
	self.resultOkBtn.TextColor3 = C.White
	self.resultOkBtn.Text = "Continue"
	self.resultOkBtn.AutoButtonColor = false
	self.resultOkBtn.LayoutOrder = 5
	self.resultOkBtn.ZIndex = 100
	self.resultOkBtn.Parent = content
	corner(self.resultOkBtn, 12)
	
	self.resultOkBtn.MouseButton1Click:Connect(function() self:hideResultModal() end)
	self.resultOkBtn.MouseEnter:Connect(function() tween(self.resultOkBtn, TweenInfo.new(0.1), { BackgroundColor3 = C.NavyDark }) end)
	self.resultOkBtn.MouseLeave:Connect(function() tween(self.resultOkBtn, TweenInfo.new(0.1), { BackgroundColor3 = C.Navy }) end)
end

function OccupationScreen:showResult(success, message, emoji)
	-- Set shell color based on success
	local shellColor = success and C.Green or C.Red
	local shellStrokeColor = success and C.GreenDark or C.RedDark
	
	self.resultShell.BackgroundColor3 = shellColor
	self.resultShellStroke.Color = shellStrokeColor
	
	self.resultEmoji.Text = emoji or (success and "🎉" or "😔")
	self.resultEmojiFrame.BackgroundColor3 = success and C.GreenPale or C.RedPale
	self.resultTitle.Text = success and "Success!" or "Uh oh..."
	self.resultTitle.TextColor3 = success and C.GreenDark or C.RedDark
	self.resultMsg.Text = message or ""
	self.resultOkBtn.BackgroundColor3 = success and C.Green or C.Red
	
	self.resultOverlay.Visible = true
	self.resultShell.Position = UDim2.new(0.5, 0, 0.5, 40)
	self.resultShell.BackgroundTransparency = 1
	self.resultCard.BackgroundTransparency = 1
	
	tween(self.resultShell, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 0
	})
	tween(self.resultCard, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0
	})
end

function OccupationScreen:hideResultModal()
	local t = tween(self.resultShell, TweenInfo.new(0.2), {
		Position = UDim2.new(0.5, 0, 0.5, 40),
		BackgroundTransparency = 1
	})
	tween(self.resultCard, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
	t.Completed:Connect(function()
		self.resultOverlay.Visible = false
		self:switchTab(self.currentTab)
	end)
end

function OccupationScreen:show()
	self.overlay.Visible = true
	self.overlay.Position = UDim2.new(1, 0, 0, 0)
	
	-- Debug: print current state info
	local age = self:getAge()
	local edu = self:getEducation()
	print("[OccupationScreen] Opening - Age:", age, "Education:", edu)
	
	self:updateInfoBar()
	self:switchTab(self.currentTab) -- This forces repopulate
	
	tween(self.overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { 
		Position = UDim2.fromScale(0, 0) 
	})
	self.isVisible = true
end

function OccupationScreen:hide()
	local t = tween(self.overlay, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { 
		Position = UDim2.new(1, 0, 0, 0) 
	})
	t.Completed:Connect(function()
		self.overlay.Visible = false
		self.resultOverlay.Visible = false
	end)
	self.isVisible = false
end

return OccupationScreen
