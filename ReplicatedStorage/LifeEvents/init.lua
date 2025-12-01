-- LifeEvents/init.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- GODLY EVENT SYSTEM - AAA BitLife-Style Event Engine
-- ═══════════════════════════════════════════════════════════════════════════════
-- 
-- ARCHITECTURE:
-- - Unified event schema with conditions, effects, and choices
-- - Career system integration with tiers and progression
-- - Event chains for story arcs
-- - Intelligent weighted event selection
-- - Cooldown and one-time event tracking
-- - Dynamic data generation
--
-- USAGE:
-- local LifeEvents = require(path.to.LifeEvents)
-- local candidates = LifeEvents.getEligibleEvents(playerState)
-- local event = LifeEvents.selectWeightedEvent(candidates, playerState)
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = {}

----------------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------------

local DEBUG_MODE = false -- Set to true for verbose loading logs
local VALIDATE_ON_LOAD = true -- Validate events when loading

----------------------------------------------------------------------
-- NAME & DATA GENERATORS (Shared across all event modules)
----------------------------------------------------------------------

local MaleNames = {
	"James","Michael","David","Chris","Daniel","Matt","Jake","Ryan","Tyler","Brandon",
	"Kevin","Justin","Josh","Nick","Alex","Brian","Eric","Andrew","Sean","Kyle",
	"Adam","Aaron","Ethan","Nathan","Zach","Dylan","Connor","Mason","Logan","Lucas",
	"Marcus","Darius","Jerome","DeShawn","Jamal","Carlos","Miguel","Antonio","Roberto",
	"Giovanni","Vladimir","Dmitri","Kenji","Hiroshi","Wei","Jin","Ahmed","Omar","Raj",
	"Vikram","Liam","Noah","Oliver","William","Henry","Sebastian","Jack","Aiden","Owen",
	"Samuel","Benjamin","Theodore","Leo","Finn","Caleb","Max","Jasper","Felix"
}

local FemaleNames = {
	"Emma","Sophia","Olivia","Ava","Isabella","Mia","Emily","Abigail","Madison",
	"Elizabeth","Ella","Avery","Chloe","Sofia","Grace","Lily","Hannah","Aria","Zoe",
	"Riley","Nora","Scarlett","Stella","Luna","Hazel","Jasmine","Aaliyah","Destiny",
	"Diamond","Keisha","Maria","Carmen","Rosa","Valentina","Yuki","Mei","Sakura",
	"Priya","Ananya","Fatima","Layla","Charlotte","Amelia","Harper","Evelyn","Penelope",
	"Camila","Eleanor","Violet"
}

local LastNames = {
	"Smith","Johnson","Williams","Brown","Jones","Garcia","Miller","Davis","Rodriguez",
	"Martinez","Anderson","Taylor","Thomas","Moore","Jackson","Martin","Lee","Thompson",
	"White","Harris","Clark","Lewis","Robinson","Walker","Young","King","Wright","Scott",
	"Green","Baker","Adams","Nelson","Hill","Mitchell","Roberts","Campbell","Phillips",
	"Evans","Turner","Torres","Parker","Collins","Edwards","Stewart","Morris","Murphy",
	"Rivera","Cook","Rogers","Morgan","Peterson","Cooper","Reed","Bailey","Bell","Gomez",
	"Kelly","Howard","Ward","Cox","Diaz","Richardson","Wood","Watson","Brooks","Bennett",
	"Gray","Sanders","Price","Hughes","Fitzgerald","O'Brien","McCarthy","Sullivan","Kim",
	"Park","Chen","Wang","Nakamura","Tanaka","Patel","Singh","Khan"
}

-- Data pools
local Schools = {"Lincoln High","Washington Academy","Jefferson High","Roosevelt Prep","Kennedy School","Franklin High","Madison Prep","Hamilton Academy"}
local Universities = {"Harvard","Yale","Stanford","MIT","Princeton","Columbia","State University","City College","Berkeley","UCLA","NYU","Duke","Northwestern"}
local Colleges = {"Community College","Technical Institute","State College","City Community College"}
local Companies = {"TechCorp","MegaCorp","GlobalTech","InnovateCo","FutureTech","DataSys","CyberDyn","NexGen","Quantum Industries","Stellar Corp"}
local Cities = {"New York","Los Angeles","Chicago","Houston","Phoenix","Philadelphia","San Antonio","San Diego","Dallas","Seattle","Boston","Miami","Denver","Atlanta"}
local Countries = {"France","Japan","Italy","Australia","Canada","UK","Germany","Spain","Brazil","Mexico","Thailand","Greece","Iceland","Norway"}
local RacingTeams = {"Red Bull Racing","Ferrari","Mercedes","McLaren","Alpine","Thunder Racing","Lightning Motorsport","Velocity Racing"}
local HackerGroups = {"Anonymous","LulzSec","Zero Day Collective","Binary Brotherhood","Shadow Net","Cyber Legion","Ghost Protocol"}
local ArtStyles = {"abstract","impressionist","surrealist","pop art","contemporary","street art","digital","minimalist","expressionist"}
local MusicGenres = {"pop","rock","hip-hop","electronic","R&B","country","jazz","classical","indie","metal"}
local Sports = {"basketball","football","baseball","soccer","tennis","golf","swimming","track","hockey","volleyball"}
local Hobbies = {"painting","gaming","reading","hiking","cooking","photography","gardening","yoga","dancing","writing"}

----------------------------------------------------------------------
-- GENERATOR FUNCTIONS (Exported for use in event modules)
----------------------------------------------------------------------

function LifeEvents.randomMaleName()
	return MaleNames[math.random(#MaleNames)] .. " " .. LastNames[math.random(#LastNames)]
end

function LifeEvents.randomFemaleName()
	return FemaleNames[math.random(#FemaleNames)] .. " " .. LastNames[math.random(#LastNames)]
end

function LifeEvents.randomName()
	return math.random(2) == 1 and LifeEvents.randomMaleName() or LifeEvents.randomFemaleName()
end

function LifeEvents.randomFirstName()
	local names = math.random(2) == 1 and MaleNames or FemaleNames
	return names[math.random(#names)]
end

function LifeEvents.randomLastName()
	return LastNames[math.random(#LastNames)]
end

function LifeEvents.randomSchool()
	return Schools[math.random(#Schools)]
end

function LifeEvents.randomUniversity()
	return Universities[math.random(#Universities)]
end

function LifeEvents.randomCollege()
	return Colleges[math.random(#Colleges)]
end

function LifeEvents.randomCompany()
	return Companies[math.random(#Companies)]
end

function LifeEvents.randomCity()
	return Cities[math.random(#Cities)]
end

function LifeEvents.randomCountry()
	return Countries[math.random(#Countries)]
end

function LifeEvents.randomRacingTeam()
	return RacingTeams[math.random(#RacingTeams)]
end

function LifeEvents.randomHackerGroup()
	return HackerGroups[math.random(#HackerGroups)]
end

function LifeEvents.randomArtStyle()
	return ArtStyles[math.random(#ArtStyles)]
end

function LifeEvents.randomMusicGenre()
	return MusicGenres[math.random(#MusicGenres)]
end

function LifeEvents.randomSport()
	return Sports[math.random(#Sports)]
end

function LifeEvents.randomHobby()
	return Hobbies[math.random(#Hobbies)]
end

function LifeEvents.randomAmount(min, max)
	return math.random(min, max)
end

function LifeEvents.randomPercent()
	return math.random(1, 100)
end

----------------------------------------------------------------------
-- STATE HELPER FUNCTIONS (for event conditions)
----------------------------------------------------------------------

function LifeEvents.hasFriend(state)
	local rels = state.Relationships or {}
	for _, rel in ipairs(rels) do
		if rel.category == "friends" then return true end
	end
	return false
end

function LifeEvents.hasPartner(state)
	local rels = state.Relationships or {}
	for _, rel in ipairs(rels) do
		if rel.category == "romantic" or rel.type == "spouse" or rel.type == "partner" then return true end
	end
	return false
end

function LifeEvents.isMarried(state)
	local flags = state.Flags or {}
	return flags.married == true
end

function LifeEvents.hasChildren(state)
	local flags = state.Flags or {}
	return flags.has_children == true or flags.parent == true
end

function LifeEvents.hasJob(state)
	return state.CurrentJob ~= nil or (state.Flags and state.Flags.employed)
end

function LifeEvents.isInJail(state)
	return state.InJail == true or (state.Flags and state.Flags.in_prison)
end

function LifeEvents.isEnrolled(state)
	return state.Enrolled == true or (state.Flags and state.Flags.college_student)
end

function LifeEvents.getFriendName(state)
	local rels = state.Relationships or {}
	for _, rel in ipairs(rels) do
		if rel.category == "friends" and rel.name then
			return rel.name
		end
	end
	return LifeEvents.randomFirstName()
end

function LifeEvents.getPartnerName(state)
	local rels = state.Relationships or {}
	for _, rel in ipairs(rels) do
		if (rel.category == "romantic" or rel.type == "spouse") and rel.name then
			return rel.name
		end
	end
	return LifeEvents.randomFirstName()
end

----------------------------------------------------------------------
-- EDUCATION RANKS (for education-gated events)
----------------------------------------------------------------------

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
	local playerRank = LifeEvents.EducationRanks[playerEdu] or 0
	local requiredRank = LifeEvents.EducationRanks[required] or 0
	return playerRank >= requiredRank
end

----------------------------------------------------------------------
-- CONDITION CHECKING ENGINE
----------------------------------------------------------------------

local function hasAnyFlag(flags, flagList)
	if not flags or not flagList then return false end
	for _, flagName in ipairs(flagList) do
		if flags[flagName] then return true end
	end
	return false
end

local function hasAllFlags(flags, flagList)
	if not flagList then return true end
	if not flags then return false end
	for _, flagName in ipairs(flagList) do
		if not flags[flagName] then return false end
	end
	return true
end

local function hasNoFlags(flags, flagList)
	if not flagList then return true end
	if not flags then return true end
	for _, flagName in ipairs(flagList) do
		if flags[flagName] then return false end
	end
	return true
end

-- Check if an event's conditions are met
function LifeEvents.checkConditions(event, state)
	local age = state.Age or 0
	local flags = state.Flags or {}
	
	-- Age check
	if event.minAge and age < event.minAge then return false, "too_young" end
	if event.maxAge and age > event.maxAge then return false, "too_old" end
	
	-- Flag checks (legacy single flags)
	if event.requiresFlag and not flags[event.requiresFlag] then return false, "missing_flag" end
	if event.requiresFlag2 and not flags[event.requiresFlag2] then return false, "missing_flag2" end
	if event.blockIfFlag and flags[event.blockIfFlag] then return false, "blocked_flag" end
	
	-- Flag checks (array style)
	if event.requiresAnyFlag and not hasAnyFlag(flags, event.requiresAnyFlag) then return false, "missing_any_flag" end
	if event.requiresAllFlags and not hasAllFlags(flags, event.requiresAllFlags) then return false, "missing_all_flags" end
	if event.blockIfAnyFlag and hasAnyFlag(flags, event.blockIfAnyFlag) then return false, "blocked_any_flag" end
	
	-- One-time events
	if event.oneTime then
		local seenEvents = state.SeenEvents or {}
		if seenEvents[event.id] then return false, "already_seen" end
	end
	
	-- Cooldown check
	if event.cooldown then
		local cooldowns = state.EventCooldowns or {}
		local lastFired = cooldowns[event.id]
		if lastFired and (age - lastFired) < event.cooldown then
			return false, "on_cooldown"
		end
	end
	
	-- Education requirement
	if event.requiresEducation then
		if not LifeEvents.hasEducation(state, event.requiresEducation) then
			return false, "insufficient_education"
		end
	end
	
	-- Custom requires function
	if event.requires and type(event.requires) == "function" then
		local ok, err = pcall(function()
			return event.requires(state)
		end)
		if not ok or not err then return false, "custom_condition_failed" end
	end
	
	-- Career requirement
	if event.requiredCareerId then
		local career = state.PrimaryCareer
		if not career or career.careerId ~= event.requiredCareerId then
			return false, "wrong_career"
		end
		if event.requiredCareerMinTier and career.tierIndex < event.requiredCareerMinTier then
			return false, "career_tier_too_low"
		end
	end
	
	return true, "ok"
end

----------------------------------------------------------------------
-- EVENT SELECTION ENGINE
----------------------------------------------------------------------

-- Get all events eligible for current state
function LifeEvents.getEligibleEvents(state)
	local eligible = {}
	
	for _, event in ipairs(allEvents) do
		local passes, reason = LifeEvents.checkConditions(event, state)
		if passes then
			table.insert(eligible, event)
		elseif DEBUG_MODE then
			-- Log why events were filtered
		end
	end
	
	return eligible
end

-- Select a weighted random event from candidates
function LifeEvents.selectWeightedEvent(candidates, state)
	if #candidates == 0 then return nil end
	
	-- Calculate weights with bonuses
	local totalWeight = 0
	local weightedCandidates = {}
	
	for _, event in ipairs(candidates) do
		local weight = event.weight or 10
		
		-- Milestone events get boosted
		if event.milestone then
			weight = weight * 2
		end
		
		-- Career-related events get boosted if player is in that career
		if event.careerId and state.PrimaryCareer then
			if state.PrimaryCareer.careerId == event.careerId then
				weight = weight * 1.5
			end
		end
		
		-- Tags-based boosting could go here
		
		totalWeight = totalWeight + weight
		table.insert(weightedCandidates, {
			event = event,
			weight = weight,
			cumulativeWeight = totalWeight,
		})
	end
	
	-- Roll weighted random
	local roll = math.random() * totalWeight
	
	for _, candidate in ipairs(weightedCandidates) do
		if roll <= candidate.cumulativeWeight then
			return candidate.event
		end
	end
	
	-- Fallback to first event
	return candidates[1]
end

-- Select multiple events (for showing event queue)
function LifeEvents.selectMultipleEvents(state, count)
	local eligible = LifeEvents.getEligibleEvents(state)
	local selected = {}
	local usedIds = {}
	
	for i = 1, count do
		-- Filter out already selected
		local remaining = {}
		for _, event in ipairs(eligible) do
			if not usedIds[event.id] then
				table.insert(remaining, event)
			end
		end
		
		if #remaining == 0 then break end
		
		local event = LifeEvents.selectWeightedEvent(remaining, state)
		if event then
			table.insert(selected, event)
			usedIds[event.id] = true
		end
	end
	
	return selected
end

----------------------------------------------------------------------
-- EVENT EFFECT APPLICATION
----------------------------------------------------------------------

function LifeEvents.applyChoiceEffects(choice, state)
	local effects = choice.effects or {}
	local stats = state.Stats or {}
	
	-- Apply stat changes
	for statName, delta in pairs(effects) do
		if statName ~= "Money" then
			local current = stats[statName] or 50
			local newVal = math.clamp(current + delta, 0, 100)
			stats[statName] = newVal
		end
	end
	
	-- Apply money change
	if effects.Money then
		state.Money = (state.Money or 0) + effects.Money
	end
	
	-- Set flags
	local flags = state.Flags or {}
	
	if choice.setFlag then
		flags[choice.setFlag] = true
	end
	
	if choice.setFlags then
		for _, flagName in ipairs(choice.setFlags) do
			flags[flagName] = true
		end
	end
	
	if choice.clearFlag then
		flags[choice.clearFlag] = nil
	end
	
	if choice.clearFlags then
		for _, flagName in ipairs(choice.clearFlags) do
			flags[flagName] = nil
		end
	end
	
	state.Flags = flags
	state.Stats = stats
	
	return state
end

----------------------------------------------------------------------
-- EVENT STORAGE
----------------------------------------------------------------------

local allEvents = {}
local moduleStats = {}

----------------------------------------------------------------------
-- MODULE LOADING
----------------------------------------------------------------------

local MODULE_LIST = {
	"child_0_5",
	"child_6_12", 
	"teen_13_17",
	"young_adult_18_35",
	"middle_aged_36_55",
	"senior_55_plus",
	"relationships",
	"health",
	"wealth",
	"random_encounters",
	"disasters",
	"fame",
	"prison",
	"career_tech",
	"career_medical",
	"career_legal",
	"career_business",
	"career_arts",
	"career_sports",
	"career_military",
	"career_political",
	"career_education",
	"career_criminal",
}

-- Validation
local function validateEvent(event, moduleName)
	local errors = {}
	
	if not event.id then
		table.insert(errors, moduleName .. ": Event missing 'id'")
	end
	
	if not event.text then
		table.insert(errors, (event.id or "unknown") .. ": Missing 'text'")
	end
	
	if not event.choices or #event.choices == 0 then
		table.insert(errors, (event.id or "unknown") .. ": Missing 'choices'")
	else
		for i, choice in ipairs(event.choices) do
			if not choice.text then
				table.insert(errors, (event.id or "unknown") .. ": Choice " .. i .. " missing 'text'")
			end
		end
	end
	
	return errors
end

-- Load all event modules
function LifeEvents.loadAllModules()
	allEvents = {}
	moduleStats = {}
	
	local totalEvents = 0
	local totalErrors = 0
	
	local containerFolder = script.Parent
	
	if DEBUG_MODE then
		print("[LifeEvents] ═══════════════════════════════════════════")
		print("[LifeEvents] Loading from:", containerFolder:GetFullName())
	end
	
	for _, moduleName in ipairs(MODULE_LIST) do
		local moduleScript = containerFolder:FindFirstChild(moduleName)
		
		if moduleScript then
			local success, result = pcall(function()
				return require(moduleScript)
			end)
			
			if success and result and result.events then
				local eventCount = 0
				local moduleErrors = 0
				
				for _, event in ipairs(result.events) do
					-- Validate
					if VALIDATE_ON_LOAD then
						local errors = validateEvent(event, moduleName)
						if #errors > 0 then
							moduleErrors = moduleErrors + #errors
							totalErrors = totalErrors + #errors
							for _, err in ipairs(errors) do
								warn("[LifeEvents] Validation error:", err)
							end
						end
					end
					
					-- Add source module info
					event._sourceModule = moduleName
					
					-- Add to pool
					table.insert(allEvents, event)
					eventCount = eventCount + 1
				end
				
				totalEvents = totalEvents + eventCount
				moduleStats[moduleName] = {
					loaded = true,
					eventCount = eventCount,
					errors = moduleErrors,
				}
				
				if DEBUG_MODE then
					print("[LifeEvents] ✓ Loaded", moduleName, "-", eventCount, "events")
				end
			else
				moduleStats[moduleName] = { loaded = false, error = tostring(result) }
				if DEBUG_MODE then
					warn("[LifeEvents] ✗ Failed to load", moduleName, ":", tostring(result))
				end
			end
		else
			if DEBUG_MODE then
				print("[LifeEvents] ✗ Skipped", moduleName, "(not found)")
			end
		end
	end
	
	print("[LifeEvents] ═══════════════════════════════════════════")
	print("[LifeEvents] ✅ Loaded", totalEvents, "events from", #MODULE_LIST, "modules")
	if totalErrors > 0 then
		warn("[LifeEvents] ⚠️", totalErrors, "validation errors found!")
	end
	print("[LifeEvents] ═══════════════════════════════════════════")
	
	return allEvents
end

----------------------------------------------------------------------
-- PUBLIC API
----------------------------------------------------------------------

function LifeEvents.getEvents()
	if #allEvents == 0 then
		LifeEvents.loadAllModules()
	end
	return allEvents
end

function LifeEvents.getEventById(id)
	if #allEvents == 0 then
		LifeEvents.loadAllModules()
	end
	
	for _, event in ipairs(allEvents) do
		if event.id == id then
			return event
		end
	end
	
	return nil
end

function LifeEvents.getEventsByCategory(category)
	if #allEvents == 0 then
		LifeEvents.loadAllModules()
	end
	
	local filtered = {}
	for _, event in ipairs(allEvents) do
		if event.category == category then
			table.insert(filtered, event)
		end
	end
	return filtered
end

function LifeEvents.getEventsForAge(age)
	if #allEvents == 0 then
		LifeEvents.loadAllModules()
	end
	
	local filtered = {}
	for _, event in ipairs(allEvents) do
		local minAge = event.minAge or 0
		local maxAge = event.maxAge or 120
		if age >= minAge and age <= maxAge then
			table.insert(filtered, event)
		end
	end
	return filtered
end

function LifeEvents.getStats()
	return {
		totalEvents = #allEvents,
		moduleStats = moduleStats,
		modulesLoaded = #MODULE_LIST,
	}
end

function LifeEvents.reload()
	print("[LifeEvents] Reloading all modules...")
	return LifeEvents.loadAllModules()
end

function LifeEvents.validateAll()
	if #allEvents == 0 then
		LifeEvents.loadAllModules()
	end
	
	local errors = {}
	local seenIds = {}
	
	for _, event in ipairs(allEvents) do
		if event.id then
			if seenIds[event.id] then
				table.insert(errors, {
					type = "duplicate_id",
					id = event.id,
					message = "Duplicate event ID found",
				})
			else
				seenIds[event.id] = true
			end
		end
		
		local eventErrors = validateEvent(event, event._sourceModule or "unknown")
		for _, err in ipairs(eventErrors) do
			table.insert(errors, {
				type = "validation",
				id = event.id or "UNKNOWN",
				message = err,
			})
		end
	end
	
	return {
		valid = #errors == 0,
		errorCount = #errors,
		errors = errors,
	}
end

----------------------------------------------------------------------
-- LEGACY COMPATIBILITY
----------------------------------------------------------------------

LifeEvents.Events = setmetatable({}, {
	__index = function(_, key)
		if key == "getEvents" then
			return LifeEvents.getEvents
		end
		return nil
	end,
	__call = function()
		return LifeEvents.getEvents()
	end,
})

----------------------------------------------------------------------
-- AUTO-LOAD ON REQUIRE
----------------------------------------------------------------------

task.spawn(function()
	task.wait(0.1)
	LifeEvents.loadAllModules()
end)

return LifeEvents
