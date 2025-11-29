-- LifeState.lua
-- Server-side representation of a player's life state with BitLife-style systems
-- Extended with career paths, relationships, assets, and proper helpers

local LifeState = {}
LifeState.__index = LifeState

local function clamp(n, minVal, maxVal)
	if n < minVal then
		return minVal
	elseif n > maxVal then
		return maxVal
	else
		return n
	end
end

local function pickRandom(list)
	if not list or #list == 0 then return nil end
	return list[math.random(1, #list)]
end

----------------------------------------------------------------------
-- CONSTRUCTOR
----------------------------------------------------------------------

function LifeState.new(player)
	local self = setmetatable({}, LifeState)

	self.PlayerId = player.UserId

	-- Basic info
	self.Name = nil
	self.Gender = nil

	-- Time
	self.Age = 0
	self.Year = 2025

	-- Economy
	self.Money = 0

	-- Core stats
	self.Stats = {
		Happiness = 80,
		Health = 80,
		Looks = 70,
		Smarts = 70,
	}

	-- For backwards compatibility, expose stats at top level too
	self.Happiness = 80
	self.Health = 80
	self.Looks = 70
	self.Smarts = 70

	-- Story Flags (for branching narrative)
	self.Flags = {}

	-- Relationships (BitLife-style organized by category)
	self.Relationships = {
		family = {},      -- parents, siblings, children, spouse
		friends = {},     -- friends, best friends
		lovers = {},      -- romantic interests, partners
		coworkers = {},   -- work colleagues
		classmates = {},  -- school/university classmates
		enemies = {},     -- people who hate you
	}

	-- Career & Job System
	self.Career = {
		path = nil,         -- "teacher", "president", "racer", "artist", "hacker", "criminal", etc.
		jobTitle = nil,     -- Current job title
		employer = nil,     -- Current employer name
		salary = 0,         -- Annual salary
		experience = 0,     -- Years of experience
		performance = 50,   -- Job performance rating 0-100
		promotions = 0,     -- Number of promotions received
	}

	-- Legacy job fields (for backwards compatibility)
	self.Job = nil
	self.JobTitle = nil
	self.JobSalary = 0

	-- Education System
	self.Education = {
		level = "none",     -- "none", "elementary", "middle", "highschool", "university", "graduate", "doctorate"
		schoolName = nil,
		university = nil,
		major = nil,
		gpa = 0,
		scholarship = nil,  -- "athletic", "academic", "music", "art", etc.
		graduated = false,
		degrees = {},       -- List of earned degrees
	}

	-- Legacy field
	self.EducationLevel = nil

	-- Assets (BitLife-style)
	self.Assets = {
		cash = 0,           -- Alias for Money
		houses = {},        -- { id, name, value, equity, mortgage, monthlyPayment }
		cars = {},          -- { id, make, model, year, value, condition }
		businesses = {},    -- { id, name, type, value, profitPerYear }
		pets = {},          -- { id, name, type, age, happiness, health }
		investments = {},   -- { id, type, value, shares }
	}

	-- Criminal/Legal status
	self.InJail = false
	self.JailTime = 0
	self.JailSentence = 0
	self.CriminalRecord = {}
	self.WantedLevel = 0
	self.Notoriety = 0  -- Criminal reputation

	-- Health tracking
	self.HealthConditions = {}  -- List of health issues
	self.Addictions = {}        -- Addictions (alcohol, drugs, etc.)
	self.Fitness = 50           -- Fitness level 0-100

	-- Social
	self.Fame = 0               -- 0-100 fame level
	self.SocialMedia = {
		followers = 0,
		platform = nil,
		verified = false,
	}

	-- Event History (for one-time events, cooldowns, milestones)
	self.EventHistory = {
		seenEvents = {},      -- { [eventId] = true }
		lastOccurrence = {},  -- { [eventId] = age }
		milestonesFired = {}, -- { [eventId] = true }
		choicesMade = {},     -- { [eventId] = choiceIndex }
	}

	-- Feed log
	self.Feed = {}

	return self
end

----------------------------------------------------------------------
-- STAT MANAGEMENT
----------------------------------------------------------------------

function LifeState:ClampStats()
	for key, value in pairs(self.Stats) do
		self.Stats[key] = clamp(math.floor(value), 0, 100)
	end
	-- Sync to top-level for backwards compatibility
	self.Happiness = self.Stats.Happiness
	self.Health = self.Stats.Health
	self.Looks = self.Stats.Looks
	self.Smarts = self.Stats.Smarts
end

function LifeState:GetStat(statName)
	return self.Stats[statName] or 0
end

function LifeState:SetStat(statName, value)
	if self.Stats[statName] ~= nil then
		self.Stats[statName] = clamp(value, 0, 100)
		self[statName] = self.Stats[statName]
	end
end

function LifeState:ModifyStat(statName, delta)
	if self.Stats[statName] ~= nil then
		self.Stats[statName] = clamp((self.Stats[statName] or 50) + delta, 0, 100)
		self[statName] = self.Stats[statName]
	end
end

-- Apply multiple stat effects at once
function LifeState:ApplyEffects(effects)
	if not effects then return end

	for stat, delta in pairs(effects) do
		if type(delta) == "number" then
			if stat == "Money" or stat == "Cash" then
				self:AddMoney(delta)
			elseif self.Stats[stat] ~= nil then
				self:ModifyStat(stat, delta)
			end
		end
	end

	self:ClampStats()
end

----------------------------------------------------------------------
-- FLAG MANAGEMENT
----------------------------------------------------------------------

function LifeState:SetFlag(flag, value)
	self.Flags = self.Flags or {}
	self.Flags[flag] = value ~= false
end

function LifeState:ClearFlag(flag)
	if self.Flags then
		self.Flags[flag] = nil
	end
end

function LifeState:HasFlag(flag)
	return self.Flags and self.Flags[flag] == true
end

function LifeState:SetFlags(flagList)
	if not flagList then return end
	for _, flag in ipairs(flagList) do
		self:SetFlag(flag)
	end
end

function LifeState:ClearFlags(flagList)
	if not flagList then return end
	for _, flag in ipairs(flagList) do
		self:ClearFlag(flag)
	end
end

function LifeState:GetAllFlags()
	return self.Flags or {}
end

----------------------------------------------------------------------
-- MONEY MANAGEMENT
----------------------------------------------------------------------

function LifeState:AddMoney(amount)
	self.Money = math.max(0, (self.Money or 0) + amount)
	self.Assets.cash = self.Money
end

function LifeState:RemoveMoney(amount)
	self.Money = math.max(0, (self.Money or 0) - amount)
	self.Assets.cash = self.Money
	return self.Money >= 0
end

function LifeState:HasMoney(amount)
	return (self.Money or 0) >= amount
end

function LifeState:GetNetWorth()
	local total = self.Money or 0

	-- Add house equity
	for _, house in ipairs(self.Assets.houses or {}) do
		total = total + (house.equity or house.value or 0)
	end

	-- Add car values
	for _, car in ipairs(self.Assets.cars or {}) do
		total = total + (car.value or 0)
	end

	-- Add business values
	for _, biz in ipairs(self.Assets.businesses or {}) do
		total = total + (biz.value or 0)
	end

	-- Add investments
	for _, inv in ipairs(self.Assets.investments or {}) do
		total = total + (inv.value or 0)
	end

	return total
end

----------------------------------------------------------------------
-- RELATIONSHIP MANAGEMENT
----------------------------------------------------------------------

function LifeState:AddRelationship(category, person)
	if not self.Relationships[category] then
		self.Relationships[category] = {}
	end

	-- Generate ID if not present
	if not person.id then
		person.id = category .. "_" .. #self.Relationships[category] + 1 .. "_" .. tick()
	end

	-- Set defaults
	person.relationship = person.relationship or 50
	person.met = person.met or self.Age
	person.alive = person.alive ~= false

	table.insert(self.Relationships[category], person)
	return person
end

function LifeState:GetRelationship(category, personId)
	if not self.Relationships[category] then return nil end

	for _, person in ipairs(self.Relationships[category]) do
		if person.id == personId then
			return person
		end
	end
	return nil
end

function LifeState:ModifyRelationship(category, personId, delta)
	local person = self:GetRelationship(category, personId)
	if person then
		person.relationship = clamp((person.relationship or 50) + delta, 0, 100)
		return person.relationship
	end
	return nil
end

function LifeState:GetRandomRelationship(category)
	if not self.Relationships[category] then return nil end
	local alive = {}
	for _, person in ipairs(self.Relationships[category]) do
		if person.alive ~= false then
			table.insert(alive, person)
		end
	end
	return pickRandom(alive)
end

function LifeState:GetAllRelationships()
	local all = {}
	for category, people in pairs(self.Relationships) do
		for _, person in ipairs(people) do
			table.insert(all, { category = category, person = person })
		end
	end
	return all
end

----------------------------------------------------------------------
-- CAREER MANAGEMENT
----------------------------------------------------------------------

function LifeState:SetCareer(path, title, employer, salary)
	self.Career.path = path
	self.Career.jobTitle = title
	self.Career.employer = employer
	self.Career.salary = salary or 0

	-- Backwards compatibility
	self.Job = employer
	self.JobTitle = title
	self.JobSalary = salary or 0
end

function LifeState:ClearCareer()
	self.Career = {
		path = nil,
		jobTitle = nil,
		employer = nil,
		salary = 0,
		experience = self.Career.experience or 0,
		performance = 50,
		promotions = 0,
	}
	self.Job = nil
	self.JobTitle = nil
	self.JobSalary = 0
end

function LifeState:HasJob()
	return self.Career.jobTitle ~= nil or self.Job ~= nil
end

function LifeState:GetAnnualIncome()
	local income = self.Career.salary or self.JobSalary or 0

	-- Add business profits
	for _, biz in ipairs(self.Assets.businesses or {}) do
		income = income + (biz.profitPerYear or 0)
	end

	return income
end

----------------------------------------------------------------------
-- EDUCATION MANAGEMENT
----------------------------------------------------------------------

function LifeState:SetEducation(level, schoolName, major)
	self.Education.level = level
	self.Education.schoolName = schoolName
	self.Education.major = major
	self.EducationLevel = level  -- Backwards compatibility
end

function LifeState:Graduate(degree)
	self.Education.graduated = true
	if degree then
		table.insert(self.Education.degrees, {
			name = degree,
			year = self.Year,
			major = self.Education.major,
		})
	end
end

function LifeState:HasDegree(degreeType)
	for _, degree in ipairs(self.Education.degrees or {}) do
		if degree.name == degreeType then
			return true
		end
	end
	return false
end

----------------------------------------------------------------------
-- ASSET MANAGEMENT
----------------------------------------------------------------------

function LifeState:AddAsset(assetType, asset)
	if not self.Assets[assetType] then
		self.Assets[assetType] = {}
	end

	asset.id = asset.id or assetType .. "_" .. #self.Assets[assetType] + 1 .. "_" .. tick()
	asset.purchaseYear = asset.purchaseYear or self.Year

	table.insert(self.Assets[assetType], asset)
	return asset
end

function LifeState:RemoveAsset(assetType, assetId)
	if not self.Assets[assetType] then return false end

	for i, asset in ipairs(self.Assets[assetType]) do
		if asset.id == assetId then
			table.remove(self.Assets[assetType], i)
			return true
		end
	end
	return false
end

function LifeState:GetAssets(assetType)
	return self.Assets[assetType] or {}
end

----------------------------------------------------------------------
-- CRIMINAL RECORD
----------------------------------------------------------------------

function LifeState:AddCrime(crime)
	table.insert(self.CriminalRecord, {
		crime = crime,
		year = self.Year,
		age = self.Age,
	})
end

function LifeState:HasCriminalRecord()
	return #self.CriminalRecord > 0
end

function LifeState:GoToJail(years)
	self.InJail = true
	self.JailSentence = years
	self.JailTime = years
	self:SetFlag("in_prison")
end

function LifeState:ServeTime(years)
	years = years or 1
	self.JailTime = math.max(0, (self.JailTime or 0) - years)

	if self.JailTime <= 0 then
		self.InJail = false
		self.JailTime = 0
		self:ClearFlag("in_prison")
		self:SetFlag("ex_con")
		return true  -- Released
	end
	return false
end

----------------------------------------------------------------------
-- STORY PROGRESS
----------------------------------------------------------------------

function LifeState:GetStoryProgress(path)
	if path == "political" then
		if self.Flags.president then return 100
		elseif self.Flags.us_senator then return 85
		elseif self.Flags.congressman then return 70
		elseif self.Flags.state_senator then return 50
		elseif self.Flags.elected_official then return 30
		elseif self.Flags.political_experience then return 15
		elseif self.Flags.political_interest then return 5
		else return 0 end

	elseif path == "criminal" then
		if self.Flags.kingpin then return 100
		elseif self.Flags.crime_boss then return 90
		elseif self.Flags.underboss then return 75
		elseif self.Flags.gang_captain then return 60
		elseif self.Flags.gang_member and self.Flags.war_veteran then return 50
		elseif self.Flags.gang_member then return 35
		elseif self.Flags.car_thief then return 20
		elseif self.Flags.criminal_tendencies then return 10
		else return 0 end

	elseif path == "teacher" then
		if self.Flags.superintendent then return 100
		elseif self.Flags.principal then return 75
		elseif self.Flags.department_head then return 50
		elseif self.Flags.teacher then return 30
		elseif self.Flags.teaching_interest then return 10
		else return 0 end

	elseif path == "racer" then
		if self.Flags.racing_legend then return 100
		elseif self.Flags.world_champion then return 85
		elseif self.Flags.f1_driver then return 65
		elseif self.Flags.junior_formula then return 40
		elseif self.Flags.karting_champion then return 20
		elseif self.Flags.racing_interest then return 5
		else return 0 end

	elseif path == "artist" then
		if self.Flags.art_celebrity then return 100
		elseif self.Flags.museum_piece then return 80
		elseif self.Flags.gallery_show then return 55
		elseif self.Flags.art_school then return 30
		elseif self.Flags.art_interest then return 10
		else return 0 end

	elseif path == "hacker" then
		if self.Flags.elite_hacker then return 100
		elseif self.Flags.hacker_group then return 70
		elseif self.Flags.hacker_career then return 45
		elseif self.Flags.black_hat then return 25
		elseif self.Flags.computer_interest then return 10
		else return 0 end
	end

	return 0
end

function LifeState:GetStoryTitle(path)
	if path == "political" then
		if self.Flags.president then return "President"
		elseif self.Flags.us_senator then return "U.S. Senator"
		elseif self.Flags.congressman then return "Congressman"
		elseif self.Flags.state_senator then return "State Senator"
		elseif self.Flags.elected_official then return "City Council"
		elseif self.Flags.political_experience then return "Political Intern"
		elseif self.Flags.political_interest then return "Interested"
		else return "Citizen" end

	elseif path == "criminal" then
		if self.Flags.kingpin then return "Kingpin"
		elseif self.Flags.crime_boss then return "Crime Boss"
		elseif self.Flags.underboss then return "Underboss"
		elseif self.Flags.gang_captain then return "Gang Captain"
		elseif self.Flags.gang_member and self.Flags.war_veteran then return "Made Member"
		elseif self.Flags.gang_member then return "Gang Member"
		elseif self.Flags.car_thief then return "Car Thief"
		elseif self.Flags.criminal_tendencies then return "Petty Criminal"
		else return "Law-Abiding" end

	elseif path == "teacher" then
		if self.Flags.superintendent then return "Superintendent"
		elseif self.Flags.principal then return "Principal"
		elseif self.Flags.department_head then return "Department Head"
		elseif self.Flags.teacher then return "Teacher"
		else return "Student" end

	elseif path == "racer" then
		if self.Flags.racing_legend then return "Racing Legend"
		elseif self.Flags.world_champion then return "World Champion"
		elseif self.Flags.f1_driver then return "F1 Driver"
		elseif self.Flags.junior_formula then return "Junior Driver"
		elseif self.Flags.karting_champion then return "Karting Champ"
		else return "Aspiring Racer" end

	elseif path == "artist" then
		if self.Flags.art_celebrity then return "Art Celebrity"
		elseif self.Flags.museum_piece then return "Famous Artist"
		elseif self.Flags.gallery_show then return "Exhibited Artist"
		elseif self.Flags.art_school then return "Art Student"
		else return "Aspiring Artist" end

	elseif path == "hacker" then
		if self.Flags.elite_hacker then return "Elite Hacker"
		elseif self.Flags.hacker_group then return "Hacker Collective"
		elseif self.Flags.hacker_career then return "Pro Hacker"
		elseif self.Flags.black_hat then return "Black Hat"
		else return "Script Kiddie" end
	end

	return "Unknown"
end

function LifeState:GetActiveCareerPath()
	-- Check which career path is active based on flags
	local paths = {"political", "criminal", "teacher", "racer", "artist", "hacker"}
	local highestProgress = 0
	local activePath = nil

	for _, path in ipairs(paths) do
		local progress = self:GetStoryProgress(path)
		if progress > highestProgress then
			highestProgress = progress
			activePath = path
		end
	end

	return activePath, highestProgress
end

----------------------------------------------------------------------
-- FEED
----------------------------------------------------------------------

function LifeState:AddFeed(text)
	if text and text ~= "" then
		table.insert(self.Feed, {
			text = text,
			year = self.Year,
			age = self.Age,
		})
	end
end

function LifeState:GetRecentFeed(count)
	count = count or 10
	local recent = {}
	local start = math.max(1, #self.Feed - count + 1)
	for i = start, #self.Feed do
		table.insert(recent, self.Feed[i])
	end
	return recent
end

----------------------------------------------------------------------
-- LIFE STAGE
----------------------------------------------------------------------

function LifeState:GetLifeStage()
	local age = self.Age or 0
	if age <= 1 then return "baby"
	elseif age <= 4 then return "toddler"
	elseif age <= 9 then return "early_childhood"
	elseif age <= 12 then return "childhood"
	elseif age <= 15 then return "tween"
	elseif age <= 19 then return "teenage"
	elseif age <= 35 then return "young_adult"
	elseif age <= 60 then return "adult"
	elseif age <= 80 then return "senior"
	else return "elderly"
	end
end

function LifeState:CanWork()
	return self.Age >= 16 and not self.InJail
end

function LifeState:CanDrive()
	return self.Age >= 16
end

function LifeState:CanVote()
	return self.Age >= 18
end

function LifeState:CanDrink()
	return self.Age >= 21
end

function LifeState:IsAdult()
	return self.Age >= 18
end

----------------------------------------------------------------------
-- SERIALIZATION
----------------------------------------------------------------------

function LifeState:Serialize()
	return {
		PlayerId = self.PlayerId,
		Name = self.Name,
		Gender = self.Gender,
		Age = self.Age,
		Year = self.Year,
		Money = self.Money,
		Stats = self.Stats,
		Happiness = self.Stats.Happiness,
		Health = self.Stats.Health,
		Looks = self.Stats.Looks,
		Smarts = self.Stats.Smarts,
		Flags = self.Flags,
		Career = self.Career,
		Education = self.Education,
		InJail = self.InJail,
		JailTime = self.JailTime,
		Fame = self.Fame,
	}
end

return LifeState
