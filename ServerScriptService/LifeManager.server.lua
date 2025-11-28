-- LifeManager.server.lua
-- Core life simulation with story paths + networking.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LifeState = require(ReplicatedStorage:WaitForChild("LifeState"))
local EventLibrary = require(ReplicatedStorage:WaitForChild("EventLibrary"))
local EventRunner = require(ReplicatedStorage:WaitForChild("EventRunner"))

-- Debug: verify EventRunner loaded correctly
if EventRunner then
	print("[LifeManager] EventRunner loaded, functions:", 
		EventRunner.getStoryPaths and "getStoryPaths✓" or "getStoryPaths✗",
		EventRunner.pickEvent and "pickEvent✓" or "pickEvent✗",
		EventRunner.initHistory and "initHistory✓" or "initHistory✗",
		EventRunner.applyChoice and "applyChoice✓" or "applyChoice✗"
	)
	-- List all functions in EventRunner
	local funcs = {}
	for k, v in pairs(EventRunner) do
		if type(v) == "function" then
			table.insert(funcs, k)
		end
	end
	print("[LifeManager] EventRunner has functions:", table.concat(funcs, ", "))
else
	warn("[LifeManager] EventRunner failed to load!")
end

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
local GetStoryPaths = getRemoteFunction("GetStoryPaths")
local GetSpecialActions = getRemoteFunction("GetSpecialActions")

----------------------------------------------------------------
-- STATE
----------------------------------------------------------------

local playerLives = {}  -- [Player] = LifeStateType

-- Forward declare serializeState
local function serializeState(state)
	state:ClampStats()

	-- Get story path info (with safety check)
	local paths = {}
	if EventRunner and EventRunner.getStoryPaths then
		paths = EventRunner.getStoryPaths(state)
	else
		paths = {
			political = { active = false, level = "None", progress = 0 },
			criminal = { active = false, level = "None", progress = 0 },
		}
	end

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
	}
end

-- Expose state getter for LifeRemoteHandlers integration
_G.GetPlayerLife = function(player)
	return playerLives[player]
end

-- Expose state push function for LifeRemoteHandlers
_G.PushPlayerState = function(player, lastFeedText)
	local state = playerLives[player]
	if state then
		SyncState:FireClient(player, serializeState(state), lastFeedText)
	end
end

local function pushState(player, state, lastFeedText)
	SyncState:FireClient(player, serializeState(state), lastFeedText)
end

local function getLife(player)
	local state = playerLives[player]
	if not state then
		state = LifeState.new(player)
		playerLives[player] = state
	end
	return state
end

local function createNewLife(player)
	local state = LifeState.new(player)
	-- Initialize event history and flags
	EventRunner.initHistory(state)
	playerLives[player] = state
	return state
end

-- Store pending event data for choice resolution
local pendingEvents = {} -- [Player] = { eventDef, dynamicData, choiceIndex }

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
-- AGE UP
----------------------------------------------------------------

local function ageUp(player)
	local state = getLife(player)

	if not state.Name then
		return
	end

	state.Age = state.Age + 1
	state.Year = state.Year + 1

	local ageText
	if state.Age == 1 then
		ageText = "You are now 1 year old."
	else
		ageText = string.format("You are now %d years old.", state.Age)
	end

	state:AddFeed(ageText)
	
	-- Reduce jail time if in jail (integration with LifeRemoteHandlers)
	if _G.ReduceJailTime then
		_G.ReduceJailTime(player, 1)
	end

	-- Add job income if has job
	if state.Job and state.JobSalary then
		state.Money = (state.Money or 0) + math.floor(state.JobSalary / 12) -- Monthly income
	end

	-- Initialize event history if needed
	EventRunner.initHistory(state)

	-- ALWAYS sync state first so client has updated Age
	pushState(player, state, ageText)
	
	-- Decide if a life event should fire
	local eventDef = EventRunner.pickEvent(state, EventLibrary.Events)
	if eventDef then
		-- Build client payload with dynamic data
		local payload, dynamicData = EventRunner.buildClientPayload(eventDef, state)
		
		-- Store for choice resolution
		pendingEvents[player] = {
			eventDef = eventDef,
			dynamicData = dynamicData or {},
			choiceIndex = nil,
		}
		
		-- Mark event as occurred (for one-time/cooldown tracking)
		EventRunner.markEventOccurred(state, eventDef)
		
		-- Present event (state already synced above)
		PresentEvent:FireClient(player, payload, nil)
	end
end

RequestAgeUp.OnServerEvent:Connect(function(player)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		return
	end

	ageUp(player)
end)

----------------------------------------------------------------
-- EVENT CHOICE HANDLING
----------------------------------------------------------------

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

	-- Validate choice index
	if type(choiceIndex) ~= "number" or choiceIndex < 1 or choiceIndex > #eventDef.choices then
		pushState(player, state, "Invalid choice.")
		return
	end

	local choice = eventDef.choices[choiceIndex]
	if not choice then
		pushState(player, state, "Choice not found.")
		return
	end

	-- Check if choice triggers a minigame
	if choice.minigame then
		-- Store choice for after minigame completes
		pending.choiceIndex = choiceIndex
		-- Client will handle minigame, then send MinigameResult
		return
	end

	-- Apply choice immediately
	local dynamicData = pending.dynamicData or {}
	
	-- Debug: verify choice exists
	local choiceDef = eventDef.choices and eventDef.choices[choiceIndex]
	if not choiceDef or type(choiceDef) ~= "table" then
		warn("[LifeManager] Invalid choice at index", choiceIndex, "for event", eventDef.id)
		pendingEvents[player] = nil
		pushState(player, state, "Choice error.")
		return
	end
	
	local results, err = EventRunner.applyChoice(state, eventDef, choiceIndex, dynamicData)
	
	if err then
		pushState(player, state, "Error: " .. tostring(err))
		pendingEvents[player] = nil
		return
	end

	-- Clear pending event
	pendingEvents[player] = nil

	local feedText = results and results.resultText or "Something happened..."
	state:AddFeed(feedText)
	pushState(player, state, feedText)
end)

----------------------------------------------------------------
-- MINIGAME RESULT HANDLING
----------------------------------------------------------------

MinigameResult.OnServerEvent:Connect(function(player, success, minigameData)
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

	-- Apply choice with minigame bonus if won
	local results, err = EventRunner.applyChoice(state, eventDef, choiceIndex, dynamicData)
	
	if err then
		pushState(player, state, "Error: " .. tostring(err))
		pendingEvents[player] = nil
		return
	end

	-- Modify results based on minigame success
	local feedText = results.resultText or "Something happened..."
	
	if success then
		-- Bonus for winning minigame
		if results.effects.Money then
			local bonus = math.floor(math.abs(results.effects.Money) * 0.5)
			state.Money = (state.Money or 0) + bonus
			feedText = feedText .. " (Minigame bonus: +" .. tostring(bonus) .. ")"
		end
		if results.effects.Happiness then
			state.Stats.Happiness = math.clamp((state.Stats.Happiness or 50) + 10, 0, 100)
		end
	else
		-- Penalty for losing minigame
		state.Stats.Happiness = math.clamp((state.Stats.Happiness or 50) - 10, 0, 100)
		feedText = feedText .. " (Minigame failed - morale down)"
	end

	-- Clear pending event
	pendingEvents[player] = nil

	state:AddFeed(feedText)
	pushState(player, state, feedText)
end)

----------------------------------------------------------------
-- STORY PATH API
----------------------------------------------------------------

GetStoryPaths.OnServerInvoke = function(player)
	local state = getLife(player)
	if not state then return {} end
	
	return EventRunner.getStoryPaths(state)
end

GetSpecialActions.OnServerInvoke = function(player)
	local state = getLife(player)
	if not state then return {} end
	
	return EventRunner.getSpecialActions(state)
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

DoSpecialAction.OnServerInvoke = function(player, actionId)
	local state = getLife(player)
	if not state or not state.Flags then
		return { success = false, message = "No active life." }
	end

	-- Presidential actions
	if actionId == "executive_order" and state.Flags.president then
		local orders = {
			"You signed an executive order on infrastructure!",
			"You issued an order protecting national parks!",
			"You signed an order boosting education funding!",
		}
		local msg = orders[math.random(#orders)]
		state:AddFeed(msg)
		state.Stats.Happiness = math.clamp((state.Stats.Happiness or 50) + 15, 0, 100)
		pushState(player, state, msg)
		return { success = true, message = msg }
		
	elseif actionId == "address_nation" and state.Flags.president then
		local msg = "You addressed the nation. Approval rating +5%!"
		state:AddFeed(msg)
		state.Stats.Happiness = math.clamp((state.Stats.Happiness or 50) + 10, 0, 100)
		pushState(player, state, msg)
		return { success = true, message = msg }
	end

	-- Criminal actions
	if actionId == "collect_debts" and state.Flags.gang_member then
		local success = math.random() > 0.3
		if success then
			local amount = math.random(5000, 20000)
			state.Money = (state.Money or 0) + amount
			local msg = "You collected $" .. amount .. " in debts."
			state:AddFeed(msg)
			pushState(player, state, msg)
			return { success = true, message = msg }
		else
			local msg = "The debtor fought back! You got nothing."
			state:AddFeed(msg)
			state.Stats.Health = math.clamp((state.Stats.Health or 50) - 10, 0, 100)
			pushState(player, state, msg)
			return { success = false, message = msg }
		end
		
	elseif actionId == "launder_money" and (state.Flags.underboss or state.Flags.crime_boss) then
		local amount = math.random(10000, 50000)
		state.Money = (state.Money or 0) + amount
		local msg = "You laundered $" .. amount .. " through shell companies."
		state:AddFeed(msg)
		pushState(player, state, msg)
		return { success = true, message = msg }
		
	elseif actionId == "order_hit" and (state.Flags.underboss or state.Flags.crime_boss) then
		local msg = "The hit was carried out successfully. Your rivals fear you."
		state:AddFeed(msg)
		state.Stats.Happiness = math.clamp((state.Stats.Happiness or 50) - 5, 0, 100)
		pushState(player, state, msg)
		return { success = true, message = msg }
	end

	return { success = false, message = "Action not available." }
end

print("[LifeManager] ✅ Life simulation server initialized!")
