-- LifeEvents/child_0_5.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- EARLY CHILDHOOD EVENTS (Ages 0-5)
-- Infant, Toddler, and Preschool years
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- BIRTH & FIRST YEAR (Age 0-1)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_birth",
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
		id = "m_first_smile",
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
		id = "m_first_crawl",
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
		id = "m_first_word",
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
		id = "m_first_steps",
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
		id = "m_first_birthday",
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
		id = "m_baby_sick",
		minAge = 0, maxAge = 2,
		weight = 25, cooldown = 2,
		emoji = "🤒", title = "Baby Gets Sick",
		category = "health",
		text = "You caught a cold! Your parents are worried.",
		choices = {
			{ text = "😴 Rest lots", effects = { Health = 2, Happiness = -2 }, resultText = "You recovered quickly with lots of sleep." },
			{ text = "😭 Be fussy", effects = { Health = 1, Happiness = -3 }, resultText = "You were miserable but got through it." },
		},
	},
	
	{
		id = "m_baby_laugh",
		minAge = 0, maxAge = 1,
		weight = 40, oneTime = true,
		emoji = "😂", title = "First Laugh!",
		category = "family",
		text = "Something made you laugh for the first time! Your giggle is infectious!",
		choices = {
			{ text = "😂 Keep laughing!", effects = { Happiness = 8 }, resultText = "Your laugh became your parents' favorite sound." },
			{ text = "🤭 Shy giggle", effects = { Happiness = 5, Looks = 3 }, resultText = "Your cute little giggle melted hearts." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- TODDLER YEARS (Age 2-4)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_baby_tantrum",
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
		id = "m_baby_sibling",
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
	
	{
		id = "m_potty_training",
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
		id = "m_imaginary_friend",
		minAge = 3, maxAge = 5,
		weight = 35, oneTime = true,
		emoji = "👻", title = "Imaginary Friend",
		category = "social",
		getDynamicData = function()
			local names = {"Mr. Whiskers", "Sparkle", "Captain Thunder", "Princess Luna", "Dino", "Flopsy", "Sir Woofs", "Rainbow"}
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
		id = "m_terrible_twos",
		minAge = 2, maxAge = 2,
		weight = 70, oneTime = true,
		emoji = "😈", title = "The Terrible Twos",
		category = "family",
		text = "You've entered the 'terrible twos' phase. Everything is 'NO!'",
		choices = {
			{ text = "🙅 NO NO NO!", effects = { Happiness = 3, Smarts = 2 }, resultText = "You asserted your independence loudly.", setFlag = "strong_willed" },
			{ text = "😇 Actually be sweet", effects = { Happiness = 5, Looks = 3 }, resultText = "You skipped the terrible twos entirely! Parents are relieved." },
			{ text = "🤔 Why should I?", effects = { Smarts = 5 }, resultText = "You questioned everything. Annoying but smart.", setFlag = "curious" },
		},
	},
	
	{
		id = "m_first_pet_encounter",
		minAge = 2, maxAge = 6,
		weight = 35, oneTime = true,
		emoji = "🐕", title = "Meeting a Pet",
		category = "family",
		getDynamicData = function()
			local pets = {"dog", "cat", "hamster", "goldfish", "bunny", "bird"}
			return { petType = pets[math.random(#pets)] }
		end,
		text = "Your family got a pet %petType%!",
		choices = {
			{ text = "🤗 Love it!", effects = { Happiness = 8 }, resultText = "You and your pet are inseparable!", setFlag = "animal_lover" },
			{ text = "😨 Scared of it", effects = { Happiness = -3 }, resultText = "Pets aren't for everyone." },
			{ text = "🔬 Study it", effects = { Smarts = 4, Happiness = 3 }, resultText = "You're fascinated by animals!", setFlag = "science_interest" },
		},
	},
	
	{
		id = "m_daycare_start",
		minAge = 2, maxAge = 3,
		weight = 50, oneTime = true,
		emoji = "🏠", title = "Starting Daycare",
		category = "social",
		text = "Your parents enrolled you in daycare! Time to socialize with other kids.",
		choices = {
			{ text = "🎉 Make friends!", effects = { Happiness = 6, Smarts = 2 }, resultText = "You made your first friends!", setFlag = "social_butterfly" },
			{ text = "😭 Miss mommy/daddy", effects = { Happiness = -4 }, resultText = "You had separation anxiety but got through it." },
			{ text = "🧸 Play alone", effects = { Smarts = 3, Happiness = 2 }, resultText = "You're comfortable doing your own thing." },
		},
	},
	
	{
		id = "m_playground_fall",
		minAge = 2, maxAge = 5,
		weight = 30, cooldown = 2,
		emoji = "🤕", title = "Playground Accident",
		category = "health",
		text = "You fell off the playground equipment and scraped your knee!",
		choices = {
			{ text = "😭 Cry!", effects = { Health = -3, Happiness = -3 }, resultText = "Ouch! But you got lots of sympathy." },
			{ text = "💪 Be brave", effects = { Health = -2, Happiness = 2 }, resultText = "You barely cried! So tough!", setFlag = "brave" },
			{ text = "🏥 Need a bandaid", effects = { Health = -2 }, resultText = "A bandaid with cartoon characters made it better." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- PRESCHOOL YEARS (Age 4-5)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_preschool_start",
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
		id = "m_playground_incident",
		minAge = 3, maxAge = 6,
		weight = 40, cooldown = 2,
		emoji = "🛝", title = "Playground Drama",
		category = "social",
		getDynamicData = function()
			return { kidName = LifeEvents.randomFirstName() }
		end,
		text = "Another kid named %kidName% pushed you on the playground!",
		choices = {
			{ text = "👊 Push back", effects = { Health = -2, Happiness = 2 }, resultText = "You stood your ground. They won't mess with you again.", setFlag = "fights_back" },
			{ text = "😭 Cry for help", effects = { Happiness = -3 }, resultText = "An adult intervened. You felt protected." },
			{ text = "🗣️ Talk it out", effects = { Smarts = 4, Happiness = 2 }, resultText = "You resolved it maturely. Impressive for your age!" },
		},
	},
	
	{
		id = "m_first_drawing",
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
		id = "m_learn_colors",
		minAge = 2, maxAge = 4,
		weight = 40, oneTime = true,
		emoji = "🌈", title = "Learning Colors!",
		category = "school",
		text = "You're learning to identify colors! What's your favorite?",
		choices = {
			{ text = "🔴 Red!", effects = { Smarts = 3, Happiness = 3 }, resultText = "Red is bold and brave, just like you!" },
			{ text = "💙 Blue!", effects = { Smarts = 3, Happiness = 3 }, resultText = "Blue is calm and cool!" },
			{ text = "🌈 ALL OF THEM!", effects = { Smarts = 5, Happiness = 4 }, resultText = "You love every color! Creative!", setFlag = "creative_mind" },
		},
	},
	
	{
		id = "m_learn_abc",
		minAge = 3, maxAge = 5,
		weight = 50, oneTime = true,
		emoji = "📚", title = "Learning the ABCs",
		category = "school",
		text = "You're learning the alphabet! A, B, C, D, E, F, G...",
		choices = {
			{ text = "🎵 Sing the song!", effects = { Smarts = 4, Happiness = 5 }, resultText = "Now you know your ABCs, next time won't you sing with me!" },
			{ text = "📖 Practice writing", effects = { Smarts = 6, Happiness = 2 }, resultText = "You're ahead of the curve!", setFlag = "early_reader" },
			{ text = "🤷 Letters are boring", effects = { Smarts = 2 }, resultText = "You'll learn eventually." },
		},
	},
	
	{
		id = "m_counting",
		minAge = 3, maxAge = 5,
		weight = 45, oneTime = true,
		emoji = "🔢", title = "Learning to Count",
		category = "school",
		text = "1, 2, 3, 4, 5... You're learning numbers!",
		choices = {
			{ text = "🔢 Count to 100!", effects = { Smarts = 6, Happiness = 3 }, resultText = "You're a counting champion!", setFlag = "math_talent" },
			{ text = "🧮 Count on fingers", effects = { Smarts = 4, Happiness = 4 }, resultText = "Hands are great calculators!" },
			{ text = "🤔 Why do we count?", effects = { Smarts = 5 }, resultText = "You ask the deep questions.", setFlag = "curious" },
		},
	},
	
	{
		id = "m_sharing_lesson",
		minAge = 3, maxAge = 5,
		weight = 35, cooldown = 2,
		emoji = "🤝", title = "Learning to Share",
		category = "social",
		getDynamicData = function()
			local toys = {"favorite toy", "cookies", "crayons", "playdough"}
			return { item = toys[math.random(#toys)] }
		end,
		text = "Another child wants your %item%. Will you share?",
		choices = {
			{ text = "🤝 Share nicely", effects = { Happiness = 4, Smarts = 2 }, resultText = "Sharing is caring! You made a friend.", setFlag = "generous" },
			{ text = "🙅 MINE!", effects = { Happiness = 2, Smarts = -1 }, resultText = "You kept your stuff. Selfish but honest." },
			{ text = "🤔 Trade instead", effects = { Smarts = 5, Happiness = 3 }, resultText = "You negotiated a fair trade! Smart!", setFlag = "negotiator" },
		},
	},
	
	{
		id = "m_naptime_rebellion",
		minAge = 2, maxAge = 4,
		weight = 30, cooldown = 2,
		emoji = "😴", title = "Naptime Rebellion",
		category = "family",
		text = "It's naptime but you're NOT tired!",
		choices = {
			{ text = "😴 Fine, I'll sleep", effects = { Health = 3, Happiness = -1 }, resultText = "You actually were tired. Good rest!" },
			{ text = "🙅 Refuse to nap!", effects = { Happiness = 3, Health = -2 }, resultText = "You stayed up! (And got cranky later)", setFlag = "stubborn" },
			{ text = "🤫 Pretend to sleep", effects = { Smarts = 4, Happiness = 2 }, resultText = "You fooled them! Sneaky.", setFlag = "sneaky" },
		},
	},
	
	{
		id = "m_make_believe",
		minAge = 3, maxAge = 6,
		weight = 35, cooldown = 3,
		emoji = "👑", title = "Make Believe!",
		category = "social",
		getDynamicData = function()
			local roles = {"superhero", "princess/prince", "dinosaur", "astronaut", "doctor", "pirate"}
			return { role = roles[math.random(#roles)] }
		end,
		text = "You're playing make-believe! Today you're a %role%!",
		choices = {
			{ text = "🦸 Be the hero!", effects = { Happiness = 6, Smarts = 3 }, resultText = "You saved the day (in your imagination)!", setFlag = "imaginative" },
			{ text = "🎭 Get really into it", effects = { Smarts = 4, Happiness = 5, Looks = 2 }, resultText = "Your performance was Oscar-worthy!" },
			{ text = "👥 Include others", effects = { Happiness = 4, Smarts = 2 }, resultText = "You made the game fun for everyone!" },
		},
	},
	
	{
		id = "m_picky_eater",
		minAge = 2, maxAge = 5,
		weight = 30, cooldown = 2,
		emoji = "🥦", title = "Picky Eater",
		category = "health",
		getDynamicData = function()
			local foods = {"broccoli", "spinach", "carrots", "peas", "beans"}
			return { food = foods[math.random(#foods)] }
		end,
		text = "Your parents want you to eat %food%. It looks gross!",
		choices = {
			{ text = "🤢 Refuse!", effects = { Happiness = 2, Health = -2 }, resultText = "No veggies for you! (Not great for health)" },
			{ text = "😤 Eat it grudgingly", effects = { Health = 4, Happiness = -1 }, resultText = "It wasn't THAT bad..." },
			{ text = "🤔 Actually tastes good!", effects = { Health = 5, Happiness = 3 }, resultText = "Hey, %food% is pretty good!", setFlag = "healthy_eater" },
		},
	},
	
	{
		id = "m_teeth_care",
		minAge = 2, maxAge = 5,
		weight = 25, oneTime = true,
		emoji = "🦷", title = "Brushing Teeth",
		category = "health",
		text = "Time to brush your teeth! You're learning to do it yourself.",
		choices = {
			{ text = "✨ Brush really well!", effects = { Health = 3, Smarts = 2 }, resultText = "Sparkling teeth! Dentist will be proud." },
			{ text = "😬 Hate brushing", effects = { Health = 1, Happiness = -1 }, resultText = "You did the minimum. Teeth are okay." },
			{ text = "🎵 Make it fun!", effects = { Happiness = 3, Health = 2 }, resultText = "You sing while brushing! Makes it fun." },
		},
	},
	
	{
		id = "m_fear_dark",
		minAge = 2, maxAge = 6,
		weight = 30, cooldown = 3,
		emoji = "🌙", title = "Fear of the Dark",
		category = "family",
		text = "You're scared of the dark! There might be monsters under the bed!",
		choices = {
			{ text = "😱 Need a nightlight", effects = { Happiness = 2 }, resultText = "The nightlight helps. Much better!" },
			{ text = "💪 Face your fear", effects = { Happiness = 5, Smarts = 2 }, resultText = "You were brave! No monsters after all.", setFlag = "brave" },
			{ text = "🧸 Hug a teddy", effects = { Happiness = 4 }, resultText = "Teddy protects you from the monsters!" },
		},
	},
	
	{
		id = "m_birthday_party",
		minAge = 3, maxAge = 5,
		weight = 40, cooldown = 2,
		emoji = "🎈", title = "Birthday Party!",
		category = "social",
		getDynamicData = function()
			return { kidName = LifeEvents.randomFirstName() }
		end,
		text = "You're invited to %kidName%'s birthday party!",
		choices = {
			{ text = "🎉 Party time!", effects = { Happiness = 8 }, resultText = "Best party ever! Cake, games, and presents!" },
			{ text = "🎁 Give a great gift", effects = { Happiness = 5, Money = -20 }, resultText = "Your gift was the best! You're a good friend." },
			{ text = "😰 Too shy to go", effects = { Happiness = -3 }, resultText = "You missed out. Maybe next time." },
		},
	},
	
	{
		id = "m_first_sleepover",
		minAge = 4, maxAge = 6,
		weight = 30, oneTime = true,
		emoji = "🏠", title = "First Sleepover!",
		category = "social",
		getDynamicData = function()
			return { friendName = LifeEvents.randomFirstName() }
		end,
		text = "You're invited to your first sleepover at %friendName%'s house!",
		choices = {
			{ text = "🎉 So excited!", effects = { Happiness = 8, Smarts = 2 }, resultText = "Best night ever! You stayed up late and had so much fun!" },
			{ text = "😰 Homesick...", effects = { Happiness = -2 }, resultText = "You called home crying. Parents came to pick you up." },
			{ text = "😴 Fall asleep early", effects = { Happiness = 3, Health = 2 }, resultText = "You slept great! The other kids drew on your face though." },
		},
	},
	
	{
		id = "m_lost_toy",
		minAge = 2, maxAge = 5,
		weight = 25, cooldown = 3,
		emoji = "🧸", title = "Lost Toy",
		category = "family",
		getDynamicData = function()
			local toys = {"teddy bear", "blankie", "favorite car", "doll", "action figure"}
			return { toy = toys[math.random(#toys)] }
		end,
		text = "Oh no! You can't find your %toy%! It's missing!",
		choices = {
			{ text = "😭 Cry a lot", effects = { Happiness = -6 }, resultText = "You're devastated. It was your favorite!" },
			{ text = "🔍 Search everywhere", effects = { Happiness = 3, Smarts = 3 }, resultText = "You found it! Under the couch. Phew!" },
			{ text = "🤷 Move on", effects = { Smarts = 2, Happiness = -1 }, resultText = "You learned to let go. Very mature for your age." },
		},
	},
	
	{
		id = "m_parent_fight",
		minAge = 3, maxAge = 5,
		weight = 15, oneTime = true,
		emoji = "😢", title = "Parents Fighting",
		category = "family",
		text = "You heard your parents arguing. It scared you.",
		choices = {
			{ text = "😢 Hide and cry", effects = { Happiness = -8 }, resultText = "It was scary. You just wanted them to stop." },
			{ text = "🤗 Hug them both", effects = { Happiness = 3, Smarts = 2 }, resultText = "Your hug reminded them what's important." },
			{ text = "🙈 Pretend it's okay", effects = { Happiness = -3, Smarts = 2 }, resultText = "You learned to cope by ignoring problems." },
		},
	},
	
}

return module
