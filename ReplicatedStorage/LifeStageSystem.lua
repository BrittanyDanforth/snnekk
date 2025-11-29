-- LifeStageSystem.lua
-- Comprehensive life stage system for BitLife-style age progression
-- Handles stage transitions, capabilities, event validation, and death

local LifeStageSystem = {}

----------------------------------------------------------------------
-- LIFE STAGES DEFINITION
----------------------------------------------------------------------

local LIFE_STAGES = {
	{
		id = "baby",
		name = "Baby",
		emoji = "👶",
		minAge = 0,
		maxAge = 1,
		description = "Just born into this world",
	},
	{
		id = "toddler",
		name = "Toddler",
		emoji = "🚼",
		minAge = 2,
		maxAge = 4,
		description = "Learning to walk and talk",
	},
	{
		id = "early_childhood",
		name = "Early Childhood",
		emoji = "🎒",
		minAge = 5,
		maxAge = 9,
		description = "Elementary school years",
	},
	{
		id = "childhood",
		name = "Childhood",
		emoji = "🚸",
		minAge = 10,
		maxAge = 12,
		description = "Growing up fast",
	},
	{
		id = "tween",
		name = "Tween",
		emoji = "😬",
		minAge = 13,
		maxAge = 15,
		description = "The awkward years",
	},
	{
		id = "teenage",
		name = "Teenager",
		emoji = "🎸",
		minAge = 16,
		maxAge = 19,
		description = "High school and beyond",
	},
	{
		id = "young_adult",
		name = "Young Adult",
		emoji = "🎓",
		minAge = 20,
		maxAge = 35,
		description = "Building your life",
	},
	{
		id = "adult",
		name = "Adult",
		emoji = "💼",
		minAge = 36,
		maxAge = 60,
		description = "Prime of life",
	},
	{
		id = "senior",
		name = "Senior",
		emoji = "👴",
		minAge = 61,
		maxAge = 80,
		description = "Golden years",
	},
	{
		id = "elderly",
		name = "Elderly",
		emoji = "🕯️",
		minAge = 81,
		maxAge = 999,
		description = "Twilight years",
	},
}

----------------------------------------------------------------------
-- CAPABILITIES BY STAGE
----------------------------------------------------------------------

local CAPABILITIES = {
	baby = {
		canWork = false,
		canWorkFullTime = false,
		canDate = false,
		canMarry = false,
		canDrive = false,
		canCrime = false,
		canDrink = false,
		canVote = false,
		canGamble = false,
		canEnrollCollege = false,
		canRetire = false,
	},
	toddler = {
		canWork = false,
		canWorkFullTime = false,
		canDate = false,
		canMarry = false,
		canDrive = false,
		canCrime = false,
		canDrink = false,
		canVote = false,
		canGamble = false,
		canEnrollCollege = false,
		canRetire = false,
	},
	early_childhood = {
		canWork = false,
		canWorkFullTime = false,
		canDate = false,
		canMarry = false,
		canDrive = false,
		canCrime = false,
		canDrink = false,
		canVote = false,
		canGamble = false,
		canEnrollCollege = false,
		canRetire = false,
	},
	childhood = {
		canWork = false,
		canWorkFullTime = false,
		canDate = false,
		canMarry = false,
		canDrive = false,
		canCrime = false,
		canDrink = false,
		canVote = false,
		canGamble = false,
		canEnrollCollege = false,
		canRetire = false,
	},
	tween = {
		canWork = false,
		canWorkFullTime = false,
		canDate = true,
		canMarry = false,
		canDrive = false,
		canCrime = true,
		canDrink = false,
		canVote = false,
		canGamble = false,
		canEnrollCollege = false,
		canRetire = false,
	},
	teenage = {
		canWork = true,
		canWorkFullTime = false,
		canDate = true,
		canMarry = false,
		canDrive = true,
		canCrime = true,
		canDrink = false,
		canVote = false,
		canGamble = false,
		canEnrollCollege = true,
		canRetire = false,
	},
	young_adult = {
		canWork = true,
		canWorkFullTime = true,
		canDate = true,
		canMarry = true,
		canDrive = true,
		canCrime = true,
		canDrink = true,
		canVote = true,
		canGamble = true,
		canEnrollCollege = true,
		canRetire = false,
	},
	adult = {
		canWork = true,
		canWorkFullTime = true,
		canDate = true,
		canMarry = true,
		canDrive = true,
		canCrime = true,
		canDrink = true,
		canVote = true,
		canGamble = true,
		canEnrollCollege = true,
		canRetire = true,
	},
	senior = {
		canWork = true,
		canWorkFullTime = true,
		canDate = true,
		canMarry = true,
		canDrive = true,
		canCrime = true,
		canDrink = true,
		canVote = true,
		canGamble = true,
		canEnrollCollege = false,
		canRetire = true,
	},
	elderly = {
		canWork = false,
		canWorkFullTime = false,
		canDate = true,
		canMarry = true,
		canDrive = false,
		canCrime = false,
		canDrink = true,
		canVote = true,
		canGamble = true,
		canEnrollCollege = false,
		canRetire = true,
	},
}

----------------------------------------------------------------------
-- DEATH CAUSES BY AGE
----------------------------------------------------------------------

local DEATH_CAUSES = {
	young = {
		"a tragic accident",
		"a sudden illness",
		"unforeseen circumstances",
	},
	middle = {
		"heart disease",
		"cancer",
		"a stroke",
		"an accident",
	},
	old = {
		"old age",
		"natural causes",
		"peacefully in their sleep",
		"heart failure",
		"a stroke",
	},
	very_old = {
		"old age",
		"natural causes",
		"peacefully surrounded by family",
		"in their sleep",
	},
}

----------------------------------------------------------------------
-- HELPER FUNCTIONS
----------------------------------------------------------------------

local function getStageIndex(stageId)
	for i, stage in ipairs(LIFE_STAGES) do
		if stage.id == stageId then
			return i
		end
	end
	return nil
end

----------------------------------------------------------------------
-- PUBLIC API
----------------------------------------------------------------------

-- Get the stage for a given age
function LifeStageSystem.getStage(age)
	age = age or 0
	for _, stage in ipairs(LIFE_STAGES) do
		if age >= stage.minAge and age <= stage.maxAge then
			return stage
		end
	end
	return LIFE_STAGES[#LIFE_STAGES] -- Return elderly as fallback
end

-- Get stage by ID
function LifeStageSystem.getStageById(stageId)
	for _, stage in ipairs(LIFE_STAGES) do
		if stage.id == stageId then
			return stage
		end
	end
	return nil
end

-- Get all stages
function LifeStageSystem.getAllStages()
	return LIFE_STAGES
end

-- Check if transitioning between stages
function LifeStageSystem.getTransitionEvent(oldAge, newAge)
	local oldStage = LifeStageSystem.getStage(oldAge)
	local newStage = LifeStageSystem.getStage(newAge)
	
	if oldStage.id ~= newStage.id then
		return {
			id = "stage_transition_" .. newStage.id,
			emoji = newStage.emoji,
			title = "New Life Stage: " .. newStage.name,
			text = newStage.description,
			fromStage = oldStage,
			toStage = newStage,
			isStageTransition = true,
		}
	end
	
	return nil
end

-- Get capabilities for a state
function LifeStageSystem.getCapabilities(state)
	local stage = LifeStageSystem.getStage(state.Age or 0)
	local caps = CAPABILITIES[stage.id] or CAPABILITIES.baby
	
	-- Copy the base capabilities
	local result = {}
	for k, v in pairs(caps) do
		result[k] = v
	end
	
	-- Modify based on state flags
	if state.InJail then
		result.canWork = false
		result.canWorkFullTime = false
		result.canDate = false
		result.canDrive = false
		result.canGamble = false
	end
	
	return result
end

-- Check if death should occur
function LifeStageSystem.checkDeath(state)
	local age = state.Age or 0
	local health = (state.Stats and state.Stats.Health) or state.Health or 50
	
	-- Base death chance increases dramatically with age
	local deathChance = 0
	
	if age < 50 then
		-- Very low chance for young people
		deathChance = 0.001 * (1 - health / 100)
	elseif age < 60 then
		deathChance = 0.005 * (1 - health / 100)
	elseif age < 70 then
		deathChance = 0.02 * (1 - health / 100)
	elseif age < 80 then
		deathChance = 0.05 * (1 - health / 100)
	elseif age < 90 then
		deathChance = 0.10 + (age - 80) * 0.02
	elseif age < 100 then
		deathChance = 0.30 + (age - 90) * 0.05
	else
		-- Almost certain death after 100
		deathChance = 0.80 + (age - 100) * 0.05
	end
	
	-- Low health dramatically increases death chance
	if health < 20 then
		deathChance = deathChance * 3
	elseif health < 40 then
		deathChance = deathChance * 2
	end
	
	-- Cap at 95%
	deathChance = math.min(deathChance, 0.95)
	
	local died = math.random() < deathChance
	
	if died then
		local causes
		if age < 50 then
			causes = DEATH_CAUSES.young
		elseif age < 70 then
			causes = DEATH_CAUSES.middle
		elseif age < 90 then
			causes = DEATH_CAUSES.old
		else
			causes = DEATH_CAUSES.very_old
		end
		
		local cause = causes[math.random(#causes)]
		
		return {
			died = true,
			cause = cause,
			age = age,
		}
	end
	
	return { died = false }
end

-- Validate if an event can fire at current state
function LifeStageSystem.validateEvent(eventDef, state)
	if not eventDef then
		return { valid = false, reason = "No event definition" }
	end
	
	local age = state.Age or 0
	local stage = LifeStageSystem.getStage(age)
	local caps = LifeStageSystem.getCapabilities(state)
	
	-- Check age range if specified
	if eventDef.minAge and age < eventDef.minAge then
		return { valid = false, reason = "Too young" }
	end
	if eventDef.maxAge and age > eventDef.maxAge then
		return { valid = false, reason = "Too old" }
	end
	
	-- Check stage restriction if specified
	if eventDef.stages then
		local stageAllowed = false
		for _, allowedStage in ipairs(eventDef.stages) do
			if stage.id == allowedStage then
				stageAllowed = true
				break
			end
		end
		if not stageAllowed then
			return { valid = false, reason = "Wrong life stage" }
		end
	end
	
	-- Check required flags
	if eventDef.requireFlags then
		for _, flag in ipairs(eventDef.requireFlags) do
			if not (state.Flags and state.Flags[flag]) then
				return { valid = false, reason = "Missing flag: " .. flag }
			end
		end
	end
	
	-- Check blocking flags
	if eventDef.blockFlags then
		for _, flag in ipairs(eventDef.blockFlags) do
			if state.Flags and state.Flags[flag] then
				return { valid = false, reason = "Blocked by flag: " .. flag }
			end
		end
	end
	
	-- Check capability requirements
	if eventDef.requireCapability then
		if not caps[eventDef.requireCapability] then
			return { valid = false, reason = "Lacking capability: " .. eventDef.requireCapability }
		end
	end
	
	-- Check one-time events
	if eventDef.oneTime then
		local history = state.EventHistory or {}
		if history.seenEvents and history.seenEvents[eventDef.id] then
			return { valid = false, reason = "Already seen (one-time)" }
		end
	end
	
	-- Check cooldown
	if eventDef.cooldown then
		local history = state.EventHistory or {}
		local lastOccurrence = history.lastOccurrence and history.lastOccurrence[eventDef.id]
		if lastOccurrence and (age - lastOccurrence) < eventDef.cooldown then
			return { valid = false, reason = "On cooldown" }
		end
	end
	
	return { valid = true }
end

-- Filter events to only those valid for current state
function LifeStageSystem.filterValidEvents(events, state)
	local valid = {}
	for _, event in ipairs(events) do
		local validation = LifeStageSystem.validateEvent(event, state)
		if validation.valid then
			table.insert(valid, event)
		end
	end
	return valid
end

-- Get a summary of the current stage for UI
function LifeStageSystem.getStageSummary(state)
	local stage = LifeStageSystem.getStage(state.Age or 0)
	local caps = LifeStageSystem.getCapabilities(state)
	
	return {
		stage = stage,
		capabilities = caps,
		isChild = stage.id == "baby" or stage.id == "toddler" or stage.id == "early_childhood" or stage.id == "childhood",
		isTeen = stage.id == "tween" or stage.id == "teenage",
		isAdult = stage.id == "young_adult" or stage.id == "adult",
		isSenior = stage.id == "senior" or stage.id == "elderly",
	}
end

return LifeStageSystem
