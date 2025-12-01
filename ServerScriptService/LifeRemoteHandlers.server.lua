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

-- Load RelationshipService (single source of truth for all relationships)
local RelationshipService = require(ReplicatedStorage:WaitForChild("RelationshipService"))

-- Get all remotes
local GetCapabilities = getRemote("GetCapabilities", true)
local ApplyForJob = getRemote("ApplyForJob", true)
local QuitJob = getRemote("QuitJob", true)
local DoWork = getRemote("DoWork", true)
local EnrollEducation = getRemote("EnrollEducation", true)
local DoFreelance = getRemote("DoFreelance", true)
local TrySpecialCareer = getRemote("TrySpecialCareer", true)

local RequestPromotion = getRemote("RequestPromotion", true)
local RequestRaise = getRemote("RequestRaise", true)
local GetCareerInfo = getRemote("GetCareerInfo", true)

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
-- CAREER SYSTEM DATA (TRIPLE AAA - 70+ CAREERS)
----------------------------------------------------------------

-- Career Categories for organization
local CareerCategories = {
	ENTRY = "entry",           -- No education, part-time, teen jobs
	SERVICE = "service",       -- Customer service, hospitality
	TRADES = "trades",         -- Skilled labor, manual work
	OFFICE = "office",         -- Business, administrative
	TECH = "tech",             -- Technology, engineering
	MEDICAL = "medical",       -- Healthcare
	LAW = "law",               -- Legal profession
	FINANCE = "finance",       -- Banking, accounting
	CREATIVE = "creative",     -- Arts, media, entertainment
	GOVERNMENT = "government", -- Public service
	EDUCATION = "education",   -- Teaching, academia
	SCIENCE = "science",       -- Research, laboratory
	CRIMINAL = "criminal",     -- Illegal careers
	SPORTS = "sports",         -- Athletics, fitness
	MILITARY = "military",     -- Armed forces
}

-- Career Skills that affect performance
local CareerSkills = {
	Technical = 0,   -- Affects tech, science, trades jobs
	Creative = 0,    -- Affects creative, entertainment jobs
	Social = 0,      -- Affects service, sales, management jobs
	Physical = 0,    -- Affects trades, sports, military jobs
	Analytical = 0,  -- Affects finance, law, medical jobs
	Leadership = 0,  -- Affects management, executive positions
}

-- Career Perks (passive bonuses while employed)
local CareerPerks = {
	health_insurance = { stat = "Health", bonus = 2, desc = "Health insurance" },
	gym_membership = { stat = "Health", bonus = 3, desc = "Free gym membership" },
	["401k"] = { money_bonus = 0.05, desc = "401k matching" },
	stock_options = { money_bonus = 0.10, desc = "Stock options" },
	company_car = { asset = "vehicle", desc = "Company car" },
	travel = { stat = "Happiness", bonus = 5, desc = "Travel opportunities" },
	fame_boost = { fame = 0.5, desc = "Media exposure" },
	networking = { social = 5, desc = "Industry connections" },
	flexible_hours = { stat = "Happiness", bonus = 3, desc = "Flexible schedule" },
	remote_work = { stat = "Happiness", bonus = 4, desc = "Work from home" },
	danger_pay = { money_bonus = 0.15, desc = "Hazard pay" },
	prestige = { looks = 2, desc = "Social prestige" },
}

-- MASSIVE JOB LISTINGS - 75+ CAREERS
local JobListings = {
	-- ════════════════════════════════════════════════════════════════
	-- ENTRY LEVEL / PART-TIME (No Education - Teen Jobs)
	-- ════════════════════════════════════════════════════════════════
	{ id = "fastfood", title = "Fast Food Worker", company = "Burger Palace", emoji = "🍔", salary = 22000, education = "None", minAge = 14, exp = 0, acceptance = 95, category = "entry", perks = {} },
	{ id = "retail", title = "Retail Associate", company = "MegaMart", emoji = "🛒", salary = 26000, education = "None", minAge = 16, exp = 0, acceptance = 90, category = "entry", perks = {"flexible_hours"} },
	{ id = "cashier", title = "Cashier", company = "QuickMart", emoji = "💵", salary = 24000, education = "None", minAge = 15, exp = 0, acceptance = 92, category = "entry", perks = {} },
	{ id = "bagger", title = "Grocery Bagger", company = "Fresh Foods", emoji = "🛍️", salary = 18000, education = "None", minAge = 14, exp = 0, acceptance = 98, category = "entry", perks = {} },
	{ id = "movie_usher", title = "Movie Usher", company = "CineMax", emoji = "🎬", salary = 20000, education = "None", minAge = 14, exp = 0, acceptance = 95, category = "entry", perks = {"flexible_hours"} },
	{ id = "lifeguard", title = "Lifeguard", company = "City Pool", emoji = "🏊", salary = 28000, education = "None", minAge = 16, exp = 0, acceptance = 70, category = "entry", perks = {"gym_membership"}, reqSmarts = 30 },
	{ id = "camp_counselor", title = "Camp Counselor", company = "Summer Camp", emoji = "🏕️", salary = 22000, education = "None", minAge = 16, exp = 0, acceptance = 85, category = "entry", perks = {"travel"}, seasonal = true },
	{ id = "newspaper_delivery", title = "Newspaper Delivery", company = "Daily News", emoji = "📰", salary = 15000, education = "None", minAge = 12, exp = 0, acceptance = 98, category = "entry", perks = {} },
	
	-- ════════════════════════════════════════════════════════════════
	-- SERVICE INDUSTRY (High School)
	-- ════════════════════════════════════════════════════════════════
	{ id = "waiter", title = "Waiter/Waitress", company = "The Grand Restaurant", emoji = "🍽️", salary = 32000, education = "None", minAge = 16, exp = 0, acceptance = 88, category = "service", perks = {"flexible_hours"} },
	{ id = "bartender", title = "Bartender", company = "The Tipsy Owl", emoji = "🍸", salary = 38000, education = "None", minAge = 21, exp = 0, acceptance = 75, category = "service", perks = {"flexible_hours"} },
	{ id = "barista", title = "Barista", company = "Bean Scene", emoji = "☕", salary = 28000, education = "None", minAge = 16, exp = 0, acceptance = 85, category = "service", perks = {} },
	{ id = "hotel_front_desk", title = "Hotel Receptionist", company = "Grand Hotel", emoji = "🏨", salary = 32000, education = "High School", minAge = 18, exp = 0, acceptance = 80, category = "service", perks = {"travel"} },
	{ id = "flight_attendant", title = "Flight Attendant", company = "SkyWays Airlines", emoji = "✈️", salary = 55000, education = "High School", minAge = 21, exp = 1, acceptance = 45, category = "service", perks = {"travel", "health_insurance"}, reqLooks = 50 },
	{ id = "tour_guide", title = "Tour Guide", company = "City Tours", emoji = "🗺️", salary = 35000, education = "High School", minAge = 18, exp = 0, acceptance = 70, category = "service", perks = {"travel"}, reqSmarts = 40 },
	{ id = "casino_dealer", title = "Casino Dealer", company = "Lucky Star Casino", emoji = "🎰", salary = 45000, education = "High School", minAge = 21, exp = 0, acceptance = 60, category = "service", perks = {"flexible_hours"} },
	{ id = "cruise_staff", title = "Cruise Ship Staff", company = "Ocean Voyages", emoji = "🚢", salary = 42000, education = "High School", minAge = 18, exp = 0, acceptance = 65, category = "service", perks = {"travel", "flexible_hours"} },
	{ id = "personal_trainer", title = "Personal Trainer", company = "FitLife Gym", emoji = "💪", salary = 48000, education = "High School", minAge = 18, exp = 1, acceptance = 55, category = "service", perks = {"gym_membership"}, reqHealth = 60 },
	
	-- ════════════════════════════════════════════════════════════════
	-- TRADES & SKILLED LABOR (High School / Vocational)
	-- ════════════════════════════════════════════════════════════════
	{ id = "janitor", title = "Janitor", company = "CleanCo Services", emoji = "🧹", salary = 28000, education = "None", minAge = 18, exp = 0, acceptance = 92, category = "trades", perks = {} },
	{ id = "construction", title = "Construction Worker", company = "BuildRight Co", emoji = "👷", salary = 42000, education = "None", minAge = 18, exp = 0, acceptance = 85, category = "trades", perks = {"danger_pay"}, reqHealth = 50 },
	{ id = "electrician_apprentice", title = "Electrician Apprentice", company = "Spark Electric", emoji = "⚡", salary = 35000, education = "High School", minAge = 18, exp = 0, acceptance = 70, category = "trades", perks = {} },
	{ id = "electrician", title = "Electrician", company = "PowerPro Electric", emoji = "⚡", salary = 62000, education = "High School", minAge = 22, exp = 4, acceptance = 60, category = "trades", perks = {"health_insurance"}, promotesFrom = "electrician_apprentice" },
	{ id = "plumber_apprentice", title = "Plumber Apprentice", company = "DrainMaster", emoji = "🔧", salary = 32000, education = "High School", minAge = 18, exp = 0, acceptance = 75, category = "trades", perks = {} },
	{ id = "plumber", title = "Licensed Plumber", company = "FlowRight Plumbing", emoji = "🔧", salary = 58000, education = "High School", minAge = 22, exp = 4, acceptance = 60, category = "trades", perks = {"health_insurance"}, promotesFrom = "plumber_apprentice" },
	{ id = "mechanic", title = "Auto Mechanic", company = "QuickFix Auto", emoji = "🔩", salary = 45000, education = "High School", minAge = 18, exp = 1, acceptance = 70, category = "trades", perks = {} },
	{ id = "hvac_tech", title = "HVAC Technician", company = "CoolAir Systems", emoji = "❄️", salary = 52000, education = "High School", minAge = 20, exp = 2, acceptance = 65, category = "trades", perks = {"health_insurance"} },
	{ id = "welder", title = "Welder", company = "Steel Works Inc", emoji = "🔥", salary = 48000, education = "High School", minAge = 18, exp = 1, acceptance = 70, category = "trades", perks = {"danger_pay"}, reqHealth = 50 },
	{ id = "carpenter", title = "Carpenter", company = "WoodCraft Co", emoji = "🪚", salary = 46000, education = "High School", minAge = 18, exp = 1, acceptance = 72, category = "trades", perks = {} },
	{ id = "truck_driver", title = "Truck Driver", company = "FastFreight Logistics", emoji = "🚛", salary = 55000, education = "High School", minAge = 21, exp = 0, acceptance = 75, category = "trades", perks = {"travel"} },
	{ id = "foreman", title = "Construction Foreman", company = "BuildRight Co", emoji = "🏗️", salary = 72000, education = "High School", minAge = 28, exp = 6, acceptance = 40, category = "trades", perks = {"health_insurance", "company_car"}, promotesFrom = "construction" },
	
	-- ════════════════════════════════════════════════════════════════
	-- OFFICE & BUSINESS (High School / Bachelor's)
	-- ════════════════════════════════════════════════════════════════
	{ id = "receptionist", title = "Receptionist", company = "Corporate Office", emoji = "📞", salary = 32000, education = "High School", minAge = 18, exp = 0, acceptance = 80, category = "office", perks = {"health_insurance"} },
	{ id = "office_assistant", title = "Office Assistant", company = "Business Solutions", emoji = "📋", salary = 35000, education = "High School", minAge = 18, exp = 1, acceptance = 75, category = "office", perks = {"health_insurance"} },
	{ id = "data_entry", title = "Data Entry Clerk", company = "DataCorp", emoji = "⌨️", salary = 34000, education = "High School", minAge = 18, exp = 0, acceptance = 82, category = "office", perks = {"remote_work"} },
	{ id = "administrative_assistant", title = "Administrative Assistant", company = "Executive Office", emoji = "📁", salary = 42000, education = "High School", minAge = 20, exp = 2, acceptance = 70, category = "office", perks = {"health_insurance", "401k"} },
	{ id = "hr_coordinator", title = "HR Coordinator", company = "PeopleFirst HR", emoji = "👥", salary = 48000, education = "Bachelor's", minAge = 22, exp = 1, acceptance = 60, category = "office", perks = {"health_insurance", "401k"} },
	{ id = "hr_manager", title = "HR Manager", company = "PeopleFirst HR", emoji = "👥", salary = 78000, education = "Bachelor's", minAge = 28, exp = 5, acceptance = 40, category = "office", perks = {"health_insurance", "401k", "stock_options"}, promotesFrom = "hr_coordinator" },
	{ id = "recruiter", title = "Corporate Recruiter", company = "TalentFind Inc", emoji = "🔍", salary = 58000, education = "Bachelor's", minAge = 24, exp = 2, acceptance = 55, category = "office", perks = {"health_insurance", "networking"} },
	{ id = "office_manager", title = "Office Manager", company = "CorpWorld Inc", emoji = "🏢", salary = 62000, education = "Bachelor's", minAge = 26, exp = 4, acceptance = 50, category = "office", perks = {"health_insurance", "401k"}, promotesFrom = "administrative_assistant" },
	{ id = "executive_assistant", title = "Executive Assistant", company = "CEO Office", emoji = "👔", salary = 72000, education = "Bachelor's", minAge = 26, exp = 4, acceptance = 40, category = "office", perks = {"health_insurance", "401k", "prestige"} },
	{ id = "project_manager", title = "Project Manager", company = "ManageAll Corp", emoji = "📊", salary = 85000, education = "Bachelor's", minAge = 28, exp = 5, acceptance = 45, category = "office", perks = {"health_insurance", "401k", "stock_options"} },
	{ id = "operations_director", title = "Operations Director", company = "Global Corp", emoji = "🎯", salary = 145000, education = "Master's", minAge = 35, exp = 10, acceptance = 25, category = "office", perks = {"health_insurance", "401k", "stock_options", "company_car"}, promotesFrom = "project_manager" },
	{ id = "coo", title = "Chief Operating Officer", company = "Fortune 500", emoji = "🏆", salary = 350000, education = "Master's", minAge = 42, exp = 18, acceptance = 10, category = "office", perks = {"health_insurance", "401k", "stock_options", "company_car", "prestige"}, promotesFrom = "operations_director" },
	
	-- ════════════════════════════════════════════════════════════════
	-- TECHNOLOGY (Bachelor's+)
	-- ════════════════════════════════════════════════════════════════
	{ id = "it_support", title = "IT Support Technician", company = "TechHelp Inc", emoji = "🖥️", salary = 45000, education = "High School", minAge = 18, exp = 0, acceptance = 70, category = "tech", perks = {"remote_work"}, reqSmarts = 45 },
	{ id = "junior_developer", title = "Junior Developer", company = "CodeStart Inc", emoji = "💻", salary = 65000, education = "Bachelor's", minAge = 21, exp = 0, acceptance = 55, category = "tech", perks = {"remote_work", "flexible_hours"}, reqSmarts = 55 },
	{ id = "developer", title = "Software Developer", company = "TechStart Inc", emoji = "💻", salary = 95000, education = "Bachelor's", minAge = 23, exp = 2, acceptance = 50, category = "tech", perks = {"remote_work", "flexible_hours", "401k"}, reqSmarts = 60, promotesFrom = "junior_developer" },
	{ id = "senior_developer", title = "Senior Developer", company = "BigTech Corp", emoji = "💻", salary = 145000, education = "Bachelor's", minAge = 27, exp = 5, acceptance = 35, category = "tech", perks = {"remote_work", "flexible_hours", "401k", "stock_options"}, reqSmarts = 65, promotesFrom = "developer" },
	{ id = "tech_lead", title = "Tech Lead", company = "BigTech Corp", emoji = "👨‍💻", salary = 175000, education = "Bachelor's", minAge = 30, exp = 8, acceptance = 25, category = "tech", perks = {"remote_work", "401k", "stock_options"}, reqSmarts = 70, promotesFrom = "senior_developer" },
	{ id = "software_architect", title = "Software Architect", company = "MegaTech Inc", emoji = "🏗️", salary = 195000, education = "Master's", minAge = 32, exp = 10, acceptance = 20, category = "tech", perks = {"remote_work", "401k", "stock_options", "prestige"}, reqSmarts = 75, promotesFrom = "tech_lead" },
	{ id = "web_developer", title = "Web Developer", company = "WebWorks Studio", emoji = "🌐", salary = 78000, education = "Bachelor's", minAge = 22, exp = 1, acceptance = 55, category = "tech", perks = {"remote_work", "flexible_hours"}, reqSmarts = 55 },
	{ id = "mobile_developer", title = "Mobile App Developer", company = "AppFactory", emoji = "📱", salary = 92000, education = "Bachelor's", minAge = 23, exp = 2, acceptance = 50, category = "tech", perks = {"remote_work", "flexible_hours"}, reqSmarts = 58 },
	{ id = "data_analyst", title = "Data Analyst", company = "DataDriven Co", emoji = "📈", salary = 72000, education = "Bachelor's", minAge = 22, exp = 1, acceptance = 55, category = "tech", perks = {"remote_work", "401k"}, reqSmarts = 60 },
	{ id = "data_scientist", title = "Data Scientist", company = "AI Innovations", emoji = "🧠", salary = 135000, education = "Master's", minAge = 26, exp = 3, acceptance = 35, category = "tech", perks = {"remote_work", "401k", "stock_options"}, reqSmarts = 70, promotesFrom = "data_analyst" },
	{ id = "ml_engineer", title = "Machine Learning Engineer", company = "AI Labs", emoji = "🤖", salary = 165000, education = "Master's", minAge = 28, exp = 5, acceptance = 25, category = "tech", perks = {"remote_work", "401k", "stock_options"}, reqSmarts = 75 },
	{ id = "cybersecurity_analyst", title = "Cybersecurity Analyst", company = "SecureNet", emoji = "🔐", salary = 95000, education = "Bachelor's", minAge = 24, exp = 2, acceptance = 45, category = "tech", perks = {"remote_work", "401k"}, reqSmarts = 65 },
	{ id = "security_engineer", title = "Security Engineer", company = "CyberShield", emoji = "🛡️", salary = 140000, education = "Bachelor's", minAge = 28, exp = 5, acceptance = 30, category = "tech", perks = {"remote_work", "401k", "stock_options"}, reqSmarts = 70, promotesFrom = "cybersecurity_analyst" },
	{ id = "devops_engineer", title = "DevOps Engineer", company = "CloudOps Inc", emoji = "☁️", salary = 125000, education = "Bachelor's", minAge = 26, exp = 4, acceptance = 40, category = "tech", perks = {"remote_work", "401k"}, reqSmarts = 65 },
	{ id = "cto", title = "Chief Technology Officer", company = "Tech Giant", emoji = "🚀", salary = 380000, education = "Master's", minAge = 38, exp = 15, acceptance = 8, category = "tech", perks = {"stock_options", "company_car", "prestige"}, reqSmarts = 80, promotesFrom = "software_architect" },
	
	-- ════════════════════════════════════════════════════════════════
	-- MEDICAL / HEALTHCARE (Varies)
	-- ════════════════════════════════════════════════════════════════
	{ id = "hospital_orderly", title = "Hospital Orderly", company = "City Hospital", emoji = "🏥", salary = 28000, education = "None", minAge = 18, exp = 0, acceptance = 88, category = "medical", perks = {"health_insurance"} },
	{ id = "medical_assistant", title = "Medical Assistant", company = "Family Clinic", emoji = "💉", salary = 36000, education = "High School", minAge = 18, exp = 0, acceptance = 75, category = "medical", perks = {"health_insurance"} },
	{ id = "emt", title = "EMT / Paramedic", company = "City Ambulance", emoji = "🚑", salary = 42000, education = "High School", minAge = 18, exp = 0, acceptance = 60, category = "medical", perks = {"health_insurance", "danger_pay"}, reqHealth = 50 },
	{ id = "nurse_lpn", title = "Licensed Practical Nurse", company = "Regional Hospital", emoji = "👩‍⚕️", salary = 52000, education = "Community College", minAge = 20, exp = 1, acceptance = 65, category = "medical", perks = {"health_insurance", "401k"} },
	{ id = "nurse_rn", title = "Registered Nurse", company = "City Hospital", emoji = "👩‍⚕️", salary = 78000, education = "Bachelor's", minAge = 22, exp = 2, acceptance = 55, category = "medical", perks = {"health_insurance", "401k"}, promotesFrom = "nurse_lpn" },
	{ id = "nurse_practitioner", title = "Nurse Practitioner", company = "Medical Center", emoji = "👩‍⚕️", salary = 118000, education = "Master's", minAge = 28, exp = 5, acceptance = 40, category = "medical", perks = {"health_insurance", "401k"}, promotesFrom = "nurse_rn" },
	{ id = "physical_therapist", title = "Physical Therapist", company = "RehabCare Center", emoji = "🦿", salary = 92000, education = "Master's", minAge = 26, exp = 2, acceptance = 50, category = "medical", perks = {"health_insurance", "401k"} },
	{ id = "pharmacist", title = "Pharmacist", company = "MediPharm", emoji = "💊", salary = 128000, education = "PhD", minAge = 28, exp = 2, acceptance = 45, category = "medical", perks = {"health_insurance", "401k"} },
	{ id = "dentist", title = "Dentist", company = "Bright Smiles Dental", emoji = "🦷", salary = 175000, education = "Medical School", minAge = 28, exp = 2, acceptance = 35, category = "medical", perks = {"health_insurance", "401k", "prestige"} },
	{ id = "doctor_resident", title = "Medical Resident", company = "Teaching Hospital", emoji = "🩺", salary = 65000, education = "Medical School", minAge = 26, exp = 0, acceptance = 40, category = "medical", perks = {"health_insurance"} },
	{ id = "doctor", title = "Doctor", company = "City Hospital", emoji = "🩺", salary = 250000, education = "Medical School", minAge = 30, exp = 4, acceptance = 30, category = "medical", perks = {"health_insurance", "401k", "prestige"}, promotesFrom = "doctor_resident" },
	{ id = "surgeon", title = "Surgeon", company = "Medical Center", emoji = "🔪", salary = 420000, education = "Medical School", minAge = 34, exp = 8, acceptance = 15, category = "medical", perks = {"health_insurance", "401k", "prestige"}, promotesFrom = "doctor" },
	{ id = "chief_of_medicine", title = "Chief of Medicine", company = "University Hospital", emoji = "👨‍⚕️", salary = 550000, education = "Medical School", minAge = 45, exp = 18, acceptance = 5, category = "medical", perks = {"health_insurance", "401k", "prestige", "company_car"}, promotesFrom = "surgeon" },
	{ id = "psychiatrist", title = "Psychiatrist", company = "Mental Health Center", emoji = "🧠", salary = 280000, education = "Medical School", minAge = 32, exp = 6, acceptance = 25, category = "medical", perks = {"health_insurance", "401k"} },
	{ id = "veterinarian", title = "Veterinarian", company = "Pet Care Clinic", emoji = "🐾", salary = 105000, education = "Medical School", minAge = 28, exp = 2, acceptance = 40, category = "medical", perks = {"health_insurance", "401k"} },
	
	-- ════════════════════════════════════════════════════════════════
	-- LEGAL (Law School)
	-- ════════════════════════════════════════════════════════════════
	{ id = "paralegal", title = "Paralegal", company = "Legal Associates", emoji = "📜", salary = 52000, education = "Bachelor's", minAge = 22, exp = 0, acceptance = 65, category = "law", perks = {"health_insurance"}, reqSmarts = 50 },
	{ id = "legal_assistant", title = "Legal Assistant", company = "Smith & Partners", emoji = "📝", salary = 42000, education = "High School", minAge = 18, exp = 0, acceptance = 70, category = "law", perks = {"health_insurance"} },
	{ id = "associate_lawyer", title = "Associate Attorney", company = "Law Firm LLP", emoji = "⚖️", salary = 95000, education = "Law School", minAge = 26, exp = 0, acceptance = 45, category = "law", perks = {"health_insurance", "401k"}, reqSmarts = 65 },
	{ id = "lawyer", title = "Attorney", company = "Smith & Associates", emoji = "⚖️", salary = 145000, education = "Law School", minAge = 28, exp = 2, acceptance = 35, category = "law", perks = {"health_insurance", "401k", "prestige"}, reqSmarts = 70, promotesFrom = "associate_lawyer" },
	{ id = "senior_partner", title = "Senior Partner", company = "Elite Law Firm", emoji = "⚖️", salary = 350000, education = "Law School", minAge = 38, exp = 12, acceptance = 15, category = "law", perks = {"health_insurance", "401k", "prestige", "stock_options"}, reqSmarts = 75, promotesFrom = "lawyer" },
	{ id = "prosecutor", title = "Prosecutor", company = "District Attorney", emoji = "🏛️", salary = 95000, education = "Law School", minAge = 28, exp = 2, acceptance = 40, category = "law", perks = {"health_insurance", "401k"}, reqSmarts = 65 },
	{ id = "public_defender", title = "Public Defender", company = "Public Defender's Office", emoji = "🏛️", salary = 72000, education = "Law School", minAge = 26, exp = 0, acceptance = 55, category = "law", perks = {"health_insurance"}, reqSmarts = 60 },
	{ id = "judge", title = "Judge", company = "Superior Court", emoji = "👨‍⚖️", salary = 195000, education = "Law School", minAge = 45, exp = 18, acceptance = 8, category = "law", perks = {"health_insurance", "401k", "prestige"}, reqSmarts = 80, promotesFrom = "senior_partner" },
	
	-- ════════════════════════════════════════════════════════════════
	-- FINANCE (Bachelor's+)
	-- ════════════════════════════════════════════════════════════════
	{ id = "bank_teller", title = "Bank Teller", company = "First National Bank", emoji = "🏦", salary = 34000, education = "High School", minAge = 18, exp = 0, acceptance = 78, category = "finance", perks = {"health_insurance"} },
	{ id = "loan_officer", title = "Loan Officer", company = "City Bank", emoji = "💰", salary = 58000, education = "Bachelor's", minAge = 22, exp = 1, acceptance = 60, category = "finance", perks = {"health_insurance", "401k"}, promotesFrom = "bank_teller" },
	{ id = "accountant_jr", title = "Junior Accountant", company = "Financial Services", emoji = "📊", salary = 52000, education = "Bachelor's", minAge = 22, exp = 0, acceptance = 65, category = "finance", perks = {"health_insurance", "401k"}, reqSmarts = 55 },
	{ id = "accountant", title = "Senior Accountant", company = "Big4 Accounting", emoji = "📊", salary = 78000, education = "Bachelor's", minAge = 25, exp = 3, acceptance = 50, category = "finance", perks = {"health_insurance", "401k"}, reqSmarts = 60, promotesFrom = "accountant_jr" },
	{ id = "cpa", title = "Certified Public Accountant", company = "CPA Partners", emoji = "📊", salary = 95000, education = "Bachelor's", minAge = 28, exp = 5, acceptance = 40, category = "finance", perks = {"health_insurance", "401k"}, reqSmarts = 65, promotesFrom = "accountant" },
	{ id = "financial_analyst", title = "Financial Analyst", company = "Investment Group", emoji = "📈", salary = 85000, education = "Bachelor's", minAge = 23, exp = 1, acceptance = 50, category = "finance", perks = {"health_insurance", "401k"}, reqSmarts = 65 },
	{ id = "investment_banker_jr", title = "Investment Banking Analyst", company = "Goldman & Partners", emoji = "💹", salary = 120000, education = "Bachelor's", minAge = 22, exp = 0, acceptance = 25, category = "finance", perks = {"health_insurance", "401k"}, reqSmarts = 70 },
	{ id = "investment_banker", title = "Investment Banker", company = "Wall Street Bank", emoji = "💹", salary = 225000, education = "Master's", minAge = 28, exp = 5, acceptance = 20, category = "finance", perks = {"health_insurance", "401k", "stock_options"}, reqSmarts = 75, promotesFrom = "investment_banker_jr" },
	{ id = "hedge_fund_manager", title = "Hedge Fund Manager", company = "Elite Capital", emoji = "🏦", salary = 750000, education = "Master's", minAge = 35, exp = 12, acceptance = 5, category = "finance", perks = {"stock_options", "prestige"}, reqSmarts = 80, promotesFrom = "investment_banker" },
	{ id = "actuary", title = "Actuary", company = "Insurance Corp", emoji = "🧮", salary = 125000, education = "Bachelor's", minAge = 26, exp = 3, acceptance = 35, category = "finance", perks = {"health_insurance", "401k"}, reqSmarts = 75 },
	{ id = "cfo", title = "Chief Financial Officer", company = "Fortune 500", emoji = "💼", salary = 450000, education = "Master's", minAge = 42, exp = 18, acceptance = 8, category = "finance", perks = {"stock_options", "company_car", "prestige"}, reqSmarts = 80, promotesFrom = "hedge_fund_manager" },
	
	-- ════════════════════════════════════════════════════════════════
	-- CREATIVE / MEDIA / ENTERTAINMENT
	-- ════════════════════════════════════════════════════════════════
	{ id = "graphic_designer_jr", title = "Junior Graphic Designer", company = "Design Studio", emoji = "🎨", salary = 42000, education = "Bachelor's", minAge = 21, exp = 0, acceptance = 60, category = "creative", perks = {"flexible_hours"} },
	{ id = "graphic_designer", title = "Graphic Designer", company = "Creative Agency", emoji = "🎨", salary = 62000, education = "Bachelor's", minAge = 24, exp = 2, acceptance = 50, category = "creative", perks = {"flexible_hours", "remote_work"}, promotesFrom = "graphic_designer_jr" },
	{ id = "art_director", title = "Art Director", company = "Top Agency", emoji = "🎨", salary = 115000, education = "Bachelor's", minAge = 30, exp = 8, acceptance = 30, category = "creative", perks = {"flexible_hours", "prestige"}, promotesFrom = "graphic_designer" },
	{ id = "photographer", title = "Photographer", company = "Photo Studio", emoji = "📷", salary = 48000, education = "None", minAge = 18, exp = 1, acceptance = 55, category = "creative", perks = {"flexible_hours"} },
	{ id = "videographer", title = "Videographer", company = "Video Productions", emoji = "🎥", salary = 55000, education = "Bachelor's", minAge = 21, exp = 1, acceptance = 50, category = "creative", perks = {"flexible_hours"} },
	{ id = "journalist_jr", title = "Junior Journalist", company = "City News", emoji = "📰", salary = 38000, education = "Bachelor's", minAge = 22, exp = 0, acceptance = 55, category = "creative", perks = {} },
	{ id = "journalist", title = "Journalist", company = "National Times", emoji = "📰", salary = 62000, education = "Bachelor's", minAge = 26, exp = 3, acceptance = 40, category = "creative", perks = {"travel"}, promotesFrom = "journalist_jr" },
	{ id = "editor", title = "Editor", company = "Publishing House", emoji = "✍️", salary = 72000, education = "Bachelor's", minAge = 28, exp = 5, acceptance = 35, category = "creative", perks = {"remote_work"}, promotesFrom = "journalist" },
	{ id = "social_media_manager", title = "Social Media Manager", company = "Digital Agency", emoji = "📱", salary = 55000, education = "Bachelor's", minAge = 22, exp = 1, acceptance = 55, category = "creative", perks = {"remote_work", "flexible_hours"} },
	{ id = "marketing_associate", title = "Marketing Associate", company = "AdVenture Agency", emoji = "📈", salary = 52000, education = "Bachelor's", minAge = 22, exp = 1, acceptance = 55, category = "creative", perks = {"health_insurance"} },
	{ id = "marketing_manager", title = "Marketing Manager", company = "Brand Corp", emoji = "📈", salary = 95000, education = "Bachelor's", minAge = 28, exp = 5, acceptance = 40, category = "creative", perks = {"health_insurance", "401k"}, promotesFrom = "marketing_associate" },
	{ id = "cmo", title = "Chief Marketing Officer", company = "Fortune 500", emoji = "📢", salary = 320000, education = "Master's", minAge = 40, exp = 15, acceptance = 10, category = "creative", perks = {"stock_options", "company_car", "prestige"}, promotesFrom = "marketing_manager" },
	{ id = "actor_extra", title = "Background Actor", company = "Hollywood Studios", emoji = "🎭", salary = 25000, education = "None", minAge = 18, exp = 0, acceptance = 75, category = "creative", perks = {"flexible_hours"}, reqLooks = 40 },
	{ id = "actor", title = "Actor", company = "Talent Agency", emoji = "🎭", salary = 85000, education = "None", minAge = 21, exp = 3, acceptance = 15, category = "creative", perks = {"fame_boost"}, reqLooks = 60, promotesFrom = "actor_extra" },
	{ id = "movie_star", title = "Movie Star", company = "Major Studios", emoji = "⭐", salary = 2500000, education = "None", minAge = 25, exp = 8, acceptance = 2, category = "creative", perks = {"fame_boost", "prestige"}, reqLooks = 75, promotesFrom = "actor" },
	{ id = "musician_local", title = "Local Musician", company = "Self-Employed", emoji = "🎸", salary = 28000, education = "None", minAge = 16, exp = 0, acceptance = 70, category = "creative", perks = {"flexible_hours"} },
	{ id = "musician_signed", title = "Signed Musician", company = "Record Label", emoji = "🎸", salary = 95000, education = "None", minAge = 20, exp = 3, acceptance = 12, category = "creative", perks = {"fame_boost", "travel"}, promotesFrom = "musician_local" },
	{ id = "pop_star", title = "Pop Star", company = "Global Records", emoji = "🎤", salary = 5000000, education = "None", minAge = 22, exp = 6, acceptance = 1, category = "creative", perks = {"fame_boost", "prestige", "travel"}, promotesFrom = "musician_signed" },
	
	-- ════════════════════════════════════════════════════════════════
	-- GOVERNMENT / PUBLIC SERVICE
	-- ════════════════════════════════════════════════════════════════
	{ id = "postal_worker", title = "Postal Worker", company = "US Postal Service", emoji = "📮", salary = 45000, education = "High School", minAge = 18, exp = 0, acceptance = 70, category = "government", perks = {"health_insurance", "401k"} },
	{ id = "dmv_clerk", title = "DMV Clerk", company = "Dept of Motor Vehicles", emoji = "🚗", salary = 38000, education = "High School", minAge = 18, exp = 0, acceptance = 80, category = "government", perks = {"health_insurance"} },
	{ id = "social_worker", title = "Social Worker", company = "Family Services", emoji = "🤝", salary = 52000, education = "Bachelor's", minAge = 22, exp = 0, acceptance = 60, category = "government", perks = {"health_insurance", "401k"} },
	{ id = "probation_officer", title = "Probation Officer", company = "Corrections Dept", emoji = "🔒", salary = 55000, education = "Bachelor's", minAge = 22, exp = 1, acceptance = 55, category = "government", perks = {"health_insurance", "401k"} },
	{ id = "police_officer", title = "Police Officer", company = "City Police Dept", emoji = "👮", salary = 62000, education = "High School", minAge = 21, exp = 0, acceptance = 45, category = "government", perks = {"health_insurance", "401k", "danger_pay"}, reqHealth = 60 },
	{ id = "detective", title = "Detective", company = "City Police Dept", emoji = "🔍", salary = 85000, education = "Bachelor's", minAge = 28, exp = 5, acceptance = 30, category = "government", perks = {"health_insurance", "401k", "danger_pay"}, promotesFrom = "police_officer" },
	{ id = "police_chief", title = "Police Chief", company = "City Police Dept", emoji = "👮‍♂️", salary = 145000, education = "Bachelor's", minAge = 40, exp = 15, acceptance = 10, category = "government", perks = {"health_insurance", "401k", "prestige", "company_car"}, promotesFrom = "detective" },
	{ id = "firefighter", title = "Firefighter", company = "Fire Department", emoji = "🚒", salary = 58000, education = "High School", minAge = 18, exp = 0, acceptance = 40, category = "government", perks = {"health_insurance", "401k", "danger_pay"}, reqHealth = 70 },
	{ id = "fire_captain", title = "Fire Captain", company = "Fire Department", emoji = "🚒", salary = 95000, education = "High School", minAge = 32, exp = 10, acceptance = 20, category = "government", perks = {"health_insurance", "401k", "prestige"}, promotesFrom = "firefighter" },
	{ id = "city_council", title = "City Council Member", company = "City Government", emoji = "🏛️", salary = 72000, education = "Bachelor's", minAge = 25, exp = 2, acceptance = 25, category = "government", perks = {"prestige", "networking"} },
	{ id = "mayor", title = "Mayor", company = "City Hall", emoji = "🏛️", salary = 185000, education = "Bachelor's", minAge = 35, exp = 10, acceptance = 8, category = "government", perks = {"prestige", "networking", "fame_boost"}, promotesFrom = "city_council" },
	{ id = "fbi_agent", title = "FBI Agent", company = "Federal Bureau of Investigation", emoji = "🕵️", salary = 95000, education = "Bachelor's", minAge = 25, exp = 2, acceptance = 20, category = "government", perks = {"health_insurance", "401k", "danger_pay"}, reqSmarts = 65, reqHealth = 60 },
	{ id = "cia_agent", title = "CIA Agent", company = "Central Intelligence Agency", emoji = "🕵️‍♂️", salary = 105000, education = "Bachelor's", minAge = 26, exp = 3, acceptance = 12, category = "government", perks = {"health_insurance", "401k", "danger_pay", "travel"}, reqSmarts = 70, reqHealth = 55 },
	{ id = "diplomat", title = "Diplomat", company = "State Department", emoji = "🌍", salary = 125000, education = "Master's", minAge = 30, exp = 5, acceptance = 15, category = "government", perks = {"travel", "prestige", "health_insurance"}, reqSmarts = 70 },
	{ id = "senator", title = "Senator", company = "US Senate", emoji = "🏛️", salary = 174000, education = "Bachelor's", minAge = 35, exp = 10, acceptance = 3, category = "government", perks = {"prestige", "fame_boost", "networking"}, promotesFrom = "mayor" },
	{ id = "president", title = "President", company = "United States", emoji = "🇺🇸", salary = 400000, education = "Bachelor's", minAge = 35, exp = 15, acceptance = 0.1, category = "government", perks = {"prestige", "fame_boost"}, promotesFrom = "senator" },
	
	-- ════════════════════════════════════════════════════════════════
	-- EDUCATION
	-- ════════════════════════════════════════════════════════════════
	{ id = "teaching_assistant", title = "Teaching Assistant", company = "Local School", emoji = "📚", salary = 28000, education = "High School", minAge = 18, exp = 0, acceptance = 75, category = "education", perks = {} },
	{ id = "substitute_teacher", title = "Substitute Teacher", company = "School District", emoji = "📚", salary = 32000, education = "Bachelor's", minAge = 21, exp = 0, acceptance = 70, category = "education", perks = {"flexible_hours"} },
	{ id = "teacher", title = "Teacher", company = "Public School", emoji = "👨‍🏫", salary = 52000, education = "Bachelor's", minAge = 22, exp = 1, acceptance = 60, category = "education", perks = {"health_insurance", "401k"}, promotesFrom = "substitute_teacher" },
	{ id = "department_head", title = "Department Head", company = "High School", emoji = "👨‍🏫", salary = 72000, education = "Master's", minAge = 32, exp = 8, acceptance = 40, category = "education", perks = {"health_insurance", "401k"}, promotesFrom = "teacher" },
	{ id = "principal", title = "School Principal", company = "Local School District", emoji = "🏫", salary = 105000, education = "Master's", minAge = 38, exp = 12, acceptance = 25, category = "education", perks = {"health_insurance", "401k", "prestige"}, promotesFrom = "department_head" },
	{ id = "superintendent", title = "School Superintendent", company = "School District", emoji = "🏫", salary = 185000, education = "PhD", minAge = 45, exp = 18, acceptance = 10, category = "education", perks = {"health_insurance", "401k", "prestige", "company_car"}, promotesFrom = "principal" },
	{ id = "professor_assistant", title = "Assistant Professor", company = "State University", emoji = "🎓", salary = 72000, education = "PhD", minAge = 28, exp = 2, acceptance = 35, category = "education", perks = {"health_insurance"}, reqSmarts = 70 },
	{ id = "professor", title = "Professor", company = "University", emoji = "🎓", salary = 115000, education = "PhD", minAge = 35, exp = 8, acceptance = 25, category = "education", perks = {"health_insurance", "401k", "prestige"}, reqSmarts = 75, promotesFrom = "professor_assistant" },
	{ id = "dean", title = "Dean", company = "University", emoji = "🎓", salary = 225000, education = "PhD", minAge = 45, exp = 18, acceptance = 10, category = "education", perks = {"health_insurance", "401k", "prestige"}, reqSmarts = 80, promotesFrom = "professor" },
	
	-- ════════════════════════════════════════════════════════════════
	-- SCIENCE / RESEARCH
	-- ════════════════════════════════════════════════════════════════
	{ id = "lab_technician", title = "Lab Technician", company = "Research Lab", emoji = "🔬", salary = 42000, education = "Bachelor's", minAge = 22, exp = 0, acceptance = 60, category = "science", perks = {"health_insurance"}, reqSmarts = 55 },
	{ id = "research_assistant", title = "Research Assistant", company = "University Lab", emoji = "🔬", salary = 48000, education = "Bachelor's", minAge = 22, exp = 1, acceptance = 55, category = "science", perks = {"health_insurance"}, reqSmarts = 60 },
	{ id = "scientist", title = "Scientist", company = "Research Institute", emoji = "🧪", salary = 85000, education = "Master's", minAge = 26, exp = 3, acceptance = 40, category = "science", perks = {"health_insurance", "401k"}, reqSmarts = 70, promotesFrom = "research_assistant" },
	{ id = "senior_scientist", title = "Senior Scientist", company = "BioTech Corp", emoji = "🧪", salary = 125000, education = "PhD", minAge = 32, exp = 8, acceptance = 30, category = "science", perks = {"health_insurance", "401k", "stock_options"}, reqSmarts = 75, promotesFrom = "scientist" },
	{ id = "research_director", title = "Research Director", company = "Innovation Labs", emoji = "🔬", salary = 195000, education = "PhD", minAge = 40, exp = 15, acceptance = 15, category = "science", perks = {"health_insurance", "401k", "stock_options", "prestige"}, reqSmarts = 80, promotesFrom = "senior_scientist" },
	
	-- ════════════════════════════════════════════════════════════════
	-- SPORTS / ATHLETICS
	-- ════════════════════════════════════════════════════════════════
	{ id = "gym_instructor", title = "Gym Instructor", company = "Fitness Center", emoji = "🏋️", salary = 35000, education = "None", minAge = 18, exp = 0, acceptance = 65, category = "sports", perks = {"gym_membership"}, reqHealth = 60 },
	{ id = "minor_league", title = "Minor League Player", company = "Farm Team", emoji = "⚾", salary = 45000, education = "None", minAge = 18, exp = 0, acceptance = 15, category = "sports", perks = {"gym_membership", "travel"}, reqHealth = 80 },
	{ id = "professional_athlete", title = "Professional Athlete", company = "Sports Team", emoji = "🏆", salary = 850000, education = "None", minAge = 21, exp = 3, acceptance = 5, category = "sports", perks = {"fame_boost", "travel"}, reqHealth = 90, promotesFrom = "minor_league" },
	{ id = "star_athlete", title = "Star Athlete", company = "Champion Team", emoji = "⭐", salary = 15000000, education = "None", minAge = 24, exp = 6, acceptance = 1, category = "sports", perks = {"fame_boost", "prestige"}, reqHealth = 95, promotesFrom = "professional_athlete" },
	{ id = "sports_coach", title = "Sports Coach", company = "High School", emoji = "📋", salary = 55000, education = "Bachelor's", minAge = 25, exp = 3, acceptance = 50, category = "sports", perks = {"health_insurance"}, reqHealth = 50 },
	{ id = "head_coach", title = "Head Coach", company = "Pro Team", emoji = "📋", salary = 2500000, education = "Bachelor's", minAge = 40, exp = 15, acceptance = 5, category = "sports", perks = {"fame_boost", "prestige"}, promotesFrom = "sports_coach" },
	
	-- ════════════════════════════════════════════════════════════════
	-- MILITARY
	-- ════════════════════════════════════════════════════════════════
	{ id = "enlisted", title = "Enlisted Soldier", company = "US Army", emoji = "🪖", salary = 35000, education = "High School", minAge = 18, exp = 0, acceptance = 70, category = "military", perks = {"health_insurance", "danger_pay"}, reqHealth = 60 },
	{ id = "sergeant", title = "Sergeant", company = "US Army", emoji = "🪖", salary = 55000, education = "High School", minAge = 24, exp = 4, acceptance = 50, category = "military", perks = {"health_insurance", "danger_pay"}, reqHealth = 60, promotesFrom = "enlisted" },
	{ id = "officer", title = "Military Officer", company = "US Armed Forces", emoji = "🎖️", salary = 75000, education = "Bachelor's", minAge = 22, exp = 0, acceptance = 35, category = "military", perks = {"health_insurance", "danger_pay", "prestige"}, reqHealth = 65 },
	{ id = "captain", title = "Captain", company = "US Armed Forces", emoji = "🎖️", salary = 95000, education = "Bachelor's", minAge = 28, exp = 5, acceptance = 25, category = "military", perks = {"health_insurance", "danger_pay", "prestige"}, reqHealth = 60, promotesFrom = "officer" },
	{ id = "colonel", title = "Colonel", company = "US Armed Forces", emoji = "🎖️", salary = 135000, education = "Master's", minAge = 38, exp = 15, acceptance = 12, category = "military", perks = {"health_insurance", "prestige"}, promotesFrom = "captain" },
	{ id = "general", title = "General", company = "Pentagon", emoji = "⭐", salary = 220000, education = "Master's", minAge = 50, exp = 25, acceptance = 3, category = "military", perks = {"health_insurance", "prestige", "fame_boost"}, promotesFrom = "colonel" },
	
	-- ════════════════════════════════════════════════════════════════
	-- CRIMINAL CAREERS (Illegal - High Risk/Reward)
	-- ════════════════════════════════════════════════════════════════
	{ id = "drug_dealer_street", title = "Street Dealer", company = "The Streets", emoji = "💊", salary = 45000, education = "None", minAge = 16, exp = 0, acceptance = 80, category = "criminal", perks = {"danger_pay"}, illegal = true },
	{ id = "drug_dealer", title = "Drug Dealer", company = "The Organization", emoji = "💊", salary = 120000, education = "None", minAge = 20, exp = 2, acceptance = 50, category = "criminal", perks = {"danger_pay"}, illegal = true, promotesFrom = "drug_dealer_street" },
	{ id = "hitman", title = "Hitman", company = "Unknown", emoji = "🔫", salary = 200000, education = "None", minAge = 25, exp = 5, acceptance = 15, category = "criminal", perks = {"danger_pay"}, illegal = true, reqHealth = 60 },
	{ id = "gang_member", title = "Gang Member", company = "The Gang", emoji = "🔪", salary = 55000, education = "None", minAge = 16, exp = 0, acceptance = 70, category = "criminal", perks = {"danger_pay"}, illegal = true },
	{ id = "gang_lieutenant", title = "Gang Lieutenant", company = "The Gang", emoji = "🔪", salary = 150000, education = "None", minAge = 22, exp = 4, acceptance = 30, category = "criminal", perks = {"danger_pay"}, illegal = true, promotesFrom = "gang_member" },
	{ id = "crime_boss", title = "Crime Boss", company = "The Syndicate", emoji = "🎩", salary = 500000, education = "None", minAge = 30, exp = 10, acceptance = 5, category = "criminal", perks = {"danger_pay", "prestige"}, illegal = true, promotesFrom = "gang_lieutenant" },
	{ id = "smuggler", title = "Smuggler", company = "Import/Export", emoji = "📦", salary = 95000, education = "None", minAge = 21, exp = 2, acceptance = 40, category = "criminal", perks = {"danger_pay", "travel"}, illegal = true },
	{ id = "fence", title = "Fence", company = "Underground Market", emoji = "💎", salary = 85000, education = "None", minAge = 20, exp = 1, acceptance = 55, category = "criminal", perks = {}, illegal = true },
}

-- Career ladders for promotions
local CareerLadders = {
	-- Tech ladder
	tech = {"junior_developer", "developer", "senior_developer", "tech_lead", "software_architect", "cto"},
	-- Medical ladder
	medical = {"hospital_orderly", "medical_assistant", "nurse_lpn", "nurse_rn", "nurse_practitioner"},
	medical_doctor = {"doctor_resident", "doctor", "surgeon", "chief_of_medicine"},
	-- Law ladder
	law = {"legal_assistant", "paralegal", "associate_lawyer", "lawyer", "senior_partner", "judge"},
	-- Finance ladder
	finance = {"bank_teller", "loan_officer", "financial_analyst", "investment_banker_jr", "investment_banker", "hedge_fund_manager", "cfo"},
	-- Creative ladder
	creative_design = {"graphic_designer_jr", "graphic_designer", "art_director"},
	creative_acting = {"actor_extra", "actor", "movie_star"},
	creative_music = {"musician_local", "musician_signed", "pop_star"},
	-- Government ladder
	government_police = {"police_officer", "detective", "police_chief"},
	government_fire = {"firefighter", "fire_captain"},
	government_political = {"city_council", "mayor", "senator", "president"},
	-- Education ladder
	education_k12 = {"teaching_assistant", "substitute_teacher", "teacher", "department_head", "principal", "superintendent"},
	education_higher = {"professor_assistant", "professor", "dean"},
	-- Trades ladder
	trades_electric = {"electrician_apprentice", "electrician"},
	trades_plumbing = {"plumber_apprentice", "plumber"},
	trades_construction = {"construction", "foreman"},
	-- Military ladder
	military_enlisted = {"enlisted", "sergeant"},
	military_officer = {"officer", "captain", "colonel", "general"},
	-- Sports ladder
	sports_player = {"minor_league", "professional_athlete", "star_athlete"},
	sports_coach = {"sports_coach", "head_coach"},
	-- Criminal ladder
	criminal_gang = {"gang_member", "gang_lieutenant", "crime_boss"},
	criminal_drugs = {"drug_dealer_street", "drug_dealer"},
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

-- EXPANDED FREELANCE GIGS (25+ options)
local FreelanceGigs = {
	-- Youth Gigs (Ages 10-14)
	{ id = "lemonade_stand", name = "Lemonade Stand", emoji = "🍋", minAge = 8, payMin = 5, payMax = 25, category = "youth" },
	{ id = "dog_walking", name = "Walk Dogs", emoji = "🐕", minAge = 10, payMin = 20, payMax = 50, category = "youth" },
	{ id = "mow_lawns", name = "Mow Lawns", emoji = "🌿", minAge = 10, payMin = 40, payMax = 100, category = "youth" },
	{ id = "wash_cars", name = "Wash Cars", emoji = "🚗", minAge = 10, payMin = 15, payMax = 40, category = "youth" },
	{ id = "rake_leaves", name = "Rake Leaves", emoji = "🍂", minAge = 10, payMin = 25, payMax = 60, category = "youth" },
	{ id = "shovel_snow", name = "Shovel Snow", emoji = "❄️", minAge = 10, payMin = 30, payMax = 80, category = "youth" },
	{ id = "babysit", name = "Babysit", emoji = "👶", minAge = 12, payMin = 50, payMax = 120, category = "youth" },
	{ id = "pet_sitting", name = "Pet Sitting", emoji = "🐾", minAge = 12, payMin = 40, payMax = 100, category = "youth" },
	
	-- Teen/Adult Gigs (Ages 14+)
	{ id = "tutor", name = "Tutor Students", emoji = "📚", minAge = 14, payMin = 30, payMax = 75, category = "service", reqSmarts = 60 },
	{ id = "food_delivery", name = "Deliver Food", emoji = "🍕", minAge = 16, payMin = 30, payMax = 80, category = "delivery" },
	{ id = "package_delivery", name = "Package Delivery", emoji = "📦", minAge = 18, payMin = 50, payMax = 150, category = "delivery" },
	{ id = "writing", name = "Freelance Writing", emoji = "✍️", minAge = 16, payMin = 100, payMax = 500, category = "creative", reqSmarts = 55 },
	{ id = "design", name = "Graphic Design", emoji = "🎨", minAge = 16, payMin = 150, payMax = 800, category = "creative" },
	{ id = "photography", name = "Photography Gig", emoji = "📸", minAge = 16, payMin = 100, payMax = 400, category = "creative" },
	{ id = "dj_gig", name = "DJ at Party", emoji = "🎧", minAge = 16, payMin = 150, payMax = 500, category = "entertainment" },
	{ id = "house_cleaning", name = "House Cleaning", emoji = "🧹", minAge = 16, payMin = 80, payMax = 200, category = "service" },
	{ id = "yard_work", name = "Landscaping Work", emoji = "🌳", minAge = 16, payMin = 100, payMax = 300, category = "labor" },
	{ id = "moving_help", name = "Help Moving", emoji = "📦", minAge = 18, payMin = 100, payMax = 300, category = "labor", reqHealth = 50 },
	{ id = "furniture_assembly", name = "Furniture Assembly", emoji = "🪑", minAge = 18, payMin = 80, payMax = 200, category = "labor" },
	
	-- Adult Gigs (Ages 18+)
	{ id = "rideshare", name = "Drive Rideshare", emoji = "🚙", minAge = 21, payMin = 50, payMax = 200, category = "delivery" },
	{ id = "bartending_event", name = "Event Bartending", emoji = "🍸", minAge = 21, payMin = 150, payMax = 400, category = "service" },
	{ id = "catering", name = "Catering Work", emoji = "🍽️", minAge = 18, payMin = 100, payMax = 300, category = "service" },
	{ id = "modeling", name = "Modeling Gig", emoji = "📷", minAge = 18, payMin = 200, payMax = 1500, category = "entertainment", reqLooks = 65 },
	{ id = "voice_over", name = "Voice Over Work", emoji = "🎙️", minAge = 18, payMin = 150, payMax = 800, category = "creative" },
	{ id = "fitness_coaching", name = "Fitness Coaching", emoji = "💪", minAge = 18, payMin = 75, payMax = 200, category = "service", reqHealth = 60 },
	{ id = "music_lessons", name = "Music Lessons", emoji = "🎹", minAge = 16, payMin = 50, payMax = 150, category = "creative" },
	{ id = "web_dev_freelance", name = "Web Development", emoji = "💻", minAge = 16, payMin = 200, payMax = 1500, category = "tech", reqSmarts = 60 },
	{ id = "consulting", name = "Business Consulting", emoji = "💼", minAge = 25, payMin = 500, payMax = 3000, category = "professional", reqSmarts = 70 },
	{ id = "handyman", name = "Handyman Services", emoji = "🔧", minAge = 18, payMin = 100, payMax = 400, category = "labor" },
	{ id = "personal_shopping", name = "Personal Shopping", emoji = "🛍️", minAge = 18, payMin = 50, payMax = 150, category = "service" },
	{ id = "house_sitting", name = "House Sitting", emoji = "🏠", minAge = 18, payMin = 100, payMax = 300, category = "service" },
	{ id = "translation", name = "Translation Work", emoji = "🌐", minAge = 18, payMin = 100, payMax = 500, category = "professional", reqSmarts = 65 },
	{ id = "market_research", name = "Market Research Survey", emoji = "📊", minAge = 18, payMin = 25, payMax = 100, category = "professional" },
}

-- Job Performance Tracking (per player)
local PlayerCareerData = {} -- [UserId] = { performance = 0-100, yearsAtJob = 0, promotionProgress = 0-100, ... }

local function getCareerData(player)
	if not PlayerCareerData[player.UserId] then
		PlayerCareerData[player.UserId] = {
			Performance = 75,           -- 0-100, affects raises and promotions
			YearsAtCurrentJob = 0,      -- Time at current position
			TotalExperience = 0,        -- Overall career experience
			PromotionProgress = 0,      -- 0-100, progress toward promotion
			Raises = 0,                 -- Number of raises received
			Warnings = 0,               -- Disciplinary warnings
			Skills = {                  -- Career skills
				Technical = 0,
				Creative = 0,
				Social = 0,
				Physical = 0,
				Analytical = 0,
				Leadership = 0,
			},
			CareerHistory = {},         -- Previous jobs
			Achievements = {},          -- Career milestones
		}
	end
	return PlayerCareerData[player.UserId]
end

-- Job events that can happen while working
local JobEvents = {
	-- Positive events
	{ id = "praised_by_boss", type = "positive", chance = 10, 
		message = "Your boss praised your excellent work!",
		effects = { performance = 5, happiness = 5, promotionProgress = 10 } },
	{ id = "successful_project", type = "positive", chance = 8,
		message = "You completed a major project successfully!",
		effects = { performance = 8, happiness = 8, promotionProgress = 15, money = 500 } },
	{ id = "coworker_help", type = "positive", chance = 12,
		message = "You helped a coworker and made a new friend.",
		effects = { social = 3, happiness = 3 } },
	{ id = "client_compliment", type = "positive", chance = 7,
		message = "A client sent a glowing review about you!",
		effects = { performance = 10, promotionProgress = 12 } },
	{ id = "innovation_bonus", type = "positive", chance = 5,
		message = "You suggested an innovation that saved the company money!",
		effects = { performance = 12, money = 1000, promotionProgress = 20, smarts = 2 } },
	{ id = "teamwork_award", type = "positive", chance = 6,
		message = "You received a teamwork award!",
		effects = { performance = 6, happiness = 10, social = 5 } },
	
	-- Negative events
	{ id = "late_to_work", type = "negative", chance = 8,
		message = "You were late to work and got a warning.",
		effects = { performance = -5, warnings = 1 } },
	{ id = "missed_deadline", type = "negative", chance = 6,
		message = "You missed an important deadline.",
		effects = { performance = -8, happiness = -3, promotionProgress = -10 } },
	{ id = "office_drama", type = "negative", chance = 10,
		message = "You got caught up in office drama.",
		effects = { happiness = -5, social = -2 } },
	{ id = "difficult_customer", type = "negative", chance = 12,
		message = "You dealt with a difficult customer who complained.",
		effects = { happiness = -3, performance = -3 } },
	{ id = "mistake_at_work", type = "negative", chance = 7,
		message = "You made a costly mistake at work.",
		effects = { performance = -10, happiness = -5, money = -200 } },
	{ id = "boss_criticism", type = "negative", chance = 8,
		message = "Your boss criticized your recent work.",
		effects = { performance = -6, happiness = -8, promotionProgress = -8 } },
	
	-- Neutral events
	{ id = "new_coworker", type = "neutral", chance = 8,
		message = "A new coworker joined your team.",
		effects = { social = 2 } },
	{ id = "company_meeting", type = "neutral", chance = 10,
		message = "You attended a company-wide meeting.",
		effects = {} },
	{ id = "training_session", type = "neutral", chance = 6,
		message = "You completed a training session.",
		effects = { smarts = 1, technical = 2 } },
	{ id = "work_anniversary", type = "neutral", chance = 3,
		message = "Happy work anniversary! You've been here another year.",
		effects = { happiness = 5, performance = 3 } },
	
	-- Category-specific events
	{ id = "tech_breakthrough", type = "positive", chance = 4, category = "tech",
		message = "You had a breakthrough solving a complex technical problem!",
		effects = { technical = 5, smarts = 3, performance = 10, promotionProgress = 15 } },
	{ id = "creative_recognition", type = "positive", chance = 5, category = "creative",
		message = "Your creative work was recognized by industry peers!",
		effects = { creative = 5, performance = 10, fame = 0.2 } },
	{ id = "patient_saved", type = "positive", chance = 4, category = "medical",
		message = "You helped save a patient's life!",
		effects = { performance = 15, happiness = 20, analytical = 3 } },
	{ id = "case_won", type = "positive", chance = 5, category = "law",
		message = "You won an important case!",
		effects = { performance = 12, money = 2000, analytical = 3, promotionProgress = 15 } },
	{ id = "big_deal", type = "positive", chance = 4, category = "finance",
		message = "You closed a major financial deal!",
		effects = { performance = 15, money = 5000, analytical = 2, promotionProgress = 20 } },
	{ id = "arrest_made", type = "positive", chance = 6, category = "government",
		message = "You made an important arrest!",
		effects = { performance = 10, physical = 2, promotionProgress = 12 } },
	{ id = "student_success", type = "positive", chance = 7, category = "education",
		message = "A student you mentored achieved great success!",
		effects = { happiness = 15, social = 3, performance = 8 } },
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
	local stats = lifeState and lifeState.Stats or {}
	local careerData = getCareerData(player)
	
	-- Update auto-education first (high school etc. based on age)
	updateAutoEducation(player)
	
	-- ════════════════════════════════════════════════════════════════
	-- CRIMINAL RECORD CHECKS (Ex-Convict System)
	-- ════════════════════════════════════════════════════════════════
	
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
	
	print("[LifeRemoteHandlers] Found job:", job.title, "Category:", job.category or "none")
	print("[LifeRemoteHandlers] Player age:", age, "Smarts:", stats.Smarts or 50, "Health:", stats.Health or 50, "Looks:", stats.Looks or 50)
	
	-- Already have a job?
	if extState.CurrentJob then
		return { success = false, message = "You already have a job! Quit first." }
	end
	
	-- In jail?
	if extState.InJail then
		return { success = false, message = "You can't work while in jail!" }
	end
	
	-- ════════════════════════════════════════════════════════════════
	-- ILLEGAL JOB HANDLING
	-- ════════════════════════════════════════════════════════════════
	if job.illegal then
		-- Criminal jobs have different requirements
		if job.category == "criminal" then
			-- Need criminal tendencies or connections
			local hasCriminalBackground = flags.criminal_tendencies or flags.gang_member or flags.petty_thief or flags.burglar
			
			-- Higher tier criminal jobs need to be promoted into
			if job.promotesFrom then
				local hasRequiredJob = false
				for _, historyJob in ipairs(careerData.CareerHistory or {}) do
					if historyJob.id == job.promotesFrom then
						hasRequiredJob = true
						break
					end
				end
				-- Also check current job
				if extState.CurrentJob and extState.CurrentJob.id == job.promotesFrom then
					hasRequiredJob = true
				end
				
				if not hasRequiredJob then
					return { success = false, message = "You need to work your way up in the criminal world first." }
				end
			end
			
			-- Set criminal flags when getting illegal job
			if lifeState then
				lifeState:SetFlag("criminal_tendencies")
				if job.id == "gang_member" or job.id == "gang_lieutenant" or job.id == "crime_boss" then
					lifeState:SetFlag("gang_member")
				end
			end
		end
	end
	
	-- ════════════════════════════════════════════════════════════════
	-- STANDARD REQUIREMENTS
	-- ════════════════════════════════════════════════════════════════
	
	-- Check age
	if age < job.minAge then
		return { success = false, message = "You must be at least " .. job.minAge .. " years old to apply for this job." }
	end
	
	-- Check education
	if not hasEducation(player, job.education) then
		return { success = false, message = "You need a " .. job.education .. " education for this job." }
	end
	
	-- Check experience
	local totalExp = (extState.Experience or 0) + (careerData.TotalExperience or 0)
	if totalExp < job.exp then
		return { success = false, message = "You need " .. job.exp .. " years of experience. You have " .. string.format("%.1f", totalExp) .. " years." }
	end
	
	-- ════════════════════════════════════════════════════════════════
	-- STAT REQUIREMENTS (NEW!)
	-- ════════════════════════════════════════════════════════════════
	
	local smarts = stats.Smarts or 50
	local health = stats.Health or 50
	local looks = stats.Looks or 50
	
	-- Check Smarts requirement
	if job.reqSmarts and smarts < job.reqSmarts then
		return { success = false, message = "This job requires higher intelligence. (Need " .. job.reqSmarts .. " Smarts, you have " .. math.floor(smarts) .. ")" }
	end
	
	-- Check Health requirement
	if job.reqHealth and health < job.reqHealth then
		return { success = false, message = "This job requires better physical fitness. (Need " .. job.reqHealth .. " Health, you have " .. math.floor(health) .. ")" }
	end
	
	-- Check Looks requirement
	if job.reqLooks and looks < job.reqLooks then
		return { success = false, message = "This job requires a certain appearance. (Need " .. job.reqLooks .. " Looks, you have " .. math.floor(looks) .. ")" }
	end
	
	-- ════════════════════════════════════════════════════════════════
	-- PROMOTION PATH CHECK
	-- ════════════════════════════════════════════════════════════════
	
	-- Check if this job requires promotion from another job
	if job.promotesFrom and not job.illegal then
		local hasRequiredExperience = false
		
		-- Check career history
		for _, historyJob in ipairs(careerData.CareerHistory or {}) do
			if historyJob.id == job.promotesFrom and (historyJob.yearsWorked or 0) >= 1 then
				hasRequiredExperience = true
				break
			end
		end
		
		-- Alternatively, if they have lots of general experience, allow it
		if careerData.TotalExperience >= job.exp * 1.5 then
			hasRequiredExperience = true
		end
		
		if not hasRequiredExperience then
			-- Find the previous job title
			local prevJobTitle = job.promotesFrom
			for _, j in ipairs(JobListings) do
				if j.id == job.promotesFrom then
					prevJobTitle = j.title
					break
				end
			end
			return { success = false, message = "This is a senior position. You should work as a " .. prevJobTitle .. " first." }
		end
	end
	
	-- ════════════════════════════════════════════════════════════════
	-- EX-CONVICT EMPLOYMENT PENALTIES
	-- ════════════════════════════════════════════════════════════════
	
	local acceptanceChance = job.acceptance
	local isExConvict = flags.ex_convict or flags.did_time or flags.released_from_prison
	local hasSecondChance = flags.second_chance
	local isReformed = flags.reformed
	
	-- Skip background check for illegal jobs
	if not job.illegal then
		-- Jobs that require background checks (professional jobs)
		local backgroundCheckJobs = {
			government = true, teacher = true, lawyer = true, doctor = true, nurse = true,
			accountant = true, banker = true, financial = true, security = true, police = true,
			daycare = true, school = true, hospital = true, pharmacy = true, fbi = true, cia = true
		}
		
		-- Also check by category
		local strictCategories = { government = true, medical = true, law = true, education = true, military = true }
		local requiresBackgroundCheck = strictCategories[job.category] or false
		
		-- Check job ID keywords
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
			
			if requiresBackgroundCheck and not hasSecondChance then
				return { 
					success = false, 
					message = "⛔ " .. job.company .. " ran a background check. Your criminal record disqualifies you for this position." 
				}
			end
			
			-- Reduce acceptance chance for ex-convicts
			if hasSecondChance or isReformed then
				acceptanceChance = math.floor(acceptanceChance * 0.7)
			else
				acceptanceChance = math.floor(acceptanceChance * 0.4)
			end
		end
	end
	
	-- ════════════════════════════════════════════════════════════════
	-- STAT-BASED ACCEPTANCE MODIFIERS
	-- ════════════════════════════════════════════════════════════════
	
	-- Smarts helps with intellectual jobs
	if job.category == "tech" or job.category == "science" or job.category == "finance" or job.category == "law" then
		if smarts >= 70 then acceptanceChance = acceptanceChance + 10
		elseif smarts >= 80 then acceptanceChance = acceptanceChance + 20
		elseif smarts <= 40 then acceptanceChance = acceptanceChance - 10
		end
	end
	
	-- Looks helps with customer-facing and creative jobs
	if job.category == "service" or job.category == "creative" or job.category == "entertainment" then
		if looks >= 70 then acceptanceChance = acceptanceChance + 8
		elseif looks >= 85 then acceptanceChance = acceptanceChance + 15
		end
	end
	
	-- Health helps with physical jobs
	if job.category == "trades" or job.category == "military" or job.category == "sports" or job.category == "government" then
		if health >= 70 then acceptanceChance = acceptanceChance + 8
		elseif health >= 85 then acceptanceChance = acceptanceChance + 15
		elseif health <= 40 then acceptanceChance = acceptanceChance - 10
		end
	end
	
	-- Career skills boost
	if careerData.Skills then
		local categorySkillMap = {
			tech = "Technical", science = "Technical", trades = "Technical",
			creative = "Creative", entertainment = "Creative",
			service = "Social", office = "Social",
			sports = "Physical", military = "Physical",
			finance = "Analytical", law = "Analytical", medical = "Analytical",
		}
		local relevantSkill = categorySkillMap[job.category]
		if relevantSkill and careerData.Skills[relevantSkill] then
			local skillBonus = math.floor(careerData.Skills[relevantSkill] / 10)
			acceptanceChance = acceptanceChance + skillBonus
		end
	end
	
	acceptanceChance = math.clamp(acceptanceChance, 5, 95)
	
	-- ════════════════════════════════════════════════════════════════
	-- ROLL FOR ACCEPTANCE
	-- ════════════════════════════════════════════════════════════════
	
	local roll = math.random(100)
	print("[LifeRemoteHandlers] Acceptance roll:", roll, "vs", acceptanceChance)
	
	if roll > acceptanceChance then
		local message = "Unfortunately, " .. job.company .. " decided not to hire you."
		if isExConvict then
			message = "📋 " .. job.company .. " reviewed your application but passed. Your criminal record may have been a factor."
		elseif job.reqSmarts and smarts < job.reqSmarts + 10 then
			message = job.company .. " felt you weren't quite qualified for this position."
		elseif job.reqLooks and looks < job.reqLooks + 10 then
			message = job.company .. " decided to go with another candidate."
		end
		return { success = false, message = message }
	end
	
	-- ════════════════════════════════════════════════════════════════
	-- HIRED! SET UP JOB
	-- ════════════════════════════════════════════════════════════════
	
	extState.CurrentJob = {
		id = job.id,
		title = job.title,
		company = job.company,
		salary = job.salary,
		category = job.category,
		perks = job.perks or {},
		illegal = job.illegal or false,
		startAge = age,
		promotesTo = nil, -- Will be set if there's a promotion path
	}
	
	-- Find promotion path
	if job.category then
		for ladderName, ladder in pairs(CareerLadders) do
			for i, jobId in ipairs(ladder) do
				if jobId == job.id and i < #ladder then
					extState.CurrentJob.promotesTo = ladder[i + 1]
					break
				end
			end
		end
	end
	
	-- Reset career progress for new job
	careerData.YearsAtCurrentJob = 0
	careerData.PromotionProgress = 0
	careerData.Warnings = 0
	careerData.Raises = 0
	
	-- Set job-specific flags
	if lifeState then
		-- CRITICAL: Set 'employed' flag for event system
		lifeState:SetFlag("employed")
		print("[LifeRemoteHandlers] Set 'employed' flag via ApplyForJob")
		
		if job.category == "military" then lifeState:SetFlag("military_service") end
		if job.category == "government" and job.id == "police_officer" then lifeState:SetFlag("police_officer") end
		if job.category == "medical" and string.find(job.id, "doctor") then lifeState:SetFlag("medical_professional") end
		if job.category == "law" and string.find(job.id, "lawyer") then lifeState:SetFlag("legal_professional") end
		if job.id == "teacher" then lifeState:SetFlag("teacher") end
		
		-- Ex-convict second chance
		if isExConvict and not job.illegal then
			lifeState:SetFlag("second_chance")
		end
	end
	
	syncStateToClient(player)
	
	-- Build success message
	local message = "🎉 Congratulations! You got hired as a " .. job.title .. " at " .. job.company .. "!"
	
	-- Add salary info
	message = message .. " Salary: $" .. string.format("%d", job.salary) .. "/year"
	
	-- Add perks info
	if job.perks and #job.perks > 0 then
		local perkNames = {}
		for _, perkId in ipairs(job.perks) do
			local perk = CareerPerks[perkId]
			if perk then
				table.insert(perkNames, perk.desc)
			end
		end
		if #perkNames > 0 then
			message = message .. " | Perks: " .. table.concat(perkNames, ", ")
		end
	end
	
	if isExConvict and not job.illegal then
		message = "🌟 Despite your criminal record, " .. job.company .. " decided to give you a chance! " .. message
	end
	
	return { 
		success = true, 
		message = message,
		salary = job.salary,
		category = job.category,
		perks = job.perks
	}
end

QuitJob.OnServerInvoke = function(player)
	local extState = getExtendedState(player)
	local careerData = getCareerData(player)
	local lifeState = getLifeManagerState(player)
	
	if extState.CurrentJob then
		local job = extState.CurrentJob
		local jobTitle = job.title or "your job"
		
		-- Save to career history
		table.insert(careerData.CareerHistory, {
			id = job.id,
			title = job.title,
			company = job.company,
			salary = job.salary,
			category = job.category,
			yearsWorked = careerData.YearsAtCurrentJob or 0,
			reason = "quit",
		})
		
		-- Reset job-related data
		extState.CurrentJob = nil
		careerData.YearsAtCurrentJob = 0
		careerData.PromotionProgress = 0
		careerData.Warnings = 0
		careerData.Raises = 0
		
		-- CRITICAL: Clear 'employed' flag when quitting job
		if lifeState then
			lifeState:ClearFlag("employed")
			print("[LifeRemoteHandlers] Cleared 'employed' flag via QuitJob")
		end
		
		syncStateToClient(player)
		return { success = true, message = "You quit " .. jobTitle .. ". You're now unemployed." }
	else
		return { success = false, message = "You don't have a job to quit!" }
	end
end

DoWork.OnServerInvoke = function(player)
	local extState = getExtendedState(player)
	local lifeState = getLifeManagerState(player)
	local careerData = getCareerData(player)
	
	if not extState.CurrentJob then
		return { success = false, message = "You don't have a job!" }
	end
	
	if extState.InJail then
		return { success = false, message = "You can't work while in jail!" }
	end
	
	local job = extState.CurrentJob
	local stats = lifeState and lifeState.Stats or {}
	local flags = lifeState and lifeState.Flags or {}
	
	-- ════════════════════════════════════════════════════════════════
	-- CALCULATE EARNINGS (Performance-based)
	-- ════════════════════════════════════════════════════════════════
	
	local baseDailyPay = math.floor(job.salary / 365)
	local performanceMultiplier = 1.0
	
	-- Performance affects pay
	local performance = careerData.Performance or 75
	if performance >= 90 then performanceMultiplier = 1.2
	elseif performance >= 80 then performanceMultiplier = 1.1
	elseif performance >= 70 then performanceMultiplier = 1.05
	elseif performance <= 40 then performanceMultiplier = 0.85
	elseif performance <= 50 then performanceMultiplier = 0.95
	end
	
	-- Apply perks bonuses
	local perkBonus = 0
	if job.perks then
		for _, perkId in ipairs(job.perks) do
			local perk = CareerPerks[perkId]
			if perk and perk.money_bonus then
				perkBonus = perkBonus + perk.money_bonus
			end
		end
	end
	
	-- Raises accumulated
	local raiseBonus = (careerData.Raises or 0) * 0.03 -- 3% per raise
	
	local totalMultiplier = performanceMultiplier + perkBonus + raiseBonus
	local dailyPay = math.floor(baseDailyPay * totalMultiplier)
	
	addMoney(player, dailyPay)
	
	-- ════════════════════════════════════════════════════════════════
	-- GAIN EXPERIENCE & SKILLS
	-- ════════════════════════════════════════════════════════════════
	
	-- Gain experience
	local expGain = 0.02 + (performance / 5000) -- 0.02-0.04 per work day
	extState.Experience = (extState.Experience or 0) + expGain
	careerData.TotalExperience = (careerData.TotalExperience or 0) + expGain
	
	-- Gain career skills based on job category
	local categorySkillMap = {
		tech = "Technical", science = "Technical", trades = "Technical",
		creative = "Creative", entertainment = "Creative",
		service = "Social", office = "Social",
		sports = "Physical", military = "Physical",
		finance = "Analytical", law = "Analytical", medical = "Analytical",
	}
	local relevantSkill = categorySkillMap[job.category]
	if relevantSkill and careerData.Skills then
		local skillGain = 0.1 + (math.random() * 0.1) -- 0.1-0.2 per work
		careerData.Skills[relevantSkill] = math.min(100, (careerData.Skills[relevantSkill] or 0) + skillGain)
	end
	
	-- Leadership gain for management positions
	if job.title and (string.find(job.title:lower(), "manager") or string.find(job.title:lower(), "director") or 
		string.find(job.title:lower(), "chief") or string.find(job.title:lower(), "lead") or 
		string.find(job.title:lower(), "head") or string.find(job.title:lower(), "boss")) then
		careerData.Skills.Leadership = math.min(100, (careerData.Skills.Leadership or 0) + 0.15)
	end
	
	-- ════════════════════════════════════════════════════════════════
	-- APPLY PERKS (Stat bonuses)
	-- ════════════════════════════════════════════════════════════════
	
	if job.perks and lifeState then
		for _, perkId in ipairs(job.perks) do
			local perk = CareerPerks[perkId]
			if perk and perk.stat then
				-- Small chance (10%) to apply stat bonus each work day
				if math.random(100) <= 10 then
					local currentStat = lifeState.Stats[perk.stat] or 50
					lifeState.Stats[perk.stat] = math.min(100, currentStat + math.random(1, perk.bonus))
				end
			end
		end
	end
	
	-- ════════════════════════════════════════════════════════════════
	-- PROMOTION PROGRESS
	-- ════════════════════════════════════════════════════════════════
	
	local promotionGain = 1 + (performance - 50) / 50 -- 0.5-2.0 based on performance
	careerData.PromotionProgress = math.min(100, (careerData.PromotionProgress or 0) + promotionGain)
	
	-- ════════════════════════════════════════════════════════════════
	-- JOB EVENTS (Random workplace scenarios)
	-- ════════════════════════════════════════════════════════════════
	
	local eventMessage = nil
	local eventTriggered = nil
	
	-- 15% chance of a job event each work day
	if math.random(100) <= 15 then
		-- Build list of applicable events
		local applicableEvents = {}
		for _, event in ipairs(JobEvents) do
			if not event.category or event.category == job.category then
				table.insert(applicableEvents, event)
			end
		end
		
		-- Roll for each event
		for _, event in ipairs(applicableEvents) do
			if math.random(100) <= event.chance then
				eventTriggered = event
				break
			end
		end
		
		-- Apply event effects
		if eventTriggered then
			eventMessage = eventTriggered.message
			local effects = eventTriggered.effects or {}
			
			-- Apply effects
			if effects.performance then
				careerData.Performance = math.clamp((careerData.Performance or 75) + effects.performance, 0, 100)
			end
			if effects.promotionProgress then
				careerData.PromotionProgress = math.clamp((careerData.PromotionProgress or 0) + effects.promotionProgress, 0, 100)
			end
			if effects.warnings then
				careerData.Warnings = (careerData.Warnings or 0) + effects.warnings
			end
			if effects.happiness and lifeState then
				lifeState.Stats.Happiness = math.clamp((lifeState.Stats.Happiness or 50) + effects.happiness, 0, 100)
			end
			if effects.smarts and lifeState then
				lifeState.Stats.Smarts = math.clamp((lifeState.Stats.Smarts or 50) + effects.smarts, 0, 100)
			end
			if effects.money then
				addMoney(player, effects.money)
			end
			
			-- Career skill effects
			if careerData.Skills then
				if effects.technical then careerData.Skills.Technical = math.min(100, (careerData.Skills.Technical or 0) + effects.technical) end
				if effects.creative then careerData.Skills.Creative = math.min(100, (careerData.Skills.Creative or 0) + effects.creative) end
				if effects.social then careerData.Skills.Social = math.min(100, (careerData.Skills.Social or 0) + effects.social) end
				if effects.physical then careerData.Skills.Physical = math.min(100, (careerData.Skills.Physical or 0) + effects.physical) end
				if effects.analytical then careerData.Skills.Analytical = math.min(100, (careerData.Skills.Analytical or 0) + effects.analytical) end
			end
			
			print("[LifeRemoteHandlers] Job event triggered:", eventTriggered.id, "-", eventTriggered.message)
		end
	end
	
	-- ════════════════════════════════════════════════════════════════
	-- TOO MANY WARNINGS = FIRED
	-- ════════════════════════════════════════════════════════════════
	
	if (careerData.Warnings or 0) >= 3 then
		-- Save to career history
		table.insert(careerData.CareerHistory, {
			id = job.id,
			title = job.title,
			company = job.company,
			yearsWorked = careerData.YearsAtCurrentJob or 0,
			reason = "fired",
		})
		
		extState.CurrentJob = nil
		careerData.Warnings = 0
		careerData.YearsAtCurrentJob = 0
		careerData.PromotionProgress = 0
		
		-- CRITICAL: Clear 'employed' flag when getting fired
		if lifeState then
			lifeState:ClearFlag("employed")
			print("[LifeRemoteHandlers] Cleared 'employed' flag - got fired")
		end
		
		syncStateToClient(player)
		
		return {
			success = false,
			message = "😱 You've been FIRED from " .. job.company .. " due to too many warnings!",
			fired = true
		}
	end
	
	-- ════════════════════════════════════════════════════════════════
	-- BUILD RESULT MESSAGE
	-- ════════════════════════════════════════════════════════════════
	
	syncStateToClient(player)
	
	local message = "You worked hard at " .. job.company .. "!"
	
	-- Add event message if one occurred
	if eventMessage then
		message = message .. "\n\n📢 " .. eventMessage
	end
	
	-- Show promotion progress if close
	if job.promotesTo and (careerData.PromotionProgress or 0) >= 75 then
		message = message .. "\n\n📈 Promotion progress: " .. math.floor(careerData.PromotionProgress) .. "%"
	end
	
	return { 
		success = true, 
		message = message,
		earned = dailyPay,
		performance = careerData.Performance,
		promotionProgress = careerData.PromotionProgress,
		event = eventTriggered and eventTriggered.id or nil,
		eventMessage = eventMessage
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
	local lifeState = getLifeManagerState(player)
	local stats = lifeState and lifeState.Stats or {}
	local careerData = getCareerData(player)
	
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
	
	-- Check stat requirements
	local smarts = stats.Smarts or 50
	local health = stats.Health or 50
	local looks = stats.Looks or 50
	
	if gig.reqSmarts and smarts < gig.reqSmarts then
		return { success = false, message = "You need at least " .. gig.reqSmarts .. " Smarts for this gig." }
	end
	if gig.reqHealth and health < gig.reqHealth then
		return { success = false, message = "You need at least " .. gig.reqHealth .. " Health for this gig." }
	end
	if gig.reqLooks and looks < gig.reqLooks then
		return { success = false, message = "You need at least " .. gig.reqLooks .. " Looks for this gig." }
	end
	
	-- Calculate earnings with stat bonuses
	local baseEarnings = math.random(gig.payMin, gig.payMax)
	local bonusMultiplier = 1.0
	
	-- Category-specific bonuses
	if gig.category == "creative" and smarts >= 60 then
		bonusMultiplier = bonusMultiplier + 0.1
	end
	if gig.category == "labor" and health >= 70 then
		bonusMultiplier = bonusMultiplier + 0.15
	end
	if gig.category == "service" and looks >= 65 then
		bonusMultiplier = bonusMultiplier + 0.1
	end
	if gig.category == "tech" and smarts >= 70 then
		bonusMultiplier = bonusMultiplier + 0.2
	end
	if gig.category == "professional" and smarts >= 75 then
		bonusMultiplier = bonusMultiplier + 0.25
	end
	
	-- Career skills bonus
	if careerData.Skills then
		local categorySkillMap = {
			creative = "Creative", tech = "Technical", labor = "Physical",
			service = "Social", professional = "Analytical", entertainment = "Creative"
		}
		local relevantSkill = categorySkillMap[gig.category]
		if relevantSkill and careerData.Skills[relevantSkill] then
			bonusMultiplier = bonusMultiplier + (careerData.Skills[relevantSkill] / 200) -- Up to 50% bonus
		end
	end
	
	local earnings = math.floor(baseEarnings * bonusMultiplier)
	addMoney(player, earnings)
	
	-- Small chance to gain relevant skill
	if careerData.Skills and math.random(100) <= 30 then
		local categorySkillMap = {
			creative = "Creative", tech = "Technical", labor = "Physical",
			service = "Social", professional = "Analytical", entertainment = "Creative"
		}
		local relevantSkill = categorySkillMap[gig.category]
		if relevantSkill then
			careerData.Skills[relevantSkill] = math.min(100, (careerData.Skills[relevantSkill] or 0) + 0.5)
		end
	end
	
	local emoji = gig.emoji or "💰"
	local message = emoji .. " You completed " .. gig.name .. " and earned $" .. earnings .. "!"
	if bonusMultiplier > 1.1 then
		message = message .. " (Bonus: +" .. math.floor((bonusMultiplier - 1) * 100) .. "%)"
	end
	
	return { 
		success = true, 
		message = message,
		earned = earnings,
		bonus = bonusMultiplier > 1 and (bonusMultiplier - 1) or nil
	}
end

TrySpecialCareer.OnServerInvoke = function(player, careerId)
	local extState = getExtendedState(player)
	local lifeState = getLifeManagerState(player)
	local stats = lifeState and lifeState.Stats or {}
	local careerData = getCareerData(player)
	
	if extState.InJail then
		return { success = false, message = "You can't pursue a career while in jail!" }
	end
	
	-- Base 30% success chance, modified by relevant stats and skills
	local successChance = 30
	
	-- Smarts helps with all special careers
	local smarts = stats.Smarts or 50
	successChance = successChance + math.floor((smarts - 50) / 5)
	
	-- Leadership helps
	if careerData.Skills and careerData.Skills.Leadership then
		successChance = successChance + math.floor(careerData.Skills.Leadership / 10)
	end
	
	successChance = math.clamp(successChance, 5, 70)
	local success = math.random(100) <= successChance
	
	if success then
		return { 
			success = true, 
			message = "🌟 You made it! Your special career has begun!"
		}
	else
		return { 
			success = false, 
			message = "It didn't work out this time. Keep trying!"
		}
	end
end

-- ════════════════════════════════════════════════════════════════
-- PROMOTION & RAISE HANDLERS (NEW!)
-- ════════════════════════════════════════════════════════════════

RequestPromotion.OnServerInvoke = function(player)
	local extState = getExtendedState(player)
	local careerData = getCareerData(player)
	local lifeState = getLifeManagerState(player)
	
	if not extState.CurrentJob then
		return { success = false, message = "You don't have a job!" }
	end
	
	local job = extState.CurrentJob
	
	-- Check if there's a promotion available
	if not job.promotesTo then
		return { success = false, message = "There's no promotion available for your current position." }
	end
	
	-- Find the promotion job
	local promotionJob = nil
	for _, j in ipairs(JobListings) do
		if j.id == job.promotesTo then
			promotionJob = j
			break
		end
	end
	
	if not promotionJob then
		return { success = false, message = "Promotion path not found." }
	end
	
	-- Check promotion progress
	local progress = careerData.PromotionProgress or 0
	if progress < 80 then
		return { success = false, message = "You need more experience before requesting a promotion. Progress: " .. math.floor(progress) .. "/80%" }
	end
	
	-- Check stats/requirements
	local stats = lifeState and lifeState.Stats or {}
	local smarts = stats.Smarts or 50
	local health = stats.Health or 50
	local looks = stats.Looks or 50
	
	if promotionJob.reqSmarts and smarts < promotionJob.reqSmarts then
		return { success = false, message = "The promotion requires " .. promotionJob.reqSmarts .. " Smarts. You have " .. math.floor(smarts) .. "." }
	end
	if promotionJob.reqHealth and health < promotionJob.reqHealth then
		return { success = false, message = "The promotion requires " .. promotionJob.reqHealth .. " Health. You have " .. math.floor(health) .. "." }
	end
	
	-- Check education
	if promotionJob.education and not hasEducation(player, promotionJob.education) then
		return { success = false, message = "The promotion requires " .. promotionJob.education .. " education." }
	end
	
	-- Calculate promotion chance
	local promotionChance = 50
	promotionChance = promotionChance + (careerData.Performance or 75) - 75 -- Performance bonus/penalty
	promotionChance = promotionChance + math.floor((progress - 80) / 4) -- Extra progress bonus
	
	-- Leadership bonus
	if careerData.Skills and careerData.Skills.Leadership then
		promotionChance = promotionChance + math.floor(careerData.Skills.Leadership / 10)
	end
	
	promotionChance = math.clamp(promotionChance, 20, 90)
	local success = math.random(100) <= promotionChance
	
	if success then
		-- Save current job to history
		table.insert(careerData.CareerHistory, {
			id = job.id,
			title = job.title,
			company = job.company,
			salary = job.salary,
			yearsWorked = careerData.YearsAtCurrentJob or 0,
			reason = "promoted",
		})
		
		-- Apply promotion
		extState.CurrentJob = {
			id = promotionJob.id,
			title = promotionJob.title,
			company = promotionJob.company or job.company, -- Keep same company if not specified
			salary = promotionJob.salary,
			category = promotionJob.category,
			perks = promotionJob.perks or {},
			illegal = promotionJob.illegal or false,
			startAge = getAge(player),
			promotesTo = nil, -- Will be found
		}
		
		-- Find next promotion
		for ladderName, ladder in pairs(CareerLadders) do
			for i, jobId in ipairs(ladder) do
				if jobId == promotionJob.id and i < #ladder then
					extState.CurrentJob.promotesTo = ladder[i + 1]
					break
				end
			end
		end
		
		-- Reset progress
		careerData.PromotionProgress = 0
		careerData.YearsAtCurrentJob = 0
		careerData.Raises = 0
		
		-- Gain leadership skill
		if careerData.Skills then
			careerData.Skills.Leadership = math.min(100, (careerData.Skills.Leadership or 0) + 5)
		end
		
		syncStateToClient(player)
		
		local salaryIncrease = promotionJob.salary - job.salary
		return { 
			success = true, 
			message = "🎉 PROMOTION! You've been promoted to " .. promotionJob.title .. "! Salary: $" .. promotionJob.salary .. "/year (+" .. salaryIncrease .. ")",
			newTitle = promotionJob.title,
			newSalary = promotionJob.salary
		}
	else
		-- Failed promotion attempt
		careerData.PromotionProgress = math.max(0, (careerData.PromotionProgress or 0) - 20)
		return { success = false, message = "Your promotion request was denied. Keep working hard and try again later." }
	end
end

RequestRaise.OnServerInvoke = function(player)
	local extState = getExtendedState(player)
	local careerData = getCareerData(player)
	
	if not extState.CurrentJob then
		return { success = false, message = "You don't have a job!" }
	end
	
	local job = extState.CurrentJob
	
	-- Can only request raise every so often
	local raises = careerData.Raises or 0
	if raises >= 5 then
		return { success = false, message = "You've received the maximum number of raises for this position." }
	end
	
	-- Need good performance
	local performance = careerData.Performance or 75
	if performance < 60 then
		return { success = false, message = "Your performance needs to improve before you can request a raise. (Performance: " .. math.floor(performance) .. "%)" }
	end
	
	-- Calculate success chance
	local successChance = 30
	successChance = successChance + (performance - 60) -- Performance bonus
	successChance = successChance - (raises * 10) -- Each previous raise makes it harder
	
	if careerData.Skills and careerData.Skills.Social then
		successChance = successChance + math.floor(careerData.Skills.Social / 10)
	end
	
	successChance = math.clamp(successChance, 10, 80)
	local success = math.random(100) <= successChance
	
	if success then
		careerData.Raises = raises + 1
		local raisePercent = 3 + math.random(0, 2) -- 3-5% raise
		local oldSalary = job.salary
		local newSalary = math.floor(job.salary * (1 + raisePercent / 100))
		job.salary = newSalary
		
		syncStateToClient(player)
		
		return { 
			success = true, 
			message = "💰 You got a raise! New salary: $" .. newSalary .. "/year (+" .. raisePercent .. "%)",
			newSalary = newSalary,
			raisePercent = raisePercent
		}
	else
		-- Failed raise request
		careerData.Performance = math.max(0, (careerData.Performance or 75) - 5) -- Slight performance hit from rejected request
		return { success = false, message = "Your raise request was denied. Focus on your performance and try again later." }
	end
end

GetCareerInfo.OnServerInvoke = function(player)
	local extState = getExtendedState(player)
	local careerData = getCareerData(player)
	
	return {
		success = true,
		currentJob = extState.CurrentJob,
		performance = careerData.Performance or 75,
		promotionProgress = careerData.PromotionProgress or 0,
		yearsAtJob = careerData.YearsAtCurrentJob or 0,
		totalExperience = careerData.TotalExperience or 0,
		raises = careerData.Raises or 0,
		warnings = careerData.Warnings or 0,
		skills = careerData.Skills or {},
		careerHistory = careerData.CareerHistory or {},
		achievements = careerData.Achievements or {},
	}
end

----------------------------------------------------------------
-- ASSETS HANDLERS
----------------------------------------------------------------

BuyProperty.OnServerInvoke = function(player, propertyId)
	print("[LifeRemoteHandlers] BuyProperty called for:", propertyId)
	local state = getPlayerState(player)
	local extState = getExtendedState(player)
	local age = state.Age
	
	local prop = nil
	for _, p in ipairs(Properties) do
		if p.id == propertyId then
			prop = p
			break
		end
	end
	
	if not prop then
		print("[LifeRemoteHandlers] Property not found:", propertyId)
		return { success = false, message = "Property not found." }
	end
	
	if age < prop.minAge then
		return { success = false, message = "You must be at least " .. prop.minAge .. " to buy property." }
	end
	
	if not canAfford(player, prop.price) then
		return { success = false, message = "You can't afford this! Price: $" .. prop.price }
	end
	
	deductMoney(player, prop.price)
	extState.OwnedProperties = extState.OwnedProperties or {}
	table.insert(extState.OwnedProperties, { id = prop.id, name = prop.name, value = prop.price })
	print("[LifeRemoteHandlers] Bought property:", prop.name, "Total owned:", #extState.OwnedProperties)
	syncStateToClient(player)
	
	return { 
		success = true, 
		message = "Congratulations! You bought " .. prop.name .. "!"
	}
end

BuyVehicle.OnServerInvoke = function(player, vehicleId)
	print("[LifeRemoteHandlers] BuyVehicle called for:", vehicleId)
	local state = getPlayerState(player)
	local extState = getExtendedState(player)
	local age = state.Age
	
	local vehicle = nil
	for _, v in ipairs(Vehicles) do
		if v.id == vehicleId then
			vehicle = v
			break
		end
	end
	
	if not vehicle then
		print("[LifeRemoteHandlers] Vehicle not found:", vehicleId)
		return { success = false, message = "Vehicle not found." }
	end
	
	if age < vehicle.minAge then
		return { success = false, message = "You must be at least " .. vehicle.minAge .. " to buy this vehicle." }
	end
	
	if not canAfford(player, vehicle.price) then
		return { success = false, message = "You can't afford this! Price: $" .. vehicle.price }
	end
	
	deductMoney(player, vehicle.price)
	extState.OwnedVehicles = extState.OwnedVehicles or {}
	table.insert(extState.OwnedVehicles, { id = vehicle.id, name = vehicle.name, value = vehicle.price })
	print("[LifeRemoteHandlers] Bought vehicle:", vehicle.name, "Total owned:", #extState.OwnedVehicles)
	syncStateToClient(player)
	
	return { 
		success = true, 
		message = "Congratulations! You bought a " .. vehicle.name .. "!"
	}
end

BuyItem.OnServerInvoke = function(player, itemId)
	print("[LifeRemoteHandlers] BuyItem called for:", itemId)
	local state = getPlayerState(player)
	local extState = getExtendedState(player)
	local age = state.Age
	
	local item = nil
	for _, i in ipairs(ShopItems) do
		if i.id == itemId then
			item = i
			break
		end
	end
	
	if not item then
		print("[LifeRemoteHandlers] Item not found:", itemId)
		return { success = false, message = "Item not found." }
	end
	
	if age < item.minAge then
		return { success = false, message = "You must be at least " .. item.minAge .. " to buy this." }
	end
	
	if not canAfford(player, item.price) then
		return { success = false, message = "You can't afford this! Price: $" .. item.price }
	end
	
	deductMoney(player, item.price)
	extState.OwnedItems = extState.OwnedItems or {}
	table.insert(extState.OwnedItems, { id = item.id, name = item.name, value = item.price })
	print("[LifeRemoteHandlers] Bought item:", item.name, "Total owned:", #extState.OwnedItems)
	syncStateToClient(player)
	
	return { 
		success = true, 
		message = "You bought a " .. item.name .. "!"
	}
end

BuyCrypto.OnServerInvoke = function(player, cryptoId, amount)
	local state = getPlayerState(player)
	local extState = getExtendedState(player)
	
	if state.Age < 18 then
		return { success = false, message = "You must be 18+ to trade crypto." }
	end
	
	-- Simplified crypto system
	local cost = amount or 100
	
	if not canAfford(player, cost) then
		return { success = false, message = "You can't afford this investment!" }
	end
	
	deductMoney(player, cost)
	table.insert(extState.OwnedCrypto, { id = cryptoId, invested = cost })
	syncStateToClient(player)
	
	return { success = true, message = "Crypto purchased!" }
end

----------------------------------------------------------------
-- SELL ASSET HANDLER
----------------------------------------------------------------

SellAsset.OnServerInvoke = function(player, assetId, assetType)
	print("[LifeRemoteHandlers] SellAsset called - Asset:", assetId, "Type:", assetType)
	
	local extState = getExtendedState(player)
	
	-- Find and remove the asset, return the value
	local assetList = nil
	local saleValue = 0
	local assetName = "Asset"
	
	if assetType == "property" then
		assetList = extState.OwnedProperties
	elseif assetType == "vehicle" then
		assetList = extState.OwnedVehicles
	elseif assetType == "item" then
		assetList = extState.OwnedItems
	elseif assetType == "crypto" then
		assetList = extState.OwnedCrypto
	end
	
	if not assetList then
		print("[LifeRemoteHandlers] Invalid asset type:", assetType)
		return { success = false, message = "Invalid asset type." }
	end
	
	-- Find the asset
	local foundIndex = nil
	for i, asset in ipairs(assetList) do
		if asset.id == assetId then
			foundIndex = i
			saleValue = asset.value or asset.invested or 0
			assetName = asset.name or assetId
			break
		end
	end
	
	if not foundIndex then
		print("[LifeRemoteHandlers] Asset not found:", assetId)
		return { success = false, message = "You don't own this asset." }
	end
	
	-- Sell for 70-90% of value
	local sellPercent = math.random(70, 90) / 100
	local sellPrice = math.floor(saleValue * sellPercent)
	
	-- Remove asset and add money
	table.remove(assetList, foundIndex)
	addMoney(player, sellPrice)
	
	print("[LifeRemoteHandlers] Sold", assetName, "for $", sellPrice)
	
	return { 
		success = true, 
		message = "Sold " .. assetName .. " for $" .. sellPrice .. "!",
		amount = sellPrice
	}
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

DoInteraction.OnServerInvoke = function(player, arg1, arg2, arg3)
	-- Support both signatures:
	-- 1. New: payload table with { actionId, relationshipType, targetId, cost }
	-- 2. Old: (actionId, relationType, personId) as separate args
	local actionId, relationType, personId
	if type(arg1) == "table" then
		-- New payload format from updated RelationshipsScreen
		actionId = arg1.actionId
		relationType = arg1.relationshipType
		personId = arg1.targetId
	else
		-- Old format with separate arguments
		actionId = arg1
		relationType = arg2
		personId = arg3
	end
	
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
		-- Use RelationshipService to create a new romantic interest
		if lifeState then
			local partnerAge = math.max(18, age + math.random(-5, 5))
			local partner = RelationshipService.create(lifeState, "romance", {
				role = "Dating",
				age = partnerAge,
				relationship = 50 + math.random(0, 20),
				tags = { dating = true, met_via_ui = true },
			})
			
			print("[LifeRemoteHandlers] ✅ Created new partner via RelationshipService:", partner.id, "Name:", partner.name)
			
			syncStateToClient(player)
			return { 
				success = true, 
				message = "You met " .. partner.name .. " (" .. partnerAge .. ") and hit it off! You're now dating."
			}
		else
			print("[LifeRemoteHandlers] ❌ ERROR: No lifeState to add partner to!")
			return { success = false, message = "Error: Could not create relationship" }
		end
		
	elseif action.special == "make_friend" then
		-- Use RelationshipService to create a new friend
		if lifeState then
			local friendAge = math.max(5, age + math.random(-3, 3))
			local friend = RelationshipService.create(lifeState, "friend", {
				role = "Friend",
				age = friendAge,
				relationship = 50 + math.random(0, 30),
				tags = { met_via_ui = true },
			})
			
			print("[LifeRemoteHandlers] ✅ Created new friend via RelationshipService:", friend.id, "Name:", friend.name)
			
			syncStateToClient(player)
			return { 
				success = true, 
				message = "You made a new friend! " .. friend.name .. " seems cool."
			}
		else
			print("[LifeRemoteHandlers] ❌ ERROR: No lifeState to add friend to!")
			return { success = false, message = "Error: Could not create relationship" }
		end
		
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
	
	-- UPDATE THE PERSON'S RELATIONSHIP VALUE if interacting with a specific person
	local personName = nil
	if personId and lifeState and lifeState.Relationships then
		local person = lifeState.Relationships[personId]
		if person then
			personName = person.name
			-- Modify the relationship value
			local currentRel = person.relationship or 50
			person.relationship = math.clamp(currentRel + statChange, 0, 100)
			print("[LifeRemoteHandlers] Updated relationship with", personName, "by", statChange, "to", person.relationship)
		end
	end
	
	syncStateToClient(player)
	
	-- Generate result message (include person name if available)
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
		betray = isSuccess and "Betrayal complete. How does it feel?" or "They saw it coming.",
		ghost = "You've ghosted them. They'll get the message eventually.",
	}
	
	local message = messages[actionId] or (isSuccess and "It went well!" or "It didn't go as planned...")
	
	-- Add relationship change info to message
	if personName and statChange ~= 0 then
		local changeText = statChange > 0 and (" (+" .. statChange .. " relationship)") or (" (" .. statChange .. " relationship)")
		message = message .. changeText
	end
	
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
	local life = _G.GetPlayerLife and _G.GetPlayerLife(player) or nil
	
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
	
	-- ═══════════════════════════════════════════════════════════
	-- ADVANCED SKILL-BASED MODIFIERS (Triple AAA Polish)
	-- ═══════════════════════════════════════════════════════════
	
	-- Get player stats and flags for advanced modifiers
	local happiness = life and life.Stats and life.Stats.Happiness or 50
	local smarts = life and life.Stats and life.Stats.Smarts or 50
	local health = life and life.Stats and life.Stats.Health or 50
	local flags = life and life.Flags or {}
	
	-- Calculate effectiveness multiplier based on current stats
	-- Happiness affects motivation (0.7x to 1.3x)
	local moodBonus = 1.0
	if happiness >= 80 then
		moodBonus = 1.3  -- Very happy = super effective
	elseif happiness >= 60 then
		moodBonus = 1.15 -- Happy = more effective
	elseif happiness <= 20 then
		moodBonus = 0.7  -- Depressed = less effective
	elseif happiness <= 40 then
		moodBonus = 0.85 -- Sad = somewhat less effective
	end
	
	-- Smarts affects learning activities (study, read)
	local smartsBonus = 1.0
	if activityId == "study" or activityId == "read" then
		smartsBonus = 0.8 + (smarts / 100) * 0.5 -- 0.8x to 1.3x based on Smarts
		print("[LifeRemoteHandlers] Learning activity - Smarts bonus:", smartsBonus)
	end
	
	-- Health affects physical activities (gym, run, yoga)
	local healthBonus = 1.0
	if activityId == "gym" or activityId == "run" or activityId == "yoga" then
		healthBonus = 0.8 + (health / 100) * 0.5 -- 0.8x to 1.3x based on Health
		print("[LifeRemoteHandlers] Physical activity - Health bonus:", healthBonus)
	end
	
	-- Athletic flag bonus (from childhood sports focus)
	local athleticBonus = 1.0
	if flags.athletic_child and (activityId == "gym" or activityId == "run" or activityId == "yoga") then
		athleticBonus = 1.2
		print("[LifeRemoteHandlers] Athletic background bonus applied!")
	end
	
	-- Calculate combined effectiveness
	local effectivenessMultiplier = moodBonus * smartsBonus * healthBonus * athleticBonus
	print("[LifeRemoteHandlers] Activity effectiveness:", effectivenessMultiplier, "mood:", moodBonus, "smarts:", smartsBonus, "health:", healthBonus)
	
	-- Chance to fail if very unhappy or low health
	local failChance = 0
	if happiness <= 15 then
		failChance = 30 -- 30% chance to fail if severely depressed
	elseif health <= 15 then
		failChance = 20 -- 20% chance to fail if very unhealthy
	end
	
	if failChance > 0 and math.random(100) <= failChance then
		local failMessages = {
			"You couldn't focus and gave up halfway through.",
			"You're feeling too down to finish this today.",
			"Your body isn't cooperating. Maybe rest first?",
			"You started but lost motivation quickly.",
		}
		return {
			success = false,
			message = failMessages[math.random(#failMessages)]
		}
	end
	
	-- Apply stat effects with modifiers
	local statChanges = {}
	local resultMessages = {}
	
	if activity.effects then
		for stat, range in pairs(activity.effects) do
			-- Calculate base change
			local baseChange = math.random(range[1], range[2])
			
			-- Apply multiplier for positive changes
			local finalChange = baseChange
			if baseChange > 0 then
				finalChange = math.floor(baseChange * effectivenessMultiplier + 0.5)
			end
			
			-- Exceptional performance bonus (10% chance if all stats high)
			if happiness >= 70 and health >= 70 and math.random(100) <= 10 then
				finalChange = math.floor(finalChange * 1.5)
				table.insert(resultMessages, "Exceptional performance!")
			end
			
			modifyStat(player, stat, finalChange)
			statChanges[stat] = finalChange
		end
	end
	
	syncStateToClient(player)
	
	-- Build result message
	local baseMessage = "You did " .. activity.name .. "!"
	if effectivenessMultiplier >= 1.2 then
		baseMessage = "You crushed " .. activity.name .. "! Great job!"
	elseif effectivenessMultiplier <= 0.8 then
		baseMessage = "You did " .. activity.name .. ", but it was tough today."
	end
	
	if #resultMessages > 0 then
		baseMessage = baseMessage .. " " .. table.concat(resultMessages, " ")
	end
	
	return { 
		success = true, 
		message = baseMessage,
		statChanges = statChanges,
		effectivenessMultiplier = effectivenessMultiplier
	}
end

CommitCrime.OnServerInvoke = function(player, crimeId)
	local age = getAge(player)
	local extState = getExtendedState(player)
	local life = _G.GetPlayerLife and _G.GetPlayerLife(player) or nil
	
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
	
	-- ═══════════════════════════════════════════════════════════
	-- ADVANCED CRIME SKILL MODIFIERS (Triple AAA Polish)
	-- ═══════════════════════════════════════════════════════════
	
	local smarts = life and life.Stats and life.Stats.Smarts or 50
	local looks = life and life.Stats and life.Stats.Looks or 50
	local happiness = life and life.Stats and life.Stats.Happiness or 50
	local flags = life and life.Flags or {}
	
	-- Calculate risk modifier based on stats and experience
	local riskModifier = 0
	
	-- Smarts reduces catch risk (better planning)
	-- High smarts = up to -15% catch risk
	local smartsReduction = math.floor((smarts - 50) / 50 * 15)
	riskModifier = riskModifier - smartsReduction
	
	-- Criminal experience reduces risk
	if flags.criminal_tendencies then riskModifier = riskModifier - 5 end
	if flags.petty_thief or flags.shoplifter then riskModifier = riskModifier - 5 end
	if flags.car_thief or flags.burglar then riskModifier = riskModifier - 8 end
	if flags.gang_member then riskModifier = riskModifier - 10 end
	if flags.gang_captain then riskModifier = riskModifier - 12 end
	if flags.underboss or flags.crime_boss then riskModifier = riskModifier - 15 end
	
	-- Low happiness increases carelessness (more risk)
	if happiness <= 20 then
		riskModifier = riskModifier + 10 -- Depressed = sloppy
	elseif happiness <= 40 then
		riskModifier = riskModifier + 5
	end
	
	-- Looks can help with certain crimes (pickpocket, con games)
	if crimeId == "pickpocket" and looks >= 70 then
		riskModifier = riskModifier - 5 -- Charming appearance = less suspicious
	end
	
	-- Calculate final catch chance
	local baseCatchChance = crime.risk
	local finalCatchChance = math.clamp(baseCatchChance + riskModifier, 5, 95)
	
	print("[LifeRemoteHandlers] Crime:", crimeId, "Base risk:", baseCatchChance, "Modifier:", riskModifier, "Final:", finalCatchChance)
	
	-- Roll for getting caught
	local caught = math.random(100) <= finalCatchChance
	
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
			-- CRITICAL: Clear 'employed' flag when going to jail
			life.Flags.employed = nil
			-- IMPORTANT: Clear sentence_complete when going to prison (prevents bugs from previous stints)
			life.Flags.sentence_complete = nil
			life.Flags.released_from_prison = nil
			print("[LifeRemoteHandlers] Set prison flags, cleared 'employed' flag")
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
		-- SUCCESS - Apply skill-based reward modifiers
		local baseReward = math.random(crime.rewardMin, crime.rewardMax)
		
		-- Smarts bonus for reward (better planning = bigger haul)
		local rewardMultiplier = 1.0
		if smarts >= 80 then
			rewardMultiplier = 1.4  -- Very smart = much bigger haul
		elseif smarts >= 60 then
			rewardMultiplier = 1.2
		end
		
		-- Criminal experience bonus
		if flags.gang_member then rewardMultiplier = rewardMultiplier * 1.15 end
		if flags.underboss or flags.crime_boss then rewardMultiplier = rewardMultiplier * 1.3 end
		
		local finalReward = math.floor(baseReward * rewardMultiplier)
		addMoney(player, finalReward)
		
		-- Set criminal tendencies flag if not already
		if life and not flags.criminal_tendencies then
			life.Flags = life.Flags or {}
			life.Flags.criminal_tendencies = true
		end
		
		-- Track specific crimes for experience bonuses
		if life and crimeId == "shoplift" and not flags.shoplifter then
			life.Flags.shoplifter = true
		elseif life and crimeId == "pickpocket" and not flags.petty_thief then
			life.Flags.petty_thief = true
		elseif life and crimeId == "gta" and not flags.car_thief then
			life.Flags.car_thief = true
		elseif life and crimeId == "burglary" and not flags.burglar then
			life.Flags.burglar = true
		end
		
		-- Build success message
		local successMessage = "You got away with it! You earned $" .. finalReward
		if rewardMultiplier > 1.2 then
			successMessage = "Clean getaway! Your experience paid off - $" .. finalReward
		end
		
		return { 
			success = true, 
			message = successMessage,
			reward = finalReward,
			rewardMultiplier = rewardMultiplier
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
	
	-- Update career tracking
	local extState = getExtendedState(player)
	local careerData = getCareerData(player)
	
	-- If player has a job, increment years at current job
	if extState.CurrentJob then
		careerData.YearsAtCurrentJob = (careerData.YearsAtCurrentJob or 0) + 1
		print("[LifeRemoteHandlers] Player aged up - Years at job:", careerData.YearsAtCurrentJob)
	end
end

-- Get extended state for external access
_G.GetExtendedState = function(player)
	return getExtendedState(player)
end

-- Reset extended state for new life (called from LifeManager.resetPlayerLife)
_G.ResetExtendedState = function(player)
	if not player or not player.UserId then return end
	
	-- Create fresh extended state
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
	
	print("[LifeRemoteHandlers] Reset extended state for new life:", player.Name)
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

-- Add asset from event (callable from LifeManager when event choice includes addAsset)
_G.AddAssetFromEvent = function(player, assetData)
	if not assetData or not assetData.type or not assetData.id then
		print("[LifeRemoteHandlers] AddAssetFromEvent - Invalid asset data")
		return false
	end
	
	local extState = getExtendedState(player)
	print("[LifeRemoteHandlers] AddAssetFromEvent - Adding", assetData.id, "type:", assetData.type)
	
	local asset = {
		id = assetData.id,
		name = assetData.name or assetData.id,
		value = assetData.value or 0,
	}
	
	if assetData.type == "vehicle" then
		extState.OwnedVehicles = extState.OwnedVehicles or {}
		table.insert(extState.OwnedVehicles, asset)
		print("[LifeRemoteHandlers] Added vehicle:", asset.name)
	elseif assetData.type == "property" then
		extState.OwnedProperties = extState.OwnedProperties or {}
		table.insert(extState.OwnedProperties, asset)
		print("[LifeRemoteHandlers] Added property:", asset.name)
	elseif assetData.type == "item" then
		extState.OwnedItems = extState.OwnedItems or {}
		table.insert(extState.OwnedItems, asset)
		print("[LifeRemoteHandlers] Added item:", asset.name)
	else
		print("[LifeRemoteHandlers] Unknown asset type:", assetData.type)
		return false
	end
	
	syncStateToClient(player)
	return true
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
		-- CRITICAL: Clear 'employed' flag when going to jail
		life.Flags.employed = nil
		-- Clear any release flags
		life.Flags.sentence_complete = nil
		life.Flags.released_from_prison = nil
	end
	
	syncStateToClient(player)
	print("[LifeRemoteHandlers] Player sent to jail for", years, "years")
end

-- Set player job from event choice (callable from LifeManager when event includes setJob)
_G.SetPlayerJob = function(player, jobData)
	if not jobData then
		print("[LifeRemoteHandlers] SetPlayerJob - No job data provided")
		return false
	end
	
	local extState = getExtendedState(player)
	local life = _G.GetPlayerLife and _G.GetPlayerLife(player)
	print("[LifeRemoteHandlers] SetPlayerJob - Setting job for:", player.Name)
	print("[LifeRemoteHandlers] Job:", jobData.id or "unknown", jobData.title or "unknown")
	
	-- Create job entry in ExtendedState
	extState.CurrentJob = {
		id = jobData.id or "story_job",
		title = jobData.title or "Employee",
		company = jobData.company or "Company",
		salary = jobData.salary or 30000,
		requirement = jobData.requirement or nil,
		-- Track that this job came from a story event
		fromStory = true,
		storyFlag = jobData.storyFlag or nil, -- e.g., "teacher", "hacker_career"
	}
	
	-- CRITICAL: Set the 'employed' flag in player's Flags for event system
	-- This allows career events to properly fire/block based on employment status
	if life then
		life.Flags = life.Flags or {}
		life.Flags.employed = true
		print("[LifeRemoteHandlers] Set 'employed' flag = true")
	end
	
	print("[LifeRemoteHandlers] Job set:", extState.CurrentJob.title, "at", extState.CurrentJob.company, "- Salary:", extState.CurrentJob.salary)
	
	syncStateToClient(player)
	return true
end

-- Quit player job (callable from scripts)
_G.QuitPlayerJob = function(player)
	local extState = getExtendedState(player)
	local life = _G.GetPlayerLife and _G.GetPlayerLife(player)
	if extState.CurrentJob then
		local oldJob = extState.CurrentJob.title or "job"
		extState.CurrentJob = nil
		
		-- CRITICAL: Clear the 'employed' flag when quitting
		if life then
			life.Flags = life.Flags or {}
			life.Flags.employed = nil
			print("[LifeRemoteHandlers] Cleared 'employed' flag")
		end
		
		print("[LifeRemoteHandlers] Player quit job:", oldJob)
		syncStateToClient(player)
		return true
	end
	return false
end

-- Get player's current job (for other scripts to check)
_G.GetPlayerJob = function(player)
	local extState = getExtendedState(player)
	return extState.CurrentJob
end

print("[LifeRemoteHandlers] ✅ All remote handlers initialized!")
