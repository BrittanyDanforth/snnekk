-- EventRunner.lua
-- Ultra-polished life event engine + narrative builder
-- Uses NarrativeContent module for BitLife-style rich text generation
-- Integrates with LifeStageSystem for proper age-based event validation

----------------------------------------------------------------------
-- TYPE DEFINITIONS
----------------------------------------------------------------------

export type LifeStatsSnapshot = {
	Money: number,
	Happiness: number,
	Health: number,
	Smarts: number,
	Looks: number,
}

export type LifeFlags = {
	[string]: boolean,
}

export type LifeStats = {
	Happiness: number?,
	Health: number?,
	Smarts: number?,
	Looks: number?,
}

export type EventHistory = {
	seenEvents: { [string]: boolean }?,
	lastOccurrence: { [string]: number }?,
	milestonesFired: { [string]: boolean }?,
}

export type LifeState = {
	Age: number?,
	Money: number?,
	Stats: LifeStats?,
	Happiness: number?,
	Health: number?,
	Smarts: number?,
	Looks: number?,
	Flags: LifeFlags?,
	EventHistory: EventHistory?,
}

export type EffectsMap = {
	[string]: number,
}

export type DynamicDataValue = string | number | boolean | { [string]: any }
export type DynamicData = {
	[string]: DynamicDataValue,
}

export type EventChoice = {
	text: string,
	result: string?,
	resultText: string?,
	effects: EffectsMap?,
	setFlag: string?,
	clearFlag: string?,
	setFlags: { string }?,
	clearFlags: { string }?,
	minigame: string?,
	outcome: string?,
	getDynamicMoney: ((DynamicData) -> (number?))?,
}

export type EventDef = {
	id: string,
	emoji: string?,
	title: string?,
	text: string?,
	category: string?,
	milestone: boolean?,
	weight: number?,
	minigame: string?,
	choices: { EventChoice }?,
}

export type ApplyChoiceResults = {
	effects: EffectsMap,
	flagsSet: { string },
	flagsCleared: { string },
	minigameTriggered: string?,
	resultText: string,
}

export type StoryPath = {
	active: boolean,
	level: string,
	progress: number,
	milestones: { string },
}

export type StoryPaths = {
	political: StoryPath,
	criminal: StoryPath,
	celebrity: StoryPath,
	business: StoryPath,
}

export type SpecialAction = {
	id: string,
	name: string,
	emoji: string,
	type: string,
	description: string,
}

export type ClientChoicePayload = {
	index: number,
	text: string,
	result: string?,
	effects: EffectsMap?,
	setFlag: string?,
	clearFlag: string?,
	minigame: string?,
	outcome: string?,
}

export type ClientEventPayload = {
	id: string,
	emoji: string?,
	title: string?,
	text: string?,
	category: string?,
	choices: { ClientChoicePayload },
	hasMinigame: boolean,
	minigameType: string?,
}

----------------------------------------------------------------------
-- MODULE TABLE
----------------------------------------------------------------------

local EventRunner = {}

----------------------------------------------------------------------
-- LOAD MODULES
----------------------------------------------------------------------

local NarrativeContent = require(script.Parent:WaitForChild("NarrativeContent"))
local LifeStageSystem = require(script.Parent:WaitForChild("LifeStageSystem"))
local RelationshipService = require(script.Parent:WaitForChild("RelationshipService"))

local StatNarrative = NarrativeContent.StatNarrative
local MoneyNarrative = NarrativeContent.MoneyNarrative
local FlagDescriptions = NarrativeContent.FlagDescriptions
local YearRecapTemplates = NarrativeContent.YearRecapTemplates
-- CategoryFlavor removed - was too spammy/repetitive
local LifeStageTransitions = NarrativeContent.LifeStageTransitions
local RelationshipLines = NarrativeContent.RelationshipLines

----------------------------------------------------------------------
-- INTERNAL HELPERS / UTILITIES
----------------------------------------------------------------------

local function formatMoney(n: number?): string
	if not n then
		return "$0"
	end

	local absN = math.abs(n)
	local sign = n < 0 and "-" or ""

	if absN >= 1_000_000_000 then
		return sign .. string.format("$%.1fB", absN / 1_000_000_000)
	elseif absN >= 1_000_000 then
		return sign .. string.format("$%.1fM", absN / 1_000_000)
	elseif absN >= 1_000 then
		return sign .. string.format("$%.1fK", absN / 1_000)
	else
		return sign .. "$" .. tostring(math.floor(absN))
	end
end

local function pickRandom<T>(list: { T }?): T?
	if not list or #list == 0 then
		return nil
	end
	return list[math.random(1, #list)]
end

local function clampStat(val: number?): number
	return math.clamp(val or 50, 0, 100)
end

local function getStatSnapshot(state: LifeState): LifeStatsSnapshot
	local stats = state.Stats or {}

	return {
		Money = state.Money or 0,
		Happiness = stats.Happiness or state.Happiness or 50,
		Health = stats.Health or state.Health or 50,
		Smarts = stats.Smarts or state.Smarts or 50,
		Looks = stats.Looks or state.Looks or 50,
	}
end

local function getLifeStage(age: number): string
	if age <= 1 then
		return "baby"
	elseif age <= 4 then
		return "toddler"
	elseif age <= 9 then
		return "early_childhood"
	elseif age <= 12 then
		return "childhood"
	elseif age <= 15 then
		return "tween"
	elseif age <= 19 then
		return "teenage"
	elseif age <= 35 then
		return "young_adult"
	elseif age <= 60 then
		return "adult"
	elseif age <= 80 then
		return "senior"
	else
		return "elderly"
	end
end

local function classifyMagnitude(deltaAbs: number): string
	if deltaAbs >= 30 then
		return "huge"
	elseif deltaAbs >= 15 then
		return "big"
	elseif deltaAbs >= 7 then
		return "medium"
	else
		return "small"
	end
end

----------------------------------------------------------------------
-- NARRATIVE BUILDERS
----------------------------------------------------------------------

local function describeStatLine(statKey: string, delta: number, finalValue: number?): string?
	if not delta or delta == 0 then
		return nil
	end

	local statTable = StatNarrative[statKey]
	if not statTable then
		return nil
	end

	local direction = (delta > 0) and "up" or "down"
	local absDelta = math.abs(delta)
	local bucket = classifyMagnitude(absDelta)

	local bucketTable = statTable[direction] and statTable[direction][bucket]
	if not bucketTable or #bucketTable == 0 then
		return nil
	end

	local template = pickRandom(bucketTable)
	if not template then
		return nil
	end

	-- Clean prose - no percentage formatting needed
	return template
end

local function describeMoneyLine(delta: number, finalMoney: number?): string?
	if not delta or delta == 0 then
		return nil
	end

	local direction = (delta > 0) and "gain" or "loss"
	local absDelta = math.abs(delta)

	local bucket: string
	if absDelta >= 50_000 then
		bucket = "large"
	elseif absDelta >= 5_000 then
		bucket = "medium"
	else
		bucket = "small"
	end

	local dirTable = MoneyNarrative[direction]
	local bucketTbl = dirTable and dirTable[bucket]
	if not bucketTbl or #bucketTbl == 0 then
		return nil
	end

	local template = pickRandom(bucketTbl)
	if not template then
		return nil
	end

	-- Clean prose - no amount formatting needed
	return template
end

local function describeFlags(flagsSet: { string }?, flagsCleared: { string }?): { string }
	local lines: { string } = {}

	if flagsSet and #flagsSet > 0 then
		for _, flag in ipairs(flagsSet) do
			local desc = FlagDescriptions[flag]
			if desc then
				table.insert(lines, desc)
			end
			-- Don't add generic text for unknown flags - keep it clean
		end
	end

	if flagsCleared and #flagsCleared > 0 then
		for _, flag in ipairs(flagsCleared) do
			local _desc = FlagDescriptions[flag]
			if _desc then
				table.insert(lines, "That chapter is over.")
			end
		end
	end

	return lines
end

-- NOTE: getCategoryFlavor removed - was too spammy

local function getYearRecap(state: LifeState): string?
	if not YearRecapTemplates then
		return nil
	end

	local flags = state.Flags or {}
	local age = state.Age or 0
	local lifeStage = getLifeStage(age)
	
	-- Check if player has EVER worked (important for narrative accuracy)
	local hasEverWorked = flags.employed or flags.has_job or flags.career_starter 
		or flags.ever_worked or flags.first_job or flags.good_worker 
		or flags.worked_parttime or flags.intern_experience or flags.internship_completed

	-- Prioritize special career paths over life stage
	local bucket: string
	if flags.crime_boss or flags.underboss or flags.gang_member or flags.gang_captain then
		bucket = "criminal_path"
	elseif flags.president or flags.us_senator or flags.congressman or flags.governor or flags.mayor then
		bucket = "political_path"
	elseif flags.f1_driver or flags.world_champion or flags.racing_legend or flags.junior_formula then
		bucket = "racer_path"
	elseif flags.teacher or flags.principal or flags.superintendent then
		bucket = "teacher_path"
	elseif flags.art_celebrity or flags.museum_piece or flags.gallery_show or flags.art_school then
		bucket = "artist_path"
	elseif flags.elite_hacker or flags.hacker_career or flags.hacker_group or flags.black_hat then
		bucket = "hacker_path"
	elseif flags.married or flags.engaged or flags.in_love then
		bucket = "romantic_path"
	elseif flags.millionaire or flags.billionaire or flags.tech_billionaire then
		bucket = "wealthy_path"
	elseif flags.bankrupt or flags.homeless or flags.unemployed or (lifeStage == "adult" and not hasEverWorked) then
		-- Include adults who never worked in struggling_path
		bucket = "struggling_path"
	else
		bucket = lifeStage
	end

	local templates = YearRecapTemplates[bucket]
	if not templates or #templates == 0 then
		-- Fallback to life stage
		templates = YearRecapTemplates[lifeStage]
	end

	if templates and #templates > 0 then
		local recap = pickRandom(templates)
		if recap then
			return string.format(recap, age)
		end
	end

	return nil
end

----------------------------------------------------------------------
-- MAIN NARRATIVE BUILDER
----------------------------------------------------------------------

function EventRunner.buildNarrativeText(
	state: LifeState,
	eventDef: EventDef?,
	choice: EventChoice?,
	results: ApplyChoiceResults,
	dynamicData: DynamicData?,
	explicitResultText: string?
): string
	local lines: { string } = {}

	-- 1) Start with explicit result text if provided
	if explicitResultText and explicitResultText ~= "" then
		table.insert(lines, explicitResultText)
	end

	-- 2) Add money / stat summaries
	local snapshot = getStatSnapshot(state)
	local effects = results.effects or {}

	if effects.Money and effects.Money ~= 0 then
		local moneyLine = describeMoneyLine(effects.Money, snapshot.Money)
		if moneyLine then
			table.insert(lines, moneyLine)
		end
	end

	local orderedStats = { "Happiness", "Health", "Smarts", "Looks" }
	for _, key in ipairs(orderedStats) do
		local delta = effects[key]
		if delta and delta ~= 0 then
			local statValue = snapshot[key]
			local line = describeStatLine(key, delta, statValue)
			if line then
				table.insert(lines, line)
			end
		end
	end

	-- 3) Flag / story-path flavor
	local flagLines = describeFlags(results.flagsSet, results.flagsCleared)
	for _, l in ipairs(flagLines) do
		table.insert(lines, l)
	end

	-- 4) Fallbacks when event/choice had no explicit text or effects
	if #lines == 0 then
		if eventDef and eventDef.title then
			table.insert(lines, "You experienced: " .. eventDef.title .. ".")
		elseif eventDef and eventDef.text then
			local base = EventRunner.processDynamicText(eventDef.text, dynamicData or {})
			table.insert(lines, base or "Something noteworthy happened in your life.")
		else
			table.insert(lines, "Life moved on, but nothing dramatic stood out this year.")
		end
	end

	-- NOTE: Removed category flavor text - was too repetitive/spammy

	return table.concat(lines, "\n")
end

-- Build a full year recap (BitLife-style summary)
function EventRunner.buildYearRecap(state: LifeState): string?
	return getYearRecap(state)
end

-- Get life stage for UI display
function EventRunner.getLifeStage(age: number): string
	return getLifeStage(age)
end

-- Format money for display
function EventRunner.formatMoney(amount: number?): string
	return formatMoney(amount)
end

----------------------------------------------------------------------
-- HISTORY / EVENT PICKING
----------------------------------------------------------------------

-- Configuration for event frequency
local DEFAULT_EVENT_CHANCE = 0.70  -- 70% chance a year has an event (30% chance of "quiet year")

function EventRunner.initHistory(state: LifeState): EventHistory
	if not state.EventHistory then
		state.EventHistory = {
			seenEvents = {},
			lastOccurrence = {},
			milestonesFired = {},
		}
	end
	if not state.Flags then
		state.Flags = {}
	end
	-- type assertion since we guarantee it above
	return state.EventHistory :: EventHistory
end

function EventRunner.canEventFire(state: LifeState, eventDef: EventDef): boolean
	-- Use the comprehensive LifeStageSystem validation
	local validation = LifeStageSystem.validateEvent(eventDef, state)
	return validation.valid
end

-- Get validation details (for debugging)
function EventRunner.getEventValidation(state: LifeState, eventDef: EventDef): any
	return LifeStageSystem.validateEvent(eventDef, state)
end

----------------------------------------------------------------------
-- EVENT PLAYABILITY CHECK
-- Ensures that at least one choice is actually available to the player
-- This prevents "❌ Requires Money 5000" situations
----------------------------------------------------------------------

function EventRunner.isEventPlayable(state: LifeState, eventDef: EventDef): boolean
	-- Basic validation first
	if not EventRunner.canEventFire(state, eventDef) then
		return false
	end

	-- No choices = "fire and forget" flavor event → always allowed
	if not eventDef.choices or #eventDef.choices == 0 then
		return true
	end

	-- Use the same logic as the client greying-out system
	local availability = EventRunner.filterAvailableChoices(state, eventDef)

	-- Check if at least one choice is actually doable
	for i = 1, #eventDef.choices do
		local info = availability[i]
		if not info or info.available then
			-- At least one choice is actually doable
			return true
		end
	end

	-- All choices blocked -> don't pick this event at all
	return false
end

-- Get detailed playability info (for debugging)
function EventRunner.getPlayabilityInfo(state: LifeState, eventDef: EventDef): any
	local canFire = EventRunner.canEventFire(state, eventDef)
	local availability = EventRunner.filterAvailableChoices(state, eventDef)
	local playableChoices = 0
	local blockedReasons = {}
	
	for i, info in pairs(availability) do
		if info.available then
			playableChoices = playableChoices + 1
		else
			table.insert(blockedReasons, {
				choiceIndex = i,
				reason = info.reason or "Unknown"
			})
		end
	end
	
	return {
		eventId = eventDef.id,
		canFire = canFire,
		totalChoices = eventDef.choices and #eventDef.choices or 0,
		playableChoices = playableChoices,
		blockedReasons = blockedReasons,
		isPlayable = canFire and (playableChoices > 0 or not eventDef.choices or #eventDef.choices == 0),
	}
end

function EventRunner.getMilestoneEvent(state: LifeState, events: { EventDef }): EventDef?
	local history = state.EventHistory or {}

	for _, event in ipairs(events) do
		if event.milestone and EventRunner.isEventPlayable(state, event) then
			if not (history.milestonesFired and history.milestonesFired[event.id]) then
				return event
			end
		end
	end

	return nil
end

function EventRunner.pickRandomEvent(state: LifeState, events: { EventDef }): EventDef?
	-- Try to use EventEngine for proper eligibility and weighting (LifeEvents format)
	local EventEngine = nil
	pcall(function()
		local LifeEvents = script.Parent:FindFirstChild("LifeEvents")
		if LifeEvents then
			local ee = LifeEvents:FindFirstChild("EventEngine")
			if ee then
				EventEngine = require(ee)
			end
		end
	end)
	
	-- If EventEngine is available, use it for proper event selection
	if EventEngine and EventEngine.weightedSelect then
		local eligible = {}
		for _, event in ipairs(events) do
			if not event.milestone then
				-- Use EventEngine.isEligible for comprehensive checks (career, flags, etc.)
				local isEligible, reason = EventEngine.isEligible(event, state)
				if isEligible and EventRunner.isEventPlayable(state, event) then
					table.insert(eligible, event)
				end
			end
		end
		
		if #eligible > 0 then
			local selected = EventEngine.weightedSelect(eligible, state)
			if selected then
				return selected
			end
		end
	end
	
	-- Fallback: Original logic for backwards compatibility
	local eligible: { EventDef } = {}
	local totalWeight = 0

	for _, event in ipairs(events) do
		-- CRITICAL: Use isEventPlayable instead of just canEventFire
		-- This ensures we only pick events where at least one choice is available
		if not event.milestone and EventRunner.isEventPlayable(state, event) then
			table.insert(eligible, event)
			totalWeight += (event.weight or 10)
		end
	end

	if #eligible == 0 then
		return nil
	end

	local roll = math.random() * totalWeight
	local cumulative = 0

	for _, event in ipairs(eligible) do
		cumulative += (event.weight or 10)
		if roll <= cumulative then
			return event
		end
	end

	return eligible[#eligible]
end

function EventRunner.pickEvent(state: LifeState, events: { EventDef }): EventDef?
	print("[EventRunner] === PICKING EVENT ===")
	print("[EventRunner] Age:", state.Age, "InJail:", state.Flags and state.Flags.in_prison or false)
	print("[EventRunner] Total events pool:", #events)

	-- Always fire milestone events (they're important life moments)
	local milestone = EventRunner.getMilestoneEvent(state, events)
	if milestone then
		print("[EventRunner] Found milestone event:", milestone.id)
		return milestone
	end

	-- Event chance roll - some years should have "nothing special"
	-- This prevents the "random stuff popping every year" feeling
	local eventChance = state.EventChance or DEFAULT_EVENT_CHANCE
	local chanceRoll = math.random()
	
	if chanceRoll > eventChance then
		print(string.format("[EventRunner] No event this year (roll %.2f > chance %.2f)", chanceRoll, eventChance))
		return nil  -- Quiet year - no random event
	end

	local selected = EventRunner.pickRandomEvent(state, events)
	if selected then
		print("[EventRunner] Selected random event:", selected.id, "category:", selected.category or "none")
	else
		print("[EventRunner] No valid playable event found!")
	end
	return selected
end

-- Set custom event chance for a player (for special circumstances)
function EventRunner.setEventChance(state: LifeState, chance: number)
	state.EventChance = math.clamp(chance, 0, 1)
end

-- Reset event chance to default
function EventRunner.resetEventChance(state: LifeState)
	state.EventChance = nil
end

-- Check for life stage transition and return transition event if applicable
function EventRunner.checkStageTransition(oldAge: number, newAge: number): any
	return LifeStageSystem.getTransitionEvent(oldAge, newAge)
end

-- Get current life stage info
function EventRunner.getCurrentStage(state: LifeState): any
	return LifeStageSystem.getStage(state.Age or 0)
end

-- Get player capabilities at current stage
function EventRunner.getCapabilities(state: LifeState): any
	return LifeStageSystem.getCapabilities(state)
end

-- Check if player should die this year
function EventRunner.checkDeath(state: LifeState): any
	return LifeStageSystem.checkDeath(state)
end

-- Get stage summary for UI
function EventRunner.getStageSummary(state: LifeState): any
	return LifeStageSystem.getStageSummary(state)
end

-- Validate if an action is allowed
function EventRunner.canDoAction(actionType: string, state: LifeState): boolean
	local caps = LifeStageSystem.getCapabilities(state)

	if actionType == "work" then return caps.canWork end
	if actionType == "work_fulltime" then return caps.canWorkFullTime end
	if actionType == "date" then return caps.canDate end
	if actionType == "marry" then return caps.canMarry end
	if actionType == "drive" then return caps.canDrive end
	if actionType == "crime" then return caps.canCrime end
	if actionType == "drink" then return caps.canDrink end
	if actionType == "vote" then return caps.canVote end
	if actionType == "gamble" then return caps.canGamble end
	if actionType == "college" then return caps.canEnrollCollege end
	if actionType == "retire" then return caps.canRetire end

	return true -- Unknown action, allow
end

-- Filter events by current stage (for UI display)
function EventRunner.getAvailableEventsForStage(events: { EventDef }, state: LifeState): { EventDef }
	return LifeStageSystem.filterValidEvents(events, state)
end

function EventRunner.markEventOccurred(state: LifeState, eventDef: EventDef)
	local history = state.EventHistory
	if not history then
		return
	end

	history.seenEvents = history.seenEvents or {}
	history.seenEvents[eventDef.id] = true

	history.lastOccurrence = history.lastOccurrence or {}
	history.lastOccurrence[eventDef.id] = state.Age or 0

	if eventDef.milestone then
		history.milestonesFired = history.milestonesFired or {}
		history.milestonesFired[eventDef.id] = true
	end
end

----------------------------------------------------------------------
-- DYNAMIC TEXT (PLACEHOLDERS)
----------------------------------------------------------------------

function EventRunner.processDynamicText(text: string?, dynamicData: DynamicData?): string?
	if not text or not dynamicData then
		return text
	end

	local result = text
	for key, value in pairs(dynamicData) do
		if type(value) == "table" then
			for subKey, subValue in pairs(value :: { [string]: any }) do
				local placeholder = "%%" .. key .. "%." .. subKey .. "%%"
				result = string.gsub(result, placeholder, tostring(subValue))
			end
		else
			local placeholder = "%%" .. key .. "%%"
			result = string.gsub(result, placeholder, tostring(value))
		end
	end

	return result
end

function EventRunner.buildClientPayload(eventDef: EventDef, state: LifeState): (ClientEventPayload, DynamicData)
	local dynamicData: DynamicData = {}

	if eventDef.getDynamicData then
		local ok, data = pcall(eventDef.getDynamicData, state)
		if ok and data then
			dynamicData = data
		end
	end

	local processedText = nil :: string?
	if eventDef.text then
		processedText = EventRunner.processDynamicText(eventDef.text, dynamicData)
	end
	
	-- Support dynamic emoji selection based on dynamicData
	local processedEmoji = eventDef.emoji
	if eventDef.getDynamicEmoji and dynamicData then
		local emojiOk, dynEmoji = pcall(eventDef.getDynamicEmoji, dynamicData)
		if emojiOk and dynEmoji then
			processedEmoji = dynEmoji
		end
	end

	local processedChoices: { ClientChoicePayload } = {}
	for i, choice in ipairs(eventDef.choices or {}) do
		local choiceText = EventRunner.processDynamicText(choice.text, dynamicData) or choice.text
		local baseResult = choice.result or choice.resultText
		local resultText = baseResult and EventRunner.processDynamicText(baseResult, dynamicData) or baseResult

		table.insert(processedChoices, {
			index = i,
			text = choiceText,
			result = resultText,
			effects = choice.effects,
			setFlag = choice.setFlag,
			clearFlag = choice.clearFlag,
			minigame = choice.minigame,
			outcome = choice.outcome,
		})
	end

	local payload: ClientEventPayload = {
		id = eventDef.id,
		emoji = processedEmoji,
		title = eventDef.title,
		text = processedText or eventDef.text,
		category = eventDef.category,
		choices = processedChoices,
		hasMinigame = eventDef.minigame ~= nil,
		minigameType = eventDef.minigame,
	}

	return payload, dynamicData
end

----------------------------------------------------------------------
-- APPLY CHOICE + EFFECTS + NARRATIVE (COMPLETE OVERHAUL)
----------------------------------------------------------------------

-- Helper to apply effects to state
local function applyEffectsToState(state: LifeState, effects: EffectsMap?, resultsTracker)
	if not effects or type(effects) ~= "table" then return end
	
	for stat, delta in pairs(effects) do
		if type(delta) == "number" then
			if stat == "Money" then
				state.Money = (state.Money or 0) + delta
				resultsTracker.effects.Money = (resultsTracker.effects.Money or 0) + delta
			elseif stat == "Happiness" then
				local current = (state.Stats and state.Stats.Happiness) or state.Happiness or 50
				local newVal = clampStat(current + delta)
				if state.Stats then state.Stats.Happiness = newVal end
				state.Happiness = newVal
				resultsTracker.effects.Happiness = (resultsTracker.effects.Happiness or 0) + delta
			elseif stat == "Health" then
				local current = (state.Stats and state.Stats.Health) or state.Health or 50
				local newVal = clampStat(current + delta)
				if state.Stats then state.Stats.Health = newVal end
				state.Health = newVal
				resultsTracker.effects.Health = (resultsTracker.effects.Health or 0) + delta
			elseif stat == "Smarts" then
				local current = (state.Stats and state.Stats.Smarts) or state.Smarts or 50
				local newVal = clampStat(current + delta)
				if state.Stats then state.Stats.Smarts = newVal end
				state.Smarts = newVal
				resultsTracker.effects.Smarts = (resultsTracker.effects.Smarts or 0) + delta
			elseif stat == "Looks" then
				local current = (state.Stats and state.Stats.Looks) or state.Looks or 50
				local newVal = clampStat(current + delta)
				if state.Stats then state.Stats.Looks = newVal end
				state.Looks = newVal
				resultsTracker.effects.Looks = (resultsTracker.effects.Looks or 0) + delta
			end
		end
	end
end

-- Check if player meets requirements for a choice
function EventRunner.checkChoiceRequirements(state: LifeState, choice): (boolean, string?)
	-- Check stat requirements (e.g., { Smarts = 40, Money = 5000 })
	if choice.requires and type(choice.requires) == "table" then
		for stat, minValue in pairs(choice.requires) do
			local currentValue = 0
			if stat == "Money" then
				currentValue = state.Money or 0
			elseif stat == "Age" then
				currentValue = state.Age or 0
			elseif state.Stats and state.Stats[stat] then
				currentValue = state.Stats[stat]
			elseif state[stat] then
				currentValue = state[stat]
			end
			
			if currentValue < minValue then
				return false, string.format("Requires %s %d (you have %d)", stat, minValue, currentValue)
			end
		end
	end
	
	-- Check required flags (must have ALL)
	if choice.requiresFlags and type(choice.requiresFlags) == "table" then
		local flags = state.Flags or {}
		for _, reqFlag in ipairs(choice.requiresFlags) do
			if not flags[reqFlag] then
				return false, "Missing required flag: " .. reqFlag
			end
		end
	end
	
	-- Check single required flag
	if choice.requiresFlag and type(choice.requiresFlag) == "string" then
		local flags = state.Flags or {}
		if not flags[choice.requiresFlag] then
			return false, "Missing required flag: " .. choice.requiresFlag
		end
	end
	
	-- Check blocked flags (must NOT have ANY)
	if choice.blockedFlags and type(choice.blockedFlags) == "table" then
		local flags = state.Flags or {}
		for _, blockFlag in ipairs(choice.blockedFlags) do
			if flags[blockFlag] then
				return false, "Blocked by flag: " .. blockFlag
			end
		end
	end
	
	-- Check single blocked flag
	if choice.blockedFlag and type(choice.blockedFlag) == "string" then
		local flags = state.Flags or {}
		if flags[choice.blockedFlag] then
			return false, "Blocked by flag: " .. choice.blockedFlag
		end
	end
	
	return true, nil
end

function EventRunner.applyChoice(
	state: LifeState,
	eventDef: EventDef,
	choiceIndex: number,
	dynamicData: DynamicData?,
	minigameResult: boolean? -- nil = no minigame, true = won, false = lost
): (ApplyChoiceResults?, string?)
	if type(choiceIndex) ~= "number" then
		return nil, "choiceIndex must be a number"
	end

	if not eventDef or not eventDef.choices then
		return nil, "Invalid event definition"
	end

	local choice = eventDef.choices[choiceIndex]
	if not choice or type(choice) ~= "table" then
		return nil, "Invalid choice at index " .. tostring(choiceIndex)
	end

	local results = {
		effects = {},
		flagsSet = {},
		flagsCleared = {},
		minigameTriggered = nil,
		minigameConfig = nil,
		worldActions = nil,
		addAsset = nil,
		setJob = nil,
		resultText = "",
		wasSuccess = nil, -- Track if RNG roll succeeded
	}

	-- ═══════════════════════════════════════════════════════════════
	-- STEP 1: CHECK REQUIREMENTS
	-- ═══════════════════════════════════════════════════════════════
	local meetsRequirements, reqError = EventRunner.checkChoiceRequirements(state, choice)
	if not meetsRequirements then
		return nil, reqError
	end

	-- ═══════════════════════════════════════════════════════════════
	-- STEP 2: DETERMINE SUCCESS/FAIL (RNG or Minigame)
	-- ═══════════════════════════════════════════════════════════════
	local success = true -- Default to success
	local usedRNG = false
	
	-- If minigame was played, use that result
	if minigameResult ~= nil then
		success = minigameResult
	-- Otherwise check for chanceSuccess RNG
	elseif choice.chanceSuccess ~= nil and type(choice.chanceSuccess) == "number" then
		local roll = math.random()
		success = roll < choice.chanceSuccess
		usedRNG = true
		print(string.format("[EventRunner] RNG roll: %.2f vs chance %.2f = %s", roll, choice.chanceSuccess, success and "SUCCESS" or "FAIL"))
	end
	
	results.wasSuccess = success

	-- ═══════════════════════════════════════════════════════════════
	-- STEP 3: APPLY BASE EFFECTS (always applied)
	-- ═══════════════════════════════════════════════════════════════
	applyEffectsToState(state, choice.effects, results)

	-- ═══════════════════════════════════════════════════════════════
	-- STEP 4: APPLY SUCCESS OR FAIL EFFECTS
	-- ═══════════════════════════════════════════════════════════════
	if success then
		if choice.effectsOnSuccess then
			applyEffectsToState(state, choice.effectsOnSuccess, results)
		end
	else
		if choice.effectsOnFail then
			applyEffectsToState(state, choice.effectsOnFail, results)
		end
	end

	-- ═══════════════════════════════════════════════════════════════
	-- STEP 5: APPLY DYNAMIC EFFECTS CALLBACK
	-- ═══════════════════════════════════════════════════════════════
	-- effectsDynamic allows events to compute effects based on dynamicData
	-- Example: effectsDynamic = function(data) return { Money = data.amount } end
	if choice.effectsDynamic and dynamicData then
		local ok, dynamicEffects = pcall(choice.effectsDynamic, dynamicData)
		if ok and type(dynamicEffects) == "table" then
			applyEffectsToState(state, dynamicEffects, results)
		elseif not ok then
			warn("[EventRunner] effectsDynamic failed:", dynamicEffects)
		end
	end
	
	-- Legacy support: getDynamicMoney callback
	if choice.getDynamicMoney and dynamicData then
		local ok, amount = pcall(choice.getDynamicMoney, dynamicData)
		if ok and type(amount) == "number" then
			state.Money = (state.Money or 0) + amount
			results.effects.Money = (results.effects.Money or 0) + amount
		end
	end

	-- ═══════════════════════════════════════════════════════════════
	-- STEP 6: SET/CLEAR FLAGS
	-- ═══════════════════════════════════════════════════════════════
	state.Flags = state.Flags or {}
	
	-- Only set flags if succeeded (or if no RNG/minigame involved)
	if success or (not usedRNG and minigameResult == nil) then
		if choice.setFlag then
			state.Flags[choice.setFlag] = true
			table.insert(results.flagsSet, choice.setFlag)
		end
		if choice.setFlags and type(choice.setFlags) == "table" then
			for _, flag in ipairs(choice.setFlags) do
				state.Flags[flag] = true
				table.insert(results.flagsSet, flag)
			end
		end
	end
	
	-- Always process clear flags
	if choice.clearFlag then
		state.Flags[choice.clearFlag] = nil
		table.insert(results.flagsCleared, choice.clearFlag)
	end
	if choice.clearFlags and type(choice.clearFlags) == "table" then
		for _, flag in ipairs(choice.clearFlags) do
			state.Flags[flag] = nil
			table.insert(results.flagsCleared, flag)
		end
	end

	-- ═══════════════════════════════════════════════════════════════
	-- STEP 7: MINIGAME TRIGGER (for deferred resolution)
	-- ═══════════════════════════════════════════════════════════════
	if choice.minigame and minigameResult == nil then
		-- Minigame hasn't been played yet - flag it
		if type(choice.minigame) == "table" then
			results.minigameTriggered = choice.minigame.id or "generic"
			results.minigameConfig = choice.minigame
		else
			results.minigameTriggered = choice.minigame
			results.minigameConfig = { id = choice.minigame }
		end
	end
	
	-- ═══════════════════════════════════════════════════════════════
	-- STEP 8: WORLD ACTIONS (spawn pet, play sound, etc.)
	-- ═══════════════════════════════════════════════════════════════
	if success and choice.worldActions then
		results.worldActions = choice.worldActions
	end

	-- ═══════════════════════════════════════════════════════════════
	-- STEP 9: ADD ASSET (property, vehicle, item)
	-- ═══════════════════════════════════════════════════════════════
	if success and choice.addAsset then
		results.addAsset = choice.addAsset
	end

	-- ═══════════════════════════════════════════════════════════════
	-- STEP 10: SET JOB
	-- ═══════════════════════════════════════════════════════════════
	if success and choice.setJob then
		results.setJob = choice.setJob
	end

	-- ═══════════════════════════════════════════════════════════════
	-- STEP 11: ADD RELATIONSHIP (via RelationshipService)
	-- ═══════════════════════════════════════════════════════════════
	-- Uses RelationshipService for single source of truth
	if choice.addRelationship then
		local relData = choice.addRelationship
		
		-- Map categories/types to the 4 standard types
		local typeMapping = {
			-- Friend types
			friends = "friend", friend = "friend", best_friend = "friend",
			childhood_friend = "friend", school_friend = "friend", club_friend = "friend",
			camp_friend = "friend", daycare_friend = "friend", kindergarten_friend = "friend",
			study_buddy = "friend", neighbor = "friend", reformed_bully_friend = "friend",
			preschool_friend = "friend", classmates = "friend", coworkers = "friend",
			acquaintance = "friend", former_student = "friend", work_friend = "friend",
			college_friend = "friend", gym_buddy = "friend", online_friend = "friend",
			mentor = "friend", mentee = "friend",
			-- Romance types
			romance = "romance", lovers = "romance", partner = "romance",
			dating = "romance", spouse = "romance", interest = "romance",
			crush = "romance", ex = "romance", fiance = "romance",
			-- Family types
			family = "family", parent = "family", sibling = "family",
			child = "family", grandparent = "family", grandchild = "family",
			cousin = "family", aunt = "family", uncle = "family", in_law = "family",
			-- Enemy types
			enemies = "enemy", enemy = "enemy", rival = "enemy",
		}
		
		local category = relData.category or "friends"
		local relType = relData.type or category
		local standardType = typeMapping[relType] or typeMapping[category] or "friend"
		
		-- Get the name from dynamic data or use provided name
		local personName = relData.name
		if relData.dynamicNameKey and dynamicData and dynamicData[relData.dynamicNameKey] then
			personName = tostring(dynamicData[relData.dynamicNameKey])
		end
		
		-- Use RelationshipService to create the relationship
		local newPerson = RelationshipService.create(state, standardType, {
			name = personName,
			role = relData.role or (standardType == "friend" and "Friend" or standardType == "romance" and "Partner" or standardType == "family" and "Family" or "Rival"),
			relationship = relData.startingRelationship or 60,
			age = relData.age or state.Age or 18,
			subtype = relType,
			tags = {
				[relType] = true,
				[category] = true,
			},
		})
		
		results.relationshipAdded = newPerson
		results.relationshipId = newPerson.id
		
		-- Store the new ID in dynamicData for follow-up operations
		if relData.storeIdAs and dynamicData then
			dynamicData[relData.storeIdAs] = newPerson.id
		end
	end

	-- ═══════════════════════════════════════════════════════════════
	-- STEP 11b: CHANGE RELATIONSHIP (NEW!)
	-- ═══════════════════════════════════════════════════════════════
	-- For events that modify existing relationships (fight with friend, etc.)
	-- Usage: changeRelationship = { targetIdKey = "friendId", delta = -20, killIfBelow = 5 }
	if choice.changeRelationship then
		local cfg = choice.changeRelationship
		local targetRel = nil
		
		-- Try to get by ID from dynamicData
		if cfg.targetIdKey and dynamicData and dynamicData[cfg.targetIdKey] then
			local targetId = dynamicData[cfg.targetIdKey]
			targetRel = RelationshipService.get(state, targetId)
		end
		
		-- If no ID provided, pick a random one of the specified type
		if not targetRel and cfg.relType then
			targetRel = RelationshipService.pick(state, cfg.relType, cfg.filterFn)
		end
		
		-- Apply the change
		if targetRel then
			-- Apply delta to relationship value
			if cfg.delta then
				RelationshipService.delta(state, targetRel.id, cfg.delta)
			end
			
			-- Set relationship to specific value
			if cfg.setRelationship then
				RelationshipService.setRelationship(state, targetRel.id, cfg.setRelationship)
			end
			
			-- Kill/remove if below threshold
			if cfg.killIfBelow and targetRel.relationship <= cfg.killIfBelow then
				RelationshipService.kill(state, targetRel.id, cfg.killReason or "relationship_ended")
			end
			
			-- Remove entirely (unfriend, breakup)
			if cfg.remove then
				RelationshipService.remove(state, targetRel.id)
			end
			
			-- Update role
			if cfg.newRole then
				targetRel.role = cfg.newRole
			end
			
			-- Add/remove tags
			if cfg.addTag then
				RelationshipService.addTag(state, targetRel.id, cfg.addTag)
			end
			if cfg.removeTag then
				RelationshipService.removeTag(state, targetRel.id, cfg.removeTag)
			end
			
			results.relationshipChanged = targetRel
			print("[EventRunner] Changed relationship:", targetRel.id, "Name:", targetRel.name, "Delta:", cfg.delta or 0)
		else
			print("[EventRunner] Warning: changeRelationship couldn't find target relationship")
		end
	end

	-- ═══════════════════════════════════════════════════════════════
	-- STEP 11c: KILL RELATIONSHIP (convenience shortcut)
	-- ═══════════════════════════════════════════════════════════════
	-- Usage: killRelationship = { targetIdKey = "friendId", reason = "died" }
	if choice.killRelationship then
		local cfg = choice.killRelationship
		local targetId = nil
		
		if cfg.targetIdKey and dynamicData and dynamicData[cfg.targetIdKey] then
			targetId = dynamicData[cfg.targetIdKey]
		end
		
		if targetId then
			RelationshipService.kill(state, targetId, cfg.reason or "event")
			results.relationshipKilled = targetId
			print("[EventRunner] Killed relationship:", targetId)
		end
	end

	-- ═══════════════════════════════════════════════════════════════
	-- STEP 12: LIFEEVENTS FORMAT SUPPORT (career, assets, death, etc.)
	-- ═══════════════════════════════════════════════════════════════
	-- Load EventEngine for LifeEvents format support
	local EventEngine = nil
	pcall(function()
		local LifeEvents = script.Parent:FindFirstChild("LifeEvents")
		if LifeEvents then
			local ee = LifeEvents:FindFirstChild("EventEngine")
			if ee then
				EventEngine = require(ee)
			end
		end
	end)
	
	-- If EventEngine is available, use it to handle LifeEvents format fields
	-- This ensures all career, trait, and flag handling works correctly
	if EventEngine and EventEngine.applyChoiceEffects then
		local engineResults = EventEngine.applyChoiceEffects(choice, state)
		if engineResults then
			-- Merge flag changes
			if engineResults.flagsSet then
				for _, flag in ipairs(engineResults.flagsSet) do
					if not table.find(results.flagsSet, flag) then
						table.insert(results.flagsSet, flag)
					end
				end
			end
			if engineResults.flagsCleared then
				for _, flag in ipairs(engineResults.flagsCleared) do
					if not table.find(results.flagsCleared, flag) then
						table.insert(results.flagsCleared, flag)
					end
				end
			end
			-- Merge stat changes
			if engineResults.statChanges then
				for stat, change in pairs(engineResults.statChanges) do
					if change.change then
						results.effects[stat] = (results.effects[stat] or 0) + change.change
					end
				end
			end
			-- Add messages
			if engineResults.messages then
				for _, msg in ipairs(engineResults.messages) do
					-- Store for later use
				end
			end
		end
	else
		-- Fallback: Handle LifeEvents format fields manually if EventEngine not available
		-- Load CareerSystem directly
		local CareerSystem = nil
		pcall(function()
			local LifeEvents = script.Parent:FindFirstChild("LifeEvents")
			if LifeEvents then
				local cs = LifeEvents:FindFirstChild("CareerSystem")
				if cs then
					CareerSystem = require(cs)
				end
			end
		end)
		
		-- Handle LifeEvents format choice fields
		if success or (not usedRNG and minigameResult == nil) then
			-- Career management
			if choice.startCareer and CareerSystem then
				local success, msg = CareerSystem.startCareer(state, choice.startCareer)
				if success then
					print("[EventRunner] Started career:", choice.startCareer)
				end
			end
			
			if choice.careerBranch and CareerSystem then
				local success, msg = CareerSystem.setBranch(state, choice.careerBranch)
				if success then
					print("[EventRunner] Set career branch:", choice.careerBranch)
				end
			end
			
			if choice.careerXP and CareerSystem then
				CareerSystem.addXP(state, choice.careerXP)
			end
			
			if choice.careerReputation and CareerSystem then
				CareerSystem.addReputation(state, choice.careerReputation)
			end
			
			if choice.promoteCareer and CareerSystem then
				local success, msg = CareerSystem.promote(state)
				if success then
					print("[EventRunner] Promoted career:", msg)
				end
			end
			
			if choice.quitCareer and CareerSystem then
				local success, msg = CareerSystem.quitCareer(state)
				if success then
					print("[EventRunner] Quit career:", msg)
				end
			end
			
			-- LifeEvents format flags (flags.set / flags.clear) - only if not already handled
			if choice.flags and not (choice.setFlag or choice.setFlags) then
				if choice.flags.set then
					for _, flag in ipairs(choice.flags.set) do
						state.Flags[flag] = true
						if not table.find(results.flagsSet, flag) then
							table.insert(results.flagsSet, flag)
						end
					end
				end
				if choice.flags.clear then
					for _, flag in ipairs(choice.flags.clear) do
						state.Flags[flag] = nil
						if not table.find(results.flagsCleared, flag) then
							table.insert(results.flagsCleared, flag)
						end
					end
				end
			end
			
			-- LifeEvents format traits (traits.add / traits.remove / traits.resolve)
			if choice.traits then
				local TraitSystem = nil
				pcall(function()
					local ts = script.Parent:FindFirstChild("TraitSystem")
					if ts then
						TraitSystem = require(ts)
					end
				end)
				
				if TraitSystem then
					if choice.traits.add then
						for _, traitId in ipairs(choice.traits.add) do
							TraitSystem.AddTrait(state, traitId)
						end
					end
					if choice.traits.remove then
						for _, traitId in ipairs(choice.traits.remove) do
							TraitSystem.RemoveTrait(state, traitId)
						end
					end
					if choice.traits.resolve then
						local resolveResult = TraitSystem.ResolveTraits(state, choice.traits.resolve)
						if resolveResult and resolveResult.narrative then
							-- Narrative will be added to result text
						end
					end
				end
			end
		end
		
		-- Asset removal
		if choice.removeAsset then
			results.removeAsset = choice.removeAsset
		end
		
		-- Death risk (via Health stat reduction)
		if choice.deathRisk then
			local healthReduction = choice.deathRisk
			if type(healthReduction) == "number" then
				local currentHealth = (state.Stats and state.Stats.Health) or 100
				local newHealth = math.max(0, currentHealth - healthReduction)
				if not state.Stats then state.Stats = {} end
				state.Stats.Health = newHealth
				results.effects.Health = (results.effects.Health or 0) - healthReduction
				
				-- Check for death
				if newHealth <= 0 then
					results.deathTriggered = true
					results.deathCause = "event_health_loss"
				end
			end
		end
	end

	-- ═══════════════════════════════════════════════════════════════
	-- STEP 13: BUILD RESULT TEXT
	-- ═══════════════════════════════════════════════════════════════
	local explicitResultText: string? = nil
	
	-- Pick correct result text based on success/fail
	if success then
		local base = choice.resultTextSuccess or choice.resultText or choice.result
		if base then
			explicitResultText = EventRunner.processDynamicText(base, dynamicData)
		end
	else
		local base = choice.resultTextFail or choice.resultText or choice.result
		if base then
			explicitResultText = EventRunner.processDynamicText(base, dynamicData)
		end
		-- Add failure indicator if not in text
		if explicitResultText and not string.find(explicitResultText:lower(), "fail") and not string.find(explicitResultText:lower(), "didn't") then
			-- Text doesn't indicate failure, maybe add context
		end
	end

	-- Final narrative
	results.resultText = EventRunner.buildNarrativeText(
		state,
		eventDef,
		choice,
		results,
		dynamicData,
		explicitResultText
	)

	return results, nil
end

-- Filter choices based on requirements (for client to gray out unavailable options)
function EventRunner.filterAvailableChoices(state: LifeState, eventDef: EventDef): { [number]: { available: boolean, reason: string? } }
	local availability = {}
	
	if not eventDef or not eventDef.choices then
		return availability
	end
	
	for i, choice in ipairs(eventDef.choices) do
		local meetsReqs, reason = EventRunner.checkChoiceRequirements(state, choice)
		availability[i] = {
			available = meetsReqs,
			reason = reason
		}
	end
	
	return availability
end

----------------------------------------------------------------------
-- STORY PATHS / SPECIAL ACTIONS
----------------------------------------------------------------------

function EventRunner.getStoryPaths(state: LifeState): StoryPaths
	local flags = state and state.Flags or {}

	local paths: StoryPaths = {
		political = {
			active = (flags and (flags.political_interest or flags.elected_official)) or false,
			level = "None",
			progress = 0,
			milestones = {},
		},
		criminal = {
			active = (flags and (flags.criminal_tendencies or flags.gang_member)) or false,
			level = "None",
			progress = 0,
			milestones = {},
		},
		celebrity = {
			active = (flags and (flags.famous or flags.influencer or flags.actor or flags.musician)) or false,
			level = "None",
			progress = 0,
			milestones = {},
		},
		business = {
			active = (flags and (flags.entrepreneur or flags.ceo)) or false,
			level = "None",
			progress = 0,
			milestones = {},
		},
	}

	-- Political career progression
	if flags and flags.president then
		paths.political.level = "President"
		paths.political.progress = 100
		paths.political.milestones = {
			"political_interest",
			"political_experience",
			"elected_official",
			"state_senator",
			"congressman",
			"us_senator",
			"president",
		}
	elseif flags and flags.vice_president then
		paths.political.level = "Vice President"
		paths.political.progress = 95
	elseif flags and flags.us_senator then
		paths.political.level = "U.S. Senator"
		paths.political.progress = 85
	elseif flags and flags.congressman then
		paths.political.level = "Congressman"
		paths.political.progress = 70
	elseif flags and flags.governor then
		paths.political.level = "Governor"
		paths.political.progress = 65
	elseif flags and flags.state_senator then
		paths.political.level = "State Senator"
		paths.political.progress = 50
	elseif flags and flags.state_representative then
		paths.political.level = "State Rep."
		paths.political.progress = 40
	elseif flags and flags.mayor then
		paths.political.level = "Mayor"
		paths.political.progress = 35
	elseif flags and flags.city_council then
		paths.political.level = "City Council"
		paths.political.progress = 30
	elseif flags and flags.elected_official then
		paths.political.level = "Local Official"
		paths.political.progress = 25
	elseif flags and flags.political_experience then
		paths.political.level = "Political Intern"
		paths.political.progress = 15
	elseif flags and flags.political_volunteer then
		paths.political.level = "Volunteer"
		paths.political.progress = 10
	elseif flags and flags.political_interest then
		paths.political.level = "Interested"
		paths.political.progress = 5
	end

	-- Criminal career progression
	if flags and flags.kingpin then
		paths.criminal.level = "Kingpin"
		paths.criminal.progress = 100
	elseif flags and flags.crime_boss then
		paths.criminal.level = "Crime Boss"
		paths.criminal.progress = 90
	elseif flags and flags.underboss then
		paths.criminal.level = "Underboss"
		paths.criminal.progress = 75
	elseif flags and flags.gang_captain then
		paths.criminal.level = "Gang Captain"
		paths.criminal.progress = 60
	elseif flags and flags.gang_member and flags.war_veteran then
		paths.criminal.level = "Made Member"
		paths.criminal.progress = 50
	elseif flags and flags.gang_member then
		paths.criminal.level = "Gang Member"
		paths.criminal.progress = 40
	elseif flags and flags.gang_prospect then
		paths.criminal.level = "Prospect"
		paths.criminal.progress = 30
	elseif flags and flags.drug_dealer then
		paths.criminal.level = "Drug Dealer"
		paths.criminal.progress = 25
	elseif flags and (flags.car_thief or flags.burglar) then
		paths.criminal.level = "Thief"
		paths.criminal.progress = 20
	elseif flags and (flags.petty_thief or flags.shoplifter) then
		paths.criminal.level = "Petty Criminal"
		paths.criminal.progress = 10
	elseif flags and flags.criminal_tendencies then
		paths.criminal.level = "Delinquent"
		paths.criminal.progress = 5
	end

	-- Celebrity career progression
	if flags and flags.famous and (flags.actor or flags.musician or flags.author) then
		paths.celebrity.level = "A-List Celebrity"
		paths.celebrity.progress = 100
	elseif flags and flags.famous then
		paths.celebrity.level = "Famous"
		paths.celebrity.progress = 75
	elseif flags and flags.influencer then
		paths.celebrity.level = "Influencer"
		paths.celebrity.progress = 50
	elseif flags and (flags.actor or flags.musician or flags.author) then
		paths.celebrity.level = "Artist"
		paths.celebrity.progress = 30
	end

	-- Business career progression
	if flags and flags.billionaire then
		paths.business.level = "Billionaire"
		paths.business.progress = 100
	elseif flags and flags.ceo and flags.millionaire then
		paths.business.level = "CEO Mogul"
		paths.business.progress = 85
	elseif flags and flags.ceo then
		paths.business.level = "CEO"
		paths.business.progress = 70
	elseif flags and flags.entrepreneur and flags.millionaire then
		paths.business.level = "Successful Entrepreneur"
		paths.business.progress = 60
	elseif flags and flags.entrepreneur then
		paths.business.level = "Entrepreneur"
		paths.business.progress = 40
	elseif flags and flags.self_made then
		paths.business.level = "Self-Made"
		paths.business.progress = 25
	end

	return paths
end

function EventRunner.getSpecialActions(state: LifeState): { SpecialAction }
	local flags = state and state.Flags or {}
	local actions: { SpecialAction } = {}

	-- Political actions
	if flags and flags.elected_official then
		table.insert(actions, { id = "campaign", name = "Campaign", emoji = "📢", type = "political", description = "Run a campaign to gain support" })
	end
	if flags and (flags.state_senator or flags.congressman or flags.us_senator) then
		table.insert(actions, { id = "propose_bill", name = "Propose Bill", emoji = "📜", type = "political", description = "Introduce legislation" })
		table.insert(actions, { id = "filibuster", name = "Filibuster", emoji = "🎤", type = "political", description = "Block opposition bills" })
	end
	if flags and (flags.governor or flags.president) then
		table.insert(actions, { id = "executive_order", name = "Executive Order", emoji = "✍️", type = "political", description = "Issue an executive order" })
	end
	if flags and flags.president then
		table.insert(actions, { id = "address_nation", name = "Address Nation", emoji = "📺", type = "political", description = "Give a national address" })
		table.insert(actions, { id = "veto_bill", name = "Veto Bill", emoji = "🚫", type = "political", description = "Veto a congressional bill" })
		table.insert(actions, { id = "pardon", name = "Grant Pardon", emoji = "⚖️", type = "political", description = "Pardon someone" })
	end

	-- Criminal actions
	if flags and flags.criminal_tendencies then
		table.insert(actions, { id = "pickpocket", name = "Pickpocket", emoji = "🖐️", type = "criminal", description = "Steal from someone's pocket" })
		table.insert(actions, { id = "shoplift", name = "Shoplift", emoji = "🛒", type = "criminal", description = "Steal from a store" })
	end
	if flags and (flags.car_thief or flags.burglar) then
		table.insert(actions, { id = "steal_car", name = "Steal Car", emoji = "🚗", type = "criminal", description = "Steal a vehicle" })
		table.insert(actions, { id = "burglary", name = "Burglary", emoji = "🏠", type = "criminal", description = "Break into a home" })
	end
	if flags and flags.gang_member then
		table.insert(actions, { id = "collect_debts", name = "Collect Debts", emoji = "💰", type = "criminal", description = "Collect money owed to the gang" })
		table.insert(actions, { id = "expand_territory", name = "Expand Territory", emoji = "🗺️", type = "criminal", description = "Claim new turf" })
		table.insert(actions, { id = "gang_war", name = "Gang War", emoji = "⚔️", type = "criminal", description = "Attack rival gang" })
	end
	if flags and (flags.underboss or flags.crime_boss) then
		table.insert(actions, { id = "launder_money", name = "Launder Money", emoji = "🏦", type = "criminal", description = "Clean dirty money" })
		table.insert(actions, { id = "order_hit", name = "Order a Hit", emoji = "🎯", type = "criminal", description = "Have someone eliminated" })
		table.insert(actions, { id = "bribe_official", name = "Bribe Official", emoji = "💵", type = "criminal", description = "Pay off law enforcement" })
	end
	if flags and flags.crime_boss then
		table.insert(actions, { id = "hold_meeting", name = "Hold Meeting", emoji = "🤝", type = "criminal", description = "Meet with other bosses" })
		table.insert(actions, { id = "go_legit", name = "Go Legitimate", emoji = "📑", type = "criminal", description = "Try to leave the criminal life" })
	end

	-- Celebrity actions
	if flags and (flags.famous or flags.influencer) then
		table.insert(actions, { id = "post_social", name = "Post Content", emoji = "📱", type = "celebrity", description = "Post on social media" })
		table.insert(actions, { id = "endorsement", name = "Brand Deal", emoji = "💸", type = "celebrity", description = "Accept a brand endorsement" })
	end
	if flags and flags.actor then
		table.insert(actions, { id = "audition", name = "Audition", emoji = "🎬", type = "celebrity", description = "Try out for a role" })
	end
	if flags and flags.musician then
		table.insert(actions, { id = "release_album", name = "Release Album", emoji = "💿", type = "celebrity", description = "Drop new music" })
		table.insert(actions, { id = "concert", name = "Concert", emoji = "🎸", type = "celebrity", description = "Perform live" })
	end

	-- Business actions
	if flags and flags.entrepreneur then
		table.insert(actions, { id = "expand_business", name = "Expand Business", emoji = "📈", type = "business", description = "Grow your company" })
		table.insert(actions, { id = "hire_employees", name = "Hire Staff", emoji = "👥", type = "business", description = "Build your team" })
	end
	if flags and flags.ceo then
		table.insert(actions, { id = "merger", name = "Merger", emoji = "🤝", type = "business", description = "Merge with another company" })
		table.insert(actions, { id = "ipo", name = "Go Public", emoji = "📊", type = "business", description = "Take company public" })
	end
	if flags and (flags.millionaire or flags.billionaire) then
		table.insert(actions, { id = "invest", name = "Invest", emoji = "💎", type = "business", description = "Make an investment" })
		table.insert(actions, { id = "charity", name = "Donate", emoji = "❤️", type = "business", description = "Give to charity" })
	end

	return actions
end

return EventRunner
