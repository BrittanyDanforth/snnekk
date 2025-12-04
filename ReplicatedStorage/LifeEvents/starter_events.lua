--[[
	starter_events.lua
	Core BitLife-style events to get the game going
	
	Categories: family, health, school, social, romance, work, money, crime, milestone
]]

local events = {
	--------------------------------------------------------------------------------
	-- CHILDHOOD EVENTS (Ages 0-12)
	--------------------------------------------------------------------------------
	{
		id = "first_word",
		emoji = "👶",
		title = "Baby's First Word!",
		text = "You spoke your first word today! Your parents are overjoyed.",
		category = "milestone",
		milestone = true,
		oneTime = true,
		weight = 100,
		conditions = { minAge = 1, maxAge = 2 },
		choices = {
			{ text = "Mama!", effects = { Happiness = 5 }, resultText = "Your mother burst into happy tears!" },
			{ text = "Dada!", effects = { Happiness = 5 }, resultText = "Your father couldn't stop smiling!" },
			{ text = "Cookie!", effects = { Happiness = 8 }, resultText = "Well, at least you know what you want!" },
		},
	},
	{
		id = "learn_to_walk",
		emoji = "🚶",
		title = "First Steps!",
		text = "You're standing up and trying to walk! This is a big moment.",
		category = "milestone",
		milestone = true,
		oneTime = true,
		weight = 100,
		conditions = { minAge = 1, maxAge = 2 },
		choices = {
			{ text = "Take a step!", effects = { Health = 5, Happiness = 5 }, resultText = "You took your first wobbly steps!" },
		},
	},
	{
		id = "playground_friend",
		emoji = "🤝",
		title = "Playground Friend",
		text = "A kid at the playground wants to be your friend! They seem nice.",
		category = "social",
		weight = 40,
		conditions = { minAge = 4, maxAge = 10 },
		choices = {
			{ text = "Be their friend!", effects = { Happiness = 10 }, resultText = "You made a new friend!", flags = { set = { "has_friend" } } },
			{ text = "I prefer to play alone", effects = { Happiness = -5 }, resultText = "You walked away..." },
		},
	},
	{
		id = "birthday_party",
		emoji = "🎂",
		title = "Birthday Party!",
		text = "It's your birthday! Your parents threw you a party with all your friends.",
		category = "family",
		weight = 60,
		conditions = { minAge = 5, maxAge = 12 },
		choices = {
			{ text = "Open presents!", effects = { Happiness = 15 }, resultText = "You got so many cool presents!" },
			{ text = "Eat cake first!", effects = { Happiness = 12, Health = -2 }, resultText = "The cake was delicious!" },
		},
	},
	{
		id = "school_bully",
		emoji = "😰",
		title = "School Bully",
		text = "A bigger kid at school is picking on you. They're demanding your lunch money.",
		category = "school",
		weight = 30,
		conditions = { minAge = 6, maxAge = 14 },
		choices = {
			{ text = "Give them the money", effects = { Happiness = -10, Money = -5 }, resultText = "They took your money and laughed..." },
			{ text = "Stand up for yourself", effects = { Happiness = 5, Health = -10 }, resultText = "You fought back! Got some bruises but kept your dignity." },
			{ text = "Tell a teacher", effects = { Happiness = 5 }, resultText = "The bully got in trouble!" },
		},
	},
	{
		id = "good_grades",
		emoji = "📚",
		title = "Report Card",
		text = "You got your report card today. Your teacher says you're doing well!",
		category = "school",
		weight = 35,
		conditions = { minAge = 6, maxAge = 17 },
		choices = {
			{ text = "Show parents!", effects = { Happiness = 10, Smarts = 5 }, resultText = "Your parents are so proud!" },
			{ text = "Study even harder", effects = { Smarts = 10, Happiness = -5 }, resultText = "You doubled down on studying." },
		},
	},

	--------------------------------------------------------------------------------
	-- TEEN EVENTS (Ages 13-17)
	--------------------------------------------------------------------------------
	{
		id = "first_crush",
		emoji = "💕",
		title = "First Crush",
		text = "You've developed a crush on someone at school. Your heart races whenever you see them!",
		category = "romance",
		oneTime = true,
		weight = 50,
		conditions = { minAge = 13, maxAge = 16 },
		choices = {
			{ text = "Tell them how you feel!", effects = { Happiness = 15 }, resultText = "They said they like you too!", flags = { set = { "had_first_crush" } } },
			{ text = "Admire from afar", effects = { Happiness = -5 }, resultText = "You stayed quiet, wondering 'what if'..." },
			{ text = "Write them a note", effects = { Happiness = 10 }, resultText = "They read your note and smiled!" },
		},
	},
	{
		id = "part_time_job_offer",
		emoji = "💼",
		title = "Job Offer",
		text = "The local store is hiring teens for part-time work. The pay isn't great, but it's something!",
		category = "work",
		weight = 40,
		conditions = { minAge = 14, maxAge = 17 },
		requiresFlag = nil,
		choices = {
			{ text = "Take the job!", effects = { Money = 200, Happiness = 5 }, resultText = "You started working part-time!", flags = { set = { "ever_worked" } } },
			{ text = "Focus on school", effects = { Smarts = 5 }, resultText = "You decided school is more important for now." },
		},
	},
	{
		id = "house_party",
		emoji = "🎉",
		title = "House Party",
		text = "Someone from school is throwing a party while their parents are away. You're invited!",
		category = "social",
		weight = 35,
		conditions = { minAge = 15, maxAge = 19 },
		choices = {
			{ text = "Party hard!", effects = { Happiness = 15, Health = -5, Smarts = -3 }, resultText = "That was an epic night!" },
			{ text = "Go but stay sober", effects = { Happiness = 8 }, resultText = "You had fun and stayed responsible." },
			{ text = "Skip it", effects = { Happiness = -5, Smarts = 3 }, resultText = "You stayed home and studied instead." },
		},
	},
	{
		id = "driving_lessons",
		emoji = "🚗",
		title = "Driving Lessons",
		text = "You're old enough to learn to drive! Want to take lessons?",
		category = "milestone",
		oneTime = true,
		weight = 80,
		conditions = { minAge = 16, maxAge = 16 },
		choices = {
			{ text = "Yes, teach me!", effects = { Happiness = 10, Money = -500 }, resultText = "You got your driver's license!", flags = { set = { "can_drive" } } },
			{ text = "Not interested", effects = {}, resultText = "You decided not to learn driving yet." },
		},
	},

	--------------------------------------------------------------------------------
	-- YOUNG ADULT EVENTS (Ages 18-29)
	--------------------------------------------------------------------------------
	{
		id = "college_decision",
		emoji = "🎓",
		title = "College Decision",
		text = "You've graduated high school! What's next for your education?",
		category = "milestone",
		milestone = true,
		oneTime = true,
		weight = 100,
		conditions = { minAge = 18, maxAge = 18 },
		choices = {
			{ text = "Apply to University", effects = { Smarts = 5, Money = -2000 }, resultText = "You applied and got accepted!", flags = { set = { "college_bound" } } },
			{ text = "Go to Community College", effects = { Smarts = 3, Money = -500 }, resultText = "Community college it is!" },
			{ text = "Start working", effects = { Money = 1000 }, resultText = "You entered the workforce right away." },
		},
	},
	{
		id = "first_apartment",
		emoji = "🏠",
		title = "First Apartment",
		text = "You found an apartment you can afford! Ready to move out of your parents' house?",
		category = "milestone",
		oneTime = true,
		weight = 60,
		conditions = { minAge = 18, maxAge = 25 },
		choices = {
			{ text = "Move out!", effects = { Happiness = 15, Money = -2000 }, resultText = "You're finally independent!", flags = { set = { "moved_out" } } },
			{ text = "Stay home longer", effects = { Money = 500 }, resultText = "You saved money by staying home." },
		},
	},
	{
		id = "job_interview",
		emoji = "👔",
		title = "Job Interview",
		text = "A company wants to interview you for a position! This could be your big break.",
		category = "work",
		weight = 45,
		conditions = { minAge = 18, maxAge = 50 },
		choices = {
			{ text = "Nail the interview!", effects = { Happiness = 15, Money = 500 }, resultText = "You got the job!" },
			{ text = "Be myself", effects = { Happiness = 10 }, resultText = "It went well. They said they'll call you back." },
			{ text = "Nervous wreck", effects = { Happiness = -10 }, resultText = "You were too nervous and blew it..." },
		},
	},
	{
		id = "random_lottery",
		emoji = "🎰",
		title = "Lottery Ticket",
		text = "You found a lottery ticket on the ground. Want to check if it's a winner?",
		category = "money",
		weight = 15,
		conditions = { minAge = 18, maxAge = 99 },
		choices = {
			{ text = "Check the numbers!", effects = { Money = 1000, Happiness = 20 }, resultText = "Holy cow! You won $1,000!" },
			{ text = "Throw it away", effects = {}, resultText = "You tossed it in the trash. Could've been a winner..." },
		},
	},

	--------------------------------------------------------------------------------
	-- ADULT EVENTS (Ages 30+)
	--------------------------------------------------------------------------------
	{
		id = "midlife_reflection",
		emoji = "🤔",
		title = "Midlife Thoughts",
		text = "You're thinking about your life choices. Are you happy with where you are?",
		category = "milestone",
		weight = 30,
		conditions = { minAge = 40, maxAge = 50 },
		choices = {
			{ text = "I'm content", effects = { Happiness = 10 }, resultText = "You appreciate what you have." },
			{ text = "Time for a change!", effects = { Happiness = 5 }, resultText = "You decided to shake things up!", flags = { set = { "seeking_change" } } },
			{ text = "Feel regret", effects = { Happiness = -15 }, resultText = "You wished you'd made different choices..." },
		},
	},
	{
		id = "health_checkup",
		emoji = "🏥",
		title = "Doctor Visit",
		text = "Time for your annual checkup. The doctor wants to see you.",
		category = "health",
		weight = 40,
		conditions = { minAge = 30, maxAge = 99 },
		choices = {
			{ text = "Go to the appointment", effects = { Health = 10, Money = -200 }, resultText = "Clean bill of health! Keep it up." },
			{ text = "Skip it", effects = { Happiness = 5 }, resultText = "You hate doctor visits anyway." },
		},
	},

	--------------------------------------------------------------------------------
	-- SENIOR EVENTS (Ages 65+)
	--------------------------------------------------------------------------------
	{
		id = "retirement_decision",
		emoji = "🏖️",
		title = "Retirement",
		text = "You've reached retirement age. Ready to hang up your work boots?",
		category = "milestone",
		milestone = true,
		oneTime = true,
		weight = 100,
		conditions = { minAge = 65, maxAge = 65 },
		choices = {
			{ text = "Time to retire!", effects = { Happiness = 20 }, resultText = "Ahh, freedom at last!", flags = { set = { "retired" } } },
			{ text = "Keep working", effects = { Money = 5000 }, resultText = "You love what you do too much to quit." },
		},
	},
	{
		id = "grandchildren",
		emoji = "👶",
		title = "Grandparent!",
		text = "Your child just had a baby! You're a grandparent now!",
		category = "family",
		milestone = true,
		oneTime = true,
		weight = 70,
		conditions = { minAge = 50, maxAge = 80 },
		requiresFlag = "has_children",
		choices = {
			{ text = "So happy!", effects = { Happiness = 25 }, resultText = "You held your grandchild for the first time!", flags = { set = { "grandparent" } } },
		},
	},

	--------------------------------------------------------------------------------
	-- RANDOM EVENTS (Any Age)
	--------------------------------------------------------------------------------
	{
		id = "found_money",
		emoji = "💵",
		title = "Found Money!",
		text = "You found some cash on the ground! Looks like someone dropped it.",
		category = "money",
		weight = 20,
		conditions = { minAge = 5, maxAge = 99 },
		choices = {
			{ text = "Keep it!", effects = { Money = 50, Happiness = 5 }, resultText = "Finders keepers!" },
			{ text = "Turn it in", effects = { Happiness = 10 }, resultText = "You did the right thing!" },
		},
	},
	{
		id = "caught_cold",
		emoji = "🤧",
		title = "Caught a Cold",
		text = "Achoo! You're not feeling well. Looks like you caught a cold.",
		category = "health",
		weight = 25,
		conditions = { minAge = 3, maxAge = 99 },
		choices = {
			{ text = "Rest up", effects = { Health = -5, Happiness = -5 }, resultText = "You stayed in bed for a few days." },
			{ text = "Power through", effects = { Health = -10, Happiness = -10 }, resultText = "You made it worse by not resting..." },
		},
	},
	{
		id = "random_compliment",
		emoji = "😊",
		title = "Nice Compliment",
		text = "A stranger gave you a genuine compliment today. It made you feel good!",
		category = "social",
		weight = 30,
		conditions = { minAge = 10, maxAge = 99 },
		choices = {
			{ text = "Thanks!", effects = { Happiness = 10, Looks = 2 }, resultText = "You felt confident the rest of the day!" },
		},
	},
}

return { events = events }
