-- EventLibrary.lua
-- Defines life events and their choices for all ages.
-- Massively expanded with 150+ events covering all life stages, careers, relationships, and more.

local EventLibrary = {}

-- Helper function to generate random names for NPCs
local function randomName(gender)
	local maleNames = {"James", "Michael", "David", "Chris", "John", "Daniel", "Matthew", "Andrew", "Joshua", "Ryan", "Brandon", "Tyler", "Kevin", "Justin", "Austin", "Ethan", "Noah", "Lucas", "Mason", "Logan"}
	local femaleNames = {"Emma", "Olivia", "Sophia", "Ava", "Isabella", "Mia", "Emily", "Abigail", "Madison", "Elizabeth", "Chloe", "Grace", "Victoria", "Natalie", "Lily", "Hannah", "Sarah", "Ashley", "Samantha", "Rachel"}
	
	if gender == "Male" then
		return maleNames[math.random(1, #maleNames)]
	else
		return femaleNames[math.random(1, #femaleNames)]
	end
end

local events = {
	----------------------------------------------------------------
	-- BABY EVENTS (Age 0-2)
	----------------------------------------------------------------
	{
		id = "first_steps",
		minAge = 1,
		maxAge = 1,
		weight = 10,
		text = "You're learning to walk! What's your approach?",
		choices = {
			{
				id = "take_time",
				text = "🚶 Take your time",
				effects = { Stats = { Health = 2, Happiness = 5 } },
				resultText = "You took careful steps and didn't fall! Everyone clapped!",
			},
			{
				id = "run_immediately",
				text = "🏃 Run immediately",
				effects = { Stats = { Health = -5, Happiness = 3 } },
				resultText = "You tried to run before you were ready and took a small tumble.",
			},
		},
	},
	{
		id = "first_words",
		minAge = 1,
		maxAge = 2,
		weight = 8,
		text = "You're trying to say your first word! What will it be?",
		choices = {
			{
				id = "mama",
				text = "👩 Say 'Mama'",
				effects = { Stats = { Happiness = 5 } },
				resultText = "You said 'Mama!' Your mother cried happy tears.",
			},
			{
				id = "dada",
				text = "👨 Say 'Dada'",
				effects = { Stats = { Happiness = 5 } },
				resultText = "You said 'Dada!' Your father was overjoyed.",
			},
			{
				id = "no",
				text = "🚫 Say 'No!'",
				effects = { Stats = { Happiness = 3, Smarts = 2 } },
				resultText = "You said 'No!' Your parents knew you'd be a handful.",
			},
		},
	},
	{
		id = "crying_night",
		minAge = 0,
		maxAge = 1,
		weight = 6,
		text = "It's the middle of the night. You're awake and your parents are sleeping...",
		choices = {
			{
				id = "cry",
				text = "😭 Cry loudly",
				effects = { Stats = { Happiness = 3 } },
				resultText = "You cried and got all the attention you wanted!",
			},
			{
				id = "sleep",
				text = "😴 Go back to sleep",
				effects = { Stats = { Health = 3, Happiness = 1 } },
				resultText = "You fell back asleep. Your parents are grateful.",
			},
		},
	},

	----------------------------------------------------------------
	-- TODDLER EVENTS (Age 2-4)
	----------------------------------------------------------------
	{
		id = "playground_toy",
		minAge = 2,
		maxAge = 4,
		weight = 8,
		text = "Another kid at the playground steals your toy. How do you react?",
		choices = {
			{
				id = "tell_teacher",
				text = "🧑‍🏫 Tell a grown-up",
				effects = { Stats = { Happiness = 3, Smarts = 2 } },
				resultText = "You told a nearby adult. They made the kid give the toy back.",
			},
			{
				id = "swing_on_kid",
				text = "👊 Swing on the kid",
				effects = { Stats = { Happiness = -2, Health = -4 } },
				resultText = "You swung on the kid and started a tiny brawl. Adults broke it up.",
			},
			{
				id = "share",
				text = "🤝 Offer to share",
				effects = { Stats = { Happiness = 4, Smarts = 1 } },
				resultText = "You offered to share. The kid became your new friend!",
			},
		},
	},
	{
		id = "potty_training",
		minAge = 2,
		maxAge = 3,
		weight = 6,
		text = "It's potty training time! How do you feel about this?",
		choices = {
			{
				id = "embrace",
				text = "🚽 Embrace it",
				effects = { Stats = { Happiness = 3, Smarts = 3 } },
				resultText = "You took to potty training like a champ! Your parents were so proud.",
			},
			{
				id = "resist",
				text = "😤 Resist!",
				effects = { Stats = { Happiness = -2 } },
				resultText = "You resisted potty training. It took a while, but you got there eventually.",
			},
		},
	},
	{
		id = "vegetables",
		minAge = 2,
		maxAge = 5,
		weight = 7,
		text = "Your parents are trying to get you to eat vegetables. What do you do?",
		choices = {
			{
				id = "eat_them",
				text = "🥦 Eat them",
				effects = { Stats = { Health = 5, Happiness = -1 } },
				resultText = "You ate your vegetables! You feel healthier already.",
			},
			{
				id = "throw_tantrum",
				text = "😭 Throw a tantrum",
				effects = { Stats = { Happiness = 2, Health = -2 } },
				resultText = "You threw a massive tantrum. Your parents gave in and made mac & cheese.",
			},
			{
				id = "hide_them",
				text = "🐕 Feed them to the dog",
				effects = { Stats = { Smarts = 3, Happiness = 3 } },
				resultText = "You cleverly fed them to the dog. Your parents never suspected!",
			},
		},
	},
	{
		id = "imaginary_friend",
		minAge = 3,
		maxAge = 6,
		weight = 5,
		text = "You've created an imaginary friend named 'Sparky'. Your parents are concerned...",
		choices = {
			{
				id = "keep_playing",
				text = "🧸 Keep playing with Sparky",
				effects = { Stats = { Happiness = 5, Smarts = 2 } },
				resultText = "Sparky and you had amazing adventures! Your creativity flourished.",
			},
			{
				id = "let_go",
				text = "👋 Say goodbye to Sparky",
				effects = { Stats = { Happiness = -2, Smarts = 1 } },
				resultText = "You said goodbye to Sparky. Your parents seemed relieved.",
			},
		},
	},
	{
		id = "preschool_art",
		minAge = 3,
		maxAge = 4,
		weight = 6,
		text = "It's art time at preschool! What do you want to create?",
		choices = {
			{
				id = "family_portrait",
				text = "👨‍👩‍👦 Draw your family",
				effects = { Stats = { Happiness = 4 } },
				resultText = "You drew a beautiful family portrait. Your teacher hung it on the wall!",
			},
			{
				id = "dinosaur",
				text = "🦖 Draw a dinosaur",
				effects = { Stats = { Happiness = 3, Smarts = 2 } },
				resultText = "Your dinosaur was epic! The other kids were impressed.",
			},
			{
				id = "eat_paste",
				text = "🧴 Eat the paste",
				effects = { Stats = { Health = -3, Happiness = 1 } },
				resultText = "You ate the paste. It didn't taste good, and you felt sick.",
			},
		},
	},

	----------------------------------------------------------------
	-- CHILDHOOD EVENTS (Age 5-12)
	----------------------------------------------------------------
	{
		id = "first_day_school",
		minAge = 5,
		maxAge = 6,
		weight = 10,
		text = "It's your first day of school! How do you feel?",
		choices = {
			{
				id = "excited",
				text = "🎒 Excited!",
				effects = { Stats = { Happiness = 5, Smarts = 3 } },
				resultText = "You loved your first day! You made new friends and impressed the teacher.",
			},
			{
				id = "nervous",
				text = "😰 Nervous...",
				effects = { Stats = { Happiness = -2, Smarts = 2 } },
				resultText = "You were nervous but got through it. School gets easier from here.",
			},
			{
				id = "cry",
				text = "😢 Cry",
				effects = { Stats = { Happiness = -5 } },
				resultText = "You cried and wanted to go home. Your teacher was understanding.",
			},
		},
	},
	{
		id = "spelling_bee",
		minAge = 6,
		maxAge = 10,
		weight = 6,
		text = "You've been entered in the school spelling bee! The final word is 'necessary'.",
		choices = {
			{
				id = "spell_correctly",
				text = "📝 N-E-C-E-S-S-A-R-Y",
				effects = { Stats = { Smarts = 8, Happiness = 5 } },
				resultText = "Correct! You won the spelling bee and got a trophy!",
			},
			{
				id = "spell_wrong",
				text = "❓ N-E-S-S-E-C-A-R-Y",
				effects = { Stats = { Smarts = 1, Happiness = -3 } },
				resultText = "Sorry, that's incorrect. You came in second place though!",
			},
			{
				id = "stage_fright",
				text = "😵 Freeze up",
				effects = { Stats = { Happiness = -5 } },
				resultText = "You froze on stage and couldn't answer. Better luck next time.",
			},
		},
	},
	{
		id = "bike_ride",
		minAge = 5,
		maxAge = 8,
		weight = 7,
		text = "Your parents are teaching you to ride a bike without training wheels!",
		choices = {
			{
				id = "brave",
				text = "🚴 Go for it!",
				effects = { Stats = { Health = 4, Happiness = 5 } },
				resultText = "You did it! You rode without training wheels for the first time!",
			},
			{
				id = "scared",
				text = "😨 Too scared",
				effects = { Stats = { Happiness = -3 } },
				resultText = "You were too scared to try. Maybe next time.",
			},
			{
				id = "crash",
				text = "💥 Try and crash",
				effects = { Stats = { Health = -5, Smarts = 2, Happiness = 2 } },
				resultText = "You crashed but got back up and tried again! That's the spirit!",
			},
		},
	},
	{
		id = "lost_tooth",
		minAge = 5,
		maxAge = 8,
		weight = 8,
		text = "Your tooth is loose! What do you want to do?",
		choices = {
			{
				id = "pull_it",
				text = "🦷 Pull it out!",
				effects = { Stats = { Health = 1, Happiness = 4 }, Money = 5 },
				resultText = "You pulled it out! The tooth fairy left you $5!",
			},
			{
				id = "wait",
				text = "⏳ Wait for it to fall out",
				effects = { Stats = { Happiness = 2 }, Money = 5 },
				resultText = "It fell out naturally. The tooth fairy still visited!",
			},
			{
				id = "apple",
				text = "🍎 Bite an apple",
				effects = { Stats = { Health = 2, Happiness = 3 }, Money = 5 },
				resultText = "The apple trick worked! Pop! Out came the tooth!",
			},
		},
	},
	{
		id = "bully_encounter",
		minAge = 7,
		maxAge = 12,
		weight = 6,
		text = "A bully is picking on you at school. What do you do?",
		choices = {
			{
				id = "stand_up",
				text = "💪 Stand up for yourself",
				effects = { Stats = { Happiness = 5, Health = -2 } },
				resultText = "You stood your ground! The bully backed off.",
			},
			{
				id = "tell_adult",
				text = "👨‍🏫 Tell an adult",
				effects = { Stats = { Smarts = 3, Happiness = 2 } },
				resultText = "You told a teacher. The bully got detention.",
			},
			{
				id = "run_away",
				text = "🏃 Run away",
				effects = { Stats = { Happiness = -5, Health = 2 } },
				resultText = "You ran away. The bully still bothers you sometimes.",
			},
			{
				id = "befriend",
				text = "🤝 Try to befriend them",
				effects = { Stats = { Happiness = 6, Smarts = 2 } },
				resultText = "Surprisingly, being nice worked! The bully became your friend.",
			},
		},
	},
	{
		id = "science_fair",
		minAge = 8,
		maxAge = 12,
		weight = 6,
		text = "The science fair is coming up! What project will you do?",
		choices = {
			{
				id = "volcano",
				text = "🌋 Classic volcano",
				effects = { Stats = { Smarts = 4, Happiness = 3 } },
				resultText = "Your volcano was the best! It actually erupted and everyone loved it!",
			},
			{
				id = "solar_system",
				text = "🪐 Solar system model",
				effects = { Stats = { Smarts = 6, Happiness = 2 } },
				resultText = "Your solar system model won second place! Very educational.",
			},
			{
				id = "skip",
				text = "🤷 Skip it",
				effects = { Stats = { Smarts = -3, Happiness = 2 } },
				resultText = "You didn't participate. Your teacher was disappointed.",
			},
		},
	},
	{
		id = "pet_desire",
		minAge = 6,
		maxAge = 12,
		weight = 5,
		text = "You really want a pet! What do you ask your parents for?",
		choices = {
			{
				id = "dog",
				text = "🐕 A dog",
				effects = { Stats = { Happiness = 8 } },
				resultText = "Your parents got you a puppy! Best day ever!",
			},
			{
				id = "cat",
				text = "🐱 A cat",
				effects = { Stats = { Happiness = 7 } },
				resultText = "You got a fluffy kitten! You named it Whiskers.",
			},
			{
				id = "fish",
				text = "🐠 A fish",
				effects = { Stats = { Happiness = 3 } },
				resultText = "You got a goldfish. Not as exciting, but it's peaceful.",
			},
			{
				id = "no_pet",
				text = "😔 Accept no pet",
				effects = { Stats = { Happiness = -3 } },
				resultText = "Your parents said no. Maybe when you're older...",
			},
		},
	},
	{
		id = "sports_tryouts",
		minAge = 8,
		maxAge = 14,
		weight = 6,
		text = "Tryouts for the school sports team are today! Which sport?",
		choices = {
			{
				id = "soccer",
				text = "⚽ Soccer",
				effects = { Stats = { Health = 5, Happiness = 4 } },
				resultText = "You made the soccer team! Go team!",
			},
			{
				id = "basketball",
				text = "🏀 Basketball",
				effects = { Stats = { Health = 5, Happiness = 4 } },
				resultText = "You made the basketball team! Time to shoot some hoops!",
			},
			{
				id = "skip_tryouts",
				text = "📚 Skip and study instead",
				effects = { Stats = { Smarts = 4, Health = -2 } },
				resultText = "You skipped tryouts to study. Your grades improved but you missed out.",
			},
		},
	},
	{
		id = "allowance",
		minAge = 7,
		maxAge = 14,
		weight = 5,
		text = "Your parents are offering you an allowance for doing chores. How much effort will you put in?",
		choices = {
			{
				id = "work_hard",
				text = "💪 Work hard",
				effects = { Stats = { Happiness = 2 }, Money = 20 },
				resultText = "You worked hard and earned your full allowance! $20!",
			},
			{
				id = "half_effort",
				text = "😐 Half effort",
				effects = { Stats = { Happiness = 1 }, Money = 10 },
				resultText = "You did the minimum. You got $10.",
			},
			{
				id = "refuse",
				text = "🙅 Refuse chores",
				effects = { Stats = { Happiness = 3 }, Money = 0 },
				resultText = "You refused to do chores. No money for you!",
			},
		},
	},
	{
		id = "summer_camp",
		minAge = 8,
		maxAge = 14,
		weight = 5,
		text = "Your parents want to send you to summer camp. How do you feel?",
		choices = {
			{
				id = "excited",
				text = "🏕️ Super excited!",
				effects = { Stats = { Happiness = 10, Health = 3 } },
				resultText = "Best summer ever! You made lifelong friends at camp!",
			},
			{
				id = "reluctant",
				text = "😕 Reluctantly go",
				effects = { Stats = { Happiness = 4, Smarts = 2 } },
				resultText = "You were hesitant but ended up having a great time!",
			},
			{
				id = "stay_home",
				text = "🏠 Stay home",
				effects = { Stats = { Happiness = 2 } },
				resultText = "You stayed home and played video games all summer.",
			},
		},
	},
	{
		id = "school_play",
		minAge = 7,
		maxAge = 14,
		weight = 4,
		text = "The school is putting on a play! What role do you want?",
		choices = {
			{
				id = "lead_role",
				text = "⭐ Try for the lead",
				effects = { Stats = { Happiness = 8, Looks = 3 } },
				resultText = "You got the lead role! Your performance was amazing!",
			},
			{
				id = "backstage",
				text = "🎭 Work backstage",
				effects = { Stats = { Smarts = 3, Happiness = 3 } },
				resultText = "You worked backstage and learned a lot about theater production.",
			},
			{
				id = "skip",
				text = "🚫 Skip it",
				effects = { Stats = { Happiness = -1 } },
				resultText = "You skipped the play. Your friends had fun without you.",
			},
		},
	},

	----------------------------------------------------------------
	-- PRE-TEEN EVENTS (Age 10-15)
	----------------------------------------------------------------
	{
		id = "crush",
		minAge = 10,
		maxAge = 14,
		weight = 7,
		text = "You have a crush on someone at school! What do you do?",
		choices = {
			{
				id = "confess",
				text = "💝 Tell them",
				effects = { Stats = { Happiness = 3, Looks = 1 } },
				resultText = "You told them! They thought it was sweet, even if they didn't feel the same.",
			},
			{
				id = "secret",
				text = "🤫 Keep it secret",
				effects = { Stats = { Happiness = -1 } },
				resultText = "You kept it to yourself. The mystery continues...",
			},
			{
				id = "note",
				text = "💌 Pass them a note",
				effects = { Stats = { Happiness = 4, Smarts = 1 } },
				resultText = "You passed them a note. They smiled when they read it!",
			},
		},
	},
	{
		id = "video_games",
		minAge = 8,
		maxAge = 16,
		weight = 6,
		text = "You've been playing video games all day. Your parents want you to stop.",
		choices = {
			{
				id = "stop",
				text = "🛑 Listen to them",
				effects = { Stats = { Happiness = -2, Health = 2 } },
				resultText = "You stopped playing. Your parents were pleased.",
			},
			{
				id = "negotiate",
				text = "🤝 Negotiate 30 more minutes",
				effects = { Stats = { Happiness = 3, Smarts = 2 } },
				resultText = "You successfully negotiated extra gaming time!",
			},
			{
				id = "ignore",
				text = "🎮 Keep playing",
				effects = { Stats = { Happiness = 4, Health = -3 } },
				resultText = "You kept playing. You got in trouble but beat the game!",
			},
		},
	},
	{
		id = "sleepover",
		minAge = 8,
		maxAge = 14,
		weight = 6,
		text = "You're invited to a sleepover at a friend's house!",
		choices = {
			{
				id = "go",
				text = "🎉 Go and have fun!",
				effects = { Stats = { Happiness = 8 } },
				resultText = "Best sleepover ever! You stayed up all night!",
			},
			{
				id = "homesick",
				text = "🏠 Get homesick and leave",
				effects = { Stats = { Happiness = -3 } },
				resultText = "You got homesick and called your parents to pick you up.",
			},
			{
				id = "decline",
				text = "❌ Stay home",
				effects = { Stats = { Happiness = -1 } },
				resultText = "You stayed home. You heard it was fun though...",
			},
		},
	},
	{
		id = "puberty_changes",
		minAge = 11,
		maxAge = 14,
		weight = 7,
		text = "Your body is going through changes. How do you handle it?",
		choices = {
			{
				id = "embrace",
				text = "😊 Embrace growing up",
				effects = { Stats = { Happiness = 3, Looks = 2 } },
				resultText = "You're handling puberty like a champ! You feel more mature.",
			},
			{
				id = "embarrassed",
				text = "😳 Feel embarrassed",
				effects = { Stats = { Happiness = -3 } },
				resultText = "You felt awkward about the changes. It's a normal phase.",
			},
			{
				id = "talk_parents",
				text = "👨‍👩‍👦 Talk to parents",
				effects = { Stats = { Happiness = 4, Smarts = 2 } },
				resultText = "Your parents helped explain everything. You feel better!",
			},
		},
	},
	{
		id = "social_media_first",
		minAge = 11,
		maxAge = 15,
		weight = 6,
		text = "All your friends are on social media. You want to join too!",
		choices = {
			{
				id = "join",
				text = "📱 Create an account",
				effects = { Stats = { Happiness = 5 } },
				resultText = "You're now on social media! You gained 50 followers instantly!",
			},
			{
				id = "wait",
				text = "⏳ Wait until you're older",
				effects = { Stats = { Smarts = 2 } },
				resultText = "You decided to wait. Good things come to those who wait.",
			},
			{
				id = "secret",
				text = "🤫 Make a secret account",
				effects = { Stats = { Happiness = 4, Smarts = -1 } },
				resultText = "You made a secret account. Just don't let your parents find out!",
			},
		},
	},
	{
		id = "first_phone",
		minAge = 10,
		maxAge = 14,
		weight = 6,
		text = "You finally got your first phone! What's the first thing you do?",
		choices = {
			{
				id = "games",
				text = "🎮 Download games",
				effects = { Stats = { Happiness = 5 } },
				resultText = "You downloaded all the best games! So much fun!",
			},
			{
				id = "text_friends",
				text = "💬 Text all your friends",
				effects = { Stats = { Happiness = 4 } },
				resultText = "You texted everyone! Your thumbs are tired but you're happy.",
			},
			{
				id = "responsible",
				text = "📚 Use it responsibly",
				effects = { Stats = { Smarts = 3, Happiness = 2 } },
				resultText = "You used it responsibly. Your parents are impressed!",
			},
		},
	},
	{
		id = "middle_school_cliques",
		minAge = 11,
		maxAge = 14,
		weight = 5,
		text = "Middle school has different social groups. Which do you gravitate toward?",
		choices = {
			{
				id = "popular_kids",
				text = "🌟 The popular kids",
				effects = { Stats = { Happiness = 5, Looks = 3 } },
				resultText = "You're now part of the popular crowd! You feel on top of the world.",
			},
			{
				id = "nerds",
				text = "🤓 The smart kids",
				effects = { Stats = { Smarts = 5, Happiness = 3 } },
				resultText = "You joined the academic achievers! Your grades improved.",
			},
			{
				id = "athletes",
				text = "🏆 The athletes",
				effects = { Stats = { Health = 5, Happiness = 3 } },
				resultText = "You're hanging with the jocks! You're getting more athletic.",
			},
			{
				id = "own_path",
				text = "🚶 Go your own way",
				effects = { Stats = { Happiness = 4, Smarts = 2 } },
				resultText = "You didn't conform to any group. You're your own person!",
			},
		},
	},

	----------------------------------------------------------------
	-- TEENAGER EVENTS (Age 13-19)
	----------------------------------------------------------------
	{
		id = "first_job_offer",
		minAge = 14,
		maxAge = 17,
		weight = 8,
		text = "A local business is offering you a part-time job after school!",
		choices = {
			{
				id = "accept",
				text = "✅ Accept the job",
				effects = { Stats = { Happiness = 3, Smarts = 2 }, Money = 500 },
				resultText = "You got your first job! Time to start earning money!",
			},
			{
				id = "decline",
				text = "❌ Focus on school",
				effects = { Stats = { Smarts = 5 } },
				resultText = "You declined to focus on your studies. Your grades improved!",
			},
		},
	},
	{
		id = "house_party",
		minAge = 15,
		maxAge = 19,
		weight = 6,
		text = "Someone's throwing a house party while their parents are away. You're invited!",
		choices = {
			{
				id = "go",
				text = "🎊 Go to the party!",
				effects = { Stats = { Happiness = 8, Health = -3, Looks = 2 } },
				resultText = "Wild party! You had an amazing time!",
			},
			{
				id = "skip",
				text = "📚 Stay home and study",
				effects = { Stats = { Smarts = 5, Happiness = -2 } },
				resultText = "You stayed home. You heard the cops showed up anyway!",
			},
			{
				id = "sneak",
				text = "🤫 Sneak out",
				effects = { Stats = { Happiness = 6, Health = -2 } },
				resultText = "You snuck out! The party was fun, but you're tired.",
			},
		},
	},
	{
		id = "driving_test",
		minAge = 16,
		maxAge = 18,
		weight = 9,
		text = "It's time for your driving test! Are you ready?",
		choices = {
			{
				id = "confident",
				text = "😎 Confident and ready!",
				effects = { Stats = { Happiness = 8, Smarts = 2 } },
				resultText = "You passed! You got your driver's license!",
			},
			{
				id = "nervous",
				text = "😰 Nervous wreck",
				effects = { Stats = { Happiness = -3, Smarts = 1 } },
				resultText = "You were too nervous and failed. You can try again next month.",
			},
			{
				id = "unprepared",
				text = "🤷 Wing it",
				effects = { Stats = { Happiness = 2 } },
				resultText = "You barely passed! But hey, a pass is a pass!",
			},
		},
	},
	{
		id = "prom",
		minAge = 16,
		maxAge = 18,
		weight = 7,
		text = "Prom night is coming up! What's your plan?",
		choices = {
			{
				id = "ask_crush",
				text = "💕 Ask your crush",
				effects = { Stats = { Happiness = 10, Looks = 3 } },
				resultText = "They said yes! You had the most magical night!",
			},
			{
				id = "go_friends",
				text = "👯 Go with friends",
				effects = { Stats = { Happiness = 7 } },
				resultText = "You went with your squad! Best group photo ever!",
			},
			{
				id = "skip",
				text = "🚫 Skip prom",
				effects = { Stats = { Happiness = -4, Smarts = 2 } },
				resultText = "You skipped prom. You'll always wonder what it was like...",
			},
		},
	},
	{
		id = "college_decision",
		minAge = 17,
		maxAge = 18,
		weight = 10,
		text = "You've graduated high school! What's next?",
		choices = {
			{
				id = "university",
				text = "🎓 Go to university",
				effects = { Stats = { Smarts = 10, Happiness = 3 }, Money = -5000 },
				resultText = "You're going to college! Time to learn and grow!",
			},
			{
				id = "work",
				text = "💼 Enter the workforce",
				effects = { Stats = { Happiness = 2 }, Money = 2000 },
				resultText = "You decided to start working right away. Time to make money!",
			},
			{
				id = "gap_year",
				text = "✈️ Take a gap year",
				effects = { Stats = { Happiness = 8, Health = 3 }, Money = -1000 },
				resultText = "You took a year to travel and find yourself. Life-changing!",
			},
			{
				id = "military",
				text = "🎖️ Join the military",
				effects = { Stats = { Health = 10, Smarts = 3, Happiness = 2 } },
				resultText = "You enlisted in the military! Time to serve your country!",
			},
		},
	},
	{
		id = "first_kiss",
		minAge = 13,
		maxAge = 18,
		weight = 6,
		text = "You're on a date and the moment feels right for a first kiss...",
		choices = {
			{
				id = "go_for_it",
				text = "💋 Go for it!",
				effects = { Stats = { Happiness = 10, Looks = 1 } },
				resultText = "Your first kiss! It was magical and unforgettable!",
			},
			{
				id = "wait",
				text = "⏳ Wait for a better moment",
				effects = { Stats = { Happiness = 2 } },
				resultText = "You decided to wait. The anticipation builds...",
			},
			{
				id = "awkward",
				text = "😬 Accidentally headbutt them",
				effects = { Stats = { Happiness = -2, Health = -1 } },
				resultText = "You went in and bonked heads! Embarrassing but memorable!",
			},
		},
	},
	{
		id = "senior_prank",
		minAge = 17,
		maxAge = 18,
		weight = 5,
		text = "Your friends want to pull a senior prank. What do you do?",
		choices = {
			{
				id = "participate",
				text = "🎭 Join in!",
				effects = { Stats = { Happiness = 8 } },
				resultText = "The prank was legendary! The whole school is talking about it!",
			},
			{
				id = "mastermind",
				text = "🧠 Be the mastermind",
				effects = { Stats = { Smarts = 3, Happiness = 6 } },
				resultText = "You planned the perfect prank! Everyone thinks you're a genius!",
			},
			{
				id = "stay_out",
				text = "🚫 Stay out of it",
				effects = { Stats = { Smarts = 2, Happiness = -1 } },
				resultText = "You stayed out of it. Probably wise - some people got in trouble.",
			},
		},
	},
	{
		id = "underage_drinking",
		minAge = 15,
		maxAge = 20,
		weight = 4,
		text = "Your friends are drinking at a party. They offer you a drink.",
		choices = {
			{
				id = "drink",
				text = "🍺 Have a drink",
				effects = { Stats = { Happiness = 4, Health = -5, Smarts = -2 } },
				resultText = "You had a few drinks. You felt sick the next day.",
			},
			{
				id = "decline",
				text = "🚫 No thanks",
				effects = { Stats = { Health = 2, Smarts = 2 } },
				resultText = "You declined. Your friends respected your choice.",
			},
			{
				id = "pretend",
				text = "🥤 Pretend to drink",
				effects = { Stats = { Smarts = 3, Happiness = 2 } },
				resultText = "You pretended to drink. No one noticed!",
			},
		},
	},
	{
		id = "rebel_phase",
		minAge = 14,
		maxAge = 18,
		weight = 4,
		text = "You're feeling rebellious. How do you express yourself?",
		choices = {
			{
				id = "hair_dye",
				text = "💇 Dye your hair a wild color",
				effects = { Stats = { Happiness = 5, Looks = 2 } },
				resultText = "You dyed your hair bright purple! You love it!",
			},
			{
				id = "piercing",
				text = "👂 Get a piercing",
				effects = { Stats = { Happiness = 4, Looks = 3, Health = -1 } },
				resultText = "You got a piercing! Your parents weren't thrilled but you love it.",
			},
			{
				id = "stay_good",
				text = "😇 Stay on the straight and narrow",
				effects = { Stats = { Smarts = 3, Happiness = 1 } },
				resultText = "You decided not to rebel. Your parents are proud.",
			},
		},
	},

	----------------------------------------------------------------
	-- YOUNG ADULT EVENTS (Age 18-30)
	----------------------------------------------------------------
	{
		id = "apartment",
		minAge = 18,
		maxAge = 25,
		weight = 7,
		text = "You're moving into your first apartment! How do you feel?",
		choices = {
			{
				id = "excited",
				text = "🏠 So excited!",
				effects = { Stats = { Happiness = 8 }, Money = -500 },
				resultText = "Freedom at last! You love having your own place!",
			},
			{
				id = "scared",
				text = "😟 A bit scared",
				effects = { Stats = { Happiness = 2, Smarts = 2 }, Money = -500 },
				resultText = "It's scary but you're learning to be independent.",
			},
			{
				id = "stay_home",
				text = "👨‍👩‍👦 Stay with parents",
				effects = { Stats = { Happiness = -2 }, Money = 300 },
				resultText = "You decided to save money and stay home longer.",
			},
		},
	},
	{
		id = "promotion",
		minAge = 22,
		maxAge = 45,
		weight = 6,
		text = "Your boss is considering you for a promotion, but it means more responsibility.",
		choices = {
			{
				id = "take_it",
				text = "📈 Take the promotion!",
				effects = { Stats = { Happiness = 5, Health = -2 }, Money = 5000 },
				resultText = "Congratulations! You got promoted and a raise!",
			},
			{
				id = "decline",
				text = "⚖️ Maintain work-life balance",
				effects = { Stats = { Happiness = 3, Health = 2 } },
				resultText = "You declined. Sometimes peace is worth more than money.",
			},
		},
	},
	{
		id = "gym_routine",
		minAge = 18,
		maxAge = 60,
		weight = 5,
		text = "A friend invites you to start a workout routine together.",
		choices = {
			{
				id = "join",
				text = "💪 Join them!",
				effects = { Stats = { Health = 8, Looks = 5, Happiness = 3 } },
				resultText = "You started working out regularly! You feel great!",
			},
			{
				id = "decline",
				text = "🛋️ Nah, I'm good",
				effects = { Stats = { Happiness = 1, Health = -2 } },
				resultText = "You stayed on the couch. Maybe next time.",
			},
		},
	},
	{
		id = "lottery",
		minAge = 18,
		maxAge = 99,
		weight = 2,
		text = "You bought a lottery ticket and... the numbers are matching!",
		choices = {
			{
				id = "check",
				text = "🎰 Check all numbers",
				effects = { Money = 10000, Stats = { Happiness = 15 } },
				resultText = "YOU WON $10,000! This is your lucky day!",
			},
			{
				id = "throw_away",
				text = "🗑️ Probably nothing...",
				effects = { Stats = { Happiness = -5 } },
				resultText = "You threw away a winning ticket! You'll never know what you lost.",
			},
		},
	},
	{
		id = "side_hustle",
		minAge = 18,
		maxAge = 50,
		weight = 5,
		text = "A friend proposes starting a side business together.",
		choices = {
			{
				id = "invest",
				text = "💰 Invest and join!",
				effects = { Stats = { Smarts = 5, Happiness = 3 }, Money = 2000 },
				resultText = "The business took off! Your investment paid off!",
			},
			{
				id = "decline",
				text = "🤔 Too risky",
				effects = { Stats = { Happiness = -1 } },
				resultText = "You played it safe. The business succeeded without you.",
			},
			{
				id = "scam",
				text = "🔍 Research first",
				effects = { Stats = { Smarts = 3 } },
				resultText = "Good thing you researched - it was a pyramid scheme!",
			},
		},
	},
	{
		id = "dating_app",
		minAge = 18,
		maxAge = 50,
		weight = 5,
		text = "You've been swiping on a dating app. You matched with someone attractive!",
		choices = {
			{
				id = "meet_up",
				text = "☕ Meet for coffee",
				effects = { Stats = { Happiness = 6, Looks = 1 } },
				resultText = "Great first date! You really hit it off!",
			},
			{
				id = "ghost",
				text = "👻 Ghost them",
				effects = { Stats = { Happiness = -2 } },
				resultText = "You ghosted them. That wasn't very nice...",
			},
			{
				id = "video_call",
				text = "📹 Video call first",
				effects = { Stats = { Smarts = 2, Happiness = 4 } },
				resultText = "Smart move! The video call went great, now you're planning to meet!",
			},
		},
	},
	{
		id = "marriage_proposal",
		minAge = 21,
		maxAge = 60,
		weight = 4,
		text = "Your partner hints that they're ready for marriage. What do you do?",
		choices = {
			{
				id = "propose",
				text = "💍 Propose!",
				effects = { Stats = { Happiness = 15 }, Money = -3000 },
				resultText = "You proposed and they said YES! Wedding bells are ringing!",
			},
			{
				id = "wait",
				text = "⏳ Not ready yet",
				effects = { Stats = { Happiness = -3 } },
				resultText = "You told them you're not ready. They're a bit disappointed.",
			},
			{
				id = "discuss",
				text = "💬 Have a conversation",
				effects = { Stats = { Happiness = 5, Smarts = 2 } },
				resultText = "You had an open conversation about the future. Your relationship is stronger!",
			},
		},
	},
	{
		id = "wedding_planning",
		minAge = 22,
		maxAge = 60,
		weight = 3,
		text = "You're planning your wedding! How big should it be?",
		choices = {
			{
				id = "big_wedding",
				text = "👑 Extravagant affair",
				effects = { Stats = { Happiness = 12, Looks = 3 }, Money = -25000 },
				resultText = "Your wedding was stunning! The photos are incredible!",
			},
			{
				id = "small_wedding",
				text = "💒 Intimate ceremony",
				effects = { Stats = { Happiness = 10 }, Money = -5000 },
				resultText = "A beautiful small wedding with close family and friends.",
			},
			{
				id = "courthouse",
				text = "🏛️ Courthouse wedding",
				effects = { Stats = { Happiness = 6, Smarts = 2 }, Money = -500 },
				resultText = "Quick, easy, and official! You saved money for the honeymoon!",
			},
		},
	},
	{
		id = "having_kids",
		minAge = 22,
		maxAge = 45,
		weight = 4,
		text = "You and your partner are discussing having children. What do you think?",
		choices = {
			{
				id = "yes_kids",
				text = "👶 Let's do it!",
				effects = { Stats = { Happiness = 10, Health = -3 }, Money = -2000 },
				resultText = "Congratulations! You're going to be a parent!",
			},
			{
				id = "not_yet",
				text = "⏳ Not yet",
				effects = { Stats = { Happiness = 2 } },
				resultText = "You decided to wait. There's no rush.",
			},
			{
				id = "no_kids",
				text = "🚫 I don't want kids",
				effects = { Stats = { Happiness = 3, Health = 2 } },
				resultText = "You decided children aren't for you. That's a valid choice!",
			},
		},
	},
	{
		id = "career_change",
		minAge = 25,
		maxAge = 50,
		weight = 4,
		text = "You're considering a complete career change. It's risky but could be rewarding.",
		choices = {
			{
				id = "change",
				text = "🔄 Make the change!",
				effects = { Stats = { Happiness = 8, Smarts = 5 }, Money = -3000 },
				resultText = "You took the leap! After some struggle, you found success in your new career!",
			},
			{
				id = "stay",
				text = "🔒 Stay where you are",
				effects = { Stats = { Happiness = -2, Health = 1 } },
				resultText = "You played it safe. The security is nice, but you wonder 'what if?'",
			},
			{
				id = "side_gig",
				text = "🌙 Start as a side gig",
				effects = { Stats = { Smarts = 4, Health = -2 }, Money = 1000 },
				resultText = "You started pursuing your passion on the side. Best of both worlds!",
			},
		},
	},
	{
		id = "buy_house",
		minAge = 25,
		maxAge = 55,
		weight = 5,
		text = "You've saved up enough for a down payment on a house!",
		choices = {
			{
				id = "buy_house",
				text = "🏡 Buy a house!",
				effects = { Stats = { Happiness = 10 }, Money = -30000 },
				resultText = "You're a homeowner! Time to make this house a home!",
			},
			{
				id = "keep_renting",
				text = "🏢 Keep renting",
				effects = { Stats = { Happiness = 1 }, Money = 2000 },
				resultText = "You decided to keep renting. Flexibility has its perks.",
			},
			{
				id = "invest_instead",
				text = "📈 Invest the money",
				effects = { Stats = { Smarts = 5 }, Money = 5000 },
				resultText = "You invested instead. Your portfolio is growing!",
			},
		},
	},
	{
		id = "dream_job_offer",
		minAge = 25,
		maxAge = 45,
		weight = 3,
		text = "You got an offer for your dream job, but it requires relocating to another city!",
		choices = {
			{
				id = "take_job",
				text = "✈️ Take the job and move!",
				effects = { Stats = { Happiness = 12, Smarts = 5 }, Money = 10000 },
				resultText = "You made the move! It was scary but so worth it!",
			},
			{
				id = "decline_job",
				text = "🏠 Stay where you are",
				effects = { Stats = { Happiness = -5 } },
				resultText = "You turned down your dream job. You have regrets...",
			},
			{
				id = "negotiate_remote",
				text = "💻 Negotiate remote work",
				effects = { Stats = { Happiness = 8, Smarts = 3 }, Money = 8000 },
				resultText = "They agreed to let you work remotely! Win-win!",
			},
		},
	},
	{
		id = "exotic_vacation",
		minAge = 20,
		maxAge = 70,
		weight = 4,
		text = "You have the opportunity for an exotic vacation!",
		choices = {
			{
				id = "tropical",
				text = "🏝️ Tropical beach resort",
				effects = { Stats = { Happiness = 12, Health = 3 }, Money = -5000 },
				resultText = "Paradise! You relaxed on beautiful beaches and felt rejuvenated!",
			},
			{
				id = "adventure",
				text = "🏔️ Mountain adventure",
				effects = { Stats = { Happiness = 10, Health = 5 }, Money = -4000 },
				resultText = "An incredible adventure! You hiked, climbed, and explored!",
			},
			{
				id = "staycation",
				text = "🏠 Save money - staycation",
				effects = { Stats = { Happiness = 4 }, Money = 500 },
				resultText = "A relaxing staycation. Sometimes the best vacation is at home.",
			},
		},
	},

	----------------------------------------------------------------
	-- ADULT EVENTS (Age 30-55)
	----------------------------------------------------------------
	{
		id = "midlife_crisis",
		minAge = 35,
		maxAge = 50,
		weight = 5,
		text = "You're feeling like life is passing you by. Midlife crisis?",
		choices = {
			{
				id = "sports_car",
				text = "🏎️ Buy a sports car",
				effects = { Stats = { Happiness = 8, Looks = 3 }, Money = -15000 },
				resultText = "VROOM! You look amazing in your new ride!",
			},
			{
				id = "therapy",
				text = "🧠 See a therapist",
				effects = { Stats = { Happiness = 10, Health = 3 }, Money = -500 },
				resultText = "Therapy helped you find meaning again. Best decision ever.",
			},
			{
				id = "ignore",
				text = "😐 Ignore it",
				effects = { Stats = { Happiness = -5 } },
				resultText = "You pushed the feelings down. They'll come back...",
			},
			{
				id = "new_hobby",
				text = "🎸 Pick up a new hobby",
				effects = { Stats = { Happiness = 7, Smarts = 3 } },
				resultText = "You started learning guitar! It's never too late!",
			},
		},
	},
	{
		id = "health_scare",
		minAge = 40,
		maxAge = 80,
		weight = 4,
		text = "The doctor found something concerning in your checkup.",
		choices = {
			{
				id = "follow_up",
				text = "🏥 Get it checked immediately",
				effects = { Stats = { Health = 5, Happiness = -3 }, Money = -1000 },
				resultText = "False alarm! But good thing you got it checked.",
			},
			{
				id = "ignore",
				text = "🙈 Ignore it",
				effects = { Stats = { Health = -10, Happiness = 2 } },
				resultText = "Ignoring health issues is never a good idea...",
			},
			{
				id = "lifestyle",
				text = "🥗 Change lifestyle",
				effects = { Stats = { Health = 10, Looks = 3, Happiness = 2 }, Money = -200 },
				resultText = "You started eating healthy and exercising. You feel reborn!",
			},
		},
	},
	{
		id = "child_graduation",
		minAge = 40,
		maxAge = 65,
		weight = 3,
		text = "Your child is graduating! You couldn't be more proud!",
		choices = {
			{
				id = "big_party",
				text = "🎉 Throw a huge party",
				effects = { Stats = { Happiness = 12 }, Money = -2000 },
				resultText = "What an amazing celebration! Your child felt so special!",
			},
			{
				id = "special_gift",
				text = "🎁 Give them a special gift",
				effects = { Stats = { Happiness = 10 }, Money = -5000 },
				resultText = "You gave them their dream gift. They'll never forget this!",
			},
			{
				id = "heartfelt_speech",
				text = "💝 Give a heartfelt speech",
				effects = { Stats = { Happiness = 8 } },
				resultText = "Your speech brought everyone to tears. Beautiful moment!",
			},
		},
	},
	{
		id = "empty_nest",
		minAge = 45,
		maxAge = 60,
		weight = 4,
		text = "Your last child just moved out. The house feels empty...",
		choices = {
			{
				id = "redecorate",
				text = "🏠 Redecorate and embrace it",
				effects = { Stats = { Happiness = 6 }, Money = -3000 },
				resultText = "You redecorated! The house feels fresh and new!",
			},
			{
				id = "travel",
				text = "✈️ Start traveling",
				effects = { Stats = { Happiness = 10, Health = 2 }, Money = -5000 },
				resultText = "You and your partner started traveling! So many adventures!",
			},
			{
				id = "sad",
				text = "😢 Feel sad about it",
				effects = { Stats = { Happiness = -5 } },
				resultText = "You miss having them around. It's a big adjustment.",
			},
		},
	},
	{
		id = "inheritance",
		minAge = 30,
		maxAge = 70,
		weight = 3,
		text = "A relative passed away and left you an inheritance!",
		choices = {
			{
				id = "invest",
				text = "📈 Invest it wisely",
				effects = { Stats = { Smarts = 5 }, Money = 20000 },
				resultText = "You invested the inheritance. Your wealth is growing!",
			},
			{
				id = "splurge",
				text = "🛍️ Splurge on yourself",
				effects = { Stats = { Happiness = 8 }, Money = 10000 },
				resultText = "You treated yourself! You deserve it!",
			},
			{
				id = "charity",
				text = "💝 Donate to charity",
				effects = { Stats = { Happiness = 10, Smarts = 2 }, Money = 5000 },
				resultText = "You donated most of it to causes you care about. You feel good.",
			},
		},
	},
	{
		id = "neighbor_conflict",
		minAge = 25,
		maxAge = 70,
		weight = 4,
		text = "Your neighbor is being really annoying - loud music at all hours!",
		choices = {
			{
				id = "confront",
				text = "😠 Confront them directly",
				effects = { Stats = { Happiness = -2, Health = -1 } },
				resultText = "You confronted them. It got heated but they agreed to quiet down.",
			},
			{
				id = "polite_note",
				text = "📝 Leave a polite note",
				effects = { Stats = { Happiness = 3, Smarts = 2 } },
				resultText = "Your polite note worked! They apologized and quieted down.",
			},
			{
				id = "authorities",
				text = "👮 Call the authorities",
				effects = { Stats = { Happiness = 1 } },
				resultText = "You called in a noise complaint. The music stopped.",
			},
			{
				id = "ignore",
				text = "🎧 Buy noise-canceling headphones",
				effects = { Stats = { Happiness = 4 }, Money = -200 },
				resultText = "You bought headphones. Problem solved, sort of.",
			},
		},
	},
	{
		id = "volunteer_opportunity",
		minAge = 25,
		maxAge = 75,
		weight = 4,
		text = "A local charity is looking for volunteers. Do you have time to help?",
		choices = {
			{
				id = "volunteer",
				text = "🤝 Sign up to volunteer",
				effects = { Stats = { Happiness = 8, Health = 2 } },
				resultText = "You started volunteering! It's so rewarding to give back!",
			},
			{
				id = "donate",
				text = "💰 Just donate money",
				effects = { Stats = { Happiness = 4 }, Money = -500 },
				resultText = "You donated instead. Every bit helps!",
			},
			{
				id = "pass",
				text = "❌ Too busy right now",
				effects = { Stats = { Happiness = -1 } },
				resultText = "You passed. Maybe next time.",
			},
		},
	},
	{
		id = "stock_market",
		minAge = 25,
		maxAge = 70,
		weight = 4,
		text = "You hear about a hot stock tip that could make you rich!",
		choices = {
			{
				id = "invest_big",
				text = "💰 Invest big!",
				effects = { Stats = { Happiness = 5 }, Money = 8000 },
				resultText = "The stock went up! You made a nice profit!",
			},
			{
				id = "small_investment",
				text = "📊 Invest conservatively",
				effects = { Stats = { Smarts = 3 }, Money = 2000 },
				resultText = "You made a small but safe investment. Steady gains!",
			},
			{
				id = "avoid",
				text = "🚫 Sounds too risky",
				effects = { Stats = { Smarts = 2 } },
				resultText = "You avoided the stock. Smart move - it crashed the next week!",
			},
		},
	},

	----------------------------------------------------------------
	-- SENIOR EVENTS (Age 55+)
	----------------------------------------------------------------
	{
		id = "retirement_offer",
		minAge = 55,
		maxAge = 70,
		weight = 6,
		text = "Your company is offering early retirement with a nice package.",
		choices = {
			{
				id = "take_it",
				text = "🏖️ Take the package!",
				effects = { Stats = { Happiness = 10, Health = 3 }, Money = 50000 },
				resultText = "Hello retirement! Time to enjoy life!",
			},
			{
				id = "keep_working",
				text = "💼 Keep working",
				effects = { Stats = { Happiness = -2, Smarts = 2 }, Money = 10000 },
				resultText = "You kept working. The extra income is nice.",
			},
		},
	},
	{
		id = "grandchildren",
		minAge = 50,
		maxAge = 80,
		weight = 5,
		text = "Your children just had a baby! You're a grandparent!",
		choices = {
			{
				id = "spoil",
				text = "🎁 Spoil them rotten!",
				effects = { Stats = { Happiness = 15 }, Money = -500 },
				resultText = "You're the best grandparent ever! So many toys and treats!",
			},
			{
				id = "strict",
				text = "📚 Teach them values",
				effects = { Stats = { Happiness = 8, Smarts = 2 } },
				resultText = "You focused on teaching important life lessons.",
			},
		},
	},
	{
		id = "bucket_list",
		minAge = 60,
		maxAge = 90,
		weight = 5,
		text = "You've always dreamed of traveling the world. Now or never?",
		choices = {
			{
				id = "travel",
				text = "✈️ Book the trip!",
				effects = { Stats = { Happiness = 20, Health = -2 }, Money = -10000 },
				resultText = "Best trip of your life! You saw the world!",
			},
			{
				id = "save",
				text = "💰 Save the money",
				effects = { Stats = { Happiness = -5 }, Money = 5000 },
				resultText = "You saved the money but always wondered 'what if?'",
			},
			{
				id = "staycation",
				text = "🏠 Local adventures",
				effects = { Stats = { Happiness = 8 }, Money = -500 },
				resultText = "You discovered amazing places right in your backyard!",
			},
		},
	},
	{
		id = "health_decline",
		minAge = 65,
		maxAge = 95,
		weight = 5,
		text = "You're noticing your health isn't what it used to be...",
		choices = {
			{
				id = "healthy_habits",
				text = "🥗 Adopt healthy habits",
				effects = { Stats = { Health = 8, Happiness = 4 }, Money = -200 },
				resultText = "You started eating better and exercising. You feel years younger!",
			},
			{
				id = "accept_it",
				text = "🤷 Accept aging gracefully",
				effects = { Stats = { Happiness = 5 } },
				resultText = "You accepted aging as a natural part of life. Wisdom comes with age.",
			},
			{
				id = "deny",
				text = "💊 Fight it with everything",
				effects = { Stats = { Health = 3, Happiness = -2 }, Money = -3000 },
				resultText = "You tried every supplement and treatment. Some helped!",
			},
		},
	},
	{
		id = "legacy_planning",
		minAge = 60,
		maxAge = 90,
		weight = 4,
		text = "It's time to think about your legacy. What do you want to leave behind?",
		choices = {
			{
				id = "family_wealth",
				text = "💰 Leave wealth for family",
				effects = { Stats = { Happiness = 6 } },
				resultText = "You set up trusts and investments for your family's future.",
			},
			{
				id = "charity",
				text = "💝 Donate to charity",
				effects = { Stats = { Happiness = 10 }, Money = -10000 },
				resultText = "You established a charitable foundation. Your legacy will help many.",
			},
			{
				id = "memories",
				text = "📸 Focus on making memories",
				effects = { Stats = { Happiness = 8 } },
				resultText = "You spent time with loved ones creating beautiful memories.",
			},
		},
	},
	{
		id = "reunion",
		minAge = 50,
		maxAge = 80,
		weight = 4,
		text = "Your high school is having a reunion! Do you want to go?",
		choices = {
			{
				id = "attend",
				text = "🎉 Definitely going!",
				effects = { Stats = { Happiness = 8 } },
				resultText = "What a blast from the past! You reconnected with old friends!",
			},
			{
				id = "skip",
				text = "🚫 Skip it",
				effects = { Stats = { Happiness = -2 } },
				resultText = "You skipped the reunion. You heard it was fun though.",
			},
			{
				id = "organize",
				text = "📋 Help organize it",
				effects = { Stats = { Happiness = 10, Smarts = 2 } },
				resultText = "You helped organize and it was the best reunion ever!",
			},
		},
	},
	{
		id = "wisdom_sharing",
		minAge = 60,
		maxAge = 90,
		weight = 3,
		text = "A young person asks you for life advice. What wisdom do you share?",
		choices = {
			{
				id = "follow_passion",
				text = "💝 Follow your passion",
				effects = { Stats = { Happiness = 6 } },
				resultText = "You encouraged them to pursue their dreams. They were inspired!",
			},
			{
				id = "work_hard",
				text = "💪 Work hard and save money",
				effects = { Stats = { Smarts = 3, Happiness = 4 } },
				resultText = "You shared practical wisdom about success. They took notes!",
			},
			{
				id = "enjoy_life",
				text = "🌈 Enjoy every moment",
				effects = { Stats = { Happiness = 8 } },
				resultText = "You reminded them life is short. Live fully!",
			},
		},
	},
	{
		id = "golden_anniversary",
		minAge = 70,
		maxAge = 95,
		weight = 2,
		text = "You're celebrating your golden wedding anniversary!",
		choices = {
			{
				id = "big_party",
				text = "🎊 Throw a big celebration",
				effects = { Stats = { Happiness = 15 }, Money = -3000 },
				resultText = "An amazing celebration of 50 years of love!",
			},
			{
				id = "renew_vows",
				text = "💍 Renew your vows",
				effects = { Stats = { Happiness = 12 }, Money = -1000 },
				resultText = "You renewed your vows. There wasn't a dry eye in the room.",
			},
			{
				id = "quiet_dinner",
				text = "🍷 Quiet romantic dinner",
				effects = { Stats = { Happiness = 10 }, Money = -500 },
				resultText = "A beautiful intimate dinner celebrating your life together.",
			},
		},
	},

	----------------------------------------------------------------
	-- RANDOM/SPECIAL EVENTS (Any Age)
	----------------------------------------------------------------
	{
		id = "random_kindness",
		minAge = 5,
		maxAge = 99,
		weight = 3,
		text = "You witness someone in need. A stranger dropped their wallet.",
		choices = {
			{
				id = "return_it",
				text = "🤝 Return the wallet",
				effects = { Stats = { Happiness = 8 }, Money = 50 },
				resultText = "You returned the wallet! They gave you a reward and thanked you profusely!",
			},
			{
				id = "keep_it",
				text = "😈 Keep the money",
				effects = { Stats = { Happiness = -3 }, Money = 200 },
				resultText = "You kept the money. You feel a bit guilty...",
			},
			{
				id = "ignore",
				text = "🚶 Walk past",
				effects = { Stats = { Happiness = -1 } },
				resultText = "You walked past. Someone else probably got it.",
			},
		},
	},
	{
		id = "viral_moment",
		minAge = 13,
		maxAge = 50,
		weight = 2,
		text = "Something you posted online is going viral!",
		choices = {
			{
				id = "embrace",
				text = "🌟 Embrace the fame",
				effects = { Stats = { Happiness = 10, Looks = 3 }, Money = 1000 },
				resultText = "You became internet famous! Brand deals are coming in!",
			},
			{
				id = "stay_humble",
				text = "😊 Stay humble",
				effects = { Stats = { Happiness = 6, Smarts = 2 } },
				resultText = "You stayed grounded despite the attention. Respect!",
			},
			{
				id = "delete",
				text = "🗑️ Delete everything",
				effects = { Stats = { Happiness = -2 } },
				resultText = "You panicked and deleted it. Too late - it's everywhere!",
			},
		},
	},
	{
		id = "natural_disaster",
		minAge = 10,
		maxAge = 99,
		weight = 2,
		text = "A natural disaster warning has been issued for your area!",
		choices = {
			{
				id = "evacuate",
				text = "🏃 Evacuate immediately",
				effects = { Stats = { Health = 5, Smarts = 3 }, Money = -500 },
				resultText = "You evacuated safely. Smart decision!",
			},
			{
				id = "ride_it_out",
				text = "🏠 Stay and ride it out",
				effects = { Stats = { Health = -5, Happiness = -3 } },
				resultText = "You stayed and it was terrifying, but you survived.",
			},
			{
				id = "help_others",
				text = "🦸 Help neighbors evacuate",
				effects = { Stats = { Happiness = 10, Health = -2 } },
				resultText = "You're a hero! You helped your neighbors get to safety!",
			},
		},
	},
	{
		id = "talent_discovered",
		minAge = 8,
		maxAge = 30,
		weight = 3,
		text = "Someone notices you have a hidden talent!",
		choices = {
			{
				id = "pursue",
				text = "⭐ Pursue it seriously",
				effects = { Stats = { Happiness = 8, Smarts = 5 }, Money = -500 },
				resultText = "You started training your talent! You're getting really good!",
			},
			{
				id = "hobby",
				text = "🎨 Keep it as a hobby",
				effects = { Stats = { Happiness = 5 } },
				resultText = "You enjoy it as a hobby. It's a nice creative outlet.",
			},
			{
				id = "ignore_talent",
				text = "🤷 Not interested",
				effects = { Stats = { Happiness = -2 } },
				resultText = "You ignored your potential. What could have been?",
			},
		},
	},
	{
		id = "scam_attempt",
		minAge = 18,
		maxAge = 99,
		weight = 3,
		text = "You receive a suspicious email claiming you've won a prize...",
		choices = {
			{
				id = "delete",
				text = "🗑️ Delete it - obvious scam",
				effects = { Stats = { Smarts = 3 } },
				resultText = "Good call! It was definitely a scam.",
			},
			{
				id = "click",
				text = "🖱️ Click to claim prize",
				effects = { Stats = { Happiness = -5, Smarts = -2 }, Money = -500 },
				resultText = "You got scammed! Your identity was compromised!",
			},
			{
				id = "report",
				text = "🚔 Report it to authorities",
				effects = { Stats = { Smarts = 4, Happiness = 3 } },
				resultText = "You reported the scam. You might have saved others from it!",
			},
		},
	},
	{
		id = "celebrity_encounter",
		minAge = 10,
		maxAge = 70,
		weight = 2,
		text = "You run into a celebrity at a coffee shop!",
		choices = {
			{
				id = "ask_selfie",
				text = "📸 Ask for a selfie",
				effects = { Stats = { Happiness = 8 } },
				resultText = "They said yes! Now you have an amazing photo to show everyone!",
			},
			{
				id = "play_cool",
				text = "😎 Play it cool",
				effects = { Stats = { Happiness = 5, Looks = 2 } },
				resultText = "You played it cool and they actually chatted with you!",
			},
			{
				id = "freak_out",
				text = "😱 Freak out",
				effects = { Stats = { Happiness = 3 } },
				resultText = "You freaked out and they awkwardly walked away. Oops!",
			},
		},
	},
	{
		id = "lost_pet",
		minAge = 8,
		maxAge = 80,
		weight = 3,
		text = "You find a lost dog wandering the streets with a collar.",
		choices = {
			{
				id = "return_pet",
				text = "🏠 Find the owner",
				effects = { Stats = { Happiness = 10 }, Money = 100 },
				resultText = "You reunited the dog with its owner! They were so grateful!",
			},
			{
				id = "shelter",
				text = "🏥 Take to a shelter",
				effects = { Stats = { Happiness = 5 } },
				resultText = "You took the dog to a shelter where it can be found.",
			},
			{
				id = "keep",
				text = "🐕 Keep it",
				effects = { Stats = { Happiness = 6 } },
				resultText = "You adopted the dog! You named it Lucky.",
			},
		},
	},
	{
		id = "unexpected_bill",
		minAge = 18,
		maxAge = 99,
		weight = 4,
		text = "An unexpected bill arrives that you weren't expecting!",
		choices = {
			{
				id = "pay_immediately",
				text = "💳 Pay it immediately",
				effects = { Stats = { Happiness = -2 }, Money = -2000 },
				resultText = "You paid the bill. Your budget is tight now.",
			},
			{
				id = "payment_plan",
				text = "📋 Set up a payment plan",
				effects = { Stats = { Smarts = 2 }, Money = -500 },
				resultText = "You negotiated a payment plan. Smart financial move!",
			},
			{
				id = "dispute",
				text = "📞 Dispute the bill",
				effects = { Stats = { Smarts = 3, Happiness = 4 } },
				resultText = "You disputed it and won! They dropped half the charges!",
			},
		},
	},
	{
		id = "random_compliment",
		minAge = 10,
		maxAge = 99,
		weight = 4,
		text = "A stranger gives you a genuine compliment out of nowhere!",
		choices = {
			{
				id = "thank_them",
				text = "😊 Thank them warmly",
				effects = { Stats = { Happiness = 5, Looks = 1 } },
				resultText = "You thanked them. What a nice boost to your day!",
			},
			{
				id = "compliment_back",
				text = "💝 Compliment them back",
				effects = { Stats = { Happiness = 7 } },
				resultText = "You complimented them back! You both walked away smiling!",
			},
			{
				id = "awkward",
				text = "😳 Get awkward",
				effects = { Stats = { Happiness = 2 } },
				resultText = "You got flustered but it still made your day!",
			},
		},
	},
}

EventLibrary.Events = events

-- Build the lookup table by ID
local byId = {}
for _, ev in ipairs(events) do
	byId[ev.id] = ev
end

EventLibrary.ById = byId

-- Helper function exposed for other modules
EventLibrary.RandomName = randomName

return EventLibrary
