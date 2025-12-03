-- CareerLibrary.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- AAA-TIER CAREER DEFINITIONS - AUTOMOTIVE/RACING CAREER PATH
-- ═══════════════════════════════════════════════════════════════════════════════
-- 
-- This is ONE career done EXTREMELY well with:
-- - 8 distinct branches (Street Racing, NASCAR, F1, Rally, Mechanic, Dealer, Designer, Crime)
-- - 40+ unique tier positions
-- - Deep trait integration
-- - Interconnected event triggers
-- - Realistic income progression
-- - Consequence-based unlocks
--
-- ═══════════════════════════════════════════════════════════════════════════════

local CareerLibrary = {}

-- ═══════════════════════════════════════════════════════════════════════════════
-- AUTOMOTIVE/RACING CAREER - THE ULTIMATE SPEED PATH
-- ═══════════════════════════════════════════════════════════════════════════════

CareerLibrary["automotive"] = {
	id = "automotive",
	label = "Automotive Career",
	emoji = "🏎️",
	category = "automotive",
	description = "From toy cars to the world stage - every path involving vehicles, speed, and machines.",
	
	-- Origin events that can spark this career
	originEventIds = {
		"childhood_toy_cars",           -- Age 0-3: Playing with toy cars
		"childhood_go_kart",            -- Age 4-8: First go-kart experience
		"childhood_dads_garage",        -- Age 5-12: Helping in garage
		"teen_first_car_obsession",     -- Age 13-16: Car magazines, posters
		"teen_driving_lessons",         -- Age 15-17: Learning to drive
	},
	
	-- BRANCHES: Each represents a completely different life path
	branches = {
		-- LEGAL RACING PATHS
		"street_racer",      -- Underground racing scene (semi-legal)
		"nascar_driver",     -- American stock car racing
		"formula_one",       -- International open-wheel racing
		"rally_driver",      -- Off-road/rally racing
		"drag_racer",        -- Quarter-mile specialists
		
		-- AUTOMOTIVE INDUSTRY PATHS
		"mechanic",          -- Working on cars
		"car_dealer",        -- Selling cars
		"automotive_engineer", -- Designing cars
		"racing_team_owner", -- Owning a racing team
		
		-- DARK PATHS
		"car_thief",         -- Stealing cars
		"chop_shop",         -- Running an illegal operation
		"getaway_driver",    -- Crime support
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- TRAIT REQUIREMENTS & UNLOCKS
	-- ═══════════════════════════════════════════════════════════════
	
	traitRequirements = {
		-- Some branches require specific childhood traits
		formula_one = {"racer_interest", "mechanical_aptitude"},
		automotive_engineer = {"mechanical_aptitude", "high_intelligence"},
		rally_driver = {"racer_interest", "thrill_seeker"},
	},
	
	traitUnlocks = {
		-- Traits you can gain from this career
		"speed_demon",
		"reckless_driver", 
		"good_driver",
		"mechanical_genius",
		"adrenaline_junkie",
		"petrolhead",
		"notorious_racer",
		"racing_legend",
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- TIERS: Every position you can hold across all branches
	-- ═══════════════════════════════════════════════════════════════
	
	tiers = {
		-- ═══════════════════════════════════════════════════════════
		-- CHILDHOOD/TEEN FOUNDATION (No branch yet - pure passion building)
		-- ═══════════════════════════════════════════════════════════
		
		{
			id = "car_enthusiast_kid",
			label = "Car Enthusiast Kid",
			description = "You dream about cars constantly",
			minAge = 5,
			maxAge = 12,
			branch = nil, -- No branch yet
			baseIncome = {min = 0, max = 0},
			eventTags = {"car_kid", "passion_building", "childhood_auto"},
			requirements = {
				traits = {"racer_interest"},
			},
		},
		
		{
			id = "go_kart_racer",
			label = "Go-Kart Racer",
			description = "Competitive karting at the local track",
			minAge = 8,
			maxAge = 16,
			branch = nil,
			baseIncome = {min = 0, max = 5000}, -- Prize money
			eventTags = {"karting", "junior_racing", "competition"},
			requirements = {
				traits = {"racer_interest"},
				minStats = {Smarts = 20},
			},
			unlocksTiers = {"junior_formula", "street_racing_initiate"},
		},
		
		{
			id = "garage_apprentice",
			label = "Garage Apprentice", 
			description = "Learning the basics of car mechanics",
			minAge = 12,
			maxAge = 18,
			branch = nil,
			baseIncome = {min = 0, max = 8000},
			eventTags = {"mechanic_basics", "hands_on", "garage_life"},
			requirements = {
				traits = {"mechanical_aptitude"},
			},
			unlocksTiers = {"apprentice_mechanic", "automotive_student"},
		},
		
		-- ═══════════════════════════════════════════════════════════
		-- STREET RACING BRANCH (Underground, semi-legal, high risk)
		-- ═══════════════════════════════════════════════════════════
		
		{
			id = "street_racing_initiate",
			label = "Street Racing Initiate",
			description = "Your first taste of illegal street racing",
			minAge = 16,
			maxAge = 25,
			branch = "street_racer",
			baseIncome = {min = 0, max = 15000}, -- Betting winnings
			eventTags = {"street_racing", "underground", "illegal_racing", "adrenaline"},
			requirements = {
				flags = {"has_car", "can_drive"},
				traits = {"racer_interest"},
			},
			risks = {
				arrest_chance = 0.15,
				crash_chance = 0.20,
				injury_chance = 0.10,
			},
		},
		
		{
			id = "street_racing_regular",
			label = "Street Racing Regular",
			description = "Known face at the underground meets",
			minAge = 17,
			maxAge = 35,
			branch = "street_racer",
			baseIncome = {min = 10000, max = 50000},
			eventTags = {"street_racing", "underground", "reputation_building"},
			requirements = {
				prevTier = "street_racing_initiate",
				minStats = {Smarts = 30},
			},
			risks = {
				arrest_chance = 0.20,
				crash_chance = 0.15,
				injury_chance = 0.12,
			},
		},
		
		{
			id = "street_racing_king",
			label = "Street Racing King",
			description = "The one everyone wants to beat",
			minAge = 20,
			maxAge = 40,
			branch = "street_racer",
			baseIncome = {min = 50000, max = 200000},
			eventTags = {"street_legend", "underground_fame", "high_stakes"},
			requirements = {
				prevTier = "street_racing_regular",
				minStats = {Smarts = 40},
				minReputation = 50,
			},
			unlocks = {
				traits = {"notorious_racer", "speed_demon"},
				flags = {"street_racing_legend"},
			},
			risks = {
				arrest_chance = 0.25,
				crash_chance = 0.10,
				death_chance = 0.02,
			},
		},
		
		{
			id = "street_racing_boss",
			label = "Street Racing Organizer",
			description = "You run the underground racing scene",
			minAge = 25,
			maxAge = 50,
			branch = "street_racer",
			baseIncome = {min = 100000, max = 500000},
			eventTags = {"racing_boss", "underground_empire", "criminal_enterprise"},
			requirements = {
				prevTier = "street_racing_king",
				minStats = {Smarts = 50, Charisma = 40},
			},
			unlocks = {
				flags = {"crime_boss", "underground_empire"},
			},
			risks = {
				arrest_chance = 0.30,
				assassination_chance = 0.05,
			},
		},
		
		-- ═══════════════════════════════════════════════════════════
		-- NASCAR BRANCH (American Stock Car Racing)
		-- ═══════════════════════════════════════════════════════════
		
		{
			id = "junior_formula",
			label = "Junior Formula Driver",
			description = "Competing in feeder series",
			minAge = 16,
			maxAge = 22,
			branch = "nascar_driver",
			baseIncome = {min = 10000, max = 50000},
			eventTags = {"junior_racing", "feeder_series", "proving_grounds"},
			requirements = {
				traits = {"racer_interest"},
				minStats = {Smarts = 35},
			},
		},
		
		{
			id = "nascar_rookie",
			label = "NASCAR Rookie",
			description = "Fresh face on the oval",
			minAge = 18,
			maxAge = 28,
			branch = "nascar_driver",
			baseIncome = {min = 50000, max = 150000},
			eventTags = {"nascar", "oval_racing", "stock_car"},
			requirements = {
				prevTier = "junior_formula",
				minStats = {Smarts = 40},
			},
			risks = {
				crash_chance = 0.25,
				injury_chance = 0.15,
			},
		},
		
		{
			id = "nascar_midpack",
			label = "NASCAR Driver",
			description = "Solid midpack competitor",
			minAge = 20,
			maxAge = 40,
			branch = "nascar_driver",
			baseIncome = {min = 200000, max = 500000},
			eventTags = {"nascar", "professional_racing", "endurance"},
			requirements = {
				prevTier = "nascar_rookie",
			},
			risks = {
				crash_chance = 0.20,
				injury_chance = 0.12,
			},
		},
		
		{
			id = "nascar_contender",
			label = "NASCAR Championship Contender",
			description = "Fighting for the title every season",
			minAge = 24,
			maxAge = 45,
			branch = "nascar_driver",
			baseIncome = {min = 1000000, max = 5000000},
			eventTags = {"nascar_elite", "championship", "fame"},
			requirements = {
				prevTier = "nascar_midpack",
				minStats = {Smarts = 50},
				minReputation = 60,
			},
			unlocks = {
				traits = {"racing_celebrity"},
				flags = {"famous", "sports_star"},
			},
		},
		
		{
			id = "nascar_champion",
			label = "NASCAR Champion",
			description = "The pinnacle of American racing",
			minAge = 26,
			maxAge = 50,
			branch = "nascar_driver",
			baseIncome = {min = 5000000, max = 20000000},
			eventTags = {"nascar_legend", "champion", "hall_of_fame"},
			requirements = {
				prevTier = "nascar_contender",
				achievements = {"won_championship"},
			},
			unlocks = {
				traits = {"racing_legend"},
				flags = {"hall_of_fame", "national_icon"},
			},
		},
		
		-- ═══════════════════════════════════════════════════════════
		-- FORMULA ONE BRANCH (International Elite Racing)
		-- ═══════════════════════════════════════════════════════════
		
		{
			id = "f1_junior_program",
			label = "F1 Junior Program Driver",
			description = "In an F1 team's development program",
			minAge = 16,
			maxAge = 21,
			branch = "formula_one",
			baseIncome = {min = 50000, max = 200000},
			eventTags = {"f1_academy", "elite_racing", "international"},
			requirements = {
				prevTier = "go_kart_racer",
				traits = {"racer_interest", "mechanical_aptitude"},
				minStats = {Smarts = 50},
			},
		},
		
		{
			id = "f2_driver",
			label = "Formula 2 Driver",
			description = "One step away from F1",
			minAge = 17,
			maxAge = 24,
			branch = "formula_one",
			baseIncome = {min = 100000, max = 500000},
			eventTags = {"f2", "feeder_series", "f1_path"},
			requirements = {
				prevTier = "f1_junior_program",
			},
		},
		
		{
			id = "f1_reserve",
			label = "F1 Reserve Driver",
			description = "Waiting for your chance",
			minAge = 18,
			maxAge = 30,
			branch = "formula_one",
			baseIncome = {min = 500000, max = 2000000},
			eventTags = {"f1_reserve", "waiting", "simulator"},
			requirements = {
				prevTier = "f2_driver",
				minStats = {Smarts = 55},
			},
		},
		
		{
			id = "f1_backmarker",
			label = "F1 Driver (Backmarker Team)",
			description = "Fighting for points in a slow car",
			minAge = 19,
			maxAge = 35,
			branch = "formula_one",
			baseIncome = {min = 1000000, max = 5000000},
			eventTags = {"f1", "formula_one", "backmarker"},
			requirements = {
				prevTier = "f1_reserve",
			},
			risks = {
				crash_chance = 0.15,
				injury_chance = 0.08,
			},
		},
		
		{
			id = "f1_midfield",
			label = "F1 Driver (Midfield Team)",
			description = "Regularly scoring points",
			minAge = 20,
			maxAge = 38,
			branch = "formula_one",
			baseIncome = {min = 5000000, max = 15000000},
			eventTags = {"f1", "formula_one", "competitive"},
			requirements = {
				prevTier = "f1_backmarker",
				minReputation = 40,
			},
		},
		
		{
			id = "f1_top_team",
			label = "F1 Driver (Top Team)",
			description = "Fighting for wins every race",
			minAge = 22,
			maxAge = 40,
			branch = "formula_one",
			baseIncome = {min = 15000000, max = 50000000},
			eventTags = {"f1_elite", "race_winner", "world_famous"},
			requirements = {
				prevTier = "f1_midfield",
				minReputation = 70,
			},
			unlocks = {
				traits = {"racing_celebrity"},
				flags = {"world_famous", "sports_icon"},
			},
		},
		
		{
			id = "f1_world_champion",
			label = "F1 World Champion",
			description = "The absolute peak of motorsport",
			minAge = 23,
			maxAge = 42,
			branch = "formula_one",
			baseIncome = {min = 30000000, max = 100000000},
			eventTags = {"f1_champion", "legend", "immortal"},
			requirements = {
				prevTier = "f1_top_team",
				achievements = {"won_f1_championship"},
			},
			unlocks = {
				traits = {"racing_legend", "living_legend"},
				flags = {"f1_champion", "immortalized"},
			},
		},
		
		-- ═══════════════════════════════════════════════════════════
		-- MECHANIC BRANCH (Working on Cars)
		-- ═══════════════════════════════════════════════════════════
		
		{
			id = "apprentice_mechanic",
			label = "Apprentice Mechanic",
			description = "Learning the trade",
			minAge = 16,
			maxAge = 25,
			branch = "mechanic",
			baseIncome = {min = 15000, max = 30000},
			eventTags = {"mechanic", "apprentice", "garage"},
			requirements = {
				traits = {"mechanical_aptitude"},
			},
		},
		
		{
			id = "certified_mechanic",
			label = "Certified Mechanic",
			description = "Fully qualified to work on cars",
			minAge = 19,
			maxAge = 65,
			branch = "mechanic",
			baseIncome = {min = 35000, max = 60000},
			eventTags = {"mechanic", "certified", "professional"},
			requirements = {
				prevTier = "apprentice_mechanic",
			},
		},
		
		{
			id = "master_mechanic",
			label = "Master Mechanic",
			description = "Expert-level skills",
			minAge = 25,
			maxAge = 70,
			branch = "mechanic",
			baseIncome = {min = 60000, max = 100000},
			eventTags = {"master_mechanic", "expert", "specialty"},
			requirements = {
				prevTier = "certified_mechanic",
				minStats = {Smarts = 50},
			},
		},
		
		{
			id = "shop_owner",
			label = "Auto Shop Owner",
			description = "Running your own garage",
			minAge = 28,
			maxAge = 75,
			branch = "mechanic",
			baseIncome = {min = 80000, max = 300000},
			eventTags = {"business_owner", "auto_shop", "entrepreneur"},
			requirements = {
				prevTier = "master_mechanic",
				minStats = {Smarts = 55, Charisma = 40},
			},
		},
		
		{
			id = "racing_team_mechanic",
			label = "Racing Team Mechanic",
			description = "Working on race cars",
			minAge = 22,
			maxAge = 55,
			branch = "mechanic",
			baseIncome = {min = 70000, max = 150000},
			eventTags = {"racing_crew", "pit_crew", "high_performance"},
			requirements = {
				prevTier = "certified_mechanic",
				minStats = {Smarts = 55},
				flags = {"racing_connection"},
			},
		},
		
		{
			id = "f1_pit_crew_chief",
			label = "F1 Pit Crew Chief",
			description = "Leading an elite racing team's garage",
			minAge = 30,
			maxAge = 60,
			branch = "mechanic",
			baseIncome = {min = 200000, max = 500000},
			eventTags = {"f1_crew", "elite_mechanic", "leadership"},
			requirements = {
				prevTier = "racing_team_mechanic",
				minStats = {Smarts = 65, Charisma = 50},
			},
		},
		
		-- ═══════════════════════════════════════════════════════════
		-- CAR DEALER BRANCH (Selling Cars)
		-- ═══════════════════════════════════════════════════════════
		
		{
			id = "car_salesman",
			label = "Car Salesman",
			description = "Selling cars at a dealership",
			minAge = 18,
			maxAge = 70,
			branch = "car_dealer",
			baseIncome = {min = 30000, max = 80000},
			eventTags = {"sales", "dealership", "commission"},
			requirements = {
				minStats = {Charisma = 40},
			},
		},
		
		{
			id = "senior_salesman",
			label = "Senior Sales Associate",
			description = "Top seller at the lot",
			minAge = 22,
			maxAge = 65,
			branch = "car_dealer",
			baseIncome = {min = 60000, max = 150000},
			eventTags = {"sales", "top_performer", "luxury"},
			requirements = {
				prevTier = "car_salesman",
				minStats = {Charisma = 55},
			},
		},
		
		{
			id = "dealership_manager",
			label = "Dealership Manager",
			description = "Running the show",
			minAge = 28,
			maxAge = 70,
			branch = "car_dealer",
			baseIncome = {min = 100000, max = 250000},
			eventTags = {"management", "dealership", "leadership"},
			requirements = {
				prevTier = "senior_salesman",
				minStats = {Charisma = 60, Smarts = 50},
			},
		},
		
		{
			id = "dealership_owner",
			label = "Dealership Owner",
			description = "Multiple locations, serious money",
			minAge = 35,
			maxAge = 80,
			branch = "car_dealer",
			baseIncome = {min = 300000, max = 2000000},
			eventTags = {"business_owner", "empire", "luxury_dealer"},
			requirements = {
				prevTier = "dealership_manager",
				minStats = {Charisma = 65, Smarts = 60},
				minMoney = 500000,
			},
		},
		
		{
			id = "exotic_dealer",
			label = "Exotic Car Dealer",
			description = "Dealing in supercars and hypercars",
			minAge = 30,
			maxAge = 75,
			branch = "car_dealer",
			baseIncome = {min = 500000, max = 5000000},
			eventTags = {"exotic_cars", "supercar", "elite_clientele"},
			requirements = {
				prevTier = "dealership_owner",
				flags = {"wealthy_connections"},
				minReputation = 70,
			},
		},
		
		-- ═══════════════════════════════════════════════════════════
		-- AUTOMOTIVE ENGINEER BRANCH (Designing Cars)
		-- ═══════════════════════════════════════════════════════════
		
		{
			id = "automotive_student",
			label = "Automotive Engineering Student",
			description = "Studying automotive engineering",
			minAge = 18,
			maxAge = 26,
			branch = "automotive_engineer",
			baseIncome = {min = 0, max = 20000}, -- Internship money
			eventTags = {"engineering", "student", "education"},
			requirements = {
				education = "high_school",
				minStats = {Smarts = 60},
				traits = {"mechanical_aptitude"},
			},
		},
		
		{
			id = "junior_engineer",
			label = "Junior Automotive Engineer",
			description = "Entry-level engineering position",
			minAge = 22,
			maxAge = 35,
			branch = "automotive_engineer",
			baseIncome = {min = 60000, max = 90000},
			eventTags = {"engineering", "junior", "design"},
			requirements = {
				prevTier = "automotive_student",
				education = "bachelor",
			},
		},
		
		{
			id = "senior_engineer",
			label = "Senior Automotive Engineer",
			description = "Leading design projects",
			minAge = 28,
			maxAge = 60,
			branch = "automotive_engineer",
			baseIncome = {min = 100000, max = 180000},
			eventTags = {"engineering", "senior", "leadership"},
			requirements = {
				prevTier = "junior_engineer",
				minStats = {Smarts = 70},
			},
		},
		
		{
			id = "lead_designer",
			label = "Lead Vehicle Designer",
			description = "Shaping the future of automobiles",
			minAge = 35,
			maxAge = 65,
			branch = "automotive_engineer",
			baseIncome = {min = 180000, max = 350000},
			eventTags = {"design", "innovation", "visionary"},
			requirements = {
				prevTier = "senior_engineer",
				minStats = {Smarts = 75},
				minReputation = 50,
			},
		},
		
		{
			id = "chief_engineer",
			label = "Chief Engineer",
			description = "Head of engineering at a major manufacturer",
			minAge = 40,
			maxAge = 70,
			branch = "automotive_engineer",
			baseIncome = {min = 300000, max = 800000},
			eventTags = {"executive", "c_suite", "industry_leader"},
			requirements = {
				prevTier = "lead_designer",
				minStats = {Smarts = 80, Charisma = 60},
			},
			unlocks = {
				traits = {"mechanical_genius"},
				flags = {"industry_leader"},
			},
		},
		
		-- ═══════════════════════════════════════════════════════════
		-- CAR THIEF BRANCH (Criminal Path)
		-- ═══════════════════════════════════════════════════════════
		
		{
			id = "joyrider",
			label = "Joyrider",
			description = "Stealing cars for fun",
			minAge = 14,
			maxAge = 25,
			branch = "car_thief",
			baseIncome = {min = 0, max = 5000},
			eventTags = {"crime", "joyriding", "juvenile"},
			requirements = {},
			risks = {
				arrest_chance = 0.30,
			},
		},
		
		{
			id = "car_thief_basic",
			label = "Car Thief",
			description = "Stealing cars for money",
			minAge = 17,
			maxAge = 45,
			branch = "car_thief",
			baseIncome = {min = 20000, max = 80000},
			eventTags = {"crime", "theft", "auto_theft"},
			requirements = {
				prevTier = "joyrider",
			},
			risks = {
				arrest_chance = 0.35,
				violent_encounter_chance = 0.10,
			},
		},
		
		{
			id = "professional_car_thief",
			label = "Professional Car Thief",
			description = "High-end vehicle specialist",
			minAge = 21,
			maxAge = 50,
			branch = "car_thief",
			baseIncome = {min = 80000, max = 300000},
			eventTags = {"crime", "professional", "luxury_theft"},
			requirements = {
				prevTier = "car_thief_basic",
				minStats = {Smarts = 50},
			},
			risks = {
				arrest_chance = 0.25,
				violent_encounter_chance = 0.15,
			},
		},
		
		{
			id = "chop_shop_worker",
			label = "Chop Shop Worker",
			description = "Breaking down stolen cars",
			minAge = 18,
			maxAge = 55,
			branch = "chop_shop",
			baseIncome = {min = 40000, max = 100000},
			eventTags = {"crime", "chop_shop", "parts"},
			requirements = {
				traits = {"mechanical_aptitude"},
				flags = {"criminal_connections"},
			},
			risks = {
				arrest_chance = 0.20,
			},
		},
		
		{
			id = "chop_shop_boss",
			label = "Chop Shop Boss",
			description = "Running the operation",
			minAge = 25,
			maxAge = 60,
			branch = "chop_shop",
			baseIncome = {min = 150000, max = 500000},
			eventTags = {"crime_boss", "chop_shop", "organized_crime"},
			requirements = {
				prevTier = "chop_shop_worker",
				minStats = {Smarts = 55, Charisma = 45},
			},
			risks = {
				arrest_chance = 0.25,
				assassination_chance = 0.05,
			},
		},
		
		{
			id = "getaway_driver",
			label = "Getaway Driver",
			description = "The wheelman for heists",
			minAge = 20,
			maxAge = 45,
			branch = "getaway_driver",
			baseIncome = {min = 50000, max = 200000},
			eventTags = {"crime", "heist", "getaway", "high_stakes"},
			requirements = {
				traits = {"racer_interest", "speed_demon"},
				minStats = {Smarts = 45},
				flags = {"criminal_connections"},
			},
			risks = {
				arrest_chance = 0.35,
				death_chance = 0.05,
			},
		},
		
		{
			id = "legendary_wheelman",
			label = "Legendary Wheelman",
			description = "The best driver in the underworld",
			minAge = 25,
			maxAge = 55,
			branch = "getaway_driver",
			baseIncome = {min = 200000, max = 1000000},
			eventTags = {"crime_legend", "wheelman", "untouchable"},
			requirements = {
				prevTier = "getaway_driver",
				minStats = {Smarts = 60},
				minReputation = 60,
			},
			unlocks = {
				traits = {"legendary_driver"},
				flags = {"underworld_legend"},
			},
		},
	},
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════════

function CareerLibrary.getCareer(careerId)
	return CareerLibrary[careerId]
end

function CareerLibrary.getAllCareers()
	local careers = {}
	for id, career in pairs(CareerLibrary) do
		if type(career) == "table" and career.id then
			table.insert(careers, career)
		end
	end
	return careers
end

function CareerLibrary.getCareersByCategory(category)
	local careers = {}
	for _, career in pairs(CareerLibrary) do
		if type(career) == "table" and career.category == category then
			table.insert(careers, career)
		end
	end
	return careers
end

function CareerLibrary.getTier(careerId, tierIndex)
	local career = CareerLibrary[careerId]
	if career and career.tiers and career.tiers[tierIndex] then
		return career.tiers[tierIndex]
	end
	return nil
end

function CareerLibrary.getTierById(careerId, tierId)
	local career = CareerLibrary[careerId]
	if not career or not career.tiers then return nil end
	
	for _, tier in ipairs(career.tiers) do
		if tier.id == tierId then
			return tier
		end
	end
	return nil
end

function CareerLibrary.getTierByBranch(careerId, branch, tierIndex)
	local career = CareerLibrary[careerId]
	if not career or not career.tiers then return nil end
	
	local branchTiers = {}
	for _, tier in ipairs(career.tiers) do
		if tier.branch == nil or tier.branch == branch then
			table.insert(branchTiers, tier)
		end
	end
	
	return branchTiers[tierIndex]
end

function CareerLibrary.getTiersForBranch(careerId, branch)
	local career = CareerLibrary[careerId]
	if not career or not career.tiers then return {} end
	
	local branchTiers = {}
	for _, tier in ipairs(career.tiers) do
		if tier.branch == nil or tier.branch == branch then
			table.insert(branchTiers, tier)
		end
	end
	
	return branchTiers
end

function CareerLibrary.getBranches(careerId)
	local career = CareerLibrary[careerId]
	if career and career.branches then
		return career.branches
	end
	return {}
end

return CareerLibrary
