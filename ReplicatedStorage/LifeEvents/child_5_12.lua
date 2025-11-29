-- LifeEvents/child_5_12.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- CHILDHOOD EVENTS (Ages 5-12)
-- Elementary and Middle School years
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- ELEMENTARY SCHOOL MILESTONES (Age 5-10)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_elementary_start",
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
		id = "m_first_computer",
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
		id = "m_first_book_love",
		minAge = 6, maxAge = 10,
		weight = 40, oneTime = true,
		emoji = "📖", title = "Book Worm!",
		category = "school",
		getDynamicData = function()
			local genres = {"fantasy", "mystery", "science fiction", "adventure", "comedy", "horror"}
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
		id = "m_science_fair",
		minAge = 8, maxAge = 12,
		weight = 35, cooldown = 3,
		emoji = "🔬", title = "Science Fair",
		category = "school",
		getDynamicData = function()
			local projects = {"volcano", "solar system model", "plant growth experiment", "robot", "crystal growing", "electricity demo"}
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
		id = "m_talent_show",
		minAge = 7, maxAge = 12,
		weight = 30, cooldown = 3,
		emoji = "🎤", title = "Talent Show",
		category = "school",
		text = "There's a school talent show! Will you perform?",
		choices = {
			{ text = "🎤 Sing!", effects = { Happiness = 7, Looks = 3 }, resultText = "You wowed the crowd!", setFlag = "performer" },
			{ text = "🎸 Play music", effects = { Happiness = 6, Smarts = 3 }, resultText = "Your musical talent impressed everyone.", setFlag = "musician" },
			{ text = "💃 Dance!", effects = { Happiness = 6, Health = 2, Looks = 2 }, resultText = "Your moves were incredible!", setFlag = "dancer" },
			{ text = "🙅 Too nervous", effects = { Happiness = -3 }, resultText = "Stage fright got you. Maybe next time." },
		},
	},
	
	{
		id = "m_childhood_bully",
		minAge = 7, maxAge = 12,
		weight = 35, cooldown = 3,
		emoji = "😈", title = "Dealing with a Bully",
		category = "school",
		getDynamicData = function()
			return { bullyName = LifeEvents.randomFirstName() }
		end,
		text = "%bullyName% has been picking on you at school.",
		choices = {
			{ text = "🗣️ Tell an adult", effects = { Smarts = 4, Happiness = 3 }, resultText = "The teacher handled it. Good call." },
			{ text = "👊 Stand up to them", effects = { Health = -3, Happiness = 5 }, resultText = "They backed off after you confronted them.", setFlag = "brave" },
			{ text = "🤝 Try to befriend them", effects = { Smarts = 5, Happiness = 4 }, resultText = "Turns out they just needed a friend.", setFlag = "compassionate" },
			{ text = "😔 Suffer in silence", effects = { Happiness = -8 }, resultText = "It was a hard year." },
		},
	},
	
	{
		id = "m_discover_computers",
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
		id = "m_discover_art",
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
		id = "m_sports_team",
		minAge = 7, maxAge = 12,
		weight = 40, oneTime = true,
		emoji = "⚽", title = "Join a Sports Team?",
		category = "school",
		getDynamicData = function()
			local sports = {"soccer", "basketball", "baseball", "swimming", "tennis", "track"}
			return { sport = sports[math.random(#sports)] }
		end,
		text = "You have a chance to join the %sport% team!",
		choices = {
			{ text = "⚽ Join the team!", effects = { Health = 6, Happiness = 5 }, resultText = "You became a %sport% player!", setFlag = "athletic_child" },
			{ text = "🏆 Be the star!", effects = { Health = 8, Happiness = 7, Looks = 2 }, resultText = "You dominated the league!", setFlag = "athletic_star" },
			{ text = "🙅 Not into sports", effects = { Smarts = 2 }, resultText = "Sports aren't for everyone." },
		},
	},
	
	{
		id = "m_spelling_bee",
		minAge = 7, maxAge = 11,
		weight = 25, cooldown = 2,
		emoji = "📝", title = "Spelling Bee",
		category = "school",
		text = "You're competing in the school spelling bee!",
		choices = {
			{ text = "🏆 Win it!", effects = { Smarts = 8, Happiness = 8 }, resultText = "Champion! You spelled every word perfectly!", setFlag = "bookworm" },
			{ text = "😅 Do your best", effects = { Smarts = 4, Happiness = 3 }, resultText = "You made it to the finals!" },
			{ text = "😰 Choke under pressure", effects = { Smarts = 2, Happiness = -3 }, resultText = "Nerves got the best of you." },
		},
	},
	
	{
		id = "m_first_phone",
		minAge = 9, maxAge = 12,
		weight = 40, oneTime = true,
		emoji = "📱", title = "First Phone!",
		category = "family",
		text = "Your parents got you your first phone! Welcome to the digital age.",
		choices = {
			{ text = "📱 Text friends all day", effects = { Happiness = 6 }, resultText = "You're always connected now!" },
			{ text = "📸 Become a content creator", effects = { Happiness = 5, Smarts = 3 }, resultText = "You started making videos.", setFlag = "content_creator" },
			{ text = "🎮 Mobile games!", effects = { Happiness = 4 }, resultText = "So many games to play!" },
		},
	},
	
	{
		id = "m_school_play",
		minAge = 8, maxAge = 12,
		weight = 30, cooldown = 2,
		emoji = "🎭", title = "School Play",
		category = "school",
		getDynamicData = function()
			local plays = {"Peter Pan", "The Wizard of Oz", "A Christmas Carol", "Alice in Wonderland", "The Lion King"}
			return { play = plays[math.random(#plays)] }
		end,
		text = "The school is putting on %play%! Do you audition?",
		choices = {
			{ text = "🌟 Get the lead!", effects = { Happiness = 10, Looks = 3 }, resultText = "You got the starring role! Amazing performance!", setFlag = "performer" },
			{ text = "🎭 Small role is fine", effects = { Happiness = 5 }, resultText = "You had fun and learned a lot." },
			{ text = "🎨 Work backstage", effects = { Smarts = 3, Happiness = 4 }, resultText = "You helped make the magic happen behind the scenes." },
			{ text = "🙅 Not my thing", effects = { Happiness = 1 }, resultText = "Theatre isn't for you." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- SOCIAL LIFE (Age 5-12)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_first_best_friend",
		minAge = 5, maxAge = 10,
		weight = 50, oneTime = true,
		emoji = "👫", title = "Best Friend!",
		category = "social",
		getDynamicData = function()
			return { friendName = LifeEvents.randomFirstName() }
		end,
		text = "You and %friendName% have become best friends!",
		choices = {
			{ text = "🤝 BFFs forever!", effects = { Happiness = 10 }, resultText = "You promised to be friends forever.", setFlag = "has_best_friend" },
			{ text = "🏠 Hang out all the time", effects = { Happiness = 8 }, resultText = "You're inseparable!" },
		},
	},
	
	{
		id = "m_friend_betrayal",
		minAge = 8, maxAge = 12,
		weight = 20, cooldown = 3,
		emoji = "💔", title = "Friend Betrayal",
		category = "social",
		requiresFlag = "has_best_friend",
		getDynamicData = function()
			return { friendName = LifeEvents.randomFirstName() }
		end,
		text = "Your best friend %friendName% spread a rumor about you!",
		choices = {
			{ text = "😭 It hurts so much", effects = { Happiness = -10 }, resultText = "The betrayal really stung. Hard to trust now." },
			{ text = "🗣️ Confront them", effects = { Happiness = -3, Smarts = 3 }, resultText = "You talked it out. They apologized." },
			{ text = "💪 Move on", effects = { Happiness = 2, Smarts = 4 }, resultText = "You learned who your real friends are.", clearFlag = "has_best_friend" },
		},
	},
	
	{
		id = "m_school_crush",
		minAge = 9, maxAge = 12,
		weight = 35, oneTime = true,
		emoji = "💕", title = "First Crush!",
		category = "romance",
		getDynamicData = function()
			return { crushName = LifeEvents.randomFirstName() }
		end,
		text = "You have a crush on %crushName%! Your heart races when you see them.",
		choices = {
			{ text = "😊 Admire from afar", effects = { Happiness = 4 }, resultText = "You dreamed about them but never said anything." },
			{ text = "💌 Write them a note", effects = { Happiness = 6, Smarts = 2 }, resultText = "They thought it was sweet!", setFlag = "romantic" },
			{ text = "😰 Too embarrassed", effects = { Happiness = -2 }, resultText = "You kept it a secret." },
		},
	},
	
	{
		id = "m_class_clown",
		minAge = 7, maxAge = 12,
		weight = 25, oneTime = true,
		emoji = "🤡", title = "Class Clown",
		category = "school",
		text = "You made a joke in class and everyone laughed! Even the teacher smiled.",
		choices = {
			{ text = "🤣 Keep making jokes", effects = { Happiness = 8, Smarts = -2 }, resultText = "You became the class clown! Popular but distracting.", setFlag = "class_clown" },
			{ text = "😊 Just that once", effects = { Happiness = 4 }, resultText = "You enjoyed the moment but stayed focused." },
			{ text = "🎭 Comedy is my calling", effects = { Happiness = 6, Smarts = 3 }, resultText = "You might have a future in entertainment!", setFlag = "comedian" },
		},
	},
	
	{
		id = "m_popularity_contest",
		minAge = 8, maxAge = 12,
		weight = 20, cooldown = 2,
		emoji = "👑", title = "Popularity Contest",
		category = "social",
		text = "You have a chance to join the popular kids' group, but it means ditching your old friends.",
		choices = {
			{ text = "👑 Be popular!", effects = { Happiness = 5, Looks = 3 }, resultText = "You're in the cool crowd now!", setFlag = "popular" },
			{ text = "🤝 Stay loyal", effects = { Happiness = 6, Smarts = 2 }, resultText = "Your real friends matter more.", setFlag = "loyal" },
			{ text = "🌟 Try to have both", effects = { Happiness = 3 }, resultText = "You balanced both friend groups!" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- FAMILY EVENTS (Age 5-12)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_family_vacation",
		minAge = 5, maxAge = 12,
		weight = 30, cooldown = 3,
		emoji = "✈️", title = "Family Vacation!",
		category = "family",
		getDynamicData = function()
			return { destination = LifeEvents.randomCountry() }
		end,
		text = "Your family is going on vacation to %destination%!",
		choices = {
			{ text = "🎉 Best trip ever!", effects = { Happiness = 12, Smarts = 3 }, resultText = "You had amazing experiences and made memories!" },
			{ text = "📸 Take lots of photos", effects = { Happiness = 8 }, resultText = "Your photo album is full of great shots." },
			{ text = "😴 Boring adult stuff", effects = { Happiness = 2 }, resultText = "Museums and history... meh." },
		},
	},
	
	{
		id = "m_parents_divorce",
		minAge = 6, maxAge = 14,
		weight = 8, oneTime = true,
		emoji = "💔", title = "Parents Separating",
		category = "family",
		text = "Your parents told you they're getting divorced. Your world is shaken.",
		choices = {
			{ text = "😭 This is my fault", effects = { Happiness = -15 }, resultText = "It wasn't your fault, but it feels that way." },
			{ text = "💪 Be strong", effects = { Happiness = -8, Smarts = 3 }, resultText = "You tried to hold it together.", setFlag = "parents_divorced" },
			{ text = "😤 Get angry", effects = { Happiness = -10, Health = -3 }, resultText = "You lashed out. It didn't help.", setFlag = "parents_divorced" },
		},
	},
	
	{
		id = "m_new_sibling_older",
		minAge = 5, maxAge = 11,
		weight = 15, oneTime = true,
		blockIfFlag = "has_sibling",
		emoji = "👶", title = "New Baby Sibling!",
		category = "family",
		getDynamicData = function()
			local types = {"brother", "sister"}
			return { sibType = types[math.random(#types)] }
		end,
		text = "Your mom had a baby! You have a new %sibType%!",
		choices = {
			{ text = "🤗 Love them!", effects = { Happiness = 8 }, resultText = "You adore being a big sibling!", setFlag = "has_sibling" },
			{ text = "😤 Less attention now", effects = { Happiness = -5 }, resultText = "You're jealous of the new baby.", setFlag = "has_sibling" },
			{ text = "🍼 Help take care", effects = { Happiness = 5, Smarts = 3 }, resultText = "You're a great big sibling!", setFlag = "has_sibling" },
		},
	},
	
	{
		id = "m_grandparent_death",
		minAge = 7, maxAge = 14,
		weight = 10, oneTime = true,
		emoji = "🕊️", title = "Grandparent Passes Away",
		category = "family",
		getDynamicData = function()
			local relations = {"grandma", "grandpa"}
			return { relation = relations[math.random(#relations)] }
		end,
		text = "Your %relation% passed away. It's your first experience with death.",
		choices = {
			{ text = "😭 Cry and mourn", effects = { Happiness = -12 }, resultText = "You miss them so much." },
			{ text = "❤️ Remember the good times", effects = { Happiness = -5, Smarts = 3 }, resultText = "You cherished the memories.", setFlag = "experienced_loss" },
			{ text = "🤷 Didn't know them well", effects = { Happiness = -3 }, resultText = "You felt sad but distant." },
		},
	},
	
	{
		id = "m_moving_away",
		minAge = 6, maxAge = 12,
		weight = 12, oneTime = true,
		emoji = "📦", title = "Moving Away!",
		category = "family",
		getDynamicData = function()
			return { newCity = LifeEvents.randomCity() }
		end,
		text = "Your family is moving to %newCity%! You have to leave your friends behind.",
		choices = {
			{ text = "😭 Don't want to go!", effects = { Happiness = -10 }, resultText = "You had to leave everything behind." },
			{ text = "🌟 New adventure!", effects = { Happiness = 3, Smarts = 3 }, resultText = "You embraced the change!", setFlag = "adaptable" },
			{ text = "📝 Stay in touch with friends", effects = { Happiness = -2 }, resultText = "You promised to write and call." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- HOBBIES & INTERESTS (Age 5-12)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_music_lessons",
		minAge = 6, maxAge = 12,
		weight = 30, oneTime = true,
		emoji = "🎹", title = "Music Lessons",
		category = "school",
		getDynamicData = function()
			local instruments = {"piano", "guitar", "violin", "drums", "flute"}
			return { instrument = instruments[math.random(#instruments)] }
		end,
		text = "Your parents signed you up for %instrument% lessons!",
		choices = {
			{ text = "🎵 Practice hard!", effects = { Smarts = 5, Happiness = 4 }, resultText = "You're becoming talented!", setFlag = "musician" },
			{ text = "😴 Boring...", effects = { Happiness = -2 }, resultText = "You quit after a few months." },
			{ text = "🌟 Natural talent!", effects = { Smarts = 8, Happiness = 6 }, resultText = "You're a %instrument% prodigy!", setFlag = "music_prodigy" },
		},
	},
	
	{
		id = "m_video_games_obsession",
		minAge = 7, maxAge = 12,
		weight = 35, oneTime = true,
		emoji = "🎮", title = "Gaming Obsession",
		category = "family",
		text = "You're really into video games. Like, REALLY into them.",
		choices = {
			{ text = "🎮 Game all day!", effects = { Happiness = 8, Health = -3, Smarts = -2 }, resultText = "You became a gaming addict.", setFlag = "gamer" },
			{ text = "⚖️ Balance gaming", effects = { Happiness = 5, Smarts = 2 }, resultText = "You game but also do other things." },
			{ text = "🏆 Get competitive", effects = { Happiness = 6, Smarts = 4 }, resultText = "You started competing in tournaments!", setFlag = "esports_interest" },
		},
	},
	
	{
		id = "m_collect_hobby",
		minAge = 7, maxAge = 12,
		weight = 25, oneTime = true,
		emoji = "🃏", title = "Collecting Hobby",
		category = "social",
		getDynamicData = function()
			local items = {"trading cards", "coins", "stamps", "action figures", "rocks", "bugs"}
			return { collection = items[math.random(#items)] }
		end,
		text = "You started collecting %collection%! It's becoming quite a collection.",
		choices = {
			{ text = "🤓 Become an expert", effects = { Smarts = 5, Happiness = 4 }, resultText = "You know everything about %collection%!", setFlag = "collector" },
			{ text = "💰 Rare finds!", effects = { Smarts = 3, Money = 50 }, resultText = "Some of your %collection% are valuable!" },
			{ text = "🤷 Lose interest", effects = { Happiness = 1 }, resultText = "It was fun while it lasted." },
		},
	},
	
	{
		id = "m_summer_camp",
		minAge = 8, maxAge = 12,
		weight = 30, cooldown = 2,
		emoji = "🏕️", title = "Summer Camp",
		category = "social",
		text = "You're going to summer camp! A whole week away from home.",
		choices = {
			{ text = "🎉 Best week ever!", effects = { Happiness = 10, Health = 3 }, resultText = "You made lifelong memories and friends!" },
			{ text = "😰 Homesick", effects = { Happiness = -5 }, resultText = "You missed home the whole time." },
			{ text = "🏆 Camp champion!", effects = { Happiness = 8, Health = 4 }, resultText = "You won all the competitions!", setFlag = "competitive" },
		},
	},
	
	{
		id = "m_bike_riding",
		minAge = 5, maxAge = 8,
		weight = 50, oneTime = true,
		emoji = "🚲", title = "Learning to Ride a Bike",
		category = "family",
		text = "Your parents are teaching you to ride a bike without training wheels!",
		choices = {
			{ text = "🚲 Nail it first try!", effects = { Health = 4, Happiness = 6 }, resultText = "Natural talent! You zoomed away.", setFlag = "athletic_child" },
			{ text = "🤕 Crash a few times", effects = { Health = -2, Happiness = 3 }, resultText = "Some scrapes but you got it eventually." },
			{ text = "😰 Too scared", effects = { Happiness = -3 }, resultText = "You'll try again next year." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- HEALTH EVENTS (Age 5-12)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_childhood_illness",
		minAge = 5, maxAge = 12,
		weight = 20, cooldown = 3,
		emoji = "🤒", title = "Sick Day",
		category = "health",
		getDynamicData = function()
			local illnesses = {"the flu", "chicken pox", "strep throat", "a bad cold", "stomach bug"}
			return { illness = illnesses[math.random(#illnesses)] }
		end,
		text = "You caught %illness%! No school for a few days.",
		choices = {
			{ text = "📺 Watch TV all day", effects = { Health = 2, Happiness = 3 }, resultText = "Being sick has its perks!" },
			{ text = "😴 Sleep it off", effects = { Health = 5 }, resultText = "Rest helped you recover fast." },
			{ text = "😭 Feel miserable", effects = { Health = 2, Happiness = -4 }, resultText = "You just wanted to feel better." },
		},
	},
	
	{
		id = "m_broken_bone",
		minAge = 6, maxAge = 12,
		weight = 15, oneTime = true,
		emoji = "🦴", title = "Broken Bone!",
		category = "health",
		getDynamicData = function()
			local bones = {"arm", "leg", "wrist", "finger"}
			return { bone = bones[math.random(#bones)] }
		end,
		text = "You broke your %bone% on the playground! Ouch!",
		choices = {
			{ text = "💪 Tough it out", effects = { Health = -5, Happiness = 2 }, resultText = "You barely cried! So brave.", setFlag = "brave" },
			{ text = "😭 Cry a lot", effects = { Health = -5, Happiness = -5 }, resultText = "It really hurt!" },
			{ text = "✍️ Get a cool cast", effects = { Health = -4, Happiness = 4 }, resultText = "Everyone signed your cast! Popular!" },
		},
	},
	
	{
		id = "m_dentist_visit",
		minAge = 6, maxAge = 12,
		weight = 25, cooldown = 3,
		emoji = "🦷", title = "Dentist Visit",
		category = "health",
		text = "Time for your dental checkup! You might have cavities...",
		choices = {
			{ text = "🦷 Perfect teeth!", effects = { Health = 3, Happiness = 4 }, resultText = "No cavities! The dentist is proud." },
			{ text = "😬 One cavity", effects = { Health = 1, Happiness = -3 }, resultText = "You need a filling. Lay off the candy." },
			{ text = "😱 Multiple cavities", effects = { Health = -2, Happiness = -6 }, resultText = "Too much sugar! This hurts." },
		},
	},
	
	{
		id = "m_glasses_needed",
		minAge = 6, maxAge = 12,
		weight = 20, oneTime = true,
		emoji = "👓", title = "Need Glasses!",
		category = "health",
		text = "The eye doctor says you need glasses!",
		choices = {
			{ text = "👓 Cool glasses!", effects = { Looks = -2, Smarts = 3, Happiness = 2 }, resultText = "You picked awesome frames!", setFlag = "wears_glasses" },
			{ text = "😤 Don't want them", effects = { Smarts = -2, Happiness = -3 }, resultText = "You refused to wear them. Squinting a lot.", setFlag = "wears_glasses" },
			{ text = "🤓 Embrace the nerd look", effects = { Smarts = 5, Looks = -1 }, resultText = "You own the glasses look!", setFlag = "wears_glasses" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- SCHOOL CHALLENGES (Age 5-12)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_failing_class",
		minAge = 7, maxAge = 12,
		weight = 20, cooldown = 3,
		emoji = "📉", title = "Struggling in Class",
		category = "school",
		getDynamicData = function()
			local subjects = {"math", "reading", "science", "history"}
			return { subject = subjects[math.random(#subjects)] }
		end,
		text = "You're having trouble with %subject%. Your grades are slipping.",
		choices = {
			{ text = "📚 Get tutoring", effects = { Smarts = 5, Happiness = -2, Money = -100 }, resultText = "The tutor helped! Grades improved." },
			{ text = "📖 Study harder", effects = { Smarts = 4, Happiness = -1 }, resultText = "You put in the work and got better." },
			{ text = "🤷 Who cares", effects = { Smarts = -3, Happiness = 2 }, resultText = "Your grades tanked but you don't care." },
		},
	},
	
	{
		id = "m_straight_as",
		minAge = 8, maxAge = 12,
		weight = 25, cooldown = 2,
		emoji = "📈", title = "Straight A's!",
		category = "school",
		requiresFlag = "studious",
		text = "You got straight A's on your report card!",
		choices = {
			{ text = "🎉 Celebrate!", effects = { Happiness = 8, Smarts = 3 }, resultText = "Your parents are so proud!" },
			{ text = "📚 Keep working hard", effects = { Smarts = 5, Happiness = 3 }, resultText = "Education is important to you.", setFlag = "academic_achiever" },
			{ text = "🏆 Brag about it", effects = { Happiness = 5, Smarts = 2 }, resultText = "Everyone knows you're smart now." },
		},
	},
	
	{
		id = "m_cheating_caught",
		minAge = 8, maxAge = 12,
		weight = 10, oneTime = true,
		emoji = "😰", title = "Caught Cheating",
		category = "school",
		text = "You got caught cheating on a test! The teacher is furious.",
		choices = {
			{ text = "😢 So sorry!", effects = { Happiness = -8, Smarts = -3 }, resultText = "You learned your lesson." },
			{ text = "🙅 Deny it", effects = { Happiness = -5, Smarts = -5 }, resultText = "They had proof. Made it worse." },
			{ text = "🤷 Own up to it", effects = { Happiness = -4, Smarts = 2 }, resultText = "You took responsibility. Parents notified." },
		},
	},
	
	{
		id = "m_skipping_school",
		minAge = 10, maxAge = 12,
		weight = 15, oneTime = true,
		emoji = "🏃", title = "Skipping School?",
		category = "school",
		getDynamicData = function()
			return { friendName = LifeEvents.randomFirstName() }
		end,
		text = "%friendName% wants you to skip school and go to the mall!",
		choices = {
			{ text = "🏃 Let's go!", effects = { Happiness = 8, Smarts = -4 }, resultText = "You had fun but got in big trouble!", setFlag = "rebellious" },
			{ text = "🙅 No way", effects = { Happiness = 2, Smarts = 2 }, resultText = "Good call. School matters." },
			{ text = "🤔 Just this once...", effects = { Happiness = 5, Smarts = -2 }, resultText = "You didn't get caught! Lucky!" },
		},
	},
}

return module
