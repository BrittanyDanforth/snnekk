--[[
	LifeState.lua
	AAA BitLife-Style Player State Management
	
	This is the "save file" for each player's life.
	Contains ALL data about a player's current life.
]]

local LifeState = {}
LifeState.__index = LifeState

--------------------------------------------------------------------------------
-- CONSTRUCTOR
--------------------------------------------------------------------------------

function LifeState.new(player)
	local self = setmetatable({}, LifeState)
	
	-- Identity
	self.PlayerId = player and player.UserId or 0
	self.Name = nil -- Set during intro
	self.Gender = nil -- "Male" or "Female"
	
	-- Time
	self.Age = 0
	self.Year = 2025
	self.IsDead = false
	
	-- Core Stats (0-100)
	self.Stats = {
		Happiness = 80,
		Health = 100,
		Smarts = math.random(40, 80),
		Looks = math.random(30, 90),
	}
	
	-- Money
	self.Money = 0
	
	-- Flags (boolean markers for story/state)
	self.Flags = {}
	
	-- Relationships
	self.Relationships = {}
	
	-- Career
	self.Career = {
		path = nil,        -- "motorsport", "political", "criminal", etc.
		jobId = nil,       -- Current job ID
		title = nil,       -- Job title
		salary = 0,        -- Annual salary
		experience = 0,    -- Years of experience
		performance = 75,  -- 0-100 job performance
		tier = 0,          -- Career tier/level
	}
	
	-- Education
	self.Education = {
		level = "none",    -- "none", "high_school", "college", "graduate", "doctorate"
		institution = nil,
		major = nil,
		gpa = 0,
		graduated = false,
		degrees = {},
		enrolled = false,
		yearsCompleted = 0,
		debt = 0,
	}
	
	-- Assets
	self.Assets = {
		properties = {},
		vehicles = {},
		items = {},
		crypto = {},
	}
	
	-- Criminal/Prison
	self.Criminal = {
		inPrison = false,
		yearsLeft = 0,
		record = {},
		wantedLevel = 0,
		escaped = false,
	}
	
	-- Health
	self.Health = {
		conditions = {},
		addictions = {},
		fitness = 50,
	}
	
	-- Fame & Social
	self.Fame = 0
	self.Social = {
		followers = 0,
		platform = nil,
		verified = false,
	}
	
	-- Event History
	self.EventHistory = {
		seen = {},
		lastOccurrence = {},
		milestones = {},
		choices = {},
	}
	
	-- Life Feed
	self.Feed = {}
	
	return self
end

--------------------------------------------------------------------------------
-- STAT MANAGEMENT
--------------------------------------------------------------------------------

function LifeState:ClampStats()
	for stat, val in pairs(self.Stats) do
		self.Stats[stat] = math.clamp(val, 0, 100)
	end
	self.Fame = math.clamp(self.Fame or 0, 0, 100)
	self.Health.fitness = math.clamp(self.Health.fitness or 50, 0, 100)
end

function LifeState:GetStat(name)
	return self.Stats[name] or 0
end

function LifeState:SetStat(name, value)
	self.Stats[name] = math.clamp(value, 0, 100)
end

function LifeState:ModifyStat(name, delta)
	local current = self.Stats[name] or 50
	self.Stats[name] = math.clamp(current + delta, 0, 100)
	return self.Stats[name]
end

function LifeState:ApplyEffects(effects)
	if not effects then return end
	
	for stat, delta in pairs(effects) do
		if stat == "Money" or stat == "Cash" then
			self.Money = (self.Money or 0) + delta
		elseif stat == "Fame" then
			self.Fame = math.clamp((self.Fame or 0) + delta, 0, 100)
		elseif stat == "Fitness" then
			self.Health.fitness = math.clamp((self.Health.fitness or 50) + delta, 0, 100)
		elseif self.Stats[stat] ~= nil then
			self:ModifyStat(stat, delta)
		end
	end
end

--------------------------------------------------------------------------------
-- FLAGS
--------------------------------------------------------------------------------

function LifeState:SetFlag(flag, value)
	self.Flags[flag] = (value ~= false)
end

function LifeState:ClearFlag(flag)
	self.Flags[flag] = nil
end

function LifeState:HasFlag(flag)
	return self.Flags[flag] == true
end

function LifeState:SetFlags(flags)
	for _, flag in ipairs(flags) do
		self.Flags[flag] = true
	end
end

function LifeState:ClearFlags(flags)
	for _, flag in ipairs(flags) do
		self.Flags[flag] = nil
	end
end

--------------------------------------------------------------------------------
-- MONEY
--------------------------------------------------------------------------------

function LifeState:AddMoney(amount)
	self.Money = (self.Money or 0) + amount
end

function LifeState:RemoveMoney(amount)
	self.Money = (self.Money or 0) - amount
end

function LifeState:HasMoney(amount)
	return (self.Money or 0) >= amount
end

function LifeState:GetNetWorth()
	local total = self.Money or 0
	
	for _, prop in ipairs(self.Assets.properties) do
		total = total + (prop.value or 0)
	end
	for _, vehicle in ipairs(self.Assets.vehicles) do
		total = total + (vehicle.value or 0)
	end
	
	return total
end

--------------------------------------------------------------------------------
-- RELATIONSHIPS
--------------------------------------------------------------------------------

function LifeState:AddRelationship(relType, data)
	local id = data.id or (relType .. "_" .. #self.Relationships + 1)
	
	local rel = {
		id = id,
		type = relType, -- "family", "friend", "romance", "enemy"
		name = data.name,
		age = data.age,
		gender = data.gender,
		relationship = data.relationship, -- "Mother", "Friend", "Partner", etc.
		closeness = data.closeness or 50,
		alive = true,
		metAge = self.Age,
	}
	
	self.Relationships[id] = rel
	return rel
end

function LifeState:GetRelationship(id)
	return self.Relationships[id]
end

function LifeState:GetRelationshipsByType(relType)
	local matches = {}
	for id, rel in pairs(self.Relationships) do
		if rel.type == relType and rel.alive then
			table.insert(matches, rel)
		end
	end
	return matches
end

function LifeState:ModifyRelationship(id, delta)
	local rel = self.Relationships[id]
	if rel then
		rel.closeness = math.clamp((rel.closeness or 50) + delta, 0, 100)
	end
end

function LifeState:HasFriend()
	return #self:GetRelationshipsByType("friend") > 0
end

function LifeState:HasPartner()
	return #self:GetRelationshipsByType("romance") > 0
end

function LifeState:IsMarried()
	return self:HasFlag("married")
end

function LifeState:HasChildren()
	for _, rel in pairs(self.Relationships) do
		if rel.relationship == "Child" or rel.relationship == "Son" or rel.relationship == "Daughter" then
			return true
		end
	end
	return false
end

--------------------------------------------------------------------------------
-- CAREER
--------------------------------------------------------------------------------

function LifeState:SetCareer(path, jobId, title, salary)
	self.Career.path = path
	self.Career.jobId = jobId
	self.Career.title = title
	self.Career.salary = salary or 0
	self.Career.performance = 75
	
	self:SetFlag("employed")
	self:SetFlag("ever_worked")
	self:SetFlag("has_job")
end

function LifeState:ClearCareer()
	self.Career.jobId = nil
	self.Career.title = nil
	self.Career.salary = 0
	self.Career.performance = 75
	
	self:ClearFlag("employed")
	self:ClearFlag("has_job")
end

function LifeState:HasJob()
	return self.Career.jobId ~= nil
end

function LifeState:GetAnnualIncome()
	return self.Career.salary or 0
end

function LifeState:PromoteCareer(newTitle, newSalary, newTier)
	self.Career.title = newTitle
	self.Career.salary = newSalary
	self.Career.tier = newTier or (self.Career.tier + 1)
	self.Career.experience = self.Career.experience + 1
end

--------------------------------------------------------------------------------
-- EDUCATION
--------------------------------------------------------------------------------

function LifeState:Enroll(level, institution, major)
	self.Education.level = level
	self.Education.institution = institution
	self.Education.major = major
	self.Education.enrolled = true
	self.Education.yearsCompleted = 0
	self.Education.gpa = 3.0
	
	self:SetFlag("enrolled")
	self:SetFlag("student")
end

function LifeState:Graduate(degree)
	self.Education.enrolled = false
	self.Education.graduated = true
	table.insert(self.Education.degrees, {
		type = degree,
		institution = self.Education.institution,
		major = self.Education.major,
		year = self.Year,
	})
	
	self:ClearFlag("enrolled")
	self:ClearFlag("student")
	self:SetFlag(degree .. "_graduate")
end

function LifeState:DropOut()
	self.Education.enrolled = false
	self:ClearFlag("enrolled")
	self:ClearFlag("student")
	self:SetFlag("dropped_out")
end

function LifeState:HasDegree(degreeType)
	for _, degree in ipairs(self.Education.degrees) do
		if degree.type == degreeType then
			return true
		end
	end
	return false
end

--------------------------------------------------------------------------------
-- PRISON / CRIMINAL
--------------------------------------------------------------------------------

function LifeState:GoToPrison(years, crime)
	self.Criminal.inPrison = true
	self.Criminal.yearsLeft = years
	table.insert(self.Criminal.record, {
		crime = crime,
		year = self.Year,
		sentence = years,
	})
	
	self:SetFlag("in_prison")
	self:SetFlag("criminal_record")
	self:ClearCareer()
end

function LifeState:ServeTime(years)
	self.Criminal.yearsLeft = math.max(0, self.Criminal.yearsLeft - years)
	
	if self.Criminal.yearsLeft <= 0 then
		self:ReleaseFromPrison()
	end
end

function LifeState:ReleaseFromPrison()
	self.Criminal.inPrison = false
	self.Criminal.yearsLeft = 0
	
	self:ClearFlag("in_prison")
	self:SetFlag("ex_convict")
end

function LifeState:IsInPrison()
	return self.Criminal.inPrison == true
end

function LifeState:HasCriminalRecord()
	return #self.Criminal.record > 0
end

--------------------------------------------------------------------------------
-- HEALTH
--------------------------------------------------------------------------------

function LifeState:AddCondition(id, severity)
	self.Health.conditions[id] = {
		id = id,
		severity = severity or 1,
		diagnosedAge = self.Age,
	}
	self:SetFlag("has_condition")
	self:SetFlag("condition_" .. id)
end

function LifeState:RemoveCondition(id)
	self.Health.conditions[id] = nil
	self:ClearFlag("condition_" .. id)
end

function LifeState:HasCondition(id)
	return self.Health.conditions[id] ~= nil
end

function LifeState:AddAddiction(id, severity)
	self.Health.addictions[id] = {
		id = id,
		severity = severity or 1,
		startAge = self.Age,
	}
	self:SetFlag("has_addiction")
	self:SetFlag("addiction_" .. id)
end

function LifeState:RemoveAddiction(id)
	self.Health.addictions[id] = nil
	self:ClearFlag("addiction_" .. id)
end

--------------------------------------------------------------------------------
-- ASSETS
--------------------------------------------------------------------------------

function LifeState:AddAsset(assetType, asset)
	asset.id = asset.id or (assetType .. "_" .. tick())
	asset.purchaseYear = self.Year
	asset.purchasePrice = asset.price
	asset.value = asset.price
	
	if assetType == "property" then
		table.insert(self.Assets.properties, asset)
		self:SetFlag("homeowner")
	elseif assetType == "vehicle" then
		table.insert(self.Assets.vehicles, asset)
		self:SetFlag("car_owner")
	elseif assetType == "item" then
		table.insert(self.Assets.items, asset)
	elseif assetType == "crypto" then
		table.insert(self.Assets.crypto, asset)
	end
	
	return asset.id
end

function LifeState:RemoveAsset(assetType, assetId)
	local list
	if assetType == "property" then list = self.Assets.properties
	elseif assetType == "vehicle" then list = self.Assets.vehicles
	elseif assetType == "item" then list = self.Assets.items
	elseif assetType == "crypto" then list = self.Assets.crypto
	end
	
	if list then
		for i, asset in ipairs(list) do
			if asset.id == assetId then
				table.remove(list, i)
				return asset
			end
		end
	end
	return nil
end

function LifeState:HasAsset(assetType, assetId)
	local list
	if assetType == "property" then list = self.Assets.properties
	elseif assetType == "vehicle" then list = self.Assets.vehicles
	elseif assetType == "item" then list = self.Assets.items
	elseif assetType == "crypto" then list = self.Assets.crypto
	end
	
	if list then
		for _, asset in ipairs(list) do
			if asset.id == assetId then
				return true
			end
		end
	end
	return false
end

--------------------------------------------------------------------------------
-- FAME & SOCIAL
--------------------------------------------------------------------------------

function LifeState:ModifyFame(delta)
	self.Fame = math.clamp((self.Fame or 0) + delta, 0, 100)
	
	if self.Fame >= 80 then
		self:SetFlag("famous")
	elseif self.Fame >= 50 then
		self:SetFlag("well_known")
	end
end

function LifeState:AddFollowers(count)
	self.Social.followers = (self.Social.followers or 0) + count
	
	if self.Social.followers >= 1000000 then
		self:SetFlag("mega_influencer")
	elseif self.Social.followers >= 100000 then
		self:SetFlag("influencer")
	end
end

--------------------------------------------------------------------------------
-- FEED / HISTORY
--------------------------------------------------------------------------------

function LifeState:AddFeed(text, emoji)
	table.insert(self.Feed, {
		year = self.Year,
		age = self.Age,
		text = text,
		emoji = emoji,
	})
	
	-- Keep only last 100 entries
	while #self.Feed > 100 do
		table.remove(self.Feed, 1)
	end
end

function LifeState:RecordEvent(eventId, choiceIndex)
	self.EventHistory.seen[eventId] = true
	self.EventHistory.lastOccurrence[eventId] = self.Age
	if choiceIndex then
		self.EventHistory.choices[eventId] = choiceIndex
	end
end

function LifeState:HasSeenEvent(eventId)
	return self.EventHistory.seen[eventId] == true
end

function LifeState:GetLastEventAge(eventId)
	return self.EventHistory.lastOccurrence[eventId]
end

--------------------------------------------------------------------------------
-- LIFE STAGE HELPERS
--------------------------------------------------------------------------------

function LifeState:GetLifeStage()
	local age = self.Age
	if age < 3 then return "infant"
	elseif age < 5 then return "toddler"
	elseif age < 10 then return "child"
	elseif age < 13 then return "tween"
	elseif age < 18 then return "teen"
	elseif age < 30 then return "young_adult"
	elseif age < 50 then return "adult"
	elseif age < 65 then return "middle_age"
	elseif age < 80 then return "senior"
	else return "elder"
	end
end

function LifeState:CanWork()
	return self.Age >= 14 and not self:IsInPrison()
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

--------------------------------------------------------------------------------
-- SERIALIZATION
--------------------------------------------------------------------------------

function LifeState:Serialize()
	return {
		PlayerId = self.PlayerId,
		Name = self.Name,
		Gender = self.Gender,
		Age = self.Age,
		Year = self.Year,
		IsDead = self.IsDead,
		Stats = self.Stats,
		Money = self.Money,
		Flags = self.Flags,
		Relationships = self.Relationships,
		Career = self.Career,
		Education = self.Education,
		Assets = self.Assets,
		Criminal = self.Criminal,
		Health = self.Health,
		Fame = self.Fame,
		Social = self.Social,
		EventHistory = self.EventHistory,
		Feed = self.Feed,
	}
end

function LifeState.fromSerialized(player, data)
	local state = LifeState.new(player)
	
	for key, value in pairs(data) do
		if state[key] ~= nil then
			state[key] = value
		end
	end
	
	return state
end

return LifeState
