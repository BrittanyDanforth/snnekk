-- LifeEvents/career_political.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- POLITICAL CAREER EVENTS
-- BitLife-style: Player picks ACTIONS, game decides OUTCOMES
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent.init)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- EARLY POLITICAL INTEREST
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "pol_student_council",
		minAge = 12, maxAge = 18,
		weight = 25, oneTime = true,
		emoji = "🗳️", title = "Student Council Elections!",
		category = "school",
		text = "Student council elections! You could run for president! What do you do?",
		choices = {
			{ text = "🎤 Run for president!", effects = { Happiness = 20, Looks = 3, Smarts = 3 }, resultText = "You WON! Class President! First taste of political power!", setFlags = {"student_leader", "political_interest"} },
			{ text = "🤝 Run for VP instead", effects = { Happiness = 15, Smarts = 3 }, resultText = "Vice President! Supporting role suits you!", setFlag = "political_interest" },
			{ text = "📢 Help someone's campaign", effects = { Happiness = 10, Smarts = 5 }, resultText = "Learned campaign strategy! Behind-the-scenes player!", setFlag = "political_strategist" },
			{ text = "🙅 Politics isn't for me", effects = { Happiness = 5 }, resultText = "Stayed out of it. School politics is drama anyway." },
		},
	},
	
	{
		id = "pol_college_activism",
		minAge = 18, maxAge = 24,
		weight = 20, oneTime = true,
		emoji = "✊", title = "Campus Activism!",
		category = "school",
		text = "Big issue on campus! Students are organizing protests and petitions. Do you get involved?",
		choices = {
			{ text = "✊ Lead the movement", effects = { Happiness = 20, Smarts = 5, Looks = 3 }, resultText = "Became the face of the cause! Administration listened!", setFlags = {"activist", "political_experience"} },
			{ text = "📝 Start a petition", effects = { Happiness = 15, Smarts = 8 }, resultText = "10,000 signatures! Changed policy! Effective organizing!", setFlag = "political_experience" },
			{ text = "🎤 Give a big speech", effects = { Happiness = 18, Looks = 5 }, resultText = "Went viral! People know your name now!", setFlags = {"public_speaker", "political_experience"} },
			{ text = "📚 Focus on studies", effects = { Happiness = 5, Smarts = 5 }, resultText = "Let others handle it. Grades are more important." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- LOCAL POLITICS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "pol_local_campaign",
		minAge = 25, maxAge = 45,
		weight = 18, oneTime = true,
		emoji = "🏛️", title = "Run for Local Office?",
		category = "work",
		requiresFlag = "political_experience",
		getDynamicData = function()
			local offices = {"City Council", "School Board", "County Commissioner", "Town Selectman"}
			return { office = offices[math.random(#offices)] }
		end,
		text = "Local %office% seat is open! Friends think you should run! It's your chance to make a difference!",
		choices = {
			{ text = "🏃 Run a grassroots campaign", effects = { Happiness = 25, Money = -10000 }, resultText = "Door to door! Won a close race! You're an elected official!", setFlags = {"local_official", "elected"} },
			{ text = "💰 Run with major donations", effects = { Happiness = 20, Money = -5000 }, resultText = "Big donors backed you! Won comfortably! But owe some favors...", setFlags = {"local_official", "connected"} },
			{ text = "😔 Lost the election", effects = { Happiness = -15, Money = -15000 }, resultText = "Came close but didn't win. Valuable experience though. Try again?" },
			{ text = "🙅 Not ready yet", effects = { Happiness = 5 }, resultText = "Decided it's not the right time. Maybe later." },
		},
	},
	
	{
		id = "pol_local_scandal",
		minAge = 28, maxAge = 60,
		weight = 20, cooldown = 4,
		emoji = "📰", title = "Local Scandal!",
		category = "work",
		requiresFlag = "elected",
		getDynamicData = function()
			local scandals = {"budget issue", "controversial vote", "personal conflict", "transparency concern"}
			return { scandal = scandals[math.random(#scandals)] }
		end,
		text = "Local paper running story about a %scandal% involving you! How do you respond?",
		choices = {
			{ text = "📰 Full transparency", effects = { Happiness = 10, Looks = 5 }, resultText = "Answered every question! Nothing to hide! Trust restored!", setFlag = "scandal_survivor" },
			{ text = "⚖️ Threaten to sue", effects = { Happiness = -10, Money = -5000 }, resultText = "Looked guilty even if not. Lawsuit made it worse. Bad strategy." },
			{ text = "🤝 Apologize sincerely", effects = { Happiness = 8, Looks = 3 }, resultText = "People appreciate accountability! Moved past it!", setFlag = "scandal_survivor" },
			{ text = "😤 Attack the reporter", effects = { Happiness = -15, Looks = -5 }, resultText = "Backfired horribly! Now the story is about YOUR behavior!" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- STATE / HIGHER OFFICE
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "pol_state_race",
		minAge = 30, maxAge = 55,
		weight = 15, oneTime = true,
		emoji = "🏛️", title = "State Legislature Race!",
		category = "work",
		requiresFlag = "local_official",
		text = "State House/Senate seat available! Bigger stage, more impact! Ready to move up?",
		choices = {
			{ text = "🎯 Run a perfect campaign", effects = { Happiness = 30, Money = -50000, Looks = 5 }, resultText = "WON! State Legislator! Making laws now!", setFlags = {"state_legislator", "rising_star"} },
			{ text = "🤝 Coalition building", effects = { Happiness = 25, Money = -30000 }, resultText = "United different groups! Strong coalition victory!", setFlags = {"state_legislator", "coalition_builder"} },
			{ text = "💔 Lost competitive race", effects = { Happiness = -20, Money = -40000 }, resultText = "So close! Lost by 2%. Heartbreaking but try again?" },
			{ text = "🏠 Stay local", effects = { Happiness = 10 }, resultText = "Decided to keep focus on local issues. More impact here anyway." },
		},
	},
	
	{
		id = "pol_major_bill",
		minAge = 32, maxAge = 65,
		weight = 20, cooldown = 3,
		emoji = "📜", title = "Your Bill Up for Vote!",
		category = "work",
		requiresFlag = "state_legislator",
		getDynamicData = function()
			local bills = {"education reform", "healthcare expansion", "tax overhaul", "infrastructure investment"}
			return { bill = bills[math.random(#bills)] }
		end,
		text = "Your %bill% bill is up for final vote! Years of work! What's your strategy?",
		choices = {
			{ text = "🤝 Negotiate with opposition", effects = { Happiness = 25, Smarts = 8 }, resultText = "Compromised to get it passed! Law of the land! Bipartisan win!", setFlag = "passed_major_bill" },
			{ text = "💪 Hold firm on principles", effects = { Happiness = 15, Smarts = 5 }, resultText = "Didn't compromise! Passed with party support! Pure vision!", setFlag = "passed_major_bill" },
			{ text = "📢 Go public with pressure", effects = { Happiness = 20, Looks = 5 }, resultText = "Rallied public! Phone lines jammed! Bill passed!", setFlag = "passed_major_bill" },
			{ text = "💔 Bill defeated", effects = { Happiness = -20 }, resultText = "Lost the vote. Years of work... maybe next session." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- MAJOR ELECTIONS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "pol_congress_run",
		minAge = 30, maxAge = 60,
		weight = 12, oneTime = true,
		emoji = "🏛️", title = "Run for Congress!",
		category = "work",
		requiresFlag = "rising_star",
		text = "Congressional seat opening up! National stage! Ready for Washington?",
		choices = {
			{ text = "🇺🇸 Win the primary", effects = { Happiness = 25, Money = -100000 }, resultText = "Won your party's nomination! General election next!", setFlag = "congressional_nominee" },
			{ text = "🎯 Win it all!", effects = { Happiness = 40, Money = -200000 }, resultText = "CONGRESSPERSON! Washington here you come!", setFlags = {"congressperson", "federal_official"} },
			{ text = "😔 Lost in primary", effects = { Happiness = -20, Money = -80000 }, resultText = "Party chose someone else. Crushing. Rebuild and try again?" },
			{ text = "📈 Build more first", effects = { Happiness = 10 }, resultText = "Decided to build profile more before federal run. Smart maybe." },
		},
	},
	
	{
		id = "pol_governor_race",
		minAge = 40, maxAge = 65,
		weight = 8, oneTime = true,
		emoji = "🏛️", title = "Run for Governor!",
		category = "work",
		requiresFlag = "state_legislator",
		text = "Governor race coming up! You could run the whole state! The biggest campaign yet!",
		choices = {
			{ text = "🏆 Win the governorship!", effects = { Happiness = 45, Money = -500000 }, resultText = "GOVERNOR! Leader of the state! Real executive power!", setFlags = {"governor", "executive"} },
			{ text = "🤝 Win with coalition", effects = { Happiness = 40, Money = -400000 }, resultText = "United campaign won! Governor! Mandate to lead!", setFlags = {"governor", "popular_mandate"} },
			{ text = "💔 Lost close race", effects = { Happiness = -30, Money = -400000 }, resultText = "2% away from the mansion. Devastating loss. Future unclear." },
			{ text = "📉 Campaign imploded", effects = { Happiness = -35, Money = -300000 }, resultText = "Gaffes, scandals, bad staff. Lost badly. Career damaged." },
		},
	},
	
	{
		id = "pol_presidential",
		minAge = 45, maxAge = 75,
		weight = 3, oneTime = true,
		emoji = "🇺🇸", title = "RUN FOR PRESIDENT?!",
		category = "work",
		requiresFlag = "governor",
		text = "The biggest stage. Leader of the free world. Your party thinks you can win. DO YOU RUN FOR PRESIDENT?",
		choices = {
			{ text = "🇺🇸 WIN THE PRESIDENCY!", effects = { Happiness = 100, Money = -2000000 }, resultText = "PRESIDENT! The most powerful person on Earth! History made!", setFlags = {"president", "world_leader", "historical_figure"} },
			{ text = "🗳️ Win primary, lose general", effects = { Happiness = -20, Money = -2000000 }, resultText = "Won the nomination but lost in November. So close to history." },
			{ text = "😔 Lose in primaries", effects = { Happiness = -30, Money = -1000000 }, resultText = "Didn't win your party's nomination. Dream over. For now." },
			{ text = "🙅 Not ready for this", effects = { Happiness = 10 }, resultText = "Decided the timing isn't right. Maybe next cycle." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- LEGACY
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "pol_legacy",
		minAge = 55, maxAge = 90,
		weight = 15, oneTime = true,
		emoji = "📚", title = "Your Political Legacy",
		category = "work",
		requiresFlag = "federal_official",
		text = "Reflecting on your career. How will history remember you? Time to cement your legacy.",
		choices = {
			{ text = "📚 Write your memoirs", effects = { Happiness = 20, Money = 500000, Smarts = 5 }, resultText = "Best-seller! Your story in your words! Legacy secured!", setFlag = "memoir_published" },
			{ text = "🏛️ Presidential library", effects = { Happiness = 30, Money = -1000000 }, resultText = "Your library opened! History preserved! Generations will learn!", setFlag = "library_built" },
			{ text = "🎓 Teaching/mentoring", effects = { Happiness = 25, Smarts = 5 }, resultText = "Training the next generation! Your wisdom lives on!", setFlag = "political_mentor" },
			{ text = "🌍 Global advocacy", effects = { Happiness = 22, Looks = 5 }, resultText = "Using your platform for causes! Statesman status!", setFlag = "elder_statesman" },
		},
	},
}

return module
