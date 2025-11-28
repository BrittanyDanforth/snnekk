-- EventLibrary.lua
-- Defines life events and their choices (BitLife style).

local EventLibrary = {}

local events = {
	-- BABY/TODDLER EVENTS (Age 0-2)
	{
		id = "first_steps",
		minAge = 1,
		maxAge = 1,
		weight = 10,
		emoji = "👶",
		title = "First Steps!",
		text = "You're learning to walk! What's your approach?",
		choices = {
			{
				id = "take_time",
				text = "🚶 Take your time",
				effects = {
					Stats = { Health = 2, Happiness = 5 },
				},
				resultText = "You took careful steps and didn't fall! Everyone clapped!",
			},
			{
				id = "run_immediately",
				text = "🏃 Run immediately",
				effects = {
					Stats = { Health = -5, Happiness = 3 },
				},
				resultText = "You tried to run before you were ready and took a small tumble.",
			},
		},
	},
	{
		id = "first_words",
		minAge = 1,
		maxAge = 2,
		weight = 8,
		emoji = "🗣️",
		title = "First Words",
		text = "You're about to say your first word! What will it be?",
		choices = {
			{
				id = "mama",
				text = "👩 Mama",
				effects = {
					Stats = { Happiness = 5 },
				},
				resultText = "You said 'Mama'! Your mother was overjoyed and cried happy tears.",
			},
			{
				id = "dada",
				text = "👨 Dada",
				effects = {
					Stats = { Happiness = 5 },
				},
				resultText = "You said 'Dada'! Your father picked you up and spun you around.",
			},
			{
				id = "no",
				text = "🙅 No!",
				effects = {
					Stats = { Happiness = 3, Smarts = 2 },
				},
				resultText = "Your first word was 'No!' Your parents are in for a ride.",
			},
		},
	},

	-- EARLY CHILDHOOD EVENTS (Age 2-5)
	{
		id = "playground_toy",
		minAge = 2,
		maxAge = 4,
		weight = 8,
		emoji = "🧸",
		title = "Playground Drama",
		text = "Another kid at the playground steals your toy. How do you react?",
		choices = {
			{
				id = "tell_teacher",
				text = "🧑‍🏫 Tell a teacher",
				effects = {
					Stats = { Happiness = 3, Smarts = 2 },
				},
				resultText = "You told a nearby teacher. They made the kid give the toy back.",
			},
			{
				id = "swing_on_kid",
				text = "👊 Swing on the kid",
				effects = {
					Stats = { Happiness = -2, Health = -4 },
				},
				resultText = "You swung on the kid and started a tiny brawl. Staff broke it up.",
			},
			{
				id = "share",
				text = "🤝 Offer to share",
				effects = {
					Stats = { Happiness = 4, Smarts = 1 },
				},
				resultText = "You offered to share and made a new friend!",
			},
		},
	},
	{
		id = "pet_goldfish",
		minAge = 3,
		maxAge = 5,
		weight = 6,
		emoji = "🐠",
		title = "A Fishy Situation",
		text = "Your parents got you a pet goldfish named Goldie. How do you react?",
		choices = {
			{
				id = "love_it",
				text = "❤️ Love it!",
				effects = {
					Stats = { Happiness = 8 },
				},
				resultText = "You spent hours watching Goldie swim around. Pure joy!",
			},
			{
				id = "overfeed",
				text = "🍞 Feed it lots",
				effects = {
					Stats = { Happiness = -3 },
				},
				resultText = "You overfed Goldie... Let's just say Goldie is swimming in the sky now.",
			},
		},
	},
	{
		id = "first_day_school",
		minAge = 5,
		maxAge = 5,
		weight = 10,
		emoji = "🏫",
		title = "First Day of School",
		text = "It's your first day of kindergarten! How do you feel?",
		choices = {
			{
				id = "excited",
				text = "🎉 Excited!",
				effects = {
					Stats = { Happiness = 5, Smarts = 3 },
				},
				resultText = "You ran into school with a big smile and made friends immediately!",
			},
			{
				id = "scared",
				text = "😰 Scared",
				effects = {
					Stats = { Happiness = -2, Smarts = 1 },
				},
				resultText = "You clung to your parent's leg but eventually made it through the day.",
			},
			{
				id = "rebellious",
				text = "😤 I don't wanna go!",
				effects = {
					Stats = { Happiness = -3 },
				},
				resultText = "You threw a tantrum but your parents made you go anyway.",
			},
		},
	},

	-- CHILDHOOD EVENTS (Age 6-12)
	{
		id = "school_bully",
		minAge = 6,
		maxAge = 12,
		weight = 7,
		emoji = "😠",
		title = "Bully Encounter",
		text = "A bigger kid is picking on you at school. What do you do?",
		choices = {
			{
				id = "stand_up",
				text = "💪 Stand up to them",
				effects = {
					Stats = { Happiness = 5, Health = -3 },
				},
				resultText = "You stood your ground! The bully was surprised and left you alone.",
			},
			{
				id = "tell_adult",
				text = "👨‍🏫 Tell an adult",
				effects = {
					Stats = { Happiness = 2, Smarts = 2 },
				},
				resultText = "The teacher handled it. Smart move!",
			},
			{
				id = "run_away",
				text = "🏃 Run away",
				effects = {
					Stats = { Happiness = -4, Health = 2 },
				},
				resultText = "You escaped but the bully might come back...",
			},
		},
	},
	{
		id = "lost_tooth",
		minAge = 6,
		maxAge = 8,
		weight = 8,
		emoji = "🦷",
		title = "Tooth Fairy Time",
		text = "You lost your first tooth! What do you do with it?",
		choices = {
			{
				id = "under_pillow",
				text = "💫 Put it under your pillow",
				effects = {
					Stats = { Happiness = 5 },
					Money = 5,
				},
				resultText = "The tooth fairy left you $5! Magic is real!",
			},
			{
				id = "keep_it",
				text = "🗃️ Keep it as a trophy",
				effects = {
					Stats = { Happiness = 2 },
				},
				resultText = "You added it to your collection. Kinda weird, but okay.",
			},
		},
	},
	{
		id = "science_fair",
		minAge = 8,
		maxAge = 12,
		weight = 6,
		emoji = "🔬",
		title = "Science Fair",
		text = "The science fair is coming up! What project do you choose?",
		choices = {
			{
				id = "volcano",
				text = "🌋 Classic volcano",
				effects = {
					Stats = { Smarts = 3, Happiness = 3 },
				},
				resultText = "Your volcano erupted perfectly! The judges were impressed.",
			},
			{
				id = "plant_growth",
				text = "🌱 Plant growth experiment",
				effects = {
					Stats = { Smarts = 5 },
				},
				resultText = "Your methodical approach won you second place!",
			},
			{
				id = "skip_it",
				text = "🙄 Skip it",
				effects = {
					Stats = { Smarts = -3, Happiness = 2 },
				},
				resultText = "You skipped the fair and played video games instead.",
			},
		},
	},
	{
		id = "birthday_party",
		minAge = 7,
		maxAge = 12,
		weight = 5,
		emoji = "🎂",
		title = "Birthday Party",
		text = "It's your birthday! What kind of party do you want?",
		choices = {
			{
				id = "big_party",
				text = "🎉 Huge party with everyone!",
				effects = {
					Stats = { Happiness = 8 },
				},
				resultText = "You had an amazing party with all your friends!",
			},
			{
				id = "small_party",
				text = "👥 Small party with close friends",
				effects = {
					Stats = { Happiness = 5 },
				},
				resultText = "You had a cozy celebration with your best friends.",
			},
			{
				id = "no_party",
				text = "🎮 Just video games",
				effects = {
					Stats = { Happiness = 3, Smarts = 1 },
				},
				resultText = "You spent your birthday gaming. No regrets!",
			},
		},
	},

	-- TEEN EVENTS (Age 13-17)
	{
		id = "first_crush",
		minAge = 13,
		maxAge = 16,
		weight = 7,
		emoji = "💕",
		title = "First Crush",
		text = "You have a crush on someone at school! What do you do?",
		choices = {
			{
				id = "confess",
				text = "💌 Confess your feelings",
				effects = {
					Stats = { Happiness = 3, Looks = 2 },
				},
				resultText = "They said they like you too! Your heart is racing!",
			},
			{
				id = "admire_afar",
				text = "👀 Admire from afar",
				effects = {
					Stats = { Happiness = -2 },
				},
				resultText = "You never said anything and they started dating someone else.",
			},
			{
				id = "friend_help",
				text = "🤝 Ask a friend to help",
				effects = {
					Stats = { Happiness = 4 },
				},
				resultText = "Your friend set you up! You're going on your first date!",
			},
		},
	},
	{
		id = "driving_test",
		minAge = 16,
		maxAge = 17,
		weight = 9,
		emoji = "🚗",
		title = "Driving Test",
		text = "Time for your driving test! How do you prepare?",
		choices = {
			{
				id = "study_hard",
				text = "📚 Study hard",
				effects = {
					Stats = { Smarts = 3, Happiness = 5 },
				},
				resultText = "You passed with flying colors! Freedom awaits!",
			},
			{
				id = "wing_it",
				text = "🤷 Wing it",
				effects = {
					Stats = { Happiness = -3 },
				},
				resultText = "You failed. Parallel parking got you.",
			},
		},
	},
	{
		id = "party_invite",
		minAge = 15,
		maxAge = 17,
		weight = 6,
		emoji = "🎊",
		title = "Party Invitation",
		text = "You're invited to a party where there might be trouble. What do you do?",
		choices = {
			{
				id = "go_party",
				text = "🕺 Go and have fun",
				effects = {
					Stats = { Happiness = 5, Health = -2 },
				},
				resultText = "You had a blast but stayed up way too late.",
			},
			{
				id = "stay_home",
				text = "🏠 Stay home",
				effects = {
					Stats = { Smarts = 3, Happiness = -2 },
				},
				resultText = "You stayed home and studied. Boring but responsible.",
			},
			{
				id = "go_leave_early",
				text = "⏰ Go but leave early",
				effects = {
					Stats = { Happiness = 3, Smarts = 1 },
				},
				resultText = "You showed up, had fun, and left before things got crazy.",
			},
		},
	},

	-- RELATIONSHIP EVENTS
	{
		id = "friend_unfriended",
		minAge = 8,
		maxAge = 50,
		weight = 4,
		emoji = "😢",
		title = "Unfriended",
		text = "Your best friend has unfriended you.\nWhat will you do?",
		showRelationship = true,
		relationName = "Bradley Allen",
		relationship = "Best Friend",
		choices = {
			{
				id = "insult",
				text = "😤 Insult him one last time",
				effects = {
					Stats = { Happiness = -5 },
				},
				resultText = "You said some things you might regret later...",
			},
			{
				id = "let_go",
				text = "👋 Let him go",
				effects = {
					Stats = { Happiness = -3, Smarts = 2 },
				},
				resultText = "Sometimes people grow apart. That's life.",
			},
			{
				id = "salvage",
				text = "🤝 Try to salvage our friendship",
				effects = {
					Stats = { Happiness = 4 },
				},
				resultText = "You reached out and patched things up. Friends again!",
			},
		},
	},
	{
		id = "new_sibling",
		minAge = 3,
		maxAge = 15,
		weight = 3,
		emoji = "👶",
		title = "New Sibling!",
		text = "Your parents just had a baby! How do you feel?",
		choices = {
			{
				id = "excited",
				text = "🎉 So excited!",
				effects = {
					Stats = { Happiness = 6 },
				},
				resultText = "You can't wait to be a big brother/sister!",
			},
			{
				id = "jealous",
				text = "😒 Jealous...",
				effects = {
					Stats = { Happiness = -4 },
				},
				resultText = "You're worried your parents will forget about you.",
			},
			{
				id = "indifferent",
				text = "🤷 Whatever",
				effects = {
					Stats = { Happiness = 0 },
				},
				resultText = "Another mouth to feed. Your allowance might suffer.",
			},
		},
	},

	-- ADULT EVENTS (Age 18+)
	{
		id = "college_choice",
		minAge = 18,
		maxAge = 18,
		weight = 10,
		emoji = "🎓",
		title = "College Decision",
		text = "High school is over! What's next?",
		choices = {
			{
				id = "university",
				text = "🏛️ Go to university",
				effects = {
					Stats = { Smarts = 8 },
					Money = -5000,
				},
				resultText = "You enrolled in university! Student loans incoming.",
			},
			{
				id = "trade_school",
				text = "🔧 Trade school",
				effects = {
					Stats = { Smarts = 4 },
					Money = -1000,
				},
				resultText = "You learned a valuable trade!",
			},
			{
				id = "work",
				text = "💼 Start working",
				effects = {
					Stats = { Happiness = -2 },
					Money = 500,
				},
				resultText = "You started working right away. The grind begins.",
			},
		},
	},
	{
		id = "job_offer",
		minAge = 20,
		maxAge = 60,
		weight = 5,
		emoji = "💼",
		title = "Job Offer",
		text = "You received a job offer! It pays well but requires long hours.",
		choices = {
			{
				id = "accept",
				text = "✅ Accept the offer",
				effects = {
					Stats = { Happiness = -2, Smarts = 2 },
					Money = 2000,
				},
				resultText = "You took the job! Time to work hard.",
			},
			{
				id = "decline",
				text = "❌ Decline",
				effects = {
					Stats = { Happiness = 2 },
				},
				resultText = "You declined. Work-life balance is important.",
			},
			{
				id = "negotiate",
				text = "💰 Negotiate for more",
				effects = {
					Stats = { Smarts = 3 },
					Money = 3000,
				},
				resultText = "You negotiated a better deal! Big brain move.",
			},
		},
	},
	{
		id = "lottery_ticket",
		minAge = 18,
		maxAge = 80,
		weight = 2,
		emoji = "🎰",
		title = "Feeling Lucky?",
		text = "You found $5 on the ground. Buy a lottery ticket?",
		choices = {
			{
				id = "buy_ticket",
				text = "🎟️ Buy a ticket",
				effects = {
					Stats = { Happiness = math.random(-5, 10) },
					Money = math.random(-5, 100),
				},
				resultText = "You bought a ticket! Let's see if luck is on your side...",
			},
			{
				id = "keep_money",
				text = "💵 Keep the $5",
				effects = {
					Money = 5,
				},
				resultText = "You kept the money. Safe and sound.",
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
