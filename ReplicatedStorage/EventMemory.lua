-- EventMemory.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- COMPREHENSIVE EVENT MEMORY & VALIDATION SYSTEM
-- BitLife AAA-Quality Backend - Tracks EVERYTHING the player does
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- This system ensures:
-- 1. Events ONLY fire based on player's ACTUAL history
-- 2. NPCs and relationships are remembered correctly
-- 3. Past choices affect future opportunities
-- 4. No "phantom" events (like tax returns without work history)
-- 5. Proper consequence chains from player decisions
--
-- ═══════════════════════════════════════════════════════════════════════════════

local EventMemory = {}

----------------------------------------------------------------------
-- MEMORY CATEGORIES - What we track about the player
----------------------------------------------------------------------

EventMemory.Categories = {
	-- Work/Career History
	WORK = {
		ever_worked = false,           -- Has EVER had any job
		first_job_age = nil,           -- Age when first job started
		total_jobs_held = 0,           -- Number of different jobs
		years_employed = 0,            -- Total years with employment
		current_job = nil,             -- Current job details
		job_history = {},              -- List of all jobs held
		fired_count = 0,               -- Times fired
		quit_count = 0,                -- Times quit voluntarily
		promotions_received = 0,       -- Total promotions
		best_salary = 0,               -- Highest salary ever earned
		is_entrepreneur = false,       -- Started own business
		is_freelancer = false,         -- Works freelance
		career_path = nil,             -- Main career path chosen
		internships_completed = 0,     -- Number of internships
		part_time_experience = false,  -- Worked part-time
	},
	
	-- Education History
	EDUCATION = {
		highest_level = "none",        -- none/elementary/middle/high_school/some_college/associate/bachelor/master/doctorate
		dropped_out = false,           -- Ever dropped out
		dropout_level = nil,           -- What level dropped out from
		ged_earned = false,            -- Got GED after dropping out
		grades = "average",            -- poor/average/good/excellent
		honor_roll = false,            -- Ever on honor roll
		valedictorian = false,         -- Was valedictorian
		scholarships = 0,              -- Number of scholarships
		expelled = false,              -- Ever expelled
		schools_attended = {},         -- List of schools
		major = nil,                   -- College major if applicable
		gpa = nil,                     -- GPA if tracked
		academic_awards = {},          -- Academic achievements
		study_abroad = false,          -- Studied abroad
		clubs = {},                    -- School clubs joined
		sports = {},                   -- School sports played
	},
	
	-- Relationship History
	RELATIONSHIPS = {
		ever_dated = false,            -- Has ever dated
		first_date_age = nil,          -- Age of first date
		total_relationships = 0,       -- Total romantic relationships
		current_partner = nil,         -- Current partner details
		times_married = 0,             -- Marriage count
		times_divorced = 0,            -- Divorce count
		children_count = 0,            -- Number of children
		children = {},                 -- List of children
		cheated = false,               -- Has cheated
		been_cheated_on = false,       -- Been cheated on
		engagements = 0,               -- Times engaged
		breakups = 0,                  -- Breakup count
		widowed = false,               -- Is widowed
		friends_made = 0,              -- Lifetime friends made
		current_friends = {},          -- Current active friendships
		best_friend = nil,             -- Best friend if any
		enemies = {},                  -- People who dislike player
		family_relationships = {},     -- Family member status
		social_events_attended = 0,    -- Parties, gatherings, etc.
	},
	
	-- Criminal History
	CRIMINAL = {
		ever_committed_crime = false,  -- Any criminal activity
		crimes_committed = {},         -- List of crimes
		times_arrested = 0,            -- Arrest count
		times_convicted = 0,           -- Conviction count
		prison_sentences = {},         -- Prison terms served
		total_prison_years = 0,        -- Years in prison
		current_status = "clean",      -- clean/wanted/imprisoned/parole
		parole = false,                -- Currently on parole
		probation = false,             -- Currently on probation
		gang_member = false,           -- In a gang
		gang_rank = nil,               -- Gang position
		informant = false,             -- Snitched to police
		notorious = false,             -- Famous criminal
		reformed = false,              -- Went straight after crime
		community_service_hours = 0,   -- Court-ordered service
	},
	
	-- Financial History  
	FINANCIAL = {
		ever_had_money = false,        -- Has had significant money
		highest_net_worth = 0,         -- Peak wealth
		bankruptcies = 0,              -- Times bankrupt
		ever_homeless = false,         -- Been homeless
		current_debt = 0,              -- Current debt amount
		loans_taken = 0,               -- Loans borrowed
		loans_paid_off = 0,            -- Loans fully repaid
		investments = {},              -- Investment history
		properties_owned = {},         -- Real estate
		inheritance_received = 0,      -- Money inherited
		lottery_wins = 0,              -- Lottery winnings
		gambling_losses = 0,           -- Total lost gambling
		charity_donated = 0,           -- Total donated
		taxes_paid = 0,                -- Lifetime taxes
		filed_taxes = false,           -- Has filed taxes
	},
	
	-- Health History
	HEALTH = {
		conditions = {},               -- Current/past health conditions
		surgeries = {},                -- Surgeries undergone
		hospitalizations = 0,          -- Hospital stays
		addictions = {},               -- Current/past addictions
		in_recovery = false,           -- Addiction recovery
		therapy_sessions = 0,          -- Therapy attended
		medications = {},              -- Current medications
		disabilities = {},             -- Any disabilities
		near_death_experiences = 0,    -- Close calls
		fitness_level = "average",     -- sedentary/average/fit/athletic
		diet_type = "regular",         -- regular/healthy/poor/vegan/etc
		mental_health_issues = {},     -- Mental health history
	},
	
	-- Skills & Hobbies
	SKILLS = {
		learned_skills = {},           -- Skills acquired
		hobbies = {},                  -- Active hobbies
		languages = {"English"},       -- Languages known
		certifications = {},           -- Professional certs
		licenses = {},                 -- Licenses held (driving, etc)
		talents = {},                  -- Natural talents
		awards = {},                   -- Non-academic awards
		competitions_won = {},         -- Competition victories
	},
	
	-- Life Events & Milestones
	MILESTONES = {
		first_kiss_age = nil,
		first_car_age = nil,
		first_home_age = nil,
		graduation_ages = {},          -- When graduated each level
		marriage_ages = {},            -- When got married
		children_birth_ages = {},      -- When had kids
		retirement_age = nil,          -- When retired
		major_achievements = {},       -- Big life moments
		traumas = {},                  -- Traumatic experiences
		lucky_events = {},             -- Fortunate happenings
	},
}

----------------------------------------------------------------------
-- CORE MEMORY FUNCTIONS
----------------------------------------------------------------------

-- Initialize fresh memory for a new player
function EventMemory.create()
	local memory = {
		work = {},
		education = {},
		relationships = {},
		criminal = {},
		financial = {},
		health = {},
		skills = {},
		milestones = {},
		timeline = {},    -- Chronological event log
		flags = {},       -- Quick lookup flags
		reputation = {},  -- How NPCs view player
	}
	
	-- Deep copy defaults
	for category, defaults in pairs(EventMemory.Categories) do
		local catKey = string.lower(category)
		memory[catKey] = {}
		for key, value in pairs(defaults) do
			if type(value) == "table" then
				memory[catKey][key] = {}
			else
				memory[catKey][key] = value
			end
		end
	end
	
	return memory
end

-- Record an event to memory
function EventMemory.recordEvent(memory, eventType, data, age)
	if not memory then return end
	
	-- Add to timeline
	table.insert(memory.timeline, {
		type = eventType,
		data = data,
		age = age,
		timestamp = os.time(),
	})
	
	-- Process by event type
	EventMemory.processEventType(memory, eventType, data, age)
end

-- Process specific event types and update relevant memory categories
function EventMemory.processEventType(memory, eventType, data, age)
	local handlers = {
		-- Work events
		job_started = function()
			memory.work.ever_worked = true
			memory.work.total_jobs_held = (memory.work.total_jobs_held or 0) + 1
			if not memory.work.first_job_age then
				memory.work.first_job_age = age
			end
			memory.work.current_job = data
			table.insert(memory.work.job_history, {
				job = data,
				start_age = age,
				end_age = nil,
			})
			memory.flags.employed = true
			memory.flags.has_job = true
			memory.flags.ever_worked = true
		end,
		
		job_ended = function()
			memory.work.current_job = nil
			if memory.work.job_history and #memory.work.job_history > 0 then
				memory.work.job_history[#memory.work.job_history].end_age = age
			end
			memory.flags.employed = false
			memory.flags.has_job = false
		end,
		
		job_fired = function()
			memory.work.fired_count = (memory.work.fired_count or 0) + 1
			memory.flags.fired = true
		end,
		
		job_quit = function()
			memory.work.quit_count = (memory.work.quit_count or 0) + 1
		end,
		
		job_promoted = function()
			memory.work.promotions_received = (memory.work.promotions_received or 0) + 1
			memory.flags.promoted = true
		end,
		
		internship_completed = function()
			memory.work.internships_completed = (memory.work.internships_completed or 0) + 1
			memory.flags.internship_completed = true
			memory.flags.intern_experience = true
		end,
		
		-- Education events
		school_started = function()
			table.insert(memory.education.schools_attended, {
				type = data.type,
				name = data.name,
				start_age = age,
			})
			memory.flags.in_school = true
		end,
		
		school_graduated = function()
			memory.education.highest_level = data.level
			memory.education.graduation_ages = memory.education.graduation_ages or {}
			table.insert(memory.education.graduation_ages, age)
			memory.flags["graduated_" .. data.level] = true
			
			if data.level == "high_school" then
				memory.flags.high_school_graduate = true
			elseif data.level == "college" or data.level == "bachelor" then
				memory.flags.college_graduate = true
				memory.flags.bachelors_degree = true
			end
		end,
		
		school_dropped_out = function()
			memory.education.dropped_out = true
			memory.education.dropout_level = data.level
			memory.flags.dropped_out = true
			memory.flags["dropped_out_" .. data.level] = true
			memory.flags.in_school = false
		end,
		
		got_ged = function()
			memory.education.ged_earned = true
			memory.flags.ged_graduate = true
		end,
		
		honor_roll = function()
			memory.education.honor_roll = true
			memory.flags.honor_roll = true
			memory.flags.honors_student = true
		end,
		
		-- Relationship events
		started_dating = function()
			memory.relationships.ever_dated = true
			memory.relationships.total_relationships = (memory.relationships.total_relationships or 0) + 1
			if not memory.relationships.first_date_age then
				memory.relationships.first_date_age = age
			end
			memory.relationships.current_partner = data.partner
			memory.flags.dating = true
			memory.flags.in_relationship = true
		end,
		
		broke_up = function()
			memory.relationships.breakups = (memory.relationships.breakups or 0) + 1
			memory.relationships.current_partner = nil
			memory.flags.dating = false
			memory.flags.in_relationship = false
		end,
		
		got_married = function()
			memory.relationships.times_married = (memory.relationships.times_married or 0) + 1
			table.insert(memory.milestones.marriage_ages or {}, age)
			memory.flags.married = true
			memory.flags.in_relationship = true
		end,
		
		got_divorced = function()
			memory.relationships.times_divorced = (memory.relationships.times_divorced or 0) + 1
			memory.flags.married = false
			memory.flags.divorced = true
		end,
		
		had_child = function()
			memory.relationships.children_count = (memory.relationships.children_count or 0) + 1
			table.insert(memory.relationships.children, {
				name = data.name,
				gender = data.gender,
				birth_age = age,
			})
			table.insert(memory.milestones.children_birth_ages or {}, age)
			memory.flags.parent = true
			memory.flags.has_children = true
		end,
		
		made_friend = function()
			memory.relationships.friends_made = (memory.relationships.friends_made or 0) + 1
			table.insert(memory.relationships.current_friends, {
				name = data.name,
				met_age = age,
				relationship = data.relationship or 50,
			})
			memory.flags.has_friend = true
			memory.flags.ever_had_friend = true
		end,
		
		-- Criminal events
		committed_crime = function()
			memory.criminal.ever_committed_crime = true
			table.insert(memory.criminal.crimes_committed, {
				type = data.type,
				age = age,
				caught = data.caught or false,
			})
			memory.flags.criminal = true
			memory.flags.committed_crime = true
		end,
		
		arrested = function()
			memory.criminal.times_arrested = (memory.criminal.times_arrested or 0) + 1
			memory.flags.arrested = true
			memory.flags.criminal_record = true
		end,
		
		went_to_prison = function()
			table.insert(memory.criminal.prison_sentences, {
				start_age = age,
				duration = data.years,
				crime = data.crime,
			})
			memory.criminal.current_status = "imprisoned"
			memory.flags.in_prison = true
		end,
		
		released_from_prison = function()
			memory.criminal.current_status = "released"
			memory.flags.in_prison = false
			memory.flags.ex_convict = true
			memory.flags.just_released = true
		end,
		
		-- Financial events
		paid_taxes = function()
			memory.financial.filed_taxes = true
			memory.financial.taxes_paid = (memory.financial.taxes_paid or 0) + (data.amount or 0)
			memory.flags.taxpayer = true
		end,
		
		went_bankrupt = function()
			memory.financial.bankruptcies = (memory.financial.bankruptcies or 0) + 1
			memory.flags.bankrupt = true
		end,
		
		became_homeless = function()
			memory.financial.ever_homeless = true
			memory.flags.homeless = true
		end,
		
		bought_property = function()
			table.insert(memory.financial.properties_owned, {
				type = data.type,
				value = data.value,
				age = age,
			})
			memory.flags.property_owner = true
			memory.flags.homeowner = true
		end,
		
		received_inheritance = function()
			memory.financial.inheritance_received = (memory.financial.inheritance_received or 0) + (data.amount or 0)
			memory.flags.inherited = true
		end,
		
		-- Health events
		diagnosed = function()
			table.insert(memory.health.conditions, {
				condition = data.condition,
				diagnosed_age = age,
				severity = data.severity,
			})
			memory.flags["has_" .. string.gsub(string.lower(data.condition), " ", "_")] = true
		end,
		
		addiction_started = function()
			table.insert(memory.health.addictions, {
				type = data.type,
				started_age = age,
				active = true,
			})
			memory.flags.addict = true
			memory.flags[data.type .. "_addiction"] = true
		end,
		
		addiction_recovery = function()
			memory.health.in_recovery = true
			memory.flags.in_recovery = true
			-- Mark addiction as inactive
			for _, addiction in ipairs(memory.health.addictions) do
				if addiction.type == data.type then
					addiction.active = false
				end
			end
		end,
		
		-- Skill events
		learned_skill = function()
			table.insert(memory.skills.learned_skills, {
				skill = data.skill,
				level = data.level or 1,
				learned_age = age,
			})
			memory.flags["knows_" .. string.gsub(string.lower(data.skill), " ", "_")] = true
		end,
		
		got_license = function()
			table.insert(memory.skills.licenses, {
				type = data.type,
				age = age,
			})
			memory.flags["has_" .. data.type .. "_license"] = true
			if data.type == "drivers" or data.type == "driving" then
				memory.flags.has_license = true
				memory.flags.can_drive = true
			end
		end,
	}
	
	local handler = handlers[eventType]
	if handler then
		handler()
	end
end

----------------------------------------------------------------------
-- VALIDATION FUNCTIONS - Check if events can fire
----------------------------------------------------------------------

-- Check if player has EVER worked
function EventMemory.hasEverWorked(memory)
	if not memory then return false end
	return memory.work and memory.work.ever_worked == true
end

-- Check if player is CURRENTLY employed
function EventMemory.isCurrentlyEmployed(memory)
	if not memory then return false end
	return memory.work and memory.work.current_job ~= nil
end

-- Check if player has specific education level
function EventMemory.hasEducation(memory, level)
	if not memory or not memory.education then return false end
	
	local levels = {
		none = 0,
		elementary = 1,
		middle = 2,
		high_school = 3,
		some_college = 4,
		associate = 5,
		bachelor = 6,
		master = 7,
		doctorate = 8,
	}
	
	local playerLevel = levels[memory.education.highest_level or "none"] or 0
	local requiredLevel = levels[level] or 0
	
	return playerLevel >= requiredLevel
end

-- Check if player dropped out
function EventMemory.hasDroppedOut(memory)
	if not memory or not memory.education then return false end
	return memory.education.dropped_out == true
end

-- Check if player has filed taxes (requires work history)
function EventMemory.canFileTaxes(memory)
	if not memory then return false end
	return memory.financial and memory.financial.filed_taxes == true or
		(memory.work and memory.work.ever_worked == true)
end

-- Check if player has any friends
function EventMemory.hasFriends(memory)
	if not memory or not memory.relationships then return false end
	return memory.relationships.current_friends and #memory.relationships.current_friends > 0
end

-- Get a friend's name (returns nil if no friends)
function EventMemory.getFriendName(memory)
	if not EventMemory.hasFriends(memory) then return nil end
	local friends = memory.relationships.current_friends
	local friend = friends[math.random(#friends)]
	return friend.name
end

-- Check if player has romantic partner
function EventMemory.hasPartner(memory)
	if not memory or not memory.relationships then return false end
	return memory.relationships.current_partner ~= nil
end

-- Check if player has criminal record
function EventMemory.hasCriminalRecord(memory)
	if not memory or not memory.criminal then return false end
	return memory.criminal.ever_committed_crime == true
end

-- Check if player is in prison
function EventMemory.isInPrison(memory)
	if not memory or not memory.criminal then return false end
	return memory.criminal.current_status == "imprisoned"
end

-- Check if player has specific skill
function EventMemory.hasSkill(memory, skillName)
	if not memory or not memory.skills then return false end
	for _, skill in ipairs(memory.skills.learned_skills or {}) do
		if string.lower(skill.skill) == string.lower(skillName) then
			return true
		end
	end
	return false
end

-- Check if player has specific license
function EventMemory.hasLicense(memory, licenseType)
	if not memory or not memory.skills then return false end
	for _, license in ipairs(memory.skills.licenses or {}) do
		if string.lower(license.type) == string.lower(licenseType) then
			return true
		end
	end
	return false
end

-- Check if player can afford something
function EventMemory.canAfford(memory, amount, currentMoney)
	return (currentMoney or 0) >= amount
end

-- Check if player has health condition
function EventMemory.hasCondition(memory, condition)
	if not memory or not memory.health then return false end
	for _, cond in ipairs(memory.health.conditions or {}) do
		if string.lower(cond.condition) == string.lower(condition) then
			return true
		end
	end
	return false
end

----------------------------------------------------------------------
-- FLAG SYNCHRONIZATION - Sync memory with state flags
----------------------------------------------------------------------

-- Get all flags that should be set based on memory
function EventMemory.getMemoryFlags(memory)
	if not memory then return {} end
	
	local flags = {}
	
	-- Work flags
	if memory.work then
		if memory.work.ever_worked then
			flags.ever_worked = true
			flags.has_work_history = true
		end
		if memory.work.current_job then
			flags.employed = true
			flags.has_job = true
		end
		if memory.work.promotions_received and memory.work.promotions_received > 0 then
			flags.promoted = true
		end
		if memory.work.is_entrepreneur then
			flags.entrepreneur = true
		end
		if memory.work.internships_completed and memory.work.internships_completed > 0 then
			flags.internship_completed = true
			flags.intern_experience = true
		end
	end
	
	-- Education flags
	if memory.education then
		if memory.education.highest_level == "high_school" then
			flags.high_school_graduate = true
		elseif memory.education.highest_level == "bachelor" or memory.education.highest_level == "college" then
			flags.college_graduate = true
			flags.bachelors_degree = true
			flags.high_school_graduate = true
		elseif memory.education.highest_level == "master" then
			flags.masters_degree = true
			flags.college_graduate = true
			flags.high_school_graduate = true
		elseif memory.education.highest_level == "doctorate" then
			flags.doctorate = true
			flags.phd = true
			flags.masters_degree = true
			flags.college_graduate = true
			flags.high_school_graduate = true
		end
		
		if memory.education.dropped_out then
			flags.dropped_out = true
			if memory.education.dropout_level == "high_school" then
				flags.high_school_dropout = true
			end
		end
		
		if memory.education.ged_earned then
			flags.ged_graduate = true
		end
		
		if memory.education.honor_roll then
			flags.honor_roll = true
			flags.honors_student = true
		end
	end
	
	-- Relationship flags
	if memory.relationships then
		if memory.relationships.current_partner then
			flags.in_relationship = true
			flags.dating = true
		end
		if memory.relationships.times_married and memory.relationships.times_married > 0 then
			if memory.relationships.times_divorced < memory.relationships.times_married then
				flags.married = true
			end
		end
		if memory.relationships.children_count and memory.relationships.children_count > 0 then
			flags.parent = true
			flags.has_children = true
		end
		if memory.relationships.current_friends and #memory.relationships.current_friends > 0 then
			flags.has_friend = true
		end
		if memory.relationships.friends_made and memory.relationships.friends_made > 0 then
			flags.ever_had_friend = true
		end
	end
	
	-- Criminal flags
	if memory.criminal then
		if memory.criminal.ever_committed_crime then
			flags.criminal = true
		end
		if memory.criminal.current_status == "imprisoned" then
			flags.in_prison = true
		end
		if memory.criminal.times_arrested and memory.criminal.times_arrested > 0 then
			flags.criminal_record = true
		end
		if memory.criminal.reformed then
			flags.going_straight = true
		end
	end
	
	-- Financial flags
	if memory.financial then
		if memory.financial.filed_taxes then
			flags.taxpayer = true
		end
		if memory.financial.properties_owned and #memory.financial.properties_owned > 0 then
			flags.property_owner = true
			flags.homeowner = true
		end
		if memory.financial.ever_homeless then
			flags.experienced_homelessness = true
		end
	end
	
	return flags
end

-- Sync memory state with LifeState flags
function EventMemory.syncToState(memory, state)
	if not memory or not state then return end
	
	local memoryFlags = EventMemory.getMemoryFlags(memory)
	state.Flags = state.Flags or {}
	
	for flag, value in pairs(memoryFlags) do
		state.Flags[flag] = value
	end
end

----------------------------------------------------------------------
-- COMPREHENSIVE EVENT VALIDATION
----------------------------------------------------------------------

-- Master validation function - checks if an event can fire
function EventMemory.validateEvent(eventDef, state, memory)
	local result = { valid = true, reasons = {} }
	
	-- If no memory, fall back to basic flag checking
	if not memory then
		return result
	end
	
	-- Check work-related requirements
	if eventDef.requiresWorkHistory then
		if not EventMemory.hasEverWorked(memory) then
			result.valid = false
			table.insert(result.reasons, "Requires work history")
		end
	end
	
	if eventDef.requiresCurrentJob then
		if not EventMemory.isCurrentlyEmployed(memory) then
			result.valid = false
			table.insert(result.reasons, "Requires current employment")
		end
	end
	
	-- Check education requirements
	if eventDef.requiresEducation then
		if not EventMemory.hasEducation(memory, eventDef.requiresEducation) then
			result.valid = false
			table.insert(result.reasons, "Requires " .. eventDef.requiresEducation .. " education")
		end
	end
	
	-- Check if requires NOT being a dropout
	if eventDef.blocksDropout then
		if EventMemory.hasDroppedOut(memory) then
			result.valid = false
			table.insert(result.reasons, "Blocked for dropouts")
		end
	end
	
	-- Check tax-related requirements
	if eventDef.requiresTaxHistory then
		if not EventMemory.canFileTaxes(memory) then
			result.valid = false
			table.insert(result.reasons, "Requires tax/work history")
		end
	end
	
	-- Check friendship requirements
	if eventDef.requiresFriends then
		if not EventMemory.hasFriends(memory) then
			result.valid = false
			table.insert(result.reasons, "Requires friends")
		end
	end
	
	-- Check relationship requirements
	if eventDef.requiresPartner then
		if not EventMemory.hasPartner(memory) then
			result.valid = false
			table.insert(result.reasons, "Requires romantic partner")
		end
	end
	
	-- Check criminal history
	if eventDef.requiresCriminalHistory then
		if not EventMemory.hasCriminalRecord(memory) then
			result.valid = false
			table.insert(result.reasons, "Requires criminal history")
		end
	end
	
	if eventDef.blocksIfCriminal then
		if EventMemory.hasCriminalRecord(memory) then
			result.valid = false
			table.insert(result.reasons, "Blocked by criminal record")
		end
	end
	
	-- Check skill requirements
	if eventDef.requiresSkill then
		if not EventMemory.hasSkill(memory, eventDef.requiresSkill) then
			result.valid = false
			table.insert(result.reasons, "Requires skill: " .. eventDef.requiresSkill)
		end
	end
	
	-- Check license requirements
	if eventDef.requiresLicense then
		if not EventMemory.hasLicense(memory, eventDef.requiresLicense) then
			result.valid = false
			table.insert(result.reasons, "Requires license: " .. eventDef.requiresLicense)
		end
	end
	
	return result
end

----------------------------------------------------------------------
-- UTILITY FUNCTIONS
----------------------------------------------------------------------

-- Get a summary of player's life history
function EventMemory.getLifeSummary(memory)
	if not memory then return {} end
	
	return {
		hasWorked = EventMemory.hasEverWorked(memory),
		isEmployed = EventMemory.isCurrentlyEmployed(memory),
		jobCount = memory.work and memory.work.total_jobs_held or 0,
		education = memory.education and memory.education.highest_level or "none",
		isDropout = EventMemory.hasDroppedOut(memory),
		hasFriends = EventMemory.hasFriends(memory),
		friendCount = memory.relationships and #(memory.relationships.current_friends or {}) or 0,
		hasPartner = EventMemory.hasPartner(memory),
		isMarried = memory.relationships and memory.relationships.times_married and memory.relationships.times_married > 0 and 
			(memory.relationships.times_divorced or 0) < memory.relationships.times_married,
		childCount = memory.relationships and memory.relationships.children_count or 0,
		hasCriminalRecord = EventMemory.hasCriminalRecord(memory),
		isInPrison = EventMemory.isInPrison(memory),
		everBankrupt = memory.financial and (memory.financial.bankruptcies or 0) > 0,
		everHomeless = memory.financial and memory.financial.ever_homeless or false,
	}
end

-- Serialize memory for saving
function EventMemory.serialize(memory)
	-- Deep copy to avoid references
	local function deepCopy(orig)
		local copy
		if type(orig) == 'table' then
			copy = {}
			for k, v in pairs(orig) do
				copy[k] = deepCopy(v)
			end
		else
			copy = orig
		end
		return copy
	end
	return deepCopy(memory)
end

-- Deserialize saved memory
function EventMemory.deserialize(data)
	if not data then return EventMemory.create() end
	return data
end

return EventMemory
