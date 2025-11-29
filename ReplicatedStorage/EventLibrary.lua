-- EventLibrary.lua
-- Defines life events and their choices for all ages.

local EventLibrary = {}

local events = {
	-- AGE 1
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

	-- AGE 2-4 (Toddler)
	{
		id = "playground_toy",
		minAge = 2,
		maxAge = 4,
		weight = 8,
		text = "Another kid at the playground steals your toy. How do you react?",
		choices = {
			{
				id = "tell_teacher",
				text = "🧑‍🏫 Tell a teacher",
				effects = { Stats = { Happiness = 3, Smarts = 2 } },
				resultText = "You told a nearby teacher. They made the kid give the toy back.",
			},
			{
				id = "swing_on_kid",
				text = "👊 Swing on the kid",
				effects = { Stats = { Happiness = -2, Health = -4 } },
				resultText = "You swung on the kid and started a tiny brawl. Staff broke it up.",
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

	-- AGE 5-10 (Childhood)
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

	-- AGE 10-15 (Pre-teen)
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

	-- AGE 13-18 (Teenager)
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
		},
	},

	-- AGE 18-30 (Young Adult)
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

	-- AGE 30+ (Adult)
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
}

EventLibrary.Events = events

local byId = {}
for _, ev in ipairs(events) do
	byId[ev.id] = ev
end

EventLibrary.ById = byId

return EventLibrary
