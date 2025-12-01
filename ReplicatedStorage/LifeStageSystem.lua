-- LifeStageSystem.lua
-- Comprehensive BitLife-style life stage management.
-- Controls what events, actions, and content are available at each stage.

local LifeStageSystem = {}

----------------------------------------------------------------------
-- CONFIG / DEBUG
----------------------------------------------------------------------

local DEBUG_EVENT_VALIDATION = false

local function dprint(...)
	if DEBUG_EVENT_VALIDATION then
		print("[LifeStageSystem]", ...)
	end
end

----------------------------------------------------------------------
-- LIFE STAGES DEFINITION
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
		activities = { "cry", "sleep", "eat", "crawl" },
		eventCategories = { "family", "health", "milestone" },
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
		activities = { "play", "learn", "tantrum" },
		eventCategories = { "family", "health", "milestone", "social" },
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
		activities = { "study", "play", "sports", "clubs" },
		eventCategories = { "family", "health", "school", "social", "milestone" },
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
		canCrime = true, -- minor stuff
		canDrink = false,
		canVote = false,
		canGamble = false,
		inSchool = true,
		schoolType = "middle",
		activities = { "study", "sports", "clubs", "hangout", "social_media" },
		eventCategories = { "family", "health", "school", "social", "romance", "milestone" },
	},

	TEEN = {
		id = "teen",
		name = "Teenager",
		emoji = "🧑‍🎤",
		minAge = 14, maxAge = 17,
		description = "High school - dating, driving, and planning your future.",
		canWork = true, -- part-time
		canDate = true,
		canDrive = true, -- at 16
		canCrime = true,
		canDrink = false,
		canVote = false,
		canGamble = false,
		inSchool = true,
		schoolType = "highschool",
		activities = { "study", "work_parttime", "sports", "clubs", "date", "party", "drive" },
		eventCategories = { "family", "health", "school", "social", "romance", "work", "crime", "milestone" },
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
		canDrink = true, -- at 21
		canVote = true,
		canGamble = true, -- at 21
		inSchool = false, -- optional college
		schoolType = "university",
		activities = { "work", "study", "date", "party", "travel", "invest", "crime" },
		eventCategories = { "all" },
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
		activities = { "work", "date", "marry", "kids", "invest", "travel", "hobby" },
		eventCategories = { "all" },
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
		activities = { "work", "retire_early", "invest", "travel", "grandkids" },
		eventCategories = { "all" },
	},

	SENIOR = {
		id = "senior",
		name = "Senior",
		emoji = "🧓",
		minAge = 61, maxAge = 75,
		description = "Retirement, grandchildren, and enjoying life's rewards.",
		canWork = true, -- optional
		canDate = true,
		canDrive = true,
		canCrime = true,
		canDrink = true,
		canVote = true,
		canGamble = true,
		inSchool = false,
		schoolType = nil,
		activities = { "retire", "travel", "grandkids", "hobby", "volunteer" },
		eventCategories = { "family", "health", "social", "money", "milestone" },
	},

	ELDER = {
		id = "elder",
		name = "Elder",
		emoji = "👴",
		minAge = 76, maxAge = 120,
		description = "The twilight years - legacy and reflection.",
		canWork = false,
		canDate = true,
		canDrive = false,
		canCrime = false,
		canDrink = true,
		canVote = true,
		canGamble = true,
		inSchool = false,
		schoolType = nil,
		activities = { "rest", "family", "legacy", "reminisce" },
		eventCategories = { "family", "health", "milestone", "death" },
	},
}

LifeStageSystem.StageOrder = {
	"INFANT", "TODDLER", "CHILD", "TWEEN", "TEEN",
	"YOUNG_ADULT", "ADULT", "MIDDLE_AGE", "SENIOR", "ELDER",
}

----------------------------------------------------------------------
-- EVENT CATEGORY DEFINITIONS
----------------------------------------------------------------------

LifeStageSystem.EventCategories = {
	-- ═══════════════════════════════════════════════════════════════
	-- CORE LIFE CATEGORIES (always available at appropriate ages)
	-- ═══════════════════════════════════════════════════════════════
	
	family = {
		name = "Family",
		emoji = "👨‍👩‍👧",
		description = "Events involving family members.",
		minAge = 0,
		maxAge = 120,
	},

	health = {
		name = "Health",
		emoji = "🏥",
		description = "Health-related events.",
		minAge = 0,
		maxAge = 120,
	},

	school = {
		name = "School",
		emoji = "🏫",
		description = "Education events.",
		minAge = 5,
		maxAge = 30,
	},
	
	education = {
		name = "Education",
		emoji = "📚",
		description = "Education and learning events.",
		minAge = 5,
		maxAge = 60,
	},

	social = {
		name = "Social",
		emoji = "👥",
		description = "Friendships and social situations.",
		minAge = 3,
		maxAge = 120,
	},

	romance = {
		name = "Romance",
		emoji = "💕",
		description = "Dating and relationships.",
		minAge = 12,
		maxAge = 120,
	},

	work = {
		name = "Work",
		emoji = "💼",
		description = "Career and job events.",
		minAge = 14,
		maxAge = 75,
	},

	money = {
		name = "Money",
		emoji = "💰",
		description = "Financial events.",
		minAge = 10,
		maxAge = 120,
	},

	milestone = {
		name = "Milestone",
		emoji = "🎉",
		description = "Major life milestones.",
		minAge = 0,
		maxAge = 120,
	},
	
	life = {
		name = "Life",
		emoji = "🌟",
		description = "General life events and opportunities.",
		minAge = 0,
		maxAge = 120,
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- CAREER PATH CATEGORIES (require interest/progression flags)
	-- ═══════════════════════════════════════════════════════════════

	crime = {
		name = "Crime",
		emoji = "🔪",
		description = "Criminal activities.",
		minAge = 10,
		maxAge = 70,
		-- Crime category doesn't require a flag - anyone can stumble into crime
		-- But serious criminal events should use requiredAllFlags in the event itself
	},

	prison = {
		name = "Prison",
		emoji = "⛓️",
		description = "Prison-related events.",
		minAge = 14,
		maxAge = 80,
		requiresFlag = "in_prison",
	},

	political = {
		name = "Political",
		emoji = "🏛️",
		description = "Political career events.",
		minAge = 18,
		maxAge = 80,
		requiresFlag = "political_interest",
	},

	racing = {
		name = "Racing",
		emoji = "🏎️",
		description = "Racing career events.",
		minAge = 8,
		maxAge = 50,
		requiresFlag = "racing_interest",
	},

	art = {
		name = "Art",
		emoji = "🎨",
		description = "Art career events.",
		minAge = 7,
		maxAge = 100,
		requiresFlag = "art_interest",
	},

	hacking = {
		name = "Hacking",
		emoji = "💻",
		description = "Hacker/cybersecurity career events.",
		minAge = 12,
		maxAge = 60,
		requiresFlag = "computer_interest",
	},
	
	tech = {
		name = "Tech",
		emoji = "💻",
		description = "Technology and software career events.",
		minAge = 12,
		maxAge = 70,
		-- Tech origin events (like "first coding project") don't require flags
		-- But advanced tech events should use requiredAllFlags in the event
	},
	
	cybersecurity = {
		name = "Cybersecurity",
		emoji = "🔐",
		description = "Security and ethical hacking events.",
		minAge = 16,
		maxAge = 65,
		requiresFlag = "security_interested",
	},

	teaching = {
		name = "Teaching",
		emoji = "📚",
		description = "Teaching career events.",
		minAge = 22,
		maxAge = 70,
		requiresFlag = "teaching_interest",
	},
	
	medical = {
		name = "Medical",
		emoji = "🏥",
		description = "Medical career events.",
		minAge = 16,
		maxAge = 80,
		requiresFlag = "medical_interest_sparked",
	},
	
	legal = {
		name = "Legal",
		emoji = "⚖️",
		description = "Legal career events.",
		minAge = 18,
		maxAge = 75,
		requiresFlag = "legal_interest",
	},
	
	business = {
		name = "Business",
		emoji = "📈",
		description = "Business and entrepreneurship events.",
		minAge = 16,
		maxAge = 80,
		-- Business doesn't require a flag - anyone can start
	},
	
	military = {
		name = "Military",
		emoji = "🎖️",
		description = "Military career events.",
		minAge = 17,
		maxAge = 65,
		requiresFlag = "military_interest",
	},
	
	sports = {
		name = "Sports",
		emoji = "⚽",
		description = "Sports career events.",
		minAge = 8,
		maxAge = 45,
		requiresFlag = "sports_interest",
	},
	
	entertainment = {
		name = "Entertainment",
		emoji = "🎬",
		description = "Entertainment and fame events.",
		minAge = 10,
		maxAge = 80,
	},
	
	fame = {
		name = "Fame",
		emoji = "⭐",
		description = "Fame and celebrity events.",
		minAge = 14,
		maxAge = 100,
	},

	death = {
		name = "Death",
		emoji = "💀",
		description = "End of life events.",
		minAge = 60,
		maxAge = 120,
	},
}

-- Categories allowed to still fire while in prison
local PRISON_ALLOWED_CATEGORIES = {
	prison = true,
	family = true,
	health = true,
	milestone = true,
}

----------------------------------------------------------------------
-- CORE STAGE HELPERS
----------------------------------------------------------------------

function LifeStageSystem.getStage(age)
	for _, stageKey in ipairs(LifeStageSystem.StageOrder) do
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
			transitioned = true,
			from = oldStage,
			to = newStage,
		}
	end

	return { transitioned = false }
end

----------------------------------------------------------------------
-- CATEGORY / CAPABILITY HELPERS
----------------------------------------------------------------------

function LifeStageSystem.isCategoryValid(category, state)
	local catDef = LifeStageSystem.EventCategories[category]
	if not catDef then
		return true -- unknown category: treat as allowed
	end

	local age = state.Age or 0
	if age < catDef.minAge or age > catDef.maxAge then
		return false
	end

	if catDef.requiresFlag then
		local flags = state.Flags or {}
		if not flags[catDef.requiresFlag] then
			return false
		end
	end

	return true
end

function LifeStageSystem.canDoActivity(activityId, state)
	local stage = LifeStageSystem.getStage(state.Age or 0)
	for _, allowed in ipairs(stage.activities) do
		if allowed == activityId then
			return true
		end
	end
	return false
end

function LifeStageSystem.getAvailableActivities(state)
	local stage = LifeStageSystem.getStage(state.Age or 0)
	return stage.activities
end

function LifeStageSystem.getCapabilities(state)
	local stage = LifeStageSystem.getStage(state.Age or 0)
	local age = state.Age or 0
	local flags = state.Flags or {}

	local inPrison = flags.in_prison or flags.incarcerated or state.InJail
	
	-- Check dropout/expelled status
	local hasDroppedOut = flags.dropped_out or flags.expelled or flags.quit_school
	
	-- Determine if in school: must be in school-age stage AND not dropped out
	-- OR be a college student (separate enrollment)
	local inSchool = (stage.inSchool and not hasDroppedOut) or flags.college_student

	return {
		canWork = stage.canWork and age >= 14 and not inPrison,
		canWorkFullTime = stage.canWork and age >= 18 and not inPrison,
		canDate = stage.canDate and age >= 12,
		canMarry = stage.canDate and age >= 18,
		canDrive = stage.canDrive and age >= 16 and flags.has_license,
		canCrime = stage.canCrime and age >= 10,
		canDrink = stage.canDrink and age >= 21,
		canVote = stage.canVote and age >= 18,
		canGamble = stage.canGamble and age >= 21,
		canEnrollCollege = age >= 18 and age <= 50,
		canRetire = age >= 50,

		inSchool = inSchool,
		schoolType = flags.college_student and "university" or stage.schoolType,
		hasDroppedOut = hasDroppedOut,

		canStartPolitics = age >= 18 and flags.political_interest,
		canStartRacing = age >= 16 and flags.racing_interest,
		canStartArt = age >= 16 and flags.art_interest,
		canStartHacking = age >= 16 and flags.computer_interest,
		canStartTeaching = age >= 22 and flags.teaching_interest,
		canStartCrime = age >= 16 and (flags.criminal_tendencies or flags.gang_member),

		inPrison = inPrison,
		isFugitive = flags.fugitive,
		isPregnant = flags.pregnant,
		isMarried = flags.married,
		hasKids = flags.has_children,
	}
end

----------------------------------------------------------------------
-- EVENT VALIDATION (SERVER-SIDE)
----------------------------------------------------------------------

function LifeStageSystem.validateEvent(eventDef, state)
	local result = {
		valid = true,
		reasons = {},
	}

	local age = state.Age or 0
	local flags = state.Flags or {}
	local stage = LifeStageSystem.getStage(age)
	local caps = LifeStageSystem.getCapabilities(state)

	if DEBUG_EVENT_VALIDATION or eventDef.category == "prison" then
		dprint("=== VALIDATING EVENT ===")
		dprint("Event:", eventDef.id, "Category:", eventDef.category or "none")
		dprint("Age:", age, "Stage:", stage.id)
		dprint("InPrison:", caps.inPrison, "flag in_prison:", flags.in_prison or false)
		if eventDef.requiresFlag then
			dprint("requiresFlag:", eventDef.requiresFlag, "has:", flags[eventDef.requiresFlag] or false)
		end
		if eventDef.requiresFlag2 then
			dprint("requiresFlag2:", eventDef.requiresFlag2, "has:", flags[eventDef.requiresFlag2] or false)
		end
		if eventDef.blockIfFlag then
			dprint("blockIfFlag:", eventDef.blockIfFlag, "has:", flags[eventDef.blockIfFlag] or false)
		end
	end

	-- 1. Age range (check both top-level and conditions for compatibility)
	local minAge = eventDef.minAge or (eventDef.conditions and eventDef.conditions.minAge)
	local maxAge = eventDef.maxAge or (eventDef.conditions and eventDef.conditions.maxAge)
	
	if minAge and age < minAge then
		result.valid = false
		table.insert(result.reasons, "Too young (need " .. minAge .. ", have " .. age .. ")")
	end

	if maxAge and age > maxAge then
		result.valid = false
		table.insert(result.reasons, "Too old (max " .. maxAge .. ", have " .. age .. ")")
	end

	-- 2. Category base validity (age + required flag)
	if eventDef.category then
		if not LifeStageSystem.isCategoryValid(eventDef.category, state) then
			result.valid = false
			table.insert(result.reasons, "Category not available at this life stage")
		end
	end

	-- 3. Stage's eventCategories gating
	if eventDef.category and stage.eventCategories then
		local isPrisonEvent = eventDef.category == "prison"
		local isInPrison = caps.inPrison

		if not (isPrisonEvent and isInPrison) then
			local categoryAllowed = false
			for _, cat in ipairs(stage.eventCategories) do
				if cat == "all" or cat == eventDef.category then
					categoryAllowed = true
					break
				end
			end
			if not categoryAllowed then
				result.valid = false
				table.insert(result.reasons, "Event category not available in " .. stage.name .. " stage")
			end
		end
	end

	-- 4. One-time events
	if eventDef.oneTime then
		local history = state.EventHistory or {}
		local seen = history.seenEvents or {}
		if seen[eventDef.id] then
			result.valid = false
			table.insert(result.reasons, "One-time event already occurred")
		end
	end

	-- 5. Cooldown
	if eventDef.cooldown then
		local history = state.EventHistory or {}
		local lastOccurrence = history.lastOccurrence or {}
		local lastAge = lastOccurrence[eventDef.id]
		if lastAge and (age - lastAge) < eventDef.cooldown then
			result.valid = false
			table.insert(result.reasons, "Event on cooldown")
		end
	end

	-- 6. Custom requires callback (check both legacy and normalized format)
	local customRequires = eventDef.requires or (eventDef.conditions and eventDef.conditions.custom)
	if customRequires and type(customRequires) == "function" then
		local ok, canFire = pcall(customRequires, state)
		if not ok then
			result.valid = false
			table.insert(result.reasons, "Requirements check failed: " .. tostring(canFire))
		elseif not canFire then
			result.valid = false
			table.insert(result.reasons, "Custom requirements not met")
		end
	end
	
	-- 6b. Check stat requirements (minStats)
	local minStats = eventDef.minStats or (eventDef.conditions and eventDef.conditions.minStats)
	if minStats and type(minStats) == "table" then
		local stats = state.Stats or {}
		for statName, minValue in pairs(minStats) do
			local currentValue = stats[statName] or state[statName] or 0
			if currentValue < minValue then
				result.valid = false
				table.insert(result.reasons, "Insufficient " .. statName .. " (need " .. minValue .. ", have " .. currentValue .. ")")
			end
		end
	end
	
	-- 6c. Check money requirements
	local minMoney = eventDef.minMoney or (eventDef.conditions and eventDef.conditions.minMoney)
	if minMoney then
		local currentMoney = state.Money or 0
		if currentMoney < minMoney then
			result.valid = false
			table.insert(result.reasons, "Insufficient money (need $" .. minMoney .. ", have $" .. currentMoney .. ")")
		end
	end

	-- 7. Simple required flags (check both legacy and normalized format)
	if eventDef.requiresFlag and not flags[eventDef.requiresFlag] then
		result.valid = false
		table.insert(result.reasons, "Missing required flag: " .. eventDef.requiresFlag)
	end

	if eventDef.requiresFlag2 and not flags[eventDef.requiresFlag2] then
		result.valid = false
		table.insert(result.reasons, "Missing required flag: " .. eventDef.requiresFlag2)
	end
	
	-- 7b. Check normalized conditions.requiredAllFlags
	local conditions = eventDef.conditions or {}
	if conditions.requiredAllFlags and type(conditions.requiredAllFlags) == "table" then
		for _, flagName in ipairs(conditions.requiredAllFlags) do
			if not flags[flagName] then
				result.valid = false
				table.insert(result.reasons, "Missing required flag: " .. flagName)
				break
			end
		end
	end

	-- 8. Any-of flags (check both legacy and normalized format)
	if eventDef.requiresAnyFlag and type(eventDef.requiresAnyFlag) == "table" then
		local hasAny = false
		for _, flagName in ipairs(eventDef.requiresAnyFlag) do
			if flags[flagName] then
				hasAny = true
				break
			end
		end
		if not hasAny then
			result.valid = false
			table.insert(result.reasons, "Missing any required flag from: " .. table.concat(eventDef.requiresAnyFlag, ", "))
		end
	end
	
	-- 8b. Check normalized conditions.requiredAnyFlags
	if conditions.requiredAnyFlags and type(conditions.requiredAnyFlags) == "table" then
		local hasAny = false
		for _, flagName in ipairs(conditions.requiredAnyFlags) do
			if flags[flagName] then
				hasAny = true
				break
			end
		end
		if not hasAny then
			result.valid = false
			table.insert(result.reasons, "Missing any required flag from: " .. table.concat(conditions.requiredAnyFlags, ", "))
		end
	end

	-- 9. Block flags (check both legacy and normalized format)
	if eventDef.blockIfFlag and flags[eventDef.blockIfFlag] then
		result.valid = false
		table.insert(result.reasons, "Blocked by flag: " .. eventDef.blockIfFlag)
	end

	if eventDef.blockIfFlag2 and flags[eventDef.blockIfFlag2] then
		result.valid = false
		table.insert(result.reasons, "Blocked by flag: " .. eventDef.blockIfFlag2)
	end
	
	-- 9b. Check normalized conditions.blockedFlags
	if conditions.blockedFlags and type(conditions.blockedFlags) == "table" then
		for _, flagName in ipairs(conditions.blockedFlags) do
			if flags[flagName] then
				result.valid = false
				table.insert(result.reasons, "Blocked by flag: " .. flagName)
				break
			end
		end
	end

	-- 10. Prison events must be in prison
	if eventDef.category == "prison" then
		if not caps.inPrison then
			result.valid = false
			table.insert(result.reasons, "Not in prison")
		end
	end

	-- 11. When in prison, block most non-prison categories
	if caps.inPrison and eventDef.category then
		if not PRISON_ALLOWED_CATEGORIES[eventDef.category] then
			result.valid = false
			table.insert(result.reasons, "Event category '" .. eventDef.category .. "' blocked while in prison")
		end
	end

	-- 12. School events require being in school or college
	if eventDef.category == "school" and not caps.inPrison then
		-- Check dropout/expelled flags first - these block school events entirely
		local hasDroppedOut = flags.dropped_out or flags.expelled or flags.quit_school
		if hasDroppedOut and not flags.college_student then
			result.valid = false
			table.insert(result.reasons, "Dropped out of school")
		else
			local inSchool = caps.inSchool or (age >= 5 and age <= 18 and not hasDroppedOut)
			if not inSchool and not flags.college_student then
				result.valid = false
				table.insert(result.reasons, "Not in school")
			end
		end
	end

	-- ═══════════════════════════════════════════════════════════════
	-- 13. CAREER VALIDATION (requiredCareerId, requiredCareerMinTier)
	-- This is CRITICAL for path-gated events
	-- ═══════════════════════════════════════════════════════════════
	
	local requiredCareerId = eventDef.requiredCareerId or (conditions and conditions.requiredCareerId)
	if requiredCareerId then
		local career = state.Career or {}
		local currentCareerId = career.path or career.id
		
		-- Check if player has the required career
		if currentCareerId ~= requiredCareerId then
			-- Also check flags for career (some systems use flags instead of Career table)
			local hasCareerFlag = flags["career_" .. requiredCareerId] or flags["career_" .. requiredCareerId .. "_started"]
			if not hasCareerFlag then
				result.valid = false
				table.insert(result.reasons, "Requires career: " .. requiredCareerId)
			end
		end
	end
	
	local requiredCareerMinTier = eventDef.requiredCareerMinTier or (conditions and conditions.requiredCareerMinTier)
	if requiredCareerMinTier and requiredCareerMinTier > 0 then
		local career = state.Career or {}
		local currentTier = career.tier or career.level or 0
		
		-- If tier not tracked in Career, estimate from experience or flags
		if currentTier == 0 then
			local experience = career.experience or 0
			if experience >= 10 then currentTier = 3
			elseif experience >= 5 then currentTier = 2
			elseif experience >= 1 then currentTier = 1
			end
		end
		
		if currentTier < requiredCareerMinTier then
			result.valid = false
			table.insert(result.reasons, "Requires career tier " .. requiredCareerMinTier .. " (have tier " .. currentTier .. ")")
		end
	end

	-- ═══════════════════════════════════════════════════════════════
	-- 14. EDUCATION VALIDATION (requiredEducation)
	-- ═══════════════════════════════════════════════════════════════
	
	local requiredEducation = eventDef.requiredEducation or (conditions and conditions.requiredEducation)
	if requiredEducation then
		local education = state.Education or {}
		local currentLevel = education.level or state.EducationLevel or "none"
		
		-- Education hierarchy
		local educationLevels = {
			none = 0,
			elementary = 1,
			middle = 2,
			high_school = 3,
			highschool = 3,
			some_college = 4,
			associate = 5,
			bachelor = 6,
			bachelors = 6,
			master = 7,
			masters = 7,
			doctorate = 8,
			phd = 8,
		}
		
		local requiredLevel = educationLevels[requiredEducation] or 0
		local currentLevelNum = educationLevels[currentLevel] or 0
		
		if currentLevelNum < requiredLevel then
			result.valid = false
			table.insert(result.reasons, "Requires education: " .. requiredEducation)
		end
	end

	-- ═══════════════════════════════════════════════════════════════
	-- 15. MAX STATS VALIDATION (maxStats - e.g., events for poor/unhealthy)
	-- ═══════════════════════════════════════════════════════════════
	
	local maxStats = eventDef.maxStats or (conditions and conditions.maxStats)
	if maxStats and type(maxStats) == "table" then
		local stats = state.Stats or {}
		for statName, maxValue in pairs(maxStats) do
			local currentValue = 0
			if statName == "Money" then
				currentValue = state.Money or 0
			else
				currentValue = stats[statName] or state[statName] or 50
			end
			if currentValue > maxValue then
				result.valid = false
				table.insert(result.reasons, statName .. " too high (max " .. maxValue .. ", have " .. currentValue .. ")")
			end
		end
	end

	-- ═══════════════════════════════════════════════════════════════
	-- 16. DYNAMIC DATA VALIDATION
	-- If getDynamicData returns nil, the event cannot fire
	-- This prevents events with missing required relationships from firing
	-- ═══════════════════════════════════════════════════════════════
	
	if result.valid and eventDef.getDynamicData then
		local ok, dynamicData = pcall(eventDef.getDynamicData, state)
		if not ok then
			result.valid = false
			table.insert(result.reasons, "getDynamicData failed: " .. tostring(dynamicData))
		elseif dynamicData == nil then
			result.valid = false
			table.insert(result.reasons, "getDynamicData returned nil (missing required data)")
		end
	end

	if DEBUG_EVENT_VALIDATION or eventDef.category == "prison" then
		if result.valid then
			dprint("✅ Event", eventDef.id, "PASSED validation")
		else
			dprint("❌ Event", eventDef.id, "FAILED validation - Reasons:", table.concat(result.reasons, ", "))
		end
	end

	return result
end

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

function LifeStageSystem.pickBestEvent(events, state)
	local validEvents = LifeStageSystem.filterValidEvents(events, state)
	if #validEvents == 0 then
		return nil
	end

	-- Milestones first
	for _, event in ipairs(validEvents) do
		if event.milestone then
			return event
		end
	end

	-- Weighted random
	local totalWeight = 0
	for _, event in ipairs(validEvents) do
		totalWeight += (event.weight or 10)
	end

	if totalWeight <= 0 then
		return validEvents[#validEvents]
	end

	local roll = math.random() * totalWeight
	local cumulative = 0

	for _, event in ipairs(validEvents) do
		cumulative += (event.weight or 10)
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

function LifeStageSystem.getTransitionEvent(oldAge, newAge)
	local transition = LifeStageSystem.checkStageTransition(oldAge, newAge)
	if transition.transitioned then
		local key = transition.from.id .. "_to_" .. transition.to.id
		local tEvent = LifeStageSystem.StageTransitionEvents[key]
		if tEvent then
			return {
				id = "stage_transition_" .. key,
				emoji = tEvent.emoji,
				title = tEvent.title,
				text = tEvent.text,
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
-- DEATH SYSTEM (BITLIFE-STYLE)
-- Health = 0% means INSTANT DEATH with contextual cause
----------------------------------------------------------------------

-- Get a contextual death cause based on the player's life circumstances
function LifeStageSystem.getDeathCause(state)
	local age = state.Age or 0
	local flags = state.Flags or {}
	local stats = state.Stats or {}
	local health = stats.Health or state.Health or 0
	local healthConditions = state.HealthConditions or {}
	local addictions = state.Addictions or {}
	
	-- Build a list of possible causes weighted by relevance
	local possibleCauses = {}
	
	-- ═══════════════════════════════════════════════════════════════
	-- HEALTH CONDITIONS (from HealthConditions table - prioritized)
	-- ═══════════════════════════════════════════════════════════════
	
	for _, condition in ipairs(healthConditions) do
		local severity = condition.severity or "mild"
		local conditionId = condition.id or ""
		local conditionName = condition.name or conditionId
		
		if severity == "terminal" or severity == "severe" then
			if conditionId == "cancer" then
				table.insert(possibleCauses, { cause = "cancer", weight = 100 })
				table.insert(possibleCauses, { cause = "a long battle with " .. conditionName, weight = 80 })
			elseif conditionId == "heart_disease" or conditionId == "heart_condition" then
				table.insert(possibleCauses, { cause = "heart failure", weight = 100 })
				table.insert(possibleCauses, { cause = "a massive heart attack", weight = 80 })
			elseif conditionId == "stroke" then
				table.insert(possibleCauses, { cause = "a stroke", weight = 100 })
			elseif conditionId == "lung_disease" or conditionId == "copd" then
				table.insert(possibleCauses, { cause = "respiratory failure", weight = 100 })
			elseif conditionId == "kidney_disease" or conditionId == "kidney_failure" then
				table.insert(possibleCauses, { cause = "kidney failure", weight = 100 })
			elseif conditionId == "liver_disease" or conditionId == "cirrhosis" then
				table.insert(possibleCauses, { cause = "liver failure", weight = 100 })
			elseif conditionId == "diabetes" then
				table.insert(possibleCauses, { cause = "diabetes complications", weight = 90 })
			elseif conditionId == "aids" or conditionId == "hiv" then
				table.insert(possibleCauses, { cause = "AIDS-related complications", weight = 100 })
			elseif conditionId == "alzheimers" or conditionId == "dementia" then
				table.insert(possibleCauses, { cause = "Alzheimer's disease", weight = 100 })
			else
				-- Generic severe condition
				table.insert(possibleCauses, { cause = "complications from " .. conditionName, weight = 70 })
			end
		end
	end
	
	-- ═══════════════════════════════════════════════════════════════
	-- ADDICTIONS (from Addictions table)
	-- ═══════════════════════════════════════════════════════════════
	
	for _, addiction in ipairs(addictions) do
		if not addiction.inRecovery then
			local severity = addiction.severity or 0
			local addictionId = addiction.id or ""
			
			if severity >= 60 then  -- Severe addiction
				if addictionId == "heroin" or addictionId == "opioids" then
					table.insert(possibleCauses, { cause = "a drug overdose", weight = 100 })
					table.insert(possibleCauses, { cause = "opioid-related complications", weight = 70 })
				elseif addictionId == "cocaine" or addictionId == "meth" then
					table.insert(possibleCauses, { cause = "a stimulant overdose", weight = 90 })
					table.insert(possibleCauses, { cause = "drug-induced cardiac arrest", weight = 80 })
				elseif addictionId == "alcohol" or addictionId == "alcoholism" then
					table.insert(possibleCauses, { cause = "liver failure", weight = 90 })
					table.insert(possibleCauses, { cause = "alcohol poisoning", weight = 70 })
					table.insert(possibleCauses, { cause = "cirrhosis of the liver", weight = 60 })
				elseif addictionId == "drugs" then
					table.insert(possibleCauses, { cause = "a drug overdose", weight = 100 })
					table.insert(possibleCauses, { cause = "substance abuse complications", weight = 60 })
				end
			end
		end
	end
	
	-- ═══════════════════════════════════════════════════════════════
	-- FLAG-BASED CAUSES (legacy support + special circumstances)
	-- ═══════════════════════════════════════════════════════════════
	
	if health <= 0 then
		-- Check flags for specific health conditions (legacy)
		if flags.terminal_illness or flags.cancer then
			if #possibleCauses == 0 then
				table.insert(possibleCauses, { cause = "cancer", weight = 100 })
				table.insert(possibleCauses, { cause = "a long battle with illness", weight = 80 })
			end
		end
		
		if flags.heart_disease or flags.heart_condition then
			if #possibleCauses == 0 then
				table.insert(possibleCauses, { cause = "heart failure", weight = 100 })
				table.insert(possibleCauses, { cause = "a massive heart attack", weight = 80 })
			end
		end
		
		if flags.drug_addict or flags.drug_addiction then
			if #possibleCauses == 0 then
				table.insert(possibleCauses, { cause = "a drug overdose", weight = 100 })
				table.insert(possibleCauses, { cause = "substance abuse complications", weight = 60 })
			end
		end
		
		if flags.alcoholic or flags.alcohol_addiction then
			if #possibleCauses == 0 then
				table.insert(possibleCauses, { cause = "liver failure", weight = 90 })
				table.insert(possibleCauses, { cause = "alcohol poisoning", weight = 70 })
				table.insert(possibleCauses, { cause = "cirrhosis of the liver", weight = 60 })
			end
		end
		
		if flags.in_prison then
			table.insert(possibleCauses, { cause = "complications while incarcerated", weight = 80 })
			table.insert(possibleCauses, { cause = "a prison altercation", weight = 60 })
			if flags.gang_member then
				table.insert(possibleCauses, { cause = "gang violence in prison", weight = 90 })
			end
		end
		
		if flags.shot or flags.gunshot_wound then
			table.insert(possibleCauses, { cause = "gunshot wounds", weight = 100 })
		end
		
		if flags.stabbed or flags.stab_wound then
			table.insert(possibleCauses, { cause = "stab wounds", weight = 100 })
		end
		
		if flags.car_accident or flags.injured_accident then
			table.insert(possibleCauses, { cause = "injuries sustained in a car accident", weight = 100 })
		end
		
		if flags.diabetes then
			table.insert(possibleCauses, { cause = "diabetes complications", weight = 70 })
		end
		
		if flags.mental_illness or flags.severe_depression then
			table.insert(possibleCauses, { cause = "complications from mental illness", weight = 50 })
		end
		
		if flags.homeless then
			table.insert(possibleCauses, { cause = "exposure to the elements", weight = 70 })
			table.insert(possibleCauses, { cause = "malnutrition", weight = 60 })
		end
		
		-- If no specific causes found, use general health-failure causes
		if #possibleCauses == 0 then
			table.insert(possibleCauses, { cause = "organ failure", weight = 40 })
			table.insert(possibleCauses, { cause = "a sudden medical emergency", weight = 40 })
			table.insert(possibleCauses, { cause = "complications from poor health", weight = 50 })
			table.insert(possibleCauses, { cause = "a severe illness", weight = 30 })
			
			if age < 30 then
				table.insert(possibleCauses, { cause = "a sudden illness", weight = 50 })
				table.insert(possibleCauses, { cause = "an undiagnosed condition", weight = 40 })
			elseif age < 50 then
				table.insert(possibleCauses, { cause = "a heart attack", weight = 40 })
				table.insert(possibleCauses, { cause = "complications from stress", weight = 30 })
			else
				table.insert(possibleCauses, { cause = "a heart attack", weight = 60 })
				table.insert(possibleCauses, { cause = "a stroke", weight = 50 })
			end
		end
	end
	
	-- ═══════════════════════════════════════════════════════════════
	-- AGE-BASED NATURAL CAUSES (for random death checks)
	-- ═══════════════════════════════════════════════════════════════
	
	if #possibleCauses == 0 then
		if age >= 90 then
			table.insert(possibleCauses, { cause = "old age", weight = 100 })
			table.insert(possibleCauses, { cause = "natural causes", weight = 80 })
			table.insert(possibleCauses, { cause = "peacefully in their sleep", weight = 70 })
		elseif age >= 75 then
			table.insert(possibleCauses, { cause = "natural causes", weight = 60 })
			table.insert(possibleCauses, { cause = "a heart attack", weight = 50 })
			table.insert(possibleCauses, { cause = "a stroke", weight = 40 })
			table.insert(possibleCauses, { cause = "old age", weight = 40 })
		elseif age >= 60 then
			table.insert(possibleCauses, { cause = "a heart attack", weight = 50 })
			table.insert(possibleCauses, { cause = "cancer", weight = 40 })
			table.insert(possibleCauses, { cause = "a stroke", weight = 30 })
		elseif age >= 40 then
			table.insert(possibleCauses, { cause = "a heart attack", weight = 30 })
			table.insert(possibleCauses, { cause = "an accident", weight = 40 })
			table.insert(possibleCauses, { cause = "cancer", weight = 30 })
		else
			table.insert(possibleCauses, { cause = "an accident", weight = 50 })
			table.insert(possibleCauses, { cause = "a sudden illness", weight = 30 })
			table.insert(possibleCauses, { cause = "an unexpected tragedy", weight = 20 })
		end
	end
	
	-- Weighted random selection
	local totalWeight = 0
	for _, entry in ipairs(possibleCauses) do
		totalWeight = totalWeight + entry.weight
	end
	
	if totalWeight <= 0 then
		return "unknown causes"
	end
	
	local roll = math.random() * totalWeight
	local cumulative = 0
	
	for _, entry in ipairs(possibleCauses) do
		cumulative = cumulative + entry.weight
		if roll <= cumulative then
			return entry.cause
		end
	end
	
	return possibleCauses[#possibleCauses].cause
end

function LifeStageSystem.calculateDeathChance(state)
	local age = state.Age or 0
	local stats = state.Stats or {}
	local health = stats.Health or state.Health or 50
	local flags = state.Flags or {}
	local healthConditions = state.HealthConditions or {}
	local addictions = state.Addictions or {}
	local fitness = state.Fitness or 50

	-- ═══════════════════════════════════════════════════════════════
	-- INSTANT DEATH: Health at or below 0% = guaranteed death
	-- ═══════════════════════════════════════════════════════════════
	if health <= 0 then
		return 1.0 -- 100% chance of death
	end

	-- Base chance increases with age
	local baseChance = 0
	if age < 50 then
		baseChance = 0.001
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

	-- Health modifier: lower health = higher chance
	-- At 50% health, this doubles the base chance
	-- At 10% health, this nearly guarantees it
	local healthMod = (100 - health) / 100
	baseChance = baseChance * (1 + healthMod * 2)

	-- ═══════════════════════════════════════════════════════════════
	-- HEALTH CONDITIONS (from HealthConditions table, not just flags)
	-- ═══════════════════════════════════════════════════════════════
	for _, condition in ipairs(healthConditions) do
		local severity = condition.severity or "mild"
		local treated = condition.treated or false
		
		if severity == "terminal" then
			baseChance = baseChance * (treated and 3 or 5)
		elseif severity == "severe" then
			baseChance = baseChance * (treated and 1.5 or 2.5)
		elseif severity == "moderate" then
			baseChance = baseChance * (treated and 1.1 or 1.5)
		-- mild conditions have minimal impact on death chance
		end
		
		-- Specific condition multipliers
		if condition.id == "cancer" then
			baseChance = baseChance * (treated and 1.5 or 3)
		elseif condition.id == "heart_disease" or condition.id == "heart_condition" then
			baseChance = baseChance * (treated and 1.3 or 2)
		elseif condition.id == "diabetes" then
			baseChance = baseChance * (treated and 1.1 or 1.5)
		end
	end

	-- ═══════════════════════════════════════════════════════════════
	-- ADDICTIONS (from Addictions table, not just flags)
	-- ═══════════════════════════════════════════════════════════════
	for _, addiction in ipairs(addictions) do
		if not addiction.inRecovery then
			local severity = addiction.severity or 0
			
			-- Higher severity = higher death risk
			if severity >= 80 then
				baseChance = baseChance * 3
			elseif severity >= 60 then
				baseChance = baseChance * 2
			elseif severity >= 40 then
				baseChance = baseChance * 1.5
			elseif severity >= 20 then
				baseChance = baseChance * 1.2
			end
			
			-- Specific addiction type multipliers
			if addiction.id == "heroin" or addiction.id == "opioids" then
				baseChance = baseChance * 2  -- Opioids are particularly deadly
			elseif addiction.id == "cocaine" or addiction.id == "meth" then
				baseChance = baseChance * 1.8
			elseif addiction.id == "alcohol" or addiction.id == "alcoholism" then
				baseChance = baseChance * 1.4
			end
		end
	end

	-- ═══════════════════════════════════════════════════════════════
	-- FITNESS MODIFIER (protects against death)
	-- ═══════════════════════════════════════════════════════════════
	if fitness >= 80 then
		baseChance = baseChance * 0.5  -- Very fit = 50% less likely to die
	elseif fitness >= 60 then
		baseChance = baseChance * 0.7
	elseif fitness >= 40 then
		baseChance = baseChance * 0.85
	elseif fitness < 20 then
		baseChance = baseChance * 1.3  -- Very unfit = 30% more likely to die
	end

	-- ═══════════════════════════════════════════════════════════════
	-- FLAG-BASED MODIFIERS (legacy support + additional factors)
	-- ═══════════════════════════════════════════════════════════════
	if flags.terminal_illness then
		baseChance = baseChance * 5
	end
	if flags.drug_addict or flags.drug_addiction then
		baseChance = baseChance * 2.5
	end
	if flags.alcoholic or flags.alcohol_addiction then
		baseChance = baseChance * 1.8
	end
	if flags.heart_disease or flags.heart_condition then
		baseChance = baseChance * 2
	end
	if flags.healthy_lifestyle then
		baseChance = baseChance * 0.4
	end
	if flags.exercises_regularly then
		baseChance = baseChance * 0.7
	end
	if flags.in_prison and flags.gang_member then
		baseChance = baseChance * 1.5
	end
	if flags.fugitive then
		baseChance = baseChance * 1.3
	end
	if flags.war_veteran then
		baseChance = baseChance * 1.2  -- PTSD, injuries from service
	end
	if flags.homeless then
		baseChance = baseChance * 2  -- Harsh living conditions
	end
	if flags.wealthy or flags.millionaire then
		baseChance = baseChance * 0.8  -- Better healthcare access
	end

	return math.min(baseChance, 0.99)
end

function LifeStageSystem.checkDeath(state)
	local stats = state.Stats or {}
	local health = stats.Health or state.Health or 50
	local age = state.Age or 0
	
	-- ═══════════════════════════════════════════════════════════════
	-- CRITICAL: 0% Health = Immediate death, no random roll needed
	-- ═══════════════════════════════════════════════════════════════
	if health <= 0 then
		local cause = LifeStageSystem.getDeathCause(state)
		return {
			died = true,
			cause = cause,
			age = age,
			wasHealthDeath = true, -- Flag indicating this was a 0% health death
		}
	end
	
	-- Normal random death check for aging/natural causes
	local chance = LifeStageSystem.calculateDeathChance(state)
	local roll = math.random()

	if roll < chance then
		local cause = LifeStageSystem.getDeathCause(state)
		return {
			died = true,
			cause = cause,
			age = age,
			wasHealthDeath = false,
		}
	end

	return { died = false }
end

-- Check if a player should die immediately (call after stat changes)
-- Returns death info if health <= 0, otherwise nil
function LifeStageSystem.checkImmediateDeath(state)
	local stats = state.Stats or {}
	local health = stats.Health or state.Health or 50
	
	if health <= 0 then
		return LifeStageSystem.checkDeath(state)
	end
	
	return nil
end

----------------------------------------------------------------------
-- UI HELPERS
----------------------------------------------------------------------

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

----------------------------------------------------------------------
-- CENTRALIZED STATE VALIDATION HELPERS
-- Use these in events to properly validate player history
----------------------------------------------------------------------

-- Check if player has EVER worked (any job, any time)
function LifeStageSystem.hasEverWorked(state)
	local flags = state.Flags or {}
	return flags.employed or flags.has_job or flags.career_starter 
		or flags.ever_worked or flags.first_job or flags.good_worker 
		or flags.worked_parttime or flags.intern_experience 
		or flags.internship_completed or flags.side_hustler
		or flags.entrepreneur or flags.business_owner
end

-- Check if player is CURRENTLY employed
function LifeStageSystem.isCurrentlyEmployed(state)
	local flags = state.Flags or {}
	return flags.employed or flags.has_job or flags.side_hustler
end

-- Check if player has completed high school (diploma or GED)
function LifeStageSystem.hasHighSchoolEducation(state)
	local flags = state.Flags or {}
	-- Must not be a dropout without GED
	if flags.high_school_dropout and not flags.ged_graduate then
		return false
	end
	return flags.high_school_graduate or flags.ged_graduate or flags.college_student or flags.college_graduate
end

-- Check if player has college education
function LifeStageSystem.hasCollegeEducation(state)
	local flags = state.Flags or {}
	return flags.college_graduate or flags.advanced_degree or flags.bachelors_degree
		or flags.masters_degree or flags.doctorate or flags.phd
end

-- Check if player is currently in school (any level)
function LifeStageSystem.isInSchool(state)
	local caps = LifeStageSystem.getCapabilities(state)
	return caps.inSchool
end

-- Check if player has demonstrated academic excellence
function LifeStageSystem.hasAcademicExcellence(state)
	local flags = state.Flags or {}
	return flags.honors_student or flags.honor_student or flags.valedictorian 
		or flags.award_winner or flags.deans_list or flags.honor_roll 
		or flags.academic_achiever or flags.academic_focused or flags.high_test_scores
		or flags.scholarship or flags.dedicated_student
end

-- Check if player has any friends in relationships
function LifeStageSystem.hasActualFriends(state)
	local relationships = state.Relationships or {}
	for _, rel in pairs(relationships) do
		if (rel.type == "friend" or rel.category == "friends") and rel.alive ~= false then
			return true
		end
	end
	return false
end

-- Check if player has romantic partner
function LifeStageSystem.hasRomanticPartner(state)
	local relationships = state.Relationships or {}
	for _, rel in pairs(relationships) do
		if (rel.type == "romance" or rel.category == "romance") and rel.alive ~= false then
			return true
		end
	end
	local flags = state.Flags or {}
	return flags.in_relationship or flags.married or flags.dating or flags.engaged
end

-- Check if player can afford something (minimum money check)
function LifeStageSystem.canAfford(state, amount)
	return (state.Money or 0) >= amount
end

-- Check if player has any social history (for events about reconnecting, etc.)
function LifeStageSystem.hasSocialHistory(state)
	local flags = state.Flags or {}
	return flags.ever_had_friend or flags.college_graduate or flags.high_school_diploma 
		or flags.social_butterfly or flags.had_childhood_friend or flags.had_college_friends
		or flags.good_roommate or flags.friendly or LifeStageSystem.hasActualFriends(state)
end

return LifeStageSystem
