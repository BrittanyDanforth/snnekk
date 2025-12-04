--[[
	LifeEvents/init.lua
	AAA BitLife-Style Event System
	
	Master event hub that:
	- Loads event modules
	- Provides event selection
	- Processes event choices
	- Exposes helpers for writing events
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LifeEvents = {}

--------------------------------------------------------------------------------
-- INTERNAL STATE
--------------------------------------------------------------------------------

local AllEvents = {}      -- Array of all events
local EventsById = {}     -- Map: eventId -> event
local EventsByCategory = {} -- Map: category -> {events}
local EventModules = {}   -- Loaded module references

local LifeStageSystem -- Lazy loaded

local function getLifeStageSystem()
	if not LifeStageSystem then
		LifeStageSystem = require(ReplicatedStorage:WaitForChild("LifeStageSystem"))
	end
	return LifeStageSystem
end

--------------------------------------------------------------------------------
-- EVENT NORMALIZATION
--------------------------------------------------------------------------------

local function normalizeEvent(event, moduleName)
	-- Ensure event has an ID
	if not event.id then
		event.id = moduleName .. "_" .. #AllEvents
	end
	
	-- Ensure category
	event.category = event.category or "life"
	
	-- Ensure weight
	event.weight = event.weight or 10
	
	-- Normalize conditions
	if not event.conditions then
		event.conditions = {}
	end
	
	-- Move legacy fields to conditions
	if event.minAge and not event.conditions.minAge then
		event.conditions.minAge = event.minAge
	end
	if event.maxAge and not event.conditions.maxAge then
		event.conditions.maxAge = event.maxAge
	end
	if event.requiresFlag and not event.conditions.requiredAllFlags then
		event.conditions.requiredAllFlags = {event.requiresFlag}
	end
	if event.blockIfFlag and not event.conditions.blockedFlags then
		event.conditions.blockedFlags = {event.blockIfFlag}
	end
	if event.minMoney and not event.conditions.minMoney then
		event.conditions.minMoney = event.minMoney
	end
	if event.requires and type(event.requires) == "function" and not event.conditions.custom then
		event.conditions.custom = event.requires
	end
	
	-- Normalize choices
	if event.choices then
		for i, choice in ipairs(event.choices) do
			choice.index = i
			choice.id = choice.id or ("choice_" .. i)
			
			-- Normalize flag effects
			if not choice.flags then
				choice.flags = { set = {}, clear = {} }
			end
			if choice.setFlag then
				table.insert(choice.flags.set, choice.setFlag)
			end
			if choice.setFlags then
				for _, f in ipairs(choice.setFlags) do
					table.insert(choice.flags.set, f)
				end
			end
			if choice.clearFlag then
				table.insert(choice.flags.clear, choice.clearFlag)
			end
		end
	else
		event.choices = {
			{ index = 1, id = "continue", text = "Continue", resultText = "Life goes on." }
		}
	end
	
	return event
end

--------------------------------------------------------------------------------
-- MODULE LOADING
--------------------------------------------------------------------------------

local EVENT_MODULES = {
	"starter_events",
	-- Add more event modules here:
	-- "career_motorsport",
	-- "crime_events",
	-- "relationship_events",
}

local function loadEventModule(moduleName)
	local container = script
	local moduleScript = container:FindFirstChild(moduleName)
	
	if not moduleScript then
		return nil, "Module not found: " .. moduleName
	end
	
	local ok, result = pcall(require, moduleScript)
	if not ok then
		return nil, "Failed to load: " .. tostring(result)
	end
	
	-- Extract events from module
	local events
	if type(result) == "table" then
		if result.events then
			events = result.events
		elseif result.Events then
			events = result.Events
		elseif result[1] then
			events = result
		else
			events = {}
		end
	end
	
	return events, nil
end

function LifeEvents.loadModules()
	AllEvents = {}
	EventsById = {}
	EventsByCategory = {}
	
	for _, moduleName in ipairs(EVENT_MODULES) do
		local events, err = loadEventModule(moduleName)
		
		if events then
			for _, event in ipairs(events) do
				local normalized = normalizeEvent(event, moduleName)
				
				-- Add to registries
				table.insert(AllEvents, normalized)
				EventsById[normalized.id] = normalized
				
				-- Category index
				local cat = normalized.category
				EventsByCategory[cat] = EventsByCategory[cat] or {}
				table.insert(EventsByCategory[cat], normalized)
			end
		end
	end
	
	return #AllEvents
end

--------------------------------------------------------------------------------
-- MANUAL EVENT REGISTRATION
--------------------------------------------------------------------------------

function LifeEvents.registerEvent(event)
	local normalized = normalizeEvent(event, "custom")
	
	table.insert(AllEvents, normalized)
	EventsById[normalized.id] = normalized
	
	local cat = normalized.category
	EventsByCategory[cat] = EventsByCategory[cat] or {}
	table.insert(EventsByCategory[cat], normalized)
	
	return normalized.id
end

function LifeEvents.registerEvents(events)
	for _, event in ipairs(events) do
		LifeEvents.registerEvent(event)
	end
end

--------------------------------------------------------------------------------
-- EVENT GETTERS
--------------------------------------------------------------------------------

function LifeEvents.getAllEvents()
	return AllEvents
end

function LifeEvents.getEvent(id)
	return EventsById[id]
end

function LifeEvents.getEventsByCategory(category)
	return EventsByCategory[category] or {}
end

function LifeEvents.getEventsForAge(age)
	local matching = {}
	
	for _, event in ipairs(AllEvents) do
		local minAge = event.conditions.minAge or 0
		local maxAge = event.conditions.maxAge or 150
		
		if age >= minAge and age <= maxAge then
			table.insert(matching, event)
		end
	end
	
	return matching
end

--------------------------------------------------------------------------------
-- EVENT SELECTION
--------------------------------------------------------------------------------

function LifeEvents.isEligible(event, state)
	local LSS = getLifeStageSystem()
	local validation = LSS.validateEvent(event, state)
	return validation.valid, validation.reasons
end

function LifeEvents.getEligibleEvents(state)
	local eligible = {}
	
	for _, event in ipairs(AllEvents) do
		if LifeEvents.isEligible(event, state) then
			table.insert(eligible, event)
		end
	end
	
	return eligible
end

function LifeEvents.weightedSelect(events, count)
	if not events or #events == 0 then
		return {}
	end
	
	count = count or 1
	local selected = {}
	local pool = {}
	
	-- Copy to pool
	for _, event in ipairs(events) do
		table.insert(pool, { event = event, weight = event.weight or 10 })
	end
	
	for _ = 1, count do
		if #pool == 0 then break end
		
		-- Calculate total weight
		local totalWeight = 0
		for _, item in ipairs(pool) do
			totalWeight = totalWeight + item.weight
		end
		
		-- Random selection
		local roll = math.random() * totalWeight
		local cumulative = 0
		
		for i, item in ipairs(pool) do
			cumulative = cumulative + item.weight
			if roll <= cumulative then
				table.insert(selected, item.event)
				table.remove(pool, i)
				break
			end
		end
	end
	
	return selected
end

function LifeEvents.selectEventsForYear(state, config)
	config = config or {}
	local maxEvents = config.maxEvents or 2
	
	local eligible = LifeEvents.getEligibleEvents(state)
	
	if #eligible == 0 then
		return {}
	end
	
	-- Prioritize milestones
	local milestones = {}
	local regular = {}
	
	for _, event in ipairs(eligible) do
		if event.milestone then
			table.insert(milestones, event)
		else
			table.insert(regular, event)
		end
	end
	
	local selected = {}
	
	-- Always include milestones first (up to max)
	for i, m in ipairs(milestones) do
		if #selected >= maxEvents then break end
		table.insert(selected, m)
	end
	
	-- Fill remaining slots with regular events
	if #selected < maxEvents and #regular > 0 then
		local extras = LifeEvents.weightedSelect(regular, maxEvents - #selected)
		for _, event in ipairs(extras) do
			table.insert(selected, event)
		end
	end
	
	return selected
end

--------------------------------------------------------------------------------
-- EVENT TEXT PROCESSING
--------------------------------------------------------------------------------

function LifeEvents.getEventText(event, state)
	local text = event.text or "Something happens..."
	local dynamicData = {}
	
	-- Get dynamic data if available
	if event.getDynamicData and type(event.getDynamicData) == "function" then
		local ok, data = pcall(event.getDynamicData, state)
		if ok and data then
			dynamicData = data
		end
	end
	
	-- Replace placeholders
	text = text:gsub("{name}", state.Name or "You")
	text = text:gsub("{age}", tostring(state.Age))
	text = text:gsub("{gender}", state.Gender or "person")
	
	-- Custom placeholders from dynamic data
	for key, value in pairs(dynamicData) do
		text = text:gsub("{" .. key .. "}", tostring(value))
	end
	
	return text, dynamicData
end

--------------------------------------------------------------------------------
-- CHOICE PROCESSING
--------------------------------------------------------------------------------

function LifeEvents.processChoice(event, choiceIndex, state)
	if not event or not event.choices then
		return nil, "Invalid event"
	end
	
	local choice = event.choices[choiceIndex]
	if not choice then
		return nil, "Invalid choice index"
	end
	
	local results = {
		statChanges = {},
		flagsSet = {},
		flagsCleared = {},
		messages = {},
	}
	
	-- Apply stat effects
	if choice.effects then
		for stat, amount in pairs(choice.effects) do
			if stat == "Money" or stat == "Cash" then
				local oldVal = state.Money or 0
				local newVal = oldVal + amount
				state.Money = newVal
				results.statChanges[stat] = { old = oldVal, new = newVal, change = amount }
			elseif state.Stats[stat] ~= nil then
				local oldVal = state.Stats[stat] or 50
				local newVal = math.clamp(oldVal + amount, 0, 100)
				state.Stats[stat] = newVal
				results.statChanges[stat] = { old = oldVal, new = newVal, change = amount }
			end
		end
	end
	
	-- Apply flag changes
	if choice.flags then
		if choice.flags.set then
			for _, flag in ipairs(choice.flags.set) do
				state.Flags[flag] = true
				table.insert(results.flagsSet, flag)
			end
		end
		if choice.flags.clear then
			for _, flag in ipairs(choice.flags.clear) do
				state.Flags[flag] = nil
				table.insert(results.flagsCleared, flag)
			end
		end
	end
	
	-- Run custom onSelect handler
	if choice.onSelect and type(choice.onSelect) == "function" then
		local ok, msg = pcall(choice.onSelect, state, results)
		if ok and msg then
			table.insert(results.messages, msg)
		end
	end
	
	-- Record event
	if state.EventHistory then
		state.EventHistory.seen[event.id] = true
		state.EventHistory.lastOccurrence[event.id] = state.Age
		state.EventHistory.choices[event.id] = choiceIndex
		
		if event.milestone then
			state.EventHistory.milestones[event.id] = true
		end
	end
	
	return results, nil
end

--------------------------------------------------------------------------------
-- HELPER FUNCTIONS FOR EVENT WRITERS
--------------------------------------------------------------------------------

-- Random helpers
LifeEvents.random = math.random

function LifeEvents.randomAmount(min, max)
	return math.random(min, max)
end

function LifeEvents.randomPercent(chance)
	return math.random() < (chance / 100)
end

function LifeEvents.randomChoice(options)
	return options[math.random(1, #options)]
end

-- State helpers
function LifeEvents.hasFlag(state, flag)
	return state.Flags and state.Flags[flag] == true
end

function LifeEvents.hasJob(state)
	return state.Career and state.Career.jobId ~= nil
end

function LifeEvents.isInPrison(state)
	return state.Criminal and state.Criminal.inPrison
end

function LifeEvents.hasMoney(state, amount)
	return (state.Money or 0) >= amount
end

function LifeEvents.getStat(state, stat)
	return state.Stats and state.Stats[stat] or 0
end

--------------------------------------------------------------------------------
-- INITIALIZATION
--------------------------------------------------------------------------------

function LifeEvents.initialize()
	local count = LifeEvents.loadModules()
	return count
end

-- Auto-initialize
LifeEvents.initialize()

return LifeEvents
