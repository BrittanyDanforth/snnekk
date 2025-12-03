-- LifeEvents/init.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- GODLY LIFE EVENTS SYSTEM - Central Hub
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- This is the main entry point for the event system. It:
-- - Loads all event modules
-- - Provides access to CareerSystem and EventEngine
-- - Normalizes legacy events to the new schema
-- - Exposes helper functions for common operations
--
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = {}

-- ═══════════════════════════════════════════════════════════════
-- SAFE MODULE LOADING
-- ═══════════════════════════════════════════════════════════════

local function safeRequire(moduleName)
	-- script.Parent is the LifeEvents folder - siblings of init, not children
	local container = script.Parent
	local module = container:FindFirstChild(moduleName)
	
	if not module then
		warn("[LifeEvents] Module not found:", moduleName, "in", container:GetFullName())
		return nil
	end

	local success, result = pcall(function()
		return require(module)
	end)

	if success then
		print("[LifeEvents] ✅ Loaded:", moduleName)
		return result
	else
		warn("[LifeEvents] ❌ Failed to load", moduleName, ":", result)
		return nil
	end
end

-- Load core systems
local CareerLibrary = safeRequire("CareerLibrary") or { getAllCareers = function() return {} end, getCareer = function() return nil end }
local CareerSystem = safeRequire("CareerSystem") or {}
local EventEngine = safeRequire("EventEngine") or {}

-- Export systems
LifeEvents.CareerLibrary = CareerLibrary
LifeEvents.CareerSystem = CareerSystem
LifeEvents.EventEngine = EventEngine

-- ═══════════════════════════════════════════════════════════════
-- MASTER EVENT REGISTRY
-- ═══════════════════════════════════════════════════════════════

LifeEvents.AllEvents = {}
LifeEvents.EventsById = {}

-- ═══════════════════════════════════════════════════════════════
-- LEGACY EVENT NORMALIZATION
-- ═══════════════════════════════════════════════════════════════

-- Convert old-style events to new unified schema
local function normalizeEvent(event)
	-- If already has conditions table, minimal normalization
	if event.conditions then
		-- Ensure id exists
		if not event.id then
			event.id = event.title and string.gsub(string.lower(event.title), " ", "_") or ("event_" .. math.random(10000, 99999))
		end
		return event
	end
	
	-- Build conditions from legacy fields
	local conditions = {
		minAge = event.minAge,
		maxAge = event.maxAge,
		requiredAllFlags = nil,
		requiredAnyFlags = event.requiresAnyFlag,
		blockedFlags = nil,
		requiredCareerId = event.requiredCareerId,
		requiredCareerMinTier = event.requiredCareerMinTier,
		requiredEducation = event.requiresEducation,
		minMoney = event.minMoney,  -- Money requirements
		minStats = event.minStats,   -- Stat requirements
		custom = event.requires,     -- Legacy custom function
	}
	
	-- Handle single flags (convert to arrays)
	if event.requiresFlag then
		conditions.requiredAllFlags = conditions.requiredAllFlags or {}
		table.insert(conditions.requiredAllFlags, event.requiresFlag)
	end
	if event.requiresFlag2 then
		conditions.requiredAllFlags = conditions.requiredAllFlags or {}
		table.insert(conditions.requiredAllFlags, event.requiresFlag2)
	end
	if event.blockIfFlag then
		conditions.blockedFlags = conditions.blockedFlags or {}
		table.insert(conditions.blockedFlags, event.blockIfFlag)
	end
	
	-- Build normalized event
	local normalized = {
		id = event.id or (event.title and string.gsub(string.lower(event.title), " ", "_")) or ("event_" .. math.random(10000, 99999)),
		emoji = event.emoji,
		title = event.title or "Life Event",
		category = event.category or "life",
		tags = event.tags,
		
		weight = event.weight,
		cooldownYears = event.cooldown,
		cooldown = event.cooldown, -- Keep legacy field for LifeStageSystem
		oneTime = event.oneTime,
		milestone = event.milestone,
		
		chainId = event.chainId,
		chainStep = event.chainStep,
		
		-- Keep these at top level for LifeStageSystem compatibility
		requires = event.requires,
		minMoney = event.minMoney,
		minStats = event.minStats,
		requiresFlag = event.requiresFlag,
		requiresFlag2 = event.requiresFlag2,
		requiresAnyFlag = event.requiresAnyFlag,
		blockIfFlag = event.blockIfFlag,
		blockIfFlag2 = event.blockIfFlag2,
		
		conditions = conditions,
		
		getDynamicData = event.getDynamicData,
		getDynamicEmoji = event.getDynamicEmoji,
		text = event.text or "",
		
		choices = event.choices or {},
	}
	
	-- Normalize choices (convert legacy setFlag/effects to new format)
	for i, choice in ipairs(normalized.choices) do
		if not choice.flags then
			choice.flags = {set = {}, clear = {}}
			
			if choice.setFlag then
				table.insert(choice.flags.set, choice.setFlag)
			end
			if choice.setFlags then
				for _, flag in ipairs(choice.setFlags) do
					table.insert(choice.flags.set, flag)
				end
			end
			if choice.clearFlag then
				table.insert(choice.flags.clear, choice.clearFlag)
			end
		end
	end
	
	return normalized
end

-- ═══════════════════════════════════════════════════════════════
-- EVENT LOADING
-- ═══════════════════════════════════════════════════════════════

-- List of event modules to load
local EVENT_MODULES = {
	-- Phase 1 rebuild: focus on a single AAA career rail.
	"career_motorsport",
}

-- Load all event modules
local function loadEventModules()
	local loaded = 0
	local failed = 0
	local container = script.Parent -- LifeEvents folder, NOT script itself

	for _, moduleName in ipairs(EVENT_MODULES) do
		local success, result = pcall(function()
			local moduleScript = container:FindFirstChild(moduleName)
			if moduleScript and moduleScript:IsA("ModuleScript") then
				local events = require(moduleScript)

				-- Handle different return formats
				local eventList = events
				if type(events) == "table" then
					if events.events then
						eventList = events.events
					elseif events.Events then
						eventList = events.Events
					end
				end

				if type(eventList) == "table" then
					local moduleEventCount = 0
					for _, event in ipairs(eventList) do
						local normalized = normalizeEvent(event)

						-- Validate event has required fields
						if normalized.id and normalized.text and normalized.choices then
							table.insert(LifeEvents.AllEvents, normalized)
							LifeEvents.EventsById[normalized.id] = normalized
							loaded = loaded + 1
							moduleEventCount = moduleEventCount + 1
						else
							warn("[LifeEvents] Invalid event in " .. moduleName .. ":", normalized.id or "no id")
						end
					end
					print("[LifeEvents] 📦", moduleName, "→", moduleEventCount, "events")
				else
					warn("[LifeEvents] Module", moduleName, "did not return a table")
				end
			else
				warn("[LifeEvents] Module not found:", moduleName)
			end
		end)

		if not success then
			warn("[LifeEvents] ❌ Failed to load module:", moduleName, result)
			failed = failed + 1
		end
	end

	print("[LifeEvents] ═══════════════════════════════════════")
	print("[LifeEvents] ✅ Loaded", loaded, "events from", #EVENT_MODULES - failed, "modules")
	print("[LifeEvents] ═══════════════════════════════════════")
	return loaded
end

-- ═══════════════════════════════════════════════════════════════
-- PUBLIC API
-- ═══════════════════════════════════════════════════════════════

-- Initialize the event system
function LifeEvents.initialize()
	LifeEvents.AllEvents = {}
	LifeEvents.EventsById = {}
	return loadEventModules()
end

-- Get all loaded events
function LifeEvents.getAllEvents()
	return LifeEvents.AllEvents
end

-- Get event by ID
function LifeEvents.getEvent(eventId)
	return LifeEvents.EventsById[eventId]
end

-- Get events for a specific age range
function LifeEvents.getEventsForAge(age)
	local events = {}
	for _, event in ipairs(LifeEvents.AllEvents) do
		local minAge = event.conditions and event.conditions.minAge or 0
		local maxAge = event.conditions and event.conditions.maxAge or 999
		if age >= minAge and age <= maxAge then
			table.insert(events, event)
		end
	end
	return events
end

-- Get events by category
function LifeEvents.getEventsByCategory(category)
	local events = {}
	for _, event in ipairs(LifeEvents.AllEvents) do
		if event.category == category then
			table.insert(events, event)
		end
	end
	return events
end

-- Get events by tag
function LifeEvents.getEventsByTag(tag)
	local events = {}
	for _, event in ipairs(LifeEvents.AllEvents) do
		if event.tags then
			for _, eventTag in ipairs(event.tags) do
				if eventTag == tag then
					table.insert(events, event)
					break
				end
			end
		end
	end
	return events
end

-- ═══════════════════════════════════════════════════════════════
-- EVENT SELECTION (Delegates to EventEngine)
-- ═══════════════════════════════════════════════════════════════

-- Check if an event is eligible for a player
function LifeEvents.checkConditions(event, state)
	return EventEngine.isEligible(event, state)
end

-- Select events for a year
function LifeEvents.selectEventsForYear(state, config)
	return EventEngine.selectYearEvents(LifeEvents.AllEvents, state, config)
end

-- Select a single random event
function LifeEvents.selectRandomEvent(state)
	local eligible = {}
	for _, event in ipairs(LifeEvents.AllEvents) do
		if EventEngine.isEligible(event, state) then
			table.insert(eligible, event)
		end
	end
	
	if #eligible == 0 then return nil end
	
	return EventEngine.weightedSelect(eligible, state)
end

-- ═══════════════════════════════════════════════════════════════
-- EVENT PROCESSING (Delegates to EventEngine)
-- ═══════════════════════════════════════════════════════════════

-- Process a choice and apply effects
function LifeEvents.processChoice(event, choiceIndex, state)
	return EventEngine.completeEvent(event, choiceIndex, state)
end

-- Get processed event text with placeholders filled
function LifeEvents.getEventText(event, state)
	return EventEngine.processEventText(event, state)
end

-- ═══════════════════════════════════════════════════════════════
-- CAREER FUNCTIONS (Delegates to CareerSystem)
-- ═══════════════════════════════════════════════════════════════

function LifeEvents.startCareer(state, careerId)
	return CareerSystem.startCareer(state, careerId)
end

function LifeEvents.getCareerInfo(state)
	return CareerSystem.getDisplayInfo(state)
end

function LifeEvents.getAvailableCareers(state)
	return CareerSystem.getAvailableCareers(state)
end

function LifeEvents.calculateCareerIncome(state)
	return CareerSystem.calculateIncome(state)
end

-- ═══════════════════════════════════════════════════════════════
-- HELPER FUNCTIONS FOR EVENTS
-- ═══════════════════════════════════════════════════════════════

-- Random amount generator
function LifeEvents.randomAmount(min, max)
	return math.random(min, max)
end

-- Random percent (0.0 to 1.0)
function LifeEvents.randomPercent()
	return math.random() 
end

-- Check if player has a friend
function LifeEvents.hasFriend(state)
	local relationships = state.Relationships or {}
	for _, rel in ipairs(relationships) do
		if rel.type == "friend" then return true end
	end
	return false
end

-- Check if player has a partner
function LifeEvents.hasPartner(state)
	local relationships = state.Relationships or {}
	for _, rel in ipairs(relationships) do
		if rel.type == "partner" or rel.type == "spouse" then return true end
	end
	return false
end

-- Check if player is married
function LifeEvents.isMarried(state)
	local relationships = state.Relationships or {}
	for _, rel in ipairs(relationships) do
		if rel.type == "spouse" then return true end
	end
	return false
end

-- Check if player has children
function LifeEvents.hasChildren(state)
	local relationships = state.Relationships or {}
	for _, rel in ipairs(relationships) do
		if rel.type == "child" then return true end
	end
	return false
end

-- Check if player has a job
function LifeEvents.hasJob(state)
	return CareerSystem.getPrimaryCareer(state) ~= nil
end

-- Check if player is in jail
function LifeEvents.isInJail(state)
	local flags = state.Flags or {}
	return flags.in_prison == true or flags.in_jail == true
end

-- Check if player is enrolled in education
function LifeEvents.isEnrolled(state)
	local edu = state.Education or "none"
	return edu ~= "none" and edu ~= "high_school"
end

-- Get a random friend name
function LifeEvents.getFriendName(state)
	local relationships = state.Relationships or {}
	local friends = {}
	for _, rel in ipairs(relationships) do
		if rel.type == "friend" and rel.name then
			table.insert(friends, rel.name)
		end
	end
	if #friends > 0 then
		return friends[math.random(#friends)]
	end
	-- Fallback names
	local fallbacks = {"Alex", "Jordan", "Taylor", "Casey", "Morgan", "Riley", "Sam", "Jamie"}
	return fallbacks[math.random(#fallbacks)]
end

-- Get partner name
function LifeEvents.getPartnerName(state)
	local relationships = state.Relationships or {}
	for _, rel in ipairs(relationships) do
		if rel.type == "partner" or rel.type == "spouse" then
			return rel.name
		end
	end
	return "your partner"
end

-- ═══════════════════════════════════════════════════════════════
-- EDUCATION HELPERS
-- ═══════════════════════════════════════════════════════════════

LifeEvents.EducationRanks = {
	none = 0,
	high_school = 1,
	community = 2,
	bachelor = 3,
	master = 4,
	law = 5,
	medical = 5,
	phd = 6,
}

function LifeEvents.hasEducation(state, required)
	local playerEdu = state.Education or "none"
	local reqRank = LifeEvents.EducationRanks[required] or 0
	local playerRank = LifeEvents.EducationRanks[playerEdu] or 0
	return playerRank >= reqRank
end

function LifeEvents.getEducationLevel(state)
	return state.Education or "none"
end

-- ═══════════════════════════════════════════════════════════════
-- STAT HELPERS
-- ═══════════════════════════════════════════════════════════════

function LifeEvents.getStat(state, statName)
	local stats = state.Stats or {}
	return stats[statName] or 0
end

function LifeEvents.modifyStat(state, statName, amount)
	local stats = state.Stats or {}
	local current = stats[statName] or 0
	local newVal = current + amount
	
	-- Clamp non-money stats
	if statName ~= "Money" and statName ~= "Karma" then
		newVal = math.clamp(newVal, 0, 100)
	end
	
	stats[statName] = newVal
	state.Stats = stats
	return newVal
end

-- ═══════════════════════════════════════════════════════════════
-- FLAG HELPERS
-- ═══════════════════════════════════════════════════════════════

function LifeEvents.hasFlag(state, flag)
	local flags = state.Flags or {}
	return flags[flag] == true
end

function LifeEvents.setFlag(state, flag)
	local flags = state.Flags or {}
	flags[flag] = true
	state.Flags = flags
end

function LifeEvents.clearFlag(state, flag)
	local flags = state.Flags or {}
	flags[flag] = nil
	state.Flags = flags
end

-- ═══════════════════════════════════════════════════════════════
-- DEBUG / STATS
-- ═══════════════════════════════════════════════════════════════

function LifeEvents.getStats()
	local stats = {
		totalEvents = #LifeEvents.AllEvents,
		byCategory = {},
		byAgeRange = {
			child = 0,
			teen = 0,
			young_adult = 0,
			middle_aged = 0,
			senior = 0,
		},
		milestones = 0,
		chainEvents = 0,
	}
	
	for _, event in ipairs(LifeEvents.AllEvents) do
		local cat = event.category or "unknown"
		stats.byCategory[cat] = (stats.byCategory[cat] or 0) + 1
		
		if event.milestone then
			stats.milestones = stats.milestones + 1
		end
		
		if event.chainId then
			stats.chainEvents = stats.chainEvents + 1
		end
		
		-- Count by age range
		local minAge = event.conditions and event.conditions.minAge or 0
		if minAge < 13 then
			stats.byAgeRange.child = stats.byAgeRange.child + 1
		elseif minAge < 18 then
			stats.byAgeRange.teen = stats.byAgeRange.teen + 1
		elseif minAge < 36 then
			stats.byAgeRange.young_adult = stats.byAgeRange.young_adult + 1
		elseif minAge < 56 then
			stats.byAgeRange.middle_aged = stats.byAgeRange.middle_aged + 1
		else
			stats.byAgeRange.senior = stats.byAgeRange.senior + 1
		end
	end
	
	return stats
end

-- Print detailed stats
function LifeEvents.printStats()
	local stats = LifeEvents.getStats()
	print("═══════════════════════════════════════")
	print("LIFE EVENTS SYSTEM STATS")
	print("═══════════════════════════════════════")
	print("Total Events:", stats.totalEvents)
	print("Milestones:", stats.milestones)
	print("Chain Events:", stats.chainEvents)
	print("")
	print("By Category:")
	for cat, count in pairs(stats.byCategory) do
		print("  " .. cat .. ":", count)
	end
	print("")
	print("By Age Range:")
	print("  Child (0-12):", stats.byAgeRange.child)
	print("  Teen (13-17):", stats.byAgeRange.teen)
	print("  Young Adult (18-35):", stats.byAgeRange.young_adult)
	print("  Middle Aged (36-55):", stats.byAgeRange.middle_aged)
	print("  Senior (55+):", stats.byAgeRange.senior)
	print("═══════════════════════════════════════")
end

-- ═══════════════════════════════════════════════════════════════
-- AUTO-INITIALIZE
-- ═══════════════════════════════════════════════════════════════

-- Load events on require
LifeEvents.initialize()

return LifeEvents
