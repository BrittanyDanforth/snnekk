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

local EventEngine = {}

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

-- Main eligibility check
function EventEngine.isEligible(event, state)
	local age = state.Age or 0
	local flags = state.Flags or {}
	local stats = state.Stats or {}
	local conditions = event.conditions or {}
	
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
	
	-- Custom condition
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
