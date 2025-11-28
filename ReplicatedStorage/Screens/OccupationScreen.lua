-- OccupationScreen.lua
-- BitLife-style Occupation screen with FULL INTERACTIVITY
-- Apply for jobs, enroll in education, do freelance work

local TweenService = game:GetService("TweenService")

local OccupationScreen = {}
OccupationScreen.__index = OccupationScreen

----------------------------------------------------------------
-- COLORS
----------------------------------------------------------------

local Colors = {
	BitLifeBlue      = Color3.fromRGB(37, 99, 235),
	BitLifeBlueDark  = Color3.fromRGB(29, 78, 216),
	BitLifeBlueLight = Color3.fromRGB(96, 165, 250),
	
	JobOrange        = Color3.fromRGB(249, 115, 22),
	JobOrangeDark    = Color3.fromRGB(234, 88, 12),
	EducationPurple  = Color3.fromRGB(139, 92, 246),
	EducationPurpleDark = Color3.fromRGB(109, 40, 217),
	FreelanceGreen   = Color3.fromRGB(16, 185, 129),
	FreelanceGreenDark = Color3.fromRGB(5, 150, 105),
	SpecialGold      = Color3.fromRGB(234, 179, 8),
	
	SuccessGreen     = Color3.fromRGB(34, 197, 94),
	ErrorRed         = Color3.fromRGB(239, 68, 68),
	
	White            = Color3.fromRGB(255, 255, 255),
	CardWhite        = Color3.fromRGB(255, 255, 255),
	LightGray        = Color3.fromRGB(243, 244, 246),
	MediumGray       = Color3.fromRGB(156, 163, 175),
	DarkGray         = Color3.fromRGB(75, 85, 99),
	DarkerGray       = Color3.fromRGB(55, 65, 81),
	TextBlack        = Color3.fromRGB(17, 24, 39),
	ScreenBg         = Color3.fromRGB(241, 245, 249),
	OverlayDark      = Color3.fromRGB(0, 0, 0),
}

local Fonts = {
	Title = Enum.Font.GothamBold,
	Body = Enum.Font.Gotham,
	BodyMedium = Enum.Font.GothamMedium,
	Button = Enum.Font.GothamBold,
}

----------------------------------------------------------------
-- JOB DATA
----------------------------------------------------------------

local JobListings = {
	{ title = "Fast Food Worker", emoji = "🍔", company = "Burger Palace", salary = 22000, education = "None", exp = 0, acceptance = 95 },
	{ title = "Retail Associate", emoji = "🛒", company = "MegaMart", salary = 26000, education = "None", exp = 0, acceptance = 90 },
	{ title = "Janitor", emoji = "🧹", company = "CleanCo Services", salary = 28000, education = "None", exp = 0, acceptance = 92 },
	{ title = "Receptionist", emoji = "📞", company = "Corporate Office", salary = 32000, education = "High School", exp = 0, acceptance = 80 },
	{ title = "Office Assistant", emoji = "📎", company = "Business Solutions", salary = 35000, education = "High School", exp = 1, acceptance = 75 },
	{ title = "Junior Accountant", emoji = "📊", company = "Financial Services", salary = 48000, education = "Bachelor's", exp = 1, acceptance = 60 },
	{ title = "Marketing Associate", emoji = "📢", company = "AdVenture Agency", salary = 52000, education = "Bachelor's", exp = 2, acceptance = 55 },
	{ title = "Software Developer", emoji = "💻", company = "TechStart Inc", salary = 85000, education = "Bachelor's", exp = 2, acceptance = 45 },
	{ title = "Senior Developer", emoji = "👨‍💻", company = "BigTech Corp", salary = 140000, education = "Bachelor's", exp = 5, acceptance = 30 },
	{ title = "Doctor", emoji = "🩺", company = "City Hospital", salary = 250000, education = "Medical School", exp = 8, acceptance = 15 },
	{ title = "Lawyer", emoji = "⚖️", company = "Smith & Associates", salary = 180000, education = "Law School", exp = 5, acceptance = 25 },
}

local EducationOptions = {
	{ name = "High School Diploma", emoji = "🎓", duration = "4 years", cost = 0, requirement = "None", type = "highschool" },
	{ name = "Community College", emoji = "📚", duration = "2 years", cost = 15000, requirement = "High School", type = "community" },
	{ name = "Bachelor's Degree", emoji = "🎓", duration = "4 years", cost = 80000, requirement = "High School", type = "bachelor" },
	{ name = "Master's Degree", emoji = "📜", duration = "2 years", cost = 60000, requirement = "Bachelor's", type = "master" },
	{ name = "Medical School", emoji = "🏥", duration = "4 years", cost = 200000, requirement = "Bachelor's", type = "medical" },
	{ name = "Law School", emoji = "⚖️", duration = "3 years", cost = 150000, requirement = "Bachelor's", type = "law" },
	{ name = "PhD Program", emoji = "🔬", duration = "5 years", cost = 100000, requirement = "Master's", type = "phd" },
}

local FreelanceGigs = {
	{ name = "Deliver Food", emoji = "🚴", pay = { 30, 80 }, time = "1-2 hours" },
	{ name = "Walk Dogs", emoji = "🐕", pay = { 20, 50 }, time = "1 hour" },
	{ name = "Babysit", emoji = "👶", pay = { 50, 120 }, time = "3-4 hours" },
	{ name = "Mow Lawns", emoji = "🌿", pay = { 40, 100 }, time = "2 hours" },
	{ name = "Tutor Students", emoji = "📖", pay = { 30, 75 }, time = "1-2 hours" },
	{ name = "Drive Rideshare", emoji = "🚗", pay = { 50, 150 }, time = "2-4 hours" },
	{ name = "Freelance Writing", emoji = "✍️", pay = { 100, 500 }, time = "Varies" },
	{ name = "Graphic Design", emoji = "🎨", pay = { 150, 800 }, time = "Varies" },
}

local SpecialCareers = {
	{ name = "Start a Business", emoji = "🏢", description = "Become an entrepreneur", requirement = "$10,000 startup" },
	{ name = "Become an Actor", emoji = "🎭", description = "Try your luck in Hollywood", requirement = "Looks 70+" },
	{ name = "Professional Athlete", emoji = "⚽", description = "Go pro in sports", requirement = "Health 80+" },
	{ name = "Music Career", emoji = "🎤", description = "Become a musician", requirement = "Smarts 50+" },
	{ name = "Social Media Star", emoji = "📱", description = "Become an influencer", requirement = "Looks 60+" },
}

----------------------------------------------------------------
-- PLAYER STATE (simulated)
----------------------------------------------------------------

local PlayerJob = {
	hasJob = false,
	currentJob = nil,
	education = "High School",
	experience = 0,
}

----------------------------------------------------------------
-- HELPERS
----------------------------------------------------------------

local function createUICorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
	return c
end

local function createPillCorner(parent)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0.5, 0)
	c.Parent = parent
	return c
end

local function createUIStroke(parent, thickness, transparency, color)
	local s = Instance.new("UIStroke")
	s.Thickness = thickness
	s.Transparency = transparency or 0
	s.Color = color or Colors.White
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function createUIPadding(parent, left, right, top, bottom)
	local p = Instance.new("UIPadding")
	p.PaddingLeft = UDim.new(0, left or 0)
	p.PaddingRight = UDim.new(0, right or 0)
	p.PaddingTop = UDim.new(0, top or 0)
	p.PaddingBottom = UDim.new(0, bottom or 0)
	p.Parent = parent
	return p
end

local function tween(obj, info, props)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

local function formatSalary(amount)
	local str = tostring(amount)
	local formatted = ""
	local count = 0
	for i = #str, 1, -1 do
		count = count + 1
		formatted = str:sub(i, i) .. formatted
		if count % 3 == 0 and i > 1 then
			formatted = "," .. formatted
		end
	end
	return "$" .. formatted .. "/yr"
end

local function formatMoney(amount)
	local str = tostring(math.floor(amount))
	local formatted = ""
	local count = 0
	for i = #str, 1, -1 do
		count = count + 1
		formatted = str:sub(i, i) .. formatted
		if count % 3 == 0 and i > 1 then
			formatted = "," .. formatted
		end
	end
	return "$" .. formatted
end

----------------------------------------------------------------
-- SCREEN CREATION
----------------------------------------------------------------

function OccupationScreen.new(screenGui, blurOverlay, showBlurFunc, hideBlurFunc, playerState)
	local self = setmetatable({}, OccupationScreen)
	
	self.screenGui = screenGui
	self.playerState = playerState
	self.isVisible = false
	
	self:createUI()
	self:createApplicationModal()
	self:createResultModal()
	
	return self
end

function OccupationScreen:createUI()
	self.overlay = Instance.new("Frame")
	self.overlay.Name = "OccupationOverlay"
	self.overlay.Size = UDim2.fromScale(1, 1)
	self.overlay.BackgroundColor3 = Colors.ScreenBg
	self.overlay.Visible = false
	self.overlay.ZIndex = 80
	self.overlay.Parent = self.screenGui
	
	-- Header
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 60)
	header.BackgroundColor3 = Colors.BitLifeBlue
	header.BorderSizePixel = 0
	header.ZIndex = 85
	header.Parent = self.overlay
	
	local headerGrad = Instance.new("UIGradient")
	headerGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Colors.BitLifeBlue), ColorSequenceKeypoint.new(1, Colors.BitLifeBlueDark) })
	headerGrad.Rotation = 90
	headerGrad.Parent = header
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -80, 1, 0)
	titleLabel.Position = UDim2.new(0, 16, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Fonts.Title
	titleLabel.TextSize = 20
	titleLabel.TextColor3 = Colors.White
	titleLabel.Text = "💼 Occupation"
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 86
	titleLabel.Parent = header
	
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 44, 0, 44)
	closeBtn.AnchorPoint = Vector2.new(1, 0.5)
	closeBtn.Position = UDim2.new(1, -10, 0.5, 0)
	closeBtn.BackgroundColor3 = Colors.White
	closeBtn.BackgroundTransparency = 0.9
	closeBtn.Font = Fonts.Title
	closeBtn.TextSize = 24
	closeBtn.TextColor3 = Colors.White
	closeBtn.Text = "✕"
	closeBtn.AutoButtonColor = false
	closeBtn.ZIndex = 86
	closeBtn.Parent = header
	createUICorner(closeBtn, 22)
	
	closeBtn.MouseEnter:Connect(function() tween(closeBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0.7 }) end)
	closeBtn.MouseLeave:Connect(function() tween(closeBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0.9 }) end)
	closeBtn.MouseButton1Click:Connect(function() self:hide() end)
	
	-- Current Job Card
	local currentJobCard = Instance.new("Frame")
	currentJobCard.Size = UDim2.new(1, -32, 0, 90)
	currentJobCard.Position = UDim2.new(0, 16, 0, 70)
	currentJobCard.BackgroundColor3 = Colors.CardWhite
	currentJobCard.ZIndex = 82
	currentJobCard.Parent = self.overlay
	createUICorner(currentJobCard, 16)
	createUIStroke(currentJobCard, 2, 0.7, Colors.BitLifeBlue)
	
	local jobIcon = Instance.new("TextLabel")
	jobIcon.Size = UDim2.new(0, 50, 0, 50)
	jobIcon.Position = UDim2.new(0, 16, 0.5, -25)
	jobIcon.BackgroundTransparency = 1
	jobIcon.Font = Fonts.Body
	jobIcon.TextSize = 36
	jobIcon.Text = "😴"
	jobIcon.ZIndex = 83
	jobIcon.Parent = currentJobCard
	self.jobIcon = jobIcon
	
	local jobTitle = Instance.new("TextLabel")
	jobTitle.Size = UDim2.new(0.6, 0, 0, 24)
	jobTitle.Position = UDim2.new(0, 76, 0, 16)
	jobTitle.BackgroundTransparency = 1
	jobTitle.Font = Fonts.Title
	jobTitle.TextSize = 16
	jobTitle.TextColor3 = Colors.TextBlack
	jobTitle.TextXAlignment = Enum.TextXAlignment.Left
	jobTitle.Text = "Unemployed"
	jobTitle.ZIndex = 83
	jobTitle.Parent = currentJobCard
	self.jobTitle = jobTitle
	
	local jobCompany = Instance.new("TextLabel")
	jobCompany.Size = UDim2.new(0.6, 0, 0, 18)
	jobCompany.Position = UDim2.new(0, 76, 0, 40)
	jobCompany.BackgroundTransparency = 1
	jobCompany.Font = Fonts.Body
	jobCompany.TextSize = 13
	jobCompany.TextColor3 = Colors.MediumGray
	jobCompany.TextXAlignment = Enum.TextXAlignment.Left
	jobCompany.Text = "Looking for work..."
	jobCompany.ZIndex = 83
	jobCompany.Parent = currentJobCard
	self.jobCompany = jobCompany
	
	local jobSalary = Instance.new("TextLabel")
	jobSalary.Size = UDim2.new(0.6, 0, 0, 20)
	jobSalary.Position = UDim2.new(0, 76, 0, 60)
	jobSalary.BackgroundTransparency = 1
	jobSalary.Font = Fonts.Title
	jobSalary.TextSize = 14
	jobSalary.TextColor3 = Colors.SuccessGreen
	jobSalary.TextXAlignment = Enum.TextXAlignment.Left
	jobSalary.Text = "$0/yr"
	jobSalary.ZIndex = 83
	jobSalary.Parent = currentJobCard
	self.jobSalary = jobSalary
	
	-- Work button (only visible when employed)
	self.workBtn = Instance.new("TextButton")
	self.workBtn.Size = UDim2.new(0, 70, 0, 36)
	self.workBtn.AnchorPoint = Vector2.new(1, 0.5)
	self.workBtn.Position = UDim2.new(1, -14, 0.5, 0)
	self.workBtn.BackgroundColor3 = Colors.BitLifeBlue
	self.workBtn.Font = Fonts.Button
	self.workBtn.TextSize = 13
	self.workBtn.TextColor3 = Colors.White
	self.workBtn.Text = "Work"
	self.workBtn.AutoButtonColor = false
	self.workBtn.Visible = false
	self.workBtn.ZIndex = 83
	self.workBtn.Parent = currentJobCard
	createPillCorner(self.workBtn)
	
	self.workBtn.MouseButton1Click:Connect(function()
		self:doWork()
	end)
	
	-- Content scroll
	local contentScroll = Instance.new("ScrollingFrame")
	contentScroll.Size = UDim2.new(1, 0, 1, -170)
	contentScroll.Position = UDim2.new(0, 0, 0, 170)
	contentScroll.BackgroundTransparency = 1
	contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	contentScroll.ScrollBarThickness = 4
	contentScroll.ZIndex = 81
	contentScroll.Parent = self.overlay
	
	createUIPadding(contentScroll, 16, 16, 0, 16)
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 16)
	layout.Parent = contentScroll
	
	self.contentScroll = contentScroll
	
	-- Create sections
	self:createJobListingsSection(1)
	self:createEducationSection(2)
	self:createFreelanceSection(3)
	self:createSpecialCareersSection(4)
end

function OccupationScreen:createJobListingsSection(order)
	local section = Instance.new("Frame")
	section.Name = "JobListingsSection"
	section.Size = UDim2.new(1, 0, 0, 0)
	section.AutomaticSize = Enum.AutomaticSize.Y
	section.BackgroundTransparency = 1
	section.LayoutOrder = order
	section.Parent = self.contentScroll
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.Parent = section
	
	local headerFrame = Instance.new("Frame")
	headerFrame.Size = UDim2.new(1, 0, 0, 44)
	headerFrame.BackgroundColor3 = Colors.JobOrange
	headerFrame.LayoutOrder = 1
	headerFrame.Parent = section
	createUICorner(headerFrame, 12)
	
	local headerText = Instance.new("TextLabel")
	headerText.Size = UDim2.fromScale(1, 1)
	headerText.BackgroundTransparency = 1
	headerText.Font = Fonts.Title
	headerText.TextSize = 16
	headerText.TextColor3 = Colors.White
	headerText.Text = "📋 Job Listings"
	headerText.Parent = headerFrame
	
	for i, job in ipairs(JobListings) do
		self:createJobCard(job, i + 1, section)
	end
end

function OccupationScreen:createJobCard(job, order, parent)
	local card = Instance.new("Frame")
	card.Name = "Job_" .. job.title:gsub(" ", "_")
	card.Size = UDim2.new(1, 0, 0, 95)
	card.BackgroundColor3 = Colors.CardWhite
	card.LayoutOrder = order
	card.Parent = parent
	createUICorner(card, 14)
	createUIStroke(card, 1, 0.85, Color3.fromRGB(229, 231, 235))
	
	local emojiCircle = Instance.new("Frame")
	emojiCircle.Size = UDim2.new(0, 50, 0, 50)
	emojiCircle.Position = UDim2.new(0, 14, 0.5, -25)
	emojiCircle.BackgroundColor3 = Color3.fromRGB(255, 247, 237)
	emojiCircle.Parent = card
	createUICorner(emojiCircle, 25)
	
	local emojiLabel = Instance.new("TextLabel")
	emojiLabel.Size = UDim2.fromScale(1, 1)
	emojiLabel.BackgroundTransparency = 1
	emojiLabel.Font = Fonts.Body
	emojiLabel.TextSize = 26
	emojiLabel.Text = job.emoji
	emojiLabel.Parent = emojiCircle
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0.5, 0, 0, 20)
	titleLabel.Position = UDim2.new(0, 74, 0, 10)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Fonts.Title
	titleLabel.TextSize = 14
	titleLabel.TextColor3 = Colors.TextBlack
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = job.title
	titleLabel.Parent = card
	
	local companyLabel = Instance.new("TextLabel")
	companyLabel.Size = UDim2.new(0.5, 0, 0, 14)
	companyLabel.Position = UDim2.new(0, 74, 0, 30)
	companyLabel.BackgroundTransparency = 1
	companyLabel.Font = Fonts.Body
	companyLabel.TextSize = 11
	companyLabel.TextColor3 = Colors.MediumGray
	companyLabel.TextXAlignment = Enum.TextXAlignment.Left
	companyLabel.Text = "🏢 " .. job.company
	companyLabel.Parent = card
	
	local reqLabel = Instance.new("TextLabel")
	reqLabel.Size = UDim2.new(0.5, 0, 0, 14)
	reqLabel.Position = UDim2.new(0, 74, 0, 46)
	reqLabel.BackgroundTransparency = 1
	reqLabel.Font = Fonts.Body
	reqLabel.TextSize = 10
	reqLabel.TextColor3 = Colors.MediumGray
	reqLabel.TextXAlignment = Enum.TextXAlignment.Left
	reqLabel.Text = "📜 " .. job.education .. (job.exp > 0 and (" • " .. job.exp .. " yr exp") or "")
	reqLabel.Parent = card
	
	local salaryLabel = Instance.new("TextLabel")
	salaryLabel.Size = UDim2.new(0.5, 0, 0, 18)
	salaryLabel.Position = UDim2.new(0, 74, 0, 64)
	salaryLabel.BackgroundTransparency = 1
	salaryLabel.Font = Fonts.Title
	salaryLabel.TextSize = 14
	salaryLabel.TextColor3 = Colors.SuccessGreen
	salaryLabel.TextXAlignment = Enum.TextXAlignment.Left
	salaryLabel.Text = formatSalary(job.salary)
	salaryLabel.Parent = card
	
	local applyBtn = Instance.new("TextButton")
	applyBtn.Size = UDim2.new(0, 65, 0, 36)
	applyBtn.AnchorPoint = Vector2.new(1, 0.5)
	applyBtn.Position = UDim2.new(1, -14, 0.5, 0)
	applyBtn.BackgroundColor3 = Colors.JobOrange
	applyBtn.Font = Fonts.Button
	applyBtn.TextSize = 12
	applyBtn.TextColor3 = Colors.White
	applyBtn.Text = "Apply"
	applyBtn.AutoButtonColor = false
	applyBtn.Parent = card
	createPillCorner(applyBtn)
	
	applyBtn.MouseEnter:Connect(function() tween(applyBtn, TweenInfo.new(0.1), { BackgroundColor3 = Colors.JobOrangeDark }) end)
	applyBtn.MouseLeave:Connect(function() tween(applyBtn, TweenInfo.new(0.1), { BackgroundColor3 = Colors.JobOrange }) end)
	
	applyBtn.MouseButton1Click:Connect(function()
		self:showApplicationModal(job, "job")
	end)
end

function OccupationScreen:createEducationSection(order)
	local section = Instance.new("Frame")
	section.Name = "EducationSection"
	section.Size = UDim2.new(1, 0, 0, 0)
	section.AutomaticSize = Enum.AutomaticSize.Y
	section.BackgroundTransparency = 1
	section.LayoutOrder = order
	section.Parent = self.contentScroll
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.Parent = section
	
	local headerFrame = Instance.new("Frame")
	headerFrame.Size = UDim2.new(1, 0, 0, 44)
	headerFrame.BackgroundColor3 = Colors.EducationPurple
	headerFrame.LayoutOrder = 1
	headerFrame.Parent = section
	createUICorner(headerFrame, 12)
	
	local headerText = Instance.new("TextLabel")
	headerText.Size = UDim2.fromScale(1, 1)
	headerText.BackgroundTransparency = 1
	headerText.Font = Fonts.Title
	headerText.TextSize = 16
	headerText.TextColor3 = Colors.White
	headerText.Text = "🎓 Education"
	headerText.Parent = headerFrame
	
	for i, edu in ipairs(EducationOptions) do
		self:createEducationCard(edu, i + 1, section)
	end
end

function OccupationScreen:createEducationCard(edu, order, parent)
	local card = Instance.new("Frame")
	card.Name = "Education_" .. edu.name:gsub(" ", "_")
	card.Size = UDim2.new(1, 0, 0, 85)
	card.BackgroundColor3 = Colors.CardWhite
	card.LayoutOrder = order
	card.Parent = parent
	createUICorner(card, 14)
	createUIStroke(card, 1, 0.85, Color3.fromRGB(229, 231, 235))
	
	local emojiCircle = Instance.new("Frame")
	emojiCircle.Size = UDim2.new(0, 46, 0, 46)
	emojiCircle.Position = UDim2.new(0, 14, 0.5, -23)
	emojiCircle.BackgroundColor3 = Color3.fromRGB(245, 243, 255)
	emojiCircle.Parent = card
	createUICorner(emojiCircle, 23)
	
	local emojiLabel = Instance.new("TextLabel")
	emojiLabel.Size = UDim2.fromScale(1, 1)
	emojiLabel.BackgroundTransparency = 1
	emojiLabel.Font = Fonts.Body
	emojiLabel.TextSize = 24
	emojiLabel.Text = edu.emoji
	emojiLabel.Parent = emojiCircle
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.5, 0, 0, 20)
	nameLabel.Position = UDim2.new(0, 70, 0, 12)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Fonts.Title
	nameLabel.TextSize = 14
	nameLabel.TextColor3 = Colors.TextBlack
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = edu.name
	nameLabel.Parent = card
	
	local durationLabel = Instance.new("TextLabel")
	durationLabel.Size = UDim2.new(0.5, 0, 0, 14)
	durationLabel.Position = UDim2.new(0, 70, 0, 32)
	durationLabel.BackgroundTransparency = 1
	durationLabel.Font = Fonts.Body
	durationLabel.TextSize = 11
	durationLabel.TextColor3 = Colors.MediumGray
	durationLabel.TextXAlignment = Enum.TextXAlignment.Left
	durationLabel.Text = "⏱️ " .. edu.duration .. " • Req: " .. edu.requirement
	durationLabel.Parent = card
	
	local costLabel = Instance.new("TextLabel")
	costLabel.Size = UDim2.new(0.5, 0, 0, 16)
	costLabel.Position = UDim2.new(0, 70, 0, 52)
	costLabel.BackgroundTransparency = 1
	costLabel.Font = Fonts.Title
	costLabel.TextSize = 13
	costLabel.TextColor3 = edu.cost > 0 and Colors.ErrorRed or Colors.SuccessGreen
	costLabel.TextXAlignment = Enum.TextXAlignment.Left
	costLabel.Text = edu.cost > 0 and formatMoney(edu.cost) or "FREE"
	costLabel.Parent = card
	
	local enrollBtn = Instance.new("TextButton")
	enrollBtn.Size = UDim2.new(0, 65, 0, 34)
	enrollBtn.AnchorPoint = Vector2.new(1, 0.5)
	enrollBtn.Position = UDim2.new(1, -14, 0.5, 0)
	enrollBtn.BackgroundColor3 = Colors.EducationPurple
	enrollBtn.Font = Fonts.Button
	enrollBtn.TextSize = 12
	enrollBtn.TextColor3 = Colors.White
	enrollBtn.Text = "Enroll"
	enrollBtn.AutoButtonColor = false
	enrollBtn.Parent = card
	createPillCorner(enrollBtn)
	
	enrollBtn.MouseEnter:Connect(function() tween(enrollBtn, TweenInfo.new(0.1), { BackgroundColor3 = Colors.EducationPurpleDark }) end)
	enrollBtn.MouseLeave:Connect(function() tween(enrollBtn, TweenInfo.new(0.1), { BackgroundColor3 = Colors.EducationPurple }) end)
	
	enrollBtn.MouseButton1Click:Connect(function()
		self:showApplicationModal(edu, "education")
	end)
end

function OccupationScreen:createFreelanceSection(order)
	local section = Instance.new("Frame")
	section.Name = "FreelanceSection"
	section.Size = UDim2.new(1, 0, 0, 0)
	section.AutomaticSize = Enum.AutomaticSize.Y
	section.BackgroundTransparency = 1
	section.LayoutOrder = order
	section.Parent = self.contentScroll
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.Parent = section
	
	local headerFrame = Instance.new("Frame")
	headerFrame.Size = UDim2.new(1, 0, 0, 44)
	headerFrame.BackgroundColor3 = Colors.FreelanceGreen
	headerFrame.LayoutOrder = 1
	headerFrame.Parent = section
	createUICorner(headerFrame, 12)
	
	local headerText = Instance.new("TextLabel")
	headerText.Size = UDim2.fromScale(1, 1)
	headerText.BackgroundTransparency = 1
	headerText.Font = Fonts.Title
	headerText.TextSize = 16
	headerText.TextColor3 = Colors.White
	headerText.Text = "💪 Freelance & Gig Work"
	headerText.Parent = headerFrame
	
	for i, gig in ipairs(FreelanceGigs) do
		self:createGigCard(gig, i + 1, section)
	end
end

function OccupationScreen:createGigCard(gig, order, parent)
	local card = Instance.new("Frame")
	card.Name = "Gig_" .. gig.name:gsub(" ", "_")
	card.Size = UDim2.new(1, 0, 0, 70)
	card.BackgroundColor3 = Colors.CardWhite
	card.LayoutOrder = order
	card.Parent = parent
	createUICorner(card, 14)
	createUIStroke(card, 1, 0.85, Color3.fromRGB(229, 231, 235))
	
	local emojiCircle = Instance.new("Frame")
	emojiCircle.Size = UDim2.new(0, 46, 0, 46)
	emojiCircle.Position = UDim2.new(0, 14, 0.5, -23)
	emojiCircle.BackgroundColor3 = Color3.fromRGB(209, 250, 229)
	emojiCircle.Parent = card
	createUICorner(emojiCircle, 23)
	
	local emojiLabel = Instance.new("TextLabel")
	emojiLabel.Size = UDim2.fromScale(1, 1)
	emojiLabel.BackgroundTransparency = 1
	emojiLabel.Font = Fonts.Body
	emojiLabel.TextSize = 24
	emojiLabel.Text = gig.emoji
	emojiLabel.Parent = emojiCircle
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.5, 0, 0, 20)
	nameLabel.Position = UDim2.new(0, 70, 0, 14)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Fonts.Title
	nameLabel.TextSize = 14
	nameLabel.TextColor3 = Colors.TextBlack
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = gig.name
	nameLabel.Parent = card
	
	local payLabel = Instance.new("TextLabel")
	payLabel.Size = UDim2.new(0.5, 0, 0, 14)
	payLabel.Position = UDim2.new(0, 70, 0, 34)
	payLabel.BackgroundTransparency = 1
	payLabel.Font = Fonts.Body
	payLabel.TextSize = 11
	payLabel.TextColor3 = Colors.SuccessGreen
	payLabel.TextXAlignment = Enum.TextXAlignment.Left
	payLabel.Text = "💰 $" .. gig.pay[1] .. " - $" .. gig.pay[2] .. " • " .. gig.time
	payLabel.Parent = card
	
	local doBtn = Instance.new("TextButton")
	doBtn.Size = UDim2.new(0, 54, 0, 32)
	doBtn.AnchorPoint = Vector2.new(1, 0.5)
	doBtn.Position = UDim2.new(1, -14, 0.5, 0)
	doBtn.BackgroundColor3 = Colors.FreelanceGreen
	doBtn.Font = Fonts.Button
	doBtn.TextSize = 12
	doBtn.TextColor3 = Colors.White
	doBtn.Text = "Do It"
	doBtn.AutoButtonColor = false
	doBtn.Parent = card
	createPillCorner(doBtn)
	
	doBtn.MouseEnter:Connect(function() tween(doBtn, TweenInfo.new(0.1), { BackgroundColor3 = Colors.FreelanceGreenDark }) end)
	doBtn.MouseLeave:Connect(function() tween(doBtn, TweenInfo.new(0.1), { BackgroundColor3 = Colors.FreelanceGreen }) end)
	
	doBtn.MouseButton1Click:Connect(function()
		self:doFreelance(gig)
	end)
end

function OccupationScreen:createSpecialCareersSection(order)
	local section = Instance.new("Frame")
	section.Name = "SpecialSection"
	section.Size = UDim2.new(1, 0, 0, 0)
	section.AutomaticSize = Enum.AutomaticSize.Y
	section.BackgroundTransparency = 1
	section.LayoutOrder = order
	section.Parent = self.contentScroll
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.Parent = section
	
	local headerFrame = Instance.new("Frame")
	headerFrame.Size = UDim2.new(1, 0, 0, 44)
	headerFrame.BackgroundColor3 = Colors.SpecialGold
	headerFrame.LayoutOrder = 1
	headerFrame.Parent = section
	createUICorner(headerFrame, 12)
	
	local headerText = Instance.new("TextLabel")
	headerText.Size = UDim2.fromScale(1, 1)
	headerText.BackgroundTransparency = 1
	headerText.Font = Fonts.Title
	headerText.TextSize = 16
	headerText.TextColor3 = Colors.TextBlack
	headerText.Text = "⭐ Special Careers"
	headerText.Parent = headerFrame
	
	for i, career in ipairs(SpecialCareers) do
		self:createSpecialCard(career, i + 1, section)
	end
end

function OccupationScreen:createSpecialCard(career, order, parent)
	local card = Instance.new("Frame")
	card.Name = "Special_" .. career.name:gsub(" ", "_")
	card.Size = UDim2.new(1, 0, 0, 75)
	card.BackgroundColor3 = Colors.CardWhite
	card.LayoutOrder = order
	card.Parent = parent
	createUICorner(card, 14)
	createUIStroke(card, 1, 0.85, Color3.fromRGB(229, 231, 235))
	
	local emojiCircle = Instance.new("Frame")
	emojiCircle.Size = UDim2.new(0, 46, 0, 46)
	emojiCircle.Position = UDim2.new(0, 14, 0.5, -23)
	emojiCircle.BackgroundColor3 = Color3.fromRGB(254, 249, 195)
	emojiCircle.Parent = card
	createUICorner(emojiCircle, 23)
	
	local emojiLabel = Instance.new("TextLabel")
	emojiLabel.Size = UDim2.fromScale(1, 1)
	emojiLabel.BackgroundTransparency = 1
	emojiLabel.Font = Fonts.Body
	emojiLabel.TextSize = 24
	emojiLabel.Text = career.emoji
	emojiLabel.Parent = emojiCircle
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.5, 0, 0, 20)
	nameLabel.Position = UDim2.new(0, 70, 0, 14)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Fonts.Title
	nameLabel.TextSize = 14
	nameLabel.TextColor3 = Colors.TextBlack
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = career.name
	nameLabel.Parent = card
	
	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(0.5, 0, 0, 14)
	descLabel.Position = UDim2.new(0, 70, 0, 34)
	descLabel.BackgroundTransparency = 1
	descLabel.Font = Fonts.Body
	descLabel.TextSize = 11
	descLabel.TextColor3 = Colors.MediumGray
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.Text = career.description .. " • " .. career.requirement
	descLabel.Parent = card
	
	local tryBtn = Instance.new("TextButton")
	tryBtn.Size = UDim2.new(0, 54, 0, 32)
	tryBtn.AnchorPoint = Vector2.new(1, 0.5)
	tryBtn.Position = UDim2.new(1, -14, 0.5, 0)
	tryBtn.BackgroundColor3 = Colors.SpecialGold
	tryBtn.Font = Fonts.Button
	tryBtn.TextSize = 12
	tryBtn.TextColor3 = Colors.TextBlack
	tryBtn.Text = "Try"
	tryBtn.AutoButtonColor = false
	tryBtn.Parent = card
	createPillCorner(tryBtn)
	
	tryBtn.MouseEnter:Connect(function() tween(tryBtn, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(202, 138, 4) }) end)
	tryBtn.MouseLeave:Connect(function() tween(tryBtn, TweenInfo.new(0.1), { BackgroundColor3 = Colors.SpecialGold }) end)
	
	tryBtn.MouseButton1Click:Connect(function()
		self:trySpecialCareer(career)
	end)
end

function OccupationScreen:createApplicationModal()
	self.appOverlay = Instance.new("Frame")
	self.appOverlay.Name = "ApplicationOverlay"
	self.appOverlay.Size = UDim2.fromScale(1, 1)
	self.appOverlay.BackgroundColor3 = Colors.OverlayDark
	self.appOverlay.BackgroundTransparency = 0.4
	self.appOverlay.Visible = false
	self.appOverlay.ZIndex = 90
	self.appOverlay.Parent = self.screenGui
	
	self.appModal = Instance.new("Frame")
	self.appModal.Size = UDim2.new(0, 320, 0, 0)
	self.appModal.AutomaticSize = Enum.AutomaticSize.Y
	self.appModal.AnchorPoint = Vector2.new(0.5, 0.5)
	self.appModal.Position = UDim2.fromScale(0.5, 0.5)
	self.appModal.BackgroundColor3 = Colors.CardWhite
	self.appModal.ZIndex = 91
	self.appModal.Parent = self.appOverlay
	createUICorner(self.appModal, 20)
	
	createUIPadding(self.appModal, 24, 24, 24, 24)
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 12)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = self.appModal
	
	self.appEmoji = Instance.new("TextLabel")
	self.appEmoji.Size = UDim2.new(0, 60, 0, 60)
	self.appEmoji.BackgroundTransparency = 1
	self.appEmoji.Font = Fonts.Body
	self.appEmoji.TextSize = 50
	self.appEmoji.Text = "💼"
	self.appEmoji.LayoutOrder = 1
	self.appEmoji.Parent = self.appModal
	
	self.appTitle = Instance.new("TextLabel")
	self.appTitle.Size = UDim2.new(1, 0, 0, 24)
	self.appTitle.BackgroundTransparency = 1
	self.appTitle.Font = Fonts.Title
	self.appTitle.TextSize = 18
	self.appTitle.TextColor3 = Colors.TextBlack
	self.appTitle.Text = "Apply"
	self.appTitle.LayoutOrder = 2
	self.appTitle.Parent = self.appModal
	
	self.appDesc = Instance.new("TextLabel")
	self.appDesc.Size = UDim2.new(1, 0, 0, 0)
	self.appDesc.AutomaticSize = Enum.AutomaticSize.Y
	self.appDesc.BackgroundTransparency = 1
	self.appDesc.Font = Fonts.Body
	self.appDesc.TextSize = 13
	self.appDesc.TextColor3 = Colors.DarkGray
	self.appDesc.TextWrapped = true
	self.appDesc.Text = "Details"
	self.appDesc.LayoutOrder = 3
	self.appDesc.Parent = self.appModal
	
	self.appInfo = Instance.new("TextLabel")
	self.appInfo.Size = UDim2.new(1, 0, 0, 20)
	self.appInfo.BackgroundTransparency = 1
	self.appInfo.Font = Fonts.BodyMedium
	self.appInfo.TextSize = 14
	self.appInfo.TextColor3 = Colors.SuccessGreen
	self.appInfo.Text = ""
	self.appInfo.LayoutOrder = 4
	self.appInfo.Parent = self.appModal
	
	local btnContainer = Instance.new("Frame")
	btnContainer.Size = UDim2.new(1, 0, 0, 48)
	btnContainer.BackgroundTransparency = 1
	btnContainer.LayoutOrder = 5
	btnContainer.Parent = self.appModal
	
	local btnLayout = Instance.new("UIListLayout")
	btnLayout.FillDirection = Enum.FillDirection.Horizontal
	btnLayout.Padding = UDim.new(0, 12)
	btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	btnLayout.Parent = btnContainer
	
	local cancelBtn = Instance.new("TextButton")
	cancelBtn.Size = UDim2.new(0.45, 0, 1, 0)
	cancelBtn.BackgroundColor3 = Colors.LightGray
	cancelBtn.Font = Fonts.Button
	cancelBtn.TextSize = 15
	cancelBtn.TextColor3 = Colors.DarkGray
	cancelBtn.Text = "Cancel"
	cancelBtn.AutoButtonColor = false
	cancelBtn.Parent = btnContainer
	createPillCorner(cancelBtn)
	
	cancelBtn.MouseButton1Click:Connect(function()
		self:hideApplicationModal()
	end)
	
	self.submitBtn = Instance.new("TextButton")
	self.submitBtn.Size = UDim2.new(0.45, 0, 1, 0)
	self.submitBtn.BackgroundColor3 = Colors.BitLifeBlue
	self.submitBtn.Font = Fonts.Button
	self.submitBtn.TextSize = 15
	self.submitBtn.TextColor3 = Colors.White
	self.submitBtn.Text = "Apply"
	self.submitBtn.AutoButtonColor = false
	self.submitBtn.Parent = btnContainer
	createPillCorner(self.submitBtn)
end

function OccupationScreen:createResultModal()
	self.resultOverlay = Instance.new("Frame")
	self.resultOverlay.Name = "ResultOverlay"
	self.resultOverlay.Size = UDim2.fromScale(1, 1)
	self.resultOverlay.BackgroundColor3 = Colors.OverlayDark
	self.resultOverlay.BackgroundTransparency = 0.5
	self.resultOverlay.Visible = false
	self.resultOverlay.ZIndex = 95
	self.resultOverlay.Parent = self.screenGui
	
	self.resultModal = Instance.new("Frame")
	self.resultModal.Size = UDim2.new(0, 320, 0, 0)
	self.resultModal.AutomaticSize = Enum.AutomaticSize.Y
	self.resultModal.AnchorPoint = Vector2.new(0.5, 0.5)
	self.resultModal.Position = UDim2.fromScale(0.5, 0.5)
	self.resultModal.BackgroundColor3 = Colors.CardWhite
	self.resultModal.ZIndex = 96
	self.resultModal.Parent = self.resultOverlay
	createUICorner(self.resultModal, 20)
	
	createUIPadding(self.resultModal, 24, 24, 24, 24)
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 16)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = self.resultModal
	
	self.resultEmoji = Instance.new("TextLabel")
	self.resultEmoji.Size = UDim2.new(0, 60, 0, 60)
	self.resultEmoji.BackgroundTransparency = 1
	self.resultEmoji.Font = Fonts.Body
	self.resultEmoji.TextSize = 50
	self.resultEmoji.Text = "✅"
	self.resultEmoji.LayoutOrder = 1
	self.resultEmoji.Parent = self.resultModal
	
	self.resultTitle = Instance.new("TextLabel")
	self.resultTitle.Size = UDim2.new(1, 0, 0, 28)
	self.resultTitle.BackgroundTransparency = 1
	self.resultTitle.Font = Fonts.Title
	self.resultTitle.TextSize = 20
	self.resultTitle.TextColor3 = Colors.SuccessGreen
	self.resultTitle.Text = "Success!"
	self.resultTitle.LayoutOrder = 2
	self.resultTitle.Parent = self.resultModal
	
	self.resultText = Instance.new("TextLabel")
	self.resultText.Size = UDim2.new(1, 0, 0, 0)
	self.resultText.AutomaticSize = Enum.AutomaticSize.Y
	self.resultText.BackgroundTransparency = 1
	self.resultText.Font = Fonts.Body
	self.resultText.TextSize = 15
	self.resultText.TextColor3 = Colors.DarkerGray
	self.resultText.TextWrapped = true
	self.resultText.Text = "Something happened!"
	self.resultText.LayoutOrder = 3
	self.resultText.Parent = self.resultModal
	
	local okBtn = Instance.new("TextButton")
	okBtn.Size = UDim2.new(1, 0, 0, 48)
	okBtn.BackgroundColor3 = Colors.BitLifeBlue
	okBtn.Font = Fonts.Button
	okBtn.TextSize = 16
	okBtn.TextColor3 = Colors.White
	okBtn.Text = "OK"
	okBtn.AutoButtonColor = false
	okBtn.LayoutOrder = 4
	okBtn.Parent = self.resultModal
	createPillCorner(okBtn)
	
	okBtn.MouseButton1Click:Connect(function()
		self:hideResultModal()
	end)
end

function OccupationScreen:showApplicationModal(item, itemType)
	self.currentItem = item
	self.currentItemType = itemType
	
	if itemType == "job" then
		self.appEmoji.Text = item.emoji
		self.appTitle.Text = item.title
		self.appDesc.Text = "Apply to " .. item.company .. " as a " .. item.title .. ".\n\nRequirements:\n• " .. item.education .. " education\n• " .. item.exp .. " years experience"
		self.appInfo.Text = "💰 " .. formatSalary(item.salary)
		self.appInfo.TextColor3 = Colors.SuccessGreen
		self.submitBtn.Text = "Apply"
		self.submitBtn.BackgroundColor3 = Colors.JobOrange
	else
		self.appEmoji.Text = item.emoji
		self.appTitle.Text = item.name
		self.appDesc.Text = "Enroll in " .. item.name .. ".\n\nDuration: " .. item.duration .. "\nRequirement: " .. item.requirement
		if item.cost > 0 then
			self.appInfo.Text = "💰 Cost: " .. formatMoney(item.cost)
			self.appInfo.TextColor3 = Colors.ErrorRed
		else
			self.appInfo.Text = "✨ FREE"
			self.appInfo.TextColor3 = Colors.SuccessGreen
		end
		self.submitBtn.Text = "Enroll"
		self.submitBtn.BackgroundColor3 = Colors.EducationPurple
	end
	
	if self.submitConnection then
		self.submitConnection:Disconnect()
	end
	
	self.submitConnection = self.submitBtn.MouseButton1Click:Connect(function()
		self:hideApplicationModal()
		task.delay(0.2, function()
			if itemType == "job" then
				self:applyForJob(item)
			else
				self:enrollInEducation(item)
			end
		end)
	end)
	
	self.appOverlay.Visible = true
	self.appModal.Position = UDim2.new(0.5, 0, 0.5, 30)
	tween(self.appModal, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.5)
	})
end

function OccupationScreen:hideApplicationModal()
	self.appOverlay.Visible = false
end

function OccupationScreen:applyForJob(job)
	-- Random acceptance based on job acceptance rate
	local accepted = math.random(100) <= job.acceptance
	
	if accepted then
		PlayerJob.hasJob = true
		PlayerJob.currentJob = job
		
		-- Update UI
		self.jobIcon.Text = job.emoji
		self.jobTitle.Text = job.title
		self.jobCompany.Text = job.company
		self.jobSalary.Text = formatSalary(job.salary)
		self.workBtn.Visible = true
		
		self:showResult("🎉", "Hired!", "Congratulations! You got the job as a " .. job.title .. " at " .. job.company .. "!\n\nYour salary is " .. formatSalary(job.salary), true)
	else
		self:showResult("😔", "Rejected", "Unfortunately, " .. job.company .. " decided not to hire you for the " .. job.title .. " position.\n\nTry again or look for other opportunities!", false)
	end
end

function OccupationScreen:enrollInEducation(edu)
	self:showResult("📚", "Enrolled!", "You've enrolled in " .. edu.name .. "!\n\nThis will take " .. edu.duration .. " to complete. Good luck with your studies!", true)
end

function OccupationScreen:doFreelance(gig)
	local earned = math.random(gig.pay[1], gig.pay[2])
	self:showResult(gig.emoji, "Gig Complete!", "You completed a " .. gig.name .. " gig and earned $" .. earned .. "!", true)
end

function OccupationScreen:doWork()
	if PlayerJob.hasJob and PlayerJob.currentJob then
		local dailyPay = math.floor(PlayerJob.currentJob.salary / 365)
		self:showResult("💼", "Day's Work Done!", "You worked hard today at " .. PlayerJob.currentJob.company .. ".\n\nYou earned $" .. dailyPay .. " (daily wage).", true)
	end
end

function OccupationScreen:trySpecialCareer(career)
	local success = math.random(100) <= 30 -- 30% chance
	
	if success then
		self:showResult("🌟", "You Made It!", "You successfully started your journey as a " .. career.name .. "!\n\nThis is just the beginning of your special career!", true)
	else
		self:showResult("😅", "Not Yet...", "Your attempt at " .. career.name .. " didn't work out this time.\n\nKeep trying! Dreams don't come easy.", false)
	end
end

function OccupationScreen:showResult(emoji, title, text, success)
	self.resultEmoji.Text = emoji
	self.resultTitle.Text = title
	self.resultTitle.TextColor3 = success and Colors.SuccessGreen or Colors.ErrorRed
	self.resultText.Text = text
	
	self.resultOverlay.Visible = true
	self.resultModal.Position = UDim2.new(0.5, 0, 0.5, 30)
	tween(self.resultModal, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.5)
	})
end

function OccupationScreen:hideResultModal()
	self.resultOverlay.Visible = false
end

----------------------------------------------------------------
-- VISIBILITY
----------------------------------------------------------------

function OccupationScreen:show()
	if self.isVisible then return end
	self.isVisible = true
	
	self.overlay.Visible = true
	self.overlay.Position = UDim2.new(1, 0, 0, 0)
	
	tween(self.overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 0, 0, 0)
	})
end

function OccupationScreen:hide()
	if not self.isVisible then return end
	self.isVisible = false
	
	self.appOverlay.Visible = false
	self.resultOverlay.Visible = false
	
	local t = tween(self.overlay, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		Position = UDim2.new(1, 0, 0, 0)
	})
	t.Completed:Connect(function()
		self.overlay.Visible = false
	end)
end

function OccupationScreen:toggle()
	if self.isVisible then self:hide() else self:show() end
end

return OccupationScreen
