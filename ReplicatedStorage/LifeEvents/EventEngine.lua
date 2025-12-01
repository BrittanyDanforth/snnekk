-- EventEngine.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- GODLY EVENT ENGINE - Central Event Selection & Processing
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- The brain of the event system. Handles:
-- - Event eligibility checking with unified conditions
-- - Weighted random selection with stat/career boosting
-- - Event buckets (career, relationships, health, random)
-- - Chain/story arc tracking
-- - Choice effect application
-- - Cooldown and one-time event management
--
-- ═══════════════════════════════════════════════════════════════════════════════

-- Safe require CareerSystem
local CareerSystem = nil
local csSuccess, csResult = pcall(function()
	return require(script.Parent.CareerSystem)
end)
if csSuccess then
	CareerSystem = csResult
else
	warn("[EventEngine] ⚠️ CareerSystem not loaded:", csResult)
	-- Provide minimal fallback
	CareerSystem = {
		getPrimaryCareer = function() return nil end,
		getCurrentTier = function() return nil end,
		meetsCareerRequirements = function() return true end,
		getCareerEventBoost = function() return 0 end,
		getDisplayInfo = function() return { hasCareer = false, title = "Unemployed" } end,
	}
end

-- Safe require EventMemory
local EventMemory = nil
local emSuccess, emResult = pcall(function()
	return require(script.Parent.Parent.EventMemory)
end)
if emSuccess then
	EventMemory = emResult
else
	warn("[EventEngine] ⚠️ EventMemory not loaded:", emResult)
	-- Provide minimal fallback
	EventMemory = {
		validateEvent = function() return { valid = true, reasons = {} } end,
		hasEverWorked = function() return false end,
		isCurrentlyEmployed = function() return false end,
		hasFriends = function() return false end,
		hasPartner = function() return false end,
		hasCriminalRecord = function() return false end,
		isInPrison = function() return false end,
		hasLicense = function() return false end,
		hasSkill = function() return false end,
		hasCondition = function() return false end,
		hasEducation = function() return false end,
	}
end

local EventEngine = {}

-- ═══════════════════════════════════════════════════════════════
-- HELPER FUNCTIONS FOR DEEP VALIDATION
-- ═══════════════════════════════════════════════════════════════

-- Check if player owns an asset of a specific type
local function ownsAsset(state, assetType)
	if not state then return false end
	
	local assets = state.Assets or {}
	
	if assetType == "car" or assetType == "vehicle" then
		return assets.Vehicles and #assets.Vehicles > 0
	elseif assetType == "house" or assetType == "property" or assetType == "home" then
		return assets.Properties and #assets.Properties > 0
	elseif assetType == "pet" then
		return state.Pets and #state.Pets > 0
	elseif assetType == "crypto" then
		return assets.Crypto and #assets.Crypto > 0
	end
	
	-- Check flags as fallback
	local flags = state.Flags or {}
	if assetType == "car" or assetType == "vehicle" then
		return flags.owns_car or flags.has_vehicle or flags.car_owner
	elseif assetType == "house" or assetType == "property" or assetType == "home" then
		return flags.owns_house or flags.homeowner or flags.property_owner
	end
	
	return false
end

-- Check if player has a specific relationship type
local function hasRelationshipType(state, relType)
	if not state then return false end
	
	local relationships = state.Relationships or {}
	
	for _, rel in ipairs(relationships) do
		if rel.type == relType then
			return true
		end
		-- Handle aliases
		if relType == "partner" and (rel.type == "spouse" or rel.type == "boyfriend" or rel.type == "girlfriend") then
			return true
		end
		if relType == "spouse" and rel.type == "partner" and (state.Flags or {}).married then
			return true
		end
	end
	
	-- Check flags as fallback
	local flags = state.Flags or {}
	if relType == "partner" then
		return flags.in_relationship or flags.dating or flags.married
	elseif relType == "spouse" then
		return flags.married
	elseif relType == "friend" then
		return flags.has_friend or flags.ever_had_friend
	elseif relType == "child" then
		return flags.has_children or flags.parent
	end
	
	return false
end

-- Check if player has specific health condition
local function hasHealthCondition(state, condition)
	if not state then return false end
	
	local flags = state.Flags or {}
	local conditionFlag = "has_" .. string.gsub(string.lower(condition), " ", "_")
	
	if flags[conditionFlag] then return true end
	
	-- Check common aliases
	local aliases = {
		pregnant = {"pregnant", "expecting", "with_child"},
		depression = {"depressed", "has_depression", "depression"},
		anxiety = {"anxious", "has_anxiety", "anxiety"},
		addiction = {"addict", "addicted", "has_addiction"},
	}
	
	if aliases[string.lower(condition)] then
		for _, alias in ipairs(aliases[string.lower(condition)]) do
			if flags[alias] then return true end
		end
	end
	
	return false
end

-- Get count of children
local function getChildCount(state)
	if not state then return 0 end
	
	local count = 0
	local relationships = state.Relationships or {}
	
	for _, rel in ipairs(relationships) do
		if rel.type == "child" or rel.type == "son" or rel.type == "daughter" then
			count = count + 1
		end
	end
	
	return count
end

-- Check if player has driver's license
local function hasDriversLicense(state)
	if not state then return false end
	
	local flags = state.Flags or {}
	return flags.has_license or flags.drivers_license or flags.can_drive
end

-- Check work status
local function isEmployed(state)
	if not state then return false end
	
	local flags = state.Flags or {}
	if flags.employed or flags.has_job then return true end
	
	-- Check for current job from extended state
	if state.CurrentJob then return true end
	
	return false
end

-- Check money requirements
local function meetsMoney(state, minMoney, maxMoney)
	local money = state.Money or 0
	
	if minMoney and money < minMoney then return false end
	if maxMoney and money > maxMoney then return false end
	
	return true
end

-- ═══════════════════════════════════════════════════════════════
-- UNIFIED EVENT SCHEMA
-- ═══════════════════════════════════════════════════════════════
--[[
EventDef = {
	-- Identity
	id: string,                    -- Unique event ID
	emoji: string?,                -- Display emoji
	title: string,                 -- Event title
	category: string,              -- "career", "health", "social", "crime", "school", "life", etc.
	tags: {string}?,               -- For filtering: {"career", "hacker", "whitehat"}
	
	-- Weight & Occurrence
	weight: number?,               -- Base weight (default 10)
	cooldownYears: number?,        -- Can't fire again for N years
	oneTime: boolean?,             -- Can only happen once ever
	milestone: boolean?,           -- Important life event (higher visibility)
	
	-- Story Chains
	chainId: string?,              -- Story chain this belongs to
	chainStep: number?,            -- Step in the chain (1, 2, 3...)
	
	-- Conditions
	conditions: {
		minAge: number?,
		maxAge: number?,
		
		-- Flag requirements
		requiredAllFlags: {string}?,    -- Must have ALL of these
		requiredAnyFlags: {string}?,    -- Must have AT LEAST ONE
		blockedFlags: {string}?,        -- NONE of these can be present
		
		-- Career requirements
		requiredCareerId: string?,
		requiredCareerMinTier: number?,
		requiredCareerBranch: string?,
		
		-- Education requirements
		requiredEducation: string?,     -- "high_school", "bachelor", etc.
		
		-- Stat requirements
		minStats: {[string]: number}?,  -- {Smarts = 50, Health = 30}
		maxStats: {[string]: number}?,  -- {Happiness = 30} (for sad events)
		
		-- Custom function
		custom: ((state) -> boolean)?,
	}?,
	
	-- Content
	getDynamicData: ((state) -> {[string]: any})?,
	getDynamicEmoji: ((data) -> string)?,
	text: string,                  -- Event text with %placeholders%
	
	-- Choices
	choices: {
		{
			id: string?,
			text: string,
			resultText: string?,
			
			-- Effects
			effects: {[string]: number}?,  -- {Money = 1000, Happiness = 5}
			
			-- Flag changes
			flags: {
				set: {string}?,
				clear: {string}?,
			}?,
			
			-- Special effects
			minigame: string?,
			addRelationship: {}?,
			startCareer: string?,
			careerBranch: string?,
			careerXP: number?,
			careerReputation: number?,
			promoteCareer: boolean?,
			quitCareer: boolean?,
		}
	},
}
]]

-- ═══════════════════════════════════════════════════════════════
-- ELIGIBILITY CHECKING
-- ═══════════════════════════════════════════════════════════════

local function hasFlag(flags, flag)
	return flags and flags[flag] == true
end

local function hasAllFlags(flags, required)
	if not required or #required == 0 then return true end
	for _, flag in ipairs(required) do
		if not hasFlag(flags, flag) then return false end
	end
	return true
end

local function hasAnyFlag(flags, required)
	if not required or #required == 0 then return true end
	for _, flag in ipairs(required) do
		if hasFlag(flags, flag) then return true end
	end
	return false
end

local function hasNoFlags(flags, blocked)
	if not blocked or #blocked == 0 then return true end
	for _, flag in ipairs(blocked) do
		if hasFlag(flags, flag) then return false end
	end
	return true
end

local function meetsStatRequirements(stats, minStats, maxStats)
	if minStats then
		for stat, minVal in pairs(minStats) do
			local current = stats[stat] or 0
			if current < minVal then return false end
		end
	end
	if maxStats then
		for stat, maxVal in pairs(maxStats) do
			local current = stats[stat] or 100
			if current > maxVal then return false end
		end
	end
	return true
end

local EducationRanks = {
	none = 0,
	high_school = 1,
	community = 2,
	bachelor = 3,
	master = 4,
	law = 5,
	medical = 5,
	phd = 6,
}

local function hasEducation(state, required)
	if not required then return true end
	local playerEdu = state.Education or "none"
	local reqRank = EducationRanks[required] or 0
	local playerRank = EducationRanks[playerEdu] or 0
	return playerRank >= reqRank
end

-- ═══════════════════════════════════════════════════════════════
-- AUTO-INFERENCE: Detect requirements from event tags/id/category
-- This catches events where the author forgot to add explicit conditions
-- ═══════════════════════════════════════════════════════════════
local function inferRequirementsFromEvent(event, state)
	local tags = event.tags or {}
	local id = event.id or ""
	local category = event.category or ""
	local title = event.title or ""
	local text = event.text or ""
	local lowerId = string.lower(id)
	local lowerTitle = string.lower(title)
	local lowerText = string.lower(text)
	
	-- CAR/VEHICLE EVENT DETECTION
	local carPatterns = {"car_", "driving_", "vehicle_", "speeding_", "traffic_", "road_trip", "commute", "parking_"}
	for _, pattern in ipairs(carPatterns) do
		if string.find(lowerId, pattern) or string.find(lowerTitle, pattern) then
			-- Event involves driving - check for vehicle or license
			if not ownsAsset(state, "car") and not hasDriversLicense(state) then
				return false, "auto_infer: car event but no vehicle/license"
			end
		end
	end
	
	-- Car crash/accident specific (these need a car!)
	local crashPatterns = {"car_accident", "car_crash", "fender_bender", "wreck", "collision"}
	for _, pattern in ipairs(crashPatterns) do
		if string.find(lowerId, pattern) or string.find(lowerText, pattern) then
			if not ownsAsset(state, "car") then
				return false, "auto_infer: car accident but no car"
			end
		end
	end
	
	-- PET EVENT DETECTION
	local petPatterns = {"pet_", "dog_", "cat_", "_pet", "_dog", "_cat", "puppy", "kitten", "veterinar"}
	for _, pattern in ipairs(petPatterns) do
		if string.find(lowerId, pattern) then
			if not ownsAsset(state, "pet") and not string.find(lowerId, "adopt") and not string.find(lowerId, "get_") then
				return false, "auto_infer: pet event but no pet"
			end
		end
	end
	
	-- PARTNER/SPOUSE EVENT DETECTION
	local partnerPatterns = {"spouse_", "partner_", "marriage_", "wedding_", "anniversary", "husband_", "wife_", "_spouse", "_partner"}
	for _, pattern in ipairs(partnerPatterns) do
		if string.find(lowerId, pattern) then
			if not hasRelationshipType(state, "partner") then
				return false, "auto_infer: partner event but no partner"
			end
		end
	end
	
	-- CHILD EVENT DETECTION
	local childPatterns = {"child_", "parenting_", "son_", "daughter_", "baby_", "kids_", "children_", "_child", "pregnant"}
	for _, pattern in ipairs(childPatterns) do
		if string.find(lowerId, pattern) then
			-- Skip "pregnancy" events - those don't require existing children
			if not string.find(lowerId, "pregnan") and not string.find(lowerId, "trying_for") then
				local hasChildren = hasRelationshipType(state, "child") or (state.Flags or {}).has_children
				if not hasChildren then
					return false, "auto_infer: child event but no children"
				end
			end
		end
	end
	
	-- WORK/JOB EVENT DETECTION
	local workPatterns = {"coworker_", "boss_", "workplace_", "office_", "promotion_", "fired_", "layoff", "work_conflict", "salary_", "raise_"}
	for _, pattern in ipairs(workPatterns) do
		if string.find(lowerId, pattern) then
			if not isEmployed(state) then
				return false, "auto_infer: work event but not employed"
			end
		end
	end
	
	-- STUDENT EVENT DETECTION
	local studentPatterns = {"exam_", "test_", "homework_", "professor_", "classmate_", "lecture_", "finals_", "midterm_", "study_group", "dorm_"}
	for _, pattern in ipairs(studentPatterns) do
		if string.find(lowerId, pattern) then
			local isStudent = (state.Flags or {}).in_school or (state.Flags or {}).enrolled or (state.Flags or {}).college_student
			if not isStudent then
				return false, "auto_infer: student event but not in school"
			end
		end
	end
	
	-- GRADUATE/ADVANCED DEGREE EVENT DETECTION
	local gradSchoolPatterns = {"phd_", "masters_", "doctorate_", "thesis_", "dissertation_", "postdoc_", "grad_school"}
	for _, pattern in ipairs(gradSchoolPatterns) do
		if string.find(lowerId, pattern) then
			-- Graduate school events require at least bachelor's degree
			local education = state.Education or {}
			local eduLevel = education.level or state.EducationLevel or "none"
			local hasUndergrad = (eduLevel == "bachelor" or eduLevel == "bachelors" or eduLevel == "associate" 
				or eduLevel == "master" or eduLevel == "masters" or eduLevel == "doctorate" or eduLevel == "phd")
			local flags = state.Flags or {}
			local hasUnderGradFlag = flags.college_graduate or flags.bachelor or flags.advanced_degree
			
			if not hasUndergrad and not hasUnderGradFlag then
				return false, "auto_infer: grad school event but no undergraduate degree"
			end
		end
	end
	
	-- PROFESSIONAL CREDENTIAL DETECTION
	-- Some careers require specific degrees
	local professionalPatterns = {
		{pattern = "medical_school", requires = "bachelor"},
		{pattern = "law_school", requires = "bachelor"},
		{pattern = "dental_school", requires = "bachelor"},
		{pattern = "residency_", requires = "medical_degree"},
		{pattern = "bar_exam", requires = "law_degree"},
	}
	for _, rule in ipairs(professionalPatterns) do
		if string.find(lowerId, rule.pattern) then
			local flags = state.Flags or {}
			local education = state.Education or {}
			local eduLevel = education.level or state.EducationLevel or "none"
			
			if rule.requires == "bachelor" then
				local hasBachelor = (eduLevel == "bachelor" or eduLevel == "bachelors" 
					or eduLevel == "master" or eduLevel == "doctorate")
				if not hasBachelor and not flags.college_graduate then
					return false, "auto_infer: " .. rule.pattern .. " requires bachelor's degree"
				end
			elseif rule.requires == "medical_degree" then
				if not flags.medical_degree and not flags.md_graduate then
					return false, "auto_infer: " .. rule.pattern .. " requires medical degree"
				end
			elseif rule.requires == "law_degree" then
				if not flags.law_degree and not flags.jd_graduate then
					return false, "auto_infer: " .. rule.pattern .. " requires law degree"
				end
			end
		end
	end
	
	-- PRISON EVENT DETECTION
	local prisonPatterns = {"prison_", "inmate_", "cell_", "warden_", "parole_", "solitary_", "yard_", "conjugal_"}
	for _, pattern in ipairs(prisonPatterns) do
		if string.find(lowerId, pattern) then
			if not (state.Flags or {}).in_prison then
				return false, "auto_infer: prison event but not in prison"
			end
		end
	end
	
	-- HOME OWNERSHIP EVENT DETECTION
	-- Note: Some events need OWNED property specifically (mortgage, property_tax)
	-- Others can happen to renters too (house_fire, home_invasion)
	local ownedPropertyPatterns = {"mortgage_", "property_tax", "home_equity", "sell_house", "home_renovation"}
	for _, pattern in ipairs(ownedPropertyPatterns) do
		if string.find(lowerId, pattern) then
			if not ownsAsset(state, "house") then
				return false, "auto_infer: property owner event but no owned property"
			end
		end
	end
	
	-- These events require any housing (owned, rented, or living with family)
	-- Assume everyone has some form of housing (minors live with parents)
	-- Only block if explicitly homeless flag
	local homelessBlocking = {"home_repair", "house_fire", "home_invasion", "basement_", "attic_", "backyard_", "garage_"}
	local flags = state.Flags or {}
	if flags.homeless then
		for _, pattern in ipairs(homelessBlocking) do
			if string.find(lowerId, pattern) then
				return false, "auto_infer: home event but homeless"
			end
		end
	end
	
	-- FAME/CELEBRITY EVENT DETECTION
	local famePatterns = {"paparazzi", "tabloid", "fans_", "autograph", "red_carpet", "award_show"}
	for _, pattern in ipairs(famePatterns) do
		if string.find(lowerId, pattern) then
			local isFamous = (state.Flags or {}).famous or (state.Flags or {}).celebrity or (state.Stats or {}).Fame and (state.Stats or {}).Fame > 50
			if not isFamous then
				return false, "auto_infer: fame event but not famous"
			end
		end
	end
	
	-- ═══════════════════════════════════════════════════════════════
	-- CRIMINAL RECORD IMPACT DETECTION
	-- Certain prestigious opportunities should be blocked by criminal records
	-- ═══════════════════════════════════════════════════════════════
	local flags = state.Flags or {}
	local hasCriminalRecord = flags.criminal_record or flags.ex_convict or flags.convicted or flags.felon
	
	if hasCriminalRecord then
		-- Government/security clearance jobs blocked
		local securityClearancePatterns = {"security_clearance", "government_job", "fbi_", "cia_", "classified", "top_secret", "military_officer", "federal_"}
		for _, pattern in ipairs(securityClearancePatterns) do
			if string.find(lowerId, pattern) then
				return false, "auto_infer: security clearance event blocked by criminal record"
			end
		end
		
		-- Law enforcement blocked
		local lawEnforcementPatterns = {"police_officer", "cop_", "sheriff_", "detective_", "law_enforcement"}
		for _, pattern in ipairs(lawEnforcementPatterns) do
			if string.find(lowerId, pattern) then
				return false, "auto_infer: law enforcement blocked by criminal record"
			end
		end
		
		-- Legal profession requires bar admission (felons often blocked)
		local legalPatterns = {"bar_exam", "become_lawyer", "law_license", "attorney_", "pass_the_bar"}
		for _, pattern in ipairs(legalPatterns) do
			if string.find(lowerId, pattern) then
				-- Not all states block, but it's realistic to make it harder
				return false, "auto_infer: bar admission blocked by criminal record"
			end
		end
		
		-- Medical licensing also affected
		local medicalPatterns = {"medical_license", "become_doctor", "nursing_license"}
		for _, pattern in ipairs(medicalPatterns) do
			if string.find(lowerId, pattern) then
				-- Can still happen but less likely
				local roll = math.random()
				if roll < 0.5 then
					return false, "auto_infer: medical license application affected by criminal record"
				end
			end
		end
	end
	
	-- PRISON FLAG BLOCKS MOST NORMAL EVENTS
	if flags.in_prison then
		-- Most normal life events should NOT happen while in prison
		-- Only prison-specific events allowed
		if category ~= "prison" and category ~= "health" and category ~= "family" and category ~= "milestone" then
			-- Allow events that explicitly work in prison
			if not string.find(lowerId, "prison_") and not string.find(lowerId, "inmate_") then
				return false, "auto_infer: non-prison event blocked while incarcerated"
			end
		end
	end
	
	return true, "passed_auto_inference"
end

-- Main eligibility check (ENHANCED with deep validation)
function EventEngine.isEligible(event, state)
	local age = state.Age or 0
	local flags = state.Flags or {}
	local stats = state.Stats or {}
	local conditions = event.conditions or {}
	local memory = state.EventMemory -- EventMemory instance if available
	
	-- ═══════════════════════════════════════════════════════════════
	-- AUTO-INFERENCE CHECK (catches forgotten conditions)
	-- ═══════════════════════════════════════════════════════════════
	local inferValid, inferReason = inferRequirementsFromEvent(event, state)
	if not inferValid then
		return false, inferReason
	end
	
	-- ═══════════════════════════════════════════════════════════════
	-- BASIC AGE & FLAG CHECKS
	-- ═══════════════════════════════════════════════════════════════
	
	-- Age check
	if conditions.minAge and age < conditions.minAge then
		return false, "too_young"
	end
	if conditions.maxAge and age > conditions.maxAge then
		return false, "too_old"
	end
	
	-- Flag checks
	if not hasAllFlags(flags, conditions.requiredAllFlags) then
		return false, "missing_required_flags"
	end
	if not hasAnyFlag(flags, conditions.requiredAnyFlags) then
		return false, "missing_any_flags"
	end
	if not hasNoFlags(flags, conditions.blockedFlags) then
		return false, "has_blocked_flag"
	end
	
	-- One-time check
	if event.oneTime then
		local seenEvents = state.SeenEvents or {}
		if seenEvents[event.id] then
			return false, "already_seen"
		end
	end
	
	-- Cooldown check
	if event.cooldownYears then
		local cooldowns = state.EventCooldowns or {}
		local lastFired = cooldowns[event.id]
		if lastFired and (age - lastFired) < event.cooldownYears then
			return false, "on_cooldown"
		end
	end
	
	-- Chain check
	if event.chainId and event.chainStep then
		local chains = state.Chains or {}
		local currentStep = chains[event.chainId] or 0
		-- Can only see this event if it's the next step
		if event.chainStep ~= currentStep + 1 then
			return false, "wrong_chain_step"
		end
	end
	
	-- Education check
	if conditions.requiredEducation then
		if not hasEducation(state, conditions.requiredEducation) then
			return false, "insufficient_education"
		end
	end
	
	-- Stat checks
	if not meetsStatRequirements(stats, conditions.minStats, conditions.maxStats) then
		return false, "stat_requirements_not_met"
	end
	
	-- Career check
	if conditions.requiredCareerId then
		if not CareerSystem.meetsCareerRequirements(
			state,
			conditions.requiredCareerId,
			conditions.requiredCareerMinTier,
			conditions.requiredCareerBranch
		) then
			return false, "career_requirements_not_met"
		end
	end
	
	-- ═══════════════════════════════════════════════════════════════
	-- DEEP VALIDATION - "SMART RANDOM" CHECKS
	-- These prevent illogical events from firing
	-- ═══════════════════════════════════════════════════════════════
	
	-- ASSET OWNERSHIP CHECKS
	-- Car-related events require owning a car
	if conditions.requiresVehicle or conditions.requiresCar then
		if not ownsAsset(state, "car") and not hasDriversLicense(state) then
			return false, "no_vehicle"
		end
	end
	
	-- Driving events require driver's license
	if conditions.requiresLicense then
		if not hasDriversLicense(state) then
			return false, "no_drivers_license"
		end
	end
	
	-- Home-related events require owning property
	if conditions.requiresHome or conditions.requiresProperty then
		if not ownsAsset(state, "house") then
			return false, "no_property"
		end
	end
	
	-- Pet-related events require having a pet
	if conditions.requiresPet then
		if not ownsAsset(state, "pet") then
			return false, "no_pet"
		end
	end
	
	-- MONEY CHECKS
	if conditions.minMoney and (state.Money or 0) < conditions.minMoney then
		return false, "insufficient_money"
	end
	if conditions.maxMoney and (state.Money or 0) > conditions.maxMoney then
		return false, "too_much_money"
	end
	
	-- RELATIONSHIP CHECKS
	-- Partner-related events require having a partner
	if conditions.requiresPartner then
		if not hasRelationshipType(state, "partner") then
			return false, "no_partner"
		end
	end
	
	-- Marriage events require being married
	if conditions.requiresMarried then
		if not flags.married then
			return false, "not_married"
		end
	end
	
	-- Friend events require having friends
	if conditions.requiresFriends or conditions.requiresFriend then
		if not hasRelationshipType(state, "friend") then
			return false, "no_friends"
		end
	end
	
	-- Child events require having children
	if conditions.requiresChildren then
		if not hasRelationshipType(state, "child") then
			return false, "no_children"
		end
	end
	
	-- Minimum children count
	if conditions.minChildren then
		if getChildCount(state) < conditions.minChildren then
			return false, "not_enough_children"
		end
	end
	
	-- EMPLOYMENT CHECKS
	if conditions.requiresEmployed or conditions.requiresJob then
		if not isEmployed(state) then
			return false, "not_employed"
		end
	end
	
	if conditions.requiresUnemployed then
		if isEmployed(state) then
			return false, "is_employed"
		end
	end
	
	-- WORK HISTORY CHECKS (uses EventMemory if available)
	if conditions.requiresWorkHistory then
		local hasWorked = flags.ever_worked or flags.has_work_history
		if memory and EventMemory.hasEverWorked then
			hasWorked = hasWorked or EventMemory.hasEverWorked(memory)
		end
		if not hasWorked then
			return false, "no_work_history"
		end
	end
	
	-- TAX EVENTS require work history
	if conditions.requiresTaxHistory then
		local canTax = flags.taxpayer or flags.ever_worked or flags.has_work_history
		if memory and EventMemory.canFileTaxes then
			canTax = canTax or EventMemory.canFileTaxes(memory)
		end
		if not canTax then
			return false, "no_tax_history"
		end
	end
	
	-- HEALTH CONDITION CHECKS
	if conditions.requiresCondition then
		if not hasHealthCondition(state, conditions.requiresCondition) then
			return false, "missing_condition"
		end
	end
	
	if conditions.blocksCondition then
		if hasHealthCondition(state, conditions.blocksCondition) then
			return false, "has_blocked_condition"
		end
	end
	
	-- CRIMINAL RECORD CHECKS
	if conditions.requiresCriminalRecord then
		local hasCriminal = flags.criminal or flags.criminal_record or flags.ex_convict
		if memory and EventMemory.hasCriminalRecord then
			hasCriminal = hasCriminal or EventMemory.hasCriminalRecord(memory)
		end
		if not hasCriminal then
			return false, "no_criminal_record"
		end
	end
	
	if conditions.blocksCriminalRecord then
		local hasCriminal = flags.criminal_record or flags.ex_convict or flags.convicted
		if memory and EventMemory.hasCriminalRecord then
			hasCriminal = hasCriminal or EventMemory.hasCriminalRecord(memory)
		end
		if hasCriminal then
			return false, "has_criminal_record"
		end
	end
	
	-- PRISON CHECK
	if conditions.requiresInPrison then
		if not flags.in_prison then
			return false, "not_in_prison"
		end
	end
	
	if conditions.blocksInPrison then
		if flags.in_prison then
			return false, "in_prison"
		end
	end
	
	-- SKILL CHECKS
	if conditions.requiresSkill then
		local hasSkillFlag = flags["knows_" .. string.gsub(string.lower(conditions.requiresSkill), " ", "_")]
		local memoryHasSkill = memory and EventMemory.hasSkill and EventMemory.hasSkill(memory, conditions.requiresSkill)
		if not hasSkillFlag and not memoryHasSkill then
			return false, "missing_skill"
		end
	end
	
	-- EDUCATION LEVEL CHECK (more granular)
	if conditions.minEducationLevel then
		local playerEdu = state.Education or "none"
		local reqRank = EducationRanks[conditions.minEducationLevel] or 0
		local playerRank = EducationRanks[playerEdu] or 0
		if playerRank < reqRank then
			return false, "education_too_low"
		end
	end
	
	-- STUDENT CHECK
	if conditions.requiresStudent then
		if not flags.in_school and not flags.enrolled and not flags.college_student then
			return false, "not_a_student"
		end
	end
	
	-- ═══════════════════════════════════════════════════════════════
	-- EVENTMEMORY DEEP VALIDATION (if available)
	-- ═══════════════════════════════════════════════════════════════
	
	if memory and EventMemory.validateEvent then
		local memValidation = EventMemory.validateEvent(event, state, memory)
		if not memValidation.valid then
			return false, "memory_validation_failed: " .. (memValidation.reasons[1] or "unknown")
		end
	end
	
	-- ═══════════════════════════════════════════════════════════════
	-- CUSTOM CONDITION (runs last)
	-- ═══════════════════════════════════════════════════════════════
	
	if conditions.custom and type(conditions.custom) == "function" then
		local ok, result = pcall(conditions.custom, state)
		if not ok or not result then
			return false, "custom_condition_failed"
		end
	end
	
	return true, "eligible"
end

-- ═══════════════════════════════════════════════════════════════
-- WEIGHT CALCULATION
-- ═══════════════════════════════════════════════════════════════

function EventEngine.calculateWeight(event, state)
	local baseWeight = event.weight or 10
	local totalWeight = baseWeight
	
	-- Career tag boost
	if event.tags then
		local careerBoost = CareerSystem.getCareerEventBoost(state, event.tags)
		totalWeight = totalWeight + careerBoost
	end
	
	-- Milestone events get a boost
	if event.milestone then
		totalWeight = totalWeight + 5
	end
	
	-- Chain events get a significant boost when they're next in sequence
	if event.chainId and event.chainStep then
		local chains = state.Chains or {}
		local currentStep = chains[event.chainId] or 0
		if event.chainStep == currentStep + 1 then
			totalWeight = totalWeight + 30
		end
	end
	
	-- Health-related events boost when health is low
	if event.category == "health" then
		local health = state.Stats and state.Stats.Health or 50
		if health < 30 then
			totalWeight = totalWeight + 20
		elseif health < 50 then
			totalWeight = totalWeight + 10
		end
	end
	
	-- Relationship events boost based on relationship count
	if event.category == "social" or event.category == "relationships" then
		local relationships = state.Relationships or {}
		if #relationships > 0 then
			totalWeight = totalWeight + math.min(#relationships * 2, 15)
		end
	end
	
	-- Criminal events are more likely if you already have criminal flags
	if event.category == "crime" or event.category == "criminal" then
		local flags = state.Flags or {}
		if flags.criminal_record or flags.in_prison or flags.gang_life then
			totalWeight = totalWeight + 15
		end
	end
	
	return math.max(totalWeight, 1)
end

-- ═══════════════════════════════════════════════════════════════
-- EVENT SELECTION
-- ═══════════════════════════════════════════════════════════════

-- Categorize events into buckets
function EventEngine.categorizeEvents(events, state)
	local buckets = {
		career = {},
		health = {},
		social = {},
		crime = {},
		school = {},
		life = {},
		milestone = {},
	}
	
	for _, event in ipairs(events) do
		local eligible, reason = EventEngine.isEligible(event, state)
		if eligible then
			local category = event.category or "life"
			
			-- Put milestones in their own bucket too
			if event.milestone then
				table.insert(buckets.milestone, event)
			end
			
			-- Main categorization
			if category == "career" or category == "work" or category == "tech" then
				table.insert(buckets.career, event)
			elseif category == "health" then
				table.insert(buckets.health, event)
			elseif category == "social" or category == "relationships" or category == "family" then
				table.insert(buckets.social, event)
			elseif category == "crime" or category == "criminal" then
				table.insert(buckets.crime, event)
			elseif category == "school" or category == "education" then
				table.insert(buckets.school, event)
			else
				table.insert(buckets.life, event)
			end
		end
	end
	
	return buckets
end

-- Weighted random selection from a list of events
function EventEngine.weightedSelect(events, state)
	if #events == 0 then return nil end
	
	local totalWeight = 0
	local weightedEvents = {}
	
	for _, event in ipairs(events) do
		local weight = EventEngine.calculateWeight(event, state)
		totalWeight = totalWeight + weight
		table.insert(weightedEvents, {event = event, weight = weight})
	end
	
	if totalWeight <= 0 then return events[1] end
	
	local roll = math.random() * totalWeight
	local cumulative = 0
	
	for _, entry in ipairs(weightedEvents) do
		cumulative = cumulative + entry.weight
		if roll <= cumulative then
			return entry.event
		end
	end
	
	return events[#events]
end

-- Select multiple events for a year
function EventEngine.selectYearEvents(allEvents, state, config)
	config = config or {}
	local maxEvents = config.maxEvents or 3
	local guaranteeCareer = config.guaranteeCareer ~= false
	local guaranteeMilestone = config.guaranteeMilestone ~= false
	
	local buckets = EventEngine.categorizeEvents(allEvents, state)
	local selected = {}
	local selectedIds = {}
	
	local function addEvent(event)
		if event and not selectedIds[event.id] then
			table.insert(selected, event)
			selectedIds[event.id] = true
			return true
		end
		return false
	end
	
	-- Priority 1: Milestone events (if any are available)
	if guaranteeMilestone and #buckets.milestone > 0 then
		local milestone = EventEngine.weightedSelect(buckets.milestone, state)
		addEvent(milestone)
	end
	
	-- Priority 2: Career event (if player has career)
	if guaranteeCareer and CareerSystem.getPrimaryCareer(state) and #buckets.career > 0 then
		if #selected < maxEvents then
			local careerEvent = EventEngine.weightedSelect(buckets.career, state)
			addEvent(careerEvent)
		end
	end
	
	-- Priority 3: Age-appropriate events
	local age = state.Age or 0
	
	-- School events for young ages
	if age < 22 and #buckets.school > 0 and #selected < maxEvents then
		local schoolEvent = EventEngine.weightedSelect(buckets.school, state)
		addEvent(schoolEvent)
	end
	
	-- Fill remaining slots with weighted random from all eligible
	local allEligible = {}
	for _, bucket in pairs(buckets) do
		for _, event in ipairs(bucket) do
			if not selectedIds[event.id] then
				table.insert(allEligible, event)
			end
		end
	end
	
	-- Remove duplicates
	local seen = {}
	local uniqueEligible = {}
	for _, event in ipairs(allEligible) do
		if not seen[event.id] then
			seen[event.id] = true
			table.insert(uniqueEligible, event)
		end
	end
	
	while #selected < maxEvents and #uniqueEligible > 0 do
		local event = EventEngine.weightedSelect(uniqueEligible, state)
		if event and addEvent(event) then
			-- Remove from pool
			for i, e in ipairs(uniqueEligible) do
				if e.id == event.id then
					table.remove(uniqueEligible, i)
					break
				end
			end
		else
			break
		end
	end
	
	return selected
end

-- ═══════════════════════════════════════════════════════════════
-- CHOICE EFFECT APPLICATION
-- ═══════════════════════════════════════════════════════════════

function EventEngine.applyChoiceEffects(choice, state)
	local results = {
		statChanges = {},
		flagsSet = {},
		flagsCleared = {},
		messages = {},
	}
	
	-- Apply stat effects
	if choice.effects then
		local stats = state.Stats or {}
		for stat, amount in pairs(choice.effects) do
			local oldVal = stats[stat] or 0
			local newVal = oldVal + amount
			
			-- Clamp stats (except Money which can be negative for debt)
			if stat ~= "Money" and stat ~= "Karma" then
				newVal = math.clamp(newVal, 0, 100)
			end
			
			stats[stat] = newVal
			results.statChanges[stat] = {old = oldVal, new = newVal, change = amount}
		end
		state.Stats = stats
	end
	
	-- Apply flag changes
	local flags = state.Flags or {}
	
	if choice.flags then
		if choice.flags.set then
			for _, flag in ipairs(choice.flags.set) do
				flags[flag] = true
				table.insert(results.flagsSet, flag)
			end
		end
		if choice.flags.clear then
			for _, flag in ipairs(choice.flags.clear) do
				flags[flag] = nil
				table.insert(results.flagsCleared, flag)
			end
		end
	end
	
	state.Flags = flags
	
	-- Career effects
	if choice.startCareer then
		local success, msg = CareerSystem.startCareer(state, choice.startCareer)
		if success then
			table.insert(results.messages, "Started career: " .. choice.startCareer)
		end
	end
	
	if choice.careerBranch then
		local success, msg = CareerSystem.setBranch(state, choice.careerBranch)
		if success then
			table.insert(results.messages, "Career branch set: " .. choice.careerBranch)
		end
	end
	
	if choice.careerXP then
		CareerSystem.addXP(state, choice.careerXP)
	end
	
	if choice.careerReputation then
		CareerSystem.addReputation(state, choice.careerReputation)
	end
	
	if choice.promoteCareer then
		local success, msg = CareerSystem.promote(state)
		if success then
			table.insert(results.messages, msg)
		end
	end
	
	if choice.quitCareer then
		local success, msg = CareerSystem.quitCareer(state)
		if success then
			table.insert(results.messages, msg)
		end
	end
	
	return results
end

-- ═══════════════════════════════════════════════════════════════
-- EVENT STATE MANAGEMENT
-- ═══════════════════════════════════════════════════════════════

-- Mark event as seen (for one-time events)
function EventEngine.markEventSeen(event, state)
	if not state.SeenEvents then
		state.SeenEvents = {}
	end
	state.SeenEvents[event.id] = true
end

-- Update cooldown
function EventEngine.updateCooldown(event, state)
	if event.cooldownYears then
		if not state.EventCooldowns then
			state.EventCooldowns = {}
		end
		state.EventCooldowns[event.id] = state.Age or 0
	end
end

-- Advance chain
function EventEngine.advanceChain(event, state)
	if event.chainId and event.chainStep then
		if not state.Chains then
			state.Chains = {}
		end
		state.Chains[event.chainId] = event.chainStep
	end
end

-- Process event completion
function EventEngine.completeEvent(event, choiceIndex, state)
	local choice = event.choices and event.choices[choiceIndex]
	if not choice then
		warn("[EventEngine] Invalid choice index:", choiceIndex)
		return nil
	end
	
	-- Apply effects
	local results = EventEngine.applyChoiceEffects(choice, state)
	
	-- Mark as seen if one-time
	if event.oneTime then
		EventEngine.markEventSeen(event, state)
	end
	
	-- Update cooldown
	EventEngine.updateCooldown(event, state)
	
	-- Advance chain
	EventEngine.advanceChain(event, state)
	
	return results
end

-- ═══════════════════════════════════════════════════════════════
-- DYNAMIC TEXT PROCESSING
-- ═══════════════════════════════════════════════════════════════

function EventEngine.processEventText(event, state)
	local text = event.text
	local dynamicData = {}
	
	-- Get dynamic data if function exists
	if event.getDynamicData then
		local ok, data = pcall(event.getDynamicData, state)
		if ok and data then
			dynamicData = data
		end
	end
	
	-- Add default dynamic data
	dynamicData.playerName = state.Name or "Player"
	dynamicData.age = tostring(state.Age or 18)
	
	-- Get career info if needed
	local careerInfo = CareerSystem.getDisplayInfo(state)
	dynamicData.jobTitle = careerInfo.title
	dynamicData.salary = tostring(careerInfo.salary)
	
	-- Get partner name if in relationship
	local relationships = state.Relationships or {}
	for _, rel in ipairs(relationships) do
		if rel.type == "partner" or rel.type == "spouse" then
			dynamicData.partnerName = rel.name
			break
		end
	end
	dynamicData.partnerName = dynamicData.partnerName or "your partner"
	
	-- Get a random friend name
	for _, rel in ipairs(relationships) do
		if rel.type == "friend" then
			dynamicData.friendName = rel.name
			break
		end
	end
	dynamicData.friendName = dynamicData.friendName or "a friend"
	
	-- Replace placeholders
	for key, value in pairs(dynamicData) do
		text = string.gsub(text, "%%" .. key .. "%%", tostring(value))
	end
	
	return text, dynamicData
end

-- Get dynamic emoji
function EventEngine.getEventEmoji(event, state)
	if event.getDynamicEmoji then
		local _, data = EventEngine.processEventText(event, state)
		local ok, emoji = pcall(event.getDynamicEmoji, data)
		if ok and emoji then
			return emoji
		end
	end
	return event.emoji or "📜"
end

-- ═══════════════════════════════════════════════════════════════
-- DEBUG / UTILITY
-- ═══════════════════════════════════════════════════════════════

function EventEngine.debugEvent(event, state)
	local eligible, reason = EventEngine.isEligible(event, state)
	local weight = EventEngine.calculateWeight(event, state)
	
	return {
		id = event.id,
		title = event.title,
		eligible = eligible,
		reason = reason,
		weight = weight,
		conditions = event.conditions,
	}
end

function EventEngine.getEventStats(allEvents, state)
	local stats = {
		total = #allEvents,
		eligible = 0,
		byCategory = {},
		byReason = {},
	}
	
	for _, event in ipairs(allEvents) do
		local eligible, reason = EventEngine.isEligible(event, state)
		
		if eligible then
			stats.eligible = stats.eligible + 1
		end
		
		local cat = event.category or "unknown"
		stats.byCategory[cat] = (stats.byCategory[cat] or 0) + 1
		
		if not eligible then
			stats.byReason[reason] = (stats.byReason[reason] or 0) + 1
		end
	end
	
	return stats
end

return EventEngine
