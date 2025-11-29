-- EventRunner.lua
-- Ultra-polished life event engine + narrative builder
-- Keeps the same public API but generates rich BitLife-style feed text.

local EventRunner = {}

----------------------------------------------------------------------
-- INTERNAL HELPERS / UTILITIES
----------------------------------------------------------------------

local function formatMoney(n: number): string
	if not n then
		return "$0"
	end

	if n >= 1_000_000_000 then
		return string.format("$%.1fB", n / 1_000_000_000)
	elseif n >= 1_000_000 then
		return string.format("$%.1fM", n / 1_000_000)
	elseif n >= 1_000 then
		return string.format("$%.1fK", n / 1_000)
	else
		return "$" .. tostring(math.floor(n))
	end
end

local function pickRandom(list)
	if not list or #list == 0 then
		return nil
	end
	return list[math.random(1, #list)]
end

local function clampStat(val)
	return math.clamp(val or 50, 0, 100)
end

local function getStatSnapshot(state)
	-- Snapshot AFTER effects so we can reference final values for text.
	local stats = state.Stats or {}

	return {
		Money      = state.Money or 0,
		Happiness  = stats.Happiness or state.Happiness or 50,
		Health     = stats.Health or state.Health or 50,
		Smarts     = stats.Smarts or state.Smarts or 50,
		Looks      = stats.Looks or state.Looks or 50,
	}
end

----------------------------------------------------------------------
-- NARRATIVE TABLES
----------------------------------------------------------------------

-- Phrases are intentionally redundant in structure but varied in flavor.
-- We assemble multiple of these into paragraphs.

local StatNarrative = {
	Happiness = {
		up = {
			small = {
				"Your happiness ticked up a bit (+%d%%, now %d%%).",
				"You're feeling a little more cheerful (+%d%%, now %d%%).",
			},
			medium = {
				"Your happiness noticeably improved (+%d%%, now %d%%).",
				"Life feels brighter than before (+%d%%, now %d%%).",
			},
			big = {
				"You felt a huge boost of joy (+%d%%, now %d%%).",
				"This really lifted your spirits (+%d%%, now %d%%).",
			},
			huge = {
				"This was a life-changing moment of happiness (+%d%%, now %d%%).",
				"You've rarely felt this good (+%d%%, now %d%%).",
			},
		},
		down = {
			small = {
				"Your happiness dipped a little (-%d%%, now %d%%).",
				"You're slightly less happy than before (-%d%%, now %d%%).",
			},
			medium = {
				"This took a toll on your happiness (-%d%%, now %d%%).",
				"You feel noticeably less happy (-%d%%, now %d%%).",
			},
			big = {
				"Your happiness plummeted (-%d%%, now %d%%).",
				"This really dragged your mood down (-%d%%, now %d%%).",
			},
			huge = {
				"You were devastated by this (-%d%%, now %d%%).",
				"This crushed your happiness (-%d%%, now %d%%).",
			},
		},
	},

	Health = {
		up = {
			small = {
				"You feel a bit healthier (+%d%%, now %d%%).",
				"Your health ticked up slightly (+%d%%, now %d%%).",
			},
			medium = {
				"Your health noticeably improved (+%d%%, now %d%%).",
				"You feel stronger and healthier (+%d%%, now %d%%).",
			},
			big = {
				"Your health made a big recovery (+%d%%, now %d%%).",
				"You feel renewed physically (+%d%%, now %d%%).",
			},
			huge = {
				"This turned your health around (+%d%%, now %d%%).",
				"You bounced back in a major way (+%d%%, now %d%%).",
			},
		},
		down = {
			small = {
				"Your health slipped a bit (-%d%%, now %d%%).",
				"You aren't feeling quite as healthy (-%d%%, now %d%%).",
			},
			medium = {
				"This hurt your health (-%d%%, now %d%%).",
				"You feel noticeably worse physically (-%d%%, now %d%%).",
			},
			big = {
				"Your health took a serious hit (-%d%%, now %d%%).",
				"This really damaged your health (-%d%%, now %d%%).",
			},
			huge = {
				"Your health collapsed after this (-%d%%, now %d%%).",
				"This was a critical blow to your health (-%d%%, now %d%%).",
			},
		},
	},

	Smarts = {
		up = {
			small = {
				"You feel a little sharper (+%d%%, now %d%%).",
				"You picked up a bit of knowledge (+%d%%, now %d%%).",
			},
			medium = {
				"Your smarts improved noticeably (+%d%%, now %d%%).",
				"You learned a lot from this (+%d%%, now %d%%).",
			},
			big = {
				"Your intelligence jumped up (+%d%%, now %d%%).",
				"This really expanded your mind (+%d%%, now %d%%).",
			},
			huge = {
				"You feel downright brilliant after this (+%d%%, now %d%%).",
				"This turned you into a genius (+%d%%, now %d%%).",
			},
		},
		down = {
			small = {
				"You feel a bit foggy (-%d%%, now %d%%).",
				"Your focus slipped a little (-%d%%, now %d%%).",
			},
			medium = {
				"You aren't thinking as clearly (-%d%%, now %d%%).",
				"This dulled your mind (-%d%%, now %d%%).",
			},
			big = {
				"Your smarts took a serious hit (-%d%%, now %d%%).",
				"You feel way less sharp than before (-%d%%, now %d%%).",
			},
			huge = {
				"This completely scrambled you (-%d%%, now %d%%).",
				"Your intelligence tanked (-%d%%, now %d%%).",
			},
		},
	},

	Looks = {
		up = {
			small = {
				"You look a bit better in the mirror (+%d%%, now %d%%).",
				"Your appearance improved slightly (+%d%%, now %d%%).",
			},
			medium = {
				"You had a noticeable glow-up (+%d%%, now %d%%).",
				"You’re looking more put-together (+%d%%, now %d%%).",
			},
			big = {
				"You had a major glow-up (+%d%%, now %d%%).",
				"People are definitely noticing your looks (+%d%%, now %d%%).",
			},
			huge = {
				"You’re basically a model now (+%d%%, now %d%%).",
				"Your looks skyrocketed (+%d%%, now %d%%).",
			},
		},
		down = {
			small = {
				"You're looking a little rough (-%d%%, now %d%%).",
				"Your looks slipped slightly (-%d%%, now %d%%).",
			},
			medium = {
				"This didn't do your looks any favors (-%d%%, now %d%%).",
				"You’re not looking your best (-%d%%, now %d%%).",
			},
			big = {
				"Your looks took a major hit (-%d%%, now %d%%).",
				"You're noticeably less attractive (-%d%%, now %d%%).",
			},
			huge = {
				"This wrecked your appearance (-%d%%, now %d%%).",
				"You look completely different after this (-%d%%, now %d%%).",
			},
		},
	},
}

local MoneyNarrative = {
	gain = {
		small = {
			"You picked up a bit of extra cash (%s). Your balance is now %s.",
			"You quietly added %s to your money. You now have %s.",
			"A small payday brought in %s. You're sitting at %s.",
		},
		medium = {
			"You scored a solid payout of %s. Your money climbed to %s.",
			"You made a decent chunk of money (%s). You're now at %s.",
			"That move paid off with %s. Your total is %s.",
		},
		large = {
			"You hit a big financial win and gained %s. You now have %s.",
			"This was a huge payday (%s). Your balance jumped to %s.",
			"You landed a major bag of %s. You're stacked with %s.",
		},
	},
	loss = {
		small = {
			"You spent a bit of cash (%s). You're left with %s.",
			"You dropped %s on this. Your balance is now %s.",
			"A small expense of %s trimmed your money to %s.",
		},
		medium = {
			"This cost you %s. Your money fell to %s.",
			"A decent chunk of your money disappeared (%s). You're at %s.",
			"You watched %s leave your account. You're down to %s.",
		},
		large = {
			"You lost a massive %s. Your balance dropped to %s.",
			"This absolutely wrecked your finances (-%s). You're down to %s.",
			"Your money took a huge hit of %s, leaving you with %s.",
		},
	},
}

-- Optional: richer descriptions for known flags (story paths etc.)
local FlagDescriptions = {
	political_interest   = "You started paying real attention to politics.",
	political_experience = "You gained your first bit of political experience.",
	elected_official     = "You were elected to public office.",
	state_senator        = "You moved up to state-level politics.",
	congressman          = "You became a member of Congress.",
	us_senator           = "You secured a seat in the U.S. Senate.",
	president            = "You reached the highest office in the country.",

	criminal_tendencies  = "You began dipping your toes into the criminal world.",
	car_thief            = "You picked up a reputation for stealing cars.",
	gang_member          = "You officially joined a gang.",
	war_veteran          = "You became a hardened war veteran.",
	underboss            = "You rose to the rank of underboss.",
	crime_boss           = "You became the boss of a criminal organization.",
}

----------------------------------------------------------------------
-- INTERNAL NARRATIVE BUILDERS
----------------------------------------------------------------------

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
	local bucket   = classifyMagnitude(absDelta)

	local bucketTable = statTable[direction] and statTable[direction][bucket]
	if not bucketTable then
		return nil
	end

	local template = pickRandom(bucketTable)
	if not template then
		return nil
	end

	finalValue = clampStat(finalValue or 50)
	return string.format(template, absDelta, finalValue)
end

local function describeMoneyLine(delta: number, finalMoney: number?): string?
	if not delta or delta == 0 then
		return nil
	end

	local direction = (delta > 0) and "gain" or "loss"
	local absDelta  = math.abs(delta)

	local bucket
	if absDelta >= 50_000 then
		bucket = "large"
	elseif absDelta >= 5_000 then
		bucket = "medium"
	else
		bucket = "small"
	end

	local dirTable  = MoneyNarrative[direction]
	local bucketTbl = dirTable and dirTable[bucket]
	if not bucketTbl then
		return nil
	end

	local template = pickRandom(bucketTbl)
	if not template then
		return nil
	end

	local amountStr = formatMoney(absDelta)
	local totalStr  = formatMoney(finalMoney or 0)

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

-- Central narrative composer. Produces multi-line text joined with "\n".
function EventRunner.buildNarrativeText(state, eventDef, choice, results, dynamicData, explicitResultText)
	local lines = {}

	-- 1) Start with explicit result text if provided in the event definition.
	if explicitResultText and explicitResultText ~= "" then
		table.insert(lines, explicitResultText)
	end

	-- 2) Add money / stat summaries.
	local snapshot = getStatSnapshot(state)
	local effects  = results.effects or {}

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

	-- 3) Flag / story-path flavor.
	local flagLines = describeFlags(results.flagsSet, results.flagsCleared)
	for _, l in ipairs(flagLines) do
		table.insert(lines, l)
	end

	-- 4) Fallbacks when event/choice had no explicit text or effects.
	if #lines == 0 then
		if eventDef and eventDef.title then
			table.insert(lines, "You experienced: " .. eventDef.title .. ".")
		elseif eventDef and eventDef.text then
			-- Use base event text, processed with dynamic data if available.
			local base = EventRunner.processDynamicText(eventDef.text, dynamicData or {})
			table.insert(lines, base or "Something noteworthy happened in your life.")
		else
			table.insert(lines, "Life moved on, but nothing dramatic stood out this year.")
		end
	end

	-- 5) Slight polish for events that have a known category / mood.
	if eventDef and eventDef.category then
		if eventDef.category == "school" then
			table.insert(lines, "It was another chapter in your school life.")
		elseif eventDef.category == "family" then
			table.insert(lines, "Your family life shifted a little because of this.")
		elseif eventDef.category == "work" then
			table.insert(lines, "Your career story took another step here.")
		elseif eventDef.category == "crime" then
			table.insert(lines, "Your criminal record quietly updated itself.")
		elseif eventDef.category == "health" then
			table.insert(lines, "Your medical history just got a new entry.")
		end
	end

	return table.concat(lines, "\n")
end

----------------------------------------------------------------------
-- HISTORY / EVENT PICKING
----------------------------------------------------------------------

-- Initialize event history and flags for a player state
function EventRunner.initHistory(state)
	if not state.EventHistory then
		state.EventHistory = {
			seenEvents      = {},
			lastOccurrence  = {},
			milestonesFired = {},
		}
	end
	if not state.Flags then
		state.Flags = {}
	end
	return state.EventHistory
end

-- Check if an event can fire based on all conditions
function EventRunner.canEventFire(state, eventDef)
	local history = state.EventHistory or {}
	local age     = state.Age or 0

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

-- Get milestone event if one should fire this age
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

-- Weighted random selection from eligible events
function EventRunner.pickRandomEvent(state, events)
	local eligible    = {}
	local totalWeight = 0

	for _, event in ipairs(events) do
		if not event.milestone and EventRunner.canEventFire(state, event) then
			table.insert(eligible, event)
			totalWeight += (event.weight or 10)
		end
	end

	if #eligible == 0 then return nil end

	local roll      = math.random() * totalWeight
	local cumulative = 0

	for _, event in ipairs(eligible) do
		cumulative += (event.weight or 10)
		if roll <= cumulative then
			return event
		end
	end

	return eligible[#eligible]
end

-- Main event picker - milestones take priority
function EventRunner.pickEvent(state, events)
	local milestone = EventRunner.getMilestoneEvent(state, events)
	if milestone then
		return milestone
	end
	return EventRunner.pickRandomEvent(state, events)
end

-- Mark an event as occurred
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

-- Process dynamic text placeholders
function EventRunner.processDynamicText(text, dynamicData)
	if not text or not dynamicData then
		return text
	end

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

-- Build client payload with dynamic data
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
		local resultText = EventRunner.processDynamicText(choice.result, dynamicData)

		table.insert(processedChoices, {
			index      = i,
			text       = choiceText,
			result     = resultText,
			effects    = choice.effects,
			setFlag    = choice.setFlag,
			clearFlag  = choice.clearFlag,
			minigame   = choice.minigame,
			outcome    = choice.outcome,      -- optional, for mood classification
		})
	end

	return {
		id          = eventDef.id,
		emoji       = eventDef.emoji,
		title       = eventDef.title,
		text        = processedText,
		choices     = processedChoices,
		hasMinigame = eventDef.minigame ~= nil,
		minigameType= eventDef.minigame,
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
		effects          = {},
		flagsSet         = {},
		flagsCleared     = {},
		minigameTriggered= nil,
		resultText       = "",
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

	-- Clear flags
	if choice.clearFlag then
		state.Flags = state.Flags or {}
		state.Flags[choice.clearFlag] = nil
		table.insert(results.flagsCleared, choice.clearFlag)
	end

	-- Minigame trigger (if any)
	if choice.minigame then
		results.minigameTriggered = choice.minigame
	end

	-- Explicit result text from choice, if given
	local explicitResultText
	if choice.result then
		explicitResultText = EventRunner.processDynamicText(choice.result, dynamicData)
	end

	-- Final narrative that the client will show in the life feed.
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
-- STORY PATHS / SPECIAL ACTIONS (unchanged API, just kept clean)
----------------------------------------------------------------------

-- Get story path status for UI
function EventRunner.getStoryPaths(state)
	local flags = state and state.Flags or {}

	local paths = {
		political = {
			active   = flags.political_interest or flags.elected_official or false,
			level    = "None",
			progress = 0,
		},
		criminal = {
			active   = flags.criminal_tendencies or flags.gang_member or false,
			level    = "None",
			progress = 0,
		},
	}

	-- Political career progression
	if flags.president then
		paths.political.level    = "President"
		paths.political.progress = 100
	elseif flags.us_senator then
		paths.political.level    = "U.S. Senator"
		paths.political.progress = 85
	elseif flags.congressman then
		paths.political.level    = "Congressman"
		paths.political.progress = 70
	elseif flags.state_senator then
		paths.political.level    = "State Senator"
		paths.political.progress = 50
	elseif flags.elected_official then
		paths.political.level    = "City Council"
		paths.political.progress = 30
	elseif flags.political_experience then
		paths.political.level    = "Political Intern"
		paths.political.progress = 15
	elseif flags.political_interest then
		paths.political.level    = "Interested"
		paths.political.progress = 5
	end

	-- Criminal career progression
	if flags.crime_boss then
		paths.criminal.level    = "Crime Boss"
		paths.criminal.progress = 100
	elseif flags.underboss then
		paths.criminal.level    = "Underboss"
		paths.criminal.progress = 75
	elseif flags.gang_member and flags.war_veteran then
		paths.criminal.level    = "Made Member"
		paths.criminal.progress = 50
	elseif flags.gang_member then
		paths.criminal.level    = "Gang Member"
		paths.criminal.progress = 35
	elseif flags.car_thief then
		paths.criminal.level    = "Car Thief"
		paths.criminal.progress = 20
	elseif flags.criminal_tendencies then
		paths.criminal.level    = "Petty Criminal"
		paths.criminal.progress = 10
	end

	return paths
end

-- Get available special actions based on flags
function EventRunner.getSpecialActions(state)
	local flags   = state and state.Flags or {}
	local actions = {}

	if flags.elected_official then
		table.insert(actions, { id = "campaign",         name = "Campaign",        emoji = "📢", type = "political" })
	end
	if flags.state_senator or flags.congressman or flags.us_senator then
		table.insert(actions, { id = "propose_bill",     name = "Propose Bill",    emoji = "📜", type = "political" })
	end
	if flags.president then
		table.insert(actions, { id = "executive_order",  name = "Executive Order", emoji = "✍️", type = "political" })
		table.insert(actions, { id = "address_nation",   name = "Address Nation",  emoji = "📺", type = "political" })
	end

	if flags.gang_member then
		table.insert(actions, { id = "collect_debts",    name = "Collect Debts",   emoji = "💰", type = "criminal" })
		table.insert(actions, { id = "expand_territory", name = "Expand Territory",emoji = "🗺️", type = "criminal" })
	end
	if flags.underboss or flags.crime_boss then
		table.insert(actions, { id = "launder_money",    name = "Launder Money",   emoji = "🏦", type = "criminal" })
		table.insert(actions, { id = "order_hit",        name = "Order a Hit",     emoji = "🎯", type = "criminal" })
	end
	if flags.crime_boss then
		table.insert(actions, { id = "hold_meeting",     name = "Hold Meeting",    emoji = "🤝", type = "criminal" })
	end

	return actions
end

return EventRunner
