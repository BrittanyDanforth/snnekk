-- EventRunner.lua
-- Logic to pick which event fires and apply the results.

local EventRunner = {}

-- Pick a matching event for this age, using simple weighted random.
function EventRunner.pickEvent(state, events)
	local age = state.Age or 0
	local pool = {}
	local totalWeight = 0

	for _, ev in ipairs(events) do
		local minAge = ev.minAge or 0
		local maxAge = ev.maxAge or math.huge
		if age >= minAge and age <= maxAge then
			local w = ev.weight or 1
			totalWeight = totalWeight + w
			table.insert(pool, { def = ev, weight = w })
		end
	end

	if totalWeight <= 0 then
		return nil
	end

	local roll = math.random() * totalWeight
	local running = 0
	for _, item in ipairs(pool) do
		running = running + item.weight
		if roll <= running then
			return item.def
		end
	end

	return nil
end

-- Strip down server event definition to client-safe payload.
function EventRunner.buildClientPayload(eventDef)
	local payload = {
		id = eventDef.id,
		text = eventDef.text,
		title = eventDef.title,
		emoji = eventDef.emoji,
		showRelationship = eventDef.showRelationship,
		relationName = eventDef.relationName,
		relationship = eventDef.relationship,
		choices = {},
	}

	for _, choice in ipairs(eventDef.choices or {}) do
		table.insert(payload.choices, {
			id = choice.id,
			text = choice.text,
		})
	end

	return payload
end

-- Apply the chosen branch effects onto the LifeState.
function EventRunner.applyChoice(state, eventDef, choiceDef)
	local effects = choiceDef.effects or {}

	if effects.Stats then
		for key, delta in pairs(effects.Stats) do
			if state.Stats[key] ~= nil then
				state.Stats[key] = state.Stats[key] + delta
			end
		end
	end

	if effects.Money then
		state.Money = state.Money + effects.Money
	end

	state:ClampStats()

	return choiceDef.resultText or "You made a choice that shaped your life."
end

return EventRunner
