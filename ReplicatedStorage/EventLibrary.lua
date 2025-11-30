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
	
	-- ═══════════════════════════════════════════════════════════════
	-- INFANT YEARS (0-2) - Multiple varied events
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
		id = "first_smile",
		minAge = 0, maxAge = 1,
		weight = 60, oneTime = true,
		emoji = "😊", title = "First Smile!",
		category = "family",
		text = "You smiled for the first time! Everyone melted.",
		choices = {
			{ text = "😄 Smile more!", effects = { Happiness = 5, Looks = 2 }, resultText = "Your smile brightened everyone's day." },
			{ text = "🤗 Reach for a hug", effects = { Happiness = 6 }, resultText = "You're already so affectionate!" },
		},
	},
	
	{
		id = "first_crawl",
		minAge = 0, maxAge = 1,
		weight = 50, oneTime = true,
		emoji = "🐛", title = "First Crawl!",
		category = "family",
		text = "You started crawling! Nothing is safe anymore.",
		choices = {
			{ text = "🏃 Crawl everywhere!", effects = { Health = 3, Smarts = 2 }, resultText = "You became an unstoppable explorer." },
			{ text = "🧸 Crawl to your toys", effects = { Happiness = 4 }, resultText = "You love your teddy bear the most." },
		},
	},
	
	{
		id = "first_word",
		minAge = 1, maxAge = 2,
		weight = 80, oneTime = true,
		emoji = "🗣️", title = "First Word!",
		category = "family",
		getDynamicData = function()
			local words = {"Mama", "Dada", "No!", "Ball", "More", "Dog", "Cat", "Bye-bye"}
			return { word = words[math.random(#words)] }
		end,
		text = "Everyone is watching as you're about to speak your first word...",
		choices = {
			{ text = "👩 Say 'Mama'", effects = { Happiness = 5 }, resultText = "Your mother cried happy tears." },
			{ text = "👨 Say 'Dada'", effects = { Happiness = 5 }, resultText = "Your father was so proud." },
			{ text = "🙅 Say 'NO!'", effects = { Happiness = 3, Smarts = 3 }, resultText = "Your rebellious streak started early.", setFlag = "strong_willed" },
		},
	},
	
	{
		id = "first_steps",
		minAge = 1, maxAge = 2,
		weight = 70, oneTime = true,
		emoji = "🚶", title = "First Steps!",
		category = "family",
		text = "You took your first wobbly steps! The whole family cheered!",
		choices = {
			{ text = "🏃 Try to run!", effects = { Health = 4, Happiness = 3 }, resultText = "You fell down but got right back up. Determined!", setFlag = "determined" },
			{ text = "👐 Walk to parent", effects = { Happiness = 6 }, resultText = "You walked right into their arms." },
			{ text = "🤸 Dance around", effects = { Happiness = 5, Looks = 2 }, resultText = "You've got natural rhythm!" },
		},
	},
	
	{
		id = "first_birthday",
		minAge = 1, maxAge = 1,
		weight = 100, oneTime = true, milestone = true,
		emoji = "🎂", title = "First Birthday!",
		category = "family",
		text = "Happy birthday! You're 1 year old! Time for cake (and to smash it).",
		choices = {
			{ text = "🎂 Smash the cake!", effects = { Happiness = 8 }, resultText = "You made a glorious mess!" },
			{ text = "🤔 What is this?", effects = { Smarts = 3, Happiness = 3 }, resultText = "You examined the cake curiously before eating it." },
			{ text = "😭 Too many people!", effects = { Happiness = -2 }, resultText = "You got overwhelmed. It's okay, little one." },
		},
	},
	
	{
		id = "baby_tantrum",
		minAge = 1, maxAge = 3,
		weight = 40, cooldown = 2,
		emoji = "😠", title = "Tantrum Time!",
		category = "family",
		text = "You didn't get what you wanted. Time to let the world know!",
		choices = {
			{ text = "😭 SCREAM!", effects = { Health = 2, Happiness = -3 }, resultText = "You got attention... but not what you wanted." },
			{ text = "🥺 Puppy eyes", effects = { Looks = 2, Happiness = 5 }, resultText = "You learned that cuteness works. Noted." },
			{ text = "🤷 Give up", effects = { Smarts = 2 }, resultText = "You learned to pick your battles early." },
		},
	},
	
	{
		id = "baby_sibling",
		minAge = 1, maxAge = 5,
		weight = 25, oneTime = true,
		emoji = "👶", title = "New Sibling!",
		category = "family",
		getDynamicData = function()
			local genders = {"brother", "sister"}
			return { siblingType = genders[math.random(#genders)] }
		end,
		text = "Your parents brought home a new baby %siblingType%!",
		choices = {
			{ text = "🤗 Love them!", effects = { Happiness = 6 }, resultText = "You adore your new sibling!", setFlag = "has_sibling" },
			{ text = "😤 Jealous...", effects = { Happiness = -5 }, resultText = "You're not sure about sharing attention.", setFlag = "has_sibling" },
			{ text = "🤷 Meh", effects = { Smarts = 2 }, resultText = "You're indifferent. You've got your own thing going.", setFlag = "has_sibling" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- TODDLER YEARS (3-4) - Expanded variety
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "potty_training",
		minAge = 2, maxAge = 3,
		weight = 60, oneTime = true,
		emoji = "🚽", title = "Potty Training!",
		category = "family",
		text = "Your parents are trying to potty train you. This is a big deal!",
		choices = {
			{ text = "✅ Nail it!", effects = { Smarts = 4, Happiness = 5 }, resultText = "You're a potty training prodigy!" },
			{ text = "😅 Accidents happen", effects = { Happiness = -2 }, resultText = "It took a while, but you got there." },
			{ text = "🙅 Refuse to cooperate", effects = { Happiness = 3, Smarts = -2 }, resultText = "You showed them who's boss (for now).", setFlag = "stubborn" },
		},
	},
	
	{
		id = "imaginary_friend",
		minAge = 3, maxAge = 5,
		weight = 35, oneTime = true,
		emoji = "👻", title = "Imaginary Friend",
		category = "social",
		getDynamicData = function()
			local names = {"Mr. Whiskers", "Sparkle", "Captain Thunder", "Princess Luna", "Dino"}
			return { friendName = names[math.random(#names)] }
		end,
		text = "You've created an imaginary friend named %friendName%!",
		choices = {
			{ text = "🤝 Best friends forever!", effects = { Happiness = 6, Smarts = 3 }, resultText = "%friendName% goes everywhere with you.", setFlag = "creative_mind" },
			{ text = "🏰 Build a whole world", effects = { Smarts = 5, Happiness = 4 }, resultText = "Your imagination is incredible.", setFlag = "creative_mind" },
			{ text = "🤷 They're just pretend", effects = { Smarts = 4 }, resultText = "You know the difference between real and pretend." },
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
			{ text = "🎉 Excited!", effects = { Happiness = 5, Smarts = 3 }, resultText = "You made friends immediately.", setFlag = "social_butterfly" },
			{ text = "😰 Scared", effects = { Happiness = -2 }, resultText = "You clung to your parent but warmed up." },
			{ text = "🤝 Make a friend", effects = { Happiness = 6 }, resultText = "You found a best friend on day one!", setFlag = "has_best_friend" },
		},
	},
	
	{
		id = "playground_incident",
		minAge = 3, maxAge = 6,
		weight = 40, cooldown = 2,
		emoji = "🛝", title = "Playground Drama",
		category = "social",
		getDynamicData = function() return { kidName = randomName() } end,
		text = "Another kid named %kidName% pushed you on the playground!",
		choices = {
			{ text = "👊 Push back", effects = { Health = -2, Happiness = 2 }, resultText = "You stood your ground. They won't mess with you again.", setFlag = "fights_back" },
			{ text = "😭 Cry for help", effects = { Happiness = -3 }, resultText = "An adult intervened. You felt protected." },
			{ text = "🗣️ Talk it out", effects = { Smarts = 4, Happiness = 2 }, resultText = "You resolved it maturely. Impressive for your age!" },
		},
	},
	
	{
		id = "first_drawing",
		minAge = 3, maxAge = 5,
		weight = 45, oneTime = true,
		emoji = "🖍️", title = "Your First Drawing!",
		category = "school",
		text = "You drew something and your parents put it on the fridge!",
		choices = {
			{ text = "🎨 Keep drawing!", effects = { Smarts = 3, Happiness = 5 }, resultText = "Art becomes your passion.", setFlag = "art_interest" },
			{ text = "🏠 Draw your family", effects = { Happiness = 6 }, resultText = "Your parents were so touched." },
			{ text = "🤷 Meh, not interested", effects = { Happiness = 2 }, resultText = "Art isn't your thing." },
		},
	},
	
	{
		id = "first_pet_encounter",
		minAge = 2, maxAge = 6,
		weight = 35, oneTime = true,
		emoji = "🐕", title = "Meeting a Pet",
		category = "family",
		getDynamicData = function()
			local pets = {"dog", "cat", "hamster", "goldfish"}
			return { petType = pets[math.random(#pets)] }
		end,
		text = "Your family got a pet %petType%!",
		choices = {
			{ text = "🤗 Love it!", effects = { Happiness = 8 }, resultText = "You and your pet are inseparable!", setFlag = "animal_lover" },
			{ text = "😨 Scared of it", effects = { Happiness = -3 }, resultText = "Pets aren't for everyone." },
			{ text = "🔬 Study it", effects = { Smarts = 4, Happiness = 3 }, resultText = "You're fascinated by animals!", setFlag = "science_interest" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- CHILDHOOD YEARS (5-11) - More variety
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "elementary_start",
		minAge = 5, maxAge = 6,
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
	
	{
		id = "first_computer",
		minAge = 6, maxAge = 10,
		weight = 50, oneTime = true,
		emoji = "💻", title = "First Computer!",
		category = "family",
		text = "Your family got a computer! A whole new world opens up.",
		choices = {
			{ text = "🎮 Play games!", effects = { Happiness = 6 }, resultText = "Gaming becomes your hobby." },
			{ text = "💻 Learn how it works", effects = { Smarts = 6, Happiness = 3 }, resultText = "You're fascinated by technology!", setFlag = "computer_interest" },
			{ text = "🌐 Explore the internet", effects = { Smarts = 4, Happiness = 4 }, resultText = "You discovered so much online.", setFlag = "computer_interest" },
		},
	},
	
	{
		id = "first_book_love",
		minAge = 6, maxAge = 10,
		weight = 40, oneTime = true,
		emoji = "📖", title = "Book Worm!",
		category = "school",
		getDynamicData = function()
			local genres = {"fantasy", "mystery", "science fiction", "adventure", "comedy"}
			return { genre = genres[math.random(#genres)] }
		end,
		text = "You discovered a love for %genre% books!",
		choices = {
			{ text = "📚 Read everything!", effects = { Smarts = 8, Happiness = 5 }, resultText = "Books became your best friends.", setFlag = "bookworm" },
			{ text = "✍️ Try writing your own", effects = { Smarts = 6, Happiness = 4 }, resultText = "You started writing stories!", setFlag = "writer_interest" },
			{ text = "🤷 It's okay", effects = { Smarts = 3 }, resultText = "Reading is fine, but not your passion." },
		},
	},
	
	{
		id = "science_fair",
		minAge = 8, maxAge = 12,
		weight = 35, cooldown = 3,
		emoji = "🔬", title = "Science Fair",
		category = "school",
		getDynamicData = function()
			local projects = {"volcano", "solar system model", "plant growth experiment", "robot", "crystal growing"}
			return { project = projects[math.random(#projects)] }
		end,
		text = "The school science fair is coming up! You're making a %project%.",
		choices = {
			{ text = "🏆 Win it!", effects = { Smarts = 8, Happiness = 8 }, resultText = "First place! You're a science star!", setFlag = "science_interest" },
			{ text = "🤝 Help others", effects = { Smarts = 4, Happiness = 6 }, resultText = "You helped friends with their projects.", setFlag = "teaching_interest" },
			{ text = "😅 Just pass", effects = { Smarts = 3, Happiness = 2 }, resultText = "You did okay. Science isn't your thing." },
		},
	},
	
	{
		id = "talent_show",
		minAge = 7, maxAge = 12,
		weight = 30, cooldown = 3,
		emoji = "🎤", title = "Talent Show",
		category = "school",
		text = "There's a school talent show! Will you perform?",
		choices = {
			{ text = "🎤 Sing!", effects = { Happiness = 7, Looks = 3 }, resultText = "You wowed the crowd!", setFlag = "performer" },
			{ text = "🎸 Play music", effects = { Happiness = 6, Smarts = 3 }, resultText = "Your musical talent impressed everyone.", setFlag = "musician" },
			{ text = "🙅 Too nervous", effects = { Happiness = -3 }, resultText = "Stage fright got you. Maybe next time." },
		},
	},
	
	{
		id = "childhood_bully",
		minAge = 7, maxAge = 12,
		weight = 35, cooldown = 3,
		emoji = "😈", title = "Dealing with a Bully",
		category = "school",
		getDynamicData = function() return { bullyName = randomName() } end,
		text = "%bullyName% has been picking on you at school.",
		choices = {
			{ text = "🗣️ Tell an adult", effects = { Smarts = 4, Happiness = 3 }, resultText = "The teacher handled it. Good call." },
			{ text = "👊 Stand up to them", effects = { Health = -3, Happiness = 5 }, resultText = "They backed off after you confronted them.", setFlag = "brave" },
			{ text = "🤝 Try to befriend them", effects = { Smarts = 5, Happiness = 4 }, resultText = "Turns out they just needed a friend.", setFlag = "compassionate" },
			{ text = "😔 Suffer in silence", effects = { Happiness = -8 }, resultText = "It was a hard year." },
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
			{ text = "✅ Accept the job!", effects = { Happiness = 10, Money = 2000 }, resultText = "You're officially a teacher!", setFlag = "teacher",
			  setJob = { id = "teacher", title = "Teacher", company = "%school%", salary = 45000, storyFlag = "teacher" } },
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
			{ text = "👔 Become Principal", effects = { Happiness = 15, Money = 20000 }, resultText = "You're now the Principal!", setFlag = "principal",
			  setJob = { id = "principal", title = "School Principal", company = "Local School District", salary = 95000, storyFlag = "principal" } },
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
			{ text = "✅ Lead the district", effects = { Happiness = 20, Money = 50000 }, resultText = "You're now shaping education for thousands of students.", setFlag = "superintendent",
			  setJob = { id = "superintendent", title = "School Superintendent", company = "School District", salary = 175000, storyFlag = "superintendent" } },
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
			{ text = "🏎️ Sign the contract!", effects = { Happiness = 25, Money = 500000 }, resultText = "You're now an F1 driver!", setFlag = "f1_driver", clearFlag = "f1_test_driver",
			  setJob = { id = "f1_driver", title = "Formula 1 Driver", company = "%team%", salary = 2000000, storyFlag = "f1_driver" } },
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
			{ text = "💼 Take the job", effects = { Happiness = 10, Money = 5000 }, resultText = "You're now a professional white-hat hacker.", setFlag = "hacker_career",
			  setJob = { id = "hacker", title = "Security Researcher", company = "%company%", salary = 95000, storyFlag = "hacker_career" } },
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
		emoji = "🐾", title = "Pet Adoption",
		category = "family",
		text = "You could adopt a pet!",
		choices = {
			{ text = "🐕 Adopt a dog", effects = { Happiness = 15 }, resultText = "You adopted a loyal companion!", resultEmoji = "🐕", setFlag = "pet_owner" },
			{ text = "🐈 Adopt a cat", effects = { Happiness = 12, Smarts = 2 }, resultText = "You adopted a mysterious feline!", resultEmoji = "🐈", setFlag = "pet_owner" },
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
			{ text = "🏎️ Buy a sports car", effects = { Money = -30000, Happiness = 10 }, resultText = "The red convertible makes you feel young!", addAsset = { type = "vehicle", id = "midlife_sports", name = "Red Sports Car", value = 30000 } },
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
		category = "prison",
		requiresFlag = "in_prison",
		text = "Life behind bars continues. Today you face a choice.",
		choices = {
			{ text = "💪 Join a prison gang", effects = { Health = 5, Smarts = -3 }, resultText = "You found protection but made enemies." },
			{ text = "📚 Keep your head down", effects = { Smarts = 5 }, resultText = "You stayed out of trouble and focused on getting out." },
			{ text = "🏋️ Work out constantly", effects = { Health = 10, Looks = 3 }, resultText = "You came out in the best shape of your life." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- DEEP PRISON PATH EVENTS (While In Prison)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "prison_yard_fight",
		minAge = 16, maxAge = 70,
		weight = 12, cooldown = 2,
		emoji = "🥊", title = "Yard Confrontation",
		category = "prison",
		requiresFlag = "in_prison",
		getDynamicData = function() return { inmateName = randomName() } end,
		text = "%inmateName% is looking for trouble. They've been eyeing you all week.",
		choices = {
			{ text = "🥊 Fight back", effects = { Health = -10, Happiness = 5 }, resultText = "You held your own. Earned some respect.", setFlag = "prison_fighter" },
			{ text = "🏃 Walk away", effects = { Happiness = -5 }, resultText = "You walked away. Some call it smart, others call it weak." },
			{ text = "🗣️ De-escalate", effects = { Smarts = 5, Happiness = 2 }, resultText = "You talked your way out. Brains over brawn." },
		},
	},
	
	{
		id = "prison_contraband",
		minAge = 18, maxAge = 70,
		weight = 10, cooldown = 3,
		emoji = "📦", title = "Contraband Opportunity",
		category = "prison",
		requiresFlag = "in_prison",
		getDynamicData = function() return { itemType = ({"phone","cigarettes","drugs","alcohol"})[math.random(4)] } end,
		text = "A guard offers to smuggle %itemType% to you... for a price.",
		choices = {
			{ text = "💵 Pay up", effects = { Money = -500, Happiness = 10 }, resultText = "You got the goods. Life in prison just got easier.", setFlag = "has_contraband" },
			{ text = "🚫 Too risky", effects = { Happiness = -3 }, resultText = "You passed. Safer that way." },
			{ text = "🐀 Report him", effects = { Smarts = 3, Happiness = -5 }, resultText = "The guard got fired. Now everyone thinks you're a snitch.", setFlag = "prison_snitch" },
		},
	},
	
	{
		id = "prison_cellmate_story",
		minAge = 18, maxAge = 70,
		weight = 8, oneTime = true,
		emoji = "🛏️", title = "New Cellmate",
		category = "prison",
		requiresFlag = "in_prison",
		getDynamicData = function() return { cellmateName = randomName() } end,
		text = "Your new cellmate %cellmateName% is a former bank robber. They offer to teach you their trade.",
		choices = {
			{ text = "📚 Learn from them", effects = { Smarts = 10, Happiness = 5 }, resultText = "You learned a lot about the criminal underworld.", setFlag = "prison_mentor" },
			{ text = "🙅 Keep to yourself", effects = { Happiness = -2 }, resultText = "You minded your own business. Probably safer." },
		},
	},
	
	{
		id = "prison_escape_opportunity",
		minAge = 18, maxAge = 70,
		weight = 5, oneTime = true,
		emoji = "🔓", title = "Escape Route",
		category = "prison",
		requiresFlag = "in_prison",
		requiresFlag2 = "prison_mentor",
		blockIfFlag = "attempted_escape",
		text = "Your mentor found a weakness in the fence. Tonight might be your chance.",
		choices = {
			{ text = "🏃 Make a break for it", effects = { Happiness = 15, Health = -5 }, resultText = "You escaped! You're now a fugitive.", setFlags = {"escaped_prison", "fugitive", "ex_convict"}, clearFlag = "in_prison", minigame = "prison_escape" },
			{ text = "⏰ Not yet", effects = { Smarts = 3 }, resultText = "You decided to wait for a better opportunity.", setFlag = "attempted_escape" },
		},
	},
	
	{
		id = "prison_parole_hearing",
		minAge = 18, maxAge = 70,
		weight = 15, cooldown = 2,
		emoji = "⚖️", title = "Parole Hearing",
		category = "prison",
		requiresFlag = "in_prison",
		text = "Your parole hearing is today. This could be your chance.",
		choices = {
			{ text = "😊 Show remorse", effects = { Smarts = 3, Happiness = 10 }, resultText = "The board saw genuine change. Early release granted!", clearFlag = "in_prison", setFlags = {"ex_convict", "paroled"} },
			{ text = "😤 Defend yourself", effects = { Happiness = -5 }, resultText = "Your attitude didn't help. Parole denied." },
			{ text = "🤷 Be honest", effects = { Smarts = 5, Happiness = 3 }, resultText = "Your honesty was refreshing. They'll reconsider next time.", setFlag = "good_behavior" },
		},
	},
	
	{
		id = "prison_riot_survive",
		minAge = 18, maxAge = 70,
		weight = 4, oneTime = true,
		emoji = "🔥", title = "Prison Riot!",
		category = "prison",
		requiresFlag = "in_prison",
		text = "A riot breaks out! Inmates are fighting guards. Chaos everywhere.",
		choices = {
			{ text = "🔥 Join the chaos", effects = { Health = -15, Happiness = 10 }, resultText = "You fought alongside the inmates. You're now marked as a troublemaker.", setFlag = "prison_troublemaker" },
			{ text = "🏃 Find cover", effects = { Smarts = 5 }, resultText = "You hid until it was over. Smart move." },
			{ text = "🚪 Use it to escape", effects = { Health = -10, Happiness = 20 }, resultText = "In the chaos, you slipped away!", setFlags = {"escaped_prison", "fugitive", "ex_convict"}, clearFlag = "in_prison", minigame = "getaway" },
		},
	},
	
	{
		id = "prison_release",
		minAge = 18, maxAge = 70,
		weight = 20, oneTime = true,
		emoji = "🚪", title = "Release Day!",
		category = "prison",
		requiresFlag = "in_prison",
		requiresFlag2 = "sentence_served",
		text = "After years behind bars, you're finally free. What now?",
		choices = {
			{ text = "🔄 Go straight", effects = { Happiness = 10, Smarts = 5 }, resultText = "You decided to turn your life around.", setFlags = {"released_from_prison", "reformed", "ex_convict"}, clearFlag = "in_prison" },
			{ text = "😈 Back to crime", effects = { Happiness = 5 }, resultText = "Old habits die hard. You know what you're good at.", setFlags = {"released_from_prison", "career_criminal", "ex_convict"}, clearFlag = "in_prison" },
			{ text = "🏠 Lay low", effects = { Happiness = 3 }, resultText = "You kept a low profile. Time to figure things out.", setFlags = {"released_from_prison", "ex_convict"}, clearFlag = "in_prison" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- FUGITIVE PATH (After Escaping Prison)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "fugitive_hideout",
		minAge = 18, maxAge = 70,
		weight = 20, oneTime = true,
		emoji = "🏚️", title = "Finding Shelter",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.fugitive and not f.found_hideout
		end,
		getDynamicData = function() return { contactName = randomName() } end,
		text = "You need a place to hide. %contactName% might help... for a price.",
		choices = {
			{ text = "💵 Pay for safety", effects = { Money = -2000, Happiness = 5 }, resultText = "You found a safe house. For now.", setFlag = "found_hideout" },
			{ text = "🏕️ Live rough", effects = { Health = -10, Smarts = 3 }, resultText = "You've been living in abandoned buildings. It's hard but you're free.", setFlag = "found_hideout" },
			{ text = "🚗 Keep moving", effects = { Health = -5, Happiness = -5 }, resultText = "You never stay in one place too long.", setFlag = "found_hideout" },
		},
	},
	
	{
		id = "fugitive_close_call",
		minAge = 18, maxAge = 70,
		weight = 15, cooldown = 2,
		emoji = "🚔", title = "Close Call!",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.fugitive
		end,
		text = "A cop car just pulled up. They're running plates. Your heart is pounding.",
		choices = {
			{ text = "😎 Stay cool", effects = { Smarts = 5, Happiness = 3 }, resultText = "You acted natural. They drove away." },
			{ text = "🏃 Run for it", effects = { Health = -10, Happiness = -10 }, resultText = "You bolted. They chased. You barely got away.", minigame = "getaway" },
			{ text = "🙋 Turn yourself in", effects = { Happiness = -15 }, resultText = "The running is over. Back to prison.", clearFlag = "fugitive", setFlags = {"recaptured", "in_prison"} },
		},
	},
	
	{
		id = "fugitive_new_identity",
		minAge = 18, maxAge = 70,
		weight = 8, oneTime = true,
		emoji = "🪪", title = "New Identity",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.fugitive and f.found_hideout
		end,
		getDynamicData = function() return { newName = randomName(), forgerName = randomName() } end,
		text = "%forgerName% can create a new identity for you. Become %newName% forever?",
		choices = {
			{ text = "💵 Buy new papers", effects = { Money = -10000, Happiness = 15 }, resultText = "You're now %newName%. Your old life is gone forever.", setFlags = {"new_identity"}, clearFlag = "fugitive" },
			{ text = "🚫 Too expensive", effects = { Happiness = -5 }, resultText = "You can't afford it. You'll stay on the run." },
		},
	},
	
	{
		id = "fugitive_recaptured",
		minAge = 18, maxAge = 70,
		weight = 6, oneTime = true,
		emoji = "🚨", title = "Busted Again!",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.fugitive and not f.new_identity
		end,
		text = "A manhunt led authorities right to your door. There's no escape this time.",
		choices = {
			{ text = "🙋 Surrender", effects = { Health = -5, Happiness = -20 }, resultText = "Back to prison with extra time for escaping.", clearFlag = "fugitive", setFlags = {"recaptured", "in_prison"} },
			{ text = "🥊 Go down fighting", effects = { Health = -30, Happiness = 5 }, resultText = "You fought until you couldn't anymore. Solitary confinement.", clearFlag = "fugitive", setFlags = {"recaptured", "in_prison", "violent_offender"} },
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
	
	-- ═══════════════════════════════════════════════════════════════
	-- MORE EVERYDAY RANDOM EVENTS (Age Variety)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "random_kindness",
		minAge = 8, maxAge = 80,
		weight = 10, cooldown = 4,
		emoji = "😊", title = "Random Act of Kindness",
		category = "social",
		getDynamicData = function() return { strangerName = randomName() } end,
		text = "A stranger named %strangerName% helped you out of nowhere!",
		choices = {
			{ text = "😊 Pay it forward", effects = { Happiness = 10, Smarts = 2 }, resultText = "You helped someone else too. The world is good." },
			{ text = "🙏 Just say thanks", effects = { Happiness = 5 }, resultText = "You were grateful for the kindness." },
		},
	},
	
	{
		id = "found_money",
		minAge = 6, maxAge = 80,
		weight = 8, cooldown = 5,
		emoji = "💵", title = "Found Money!",
		category = "money",
		getDynamicData = function() return { amount = math.random(20, 200) } end,
		text = "You found $%amount% on the ground!",
		choices = {
			{ text = "💵 Keep it", effects = { Money = 100, Happiness = 8 }, resultText = "Finders keepers!" },
			{ text = "🤝 Try to find owner", effects = { Smarts = 3, Happiness = 5 }, resultText = "You tried but nobody claimed it. You kept it guilt-free." },
		},
	},
	
	{
		id = "traffic_ticket",
		minAge = 16, maxAge = 80,
		weight = 8, cooldown = 3,
		emoji = "🚔", title = "Traffic Stop",
		category = "money",
		requires = function(state) return state.Flags and state.Flags.has_license end,
		text = "You got pulled over for speeding!",
		choices = {
			{ text = "😇 Be polite", effects = { Money = -100, Happiness = -3 }, resultText = "The officer let you off with a warning." },
			{ text = "😤 Argue", effects = { Money = -300, Happiness = -10 }, resultText = "You made it worse. Full ticket." },
			{ text = "😢 Cry", effects = { Money = -150, Happiness = 5 }, resultText = "The officer felt bad. Reduced fine." },
		},
	},
	
	{
		id = "new_hobby",
		minAge = 10, maxAge = 70,
		weight = 10, cooldown = 5,
		emoji = "🎯", title = "New Hobby",
		category = "social",
		getDynamicData = function()
			local hobbies = {"gardening", "cooking", "photography", "hiking", "collecting stamps", "woodworking", "painting", "bird watching"}
			return { hobby = hobbies[math.random(#hobbies)] }
		end,
		text = "You discovered %hobby% and really enjoy it!",
		choices = {
			{ text = "🎯 Dive in deep", effects = { Happiness = 12, Smarts = 5 }, resultText = "Your new hobby brings you joy every day." },
			{ text = "🤷 Casual interest", effects = { Happiness = 5 }, resultText = "It's a nice occasional activity." },
		},
	},
	
	{
		id = "health_checkup",
		minAge = 20, maxAge = 80,
		weight = 8, cooldown = 4,
		emoji = "🏥", title = "Annual Checkup",
		category = "health",
		text = "Time for your annual health checkup!",
		choices = {
			{ text = "🏥 Go to doctor", effects = { Health = 10, Money = -200 }, resultText = "You're in good health! The doctor gave some helpful advice." },
			{ text = "🙅 Skip it", effects = { Happiness = 3 }, resultText = "You put off the appointment. Hopefully nothing's wrong." },
		},
	},
	
	{
		id = "food_poisoning",
		minAge = 10, maxAge = 80,
		weight = 5, cooldown = 5,
		emoji = "🤢", title = "Food Poisoning",
		category = "health",
		getDynamicData = function()
			local foods = {"gas station sushi", "street tacos", "leftover pizza", "questionable buffet", "sketchy food truck"}
			return { food = foods[math.random(#foods)] }
		end,
		text = "You got food poisoning from %food%!",
		choices = {
			{ text = "🏥 Go to hospital", effects = { Health = -5, Money = -500 }, resultText = "You recovered quickly with medical help." },
			{ text = "🏠 Tough it out", effects = { Health = -15, Happiness = -10 }, resultText = "That was a rough few days..." },
		},
	},
	
	{
		id = "viral_video",
		minAge = 13, maxAge = 50,
		weight = 4, oneTime = true,
		emoji = "📱", title = "Viral Video!",
		category = "social",
		text = "A video of you went viral! Millions of people have seen it.",
		choices = {
			{ text = "😎 Embrace the fame", effects = { Happiness = 15, Money = 5000 }, resultText = "You became an internet celebrity!", setFlag = "internet_famous" },
			{ text = "😰 Try to hide", effects = { Happiness = -5 }, resultText = "The attention faded eventually." },
		},
	},
	
	{
		id = "bad_haircut",
		minAge = 8, maxAge = 60,
		weight = 8, cooldown = 5,
		emoji = "✂️", title = "Bad Haircut",
		category = "looks",
		text = "Your barber really messed up your haircut!",
		choices = {
			{ text = "😭 Be upset", effects = { Happiness = -10, Looks = -5 }, resultText = "It'll grow back... eventually." },
			{ text = "😂 Laugh it off", effects = { Happiness = 3, Smarts = 2 }, resultText = "Hair grows back! You owned it." },
			{ text = "🎩 Wear a hat", effects = { Happiness = -3 }, resultText = "Hat season it is." },
		},
	},
	
	{
		id = "neighbor_dispute",
		minAge = 18, maxAge = 80,
		weight = 6, cooldown = 4,
		emoji = "🏠", title = "Neighbor Problems",
		category = "social",
		getDynamicData = function() return { neighborName = randomName() } end,
		text = "Your neighbor %neighborName% is playing loud music at 2 AM!",
		choices = {
			{ text = "🗣️ Talk to them", effects = { Smarts = 3, Happiness = 5 }, resultText = "They apologized and turned it down." },
			{ text = "🔊 Retaliate louder", effects = { Happiness = 5, Smarts = -3 }, resultText = "Petty but satisfying. The noise war continues." },
			{ text = "📞 Call police", effects = { Happiness = 3 }, resultText = "The cops told them to quiet down." },
		},
	},
	
	{
		id = "strange_dream",
		minAge = 6, maxAge = 80,
		weight = 8, cooldown = 5,
		emoji = "💭", title = "Strange Dream",
		category = "social",
		text = "You had an incredibly vivid and strange dream that felt meaningful.",
		choices = {
			{ text = "🔮 Look up meaning", effects = { Smarts = 3, Happiness = 3 }, resultText = "Dream interpretation is fascinating!" },
			{ text = "📓 Journal about it", effects = { Smarts = 5 }, resultText = "Writing it down helped you process it." },
			{ text = "🤷 Forget it", effects = {}, resultText = "Just a dream, nothing more." },
		},
	},
	
	{
		id = "find_pet",
		minAge = 8, maxAge = 70,
		weight = 5, oneTime = true,
		emoji = "🐾", title = "Stray Pet",
		category = "social",
		getDynamicData = function()
			local pets = {"dog", "cat", "kitten", "puppy"}
			local petType = pets[math.random(#pets)]
			local emojiMap = {
				dog = "🐕",
				puppy = "🐕‍🦺",
				cat = "🐈",
				kitten = "🐈‍⬛",
			}

			local scenarioRoll = math.random()
			local conditionLine
			local keepCost = math.random(150, 450)
			local shelterFee = math.random(25, 120)
			local feedCost = math.random(10, 40)
			local keepHealthLoss = 0
			local shelterHealthLoss = 0

			if scenarioRoll < 0.45 then
				conditionLine = "It happily trots behind you and looks healthy."
			elseif scenarioRoll < 0.8 then
				conditionLine = "It's skittish and keeps flinching away."
				if math.random() < 0.5 then
					keepHealthLoss = math.random(2, 4)
				end
				if math.random() < 0.6 then
					shelterHealthLoss = math.random(2, 5)
				end
			else
				conditionLine = "It's limping and whimpering — clearly injured."
				keepCost = keepCost + math.random(200, 350)
				keepHealthLoss = math.random(3, 6)
				shelterHealthLoss = math.random(4, 7)
			end

			local function buildShelterResult()
				if shelterHealthLoss > 0 then
					return string.format("Shelter staff took over, but not before it scratched you (-%d Health).", shelterHealthLoss)
				else
					return "Shelter staff thanked you and promised to find it a family."
				end
			end

			local function buildKeepResult()
				if keepHealthLoss > 0 then
					return string.format("It panicked at first and scratched you (-%d Health), but a vet visit ($%d) calmed it down.", keepHealthLoss, keepCost)
				else
					return string.format("It curled up on your couch immediately. Supplies and shots cost $%d.", keepCost)
				end
			end

			return {
				petType = petType,
				eventEmoji = emojiMap[petType] or "🐾",
				conditionLine = conditionLine,
				keepCost = keepCost,
				shelterFee = shelterFee,
				feedCost = feedCost,
				keepHealthLoss = keepHealthLoss,
				shelterHealthLoss = shelterHealthLoss,
				keepResult = buildKeepResult(),
				shelterResult = buildShelterResult(),
				feedResult = string.format("You bought food ($%d). It ate nervously then trotted off.", feedCost),
				ignoreResult = "It watched you leave before wandering down the street.",
			}
		end,
		text = "A stray %petType% followed you home. %conditionLine%",
		choices = {
			{
				text = "🏠 Keep it!",
				effects = { Happiness = 15 },
				dynamicEffects = function(_, data)
					return {
						Money = data.keepCost and -data.keepCost or 0,
						Health = data.keepHealthLoss and -data.keepHealthLoss or 0,
					}
				end,
				resultText = "%keepResult%",
				resultEmoji = "%eventEmoji%",
				setFlags = { "pet_owner", "pet_parent" },
			},
			{
				text = "🏥 Take to shelter",
				effects = { Happiness = 5, Smarts = 3 },
				dynamicEffects = function(_, data)
					return {
						Money = data.shelterFee and -data.shelterFee or 0,
						Health = data.shelterHealthLoss and -data.shelterHealthLoss or 0,
					}
				end,
				resultText = "%shelterResult%",
				resultEmoji = "%eventEmoji%",
			},
			{
				text = "🥪 Feed & post online",
				effects = { Happiness = 4 },
				dynamicEffects = function(_, data)
					return {
						Money = data.feedCost and -data.feedCost or 0,
					}
				end,
				resultText = "%feedResult%",
				resultEmoji = "%eventEmoji%",
			},
			{
				text = "🤷 Shoo it away",
				effects = { Happiness = -3 },
				resultText = "%ignoreResult%",
			},
		},
	},
	
	{
		id = "surprise_gift",
		minAge = 10, maxAge = 80,
		weight = 7, cooldown = 4,
		emoji = "🎁", title = "Surprise Gift",
		category = "social",
		getDynamicData = function() return { senderName = randomName() } end,
		text = "You received an unexpected gift from %senderName%!",
		choices = {
			{ text = "🎁 Open immediately", effects = { Happiness = 12 }, resultText = "It was exactly what you wanted!" },
			{ text = "🤔 What's the catch?", effects = { Smarts = 3, Happiness = 5 }, resultText = "No catch! Just a thoughtful person." },
		},
	},
	
	{
		id = "minor_accident",
		minAge = 16, maxAge = 80,
		weight = 5, cooldown = 4,
		emoji = "🚗", title = "Fender Bender",
		category = "money",
		requires = function(state) return state.Flags and state.Flags.has_license end,
		text = "You got into a minor car accident in a parking lot.",
		choices = {
			{ text = "📋 Exchange info", effects = { Money = -500, Happiness = -5 }, resultText = "Insurance handled it. Annoying but sorted." },
			{ text = "🏃 Drive away", effects = { Happiness = -10, Smarts = -5 }, resultText = "You hope nobody saw. Guilt lingers." },
		},
	},
	
	{
		id = "volunteer_opportunity",
		minAge = 14, maxAge = 80,
		weight = 8, cooldown = 3,
		emoji = "🤝", title = "Volunteer Opportunity",
		category = "social",
		getDynamicData = function()
			local causes = {"animal shelter", "food bank", "elderly home", "beach cleanup", "homeless shelter"}
			return { cause = causes[math.random(#causes)] }
		end,
		text = "There's an opportunity to volunteer at the local %cause%.",
		choices = {
			{ text = "🤝 Sign up!", effects = { Happiness = 12, Smarts = 5 }, resultText = "You made a real difference today!" },
			{ text = "⏰ Too busy", effects = { Happiness = -2 }, resultText = "Maybe next time." },
		},
	},
	
	{
		id = "rainy_day",
		minAge = 5, maxAge = 80,
		weight = 10, cooldown = 3,
		emoji = "🌧️", title = "Rainy Day",
		category = "social",
		text = "It's a gloomy rainy day with nothing planned.",
		choices = {
			{ text = "📺 Movie marathon", effects = { Happiness = 8 }, resultText = "A cozy day watching your favorite movies!" },
			{ text = "📚 Read a book", effects = { Smarts = 8, Happiness = 5 }, resultText = "You finished that book you've been meaning to read." },
			{ text = "🌧️ Go out anyway", effects = { Health = 3, Happiness = 5 }, resultText = "Dancing in the rain is underrated!" },
		},
	},
	
	{
		id = "insomnia",
		minAge = 15, maxAge = 80,
		weight = 6, cooldown = 4,
		emoji = "😴", title = "Can't Sleep",
		category = "health",
		text = "You've been having trouble sleeping lately.",
		choices = {
			{ text = "☕ More coffee", effects = { Health = -5, Smarts = 3 }, resultText = "You powered through but felt terrible." },
			{ text = "🧘 Try meditation", effects = { Health = 5, Happiness = 5 }, resultText = "Meditation helped calm your mind." },
			{ text = "💊 Sleep aids", effects = { Health = 3 }, resultText = "It helped but probably shouldn't become a habit." },
		},
	},

	-- ═══════════════════════════════════════════════════════════════════════════
	-- ███████████████████████████████████████████████████████████████████████████
	-- MASSIVE EXPANSION PART 1: EARLY LIFE EVENTS (0-11)
	-- ███████████████████████████████████████████████████████████████████████████
	-- ═══════════════════════════════════════════════════════════════════════════
	
	-- ─────────────────────────────────────────────────────────────────
	-- MORE INFANT EVENTS (Ages 0-2)
	-- ─────────────────────────────────────────────────────────────────
	
	{
		id = "baby_food_reaction",
		minAge = 0, maxAge = 1,
		weight = 40, oneTime = true,
		emoji = "🥄", title = "First Solid Food",
		category = "family",
		getDynamicData = function()
			local foods = {"mashed peas", "sweet potato puree", "apple sauce", "banana mush", "carrot paste"}
			return { food = foods[math.random(#foods)] }
		end,
		text = "Your parents are trying to feed you %food% for the first time!",
		choices = {
			{ text = "😋 Love it!", effects = { Health = 3, Happiness = 5 }, resultText = "You couldn't get enough! A future foodie." },
			{ text = "🤮 Spit it out", effects = { Happiness = 2 }, resultText = "Your parents' clothes were a mess, but you were happy." },
			{ text = "🤔 Cautiously curious", effects = { Smarts = 3, Health = 2 }, resultText = "You examined each bite before eating. Thoughtful baby!" },
		},
	},
	
	{
		id = "baby_music_discovery",
		minAge = 0, maxAge = 2,
		weight = 35, oneTime = true,
		emoji = "🎵", title = "Musical Moment",
		category = "family",
		text = "Music is playing and you're reacting to it for the first time!",
		choices = {
			{ text = "💃 Dance around!", effects = { Happiness = 6, Health = 2 }, resultText = "You've got natural rhythm!", setFlag = "musical_baby" },
			{ text = "😊 Smile and clap", effects = { Happiness = 5 }, resultText = "Music makes you so happy!" },
			{ text = "😴 Fall asleep", effects = { Health = 3 }, resultText = "Lullabies work wonders on you." },
		},
	},
	
	{
		id = "baby_bath_time",
		minAge = 0, maxAge = 2,
		weight = 40, cooldown = 2,
		emoji = "🛁", title = "Bath Time Adventure",
		category = "family",
		text = "It's bath time! The water is warm and bubbly.",
		choices = {
			{ text = "💦 Splash everywhere!", effects = { Happiness = 6, Health = 2 }, resultText = "The bathroom is soaked but you had fun!" },
			{ text = "🦆 Play with rubber ducky", effects = { Happiness = 5, Smarts = 2 }, resultText = "You and ducky are best friends now." },
			{ text = "😭 Hate bath time", effects = { Happiness = -3 }, resultText = "You screamed through the whole thing." },
		},
	},
	
	{
		id = "baby_peek_a_boo",
		minAge = 0, maxAge = 1,
		weight = 45, oneTime = true,
		emoji = "🙈", title = "Peek-a-boo!",
		category = "family",
		text = "Your parent is playing peek-a-boo with you!",
		choices = {
			{ text = "😄 Laugh hysterically", effects = { Happiness = 7 }, resultText = "Best game ever! You laughed so hard you hiccupped." },
			{ text = "🙈 Cover your own eyes", effects = { Happiness = 5, Smarts = 4 }, resultText = "You learned the game! So clever!" },
		},
	},
	
	{
		id = "baby_mirror_discovery",
		minAge = 0, maxAge = 2,
		weight = 35, oneTime = true,
		emoji = "🪞", title = "Mirror Discovery",
		category = "family",
		text = "You discovered your reflection in a mirror!",
		choices = {
			{ text = "👋 Wave at yourself", effects = { Smarts = 4, Happiness = 4 }, resultText = "You recognized yourself! A cognitive milestone!" },
			{ text = "😘 Kiss the mirror", effects = { Happiness = 5, Looks = 2 }, resultText = "You love what you see!" },
			{ text = "😠 Get upset at 'other baby'", effects = { Happiness = 2 }, resultText = "Who is that baby and why are they copying you?!" },
		},
	},
	
	{
		id = "baby_grandparents_visit",
		minAge = 0, maxAge = 3,
		weight = 30, cooldown = 2,
		emoji = "👴", title = "Grandparents Visit!",
		category = "family",
		text = "Your grandparents came to visit!",
		choices = {
			{ text = "🤗 Run to them", effects = { Happiness = 8 }, resultText = "They showered you with love and treats!" },
			{ text = "😳 Act shy", effects = { Happiness = 3, Smarts = 2 }, resultText = "You warmed up eventually. They thought it was adorable." },
			{ text = "💤 Sleep through it", effects = { Health = 2 }, resultText = "They just watched you sleep peacefully." },
		},
	},
	
	{
		id = "baby_separation_anxiety",
		minAge = 1, maxAge = 3,
		weight = 30, oneTime = true,
		emoji = "😢", title = "Where Did They Go?",
		category = "family",
		text = "Your parent left the room and you can't see them anymore!",
		choices = {
			{ text = "😭 Cry loudly", effects = { Happiness = -3 }, resultText = "They came running back! Crisis averted." },
			{ text = "🏃 Crawl/walk to find them", effects = { Health = 2, Smarts = 3 }, resultText = "You found them! Independence level: unlocked." },
			{ text = "🎮 Get distracted by toys", effects = { Happiness = 4 }, resultText = "You forgot they were gone. Self-soothing mastered!" },
		},
	},
	
	{
		id = "baby_stacking_blocks",
		minAge = 1, maxAge = 3,
		weight = 35, oneTime = true,
		emoji = "🧱", title = "Block Building",
		category = "family",
		getDynamicData = function() return { height = math.random(3, 6) } end,
		text = "You're playing with building blocks!",
		choices = {
			{ text = "🏗️ Build a tower", effects = { Smarts = 5, Happiness = 4 }, resultText = "You built a %height%-block tower! Future engineer!", setFlag = "builder_interest" },
			{ text = "💥 Knock them down!", effects = { Happiness = 6 }, resultText = "CRASH! Destruction is fun too!" },
			{ text = "🎨 Sort by color", effects = { Smarts = 6 }, resultText = "You organized them perfectly. Pattern recognition!" },
		},
	},
	
	{
		id = "baby_animal_sounds",
		minAge = 1, maxAge = 3,
		weight = 35, oneTime = true,
		emoji = "🐄", title = "Animal Sounds",
		category = "family",
		text = "Your parent is teaching you animal sounds!",
		choices = {
			{ text = "🐄 Moo like a cow", effects = { Happiness = 5, Smarts = 3 }, resultText = "MOOO! You got it!" },
			{ text = "🐕 Bark like a dog", effects = { Happiness = 5, Smarts = 3 }, resultText = "WOOF WOOF! Natural communicator!" },
			{ text = "🦁 Roar like a lion", effects = { Happiness = 6, Smarts = 3 }, resultText = "RAWR! You're fearsome!" },
		},
	},
	
	{
		id = "baby_picture_book",
		minAge = 1, maxAge = 3,
		weight = 40, cooldown = 2,
		emoji = "📖", title = "Story Time",
		category = "family",
		getDynamicData = function()
			local books = {"Goodnight Moon", "The Very Hungry Caterpillar", "Where the Wild Things Are", "Pat the Bunny"}
			return { book = books[math.random(#books)] }
		end,
		text = "Your parent is reading '%book%' to you!",
		choices = {
			{ text = "📖 Listen intently", effects = { Smarts = 5, Happiness = 4 }, resultText = "You loved the story! Books are amazing.", setFlag = "loves_stories" },
			{ text = "🖐️ Touch the pictures", effects = { Smarts = 4, Happiness = 3 }, resultText = "You tried to 'help' turn the pages." },
			{ text = "😴 Fall asleep", effects = { Health = 3 }, resultText = "Perfect bedtime routine." },
		},
	},
	
	{
		id = "baby_daycare_first",
		minAge = 1, maxAge = 3,
		weight = 25, oneTime = true, milestone = true,
		emoji = "🏫", title = "First Day at Daycare",
		category = "family",
		text = "Your parents are dropping you off at daycare for the first time!",
		choices = {
			{ text = "👋 Wave bye-bye happily", effects = { Happiness = 5, Smarts = 3 }, resultText = "You adapted so well! Made new friends already.", setFlag = "daycare_kid" },
			{ text = "😭 Cling and cry", effects = { Happiness = -3 }, resultText = "It was hard at first, but you adjusted." },
			{ text = "🧸 Bring comfort item", effects = { Happiness = 3 }, resultText = "Your teddy bear helped you feel safe." },
		},
	},
	
	{
		id = "baby_halloween",
		minAge = 0, maxAge = 3,
		weight = 20, cooldown = 3,
		emoji = "🎃", title = "First Halloween",
		category = "family",
		getDynamicData = function()
			local costumes = {"pumpkin", "bunny", "superhero", "princess", "dinosaur", "lion"}
			return { costume = costumes[math.random(#costumes)] }
		end,
		text = "Your parents dressed you up as a %costume% for Halloween!",
		choices = {
			{ text = "😊 Look adorable", effects = { Happiness = 6, Looks = 3 }, resultText = "Everyone said you were the cutest %costume% ever!" },
			{ text = "😠 Hate the costume", effects = { Happiness = -2 }, resultText = "You kept trying to take it off." },
		},
	},
	
	{
		id = "baby_first_holiday",
		minAge = 0, maxAge = 2,
		weight = 25, oneTime = true,
		emoji = "🎄", title = "First Holiday Season",
		category = "family",
		text = "It's your first holiday season! The house is decorated beautifully.",
		choices = {
			{ text = "✨ Mesmerized by lights", effects = { Happiness = 7 }, resultText = "You stared at the lights for hours in wonder!" },
			{ text = "🎁 Tear up wrapping paper", effects = { Happiness = 8 }, resultText = "You cared more about the paper than the gift!" },
			{ text = "😱 Scared of decorations", effects = { Happiness = -2 }, resultText = "Giant inflatable Santa was terrifying." },
		},
	},
	
	-- ─────────────────────────────────────────────────────────────────
	-- MORE TODDLER EVENTS (Ages 3-4)
	-- ─────────────────────────────────────────────────────────────────
	
	{
		id = "toddler_playground_hero",
		minAge = 3, maxAge = 5,
		weight = 30, oneTime = true,
		emoji = "🦸", title = "Playground Hero",
		category = "social",
		getDynamicData = function() return { kidName = randomName() } end,
		text = "A smaller kid named %kidName% fell down at the playground and is crying!",
		choices = {
			{ text = "🤗 Help them up", effects = { Happiness = 6, Smarts = 3 }, resultText = "You helped them feel better. Natural caregiver!", setFlag = "compassionate" },
			{ text = "📢 Call for adult", effects = { Smarts = 4 }, resultText = "You got help quickly. Smart thinking!" },
			{ text = "🤷 Keep playing", effects = {}, resultText = "Someone else helped them." },
		},
	},
	
	{
		id = "toddler_picky_eater",
		minAge = 2, maxAge = 5,
		weight = 35, cooldown = 2,
		emoji = "🥦", title = "Picky Eater Phase",
		category = "family",
		getDynamicData = function()
			local veggies = {"broccoli", "spinach", "peas", "carrots", "green beans"}
			return { veggie = veggies[math.random(#veggies)] }
		end,
		text = "Your parents want you to eat your %veggie%!",
		choices = {
			{ text = "😤 No way!", effects = { Happiness = 3, Health = -2 }, resultText = "You won this battle. No vegetables today." },
			{ text = "😣 Eat it reluctantly", effects = { Health = 5, Happiness = -2 }, resultText = "It wasn't as bad as you thought." },
			{ text = "🎭 Make a game of it", effects = { Happiness = 4, Health = 3 }, resultText = "Pretending to be a dinosaur eating trees made it fun!", setFlag = "imaginative" },
		},
	},
	
	{
		id = "toddler_first_sleepover",
		minAge = 4, maxAge = 6,
		weight = 25, oneTime = true,
		emoji = "🌙", title = "First Sleepover",
		category = "social",
		getDynamicData = function() return { friendName = randomName() } end,
		text = "You're invited to your first sleepover at %friendName%'s house!",
		choices = {
			{ text = "🎉 So excited!", effects = { Happiness = 8 }, resultText = "Best night ever! You stayed up way too late." },
			{ text = "😰 Too scary", effects = { Happiness = -3 }, resultText = "You called your parents to come get you." },
			{ text = "🧸 Bring backup", effects = { Happiness = 5 }, resultText = "Your stuffed animal made you feel brave enough." },
		},
	},
	
	{
		id = "toddler_coloring_mastery",
		minAge = 3, maxAge = 5,
		weight = 35, oneTime = true,
		emoji = "🖍️", title = "Coloring Skills",
		category = "family",
		text = "You're getting really good at coloring inside the lines!",
		choices = {
			{ text = "🖍️ Perfect every page", effects = { Smarts = 4, Happiness = 4 }, resultText = "Your coloring books are works of art!", setFlag = "detail_oriented" },
			{ text = "🌈 Use ALL the colors", effects = { Happiness = 5 }, resultText = "Rules are for boring people! Creative chaos!" },
			{ text = "🎨 Start drawing own pictures", effects = { Smarts = 5, Happiness = 3 }, resultText = "You graduated from coloring to creating!", setFlag = "art_interest" },
		},
	},
	
	{
		id = "toddler_question_phase",
		minAge = 3, maxAge = 5,
		weight = 40, cooldown = 2,
		emoji = "❓", title = "Why? Why? Why?",
		category = "family",
		text = "You've discovered the most powerful word: WHY?",
		choices = {
			{ text = "❓ Ask everything", effects = { Smarts = 6, Happiness = 3 }, resultText = "You drove your parents crazy but learned so much!", setFlag = "curious_mind" },
			{ text = "🔬 Investigate yourself", effects = { Smarts = 5, Health = -2 }, resultText = "You found out why the stove is hot. Ouch." },
			{ text = "📚 Look at books", effects = { Smarts = 4 }, resultText = "Pictures helped answer some questions." },
		},
	},
	
	{
		id = "toddler_sharing_lesson",
		minAge = 2, maxAge = 5,
		weight = 35, oneTime = true,
		emoji = "🤝", title = "Learning to Share",
		category = "social",
		getDynamicData = function() return { friendName = randomName() } end,
		text = "%friendName% wants to play with your favorite toy!",
		choices = {
			{ text = "🤝 Share it", effects = { Happiness = 5, Smarts = 3 }, resultText = "Sharing is caring! You made a good friend.", setFlag = "generous" },
			{ text = "😤 Mine!", effects = { Happiness = 3, Smarts = -2 }, resultText = "You kept it but felt weird about it later." },
			{ text = "🔄 Take turns", effects = { Smarts = 5, Happiness = 4 }, resultText = "You invented a turn-taking game! Problem solved.", setFlag = "problem_solver" },
		},
	},
	
	{
		id = "toddler_monster_fear",
		minAge = 3, maxAge = 6,
		weight = 30, oneTime = true,
		emoji = "👹", title = "Monster Under the Bed",
		category = "family",
		text = "You're convinced there's a monster under your bed!",
		choices = {
			{ text = "😭 Cry for parents", effects = { Happiness = 3 }, resultText = "They checked and showed you it was safe." },
			{ text = "💪 Be brave", effects = { Happiness = 5, Smarts = 3 }, resultText = "You looked yourself! Nothing there. You're so brave!", setFlag = "brave" },
			{ text = "🔦 Keep a flashlight", effects = { Happiness = 4, Smarts = 2 }, resultText = "Monsters hate light. You're prepared now." },
		},
	},
	
	{
		id = "toddler_owie",
		minAge = 2, maxAge = 5,
		weight = 35, cooldown = 2,
		emoji = "🩹", title = "First Big Owie",
		category = "health",
		text = "You fell and got a scrape on your knee!",
		choices = {
			{ text = "😭 Cry a lot", effects = { Happiness = -3, Health = -2 }, resultText = "It really hurt! But mom's kisses helped." },
			{ text = "💪 Tough it out", effects = { Health = -2, Happiness = 5 }, resultText = "You barely cried! So brave!", setFlag = "pain_tolerant" },
			{ text = "🩹 Want a cool bandaid", effects = { Happiness = 3, Health = 2 }, resultText = "The dinosaur bandaid made everything better." },
		},
	},
	
	{
		id = "toddler_counting",
		minAge = 3, maxAge = 5,
		weight = 35, oneTime = true,
		emoji = "🔢", title = "Learning to Count",
		category = "family",
		text = "You're learning your numbers!",
		choices = {
			{ text = "🔢 Count everything", effects = { Smarts = 6, Happiness = 3 }, resultText = "1, 2, 3... you counted all the way to 20!", setFlag = "math_interest" },
			{ text = "🎵 Sing number songs", effects = { Smarts = 4, Happiness = 5 }, resultText = "Learning through music makes it fun!" },
			{ text = "🤷 Numbers are boring", effects = { Smarts = 2 }, resultText = "You preferred other activities." },
		},
	},
	
	{
		id = "toddler_abc",
		minAge = 3, maxAge = 5,
		weight = 35, oneTime = true,
		emoji = "📝", title = "Learning the Alphabet",
		category = "family",
		text = "ABC, it's easy as 1-2-3!",
		choices = {
			{ text = "🎵 Sing the ABC song", effects = { Smarts = 5, Happiness = 4 }, resultText = "Now you know your ABCs!" },
			{ text = "✏️ Practice writing letters", effects = { Smarts = 6 }, resultText = "Your letters are getting better!", setFlag = "early_reader" },
			{ text = "📚 Find letters everywhere", effects = { Smarts = 5, Happiness = 3 }, resultText = "You point out letters on signs, cereal boxes, everywhere!" },
		},
	},
	
	{
		id = "toddler_bike_training",
		minAge = 3, maxAge = 5,
		weight = 30, oneTime = true,
		emoji = "🚲", title = "Training Wheels",
		category = "family",
		text = "You got a bike with training wheels!",
		choices = {
			{ text = "🚲 Ride everywhere!", effects = { Health = 5, Happiness = 6 }, resultText = "Freedom! You love your bike!", setFlag = "bike_rider" },
			{ text = "😰 Scary at first", effects = { Happiness = 3, Health = 3 }, resultText = "You're getting more confident every day." },
			{ text = "🏃 Prefer running", effects = { Health = 4, Happiness = 2 }, resultText = "Bikes aren't your thing." },
		},
	},
	
	{
		id = "toddler_first_lie",
		minAge = 3, maxAge = 5,
		weight = 25, oneTime = true,
		emoji = "🤥", title = "First Little Lie",
		category = "family",
		getDynamicData = function()
			local situations = {"broken vase", "eaten cookie", "colored wall", "spilled juice"}
			return { situation = situations[math.random(#situations)] }
		end,
		text = "There's a %situation% and your parents ask if you did it...",
		choices = {
			{ text = "😇 Tell the truth", effects = { Smarts = 4, Happiness = 3 }, resultText = "Honesty is the best policy. You got praised for being truthful.", setFlag = "honest" },
			{ text = "🤥 Wasn't me!", effects = { Smarts = 2, Happiness = -3 }, resultText = "They knew you were lying. Trust is hard to rebuild." },
			{ text = "🐕 Blame the pet", effects = { Smarts = 3, Happiness = 2 }, resultText = "Creative, but they didn't buy it." },
		},
	},
	
	-- ─────────────────────────────────────────────────────────────────
	-- MORE CHILDHOOD EVENTS (Ages 5-11)
	-- ─────────────────────────────────────────────────────────────────
	
	{
		id = "child_school_play",
		minAge = 6, maxAge = 11,
		weight = 25, cooldown = 3,
		emoji = "🎭", title = "School Play",
		category = "school",
		getDynamicData = function()
			local plays = {"The Wizard of Oz", "Peter Pan", "Alice in Wonderland", "Christmas Carol"}
			return { play = plays[math.random(#plays)] }
		end,
		text = "There's a school production of '%play%'. Auditions are open!",
		choices = {
			{ text = "🌟 Try for the lead", effects = { Happiness = 8, Looks = 3 }, resultText = "You got the lead role! Star of the show!", setFlag = "performer" },
			{ text = "🎭 Get a supporting role", effects = { Happiness = 5 }, resultText = "You nailed your part! Great experience." },
			{ text = "🔧 Work backstage", effects = { Smarts = 4, Happiness = 3 }, resultText = "Behind the scenes is where the magic happens." },
			{ text = "🙅 Too nervous", effects = { Happiness = -2 }, resultText = "Maybe next time you'll be braver." },
		},
	},
	
	{
		id = "child_sports_tryout",
		minAge = 6, maxAge = 12,
		weight = 30, cooldown = 2,
		emoji = "⚽", title = "Sports Tryouts",
		category = "school",
		getDynamicData = function()
			local sports = {"soccer", "basketball", "baseball", "swimming", "gymnastics", "martial arts"}
			return { sport = sports[math.random(#sports)] }
		end,
		text = "Tryouts for the %sport% team are coming up!",
		choices = {
			{ text = "🏆 Go for it!", effects = { Health = 6, Happiness = 6 }, resultText = "You made the team!", setFlag = "athletic_child" },
			{ text = "😅 Just for fun", effects = { Health = 4, Happiness = 4 }, resultText = "You didn't make it but had fun trying." },
			{ text = "📚 Sports aren't my thing", effects = { Smarts = 2 }, resultText = "You focused on other activities instead." },
		},
	},
	
	{
		id = "child_class_president",
		minAge = 8, maxAge = 12,
		weight = 20, oneTime = true,
		emoji = "🎤", title = "Class President Election",
		category = "school",
		text = "Elections for class president! Do you want to run?",
		choices = {
			{ text = "📢 Campaign hard!", effects = { Smarts = 5, Happiness = 8 }, resultText = "You won! First taste of leadership.", setFlags = {"class_president", "political_interest"} },
			{ text = "🤝 Help a friend run", effects = { Happiness = 5, Smarts = 3 }, resultText = "Your friend won thanks to you! Team player.", setFlag = "campaign_experience" },
			{ text = "🙅 Not interested", effects = {}, resultText = "Politics isn't your thing." },
		},
	},
	
	{
		id = "child_spelling_bee",
		minAge = 7, maxAge = 12,
		weight = 25, cooldown = 3,
		emoji = "📝", title = "Spelling Bee",
		category = "school",
		getDynamicData = function()
			local words = {"supercalifragilisticexpialidocious", "pneumonia", "entrepreneur", "conscientious", "onomatopoeia"}
			return { word = words[math.random(#words)] }
		end,
		text = "The school spelling bee finals! Your word is... '%word%'!",
		choices = {
			{ text = "📝 Spell it perfectly", effects = { Smarts = 8, Happiness = 8 }, resultText = "CORRECT! You're the spelling champion!", setFlag = "spelling_champion" },
			{ text = "😰 Panic and guess", effects = { Smarts = 3, Happiness = -2 }, resultText = "You got it wrong but learned from the experience." },
		},
	},
	
	{
		id = "child_first_crush",
		minAge = 8, maxAge = 12,
		weight = 20, oneTime = true,
		emoji = "💕", title = "First Crush",
		category = "social",
		getDynamicData = function() return { crushName = randomName() } end,
		text = "You can't stop thinking about %crushName% in your class...",
		choices = {
			{ text = "💌 Write a note", effects = { Happiness = 5 }, resultText = "They thought it was sweet! You're friends now." },
			{ text = "😳 Keep it secret", effects = { Happiness = 3, Smarts = 2 }, resultText = "Some feelings are private. You handled it maturely." },
			{ text = "🗣️ Tell everyone", effects = { Happiness = -3 }, resultText = "Kids are cruel. You got teased." },
		},
	},
	
	{
		id = "child_club_join",
		minAge = 7, maxAge = 12,
		weight = 30, cooldown = 2,
		emoji = "🎯", title = "Join a Club",
		category = "school",
		getDynamicData = function()
			local clubs = {"chess club", "debate team", "robotics club", "art club", "coding club", "book club", "drama club"}
			return { club = clubs[math.random(#clubs)] }
		end,
		text = "The %club% is looking for new members!",
		choices = {
			{ text = "✅ Sign up!", effects = { Smarts = 5, Happiness = 4 }, resultText = "You love the %club%! Made new friends too." },
			{ text = "🤔 Not for me", effects = {}, resultText = "You passed. Something else will come along." },
		},
	},
	
	{
		id = "child_library_discovery",
		minAge = 6, maxAge = 12,
		weight = 25, oneTime = true,
		emoji = "📚", title = "Library Card!",
		category = "school",
		text = "You got your very own library card!",
		choices = {
			{ text = "📚 Read everything!", effects = { Smarts = 8, Happiness = 5 }, resultText = "You discovered a whole world of books!", setFlag = "bookworm" },
			{ text = "🔬 Find the science section", effects = { Smarts = 6, Happiness = 4 }, resultText = "So many science books! Experiments await!", setFlag = "science_interest" },
			{ text = "💻 Use the computers", effects = { Smarts = 5, Happiness = 3 }, resultText = "You discovered the internet at the library!", setFlag = "computer_interest" },
		},
	},
	
	{
		id = "child_allowance",
		minAge = 6, maxAge = 12,
		weight = 30, oneTime = true,
		emoji = "💰", title = "First Allowance",
		category = "family",
		getDynamicData = function() return { amount = math.random(5, 15) } end,
		text = "You started getting $%amount% weekly allowance!",
		choices = {
			{ text = "💰 Save it all", effects = { Smarts = 5, Money = 50 }, resultText = "You're learning about money management!", setFlag = "saver" },
			{ text = "🍬 Spend immediately", effects = { Happiness = 6 }, resultText = "Candy and toys! So much fun!" },
			{ text = "📊 Save half, spend half", effects = { Smarts = 6, Happiness = 3, Money = 25 }, resultText = "Balanced approach. Financially smart!" },
		},
	},
	
	{
		id = "child_instrument_choice",
		minAge = 6, maxAge = 10,
		weight = 25, oneTime = true,
		emoji = "🎸", title = "Music Lessons",
		category = "school",
		text = "You can start learning a musical instrument!",
		choices = {
			{ text = "🎹 Piano", effects = { Smarts = 5, Happiness = 4 }, resultText = "Piano lessons begin! Classical foundations.", setFlag = "musician" },
			{ text = "🎸 Guitar", effects = { Happiness = 6, Looks = 2 }, resultText = "Guitar is so cool! You're going to rock.", setFlag = "musician" },
			{ text = "🥁 Drums", effects = { Happiness = 7, Health = 3 }, resultText = "You're a natural drummer! Loud but fun.", setFlag = "musician" },
			{ text = "🎻 Violin", effects = { Smarts = 6 }, resultText = "Violin requires dedication. You're committed.", setFlag = "musician" },
			{ text = "🙅 No music", effects = { Happiness = 2 }, resultText = "Music isn't your thing." },
		},
	},
	
	{
		id = "child_camp_summer",
		minAge = 7, maxAge = 12,
		weight = 20, cooldown = 3,
		emoji = "🏕️", title = "Summer Camp",
		category = "social",
		getDynamicData = function()
			local camps = {"wilderness camp", "science camp", "sports camp", "art camp", "computer camp"}
			return { camp = camps[math.random(#camps)] }
		end,
		text = "Your parents want to send you to %camp% this summer!",
		choices = {
			{ text = "🎉 Can't wait!", effects = { Happiness = 8, Health = 3 }, resultText = "Best summer ever! You made lifelong friends." },
			{ text = "😰 Homesick worry", effects = { Happiness = 4, Smarts = 3 }, resultText = "You were scared at first but ended up loving it." },
			{ text = "🙅 Stay home", effects = { Happiness = 3 }, resultText = "You had a quiet summer instead." },
		},
	},
	
	{
		id = "child_video_game_love",
		minAge = 6, maxAge = 12,
		weight = 35, oneTime = true,
		emoji = "🎮", title = "Gaming Discovery",
		category = "social",
		getDynamicData = function()
			local games = {"Mario", "Minecraft", "Pokémon", "Zelda", "Roblox"}
			return { game = games[math.random(#games)] }
		end,
		text = "You discovered %game%! Video games are amazing!",
		choices = {
			{ text = "🎮 Play constantly", effects = { Happiness = 8, Health = -2 }, resultText = "You got really good but should go outside more." },
			{ text = "⚖️ Balance gaming and life", effects = { Happiness = 5, Smarts = 3 }, resultText = "You learned to manage your time well." },
			{ text = "🛠️ Start modding games", effects = { Smarts = 6, Happiness = 4 }, resultText = "You started customizing games! Future developer?", setFlag = "computer_interest" },
		},
	},
	
	{
		id = "child_cooking_helper",
		minAge = 6, maxAge = 11,
		weight = 25, oneTime = true,
		emoji = "👨‍🍳", title = "Kitchen Helper",
		category = "family",
		text = "Your parent asks if you want to help cook dinner!",
		choices = {
			{ text = "👨‍🍳 Yes please!", effects = { Smarts = 4, Happiness = 5 }, resultText = "You made dinner together! Delicious and fun.", setFlag = "cooking_interest" },
			{ text = "🍪 Only if we make dessert", effects = { Happiness = 6 }, resultText = "Cookies! The best part of cooking." },
			{ text = "📺 Rather watch TV", effects = { Happiness = 3 }, resultText = "You missed a bonding moment." },
		},
	},
	
	{
		id = "child_lost_tooth",
		minAge = 5, maxAge = 10,
		weight = 35, cooldown = 2,
		emoji = "🦷", title = "Lost a Tooth!",
		category = "health",
		text = "Your tooth is super wiggly... and it just came out!",
		choices = {
			{ text = "🧚 Put it under pillow", effects = { Happiness = 5, Money = 5 }, resultText = "The tooth fairy left you money!" },
			{ text = "😬 Show everyone", effects = { Happiness = 4, Looks = -2 }, resultText = "You smiled big showing your new gap!" },
			{ text = "😰 Scared", effects = { Happiness = -2 }, resultText = "It was scary but you're okay." },
		},
	},
	
	{
		id = "child_homework_struggle",
		minAge = 6, maxAge = 12,
		weight = 40, cooldown = 2,
		emoji = "📝", title = "Homework Challenge",
		category = "school",
		getDynamicData = function()
			local subjects = {"math", "reading", "science", "history", "writing"}
			return { subject = subjects[math.random(#subjects)] }
		end,
		text = "This %subject% homework is really hard!",
		choices = {
			{ text = "💪 Keep trying", effects = { Smarts = 6, Happiness = 4 }, resultText = "You figured it out! Persistence pays off.", setFlag = "determined" },
			{ text = "🙋 Ask for help", effects = { Smarts = 5, Happiness = 3 }, resultText = "A parent or teacher helped you understand." },
			{ text = "😴 Give up", effects = { Smarts = -2, Happiness = -3 }, resultText = "You didn't finish it. Teacher was disappointed." },
		},
	},
	
	{
		id = "child_glasses_needed",
		minAge = 6, maxAge = 12,
		weight = 15, oneTime = true,
		emoji = "👓", title = "You Need Glasses",
		category = "health",
		text = "The eye doctor says you need glasses!",
		choices = {
			{ text = "😎 Pick cool frames", effects = { Happiness = 5, Looks = 3, Smarts = 3 }, resultText = "You can see AND you look stylish!", setFlag = "wears_glasses" },
			{ text = "😞 Don't want them", effects = { Happiness = -3, Smarts = 3 }, resultText = "You got them anyway. At least you can see now.", setFlag = "wears_glasses" },
		},
	},
	
	{
		id = "child_nature_discovery",
		minAge = 5, maxAge = 11,
		weight = 25, oneTime = true,
		emoji = "🐛", title = "Nature Explorer",
		category = "social",
		text = "You're exploring outside and find a fascinating insect!",
		choices = {
			{ text = "🔬 Study it closely", effects = { Smarts = 6, Happiness = 4 }, resultText = "You learned so much about bugs!", setFlag = "science_interest" },
			{ text = "🏠 Keep it as a pet", effects = { Happiness = 5 }, resultText = "You had a new friend... for a few days." },
			{ text = "😱 Eww, gross!", effects = { Happiness = 2 }, resultText = "You ran away. Bugs aren't for everyone." },
		},
	},
	
	{
		id = "child_standing_up_bully",
		minAge = 7, maxAge = 12,
		weight = 20, oneTime = true,
		emoji = "💪", title = "Defending a Friend",
		category = "social",
		getDynamicData = function() return { friendName = randomName(), bullyName = randomName() } end,
		text = "%bullyName% is picking on your friend %friendName%!",
		choices = {
			{ text = "🦸 Stand up for them", effects = { Happiness = 8, Health = -3 }, resultText = "You defended your friend! They'll never forget it.", setFlags = {"brave", "loyal_friend"} },
			{ text = "📢 Get a teacher", effects = { Smarts = 5, Happiness = 4 }, resultText = "The teacher handled it. Smart choice." },
			{ text = "👀 Watch from afar", effects = { Happiness = -5 }, resultText = "You felt guilty for not helping." },
		},
	},
	
	{
		id = "child_bike_no_training",
		minAge = 5, maxAge = 8,
		weight = 25, oneTime = true,
		emoji = "🚲", title = "Training Wheels Off!",
		category = "family",
		requires = function(state) return state.Flags and state.Flags.bike_rider end,
		text = "Time to take off the training wheels!",
		choices = {
			{ text = "💪 Go for it!", effects = { Health = 4, Happiness = 8 }, resultText = "You did it! Riding without training wheels!", setFlag = "real_cyclist" },
			{ text = "😰 Not ready yet", effects = { Happiness = -2 }, resultText = "Maybe next time you'll be braver." },
		},
	},
	
	{
		id = "child_chores",
		minAge = 6, maxAge = 12,
		weight = 35, cooldown = 2,
		emoji = "🧹", title = "Chore Time",
		category = "family",
		getDynamicData = function()
			local chores = {"clean your room", "do the dishes", "take out the trash", "mow the lawn", "fold laundry"}
			return { chore = chores[math.random(#chores)] }
		end,
		text = "Your parent asks you to %chore%!",
		choices = {
			{ text = "✅ Do it without complaining", effects = { Happiness = 4, Smarts = 2 }, resultText = "Good job! You earned some praise." },
			{ text = "😤 Complain then do it", effects = { Happiness = 2 }, resultText = "You did it eventually. Drama was unnecessary." },
			{ text = "🙅 Refuse", effects = { Happiness = -5 }, resultText = "You got in trouble. Not worth it." },
		},
	},
	
	{
		id = "child_new_kid_school",
		minAge = 6, maxAge = 12,
		weight = 20, cooldown = 3,
		emoji = "👋", title = "New Kid in Class",
		category = "social",
		getDynamicData = function() return { newKidName = randomName() } end,
		text = "A new kid named %newKidName% joined your class. They look lonely.",
		choices = {
			{ text = "👋 Be their friend", effects = { Happiness = 6, Smarts = 2 }, resultText = "You made a new friend! They were so grateful.", setFlag = "compassionate" },
			{ text = "🤷 Let them figure it out", effects = {}, resultText = "Someone else befriended them." },
			{ text = "😈 Be mean", effects = { Happiness = -5, Smarts = -3 }, resultText = "Why would you do that? You felt bad later." },
		},
	},

	-- ═══════════════════════════════════════════════════════════════════════════
	-- ███████████████████████████████████████████████████████████████████████████
	-- MASSIVE EXPANSION PART 2: TEEN YEARS (12-17)
	-- ███████████████████████████████████████████████████████████████████████████
	-- ═══════════════════════════════════════════════════════════════════════════
	
	{
		id = "teen_middle_school",
		minAge = 12, maxAge = 12,
		weight = 100, oneTime = true, milestone = true,
		emoji = "🏫", title = "Middle School Begins",
		category = "school",
		text = "Welcome to middle school! Everything is changing - your body, your friends, your life.",
		choices = {
			{ text = "📚 Focus on grades", effects = { Smarts = 6, Happiness = 3 }, resultText = "You decided academics would be your priority.", setFlag = "studious" },
			{ text = "👥 Focus on friends", effects = { Happiness = 6, Smarts = 2 }, resultText = "Your social circle expanded dramatically.", setFlag = "social_butterfly" },
			{ text = "🏃 Focus on activities", effects = { Health = 5, Happiness = 4 }, resultText = "You joined everything! Sports, clubs, you name it.", setFlag = "active_kid" },
		},
	},
	
	{
		id = "teen_puberty_start",
		minAge = 12, maxAge = 14,
		weight = 35, oneTime = true,
		emoji = "😰", title = "Puberty Hits",
		category = "health",
		text = "Your body is going through some... changes. It's confusing.",
		choices = {
			{ text = "📚 Learn about it", effects = { Smarts = 5, Happiness = 3 }, resultText = "You educated yourself. Knowledge is power." },
			{ text = "😰 Panic a little", effects = { Happiness = -3 }, resultText = "Everyone goes through this. It gets easier." },
			{ text = "🤷 Go with the flow", effects = { Happiness = 2, Health = 2 }, resultText = "You handled it with grace." },
		},
	},
	
	{
		id = "teen_acne_struggle",
		minAge = 12, maxAge = 18,
		weight = 30, cooldown = 3,
		emoji = "😫", title = "Acne Attack",
		category = "health",
		text = "You woke up with a face full of acne before a big event!",
		choices = {
			{ text = "💊 Get treatment", effects = { Money = -50, Looks = 3, Happiness = 3 }, resultText = "The treatment helped a lot!" },
			{ text = "🤷 It's just skin", effects = { Happiness = 5, Smarts = 3 }, resultText = "You didn't let it bother you. Confidence is attractive." },
			{ text = "😭 Hide at home", effects = { Happiness = -5, Looks = -2 }, resultText = "You missed out and felt worse." },
		},
	},
	
	{
		id = "teen_first_job_offer",
		minAge = 14, maxAge = 17,
		weight = 25, oneTime = true,
		emoji = "💼", title = "First Job Offer",
		category = "work",
		getDynamicData = function()
			local jobs = {"babysitting", "lawn mowing", "fast food", "retail", "tutoring", "lifeguarding"}
			return { job = jobs[math.random(#jobs)] }
		end,
		text = "You got offered a part-time %job% job!",
		choices = {
			{ text = "💼 Take the job!", effects = { Money = 500, Happiness = 5, Smarts = 3 }, resultText = "Your first paycheck! Financial independence begins.", setFlag = "first_job_done" },
			{ text = "📚 Focus on school", effects = { Smarts = 5 }, resultText = "Grades come first. Smart choice." },
			{ text = "🎮 Too busy", effects = { Happiness = 3 }, resultText = "You had other priorities." },
		},
	},
	
	{
		id = "teen_first_party",
		minAge = 14, maxAge = 18,
		weight = 30, oneTime = true,
		emoji = "🎉", title = "First Real Party",
		category = "social",
		getDynamicData = function() return { hostName = randomName() } end,
		text = "%hostName% is throwing a party and you're invited! Parents won't be home...",
		choices = {
			{ text = "🎉 Go and have fun responsibly", effects = { Happiness = 8 }, resultText = "It was epic! You had a blast and made great memories." },
			{ text = "😈 Go wild!", effects = { Happiness = 10, Health = -5, Smarts = -3 }, resultText = "You partied too hard. Worth it? Maybe.", setFlag = "party_animal" },
			{ text = "🙅 Skip it", effects = { Happiness = -3, Smarts = 2 }, resultText = "You heard stories on Monday. FOMO is real." },
			{ text = "🚔 Tell parents", effects = { Happiness = -5, Smarts = 3 }, resultText = "Party got shut down. You're not popular now." },
		},
	},
	
	{
		id = "teen_first_date",
		minAge = 14, maxAge = 18,
		weight = 30, oneTime = true,
		emoji = "💕", title = "First Real Date",
		category = "romance",
		getDynamicData = function() return { dateName = randomName() } end,
		text = "%dateName% asked you out on a real date!",
		choices = {
			{ text = "💕 Say yes!", effects = { Happiness = 10 }, resultText = "Butterflies in your stomach! The date went great.", setFlag = "dating_experience" },
			{ text = "😰 Too nervous", effects = { Happiness = -3 }, resultText = "You said no and immediately regretted it." },
			{ text = "🤔 Friends first", effects = { Happiness = 3, Smarts = 3 }, resultText = "You wanted to know them better first. Mature!" },
		},
	},
	
	{
		id = "teen_social_media_account",
		minAge = 13, maxAge = 16,
		weight = 35, oneTime = true,
		emoji = "📱", title = "Social Media",
		category = "social",
		text = "All your friends are on social media. Do you join?",
		choices = {
			{ text = "📱 Create accounts!", effects = { Happiness = 6 }, resultText = "You're connected! So many followers already.", setFlag = "social_media_user" },
			{ text = "📸 Just for photos", effects = { Happiness = 4, Looks = 3 }, resultText = "You use it for art/photos only." },
			{ text = "🙅 Stay offline", effects = { Smarts = 4, Happiness = -2 }, resultText = "You missed out socially but avoided drama." },
		},
	},
	
	{
		id = "teen_gaming_career",
		minAge = 13, maxAge = 18,
		weight = 20, oneTime = true,
		emoji = "🎮", title = "Gaming Ambitions",
		category = "social",
		requires = function(state) return state.Flags and state.Flags.computer_interest end,
		text = "You're really good at games. Could you go pro?",
		choices = {
			{ text = "🎮 Try competitive gaming", effects = { Smarts = 4, Happiness = 6 }, resultText = "You started entering tournaments!", setFlag = "competitive_gamer" },
			{ text = "📺 Start streaming", effects = { Happiness = 5, Money = 100 }, resultText = "You started a gaming channel!", setFlag = "content_creator" },
			{ text = "🤷 Just for fun", effects = { Happiness = 3 }, resultText = "Games are a hobby, not a career. That's okay." },
		},
	},
	
	{
		id = "teen_peer_pressure_alcohol",
		minAge = 15, maxAge = 18,
		weight = 20, oneTime = true,
		emoji = "🍺", title = "Peer Pressure",
		category = "social",
		getDynamicData = function() return { peerName = randomName() } end,
		text = "%peerName% offers you a drink at a party. Everyone's watching.",
		choices = {
			{ text = "🍺 Just one...", effects = { Happiness = 3, Health = -3, Smarts = -2 }, resultText = "One turned into more. You didn't feel great the next day." },
			{ text = "🙅 No thanks", effects = { Happiness = 5, Smarts = 5 }, resultText = "You stood your ground. Real friends respected that.", setFlag = "resists_peer_pressure" },
			{ text = "🏃 Leave the party", effects = { Happiness = -3, Health = 2 }, resultText = "You removed yourself from the situation. Smart." },
		},
	},
	
	{
		id = "teen_peer_pressure_drugs",
		minAge = 15, maxAge = 18,
		weight = 15, oneTime = true,
		emoji = "💊", title = "Dangerous Offer",
		category = "social",
		getDynamicData = function() return { dealerName = randomName() } end,
		text = "%dealerName% is offering something illegal. Your heart is racing.",
		choices = {
			{ text = "💊 Try it", effects = { Happiness = 3, Health = -10, Smarts = -5 }, resultText = "Bad decision. Really bad decision.", setFlag = "drug_user" },
			{ text = "🙅 Hard pass", effects = { Happiness = 5, Smarts = 8 }, resultText = "You said no. Best choice you ever made.", setFlag = "drug_free" },
			{ text = "🚔 Report them", effects = { Smarts = 5, Happiness = -3 }, resultText = "You did the right thing but made an enemy." },
		},
	},
	
	{
		id = "teen_body_image",
		minAge = 13, maxAge = 18,
		weight = 25, cooldown = 3,
		emoji = "🪞", title = "Body Image",
		category = "health",
		text = "You've been comparing yourself to others. Feeling insecure.",
		choices = {
			{ text = "💪 Start working out", effects = { Health = 6, Looks = 4, Happiness = 5 }, resultText = "Exercise helped you feel better in your own skin." },
			{ text = "🧠 Work on self-love", effects = { Happiness = 8, Smarts = 4 }, resultText = "You learned to appreciate yourself. Growth!" },
			{ text = "😔 Spiral down", effects = { Happiness = -10, Health = -5 }, resultText = "It got bad. Please talk to someone." },
		},
	},
	
	{
		id = "teen_SAT_prep",
		minAge = 16, maxAge = 17,
		weight = 35, oneTime = true,
		emoji = "📝", title = "SAT Prep",
		category = "school",
		text = "SAT testing is coming up. Time to prepare!",
		choices = {
			{ text = "📚 Study intensively", effects = { Smarts = 10, Happiness = -3 }, resultText = "You scored amazingly! College doors are open.", setFlag = "high_SAT" },
			{ text = "📖 Moderate study", effects = { Smarts = 6, Happiness = 2 }, resultText = "Good score. Solid performance." },
			{ text = "🤷 Wing it", effects = { Smarts = 2, Happiness = 3 }, resultText = "Could have gone better. More options would be nice." },
		},
	},
	
	{
		id = "teen_college_tour",
		minAge = 16, maxAge = 17,
		weight = 30, oneTime = true,
		emoji = "🎓", title = "College Tour",
		category = "school",
		getDynamicData = function() return { college = randomUniversity() } end,
		text = "Your family is touring %college%!",
		choices = {
			{ text = "😍 I love it here!", effects = { Happiness = 8, Smarts = 3 }, resultText = "This could be your future home!", setFlag = "dream_college" },
			{ text = "🤔 It's okay", effects = { Happiness = 3 }, resultText = "Keep looking. The right fit is out there." },
			{ text = "🙅 College isn't for me", effects = { Happiness = 2, Smarts = -2 }, resultText = "You're considering other paths." },
		},
	},
	
	{
		id = "teen_part_time_coding",
		minAge = 15, maxAge = 18,
		weight = 15, oneTime = true,
		emoji = "💻", title = "Coding Side Gig",
		category = "work",
		requires = function(state) return state.Flags and state.Flags.computer_interest end,
		text = "Someone found out you can code and wants to pay you for a website!",
		choices = {
			{ text = "💻 Take the gig!", effects = { Money = 500, Smarts = 6, Happiness = 8 }, resultText = "You built a website and got paid! Entrepreneurial spirit.", setFlag = "freelance_dev" },
			{ text = "😰 Too much pressure", effects = { Smarts = 2 }, resultText = "You passed. Maybe next time." },
		},
	},
	
	{
		id = "teen_volunteer_work",
		minAge = 14, maxAge = 18,
		weight = 25, cooldown = 2,
		emoji = "🤝", title = "Volunteer Opportunity",
		category = "social",
		getDynamicData = function()
			local orgs = {"homeless shelter", "animal rescue", "food bank", "hospital", "environmental cleanup"}
			return { org = orgs[math.random(#orgs)] }
		end,
		text = "There's an opportunity to volunteer at the %org%.",
		choices = {
			{ text = "🤝 Sign up!", effects = { Happiness = 8, Smarts = 4 }, resultText = "You made a real difference! College apps will love this.", setFlag = "volunteer" },
			{ text = "⏰ Too busy", effects = {}, resultText = "You had other commitments." },
		},
	},
	
	{
		id = "teen_fight_at_school",
		minAge = 13, maxAge = 18,
		weight = 15, cooldown = 3,
		emoji = "👊", title = "School Fight",
		category = "social",
		getDynamicData = function() return { enemyName = randomName() } end,
		text = "%enemyName% is trying to start a fight with you at school!",
		choices = {
			{ text = "👊 Fight back", effects = { Health = -10, Happiness = 5 }, resultText = "You got suspended but earned respect.", setFlags = {"fights_back", "suspension"} },
			{ text = "🗣️ Talk it out", effects = { Smarts = 6, Happiness = 3 }, resultText = "You de-escalated the situation. Impressive." },
			{ text = "🏃 Walk away", effects = { Happiness = -5, Smarts = 4 }, resultText = "Some called you a coward. You called it smart." },
		},
	},
	
	{
		id = "teen_heartbreak",
		minAge = 14, maxAge = 18,
		weight = 20, cooldown = 3,
		emoji = "💔", title = "First Heartbreak",
		category = "romance",
		requires = function(state) return state.Flags and state.Flags.dating_experience end,
		getDynamicData = function() return { exName = randomName() } end,
		text = "%exName% broke up with you. It hurts so much.",
		choices = {
			{ text = "😭 Cry it out", effects = { Happiness = -10 }, resultText = "You needed to feel this. It's part of growing up." },
			{ text = "🎵 Channel it into art", effects = { Happiness = -3, Smarts = 5 }, resultText = "Your pain became beautiful art.", setFlag = "creative_outlet" },
			{ text = "💪 Focus on yourself", effects = { Happiness = 3, Health = 5 }, resultText = "You hit the gym and worked on yourself." },
		},
	},
	
	{
		id = "teen_prom_ask",
		minAge = 16, maxAge = 18,
		weight = 25, cooldown = 2,
		emoji = "🌹", title = "Prom-posal",
		category = "romance",
		getDynamicData = function() return { promName = randomName() } end,
		text = "Prom is coming up! %promName% is who you want to go with.",
		choices = {
			{ text = "🌹 Ask them big!", effects = { Happiness = 10, Money = -50 }, resultText = "They said yes! Your promposal went viral!", setFlag = "has_prom_date" },
			{ text = "😊 Ask simply", effects = { Happiness = 7 }, resultText = "They said yes! Simple but sweet." },
			{ text = "🙅 Go alone/with friends", effects = { Happiness = 5 }, resultText = "You don't need a date to have fun!" },
		},
	},
	
	{
		id = "teen_prom_night",
		minAge = 17, maxAge = 18,
		weight = 50, oneTime = true, milestone = true,
		emoji = "🎭", title = "Prom Night!",
		category = "social",
		text = "It's prom night! The biggest event of high school!",
		choices = {
			{ text = "👑 Best night ever", effects = { Happiness = 15, Looks = 5 }, resultText = "You danced all night. Unforgettable memories.", setFlag = "prom_king_queen" },
			{ text = "😊 Great night", effects = { Happiness = 10 }, resultText = "A wonderful night with friends and fun." },
			{ text = "😔 Disaster", effects = { Happiness = -10 }, resultText = "Everything went wrong. At least it's over." },
		},
	},
	
	{
		id = "teen_summer_romance",
		minAge = 15, maxAge = 18,
		weight = 20, cooldown = 3,
		emoji = "☀️", title = "Summer Romance",
		category = "romance",
		getDynamicData = function() return { summerLove = randomName() } end,
		text = "You met %summerLove% this summer. There's something special here.",
		choices = {
			{ text = "❤️ Fall in love", effects = { Happiness = 12 }, resultText = "The perfect summer romance. You'll never forget them." },
			{ text = "🤝 Stay friends", effects = { Happiness = 6 }, resultText = "A great summer friendship that might become more." },
			{ text = "💔 Long distance is hard", effects = { Happiness = -5 }, resultText = "You tried but distance won." },
		},
	},
	
	{
		id = "teen_mentor_discovered",
		minAge = 14, maxAge = 18,
		weight = 15, oneTime = true,
		emoji = "🧙", title = "Finding a Mentor",
		category = "school",
		getDynamicData = function() return { mentorName = randomName() } end,
		text = "Your teacher %mentorName% sees potential in you and offers to mentor you.",
		choices = {
			{ text = "🙏 Accept gratefully", effects = { Smarts = 8, Happiness = 8 }, resultText = "This mentorship changes your life trajectory.", setFlags = {"has_mentor", "teaching_interest"} },
			{ text = "🤷 I don't need help", effects = { Smarts = 2 }, resultText = "You missed an opportunity." },
		},
	},
	
	{
		id = "teen_startup_idea",
		minAge = 15, maxAge = 18,
		weight = 15, oneTime = true,
		emoji = "💡", title = "Startup Idea",
		category = "social",
		requires = function(state) return state.Flags and state.Flags.computer_interest end,
		text = "You had an amazing app idea! Could this be the next big thing?",
		choices = {
			{ text = "🚀 Start building!", effects = { Smarts = 8, Happiness = 8 }, resultText = "You started working on your app!", setFlag = "teen_entrepreneur" },
			{ text = "📝 Write it down for later", effects = { Smarts = 4 }, resultText = "Saved for when you have more time." },
			{ text = "🤷 Someone's probably done it", effects = { Happiness = -2 }, resultText = "Self-doubt killed the dream." },
		},
	},
	
	{
		id = "teen_car_accident",
		minAge = 16, maxAge = 18,
		weight = 10, oneTime = true,
		emoji = "🚗", title = "Car Accident",
		category = "health",
		requires = function(state) return state.Flags and state.Flags.has_license end,
		text = "You were in a car accident! It wasn't serious but very scary.",
		choices = {
			{ text = "🏥 Get checked out", effects = { Health = 3, Money = -200 }, resultText = "Doctor said you're fine. Relief." },
			{ text = "💪 I'm fine", effects = { Health = -5 }, resultText = "You should have seen a doctor." },
			{ text = "😰 Scared to drive", effects = { Happiness = -5, Smarts = 2 }, resultText = "It took a while to get behind the wheel again." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════════════════
	-- ███████████████████████████████████████████████████████████████████████████
	-- MASSIVE EXPANSION PART 3: DEEP HACKER CAREER PATH
	-- ███████████████████████████████████████████████████████████████████████████
	-- ═══════════════════════════════════════════════════════════════════════════
	
	{
		id = "hacker_computer_build",
		minAge = 12, maxAge = 18,
		weight = 20, oneTime = true,
		emoji = "🖥️", title = "Building Your Rig",
		category = "social",
		requires = function(state) return state.Flags and state.Flags.computer_interest end,
		text = "You saved up enough to build your own custom computer!",
		choices = {
			{ text = "🖥️ Build a beast!", effects = { Smarts = 6, Happiness = 8, Money = -500 }, resultText = "You built an amazing machine from scratch!", setFlag = "custom_pc" },
			{ text = "💻 Upgrade what you have", effects = { Smarts = 4, Happiness = 4, Money = -200 }, resultText = "Upgrades made a big difference!" },
		},
	},
	
	{
		id = "hacker_ctf_competition",
		minAge = 14, maxAge = 30,
		weight = 15, cooldown = 2,
		emoji = "🏆", title = "CTF Competition",
		category = "social",
		requires = function(state) return state.Flags and state.Flags.hacker_skills end,
		getDynamicData = function()
			local events = {"DEF CON CTF", "PicoCTF", "Google CTF", "HackTheBox CTF"}
			return { event = events[math.random(#events)] }
		end,
		text = "There's a Capture The Flag hacking competition: %event%!",
		choices = {
			{ text = "🏆 Compete to win!", effects = { Smarts = 8, Happiness = 10, Money = 1000 }, resultText = "You placed in the top rankings! Scouts noticed.", setFlag = "ctf_champion" },
			{ text = "📚 Participate to learn", effects = { Smarts = 6, Happiness = 5 }, resultText = "You learned so much! Great experience." },
		},
	},
	
	{
		id = "hacker_found_backdoor",
		minAge = 16, maxAge = 35,
		weight = 12, oneTime = true,
		emoji = "🚪", title = "Discovered a Backdoor",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.hacker_skills and not f.backdoor_found
		end,
		text = "While exploring a major company's systems, you found a pre-existing backdoor. Someone else was here first.",
		choices = {
			{ text = "🔍 Investigate further", effects = { Smarts = 8 }, resultText = "You traced it to a nation-state actor. Heavy stuff.", setFlag = "backdoor_found" },
			{ text = "📧 Report to the company", effects = { Smarts = 5, Money = 5000, Happiness = 5 }, resultText = "They paid you well for the discovery.", setFlags = {"backdoor_found", "white_hat"} },
			{ text = "🤫 Use it yourself", effects = { Smarts = 5, Money = 2000 }, resultText = "You now have access whenever you want.", setFlags = {"backdoor_found", "black_hat"} },
		},
	},
	
	{
		id = "hacker_cryptocurrency",
		minAge = 18, maxAge = 45,
		weight = 12, cooldown = 3,
		emoji = "₿", title = "Crypto Opportunity",
		category = "money",
		requires = function(state) return state.Flags and state.Flags.computer_interest end,
		text = "You understand cryptocurrency better than most. Investment opportunity?",
		choices = {
			{ text = "💰 Invest heavily", effects = { Money = 10000, Smarts = 3 }, resultText = "Your timing was perfect! Huge gains!" },
			{ text = "📊 Mine some", effects = { Money = 2000, Smarts = 5 }, resultText = "Mining brought steady income.", setFlag = "crypto_miner" },
			{ text = "🔧 Build trading bots", effects = { Smarts = 8, Money = 5000 }, resultText = "Your algorithms made money while you slept!", setFlag = "algo_trader" },
		},
	},
	
	{
		id = "hacker_social_engineering",
		minAge = 16, maxAge = 40,
		weight = 12, oneTime = true,
		emoji = "🎭", title = "Social Engineering",
		category = "crime",
		requires = function(state) return state.Flags and state.Flags.hacker_skills end,
		text = "Sometimes hacking people is easier than hacking computers. Try social engineering?",
		choices = {
			{ text = "📞 Phishing call", effects = { Smarts = 5, Money = 1000 }, resultText = "You talked your way into system access. Scary effective.", setFlag = "social_engineer" },
			{ text = "📧 Phishing email", effects = { Smarts = 4, Money = 500 }, resultText = "So many people clicked your fake link." },
			{ text = "🙅 That's manipulation", effects = { Smarts = 2, Happiness = 3 }, resultText = "You prefer technical challenges." },
		},
	},
	
	{
		id = "hacker_virus_creation",
		minAge = 16, maxAge = 40,
		weight = 8, oneTime = true,
		emoji = "🦠", title = "Create Malware?",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.black_hat and f.hacker_skills
		end,
		text = "You could create your own virus/malware. The power is tempting.",
		choices = {
			{ text = "🦠 Create it", effects = { Smarts = 8, Happiness = -5 }, resultText = "You created something dangerous. It spread.", setFlag = "malware_author" },
			{ text = "🔬 For research only", effects = { Smarts = 10 }, resultText = "You studied malware but never released it. Ethical.", setFlag = "malware_researcher" },
			{ text = "🚫 That's too far", effects = { Happiness = 5, Smarts = 3 }, resultText = "Some lines shouldn't be crossed." },
		},
	},
	
	{
		id = "hacker_darknet_market",
		minAge = 18, maxAge = 45,
		weight = 8, oneTime = true,
		emoji = "🌑", title = "Darknet Marketplace",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.black_hat and (f.hacker_group or f.elite_hacker)
		end,
		text = "You could set up a marketplace on the darknet. Illegal but profitable.",
		choices = {
			{ text = "💻 Create a marketplace", effects = { Money = 100000, Smarts = 5, Happiness = -10 }, resultText = "You became a darknet kingpin. The feds are watching.", setFlag = "darknet_operator" },
			{ text = "🤝 Just be a vendor", effects = { Money = 20000, Smarts = 3 }, resultText = "You sold data on existing markets." },
			{ text = "🚫 Too risky", effects = { Smarts = 3, Happiness = 5 }, resultText = "Smart call. That life ends badly." },
		},
	},
	
	{
		id = "hacker_zero_day",
		minAge = 20, maxAge = 50,
		weight = 8, cooldown = 5,
		emoji = "⚡", title = "Zero-Day Discovery",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.elite_hacker or f.hacker_career
		end,
		getDynamicData = function()
			local targets = {"major OS", "browser", "IoT device", "enterprise software", "cloud platform"}
			return { target = targets[math.random(#targets)] }
		end,
		text = "You discovered a zero-day vulnerability in a %target%!",
		choices = {
			{ text = "💵 Sell to highest bidder", effects = { Money = 200000, Smarts = 5 }, resultText = "Sold to... you don't want to know who.", setFlag = "zero_day_seller" },
			{ text = "📧 Responsible disclosure", effects = { Money = 50000, Happiness = 10, Smarts = 5 }, resultText = "The vendor paid the bug bounty and thanked you publicly.", setFlag = "zero_day_hunter" },
			{ text = "🏛️ Sell to government", effects = { Money = 100000, Smarts = 3 }, resultText = "The NSA is your new client." },
		},
	},
	
	{
		id = "hacker_arrested_risk",
		minAge = 18, maxAge = 50,
		weight = 10, cooldown = 5,
		emoji = "🚔", title = "Close Call",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.black_hat and (f.hacker_group or f.hacked_government)
		end,
		text = "FBI agents showed up at your door asking questions. They're getting close.",
		choices = {
			{ text = "😇 Play innocent", effects = { Smarts = 5, Happiness = -10 }, resultText = "They bought it... for now. Time to cover tracks." },
			{ text = "🏃 Go dark immediately", effects = { Happiness = -15, Smarts = 8 }, resultText = "You destroyed evidence and went underground.", setFlag = "underground" },
			{ text = "⚖️ Lawyer up", effects = { Money = -10000, Smarts = 5 }, resultText = "Expensive but necessary protection." },
		},
	},
	
	{
		id = "hacker_job_nsa",
		minAge = 22, maxAge = 45,
		weight = 8, oneTime = true,
		emoji = "🏛️", title = "Government Recruiting",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return (f.elite_hacker or f.ctf_champion) and not f.black_hat
		end,
		text = "A three-letter agency wants to recruit you. NSA, CIA, they're all interested.",
		choices = {
			{ text = "🏛️ Join the government", effects = { Money = 5000, Smarts = 8, Happiness = 5 }, resultText = "You now work for the government. Clearance level: Top Secret.", setFlag = "government_hacker" },
			{ text = "💼 Stay private sector", effects = { Money = 8000, Happiness = 3 }, resultText = "More money in corporations anyway." },
			{ text = "🐺 Stay independent", effects = { Happiness = 5, Smarts = 3 }, resultText = "You prefer freedom." },
		},
	},
	
	{
		id = "hacker_silicon_valley",
		minAge = 22, maxAge = 40,
		weight = 10, oneTime = true,
		emoji = "🌉", title = "Silicon Valley Calling",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return (f.programmer or f.hacker_career) and not f.silicon_valley
		end,
		getDynamicData = function()
			local companies = {"Google", "Apple", "Meta", "Amazon", "Microsoft", "Netflix", "Stripe", "Cloudflare"}
			return { company = companies[math.random(#companies)] }
		end,
		text = "%company% is recruiting you! The offer is incredible.",
		choices = {
			{ text = "💼 Take the job!", effects = { Money = 15000, Happiness = 10, Smarts = 5 }, resultText = "You're now at a top tech company!", setFlag = "silicon_valley" },
			{ text = "🤔 Negotiate harder", effects = { Money = 25000, Happiness = 8, Smarts = 5 }, resultText = "They really wanted you. Stock options included!", setFlag = "silicon_valley" },
			{ text = "🚀 Start my own thing", effects = { Happiness = 5, Smarts = 3 }, resultText = "You'd rather be the founder than the employee." },
		},
	},
	
	{
		id = "hacker_security_breach_response",
		minAge = 24, maxAge = 50,
		weight = 10, cooldown = 3,
		emoji = "🚨", title = "Security Incident Response",
		category = "work",
		requires = function(state) return state.Flags and state.Flags.hacker_career end,
		text = "A major breach just hit your company! All hands on deck!",
		choices = {
			{ text = "💻 Lead the response", effects = { Smarts = 8, Happiness = 5, Money = 5000 }, resultText = "You contained the breach. Promoted for your leadership.", setFlag = "incident_responder" },
			{ text = "🔍 Investigate quietly", effects = { Smarts = 6, Happiness = 3 }, resultText = "You found evidence others missed." },
			{ text = "📢 Go public", effects = { Smarts = 3, Happiness = -5 }, resultText = "Whistleblowing made you unpopular but it was right." },
		},
	},
	
	{
		id = "hacker_conference_speaker",
		minAge = 25, maxAge = 55,
		weight = 8, cooldown = 3,
		emoji = "🎤", title = "Conference Speaker",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.elite_hacker or f.hacker_career
		end,
		getDynamicData = function()
			local conferences = {"Black Hat", "DEF CON", "RSA Conference", "CCC", "ShmooCon"}
			return { conference = conferences[math.random(#conferences)] }
		end,
		text = "You've been invited to speak at %conference%!",
		choices = {
			{ text = "🎤 Prepare an epic talk", effects = { Smarts = 8, Happiness = 10, Money = 3000 }, resultText = "Standing ovation! You're a legend now.", setFlag = "conference_speaker" },
			{ text = "😰 Too scary", effects = { Happiness = -5 }, resultText = "You passed. Maybe next time." },
		},
	},
	
	{
		id = "hacker_open_source",
		minAge = 18, maxAge = 50,
		weight = 12, cooldown = 3,
		emoji = "🌐", title = "Open Source Project",
		category = "work",
		requires = function(state) return state.Flags and (state.Flags.programmer or state.Flags.hacker_career) end,
		text = "You created an open source security tool. It's gaining traction!",
		choices = {
			{ text = "🌐 Keep it free", effects = { Happiness = 10, Smarts = 5 }, resultText = "Thousands of people use your tool! Community hero.", setFlag = "open_source_creator" },
			{ text = "💰 Monetize it", effects = { Money = 20000, Happiness = 5, Smarts = 3 }, resultText = "Enterprise version brings in money." },
			{ text = "🏢 Sell to a company", effects = { Money = 100000, Happiness = -5 }, resultText = "They bought it but you lost control." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════════════════
	-- ███████████████████████████████████████████████████████████████████████████
	-- MASSIVE EXPANSION PART 4: DEEP TEACHER CAREER PATH
	-- ███████████████████████████████████████████████████████████████████████████
	-- ═══════════════════════════════════════════════════════════════════════════
	
	{
		id = "teacher_education_degree",
		minAge = 18, maxAge = 30,
		weight = 20, oneTime = true,
		emoji = "🎓", title = "Education Degree",
		category = "school",
		requires = function(state)
			local f = state.Flags or {}
			return f.teaching_interest and f.college_student and not f.education_degree
		end,
		getDynamicData = function() return { university = randomUniversity() } end,
		text = "You're studying Education at %university%! This is your calling.",
		choices = {
			{ text = "📚 Double major", effects = { Smarts = 10, Happiness = 5 }, resultText = "You added a content area. More versatile!", setFlag = "education_degree" },
			{ text = "🎓 Focus on pedagogy", effects = { Smarts = 8, Happiness = 6 }, resultText = "You became an expert in how people learn.", setFlag = "education_degree" },
		},
	},
	
	{
		id = "teacher_student_teaching",
		minAge = 21, maxAge = 30,
		weight = 25, oneTime = true,
		emoji = "👨‍🏫", title = "Student Teaching",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.education_degree and not f.student_teaching_done
		end,
		getDynamicData = function() return { school = randomSchool(), mentor = randomName() } end,
		text = "Time for student teaching at %school% under %mentor%!",
		choices = {
			{ text = "💪 Give it your all", effects = { Smarts = 6, Happiness = 8 }, resultText = "Your mentor praised your natural ability!", setFlag = "student_teaching_done" },
			{ text = "📚 Learn by observing", effects = { Smarts = 8, Happiness = 4 }, resultText = "You learned so much watching an expert.", setFlag = "student_teaching_done" },
		},
	},
	
	{
		id = "teacher_first_classroom",
		minAge = 22, maxAge = 35,
		weight = 30, oneTime = true, milestone = true,
		emoji = "🏫", title = "Your Own Classroom!",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.student_teaching_done and not f.teacher
		end,
		getDynamicData = function() return { school = randomSchool() } end,
		text = "You got hired at %school%! You have your own classroom!",
		choices = {
			{ text = "😍 Best day ever!", effects = { Happiness = 15, Smarts = 5, Money = 2000 }, resultText = "You're officially a teacher!", setFlag = "teacher",
			  setJob = { id = "teacher", title = "Teacher", company = "%school%", salary = 45000, storyFlag = "teacher" } },
		},
	},
	
	{
		id = "teacher_first_year_challenge",
		minAge = 22, maxAge = 40,
		weight = 25, oneTime = true,
		emoji = "😰", title = "First Year Struggles",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.teacher and not f.survived_first_year
		end,
		text = "First year teaching is HARD. You're exhausted and questioning everything.",
		choices = {
			{ text = "💪 Push through", effects = { Smarts = 5, Happiness = -5 }, resultText = "You made it. Year one done. It gets easier.", setFlag = "survived_first_year" },
			{ text = "🤝 Seek mentorship", effects = { Smarts = 8, Happiness = 3 }, resultText = "Veteran teachers helped you survive.", setFlags = {"survived_first_year", "has_mentor"} },
			{ text = "😭 Consider quitting", effects = { Happiness = -10 }, resultText = "Many new teachers quit. You're not alone in struggling." },
		},
	},
	
	{
		id = "teacher_difficult_student",
		minAge = 23, maxAge = 65,
		weight = 20, cooldown = 2,
		emoji = "😤", title = "Difficult Student",
		category = "work",
		requires = function(state) return state.Flags and state.Flags.teacher end,
		getDynamicData = function() return { studentName = randomName() } end,
		text = "%studentName% is disrupting your class constantly. Nothing seems to work.",
		choices = {
			{ text = "💗 Find their story", effects = { Smarts = 5, Happiness = 8 }, resultText = "You discovered why they act out. Breakthrough achieved!" },
			{ text = "📞 Contact parents", effects = { Smarts = 3, Happiness = 3 }, resultText = "Parent meeting helped address the issue." },
			{ text = "📝 Document and escalate", effects = { Smarts = 4 }, resultText = "Administration got involved. Problem handled." },
		},
	},
	
	{
		id = "teacher_breakthrough_moment",
		minAge = 23, maxAge = 65,
		weight = 15, cooldown = 3,
		emoji = "💡", title = "Teaching Breakthrough",
		category = "work",
		requires = function(state) return state.Flags and state.Flags.teacher end,
		getDynamicData = function() return { studentName = randomName() } end,
		text = "%studentName% finally understood something they've struggled with for months! Their face lit up!",
		choices = {
			{ text = "🎉 This is why I teach!", effects = { Happiness = 15, Smarts = 3 }, resultText = "That moment made everything worth it." },
		},
	},
	
	{
		id = "teacher_extra_curricular",
		minAge = 23, maxAge = 55,
		weight = 15, cooldown = 3,
		emoji = "🎯", title = "Run an Activity",
		category = "work",
		requires = function(state) return state.Flags and state.Flags.teacher end,
		getDynamicData = function()
			local activities = {"drama club", "debate team", "robotics club", "student newspaper", "chess club", "tutoring program"}
			return { activity = activities[math.random(#activities)] }
		end,
		text = "The school needs someone to run the %activity%. Extra work but extra impact.",
		choices = {
			{ text = "✅ I'll do it!", effects = { Happiness = 8, Money = 2000, Smarts = 3 }, resultText = "Students love you even more now!", setFlag = "club_advisor" },
			{ text = "⏰ No time", effects = { Happiness = 2 }, resultText = "You need to protect your work-life balance." },
		},
	},
	
	{
		id = "teacher_grad_school",
		minAge = 25, maxAge = 50,
		weight = 12, oneTime = true,
		emoji = "🎓", title = "Graduate School",
		category = "school",
		requires = function(state)
			local f = state.Flags or {}
			return f.teacher and not f.masters_degree
		end,
		getDynamicData = function() return { university = randomUniversity() } end,
		text = "%university% accepted you into their Master's program in Education!",
		choices = {
			{ text = "📚 Start the program", effects = { Smarts = 12, Happiness = 5, Money = -20000 }, resultText = "Grad school while teaching is hard but you're growing.", setFlag = "masters_degree" },
			{ text = "⏰ Maybe later", effects = {}, resultText = "The timing isn't right." },
		},
	},
	
	{
		id = "teacher_national_board",
		minAge = 28, maxAge = 55,
		weight = 10, oneTime = true,
		emoji = "🏆", title = "National Board Certification",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.teacher and f.masters_degree and not f.national_board
		end,
		text = "You could pursue National Board Certification - the highest credential in teaching.",
		choices = {
			{ text = "📝 Go for it!", effects = { Smarts = 10, Happiness = 10, Money = 5000 }, resultText = "You're National Board Certified! Elite status achieved!", setFlag = "national_board" },
			{ text = "😰 Too much work", effects = {}, resultText = "Maybe when you have more time." },
		},
	},
	
	{
		id = "teacher_department_head_offer",
		minAge = 30, maxAge = 55,
		weight = 12, oneTime = true,
		emoji = "👔", title = "Department Head Opening",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.teacher and f.survived_first_year and not f.department_head
		end,
		text = "There's an opening for department head. More responsibility, more pay.",
		choices = {
			{ text = "👔 Apply!", effects = { Money = 5000, Happiness = 8, Smarts = 5 }, resultText = "You're now leading your department!", setFlag = "department_head" },
			{ text = "📚 Stay in classroom", effects = { Happiness = 3 }, resultText = "You prefer direct student impact." },
		},
	},
	
	{
		id = "teacher_admin_track",
		minAge = 35, maxAge = 55,
		weight = 10, oneTime = true,
		emoji = "🏫", title = "Administration Path",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.department_head and f.masters_degree and not f.admin_certificate
		end,
		text = "People keep suggesting you'd make a great principal. Get admin certified?",
		choices = {
			{ text = "📚 Get the certificate", effects = { Smarts = 8, Money = -10000 }, resultText = "You're now qualified for administration roles!", setFlag = "admin_certificate" },
			{ text = "🙅 Teaching is where I belong", effects = { Happiness = 5 }, resultText = "Not everyone should be admin. Teachers matter." },
		},
	},
	
	{
		id = "teacher_assistant_principal",
		minAge = 35, maxAge = 58,
		weight = 10, oneTime = true,
		emoji = "📋", title = "Assistant Principal",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.admin_certificate and not f.assistant_principal
		end,
		getDynamicData = function() return { school = randomSchool() } end,
		text = "%school% is hiring an assistant principal and you're a top candidate!",
		choices = {
			{ text = "📋 Take the position", effects = { Money = 10000, Happiness = 8, Smarts = 5 }, resultText = "You're now in school leadership!", setFlag = "assistant_principal", clearFlag = "teacher" },
			{ text = "📚 Stay a teacher", effects = { Happiness = 5 }, resultText = "Administration isn't for everyone." },
		},
	},
	
	{
		id = "teacher_principal_promotion",
		minAge = 38, maxAge = 62,
		weight = 8, oneTime = true, milestone = true,
		emoji = "🎓", title = "Principal!",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.assistant_principal and not f.principal
		end,
		getDynamicData = function() return { school = randomSchool() } end,
		text = "The principal position at %school% just opened up!",
		choices = {
			{ text = "🎓 This is my moment!", effects = { Money = 15000, Happiness = 15, Smarts = 5 }, resultText = "You're the principal! Your school, your vision.", setFlag = "principal",
			  setJob = { id = "principal", title = "School Principal", company = "%school%", salary = 95000, storyFlag = "principal" } },
		},
	},
	
	{
		id = "teacher_superintendent",
		minAge = 45, maxAge = 65,
		weight = 5, oneTime = true, milestone = true,
		emoji = "🏛️", title = "Superintendent",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.principal and (state.Age or 0) >= 45 and not f.superintendent
		end,
		text = "The district is looking for a new superintendent. Your name keeps coming up.",
		choices = {
			{ text = "🏛️ Lead the district!", effects = { Money = 30000, Happiness = 15, Smarts = 8 }, resultText = "You're now superintendent of the entire district!", setFlag = "superintendent",
			  setJob = { id = "superintendent", title = "School Superintendent", company = "School District", salary = 175000, storyFlag = "superintendent" } },
			{ text = "🏫 Stay at my school", effects = { Happiness = 5 }, resultText = "You love your school community too much to leave." },
		},
	},
	
	{
		id = "teacher_union_leadership",
		minAge = 28, maxAge = 55,
		weight = 10, oneTime = true,
		emoji = "✊", title = "Union Leadership",
		category = "work",
		requires = function(state) return state.Flags and state.Flags.teacher end,
		text = "The teachers' union is looking for new leadership. Advocate for your colleagues?",
		choices = {
			{ text = "✊ Run for union president", effects = { Happiness = 8, Smarts = 5 }, resultText = "You're now fighting for teachers' rights!", setFlag = "union_leader" },
			{ text = "🤝 Committee member", effects = { Happiness = 4, Smarts = 3 }, resultText = "You contribute without the spotlight." },
			{ text = "🙅 Stay out of politics", effects = {}, resultText = "You focus on your students instead." },
		},
	},
	
	{
		id = "teacher_scholarship_student",
		minAge = 25, maxAge = 55,
		weight = 12, cooldown = 3,
		emoji = "🌟", title = "Star Student",
		category = "work",
		requires = function(state) return state.Flags and state.Flags.teacher end,
		getDynamicData = function() return { studentName = randomName() } end,
		text = "%studentName% got a full scholarship thanks to your recommendation and guidance!",
		choices = {
			{ text = "🎉 This is my legacy!", effects = { Happiness = 15 }, resultText = "Changing lives - that's what it's all about." },
		},
	},
	
	{
		id = "teacher_former_student_success",
		minAge = 30, maxAge = 65,
		weight = 10, cooldown = 5,
		emoji = "🎓", title = "Former Student Success",
		category = "social",
		requires = function(state) return state.Flags and state.Flags.teacher end,
		getDynamicData = function() return { studentName = randomName() } end,
		text = "You ran into your former student %studentName%. They're now a successful professional and thanked you for believing in them.",
		choices = {
			{ text = "🥹 This means everything", effects = { Happiness = 20 }, resultText = "The impact you've made is immeasurable." },
		},
	},
	
	{
		id = "teacher_write_curriculum",
		minAge = 30, maxAge = 60,
		weight = 10, oneTime = true,
		emoji = "📖", title = "Write Curriculum",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.teacher and (f.department_head or f.national_board)
		end,
		text = "The district wants you to write new curriculum for your subject area.",
		choices = {
			{ text = "📖 Create something amazing", effects = { Smarts = 10, Money = 5000, Happiness = 8 }, resultText = "Your curriculum is being used district-wide!", setFlag = "curriculum_author" },
			{ text = "⏰ No time", effects = {}, resultText = "You passed on the opportunity." },
		},
	},
	
	{
		id = "teacher_conference_presenter",
		minAge = 28, maxAge = 60,
		weight = 10, cooldown = 3,
		emoji = "🎤", title = "Present at Conference",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.teacher and (f.teacher_award or f.national_board)
		end,
		getDynamicData = function()
			local conferences = {"National Education Conference", "State Teachers Convention", "Subject Area Summit"}
			return { conference = conferences[math.random(#conferences)] }
		end,
		text = "You've been invited to present at the %conference%!",
		choices = {
			{ text = "🎤 Share your expertise", effects = { Smarts = 6, Happiness = 10, Money = 1000 }, resultText = "Your session was a hit! Educators were inspired." },
			{ text = "😰 Public speaking is scary", effects = {}, resultText = "Maybe next time." },
		},
	},

	-- ═══════════════════════════════════════════════════════════════════════════
	-- ███████████████████████████████████████████████████████████████████████████
	-- MASSIVE EXPANSION PART 5: DEEP CRIMINAL CAREER PATH
	-- ███████████████████████████████████████████████████████████████████████████
	-- ═══════════════════════════════════════════════════════════════════════════
	
	{
		id = "crime_first_fight",
		minAge = 12, maxAge = 20,
		weight = 20, oneTime = true,
		emoji = "👊", title = "First Fight",
		category = "social",
		getDynamicData = function() return { enemyName = randomName() } end,
		text = "%enemyName% pushed you too far. Are you going to do something about it?",
		choices = {
			{ text = "👊 Fight them", effects = { Health = -5, Happiness = 5 }, resultText = "You got in your first real fight. Won some respect.", setFlag = "scrapper" },
			{ text = "🗣️ Use words", effects = { Smarts = 4, Happiness = 3 }, resultText = "You talked your way out of it. Smart." },
			{ text = "🏃 Walk away", effects = { Happiness = -3 }, resultText = "Live to fight another day." },
		},
	},
	
	{
		id = "crime_steal_from_store",
		minAge = 12, maxAge = 25,
		weight = 15, cooldown = 3,
		emoji = "🛒", title = "Five-Finger Discount",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.criminal_tendencies or f.scrapper
		end,
		getDynamicData = function()
			local items = {"candy", "video game", "electronics", "clothes", "makeup"}
			return { item = items[math.random(#items)] }
		end,
		text = "That %item% would be so easy to steal. Nobody's watching...",
		choices = {
			{ text = "🖐️ Take it", effects = { Happiness = 5 }, resultText = "You got away with it. The rush is real.", setFlag = "shoplifter" },
			{ text = "🚶 Walk away", effects = { Smarts = 3 }, resultText = "Not worth the risk." },
			{ text = "🚨 Get caught!", effects = { Happiness = -10, Money = -100 }, resultText = "Security grabbed you. Your parents are so disappointed." },
		},
	},
	
	{
		id = "crime_vandalism",
		minAge = 13, maxAge = 22,
		weight = 15, oneTime = true,
		emoji = "🖌️", title = "Vandalism",
		category = "crime",
		requires = function(state) return state.Flags and state.Flags.criminal_tendencies end,
		text = "Your friends want to tag some walls. Join them?",
		choices = {
			{ text = "🖌️ Leave your mark", effects = { Happiness = 5 }, resultText = "Your tag is everywhere now!", setFlag = "vandal" },
			{ text = "🙅 Nah, too risky", effects = { Smarts = 3 }, resultText = "You passed. Smart choice." },
		},
	},
	
	{
		id = "crime_sell_drugs_start",
		minAge = 16, maxAge = 30,
		weight = 12, oneTime = true,
		emoji = "💊", title = "Dealing Opportunity",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return (f.criminal_tendencies or f.gang_prospect) and not f.drug_dealer
		end,
		getDynamicData = function() return { contactName = randomName() } end,
		text = "%contactName% says you could make good money selling. Easy work.",
		choices = {
			{ text = "💊 Start dealing", effects = { Money = 2000, Happiness = 3 }, resultText = "The money flows in. But so does the risk.", setFlag = "drug_dealer" },
			{ text = "🚫 Not for me", effects = { Smarts = 5 }, resultText = "You don't want that life." },
		},
	},
	
	{
		id = "crime_street_race",
		minAge = 17, maxAge = 35,
		weight = 12, cooldown = 3,
		emoji = "🏎️", title = "Street Racing",
		category = "crime",
		requires = function(state) return state.Flags and state.Flags.has_license end,
		getDynamicData = function() return { location = "downtown strip", prize = math.random(500, 2000) } end,
		text = "There's a street race at the %location% tonight. Prize is $%prize%.",
		choices = {
			{ text = "🏎️ Race!", effects = { Happiness = 8, Money = 1000 }, resultText = "You won! Cops almost caught you though.", setFlag = "street_racer", minigame = "getaway" },
			{ text = "👀 Watch", effects = { Happiness = 3 }, resultText = "You enjoyed the show safely." },
			{ text = "🚫 Too dangerous", effects = { Smarts = 3 }, resultText = "Someone got hurt that night. Good call." },
		},
	},
	
	{
		id = "crime_burglary_first",
		minAge = 18, maxAge = 40,
		weight = 10, oneTime = true,
		emoji = "🏠", title = "First Burglary",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.car_thief or f.drug_dealer
		end,
		text = "Someone's vacation home is empty for weeks. Lot of valuables inside.",
		choices = {
			{ text = "🏠 Break in", effects = { Money = 5000, Happiness = 5 }, resultText = "You cleaned the place out. Big haul.", setFlag = "burglar", minigame = "heist" },
			{ text = "🚫 Too far", effects = { Smarts = 3 }, resultText = "That's someone's home. You passed." },
		},
	},
	
	{
		id = "crime_fence_connection",
		minAge = 18, maxAge = 50,
		weight = 12, oneTime = true,
		emoji = "🤝", title = "Meet a Fence",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.burglar or f.car_thief
		end,
		getDynamicData = function() return { fenceName = randomName() } end,
		text = "You met %fenceName%, a fence who buys stolen goods. Better prices than pawning.",
		choices = {
			{ text = "🤝 Make the connection", effects = { Money = 2000, Smarts = 3 }, resultText = "Now you have a reliable outlet for your goods.", setFlag = "has_fence" },
			{ text = "🚫 Don't trust them", effects = {}, resultText = "Could be a cop. Better safe." },
		},
	},
	
	{
		id = "crime_gang_war_battle",
		minAge = 18, maxAge = 45,
		weight = 12, cooldown = 2,
		emoji = "⚔️", title = "Gang Battle",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.gang_member and f.initiated
		end,
		getDynamicData = function() return { rival = "The Southside Crew" } end,
		text = "%rival% is making moves on your territory. It's war.",
		choices = {
			{ text = "⚔️ Lead the charge", effects = { Health = -15, Happiness = 8, Money = 5000 }, resultText = "Victory. But at what cost?", setFlag = "war_veteran", minigame = "getaway" },
			{ text = "🛡️ Defend only", effects = { Health = -5, Happiness = 3 }, resultText = "You held the line but didn't expand." },
			{ text = "🕊️ Negotiate peace", effects = { Smarts = 8, Happiness = 3 }, resultText = "You talked it out. Bloodshed avoided." },
		},
	},
	
	{
		id = "crime_police_informant",
		minAge = 20, maxAge = 50,
		weight = 10, oneTime = true,
		emoji = "🐀", title = "Become an Informant?",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.gang_member and f.arrested
		end,
		getDynamicData = function() return { detectiveName = randomName() } end,
		text = "Detective %detectiveName% offers a deal: information for immunity.",
		choices = {
			{ text = "🐀 Become a snitch", effects = { Happiness = -10, Smarts = 3 }, resultText = "You're informing on your crew. Dangerous game.", setFlag = "informant", clearFlag = "snitch" },
			{ text = "🤐 Stay loyal", effects = { Happiness = 5 }, resultText = "You kept your mouth shut. Respect." },
		},
	},
	
	{
		id = "crime_witness_murder",
		minAge = 18, maxAge = 55,
		weight = 8, oneTime = true,
		emoji = "👀", title = "Witness to Murder",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.gang_member or f.crime_boss
		end,
		getDynamicData = function() return { victimName = randomName() } end,
		text = "You witnessed the gang eliminate %victimName%. You know too much.",
		choices = {
			{ text = "🤐 Never speak of it", effects = { Happiness = -15, Smarts = 3 }, resultText = "Some things you take to the grave.", setFlag = "knows_secrets" },
			{ text = "🏃 Get out", effects = { Happiness = -10, Health = -5 }, resultText = "You tried to leave the life. They didn't make it easy." },
		},
	},
	
	{
		id = "crime_corrupt_cop",
		minAge = 22, maxAge = 55,
		weight = 10, oneTime = true,
		emoji = "🚔", title = "Crooked Cop",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.gang_captain or f.underboss or f.crime_boss
		end,
		getDynamicData = function() return { copName = randomName() } end,
		text = "Officer %copName% is on the take. Want police protection?",
		choices = {
			{ text = "💵 Pay them off", effects = { Money = -5000, Happiness = 5 }, resultText = "Now you have a cop in your pocket.", setFlag = "has_dirty_cop" },
			{ text = "🚫 Don't trust cops", effects = { Smarts = 3 }, resultText = "Could be a setup. You passed." },
		},
	},
	
	{
		id = "crime_family_threat",
		minAge = 25, maxAge = 60,
		weight = 8, oneTime = true,
		emoji = "👨‍👩‍👧", title = "Family Threatened",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.gang_captain or f.underboss
		end,
		text = "Rivals threatened your family. This is getting serious.",
		choices = {
			{ text = "🏠 Hide them", effects = { Money = -10000, Happiness = -10 }, resultText = "You moved your family somewhere safe." },
			{ text = "💀 Send a message", effects = { Happiness = -5, Health = -5 }, resultText = "They won't threaten your family again.", setFlag = "made_example" },
			{ text = "🏃 Leave the life", effects = { Happiness = 10, Money = -50000 }, resultText = "You tried to go straight. For your family.", clearFlags = {"gang_member", "gang_captain"} },
		},
	},
	
	{
		id = "crime_rico_investigation",
		minAge = 28, maxAge = 60,
		weight = 6, oneTime = true,
		emoji = "📋", title = "RICO Investigation",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.crime_boss or f.underboss
		end,
		text = "The feds are building a RICO case against your organization.",
		choices = {
			{ text = "⚖️ Lawyer up hard", effects = { Money = -100000, Smarts = 5 }, resultText = "Best lawyers money can buy. Case might fall apart." },
			{ text = "🏃 Flee the country", effects = { Money = -200000, Happiness = -15 }, resultText = "You're now living abroad under a new identity.", setFlag = "in_exile", clearFlags = {"crime_boss", "underboss"} },
			{ text = "🤝 Make a deal", effects = { Happiness = -20, Smarts = 3 }, resultText = "You cooperated. Witness protection awaits.", setFlag = "witness_protection", clearFlag = "crime_boss" },
		},
	},
	
	{
		id = "crime_prison_life_hard",
		minAge = 18, maxAge = 70,
		weight = 15, cooldown = 2,
		emoji = "⛓️", title = "Prison Life",
		category = "prison",
		requiresFlag = "in_prison",
		text = "Life behind bars is tough. How will you handle it?",
		choices = {
			{ text = "💪 Work out constantly", effects = { Health = 8, Looks = 3 }, resultText = "You're getting massive. Nobody messes with you.", setFlag = "prison_workout" },
			{ text = "📚 Use the library", effects = { Smarts = 8, Happiness = 3 }, resultText = "You're educating yourself. Rehabilitation?", setFlag = "prison_educated" },
			{ text = "🤝 Make connections", effects = { Smarts = 4, Happiness = 3 }, resultText = "Prison networks might be useful on the outside.", setFlag = "prison_connections" },
		},
	},
	
	{
		id = "crime_prison_fight",
		minAge = 18, maxAge = 70,
		weight = 12, cooldown = 3,
		emoji = "👊", title = "Prison Fight",
		category = "prison",
		requiresFlag = "in_prison",
		getDynamicData = function() return { inmateName = randomName() } end,
		text = "%inmateName% is challenging you. Back down and you're a target forever.",
		choices = {
			{ text = "👊 Fight", effects = { Health = -10, Happiness = 5 }, resultText = "You held your own. Earned some respect.", setFlag = "prison_fighter" },
			{ text = "🗣️ Talk your way out", effects = { Smarts = 6, Happiness = 3 }, resultText = "Silver tongue saves the day." },
			{ text = "🛡️ Get protection", effects = { Money = -500 }, resultText = "You paid for protection. Safe for now." },
		},
	},
	
	{
		id = "crime_prison_gang",
		minAge = 18, maxAge = 60,
		weight = 10, oneTime = true,
		emoji = "⛓️", title = "Prison Gang",
		category = "prison",
		requiresFlag = "in_prison",
		blockIfFlag = "prison_gang",
		getDynamicData = function()
			local gangs = {"Aryan Brotherhood", "La Nuestra Familia", "Black Guerrilla Family", "The Bloods"}
			return { gang = gangs[math.random(#gangs)] }
		end,
		text = "%gang% wants you to join. Protection in exchange for loyalty.",
		choices = {
			{ text = "⛓️ Join them", effects = { Happiness = 3 }, resultText = "You're protected now. But you owe them.", setFlag = "prison_gang" },
			{ text = "🙅 Stay independent", effects = { Health = -5, Happiness = -3 }, resultText = "Dangerous choice but you kept your freedom." },
		},
	},
	
	{
		id = "crime_empire_built",
		minAge = 35, maxAge = 65,
		weight = 5, oneTime = true, milestone = true,
		emoji = "🏰", title = "Criminal Empire",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.crime_boss and f.money_launderer and not f.empire_built
		end,
		text = "You've built a criminal empire. Drugs, gambling, construction - you control it all.",
		choices = {
			{ text = "👑 Long live the king", effects = { Money = 500000, Happiness = 15 }, resultText = "You are the kingpin. Everyone answers to you.", setFlag = "empire_built" },
		},
	},
	
	{
		id = "crime_go_legit",
		minAge = 35, maxAge = 65,
		weight = 8, oneTime = true,
		emoji = "📑", title = "Go Legitimate",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return f.crime_boss and f.empire_built
		end,
		text = "You have enough money. Could you walk away and go legitimate?",
		choices = {
			{ text = "📑 Go clean", effects = { Money = -100000, Happiness = 15 }, resultText = "You're out of the game. Legal businesses only.", setFlag = "reformed_criminal", clearFlags = {"crime_boss", "gang_member"} },
			{ text = "👑 This is who I am", effects = { Happiness = 5 }, resultText = "Once a boss, always a boss." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════════════════
	-- ███████████████████████████████████████████████████████████████████████████
	-- MASSIVE EXPANSION PART 6: ADULT LIFE EVENTS (25-60)
	-- ███████████████████████████████████████████████████████████████████████████
	-- ═══════════════════════════════════════════════════════════════════════════
	
	{
		id = "adult_first_apartment",
		minAge = 18, maxAge = 30,
		weight = 25, oneTime = true,
		emoji = "🏢", title = "First Apartment",
		category = "money",
		text = "You're getting your own place! Independence at last!",
		choices = {
			{ text = "🏢 Nice place", effects = { Money = -2000, Happiness = 10 }, resultText = "Your first apartment is great!", setFlag = "has_apartment" },
			{ text = "🏚️ Cheap place", effects = { Money = -500, Happiness = 5 }, resultText = "It's not much but it's yours." },
			{ text = "👨‍👩‍👧 Stay with family", effects = { Money = 1000, Happiness = -3 }, resultText = "You saved money but sacrificed independence." },
		},
	},
	
	{
		id = "adult_career_change",
		minAge = 25, maxAge = 50,
		weight = 12, cooldown = 5,
		emoji = "🔄", title = "Career Change",
		category = "work",
		text = "You've been thinking about changing careers entirely.",
		choices = {
			{ text = "🔄 Make the switch", effects = { Happiness = 10, Money = -5000, Smarts = 5 }, resultText = "Fresh start! Scary but exciting." },
			{ text = "📚 Go back to school", effects = { Smarts = 10, Money = -20000, Happiness = 5 }, resultText = "You're investing in a new direction." },
			{ text = "🛡️ Stay safe", effects = { Happiness = -3 }, resultText = "The familiar path continues." },
		},
	},
	
	{
		id = "adult_proposal",
		minAge = 22, maxAge = 45,
		weight = 15, oneTime = true,
		emoji = "💍", title = "The Proposal",
		category = "romance",
		requires = function(state)
			local f = state.Flags or {}
			return f.in_love and not f.married and not f.engaged
		end,
		getDynamicData = function() return { partnerName = randomName() } end,
		text = "You're ready to propose to %partnerName%. This is the moment.",
		choices = {
			{ text = "💍 Pop the question!", effects = { Happiness = 20, Money = -5000 }, resultText = "They said YES!", setFlag = "engaged" },
			{ text = "⏳ Wait a bit longer", effects = { Happiness = -3 }, resultText = "The timing didn't feel right." },
		},
	},
	
	{
		id = "adult_wedding",
		minAge = 22, maxAge = 50,
		weight = 40, oneTime = true, milestone = true,
		emoji = "👰", title = "Wedding Day!",
		category = "romance",
		requires = function(state)
			local f = state.Flags or {}
			return f.engaged and not f.married
		end,
		text = "Today's the day! Your wedding is finally here!",
		choices = {
			{ text = "🎉 Best day ever!", effects = { Happiness = 25, Money = -20000 }, resultText = "You're married! Here's to forever.", setFlag = "married", clearFlag = "engaged" },
			{ text = "😰 Cold feet...", effects = { Happiness = -30 }, resultText = "You couldn't go through with it.", clearFlag = "engaged" },
		},
	},
	
	{
		id = "adult_having_baby",
		minAge = 22, maxAge = 45,
		weight = 20, oneTime = true, milestone = true,
		emoji = "👶", title = "Having a Baby!",
		category = "family",
		requires = function(state)
			local f = state.Flags or {}
			return f.married and not f.has_children
		end,
		text = "Your partner is pregnant! You're going to be a parent!",
		choices = {
			{ text = "👶 So excited!", effects = { Happiness = 20 }, resultText = "Parenthood awaits! Your life will never be the same.", setFlag = "has_children" },
			{ text = "😰 Terrified", effects = { Happiness = 5, Smarts = 3 }, resultText = "You're scared but committed.", setFlag = "has_children" },
		},
	},
	
	{
		id = "adult_baby_born",
		minAge = 22, maxAge = 48,
		weight = 50, oneTime = true, milestone = true,
		emoji = "🍼", title = "Baby Arrives!",
		category = "family",
		requires = function(state)
			local f = state.Flags or {}
			return f.has_children and not f.baby_born
		end,
		getDynamicData = function()
			local genders = {"boy", "girl"}
			local names = {"Emma", "Liam", "Olivia", "Noah", "Ava", "Ethan", "Sophia", "Mason"}
			return { gender = genders[math.random(#genders)], babyName = names[math.random(#names)] }
		end,
		text = "Your baby %babyName% is here! A beautiful %gender%!",
		choices = {
			{ text = "❤️ Pure joy", effects = { Happiness = 25 }, resultText = "Holding your child for the first time is indescribable.", setFlag = "baby_born" },
		},
	},
	
	{
		id = "adult_sleep_deprivation",
		minAge = 22, maxAge = 50,
		weight = 25, cooldown = 3,
		emoji = "😴", title = "Sleep Deprivation",
		category = "family",
		requires = function(state) return state.Flags and state.Flags.baby_born end,
		text = "The baby won't sleep. Neither will you. For months.",
		choices = {
			{ text = "💪 Power through", effects = { Health = -5, Happiness = -5 }, resultText = "Exhausted but managing. It gets better, right?" },
			{ text = "🤝 Get help", effects = { Money = -500, Happiness = 3 }, resultText = "A night nurse saved your sanity." },
		},
	},
	
	{
		id = "adult_first_house",
		minAge = 25, maxAge = 50,
		weight = 15, oneTime = true,
		emoji = "🏡", title = "Buying a House",
		category = "money",
		requires = function(state) return (state.Money or 0) >= 50000 end,
		text = "You found your dream home! The mortgage is scary but doable.",
		choices = {
			{ text = "🏡 Buy it!", effects = { Money = -50000, Happiness = 20 }, resultText = "You're a homeowner! Welcome to the American dream.", setFlag = "homeowner" },
			{ text = "🏢 Keep renting", effects = { Happiness = -3 }, resultText = "Maybe next year." },
		},
	},
	
	{
		id = "adult_job_loss",
		minAge = 25, maxAge = 60,
		weight = 10, cooldown = 5,
		emoji = "📦", title = "Laid Off",
		category = "work",
		requires = function(state) return state.Flags and (state.Flags.first_job_done or state.Flags.teacher or state.Flags.hacker_career) end,
		text = "You got laid off. The company is downsizing.",
		choices = {
			{ text = "🔍 Job hunt immediately", effects = { Smarts = 5, Happiness = -5 }, resultText = "You found something new quickly." },
			{ text = "💡 Start a business", effects = { Money = -10000, Happiness = 5, Smarts = 5 }, resultText = "Maybe this is your opportunity!", setFlag = "entrepreneur" },
			{ text = "😔 Wallow", effects = { Happiness = -15, Health = -5 }, resultText = "It took a while to recover." },
		},
	},
	
	{
		id = "adult_affair_opportunity",
		minAge = 25, maxAge = 55,
		weight = 8, cooldown = 5,
		emoji = "💋", title = "Temptation",
		category = "romance",
		requires = function(state) return state.Flags and state.Flags.married end,
		getDynamicData = function() return { tempterName = randomName() } end,
		text = "%tempterName% is flirting with you. They're attractive and interested.",
		choices = {
			{ text = "💋 Give in", effects = { Happiness = 5, Smarts = -5 }, resultText = "You had an affair. It was exciting but wrong.", setFlag = "cheater" },
			{ text = "💍 Stay faithful", effects = { Happiness = 5, Smarts = 5 }, resultText = "You honored your vows. Good choice." },
		},
	},
	
	{
		id = "adult_divorce",
		minAge = 25, maxAge = 65,
		weight = 10, oneTime = true,
		emoji = "💔", title = "Divorce",
		category = "romance",
		requires = function(state)
			local f = state.Flags or {}
			return f.married and (f.cheater or (state.Stats and state.Stats.Happiness and state.Stats.Happiness < 30))
		end,
		text = "Your marriage is falling apart. Divorce seems inevitable.",
		choices = {
			{ text = "💔 Get divorced", effects = { Money = -50000, Happiness = -20 }, resultText = "It's over. Time to rebuild.", clearFlag = "married", setFlag = "divorced" },
			{ text = "💪 Fight for it", effects = { Happiness = -10, Money = -5000 }, resultText = "Marriage counseling might help." },
		},
	},
	
	{
		id = "adult_kids_graduation",
		minAge = 40, maxAge = 70,
		weight = 15, oneTime = true,
		emoji = "🎓", title = "Child's Graduation",
		category = "family",
		requires = function(state) return state.Flags and state.Flags.has_children end,
		getDynamicData = function() return { childName = randomName() } end,
		text = "%childName% is graduating! You're so proud!",
		choices = {
			{ text = "🎉 Celebrate big!", effects = { Happiness = 20, Money = -2000 }, resultText = "What a wonderful moment. You did it, parent!" },
			{ text = "😢 Happy tears", effects = { Happiness = 15 }, resultText = "Where did the time go?" },
		},
	},
	
	{
		id = "adult_empty_nest",
		minAge = 45, maxAge = 65,
		weight = 15, oneTime = true,
		emoji = "🏠", title = "Empty Nest",
		category = "family",
		requires = function(state) return state.Flags and state.Flags.has_children end,
		text = "Your kids have all moved out. The house is quiet.",
		choices = {
			{ text = "😢 Miss them", effects = { Happiness = -10 }, resultText = "The quiet is deafening." },
			{ text = "🎉 Freedom!", effects = { Happiness = 15 }, resultText = "Finally! Time for yourself again!" },
			{ text = "🏡 Downsize", effects = { Money = 50000, Happiness = 5 }, resultText = "You sold the big house. Fresh start." },
		},
	},
	
	{
		id = "adult_health_scare",
		minAge = 35, maxAge = 70,
		weight = 10, cooldown = 5,
		emoji = "🏥", title = "Health Scare",
		category = "health",
		getDynamicData = function()
			local conditions = {"heart issue", "cancer scare", "diabetes warning", "high blood pressure"}
			return { condition = conditions[math.random(#conditions)] }
		end,
		text = "The doctor found a %condition%. It's serious but treatable.",
		choices = {
			{ text = "🏥 Take it seriously", effects = { Health = 10, Money = -5000, Happiness = -5 }, resultText = "You changed your lifestyle. Health improved." },
			{ text = "🤷 Ignore it", effects = { Health = -15, Happiness = 3 }, resultText = "Bad choice. It got worse." },
		},
	},
	
	{
		id = "adult_become_millionaire",
		minAge = 30, maxAge = 70,
		weight = 5, oneTime = true, milestone = true,
		emoji = "💰", title = "Millionaire!",
		category = "money",
		requires = function(state) return (state.Money or 0) >= 1000000 end,
		text = "Your net worth just crossed one million dollars!",
		choices = {
			{ text = "💰 I made it!", effects = { Happiness = 25 }, resultText = "You're officially a millionaire!", setFlag = "millionaire" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════════════════
	-- ███████████████████████████████████████████████████████████████████████████
	-- MASSIVE EXPANSION PART 7: SENIOR & ELDER EVENTS (60+)
	-- ███████████████████████████████████████████████████████████████████████████
	-- ═══════════════════════════════════════════════════════════════════════════
	
	{
		id = "senior_retirement_official",
		minAge = 60, maxAge = 70,
		weight = 30, oneTime = true, milestone = true,
		emoji = "🏖️", title = "Retirement!",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return not f.retired
		end,
		text = "It's time to retire. You've worked hard your whole life.",
		choices = {
			{ text = "🏖️ Retire happily", effects = { Happiness = 20 }, resultText = "You've earned this rest!", setFlag = "retired" },
			{ text = "💼 Keep working", effects = { Happiness = 5, Money = 5000 }, resultText = "You're not ready to slow down." },
		},
	},
	
	{
		id = "senior_grandchildren",
		minAge = 50, maxAge = 80,
		weight = 20, oneTime = true, milestone = true,
		emoji = "👶", title = "Grandparent!",
		category = "family",
		requires = function(state)
			local f = state.Flags or {}
			return f.has_children and not f.grandparent
		end,
		getDynamicData = function() return { grandchildName = randomName() } end,
		text = "Your child just had a baby! You're a grandparent! Meet %grandchildName%!",
		choices = {
			{ text = "👶 Pure joy!", effects = { Happiness = 25 }, resultText = "Grandchildren are the best!", setFlag = "grandparent" },
		},
	},
	
	{
		id = "senior_spoil_grandkids",
		minAge = 55, maxAge = 90,
		weight = 15, cooldown = 3,
		emoji = "🎁", title = "Spoiling Grandkids",
		category = "family",
		requires = function(state) return state.Flags and state.Flags.grandparent end,
		text = "Your grandchildren are visiting! Time to spoil them rotten!",
		choices = {
			{ text = "🎁 Spoil them!", effects = { Happiness = 15, Money = -500 }, resultText = "Their parents might be mad but it's worth it!" },
			{ text = "📚 Teach them things", effects = { Happiness = 10, Smarts = 3 }, resultText = "You're passing on wisdom." },
		},
	},
	
	{
		id = "senior_bucket_list",
		minAge = 60, maxAge = 85,
		weight = 15, oneTime = true,
		emoji = "📝", title = "Bucket List",
		category = "social",
		text = "You made a bucket list. What's first?",
		choices = {
			{ text = "✈️ Travel the world", effects = { Happiness = 20, Money = -30000 }, resultText = "You saw places you always dreamed of!", setFlag = "world_traveler" },
			{ text = "🏔️ Adventure", effects = { Health = 5, Happiness = 15, Money = -10000 }, resultText = "You went skydiving/hiking/rafting!" },
			{ text = "📖 Write your memoir", effects = { Smarts = 8, Happiness = 10 }, resultText = "Your life story is now written.", setFlag = "memoir_written" },
		},
	},
	
	{
		id = "senior_health_decline",
		minAge = 65, maxAge = 90,
		weight = 20, cooldown = 3,
		emoji = "🦯", title = "Health Declining",
		category = "health",
		text = "Getting older is hard. Your body isn't what it used to be.",
		choices = {
			{ text = "💪 Stay active", effects = { Health = 5, Happiness = 5 }, resultText = "You're fighting the decline!" },
			{ text = "🧘 Gentle exercise", effects = { Health = 3, Happiness = 3 }, resultText = "Yoga and walking help." },
			{ text = "😔 Accept it", effects = { Health = -5, Happiness = -5 }, resultText = "Age catches up with everyone." },
		},
	},
	
	{
		id = "senior_lose_spouse",
		minAge = 60, maxAge = 100,
		weight = 10, oneTime = true,
		emoji = "💔", title = "Losing Your Spouse",
		category = "family",
		requires = function(state) return state.Flags and state.Flags.married end,
		getDynamicData = function() return { spouseName = randomName() } end,
		text = "%spouseName% has passed away. You've lost your life partner.",
		choices = {
			{ text = "😢 Grieve deeply", effects = { Happiness = -30, Health = -10 }, resultText = "The grief is overwhelming.", clearFlag = "married", setFlag = "widowed" },
			{ text = "💪 Honor their memory", effects = { Happiness = -15, Smarts = 5 }, resultText = "You'll carry them in your heart forever.", clearFlag = "married", setFlag = "widowed" },
		},
	},
	
	{
		id = "senior_legacy_planning",
		minAge = 65, maxAge = 90,
		weight = 15, oneTime = true,
		emoji = "📜", title = "Estate Planning",
		category = "money",
		text = "It's time to think about your legacy. Who gets what?",
		choices = {
			{ text = "📜 Write a will", effects = { Smarts = 5, Money = -1000 }, resultText = "Your affairs are in order.", setFlag = "has_will" },
			{ text = "🎁 Start giving now", effects = { Happiness = 10, Money = -50000 }, resultText = "You're helping your family while you're still here." },
			{ text = "🤷 Deal with it later", effects = { Happiness = -3 }, resultText = "Procrastination might cause problems." },
		},
	},
	
	{
		id = "senior_assisted_living",
		minAge = 75, maxAge = 100,
		weight = 15, oneTime = true,
		emoji = "🏥", title = "Assisted Living",
		category = "health",
		requires = function(state) return (state.Stats and state.Stats.Health and state.Stats.Health < 40) end,
		text = "You might need to move to assisted living.",
		choices = {
			{ text = "🏥 Accept help", effects = { Health = 10, Happiness = -10, Money = -20000 }, resultText = "It's hard but necessary.", setFlag = "in_assisted_living" },
			{ text = "🏠 Stay home", effects = { Health = -10, Happiness = 5 }, resultText = "You're stubborn. Hopefully it works out." },
		},
	},
	
	{
		id = "senior_find_old_friend",
		minAge = 60, maxAge = 90,
		weight = 12, cooldown = 5,
		emoji = "👥", title = "Reconnecting",
		category = "social",
		getDynamicData = function() return { friendName = randomName() } end,
		text = "You reconnected with your old friend %friendName% after decades!",
		choices = {
			{ text = "🤗 Wonderful reunion!", effects = { Happiness = 15 }, resultText = "It's like no time has passed at all!" },
			{ text = "📞 Stay in touch", effects = { Happiness = 8 }, resultText = "You'll call each other regularly now." },
		},
	},
	
	{
		id = "senior_life_reflection",
		minAge = 70, maxAge = 100,
		weight = 20, cooldown = 5,
		emoji = "🔮", title = "Life Reflection",
		category = "social",
		text = "Looking back on your life, how do you feel?",
		choices = {
			{ text = "😊 Content", effects = { Happiness = 20 }, resultText = "You lived a good life. No major regrets." },
			{ text = "🤔 Some regrets", effects = { Happiness = 5, Smarts = 5 }, resultText = "There are things you'd do differently, but overall okay." },
			{ text = "😢 Many regrets", effects = { Happiness = -10 }, resultText = "If only you could do it all again..." },
		},
	},
	
	{
		id = "senior_centenarian",
		minAge = 100, maxAge = 120,
		weight = 100, oneTime = true, milestone = true,
		emoji = "🎂", title = "Centenarian!",
		category = "health",
		text = "You've reached 100 years old! Incredible!",
		choices = {
			{ text = "🎂 Celebrate!", effects = { Happiness = 30 }, resultText = "You're a living legend! What a life!", setFlag = "centenarian" },
		},
	},
	
	{
		id = "elder_final_wisdom",
		minAge = 85, maxAge = 110,
		weight = 15, oneTime = true,
		emoji = "🦉", title = "Passing On Wisdom",
		category = "family",
		text = "Your family gathers to hear your wisdom. What do you tell them?",
		choices = {
			{ text = "❤️ Love matters most", effects = { Happiness = 15 }, resultText = "They'll remember your words forever." },
			{ text = "💪 Never give up", effects = { Happiness = 12 }, resultText = "Your strength inspires them." },
			{ text = "😊 Live fully", effects = { Happiness = 15 }, resultText = "You taught them to seize every moment." },
		},
	},
	
	{
		id = "elder_peaceful_day",
		minAge = 75, maxAge = 110,
		weight = 20, cooldown = 2,
		emoji = "☀️", title = "A Beautiful Day",
		category = "social",
		text = "It's a beautiful day. The sun is shining, birds are singing.",
		choices = {
			{ text = "🌳 Sit in the garden", effects = { Happiness = 10, Health = 3 }, resultText = "Simple pleasures are the best." },
			{ text = "👨‍👩‍👧 Call family", effects = { Happiness = 12 }, resultText = "Hearing their voices brings joy." },
			{ text = "📖 Read a good book", effects = { Happiness = 8, Smarts = 3 }, resultText = "A peaceful afternoon." },
		},
	},

	-- ═══════════════════════════════════════════════════════════════════════════
	-- ███████████████████████████████████████████████████████████████████████████
	-- MASSIVE EXPANSION PART 8: DEEP RACER CAREER PATH
	-- ███████████████████████████████████████████████████████████████████████████
	-- ═══════════════════════════════════════════════════════════════════════════
	
	{
		id = "racer_first_gokart",
		minAge = 8, maxAge = 14,
		weight = 15, oneTime = true,
		emoji = "🏎️", title = "First Go-Kart",
		category = "hobby",
		text = "Your parents take you to a go-kart track! The speed is exhilarating!",
		choices = {
			{ text = "🏎️ This is amazing!", effects = { Happiness = 15 }, resultText = "You fell in love with racing!", setFlag = "loves_racing" },
			{ text = "😬 A bit scary", effects = { Happiness = 3 }, resultText = "Fun but the speed was intense." },
		},
	},
	
	{
		id = "racer_junior_karting",
		minAge = 10, maxAge = 16,
		weight = 12, oneTime = true,
		emoji = "🏁", title = "Junior Karting League",
		category = "hobby",
		requires = function(state) return state.Flags and state.Flags.loves_racing end,
		text = "There's a junior karting league in town. Want to join?",
		choices = {
			{ text = "🏁 Sign up!", effects = { Money = -500, Happiness = 15 }, resultText = "You're officially a junior racer!", setFlag = "junior_racer" },
			{ text = "👀 Watch first", effects = { Happiness = 5 }, resultText = "You observed but didn't compete yet." },
		},
	},
	
	{
		id = "racer_first_win",
		minAge = 12, maxAge = 18,
		weight = 15, oneTime = true,
		emoji = "🏆", title = "First Racing Win!",
		category = "hobby",
		requires = function(state) return state.Flags and state.Flags.junior_racer end,
		text = "You crossed the finish line first! Your first ever win!",
		choices = {
			{ text = "🏆 Victory!", effects = { Happiness = 20, Money = 200 }, resultText = "The crowd cheered your name!", setFlag = "first_race_win" },
		},
	},
	
	{
		id = "racer_talent_spotted",
		minAge = 14, maxAge = 20,
		weight = 10, oneTime = true,
		emoji = "👀", title = "Talent Scout",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.junior_racer and f.first_race_win
		end,
		getDynamicData = function() return { scoutName = randomName(), team = randomRacingTeam() } end,
		text = "%scoutName% from %team% noticed your talent! They want to develop you.",
		choices = {
			{ text = "🏎️ Join their program!", effects = { Happiness = 20, Smarts = 5 }, resultText = "You're now part of a real racing program!", setFlag = "racing_academy" },
			{ text = "📚 Focus on school first", effects = { Smarts = 5, Happiness = -5 }, resultText = "Maybe later. Education comes first." },
		},
	},
	
	{
		id = "racer_formula_4",
		minAge = 16, maxAge = 20,
		weight = 12, oneTime = true,
		emoji = "🏎️", title = "Formula 4 Debut",
		category = "work",
		requires = function(state) return state.Flags and state.Flags.racing_academy end,
		text = "You're ready to move up to Formula 4! Real single-seaters!",
		choices = {
			{ text = "🏎️ Let's race!", effects = { Happiness = 20, Money = -5000 }, resultText = "You're now a Formula 4 driver!", setFlag = "f4_driver" },
			{ text = "🏁 Stay in karting", effects = { Happiness = 5, Money = 1000 }, resultText = "You dominated karting but missed the step up." },
		},
	},
	
	{
		id = "racer_crash_injury",
		minAge = 16, maxAge = 45,
		weight = 8, cooldown = 5,
		emoji = "💥", title = "Racing Crash",
		category = "health",
		requires = function(state)
			local f = state.Flags or {}
			return f.f4_driver or f.f3_driver or f.f2_driver or f.f1_driver
		end,
		text = "You had a serious crash during practice. The car is destroyed.",
		choices = {
			{ text = "🏥 Get checked out", effects = { Health = -20, Happiness = -10 }, resultText = "Injuries but you'll recover. The mental scars are real." },
			{ text = "💪 Back in the car", effects = { Health = -10, Happiness = 5 }, resultText = "You showed courage getting back in immediately." },
		},
	},
	
	{
		id = "racer_formula_3",
		minAge = 17, maxAge = 23,
		weight = 10, oneTime = true,
		emoji = "🏎️", title = "Formula 3 Promotion",
		category = "work",
		requires = function(state) return state.Flags and state.Flags.f4_driver end,
		getDynamicData = function() return { team = randomRacingTeam() } end,
		text = "%team% wants you for their Formula 3 team! Closer to F1!",
		choices = {
			{ text = "🏎️ Sign the contract!", effects = { Happiness = 20, Money = 10000 }, resultText = "F3 driver! The dream continues!", setFlag = "f3_driver" },
			{ text = "💰 Negotiate harder", effects = { Smarts = 5, Money = 20000 }, resultText = "You got a better deal!", setFlag = "f3_driver" },
		},
	},
	
	{
		id = "racer_rivalry",
		minAge = 17, maxAge = 35,
		weight = 12, cooldown = 3,
		emoji = "😤", title = "Racing Rival",
		category = "social",
		requires = function(state)
			local f = state.Flags or {}
			return f.f3_driver or f.f2_driver or f.f1_driver
		end,
		getDynamicData = function() return { rivalName = randomName() } end,
		text = "%rivalName% is your biggest rival. They're talking trash in the press.",
		choices = {
			{ text = "🏎️ Beat them on track", effects = { Happiness = 10 }, resultText = "Your racing does the talking!", setFlag = "has_rival" },
			{ text = "🗣️ Fire back", effects = { Happiness = 5, Looks = 3 }, resultText = "The media loves the drama!" },
			{ text = "🤝 Stay professional", effects = { Smarts = 5 }, resultText = "You took the high road." },
		},
	},
	
	{
		id = "racer_formula_2",
		minAge = 18, maxAge = 25,
		weight = 10, oneTime = true,
		emoji = "🏎️", title = "Formula 2!",
		category = "work",
		requires = function(state) return state.Flags and state.Flags.f3_driver end,
		getDynamicData = function() return { team = randomRacingTeam() } end,
		text = "%team% wants you in Formula 2! One step away from Formula 1!",
		choices = {
			{ text = "🏎️ This is it!", effects = { Happiness = 25, Money = 50000 }, resultText = "F2! The final step before the pinnacle!", setFlag = "f2_driver" },
		},
	},
	
	{
		id = "racer_f2_championship",
		minAge = 18, maxAge = 26,
		weight = 8, oneTime = true, milestone = true,
		emoji = "🏆", title = "F2 Championship!",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.f2_driver and not f.f2_champion
		end,
		text = "Final race of the season. Win this and you're F2 World Champion!",
		choices = {
			{ text = "🏆 Win it all!", effects = { Happiness = 30, Money = 100000 }, resultText = "F2 WORLD CHAMPION! F1 is calling!", setFlag = "f2_champion", minigame = "getaway" },
		},
	},
	
	{
		id = "racer_f1_call",
		minAge = 19, maxAge = 30,
		weight = 15, oneTime = true, milestone = true,
		emoji = "📞", title = "The F1 Call",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.f2_champion and not f.f1_driver
		end,
		getDynamicData = function()
			local teams = {"Red Bull Racing", "Ferrari", "Mercedes", "McLaren", "Aston Martin", "Alpine"}
			return { team = teams[math.random(#teams)] }
		end,
		text = "%team% wants you to race in Formula 1! Your dream is coming true!",
		choices = {
			{ text = "📝 SIGN EVERYTHING!", effects = { Happiness = 50, Money = 500000 }, resultText = "YOU'RE AN F1 DRIVER! CHILDHOOD DREAM ACHIEVED!", setFlag = "f1_driver",
			  setJob = { id = "f1_driver", title = "Formula 1 Driver", company = "%team%", salary = 2500000, storyFlag = "f1_driver" } },
		},
	},
	
	{
		id = "racer_f1_first_race",
		minAge = 19, maxAge = 35,
		weight = 20, oneTime = true,
		emoji = "🏁", title = "First F1 Race",
		category = "work",
		requires = function(state) return state.Flags and state.Flags.f1_driver end,
		text = "Your first Formula 1 race. Millions are watching. This is it.",
		choices = {
			{ text = "🏎️ Full focus", effects = { Happiness = 25, Smarts = 5 }, resultText = "You finished! An F1 finisher!", setFlag = "f1_debut" },
		},
	},
	
	{
		id = "racer_f1_first_points",
		minAge = 19, maxAge = 40,
		weight = 15, oneTime = true,
		emoji = "🔢", title = "First F1 Points!",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.f1_debut and not f.f1_points
		end,
		text = "You finished in the top 10! Your first ever F1 points!",
		choices = {
			{ text = "🎉 Incredible!", effects = { Happiness = 25, Money = 50000 }, resultText = "Points on the board! You're competing with the best!", setFlag = "f1_points" },
		},
	},
	
	{
		id = "racer_f1_podium",
		minAge = 20, maxAge = 42,
		weight = 10, oneTime = true, milestone = true,
		emoji = "🥇", title = "First F1 Podium!",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.f1_points and not f.f1_podium
		end,
		text = "Third place! You're on the podium! Champagne spraying everywhere!",
		choices = {
			{ text = "🍾 Spray the champagne!", effects = { Happiness = 35, Money = 200000 }, resultText = "AN F1 PODIUM! This feeling is unreal!", setFlag = "f1_podium" },
		},
	},
	
	{
		id = "racer_f1_first_win",
		minAge = 20, maxAge = 45,
		weight = 8, oneTime = true, milestone = true,
		emoji = "🏆", title = "First F1 Win!",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.f1_podium and not f.f1_winner
		end,
		text = "FIRST! You've won a Formula 1 Grand Prix! Your national anthem plays!",
		choices = {
			{ text = "🏆 CHAMPION FEELING!", effects = { Happiness = 50, Money = 500000 }, resultText = "F1 RACE WINNER! You're among legends now!", setFlag = "f1_winner" },
		},
	},
	
	{
		id = "racer_f1_world_champion",
		minAge = 21, maxAge = 45,
		weight = 5, oneTime = true, milestone = true,
		emoji = "👑", title = "F1 World Champion!",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.f1_winner and not f.f1_champion
		end,
		text = "You've won the Formula 1 World Championship! The pinnacle of motorsport!",
		choices = {
			{ text = "👑 I AM THE CHAMPION!", effects = { Happiness = 100, Money = 5000000 }, resultText = "F1 WORLD CHAMPION! Your name is etched in history forever!", setFlag = "f1_champion" },
		},
	},
	
	{
		id = "racer_multi_champion",
		minAge = 23, maxAge = 45,
		weight = 3, oneTime = true, milestone = true,
		emoji = "🌟", title = "Multiple Championships!",
		category = "work",
		requires = function(state) return state.Flags and state.Flags.f1_champion end,
		text = "You've won MULTIPLE F1 World Championships! You're a legend!",
		choices = {
			{ text = "🌟 LEGEND STATUS!", effects = { Happiness = 50, Money = 10000000 }, resultText = "Multi-time World Champion! Among the all-time greats!", setFlag = "multi_champion" },
		},
	},
	
	{
		id = "racer_team_switch",
		minAge = 22, maxAge = 40,
		weight = 10, cooldown = 3,
		emoji = "🔄", title = "Team Offer",
		category = "work",
		requires = function(state) return state.Flags and state.Flags.f1_driver end,
		getDynamicData = function()
			local teams = {"Red Bull Racing", "Ferrari", "Mercedes", "McLaren", "Aston Martin"}
			return { newTeam = teams[math.random(#teams)], salary = math.random(5, 20) * 1000000 }
		end,
		text = "%newTeam% wants to sign you! They're offering $%salary%!",
		choices = {
			{ text = "📝 Sign with them", effects = { Happiness = 10, Money = 10000000 }, resultText = "New team, new chapter!" },
			{ text = "🤝 Stay loyal", effects = { Happiness = 5 }, resultText = "You're committed to your current team." },
		},
	},
	
	{
		id = "racer_sponsor_deal",
		minAge = 20, maxAge = 45,
		weight = 12, cooldown = 2,
		emoji = "💼", title = "Sponsorship Deal",
		category = "money",
		requires = function(state)
			local f = state.Flags or {}
			return f.f1_driver or f.f1_champion
		end,
		getDynamicData = function()
			local brands = {"Rolex", "Richard Mille", "Tommy Hilfiger", "Hugo Boss", "Monster Energy"}
			return { brand = brands[math.random(#brands)], amount = math.random(1, 5) * 1000000 }
		end,
		text = "%brand% wants you as their brand ambassador! $%amount% deal!",
		choices = {
			{ text = "📝 Sign the deal", effects = { Money = 2000000, Looks = 5 }, resultText = "You're now a brand ambassador!" },
			{ text = "🚫 Too commercial", effects = { Smarts = 3 }, resultText = "You prefer to stay focused on racing." },
		},
	},
	
	{
		id = "racer_retire",
		minAge = 35, maxAge = 50,
		weight = 10, oneTime = true,
		emoji = "🏁", title = "Racing Retirement",
		category = "work",
		requires = function(state) return state.Flags and state.Flags.f1_driver end,
		text = "Your body is telling you it's time. Ready to retire from racing?",
		choices = {
			{ text = "🏁 Final race", effects = { Happiness = 15 }, resultText = "You retired a legend. What a career!", setFlag = "retired_racer", clearFlag = "f1_driver" },
			{ text = "🏎️ One more season", effects = { Health = -5, Happiness = 10 }, resultText = "You're not done yet!" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════════════════
	-- ███████████████████████████████████████████████████████████████████████████
	-- MASSIVE EXPANSION PART 9: DEEP ARTIST CAREER PATH
	-- ███████████████████████████████████████████████████████████████████████████
	-- ═══════════════════════════════════════════════════════════════════════════
	
	{
		id = "artist_childhood_talent",
		minAge = 5, maxAge = 10,
		weight = 15, oneTime = true,
		emoji = "🎨", title = "Artistic Talent",
		category = "hobby",
		text = "Your drawings are better than everyone else's in class!",
		choices = {
			{ text = "🎨 I love drawing!", effects = { Happiness = 10, Smarts = 3 }, resultText = "You have real talent!", setFlag = "art_talent" },
			{ text = "🤷 It's just doodles", effects = { Happiness = 3 }, resultText = "You don't think much of it." },
		},
	},
	
	{
		id = "artist_art_class",
		minAge = 8, maxAge = 18,
		weight = 12, oneTime = true,
		emoji = "🖌️", title = "Art Classes",
		category = "education",
		requires = function(state) return state.Flags and state.Flags.art_talent end,
		text = "Your parents want to sign you up for professional art classes.",
		choices = {
			{ text = "🖌️ Yes please!", effects = { Money = -500, Smarts = 8, Happiness = 10 }, resultText = "You're learning from real artists!", setFlag = "art_trained" },
			{ text = "🎮 Rather play games", effects = { Happiness = 3 }, resultText = "Maybe another time." },
		},
	},
	
	{
		id = "artist_find_style",
		minAge = 14, maxAge = 25,
		weight = 12, oneTime = true,
		emoji = "✨", title = "Finding Your Style",
		category = "hobby",
		requires = function(state) return state.Flags and state.Flags.art_trained end,
		getDynamicData = function() return { style = randomArtStyle() } end,
		text = "You've developed a unique artistic style - %style%. It's distinctly YOU.",
		choices = {
			{ text = "✨ My signature!", effects = { Happiness = 15, Smarts = 5 }, resultText = "You found your artistic voice!", setFlag = "has_art_style" },
		},
	},
	
	{
		id = "artist_first_sale",
		minAge = 16, maxAge = 30,
		weight = 15, oneTime = true,
		emoji = "💰", title = "First Art Sale!",
		category = "money",
		requires = function(state) return state.Flags and state.Flags.has_art_style end,
		getDynamicData = function() return { price = math.random(50, 200), buyer = randomName() } end,
		text = "%buyer% wants to buy one of your pieces for $%price%!",
		choices = {
			{ text = "💰 SOLD!", effects = { Money = 100, Happiness = 20 }, resultText = "Your first sale! You're a professional artist now!", setFlag = "artist_first_sale" },
			{ text = "❤️ Not for sale", effects = { Happiness = 3 }, resultText = "Some pieces are too personal." },
		},
	},
	
	{
		id = "artist_art_school",
		minAge = 18, maxAge = 25,
		weight = 12, oneTime = true,
		emoji = "🏛️", title = "Art School",
		category = "education",
		requires = function(state)
			local f = state.Flags or {}
			return f.has_art_style and not f.art_school
		end,
		getDynamicData = function()
			local schools = {"Parsons School of Design", "Rhode Island School of Design", "School of Visual Arts", "CalArts", "Pratt Institute"}
			return { school = schools[math.random(#schools)] }
		end,
		text = "You got accepted to %school%! A prestigious art school!",
		choices = {
			{ text = "🏛️ Attend!", effects = { Money = -40000, Smarts = 15, Happiness = 15 }, resultText = "You're learning from the best!", setFlag = "art_school" },
			{ text = "🛠️ Self-taught path", effects = { Smarts = 5, Money = 40000 }, resultText = "You'll learn on your own." },
		},
	},
	
	{
		id = "artist_gallery_showing",
		minAge = 20, maxAge = 45,
		weight = 12, oneTime = true,
		emoji = "🖼️", title = "Gallery Showing",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.artist_first_sale or f.art_school
		end,
		getDynamicData = function() return { gallery = "The Downtown Art Gallery" } end,
		text = "%gallery% wants to feature your work in a group show!",
		choices = {
			{ text = "🖼️ Amazing opportunity!", effects = { Happiness = 20, Money = 2000, Looks = 5 }, resultText = "Your work is on display for the world!", setFlag = "gallery_show" },
			{ text = "😰 Not ready yet", effects = { Happiness = -5 }, resultText = "Maybe next time." },
		},
	},
	
	{
		id = "artist_commissions",
		minAge = 20, maxAge = 60,
		weight = 15, cooldown = 2,
		emoji = "📝", title = "Commission Work",
		category = "work",
		requires = function(state) return state.Flags and state.Flags.gallery_show end,
		getDynamicData = function()
			local clients = {"a wealthy collector", "a tech CEO", "a celebrity", "a corporation"}
			return { client = clients[math.random(#clients)], amount = math.random(1, 10) * 1000 }
		end,
		text = "%client% wants to commission original artwork! Offering $%amount%.",
		choices = {
			{ text = "📝 Accept commission", effects = { Money = 5000, Happiness = 10 }, resultText = "You created a custom piece!" },
			{ text = "🎨 Pure art only", effects = { Happiness = 3, Smarts = 3 }, resultText = "You prefer personal projects." },
		},
	},
	
	{
		id = "artist_solo_show",
		minAge = 25, maxAge = 60,
		weight = 10, oneTime = true, milestone = true,
		emoji = "🌟", title = "Solo Exhibition!",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.gallery_show and not f.solo_show
		end,
		getDynamicData = function() return { gallery = "Prestige Modern Art Gallery" } end,
		text = "%gallery% wants to give you a SOLO EXHIBITION! Your name on the marquee!",
		choices = {
			{ text = "🌟 Dreams come true!", effects = { Happiness = 30, Money = 20000, Looks = 10 }, resultText = "Your solo show was a massive success!", setFlag = "solo_show" },
		},
	},
	
	{
		id = "artist_critic_praise",
		minAge = 25, maxAge = 70,
		weight = 10, cooldown = 3,
		emoji = "📰", title = "Critical Acclaim",
		category = "social",
		requires = function(state) return state.Flags and state.Flags.solo_show end,
		getDynamicData = function()
			local critics = {"Art Monthly", "The New York Times", "ArtForum", "The Guardian"}
			return { publication = critics[math.random(#critics)] }
		end,
		text = "%publication% wrote a glowing review of your work! 'A voice of a generation!'",
		choices = {
			{ text = "📰 Frame that review!", effects = { Happiness = 20, Looks = 5, Smarts = 5 }, resultText = "Critical acclaim feels amazing!", setFlag = "critical_acclaim" },
		},
	},
	
	{
		id = "artist_museum_acquisition",
		minAge = 30, maxAge = 80,
		weight = 6, oneTime = true, milestone = true,
		emoji = "🏛️", title = "Museum Acquisition!",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.critical_acclaim and not f.museum_artist
		end,
		getDynamicData = function()
			local museums = {"MoMA", "The Tate", "The Louvre", "The Guggenheim", "The Whitney"}
			return { museum = museums[math.random(#museums)], price = math.random(50, 500) * 1000 }
		end,
		text = "%museum% wants to acquire one of your pieces for their permanent collection! $%price%!",
		choices = {
			{ text = "🏛️ IMMORTALIZED!", effects = { Happiness = 50, Money = 250000 }, resultText = "Your art will be seen for generations!", setFlag = "museum_artist" },
		},
	},
	
	{
		id = "artist_art_market_boom",
		minAge = 30, maxAge = 70,
		weight = 8, cooldown = 5,
		emoji = "📈", title = "Art Market Boom",
		category = "money",
		requires = function(state) return state.Flags and state.Flags.museum_artist end,
		getDynamicData = function() return { multiplier = math.random(2, 10) } end,
		text = "Your work is selling for %multiplier%x what it used to! The market loves you!",
		choices = {
			{ text = "📈 Cash in!", effects = { Money = 500000, Happiness = 20 }, resultText = "You sold multiple pieces at peak prices!" },
			{ text = "🎨 Keep creating", effects = { Happiness = 10, Smarts = 5 }, resultText = "The art matters more than the money." },
		},
	},
	
	{
		id = "artist_famous_portrait",
		minAge = 30, maxAge = 70,
		weight = 8, oneTime = true,
		emoji = "👤", title = "Celebrity Portrait",
		category = "work",
		requires = function(state) return state.Flags and state.Flags.solo_show end,
		getDynamicData = function()
			local celebs = {"a famous actor", "a world leader", "a tech billionaire", "a pop star", "a royal family member"}
			return { celeb = celebs[math.random(#celebs)] }
		end,
		text = "%celeb% wants you to paint their official portrait!",
		choices = {
			{ text = "👤 An honor!", effects = { Money = 100000, Happiness = 20, Looks = 10 }, resultText = "You painted a portrait that will hang in history!", setFlag = "celeb_portrait" },
			{ text = "🚫 Too commercial", effects = { Smarts = 5 }, resultText = "You prefer to choose your own subjects." },
		},
	},
	
	{
		id = "artist_retrospective",
		minAge = 50, maxAge = 90,
		weight = 6, oneTime = true, milestone = true,
		emoji = "🎨", title = "Career Retrospective",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return f.museum_artist and not f.retrospective
		end,
		getDynamicData = function()
			local museums = {"The Met", "MoMA", "The National Gallery", "Centre Pompidou"}
			return { museum = museums[math.random(#museums)] }
		end,
		text = "%museum% wants to host a retrospective of your entire career!",
		choices = {
			{ text = "🎨 A lifetime of work!", effects = { Happiness = 40, Money = 100000 }, resultText = "Your life's work celebrated in one place. Incredible.", setFlag = "retrospective" },
		},
	},
	
	{
		id = "artist_legacy_foundation",
		minAge = 55, maxAge = 90,
		weight = 8, oneTime = true,
		emoji = "🏛️", title = "Art Foundation",
		category = "money",
		requires = function(state) return state.Flags and state.Flags.retrospective end,
		text = "You could start a foundation to support young artists.",
		choices = {
			{ text = "🏛️ Give back", effects = { Money = -500000, Happiness = 30 }, resultText = "The foundation will help artists for generations!", setFlag = "art_foundation" },
			{ text = "💰 Keep the money", effects = { Money = 100000, Happiness = 5 }, resultText = "You'll help in other ways." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════════════════
	-- ███████████████████████████████████████████████████████████████████████████
	-- MASSIVE EXPANSION PART 10: MORE RANDOM LIFE EVENTS (ALL AGES)
	-- ███████████████████████████████████████████████████████████████████████████
	-- ═══════════════════════════════════════════════════════════════════════════
	
	{
		id = "random_find_money",
		minAge = 5, maxAge = 90,
		weight = 8, cooldown = 5,
		emoji = "💵", title = "Found Money!",
		category = "money",
		getDynamicData = function() return { amount = math.random(1, 5) * 20 } end,
		text = "You found $%amount% on the ground!",
		choices = {
			{ text = "💵 Keep it!", effects = { Money = 50, Happiness = 10 }, resultText = "Finders keepers!" },
			{ text = "👮 Turn it in", effects = { Happiness = 8, Smarts = 3 }, resultText = "You did the right thing." },
		},
	},
	
	{
		id = "random_car_accident",
		minAge = 16, maxAge = 90,
		weight = 6, cooldown = 5,
		emoji = "🚗", title = "Car Accident",
		category = "health",
		requires = function(state) return state.Flags and state.Flags.has_license end,
		text = "You were in a car accident! It wasn't your fault.",
		choices = {
			{ text = "🏥 Minor injuries", effects = { Health = -15, Happiness = -10, Money = 5000 }, resultText = "You're okay but shaken. Insurance helped." },
			{ text = "😰 Just scared", effects = { Happiness = -5 }, resultText = "Thankfully just a fender bender." },
		},
	},
	
	{
		id = "random_natural_disaster",
		minAge = 0, maxAge = 100,
		weight = 3, cooldown = 10,
		emoji = "🌪️", title = "Natural Disaster",
		category = "health",
		getDynamicData = function()
			local disasters = {"hurricane", "earthquake", "tornado", "flood", "wildfire"}
			return { disaster = disasters[math.random(#disasters)] }
		end,
		text = "A %disaster% hit your area! Everyone is scrambling!",
		choices = {
			{ text = "🏃 Evacuate!", effects = { Health = -5, Happiness = -15 }, resultText = "You got out safely but lost some possessions." },
			{ text = "🏠 Shelter in place", effects = { Health = -10, Happiness = -10 }, resultText = "You rode it out. Scary but survived." },
		},
	},
	
	{
		id = "random_lottery_small",
		minAge = 18, maxAge = 100,
		weight = 5, cooldown = 3,
		emoji = "🎫", title = "Lottery Ticket",
		category = "money",
		text = "You bought a scratch-off lottery ticket...",
		choices = {
			{ text = "🎫 Scratch it!", effects = { Money = 100, Happiness = 10 }, resultText = "You won $100! Not bad!" },
			{ text = "😔 Nothing...", effects = { Money = -5, Happiness = -3 }, resultText = "Better luck next time." },
		},
	},
	
	{
		id = "random_lottery_jackpot",
		minAge = 18, maxAge = 100,
		weight = 1, oneTime = true, milestone = true,
		emoji = "🎰", title = "LOTTERY JACKPOT!",
		category = "money",
		-- ULTRA RARE: Only 1 in 500 chance when this event is even considered
		requires = function(state)
			if state.Flags and state.Flags.lottery_winner then return false end
			-- 0.2% chance per year this can even fire
			return math.random(1, 500) == 1
		end,
		getDynamicData = function() return { amount = math.random(1, 10) * 1000000 } end,
		text = "YOU WON THE LOTTERY! $%amount%!!! THIS IS REAL!!!",
		choices = {
			{ text = "🎉 LIFE CHANGED!", effects = { Money = 5000000, Happiness = 50 }, resultText = "You're RICH! What will you do with it all?", setFlag = "lottery_winner" },
		},
	},
	
	{
		id = "random_pet_adoption",
		minAge = 10, maxAge = 80,
		weight = 10, cooldown = 5,
		emoji = "🐕", title = "Pet Adoption",
		category = "social",
		getDynamicData = function()
			local pets = {"dog", "cat", "hamster", "bird", "rabbit"}
			local names = {"Max", "Luna", "Charlie", "Bella", "Buddy", "Coco"}
			return { pet = pets[math.random(#pets)], name = names[math.random(#names)] }
		end,
		text = "There's an adorable %pet% at the shelter. They're calling them %name%.",
		choices = {
			{ text = "🐕 Adopt!", effects = { Money = -200, Happiness = 20 }, resultText = "You have a new furry friend!", setFlag = "has_pet" },
			{ text = "😢 Can't right now", effects = { Happiness = -5 }, resultText = "Maybe someday." },
		},
	},
	
	{
		id = "random_pet_death",
		minAge = 15, maxAge = 100,
		weight = 8, oneTime = true,
		emoji = "🌈", title = "Pet Passes Away",
		category = "social",
		requires = function(state) return state.Flags and state.Flags.has_pet end,
		getDynamicData = function() return { petName = "your beloved pet" } end,
		text = "%petName% has crossed the rainbow bridge. They lived a good life.",
		choices = {
			{ text = "😢 Goodbye friend", effects = { Happiness = -20 }, resultText = "They were family. You'll miss them forever.", clearFlag = "has_pet" },
		},
	},
	
	{
		id = "random_random_act_kindness",
		minAge = 10, maxAge = 100,
		weight = 10, cooldown = 3,
		emoji = "💝", title = "Random Act of Kindness",
		category = "social",
		getDynamicData = function() return { stranger = randomName() } end,
		text = "A stranger named %stranger% did something really kind for you today!",
		choices = {
			{ text = "💝 Pay it forward", effects = { Happiness = 15, Money = -20 }, resultText = "You did something kind for someone else!" },
			{ text = "😊 Just smile", effects = { Happiness = 10 }, resultText = "Faith in humanity restored!" },
		},
	},
	
	{
		id = "random_viral_moment",
		minAge = 12, maxAge = 60,
		weight = 5, oneTime = true,
		emoji = "📱", title = "Went Viral!",
		category = "social",
		text = "Something you posted online went VIRAL! Millions of views!",
		choices = {
			{ text = "🌟 Enjoy the fame!", effects = { Happiness = 20, Looks = 5, Money = 1000 }, resultText = "You're internet famous!", setFlag = "went_viral" },
			{ text = "😰 Delete everything", effects = { Happiness = -5 }, resultText = "You didn't want that attention." },
		},
	},
	
	{
		id = "random_identity_theft",
		minAge = 18, maxAge = 90,
		weight = 4, cooldown = 10,
		emoji = "🔓", title = "Identity Theft",
		category = "crime",
		text = "Someone stole your identity! Fraudulent charges everywhere!",
		choices = {
			{ text = "🚔 Report it", effects = { Money = -5000, Happiness = -15, Smarts = 3 }, resultText = "A nightmare to fix but you got through it." },
			{ text = "😤 Track them down", effects = { Money = -3000, Happiness = 5, Smarts = 5 }, resultText = "You actually found the culprit!" },
		},
	},
	
	{
		id = "random_surprise_inheritance",
		minAge = 20, maxAge = 80,
		weight = 4, oneTime = true,
		emoji = "📜", title = "Surprise Inheritance",
		category = "money",
		getDynamicData = function()
			local relatives = {"great-aunt", "distant cousin", "grandfather's friend", "unknown relative"}
			return { relative = relatives[math.random(#relatives)], amount = math.random(10, 100) * 1000 }
		end,
		text = "Your %relative% passed away and left you $%amount% in their will!",
		choices = {
			{ text = "💰 Unexpected!", effects = { Money = 50000, Happiness = 10 }, resultText = "A bittersweet surprise.", setFlag = "got_inheritance" },
		},
	},
	
	{
		id = "random_home_invasion",
		minAge = 18, maxAge = 90,
		weight = 3, cooldown = 10,
		emoji = "🏚️", title = "Home Invasion",
		category = "crime",
		text = "Someone broke into your home while you were away! They took valuables!",
		choices = {
			{ text = "🚔 Call police", effects = { Money = -5000, Happiness = -20 }, resultText = "They never caught the thieves." },
			{ text = "🔒 Security upgrade", effects = { Money = -8000, Happiness = -15 }, resultText = "You invested in serious security.", setFlag = "has_security" },
		},
	},
	
	{
		id = "random_jury_duty",
		minAge = 18, maxAge = 80,
		weight = 10, cooldown = 5,
		emoji = "⚖️", title = "Jury Duty",
		category = "social",
		text = "You've been summoned for jury duty.",
		choices = {
			{ text = "⚖️ Serve your duty", effects = { Smarts = 5, Happiness = -3, Money = -200 }, resultText = "Justice was served. Interesting experience." },
			{ text = "🏃 Try to get out of it", effects = { Happiness = 3, Smarts = -3 }, resultText = "You dodged it this time." },
		},
	},
	
	{
		id = "random_midlife_crisis",
		minAge = 40, maxAge = 55,
		weight = 15, oneTime = true,
		emoji = "🏎️", title = "Midlife Crisis",
		category = "social",
		text = "Is this all there is? You're questioning everything about your life.",
		choices = {
			{ text = "🏎️ Buy a sports car", effects = { Money = -50000, Happiness = 15, Looks = 5 }, resultText = "The car is amazing. Crisis... managed?", setFlag = "midlife_crisis", addAsset = { type = "vehicle", id = "crisis_sports", name = "Luxury Sports Car", value = 50000 } },
			{ text = "🔄 Make real changes", effects = { Happiness = 10, Smarts = 5 }, resultText = "You're making meaningful life adjustments." },
			{ text = "🧘 Accept yourself", effects = { Happiness = 20 }, resultText = "You found peace with who you are." },
		},
	},
	
	{
		id = "random_scam_attempt",
		minAge = 18, maxAge = 100,
		weight = 8, cooldown = 3,
		emoji = "🎣", title = "Scam Attempt",
		category = "social",
		getDynamicData = function()
			local scams = {"Nigerian prince email", "IRS phone call", "tech support scam", "romance scam", "crypto scheme"}
			return { scam = scams[math.random(#scams)] }
		end,
		text = "Someone is trying to scam you with a %scam%!",
		choices = {
			{ text = "🚫 Not falling for it", effects = { Smarts = 5, Happiness = 3 }, resultText = "You saw right through it!" },
			{ text = "😰 Almost fell for it", effects = { Smarts = 3, Happiness = -5 }, resultText = "That was close..." },
		},
	},
	
	{
		id = "random_reunion",
		minAge = 25, maxAge = 80,
		weight = 10, cooldown = 10,
		emoji = "🎉", title = "Class Reunion",
		category = "social",
		getDynamicData = function() return { years = math.random(1, 5) * 10 } end,
		text = "Your %years%-year class reunion is coming up!",
		choices = {
			{ text = "🎉 Attend!", effects = { Happiness = 15, Looks = 3 }, resultText = "Great to see everyone! Some aged better than others." },
			{ text = "🙅 Skip it", effects = { Happiness = -3 }, resultText = "You weren't that close anyway." },
		},
	},
	
	{
		id = "random_good_deed_reward",
		minAge = 10, maxAge = 90,
		weight = 6, cooldown = 5,
		emoji = "🏆", title = "Good Deed Rewarded",
		category = "social",
		getDynamicData = function()
			local deeds = {"returned a lost wallet", "helped an elderly person", "saved a choking person", "stopped a thief"}
			return { deed = deeds[math.random(#deeds)], reward = math.random(1, 5) * 100 }
		end,
		text = "Because you %deed%, someone wants to reward you with $%reward%!",
		choices = {
			{ text = "💵 Accept reward", effects = { Money = 250, Happiness = 15 }, resultText = "Good karma pays off!" },
			{ text = "🙅 Refuse it", effects = { Happiness = 20, Smarts = 3 }, resultText = "The deed was reward enough." },
		},
	},
	
	{
		id = "random_stranger_conversation",
		minAge = 10, maxAge = 100,
		weight = 12, cooldown = 2,
		emoji = "💬", title = "Meaningful Conversation",
		category = "social",
		getDynamicData = function() return { stranger = randomName() } end,
		text = "You had a deep, meaningful conversation with a stranger named %stranger%.",
		choices = {
			{ text = "💬 Exchange contact info", effects = { Happiness = 10, Smarts = 3 }, resultText = "You might have made a new friend!" },
			{ text = "👋 Part ways", effects = { Happiness = 8 }, resultText = "Ships passing in the night, but memorable." },
		},
	},
	
	{
		id = "random_embarrassing_moment",
		minAge = 5, maxAge = 80,
		weight = 10, cooldown = 3,
		emoji = "😳", title = "Embarrassing Moment",
		category = "social",
		getDynamicData = function()
			local moments = {"tripped in public", "called someone the wrong name", "spilled food on yourself", "forgot someone's name", "laughed at the wrong moment"}
			return { moment = moments[math.random(#moments)] }
		end,
		text = "You %moment%. So embarrassing!",
		choices = {
			{ text = "😂 Laugh it off", effects = { Happiness = 3, Looks = -3 }, resultText = "Everyone has those moments!" },
			{ text = "😳 Cringe", effects = { Happiness = -5 }, resultText = "You'll be thinking about this at 3am for years." },
		},
	},
	
	{
		id = "random_perfect_day",
		minAge = 5, maxAge = 100,
		weight = 8, cooldown = 5,
		emoji = "✨", title = "Perfect Day",
		category = "social",
		text = "Everything went right today. The weather, the food, the people. Perfect.",
		choices = {
			{ text = "✨ Appreciate it", effects = { Happiness = 20, Health = 5 }, resultText = "These days are rare. You savored every moment." },
		},
	},
	
	{
		id = "random_terrible_day",
		minAge = 5, maxAge = 100,
		weight = 8, cooldown = 5,
		emoji = "😞", title = "Terrible Day",
		category = "social",
		text = "Everything went wrong today. Murphy's Law in full effect.",
		choices = {
			{ text = "😞 Tomorrow is a new day", effects = { Happiness = -10, Smarts = 3 }, resultText = "You survived. That counts for something." },
			{ text = "😤 Get angry", effects = { Happiness = -5, Health = -3 }, resultText = "Sometimes you just need to vent." },
		},
	},
	
	{
		id = "random_deja_vu",
		minAge = 10, maxAge = 100,
		weight = 8, cooldown = 5,
		emoji = "🔮", title = "Déjà Vu",
		category = "social",
		text = "You experienced intense déjà vu. Have you lived this moment before?",
		choices = {
			{ text = "🔮 Mysterious...", effects = { Smarts = 3, Happiness = 5 }, resultText = "The universe works in strange ways." },
			{ text = "🧠 Just a brain glitch", effects = { Smarts = 5 }, resultText = "Science says it's just neural misfiring." },
		},
	},
	
	{
		id = "random_insomnia",
		minAge = 15, maxAge = 90,
		weight = 10, cooldown = 3,
		emoji = "😵", title = "Can't Sleep",
		category = "health",
		text = "You've been struggling with insomnia. Nights are long and restless.",
		choices = {
			{ text = "💊 See a doctor", effects = { Health = 5, Money = -200, Happiness = 3 }, resultText = "Treatment helped you sleep better." },
			{ text = "☕ Power through", effects = { Health = -5, Happiness = -5, Smarts = 3 }, resultText = "You're exhausted but managing." },
		},
	},
	
	{
		id = "random_food_poisoning",
		minAge = 5, maxAge = 100,
		weight = 8, cooldown = 5,
		emoji = "🤢", title = "Food Poisoning",
		category = "health",
		getDynamicData = function()
			local foods = {"sushi", "chicken", "shellfish", "buffet food", "street food"}
			return { food = foods[math.random(#foods)] }
		end,
		text = "That %food% was a mistake. You're violently ill.",
		choices = {
			{ text = "🤢 Ride it out", effects = { Health = -10, Happiness = -10 }, resultText = "Worst 24 hours ever but you survived." },
			{ text = "🏥 Hospital", effects = { Health = -5, Money = -500, Happiness = -5 }, resultText = "They gave you IV fluids. Felt better faster." },
		},
	},
	
	{
		id = "random_new_hobby",
		minAge = 10, maxAge = 80,
		weight = 12, cooldown = 5,
		emoji = "🎯", title = "New Hobby",
		category = "hobby",
		getDynamicData = function()
			local hobbies = {"woodworking", "gardening", "photography", "cooking", "hiking", "chess", "bird watching", "pottery"}
			return { hobby = hobbies[math.random(#hobbies)] }
		end,
		text = "You discovered an interest in %hobby%!",
		choices = {
			{ text = "🎯 Dive in!", effects = { Happiness = 15, Smarts = 5, Money = -200 }, resultText = "You found a new passion!", setFlag = "has_hobby" },
			{ text = "🤷 Not for me", effects = { Happiness = 3 }, resultText = "Maybe something else will click." },
		},
	},
	
	{
		id = "random_weather_extreme",
		minAge = 0, maxAge = 100,
		weight = 10, cooldown = 3,
		emoji = "🌡️", title = "Extreme Weather",
		category = "health",
		getDynamicData = function()
			local weather = {"heat wave", "cold snap", "massive storm", "heavy snow", "intense rain"}
			return { weather = weather[math.random(#weather)] }
		end,
		text = "A %weather% hit your area! Everyone's talking about it.",
		choices = {
			{ text = "🏠 Stay inside", effects = { Happiness = -3 }, resultText = "You waited it out safely." },
			{ text = "🚶 Brave the elements", effects = { Health = -5, Happiness = 5 }, resultText = "An adventure, but a bit rough." },
		},
	},
	
	{
		id = "random_strange_dream",
		minAge = 5, maxAge = 100,
		weight = 10, cooldown = 3,
		emoji = "💭", title = "Strange Dream",
		category = "social",
		text = "You had the strangest, most vivid dream last night. It felt so real.",
		choices = {
			{ text = "💭 What did it mean?", effects = { Smarts = 3, Happiness = 3 }, resultText = "You pondered its meaning all day." },
			{ text = "🤷 Just a dream", effects = { Happiness = 3 }, resultText = "Brains are weird." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- PRISON EVENTS - Only fire when player has in_prison flag
	-- These events provide depth and immersion to the prison experience
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "prison_first_day",
		minAge = 14, maxAge = 100,
		weight = 100, milestone = true, oneTime = true,
		emoji = "⛓️", title = "First Day in Prison",
		category = "prison",
		requiresFlag = "in_prison",
		blockIfFlag = "survived_first_day",
		text = "The cell door slams behind you. You're now an inmate. Other prisoners size you up.",
		choices = {
			{ text = "💪 Look tough", effects = { Health = -5, Happiness = -10 }, resultText = "You tried to look intimidating. Most left you alone.", setFlag = "prison_tough" },
			{ text = "😔 Keep head down", effects = { Happiness = -15 }, resultText = "You avoided eye contact. Time to survive.", setFlag = "prison_quiet" },
			{ text = "🤝 Find allies", effects = { Happiness = -5, Smarts = 3 }, resultText = "You started looking for friendly faces.", setFlag = "prison_social" },
		},
	},
	
	{
		id = "prison_cellmate_intro",
		minAge = 14, maxAge = 100,
		weight = 60, oneTime = true,
		emoji = "👤", title = "Your Cellmate",
		category = "prison",
		requiresFlag = "in_prison",
		blockIfFlag = "met_cellmate",
		getDynamicData = function()
			local types = {"a massive guy covered in tattoos", "a quiet old man who's been here decades", "a nervous young first-timer like you", "a friendly guy who knows the ropes", "a scary-looking dude who doesn't talk"}
			return { cellmate = types[math.random(#types)] }
		end,
		text = "Your cellmate is %cellmate%. They watch you unpack your stuff.",
		choices = {
			{ text = "👋 Introduce yourself", effects = { Happiness = 5, Smarts = 3 }, resultText = "They nodded. A small but important first step.", setFlag = "met_cellmate" },
			{ text = "🤐 Stay quiet", effects = { Happiness = -3 }, resultText = "The silence was uncomfortable.", setFlag = "met_cellmate" },
			{ text = "💪 Assert dominance", effects = { Health = -10, Happiness = -5 }, resultText = "Bad idea. You learned your place quickly.", setFlag = "met_cellmate" },
		},
	},
	
	{
		id = "prison_yard_time",
		minAge = 14, maxAge = 100,
		weight = 40, cooldown = 2,
		emoji = "☀️", title = "Yard Time",
		category = "prison",
		requiresFlag = "in_prison",
		text = "It's yard time. The sun feels good after being in that cell.",
		choices = {
			{ text = "🏋️ Hit the weights", effects = { Health = 10, Looks = 3 }, resultText = "You pumped iron. Getting stronger every day." },
			{ text = "🏃 Walk laps", effects = { Health = 5, Happiness = 5 }, resultText = "Some cardio and fresh air." },
			{ text = "👥 Socialize", effects = { Happiness = 5, Smarts = 3 }, resultText = "You learned some valuable info from other inmates." },
			{ text = "🧘 Meditate", effects = { Happiness = 8, Smarts = 5 }, resultText = "You found inner peace despite the chaos." },
		},
	},
	
	{
		id = "prison_gang_approach",
		minAge = 16, maxAge = 70,
		weight = 30, cooldown = 10,
		emoji = "😈", title = "Gang Recruitment",
		category = "prison",
		requiresFlag = "in_prison",
		blockIfFlag = "prison_gang_member",
		getDynamicData = function()
			local gangs = {"The Brotherhood", "Los Carnales", "Black Hand", "The Aryan Nation", "MS-13"}
			return { gang = gangs[math.random(#gangs)] }
		end,
		text = "A member of %gang% approaches you. 'You looking for protection in here?'",
		choices = {
			{ text = "✅ Join them", effects = { Happiness = -5, Health = 5 }, resultText = "You're protected now, but at what cost?", setFlags = {"prison_gang_member", "gang_affiliated"} },
			{ text = "❌ Decline politely", effects = { Happiness = 5 }, resultText = "They nodded and walked away. For now." },
			{ text = "🖕 Tell them off", effects = { Health = -20, Happiness = -15 }, resultText = "Bad move. You got jumped that night.", setFlag = "gang_enemy" },
		},
	},
	
	{
		id = "prison_fight",
		minAge = 14, maxAge = 80,
		weight = 25, cooldown = 3,
		emoji = "👊", title = "Prison Fight!",
		category = "prison",
		requiresFlag = "in_prison",
		getDynamicData = function()
			local reasons = {"looked at you wrong", "took your seat in the cafeteria", "insulted you", "bumped into you", "stole from you"}
			return { reason = reasons[math.random(#reasons)] }
		end,
		text = "An inmate %reason%. They're squaring up. Guards aren't watching.",
		choices = {
			{ text = "👊 Fight!", effects = { Health = -15, Happiness = -10 }, resultText = "You threw hands. Win or lose, you earned some respect.", setFlag = "prison_fighter" },
			{ text = "🏃 Walk away", effects = { Happiness = -5, Health = -5 }, resultText = "They sucker punched you as you left. Coward rep grows." },
			{ text = "🗣️ De-escalate", effects = { Smarts = 5, Happiness = 3 }, resultText = "Your words defused the situation. Smart move." },
		},
	},
	
	{
		id = "prison_solitary",
		minAge = 14, maxAge = 100,
		weight = 15, cooldown = 10,
		emoji = "🚪", title = "Solitary Confinement",
		category = "prison",
		requiresFlag = "in_prison",
		requiresFlag2 = "prison_fighter",
		getDynamicData = function()
			local days = math.random(3, 14)
			return { days = days }
		end,
		text = "You're being sent to solitary for %days% days. The hole.",
		choices = {
			{ text = "😔 Endure it", effects = { Happiness = -25, Smarts = 5 }, resultText = "Alone with your thoughts. You barely kept it together." },
			{ text = "😠 Rage", effects = { Health = -10, Happiness = -20 }, resultText = "You screamed and beat the walls. They extended your stay." },
			{ text = "🧘 Meditate", effects = { Happiness = -10, Smarts = 10 }, resultText = "You used the time for inner reflection. Emerged stronger mentally." },
		},
	},
	
	{
		id = "prison_visitor",
		minAge = 14, maxAge = 100,
		weight = 35, cooldown = 5,
		emoji = "👨‍👩‍👧", title = "Visitor!",
		category = "prison",
		requiresFlag = "in_prison",
		getDynamicData = function()
			local visitors = {"your mother", "your father", "your sibling", "an old friend", "your significant other", "a family member"}
			return { visitor = visitors[math.random(#visitors)] }
		end,
		text = "You have a visitor! It's %visitor%. They look worried but happy to see you.",
		choices = {
			{ text = "💕 Tearful reunion", effects = { Happiness = 25 }, resultText = "Seeing them made everything feel better, even if briefly." },
			{ text = "😔 Apologize", effects = { Happiness = 15, Smarts = 3 }, resultText = "You told them how sorry you are. Tears were shed." },
			{ text = "😠 Tell them not to come", effects = { Happiness = -10 }, resultText = "You pushed them away. You don't deserve visitors.", setFlag = "isolated" },
		},
	},
	
	{
		id = "prison_good_behavior",
		minAge = 14, maxAge = 100,
		weight = 25, cooldown = 8,
		emoji = "⭐", title = "Good Behavior Notice",
		category = "prison",
		requiresFlag = "in_prison",
		blockIfFlag = "prison_fighter",
		blockIfFlag2 = "prison_troublemaker",
		text = "The warden noticed your good behavior. You might get privileges.",
		choices = {
			{ text = "😊 Thank them", effects = { Happiness = 15 }, resultText = "You got extra yard time and better food.", setFlag = "good_behavior" },
			{ text = "🤔 Ask about early release", effects = { Smarts = 5 }, resultText = "They said they'll consider it. Hope rises." },
		},
	},
	
	{
		id = "prison_contraband_offer",
		minAge = 16, maxAge = 80,
		weight = 20, cooldown = 5,
		emoji = "📦", title = "Contraband Offer",
		category = "prison",
		requiresFlag = "in_prison",
		getDynamicData = function()
			local items = {"a phone", "drugs", "a weapon", "cigarettes", "alcohol"}
			return { item = items[math.random(#items)] }
		end,
		text = "Another inmate whispers: 'Want %item%? I can hook you up.'",
		choices = {
			{ text = "✅ Accept", effects = { Happiness = 10, Health = -5 }, resultText = "You got the goods. High risk, but feels good.", setFlag = "has_contraband" },
			{ text = "❌ Decline", effects = { Happiness = 3 }, resultText = "You stayed clean. Smart choice." },
			{ text = "🚔 Report them", effects = { Happiness = -5, Health = -10 }, resultText = "You snitched. Now you have enemies.", setFlag = "prison_snitch" },
		},
	},
	
	{
		id = "prison_library",
		minAge = 14, maxAge = 100,
		weight = 30, cooldown = 3,
		emoji = "📚", title = "Prison Library",
		category = "prison",
		requiresFlag = "in_prison",
		text = "You got access to the prison library. A small escape from reality.",
		choices = {
			{ text = "📖 Read books", effects = { Smarts = 10, Happiness = 8 }, resultText = "You devoured books. Knowledge is power." },
			{ text = "⚖️ Study law", effects = { Smarts = 15 }, resultText = "You started understanding your legal situation better.", setFlag = "prison_lawyer" },
			{ text = "✍️ Write", effects = { Happiness = 10, Smarts = 5 }, resultText = "You started journaling. Good therapy." },
		},
	},
	
	{
		id = "prison_work_detail",
		minAge = 16, maxAge = 70,
		weight = 35, cooldown = 5,
		emoji = "🧹", title = "Work Assignment",
		category = "prison",
		requiresFlag = "in_prison",
		getDynamicData = function()
			local jobs = {"kitchen duty", "laundry service", "janitorial work", "license plate making", "groundskeeping"}
			return { job = jobs[math.random(#jobs)] }
		end,
		text = "You've been assigned %job%. It's not glamorous, but it passes the time.",
		choices = {
			{ text = "💪 Work hard", effects = { Health = 5, Happiness = 5, Money = 50 }, resultText = "Good work. You earned some commissary money.", setFlag = "prison_worker" },
			{ text = "😒 Do minimum", effects = { Happiness = -3 }, resultText = "You did just enough. The time dragged." },
			{ text = "😴 Slack off", effects = { Happiness = -10 }, resultText = "You got caught and lost privileges.", setFlag = "prison_troublemaker" },
		},
	},
	
	{
		id = "prison_food",
		minAge = 14, maxAge = 100,
		weight = 25, cooldown = 3,
		emoji = "🍽️", title = "Cafeteria Incident",
		category = "prison",
		requiresFlag = "in_prison",
		getDynamicData = function()
			local incidents = {"Someone tried to take your food", "The food today is especially bad", "You found a bug in your tray", "Someone spilled their tray on you", "A fight broke out nearby"}
			return { incident = incidents[math.random(#incidents)] }
		end,
		text = "%incident%. Prison meals are never pleasant.",
		choices = {
			{ text = "😤 Deal with it", effects = { Happiness = -5, Health = -3 }, resultText = "Just another day in here." },
			{ text = "🤷 Ignore", effects = { Happiness = -3 }, resultText = "You kept your head down and finished eating." },
		},
	},
	
	{
		id = "prison_health_issue",
		minAge = 14, maxAge = 100,
		weight = 20, cooldown = 8,
		emoji = "🤒", title = "Prison Health Issues",
		category = "prison",
		requiresFlag = "in_prison",
		getDynamicData = function()
			local issues = {"caught a cold", "got an infection", "developed back pain", "have dental problems", "feel depressed"}
			return { issue = issues[math.random(#issues)] }
		end,
		text = "You've %issue%. Prison medical isn't great, but it's something.",
		choices = {
			{ text = "🏥 See prison doctor", effects = { Health = 5, Happiness = 3 }, resultText = "They gave you some treatment. Better than nothing." },
			{ text = "💪 Tough it out", effects = { Health = -10, Happiness = -5 }, resultText = "You refused to show weakness. But you're suffering." },
		},
	},
	
	{
		id = "prison_letter",
		minAge = 14, maxAge = 100,
		weight = 30, cooldown = 4,
		emoji = "✉️", title = "You Got Mail",
		category = "prison",
		requiresFlag = "in_prison",
		getDynamicData = function()
			local senders = {"your mom", "an old friend", "your ex", "a family member", "someone you don't recognize"}
			return { sender = senders[math.random(#senders)] }
		end,
		text = "A letter arrived from %sender%. Your heart races opening it.",
		choices = {
			{ text = "📖 Read it", effects = { Happiness = 15 }, resultText = "News from the outside. It hurt and healed at the same time." },
			{ text = "✍️ Write back", effects = { Happiness = 10, Smarts = 3 }, resultText = "You poured your heart out on paper." },
			{ text = "🗑️ Throw it away", effects = { Happiness = -5 }, resultText = "You couldn't face what they wrote.", setFlag = "isolated" },
		},
	},
	
	{
		id = "prison_parole_hearing",
		minAge = 18, maxAge = 100,
		weight = 20, cooldown = 20, oneTime = false,
		emoji = "⚖️", title = "Parole Hearing!",
		category = "prison",
		requiresFlag = "in_prison",
		requiresFlag2 = "good_behavior",
		text = "You have a parole hearing! This could be your ticket out.",
		choices = {
			{ text = "😢 Show remorse", effects = { Happiness = 10, Smarts = 5 }, resultText = "The board seemed moved. They'll consider your case." },
			{ text = "💪 Promise change", effects = { Happiness = 5 }, resultText = "You laid out your plans for reform." },
			{ text = "😤 Stay defiant", effects = { Happiness = -10 }, resultText = "Bad choice. They denied your parole.", clearFlag = "good_behavior" },
		},
	},
	
	{
		id = "prison_commissary",
		minAge = 14, maxAge = 100,
		weight = 25, cooldown = 5,
		emoji = "🛒", title = "Commissary Day",
		category = "prison",
		requiresFlag = "in_prison",
		text = "It's commissary day. You can buy snacks, toiletries, and small comforts.",
		choices = {
			{ text = "🍫 Buy snacks", effects = { Happiness = 10, Money = -30 }, resultText = "Ramen and candy bars. Small pleasures matter." },
			{ text = "📱 Buy phone time", effects = { Happiness = 15, Money = -50 }, resultText = "You called someone from the outside. Worth every penny." },
			{ text = "💰 Save your money", effects = { Smarts = 3 }, resultText = "You're being smart with your funds." },
		},
	},
	
	{
		id = "prison_religion",
		minAge = 14, maxAge = 100,
		weight = 20, cooldown = 10,
		emoji = "🙏", title = "Religious Services",
		category = "prison",
		requiresFlag = "in_prison",
		text = "There's a religious service today. Many inmates find comfort in faith.",
		choices = {
			{ text = "🙏 Attend", effects = { Happiness = 12, Smarts = 3 }, resultText = "You found some peace and community.", setFlag = "prison_faithful" },
			{ text = "❌ Skip", effects = { Happiness = -3 }, resultText = "Not your thing. You stayed in your cell." },
		},
	},
	
	{
		id = "prison_riot",
		minAge = 16, maxAge = 80,
		weight = 8, cooldown = 30,
		emoji = "🔥", title = "Prison Riot!",
		category = "prison",
		requiresFlag = "in_prison",
		text = "A riot breaks out! Alarms are blaring, smoke is everywhere. Chaos!",
		choices = {
			{ text = "🏠 Hide in cell", effects = { Health = 5, Happiness = -15 }, resultText = "You stayed safe but the sounds were terrifying." },
			{ text = "🔥 Join the riot", effects = { Health = -25, Happiness = 10 }, resultText = "You let out some rage. But you got hurt.", setFlag = "prison_troublemaker" },
			{ text = "🆘 Help guards", effects = { Health = -10, Happiness = 5 }, resultText = "Risky, but guards remember who helped.", setFlag = "good_behavior" },
		},
	},
	
	{
		id = "prison_transfer",
		minAge = 14, maxAge = 100,
		weight = 10, cooldown = 30, oneTime = true,
		emoji = "🚐", title = "Prison Transfer",
		category = "prison",
		requiresFlag = "in_prison",
		getDynamicData = function()
			local prisons = {"a maximum security facility", "a minimum security camp", "a prison closer to home", "a more dangerous facility", "a newer prison"}
			return { prison = prisons[math.random(#prisons)] }
		end,
		text = "You're being transferred to %prison%. New beginnings, new dangers.",
		choices = {
			{ text = "😬 Nervous", effects = { Happiness = -10 }, resultText = "Change is scary, especially in here." },
			{ text = "🤞 Hopeful", effects = { Happiness = 5 }, resultText = "Maybe this will be better. Fresh start." },
		},
	},
	
	{
		id = "prison_education",
		minAge = 16, maxAge = 60,
		weight = 20, cooldown = 15,
		emoji = "🎓", title = "Prison Education Program",
		category = "prison",
		requiresFlag = "in_prison",
		text = "The prison offers education programs. You could get a GED or learn a trade.",
		choices = {
			{ text = "📚 Get GED", effects = { Smarts = 20, Happiness = 15 }, resultText = "You earned your GED! This will help when you get out.", setFlag = "has_ged" },
			{ text = "🔧 Learn a trade", effects = { Smarts = 15, Happiness = 10 }, resultText = "You learned valuable skills for the real world.", setFlag = "has_trade_skill" },
			{ text = "❌ Not interested", effects = { Happiness = -5 }, resultText = "You passed up a good opportunity." },
		},
	},
	
	{
		id = "prison_nightmare",
		minAge = 14, maxAge = 100,
		weight = 30, cooldown = 3,
		emoji = "😱", title = "Prison Nightmares",
		category = "prison",
		requiresFlag = "in_prison",
		text = "You wake up screaming. The nightmares are getting worse.",
		choices = {
			{ text = "😔 Try to sleep", effects = { Happiness = -10, Health = -5 }, resultText = "Sleep didn't come easy that night." },
			{ text = "🧘 Breathe and calm", effects = { Happiness = -5, Smarts = 3 }, resultText = "You centered yourself. It helped a little." },
		},
	},
	
	{
		id = "prison_birthday",
		minAge = 14, maxAge = 100,
		weight = 40, cooldown = 20,
		emoji = "🎂", title = "Birthday Behind Bars",
		category = "prison",
		requiresFlag = "in_prison",
		text = "It's your birthday. Celebrating in prison hits different.",
		choices = {
			{ text = "😔 Feel sad", effects = { Happiness = -15 }, resultText = "Another year older, still locked up." },
			{ text = "🎂 Make the best of it", effects = { Happiness = 5 }, resultText = "Some inmates wished you well. Small comforts." },
		},
	},
	
	{
		id = "prison_lockdown",
		minAge = 14, maxAge = 100,
		weight = 20, cooldown = 10,
		emoji = "🚨", title = "Prison Lockdown",
		category = "prison",
		requiresFlag = "in_prison",
		getDynamicData = function()
			local reasons = {"a stabbing in D-block", "contraband discovery", "an escape attempt", "suspicious activity", "a credible threat"}
			return { reason = reasons[math.random(#reasons)] }
		end,
		text = "Full lockdown! Everyone in cells. Word is there was %reason%.",
		choices = {
			{ text = "😴 Sleep through it", effects = { Health = 3 }, resultText = "Might as well rest." },
			{ text = "👂 Listen for info", effects = { Smarts = 3 }, resultText = "You picked up some gossip through the walls." },
		},
	},
	
	{
		id = "prison_shakedown",
		minAge = 14, maxAge = 100,
		weight = 25, cooldown = 8,
		emoji = "🔍", title = "Cell Shakedown",
		category = "prison",
		requiresFlag = "in_prison",
		text = "Guards are searching cells! They're looking for contraband.",
		choices = {
			{ text = "😰 Sweat it out", effects = { Happiness = -8 }, resultText = "Your cell was clean. You're safe.", clearFlag = "has_contraband" },
			{ text = "😎 Stay cool", effects = { Smarts = 3 }, resultText = "You kept your composure. Nothing found." },
		},
	},
	
	{
		id = "prison_respect_earned",
		minAge = 14, maxAge = 100,
		weight = 15, cooldown = 15,
		emoji = "🤝", title = "Earned Respect",
		category = "prison",
		requiresFlag = "in_prison",
		requiresAnyFlag = {"prison_tough", "prison_fighter", "prison_worker"},
		text = "Other inmates have started respecting you. You've earned your place.",
		choices = {
			{ text = "😌 Feel proud", effects = { Happiness = 15 }, resultText = "In here, respect means everything.", setFlag = "prison_respected" },
			{ text = "🤝 Build alliances", effects = { Happiness = 10, Smarts = 5 }, resultText = "You started making real connections." },
		},
	},
	
	{
		id = "prison_depression",
		minAge = 14, maxAge = 100,
		weight = 30, cooldown = 5,
		emoji = "😢", title = "Prison Depression",
		category = "prison",
		requiresFlag = "in_prison",
		text = "The weight of incarceration is crushing. You feel hopeless.",
		choices = {
			{ text = "😢 Let it out", effects = { Happiness = -5 }, resultText = "You cried. Sometimes you need to." },
			{ text = "💪 Stay strong", effects = { Health = -5, Smarts = 3 }, resultText = "You pushed through. But it's wearing you down." },
			{ text = "🗣️ Talk to someone", effects = { Happiness = 10 }, resultText = "Opening up helped. You're not alone." },
		},
	},
	
	{
		id = "prison_anniversary",
		minAge = 14, maxAge = 100,
		weight = 20, cooldown = 15,
		emoji = "📅", title = "Prison Anniversary",
		category = "prison",
		requiresFlag = "in_prison",
		text = "It's been a year since you arrived. Time moves strangely in here.",
		choices = {
			{ text = "😔 Reflect", effects = { Smarts = 5, Happiness = -10 }, resultText = "A year gone. How many more?" },
			{ text = "💪 Stay focused", effects = { Happiness = 3 }, resultText = "Keep your eye on release day." },
		},
	},
	
	{
		id = "prison_release_day",
		minAge = 14, maxAge = 100,
		weight = 60, milestone = true,
		emoji = "🔓", title = "RELEASE DAY!",
		category = "prison",
		requiresFlag = "in_prison",
		requiresFlag2 = "sentence_complete",
		text = "The day has finally come. You're getting out. Freedom awaits.",
		choices = {
			{ text = "🎉 Overjoyed!", effects = { Happiness = 50 }, resultText = "You walked out those gates a free person!", clearFlags = {"in_prison", "sentence_complete", "prison_gang_member", "has_contraband"}, setFlag = "ex_convict" },
			{ text = "😬 Nervous", effects = { Happiness = 30, Smarts = 5 }, resultText = "The outside world feels different. But you're free.", clearFlags = {"in_prison", "sentence_complete", "prison_gang_member", "has_contraband"}, setFlag = "ex_convict" },
		},
	},
	
	{
		id = "prison_attack_on_you",
		minAge = 14, maxAge = 80,
		weight = 12, cooldown = 10,
		emoji = "🔪", title = "Attacked!",
		category = "prison",
		requiresFlag = "in_prison",
		requiresAnyFlag = {"prison_snitch", "gang_enemy"},
		text = "You got jumped in the shower. They came for revenge.",
		choices = {
			{ text = "💪 Fight back", effects = { Health = -30, Happiness = -20 }, resultText = "You fought hard. Battered but alive." },
			{ text = "🆘 Call for guards", effects = { Health = -20, Happiness = -15 }, resultText = "Guards intervened. But you're now marked as weak." },
		},
	},
	
	{
		id = "prison_hope",
		minAge = 14, maxAge = 100,
		weight = 25, cooldown = 10,
		emoji = "🌅", title = "A Moment of Hope",
		category = "prison",
		requiresFlag = "in_prison",
		text = "Watching the sunrise through the bars, you felt something. Hope.",
		choices = {
			{ text = "🌅 Embrace it", effects = { Happiness = 15, Smarts = 3 }, resultText = "This won't last forever. Better days are coming." },
			{ text = "😔 Push it away", effects = { Happiness = -5 }, resultText = "Hope can be dangerous in here." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- FUGITIVE EVENTS - Only fire when player has fugitive flag (escaped prison)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "fugitive_close_call",
		minAge = 16, maxAge = 80,
		weight = 40, cooldown = 3,
		emoji = "🚨", title = "Close Call!",
		category = "social",
		requiresFlag = "fugitive",
		text = "You spotted a police officer nearby. Your heart pounds. Did they recognize you?",
		choices = {
			{ text = "🏃 Run!", effects = { Happiness = -10, Health = -5 }, resultText = "You bolted. Probably looked suspicious." },
			{ text = "😎 Stay calm", effects = { Smarts = 5, Happiness = 5 }, resultText = "You kept your cool. They walked right past." },
			{ text = "🧢 Hide your face", effects = { Happiness = -3 }, resultText = "You ducked behind a newspaper. Safe for now." },
		},
	},
	
	{
		id = "fugitive_paranoia",
		minAge = 16, maxAge = 100,
		weight = 35, cooldown = 5,
		emoji = "😰", title = "Paranoia Sets In",
		category = "health",
		requiresFlag = "fugitive",
		text = "Every siren makes you jump. Every stranger could be an undercover cop. The paranoia is overwhelming.",
		choices = {
			{ text = "😰 Can't take it", effects = { Happiness = -15, Health = -5 }, resultText = "Living on the run is taking its toll." },
			{ text = "💪 Stay strong", effects = { Smarts = 3, Happiness = -5 }, resultText = "You've survived this long. Keep going." },
		},
	},
	
	{
		id = "fugitive_new_identity",
		minAge = 18, maxAge = 70,
		weight = 20, cooldown = 30, oneTime = true,
		emoji = "🪪", title = "New Identity",
		category = "social",
		requiresFlag = "fugitive",
		getDynamicData = function()
			local names = {"John Smith", "Jane Doe", "Mike Johnson", "Sarah Williams", "Chris Brown"}
			return { name = names[math.random(#names)] }
		end,
		text = "A shady contact offers to get you a new identity for a price. '%name%' could be your new life.",
		choices = {
			{ text = "💵 Buy it ($5000)", effects = { Money = -5000, Happiness = 15 }, resultText = "You have a new name, new documents. A fresh start.", setFlag = "new_identity" },
			{ text = "❌ Too risky", effects = { Happiness = -5 }, resultText = "You couldn't trust them. Still on the run." },
		},
	},
	
	{
		id = "fugitive_recaptured",
		minAge = 16, maxAge = 100,
		weight = 15, cooldown = 10,
		emoji = "🔒", title = "RECAPTURED!",
		category = "crime",
		requiresFlag = "fugitive",
		blockIfFlag = "new_identity",
		text = "They found you. Police storm in, weapons drawn. 'You're under arrest!'",
		choices = {
			{ text = "🙌 Surrender", effects = { Happiness = -30 }, resultText = "You're going back to prison with extra time.", clearFlag = "fugitive", setFlags = {"in_prison", "incarcerated", "escape_recaptured"} },
			{ text = "🏃 Try to run", effects = { Health = -20, Happiness = -20 }, resultText = "They caught you anyway. Now you're hurt AND going back.", clearFlag = "fugitive", setFlags = {"in_prison", "incarcerated", "escape_recaptured"} },
		},
	},
	
	{
		id = "fugitive_safe_for_now",
		minAge = 16, maxAge = 100,
		weight = 25, cooldown = 10,
		emoji = "🏠", title = "Safe House",
		category = "social",
		requiresFlag = "fugitive",
		text = "An old friend agrees to let you lay low at their place. For now, you're safe.",
		choices = {
			{ text = "🙏 Thank them", effects = { Happiness = 20 }, resultText = "True friends are rare. This one came through." },
			{ text = "😔 Feel guilty", effects = { Happiness = 5, Smarts = 3 }, resultText = "You're putting them at risk. But you're grateful." },
		},
	},
	
	{
		id = "fugitive_news_story",
		minAge = 16, maxAge = 100,
		weight = 20, cooldown = 15,
		emoji = "📺", title = "On the News",
		category = "social",
		requiresFlag = "fugitive",
		text = "Your face is on the news. 'Police searching for escaped convict...' Your heart stops.",
		choices = {
			{ text = "😱 Panic", effects = { Happiness = -15, Health = -5 }, resultText = "The whole city is looking for you now." },
			{ text = "✂️ Change appearance", effects = { Looks = -10, Money = -100 }, resultText = "New hair, new look. Hopefully it's enough." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- EX-CONVICT EVENTS - After serving time or being released
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "excon_job_hunt",
		minAge = 18, maxAge = 70,
		weight = 40, cooldown = 5,
		emoji = "💼", title = "Job Hunt Struggles",
		category = "work",
		requiresFlag = "ex_convict",
		blockIfFlag = "in_prison",
		text = "Another job rejection. 'We don't hire people with criminal records.' It's hard out here.",
		choices = {
			{ text = "😔 Keep trying", effects = { Happiness = -10, Smarts = 3 }, resultText = "You'll find someone willing to give you a chance." },
			{ text = "😤 Get angry", effects = { Happiness = -5, Health = -3 }, resultText = "The system is rigged against people like you." },
		},
	},
	
	{
		id = "excon_redemption",
		minAge = 18, maxAge = 100,
		weight = 30, cooldown = 10,
		emoji = "🌟", title = "Second Chance",
		category = "work",
		requiresFlag = "ex_convict",
		blockIfFlag = "in_prison",
		text = "A company that hires ex-convicts wants to interview you. This could be your fresh start.",
		choices = {
			{ text = "✅ Accept interview", effects = { Happiness = 20, Smarts = 5 }, resultText = "You got the job! Someone believed in you.", setFlag = "second_chance" },
			{ text = "😒 Too good to be true", effects = { Happiness = -5 }, resultText = "You passed up a real opportunity." },
		},
	},
	
	{
		id = "excon_old_friends",
		minAge = 18, maxAge = 80,
		weight = 25, cooldown = 8,
		emoji = "👥", title = "Old Associates",
		category = "crime",
		requiresFlag = "ex_convict",
		blockIfFlag = "in_prison",
		text = "Some old 'friends' from your criminal past reach out. They have a 'job' for you.",
		choices = {
			{ text = "❌ Stay straight", effects = { Happiness = 10, Smarts = 5 }, resultText = "You've changed. That life is behind you.", setFlag = "reformed" },
			{ text = "🤔 Hear them out", effects = { Happiness = -5, Money = 500 }, resultText = "Old habits die hard. Easy money is tempting.", setFlag = "criminal_tendencies" },
		},
	},
	
	{
		id = "excon_stigma",
		minAge = 18, maxAge = 100,
		weight = 30, cooldown = 5,
		emoji = "😞", title = "The Stigma",
		category = "social",
		requiresFlag = "ex_convict",
		blockIfFlag = "in_prison",
		text = "People treat you differently when they learn about your past. The judgment hurts.",
		choices = {
			{ text = "😔 Accept it", effects = { Happiness = -10 }, resultText = "Society doesn't easily forgive." },
			{ text = "💪 Prove them wrong", effects = { Happiness = 5, Smarts = 5 }, resultText = "You'll show them you've changed.", setFlag = "determined" },
		},
	},
}

----------------------------------------------------------------------
-- MODULAR EVENT SYSTEM INTEGRATION
----------------------------------------------------------------------

-- Try to load modular events from LifeEvents system
local modularEventsLoaded = 0
local function loadModularEvents()
	-- Try multiple ways to find LifeEvents module
	local LifeEventsModule = nil
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	
	-- Method 1: Direct child of ReplicatedStorage
	local lifeEventsFolder = ReplicatedStorage:FindFirstChild("LifeEvents")
	if lifeEventsFolder then
		local success, result = pcall(function()
			return require(lifeEventsFolder)
		end)
		if success then
			LifeEventsModule = result
			print("[EventLibrary] ✅ Found LifeEvents via ReplicatedStorage:FindFirstChild")
		else
			print("[EventLibrary] ⚠️ Found LifeEvents folder but failed to require:", result)
		end
	end
	
	-- Method 2: WaitForChild with longer timeout
	if not LifeEventsModule then
		local success, result = pcall(function()
			local folder = script.Parent:WaitForChild("LifeEvents", 5)
			if folder then
				return require(folder)
			end
			return nil
		end)
		if success and result then
			LifeEventsModule = result
			print("[EventLibrary] ✅ Found LifeEvents via WaitForChild")
		end
	end
	
	-- Method 3: Try requiring directly by path
	if not LifeEventsModule then
		local success, result = pcall(function()
			return require(ReplicatedStorage.LifeEvents)
		end)
		if success then
			LifeEventsModule = result
			print("[EventLibrary] ✅ Found LifeEvents via direct path")
		end
	end
	
	-- Try backup module if main module failed
	if not LifeEventsModule then
		local success, result = pcall(function()
			return require(ReplicatedStorage:FindFirstChild("LifeEventsBackup"))
		end)
		if success and result then
			LifeEventsModule = result
			print("[EventLibrary] ✅ Found LifeEventsBackup module!")
		end
	end
	
	if LifeEventsModule then
		local modularEvents = LifeEventsModule.getEvents and LifeEventsModule.getEvents() or {}
		if modularEvents and #modularEvents > 0 then
			-- Track IDs to avoid duplicates
			local existingIds = {}
			for _, event in ipairs(events) do
				if event.id then
					existingIds[event.id] = true
				end
			end
			
			-- Add modular events that don't conflict with existing ones
			for _, event in ipairs(modularEvents) do
				if event.id and not existingIds[event.id] then
					table.insert(events, event)
					modularEventsLoaded = modularEventsLoaded + 1
				end
			end
			
			print("[EventLibrary] ✅ Loaded", modularEventsLoaded, "modular events from LifeEvents system")
			print("[EventLibrary] 📊 Total events now:", #events)
		else
			print("[EventLibrary] ⚠️ LifeEvents module found but returned no events")
		end
	else
		print("[EventLibrary] ℹ️ LifeEvents module not found - using legacy events only")
		print("[EventLibrary] 📂 Available children in ReplicatedStorage:")
		for _, child in ipairs(ReplicatedStorage:GetChildren()) do
			print("  -", child.Name, "(" .. child.ClassName .. ")")
		end
	end
end

-- Load modular events
loadModularEvents()

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

-- Expose modular system stats
EventLibrary.modularEventsLoaded = modularEventsLoaded

-- ═══════════════════════════════════════════════════════════════════════════
-- ███████████████████████████████████████████████████████████████████████████
-- TRAIT-INFLUENCED EVENTS - Events that fire based on player personality/interests
-- These create a BitLife-like experience where your choices matter!
-- ███████████████████████████████████████████████████████████████████████████
-- ═══════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════
-- CODING/TECH INTEREST EVENTS (requiresFlag = "computer_interest")
-- ═══════════════════════════════════════════════════════════════════

local codingEvents = {
	{
		id = "coding_first_program",
		minAge = 10, maxAge = 18,
		weight = 40, oneTime = true,
		emoji = "💻", title = "Your First Program!",
		category = "school",
		requiresFlag = "computer_interest",
		text = "You wrote your first real computer program! It actually works!",
		choices = {
			{ text = "💡 Build more!", effects = { Smarts = 10, Happiness = 8 }, resultText = "You're hooked! Coding is your passion now.", setFlag = "coding_natural" },
			{ text = "🎮 Make a game next", effects = { Smarts = 8, Happiness = 10 }, resultText = "You started dreaming of making video games.", setFlag = "game_dev_interest" },
			{ text = "🤔 It's cool but hard", effects = { Smarts = 5 }, resultText = "Programming is interesting but challenging." },
		},
	},
	
	{
		id = "coding_hackathon",
		minAge = 14, maxAge = 30,
		weight = 25, cooldown = 3,
		emoji = "🏆", title = "Hackathon Opportunity",
		category = "work",
		requiresFlag = "computer_interest",
		getDynamicData = function()
			local sponsors = {"Google", "Microsoft", "Amazon", "Meta", "Apple", "a local startup"}
			return { sponsor = sponsors[math.random(#sponsors)] }
		end,
		text = "%sponsor% is hosting a hackathon! Want to participate?",
		choices = {
			{ text = "💪 Let's win this!", effects = { Smarts = 8, Happiness = 5, Money = 500 }, resultText = "You impressed everyone with your skills!", setFlag = "hackathon_winner" },
			{ text = "🤝 Team up with others", effects = { Smarts = 5, Happiness = 8 }, resultText = "Great teamwork! You made some developer friends." },
			{ text = "😅 Too intimidating", effects = { Happiness = -2 }, resultText = "Maybe next time when you're more confident." },
		},
	},
	
	{
		id = "coding_job_offer_teen",
		minAge = 15, maxAge = 19,
		weight = 15, oneTime = true,
		emoji = "💰", title = "Teen Coding Prodigy!",
		category = "work",
		requiresFlag = "coding_natural",
		getDynamicData = function()
			local companies = {"a tech startup", "a local business", "a game studio", "an app company"}
			return { company = companies[math.random(#companies)] }
		end,
		text = "%company% noticed your coding skills and wants to hire you part-time!",
		choices = {
			{ text = "💵 Take the job!", effects = { Money = 5000, Smarts = 5, Happiness = 10 }, resultText = "You're making real money as a teen coder!", setFlag = "teen_coder_job" },
			{ text = "📚 Focus on school first", effects = { Smarts = 8 }, resultText = "Education first, jobs later. Smart choice." },
		},
	},
	
	{
		id = "coding_open_source",
		minAge = 16, maxAge = 40,
		weight = 20, cooldown = 5,
		emoji = "🌐", title = "Open Source Contribution",
		category = "work",
		requiresFlag = "computer_interest",
		text = "A major open source project needs contributors. Your skills could help!",
		choices = {
			{ text = "🔧 Contribute!", effects = { Smarts = 8, Happiness = 5 }, resultText = "Your code is now used by thousands!", setFlag = "open_source_contributor" },
			{ text = "🐛 Fix bugs for them", effects = { Smarts = 6, Happiness = 4 }, resultText = "The community appreciated your help." },
			{ text = "⏰ No time right now", effects = {}, resultText = "You passed on this opportunity." },
		},
	},
	
	{
		id = "coding_startup_idea",
		minAge = 18, maxAge = 40,
		weight = 15, oneTime = true,
		emoji = "💡", title = "Startup Idea!",
		category = "work",
		requiresFlag = "coding_natural",
		text = "You have an amazing idea for a tech startup! Could this be your ticket to millions?",
		choices = {
			{ text = "🚀 Go for it!", effects = { Money = -5000, Happiness = 10, Smarts = 5 }, resultText = "You started your own company!", setFlag = "tech_entrepreneur" },
			{ text = "🤔 Need more experience first", effects = { Smarts = 3 }, resultText = "You decided to learn more before taking the plunge." },
			{ text = "💼 Pitch it to investors", effects = { Smarts = 5, Money = 10000 }, resultText = "An investor loved your idea and funded it!", setFlags = {"tech_entrepreneur", "has_investor"} },
		},
	},
	
	{
		id = "coding_tech_giant_recruit",
		minAge = 20, maxAge = 50,
		weight = 12, oneTime = true,
		emoji = "🏢", title = "Big Tech Recruitment!",
		category = "work",
		requiresAnyFlag = {"coding_natural", "hackathon_winner", "open_source_contributor"},
		getDynamicData = function()
			local companies = {"Google", "Apple", "Microsoft", "Meta", "Amazon", "Netflix"}
			return { company = companies[math.random(#companies)] }
		end,
		text = "A recruiter from %company% reached out. They want YOU!",
		choices = {
			{ text = "🎯 Accept!", effects = { Money = 50000, Happiness = 15, Smarts = 5 }, resultText = "You're now working at a Big Tech company!", setFlag = "big_tech_employee" },
			{ text = "💰 Negotiate higher", effects = { Money = 80000, Happiness = 15, Smarts = 5 }, resultText = "They really wanted you. Huge signing bonus!", setFlag = "big_tech_employee" },
			{ text = "🏠 Prefer smaller company", effects = { Happiness = 5 }, resultText = "Big tech isn't for everyone." },
		},
	},
}

-- ═══════════════════════════════════════════════════════════════════
-- REBEL/TROUBLEMAKER EVENTS
-- ═══════════════════════════════════════════════════════════════════

local rebelEvents = {
	{
		id = "rebel_childhood_prank",
		minAge = 8, maxAge = 14,
		weight = 35, cooldown = 2,
		emoji = "😈", title = "Prank Time!",
		category = "school",
		text = "You have an opportunity to pull an epic prank at school.",
		choices = {
			{ text = "😈 Do it!", effects = { Happiness = 8, Smarts = -2 }, resultText = "Legendary prank! You're now infamous.", setFlag = "rebel" },
			{ text = "🤔 Too risky", effects = { Smarts = 2 }, resultText = "You played it safe. Boring but smart." },
			{ text = "🗣️ Blame someone else", effects = { Smarts = 3, Happiness = 3 }, resultText = "You got someone else in trouble. Sneaky.", setFlag = "manipulative" },
		},
	},
	
	{
		id = "rebel_skip_school",
		minAge = 12, maxAge = 18,
		weight = 30, cooldown = 2,
		emoji = "🏃", title = "Skip Day?",
		category = "school",
		requiresFlag = "rebel",
		text = "Your rebel friends want you to skip school today. Adventure awaits!",
		choices = {
			{ text = "🎢 Let's go!", effects = { Happiness = 10, Smarts = -3 }, resultText = "Best day ever! (You got detention later though)", setFlag = "frequent_skipper" },
			{ text = "📚 I should stay", effects = { Smarts = 3, Happiness = -2 }, resultText = "FOMO hit hard but you stayed responsible." },
			{ text = "😎 Organize something bigger", effects = { Happiness = 8, Smarts = 2 }, resultText = "You led a group adventure. Leadership!", setFlags = {"rebel_leader", "rebel"} },
		},
	},
	
	{
		id = "rebel_authority_clash",
		minAge = 14, maxAge = 25,
		weight = 25, cooldown = 3,
		emoji = "💢", title = "Authority Issues",
		category = "social",
		requiresFlag = "rebel",
		getDynamicData = function()
			local authorities = {"teacher", "boss", "police officer", "parent", "security guard"}
			return { authority = authorities[math.random(#authorities)] }
		end,
		text = "A %authority% is giving you a hard time. You feel your rebel spirit rising.",
		choices = {
			{ text = "🗯️ Talk back!", effects = { Happiness = 5, Smarts = -5 }, resultText = "You said what you felt. Worth it? Maybe.", setFlag = "defiant" },
			{ text = "😤 Stay calm (barely)", effects = { Smarts = 5 }, resultText = "You bit your tongue. Personal growth." },
			{ text = "🖕 Go all out", effects = { Happiness = 3, Health = -5 }, resultText = "Things escalated. You might be in trouble.", setFlags = {"defiant", "troublemaker"} },
		},
	},
	
	{
		id = "rebel_underground_scene",
		minAge = 16, maxAge = 30,
		weight = 20, cooldown = 5,
		emoji = "🎤", title = "Underground Scene",
		category = "social",
		requiresAnyFlag = {"rebel", "rebel_leader"},
		text = "You discovered an underground music/art scene. These are your people!",
		choices = {
			{ text = "🎤 Become part of it", effects = { Happiness = 12, Looks = 3 }, resultText = "You found your tribe. This is home.", setFlag = "underground_scene" },
			{ text = "🎨 Create for it", effects = { Happiness = 10, Smarts = 5 }, resultText = "You became a creator in the scene.", setFlags = {"underground_scene", "underground_artist"} },
			{ text = "🏃 Too intense", effects = { Happiness = -3 }, resultText = "It wasn't for you after all." },
		},
	},
	
	{
		id = "rebel_protest",
		minAge = 16, maxAge = 60,
		weight = 18, cooldown = 5,
		emoji = "✊", title = "Stand For Something",
		category = "social",
		requiresAnyFlag = {"rebel", "political_interest"},
		text = "There's a major protest happening. This is your chance to make a difference!",
		choices = {
			{ text = "✊ Join the front lines!", effects = { Happiness = 10, Health = -5 }, resultText = "You made your voice heard. Powerful moment.", setFlag = "activist" },
			{ text = "📢 Help organize", effects = { Smarts = 5, Happiness = 8 }, resultText = "Your organizational skills helped the cause.", setFlags = {"activist", "organizer"} },
			{ text = "📱 Support online", effects = { Happiness = 3 }, resultText = "You showed support from a distance." },
		},
	},
}

-- ═══════════════════════════════════════════════════════════════════
-- ARTISTIC EVENTS
-- ═══════════════════════════════════════════════════════════════════

local artisticEvents = {
	{
		id = "artistic_gallery_invite",
		minAge = 16, maxAge = 70,
		weight = 20, cooldown = 5,
		emoji = "🖼️", title = "Gallery Showing",
		category = "work",
		requiresFlag = "art_interest",
		text = "A local gallery wants to display your artwork!",
		choices = {
			{ text = "🎨 Show my best work!", effects = { Happiness = 12, Money = 500, Looks = 3 }, resultText = "Your art impressed everyone!", setFlag = "exhibited_artist" },
			{ text = "😰 Not ready yet", effects = { Happiness = -5 }, resultText = "You passed up a great opportunity." },
			{ text = "🖼️ Sell some pieces", effects = { Money = 2000, Happiness = 8 }, resultText = "You sold your art! People paid real money!", setFlag = "selling_artist" },
		},
	},
	
	{
		id = "artistic_commission",
		minAge = 16, maxAge = 80,
		weight = 25, cooldown = 3,
		emoji = "💰", title = "Art Commission",
		category = "work",
		requiresAnyFlag = {"art_interest", "exhibited_artist"},
		getDynamicData = function()
			local clients = {"a wealthy collector", "a business owner", "a fan online", "a friend's family"}
			local amounts = {500, 1000, 2000, 5000}
			return { client = clients[math.random(#clients)], amount = amounts[math.random(#amounts)] }
		end,
		text = "%client% wants to commission you for $%amount%!",
		choices = {
			{ text = "🎨 Accept!", effects = { Money = 0, Happiness = 8, Smarts = 3 }, resultText = "You completed the commission successfully!" },
			{ text = "💰 Negotiate higher", effects = { Money = 0, Happiness = 5 }, resultText = "You got more! Smart business sense.", setFlag = "business_savvy" },
			{ text = "🙅 Not my style", effects = { Happiness = 2 }, resultText = "You stayed true to your artistic vision." },
		},
	},
	
	{
		id = "artistic_creative_block",
		minAge = 14, maxAge = 80,
		weight = 20, cooldown = 5,
		emoji = "😔", title = "Creative Block",
		category = "health",
		requiresFlag = "art_interest",
		text = "You can't create anything. The inspiration just isn't there.",
		choices = {
			{ text = "🚶 Take a walk", effects = { Health = 3, Happiness = 2 }, resultText = "Sometimes stepping away helps." },
			{ text = "📚 Study other artists", effects = { Smarts = 5 }, resultText = "You found new inspiration in others' work!" },
			{ text = "💪 Force through it", effects = { Happiness = -5, Smarts = 3 }, resultText = "You created something... it's not your best though." },
		},
	},
}

-- ═══════════════════════════════════════════════════════════════════
-- ATHLETIC/SPORTS EVENTS
-- ═══════════════════════════════════════════════════════════════════

local athleticEvents = {
	{
		id = "athletic_talent_spotted",
		minAge = 10, maxAge = 18,
		weight = 20, oneTime = true,
		emoji = "⚽", title = "Talent Spotted!",
		category = "school",
		requiresAnyFlag = {"athletic_child", "sports_fan"},
		getDynamicData = function()
			local sports = {"basketball", "soccer", "football", "baseball", "swimming", "track"}
			return { sport = sports[math.random(#sports)] }
		end,
		text = "A %sport% coach noticed your athletic abilities!",
		choices = {
			{ text = "🏆 Train hard!", effects = { Health = 10, Happiness = 8, Looks = 3 }, resultText = "You became a star athlete!", setFlag = "star_athlete" },
			{ text = "🤔 Just for fun", effects = { Health = 5, Happiness = 5 }, resultText = "You played for enjoyment, not competition." },
			{ text = "📚 Focus on school", effects = { Smarts = 5 }, resultText = "Academics over athletics for you." },
		},
	},
	
	{
		id = "athletic_scholarship",
		minAge = 17, maxAge = 19,
		weight = 15, oneTime = true,
		emoji = "🎓", title = "Athletic Scholarship!",
		category = "school",
		requiresFlag = "star_athlete",
		getDynamicData = function()
			local schools = {"State University", "Tech Institute", "Coastal College", "Mountain University"}
			return { school = schools[math.random(#schools)] }
		end,
		text = "%school% is offering you a full athletic scholarship!",
		choices = {
			{ text = "🎓 Accept!", effects = { Happiness = 15, Smarts = 5 }, resultText = "Free college! Your athletic career continues!", setFlag = "college_athlete" },
			{ text = "🤔 Want to explore options", effects = { Smarts = 3 }, resultText = "You kept your options open." },
		},
	},
	
	{
		id = "athletic_injury",
		minAge = 14, maxAge = 50,
		weight = 15, cooldown = 5,
		emoji = "🤕", title = "Sports Injury",
		category = "health",
		requiresAnyFlag = {"athletic_child", "star_athlete", "college_athlete"},
		getDynamicData = function()
			local injuries = {"knee injury", "sprained ankle", "shoulder tear", "concussion", "muscle strain"}
			return { injury = injuries[math.random(#injuries)] }
		end,
		text = "You suffered a %injury% during practice!",
		choices = {
			{ text = "💪 Push through", effects = { Health = -15, Happiness = -5 }, resultText = "Playing through pain. Risky.", setFlag = "plays_through_pain" },
			{ text = "🏥 Rest and recover", effects = { Health = -5, Happiness = -3 }, resultText = "You took time to heal properly." },
			{ text = "🔬 Get surgery", effects = { Health = 5, Money = -5000 }, resultText = "The surgery was successful. You'll be back." },
		},
	},
	
	{
		id = "athletic_pro_tryout",
		minAge = 18, maxAge = 30,
		weight = 10, oneTime = true,
		emoji = "🏟️", title = "Pro Tryout!",
		category = "work",
		requiresAnyFlag = {"star_athlete", "college_athlete"},
		getDynamicData = function()
			local teams = {"a professional team", "a minor league team", "an overseas team"}
			return { team = teams[math.random(#teams)] }
		end,
		text = "%team% invited you to try out!",
		choices = {
			{ text = "💪 Give it your all!", effects = { Health = 5, Happiness = 15, Money = 50000 }, resultText = "You made the team! You're a pro!", setFlag = "pro_athlete" },
			{ text = "😰 Too nervous", effects = { Happiness = -10 }, resultText = "You choked under pressure." },
		},
	},
}

-- ═══════════════════════════════════════════════════════════════════
-- BOOKWORM/INTELLECTUAL EVENTS
-- ═══════════════════════════════════════════════════════════════════

local intellectualEvents = {
	{
		id = "intellectual_debate_team",
		minAge = 14, maxAge = 22,
		weight = 25, oneTime = true,
		emoji = "🎤", title = "Debate Team",
		category = "school",
		requiresAnyFlag = {"bookworm", "studious"},
		text = "The debate team needs new members. Your intellect could be an asset!",
		choices = {
			{ text = "🎤 Join!", effects = { Smarts = 8, Happiness = 5 }, resultText = "You became a skilled debater!", setFlag = "debate_champion" },
			{ text = "✍️ Prefer writing", effects = { Smarts = 5, Happiness = 3 }, resultText = "You'd rather express yourself in writing." },
			{ text = "🙅 Too competitive", effects = { Happiness = 2 }, resultText = "Not your scene." },
		},
	},
	
	{
		id = "intellectual_publish",
		minAge = 18, maxAge = 80,
		weight = 15, cooldown = 8,
		emoji = "📖", title = "Publishing Opportunity",
		category = "work",
		requiresAnyFlag = {"bookworm", "writer_interest"},
		getDynamicData = function()
			local genres = {"novel", "short story collection", "memoir", "research paper"}
			return { type = genres[math.random(#genres)] }
		end,
		text = "A publisher is interested in your %type%!",
		choices = {
			{ text = "📝 Submit it!", effects = { Smarts = 5, Money = 5000, Happiness = 12 }, resultText = "You're a published author!", setFlag = "published_author" },
			{ text = "🔄 Needs more work", effects = { Smarts = 3 }, resultText = "You're perfecting your craft." },
			{ text = "😰 Not ready to share", effects = { Happiness = -3 }, resultText = "Putting yourself out there is scary." },
		},
	},
	
	{
		id = "intellectual_scholarship_academic",
		minAge = 17, maxAge = 19,
		weight = 20, oneTime = true,
		emoji = "🎓", title = "Academic Scholarship!",
		category = "school",
		requiresAnyFlag = {"studious", "bookworm", "science_interest"},
		getDynamicData = function()
			local schools = {"Harvard", "MIT", "Stanford", "Yale", "Princeton", "Caltech"}
			return { school = schools[math.random(#schools)] }
		end,
		text = "%school% is offering you an academic scholarship!",
		choices = {
			{ text = "🎓 Accept!", effects = { Happiness = 15, Smarts = 10 }, resultText = "Elite education awaits!", setFlags = {"ivy_league", "college_student"} },
			{ text = "🏠 Stay closer to home", effects = { Happiness = 5, Smarts = 5 }, resultText = "You chose a local school instead." },
		},
	},
}

-- ═══════════════════════════════════════════════════════════════════
-- SOCIAL BUTTERFLY / INFLUENCER EVENTS  
-- ═══════════════════════════════════════════════════════════════════

local socialEvents = {
	{
		id = "social_popular_kid",
		minAge = 12, maxAge = 18,
		weight = 25, oneTime = true,
		emoji = "⭐", title = "Rising Popularity",
		category = "social",
		requiresFlag = "social_butterfly",
		text = "You're becoming one of the popular kids at school!",
		choices = {
			{ text = "👑 Embrace it!", effects = { Happiness = 10, Looks = 3 }, resultText = "You're officially popular!", setFlag = "popular_kid" },
			{ text = "🤝 Stay grounded", effects = { Happiness = 5, Smarts = 3 }, resultText = "You stayed humble despite your popularity." },
			{ text = "🙅 Don't care about popularity", effects = { Smarts = 5 }, resultText = "You valued authenticity over popularity." },
		},
	},
	
	{
		id = "social_viral_moment",
		minAge = 13, maxAge = 40,
		weight = 15, oneTime = true,
		emoji = "📱", title = "Going Viral!",
		category = "social",
		requiresAnyFlag = {"social_butterfly", "performer", "popular_kid"},
		text = "Something you posted went VIRAL! Millions of views overnight!",
		choices = {
			{ text = "🌟 Build on this!", effects = { Happiness = 15, Money = 1000, Looks = 5 }, resultText = "You gained a massive following!", setFlag = "social_media_famous" },
			{ text = "😅 It's overwhelming", effects = { Happiness = 5 }, resultText = "15 minutes of fame was enough." },
			{ text = "💰 Monetize it!", effects = { Money = 5000, Happiness = 8 }, resultText = "Brand deals started rolling in!", setFlags = {"social_media_famous", "influencer"} },
		},
	},
	
	{
		id = "social_influencer_brand",
		minAge = 16, maxAge = 50,
		weight = 15, cooldown = 5,
		emoji = "💰", title = "Brand Partnership",
		category = "work",
		requiresAnyFlag = {"social_media_famous", "influencer"},
		getDynamicData = function()
			local brands = {"Fashion Nova", "Gymshark", "Audible", "NordVPN", "a gaming company", "a beauty brand"}
			local amounts = {1000, 5000, 10000, 25000}
			return { brand = brands[math.random(#brands)], amount = amounts[math.random(#amounts)] }
		end,
		text = "%brand% wants you to promote them for $%amount%!",
		choices = {
			{ text = "💰 Take the deal!", effects = { Money = 0, Happiness = 5 }, resultText = "Easy money for a few posts!" },
			{ text = "💰 Negotiate higher", effects = { Money = 0, Happiness = 8, Smarts = 3 }, resultText = "You got more! Know your worth.", setFlag = "business_savvy" },
			{ text = "🙅 Not my brand", effects = { Happiness = 3 }, resultText = "You stayed authentic to your audience." },
		},
	},
}

-- ═══════════════════════════════════════════════════════════════════
-- MUSICAL EVENTS
-- ═══════════════════════════════════════════════════════════════════

local musicalEvents = {
	{
		id = "music_band_form",
		minAge = 14, maxAge = 30,
		weight = 20, oneTime = true,
		emoji = "🎸", title = "Start a Band?",
		category = "social",
		requiresFlag = "musician",
		getDynamicData = function()
			local genres = {"rock", "pop", "metal", "indie", "punk", "hip-hop"}
			return { genre = genres[math.random(#genres)] }
		end,
		text = "Some friends want to start a %genre% band with you!",
		choices = {
			{ text = "🎸 Let's rock!", effects = { Happiness = 12, Looks = 3 }, resultText = "You formed a band!", setFlag = "in_a_band" },
			{ text = "🎹 Prefer solo", effects = { Happiness = 5, Smarts = 3 }, resultText = "You continued your solo musical journey." },
			{ text = "⏰ No time right now", effects = { Happiness = -3 }, resultText = "You missed out on a fun opportunity." },
		},
	},
	
	{
		id = "music_gig_offer",
		minAge = 16, maxAge = 50,
		weight = 18, cooldown = 3,
		emoji = "🎤", title = "Gig Opportunity!",
		category = "work",
		requiresAnyFlag = {"musician", "in_a_band", "performer"},
		getDynamicData = function()
			local venues = {"a local bar", "a coffee shop", "a festival", "a club", "a wedding"}
			local pays = {100, 300, 500, 1000}
			return { venue = venues[math.random(#venues)], pay = pays[math.random(#pays)] }
		end,
		text = "You got offered to perform at %venue% for $%pay%!",
		choices = {
			{ text = "🎤 Perform!", effects = { Money = 0, Happiness = 10, Looks = 2 }, resultText = "Great performance! The crowd loved you!", setFlag = "gigging_musician" },
			{ text = "😰 Stage fright", effects = { Happiness = -5 }, resultText = "You couldn't bring yourself to perform." },
		},
	},
	
	{
		id = "music_record_deal",
		minAge = 18, maxAge = 45,
		weight = 8, oneTime = true,
		emoji = "📀", title = "Record Deal!",
		category = "work",
		requiresAnyFlag = {"gigging_musician", "in_a_band", "social_media_famous"},
		getDynamicData = function()
			local labels = {"a major label", "an indie label", "a hip-hop label", "a streaming platform"}
			return { label = labels[math.random(#labels)] }
		end,
		text = "%label% wants to sign you to a record deal!",
		choices = {
			{ text = "✍️ Sign!", effects = { Money = 25000, Happiness = 20 }, resultText = "You're a signed artist! Dreams coming true!", setFlag = "signed_musician" },
			{ text = "📜 Read the fine print", effects = { Smarts = 5, Money = 35000, Happiness = 15 }, resultText = "Good call! You negotiated better terms.", setFlags = {"signed_musician", "business_savvy"} },
			{ text = "🎤 Stay independent", effects = { Happiness = 5 }, resultText = "You valued creative freedom over fame." },
		},
	},
}

-- ═══════════════════════════════════════════════════════════════════
-- CRIMINAL CAREER PATHS (Roblox-appropriate)
-- Gun Dealer, Car Thief, House Robber paths
-- ═══════════════════════════════════════════════════════════════════

local criminalCareerEvents = {
	-- ===============================
	-- CAR THIEF CAREER PATH
	-- ===============================
	{
		id = "car_thief_start",
		minAge = 16, maxAge = 35,
		weight = 20, oneTime = true,
		emoji = "🚗", title = "Chop Shop Introduction",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return (f.criminal_tendencies or f.gang_member) and not f.car_thief_career
		end,
		text = "A shady contact knows someone who runs a chop shop. They need people who can 'acquire' vehicles.",
		choices = {
			{ text = "🚗 I'm interested", effects = { Happiness = 5, Smarts = 3 }, resultText = "You're now connected to the car theft ring.", setFlags = {"car_thief_career", "connected"} },
			{ text = "🚫 Too risky", effects = { Smarts = 3 }, resultText = "You stayed away from that life." },
		},
	},
	
	{
		id = "car_thief_first_job",
		minAge = 16, maxAge = 50,
		weight = 25, cooldown = 3,
		emoji = "🔑", title = "First Vehicle Acquisition",
		category = "crime",
		requiresFlag = "car_thief_career",
		blockIfFlag = "in_prison",
		getDynamicData = function()
			local cars = {"Honda Civic", "Toyota Camry", "Ford Mustang", "BMW 3 Series", "pickup truck"}
			return { car = cars[math.random(#cars)] }
		end,
		text = "Your contact has a target: a %car% parked in a quiet neighborhood.",
		choices = {
			{ text = "🔓 Steal it", effects = { Money = 3000, Happiness = 5 }, resultText = "You delivered the car to the chop shop. Easy money!", minigame = "heist" },
			{ text = "👀 Scout first", effects = { Money = 2000, Smarts = 5 }, resultText = "Your careful approach paid off. Clean job.", setFlag = "careful_thief" },
			{ text = "⏭️ Pass on this one", effects = {}, resultText = "You waited for a better opportunity." },
		},
	},
	
	{
		id = "car_thief_luxury",
		minAge = 18, maxAge = 50,
		weight = 15, cooldown = 5,
		emoji = "🏎️", title = "Luxury Target",
		category = "crime",
		requiresFlag = "car_thief_career",
		blockIfFlag = "in_prison",
		getDynamicData = function()
			local cars = {"Porsche 911", "Mercedes AMG", "Tesla Model S", "Range Rover", "Lamborghini"}
			return { car = cars[math.random(#cars)] }
		end,
		text = "A %car% spotted outside an upscale restaurant. High risk, high reward.",
		choices = {
			{ text = "🏎️ Go for it!", effects = { Money = 25000, Happiness = 10 }, resultText = "Jackpot! The chop shop paid top dollar!", setFlag = "luxury_thief", minigame = "heist" },
			{ text = "🎯 Need better intel", effects = { Smarts = 3 }, resultText = "You passed. Luxury cars have better security." },
		},
	},
	
	{
		id = "car_thief_ring_promotion",
		minAge = 20, maxAge = 55,
		weight = 10, oneTime = true,
		emoji = "👔", title = "Moving Up",
		category = "crime",
		requiresFlag = "car_thief_career",
		requiresFlag2 = "luxury_thief",
		blockIfFlag = "in_prison",
		text = "The chop shop boss is impressed. They want you to recruit and manage a crew.",
		choices = {
			{ text = "👔 Accept the promotion", effects = { Money = 10000, Happiness = 12, Smarts = 5 }, resultText = "You're now running your own crew!", setFlags = {"car_ring_leader", "crew_boss"} },
			{ text = "🚗 Prefer solo work", effects = { Money = 5000 }, resultText = "You stayed a lone wolf operator." },
		},
	},
	
	-- ===============================
	-- HOUSE ROBBER CAREER PATH  
	-- ===============================
	{
		id = "burglary_start",
		minAge = 16, maxAge = 40,
		weight = 20, oneTime = true,
		emoji = "🏠", title = "Breaking & Entering",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return (f.criminal_tendencies or f.petty_thief) and not f.burglar_career
		end,
		text = "A friend tells you about houses that are easy targets. Empty homes with valuable stuff.",
		choices = {
			{ text = "🏠 Show me", effects = { Smarts = 3, Happiness = 3 }, resultText = "You learned the basics of residential burglary.", setFlags = {"burglar_career", "knows_targets"} },
			{ text = "🚫 Not interested", effects = { Smarts = 2 }, resultText = "You drew the line at breaking into homes." },
		},
	},
	
	{
		id = "burglary_job",
		minAge = 16, maxAge = 55,
		weight = 25, cooldown = 2,
		emoji = "🔦", title = "Night Job",
		category = "crime",
		requiresFlag = "burglar_career",
		blockIfFlag = "in_prison",
		getDynamicData = function()
			local items = {"jewelry", "electronics", "designer items", "collectibles", "cash stash"}
			return { items = items[math.random(#items)] }
		end,
		text = "You found a house where the owners are on vacation. Intel says they have %items%.",
		choices = {
			{ text = "🌙 Hit it tonight", effects = { Money = 4000, Happiness = 5 }, resultText = "You got in and out clean with the goods!", minigame = "heist" },
			{ text = "🕵️ Watch for a week", effects = { Money = 5500, Smarts = 5, Happiness = 3 }, resultText = "Your patience paid off. Perfect timing.", setFlag = "patient_burglar" },
			{ text = "⏭️ Bad feeling", effects = {}, resultText = "You trusted your gut and passed." },
		},
	},
	
	{
		id = "burglary_mansion",
		minAge = 20, maxAge = 55,
		weight = 12, cooldown = 8,
		emoji = "🏰", title = "The Big Score",
		category = "crime",
		requiresFlag = "burglar_career",
		requiresAnyFlag = {"patient_burglar", "master_thief"},
		blockIfFlag = "in_prison",
		text = "A mansion in the hills. Rich owner, minimal security, gone for a month. This could set you up for life.",
		choices = {
			{ text = "🏰 Go for the big score!", effects = { Money = 100000, Happiness = 20 }, resultText = "MASSIVE haul! You're set for a while!", setFlag = "mansion_heist", minigame = "heist" },
			{ text = "🎯 Need a crew", effects = { Money = 75000, Happiness = 15 }, resultText = "Your crew helped pull it off. Split the take.", setFlags = {"mansion_heist", "has_crew"} },
			{ text = "🚫 Too ambitious", effects = { Smarts = 5 }, resultText = "Mansions have surprises. Smart to pass." },
		},
	},
	
	{
		id = "burglary_fence_connection",
		minAge = 18, maxAge = 55,
		weight = 15, oneTime = true,
		emoji = "🤝", title = "Meet the Fence",
		category = "crime",
		requiresFlag = "burglar_career",
		blockIfFlag = "in_prison",
		getDynamicData = function()
			local names = {"Rico", "Snake", "Ghost", "Diamond", "Vex"}
			return { fenceName = names[math.random(#names)] }
		end,
		text = "%fenceName% is a high-end fence who pays 70% of value instead of the usual 30%. Want an introduction?",
		choices = {
			{ text = "🤝 Get me connected", effects = { Happiness = 8, Smarts = 5 }, resultText = "Now you have a premium fence contact!", setFlag = "premium_fence" },
			{ text = "🚫 Don't trust new people", effects = { Smarts = 3 }, resultText = "You stuck with your current connections." },
		},
	},
	
	-- ===============================
	-- GUN DEALER CAREER PATH (Roblox-appropriate: focuses on "replica" and "collectible" angle)
	-- ===============================
	{
		id = "collector_dealer_start",
		minAge = 18, maxAge = 50,
		weight = 15, oneTime = true,
		emoji = "🎯", title = "Underground Market",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return (f.gang_member or f.criminal_tendencies or f.connected) and not f.dealer_career
		end,
		text = "Someone approaches you about selling 'collectible items' on the underground market. Very profitable.",
		choices = {
			{ text = "💰 Tell me more", effects = { Smarts = 5 }, resultText = "You learned about the underground collectibles trade.", setFlags = {"dealer_career", "underground_trader"} },
			{ text = "🚫 Stay out of it", effects = { Smarts = 3 }, resultText = "You wanted nothing to do with that world." },
		},
	},
	
	{
		id = "dealer_first_sale",
		minAge = 18, maxAge = 60,
		weight = 20, cooldown = 3,
		emoji = "📦", title = "First Client",
		category = "crime",
		requiresFlag = "dealer_career",
		blockIfFlag = "in_prison",
		text = "A client wants to buy some 'collectibles'. Standard deal, nothing too risky.",
		choices = {
			{ text = "📦 Make the deal", effects = { Money = 5000, Happiness = 5 }, resultText = "Smooth transaction. Easy money." },
			{ text = "💰 Charge premium", effects = { Money = 7000, Happiness = 3 }, resultText = "You upsold them. Good business.", setFlag = "shrewd_dealer" },
			{ text = "⏭️ Bad vibes", effects = {}, resultText = "Something felt off. You passed." },
		},
	},
	
	{
		id = "dealer_bulk_opportunity",
		minAge = 20, maxAge = 55,
		weight = 12, cooldown = 8,
		emoji = "📈", title = "Bulk Order",
		category = "crime",
		requiresFlag = "dealer_career",
		blockIfFlag = "in_prison",
		text = "A big buyer wants a large quantity. Massive payout but higher exposure.",
		choices = {
			{ text = "📦 Take the order", effects = { Money = 50000, Happiness = 10 }, resultText = "Huge payout! But you're now on the radar.", setFlags = {"big_dealer", "high_profile"} },
			{ text = "🎯 Counter with smaller deal", effects = { Money = 20000, Happiness = 8 }, resultText = "You kept things manageable. Smart.", setFlag = "cautious_dealer" },
			{ text = "🚫 Too risky", effects = { Smarts = 5 }, resultText = "Bulk deals attract attention. You passed." },
		},
	},
	
	{
		id = "dealer_territory",
		minAge = 22, maxAge = 55,
		weight = 10, oneTime = true,
		emoji = "🗺️", title = "Expand Territory",
		category = "crime",
		requiresFlag = "big_dealer",
		blockIfFlag = "in_prison",
		text = "You could expand your operation to neighboring areas. More profit, more risk.",
		choices = {
			{ text = "🗺️ Expand operations", effects = { Money = 30000, Happiness = 10 }, resultText = "Your network now spans multiple areas!", setFlag = "territory_boss" },
			{ text = "🏠 Stay local", effects = { Money = 10000, Smarts = 3 }, resultText = "You kept things contained. Lower profile." },
		},
	},
}

-- ═══════════════════════════════════════════════════════════════════
-- HACKER JOB CAREER EVENTS (With typing minigame!)
-- Ethical and Unethical paths
-- ═══════════════════════════════════════════════════════════════════

local hackerJobEvents = {
	-- ===============================
	-- ETHICAL HACKER PATH
	-- ===============================
	{
		id = "ethical_hacker_job_offer",
		minAge = 18, maxAge = 45,
		weight = 18, oneTime = true,
		emoji = "🛡️", title = "Cybersecurity Job Offer",
		category = "work",
		requires = function(state)
			local f = state.Flags or {}
			return (f.white_hat or f.programmer or f.computer_interest) and not f.hacker_job
		end,
		getDynamicData = function()
			local companies = {"SecureNet Inc", "CyberGuard Corp", "Digital Fortress", "TrustShield", "ByteArmor"}
			local salaries = {65000, 75000, 85000, 95000}
			return { company = companies[math.random(#companies)], salary = salaries[math.random(#salaries)] }
		end,
		text = "%company% is hiring ethical hackers! Starting salary: $%salary%/year.",
		choices = {
			{ text = "🛡️ Apply now!", effects = { Happiness = 12, Money = 0 }, resultText = "You got the job! Time to protect systems.", setFlags = {"hacker_job", "ethical_hacker_job", "employed"}, minigame = "hacking" },
			{ text = "📚 Need more training", effects = { Smarts = 5 }, resultText = "You decided to improve your skills first." },
			{ text = "💰 Want higher pay", effects = {}, resultText = "You'll wait for a better offer." },
		},
	},
	
	{
		id = "ethical_hacker_pentest",
		minAge = 18, maxAge = 60,
		weight = 25, cooldown = 2,
		emoji = "🔍", title = "Penetration Test Assignment",
		category = "work",
		requiresFlag = "ethical_hacker_job",
		getDynamicData = function()
			local clients = {"a major bank", "a hospital network", "a government agency", "a tech startup", "an e-commerce site"}
			local bounties = {2000, 5000, 10000, 15000}
			return { client = clients[math.random(#clients)], bounty = bounties[math.random(#bounties)] }
		end,
		text = "Your company assigned you to test %client%'s security. Bonus potential: $%bounty%.",
		choices = {
			{ text = "💻 Begin penetration test", effects = { Money = 0, Smarts = 5 }, resultText = "You found several vulnerabilities!", minigame = "hacking" },
			{ text = "📝 Document approach first", effects = { Smarts = 8, Money = 0 }, resultText = "Your thorough documentation impressed the client!" },
		},
	},
	
	{
		id = "ethical_hacker_bug_bounty",
		minAge = 16, maxAge = 60,
		weight = 22, cooldown = 3,
		emoji = "🐛", title = "Bug Bounty Hunt",
		category = "work",
		requiresAnyFlag = {"white_hat", "ethical_hacker_job", "computer_interest"},
		getDynamicData = function()
			local companies = {"Google", "Facebook", "Microsoft", "Apple", "Tesla", "Uber"}
			local bounties = {500, 1000, 5000, 10000, 25000}
			return { company = companies[math.random(#companies)], bounty = bounties[math.random(#bounties)] }
		end,
		text = "%company% has a bug bounty program. Find a vulnerability and earn up to $%bounty%!",
		choices = {
			{ text = "🐛 Hunt for bugs!", effects = { Smarts = 5, Money = 0, Happiness = 8 }, resultText = "You found a critical vulnerability!", setFlag = "bug_hunter", minigame = "hacking" },
			{ text = "⏭️ Not worth the time", effects = {}, resultText = "You passed on the opportunity." },
		},
	},
	
	{
		id = "ethical_hacker_promotion",
		minAge = 22, maxAge = 55,
		weight = 12, oneTime = true,
		emoji = "📈", title = "Senior Security Position",
		category = "work",
		requiresFlag = "ethical_hacker_job",
		requiresFlag2 = "bug_hunter",
		text = "Your work has been exceptional. They're promoting you to Senior Security Analyst!",
		choices = {
			{ text = "📈 Accept promotion!", effects = { Money = 25000, Happiness = 15, Smarts = 5 }, resultText = "You're now a senior security professional!", setFlag = "senior_hacker" },
			{ text = "🏢 Start own firm", effects = { Money = -10000, Happiness = 10 }, resultText = "You launched your own cybersecurity consultancy!", setFlags = {"security_founder", "entrepreneur"} },
		},
	},
	
	{
		id = "ethical_hacker_zero_day",
		minAge = 20, maxAge = 60,
		weight = 8, oneTime = true,
		emoji = "💎", title = "Zero-Day Discovery!",
		category = "work",
		requiresAnyFlag = {"senior_hacker", "elite_hacker", "bug_hunter"},
		getDynamicData = function()
			local systems = {"Windows", "iOS", "Android", "Chrome", "Linux kernel"}
			return { system = systems[math.random(#systems)] }
		end,
		text = "You discovered a zero-day vulnerability in %system%! This is HUGE.",
		choices = {
			{ text = "🏛️ Report responsibly", effects = { Money = 100000, Happiness = 20, Smarts = 10 }, resultText = "Massive bounty! You're a legend in the security community!", setFlags = {"zero_day_finder", "famous_hacker"} },
			{ text = "💰 Sell to highest bidder", effects = { Money = 500000, Happiness = 10 }, resultText = "You sold it on the dark market. Risky but lucrative.", setFlags = {"sold_zero_day", "gray_hat"}, clearFlag = "white_hat" },
		},
	},
	
	-- ===============================
	-- UNETHICAL HACKER PATH (Black Hat)
	-- ===============================
	{
		id = "blackhat_first_hack",
		minAge = 14, maxAge = 40,
		weight = 20, oneTime = true,
		emoji = "💀", title = "Dark Side Temptation",
		category = "crime",
		requires = function(state)
			local f = state.Flags or {}
			return (f.black_hat or f.hacker_skills or f.computer_interest) and not f.blackhat_career
		end,
		text = "Someone on a hacker forum is offering to pay for 'services'. This isn't ethical, but it's money.",
		choices = {
			{ text = "💀 Take the job", effects = { Money = 2000, Happiness = 5 }, resultText = "You crossed a line. Welcome to the dark side.", setFlags = {"blackhat_career", "black_hat"}, minigame = "hacking" },
			{ text = "🛡️ Stay ethical", effects = { Smarts = 5, Happiness = 3 }, resultText = "You maintained your principles.", setFlag = "white_hat" },
		},
	},
	
	{
		id = "blackhat_corporate_hack",
		minAge = 16, maxAge = 55,
		weight = 18, cooldown = 4,
		emoji = "🏢", title = "Corporate Target",
		category = "crime",
		requiresFlag = "blackhat_career",
		blockIfFlag = "in_prison",
		getDynamicData = function()
			local companies = {"MegaCorp", "GlobalTech", "DataHoard Inc", "InfoSystems", "TechGiant"}
			local payouts = {10000, 25000, 50000, 75000}
			return { company = companies[math.random(#companies)], payout = payouts[math.random(#payouts)] }
		end,
		text = "A client wants data from %company%. They're paying $%payout% for the job.",
		choices = {
			{ text = "💻 Hack them", effects = { Money = 0, Happiness = 5 }, resultText = "You breached their systems and extracted the data!", minigame = "hacking" },
			{ text = "💰 Demand more", effects = { Money = 0, Happiness = 3 }, resultText = "You negotiated a higher fee.", setFlag = "shrewd_blackhat" },
			{ text = "⏭️ Too risky", effects = { Smarts = 3 }, resultText = "You passed on this one." },
		},
	},
	
	{
		id = "blackhat_ransomware",
		minAge = 18, maxAge = 50,
		weight = 12, cooldown = 8,
		emoji = "🔐", title = "Ransomware Operation",
		category = "crime",
		requiresFlag = "blackhat_career",
		blockIfFlag = "in_prison",
		text = "You could deploy ransomware and demand crypto payments. VERY illegal but potentially huge money.",
		choices = {
			{ text = "🔐 Deploy ransomware", effects = { Money = 200000, Happiness = 5, Smarts = -5 }, resultText = "Several companies paid up. You're now a serious cybercriminal.", setFlags = {"ransomware_operator", "high_priority_target"}, minigame = "hacking" },
			{ text = "💰 Just steal data", effects = { Money = 50000, Happiness = 3 }, resultText = "You stuck to data theft. Less heat.", minigame = "hacking" },
			{ text = "🚫 Way too dangerous", effects = { Smarts = 5 }, resultText = "Ransomware attracts federal attention. Smart to avoid." },
		},
	},
	
	{
		id = "blackhat_collective_invite",
		minAge = 18, maxAge = 45,
		weight = 10, oneTime = true,
		emoji = "👥", title = "Hacker Collective Invite",
		category = "crime",
		requiresFlag = "blackhat_career",
		blockIfFlag = "in_prison",
		getDynamicData = function()
			local groups = {"Shadow Collective", "Binary Ghosts", "Zero Day Syndicate", "Phantom Hackers", "Dark Network"}
			return { group = groups[math.random(#groups)] }
		end,
		text = "The infamous %group% wants you to join. They only recruit the best.",
		choices = {
			{ text = "👥 Join them", effects = { Happiness = 15, Smarts = 10 }, resultText = "You're now part of an elite hacking collective!", setFlags = {"hacker_collective", "elite_hacker"} },
			{ text = "🐺 Work alone", effects = { Happiness = 5 }, resultText = "You preferred to stay independent." },
		},
	},
	
	{
		id = "blackhat_feds_hunting",
		minAge = 18, maxAge = 60,
		weight = 15, cooldown = 5,
		emoji = "🚨", title = "Feds Are Hunting You",
		category = "crime",
		requiresAnyFlag = {"ransomware_operator", "hacked_government", "high_priority_target"},
		blockIfFlag = "in_prison",
		getDynamicData = function()
			local agents = {"Agent Smith", "Agent Chen", "Agent Williams", "Agent Kumar"}
			return { agent = agents[math.random(#agents)] }
		end,
		text = "FBI Cyber Division is closing in. %agent% has been assigned to your case.",
		choices = {
			{ text = "💻 Cover your tracks", effects = { Smarts = 10, Happiness = -5 }, resultText = "You erased your digital footprint. For now.", minigame = "hacking" },
			{ text = "🏃 Go dark completely", effects = { Happiness = -15, Money = -10000 }, resultText = "You abandoned everything and disappeared." },
			{ text = "🔄 Become an informant", effects = { Happiness = 5, Money = 25000 }, resultText = "You cut a deal. Immunity for information.", setFlag = "fbi_informant", clearFlags = {"blackhat_career", "hacker_collective"} },
		},
	},
	
	-- ===============================
	-- HACKER WORK EVENTS (Random gigs for any hacker)
	-- ===============================
	{
		id = "hacker_freelance_gig",
		minAge = 16, maxAge = 60,
		weight = 30, cooldown = 2,
		emoji = "💻", title = "Freelance Hack Job",
		category = "work",
		requiresAnyFlag = {"hacker_job", "blackhat_career", "hacker_skills", "computer_interest"},
		blockIfFlag = "in_prison",
		getDynamicData = function()
			local jobs = {"recover a lost password", "test website security", "find data online", "unlock a device", "trace a scammer"}
			local pays = {200, 500, 1000, 2000, 3000}
			return { job = jobs[math.random(#jobs)], pay = pays[math.random(#pays)] }
		end,
		text = "Someone needs you to %job%. They're offering $%pay%.",
		choices = {
			{ text = "💻 Take the job", effects = { Money = 0, Happiness = 5, Smarts = 3 }, resultText = "Job completed successfully!", minigame = "hacking" },
			{ text = "⏭️ Not interested", effects = {}, resultText = "You passed on this one." },
		},
	},
	
	{
		id = "hacker_crypto_recovery",
		minAge = 18, maxAge = 60,
		weight = 15, cooldown = 5,
		emoji = "₿", title = "Crypto Recovery Job",
		category = "work",
		requiresAnyFlag = {"hacker_job", "blackhat_career", "elite_hacker"},
		blockIfFlag = "in_prison",
		getDynamicData = function()
			local amounts = {5000, 25000, 100000, 500000}
			return { cryptoValue = amounts[math.random(#amounts)] }
		end,
		text = "A client lost access to a crypto wallet worth $%cryptoValue%. They'll pay 20% if you can recover it.",
		choices = {
			{ text = "💻 Attempt recovery", effects = { Money = 0, Smarts = 8 }, resultText = "You recovered the wallet! Huge payday!", minigame = "hacking" },
			{ text = "📚 Research first", effects = { Smarts = 5 }, resultText = "You studied the problem. Might take longer but more likely to succeed." },
			{ text = "⏭️ Too complicated", effects = {}, resultText = "This was beyond your expertise." },
		},
	},
}

-- Add criminal career events to main table
for _, event in ipairs(criminalCareerEvents) do
	table.insert(events, event)
end
print("[EventLibrary] Added", #criminalCareerEvents, "criminal career events!")

-- Add hacker job events to main table
for _, event in ipairs(hackerJobEvents) do
	table.insert(events, event)
end
print("[EventLibrary] Added", #hackerJobEvents, "hacker job events!")

-- Add all trait events to the main events table
for _, event in ipairs(codingEvents) do
	table.insert(events, event)
end
for _, event in ipairs(rebelEvents) do
	table.insert(events, event)
end
for _, event in ipairs(artisticEvents) do
	table.insert(events, event)
end
for _, event in ipairs(athleticEvents) do
	table.insert(events, event)
end
for _, event in ipairs(intellectualEvents) do
	table.insert(events, event)
end
for _, event in ipairs(socialEvents) do
	table.insert(events, event)
end
for _, event in ipairs(musicalEvents) do
	table.insert(events, event)
end

print("[EventLibrary] Added", #codingEvents + #rebelEvents + #artisticEvents + #athleticEvents + #intellectualEvents + #socialEvents + #musicalEvents, "trait-influenced events!")

-- ═══════════════════════════════════════════════════════════════════
-- EXPANDED BEGINNING OF LIFE EVENTS (Ages 0-5)
-- More variety for early childhood!
-- ═══════════════════════════════════════════════════════════════════

local earlyLifeEvents = {
	-- ═══════════════════════════════════════════════════════════
	-- INFANT EVENTS (0-1)
	-- ═══════════════════════════════════════════════════════════
	{
		id = "baby_hiccups",
		minAge = 0, maxAge = 1,
		weight = 40, cooldown = 3,
		emoji = "🤭", title = "Hiccup Attack!",
		category = "family",
		text = "You got the hiccups! Everyone thinks it's adorable.",
		choices = {
			{ text = "😆 Giggle at it", effects = { Happiness = 4 }, resultText = "You made everyone laugh!" },
			{ text = "😢 Start crying", effects = { Happiness = -2 }, resultText = "It was a bit scary at first." },
		},
	},
	{
		id = "baby_first_food",
		minAge = 0, maxAge = 1,
		weight = 55, oneTime = true,
		emoji = "🥣", title = "First Solid Food!",
		category = "family",
		getDynamicData = function()
			local foods = {"mashed carrots", "applesauce", "mashed banana", "sweet potato puree"}
			return { food = foods[math.random(#foods)] }
		end,
		text = "Time to try %food%! Your first real food beyond milk!",
		choices = {
			{ text = "😋 Yummy!", effects = { Health = 4, Happiness = 5 }, resultText = "You loved it! A foodie is born." },
			{ text = "🤢 Spit it out", effects = { Happiness = -2 }, resultText = "You're a picky eater already." },
			{ text = "🤔 Examine it first", effects = { Smarts = 3 }, resultText = "You're cautious with new things." },
		},
	},
	{
		id = "baby_teething",
		minAge = 0, maxAge = 1,
		weight = 50, oneTime = true,
		emoji = "🦷", title = "First Tooth!",
		category = "family",
		text = "Your first tooth is coming in! It's a bit painful but exciting!",
		choices = {
			{ text = "🦷 Chew on everything", effects = { Health = 2 }, resultText = "Teething toys became your best friends." },
			{ text = "😭 Cry about it", effects = { Happiness = -3 }, resultText = "It hurt, but mom made it better." },
		},
	},
	{
		id = "baby_laughing_fit",
		minAge = 0, maxAge = 1,
		weight = 45, cooldown = 3,
		emoji = "😂", title = "First Big Laugh!",
		category = "family",
		text = "Something made you burst into giggles! True belly laughs!",
		choices = {
			{ text = "😂 Keep laughing!", effects = { Happiness = 8, Health = 2 }, resultText = "Best day ever! Pure joy!" },
			{ text = "🤗 Hug whoever made you laugh", effects = { Happiness = 6 }, resultText = "You bonded with your funny family." },
		},
	},
	{
		id = "baby_stranger_fear",
		minAge = 0, maxAge = 1,
		weight = 35, oneTime = true,
		emoji = "😰", title = "Stranger Anxiety!",
		category = "family",
		getDynamicData = function()
			local relatives = {"grandparent", "aunt", "uncle", "family friend"}
			return { relative = relatives[math.random(#relatives)] }
		end,
		text = "Your %relative% tried to hold you but you didn't recognize them!",
		choices = {
			{ text = "😭 WAAAAH!", effects = { Happiness = -3 }, resultText = "You really didn't like strangers.", setFlag = "shy" },
			{ text = "🤔 Warm up slowly", effects = { Smarts = 2 }, resultText = "You're cautious but adaptable." },
			{ text = "🤗 Give them a chance", effects = { Happiness = 4 }, resultText = "You're naturally friendly!", setFlag = "outgoing" },
		},
	},

	-- ═══════════════════════════════════════════════════════════
	-- TODDLER EVENTS (2-4)
	-- ═══════════════════════════════════════════════════════════
	{
		id = "toddler_terrible_twos",
		minAge = 2, maxAge = 2,
		weight = 70, oneTime = true, milestone = true,
		emoji = "😤", title = "The Terrible Twos!",
		category = "family",
		text = "You've entered the 'terrible twos' phase. Your favorite word is 'NO!'",
		choices = {
			{ text = "🙅 Say NO to everything", effects = { Happiness = 5 }, resultText = "You asserted your independence!", setFlag = "strong_willed" },
			{ text = "😇 Be a good baby", effects = { Happiness = 4, Smarts = 2 }, resultText = "You surprised everyone with your maturity." },
			{ text = "😭 Tantrum time!", effects = { Happiness = 2, Health = -2 }, resultText = "You let out all your big feelings." },
		},
	},
	{
		id = "toddler_playground",
		minAge = 2, maxAge = 5,
		weight = 45, cooldown = 2,
		emoji = "🛝", title = "Playground Adventure!",
		category = "family",
		text = "You're at the playground! So many things to explore!",
		choices = {
			{ text = "🪜 Climb everything!", effects = { Health = 4, Happiness = 5 }, resultText = "You're a little monkey!", setFlag = "adventurous" },
			{ text = "🤝 Make friends", effects = { Happiness = 6 }, resultText = "You made playground buddies!" },
			{ text = "⬇️ Go down the slide!", effects = { Happiness = 7 }, resultText = "WEEEEE!" },
			{ text = "🧍 Watch others", effects = { Smarts = 3 }, resultText = "You learned by observing.", setFlag = "shy" },
		},
	},
	{
		id = "toddler_favorite_show",
		minAge = 2, maxAge = 5,
		weight = 40, cooldown = 4,
		emoji = "📺", title = "Favorite TV Show!",
		category = "family",
		getDynamicData = function()
			local shows = {"talking animals", "colorful adventures", "singing characters", "educational puppets"}
			return { show = shows[math.random(#shows)] }
		end,
		text = "You found a show about %show%! You want to watch it FOREVER!",
		choices = {
			{ text = "📺 Watch it again!", effects = { Happiness = 5 }, resultText = "For the 100th time today..." },
			{ text = "🎤 Sing along!", effects = { Happiness = 6, Smarts = 2 }, resultText = "You memorized all the songs!", setFlag = "musical" },
			{ text = "📱 Something else", effects = { Smarts = 2 }, resultText = "You have varied interests." },
		},
	},
	{
		id = "toddler_picky_eater",
		minAge = 2, maxAge = 5,
		weight = 35,
		emoji = "🥦", title = "Veggie Standoff!",
		category = "family",
		getDynamicData = function()
			local veggies = {"broccoli", "spinach", "peas", "carrots", "green beans"}
			return { veggie = veggies[math.random(#veggies)] }
		end,
		text = "Your parents want you to eat %veggie%. You're not having it.",
		choices = {
			{ text = "🤢 Refuse!", effects = { Happiness = 3 }, resultText = "Victory! (for now)" },
			{ text = "😋 Actually try it", effects = { Health = 4, Smarts = 2, Happiness = 3 }, resultText = "It wasn't that bad!" },
			{ text = "🤫 Hide it under napkin", effects = { Smarts = 4 }, resultText = "Sneaky! You're getting clever." },
		},
	},
	{
		id = "toddler_first_drawing",
		minAge = 2, maxAge = 4,
		weight = 50, oneTime = true,
		emoji = "🖍️", title = "First Masterpiece!",
		category = "family",
		text = "You drew something with crayons! It's... abstract art, let's say.",
		choices = {
			{ text = "🎨 Keep drawing!", effects = { Happiness = 5, Smarts = 3 }, resultText = "You might be an artist!", setFlag = "artistic" },
			{ text = "🖼️ Show everyone!", effects = { Happiness = 6 }, resultText = "Everyone praised your 'masterpiece'!" },
			{ text = "✏️ Draw on walls too!", effects = { Happiness = 4, Smarts = -2 }, resultText = "You got in trouble but had fun!" },
		},
	},
	{
		id = "toddler_first_nightmare",
		minAge = 2, maxAge = 5,
		weight = 30, oneTime = true,
		emoji = "😱", title = "First Nightmare!",
		category = "family",
		text = "You had a scary dream and woke up crying!",
		choices = {
			{ text = "👶 Run to parents", effects = { Happiness = 3 }, resultText = "They made you feel safe." },
			{ text = "🧸 Hug your teddy", effects = { Happiness = 2 }, resultText = "Your teddy bear is your guardian." },
			{ text = "💪 Face it bravely", effects = { Happiness = 2, Smarts = 3 }, resultText = "You're learning to self-soothe.", setFlag = "brave" },
		},
	},
	{
		id = "toddler_pet_encounter",
		minAge = 2, maxAge = 5,
		weight = 40,
		emoji = "🐕", title = "Meeting a Dog!",
		category = "family",
		getDynamicData = function()
			local dogs = {"big fluffy", "tiny yappy", "friendly", "curious"}
			return { dogType = dogs[math.random(#dogs)] }
		end,
		text = "You met a %dogType% dog! It wants to say hello!",
		choices = {
			{ text = "🤗 Pet it!", effects = { Happiness = 8 }, resultText = "You made a new furry friend!", setFlag = "animal_lover" },
			{ text = "😨 Too scary!", effects = { Happiness = -2 }, resultText = "Dogs seem intimidating for now." },
			{ text = "🏃 Chase it!", effects = { Health = 3, Happiness = 5 }, resultText = "You ran around together!" },
		},
	},

	-- ═══════════════════════════════════════════════════════════
	-- KINDERGARTEN EVENTS (5-6)
	-- ═══════════════════════════════════════════════════════════
	{
		id = "kindergarten_first_day",
		minAge = 5, maxAge = 5,
		weight = 90, oneTime = true, milestone = true,
		emoji = "🎒", title = "First Day of School!",
		category = "school",
		text = "Today's your first day of kindergarten! Big kid territory!",
		choices = {
			{ text = "😊 I'm excited!", effects = { Happiness = 8, Smarts = 3 }, resultText = "You loved every minute!" },
			{ text = "😢 I miss mom/dad", effects = { Happiness = -3 }, resultText = "It was hard at first, but you got through it." },
			{ text = "🤝 Make friends!", effects = { Happiness = 10 }, resultText = "You're a social butterfly!", setFlag = "popular" },
		},
	},
	{
		id = "kindergarten_nap_time",
		minAge = 5, maxAge = 6,
		weight = 35, cooldown = 3,
		emoji = "😴", title = "Nap Time!",
		category = "school",
		text = "It's nap time at school. But you're not tired at all!",
		choices = {
			{ text = "😴 Actually sleep", effects = { Health = 3 }, resultText = "Power nap achieved!" },
			{ text = "🗣️ Whisper to friends", effects = { Happiness = 4 }, resultText = "Social butterfly, even at nap time!" },
			{ text = "🤫 Pretend to sleep", effects = { Smarts = 3 }, resultText = "You fooled the teacher!" },
		},
	},
	{
		id = "kindergarten_sharing",
		minAge = 5, maxAge = 6,
		weight = 40, cooldown = 3,
		emoji = "🧸", title = "Sharing Is Caring!",
		category = "school",
		getDynamicData = function()
			local items = {"toy", "crayon", "snack", "book"}
			local names = {"Tommy", "Sarah", "Alex", "Jordan"}
			return { item = items[math.random(#items)], kid = names[math.random(#names)] }
		end,
		text = "%kid% wants to use your %item%. Will you share?",
		choices = {
			{ text = "🤝 Yes, share!", effects = { Happiness = 5, Looks = 2 }, resultText = "You made a friend!", setFlag = "generous" },
			{ text = "🙅 It's mine!", effects = { Happiness = 2 }, resultText = "You kept your stuff. Fair enough." },
			{ text = "🔄 Take turns", effects = { Smarts = 4, Happiness = 3 }, resultText = "Smart compromise!" },
		},
	},
}

-- Add early life events to main table
for _, event in ipairs(earlyLifeEvents) do
	table.insert(events, event)
end
print("[EventLibrary] Added", #earlyLifeEvents, "expanded early life events!")

-- ═══════════════════════════════════════════════════════════════════
-- EXPANDED END OF LIFE EVENTS (Ages 65+)
-- More variety for the golden years!
-- ═══════════════════════════════════════════════════════════════════

local endOfLifeEvents = {
	-- ═══════════════════════════════════════════════════════════
	-- ELDERLY LIFE (65-79)
	-- ═══════════════════════════════════════════════════════════
	{
		id = "elder_retirement_party",
		minAge = 65, maxAge = 70,
		weight = 60, oneTime = true,
		emoji = "🎉", title = "Retirement Party!",
		category = "work",
		requiresAnyFlag = {"employed", "had_career"},
		text = "Your colleagues threw you a retirement party! Decades of work celebrated!",
		choices = {
			{ text = "🥹 Give emotional speech", effects = { Happiness = 15 }, resultText = "Everyone was moved. What a career!" },
			{ text = "🎂 Enjoy the cake", effects = { Happiness = 10, Health = -2 }, resultText = "Best retirement cake ever!" },
			{ text = "🤗 Thank everyone", effects = { Happiness = 12 }, resultText = "You left on the best terms." },
		},
	},
	{
		id = "elder_first_grandchild",
		minAge = 50, maxAge = 75,
		weight = 40, oneTime = true,
		emoji = "👶", title = "First Grandchild!",
		category = "family",
		requiresAnyFlag = {"has_children", "married", "had_kids"},
		getDynamicData = function()
			local names = {"Emma", "Liam", "Olivia", "Noah", "Sophia", "Lucas"}
			return { babyName = names[math.random(#names)] }
		end,
		text = "Your grandchild %babyName% was just born! You're a grandparent!",
		choices = {
			{ text = "🤗 Rush to the hospital!", effects = { Happiness = 20 }, resultText = "The moment you held them was magical.", setFlag = "has_grandchildren" },
			{ text = "🎁 Send gifts first", effects = { Happiness = 12, Money = -500 }, resultText = "You spoil them already!", setFlag = "has_grandchildren" },
			{ text = "😭 Cry happy tears", effects = { Happiness = 18 }, resultText = "This is what life is about.", setFlag = "has_grandchildren" },
		},
	},
	{
		id = "elder_aarp_card",
		minAge = 65, maxAge = 66,
		weight = 50, oneTime = true,
		emoji = "💳", title = "Senior Discounts!",
		category = "life",
		text = "You got your senior citizen card! Discounts everywhere!",
		choices = {
			{ text = "💰 Use every discount!", effects = { Money = 2000, Happiness = 5 }, resultText = "Saving money feels good!" },
			{ text = "🤷 Age is just a number", effects = { Happiness = 8 }, resultText = "You don't feel old at all." },
			{ text = "😤 I'm not THAT old!", effects = { Happiness = -3 }, resultText = "The reality hit a bit hard." },
		},
	},
	{
		id = "elder_travel_dreams",
		minAge = 65, maxAge = 80,
		weight = 35, cooldown = 3,
		emoji = "✈️", title = "Dream Vacation!",
		category = "life",
		getDynamicData = function()
			local places = {"Paris", "Tokyo", "the Caribbean", "Alaska", "Italy", "Australia"}
			return { destination = places[math.random(#places)] }
		end,
		text = "You finally have time! Want to take that trip to %destination%?",
		choices = {
			{ text = "✈️ Book it now!", effects = { Happiness = 15, Money = -8000, Health = -3 }, resultText = "Trip of a lifetime!" },
			{ text = "🏠 Stay home instead", effects = { Happiness = 5, Money = 2000 }, resultText = "Home is where the heart is." },
			{ text = "📅 Plan for later", effects = { Smarts = 3 }, resultText = "You'll go when the time is right." },
		},
	},
	{
		id = "elder_memory_lane",
		minAge = 65, maxAge = 90,
		weight = 30, cooldown = 5,
		emoji = "📷", title = "Trip Down Memory Lane",
		category = "life",
		text = "You found old photos from your youth. So many memories...",
		choices = {
			{ text = "😊 Reminisce happily", effects = { Happiness = 10 }, resultText = "The good old days never fade." },
			{ text = "📖 Write your memoirs", effects = { Smarts = 5, Happiness = 8 }, resultText = "Your story deserves to be told." },
			{ text = "👨‍👩‍👧‍👦 Share with family", effects = { Happiness = 12 }, resultText = "The kids loved hearing your stories." },
		},
	},
	{
		id = "elder_health_checkup",
		minAge = 65, maxAge = 95,
		weight = 45, cooldown = 3,
		emoji = "🏥", title = "Annual Checkup",
		category = "health",
		text = "Time for your annual medical checkup. How's your health?",
		choices = {
			{ text = "✅ Get checked", effects = { Health = 5, Money = -500 }, resultText = "Doctor says you're doing well for your age!" },
			{ text = "🙅 Skip it this year", effects = { Health = -10 }, resultText = "Probably should have gone..." },
			{ text = "💊 Ask about new treatments", effects = { Health = 8, Smarts = 3, Money = -1000 }, resultText = "You're on top of your health!" },
		},
	},
	{
		id = "elder_learn_technology",
		minAge = 65, maxAge = 85,
		weight = 35, cooldown = 4,
		emoji = "📱", title = "New Technology!",
		category = "life",
		getDynamicData = function()
			local tech = {"smartphone", "tablet", "video calling", "social media", "smart TV"}
			return { technology = tech[math.random(#tech)] }
		end,
		text = "Your family wants to teach you how to use a %technology%.",
		choices = {
			{ text = "📚 Learn it!", effects = { Smarts = 8, Happiness = 5 }, resultText = "You're tech-savvy now!" },
			{ text = "🤷 Too complicated", effects = { Happiness = -3 }, resultText = "Technology these days..." },
			{ text = "👴 Back in my day...", effects = { Happiness = 2 }, resultText = "You told them about the good old days instead." },
		},
	},
	{
		id = "elder_volunteer",
		minAge = 65, maxAge = 85,
		weight = 30,
		emoji = "🤝", title = "Volunteer Opportunity",
		category = "life",
		getDynamicData = function()
			local places = {"local hospital", "animal shelter", "food bank", "community center", "school tutoring"}
			return { place = places[math.random(#places)] }
		end,
		text = "Would you like to volunteer at the %place%?",
		choices = {
			{ text = "🤝 Yes, sign me up!", effects = { Happiness = 12, Health = 3 }, resultText = "Helping others is fulfilling.", setFlag = "volunteer" },
			{ text = "⏰ Maybe later", effects = { Happiness = 2 }, resultText = "You'll think about it." },
		},
	},

	-- ═══════════════════════════════════════════════════════════
	-- SENIOR SENIOR YEARS (80-99)
	-- ═══════════════════════════════════════════════════════════
	{
		id = "elder_80th_birthday",
		minAge = 80, maxAge = 80,
		weight = 100, oneTime = true, milestone = true,
		emoji = "🎂", title = "80th Birthday!",
		category = "life",
		text = "Happy 80th birthday! What an incredible milestone!",
		choices = {
			{ text = "🎉 Big party!", effects = { Happiness = 20, Money = -3000 }, resultText = "All your loved ones celebrated with you!" },
			{ text = "👨‍👩‍👧‍👦 Family dinner", effects = { Happiness = 15 }, resultText = "Intimate and perfect." },
			{ text = "🧘 Quiet reflection", effects = { Happiness = 10, Smarts = 5 }, resultText = "80 years of wisdom..." },
		},
	},
	{
		id = "elder_great_grandchild",
		minAge = 75, maxAge = 95,
		weight = 25, oneTime = true,
		emoji = "👶", title = "Great-Grandchild!",
		category = "family",
		requiresFlag = "has_grandchildren",
		text = "Your great-grandchild was just born! Four generations!",
		choices = {
			{ text = "🥹 Tears of joy", effects = { Happiness = 25 }, resultText = "Your legacy continues!", setFlag = "has_great_grandchildren" },
			{ text = "🎁 Start the spoiling!", effects = { Happiness = 18, Money = -1000 }, resultText = "Great-grandparents get to spoil the most!", setFlag = "has_great_grandchildren" },
		},
	},
	{
		id = "elder_mobility_challenge",
		minAge = 75, maxAge = 95,
		weight = 40, cooldown = 3,
		emoji = "🦽", title = "Mobility Decision",
		category = "health",
		getDynamicData = function()
			local scenarios = {
				{
					text = "Your knees grind whenever you take the stairs. The doctor warned another fall could break something.",
					keepRange = { -5, 4 },
					stayRange = { -10, -2 },
					aidRange = { 3, 8 },
					aidHappy = { 4, 9 },
					walkHappyPos = 6,
					walkHappyNeg = -5,
				},
				{
					text = "Vertigo hits hard in grocery aisles. Handrails suddenly look very appealing.",
					keepRange = { -3, 5 },
					stayRange = { -6, -1 },
					aidRange = { 2, 6 },
					aidHappy = { 3, 7 },
					walkHappyPos = 5,
					walkHappyNeg = -6,
				},
				{
					text = "Your hip keeps popping out when you stand up quickly. Physical therapy says stay active, but cautiously.",
					keepRange = { -4, 6 },
					stayRange = { -8, -2 },
					aidRange = { 4, 9 },
					aidHappy = { 5, 8 },
					walkHappyPos = 7,
					walkHappyNeg = -4,
				},
			}

			local scenario = scenarios[math.random(#scenarios)]
			local function roll(range)
				return math.random(range[1], range[2])
			end

			local keepDelta = roll(scenario.keepRange)
			local stayDelta = roll(scenario.stayRange)
			local aidDelta = roll(scenario.aidRange)
			local aidCost = math.random(400, 2200)
			local aidHappy = roll(scenario.aidHappy)

			local function buildResult(delta, posText, negText)
				if delta >= 0 then
					return string.format("%s (+%d Health).", posText, delta)
				else
					return string.format("%s (%d Health).", negText, delta)
				end
			end

			return {
				scenarioText = scenario.text,
				keepHealthDelta = keepDelta,
				keepHappinessDelta = keepDelta >= 0 and scenario.walkHappyPos or scenario.walkHappyNeg,
				stayHealthDelta = stayDelta,
				stayHappinessDelta = -6,
				aidHealthDelta = aidDelta,
				aidHappinessDelta = aidHappy,
				aidCost = aidCost,
				keepResult = buildResult(keepDelta, "Slow walks loosened you up again.", "You pushed too hard and tweaked something."),
				aidResult = buildResult(aidDelta, "The cane/walker kept you steady and confident.", "Still shaky, but at least the aid stopped big spills."),
				stayResult = buildResult(stayDelta, "Rest felt good short term but stiffness is brutal now.", "Staying home made everything ache even more."),
			}
		end,
		text = "%scenarioText%",
		choices = {
			{
				text = "🚶 Keep walking daily",
				dynamicEffects = function(_, data)
					return {
						Health = data.keepHealthDelta or 0,
						Happiness = data.keepHappinessDelta or 0,
					}
				end,
				resultText = "%keepResult%",
			},
			{
				text = "🦯 Get mobility aid",
				dynamicEffects = function(_, data)
					return {
						Health = data.aidHealthDelta or 0,
						Happiness = data.aidHappinessDelta or 0,
						Money = data.aidCost and -data.aidCost or 0,
					}
				end,
				resultText = "%aidResult%",
			},
			{
				text = "🏠 Stay home more",
				dynamicEffects = function(_, data)
					return {
						Health = data.stayHealthDelta or 0,
						Happiness = data.stayHappinessDelta or -6,
					}
				end,
				resultText = "%stayResult%",
			},
		},
	},
	{
		id = "elder_old_friend_reunion",
		minAge = 70, maxAge = 95,
		weight = 25, cooldown = 5,
		emoji = "👴", title = "Old Friend Reunion!",
		category = "life",
		getDynamicData = function()
			return { friendName = randomName() }
		end,
		text = "Your old friend %friendName% contacted you! You haven't seen them in decades!",
		choices = {
			{ text = "🤗 Meet up!", effects = { Happiness = 15 }, resultText = "So much catching up to do!" },
			{ text = "📞 Long phone call", effects = { Happiness = 10 }, resultText = "Hours of reminiscing." },
			{ text = "😢 They passed away", effects = { Happiness = -10, Health = -3 }, resultText = "You missed your chance... Rest in peace, old friend." },
		},
	},
	{
		id = "elder_legacy_decision",
		minAge = 75, maxAge = 95,
		weight = 30, oneTime = true,
		emoji = "📜", title = "Your Legacy",
		category = "life",
		text = "What do you want to be remembered for?",
		choices = {
			{ text = "👨‍👩‍👧‍👦 Family legacy", effects = { Happiness = 15 }, resultText = "Your family IS your legacy." },
			{ text = "💝 Charity donation", effects = { Happiness = 12, Money = -50000 }, resultText = "Your generosity will help many.", setFlag = "philanthropist" },
			{ text = "📚 Write an autobiography", effects = { Smarts = 5, Happiness = 10 }, resultText = "Your story will inspire others." },
			{ text = "🏛️ Create a scholarship", effects = { Happiness = 15, Money = -100000 }, resultText = "Future students will thank you.", setFlag = "philanthropist" },
		},
	},
	{
		id = "elder_90th_birthday",
		minAge = 90, maxAge = 90,
		weight = 100, oneTime = true, milestone = true,
		emoji = "🎂", title = "90th Birthday!",
		category = "life",
		text = "NINETY YEARS OLD! You've seen almost a century!",
		choices = {
			{ text = "🎉 Celebrate big!", effects = { Happiness = 25 }, resultText = "What an achievement!" },
			{ text = "📺 Get on local news!", effects = { Happiness = 20 }, resultText = "The community celebrated you!" },
			{ text = "🧘 Peaceful gratitude", effects = { Happiness = 18, Smarts = 5 }, resultText = "90 years of experiences..." },
		},
	},
	{
		id = "elder_centenarian_prep",
		minAge = 95, maxAge = 99,
		weight = 50,
		emoji = "💯", title = "Almost 100!",
		category = "life",
		text = "You're approaching 100 years old! Any goals left?",
		choices = {
			{ text = "💪 Make it to 100!", effects = { Health = 5, Happiness = 10 }, resultText = "You're determined!" },
			{ text = "😌 At peace with life", effects = { Happiness = 15 }, resultText = "You've lived a full life." },
			{ text = "📝 Share your secrets", effects = { Smarts = 3, Happiness = 8 }, resultText = "Everyone wants your longevity tips!" },
		},
	},
	{
		id = "elder_100th_birthday",
		minAge = 100, maxAge = 100,
		weight = 100, oneTime = true, milestone = true,
		emoji = "🎂", title = "100 YEARS OLD!",
		category = "life",
		text = "ONE HUNDRED YEARS! You're a centenarian! Incredible!",
		choices = {
			{ text = "🎉 BIGGEST PARTY EVER!", effects = { Happiness = 50 }, resultText = "A century of life celebrated!" },
			{ text = "📺 National news!", effects = { Happiness = 40 }, resultText = "You're famous for your longevity!" },
			{ text = "🙏 Thank everyone who helped", effects = { Happiness = 45 }, resultText = "So many people made this possible." },
		},
	},
	{
		id = "elder_final_wishes",
		minAge = 85, maxAge = 120,
		weight = 20, oneTime = true,
		emoji = "📝", title = "Final Wishes",
		category = "life",
		text = "It's important to plan ahead. Have you arranged your final wishes?",
		choices = {
			{ text = "📜 Write a will", effects = { Smarts = 5, Happiness = 5 }, resultText = "Your affairs are in order.", setFlag = "has_will" },
			{ text = "💬 Tell family my wishes", effects = { Happiness = 8 }, resultText = "They know what you want." },
			{ text = "⏭️ Not ready to think about it", effects = { Happiness = -5 }, resultText = "It's hard to face, but important." },
		},
	},
	{
		id = "elder_peaceful_end",
		minAge = 90, maxAge = 120,
		weight = 10, oneTime = true,
		emoji = "🌅", title = "Sunset of Life",
		category = "life",
		text = "You feel at peace. You've lived a full life with many experiences.",
		choices = {
			{ text = "😌 I'm ready whenever", effects = { Happiness = 20 }, resultText = "You face the future with grace." },
			{ text = "👨‍👩‍👧‍👦 Spend time with family", effects = { Happiness = 25 }, resultText = "Every moment is precious." },
			{ text = "📖 Pass on wisdom", effects = { Smarts = 5, Happiness = 15 }, resultText = "Your knowledge will live on." },
		},
	},
}

-- Add end of life events to main table
for _, event in ipairs(endOfLifeEvents) do
	table.insert(events, event)
end
print("[EventLibrary] Added", #endOfLifeEvents, "expanded end of life events!")

-- ═══════════════════════════════════════════════════════════════════
-- MASSIVE EVENT EXPANSION - DIVERSE LIFE PATHS
-- 500+ new events for different life paths and scenarios
-- ═══════════════════════════════════════════════════════════════════

local diverseEvents = {
	-- ═══════════════════════════════════════════════════════════
	-- TECH/HACKER LIFE PATH (White Hat & Black Hat)
	-- ═══════════════════════════════════════════════════════════
	{
		id = "discover_coding_talent",
		minAge = 8, maxAge = 16,
		weight = 25, oneTime = true,
		emoji = "💻", title = "Natural Talent!",
		category = "school",
		text = "You wrote your first program and it actually worked! The computer seems to understand you.",
		choices = {
			{ text = "🖥️ Keep learning", effects = { Smarts = 10, Happiness = 8 }, resultText = "You're becoming a coding prodigy!", setFlag = "tech_talent" },
			{ text = "🎮 Make games instead", effects = { Happiness = 10, Smarts = 5 }, resultText = "Game development is fun!", setFlag = "game_dev" },
			{ text = "🤷 It's just a hobby", effects = { Happiness = 3 }, resultText = "Maybe you'll come back to it later." },
		},
	},
	{
		id = "hackathon_invite",
		minAge = 14, maxAge = 30,
		weight = 15, cooldown = 3,
		emoji = "🏆", title = "Hackathon Invitation",
		category = "career",
		requiresAnyFlag = {"tech_talent", "coding_interest", "developer"},
		text = "You've been invited to a 48-hour hackathon! Cash prizes await.",
		choices = {
			{ text = "💪 I'm in!", effects = { Money = 5000, Smarts = 8, Health = -5 }, resultText = "48 sleepless hours later... you won $5,000!", setFlag = "hackathon_winner" },
			{ text = "👥 Find a team", effects = { Money = 2000, Smarts = 5, Happiness = 5 }, resultText = "Your team placed second! Great networking too." },
			{ text = "😴 Too intense", effects = { Happiness = -3 }, resultText = "Maybe next time." },
		},
	},
	{
		id = "bug_bounty_discovery",
		minAge = 16, maxAge = 50,
		weight = 12, cooldown = 2,
		emoji = "🐛", title = "Bug Bounty!",
		category = "career",
		requiresAnyFlag = {"tech_talent", "hacker_curious", "developer", "ethical_hacker"},
		getDynamicData = function()
			local companies = {"TechGiant", "SocialMedia Corp", "CloudServices Inc", "E-Commerce Giant"}
			local amounts = {500, 1000, 5000, 10000, 25000}
			return { company = companies[math.random(#companies)], amount = amounts[math.random(#amounts)] }
		end,
		text = "You found a security vulnerability in %company%'s systems! They have a bug bounty program.",
		choices = {
			{ text = "📧 Report responsibly", effects = { Money = 10000, Smarts = 5, Happiness = 10 }, resultText = "They paid you $%amount% and thanked you publicly!", setFlag = "ethical_hacker" },
			{ text = "🤫 Try to exploit it", effects = { Money = 50000, Smarts = 3 }, resultText = "You quietly extracted some crypto... risky move.", setFlags = {"blackhat", "criminal"} },
			{ text = "📢 Go public", effects = { Happiness = -5, Smarts = 3 }, resultText = "They weren't happy, but the security community respected you." },
		},
	},
	{
		id = "dark_web_invitation",
		minAge = 18, maxAge = 40,
		weight = 8, oneTime = true,
		emoji = "🌑", title = "The Dark Side",
		category = "crime",
		requiresAnyFlag = {"tech_talent", "blackhat", "criminal", "hacker_curious"},
		text = "Someone on an underground forum offered you a job. They need your skills for 'special projects'.",
		choices = {
			{ text = "💀 Join them", effects = { Money = 30000, Smarts = 5, Happiness = -10 }, resultText = "You're now part of a hacking collective...", setFlags = {"blackhat_hacker", "criminal_hacker", "underground"} },
			{ text = "🚫 Refuse", effects = { Happiness = 5 }, resultText = "You stayed on the right path.", setFlag = "ethical_path" },
			{ text = "🚨 Report to FBI", effects = { Smarts = 3 }, resultText = "You became an anonymous informant.", setFlag = "fed_informant" },
		},
	},
	{
		id = "startup_opportunity",
		minAge = 20, maxAge = 45,
		weight = 15, oneTime = true,
		emoji = "🚀", title = "Startup Dreams",
		category = "career",
		requiresAnyFlag = {"tech_talent", "developer", "business_minded", "entrepreneurial"},
		getDynamicData = function()
			local ideas = {"AI assistant", "social app", "fintech platform", "gaming platform", "crypto exchange"}
			return { idea = ideas[math.random(#ideas)] }
		end,
		text = "You have an idea for a %idea% startup! Investors are interested.",
		choices = {
			{ text = "🏢 Go all in!", effects = { Money = -20000, Happiness = 15, Smarts = 5 }, resultText = "You quit your job and founded your company!", setFlags = {"startup_founder", "entrepreneur"} },
			{ text = "💼 Keep day job + side hustle", effects = { Money = 5000, Happiness = 5, Health = -5 }, resultText = "Working on it nights and weekends..." },
			{ text = "🤝 Sell the idea", effects = { Money = 100000 }, resultText = "An acqui-hire! $100k in your pocket." },
		},
	},
	{
		id = "crypto_scheme",
		minAge = 18, maxAge = 60,
		weight = 10, cooldown = 4,
		emoji = "₿", title = "Crypto Opportunity",
		category = "money",
		text = "A friend says they know someone who can 10x your crypto investment...",
		choices = {
			{ text = "💰 Invest $10,000", effects = { Money = -10000 }, resultText = "It was a scam. Money's gone.", setFlag = "crypto_scammed" },
			{ text = "💵 Invest $1,000", effects = { Money = -1000 }, resultText = "At least you didn't lose too much..." },
			{ text = "🙅 Pass", effects = { Smarts = 5 }, resultText = "Good instincts - it was a scam.", setFlag = "financially_savvy" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════
	-- STREET LIFE / THUG PATH
	-- ═══════════════════════════════════════════════════════════
	{
		id = "neighborhood_crew",
		minAge = 12, maxAge = 22,
		weight = 15, oneTime = true,
		emoji = "👥", title = "The Crew",
		category = "social",
		text = "Some kids from the block want you to hang with their crew. They look tough.",
		choices = {
			{ text = "🤝 Join up", effects = { Happiness = 8 }, resultText = "You're part of the crew now.", setFlags = {"street_connected", "crew_member"} },
			{ text = "🏃 Stay away", effects = { Smarts = 3 }, resultText = "Probably safer this way." },
			{ text = "🎭 Play both sides", effects = { Smarts = 5 }, resultText = "You know them but keep your distance." },
		},
	},
	{
		id = "corner_opportunity",
		minAge = 14, maxAge = 25,
		weight = 10, oneTime = true,
		emoji = "🏪", title = "Easy Money",
		category = "crime",
		requiresAnyFlag = {"street_connected", "crew_member", "rebellious"},
		text = "Your boy says there's easy money to be made on the corner. No questions asked.",
		choices = {
			{ text = "💵 Start slanging", effects = { Money = 5000, Happiness = 5 }, resultText = "The money's good but the risk is real.", setFlags = {"street_hustler", "criminal"} },
			{ text = "🙅 Too risky", effects = { Happiness = -3 }, resultText = "You stayed clean... for now." },
			{ text = "👀 Just look out", effects = { Money = 1000 }, resultText = "You're a lookout. Less risky, less pay." },
		},
	},
	{
		id = "turf_war",
		minAge = 15, maxAge = 35,
		weight = 12, cooldown = 2,
		emoji = "⚔️", title = "Turf War",
		category = "crime",
		requiresAnyFlag = {"street_hustler", "gang_member", "crew_member"},
		text = "Another crew is moving in on your territory. Things are getting heated.",
		choices = {
			{ text = "💪 Stand your ground", effects = { Happiness = 5, Health = -15 }, resultText = "You held the block but got hurt.", setFlag = "street_reputation" },
			{ text = "🤝 Make peace", effects = { Smarts = 5, Happiness = 3 }, resultText = "You negotiated a truce. Smart.", setFlag = "peacemaker" },
			{ text = "🏃 Fall back", effects = { Happiness = -10 }, resultText = "You lost respect but stayed safe." },
		},
	},
	{
		id = "robbery_plan",
		minAge = 16, maxAge = 40,
		weight = 8, cooldown = 3,
		emoji = "🎭", title = "Big Score",
		category = "crime",
		requiresAnyFlag = {"street_hustler", "criminal", "crew_member"},
		getDynamicData = function()
			local targets = {"convenience store", "pawn shop", "jewelry store", "electronics store"}
			return { target = targets[math.random(#targets)] }
		end,
		text = "Your crew wants to hit a %target%. They need a driver.",
		choices = {
			{ text = "🚗 Be the wheelman", effects = { Money = 15000 }, resultText = "Clean getaway! Easy money.", setFlags = {"robbery_participant", "criminal_record"} },
			{ text = "🙅 Too hot", effects = { Happiness = 3 }, resultText = "You backed out. They're not happy." },
			{ text = "🚨 Anonymous tip", effects = { Happiness = -5 }, resultText = "You snitched... but nobody knows.", setFlag = "informant" },
		},
	},
	{
		id = "street_promotion",
		minAge = 18, maxAge = 35,
		weight = 10, oneTime = true,
		emoji = "👑", title = "Moving Up",
		category = "crime",
		requiresFlag = "street_hustler",
		text = "The OG's noticed your work. They want to give you more responsibility.",
		choices = {
			{ text = "👑 Take the crown", effects = { Money = 20000, Smarts = 3 }, resultText = "You're running your own corner now.", setFlags = {"street_boss", "gang_lieutenant"} },
			{ text = "😎 Stay humble", effects = { Happiness = 5, Money = 5000 }, resultText = "More money, same risk level." },
			{ text = "🚪 Get out", effects = { Happiness = 10, Money = -10000 }, resultText = "You paid your dues and walked away.", setFlag = "ex_street" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════
	-- SCHOOL/STUDENT EVENTS
	-- ═══════════════════════════════════════════════════════════
	{
		id = "study_group_invite",
		minAge = 14, maxAge = 25,
		weight = 30, cooldown = 2,
		emoji = "📚", title = "Study Group",
		category = "school",
		text = "Some classmates want to form a study group. They asked if you want to join.",
		choices = {
			{ text = "📖 Join them!", effects = { Smarts = 8, Happiness = 5 }, resultText = "Your grades improved and you made friends!", setFlag = "studious" },
			{ text = "🎮 Rather play games", effects = { Happiness = 5, Smarts = -3 }, resultText = "Fun but not productive." },
			{ text = "📱 Study alone", effects = { Smarts = 5 }, resultText = "You prefer your own pace." },
		},
	},
	{
		id = "class_president_run",
		minAge = 12, maxAge = 18,
		weight = 15, oneTime = true,
		emoji = "🗳️", title = "Class President!",
		category = "school",
		text = "Friends want you to run for class president. Campaign time!",
		choices = {
			{ text = "🎤 Run for it!", effects = { Smarts = 5, Happiness = 10, Looks = 3 }, resultText = "You won! Leadership looks good on you.", setFlags = {"class_president", "leadership"} },
			{ text = "🤝 Run as VP instead", effects = { Smarts = 3, Happiness = 5 }, resultText = "Less pressure, still involved.", setFlag = "student_council" },
			{ text = "📚 Focus on grades", effects = { Smarts = 5 }, resultText = "Politics isn't for everyone." },
		},
	},
	{
		id = "science_fair",
		minAge = 10, maxAge = 18,
		weight = 20, cooldown = 3,
		emoji = "🔬", title = "Science Fair!",
		category = "school",
		getDynamicData = function()
			local projects = {"volcano model", "robot arm", "plant growth experiment", "solar panel system", "chemistry reaction"}
			return { project = projects[math.random(#projects)] }
		end,
		text = "Science fair is coming up! You could build a %project%.",
		choices = {
			{ text = "🏆 Go all out!", effects = { Smarts = 12, Happiness = 8 }, resultText = "First place! You're a scientist!", setFlags = {"science_talent", "academically_gifted"} },
			{ text = "📋 Basic entry", effects = { Smarts = 5 }, resultText = "Participation ribbon. Not bad." },
			{ text = "🙄 Skip it", effects = { Happiness = 3, Smarts = -3 }, resultText = "Science isn't your thing anyway." },
		},
	},
	{
		id = "detention_trouble",
		minAge = 8, maxAge = 18,
		weight = 25, cooldown = 2,
		emoji = "📝", title = "Detention!",
		category = "school",
		getDynamicData = function()
			local reasons = {"talking in class", "being late", "pulling a prank", "fighting", "skipping class"}
			return { reason = reasons[math.random(#reasons)] }
		end,
		text = "You got detention for %reason%! Your parents will find out.",
		choices = {
			{ text = "😤 Serve it silently", effects = { Happiness = -5 }, resultText = "You sat there fuming for an hour." },
			{ text = "💬 Argue with teacher", effects = { Happiness = -10, Smarts = -3 }, resultText = "Now you have more detention.", setFlag = "rebellious" },
			{ text = "🍎 Apologize sincerely", effects = { Smarts = 3, Looks = 2 }, resultText = "The teacher reduced your time." },
		},
	},
	{
		id = "school_dance",
		minAge = 12, maxAge = 18,
		weight = 20, cooldown = 2,
		emoji = "💃", title = "School Dance!",
		category = "social",
		text = "The school dance is this weekend! Do you want to go?",
		choices = {
			{ text = "💃 Go with a date!", effects = { Happiness = 15, Looks = 3 }, resultText = "Best night ever!", setFlag = "social_butterfly" },
			{ text = "👥 Go with friends", effects = { Happiness = 10 }, resultText = "Great time with your squad!" },
			{ text = "🏠 Stay home", effects = { Happiness = -5 }, resultText = "You missed out on memories." },
			{ text = "📚 Study instead", effects = { Smarts = 5, Happiness = -3 }, resultText = "At least you'll ace the test." },
		},
	},
	{
		id = "bully_encounter",
		minAge = 8, maxAge = 18,
		weight = 18, cooldown = 3,
		emoji = "😠", title = "Bully Alert!",
		category = "school",
		getDynamicData = function()
			return { bullyName = randomName() }
		end,
		text = "%bullyName% has been picking on you. It's getting worse.",
		choices = {
			{ text = "💪 Stand up to them", effects = { Happiness = 8, Health = -5 }, resultText = "You fought back! They leave you alone now.", setFlag = "stood_up_for_self" },
			{ text = "🗣️ Tell a teacher", effects = { Smarts = 3 }, resultText = "The bully got in trouble.", setFlag = "seeks_help" },
			{ text = "😢 Ignore it", effects = { Happiness = -10, Health = -3 }, resultText = "It hurts but you push through." },
			{ text = "🤝 Try to befriend them", effects = { Smarts = 5, Happiness = 5 }, resultText = "Surprisingly, they're actually nice one-on-one.", setFlag = "peacemaker" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════
	-- CAREER/WORK EVENTS
	-- ═══════════════════════════════════════════════════════════
	{
		id = "promotion_opportunity",
		minAge = 22, maxAge = 60,
		weight = 15, cooldown = 3,
		emoji = "📈", title = "Promotion!",
		category = "work",
		requiresAnyFlag = {"employed", "had_job"},
		text = "Your boss called you into the office. A promotion is on the table!",
		choices = {
			{ text = "🎉 Accept!", effects = { Money = 15000, Happiness = 15, Smarts = 3 }, resultText = "Bigger title, bigger paycheck!", setFlag = "promoted" },
			{ text = "💰 Negotiate more", effects = { Money = 25000, Happiness = 10 }, resultText = "You got even more than offered!" },
			{ text = "🤔 Think about it", effects = { Smarts = 3 }, resultText = "Sometimes patience pays off." },
		},
	},
	{
		id = "workplace_drama",
		minAge = 18, maxAge = 65,
		weight = 20, cooldown = 2,
		emoji = "🎭", title = "Office Drama",
		category = "work",
		getDynamicData = function()
			return { coworkerName = randomName() }
		end,
		text = "%coworkerName% has been spreading rumors about you at work!",
		choices = {
			{ text = "😤 Confront them", effects = { Happiness = 5 }, resultText = "You cleared the air. Respect earned.", setFlag = "assertive" },
			{ text = "🗣️ Go to HR", effects = { Smarts = 3 }, resultText = "They got a warning. Awkward now." },
			{ text = "🤷 Rise above", effects = { Smarts = 5, Happiness = 3 }, resultText = "Your work speaks for itself." },
			{ text = "🔥 Spread rumors back", effects = { Happiness = 3, Smarts = -5 }, resultText = "Petty but satisfying.", setFlag = "office_drama" },
		},
	},
	{
		id = "side_hustle_idea",
		minAge = 16, maxAge = 50,
		weight = 15, cooldown = 4,
		emoji = "💡", title = "Side Hustle Idea!",
		category = "work",
		getDynamicData = function()
			local hustles = {"tutoring", "freelance design", "social media management", "pet sitting", "delivery driving", "reselling sneakers"}
			return { hustle = hustles[math.random(#hustles)] }
		end,
		text = "You had an idea: start %hustle% on the side for extra cash!",
		choices = {
			{ text = "🚀 Start it!", effects = { Money = 5000, Happiness = 8, Health = -3 }, resultText = "Extra income is flowing!", setFlag = "entrepreneur" },
			{ text = "📋 Research first", effects = { Smarts = 5 }, resultText = "You're planning carefully." },
			{ text = "😴 Too much work", effects = { Happiness = 3 }, resultText = "Your free time is valuable too." },
		},
	},
	{
		id = "dream_job_offer",
		minAge = 22, maxAge = 55,
		weight = 8, oneTime = true,
		emoji = "✨", title = "Dream Job!",
		category = "work",
		requiresAnyFlag = {"college_grad", "talented", "expert", "promoted"},
		getDynamicData = function()
			local companies = {"Google", "NASA", "Apple", "SpaceX", "Goldman Sachs", "Disney"}
			return { company = companies[math.random(#companies)] }
		end,
		text = "%company% reached out. They want to interview you for your dream position!",
		choices = {
			{ text = "🎯 Nail the interview!", effects = { Money = 50000, Happiness = 25, Smarts = 5 }, resultText = "YOU GOT THE JOB! Life changed.", setFlags = {"dream_job", "successful"} },
			{ text = "😰 Too nervous", effects = { Happiness = -10 }, resultText = "You bombed it. Opportunity lost." },
			{ text = "🤝 Counter offer", effects = { Money = 75000, Happiness = 20 }, resultText = "You negotiated an even better deal!" },
		},
	},
	{
		id = "work_from_home",
		minAge = 22, maxAge = 65,
		weight = 15, cooldown = 4,
		emoji = "🏠", title = "Remote Work!",
		category = "work",
		text = "Your company is offering remote work options. Do you want to work from home?",
		choices = {
			{ text = "🏠 Yes please!", effects = { Happiness = 10, Health = 3, Money = 2000 }, resultText = "No commute, pajamas optional!", setFlag = "remote_worker" },
			{ text = "🏢 Prefer the office", effects = { Smarts = 3 }, resultText = "Face time with colleagues has value." },
			{ text = "🔀 Hybrid schedule", effects = { Happiness = 7, Health = 2 }, resultText = "Best of both worlds!" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════
	-- SPORTS & FITNESS EVENTS
	-- ═══════════════════════════════════════════════════════════
	{
		id = "sports_tryout",
		minAge = 10, maxAge = 18,
		weight = 25, cooldown = 2,
		emoji = "⚽", title = "Sports Tryout!",
		category = "school",
		getDynamicData = function()
			local sports = {"basketball", "football", "soccer", "baseball", "volleyball", "track"}
			return { sport = sports[math.random(#sports)] }
		end,
		text = "Tryouts for the %sport% team are today!",
		choices = {
			{ text = "🏃 Give it your all!", effects = { Health = 8, Happiness = 10, Looks = 3 }, resultText = "You made the team!", setFlags = {"athlete", "team_player"} },
			{ text = "😅 Try casually", effects = { Health = 3, Happiness = 3 }, resultText = "You didn't make varsity, but JV works!" },
			{ text = "🤷 Skip tryouts", effects = { Happiness = -3 }, resultText = "Sports aren't your thing anyway." },
		},
	},
	{
		id = "championship_game",
		minAge = 12, maxAge = 22,
		weight = 12, oneTime = true,
		emoji = "🏆", title = "Championship Game!",
		category = "social",
		requiresFlag = "athlete",
		text = "The championship game is tonight! The whole school is watching.",
		choices = {
			{ text = "🌟 Be the MVP!", effects = { Happiness = 25, Looks = 10, Health = 5 }, resultText = "You scored the winning point! LEGEND!", setFlags = {"sports_star", "champion"} },
			{ text = "👥 Team effort", effects = { Happiness = 15, Health = 3 }, resultText = "Your team won! What a night!" },
			{ text = "😰 Choke under pressure", effects = { Happiness = -15, Health = -5 }, resultText = "You missed the shot... haunting." },
		},
	},
	{
		id = "gym_membership",
		minAge = 16, maxAge = 70,
		weight = 20, cooldown = 3,
		emoji = "🏋️", title = "Gym Life",
		category = "health",
		text = "A new gym opened nearby. $50/month membership.",
		choices = {
			{ text = "💪 Sign up!", effects = { Health = 10, Looks = 5, Money = -600 }, resultText = "You're getting fit!", setFlag = "gym_goer" },
			{ text = "🏃 Outdoor exercise", effects = { Health = 5, Happiness = 3 }, resultText = "Free and refreshing!" },
			{ text = "😴 Too lazy", effects = { Health = -3 }, resultText = "The couch won today." },
		},
	},
	{
		id = "marathon_challenge",
		minAge = 18, maxAge = 60,
		weight = 10, cooldown = 5,
		emoji = "🏃", title = "Marathon!",
		category = "health",
		text = "Your friend challenges you to run a marathon with them!",
		choices = {
			{ text = "🏅 Train and run!", effects = { Health = 20, Happiness = 15, Looks = 5 }, resultText = "26.2 miles complete! You're a marathoner!", setFlags = {"marathon_finisher", "determined"} },
			{ text = "🚶 Do a half marathon", effects = { Health = 10, Happiness = 8 }, resultText = "13.1 miles is still impressive!" },
			{ text = "🛋️ Watch from home", effects = { Happiness = -5 }, resultText = "You cheered them on from the couch." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════
	-- SOCIAL/RELATIONSHIP EVENTS
	-- ═══════════════════════════════════════════════════════════
	{
		id = "surprise_party",
		minAge = 10, maxAge = 80,
		weight = 15, cooldown = 5,
		emoji = "🎉", title = "Surprise Party!",
		category = "social",
		text = "Your friends threw you a surprise party! You had no idea!",
		choices = {
			{ text = "😭 Tears of joy", effects = { Happiness = 20 }, resultText = "Best surprise ever! You feel so loved!" },
			{ text = "🎤 Give a speech", effects = { Happiness = 15, Smarts = 3 }, resultText = "You thanked everyone beautifully." },
			{ text = "😳 So embarrassing!", effects = { Happiness = 10 }, resultText = "You hate surprises but appreciate the love." },
		},
	},
	{
		id = "friendship_fallout",
		minAge = 12, maxAge = 60,
		weight = 15, cooldown = 4,
		emoji = "💔", title = "Friendship Troubles",
		category = "social",
		getDynamicData = function()
			return { friendName = randomName() }
		end,
		text = "You and %friendName% had a big argument. The friendship is on the rocks.",
		choices = {
			{ text = "🤝 Apologize first", effects = { Happiness = 5 }, resultText = "You made up. Friendship saved!", setFlag = "mature" },
			{ text = "⏰ Give it time", effects = { Happiness = -5 }, resultText = "Some distance might help." },
			{ text = "🚪 End it", effects = { Happiness = -10 }, resultText = "Some friendships aren't meant to last." },
			{ text = "💬 Talk it out", effects = { Smarts = 5, Happiness = 8 }, resultText = "Communication wins again!" },
		},
	},
	{
		id = "new_neighbor",
		minAge = 5, maxAge = 80,
		weight = 20, cooldown = 4,
		emoji = "🏠", title = "New Neighbor!",
		category = "social",
		getDynamicData = function()
			return { neighborName = randomName() }
		end,
		text = "A new neighbor %neighborName% moved in next door!",
		choices = {
			{ text = "🍪 Bring welcome cookies", effects = { Happiness = 8 }, resultText = "You made a new friend!", setFlag = "friendly" },
			{ text = "👋 Just wave hi", effects = { Happiness = 3 }, resultText = "Polite but keeping distance." },
			{ text = "🙈 Avoid them", effects = { Happiness = -3 }, resultText = "You're not the social type." },
		},
	},
	{
		id = "viral_moment",
		minAge = 13, maxAge = 50,
		weight = 8, oneTime = true,
		emoji = "📱", title = "Going Viral!",
		category = "social",
		getDynamicData = function()
			local content = {"funny video", "dance clip", "cute pet post", "hot take tweet", "meme creation"}
			return { viralContent = content[math.random(#content)] }
		end,
		text = "Your %viralContent% is going viral! Millions of views!",
		choices = {
			{ text = "🌟 Ride the wave!", effects = { Happiness = 20, Looks = 5, Money = 5000 }, resultText = "You're internet famous! Sponsors incoming!", setFlags = {"viral_star", "influencer"} },
			{ text = "🙈 Delete everything", effects = { Happiness = -5 }, resultText = "Fame isn't for everyone." },
			{ text = "💰 Monetize it", effects = { Money = 20000, Happiness = 10 }, resultText = "Brand deals rolling in!" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════
	-- HEALTH EVENTS (MORE VARIETY)
	-- ═══════════════════════════════════════════════════════════
	{
		id = "mental_health_moment",
		minAge = 14, maxAge = 80,
		weight = 15, cooldown = 3,
		emoji = "🧠", title = "Mental Health Check",
		category = "health",
		text = "You've been feeling overwhelmed lately. Maybe it's time to talk to someone?",
		choices = {
			{ text = "🗣️ See a therapist", effects = { Happiness = 15, Health = 5, Money = -500 }, resultText = "Talking helped so much!", setFlag = "therapy_positive" },
			{ text = "📝 Start journaling", effects = { Happiness = 8, Smarts = 3 }, resultText = "Writing your feelings out helps." },
			{ text = "🧘 Try meditation", effects = { Happiness = 10, Health = 3 }, resultText = "Inner peace discovered.", setFlag = "mindful" },
			{ text = "💪 Push through", effects = { Health = -5, Happiness = -8 }, resultText = "Bottling it up wasn't the answer." },
		},
	},
	{
		id = "health_scare",
		minAge = 30, maxAge = 90,
		weight = 10, cooldown = 5,
		emoji = "🏥", title = "Health Scare",
		category = "health",
		text = "You had some concerning symptoms. The doctor wants to run tests.",
		choices = {
			{ text = "🔬 Get tested", effects = { Happiness = -5, Money = -1000 }, resultText = "False alarm! But good to check.", setFlag = "health_conscious" },
			{ text = "🙏 Hope for the best", effects = { Happiness = -10, Health = -10 }, resultText = "The anxiety is eating at you." },
			{ text = "💪 Lifestyle changes", effects = { Health = 10, Happiness = 5 }, resultText = "Wake-up call received. Getting healthy!" },
		},
	},
	{
		id = "new_hobby_discovery",
		minAge = 8, maxAge = 80,
		weight = 25, cooldown = 3,
		emoji = "🎨", title = "New Hobby!",
		category = "life",
		getDynamicData = function()
			local hobbies = {"painting", "guitar", "cooking", "photography", "gardening", "woodworking", "chess", "yoga"}
			return { hobby = hobbies[math.random(#hobbies)] }
		end,
		text = "You discovered a new interest in %hobby%! Should you pursue it?",
		choices = {
			{ text = "🎯 Dive in!", effects = { Happiness = 12, Smarts = 5 }, resultText = "You found your passion!", setFlag = "hobbyist" },
			{ text = "📚 Take a class", effects = { Happiness = 8, Smarts = 8, Money = -500 }, resultText = "Learning from experts!" },
			{ text = "🤷 Just dabble", effects = { Happiness = 5 }, resultText = "Casual interest is fine too." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════
	-- RANDOM LIFE EVENTS (MORE VARIETY)
	-- ═══════════════════════════════════════════════════════════
	{
		id = "found_money",
		minAge = 8, maxAge = 80,
		weight = 15, cooldown = 4,
		emoji = "💵", title = "Lucky Find!",
		category = "money",
		getDynamicData = function()
			local amounts = {20, 50, 100, 500}
			return { amount = amounts[math.random(#amounts)] }
		end,
		text = "You found $%amount% on the ground! What do you do?",
		choices = {
			{ text = "💰 Keep it!", effects = { Money = 100, Happiness = 8 }, resultText = "Finders keepers!" },
			{ text = "🔍 Look for owner", effects = { Happiness = 5, Smarts = 3 }, resultText = "No one claimed it. It's yours!", setFlag = "honest" },
			{ text = "🎁 Donate it", effects = { Happiness = 10 }, resultText = "Karma will reward you.", setFlag = "charitable" },
		},
	},
	{
		id = "car_trouble",
		minAge = 16, maxAge = 80,
		weight = 15, cooldown = 3,
		emoji = "🚗", title = "Car Trouble!",
		category = "life",
		text = "Your car broke down on the highway! Smoke is coming from the hood.",
		choices = {
			{ text = "📞 Call roadside assist", effects = { Money = -200 }, resultText = "They towed it to a shop." },
			{ text = "🔧 Fix it yourself", effects = { Smarts = 5, Health = -3 }, resultText = "YouTube tutorials saved the day!" },
			{ text = "👍 Hitchhike", effects = { Happiness = -5 }, resultText = "Sketchy but you made it home." },
		},
	},
	{
		id = "identity_theft",
		minAge = 18, maxAge = 80,
		weight = 8, oneTime = true,
		emoji = "🆔", title = "Identity Stolen!",
		category = "crime",
		text = "Someone stole your identity! Credit cards are maxed out in your name.",
		choices = {
			{ text = "🚔 Report to police", effects = { Money = -5000, Happiness = -15, Smarts = 3 }, resultText = "Long process but you'll recover.", setFlag = "identity_theft_victim" },
			{ text = "🏦 Dispute charges", effects = { Money = -2000, Happiness = -10 }, resultText = "Banks helped reverse some charges." },
			{ text = "🔐 Freeze credit", effects = { Smarts = 5, Happiness = -5 }, resultText = "Damage contained. Stay vigilant!" },
		},
	},
	{
		id = "random_kindness",
		minAge = 5, maxAge = 80,
		weight = 20, cooldown = 3,
		emoji = "💝", title = "Random Kindness",
		category = "social",
		getDynamicData = function()
			local acts = {"paid for your coffee", "helped you carry groceries", "gave you their parking spot", "shared their umbrella"}
			return { kindAct = acts[math.random(#acts)] }
		end,
		text = "A stranger %kindAct% today! Faith in humanity restored.",
		choices = {
			{ text = "🤗 Pay it forward", effects = { Happiness = 15 }, resultText = "You did something nice for someone else!", setFlag = "kind_hearted" },
			{ text = "😊 Just smile", effects = { Happiness = 10 }, resultText = "What a nice moment." },
			{ text = "🤔 Suspicious...", effects = { Smarts = 2 }, resultText = "Why are people so nice? Weird." },
		},
	},
	{
		id = "apartment_flood",
		minAge = 18, maxAge = 80,
		weight = 10, cooldown = 5,
		emoji = "🌊", title = "Flooded!",
		category = "life",
		text = "Your apartment flooded! Water damage everywhere.",
		choices = {
			{ text = "📞 Call insurance", effects = { Money = -1000 }, resultText = "Covered most of the damage!" },
			{ text = "🧹 Clean it yourself", effects = { Health = -5, Happiness = -10 }, resultText = "Days of work but you saved money." },
			{ text = "🏃 Move out", effects = { Money = -5000, Happiness = -15 }, resultText = "Fresh start needed." },
		},
	},
	{
		id = "jury_summons",
		minAge = 18, maxAge = 80,
		weight = 12, cooldown = 5,
		emoji = "⚖️", title = "Jury Duty!",
		category = "life",
		text = "You've been summoned for jury duty! A murder trial...",
		choices = {
			{ text = "⚖️ Serve civic duty", effects = { Smarts = 8, Happiness = -3, Money = -500 }, resultText = "Fascinating but stressful experience.", setFlag = "jury_served" },
			{ text = "🙅 Get excused", effects = { Happiness = 3 }, resultText = "Hardship exemption approved." },
			{ text = "🤔 Actually interesting", effects = { Smarts = 10, Happiness = 5 }, resultText = "You learned a lot about the legal system!" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════
	-- TRAVEL & ADVENTURE EVENTS
	-- ═══════════════════════════════════════════════════════════
	{
		id = "travel_opportunity",
		minAge = 18, maxAge = 70,
		weight = 12, cooldown = 3,
		emoji = "✈️", title = "Travel Opportunity!",
		category = "life",
		getDynamicData = function()
			local destinations = {"Paris", "Tokyo", "Bali", "New York", "London", "Dubai", "Sydney", "Rio"}
			return { destination = destinations[math.random(#destinations)] }
		end,
		text = "Cheap flights to %destination%! Only for the next 24 hours.",
		choices = {
			{ text = "✈️ Book it!", effects = { Money = -3000, Happiness = 20, Smarts = 5 }, resultText = "Best trip ever!", setFlag = "world_traveler" },
			{ text = "📅 Plan for later", effects = { Smarts = 2 }, resultText = "You'll go someday..." },
			{ text = "💰 Save the money", effects = { Money = 500 }, resultText = "Responsible but boring." },
		},
	},
	{
		id = "backpacking_trip",
		minAge = 18, maxAge = 35,
		weight = 10, oneTime = true,
		emoji = "🎒", title = "Backpacking Adventure!",
		category = "life",
		getDynamicData = function()
			local regions = {"Europe", "Southeast Asia", "South America", "Australia"}
			return { region = regions[math.random(#regions)] }
		end,
		text = "Your friend wants to backpack through %region% for 3 months!",
		choices = {
			{ text = "🌍 Let's go!", effects = { Money = -8000, Happiness = 30, Smarts = 10, Health = 5 }, resultText = "Life-changing adventure!", setFlags = {"backpacker", "adventurous", "world_traveler"} },
			{ text = "📅 Can't take time off", effects = { Happiness = -10 }, resultText = "Maybe after you retire..." },
			{ text = "🏠 Prefer comfort", effects = { Happiness = 3 }, resultText = "Hostels aren't for everyone." },
		},
	},
	{
		id = "road_trip",
		minAge = 16, maxAge = 70,
		weight = 15, cooldown = 3,
		emoji = "🚗", title = "Road Trip!",
		category = "life",
		text = "Friends want to do a weekend road trip! Are you in?",
		choices = {
			{ text = "🚗 Let's ride!", effects = { Money = -500, Happiness = 15 }, resultText = "Best weekend in a long time!" },
			{ text = "🎵 I'll DJ", effects = { Happiness = 12 }, resultText = "Your playlist was fire!" },
			{ text = "🏠 Can't make it", effects = { Happiness = -5 }, resultText = "FOMO is real." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════
	-- ENTERTAINMENT & POP CULTURE
	-- ═══════════════════════════════════════════════════════════
	{
		id = "concert_tickets",
		minAge = 14, maxAge = 60,
		weight = 15, cooldown = 3,
		emoji = "🎤", title = "Concert Alert!",
		category = "social",
		getDynamicData = function()
			local artists = {"your favorite artist", "a legendary band", "a new hot artist", "a famous DJ"}
			return { artist = artists[math.random(#artists)] }
		end,
		text = "%artist% is coming to town! VIP tickets are $500, regular are $100.",
		choices = {
			{ text = "🌟 VIP please!", effects = { Money = -500, Happiness = 20 }, resultText = "Best concert ever! Front row vibes!", setFlag = "concert_goer" },
			{ text = "🎫 Regular tickets", effects = { Money = -100, Happiness = 12 }, resultText = "Great show from the crowd!" },
			{ text = "📺 Watch livestream", effects = { Happiness = 5 }, resultText = "Not the same but still cool." },
		},
	},
	{
		id = "movie_premiere",
		minAge = 13, maxAge = 60,
		weight = 12, cooldown = 4,
		emoji = "🎬", title = "Movie Premiere!",
		category = "social",
		getDynamicData = function()
			local movies = {"the biggest blockbuster", "a superhero movie", "an Oscar contender", "a highly anticipated sequel"}
			return { movie = movies[math.random(#movies)] }
		end,
		text = "%movie% of the year is premiering! Want to see it opening night?",
		choices = {
			{ text = "🍿 Opening night!", effects = { Money = -30, Happiness = 12 }, resultText = "No spoilers! Great experience!" },
			{ text = "⏰ Wait for streaming", effects = { Money = 15, Happiness = 3 }, resultText = "Patience pays off." },
			{ text = "📱 Already spoiled", effects = { Happiness = -5 }, resultText = "Social media ruined it." },
		},
	},
	{
		id = "gaming_addiction",
		minAge = 10, maxAge = 40,
		weight = 15, cooldown = 4,
		emoji = "🎮", title = "Gaming Life",
		category = "social",
		getDynamicData = function()
			local games = {"a new AAA game", "a battle royale", "an MMO", "a mobile game"}
			return { game = games[math.random(#games)] }
		end,
		text = "You've been playing %game% for 12 hours straight...",
		choices = {
			{ text = "🎮 One more hour", effects = { Happiness = 5, Health = -5, Smarts = -3 }, resultText = "Just one more... okay maybe two.", setFlag = "gamer" },
			{ text = "🛏️ Go to sleep", effects = { Health = 3 }, resultText = "Rest is important." },
			{ text = "🚿 Touch grass", effects = { Health = 5, Happiness = 3 }, resultText = "Outside world still exists!" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════
	-- PET EVENTS
	-- ═══════════════════════════════════════════════════════════
	{
		id = "stray_animal",
		minAge = 8, maxAge = 70,
		weight = 15, cooldown = 4,
		emoji = "🐾", title = "Stray Found!",
		category = "life",
		getDynamicData = function()
			local animals = {"dog", "cat", "kitten", "puppy"}
			local animal = animals[math.random(#animals)]
			local emojiMap = {
				dog = "🐕",
				puppy = "🐕‍🦺",
				cat = "🐈",
				kitten = "🐈‍⬛",
			}

			local scenarioRoll = math.random()
			local condition
			local keepCost = math.random(200, 500)
			local shelterFee = math.random(40, 160)
			local feedCost = math.random(15, 50)
			local keepHealthLoss = 0
			local shelterHealthLoss = 0

			if scenarioRoll < 0.4 then
				condition = "It keeps nudging your leg like it already knows you."
			elseif scenarioRoll < 0.75 then
				condition = "It's terrified and snaps when anyone gets too close."
				if math.random() < 0.6 then
					shelterHealthLoss = math.random(2, 6)
				end
			else
				condition = "It's bleeding from a cut and shaking in pain."
				keepCost = keepCost + math.random(250, 400)
				keepHealthLoss = math.random(3, 7)
				shelterHealthLoss = math.random(3, 6)
			end

			if math.random() < 0.35 then
				keepHealthLoss = math.max(keepHealthLoss, math.random(2, 5))
			end

			return {
				animal = animal,
				eventEmoji = emojiMap[animal] or "🐾",
				condition = condition,
				keepCost = keepCost,
				shelterFee = shelterFee,
				feedCost = feedCost,
				keepHealthLoss = keepHealthLoss,
				shelterHealthLoss = shelterHealthLoss,
				keepResult = (keepHealthLoss > 0)
					and string.format("It lashed out (-%d Health) until the vet patched it up ($%d). Now it won't leave your side.", keepHealthLoss, keepCost)
					or string.format("Paperwork signed and supplies bought ($%d). Instant new roommate.", keepCost),
				shelterResult = (shelterHealthLoss > 0)
					and string.format("It scratched you (-%d Health) on the way, but the shelter took over.", shelterHealthLoss)
					or "The shelter scanned its microchip and called the owner. Hero status!",
				feedResult = string.format("You fed it ($%d) and posted everywhere. Someone offered to foster within the hour.", feedCost),
				ignoreResult = "You walked away. It eventually wandered off into the night.",
			}
		end,
		text = "You found a stray %animal%! %condition%",
		choices = {
			{
				text = "🏠 Adopt it!",
				effects = { Happiness = 15 },
				dynamicEffects = function(_, data)
					return {
						Money = data.keepCost and -data.keepCost or 0,
						Health = data.keepHealthLoss and -data.keepHealthLoss or 0,
					}
				end,
				resultText = "%keepResult%",
				resultEmoji = "%eventEmoji%",
				setFlags = {"pet_owner", "animal_lover"},
				addAsset = { type = "item", id = "rescue_pet", name = "Rescue Pet", value = 0 },
			},
			{
				text = "🏥 Take to shelter",
				effects = { Happiness = 6 },
				dynamicEffects = function(_, data)
					return {
						Money = data.shelterFee and -data.shelterFee or 0,
						Health = data.shelterHealthLoss and -data.shelterHealthLoss or 0,
					}
				end,
				resultText = "%shelterResult%",
				resultEmoji = "%eventEmoji%",
			},
			{
				text = "🍖 Just feed it",
				effects = { Happiness = 3 },
				dynamicEffects = function(_, data)
					return {
						Money = data.feedCost and -data.feedCost or 0,
					}
				end,
				resultText = "%feedResult%",
				resultEmoji = "%eventEmoji%",
			},
			{
				text = "🚶 Keep walking",
				effects = { Happiness = -4 },
				resultText = "%ignoreResult%",
			},
		},
	},
	{
		id = "pet_sick",
		minAge = 8, maxAge = 80,
		weight = 12, cooldown = 4,
		emoji = "🩺", title = "Pet Emergency!",
		category = "life",
		requiresFlag = "pet_owner",
		text = "Your pet is acting strange. Something's wrong!",
		choices = {
			{ text = "🏥 Emergency vet!", effects = { Money = -2000, Happiness = -10 }, resultText = "They'll be okay. Expensive but worth it." },
			{ text = "💊 Home remedies", effects = { Happiness = -15 }, resultText = "It got worse. Should've gone to vet." },
			{ text = "⏰ Wait and see", effects = { Happiness = -20 }, resultText = "They need professional help..." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════
	-- UNIQUE LIFE MOMENTS
	-- ═══════════════════════════════════════════════════════════
	{
		id = "celebrity_encounter",
		minAge = 10, maxAge = 80,
		weight = 5, oneTime = true,
		emoji = "⭐", title = "Celebrity Sighting!",
		category = "social",
		getDynamicData = function()
			local celebs = {"a famous actor", "a popular musician", "a sports legend", "a famous YouTuber"}
			return { celebrity = celebs[math.random(#celebs)] }
		end,
		text = "You spotted %celebrity% at a coffee shop! They're alone!",
		choices = {
			{ text = "📸 Ask for selfie", effects = { Happiness = 15 }, resultText = "They were so nice! Great photo!", setFlag = "met_celebrity" },
			{ text = "👋 Say hi respectfully", effects = { Happiness = 10 }, resultText = "Brief but cool interaction!" },
			{ text = "😎 Play it cool", effects = { Smarts = 3 }, resultText = "You respected their privacy." },
			{ text = "📱 Post location", effects = { Smarts = -5 }, resultText = "That was kind of uncool..." },
		},
	},
	{
		id = "winning_streak",
		minAge = 18, maxAge = 80,
		weight = 8, cooldown = 5,
		emoji = "🍀", title = "Lucky Day!",
		category = "money",
		text = "Everything is going your way today! What do you try your luck on?",
		choices = {
			{ text = "🎰 Hit the casino", effects = { Money = 10000, Happiness = 15 }, resultText = "You're on fire! Big win!" },
			{ text = "📈 Buy stocks", effects = { Money = 5000, Smarts = 3 }, resultText = "Great timing! Portfolio up!" },
			{ text = "🙏 Don't push it", effects = { Happiness = 5, Smarts = 5 }, resultText = "Wise. Luck runs out." },
		},
	},
	{
		id = "deja_vu",
		minAge = 12, maxAge = 80,
		weight = 20, cooldown = 5,
		emoji = "🔄", title = "Déjà Vu",
		category = "life",
		text = "Wait... this all feels very familiar. Have you been here before?",
		choices = {
			{ text = "🤔 Ponder it deeply", effects = { Smarts = 3, Happiness = 2 }, resultText = "The mysteries of the mind..." },
			{ text = "😅 Weird feeling", effects = { Happiness = 1 }, resultText = "That was strange." },
			{ text = "🌌 Multiverse theory!", effects = { Smarts = 5, Happiness = 5 }, resultText = "Maybe you're living multiple lives!" },
		},
	},
	{
		id = "near_miss",
		minAge = 16, maxAge = 80,
		weight = 10, cooldown = 5,
		emoji = "😰", title = "Close Call!",
		category = "life",
		getDynamicData = function()
			local situations = {"almost got hit by a car", "narrowly missed a falling tree", "just missed a delayed flight that crashed", "stepped away right before an accident"}
			return { situation = situations[math.random(#situations)] }
		end,
		text = "You %situation%. That was terrifyingly close!",
		choices = {
			{ text = "🙏 Thank the universe", effects = { Happiness = 5 }, resultText = "Someone's watching over you." },
			{ text = "😱 Shaken up", effects = { Happiness = -10, Health = -5 }, resultText = "Can't stop thinking about it." },
			{ text = "💪 Life is precious", effects = { Happiness = 10 }, resultText = "You appreciate every day more now.", setFlag = "perspective_gained" },
		},
	},
}

-- Add diverse events to main table
for _, event in ipairs(diverseEvents) do
	table.insert(events, event)
end
print("[EventLibrary] Added", #diverseEvents, "diverse life path events!")

-- ═══════════════════════════════════════════════════════════════════
-- ADDITIONAL EVENT BATCHES FOR EVEN MORE VARIETY
-- ═══════════════════════════════════════════════════════════════════

local moreEvents = {
	-- More unique scenarios
	{
		id = "inherited_property",
		minAge = 25, maxAge = 70,
		weight = 5, oneTime = true,
		emoji = "🏠", title = "Inheritance!",
		category = "money",
		getDynamicData = function()
			return { relativeName = randomName() }
		end,
		text = "Your distant relative %relativeName% left you property in their will!",
		choices = {
			{ text = "🏠 Keep it!", effects = { Happiness = 15 }, resultText = "You own property now!", addAsset = { type = "property", id = "inherited_home", name = "Inherited Home", value = 150000 } },
			{ text = "💰 Sell it", effects = { Money = 150000, Happiness = 10 }, resultText = "Nice inheritance check!" },
			{ text = "🏘️ Rent it out", effects = { Money = 2000, Happiness = 8 }, resultText = "Passive income stream!", setFlag = "landlord" },
		},
	},
	{
		id = "talent_show",
		minAge = 8, maxAge = 30,
		weight = 15, cooldown = 4,
		emoji = "🎤", title = "Talent Show!",
		category = "social",
		getDynamicData = function()
			local talents = {"singing", "dancing", "comedy", "magic tricks", "instrument playing"}
			return { talent = talents[math.random(#talents)] }
		end,
		text = "There's a talent show coming up! You could perform your %talent%.",
		choices = {
			{ text = "🌟 Perform!", effects = { Happiness = 15, Looks = 5 }, resultText = "Standing ovation! You're talented!", setFlag = "performer" },
			{ text = "👀 Just watch", effects = { Happiness = 5 }, resultText = "Fun to see others perform." },
			{ text = "😰 Too nervous", effects = { Happiness = -5 }, resultText = "Stage fright is real." },
		},
	},
	{
		id = "secret_admirer",
		minAge = 14, maxAge = 40,
		weight = 12, cooldown = 4,
		emoji = "💌", title = "Secret Admirer!",
		category = "social",
		text = "Someone left you an anonymous love letter! Who could it be?",
		choices = {
			{ text = "🔍 Investigate!", effects = { Happiness = 10, Smarts = 3 }, resultText = "You found out who it was! Cute!", setFlag = "romantic" },
			{ text = "💕 Flattered!", effects = { Happiness = 8, Looks = 3 }, resultText = "Mystery keeps it exciting." },
			{ text = "😬 Kinda creepy", effects = { Happiness = -3 }, resultText = "You prefer direct approaches." },
		},
	},
	{
		id = "neighborhood_watch",
		minAge = 25, maxAge = 70,
		weight = 10, cooldown = 5,
		emoji = "👀", title = "Neighborhood Watch",
		category = "social",
		text = "Your neighbors are forming a neighborhood watch. They want you to join.",
		choices = {
			{ text = "🦸 Sign me up!", effects = { Happiness = 5, Smarts = 3 }, resultText = "You're a community protector!", setFlag = "community_involved" },
			{ text = "📞 Just the group chat", effects = { Happiness = 2 }, resultText = "Staying informed without commitment." },
			{ text = "🙄 Too nosy", effects = { Happiness = -3 }, resultText = "You like your privacy." },
		},
	},
	{
		id = "diy_project",
		minAge = 18, maxAge = 70,
		weight = 15, cooldown = 3,
		emoji = "🔨", title = "DIY Project!",
		category = "life",
		getDynamicData = function()
			local projects = {"deck building", "bathroom renovation", "garden landscaping", "furniture making", "home automation"}
			return { project = projects[math.random(#projects)] }
		end,
		text = "You want to try %project% yourself instead of hiring someone.",
		choices = {
			{ text = "🛠️ DIY time!", effects = { Smarts = 8, Happiness = 10, Health = -3 }, resultText = "Hard work but it looks amazing!", setFlag = "handy" },
			{ text = "📺 YouTube tutorials", effects = { Smarts = 5, Happiness = 5 }, resultText = "Learning as you go!" },
			{ text = "👷 Hire a pro", effects = { Money = -3000, Happiness = 5 }, resultText = "Done right, no stress." },
		},
	},
	{
		id = "book_club",
		minAge = 18, maxAge = 80,
		weight = 12, cooldown = 4,
		emoji = "📚", title = "Book Club Invite",
		category = "social",
		text = "Someone invited you to join their book club. Monthly meetings.",
		choices = {
			{ text = "📖 Join!", effects = { Smarts = 8, Happiness = 5 }, resultText = "Great discussions and new friends!", setFlag = "intellectual" },
			{ text = "🎧 Prefer audiobooks", effects = { Smarts = 3 }, resultText = "Reading at your own pace." },
			{ text = "📺 Books? What are those?", effects = { Happiness = 2, Smarts = -3 }, resultText = "You'll stick to Netflix." },
		},
	},
	{
		id = "cooking_disaster",
		minAge = 14, maxAge = 80,
		weight = 20, cooldown = 3,
		emoji = "🔥", title = "Kitchen Disaster!",
		category = "life",
		getDynamicData = function()
			local dishes = {"fancy dinner", "birthday cake", "holiday meal", "impressive first date meal"}
			return { dish = dishes[math.random(#dishes)] }
		end,
		text = "You tried to make a %dish% but it went horribly wrong!",
		choices = {
			{ text = "🍕 Order takeout", effects = { Money = -50, Happiness = 3 }, resultText = "Pizza saves the day!" },
			{ text = "🔄 Try again!", effects = { Smarts = 5, Happiness = -3 }, resultText = "Second attempt was better!" },
			{ text = "😭 Just cry", effects = { Happiness = -8 }, resultText = "Cooking isn't for everyone." },
		},
	},
	{
		id = "garage_sale_find",
		minAge = 12, maxAge = 80,
		weight = 15, cooldown = 4,
		emoji = "🏷️", title = "Garage Sale Treasure!",
		category = "money",
		getDynamicData = function()
			local items = {"vintage video game", "antique vase", "rare baseball card", "designer handbag", "old vinyl record"}
			return { item = items[math.random(#items)] }
		end,
		text = "You found a %item% at a garage sale for only $5. It looks valuable!",
		choices = {
			{ text = "💰 Buy and resell!", effects = { Money = 2000, Smarts = 5 }, resultText = "Sold for $2000! Great eye!", setFlag = "treasure_hunter" },
			{ text = "🏠 Keep it!", effects = { Happiness = 8 }, resultText = "Cool addition to your collection!" },
			{ text = "🤷 Pass on it", effects = { Smarts = -3 }, resultText = "Someone else got rich instead." },
		},
	},
	{
		id = "public_speaking",
		minAge = 14, maxAge = 70,
		weight = 12, cooldown = 4,
		emoji = "🎤", title = "Public Speaking!",
		category = "work",
		getDynamicData = function()
			local venues = {"class presentation", "work meeting", "community event", "wedding speech"}
			return { venue = venues[math.random(#venues)] }
		end,
		text = "You have to give a speech at a %venue%. Nervous?",
		choices = {
			{ text = "🎯 Nail it!", effects = { Smarts = 8, Happiness = 10, Looks = 3 }, resultText = "Everyone was impressed!", setFlag = "public_speaker" },
			{ text = "📝 Read from notes", effects = { Smarts = 3, Happiness = 3 }, resultText = "Got through it!" },
			{ text = "😰 Bomb it", effects = { Happiness = -15 }, resultText = "That was embarrassing..." },
		},
	},
	{
		id = "volunteer_opportunity",
		minAge = 12, maxAge = 80,
		weight = 15, cooldown = 4,
		emoji = "🤝", title = "Volunteer Work",
		category = "social",
		getDynamicData = function()
			local causes = {"animal shelter", "homeless shelter", "environmental cleanup", "tutoring kids", "elderly care"}
			return { cause = causes[math.random(#causes)] }
		end,
		text = "There's a volunteer opportunity at the local %cause%.",
		choices = {
			{ text = "🤝 Sign up!", effects = { Happiness = 15, Smarts = 3 }, resultText = "Making a difference feels amazing!", setFlags = {"volunteer", "charitable"} },
			{ text = "💵 Donate instead", effects = { Money = -100, Happiness = 5 }, resultText = "Money helps too!" },
			{ text = "⏰ Too busy", effects = { Happiness = -3 }, resultText = "Maybe another time." },
		},
	},
}

-- Add more events
for _, event in ipairs(moreEvents) do
	table.insert(events, event)
end
print("[EventLibrary] Added", #moreEvents, "additional variety events!")

-- Final count
print("[EventLibrary] ✅ Total events loaded:", #events)

return EventLibrary
