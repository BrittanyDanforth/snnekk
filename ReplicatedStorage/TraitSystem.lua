-- TraitSystem.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- AAA-TIER TRAIT INTERACTION SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- This is the backend that makes traits MATTER. Features:
-- - Trait definitions with stats, modifiers, and hidden flags
-- - Trait prerequisites and incompatibilities
-- - Evolution rules (traits can transform based on events)
-- - Interaction matrix (trait combinations create new effects)
-- - Event-driven hooks for trait evolution
-- - Serialization for DataStore persistence
--
-- Based on the deep system from the ChatGPT conversation:
-- RacerInterest → SpeedDemon → RecklessDriver (or GoodDriver)
-- Childhood traits that affect adult life paths
--
-- ═══════════════════════════════════════════════════════════════════════════════

local TraitSystem = {}
TraitSystem.__index = TraitSystem

-- ═══════════════════════════════════════════════════════════════════════════════
-- BASE STATS CONFIGURATION
-- ═══════════════════════════════════════════════════════════════════════════════

local BASE_STATS = {
	Health = 50,
	Happiness = 50,
	Smarts = 50,
	Looks = 50,
	-- Extended stats for deep simulation
	Strength = 50,
	Stamina = 50,
	Charisma = 50,
	Creativity = 50,
	Luck = 50,
	-- Automotive-specific stats
	DrivingSkill = 0,
	MechanicalSkill = 0,
	RiskAffinity = 0,      -- Positive = risk-loving, negative = cautious
	MentalHealth = 0,      -- Positive = resilient, negative = fragile
	Fame = 0,
	Karma = 0,
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- TRAIT REGISTRY
-- ═══════════════════════════════════════════════════════════════════════════════

local TRAITS = {}

-- ═══════════════════════════════════════════════════════════════════════════════
-- INTERACTION RULES (when player has multiple traits)
-- ═══════════════════════════════════════════════════════════════════════════════

local INTERACTION_RULES = {}

-- ═══════════════════════════════════════════════════════════════════════════════
-- EVOLUTION RULES (traits that transform based on events)
-- ═══════════════════════════════════════════════════════════════════════════════

local EVOLUTION_RULES = {}

-- ═══════════════════════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════════

local function shallowCopy(t)
	local out = {}
	for k, v in pairs(t) do out[k] = v end
	return out
end

local function ensurePlayerShape(playerData)
	playerData.Traits = playerData.Traits or {}
	playerData.Stats = playerData.Stats or shallowCopy(BASE_STATS)
	playerData.HiddenFlags = playerData.HiddenFlags or {}
end

local function traitExists(traitId)
	return TRAITS[traitId] ~= nil
end

local function traitListToSet(list)
	local set = {}
	for _, v in ipairs(list or {}) do set[v] = true end
	return set
end

local function satisfiesNeed(haveSet, need)
	for _, n in ipairs(need or {}) do
		if not haveSet[n] then return false end
	end
	return true
end

local function addTraitIfMissing(list, trait)
	for _, v in ipairs(list) do 
		if v == trait then return false end 
	end
	table.insert(list, trait)
	return true
end

local function removeTraitFromList(list, trait)
	for i = #list, 1, -1 do
		if list[i] == trait then 
			table.remove(list, i) 
			return true
		end
	end
	return false
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- TRAIT DEFINITIONS
-- ═══════════════════════════════════════════════════════════════════════════════

local function registerTrait(def)
	assert(def and def.id, "Trait definition requires an id")
	TRAITS[def.id] = def
end

local function registerBaseTraits()
	
	-- ═══════════════════════════════════════════════════════════════
	-- CHILDHOOD ORIGIN TRAITS (set early, affect everything)
	-- ═══════════════════════════════════════════════════════════════
	
	registerTrait({
		id = "racer_interest",
		name = "Racer Interest",
		emoji = "🚗",
		description = "Early obsession with cars, speed, and racing. The foundation of an automotive life.",
		category = "origin",
		tier = 1, -- Foundation trait
		
		modifiers = {
			DrivingSkill = 3,
			RiskAffinity = 2,
			Happiness = 2,
		},
		
		hidden = {
			speedSeed = true,
			mechanicalAptitudePotential = true,
		},
		
		prerequisites = {},
		incompatible = {"car_anxiety", "racer_interest_rejected"},
		exclusiveGroup = nil,
		
		-- Traits this can evolve into
		evolvesInto = {"speed_demon", "thrill_seeker", "natural_racer"},
	})
	
	registerTrait({
		id = "mechanical_aptitude",
		name = "Mechanical Aptitude", 
		emoji = "🔧",
		description = "Natural talent for understanding how machines work. Learned in a garage, expressed forever.",
		category = "origin",
		tier = 1,
		
		modifiers = {
			MechanicalSkill = 5,
			Smarts = 2,
			DrivingSkill = 1,
		},
		
		hidden = {
			mechanicalGenius = true,
		},
		
		prerequisites = {},
		incompatible = {"mechanical_aptitude_rejected"},
		exclusiveGroup = nil,
		
		evolvesInto = {"mechanical_genius"},
	})
	
	registerTrait({
		id = "thrill_seeker",
		name = "Thrill Seeker",
		emoji = "⚡",
		description = "Lives for adrenaline. Danger is a feature, not a bug.",
		category = "personality",
		tier = 1,
		
		modifiers = {
			RiskAffinity = 8,
			Happiness = 3,
			MentalHealth = -2,
		},
		
		hidden = {
			deathWishPotential = true,
		},
		
		prerequisites = {"racer_interest"},
		incompatible = {"cautious_driver", "racing_fear"},
		exclusiveGroup = "risk_profile",
		
		evolvesInto = {"speed_demon", "reckless_driver"},
	})
	
	-- ═══════════════════════════════════════════════════════════════
	-- DRIVING STYLE TRAITS (how they handle a vehicle)
	-- ═══════════════════════════════════════════════════════════════
	
	registerTrait({
		id = "speed_demon",
		name = "Speed Demon",
		emoji = "💨",
		description = "Addicted to velocity. Every drive is an opportunity to go faster.",
		category = "driving",
		tier = 2,
		
		modifiers = {
			DrivingSkill = 5,
			RiskAffinity = 6,
			Luck = -2,
			MentalHealth = 2,
		},
		
		hidden = {
			speedAddiction = true,
			crashRiskModifier = 1.3,
		},
		
		prerequisites = {"racer_interest"},
		incompatible = {"cautious_driver", "speed_fear"},
		exclusiveGroup = "driving_style",
	})
	
	registerTrait({
		id = "reckless_driver",
		name = "Reckless Driver",
		emoji = "⚠️",
		description = "Safety is for other people. Pushes limits beyond reason.",
		category = "driving",
		tier = 2,
		
		modifiers = {
			DrivingSkill = 3,
			RiskAffinity = 10,
			Luck = -5,
			Health = -3,
		},
		
		hidden = {
			crashRiskModifier = 1.8,
			policeAttentionModifier = 1.5,
		},
		
		prerequisites = {"speed_demon"},
		incompatible = {"good_driver", "cautious_driver"},
		exclusiveGroup = "driving_style",
	})
	
	registerTrait({
		id = "good_driver",
		name = "Good Driver",
		emoji = "✅",
		description = "Skilled, calm, and measured. Fast when needed, safe always.",
		category = "driving",
		tier = 2,
		
		modifiers = {
			DrivingSkill = 8,
			Luck = 3,
			RiskAffinity = -2,
		},
		
		hidden = {
			crashRiskModifier = 0.6,
			policeAttentionModifier = 0.5,
		},
		
		prerequisites = {"racer_interest"},
		incompatible = {"reckless_driver"},
		exclusiveGroup = "driving_style",
	})
	
	registerTrait({
		id = "natural_racer",
		name = "Natural Racer",
		emoji = "🏎️",
		description = "Born with the instinct. Things click on track that others have to learn.",
		category = "racing",
		tier = 2,
		
		modifiers = {
			DrivingSkill = 10,
			Smarts = 3,
			RiskAffinity = 3,
		},
		
		hidden = {
			raceWinModifier = 1.4,
			scoutInterestModifier = 1.5,
		},
		
		prerequisites = {"racer_interest", "racing_talent"},
		incompatible = {"racing_fear"},
		exclusiveGroup = nil,
	})
	
	registerTrait({
		id = "cautious_driver",
		name = "Cautious Driver",
		emoji = "🐢",
		description = "Safety first, always. Rarely pushes limits.",
		category = "driving",
		tier = 2,
		
		modifiers = {
			DrivingSkill = 2,
			RiskAffinity = -8,
			Luck = 5,
			Health = 2,
		},
		
		hidden = {
			crashRiskModifier = 0.3,
		},
		
		prerequisites = {},
		incompatible = {"speed_demon", "reckless_driver", "thrill_seeker"},
		exclusiveGroup = "driving_style",
	})
	
	-- ═══════════════════════════════════════════════════════════════
	-- CAREER/SKILL TRAITS
	-- ═══════════════════════════════════════════════════════════════
	
	registerTrait({
		id = "mechanical_genius",
		name = "Mechanical Genius",
		emoji = "🧠",
		description = "Mastery of machines. Can fix, build, or improve anything with an engine.",
		category = "skill",
		tier = 3,
		
		modifiers = {
			MechanicalSkill = 15,
			Smarts = 5,
			DrivingSkill = 3,
		},
		
		prerequisites = {"mechanical_aptitude"},
		incompatible = {},
	})
	
	registerTrait({
		id = "racing_legend",
		name = "Racing Legend",
		emoji = "👑",
		description = "A name spoken with reverence. Championships, records, immortality.",
		category = "achievement",
		tier = 3,
		
		modifiers = {
			Fame = 30,
			Happiness = 10,
			Charisma = 5,
		},
		
		hidden = {
			legacyValue = true,
		},
		
		prerequisites = {"natural_racer"},
		incompatible = {"disgraced"},
	})
	
	registerTrait({
		id = "notorious_racer",
		name = "Notorious Racer",
		emoji = "😈",
		description = "Famous in the underground. Respected, feared, wanted.",
		category = "reputation",
		tier = 3,
		
		modifiers = {
			Fame = 10,
			Karma = -10,
			RiskAffinity = 5,
		},
		
		hidden = {
			policeInterest = true,
			underworldConnections = true,
		},
		
		prerequisites = {"speed_demon", "street_racing_initiate"},
		incompatible = {"clean_record"},
	})
	
	-- ═══════════════════════════════════════════════════════════════
	-- TRAUMA & CONSEQUENCE TRAITS
	-- ═══════════════════════════════════════════════════════════════
	
	registerTrait({
		id = "crash_survivor",
		name = "Crash Survivor",
		emoji = "🔥",
		description = "Walked away from something that should have been fatal. Changed forever.",
		category = "trauma",
		tier = 2,
		
		modifiers = {
			MentalHealth = -5,
			RiskAffinity = -3, -- More cautious after near-death
			Luck = 5, -- Lucky to be alive
		},
		
		hidden = {
			nearDeathExperience = true,
		},
		
		prerequisites = {},
		incompatible = {},
	})
	
	registerTrait({
		id = "racing_fear",
		name = "Racing Fear",
		emoji = "😰",
		description = "Trauma from a crash or near-miss. Speed now triggers anxiety.",
		category = "trauma",
		tier = 2,
		
		modifiers = {
			RiskAffinity = -15,
			MentalHealth = -8,
			DrivingSkill = -3,
		},
		
		prerequisites = {"crash_survivor"},
		incompatible = {"speed_demon", "thrill_seeker"},
	})
	
	registerTrait({
		id = "invincibility_complex",
		name = "Invincibility Complex",
		emoji = "💪",
		description = "Believes they can't be hurt. Dangerously overconfident.",
		category = "psychological",
		tier = 2,
		
		modifiers = {
			RiskAffinity = 12,
			MentalHealth = 5,
			Luck = -8,
		},
		
		hidden = {
			fatalOverconfidence = true,
			crashRiskModifier = 2.0,
		},
		
		prerequisites = {},
		incompatible = {"cautious_driver", "racing_fear"},
	})
	
	-- ═══════════════════════════════════════════════════════════════
	-- CRIMINAL TRAITS
	-- ═══════════════════════════════════════════════════════════════
	
	registerTrait({
		id = "street_racing_initiate",
		name = "Street Racer",
		emoji = "🌙",
		description = "Part of the underground racing scene. Illegal, dangerous, alive.",
		category = "criminal",
		tier = 2,
		
		modifiers = {
			DrivingSkill = 4,
			RiskAffinity = 5,
			Karma = -5,
		},
		
		hidden = {
			policeRisk = true,
			underworldAccess = true,
		},
		
		prerequisites = {"racer_interest"},
		incompatible = {"clean_record"},
	})
	
	registerTrait({
		id = "car_thief",
		name = "Car Thief",
		emoji = "🔓",
		description = "Steals cars for money or thrills. A darker path.",
		category = "criminal",
		tier = 2,
		
		modifiers = {
			DrivingSkill = 5,
			MechanicalSkill = 3,
			Karma = -15,
			RiskAffinity = 8,
		},
		
		hidden = {
			prisonRisk = true,
			criminalNetwork = true,
		},
		
		prerequisites = {"street_racing_initiate"},
		incompatible = {"moral_compass"},
	})
	
	registerTrait({
		id = "getaway_driver",
		name = "Getaway Driver",
		emoji = "💨",
		description = "The wheelman. Drives for criminals. High stakes, high pay, high risk.",
		category = "criminal",
		tier = 3,
		
		modifiers = {
			DrivingSkill = 12,
			Karma = -20,
			RiskAffinity = 10,
		},
		
		hidden = {
			fbiInterest = true,
			deathRisk = true,
		},
		
		prerequisites = {"car_thief", "speed_demon"},
		incompatible = {"moral_compass", "clean_record"},
	})
	
	-- ═══════════════════════════════════════════════════════════════
	-- POSITIVE LIFE TRAITS
	-- ═══════════════════════════════════════════════════════════════
	
	registerTrait({
		id = "petrolhead",
		name = "Petrolhead",
		emoji = "⛽",
		description = "Lives and breathes cars. It's not a hobby, it's an identity.",
		category = "lifestyle",
		tier = 1,
		
		modifiers = {
			Happiness = 5,
			DrivingSkill = 2,
			MechanicalSkill = 2,
		},
		
		prerequisites = {"racer_interest"},
		incompatible = {},
	})
	
	registerTrait({
		id = "mentor",
		name = "Mentor",
		emoji = "👨‍🏫",
		description = "Passes knowledge to the next generation. Leaves a legacy beyond racing.",
		category = "legacy",
		tier = 3,
		
		modifiers = {
			Karma = 10,
			Happiness = 8,
			Charisma = 5,
		},
		
		prerequisites = {},
		incompatible = {},
	})
	
	registerTrait({
		id = "hall_of_famer",
		name = "Hall of Famer",
		emoji = "🏛️",
		description = "Immortalized in the Hall of Fame. A living legend.",
		category = "achievement",
		tier = 3,
		
		modifiers = {
			Fame = 50,
			Happiness = 15,
			Karma = 5,
		},
		
		prerequisites = {"racing_legend"},
		incompatible = {"disgraced"},
	})
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- INTERACTION RULES
-- ═══════════════════════════════════════════════════════════════════════════════

local function registerBaseInteractions()
	
	-- Speed Demon + Reckless = Extreme crash risk
	table.insert(INTERACTION_RULES, {
		id = "speed_and_reckless",
		require = {"speed_demon", "reckless_driver"},
		priority = 100,
		effect = function(playerData)
			return {
				addTraits = {},
				removeTraits = {},
				statDelta = {Luck = -5, Health = -3, RiskAffinity = 5},
				notes = "Extreme driving style - very high crash probability",
			}
		end
	})
	
	-- Racer Interest + Mechanical Aptitude = Potential engineer
	table.insert(INTERACTION_RULES, {
		id = "racer_and_mechanic",
		require = {"racer_interest", "mechanical_aptitude"},
		priority = 90,
		effect = function(playerData)
			-- 25% chance to unlock engineering potential
			if math.random() < 0.25 then
				return {
					addTraits = {},
					removeTraits = {},
					statDelta = {Smarts = 3, MechanicalSkill = 3},
					notes = "Perfect combo for automotive engineering",
					unlockFlags = {"engineering_potential"},
				}
			end
			return {statDelta = {}}
		end
	})
	
	-- Street Racing + Car Thief = Criminal empire potential
	table.insert(INTERACTION_RULES, {
		id = "street_and_thief",
		require = {"street_racing_initiate", "car_thief"},
		priority = 85,
		effect = function(playerData)
			return {
				addTraits = {},
				removeTraits = {},
				statDelta = {Karma = -5, RiskAffinity = 3},
				notes = "Deep in the criminal underworld",
				unlockFlags = {"crime_boss_potential"},
			}
		end
	})
	
	-- Crash Survivor + Thrill Seeker = PTSD battle
	table.insert(INTERACTION_RULES, {
		id = "survivor_thrill",
		require = {"crash_survivor", "thrill_seeker"},
		priority = 80,
		effect = function(playerData)
			-- 40% chance of developing fear, 60% of becoming hardened
			if math.random() < 0.40 then
				return {
					addTraits = {"racing_fear"},
					removeTraits = {"thrill_seeker"},
					statDelta = {MentalHealth = -10},
					notes = "Trauma overcomes thrill-seeking",
				}
			else
				return {
					addTraits = {},
					removeTraits = {},
					statDelta = {MentalHealth = 5, RiskAffinity = 5},
					notes = "Hardened by near-death experience",
				}
			end
		end
	})
	
	-- Good Driver + Natural Racer = Championship material
	table.insert(INTERACTION_RULES, {
		id = "good_and_natural",
		require = {"good_driver", "natural_racer"},
		priority = 75,
		effect = function(playerData)
			return {
				addTraits = {},
				removeTraits = {},
				statDelta = {DrivingSkill = 5, Luck = 3},
				notes = "Perfect racing temperament",
				unlockFlags = {"championship_potential"},
			}
		end
	})
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- EVOLUTION RULES (traits transform based on events)
-- ═══════════════════════════════════════════════════════════════════════════════

local function registerBaseEvolutionRules()
	
	-- Major crash can create fear or strength
	table.insert(EVOLUTION_RULES, {
		id = "crash_evolution",
		triggerTags = {"crash", "accident", "injury"},
		condition = function(playerData, outcome)
			return outcome and outcome.severity and outcome.severity >= 7
		end,
		effect = function(playerData, outcome)
			local hasReckless = false
			for _, t in ipairs(playerData.Traits or {}) do
				if t == "reckless_driver" then hasReckless = true break end
			end
			
			if not hasReckless then return {statDelta = {}} end
			
			local mh = playerData.Stats and playerData.Stats.MentalHealth or 0
			local traumaChance = mh > 2 and 0.4 or 0.6
			
			if math.random() < traumaChance then
				return {
					addTraits = {"crash_survivor", "racing_fear"},
					removeTraits = {"reckless_driver"},
					statDelta = {MentalHealth = -8, RiskAffinity = -10},
					notes = "Traumatized by crash - fear develops",
				}
			else
				return {
					addTraits = {"crash_survivor"},
					removeTraits = {},
					statDelta = {MentalHealth = 3, RiskAffinity = 2},
					notes = "Hardened by crash - stronger than before",
				}
			end
		end
	})
	
	-- Winning championship evolves racing skills
	table.insert(EVOLUTION_RULES, {
		id = "championship_win",
		triggerTags = {"championship", "victory", "trophy"},
		condition = function(playerData, outcome)
			return outcome and outcome.won == true
		end,
		effect = function(playerData, outcome)
			local hasNatural = false
			for _, t in ipairs(playerData.Traits or {}) do
				if t == "natural_racer" then hasNatural = true break end
			end
			
			if hasNatural then
				return {
					addTraits = {"racing_legend"},
					removeTraits = {},
					statDelta = {Fame = 20, Happiness = 15},
					notes = "Championship win creates a legend",
				}
			end
			return {statDelta = {Fame = 10}}
		end
	})
	
	-- Prison time changes personality
	table.insert(EVOLUTION_RULES, {
		id = "prison_evolution",
		triggerTags = {"prison", "jail", "incarceration"},
		condition = function(playerData, outcome)
			return outcome and outcome.served_time == true
		end,
		effect = function(playerData, outcome)
			if math.random() < 0.5 then
				-- Reformed
				return {
					addTraits = {},
					removeTraits = {"car_thief", "getaway_driver"},
					statDelta = {Karma = 10, MentalHealth = -5},
					notes = "Prison reformed you",
					clearFlags = {"criminal_activity_started"},
				}
			else
				-- Hardened
				return {
					addTraits = {},
					removeTraits = {},
					statDelta = {Karma = -5, RiskAffinity = 5},
					notes = "Prison hardened you",
					setFlags = {"prison_connections"},
				}
			end
		end
	})
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- CORE API FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════════

function TraitSystem.Init()
	TRAITS = {}
	INTERACTION_RULES = {}
	EVOLUTION_RULES = {}
	registerBaseTraits()
	registerBaseInteractions()
	registerBaseEvolutionRules()
end

function TraitSystem.AddTrait(playerData, traitId)
	ensurePlayerShape(playerData)
	if not traitExists(traitId) then 
		return {success = false, reason = "unknown_trait"} 
	end
	
	local def = TRAITS[traitId]
	local haveSet = traitListToSet(playerData.Traits)
	
	-- Check incompatibles
	for _, inc in ipairs(def.incompatible or {}) do
		if haveSet[inc] then
			return {success = false, reason = "incompatible_with_" .. inc}
		end
	end
	
	-- Check prerequisites
	for _, prereq in ipairs(def.prerequisites or {}) do
		if not haveSet[prereq] then
			return {success = false, reason = "missing_prerequisite_" .. prereq}
		end
	end
	
	-- Handle exclusive groups
	if def.exclusiveGroup then
		for i = #playerData.Traits, 1, -1 do
			local t = playerData.Traits[i]
			if TRAITS[t] and TRAITS[t].exclusiveGroup == def.exclusiveGroup and t ~= traitId then
				table.remove(playerData.Traits, i)
			end
		end
	end
	
	if addTraitIfMissing(playerData.Traits, traitId) then
		return {success = true, reason = "added"}
	end
	return {success = false, reason = "already_has_trait"}
end

function TraitSystem.RemoveTrait(playerData, traitId)
	ensurePlayerShape(playerData)
	if removeTraitFromList(playerData.Traits, traitId) then
		return {success = true}
	end
	return {success = false, reason = "trait_not_found"}
end

function TraitSystem.HasTrait(playerData, traitId)
	ensurePlayerShape(playerData)
	local set = traitListToSet(playerData.Traits)
	return set[traitId] == true
end

function TraitSystem.ResolveTraits(playerData)
	ensurePlayerShape(playerData)
	local applied = {}
	local statDelta = {}
	local narrative = {}
	local flagChanges = {set = {}, clear = {}}
	
	local haveSet = traitListToSet(playerData.Traits)
	
	table.sort(INTERACTION_RULES, function(a, b) 
		return (a.priority or 0) > (b.priority or 0) 
	end)
	
	for _, rule in ipairs(INTERACTION_RULES) do
		if satisfiesNeed(haveSet, rule.require or {}) then
			local res = rule.effect(playerData) or {}
			
			for _, t in ipairs(res.addTraits or {}) do
				if addTraitIfMissing(playerData.Traits, t) then
					table.insert(applied, {type = "add", trait = t, rule = rule.id})
				end
			end
			
			for _, t in ipairs(res.removeTraits or {}) do
				if removeTraitFromList(playerData.Traits, t) then
					table.insert(applied, {type = "remove", trait = t, rule = rule.id})
				end
			end
			
			for k, v in pairs(res.statDelta or {}) do
				statDelta[k] = (statDelta[k] or 0) + v
			end
			
			if res.notes then 
				table.insert(narrative, res.notes) 
			end
			
			for _, f in ipairs(res.unlockFlags or {}) do
				table.insert(flagChanges.set, f)
			end
			
			haveSet = traitListToSet(playerData.Traits)
		end
	end
	
	-- Apply stat deltas
	playerData.Stats = playerData.Stats or shallowCopy(BASE_STATS)
	for k, v in pairs(statDelta) do
		playerData.Stats[k] = (playerData.Stats[k] or 0) + v
	end
	
	return {
		applied = applied, 
		statDelta = statDelta, 
		narrative = narrative,
		flagChanges = flagChanges,
	}
end

function TraitSystem.ComputeStatsWithTraits(playerData)
	ensurePlayerShape(playerData)
	local out = shallowCopy(playerData.Stats or BASE_STATS)
	
	for _, tId in ipairs(playerData.Traits) do
		local def = TRAITS[tId]
		if def and def.modifiers then
			for stat, delta in pairs(def.modifiers) do
				out[stat] = (out[stat] or 0) + delta
			end
		end
	end
	
	return out
end

function TraitSystem.HandleEventOutcome(playerData, outcome)
	ensurePlayerShape(playerData)
	local applied = {}
	local statDelta = {}
	local narrative = {}
	
	for _, rule in ipairs(EVOLUTION_RULES) do
		local triggerOk = false
		
		if outcome and outcome.tags then
			for _, ot in ipairs(outcome.tags) do
				for _, rt in ipairs(rule.triggerTags or {}) do
					if ot == rt then triggerOk = true break end
				end
				if triggerOk then break end
			end
		end
		
		if triggerOk and rule.condition(playerData, outcome) then
			local res = rule.effect(playerData, outcome) or {}
			
			for _, t in ipairs(res.addTraits or {}) do
				if addTraitIfMissing(playerData.Traits, t) then
					table.insert(applied, {type = "add", trait = t, ruleId = rule.id})
				end
			end
			
			for _, t in ipairs(res.removeTraits or {}) do
				if removeTraitFromList(playerData.Traits, t) then
					table.insert(applied, {type = "remove", trait = t, ruleId = rule.id})
				end
			end
			
			for k, v in pairs(res.statDelta or {}) do
				statDelta[k] = (statDelta[k] or 0) + v
			end
			
			if res.notes then 
				table.insert(narrative, res.notes) 
			end
		end
	end
	
	-- Apply stat deltas
	playerData.Stats = playerData.Stats or shallowCopy(BASE_STATS)
	for k, v in pairs(statDelta) do
		playerData.Stats[k] = (playerData.Stats[k] or 0) + v
	end
	
	-- Run interactions after evolution
	local inter = TraitSystem.ResolveTraits(playerData)
	for k, v in pairs(inter.statDelta or {}) do 
		statDelta[k] = (statDelta[k] or 0) + v 
	end
	for _, n in ipairs(inter.narrative or {}) do 
		table.insert(narrative, n) 
	end
	for _, a in ipairs(inter.applied or {}) do 
		table.insert(applied, a) 
	end
	
	return {applied = applied, statDelta = statDelta, narrative = narrative}
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SERIALIZATION FOR DATASTORE
-- ═══════════════════════════════════════════════════════════════════════════════

function TraitSystem.Serialize(playerData)
	ensurePlayerShape(playerData)
	return {
		traits = playerData.Traits,
		stats = playerData.Stats,
		hiddenFlags = playerData.HiddenFlags,
	}
end

function TraitSystem.Deserialize(serial)
	return {
		Traits = serial.traits or {},
		Stats = serial.stats or shallowCopy(BASE_STATS),
		HiddenFlags = serial.hiddenFlags or {},
	}
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- DEBUG & UTILITY
-- ═══════════════════════════════════════════════════════════════════════════════

function TraitSystem.GetTrait(traitId)
	return TRAITS[traitId]
end

function TraitSystem.ListAllTraits()
	local out = {}
	for k, v in pairs(TRAITS) do
		out[k] = {
			id = v.id,
			name = v.name,
			emoji = v.emoji,
			description = v.description,
			category = v.category,
			tier = v.tier,
			modifiers = v.modifiers and shallowCopy(v.modifiers) or {},
		}
	end
	return out
end

function TraitSystem.Diagnose(playerData)
	ensurePlayerShape(playerData)
	return {
		traits = playerData.Traits,
		stats = TraitSystem.ComputeStatsWithTraits(playerData),
		traitCount = #playerData.Traits,
	}
end

function TraitSystem.ValidateTraitTree()
	local errors = {}
	for id, def in pairs(TRAITS) do
		for _, p in ipairs(def.prerequisites or {}) do
			if not TRAITS[p] then
				table.insert(errors, id .. " requires unknown trait: " .. p)
			end
		end
		for _, inc in ipairs(def.incompatible or {}) do
			if not TRAITS[inc] and not string.find(inc, "_rejected") then
				-- Allow _rejected flags even if not traits
			end
		end
	end
	return errors
end

-- Export constants
TraitSystem.BASE_STATS = shallowCopy(BASE_STATS)
TraitSystem.TRAITS = TRAITS
TraitSystem.registerTrait = registerTrait

-- Auto-initialize
TraitSystem.Init()

return TraitSystem
