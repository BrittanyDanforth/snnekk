-- LifeEvents/init.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- MODULAR EVENT SYSTEM - Central Loader
-- ═══════════════════════════════════════════════════════════════════════════════
-- This module loads all event modules and provides a unified event pool
-- Designed to scale to 30,000+ events without becoming spaghetti code
--
-- ARCHITECTURE:
-- Each event module returns a table of events organized by category
-- This loader merges all modules and provides validation
--
-- TO ADD NEW EVENTS:
-- 1. Create a new .lua file in this folder (e.g., career_sports.lua)
-- 2. Export your events table
-- 3. Add require() below in MODULE_LIST
-- 4. Events will automatically be loaded and validated
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = {}

----------------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------------

local DEBUG_MODE = true -- Set to true for verbose loading logs
local VALIDATE_ON_LOAD = true -- Validate events when loading (catches errors early)

-- Debug info about script location
print("[LifeEvents] ═══════════════════════════════════════════")
print("[LifeEvents] Script:", script:GetFullName())
print("[LifeEvents] Parent:", script.Parent and script.Parent:GetFullName() or "nil")
print("[LifeEvents] Children:", #script:GetChildren())

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

-- Shared data pools
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

-- Money formatting
function LifeEvents.formatMoney(amount)
	if not amount then return "$0" end
	amount = math.floor(amount)
	if amount >= 1000000000 then
		return string.format("$%.1fB", amount / 1000000000)
	elseif amount >= 1000000 then
		return string.format("$%.1fM", amount / 1000000)
	elseif amount >= 1000 then
		return string.format("$%.1fK", amount / 1000)
	else
		return "$" .. tostring(amount)
	end
end

-- Random range helper
function LifeEvents.randomRange(min, max)
	return math.random(min, max)
end

-- Weighted random choice
function LifeEvents.weightedRandom(options)
	-- options = { {value = x, weight = n}, ... }
	local totalWeight = 0
	for _, opt in ipairs(options) do
		totalWeight = totalWeight + (opt.weight or 1)
	end
	
	local roll = math.random() * totalWeight
	local cumulative = 0
	
	for _, opt in ipairs(options) do
		cumulative = cumulative + (opt.weight or 1)
		if roll <= cumulative then
			return opt.value
		end
	end
	
	return options[#options].value
end

----------------------------------------------------------------------
-- CAREER CHECK HELPERS (Exported)
----------------------------------------------------------------------

function LifeEvents.hasNoCareer(state)
	local f = state.Flags or {}
	return not (f.teacher or f.racer or f.artist or f.hacker_career or f.gang_member or f.president or f.doctor or f.lawyer or f.athlete)
end

function LifeEvents.hasNoCriminalRecord(state)
	local f = state.Flags or {}
	return not (f.arrested or f.in_prison or f.gang_member or f.ex_convict)
end

function LifeEvents.isInPrison(state)
	local f = state.Flags or {}
	return f.in_prison or f.incarcerated
end

function LifeEvents.hasJob(state)
	-- Check ExtendedState for current job (would need to be passed in)
	local f = state.Flags or {}
	return f.employed or f.has_job
end

function LifeEvents.isMarried(state)
	local f = state.Flags or {}
	return f.married
end

function LifeEvents.hasChildren(state)
	local f = state.Flags or {}
	return f.has_children or f.parent
end

----------------------------------------------------------------------
-- EVENT TEMPLATE HELPERS (Create common event patterns)
----------------------------------------------------------------------

-- Create a simple decision event
function LifeEvents.createDecisionEvent(config)
	return {
		id = config.id,
		minAge = config.minAge or 0,
		maxAge = config.maxAge or 120,
		weight = config.weight or 10,
		emoji = config.emoji or "❓",
		title = config.title,
		text = config.text,
		category = config.category or "misc",
		oneTime = config.oneTime or false,
		cooldown = config.cooldown,
		requiresFlag = config.requiresFlag,
		blockIfFlag = config.blockIfFlag,
		getDynamicData = config.getDynamicData,
		choices = config.choices,
	}
end

-- Create a milestone event (high weight, one-time)
function LifeEvents.createMilestoneEvent(config)
	local event = LifeEvents.createDecisionEvent(config)
	event.milestone = true
	event.oneTime = true
	event.weight = config.weight or 100
	return event
end

-- Create a repeatable event (can happen multiple times with cooldown)
function LifeEvents.createRepeatableEvent(config)
	local event = LifeEvents.createDecisionEvent(config)
	event.oneTime = false
	event.cooldown = config.cooldown or 3
	return event
end

-- Create a career path event
function LifeEvents.createCareerEvent(config)
	local event = LifeEvents.createDecisionEvent(config)
	event.category = config.category or "work"
	event.requiresFlag = config.requiresFlag
	return event
end

-- Create a choice with common effects structure
function LifeEvents.createChoice(text, effects, resultText, flags)
	local choice = {
		text = text,
		effects = effects or {},
		resultText = resultText,
	}
	
	if flags then
		if flags.set then choice.setFlag = flags.set end
		if flags.setMultiple then choice.setFlags = flags.setMultiple end
		if flags.clear then choice.clearFlag = flags.clear end
		if flags.clearMultiple then choice.clearFlags = flags.clearMultiple end
	end
	
	return choice
end

----------------------------------------------------------------------
-- MODULE LOADING SYSTEM
----------------------------------------------------------------------

-- List of all event modules to load
-- Add new modules here as they're created
local MODULE_LIST = {
	-- ═══════════════════════════════════════════════════════════════
	-- CORE LIFE STAGES (Massive expansion - 700+ events total)
	-- ═══════════════════════════════════════════════════════════════
	"child_0_5",          -- Ages 0-5: Birth, infant, toddler, preschool (100+ events)
	"child_6_12",         -- Ages 6-12: Elementary school years (120+ events)
	"teen_13_17",         -- Ages 13-17: Middle school & high school (130+ events)
	"young_adult_18_35",  -- Ages 18-35: College, career start, relationships (140+ events)
	"middle_aged_36_55",  -- Ages 36-55: Career peak, family, midlife (100+ events)
	"senior_55_plus",     -- Ages 55+: Retirement, golden years (100+ events)
	
	-- ═══════════════════════════════════════════════════════════════
	-- CAREER PATHS (Specialized events)
	-- ═══════════════════════════════════════════════════════════════
	"career_criminal",    -- Crime, gangs, prison life
	"career_political",   -- Politics, elections, government
	"career_arts",        -- Art, music, entertainment, fame
	"career_tech",        -- Technology, hacking, startups
	"career_sports",      -- Athletics, racing, competition
	"career_business",    -- Business, entrepreneurship
	"career_medical",     -- Doctor, nurse, healthcare
	"career_education",   -- Teacher, professor, academia
	"career_legal",       -- Lawyer, judge, law enforcement
	"career_military",    -- Military, veteran
	
	-- ═══════════════════════════════════════════════════════════════
	-- LIFE THEMES
	-- ═══════════════════════════════════════════════════════════════
	"relationships",      -- Romance, marriage, family, friends
	"health",             -- Illness, injury, wellness
	"wealth",             -- Money, investments, inheritance
	"prison",             -- Prison-specific events
	"random_encounters",  -- Random life events
	"disasters",          -- Natural disasters, accidents
	"fame",               -- Celebrity, social media, influencer
}

-- Storage for loaded events
local allEvents = {}
local eventIndex = {} -- Quick lookup by ID
local moduleStats = {} -- Track events per module

-- Load a single module safely
local function loadModule(moduleName)
	-- Try multiple ways to find the module
	local moduleScript = nil
	
	-- Method 1: WaitForChild (works when this script is a folder's init)
	local success1, child = pcall(function()
		return script:WaitForChild(moduleName, 2)
	end)
	if success1 and child then
		moduleScript = child
	end
	
	-- Method 2: FindFirstChild (faster, no wait)
	if not moduleScript then
		moduleScript = script:FindFirstChild(moduleName)
	end
	
	-- Method 3: Check parent (in case we're in a different structure)
	if not moduleScript and script.Parent then
		local parentFolder = script.Parent:FindFirstChild("LifeEvents")
		if parentFolder then
			moduleScript = parentFolder:FindFirstChild(moduleName)
		end
	end
	
	if not moduleScript then
		if DEBUG_MODE then
			warn("[LifeEvents] Module not found:", moduleName)
		end
		return nil
	end
	
	-- Require the found module
	local success, result = pcall(function()
		return require(moduleScript)
	end)
	
	if not success then
		warn("[LifeEvents] Failed to require module:", moduleName, "-", result)
		return nil
	end
	
	return result
end

-- Validate a single event
local function validateEvent(event, moduleName)
	local errors = {}
	
	-- Required fields
	if not event.id then
		table.insert(errors, "Missing 'id' field")
	end
	if not event.text and not event.title then
		table.insert(errors, "Missing 'text' or 'title' field")
	end
	if not event.choices or #event.choices == 0 then
		table.insert(errors, "Missing or empty 'choices' array")
	end
	
	-- Type checks
	if event.minAge and type(event.minAge) ~= "number" then
		table.insert(errors, "'minAge' must be a number")
	end
	if event.maxAge and type(event.maxAge) ~= "number" then
		table.insert(errors, "'maxAge' must be a number")
	end
	if event.weight and type(event.weight) ~= "number" then
		table.insert(errors, "'weight' must be a number")
	end
	
	-- Age range validation
	if event.minAge and event.maxAge and event.minAge > event.maxAge then
		table.insert(errors, "minAge > maxAge")
	end
	
	-- Validate choices
	if event.choices then
		for i, choice in ipairs(event.choices) do
			if not choice.text then
				table.insert(errors, "Choice " .. i .. " missing 'text'")
			end
		end
	end
	
	-- Check for duplicate ID
	if event.id and eventIndex[event.id] then
		table.insert(errors, "Duplicate event ID: " .. event.id .. " (already in " .. eventIndex[event.id] .. ")")
	end
	
	return errors
end

-- Load all event modules
function LifeEvents.loadAllModules()
	allEvents = {}
	eventIndex = {}
	moduleStats = {}
	
	local totalEvents = 0
	local totalErrors = 0
	
	print("[LifeEvents] ═══════════════════════════════════════════")
	print("[LifeEvents] Loading event modules...")
	print("[LifeEvents] Available children of script:")
	for _, child in ipairs(script:GetChildren()) do
		print("  -", child.Name, "(" .. child.ClassName .. ")")
	end
	
	for _, moduleName in ipairs(MODULE_LIST) do
		local moduleData = loadModule(moduleName)
		
		if moduleData and moduleData.events then
			local moduleEventCount = 0
			local moduleErrors = 0
			
			for _, event in ipairs(moduleData.events) do
				-- Validate if enabled
				if VALIDATE_ON_LOAD then
					local errors = validateEvent(event, moduleName)
					if #errors > 0 then
						moduleErrors = moduleErrors + 1
						totalErrors = totalErrors + 1
						warn("[LifeEvents] Event validation failed in", moduleName, ":", event.id or "UNKNOWN")
						for _, err in ipairs(errors) do
							warn("  - " .. err)
						end
					end
				end
				
				-- Add event to pool (even if has errors, for debugging)
				table.insert(allEvents, event)
				if event.id then
					eventIndex[event.id] = moduleName
				end
				moduleEventCount = moduleEventCount + 1
			end
			
			moduleStats[moduleName] = {
				count = moduleEventCount,
				errors = moduleErrors,
			}
			
			totalEvents = totalEvents + moduleEventCount
			
			if DEBUG_MODE then
				print("[LifeEvents] ✓ Loaded", moduleName, ":", moduleEventCount, "events", moduleErrors > 0 and ("(" .. moduleErrors .. " errors)") or "")
			end
		else
			if DEBUG_MODE then
				print("[LifeEvents] ✗ Skipped", moduleName, "(not found or empty)")
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

-- Get all events (load if needed)
function LifeEvents.getEvents()
	if #allEvents == 0 then
		LifeEvents.loadAllModules()
	end
	return allEvents
end

-- Get event by ID
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

-- Get events by category
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

-- Get events for age range
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

-- Get loading statistics
function LifeEvents.getStats()
	return {
		totalEvents = #allEvents,
		moduleStats = moduleStats,
		modulesLoaded = #MODULE_LIST,
	}
end

-- Reload all modules (for development/hot reload)
function LifeEvents.reload()
	print("[LifeEvents] Reloading all modules...")
	return LifeEvents.loadAllModules()
end

-- Validate all events (comprehensive check)
function LifeEvents.validateAll()
	if #allEvents == 0 then
		LifeEvents.loadAllModules()
	end
	
	local errors = {}
	local seenIds = {}
	
	for _, event in ipairs(allEvents) do
		-- Check duplicates
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
		
		-- Validate structure
		local eventErrors = validateEvent(event, "unknown")
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

-- For compatibility with existing EventLibrary.lua
-- Returns events in the same format the old system expected
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

-- Load modules when this file is required
task.spawn(function()
	task.wait(0.1) -- Small delay to ensure all modules are available
	LifeEvents.loadAllModules()
end)

return LifeEvents
