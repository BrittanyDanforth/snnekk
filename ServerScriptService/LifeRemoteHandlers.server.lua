-- ServerScriptService / LifeRemoteHandlers.server.lua
-- Handles all the new remotes for Occupation, Assets, Relationships, Activities
-- This validates player age, money, requirements before allowing actions
-- Integrates with LifeManager's state system

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for LifeState module
local LifeState = require(ReplicatedStorage:WaitForChild("LifeState"))

-- Create or get remotes folder (don't just wait - create if needed!)
local REMOTES_FOLDER_NAME = "LifeRemotes"
local remotesFolder = ReplicatedStorage:FindFirstChild(REMOTES_FOLDER_NAME)
if not remotesFolder then
	-- Wait a bit for LifeManager to create it
	remotesFolder = ReplicatedStorage:WaitForChild(REMOTES_FOLDER_NAME, 5)
end
if not remotesFolder then
	-- Still doesn't exist, create it ourselves
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = REMOTES_FOLDER_NAME
	remotesFolder.Parent = ReplicatedStorage
	print("[LifeRemoteHandlers] Created LifeRemotes folder")
end

-- Reference to LifeManager's playerLives (set via _G for inter-script communication)
-- This allows us to modify the same state that LifeManager uses
local function getLifeManagerState(player)
	-- Try to get state from LifeManager via _G
	if _G.GetPlayerLife then
		return _G.GetPlayerLife(player)
	end
	return nil
end

-- Helper to get remotes safely
local function getRemote(name, isFunction)
	local remote = remotesFolder:FindFirstChild(name)
	
	-- Check if existing remote is wrong type
	if remote then
		local isCorrectType = (isFunction and remote:IsA("RemoteFunction")) or (not isFunction and remote:IsA("RemoteEvent"))
		if not isCorrectType then
			remote:Destroy()
			remote = nil
		end
	end
	
	if not remote then
		if isFunction then
			remote = Instance.new("RemoteFunction")
		else
			remote = Instance.new("RemoteEvent")
		end
		remote.Name = name
		remote.Parent = remotesFolder
		print("[LifeRemoteHandlers] Created remote:", name, isFunction and "(Function)" or "(Event)")
	end
	return remote
end

-- Load LifeStageSystem for capability checks
local LifeStageSystem = require(ReplicatedStorage:WaitForChild("LifeStageSystem"))

-- Get all remotes
local GetCapabilities = getRemote("GetCapabilities", true)
local ApplyForJob = getRemote("ApplyForJob", true)
local QuitJob = getRemote("QuitJob", false)
local DoWork = getRemote("DoWork", true)
local EnrollEducation = getRemote("EnrollEducation", true)
local DoFreelance = getRemote("DoFreelance", true)
local TrySpecialCareer = getRemote("TrySpecialCareer", true)

local BuyProperty = getRemote("BuyProperty", true)
local BuyVehicle = getRemote("BuyVehicle", true)
local BuyItem = getRemote("BuyItem", true)
local BuyCrypto = getRemote("BuyCrypto", true)
local SellAsset = getRemote("SellAsset", true)

local InteractPerson = getRemote("InteractPerson", true)
local DoInteraction = getRemote("DoInteraction", true) -- Client uses this name
local GiveMoney = getRemote("GiveMoney", true)

local DoActivity = getRemote("DoActivity", true)
local CommitCrime = getRemote("CommitCrime", true)
local Gamble = getRemote("Gamble", true)

-- SyncState is created by LifeManager, wait for it or create it
local SyncState = remotesFolder:FindFirstChild("SyncState")
if not SyncState then
	SyncState = remotesFolder:WaitForChild("SyncState", 10)
end
if not SyncState then
	SyncState = Instance.new("RemoteEvent")
	SyncState.Name = "SyncState"
	SyncState.Parent = remotesFolder
	print("[LifeRemoteHandlers] Created SyncState remote")
end

----------------------------------------------------------------
-- PLAYER STATE ACCESS (Uses LifeManager's state)
----------------------------------------------------------------

-- Extended state for features not in base LifeManager
local ExtendedStates = {} -- [UserId] = { Education, Experience, CurrentJob, etc. }

local function getExtendedState(player)
	if not ExtendedStates[player.UserId] then
		ExtendedStates[player.UserId] = {
			Education = "None",
			Experience = 0,
			CurrentJob = nil,
			OwnedProperties = {},
			OwnedVehicles = {},
			OwnedItems = {},
			OwnedCrypto = {},
			InJail = false,
			JailYearsLeft = 0,
		}
	end
	return ExtendedStates[player.UserId]
end

-- Auto-progress education based on age (elementary/middle/high school are automatic)
local function updateAutoEducation(player)
	local lifeState = getLifeManagerState(player)
	local extState = getExtendedState(player)
	local age = lifeState and lifeState.Age or 0
	
	-- Only auto-progress if they don't already have higher education
	local currentEdu = extState.Education or "None"
	
	-- Education hierarchy for checking
	local eduLevels = {
		["None"] = 0,
		["Elementary"] = 1,
		["Middle School"] = 2,
		["High School"] = 3,
		["Community College"] = 4,
		["Bachelor's"] = 5,
		["Master's"] = 6,
		["Medical School"] = 7,
		["Law School"] = 7,
		["PhD"] = 8,
	}
	
	local currentLevel = eduLevels[currentEdu] or 0
	
	-- Auto-assign education based on age (only if they don't have something higher)
	if age >= 18 and currentLevel < 3 then
		extState.Education = "High School"
	elseif age >= 14 and currentLevel < 2 then
		extState.Education = "Middle School"
	elseif age >= 5 and currentLevel < 1 then
		extState.Education = "Elementary"
	end
end

-- Get unified player state (combines LifeManager state + extended state)
local function getPlayerState(player)
	local lifeState = getLifeManagerState(player)
	local extState = getExtendedState(player)
	
	-- Build combined state
	return {
		Age = lifeState and lifeState.Age or 0,
		Money = lifeState and lifeState.Money or 0,
		Happiness = lifeState and lifeState.Stats and lifeState.Stats.Happiness or 50,
		Health = lifeState and lifeState.Stats and lifeState.Stats.Health or 100,
		Smarts = lifeState and lifeState.Stats and lifeState.Stats.Smarts or 50,
		Looks = lifeState and lifeState.Stats and lifeState.Stats.Looks or 50,
		Education = extState.Education,
		Experience = extState.Experience,
		CurrentJob = extState.CurrentJob,
		InJail = extState.InJail,
		-- Access to life state for direct modification
		_lifeState = lifeState,
		_extState = extState,
	}
end

local function syncStateToClient(player)
	-- Use LifeManager's push function if available
	if _G.PushPlayerState then
		_G.PushPlayerState(player, nil)
	end
end

----------------------------------------------------------------
-- CAPABILITY CHECK (Server-side validation for what player can do)
----------------------------------------------------------------

GetCapabilities.OnServerInvoke = function(player)
	local lifeState = getLifeManagerState(player)
	local extState = getExtendedState(player)
	
	if not lifeState then
		return { error = "State not found" }
	end
	
	-- Build a combined state for the LifeStageSystem
	local combinedState = {
		Age = lifeState.Age or 0,
		Money = lifeState.Money or 0,
		Stats = lifeState.Stats or {},
		Flags = lifeState.Flags or {},
		InJail = extState.InJail or false,
	}
	
	-- Get capabilities from LifeStageSystem
	local caps = LifeStageSystem.getCapabilities(combinedState)
	local stage = LifeStageSystem.getStage(combinedState.Age)
	
	return {
		success = true,
		stage = {
			id = stage.id,
			name = stage.name,
			emoji = stage.emoji,
			description = stage.description,
		},
		capabilities = caps,
		age = combinedState.Age,
		inJail = extState.InJail,
		jailYearsLeft = extState.JailYearsLeft or 0,
	}
end

----------------------------------------------------------------
-- VALIDATION HELPERS
----------------------------------------------------------------

local function canAfford(player, cost)
	local lifeState = getLifeManagerState(player)
	return lifeState and lifeState.Money >= cost
end

local function deductMoney(player, amount)
	local lifeState = getLifeManagerState(player)
	if lifeState then
		lifeState.Money = math.max(0, lifeState.Money - amount)
		syncStateToClient(player)
	end
end

local function addMoney(player, amount)
	local lifeState = getLifeManagerState(player)
	if lifeState then
		lifeState.Money = lifeState.Money + amount
		syncStateToClient(player)
	end
end

local function getAge(player)
	local lifeState = getLifeManagerState(player)
	return lifeState and lifeState.Age or 0
end

local function hasEducation(player, required)
	-- Update auto-education first
	updateAutoEducation(player)
	
	local extState = getExtendedState(player)
	local eduLevels = {
		["None"] = 0,
		["Elementary"] = 1,
		["Middle School"] = 2,
		["High School"] = 3,
		["Community College"] = 4,
		["Bachelor's"] = 5,
		["Master's"] = 6,
		["Medical School"] = 7,
		["Law School"] = 7,
		["PhD"] = 8,
	}
	local playerLevel = eduLevels[extState.Education] or 0
	local requiredLevel = eduLevels[required] or 0
	
	print("[LifeRemoteHandlers] hasEducation check:", extState.Education, "vs required:", required, "->", playerLevel >= requiredLevel)
	return playerLevel >= requiredLevel
end

local function modifyStat(player, statName, amount)
	local lifeState = getLifeManagerState(player)
	if lifeState and lifeState.Stats and lifeState.Stats[statName] then
		lifeState.Stats[statName] = math.clamp((lifeState.Stats[statName] or 50) + amount, 0, 100)
	end
end

----------------------------------------------------------------
-- JOB DATA
----------------------------------------------------------------

local JobListings = {
	{ id = "fastfood", title = "Fast Food Worker", company = "Burger Palace", salary = 22000, education = "None", minAge = 14, exp = 0, acceptance = 95 },
	{ id = "retail", title = "Retail Associate", company = "MegaMart", salary = 26000, education = "None", minAge = 16, exp = 0, acceptance = 90 },
	{ id = "janitor", title = "Janitor", company = "CleanCo Services", salary = 28000, education = "None", minAge = 18, exp = 0, acceptance = 92 },
	{ id = "receptionist", title = "Receptionist", company = "Corporate Office", salary = 32000, education = "High School", minAge = 18, exp = 0, acceptance = 80 },
	{ id = "office", title = "Office Assistant", company = "Business Solutions", salary = 35000, education = "High School", minAge = 18, exp = 1, acceptance = 75 },
	{ id = "accountant_jr", title = "Junior Accountant", company = "Financial Services", salary = 48000, education = "Bachelor's", minAge = 22, exp = 1, acceptance = 60 },
	{ id = "marketing", title = "Marketing Associate", company = "AdVenture Agency", salary = 52000, education = "Bachelor's", minAge = 22, exp = 2, acceptance = 55 },
	{ id = "developer", title = "Software Developer", company = "TechStart Inc", salary = 85000, education = "Bachelor's", minAge = 22, exp = 2, acceptance = 45 },
	{ id = "senior_dev", title = "Senior Developer", company = "BigTech Corp", salary = 140000, education = "Bachelor's", minAge = 26, exp = 5, acceptance = 30 },
	{ id = "doctor", title = "Doctor", company = "City Hospital", salary = 250000, education = "Medical School", minAge = 30, exp = 8, acceptance = 15 },
	{ id = "lawyer", title = "Lawyer", company = "Smith & Associates", salary = 180000, education = "Law School", minAge = 28, exp = 5, acceptance = 25 },
}

-- Education options for MANUAL enrollment (College+)
-- Elementary/Middle/High School are AUTOMATIC based on age
local EducationOptions = {
	{ id = "community", name = "Community College", minAge = 18, maxAge = 99, cost = 15000, requirement = "High School", grants = "Community College", duration = 2 },
	{ id = "bachelor", name = "Bachelor's Degree", minAge = 18, maxAge = 99, cost = 80000, requirement = "High School", grants = "Bachelor's", duration = 4 },
	{ id = "master", name = "Master's Degree", minAge = 22, maxAge = 99, cost = 60000, requirement = "Bachelor's", grants = "Master's", duration = 2 },
	{ id = "medical", name = "Medical School", minAge = 22, maxAge = 45, cost = 200000, requirement = "Bachelor's", grants = "Medical School", duration = 4 },
	{ id = "law", name = "Law School", minAge = 22, maxAge = 50, cost = 150000, requirement = "Bachelor's", grants = "Law School", duration = 3 },
	{ id = "phd", name = "PhD Program", minAge = 24, maxAge = 99, cost = 100000, requirement = "Master's", grants = "PhD", duration = 5 },
}

local FreelanceGigs = {
	{ id = "food_delivery", name = "Deliver Food", minAge = 16, payMin = 30, payMax = 80 },
	{ id = "dog_walking", name = "Walk Dogs", minAge = 10, payMin = 20, payMax = 50 },
	{ id = "babysit", name = "Babysit", minAge = 12, payMin = 50, payMax = 120 },
	{ id = "mow_lawns", name = "Mow Lawns", minAge = 10, payMin = 40, payMax = 100 },
	{ id = "tutor", name = "Tutor Students", minAge = 14, payMin = 30, payMax = 75 },
	{ id = "rideshare", name = "Drive Rideshare", minAge = 21, payMin = 50, payMax = 150 },
	{ id = "writing", name = "Freelance Writing", minAge = 16, payMin = 100, payMax = 500 },
	{ id = "design", name = "Graphic Design", minAge = 16, payMin = 150, payMax = 800 },
}

----------------------------------------------------------------
-- PROPERTY/VEHICLE/ITEM DATA
----------------------------------------------------------------

local Properties = {
	{ id = "studio", name = "Studio Apartment", price = 85000, minAge = 18 },
	{ id = "1br_condo", name = "1BR Condo", price = 175000, minAge = 18 },
	{ id = "family_house", name = "Family House", price = 350000, minAge = 18 },
	{ id = "penthouse", name = "Luxury Penthouse", price = 2500000, minAge = 21 },
	{ id = "beach_house", name = "Beach House", price = 1200000, minAge = 21 },
	{ id = "mansion", name = "Mansion", price = 8500000, minAge = 21 },
}

local Vehicles = {
	{ id = "used_civic", name = "Used Honda Civic", price = 8000, minAge = 16 },
	{ id = "camry", name = "Toyota Camry", price = 28000, minAge = 16 },
	{ id = "bmw", name = "BMW 3 Series", price = 55000, minAge = 18 },
	{ id = "tesla", name = "Tesla Model S", price = 95000, minAge = 18 },
	{ id = "porsche", name = "Porsche 911", price = 180000, minAge = 21 },
	{ id = "lambo", name = "Lamborghini Huracán", price = 280000, minAge = 21 },
	{ id = "ferrari", name = "Ferrari F8", price = 350000, minAge = 21 },
	{ id = "yacht", name = "Yacht", price = 2000000, minAge = 25 },
	{ id = "jet", name = "Private Jet", price = 15000000, minAge = 25 },
}

local ShopItems = {
	{ id = "watch", name = "Designer Watch", price = 5000, minAge = 16 },
	{ id = "necklace", name = "Gold Necklace", price = 3500, minAge = 16 },
	{ id = "ring", name = "Diamond Ring", price = 15000, minAge = 18 },
	{ id = "bag", name = "Designer Bag", price = 2500, minAge = 14 },
	{ id = "sneakers", name = "Sneakers", price = 350, minAge = 10 },
	{ id = "gaming_pc", name = "Gaming PC", price = 3000, minAge = 10 },
	{ id = "iphone", name = "iPhone", price = 1200, minAge = 10 },
	{ id = "piano", name = "Grand Piano", price = 50000, minAge = 18 },
}

----------------------------------------------------------------
-- ACTIVITY DATA
----------------------------------------------------------------

local Activities = {
	{ id = "read", name = "Read a Book", minAge = 5, cost = 0, effects = { Smarts = {2, 5}, Happiness = {1, 3} } },
	{ id = "meditate", name = "Meditate", minAge = 8, cost = 0, effects = { Happiness = {3, 8}, Health = {1, 3} } },
	{ id = "study", name = "Study", minAge = 5, cost = 0, effects = { Smarts = {4, 8} } },
	{ id = "gym", name = "Go to the Gym", minAge = 14, cost = 0, effects = { Health = {3, 7}, Looks = {1, 3} } },
	{ id = "run", name = "Go for a Run", minAge = 6, cost = 0, effects = { Health = {2, 5}, Happiness = {1, 3} } },
	{ id = "yoga", name = "Yoga", minAge = 10, cost = 0, effects = { Health = {2, 4}, Happiness = {2, 5} } },
	{ id = "spa", name = "Spa Day", minAge = 16, cost = 200, effects = { Looks = {3, 6}, Happiness = {4, 8} } },
	{ id = "salon", name = "Salon Visit", minAge = 12, cost = 80, effects = { Looks = {2, 5}, Happiness = {1, 3} } },
	{ id = "party", name = "Go to a Party", minAge = 14, cost = 0, effects = { Happiness = {4, 10} } },
	{ id = "hangout", name = "Hang Out", minAge = 5, cost = 0, effects = { Happiness = {3, 7} } },
	{ id = "nightclub", name = "Nightclub", minAge = 21, cost = 50, effects = { Happiness = {3, 8}, Health = {-2, 0} } },
	{ id = "host_party", name = "Host a Party", minAge = 16, cost = 300, effects = { Happiness = {5, 12} } },
	{ id = "tv", name = "Watch TV", minAge = 2, cost = 0, effects = { Happiness = {1, 4} } },
	{ id = "games", name = "Play Video Games", minAge = 5, cost = 0, effects = { Happiness = {2, 6}, Smarts = {0, 2} } },
	{ id = "movies", name = "Go to Movies", minAge = 5, cost = 20, effects = { Happiness = {3, 6} } },
	{ id = "concert", name = "Concert", minAge = 12, cost = 150, effects = { Happiness = {6, 15} } },
	{ id = "vacation", name = "Vacation", minAge = 5, cost = 2000, effects = { Happiness = {10, 25}, Health = {2, 5} } },
}

local Crimes = {
	{ id = "shoplift", name = "Shoplift", minAge = 8, risk = 25, rewardMin = 20, rewardMax = 150, jailMin = 0.1, jailMax = 0.5 },
	{ id = "pickpocket", name = "Pickpocket", minAge = 10, risk = 35, rewardMin = 30, rewardMax = 300, jailMin = 0.2, jailMax = 1 },
	{ id = "burglary", name = "Burglary", minAge = 16, risk = 50, rewardMin = 500, rewardMax = 5000, jailMin = 1, jailMax = 5 },
	{ id = "gta", name = "Grand Theft Auto", minAge = 16, risk = 60, rewardMin = 2000, rewardMax = 20000, jailMin = 2, jailMax = 8 },
	{ id = "bank_robbery", name = "Bank Robbery", minAge = 18, risk = 80, rewardMin = 10000, rewardMax = 500000, jailMin = 10, jailMax = 25 },
	{ id = "porch_pirate", name = "Porch Pirate", minAge = 10, risk = 20, rewardMin = 10, rewardMax = 200, jailMin = 0.1, jailMax = 0.3 },
}

----------------------------------------------------------------
-- RELATIONSHIP ACTIONS
----------------------------------------------------------------

local RelationshipActions = {
	Compliment = { minAge = 3, cost = 0, successChance = 0.7, statMin = 2, statMax = 8 },
	Insult = { minAge = 5, cost = 0, successChance = 0.2, statMin = -15, statMax = -5 },
	Gift = { minAge = 5, cost = 50, successChance = 0.8, statMin = 5, statMax = 15 },
	SpendTime = { minAge = 2, cost = 0, successChance = 0.75, statMin = 3, statMax = 10 },
	Argue = { minAge = 5, cost = 0, successChance = 0.3, statMin = -12, statMax = -3 },
	Apologize = { minAge = 4, cost = 0, successChance = 0.6, statMin = 5, statMax = 20 },
	Conversation = { minAge = 3, cost = 0, successChance = 0.8, statMin = 1, statMax = 5 },
}

----------------------------------------------------------------
-- OCCUPATION HANDLERS
----------------------------------------------------------------

ApplyForJob.OnServerInvoke = function(player, jobId)
	print("[LifeRemoteHandlers] ApplyForJob called with jobId:", jobId)
	
	local age = getAge(player)
	local extState = getExtendedState(player)
	local lifeState = getLifeManagerState(player)
	local flags = lifeState and lifeState.Flags or {}
	
	-- Update auto-education first (high school etc. based on age)
	updateAutoEducation(player)
	
	-- ========================================
	-- CRIMINAL RECORD CHECKS (Ex-Convict System)
	-- ========================================
	
	-- Fugitives can't apply for jobs (they're on the run!)
	if flags.fugitive then
		print("[LifeRemoteHandlers] Job application blocked - player is a fugitive")
		return { success = false, message = "⚠️ You're a fugitive! You can't apply for jobs while on the run." }
	end
	
	-- Wanted players can't apply
	if flags.wanted then
		print("[LifeRemoteHandlers] Job application blocked - player is wanted")
		return { success = false, message = "⚠️ There's a warrant out for your arrest! You can't apply for jobs right now." }
	end
	
	-- Find job
	local job = nil
	for _, j in ipairs(JobListings) do
		if j.id == jobId then
			job = j
			break
		end
	end
	
	if not job then
		print("[LifeRemoteHandlers] Job not found:", jobId)
		return { success = false, message = "Job not found: " .. tostring(jobId) }
	end
	
	print("[LifeRemoteHandlers] Found job:", job.title, "for player age:", age)
	print("[LifeRemoteHandlers] Player flags - ex_convict:", flags.ex_convict, "reformed:", flags.reformed, "second_chance:", flags.second_chance)
	
	-- Already have a job?
	if extState.CurrentJob then
		return { success = false, message = "You already have a job! Quit first." }
	end
	
	-- In jail?
	if extState.InJail then
		return { success = false, message = "You can't work while in jail!" }
	end
	
	-- Check age
	if age < job.minAge then
		return { success = false, message = "You must be at least " .. job.minAge .. " years old to apply for this job." }
	end
	
	-- Check education
	if not hasEducation(player, job.education) then
		return { success = false, message = "You need a " .. job.education .. " education for this job." }
	end
	
	-- Check experience
	if extState.Experience < job.exp then
		return { success = false, message = "You need " .. job.exp .. " years of experience." }
	end
	
	-- ========================================
	-- EX-CONVICT EMPLOYMENT PENALTIES
	-- ========================================
	
	local acceptanceChance = job.acceptance
	local isExConvict = flags.ex_convict or flags.did_time or flags.released_from_prison
	local hasSecondChance = flags.second_chance
	local isReformed = flags.reformed
	
	-- Jobs that require background checks (professional jobs) - block or severe penalty for ex-convicts
	local backgroundCheckJobs = {
		government = true, teacher = true, lawyer = true, doctor = true, nurse = true,
		accountant = true, banker = true, financial = true, security = true, police = true,
		daycare = true, school = true, hospital = true, pharmacy = true
	}
	
	-- Check if job requires background check (based on job ID keywords)
	local requiresBackgroundCheck = false
	local jobIdLower = string.lower(job.id or "")
	local jobTitleLower = string.lower(job.title or "")
	for keyword, _ in pairs(backgroundCheckJobs) do
		if string.find(jobIdLower, keyword) or string.find(jobTitleLower, keyword) then
			requiresBackgroundCheck = true
			break
		end
	end
	
	if isExConvict then
		print("[LifeRemoteHandlers] Ex-convict applying for job. Background check required:", requiresBackgroundCheck)
		
		-- Block background check jobs entirely for ex-convicts (unless they have second_chance)
		if requiresBackgroundCheck and not hasSecondChance then
			return { 
				success = false, 
				message = "⛔ " .. job.company .. " ran a background check. Your criminal record disqualifies you for this position." 
			}
		end
		
		-- Reduce acceptance chance significantly for ex-convicts
		if hasSecondChance or isReformed then
			-- Reformed/second chance reduces penalty
			acceptanceChance = math.floor(acceptanceChance * 0.7) -- 30% penalty
			print("[LifeRemoteHandlers] Reformed ex-convict penalty applied. New acceptance:", acceptanceChance)
		else
			-- Standard ex-convict penalty
			acceptanceChance = math.floor(acceptanceChance * 0.4) -- 60% penalty
			print("[LifeRemoteHandlers] Ex-convict penalty applied. New acceptance:", acceptanceChance)
		end
	end
	
	-- Roll for acceptance
	local roll = math.random(100)
	print("[LifeRemoteHandlers] Acceptance roll:", roll, "vs", acceptanceChance)
	
	if roll > acceptanceChance then
		local message = "Unfortunately, " .. job.company .. " decided not to hire you."
		if isExConvict then
			message = "📋 " .. job.company .. " reviewed your application but passed. Your criminal record may have been a factor."
		end
		return { success = false, message = message }
	end
	
	-- Hired!
	extState.CurrentJob = {
		id = job.id,
		title = job.title,
		company = job.company,
		salary = job.salary,
	}
	syncStateToClient(player)
	
	local message = "Congratulations! You got hired as a " .. job.title .. " at " .. job.company .. "!"
	if isExConvict then
		message = "🌟 Despite your criminal record, " .. job.company .. " decided to give you a chance! You got hired as a " .. job.title .. "!"
		-- If they got hired as ex-convict, set the second_chance flag
		if lifeState then
			lifeState:SetFlag("second_chance")
		end
	end
	
	return { 
		success = true, 
		message = message,
		salary = job.salary
	}
end

QuitJob.OnServerEvent:Connect(function(player)
	local extState = getExtendedState(player)
	if extState.CurrentJob then
		extState.CurrentJob = nil
		syncStateToClient(player)
	end
end)

DoWork.OnServerInvoke = function(player)
	local extState = getExtendedState(player)
	
	if not extState.CurrentJob then
		return { success = false, message = "You don't have a job!" }
	end
	
	if extState.InJail then
		return { success = false, message = "You can't work while in jail!" }
	end
	
	-- Daily pay = annual / 365
	local dailyPay = math.floor(extState.CurrentJob.salary / 365)
	addMoney(player, dailyPay)
	
	-- Gain experience
	extState.Experience = extState.Experience + 0.01 -- Small XP per work day
	
	return { 
		success = true, 
		message = "You worked hard at " .. extState.CurrentJob.company .. "!",
		earned = dailyPay
	}
end

EnrollEducation.OnServerInvoke = function(player, eduId)
	local state = getPlayerState(player)
	local age = state.Age
	local lifeState = getLifeManagerState(player)
	local flags = lifeState and lifeState.Flags or {}
	
	print("[LifeRemoteHandlers] EnrollEducation called with eduId:", eduId)
	print("[LifeRemoteHandlers] Player flags - ex_convict:", flags.ex_convict, "fugitive:", flags.fugitive)
	
	-- ========================================
	-- CRIMINAL RECORD CHECKS (Ex-Convict System)
	-- ========================================
	
	-- Fugitives can't enroll (they're on the run!)
	if flags.fugitive then
		print("[LifeRemoteHandlers] Education blocked - player is a fugitive")
		return { success = false, message = "⚠️ You're a fugitive! You can't enroll in school while on the run." }
	end
	
	-- Wanted players can't enroll
	if flags.wanted then
		print("[LifeRemoteHandlers] Education blocked - player is wanted")
		return { success = false, message = "⚠️ There's a warrant out for your arrest! You can't enroll right now." }
	end
	
	-- In jail?
	local extState = getExtendedState(player)
	if extState.InJail then
		return { success = false, message = "You can't enroll in education while in jail! (Try the prison GED program instead)" }
	end
	
	-- Find education
	local edu = nil
	for _, e in ipairs(EducationOptions) do
		if e.id == eduId then
			edu = e
			break
		end
	end
	
	if not edu then
		return { success = false, message = "Education program not found." }
	end
	
	print("[LifeRemoteHandlers] Found education:", edu.name, "for player age:", age)
	
	-- Check age
	if age < edu.minAge then
		return { success = false, message = "You must be at least " .. edu.minAge .. " years old to enroll." }
	end
	
	if age > edu.maxAge then
		return { success = false, message = "You're too old for this program (max age: " .. edu.maxAge .. ")." }
	end
	
	-- Check prerequisite
	if not hasEducation(player, edu.requirement) then
		return { success = false, message = "You need a " .. edu.requirement .. " to enroll in this program." }
	end
	
	-- Already have this or higher?
	if hasEducation(player, edu.grants) then
		return { success = false, message = "You already have this education level or higher." }
	end
	
	-- ========================================
	-- EX-CONVICT EDUCATION PENALTIES
	-- ========================================
	
	local isExConvict = flags.ex_convict or flags.did_time or flags.released_from_prison
	local isReformed = flags.reformed
	local hasGED = flags.prison_educated
	local actualCost = edu.cost
	
	-- Professional programs that require background checks and often reject ex-convicts
	local restrictedPrograms = {
		law_school = true, medical_school = true, nursing = true, 
		education = true, teaching = true, police_academy = true,
		government = true, security = true
	}
	
	-- Check if program is restricted
	local eduIdLower = string.lower(eduId or "")
	local eduNameLower = string.lower(edu.name or "")
	local isRestricted = false
	for keyword, _ in pairs(restrictedPrograms) do
		if string.find(eduIdLower, keyword) or string.find(eduNameLower, keyword) then
			isRestricted = true
			break
		end
	end
	
	if isExConvict then
		print("[LifeRemoteHandlers] Ex-convict enrolling in education. Restricted program:", isRestricted)
		
		-- Block restricted programs for ex-convicts (unless reformed)
		if isRestricted and not isReformed then
			return { 
				success = false, 
				message = "⛔ Your criminal record disqualifies you from " .. edu.name .. ". Some programs require a clean background check." 
			}
		end
		
		-- Increase cost for ex-convicts (no financial aid/scholarships)
		if not isReformed then
			-- 50% cost increase due to no scholarships
			actualCost = math.floor(edu.cost * 1.5)
			print("[LifeRemoteHandlers] Ex-convict cost penalty applied. New cost:", actualCost)
		else
			-- Reformed ex-convicts get smaller penalty
			actualCost = math.floor(edu.cost * 1.2)
			print("[LifeRemoteHandlers] Reformed ex-convict cost penalty applied. New cost:", actualCost)
		end
	end
	
	-- Check cost
	if not canAfford(player, actualCost) then
		local message = "You can't afford this! Cost: $" .. actualCost
		if isExConvict and actualCost > edu.cost then
			message = "You can't afford this! Cost: $" .. actualCost .. " (increased due to limited financial aid for ex-convicts)"
		end
		return { success = false, message = message }
	end
	
	-- Enroll!
	deductMoney(player, actualCost)
	extState.Education = edu.grants
	
	-- Set college_student flag if applicable
	if lifeState and (edu.grants == "Bachelor's" or edu.grants == "Master's" or edu.grants == "PhD" 
		or edu.grants == "Medical School" or edu.grants == "Law School") then
		lifeState:SetFlag("college_student")
	end
	
	syncStateToClient(player)
	
	local message = "You enrolled in " .. edu.name .. "! (Cost: $" .. actualCost .. ")"
	if isExConvict and actualCost > edu.cost then
		message = "🎓 Despite your criminal record, you enrolled in " .. edu.name .. "! (Cost: $" .. actualCost .. " - limited financial aid available)"
	end
	
	return { 
		success = true, 
		message = message
	}
end

DoFreelance.OnServerInvoke = function(player, gigId)
	local age = getAge(player)
	local extState = getExtendedState(player)
	
	-- Find gig
	local gig = nil
	for _, g in ipairs(FreelanceGigs) do
		if g.id == gigId then
			gig = g
			break
		end
	end
	
	if not gig then
		return { success = false, message = "Gig not found." }
	end
	
	if extState.InJail then
		return { success = false, message = "You can't work while in jail!" }
	end
	
	-- Check age
	if age < gig.minAge then
		return { success = false, message = "You must be at least " .. gig.minAge .. " years old for this gig." }
	end
	
	-- Do gig!
	local earnings = math.random(gig.payMin, gig.payMax)
	addMoney(player, earnings)
	
	return { 
		success = true, 
		message = "You completed " .. gig.name .. " and earned $" .. earnings .. "!",
		earned = earnings
	}
end

TrySpecialCareer.OnServerInvoke = function(player, careerId)
	local extState = getExtendedState(player)
	
	if extState.InJail then
		return { success = false, message = "You can't pursue a career while in jail!" }
	end
	
	-- 30% success chance for special careers
	local success = math.random(100) <= 30
	
	if success then
		return { 
			success = true, 
			message = "You made it! Your special career has begun!"
		}
	else
		return { 
			success = false, 
			message = "It didn't work out this time. Keep trying!"
		}
	end
end

----------------------------------------------------------------
-- ASSETS HANDLERS
----------------------------------------------------------------

BuyProperty.OnServerInvoke = function(player, propertyId)
	local state = getPlayerState(player)
	local age = state.Age
	
	local prop = nil
	for _, p in ipairs(Properties) do
		if p.id == propertyId then
			prop = p
			break
		end
	end
	
	if not prop then
		return { success = false, message = "Property not found." }
	end
	
	if age < prop.minAge then
		return { success = false, message = "You must be at least " .. prop.minAge .. " to buy property." }
	end
	
	if not canAfford(player, prop.price) then
		return { success = false, message = "You can't afford this! Price: $" .. prop.price }
	end
	
	deductMoney(player, prop.price)
	table.insert(state.OwnedProperties, { id = prop.id, name = prop.name, value = prop.price })
	syncStateToClient(player)
	
	return { 
		success = true, 
		message = "Congratulations! You bought " .. prop.name .. "!"
	}
end

BuyVehicle.OnServerInvoke = function(player, vehicleId)
	local state = getPlayerState(player)
	local age = state.Age
	
	local vehicle = nil
	for _, v in ipairs(Vehicles) do
		if v.id == vehicleId then
			vehicle = v
			break
		end
	end
	
	if not vehicle then
		return { success = false, message = "Vehicle not found." }
	end
	
	if age < vehicle.minAge then
		return { success = false, message = "You must be at least " .. vehicle.minAge .. " to buy this vehicle." }
	end
	
	if not canAfford(player, vehicle.price) then
		return { success = false, message = "You can't afford this! Price: $" .. vehicle.price }
	end
	
	deductMoney(player, vehicle.price)
	table.insert(state.OwnedVehicles, { id = vehicle.id, name = vehicle.name, value = vehicle.price })
	syncStateToClient(player)
	
	return { 
		success = true, 
		message = "Congratulations! You bought a " .. vehicle.name .. "!"
	}
end

BuyItem.OnServerInvoke = function(player, itemId)
	local state = getPlayerState(player)
	local age = state.Age
	
	local item = nil
	for _, i in ipairs(ShopItems) do
		if i.id == itemId then
			item = i
			break
		end
	end
	
	if not item then
		return { success = false, message = "Item not found." }
	end
	
	if age < item.minAge then
		return { success = false, message = "You must be at least " .. item.minAge .. " to buy this." }
	end
	
	if not canAfford(player, item.price) then
		return { success = false, message = "You can't afford this! Price: $" .. item.price }
	end
	
	deductMoney(player, item.price)
	table.insert(state.OwnedItems, { id = item.id, name = item.name, value = item.price })
	syncStateToClient(player)
	
	return { 
		success = true, 
		message = "You bought a " .. item.name .. "!"
	}
end

BuyCrypto.OnServerInvoke = function(player, cryptoId, amount)
	local state = getPlayerState(player)
	
	if state.Age < 18 then
		return { success = false, message = "You must be 18+ to trade crypto." }
	end
	
	-- Simplified crypto system
	local cost = amount or 100
	
	if not canAfford(player, cost) then
		return { success = false, message = "You can't afford this investment!" }
	end
	
	deductMoney(player, cost)
	table.insert(state.OwnedCrypto, { id = cryptoId, invested = cost })
	syncStateToClient(player)
	
	return { success = true, message = "Crypto purchased!" }
end

----------------------------------------------------------------
-- RELATIONSHIP HANDLERS
----------------------------------------------------------------

InteractPerson.OnServerInvoke = function(player, personId, actionType)
	local state = getPlayerState(player)
	local age = state.Age
	
	local action = RelationshipActions[actionType]
	if not action then
		return { success = false, message = "Invalid action." }
	end
	
	if age < action.minAge then
		return { success = false, message = "You're too young for this action." }
	end
	
	if action.cost > 0 and not canAfford(player, action.cost) then
		return { success = false, message = "You can't afford this! Cost: $" .. action.cost }
	end
	
	if action.cost > 0 then
		deductMoney(player, action.cost)
	end
	
	-- Roll for success
	local isSuccess = math.random() < action.successChance
	local statChange = 0
	
	if isSuccess then
		statChange = math.random(math.max(1, action.statMin), action.statMax)
	else
		statChange = math.random(action.statMin, math.min(-1, action.statMax))
	end
	
	return { 
		success = true, 
		isPositive = isSuccess,
		statChange = statChange,
		message = isSuccess and "It went well!" or "It didn't go as planned..."
	}
end

GiveMoney.OnServerInvoke = function(player, personId)
	local state = getPlayerState(player)
	
	-- Can only ask family for money
	-- Random chance and amount
	local success = math.random(100) <= 60
	
	if success then
		local amount = math.random(25, 100)
		addMoney(player, amount)
		return { success = true, message = "They gave you $" .. amount .. "!", amount = amount }
	else
		return { success = false, message = "They said no." }
	end
end

----------------------------------------------------------------
-- UNIFIED INTERACTION HANDLER (DoInteraction)
-- Handles all relationship interactions: family, romance, friend, enemy
----------------------------------------------------------------

-- Extended relationship actions by type
local AllRelationshipActions = {
	-- Family actions
	hug = { minAge = 2, cost = 0, successChance = 0.85, statMin = 3, statMax = 10, type = "family" },
	talk = { minAge = 3, cost = 0, successChance = 0.8, statMin = 2, statMax = 8, type = "family" },
	argue = { minAge = 5, cost = 0, successChance = 0.3, statMin = -12, statMax = -3, type = "family" },
	money = { minAge = 5, cost = 0, successChance = 0.6, statMin = 0, statMax = 0, giveMoney = true, type = "family" },
	vacation = { minAge = 5, cost = 2000, successChance = 0.9, statMin = 10, statMax = 25, type = "family" },
	apologize = { minAge = 4, cost = 0, successChance = 0.65, statMin = 5, statMax = 20, type = "family" },
	
	-- Romance actions  
	date = { minAge = 16, cost = 100, successChance = 0.75, statMin = 5, statMax = 15, type = "romance" },
	kiss = { minAge = 14, cost = 0, successChance = 0.7, statMin = 5, statMax = 12, type = "romance" },
	propose = { minAge = 18, cost = 5000, successChance = 0.5, statMin = 20, statMax = 50, type = "romance", special = "propose" },
	breakup = { minAge = 14, cost = 0, successChance = 1.0, statMin = -50, statMax = -30, type = "romance", special = "breakup" },
	flirt = { minAge = 14, cost = 0, successChance = 0.6, statMin = 3, statMax = 10, type = "romance" },
	compliment = { minAge = 3, cost = 0, successChance = 0.8, statMin = 2, statMax = 8, type = "any" },
	
	-- Friend actions
	hangout = { minAge = 5, cost = 0, successChance = 0.85, statMin = 3, statMax = 10, type = "friend" },
	support = { minAge = 5, cost = 0, successChance = 0.9, statMin = 4, statMax = 12, type = "friend" },
	party = { minAge = 14, cost = 0, successChance = 0.8, statMin = 5, statMax = 15, type = "friend" },
	betray = { minAge = 10, cost = 0, successChance = 0.5, statMin = -30, statMax = -15, type = "friend", special = "betray" },
	ghost = { minAge = 10, cost = 0, successChance = 1.0, statMin = -100, statMax = -50, type = "friend", special = "ghost" },
	
	-- Enemy actions
	insult = { minAge = 5, cost = 0, successChance = 0.9, statMin = -10, statMax = -3, type = "enemy" },
	fight = { minAge = 10, cost = 0, successChance = 0.5, statMin = -20, statMax = 10, type = "enemy", special = "fight" },
	forgive = { minAge = 5, cost = 0, successChance = 0.6, statMin = 10, statMax = 30, type = "enemy", special = "forgive" },
	prank = { minAge = 8, cost = 0, successChance = 0.7, statMin = -8, statMax = -2, type = "enemy" },
	ignore = { minAge = 5, cost = 0, successChance = 1.0, statMin = 0, statMax = 0, type = "enemy" },
	
	-- Special actions (meeting new people)
	meet_someone = { minAge = 16, cost = 0, successChance = 0.7, statMin = 0, statMax = 0, type = "romance", special = "meet_romance" },
	make_friend = { minAge = 5, cost = 0, successChance = 0.8, statMin = 0, statMax = 0, type = "friend", special = "make_friend" },
	
	-- Gift works for all types
	gift = { minAge = 5, cost = 50, successChance = 0.85, statMin = 8, statMax = 20, type = "any" },
}

-- Random name generator
local FirstNames = {
	male = {"James", "John", "Michael", "David", "Chris", "Alex", "Ryan", "Daniel", "Tyler", "Jake", "Ethan", "Noah", "Liam", "Mason", "Lucas"},
	female = {"Emma", "Olivia", "Sophia", "Isabella", "Mia", "Charlotte", "Amelia", "Harper", "Evelyn", "Luna", "Chloe", "Lily", "Zoe", "Grace", "Ella"},
}

local function getRandomName(gender)
	local names = gender == "male" and FirstNames.male or FirstNames.female
	return names[math.random(#names)]
end

DoInteraction.OnServerInvoke = function(player, actionId, relationType, personId)
	print("[LifeRemoteHandlers] DoInteraction called:", actionId, relationType, personId)
	
	local age = getAge(player)
	local extState = getExtendedState(player)
	local lifeState = getLifeManagerState(player)
	
	local action = AllRelationshipActions[actionId]
	if not action then
		print("[LifeRemoteHandlers] Unknown action:", actionId)
		return { success = false, message = "Unknown action: " .. tostring(actionId) }
	end
	
	-- Check age
	if age < action.minAge then
		return { success = false, message = "You must be at least " .. action.minAge .. " years old." }
	end
	
	-- Check cost
	local cost = action.cost or 0
	if cost > 0 and not canAfford(player, cost) then
		return { success = false, message = "You can't afford this! Cost: $" .. cost }
	end
	
	-- Deduct cost
	if cost > 0 then
		deductMoney(player, cost)
	end
	
	-- Handle special actions
	if action.special == "meet_romance" then
		-- Generate a new romantic interest
		local partnerGender = math.random() > 0.5 and "male" or "female"
		local partnerName = getRandomName(partnerGender)
		local partnerAge = math.max(18, age + math.random(-5, 5))
		
		-- Add to relationships
		if lifeState then
			lifeState.Relationships = lifeState.Relationships or {}
			local id = "partner_" .. os.time()
			lifeState.Relationships[id] = {
				type = "romance",
				name = partnerName,
				role = "Dating",
				age = partnerAge,
				relationship = 50 + math.random(0, 20),
				alive = true,
				gender = partnerGender,
			}
		end
		
		syncStateToClient(player)
		return { 
			success = true, 
			message = "You met " .. partnerName .. " (" .. partnerAge .. ") and hit it off! You're now dating."
		}
		
	elseif action.special == "make_friend" then
		-- Generate a new friend
		local friendGender = math.random() > 0.5 and "male" or "female"
		local friendName = getRandomName(friendGender)
		local friendAge = math.max(5, age + math.random(-3, 3))
		
		-- Add to relationships
		if lifeState then
			lifeState.Relationships = lifeState.Relationships or {}
			local id = "friend_" .. os.time()
			lifeState.Relationships[id] = {
				type = "friend",
				name = friendName,
				role = "Friend",
				age = friendAge,
				relationship = 50 + math.random(0, 30),
				alive = true,
				gender = friendGender,
			}
		end
		
		syncStateToClient(player)
		return { 
			success = true, 
			message = "You made a new friend! " .. friendName .. " seems cool."
		}
		
	elseif action.giveMoney then
		-- Ask for money action
		local success = math.random(100) <= 60
		if success then
			local amount = math.random(25, 200)
			addMoney(player, amount)
			return { success = true, message = "They gave you $" .. amount .. "!", amount = amount }
		else
			return { success = false, message = "They said no this time." }
		end
		
	elseif action.special == "propose" then
		local success = math.random(100) <= 50
		if success then
			-- Marriage!
			if lifeState then
				lifeState:SetFlag("married")
			end
			modifyStat(player, "Happiness", 30)
			syncStateToClient(player)
			return { success = true, message = "They said YES! You're engaged! 💍" }
		else
			modifyStat(player, "Happiness", -15)
			syncStateToClient(player)
			return { success = false, message = "They said no... The rejection hurts." }
		end
		
	elseif action.special == "breakup" then
		modifyStat(player, "Happiness", -20)
		syncStateToClient(player)
		return { success = true, message = "You ended the relationship. It's over." }
		
	elseif action.special == "fight" then
		local won = math.random(100) <= 50
		if won then
			modifyStat(player, "Happiness", 5)
			return { success = true, message = "You won the fight! They'll think twice before messing with you." }
		else
			modifyStat(player, "Health", -10)
			modifyStat(player, "Happiness", -5)
			syncStateToClient(player)
			return { success = false, message = "You lost the fight and got hurt. Maybe fighting isn't your thing." }
		end
		
	elseif action.special == "forgive" then
		local accepted = math.random(100) <= 60
		if accepted then
			-- Convert enemy to friend
			modifyStat(player, "Happiness", 10)
			syncStateToClient(player)
			return { success = true, message = "They accepted your forgiveness. Maybe you can be friends now." }
		else
			return { success = false, message = "They're not ready to forgive. Give it time." }
		end
	end
	
	-- Standard interaction - roll for success
	local isSuccess = math.random(100) <= (action.successChance * 100)
	local statChange = 0
	
	if isSuccess then
		statChange = math.random(math.max(1, action.statMin), math.max(1, action.statMax))
		modifyStat(player, "Happiness", math.floor(statChange / 2))
	else
		statChange = math.random(math.min(-1, action.statMin), math.min(-1, action.statMax))
		modifyStat(player, "Happiness", math.floor(statChange / 3))
	end
	
	syncStateToClient(player)
	
	-- Generate result message
	local messages = {
		hug = isSuccess and "The hug was warm and comforting!" or "They seemed distant...",
		talk = isSuccess and "You had a great conversation!" or "The conversation was a bit awkward.",
		argue = isSuccess and "You made your point but things got heated." or "The argument went badly.",
		apologize = isSuccess and "They accepted your apology!" or "They're not ready to forgive yet.",
		gift = isSuccess and "They loved the gift!" or "The gift didn't go over as well as you hoped.",
		date = isSuccess and "The date was amazing!" or "The date was a bit awkward.",
		kiss = isSuccess and "A magical moment!" or "Maybe not the right time...",
		flirt = isSuccess and "They're definitely interested!" or "That was embarrassing...",
		compliment = isSuccess and "They appreciated the kind words!" or "They seemed uncomfortable.",
		hangout = isSuccess and "You had a blast hanging out!" or "Things were a bit awkward.",
		support = isSuccess and "They really appreciated your support!" or "You tried your best.",
		party = isSuccess and "The party was epic!" or "The party was kind of lame.",
		insult = isSuccess and "That was harsh but felt good." or "They didn't even react.",
		prank = isSuccess and "The prank was hilarious!" or "The prank backfired.",
		ignore = "You ignored them successfully.",
		vacation = isSuccess and "The vacation was incredible! Great bonding time." or "The vacation had some rough moments.",
	}
	
	local message = messages[actionId] or (isSuccess and "It went well!" or "It didn't go as planned...")
	
	return { 
		success = isSuccess, 
		message = message,
		statChange = statChange
	}
end

----------------------------------------------------------------
-- ACTIVITY HANDLERS
----------------------------------------------------------------

DoActivity.OnServerInvoke = function(player, activityId)
	local age = getAge(player)
	local extState = getExtendedState(player)
	
	local activity = nil
	for _, a in ipairs(Activities) do
		if a.id == activityId then
			activity = a
			break
		end
	end
	
	if not activity then
		return { success = false, message = "Activity not found." }
	end
	
	if extState.InJail then
		return { success = false, message = "You can't do activities while in jail!" }
	end
	
	if age < activity.minAge then
		return { success = false, message = "You must be at least " .. activity.minAge .. " years old for this activity." }
	end
	
	if activity.cost > 0 and not canAfford(player, activity.cost) then
		return { success = false, message = "You can't afford this! Cost: $" .. activity.cost }
	end
	
	if activity.cost > 0 then
		deductMoney(player, activity.cost)
	end
	
	-- Apply stat effects using the helper function
	local statChanges = {}
	if activity.effects then
		for stat, range in pairs(activity.effects) do
			local change = math.random(range[1], range[2])
			modifyStat(player, stat, change)
			statChanges[stat] = change
		end
	end
	
	syncStateToClient(player)
	
	return { 
		success = true, 
		message = "You did " .. activity.name .. "!",
		statChanges = statChanges
	}
end

CommitCrime.OnServerInvoke = function(player, crimeId)
	local age = getAge(player)
	local extState = getExtendedState(player)
	
	local crime = nil
	for _, c in ipairs(Crimes) do
		if c.id == crimeId then
			crime = c
			break
		end
	end
	
	if not crime then
		return { success = false, message = "Crime not found." }
	end
	
	if extState.InJail then
		return { success = false, message = "You're already in jail!" }
	end
	
	if age < crime.minAge then
		return { success = false, message = "You must be at least " .. crime.minAge .. " to attempt this crime." }
	end
	
	-- Roll for getting caught
	local caught = math.random(100) <= crime.risk
	
	if caught then
		-- GO TO JAIL
		local jailTime = crime.jailMin + math.random() * (crime.jailMax - crime.jailMin)
		extState.InJail = true
		extState.JailYearsLeft = jailTime
		extState.CurrentJob = nil -- Lose job
		
		-- Also set the in_prison flag in player's Flags for event system
		local life = _G.GetPlayerLife and _G.GetPlayerLife(player)
		if life then
			life.Flags = life.Flags or {}
			life.Flags.in_prison = true
			life.Flags.incarcerated = true
			life.Flags.arrested = true
			life.Flags.did_time = true
			-- IMPORTANT: Clear sentence_complete when going to prison (prevents bugs from previous stints)
			life.Flags.sentence_complete = nil
			life.Flags.released_from_prison = nil
			print("[LifeRemoteHandlers] Set prison flags in life state, cleared any previous release flags")
		end
		
		syncStateToClient(player)
		
		local jailText = jailTime < 1 and string.format("%.0f months", jailTime * 12) or string.format("%.1f years", jailTime)
		print("[LifeRemoteHandlers] Player caught! Jailed for", jailText)
		return { 
			success = false, 
			caught = true,
			message = "You got caught! Sentenced to " .. jailText .. " in prison.",
			jailTime = jailTime
		}
	else
		-- SUCCESS
		local reward = math.random(crime.rewardMin, crime.rewardMax)
		addMoney(player, reward)
		
		return { 
			success = true, 
			message = "You got away with it! You earned $" .. reward,
			reward = reward
		}
	end
end

Gamble.OnServerInvoke = function(player, amount)
	local age = getAge(player)
	
	if age < 21 then
		return { success = false, message = "You must be 21+ to gamble." }
	end
	
	local bet = amount or 100
	
	if not canAfford(player, bet) then
		return { success = false, message = "You don't have enough money to bet $" .. bet }
	end
	
	deductMoney(player, bet)
	
	-- 40% chance to win
	local won = math.random(100) <= 40
	
	if won then
		local winnings = bet * 2 -- Double your money
		addMoney(player, winnings)
		return { success = true, won = true, message = "JACKPOT! You won $" .. winnings, amount = winnings }
	else
		return { success = true, won = false, message = "Better luck next time! You lost $" .. bet, amount = -bet }
	end
end

----------------------------------------------------------------
-- PRISON ACTIONS
----------------------------------------------------------------
local DoPrisonAction = getRemote("DoPrisonAction", true)

DoPrisonAction.OnServerInvoke = function(player, actionId)
	print("[LifeRemoteHandlers] DoPrisonAction called:", actionId, "for", player.Name)
	
	local extState = getExtendedState(player)
	local life = _G.GetPlayerLife and _G.GetPlayerLife(player) or nil
	
	-- Must be in jail (except for escape_failed which is just a penalty)
	if not extState.InJail and actionId ~= "prison_escape_failed" then
		print("[LifeRemoteHandlers] Player not in prison!")
		return { success = false, message = "You're not in prison!" }
	end
	
	-- Prison Escape Failed (minigame failure)
	if actionId == "prison_escape_failed" then
		print("[LifeRemoteHandlers] Escape minigame failed - adding time")
		extState.JailYearsLeft = (extState.JailYearsLeft or 0) + math.random(2, 5)
		if life then
			life.Stats.Health = math.max(1, (life.Stats.Health or 50) - 10)
		end
		syncStateToClient(player)
		return { success = false, message = "Caught trying to escape! More years added." }
	end
	
	-- Prison Escape (player beat the minigame - high success rate!)
	if actionId == "prison_escape" then
		print("[LifeRemoteHandlers] Prison escape attempt (minigame success)")
		-- Player beat the minigame, so much higher escape chance (70% base)
		local smarts = life and life.Stats and life.Stats.Smarts or 50
		local escapeChance = 70 + math.floor(smarts / 10) -- 70-80% chance
		local success = math.random(100) <= escapeChance
		
		print("[LifeRemoteHandlers] Escape chance:", escapeChance, "Roll success:", success)
		
		if success then
			extState.InJail = false
			extState.JailYearsLeft = 0
			extState.EscapedPrison = true
			extState.WantedLevel = (extState.WantedLevel or 0) + 3
			
			if life then
				-- Set escaped/fugitive flags
				life.Flags = life.Flags or {}
				life.Flags.escaped_prison = true
				life.Flags.fugitive = true
				life.Flags.ex_convict = true
				-- Clear prison flags
				life.Flags.in_prison = nil
				life.Flags.incarcerated = nil
				
				life.Stats = life.Stats or {}
				life.Stats.Happiness = math.min(100, (life.Stats.Happiness or 50) + 30)
			end
			
			syncStateToClient(player)
			print("[LifeRemoteHandlers] Escape successful! Cleared prison flags.")
			return { 
				success = true, 
				message = "You escaped prison! 🎉 You're now a fugitive and must lay low..."
			}
		else
			-- Even with minigame success, there's a small chance of getting caught
			extState.JailYearsLeft = (extState.JailYearsLeft or 0) + math.random(1, 3)
			syncStateToClient(player)
			print("[LifeRemoteHandlers] Escape failed despite minigame win")
			return { 
				success = false, 
				message = "A guard spotted you at the last moment! More time added."
			}
		end
	
	-- Yard Workout
	elseif actionId == "prison_workout" then
		if life then
			life.Stats.Health = math.min(100, (life.Stats.Health or 50) + 5)
			life.Stats.Looks = math.min(100, (life.Stats.Looks or 50) + 2)
		end
		syncStateToClient(player)
		return { success = true, message = "You pumped iron in the yard. Getting jacked!" }
	
	-- Get GED
	elseif actionId == "prison_study" then
		if extState.PrisonGED then
			return { success = false, message = "You already have your GED." }
		end
		if life then
			life.Stats.Smarts = math.min(100, (life.Stats.Smarts or 50) + 8)
		end
		extState.PrisonGED = true
		if life and life.SetFlag then
			life:SetFlag("prison_educated")
		end
		syncStateToClient(player)
		return { success = true, message = "You studied hard and earned your GED! You feel smarter." }
	
	-- Join Prison Gang
	elseif actionId == "prison_gang" then
		if extState.PrisonGang then
			return { success = false, message = "You're already in a prison gang." }
		end
		local gangNames = {"The Aryans", "MS-13", "The Bloods", "Latin Kings", "Crips"}
		local gang = gangNames[math.random(#gangNames)]
		extState.PrisonGang = gang
		if life and life.SetFlag then
			life:SetFlag("prison_gang_member")
		end
		-- Risk of getting hurt during initiation
		local hurt = math.random(100) <= 30
		if hurt and life then
			life.Stats.Health = math.max(1, (life.Stats.Health or 50) - 15)
		end
		syncStateToClient(player)
		if hurt then
			return { success = true, message = "You joined " .. gang .. ". The initiation was brutal but you're protected now." }
		else
			return { success = true, message = "You joined " .. gang .. ". You now have protection in the yard." }
		end
	
	-- Start Riot
	elseif actionId == "prison_riot" then
		local success = math.random(100) <= 15 -- Very risky
		if success then
			-- Chaos might reduce sentence or get you transferred
			extState.JailYearsLeft = math.max(0, extState.JailYearsLeft - math.random(1, 3))
			if extState.JailYearsLeft <= 0 then
				extState.InJail = false
			end
			syncStateToClient(player)
			return { success = true, message = "In the chaos, you managed to get transferred and your case was lost in paperwork!" }
		else
			-- Caught! Solitary and more time
			extState.JailYearsLeft = extState.JailYearsLeft + math.random(3, 8)
			if life then
				life.Stats.Happiness = math.max(0, (life.Stats.Happiness or 50) - 20)
				life.Stats.Health = math.max(1, (life.Stats.Health or 50) - 10)
			end
			syncStateToClient(player)
			return { success = false, message = "The riot was crushed. You got beat up and sent to solitary. More years added." }
		end
	
	-- Snitch
	elseif actionId == "prison_snitch" then
		local success = math.random(100) <= 60 -- Usually works but dangerous
		if success then
			extState.JailYearsLeft = math.max(0, extState.JailYearsLeft - math.random(1, 2))
			if extState.JailYearsLeft <= 0 then
				extState.InJail = false
			end
			syncStateToClient(player)
			return { success = true, message = "Your info was valuable. Time reduced, but watch your back..." }
		else
			-- Other inmates found out
			if life then
				life.Stats.Health = math.max(1, (life.Stats.Health or 50) - 25)
			end
			syncStateToClient(player)
			return { success = false, message = "Word got out that you're a snitch. You got jumped in the yard." }
		end
	
	-- Appeal Sentence
	elseif actionId == "prison_appeal" then
		if not canAfford(player, 5000) then
			return { success = false, message = "You can't afford a lawyer. Need $5,000." }
		end
		deductMoney(player, 5000)
		
		local smarts = life and life.Stats and life.Stats.Smarts or 50
		local success = math.random(100) <= (20 + math.floor(smarts / 5))
		
		if success then
			local yearsRemoved = math.random(2, 5)
			extState.JailYearsLeft = math.max(0, extState.JailYearsLeft - yearsRemoved)
			if extState.JailYearsLeft <= 0 then
				extState.InJail = false
			end
			syncStateToClient(player)
			return { success = true, message = "Your appeal was successful! " .. yearsRemoved .. " years removed from your sentence." }
		else
			syncStateToClient(player)
			return { success = false, message = "Appeal denied. $5,000 wasted on lawyer fees." }
		end
	
	-- Good Behavior
	elseif actionId == "prison_goodbehavior" then
		local success = math.random(100) <= 70
		if success then
			extState.JailYearsLeft = math.max(0, extState.JailYearsLeft - 1)
			if extState.JailYearsLeft <= 0 then
				extState.InJail = false
			end
			if life then
				life.Stats.Happiness = math.min(100, (life.Stats.Happiness or 50) + 3)
			end
			syncStateToClient(player)
			return { success = true, message = "Your good behavior was noted. Time reduced!" }
		else
			syncStateToClient(player)
			return { success = false, message = "You tried to be good but got caught up in yard drama." }
		end
	end
	
	return { success = false, message = "Unknown prison action." }
end

----------------------------------------------------------------
-- LIFECYCLE AND INTEGRATION
----------------------------------------------------------------

-- Player joined - initialize extended state
Players.PlayerAdded:Connect(function(player)
	getExtendedState(player)
	print("[LifeRemoteHandlers] Initialized extended state for", player.Name)
end)

-- Player left - cleanup
Players.PlayerRemoving:Connect(function(player)
	ExtendedStates[player.UserId] = nil
end)

-- Handle jail time reduction on age up
-- Called from LifeManager when age increases
_G.ReduceJailTime = function(player, years)
	local extState = getExtendedState(player)
	local life = _G.GetPlayerLife and _G.GetPlayerLife(player)
	
	-- Update auto-education based on new age
	updateAutoEducation(player)
	
	-- Handle jail time
	if extState.InJail then
		print("[LifeRemoteHandlers] Reducing jail time by", years, "years. Current:", extState.JailYearsLeft)
		extState.JailYearsLeft = extState.JailYearsLeft - years
		if extState.JailYearsLeft <= 0 then
			-- IMPORTANT: Set sentence_complete FIRST, but KEEP in_prison TRUE
			-- This allows prison_release_day event to fire (which requires BOTH flags)
			-- The event's choice will then clear in_prison when player picks a response
			if life then
				life.Flags = life.Flags or {}
				life.Flags.sentence_complete = true -- For release day event
				life.Flags.ex_convict = true
				-- Keep in_prison = true so the prison_release_day event can fire!
				-- The event choice will clear it
				print("[LifeRemoteHandlers] Set sentence_complete flag - prison_release_day event should fire")
			end
			
			-- Mark jail time as complete but don't immediately release
			-- The prison_release_day event handles the actual release
			extState.JailYearsLeft = 0
			print("[LifeRemoteHandlers] ✅", player.Name, "has served their time! Release day event will fire.")
		else
			print("[LifeRemoteHandlers]", player.Name, "has", string.format("%.2f", extState.JailYearsLeft), "years left in jail")
		end
		syncStateToClient(player)
	end
end

-- Force release from prison (called when prison_release_day event choice is made or as fallback)
_G.ForceReleaseFromPrison = function(player)
	local extState = getExtendedState(player)
	local life = _G.GetPlayerLife and _G.GetPlayerLife(player)
	
	print("[LifeRemoteHandlers] ForceReleaseFromPrison called for", player.Name)
	
	extState.InJail = false
	extState.JailYearsLeft = 0
	
	if life then
		life.Flags = life.Flags or {}
		life.Flags.in_prison = nil
		life.Flags.incarcerated = nil
		life.Flags.sentence_complete = nil
		life.Flags.ex_convict = true
		life.Flags.released_from_prison = true
		print("[LifeRemoteHandlers] Cleared all prison flags, player is now free")
	end
	
	syncStateToClient(player)
end

-- Hook for yearly updates (called from LifeManager)
_G.OnPlayerAgeUp = function(player)
	updateAutoEducation(player)
end

-- Get extended state for external access
_G.GetExtendedState = function(player)
	return getExtendedState(player)
end

-- Sync prison state from flags (called after event choice processing)
-- This ensures ExtendedStates stays in sync with Flags
_G.SyncPrisonStateFromFlags = function(player)
	local extState = getExtendedState(player)
	local life = _G.GetPlayerLife and _G.GetPlayerLife(player)
	
	if not life then return end
	
	local flags = life.Flags or {}
	
	print("[LifeRemoteHandlers] SyncPrisonStateFromFlags - in_prison:", flags.in_prison, "InJail:", extState.InJail, "ex_convict:", flags.ex_convict)
	
	-- CASE 1: in_prison flag is set but ExtendedStates says not in jail - PUT THEM IN JAIL
	if flags.in_prison and not extState.InJail then
		-- This can happen from event choices like recapture
		local addedTime = flags.escape_recaptured and math.random(3, 8) or math.random(2, 5)
		extState.InJail = true
		extState.JailYearsLeft = (extState.JailYearsLeft or 0) + addedTime
		-- Clear sentence_complete since they're back in
		flags.sentence_complete = nil
		print("[LifeRemoteHandlers] Synced prison state - Player jailed for", addedTime, "years from event")
		syncStateToClient(player)
		return
	end
	
	-- CASE 2: in_prison flag is NOT set but ExtendedStates says in jail - RELEASE THEM
	-- This happens when event choice clears in_prison flag (like prison_release_day)
	if not flags.in_prison and extState.InJail then
		-- Check if this is a legitimate release (ex_convict flag set or sentence_complete)
		if flags.ex_convict or flags.escaped_prison or flags.released_from_prison then
			extState.InJail = false
			extState.JailYearsLeft = 0
			-- Clear any remaining sentence flags
			flags.sentence_complete = nil
			print("[LifeRemoteHandlers] Synced prison state - Player released from prison (flags cleared by event)")
			syncStateToClient(player)
			return
		end
	end
	
	-- CASE 3: Both states agree - nothing to do
	-- (in_prison and InJail both true, or both false)
end

-- Send player to jail (callable from other scripts)
_G.SendToJail = function(player, years)
	local extState = getExtendedState(player)
	local life = _G.GetPlayerLife and _G.GetPlayerLife(player)
	
	print("[LifeRemoteHandlers] SendToJail called - Player:", player.Name, "Years:", years)
	
	extState.InJail = true
	extState.JailYearsLeft = (extState.JailYearsLeft or 0) + years
	extState.CurrentJob = nil -- Lose job
	
	if life then
		life.Flags = life.Flags or {}
		life.Flags.in_prison = true
		life.Flags.incarcerated = true
		life.Flags.did_time = true
		-- Clear any release flags
		life.Flags.sentence_complete = nil
		life.Flags.released_from_prison = nil
	end
	
	syncStateToClient(player)
	print("[LifeRemoteHandlers] Player sent to jail for", years, "years")
end

print("[LifeRemoteHandlers] ✅ All remote handlers initialized!")
