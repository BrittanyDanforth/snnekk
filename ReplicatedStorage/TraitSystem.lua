-- TraitSystem.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- AAA-Tier Trait Interaction System
-- Drives BitLife-scale personality arcs, stat modifiers, and event gating.
-- Drop this ModuleScript in ReplicatedStorage (sibling to LifeEvents).
-- ═══════════════════════════════════════════════════════════════════════════════

local TraitSystem = {}
TraitSystem.__index = TraitSystem

-- ###########################################################################
-- ## INTERNAL STATE ########################################################
-- ###########################################################################

local BASE_STATS = {
	Strength = 0,
	Stamina = 0,
	Intelligence = 0,
	Charisma = 0,
	Creativity = 0,
	Luck = 0,
	DrivingSkill = 0,
	TechSkill = 0,
	Fitness = 0,
	MentalHealth = 0,
	RiskAffinity = 0,
}

local TRAITS = {}
local INTERACTION_RULES = {}
local EVOLUTION_RULES = {}

local function shallowCopy(tbl)
	local copy = {}
	for key, value in pairs(tbl or {}) do
		copy[key] = value
	end
	return copy
end

local function ensurePlayerShape(playerData)
	playerData.Traits = playerData.Traits or {}
	playerData.Stats = playerData.Stats or shallowCopy(BASE_STATS)
	playerData.Flags = playerData.Flags or {}
	return playerData
end

local function traitExists(traitId)
	return TRAITS[traitId] ~= nil
end

local function traitListToSet(list)
	local set = {}
	for index, value in ipairs(list or {}) do
		set[value] = true
	end
	return set
end

local function addTraitIfMissing(traitList, traitId)
	for _, trait in ipairs(traitList) do
		if trait == traitId then
			return
		end
	end
	table.insert(traitList, traitId)
end

local function removeTraitFromList(traitList, traitId)
	for index = #traitList, 1, -1 do
		if traitList[index] == traitId then
			table.remove(traitList, index)
		end
	end
end

-- ###########################################################################
-- ## TRAIT REGISTRATION ####################################################
-- ###########################################################################

local function registerTrait(def)
	assert(def and def.id, "Trait definition requires id")
	TRAITS[def.id] = def
end

local function registerBaseTraits()
	-- ═══════════════════════════════════════════════════════════════
	-- TIER 1: CORE IDENTITY TRAITS
	-- ═══════════════════════════════════════════════════════════════
	
	-- Racer / motorsport core archetype
	registerTrait({
		id = "RACER",
		name = "Racer Imprint",
		desc = "Speed fixation since infancy; rewires how risk feels.",
		tags = {"motorsport", "identity"},
		tier = 1,
		modifiers = { DrivingSkill = 6, RiskAffinity = 2 },
		hidden = { speedIdentity = true },
	})

	registerTrait({
		id = "TECHYKID",
		name = "Digital Native",
		desc = "Screens shaped their cognition; hyper-focus on systems.",
		tags = {"tech", "focus"},
		tier = 1,
		modifiers = { TechSkill = 5, Intelligence = 2, MentalHealth = -1 },
		hidden = { screenDependencySeed = true },
	})

	registerTrait({
		id = "FATKID",
		name = "Comfort Eater",
		desc = "Food as shield + social anxiety from early bullying.",
		tags = {"health", "social"},
		tier = 1,
		modifiers = { Fitness = -6, Charisma = -1, MentalHealth = -2 },
		hidden = { bodyInsecuritySeed = true },
	})

	registerTrait({
		id = "BULLYVICTIM",
		name = "Internalized Bullying",
		desc = "Carries insults forever; fuels either rage or art.",
		tags = {"trauma", "social"},
		tier = 1,
		modifiers = { Charisma = -2, MentalHealth = -3 },
		hidden = {},
	})

	registerTrait({
		id = "GOODDRIVER",
		name = "Natural Driver",
		desc = "Instinctive car control; smooth inputs, perfect lines.",
		tags = {"motorsport", "skill"},
		tier = 1,
		modifiers = { DrivingSkill = 5, RiskAffinity = -1 },
	})

	registerTrait({
		id = "RECKLESS",
		name = "Reckless Driver",
		desc = "Pushes limits without fear; crashes are inevitable.",
		tags = {"motorsport", "risk"},
		tier = 1,
		modifiers = { RiskAffinity = 5, DrivingSkill = 2, MentalHealth = -2 },
	})

	registerTrait({
		id = "COMPETITIVE",
		name = "Competitive Spirit",
		desc = "Hates losing more than loves winning; drives excellence.",
		tags = {"motorsport", "personality"},
		tier = 1,
		modifiers = { DrivingSkill = 3, MentalHealth = -1 },
	})

	registerTrait({
		id = "FOCUSED",
		name = "Laser Focus",
		desc = "Single-minded dedication; distractions don't exist.",
		tags = {"motorsport", "mental"},
		tier = 1,
		modifiers = { Intelligence = 2, DrivingSkill = 2 },
	})

	-- ═══════════════════════════════════════════════════════════════
	-- TIER 2: DEVELOPED SKILLS & BEHAVIORS
	-- ═══════════════════════════════════════════════════════════════

	registerTrait({
		id = "THRILLSEEKER",
		name = "Adrenaline Directive",
		desc = "Needs chaos to feel alive; empathy dips when bored.",
		tags = {"risk"},
		tier = 2,
		modifiers = { RiskAffinity = 6, MentalHealth = -1 },
		prerequisites = {"RACER"},
	})

	registerTrait({
		id = "MECHANICAPPT",
		name = "Mechanical Savant",
		desc = "Understands torque, telemetry, and tolerances instinctively.",
		tags = {"engineering"},
		tier = 2,
		modifiers = { TechSkill = 3, DrivingSkill = 3, Intelligence = 1 },
		prerequisites = {"RACER", "TECHYKID"},
	})

	registerTrait({
		id = "ANXIOUS",
		name = "Trauma Flashbacks",
		desc = "Panic loops after every close call.",
		tags = {"mental"},
		tier = 2,
		modifiers = { RiskAffinity = -3, MentalHealth = -4 },
		prerequisites = {"BULLYVICTIM"},
	})

	registerTrait({
		id = "MEDIA_DARLING",
		name = "Media Darling",
		desc = "Knows how to weaponize charisma with cameras rolling.",
		tags = {"fame"},
		tier = 2,
		modifiers = { Charisma = 4, Luck = 2 },
	})

	registerTrait({
		id = "RAIN_MASTER",
		name = "Rain Master",
		desc = "Thrives in wet conditions; others crash, you excel.",
		tags = {"motorsport", "skill", "weather"},
		tier = 2,
		modifiers = { DrivingSkill = 4, Intelligence = 2 },
		prerequisites = {"GOODDRIVER"},
	})

	registerTrait({
		id = "OVERTAKE_SPECIALIST",
		name = "Overtaking Specialist",
		desc = "Makes impossible passes look easy; fearless wheel-to-wheel.",
		tags = {"motorsport", "skill"},
		tier = 2,
		modifiers = { DrivingSkill = 5, RiskAffinity = 2 },
		prerequisites = {"RACER", "COMPETITIVE"},
	})

	registerTrait({
		id = "QUALIFYING_BEAST",
		name = "Qualifying Beast",
		desc = "Extracts maximum pace in one lap; pole positions are routine.",
		tags = {"motorsport", "skill"},
		tier = 2,
		modifiers = { DrivingSkill = 4, Intelligence = 1 },
		prerequisites = {"FOCUSED"},
	})

	registerTrait({
		id = "RACE_CRAFTSMAN",
		name = "Race Craftsman",
		desc = "Perfect race management; tire conservation, fuel strategy.",
		tags = {"motorsport", "strategy"},
		tier = 2,
		modifiers = { Intelligence = 3, DrivingSkill = 2 },
		prerequisites = {"GOODDRIVER"},
	})

	registerTrait({
		id = "DEFENSIVE_MASTER",
		name = "Defensive Master",
		desc = "Impossible to pass; protects position with surgical precision.",
		tags = {"motorsport", "skill"},
		tier = 2,
		modifiers = { DrivingSkill = 4, Intelligence = 2 },
		prerequisites = {"GOODDRIVER", "FOCUSED"},
	})

	registerTrait({
		id = "STREET_RACER",
		name = "Street Racer",
		desc = "Illegal racing background; raw talent, no rules.",
		tags = {"motorsport", "illegal"},
		tier = 2,
		modifiers = { DrivingSkill = 4, RiskAffinity = 4, Karma = -2 },
		prerequisites = {"RACER", "THRILLSEEKER"},
	})

	registerTrait({
		id = "KARTING_PRODIGY",
		name = "Karting Prodigy",
		desc = "Dominant in karts; foundation for greatness.",
		tags = {"motorsport", "karting"},
		tier = 2,
		modifiers = { DrivingSkill = 5, Fame = 2 },
		prerequisites = {"RACER"},
	})

	registerTrait({
		id = "ENGINE_WHISPERER",
		name = "Engine Whisperer",
		desc = "Intuitive understanding of power units; feels problems before they happen.",
		tags = {"motorsport", "engineering"},
		tier = 2,
		modifiers = { TechSkill = 5, Intelligence = 2 },
		prerequisites = {"MECHANICAPPT"},
	})

	registerTrait({
		id = "SETUP_GENIUS",
		name = "Setup Genius",
		desc = "Perfect car setup every time; engineers trust your feedback.",
		tags = {"motorsport", "engineering"},
		tier = 2,
		modifiers = { TechSkill = 4, Intelligence = 3 },
		prerequisites = {"MECHANICAPPT", "GOODDRIVER"},
	})

	registerTrait({
		id = "TEAM_PLAYER",
		name = "Team Player",
		desc = "Puts team success first; respected by mechanics and engineers.",
		tags = {"motorsport", "social"},
		tier = 2,
		modifiers = { Charisma = 3, MentalHealth = 2 },
		prerequisites = {"RACER"},
	})

	registerTrait({
		id = "PRIMA_DONNA",
		name = "Prima Donna",
		desc = "Demanding perfection; team tensions rise but results come.",
		tags = {"motorsport", "personality"},
		tier = 2,
		modifiers = { Charisma = -2, DrivingSkill = 2, MentalHealth = -1 },
		prerequisites = {"COMPETITIVE"},
	})

	registerTrait({
		id = "CRASH_PRONE",
		name = "Crash Prone",
		desc = "Pushes too hard; crashes are frequent but recoverable.",
		tags = {"motorsport", "risk"},
		tier = 2,
		modifiers = { RiskAffinity = 4, MentalHealth = -3 },
		prerequisites = {"RECKLESS", "THRILLSEEKER"},
	})

	registerTrait({
		id = "CONSISTENT_FINISHER",
		name = "Consistent Finisher",
		desc = "Always brings car home; points over glory.",
		tags = {"motorsport", "strategy"},
		tier = 2,
		modifiers = { Intelligence = 2, DrivingSkill = 2 },
		prerequisites = {"GOODDRIVER", "FOCUSED"},
	})

	registerTrait({
		id = "GLORY_HUNTER",
		name = "Glory Hunter",
		desc = "Wins or crashes; no middle ground.",
		tags = {"motorsport", "personality"},
		tier = 2,
		modifiers = { DrivingSkill = 3, RiskAffinity = 3, MentalHealth = -2 },
		prerequisites = {"THRILLSEEKER", "COMPETITIVE"},
	})

	registerTrait({
		id = "PHYSICAL_BEAST",
		name = "Physical Beast",
		desc = "Peak physical condition; G-forces don't affect performance.",
		tags = {"motorsport", "fitness"},
		tier = 2,
		modifiers = { Fitness = 5, Stamina = 4, Health = 3 },
		prerequisites = {"RACER"},
	})

	registerTrait({
		id = "MENTAL_FORTITUDE",
		name = "Mental Fortitude",
		desc = "Unbreakable focus under pressure; clutch performances.",
		tags = {"motorsport", "mental"},
		tier = 2,
		modifiers = { Intelligence = 2, MentalHealth = 4 },
		prerequisites = {"FOCUSED"},
	})

	-- ═══════════════════════════════════════════════════════════════
	-- TIER 3: ADVANCED & SPECIALIZED TRAITS
	-- ═══════════════════════════════════════════════════════════════

	registerTrait({
		id = "MENTOR_DRIVER",
		name = "Mentorship Core",
		desc = "Channels obsession into teaching; boosts team morale.",
		tags = {"leadership"},
		tier = 3,
		modifiers = { Charisma = 3, MentalHealth = 2 },
		prerequisites = {"RACER"},
	})

	registerTrait({
		id = "DATA_STRATEGIST",
		name = "Telemetry Strategist",
		desc = "Reads race data like poetry; anticipates chaos.",
		tags = {"analytics"},
		tier = 3,
		modifiers = { Intelligence = 4, TechSkill = 4 },
		prerequisites = {"MECHANICAPPT"},
	})

	registerTrait({
		id = "F1_READY",
		name = "F1 Ready",
		desc = "Proven in junior categories; ready for Formula 1.",
		tags = {"motorsport", "f1"},
		tier = 3,
		modifiers = { DrivingSkill = 6, Fame = 5 },
		prerequisites = {"KARTING_PRODIGY", "GOODDRIVER"},
	})

	registerTrait({
		id = "ENDURANCE_SPECIALIST",
		name = "Endurance Specialist",
		desc = "Thrives in long races; triple stints are routine.",
		tags = {"motorsport", "endurance"},
		tier = 3,
		modifiers = { Stamina = 5, MentalHealth = 3, DrivingSkill = 3 },
		prerequisites = {"PHYSICAL_BEAST", "MENTAL_FORTITUDE"},
	})

	registerTrait({
		id = "WET_WEATHER_MASTER",
		name = "Wet Weather Master",
		desc = "Untouchable in rain; others crash, you win.",
		tags = {"motorsport", "weather"},
		tier = 3,
		modifiers = { DrivingSkill = 6, Intelligence = 3 },
		prerequisites = {"RAIN_MASTER", "GOODDRIVER"},
	})

	registerTrait({
		id = "OVERTAKE_LEGEND",
		name = "Overtaking Legend",
		desc = "Makes impossible passes routine; highlight reels are endless.",
		tags = {"motorsport", "skill"},
		tier = 3,
		modifiers = { DrivingSkill = 6, Fame = 4 },
		prerequisites = {"OVERTAKE_SPECIALIST", "THRILLSEEKER"},
	})

	registerTrait({
		id = "POLE_POSITION_KING",
		name = "Pole Position King",
		desc = "Qualifying dominance; starts from front row constantly.",
		tags = {"motorsport", "qualifying"},
		tier = 3,
		modifiers = { DrivingSkill = 5, Fame = 3 },
		prerequisites = {"QUALIFYING_BEAST", "FOCUSED"},
	})

	registerTrait({
		id = "RACE_WINNER",
		name = "Race Winner",
		desc = "Knows how to win; converts opportunities into victories.",
		tags = {"motorsport", "victory"},
		tier = 3,
		modifiers = { DrivingSkill = 5, Fame = 4, MentalHealth = 2 },
		prerequisites = {"GOODDRIVER", "COMPETITIVE"},
	})

	registerTrait({
		id = "CHAMPIONSHIP_CONTENDER",
		name = "Championship Contender",
		desc = "Consistent title challenges; always in the fight.",
		tags = {"motorsport", "championship"},
		tier = 3,
		modifiers = { DrivingSkill = 5, Intelligence = 3, Fame = 5 },
		prerequisites = {"CONSISTENT_FINISHER", "RACE_WINNER"},
	})

	registerTrait({
		id = "WORLD_CHAMPION",
		name = "World Champion",
		desc = "Achieved the ultimate; immortalized in racing history.",
		tags = {"motorsport", "championship", "legend"},
		tier = 3,
		modifiers = { DrivingSkill = 7, Fame = 10, MentalHealth = 3 },
		prerequisites = {"CHAMPIONSHIP_CONTENDER"},
	})

	registerTrait({
		id = "FACTORY_DRIVER",
		name = "Factory Driver",
		desc = "Signed to factory team; top-tier equipment and support.",
		tags = {"motorsport", "factory"},
		tier = 3,
		modifiers = { Fame = 6, Luck = 3 },
		prerequisites = {"F1_READY", "GOODDRIVER"},
	})

	registerTrait({
		id = "TEST_DRIVER",
		name = "Test Driver",
		desc = "Development specialist; perfects cars for race drivers.",
		tags = {"motorsport", "testing"},
		tier = 3,
		modifiers = { TechSkill = 5, Intelligence = 4 },
		prerequisites = {"SETUP_GENIUS", "GOODDRIVER"},
	})

	registerTrait({
		id = "SIM_RACING_PRO",
		name = "Sim Racing Pro",
		desc = "Dominant in simulators; skills transfer to real racing.",
		tags = {"motorsport", "simulation"},
		tier = 3,
		modifiers = { TechSkill = 4, Intelligence = 3, DrivingSkill = 2 },
		prerequisites = {"TECHYKID", "GOODDRIVER"},
	})

	registerTrait({
		id = "DRIFT_KING",
		name = "Drift King",
		desc = "Master of sideways; street racing legend.",
		tags = {"motorsport", "drifting", "street"},
		tier = 3,
		modifiers = { DrivingSkill = 5, Fame = 4, RiskAffinity = 3 },
		prerequisites = {"STREET_RACER", "THRILLSEEKER"},
	})

	registerTrait({
		id = "UNDERGROUND_LEGEND",
		name = "Underground Legend",
		desc = "Respected in illegal racing scene; name is whispered.",
		tags = {"motorsport", "street", "illegal"},
		tier = 3,
		modifiers = { Fame = 5, RiskAffinity = 4, Karma = -3 },
		prerequisites = {"STREET_RACER", "DRIFT_KING"},
	})

	registerTrait({
		id = "LEGAL_TRANSITION",
		name = "Legal Transition",
		desc = "Moved from street to track; kept the style, gained respect.",
		tags = {"motorsport", "transition"},
		tier = 3,
		modifiers = { Fame = 4, Karma = 2, DrivingSkill = 3 },
		prerequisites = {"UNDERGROUND_LEGEND", "GOODDRIVER"},
	})

	registerTrait({
		id = "MASTER_MECHANIC",
		name = "Master Mechanic",
		desc = "Elite-level mechanic; teams fight for your services.",
		tags = {"motorsport", "mechanic"},
		tier = 3,
		modifiers = { TechSkill = 6, Intelligence = 4, Fame = 3 },
		prerequisites = {"ENGINE_WHISPERER", "SETUP_GENIUS"},
	})

	registerTrait({
		id = "TEAM_OWNER",
		name = "Team Owner",
		desc = "Built own racing team; business and racing combined.",
		tags = {"motorsport", "business"},
		tier = 3,
		modifiers = { Charisma = 4, Intelligence = 3, Fame = 5 },
		prerequisites = {"MASTER_MECHANIC", "MENTOR_DRIVER"},
	})

	registerTrait({
		id = "ACADEMY_FOUNDER",
		name = "Academy Founder",
		desc = "Created driver academy; trains next generation.",
		tags = {"motorsport", "education"},
		tier = 3,
		modifiers = { Charisma = 5, MentalHealth = 4, Karma = 5 },
		prerequisites = {"MENTOR_DRIVER", "WORLD_CHAMPION"},
	})

	registerTrait({
		id = "HALL_OF_FAME",
		name = "Hall of Fame",
		desc = "Inducted into Motorsport Hall of Fame; immortality achieved.",
		tags = {"motorsport", "legend"},
		tier = 3,
		modifiers = { Fame = 15, MentalHealth = 5, Karma = 5 },
		prerequisites = {"WORLD_CHAMPION"},
	})

	registerTrait({
		id = "CRASH_SURVIVOR",
		name = "Crash Survivor",
		desc = "Survived major crash; trauma reshaped perspective.",
		tags = {"motorsport", "trauma"},
		tier = 3,
		modifiers = { MentalHealth = -5, RiskAffinity = -2, Intelligence = 2 },
		prerequisites = {"CRASH_PRONE"},
	})

	registerTrait({
		id = "FEARLESS",
		name = "Fearless",
		desc = "No fear after crash; trauma became strength.",
		tags = {"motorsport", "mental"},
		tier = 3,
		modifiers = { RiskAffinity = 5, MentalHealth = 2, DrivingSkill = 2 },
		prerequisites = {"CRASH_SURVIVOR", "THRILLSEEKER"},
	})

	registerTrait({
		id = "RETIRED_CHAMPION",
		name = "Retired Champion",
		desc = "Retired on top; legacy secured forever.",
		tags = {"motorsport", "retirement"},
		tier = 3,
		modifiers = { Fame = 8, MentalHealth = 5, Happiness = 5 },
		prerequisites = {"WORLD_CHAMPION"},
	})

	-- ═══════════════════════════════════════════════════════════════
	-- ADDITIONAL SPECIALIZED TRAITS (100+ total)
	-- ═══════════════════════════════════════════════════════════════

	-- Karting Traits
	registerTrait({
		id = "KARTING_CHAMPION",
		name = "Karting Champion",
		desc = "Won national karting championship; foundation for greatness.",
		tags = {"motorsport", "karting"},
		tier = 2,
		modifiers = { DrivingSkill = 4, Fame = 3 },
		prerequisites = {"KARTING_PRODIGY"},
	})

	registerTrait({
		id = "INTERNATIONAL_KART_CHAMP",
		name = "International Kart Champ",
		desc = "Won international karting championship; world noticed.",
		tags = {"motorsport", "karting"},
		tier = 3,
		modifiers = { DrivingSkill = 5, Fame = 5 },
		prerequisites = {"KARTING_CHAMPION"},
	})

	-- Formula Traits
	registerTrait({
		id = "F4_CHAMPION",
		name = "F4 Champion",
		desc = "Won Formula 4 championship; junior formula success.",
		tags = {"motorsport", "formula"},
		tier = 2,
		modifiers = { DrivingSkill = 4, Fame = 3 },
		prerequisites = {"KARTING_PRODIGY"},
	})

	registerTrait({
		id = "F3_CHAMPION",
		name = "F3 Champion",
		desc = "Won Formula 3 championship; F1 path secured.",
		tags = {"motorsport", "formula"},
		tier = 3,
		modifiers = { DrivingSkill = 5, Fame = 5 },
		prerequisites = {"F4_CHAMPION"},
	})

	registerTrait({
		id = "F2_CHAMPION",
		name = "F2 Champion",
		desc = "Won Formula 2 championship; F1 is next.",
		tags = {"motorsport", "formula"},
		tier = 3,
		modifiers = { DrivingSkill = 6, Fame = 7 },
		prerequisites = {"F3_CHAMPION"},
	})

	registerTrait({
		id = "F1_ROOKIE",
		name = "F1 Rookie",
		desc = "Formula 1 debut; living the dream.",
		tags = {"motorsport", "f1"},
		tier = 3,
		modifiers = { Fame = 8, MentalHealth = 2 },
		prerequisites = {"F2_CHAMPION"},
	})

	registerTrait({
		id = "F1_WINNER",
		name = "F1 Winner",
		desc = "Won Formula 1 Grand Prix; elite achievement.",
		tags = {"motorsport", "f1"},
		tier = 3,
		modifiers = { DrivingSkill = 6, Fame = 10, MentalHealth = 3 },
		prerequisites = {"F1_ROOKIE"},
	})

	registerTrait({
		id = "F1_CHAMPION",
		name = "F1 World Champion",
		desc = "Won Formula 1 World Championship; pinnacle achieved.",
		tags = {"motorsport", "f1", "legend"},
		tier = 3,
		modifiers = { DrivingSkill = 8, Fame = 15, MentalHealth = 5 },
		prerequisites = {"F1_WINNER", "CHAMPIONSHIP_CONTENDER"},
	})

	-- Endurance Traits
	registerTrait({
		id = "LE_MANS_WINNER",
		name = "Le Mans Winner",
		desc = "Won 24 Hours of Le Mans; endurance racing legend.",
		tags = {"motorsport", "endurance", "lemans"},
		tier = 3,
		modifiers = { DrivingSkill = 6, Fame = 8, Stamina = 5 },
		prerequisites = {"ENDURANCE_SPECIALIST"},
	})

	registerTrait({
		id = "DAYTONA_WINNER",
		name = "Daytona Winner",
		desc = "Won 24 Hours of Daytona; American endurance legend.",
		tags = {"motorsport", "endurance", "daytona"},
		tier = 3,
		modifiers = { DrivingSkill = 5, Fame = 7, Stamina = 4 },
		prerequisites = {"ENDURANCE_SPECIALIST"},
	})

	-- Street Racing Traits
	registerTrait({
		id = "STREET_TAKEOVER_KING",
		name = "Street Takeover King",
		desc = "Dominates street takeovers; underground legend.",
		tags = {"motorsport", "street", "illegal"},
		tier = 2,
		modifiers = { Fame = 4, RiskAffinity = 5, Karma = -2 },
		prerequisites = {"STREET_RACER"},
	})

	registerTrait({
		id = "COP_CHASE_SURVIVOR",
		name = "Cop Chase Survivor",
		desc = "Escaped high-speed police chases; legend grows.",
		tags = {"motorsport", "street", "illegal"},
		tier = 2,
		modifiers = { Fame = 3, RiskAffinity = 3, Karma = -3 },
		prerequisites = {"STREET_RACER"},
	})

	-- Vehicle Traits
	registerTrait({
		id = "CAR_COLLECTOR",
		name = "Car Collector",
		desc = "Owns impressive car collection; garage is a museum.",
		tags = {"motorsport", "vehicle"},
		tier = 2,
		modifiers = { Fame = 3, Happiness = 4 },
		prerequisites = {"RACER"},
	})

	registerTrait({
		id = "SUPERCAR_OWNER",
		name = "Supercar Owner",
		desc = "Owns multiple supercars; living the dream.",
		tags = {"motorsport", "vehicle"},
		tier = 2,
		modifiers = { Fame = 4, Happiness = 5 },
		prerequisites = {"CAR_COLLECTOR"},
	})

	registerTrait({
		id = "TRACK_CAR_OWNER",
		name = "Track Car Owner",
		desc = "Dedicated track car; pure performance focus.",
		tags = {"motorsport", "vehicle"},
		tier = 2,
		modifiers = { DrivingSkill = 2, Happiness = 3 },
		prerequisites = {"RACER"},
	})

	-- Media & Fame Traits
	registerTrait({
		id = "VIRAL_SENSATION",
		name = "Viral Sensation",
		desc = "Racing videos go viral; millions of views.",
		tags = {"motorsport", "media", "fame"},
		tier = 2,
		modifiers = { Fame = 6, Charisma = 2 },
		prerequisites = {"MEDIA_DARLING"},
	})

	registerTrait({
		id = "BRAND_AMBASSADOR",
		name = "Brand Ambassador",
		desc = "Major brand sponsorship; face of motorsport.",
		tags = {"motorsport", "media", "fame"},
		tier = 3,
		modifiers = { Fame = 8, Charisma = 4, Luck = 3 },
		prerequisites = {"MEDIA_DARLING", "F1_READY"},
	})

	registerTrait({
		id = "DOCUMENTARY_STAR",
		name = "Documentary Star",
		desc = "Featured in racing documentaries; story told worldwide.",
		tags = {"motorsport", "media", "fame"},
		tier = 3,
		modifiers = { Fame = 7, Charisma = 3 },
		prerequisites = {"WORLD_CHAMPION", "MEDIA_DARLING"},
	})

	-- Mental & Physical Traits
	registerTrait({
		id = "BURNOUT",
		name = "Burnout",
		desc = "Racing exhaustion; needs break from competition.",
		tags = {"motorsport", "mental"},
		tier = 2,
		modifiers = { MentalHealth = -6, DrivingSkill = -2 },
		prerequisites = {"COMPETITIVE"},
	})

	registerTrait({
		id = "RACING_OBSESSED",
		name = "Racing Obsessed",
		desc = "Can't stop thinking about racing; all-consuming passion.",
		tags = {"motorsport", "mental"},
		tier = 2,
		modifiers = { DrivingSkill = 3, MentalHealth = -2 },
		prerequisites = {"RACER", "FOCUSED"},
	})

	registerTrait({
		id = "INJURY_RECOVERY",
		name = "Injury Recovery",
		desc = "Recovering from racing injury; building back strength.",
		tags = {"motorsport", "health"},
		tier = 2,
		modifiers = { Health = -5, Fitness = -3, MentalHealth = -2 },
		prerequisites = {"CRASH_PRONE"},
	})

	registerTrait({
		id = "FULLY_RECOVERED",
		name = "Fully Recovered",
		desc = "Recovered from injury; stronger than before.",
		tags = {"motorsport", "health"},
		tier = 3,
		modifiers = { Health = 5, Fitness = 4, MentalHealth = 3 },
		prerequisites = {"INJURY_RECOVERY", "PHYSICAL_BEAST"},
	})

	-- Social Traits
	registerTrait({
		id = "RIVALRY_INTENSE",
		name = "Intense Rivalry",
		desc = "Fierce rivalry with another driver; pushes both to limits.",
		tags = {"motorsport", "social"},
		tier = 2,
		modifiers = { DrivingSkill = 2, MentalHealth = -1 },
		prerequisites = {"COMPETITIVE"},
	})

	registerTrait({
		id = "FAN_FAVORITE",
		name = "Fan Favorite",
		desc = "Beloved by fans; massive following worldwide.",
		tags = {"motorsport", "social", "fame"},
		tier = 2,
		modifiers = { Fame = 5, Charisma = 3, MentalHealth = 2 },
		prerequisites = {"MEDIA_DARLING"},
	})

	registerTrait({
		id = "CONTROVERSIAL",
		name = "Controversial",
		desc = "Polarizing figure; loved by some, hated by others.",
		tags = {"motorsport", "social"},
		tier = 2,
		modifiers = { Fame = 4, Charisma = -1, MentalHealth = -2 },
		prerequisites = {"PRIMA_DONNA"},
	})

	-- Business Traits
	registerTrait({
		id = "SPONSOR_MAGNET",
		name = "Sponsor Magnet",
		desc = "Attracts major sponsors; financial security guaranteed.",
		tags = {"motorsport", "business"},
		tier = 2,
		modifiers = { Charisma = 4, Luck = 3 },
		prerequisites = {"MEDIA_DARLING"},
	})

	registerTrait({
		id = "BUSINESS_MOGUL",
		name = "Business Mogul",
		desc = "Built racing empire; multiple revenue streams.",
		tags = {"motorsport", "business"},
		tier = 3,
		modifiers = { Intelligence = 4, Charisma = 5, Fame = 6 },
		prerequisites = {"TEAM_OWNER", "SPONSOR_MAGNET"},
	})

	-- Legacy Traits
	registerTrait({
		id = "RACING_LEGEND",
		name = "Racing Legend",
		desc = "Immortalized in racing history; name lives forever.",
		tags = {"motorsport", "legend"},
		tier = 3,
		modifiers = { Fame = 12, MentalHealth = 4, Karma = 3 },
		prerequisites = {"WORLD_CHAMPION", "HALL_OF_FAME"},
	})

	registerTrait({
		id = "GENERATION_INFLUENCER",
		name = "Generation Influencer",
		desc = "Inspired entire generation; changed the sport forever.",
		tags = {"motorsport", "legend"},
		tier = 3,
		modifiers = { Fame = 10, Charisma = 5, Karma = 5 },
		prerequisites = {"ACADEMY_FOUNDER", "MENTOR_DRIVER"},
	})

	-- Negative Traits
	registerTrait({
		id = "ADDICTED_RACING",
		name = "Racing Addict",
		desc = "Can't stop racing; life revolves around competition.",
		tags = {"motorsport", "negative"},
		tier = 2,
		modifiers = { DrivingSkill = 2, MentalHealth = -4, RiskAffinity = 3 },
		prerequisites = {"RACING_OBSESSED", "THRILLSEEKER"},
	})

	registerTrait({
		id = "WASHED_UP",
		name = "Washed Up",
		desc = "Past prime; skills declining but can't let go.",
		tags = {"motorsport", "negative"},
		tier = 3,
		modifiers = { DrivingSkill = -3, MentalHealth = -5, Fame = -2 },
		prerequisites = {"RETIRED_CHAMPION"},
	})

	registerTrait({
		id = "BANNED_RACER",
		name = "Banned Racer",
		desc = "Banned from racing; illegal activities caught up.",
		tags = {"motorsport", "negative", "illegal"},
		tier = 2,
		modifiers = { Fame = -5, Karma = -5, MentalHealth = -4 },
		prerequisites = {"UNDERGROUND_LEGEND", "STREET_TAKEOVER_KING"},
	})
end

local function registerBaseInteractions()
	-- Core Racer Interactions
	table.insert(INTERACTION_RULES, {
		require = {"RACER", "THRILLSEEKER"},
		priority = 100,
		effect = function(state)
			return {
				statDelta = { Luck = -2, RiskAffinity = 2 },
				notes = "Thrill-seeking racer invites chaos.",
			}
		end,
	})

	table.insert(INTERACTION_RULES, {
		require = {"FATKID", "BULLYVICTIM"},
		priority = 90,
		effect = function()
			return {
				statDelta = { MentalHealth = -3, Charisma = -1 },
				notes = "Body shaming trauma compounds insecurity.",
			}
		end,
	})

	table.insert(INTERACTION_RULES, {
		require = {"RACER", "TECHYKID"},
		priority = 80,
		effect = function(state)
			if math.random() < 0.35 then
				return {
					addTraits = {"MECHANICAPPT"},
					notes = "Systems brain merges with speed obsession → Mechanical Aptitude unlocked.",
				}
			end
		end,
	})

	-- Motorsport Skill Interactions
	table.insert(INTERACTION_RULES, {
		require = {"GOODDRIVER", "RAIN_MASTER"},
		priority = 85,
		effect = function()
			return {
				addTraits = {"WET_WEATHER_MASTER"},
				statDelta = { DrivingSkill = 2 },
				notes = "Natural talent + rain experience → Wet Weather Master.",
			}
		end,
	})

	table.insert(INTERACTION_RULES, {
		require = {"OVERTAKE_SPECIALIST", "THRILLSEEKER"},
		priority = 75,
		effect = function()
			if math.random() < 0.4 then
				return {
					addTraits = {"OVERTAKE_LEGEND"},
					statDelta = { DrivingSkill = 1, Fame = 2 },
					notes = "Fearless overtaking + thrill-seeking → Overtaking Legend.",
				}
			end
		end,
	})

	table.insert(INTERACTION_RULES, {
		require = {"QUALIFYING_BEAST", "FOCUSED"},
		priority = 70,
		effect = function()
			if math.random() < 0.3 then
				return {
					addTraits = {"POLE_POSITION_KING"},
					statDelta = { DrivingSkill = 1, Fame = 1 },
					notes = "Qualifying dominance + focus → Pole Position King.",
				}
			end
		end,
	})

	table.insert(INTERACTION_RULES, {
		require = {"KARTING_PRODIGY", "GOODDRIVER"},
		priority = 65,
		effect = function()
			if math.random() < 0.25 then
				return {
					addTraits = {"F1_READY"},
					statDelta = { DrivingSkill = 1, Fame = 2 },
					notes = "Karting success + natural talent → F1 Ready.",
				}
			end
		end,
	})

	-- Championship Progression
	table.insert(INTERACTION_RULES, {
		require = {"CONSISTENT_FINISHER", "RACE_WINNER"},
		priority = 60,
		effect = function()
			if math.random() < 0.3 then
				return {
					addTraits = {"CHAMPIONSHIP_CONTENDER"},
					statDelta = { Intelligence = 1, Fame = 2 },
					notes = "Consistency + wins → Championship Contender.",
				}
			end
		end,
	})

	table.insert(INTERACTION_RULES, {
		require = {"CHAMPIONSHIP_CONTENDER", "F1_WINNER"},
		priority = 55,
		effect = function()
			if math.random() < 0.2 then
				return {
					addTraits = {"F1_CHAMPION"},
					statDelta = { DrivingSkill = 2, Fame = 5 },
					notes = "Championship contention + F1 wins → F1 World Champion.",
				}
			end
		end,
	})

	-- Street Racing Interactions
	table.insert(INTERACTION_RULES, {
		require = {"STREET_RACER", "THRILLSEEKER"},
		priority = 50,
		effect = function()
			if math.random() < 0.35 then
				return {
					addTraits = {"DRIFT_KING"},
					statDelta = { DrivingSkill = 1, Fame = 2 },
					notes = "Street racing + thrill-seeking → Drift King.",
				}
			end
		end,
	})

	table.insert(INTERACTION_RULES, {
		require = {"DRIFT_KING", "STREET_TAKEOVER_KING"},
		priority = 45,
		effect = function()
			if math.random() < 0.3 then
				return {
					addTraits = {"UNDERGROUND_LEGEND"},
					statDelta = { Fame = 1, RiskAffinity = 1 },
					notes = "Drift mastery + takeover dominance → Underground Legend.",
				}
			end
		end,
	})

	-- Mechanic Interactions
	table.insert(INTERACTION_RULES, {
		require = {"ENGINE_WHISPERER", "SETUP_GENIUS"},
		priority = 40,
		effect = function()
			if math.random() < 0.4 then
				return {
					addTraits = {"MASTER_MECHANIC"},
					statDelta = { TechSkill = 1, Intelligence = 1 },
					notes = "Engine mastery + setup genius → Master Mechanic.",
				}
			end
		end,
	})

	table.insert(INTERACTION_RULES, {
		require = {"MASTER_MECHANIC", "MENTOR_DRIVER"},
		priority = 35,
		effect = function()
			if math.random() < 0.25 then
				return {
					addTraits = {"TEAM_OWNER"},
					statDelta = { Charisma = 1, Intelligence = 1 },
					notes = "Mechanic mastery + mentorship → Team Owner.",
				}
			end
		end,
	})

	-- Crash & Recovery Interactions
	table.insert(INTERACTION_RULES, {
		require = {"CRASH_PRONE", "ANXIOUS"},
		priority = 30,
		effect = function()
			if math.random() < 0.5 then
				return {
					addTraits = {"CRASH_SURVIVOR"},
					statDelta = { MentalHealth = -2, RiskAffinity = -1 },
					notes = "Frequent crashes + anxiety → Crash Survivor trauma.",
				}
			end
		end,
	})

	table.insert(INTERACTION_RULES, {
		require = {"CRASH_SURVIVOR", "THRILLSEEKER"},
		priority = 25,
		effect = function()
			if math.random() < 0.4 then
				return {
					addTraits = {"FEARLESS"},
					statDelta = { RiskAffinity = 2, MentalHealth = 1 },
					notes = "Crash survival + thrill-seeking → Fearless recovery.",
				}
			end
		end,
	})

	-- Media & Fame Interactions
	table.insert(INTERACTION_RULES, {
		require = {"MEDIA_DARLING", "F1_READY"},
		priority = 20,
		effect = function()
			if math.random() < 0.3 then
				return {
					addTraits = {"BRAND_AMBASSADOR"},
					statDelta = { Fame = 2, Charisma = 1 },
					notes = "Media presence + F1 readiness → Brand Ambassador.",
				}
			end
		end,
	})

	table.insert(INTERACTION_RULES, {
		require = {"WORLD_CHAMPION", "MEDIA_DARLING"},
		priority = 15,
		effect = function()
			if math.random() < 0.4 then
				return {
					addTraits = {"DOCUMENTARY_STAR"},
					statDelta = { Fame = 2, Charisma = 1 },
					notes = "World champion + media darling → Documentary Star.",
				}
			end
		end,
	})

	-- Legacy Interactions
	table.insert(INTERACTION_RULES, {
		require = {"WORLD_CHAMPION", "HALL_OF_FAME"},
		priority = 10,
		effect = function()
			return {
				addTraits = {"RACING_LEGEND"},
				statDelta = { Fame = 2, MentalHealth = 1 },
				notes = "World champion + Hall of Fame → Racing Legend.",
			}
		end,
	})

	table.insert(INTERACTION_RULES, {
		require = {"ACADEMY_FOUNDER", "MENTOR_DRIVER"},
		priority = 5,
		effect = function()
			if math.random() < 0.5 then
				return {
					addTraits = {"GENERATION_INFLUENCER"},
					statDelta = { Charisma = 1, Karma = 2 },
					notes = "Academy founder + mentorship → Generation Influencer.",
				}
			end
		end,
	})
end

local function registerBaseEvolutionRules()
	table.insert(EVOLUTION_RULES, {
		id = "CRASH_TRAUMA_EVOLVE",
		triggerTags = {"vehicle_crash", "high_impact"},
		condition = function(_, outcome)
			return outcome and (outcome.severity or 0) >= 7
		end,
		effect = function(playerData)
			local mentalHealth = (playerData.Stats and playerData.Stats.MentalHealth) or 0
			local traumaChance = mentalHealth > 2 and 0.45 or 0.7
			if math.random() < traumaChance then
				return {
					addTraits = {"ANXIOUS"},
					statDelta = { MentalHealth = -4 },
					notes = "Crash locked in anxiety pathway.",
				}
			else
				return {
					addTraits = {"THRILLSEEKER"},
					statDelta = { RiskAffinity = 3 },
					notes = "Crash rewired fear into adrenaline hunger.",
				}
			end
		end,
	})

	table.insert(EVOLUTION_RULES, {
		id = "DEFENSE_HEALS",
		triggerTags = {"bully", "defended"},
		condition = function(_, outcome)
			return outcome and outcome.defendedByFriend
		end,
		effect = function()
			return {
				removeTraits = {"BULLYVICTIM"},
				statDelta = { Charisma = 2, MentalHealth = 2 },
				notes = "Defense rewires self-worth; bully victim flag cleared.",
			}
		end,
	})
end

-- ###########################################################################
-- ## PUBLIC INITIALIZER ####################################################
-- ###########################################################################

function TraitSystem.Init()
	for key in pairs(TRAITS) do
		TRAITS[key] = nil
	end
	for key in pairs(INTERACTION_RULES) do
		INTERACTION_RULES[key] = nil
	end
	for key in pairs(EVOLUTION_RULES) do
		EVOLUTION_RULES[key] = nil
	end
	registerBaseTraits()
	registerBaseInteractions()
	registerBaseEvolutionRules()
end

-- ###########################################################################
-- ## CORE API ##############################################################
-- ###########################################################################

function TraitSystem.HasTrait(playerData, traitId)
	playerData = ensurePlayerShape(playerData)
	for _, trait in ipairs(playerData.Traits) do
		if trait == traitId then
			return true
		end
	end
	return false
end

function TraitSystem.AddTrait(playerData, traitId)
	playerData = ensurePlayerShape(playerData)
	if not traitExists(traitId) then
		return { success = false, reason = "unknown_trait" }
	end

	local def = TRAITS[traitId]
	local existing = traitListToSet(playerData.Traits)

	-- prerequisites
	for _, prereq in ipairs(def.prerequisites or {}) do
		if not existing[prereq] then
			TraitSystem.AddTrait(playerData, prereq)
		end
	end

	-- incompatible cleanup
	for _, incompatible in ipairs(def.incompatible or {}) do
		if existing[incompatible] then
			removeTraitFromList(playerData.Traits, incompatible)
		end
	end

	addTraitIfMissing(playerData.Traits, traitId)
	return { success = true }
end

function TraitSystem.RemoveTrait(playerData, traitId)
	playerData = ensurePlayerShape(playerData)
	removeTraitFromList(playerData.Traits, traitId)
	return { success = true }
end

function TraitSystem.ResolveTraits(playerData)
	playerData = ensurePlayerShape(playerData)
	local applied = {}
	local statDelta = {}
	local narrative = {}

	table.sort(INTERACTION_RULES, function(a, b)
		return (a.priority or 0) > (b.priority or 0)
	end)

	for _, rule in ipairs(INTERACTION_RULES) do
		local has = traitListToSet(playerData.Traits)
		local valid = true
		for _, required in ipairs(rule.require or {}) do
			if not has[required] then
				valid = false
				break
			end
		end
		if valid then
			local response = rule.effect(playerData) or {}
			for _, addId in ipairs(response.addTraits or {}) do
				TraitSystem.AddTrait(playerData, addId)
				table.insert(applied, { type = "add", trait = addId, rule = rule })
			end
			for _, removeId in ipairs(response.removeTraits or {}) do
				TraitSystem.RemoveTrait(playerData, removeId)
				table.insert(applied, { type = "remove", trait = removeId, rule = rule })
			end
			for stat, delta in pairs(response.statDelta or {}) do
				playerData.Stats[stat] = (playerData.Stats[stat] or 0) + delta
				statDelta[stat] = (statDelta[stat] or 0) + delta
			end
			if response.notes then
				table.insert(narrative, response.notes)
			end
		end
	end

	return { applied = applied, statDelta = statDelta, narrative = narrative }
end

function TraitSystem.ComputeStatsWithTraits(playerData)
	playerData = ensurePlayerShape(playerData)
	local computed = shallowCopy(playerData.Stats)
	for _, traitId in ipairs(playerData.Traits) do
		local def = TRAITS[traitId]
		if def and def.modifiers then
			for stat, delta in pairs(def.modifiers) do
				computed[stat] = (computed[stat] or 0) + delta
			end
		end
	end
	return computed
end

function TraitSystem.ApplyTraitModifiers(playerData)
	playerData = ensurePlayerShape(playerData)
	playerData.Stats = TraitSystem.ComputeStatsWithTraits(playerData)
	return playerData.Stats
end

function TraitSystem.HandleEventOutcome(playerData, outcome)
	playerData = ensurePlayerShape(playerData)
	local applied = {}
	local statDelta = {}
	local narrative = {}

	for _, rule in ipairs(EVOLUTION_RULES) do
		local triggered = false
		if outcome and outcome.tags then
			for _, tag in ipairs(outcome.tags) do
				for _, requiredTag in ipairs(rule.triggerTags or {}) do
					if tag == requiredTag then
						triggered = true
						break
					end
				end
				if triggered then break end
			end
		end
		if not triggered and outcome and outcome.eventId then
			for _, requiredTag in ipairs(rule.triggerTags or {}) do
				if outcome.eventId == requiredTag then
					triggered = true
					break
				end
			end
		end

		if triggered and rule.condition(playerData, outcome) then
			local response = rule.effect(playerData, outcome) or {}
			for _, addId in ipairs(response.addTraits or {}) do
				TraitSystem.AddTrait(playerData, addId)
				table.insert(applied, { type = "add", trait = addId, ruleId = rule.id })
			end
			for _, removeId in ipairs(response.removeTraits or {}) do
				TraitSystem.RemoveTrait(playerData, removeId)
				table.insert(applied, { type = "remove", trait = removeId, ruleId = rule.id })
			end
			for stat, delta in pairs(response.statDelta or {}) do
				playerData.Stats[stat] = (playerData.Stats[stat] or 0) + delta
				statDelta[stat] = (statDelta[stat] or 0) + delta
			end
			if response.notes then
				table.insert(narrative, response.notes)
			end
		end
	end

	local resolveResult = TraitSystem.ResolveTraits(playerData)
	for stat, delta in pairs(resolveResult.statDelta or {}) do
		statDelta[stat] = (statDelta[stat] or 0) + delta
	end
	for _, note in ipairs(resolveResult.narrative or {}) do
		table.insert(narrative, note)
	end
	for _, action in ipairs(resolveResult.applied or {}) do
		table.insert(applied, action)
	end

	return {
		applied = applied,
		statDelta = statDelta,
		narrative = narrative,
	}
end

function TraitSystem.ApplyChoiceTraits(playerData, payload)
	playerData = ensurePlayerShape(playerData)
	payload = payload or {}
	local applied = {}

	for _, traitId in ipairs(payload.add or {}) do
		local result = TraitSystem.AddTrait(playerData, traitId)
		table.insert(applied, { type = "add", trait = traitId, success = result.success })
	end

	for _, traitId in ipairs(payload.remove or {}) do
		TraitSystem.RemoveTrait(playerData, traitId)
		table.insert(applied, { type = "remove", trait = traitId })
	end

	local resolveInfo = nil
	if payload.resolve then
		resolveInfo = TraitSystem.ResolveTraits(playerData)
	end

	if payload.applyModifiers then
		for stat, delta in pairs(payload.applyModifiers) do
			playerData.Stats[stat] = (playerData.Stats[stat] or 0) + delta
		end
	end

	return {
		applied = applied,
		resolve = resolveInfo,
	}
end

function TraitSystem.ValidateDefinitions()
	local errors = {}
	for id, def in pairs(TRAITS) do
		for _, prereq in ipairs(def.prerequisites or {}) do
			if not TRAITS[prereq] then
				table.insert(errors, ("Trait %s missing prerequisite %s"):format(id, prereq))
			end
		end
		for _, incompatible in ipairs(def.incompatible or {}) do
			if not TRAITS[incompatible] then
				table.insert(errors, ("Trait %s incompatible with unknown %s"):format(id, incompatible))
			end
		end
	end
	return errors
end

function TraitSystem.RecommendFixes(playerData)
	playerData = ensurePlayerShape(playerData)
	local existing = traitListToSet(playerData.Traits)
	local toAdd = {}
	local toRemove = {}
	local notes = {}

	for _, traitId in ipairs(playerData.Traits) do
		local def = TRAITS[traitId]
		if def then
			for _, prereq in ipairs(def.prerequisites or {}) do
				if not existing[prereq] then
					table.insert(toAdd, prereq)
					table.insert(notes, ("Missing %s prerequisite %s"):format(traitId, prereq))
				end
			end
			for _, incompatible in ipairs(def.incompatible or {}) do
				if existing[incompatible] then
					table.insert(toRemove, incompatible)
					table.insert(notes, ("Conflict %s vs %s"):format(traitId, incompatible))
				end
			end
		end
	end

	return { toAdd = toAdd, toRemove = toRemove, notes = notes }
end

function TraitSystem.Serialize(playerData)
	return {
		traits = shallowCopy(playerData.Traits or {}),
		stats = shallowCopy(playerData.Stats or BASE_STATS),
	}
end

function TraitSystem.Deserialize(serialized)
	return {
		Traits = shallowCopy(serialized and serialized.traits or {}),
		Stats = shallowCopy(serialized and serialized.stats or BASE_STATS),
	}
end

function TraitSystem.ListRegisteredTraits()
	local list = {}
	for id, def in pairs(TRAITS) do
		list[id] = {
			id = def.id,
			name = def.name,
			desc = def.desc,
			tier = def.tier,
			tags = shallowCopy(def.tags),
			modifiers = shallowCopy(def.modifiers),
		}
	end
	return list
end

function TraitSystem.Diagnose(playerData)
	return {
		recommended = TraitSystem.RecommendFixes(playerData),
		computed = TraitSystem.ComputeStatsWithTraits(playerData),
	}
end

TraitSystem.BASE_STATS = BASE_STATS
TraitSystem.TRAITS = TRAITS
TraitSystem.INTERACTION_RULES = INTERACTION_RULES
TraitSystem.EVOLUTION_RULES = EVOLUTION_RULES

TraitSystem.Init()

return TraitSystem
