-- OccupationScreen.lua
-- BitLife-style Occupation screen with SERVER VALIDATION
-- Uses remotes for all actions - no more 4 year old lawyers!

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OccupationScreen = {}
OccupationScreen.__index = OccupationScreen

----------------------------------------------------------------
-- REMOTES
----------------------------------------------------------------

local remotesFolder = ReplicatedStorage:WaitForChild("LifeRemotes", 10)
local ApplyForJob = remotesFolder and remotesFolder:FindFirstChild("ApplyForJob")
local DoWork = remotesFolder and remotesFolder:FindFirstChild("DoWork")
local EnrollEducation = remotesFolder and remotesFolder:FindFirstChild("EnrollEducation")
local DoFreelance = remotesFolder and remotesFolder:FindFirstChild("DoFreelance")
local TrySpecialCareer = remotesFolder and remotesFolder:FindFirstChild("TrySpecialCareer")
local QuitJob = remotesFolder and remotesFolder:FindFirstChild("QuitJob")

----------------------------------------------------------------
-- COLORS
----------------------------------------------------------------

local Colors = {
	BitLifeBlue      = Color3.fromRGB(37, 99, 235),
	BitLifeBlueDark  = Color3.fromRGB(29, 78, 216),
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
-- DATA WITH AGE REQUIREMENTS
----------------------------------------------------------------

local JobListings = {
	{ id = "fastfood", title = "Fast Food Worker", emoji = "🍔", company = "Burger Palace", salary = 22000, education = "None", minAge = 14, exp = 0 },
	{ id = "retail", title = "Retail Associate", emoji = "🛒", company = "MegaMart", salary = 26000, education = "None", minAge = 16, exp = 0 },
	{ id = "janitor", title = "Janitor", emoji = "🧹", company = "CleanCo", salary = 28000, education = "None", minAge = 18, exp = 0 },
	{ id = "receptionist", title = "Receptionist", emoji = "📞", company = "Corp Office", salary = 32000, education = "High School", minAge = 18, exp = 0 },
	{ id = "office", title = "Office Assistant", emoji = "📎", company = "Business Solutions", salary = 35000, education = "High School", minAge = 18, exp = 1 },
	{ id = "accountant_jr", title = "Jr. Accountant", emoji = "📊", company = "Financial Svcs", salary = 48000, education = "Bachelor's", minAge = 22, exp = 1 },
	{ id = "marketing", title = "Marketing Associate", emoji = "📢", company = "AdVenture", salary = 52000, education = "Bachelor's", minAge = 22, exp = 2 },
	{ id = "developer", title = "Software Developer", emoji = "💻", company = "TechStart", salary = 85000, education = "Bachelor's", minAge = 22, exp = 2 },
	{ id = "senior_dev", title = "Senior Developer", emoji = "👨‍💻", company = "BigTech", salary = 140000, education = "Bachelor's", minAge = 26, exp = 5 },
	{ id = "doctor", title = "Doctor", emoji = "🩺", company = "City Hospital", salary = 250000, education = "Medical School", minAge = 30, exp = 8 },
	{ id = "lawyer", title = "Lawyer", emoji = "⚖️", company = "Smith & Co", salary = 180000, education = "Law School", minAge = 28, exp = 5 },
}

local EducationOptions = {
	{ id = "highschool", name = "High School Diploma", emoji = "🎓", duration = "4 years", cost = 0, minAge = 14, maxAge = 18, requirement = "None" },
	{ id = "community", name = "Community College", emoji = "📚", duration = "2 years", cost = 15000, minAge = 18, maxAge = 99, requirement = "High School" },
	{ id = "bachelor", name = "Bachelor's Degree", emoji = "🎓", duration = "4 years", cost = 80000, minAge = 18, maxAge = 99, requirement = "High School" },
	{ id = "master", name = "Master's Degree", emoji = "📜", duration = "2 years", cost = 60000, minAge = 22, maxAge = 99, requirement = "Bachelor's" },
	{ id = "medical", name = "Medical School", emoji = "🏥", duration = "4 years", cost = 200000, minAge = 22, maxAge = 45, requirement = "Bachelor's" },
	{ id = "law", name = "Law School", emoji = "⚖️", duration = "3 years", cost = 150000, minAge = 22, maxAge = 50, requirement = "Bachelor's" },
	{ id = "phd", name = "PhD Program", emoji = "🔬", duration = "5 years", cost = 100000, minAge = 24, maxAge = 99, requirement = "Master's" },
}

local FreelanceGigs = {
	{ id = "dog_walking", name = "Walk Dogs", emoji = "🐕", payRange = "$20-50", minAge = 10 },
	{ id = "mow_lawns", name = "Mow Lawns", emoji = "🌿", payRange = "$40-100", minAge = 10 },
	{ id = "babysit", name = "Babysit", emoji = "👶", payRange = "$50-120", minAge = 12 },
	{ id = "tutor", name = "Tutor Students", emoji = "📖", payRange = "$30-75", minAge = 14 },
	{ id = "food_delivery", name = "Deliver Food", emoji = "🚴", payRange = "$30-80", minAge = 16 },
	{ id = "writing", name = "Freelance Writing", emoji = "✍️", payRange = "$100-500", minAge = 16 },
	{ id = "design", name = "Graphic Design", emoji = "🎨", payRange = "$150-800", minAge = 16 },
	{ id = "rideshare", name = "Drive Rideshare", emoji = "🚗", payRange = "$50-150", minAge = 21 },
}

local SpecialCareers = {
	{ id = "business", name = "Start a Business", emoji = "🏢", description = "Become an entrepreneur", minAge = 18 },
	{ id = "actor", name = "Become an Actor", emoji = "🎭", description = "Hollywood dreams", minAge = 16 },
	{ id = "athlete", name = "Pro Athlete", emoji = "⚽", description = "Go pro in sports", minAge = 18 },
	{ id = "musician", name = "Music Career", emoji = "🎤", description = "Become a musician", minAge = 14 },
	{ id = "influencer", name = "Social Media Star", emoji = "📱", description = "Become an influencer", minAge = 13 },
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
	return "$" .. string.format("%d", amount / 1000) .. "K/yr"
end

local function formatMoney(amount)
	if amount >= 1000 then return "$" .. string.format("%.0fK", amount / 1000) end
	return "$" .. amount
end

----------------------------------------------------------------
-- SCREEN
----------------------------------------------------------------

function OccupationScreen.new(screenGui, blurOverlay, showBlurFunc, hideBlurFunc, playerState)
	local self = setmetatable({}, OccupationScreen)
	
	self.screenGui = screenGui
	self.playerState = playerState
	self.isVisible = false
	
	self:createUI()
	self:createConfirmModal()
	self:createResultModal()
	
	return self
end

function OccupationScreen:getPlayerAge()
	return self.playerState and self.playerState.Age or 0
end

function OccupationScreen:getPlayerMoney()
	return self.playerState and self.playerState.Money or 0
end

function OccupationScreen:getPlayerEducation()
	return self.playerState and self.playerState.Education or "None"
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
	
	-- Player Info Bar
	local infoBar = Instance.new("Frame")
	infoBar.Size = UDim2.new(1, -32, 0, 50)
	infoBar.Position = UDim2.new(0, 16, 0, 70)
	infoBar.BackgroundColor3 = Colors.CardWhite
	infoBar.ZIndex = 82
	infoBar.Parent = self.overlay
	createUICorner(infoBar, 12)
	createUIStroke(infoBar, 1, 0.8, Colors.MediumGray)
	
	self.infoLabel = Instance.new("TextLabel")
	self.infoLabel.Size = UDim2.fromScale(1, 1)
	self.infoLabel.BackgroundTransparency = 1
	self.infoLabel.Font = Fonts.Body
	self.infoLabel.TextSize = 13
	self.infoLabel.TextColor3 = Colors.DarkGray
	self.infoLabel.Text = "Loading..."
	self.infoLabel.ZIndex = 83
	self.infoLabel.Parent = infoBar
	
	-- Content
	local contentScroll = Instance.new("ScrollingFrame")
	contentScroll.Size = UDim2.new(1, 0, 1, -130)
	contentScroll.Position = UDim2.new(0, 0, 0, 130)
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
	
	self:createJobListingsSection(1)
	self:createEducationSection(2)
	self:createFreelanceSection(3)
	self:createSpecialSection(4)
end

function OccupationScreen:updateInfoBar()
	local age = self:getPlayerAge()
	local money = self:getPlayerMoney()
	local edu = self:getPlayerEducation()
	self.infoLabel.Text = "📅 Age: " .. age .. " | 💰 Money: $" .. money .. " | 🎓 Education: " .. edu
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
	card.Name = "Job_" .. job.id
	card.Size = UDim2.new(1, 0, 0, 90)
	card.BackgroundColor3 = Colors.CardWhite
	card.LayoutOrder = order
	card.Parent = parent
	createUICorner(card, 14)
	createUIStroke(card, 1, 0.85, Color3.fromRGB(229, 231, 235))
	
	local emoji = Instance.new("TextLabel")
	emoji.Size = UDim2.new(0, 40, 0, 40)
	emoji.Position = UDim2.new(0, 12, 0.5, -20)
	emoji.BackgroundTransparency = 1
	emoji.Font = Fonts.Body
	emoji.TextSize = 28
	emoji.Text = job.emoji
	emoji.Parent = card
	
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(0.5, 0, 0, 18)
	title.Position = UDim2.new(0, 58, 0, 10)
	title.BackgroundTransparency = 1
	title.Font = Fonts.Title
	title.TextSize = 14
	title.TextColor3 = Colors.TextBlack
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = job.title
	title.Parent = card
	
	local company = Instance.new("TextLabel")
	company.Size = UDim2.new(0.5, 0, 0, 14)
	company.Position = UDim2.new(0, 58, 0, 28)
	company.BackgroundTransparency = 1
	company.Font = Fonts.Body
	company.TextSize = 11
	company.TextColor3 = Colors.MediumGray
	company.TextXAlignment = Enum.TextXAlignment.Left
	company.Text = "🏢 " .. job.company
	company.Parent = card
	
	local reqs = Instance.new("TextLabel")
	reqs.Size = UDim2.new(0.6, 0, 0, 14)
	reqs.Position = UDim2.new(0, 58, 0, 44)
	reqs.BackgroundTransparency = 1
	reqs.Font = Fonts.Body
	reqs.TextSize = 10
	reqs.TextColor3 = Colors.MediumGray
	reqs.TextXAlignment = Enum.TextXAlignment.Left
	reqs.Text = "📜 " .. job.education .. " | Age " .. job.minAge .. "+" .. (job.exp > 0 and (" | " .. job.exp .. "yr exp") or "")
	reqs.Parent = card
	
	local salary = Instance.new("TextLabel")
	salary.Size = UDim2.new(0.5, 0, 0, 16)
	salary.Position = UDim2.new(0, 58, 0, 62)
	salary.BackgroundTransparency = 1
	salary.Font = Fonts.Title
	salary.TextSize = 13
	salary.TextColor3 = Colors.SuccessGreen
	salary.TextXAlignment = Enum.TextXAlignment.Left
	salary.Text = formatSalary(job.salary)
	salary.Parent = card
	
	local applyBtn = Instance.new("TextButton")
	applyBtn.Size = UDim2.new(0, 60, 0, 32)
	applyBtn.AnchorPoint = Vector2.new(1, 0.5)
	applyBtn.Position = UDim2.new(1, -12, 0.5, 0)
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
		self:showConfirm("job", job)
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
	card.Name = "Edu_" .. edu.id
	card.Size = UDim2.new(1, 0, 0, 80)
	card.BackgroundColor3 = Colors.CardWhite
	card.LayoutOrder = order
	card.Parent = parent
	createUICorner(card, 14)
	createUIStroke(card, 1, 0.85, Color3.fromRGB(229, 231, 235))
	
	local emoji = Instance.new("TextLabel")
	emoji.Size = UDim2.new(0, 40, 0, 40)
	emoji.Position = UDim2.new(0, 12, 0.5, -20)
	emoji.BackgroundTransparency = 1
	emoji.Font = Fonts.Body
	emoji.TextSize = 26
	emoji.Text = edu.emoji
	emoji.Parent = card
	
	local name = Instance.new("TextLabel")
	name.Size = UDim2.new(0.5, 0, 0, 18)
	name.Position = UDim2.new(0, 58, 0, 12)
	name.BackgroundTransparency = 1
	name.Font = Fonts.Title
	name.TextSize = 13
	name.TextColor3 = Colors.TextBlack
	name.TextXAlignment = Enum.TextXAlignment.Left
	name.Text = edu.name
	name.Parent = card
	
	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(0.6, 0, 0, 14)
	info.Position = UDim2.new(0, 58, 0, 30)
	info.BackgroundTransparency = 1
	info.Font = Fonts.Body
	info.TextSize = 10
	info.TextColor3 = Colors.MediumGray
	info.TextXAlignment = Enum.TextXAlignment.Left
	info.Text = "⏱️ " .. edu.duration .. " | Age " .. edu.minAge .. "-" .. edu.maxAge .. " | Req: " .. edu.requirement
	info.Parent = card
	
	local cost = Instance.new("TextLabel")
	cost.Size = UDim2.new(0.5, 0, 0, 16)
	cost.Position = UDim2.new(0, 58, 0, 48)
	cost.BackgroundTransparency = 1
	cost.Font = Fonts.Title
	cost.TextSize = 12
	cost.TextColor3 = edu.cost > 0 and Colors.ErrorRed or Colors.SuccessGreen
	cost.TextXAlignment = Enum.TextXAlignment.Left
	cost.Text = edu.cost > 0 and formatMoney(edu.cost) or "FREE"
	cost.Parent = card
	
	local enrollBtn = Instance.new("TextButton")
	enrollBtn.Size = UDim2.new(0, 60, 0, 32)
	enrollBtn.AnchorPoint = Vector2.new(1, 0.5)
	enrollBtn.Position = UDim2.new(1, -12, 0.5, 0)
	enrollBtn.BackgroundColor3 = Colors.EducationPurple
	enrollBtn.Font = Fonts.Button
	enrollBtn.TextSize = 11
	enrollBtn.TextColor3 = Colors.White
	enrollBtn.Text = "Enroll"
	enrollBtn.AutoButtonColor = false
	enrollBtn.Parent = card
	createPillCorner(enrollBtn)
	
	enrollBtn.MouseEnter:Connect(function() tween(enrollBtn, TweenInfo.new(0.1), { BackgroundColor3 = Colors.EducationPurpleDark }) end)
	enrollBtn.MouseLeave:Connect(function() tween(enrollBtn, TweenInfo.new(0.1), { BackgroundColor3 = Colors.EducationPurple }) end)
	
	enrollBtn.MouseButton1Click:Connect(function()
		self:showConfirm("education", edu)
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
		self:createFreelanceCard(gig, i + 1, section)
	end
end

function OccupationScreen:createFreelanceCard(gig, order, parent)
	local card = Instance.new("Frame")
	card.Name = "Gig_" .. gig.id
	card.Size = UDim2.new(1, 0, 0, 60)
	card.BackgroundColor3 = Colors.CardWhite
	card.LayoutOrder = order
	card.Parent = parent
	createUICorner(card, 14)
	createUIStroke(card, 1, 0.85, Color3.fromRGB(229, 231, 235))
	
	local emoji = Instance.new("TextLabel")
	emoji.Size = UDim2.new(0, 36, 0, 36)
	emoji.Position = UDim2.new(0, 12, 0.5, -18)
	emoji.BackgroundTransparency = 1
	emoji.Font = Fonts.Body
	emoji.TextSize = 24
	emoji.Text = gig.emoji
	emoji.Parent = card
	
	local name = Instance.new("TextLabel")
	name.Size = UDim2.new(0.4, 0, 0, 18)
	name.Position = UDim2.new(0, 54, 0, 10)
	name.BackgroundTransparency = 1
	name.Font = Fonts.Title
	name.TextSize = 13
	name.TextColor3 = Colors.TextBlack
	name.TextXAlignment = Enum.TextXAlignment.Left
	name.Text = gig.name
	name.Parent = card
	
	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(0.5, 0, 0, 14)
	info.Position = UDim2.new(0, 54, 0, 30)
	info.BackgroundTransparency = 1
	info.Font = Fonts.Body
	info.TextSize = 11
	info.TextColor3 = Colors.SuccessGreen
	info.TextXAlignment = Enum.TextXAlignment.Left
	info.Text = "💰 " .. gig.payRange .. " | Age " .. gig.minAge .. "+"
	info.Parent = card
	
	local doBtn = Instance.new("TextButton")
	doBtn.Size = UDim2.new(0, 50, 0, 28)
	doBtn.AnchorPoint = Vector2.new(1, 0.5)
	doBtn.Position = UDim2.new(1, -12, 0.5, 0)
	doBtn.BackgroundColor3 = Colors.FreelanceGreen
	doBtn.Font = Fonts.Button
	doBtn.TextSize = 11
	doBtn.TextColor3 = Colors.White
	doBtn.Text = "Do It"
	doBtn.AutoButtonColor = false
	doBtn.Parent = card
	createPillCorner(doBtn)
	
	doBtn.MouseButton1Click:Connect(function()
		self:doFreelanceAction(gig)
	end)
end

function OccupationScreen:createSpecialSection(order)
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
	card.Name = "Special_" .. career.id
	card.Size = UDim2.new(1, 0, 0, 60)
	card.BackgroundColor3 = Colors.CardWhite
	card.LayoutOrder = order
	card.Parent = parent
	createUICorner(card, 14)
	createUIStroke(card, 1, 0.85, Color3.fromRGB(229, 231, 235))
	
	local emoji = Instance.new("TextLabel")
	emoji.Size = UDim2.new(0, 36, 0, 36)
	emoji.Position = UDim2.new(0, 12, 0.5, -18)
	emoji.BackgroundTransparency = 1
	emoji.Font = Fonts.Body
	emoji.TextSize = 24
	emoji.Text = career.emoji
	emoji.Parent = card
	
	local name = Instance.new("TextLabel")
	name.Size = UDim2.new(0.4, 0, 0, 18)
	name.Position = UDim2.new(0, 54, 0, 10)
	name.BackgroundTransparency = 1
	name.Font = Fonts.Title
	name.TextSize = 13
	name.TextColor3 = Colors.TextBlack
	name.TextXAlignment = Enum.TextXAlignment.Left
	name.Text = career.name
	name.Parent = card
	
	local desc = Instance.new("TextLabel")
	desc.Size = UDim2.new(0.5, 0, 0, 14)
	desc.Position = UDim2.new(0, 54, 0, 30)
	desc.BackgroundTransparency = 1
	desc.Font = Fonts.Body
	desc.TextSize = 11
	desc.TextColor3 = Colors.MediumGray
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.Text = career.description .. " | Age " .. career.minAge .. "+"
	desc.Parent = card
	
	local tryBtn = Instance.new("TextButton")
	tryBtn.Size = UDim2.new(0, 50, 0, 28)
	tryBtn.AnchorPoint = Vector2.new(1, 0.5)
	tryBtn.Position = UDim2.new(1, -12, 0.5, 0)
	tryBtn.BackgroundColor3 = Colors.SpecialGold
	tryBtn.Font = Fonts.Button
	tryBtn.TextSize = 11
	tryBtn.TextColor3 = Colors.TextBlack
	tryBtn.Text = "Try"
	tryBtn.AutoButtonColor = false
	tryBtn.Parent = card
	createPillCorner(tryBtn)
	
	tryBtn.MouseButton1Click:Connect(function()
		self:trySpecialAction(career)
	end)
end

function OccupationScreen:createConfirmModal()
	self.confirmOverlay = Instance.new("Frame")
	self.confirmOverlay.Name = "ConfirmOverlay"
	self.confirmOverlay.Size = UDim2.fromScale(1, 1)
	self.confirmOverlay.BackgroundColor3 = Colors.OverlayDark
	self.confirmOverlay.BackgroundTransparency = 0.4
	self.confirmOverlay.Visible = false
	self.confirmOverlay.ZIndex = 90
	self.confirmOverlay.Parent = self.screenGui
	
	self.confirmModal = Instance.new("Frame")
	self.confirmModal.Size = UDim2.new(0, 320, 0, 0)
	self.confirmModal.AutomaticSize = Enum.AutomaticSize.Y
	self.confirmModal.AnchorPoint = Vector2.new(0.5, 0.5)
	self.confirmModal.Position = UDim2.fromScale(0.5, 0.5)
	self.confirmModal.BackgroundColor3 = Colors.CardWhite
	self.confirmModal.ZIndex = 91
	self.confirmModal.Parent = self.confirmOverlay
	createUICorner(self.confirmModal, 20)
	createUIPadding(self.confirmModal, 24, 24, 24, 24)
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 12)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = self.confirmModal
	
	self.confirmEmoji = Instance.new("TextLabel")
	self.confirmEmoji.Size = UDim2.new(0, 50, 0, 50)
	self.confirmEmoji.BackgroundTransparency = 1
	self.confirmEmoji.Font = Fonts.Body
	self.confirmEmoji.TextSize = 40
	self.confirmEmoji.Text = "💼"
	self.confirmEmoji.LayoutOrder = 1
	self.confirmEmoji.Parent = self.confirmModal
	
	self.confirmTitle = Instance.new("TextLabel")
	self.confirmTitle.Size = UDim2.new(1, 0, 0, 24)
	self.confirmTitle.BackgroundTransparency = 1
	self.confirmTitle.Font = Fonts.Title
	self.confirmTitle.TextSize = 18
	self.confirmTitle.TextColor3 = Colors.TextBlack
	self.confirmTitle.Text = "Confirm"
	self.confirmTitle.LayoutOrder = 2
	self.confirmTitle.Parent = self.confirmModal
	
	self.confirmDesc = Instance.new("TextLabel")
	self.confirmDesc.Size = UDim2.new(1, 0, 0, 0)
	self.confirmDesc.AutomaticSize = Enum.AutomaticSize.Y
	self.confirmDesc.BackgroundTransparency = 1
	self.confirmDesc.Font = Fonts.Body
	self.confirmDesc.TextSize = 13
	self.confirmDesc.TextColor3 = Colors.DarkGray
	self.confirmDesc.TextWrapped = true
	self.confirmDesc.Text = ""
	self.confirmDesc.LayoutOrder = 3
	self.confirmDesc.Parent = self.confirmModal
	
	local btnContainer = Instance.new("Frame")
	btnContainer.Size = UDim2.new(1, 0, 0, 44)
	btnContainer.BackgroundTransparency = 1
	btnContainer.LayoutOrder = 4
	btnContainer.Parent = self.confirmModal
	
	local btnLayout = Instance.new("UIListLayout")
	btnLayout.FillDirection = Enum.FillDirection.Horizontal
	btnLayout.Padding = UDim.new(0, 12)
	btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	btnLayout.Parent = btnContainer
	
	local cancelBtn = Instance.new("TextButton")
	cancelBtn.Size = UDim2.new(0.45, 0, 1, 0)
	cancelBtn.BackgroundColor3 = Colors.LightGray
	cancelBtn.Font = Fonts.Button
	cancelBtn.TextSize = 14
	cancelBtn.TextColor3 = Colors.DarkGray
	cancelBtn.Text = "Cancel"
	cancelBtn.AutoButtonColor = false
	cancelBtn.Parent = btnContainer
	createPillCorner(cancelBtn)
	cancelBtn.MouseButton1Click:Connect(function() self:hideConfirm() end)
	
	self.confirmBtn = Instance.new("TextButton")
	self.confirmBtn.Size = UDim2.new(0.45, 0, 1, 0)
	self.confirmBtn.BackgroundColor3 = Colors.BitLifeBlue
	self.confirmBtn.Font = Fonts.Button
	self.confirmBtn.TextSize = 14
	self.confirmBtn.TextColor3 = Colors.White
	self.confirmBtn.Text = "Confirm"
	self.confirmBtn.AutoButtonColor = false
	self.confirmBtn.Parent = btnContainer
	createPillCorner(self.confirmBtn)
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
	self.resultEmoji.Size = UDim2.new(0, 50, 0, 50)
	self.resultEmoji.BackgroundTransparency = 1
	self.resultEmoji.Font = Fonts.Body
	self.resultEmoji.TextSize = 40
	self.resultEmoji.Text = "✅"
	self.resultEmoji.LayoutOrder = 1
	self.resultEmoji.Parent = self.resultModal
	
	self.resultTitle = Instance.new("TextLabel")
	self.resultTitle.Size = UDim2.new(1, 0, 0, 24)
	self.resultTitle.BackgroundTransparency = 1
	self.resultTitle.Font = Fonts.Title
	self.resultTitle.TextSize = 18
	self.resultTitle.TextColor3 = Colors.SuccessGreen
	self.resultTitle.Text = "Success!"
	self.resultTitle.LayoutOrder = 2
	self.resultTitle.Parent = self.resultModal
	
	self.resultText = Instance.new("TextLabel")
	self.resultText.Size = UDim2.new(1, 0, 0, 0)
	self.resultText.AutomaticSize = Enum.AutomaticSize.Y
	self.resultText.BackgroundTransparency = 1
	self.resultText.Font = Fonts.Body
	self.resultText.TextSize = 14
	self.resultText.TextColor3 = Colors.DarkerGray
	self.resultText.TextWrapped = true
	self.resultText.Text = ""
	self.resultText.LayoutOrder = 3
	self.resultText.Parent = self.resultModal
	
	local okBtn = Instance.new("TextButton")
	okBtn.Size = UDim2.new(1, 0, 0, 44)
	okBtn.BackgroundColor3 = Colors.BitLifeBlue
	okBtn.Font = Fonts.Button
	okBtn.TextSize = 15
	okBtn.TextColor3 = Colors.White
	okBtn.Text = "OK"
	okBtn.AutoButtonColor = false
	okBtn.LayoutOrder = 4
	okBtn.Parent = self.resultModal
	createPillCorner(okBtn)
	okBtn.MouseButton1Click:Connect(function() self:hideResult() end)
end

function OccupationScreen:showConfirm(actionType, data)
	self.currentAction = actionType
	self.currentData = data
	
	if actionType == "job" then
		self.confirmEmoji.Text = data.emoji
		self.confirmTitle.Text = "Apply for " .. data.title .. "?"
		self.confirmDesc.Text = "Company: " .. data.company .. "\nSalary: " .. formatSalary(data.salary) .. "\nRequirements: " .. data.education .. ", Age " .. data.minAge .. "+"
		self.confirmBtn.Text = "Apply"
		self.confirmBtn.BackgroundColor3 = Colors.JobOrange
	elseif actionType == "education" then
		self.confirmEmoji.Text = data.emoji
		self.confirmTitle.Text = "Enroll in " .. data.name .. "?"
		self.confirmDesc.Text = "Duration: " .. data.duration .. "\nCost: " .. (data.cost > 0 and formatMoney(data.cost) or "FREE") .. "\nAge: " .. data.minAge .. "-" .. data.maxAge .. "\nRequirement: " .. data.requirement
		self.confirmBtn.Text = "Enroll"
		self.confirmBtn.BackgroundColor3 = Colors.EducationPurple
	end
	
	if self.confirmConn then self.confirmConn:Disconnect() end
	self.confirmConn = self.confirmBtn.MouseButton1Click:Connect(function()
		self:hideConfirm()
		task.delay(0.2, function()
			self:executeAction()
		end)
	end)
	
	self.confirmOverlay.Visible = true
	tween(self.confirmModal, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.fromScale(0.5, 0.5) })
end

function OccupationScreen:hideConfirm()
	self.confirmOverlay.Visible = false
end

function OccupationScreen:executeAction()
	local result
	
	if self.currentAction == "job" and ApplyForJob then
		result = ApplyForJob:InvokeServer(self.currentData.id)
	elseif self.currentAction == "education" and EnrollEducation then
		result = EnrollEducation:InvokeServer(self.currentData.id)
	else
		result = { success = false, message = "Server not available" }
	end
	
	self:showResult(result)
end

function OccupationScreen:doFreelanceAction(gig)
	if DoFreelance then
		local result = DoFreelance:InvokeServer(gig.id)
		self:showResult(result)
	else
		self:showResult({ success = false, message = "Server not available" })
	end
end

function OccupationScreen:trySpecialAction(career)
	if TrySpecialCareer then
		local result = TrySpecialCareer:InvokeServer(career.id)
		self:showResult(result)
	else
		self:showResult({ success = false, message = "Server not available" })
	end
end

function OccupationScreen:showResult(result)
	self.resultEmoji.Text = result.success and "✅" or "❌"
	self.resultTitle.Text = result.success and "Success!" or "Failed"
	self.resultTitle.TextColor3 = result.success and Colors.SuccessGreen or Colors.ErrorRed
	self.resultText.Text = result.message or ""
	
	self.resultOverlay.Visible = true
	tween(self.resultModal, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.fromScale(0.5, 0.5) })
end

function OccupationScreen:hideResult()
	self.resultOverlay.Visible = false
end

function OccupationScreen:show()
	if self.isVisible then return end
	self.isVisible = true
	self:updateInfoBar()
	self.overlay.Visible = true
	self.overlay.Position = UDim2.new(1, 0, 0, 0)
	tween(self.overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.new(0, 0, 0, 0) })
end

function OccupationScreen:hide()
	if not self.isVisible then return end
	self.isVisible = false
	self.confirmOverlay.Visible = false
	self.resultOverlay.Visible = false
	local t = tween(self.overlay, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Position = UDim2.new(1, 0, 0, 0) })
	t.Completed:Connect(function() self.overlay.Visible = false end)
end

function OccupationScreen:toggle()
	if self.isVisible then self:hide() else self:show() end
end

return OccupationScreen
