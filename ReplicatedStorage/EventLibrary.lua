-- EventLibrary.lua
-- MASSIVE BitLife-style event database with 300+ unique events
-- DEEP story paths: President, Criminal, Teacher, Racer, Artist, Hacker
-- With smart flag checks to prevent event repetition

local EventLibrary = {}

----------------------------------------------------------------------
-- NAME & DATA GENERATORS
----------------------------------------------------------------------

local MaleNames = {"James","Michael","David","Chris","Daniel","Matt","Jake","Ryan","Tyler","Brandon","Kevin","Justin","Josh","Nick","Alex","Brian","Eric","Andrew","Sean","Kyle","Adam","Aaron","Ethan","Nathan","Zach","Dylan","Connor","Mason","Logan","Lucas","Marcus","Darius","Jerome","DeShawn","Jamal","Carlos","Miguel","Antonio","Roberto","Giovanni","Vladimir","Dmitri","Kenji","Hiroshi","Wei","Jin","Ahmed","Omar","Raj","Vikram","Liam","Noah","Oliver","William","Henry","Sebastian","Jack","Aiden","Owen","Samuel","Benjamin","Theodore","Leo","Finn","Caleb","Max","Jasper","Felix"}
local FemaleNames = {"Emma","Sophia","Olivia","Ava","Isabella","Mia","Emily","Abigail","Madison","Elizabeth","Ella","Avery","Chloe","Sofia","Grace","Lily","Hannah","Aria","Zoe","Riley","Nora","Scarlett","Stella","Luna","Hazel","Jasmine","Aaliyah","Destiny","Diamond","Keisha","Maria","Carmen","Rosa","Valentina","Yuki","Mei","Sakura","Priya","Ananya","Fatima","Layla","Charlotte","Amelia","Harper","Evelyn","Penelope","Layla","Camila","Eleanor","Violet"}
local LastNames = {"Smith","Johnson","Williams","Brown","Jones","Garcia","Miller","Davis","Rodriguez","Martinez","Anderson","Taylor","Thomas","Moore","Jackson","Martin","Lee","Thompson","White","Harris","Clark","Lewis","Robinson","Walker","Young","King","Wright","Scott","Green","Baker","Adams","Nelson","Hill","Mitchell","Roberts","Campbell","Phillips","Evans","Turner","Torres","Parker","Collins","Edwards","Stewart","Morris","Murphy","Rivera","Cook","Rogers","Morgan","Peterson","Cooper","Reed","Bailey","Bell","Gomez","Kelly","Howard","Ward","Cox","Diaz","Richardson","Wood","Watson","Brooks","Bennett","Gray","Sanders","Price","Hughes","Fitzgerald","O'Brien","McCarthy","Sullivan","Kim","Park","Chen","Wang","Nakamura","Tanaka","Patel","Singh","Khan"}

local function randomMaleName() return MaleNames[math.random(#MaleNames)] .. " " .. LastNames[math.random(#LastNames)] end
local function randomFemaleName() return FemaleNames[math.random(#FemaleNames)] .. " " .. LastNames[math.random(#LastNames)] end
local function randomName() return math.random(2) == 1 and randomMaleName() or randomFemaleName() end

local Schools = {"Lincoln High","Washington Academy","Jefferson High","Roosevelt Prep","Kennedy School"}
local Universities = {"Harvard","Yale","Stanford","MIT","Princeton","Columbia","State University","City College"}
local RacingTeams = {"Red Bull Racing","Ferrari","Mercedes","McLaren","Alpine","Thunder Racing","Lightning Motorsport"}
local HackerGroups = {"Anonymous","LulzSec","Zero Day Collective","Binary Brotherhood","Shadow Net","Cyber Legion"}
local ArtStyles = {"abstract","impressionist","surrealist","pop art","contemporary","street art","digital"}

local function randomSchool() return Schools[math.random(#Schools)] end
local function randomUniversity() return Universities[math.random(#Universities)] end
local function randomRacingTeam() return RacingTeams[math.random(#RacingTeams)] end
local function randomHackerGroup() return HackerGroups[math.random(#HackerGroups)] end
local function randomArtStyle() return ArtStyles[math.random(#ArtStyles)] end

----------------------------------------------------------------------
-- CAREER CHECK HELPERS
----------------------------------------------------------------------

local function hasNoCareer(state)
	local f = state.Flags or {}
	return not (f.teacher or f.racer or f.artist or f.hacker_career or f.gang_member or f.president)
end

local function hasNoCriminalRecord(state)
	local f = state.Flags or {}
	return not (f.arrested or f.in_prison or f.gang_member)
end

----------------------------------------------------------------------
-- EVENTS DATABASE
----------------------------------------------------------------------

local events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- UNIVERSAL CHILDHOOD EVENTS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "birth",
		minAge = 0, maxAge = 0,
		weight = 100, milestone = true, oneTime = true,
		emoji = "👶", title = "You Are Born!",
		category = "family",
		text = "You came into this world. Your life begins now.",
		choices = {
			{ text = "😭 Cry loudly", effects = { Health = 2 }, resultText = "Your strong lungs impressed the doctors." },
			{ text = "😴 Sleep peacefully", effects = { Health = 3, Happiness = 2 }, resultText = "You were a calm, peaceful baby." },
			{ text = "👀 Look around curiously", effects = { Smarts = 3 }, resultText = "You observed everything with wide, curious eyes." },
		},
	},
	
	{
		id = "first_word",
		minAge = 1, maxAge = 2,
		weight = 80, oneTime = true,
		emoji = "🗣️", title = "First Word!",
		category = "family",
		text = "Everyone is watching as you're about to speak your first word...",
		choices = {
			{ text = "👩 Say 'Mama'", effects = { Happiness = 5 }, resultText = "Your mother cried happy tears." },
			{ text = "👨 Say 'Dada'", effects = { Happiness = 5 }, resultText = "Your father was so proud." },
			{ text = "🙅 Say 'NO!'", effects = { Happiness = 3, Smarts = 3 }, resultText = "Your rebellious streak started early." },
		},
	},
	
	{
		id = "preschool_start",
		minAge = 4, maxAge = 4,
		weight = 90, oneTime = true, milestone = true,
		emoji = "🏫", title = "First Day of Preschool",
		category = "school",
		text = "It's your first day away from home!",
		choices = {
			{ text = "🎉 Excited!", effects = { Happiness = 5, Smarts = 3 }, resultText = "You made friends immediately." },
			{ text = "😰 Scared", effects = { Happiness = -2 }, resultText = "You clung to your parent but warmed up." },
			{ text = "🤝 Make a friend", effects = { Happiness = 6 }, resultText = "You found a best friend on day one!" },
		},
	},
	
	{
		id = "elementary_start",
		minAge = 6, maxAge = 6,
		weight = 100, oneTime = true, milestone = true,
		emoji = "🎒", title = "Elementary School Begins!",
		category = "school",
		text = "You're starting real school! This is a big step.",
		choices = {
			{ text = "📚 Focus on learning", effects = { Smarts = 5 }, resultText = "You became the smart kid.", setFlag = "studious" },
			{ text = "🎨 Focus on creativity", effects = { Smarts = 2, Happiness = 4 }, resultText = "You discovered your creative side.", setFlag = "creative_child" },
			{ text = "⚽ Focus on sports", effects = { Health = 5, Happiness = 3 }, resultText = "You became the star of gym class.", setFlag = "athletic_child" },
		},
	},

	-- ═══════════════════════════════════════════════════════════════
	-- CAREER PATH DISCOVERY EVENTS (Age 8-16)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "discover_computers",
		minAge = 8, maxAge = 14,
		weight = 15, oneTime = true,
		emoji = "💻", title = "Computer Fascination",
		category = "school",
		text = "You got access to a computer and you're absolutely fascinated by it.",
		choices = {
			{ text = "💻 Spend hours exploring", effects = { Smarts = 5, Happiness = 4 }, resultText = "You discovered a natural talent for computers.", setFlag = "computer_interest" },
			{ text = "🎮 Just play games", effects = { Happiness = 3 }, resultText = "You enjoyed gaming." },
		},
	},
	
	{
		id = "discover_art",
		minAge = 7, maxAge = 14,
		weight = 15, oneTime = true,
		emoji = "🎨", title = "Artistic Discovery",
		category = "school",
		text = "Your art teacher says you have exceptional talent!",
		choices = {
			{ text = "🎨 Take it seriously", effects = { Smarts = 3, Happiness = 5, Looks = 2 }, resultText = "You started developing your artistic gift.", setFlag = "art_interest" },
			{ text = "😊 Thanks but other interests", effects = { Happiness = 2 }, resultText = "You appreciated the compliment." },
		},
	},
	
	{
		id = "discover_racing",
		minAge = 8, maxAge = 14,
		weight = 12, oneTime = true,
		emoji = "🏎️", title = "Need for Speed",
		category = "social",
		text = "You went go-karting and discovered an incredible rush from speed!",
		choices = {
			{ text = "🏎️ I want to do this forever!", effects = { Happiness = 8, Health = 2 }, resultText = "You became obsessed with racing.", setFlag = "racing_interest" },
			{ text = "😅 Fun but scary", effects = { Happiness = 3 }, resultText = "It was thrilling but not for you." },
		},
	},
	
	{
		id = "discover_politics",
		minAge = 12, maxAge = 18,
		weight = 12, oneTime = true,
		emoji = "🗳️", title = "Political Awakening",
		category = "school",
		text = "A news story about politics inspired you to make a difference.",
		choices = {
			{ text = "📚 Learn more about government", effects = { Smarts = 5, Happiness = 3 }, resultText = "You became fascinated with how society works.", setFlag = "political_interest" },
			{ text = "✊ Join student council", effects = { Smarts = 3, Happiness = 4 }, resultText = "You ran for student council and won!", setFlags = {"political_interest", "student_council"} },
		},
	},
	
	{
		id = "discover_teaching",
		minAge = 10, maxAge = 18,
		weight = 12, oneTime = true,
		emoji = "📚", title = "Born to Teach",
		category = "school",
		text = "You helped a classmate understand a difficult subject, and it felt amazing.",
		choices = {
			{ text = "📚 I want to be a teacher!", effects = { Smarts = 4, Happiness = 5 }, resultText = "You discovered a passion for helping others learn.", setFlag = "teaching_interest" },
			{ text = "🤝 Nice to help occasionally", effects = { Happiness = 3 }, resultText = "You helped but had other plans." },
		},
	},
	
	{
		id = "first_criminal_temptation",
		minAge = 10, maxAge = 16,
		weight = 10, oneTime = true,
		emoji = "😈", title = "The Temptation",
		category = "crime",
		requires = function(state) return hasNoCriminalRecord(state) end,
		text = "A friend dares you to steal something from a store.",
		choices = {
			{ text = "🛒 Do it!", effects = { Happiness = 3, Smarts = -2 }, resultText = "You got away with it. The rush was real.", setFlag = "criminal_tendencies" },
			{ text = "🙅 No way", effects = { Happiness = 2, Smarts = 3 }, resultText = "You walked away. Crime isn't for you." },
		},
	},

	-- ═══════════════════════════════════════════════════════════════
	-- HIGH SCHOOL YEARS (14-18)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "high_school_start",
		minAge = 14, maxAge = 14,
		weight = 100, oneTime = true, milestone = true,
		emoji = "🏫", title = "High School Begins!",
		category = "school",
		text = "Welcome to high school! These years will shape your future.",
		choices = {
			{ text = "📚 Academic focus", effects = { Smarts = 8 }, resultText = "Academics became your priority.", setFlag = "honor_student" },
			{ text = "🎉 Social butterfly", effects = { Happiness = 6 }, resultText = "You became super popular!", setFlag = "popular" },
			{ text = "😈 Rebel", effects = { Happiness = 3, Smarts = -3 }, resultText = "You lived by your own rules.", setFlag = "rebel" },
		},
	},
	
	{
		id = "first_hacking",
		minAge = 14, maxAge = 20,
		weight = 10, oneTime = true,
		emoji = "👨‍💻", title = "First Hack",
		category = "school",
		requires = function(state) return state.Flags and state.Flags.computer_interest end,
		getDynamicData = function() return { targetSystem = "school grading system" } end,
		text = "You discovered you could hack into the %targetSystem%. What do you do?",
		choices = {
			{ text = "💻 Hack it!", effects = { Smarts = 6, Happiness = 5 }, resultText = "You got in! The power is intoxicating.", setFlag = "hacker_skills" },
			{ text = "🛑 Too risky", effects = { Smarts = 2 }, resultText = "You decided not to risk it." },
			{ text = "📢 Report the vulnerability", effects = { Smarts = 4, Happiness = 3 }, resultText = "You reported it responsibly. The IT department thanked you.", setFlag = "white_hat" },
		},
	},
	
	{
		id = "art_competition",
		minAge = 14, maxAge = 22,
		weight = 12, oneTime = true,
		emoji = "🏆", title = "Art Competition",
		category = "school",
		requires = function(state) return state.Flags and state.Flags.art_interest end,
		getDynamicData = function() return { competitionName = "Regional Young Artists", artStyle = randomArtStyle() } end,
		text = "The %competitionName% competition is accepting entries. Your %artStyle% piece could win!",
		choices = {
			{ text = "🎨 Enter the competition!", effects = { Smarts = 3, Happiness = 8 }, resultText = "You won first place! Your artistic future looks bright.", setFlag = "award_winning_artist" },
			{ text = "😰 Not ready yet", effects = { Happiness = -2 }, resultText = "You didn't enter. Maybe next time." },
		},
	},
	
	{
		id = "karting_championship",
		minAge = 12, maxAge = 18,
		weight = 10, oneTime = true,
		emoji = "🏆", title = "Karting Championship",
		category = "social",
		requires = function(state) return state.Flags and state.Flags.racing_interest end,
		getDynamicData = function() return { trackName = "Thunder Valley Speedway" } end,
		text = "There's a regional karting championship at %trackName%. You could enter!",
		choices = {
			{ text = "🏎️ Race to win!", effects = { Happiness = 10, Health = 3 }, resultText = "You won the championship! Racing scouts noticed you.", setFlag = "karting_champion", minigame = "qte" },
			{ text = "🏎️ Race for fun", effects = { Happiness = 5 }, resultText = "You had a great time but didn't push for the win." },
		},
	},
	
	{
		id = "drivers_license",
		minAge = 16, maxAge = 17,
		weight = 80, oneTime = true, milestone = true,
		emoji = "🚗", title = "Driving Test!",
		category = "school",
		text = "Time to get your driver's license!",
		choices = {
			{ text = "📚 Study hard, ace it", effects = { Smarts = 3, Happiness = 8 }, resultText = "You passed on your first try!", setFlag = "has_license" },
			{ text = "🤷 Wing it", effects = { Happiness = -5 }, resultText = "You failed. Parallel parking got you." },
		},
	},
	
	{
		id = "high_school_graduation",
		minAge = 18, maxAge = 18,
		weight = 100, oneTime = true, milestone = true,
		emoji = "🎓", title = "High School Graduation!",
		category = "school",
		text = "You did it! What's next?",
		choices = {
			{ text = "🏛️ Go to college", effects = { Smarts = 10, Money = -5000 }, resultText = "College bound!", setFlag = "college_student" },
			{ text = "💼 Start working", effects = { Money = 1000 }, resultText = "You entered the workforce.", setFlag = "job_hunting" },
			{ text = "🔧 Trade school", effects = { Smarts = 6, Money = -2000 }, resultText = "You learned practical skills.", setFlag = "trade_student" },
		},
	},

	-- ═══════════════════════════════════════════════════════════════
	-- PRESIDENT PATH (18 Events)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "political_internship",
		minAge = 18, maxAge = 25,
		weight = 15, oneTime = true,
		emoji = "📋", title = "Political Internship",
		category = "work",
		requires = function(state) return state.Flags and state.Flags.political_interest and not state.Flags.political_intern end,
		getDynamicData = function() return { politicianTitle = "Senator", politicianName = randomName() } end,
		text = "You got offered an internship with %politicianTitle% %politicianName%!",
		choices = {
			{ text = "✅ Take it!", effects = { Smarts = 5, Happiness = 4 }, resultText = "You learned the ins and outs of politics.", setFlag = "political_intern" },
			{ text = "❌ Not interested", effects = {}, resultText = "You passed." },
		},
	},
	
	{
		id = "campaign_volunteer",
		minAge = 18, maxAge = 40,
		weight = 12, oneTime = true,
		emoji = "📢", title = "Campaign Volunteer",
		category = "work",
		requires = function(state) return state.Flags and state.Flags.political_interest and not state.Flags.campaign_experience end,
		getDynamicData = function() return { candidateName = randomName() } end,
		text = "%candidateName% is running for office and needs volunteers.",
		choices = {
			{ text = "📢 Join the campaign!", effects = { Smarts = 4, Happiness = 5 }, resultText = "You learned how campaigns really work.", setFlag = "campaign_experience" },
			{ text = "🙅 Too busy", effects = {}, resultText = "You had other priorities." },
		},
	},
	
	{
		id = "run_school_board",
		minAge = 25, maxAge = 50,
		weight = 10, oneTime = true,
		emoji = "🏫", title = "School Board Election",
		category = "work",
		requires = function(state) 
			local f = state.Flags or {}
			return f.political_interest and (f.political_intern or f.campaign_experience) and not f.elected_official
		end,
		text = "There's an opening on the local school board. It's your first shot at elected office!",
		choices = {
			{ text = "🗳️ Run for school board!", effects = { Smarts = 4, Happiness = 6, Money = -1000 }, resultText = "You won! Your political career begins.", setFlags = {"school_board", "elected_official"} },
			{ text = "⏳ Not ready yet", effects = {}, resultText = "You decided to wait." },
		},
	},
	
	{
		id = "run_city_council",
		minAge = 26, maxAge = 55,
		weight = 10, oneTime = true,
		emoji = "🏛️", title = "City Council Race",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.elected_official and f.school_board and not f.city_council
		end,
		text = "A city council seat is opening up. Step up from school board?",
		choices = {
			{ text = "🗳️ Run for city council!", effects = { Smarts = 5, Happiness = 7, Money = -3000 }, resultText = "You won the city council seat!", setFlag = "city_council", minigame = "debate" },
			{ text = "⏳ Stay where I am", effects = {}, resultText = "You built more experience first." },
		},
	},
	
	{
		id = "run_mayor",
		minAge = 30, maxAge = 60,
		weight = 8, oneTime = true,
		emoji = "🏙️", title = "Mayoral Election!",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.city_council and not f.mayor
		end,
		text = "The mayoral election is coming. You have enough support to run!",
		choices = {
			{ text = "🗳️ Run for Mayor!", effects = { Smarts = 6, Happiness = 8, Money = -10000 }, resultText = "You're now the Mayor!", setFlag = "mayor", minigame = "debate" },
			{ text = "⏳ Not my time", effects = {}, resultText = "You stayed on council." },
		},
	},
	
	{
		id = "run_state_rep",
		minAge = 28, maxAge = 60,
		weight = 8, oneTime = true,
		emoji = "🏛️", title = "State Legislature Race",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return (f.mayor or f.city_council) and not f.state_rep
		end,
		text = "There's an opening in the state legislature. Go to the state capital?",
		choices = {
			{ text = "🗳️ Run for state rep!", effects = { Smarts = 6, Happiness = 8, Money = -15000 }, resultText = "You're now a state representative!", setFlag = "state_rep", minigame = "debate" },
			{ text = "⏳ Local is fine", effects = {}, resultText = "You focused on local issues." },
		},
	},
	
	{
		id = "run_governor",
		minAge = 35, maxAge = 65,
		weight = 6, oneTime = true,
		emoji = "🏛️", title = "Governor's Race!",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return (f.state_rep or f.mayor) and not f.governor
		end,
		getDynamicData = function()
			local states = {"California","Texas","New York","Florida","Illinois","Pennsylvania"}
			return { stateName = states[math.random(#states)] }
		end,
		text = "The governorship of %stateName% is up for election!",
		choices = {
			{ text = "🗳️ Run for Governor!", effects = { Smarts = 8, Happiness = 10, Money = -100000 }, resultText = "You're now the Governor!", setFlag = "governor", minigame = "debate" },
			{ text = "⏳ Not ready", effects = {}, resultText = "You stayed in the legislature." },
		},
	},
	
	{
		id = "run_congress",
		minAge = 30, maxAge = 70,
		weight = 5, oneTime = true,
		emoji = "🏛️", title = "Congressional Race!",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return (f.state_rep or f.governor) and not f.congressman
		end,
		text = "A congressional seat is open. Time to go to Washington?",
		choices = {
			{ text = "🗳️ Run for Congress!", effects = { Smarts = 8, Happiness = 10, Money = -200000 }, resultText = "You're going to Washington!", setFlag = "congressman", minigame = "debate" },
			{ text = "⏳ State politics is enough", effects = {}, resultText = "You stayed in state politics." },
		},
	},
	
	{
		id = "run_us_senate",
		minAge = 35, maxAge = 75,
		weight = 4, oneTime = true,
		emoji = "🏛️", title = "U.S. Senate Race!",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return (f.congressman or f.governor) and not f.us_senator
		end,
		text = "A U.S. Senate seat is opening. This is the big leagues.",
		choices = {
			{ text = "🗳️ Run for U.S. Senate!", effects = { Smarts = 10, Happiness = 12, Money = -500000 }, resultText = "You're a United States Senator!", setFlag = "us_senator", clearFlag = "congressman", minigame = "debate" },
			{ text = "⏳ The House is fine", effects = {}, resultText = "You stayed in the House." },
		},
	},
	
	{
		id = "presidential_primary",
		minAge = 40, maxAge = 75,
		weight = 3, oneTime = true,
		emoji = "🇺🇸", title = "Presidential Primary!",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return (f.us_senator or f.governor) and not f.presidential_candidate and (state.Age or 0) >= 35
		end,
		text = "Your party is looking for a presidential candidate. They want you!",
		choices = {
			{ text = "🇺🇸 Enter the race!", effects = { Smarts = 10, Happiness = 10, Money = -1000000 }, resultText = "You entered the presidential primary!", setFlag = "presidential_candidate" },
			{ text = "⏳ Maybe next cycle", effects = {}, resultText = "You decided to wait." },
		},
	},
	
	{
		id = "presidential_debate",
		minAge = 40, maxAge = 75,
		weight = 80, oneTime = true,
		emoji = "🎤", title = "Presidential Debate!",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.presidential_candidate and not f.won_debate
		end,
		getDynamicData = function() return { opponentName = randomName() } end,
		text = "Tonight you debate %opponentName% in front of millions!",
		choices = {
			{ text = "🎤 Debate with confidence!", effects = { Smarts = 8, Happiness = 10 }, resultText = "You dominated the debate!", setFlag = "won_debate", minigame = "debate" },
			{ text = "📚 Play it safe", effects = { Smarts = 5 }, resultText = "You played it safe. Neither gained nor lost." },
		},
	},
	
	{
		id = "presidential_election",
		minAge = 40, maxAge = 75,
		weight = 100, oneTime = true, milestone = true,
		emoji = "🇺🇸", title = "PRESIDENTIAL ELECTION!",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.presidential_candidate and f.won_debate and not f.president
		end,
		text = "Election night. Your entire political career has led to this moment.",
		choices = {
			{ text = "🗳️ Watch the results", effects = { Happiness = 30, Smarts = 10 }, resultText = "YOU WON! You are the President-Elect!", setFlag = "president", clearFlags = {"us_senator", "governor", "congressman", "presidential_candidate"} },
		},
	},
	
	{
		id = "inauguration",
		minAge = 40, maxAge = 80,
		weight = 100, oneTime = true, milestone = true,
		emoji = "🎉", title = "Inauguration Day!",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.president and not f.inaugurated
		end,
		text = "You stand before the nation, about to take the oath of office.",
		choices = {
			{ text = "✋ Take the oath", effects = { Happiness = 30 }, resultText = "You are now the President of the United States.", setFlag = "inaugurated" },
		},
	},
	
	{
		id = "presidential_crisis",
		minAge = 40, maxAge = 80,
		weight = 15, cooldown = 2,
		emoji = "🚨", title = "National Crisis!",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.president and f.inaugurated
		end,
		getDynamicData = function()
			local crises = {"Economic Recession","Natural Disaster","International Incident","Pandemic Outbreak"}
			return { crisisName = crises[math.random(#crises)] }
		end,
		text = "BREAKING: %crisisName%! The nation looks to you for leadership.",
		choices = {
			{ text = "📺 Address the nation", effects = { Happiness = 8, Smarts = 5 }, resultText = "Your address calmed the nation." },
			{ text = "🏛️ Emergency legislation", effects = { Smarts = 8, Money = -500000 }, resultText = "You pushed through emergency measures." },
			{ text = "⏳ Wait and see", effects = { Happiness = -10 }, resultText = "Your inaction was criticized." },
		},
	},

	-- ═══════════════════════════════════════════════════════════════
	-- CRIMINAL PATH (20 Events)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "shoplifting_escalation",
		minAge = 12, maxAge = 25,
		weight = 12, oneTime = true,
		emoji = "🛒", title = "Getting Bolder",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.criminal_tendencies and not f.petty_thief
		end,
		text = "Shoplifting small items was easy. Now you're eyeing bigger targets.",
		choices = {
			{ text = "🛒 Steal something expensive", effects = { Happiness = 5, Money = 200 }, resultText = "You walked out with something valuable.", setFlag = "petty_thief" },
			{ text = "🛑 Stop while ahead", effects = { Smarts = 3 }, resultText = "You decided crime wasn't worth it.", clearFlag = "criminal_tendencies" },
		},
	},
	
	{
		id = "car_theft",
		minAge = 16, maxAge = 30,
		weight = 10, oneTime = true,
		emoji = "🚗", title = "Grand Theft Auto",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.petty_thief and not f.car_thief
		end,
		text = "That car's been sitting there all week. Keys might be inside...",
		choices = {
			{ text = "🚗 Steal it!", effects = { Happiness = 8, Money = 2000 }, resultText = "You took the car and sold it.", setFlag = "car_thief", minigame = "heist" },
			{ text = "🚨 Too risky", effects = { Smarts = 3 }, resultText = "Grand theft auto is serious. You walked away." },
		},
	},
	
	{
		id = "first_arrest",
		minAge = 14, maxAge = 40,
		weight = 15, oneTime = true,
		emoji = "🚔", title = "Busted!",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return (f.petty_thief or f.car_thief) and not f.arrested
		end,
		text = "The cops caught up with you!",
		choices = {
			{ text = "🤐 Stay silent", effects = { Smarts = 5 }, resultText = "You kept quiet. Lighter sentence.", setFlag = "arrested" },
			{ text = "🐀 Cooperate", effects = { Happiness = -10 }, resultText = "You snitched. You got off but made enemies.", setFlags = {"arrested", "snitch"} },
			{ text = "🏃 Try to run", effects = { Health = -15 }, resultText = "They tackled you. Extra charges.", setFlag = "arrested", minigame = "getaway" },
		},
	},
	
	{
		id = "prison_short",
		minAge = 16, maxAge = 60,
		weight = 20, oneTime = true,
		emoji = "⛓️", title = "Behind Bars",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.arrested and not f.did_time
		end,
		getDynamicData = function() return { years = math.random(1, 3) } end,
		text = "You've been sentenced to %years% years in prison.",
		choices = {
			{ text = "💪 Do your time", effects = { Health = -10, Smarts = 2 }, resultText = "You came out harder.", setFlag = "did_time" },
			{ text = "📚 Use time productively", effects = { Smarts = 8, Health = -5 }, resultText = "You got your GED and read hundreds of books.", setFlags = {"did_time", "prison_educated"} },
			{ text = "💪 Work out constantly", effects = { Health = 10, Looks = 3 }, resultText = "You got jacked.", setFlags = {"did_time", "prison_muscles"} },
		},
	},
	
	{
		id = "gang_recruitment",
		minAge = 16, maxAge = 35,
		weight = 10, oneTime = true,
		emoji = "👥", title = "Gang Invitation",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return (f.car_thief or f.did_time) and not f.gang_member and not f.snitch
		end,
		getDynamicData = function()
			local gangs = {"The Vipers","Street Kings","Black Aces","Los Diablos","The Syndicate"}
			return { gangName = gangs[math.random(#gangs)], recruiterName = randomName() }
		end,
		text = "%recruiterName% from %gangName% noticed you. They're offering you a spot.",
		choices = {
			{ text = "✅ Join the gang", effects = { Happiness = 8, Money = 3000 }, resultText = "You're officially part of %gangName%.", setFlags = {"gang_member", "gang_prospect"} },
			{ text = "❌ Stay independent", effects = { Happiness = -3 }, resultText = "You said no. They didn't take it well." },
		},
	},
	
	{
		id = "gang_initiation",
		minAge = 16, maxAge = 40,
		weight = 30, oneTime = true,
		emoji = "🔥", title = "Gang Initiation",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.gang_prospect and not f.initiated
		end,
		text = "To prove your loyalty, you need to pass the initiation.",
		choices = {
			{ text = "💪 Do whatever it takes", effects = { Health = -10, Happiness = 5 }, resultText = "You're now a full member.", setFlag = "initiated", clearFlag = "gang_prospect" },
			{ text = "🏃 I'm out", effects = { Health = -5, Happiness = -5 }, resultText = "You tried to leave. They made sure you'd remember.", clearFlags = {"gang_member", "gang_prospect"} },
		},
	},
	
	{
		id = "drug_dealing",
		minAge = 18, maxAge = 50,
		weight = 12, oneTime = true,
		emoji = "💊", title = "Moving Product",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.gang_member and f.initiated and not f.drug_dealer
		end,
		text = "The gang wants you to start dealing. Good money, high risk.",
		choices = {
			{ text = "💊 Start dealing", effects = { Money = 5000, Smarts = 2 }, resultText = "The money flows in.", setFlag = "drug_dealer" },
			{ text = "🔫 Prefer other work", effects = {}, resultText = "You stuck to other gang activities." },
		},
	},
	
	{
		id = "turf_war",
		minAge = 18, maxAge = 50,
		weight = 15, cooldown = 2,
		emoji = "⚔️", title = "Turf War!",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.gang_member and f.initiated
		end,
		getDynamicData = function() return { rivalGang = randomHackerGroup() } end,
		text = "%rivalGang% is moving in on your territory. War is coming.",
		choices = {
			{ text = "⚔️ Fight for territory", effects = { Health = -15, Money = 5000, Happiness = 5 }, resultText = "You won. Your reputation grew.", setFlag = "turf_warrior", minigame = "getaway" },
			{ text = "🤝 Negotiate peace", effects = { Smarts = 5 }, resultText = "You brokered a peace deal." },
		},
	},
	
	{
		id = "gang_captain",
		minAge = 22, maxAge = 50,
		weight = 8, oneTime = true,
		emoji = "⭐", title = "Moving Up",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.gang_member and f.initiated and (f.turf_warrior or f.drug_dealer) and not f.gang_captain
		end,
		text = "The boss noticed your work. You're being promoted to captain.",
		choices = {
			{ text = "⭐ Accept", effects = { Happiness = 10, Money = 10000 }, resultText = "You have soldiers under your command.", setFlag = "gang_captain" },
		},
	},
	
	{
		id = "heist_opportunity",
		minAge = 20, maxAge = 55,
		weight = 8, cooldown = 3,
		emoji = "💰", title = "The Big Score",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.gang_captain
		end,
		getDynamicData = function()
			local targets = {"armored truck","bank vault","jewelry store","casino vault"}
			return { target = targets[math.random(#targets)] }
		end,
		text = "An opportunity to hit a %target%. The take could be massive.",
		choices = {
			{ text = "💰 Plan the heist", effects = { Money = 100000, Happiness = 10 }, resultText = "The heist went perfectly!", setFlag = "master_thief", minigame = "heist" },
			{ text = "🚨 Too risky", effects = { Smarts = 3 }, resultText = "You passed. Sometimes caution is wisdom." },
		},
	},
	
	{
		id = "underboss_promotion",
		minAge = 28, maxAge = 55,
		weight = 5, oneTime = true,
		emoji = "👔", title = "Underboss",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.gang_captain and f.master_thief and not f.underboss
		end,
		text = "The boss wants to make you underboss. Second in command.",
		choices = {
			{ text = "👔 Accept the position", effects = { Happiness = 15, Money = 50000 }, resultText = "You're now the underboss.", setFlag = "underboss" },
		},
	},
	
	{
		id = "take_over_gang",
		minAge = 30, maxAge = 60,
		weight = 4, oneTime = true,
		emoji = "👑", title = "Power Grab",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.underboss and not f.crime_boss
		end,
		getDynamicData = function() return { bossName = randomName() } end,
		text = "The boss %bossName% is getting weak. You could take over.",
		choices = {
			{ text = "👑 Make your move", effects = { Happiness = 20, Money = 200000, Health = -10 }, resultText = "You're now the boss. The whole empire is yours.", setFlag = "crime_boss", clearFlag = "underboss" },
			{ text = "🤝 Stay loyal", effects = { Happiness = 5 }, resultText = "You stayed loyal. The boss appreciated it." },
		},
	},
	
	{
		id = "crime_empire",
		minAge = 32, maxAge = 70,
		weight = 100, oneTime = true, milestone = true,
		emoji = "🏰", title = "Criminal Empire",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.crime_boss and not f.empire_built
		end,
		text = "You run the organization now. Time to expand your empire.",
		choices = {
			{ text = "🌆 Expand the empire", effects = { Money = 500000, Happiness = 15 }, resultText = "Your criminal empire spans multiple cities.", setFlag = "empire_built" },
		},
	},
	
	{
		id = "feds_closing_in",
		minAge = 25, maxAge = 70,
		weight = 8, cooldown = 5,
		emoji = "🕵️", title = "Feds Closing In",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.crime_boss or f.underboss
		end,
		getDynamicData = function() return { agentName = randomName() } end,
		text = "FBI Agent %agentName% is building a case against you.",
		choices = {
			{ text = "🏃 Lay low", effects = { Happiness = -5, Smarts = 5 }, resultText = "You went underground. The heat cooled down." },
			{ text = "💰 Bribe officials", effects = { Money = -50000 }, resultText = "The case mysteriously disappeared." },
			{ text = "⚔️ Send a message", effects = { Health = -5, Happiness = 5 }, resultText = "The agent backed off. For now.", minigame = "getaway" },
		},
	},

	-- ═══════════════════════════════════════════════════════════════
	-- TEACHER PATH (15 Events)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "education_degree",
		minAge = 18, maxAge = 25,
		weight = 15, oneTime = true,
		emoji = "🎓", title = "Education Major",
		category = "school",
		requires = function(state)
			local f = state.Flags or {}
			return f.teaching_interest and f.college_student and not f.education_degree
		end,
		getDynamicData = function() return { university = randomUniversity() } end,
		text = "You're majoring in Education at %university%!",
		choices = {
			{ text = "📚 Study hard", effects = { Smarts = 8 }, resultText = "You're becoming an excellent educator.", setFlag = "education_degree" },
		},
	},
	
	{
		id = "student_teaching",
		minAge = 21, maxAge = 28,
		weight = 15, oneTime = true,
		emoji = "👨‍🏫", title = "Student Teaching",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.education_degree and not f.student_taught
		end,
		getDynamicData = function() return { school = randomSchool() } end,
		text = "Time for student teaching at %school%!",
		choices = {
			{ text = "👨‍🏫 Do my best", effects = { Smarts = 5, Happiness = 5 }, resultText = "The students loved you!", setFlag = "student_taught" },
			{ text = "😰 Nervous but try", effects = { Smarts = 3, Happiness = 3 }, resultText = "Rough start but you improved.", setFlag = "student_taught" },
		},
	},
	
	{
		id = "first_teaching_job",
		minAge = 22, maxAge = 35,
		weight = 15, oneTime = true,
		emoji = "🏫", title = "First Teaching Job!",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.student_taught and not f.teacher
		end,
		getDynamicData = function() return { school = randomSchool() } end,
		text = "%school% is offering you a teaching position!",
		choices = {
			{ text = "✅ Accept the job!", effects = { Happiness = 10, Money = 2000 }, resultText = "You're officially a teacher!", setFlag = "teacher" },
		},
	},
	
	{
		id = "difficult_student",
		minAge = 23, maxAge = 60,
		weight = 12, cooldown = 2,
		emoji = "😤", title = "Difficult Student",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.teacher
		end,
		getDynamicData = function() return { studentName = randomName() } end,
		text = "%studentName% is being disruptive in class again.",
		choices = {
			{ text = "📞 Call parents", effects = { Smarts = 3 }, resultText = "The parents were helpful. The behavior improved." },
			{ text = "🤝 Connect one-on-one", effects = { Happiness = 5, Smarts = 3 }, resultText = "You discovered they were struggling at home. You became their mentor." },
			{ text = "📋 Send to principal", effects = { Happiness = -2 }, resultText = "The problem was passed on. Not a great solution." },
		},
	},
	
	{
		id = "inspiring_moment",
		minAge = 24, maxAge = 65,
		weight = 10, cooldown = 3,
		emoji = "✨", title = "Inspiring Moment",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.teacher
		end,
		getDynamicData = function() return { studentName = randomName() } end,
		text = "Former student %studentName% visited to thank you for changing their life.",
		choices = {
			{ text = "😭 Cry happy tears", effects = { Happiness = 15 }, resultText = "This is why you became a teacher." },
			{ text = "🤝 Stay humble", effects = { Happiness = 10, Smarts = 3 }, resultText = "You were proud but deflected the credit to them." },
		},
	},
	
	{
		id = "teacher_of_year",
		minAge = 28, maxAge = 60,
		weight = 8, oneTime = true,
		emoji = "🏆", title = "Teacher of the Year!",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.teacher and not f.teacher_award
		end,
		text = "You've been nominated for Teacher of the Year!",
		choices = {
			{ text = "🏆 Accept graciously", effects = { Happiness = 15, Money = 1000 }, resultText = "You won! Your dedication is recognized.", setFlag = "teacher_award" },
		},
	},
	
	{
		id = "department_head",
		minAge = 30, maxAge = 55,
		weight = 8, oneTime = true,
		emoji = "📋", title = "Department Head",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.teacher and f.teacher_award and not f.department_head
		end,
		text = "You're being offered the position of Department Head!",
		choices = {
			{ text = "✅ Accept", effects = { Happiness = 10, Money = 5000 }, resultText = "You're now leading the department.", setFlag = "department_head" },
			{ text = "❌ Stay in classroom", effects = { Happiness = 5 }, resultText = "You preferred teaching directly." },
		},
	},
	
	{
		id = "vice_principal",
		minAge = 35, maxAge = 60,
		weight = 6, oneTime = true,
		emoji = "🏫", title = "Vice Principal",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.department_head and not f.vice_principal
		end,
		getDynamicData = function() return { school = randomSchool() } end,
		text = "%school% is looking for a new Vice Principal. You're a top candidate!",
		choices = {
			{ text = "✅ Take the position", effects = { Happiness = 12, Money = 10000 }, resultText = "You're now Vice Principal!", setFlag = "vice_principal" },
			{ text = "❌ Stay in teaching", effects = { Happiness = 3 }, resultText = "You preferred the classroom." },
		},
	},
	
	{
		id = "principal",
		minAge = 40, maxAge = 65,
		weight = 5, oneTime = true,
		emoji = "🏫", title = "Principal!",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.vice_principal and not f.principal
		end,
		text = "The principal is retiring. You're next in line!",
		choices = {
			{ text = "👔 Become Principal", effects = { Happiness = 15, Money = 20000 }, resultText = "You're now the Principal!", setFlag = "principal" },
		},
	},
	
	{
		id = "superintendent",
		minAge = 45, maxAge = 70,
		weight = 4, oneTime = true, milestone = true,
		emoji = "🎓", title = "Superintendent!",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.principal and not f.superintendent
		end,
		text = "The school district wants you as Superintendent!",
		choices = {
			{ text = "✅ Lead the district", effects = { Happiness = 20, Money = 50000 }, resultText = "You're now shaping education for thousands of students.", setFlag = "superintendent" },
		},
	},

	-- ═══════════════════════════════════════════════════════════════
	-- RACER PATH (18 Events)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "karting_league",
		minAge = 12, maxAge = 18,
		weight = 10, oneTime = true,
		emoji = "🏎️", title = "Karting League",
		category = "social",
		requires = function(state)
			local f = state.Flags or {}
			return f.racing_interest and not f.karting_league
		end,
		getDynamicData = function() return { leagueName = "Junior Racing League" } end,
		text = "You've been accepted into the %leagueName%!",
		choices = {
			{ text = "🏎️ Join the league!", effects = { Happiness = 10, Health = 3 }, resultText = "You're officially a competitive racer!", setFlag = "karting_league" },
		},
	},
	
	{
		id = "karting_championship_win",
		minAge = 14, maxAge = 20,
		weight = 8, oneTime = true,
		emoji = "🏆", title = "Karting Championship!",
		category = "social",
		requires = function(state)
			local f = state.Flags or {}
			return f.karting_league and not f.karting_champion
		end,
		text = "The karting championship finals are here!",
		choices = {
			{ text = "🏆 Race to win!", effects = { Happiness = 15, Money = 5000 }, resultText = "You won the championship! Scouts are watching.", setFlag = "karting_champion", minigame = "qte" },
			{ text = "🏎️ Have fun", effects = { Happiness = 5 }, resultText = "You didn't win but had a great time." },
		},
	},
	
	{
		id = "junior_formula",
		minAge = 16, maxAge = 22,
		weight = 8, oneTime = true,
		emoji = "🏎️", title = "Junior Formula",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.karting_champion and not f.junior_formula
		end,
		getDynamicData = function() return { team = randomRacingTeam() } end,
		text = "%team%'s junior program wants to sign you!",
		choices = {
			{ text = "✅ Sign with the team!", effects = { Happiness = 15, Money = 10000 }, resultText = "You're now a junior formula driver!", setFlag = "junior_formula" },
		},
	},
	
	{
		id = "junior_championship",
		minAge = 18, maxAge = 24,
		weight = 8, oneTime = true,
		emoji = "🏆", title = "Junior Formula Championship",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.junior_formula and not f.junior_champion
		end,
		text = "The junior formula championship is within reach!",
		choices = {
			{ text = "🏆 Fight for the title!", effects = { Happiness = 15, Money = 25000 }, resultText = "You're the junior formula champion!", setFlag = "junior_champion", minigame = "qte" },
		},
	},
	
	{
		id = "f1_test_driver",
		minAge = 20, maxAge = 28,
		weight = 6, oneTime = true,
		emoji = "🏎️", title = "F1 Test Driver!",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.junior_champion and not f.f1_test_driver
		end,
		getDynamicData = function() return { team = randomRacingTeam() } end,
		text = "%team% wants you as their F1 test driver!",
		choices = {
			{ text = "✅ Accept!", effects = { Happiness = 20, Money = 100000 }, resultText = "You're now an F1 test driver!", setFlag = "f1_test_driver" },
		},
	},
	
	{
		id = "f1_race_driver",
		minAge = 21, maxAge = 35,
		weight = 5, oneTime = true,
		emoji = "🏎️", title = "F1 Race Seat!",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.f1_test_driver and not f.f1_driver
		end,
		getDynamicData = function() return { team = randomRacingTeam() } end,
		text = "A race seat at %team% has opened up! This is your chance!",
		choices = {
			{ text = "🏎️ Sign the contract!", effects = { Happiness = 25, Money = 500000 }, resultText = "You're now an F1 driver!", setFlag = "f1_driver", clearFlag = "f1_test_driver" },
		},
	},
	
	{
		id = "first_f1_race",
		minAge = 21, maxAge = 40,
		weight = 100, oneTime = true, milestone = true,
		emoji = "🏁", title = "First F1 Race!",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.f1_driver and not f.first_race_complete
		end,
		getDynamicData = function()
			local tracks = {"Monaco","Monza","Silverstone","Spa","Suzuka","Austin"}
			return { trackName = tracks[math.random(#tracks)] }
		end,
		text = "Your first F1 race at %trackName%! The whole world is watching.",
		choices = {
			{ text = "🏁 Give it everything!", effects = { Happiness = 20, Health = -5 }, resultText = "You finished in the points! Incredible debut.", setFlag = "first_race_complete", minigame = "qte" },
		},
	},
	
	{
		id = "first_f1_win",
		minAge = 22, maxAge = 42,
		weight = 6, oneTime = true,
		emoji = "🏆", title = "First F1 Victory!",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.f1_driver and f.first_race_complete and not f.f1_winner
		end,
		getDynamicData = function()
			local tracks = {"Monaco","Monza","Silverstone","Spa","Suzuka"}
			return { trackName = tracks[math.random(#tracks)] }
		end,
		text = "The %trackName% Grand Prix. You're leading on the final lap!",
		choices = {
			{ text = "🏆 Cross the line!", effects = { Happiness = 30, Money = 200000 }, resultText = "YOU WON YOUR FIRST F1 RACE!", setFlag = "f1_winner", minigame = "qte" },
		},
	},
	
	{
		id = "crash_incident",
		minAge = 21, maxAge = 45,
		weight = 8, cooldown = 2,
		emoji = "💥", title = "Race Incident!",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.f1_driver
		end,
		getDynamicData = function() return { rivalName = randomName() } end,
		text = "%rivalName% made an aggressive move! You're heading toward a crash!",
		choices = {
			{ text = "🏎️ Avoid collision", effects = { Smarts = 5, Happiness = 5 }, resultText = "You avoided the crash with incredible reflexes.", minigame = "qte" },
			{ text = "💥 Hold your line", effects = { Health = -20, Happiness = -10 }, resultText = "You crashed. Thankfully nothing serious." },
		},
	},
	
	{
		id = "f1_championship",
		minAge = 23, maxAge = 45,
		weight = 4, oneTime = true, milestone = true,
		emoji = "🏆", title = "F1 World Championship!",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.f1_winner and not f.world_champion
		end,
		text = "Final race of the season. Win this and you're World Champion!",
		choices = {
			{ text = "🏆 Win the championship!", effects = { Happiness = 50, Money = 5000000 }, resultText = "YOU ARE THE FORMULA 1 WORLD CHAMPION!", setFlag = "world_champion", minigame = "qte" },
		},
	},
	
	{
		id = "racing_legend",
		minAge = 30, maxAge = 50,
		weight = 3, oneTime = true, milestone = true,
		emoji = "👑", title = "Racing Legend",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.world_champion and not f.racing_legend
		end,
		text = "Multiple championships, countless wins. You're being inducted into the Racing Hall of Fame.",
		choices = {
			{ text = "👑 Accept the honor", effects = { Happiness = 40, Money = 1000000 }, resultText = "You're officially a racing legend.", setFlag = "racing_legend" },
		},
	},

	-- ═══════════════════════════════════════════════════════════════
	-- ARTIST PATH (15 Events)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "art_school",
		minAge = 18, maxAge = 25,
		weight = 15, oneTime = true,
		emoji = "🎨", title = "Art School",
		category = "school",
		requires = function(state)
			local f = state.Flags or {}
			return f.art_interest and (f.college_student or f.trade_student) and not f.art_school
		end,
		getDynamicData = function() return { school = "Rhode Island School of Design" } end,
		text = "You've been accepted to %school%!",
		choices = {
			{ text = "🎨 Enroll!", effects = { Smarts = 8, Happiness = 10 }, resultText = "You're now studying art professionally!", setFlag = "art_school" },
		},
	},
	
	{
		id = "first_gallery_show",
		minAge = 20, maxAge = 35,
		weight = 12, oneTime = true,
		emoji = "🖼️", title = "First Gallery Show",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return (f.art_school or f.award_winning_artist) and not f.gallery_show
		end,
		getDynamicData = function() return { galleryName = "Blue Moon Gallery" } end,
		text = "%galleryName% wants to feature your work!",
		choices = {
			{ text = "🖼️ Show my art!", effects = { Happiness = 15, Money = 2000 }, resultText = "Your first gallery show was a hit!", setFlag = "gallery_show" },
		},
	},
	
	{
		id = "art_style_development",
		minAge = 22, maxAge = 40,
		weight = 10, oneTime = true,
		emoji = "✨", title = "Finding Your Voice",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.gallery_show and not f.signature_style
		end,
		getDynamicData = function() return { style = randomArtStyle() } end,
		text = "Critics are noticing your unique %style% approach.",
		choices = {
			{ text = "🎨 Double down on style", effects = { Smarts = 5, Happiness = 10 }, resultText = "You've developed a signature style.", setFlag = "signature_style" },
			{ text = "🔄 Keep experimenting", effects = { Smarts = 8 }, resultText = "You continued exploring different styles." },
		},
	},
	
	{
		id = "first_sale",
		minAge = 21, maxAge = 50,
		weight = 12, oneTime = true,
		emoji = "💰", title = "First Major Sale",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.gallery_show and not f.sold_artwork
		end,
		getDynamicData = function() return { buyerName = randomName(), amount = math.random(5, 50) * 1000 } end,
		text = "Collector %buyerName% wants to buy your piece for $%amount%!",
		choices = {
			{ text = "💰 Sell it!", effects = { Happiness = 15, Money = 25000 }, resultText = "You sold your first major piece!", setFlag = "sold_artwork" },
			{ text = "❤️ Keep it", effects = { Happiness = 5 }, resultText = "Some pieces are too personal to sell." },
		},
	},
	
	{
		id = "art_critic_review",
		minAge = 23, maxAge = 60,
		weight = 10, cooldown = 2,
		emoji = "📰", title = "Art Critic Review",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.gallery_show
		end,
		getDynamicData = function() return { criticName = randomName(), publication = "Art Weekly" } end,
		text = "Renowned critic %criticName% from %publication% is reviewing your work.",
		choices = {
			{ text = "🙏 Hope for the best", effects = { Happiness = 10, Money = 5000 }, resultText = "They loved it! Your prices just went up." },
			{ text = "😬 Prepare for criticism", effects = { Happiness = -5, Smarts = 5 }, resultText = "Mixed review. You learned from the feedback." },
		},
	},
	
	{
		id = "commissioned_work",
		minAge = 25, maxAge = 65,
		weight = 10, cooldown = 2,
		emoji = "📜", title = "Commissioned Work",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.signature_style or f.sold_artwork
		end,
		getDynamicData = function() 
			local clients = {"tech billionaire","museum","celebrity","corporation"}
			return { clientType = clients[math.random(#clients)] }
		end,
		text = "A %clientType% wants to commission a piece from you!",
		choices = {
			{ text = "🎨 Accept commission", effects = { Money = 50000, Happiness = 10 }, resultText = "You created something amazing." },
			{ text = "❌ Decline", effects = { Happiness = 3 }, resultText = "You only work on your own terms." },
		},
	},
	
	{
		id = "museum_collection",
		minAge = 30, maxAge = 70,
		weight = 6, oneTime = true,
		emoji = "🏛️", title = "Museum Acquisition",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.signature_style and f.sold_artwork and not f.museum_piece
		end,
		getDynamicData = function()
			local museums = {"MoMA","The Met","Tate Modern","Guggenheim","Louvre"}
			return { museum = museums[math.random(#museums)] }
		end,
		text = "The %museum% wants to acquire one of your pieces!",
		choices = {
			{ text = "🏛️ Agree!", effects = { Happiness = 25, Money = 100000 }, resultText = "Your art is now in a world-famous museum!", setFlag = "museum_piece" },
		},
	},
	
	{
		id = "art_celebrity",
		minAge = 30, maxAge = 70,
		weight = 5, oneTime = true, milestone = true,
		emoji = "⭐", title = "Art World Celebrity",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.museum_piece and not f.art_celebrity
		end,
		text = "You're being interviewed on major news networks. Everyone knows your name.",
		choices = {
			{ text = "⭐ Embrace fame", effects = { Happiness = 20, Money = 200000 }, resultText = "You're now a household name in the art world.", setFlag = "art_celebrity" },
		},
	},
	
	{
		id = "art_retrospective",
		minAge = 45, maxAge = 80,
		weight = 4, oneTime = true, milestone = true,
		emoji = "🎭", title = "Career Retrospective",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.art_celebrity and not f.art_legend
		end,
		getDynamicData = function() return { museum = "The Whitney" } end,
		text = "%museum% wants to do a full retrospective of your life's work.",
		choices = {
			{ text = "🎭 A fitting tribute", effects = { Happiness = 30, Money = 500000 }, resultText = "Your legacy is cemented in art history.", setFlag = "art_legend" },
		},
	},

	-- ═══════════════════════════════════════════════════════════════
	-- HACKER PATH (18 Events)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "learn_programming",
		minAge = 12, maxAge = 20,
		weight = 15, oneTime = true,
		emoji = "💻", title = "Learning to Code",
		category = "school",
		requires = function(state)
			local f = state.Flags or {}
			return f.computer_interest and not f.programmer
		end,
		text = "You started learning to program. The code makes sense to you.",
		choices = {
			{ text = "💻 Dive deep", effects = { Smarts = 8 }, resultText = "You became fluent in multiple programming languages.", setFlag = "programmer" },
			{ text = "🤷 Just basics", effects = { Smarts = 3 }, resultText = "You learned the fundamentals." },
		},
	},
	
	{
		id = "first_exploit",
		minAge = 14, maxAge = 25,
		weight = 12, oneTime = true,
		emoji = "🔓", title = "First Exploit",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.hacker_skills and not f.first_exploit
		end,
		text = "You discovered a security vulnerability in a major website.",
		choices = {
			{ text = "💻 Exploit it", effects = { Smarts = 5, Money = 1000 }, resultText = "You're in their system. What power.", setFlag = "first_exploit", setFlags = {"black_hat"} },
			{ text = "📧 Report it responsibly", effects = { Smarts = 6, Money = 500 }, resultText = "They paid you a bug bounty. Ethical hacking pays.", setFlag = "first_exploit", setFlags = {"white_hat"} },
		},
	},
	
	{
		id = "join_hacker_group",
		minAge = 16, maxAge = 35,
		weight = 10, oneTime = true,
		emoji = "👥", title = "Hacker Collective",
		category = "social",
		requires = function(state)
			local f = state.Flags or {}
			return f.black_hat and not f.hacker_group
		end,
		getDynamicData = function() return { groupName = randomHackerGroup() } end,
		text = "%groupName% noticed your skills. They want you to join.",
		choices = {
			{ text = "👥 Join the collective", effects = { Happiness = 10, Smarts = 5 }, resultText = "You're now part of an elite hacker group.", setFlag = "hacker_group" },
			{ text = "🐺 Work alone", effects = { Smarts = 3 }, resultText = "You preferred to be a lone wolf." },
		},
	},
	
	{
		id = "corporate_hack",
		minAge = 18, maxAge = 40,
		weight = 10, cooldown = 2,
		emoji = "🏢", title = "Corporate Target",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.black_hat and (f.hacker_group or f.first_exploit)
		end,
		getDynamicData = function() return { company = "MegaCorp Industries" } end,
		text = "%company% has terrible security. Their database is wide open.",
		choices = {
			{ text = "💻 Breach their systems", effects = { Money = 10000, Smarts = 5 }, resultText = "You got valuable data. Sold it on the dark web.", minigame = "heist" },
			{ text = "🛑 Too risky", effects = { Smarts = 2 }, resultText = "Corporations have resources to hunt you down." },
		},
	},
	
	{
		id = "cybersecurity_job_offer",
		minAge = 20, maxAge = 40,
		weight = 10, oneTime = true,
		emoji = "💼", title = "Cybersecurity Job",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.white_hat and not f.hacker_career
		end,
		getDynamicData = function() return { company = "SecureTech Inc" } end,
		text = "%company% wants to hire you as a security researcher!",
		choices = {
			{ text = "💼 Take the job", effects = { Happiness = 10, Money = 5000 }, resultText = "You're now a professional white-hat hacker.", setFlag = "hacker_career" },
			{ text = "🐺 Stay independent", effects = { Happiness = 3 }, resultText = "You preferred freelance work." },
		},
	},
	
	{
		id = "government_target",
		minAge = 20, maxAge = 45,
		weight = 6, oneTime = true,
		emoji = "🏛️", title = "Government Systems",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.black_hat and f.hacker_group and not f.hacked_government
		end,
		text = "The group has a target: government classified systems.",
		choices = {
			{ text = "💻 Hack the government", effects = { Smarts = 10, Happiness = 10 }, resultText = "You breached classified systems. Now you know secrets.", setFlag = "hacked_government", minigame = "heist" },
			{ text = "🛑 Too dangerous", effects = { Smarts = 3 }, resultText = "Government hackers get prison, not bail." },
		},
	},
	
	{
		id = "fbi_investigation",
		minAge = 20, maxAge = 50,
		weight = 10, cooldown = 3,
		emoji = "🕵️", title = "FBI Investigation",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.black_hat and (f.hacked_government or f.hacker_group)
		end,
		getDynamicData = function() return { agentName = randomName() } end,
		text = "FBI Cyber Division is investigating you. Agent %agentName% is on your trail.",
		choices = {
			{ text = "🖥️ Cover your tracks", effects = { Smarts = 8 }, resultText = "You erased all evidence. They can't touch you.", minigame = "heist" },
			{ text = "🏃 Go dark", effects = { Happiness = -5, Smarts = 5 }, resultText = "You disappeared from the digital world for a while." },
			{ text = "🔄 Flip to their side", effects = { Happiness = 5, Money = 10000 }, resultText = "You became an FBI consultant. Immunity in exchange for skills.", setFlag = "fbi_consultant", clearFlags = {"black_hat", "hacker_group"} },
		},
	},
	
	{
		id = "whistleblower_leak",
		minAge = 22, maxAge = 50,
		weight = 6, oneTime = true,
		emoji = "📢", title = "Whistleblower Leak",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.hacked_government and not f.whistleblower_hacker
		end,
		text = "You found evidence of government crimes. Leak it to journalists?",
		choices = {
			{ text = "📢 Leak it all", effects = { Happiness = 15, Smarts = 5 }, resultText = "The world knows the truth. You're a hero to some.", setFlag = "whistleblower_hacker" },
			{ text = "🤐 Keep it secret", effects = { Smarts = 3 }, resultText = "Some secrets are too dangerous to reveal." },
		},
	},
	
	{
		id = "elite_hacker",
		minAge = 25, maxAge = 50,
		weight = 5, oneTime = true, milestone = true,
		emoji = "👑", title = "Elite Hacker Status",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return (f.hacked_government or f.hacker_career) and not f.elite_hacker
		end,
		text = "You're now considered one of the world's top hackers.",
		choices = {
			{ text = "👑 Accept the title", effects = { Happiness = 20, Smarts = 10 }, resultText = "You've reached the pinnacle of your field.", setFlag = "elite_hacker" },
		},
	},
	
	{
		id = "startup_founder",
		minAge = 25, maxAge = 45,
		weight = 6, oneTime = true,
		emoji = "🚀", title = "Tech Startup",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return (f.hacker_career or f.programmer) and not f.startup_founder
		end,
		getDynamicData = function() return { startupName = "CyberShield" } end,
		text = "You could start your own cybersecurity company: %startupName%.",
		choices = {
			{ text = "🚀 Start the company", effects = { Happiness = 15, Money = -50000 }, resultText = "You founded %startupName%!", setFlag = "startup_founder" },
			{ text = "💼 Stick to employment", effects = {}, resultText = "Entrepreneurship isn't for everyone." },
		},
	},
	
	{
		id = "tech_billionaire",
		minAge = 30, maxAge = 60,
		weight = 3, oneTime = true, milestone = true,
		emoji = "💰", title = "Tech Billionaire",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.startup_founder and f.elite_hacker and not f.tech_billionaire
		end,
		text = "Your company went public. You're now worth over a billion dollars.",
		choices = {
			{ text = "💰 Enjoy the wealth", effects = { Happiness = 30, Money = 10000000 }, resultText = "You're a tech billionaire.", setFlag = "tech_billionaire" },
		},
	},

	-- ═══════════════════════════════════════════════════════════════
	-- RANDOM LIFE EVENTS (Universal)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "lottery_win",
		minAge = 18, maxAge = 90,
		weight = 2, cooldown = 10,
		emoji = "🎰", title = "Lottery Winner!",
		category = "money",
		text = "You bought a lottery ticket and... YOU WON!",
		choices = {
			{ text = "💰 Claim the prize!", effects = { Happiness = 25, Money = 50000 }, resultText = "You're suddenly much richer!" },
		},
	},
	
	{
		id = "illness",
		minAge = 5, maxAge = 90,
		weight = 8, cooldown = 3,
		emoji = "🤒", title = "Feeling Sick",
		category = "health",
		text = "You've come down with something.",
		choices = {
			{ text = "🏥 See a doctor", effects = { Health = 5, Money = -500 }, resultText = "The doctor fixed you up." },
			{ text = "🛏️ Rest at home", effects = { Health = -5, Happiness = -3 }, resultText = "You recovered slowly." },
		},
	},
	
	{
		id = "find_money",
		minAge = 5, maxAge = 90,
		weight = 5, cooldown = 5,
		emoji = "💵", title = "Found Money!",
		category = "money",
		getDynamicData = function() return { amount = math.random(20, 200) } end,
		text = "You found $%amount% on the ground!",
		choices = {
			{ text = "💰 Keep it", effects = { Happiness = 5, Money = 100 }, resultText = "Finders keepers!" },
			{ text = "🚔 Turn it in", effects = { Happiness = 3, Smarts = 2 }, resultText = "You did the right thing." },
		},
	},
	
	{
		id = "romantic_encounter",
		minAge = 16, maxAge = 70,
		weight = 10, cooldown = 2,
		emoji = "💕", title = "Romantic Interest",
		category = "romance",
		getDynamicData = function() return { personName = randomName() } end,
		text = "You met someone interesting: %personName%. There's definitely a spark.",
		choices = {
			{ text = "💕 Ask them out", effects = { Happiness = 10 }, resultText = "They said yes! You're going on a date." },
			{ text = "😳 Too shy", effects = { Happiness = -3 }, resultText = "You couldn't work up the courage." },
		},
	},
	
	{
		id = "friendship_test",
		minAge = 8, maxAge = 80,
		weight = 8, cooldown = 3,
		emoji = "🤝", title = "Friend in Need",
		category = "social",
		getDynamicData = function() return { friendName = randomName() } end,
		text = "Your friend %friendName% needs help with something important.",
		choices = {
			{ text = "🤝 Help them out", effects = { Happiness = 8, Money = -100 }, resultText = "You helped them through a tough time." },
			{ text = "🙅 Too busy", effects = { Happiness = -5 }, resultText = "They were disappointed in you." },
		},
	},
	
	{
		id = "exercise_routine",
		minAge = 12, maxAge = 80,
		weight = 10, cooldown = 2,
		emoji = "💪", title = "Exercise Time",
		category = "health",
		text = "You've been thinking about getting more exercise.",
		choices = {
			{ text = "🏃 Start jogging", effects = { Health = 8, Happiness = 3 }, resultText = "You feel more energetic!" },
			{ text = "🏋️ Hit the gym", effects = { Health = 10, Looks = 3 }, resultText = "You're getting stronger!" },
			{ text = "🛋️ Maybe later", effects = { Health = -2 }, resultText = "Couch potato life continues." },
		},
	},
	
	{
		id = "social_media_viral",
		minAge = 13, maxAge = 50,
		weight = 5, cooldown = 5,
		emoji = "📱", title = "Gone Viral!",
		category = "social",
		text = "Something you posted went viral! Millions of views!",
		choices = {
			{ text = "🎉 Embrace the fame", effects = { Happiness = 15, Looks = 3 }, resultText = "You're internet famous!" },
			{ text = "😰 Delete everything", effects = { Happiness = -5, Smarts = 3 }, resultText = "You deleted it. Privacy preserved." },
		},
	},
	
	{
		id = "pet_adoption",
		minAge = 10, maxAge = 80,
		weight = 8, oneTime = true,
		emoji = "🐕", title = "Pet Adoption",
		category = "family",
		text = "You could adopt a pet!",
		choices = {
			{ text = "🐕 Adopt a dog", effects = { Happiness = 15 }, resultText = "You adopted a loyal companion!", setFlag = "pet_owner" },
			{ text = "🐈 Adopt a cat", effects = { Happiness = 12, Smarts = 2 }, resultText = "You adopted a mysterious feline!", setFlag = "pet_owner" },
			{ text = "🙅 Not ready", effects = {}, resultText = "Maybe another time." },
		},
	},
	
	{
		id = "inheritance",
		minAge = 25, maxAge = 80,
		weight = 3, oneTime = true,
		emoji = "💎", title = "Inheritance",
		category = "money",
		getDynamicData = function() return { relativeName = randomName() } end,
		text = "Your relative %relativeName% passed away and left you an inheritance.",
		choices = {
			{ text = "💰 Accept it", effects = { Money = 50000, Happiness = -5 }, resultText = "You inherited a substantial amount, but miss them." },
		},
	},
	
	{
		id = "midlife_crisis",
		minAge = 38, maxAge = 50,
		weight = 8, oneTime = true,
		emoji = "😰", title = "Midlife Crisis",
		category = "health",
		text = "You're questioning everything about your life choices.",
		choices = {
			{ text = "🏎️ Buy a sports car", effects = { Money = -30000, Happiness = 10 }, resultText = "The red convertible makes you feel young!" },
			{ text = "🧘 Find inner peace", effects = { Smarts = 5, Happiness = 8 }, resultText = "You embraced meditation and self-reflection." },
			{ text = "🤷 Power through", effects = { Happiness = 3 }, resultText = "It passed. Life goes on." },
		},
	},
	
	{
		id = "career_burnout",
		minAge = 25, maxAge = 60,
		weight = 8, cooldown = 5,
		emoji = "😓", title = "Burnout",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.teacher or f.hacker_career or f.congressman or f.f1_driver
		end,
		text = "You're exhausted. The passion is fading.",
		choices = {
			{ text = "🏖️ Take a break", effects = { Happiness = 10, Money = -5000 }, resultText = "You took time off. It helped a lot." },
			{ text = "💪 Push through", effects = { Happiness = -10, Health = -5 }, resultText = "You kept going but felt the toll." },
		},
	},
	
	{
		id = "retirement_age",
		minAge = 60, maxAge = 70,
		weight = 15, oneTime = true,
		emoji = "🏖️", title = "Retirement Decision",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.teacher or f.hacker_career or f.superintendent or f.elite_hacker
		end,
		text = "You've reached retirement age. Time to hang it up?",
		choices = {
			{ text = "🏖️ Retire peacefully", effects = { Happiness = 15 }, resultText = "You retired. Time to enjoy life!", setFlag = "retired" },
			{ text = "💼 Keep working", effects = { Happiness = 5, Smarts = 3 }, resultText = "You're not done yet!" },
		},
	},
	
	{
		id = "death_approach",
		minAge = 75, maxAge = 110,
		weight = 5, cooldown = 5,
		emoji = "⏳", title = "Reflecting on Life",
		category = "health",
		text = "You've lived a long life. Time to reflect on everything.",
		choices = {
			{ text = "😊 No regrets", effects = { Happiness = 20 }, resultText = "You've lived a full, meaningful life." },
			{ text = "😢 Some regrets", effects = { Happiness = -5, Smarts = 5 }, resultText = "You learned from your mistakes." },
		},
	},

	-- ═══════════════════════════════════════════════════════════════
	-- EXTENDED LIFE EVENTS (More Variety)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "bullying_victim",
		minAge = 8, maxAge = 18,
		weight = 8, oneTime = true,
		emoji = "😢", title = "Bullied at School",
		category = "school",
		getDynamicData = function() return { bullyName = randomName() } end,
		text = "%bullyName% has been bullying you at school. It's getting worse.",
		choices = {
			{ text = "🗣️ Tell a teacher", effects = { Happiness = 5, Smarts = 3 }, resultText = "The teacher intervened. The bullying stopped." },
			{ text = "👊 Stand up to them", effects = { Happiness = 8, Health = -5 }, resultText = "You confronted the bully. They backed off.", setFlag = "stood_up" },
			{ text = "😔 Suffer in silence", effects = { Happiness = -15 }, resultText = "The bullying continued for months." },
		},
	},
	
	{
		id = "best_friend_made",
		minAge = 6, maxAge = 25,
		weight = 10, oneTime = true,
		emoji = "🤝", title = "New Best Friend",
		category = "social",
		getDynamicData = function() return { friendName = randomName() } end,
		text = "You and %friendName% have become inseparable!",
		choices = {
			{ text = "🤗 Best friends forever!", effects = { Happiness = 12 }, resultText = "You found a lifelong friend.", setFlag = "has_best_friend" },
		},
	},
	
	{
		id = "parents_divorce",
		minAge = 5, maxAge = 18,
		weight = 6, oneTime = true,
		emoji = "💔", title = "Parents' Divorce",
		category = "family",
		text = "Your parents are getting divorced. Your world is shaking.",
		choices = {
			{ text = "😭 Cry it out", effects = { Happiness = -15, Smarts = 3 }, resultText = "It hurt, but time helped you heal." },
			{ text = "🤬 Act out", effects = { Happiness = -10, Health = -5 }, resultText = "You rebelled against the unfairness of it all.", setFlag = "rebel" },
			{ text = "💪 Stay strong", effects = { Happiness = -8, Smarts = 5 }, resultText = "You matured faster than most kids your age." },
		},
	},
	
	{
		id = "sibling_rivalry",
		minAge = 5, maxAge = 25,
		weight = 8, cooldown = 3,
		emoji = "😤", title = "Sibling Rivalry",
		category = "family",
		getDynamicData = function() return { siblingName = randomName() } end,
		text = "You and your sibling %siblingName% are constantly fighting.",
		choices = {
			{ text = "🤝 Make peace", effects = { Happiness = 5, Smarts = 3 }, resultText = "You worked out your differences." },
			{ text = "😤 Keep feuding", effects = { Happiness = -5 }, resultText = "The rivalry continues." },
			{ text = "🗣️ Get parents involved", effects = { Happiness = 2 }, resultText = "Parents made you both apologize." },
		},
	},
	
	{
		id = "school_talent_show",
		minAge = 8, maxAge = 18,
		weight = 8, oneTime = true,
		emoji = "🎭", title = "Talent Show",
		category = "school",
		text = "The school talent show is coming up. Will you participate?",
		choices = {
			{ text = "🎤 Perform!", effects = { Happiness = 10, Looks = 3 }, resultText = "You performed and the crowd loved it!", setFlag = "performer" },
			{ text = "🙅 Too nervous", effects = { Happiness = -3 }, resultText = "You watched from the audience with regret." },
		},
	},
	
	{
		id = "broken_bone",
		minAge = 5, maxAge = 70,
		weight = 5, cooldown = 10,
		emoji = "🦴", title = "Broken Bone",
		category = "health",
		getDynamicData = function()
			local bones = {"arm", "leg", "wrist", "ankle", "rib"}
			return { bone = bones[math.random(#bones)] }
		end,
		text = "Ouch! You broke your %bone% in an accident.",
		choices = {
			{ text = "🏥 Get it treated", effects = { Health = 5, Money = -500 }, resultText = "The doctor fixed you up. It'll heal in weeks." },
			{ text = "💪 Tough it out", effects = { Health = -10 }, resultText = "Bad idea. It didn't heal right." },
		},
	},
	
	{
		id = "family_vacation",
		minAge = 5, maxAge = 70,
		weight = 8, cooldown = 3,
		emoji = "✈️", title = "Family Vacation",
		category = "family",
		getDynamicData = function()
			local destinations = {"Hawaii", "Paris", "Tokyo", "Disney World", "the Grand Canyon", "Mexico", "Italy", "Australia"}
			return { destination = destinations[math.random(#destinations)] }
		end,
		text = "Your family is planning a vacation to %destination%!",
		choices = {
			{ text = "🎉 I'm so excited!", effects = { Happiness = 15, Money = -2000 }, resultText = "Best vacation ever!" },
			{ text = "🙄 Boring, but okay", effects = { Happiness = 5, Money = -2000 }, resultText = "It was actually more fun than expected." },
		},
	},
	
	{
		id = "first_crush",
		minAge = 10, maxAge = 16,
		weight = 10, oneTime = true,
		emoji = "😍", title = "First Crush",
		category = "romance",
		getDynamicData = function() return { crushName = randomName() } end,
		text = "You have a massive crush on %crushName%. Your heart races when you see them.",
		choices = {
			{ text = "💌 Confess your feelings", effects = { Happiness = 10 }, resultText = "They liked you back!", setFlag = "first_love" },
			{ text = "😳 Too shy to say anything", effects = { Happiness = -5 }, resultText = "You watched from afar as they dated someone else." },
			{ text = "🤷 Just a phase", effects = { Happiness = 2 }, resultText = "You moved on eventually." },
		},
	},
	
	{
		id = "prom_night",
		minAge = 16, maxAge = 18,
		weight = 15, oneTime = true, milestone = true,
		emoji = "👗", title = "Prom Night",
		category = "school",
		text = "Prom is here! The biggest night of high school.",
		choices = {
			{ text = "💃 Dance the night away", effects = { Happiness = 15, Looks = 2 }, resultText = "Prom was magical! You'll never forget this night." },
			{ text = "👑 Try to win Prom King/Queen", effects = { Happiness = 20, Looks = 5 }, resultText = "You won! This is your moment." },
			{ text = "🙅 Skip prom", effects = { Happiness = -5 }, resultText = "You stayed home. Maybe it was overrated anyway." },
		},
	},
	
	{
		id = "college_application",
		minAge = 17, maxAge = 18,
		weight = 12, oneTime = true,
		emoji = "📝", title = "College Applications",
		category = "school",
		requires = function(state) return state.Flags and state.Flags.honor_student end,
		getDynamicData = function()
			local colleges = {"Harvard", "Yale", "Stanford", "MIT", "Princeton"}
			return { dreamSchool = colleges[math.random(#colleges)] }
		end,
		text = "You're applying to colleges. Your dream is %dreamSchool%!",
		choices = {
			{ text = "📝 Apply to my dream school", effects = { Smarts = 5, Happiness = 10 }, resultText = "You got accepted! Dreams do come true.", setFlag = "elite_college" },
			{ text = "🎯 Be realistic", effects = { Smarts = 3 }, resultText = "You got into a good state school." },
		},
	},
	
	{
		id = "college_party",
		minAge = 18, maxAge = 25,
		weight = 10, cooldown = 2,
		emoji = "🎉", title = "College Party",
		category = "social",
		requires = function(state) return state.Flags and state.Flags.college_student end,
		text = "There's a huge party on campus tonight!",
		choices = {
			{ text = "🎉 Party hard!", effects = { Happiness = 10, Health = -3, Smarts = -2 }, resultText = "What a night! You barely remember it." },
			{ text = "📚 Stay in and study", effects = { Smarts = 5 }, resultText = "Your grades thanked you." },
			{ text = "😎 Show up briefly", effects = { Happiness = 5 }, resultText = "You made an appearance and left early." },
		},
	},
	
	{
		id = "internship_opportunity",
		minAge = 19, maxAge = 24,
		weight = 10, oneTime = true,
		emoji = "💼", title = "Internship Opportunity",
		category = "work",
		requires = function(state) return state.Flags and state.Flags.college_student end,
		getDynamicData = function() return { companyName = "TechCorp Industries" } end,
		text = "%companyName% is offering internships. This could launch your career!",
		choices = {
			{ text = "💼 Apply immediately", effects = { Smarts = 5, Money = 1000 }, resultText = "You got the internship! Great experience.", setFlag = "had_internship" },
			{ text = "😴 Too much work", effects = { Happiness = 2 }, resultText = "You passed. Summer freedom was nice." },
		},
	},
	
	{
		id = "first_job",
		minAge = 16, maxAge = 25,
		weight = 12, oneTime = true,
		emoji = "💵", title = "First Job",
		category = "work",
		requires = function(state) return not (state.Flags and state.Flags.first_job_done) end,
		getDynamicData = function()
			local jobs = {"fast food restaurant", "retail store", "coffee shop", "movie theater", "grocery store"}
			return { jobType = jobs[math.random(#jobs)] }
		end,
		text = "You got your first job at a %jobType%!",
		choices = {
			{ text = "💪 Work hard", effects = { Money = 500, Smarts = 2 }, resultText = "You learned the value of hard work.", setFlag = "first_job_done" },
			{ text = "😒 Do the minimum", effects = { Money = 300 }, resultText = "You got paid, that's what matters.", setFlag = "first_job_done" },
		},
	},
	
	{
		id = "apartment_hunting",
		minAge = 18, maxAge = 35,
		weight = 10, oneTime = true,
		emoji = "🏠", title = "First Apartment",
		category = "money",
		text = "Time to get your own place!",
		choices = {
			{ text = "🏠 Find a nice place", effects = { Happiness = 10, Money = -5000 }, resultText = "You're finally independent!", setFlag = "has_apartment" },
			{ text = "👥 Get roommates", effects = { Happiness = 5, Money = -2000 }, resultText = "Living with roommates is an adventure.", setFlag = "has_apartment" },
			{ text = "🏡 Stay with parents", effects = { Money = 500 }, resultText = "Free rent! Smart choice... maybe." },
		},
	},
	
	{
		id = "proposal",
		minAge = 22, maxAge = 60,
		weight = 8, oneTime = true,
		emoji = "💍", title = "The Proposal",
		category = "romance",
		requires = function(state) return state.Flags and state.Flags.in_love end,
		getDynamicData = function() return { partnerName = randomName() } end,
		text = "You're thinking about proposing to %partnerName%.",
		choices = {
			{ text = "💍 Ask them to marry you", effects = { Happiness = 25, Money = -3000 }, resultText = "They said YES!", setFlag = "engaged", clearFlag = "in_love" },
			{ text = "⏳ Not ready yet", effects = { Happiness = -5 }, resultText = "You decided to wait a bit longer." },
		},
	},
	
	{
		id = "wedding_day",
		minAge = 22, maxAge = 70,
		weight = 100, oneTime = true, milestone = true,
		emoji = "👰", title = "Wedding Day!",
		category = "romance",
		requires = function(state) return state.Flags and state.Flags.engaged end,
		text = "Today's the big day! You're getting married!",
		choices = {
			{ text = "💒 Have the perfect wedding", effects = { Happiness = 30, Money = -20000 }, resultText = "Best day of your life!", setFlag = "married", clearFlag = "engaged" },
			{ text = "🏃 Elope", effects = { Happiness = 20, Money = -500 }, resultText = "You eloped! Simple but special.", setFlag = "married", clearFlag = "engaged" },
		},
	},
	
	{
		id = "baby_born",
		minAge = 20, maxAge = 45,
		weight = 8, oneTime = true, milestone = true,
		emoji = "👶", title = "New Baby!",
		category = "family",
		requires = function(state) return state.Flags and state.Flags.married end,
		getDynamicData = function()
			local names = {"a boy", "a girl", "twins"}
			return { babyType = names[math.random(#names)] }
		end,
		text = "You're having %babyType%! Parenthood begins.",
		choices = {
			{ text = "👶 Embrace parenthood", effects = { Happiness = 20, Money = -5000, Health = -5 }, resultText = "Your heart grew three sizes that day.", setFlag = "has_kids" },
		},
	},
	
	{
		id = "midlife_affair_temptation",
		minAge = 35, maxAge = 55,
		weight = 5, oneTime = true,
		emoji = "😈", title = "Temptation",
		category = "romance",
		requires = function(state) return state.Flags and state.Flags.married end,
		getDynamicData = function() return { temptName = randomName() } end,
		text = "%temptName% is flirting with you. You feel a spark you haven't felt in years.",
		choices = {
			{ text = "❌ Stay faithful", effects = { Happiness = 5, Smarts = 5 }, resultText = "You resisted temptation. Your marriage is stronger." },
			{ text = "😈 Give in", effects = { Happiness = 10, Smarts = -5 }, resultText = "You cheated. The guilt is already setting in.", setFlag = "cheater" },
		},
	},
	
	{
		id = "business_idea",
		minAge = 25, maxAge = 55,
		weight = 8, oneTime = true,
		emoji = "💡", title = "Business Idea",
		category = "work",
		text = "You have a brilliant business idea! Should you pursue it?",
		choices = {
			{ text = "🚀 Start the business", effects = { Happiness = 10, Money = -10000 }, resultText = "You became an entrepreneur!", setFlag = "entrepreneur" },
			{ text = "📋 Write it down for later", effects = { Smarts = 3 }, resultText = "Maybe someday..." },
			{ text = "🤷 Ideas are just ideas", effects = {}, resultText = "You moved on." },
		},
	},
	
	{
		id = "business_success",
		minAge = 26, maxAge = 70,
		weight = 8, oneTime = true,
		emoji = "📈", title = "Business Booming!",
		category = "work",
		requires = function(state) return state.Flags and state.Flags.entrepreneur end,
		text = "Your business is taking off! You're making serious money.",
		choices = {
			{ text = "💰 Expand aggressively", effects = { Money = 100000, Happiness = 15 }, resultText = "Your empire grows!", setFlag = "business_owner" },
			{ text = "📊 Grow carefully", effects = { Money = 50000, Happiness = 10, Smarts = 5 }, resultText = "Sustainable growth. Smart.", setFlag = "business_owner" },
		},
	},
	
	{
		id = "business_failure",
		minAge = 26, maxAge = 70,
		weight = 6, oneTime = true,
		emoji = "📉", title = "Business Troubles",
		category = "work",
		requires = function(state) return state.Flags and state.Flags.entrepreneur end,
		text = "Your business is failing. Competitors and costs are crushing you.",
		choices = {
			{ text = "💪 Fight to survive", effects = { Money = -20000, Happiness = -10 }, resultText = "You barely survived. Lessons learned." },
			{ text = "🏳️ Declare bankruptcy", effects = { Money = -50000, Happiness = -20 }, resultText = "You lost everything. Time to start over.", setFlag = "bankrupt", clearFlag = "entrepreneur" },
		},
	},
	
	{
		id = "investment_opportunity",
		minAge = 25, maxAge = 80,
		weight = 8, cooldown = 5,
		emoji = "📊", title = "Investment Opportunity",
		category = "money",
		requires = function(state) return (state.Money or 0) > 10000 end,
		getDynamicData = function()
			local types = {"cryptocurrency", "stocks", "real estate", "startup"}
			return { investType = types[math.random(#types)] }
		end,
		text = "A friend has a hot tip on %investType%. Could be big!",
		choices = {
			{ text = "💰 Invest big", effects = { Money = 50000, Happiness = 10 }, resultText = "It paid off! You made a fortune!" },
			{ text = "💵 Invest small", effects = { Money = 5000 }, resultText = "Modest returns, but profit is profit." },
			{ text = "🙅 Too risky", effects = { Smarts = 3 }, resultText = "You passed. Who knows if it was the right call." },
		},
	},
	
	{
		id = "stock_crash",
		minAge = 25, maxAge = 80,
		weight = 5, cooldown = 10,
		emoji = "📉", title = "Market Crash!",
		category = "money",
		requires = function(state) return (state.Money or 0) > 50000 end,
		text = "The market crashed! Your investments are plummeting!",
		choices = {
			{ text = "💎 Hold your position", effects = { Smarts = 5 }, resultText = "You held through the panic. Time will tell." },
			{ text = "🏃 Sell everything", effects = { Money = -30000, Happiness = -10 }, resultText = "You sold at the bottom. Ouch." },
		},
	},
	
	{
		id = "charity_donation",
		minAge = 20, maxAge = 90,
		weight = 8, cooldown = 3,
		emoji = "❤️", title = "Charity Request",
		category = "social",
		getDynamicData = function()
			local causes = {"children's hospital", "homeless shelter", "environmental group", "animal rescue"}
			return { charity = causes[math.random(#causes)] }
		end,
		text = "A %charity% is asking for donations. Will you help?",
		choices = {
			{ text = "💝 Donate generously", effects = { Money = -1000, Happiness = 10 }, resultText = "Your generosity made a difference." },
			{ text = "💵 Small donation", effects = { Money = -100, Happiness = 5 }, resultText = "Every bit helps." },
			{ text = "🙅 Not this time", effects = {}, resultText = "You passed on this one." },
		},
	},
	
	{
		id = "gym_membership",
		minAge = 18, maxAge = 70,
		weight = 10, oneTime = true,
		emoji = "🏋️", title = "Gym Membership",
		category = "health",
		text = "A new gym opened nearby. Time to get fit?",
		choices = {
			{ text = "💪 Join and commit", effects = { Health = 10, Looks = 5, Money = -500 }, resultText = "You're getting in shape!", setFlag = "gym_member" },
			{ text = "🛋️ Nah, I'm good", effects = {}, resultText = "The couch wins again." },
		},
	},
	
	{
		id = "marathon_training",
		minAge = 20, maxAge = 60,
		weight = 6, oneTime = true,
		emoji = "🏃", title = "Marathon Challenge",
		category = "health",
		requires = function(state) return state.Flags and state.Flags.gym_member end,
		text = "A friend challenged you to run a marathon!",
		choices = {
			{ text = "🏃 Accept the challenge", effects = { Health = 15, Happiness = 10 }, resultText = "You trained hard and finished the marathon!", setFlag = "marathon_runner", minigame = "qte" },
			{ text = "🙅 No way", effects = {}, resultText = "26 miles? That's crazy." },
		},
	},
	
	{
		id = "addiction_problem",
		minAge = 16, maxAge = 60,
		weight = 4, oneTime = true,
		emoji = "😵", title = "Addiction Struggle",
		category = "health",
		text = "You've developed a dependency. It's affecting your life.",
		choices = {
			{ text = "🆘 Seek help", effects = { Happiness = -10, Health = 5, Money = -2000 }, resultText = "You entered recovery. It's hard but necessary.", setFlag = "recovering" },
			{ text = "🙅 I can handle it", effects = { Happiness = -15, Health = -15 }, resultText = "The problem got worse.", setFlag = "addict" },
		},
	},
	
	{
		id = "recovery_success",
		minAge = 17, maxAge = 70,
		weight = 100, oneTime = true, milestone = true,
		emoji = "🎉", title = "Recovery Milestone",
		category = "health",
		requires = function(state) return state.Flags and state.Flags.recovering end,
		text = "You've been clean for a year! This is a huge achievement.",
		choices = {
			{ text = "🎉 Celebrate this victory", effects = { Happiness = 20, Health = 10 }, resultText = "You're sober. You're strong. You made it.", setFlag = "sober", clearFlag = "recovering" },
		},
	},
	
	{
		id = "near_death_experience",
		minAge = 18, maxAge = 90,
		weight = 3, oneTime = true,
		emoji = "💀", title = "Near Death Experience",
		category = "health",
		getDynamicData = function()
			local causes = {"car accident", "medical emergency", "dangerous situation", "freak accident"}
			return { cause = causes[math.random(#causes)] }
		end,
		text = "A %cause% nearly killed you. You saw your life flash before your eyes.",
		choices = {
			{ text = "🙏 Grateful to be alive", effects = { Happiness = 15, Smarts = 10 }, resultText = "You appreciate life so much more now.", setFlag = "survivor" },
			{ text = "😨 Traumatized", effects = { Happiness = -15, Smarts = 5 }, resultText = "You can't stop thinking about how close it was." },
		},
	},
	
	{
		id = "mentor_appears",
		minAge = 16, maxAge = 40,
		weight = 8, oneTime = true,
		emoji = "👤", title = "A Mentor Appears",
		category = "work",
		getDynamicData = function() return { mentorName = randomName() } end,
		text = "%mentorName% sees potential in you and offers to mentor you.",
		choices = {
			{ text = "🙏 Accept gratefully", effects = { Smarts = 10, Happiness = 8 }, resultText = "Your mentor's guidance accelerated your growth.", setFlag = "has_mentor" },
			{ text = "🤷 Don't need help", effects = {}, resultText = "You preferred to figure things out alone." },
		},
	},
	
	{
		id = "become_mentor",
		minAge = 35, maxAge = 70,
		weight = 6, oneTime = true,
		emoji = "👨‍🏫", title = "Become a Mentor",
		category = "work",
		requires = function(state) return state.Flags and state.Flags.has_mentor end,
		getDynamicData = function() return { menteeName = randomName() } end,
		text = "Young %menteeName% looks up to you. Want to mentor them?",
		choices = {
			{ text = "👨‍🏫 Pay it forward", effects = { Happiness = 12, Smarts = 5 }, resultText = "You became a mentor. The cycle continues." },
			{ text = "🙅 Too busy", effects = {}, resultText = "You didn't have the time." },
		},
	},
	
	{
		id = "travel_opportunity",
		minAge = 18, maxAge = 70,
		weight = 8, cooldown = 3,
		emoji = "🌍", title = "Travel Opportunity",
		category = "social",
		getDynamicData = function()
			local places = {"Japan", "Italy", "Australia", "Brazil", "Egypt", "Greece", "Iceland", "South Africa"}
			return { destination = places[math.random(#places)] }
		end,
		text = "You have a chance to travel to %destination%!",
		choices = {
			{ text = "✈️ Go on the adventure", effects = { Happiness = 15, Smarts = 5, Money = -5000 }, resultText = "An unforgettable trip that broadened your horizons." },
			{ text = "🏠 Stay home", effects = {}, resultText = "Maybe next time." },
		},
	},
	
	{
		id = "learn_language",
		minAge = 12, maxAge = 60,
		weight = 6, cooldown = 5,
		emoji = "🗣️", title = "Learn a New Language",
		category = "school",
		getDynamicData = function()
			local languages = {"Spanish", "French", "Japanese", "Mandarin", "German", "Italian", "Portuguese", "Korean"}
			return { language = languages[math.random(#languages)] }
		end,
		text = "You're inspired to learn %language%!",
		choices = {
			{ text = "📚 Study hard", effects = { Smarts = 8, Happiness = 5 }, resultText = "You became conversational in %language%!" },
			{ text = "😅 Too difficult", effects = { Smarts = 2 }, resultText = "You learned a few phrases at least." },
		},
	},
	
	{
		id = "musical_instrument",
		minAge = 8, maxAge = 50,
		weight = 8, oneTime = true,
		emoji = "🎸", title = "Learn an Instrument",
		category = "social",
		getDynamicData = function()
			local instruments = {"guitar", "piano", "drums", "violin", "saxophone", "bass"}
			return { instrument = instruments[math.random(#instruments)] }
		end,
		text = "You're thinking about learning %instrument%.",
		choices = {
			{ text = "🎵 Start lessons", effects = { Smarts = 5, Happiness = 8, Money = -500 }, resultText = "You picked up the %instrument%! Practice makes perfect.", setFlag = "musician" },
			{ text = "🤷 Not for me", effects = {}, resultText = "Maybe someday." },
		},
	},
	
	{
		id = "write_book",
		minAge = 20, maxAge = 80,
		weight = 5, oneTime = true,
		emoji = "📖", title = "Write a Book",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.studious or f.honor_student or (state.Smarts or 0) > 70
		end,
		text = "You've always wanted to write a book. Maybe it's time.",
		choices = {
			{ text = "✍️ Start writing", effects = { Smarts = 8, Happiness = 10 }, resultText = "After months of work, you finished your manuscript!", setFlag = "wrote_book" },
			{ text = "📅 Later", effects = {}, resultText = "The book stayed in your head." },
		},
	},
	
	{
		id = "book_published",
		minAge = 21, maxAge = 85,
		weight = 100, oneTime = true,
		emoji = "📚", title = "Book Published!",
		category = "work",
		requires = function(state) return state.Flags and state.Flags.wrote_book end,
		text = "A publisher wants to publish your book!",
		choices = {
			{ text = "📚 Sign the deal", effects = { Money = 10000, Happiness = 20 }, resultText = "You're a published author!", setFlag = "author" },
		},
	},
	
	{
		id = "volunteer_abroad",
		minAge = 18, maxAge = 50,
		weight = 5, oneTime = true,
		emoji = "🌍", title = "Volunteer Abroad",
		category = "social",
		getDynamicData = function()
			local countries = {"Kenya", "Nepal", "Peru", "Cambodia", "Guatemala"}
			return { country = countries[math.random(#countries)] }
		end,
		text = "An organization is looking for volunteers to help in %country%.",
		choices = {
			{ text = "🌍 Go help", effects = { Happiness = 15, Smarts = 8, Money = -2000 }, resultText = "You made a real difference in people's lives.", setFlag = "volunteer" },
			{ text = "🙅 Can't right now", effects = {}, resultText = "Life got in the way." },
		},
	},
	
	{
		id = "adopt_pet",
		minAge = 18, maxAge = 70,
		weight = 8, cooldown = 10,
		emoji = "🐕", title = "Adopt a Pet",
		category = "family",
		requires = function(state) return not (state.Flags and state.Flags.pet_owner) end,
		getDynamicData = function()
			local pets = {"dog", "cat", "rabbit", "hamster", "parrot"}
			return { petType = pets[math.random(#pets)] }
		end,
		text = "A cute %petType% at the shelter needs a home.",
		choices = {
			{ text = "🏠 Adopt them!", effects = { Happiness = 12, Money = -500 }, resultText = "You have a new furry friend!", setFlag = "pet_owner" },
			{ text = "🙅 Not ready", effects = {}, resultText = "Maybe someday." },
		},
	},
	
	{
		id = "pet_passes",
		minAge = 25, maxAge = 90,
		weight = 5, oneTime = true,
		emoji = "🌈", title = "Pet Passes Away",
		category = "family",
		requires = function(state) return state.Flags and state.Flags.pet_owner end,
		text = "Your beloved pet has passed away. They lived a good life.",
		choices = {
			{ text = "😭 Mourn them", effects = { Happiness = -15 }, resultText = "You'll miss them forever.", clearFlag = "pet_owner" },
			{ text = "💙 Celebrate their life", effects = { Happiness = -8, Smarts = 3 }, resultText = "You focused on the happy memories.", clearFlag = "pet_owner" },
		},
	},
	
	{
		id = "neighbor_conflict",
		minAge = 20, maxAge = 80,
		weight = 6, cooldown = 5,
		emoji = "😤", title = "Neighbor Problems",
		category = "social",
		getDynamicData = function() return { neighborName = randomName() } end,
		text = "Your neighbor %neighborName% is causing problems. Loud music, messy yard, complaints about you...",
		choices = {
			{ text = "🗣️ Talk it out", effects = { Smarts = 3, Happiness = 5 }, resultText = "You resolved things peacefully." },
			{ text = "😤 Escalate", effects = { Happiness = -5 }, resultText = "The feud continues." },
			{ text = "📞 Call authorities", effects = { Happiness = 2 }, resultText = "They got a warning. Awkward now." },
		},
	},
	
	{
		id = "jury_duty",
		minAge = 18, maxAge = 80,
		weight = 5, cooldown = 10,
		emoji = "⚖️", title = "Jury Duty",
		category = "social",
		text = "You've been summoned for jury duty.",
		choices = {
			{ text = "⚖️ Serve responsibly", effects = { Smarts = 5, Happiness = -3 }, resultText = "You fulfilled your civic duty." },
			{ text = "🙅 Try to get out of it", effects = {}, resultText = "You were excused." },
		},
	},
	
	{
		id = "class_reunion",
		minAge = 28, maxAge = 60,
		weight = 6, cooldown = 10,
		emoji = "👥", title = "Class Reunion",
		category = "social",
		getDynamicData = function() return { years = math.random(10, 30) } end,
		text = "Your %years%-year class reunion is coming up!",
		choices = {
			{ text = "🎉 Attend", effects = { Happiness = 10 }, resultText = "It was great seeing old friends and comparing lives." },
			{ text = "🙅 Skip it", effects = { Happiness = -3 }, resultText = "You weren't curious how everyone turned out." },
		},
	},
	
	{
		id = "existential_crisis",
		minAge = 25, maxAge = 60,
		weight = 5, cooldown = 10,
		emoji = "🤔", title = "Existential Crisis",
		category = "health",
		text = "You're questioning the meaning of life. What's it all for?",
		choices = {
			{ text = "🧘 Find inner peace", effects = { Smarts = 8, Happiness = 5 }, resultText = "You found your own meaning." },
			{ text = "🎉 Just live in the moment", effects = { Happiness = 8 }, resultText = "Why worry? Life is for living!" },
			{ text = "😔 Spiral deeper", effects = { Happiness = -10, Smarts = 5 }, resultText = "You're still searching for answers." },
		},
	},
	
	{
		id = "famous_encounter",
		minAge = 10, maxAge = 80,
		weight = 3, cooldown = 10,
		emoji = "⭐", title = "Celebrity Encounter",
		category = "social",
		getDynamicData = function()
			local celebs = {"movie star", "famous musician", "sports legend", "TV personality", "famous author"}
			return { celebType = celebs[math.random(#celebs)] }
		end,
		text = "You ran into a %celebType% in public!",
		choices = {
			{ text = "📸 Ask for a photo", effects = { Happiness = 15 }, resultText = "They said yes! What a moment!" },
			{ text = "👋 Just say hi", effects = { Happiness = 10 }, resultText = "They were surprisingly normal." },
			{ text = "🚶 Respect their privacy", effects = { Smarts = 3 }, resultText = "They appreciated not being mobbed." },
		},
	},
	
	{
		id = "unexpected_windfall",
		minAge = 18, maxAge = 90,
		weight = 2, cooldown = 15,
		emoji = "💎", title = "Unexpected Windfall",
		category = "money",
		getDynamicData = function()
			local sources = {"forgotten investment", "tax refund error in your favor", "old savings bond", "cryptocurrency you forgot about"}
			return { source = sources[math.random(#sources)] }
		end,
		text = "You discovered a %source% worth a significant amount!",
		choices = {
			{ text = "💰 Celebrate!", effects = { Money = 25000, Happiness = 15 }, resultText = "Free money! Life is good." },
		},
	},
	
	{
		id = "lawsuit_filed",
		minAge = 25, maxAge = 80,
		weight = 3, cooldown = 10,
		emoji = "⚖️", title = "Lawsuit Filed",
		category = "work",
		getDynamicData = function() return { plaintiffName = randomName() } end,
		text = "%plaintiffName% is suing you! They claim you wronged them.",
		choices = {
			{ text = "⚖️ Fight it in court", effects = { Money = -10000, Happiness = -10 }, resultText = "You won, but the legal fees were brutal." },
			{ text = "🤝 Settle out of court", effects = { Money = -20000, Happiness = -5 }, resultText = "You settled to avoid the hassle." },
		},
	},
	
	{
		id = "award_nomination",
		minAge = 25, maxAge = 80,
		weight = 4, cooldown = 5,
		emoji = "🏆", title = "Award Nomination",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.teacher_award or f.author or f.performer or f.f1_winner or f.art_celebrity
		end,
		getDynamicData = function()
			local awards = {"Excellence Award", "Achievement Award", "Outstanding Contribution Award", "Lifetime Achievement Award"}
			return { awardName = awards[math.random(#awards)] }
		end,
		text = "You've been nominated for the %awardName%!",
		choices = {
			{ text = "🏆 Attend the ceremony", effects = { Happiness = 15, Looks = 2 }, resultText = "You won! What an honor!" },
		},
	},

	-- ═══════════════════════════════════════════════════════════════
	-- MORE CAREER DEPTH: PRESIDENT PATH EXTRAS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "cabinet_appointment",
		minAge = 40, maxAge = 80,
		weight = 10, cooldown = 2,
		emoji = "👔", title = "Cabinet Appointment",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.president and f.inaugurated
		end,
		getDynamicData = function()
			local positions = {"Secretary of State", "Secretary of Defense", "Attorney General", "Treasury Secretary"}
			return { position = positions[math.random(#positions)], nomineeName = randomName() }
		end,
		text = "You need to appoint someone as %position%. %nomineeName% is a candidate.",
		choices = {
			{ text = "✅ Nominate them", effects = { Smarts = 3, Happiness = 5 }, resultText = "The Senate confirmed your appointment." },
			{ text = "🔍 Keep looking", effects = { Smarts = 2 }, resultText = "You continued the search for the right person." },
		},
	},
	
	{
		id = "foreign_summit",
		minAge = 40, maxAge = 80,
		weight = 8, cooldown = 2,
		emoji = "🌍", title = "International Summit",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.president and f.inaugurated
		end,
		getDynamicData = function()
			local countries = {"China", "Russia", "Germany", "France", "Japan", "United Kingdom", "Brazil", "India"}
			return { country = countries[math.random(#countries)] }
		end,
		text = "You're attending a summit with the leader of %country%. High stakes diplomacy.",
		choices = {
			{ text = "🤝 Negotiate firmly but fairly", effects = { Smarts = 5, Happiness = 5 }, resultText = "The summit was a success. Relations improved." },
			{ text = "💪 Show strength", effects = { Smarts = 3, Happiness = 3 }, resultText = "You established dominance. Tensions remain." },
			{ text = "🕊️ Seek peace", effects = { Smarts = 5, Happiness = 8 }, resultText = "A historic peace agreement was reached!" },
		},
	},
	
	{
		id = "presidential_speech",
		minAge = 40, maxAge = 80,
		weight = 10, cooldown = 1,
		emoji = "📺", title = "Address the Nation",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.president and f.inaugurated
		end,
		getDynamicData = function()
			local topics = {"the economy", "national security", "healthcare", "unity"}
			return { topic = topics[math.random(#topics)] }
		end,
		text = "It's time to address the nation about %topic%.",
		choices = {
			{ text = "🎤 Deliver a powerful speech", effects = { Happiness = 10, Smarts = 5 }, resultText = "Your speech was inspiring. Approval ratings soared." },
			{ text = "📄 Read the teleprompter", effects = { Happiness = 3 }, resultText = "The speech was adequate. Nothing memorable." },
		},
	},
	
	{
		id = "impeachment_threat",
		minAge = 40, maxAge = 80,
		weight = 5, oneTime = true,
		emoji = "⚖️", title = "Impeachment Talk",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.president and f.inaugurated and f.scandal_survivor
		end,
		text = "Congress is talking about impeachment proceedings. This is serious.",
		choices = {
			{ text = "⚔️ Fight back hard", effects = { Happiness = -10, Smarts = 5 }, resultText = "You survived the impeachment attempt." },
			{ text = "🏳️ Resign with dignity", effects = { Happiness = -20 }, resultText = "You resigned from the presidency.", clearFlags = {"president", "inaugurated"} },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- MORE CAREER DEPTH: CRIMINAL PATH EXTRAS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "witness_intimidation",
		minAge = 20, maxAge = 60,
		weight = 8, cooldown = 3,
		emoji = "😠", title = "Witness Problem",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.gang_member and f.initiated
		end,
		getDynamicData = function() return { witnessName = randomName() } end,
		text = "A witness, %witnessName%, is about to testify against the gang. What do you do?",
		choices = {
			{ text = "😠 Intimidate them", effects = { Happiness = 5, Smarts = -3 }, resultText = "They withdrew their testimony. Problem solved... for now." },
			{ text = "💰 Bribe them", effects = { Money = -5000, Happiness = 5 }, resultText = "Money talks. They 'forgot' what they saw." },
			{ text = "🤷 Let it play out", effects = { Happiness = -5 }, resultText = "The testimony hurt the gang but you stayed clean." },
		},
	},
	
	{
		id = "prison_experience",
		minAge = 18, maxAge = 70,
		weight = 15, cooldown = 5,
		emoji = "⛓️", title = "Prison Life",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.did_time
		end,
		text = "Life behind bars continues. Today you face a choice.",
		choices = {
			{ text = "💪 Join a prison gang", effects = { Health = 5, Smarts = -3 }, resultText = "You found protection but made enemies." },
			{ text = "📚 Keep your head down", effects = { Smarts = 5 }, resultText = "You stayed out of trouble and focused on getting out." },
			{ text = "🏋️ Work out constantly", effects = { Health = 10, Looks = 3 }, resultText = "You came out in the best shape of your life." },
		},
	},
	
	{
		id = "money_laundering",
		minAge = 25, maxAge = 60,
		weight = 8, oneTime = true,
		emoji = "💵", title = "Money Laundering",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.gang_captain or f.underboss or f.crime_boss
		end,
		getDynamicData = function() return { businessName = "Clean Wash Laundromat" } end,
		text = "You need to launder money through %businessName%. The operation is risky.",
		choices = {
			{ text = "💵 Set up the operation", effects = { Money = 50000, Smarts = 5 }, resultText = "The money is now clean. The feds suspect nothing.", setFlag = "money_launderer" },
			{ text = "🚫 Too risky", effects = { Smarts = 3 }, resultText = "You passed. Live to fight another day." },
		},
	},
	
	{
		id = "criminal_empire_expansion",
		minAge = 30, maxAge = 70,
		weight = 6, cooldown = 3,
		emoji = "🌆", title = "Empire Expansion",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.crime_boss and f.empire_built
		end,
		getDynamicData = function()
			local cities = {"Los Angeles", "Miami", "Chicago", "Houston", "Philadelphia"}
			return { cityName = cities[math.random(#cities)] }
		end,
		text = "There's an opportunity to expand operations to %cityName%.",
		choices = {
			{ text = "🌆 Take over", effects = { Money = 100000, Happiness = 10 }, resultText = "You now control %cityName%. Your empire grows." },
			{ text = "🤝 Partner with locals", effects = { Money = 50000, Smarts = 5 }, resultText = "A smart partnership. Less risk, steady profits." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- MORE CAREER DEPTH: TEACHER PATH EXTRAS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "parent_conference",
		minAge = 23, maxAge = 65,
		weight = 10, cooldown = 2,
		emoji = "👨‍👩‍👧", title = "Parent Conference",
		category = "work",
		requires = function(state) return state.Flags and state.Flags.teacher end,
		getDynamicData = function() return { parentName = randomName(), studentName = randomName() } end,
		text = "%parentName% wants to discuss their child %studentName%'s performance.",
		choices = {
			{ text = "🤝 Be diplomatic", effects = { Smarts = 3, Happiness = 5 }, resultText = "The meeting went well. The parent appreciated your care." },
			{ text = "📊 Be direct with facts", effects = { Smarts = 5 }, resultText = "You delivered honest feedback. Some parents can't handle the truth." },
		},
	},
	
	{
		id = "student_crisis",
		minAge = 23, maxAge = 65,
		weight = 8, cooldown = 3,
		emoji = "🆘", title = "Student in Crisis",
		category = "work",
		requires = function(state) return state.Flags and state.Flags.teacher end,
		getDynamicData = function() return { studentName = randomName() } end,
		text = "You noticed that %studentName% might be going through something serious at home.",
		choices = {
			{ text = "🤝 Reach out privately", effects = { Happiness = 10, Smarts = 3 }, resultText = "You helped connect them with resources. You may have saved a life." },
			{ text = "📞 Report to counselor", effects = { Smarts = 3 }, resultText = "You followed protocol. The counselor took over." },
			{ text = "🤷 Not your business", effects = { Happiness = -5 }, resultText = "You let it slide. Hopefully it's nothing serious." },
		},
	},
	
	{
		id = "curriculum_innovation",
		minAge = 28, maxAge = 65,
		weight = 8, oneTime = true,
		emoji = "💡", title = "Curriculum Innovation",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.teacher and (f.teacher_award or f.department_head)
		end,
		text = "You have an idea to revolutionize how your subject is taught.",
		choices = {
			{ text = "📚 Propose the change", effects = { Smarts = 8, Happiness = 10 }, resultText = "Your innovative curriculum was adopted! Students are thriving." },
			{ text = "🤷 It's too much work", effects = {}, resultText = "You stuck with the traditional approach." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- MORE CAREER DEPTH: RACER PATH EXTRAS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "racing_sponsor",
		minAge = 18, maxAge = 45,
		weight = 10, oneTime = true,
		emoji = "💰", title = "Major Sponsor",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.junior_formula or f.f1_driver
		end,
		getDynamicData = function()
			local sponsors = {"EnergyDrink Corp", "TechGiant Inc", "LuxuryWatch Co", "FastCar Automotive"}
			return { sponsorName = sponsors[math.random(#sponsors)] }
		end,
		text = "%sponsorName% wants to sponsor you! Big money on the table.",
		choices = {
			{ text = "✅ Sign the deal", effects = { Money = 200000, Happiness = 10 }, resultText = "You're now sponsored! The money and exposure are incredible.", setFlag = "major_sponsor" },
			{ text = "🤔 Negotiate harder", effects = { Money = 300000, Smarts = 3 }, resultText = "You got an even better deal!" },
		},
	},
	
	{
		id = "racing_injury",
		minAge = 18, maxAge = 50,
		weight = 6, cooldown = 5,
		emoji = "🏥", title = "Racing Injury",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.f1_driver or f.junior_formula
		end,
		text = "A crash during practice left you injured. Recovery will take time.",
		choices = {
			{ text = "💪 Rush recovery", effects = { Health = -10, Happiness = 5 }, resultText = "You came back early but your body paid the price." },
			{ text = "🏥 Full recovery", effects = { Health = 5, Happiness = -5 }, resultText = "You took the time to heal properly. Smart choice." },
		},
	},
	
	{
		id = "team_drama",
		minAge = 20, maxAge = 50,
		weight = 8, cooldown = 3,
		emoji = "😤", title = "Team Drama",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.f1_driver
		end,
		getDynamicData = function() return { teammateName = randomName() } end,
		text = "Tensions are high with your teammate %teammateName%. The media is watching.",
		choices = {
			{ text = "🤝 Bury the hatchet", effects = { Happiness = 5, Smarts = 5 }, resultText = "You made peace. Team harmony restored." },
			{ text = "🔥 Fuel the rivalry", effects = { Happiness = 8 }, resultText = "The rivalry intensifies. Great for ratings, bad for team chemistry." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- MORE CAREER DEPTH: ARTIST PATH EXTRAS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "art_controversy",
		minAge = 25, maxAge = 70,
		weight = 8, cooldown = 5,
		emoji = "🎭", title = "Controversial Art",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.gallery_show or f.art_celebrity
		end,
		text = "Your latest piece is controversial. People are either loving or hating it.",
		choices = {
			{ text = "🎤 Explain your vision", effects = { Smarts = 5, Happiness = 5 }, resultText = "Your explanation added depth. Critics came around." },
			{ text = "🤐 Let the art speak", effects = { Happiness = 8, Looks = 3 }, resultText = "The mystery added to your mystique. Prices went up." },
			{ text = "🗑️ Pull the piece", effects = { Happiness = -10 }, resultText = "You caved to pressure. Some saw it as weakness." },
		},
	},
	
	{
		id = "art_forgery",
		minAge = 25, maxAge = 60,
		weight = 5, oneTime = true,
		emoji = "🔍", title = "Forgery Accusation",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.museum_piece or f.art_celebrity
		end,
		text = "Someone is claiming your most famous piece is actually their work!",
		choices = {
			{ text = "⚖️ Sue for defamation", effects = { Money = -10000, Happiness = -5, Smarts = 5 }, resultText = "You won the lawsuit! Your reputation is vindicated." },
			{ text = "🤐 Ignore them", effects = { Happiness = -10 }, resultText = "The rumors persist. Some doubt lingers." },
		},
	},
	
	{
		id = "art_teaching",
		minAge = 30, maxAge = 70,
		weight = 8, oneTime = true,
		emoji = "🎨", title = "Teach Your Craft",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.art_celebrity
		end,
		text = "A prestigious art school wants you to teach a masterclass.",
		choices = {
			{ text = "👨‍🏫 Accept", effects = { Money = 10000, Happiness = 10, Smarts = 5 }, resultText = "You inspired the next generation of artists." },
			{ text = "🙅 Decline", effects = { Happiness = 3 }, resultText = "You preferred to focus on your own work." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- MORE CAREER DEPTH: HACKER PATH EXTRAS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "dark_web_deal",
		minAge = 18, maxAge = 50,
		weight = 8, cooldown = 3,
		emoji = "🌑", title = "Dark Web Offer",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.black_hat and f.hacker_group
		end,
		getDynamicData = function()
			local targets = {"corporate database", "government server", "bank system", "hospital records"}
			return { target = targets[math.random(#targets)] }
		end,
		text = "Someone on the dark web wants you to hack a %target%. Big payout.",
		choices = {
			{ text = "💻 Take the job", effects = { Money = 30000, Smarts = 5 }, resultText = "You completed the job. Anonymous, untraceable." },
			{ text = "🚫 Too risky", effects = { Smarts = 3 }, resultText = "Some jobs aren't worth the heat." },
		},
	},
	
	{
		id = "cyber_bounty",
		minAge = 20, maxAge = 50,
		weight = 8, cooldown = 3,
		emoji = "💰", title = "Bug Bounty",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.white_hat or f.hacker_career
		end,
		getDynamicData = function() return { companyName = "MegaTech Corp" } end,
		text = "You found a critical vulnerability in %companyName%'s systems.",
		choices = {
			{ text = "📧 Report for bounty", effects = { Money = 20000, Happiness = 10 }, resultText = "They paid you generously and fixed the flaw." },
			{ text = "💻 Exploit it secretly", effects = { Money = 50000, Smarts = 3 }, resultText = "You exploited it before anyone noticed.", setFlag = "black_hat", clearFlag = "white_hat" },
		},
	},
	
	{
		id = "ransomware_attack",
		minAge = 20, maxAge = 50,
		weight = 6, oneTime = true,
		emoji = "🔒", title = "Ransomware Opportunity",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.black_hat and f.elite_hacker
		end,
		getDynamicData = function()
			local targets = {"hospital", "city government", "school district", "small business"}
			return { target = targets[math.random(#targets)] }
		end,
		text = "You could deploy ransomware against a %target%. Morally questionable but profitable.",
		choices = {
			{ text = "🔒 Do it", effects = { Money = 100000, Happiness = -10, Smarts = -5 }, resultText = "You got the ransom but live with knowing you hurt innocent people." },
			{ text = "🚫 I have limits", effects = { Happiness = 5, Smarts = 5 }, resultText = "Some lines shouldn't be crossed." },
		},
	},
	
	{
		id = "security_conference",
		minAge = 22, maxAge = 60,
		weight = 8, cooldown = 3,
		emoji = "🎤", title = "DEF CON Invitation",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.elite_hacker or f.hacker_career
		end,
		text = "You've been invited to speak at DEF CON, the world's premier hacking conference.",
		choices = {
			{ text = "🎤 Present your research", effects = { Smarts = 10, Happiness = 10 }, resultText = "Your talk was legendary. You're a celebrity in the hacker community." },
			{ text = "🙅 Stay anonymous", effects = { Smarts = 3 }, resultText = "You preferred to keep a low profile." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- EVEN MORE LIFE EVENTS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "dream_house",
		minAge = 30, maxAge = 70,
		weight = 6, oneTime = true,
		emoji = "🏡", title = "Dream House",
		category = "money",
		requires = function(state) return (state.Money or 0) > 100000 end,
		text = "Your dream house is on the market! But it's expensive.",
		choices = {
			{ text = "🏡 Buy it!", effects = { Money = -200000, Happiness = 20 }, resultText = "You own your dream home! Every day feels special.", setFlag = "homeowner" },
			{ text = "🤔 Too expensive", effects = {}, resultText = "You let someone else have your dream." },
		},
	},
	
	{
		id = "online_dating",
		minAge = 18, maxAge = 60,
		weight = 8, cooldown = 3,
		emoji = "💘", title = "Online Dating",
		category = "romance",
		requires = function(state) return not (state.Flags and (state.Flags.married or state.Flags.engaged)) end,
		text = "You created a profile on a dating app. Time to find love?",
		choices = {
			{ text = "💘 Start swiping", effects = { Happiness = 8 }, resultText = "You matched with someone amazing!", setFlag = "in_love" },
			{ text = "😰 Too awkward", effects = { Happiness = -3 }, resultText = "You deleted the app after a week." },
		},
	},
	
	{
		id = "bad_breakup",
		minAge = 16, maxAge = 60,
		weight = 6, oneTime = true,
		emoji = "💔", title = "Bad Breakup",
		category = "romance",
		requires = function(state)
			local f = state.Flags or {}
			return f.in_love and not f.married and not f.engaged
		end,
		text = "Your relationship ended badly. You're heartbroken.",
		choices = {
			{ text = "😭 Wallow in sadness", effects = { Happiness = -20 }, resultText = "It took months to recover from this.", clearFlag = "in_love" },
			{ text = "💪 Focus on yourself", effects = { Happiness = -10, Smarts = 5 }, resultText = "You channeled the pain into self-improvement.", clearFlag = "in_love" },
		},
	},
	
	{
		id = "surprise_party",
		minAge = 10, maxAge = 80,
		weight = 6, cooldown = 10,
		emoji = "🎉", title = "Surprise Party!",
		category = "social",
		text = "Your friends and family threw you a surprise party!",
		choices = {
			{ text = "🎉 Amazing!", effects = { Happiness = 15 }, resultText = "You felt so loved! What a great surprise." },
			{ text = "😱 Hate surprises", effects = { Happiness = 5 }, resultText = "You don't love surprises but appreciated the thought." },
		},
	},
	
	{
		id = "helping_stranger",
		minAge = 12, maxAge = 80,
		weight = 8, cooldown = 3,
		emoji = "🤝", title = "Stranger in Need",
		category = "social",
		getDynamicData = function() return { strangerName = randomName() } end,
		text = "A stranger, %strangerName%, clearly needs help. Their car broke down.",
		choices = {
			{ text = "🤝 Help them", effects = { Happiness = 10, Smarts = 2 }, resultText = "You helped and they were incredibly grateful." },
			{ text = "🚶 Walk by", effects = { Happiness = -3 }, resultText = "You ignored them. Maybe someone else will help." },
		},
	},
	
	{
		id = "scam_attempt",
		minAge = 18, maxAge = 90,
		weight = 6, cooldown = 5,
		emoji = "📞", title = "Scam Call",
		category = "money",
		text = "You received a suspicious call claiming you owe money to the IRS.",
		choices = {
			{ text = "🚫 Hang up", effects = { Smarts = 5 }, resultText = "Good instincts. It was definitely a scam." },
			{ text = "💸 Pay them", effects = { Money = -5000, Happiness = -10, Smarts = -5 }, resultText = "You got scammed. That money is gone forever." },
		},
	},
	
	{
		id = "food_poisoning",
		minAge = 5, maxAge = 90,
		weight = 6, cooldown = 5,
		emoji = "🤢", title = "Food Poisoning",
		category = "health",
		getDynamicData = function()
			local foods = {"sushi", "street food", "leftover pizza", "mystery meat", "gas station sushi"}
			return { food = foods[math.random(#foods)] }
		end,
		text = "That %food% didn't agree with you. You're really sick.",
		choices = {
			{ text = "🏥 See a doctor", effects = { Health = 5, Money = -200 }, resultText = "The doctor fixed you up." },
			{ text = "🛏️ Ride it out", effects = { Health = -5, Happiness = -5 }, resultText = "Two days of misery, but you survived." },
		},
	},
	
	{
		id = "dentist_visit",
		minAge = 6, maxAge = 90,
		weight = 8, cooldown = 3,
		emoji = "🦷", title = "Dentist Time",
		category = "health",
		text = "Time for your dental checkup!",
		choices = {
			{ text = "🦷 Go to the dentist", effects = { Health = 3, Money = -100 }, resultText = "No cavities! Good job with the brushing." },
			{ text = "🙅 Skip it", effects = { Health = -3 }, resultText = "Avoiding the dentist will catch up to you eventually." },
		},
	},
	
	{
		id = "flat_tire",
		minAge = 16, maxAge = 90,
		weight = 8, cooldown = 5,
		emoji = "🚗", title = "Flat Tire",
		category = "social",
		requires = function(state) return state.Flags and state.Flags.has_license end,
		text = "You got a flat tire on the side of the road.",
		choices = {
			{ text = "🔧 Change it yourself", effects = { Smarts = 3, Happiness = 5 }, resultText = "You changed the tire like a pro!" },
			{ text = "📞 Call for help", effects = { Money = -100 }, resultText = "Roadside assistance saved the day." },
		},
	},
	
	{
		id = "noisy_neighbors",
		minAge = 18, maxAge = 70,
		weight = 6, cooldown = 5,
		emoji = "🔊", title = "Noisy Neighbors",
		category = "social",
		requires = function(state) return state.Flags and state.Flags.has_apartment end,
		text = "Your neighbors are having another loud party at 2 AM.",
		choices = {
			{ text = "🚪 Ask them to quiet down", effects = { Happiness = 5 }, resultText = "They apologized and turned it down." },
			{ text = "📞 Call the police", effects = { Happiness = 3 }, resultText = "The cops came. Problem solved, but awkward now." },
			{ text = "😤 Suffer in silence", effects = { Happiness = -5, Health = -2 }, resultText = "You didn't sleep at all." },
		},
	},
	
	{
		id = "lost_wallet",
		minAge = 12, maxAge = 90,
		weight = 5, cooldown = 10,
		emoji = "👛", title = "Lost Wallet",
		category = "money",
		text = "You lost your wallet! All your cards and cash were inside.",
		choices = {
			{ text = "🔍 Search everywhere", effects = { Happiness = -5 }, resultText = "You found it! Everything was still there." },
			{ text = "😢 Give up", effects = { Money = -500, Happiness = -10 }, resultText = "It's gone. Cancel those cards." },
		},
	},
	
	{
		id = "social_media_drama",
		minAge = 13, maxAge = 50,
		weight = 8, cooldown = 3,
		emoji = "📱", title = "Social Media Drama",
		category = "social",
		text = "Someone is talking trash about you online!",
		choices = {
			{ text = "🔥 Clap back", effects = { Happiness = 5, Smarts = -2 }, resultText = "You won the argument. The internet loved it." },
			{ text = "🤐 Ignore it", effects = { Smarts = 5, Happiness = 3 }, resultText = "You rose above it. Mature choice." },
			{ text = "📵 Delete social media", effects = { Happiness = 10, Smarts = 3 }, resultText = "You're free! Mental health improved instantly." },
		},
	},
	
	{
		id = "work_promotion",
		minAge = 22, maxAge = 65,
		weight = 8, cooldown = 3,
		emoji = "📈", title = "Promotion Opportunity",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.first_job_done and not f.teacher and not f.f1_driver and not f.crime_boss
		end,
		text = "There's an opening for a promotion at work!",
		choices = {
			{ text = "📈 Go for it", effects = { Money = 10000, Happiness = 10 }, resultText = "You got the promotion! More money, more responsibility." },
			{ text = "🤷 Content where I am", effects = { Happiness = 2 }, resultText = "You stayed in your current role." },
		},
	},
	
	{
		id = "workplace_conflict",
		minAge = 18, maxAge = 65,
		weight = 8, cooldown = 3,
		emoji = "😤", title = "Workplace Conflict",
		category = "work",
		getDynamicData = function() return { coworkerName = randomName() } end,
		text = "You're having serious issues with coworker %coworkerName%.",
		choices = {
			{ text = "🤝 Work it out", effects = { Smarts = 5, Happiness = 5 }, resultText = "You resolved the conflict professionally." },
			{ text = "📋 Report to HR", effects = { Happiness = 3 }, resultText = "HR intervened. The situation improved." },
			{ text = "😤 Escalate", effects = { Happiness = -5 }, resultText = "Things got worse before they got better." },
		},
	},
	
	{
		id = "fired_from_job",
		minAge = 18, maxAge = 65,
		weight = 4, oneTime = true,
		emoji = "📦", title = "Fired!",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.first_job_done and not f.entrepreneur and not f.teacher
		end,
		getDynamicData = function()
			local reasons = {"budget cuts", "performance issues", "company restructuring", "personality conflicts"}
			return { reason = reasons[math.random(#reasons)] }
		end,
		text = "Due to %reason%, you've been let go from your job.",
		choices = {
			{ text = "😔 Accept it", effects = { Happiness = -15, Money = -3000 }, resultText = "It stings, but you'll bounce back." },
			{ text = "😤 Fight it", effects = { Happiness = -10, Money = 5000 }, resultText = "You negotiated a severance package." },
		},
	},
}

----------------------------------------------------------------------
-- EXPORTS
----------------------------------------------------------------------

EventLibrary.events = events
EventLibrary.Events = events  -- Also export as uppercase for compatibility
EventLibrary.randomName = randomName
EventLibrary.randomMaleName = randomMaleName
EventLibrary.randomFemaleName = randomFemaleName
EventLibrary.randomSchool = randomSchool
EventLibrary.randomUniversity = randomUniversity
EventLibrary.randomRacingTeam = randomRacingTeam
EventLibrary.randomHackerGroup = randomHackerGroup
EventLibrary.randomArtStyle = randomArtStyle
EventLibrary.hasNoCareer = hasNoCareer

return EventLibrary
