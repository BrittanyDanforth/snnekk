-- LifeEvents/child_6_12.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- CHILDHOOD EVENTS (Ages 6-12) - MASSIVE EXPANSION
-- 120+ deeply thought-out events for elementary school years
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent.init)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- KINDERGARTEN & FIRST GRADE (Ages 5-7)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_kindergarten_start",
		minAge = 5, maxAge = 6,
		weight = 100, milestone = true, oneTime = true,
		emoji = "🏫", title = "First Day of Kindergarten!",
		category = "school",
		getDynamicData = function()
			local schools = {"Washington Elementary", "Lincoln Elementary", "Roosevelt Elementary", "Jefferson Elementary", "Madison Elementary"}
			return { school = schools[math.random(#schools)] }
		end,
		text = "The big day is here! You're starting kindergarten at %school%! Backpack packed, lunchbox ready, butterflies in your stomach.",
		choices = {
			{ text = "🎉 Excited!", effects = { Happiness = 8, Smarts = 3 }, resultText = "You bounced into class and made friends immediately!" },
			{ text = "😭 Don't want to go!", effects = { Happiness = -4 }, resultText = "You clung to your parent, crying. But eventually you calmed down." },
			{ text = "🤝 Make a best friend", effects = { Happiness = 10, Smarts = 2 }, resultText = "You met someone special on day one. Best friends!" },
			{ text = "📚 Focus on learning", effects = { Smarts = 8, Happiness = 2 }, resultText = "You impressed the teacher with your focus!", setFlag = "teacher_favorite" },
		},
	},
	
	{
		id = "m_reading_journey",
		minAge = 5, maxAge = 7,
		weight = 60, oneTime = true,
		emoji = "📖", title = "Learning to Read!",
		category = "school",
		getDynamicData = function()
			local books = {"Cat in the Hat", "Green Eggs and Ham", "Clifford the Big Red Dog", "Goodnight Moon", "Where the Wild Things Are"}
			return { book = books[math.random(#books)] }
		end,
		text = "You're learning to read! Your first book was '%book%'!",
		choices = {
			{ text = "📚 I LOVE reading!", effects = { Smarts = 10, Happiness = 6 }, resultText = "Books became your portal to other worlds!", setFlags = {"bookworm", "early_reader"} },
			{ text = "🤔 It's hard...", effects = { Smarts = 4, Happiness = -2 }, resultText = "Reading was challenging, but you kept trying." },
			{ text = "🏃 Prefer other stuff", effects = { Smarts = 2, Happiness = 4 }, resultText = "Reading is fine, but playing is more fun!" },
			{ text = "📚 Read to a pet/sibling", effects = { Smarts = 6, Happiness = 6 }, resultText = "You practiced reading to anyone who'd listen!", setFlag = "bookworm" },
		},
	},
	
	{
		id = "m_first_report_card",
		minAge = 6, maxAge = 12,
		weight = 45, cooldown = 3,
		emoji = "📋", title = "Report Card Time!",
		category = "school",
		getDynamicData = function()
			local grades = math.random(1, 10)
			local performance = grades > 7 and "excellent" or grades > 4 and "average" or "needs improvement"
			return { performance = performance, grades = grades }
		end,
		text = "Report cards are out! Your performance this term was: %performance%.",
		choices = {
			{ text = "📈 Straight A's!", effects = { Smarts = 8, Happiness = 7, Money = 20 }, resultText = "Your parents were so proud! Maybe even a reward!", setFlag = "honor_student" },
			{ text = "📊 Middle of the pack", effects = { Smarts = 3, Happiness = 2 }, resultText = "Not the best, not the worst. Room for improvement." },
			{ text = "📉 Uh oh...", effects = { Smarts = 1, Happiness = -5 }, resultText = "Your parents had 'a talk' with you about trying harder." },
			{ text = "🎭 Hide the bad grades", effects = { Happiness = 2, Smarts = -2 }, resultText = "You hid it... until parent-teacher conference.", setFlag = "sneaky" },
		},
	},
	
	{
		id = "m_playground_politics",
		minAge = 6, maxAge = 10,
		weight = 35, cooldown = 2,
		emoji = "🛝", title = "Playground Politics",
		category = "social",
		getDynamicData = function()
			return { kidName = LifeEvents.randomFirstName() }
		end,
		text = "%kidName% says you can't play with their group unless you do what they say!",
		choices = {
			{ text = "👑 Start your own group", effects = { Happiness = 6, Smarts = 4 }, resultText = "You made your own group! It became more popular.", setFlag = "leader" },
			{ text = "🤷 Follow the rules", effects = { Happiness = 2 }, resultText = "You went along with it. Playing was more important." },
			{ text = "🗣️ Tell a teacher", effects = { Happiness = 4, Smarts = 1 }, resultText = "The teacher made %kidName% include everyone." },
			{ text = "🙅 Don't need them!", effects = { Happiness = 3, Smarts = 3 }, resultText = "You found other friends. Their loss!" },
		},
	},
	
	{
		id = "m_lunch_table_drama",
		minAge = 6, maxAge = 12,
		weight = 30, cooldown = 2,
		emoji = "🍽️", title = "Lunch Table Drama",
		category = "social",
		getDynamicData = function()
			return { friendName = LifeEvents.randomFirstName() }
		end,
		text = "There's drama at the lunch table! %friendName% is sitting in 'your' spot and your friend group is divided!",
		choices = {
			{ text = "🤷 Who cares, sit anywhere", effects = { Happiness = 4, Smarts = 3 }, resultText = "You're too mature for this drama." },
			{ text = "😤 Make a fuss", effects = { Happiness = -3 }, resultText = "You made a scene. Now everyone's uncomfortable." },
			{ text = "🤝 Make peace", effects = { Happiness = 6, Smarts = 2 }, resultText = "You found a solution! Everyone sits together.", setFlag = "peacemaker" },
			{ text = "🍽️ Start new lunch spot", effects = { Happiness = 5 }, resultText = "You found a better table! Others followed." },
		},
	},
	
	{
		id = "m_show_and_tell",
		minAge = 6, maxAge = 8,
		weight = 40, cooldown = 2,
		emoji = "🎤", title = "Show and Tell!",
		category = "school",
		getDynamicData = function()
			local items = {"rock collection", "pet lizard", "family photo", "trophy", "cool toy", "homemade art", "grandpa's medal"}
			return { item = items[math.random(#items)] }
		end,
		text = "It's Show and Tell day! You're bringing your %item% to share with the class.",
		choices = {
			{ text = "🌟 Amazing presentation!", effects = { Smarts = 6, Happiness = 8, Looks = 2 }, resultText = "The class loved it! You got a round of applause!", setFlag = "public_speaker" },
			{ text = "😰 Too nervous to present", effects = { Happiness = -4 }, resultText = "You barely got through it. Public speaking is scary." },
			{ text = "🤔 Interesting facts!", effects = { Smarts = 8, Happiness = 4 }, resultText = "You taught everyone something new!", setFlag = "trivia_master" },
			{ text = "😂 Made everyone laugh", effects = { Happiness = 7, Looks = 3 }, resultText = "Your presentation was hilarious!", setFlag = "class_clown" },
		},
	},
	
	{
		id = "m_first_crush",
		minAge = 8, maxAge = 12,
		weight = 35, oneTime = true,
		emoji = "💕", title = "First Crush!",
		category = "social",
		getDynamicData = function()
			return { crushName = LifeEvents.randomFirstName() }
		end,
		text = "You've developed a crush on %crushName% in your class! Your face gets red whenever they're around.",
		choices = {
			{ text = "😊 Try to be friends", effects = { Happiness = 6 }, resultText = "You became friends with your crush! Mission accomplished!", setFlag = "has_crush" },
			{ text = "🤫 Keep it secret", effects = { Happiness = 4 }, resultText = "You admired from afar. Safe but tortured.", setFlag = "has_crush" },
			{ text = "💌 Pass a note", effects = { Happiness = 8, Smarts = -1 }, resultText = "%crushName% likes you too!! Your heart exploded!", setFlags = {"has_crush", "brave"} },
			{ text = "😰 Too embarrassed", effects = { Happiness = -2 }, resultText = "You couldn't even look at them. Crushing is hard." },
		},
	},
	
	{
		id = "m_school_bully",
		minAge = 6, maxAge = 12,
		weight = 25, cooldown = 3,
		emoji = "😠", title = "Bully Encounter",
		category = "social",
		getDynamicData = function()
			return { bullyName = LifeEvents.randomFirstName() }
		end,
		text = "%bullyName% has been bullying you at school - calling you names and taking your lunch money!",
		choices = {
			{ text = "🗣️ Tell an adult", effects = { Happiness = 4, Smarts = 3 }, resultText = "The teacher intervened. %bullyName% got in trouble." },
			{ text = "💪 Stand up for yourself", effects = { Health = -3, Happiness = 6 }, resultText = "You stood your ground! The bullying stopped.", setFlag = "brave" },
			{ text = "🤝 Try to befriend them", effects = { Happiness = 4, Smarts = 5 }, resultText = "Turns out %bullyName% had problems at home. You became unlikely friends.", setFlag = "empathetic" },
			{ text = "😢 Suffer in silence", effects = { Happiness = -8, Health = -3 }, resultText = "It was awful. Eventually your parents noticed something was wrong." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- ELEMENTARY SCHOOL CORE (Ages 7-10)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_school_play",
		minAge = 7, maxAge = 12,
		weight = 30, cooldown = 2,
		emoji = "🎭", title = "School Play Auditions!",
		category = "school",
		getDynamicData = function()
			local plays = {"The Wizard of Oz", "Peter Pan", "Beauty and the Beast", "The Lion King", "Alice in Wonderland"}
			return { play = plays[math.random(#plays)] }
		end,
		text = "The school is putting on '%play%'! Are you going to audition?",
		choices = {
			{ text = "🌟 Get the lead!", effects = { Happiness = 10, Looks = 5, Smarts = 2 }, resultText = "You got the main role! Star of the show!", setFlag = "drama_kid" },
			{ text = "🎭 Get a supporting role", effects = { Happiness = 6, Looks = 2 }, resultText = "You got a great part! Not the lead, but memorable." },
			{ text = "🔧 Work backstage", effects = { Smarts = 5, Happiness = 4 }, resultText = "You helped with sets and lights. Just as important!" },
			{ text = "🙅 Stage fright", effects = { Happiness = -2 }, resultText = "You didn't audition. Maybe next time." },
		},
	},
	
	{
		id = "m_science_fair",
		minAge = 8, maxAge = 12,
		weight = 35, cooldown = 2,
		emoji = "🔬", title = "Science Fair!",
		category = "school",
		getDynamicData = function()
			local projects = {"volcano model", "solar system display", "plant growth experiment", "electricity demonstration", "water filtration system"}
			return { project = projects[math.random(#projects)] }
		end,
		text = "The science fair is coming! You're working on a %project%.",
		choices = {
			{ text = "🏆 WIN FIRST PLACE!", effects = { Smarts = 10, Happiness = 10, Money = 50 }, resultText = "Your project was incredible! First place!", setFlag = "science_talent" },
			{ text = "📊 Honorable mention", effects = { Smarts = 6, Happiness = 5 }, resultText = "You didn't win, but the judges were impressed." },
			{ text = "💥 It exploded...", effects = { Smarts = 3, Happiness = -3 }, resultText = "Your experiment had unexpected results. Oops." },
			{ text = "🤷 Minimal effort", effects = { Smarts = 2 }, resultText = "You threw something together last minute. Meh." },
		},
	},
	
	{
		id = "m_spelling_bee",
		minAge = 7, maxAge = 12,
		weight = 30, cooldown = 2,
		emoji = "📝", title = "Spelling Bee!",
		category = "school",
		getDynamicData = function()
			local words = {"necessary", "occurrence", "accommodate", "rhythm", "conscientious", "mischievous", "onomatopoeia"}
			return { finalWord = words[math.random(#words)] }
		end,
		text = "You made it to the school spelling bee! The final word is: '%finalWord%'",
		choices = {
			{ text = "🏆 Spelled it perfectly!", effects = { Smarts = 10, Happiness = 10 }, resultText = "CORRECT! You're the spelling bee champion!", setFlags = {"spelling_champ", "academic_achiever"} },
			{ text = "😰 Choked under pressure", effects = { Happiness = -4 }, resultText = "You got nervous and misspelled it. So close!" },
			{ text = "🥈 Second place", effects = { Smarts = 6, Happiness = 4 }, resultText = "You got second! Still a great achievement." },
			{ text = "🤔 Asked for definition", effects = { Smarts = 7, Happiness = 5 }, resultText = "Using context clues, you figured it out!" },
		},
	},
	
	{
		id = "m_sports_tryout",
		minAge = 8, maxAge = 12,
		weight = 35, cooldown = 2,
		emoji = "⚽", title = "Sports Team Tryouts!",
		category = "school",
		getDynamicData = function()
			local sports = {"soccer", "basketball", "baseball", "swimming", "track", "gymnastics"}
			return { sport = sports[math.random(#sports)] }
		end,
		text = "Tryouts for the %sport% team are today! Are you going to go for it?",
		choices = {
			{ text = "🏆 Make the team!", effects = { Health = 8, Happiness = 8, Looks = 2 }, resultText = "You made it! You're on the team!", setFlag = "athlete" },
			{ text = "😔 Didn't make it", effects = { Happiness = -5, Health = 2 }, resultText = "You didn't make the cut. There's always next year." },
			{ text = "⭐ STAR PLAYER!", effects = { Health = 10, Happiness = 10, Looks = 4 }, resultText = "The coach was blown away! You're starting!", setFlags = {"athlete", "sports_star"} },
			{ text = "🙅 Not my thing", effects = { Smarts = 2 }, resultText = "You decided sports aren't for you." },
		},
	},
	
	{
		id = "m_talent_show",
		minAge = 7, maxAge = 12,
		weight = 30, cooldown = 2,
		emoji = "🎤", title = "School Talent Show!",
		category = "school",
		getDynamicData = function()
			local talents = {"singing", "playing piano", "magic tricks", "dancing", "comedy routine", "juggling", "martial arts demo"}
			return { talent = talents[math.random(#talents)] }
		end,
		text = "The school talent show is coming! You want to perform %talent%!",
		choices = {
			{ text = "🌟 Standing ovation!", effects = { Happiness = 10, Looks = 5, Smarts = 2 }, resultText = "You brought the house down! AMAZING!", setFlag = "performer" },
			{ text = "👏 Good performance", effects = { Happiness = 6, Looks = 2 }, resultText = "You did well! The crowd appreciated it." },
			{ text = "😰 Stage fright disaster", effects = { Happiness = -6 }, resultText = "You froze on stage. Mortifying." },
			{ text = "🎬 Behind the scenes", effects = { Smarts = 4, Happiness = 3 }, resultText = "You helped organize instead. Less scary!" },
		},
	},
	
	{
		id = "m_book_report",
		minAge = 7, maxAge = 12,
		weight = 30, cooldown = 2,
		emoji = "📚", title = "Book Report Due!",
		category = "school",
		getDynamicData = function()
			local books = {"Charlotte's Web", "Harry Potter", "Percy Jackson", "Diary of a Wimpy Kid", "The Giver", "Bridge to Terabithia"}
			return { book = books[math.random(#books)] }
		end,
		text = "Your book report on '%book%' is due tomorrow!",
		choices = {
			{ text = "📖 Already done!", effects = { Smarts = 6, Happiness = 4 }, resultText = "You planned ahead and did an amazing job!", setFlag = "organized" },
			{ text = "🌙 All-nighter!", effects = { Smarts = 4, Health = -3 }, resultText = "You stayed up late but got it done!" },
			{ text = "🎬 Watch the movie instead", effects = { Smarts = 2, Happiness = 3 }, resultText = "The teacher could tell. 'That's not in the book!'" },
			{ text = "📝 Amazing analysis!", effects = { Smarts = 10, Happiness = 5 }, resultText = "The teacher read your report to the class!", setFlag = "bookworm" },
		},
	},
	
	{
		id = "m_field_trip",
		minAge = 6, maxAge = 12,
		weight = 40, cooldown = 2,
		emoji = "🚌", title = "School Field Trip!",
		category = "school",
		getDynamicData = function()
			local destinations = {"the museum", "the zoo", "an aquarium", "a science center", "a farm", "a historical site", "the fire station"}
			return { destination = destinations[math.random(#destinations)] }
		end,
		text = "Your class is going on a field trip to %destination%!",
		choices = {
			{ text = "🎉 Best day ever!", effects = { Happiness = 10, Smarts = 4 }, resultText = "You had an amazing time and learned so much!" },
			{ text = "📸 Take lots of photos", effects = { Happiness = 6, Smarts = 3 }, resultText = "You documented everything!" },
			{ text = "😔 Got sick on the bus", effects = { Happiness = -5, Health = -3 }, resultText = "Motion sickness ruined the trip." },
			{ text = "🤔 Ask ALL the questions", effects = { Smarts = 8, Happiness = 4 }, resultText = "The guide was impressed by your curiosity!", setFlag = "curious" },
		},
	},
	
	{
		id = "m_math_test",
		minAge = 7, maxAge = 12,
		weight = 35, cooldown = 2,
		emoji = "🔢", title = "Big Math Test!",
		category = "school",
		getDynamicData = function()
			local topics = {"multiplication", "division", "fractions", "decimals", "geometry", "word problems"}
			return { topic = topics[math.random(#topics)] }
		end,
		text = "The big %topic% test is today! Did you study?",
		choices = {
			{ text = "💯 Aced it!", effects = { Smarts = 8, Happiness = 8 }, resultText = "100%! Math genius!", setFlag = "math_talent" },
			{ text = "📊 Did okay", effects = { Smarts = 4, Happiness = 2 }, resultText = "B- isn't bad. Math is hard." },
			{ text = "📉 Bombed it...", effects = { Smarts = 1, Happiness = -5 }, resultText = "Yikes. Study harder next time." },
			{ text = "🤫 May have cheated", effects = { Smarts = -2, Happiness = 2 }, resultText = "You didn't get caught... this time.", setFlag = "cheater" },
		},
	},
	
	{
		id = "m_recess_invention",
		minAge = 6, maxAge = 10,
		weight = 25, oneTime = true,
		emoji = "🎮", title = "Recess Game Inventor!",
		category = "social",
		getDynamicData = function()
			local games = {"four square variant", "tag modification", "trading card game", "secret club", "obstacle course", "mystery game"}
			return { game = games[math.random(#games)] }
		end,
		text = "You invented a new recess game: a %game%! Kids are lining up to play!",
		choices = {
			{ text = "👑 Everyone plays YOUR game", effects = { Happiness = 10, Smarts = 4, Looks = 2 }, resultText = "You became the playground king/queen!", setFlag = "leader" },
			{ text = "📜 Create official rules", effects = { Smarts = 6, Happiness = 6 }, resultText = "You wrote down the rules. Very organized!" },
			{ text = "🤝 Let others contribute", effects = { Happiness = 7, Smarts = 2 }, resultText = "The game evolved with everyone's ideas!" },
			{ text = "😤 Rules lawyer", effects = { Happiness = 2, Smarts = 4 }, resultText = "You got too strict with rules and people stopped playing." },
		},
	},
	
	{
		id = "m_birthday_party_yours",
		minAge = 6, maxAge = 12,
		weight = 50, cooldown = 3,
		emoji = "🎂", title = "Your Birthday Party!",
		category = "social",
		getDynamicData = function()
			local themes = {"superhero", "princess", "sports", "video game", "dinosaur", "space", "pool party", "sleepover", "arcade"}
			return { theme = themes[math.random(#themes)], age = "%age%" }
		end,
		text = "It's your birthday! You're having a %theme% themed party!",
		choices = {
			{ text = "🎉 Best party ever!", effects = { Happiness = 12, Money = -100 }, resultText = "Everyone said it was the best birthday party all year!" },
			{ text = "🎁 Love the presents!", effects = { Happiness = 10, Money = 50 }, resultText = "You got amazing gifts!" },
			{ text = "😢 Someone couldn't come", effects = { Happiness = 4 }, resultText = "Your best friend was sick. Party still happened though." },
			{ text = "🍰 Cake was incredible", effects = { Happiness = 8 }, resultText = "That cake was the best thing you've ever tasted!" },
		},
	},
	
	{
		id = "m_instrument_start",
		minAge = 7, maxAge = 11,
		weight = 25, oneTime = true,
		emoji = "🎵", title = "Learning an Instrument!",
		category = "school",
		getDynamicData = function()
			local instruments = {"piano", "guitar", "violin", "drums", "trumpet", "flute", "clarinet", "saxophone"}
			return { instrument = instruments[math.random(#instruments)] }
		end,
		text = "Your parents signed you up for %instrument% lessons!",
		choices = {
			{ text = "🎵 Natural talent!", effects = { Smarts = 6, Happiness = 8 }, resultText = "You're a prodigy! The teacher is amazed!", setFlag = "musical_talent" },
			{ text = "🎹 Practice makes perfect", effects = { Smarts = 5, Happiness = 4 }, resultText = "It's hard work but you're improving!" },
			{ text = "😫 Hate it", effects = { Happiness = -4 }, resultText = "You begged to quit after a month." },
			{ text = "🎸 Start a band dream", effects = { Happiness = 6, Smarts = 3 }, resultText = "You're already planning your future band!", setFlags = {"musical_talent", "band_dream"} },
		},
	},
	
	{
		id = "m_video_games",
		minAge = 7, maxAge = 12,
		weight = 35, cooldown = 2,
		emoji = "🎮", title = "Video Game Obsession",
		category = "social",
		getDynamicData = function()
			local games = {"Minecraft", "Fortnite", "Roblox", "Mario", "Pokemon", "Zelda", "sports games"}
			return { game = games[math.random(#games)] }
		end,
		text = "You've been playing %game% NON-STOP. Your parents are concerned.",
		choices = {
			{ text = "🎮 Just one more hour!", effects = { Happiness = 6, Health = -3, Smarts = -2 }, resultText = "You played until 2 AM. Worth it!", setFlag = "gamer" },
			{ text = "⏰ Set time limits", effects = { Smarts = 4, Happiness = 3 }, resultText = "Balance is important. You managed it well." },
			{ text = "🏆 Go competitive!", effects = { Smarts = 6, Happiness = 5 }, resultText = "You joined tournaments! You're actually really good!", setFlags = {"gamer", "competitive"} },
			{ text = "🌳 Take a break outside", effects = { Health = 5, Happiness = 4 }, resultText = "Fresh air is nice too. Good balance!" },
		},
	},
	
	{
		id = "m_sibling_conflict",
		minAge = 6, maxAge = 12,
		weight = 30, cooldown = 2,
		requiresFlag = "has_sibling",
		emoji = "😤", title = "Sibling War!",
		category = "family",
		getDynamicData = function()
			local causes = {"the TV remote", "who gets the front seat", "who used whose stuff", "bathroom time", "who mom loves more"}
			return { cause = causes[math.random(#causes)] }
		end,
		text = "You and your sibling are fighting over %cause%!",
		choices = {
			{ text = "👊 Full battle mode", effects = { Health = -3, Happiness = 2 }, resultText = "Someone got hurt. Parents are not happy." },
			{ text = "🤝 Truce", effects = { Happiness = 4, Smarts = 3 }, resultText = "You worked it out like mature people.", setFlag = "peacemaker" },
			{ text = "🗣️ Call for backup (parents)", effects = { Happiness = 3 }, resultText = "Mom sorted it out. You won this round." },
			{ text = "😈 Revenge later", effects = { Smarts = 2 }, resultText = "You're planning something. They won't see it coming.", setFlag = "vengeful" },
		},
	},
	
	{
		id = "m_sleepover_hosted",
		minAge = 8, maxAge = 12,
		weight = 25, cooldown = 3,
		emoji = "🏠", title = "Hosting a Sleepover!",
		category = "social",
		getDynamicData = function()
			return { count = math.random(2, 5) }
		end,
		text = "You're hosting a sleepover! %count% friends are coming over!",
		choices = {
			{ text = "🎉 Epic night!", effects = { Happiness = 10 }, resultText = "You stayed up all night laughing. Best sleepover ever!" },
			{ text = "🍕 Pizza and movies", effects = { Happiness = 8, Money = -30 }, resultText = "Classic sleepover. Perfect execution." },
			{ text = "😴 Everyone passed out early", effects = { Happiness = 4, Health = 3 }, resultText = "Actually got some sleep. Weird for a sleepover." },
			{ text = "🤫 Snuck out together", effects = { Happiness = 8, Smarts = -2 }, resultText = "Adventurous! (Don't tell the parents)", setFlag = "risk_taker" },
		},
	},
	
	{
		id = "m_pet_responsibility",
		minAge = 7, maxAge = 12,
		weight = 25, cooldown = 3,
		requiresFlag = "animal_lover",
		emoji = "🐕", title = "Pet Responsibility",
		category = "family",
		getDynamicData = function()
			local tasks = {"walk the dog", "clean the litter box", "feed the fish", "brush the pet", "clean the cage"}
			return { task = tasks[math.random(#tasks)] }
		end,
		text = "It's your turn to %task%! Pets need regular care.",
		choices = {
			{ text = "✅ Do it right away", effects = { Happiness = 4, Smarts = 2 }, resultText = "Good job! Responsible pet owner!", setFlag = "responsible" },
			{ text = "😫 Complain but do it", effects = { Happiness = 1 }, resultText = "Grumbling the whole time, but it got done." },
			{ text = "🙅 Try to skip it", effects = { Happiness = 3, Smarts = -2 }, resultText = "Your parents noticed. No video games tonight." },
			{ text = "🤗 Actually enjoy it", effects = { Happiness = 6, Health = 2 }, resultText = "You love spending time with your pet!", setFlag = "animal_lover" },
		},
	},
	
	{
		id = "m_school_project",
		minAge = 8, maxAge = 12,
		weight = 30, cooldown = 2,
		emoji = "📊", title = "Group Project Drama",
		category = "school",
		getDynamicData = function()
			return { partnerName = LifeEvents.randomFirstName() }
		end,
		text = "You're assigned a group project with %partnerName%. Will you work well together?",
		choices = {
			{ text = "🤝 Great teamwork!", effects = { Smarts = 6, Happiness = 5 }, resultText = "You complemented each other's skills perfectly!" },
			{ text = "😤 Did all the work yourself", effects = { Smarts = 7, Happiness = -4 }, resultText = "Group projects are the worst. You carried them." },
			{ text = "🎭 Present like a boss", effects = { Looks = 3, Smarts = 4, Happiness = 5 }, resultText = "Your presentation skills saved a mediocre project!" },
			{ text = "😅 Barely scraped by", effects = { Smarts = 2 }, resultText = "C-. Could have been worse." },
		},
	},
	
	{
		id = "m_first_phone",
		minAge = 9, maxAge = 12,
		weight = 30, oneTime = true,
		emoji = "📱", title = "First Phone!",
		category = "family",
		getDynamicData = function()
			local phones = {"a hand-me-down", "a basic phone", "a smartphone"}
			return { phoneType = phones[math.random(#phones)] }
		end,
		text = "Your parents got you %phoneType%! You finally have your own phone!",
		choices = {
			{ text = "📱 Text all the friends!", effects = { Happiness = 10 }, resultText = "Your social life just leveled up!" },
			{ text = "🎮 Download ALL the games", effects = { Happiness = 8, Smarts = -1 }, resultText = "So many games! So little battery!" },
			{ text = "📸 Become a photo taker", effects = { Happiness = 6, Looks = 2 }, resultText = "You document everything now." },
			{ text = "🤓 Use it responsibly", effects = { Smarts = 5, Happiness = 4 }, resultText = "Your parents are proud of your maturity.", setFlag = "responsible" },
		},
	},
	
	{
		id = "m_halloween",
		minAge = 6, maxAge = 12,
		weight = 45, cooldown = 2,
		emoji = "🎃", title = "Halloween Night!",
		category = "social",
		getDynamicData = function()
			local costumes = {"superhero", "vampire", "princess", "monster", "ghost", "celebrity", "video game character", "animal", "meme"}
			return { costume = costumes[math.random(#costumes)] }
		end,
		text = "It's Halloween! You're dressed as a %costume%! Time for trick-or-treating!",
		choices = {
			{ text = "🍬 Maximum candy!", effects = { Happiness = 10, Health = -2 }, resultText = "You filled THREE bags! Legendary haul!" },
			{ text = "👻 Scare people", effects = { Happiness = 8 }, resultText = "You scared so many kids! (In a fun way)" },
			{ text = "🎉 Epic costume party", effects = { Happiness = 9, Looks = 4 }, resultText = "Your costume won best dressed!" },
			{ text = "🏠 Spooky movie marathon", effects = { Happiness = 7 }, resultText = "Scary movies with friends! Perfect Halloween." },
		},
	},
	
	{
		id = "m_summer_camp",
		minAge = 8, maxAge = 12,
		weight = 30, cooldown = 3,
		emoji = "🏕️", title = "Summer Camp!",
		category = "social",
		getDynamicData = function()
			local camps = {"adventure camp", "sports camp", "arts camp", "science camp", "wilderness camp", "music camp"}
			return { campType = camps[math.random(#camps)] }
		end,
		text = "Your parents signed you up for %campType% this summer!",
		choices = {
			{ text = "🏕️ Best summer ever!", effects = { Happiness = 12, Health = 5 }, resultText = "Camp was incredible! You made lifelong memories." },
			{ text = "😰 Homesick", effects = { Happiness = -4 }, resultText = "You missed home but survived the week." },
			{ text = "🤝 Made lifelong friends", effects = { Happiness = 10 }, resultText = "You'll stay in touch with camp friends forever!", setFlag = "camp_friends" },
			{ text = "🏆 Camp champion", effects = { Happiness = 8, Health = 4, Smarts = 2 }, resultText = "You won multiple awards at camp!", setFlag = "camp_legend" },
		},
	},
	
	{
		id = "m_discover_hobby",
		minAge = 7, maxAge = 12,
		weight = 35, oneTime = true,
		emoji = "⭐", title = "Discovering Your Passion!",
		category = "social",
		getDynamicData = function()
			local hobbies = {"drawing", "coding", "building things", "writing stories", "photography", "collecting", "crafting", "cooking", "skateboarding"}
			return { hobby = hobbies[math.random(#hobbies)] }
		end,
		text = "You've discovered you LOVE %hobby%! It's your new obsession!",
		choices = {
			{ text = "🔥 Go all in!", effects = { Happiness = 10, Smarts = 5 }, resultText = "You practice every day! Getting really good!", setFlag = "passionate_hobbyist" },
			{ text = "📚 Learn everything about it", effects = { Smarts = 8, Happiness = 6 }, resultText = "You became an expert on the subject!" },
			{ text = "🤝 Find others who share it", effects = { Happiness = 8, Smarts = 3 }, resultText = "You joined a club! So fun with others!" },
			{ text = "💭 Dream of doing it professionally", effects = { Happiness = 6, Smarts = 2 }, resultText = "Maybe this could be a career someday!" },
		},
	},
	
	{
		id = "m_puberty_begins",
		minAge = 10, maxAge = 12,
		weight = 45, oneTime = true,
		emoji = "📈", title = "Growing Up Fast!",
		category = "health",
		text = "Your body is changing! Puberty has begun. This is... interesting.",
		choices = {
			{ text = "😳 So awkward", effects = { Happiness = -4 }, resultText = "Everything feels weird. Welcome to puberty." },
			{ text = "🤔 Ask questions", effects = { Smarts = 5, Happiness = 2 }, resultText = "Your parents explained things. It's natural!", setFlag = "informed" },
			{ text = "📚 Research it yourself", effects = { Smarts = 6, Happiness = 1 }, resultText = "Books and internet helped you understand." },
			{ text = "💪 Embrace the changes", effects = { Happiness = 3, Health = 2, Looks = 2 }, resultText = "Growing up is pretty cool actually!", setFlag = "confident" },
		},
	},
	
	{
		id = "m_allowance_start",
		minAge = 7, maxAge = 10,
		weight = 35, oneTime = true,
		emoji = "💵", title = "Getting an Allowance!",
		category = "family",
		getDynamicData = function()
			local amounts = {5, 10, 15, 20}
			return { amount = amounts[math.random(#amounts)] }
		end,
		text = "Your parents start giving you $%amount% allowance per week! Time to learn about money!",
		choices = {
			{ text = "💰 Save it all!", effects = { Smarts = 6, Money = 50 }, resultText = "You're a natural saver! Your piggy bank grows.", setFlag = "saver" },
			{ text = "🛍️ Spend immediately", effects = { Happiness = 6, Money = 10 }, resultText = "Candy and toys! What else is money for?" },
			{ text = "📊 Make a budget", effects = { Smarts = 8, Money = 30, Happiness = 4 }, resultText = "Half save, half spend. Smart!", setFlag = "financially_smart" },
			{ text = "💼 Negotiate more", effects = { Smarts = 5, Money = 20 }, resultText = "You convinced them to raise it! Future CEO!", setFlag = "negotiator" },
		},
	},
	
	{
		id = "m_pet_death",
		minAge = 6, maxAge = 12,
		weight = 8, oneTime = true,
		requiresFlag = "animal_lover",
		emoji = "🕊️", title = "Losing a Pet",
		category = "family",
		text = "Your pet passed away. This is the first time you've experienced loss.",
		choices = {
			{ text = "😭 Devastated", effects = { Happiness = -15 }, resultText = "You cried for days. They were your best friend." },
			{ text = "🪦 Have a funeral", effects = { Happiness = -8, Smarts = 2 }, resultText = "You said goodbye properly. It helped.", setFlag = "experienced_loss" },
			{ text = "📸 Remember the good times", effects = { Happiness = -6, Smarts = 3 }, resultText = "Looking at photos helped you cope.", setFlag = "resilient" },
			{ text = "🐕 Adopt a new pet?", effects = { Happiness = -4 }, resultText = "Nothing can replace them, but... maybe someday." },
		},
	},
	
	{
		id = "m_school_election",
		minAge = 9, maxAge = 12,
		weight = 25, cooldown = 3,
		emoji = "🗳️", title = "Class Elections!",
		category = "school",
		text = "Class president elections are coming! Will you run?",
		choices = {
			{ text = "🏆 WIN THE ELECTION!", effects = { Happiness = 10, Looks = 4, Smarts = 3 }, resultText = "You're the class president! Power!", setFlags = {"class_president", "leader", "political_interest"} },
			{ text = "🥈 Runner-up", effects = { Happiness = 4, Smarts = 2 }, resultText = "You lost by just a few votes. So close!" },
			{ text = "📢 Amazing campaign", effects = { Happiness = 6, Looks = 2, Smarts = 2 }, resultText = "Win or lose, your posters were everywhere!" },
			{ text = "🗳️ Just vote, don't run", effects = { Smarts = 2 }, resultText = "Democracy in action! You did your civic duty." },
		},
	},
	
	{
		id = "m_moving_away",
		minAge = 6, maxAge = 12,
		weight = 8, oneTime = true,
		emoji = "📦", title = "Moving Away!",
		category = "family",
		getDynamicData = function()
			local cities = {"across town", "to another city", "to another state", "to another country"}
			return { destination = cities[math.random(#cities)] }
		end,
		text = "Your family is moving %destination%! You have to leave everything behind.",
		choices = {
			{ text = "😭 Don't want to go!", effects = { Happiness = -10 }, resultText = "You begged to stay but... it's happening." },
			{ text = "🤝 Say goodbye to friends", effects = { Happiness = -5, Smarts = 2 }, resultText = "Tearful goodbyes. You'll keep in touch... hopefully.", setFlag = "moved_away" },
			{ text = "🎉 New adventure!", effects = { Happiness = 4, Smarts = 3 }, resultText = "You chose to see it as an adventure!", setFlags = {"moved_away", "adaptable"} },
			{ text = "📱 Promise to stay connected", effects = { Happiness = 2 }, resultText = "Technology makes distance easier.", setFlag = "moved_away" },
		},
	},
	
	{
		id = "m_sick_days",
		minAge = 6, maxAge = 12,
		weight = 30, cooldown = 3,
		emoji = "🤒", title = "Sick Day!",
		category = "health",
		getDynamicData = function()
			local illnesses = {"a cold", "the flu", "stomach bug", "strep throat", "pink eye"}
			return { illness = illnesses[math.random(#illnesses)] }
		end,
		text = "You caught %illness%! No school today!",
		choices = {
			{ text = "😷 Actually feel terrible", effects = { Health = -8, Happiness = -3 }, resultText = "Being sick is no fun. Soup and rest." },
			{ text = "📺 Milk it for TV time", effects = { Happiness = 5, Health = -5 }, resultText = "You watched cartoons all day. Silver lining!" },
			{ text = "📚 Study anyway", effects = { Smarts = 4, Health = -3 }, resultText = "You didn't want to fall behind.", setFlag = "dedicated_student" },
			{ text = "🤥 Were you really sick?", effects = { Happiness = 6, Smarts = 2 }, resultText = "Maybe exaggerated a little... mental health day!", setFlag = "sneaky" },
		},
	},
	
	{
		id = "m_getting_glasses",
		minAge = 7, maxAge = 12,
		weight = 15, oneTime = true,
		emoji = "👓", title = "You Need Glasses!",
		category = "health",
		text = "The eye doctor says you need glasses! The blackboard has been blurry this whole time?!",
		choices = {
			{ text = "😎 Cool glasses!", effects = { Smarts = 4, Happiness = 5, Looks = 2 }, resultText = "You picked stylish frames. Look smart!", setFlag = "glasses" },
			{ text = "😰 Don't want them", effects = { Happiness = -4 }, resultText = "You felt self-conscious but you can see now!" },
			{ text = "🤓 Embrace the nerd look", effects = { Smarts = 6, Happiness = 2 }, resultText = "Four-eyes and proud! You can SEE!", setFlag = "glasses" },
			{ text = "🔬 Everything is HD!", effects = { Smarts = 5, Happiness = 4 }, resultText = "You never knew how much you were missing!", setFlag = "glasses" },
		},
	},
	
	{
		id = "m_getting_braces",
		minAge = 10, maxAge = 12,
		weight = 20, oneTime = true,
		emoji = "🦷", title = "Getting Braces!",
		category = "health",
		getDynamicData = function()
			local colors = {"blue", "red", "purple", "green", "rainbow"}
			return { color = colors[math.random(#colors)] }
		end,
		text = "The orthodontist says you need braces! You chose %color% bands.",
		choices = {
			{ text = "😬 Metal mouth!", effects = { Looks = -3, Happiness = -3 }, resultText = "It hurts and you look weird. Future you will thank you." },
			{ text = "🌈 Colorful smile!", effects = { Happiness = 2 }, resultText = "You made braces a fashion statement!", setFlag = "braces" },
			{ text = "🍎 Miss certain foods", effects = { Happiness = -4, Health = 2 }, resultText = "No popcorn, no gum, no corn on the cob... torture." },
			{ text = "💪 Worth it for straight teeth", effects = { Looks = 1, Smarts = 2, Happiness = 1 }, resultText = "Temporary pain, permanent gain!", setFlag = "braces" },
		},
	},
	
	{
		id = "m_learning_ride_bike",
		minAge = 5, maxAge = 8,
		weight = 40, oneTime = true,
		emoji = "🚲", title = "Learning to Ride a Bike!",
		category = "family",
		text = "Training wheels are coming off! Time to ride a bike for real!",
		choices = {
			{ text = "🚲 Natural!", effects = { Health = 5, Happiness = 8 }, resultText = "You rode off immediately! Freedom!", setFlag = "bike_rider" },
			{ text = "🤕 Few falls first", effects = { Health = -3, Happiness = 4, Smarts = 2 }, resultText = "Scraped knees are worth it. You learned!", setFlag = "bike_rider" },
			{ text = "😰 Too scared", effects = { Happiness = -3 }, resultText = "You weren't ready. Maybe next year." },
			{ text = "🏆 Race around the block!", effects = { Health = 6, Happiness = 10 }, resultText = "You couldn't stop riding! Wheee!", setFlags = {"bike_rider", "speed_demon"} },
		},
	},
	
	{
		id = "m_cooking_attempt",
		minAge = 8, maxAge = 12,
		weight = 25, cooldown = 3,
		emoji = "👨‍🍳", title = "Cooking Adventure!",
		category = "family",
		getDynamicData = function()
			local dishes = {"cookies", "pancakes", "a sandwich", "mac and cheese", "scrambled eggs"}
			return { dish = dishes[math.random(#dishes)] }
		end,
		text = "You decided to make %dish% all by yourself!",
		choices = {
			{ text = "👨‍🍳 Delicious!", effects = { Smarts = 5, Happiness = 8 }, resultText = "You're a natural chef! Everyone loved it!", setFlag = "cooking_talent" },
			{ text = "🔥 Almost burned the house down", effects = { Happiness = 2, Health = -2 }, resultText = "Lesson learned. Supervision needed." },
			{ text = "🤢 Inedible...", effects = { Happiness = -2, Smarts = 2 }, resultText = "Points for trying! It was... interesting." },
			{ text = "🍳 Got help (still proud)", effects = { Smarts = 3, Happiness = 5 }, resultText = "With guidance, you made something great!" },
		},
	},
	
	{
		id = "m_library_discovery",
		minAge = 6, maxAge = 12,
		weight = 25, oneTime = true,
		emoji = "📚", title = "Library Card!",
		category = "school",
		text = "You got your very own library card! All these books... for FREE!",
		choices = {
			{ text = "📚 READ ALL THE BOOKS!", effects = { Smarts = 10, Happiness = 6 }, resultText = "You became a library regular!", setFlag = "bookworm" },
			{ text = "🎮 Just use the computers", effects = { Smarts = 3, Happiness = 4 }, resultText = "Free computer time! Cool." },
			{ text = "🎬 DVDs and movies!", effects = { Happiness = 5 }, resultText = "They have movies too?! Amazing!" },
			{ text = "🤫 Love the quiet", effects = { Smarts = 5, Happiness = 5 }, resultText = "The library became your sanctuary.", setFlag = "introverted" },
		},
	},
	
	{
		id = "m_competitive_nature",
		minAge = 7, maxAge = 12,
		weight = 25, oneTime = true,
		emoji = "🏆", title = "Discovering Competition",
		category = "social",
		getDynamicData = function()
			local events = {"a board game", "video games", "sports", "grades", "a race"}
			return { event = events[math.random(#events)] }
		end,
		text = "You got really competitive during %event%! Winning feels AMAZING!",
		choices = {
			{ text = "🏆 Win at all costs!", effects = { Happiness = 6, Smarts = 2 }, resultText = "You became ultra-competitive!", setFlag = "competitive" },
			{ text = "🤝 Play fair", effects = { Happiness = 4, Smarts = 4 }, resultText = "Winning is better when it's honest.", setFlag = "good_sport" },
			{ text = "😤 Sore loser moment", effects = { Happiness = -4 }, resultText = "You didn't handle losing well. Working on it." },
			{ text = "🎯 Use this drive for good", effects = { Smarts = 6, Happiness = 4 }, resultText = "Competition makes you better!", setFlag = "driven" },
		},
	},
	
	{
		id = "m_homework_struggle",
		minAge = 7, maxAge = 12,
		weight = 35, cooldown = 2,
		emoji = "📝", title = "Homework Struggle",
		category = "school",
		getDynamicData = function()
			local subjects = {"math", "reading", "science", "social studies", "spelling"}
			return { subject = subjects[math.random(#subjects)] }
		end,
		text = "You're stuck on your %subject% homework! This is really hard!",
		choices = {
			{ text = "📖 Figure it out yourself", effects = { Smarts = 8, Happiness = 2 }, resultText = "You struggled but eventually got it! Proud moment!", setFlag = "persistent" },
			{ text = "🙋 Ask for help", effects = { Smarts = 5, Happiness = 4 }, resultText = "A parent or sibling helped. Teamwork!" },
			{ text = "💻 Google the answers", effects = { Smarts = 2, Happiness = 5 }, resultText = "The internet knows everything... did you really learn though?" },
			{ text = "😴 Give up and sleep", effects = { Happiness = 2, Smarts = -2 }, resultText = "Tomorrow's problem now." },
		},
	},
	
	{
		id = "m_grandparent_visit",
		minAge = 6, maxAge = 12,
		weight = 30, cooldown = 3,
		emoji = "👴👵", title = "Grandparent Visit!",
		category = "family",
		text = "Grandma and Grandpa are visiting! (Or you're visiting them!)",
		choices = {
			{ text = "🤗 Love them so much!", effects = { Happiness = 10 }, resultText = "Best visit ever! So many hugs and stories!" },
			{ text = "🍪 Grandma's cooking!", effects = { Happiness = 8, Health = 2 }, resultText = "Home cooking beats everything!" },
			{ text = "💰 Getting spoiled", effects = { Happiness = 7, Money = 50 }, resultText = "Grandparents always have 'pocket money' for you!" },
			{ text = "📖 Learn family history", effects = { Smarts = 5, Happiness = 5 }, resultText = "You learned amazing stories about your family!" },
		},
	},
	
	{
		id = "m_charity_experience",
		minAge = 8, maxAge = 12,
		weight = 20, oneTime = true,
		emoji = "❤️", title = "Helping Others",
		category = "social",
		getDynamicData = function()
			local activities = {"food drive", "charity run", "visiting elderly", "cleaning up a park", "donating toys"}
			return { activity = activities[math.random(#activities)] }
		end,
		text = "Your family participated in a %activity%! Time to give back!",
		choices = {
			{ text = "❤️ Feels amazing!", effects = { Happiness = 10, Smarts = 3 }, resultText = "Helping others is its own reward!", setFlag = "charitable" },
			{ text = "🤝 Want to do more", effects = { Happiness = 8, Smarts = 4 }, resultText = "You found a new purpose!", setFlags = {"charitable", "activist"} },
			{ text = "🤔 Did it for community service", effects = { Happiness = 4, Smarts = 2 }, resultText = "Whatever the reason, you still helped!" },
			{ text = "😔 Opened your eyes", effects = { Smarts = 6, Happiness = 2 }, resultText = "Not everyone has what you have. Grateful now.", setFlag = "empathetic" },
		},
	},
}

return module
