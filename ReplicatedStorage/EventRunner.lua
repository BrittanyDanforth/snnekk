-- EventRunner.lua
-- Advanced event system with tracking, cooldowns, milestones, and dynamic text

local EventRunner = {}

--[[
  Event State Tracking (stored per-player in LifeState.EventHistory):
  {
    seenEvents = { [eventId] = true },           -- Events that happened (for oneTime)
    lastOccurrence = { [eventId] = age },        -- Last age this event fired (for cooldown)
    milestonesFired = { [age] = true },          -- Milestones that fired this age
  }
]]

-- Initialize event history for a player state
function EventRunner.initHistory(state)
	if not state.EventHistory then
		state.EventHistory = {
			seenEvents = {},
			lastOccurrence = {},
			milestonesFired = {},
		}
	end
	return state.EventHistory
end

-- Check if an event can fire based on all conditions
function EventRunner.canEventFire(state, eventDef)
	local age = state.Age or 0
	local history = EventRunner.initHistory(state)
	
	-- Check age range
	local minAge = eventDef.minAge or 0
	local maxAge = eventDef.maxAge or math.huge
	if age < minAge or age > maxAge then
		return false
	end
	
	-- Check one-time events
	if eventDef.oneTime and history.seenEvents[eventDef.id] then
		return false
	end
	
	-- Check cooldown
	if eventDef.cooldown and history.lastOccurrence[eventDef.id] then
		local lastAge = history.lastOccurrence[eventDef.id]
		if age - lastAge < eventDef.cooldown then
			return false
		end
	end
	
	-- Check custom requirements function
	if eventDef.requires and type(eventDef.requires) == "function" then
		local success, canFire = pcall(eventDef.requires, state)
		if not success or not canFire then
			return false
		end
	end
	
	return true
end

-- Get milestone events for current age (guaranteed to fire)
function EventRunner.getMilestoneEvent(state, events)
	local age = state.Age or 0
	local history = EventRunner.initHistory(state)
	
	-- Don't repeat milestones for the same age
	if history.milestonesFired[age] then
		return nil
	end
	
	for _, ev in ipairs(events) do
		if ev.milestone and EventRunner.canEventFire(state, ev) then
			return ev
		end
	end
	
	return nil
end

-- Pick a random event using weighted selection (excludes milestones, respects all rules)
function EventRunner.pickRandomEvent(state, events)
	local pool = {}
	local totalWeight = 0
	
	for _, ev in ipairs(events) do
		-- Skip milestones (they're handled separately)
		if ev.milestone then
			continue
		end
		
		if EventRunner.canEventFire(state, ev) then
			local w = ev.weight or 1
			totalWeight = totalWeight + w
			table.insert(pool, { def = ev, weight = w })
		end
	end
	
	if totalWeight <= 0 or #pool == 0 then
		return nil
	end
	
	-- Weighted random selection
	local roll = math.random() * totalWeight
	local running = 0
	for _, item in ipairs(pool) do
		running = running + item.weight
		if roll <= running then
			return item.def
		end
	end
	
	-- Fallback
	return pool[math.random(#pool)].def
end

-- Main function: pick the best event for this age
function EventRunner.pickEvent(state, events)
	-- First, check for milestone events (guaranteed)
	local milestone = EventRunner.getMilestoneEvent(state, events)
	if milestone then
		return milestone
	end
	
	-- Otherwise, pick a random weighted event
	return EventRunner.pickRandomEvent(state, events)
end

-- Mark an event as occurred
function EventRunner.markEventOccurred(state, eventDef)
	local history = EventRunner.initHistory(state)
	local age = state.Age or 0
	
	-- Track for one-time events
	if eventDef.oneTime then
		history.seenEvents[eventDef.id] = true
	end
	
	-- Track for cooldown
	history.lastOccurrence[eventDef.id] = age
	
	-- Track milestone
	if eventDef.milestone then
		history.milestonesFired[age] = true
	end
end

-- Process dynamic text replacement (%variableName%)
function EventRunner.processDynamicText(text, dynamicData)
	if not text or not dynamicData then return text end
	
	for key, value in pairs(dynamicData) do
		text = text:gsub("%%" .. key .. "%%", tostring(value))
	end
	
	return text
end

-- Build client-safe payload with dynamic text processing
function EventRunner.buildClientPayload(eventDef, state)
	-- Generate dynamic data if available
	local dynamicData = {}
	if eventDef.getDynamicData and type(eventDef.getDynamicData) == "function" then
		local success, data = pcall(eventDef.getDynamicData, state)
		if success and data then
			dynamicData = data
		end
	end
	
	-- Process text with dynamic replacements
	local processedText = EventRunner.processDynamicText(eventDef.text, dynamicData)
	local processedTitle = EventRunner.processDynamicText(eventDef.title, dynamicData)
	local processedRelationName = EventRunner.processDynamicText(eventDef.relationName, dynamicData)
	
	local payload = {
		id = eventDef.id,
		text = processedText,
		title = processedTitle,
		emoji = eventDef.emoji,
		showRelationship = eventDef.showRelationship,
		relationName = processedRelationName,
		relationship = eventDef.relationship,
		choices = {},
		_dynamicData = dynamicData, -- Pass to server for result processing
	}
	
	for _, choice in ipairs(eventDef.choices or {}) do
		local processedChoiceText = EventRunner.processDynamicText(choice.text, dynamicData)
		table.insert(payload.choices, {
			id = choice.id,
			text = processedChoiceText,
		})
	end
	
	return payload, dynamicData
end

-- Apply the chosen branch effects onto the LifeState
function EventRunner.applyChoice(state, eventDef, choiceDef, dynamicData)
	local effects = choiceDef.effects or {}
	
	-- Apply stat changes
	if effects.Stats then
		for key, delta in pairs(effects.Stats) do
			-- Handle both nested Stats and flat stats
			if state.Stats and state.Stats[key] ~= nil then
				state.Stats[key] = state.Stats[key] + delta
			elseif state[key] ~= nil then
				state[key] = state[key] + delta
			end
		end
	end
	
	-- Apply money changes
	if effects.Money then
		state.Money = (state.Money or 0) + effects.Money
	end
	
	-- Apply dynamic money (from events like lottery, inheritance)
	if eventDef.applyDynamicMoney and dynamicData and dynamicData.amount then
		state.Money = (state.Money or 0) + dynamicData.amount
	end
	
	-- Clamp stats
	if state.ClampStats then
		state:ClampStats()
	else
		-- Manual clamp if method doesn't exist
		if state.Stats then
			for key, val in pairs(state.Stats) do
				state.Stats[key] = math.clamp(val, 0, 100)
			end
		end
	end
	
	-- Process result text with dynamic data
	local resultText = EventRunner.processDynamicText(choiceDef.resultText, dynamicData)
	
	return resultText or "You made a choice that shaped your life."
end

-- Get a summary of event history (for debugging)
function EventRunner.getHistorySummary(state)
	local history = EventRunner.initHistory(state)
	local seenCount = 0
	for _ in pairs(history.seenEvents) do seenCount = seenCount + 1 end
	
	return {
		seenEvents = seenCount,
		lastOccurrences = history.lastOccurrence,
	}
end

-- Reset event history (for new game)
function EventRunner.resetHistory(state)
	state.EventHistory = {
		seenEvents = {},
		lastOccurrence = {},
		milestonesFired = {},
	}
end

return EventRunner
