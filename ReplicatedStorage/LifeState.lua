-- LifeState.lua
-- Server-side representation of a player's life state with BitLife-style systems
-- Extended with career paths, relationships, assets, and proper helpers
-- INTEGRATED with EventMemory for comprehensive history tracking

local LifeState = {}
LifeState.__index = LifeState

-- Load EventMemory module for comprehensive player history tracking
local EventMemory = nil
local function loadEventMemory()
	if EventMemory then return EventMemory end
	local success, result = pcall(function()
		return require(script.Parent:WaitForChild("EventMemory", 2))
	end)
	if success and result then
		EventMemory = result
		print("[LifeState] EventMemory module loaded successfully")
	else
		warn("[LifeState] EventMemory module not found, using basic flag tracking")
	end
	return EventMemory
end

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
	
	-- Relationships (FLAT dictionary format for UI compatibility)
	-- RelationshipsScreen expects: state.Relationships["friend_123"] = { type = "friend", name = "...", ... }
	-- Valid types: "friend", "romance", "family", "enemy"
	self.Relationships = {}
	
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

	-- ═══════════════════════════════════════════════════════════════
	-- COMPREHENSIVE EVENT MEMORY (AAA BitLife-style history tracking)
	-- This tracks EVERYTHING the player does for proper event validation
	-- ═══════════════════════════════════════════════════════════════
	local mem = loadEventMemory()
	if mem then
		self.Memory = mem.create()
	else
		-- Fallback if EventMemory module fails to load
		self.Memory = nil
	end

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
-- EVENT MEMORY INTEGRATION (AAA BitLife-style tracking)
----------------------------------------------------------------------

-- Record an event to memory (call this when events occur)
function LifeState:RecordEvent(eventType, data)
	local mem = loadEventMemory()
	if mem and self.Memory then
		mem.recordEvent(self.Memory, eventType, data, self.Age)
		-- Sync memory-derived flags to state flags
		mem.syncToState(self.Memory, self)
	end
end

-- Validate if an event can fire based on player's actual history
function LifeState:ValidateEvent(eventDef)
	local mem = loadEventMemory()
	if mem and self.Memory then
		return mem.validateEvent(eventDef, self, self.Memory)
	end
	return { valid = true, reasons = {} } -- Allow if no memory available
end

-- Get comprehensive life summary from memory
function LifeState:GetLifeSummary()
	local mem = loadEventMemory()
	if mem and self.Memory then
		return mem.getLifeSummary(self.Memory)
	end
	return {}
end

-- Memory-backed validation helpers (use these in events!)
function LifeState:HasEverWorked()
	local mem = loadEventMemory()
	if mem and self.Memory then
		return mem.hasEverWorked(self.Memory)
	end
	-- Fallback to flags
	return self:HasFlag("employed") or self:HasFlag("has_job") or self:HasFlag("ever_worked")
end

function LifeState:IsCurrentlyEmployed()
	local mem = loadEventMemory()
	if mem and self.Memory then
		return mem.isCurrentlyEmployed(self.Memory)
	end
	return self:HasFlag("employed") or self:HasFlag("has_job")
end

function LifeState:HasEducation(level)
	local mem = loadEventMemory()
	if mem and self.Memory then
		return mem.hasEducation(self.Memory, level)
	end
	-- Fallback to Education table
	local educationLevels = {
		none = 0, elementary = 1, middle = 2, high_school = 3, highschool = 3,
		some_college = 4, associate = 5, bachelor = 6, bachelors = 6,
		master = 7, masters = 7, doctorate = 8, phd = 8,
	}
	local currentLevel = educationLevels[self.Education.level or "none"] or 0
	local requiredLevel = educationLevels[level] or 0
	return currentLevel >= requiredLevel
end

function LifeState:HasDroppedOut()
	local mem = loadEventMemory()
	if mem and self.Memory then
		return mem.hasDroppedOut(self.Memory)
	end
	return self:HasFlag("dropped_out") or self:HasFlag("expelled")
end

function LifeState:HasActualFriends()
	local mem = loadEventMemory()
	if mem and self.Memory then
		return mem.hasFriends(self.Memory)
	end
	-- Fallback to relationships
	for _, rel in pairs(self.Relationships) do
		if (rel.type == "friend") and rel.alive ~= false then
			return true
		end
	end
	return false
end

function LifeState:GetFriendName()
	local mem = loadEventMemory()
	if mem and self.Memory then
		return mem.getFriendName(self.Memory)
	end
	-- Fallback to relationships
	for _, rel in pairs(self.Relationships) do
		if (rel.type == "friend") and rel.alive ~= false and rel.name then
			return rel.name
		end
	end
	return nil
end

function LifeState:HasRomanticPartner()
	local mem = loadEventMemory()
	if mem and self.Memory then
		return mem.hasPartner(self.Memory)
	end
	local _, partner = self:GetPartner()
	return partner ~= nil
end

function LifeState:HasCriminalRecord()
	local mem = loadEventMemory()
	if mem and self.Memory then
		return mem.hasCriminalRecord(self.Memory)
	end
	return #self.CriminalRecord > 0 or self:HasFlag("criminal")
end

function LifeState:CanFileTaxes()
	local mem = loadEventMemory()
	if mem and self.Memory then
		return mem.canFileTaxes(self.Memory)
	end
	return self:HasEverWorked()
end

function LifeState:HasSkill(skillName)
	local mem = loadEventMemory()
	if mem and self.Memory then
		return mem.hasSkill(self.Memory, skillName)
	end
	return self:HasFlag("knows_" .. string.lower(skillName):gsub(" ", "_"))
end

function LifeState:HasLicense(licenseType)
	local mem = loadEventMemory()
	if mem and self.Memory then
		return mem.hasLicense(self.Memory, licenseType)
	end
	return self:HasFlag("has_" .. licenseType .. "_license") or self:HasFlag("has_license")
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
-- Uses FLAT dictionary format: Relationships["friend_123"] = { type = "friend", name = "...", ... }
-- Valid types: "friend", "romance", "family", "enemy"
----------------------------------------------------------------------

-- Type mapping for backwards compatibility with category-based calls
-- Maps all relationship types to the 4 standard UI types: "friend", "romance", "family", "enemy"
local typeFromCategory = {
	-- Friend types
	friends = "friend",
	friend = "friend",
	best_friend = "friend",
	childhood_friend = "friend",
	school_friend = "friend",
	club_friend = "friend",
	camp_friend = "friend",
	daycare_friend = "friend",
	kindergarten_friend = "friend",
	study_buddy = "friend",
	neighbor = "friend",
	reformed_bully_friend = "friend",
	preschool_friend = "friend",
	classmates = "friend",
	coworkers = "friend",
	acquaintance = "friend",
	former_student = "friend",
	work_friend = "friend",
	college_friend = "friend",
	gym_buddy = "friend",
	online_friend = "friend",
	mentor = "friend",
	mentee = "friend",
	-- Romance types
	romance = "romance",
	lovers = "romance",
	partner = "romance",
	dating = "romance",
	spouse = "romance",
	interest = "romance",
	crush = "romance",
	ex = "romance",
	fiance = "romance",
	-- Family types
	family = "family",
	parent = "family",
	sibling = "family",
	child = "family",
	grandparent = "family",
	grandchild = "family",
	cousin = "family",
	aunt = "family",
	uncle = "family",
	in_law = "family",
	-- Enemy types
	enemies = "enemy",
	enemy = "enemy",
	rival = "enemy",
}

function LifeState:AddRelationship(categoryOrType, person)
	-- Map category to standard type
	local standardType = typeFromCategory[categoryOrType] or "friend"
	
	-- Generate unique ID
	local uniqueId = person.id or (standardType .. "_" .. tostring(tick()) .. "_" .. tostring(math.random(1000, 9999)))
	
	-- Create relationship entry in flat format
	local entry = {
		type = standardType,
		name = person.name or "Unknown",
		role = person.role or (standardType == "friend" and "Friend" or standardType == "romance" and "Partner" or standardType == "family" and "Family" or "Enemy"),
		relationship = person.relationship or 50,
		age = person.age or self.Age,
		met = person.met or self.Age,
		alive = person.alive ~= false,
		subtype = person.subtype or categoryOrType,  -- Keep original category for reference
		gender = person.gender,
	}
	
	self.Relationships[uniqueId] = entry
	
	-- RECORD TO MEMORY (AAA BitLife-style tracking)
	if standardType == "friend" then
		self:RecordEvent("made_friend", {
			name = entry.name,
			id = uniqueId,
		})
		self:SetFlag("ever_had_friend")
		self:SetFlag("has_friend")
	elseif standardType == "romance" then
		self:RecordEvent("started_dating", {
			partner = entry.name,
			id = uniqueId,
		})
	end
	
	return entry, uniqueId
end

function LifeState:GetRelationship(idOrType, personId)
	-- If called with old category style: GetRelationship("friends", "friend_123")
	-- Just look up by personId directly
	if personId then
		return self.Relationships[personId]
	end
	-- If called with just an ID
	return self.Relationships[idOrType]
end

function LifeState:GetRelationshipById(personId)
	return self.Relationships[personId]
end

function LifeState:ModifyRelationship(personId, delta, category)
	-- Support both old style: ModifyRelationship("friends", "friend_123", 10)
	-- And new style: ModifyRelationship("friend_123", 10)
	local actualId = personId
	local actualDelta = delta
	if type(delta) == "string" then
		-- Old style call with category first
		actualId = delta
		actualDelta = category or 0
	end
	
	local person = self.Relationships[actualId]
	if person then
		person.relationship = clamp((person.relationship or 50) + actualDelta, 0, 100)
		return person.relationship
	end
	return nil
end

function LifeState:GetRandomRelationship(relType)
	-- Get a random relationship of a specific type (friend, romance, family, enemy)
	local matches = {}
	for id, person in pairs(self.Relationships) do
		if person.alive ~= false and (not relType or person.type == relType) then
			table.insert(matches, { id = id, person = person })
		end
	end
	return pickRandom(matches)
end

function LifeState:GetRelationshipsByType(relType)
	-- Get all relationships of a specific type
	local results = {}
	for id, person in pairs(self.Relationships) do
		if person.type == relType then
			table.insert(results, { id = id, person = person })
		end
	end
	return results
end

function LifeState:GetAllRelationships()
	local all = {}
	for id, person in pairs(self.Relationships) do
		table.insert(all, { id = id, person = person, type = person.type })
	end
	return all
end

function LifeState:RemoveRelationship(personId)
	self.Relationships[personId] = nil
end

function LifeState:HasRelationshipOfType(relType)
	for _, person in pairs(self.Relationships) do
		if person.type == relType and person.alive ~= false then
			return true
		end
	end
	return false
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
	
	-- Set employment flags
	self:SetFlag("employed")
	self:SetFlag("has_job")
	self:SetFlag("ever_worked")
	
	-- RECORD TO MEMORY (AAA BitLife-style tracking)
	self:RecordEvent("job_started", {
		path = path,
		title = title,
		employer = employer,
		salary = salary or 0,
	})
end

function LifeState:ClearCareer(reason)
	local previousJob = {
		path = self.Career.path,
		title = self.Career.jobTitle,
		employer = self.Career.employer,
		salary = self.Career.salary,
	}
	
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
	
	-- Clear employment flags
	self:ClearFlag("employed")
	self:ClearFlag("has_job")
	
	-- RECORD TO MEMORY
	local eventType = reason == "fired" and "job_fired" or (reason == "quit" and "job_quit" or "job_ended")
	self:RecordEvent(eventType, previousJob)
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
	
	-- RECORD TO MEMORY (AAA BitLife-style tracking)
	self:RecordEvent("school_graduated", {
		level = self.Education.level,
		degree = degree,
		schoolName = self.Education.schoolName,
		major = self.Education.major,
	})
	
	-- Set appropriate flags
	if self.Education.level == "highschool" or self.Education.level == "high_school" then
		self:SetFlag("high_school_graduate")
	elseif self.Education.level == "university" or self.Education.level == "bachelor" then
		self:SetFlag("college_graduate")
		self:SetFlag("bachelors_degree")
	elseif self.Education.level == "graduate" or self.Education.level == "master" then
		self:SetFlag("masters_degree")
		self:SetFlag("advanced_degree")
	elseif self.Education.level == "doctorate" then
		self:SetFlag("doctorate")
		self:SetFlag("phd")
		self:SetFlag("advanced_degree")
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

function LifeState:DropOut(level)
	local dropoutLevel = level or self.Education.level
	
	-- Set flags
	self:SetFlag("dropped_out")
	if dropoutLevel == "highschool" or dropoutLevel == "high_school" then
		self:SetFlag("high_school_dropout")
	end
	
	-- RECORD TO MEMORY (AAA BitLife-style tracking)
	self:RecordEvent("school_dropped_out", {
		level = dropoutLevel,
	})
end

function LifeState:GetGED()
	self:SetFlag("ged_graduate")
	self:ClearFlag("high_school_dropout") -- GED removes dropout stigma
	
	-- RECORD TO MEMORY
	self:RecordEvent("got_ged", {})
end

function LifeState:Expelled()
	self:SetFlag("expelled")
	self:SetFlag("dropped_out")
	
	-- RECORD TO MEMORY
	self:RecordEvent("school_dropped_out", {
		level = self.Education.level,
		reason = "expelled",
	})
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
-- HEALTH CONDITIONS HELPERS
----------------------------------------------------------------------

function LifeState:AddHealthCondition(id, opts)
	opts = opts or {}
	local cond = {
		id = id,
		name = opts.name or id,
		severity = opts.severity or "mild", -- "mild", "moderate", "severe", "terminal"
		chronic = opts.chronic ~= false,
		diagnosedAge = self.Age,
		diagnosedYear = self.Year,
		treated = opts.treated or false,
		treatmentCost = opts.treatmentCost or 0,
	}
	table.insert(self.HealthConditions, cond)
	
	-- Set flag for conditions that should trigger death system
	if opts.severity == "terminal" then
		self:SetFlag("terminal_illness")
	end
	if id == "cancer" then
		self:SetFlag("cancer")
	end
	if id == "heart_disease" or id == "heart_condition" then
		self:SetFlag("heart_condition")
	end
	if id == "diabetes" then
		self:SetFlag("diabetes")
	end
	
	return cond
end

function LifeState:HasHealthCondition(id)
	for _, cond in ipairs(self.HealthConditions) do
		if cond.id == id then
			return true, cond
		end
	end
	return false, nil
end

function LifeState:RemoveHealthCondition(id)
	for i, cond in ipairs(self.HealthConditions) do
		if cond.id == id then
			table.remove(self.HealthConditions, i)
			-- Clear associated flags
			if id == "cancer" then
				self:ClearFlag("cancer")
			end
			if id == "heart_disease" or id == "heart_condition" then
				self:ClearFlag("heart_condition")
			end
			if id == "diabetes" then
				self:ClearFlag("diabetes")
			end
			return true
		end
	end
	return false
end

function LifeState:GetHealthConditions()
	return self.HealthConditions or {}
end

function LifeState:GetSevereConditions()
	local severe = {}
	for _, cond in ipairs(self.HealthConditions) do
		if cond.severity == "severe" or cond.severity == "terminal" then
			table.insert(severe, cond)
		end
	end
	return severe
end

----------------------------------------------------------------------
-- ADDICTIONS HELPERS
----------------------------------------------------------------------

function LifeState:AddAddiction(id, opts)
	opts = opts or {}
	local addiction = {
		id = id,                         -- "alcohol", "drugs", "opioids", "gambling", etc.
		name = opts.name or id,
		severity = opts.severity or 20,  -- 0-100
		startAge = self.Age,
		startYear = self.Year,
		inRecovery = opts.inRecovery or false,
		relapses = 0,
	}
	table.insert(self.Addictions, addiction)
	
	-- Set flag for death system integration
	if id == "alcohol" or id == "alcoholism" then
		self:SetFlag("alcoholic")
	end
	if id == "drugs" or id == "opioids" or id == "cocaine" or id == "heroin" then
		self:SetFlag("drug_addict")
	end
	
	return addiction
end

function LifeState:HasAddiction(id)
	for _, add in ipairs(self.Addictions) do
		if add.id == id then
			return true, add
		end
	end
	return false, nil
end

function LifeState:ModifyAddiction(id, delta)
	local has, add = self:HasAddiction(id)
	if not has then return nil end
	add.severity = clamp((add.severity or 0) + delta, 0, 100)
	
	-- If severity hits 0, they've beaten the addiction
	if add.severity <= 0 then
		add.inRecovery = true
	end
	
	return add.severity
end

function LifeState:RemoveAddiction(id)
	for i, add in ipairs(self.Addictions) do
		if add.id == id then
			table.remove(self.Addictions, i)
			-- Clear associated flags
			if id == "alcohol" or id == "alcoholism" then
				self:ClearFlag("alcoholic")
			end
			if id == "drugs" or id == "opioids" or id == "cocaine" or id == "heroin" then
				self:ClearFlag("drug_addict")
			end
			return true
		end
	end
	return false
end

function LifeState:GetAddictions()
	return self.Addictions or {}
end

function LifeState:GetTotalAddictionSeverity()
	local total = 0
	for _, add in ipairs(self.Addictions) do
		if not add.inRecovery then
			total = total + (add.severity or 0)
		end
	end
	return total
end

----------------------------------------------------------------------
-- FAME & SOCIAL MEDIA HELPERS
----------------------------------------------------------------------

function LifeState:ModifyFame(delta)
	self.Fame = clamp((self.Fame or 0) + delta, 0, 100)
	
	-- Set milestone flags
	if self.Fame >= 90 then
		self:SetFlag("famous")
	elseif self.Fame >= 50 then
		self:SetFlag("notable")
	end
	
	return self.Fame
end

function LifeState:SetSocialPlatform(platform)
	self.SocialMedia.platform = platform
end

function LifeState:AddFollowers(amount)
	amount = math.floor(amount or 0)
	self.SocialMedia.followers = math.max(0, (self.SocialMedia.followers or 0) + amount)
	
	-- Scale Fame from followers
	if self.SocialMedia.followers >= 10000000 then
		self.Fame = math.max(self.Fame or 0, 100)
		self:SetFlag("mega_influencer")
	elseif self.SocialMedia.followers >= 1000000 then
		self.Fame = math.max(self.Fame or 0, 90)
		self:SetFlag("famous")
	elseif self.SocialMedia.followers >= 100000 then
		self.Fame = math.max(self.Fame or 0, 70)
		self:SetFlag("influencer")
	elseif self.SocialMedia.followers >= 10000 then
		self.Fame = math.max(self.Fame or 0, 50)
	elseif self.SocialMedia.followers >= 1000 then
		self.Fame = math.max(self.Fame or 0, 30)
	end
	
	return self.SocialMedia.followers
end

function LifeState:RemoveFollowers(amount)
	amount = math.floor(amount or 0)
	self.SocialMedia.followers = math.max(0, (self.SocialMedia.followers or 0) - amount)
	return self.SocialMedia.followers
end

function LifeState:SetVerified()
	self.SocialMedia.verified = true
	self.Fame = math.max(self.Fame or 0, 60)
	self:SetFlag("verified")
end

function LifeState:GetFollowers()
	return self.SocialMedia.followers or 0
end

function LifeState:IsVerified()
	return self.SocialMedia.verified == true
end

----------------------------------------------------------------------
-- RELATIONSHIP CONVENIENCE HELPERS
----------------------------------------------------------------------

function LifeState:GetSpouse()
	for id, rel in pairs(self.Relationships) do
		if rel.type == "romance" and rel.role == "Spouse" and rel.alive ~= false then
			return id, rel
		end
	end
	return nil, nil
end

function LifeState:GetParents()
	local parents = {}
	for id, rel in pairs(self.Relationships) do
		if rel.type == "family" and (rel.role == "Mother" or rel.role == "Father") then
			table.insert(parents, { id = id, person = rel })
		end
	end
	return parents
end

function LifeState:GetChildren()
	local kids = {}
	for id, rel in pairs(self.Relationships) do
		if rel.type == "family" and rel.role == "Child" then
			table.insert(kids, { id = id, person = rel })
		end
	end
	return kids
end

function LifeState:GetSiblings()
	local siblings = {}
	for id, rel in pairs(self.Relationships) do
		if rel.type == "family" and (rel.role == "Brother" or rel.role == "Sister" or rel.role == "Sibling") then
			table.insert(siblings, { id = id, person = rel })
		end
	end
	return siblings
end

function LifeState:GetPartner()
	-- Get current romantic partner (dating, fiance, or spouse)
	for id, rel in pairs(self.Relationships) do
		if rel.type == "romance" and rel.alive ~= false then
			if rel.role == "Spouse" or rel.role == "Partner" or rel.role == "Fiance" or rel.role == "Fiancée" then
				return id, rel
			end
		end
	end
	return nil, nil
end

function LifeState:IsMarried()
	local spouseId, spouse = self:GetSpouse()
	return spouseId ~= nil
end

function LifeState:HasChildren()
	return #self:GetChildren() > 0
end

function LifeState:GetLivingRelationships()
	local living = {}
	for id, rel in pairs(self.Relationships) do
		if rel.alive ~= false then
			table.insert(living, { id = id, person = rel })
		end
	end
	return living
end

function LifeState:CountRelationshipsByType(relType)
	local count = 0
	for _, rel in pairs(self.Relationships) do
		if rel.type == relType and rel.alive ~= false then
			count = count + 1
		end
	end
	return count
end

----------------------------------------------------------------------
-- ASSET CONVENIENCE HELPERS
----------------------------------------------------------------------

function LifeState:GetRandomAsset(assetType)
	local list = self.Assets[assetType]
	if not list or #list == 0 then return nil end
	return list[math.random(1, #list)]
end

function LifeState:GetTotalAssetValue(assetType)
	local total = 0
	local list = self.Assets[assetType]
	if not list then return 0 end
	for _, asset in ipairs(list) do
		total = total + (asset.value or 0)
	end
	return total
end

function LifeState:GetAssetCount(assetType)
	local list = self.Assets[assetType]
	if not list then return 0 end
	return #list
end

function LifeState:HasAsset(assetType, assetId)
	local list = self.Assets[assetType]
	if not list then return false end
	for _, asset in ipairs(list) do
		if asset.id == assetId then
			return true, asset
		end
	end
	return false
end

function LifeState:GetAllAssetValues()
	local totals = {
		houses = self:GetTotalAssetValue("houses"),
		cars = self:GetTotalAssetValue("cars"),
		businesses = self:GetTotalAssetValue("businesses"),
		investments = self:GetTotalAssetValue("investments"),
	}
	totals.total = totals.houses + totals.cars + totals.businesses + totals.investments
	return totals
end

----------------------------------------------------------------------
-- CRIMINAL RECORD
----------------------------------------------------------------------

function LifeState:AddCrime(crime, caught)
	table.insert(self.CriminalRecord, {
		crime = crime,
		year = self.Year,
		age = self.Age,
		caught = caught or false,
	})
	
	-- RECORD TO MEMORY (AAA BitLife-style tracking)
	self:RecordEvent("committed_crime", {
		type = crime,
		caught = caught or false,
	})
	self:SetFlag("criminal")
	self:SetFlag("committed_crime")
end

function LifeState:HasCriminalRecord()
	return #self.CriminalRecord > 0
end

function LifeState:GoToJail(years, crime)
	self.InJail = true
	self.JailSentence = years
	self.JailTime = years
	self:SetFlag("in_prison")
	self:SetFlag("criminal_record")
	
	-- RECORD TO MEMORY (AAA BitLife-style tracking)
	self:RecordEvent("arrested", { crime = crime })
	self:RecordEvent("went_to_prison", {
		years = years,
		crime = crime,
	})
end

function LifeState:ServeTime(years)
	years = years or 1
	self.JailTime = math.max(0, (self.JailTime or 0) - years)
	
	if self.JailTime <= 0 then
		self.InJail = false
		self.JailTime = 0
		self:ClearFlag("in_prison")
		self:SetFlag("ex_con")
		
		-- RECORD TO MEMORY (AAA BitLife-style tracking)
		self:RecordEvent("released_from_prison", {})
		
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
-- SERIALIZATION (COMPLETE - for DataStore persistence)
----------------------------------------------------------------------

function LifeState:Serialize()
	return {
		-- Core identity
		PlayerId = self.PlayerId,
		Name = self.Name,
		Gender = self.Gender,
		
		-- Time
		Age = self.Age,
		Year = self.Year,
		
		-- Economy
		Money = self.Money,
		
		-- Stats (both formats for compatibility)
		Stats = self.Stats,
		Happiness = self.Stats.Happiness,
		Health = self.Stats.Health,
		Looks = self.Stats.Looks,
		Smarts = self.Stats.Smarts,
		
		-- Flags (story progress, achievements, etc.)
		Flags = self.Flags,
		
		-- Career & Education
		Career = self.Career,
		Education = self.Education,
		
		-- Assets (houses, cars, businesses, pets, investments)
		Assets = self.Assets,
		
		-- Relationships (complete dictionary)
		Relationships = self.Relationships,
		
		-- Criminal/Legal status
		InJail = self.InJail,
		JailTime = self.JailTime,
		JailSentence = self.JailSentence,
		CriminalRecord = self.CriminalRecord,
		WantedLevel = self.WantedLevel,
		Notoriety = self.Notoriety,
		
		-- Health tracking
		HealthConditions = self.HealthConditions,
		Addictions = self.Addictions,
		Fitness = self.Fitness,
		
		-- Fame & Social
		Fame = self.Fame,
		SocialMedia = self.SocialMedia,
		
		-- Event History (for one-time events, cooldowns, milestones)
		EventHistory = self.EventHistory,
		
		-- Feed log (recent entries only to save space)
		Feed = self:GetRecentFeed(50),
		
		-- Comprehensive Event Memory (AAA BitLife-style tracking)
		Memory = self.Memory,
	}
end

-- Hydrate/restore a LifeState from serialized data (for DataStore loading)
function LifeState.fromSerialized(player, data)
	if not data then return nil end
	
	local self = setmetatable({}, LifeState)
	
	-- Core identity
	self.PlayerId = player.UserId
	self.Name = data.Name
	self.Gender = data.Gender
	
	-- Time
	self.Age = data.Age or 0
	self.Year = data.Year or 2025
	
	-- Economy
	self.Money = data.Money or 0
	
	-- Stats
	self.Stats = data.Stats or {
		Happiness = data.Happiness or 80,
		Health = data.Health or 80,
		Looks = data.Looks or 70,
		Smarts = data.Smarts or 70,
	}
	-- Backwards compatibility
	self.Happiness = self.Stats.Happiness
	self.Health = self.Stats.Health
	self.Looks = self.Stats.Looks
	self.Smarts = self.Stats.Smarts
	
	-- Flags
	self.Flags = data.Flags or {}
	
	-- Career
	self.Career = data.Career or {
		path = nil,
		jobTitle = nil,
		employer = nil,
		salary = 0,
		experience = 0,
		performance = 50,
		promotions = 0,
	}
	-- Legacy fields
	self.Job = self.Career.employer
	self.JobTitle = self.Career.jobTitle
	self.JobSalary = self.Career.salary or 0
	
	-- Education
	self.Education = data.Education or {
		level = "none",
		schoolName = nil,
		university = nil,
		major = nil,
		gpa = 0,
		scholarship = nil,
		graduated = false,
		degrees = {},
	}
	self.EducationLevel = self.Education.level
	
	-- Assets
	self.Assets = data.Assets or {
		cash = self.Money,
		houses = {},
		cars = {},
		businesses = {},
		pets = {},
		investments = {},
	}
	self.Assets.cash = self.Money -- Sync
	
	-- Relationships
	self.Relationships = data.Relationships or {}
	
	-- Criminal/Legal status
	self.InJail = data.InJail or false
	self.JailTime = data.JailTime or 0
	self.JailSentence = data.JailSentence or 0
	self.CriminalRecord = data.CriminalRecord or {}
	self.WantedLevel = data.WantedLevel or 0
	self.Notoriety = data.Notoriety or 0
	
	-- Health tracking
	self.HealthConditions = data.HealthConditions or {}
	self.Addictions = data.Addictions or {}
	self.Fitness = data.Fitness or 50
	
	-- Fame & Social
	self.Fame = data.Fame or 0
	self.SocialMedia = data.SocialMedia or {
		followers = 0,
		platform = nil,
		verified = false,
	}
	
	-- Event History
	self.EventHistory = data.EventHistory or {
		seenEvents = {},
		lastOccurrence = {},
		milestonesFired = {},
		choicesMade = {},
	}
	
	-- Feed
	self.Feed = data.Feed or {}
	
	-- Restore Event Memory (AAA BitLife-style tracking)
	local mem = loadEventMemory()
	if mem and data.Memory then
		self.Memory = data.Memory
	elseif mem then
		-- Create fresh memory if no saved data
		self.Memory = mem.create()
	else
		self.Memory = nil
	end
	
	return self
end

-- Quick check if serialized data is valid
function LifeState.isValidSaveData(data)
	if not data then return false end
	if type(data) ~= "table" then return false end
	if not data.Name then return false end
	if data.Age == nil then return false end
	return true
end

return LifeState
