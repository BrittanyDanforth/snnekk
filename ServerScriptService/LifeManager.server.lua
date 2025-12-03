-- LifeManager.server.lua
-- Core life simulation with story paths + networking.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LifeState = require(ReplicatedStorage:WaitForChild("LifeState"))
local LifeEventsFolder = ReplicatedStorage:WaitForChild("LifeEvents")
local LifeEvents = require(LifeEventsFolder:WaitForChild("init"))
local LifeStageSystem = require(ReplicatedStorage:WaitForChild("LifeStageSystem"))

----------------------------------------------------------------
-- REMOTES
----------------------------------------------------------------

local REMOTES_FOLDER_NAME = "LifeRemotes"

local remotesFolder = ReplicatedStorage:FindFirstChild(REMOTES_FOLDER_NAME)
if not remotesFolder then
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = REMOTES_FOLDER_NAME
	remotesFolder.Parent = ReplicatedStorage
end

local function getRemote(name)
	local existing = remotesFolder:FindFirstChild(name)
	if existing and existing:IsA("RemoteEvent") then
		return existing
	end
	local ev = Instance.new("RemoteEvent")
	ev.Name = name
	ev.Parent = remotesFolder
	return ev
end

local function getRemoteFunction(name)
	local existing = remotesFolder:FindFirstChild(name)
	if existing and existing:IsA("RemoteFunction") then
		return existing
	end
	local rf = Instance.new("RemoteFunction")
	rf.Name = name
	rf.Parent = remotesFolder
	return rf
end

local RequestAgeUp = getRemote("RequestAgeUp")
local PresentEvent = getRemote("PresentEvent")
local SubmitChoice = getRemote("SubmitChoice")
local SyncState = getRemote("SyncState")
local SetLifeInfo = getRemote("SetLifeInfo")
local MinigameResult = getRemote("MinigameResult")
local ShowResult = getRemote("ShowResult")  -- New: for result popups
local GetStoryPaths = getRemoteFunction("GetStoryPaths")
local GetSpecialActions = getRemoteFunction("GetSpecialActions")

local STORY_PATHS = {"political", "criminal", "teacher", "racer", "artist", "hacker"}

local function buildStoryPaths(state)
	local paths = {}
	for _, path in ipairs(STORY_PATHS) do
		local progress = 0
		local title = "None"
		if state.GetStoryProgress then
			progress = state:GetStoryProgress(path) or 0
		end
		if state.GetStoryTitle then
			title = state:GetStoryTitle(path) or "None"
		end
		paths[path] = {
			active = progress > 0,
			level = title,
			progress = progress,
		}
	end
	return paths
end

----------------------------------------------------------------
-- STATE
----------------------------------------------------------------

local playerLives = {}  -- [Player] = LifeStateType
local pendingEvents = {} -- [Player] = { eventDef, dynamicData, choiceIndex } -- MUST be declared before resetPlayerLife!
local eventQueues = {} -- [Player] = { events = {...}, current = 1 }
local DEFAULT_EVENT_CONFIG = {
	maxEvents = 2,
	guaranteeCareer = true,
	guaranteeMilestone = true,
}
local handleRandomDeath

-- Forward declare serializeState
local function serializeState(state, player)
	state:ClampStats()

	-- Get story path info via LifeState helpers
	local paths = buildStoryPaths(state)
	
	-- Get extended state from LifeRemoteHandlers (includes InJail, CurrentJob, Education, etc.)
	local extState = _G.GetExtendedState and player and _G.GetExtendedState(player) or {}

	-- Get education data
	local eduData = extState.EducationData or {}
	local enrolled = state.Enrolled or (eduData.Status == "enrolled") or false
	
	return {
		PlayerId = state.PlayerId,
		Name = state.Name,
		Gender = state.Gender,
		Age = state.Age,
		Year = state.Year,
		Money = state.Money,
		-- Flattened stats for screen modules
		Happiness = state.Stats.Happiness,
		Health = state.Stats.Health,
		Looks = state.Stats.Looks,
		Smarts = state.Stats.Smarts,
		-- Also include nested for compatibility
		Stats = state.Stats,
		-- Story paths
		StoryPaths = paths,
		-- Flags (for UI)
		Flags = state.Flags or {},
		-- Extended state from LifeRemoteHandlers (prison, jobs, education)
		InJail = extState.InJail or false,
		JailYearsLeft = extState.JailYearsLeft or 0,
		CurrentJob = extState.CurrentJob,
		Education = extState.Education or eduData.Level or "None",
		Enrolled = enrolled,
		-- Full education tracking data
		EducationData = {
			Level = eduData.Level,
			Institution = eduData.Institution,
			Major = eduData.Major,
			GPA = eduData.GPA,
			Progress = eduData.Progress,
			Debt = eduData.Debt,
			Year = eduData.Year,
			TotalYears = eduData.TotalYears,
			Status = eduData.Status,
			CreditsEarned = eduData.CreditsEarned,
			CreditsRequired = eduData.CreditsRequired,
		},
		-- Owned assets (properties, vehicles, items)
		Assets = {
			Properties = extState.OwnedProperties or {},
			Vehicles = extState.OwnedVehicles or {},
			Items = extState.OwnedItems or {},
			Crypto = extState.OwnedCrypto or {},
		},
		-- Relationships (family, friends, etc.)
		Relationships = state.Relationships or {},
	}
end

-- Expose state getter for LifeRemoteHandlers integration
_G.GetPlayerLife = function(player)
	return playerLives[player]
end

-- Expose state push function for LifeRemoteHandlers
_G.PushPlayerState = function(player, lastFeedText, resultData)
	local state = playerLives[player]
	if state then
		SyncState:FireClient(player, serializeState(state, player), lastFeedText, resultData)
	end
end

-- Push state with optional result data for popup
local function pushState(player, state, lastFeedText, resultData)
	SyncState:FireClient(player, serializeState(state, player), lastFeedText, resultData)
end

local function buildYearRecap(state)
	local stageSummary = LifeStageSystem.getStageSummary(state)
	local stageName = stageSummary and stageSummary.stage and stageSummary.stage.name or "life"
	return string.format("Life continues through %s.", stageName)
end

local function recordEventHistory(state, event)
	state.EventHistory = state.EventHistory or {
		seenEvents = {},
		lastOccurrence = {},
		milestonesFired = {},
		choicesMade = {},
	}
	local history = state.EventHistory
	history.seenEvents = history.seenEvents or {}
	history.lastOccurrence = history.lastOccurrence or {}
	history.milestonesFired = history.milestonesFired or {}

	if event and event.id then
		history.seenEvents[event.id] = true
		history.lastOccurrence[event.id] = state.Age or 0
		if event.milestone then
			history.milestonesFired[event.id] = true
		end
	end
end

local function buildEventPayload(state, event)
	if not event then
		return nil, nil
	end

	if event.isStageTransition then
		return {
			id = event.id,
			emoji = event.emoji or "🎉",
			title = event.title or "Milestone",
			text = event.text or "A new life stage begins.",
			category = "milestone",
			milestone = true,
			isStageTransition = true,
			choices = {
				{
					index = 1,
					id = "continue",
					text = "Continue",
					resultText = event.resultText or "Life goes on.",
				},
			},
		}, {}
	end

	local text, dynamicData = LifeEvents.getEventText(event, state)
	if not text or text == "" then
		text = event.text or "Something happens..."
	end
	local emoji = event.emoji or "📜"
	if event.getDynamicEmoji then
		local ok, dynamicEmoji = pcall(event.getDynamicEmoji, dynamicData or {})
		if ok and dynamicEmoji then
			emoji = dynamicEmoji
		end
	end

	local formattedChoices = {}
	if event.choices and #event.choices > 0 then
		for index, choice in ipairs(event.choices) do
			local choiceEntry = {
				index = index,
				id = choice.id or ("choice_" .. index),
				text = choice.text or ("Choice " .. index),
				resultText = choice.resultText,
				effects = choice.effects,
			}
			table.insert(formattedChoices, choiceEntry)
		end
	else
		table.insert(formattedChoices, {
			index = 1,
			id = "continue",
			text = "Continue",
			resultText = "Life goes on.",
		})
	end

	local payload = {
		id = event.id,
		emoji = emoji,
		title = event.title or "Life Event",
		text = text,
		category = event.category or "life",
		milestone = event.milestone,
		isStageTransition = event.isStageTransition,
		choices = formattedChoices,
	}

	return payload, dynamicData
end

local function presentQueuedEvent(player)
	local queue = eventQueues[player]
	if not queue then
		print("[LifeManager] presentQueuedEvent - no queue for", player.Name)
		return false
	end

	local entry = queue.events[queue.current]
	if not entry then
		print("[LifeManager] presentQueuedEvent - no entry at index", queue.current, "for", player.Name)
		eventQueues[player] = nil
		return false
	end

	print("[LifeManager] 📨 Presenting event", queue.current, "/", #queue.events, "-", entry.eventDef and entry.eventDef.id or "unknown", "to", player.Name)
	pendingEvents[player] = entry
	PresentEvent:FireClient(player, entry.payload, nil)
	return true
end

local function advanceEventQueue(player)
	local queue = eventQueues[player]
	if not queue then
		print("[LifeManager] advanceEventQueue - no queue for", player.Name)
		return false
	end

	queue.current += 1
	print("[LifeManager] 📋 Advancing event queue:", queue.current, "/", #queue.events, "for", player.Name)
	
	if queue.current > #queue.events then
		print("[LifeManager] ✅ Event queue completed for", player.Name)
		eventQueues[player] = nil
		return false
	end

	return presentQueuedEvent(player)
end

local function enqueueEvents(player, entries)
	if not entries or #entries == 0 then
		print("[LifeManager] enqueueEvents - no entries for", player.Name)
		eventQueues[player] = nil
		return false
	end

	print("[LifeManager] 📦 Enqueuing", #entries, "events for", player.Name)
	for i, entry in ipairs(entries) do
		print("[LifeManager]   Event", i, ":", entry.eventDef and entry.eventDef.id or "unknown")
	end
	
	eventQueues[player] = {
		events = entries,
		current = 1,
	}

	return presentQueuedEvent(player)
end

local function finalizeYear(player, state)
	if handleRandomDeath(player, state) then
		return
	end
	local recap = buildYearRecap(state) or "Life continues..."
	state:AddFeed(recap)
	pushState(player, state, recap)
end

local function buildStageTransitionEvent(oldAge, newAge)
	local transition = LifeStageSystem.getTransitionEvent(oldAge, newAge)
	if not transition then
		return nil
	end

	return {
		id = transition.id,
		emoji = transition.emoji,
		title = transition.title,
		text = transition.text,
		category = transition.category or "milestone",
		milestone = true,
		isStageTransition = true,
		choices = {
			{
				id = "continue",
				text = "Continue",
				resultText = "Life goes on.",
			},
		},
	}
end

-- Show a result popup to the player
local function showResultPopup(player, data)
	ShowResult:FireClient(player, data)
end

-- Expose for other scripts
_G.ShowResultPopup = showResultPopup

local function getLife(player)
	local state = playerLives[player]
	if not state then
		state = LifeState.new(player)
		playerLives[player] = state
	end
	return state
end

local function resetPlayerLife(player)
	print("[LifeManager] === RESETTING PLAYER LIFE ===")
	print("[LifeManager] Player:", player and player.Name or "NIL PLAYER")
	
	-- Validate player
	if not player then
		warn("[LifeManager] resetPlayerLife called with nil player!")
		return false
	end
	
	-- Create a completely new life state
	print("[LifeManager] Creating new LifeState...")
	local newState = LifeState.new(player)
	
	if not newState then
		warn("[LifeManager] Failed to create new LifeState!")
		return false
	end
	print("[LifeManager] New state created for:", newState.Name or "Unknown")
	
	-- Store in playerLives
	playerLives[player] = newState
	print("[LifeManager] Stored new state in playerLives")
	
	-- Clear pending events (pendingEvents is declared at top of file)
	if pendingEvents then
		pendingEvents[player] = nil
		print("[LifeManager] Cleared pending events")
	else
		warn("[LifeManager] pendingEvents table is nil!")
	end
	
	-- Reset extended state in LifeRemoteHandlers (jobs, education, assets, prison)
	if _G.ResetExtendedState then
		local ok, err = pcall(_G.ResetExtendedState, player)
		if ok then
			print("[LifeManager] Reset extended state")
		else
			warn("[LifeManager] Failed to reset extended state:", err)
		end
	end
	
	-- Sync the fresh state to client (will show intro screen again)
	-- THIS MUST HAPPEN even if extended state reset failed
	print("[LifeManager] Syncing state to client...")
	local serialized = serializeState(newState, player)
	SyncState:FireClient(player, serialized, "A new life begins...", nil)
	
	print("[LifeManager] ✅ Player", player.Name, "started a new life successfully!")
	return true
end

local function createNewLife(player)
	local state = LifeState.new(player)
	playerLives[player] = state
	return state
end

-- pendingEvents is declared at top of STATE section

----------------------------------------------------------------
-- PLAYER HANDLERS
----------------------------------------------------------------

Players.PlayerAdded:Connect(function(player)
	local state = createNewLife(player)
	pushState(player, state, nil)
end)

Players.PlayerRemoving:Connect(function(player)
	playerLives[player] = nil
	pendingEvents[player] = nil
end)

----------------------------------------------------------------
-- LIFE INFO (NAME + GENDER)
----------------------------------------------------------------

SetLifeInfo.OnServerEvent:Connect(function(player, name, gender)
	local state = getLife(player)
	if state.Name then
		return
	end

	if type(name) ~= "string" then
		return
	end
	name = name:match("^%s*(.-)%s*$") or name
	if name == "" then
		return
	end

	if type(gender) ~= "string" or gender == "" then
		gender = "Unknown"
	end

	local safeName = tostring(name)
	safeName = string.sub(safeName, 1, 18)

	state.Name = safeName
	state.Gender = gender

	local welcomeText = "Welcome to BloxLife!"
	local bornText = string.format("You were born as %s.", state.Name)

	state:AddFeed(welcomeText)
	state:AddFeed(bornText)

	pushState(player, state, bornText)
end)

----------------------------------------------------------------
-- LIFE SUMMARY GENERATOR
----------------------------------------------------------------

-- Local helper to format money
local function formatMoney(amount)
	if not amount then return "$0" end
	amount = math.floor(amount)
	if amount >= 1000000000 then
		return string.format("$%.1fB", amount / 1000000000)
	elseif amount >= 1000000 then
		return string.format("$%.1fM", amount / 1000000)
	elseif amount >= 1000 then
		return string.format("$%.1fK", amount / 1000)
	else
		return "$" .. tostring(amount)
	end
end

local function generateLifeSummary(state, deathCause)
	local flags = state.Flags or {}
	local achievements = {}
	local stats = state.Stats or {}
	
	-- Career achievements
	if flags.president then table.insert(achievements, "🏛️ Became President of the United States") end
	if flags.governor then table.insert(achievements, "🏛️ Served as State Governor") end
	if flags.us_senator then table.insert(achievements, "🏛️ Served in the U.S. Senate") end
	if flags.congressman then table.insert(achievements, "🏛️ Served in Congress") end
	if flags.mayor then table.insert(achievements, "🏙️ Served as Mayor") end
	
	if flags.crime_boss then table.insert(achievements, "💀 Became a Crime Boss") end
	if flags.gang_member then table.insert(achievements, "⛓️ Joined a Gang") end
	if flags.escaped_prison then table.insert(achievements, "🔓 Escaped from Prison") end
	
	if flags.f1_champion then table.insert(achievements, "🏎️ Won F1 World Championship") end
	if flags.f1_driver then table.insert(achievements, "🏎️ Became an F1 Driver") end
	if flags.karting_champion then table.insert(achievements, "🏎️ Won Karting Championship") end
	
	if flags.famous_artist then table.insert(achievements, "🎨 Became a Famous Artist") end
	if flags.museum_exhibit then table.insert(achievements, "🏛️ Had Art in a Museum") end
	
	if flags.elite_hacker then table.insert(achievements, "💻 Became an Elite Hacker") end
	if flags.white_hat then table.insert(achievements, "🛡️ Became a White Hat Security Expert") end
	if flags.black_hat then table.insert(achievements, "🖤 Became a Black Hat Hacker") end
	
	if flags.principal then table.insert(achievements, "📚 Became School Principal") end
	if flags.teacher then table.insert(achievements, "📚 Became a Teacher") end
	if flags.teacher_of_year then table.insert(achievements, "🏆 Won Teacher of the Year") end
	
	-- Life achievements
	if flags.married then table.insert(achievements, "💒 Got Married") end
	if flags.has_children then table.insert(achievements, "👶 Had Children") end
	if flags.homeowner then table.insert(achievements, "🏠 Owned a Home") end
	if flags.millionaire then table.insert(achievements, "💰 Became a Millionaire") end
	if flags.college_graduate then table.insert(achievements, "🎓 Graduated College") end
	if flags.doctorate then table.insert(achievements, "🎓 Earned a Doctorate") end
	
	-- Personality traits
	if flags.brave then table.insert(achievements, "🦁 Known for Bravery") end
	if flags.compassionate then table.insert(achievements, "❤️ Known for Compassion") end
	if flags.creative_mind then table.insert(achievements, "🎨 Creative Mind") end
	
	-- Build summary text
	local summaryParts = {}
	table.insert(summaryParts, string.format("💀 %s passed away at age %d from %s.", state.Name or "You", state.Age, deathCause))
	table.insert(summaryParts, "")
	
	-- Stats summary
	table.insert(summaryParts, "📊 Final Stats:")
	table.insert(summaryParts, string.format("   💰 Net Worth: $%s", formatMoney(state.Money or 0)))
	table.insert(summaryParts, string.format("   😊 Happiness: %d%%", stats.Happiness or 50))
	table.insert(summaryParts, string.format("   ❤️ Health: %d%%", stats.Health or 0))
	table.insert(summaryParts, string.format("   🧠 Smarts: %d%%", stats.Smarts or 50))
	table.insert(summaryParts, string.format("   ✨ Looks: %d%%", stats.Looks or 50))
	
	if #achievements > 0 then
		table.insert(summaryParts, "")
		table.insert(summaryParts, "🏆 Life Achievements:")
		for _, achievement in ipairs(achievements) do
			table.insert(summaryParts, "   " .. achievement)
		end
	end
	
	-- Life rating
	local score = 0
	score = score + (state.Age or 0) -- Points for longevity
	score = score + (#achievements * 10) -- Points for achievements
	score = score + math.floor((state.Money or 0) / 10000) -- Points for wealth
	score = score + (stats.Happiness or 0) -- Points for happiness
	
	local rating = "F"
	if score >= 500 then rating = "S+"
	elseif score >= 400 then rating = "S"
	elseif score >= 300 then rating = "A+"
	elseif score >= 250 then rating = "A"
	elseif score >= 200 then rating = "B+"
	elseif score >= 150 then rating = "B"
	elseif score >= 100 then rating = "C+"
	elseif score >= 75 then rating = "C"
	elseif score >= 50 then rating = "D"
	end
	
	table.insert(summaryParts, "")
	table.insert(summaryParts, string.format("⭐ Life Rating: %s (Score: %d)", rating, score))
	
	return {
		summaryText = table.concat(summaryParts, "\n"),
		achievements = achievements,
		score = score,
		rating = rating,
		age = state.Age,
		name = state.Name,
		cause = deathCause,
		money = state.Money or 0,
	}
end

----------------------------------------------------------------
-- IMMEDIATE DEATH CHECK (Call after stat modifications)
-- Returns true if player died, false otherwise
----------------------------------------------------------------

local function checkAndHandleImmediateDeath(player, state, lastActionText)
	-- Check if health has dropped to 0% or below
	local stats = state.Stats or {}
	local health = stats.Health or 0
	
	if health > 0 then
		return false -- Still alive
	end
	
	-- Player's health hit 0% - they die immediately
	print("[LifeManager] ⚠️ IMMEDIATE DEATH TRIGGERED - Health hit 0% for", player.Name)
	
	-- Mark as dead
	state.IsDead = true
	state:SetFlag("deceased")
	
	-- Get contextual death cause from the enhanced death system
	local deathCheck = LifeStageSystem.checkDeath(state)
	local deathCause = deathCheck.cause or "complications from poor health"
	
	-- Generate life summary
	local lifeSummary = generateLifeSummary(state, deathCause)
	
	-- Build death payload
	local deathPayload = {
		id = "death",
		emoji = "💀",
		title = "Rest In Peace",
		text = lifeSummary.summaryText,
		category = "death",
		isDeath = true,
		isImmediateDeath = true,
		lifeSummary = lifeSummary,
		lastAction = lastActionText,
		choices = {
			{ index = 1, text = "🔄 Start New Life", effects = {}, result = "Begin again..." }
		}
	}
	
	-- Store pending death event
	pendingEvents[player] = {
		eventDef = { id = "death", category = "death" },
		dynamicData = {},
		choiceIndex = nil,
		isDeath = true,
		deathCause = deathCause,
		lifeSummary = lifeSummary,
	}
	
	-- Add to feed and notify client
	state:AddFeed("💀 " .. (state.Name or "You") .. " has passed away from " .. deathCause .. " at age " .. (state.Age or 0))
	PresentEvent:FireClient(player, deathPayload, nil)
	
	return true -- Player died
end

handleRandomDeath = function(player, state)
	local deathCheck = LifeStageSystem.checkDeath(state)
	if not deathCheck.died then
		return false
	end

	state.IsDead = true
	state:SetFlag("deceased")

	local lifeSummary = generateLifeSummary(state, deathCheck.cause)
	local deathPayload = {
		id = "death",
		emoji = "💀",
		title = "Rest In Peace",
		text = lifeSummary.summaryText,
		category = "death",
		isDeath = true,
		lifeSummary = lifeSummary,
		choices = {
			{ index = 1, text = "🔄 Start New Life", effects = {}, result = "Begin again..." }
		}
	}

	pendingEvents[player] = {
		eventDef = { id = "death", category = "death" },
		dynamicData = {},
		choiceIndex = nil,
		isDeath = true,
		deathCause = deathCheck.cause,
		lifeSummary = lifeSummary,
	}

	state:AddFeed("💀 " .. state.Name .. " has passed away from " .. deathCheck.cause .. " at age " .. state.Age)
	PresentEvent:FireClient(player, deathPayload, nil)
	return true
end

-- Expose for other scripts that modify stats
_G.CheckImmediateDeath = function(player, lastActionText)
	local state = playerLives[player]
	if state then
		return checkAndHandleImmediateDeath(player, state, lastActionText)
	end
	return false
end

----------------------------------------------------------------
-- AGE UP
----------------------------------------------------------------

local function ageUp(player)
	local state = getLife(player)
	if not state.Name or state.IsDead then
		return
	end

	local oldAge = state.Age
	state.Age += 1
	state.Year += 1
	local newAge = state.Age

	print("[LifeManager] === AGE UP ===")
	print("[LifeManager] Player:", player.Name, "Old Age:", oldAge, "New Age:", newAge)

	local ageText = state.Age == 1 and "You are now 1 year old." or string.format("You are now %d years old.", state.Age)
	state:AddFeed(ageText)

	if _G.ReduceJailTime then
		_G.ReduceJailTime(player, 1)
	end

	if _G.OnPlayerAgeUp then
		_G.OnPlayerAgeUp(player)
	end

	if _G.ProgressPlayerEducation then
		local eduResult = _G.ProgressPlayerEducation(player)
		if eduResult and eduResult.message then
			state:AddFeed(eduResult.message)
		end
	end

	local extState = _G.GetExtendedState and _G.GetExtendedState(player)
	if extState and extState.CurrentJob then
		state.Money = (state.Money or 0) + math.floor(extState.CurrentJob.salary / 12)
	elseif state.Job and state.JobSalary then
		state.Money = (state.Money or 0) + math.floor(state.JobSalary / 12)
	end

	state:ClampStats()

	pushState(player, state, ageText)

	local queueEntries = {}
	local transitionEvent = buildStageTransitionEvent(oldAge, newAge)
	if transitionEvent then
		state:AddFeed(transitionEvent.title .. " - " .. transitionEvent.text)
		local payload = buildEventPayload(state, transitionEvent)
		table.insert(queueEntries, {
			eventDef = transitionEvent,
			event = transitionEvent,
			payload = payload,
			dynamicData = {},
			isStageTransition = true,
		})
	end

	local selectedEvents = LifeEvents.selectEventsForYear(state, DEFAULT_EVENT_CONFIG) or {}
	for _, eventDef in ipairs(selectedEvents) do
		local validation = LifeStageSystem.validateEvent(eventDef, state)
		if validation.valid then
			local payload, dynamicData = buildEventPayload(state, eventDef)
			if payload then
				recordEventHistory(state, eventDef)
				table.insert(queueEntries, {
					eventDef = eventDef,
					event = eventDef,
					payload = payload,
					dynamicData = dynamicData or {},
				})
			end
		else
			print(string.format("[LifeManager] Event %s failed validation: %s", eventDef.id or "unknown", table.concat(validation.reasons or {}, ", ")))
		end
	end

	if #queueEntries > 0 then
		if not enqueueEvents(player, queueEntries) then
			eventQueues[player] = nil
		end
		return
	end

	local quietYearText = buildYearRecap(state) or "Life continues..."
	state:AddFeed(quietYearText)

	if handleRandomDeath(player, state) then
		return
	end

	pushState(player, state, quietYearText)
end

RequestAgeUp.OnServerEvent:Connect(function(player)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		return
	end

	-- Check if player has pending events - prevent age up while events are in queue
	if eventQueues[player] and eventQueues[player].events and #eventQueues[player].events > 0 then
		local currentIdx = eventQueues[player].current or 1
		local totalEvents = #eventQueues[player].events
		print("[LifeManager] ⚠️ RequestAgeUp blocked - pending events:", currentIdx, "/", totalEvents, "for", player.Name)
		
		-- Try to re-present the current event in case client missed it
		local queue = eventQueues[player]
		local entry = queue.events[queue.current]
		if entry and entry.payload then
			print("[LifeManager] 🔄 Re-presenting event:", entry.eventDef and entry.eventDef.id or "unknown")
			pendingEvents[player] = entry
			PresentEvent:FireClient(player, entry.payload, nil)
		end
		return
	end
	
	-- Check if there's a pending death event
	if pendingEvents[player] and pendingEvents[player].isDeath then
		print("[LifeManager] ⚠️ RequestAgeUp blocked - death event pending for", player.Name)
		return
	end

	print("[LifeManager] ✅ RequestAgeUp accepted for", player.Name)
	ageUp(player)
end)

----------------------------------------------------------------
-- EVENT CHOICE HANDLING (COMPLETE OVERHAUL)
----------------------------------------------------------------

-- Create MinigameStart remote for triggering minigames on client
local MinigameStart = getRemote("MinigameStart")

-- Process world actions from event results
local function processWorldActions(player, worldActions, dynamicData)
	if not worldActions or type(worldActions) ~= "table" then return end
	
	for _, action in ipairs(worldActions) do
		if action.type == "spawnPet" then
			-- Spawn a pet for the player
			if _G.SpawnLifePetForPlayer then
				_G.SpawnLifePetForPlayer(player, action.petType or "Dog")
			end
			print("[LifeManager] Spawned pet:", action.petType)
			
		elseif action.type == "playSfx" then
			-- Play sound effect (client will handle)
			local PlaySfx = remotesFolder:FindFirstChild("PlaySfx")
			if PlaySfx then
				PlaySfx:FireClient(player, action.sfxName)
			end
			
		elseif action.type == "screenEffect" then
			-- Screen shake, flash, etc.
			local ScreenEffect = remotesFolder:FindFirstChild("ScreenEffect")
			if ScreenEffect then
				ScreenEffect:FireClient(player, action.effectName, action.params)
			end
			
		elseif action.type == "unlockAchievement" then
			-- Unlock achievement
			if _G.UnlockAchievement then
				_G.UnlockAchievement(player, action.achievementId)
			end
		end
	end
end

SubmitChoice.OnServerEvent:Connect(function(player, eventId, choiceIndex)
	local state = getLife(player)
	if not state.Name then
		return
	end

	-- Get pending event data
	local pending = pendingEvents[player]
	if not pending then
		pushState(player, state, "Event not found.")
		return
	end
	
	local eventDef = pending.eventDef
	if not eventDef or eventDef.id ~= eventId then
		pushState(player, state, "Event mismatch.")
		return
	end

	if pending.isStageTransition then
		pendingEvents[player] = nil
		if not advanceEventQueue(player) then
			finalizeYear(player, state)
		end
		return
	end
	
	if pending.isDeath then
		pendingEvents[player] = nil
		resetPlayerLife(player)
		return
	end
	
	local choices = eventDef.choices or {}
	if type(choiceIndex) ~= "number" or not choices[choiceIndex] then
		pushState(player, state, "Invalid choice.")
		return
	end
	
	local choiceDef = choices[choiceIndex]
	local dynamicData = pending.dynamicData or {}
	
	if choiceDef.minigame and not pending.minigameCompleted then
		pending.choiceIndex = choiceIndex
		local minigameConfig
		if type(choiceDef.minigame) == "table" then
			minigameConfig = {
				id = choiceDef.minigame.id or "typing",
				difficulty = choiceDef.minigame.difficulty or "medium",
				eventId = eventId,
				choiceIndex = choiceIndex,
				rewardOnSuccess = choiceDef.minigame.rewardOnSuccess,
				rewardOnFail = choiceDef.minigame.rewardOnFail,
			}
		else
			minigameConfig = {
				id = choiceDef.minigame,
				difficulty = "medium",
				eventId = eventId,
				choiceIndex = choiceIndex,
			}
		end
		MinigameStart:FireClient(player, minigameConfig)
		return
	end
	
	local beforeStats = {
		Happiness = state.Stats.Happiness or 50,
		Health = state.Stats.Health or 100,
		Smarts = state.Stats.Smarts or 50,
		Looks = state.Stats.Looks or 50,
	}
	local beforeMoney = state.Money or 0
	
	local results, err = LifeEvents.processChoice(eventDef, choiceIndex, state)
	if err then
		pushState(player, state, "❌ " .. tostring(err))
		pendingEvents[player] = nil
		return
	end
	
	state.EventHistory = state.EventHistory or {}
	state.EventHistory.choicesMade = state.EventHistory.choicesMade or {}
	if eventDef.id then
		state.EventHistory.choicesMade[eventDef.id] = choiceIndex
	end
	
	if _G.SyncPrisonStateFromFlags then
		_G.SyncPrisonStateFromFlags(player)
	end
	
	local feedText = choiceDef.resultText or string.format("You chose %s.", choiceDef.text or "an option.")
	if results and results.messages then
		for _, message in ipairs(results.messages) do
			if message and message ~= "" then
				state:AddFeed(message)
			end
		end
	end
	state:AddFeed(feedText)
	
	if checkAndHandleImmediateDeath(player, state, feedText) then
		return
	end
	
	pendingEvents[player] = nil
	
	local happinessDelta = (state.Stats.Happiness or 50) - beforeStats.Happiness
	local healthDelta = (state.Stats.Health or 100) - beforeStats.Health
	local smartsDelta = (state.Stats.Smarts or 50) - beforeStats.Smarts
	local looksDelta = (state.Stats.Looks or 50) - beforeStats.Looks
	local moneyDelta = (state.Money or 0) - beforeMoney
	
	local significantChange = eventDef.milestone
		or math.abs(happinessDelta) >= 10
		or math.abs(healthDelta) >= 10
		or math.abs(moneyDelta) >= 1000
	
	local resultData = nil
	if significantChange then
		resultData = {
			showPopup = true,
			emoji = eventDef.emoji or "📋",
			title = eventDef.title or "Life Event",
			body = feedText,
			happiness = happinessDelta ~= 0 and happinessDelta or nil,
			health = healthDelta ~= 0 and healthDelta or nil,
			smarts = smartsDelta ~= 0 and smartsDelta or nil,
			looks = looksDelta ~= 0 and looksDelta or nil,
			money = moneyDelta ~= 0 and moneyDelta or nil,
		}
	end
	
	pushState(player, state, feedText, resultData)
	
	if not advanceEventQueue(player) then
		finalizeYear(player, state)
	end
end)

----------------------------------------------------------------
-- MINIGAME RESULT HANDLING (OVERHAULED)
----------------------------------------------------------------

MinigameResult.OnServerEvent:Connect(function(player, minigameSuccess, minigameData)
	local state = getLife(player)
	if not state.Name then
		return
	end

	local pending = pendingEvents[player]
	if not pending or not pending.choiceIndex then
		pushState(player, state, "No minigame pending.")
		return
	end

	local eventDef = pending.eventDef
	local choiceIndex = pending.choiceIndex
	local dynamicData = pending.dynamicData or {}
	local choiceDef = eventDef.choices and eventDef.choices[choiceIndex]
	
	-- Apply choice WITH the minigame result (true = won, false = lost)
	local beforeStats = {
		Happiness = state.Stats.Happiness or 50,
		Health = state.Stats.Health or 100,
		Smarts = state.Stats.Smarts or 50,
		Looks = state.Stats.Looks or 50,
	}
	local beforeMoney = state.Money or 0

	local results, err = LifeEvents.processChoice(eventDef, choiceIndex, state)
	
	if err then
		pushState(player, state, "Error: " .. tostring(err))
		pendingEvents[player] = nil
		return
	end

	state.EventHistory = state.EventHistory or {}
	state.EventHistory.choicesMade = state.EventHistory.choicesMade or {}
	if eventDef.id then
		state.EventHistory.choicesMade[eventDef.id] = choiceIndex
	end

	if _G.SyncPrisonStateFromFlags then
		_G.SyncPrisonStateFromFlags(player)
	end

	local feedText = (choiceDef and choiceDef.resultText) or "Something happened..."
	if minigameSuccess then
		feedText = feedText .. " 🎮 Minigame mastered!"
	else
		feedText = feedText .. " 🎮 Minigame failed..."
	end

	if results and results.messages then
		for _, message in ipairs(results.messages) do
			if message and message ~= "" then
				state:AddFeed(message)
			end
		end
	end
	state:AddFeed(feedText)

	if checkAndHandleImmediateDeath(player, state, feedText) then
		return
	end

	pendingEvents[player] = nil

	local happinessDelta = (state.Stats.Happiness or 50) - beforeStats.Happiness
	local healthDelta = (state.Stats.Health or 100) - beforeStats.Health
	local smartsDelta = (state.Stats.Smarts or 50) - beforeStats.Smarts
	local looksDelta = (state.Stats.Looks or 50) - beforeStats.Looks
	local moneyDelta = (state.Money or 0) - beforeMoney

	local resultData = {
		showPopup = true,
		emoji = minigameSuccess and "🏆" or "😞",
		title = minigameSuccess and "Minigame Success!" or "Minigame Failed",
		body = feedText,
		happiness = happinessDelta ~= 0 and happinessDelta or nil,
		health = healthDelta ~= 0 and healthDelta or nil,
		smarts = smartsDelta ~= 0 and smartsDelta or nil,
		looks = looksDelta ~= 0 and looksDelta or nil,
		money = moneyDelta ~= 0 and moneyDelta or nil,
		wasSuccess = minigameSuccess,
	}

	pushState(player, state, feedText, resultData)
	if not advanceEventQueue(player) then
		finalizeYear(player, state)
	end
end)

----------------------------------------------------------------
-- STORY PATH API
----------------------------------------------------------------

GetStoryPaths.OnServerInvoke = function(player)
	local state = getLife(player)
	if not state then return {} end
	return buildStoryPaths(state)
end

GetSpecialActions.OnServerInvoke = function(player)
	local state = getLife(player)
	if not state then
		return {}
	end
	return {}
end

----------------------------------------------------------------
-- SPECIAL ACTIONS (For story paths)
----------------------------------------------------------------

local function createSpecialActionRemote(name)
	local rf = remotesFolder:FindFirstChild(name)
	if not rf then
		rf = Instance.new("RemoteFunction")
		rf.Name = name
		rf.Parent = remotesFolder
	end
	return rf
end

local DoSpecialAction = createSpecialActionRemote("DoSpecialAction")
-- NOTE: DoInteraction is handled by LifeRemoteHandlers.server.lua - don't create duplicate here!

DoSpecialAction.OnServerInvoke = function(player, actionId)
	local state = getLife(player)
	if not state or not state.Flags then
		return { success = false, message = "No active life." }
	end

	-- Presidential actions
	if actionId == "executive_order" and state.Flags.president then
		local orders = {
			{ text = "You signed an executive order on infrastructure!", emoji = "🏗️" },
			{ text = "You issued an order protecting national parks!", emoji = "🌲" },
			{ text = "You signed an order boosting education funding!", emoji = "📚" },
		}
		local chosen = orders[math.random(#orders)]
		state:AddFeed(chosen.text)
		state.Stats.Happiness = math.clamp((state.Stats.Happiness or 50) + 15, 0, 100)
		
		-- Show popup
		showResultPopup(player, {
			emoji = chosen.emoji,
			title = "Executive Order Signed!",
			body = chosen.text,
			happiness = 15,
		})
		pushState(player, state, chosen.text)
		return { success = true, message = chosen.text }
		
	elseif actionId == "address_nation" and state.Flags.president then
		local msg = "You addressed the nation in a televised speech. Approval rating up!"
		state:AddFeed(msg)
		state.Stats.Happiness = math.clamp((state.Stats.Happiness or 50) + 10, 0, 100)
		
		showResultPopup(player, {
			emoji = "📺",
			title = "Address to the Nation",
			body = msg,
			happiness = 10,
		})
		pushState(player, state, msg)
		return { success = true, message = msg }
	end

	-- Criminal actions
	if actionId == "collect_debts" and state.Flags.gang_member then
		local success = math.random() > 0.3
		if success then
			local amount = math.random(5000, 20000)
			state.Money = (state.Money or 0) + amount
			local msg = "You collected $" .. amount .. " in debts. They paid up without much trouble."
			state:AddFeed(msg)
			
			showResultPopup(player, {
				emoji = "💰",
				title = "Debt Collection",
				body = msg,
				money = amount,
			})
			pushState(player, state, msg)
			return { success = true, message = msg }
		else
			local msg = "The debtor fought back! You got roughed up and got nothing."
			state:AddFeed(msg)
			state.Stats.Health = math.clamp((state.Stats.Health or 50) - 10, 0, 100)
			
			showResultPopup(player, {
				emoji = "🤕",
				title = "Debt Collection Failed",
				body = msg,
				health = -10,
			})
			pushState(player, state, msg)
			return { success = false, message = msg }
		end
		
	elseif actionId == "launder_money" and (state.Flags.underboss or state.Flags.crime_boss) then
		local amount = math.random(10000, 50000)
		state.Money = (state.Money or 0) + amount
		local msg = "You successfully laundered $" .. amount .. " through shell companies."
		state:AddFeed(msg)
		
		showResultPopup(player, {
			emoji = "🏦",
			title = "Money Laundering",
			body = msg,
			money = amount,
		})
		pushState(player, state, msg)
		return { success = true, message = msg }
		
	elseif actionId == "order_hit" and (state.Flags.underboss or state.Flags.crime_boss) then
		local msg = "The hit was carried out successfully. Your rivals will think twice before crossing you again."
		state:AddFeed(msg)
		state.Stats.Happiness = math.clamp((state.Stats.Happiness or 50) - 5, 0, 100)
		
		showResultPopup(player, {
			emoji = "🎯",
			title = "Hit Ordered",
			body = msg,
			happiness = -5,
		})
		pushState(player, state, msg)
		return { success = true, message = msg }
	end

	return { success = false, message = "Action not available." }
end


----------------------------------------------------------------
-- STAT MODIFICATION HELPERS (Global API for other scripts)
-- These all check for immediate death after modification
----------------------------------------------------------------

_G.ModifyPlayerStat = function(player, statName, delta, reason)
	local state = playerLives[player]
	if not state then return false end
	
	if statName == "Money" then
		state.Money = (state.Money or 0) + delta
	elseif state.Stats and state.Stats[statName] ~= nil then
		state.Stats[statName] = math.clamp((state.Stats[statName] or 50) + delta, 0, 100)
	else
		return false
	end
	
	-- Check for death if health was modified
	if statName == "Health" then
		if checkAndHandleImmediateDeath(player, state, reason or "Stat change") then
			return true, true -- success, died
		end
	end
	
	return true, false -- success, not died
end

_G.SetPlayerStat = function(player, statName, value, reason)
	local state = playerLives[player]
	if not state then return false end
	
	if statName == "Money" then
		state.Money = value
	elseif state.Stats and state.Stats[statName] ~= nil then
		state.Stats[statName] = math.clamp(value, 0, 100)
	else
		return false
	end
	
	-- Check for death if health was set to 0
	if statName == "Health" then
		if checkAndHandleImmediateDeath(player, state, reason or "Stat change") then
			return true, true -- success, died
		end
	end
	
	return true, false -- success, not died
end

print("[LifeManager] ✅ Life simulation server initialized with enhanced death system!")
