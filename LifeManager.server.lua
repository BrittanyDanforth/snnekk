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

local remotesFolder = ReplicatedStorage:FindFirstChild("LifeRemotes")
if not remotesFolder then
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "LifeRemotes"
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

local function serializeState(state)
	state:ClampStats()

	return {
		PlayerId = state.PlayerId,
		Name = state.Name,
		Gender = state.Gender,
		Age = state.Age,
		Year = state.Year,
		Money = state.Money,
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
		ageText = "You are now 1 years old."
	else
		ageText = string.format("You are now %d years old.", state.Age)
	end

	state:AddFeed(ageText)

	-- decide if a life event should fire
	local eventDef = EventRunner.pickEvent(state, EventLibrary.Events)
	if eventDef then
		local payload = EventRunner.buildClientPayload(eventDef)
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

	local resultText = EventRunner.applyChoice(state, eventDef, choiceDef)
	state:AddFeed(resultText)
	pushState(player, state, resultText)
end)
