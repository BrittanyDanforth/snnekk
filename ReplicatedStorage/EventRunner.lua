-- EventRunner.lua
-- Manages event selection, history, flags, and story path progression

local EventRunner = {}

-- Initialize event history and flags for a player state
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

-- Check if an event can fire based on all conditions
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
	local eligible = {}
	local totalWeight = 0
	
	for _, event in ipairs(events) do
		if not event.milestone and EventRunner.canEventFire(state, event) then
			table.insert(eligible, event)
			totalWeight = totalWeight + (event.weight or 10)
		end
	end
	
	if #eligible == 0 then return nil end
	
	local roll = math.random() * totalWeight
	local cumulative = 0
	
	for _, event in ipairs(eligible) do
		cumulative = cumulative + (event.weight or 10)
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

-- Process dynamic text placeholders
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
			index = i,
			text = choiceText,
			result = resultText,
			effects = choice.effects,
			setFlag = choice.setFlag,
			clearFlag = choice.clearFlag,
			minigame = choice.minigame,
		})
	end
	
	return {
		id = eventDef.id,
		emoji = eventDef.emoji,
		title = eventDef.title,
		text = processedText,
		choices = processedChoices,
		hasMinigame = eventDef.minigame ~= nil,
		minigameType = eventDef.minigame,
	}, dynamicData
end

-- Apply choice effects to state
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
	
	-- Apply stat effects
	if choice.effects and type(choice.effects) == "table" then
		for stat, delta in pairs(choice.effects) do
			if type(delta) == "number" then
				if stat == "Money" then
					state.Money = (state.Money or 0) + delta
					results.effects.Money = delta
				elseif stat == "Happiness" then
					local newVal = math.clamp((state.Stats and state.Stats.Happiness or 50) + delta, 0, 100)
					if state.Stats then state.Stats.Happiness = newVal end
					state.Happiness = newVal
					results.effects.Happiness = delta
				elseif stat == "Health" then
					local newVal = math.clamp((state.Stats and state.Stats.Health or 50) + delta, 0, 100)
					if state.Stats then state.Stats.Health = newVal end
					state.Health = newVal
					results.effects.Health = delta
				elseif stat == "Smarts" then
					local newVal = math.clamp((state.Stats and state.Stats.Smarts or 50) + delta, 0, 100)
					if state.Stats then state.Stats.Smarts = newVal end
					state.Smarts = newVal
					results.effects.Smarts = delta
				elseif stat == "Looks" then
					local newVal = math.clamp((state.Stats and state.Stats.Looks or 50) + delta, 0, 100)
					if state.Stats then state.Stats.Looks = newVal end
					state.Looks = newVal
					results.effects.Looks = delta
				end
			end
		end
	end
	
	-- Apply dynamic money if present
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
	
	-- Check for minigame trigger
	if choice.minigame then
		results.minigameTriggered = choice.minigame
	end
	
	-- Process result text
	results.resultText = EventRunner.processDynamicText(choice.result, dynamicData) or "Something happened."
	
	return results, nil
end

-- Get story path status for UI
function EventRunner.getStoryPaths(state)
	local flags = state and state.Flags or {}
	
	local paths = {
		political = {
			active = flags.political_interest or flags.elected_official or false,
			level = "None",
			progress = 0,
		},
		criminal = {
			active = flags.criminal_tendencies or flags.gang_member or false,
			level = "None",
			progress = 0,
		},
	}
	
	-- Political career progression
	if flags.president then
		paths.political.level = "President"
		paths.political.progress = 100
	elseif flags.us_senator then
		paths.political.level = "U.S. Senator"
		paths.political.progress = 85
	elseif flags.congressman then
		paths.political.level = "Congressman"
		paths.political.progress = 70
	elseif flags.state_senator then
		paths.political.level = "State Senator"
		paths.political.progress = 50
	elseif flags.elected_official then
		paths.political.level = "City Council"
		paths.political.progress = 30
	elseif flags.political_experience then
		paths.political.level = "Political Intern"
		paths.political.progress = 15
	elseif flags.political_interest then
		paths.political.level = "Interested"
		paths.political.progress = 5
	end
	
	-- Criminal career progression
	if flags.crime_boss then
		paths.criminal.level = "Crime Boss"
		paths.criminal.progress = 100
	elseif flags.underboss then
		paths.criminal.level = "Underboss"
		paths.criminal.progress = 75
	elseif flags.gang_member and flags.war_veteran then
		paths.criminal.level = "Made Member"
		paths.criminal.progress = 50
	elseif flags.gang_member then
		paths.criminal.level = "Gang Member"
		paths.criminal.progress = 35
	elseif flags.car_thief then
		paths.criminal.level = "Car Thief"
		paths.criminal.progress = 20
	elseif flags.criminal_tendencies then
		paths.criminal.level = "Petty Criminal"
		paths.criminal.progress = 10
	end
	
	return paths
end

-- Get available special actions based on flags
function EventRunner.getSpecialActions(state)
	local flags = state and state.Flags or {}
	local actions = {}
	
	if flags.elected_official then
		table.insert(actions, { id = "campaign", name = "Campaign", emoji = "📢", type = "political" })
	end
	if flags.state_senator or flags.congressman or flags.us_senator then
		table.insert(actions, { id = "propose_bill", name = "Propose Bill", emoji = "📜", type = "political" })
	end
	if flags.president then
		table.insert(actions, { id = "executive_order", name = "Executive Order", emoji = "✍️", type = "political" })
		table.insert(actions, { id = "address_nation", name = "Address Nation", emoji = "📺", type = "political" })
	end
	
	if flags.gang_member then
		table.insert(actions, { id = "collect_debts", name = "Collect Debts", emoji = "💰", type = "criminal" })
		table.insert(actions, { id = "expand_territory", name = "Expand Territory", emoji = "🗺️", type = "criminal" })
	end
	if flags.underboss or flags.crime_boss then
		table.insert(actions, { id = "launder_money", name = "Launder Money", emoji = "🏦", type = "criminal" })
		table.insert(actions, { id = "order_hit", name = "Order a Hit", emoji = "🎯", type = "criminal" })
	end
	if flags.crime_boss then
		table.insert(actions, { id = "hold_meeting", name = "Hold Meeting", emoji = "🤝", type = "criminal" })
	end
	
	return actions
end

return EventRunner
