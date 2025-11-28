-- LifeManager.server.lua
-- Core life simulation + networking.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LifeState = require(ReplicatedStorage:WaitForChild("LifeState"))
local EventLibrary = require(ReplicatedStorage:WaitForChild("EventLibrary"))
local EventRunner = require(ReplicatedStorage:WaitForChild("EventRunner"))

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

local RequestAgeUp = getRemote("RequestAgeUp")
local PresentEvent = getRemote("PresentEvent")
local SubmitChoice = getRemote("SubmitChoice")
local SyncState = getRemote("SyncState")
local SetLifeInfo = getRemote("SetLifeInfo")

----------------------------------------------------------------
-- STATE
----------------------------------------------------------------

local playerLives = {}  -- [Player] = LifeStateType

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

local function serializeState(state)
	state:ClampStats()

	-- Flatten stats for easier client access
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
	}
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
	playerLives[player] = state
	return state
end

----------------------------------------------------------------
-- PLAYER HANDLERS
----------------------------------------------------------------

Players.PlayerAdded:Connect(function(player)
	local state = createNewLife(player)
	-- No name yet; client will show "Create Your Life" overlay.
	pushState(player, state, nil)
end)

Players.PlayerRemoving:Connect(function(player)
	playerLives[player] = nil
end)

----------------------------------------------------------------
-- LIFE INFO (NAME + GENDER)
----------------------------------------------------------------

SetLifeInfo.OnServerEvent:Connect(function(player, name, gender)
	local state = getLife(player)
	if state.Name then
		-- already set, ignore
		return
	end

	-- must be a non-empty string
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

-- Store pending event data for choice resolution
local pendingEvents = {} -- [Player] = { eventDef, dynamicData }

local function ageUp(player)
	local state = getLife(player)

	if not state.Name then
		-- must create life first
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

	-- Initialize event history if needed
	EventRunner.initHistory(state)

	-- Decide if a life event should fire
	local eventDef = EventRunner.pickEvent(state, EventLibrary.Events)
	if eventDef then
		-- Build client payload with dynamic data
		local payload, dynamicData = EventRunner.buildClientPayload(eventDef, state)
		
		-- Store for choice resolution
		pendingEvents[player] = {
			eventDef = eventDef,
			dynamicData = dynamicData or {},
		}
		
		-- Mark event as occurred (for one-time/cooldown tracking)
		EventRunner.markEventOccurred(state, eventDef)
		
		PresentEvent:FireClient(player, payload, ageText)
	else
		pushState(player, state, ageText)
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

SubmitChoice.OnServerEvent:Connect(function(player, eventId, choiceId)
	local state = getLife(player)
	if not state.Name then
		return
	end

	local eventDef = EventLibrary.ById[eventId]
	if not eventDef then
		return
	end

	local choiceDef = nil
	for _, c in ipairs(eventDef.choices or {}) do
		if c.id == choiceId then
			choiceDef = c
			break
		end
	end
	if not choiceDef then
		return
	end

	-- Get stored dynamic data from when event was presented
	local dynamicData = {}
	if pendingEvents[player] and pendingEvents[player].eventDef.id == eventId then
		dynamicData = pendingEvents[player].dynamicData or {}
		pendingEvents[player] = nil -- Clear pending event
	end

	-- Apply choice with dynamic data
	local resultText = EventRunner.applyChoice(state, eventDef, choiceDef, dynamicData)
	state:AddFeed(resultText)
	pushState(player, state, resultText)
end)

-- Clean up pending events when player leaves
Players.PlayerRemoving:Connect(function(player)
	pendingEvents[player] = nil
end)
