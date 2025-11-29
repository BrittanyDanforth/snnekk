-- LifeManager.server.lua
-- Core life simulation + networking with Jobs, Crimes, Activities, Education, Relationships, Assets, and more.
-- Massively enhanced with full life simulation features.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LifeState = require(ReplicatedStorage:WaitForChild("LifeState"))
local EventLibrary = require(ReplicatedStorage:WaitForChild("EventLibrary"))
local EventRunner = require(ReplicatedStorage:WaitForChild("EventRunner"))

----------------------------------------------------------------
-- REMOTES SETUP
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

-- Education system
local GetEducation = getRemoteFunction("GetEducation")
local EnrollEducation = getRemoteFunction("EnrollEducation")
local DropOut = getRemote("DropOut")

-- Relationships system
local GetRelationships = getRemoteFunction("GetRelationships")
local InteractRelationship = getRemoteFunction("InteractRelationship")

-- Assets system
local GetAssets = getRemoteFunction("GetAssets")
local BuyAsset = getRemoteFunction("BuyAsset")
local SellAsset = getRemoteFunction("SellAsset")

-- Prison system
local GetPrisonActions = getRemoteFunction("GetPrisonActions")
local DoPrisonAction = getRemoteFunction("DoPrisonAction")

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
	{
		id = "lawn_care",
		title = "Lawn Care Worker",
		emoji = "🌿",
		company = "Green Thumb LLC",
		salary = 17000,
		minAge = 14,
		requirements = {},
		category = "Service",
	},
	{
		id = "retail_cashier",
		title = "Retail Cashier",
		emoji = "💵",
		company = "MegaMart",
		salary = 21000,
		minAge = 16,
		requirements = {},
		category = "Retail",
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
	{
		id = "receptionist",
		title = "Receptionist",
		emoji = "📞",
		company = "Grand Hotel",
		salary = 29000,
		minAge = 18,
		requirements = { Looks = 35 },
		category = "Service",
	},
	{
		id = "delivery_driver",
		title = "Delivery Driver",
		emoji = "🚗",
		company = "QuickShip",
		salary = 33000,
		minAge = 18,
		requirements = { Health = 30 },
		category = "Transportation",
	},
	{
		id = "warehouse_worker",
		title = "Warehouse Worker",
		emoji = "📦",
		company = "BigBox Distribution",
		salary = 31000,
		minAge = 18,
		requirements = { Health = 45 },
		category = "Labor",
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
	{
		id = "graphic_designer",
		title = "Graphic Designer",
		emoji = "🎨",
		company = "Creative Studios",
		salary = 52000,
		minAge = 22,
		requirements = { Smarts = 45 },
		category = "Creative",
	},
	{
		id = "paralegal",
		title = "Paralegal",
		emoji = "📋",
		company = "Law Office",
		salary = 48000,
		minAge = 22,
		requirements = { Smarts = 50 },
		category = "Legal",
	},
	{
		id = "real_estate_agent",
		title = "Real Estate Agent",
		emoji = "🏠",
		company = "Dream Homes",
		salary = 55000,
		minAge = 21,
		requirements = { Looks = 40, Smarts = 35 },
		category = "Sales",
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
	{
		id = "surgeon",
		title = "Surgeon",
		emoji = "🔪",
		company = "University Hospital",
		salary = 350000,
		minAge = 32,
		requirements = { Smarts = 90, Health = 60 },
		category = "Healthcare",
	},
	{
		id = "investment_banker",
		title = "Investment Banker",
		emoji = "💹",
		company = "Wall Street Capital",
		salary = 200000,
		minAge = 26,
		requirements = { Smarts = 80 },
		category = "Finance",
	},
	{
		id = "software_architect",
		title = "Software Architect",
		emoji = "🏗️",
		company = "TechGiant Corp",
		salary = 180000,
		minAge = 30,
		requirements = { Smarts = 85 },
		category = "Technology",
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
	{
		id = "photographer",
		title = "Photographer",
		emoji = "📷",
		company = "Studio Photo",
		salary = 42000,
		minAge = 18,
		requirements = { Smarts = 40 },
		category = "Creative",
	},
	{
		id = "writer",
		title = "Writer",
		emoji = "✍️",
		company = "Publishing House",
		salary = 48000,
		minAge = 22,
		requirements = { Smarts = 55 },
		category = "Creative",
	},
	{
		id = "famous_actor",
		title = "A-List Actor",
		emoji = "⭐",
		company = "Hollywood Elite",
		salary = 2000000,
		minAge = 25,
		requirements = { Looks = 85, Happiness = 70 },
		category = "Entertainment",
	},
	-- Public service
	{
		id = "police_officer",
		title = "Police Officer",
		emoji = "👮",
		company = "City Police Dept",
		salary = 55000,
		minAge = 21,
		requirements = { Health = 60, Smarts = 40 },
		category = "Public Service",
	},
	{
		id = "firefighter",
		title = "Firefighter",
		emoji = "🚒",
		company = "Fire Department",
		salary = 52000,
		minAge = 21,
		requirements = { Health = 70 },
		category = "Public Service",
	},
	{
		id = "paramedic",
		title = "Paramedic",
		emoji = "🚑",
		company = "Emergency Services",
		salary = 48000,
		minAge = 21,
		requirements = { Health = 55, Smarts = 45 },
		category = "Healthcare",
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
	{
		id = "porch_pirate",
		name = "Porch Pirate",
		emoji = "📦",
		description = "Steal delivered packages",
		minPayout = 30,
		maxPayout = 300,
		successChance = 0.75,
		jailYears = 1,
		minAge = 12,
	},
	{
		id = "art_heist",
		name = "Art Heist",
		emoji = "🖼️",
		description = "Steal valuable artwork",
		minPayout = 100000,
		maxPayout = 1000000,
		successChance = 0.15,
		jailYears = 25,
		minAge = 25,
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
	{
		id = "running",
		name = "Go Running",
		emoji = "🏃",
		category = "Health",
		effects = { Health = 6, Happiness = 2 },
		cost = 0,
		minAge = 8,
	},
	{
		id = "cycling",
		name = "Go Cycling",
		emoji = "🚴",
		category = "Health",
		effects = { Health = 5, Happiness = 4 },
		cost = 10,
		minAge = 8,
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
	{
		id = "read_book",
		name = "Read a Book",
		emoji = "📖",
		category = "Mind",
		effects = { Smarts = 4, Happiness = 3 },
		cost = 15,
		minAge = 6,
	},
	{
		id = "learn_language",
		name = "Learn a Language",
		emoji = "🗣️",
		category = "Mind",
		effects = { Smarts = 6 },
		cost = 100,
		minAge = 10,
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
	{
		id = "nightclub",
		name = "Go Clubbing",
		emoji = "💃",
		category = "Fun",
		effects = { Happiness = 8, Health = -3, Looks = 2 },
		cost = 100,
		minAge = 21,
	},
	{
		id = "casino",
		name = "Visit Casino",
		emoji = "🎰",
		category = "Fun",
		effects = { Happiness = 5 },
		cost = 200,
		minAge = 21,
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
	{
		id = "dermatologist",
		name = "Dermatologist",
		emoji = "👨‍⚕️",
		category = "Beauty",
		effects = { Looks = 5, Health = 2 },
		cost = 200,
		minAge = 12,
	},
	-- Social activities
	{
		id = "volunteer",
		name = "Volunteer Work",
		emoji = "🤝",
		category = "Social",
		effects = { Happiness = 6, Smarts = 2 },
		cost = 0,
		minAge = 12,
	},
	{
		id = "date",
		name = "Go on a Date",
		emoji = "💕",
		category = "Social",
		effects = { Happiness = 7, Looks = 1 },
		cost = 100,
		minAge = 14,
	},
	{
		id = "family_dinner",
		name = "Family Dinner",
		emoji = "👨‍👩‍👧‍👦",
		category = "Social",
		effects = { Happiness = 5 },
		cost = 50,
		minAge = 5,
	},
}

local ActivitiesById = {}
for _, activity in ipairs(ActivitiesDatabase) do
	ActivitiesById[activity.id] = activity
end

----------------------------------------------------------------
-- EDUCATION DATABASE
----------------------------------------------------------------

local EducationDatabase = {
	{
		id = "elementary",
		name = "Elementary School",
		emoji = "🏫",
		type = "ElementarySchool",
		minAge = 5,
		maxAge = 10,
		yearsRequired = 5,
		cost = 0,
		smartsRequired = 0,
		smartsGain = 3,
	},
	{
		id = "middle_school",
		name = "Middle School",
		emoji = "🏫",
		type = "MiddleSchool",
		minAge = 11,
		maxAge = 13,
		yearsRequired = 3,
		cost = 0,
		smartsRequired = 0,
		smartsGain = 4,
	},
	{
		id = "high_school",
		name = "High School",
		emoji = "🎓",
		type = "HighSchool",
		minAge = 14,
		maxAge = 18,
		yearsRequired = 4,
		cost = 0,
		smartsRequired = 0,
		smartsGain = 5,
		completionTitle = "High School Diploma",
	},
	{
		id = "community_college",
		name = "Community College",
		emoji = "🏛️",
		type = "College",
		minAge = 18,
		maxAge = 99,
		yearsRequired = 2,
		cost = 5000,
		smartsRequired = 30,
		smartsGain = 8,
		completionTitle = "Associate's Degree",
	},
	{
		id = "state_university",
		name = "State University",
		emoji = "🎓",
		type = "College",
		minAge = 18,
		maxAge = 99,
		yearsRequired = 4,
		cost = 20000,
		smartsRequired = 50,
		smartsGain = 12,
		completionTitle = "Bachelor's Degree",
	},
	{
		id = "ivy_league",
		name = "Ivy League University",
		emoji = "🏆",
		type = "College",
		minAge = 18,
		maxAge = 99,
		yearsRequired = 4,
		cost = 60000,
		smartsRequired = 75,
		smartsGain = 15,
		completionTitle = "Bachelor's Degree (Honors)",
	},
	{
		id = "medical_school",
		name = "Medical School",
		emoji = "🩺",
		type = "GraduateSchool",
		minAge = 22,
		maxAge = 99,
		yearsRequired = 4,
		cost = 100000,
		smartsRequired = 80,
		requiresDegree = "College",
		smartsGain = 10,
		completionTitle = "Medical Degree (M.D.)",
	},
	{
		id = "law_school",
		name = "Law School",
		emoji = "⚖️",
		type = "GraduateSchool",
		minAge = 22,
		maxAge = 99,
		yearsRequired = 3,
		cost = 80000,
		smartsRequired = 70,
		requiresDegree = "College",
		smartsGain = 10,
		completionTitle = "Law Degree (J.D.)",
	},
	{
		id = "business_school",
		name = "Business School",
		emoji = "💼",
		type = "GraduateSchool",
		minAge = 22,
		maxAge = 99,
		yearsRequired = 2,
		cost = 70000,
		smartsRequired = 60,
		requiresDegree = "College",
		smartsGain = 8,
		completionTitle = "MBA",
	},
}

local EducationById = {}
for _, edu in ipairs(EducationDatabase) do
	EducationById[edu.id] = edu
end

----------------------------------------------------------------
-- ASSETS DATABASE
----------------------------------------------------------------

local VehiclesDatabase = {
	{ id = "bicycle", name = "Bicycle", emoji = "🚲", price = 500, minAge = 8 },
	{ id = "scooter", name = "Motor Scooter", emoji = "🛵", price = 2000, minAge = 16 },
	{ id = "used_car", name = "Used Car", emoji = "🚗", price = 8000, minAge = 16 },
	{ id = "sedan", name = "Sedan", emoji = "🚙", price = 25000, minAge = 18 },
	{ id = "suv", name = "SUV", emoji = "🚙", price = 45000, minAge = 18 },
	{ id = "sports_car", name = "Sports Car", emoji = "🏎️", price = 80000, minAge = 21 },
	{ id = "luxury_car", name = "Luxury Car", emoji = "🚘", price = 150000, minAge = 25 },
	{ id = "supercar", name = "Supercar", emoji = "🏎️", price = 500000, minAge = 25 },
	{ id = "motorcycle", name = "Motorcycle", emoji = "🏍️", price = 15000, minAge = 18 },
	{ id = "yacht", name = "Yacht", emoji = "🛥️", price = 1000000, minAge = 30 },
	{ id = "private_jet", name = "Private Jet", emoji = "✈️", price = 5000000, minAge = 30 },
}

local PropertiesDatabase = {
	{ id = "studio", name = "Studio Apartment", emoji = "🏢", price = 80000, minAge = 18 },
	{ id = "apartment", name = "2BR Apartment", emoji = "🏢", price = 150000, minAge = 18 },
	{ id = "condo", name = "Condo", emoji = "🏠", price = 250000, minAge = 21 },
	{ id = "house", name = "House", emoji = "🏡", price = 400000, minAge = 21 },
	{ id = "large_house", name = "Large House", emoji = "🏘️", price = 750000, minAge = 25 },
	{ id = "mansion", name = "Mansion", emoji = "🏰", price = 2000000, minAge = 30 },
	{ id = "penthouse", name = "Penthouse", emoji = "🌆", price = 3000000, minAge = 30 },
	{ id = "castle", name = "Castle", emoji = "🏰", price = 10000000, minAge = 35 },
}

----------------------------------------------------------------
-- PRISON ACTIONS DATABASE
----------------------------------------------------------------

local PrisonActionsDatabase = {
	{
		id = "behave",
		name = "Behave Well",
		emoji = "😇",
		description = "Be a model prisoner",
		effects = { Happiness = -2, Health = 1 },
		timeReduction = 0.1, -- 10% chance to reduce sentence by 1 year
	},
	{
		id = "workout",
		name = "Work Out",
		emoji = "💪",
		description = "Hit the prison gym",
		effects = { Health = 5, Looks = 2, Happiness = 2 },
		timeReduction = 0,
	},
	{
		id = "read",
		name = "Read Books",
		emoji = "📖",
		description = "Educate yourself in the library",
		effects = { Smarts = 5, Happiness = 2 },
		timeReduction = 0,
	},
	{
		id = "fight",
		name = "Start a Fight",
		emoji = "👊",
		description = "Pick a fight with another inmate",
		effects = { Health = -10, Happiness = -5 },
		timeReduction = -0.2, -- 20% chance to ADD time
		risky = true,
	},
	{
		id = "escape",
		name = "Attempt Escape",
		emoji = "🏃",
		description = "Try to break out",
		successChance = 0.15,
		effects = { Health = -5 },
		timeReduction = -0.5, -- 50% chance to add significant time if caught
		risky = true,
	},
	{
		id = "gang",
		name = "Join a Gang",
		emoji = "🔪",
		description = "Join a prison gang for protection",
		effects = { Happiness = 3, Health = -2 },
		timeReduction = 0,
	},
	{
		id = "therapy",
		name = "Attend Therapy",
		emoji = "🧠",
		description = "Work on self-improvement",
		effects = { Happiness = 5, Smarts = 2 },
		timeReduction = 0.05,
	},
}

----------------------------------------------------------------
-- STATE MANAGEMENT
----------------------------------------------------------------

local playerLives = {}  -- [Player] = LifeStateType

-- Expose for external access if needed
_G.GetPlayerLife = function(player)
	return playerLives[player]
end

_G.PushPlayerState = function(player, feedText)
	local state = playerLives[player]
	if state then
		pushState(player, state, feedText)
	end
end

local function serializeState(state)
	state:ClampStats()

	return {
		-- Basic info
		PlayerId = state.PlayerId,
		Name = state.Name,
		Gender = state.Gender,
		Age = state.Age,
		Year = state.Year,
		Money = state.Money,
		
		-- Stats
		Stats = state.Stats,
		Karma = state.Karma,
		Fame = state.Fame,
		
		-- Job
		Job = state.Job,
		
		-- Crime/Jail
		InJail = state.InJail,
		JailYearsLeft = state.JailYearsLeft,
		CrimeRecord = state.CrimeRecord,
		
		-- Education summary
		EducationLevel = state:GetEducationLevel(),
		CurrentSchool = state.Education.CurrentSchool,
		HighSchoolGraduate = state.Education.HighSchoolGraduate,
		CollegeGraduate = state.Education.CollegeGraduate,
		
		-- Relationships summary
		IsMarried = state:IsMarried(),
		PartnerName = state.Relationships.Partner and state.Relationships.Partner.name or nil,
		ChildCount = state:GetChildCount(),
		
		-- Assets summary
		VehicleCount = state:GetVehicleCount(),
		PropertyCount = state:GetPropertyCount(),
		TotalAssetValue = state.TotalAssetValue,
		NetWorth = state.NetWorth,
		
		-- Milestones
		Milestones = state.Milestones,
		
		-- Skills
		Skills = state.Skills,
	}
end

function pushState(player, state, lastFeedText)
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
	
	-- Education bonus
	local eduBonus = 0
	if state:HasDegree("Graduate") then
		eduBonus = 0.2
	elseif state:HasDegree("College") then
		eduBonus = 0.15
	elseif state:HasDegree("HighSchool") then
		eduBonus = 0.05
	end
	
	local successChance = math.min(0.95, baseChance + smartsBonus + looksBonus + happinessBonus + eduBonus)
	
	if math.random() < successChance then
		-- Track old job if switching
		if state.Job then
			table.insert(state.JobHistory, {
				job = state.Job,
				leftYear = state.Year,
			})
		end
		
		state.Job = {
			id = job.id,
			title = job.title,
			company = job.company,
			salary = job.salary,
			emoji = job.emoji,
			yearsWorked = 0,
			performance = 50,
		}
		
		-- First job milestone
		if not state.Milestones.FirstJob then
			state.Milestones.FirstJob = true
			state:AddMilestone("Got your first job!")
		end
		
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
	
	-- Track crime attempt
	state.YearlyActivities.CrimesThisYear = (state.YearlyActivities.CrimesThisYear or 0) + 1
	
	-- Attempt the crime
	local roll = math.random()
	
	-- Smarts bonus for success
	local smartsBonus = (state.Stats.Smarts or 50) / 500
	local effectiveChance = math.min(0.9, crime.successChance + smartsBonus)
	
	if roll < effectiveChance then
		-- Success!
		local payout = math.random(crime.minPayout, crime.maxPayout)
		state.Money = state.Money + payout
		state.CrimeRecord = (state.CrimeRecord or 0) + 1
		state.Stats.Happiness = (state.Stats.Happiness or 50) + 5
		state.Notoriety = (state.Notoriety or 0) + 5
		state.Karma = (state.Karma or 50) - 5
		
		table.insert(state.CrimesCommitted, {
			crimeId = crime.id,
			year = state.Year,
			caught = false,
			payout = payout,
		})
		
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
		state.Notoriety = (state.Notoriety or 0) + 10
		state.Karma = (state.Karma or 50) - 10
		
		table.insert(state.CrimesCommitted, {
			crimeId = crime.id,
			year = state.Year,
			caught = true,
			sentence = crime.jailYears,
		})
		
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
	
	-- Track activity counters
	if activityId == "gym" then
		state.YearlyActivities.GymVisits = (state.YearlyActivities.GymVisits or 0) + 1
		state:ImproveSkill("Fitness", 2)
	elseif activityId == "library" then
		state.YearlyActivities.LibraryVisits = (state.YearlyActivities.LibraryVisits or 0) + 1
	elseif activityId == "party" then
		state.YearlyActivities.PartyAttendances = (state.YearlyActivities.PartyAttendances or 0) + 1
	elseif activityId == "date" then
		state.YearlyActivities.DatesThisYear = (state.YearlyActivities.DatesThisYear or 0) + 1
	elseif activityId == "martial_arts" then
		state:ImproveSkill("Martial_Arts", 3)
	elseif activityId == "meditate" then
		state.Willpower = (state.Willpower or 50) + 2
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
-- EDUCATION FUNCTIONS
----------------------------------------------------------------

local function getAvailableEducation(player)
	local state = getLife(player)
	local options = {}
	
	for _, edu in ipairs(EducationDatabase) do
		local canEnroll = state.Age >= edu.minAge 
			and state.Age <= (edu.maxAge or 99)
			and (state.Stats.Smarts or 0) >= edu.smartsRequired
			and state.Money >= edu.cost
			and not state.InJail
			and not state.Education.CurrentSchool
		
		-- Check prerequisite degree
		if edu.requiresDegree and not state:HasDegree(edu.requiresDegree) then
			canEnroll = false
		end
		
		-- Already completed this level
		if edu.type == "HighSchool" and state.Education.HighSchoolGraduate then
			canEnroll = false
		end
		if edu.type == "College" and state.Education.CollegeGraduate then
			canEnroll = false
		end
		
		table.insert(options, {
			id = edu.id,
			name = edu.name,
			emoji = edu.emoji,
			type = edu.type,
			yearsRequired = edu.yearsRequired,
			cost = edu.cost,
			smartsRequired = edu.smartsRequired,
			completionTitle = edu.completionTitle,
			canEnroll = canEnroll,
		})
	end
	
	return options
end

local function enrollEducation(player, educationId)
	local state = getLife(player)
	
	if not state.Name then
		return { success = false, message = "You haven't started your life yet!" }
	end
	
	if state.InJail then
		return { success = false, message = "You can't enroll while in jail!" }
	end
	
	if state.Education.CurrentSchool then
		return { success = false, message = "You're already enrolled in school!" }
	end
	
	local edu = EducationById[educationId]
	if not edu then
		return { success = false, message = "Education option not found." }
	end
	
	if state.Age < edu.minAge or state.Age > (edu.maxAge or 99) then
		return { success = false, message = "You're not the right age for this." }
	end
	
	if (state.Stats.Smarts or 0) < edu.smartsRequired then
		return { success = false, message = string.format("You need at least %d%% Smarts.", edu.smartsRequired) }
	end
	
	if state.Money < edu.cost then
		return { success = false, message = string.format("You need $%d to enroll.", edu.cost) }
	end
	
	if edu.requiresDegree and not state:HasDegree(edu.requiresDegree) then
		return { success = false, message = "You need a prerequisite degree." }
	end
	
	-- Enroll
	state.Money = state.Money - edu.cost
	state.Education.CurrentSchool = {
		id = edu.id,
		name = edu.name,
		type = edu.type,
		yearsCompleted = 0,
		yearsRequired = edu.yearsRequired,
		gpa = 3.0,
		smartsGain = edu.smartsGain,
		completionTitle = edu.completionTitle,
	}
	
	local feedText = string.format("📚 You enrolled in %s!", edu.name)
	state:AddFeed(feedText)
	pushState(player, state, feedText)
	
	return { success = true, message = string.format("Welcome to %s!", edu.name) }
end

----------------------------------------------------------------
-- PRISON FUNCTIONS
----------------------------------------------------------------

local function getAvailablePrisonActions(player)
	local state = getLife(player)
	
	if not state.InJail then
		return {}
	end
	
	local actions = {}
	for _, action in ipairs(PrisonActionsDatabase) do
		table.insert(actions, {
			id = action.id,
			name = action.name,
			emoji = action.emoji,
			description = action.description,
			risky = action.risky or false,
		})
	end
	
	return actions
end

local function doPrisonActionInternal(player, actionId)
	local state = getLife(player)
	
	if not state.InJail then
		return { success = false, message = "You're not in prison!" }
	end
	
	local action = nil
	for _, a in ipairs(PrisonActionsDatabase) do
		if a.id == actionId then
			action = a
			break
		end
	end
	
	if not action then
		return { success = false, message = "Action not found." }
	end
	
	-- Apply effects
	if action.effects then
		for stat, change in pairs(action.effects) do
			if state.Stats[stat] ~= nil then
				state.Stats[stat] = state.Stats[stat] + change
			end
		end
	end
	
	local feedText = string.format("%s %s", action.emoji, action.name)
	local resultMessage = "You did: " .. action.name
	
	-- Special handling for escape attempt
	if action.id == "escape" then
		if math.random() < (action.successChance or 0.1) then
			state.InJail = false
			state.JailYearsLeft = 0
			state.Notoriety = (state.Notoriety or 0) + 20
			feedText = "🏃 You escaped from prison!"
			resultMessage = "You successfully escaped! You're on the run!"
		else
			-- Failed escape - add time
			local addedYears = math.random(2, 5)
			state.JailYearsLeft = (state.JailYearsLeft or 0) + addedYears
			state.Stats.Health = (state.Stats.Health or 50) - 10
			feedText = string.format("🚨 Escape failed! %d years added to sentence.", addedYears)
			resultMessage = string.format("Caught! %d years added.", addedYears)
		end
	elseif action.id == "fight" then
		if math.random() < 0.5 then
			-- Lost fight
			state.Stats.Health = (state.Stats.Health or 50) - 15
			feedText = "👊 You lost the fight badly."
			resultMessage = "You got beat up pretty bad."
		else
			-- Won fight
			state.Notoriety = (state.Notoriety or 0) + 5
			feedText = "👊 You won the fight!"
			resultMessage = "You showed them who's boss!"
		end
	elseif action.timeReduction and action.timeReduction > 0 then
		-- Chance for time reduction
		if math.random() < action.timeReduction then
			state.JailYearsLeft = math.max(0, (state.JailYearsLeft or 1) - 1)
			feedText = feedText .. " Your good behavior was noticed!"
			resultMessage = resultMessage .. " (Sentence reduced!)"
		end
	end
	
	state:ClampStats()
	state:AddFeed(feedText)
	pushState(player, state, feedText)
	
	return { success = true, message = resultMessage }
end

----------------------------------------------------------------
-- ASSETS FUNCTIONS
----------------------------------------------------------------

local function getAvailableAssets(player)
	local state = getLife(player)
	
	local result = {
		vehicles = {},
		properties = {},
		owned = {
			vehicles = state.Assets.Vehicles,
			properties = state.Assets.Properties,
		}
	}
	
	for _, v in ipairs(VehiclesDatabase) do
		local canBuy = state.Age >= v.minAge and state.Money >= v.price and not state.InJail
		table.insert(result.vehicles, {
			id = v.id,
			name = v.name,
			emoji = v.emoji,
			price = v.price,
			minAge = v.minAge,
			canBuy = canBuy,
		})
	end
	
	for _, p in ipairs(PropertiesDatabase) do
		local canBuy = state.Age >= p.minAge and state.Money >= p.price and not state.InJail
		table.insert(result.properties, {
			id = p.id,
			name = p.name,
			emoji = p.emoji,
			price = p.price,
			minAge = p.minAge,
			canBuy = canBuy,
		})
	end
	
	return result
end

local function buyAssetInternal(player, assetType, assetId)
	local state = getLife(player)
	
	if not state.Name then
		return { success = false, message = "You haven't started your life yet!" }
	end
	
	if state.InJail then
		return { success = false, message = "You can't buy assets while in jail!" }
	end
	
	local database = assetType == "vehicle" and VehiclesDatabase or PropertiesDatabase
	local asset = nil
	
	for _, a in ipairs(database) do
		if a.id == assetId then
			asset = a
			break
		end
	end
	
	if not asset then
		return { success = false, message = "Asset not found." }
	end
	
	if state.Age < asset.minAge then
		return { success = false, message = "You're too young to buy this." }
	end
	
	if state.Money < asset.price then
		return { success = false, message = string.format("You need $%d to buy this.", asset.price) }
	end
	
	-- Purchase
	state.Money = state.Money - asset.price
	
	local newAsset = {
		id = asset.id,
		name = asset.name,
		emoji = asset.emoji,
		value = asset.price,
		purchaseYear = state.Year,
		condition = 100,
	}
	
	if assetType == "vehicle" then
		table.insert(state.Assets.Vehicles, newAsset)
		if not state.Milestones.FirstCar then
			state.Milestones.FirstCar = true
			state:AddMilestone("Bought your first car!")
		end
	else
		newAsset.type = "Property"
		table.insert(state.Assets.Properties, newAsset)
		state.LivingSituation = "Own Home"
		if not state.Milestones.FirstHome then
			state.Milestones.FirstHome = true
			state:AddMilestone("Bought your first home!")
		end
	end
	
	state:RecalculateAssetValue()
	
	local feedText = string.format("%s You bought a %s for $%d!", asset.emoji, asset.name, asset.price)
	state:AddFeed(feedText)
	pushState(player, state, feedText)
	
	return { success = true, message = string.format("Congratulations on your new %s!", asset.name) }
end

local function sellAssetInternal(player, assetType, assetIndex)
	local state = getLife(player)
	
	if not state.Name then
		return { success = false, message = "You haven't started your life yet!" }
	end
	
	local assetList = assetType == "vehicle" and state.Assets.Vehicles or state.Assets.Properties
	
	if assetIndex < 1 or assetIndex > #assetList then
		return { success = false, message = "Asset not found." }
	end
	
	local asset = assetList[assetIndex]
	local sellValue = math.floor(asset.value * 0.8) -- 80% of value
	
	state.Money = state.Money + sellValue
	table.remove(assetList, assetIndex)
	state:RecalculateAssetValue()
	
	-- Update living situation if sold home
	if assetType == "property" and #state.Assets.Properties == 0 then
		state.LivingSituation = "Renting"
	end
	
	local feedText = string.format("💵 You sold your %s for $%d!", asset.name, sellValue)
	state:AddFeed(feedText)
	pushState(player, state, feedText)
	
	return { success = true, message = string.format("Sold for $%d!", sellValue) }
end

----------------------------------------------------------------
-- RELATIONSHIPS FUNCTIONS
----------------------------------------------------------------

local function getRelationshipsInfo(player)
	local state = getLife(player)
	
	return {
		partner = state.Relationships.Partner,
		friends = state.Relationships.Friends,
		enemies = state.Relationships.Enemies,
		children = state.Relationships.Children,
		father = state.Relationships.Father,
		mother = state.Relationships.Mother,
		siblings = state.Relationships.Siblings,
		totalRelationships = state.Relationships.TotalRelationships,
		totalMarriages = state.Relationships.TotalMarriages,
		totalDivorces = state.Relationships.TotalDivorces,
	}
end

----------------------------------------------------------------
-- PLAYER HANDLERS
----------------------------------------------------------------

Players.PlayerAdded:Connect(function(player)
	local state = createNewLife(player)
	
	-- Generate family
	state.Relationships.Father = {
		name = EventLibrary.RandomName("Male") .. " " .. (state.Name and state.Name:match("%w+$") or "Smith"),
		age = math.random(25, 40),
		relationship = 70,
		alive = true,
		health = math.random(60, 90),
	}
	
	state.Relationships.Mother = {
		name = EventLibrary.RandomName("Female") .. " " .. (state.Name and state.Name:match("%w+$") or "Smith"),
		age = math.random(23, 38),
		relationship = 75,
		alive = true,
		health = math.random(60, 90),
	}
	
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

	-- Update family last names
	local lastName = safeName:match("%s(%w+)$") or "Smith"
	if state.Relationships.Father then
		state.Relationships.Father.name = state.Relationships.Father.name:match("^(%w+)") .. " " .. lastName
	end
	if state.Relationships.Mother then
		state.Relationships.Mother.name = state.Relationships.Mother.name:match("^(%w+)") .. " " .. lastName
	end

	local welcomeText = "🎉 Welcome to BloxLife!"
	local bornText = string.format("👶 You were born as %s.", state.Name)

	state:AddFeed(welcomeText)
	state:AddFeed(bornText)
	state:AddMilestone("Born into the world!")

	pushState(player, state, bornText)
end)

----------------------------------------------------------------
-- AGE UP
----------------------------------------------------------------

local function processYearlyChanges(state)
	-- Increment years worked at current job
	if state.Job then
		state.Job.yearsWorked = (state.Job.yearsWorked or 0) + 1
	end
	
	-- Progress education
	if state.Education.CurrentSchool then
		local school = state.Education.CurrentSchool
		school.yearsCompleted = (school.yearsCompleted or 0) + 1
		
		-- Add smarts
		state.Stats.Smarts = (state.Stats.Smarts or 50) + (school.smartsGain or 3)
		
		-- Check graduation
		if school.yearsCompleted >= school.yearsRequired then
			-- Graduate!
			if school.type == "HighSchool" then
				state.Education.HighSchoolGraduate = true
				state.Education.HighSchoolGPA = school.gpa
			elseif school.type == "College" then
				state.Education.CollegeGraduate = true
				state.Education.CollegeDegree = school.completionTitle
			elseif school.type == "GraduateSchool" then
				state.Education.GraduateDegree = school.completionTitle
			end
			
			local gradText = string.format("🎓 You graduated from %s!", school.name)
			if school.completionTitle then
				gradText = gradText .. string.format(" You earned your %s!", school.completionTitle)
			end
			state:AddFeed(gradText)
			state:AddMilestone("Graduated from " .. school.name)
			
			state.Education.CurrentSchool = nil
		end
	end
	
	-- Age family members
	if state.Relationships.Father and state.Relationships.Father.alive then
		state.Relationships.Father.age = state.Relationships.Father.age + 1
		-- Chance of death after 60
		if state.Relationships.Father.age > 60 then
			local deathChance = (state.Relationships.Father.age - 60) / 100
			if math.random() < deathChance then
				state.Relationships.Father.alive = false
				state:AddFeed("😢 Your father passed away at age " .. state.Relationships.Father.age)
				state.Stats.Happiness = (state.Stats.Happiness or 50) - 15
			end
		end
	end
	
	if state.Relationships.Mother and state.Relationships.Mother.alive then
		state.Relationships.Mother.age = state.Relationships.Mother.age + 1
		if state.Relationships.Mother.age > 65 then
			local deathChance = (state.Relationships.Mother.age - 65) / 100
			if math.random() < deathChance then
				state.Relationships.Mother.alive = false
				state:AddFeed("😢 Your mother passed away at age " .. state.Relationships.Mother.age)
				state.Stats.Happiness = (state.Stats.Happiness or 50) - 15
			end
		end
	end
	
	-- Depreciate asset values slightly
	for _, vehicle in ipairs(state.Assets.Vehicles) do
		vehicle.value = math.floor(vehicle.value * 0.95) -- 5% depreciation
		vehicle.condition = math.max(50, (vehicle.condition or 100) - 2)
	end
	
	-- Reset yearly counters
	state:ResetYearlyCounters()
end

local function ageUp(player)
	local state = getLife(player)

	if not state.Name then
		return
	end

	-- Handle jail time
	if state.InJail then
		state.JailYearsLeft = (state.JailYearsLeft or 1) - 1
		state.TotalTimeServed = (state.TotalTimeServed or 0) + 1
		
		if state.JailYearsLeft <= 0 then
			state.InJail = false
			state.JailYearsLeft = 0
			local releaseText = "🔓 You've been released from prison!"
			state:AddFeed(releaseText)
			state:AddMilestone("Released from prison")
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
		
		-- Performance bonus
		local performance = state.Job.performance or 50
		local bonus = math.floor(salary * (performance / 500)) -- Up to 20% bonus
		local totalPay = salary + bonus
		
		state.Money = state.Money + totalPay
		state.TotalEarnings = (state.TotalEarnings or 0) + totalPay
		state.YearsEmployed = (state.YearsEmployed or 0) + 1
		
		local payText = string.format("💰 You earned $%d from your job as %s.", totalPay, state.Job.title)
		state:AddFeed(payText)
	end

	-- Process yearly changes
	processYearlyChanges(state)

	-- Natural stat changes with age
	if state.Age > 30 then
		-- Health slowly declines after 30
		local healthDecline = math.floor((state.Age - 30) / 10)
		state.Stats.Health = (state.Stats.Health or 50) - healthDecline
	end
	
	if state.Age > 40 then
		-- Looks decline after 40
		local looksDecline = math.floor((state.Age - 40) / 15)
		state.Stats.Looks = (state.Stats.Looks or 50) - looksDecline
	end

	state:ClampStats()

	local ageText
	if state.Age == 1 then
		ageText = "🎂 You are now 1 year old."
	else
		ageText = string.format("🎂 You are now %d years old.", state.Age)
	end

	state:AddFeed(ageText)

	-- Decide if a life event should fire
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
		
		-- Add to job history
		table.insert(state.JobHistory, {
			job = state.Job,
			leftYear = state.Year,
			reason = "Quit",
		})
		
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

----------------------------------------------------------------
-- EDUCATION HANDLERS
----------------------------------------------------------------

GetEducation.OnServerInvoke = function(player)
	return getAvailableEducation(player)
end

EnrollEducation.OnServerInvoke = function(player, educationId)
	return enrollEducation(player, educationId)
end

DropOut.OnServerEvent:Connect(function(player)
	local state = getLife(player)
	if state.Education.CurrentSchool then
		local schoolName = state.Education.CurrentSchool.name
		state.Education.CurrentSchool = nil
		local feedText = string.format("📚 You dropped out of %s.", schoolName)
		state:AddFeed(feedText)
		pushState(player, state, feedText)
	end
end)

----------------------------------------------------------------
-- PRISON HANDLERS
----------------------------------------------------------------

GetPrisonActions.OnServerInvoke = function(player)
	return getAvailablePrisonActions(player)
end

DoPrisonAction.OnServerInvoke = function(player, actionId)
	return doPrisonActionInternal(player, actionId)
end

----------------------------------------------------------------
-- ASSETS HANDLERS
----------------------------------------------------------------

GetAssets.OnServerInvoke = function(player)
	return getAvailableAssets(player)
end

BuyAsset.OnServerInvoke = function(player, assetType, assetId)
	return buyAssetInternal(player, assetType, assetId)
end

SellAsset.OnServerInvoke = function(player, assetType, assetIndex)
	return sellAssetInternal(player, assetType, assetIndex)
end

----------------------------------------------------------------
-- RELATIONSHIPS HANDLERS
----------------------------------------------------------------

GetRelationships.OnServerInvoke = function(player)
	return getRelationshipsInfo(player)
end
