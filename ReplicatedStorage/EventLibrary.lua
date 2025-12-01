-- EventLibrary.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- GODLY EVENT LIBRARY - Complete Rewrite for BitLife-Style Gameplay
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- This is the main public API for the event system. It wraps the LifeEvents
-- module and provides all the functionality needed by the game.
--
-- Features:
-- - 50+ Career paths with tiers and branches
-- - Smart event selection based on player state
-- - Chain/story arc support
-- - Career progression system
-- - Roblox TOS compliant content
--
-- ═══════════════════════════════════════════════════════════════════════════════

local EventLibrary = {}

-- ═══════════════════════════════════════════════════════════════
-- LOAD CORE SYSTEMS
-- ═══════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent:WaitForChild("LifeEvents"))
local RelationshipService = nil

-- Lazy load RelationshipService
local function getRelationshipService()
	if RelationshipService then return RelationshipService end
	local success, result = pcall(function()
		return require(script.Parent:WaitForChild("RelationshipService", 2))
	end)
	if success and result then
		RelationshipService = result
		print("[EventLibrary] ✅ RelationshipService loaded")
	else
		warn("[EventLibrary] ⚠️ RelationshipService not found, using fallbacks")
	end
	return RelationshipService
end

-- ═══════════════════════════════════════════════════════════════
-- EXPORT CORE SYSTEMS
-- ═══════════════════════════════════════════════════════════════

EventLibrary.CareerLibrary = LifeEvents.CareerLibrary
EventLibrary.CareerSystem = LifeEvents.CareerSystem
EventLibrary.EventEngine = LifeEvents.EventEngine

-- ═══════════════════════════════════════════════════════════════
-- NAME & DATA GENERATORS
-- ═══════════════════════════════════════════════════════════════

local MaleNames = {
	"James", "Michael", "David", "Chris", "Daniel", "Matt", "Jake", "Ryan", "Tyler", "Brandon",
	"Kevin", "Justin", "Josh", "Nick", "Alex", "Brian", "Eric", "Andrew", "Sean", "Kyle",
	"Adam", "Aaron", "Ethan", "Nathan", "Zach", "Dylan", "Connor", "Mason", "Logan", "Lucas",
	"Marcus", "Darius", "Jerome", "DeShawn", "Jamal", "Carlos", "Miguel", "Antonio", "Roberto",
	"Giovanni", "Vladimir", "Dmitri", "Kenji", "Hiroshi", "Wei", "Jin", "Ahmed", "Omar", "Raj",
	"Vikram", "Liam", "Noah", "Oliver", "William", "Henry", "Sebastian", "Jack", "Aiden", "Owen",
	"Samuel", "Benjamin", "Theodore", "Leo", "Finn", "Caleb", "Max", "Jasper", "Felix", "Theo"
}

local FemaleNames = {
	"Emma", "Sophia", "Olivia", "Ava", "Isabella", "Mia", "Emily", "Abigail", "Madison", "Elizabeth",
	"Ella", "Avery", "Chloe", "Sofia", "Grace", "Lily", "Hannah", "Aria", "Zoe", "Riley",
	"Nora", "Scarlett", "Stella", "Luna", "Hazel", "Jasmine", "Aaliyah", "Destiny", "Diamond",
	"Keisha", "Maria", "Carmen", "Rosa", "Valentina", "Yuki", "Mei", "Sakura", "Priya", "Ananya",
	"Fatima", "Layla", "Charlotte", "Amelia", "Harper", "Evelyn", "Penelope", "Camila", "Eleanor",
	"Violet", "Aurora", "Savannah", "Brooklyn", "Leah", "Natalie", "Samantha", "Audrey", "Claire"
}

local LastNames = {
	"Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez",
	"Martinez", "Anderson", "Taylor", "Thomas", "Moore", "Jackson", "Martin", "Lee", "Thompson",
	"White", "Harris", "Clark", "Lewis", "Robinson", "Walker", "Young", "King", "Wright", "Scott",
	"Green", "Baker", "Adams", "Nelson", "Hill", "Mitchell", "Roberts", "Campbell", "Phillips",
	"Evans", "Turner", "Torres", "Parker", "Collins", "Edwards", "Stewart", "Morris", "Murphy",
	"Rivera", "Cook", "Rogers", "Morgan", "Peterson", "Cooper", "Reed", "Bailey", "Bell", "Gomez",
	"Kelly", "Howard", "Ward", "Cox", "Diaz", "Richardson", "Wood", "Watson", "Brooks", "Bennett",
	"Gray", "Sanders", "Price", "Hughes", "Fitzgerald", "O'Brien", "McCarthy", "Sullivan", "Kim",
	"Park", "Chen", "Wang", "Nakamura", "Tanaka", "Patel", "Singh", "Khan", "Nguyen", "Tran"
}

-- School/University names
local Schools = {"Lincoln High", "Washington Academy", "Jefferson High", "Roosevelt Prep", "Kennedy School", "Westview High", "Eastside Academy", "Central High", "Northgate Prep", "Southfield High"}
local Universities = {"Harvard", "Yale", "Stanford", "MIT", "Princeton", "Columbia", "State University", "City College", "Tech Institute", "National University"}
local CommunityColleges = {"Metro Community College", "Valley CC", "Central Community College", "Riverside CC", "Lakeside Community College"}

-- Company names by industry
local TechCompanies = {"TechStart Inc", "CodeCraft Labs", "Digital Dynamics", "ByteWave Solutions", "InnovateTech", "Nexus Technologies", "CloudByte Systems", "Fusion Software", "Apex Digital", "Quantum Code"}
local FinanceCompanies = {"Goldman & Sterling", "Morgan Hill Partners", "Capital First Group", "WealthMax Advisory", "Blue Sky Capital", "Venture Partners", "Growth Fund", "Angel Group"}
local MedicalFacilities = {"City General Hospital", "University Medical Center", "Memorial Hospital", "Regional Medical Center", "Metro Health System"}
local LawFirms = {"Sterling & Associates", "Parker Law Group", "Justice Partners LLP", "Smith & Williams", "Metro Legal Services"}
local GameStudios = {"Pixel Forge Studios", "Neon Games", "Thunderbolt Entertainment", "Starlight Interactive", "Iron Crown Games"}
local RecordLabels = {"Rising Star Records", "Urban Sound Media", "Horizon Music Group", "Elite Artists Label", "Indie Wave Records"}

-- Name generators
function EventLibrary.randomMaleName()
	return MaleNames[math.random(#MaleNames)] .. " " .. LastNames[math.random(#LastNames)]
end

function EventLibrary.randomFemaleName()
	return FemaleNames[math.random(#FemaleNames)] .. " " .. LastNames[math.random(#LastNames)]
end

function EventLibrary.randomName()
	return math.random(2) == 1 and EventLibrary.randomMaleName() or EventLibrary.randomFemaleName()
end

function EventLibrary.randomFirstName()
	if math.random(2) == 1 then
		return MaleNames[math.random(#MaleNames)]
	else
		return FemaleNames[math.random(#FemaleNames)]
	end
end

function EventLibrary.randomLastName()
	return LastNames[math.random(#LastNames)]
end

-- Institution generators
function EventLibrary.randomSchool()
	return Schools[math.random(#Schools)]
end

function EventLibrary.randomUniversity()
	return Universities[math.random(#Universities)]
end

function EventLibrary.randomCommunityCollege()
	return CommunityColleges[math.random(#CommunityColleges)]
end

-- Company generators
function EventLibrary.randomCompany(industry)
	if industry == "tech" then
		return TechCompanies[math.random(#TechCompanies)]
	elseif industry == "finance" then
		return FinanceCompanies[math.random(#FinanceCompanies)]
	elseif industry == "medical" then
		return MedicalFacilities[math.random(#MedicalFacilities)]
	elseif industry == "legal" then
		return LawFirms[math.random(#LawFirms)]
	elseif industry == "games" then
		return GameStudios[math.random(#GameStudios)]
	elseif industry == "music" then
		return RecordLabels[math.random(#RecordLabels)]
	else
		-- Generic company
		local prefixes = {"Global", "United", "Premier", "Elite", "Apex", "Summit", "Prime", "Core", "Nexus", "Vertex"}
		local suffixes = {"Industries", "Corp", "Inc", "Group", "Solutions", "Systems", "Enterprises", "Holdings"}
		return prefixes[math.random(#prefixes)] .. " " .. suffixes[math.random(#suffixes)]
	end
end

-- ═══════════════════════════════════════════════════════════════
-- RELATIONSHIP HELPERS
-- ═══════════════════════════════════════════════════════════════

function EventLibrary.hasFriend(state)
	local RS = getRelationshipService()
	if RS and RS.hasFriend then return RS.hasFriend(state) end
	return LifeEvents.hasFriend(state)
end

function EventLibrary.hasPartner(state)
	local RS = getRelationshipService()
	if RS and RS.hasPartner then return RS.hasPartner(state) end
	return LifeEvents.hasPartner(state)
end

function EventLibrary.isMarried(state)
	local RS = getRelationshipService()
	if RS and RS.isMarried then return RS.isMarried(state) end
	return LifeEvents.isMarried(state)
end

function EventLibrary.hasChildren(state)
	local RS = getRelationshipService()
	if RS and RS.hasChildren then return RS.hasChildren(state) end
	return LifeEvents.hasChildren(state)
end

function EventLibrary.getFriendName(state)
	local RS = getRelationshipService()
	if RS and RS.getFriendName then return RS.getFriendName(state) end
	return LifeEvents.getFriendName(state)
end

function EventLibrary.getPartnerName(state)
	local RS = getRelationshipService()
	if RS and RS.getPartnerName then return RS.getPartnerName(state) end
	return LifeEvents.getPartnerName(state)
end

-- Get or create a friend relationship
function EventLibrary.getOrCreateFriend(state, opts)
	opts = opts or {}
	local RS = getRelationshipService()
	
	if RS and RS.getOrCreateFriend then
		return RS.getOrCreateFriend(state, opts)
	end
	
	-- Fallback: check existing relationships
	if state.Relationships then
		for _, rel in pairs(state.Relationships) do
			if rel.type == "friend" and rel.alive ~= false then
				return rel
			end
		end
	end
	
	-- Create placeholder
	return {
		id = "temp_friend_" .. math.random(10000, 99999),
		name = EventLibrary.randomName(),
		type = "friend",
		relationship = 60,
		alive = true
	}
end

-- Get or create a partner relationship
function EventLibrary.getOrCreatePartner(state, opts)
	opts = opts or {}
	local RS = getRelationshipService()
	
	if RS and RS.getOrCreatePartner then
		return RS.getOrCreatePartner(state, opts)
	end
	
	-- Fallback
	if state.Relationships then
		for _, rel in pairs(state.Relationships) do
			if (rel.type == "partner" or rel.type == "spouse" or rel.type == "romance") and rel.alive ~= false then
				return rel
			end
		end
	end
	
	return {
		id = "temp_partner_" .. math.random(10000, 99999),
		name = EventLibrary.randomName(),
		type = "partner",
		relationship = 70,
		alive = true
	}
end

-- ═══════════════════════════════════════════════════════════════
-- STATE HELPERS
-- ═══════════════════════════════════════════════════════════════

function EventLibrary.hasJob(state)
	return LifeEvents.hasJob(state)
end

function EventLibrary.isInJail(state)
	return LifeEvents.isInJail(state)
end

function EventLibrary.isEnrolled(state)
	return LifeEvents.isEnrolled(state)
end

function EventLibrary.hasFlag(state, flag)
	return LifeEvents.hasFlag(state, flag)
end

function EventLibrary.setFlag(state, flag)
	return LifeEvents.setFlag(state, flag)
end

function EventLibrary.clearFlag(state, flag)
	return LifeEvents.clearFlag(state, flag)
end

function EventLibrary.getStat(state, statName)
	return LifeEvents.getStat(state, statName)
end

function EventLibrary.modifyStat(state, statName, amount)
	return LifeEvents.modifyStat(state, statName, amount)
end

function EventLibrary.hasEducation(state, required)
	return LifeEvents.hasEducation(state, required)
end

-- ═══════════════════════════════════════════════════════════════
-- CAREER FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

function EventLibrary.startCareer(state, careerId)
	return LifeEvents.CareerSystem.startCareer(state, careerId)
end

function EventLibrary.getCareerInfo(state)
	return LifeEvents.CareerSystem.getDisplayInfo(state)
end

function EventLibrary.getAvailableCareers(state)
	return LifeEvents.CareerSystem.getAvailableCareers(state)
end

function EventLibrary.calculateIncome(state)
	return LifeEvents.CareerSystem.calculateIncome(state)
end

function EventLibrary.hasCareer(state, careerId)
	return LifeEvents.CareerSystem.hasCareer(state, careerId)
end

function EventLibrary.promoteCareer(state)
	return LifeEvents.CareerSystem.promote(state)
end

function EventLibrary.quitCareer(state)
	return LifeEvents.CareerSystem.quitCareer(state)
end

function EventLibrary.setCareerBranch(state, branch)
	return LifeEvents.CareerSystem.setBranch(state, branch)
end

function EventLibrary.addCareerXP(state, amount)
	return LifeEvents.CareerSystem.addXP(state, amount)
end

function EventLibrary.addCareerReputation(state, amount)
	return LifeEvents.CareerSystem.addReputation(state, amount)
end

-- Called each year to advance career
function EventLibrary.yearPassedCareer(state)
	return LifeEvents.CareerSystem.yearPassed(state)
end

-- ═══════════════════════════════════════════════════════════════
-- EVENT FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

-- Get all loaded events
function EventLibrary.getAllEvents()
	return LifeEvents.getAllEvents()
end

-- Get event by ID
function EventLibrary.getEvent(eventId)
	return LifeEvents.getEvent(eventId)
end

-- Get events for a specific age
function EventLibrary.getEventsForAge(age)
	return LifeEvents.getEventsForAge(age)
end

-- Get events by category
function EventLibrary.getEventsByCategory(category)
	return LifeEvents.getEventsByCategory(category)
end

-- Get events by tag
function EventLibrary.getEventsByTag(tag)
	return LifeEvents.getEventsByTag(tag)
end

-- Check if event is eligible
function EventLibrary.checkConditions(event, state)
	return LifeEvents.EventEngine.isEligible(event, state)
end

-- Select events for a year
function EventLibrary.selectEventsForYear(state, config)
	return LifeEvents.EventEngine.selectYearEvents(LifeEvents.getAllEvents(), state, config)
end

-- Select a single random event
function EventLibrary.selectRandomEvent(state)
	return LifeEvents.selectRandomEvent(state)
end

-- Process a choice and apply effects
function EventLibrary.processChoice(event, choiceIndex, state)
	return LifeEvents.EventEngine.completeEvent(event, choiceIndex, state)
end

-- Get processed event text
function EventLibrary.getEventText(event, state)
	return LifeEvents.EventEngine.processEventText(event, state)
end

-- Get event emoji
function EventLibrary.getEventEmoji(event, state)
	return LifeEvents.EventEngine.getEventEmoji(event, state)
end

-- ═══════════════════════════════════════════════════════════════
-- LEGACY COMPATIBILITY - Events Array
-- ═══════════════════════════════════════════════════════════════

-- For backwards compatibility, expose events as EventLibrary.events
-- This allows old code that does `for _, event in ipairs(EventLibrary.events)` to work
EventLibrary.events = LifeEvents.getAllEvents()

-- ═══════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

-- Random amount generator
function EventLibrary.randomAmount(min, max)
	return math.random(min, max)
end

-- Random percent (0.0 to 1.0)
function EventLibrary.randomPercent()
	return math.random()
end

-- Weighted random choice from options
function EventLibrary.weightedChoice(options)
	-- options = {{value = x, weight = 10}, {value = y, weight = 5}, ...}
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

-- Format money with commas
function EventLibrary.formatMoney(amount)
	local formatted = tostring(math.floor(amount))
	local k
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then break end
	end
	return "$" .. formatted
end

-- ═══════════════════════════════════════════════════════════════
-- DEBUG / STATS
-- ═══════════════════════════════════════════════════════════════

function EventLibrary.getStats()
	return LifeEvents.getStats()
end

function EventLibrary.printStats()
	return LifeEvents.printStats()
end

function EventLibrary.debugEvent(event, state)
	return LifeEvents.EventEngine.debugEvent(event, state)
end

-- ═══════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════════

-- Print stats on load
local stats = LifeEvents.getStats()
print("═══════════════════════════════════════════════════════════")
print("🎮 GODLY EVENT LIBRARY LOADED")
print("═══════════════════════════════════════════════════════════")
print("📊 Total Events:", stats.totalEvents)
print("🌟 Milestones:", stats.milestones)
print("🔗 Chain Events:", stats.chainEvents)
print("💼 Careers Available:", #LifeEvents.CareerLibrary.getAllCareers())
print("═══════════════════════════════════════════════════════════")

return EventLibrary
