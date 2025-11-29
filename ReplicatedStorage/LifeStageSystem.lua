-- LifeStageSystem.lua
-- Comprehensive BitLife-style life stage management
-- Controls what events, actions, and content are available at each stage

local LifeStageSystem = {}

----------------------------------------------------------------------
-- LIFE STAGES DEFINITION (BitLife-style)
----------------------------------------------------------------------

LifeStageSystem.Stages = {
	INFANT = {
		id = "infant",
		name = "Infant",
		emoji = "👶",
		minAge = 0, maxAge = 2,
		description = "You're just a baby, completely dependent on your parents.",
		canWork = false,
		canDate = false,
		canDrive = false,
		canCrime = false,
		canDrink = false,
		canVote = false,
		canGamble = false,
		inSchool = false,
		schoolType = nil,
		activities = {"cry", "sleep", "eat", "crawl"},
		eventCategories = {"family", "health", "milestone"},
	},
	
	TODDLER = {
		id = "toddler",
		name = "Toddler",
		emoji = "💒",
		minAge = 3, maxAge = 4,
		description = "You're learning to walk, talk, and explore the world.",
		canWork = false,
		canDate = false,
		canDrive = false,
		canCrime = false,
		canDrink = false,
		canVote = false,
		canGamble = false,
		inSchool = false,
		schoolType = "daycare",
		activities = {"play", "learn", "tantrum"},
		eventCategories = {"family", "health", "milestone", "social"},
	},
	
	CHILD = {
		id = "child",
		name = "Child",
		emoji = "🧒",
		minAge = 5, maxAge = 11,
		description = "Elementary school years - making friends and learning.",
		canWork = false,
		canDate = false,
		canDrive = false,
		canCrime = false,
		canDrink = false,
		canVote = false,
		canGamble = false,
		inSchool = true,
		schoolType = "elementary",
		activities = {"study", "play", "sports", "clubs"},
		eventCategories = {"family", "health", "school", "social", "milestone"},
	},
	
	TWEEN = {
		id = "tween",
		name = "Tween",
		emoji = "🧑",
		minAge = 12, maxAge = 13,
		description = "Middle school - puberty, drama, and finding yourself.",
		canWork = false,
		canDate = false,
		canDrive = false,
		canCrime = true, -- Minor stuff
		canDrink = false,
		canVote = false,
		canGamble = false,
		inSchool = true,
		schoolType = "middle",
		activities = {"study", "sports", "clubs", "hangout", "social_media"},
		eventCategories = {"family", "health", "school", "social", "romance", "milestone"},
	},
	
	TEEN = {
		id = "teen",
		name = "Teenager",
		emoji = "🧑‍🎤",
		minAge = 14, maxAge = 17,
		description = "High school - dating, driving, and planning your future.",
		canWork = true, -- Part-time
		canDate = true,
		canDrive = true, -- At 16
		canCrime = true,
		canDrink = false,
		canVote = false,
		canGamble = false,
		inSchool = true,
		schoolType = "highschool",
		activities = {"study", "work_parttime", "sports", "clubs", "date", "party", "drive"},
		eventCategories = {"family", "health", "school", "social", "romance", "work", "crime", "milestone"},
	},
	
	YOUNG_ADULT = {
		id = "young_adult",
		name = "Young Adult",
		emoji = "🧑‍💼",
		minAge = 18, maxAge = 25,
		description = "College, first real job, independence, and possibilities.",
		canWork = true,
		canDate = true,
		canDrive = true,
		canCrime = true,
		canDrink = true, -- At 21
		canVote = true,
		canGamble = true, -- At 21
		inSchool = false, -- Optional
		schoolType = "university",
		activities = {"work", "study", "date", "party", "travel", "invest", "crime"},
		eventCategories = {"all"},
	},
	
	ADULT = {
		id = "adult",
		name = "Adult",
		emoji = "🧑‍💻",
		minAge = 26, maxAge = 45,
		description = "Career building, family, and major life decisions.",
		canWork = true,
		canDate = true,
		canDrive = true,
		canCrime = true,
		canDrink = true,
		canVote = true,
		canGamble = true,
		inSchool = false,
		schoolType = nil,
		activities = {"work", "date", "marry", "kids", "invest", "travel", "hobby"},
		eventCategories = {"all"},
	},
	
	MIDDLE_AGE = {
		id = "middle_age",
		name = "Middle-Aged",
		emoji = "🧔",
		minAge = 46, maxAge = 60,
		description = "Career peak, midlife reflections, kids growing up.",
		canWork = true,
		canDate = true,
		canDrive = true,
		canCrime = true,
		canDrink = true,
		canVote = true,
		canGamble = true,
		inSchool = false,
		schoolType = nil,
		activities = {"work", "retire_early", "invest", "travel", "grandkids"},
		eventCategories = {"all"},
	},
	
	SENIOR = {
		id = "senior",
		name = "Senior",
		emoji = "🧓",
		minAge = 61, maxAge = 75,
		description = "Retirement, grandchildren, and enjoying life's rewards.",
		canWork = true, -- Optional
		canDate = true,
		canDrive = true,
		canCrime = true,
		canDrink = true,
		canVote = true,
		canGamble = true,
		inSchool = false,
		schoolType = nil,
		activities = {"retire", "travel", "grandkids", "hobby", "volunteer"},
		eventCategories = {"family", "health", "social", "money", "milestone"},
	},
	
	ELDER = {
		id = "elder",
		name = "Elder",
		emoji = "👴",
		minAge = 76, maxAge = 120,
		description = "The twilight years - legacy and reflection.",
		canWork = false,
		canDate = true,
		canDrive = false, -- Too old
		canCrime = false,
		canDrink = true,
		canVote = true,
		canGamble = true,
		inSchool = false,
		schoolType = nil,
		activities = {"rest", "family", "legacy", "reminisce"},
		eventCategories = {"family", "health", "milestone", "death"},
	},
}

-- Ordered list for iteration
LifeStageSystem.StageOrder = {
	"INFANT", "TODDLER", "CHILD", "TWEEN", "TEEN", 
	"YOUNG_ADULT", "ADULT", "MIDDLE_AGE", "SENIOR", "ELDER"
}

----------------------------------------------------------------------
-- EVENT CATEGORY DEFINITIONS
----------------------------------------------------------------------

LifeStageSystem.EventCategories = {
	family = {
		name = "Family",
		emoji = "👨‍👩‍👧",
		description = "Events involving family members",
		minAge = 0,
		maxAge = 120,
	},
	health = {
		name = "Health",
		emoji = "🏥",
		description = "Health-related events",
		minAge = 0,
		maxAge = 120,
	},
	school = {
		name = "School",
		emoji = "🏫",
		description = "Education events",
		minAge = 5,
		maxAge = 30,
	},
	social = {
		name = "Social",
		emoji = "👥",
		description = "Friendships and social situations",
		minAge = 3,
		maxAge = 120,
	},
	romance = {
		name = "Romance",
		emoji = "💕",
		description = "Dating and relationships",
		minAge = 12,
		maxAge = 120,
	},
	work = {
		name = "Work",
		emoji = "💼",
		description = "Career and job events",
		minAge = 14,
		maxAge = 75,
	},
	crime = {
		name = "Crime",
		emoji = "🔪",
		description = "Criminal activities",
		minAge = 10,
		maxAge = 70,
	},
	money = {
		name = "Money",
		emoji = "💰",
		description = "Financial events",
		minAge = 10,
		maxAge = 120,
	},
	milestone = {
		name = "Milestone",
		emoji = "🎉",
		description = "Major life milestones",
		minAge = 0,
		maxAge = 120,
	},
	prison = {
		name = "Prison",
		emoji = "⛓️",
		description = "Prison-related events",
		minAge = 14,
		maxAge = 80,
		requiresFlag = "in_prison",
	},
	political = {
		name = "Political",
		emoji = "🏛️",
		description = "Political career events",
		minAge = 18,
		maxAge = 80,
		requiresFlag = "political_interest",
	},
	racing = {
		name = "Racing",
		emoji = "🏎️",
		description = "Racing career events",
		minAge = 8,
		maxAge = 50,
		requiresFlag = "racing_interest",
	},
	art = {
		name = "Art",
		emoji = "🎨",
		description = "Art career events",
		minAge = 7,
		maxAge = 100,
		requiresFlag = "art_interest",
	},
	hacking = {
		name = "Hacking",
		emoji = "💻",
		description = "Hacker career events",
		minAge = 12,
		maxAge = 60,
		requiresFlag = "computer_interest",
	},
	teaching = {
		name = "Teaching",
		emoji = "📚",
		description = "Teaching career events",
		minAge = 22,
		maxAge = 70,
		requiresFlag = "teaching_interest",
	},
	death = {
		name = "Death",
		emoji = "💀",
		description = "End of life events",
		minAge = 60,
		maxAge = 120,
	},
}

----------------------------------------------------------------------
-- CORE FUNCTIONS
----------------------------------------------------------------------

-- Get current life stage for an age
function LifeStageSystem.getStage(age)
	for _, stageKey in ipairs(LifeStageSystem.StageOrder) do
		local stage = LifeStageSystem.Stages[stageKey]
		if age >= stage.minAge and age <= stage.maxAge then
			return stage
		end
	end
	return LifeStageSystem.Stages.ELDER -- Fallback
end

-- Get stage by ID
function LifeStageSystem.getStageById(stageId)
	for _, stage in pairs(LifeStageSystem.Stages) do
		if stage.id == stageId then
			return stage
		end
	end
	return nil
end

-- Check if player just transitioned to a new stage
function LifeStageSystem.checkStageTransition(oldAge, newAge)
	local oldStage = LifeStageSystem.getStage(oldAge)
	local newStage = LifeStageSystem.getStage(newAge)
	
	if oldStage.id ~= newStage.id then
		return {
			transitioned = true,
			from = oldStage,
			to = newStage,
		}
	end
	
	return { transitioned = false }
end

-- Check if a category is valid for the current state
function LifeStageSystem.isCategoryValid(category, state)
	local catDef = LifeStageSystem.EventCategories[category]
	if not catDef then return true end -- Unknown category, allow
	
	local age = state.Age or 0
	
	-- Check age range
	if age < catDef.minAge or age > catDef.maxAge then
		return false
	end
	
	-- Check required flag
	if catDef.requiresFlag then
		local flags = state.Flags or {}
		if not flags[catDef.requiresFlag] then
			return false
		end
	end
	
	return true
end

-- Check if an activity is available at current stage
function LifeStageSystem.canDoActivity(activityId, state)
	local stage = LifeStageSystem.getStage(state.Age or 0)
	
	-- Check if activity is in stage's allowed activities
	for _, allowed in ipairs(stage.activities) do
		if allowed == activityId then
			return true
		end
	end
	
	return false
end

-- Get all available activities for current stage
function LifeStageSystem.getAvailableActivities(state)
	local stage = LifeStageSystem.getStage(state.Age or 0)
	return stage.activities
end

-- Check capabilities at current stage
function LifeStageSystem.getCapabilities(state)
	local stage = LifeStageSystem.getStage(state.Age or 0)
	local age = state.Age or 0
	local flags = state.Flags or {}
	
	return {
		canWork = stage.canWork and age >= 14,
		canWorkFullTime = stage.canWork and age >= 18,
		canDate = stage.canDate and age >= 12,
		canMarry = stage.canDate and age >= 18,
		canDrive = stage.canDrive and age >= 16 and flags.has_license,
		canCrime = stage.canCrime and age >= 10,
		canDrink = stage.canDrink and age >= 21,
		canVote = stage.canVote and age >= 18,
		canGamble = stage.canGamble and age >= 21,
		canEnrollCollege = age >= 18 and age <= 50,
		canRetire = age >= 50,
		inSchool = stage.inSchool or flags.college_student,
		schoolType = flags.college_student and "university" or stage.schoolType,
		
		-- Career paths
		canStartPolitics = age >= 18 and flags.political_interest,
		canStartRacing = age >= 16 and flags.racing_interest,
		canStartArt = age >= 16 and flags.art_interest,
		canStartHacking = age >= 16 and flags.computer_interest,
		canStartTeaching = age >= 22 and flags.teaching_interest,
		canStartCrime = age >= 16 and (flags.criminal_tendencies or flags.gang_member),
		
		-- Special states
		inPrison = flags.in_prison or state.InJail,
		isFugitive = flags.fugitive,
		isPregnant = flags.pregnant,
		isMarried = flags.married,
		hasKids = flags.has_children,
	}
end

----------------------------------------------------------------------
-- EVENT VALIDATION (Server-side)
----------------------------------------------------------------------

-- Master validation function - checks everything
function LifeStageSystem.validateEvent(eventDef, state)
	local validationResult = {
		valid = true,
		reasons = {},
	}
	
	local age = state.Age or 0
	local flags = state.Flags or {}
	local stage = LifeStageSystem.getStage(age)
	local caps = LifeStageSystem.getCapabilities(state)
	
	-- Enhanced debug logging for all validation
	local DEBUG_EVENT_VALIDATION = false -- Set to true for verbose logging
	
	if DEBUG_EVENT_VALIDATION or eventDef.category == "prison" then
		print("[LifeStageSystem] === VALIDATING EVENT ===")
		print("[LifeStageSystem] Event:", eventDef.id, "Category:", eventDef.category or "none")
		print("[LifeStageSystem] - Age:", age, "Stage:", stage.id)
		print("[LifeStageSystem] - InPrison (caps):", caps.inPrison, "Flag in_prison:", flags.in_prison or false)
		if eventDef.requiresFlag then
			print("[LifeStageSystem] - requiresFlag:", eventDef.requiresFlag, "Has flag:", flags[eventDef.requiresFlag] or false)
		end
		if eventDef.requiresFlag2 then
			print("[LifeStageSystem] - requiresFlag2:", eventDef.requiresFlag2, "Has flag:", flags[eventDef.requiresFlag2] or false)
		end
		if eventDef.blockIfFlag then
			print("[LifeStageSystem] - blockIfFlag:", eventDef.blockIfFlag, "Has flag:", flags[eventDef.blockIfFlag] or false)
		end
	end
	
	-- 1. Check age range
	if eventDef.minAge and age < eventDef.minAge then
		validationResult.valid = false
		table.insert(validationResult.reasons, "Too young (need " .. eventDef.minAge .. ")")
	end
	
	if eventDef.maxAge and age > eventDef.maxAge then
		validationResult.valid = false
		table.insert(validationResult.reasons, "Too old (max " .. eventDef.maxAge .. ")")
	end
	
	-- 2. Check category validity
	if eventDef.category then
		if not LifeStageSystem.isCategoryValid(eventDef.category, state) then
			validationResult.valid = false
			table.insert(validationResult.reasons, "Category not available at this life stage")
		end
	end
	
	-- 3. Check if category is allowed in current stage (but PRISON events bypass stage restrictions when in prison)
	if eventDef.category and stage.eventCategories then
		-- Prison events always allowed when in prison, regardless of stage
		local isPrisonEvent = eventDef.category == "prison"
		local isInPrison = caps.inPrison or flags.in_prison or flags.incarcerated
		
		if not (isPrisonEvent and isInPrison) then
			local categoryAllowed = false
			for _, cat in ipairs(stage.eventCategories) do
				if cat == "all" or cat == eventDef.category then
					categoryAllowed = true
					break
				end
			end
			if not categoryAllowed then
				validationResult.valid = false
				table.insert(validationResult.reasons, "Event category not available in " .. stage.name .. " stage")
			end
		end
	end
	
	-- 4. Check one-time events
	if eventDef.oneTime then
		local history = state.EventHistory or {}
		local seen = history.seenEvents or {}
		if seen[eventDef.id] then
			validationResult.valid = false
			table.insert(validationResult.reasons, "One-time event already occurred")
		end
	end
	
	-- 5. Check cooldown
	if eventDef.cooldown then
		local history = state.EventHistory or {}
		local lastOccurrence = history.lastOccurrence or {}
		local lastAge = lastOccurrence[eventDef.id]
		if lastAge and (age - lastAge) < eventDef.cooldown then
			validationResult.valid = false
			table.insert(validationResult.reasons, "Event on cooldown")
		end
	end
	
	-- 6. Check custom requires function
	if eventDef.requires then
		local ok, canFire = pcall(eventDef.requires, state)
		if not ok or not canFire then
			validationResult.valid = false
			table.insert(validationResult.reasons, "Requirements not met")
		end
	end
	
	-- 7. Check requiresFlag (single required flag)
	if eventDef.requiresFlag then
		if not flags[eventDef.requiresFlag] then
			validationResult.valid = false
			table.insert(validationResult.reasons, "Missing required flag: " .. eventDef.requiresFlag)
		end
	end
	
	-- 8. Check requiresFlag2 (second required flag)
	if eventDef.requiresFlag2 then
		if not flags[eventDef.requiresFlag2] then
			validationResult.valid = false
			table.insert(validationResult.reasons, "Missing required flag: " .. eventDef.requiresFlag2)
		end
	end
	
	-- 9. Check requiresAnyFlag (any of these flags must be present)
	if eventDef.requiresAnyFlag and type(eventDef.requiresAnyFlag) == "table" then
		local hasAny = false
		for _, flagName in ipairs(eventDef.requiresAnyFlag) do
			if flags[flagName] then
				hasAny = true
				break
			end
		end
		if not hasAny then
			validationResult.valid = false
			table.insert(validationResult.reasons, "Missing any required flag from: " .. table.concat(eventDef.requiresAnyFlag, ", "))
		end
	end
	
	-- 10. Check blockIfFlag (event blocked if this flag exists)
	if eventDef.blockIfFlag then
		if flags[eventDef.blockIfFlag] then
			validationResult.valid = false
			table.insert(validationResult.reasons, "Blocked by flag: " .. eventDef.blockIfFlag)
		end
	end
	
	-- 11. Check blockIfFlag2 (second blocking flag)
	if eventDef.blockIfFlag2 then
		if flags[eventDef.blockIfFlag2] then
			validationResult.valid = false
			table.insert(validationResult.reasons, "Blocked by flag: " .. eventDef.blockIfFlag2)
		end
	end
	
	-- 12. Check prison-specific (event requires being in prison)
	if eventDef.category == "prison" then
		local isInPrison = caps.inPrison or flags.in_prison or flags.incarcerated
		if not isInPrison then
			validationResult.valid = false
			table.insert(validationResult.reasons, "Not in prison")
		end
	end
	
	-- 13. Block NON-prison events when IN prison (except family, health, milestone)
	local isInPrison = caps.inPrison or flags.in_prison or flags.incarcerated
	if isInPrison and eventDef.category then
		local allowedInPrison = {
			prison = true,
			family = true,    -- Can still have family events
			health = true,    -- Health events still happen
			milestone = true, -- Milestones still occur
		}
		if not allowedInPrison[eventDef.category] then
			validationResult.valid = false
			table.insert(validationResult.reasons, "Event category '" .. eventDef.category .. "' blocked while in prison")
		end
	end
	
	-- 14. Check school events
	if eventDef.category == "school" and not isInPrison then
		local inSchool = caps.inSchool or (age >= 5 and age <= 18)
		if not inSchool and not flags.college_student then
			validationResult.valid = false
			table.insert(validationResult.reasons, "Not in school")
		end
	end
	
	-- Final debug log for prison events or when debugging
	local DEBUG_EVENT_VALIDATION = false
	if DEBUG_EVENT_VALIDATION or eventDef.category == "prison" then
		if validationResult.valid then
			print("[LifeStageSystem] ✅ Event", eventDef.id, "PASSED validation")
		else
			print("[LifeStageSystem] ❌ Event", eventDef.id, "FAILED validation - Reasons:", table.concat(validationResult.reasons, ", "))
		end
	end
	
	return validationResult
end

-- Filter a list of events to only valid ones
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

-- Pick best event for current state
function LifeStageSystem.pickBestEvent(events, state)
	local validEvents = LifeStageSystem.filterValidEvents(events, state)
	
	if #validEvents == 0 then
		return nil
	end
	
	-- Prioritize milestones
	for _, event in ipairs(validEvents) do
		if event.milestone then
			return event
		end
	end
	
	-- Weighted random selection
	local totalWeight = 0
	for _, event in ipairs(validEvents) do
		totalWeight = totalWeight + (event.weight or 10)
	end
	
	local roll = math.random() * totalWeight
	local cumulative = 0
	
	for _, event in ipairs(validEvents) do
		cumulative = cumulative + (event.weight or 10)
		if roll <= cumulative then
			return event
		end
	end
	
	return validEvents[#validEvents]
end

----------------------------------------------------------------------
-- STAGE TRANSITION EVENTS
----------------------------------------------------------------------

LifeStageSystem.StageTransitionEvents = {
	infant_to_toddler = {
		emoji = "🎂",
		title = "Growing Up!",
		text = "You're not a baby anymore! You're learning to walk and talk.",
	},
	toddler_to_child = {
		emoji = "🎒",
		title = "Off to School!",
		text = "It's time to start elementary school! A whole new world awaits.",
	},
	child_to_tween = {
		emoji = "📱",
		title = "Middle School!",
		text = "You're entering middle school. Things are about to get interesting...",
	},
	tween_to_teen = {
		emoji = "🎓",
		title = "High School!",
		text = "Welcome to high school! These years will shape who you become.",
	},
	teen_to_young_adult = {
		emoji = "🎉",
		title = "You're an Adult!",
		text = "You've turned 18! The world is yours. What will you do with it?",
	},
	young_adult_to_adult = {
		emoji = "💼",
		title = "Full Adulthood",
		text = "Your 20s are behind you. Time to get serious about life.",
	},
	adult_to_middle_age = {
		emoji = "🔮",
		title = "Middle Age",
		text = "You've hit middle age. Time to reflect on what you've accomplished.",
	},
	middle_age_to_senior = {
		emoji = "🏖️",
		title = "Senior Years",
		text = "Retirement age is here. You've earned some rest.",
	},
	senior_to_elder = {
		emoji = "🕯️",
		title = "Elder Status",
		text = "You're now an elder. Every day is a gift.",
	},
}

-- Get transition event if applicable
function LifeStageSystem.getTransitionEvent(oldAge, newAge)
	local transition = LifeStageSystem.checkStageTransition(oldAge, newAge)
	
	if transition.transitioned then
		local key = transition.from.id .. "_to_" .. transition.to.id
		local transitionEvent = LifeStageSystem.StageTransitionEvents[key]
		
		if transitionEvent then
			return {
				id = "stage_transition_" .. key,
				emoji = transitionEvent.emoji,
				title = transitionEvent.title,
				text = transitionEvent.text,
				category = "milestone",
				milestone = true,
				fromStage = transition.from,
				toStage = transition.to,
			}
		end
	end
	
	return nil
end

----------------------------------------------------------------------
-- DEATH SYSTEM
----------------------------------------------------------------------

-- Calculate death chance based on age and health
function LifeStageSystem.calculateDeathChance(state)
	local age = state.Age or 0
	local health = state.Stats and state.Stats.Health or state.Health or 50
	local flags = state.Flags or {}
	
	-- Base death chance by age
	local baseChance = 0
	if age < 50 then
		baseChance = 0.001 -- Very low
	elseif age < 60 then
		baseChance = 0.005
	elseif age < 70 then
		baseChance = 0.02
	elseif age < 80 then
		baseChance = 0.05
	elseif age < 90 then
		baseChance = 0.15
	elseif age < 100 then
		baseChance = 0.30
	else
		baseChance = 0.50
	end
	
	-- Modify by health
	local healthMod = (100 - health) / 100
	baseChance = baseChance * (1 + healthMod)
	
	-- Modify by flags
	if flags.terminal_illness then
		baseChance = baseChance * 5
	end
	if flags.drug_addict then
		baseChance = baseChance * 2
	end
	if flags.alcoholic then
		baseChance = baseChance * 1.5
	end
	if flags.healthy_lifestyle then
		baseChance = baseChance * 0.5
	end
	
	return math.min(baseChance, 0.99) -- Cap at 99%
end

-- Check if player dies this year
function LifeStageSystem.checkDeath(state)
	local chance = LifeStageSystem.calculateDeathChance(state)
	local roll = math.random()
	
	if roll < chance then
		-- Determine cause of death
		local causes = {"old age", "heart attack", "stroke", "cancer", "accident"}
		local age = state.Age or 0
		
		if age >= 80 then
			table.insert(causes, "natural causes")
			table.insert(causes, "peacefully in sleep")
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

----------------------------------------------------------------------
-- UTILITY FUNCTIONS
----------------------------------------------------------------------

-- Get a summary of current life stage for UI
function LifeStageSystem.getStageSummary(state)
	local stage = LifeStageSystem.getStage(state.Age or 0)
	local caps = LifeStageSystem.getCapabilities(state)
	
	return {
		stage = stage,
		capabilities = caps,
		age = state.Age or 0,
		emoji = stage.emoji,
		name = stage.name,
		description = stage.description,
	}
end

-- Serialize for client
function LifeStageSystem.serializeForClient(state)
	local stage = LifeStageSystem.getStage(state.Age or 0)
	local caps = LifeStageSystem.getCapabilities(state)
	
	return {
		stageId = stage.id,
		stageName = stage.name,
		stageEmoji = stage.emoji,
		age = state.Age or 0,
		canWork = caps.canWork,
		canDate = caps.canDate,
		canDrive = caps.canDrive,
		canCrime = caps.canCrime,
		canDrink = caps.canDrink,
		canVote = caps.canVote,
		canGamble = caps.canGamble,
		inSchool = caps.inSchool,
		inPrison = caps.inPrison,
	}
end

return LifeStageSystem
