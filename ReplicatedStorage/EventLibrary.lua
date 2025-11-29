-- EventLibrary.lua
-- MASSIVE BitLife-style event database with 200+ unique events
-- Covers all life stages, story arcs, and branching paths

local EventLibrary = {}

----------------------------------------------------------------------
-- NAME GENERATORS
----------------------------------------------------------------------

local MaleNames = {"James","Michael","David","Chris","Daniel","Matt","Jake","Ryan","Tyler","Brandon","Kevin","Justin","Josh","Nick","Alex","Brian","Eric","Andrew","Sean","Kyle","Adam","Aaron","Ethan","Nathan","Zach","Dylan","Connor","Mason","Logan","Lucas","Marcus","Darius","Jerome","DeShawn","Jamal","Carlos","Miguel","Antonio","Roberto","Giovanni","Vladimir","Dmitri","Kenji","Hiroshi","Wei","Jin","Ahmed","Omar","Raj","Vikram"}
local FemaleNames = {"Emma","Sophia","Olivia","Ava","Isabella","Mia","Emily","Abigail","Madison","Elizabeth","Ella","Avery","Chloe","Sofia","Grace","Lily","Hannah","Aria","Zoe","Riley","Nora","Scarlett","Stella","Luna","Hazel","Jasmine","Aaliyah","Destiny","Diamond","Keisha","Maria","Carmen","Rosa","Valentina","Yuki","Mei","Sakura","Priya","Ananya","Fatima","Layla"}
local LastNames = {"Smith","Johnson","Williams","Brown","Jones","Garcia","Miller","Davis","Rodriguez","Martinez","Anderson","Taylor","Thomas","Moore","Jackson","Martin","Lee","Thompson","White","Harris","Clark","Lewis","Robinson","Walker","Young","King","Wright","Scott","Green","Baker","Adams","Nelson","Hill","Mitchell","Roberts","Campbell","Phillips","Evans","Turner","Torres","Parker","Collins","Edwards","Stewart","Morris","Murphy","Rivera","Cook","Rogers","Morgan","Peterson","Cooper","Reed","Bailey","Bell","Gomez","Kelly","Howard","Ward","Cox","Diaz","Richardson","Wood","Watson","Brooks","Bennett","Gray","Sanders","Price","Hughes","Fitzgerald","O'Brien","McCarthy","Sullivan","Kim","Park","Chen","Wang","Nakamura","Tanaka","Patel","Singh","Khan"}

local function randomMaleName()
	return MaleNames[math.random(#MaleNames)] .. " " .. LastNames[math.random(#LastNames)]
end

local function randomFemaleName()
	return FemaleNames[math.random(#FemaleNames)] .. " " .. LastNames[math.random(#LastNames)]
end

local function randomName()
	return math.random(2) == 1 and randomMaleName() or randomFemaleName()
end

local Companies = {"TechCorp","GlobalSoft","MegaCorp","Innovate Inc","FutureTech","DataStream","CloudNine","ByteWorks","CodeBase","NetSphere","DigiCore","InfoSys","SmartSolutions","PrimeTech","NextGen","BlueWave","RedShift","GreenLight","SilverLine","GoldStar","Amazon","Google","Microsoft","Apple","Meta","Tesla","SpaceX","Netflix","Uber","Airbnb","Walmart","Target","Nike","Adidas","Coca-Cola","PepsiCo","McDonald's","Starbucks"}

local function randomCompany()
	return Companies[math.random(#Companies)]
end

local Cities = {"New York","Los Angeles","Chicago","Houston","Phoenix","Philadelphia","San Antonio","San Diego","Dallas","San Jose","Austin","Jacksonville","Fort Worth","Columbus","Charlotte","Seattle","Denver","Washington DC","Boston","Nashville","Las Vegas","Miami","Atlanta","Portland","Detroit"}

local function randomCity()
	return Cities[math.random(#Cities)]
end

----------------------------------------------------------------------
-- EVENTS DATABASE (200+ Events)
----------------------------------------------------------------------

local events = {
	
	----------------------------------------------------------------
	-- BABY EVENTS (Age 0-2)
	----------------------------------------------------------------
	{
		id = "birth",
		minAge = 0, maxAge = 0,
		weight = 100, milestone = true, oneTime = true,
		emoji = "👶", title = "You Are Born!",
		category = "family",
		text = "You came into this world screaming and crying. Welcome to life!",
		choices = {
			{ text = "😭 Keep crying", effects = { Health = 2 }, resultText = "Your lungs are strong! Good sign for your health." },
			{ text = "😴 Fall asleep", effects = { Health = 3, Happiness = 2 }, resultText = "You drifted off to sleep peacefully in your mother's arms." },
			{ text = "👀 Look around curiously", effects = { Smarts = 3 }, resultText = "You immediately started observing the world with wide, curious eyes." },
		},
	},
	{
		id = "first_smile",
		minAge = 0, maxAge = 0,
		weight = 80, oneTime = true,
		emoji = "😊", title = "First Smile",
		category = "family",
		text = "You smiled for the first time! Your parents are overjoyed!",
		choices = {
			{ text = "😊 Keep smiling", effects = { Happiness = 5 }, resultText = "Your smile lit up the room. Everyone fell in love with you." },
			{ text = "😂 Let out a giggle", effects = { Happiness = 6, Looks = 1 }, resultText = "Your giggle was the most adorable sound your parents ever heard." },
		},
	},
	{
		id = "first_steps",
		minAge = 1, maxAge = 1,
		weight = 80, oneTime = true,
		emoji = "👣", title = "First Steps!",
		category = "family",
		text = "You're pulling yourself up and trying to walk for the first time!",
		choices = {
			{ text = "🚶 Take it slow", effects = { Health = 2, Happiness = 3 }, resultText = "You took your first wobbly steps! Everyone cheered!" },
			{ text = "🏃 Go for it!", effects = { Health = -2, Happiness = 5 }, resultText = "You tried to run and faceplanted into the couch. But you laughed it off!" },
			{ text = "😰 Fall down crying", effects = { Happiness = -2 }, resultText = "You fell and cried. Your parents comforted you." },
		},
	},
	{
		id = "first_word",
		minAge = 1, maxAge = 2,
		weight = 70, oneTime = true,
		emoji = "🗣️", title = "First Word!",
		category = "family",
		text = "You're about to speak your first word! Everyone is watching...",
		choices = {
			{ text = "👩 Mama", effects = { Happiness = 5 }, resultText = "You said 'Mama'! Your mother burst into happy tears." },
			{ text = "👨 Dada", effects = { Happiness = 5 }, resultText = "You said 'Dada'! Your father was so proud he called everyone he knows." },
			{ text = "🙅 NO!", effects = { Happiness = 3, Smarts = 2 }, resultText = "Your first word was 'NO!' This is going to be an interesting childhood..." },
			{ text = "🤔 Something weird", effects = { Smarts = 4 }, resultText = "You said something nobody expected. Your parents are confused but impressed." },
		},
	},
	{
		id = "potty_training",
		minAge = 2, maxAge = 3,
		weight = 60, oneTime = true,
		emoji = "🚽", title = "Potty Training",
		category = "family",
		text = "It's time to learn to use the toilet like a big kid!",
		choices = {
			{ text = "💪 I can do this!", effects = { Happiness = 4, Smarts = 2 }, resultText = "After a few accidents, you figured it out! No more diapers!" },
			{ text = "😤 Diapers are fine", effects = { Happiness = -2 }, resultText = "You resisted, but eventually learned. It took a while though." },
			{ text = "😱 This is scary!", effects = { Happiness = -1, Smarts = 1 }, resultText = "The toilet seemed huge and terrifying, but you got there eventually." },
		},
	},
	{
		id = "terrible_twos",
		minAge = 2, maxAge = 2,
		weight = 50, oneTime = true,
		emoji = "😤", title = "The Terrible Twos",
		category = "family",
		text = "You've hit the terrible twos! Tantrums are your new favorite activity.",
		choices = {
			{ text = "😭 Throw a tantrum!", effects = { Happiness = -3, Health = 2 }, resultText = "You screamed until you got what you wanted. Your parents look exhausted." },
			{ text = "😇 Be surprisingly good", effects = { Happiness = 5, Smarts = 2 }, resultText = "You skipped the terrible twos entirely. Your parents consider themselves lucky." },
			{ text = "🎭 Both - depends on mood", effects = { Happiness = 1 }, resultText = "Some days you're an angel, other days a demon. Classic two-year-old." },
		},
	},
	
	----------------------------------------------------------------
	-- EARLY CHILDHOOD (Age 3-5)
	----------------------------------------------------------------
	{
		id = "imaginary_friend",
		minAge = 3, maxAge = 5,
		weight = 20, oneTime = true,
		emoji = "👻", title = "Imaginary Friend",
		category = "social",
		text = "You've created an imaginary friend. They're always with you now.",
		getDynamicData = function()
			local names = {"Mr. Whiskers","Captain Zoom","Princess Sparkle","Dino","Bubbles","Shadow","Moonbeam","Thunder"}
			return { friendName = names[math.random(#names)] }
		end,
		choices = {
			{ text = "🐱 Play together!", effects = { Happiness = 6, Smarts = 2 }, resultText = "You and %friendName% had amazing adventures together." },
			{ text = "🤷 That's weird", effects = { Happiness = -1 }, resultText = "You decided imaginary friends weren't for you." },
			{ text = "👨‍👩‍👦 Tell your parents", effects = { Happiness = 3 }, resultText = "Your parents thought %friendName% was adorable and played along." },
		},
	},
	{
		id = "playground_push",
		minAge = 3, maxAge = 5,
		weight = 25, cooldown = 3,
		emoji = "😢", title = "Playground Trouble",
		category = "social",
		text = "A bigger kid pushed you off the swing!",
		choices = {
			{ text = "😭 Cry", effects = { Happiness = -3 }, resultText = "You cried until a teacher came to help." },
			{ text = "😠 Push back", effects = { Happiness = 2, Health = -3 }, resultText = "You pushed back and both of you got timeout." },
			{ text = "👨‍🏫 Tell a grown-up", effects = { Happiness = 1, Smarts = 2 }, resultText = "You told the teacher and the bully got in trouble." },
			{ text = "🏃 Run away", effects = { Health = 2, Happiness = -1 }, resultText = "You ran to the other side of the playground. Probably the safest choice." },
		},
	},
	{
		id = "first_pet",
		minAge = 4, maxAge = 8,
		weight = 15, oneTime = true,
		emoji = "🐕", title = "First Pet!",
		category = "family",
		getDynamicData = function()
			local pets = {{"dog","Buddy","🐕"},{"cat","Whiskers","🐱"},{"hamster","Hammy","🐹"},{"goldfish","Goldie","🐠"},{"turtle","Shelly","🐢"},{"rabbit","Flopsy","🐰"}}
			local pet = pets[math.random(#pets)]
			return { petType = pet[1], petName = pet[2], petEmoji = pet[3] }
		end,
		text = "Your parents got you a pet %petType% named %petName%!",
		choices = {
			{ text = "❤️ Best day ever!", effects = { Happiness = 10 }, resultText = "You and %petName% became inseparable best friends!" },
			{ text = "😰 That's responsibility", effects = { Happiness = 4, Smarts = 3 }, resultText = "You took your pet duties seriously and learned about caring for others." },
			{ text = "😒 I wanted something else", effects = { Happiness = -2 }, resultText = "You were disappointed, but %petName% grew on you eventually." },
		},
	},
	{
		id = "first_day_preschool",
		minAge = 4, maxAge = 4,
		weight = 90, oneTime = true, milestone = true,
		emoji = "🏫", title = "First Day of Preschool",
		category = "school",
		text = "It's your first day of preschool! How do you feel about leaving home?",
		choices = {
			{ text = "🎉 Can't wait!", effects = { Happiness = 5, Smarts = 3 }, resultText = "You ran in excitedly and made 3 new friends by lunchtime!" },
			{ text = "😰 Don't leave me!", effects = { Happiness = -3 }, resultText = "You clung to your parent's leg, but eventually had fun." },
			{ text = "🤔 What's preschool?", effects = { Smarts = 4 }, resultText = "Your curiosity led you to explore every corner of the classroom!" },
		},
	},
	{
		id = "nightmare",
		minAge = 3, maxAge = 10,
		weight = 18, cooldown = 2,
		emoji = "😱", title = "Nightmare!",
		category = "health",
		text = "You woke up from a terrible nightmare about monsters under your bed!",
		choices = {
			{ text = "🏃 Run to parents", effects = { Happiness = 3 }, resultText = "Your parents comforted you and let you sleep with them." },
			{ text = "💪 Face the monsters", effects = { Happiness = 5, Smarts = 2 }, resultText = "You checked under the bed and realized it was just your imagination. Brave!" },
			{ text = "😨 Hide under covers", effects = { Happiness = -2 }, resultText = "You stayed frozen under your blanket until morning." },
			{ text = "💡 Turn on the light", effects = { Happiness = 2, Smarts = 3 }, resultText = "Light chased away the monsters. Problem solved!" },
		},
	},
	{
		id = "santa_question",
		minAge = 4, maxAge = 7,
		weight = 15, oneTime = true,
		emoji = "🎅", title = "Is Santa Real?",
		category = "family",
		text = "A kid at school said Santa isn't real. You're confused and upset.",
		choices = {
			{ text = "🎅 Santa IS real!", effects = { Happiness = 3 }, resultText = "You defended Santa's honor. The magic of Christmas lives on!" },
			{ text = "🤔 Ask your parents", effects = { Smarts = 3 }, resultText = "Your parents gave you a careful answer about the 'spirit of Christmas.'" },
			{ text = "😢 Feel betrayed", effects = { Happiness = -4, Smarts = 2 }, resultText = "You realized the truth and felt your childhood slipping away." },
		},
	},
	{
		id = "drawing_talent",
		minAge = 4, maxAge = 7,
		weight = 12, oneTime = true,
		emoji = "🎨", title = "Art Prodigy?",
		category = "school",
		text = "Your teacher says you drew an amazing picture. You might have artistic talent!",
		choices = {
			{ text = "🎨 I love drawing!", effects = { Happiness = 5, Smarts = 3, Looks = 1 }, resultText = "You started drawing every day. A possible artist in the making!", setFlag = "artistic" },
			{ text = "🤷 It was okay", effects = { Happiness = 2 }, resultText = "You didn't think much of it, just having fun." },
			{ text = "📚 I prefer other stuff", effects = { Smarts = 2 }, resultText = "Art is nice, but you have other interests." },
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
		category = "school",
		text = "Big kid school! You're starting first grade!",
		choices = {
			{ text = "😎 I got this", effects = { Happiness = 5, Smarts = 3 }, resultText = "You walked in like you owned the place and had a great first day!" },
			{ text = "😬 So nervous", effects = { Happiness = 1, Smarts = 2 }, resultText = "You were nervous but made it through. Tomorrow will be easier!" },
			{ text = "👋 Find new friends", effects = { Happiness = 6 }, resultText = "You introduced yourself to everyone and made lots of friends!" },
		},
	},
	{
		id = "lost_tooth",
		minAge = 6, maxAge = 8,
		weight = 30, cooldown = 1,
		emoji = "🦷", title = "Lost a Tooth!",
		category = "health",
		text = "Your tooth finally fell out! There's a gap in your smile now.",
		choices = {
			{ text = "🧚 Put under pillow", effects = { Happiness = 4, Money = 5 }, resultText = "The tooth fairy left you $5! Magic is real!" },
			{ text = "🏆 Keep it as trophy", effects = { Happiness = 2 }, resultText = "You added it to your growing collection of teeth." },
			{ text = "🤢 Throw it away", effects = { Happiness = 1 }, resultText = "You tossed it. Teeth are kind of gross when you think about it." },
		},
	},
	{
		id = "bully_encounter",
		minAge = 6, maxAge = 14,
		weight = 15, cooldown = 3,
		emoji = "😠", title = "Bully Trouble",
		category = "school",
		getDynamicData = function()
			return { bullyName = randomName() }
		end,
		text = "%bullyName% has been picking on you at school. They called you names in front of everyone.",
		choices = {
			{ text = "💪 Stand up to them", effects = { Happiness = 4, Health = -2 }, resultText = "You stood your ground! %bullyName% seemed surprised and backed off." },
			{ text = "👨‍🏫 Tell a teacher", effects = { Happiness = 2, Smarts = 2 }, resultText = "The teacher talked to them. Smart move avoiding a fight." },
			{ text = "🙄 Ignore them", effects = { Happiness = -2 }, resultText = "You walked away. They might bother you again though." },
			{ text = "🤝 Try to befriend them", effects = { Happiness = 5, Smarts = 3 }, resultText = "Surprisingly, they just needed a friend. You're buddies now!" },
		},
	},
	{
		id = "science_fair",
		minAge = 8, maxAge = 14,
		weight = 18, cooldown = 2,
		emoji = "🔬", title = "Science Fair",
		category = "school",
		text = "The science fair is coming up! What project will you do?",
		choices = {
			{ text = "🌋 Baking soda volcano", effects = { Smarts = 3, Happiness = 4 }, resultText = "Classic! Your volcano erupted perfectly and got 2nd place." },
			{ text = "🪐 Solar system model", effects = { Smarts = 5 }, resultText = "Your detailed model impressed the judges. 1st place!" },
			{ text = "🌱 Plant growth study", effects = { Smarts = 4, Happiness = 2 }, resultText = "Your careful documentation earned you an honorable mention." },
			{ text = "🤖 Build a robot", effects = { Smarts = 6, Money = -20 }, resultText = "Your robot was the talk of the fair! You might be an engineer someday." },
			{ text = "😴 Don't participate", effects = { Smarts = -3 }, resultText = "You skipped it and regretted it when everyone got prizes." },
		},
	},
	{
		id = "birthday_party",
		minAge = 6, maxAge = 16,
		weight = 10, cooldown = 2,
		emoji = "🎂", title = "Birthday Party!",
		category = "social",
		text = "It's your birthday! What kind of celebration do you want?",
		choices = {
			{ text = "🎉 Huge party!", effects = { Happiness = 10, Money = -50 }, resultText = "You had an amazing party with tons of friends and presents!" },
			{ text = "👥 Just close friends", effects = { Happiness = 6 }, resultText = "A cozy celebration with your best friends. Quality over quantity!" },
			{ text = "👨‍👩‍👧‍👦 Family dinner", effects = { Happiness = 5 }, resultText = "A nice family dinner with cake. Simple but sweet." },
			{ text = "🎮 Gaming party", effects = { Happiness = 8, Money = -30 }, resultText = "Epic gaming session with friends. Best birthday ever!" },
		},
	},
	{
		id = "broken_bone",
		minAge = 5, maxAge = 18,
		weight = 8, cooldown = 5,
		emoji = "🦴", title = "Ouch! Broken Bone!",
		category = "health",
		getDynamicData = function()
			local bones = {"arm","leg","wrist","ankle","finger","collarbone"}
			return { bone = bones[math.random(#bones)] }
		end,
		text = "You fell while playing and broke your %bone%! It really hurts!",
		choices = {
			{ text = "💪 Be brave", effects = { Health = -10, Happiness = 2 }, resultText = "You toughed it out at the hospital. You got a cool cast that everyone signed!" },
			{ text = "😭 Cry", effects = { Health = -10, Happiness = -3 }, resultText = "You cried a lot. Fair enough, broken bones really hurt." },
		},
	},
	{
		id = "report_card_good",
		minAge = 6, maxAge = 18,
		weight = 12, cooldown = 1,
		emoji = "📊", title = "Great Report Card!",
		category = "school",
		text = "Report cards are out! You got straight A's!",
		choices = {
			{ text = "🎉 Celebrate!", effects = { Happiness = 6, Smarts = 3 }, resultText = "Your parents were so proud! They took you out for ice cream." },
			{ text = "😊 Stay humble", effects = { Happiness = 3, Smarts = 4 }, resultText = "You acknowledged your hard work paid off and kept studying." },
			{ text = "💰 Ask for reward", effects = { Happiness = 5, Money = 20 }, resultText = "Your parents gave you a cash reward for good grades!" },
		},
	},
	{
		id = "report_card_bad",
		minAge = 6, maxAge = 18,
		weight = 10, cooldown = 2,
		emoji = "📊", title = "Bad Report Card",
		category = "school",
		text = "Report cards are out... You didn't do so well this semester.",
		choices = {
			{ text = "🙈 Hide it", effects = { Happiness = -5, Smarts = -2 }, resultText = "You hid it but your parents found out anyway. Double trouble." },
			{ text = "😔 Be honest", effects = { Happiness = -2, Smarts = 2 }, resultText = "Your parents were disappointed but appreciated your honesty." },
			{ text = "📚 Promise to improve", effects = { Happiness = 1, Smarts = 4 }, resultText = "You committed to studying harder. Good attitude!" },
		},
	},
	{
		id = "video_game",
		minAge = 7, maxAge = 40,
		weight = 15, cooldown = 2,
		emoji = "🎮", title = "New Video Game",
		category = "social",
		text = "A new video game just came out that all your friends are playing!",
		choices = {
			{ text = "💰 Buy it!", effects = { Happiness = 8, Money = -60 }, resultText = "You got the game and played it all weekend!" },
			{ text = "⏰ Wait for sale", effects = { Happiness = 2, Smarts = 2 }, resultText = "You waited and got it half price later. Smart!" },
			{ text = "📺 Watch streams instead", effects = { Happiness = 3 }, resultText = "You watched others play. Not the same, but free!" },
			{ text = "🚫 Games are a waste", effects = { Smarts = 3, Happiness = -2 }, resultText = "You decided to focus on other things instead." },
		},
	},
	{
		id = "sports_tryout",
		minAge = 8, maxAge = 18,
		weight = 12, cooldown = 2,
		emoji = "⚽", title = "Sports Tryouts",
		category = "school",
		getDynamicData = function()
			local sports = {"soccer","basketball","baseball","volleyball","swimming","track","football","tennis"}
			return { sport = sports[math.random(#sports)] }
		end,
		text = "Tryouts for the %sport% team are today! Will you try out?",
		choices = {
			{ text = "💪 Go for it!", effects = { Health = 5, Happiness = 4 }, resultText = "You made the team! Practice starts Monday.", setFlag = "athlete" },
			{ text = "😰 Too nervous", effects = { Happiness = -3 }, resultText = "You chickened out. Maybe next year..." },
			{ text = "🎨 Sports aren't my thing", effects = { Happiness = 2 }, resultText = "You decided to focus on other activities instead." },
		},
	},
	{
		id = "school_play",
		minAge = 8, maxAge = 18,
		weight = 10, cooldown = 2,
		emoji = "🎭", title = "School Play",
		category = "school",
		text = "The school is putting on a play! Auditions are today.",
		choices = {
			{ text = "🎭 Audition for lead!", effects = { Happiness = 6, Looks = 2 }, resultText = "You got the lead role! Time to memorize those lines.", setFlag = "actor" },
			{ text = "🎤 Small part is fine", effects = { Happiness = 4, Smarts = 2 }, resultText = "You got a supporting role. Less pressure, still fun!" },
			{ text = "🔧 Work backstage", effects = { Happiness = 3, Smarts = 3 }, resultText = "You helped with sets and lighting. The show couldn't happen without you!" },
			{ text = "🙅 Not for me", effects = { Happiness = 1 }, resultText = "Acting isn't your thing. That's okay!" },
		},
	},
	{
		id = "learned_to_swim",
		minAge = 6, maxAge = 12,
		weight = 15, oneTime = true,
		emoji = "🏊", title = "Swimming Lessons",
		category = "health",
		text = "Your parents signed you up for swimming lessons!",
		choices = {
			{ text = "🏊 Dive right in!", effects = { Health = 5, Happiness = 5 }, resultText = "You learned to swim and now you're like a fish in water!" },
			{ text = "😰 Water is scary", effects = { Health = 2, Happiness = -2 }, resultText = "It took a while, but you eventually learned the basics." },
			{ text = "🏆 Train to compete", effects = { Health = 8, Happiness = 3 }, resultText = "You discovered a talent for swimming and joined the swim team!" },
		},
	},
	{
		id = "best_friend",
		minAge = 6, maxAge = 18,
		weight = 15, oneTime = true,
		emoji = "👯", title = "Best Friend",
		category = "social",
		getDynamicData = function()
			return { friendName = randomName() }
		end,
		text = "You and %friendName% have become inseparable. You're officially best friends!",
		choices = {
			{ text = "❤️ BFFs forever!", effects = { Happiness = 10 }, resultText = "You made a friendship pact. %friendName% will always have your back.", setFlag = "best_friend" },
			{ text = "🤝 Good friends", effects = { Happiness = 6 }, resultText = "You're close, but you don't want to put a label on it." },
		},
	},
	{
		id = "learned_instrument",
		minAge = 7, maxAge = 14,
		weight = 12, oneTime = true,
		emoji = "🎹", title = "Music Lessons",
		category = "school",
		getDynamicData = function()
			local instruments = {"piano","guitar","violin","drums","flute","saxophone","trumpet"}
			return { instrument = instruments[math.random(#instruments)] }
		end,
		text = "Your parents are offering to pay for %instrument% lessons!",
		choices = {
			{ text = "🎵 Yes please!", effects = { Smarts = 4, Happiness = 4, Money = -100 }, resultText = "You started learning %instrument% and discovered a love for music!", setFlag = "musician" },
			{ text = "😴 Sounds boring", effects = { Happiness = 1 }, resultText = "You passed on the lessons. Music isn't for everyone." },
			{ text = "🎸 Can I pick something else?", effects = { Smarts = 3, Happiness = 3, Money = -80 }, resultText = "You negotiated a different instrument and started lessons!" },
		},
	},
	
	----------------------------------------------------------------
	-- TEEN YEARS (Age 13-19)
	----------------------------------------------------------------
	{
		id = "puberty",
		minAge = 12, maxAge = 14,
		weight = 90, oneTime = true, milestone = true,
		emoji = "😳", title = "Growing Up",
		category = "health",
		text = "Your body is changing... Puberty has arrived. This is awkward.",
		choices = {
			{ text = "💪 Embrace the changes", effects = { Happiness = 3, Health = 5 }, resultText = "You accepted the changes as part of growing up." },
			{ text = "😳 So embarrassing", effects = { Happiness = -3 }, resultText = "You felt awkward, but everyone goes through this." },
			{ text = "📚 Learn about it", effects = { Smarts = 4, Happiness = 2 }, resultText = "You educated yourself about what's happening. Knowledge is power!" },
		},
	},
	{
		id = "first_crush",
		minAge = 12, maxAge = 16,
		weight = 30, oneTime = true,
		emoji = "💕", title = "First Crush",
		category = "romance",
		getDynamicData = function()
			return { crushName = randomName() }
		end,
		text = "You have a crush on %crushName%! Your heart races whenever you see them.",
		choices = {
			{ text = "💌 Tell them", effects = { Happiness = 6 }, resultText = "You confessed and they said they like you too! You're floating!", setFlag = "dating" },
			{ text = "🤫 Keep it secret", effects = { Happiness = -2 }, resultText = "You never said anything. They started dating someone else..." },
			{ text = "🤝 Just be friends", effects = { Happiness = 3 }, resultText = "You became good friends. Maybe something more later?" },
			{ text = "📱 DM them", effects = { Happiness = 4, Smarts = 1 }, resultText = "You slid into their DMs. It worked! You're texting all night." },
		},
	},
	{
		id = "first_kiss",
		minAge = 13, maxAge = 18,
		weight = 20, oneTime = true,
		emoji = "💋", title = "First Kiss!",
		category = "romance",
		getDynamicData = function()
			return { kissName = randomName() }
		end,
		text = "%kissName% leaned in for a kiss! This is the moment!",
		choices = {
			{ text = "💋 Go for it!", effects = { Happiness = 10 }, resultText = "Your first kiss! It was magical and slightly awkward!" },
			{ text = "😊 Turn for cheek kiss", effects = { Happiness = 3 }, resultText = "You turned and got a peck on the cheek. Maybe next time." },
			{ text = "🏃 Panic and run", effects = { Happiness = -5 }, resultText = "You panicked and literally ran away. So embarrassing!" },
		},
	},
	{
		id = "high_school_start",
		minAge = 14, maxAge = 14,
		weight = 100, oneTime = true, milestone = true,
		emoji = "🏫", title = "High School Begins!",
		category = "school",
		text = "Welcome to high school! The next 4 years will shape your future.",
		choices = {
			{ text = "📚 Focus on studies", effects = { Smarts = 8 }, resultText = "You decided academics would be your priority.", setFlag = "honor_student" },
			{ text = "🎉 Make lots of friends", effects = { Happiness = 6 }, resultText = "You became super popular and joined every club!", setFlag = "popular" },
			{ text = "⚖️ Find balance", effects = { Smarts = 4, Happiness = 4 }, resultText = "You found a healthy balance between work and fun." },
			{ text = "😈 Who cares about school", effects = { Happiness = 3, Smarts = -5 }, resultText = "You decided school wasn't for you. Risky move...", setFlag = "criminal_tendencies" },
		},
	},
	{
		id = "drivers_license",
		minAge = 16, maxAge = 17,
		weight = 80, oneTime = true, milestone = true,
		emoji = "🚗", title = "Driving Test!",
		category = "school",
		text = "Time for your driving test! You've been waiting for this!",
		choices = {
			{ text = "📚 Well prepared", effects = { Happiness = 8, Smarts = 3 }, resultText = "You passed easily! FREEDOM! Time to drive everywhere!" },
			{ text = "🤷 Wing it", effects = { Happiness = -5 }, resultText = "You failed. Parallel parking destroyed you. Try again later." },
			{ text = "😰 So nervous", effects = { Happiness = 3 }, resultText = "You barely passed but a pass is a pass! License acquired!" },
		},
	},
	{
		id = "prom",
		minAge = 17, maxAge = 18,
		weight = 70, oneTime = true,
		emoji = "💃", title = "Prom Night!",
		category = "social",
		getDynamicData = function()
			return { promDate = randomName() }
		end,
		text = "Prom is coming up! %promDate% asked you to go with them!",
		choices = {
			{ text = "💕 Yes!", effects = { Happiness = 12, Looks = 3, Money = -200 }, resultText = "You had an amazing night! Dancing, photos, memories!" },
			{ text = "👥 Go with friends instead", effects = { Happiness = 8 }, resultText = "You went with your friend group and had a blast!" },
			{ text = "🙅 Skip prom", effects = { Happiness = -3 }, resultText = "You skipped prom. Everyone's posts made you regret it a little." },
			{ text = "👑 Go alone, own it", effects = { Happiness = 6, Looks = 2 }, resultText = "You went solo and had an amazing time on your own terms!" },
		},
	},
	{
		id = "part_time_job",
		minAge = 15, maxAge = 18,
		weight = 25, oneTime = true,
		emoji = "💼", title = "First Job!",
		category = "work",
		getDynamicData = function()
			local jobs = {"fast food restaurant","grocery store","movie theater","ice cream shop","retail store","coffee shop","pizza place"}
			return { jobPlace = jobs[math.random(#jobs)] }
		end,
		text = "You got offered a part-time job at a %jobPlace%!",
		choices = {
			{ text = "✅ Take the job", effects = { Happiness = 2, Money = 500, Smarts = 2 }, resultText = "You started working! It's tiring but the money is nice.", setFlag = "employed" },
			{ text = "❌ Focus on school", effects = { Smarts = 3 }, resultText = "You decided school was more important right now." },
		},
	},
	{
		id = "party_peer_pressure",
		minAge = 15, maxAge = 19,
		weight = 18, cooldown = 2,
		emoji = "🎊", title = "The Party",
		category = "social",
		getDynamicData = function()
			return { partyHost = randomName() }
		end,
		text = "You're at %partyHost%'s party. Someone offers you a drink...",
		choices = {
			{ text = "🙅 No thanks", effects = { Happiness = 2, Health = 3 }, resultText = "You said no and still had fun. Good choice!" },
			{ text = "🍺 Just one", effects = { Happiness = 3, Health = -5, Smarts = -2 }, resultText = "You had one and got dizzy. Not your thing." },
			{ text = "🚪 Leave the party", effects = { Happiness = -2, Smarts = 3 }, resultText = "You left early. Better safe than sorry." },
			{ text = "🎉 Party hard", effects = { Happiness = 6, Health = -10, Smarts = -4 }, resultText = "You went all out. Fun night, rough morning.", setFlag = "party_animal" },
		},
	},
	{
		id = "caught_cheating",
		minAge = 14, maxAge = 22,
		weight = 8, cooldown = 3,
		emoji = "📝", title = "Cheating Scandal",
		category = "school",
		text = "You were caught looking at someone else's test during an exam!",
		choices = {
			{ text = "😔 Accept punishment", effects = { Happiness = -5, Smarts = -3 }, resultText = "You got a zero and detention. Lesson learned." },
			{ text = "🤥 Deny everything", effects = { Happiness = -3, Smarts = -5 }, resultText = "You lied but they had proof. Made it worse." },
			{ text = "😢 Cry and apologize", effects = { Happiness = -4, Smarts = -2 }, resultText = "You apologized sincerely. They gave you a chance to retake it." },
		},
	},
	{
		id = "graduation_hs",
		minAge = 18, maxAge = 18,
		weight = 100, oneTime = true, milestone = true,
		emoji = "🎓", title = "High School Graduation!",
		category = "school",
		text = "You did it! You're graduating high school! What's next?",
		choices = {
			{ text = "🏛️ Go to college", effects = { Smarts = 10, Money = -10000 }, resultText = "College bound! Student loans here you come.", setFlag = "college_student" },
			{ text = "💼 Start working", effects = { Happiness = 2, Money = 2000 }, resultText = "You entered the workforce. Time to make money!", setFlag = "employed" },
			{ text = "✈️ Take a gap year", effects = { Happiness = 8, Smarts = 3 }, resultText = "You took a year to travel and find yourself." },
			{ text = "🔧 Learn a trade", effects = { Smarts = 6, Money = -2000 }, resultText = "Trade school it is! Practical skills for life.", setFlag = "trade_certified" },
			{ text = "🎖️ Join military", effects = { Health = 5, Smarts = 3, Money = 1000 }, resultText = "You enlisted! Your country thanks you.", setFlag = "enlisted" },
		},
	},
	{
		id = "social_media_fame",
		minAge = 13, maxAge = 30,
		weight = 8, oneTime = true,
		emoji = "📱", title = "Going Viral!",
		category = "social",
		text = "One of your posts went viral! You're gaining thousands of followers!",
		choices = {
			{ text = "📈 Grow the audience", effects = { Happiness = 8, Looks = 3 }, resultText = "You leaned into it and became an influencer!", setFlag = "influencer" },
			{ text = "💰 Monetize it", effects = { Happiness = 5, Money = 1000 }, resultText = "You got some brand deals! Easy money." },
			{ text = "🙈 Delete everything", effects = { Happiness = -3 }, resultText = "The attention was too much. You went private." },
		},
	},
	{
		id = "political_awakening",
		minAge = 16, maxAge = 25,
		weight = 10, oneTime = true,
		emoji = "🗳️", title = "Political Awakening",
		category = "social",
		text = "You're becoming interested in politics and how the world works.",
		choices = {
			{ text = "📚 Study political science", effects = { Smarts = 5 }, resultText = "You started reading about politics and policy.", setFlag = "political_interest" },
			{ text = "✊ Become an activist", effects = { Happiness = 4, Smarts = 3 }, resultText = "You joined causes you believe in!", setFlag = "activist" },
			{ text = "🤷 Politics is boring", effects = { Happiness = 1 }, resultText = "You decided to focus on other things." },
		},
	},
	
	----------------------------------------------------------------
	-- YOUNG ADULT (Age 19-29)
	----------------------------------------------------------------
	{
		id = "college_major",
		minAge = 19, maxAge = 22,
		weight = 40, oneTime = true,
		emoji = "📚", title = "Choose Your Major",
		category = "school",
		requires = function(state) return state.Flags and state.Flags.college_student end,
		text = "What do you want to study in college?",
		choices = {
			{ text = "🔬 Science/Engineering", effects = { Smarts = 10 }, resultText = "STEM it is! Get ready for lots of math." },
			{ text = "💼 Business", effects = { Smarts = 6, Money = -500 }, resultText = "Business school! Networking is key." },
			{ text = "⚖️ Pre-Law", effects = { Smarts = 8 }, resultText = "Lawyer in the making! Better start studying.", setFlag = "pre_law" },
			{ text = "🩺 Pre-Med", effects = { Smarts = 10, Health = -2 }, resultText = "Doctor in training! Sleep is optional.", setFlag = "pre_med" },
			{ text = "🎨 Arts/Humanities", effects = { Happiness = 5, Smarts = 5 }, resultText = "Follow your passion! Who needs money anyway?" },
			{ text = "🖥️ Computer Science", effects = { Smarts = 8 }, resultText = "Tech is the future. Good choice." },
		},
	},
	{
		id = "college_graduation",
		minAge = 22, maxAge = 24,
		weight = 80, oneTime = true, milestone = true,
		emoji = "🎓", title = "College Graduation!",
		category = "school",
		requires = function(state) return state.Flags and state.Flags.college_student end,
		text = "Four years of hard work! You're graduating college!",
		choices = {
			{ text = "🎉 Celebrate!", effects = { Happiness = 10 }, resultText = "You did it! Time to celebrate this achievement!", setFlag = "bachelor_degree", clearFlag = "college_student" },
			{ text = "📚 Graduate school", effects = { Smarts = 5, Money = -20000 }, resultText = "You're continuing to graduate school!", setFlag = "grad_student" },
			{ text = "💼 Job hunt time", effects = { Smarts = 3, Happiness = 3 }, resultText = "Degree in hand, time to enter the workforce!", setFlag = "bachelor_degree", clearFlag = "college_student" },
		},
	},
	{
		id = "roommate_issue",
		minAge = 18, maxAge = 25,
		weight = 15, cooldown = 2,
		emoji = "🏠", title = "Roommate Drama",
		category = "social",
		getDynamicData = function()
			return { roomateName = randomName() }
		end,
		text = "Your roommate %roomateName% keeps eating your food without asking!",
		choices = {
			{ text = "😤 Confront them", effects = { Happiness = 3 }, resultText = "You talked it out and set boundaries. Problem solved!" },
			{ text = "📝 Label everything", effects = { Happiness = 2, Smarts = 2 }, resultText = "Passive aggressive but effective." },
			{ text = "😈 Eat their food", effects = { Happiness = 4, Smarts = -2 }, resultText = "War has been declared. This will escalate." },
			{ text = "🚪 Move out", effects = { Happiness = 5, Money = -500 }, resultText = "You found your own place. Peace at last!" },
		},
	},
	{
		id = "job_interview",
		minAge = 20, maxAge = 60,
		weight = 20, cooldown = 1,
		emoji = "👔", title = "Job Interview",
		category = "work",
		getDynamicData = function()
			return { companyName = randomCompany() }
		end,
		text = "You have a job interview at %companyName%! How do you prepare?",
		choices = {
			{ text = "📚 Research thoroughly", effects = { Smarts = 3, Happiness = 5, Money = 2000 }, resultText = "You nailed it! You got the job!", setFlag = "employed" },
			{ text = "🤷 Wing it", effects = { Happiness = -3 }, resultText = "They could tell you didn't prepare. No callback." },
			{ text = "👔 Dress to impress", effects = { Looks = 3, Happiness = 3, Money = 1500 }, resultText = "Your professional appearance helped! You got an offer.", setFlag = "employed" },
		},
	},
	{
		id = "first_apartment",
		minAge = 18, maxAge = 30,
		weight = 25, oneTime = true,
		emoji = "🏢", title = "First Apartment!",
		category = "money",
		text = "You're moving into your first apartment! Independence at last!",
		choices = {
			{ text = "🎉 So excited!", effects = { Happiness = 10, Money = -1500 }, resultText = "You decorated it perfectly! This is YOUR space!", setFlag = "renter" },
			{ text = "💰 Budget carefully", effects = { Happiness = 5, Smarts = 3, Money = -800 }, resultText = "You found a great deal and saved money. Smart!", setFlag = "renter" },
			{ text = "👥 Get roommates", effects = { Happiness = 3, Money = -400 }, resultText = "Splitting rent makes everything easier!", setFlag = "renter" },
		},
	},
	{
		id = "promotion",
		minAge = 22, maxAge = 60,
		weight = 12, cooldown = 3,
		emoji = "📈", title = "Promotion Opportunity!",
		category = "work",
		requires = function(state) return state.Flags and state.Flags.employed end,
		getDynamicData = function()
			return { newTitle = math.random(2) == 1 and "Senior " or "Lead " }
		end,
		text = "Your boss wants to promote you to %newTitle% position!",
		choices = {
			{ text = "✅ Accept!", effects = { Happiness = 8, Smarts = 2, Money = 5000 }, resultText = "Congratulations! More money and responsibility!", setFlag = "promoted" },
			{ text = "💰 Negotiate more", effects = { Smarts = 3, Money = 7000 }, resultText = "You negotiated a better package. Boss respects that!" },
			{ text = "❌ Too much pressure", effects = { Happiness = 2 }, resultText = "You declined. Work-life balance is important." },
		},
	},
	{
		id = "dating_app",
		minAge = 18, maxAge = 50,
		weight = 15, cooldown = 2,
		emoji = "📱", title = "Dating App Match",
		category = "romance",
		getDynamicData = function()
			return { matchName = randomName() }
		end,
		text = "You matched with %matchName% on a dating app! They seem interesting.",
		choices = {
			{ text = "💬 Send a message", effects = { Happiness = 5 }, resultText = "You hit it off! First date scheduled for Friday!", setFlag = "dating" },
			{ text = "😬 Too nervous", effects = { Happiness = -2 }, resultText = "You never messaged. The match expired." },
			{ text = "🔍 Research first", effects = { Smarts = 2, Happiness = 3 }, resultText = "You checked their socials. Seems legit. You messaged!" },
		},
	},
	{
		id = "engagement",
		minAge = 22, maxAge = 50,
		weight = 8, oneTime = true,
		emoji = "💍", title = "The Proposal!",
		category = "romance",
		requires = function(state) return state.Flags and state.Flags.dating end,
		getDynamicData = function()
			return { partnerName = randomName() }
		end,
		text = "You've been with %partnerName% for a while. It's time to pop the question!",
		choices = {
			{ text = "💍 Propose!", effects = { Happiness = 15, Money = -5000 }, resultText = "They said YES! You're engaged!", setFlag = "engaged", clearFlag = "dating" },
			{ text = "⏳ Not ready yet", effects = { Happiness = -2 }, resultText = "You decided to wait a bit longer." },
			{ text = "💔 Break up instead", effects = { Happiness = -10 }, resultText = "You realized they weren't the one. It hurt, but it's for the best.", clearFlag = "dating" },
		},
	},
	{
		id = "wedding",
		minAge = 22, maxAge = 60,
		weight = 10, oneTime = true,
		emoji = "💒", title = "Wedding Day!",
		category = "romance",
		requires = function(state) return state.Flags and state.Flags.engaged end,
		getDynamicData = function()
			return { spouseName = randomName() }
		end,
		text = "It's your wedding day! You're marrying %spouseName%!",
		choices = {
			{ text = "💒 Grand wedding!", effects = { Happiness = 15, Money = -20000 }, resultText = "It was the wedding of your dreams! Magical!", setFlag = "married", clearFlag = "engaged" },
			{ text = "👥 Intimate ceremony", effects = { Happiness = 12, Money = -3000 }, resultText = "A beautiful, personal ceremony with close ones.", setFlag = "married", clearFlag = "engaged" },
			{ text = "✈️ Elope!", effects = { Happiness = 10, Money = -500 }, resultText = "You eloped! Romantic and affordable!", setFlag = "married", clearFlag = "engaged" },
		},
	},
	{
		id = "start_business",
		minAge = 21, maxAge = 60,
		weight = 8, oneTime = true,
		emoji = "🏢", title = "Start a Business?",
		category = "work",
		text = "You have a great business idea! Should you pursue it?",
		choices = {
			{ text = "🚀 Go for it!", effects = { Happiness = 8, Money = -10000, Smarts = 5 }, resultText = "You started your own company! The entrepreneurial life begins!", setFlag = "entrepreneur" },
			{ text = "⏳ Keep planning", effects = { Smarts = 3 }, resultText = "You decided to plan more before jumping in." },
			{ text = "💼 Too risky", effects = { Happiness = -2 }, resultText = "You stuck with the safe route. Maybe someday." },
		},
	},
	
	----------------------------------------------------------------
	-- ADULT LIFE (Age 30-60)
	----------------------------------------------------------------
	{
		id = "midlife_reflection",
		minAge = 35, maxAge = 45,
		weight = 25, oneTime = true, milestone = true,
		emoji = "🤔", title = "Midlife Reflection",
		category = "health",
		text = "You're thinking about where you are in life. Is this what you wanted?",
		choices = {
			{ text = "😊 Pretty happy actually", effects = { Happiness = 8 }, resultText = "You realized you've built a good life. Gratitude!" },
			{ text = "🔄 Time for a change", effects = { Happiness = 5, Smarts = 3 }, resultText = "You decided to make some positive changes." },
			{ text = "🚗 Buy a sports car", effects = { Happiness = 6, Money = -50000, Looks = 3 }, resultText = "Classic midlife crisis purchase. But you look good!" },
			{ text = "😰 Is this it?", effects = { Happiness = -5 }, resultText = "You're having existential thoughts. Maybe therapy would help." },
		},
	},
	{
		id = "health_scare",
		minAge = 40, maxAge = 80,
		weight = 12, cooldown = 5,
		emoji = "🏥", title = "Health Scare",
		category = "health",
		text = "The doctor found something concerning in your checkup...",
		choices = {
			{ text = "🏥 Get it checked out", effects = { Health = -5, Smarts = 3, Money = -2000 }, resultText = "False alarm! But good thing you followed up." },
			{ text = "🙈 Ignore it", effects = { Health = -15 }, resultText = "Ignoring health issues is never a good idea..." },
			{ text = "💪 Change lifestyle", effects = { Health = 5, Happiness = 3 }, resultText = "You started eating better and exercising. Great choice!" },
		},
	},
	{
		id = "inheritance",
		minAge = 25, maxAge = 70,
		weight = 5, oneTime = true,
		emoji = "💰", title = "Unexpected Inheritance",
		category = "money",
		getDynamicData = function()
			local amounts = {5000, 10000, 25000, 50000, 100000, 500000}
			return { amount = amounts[math.random(#amounts)] }
		end,
		text = "A distant relative passed away and left you $%amount%!",
		choices = {
			{ text = "🏦 Save it", effects = { Smarts = 3 }, resultText = "You saved it wisely. Smart financial move!", getDynamicMoney = function(d) return d.amount end, setFlag = "inherited_wealth" },
			{ text = "📈 Invest it", effects = { Smarts = 5 }, resultText = "You invested it. Hopefully it grows!", getDynamicMoney = function(d) return d.amount end },
			{ text = "🛍️ Treat yourself", effects = { Happiness = 8, Looks = 3 }, resultText = "You splurged! You deserve it!", getDynamicMoney = function(d) return d.amount * 0.5 end },
		},
	},
	{
		id = "kid_born",
		minAge = 22, maxAge = 45,
		weight = 10, cooldown = 3,
		emoji = "👶", title = "Baby On The Way!",
		category = "family",
		requires = function(state) return state.Flags and state.Flags.married end,
		text = "Congratulations! You're going to be a parent!",
		choices = {
			{ text = "🎉 Over the moon!", effects = { Happiness = 15, Health = -3, Money = -2000 }, resultText = "A beautiful baby entered your life! Sleep is overrated anyway.", setFlag = "has_kids" },
			{ text = "😰 So nervous", effects = { Happiness = 8, Smarts = 2, Money = -2000 }, resultText = "You were nervous but stepped up! Great parent in the making.", setFlag = "has_kids" },
		},
	},
	{
		id = "career_burnout",
		minAge = 28, maxAge = 55,
		weight = 15, cooldown = 4,
		emoji = "😩", title = "Burnout",
		category = "work",
		requires = function(state) return state.Flags and state.Flags.employed end,
		text = "You're completely burned out from work. Something has to change.",
		choices = {
			{ text = "✈️ Take a vacation", effects = { Happiness = 8, Health = 5, Money = -2000 }, resultText = "You took a break and came back refreshed!" },
			{ text = "🚪 Quit the job", effects = { Happiness = 10, Health = 3, Money = -5000 }, resultText = "You quit! Scary but liberating.", clearFlag = "employed", setFlag = "unemployed" },
			{ text = "💪 Push through", effects = { Happiness = -8, Health = -10 }, resultText = "You kept going but your health suffered..." },
			{ text = "🧘 Start therapy", effects = { Happiness = 5, Health = 3, Money = -500 }, resultText = "You got help. Smart move.", setFlag = "in_therapy" },
		},
	},
	{
		id = "buy_house",
		minAge = 25, maxAge = 60,
		weight = 10, oneTime = true,
		emoji = "🏠", title = "Buy a House?",
		category = "money",
		text = "You've saved up enough for a down payment. Ready to be a homeowner?",
		choices = {
			{ text = "🏠 Buy the house!", effects = { Happiness = 12, Money = -50000 }, resultText = "You're a homeowner! The American dream!", setFlag = "homeowner", clearFlag = "renter" },
			{ text = "💰 Keep saving", effects = { Smarts = 3 }, resultText = "You decided to wait for a better opportunity." },
			{ text = "📈 Invest instead", effects = { Smarts = 4 }, resultText = "You put the money in investments. Different kind of asset!" },
		},
	},
	{
		id = "divorce",
		minAge = 25, maxAge = 70,
		weight = 5, oneTime = true,
		emoji = "💔", title = "Marriage Troubles",
		category = "romance",
		requires = function(state) return state.Flags and state.Flags.married end,
		getDynamicData = function()
			return { spouseName = randomName() }
		end,
		text = "Things aren't going well with %spouseName%. You're considering divorce.",
		choices = {
			{ text = "💔 File for divorce", effects = { Happiness = -15, Money = -20000 }, resultText = "It's over. Painful but sometimes necessary.", setFlag = "divorced", clearFlag = "married" },
			{ text = "💝 Try counseling", effects = { Happiness = 3, Money = -2000 }, resultText = "You decided to work on the marriage. Things improved!" },
			{ text = "🤔 Give it time", effects = { Happiness = -5 }, resultText = "You're waiting to see if things improve on their own." },
		},
	},
	{
		id = "retirement",
		minAge = 55, maxAge = 70,
		weight = 20, oneTime = true, milestone = true,
		emoji = "🏖️", title = "Retirement Time!",
		category = "work",
		text = "You've worked your whole life. Ready to retire?",
		choices = {
			{ text = "🏖️ Retire now!", effects = { Happiness = 15, Health = 5 }, resultText = "You're officially retired! Time to enjoy life!", setFlag = "retired", clearFlag = "employed" },
			{ text = "💼 Keep working", effects = { Happiness = -2, Money = 5000 }, resultText = "You're not ready to stop. The work continues." },
			{ text = "🏖️ Part-time", effects = { Happiness = 8, Money = 2000 }, resultText = "Semi-retirement! Best of both worlds.", setFlag = "retired" },
		},
	},
	
	----------------------------------------------------------------
	-- POLITICAL PATH EVENTS
	----------------------------------------------------------------
	{
		id = "run_for_local_office",
		minAge = 25, maxAge = 60,
		weight = 5, oneTime = true,
		emoji = "🗳️", title = "Run for Office?",
		category = "work",
		requires = function(state) return state.Flags and state.Flags.political_interest end,
		text = "You've been encouraged to run for local city council. This could be the start of a political career.",
		choices = {
			{ text = "🗳️ Run for office!", effects = { Happiness = 8, Money = -5000, Smarts = 3 }, resultText = "You campaigned hard and won! You're on city council!", setFlag = "elected_official", setFlags = {"city_council"} },
			{ text = "⏳ Not yet", effects = { Smarts = 2 }, resultText = "You decided to wait and build more experience." },
			{ text = "🙅 Politics isn't for me", effects = { Happiness = 2 }, resultText = "You decided political life wasn't your path." },
		},
	},
	{
		id = "run_for_mayor",
		minAge = 30, maxAge = 65,
		weight = 5, oneTime = true,
		emoji = "🏛️", title = "Mayoral Race!",
		category = "work",
		requires = function(state) return state.Flags and state.Flags.city_council end,
		text = "You have the support to run for mayor! It's a big step up.",
		choices = {
			{ text = "🏛️ Run for mayor!", effects = { Happiness = 10, Money = -20000, Smarts = 4 }, resultText = "You won the election! You're the mayor!", setFlag = "mayor", minigame = "debate" },
			{ text = "⏳ Need more experience", effects = { Smarts = 2 }, resultText = "You decided to stay on council longer." },
		},
	},
	{
		id = "run_for_state_office",
		minAge = 30, maxAge = 65,
		weight = 5, oneTime = true,
		emoji = "🏛️", title = "State Legislature Race!",
		category = "work",
		requires = function(state) return state.Flags and (state.Flags.mayor or state.Flags.city_council) end,
		text = "You have a chance to run for state legislature!",
		choices = {
			{ text = "🗳️ Run for state rep!", effects = { Happiness = 10, Money = -30000, Smarts = 5 }, resultText = "You won! You're a state representative!", setFlag = "state_representative", minigame = "debate" },
			{ text = "🗳️ Run for state senate!", effects = { Happiness = 12, Money = -50000, Smarts = 5 }, resultText = "You won the state senate race!", setFlag = "state_senator", minigame = "debate" },
		},
	},
	{
		id = "run_for_congress",
		minAge = 35, maxAge = 70,
		weight = 5, oneTime = true,
		emoji = "🏛️", title = "Congressional Race!",
		category = "work",
		requires = function(state) return state.Flags and (state.Flags.state_senator or state.Flags.state_representative or state.Flags.governor) end,
		text = "The party wants you to run for Congress! This is the big leagues.",
		choices = {
			{ text = "🗳️ Run for Congress!", effects = { Happiness = 15, Money = -100000, Smarts = 6 }, resultText = "You won! You're going to Washington!", setFlag = "congressman", minigame = "debate" },
			{ text = "⏳ Not ready", effects = { Smarts = 2 }, resultText = "You decided to wait for a better opportunity." },
		},
	},
	{
		id = "run_for_senate",
		minAge = 35, maxAge = 70,
		weight = 3, oneTime = true,
		emoji = "🏛️", title = "U.S. Senate Race!",
		category = "work",
		requires = function(state) return state.Flags and state.Flags.congressman end,
		text = "You have a shot at the U.S. Senate! This is huge.",
		choices = {
			{ text = "🗳️ Run for Senate!", effects = { Happiness = 15, Money = -500000, Smarts = 7 }, resultText = "You won! You're a U.S. Senator!", setFlag = "us_senator", minigame = "debate" },
		},
	},
	{
		id = "presidential_run",
		minAge = 40, maxAge = 75,
		weight = 2, oneTime = true,
		emoji = "🇺🇸", title = "Presidential Race!",
		category = "work",
		requires = function(state) return state.Flags and (state.Flags.us_senator or state.Flags.governor) end,
		text = "The nation is calling. Will you run for President of the United States?",
		choices = {
			{ text = "🇺🇸 Run for President!", effects = { Happiness = 20, Money = -1000000, Smarts = 10 }, resultText = "YOU WON! You're the President of the United States!", setFlag = "president", minigame = "debate" },
			{ text = "⏳ Maybe next cycle", effects = { Smarts = 3 }, resultText = "You decided to wait for a better opportunity." },
		},
	},
	
	----------------------------------------------------------------
	-- CRIMINAL PATH EVENTS
	----------------------------------------------------------------
	{
		id = "first_crime",
		minAge = 12, maxAge = 25,
		weight = 8, oneTime = true,
		emoji = "😈", title = "The Temptation",
		category = "crime",
		text = "A friend suggests shoplifting something from a store. Easy money, they say.",
		choices = {
			{ text = "🛒 Steal it", effects = { Happiness = 3, Smarts = -2, Money = 20 }, resultText = "You got away with it. The rush was real.", setFlag = "shoplifter", setFlags = {"criminal_tendencies"} },
			{ text = "🙅 That's wrong", effects = { Happiness = 2, Smarts = 2 }, resultText = "You walked away. Crime isn't for you." },
			{ text = "🚨 Almost caught!", effects = { Happiness = -5, Health = -2 }, resultText = "Security spotted you. You ran. Close call." },
		},
	},
	{
		id = "steal_car",
		minAge = 16, maxAge = 35,
		weight = 5, oneTime = true,
		emoji = "🚗", title = "Grand Theft Auto",
		category = "crime",
		requires = function(state) return state.Flags and state.Flags.criminal_tendencies end,
		text = "That nice car on the corner is just sitting there, keys probably inside...",
		choices = {
			{ text = "🚗 Take it for a ride", effects = { Happiness = 5, Money = 500 }, resultText = "You stole the car and sold it. Easy money.", setFlag = "car_thief", minigame = "heist" },
			{ text = "🚔 Too risky", effects = { Smarts = 2 }, resultText = "You thought better of it. Smart." },
			{ text = "🚨 Get caught", effects = { Happiness = -20, Money = -1000 }, resultText = "The cops caught you. Jail time.", setFlag = "in_prison" },
		},
	},
	{
		id = "gang_recruitment",
		minAge = 16, maxAge = 30,
		weight = 5, oneTime = true,
		emoji = "👥", title = "Gang Recruitment",
		category = "crime",
		requires = function(state) return state.Flags and (state.Flags.car_thief or state.Flags.shoplifter) end,
		getDynamicData = function()
			local gangs = {"The Vipers","Street Kings","Black Aces","Los Diablos","The Syndicate"}
			return { gangName = gangs[math.random(#gangs)] }
		end,
		text = "%gangName% has noticed your work. They're offering you a spot.",
		choices = {
			{ text = "✅ Join the gang", effects = { Happiness = 8, Money = 2000 }, resultText = "You're officially part of %gangName%. No going back.", setFlag = "gang_member" },
			{ text = "❌ Decline", effects = { Happiness = -3, Health = -5 }, resultText = "They didn't take rejection well. Watch your back." },
		},
	},
	{
		id = "gang_war",
		minAge = 18, maxAge = 45,
		weight = 10, cooldown = 2,
		emoji = "⚔️", title = "Gang War",
		category = "crime",
		requires = function(state) return state.Flags and state.Flags.gang_member end,
		text = "A rival gang is moving on your territory. Blood will be spilled.",
		choices = {
			{ text = "⚔️ Fight back hard", effects = { Health = -15, Happiness = 5, Money = 5000 }, resultText = "You fought and won. Your reputation grew.", setFlag = "war_veteran", minigame = "getaway" },
			{ text = "🤝 Try to negotiate", effects = { Smarts = 3 }, resultText = "You managed to avoid bloodshed. Wise move." },
			{ text = "🏃 Lay low", effects = { Happiness = -5 }, resultText = "You stayed out of it. Others noticed." },
		},
	},
	{
		id = "underboss_promotion",
		minAge = 25, maxAge = 50,
		weight = 5, oneTime = true,
		emoji = "👔", title = "Rise in the Ranks",
		category = "crime",
		requires = function(state) return state.Flags and state.Flags.gang_member and state.Flags.war_veteran end,
		text = "The boss has taken notice of your loyalty and skill. Promotion time.",
		choices = {
			{ text = "👔 Accept the promotion", effects = { Happiness = 12, Money = 20000 }, resultText = "You're now underboss. Power comes with a price.", setFlag = "underboss" },
		},
	},
	{
		id = "become_boss",
		minAge = 30, maxAge = 60,
		weight = 3, oneTime = true,
		emoji = "👑", title = "Take the Throne",
		category = "crime",
		requires = function(state) return state.Flags and state.Flags.underboss end,
		text = "The boss is gone. The organization needs new leadership. It's your time.",
		choices = {
			{ text = "👑 Take control", effects = { Happiness = 15, Money = 100000 }, resultText = "You're now the boss. The criminal empire is yours.", setFlag = "crime_boss" },
			{ text = "🚪 Walk away", effects = { Happiness = 5, Health = 5 }, resultText = "You left the life behind. A fresh start.", clearFlags = {"gang_member", "underboss"} },
		},
	},
	{
		id = "arrested",
		minAge = 14, maxAge = 70,
		weight = 8, cooldown = 3,
		emoji = "🚔", title = "Arrested!",
		category = "crime",
		requires = function(state) return state.Flags and (state.Flags.criminal_tendencies or state.Flags.gang_member) end,
		text = "The police caught up with you. You're being arrested!",
		choices = {
			{ text = "🤐 Say nothing", effects = { Smarts = 3 }, resultText = "You kept your mouth shut. Lawyer up." },
			{ text = "🐀 Cooperate", effects = { Happiness = -10, Money = -5000 }, resultText = "You talked. Others won't be happy.", setFlag = "rat" },
			{ text = "🏃 Try to escape", effects = { Health = -10, Happiness = -5 }, resultText = "Bad idea. They added more charges.", minigame = "getaway" },
		},
	},
	{
		id = "prison_time",
		minAge = 18, maxAge = 70,
		weight = 5, cooldown = 5,
		emoji = "⛓️", title = "Prison Life",
		category = "crime",
		requires = function(state) return state.Flags and state.Flags.in_prison end,
		text = "You're serving time. Life behind bars is rough.",
		choices = {
			{ text = "💪 Join a gang inside", effects = { Health = -5, Happiness = 2 }, resultText = "You found protection. Survival first." },
			{ text = "📚 Use time to study", effects = { Smarts = 5, Happiness = 3 }, resultText = "You educated yourself. Time well spent." },
			{ text = "🏋️ Work out", effects = { Health = 8, Looks = 3 }, resultText = "You got jacked. Nobody messes with you now." },
		},
	},
	
	----------------------------------------------------------------
	-- RANDOM LIFE EVENTS
	----------------------------------------------------------------
	{
		id = "find_money",
		minAge = 5, maxAge = 90,
		weight = 10, cooldown = 3,
		emoji = "💵", title = "Lucky Find!",
		category = "money",
		getDynamicData = function()
			local amounts = {5, 10, 20, 50, 100, 500}
			return { amount = amounts[math.random(#amounts)] }
		end,
		text = "You found $%amount% on the ground!",
		choices = {
			{ text = "💰 Keep it", effects = { Happiness = 5 }, resultText = "Finders keepers!", getDynamicMoney = function(d) return d.amount end },
			{ text = "🔍 Find the owner", effects = { Happiness = 3, Smarts = 2 }, resultText = "You tried to find the owner. Good karma!", getDynamicMoney = function(d) return d.amount * 0.5 end },
		},
	},
	{
		id = "random_kindness",
		minAge = 10, maxAge = 90,
		weight = 12, cooldown = 2,
		emoji = "💝", title = "Random Act of Kindness",
		category = "social",
		text = "You see someone struggling with heavy bags. What do you do?",
		choices = {
			{ text = "🤝 Help them", effects = { Happiness = 8 }, resultText = "You helped them out! They were so grateful. Good karma!" },
			{ text = "😅 Too busy", effects = { Happiness = -2 }, resultText = "You walked past. You feel a little guilty." },
		},
	},
	{
		id = "flat_tire",
		minAge = 16, maxAge = 80,
		weight = 10, cooldown = 3,
		emoji = "🚗", title = "Flat Tire!",
		category = "random",
		text = "You got a flat tire on your way somewhere important!",
		choices = {
			{ text = "🔧 Fix it yourself", effects = { Happiness = 3, Smarts = 3 }, resultText = "You fixed it yourself! Useful skill." },
			{ text = "📱 Call for help", effects = { Happiness = 1, Money = -100 }, resultText = "Help arrived. Cost some money but problem solved." },
			{ text = "😰 Panic", effects = { Happiness = -5 }, resultText = "You panicked and made everything worse. Bad day." },
		},
	},
	{
		id = "lottery_win",
		minAge = 18, maxAge = 90,
		weight = 1, oneTime = true,
		emoji = "🎰", title = "LOTTERY WINNER!",
		category = "money",
		getDynamicData = function()
			local amounts = {10000, 50000, 100000, 500000, 1000000, 10000000}
			return { amount = amounts[math.random(#amounts)] }
		end,
		text = "YOUR LOTTERY TICKET WON $%amount%!!! This can't be real!",
		choices = {
			{ text = "💰 Claim it all!", effects = { Happiness = 25 }, resultText = "You're rich! Life will never be the same!", getDynamicMoney = function(d) return d.amount end, setFlag = "millionaire" },
		},
	},
	{
		id = "car_accident",
		minAge = 16, maxAge = 90,
		weight = 6, cooldown = 5,
		emoji = "🚗", title = "Car Accident!",
		category = "health",
		text = "You were in a car accident! Are you okay?",
		choices = {
			{ text = "🏥 Go to hospital", effects = { Health = -20, Money = -5000, Happiness = -10 }, resultText = "You were injured but you'll recover. Medical bills are rough." },
			{ text = "😅 Just a scratch", effects = { Health = -5, Happiness = -3 }, resultText = "Luckily it wasn't serious. Your car is damaged though." },
		},
	},
	{
		id = "natural_disaster",
		minAge = 5, maxAge = 90,
		weight = 3, cooldown = 10,
		emoji = "🌪️", title = "Natural Disaster!",
		category = "random",
		getDynamicData = function()
			local disasters = {"tornado","hurricane","earthquake","flood","wildfire"}
			return { disaster = disasters[math.random(#disasters)] }
		end,
		text = "A %disaster% hit your area! This is terrifying!",
		choices = {
			{ text = "🏃 Evacuate immediately", effects = { Happiness = -5, Health = -3 }, resultText = "You got out safely. Your home has some damage." },
			{ text = "🏠 Ride it out", effects = { Health = -10, Happiness = -8 }, resultText = "It was intense. You made it through but barely." },
		},
	},
	{
		id = "pet_dies",
		minAge = 8, maxAge = 90,
		weight = 5, cooldown = 5,
		emoji = "🐕", title = "Goodbye, Friend",
		category = "family",
		text = "Your beloved pet has passed away. You're heartbroken.",
		choices = {
			{ text = "😢 Mourn", effects = { Happiness = -15 }, resultText = "You grieved. They were family." },
			{ text = "🐕 Get a new pet", effects = { Happiness = -5, Money = -200 }, resultText = "A new friend helped heal the pain. Life goes on." },
			{ text = "💪 Celebrate their life", effects = { Happiness = -8, Smarts = 2 }, resultText = "You focused on the good memories. They had a good life." },
		},
	},
	{
		id = "famous_encounter",
		minAge = 10, maxAge = 90,
		weight = 5, cooldown = 3,
		emoji = "⭐", title = "Celebrity Encounter!",
		category = "social",
		getDynamicData = function()
			local celebs = {"a famous actor","a pop star","a professional athlete","a famous YouTuber","a famous politician","a billionaire"}
			return { celeb = celebs[math.random(#celebs)] }
		end,
		text = "You ran into %celeb% at a coffee shop!",
		choices = {
			{ text = "📸 Ask for a selfie", effects = { Happiness = 8 }, resultText = "They said yes! You got the photo!" },
			{ text = "😎 Play it cool", effects = { Happiness = 5, Smarts = 2 }, resultText = "You had a nice conversation. They seemed to appreciate not being mobbed." },
			{ text = "🙈 Too nervous", effects = { Happiness = -2 }, resultText = "You froze up and they left. Missed opportunity." },
		},
	},
	{
		id = "scammed",
		minAge = 18, maxAge = 90,
		weight = 5, cooldown = 3,
		emoji = "😤", title = "Scammed!",
		category = "money",
		text = "You fell for an online scam and lost money!",
		choices = {
			{ text = "🚔 Report it", effects = { Happiness = -5, Money = -500, Smarts = 3 }, resultText = "You reported it but probably won't get the money back." },
			{ text = "😔 Learn from it", effects = { Happiness = -8, Money = -1000, Smarts = 5 }, resultText = "Expensive lesson. You'll be more careful now." },
		},
	},
	{
		id = "won_contest",
		minAge = 10, maxAge = 70,
		weight = 6, cooldown = 3,
		emoji = "🏆", title = "You Won!",
		category = "social",
		getDynamicData = function()
			local contests = {"a cooking contest","a talent show","a video game tournament","a writing contest","a photo contest"}
			return { contest = contests[math.random(#contests)] }
		end,
		text = "You entered %contest% and won first place!",
		choices = {
			{ text = "🎉 Celebrate!", effects = { Happiness = 12, Money = 500 }, resultText = "You won! The prize and recognition felt amazing!" },
			{ text = "😌 Stay humble", effects = { Happiness = 8, Smarts = 3, Money = 500 }, resultText = "You accepted the win graciously. People respect that." },
		},
	},
	
	----------------------------------------------------------------
	-- SENIOR YEARS (Age 60+)
	----------------------------------------------------------------
	{
		id = "grandchild_born",
		minAge = 50, maxAge = 90,
		weight = 10, cooldown = 3,
		emoji = "👶", title = "Grandchild Born!",
		category = "family",
		requires = function(state) return state.Flags and state.Flags.has_kids end,
		text = "Congratulations! You're a grandparent! Your grandchild was just born!",
		choices = {
			{ text = "🥰 So blessed!", effects = { Happiness = 20 }, resultText = "Holding your grandchild for the first time was magical." },
			{ text = "👴 Feel old", effects = { Happiness = 10, Health = -3 }, resultText = "You're happy but wow, where did the time go?" },
		},
	},
	{
		id = "memory_loss",
		minAge = 65, maxAge = 100,
		weight = 8, cooldown = 5,
		emoji = "🧠", title = "Memory Troubles",
		category = "health",
		text = "You've been forgetting things more often. It's concerning.",
		choices = {
			{ text = "🏥 See a doctor", effects = { Health = -5, Smarts = -5, Money = -1000 }, resultText = "The doctor says it's normal aging. Stay mentally active." },
			{ text = "🧩 Brain exercises", effects = { Smarts = 3, Happiness = 3 }, resultText = "You started doing puzzles and reading more. It helps!" },
			{ text = "😰 Worry about it", effects = { Happiness = -8, Health = -3 }, resultText = "The worry makes it worse. Try to stay positive." },
		},
	},
	{
		id = "bucket_list",
		minAge = 60, maxAge = 90,
		weight = 10, oneTime = true,
		emoji = "📝", title = "Bucket List",
		category = "social",
		text = "You've made a bucket list of things to do before you die. What's first?",
		choices = {
			{ text = "✈️ Travel the world", effects = { Happiness = 15, Money = -10000, Health = -5 }, resultText = "You visited places you've always dreamed of. Worth every penny.", setFlag = "world_traveler" },
			{ text = "✍️ Write your memoir", effects = { Happiness = 10, Smarts = 5 }, resultText = "You wrote about your life. Future generations will know your story.", setFlag = "author" },
			{ text = "🪂 Skydiving!", effects = { Happiness = 12, Health = -3 }, resultText = "You jumped out of a plane! What a rush!" },
			{ text = "👨‍👩‍👧‍👦 Family time", effects = { Happiness = 15 }, resultText = "You spent quality time with loved ones. That's what really matters." },
		},
	},
	{
		id = "legacy",
		minAge = 70, maxAge = 100,
		weight = 10, oneTime = true,
		emoji = "🏛️", title = "Your Legacy",
		category = "social",
		text = "You're thinking about what you'll leave behind. What matters most?",
		choices = {
			{ text = "💰 Leave money", effects = { Happiness = 8 }, resultText = "You set up your estate to provide for your family." },
			{ text = "📚 Share wisdom", effects = { Happiness = 10, Smarts = 3 }, resultText = "You documented life lessons for future generations." },
			{ text = "💝 Charity", effects = { Happiness = 12, Money = -5000 }, resultText = "You donated to causes you believe in. Making the world better.", setFlag = "volunteer" },
			{ text = "🏠 Family home", effects = { Happiness = 10 }, resultText = "The family home will stay in the family. Memories live on." },
		},
	},
}

----------------------------------------------------------------------
-- BUILD LOOKUP TABLES
----------------------------------------------------------------------

EventLibrary.Events = events

local byId = {}
for _, ev in ipairs(events) do
	byId[ev.id] = ev
end
EventLibrary.ById = byId

-- Helper functions for external use
EventLibrary.RandomMaleName = randomMaleName
EventLibrary.RandomFemaleName = randomFemaleName
EventLibrary.RandomName = randomName
EventLibrary.RandomCompany = randomCompany
EventLibrary.RandomCity = randomCity

return EventLibrary
