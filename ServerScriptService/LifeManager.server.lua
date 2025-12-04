--[[
	LifeManager.server.lua
	AAA BitLife-Style Core Game Loop
	
	Handles:
	- Player state management
	- Age progression
	- Event selection and presentation
	- Choice processing
	- Death handling
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--------------------------------------------------------------------------------
-- MODULES
--------------------------------------------------------------------------------

local LifeState = require(ReplicatedStorage:WaitForChild("LifeState"))
local LifeStageSystem = require(ReplicatedStorage:WaitForChild("LifeStageSystem"))
local LifeEvents = require(ReplicatedStorage:WaitForChild("LifeEvents"))

--------------------------------------------------------------------------------
-- REMOTES
--------------------------------------------------------------------------------

local remotesFolder = Instance.new("Folder")
remotesFolder.Name = "LifeRemotes"
remotesFolder.Parent = ReplicatedStorage

local function createRemote(name, isFunction)
	local remote
	if isFunction then
		remote = Instance.new("RemoteFunction")
	else
		remote = Instance.new("RemoteEvent")
	end
	remote.Name = name
	remote.Parent = remotesFolder
	return remote
end

-- Core remotes
local RequestAgeUp = createRemote("RequestAgeUp")
local PresentEvent = createRemote("PresentEvent")
local SubmitChoice = createRemote("SubmitChoice")
local SyncState = createRemote("SyncState")
local SetLifeInfo = createRemote("SetLifeInfo")
local ShowResult = createRemote("ShowResult")

-- Minigame remotes
local MinigameStart = createRemote("MinigameStart")
local MinigameResult = createRemote("MinigameResult")

-- Job/Career remotes
local ApplyForJob = createRemote("ApplyForJob")
local QuitJob = createRemote("QuitJob")
local DoWork = createRemote("DoWork")
local RequestPromotion = createRemote("RequestPromotion")
local RequestRaise = createRemote("RequestRaise")
local GetCareerInfo = createRemote("GetCareerInfo", true)

-- Education remotes
local EnrollEducation = createRemote("EnrollEducation")
local GetEducationInfo = createRemote("GetEducationInfo", true)

-- Assets remotes
local BuyAsset = createRemote("BuyAsset")
local SellAsset = createRemote("SellAsset")
local GetAssets = createRemote("GetAssets", true)

-- Relationships remotes
local InteractRelationship = createRemote("InteractRelationship")
local GetRelationships = createRemote("GetRelationships", true)

-- Activities remotes
local DoActivity = createRemote("DoActivity")

-- Crime remotes
local CommitCrime = createRemote("CommitCrime")
local EscapePrison = createRemote("EscapePrison")

-- Story paths remote
local GetStoryPaths = createRemote("GetStoryPaths", true)

--------------------------------------------------------------------------------
-- STATE MANAGEMENT
--------------------------------------------------------------------------------

local playerStates = {}     -- PlayerId -> LifeState
local pendingEvents = {}    -- PlayerId -> {event, ...}
local currentEvents = {}    -- PlayerId -> current event being shown

local function getState(player)
	local userId = player.UserId
	if not playerStates[userId] then
		playerStates[userId] = LifeState.new(player)
	end
	return playerStates[userId]
end

-- Expose getState globally for remote handlers
_G.GetLifeState = getState

--------------------------------------------------------------------------------
-- STATE SYNC
--------------------------------------------------------------------------------

local function syncState(player, feedText, resultData)
	local state = getState(player)
	
	-- Build client-friendly state
	local clientState = {
		Name = state.Name,
		Gender = state.Gender,
		Age = state.Age,
		Year = state.Year,
		Money = state.Money,
		IsDead = state.IsDead,
		
		-- Stats
		Happiness = state.Stats.Happiness,
		Health = state.Stats.Health,
		Smarts = state.Stats.Smarts,
		Looks = state.Stats.Looks,
		Stats = state.Stats,
		
		-- Flags for UI
		Flags = state.Flags,
		
		-- Career info
		Career = state.Career,
		Education = state.Education,
		
		-- Relationships count
		RelationshipsCount = 0,
		
		-- Assets summary
		PropertyCount = #state.Assets.properties,
		VehicleCount = #state.Assets.vehicles,
		
		-- Prison status
		InPrison = state.Criminal.inPrison,
		JailTime = state.Criminal.yearsLeft,
		
		-- Fame
		Fame = state.Fame,
	}
	
	-- Count relationships
	for _ in pairs(state.Relationships) do
		clientState.RelationshipsCount = clientState.RelationshipsCount + 1
	end
	
	SyncState:FireClient(player, clientState, feedText, resultData)
end

-- Expose syncState globally
_G.SyncPlayerState = syncState

--------------------------------------------------------------------------------
-- EVENT QUEUE
--------------------------------------------------------------------------------

local function queueEvent(player, event)
	local userId = player.UserId
	pendingEvents[userId] = pendingEvents[userId] or {}
	table.insert(pendingEvents[userId], event)
end

local function hasQueuedEvents(player)
	local queue = pendingEvents[player.UserId]
	return queue and #queue > 0
end

local function getNextEvent(player)
	local queue = pendingEvents[player.UserId]
	if queue and #queue > 0 then
		return table.remove(queue, 1)
	end
	return nil
end

--------------------------------------------------------------------------------
-- EVENT PRESENTATION
--------------------------------------------------------------------------------

local function buildEventPayload(state, event)
	local text, dynamicData = LifeEvents.getEventText(event, state)
	
	return {
		id = event.id,
		emoji = event.emoji or "🙂",
		title = event.title or "Life Event",
		text = text,
		category = event.category,
		question = event.question or "What will you do?",
		choices = event.choices,
		showRelationship = event.showRelationship,
		relationName = event.relationName,
		relationship = event.relationship,
	}
end

local function presentNextEvent(player)
	local event = getNextEvent(player)
	if not event then
		return false
	end
	
	local state = getState(player)
	local payload = buildEventPayload(state, event)
	
	currentEvents[player.UserId] = event
	PresentEvent:FireClient(player, payload)
	return true
end

--------------------------------------------------------------------------------
-- DEATH HANDLING
--------------------------------------------------------------------------------

local function handleDeath(player, cause)
	local state = getState(player)
	state.IsDead = true
	
	local obituary = string.format(
		"💀 %s passed away at age %d. Cause: %s.",
		state.Name or "Unknown",
		state.Age,
		cause or "natural causes"
	)
	
	state:AddFeed(obituary)
	
	ShowResult:FireClient(player, {
		emoji = "💀",
		title = "Game Over",
		body = obituary,
		health = -100,
		showPopup = true,
	})
	
	syncState(player, obituary)
	
	-- Reset for new life after a delay
	task.delay(3, function()
		if player and player.Parent then
			playerStates[player.UserId] = LifeState.new(player)
			syncState(player, "A new life begins...")
		end
	end)
end

--------------------------------------------------------------------------------
-- AGE UP LOGIC
--------------------------------------------------------------------------------

local function ageUp(player)
	local state = getState(player)
	
	-- Can't age up without a name
	if not state.Name then return end
	
	-- Can't age up if dead
	if state.IsDead then return end
	
	-- Can't age up if events are pending
	if hasQueuedEvents(player) or currentEvents[player.UserId] then
		return
	end
	
	-- Increment age
	local oldAge = state.Age
	state.Age = state.Age + 1
	state.Year = state.Year + 1
	
	-- Build age message
	local ageText = state.Age == 1 
		and "You are now 1 year old." 
		or string.format("You are now %d years old.", state.Age)
	
	state:AddFeed(ageText)
	
	-- Reduce prison sentence
	if state:IsInPrison() then
		state:ServeTime(1)
		if not state:IsInPrison() then
			state:AddFeed("🎉 You've been released from prison!")
		end
	end
	
	-- Job income
	if state:HasJob() and not state:IsInPrison() then
		local income = math.floor(state.Career.salary / 12)
		state:AddMoney(income)
	end
	
	-- Education progression
	if state.Education.enrolled then
		state.Education.yearsCompleted = state.Education.yearsCompleted + 1
		
		-- Check for graduation
		local level = state.Education.level
		local years = state.Education.yearsCompleted
		
		if level == "high_school" and years >= 4 then
			state:Graduate("high_school")
			state:AddFeed("🎓 You graduated from High School!")
		elseif level == "community" and years >= 2 then
			state:Graduate("community")
			state:AddFeed("🎓 You earned your Associate's Degree!")
		elseif level == "bachelor" and years >= 4 then
			state:Graduate("bachelor")
			state:AddFeed("🎓 You earned your Bachelor's Degree!")
		elseif level == "master" and years >= 2 then
			state:Graduate("master")
			state:AddFeed("🎓 You earned your Master's Degree!")
		elseif level == "law" and years >= 3 then
			state:Graduate("law")
			state:AddFeed("🎓 You passed the bar exam! You're now an Attorney!")
		elseif level == "medical" and years >= 4 then
			state:Graduate("medical")
			state:AddFeed("🎓 You completed medical school! You're now a Doctor!")
		end
	end
	
	-- Auto-enroll in school
	if state.Age == 5 and not state.Education.enrolled then
		state:Enroll("elementary", "Elementary School", nil)
		state:AddFeed("🏫 You started elementary school!")
	elseif state.Age == 10 and state.Education.level == "elementary" then
		state:Enroll("middle", "Middle School", nil)
		state:AddFeed("🏫 You started middle school!")
	elseif state.Age == 14 and state.Education.level == "middle" then
		state:Enroll("high_school", "High School", nil)
		state:AddFeed("🏫 You started high school!")
	end
	
	state:ClampStats()
	
	-- Get stage transition event
	local transitionEvent = LifeStageSystem.getTransitionEvent(oldAge, state.Age)
	if transitionEvent then
		queueEvent(player, transitionEvent)
	end
	
	-- Get random events for this year
	local events = LifeEvents.selectEventsForYear(state, { maxEvents = 2 })
	for _, event in ipairs(events) do
		queueEvent(player, event)
	end
	
	-- Present first event or sync state
	if hasQueuedEvents(player) then
		syncState(player, ageText)
		presentNextEvent(player)
	else
		-- Check for death
		local deathCheck = LifeStageSystem.checkDeath(state)
		if deathCheck.died then
			handleDeath(player, deathCheck.cause)
		else
			syncState(player, ageText)
		end
	end
end

--------------------------------------------------------------------------------
-- CHOICE PROCESSING
--------------------------------------------------------------------------------

local function processChoice(player, eventId, choiceIndex)
	local state = getState(player)
	local event = currentEvents[player.UserId]
	
	-- Validate
	if not event or event.id ~= eventId then
		return
	end
	
	-- Clear current event
	currentEvents[player.UserId] = nil
	
	-- Process the choice
	local results, err = LifeEvents.processChoice(event, choiceIndex, state)
	
	if results then
		local choice = event.choices[choiceIndex]
		local resultText = choice.resultText or "Life goes on."
		
		state:AddFeed(resultText)
		state:ClampStats()
		
		-- Build result data for popup
		local resultData = nil
		if choice.showResult ~= false then
			resultData = {
				showPopup = true,
				emoji = choice.resultEmoji or event.emoji or "📋",
				title = choice.resultTitle or "What Happened",
				body = resultText,
				happiness = results.statChanges.Happiness and results.statChanges.Happiness.change,
				health = results.statChanges.Health and results.statChanges.Health.change,
				smarts = results.statChanges.Smarts and results.statChanges.Smarts.change,
				looks = results.statChanges.Looks and results.statChanges.Looks.change,
				money = results.statChanges.Money and results.statChanges.Money.change,
			}
		end
		
		syncState(player, resultText, resultData)
	end
	
	-- Present next event or check death
	if hasQueuedEvents(player) then
		presentNextEvent(player)
	else
		local deathCheck = LifeStageSystem.checkDeath(state)
		if deathCheck.died then
			handleDeath(player, deathCheck.cause)
		end
	end
end

--------------------------------------------------------------------------------
-- REMOTE HANDLERS
--------------------------------------------------------------------------------

RequestAgeUp.OnServerEvent:Connect(function(player)
	ageUp(player)
end)

SubmitChoice.OnServerEvent:Connect(function(player, eventId, choiceIndex)
	processChoice(player, eventId, choiceIndex)
end)

SetLifeInfo.OnServerEvent:Connect(function(player, name, gender)
	local state = getState(player)
	
	state.Name = name
	state.Gender = gender
	
	-- Generate starter relationships
	local parentGender1 = gender == "Male" and "Father" or "Mother"
	local parentGender2 = gender == "Male" and "Mother" or "Father"
	
	state:AddRelationship("family", {
		name = parentGender1 == "Father" and "Your Father" or "Your Mother",
		relationship = parentGender1,
		age = math.random(25, 35),
		gender = parentGender1 == "Father" and "Male" or "Female",
		closeness = 80,
	})
	
	state:AddRelationship("family", {
		name = parentGender2 == "Father" and "Your Father" or "Your Mother",
		relationship = parentGender2,
		age = math.random(25, 35),
		gender = parentGender2 == "Father" and "Male" or "Female",
		closeness = 80,
	})
	
	state:AddFeed("🎉 A new life begins!")
	
	syncState(player, "A new life begins!")
end)

--------------------------------------------------------------------------------
-- PLAYER CONNECTIONS
--------------------------------------------------------------------------------

Players.PlayerAdded:Connect(function(player)
	local state = getState(player)
	
	task.defer(function()
		syncState(player)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	local userId = player.UserId
	
	-- Clean up
	playerStates[userId] = nil
	pendingEvents[userId] = nil
	currentEvents[userId] = nil
end)

-- Handle players already in game
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(function()
		local state = getState(player)
		syncState(player)
	end)
end

print("[LifeManager] ✅ AAA BitLife Backend Initialized")
