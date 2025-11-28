-- OccupationScreen.lua
-- BitLife-style Occupation/Career screen with jobs, education, freelance work
-- Full-screen overlay with scrollable content sections

local TweenService = game:GetService("TweenService")

local OccupationScreen = {}
OccupationScreen.__index = OccupationScreen

----------------------------------------------------------------
-- COLORS (BitLife Palette)
----------------------------------------------------------------

local Colors = {
	-- Primary
	BitLifeBlue      = Color3.fromRGB(37, 99, 235),
	BitLifeBlueDark  = Color3.fromRGB(29, 78, 216),
	BitLifeBlueLight = Color3.fromRGB(59, 130, 246),
	
	-- Section Colors
	JobsGreen        = Color3.fromRGB(34, 197, 94),
	JobsGreenDark    = Color3.fromRGB(22, 163, 74),
	EducationPurple  = Color3.fromRGB(139, 92, 246),
	EducationPurpleDark = Color3.fromRGB(109, 40, 217),
	FreelanceOrange  = Color3.fromRGB(249, 115, 22),
	FreelanceOrangeDark = Color3.fromRGB(234, 88, 12),
	SpecialGold      = Color3.fromRGB(234, 179, 8),
	SpecialGoldDark  = Color3.fromRGB(202, 138, 4),
	MilitaryOlive    = Color3.fromRGB(101, 163, 13),
	QuitRed          = Color3.fromRGB(239, 68, 68),
	
	-- UI Elements
	White            = Color3.fromRGB(255, 255, 255),
	CardWhite        = Color3.fromRGB(255, 255, 255),
	LightGray        = Color3.fromRGB(243, 244, 246),
	MediumGray       = Color3.fromRGB(156, 163, 175),
	DarkGray         = Color3.fromRGB(75, 85, 99),
	DarkerGray       = Color3.fromRGB(55, 65, 81),
	TextDark         = Color3.fromRGB(31, 41, 55),
	TextBlack        = Color3.fromRGB(17, 24, 39),
	
	-- Background
	OverlayBlack     = Color3.fromRGB(0, 0, 0),
	ScreenBg         = Color3.fromRGB(241, 245, 249),
}

----------------------------------------------------------------
-- FONTS
----------------------------------------------------------------

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
	-- Entry level jobs (no education required)
	{
		title = "Cashier",
		company = "MegaMart",
		salary = 22000,
		emoji = "🛒",
		requirements = { minAge = 16, education = "None" },
		category = "Retail",
	},
	{
		title = "Fast Food Worker",
		company = "Burger Barn",
		salary = 19000,
		emoji = "🍔",
		requirements = { minAge = 16, education = "None" },
		category = "Food Service",
	},
	{
		title = "Janitor",
		company = "CleanCo Services",
		salary = 26000,
		emoji = "🧹",
		requirements = { minAge = 18, education = "None" },
		category = "Maintenance",
	},
	{
		title = "Receptionist",
		company = "City Dental",
		salary = 28000,
		emoji = "📞",
		requirements = { minAge = 18, education = "High School" },
		category = "Administrative",
	},
	{
		title = "Warehouse Worker",
		company = "QuickShip Logistics",
		salary = 32000,
		emoji = "📦",
		requirements = { minAge = 18, education = "None" },
		category = "Logistics",
	},
	-- Professional jobs (education required)
	{
		title = "Junior Software Developer",
		company = "TechStart Inc.",
		salary = 65000,
		emoji = "💻",
		requirements = { minAge = 22, education = "University", major = "Computer Science" },
		category = "Technology",
	},
	{
		title = "Marketing Associate",
		company = "BrandWorks Agency",
		salary = 48000,
		emoji = "📊",
		requirements = { minAge = 22, education = "University" },
		category = "Marketing",
	},
	{
		title = "Nurse",
		company = "City General Hospital",
		salary = 72000,
		emoji = "👩‍⚕️",
		requirements = { minAge = 22, education = "University", major = "Nursing" },
		category = "Healthcare",
	},
	{
		title = "Accountant",
		company = "NumberCrunch LLC",
		salary = 58000,
		emoji = "🧮",
		requirements = { minAge = 22, education = "University", major = "Finance" },
		category = "Finance",
	},
	{
		title = "Teacher",
		company = "Lincoln High School",
		salary = 45000,
		emoji = "📚",
		requirements = { minAge = 22, education = "University" },
		category = "Education",
	},
}

local EducationOptions = {
	{
		type = "High School",
		name = "Complete High School",
		duration = "4 years",
		cost = 0,
		emoji = "🎒",
		description = "Graduate high school and get your diploma.",
		minAge = 14,
		maxAge = 18,
	},
	{
		type = "Community College",
		name = "Community College",
		duration = "2 years",
		cost = 8000,
		emoji = "📖",
		description = "Get an associate's degree at a lower cost.",
		minAge = 18,
	},
	{
		type = "University",
		name = "University",
		duration = "4 years",
		cost = 45000,
		emoji = "🎓",
		description = "Earn a bachelor's degree from a university.",
		minAge = 18,
	},
	{
		type = "Graduate School",
		name = "Graduate School",
		duration = "2-4 years",
		cost = 80000,
		emoji = "🎖️",
		description = "Pursue a master's or doctoral degree.",
		minAge = 22,
		requiresUniversity = true,
	},
	{
		type = "Medical School",
		name = "Medical School",
		duration = "4 years",
		cost = 200000,
		emoji = "⚕️",
		description = "Become a doctor. Very expensive but rewarding.",
		minAge = 22,
		requiresUniversity = true,
	},
	{
		type = "Law School",
		name = "Law School",
		duration = "3 years",
		cost = 150000,
		emoji = "⚖️",
		description = "Become a lawyer and practice law.",
		minAge = 22,
		requiresUniversity = true,
	},
}

local FreelanceGigs = {
	{
		title = "Food Delivery Driver",
		payRange = "$50-150/day",
		emoji = "🚗",
		description = "Deliver food for DoorDash, UberEats, etc.",
	},
	{
		title = "Rideshare Driver",
		payRange = "$80-200/day",
		emoji = "🚕",
		description = "Drive for Uber or Lyft.",
		requiresCar = true,
	},
	{
		title = "Freelance Writer",
		payRange = "$100-500/project",
		emoji = "✍️",
		description = "Write articles, blogs, and content.",
	},
	{
		title = "Social Media Manager",
		payRange = "$500-2000/month",
		emoji = "📱",
		description = "Manage social media for small businesses.",
	},
	{
		title = "Tutoring",
		payRange = "$25-75/hour",
		emoji = "👨‍🏫",
		description = "Help students with their studies.",
	},
}

local SpecialCareers = {
	{
		title = "Join the Military",
		emoji = "🎖️",
		color = Colors.MilitaryOlive,
		description = "Serve your country in the armed forces.",
		branches = {"Army", "Navy", "Air Force", "Marines", "Coast Guard"},
	},
	{
		title = "Become a YouTuber",
		emoji = "📺",
		color = Colors.QuitRed,
		description = "Start a YouTube channel and build an audience.",
	},
	{
		title = "Start a Business",
		emoji = "🏢",
		color = Colors.SpecialGold,
		description = "Take the entrepreneurial path.",
	},
	{
		title = "Become a Musician",
		emoji = "🎸",
		color = Colors.EducationPurple,
		description = "Pursue a career in music.",
	},
	{
		title = "Become an Actor",
		emoji = "🎬",
		color = Colors.FreelanceOrange,
		description = "Try to make it in Hollywood.",
	},
}

----------------------------------------------------------------
-- HELPER FUNCTIONS
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
	if amount >= 1000000 then
		return string.format("$%.1fM", amount / 1000000)
	elseif amount >= 1000 then
		return string.format("$%.0fK", amount / 1000)
	else
		return "$" .. tostring(amount)
	end
end

----------------------------------------------------------------
-- SCREEN CREATION
----------------------------------------------------------------

function OccupationScreen.new(screenGui, blurOverlay, showBlurFunc, hideBlurFunc, playerState)
	local self = setmetatable({}, OccupationScreen)
	
	self.screenGui = screenGui
	self.blurOverlay = blurOverlay
	self.showBlur = showBlurFunc
	self.hideBlur = hideBlurFunc
	self.playerState = playerState
	self.isVisible = false
	self.currentJob = nil -- Player's current job
	
	self:createUI()
	
	return self
end

function OccupationScreen:createUI()
	-- Main overlay container
	self.overlay = Instance.new("Frame")
	self.overlay.Name = "OccupationOverlay"
	self.overlay.Size = UDim2.fromScale(1, 1)
	self.overlay.BackgroundColor3 = Colors.ScreenBg
	self.overlay.BackgroundTransparency = 0
	self.overlay.Visible = false
	self.overlay.ZIndex = 80
	self.overlay.Parent = self.screenGui
	
	-- Header bar (fixed at top)
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 60)
	header.BackgroundColor3 = Colors.BitLifeBlue
	header.BorderSizePixel = 0
	header.ZIndex = 85
	header.Parent = self.overlay
	
	-- Header gradient
	local headerGrad = Instance.new("UIGradient")
	headerGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Colors.BitLifeBlue),
		ColorSequenceKeypoint.new(1, Colors.BitLifeBlueDark),
	})
	headerGrad.Rotation = 90
	headerGrad.Parent = header
	
	-- Back button
	local backBtn = Instance.new("TextButton")
	backBtn.Name = "BackBtn"
	backBtn.Size = UDim2.new(0, 50, 0, 40)
	backBtn.Position = UDim2.new(0, 10, 0.5, -20)
	backBtn.BackgroundTransparency = 1
	backBtn.Font = Fonts.Title
	backBtn.TextSize = 24
	backBtn.TextColor3 = Colors.White
	backBtn.Text = "←"
	backBtn.ZIndex = 86
	backBtn.Parent = header
	
	backBtn.MouseButton1Click:Connect(function()
		self:hide()
	end)
	
	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -120, 1, 0)
	titleLabel.Position = UDim2.new(0, 60, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Fonts.Title
	titleLabel.TextSize = 20
	titleLabel.TextColor3 = Colors.White
	titleLabel.Text = "💼 Occupation"
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 86
	titleLabel.Parent = header
	
	-- Scrolling content area
	local contentScroll = Instance.new("ScrollingFrame")
	contentScroll.Name = "ContentScroll"
	contentScroll.Size = UDim2.new(1, 0, 1, -60)
	contentScroll.Position = UDim2.new(0, 0, 0, 60)
	contentScroll.BackgroundTransparency = 1
	contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	contentScroll.ScrollBarThickness = 4
	contentScroll.ScrollBarImageColor3 = Colors.MediumGray
	contentScroll.ZIndex = 81
	contentScroll.Parent = self.overlay
	
	local contentPadding = createUIPadding(contentScroll, 16, 16, 16, 16)
	
	local contentLayout = Instance.new("UIListLayout")
	contentLayout.FillDirection = Enum.FillDirection.Vertical
	contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	contentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	contentLayout.Padding = UDim.new(0, 16)
	contentLayout.Parent = contentScroll
	
	self.contentScroll = contentScroll
	
	-- Create sections
	self:createCurrentJobSection()
	self:createJobListingsSection()
	self:createEducationSection()
	self:createFreelanceSection()
	self:createSpecialCareersSection()
end

function OccupationScreen:createSectionHeader(parent, title, emoji, color, layoutOrder)
	local section = Instance.new("Frame")
	section.Name = title .. "Section"
	section.Size = UDim2.new(1, 0, 0, 0)
	section.AutomaticSize = Enum.AutomaticSize.Y
	section.BackgroundTransparency = 1
	section.LayoutOrder = layoutOrder
	section.Parent = parent
	
	local sectionLayout = Instance.new("UIListLayout")
	sectionLayout.FillDirection = Enum.FillDirection.Vertical
	sectionLayout.Padding = UDim.new(0, 8)
	sectionLayout.Parent = section
	
	-- Section header
	local headerFrame = Instance.new("Frame")
	headerFrame.Size = UDim2.new(1, 0, 0, 44)
	headerFrame.BackgroundColor3 = color
	headerFrame.LayoutOrder = 1
	headerFrame.Parent = section
	createUICorner(headerFrame, 12)
	
	local headerGrad = Instance.new("UIGradient")
	headerGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color),
		ColorSequenceKeypoint.new(1, Color3.new(
			math.max(0, color.R - 0.1),
			math.max(0, color.G - 0.1),
			math.max(0, color.B - 0.1)
		)),
	})
	headerGrad.Rotation = 90
	headerGrad.Parent = headerFrame
	
	local headerText = Instance.new("TextLabel")
	headerText.Size = UDim2.fromScale(1, 1)
	headerText.BackgroundTransparency = 1
	headerText.Font = Fonts.Title
	headerText.TextSize = 16
	headerText.TextColor3 = Colors.White
	headerText.Text = emoji .. "  " .. title
	headerText.Parent = headerFrame
	
	return section, sectionLayout
end

function OccupationScreen:createCurrentJobSection()
	local section, layout = self:createSectionHeader(
		self.contentScroll, 
		"Current Job", 
		"👔", 
		Colors.BitLifeBlue, 
		1
	)
	
	self.currentJobSection = section
	
	-- Current job card (or "Unemployed" message)
	local jobCard = Instance.new("Frame")
	jobCard.Name = "CurrentJobCard"
	jobCard.Size = UDim2.new(1, 0, 0, 100)
	jobCard.BackgroundColor3 = Colors.CardWhite
	jobCard.LayoutOrder = 2
	jobCard.Parent = section
	createUICorner(jobCard, 14)
	createUIStroke(jobCard, 1, 0.8, Colors.LightGray)
	
	local cardPadding = createUIPadding(jobCard, 16, 16, 14, 14)
	
	-- Unemployed state (default)
	local unemployedLabel = Instance.new("TextLabel")
	unemployedLabel.Name = "UnemployedLabel"
	unemployedLabel.Size = UDim2.fromScale(1, 1)
	unemployedLabel.BackgroundTransparency = 1
	unemployedLabel.Font = Fonts.BodyMedium
	unemployedLabel.TextSize = 16
	unemployedLabel.TextColor3 = Colors.MediumGray
	unemployedLabel.Text = "😴 You are currently unemployed.\nLook for a job below!"
	unemployedLabel.TextWrapped = true
	unemployedLabel.Parent = jobCard
	
	self.currentJobCard = jobCard
	self.unemployedLabel = unemployedLabel
end

function OccupationScreen:createJobListingsSection()
	local section, layout = self:createSectionHeader(
		self.contentScroll, 
		"Job Listings", 
		"📋", 
		Colors.JobsGreen, 
		2
	)
	
	-- Create job listing cards
	for i, job in ipairs(JobListings) do
		local jobCard = self:createJobCard(job, i + 1)
		jobCard.Parent = section
	end
end

function OccupationScreen:createJobCard(job, layoutOrder)
	local card = Instance.new("Frame")
	card.Name = "Job_" .. job.title:gsub(" ", "_")
	card.Size = UDim2.new(1, 0, 0, 90)
	card.BackgroundColor3 = Colors.CardWhite
	card.LayoutOrder = layoutOrder
	createUICorner(card, 14)
	createUIStroke(card, 1, 0.85, Color3.fromRGB(229, 231, 235))
	
	-- Left emoji circle
	local emojiCircle = Instance.new("Frame")
	emojiCircle.Size = UDim2.new(0, 50, 0, 50)
	emojiCircle.Position = UDim2.new(0, 14, 0.5, -25)
	emojiCircle.BackgroundColor3 = Color3.fromRGB(240, 253, 244)
	emojiCircle.Parent = card
	createUICorner(emojiCircle, 25)
	
	local emojiLabel = Instance.new("TextLabel")
	emojiLabel.Size = UDim2.fromScale(1, 1)
	emojiLabel.BackgroundTransparency = 1
	emojiLabel.Font = Fonts.Body
	emojiLabel.TextSize = 26
	emojiLabel.Text = job.emoji
	emojiLabel.Parent = emojiCircle
	
	-- Job info
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0.5, 0, 0, 20)
	titleLabel.Position = UDim2.new(0, 74, 0, 14)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Fonts.Title
	titleLabel.TextSize = 15
	titleLabel.TextColor3 = Colors.TextBlack
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = job.title
	titleLabel.Parent = card
	
	local companyLabel = Instance.new("TextLabel")
	companyLabel.Size = UDim2.new(0.5, 0, 0, 16)
	companyLabel.Position = UDim2.new(0, 74, 0, 34)
	companyLabel.BackgroundTransparency = 1
	companyLabel.Font = Fonts.Body
	companyLabel.TextSize = 12
	companyLabel.TextColor3 = Colors.MediumGray
	companyLabel.TextXAlignment = Enum.TextXAlignment.Left
	companyLabel.Text = job.company
	companyLabel.Parent = card
	
	local salaryLabel = Instance.new("TextLabel")
	salaryLabel.Size = UDim2.new(0.5, 0, 0, 18)
	salaryLabel.Position = UDim2.new(0, 74, 0, 54)
	salaryLabel.BackgroundTransparency = 1
	salaryLabel.Font = Fonts.BodyMedium
	salaryLabel.TextSize = 14
	salaryLabel.TextColor3 = Colors.JobsGreen
	salaryLabel.TextXAlignment = Enum.TextXAlignment.Left
	salaryLabel.Text = formatSalary(job.salary) .. "/year"
	salaryLabel.Parent = card
	
	-- Apply button
	local applyBtn = Instance.new("TextButton")
	applyBtn.Name = "ApplyBtn"
	applyBtn.Size = UDim2.new(0, 80, 0, 36)
	applyBtn.AnchorPoint = Vector2.new(1, 0.5)
	applyBtn.Position = UDim2.new(1, -14, 0.5, 0)
	applyBtn.BackgroundColor3 = Colors.JobsGreen
	applyBtn.Font = Fonts.Button
	applyBtn.TextSize = 13
	applyBtn.TextColor3 = Colors.White
	applyBtn.Text = "Apply"
	applyBtn.AutoButtonColor = false
	applyBtn.Parent = card
	createPillCorner(applyBtn)
	
	applyBtn.MouseEnter:Connect(function()
		tween(applyBtn, TweenInfo.new(0.15), { BackgroundColor3 = Colors.JobsGreenDark })
	end)
	applyBtn.MouseLeave:Connect(function()
		tween(applyBtn, TweenInfo.new(0.15), { BackgroundColor3 = Colors.JobsGreen })
	end)
	
	applyBtn.MouseButton1Click:Connect(function()
		self:applyForJob(job)
	end)
	
	return card
end

function OccupationScreen:createEducationSection()
	local section, layout = self:createSectionHeader(
		self.contentScroll, 
		"Education", 
		"🎓", 
		Colors.EducationPurple, 
		3
	)
	
	for i, edu in ipairs(EducationOptions) do
		local eduCard = self:createEducationCard(edu, i + 1)
		eduCard.Parent = section
	end
end

function OccupationScreen:createEducationCard(edu, layoutOrder)
	local card = Instance.new("Frame")
	card.Name = "Edu_" .. edu.type:gsub(" ", "_")
	card.Size = UDim2.new(1, 0, 0, 100)
	card.BackgroundColor3 = Colors.CardWhite
	card.LayoutOrder = layoutOrder
	createUICorner(card, 14)
	createUIStroke(card, 1, 0.85, Color3.fromRGB(229, 231, 235))
	
	-- Left emoji circle
	local emojiCircle = Instance.new("Frame")
	emojiCircle.Size = UDim2.new(0, 50, 0, 50)
	emojiCircle.Position = UDim2.new(0, 14, 0.5, -25)
	emojiCircle.BackgroundColor3 = Color3.fromRGB(245, 243, 255)
	emojiCircle.Parent = card
	createUICorner(emojiCircle, 25)
	
	local emojiLabel = Instance.new("TextLabel")
	emojiLabel.Size = UDim2.fromScale(1, 1)
	emojiLabel.BackgroundTransparency = 1
	emojiLabel.Font = Fonts.Body
	emojiLabel.TextSize = 26
	emojiLabel.Text = edu.emoji
	emojiLabel.Parent = emojiCircle
	
	-- Education info
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0.55, 0, 0, 20)
	titleLabel.Position = UDim2.new(0, 74, 0, 12)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Fonts.Title
	titleLabel.TextSize = 15
	titleLabel.TextColor3 = Colors.TextBlack
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = edu.name
	titleLabel.Parent = card
	
	local durationLabel = Instance.new("TextLabel")
	durationLabel.Size = UDim2.new(0.55, 0, 0, 16)
	durationLabel.Position = UDim2.new(0, 74, 0, 32)
	durationLabel.BackgroundTransparency = 1
	durationLabel.Font = Fonts.Body
	durationLabel.TextSize = 12
	durationLabel.TextColor3 = Colors.MediumGray
	durationLabel.TextXAlignment = Enum.TextXAlignment.Left
	durationLabel.Text = "⏱️ " .. edu.duration
	durationLabel.Parent = card
	
	local costLabel = Instance.new("TextLabel")
	costLabel.Size = UDim2.new(0.55, 0, 0, 16)
	costLabel.Position = UDim2.new(0, 74, 0, 50)
	costLabel.BackgroundTransparency = 1
	costLabel.Font = Fonts.BodyMedium
	costLabel.TextSize = 13
	costLabel.TextColor3 = edu.cost > 0 and Colors.QuitRed or Colors.JobsGreen
	costLabel.TextXAlignment = Enum.TextXAlignment.Left
	costLabel.Text = edu.cost > 0 and formatSalary(edu.cost) or "Free"
	costLabel.Parent = card
	
	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(0.55, 0, 0, 16)
	descLabel.Position = UDim2.new(0, 74, 0, 70)
	descLabel.BackgroundTransparency = 1
	descLabel.Font = Fonts.Body
	descLabel.TextSize = 11
	descLabel.TextColor3 = Colors.DarkGray
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextTruncate = Enum.TextTruncate.AtEnd
	descLabel.Text = edu.description
	descLabel.Parent = card
	
	-- Enroll button
	local enrollBtn = Instance.new("TextButton")
	enrollBtn.Name = "EnrollBtn"
	enrollBtn.Size = UDim2.new(0, 80, 0, 36)
	enrollBtn.AnchorPoint = Vector2.new(1, 0.5)
	enrollBtn.Position = UDim2.new(1, -14, 0.5, 0)
	enrollBtn.BackgroundColor3 = Colors.EducationPurple
	enrollBtn.Font = Fonts.Button
	enrollBtn.TextSize = 13
	enrollBtn.TextColor3 = Colors.White
	enrollBtn.Text = "Enroll"
	enrollBtn.AutoButtonColor = false
	enrollBtn.Parent = card
	createPillCorner(enrollBtn)
	
	enrollBtn.MouseEnter:Connect(function()
		tween(enrollBtn, TweenInfo.new(0.15), { BackgroundColor3 = Colors.EducationPurpleDark })
	end)
	enrollBtn.MouseLeave:Connect(function()
		tween(enrollBtn, TweenInfo.new(0.15), { BackgroundColor3 = Colors.EducationPurple })
	end)
	
	return card
end

function OccupationScreen:createFreelanceSection()
	local section, layout = self:createSectionHeader(
		self.contentScroll, 
		"Freelance & Gig Work", 
		"🚀", 
		Colors.FreelanceOrange, 
		4
	)
	
	for i, gig in ipairs(FreelanceGigs) do
		local gigCard = self:createFreelanceCard(gig, i + 1)
		gigCard.Parent = section
	end
end

function OccupationScreen:createFreelanceCard(gig, layoutOrder)
	local card = Instance.new("Frame")
	card.Name = "Gig_" .. gig.title:gsub(" ", "_")
	card.Size = UDim2.new(1, 0, 0, 80)
	card.BackgroundColor3 = Colors.CardWhite
	card.LayoutOrder = layoutOrder
	createUICorner(card, 14)
	createUIStroke(card, 1, 0.85, Color3.fromRGB(229, 231, 235))
	
	-- Left emoji circle
	local emojiCircle = Instance.new("Frame")
	emojiCircle.Size = UDim2.new(0, 46, 0, 46)
	emojiCircle.Position = UDim2.new(0, 14, 0.5, -23)
	emojiCircle.BackgroundColor3 = Color3.fromRGB(255, 247, 237)
	emojiCircle.Parent = card
	createUICorner(emojiCircle, 23)
	
	local emojiLabel = Instance.new("TextLabel")
	emojiLabel.Size = UDim2.fromScale(1, 1)
	emojiLabel.BackgroundTransparency = 1
	emojiLabel.Font = Fonts.Body
	emojiLabel.TextSize = 24
	emojiLabel.Text = gig.emoji
	emojiLabel.Parent = emojiCircle
	
	-- Gig info
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0.5, 0, 0, 20)
	titleLabel.Position = UDim2.new(0, 70, 0, 14)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Fonts.Title
	titleLabel.TextSize = 14
	titleLabel.TextColor3 = Colors.TextBlack
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = gig.title
	titleLabel.Parent = card
	
	local payLabel = Instance.new("TextLabel")
	payLabel.Size = UDim2.new(0.5, 0, 0, 16)
	payLabel.Position = UDim2.new(0, 70, 0, 34)
	payLabel.BackgroundTransparency = 1
	payLabel.Font = Fonts.BodyMedium
	payLabel.TextSize = 12
	payLabel.TextColor3 = Colors.FreelanceOrange
	payLabel.TextXAlignment = Enum.TextXAlignment.Left
	payLabel.Text = "💰 " .. gig.payRange
	payLabel.Parent = card
	
	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(0.5, 0, 0, 16)
	descLabel.Position = UDim2.new(0, 70, 0, 52)
	descLabel.BackgroundTransparency = 1
	descLabel.Font = Fonts.Body
	descLabel.TextSize = 11
	descLabel.TextColor3 = Colors.DarkGray
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextTruncate = Enum.TextTruncate.AtEnd
	descLabel.Text = gig.description
	descLabel.Parent = card
	
	-- Work button
	local workBtn = Instance.new("TextButton")
	workBtn.Name = "WorkBtn"
	workBtn.Size = UDim2.new(0, 70, 0, 32)
	workBtn.AnchorPoint = Vector2.new(1, 0.5)
	workBtn.Position = UDim2.new(1, -14, 0.5, 0)
	workBtn.BackgroundColor3 = Colors.FreelanceOrange
	workBtn.Font = Fonts.Button
	workBtn.TextSize = 12
	workBtn.TextColor3 = Colors.White
	workBtn.Text = "Work"
	workBtn.AutoButtonColor = false
	workBtn.Parent = card
	createPillCorner(workBtn)
	
	workBtn.MouseEnter:Connect(function()
		tween(workBtn, TweenInfo.new(0.15), { BackgroundColor3 = Colors.FreelanceOrangeDark })
	end)
	workBtn.MouseLeave:Connect(function()
		tween(workBtn, TweenInfo.new(0.15), { BackgroundColor3 = Colors.FreelanceOrange })
	end)
	
	return card
end

function OccupationScreen:createSpecialCareersSection()
	local section, layout = self:createSectionHeader(
		self.contentScroll, 
		"Special Careers", 
		"⭐", 
		Colors.SpecialGold, 
		5
	)
	
	for i, career in ipairs(SpecialCareers) do
		local careerCard = self:createSpecialCareerCard(career, i + 1)
		careerCard.Parent = section
	end
end

function OccupationScreen:createSpecialCareerCard(career, layoutOrder)
	local card = Instance.new("TextButton")
	card.Name = "Special_" .. career.title:gsub(" ", "_")
	card.Size = UDim2.new(1, 0, 0, 70)
	card.BackgroundColor3 = career.color
	card.LayoutOrder = layoutOrder
	card.AutoButtonColor = false
	card.Text = ""
	createUICorner(card, 14)
	
	-- Gradient
	local cardGrad = Instance.new("UIGradient")
	cardGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, career.color),
		ColorSequenceKeypoint.new(1, Color3.new(
			math.max(0, career.color.R - 0.08),
			math.max(0, career.color.G - 0.08),
			math.max(0, career.color.B - 0.08)
		)),
	})
	cardGrad.Rotation = 90
	cardGrad.Parent = card
	
	-- Emoji
	local emojiLabel = Instance.new("TextLabel")
	emojiLabel.Size = UDim2.new(0, 50, 1, 0)
	emojiLabel.Position = UDim2.new(0, 10, 0, 0)
	emojiLabel.BackgroundTransparency = 1
	emojiLabel.Font = Fonts.Body
	emojiLabel.TextSize = 32
	emojiLabel.Text = career.emoji
	emojiLabel.Parent = card
	
	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0.7, 0, 0, 22)
	titleLabel.Position = UDim2.new(0, 65, 0, 14)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Fonts.Title
	titleLabel.TextSize = 16
	titleLabel.TextColor3 = Colors.White
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = career.title
	titleLabel.Parent = card
	
	-- Description
	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(0.7, 0, 0, 18)
	descLabel.Position = UDim2.new(0, 65, 0, 38)
	descLabel.BackgroundTransparency = 1
	descLabel.Font = Fonts.Body
	descLabel.TextSize = 12
	descLabel.TextColor3 = Color3.new(1, 1, 1)
	descLabel.TextTransparency = 0.2
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.Text = career.description
	descLabel.Parent = card
	
	-- Arrow
	local arrow = Instance.new("TextLabel")
	arrow.Size = UDim2.new(0, 30, 1, 0)
	arrow.AnchorPoint = Vector2.new(1, 0)
	arrow.Position = UDim2.new(1, -10, 0, 0)
	arrow.BackgroundTransparency = 1
	arrow.Font = Fonts.Title
	arrow.TextSize = 20
	arrow.TextColor3 = Colors.White
	arrow.Text = "→"
	arrow.Parent = card
	
	-- Hover effect
	card.MouseEnter:Connect(function()
		tween(card, TweenInfo.new(0.15), { Size = UDim2.new(1, 4, 0, 74) })
	end)
	card.MouseLeave:Connect(function()
		tween(card, TweenInfo.new(0.15), { Size = UDim2.new(1, 0, 0, 70) })
	end)
	
	return card
end

----------------------------------------------------------------
-- ACTIONS
----------------------------------------------------------------

function OccupationScreen:applyForJob(job)
	-- TODO: Send to server, handle application logic
	print("Applying for job:", job.title)
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
	
	local t = tween(self.overlay, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		Position = UDim2.new(1, 0, 0, 0)
	})
	
	t.Completed:Connect(function()
		self.overlay.Visible = false
	end)
end

function OccupationScreen:toggle()
	if self.isVisible then
		self:hide()
	else
		self:show()
	end
end

return OccupationScreen
