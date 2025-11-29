-- OccupationScreen.lua
-- Premium BitLife-style Career & Education screen
-- Triple AAA polished UI with beautiful card animations

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
local EnrollEducation = remotesFolder and remotesFolder:WaitForChild("EnrollEducation", 15)
local QuitJob = remotesFolder and remotesFolder:WaitForChild("QuitJob", 15)

-- Job Data (synchronized with server)
local Jobs = {
	{ id = "fastfood", name = "Fast Food Worker", emoji = "🍔", salary = 22000, minAge = 14, requirement = nil },
	{ id = "retail", name = "Retail Associate", emoji = "🛒", salary = 26000, minAge = 16, requirement = nil },
	{ id = "janitor", name = "Janitor", emoji = "🧹", salary = 28000, minAge = 18, requirement = nil },
	{ id = "receptionist", name = "Receptionist", emoji = "📞", salary = 32000, minAge = 18, requirement = "High School" },
	{ id = "office", name = "Office Assistant", emoji = "💼", salary = 35000, minAge = 18, requirement = "High School" },
	{ id = "accountant_jr", name = "Junior Accountant", emoji = "📊", salary = 48000, minAge = 22, requirement = "Bachelor's" },
	{ id = "marketing", name = "Marketing Associate", emoji = "📢", salary = 52000, minAge = 22, requirement = "Bachelor's" },
	{ id = "developer", name = "Software Developer", emoji = "💻", salary = 85000, minAge = 22, requirement = "Bachelor's" },
	{ id = "senior_dev", name = "Senior Developer", emoji = "👨‍💻", salary = 140000, minAge = 26, requirement = "Bachelor's" },
	{ id = "doctor", name = "Doctor", emoji = "👨‍⚕️", salary = 250000, minAge = 30, requirement = "Medical School" },
	{ id = "lawyer", name = "Lawyer", emoji = "⚖️", salary = 180000, minAge = 28, requirement = "Law School" },
}

-- Education (only manual enrollment options)
local Education = {
	{ id = "community", name = "Community College", emoji = "🏫", cost = 15000, minAge = 18, maxAge = 99, duration = "2 years", requirement = "High School" },
	{ id = "bachelor", name = "Bachelor's Degree", emoji = "🎓", cost = 80000, minAge = 18, maxAge = 99, duration = "4 years", requirement = "High School" },
	{ id = "master", name = "Master's Degree", emoji = "📜", cost = 60000, minAge = 22, maxAge = 99, duration = "2 years", requirement = "Bachelor's" },
	{ id = "medical", name = "Medical School", emoji = "🏥", cost = 200000, minAge = 22, maxAge = 45, duration = "4 years", requirement = "Bachelor's" },
	{ id = "law", name = "Law School", emoji = "⚖️", cost = 150000, minAge = 22, maxAge = 50, duration = "3 years", requirement = "Bachelor's" },
	{ id = "phd", name = "PhD Program", emoji = "🎓", cost = 100000, minAge = 24, maxAge = 99, duration = "5 years", requirement = "Master's" },
}

function OccupationScreen.new(screenGui, blurOverlay, showBlurFunc, hideBlurFunc, playerState)
	local self = setmetatable({}, OccupationScreen)
	self.screenGui = screenGui
	self.playerState = playerState or {}
	self.showBlur = showBlurFunc
	self.hideBlur = hideBlurFunc
	self.isVisible = false
	self.currentTab = "jobs"
	self:createUI()
	return self
end

function OccupationScreen:updateState(newState)
	if newState then self.playerState = newState end
end

function OccupationScreen:getAge()
	local state = self.playerState
	if not state then return 0 end
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
	if state.Education then
		if type(state.Education) == "table" then
			return state.Education.level or state.Education.schoolLevel or "None"
		end
		return state.Education
	end
	if state.Career and state.Career.education then return state.Career.education end
	local flags = state.Flags or {}
	if flags.college_graduate or flags.has_degree then return "College" end
	if flags.high_school_graduate then return "High School" end
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
		title = "💼 Career & Education",
		color = C.Navy,
		colorDark = C.NavyDark,
		zIndex = 85
	})
	self.header = headerData.header
	headerData.closeButton.MouseButton1Click:Connect(function() self:hide() end)
	
	-- Hover effects for close button
	headerData.closeButton.MouseEnter:Connect(function()
		UI.tween(headerData.closeButton, TweenInfo.new(0.12), { BackgroundTransparency = 0 })
	end)
	headerData.closeButton.MouseLeave:Connect(function()
		UI.tween(headerData.closeButton, TweenInfo.new(0.12), { BackgroundTransparency = 0.1 })
	end)
	
	-- Info bar
	self.infoBar = UI.createInfoBar(self.overlay, { topOffset = 116, zIndex = 84 })
	
	self.ageChip = UI.createInfoChip(self.infoBar, {
		name = "AgeChip", icon = "👤", text = "Age 0",
		bgColor = C.BluePale, textColor = C.BlueDark, order = 1, width = 88
	})
	self.moneyChip = UI.createInfoChip(self.infoBar, {
		name = "MoneyChip", icon = "💵", text = "$0",
		bgColor = C.GreenPale, textColor = C.GreenDark, order = 2, width = 95
	})
	self.eduChip = UI.createInfoChip(self.infoBar, {
		name = "EduChip", icon = "🎓", text = "None",
		bgColor = C.PurplePale, textColor = C.PurpleDark, order = 3, width = 95
	})
	
	-- Tab bar
	self.tabBar = UI.createTabBar(self.overlay, { topOffset = 176, zIndex = 84 })
	self.tabBtns = {}
	
	local tabs = {
		{ id = "jobs", text = "💼 Jobs", color = C.Navy },
		{ id = "education", text = "🎓 Education", color = C.Purple }
	}
	
	for i, tab in ipairs(tabs) do
		local btn = UI.createTabButton(self.tabBar, {
			id = tab.id, text = tab.text, color = tab.color,
			active = i == 1, order = i, width = 0.47, zIndex = 84
		})
		self.tabBtns[tab.id] = { btn = btn, color = tab.color }
		btn.MouseButton1Click:Connect(function() self:switchTab(tab.id) end)
	end
	
	-- Scroll area
	self.contentScroll = UI.createScrollArea(self.overlay, { topOffset = 240, zIndex = 81 })
	
	-- Result modal
	self:createResultModal()
	
	-- Initial populate
	self:populateJobs()
end

function OccupationScreen:createResultModal()
	self.resultModal = UI.createModalCard(self.screenGui, {
		name = "OccupationResult",
		accentColor = C.Green,
		accentDark = C.GreenDark,
		accentPale = C.GreenPale,
		emoji = "🎉",
		title = "Success!",
		buttonText = "Continue",
		zIndex = 96
	})
	
	-- Close handlers
	self.resultModal.closeArea.MouseButton1Click:Connect(function()
		UI.hideModal(self.resultModal, function() self:switchTab(self.currentTab) end)
	end)
	self.resultModal.okButton.MouseButton1Click:Connect(function()
		UI.hideModal(self.resultModal, function() self:switchTab(self.currentTab) end)
	end)
	
	-- Button hover
	self.resultModal.okButton.MouseEnter:Connect(function()
		UI.tween(self.resultModal.okButton, TweenInfo.new(0.1), {
			BackgroundColor3 = self.resultModal.shell.BackgroundColor3:Lerp(C.Black, 0.15)
		})
	end)
	self.resultModal.okButton.MouseLeave:Connect(function()
		UI.tween(self.resultModal.okButton, TweenInfo.new(0.1), {
			BackgroundColor3 = self.resultModal.shell.BackgroundColor3
		})
	end)
end

function OccupationScreen:updateInfoBar()
	self.ageChip.text.Text = "Age " .. self:getAge()
	self.moneyChip.text.Text = UI.formatMoney(self:getMoney())
	self.eduChip.text.Text = self:getEducation() or "None"
end

function OccupationScreen:switchTab(tabId)
	self.currentTab = tabId
	
	for id, data in pairs(self.tabBtns) do
		local isActive = id == tabId
		UI.tween(data.btn, TweenInfo.new(0.15), {
			BackgroundColor3 = isActive and data.color or C.White,
			TextColor3 = isActive and C.White or C.Gray600
		})
	end
	
	-- Clear and repopulate
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
	local currentJob = self:getCurrentJob()
	
	-- Current Job Section (if has job)
	if currentJob then
		local currentSection = UI.createSectionCard(self.contentScroll, {
			name = "CurrentJob",
			title = "Current Job",
			subtitle = "Your career",
			accentColor = C.Green,
			badgeWidth = 110,
			order = 0,
			zIndex = 82
		})
		
		for _, job in ipairs(Jobs) do
			if job.id == currentJob or job.name == currentJob then
				self:createJobCard(currentSection, job, 1, true)
				break
			end
		end
	end
	
	-- Available Jobs Section
	local jobsSection = UI.createSectionCard(self.contentScroll, {
		name = "AvailableJobs",
		title = "Job Listings",
		subtitle = #Jobs .. " positions",
		accentColor = C.Navy,
		badgeWidth = 105,
		order = 1,
		zIndex = 82
	})
	
	for i, job in ipairs(Jobs) do
		if job.id ~= currentJob and job.name ~= currentJob then
			self:createJobCard(jobsSection, job, i + 1, false)
		end
	end
end

function OccupationScreen:createJobCard(parent, job, order, isCurrent)
	local age = self:getAge()
	local edu = self:getEducation()
	
	local meetsAge = age >= job.minAge
	local meetsEdu = not job.requirement or edu == job.requirement or 
		(edu == "College" and job.requirement == "High School") or
		(edu == "Bachelor's" and job.requirement == "High School") or
		(edu == "Master's" and (job.requirement == "High School" or job.requirement == "Bachelor's"))
	local canApply = meetsAge and meetsEdu and not isCurrent
	
	local card = Instance.new("Frame")
	card.Name = job.id
	card.Size = UDim2.new(1, 0, 0, 100)
	card.BackgroundColor3 = C.White
	card.LayoutOrder = order
	card.ZIndex = 83
	card.Parent = parent
	UI.corner(card, 16)
	UI.stroke(card, isCurrent and 2 or 1, isCurrent and 0.3 or 0.88, isCurrent and C.Green or C.Gray200)
	
	-- Gradient overlay for current job
	if isCurrent then
		local glow = Instance.new("Frame")
		glow.Size = UDim2.fromScale(1, 1)
		glow.BackgroundColor3 = C.GreenPale
		glow.BackgroundTransparency = 0.7
		glow.ZIndex = 83
		glow.Parent = card
		UI.corner(glow, 16)
	end
	
	-- Icon frame with gradient
	local iconFrame = Instance.new("Frame")
	iconFrame.Size = UDim2.new(0, 60, 0, 60)
	iconFrame.Position = UDim2.new(0, 16, 0.5, -30)
	iconFrame.BackgroundColor3 = isCurrent and C.GreenPale or C.NavyPale
	iconFrame.ZIndex = 84
	iconFrame.Parent = card
	UI.corner(iconFrame, 16)
	
	if not isCurrent then
		UI.gradient(iconFrame, C.NavyPale, Color3.fromRGB(199, 210, 254), 135)
	end
	
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.fromScale(1, 1)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Font = F.Body
	iconLabel.TextSize = 32
	iconLabel.Text = job.emoji
	iconLabel.ZIndex = 85
	iconLabel.Parent = iconFrame
	
	-- Current badge
	if isCurrent then
		local badge = Instance.new("Frame")
		badge.Size = UDim2.new(0, 95, 0, 24)
		badge.Position = UDim2.new(0, 90, 0, 10)
		badge.BackgroundColor3 = C.Green
		badge.ZIndex = 85
		badge.Parent = card
		UI.pill(badge)
		
		local badgeLabel = Instance.new("TextLabel")
		badgeLabel.Size = UDim2.fromScale(1, 1)
		badgeLabel.BackgroundTransparency = 1
		badgeLabel.Font = F.Button
		badgeLabel.TextSize = 11
		badgeLabel.TextColor3 = C.White
		badgeLabel.Text = "✓ EMPLOYED"
		badgeLabel.ZIndex = 86
		badgeLabel.Parent = badge
	end
	
	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0.5, 0, 0, 24)
	titleLabel.Position = UDim2.new(0, 90, 0, isCurrent and 36 or 14)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = F.Title
	titleLabel.TextSize = 16
	titleLabel.TextColor3 = C.Gray900
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = job.name
	titleLabel.ZIndex = 84
	titleLabel.Parent = card
	
	-- Salary badge
	local salaryBadge = Instance.new("Frame")
	salaryBadge.Size = UDim2.new(0, 90, 0, 26)
	salaryBadge.Position = UDim2.new(0, 90, 0, isCurrent and 62 or 42)
	salaryBadge.BackgroundColor3 = C.GreenPale
	salaryBadge.ZIndex = 84
	salaryBadge.Parent = card
	UI.pill(salaryBadge)
	
	local salaryLabel = Instance.new("TextLabel")
	salaryLabel.Size = UDim2.fromScale(1, 1)
	salaryLabel.BackgroundTransparency = 1
	salaryLabel.Font = F.Medium
	salaryLabel.TextSize = 12
	salaryLabel.TextColor3 = C.GreenDark
	salaryLabel.Text = "💵 " .. UI.formatMoney(job.salary) .. "/yr"
	salaryLabel.ZIndex = 85
	salaryLabel.Parent = salaryBadge
	
	-- Requirements (if not current)
	if not isCurrent then
		local reqText = "Age " .. job.minAge .. "+"
		if job.requirement then reqText = reqText .. " • " .. job.requirement end
		
		local reqLabel = Instance.new("TextLabel")
		reqLabel.Size = UDim2.new(0.45, 0, 0, 18)
		reqLabel.Position = UDim2.new(0, 90, 0, 70)
		reqLabel.BackgroundTransparency = 1
		reqLabel.Font = F.Body
		reqLabel.TextSize = 11
		reqLabel.TextColor3 = canApply and C.Gray500 or C.Red
		reqLabel.TextXAlignment = Enum.TextXAlignment.Left
		reqLabel.Text = reqText
		reqLabel.ZIndex = 84
		reqLabel.Parent = card
	end
	
	-- Action button
	local actionBtn = Instance.new("TextButton")
	actionBtn.Size = UDim2.new(0, isCurrent and 80 or 78, 0, 46)
	actionBtn.AnchorPoint = Vector2.new(1, 0.5)
	actionBtn.Position = UDim2.new(1, -14, 0.5, 0)
	actionBtn.BackgroundColor3 = isCurrent and C.Red or (canApply and C.Navy or C.Gray300)
	actionBtn.Font = F.Button
	actionBtn.TextSize = 14
	actionBtn.TextColor3 = (isCurrent or canApply) and C.White or C.Gray500
	actionBtn.AutoButtonColor = false
	actionBtn.ZIndex = 84
	actionBtn.Parent = card
	UI.corner(actionBtn, 14)
	
	if isCurrent then
		actionBtn.Text = "Quit"
		actionBtn.MouseButton1Click:Connect(function()
			self:quitJob()
		end)
	elseif canApply then
		actionBtn.Text = "Apply"
		actionBtn.MouseEnter:Connect(function()
			UI.tween(actionBtn, TweenInfo.new(0.12), { 
				Size = UDim2.new(0, 84, 0, 50),
				BackgroundColor3 = C.NavyDark
			})
		end)
		actionBtn.MouseLeave:Connect(function()
			UI.tween(actionBtn, TweenInfo.new(0.12), { 
				Size = UDim2.new(0, 78, 0, 46),
				BackgroundColor3 = C.Navy
			})
		end)
		actionBtn.MouseButton1Click:Connect(function()
			self:applyJob(job)
		end)
	else
		actionBtn.Text = not meetsAge and "Age " .. job.minAge or "Need Edu"
	end
	
	-- Card hover effect (if not current)
	if not isCurrent then
		card.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				UI.tween(card, TweenInfo.new(0.15), { BackgroundColor3 = C.Gray50 })
			end
		end)
		card.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				UI.tween(card, TweenInfo.new(0.15), { BackgroundColor3 = C.White })
			end
		end)
	end
end

function OccupationScreen:populateEducation()
	self:updateInfoBar()
	
	local age = self:getAge()
	local money = self:getMoney()
	local currentEdu = self:getEducation()
	
	-- Auto education info
	local infoCard = Instance.new("Frame")
	infoCard.Size = UDim2.new(1, 0, 0, 70)
	infoCard.BackgroundColor3 = C.BluePale
	infoCard.LayoutOrder = 0
	infoCard.ZIndex = 82
	infoCard.Parent = self.contentScroll
	UI.corner(infoCard, 16)
	UI.stroke(infoCard, 1, 0.8, C.BlueLight)
	
	local infoIcon = Instance.new("TextLabel")
	infoIcon.Size = UDim2.new(0, 50, 0, 50)
	infoIcon.Position = UDim2.new(0, 12, 0.5, -25)
	infoIcon.BackgroundTransparency = 1
	infoIcon.Font = F.Body
	infoIcon.TextSize = 28
	infoIcon.Text = "📚"
	infoIcon.ZIndex = 83
	infoIcon.Parent = infoCard
	
	local infoText = Instance.new("TextLabel")
	infoText.Size = UDim2.new(1, -80, 1, -16)
	infoText.Position = UDim2.new(0, 65, 0, 8)
	infoText.BackgroundTransparency = 1
	infoText.Font = F.Body
	infoText.TextSize = 13
	infoText.TextColor3 = C.BlueDark
	infoText.TextXAlignment = Enum.TextXAlignment.Left
	infoText.TextWrapped = true
	infoText.Text = "Elementary, Middle, and High School are automatic! Enroll below for higher education."
	infoText.ZIndex = 83
	infoText.Parent = infoCard
	
	-- Education Section
	local eduSection = UI.createSectionCard(self.contentScroll, {
		name = "HigherEducation",
		title = "Higher Education",
		subtitle = #Education .. " programs",
		accentColor = C.Purple,
		badgeWidth = 130,
		order = 1,
		zIndex = 82
	})
	
	for i, edu in ipairs(Education) do
		self:createEducationCard(eduSection, edu, i)
	end
end

function OccupationScreen:createEducationCard(parent, edu, order)
	local age = self:getAge()
	local money = self:getMoney()
	local currentEdu = self:getEducation()
	
	local meetsAge = age >= edu.minAge and age <= (edu.maxAge or 100)
	local canAfford = money >= (edu.cost or 0)
	local meetsReq = not edu.requirement or currentEdu == edu.requirement or
		(currentEdu == "Bachelor's" and edu.requirement == "High School") or
		(currentEdu == "Master's" and (edu.requirement == "High School" or edu.requirement == "Bachelor's")) or
		(currentEdu == "PhD" and (edu.requirement == "High School" or edu.requirement == "Bachelor's" or edu.requirement == "Master's"))
	local alreadyHas = currentEdu == edu.name:gsub("'s", ""):gsub(" Degree", ""):gsub(" Program", "")
	local canEnroll = meetsAge and canAfford and meetsReq and not alreadyHas
	
	local card = Instance.new("Frame")
	card.Name = edu.id
	card.Size = UDim2.new(1, 0, 0, 105)
	card.BackgroundColor3 = C.White
	card.LayoutOrder = order
	card.ZIndex = 83
	card.Parent = parent
	UI.corner(card, 16)
	UI.stroke(card, alreadyHas and 2 or 1, alreadyHas and 0.3 or 0.88, alreadyHas and C.Purple or C.Gray200)
	
	-- Icon
	local iconFrame = Instance.new("Frame")
	iconFrame.Size = UDim2.new(0, 60, 0, 60)
	iconFrame.Position = UDim2.new(0, 16, 0.5, -30)
	iconFrame.BackgroundColor3 = alreadyHas and C.PurplePale or C.NavyPale
	iconFrame.ZIndex = 84
	iconFrame.Parent = card
	UI.corner(iconFrame, 16)
	
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.fromScale(1, 1)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Font = F.Body
	iconLabel.TextSize = 32
	iconLabel.Text = edu.emoji
	iconLabel.ZIndex = 85
	iconLabel.Parent = iconFrame
	
	-- Completed badge
	if alreadyHas then
		local badge = Instance.new("Frame")
		badge.Size = UDim2.new(0, 105, 0, 24)
		badge.Position = UDim2.new(0, 90, 0, 10)
		badge.BackgroundColor3 = C.Purple
		badge.ZIndex = 85
		badge.Parent = card
		UI.pill(badge)
		
		local badgeLabel = Instance.new("TextLabel")
		badgeLabel.Size = UDim2.fromScale(1, 1)
		badgeLabel.BackgroundTransparency = 1
		badgeLabel.Font = F.Button
		badgeLabel.TextSize = 11
		badgeLabel.TextColor3 = C.White
		badgeLabel.Text = "✓ COMPLETED"
		badgeLabel.ZIndex = 86
		badgeLabel.Parent = badge
	end
	
	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0.5, 0, 0, 24)
	titleLabel.Position = UDim2.new(0, 90, 0, alreadyHas and 36 or 12)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = F.Title
	titleLabel.TextSize = 16
	titleLabel.TextColor3 = C.Gray900
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = edu.name
	titleLabel.ZIndex = 84
	titleLabel.Parent = card
	
	-- Badges row
	local badgeY = alreadyHas and 64 or 40
	
	-- Duration badge
	local durBadge = Instance.new("Frame")
	durBadge.Size = UDim2.new(0, 70, 0, 24)
	durBadge.Position = UDim2.new(0, 90, 0, badgeY)
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
	durLabel.Text = "⏱️ " .. edu.duration
	durLabel.ZIndex = 85
	durLabel.Parent = durBadge
	
	-- Cost badge
	if edu.cost > 0 then
		local costBadge = Instance.new("Frame")
		costBadge.Size = UDim2.new(0, 80, 0, 24)
		costBadge.Position = UDim2.new(0, 165, 0, badgeY)
		costBadge.BackgroundColor3 = canAfford and C.AmberPale or C.RedPale
		costBadge.ZIndex = 84
		costBadge.Parent = card
		UI.pill(costBadge)
		
		local costLabel = Instance.new("TextLabel")
		costLabel.Size = UDim2.fromScale(1, 1)
		costLabel.BackgroundTransparency = 1
		costLabel.Font = F.Medium
		costLabel.TextSize = 11
		costLabel.TextColor3 = canAfford and C.AmberDark or C.RedDark
		costLabel.Text = "💵 " .. UI.formatMoney(edu.cost)
		costLabel.ZIndex = 85
		costLabel.Parent = costBadge
	end
	
	-- Requirements
	if not alreadyHas then
		local reqText = "Age " .. edu.minAge .. "-" .. edu.maxAge
		if edu.requirement then reqText = reqText .. " • Req: " .. edu.requirement end
		
		local reqLabel = Instance.new("TextLabel")
		reqLabel.Size = UDim2.new(0.5, 0, 0, 18)
		reqLabel.Position = UDim2.new(0, 90, 0, badgeY + 28)
		reqLabel.BackgroundTransparency = 1
		reqLabel.Font = F.Body
		reqLabel.TextSize = 11
		reqLabel.TextColor3 = canEnroll and C.Gray500 or C.Red
		reqLabel.TextXAlignment = Enum.TextXAlignment.Left
		reqLabel.Text = reqText
		reqLabel.ZIndex = 84
		reqLabel.Parent = card
	end
	
	-- Enroll button
	if not alreadyHas then
		local enrollBtn = Instance.new("TextButton")
		enrollBtn.Size = UDim2.new(0, 78, 0, 46)
		enrollBtn.AnchorPoint = Vector2.new(1, 0.5)
		enrollBtn.Position = UDim2.new(1, -14, 0.5, 0)
		enrollBtn.BackgroundColor3 = canEnroll and C.Purple or C.Gray300
		enrollBtn.Font = F.Button
		enrollBtn.TextSize = 14
		enrollBtn.TextColor3 = canEnroll and C.White or C.Gray500
		enrollBtn.AutoButtonColor = false
		enrollBtn.ZIndex = 84
		enrollBtn.Parent = card
		UI.corner(enrollBtn, 14)
		
		if canEnroll then
			enrollBtn.Text = "Enroll"
			enrollBtn.MouseEnter:Connect(function()
				UI.tween(enrollBtn, TweenInfo.new(0.12), { 
					Size = UDim2.new(0, 84, 0, 50),
					BackgroundColor3 = C.PurpleDark
				})
			end)
			enrollBtn.MouseLeave:Connect(function()
				UI.tween(enrollBtn, TweenInfo.new(0.12), { 
					Size = UDim2.new(0, 78, 0, 46),
					BackgroundColor3 = C.Purple
				})
			end)
			enrollBtn.MouseButton1Click:Connect(function()
				self:enrollEducation(edu)
			end)
		else
			enrollBtn.Text = not meetsAge and "Age" or (not canAfford and "Need $" or "Need " .. (edu.requirement or ""))
		end
	end
end

function OccupationScreen:applyJob(job)
	if not ApplyForJob then
		self:showResult(false, "Server not available", "❌")
		return
	end
	
	local result = ApplyForJob:InvokeServer(job.id)
	if result then
		self:showResult(result.success, result.message, result.success and "🎉" or "😔")
	else
		self:showResult(false, "Server error", "❌")
	end
end

function OccupationScreen:quitJob()
	if not QuitJob then
		self:showResult(false, "Server not available", "❌")
		return
	end
	
	local result = QuitJob:InvokeServer()
	if result then
		self:showResult(result.success, result.message, result.success and "👋" or "😔")
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

function OccupationScreen:showResult(success, message, emoji)
	local shellColor = success and C.Green or C.Red
	local shellStroke = success and C.GreenDark or C.RedDark
	local pale = success and C.GreenPale or C.RedPale
	
	self.resultModal.shell.BackgroundColor3 = shellColor
	self.resultModal.shellStroke.Color = shellStroke
	self.resultModal.emojiFrame.BackgroundColor3 = pale
	self.resultModal.emojiLabel.Text = emoji or (success and "🎉" or "😔")
	self.resultModal.titleLabel.Text = success and "Success!" or "Uh oh..."
	self.resultModal.titleLabel.TextColor3 = success and C.GreenDark or C.RedDark
	self.resultModal.messageLabel.Text = message or ""
	self.resultModal.okButton.BackgroundColor3 = shellColor
	
	UI.showModal(self.resultModal)
end

function OccupationScreen:show()
	self:updateInfoBar()
	self:switchTab(self.currentTab)
	UI.slideInScreen(self.overlay, "right")
	self.isVisible = true
end

function OccupationScreen:hide()
	UI.slideOutScreen(self.overlay, "right", function()
		self.resultModal.overlay.Visible = false
	end)
	self.isVisible = false
end

return OccupationScreen
