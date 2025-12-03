--[[
	LifeManager.server.lua
	Core life simulation server - BitLife-style game loop
	
	Architecture:
	- Players have a LifeState (stats, money, flags, relationships)
	- Each year, events are selected and presented
	- Choices apply effects and advance the story
	- Death triggers life summary and restart
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Core modules
local LifeState = require(ReplicatedStorage:WaitForChild("LifeState"))
local LifeEvents = require(ReplicatedStorage:WaitForChild("LifeEvents"))
local LifeStageSystem = require(ReplicatedStorage:WaitForChild("LifeStageSystem"))

--------------------------------------------------------------------------------
-- REMOTES
--------------------------------------------------------------------------------

local remotesFolder = ReplicatedStorage:FindFirstChild("LifeRemotes") or Instance.new("Folder")
remotesFolder.Name = "LifeRemotes"
remotesFolder.Parent = ReplicatedStorage

local function getRemote(name)
	local r = remotesFolder:FindFirstChild(name)
	if r and r:IsA("RemoteEvent") then return r end
	local ev = Instance.new("RemoteEvent")
	ev.Name = name
	ev.Parent = remotesFolder
	return ev
end

local function getRemoteFunction(name)
	local r = remotesFolder:FindFirstChild(name)
	if r and r:IsA("RemoteFunction") then return r end
	local rf = Instance.new("RemoteFunction")
	rf.Name = name
	rf.Parent = remotesFolder
	return rf
end

-- Core remotes
local RequestAgeUp = getRemote("RequestAgeUp")
local PresentEvent = getRemote("PresentEvent")
local SubmitChoice = getRemote("SubmitChoice")
local SyncState = getRemote("SyncState")
local SetLifeInfo = getRemote("SetLifeInfo")
local MinigameResult = getRemote("MinigameResult")
local MinigameStart = getRemote("MinigameStart")
local ShowResult = getRemote("ShowResult")
local GetStoryPaths = getRemoteFunction("GetStoryPaths")

--------------------------------------------------------------------------------
-- STATE
--------------------------------------------------------------------------------

local playerLives = {}   -- [Player] = LifeState
local pendingEvents = {} -- [Player] = { eventDef, payload, dynamicData, ... }
local eventQueues = {}   -- [Player] = { events = {...}, current = 1 }

local EVENT_CONFIG = {
	maxEvents = 2,
	guaranteeCareer = true,
	guaranteeMilestone = true,
}

--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------

local function formatMoney(amount)
	amount = math.floor(amount or 0)
	if amount >= 1e9 then return string.format("$%.1fB", amount / 1e9)
	elseif amount >= 1e6 then return string.format("$%.1fM", amount / 1e6)
	elseif amount >= 1e3 then return string.format("$%.1fK", amount / 1e3)
	else return "$" .. amount end
end

local function buildStoryPaths(state)
	local paths = {}
	for _, path in ipairs({"political", "criminal", "teacher", "racer", "artist", "hacker"}) do
		local progress = state.GetStoryProgress and state:GetStoryProgress(path) or 0
		local title = state.GetStoryTitle and state:GetStoryTitle(path) or "None"
		paths[path] = { active = progress > 0, level = title, progress = progress }
	end
	return paths
end

local function serializeState(state, player)
	state:ClampStats()
	local ext = _G.GetExtendedState and _G.GetExtendedState(player) or {}
	local edu = ext.EducationData or {}
	
	return {
		PlayerId = state.PlayerId,
		Name = state.Name,
		Gender = state.Gender,
		Age = state.Age,
		Year = state.Year,
		Money = state.Money,
		Happiness = state.Stats.Happiness,
		Health = state.Stats.Health,
		Looks = state.Stats.Looks,
		Smarts = state.Stats.Smarts,
		Stats = state.Stats,
		StoryPaths = buildStoryPaths(state),
		Flags = state.Flags or {},
		InJail = ext.InJail or false,
		JailYearsLeft = ext.JailYearsLeft or 0,
		CurrentJob = ext.CurrentJob,
		Education = ext.Education or edu.Level or "None",
		Enrolled = state.Enrolled or (edu.Status == "enrolled") or false,
		EducationData = edu,
		Assets = {
			Properties = ext.OwnedProperties or {},
			Vehicles = ext.OwnedVehicles or {},
			Items = ext.OwnedItems or {},
			Crypto = ext.OwnedCrypto or {},
		},
		Relationships = state.Relationships or {},
	}
end

local function pushState(player, state, feedText, resultData)
	SyncState:FireClient(player, serializeState(state, player), feedText, resultData)
end

local function getLife(player)
	local state = playerLives[player]
	if not state then
		state = LifeState.new(player)
		playerLives[player] = state
	end
	return state
end

--------------------------------------------------------------------------------
-- EVENT PAYLOAD BUILDING
--------------------------------------------------------------------------------

local function buildEventPayload(state, event)
	if not event then return nil end
	
	-- Stage transition events
	if event.isStageTransition then
		return {
			id = event.id,
			emoji = event.emoji or "🎉",
			title = event.title or "Milestone",
			text = event.text or "A new chapter begins.",
			category = "milestone",
			milestone = true,
			isStageTransition = true,
			choices = {{ index = 1, id = "continue", text = "Continue", resultText = "Life goes on." }},
		}, {}
	end
	
	-- Normal events
	local text, dynamicData = LifeEvents.getEventText(event, state)
	text = (text and text ~= "") and text or (event.text or "Something happens...")
	
	local emoji = event.emoji or "📜"
	if event.getDynamicEmoji then
		local ok, de = pcall(event.getDynamicEmoji, dynamicData or {})
		if ok and de then emoji = de end
	end
	
	local choices = {}
	if event.choices and #event.choices > 0 then
		for i, c in ipairs(event.choices) do
			choices[i] = { index = i, id = c.id or ("choice_" .. i), text = c.text or ("Choice " .. i), resultText = c.resultText, effects = c.effects }
		end
	else
		choices[1] = { index = 1, id = "continue", text = "Continue", resultText = "Life goes on." }
	end
	
	return {
		id = event.id,
		emoji = emoji,
		title = event.title or "Life Event",
		text = text,
		category = event.category or "life",
		milestone = event.milestone,
		choices = choices,
	}, dynamicData
end

--------------------------------------------------------------------------------
-- EVENT QUEUE MANAGEMENT
--------------------------------------------------------------------------------

local function presentQueuedEvent(player)
	local queue = eventQueues[player]
	if not queue then return false end
	
	local entry = queue.events[queue.current]
	if not entry then
		eventQueues[player] = nil
		return false
	end
	
	pendingEvents[player] = entry
	PresentEvent:FireClient(player, entry.payload, nil)
	return true
end

local function advanceEventQueue(player)
	local queue = eventQueues[player]
	if not queue then return false end
	
	queue.current += 1
	if queue.current > #queue.events then
		eventQueues[player] = nil
		return false
	end
	
	return presentQueuedEvent(player)
end

local function enqueueEvents(player, entries)
	if not entries or #entries == 0 then
		eventQueues[player] = nil
		return false
	end
	
	eventQueues[player] = { events = entries, current = 1 }
	return presentQueuedEvent(player)
end

--------------------------------------------------------------------------------
-- DEATH SYSTEM
--------------------------------------------------------------------------------

local function generateLifeSummary(state, cause)
	local flags = state.Flags or {}
	local stats = state.Stats or {}
	local achievements = {}
	
	-- Collect achievements from flags
	local achievementMap = {
		president = "🏛️ Became President", governor = "🏛️ Served as Governor",
		crime_boss = "💀 Became Crime Boss", f1_champion = "🏎️ Won F1 Championship",
		famous_artist = "🎨 Became Famous Artist", elite_hacker = "💻 Elite Hacker",
		married = "💒 Got Married", millionaire = "💰 Became Millionaire",
		college_graduate = "🎓 College Graduate", doctorate = "🎓 Earned Doctorate",
	}
	for flag, text in pairs(achievementMap) do
		if flags[flag] then table.insert(achievements, text) end
	end
	
	-- Calculate score
	local score = (state.Age or 0) + (#achievements * 10) + math.floor((state.Money or 0) / 10000) + (stats.Happiness or 0)
	local rating = score >= 400 and "S" or score >= 300 and "A" or score >= 200 and "B" or score >= 100 and "C" or "D"
	
	local lines = {
		string.format("💀 %s passed away at age %d from %s.", state.Name or "You", state.Age, cause),
		"",
		"📊 Final Stats:",
		string.format("   💰 Net Worth: %s", formatMoney(state.Money)),
		string.format("   😊 Happiness: %d%%", stats.Happiness or 0),
		string.format("   ❤️ Health: %d%%", stats.Health or 0),
	}
	
	if #achievements > 0 then
		table.insert(lines, "")
		table.insert(lines, "🏆 Achievements:")
		for _, a in ipairs(achievements) do table.insert(lines, "   " .. a) end
	end
	
	table.insert(lines, "")
	table.insert(lines, string.format("⭐ Life Rating: %s (Score: %d)", rating, score))
	
	return {
		summaryText = table.concat(lines, "\n"),
		achievements = achievements,
		score = score,
		rating = rating,
		age = state.Age,
		name = state.Name,
		cause = cause,
		money = state.Money or 0,
	}
end

local function handleDeath(player, state, cause)
	state.IsDead = true
	state:SetFlag("deceased")
	
	local summary = generateLifeSummary(state, cause)
	local payload = {
		id = "death",
		emoji = "💀",
		title = "Rest In Peace",
		text = summary.summaryText,
		category = "death",
		isDeath = true,
		lifeSummary = summary,
		choices = {{ index = 1, text = "🔄 Start New Life" }},
	}
	
	pendingEvents[player] = { eventDef = { id = "death" }, isDeath = true, lifeSummary = summary }
	state:AddFeed("💀 " .. (state.Name or "You") .. " passed away from " .. cause .. " at age " .. state.Age)
	PresentEvent:FireClient(player, payload, nil)
	return true
end

local function checkDeath(player, state)
	-- Immediate death at 0 health
	if (state.Stats.Health or 0) <= 0 then
		local check = LifeStageSystem.checkDeath(state)
		return handleDeath(player, state, check.cause or "health complications")
	end
	
	-- Random death check
	local check = LifeStageSystem.checkDeath(state)
	if check.died then
		return handleDeath(player, state, check.cause)
	end
	
	return false
end

local function resetPlayerLife(player)
	local newState = LifeState.new(player)
	playerLives[player] = newState
	pendingEvents[player] = nil
	eventQueues[player] = nil
	
	if _G.ResetExtendedState then pcall(_G.ResetExtendedState, player) end
	
	SyncState:FireClient(player, serializeState(newState, player), "A new life begins...", nil)
	return true
end

--------------------------------------------------------------------------------
-- AGE UP
--------------------------------------------------------------------------------

local function ageUp(player)
	local state = getLife(player)
	if not state.Name or state.IsDead then return end
	
	local oldAge = state.Age
	state.Age += 1
	state.Year += 1
	
	local ageText = state.Age == 1 and "You are now 1 year old." or string.format("You are now %d years old.", state.Age)
	state:AddFeed(ageText)
	
	-- External hooks
	if _G.ReduceJailTime then _G.ReduceJailTime(player, 1) end
	if _G.OnPlayerAgeUp then _G.OnPlayerAgeUp(player) end
	
	-- Education progression
	if _G.ProgressPlayerEducation then
		local r = _G.ProgressPlayerEducation(player)
		if r and r.message then state:AddFeed(r.message) end
	end
	
	-- Job income
	local ext = _G.GetExtendedState and _G.GetExtendedState(player)
	if ext and ext.CurrentJob then
		state.Money = (state.Money or 0) + math.floor(ext.CurrentJob.salary / 12)
	end
	
	state:ClampStats()
	pushState(player, state, ageText)
	
	-- Build event queue
	local entries = {}
	
	-- Stage transition
	local transition = LifeStageSystem.getTransitionEvent(oldAge, state.Age)
	if transition then
		local payload = buildEventPayload(state, {
			id = transition.id, emoji = transition.emoji, title = transition.title,
			text = transition.text, category = "milestone", milestone = true, isStageTransition = true,
			choices = {{ id = "continue", text = "Continue" }},
		})
		table.insert(entries, { eventDef = transition, payload = payload, isStageTransition = true })
	end
	
	-- Random events
	local events = LifeEvents.selectEventsForYear(state, EVENT_CONFIG) or {}
	for _, ev in ipairs(events) do
		local validation = LifeStageSystem.validateEvent(ev, state)
		if validation.valid then
			local payload, data = buildEventPayload(state, ev)
			if payload then
				-- Record in history
				state.EventHistory = state.EventHistory or { seenEvents = {}, lastOccurrence = {}, milestonesFired = {} }
				if ev.id then
					state.EventHistory.seenEvents[ev.id] = true
					state.EventHistory.lastOccurrence[ev.id] = state.Age
					if ev.milestone then state.EventHistory.milestonesFired[ev.id] = true end
				end
				table.insert(entries, { eventDef = ev, payload = payload, dynamicData = data or {} })
			end
		end
	end
	
	-- Present events or finalize year
	if #entries > 0 then
		enqueueEvents(player, entries)
	else
		local recap = LifeStageSystem.getStageSummary(state)
		local text = string.format("Life continues through %s.", recap and recap.stage and recap.stage.name or "life")
		state:AddFeed(text)
		if not checkDeath(player, state) then
			pushState(player, state, text)
		end
	end
end

local function finalizeYear(player, state)
	local recap = LifeStageSystem.getStageSummary(state)
	local text = string.format("Life continues through %s.", recap and recap.stage and recap.stage.name or "life")
	state:AddFeed(text)
	if not checkDeath(player, state) then
		pushState(player, state, text)
	end
end

--------------------------------------------------------------------------------
-- EVENT HANDLERS
--------------------------------------------------------------------------------

RequestAgeUp.OnServerEvent:Connect(function(player)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then return end
	
	-- Block if events pending
	if eventQueues[player] and eventQueues[player].events and #eventQueues[player].events > 0 then
		local queue = eventQueues[player]
		local entry = queue.events[queue.current]
		if entry and entry.payload then
			pendingEvents[player] = entry
			PresentEvent:FireClient(player, entry.payload, nil)
		end
		return
	end
	
	-- Block if death pending
	if pendingEvents[player] and pendingEvents[player].isDeath then return end
	
	ageUp(player)
end)

SetLifeInfo.OnServerEvent:Connect(function(player, name, gender)
	local state = getLife(player)
	if state.Name then return end
	
	if type(name) ~= "string" or name:match("^%s*$") then return end
	name = string.sub(name:match("^%s*(.-)%s*$") or name, 1, 18)
	
	state.Name = name
	state.Gender = type(gender) == "string" and gender ~= "" and gender or "Unknown"
	
	local text = string.format("You were born as %s.", state.Name)
	state:AddFeed("Welcome to BloxLife!")
	state:AddFeed(text)
	pushState(player, state, text)
end)

SubmitChoice.OnServerEvent:Connect(function(player, eventId, choiceIndex)
	local state = getLife(player)
	if not state.Name then return end
	
	local pending = pendingEvents[player]
	if not pending then return pushState(player, state, "Event not found.") end
	
	local eventDef = pending.eventDef
	if not eventDef or eventDef.id ~= eventId then return pushState(player, state, "Event mismatch.") end
	
	-- Stage transition
	if pending.isStageTransition then
		pendingEvents[player] = nil
		if not advanceEventQueue(player) then finalizeYear(player, state) end
		return
	end
	
	-- Death restart
	if pending.isDeath then
		pendingEvents[player] = nil
		resetPlayerLife(player)
		return
	end
	
	-- Validate choice
	local choices = eventDef.choices or {}
	if type(choiceIndex) ~= "number" or not choices[choiceIndex] then
		return pushState(player, state, "Invalid choice.")
	end
	
	local choice = choices[choiceIndex]
	
	-- Minigame check
	if choice.minigame and not pending.minigameCompleted then
		pending.choiceIndex = choiceIndex
		local cfg = type(choice.minigame) == "table" and choice.minigame or { id = choice.minigame }
		MinigameStart:FireClient(player, {
			id = cfg.id or "typing",
			difficulty = cfg.difficulty or "medium",
			eventId = eventId,
			choiceIndex = choiceIndex,
		})
		return
	end
	
	-- Track before stats
	local before = {
		Happiness = state.Stats.Happiness or 50,
		Health = state.Stats.Health or 100,
		Smarts = state.Stats.Smarts or 50,
		Looks = state.Stats.Looks or 50,
		Money = state.Money or 0,
	}
	
	-- Process choice
	local results = LifeEvents.processChoice(eventDef, choiceIndex, state)
	
	-- Record choice
	state.EventHistory = state.EventHistory or { choicesMade = {} }
	state.EventHistory.choicesMade = state.EventHistory.choicesMade or {}
	if eventDef.id then state.EventHistory.choicesMade[eventDef.id] = choiceIndex end
	
	-- Sync prison state
	if _G.SyncPrisonStateFromFlags then _G.SyncPrisonStateFromFlags(player) end
	
	-- Feed text
	local feedText = choice.resultText or string.format("You chose %s.", choice.text or "an option.")
	if results and results.messages then
		for _, msg in ipairs(results.messages) do
			if msg and msg ~= "" then state:AddFeed(msg) end
		end
	end
	state:AddFeed(feedText)
	
	-- Death check
	if checkDeath(player, state) then return end
	
	pendingEvents[player] = nil
	
	-- Calculate deltas
	local deltas = {
		happiness = (state.Stats.Happiness or 50) - before.Happiness,
		health = (state.Stats.Health or 100) - before.Health,
		smarts = (state.Stats.Smarts or 50) - before.Smarts,
		looks = (state.Stats.Looks or 50) - before.Looks,
		money = (state.Money or 0) - before.Money,
	}
	
	-- Show result popup for significant changes
	local significant = eventDef.milestone or math.abs(deltas.happiness) >= 10 or math.abs(deltas.health) >= 10 or math.abs(deltas.money) >= 1000
	local resultData = significant and {
		showPopup = true,
		emoji = eventDef.emoji or "📋",
		title = eventDef.title or "Result",
		body = feedText,
		happiness = deltas.happiness ~= 0 and deltas.happiness or nil,
		health = deltas.health ~= 0 and deltas.health or nil,
		smarts = deltas.smarts ~= 0 and deltas.smarts or nil,
		looks = deltas.looks ~= 0 and deltas.looks or nil,
		money = deltas.money ~= 0 and deltas.money or nil,
	} or nil
	
	pushState(player, state, feedText, resultData)
	
	if not advanceEventQueue(player) then
		finalizeYear(player, state)
	end
end)

MinigameResult.OnServerEvent:Connect(function(player, success, data)
	local state = getLife(player)
	if not state.Name then return end
	
	local pending = pendingEvents[player]
	if not pending or not pending.choiceIndex then return end
	
	local eventDef = pending.eventDef
	local choice = eventDef.choices and eventDef.choices[pending.choiceIndex]
	
	-- Track before
	local before = {
		Happiness = state.Stats.Happiness or 50,
		Health = state.Stats.Health or 100,
		Money = state.Money or 0,
	}
	
	-- Process
	LifeEvents.processChoice(eventDef, pending.choiceIndex, state)
	if _G.SyncPrisonStateFromFlags then _G.SyncPrisonStateFromFlags(player) end
	
	local feedText = (choice and choice.resultText or "Something happened...") .. (success and " 🎮 Success!" or " 🎮 Failed...")
	state:AddFeed(feedText)
	
	if checkDeath(player, state) then return end
	
	pendingEvents[player] = nil
	
	local resultData = {
		showPopup = true,
		emoji = success and "🏆" or "😞",
		title = success and "Minigame Success!" or "Minigame Failed",
		body = feedText,
		happiness = (state.Stats.Happiness or 50) - before.Happiness,
		health = (state.Stats.Health or 100) - before.Health,
		money = (state.Money or 0) - before.Money,
		wasSuccess = success,
	}
	
	pushState(player, state, feedText, resultData)
	
	if not advanceEventQueue(player) then
		finalizeYear(player, state)
	end
end)

GetStoryPaths.OnServerInvoke = function(player)
	local state = getLife(player)
	return state and buildStoryPaths(state) or {}
end

--------------------------------------------------------------------------------
-- PLAYER LIFECYCLE
--------------------------------------------------------------------------------

Players.PlayerAdded:Connect(function(player)
	local state = LifeState.new(player)
	playerLives[player] = state
	pushState(player, state, nil)
end)

Players.PlayerRemoving:Connect(function(player)
	playerLives[player] = nil
	pendingEvents[player] = nil
	eventQueues[player] = nil
end)

--------------------------------------------------------------------------------
-- GLOBAL API (for other scripts)
--------------------------------------------------------------------------------

_G.GetPlayerLife = function(player) return playerLives[player] end

_G.PushPlayerState = function(player, feedText, resultData)
	local state = playerLives[player]
	if state then pushState(player, state, feedText, resultData) end
end

_G.ShowResultPopup = function(player, data)
	ShowResult:FireClient(player, data)
end

_G.CheckImmediateDeath = function(player, reason)
	local state = playerLives[player]
	if state then return checkDeath(player, state) end
	return false
end

_G.ModifyPlayerStat = function(player, stat, delta, reason)
	local state = playerLives[player]
	if not state then return false end
	
	if stat == "Money" then
		state.Money = (state.Money or 0) + delta
	elseif state.Stats[stat] then
		state.Stats[stat] = math.clamp((state.Stats[stat] or 50) + delta, 0, 100)
	else
		return false
	end
	
	if stat == "Health" then
		return true, checkDeath(player, state)
	end
	return true, false
end

print("[LifeManager] ✅ Initialized")
