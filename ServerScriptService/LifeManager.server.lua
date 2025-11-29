-- LifeManager.server.lua
-- Core life simulation + networking with Jobs, Crimes, Activities.

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

-- Core events
local RequestAgeUp = getRemote("RequestAgeUp")
local PresentEvent = getRemote("PresentEvent")
local SubmitChoice = getRemote("SubmitChoice")
local SyncState = getRemote("SyncState")
local SetLifeInfo = getRemote("SetLifeInfo")

-- Job system
local GetJobs = getRemoteFunction("GetJobs")
local ApplyForJob = getRemoteFunction("ApplyForJob")
local QuitJob = getRemote("QuitJob")

-- Crime system
local GetCrimes = getRemoteFunction("GetCrimes")
local CommitCrime = getRemoteFunction("CommitCrime")

-- Activities system
local DoActivity = getRemoteFunction("DoActivity")
local GetActivities = getRemoteFunction("GetActivities")

----------------------------------------------------------------
-- JOB DATABASE
----------------------------------------------------------------

local JobDatabase = {
	-- Entry-level jobs (no requirements)
	{
		id = "fast_food",
		title = "Fast Food Worker",
		emoji = "🍔",
		company = "McRonald's",
		salary = 18000,
		minAge = 16,
		requirements = {},
		category = "Service",
	},
	{
		id = "grocery_clerk",
		title = "Grocery Clerk",
		emoji = "🛒",
		company = "FreshMart",
		salary = 20000,
		minAge = 16,
		requirements = {},
		category = "Retail",
	},
	{
		id = "dog_walker",
		title = "Dog Walker",
		emoji = "🐕",
		company = "Paws & Claws",
		salary = 15000,
		minAge = 14,
		requirements = {},
		category = "Service",
	},
	{
		id = "babysitter",
		title = "Babysitter",
		emoji = "👶",
		company = "Self-Employed",
		salary = 12000,
		minAge = 14,
		requirements = {},
		category = "Service",
	},
	{
		id = "movie_theater",
		title = "Movie Theater Attendant",
		emoji = "🎬",
		company = "CinePlex",
		salary = 19000,
		minAge = 16,
		requirements = {},
		category = "Entertainment",
	},
	-- Mid-level jobs
	{
		id = "office_assistant",
		title = "Office Assistant",
		emoji = "📎",
		company = "CorpTech Inc.",
		salary = 32000,
		minAge = 18,
		requirements = { Smarts = 40 },
		category = "Business",
	},
	{
		id = "sales_associate",
		title = "Sales Associate",
		emoji = "💼",
		company = "SellMax",
		salary = 35000,
		minAge = 18,
		requirements = { Looks = 30 },
		category = "Sales",
	},
	{
		id = "security_guard",
		title = "Security Guard",
		emoji = "🛡️",
		company = "SecureForce",
		salary = 30000,
		minAge = 21,
		requirements = { Health = 50 },
		category = "Security",
	},
	{
		id = "waiter",
		title = "Restaurant Server",
		emoji = "🍽️",
		company = "Fine Dine",
		salary = 28000,
		minAge = 18,
		requirements = { Happiness = 40 },
		category = "Service",
	},
	{
		id = "barista",
		title = "Barista",
		emoji = "☕",
		company = "StarCoffee",
		salary = 26000,
		minAge = 16,
		requirements = {},
		category = "Service",
	},
	-- Professional jobs
	{
		id = "junior_developer",
		title = "Junior Developer",
		emoji = "💻",
		company = "TechStart",
		salary = 65000,
		minAge = 22,
		requirements = { Smarts = 60 },
		category = "Technology",
	},
	{
		id = "nurse",
		title = "Registered Nurse",
		emoji = "👩‍⚕️",
		company = "City Hospital",
		salary = 72000,
		minAge = 24,
		requirements = { Smarts = 55, Health = 40 },
		category = "Healthcare",
	},
	{
		id = "accountant",
		title = "Accountant",
		emoji = "📊",
		company = "NumbersCo",
		salary = 58000,
		minAge = 22,
		requirements = { Smarts = 50 },
		category = "Finance",
	},
	{
		id = "teacher",
		title = "Teacher",
		emoji = "📚",
		company = "Public School",
		salary = 48000,
		minAge = 24,
		requirements = { Smarts = 50, Happiness = 40 },
		category = "Education",
	},
	{
		id = "marketing_specialist",
		title = "Marketing Specialist",
		emoji = "📢",
		company = "AdVenture",
		salary = 55000,
		minAge = 22,
		requirements = { Smarts = 45, Looks = 35 },
		category = "Marketing",
	},
	-- Senior/Executive jobs
	{
		id = "senior_developer",
		title = "Senior Developer",
		emoji = "🖥️",
		company = "MegaTech",
		salary = 120000,
		minAge = 28,
		requirements = { Smarts = 75 },
		category = "Technology",
	},
	{
		id = "doctor",
		title = "Doctor",
		emoji = "🩺",
		company = "General Hospital",
		salary = 180000,
		minAge = 30,
		requirements = { Smarts = 80, Health = 50 },
		category = "Healthcare",
	},
	{
		id = "lawyer",
		title = "Lawyer",
		emoji = "⚖️",
		company = "Justice & Associates",
		salary = 150000,
		minAge = 28,
		requirements = { Smarts = 75 },
		category = "Legal",
	},
	{
		id = "ceo",
		title = "CEO",
		emoji = "👔",
		company = "Fortune 500",
		salary = 500000,
		minAge = 35,
		requirements = { Smarts = 85, Looks = 60, Happiness = 50 },
		category = "Executive",
	},
	{
		id = "pilot",
		title = "Commercial Pilot",
		emoji = "✈️",
		company = "SkyWays Airlines",
		salary = 140000,
		minAge = 26,
		requirements = { Smarts = 65, Health = 70 },
		category = "Aviation",
	},
	-- Creative jobs
	{
		id = "actor",
		title = "Actor",
		emoji = "🎭",
		company = "Hollywood Studios",
		salary = 85000,
		minAge = 18,
		requirements = { Looks = 70, Happiness = 50 },
		category = "Entertainment",
	},
	{
		id = "musician",
		title = "Musician",
		emoji = "🎸",
		company = "Record Label",
		salary = 45000,
		minAge = 18,
		requirements = { Happiness = 60 },
		category = "Entertainment",
	},
	{
		id = "influencer",
		title = "Social Media Influencer",
		emoji = "📱",
		company = "Self-Employed",
		salary = 75000,
		minAge = 16,
		requirements = { Looks = 65, Happiness = 55 },
		category = "Entertainment",
	},
}

local JobsById = {}
for _, job in ipairs(JobDatabase) do
	JobsById[job.id] = job
end

----------------------------------------------------------------
-- CRIME DATABASE
----------------------------------------------------------------

local CrimeDatabase = {
	{
		id = "pickpocket",
		name = "Pickpocket",
		emoji = "🖐️",
		description = "Steal from someone's pocket",
		minPayout = 20,
		maxPayout = 200,
		successChance = 0.7,
		jailYears = 1,
		minAge = 12,
	},
	{
		id = "shoplift",
		name = "Shoplift",
		emoji = "🏪",
		description = "Steal items from a store",
		minPayout = 50,
		maxPayout = 500,
		successChance = 0.65,
		jailYears = 1,
		minAge = 12,
	},
	{
		id = "purse_snatch",
		name = "Purse Snatch",
		emoji = "👜",
		description = "Grab someone's purse and run",
		minPayout = 100,
		maxPayout = 800,
		successChance = 0.55,
		jailYears = 2,
		minAge = 14,
	},
	{
		id = "car_theft",
		name = "Grand Theft Auto",
		emoji = "🚗",
		description = "Steal a car",
		minPayout = 2000,
		maxPayout = 25000,
		successChance = 0.4,
		jailYears = 5,
		minAge = 16,
	},
	{
		id = "burglary",
		name = "Burglary",
		emoji = "🏠",
		description = "Break into a house",
		minPayout = 1000,
		maxPayout = 15000,
		successChance = 0.45,
		jailYears = 4,
		minAge = 16,
	},
	{
		id = "bank_robbery",
		name = "Bank Robbery",
		emoji = "🏦",
		description = "Rob a bank",
		minPayout = 50000,
		maxPayout = 500000,
		successChance = 0.2,
		jailYears = 20,
		minAge = 21,
	},
	{
		id = "extortion",
		name = "Extortion",
		emoji = "💰",
		description = "Threaten someone for money",
		minPayout = 500,
		maxPayout = 5000,
		successChance = 0.5,
		jailYears = 3,
		minAge = 18,
	},
	{
		id = "drug_deal",
		name = "Drug Dealing",
		emoji = "💊",
		description = "Sell illegal substances",
		minPayout = 200,
		maxPayout = 3000,
		successChance = 0.55,
		jailYears = 6,
		minAge = 16,
	},
	{
		id = "fraud",
		name = "Identity Fraud",
		emoji = "🆔",
		description = "Commit identity theft",
		minPayout = 5000,
		maxPayout = 50000,
		successChance = 0.35,
		jailYears = 8,
		minAge = 18,
	},
	{
		id = "train_robbery",
		name = "Train Robbery",
		emoji = "🚂",
		description = "Hold up a train",
		minPayout = 10000,
		maxPayout = 100000,
		successChance = 0.25,
		jailYears = 15,
		minAge = 21,
	},
}

local CrimesById = {}
for _, crime in ipairs(CrimeDatabase) do
	CrimesById[crime.id] = crime
end

----------------------------------------------------------------
-- ACTIVITIES DATABASE
----------------------------------------------------------------

local ActivitiesDatabase = {
	-- Health activities
	{
		id = "gym",
		name = "Go to Gym",
		emoji = "🏋️",
		category = "Health",
		effects = { Health = 5, Looks = 2, Happiness = 2 },
		cost = 50,
		minAge = 14,
	},
	{
		id = "walk",
		name = "Take a Walk",
		emoji = "🚶",
		category = "Health",
		effects = { Health = 2, Happiness = 3 },
		cost = 0,
		minAge = 5,
	},
	{
		id = "martial_arts",
		name = "Martial Arts",
		emoji = "🥋",
		category = "Health",
		effects = { Health = 6, Happiness = 3 },
		cost = 100,
		minAge = 8,
	},
	{
		id = "yoga",
		name = "Yoga",
		emoji = "🧘",
		category = "Health",
		effects = { Health = 4, Happiness = 5, Looks = 1 },
		cost = 40,
		minAge = 10,
	},
	{
		id = "swimming",
		name = "Go Swimming",
		emoji = "🏊",
		category = "Health",
		effects = { Health = 5, Happiness = 4 },
		cost = 20,
		minAge = 6,
	},
	-- Mind activities
	{
		id = "library",
		name = "Visit Library",
		emoji = "📚",
		category = "Mind",
		effects = { Smarts = 5, Happiness = 1 },
		cost = 0,
		minAge = 6,
	},
	{
		id = "meditate",
		name = "Meditate",
		emoji = "🧠",
		category = "Mind",
		effects = { Happiness = 6, Health = 2, Smarts = 1 },
		cost = 0,
		minAge = 10,
	},
	{
		id = "puzzle",
		name = "Do Puzzles",
		emoji = "🧩",
		category = "Mind",
		effects = { Smarts = 4, Happiness = 2 },
		cost = 15,
		minAge = 5,
	},
	{
		id = "online_course",
		name = "Online Course",
		emoji = "💻",
		category = "Mind",
		effects = { Smarts = 7 },
		cost = 200,
		minAge = 14,
	},
	{
		id = "chess",
		name = "Play Chess",
		emoji = "♟️",
		category = "Mind",
		effects = { Smarts = 4, Happiness = 2 },
		cost = 0,
		minAge = 8,
	},
	-- Fun activities
	{
		id = "movie",
		name = "Watch Movie",
		emoji = "🎬",
		category = "Fun",
		effects = { Happiness = 5 },
		cost = 25,
		minAge = 5,
	},
	{
		id = "party",
		name = "Go to Party",
		emoji = "🎉",
		category = "Fun",
		effects = { Happiness = 8, Health = -2 },
		cost = 50,
		minAge = 16,
	},
	{
		id = "gaming",
		name = "Video Games",
		emoji = "🎮",
		category = "Fun",
		effects = { Happiness = 5, Health = -1 },
		cost = 0,
		minAge = 6,
	},
	{
		id = "concert",
		name = "Go to Concert",
		emoji = "🎤",
		category = "Fun",
		effects = { Happiness = 10 },
		cost = 150,
		minAge = 14,
	},
	{
		id = "amusement_park",
		name = "Amusement Park",
		emoji = "🎢",
		category = "Fun",
		effects = { Happiness = 12, Health = -1 },
		cost = 100,
		minAge = 8,
	},
	-- Beauty activities
	{
		id = "salon",
		name = "Hair Salon",
		emoji = "💇",
		category = "Beauty",
		effects = { Looks = 4, Happiness = 2 },
		cost = 80,
		minAge = 12,
	},
	{
		id = "spa",
		name = "Spa Day",
		emoji = "🧖",
		category = "Beauty",
		effects = { Looks = 3, Happiness = 6, Health = 2 },
		cost = 200,
		minAge = 16,
	},
	{
		id = "shopping",
		name = "Go Shopping",
		emoji = "🛍️",
		category = "Beauty",
		effects = { Looks = 2, Happiness = 5 },
		cost = 300,
		minAge = 10,
	},
	{
		id = "dentist",
		name = "Dentist Visit",
		emoji = "🦷",
		category = "Beauty",
		effects = { Looks = 2, Health = 3 },
		cost = 150,
		minAge = 5,
	},
	{
		id = "plastic_surgery",
		name = "Plastic Surgery",
		emoji = "💉",
		category = "Beauty",
		effects = { Looks = 15, Health = -5, Happiness = 5 },
		cost = 10000,
		minAge = 21,
	},
}

local ActivitiesById = {}
for _, activity in ipairs(ActivitiesDatabase) do
	ActivitiesById[activity.id] = activity
end

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
		Job = state.Job,
		InJail = state.InJail,
		JailYearsLeft = state.JailYearsLeft,
		CrimeRecord = state.CrimeRecord,
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
-- JOB FUNCTIONS
----------------------------------------------------------------

local function meetsJobRequirements(state, job)
	if state.Age < job.minAge then
		return false, "You're too young for this job."
	end
	
	for stat, minValue in pairs(job.requirements or {}) do
		if (state.Stats[stat] or 0) < minValue then
			return false, string.format("You need at least %d%% %s.", minValue, stat)
		end
	end
	
	return true, nil
end

local function applyForJobInternal(player, jobId)
	local state = getLife(player)
	
	if not state.Name then
		return { success = false, message = "You haven't started your life yet!" }
	end
	
	if state.InJail then
		return { success = false, message = "You can't apply for jobs while in jail!" }
	end
	
	local job = JobsById[jobId]
	if not job then
		return { success = false, message = "Job not found." }
	end
	
	local canApply, reason = meetsJobRequirements(state, job)
	if not canApply then
		return { success = false, message = reason }
	end
	
	-- Interview success based on stats
	local baseChance = 0.5
	local smartsBonus = (state.Stats.Smarts or 50) / 200
	local looksBonus = (state.Stats.Looks or 50) / 400
	local happinessBonus = (state.Stats.Happiness or 50) / 400
	
	local successChance = math.min(0.95, baseChance + smartsBonus + looksBonus + happinessBonus)
	
	if math.random() < successChance then
		state.Job = {
			id = job.id,
			title = job.title,
			company = job.company,
			salary = job.salary,
			emoji = job.emoji,
		}
		
		local feedText = string.format("🎉 You got hired as a %s at %s! Salary: $%d/year", job.title, job.company, job.salary)
		state:AddFeed(feedText)
		pushState(player, state, feedText)
		
		return { success = true, message = string.format("Congratulations! You're now a %s at %s!", job.title, job.company) }
	else
		local feedText = string.format("😔 You weren't selected for the %s position at %s.", job.title, job.company)
		state:AddFeed(feedText)
		pushState(player, state, feedText)
		
		return { success = false, message = "Unfortunately, you weren't selected for this position. Keep trying!" }
	end
end

local function getAvailableJobs(player)
	local state = getLife(player)
	local jobs = {}
	
	for _, job in ipairs(JobDatabase) do
		local canApply, _ = meetsJobRequirements(state, job)
		table.insert(jobs, {
			id = job.id,
			title = job.title,
			emoji = job.emoji,
			company = job.company,
			salary = job.salary,
			minAge = job.minAge,
			requirements = job.requirements,
			category = job.category,
			canApply = canApply,
		})
	end
	
	return jobs
end

----------------------------------------------------------------
-- CRIME FUNCTIONS
----------------------------------------------------------------

local function commitCrimeInternal(player, crimeId)
	local state = getLife(player)
	
	if not state.Name then
		return { success = false, message = "You haven't started your life yet!" }
	end
	
	if state.InJail then
		return { success = false, message = "You're already in jail!" }
	end
	
	local crime = CrimesById[crimeId]
	if not crime then
		return { success = false, message = "Crime not found." }
	end
	
	if state.Age < crime.minAge then
		return { success = false, message = "You're too young for this crime." }
	end
	
	-- Attempt the crime
	local roll = math.random()
	
	if roll < crime.successChance then
		-- Success!
		local payout = math.random(crime.minPayout, crime.maxPayout)
		state.Money = state.Money + payout
		state.CrimeRecord = (state.CrimeRecord or 0) + 1
		state.Stats.Happiness = (state.Stats.Happiness or 50) + 5
		
		local feedText = string.format("💵 You successfully committed %s and got away with $%d!", crime.name, payout)
		state:AddFeed(feedText)
		pushState(player, state, feedText)
		
		return { 
			success = true, 
			caught = false,
			payout = payout,
			message = string.format("Success! You got away with $%d!", payout)
		}
	else
		-- Caught!
		state.InJail = true
		state.JailYearsLeft = crime.jailYears
		state.Job = nil -- Lose job
		state.CrimeRecord = (state.CrimeRecord or 0) + 1
		state.Stats.Happiness = (state.Stats.Happiness or 50) - 20
		
		local feedText = string.format("🚔 You were caught committing %s! Sentenced to %d years in prison.", crime.name, crime.jailYears)
		state:AddFeed(feedText)
		pushState(player, state, feedText)
		
		return {
			success = false,
			caught = true,
			jailYears = crime.jailYears,
			message = string.format("Busted! You've been sentenced to %d years in prison!", crime.jailYears)
		}
	end
end

local function getAvailableCrimes(player)
	local state = getLife(player)
	local crimes = {}
	
	for _, crime in ipairs(CrimeDatabase) do
		local canDo = state.Age >= crime.minAge and not state.InJail
		table.insert(crimes, {
			id = crime.id,
			name = crime.name,
			emoji = crime.emoji,
			description = crime.description,
			minPayout = crime.minPayout,
			maxPayout = crime.maxPayout,
			jailYears = crime.jailYears,
			minAge = crime.minAge,
			canDo = canDo,
		})
	end
	
	return crimes
end

----------------------------------------------------------------
-- ACTIVITY FUNCTIONS
----------------------------------------------------------------

local function doActivityInternal(player, activityId)
	local state = getLife(player)
	
	if not state.Name then
		return { success = false, message = "You haven't started your life yet!" }
	end
	
	if state.InJail then
		return { success = false, message = "You can't do activities while in jail!" }
	end
	
	local activity = ActivitiesById[activityId]
	if not activity then
		return { success = false, message = "Activity not found." }
	end
	
	if state.Age < activity.minAge then
		return { success = false, message = "You're too young for this activity." }
	end
	
	if state.Money < activity.cost then
		return { success = false, message = string.format("You need $%d for this activity.", activity.cost) }
	end
	
	-- Do the activity
	state.Money = state.Money - activity.cost
	
	for stat, change in pairs(activity.effects or {}) do
		if state.Stats[stat] ~= nil then
			state.Stats[stat] = state.Stats[stat] + change
		end
	end
	
	state:ClampStats()
	
	local feedText = string.format("%s You did: %s", activity.emoji, activity.name)
	if activity.cost > 0 then
		feedText = feedText .. string.format(" (-$%d)", activity.cost)
	end
	
	state:AddFeed(feedText)
	pushState(player, state, feedText)
	
	return { success = true, message = string.format("You enjoyed %s!", activity.name) }
end

local function getAvailableActivities(player)
	local state = getLife(player)
	local activities = {}
	
	for _, activity in ipairs(ActivitiesDatabase) do
		local canDo = state.Age >= activity.minAge and state.Money >= activity.cost and not state.InJail
		table.insert(activities, {
			id = activity.id,
			name = activity.name,
			emoji = activity.emoji,
			category = activity.category,
			effects = activity.effects,
			cost = activity.cost,
			minAge = activity.minAge,
			canDo = canDo,
		})
	end
	
	return activities
end

----------------------------------------------------------------
-- PLAYER HANDLERS
----------------------------------------------------------------

Players.PlayerAdded:Connect(function(player)
	local state = createNewLife(player)
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

	-- Handle jail time
	if state.InJail then
		state.JailYearsLeft = (state.JailYearsLeft or 1) - 1
		if state.JailYearsLeft <= 0 then
			state.InJail = false
			state.JailYearsLeft = 0
			local releaseText = "🔓 You've been released from prison!"
			state:AddFeed(releaseText)
		else
			local jailText = string.format("⛓️ You spent another year in prison. %d years remaining.", state.JailYearsLeft)
			state:AddFeed(jailText)
		end
	end

	state.Age = state.Age + 1
	state.Year = state.Year + 1

	-- Pay salary if employed
	if state.Job and not state.InJail then
		local salary = state.Job.salary or 0
		state.Money = state.Money + salary
		local payText = string.format("💰 You earned $%d from your job as %s.", salary, state.Job.title)
		state:AddFeed(payText)
	end

	local ageText
	if state.Age == 1 then
		ageText = "You are now 1 year old."
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

----------------------------------------------------------------
-- JOB HANDLERS
----------------------------------------------------------------

GetJobs.OnServerInvoke = function(player)
	return getAvailableJobs(player)
end

ApplyForJob.OnServerInvoke = function(player, jobId)
	return applyForJobInternal(player, jobId)
end

QuitJob.OnServerEvent:Connect(function(player)
	local state = getLife(player)
	if state.Job then
		local feedText = string.format("👋 You quit your job as %s at %s.", state.Job.title, state.Job.company)
		state.Job = nil
		state:AddFeed(feedText)
		pushState(player, state, feedText)
	end
end)

----------------------------------------------------------------
-- CRIME HANDLERS
----------------------------------------------------------------

GetCrimes.OnServerInvoke = function(player)
	return getAvailableCrimes(player)
end

CommitCrime.OnServerInvoke = function(player, crimeId)
	return commitCrimeInternal(player, crimeId)
end

----------------------------------------------------------------
-- ACTIVITY HANDLERS
----------------------------------------------------------------

GetActivities.OnServerInvoke = function(player)
	return getAvailableActivities(player)
end

DoActivity.OnServerInvoke = function(player, activityId)
	return doActivityInternal(player, activityId)
end
