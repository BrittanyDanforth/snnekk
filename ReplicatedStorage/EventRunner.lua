-- EventRunner.lua
-- Ultra-polished life event engine + narrative builder
-- Uses NarrativeContent module for BitLife-style rich text generation

local EventRunner = {}

----------------------------------------------------------------------
-- LOAD NARRATIVE CONTENT
----------------------------------------------------------------------

local NarrativeContent = require(script.Parent:WaitForChild("NarrativeContent"))

local StatNarrative = NarrativeContent.StatNarrative
local MoneyNarrative = NarrativeContent.MoneyNarrative
local FlagDescriptions = NarrativeContent.FlagDescriptions
local YearRecapTemplates = NarrativeContent.YearRecapTemplates
local CategoryFlavor = NarrativeContent.CategoryFlavor
local LifeStageTransitions = NarrativeContent.LifeStageTransitions
local RelationshipLines = NarrativeContent.RelationshipLines

----------------------------------------------------------------------
-- INTERNAL HELPERS / UTILITIES
----------------------------------------------------------------------

local function formatMoney(n: number): string
	if not n then return "$0" end
	
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

local function pickRandom(list)
	if not list or #list == 0 then return nil end
	return list[math.random(1, #list)]
end

local function clampStat(val)
	return math.clamp(val or 50, 0, 100)
end

local function getStatSnapshot(state)
	local stats = state.Stats or {}
	return {
		Money     = state.Money or 0,
		Happiness = stats.Happiness or state.Happiness or 50,
		Health    = stats.Health or state.Health or 50,
		Smarts    = stats.Smarts or state.Smarts or 50,
		Looks     = stats.Looks or state.Looks or 50,
	}
end

local function getLifeStage(age)
	if age <= 1 then return "baby"
	elseif age <= 4 then return "toddler"
	elseif age <= 9 then return "early_childhood"
	elseif age <= 12 then return "childhood"
	elseif age <= 15 then return "tween"
	elseif age <= 19 then return "teenage"
	elseif age <= 35 then return "young_adult"
	elseif age <= 60 then return "adult"
	elseif age <= 80 then return "senior"
	else return "elderly"
	end
end

local function classifyMagnitude(deltaAbs: number): string
	if deltaAbs >= 30 then return "huge"
	elseif deltaAbs >= 15 then return "big"
	elseif deltaAbs >= 7 then return "medium"
	else return "small"
	end
end

----------------------------------------------------------------------
-- NARRATIVE BUILDERS
----------------------------------------------------------------------

local function describeStatLine(statKey: string, delta: number, finalValue: number?): string?
	if not delta or delta == 0 then return nil end
	
	local statTable = StatNarrative[statKey]
	if not statTable then return nil end
	
	local direction = (delta > 0) and "up" or "down"
	local absDelta = math.abs(delta)
	local bucket = classifyMagnitude(absDelta)
	
	local bucketTable = statTable[direction] and statTable[direction][bucket]
	if not bucketTable or #bucketTable == 0 then return nil end
	
	local template = pickRandom(bucketTable)
	if not template then return nil end
	
	finalValue = clampStat(finalValue or 50)
	return string.format(template, absDelta, finalValue)
end

local function describeMoneyLine(delta: number, finalMoney: number?): string?
	if not delta or delta == 0 then return nil end
	
	local direction = (delta > 0) and "gain" or "loss"
	local absDelta = math.abs(delta)
	
	local bucket
	if absDelta >= 50_000 then bucket = "large"
	elseif absDelta >= 5_000 then bucket = "medium"
	else bucket = "small"
	end
	
	local dirTable = MoneyNarrative[direction]
	local bucketTbl = dirTable and dirTable[bucket]
	if not bucketTbl or #bucketTbl == 0 then return nil end
	
	local template = pickRandom(bucketTbl)
	if not template then return nil end
	
	local amountStr = formatMoney(absDelta)
	local totalStr = formatMoney(finalMoney or 0)
	
	return string.format(template, amountStr, totalStr)
end

local function describeFlags(flagsSet, flagsCleared)
	local lines = {}
	
	if flagsSet and #flagsSet > 0 then
		for _, flag in ipairs(flagsSet) do
			local desc = FlagDescriptions[flag]
			if desc then
				table.insert(lines, desc)
			else
				table.insert(lines, "Something in your life shifted (" .. flag .. ").")
			end
		end
	end
	
	if flagsCleared and #flagsCleared > 0 then
		for _, flag in ipairs(flagsCleared) do
			local desc = FlagDescriptions[flag]
			if desc then
				table.insert(lines, "That chapter seems to be over: " .. desc)
			else
				table.insert(lines, "A previous lifestyle faded out (" .. flag .. ").")
			end
		end
	end
	
	return lines
end

local function getCategoryFlavor(category)
	if not category or not CategoryFlavor[category] then return nil end
	return pickRandom(CategoryFlavor[category])
end

local function getYearRecap(state)
	if not YearRecapTemplates then return nil end
	
	local flags = state.Flags or {}
	local age = state.Age or 0
	local lifeStage = getLifeStage(age)
	
	-- Prioritize special paths over life stage
	local bucket
	if flags.crime_boss or flags.underboss or flags.gang_member or flags.criminal_tendencies then
		bucket = "criminal_path"
	elseif flags.president or flags.us_senator or flags.congressman or flags.state_senator or flags.elected_official or flags.political_interest then
		bucket = "political_path"
	elseif flags.married or flags.engaged or flags.in_love then
		bucket = "romantic_path"
	elseif flags.millionaire or flags.billionaire then
		bucket = "wealthy_path"
	elseif flags.bankrupt or flags.homeless or flags.unemployed then
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

function EventRunner.buildNarrativeText(state, eventDef, choice, results, dynamicData, explicitResultText)
	local lines = {}
	
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
	
	-- 5) Category flavor text
	if eventDef and eventDef.category then
		local flavor = getCategoryFlavor(eventDef.category)
		if flavor then
			table.insert(lines, flavor)
		end
	end
	
	return table.concat(lines, "\n")
end

-- Build a full year recap (BitLife-style summary)
function EventRunner.buildYearRecap(state)
	return getYearRecap(state)
end

-- Get life stage for UI display
function EventRunner.getLifeStage(age)
	return getLifeStage(age)
end

-- Format money for display
function EventRunner.formatMoney(amount)
	return formatMoney(amount)
end

----------------------------------------------------------------------
-- HISTORY / EVENT PICKING
----------------------------------------------------------------------

function EventRunner.initHistory(state)
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
	return state.EventHistory
end

function EventRunner.canEventFire(state, eventDef)
	local history = state.EventHistory or {}
	local age = state.Age or 0
	
	if eventDef.minAge and age < eventDef.minAge then return false end
	if eventDef.maxAge and age > eventDef.maxAge then return false end
	
	if eventDef.oneTime then
		if history.seenEvents and history.seenEvents[eventDef.id] then
			return false
		end
	end
	
	if eventDef.cooldown and history.lastOccurrence then
		local lastAge = history.lastOccurrence[eventDef.id]
		if lastAge and (age - lastAge) < eventDef.cooldown then
			return false
		end
	end
	
	if eventDef.requires then
		local ok, canFire = pcall(eventDef.requires, state)
		if not ok or not canFire then
			return false
		end
	end
	
	return true
end

function EventRunner.getMilestoneEvent(state, events)
	local history = state.EventHistory or {}
	
	for _, event in ipairs(events) do
		if event.milestone and EventRunner.canEventFire(state, event) then
			if not (history.milestonesFired and history.milestonesFired[event.id]) then
				return event
			end
		end
	end
	
	return nil
end

function EventRunner.pickRandomEvent(state, events)
	local eligible = {}
	local totalWeight = 0
	
	for _, event in ipairs(events) do
		if not event.milestone and EventRunner.canEventFire(state, event) then
			table.insert(eligible, event)
			totalWeight += (event.weight or 10)
		end
	end
	
	if #eligible == 0 then return nil end
	
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

function EventRunner.pickEvent(state, events)
	local milestone = EventRunner.getMilestoneEvent(state, events)
	if milestone then
		return milestone
	end
	return EventRunner.pickRandomEvent(state, events)
end

function EventRunner.markEventOccurred(state, eventDef)
	local history = state.EventHistory
	if not history then return end
	
	history.seenEvents = history.seenEvents or {}
	history.seenEvents[eventDef.id] = true
	
	history.lastOccurrence = history.lastOccurrence or {}
	history.lastOccurrence[eventDef.id] = state.Age
	
	if eventDef.milestone then
		history.milestonesFired = history.milestonesFired or {}
		history.milestonesFired[eventDef.id] = true
	end
end

----------------------------------------------------------------------
-- DYNAMIC TEXT (PLACEHOLDERS)
----------------------------------------------------------------------

function EventRunner.processDynamicText(text, dynamicData)
	if not text or not dynamicData then return text end
	
	local result = text
	for key, value in pairs(dynamicData) do
		if type(value) == "table" then
			for subKey, subValue in pairs(value) do
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

function EventRunner.buildClientPayload(eventDef, state)
	local dynamicData = {}
	
	if eventDef.getDynamicData then
		local ok, data = pcall(eventDef.getDynamicData, state)
		if ok and data then
			dynamicData = data
		end
	end
	
	local processedText = EventRunner.processDynamicText(eventDef.text, dynamicData)
	
	local processedChoices = {}
	for i, choice in ipairs(eventDef.choices or {}) do
		local choiceText = EventRunner.processDynamicText(choice.text, dynamicData)
		local resultText = EventRunner.processDynamicText(choice.result or choice.resultText, dynamicData)
		
		table.insert(processedChoices, {
			index     = i,
			text      = choiceText,
			result    = resultText,
			effects   = choice.effects,
			setFlag   = choice.setFlag,
			clearFlag = choice.clearFlag,
			minigame  = choice.minigame,
			outcome   = choice.outcome,
		})
	end
	
	return {
		id          = eventDef.id,
		emoji       = eventDef.emoji,
		title       = eventDef.title,
		text        = processedText,
		category    = eventDef.category,
		choices     = processedChoices,
		hasMinigame = eventDef.minigame ~= nil,
		minigameType = eventDef.minigame,
	}, dynamicData
end

----------------------------------------------------------------------
-- APPLY CHOICE + EFFECTS + NARRATIVE
----------------------------------------------------------------------

function EventRunner.applyChoice(state, eventDef, choiceIndex, dynamicData)
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
		resultText = "",
	}
	
	-- Apply stat / money effects
	if choice.effects and type(choice.effects) == "table" then
		for stat, delta in pairs(choice.effects) do
			if type(delta) == "number" then
				if stat == "Money" then
					state.Money = (state.Money or 0) + delta
					results.effects.Money = (results.effects.Money or 0) + delta
				elseif stat == "Happiness" then
					local newVal = clampStat((state.Stats and state.Stats.Happiness or state.Happiness or 50) + delta)
					if state.Stats then state.Stats.Happiness = newVal end
					state.Happiness = newVal
					results.effects.Happiness = (results.effects.Happiness or 0) + delta
				elseif stat == "Health" then
					local newVal = clampStat((state.Stats and state.Stats.Health or state.Health or 50) + delta)
					if state.Stats then state.Stats.Health = newVal end
					state.Health = newVal
					results.effects.Health = (results.effects.Health or 0) + delta
				elseif stat == "Smarts" then
					local newVal = clampStat((state.Stats and state.Stats.Smarts or state.Smarts or 50) + delta)
					if state.Stats then state.Stats.Smarts = newVal end
					state.Smarts = newVal
					results.effects.Smarts = (results.effects.Smarts or 0) + delta
				elseif stat == "Looks" then
					local newVal = clampStat((state.Stats and state.Stats.Looks or state.Looks or 50) + delta)
					if state.Stats then state.Stats.Looks = newVal end
					state.Looks = newVal
					results.effects.Looks = (results.effects.Looks or 0) + delta
				end
			end
		end
	end
	
	-- Apply dynamic money callback if present
	if choice.getDynamicMoney and dynamicData then
		local ok, amount = pcall(choice.getDynamicMoney, dynamicData)
		if ok and type(amount) == "number" then
			state.Money = (state.Money or 0) + amount
			results.effects.Money = (results.effects.Money or 0) + amount
		end
	end
	
	-- Set flags
	if choice.setFlag then
		state.Flags = state.Flags or {}
		state.Flags[choice.setFlag] = true
		table.insert(results.flagsSet, choice.setFlag)
	end
	
	-- Set multiple flags
	if choice.setFlags and type(choice.setFlags) == "table" then
		state.Flags = state.Flags or {}
		for _, flag in ipairs(choice.setFlags) do
			state.Flags[flag] = true
			table.insert(results.flagsSet, flag)
		end
	end
	
	-- Clear flags
	if choice.clearFlag then
		state.Flags = state.Flags or {}
		state.Flags[choice.clearFlag] = nil
		table.insert(results.flagsCleared, choice.clearFlag)
	end
	
	-- Clear multiple flags
	if choice.clearFlags and type(choice.clearFlags) == "table" then
		state.Flags = state.Flags or {}
		for _, flag in ipairs(choice.clearFlags) do
			state.Flags[flag] = nil
			table.insert(results.flagsCleared, flag)
		end
	end
	
	-- Minigame trigger (if any)
	if choice.minigame then
		results.minigameTriggered = choice.minigame
	end
	
	-- Explicit result text from choice, if given
	local explicitResultText
	if choice.result or choice.resultText then
		explicitResultText = EventRunner.processDynamicText(choice.result or choice.resultText, dynamicData)
	end
	
	-- Final narrative that the client will show in the life feed
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

----------------------------------------------------------------------
-- STORY PATHS / SPECIAL ACTIONS
----------------------------------------------------------------------

function EventRunner.getStoryPaths(state)
	local flags = state and state.Flags or {}
	
	local paths = {
		political = {
			active = flags.political_interest or flags.elected_official or false,
			level = "None",
			progress = 0,
			milestones = {},
		},
		criminal = {
			active = flags.criminal_tendencies or flags.gang_member or false,
			level = "None",
			progress = 0,
			milestones = {},
		},
		celebrity = {
			active = flags.famous or flags.influencer or flags.actor or flags.musician or false,
			level = "None",
			progress = 0,
			milestones = {},
		},
		business = {
			active = flags.entrepreneur or flags.ceo or false,
			level = "None",
			progress = 0,
			milestones = {},
		},
	}
	
	-- Political career progression
	if flags.president then
		paths.political.level = "President"
		paths.political.progress = 100
		paths.political.milestones = {"political_interest", "political_experience", "elected_official", "state_senator", "congressman", "us_senator", "president"}
	elseif flags.vice_president then
		paths.political.level = "Vice President"
		paths.political.progress = 95
	elseif flags.us_senator then
		paths.political.level = "U.S. Senator"
		paths.political.progress = 85
	elseif flags.congressman then
		paths.political.level = "Congressman"
		paths.political.progress = 70
	elseif flags.governor then
		paths.political.level = "Governor"
		paths.political.progress = 65
	elseif flags.state_senator then
		paths.political.level = "State Senator"
		paths.political.progress = 50
	elseif flags.state_representative then
		paths.political.level = "State Rep."
		paths.political.progress = 40
	elseif flags.mayor then
		paths.political.level = "Mayor"
		paths.political.progress = 35
	elseif flags.city_council then
		paths.political.level = "City Council"
		paths.political.progress = 30
	elseif flags.elected_official then
		paths.political.level = "Local Official"
		paths.political.progress = 25
	elseif flags.political_experience then
		paths.political.level = "Political Intern"
		paths.political.progress = 15
	elseif flags.political_volunteer then
		paths.political.level = "Volunteer"
		paths.political.progress = 10
	elseif flags.political_interest then
		paths.political.level = "Interested"
		paths.political.progress = 5
	end
	
	-- Criminal career progression
	if flags.kingpin then
		paths.criminal.level = "Kingpin"
		paths.criminal.progress = 100
	elseif flags.crime_boss then
		paths.criminal.level = "Crime Boss"
		paths.criminal.progress = 90
	elseif flags.underboss then
		paths.criminal.level = "Underboss"
		paths.criminal.progress = 75
	elseif flags.gang_captain then
		paths.criminal.level = "Gang Captain"
		paths.criminal.progress = 60
	elseif flags.gang_member and flags.war_veteran then
		paths.criminal.level = "Made Member"
		paths.criminal.progress = 50
	elseif flags.gang_member then
		paths.criminal.level = "Gang Member"
		paths.criminal.progress = 40
	elseif flags.gang_prospect then
		paths.criminal.level = "Prospect"
		paths.criminal.progress = 30
	elseif flags.drug_dealer then
		paths.criminal.level = "Drug Dealer"
		paths.criminal.progress = 25
	elseif flags.car_thief or flags.burglar then
		paths.criminal.level = "Thief"
		paths.criminal.progress = 20
	elseif flags.petty_thief or flags.shoplifter then
		paths.criminal.level = "Petty Criminal"
		paths.criminal.progress = 10
	elseif flags.criminal_tendencies then
		paths.criminal.level = "Delinquent"
		paths.criminal.progress = 5
	end
	
	-- Celebrity career progression
	if flags.famous and (flags.actor or flags.musician or flags.author) then
		paths.celebrity.level = "A-List Celebrity"
		paths.celebrity.progress = 100
	elseif flags.famous then
		paths.celebrity.level = "Famous"
		paths.celebrity.progress = 75
	elseif flags.influencer then
		paths.celebrity.level = "Influencer"
		paths.celebrity.progress = 50
	elseif flags.actor or flags.musician or flags.author then
		paths.celebrity.level = "Artist"
		paths.celebrity.progress = 30
	end
	
	-- Business career progression
	if flags.billionaire then
		paths.business.level = "Billionaire"
		paths.business.progress = 100
	elseif flags.ceo and flags.millionaire then
		paths.business.level = "CEO Mogul"
		paths.business.progress = 85
	elseif flags.ceo then
		paths.business.level = "CEO"
		paths.business.progress = 70
	elseif flags.entrepreneur and flags.millionaire then
		paths.business.level = "Successful Entrepreneur"
		paths.business.progress = 60
	elseif flags.entrepreneur then
		paths.business.level = "Entrepreneur"
		paths.business.progress = 40
	elseif flags.self_made then
		paths.business.level = "Self-Made"
		paths.business.progress = 25
	end
	
	return paths
end

function EventRunner.getSpecialActions(state)
	local flags = state and state.Flags or {}
	local actions = {}
	
	-- Political actions
	if flags.elected_official then
		table.insert(actions, { id = "campaign", name = "Campaign", emoji = "📢", type = "political", description = "Run a campaign to gain support" })
	end
	if flags.state_senator or flags.congressman or flags.us_senator then
		table.insert(actions, { id = "propose_bill", name = "Propose Bill", emoji = "📜", type = "political", description = "Introduce legislation" })
		table.insert(actions, { id = "filibuster", name = "Filibuster", emoji = "🎤", type = "political", description = "Block opposition bills" })
	end
	if flags.governor or flags.president then
		table.insert(actions, { id = "executive_order", name = "Executive Order", emoji = "✍️", type = "political", description = "Issue an executive order" })
	end
	if flags.president then
		table.insert(actions, { id = "address_nation", name = "Address Nation", emoji = "📺", type = "political", description = "Give a national address" })
		table.insert(actions, { id = "veto_bill", name = "Veto Bill", emoji = "🚫", type = "political", description = "Veto a congressional bill" })
		table.insert(actions, { id = "pardon", name = "Grant Pardon", emoji = "⚖️", type = "political", description = "Pardon someone" })
	end
	
	-- Criminal actions
	if flags.criminal_tendencies then
		table.insert(actions, { id = "pickpocket", name = "Pickpocket", emoji = "🖐️", type = "criminal", description = "Steal from someone's pocket" })
		table.insert(actions, { id = "shoplift", name = "Shoplift", emoji = "🛒", type = "criminal", description = "Steal from a store" })
	end
	if flags.car_thief or flags.burglar then
		table.insert(actions, { id = "steal_car", name = "Steal Car", emoji = "🚗", type = "criminal", description = "Steal a vehicle" })
		table.insert(actions, { id = "burglary", name = "Burglary", emoji = "🏠", type = "criminal", description = "Break into a home" })
	end
	if flags.gang_member then
		table.insert(actions, { id = "collect_debts", name = "Collect Debts", emoji = "💰", type = "criminal", description = "Collect money owed to the gang" })
		table.insert(actions, { id = "expand_territory", name = "Expand Territory", emoji = "🗺️", type = "criminal", description = "Claim new turf" })
		table.insert(actions, { id = "gang_war", name = "Gang War", emoji = "⚔️", type = "criminal", description = "Attack rival gang" })
	end
	if flags.underboss or flags.crime_boss then
		table.insert(actions, { id = "launder_money", name = "Launder Money", emoji = "🏦", type = "criminal", description = "Clean dirty money" })
		table.insert(actions, { id = "order_hit", name = "Order a Hit", emoji = "🎯", type = "criminal", description = "Have someone eliminated" })
		table.insert(actions, { id = "bribe_official", name = "Bribe Official", emoji = "💵", type = "criminal", description = "Pay off law enforcement" })
	end
	if flags.crime_boss then
		table.insert(actions, { id = "hold_meeting", name = "Hold Meeting", emoji = "🤝", type = "criminal", description = "Meet with other bosses" })
		table.insert(actions, { id = "go_legit", name = "Go Legitimate", emoji = "📑", type = "criminal", description = "Try to leave the criminal life" })
	end
	
	-- Celebrity actions
	if flags.famous or flags.influencer then
		table.insert(actions, { id = "post_social", name = "Post Content", emoji = "📱", type = "celebrity", description = "Post on social media" })
		table.insert(actions, { id = "endorsement", name = "Brand Deal", emoji = "💸", type = "celebrity", description = "Accept a brand endorsement" })
	end
	if flags.actor then
		table.insert(actions, { id = "audition", name = "Audition", emoji = "🎬", type = "celebrity", description = "Try out for a role" })
	end
	if flags.musician then
		table.insert(actions, { id = "release_album", name = "Release Album", emoji = "💿", type = "celebrity", description = "Drop new music" })
		table.insert(actions, { id = "concert", name = "Concert", emoji = "🎸", type = "celebrity", description = "Perform live" })
	end
	
	-- Business actions
	if flags.entrepreneur then
		table.insert(actions, { id = "expand_business", name = "Expand Business", emoji = "📈", type = "business", description = "Grow your company" })
		table.insert(actions, { id = "hire_employees", name = "Hire Staff", emoji = "👥", type = "business", description = "Build your team" })
	end
	if flags.ceo then
		table.insert(actions, { id = "merger", name = "Merger", emoji = "🤝", type = "business", description = "Merge with another company" })
		table.insert(actions, { id = "ipo", name = "Go Public", emoji = "📊", type = "business", description = "Take company public" })
	end
	if flags.millionaire or flags.billionaire then
		table.insert(actions, { id = "invest", name = "Invest", emoji = "💎", type = "business", description = "Make an investment" })
		table.insert(actions, { id = "charity", name = "Donate", emoji = "❤️", type = "business", description = "Give to charity" })
	end
	
	return actions
end

return EventRunner
