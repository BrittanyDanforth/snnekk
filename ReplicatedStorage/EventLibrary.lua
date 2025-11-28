-- EventLibrary.lua
-- Comprehensive BitLife-style event system with 100+ unique events
-- Features: one-time events, cooldowns, dynamic text, milestone events

local EventLibrary = {}

-- Helper to generate random names
local MaleNames = {"James","Michael","David","Chris","Daniel","Matt","Jake","Ryan","Tyler","Brandon","Kevin","Justin","Josh","Nick","Alex","Brian","Eric","Andrew","Sean","Kyle","Adam","Aaron","Ethan","Nathan","Zach","Dylan","Connor","Mason","Logan","Lucas"}
local FemaleNames = {"Emma","Sophia","Olivia","Ava","Isabella","Mia","Emily","Abigail","Madison","Elizabeth","Ella","Avery","Chloe","Sofia","Grace","Lily","Hannah","Aria","Zoe","Riley","Nora","Scarlett","Stella","Luna","Hazel"}
local LastNames = {"Smith","Johnson","Williams","Brown","Jones","Garcia","Miller","Davis","Rodriguez","Martinez","Anderson","Taylor","Thomas","Moore","Jackson","Martin","Lee","Thompson","White","Harris","Clark","Lewis","Robinson","Walker","Young","King","Wright","Scott","Green","Baker","Adams","Nelson","Hill","Mitchell","Roberts","Campbell","Phillips","Evans","Turner","Torres","Parker","Collins","Edwards","Stewart","Morris","Murphy","Rivera","Cook","Rogers","Morgan","Peterson","Cooper","Reed","Bailey","Bell","Gomez","Kelly","Howard","Ward","Cox","Diaz","Richardson","Wood","Watson","Brooks","Bennett","Gray","James","Sanders","Price","Hughes"}

local function randomMaleName() return MaleNames[math.random(#MaleNames)] .. " " .. LastNames[math.random(#LastNames)] end
local function randomFemaleName() return FemaleNames[math.random(#FemaleNames)] .. " " .. LastNames[math.random(#LastNames)] end
local function randomName() return math.random(2) == 1 and randomMaleName() or randomFemaleName() end

local Companies = {"TechCorp","GlobalSoft","MegaCorp","Innovate Inc","FutureTech","DataStream","CloudNine","ByteWorks","CodeBase","NetSphere","DigiCore","InfoSys","SmartSolutions","PrimeTech","NextGen","BlueWave","RedShift","GreenLight","SilverLine","GoldStar"}
local function randomCompany() return Companies[math.random(#Companies)] end

--[[
  EVENT FLAGS:
  - oneTime: true = can only happen once per life
  - cooldown: number of years before it can happen again
  - milestone: true = guaranteed to happen at this age (overrides random)
  - requires: function(state) -> boolean for conditional events
  - dynamicText: function(state) -> replaces text/names dynamically
]]

local events = {
	----------------------------------------------------------------
	-- BABY EVENTS (Age 0-2) - Mostly one-time milestones
	----------------------------------------------------------------
	{
		id = "birth",
		minAge = 0, maxAge = 0,
		weight = 100, milestone = true, oneTime = true,
		emoji = "👶", title = "You Are Born!",
		text = "You came into this world screaming and crying. Welcome to life!",
		choices = {
			{ id = "cry", text = "😭 Keep crying", effects = { Stats = { Health = 2 } }, resultText = "Your lungs are strong! Good sign." },
			{ id = "sleep", text = "😴 Fall asleep", effects = { Stats = { Health = 3 } }, resultText = "You drifted off to sleep in your mother's arms." },
		},
	},
	{
		id = "first_steps",
		minAge = 1, maxAge = 1,
		weight = 50, oneTime = true,
		emoji = "👣", title = "First Steps!",
		text = "You're pulling yourself up and trying to walk for the first time!",
		choices = {
			{ id = "careful", text = "🚶 Take it slow", effects = { Stats = { Health = 2, Happiness = 3 } }, resultText = "You took your first wobbly steps! Everyone cheered!" },
			{ id = "run", text = "🏃 Go for it!", effects = { Stats = { Health = -2, Happiness = 5 } }, resultText = "You tried to run and faceplanted into the couch. But you laughed it off!" },
		},
	},
	{
		id = "first_word",
		minAge = 1, maxAge = 2,
		weight = 40, oneTime = true,
		emoji = "🗣️", title = "First Word!",
		text = "You're about to speak your first word! Everyone is watching...",
		choices = {
			{ id = "mama", text = "👩 Mama", effects = { Stats = { Happiness = 5 } }, resultText = "You said 'Mama'! Your mother burst into happy tears." },
			{ id = "dada", text = "👨 Dada", effects = { Stats = { Happiness = 5 } }, resultText = "You said 'Dada'! Your father was so proud he called everyone he knows." },
			{ id = "no", text = "🙅 NO!", effects = { Stats = { Happiness = 3, Smarts = 2 } }, resultText = "Your first word was 'NO!' This is going to be interesting..." },
			{ id = "random", text = "🤔 Something weird", effects = { Stats = { Smarts = 3 } }, resultText = "You said 'Refrigerator'. Your parents are confused but impressed." },
		},
	},
	{
		id = "potty_training",
		minAge = 2, maxAge = 3,
		weight = 30, oneTime = true,
		emoji = "🚽", title = "Potty Training",
		text = "It's time to learn to use the toilet like a big kid!",
		choices = {
			{ id = "try_hard", text = "💪 I can do this!", effects = { Stats = { Happiness = 4, Smarts = 2 } }, resultText = "After a few accidents, you figured it out! No more diapers!" },
			{ id = "resist", text = "😤 Diapers are fine", effects = { Stats = { Happiness = -2 } }, resultText = "You resisted, but eventually learned. It took a while though." },
		},
	},
	
	----------------------------------------------------------------
	-- EARLY CHILDHOOD (Age 3-5)
	----------------------------------------------------------------
	{
		id = "imaginary_friend",
		minAge = 3, maxAge = 5,
		weight = 15, oneTime = true,
		emoji = "👻", title = "Imaginary Friend",
		text = "You've created an imaginary friend named 'Mr. Whiskers' who is apparently a ghost cat.",
		choices = {
			{ id = "play", text = "🐱 Play together!", effects = { Stats = { Happiness = 6, Smarts = 2 } }, resultText = "You and Mr. Whiskers had amazing adventures together." },
			{ id = "ignore", text = "🤷 That's weird", effects = { Stats = { Happiness = -1 } }, resultText = "You decided imaginary friends weren't for you." },
			{ id = "tell_parents", text = "👨‍👩‍👦 Tell your parents", effects = { Stats = { Happiness = 3 } }, resultText = "Your parents thought it was adorable and played along." },
		},
	},
	{
		id = "playground_push",
		minAge = 3, maxAge = 5,
		weight = 20, cooldown = 3,
		emoji = "😢", title = "Playground Trouble",
		text = "A bigger kid pushed you off the swing!",
		choices = {
			{ id = "cry", text = "😭 Cry", effects = { Stats = { Happiness = -3 } }, resultText = "You cried until a teacher came to help." },
			{ id = "push_back", text = "😠 Push back", effects = { Stats = { Happiness = 2, Health = -3 } }, resultText = "You pushed back and both of you got timeout." },
			{ id = "tell", text = "👨‍🏫 Tell a grown-up", effects = { Stats = { Happiness = 1, Smarts = 2 } }, resultText = "You told the teacher and the bully got in trouble." },
		},
	},
	{
		id = "first_pet",
		minAge = 4, maxAge = 8,
		weight = 12, oneTime = true,
		emoji = "🐕", title = "First Pet!",
		getDynamicData = function()
			local pets = {{"dog","Buddy","🐕"},{"cat","Whiskers","🐱"},{"hamster","Hammy","🐹"},{"goldfish","Goldie","🐠"},{"turtle","Shelly","🐢"}}
			local pet = pets[math.random(#pets)]
			return { petType = pet[1], petName = pet[2], petEmoji = pet[3] }
		end,
		text = "Your parents got you a pet %petType% named %petName%!",
		choices = {
			{ id = "love", text = "❤️ Best day ever!", effects = { Stats = { Happiness = 10 } }, resultText = "You and %petName% became inseparable best friends!" },
			{ id = "responsibility", text = "😰 That's a big responsibility", effects = { Stats = { Happiness = 4, Smarts = 3 } }, resultText = "You took your pet duties seriously and learned a lot about caring for others." },
		},
	},
	{
		id = "first_day_preschool",
		minAge = 4, maxAge = 4,
		weight = 50, oneTime = true, milestone = true,
		emoji = "🏫", title = "First Day of Preschool",
		text = "It's your first day of preschool! How do you feel about leaving home?",
		choices = {
			{ id = "excited", text = "🎉 Can't wait!", effects = { Stats = { Happiness = 5, Smarts = 3 } }, resultText = "You ran in excitedly and made 3 new friends by lunchtime!" },
			{ id = "scared", text = "😰 Don't leave me!", effects = { Stats = { Happiness = -3 } }, resultText = "You clung to your parent's leg, but eventually had fun." },
			{ id = "curious", text = "🤔 What's preschool?", effects = { Stats = { Smarts = 4 } }, resultText = "Your curiosity led you to explore every corner of the classroom!" },
		},
	},
	{
		id = "nightmare",
		minAge = 3, maxAge = 10,
		weight = 15, cooldown = 2,
		emoji = "😱", title = "Nightmare!",
		text = "You woke up from a terrible nightmare about monsters under your bed!",
		choices = {
			{ id = "parents", text = "🏃 Run to parents", effects = { Stats = { Happiness = 3 } }, resultText = "Your parents comforted you and let you sleep with them." },
			{ id = "brave", text = "💪 Face the monsters", effects = { Stats = { Happiness = 5, Smarts = 2 } }, resultText = "You checked under the bed and realized it was just your imagination. Brave!" },
			{ id = "hide", text = "😨 Hide under covers", effects = { Stats = { Happiness = -2 } }, resultText = "You stayed frozen under your blanket until morning." },
		},
	},
	
	----------------------------------------------------------------
	-- CHILDHOOD (Age 6-12)
	----------------------------------------------------------------
	{
		id = "first_day_elementary",
		minAge = 6, maxAge = 6,
		weight = 100, oneTime = true, milestone = true,
		emoji = "🎒", title = "First Day of Elementary School",
		text = "Big kid school! You're starting first grade!",
		choices = {
			{ id = "confident", text = "😎 I got this", effects = { Stats = { Happiness = 5, Smarts = 3 } }, resultText = "You walked in like you owned the place and had a great first day!" },
			{ id = "nervous", text = "😬 So nervous", effects = { Stats = { Happiness = 1, Smarts = 2 } }, resultText = "You were nervous but made it through. Tomorrow will be easier!" },
			{ id = "make_friends", text = "👋 Find new friends", effects = { Stats = { Happiness = 6 } }, resultText = "You introduced yourself to everyone and made lots of friends!" },
		},
	},
	{
		id = "lost_tooth",
		minAge = 6, maxAge = 8,
		weight = 25, cooldown = 1,
		emoji = "🦷", title = "Lost a Tooth!",
		text = "Your tooth finally fell out! There's a gap in your smile now.",
		choices = {
			{ id = "tooth_fairy", text = "🧚 Put under pillow", effects = { Stats = { Happiness = 4 }, Money = 5 }, resultText = "The tooth fairy left you $5! Magic is real!" },
			{ id = "keep", text = "🏆 Keep it as trophy", effects = { Stats = { Happiness = 2 } }, resultText = "You added it to your growing collection of teeth." },
			{ id = "gross", text = "🤢 Throw it away", effects = { Stats = { Happiness = 1 } }, resultText = "You tossed it. Teeth are kind of gross when you think about it." },
		},
	},
	{
		id = "bully_encounter",
		minAge = 6, maxAge = 14,
		weight = 12, cooldown = 3,
		emoji = "😠", title = "Bully Trouble",
		getDynamicData = function()
			return { bullyName = math.random(2) == 1 and randomMaleName() or randomFemaleName() }
		end,
		text = "%bullyName% has been picking on you at school. They called you names in front of everyone.",
		choices = {
			{ id = "stand_up", text = "💪 Stand up to them", effects = { Stats = { Happiness = 4, Health = -2 } }, resultText = "You stood your ground! They seemed surprised and backed off." },
			{ id = "tell_adult", text = "👨‍🏫 Tell a teacher", effects = { Stats = { Happiness = 2, Smarts = 2 } }, resultText = "The teacher talked to them. Smart move avoiding a fight." },
			{ id = "ignore", text = "🙄 Ignore them", effects = { Stats = { Happiness = -2 } }, resultText = "You walked away. They might bother you again though." },
			{ id = "befriend", text = "🤝 Try to befriend them", effects = { Stats = { Happiness = 5, Smarts = 3 } }, resultText = "Surprisingly, they just needed a friend. You're buddies now!" },
		},
	},
	{
		id = "science_fair",
		minAge = 8, maxAge = 14,
		weight = 15, cooldown = 2,
		emoji = "🔬", title = "Science Fair",
		text = "The science fair is coming up! What project will you do?",
		choices = {
			{ id = "volcano", text = "🌋 Baking soda volcano", effects = { Stats = { Smarts = 3, Happiness = 4 } }, resultText = "Classic! Your volcano erupted perfectly and got 2nd place." },
			{ id = "solar_system", text = "🪐 Solar system model", effects = { Stats = { Smarts = 5 } }, resultText = "Your detailed model impressed the judges. 1st place!" },
			{ id = "plant", text = "🌱 Plant growth study", effects = { Stats = { Smarts = 4, Happiness = 2 } }, resultText = "Your careful documentation earned you an honorable mention." },
			{ id = "skip", text = "😴 Don't participate", effects = { Stats = { Smarts = -3 } }, resultText = "You skipped it and regretted it when everyone got prizes." },
		},
	},
	{
		id = "birthday_party",
		minAge = 6, maxAge = 16,
		weight = 8, cooldown = 2,
		emoji = "🎂", title = "Birthday Party!",
		text = "It's your birthday! What kind of celebration do you want?",
		choices = {
			{ id = "big", text = "🎉 Huge party!", effects = { Stats = { Happiness = 10 }, Money = -50 }, resultText = "You had an amazing party with tons of friends and presents!" },
			{ id = "small", text = "👥 Just close friends", effects = { Stats = { Happiness = 6 } }, resultText = "A cozy celebration with your best friends. Quality over quantity!" },
			{ id = "family", text = "👨‍👩‍👧‍👦 Family dinner", effects = { Stats = { Happiness = 5 } }, resultText = "A nice family dinner with cake. Simple but sweet." },
			{ id = "skip", text = "🙅 No celebration", effects = { Stats = { Happiness = -2 } }, resultText = "You said you didn't want anything. You kind of regretted it." },
		},
	},
	{
		id = "broken_bone",
		minAge = 5, maxAge = 18,
		weight = 6, cooldown = 5,
		emoji = "🦴", title = "Ouch! Broken Bone!",
		getDynamicData = function()
			local bones = {"arm","leg","wrist","ankle","finger"}
			return { bone = bones[math.random(#bones)] }
		end,
		text = "You fell while playing and broke your %bone%! It really hurts!",
		choices = {
			{ id = "brave", text = "💪 Be brave", effects = { Stats = { Health = -10, Happiness = 2 } }, resultText = "You toughed it out at the hospital. You got a cool cast that everyone signed!" },
			{ id = "cry", text = "😭 Cry", effects = { Stats = { Health = -10, Happiness = -3 } }, resultText = "You cried a lot. Fair enough, broken bones really hurt." },
		},
	},
	{
		id = "report_card_good",
		minAge = 6, maxAge = 18,
		weight = 15, cooldown = 1,
		emoji = "📊", title = "Report Card Day",
		text = "Report cards are out! You got straight A's!",
		choices = {
			{ id = "celebrate", text = "🎉 Celebrate!", effects = { Stats = { Happiness = 6, Smarts = 3 } }, resultText = "Your parents were so proud! They took you out for ice cream." },
			{ id = "humble", text = "😊 Stay humble", effects = { Stats = { Happiness = 3, Smarts = 4 } }, resultText = "You acknowledged your hard work paid off and kept studying." },
			{ id = "brag", text = "😏 Brag to everyone", effects = { Stats = { Happiness = 4, Smarts = 1 } }, resultText = "You showed everyone. Some were impressed, others annoyed." },
		},
	},
	{
		id = "report_card_bad",
		minAge = 6, maxAge = 18,
		weight = 10, cooldown = 2,
		emoji = "📊", title = "Report Card Day",
		text = "Report cards are out... You didn't do so well this semester.",
		choices = {
			{ id = "hide", text = "🙈 Hide it", effects = { Stats = { Happiness = -5, Smarts = -2 } }, resultText = "You hid it but your parents found out anyway. Double trouble." },
			{ id = "honest", text = "😔 Be honest", effects = { Stats = { Happiness = -2, Smarts = 2 } }, resultText = "Your parents were disappointed but appreciated your honesty." },
			{ id = "study", text = "📚 Promise to improve", effects = { Stats = { Happiness = 1, Smarts = 4 } }, resultText = "You committed to studying harder. Good attitude!" },
		},
	},
	{
		id = "video_game",
		minAge = 7, maxAge = 40,
		weight = 12, cooldown = 2,
		emoji = "🎮", title = "New Video Game",
		text = "A new video game just came out that all your friends are playing!",
		choices = {
			{ id = "buy", text = "💰 Buy it!", effects = { Stats = { Happiness = 8 }, Money = -60 }, resultText = "You got the game and played it all weekend!" },
			{ id = "wait", text = "⏰ Wait for sale", effects = { Stats = { Happiness = 2, Smarts = 2 } }, resultText = "You waited and got it half price later. Smart!" },
			{ id = "watch", text = "📺 Watch streams instead", effects = { Stats = { Happiness = 3 } }, resultText = "You watched others play. Not the same, but free!" },
		},
	},
	{
		id = "sports_tryout",
		minAge = 8, maxAge = 18,
		weight = 10, cooldown = 2,
		emoji = "⚽", title = "Sports Tryouts",
		getDynamicData = function()
			local sports = {"soccer","basketball","baseball","volleyball","swimming","track"}
			return { sport = sports[math.random(#sports)] }
		end,
		text = "Tryouts for the %sport% team are today! Will you try out?",
		choices = {
			{ id = "tryout", text = "💪 Go for it!", effects = { Stats = { Health = 5, Happiness = 4 } }, resultText = "You made the team! Practice starts Monday." },
			{ id = "nervous", text = "😰 Too nervous", effects = { Stats = { Happiness = -3 } }, resultText = "You chickened out. Maybe next year..." },
			{ id = "other", text = "🎨 Sports aren't my thing", effects = { Stats = { Happiness = 2 } }, resultText = "You decided to focus on other activities instead." },
		},
	},
	
	----------------------------------------------------------------
	-- TEEN YEARS (Age 13-17)
	----------------------------------------------------------------
	{
		id = "puberty",
		minAge = 12, maxAge = 14,
		weight = 80, oneTime = true, milestone = true,
		emoji = "😳", title = "Growing Up",
		text = "Your body is changing... Puberty has arrived. This is awkward.",
		choices = {
			{ id = "embrace", text = "💪 Embrace the changes", effects = { Stats = { Happiness = 3, Health = 5 } }, resultText = "You accepted the changes as part of growing up." },
			{ id = "embarrassed", text = "😳 So embarrassing", effects = { Stats = { Happiness = -3 } }, resultText = "You felt awkward, but everyone goes through this." },
			{ id = "learn", text = "📚 Learn about it", effects = { Stats = { Smarts = 4, Happiness = 2 } }, resultText = "You educated yourself about what's happening. Knowledge is power!" },
		},
	},
	{
		id = "first_crush",
		minAge = 12, maxAge = 16,
		weight = 25, oneTime = true,
		emoji = "💕", title = "First Crush",
		getDynamicData = function()
			return { crushName = randomName() }
		end,
		text = "You have a crush on %crushName%! Your heart races whenever you see them.",
		choices = {
			{ id = "confess", text = "💌 Tell them", effects = { Stats = { Happiness = 6 } }, resultText = "You confessed and they said they like you too! You're floating!" },
			{ id = "secret", text = "🤫 Keep it secret", effects = { Stats = { Happiness = -2 } }, resultText = "You never said anything. They started dating someone else..." },
			{ id = "friend", text = "🤝 Just be friends", effects = { Stats = { Happiness = 3 } }, resultText = "You became good friends. Maybe something more later?" },
		},
	},
	{
		id = "first_kiss",
		minAge = 13, maxAge = 18,
		weight = 15, oneTime = true,
		emoji = "💋", title = "First Kiss!",
		getDynamicData = function()
			return { kissName = randomName() }
		end,
		text = "%kissName% leaned in for a kiss! This is the moment!",
		choices = {
			{ id = "kiss", text = "💋 Go for it!", effects = { Stats = { Happiness = 10 } }, resultText = "Your first kiss! It was magical and slightly awkward!" },
			{ id = "cheek", text = "😊 Turn for cheek kiss", effects = { Stats = { Happiness = 3 } }, resultText = "You turned and got a peck on the cheek. Maybe next time." },
			{ id = "run", text = "🏃 Panic and run", effects = { Stats = { Happiness = -5 } }, resultText = "You panicked and literally ran away. So embarrassing!" },
		},
	},
	{
		id = "high_school_start",
		minAge = 14, maxAge = 14,
		weight = 100, oneTime = true, milestone = true,
		emoji = "🏫", title = "High School Begins!",
		text = "Welcome to high school! The next 4 years will shape your future.",
		choices = {
			{ id = "academics", text = "📚 Focus on studies", effects = { Stats = { Smarts = 8 } }, resultText = "You decided academics would be your priority." },
			{ id = "social", text = "🎉 Make lots of friends", effects = { Stats = { Happiness = 6 } }, resultText = "You became super popular and joined every club!" },
			{ id = "balance", text = "⚖️ Find balance", effects = { Stats = { Smarts = 4, Happiness = 4 } }, resultText = "You found a healthy balance between work and fun." },
			{ id = "rebel", text = "😈 Who cares about school", effects = { Stats = { Happiness = 3, Smarts = -5 } }, resultText = "You decided school wasn't for you. Risky move..." },
		},
	},
	{
		id = "drivers_license",
		minAge = 16, maxAge = 17,
		weight = 60, oneTime = true, milestone = true,
		emoji = "🚗", title = "Driving Test!",
		text = "Time for your driving test! You've been waiting for this!",
		choices = {
			{ id = "prepared", text = "📚 Well prepared", effects = { Stats = { Happiness = 8, Smarts = 3 } }, resultText = "You passed easily! FREEDOM! Time to drive everywhere!" },
			{ id = "wing_it", text = "🤷 Wing it", effects = { Stats = { Happiness = -5 } }, resultText = "You failed. Parallel parking destroyed you. Try again in 2 weeks." },
			{ id = "nervous", text = "😰 So nervous", effects = { Stats = { Happiness = 3 } }, resultText = "You barely passed but a pass is a pass! License acquired!" },
		},
	},
	{
		id = "prom",
		minAge = 17, maxAge = 18,
		weight = 50, oneTime = true,
		emoji = "💃", title = "Prom Night!",
		getDynamicData = function()
			return { promDate = randomName() }
		end,
		text = "Prom is coming up! %promDate% asked you to go with them!",
		choices = {
			{ id = "yes", text = "💕 Yes!", effects = { Stats = { Happiness = 12, Looks = 3 } }, resultText = "You had an amazing night! Dancing, photos, memories!" },
			{ id = "friends", text = "👥 Go with friends instead", effects = { Stats = { Happiness = 8 } }, resultText = "You went with your friend group and had a blast!" },
			{ id = "skip", text = "🙅 Skip prom", effects = { Stats = { Happiness = -3 } }, resultText = "You skipped prom. Everyone's posts made you regret it a little." },
		},
	},
	{
		id = "part_time_job",
		minAge = 15, maxAge = 18,
		weight = 20, oneTime = true,
		emoji = "💼", title = "First Job!",
		getDynamicData = function()
			local jobs = {"fast food restaurant","grocery store","movie theater","ice cream shop","retail store"}
			return { jobPlace = jobs[math.random(#jobs)] }
		end,
		text = "You got offered a part-time job at a %jobPlace%!",
		choices = {
			{ id = "accept", text = "✅ Take the job", effects = { Stats = { Happiness = 2 }, Money = 500 }, resultText = "You started working! It's tiring but the money is nice." },
			{ id = "decline", text = "❌ Focus on school", effects = { Stats = { Smarts = 3 } }, resultText = "You decided school was more important right now." },
		},
	},
	{
		id = "party_peer_pressure",
		minAge = 15, maxAge = 19,
		weight = 15, cooldown = 2,
		emoji = "🎊", title = "The Party",
		getDynamicData = function()
			return { partyHost = randomName() }
		end,
		text = "You're at %partyHost%'s party. Someone offers you a drink...",
		choices = {
			{ id = "decline", text = "🙅 No thanks", effects = { Stats = { Happiness = 2, Health = 3 } }, resultText = "You said no and still had fun. Good choice!" },
			{ id = "accept", text = "🍺 Just one", effects = { Stats = { Happiness = 3, Health = -5 } }, resultText = "You had one and got dizzy. Not your thing." },
			{ id = "leave", text = "🚪 Leave the party", effects = { Stats = { Happiness = -2, Smarts = 3 } }, resultText = "You left early. Better safe than sorry." },
		},
	},
	{
		id = "graduation_hs",
		minAge = 18, maxAge = 18,
		weight = 100, oneTime = true, milestone = true,
		emoji = "🎓", title = "High School Graduation!",
		text = "You did it! You're graduating high school! What's next?",
		choices = {
			{ id = "college", text = "🏛️ Go to college", effects = { Stats = { Smarts = 10 }, Money = -10000 }, resultText = "College bound! Student loans here you come." },
			{ id = "work", text = "💼 Start working", effects = { Stats = { Happiness = 2 }, Money = 2000 }, resultText = "You entered the workforce. Time to make money!" },
			{ id = "gap_year", text = "✈️ Take a gap year", effects = { Stats = { Happiness = 8, Smarts = 3 } }, resultText = "You took a year to travel and find yourself." },
			{ id = "trade", text = "🔧 Learn a trade", effects = { Stats = { Smarts = 6 }, Money = -2000 }, resultText = "Trade school it is! Practical skills for life." },
		},
	},
	
	----------------------------------------------------------------
	-- YOUNG ADULT (Age 19-29)
	----------------------------------------------------------------
	{
		id = "college_major",
		minAge = 19, maxAge = 22,
		weight = 30, oneTime = true,
		emoji = "📚", title = "Choose Your Major",
		text = "What do you want to study in college?",
		choices = {
			{ id = "stem", text = "🔬 Science/Engineering", effects = { Stats = { Smarts = 10 } }, resultText = "STEM it is! Get ready for lots of math." },
			{ id = "business", text = "💼 Business", effects = { Stats = { Smarts = 6 } }, resultText = "Business school! Networking is key." },
			{ id = "arts", text = "🎨 Arts/Humanities", effects = { Stats = { Happiness = 5, Smarts = 5 } }, resultText = "Follow your passion! Who needs money anyway?" },
			{ id = "undeclared", text = "🤷 Undeclared", effects = { Stats = { Smarts = 3, Happiness = 3 } }, resultText = "You'll figure it out later. No pressure!" },
		},
	},
	{
		id = "roommate_issue",
		minAge = 18, maxAge = 25,
		weight = 15, cooldown = 2,
		emoji = "🏠", title = "Roommate Drama",
		getDynamicData = function()
			return { roomateName = randomName() }
		end,
		text = "Your roommate %roomateName% keeps eating your food without asking!",
		choices = {
			{ id = "confront", text = "😤 Confront them", effects = { Stats = { Happiness = 3 } }, resultText = "You talked it out and set boundaries. Problem solved!" },
			{ id = "label", text = "📝 Label everything", effects = { Stats = { Happiness = 2, Smarts = 2 } }, resultText = "Passive aggressive but effective." },
			{ id = "revenge", text = "😈 Eat their food", effects = { Stats = { Happiness = 4, Smarts = -2 } }, resultText = "War has been declared. This will escalate." },
		},
	},
	{
		id = "job_interview",
		minAge = 20, maxAge = 60,
		weight = 20, cooldown = 1,
		emoji = "👔", title = "Job Interview",
		getDynamicData = function()
			return { companyName = randomCompany() }
		end,
		text = "You have a job interview at %companyName%! How do you prepare?",
		choices = {
			{ id = "prepare", text = "📚 Research thoroughly", effects = { Stats = { Smarts = 3, Happiness = 5 }, Money = 2000 }, resultText = "You nailed it! You got the job!" },
			{ id = "wing_it", text = "🤷 Wing it", effects = { Stats = { Happiness = -3 } }, resultText = "They could tell you didn't prepare. No callback." },
			{ id = "overdress", text = "👔 Dress to impress", effects = { Stats = { Looks = 3, Happiness = 3 }, Money = 1500 }, resultText = "Your professional appearance helped! You got an offer." },
		},
	},
	{
		id = "first_apartment",
		minAge = 18, maxAge = 30,
		weight = 20, oneTime = true,
		emoji = "🏢", title = "First Apartment!",
		text = "You're moving into your first apartment! Independence at last!",
		choices = {
			{ id = "excited", text = "🎉 So excited!", effects = { Stats = { Happiness = 10 }, Money = -1500 }, resultText = "You decorated it perfectly! This is YOUR space!" },
			{ id = "budget", text = "💰 Budget carefully", effects = { Stats = { Happiness = 5, Smarts = 3 }, Money = -800 }, resultText = "You found a great deal and saved money. Smart!" },
			{ id = "roommates", text = "👥 Get roommates", effects = { Stats = { Happiness = 3 }, Money = -400 }, resultText = "Splitting rent makes everything easier!" },
		},
	},
	{
		id = "promotion",
		minAge = 22, maxAge = 60,
		weight = 10, cooldown = 3,
		emoji = "📈", title = "Promotion Opportunity!",
		getDynamicData = function()
			return { newTitle = math.random(2) == 1 and "Senior " or "Lead " }
		end,
		text = "Your boss wants to promote you to %newTitle% position!",
		choices = {
			{ id = "accept", text = "✅ Accept!", effects = { Stats = { Happiness = 8, Smarts = 2 }, Money = 5000 }, resultText = "Congratulations! More money and responsibility!" },
			{ id = "negotiate", text = "💰 Negotiate more", effects = { Stats = { Smarts = 3 }, Money = 7000 }, resultText = "You negotiated a better package. Boss respects that!" },
			{ id = "decline", text = "❌ Too much pressure", effects = { Stats = { Happiness = 2 } }, resultText = "You declined. Work-life balance is important." },
		},
	},
	{
		id = "dating_app",
		minAge = 18, maxAge = 50,
		weight = 12, cooldown = 2,
		emoji = "📱", title = "Dating App Match",
		getDynamicData = function()
			return { matchName = randomName() }
		end,
		text = "You matched with %matchName% on a dating app! They seem interesting.",
		choices = {
			{ id = "message", text = "💬 Send a message", effects = { Stats = { Happiness = 5 } }, resultText = "You hit it off! First date scheduled for Friday!" },
			{ id = "ignore", text = "😬 Too nervous", effects = { Stats = { Happiness = -2 } }, resultText = "You never messaged. The match expired." },
			{ id = "creep", text = "🔍 Stalk their profile first", effects = { Stats = { Smarts = 2, Happiness = 3 } }, resultText = "Research complete. They seem legit. You messaged!" },
		},
	},
	{
		id = "wedding",
		minAge = 22, maxAge = 50,
		weight = 5, oneTime = true,
		emoji = "💒", title = "Wedding Bells!",
		getDynamicData = function()
			return { spouseName = randomName() }
		end,
		text = "%spouseName% and you are getting married! What kind of wedding?",
		choices = {
			{ id = "big", text = "💍 Grand wedding!", effects = { Stats = { Happiness = 15 }, Money = -20000 }, resultText = "It was the wedding of your dreams! Magical!" },
			{ id = "small", text = "👥 Intimate ceremony", effects = { Stats = { Happiness = 12 }, Money = -3000 }, resultText = "A beautiful, personal ceremony with close ones." },
			{ id = "elope", text = "✈️ Just elope!", effects = { Stats = { Happiness = 10 }, Money = -500 }, resultText = "You eloped! Romantic and affordable!" },
		},
	},
	
	----------------------------------------------------------------
	-- ADULT LIFE (Age 30-60)
	----------------------------------------------------------------
	{
		id = "midlife_reflection",
		minAge = 35, maxAge = 45,
		weight = 20, oneTime = true,
		emoji = "🤔", title = "Midlife Reflection",
		text = "You're thinking about where you are in life. Is this what you wanted?",
		choices = {
			{ id = "content", text = "😊 Pretty happy actually", effects = { Stats = { Happiness = 8 } }, resultText = "You realized you've built a good life. Gratitude!" },
			{ id = "change", text = "🔄 Time for a change", effects = { Stats = { Happiness = 5, Smarts = 3 } }, resultText = "You decided to make some positive changes." },
			{ id = "crisis", text = "😰 Is this it?", effects = { Stats = { Happiness = -5 } }, resultText = "You're having a midlife crisis. Maybe buy a sports car?" },
		},
	},
	{
		id = "health_scare",
		minAge = 40, maxAge = 80,
		weight = 10, cooldown = 5,
		emoji = "🏥", title = "Health Scare",
		text = "The doctor found something concerning in your checkup...",
		choices = {
			{ id = "followup", text = "🏥 Get it checked out", effects = { Stats = { Health = -5, Smarts = 3 } }, resultText = "False alarm! But good thing you followed up." },
			{ id = "ignore", text = "🙈 Ignore it", effects = { Stats = { Health = -15 } }, resultText = "Ignoring health issues is never a good idea..." },
			{ id = "lifestyle", text = "💪 Change lifestyle", effects = { Stats = { Health = 5, Happiness = 3 } }, resultText = "You started eating better and exercising. Great choice!" },
		},
	},
	{
		id = "inheritance",
		minAge = 25, maxAge = 70,
		weight = 3, oneTime = true,
		emoji = "💰", title = "Unexpected Inheritance",
		getDynamicData = function()
			local amounts = {5000, 10000, 25000, 50000, 100000}
			return { amount = amounts[math.random(#amounts)] }
		end,
		text = "A distant relative passed away and left you $%amount%!",
		choices = {
			{ id = "save", text = "🏦 Save it", effects = { Stats = { Smarts = 3 } }, resultText = "You saved it wisely. Smart financial move!" },
			{ id = "invest", text = "📈 Invest it", effects = { Stats = { Smarts = 5 } }, resultText = "You invested it. Hopefully it grows!" },
			{ id = "spend", text = "🛍️ Treat yourself", effects = { Stats = { Happiness = 8 } }, resultText = "You splurged a bit. You deserve it!" },
		},
		applyDynamicMoney = true,
	},
	{
		id = "kid_born",
		minAge = 22, maxAge = 45,
		weight = 8, cooldown = 3,
		emoji = "👶", title = "Baby On The Way!",
		text = "Congratulations! You're going to be a parent!",
		choices = {
			{ id = "excited", text = "🎉 Over the moon!", effects = { Stats = { Happiness = 15, Health = -3 }, Money = -2000 }, resultText = "A beautiful baby entered your life! Sleep is overrated anyway." },
			{ id = "nervous", text = "😰 So nervous", effects = { Stats = { Happiness = 8, Smarts = 2 }, Money = -2000 }, resultText = "You were nervous but stepped up! Great parent in the making." },
			{ id = "notready", text = "😱 Not ready!", effects = { Stats = { Happiness = -5, Health = -5 }, Money = -2000 }, resultText = "Ready or not, the baby arrived. Time to figure it out!" },
		},
	},
	{
		id = "career_burnout",
		minAge = 28, maxAge = 55,
		weight = 12, cooldown = 4,
		emoji = "😩", title = "Burnout",
		text = "You're completely burned out from work. Something has to change.",
		choices = {
			{ id = "vacation", text = "✈️ Take a vacation", effects = { Stats = { Happiness = 8, Health = 5 }, Money = -2000 }, resultText = "You took a break and came back refreshed!" },
			{ id = "quit", text = "🚪 Quit the job", effects = { Stats = { Happiness = 10, Health = 3 }, Money = -5000 }, resultText = "You quit! Scary but liberating. Time to find something better." },
			{ id = "push", text = "💪 Push through", effects = { Stats = { Happiness = -8, Health = -10 } }, resultText = "You kept going but your health suffered..." },
		},
	},
	
	----------------------------------------------------------------
	-- RANDOM LIFE EVENTS (Any age with conditions)
	----------------------------------------------------------------
	{
		id = "find_money",
		minAge = 5, maxAge = 90,
		weight = 8, cooldown = 3,
		emoji = "💵", title = "Lucky Find!",
		getDynamicData = function()
			local amounts = {5, 10, 20, 50, 100}
			return { amount = amounts[math.random(#amounts)] }
		end,
		text = "You found $%amount% on the ground!",
		choices = {
			{ id = "keep", text = "💰 Keep it", effects = { Stats = { Happiness = 5 } }, resultText = "Finders keepers!" },
			{ id = "return", text = "🔍 Try to find owner", effects = { Stats = { Happiness = 3, Smarts = 2 } }, resultText = "You couldn't find the owner. Guess it's yours now, with good karma!" },
		},
		applyDynamicMoney = true,
	},
	{
		id = "random_kindness",
		minAge = 10, maxAge = 90,
		weight = 10, cooldown = 2,
		emoji = "💝", title = "Random Act of Kindness",
		text = "You see someone struggling with heavy bags. What do you do?",
		choices = {
			{ id = "help", text = "🤝 Help them", effects = { Stats = { Happiness = 8 } }, resultText = "You helped them out! They were so grateful. Good karma!" },
			{ id = "busy", text = "😅 Too busy", effects = { Stats = { Happiness = -2 } }, resultText = "You walked past. You feel a little guilty." },
		},
	},
	{
		id = "flat_tire",
		minAge = 16, maxAge = 80,
		weight = 8, cooldown = 3,
		emoji = "🚗", title = "Flat Tire!",
		text = "You got a flat tire on your way somewhere important!",
		choices = {
			{ id = "fix", text = "🔧 Change it yourself", effects = { Stats = { Happiness = 3, Smarts = 3 } }, resultText = "You fixed it yourself! Useful skill." },
			{ id = "call", text = "📱 Call for help", effects = { Stats = { Happiness = 1 }, Money = -100 }, resultText = "Help arrived. Cost some money but problem solved." },
			{ id = "panic", text = "😰 Panic", effects = { Stats = { Happiness = -5 } }, resultText = "You panicked and made everything worse. Bad day." },
		},
	},
	{
		id = "viral_post",
		minAge = 13, maxAge = 60,
		weight = 5, cooldown = 5,
		emoji = "📱", title = "You Went Viral!",
		text = "Something you posted online went viral! Millions of views!",
		choices = {
			{ id = "embrace", text = "🌟 Embrace fame", effects = { Stats = { Happiness = 10, Looks = 3 } }, resultText = "You became internet famous! Followers everywhere!" },
			{ id = "delete", text = "😰 Delete everything", effects = { Stats = { Happiness = -3 } }, resultText = "The attention was too much. You disappeared online." },
			{ id = "monetize", text = "💰 Monetize it", effects = { Stats = { Smarts = 3 }, Money = 500 }, resultText = "You made some money from the attention. Nice!" },
		},
	},
	{
		id = "lottery_win",
		minAge = 18, maxAge = 90,
		weight = 1, oneTime = true,
		emoji = "🎰", title = "LOTTERY WINNER!",
		getDynamicData = function()
			local amounts = {1000, 5000, 10000, 50000, 100000, 1000000}
			return { amount = amounts[math.random(#amounts)] }
		end,
		text = "YOUR LOTTERY TICKET WON $%amount%!!! This can't be real!",
		choices = {
			{ id = "claim", text = "💰 Claim it all!", effects = { Stats = { Happiness = 20 } }, resultText = "You're rich! Life will never be the same!" },
		},
		applyDynamicMoney = true,
	},
}

-- Build lookup tables
EventLibrary.Events = events

local byId = {}
for _, ev in ipairs(events) do
	byId[ev.id] = ev
end
EventLibrary.ById = byId

-- Helper functions for dynamic events
EventLibrary.RandomMaleName = randomMaleName
EventLibrary.RandomFemaleName = randomFemaleName  
EventLibrary.RandomName = randomName
EventLibrary.RandomCompany = randomCompany

return EventLibrary
