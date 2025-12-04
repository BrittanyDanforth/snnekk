--[[
	LifeStageSystem.lua
	AAA BitLife-Style Life Stage Management
	
	Handles:
	- Life stages (infant, child, teen, adult, etc.)
	- Capabilities (can work, can drive, etc.)
	- Event validation
	- Death system
	- Stage transitions
]]

local LifeStageSystem = {}

--------------------------------------------------------------------------------
-- LIFE STAGES
--------------------------------------------------------------------------------

LifeStageSystem.Stages = {
	INFANT = {
		id = "infant", name = "Infant",
		minAge = 0, maxAge = 2,
		emoji = "👶",
		canWork = false, canDate = false, canCrime = false, canDrive = false,
		inSchool = false,
		activities = {"sleep", "cry", "play"},
		eventCategories = {"family", "health", "milestone"},
	},
	TODDLER = {
		id = "toddler", name = "Toddler",
		minAge = 3, maxAge = 4,
		emoji = "💒",
		canWork = false, canDate = false, canCrime = false, canDrive = false,
		inSchool = true, schoolType = "daycare",
		activities = {"play", "learn", "tantrum"},
		eventCategories = {"family", "health", "milestone", "social"},
	},
	CHILD = {
		id = "child", name = "Child",
		minAge = 5, maxAge = 9,
		emoji = "💒",
		canWork = false, canDate = false, canCrime = false, canDrive = false,
		inSchool = true, schoolType = "elementary",
		activities = {"school", "play", "sports", "hobbies"},
		eventCategories = {"family", "health", "school", "social", "milestone"},
	},
	TWEEN = {
		id = "tween", name = "Tween",
		minAge = 10, maxAge = 12,
		emoji = "🧒",
		canWork = false, canDate = false, canCrime = true, canDrive = false,
		inSchool = true, schoolType = "middle",
		activities = {"school", "sports", "hobbies", "social_media"},
		eventCategories = {"family", "health", "school", "social", "milestone", "crime"},
	},
	TEEN = {
		id = "teen", name = "Teen",
		minAge = 13, maxAge = 17,
		emoji = "🧑",
		canWork = true, canDate = true, canCrime = true, canDrive = true,
		inSchool = true, schoolType = "high_school",
		activities = {"school", "work", "dating", "sports", "hobbies", "party"},
		eventCategories = {"family", "health", "school", "social", "romance", "work", "crime", "milestone"},
	},
	YOUNG_ADULT = {
		id = "young_adult", name = "Young Adult",
		minAge = 18, maxAge = 29,
		emoji = "👨",
		canWork = true, canDate = true, canCrime = true, canDrive = true,
		canMarry = true, canDrink = true, canVote = true,
		inSchool = false,
		activities = {"work", "dating", "party", "travel", "education", "investments"},
		eventCategories = {"family", "health", "social", "romance", "work", "money", "crime", "milestone", "education"},
	},
	ADULT = {
		id = "adult", name = "Adult",
		minAge = 30, maxAge = 49,
		emoji = "👨",
		canWork = true, canDate = true, canCrime = true, canDrive = true,
		canMarry = true, canDrink = true, canVote = true,
		activities = {"work", "family", "investments", "hobbies", "travel"},
		eventCategories = {"family", "health", "social", "romance", "work", "money", "crime", "milestone", "business"},
	},
	MIDDLE_AGE = {
		id = "middle_age", name = "Middle Aged",
		minAge = 50, maxAge = 64,
		emoji = "🧔",
		canWork = true, canDate = true, canCrime = true, canDrive = true,
		canMarry = true, canDrink = true, canVote = true, canRetire = true,
		activities = {"work", "family", "retirement_planning", "health"},
		eventCategories = {"family", "health", "social", "romance", "work", "money", "milestone", "medical"},
	},
	SENIOR = {
		id = "senior", name = "Senior",
		minAge = 65, maxAge = 79,
		emoji = "👴",
		canWork = true, canDate = true, canCrime = true, canDrive = true,
		canMarry = true, canRetire = true, retired = true,
		activities = {"retirement", "family", "health", "hobbies"},
		eventCategories = {"family", "health", "social", "milestone", "medical", "death"},
	},
	ELDER = {
		id = "elder", name = "Elder",
		minAge = 80, maxAge = 150,
		emoji = "👴",
		canWork = false, canDate = true, canCrime = false, canDrive = false,
		canMarry = true, retired = true,
		activities = {"rest", "family", "reminisce"},
		eventCategories = {"family", "health", "milestone", "medical", "death"},
	},
}

local StageOrder = {"INFANT", "TODDLER", "CHILD", "TWEEN", "TEEN", "YOUNG_ADULT", "ADULT", "MIDDLE_AGE", "SENIOR", "ELDER"}

--------------------------------------------------------------------------------
-- STAGE HELPERS
--------------------------------------------------------------------------------

function LifeStageSystem.getStage(age)
	for _, stageKey in ipairs(StageOrder) do
		local stage = LifeStageSystem.Stages[stageKey]
		if age >= stage.minAge and age <= stage.maxAge then
			return stage
		end
	end
	return LifeStageSystem.Stages.ELDER
end

function LifeStageSystem.getStageById(stageId)
	for _, stage in pairs(LifeStageSystem.Stages) do
		if stage.id == stageId then
			return stage
		end
	end
	return nil
end

function LifeStageSystem.checkStageTransition(oldAge, newAge)
	local oldStage = LifeStageSystem.getStage(oldAge)
	local newStage = LifeStageSystem.getStage(newAge)
	
	if oldStage.id ~= newStage.id then
		return {
			changed = true,
			from = oldStage,
			to = newStage,
		}
	end
	
	return { changed = false }
end

--------------------------------------------------------------------------------
-- STAGE TRANSITION EVENTS
--------------------------------------------------------------------------------

local StageTransitionEvents = {
	toddler = {
		id = "stage_transition_infant_to_toddler",
		emoji = "🎂",
		title = "Growing Up!",
		text = "You're no longer a baby! The world is getting more interesting.",
	},
	child = {
		id = "stage_transition_toddler_to_child",
		emoji = "🎒",
		title = "Off to School!",
		text = "It's time for elementary school. A whole new world awaits!",
	},
	tween = {
		id = "stage_transition_child_to_tween",
		emoji = "📱",
		title = "Tween Years!",
		text = "You're becoming more independent. Middle school is a new adventure.",
	},
	teen = {
		id = "stage_transition_tween_to_teen",
		emoji = "🎓",
		title = "Teenage Years!",
		text = "High school begins! Dating, driving, and new responsibilities await.",
	},
	young_adult = {
		id = "stage_transition_teen_to_adult",
		emoji = "🎉",
		title = "Adulthood!",
		text = "You're 18! The world is now yours to conquer.",
	},
	adult = {
		id = "stage_transition_young_adult_to_adult",
		emoji = "💼",
		title = "Full Adulthood!",
		text = "You're 30 now. Time to really make your mark on the world.",
	},
	middle_age = {
		id = "stage_transition_adult_to_middle",
		emoji = "👔",
		title = "Middle Age!",
		text = "The big 5-0! You've gained wisdom and experience.",
	},
	senior = {
		id = "stage_transition_middle_to_senior",
		emoji = "🎂",
		title = "Senior Years!",
		text = "65 years young! Time to enjoy the fruits of your labor.",
	},
	elder = {
		id = "stage_transition_senior_to_elder",
		emoji = "👴",
		title = "Elder!",
		text = "80 years of life experience. You've seen it all.",
	},
}

function LifeStageSystem.getTransitionEvent(oldAge, newAge)
	local transition = LifeStageSystem.checkStageTransition(oldAge, newAge)
	
	if transition.changed then
		local event = StageTransitionEvents[transition.to.id]
		if event then
			return {
				id = event.id,
				emoji = event.emoji,
				title = event.title,
				text = event.text,
				category = "milestone",
				milestone = true,
				isStageTransition = true,
			}
		end
	end
	
	return nil
end

--------------------------------------------------------------------------------
-- CAPABILITIES
--------------------------------------------------------------------------------

function LifeStageSystem.getCapabilities(state)
	local stage = LifeStageSystem.getStage(state.Age)
	local flags = state.Flags or {}
	
	local caps = {
		-- Basic capabilities from stage
		canWork = stage.canWork,
		canDate = stage.canDate,
		canCrime = stage.canCrime,
		canDrive = stage.canDrive and state.Age >= 16,
		canMarry = stage.canMarry and state.Age >= 18,
		canDrink = state.Age >= 21,
		canVote = state.Age >= 18,
		canGamble = state.Age >= 21,
		canRetire = state.canRetire or state.Age >= 65,
		
		-- School status
		inSchool = stage.inSchool or (state.Education and state.Education.enrolled),
		schoolType = stage.schoolType,
		
		-- Prison status
		inPrison = flags.in_prison or (state.Criminal and state.Criminal.inPrison),
		
		-- Flags-based
		hasJob = flags.employed or (state.Career and state.Career.jobId),
		isMarried = flags.married,
		hasKids = flags.has_children,
		hasDegree = flags.college_graduate or flags.high_school_graduate,
		
		-- Current stage info
		stage = stage.id,
		stageName = stage.name,
		stageEmoji = stage.emoji,
	}
	
	-- Prison restricts most capabilities
	if caps.inPrison then
		caps.canWork = false
		caps.canDate = false
		caps.canDrive = false
		caps.canGamble = false
		caps.canMarry = false
	end
	
	return caps
end

--------------------------------------------------------------------------------
-- EVENT VALIDATION
--------------------------------------------------------------------------------

function LifeStageSystem.validateEvent(event, state)
	local reasons = {}
	local valid = true
	
	if not event then
		return { valid = false, reasons = {"No event provided"} }
	end
	
	local age = state.Age
	local flags = state.Flags or {}
	local stage = LifeStageSystem.getStage(age)
	local caps = LifeStageSystem.getCapabilities(state)
	
	-- Age requirements
	local minAge = event.minAge or (event.conditions and event.conditions.minAge) or 0
	local maxAge = event.maxAge or (event.conditions and event.conditions.maxAge) or 150
	
	if age < minAge then
		valid = false
		table.insert(reasons, "Too young")
	end
	if age > maxAge then
		valid = false
		table.insert(reasons, "Too old")
	end
	
	-- Prison check
	if caps.inPrison then
		local category = event.category or ""
		local allowedInPrison = { prison = true, health = true, family = true, milestone = true }
		if not allowedInPrison[category] then
			valid = false
			table.insert(reasons, "In prison")
		end
	end
	
	-- One-time events
	if event.oneTime then
		if state.EventHistory and state.EventHistory.seen[event.id] then
			valid = false
			table.insert(reasons, "Already seen")
		end
	end
	
	-- Cooldown
	if event.cooldown then
		local lastAge = state.EventHistory and state.EventHistory.lastOccurrence[event.id]
		if lastAge and (age - lastAge) < event.cooldown then
			valid = false
			table.insert(reasons, "On cooldown")
		end
	end
	
	-- Required flags
	if event.requiresFlag then
		if not flags[event.requiresFlag] then
			valid = false
			table.insert(reasons, "Missing flag: " .. event.requiresFlag)
		end
	end
	
	-- Blocked flags
	if event.blockIfFlag then
		if flags[event.blockIfFlag] then
			valid = false
			table.insert(reasons, "Blocked by flag: " .. event.blockIfFlag)
		end
	end
	
	-- Custom requires function
	if event.requires and type(event.requires) == "function" then
		local ok, result = pcall(event.requires, state)
		if ok and not result then
			valid = false
			table.insert(reasons, "Custom requirements not met")
		end
	end
	
	-- Conditions table (new-style events)
	if event.conditions then
		local cond = event.conditions
		
		-- Required all flags
		if cond.requiredAllFlags then
			for _, flag in ipairs(cond.requiredAllFlags) do
				if not flags[flag] then
					valid = false
					table.insert(reasons, "Missing required flag: " .. flag)
				end
			end
		end
		
		-- Required any flags
		if cond.requiredAnyFlags then
			local hasAny = false
			for _, flag in ipairs(cond.requiredAnyFlags) do
				if flags[flag] then hasAny = true break end
			end
			if not hasAny then
				valid = false
				table.insert(reasons, "Missing any of required flags")
			end
		end
		
		-- Blocked flags
		if cond.blockedFlags then
			for _, flag in ipairs(cond.blockedFlags) do
				if flags[flag] then
					valid = false
					table.insert(reasons, "Blocked by flag: " .. flag)
				end
			end
		end
		
		-- Min stats
		if cond.minStats then
			for stat, minVal in pairs(cond.minStats) do
				local current = state.Stats and state.Stats[stat] or 0
				if current < minVal then
					valid = false
					table.insert(reasons, stat .. " too low")
				end
			end
		end
		
		-- Min money
		if cond.minMoney then
			if (state.Money or 0) < cond.minMoney then
				valid = false
				table.insert(reasons, "Not enough money")
			end
		end
		
		-- Custom function
		if cond.custom and type(cond.custom) == "function" then
			local ok, result = pcall(cond.custom, state)
			if ok and not result then
				valid = false
				table.insert(reasons, "Custom requirements not met")
			end
		end
	end
	
	return { valid = valid, reasons = reasons }
end

--------------------------------------------------------------------------------
-- DEATH SYSTEM
--------------------------------------------------------------------------------

local DeathCauses = {
	-- Natural causes by age
	{ cause = "old age", minAge = 75, weight = 50 },
	{ cause = "heart failure", minAge = 50, weight = 20 },
	{ cause = "stroke", minAge = 60, weight = 15 },
	{ cause = "cancer", minAge = 40, weight = 15 },
	
	-- Health-related
	{ cause = "heart attack", condition = "heart_condition", weight = 40 },
	{ cause = "cancer", condition = "cancer", weight = 50 },
	{ cause = "diabetes complications", condition = "diabetes", weight = 30 },
	
	-- Addiction-related
	{ cause = "overdose", addiction = "drugs", weight = 40 },
	{ cause = "liver failure", addiction = "alcohol", weight = 30 },
	
	-- Lifestyle
	{ cause = "unhealthy lifestyle", minHealth = 0, maxHealth = 20, weight = 30 },
}

function LifeStageSystem.getDeathCause(state)
	local validCauses = {}
	local totalWeight = 0
	
	for _, dc in ipairs(DeathCauses) do
		local valid = true
		
		if dc.minAge and state.Age < dc.minAge then valid = false end
		if dc.condition and not state:HasCondition(dc.condition) then valid = false end
		if dc.addiction then
			local hasAddiction = state.Health and state.Health.addictions and state.Health.addictions[dc.addiction]
			if not hasAddiction then valid = false end
		end
		if dc.minHealth and (state.Stats.Health or 100) > dc.minHealth then valid = false end
		if dc.maxHealth and (state.Stats.Health or 100) > dc.maxHealth then valid = false end
		
		if valid then
			table.insert(validCauses, dc)
			totalWeight = totalWeight + dc.weight
		end
	end
	
	if #validCauses == 0 then
		return "natural causes"
	end
	
	-- Weighted random selection
	local roll = math.random(1, totalWeight)
	local cumulative = 0
	
	for _, dc in ipairs(validCauses) do
		cumulative = cumulative + dc.weight
		if roll <= cumulative then
			return dc.cause
		end
	end
	
	return validCauses[1].cause
end

function LifeStageSystem.calculateDeathChance(state)
	local health = state.Stats and state.Stats.Health or 100
	
	-- Instant death at 0 health
	if health <= 0 then
		return 1.0
	end
	
	-- Base death chance by age
	local age = state.Age
	local baseChance = 0
	
	if age < 50 then
		baseChance = 0.001 -- 0.1% per year
	elseif age < 60 then
		baseChance = 0.005 -- 0.5%
	elseif age < 70 then
		baseChance = 0.02 -- 2%
	elseif age < 80 then
		baseChance = 0.05 -- 5%
	elseif age < 90 then
		baseChance = 0.12 -- 12%
	elseif age < 100 then
		baseChance = 0.25 -- 25%
	else
		baseChance = 0.40 -- 40%
	end
	
	-- Health modifier (low health = higher death chance)
	local healthMod = 1.0
	if health < 20 then
		healthMod = 3.0
	elseif health < 40 then
		healthMod = 2.0
	elseif health < 60 then
		healthMod = 1.5
	end
	
	-- Condition modifiers
	local conditionMod = 1.0
	if state.Health and state.Health.conditions then
		for _, cond in pairs(state.Health.conditions) do
			conditionMod = conditionMod + (cond.severity or 1) * 0.2
		end
	end
	
	-- Addiction modifiers
	local addictionMod = 1.0
	if state.Health and state.Health.addictions then
		for _, addiction in pairs(state.Health.addictions) do
			addictionMod = addictionMod + (addiction.severity or 1) * 0.15
		end
	end
	
	-- Fitness bonus
	local fitnessMod = 1.0
	local fitness = state.Health and state.Health.fitness or 50
	if fitness > 80 then
		fitnessMod = 0.7
	elseif fitness > 60 then
		fitnessMod = 0.85
	end
	
	local finalChance = baseChance * healthMod * conditionMod * addictionMod * fitnessMod
	return math.min(finalChance, 0.95) -- Cap at 95%
end

function LifeStageSystem.checkDeath(state)
	local health = state.Stats and state.Stats.Health or 100
	
	-- Instant death at 0 health
	if health <= 0 then
		return {
			died = true,
			cause = LifeStageSystem.getDeathCause(state),
			wasHealthDeath = true,
		}
	end
	
	-- Random death roll
	local chance = LifeStageSystem.calculateDeathChance(state)
	local roll = math.random()
	
	if roll < chance then
		return {
			died = true,
			cause = LifeStageSystem.getDeathCause(state),
			wasHealthDeath = false,
		}
	end
	
	return { died = false }
end

--------------------------------------------------------------------------------
-- SUMMARY HELPERS
--------------------------------------------------------------------------------

function LifeStageSystem.getStageSummary(state)
	local stage = LifeStageSystem.getStage(state.Age)
	local caps = LifeStageSystem.getCapabilities(state)
	
	return {
		stage = stage,
		capabilities = caps,
		age = state.Age,
		name = state.Name,
	}
end

return LifeStageSystem
