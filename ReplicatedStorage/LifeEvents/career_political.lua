-- LifeEvents/career_political.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- POLITICAL CAREER EVENTS
-- Politicians, Activists, Presidents - Public service and power
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent.init)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- EARLY POLITICAL INTEREST
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "pol_student_council",
		minAge = 14, maxAge = 18,
		weight = 25, oneTime = true,
		emoji = "🗳️", title = "Student Council Election!",
		category = "school",
		text = "Running for student body president! Your first taste of politics!",
		choices = {
			{ text = "🏆 Won!", effects = { Happiness = 20, Smarts = 5, Looks = 3 }, resultText = "ELECTED! Leading your school! First political victory!", setFlags = {"political_interest", "student_leader"} },
			{ text = "📊 Lost but learned", effects = { Happiness = 5, Smarts = 5 }, resultText = "Didn't win but learned about campaigns. Next time.", setFlag = "political_interest" },
			{ text = "🎤 Great speech!", effects = { Happiness = 15, Smarts = 3, Looks = 3 }, resultText = "Your speech went viral (in school). Natural orator!", setFlags = {"political_interest", "gifted_speaker"} },
			{ text = "😤 Dirty politics", effects = { Happiness = -5, Smarts = 5 }, resultText = "Opponent spread rumors. Even student elections are nasty.", setFlag = "political_interest" },
		},
	},
	
	{
		id = "pol_activism_spark",
		minAge = 15, maxAge = 25,
		weight = 20, oneTime = true,
		emoji = "✊", title = "Activist Awakening!",
		category = "social",
		getDynamicData = function()
			local causes = {"climate change", "social justice", "education reform", "healthcare access", "voting rights", "economic inequality"}
			return { cause = causes[math.random(#causes)] }
		end,
		text = "You've become passionate about %cause%! Time to make a difference!",
		choices = {
			{ text = "📢 Organized a protest", effects = { Happiness = 15, Smarts = 5 }, resultText = "Hundreds showed up! Your voice matters! Change is possible!", setFlags = {"activist", "political_interest"} },
			{ text = "✍️ Started a petition", effects = { Happiness = 12, Smarts = 5 }, resultText = "50,000 signatures! Officials are taking notice!", setFlags = {"activist", "political_interest"} },
			{ text = "📱 Went viral", effects = { Happiness = 18, Looks = 3 }, resultText = "Your social media post sparked a movement! Influencer activist!", setFlags = {"activist", "viral_activist"} },
			{ text = "🤝 Local impact", effects = { Happiness = 10, Smarts = 3 }, resultText = "Real change in your community. Small but meaningful.", setFlag = "activist" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- LOCAL POLITICS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "pol_city_council",
		minAge = 25, maxAge = 50,
		weight = 20, oneTime = true,
		emoji = "🏛️", title = "City Council Run!",
		category = "work",
		requiresFlag = "political_interest",
		getDynamicData = function()
			local cities = {"your hometown", "the city you live in", "a growing suburb"}
			return { city = cities[math.random(#cities)] }
		end,
		text = "Running for city council in %city%! Local politics, real impact!",
		choices = {
			{ text = "🏆 Elected!", effects = { Happiness = 25, Money = 30000, Looks = 3 }, resultText = "COUNCILMEMBER! Your political career officially begins!", setFlags = {"city_council", "elected_official"} },
			{ text = "📊 Close race", effects = { Happiness = 10, Money = -10000, Smarts = 5 }, resultText = "Lost by 200 votes. Recount? The system works... barely.", setFlag = "lost_election" },
			{ text = "🤝 Made connections", effects = { Happiness = 15, Smarts = 5 }, resultText = "Win or lose, you know everyone in local politics now.", setFlag = "political_networked" },
			{ text = "💰 Campaign debt", effects = { Happiness = 5, Money = -20000 }, resultText = "Won but spent too much. Politics is expensive.", setFlags = {"city_council", "elected_official"} },
		},
	},
	
	{
		id = "pol_mayor_race",
		minAge = 30, maxAge = 60,
		weight = 15, oneTime = true,
		emoji = "🏛️", title = "Running for Mayor!",
		category = "work",
		requiresFlag = "city_council",
		getDynamicData = function()
			local population = math.random(50, 500)
			return { population = population }
		end,
		text = "Running for mayor! City of %population%,000 people could be yours to lead!",
		choices = {
			{ text = "🏆 Mayor elected!", effects = { Happiness = 35, Money = 80000, Looks = 5 }, resultText = "MAYOR YOU! The people chose you to lead! Real power now!", clearFlag = "city_council", setFlags = {"mayor", "executive"} },
			{ text = "📺 Debate victory", effects = { Happiness = 30, Money = 75000, Smarts = 5 }, resultText = "Destroyed your opponent in debate. Landslide win!", clearFlag = "city_council", setFlags = {"mayor", "executive", "debate_champion"} },
			{ text = "😤 Mudslinging campaign", effects = { Happiness = 15, Money = 70000, Looks = -3 }, resultText = "Won but it got ugly. Opponents found old dirt on you.", clearFlag = "city_council", setFlags = {"mayor", "controversial"} },
			{ text = "💔 Lost", effects = { Happiness = -20, Money = -30000 }, resultText = "Not this time. Crushing defeat. Political career in question." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- STATE / NATIONAL POLITICS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "pol_state_legislature",
		minAge = 28, maxAge = 60,
		weight = 15, oneTime = true,
		emoji = "🏛️", title = "State Legislature Run!",
		category = "work",
		requiresFlag = "elected_official",
		text = "Running for State House/Senate! Moving up the political ladder!",
		choices = {
			{ text = "🏆 State legislator!", effects = { Happiness = 30, Money = 50000, Looks = 3 }, resultText = "Making laws! Real power! State capital bound!", setFlags = {"state_legislator", "lawmaker"} },
			{ text = "📜 First bill passed!", effects = { Happiness = 35, Money = 50000, Smarts = 5 }, resultText = "Not just elected - passed legislation! Making change!", setFlags = {"state_legislator", "lawmaker", "effective"} },
			{ text = "😤 Party politics", effects = { Happiness = 15, Money = 45000, Smarts = 5 }, resultText = "Won but had to compromise principles. The party controls too much.", setFlags = {"state_legislator", "pragmatist"} },
			{ text = "📊 Primary upset", effects = { Happiness = -15, Money = -20000 }, resultText = "Lost in your own party's primary. Brutal." },
		},
	},
	
	{
		id = "pol_congress",
		minAge = 30, maxAge = 65,
		weight = 10, oneTime = true,
		emoji = "🏛️", title = "Running for Congress!",
		category = "work",
		requiresFlag = "state_legislator",
		getDynamicData = function()
			local chambers = {"House of Representatives", "U.S. Senate"}
			return { chamber = chambers[math.random(#chambers)] }
		end,
		text = "Running for the %chamber%! National stage! DC awaits!",
		choices = {
			{ text = "🏆 CONGRESSMAN/SENATOR!", effects = { Happiness = 45, Money = 174000, Looks = 8 }, resultText = "YOU'RE GOING TO WASHINGTON! National lawmaker! Historic achievement!", clearFlags = {"state_legislator", "mayor"}, setFlags = {"congress", "federal_official"} },
			{ text = "📺 National attention", effects = { Happiness = 40, Money = 174000, Looks = 10 }, resultText = "Cable news loves you! Rising star! Future presidential talk!", clearFlags = {"state_legislator", "mayor"}, setFlags = {"congress", "federal_official", "rising_star"} },
			{ text = "😰 Brutal campaign", effects = { Happiness = 25, Money = 174000, Health = -10 }, resultText = "Won but the race was vicious. Enemies made. Scars remain.", clearFlags = {"state_legislator", "mayor"}, setFlags = {"congress", "federal_official"} },
			{ text = "💔 Lost the race", effects = { Happiness = -25, Money = -100000 }, resultText = "National ambitions crushed. For now." },
		},
	},
	
	{
		id = "pol_legislation_passed",
		minAge = 32, maxAge = 70,
		weight = 20, cooldown = 3,
		emoji = "📜", title = "Major Legislation!",
		category = "work",
		requiresFlag = "congress",
		getDynamicData = function()
			local bills = {"healthcare reform", "infrastructure bill", "education funding", "environmental protection", "tax reform", "civil rights expansion"}
			return { bill = bills[math.random(#bills)] }
		end,
		text = "Your %bill% bill is up for a vote! Years of work, one moment of truth!",
		choices = {
			{ text = "🎉 Passed!", effects = { Happiness = 40, Smarts = 5, Looks = 3 }, resultText = "YOUR BILL BECAME LAW! Millions of lives changed! THIS is why you ran!", setFlag = "major_legislation" },
			{ text = "🤝 Bipartisan success", effects = { Happiness = 35, Smarts = 8 }, resultText = "Both parties voted yes! Rare unity! You bridged the divide!", setFlags = {"major_legislation", "bipartisan"} },
			{ text = "😤 Killed in committee", effects = { Happiness = -20, Smarts = 3 }, resultText = "Never even got a vote. Politics killed good policy." },
			{ text = "📝 Amended heavily", effects = { Happiness = 20, Smarts = 5 }, resultText = "Passed but gutted. Better than nothing? Compromise is painful.", setFlag = "compromised" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- SCANDALS & CHALLENGES
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "pol_scandal",
		minAge = 30, maxAge = 75,
		weight = 20, cooldown = 4,
		emoji = "📰", title = "Political Scandal!",
		category = "work",
		requiresFlag = "elected_official",
		getDynamicData = function()
			local scandals = {"financial impropriety allegations", "leaked private messages", "affair accusations", "controversial old statements", "conflict of interest"}
			return { scandal = scandals[math.random(#scandals)] }
		end,
		text = "SCANDAL! %scandal% all over the news! Your career is on the line!",
		choices = {
			{ text = "📺 Press conference", effects = { Happiness = -10, Looks = -5 }, resultText = "Faced the cameras. Apologized or denied. The spin begins.", setFlag = "survived_scandal" },
			{ text = "⚖️ Lawyers up", effects = { Happiness = -15, Money = -100000 }, resultText = "Legal battle. Reputation in limbo. Career might survive." },
			{ text = "😔 Resign", effects = { Happiness = -30, Money = -50000 }, resultText = "Stepped down. Disgrace. Years of work, gone.", clearFlags = {"congress", "mayor", "city_council", "elected_official"}, setFlag = "disgraced" },
			{ text = "💪 Doubled down", effects = { Happiness = 5, Looks = -3, Smarts = 3 }, resultText = "Refused to apologize. Base loves it. Others disgusted. Polarizing.", setFlags = {"survived_scandal", "polarizing"} },
		},
	},
	
	{
		id = "pol_threat",
		minAge = 30, maxAge = 80,
		weight = 15, cooldown = 5,
		emoji = "⚠️", title = "Security Threat",
		category = "work",
		requiresFlag = "federal_official",
		text = "Credible threat against you. Security detail assigned. Being a public figure is dangerous.",
		choices = {
			{ text = "😰 Terrifying", effects = { Happiness = -20, Health = -5 }, resultText = "Can't go anywhere freely anymore. Family scared. This job has costs." },
			{ text = "💪 Won't be intimidated", effects = { Happiness = 5, Smarts = 3 }, resultText = "Threats won't silence you. Democracy requires brave voices.", setFlag = "brave" },
			{ text = "👨‍👩‍👧 Family suffers", effects = { Happiness = -15 }, resultText = "Your kids need security now too. They didn't sign up for this." },
			{ text = "🤐 Toned down rhetoric", effects = { Happiness = -5, Smarts = 5 }, resultText = "Being less controversial. Not worth dying over politics." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- PRESIDENTIAL PATH
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "pol_presidential_primary",
		minAge = 40, maxAge = 70,
		weight = 5, oneTime = true,
		emoji = "🇺🇸", title = "Presidential Primary!",
		category = "work",
		requiresFlag = "rising_star",
		text = "YOU'RE RUNNING FOR PRESIDENT OF THE UNITED STATES!",
		choices = {
			{ text = "🏆 Won the nomination!", effects = { Happiness = 50, Money = 0, Looks = 10 }, resultText = "YOU'RE THE NOMINEE! One step from the Oval Office!", setFlags = {"presidential_nominee", "national_figure"} },
			{ text = "🥈 Strong second", effects = { Happiness = 20, Looks = 5 }, resultText = "Didn't win but made a name. Maybe next time. Cabinet position?", setFlag = "presidential_contender" },
			{ text = "📊 Early dropout", effects = { Happiness = -10, Money = -5000000 }, resultText = "Couldn't get traction. Dropped out early. Millions spent." },
			{ text = "🌟 Kingmaker", effects = { Happiness = 25, Smarts = 5, Looks = 5 }, resultText = "Dropped out but endorsed winner. Now you have influence.", setFlag = "kingmaker" },
		},
	},
	
	{
		id = "pol_presidential_election",
		minAge = 40, maxAge = 75,
		weight = 3, oneTime = true,
		emoji = "🇺🇸", title = "PRESIDENTIAL ELECTION!",
		category = "work",
		requiresFlag = "presidential_nominee",
		text = "Election night. The world is watching. Will you be the next President?",
		choices = {
			{ text = "🎉 PRESIDENT ELECT!", effects = { Happiness = 100, Money = 400000, Looks = 15, Smarts = 10 }, resultText = "YOU WON! PRESIDENT OF THE UNITED STATES! The most powerful person on Earth! HISTORIC!", clearFlag = "presidential_nominee", setFlags = {"president", "world_leader"} },
			{ text = "🗳️ Electoral squeaker", effects = { Happiness = 80, Money = 400000, Looks = 12 }, resultText = "Won by a hair! Contested but certified! You're the President!", clearFlag = "presidential_nominee", setFlags = {"president", "controversial_win"} },
			{ text = "💔 Lost", effects = { Happiness = -40, Smarts = 5 }, resultText = "So close to history. Graceful concession. Maybe in 4 years.", clearFlag = "presidential_nominee", setFlag = "lost_presidential" },
			{ text = "🗳️ Popular vote only", effects = { Happiness = -20, Smarts = 5 }, resultText = "Won the popular vote, lost electoral college. Bitter defeat.", clearFlag = "presidential_nominee", setFlag = "robbed" },
		},
	},
	
	{
		id = "pol_oval_office",
		minAge = 42, maxAge = 78,
		weight = 10, cooldown = 4,
		emoji = "🏛️", title = "Oval Office Decision",
		category = "work",
		requiresFlag = "president",
		getDynamicData = function()
			local crises = {"international crisis", "economic emergency", "national disaster", "military decision", "Supreme Court nomination"}
			return { crisis = crises[math.random(#crises)] }
		end,
		text = "The %crisis% requires YOUR decision. The weight of the world on your shoulders.",
		choices = {
			{ text = "📊 History will judge well", effects = { Happiness = 20, Smarts = 8 }, resultText = "Made the tough call. Country rallied. Legacy defining moment.", setFlag = "decisive_president" },
			{ text = "🤝 Bipartisan solution", effects = { Happiness = 25, Smarts = 8 }, resultText = "Brought both parties together. Rare unity. Presidential moment.", setFlag = "unifying_president" },
			{ text = "😔 Controversial decision", effects = { Happiness = -10, Smarts = 5 }, resultText = "History will debate. Half love it, half hate it. Presidential reality." },
			{ text = "😰 Paralyzed by pressure", effects = { Happiness = -15, Health = -10 }, resultText = "Too slow to act. Critics pouncing. This job is crushing." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- LEGACY
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "pol_presidential_library",
		minAge = 50, maxAge = 95,
		weight = 10, oneTime = true,
		emoji = "🏛️", title = "Presidential Library",
		category = "work",
		requiresFlag = "president",
		getDynamicData = function()
			local cities = {"your hometown", "Washington DC", "a major city", "near your university"}
			return { location = cities[math.random(#cities)] }
		end,
		text = "Your presidential library is being built in %location%! Your legacy preserved!",
		choices = {
			{ text = "🏛️ Proud legacy", effects = { Happiness = 45 }, resultText = "Your presidency, preserved forever. Schoolchildren will study you.", setFlag = "presidential_legacy" },
			{ text = "📚 The whole truth", effects = { Happiness = 35, Smarts = 5 }, resultText = "Insisted on full transparency. Good and bad. Real history.", setFlag = "honest_legacy" },
			{ text = "💰 $500 million raised", effects = { Happiness = 40, Money = 10000000 }, resultText = "Donors funded it all. Your friends came through.", setFlag = "presidential_legacy" },
			{ text = "🎓 Scholars will debate", effects = { Happiness = 30, Smarts = 8 }, resultText = "Your presidency was consequential. Historians will argue for decades.", setFlag = "consequential" },
		},
	},
	
	{
		id = "pol_elder_statesman",
		minAge = 60, maxAge = 95,
		weight = 15, oneTime = true,
		emoji = "🕊️", title = "Elder Statesman",
		category = "social",
		requiresFlag = "federal_official",
		text = "You've become an elder statesman. Both parties respect you. Wisdom earned through service.",
		choices = {
			{ text = "🤝 Bridge builder", effects = { Happiness = 30, Smarts = 5 }, resultText = "Bringing people together. In this divided time, you're a unifying voice.", setFlag = "statesman" },
			{ text = "📚 Memoirs published", effects = { Happiness = 25, Money = 5000000 }, resultText = "Your book is a bestseller. The real story, in your words.", setFlags = {"statesman", "author"} },
			{ text = "🌍 Global humanitarian", effects = { Happiness = 35, Smarts = 5 }, resultText = "Using your influence for good worldwide. Nobel Peace Prize buzz!", setFlags = {"statesman", "humanitarian"} },
			{ text = "🤫 Quiet retirement", effects = { Happiness = 20, Health = 10 }, resultText = "Done with public life. Enjoying grandkids. Peace at last.", setFlag = "retired_politician" },
		},
	},
}

return module
