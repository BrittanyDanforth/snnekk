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
		id = "MENTOR_DRIVER",
		name = "Mentorship Core",
		desc = "Channels obsession into teaching; boosts team morale.",
		tags = {"leadership"},
		tier = 3,
		modifiers = { Charisma = 3, MentalHealth = 2 },
		prerequisites = {"RACER"},
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
		id = "DATA_STRATEGIST",
		name = "Telemetry Strategist",
		desc = "Reads race data like poetry; anticipates chaos.",
		tags = {"analytics"},
		tier = 3,
		modifiers = { Intelligence = 4, TechSkill = 4 },
		prerequisites = {"MECHANICAPPT"},
	})
end

local function registerBaseInteractions()
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
