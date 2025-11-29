-- LifeState.lua
-- Server-side representation of a player's life state.
-- Enhanced with relationships, education, assets, health conditions, achievements, and more.

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

function LifeState.new(player)
	local self = setmetatable({}, LifeState)

	self.PlayerId = player.UserId

	-- Basic Info
	self.Name = nil
	self.Gender = nil
	self.Sexuality = nil -- "Straight", "Gay", "Bisexual", etc.
	self.BirthCountry = "United States"
	self.CurrentCountry = "United States"

	-- Time
	self.Age = 0
	self.Year = 2025
	self.BirthYear = 2025

	-- Finances
	self.Money = 0
	self.BankBalance = 0
	self.Debt = 0
	self.NetWorth = 0

	-- Core Stats
	self.Stats = {
		Happiness = 80,
		Health = 80,
		Looks = 70,
		Smarts = 70,
	}

	-- Additional Stats
	self.Karma = 50 -- 0-100, affects random events
	self.Willpower = 50 -- Affects resisting addictions, temptations
	self.Fame = 0 -- 0-100, public recognition
	self.Craziness = 20 -- Affects wild event outcomes
	self.Fertility = 100 -- Ability to have children

	-- Feed/History
	self.Feed = {}
	self.LifeHistory = {} -- Important life milestones

	-- Job System
	self.Job = nil -- { id, title, company, salary, emoji, yearsWorked, performance }
	self.JobHistory = {} -- Past jobs
	self.TotalEarnings = 0
	self.YearsEmployed = 0

	-- Education System
	self.Education = {
		CurrentSchool = nil, -- { type, name, yearsCompleted, gpa }
		HighSchoolGraduate = false,
		HighSchoolGPA = 0,
		College = nil, -- { name, major, yearsCompleted, gpa }
		CollegeGraduate = false,
		CollegeDegree = nil,
		GraduateSchool = nil,
		GraduateDegree = nil,
		Certifications = {},
		DriversLicense = false,
		PilotsLicense = false,
		BoatingLicense = false,
	}

	-- Relationships
	self.Relationships = {
		-- Family
		Father = nil, -- { name, age, relationship, alive, health }
		Mother = nil,
		Siblings = {},
		Children = {},
		
		-- Romantic
		Partner = nil, -- { name, age, relationship, yearsTogether, married }
		ExPartners = {},
		
		-- Social
		Friends = {},
		Enemies = {},
		
		-- Counts
		TotalRelationships = 0,
		TotalMarriages = 0,
		TotalDivorces = 0,
	}

	-- Crime System
	self.InJail = false
	self.JailYearsLeft = 0
	self.CrimeRecord = 0
	self.CrimesCommitted = {} -- { crimeId, year, caught }
	self.TotalTimeServed = 0
	self.OnProbation = false
	self.ProbationYearsLeft = 0
	self.Notoriety = 0 -- Criminal reputation

	-- Health System
	self.HealthConditions = {} -- { condition, severity, yearsHad, treatable }
	self.Addictions = {} -- { substance, severity, yearsAddicted }
	self.MentalHealth = {
		Depression = false,
		Anxiety = false,
		Stress = 0,
	}
	self.PhysicalFitness = 50
	self.Diet = "Normal" -- "Healthy", "Normal", "Unhealthy", "Vegan", etc.
	self.SleepQuality = 70
	self.DoctorVisitsThisYear = 0
	self.Surgeries = {}

	-- Assets & Property
	self.Assets = {
		Vehicles = {}, -- { type, make, model, year, value, condition }
		Properties = {}, -- { type, location, value, mortgage }
		Jewelry = {},
		Collections = {},
		Investments = {}, -- { type, value, returns }
	}
	self.TotalAssetValue = 0
	self.RentExpense = 0
	self.LivingSituation = "With Parents" -- "With Parents", "Renting", "Own Home", "Homeless"

	-- Achievements & Milestones
	self.Achievements = {}
	self.Milestones = {
		FirstKiss = false,
		FirstDate = false,
		FirstJob = false,
		FirstCar = false,
		FirstHome = false,
		LostVirginity = false,
		GotMarried = false,
		HadChildren = false,
		Retired = false,
	}

	-- Flags for event tracking
	self.Flags = {}
	
	-- Story progress tracking
	self.StoryProgress = {
		PresidentPath = 0,
		CriminalPath = 0,
		CelebrityPath = 0,
		AthletePath = 0,
		BusinessPath = 0,
	}

	-- Skills & Talents
	self.Skills = {
		Cooking = 0,
		Music = 0,
		Art = 0,
		Writing = 0,
		Martial_Arts = 0,
		Dancing = 0,
		Public_Speaking = 0,
		Programming = 0,
		Photography = 0,
		Gaming = 0,
		Acting = 0,
		Fitness = 0,
	}

	-- Military Service
	self.Military = {
		Enlisted = false,
		Branch = nil,
		Rank = nil,
		YearsServed = 0,
		Deployed = false,
		Veteran = false,
		Discharged = false,
		DischargeType = nil,
	}

	-- Social Media & Fame
	self.SocialMedia = {
		Followers = 0,
		Posts = 0,
		Verified = false,
		Platform = nil,
	}

	-- Gambling & Lottery
	self.GamblingStats = {
		TotalWagered = 0,
		TotalWon = 0,
		TotalLost = 0,
		BiggestWin = 0,
		CasinoVisits = 0,
	}

	-- Legacy
	self.Legacy = {
		Will = nil,
		Inheritance = 0,
		InheritanceReceived = 0,
		Generations = 1,
	}

	-- Activity counters for this year
	self.YearlyActivities = {
		GymVisits = 0,
		LibraryVisits = 0,
		PartyAttendances = 0,
		DatesThisYear = 0,
		CrimesThisYear = 0,
	}

	return self
end

----------------------------------------------------------------
-- FEED METHODS
----------------------------------------------------------------

function LifeState:AddFeed(text)
	table.insert(self.Feed, text)
	
	-- Keep feed manageable
	if #self.Feed > 100 then
		table.remove(self.Feed, 1)
	end
end

function LifeState:AddMilestone(text)
	table.insert(self.LifeHistory, {
		year = self.Year,
		age = self.Age,
		text = text,
	})
end

----------------------------------------------------------------
-- STAT METHODS
----------------------------------------------------------------

function LifeState:ClampStats()
	for key, value in pairs(self.Stats) do
		self.Stats[key] = clamp(math.floor(value), 0, 100)
	end
	
	-- Clamp additional stats
	self.Karma = clamp(self.Karma, 0, 100)
	self.Willpower = clamp(self.Willpower, 0, 100)
	self.Fame = clamp(self.Fame, 0, 100)
	self.Craziness = clamp(self.Craziness, 0, 100)
	self.Fertility = clamp(self.Fertility, 0, 100)
	self.PhysicalFitness = clamp(self.PhysicalFitness, 0, 100)
	self.SleepQuality = clamp(self.SleepQuality, 0, 100)
	self.Notoriety = clamp(self.Notoriety, 0, 100)
end

function LifeState:ModifyStat(statName, amount)
	if self.Stats[statName] ~= nil then
		self.Stats[statName] = self.Stats[statName] + amount
		self:ClampStats()
		return true
	end
	return false
end

function LifeState:GetStat(statName)
	return self.Stats[statName] or 0
end

----------------------------------------------------------------
-- FLAG METHODS
----------------------------------------------------------------

function LifeState:SetFlag(flagName, value)
	self.Flags[flagName] = value
end

function LifeState:GetFlag(flagName)
	return self.Flags[flagName]
end

function LifeState:HasFlag(flagName)
	return self.Flags[flagName] ~= nil and self.Flags[flagName] == true
end

----------------------------------------------------------------
-- MONEY METHODS
----------------------------------------------------------------

function LifeState:AddMoney(amount)
	self.Money = self.Money + amount
	if amount > 0 then
		self.TotalEarnings = self.TotalEarnings + amount
	end
	self:UpdateNetWorth()
end

function LifeState:SubtractMoney(amount)
	self.Money = self.Money - amount
	self:UpdateNetWorth()
end

function LifeState:UpdateNetWorth()
	self.NetWorth = self.Money + self.BankBalance - self.Debt + self.TotalAssetValue
end

function LifeState:CanAfford(amount)
	return self.Money >= amount
end

----------------------------------------------------------------
-- RELATIONSHIP METHODS
----------------------------------------------------------------

function LifeState:AddRelationship(category, person)
	if category == "Friend" then
		table.insert(self.Relationships.Friends, person)
	elseif category == "Enemy" then
		table.insert(self.Relationships.Enemies, person)
	elseif category == "Child" then
		table.insert(self.Relationships.Children, person)
	elseif category == "Sibling" then
		table.insert(self.Relationships.Siblings, person)
	elseif category == "ExPartner" then
		table.insert(self.Relationships.ExPartners, person)
	end
	self.Relationships.TotalRelationships = self.Relationships.TotalRelationships + 1
end

function LifeState:GetPartner()
	return self.Relationships.Partner
end

function LifeState:IsMarried()
	return self.Relationships.Partner ~= nil and self.Relationships.Partner.married == true
end

function LifeState:GetChildCount()
	return #self.Relationships.Children
end

----------------------------------------------------------------
-- EDUCATION METHODS
----------------------------------------------------------------

function LifeState:IsInSchool()
	return self.Education.CurrentSchool ~= nil
end

function LifeState:HasDegree(degreeType)
	if degreeType == "HighSchool" then
		return self.Education.HighSchoolGraduate
	elseif degreeType == "College" then
		return self.Education.CollegeGraduate
	elseif degreeType == "Graduate" then
		return self.Education.GraduateDegree ~= nil
	end
	return false
end

function LifeState:GetEducationLevel()
	if self.Education.GraduateDegree then
		return "Graduate"
	elseif self.Education.CollegeGraduate then
		return "College"
	elseif self.Education.HighSchoolGraduate then
		return "High School"
	elseif self.Age >= 5 then
		return "In School"
	else
		return "None"
	end
end

----------------------------------------------------------------
-- HEALTH METHODS
----------------------------------------------------------------

function LifeState:AddHealthCondition(condition, severity, treatable)
	table.insert(self.HealthConditions, {
		condition = condition,
		severity = severity or "Mild",
		yearsHad = 0,
		treatable = treatable ~= false,
		treated = false,
	})
end

function LifeState:HasCondition(conditionName)
	for _, cond in ipairs(self.HealthConditions) do
		if cond.condition == conditionName then
			return true
		end
	end
	return false
end

function LifeState:AddAddiction(substance, severity)
	self.Addictions[substance] = {
		severity = severity or 1,
		yearsAddicted = 0,
	}
end

function LifeState:HasAddiction(substance)
	return self.Addictions[substance] ~= nil
end

function LifeState:RemoveAddiction(substance)
	self.Addictions[substance] = nil
end

----------------------------------------------------------------
-- ASSET METHODS
----------------------------------------------------------------

function LifeState:AddVehicle(vehicle)
	table.insert(self.Assets.Vehicles, vehicle)
	self:RecalculateAssetValue()
end

function LifeState:AddProperty(property)
	table.insert(self.Assets.Properties, property)
	self:RecalculateAssetValue()
end

function LifeState:RecalculateAssetValue()
	local total = 0
	
	for _, v in ipairs(self.Assets.Vehicles) do
		total = total + (v.value or 0)
	end
	
	for _, p in ipairs(self.Assets.Properties) do
		total = total + (p.value or 0) - (p.mortgage or 0)
	end
	
	for _, inv in ipairs(self.Assets.Investments) do
		total = total + (inv.value or 0)
	end
	
	self.TotalAssetValue = total
	self:UpdateNetWorth()
end

function LifeState:GetVehicleCount()
	return #self.Assets.Vehicles
end

function LifeState:GetPropertyCount()
	return #self.Assets.Properties
end

function LifeState:OwnsHome()
	for _, p in ipairs(self.Assets.Properties) do
		if p.type == "House" or p.type == "Condo" or p.type == "Mansion" then
			return true
		end
	end
	return false
end

----------------------------------------------------------------
-- SKILL METHODS
----------------------------------------------------------------

function LifeState:ImproveSkill(skillName, amount)
	if self.Skills[skillName] ~= nil then
		self.Skills[skillName] = clamp(self.Skills[skillName] + amount, 0, 100)
		return true
	end
	return false
end

function LifeState:GetSkill(skillName)
	return self.Skills[skillName] or 0
end

----------------------------------------------------------------
-- ACHIEVEMENT METHODS
----------------------------------------------------------------

function LifeState:UnlockAchievement(achievementId, title, description)
	if not self.Achievements[achievementId] then
		self.Achievements[achievementId] = {
			title = title,
			description = description,
			unlockedYear = self.Year,
			unlockedAge = self.Age,
		}
		return true
	end
	return false
end

function LifeState:HasAchievement(achievementId)
	return self.Achievements[achievementId] ~= nil
end

----------------------------------------------------------------
-- STORY PROGRESS METHODS
----------------------------------------------------------------

function LifeState:AdvanceStoryPath(pathName, amount)
	if self.StoryProgress[pathName] ~= nil then
		self.StoryProgress[pathName] = self.StoryProgress[pathName] + (amount or 1)
		return self.StoryProgress[pathName]
	end
	return 0
end

function LifeState:GetStoryProgress(pathName)
	return self.StoryProgress[pathName] or 0
end

function LifeState:IsOnPath(pathName, minProgress)
	return (self.StoryProgress[pathName] or 0) >= (minProgress or 1)
end

----------------------------------------------------------------
-- UTILITY METHODS
----------------------------------------------------------------

function LifeState:GetAgeCategory()
	local age = self.Age
	if age < 3 then
		return "Baby"
	elseif age < 5 then
		return "Toddler"
	elseif age < 13 then
		return "Child"
	elseif age < 18 then
		return "Teen"
	elseif age < 30 then
		return "Young Adult"
	elseif age < 50 then
		return "Adult"
	elseif age < 65 then
		return "Middle Aged"
	else
		return "Senior"
	end
end

function LifeState:IsAdult()
	return self.Age >= 18
end

function LifeState:IsMinor()
	return self.Age < 18
end

function LifeState:CanWork()
	return self.Age >= 14 and not self.InJail
end

function LifeState:CanDrive()
	return self.Age >= 16 and self.Education.DriversLicense
end

function LifeState:CanDrink()
	return self.Age >= 21
end

function LifeState:CanVote()
	return self.Age >= 18
end

function LifeState:CanGamble()
	return self.Age >= 21
end

function LifeState:IsRetired()
	return self.Milestones.Retired
end

function LifeState:GetLifeQuality()
	local stats = self.Stats
	local average = (stats.Happiness + stats.Health + stats.Looks + stats.Smarts) / 4
	
	if average >= 80 then
		return "Excellent"
	elseif average >= 60 then
		return "Good"
	elseif average >= 40 then
		return "Fair"
	elseif average >= 20 then
		return "Poor"
	else
		return "Critical"
	end
end

function LifeState:ResetYearlyCounters()
	self.YearlyActivities = {
		GymVisits = 0,
		LibraryVisits = 0,
		PartyAttendances = 0,
		DatesThisYear = 0,
		CrimesThisYear = 0,
	}
	self.DoctorVisitsThisYear = 0
end

return LifeState
