-- EventRunner.lua
-- Logic to pick which event fires and apply the results.
-- Enhanced with flag-based event conditions, story progression, and more sophisticated selection.

local EventRunner = {}

----------------------------------------------------------------
-- EVENT SELECTION
----------------------------------------------------------------

-- Check if an event's conditions are met
local function checkConditions(state, eventDef)
	-- Check age range
	local age = state.Age or 0
	local minAge = eventDef.minAge or 0
	local maxAge = eventDef.maxAge or math.huge
	
	if age < minAge or age > maxAge then
		return false
	end
	
	-- Check required flags
	if eventDef.requiredFlags then
		for flagName, requiredValue in pairs(eventDef.requiredFlags) do
			local stateValue = state:GetFlag(flagName)
			if type(requiredValue) == "boolean" then
				if stateValue ~= requiredValue then
					return false
				end
			elseif type(requiredValue) == "number" then
				if (stateValue or 0) < requiredValue then
					return false
				end
			elseif stateValue ~= requiredValue then
				return false
			end
		end
	end
	
	-- Check excluded flags (events that shouldn't fire if flag is set)
	if eventDef.excludedFlags then
		for _, flagName in ipairs(eventDef.excludedFlags) do
			if state:HasFlag(flagName) then
				return false
			end
		end
	end
	
	-- Check minimum stats
	if eventDef.minStats then
		for statName, minValue in pairs(eventDef.minStats) do
			if (state.Stats[statName] or 0) < minValue then
				return false
			end
		end
	end
	
	-- Check maximum stats
	if eventDef.maxStats then
		for statName, maxValue in pairs(eventDef.maxStats) do
			if (state.Stats[statName] or 0) > maxValue then
				return false
			end
		end
	end
	
	-- Check job requirement
	if eventDef.requiresJob and not state.Job then
		return false
	end
	
	-- Check unemployed requirement
	if eventDef.requiresUnemployed and state.Job then
		return false
	end
	
	-- Check jail status
	if eventDef.requiresInJail and not state.InJail then
		return false
	end
	
	if eventDef.requiresFree and state.InJail then
		return false
	end
	
	-- Check married status
	if eventDef.requiresMarried and not state:IsMarried() then
		return false
	end
	
	if eventDef.requiresSingle and state:IsMarried() then
		return false
	end
	
	-- Check has children
	if eventDef.requiresChildren and state:GetChildCount() <= 0 then
		return false
	end
	
	-- Check education requirements
	if eventDef.requiresDegree then
		if not state:HasDegree(eventDef.requiresDegree) then
			return false
		end
	end
	
	-- Check money requirements
	if eventDef.minMoney and state.Money < eventDef.minMoney then
		return false
	end
	
	if eventDef.maxMoney and state.Money > eventDef.maxMoney then
		return false
	end
	
	-- Check story path progress
	if eventDef.requiredStoryProgress then
		for pathName, minProgress in pairs(eventDef.requiredStoryProgress) do
			if state:GetStoryProgress(pathName) < minProgress then
				return false
			end
		end
	end
	
	-- Check health condition requirements
	if eventDef.requiresCondition then
		if not state:HasCondition(eventDef.requiresCondition) then
			return false
		end
	end
	
	-- Check addiction requirements
	if eventDef.requiresAddiction then
		if not state:HasAddiction(eventDef.requiresAddiction) then
			return false
		end
	end
	
	-- All conditions passed
	return true
end

-- Calculate weighted probability based on state
local function calculateWeight(state, eventDef)
	local baseWeight = eventDef.weight or 1
	local weight = baseWeight
	
	-- Karma affects event probability
	if eventDef.karmaModifier then
		local karma = state.Karma or 50
		local karmaFactor = karma / 50 -- 0-2 multiplier based on karma
		weight = weight * (1 + (eventDef.karmaModifier * (karmaFactor - 1)))
	end
	
	-- Luck/randomness factor
	if eventDef.luckBased then
		local happinessBonus = (state.Stats.Happiness or 50) / 100
		weight = weight * (0.5 + happinessBonus)
	end
	
	-- Story path events get boosted if player is on that path
	if eventDef.storyPath then
		local progress = state:GetStoryProgress(eventDef.storyPath)
		if progress > 0 then
			weight = weight * (1 + progress * 0.1)
		end
	end
	
	-- Events for player's current situation get priority
	if eventDef.situational then
		-- Boost weight for relevant events
		if eventDef.situational == "employed" and state.Job then
			weight = weight * 1.5
		elseif eventDef.situational == "unemployed" and not state.Job then
			weight = weight * 1.5
		elseif eventDef.situational == "wealthy" and state.Money > 100000 then
			weight = weight * 1.5
		elseif eventDef.situational == "poor" and state.Money < 1000 then
			weight = weight * 1.5
		end
	end
	
	return math.max(0.1, weight) -- Minimum weight to prevent 0
end

-- Pick a matching event for this age, using weighted random with conditions
function EventRunner.pickEvent(state, events)
	local pool = {}
	local totalWeight = 0

	for _, ev in ipairs(events) do
		if checkConditions(state, ev) then
			local w = calculateWeight(state, ev)
			totalWeight = totalWeight + w
			table.insert(pool, { def = ev, weight = w })
		end
	end

	if totalWeight <= 0 then
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

	return nil
end

-- Get all eligible events without picking (for debugging/preview)
function EventRunner.getEligibleEvents(state, events)
	local eligible = {}
	
	for _, ev in ipairs(events) do
		if checkConditions(state, ev) then
			table.insert(eligible, {
				id = ev.id,
				text = ev.text,
				weight = calculateWeight(state, ev),
			})
		end
	end
	
	-- Sort by weight descending
	table.sort(eligible, function(a, b)
		return a.weight > b.weight
	end)
	
	return eligible
end

----------------------------------------------------------------
-- CLIENT PAYLOAD
----------------------------------------------------------------

-- Strip down server event definition to client-safe payload
function EventRunner.buildClientPayload(eventDef)
	local payload = {
		id = eventDef.id,
		text = eventDef.text,
		choices = {},
		emoji = eventDef.emoji or "🎲",
		category = eventDef.category or "Life Event",
	}

	for _, choice in ipairs(eventDef.choices or {}) do
		local choicePayload = {
			id = choice.id,
			text = choice.text,
		}
		
		-- Include preview hints if available
		if choice.previewHint then
			choicePayload.hint = choice.previewHint
		end
		
		-- Include risk level if specified
		if choice.risk then
			choicePayload.risk = choice.risk
		end
		
		table.insert(payload.choices, choicePayload)
	end

	return payload
end

----------------------------------------------------------------
-- CHOICE APPLICATION
----------------------------------------------------------------

-- Apply the chosen branch effects onto the LifeState
function EventRunner.applyChoice(state, eventDef, choiceDef)
	local effects = choiceDef.effects or {}
	local resultText = choiceDef.resultText or "You made a choice that shaped your life."

	-- Apply stat changes
	if effects.Stats then
		for key, delta in pairs(effects.Stats) do
			if state.Stats[key] ~= nil then
				state.Stats[key] = state.Stats[key] + delta
			end
		end
	end

	-- Apply money changes
	if effects.Money then
		state.Money = state.Money + effects.Money
	end

	-- Apply flag changes
	if effects.SetFlags then
		for flagName, value in pairs(effects.SetFlags) do
			state:SetFlag(flagName, value)
		end
	end
	
	-- Apply flag removal
	if effects.RemoveFlags then
		for _, flagName in ipairs(effects.RemoveFlags) do
			state:SetFlag(flagName, nil)
		end
	end

	-- Apply story progress
	if effects.StoryProgress then
		for pathName, amount in pairs(effects.StoryProgress) do
			state:AdvanceStoryPath(pathName, amount)
		end
	end
	
	-- Apply skill improvements
	if effects.Skills then
		for skillName, amount in pairs(effects.Skills) do
			state:ImproveSkill(skillName, amount)
		end
	end
	
	-- Apply karma changes
	if effects.Karma then
		state.Karma = (state.Karma or 50) + effects.Karma
	end
	
	-- Apply willpower changes
	if effects.Willpower then
		state.Willpower = (state.Willpower or 50) + effects.Willpower
	end
	
	-- Apply fame changes
	if effects.Fame then
		state.Fame = (state.Fame or 0) + effects.Fame
	end
	
	-- Apply craziness changes
	if effects.Craziness then
		state.Craziness = (state.Craziness or 20) + effects.Craziness
	end
	
	-- Apply health conditions
	if effects.AddCondition then
		state:AddHealthCondition(
			effects.AddCondition.name,
			effects.AddCondition.severity,
			effects.AddCondition.treatable
		)
	end
	
	-- Apply addiction
	if effects.AddAddiction then
		state:AddAddiction(effects.AddAddiction.substance, effects.AddAddiction.severity)
	end
	
	-- Remove addiction
	if effects.RemoveAddiction then
		state:RemoveAddiction(effects.RemoveAddiction)
	end
	
	-- Unlock achievement
	if effects.Achievement then
		state:UnlockAchievement(
			effects.Achievement.id,
			effects.Achievement.title,
			effects.Achievement.description
		)
	end
	
	-- Set milestone
	if effects.Milestone then
		if state.Milestones[effects.Milestone] ~= nil then
			state.Milestones[effects.Milestone] = true
		end
		state:AddMilestone(resultText)
	end
	
	-- Apply relationship changes
	if effects.RelationshipChange then
		local change = effects.RelationshipChange
		if change.type == "AddFriend" then
			state:AddRelationship("Friend", {
				name = change.name or "New Friend",
				relationship = 50,
				yearMet = state.Year,
			})
		elseif change.type == "AddEnemy" then
			state:AddRelationship("Enemy", {
				name = change.name or "Enemy",
				relationship = -50,
				yearMet = state.Year,
			})
		end
	end
	
	-- Special effects
	if effects.Special then
		-- Handle jail
		if effects.Special.GoToJail then
			state.InJail = true
			state.JailYearsLeft = effects.Special.GoToJail
			state.Job = nil
		end
		
		-- Handle release from jail
		if effects.Special.ReleaseFromJail then
			state.InJail = false
			state.JailYearsLeft = 0
		end
		
		-- Handle job loss
		if effects.Special.LoseJob then
			state.Job = nil
		end
		
		-- Handle divorce
		if effects.Special.Divorce then
			if state.Relationships.Partner then
				state:AddRelationship("ExPartner", state.Relationships.Partner)
				state.Relationships.Partner = nil
				state.Relationships.TotalDivorces = state.Relationships.TotalDivorces + 1
			end
		end
	end

	-- Clamp stats after all changes
	state:ClampStats()

	return resultText
end

----------------------------------------------------------------
-- UTILITY FUNCTIONS
----------------------------------------------------------------

-- Generate dynamic text with state-based replacements
function EventRunner.generateDynamicText(template, state)
	local text = template
	
	-- Replace placeholders
	text = text:gsub("{NAME}", state.Name or "You")
	text = text:gsub("{AGE}", tostring(state.Age or 0))
	text = text:gsub("{YEAR}", tostring(state.Year or 2025))
	text = text:gsub("{MONEY}", string.format("$%d", state.Money or 0))
	
	if state.Job then
		text = text:gsub("{JOB}", state.Job.title or "your job")
		text = text:gsub("{COMPANY}", state.Job.company or "work")
	else
		text = text:gsub("{JOB}", "work")
		text = text:gsub("{COMPANY}", "a company")
	end
	
	if state.Relationships.Partner then
		text = text:gsub("{PARTNER}", state.Relationships.Partner.name or "your partner")
	else
		text = text:gsub("{PARTNER}", "someone special")
	end
	
	return text
end

-- Calculate outcome probability for a choice
function EventRunner.calculateOutcomeProbability(state, choiceDef)
	local baseProbability = choiceDef.successChance or 0.5
	
	-- Stat-based modifiers
	if choiceDef.statModifiers then
		for statName, modifier in pairs(choiceDef.statModifiers) do
			local statValue = state.Stats[statName] or 50
			baseProbability = baseProbability + (statValue - 50) * modifier / 100
		end
	end
	
	-- Karma modifier
	if choiceDef.karmaAffected then
		local karmaBonus = ((state.Karma or 50) - 50) / 100
		baseProbability = baseProbability + karmaBonus * 0.1
	end
	
	-- Willpower modifier
	if choiceDef.willpowerAffected then
		local willpowerBonus = ((state.Willpower or 50) - 50) / 100
		baseProbability = baseProbability + willpowerBonus * 0.1
	end
	
	-- Clamp between 5% and 95%
	return math.max(0.05, math.min(0.95, baseProbability))
end

-- Roll for a probabilistic outcome
function EventRunner.rollOutcome(state, choiceDef)
	local probability = EventRunner.calculateOutcomeProbability(state, choiceDef)
	local roll = math.random()
	return roll < probability
end

-- Get a random event from a specific category
function EventRunner.pickEventByCategory(state, events, category)
	local filtered = {}
	
	for _, ev in ipairs(events) do
		if ev.category == category and checkConditions(state, ev) then
			table.insert(filtered, ev)
		end
	end
	
	if #filtered == 0 then
		return nil
	end
	
	return filtered[math.random(1, #filtered)]
end

-- Get event chains (events that are part of a story sequence)
function EventRunner.getNextChainEvent(state, events, chainId)
	local chainProgress = state:GetFlag("chain_" .. chainId .. "_progress") or 0
	
	for _, ev in ipairs(events) do
		if ev.chainId == chainId and ev.chainStep == (chainProgress + 1) then
			if checkConditions(state, ev) then
				return ev
			end
		end
	end
	
	return nil
end

-- Advance chain progress after completing a chain event
function EventRunner.advanceChain(state, chainId)
	local currentProgress = state:GetFlag("chain_" .. chainId .. "_progress") or 0
	state:SetFlag("chain_" .. chainId .. "_progress", currentProgress + 1)
end

return EventRunner
