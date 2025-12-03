-- general_events.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- COMPREHENSIVE LIFE EVENTS - Linked to All Game Screens
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- This file contains life events that are properly linked to:
-- • RelationshipsScreen (friends, family, romance, enemies)
-- • OccupationScreen (careers, education, jobs)
-- • ActivitiesScreen (activities, crime, prison)
-- • AssetsScreen (property, vehicles, shopping)
-- • StoryPathsScreen (life paths and milestones)
--
-- IMPORTANT: Names are generated at runtime using RelationshipService, NOT hardcoded placeholders!
--
-- ═══════════════════════════════════════════════════════════════════════════════

local events = {}

-- ═══════════════════════════════════════════════════════════════════════════════
-- HELPER: Name generation (uses RelationshipService patterns)
-- ═══════════════════════════════════════════════════════════════════════════════

local MaleNames = {
	"James", "Michael", "David", "Chris", "Daniel", "Matt", "Jake", "Ryan", "Tyler",
	"Kevin", "Justin", "Josh", "Nick", "Alex", "Brian", "Eric", "Andrew", "Sean",
	"Adam", "Ethan", "Nathan", "Dylan", "Connor", "Mason", "Logan", "Lucas", "Liam"
}

local FemaleNames = {
	"Emma", "Sophia", "Olivia", "Ava", "Isabella", "Mia", "Emily", "Abigail", "Madison",
	"Ella", "Chloe", "Sofia", "Grace", "Lily", "Hannah", "Aria", "Zoe", "Riley",
	"Nora", "Scarlett", "Luna", "Hazel", "Charlotte", "Amelia", "Harper", "Evelyn"
}

local LastNames = {
	"Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis",
	"Martinez", "Anderson", "Taylor", "Thomas", "Jackson", "White", "Harris", "Clark"
}

local function randomMaleName()
	return MaleNames[math.random(#MaleNames)] .. " " .. LastNames[math.random(#LastNames)]
end

local function randomFemaleName()
	return FemaleNames[math.random(#FemaleNames)] .. " " .. LastNames[math.random(#LastNames)]
end

local function randomName()
	return math.random(2) == 1 and randomMaleName() or randomFemaleName()
end

local function randomFirstName()
	local names = math.random(2) == 1 and MaleNames or FemaleNames
	return names[math.random(#names)]
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 1: CHILDHOOD EVENTS (Ages 0-12)
-- These events establish early life and first relationships
-- ═══════════════════════════════════════════════════════════════════════════════

table.insert(events, {
	id = "childhood_first_friend",
	emoji = "👫",
	title = "Your First Friend",
	category = "social",
	tags = {"childhood", "relationships", "friend", "milestone"},
	
	weight = 20,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 4,
		maxAge = 7,
		blockedFlags = {"has_first_friend"},
	},
	
	getDynamicData = function(state)
		-- Generate a real name at runtime
		local friendName = randomName()
		return {
			friendName = friendName,
			location = ({"playground", "kindergarten", "the park", "your neighborhood"})[math.random(4)]
		}
	end,
	
	text = "At %location%, you meet %friendName%. They share their snacks with you and you play together all afternoon. It feels like you've known each other forever!",
	
	choices = {
		{
			id = "best_friends",
			text = "This is the best day ever! You want to be friends forever!",
			resultText = "You and %friendName% become inseparable. Your parents arrange playdates every week. You've made your first real friend!",
			effects = {Happiness = 15},
			setFlags = {"has_first_friend", "has_friend", "social_kid"},
			-- Use dynamicNameKey to get the actual generated name from getDynamicData
			addRelationship = {type = "friend", role = "Best Friend", startingRelationship = 75, dynamicNameKey = "friendName"},
		},
		{
			id = "shy_response",
			text = "You're too shy to really open up, but it was nice.",
			resultText = "You had fun, but you're not sure if they'll want to play again. Maybe next time you'll be braver.",
			effects = {Happiness = 5},
			setFlags = {"shy_kid"},
		},
	},
})

table.insert(events, {
	id = "childhood_birthday_party",
	emoji = "🎂",
	title = "Birthday Party",
	category = "social",
	tags = {"childhood", "social", "family"},
	
	weight = 15,
	cooldownYears = 2,
	
	conditions = {
		minAge = 5,
		maxAge = 12,
	},
	
	getDynamicData = function(state)
		local age = state.Age or 5
		return {
			age = age,
			guests = math.random(5, 15),
		}
	end,
	
	text = "It's your %age%th birthday! Your parents throw you a party with %guests% guests, cake, and presents!",
	
	choices = {
		{
			id = "love_it",
			text = "This is the best birthday ever!",
			resultText = "You blow out the candles, open presents, and play with all your friends. What a perfect day!",
			effects = {Happiness = 20, Money = 50},
			setFlags = {"had_birthday_party"},
		},
		{
			id = "want_more",
			text = "The presents are okay... but you wanted more.",
			resultText = "You're a bit disappointed. Maybe next year will be better.",
			effects = {Happiness = 5, Money = 30},
			setFlags = {"materialistic_tendencies"},
		},
	},
})

table.insert(events, {
	id = "childhood_school_start",
	emoji = "🏫",
	title = "First Day of School",
	category = "education",
	tags = {"childhood", "education", "milestone"},
	
	weight = 20,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 5,
		maxAge = 6,
		blockedFlags = {"started_school"},
	},
	
	getDynamicData = function(state)
		local schools = {"Lincoln Elementary", "Washington Elementary", "Jefferson Primary", "Central Elementary"}
		return {
			school = schools[math.random(#schools)],
			teacherName = randomFemaleName(),
		}
	end,
	
	text = "Today is your first day at %school%! Your teacher, %teacherName%, greets you at the classroom door. The room is filled with colorful decorations and other nervous kids.",
	
	choices = {
		{
			id = "excited",
			text = "You're so excited! You wave goodbye to your parents and run in!",
			resultText = "You make friends immediately and love learning new things. School is going to be great!",
			effects = {Happiness = 10, Smarts = 5},
			setFlags = {"started_school", "loves_school", "in_school"},
		},
		{
			id = "nervous",
			text = "You cling to your parent's hand, not wanting them to leave.",
			resultText = "It's scary at first, but your teacher is kind and the other kids are friendly. By lunchtime, you feel better.",
			effects = {Happiness = 3, Smarts = 3},
			setFlags = {"started_school", "in_school", "school_anxiety"},
		},
		{
			id = "cry",
			text = "You cry and refuse to let go.",
			resultText = "Your parents have to pry themselves away. It's a rough start, but eventually you calm down.",
			effects = {Happiness = -5, Smarts = 2},
			setFlags = {"started_school", "in_school", "separation_anxiety"},
		},
	},
})

table.insert(events, {
	id = "childhood_pet_adoption",
	emoji = "🐕",
	title = "A New Family Member",
	category = "family",
	tags = {"childhood", "family", "pets", "milestone"},
	
	weight = 12,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 5,
		maxAge = 14,
		blockedFlags = {"has_pet"},
	},
	
	getDynamicData = function(state)
		local pets = {
			{type = "puppy", emoji = "🐕", names = {"Max", "Buddy", "Charlie", "Cooper", "Rocky"}},
			{type = "kitten", emoji = "🐈", names = {"Luna", "Bella", "Milo", "Oliver", "Leo"}},
			{type = "hamster", emoji = "🐹", names = {"Nibbles", "Squeaky", "Fuzzy", "Peanut", "Whiskers"}},
		}
		local pet = pets[math.random(#pets)]
		return {
			petType = pet.type,
			petEmoji = pet.emoji,
			petName = pet.names[math.random(#pet.names)],
		}
	end,
	
	text = "Your parents surprise you with a %petType%! %petEmoji% The little ball of fur looks up at you with big eyes.",
	
	choices = {
		{
			id = "love_it",
			text = "You're SO HAPPY! You immediately name them %petName%!",
			resultText = "%petName% becomes your best friend. You promise to take care of them forever!",
			effects = {Happiness = 20},
			setFlags = {"has_pet", "pet_lover", "responsible_kid"},
		},
		{
			id = "wanted_different",
			text = "It's cute... but you wanted something different.",
			resultText = "You still take care of your new pet, but you can't help feeling a little disappointed.",
			effects = {Happiness = 5},
			setFlags = {"has_pet"},
		},
	},
})

table.insert(events, {
	id = "childhood_bullied",
	emoji = "😢",
	title = "The Bully",
	category = "social",
	tags = {"childhood", "social", "conflict", "school"},
	
	weight = 10,
	cooldownYears = 3,
	
	conditions = {
		minAge = 6,
		maxAge = 14,
		requiredAllFlags = {"in_school"},
	},
	
	getDynamicData = function(state)
		return {
			bullyName = randomName(),
		}
	end,
	
	text = "%bullyName% has been picking on you at school. They call you names and make fun of you in front of others. Today they pushed you in the hallway.",
	
	choices = {
		{
			id = "tell_adult",
			text = "Tell a teacher or your parents.",
			resultText = "Your teacher talks to %bullyName% and their parents. The bullying stops, but they still glare at you sometimes.",
			effects = {Happiness = 5},
			setFlags = {"stood_up_to_bully", "trusts_adults"},
		},
		{
			id = "fight_back",
			text = "Push them back! You've had enough!",
			resultText = "You shove %bullyName% and they fall. You both get in trouble, but they never bother you again.",
			effects = {Happiness = 3, Health = -5},
			setFlags = {"fought_back", "aggressive_kid"},
		},
		{
			id = "do_nothing",
			text = "Just ignore it and walk away.",
			resultText = "You try to act like it doesn't bother you, but it does. You dread going to school.",
			effects = {Happiness = -10},
			setFlags = {"bullied", "low_confidence"},
		},
	},
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 2: TEEN EVENTS (Ages 13-17)
-- Dating, high school, identity formation
-- ═══════════════════════════════════════════════════════════════════════════════

table.insert(events, {
	id = "teen_high_school_start",
	emoji = "🎒",
	title = "High School Begins",
	category = "education",
	tags = {"teen", "education", "milestone"},
	
	weight = 20,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 14,
		maxAge = 15,
		blockedFlags = {"started_high_school"},
	},
	
	getDynamicData = function(state)
		local schools = {"Lincoln High", "Washington High", "Jefferson Academy", "Central High", "Westview High"}
		return {
			school = schools[math.random(#schools)],
		}
	end,
	
	text = "You're starting high school at %school%! The building is huge, the older kids look intimidating, and you have no idea where your classes are.",
	
	choices = {
		{
			id = "confident",
			text = "Walk in with confidence. You've got this!",
			resultText = "You find your classes, meet new people, and even sit with some cool kids at lunch. High school might actually be okay!",
			effects = {Happiness = 10, Smarts = 5},
			setFlags = {"started_high_school", "in_high_school", "confident_student"},
		},
		{
			id = "nervous",
			text = "Stick to yourself and try not to get noticed.",
			resultText = "You make it through the day without embarrassing yourself. Baby steps.",
			effects = {Happiness = 3, Smarts = 3},
			setFlags = {"started_high_school", "in_high_school", "quiet_student"},
		},
	},
})

table.insert(events, {
	id = "teen_first_crush",
	emoji = "💕",
	title = "First Crush",
	category = "social",
	tags = {"teen", "romance", "relationships", "milestone"},
	
	weight = 15,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 13,
		maxAge = 16,
		blockedFlags = {"had_first_crush"},
	},
	
	getDynamicData = function(state)
		return {
			crushName = randomName(),
		}
	end,
	
	text = "You can't stop thinking about %crushName%. They're in your class and every time they look your way, your heart races. You think you might have a crush!",
	
	choices = {
		{
			id = "confess",
			text = "Work up the courage to talk to them.",
			chanceSuccess = 0.50,
			resultTextSuccess = "%crushName% smiles and says they've noticed you too! You exchange numbers and start texting. This is the best day ever!",
			resultTextFail = "They're nice but clearly not interested. It stings, but at least you tried.",
			effectsOnSuccess = {Happiness = 20},
			effectsOnFail = {Happiness = -10},
			setFlags = {"had_first_crush", "brave_in_love"},
		},
		{
			id = "admire_afar",
			text = "Admire them from afar. Too scared to talk.",
			resultText = "You spend weeks daydreaming about %crushName%, but never say a word. Eventually, the crush fades.",
			effects = {Happiness = 0},
			setFlags = {"had_first_crush", "shy_romantic"},
		},
	},
})

table.insert(events, {
	id = "teen_part_time_job",
	emoji = "💼",
	title = "First Job Opportunity",
	category = "career",
	tags = {"teen", "career", "money"},
	
	weight = 12,
	oneTime = true,
	
	conditions = {
		minAge = 15,
		maxAge = 18,
		blockedFlags = {"has_first_job"},
	},
	
	getDynamicData = function(state)
		local jobs = {
			{name = "Fast Food Worker", pay = 8, place = "a local burger joint"},
			{name = "Grocery Store Clerk", pay = 9, place = "the neighborhood grocery store"},
			{name = "Movie Theater Attendant", pay = 8, place = "the local cinema"},
			{name = "Retail Associate", pay = 9, place = "a clothing store at the mall"},
		}
		local job = jobs[math.random(#jobs)]
		return {
			jobTitle = job.name,
			hourlyPay = job.pay,
			workplace = job.place,
		}
	end,
	
	text = "There's a job opening for a %jobTitle% at %workplace%. The pay is $%hourlyPay%/hour. Your parents say it's up to you.",
	
	choices = {
		{
			id = "take_job",
			text = "Apply for the job! Extra money sounds great!",
			resultText = "You get hired! It's hard work balancing school and your job, but the paycheck feels amazing.",
			effects = {Money = 500, Happiness = 5},
			setFlags = {"has_first_job", "employed", "responsible_teen", "work_experience"},
		},
		{
			id = "decline",
			text = "Focus on school instead.",
			resultText = "You decide your grades are more important right now. Maybe later.",
			effects = {Smarts = 5},
			setFlags = {"academic_focused"},
		},
	},
})

table.insert(events, {
	id = "teen_drivers_license",
	emoji = "🚗",
	title = "Learning to Drive",
	category = "life",
	tags = {"teen", "milestone", "driving"},
	
	weight = 20,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 16,
		maxAge = 18,
		blockedFlags = {"has_license"},
	},
	
	getDynamicData = function(state)
		return {
			instructor = math.random(2) == 1 and "your parent" or "a driving instructor",
		}
	end,
	
	text = "It's time to learn to drive! %instructor% takes you out for lessons. Your hands are shaking as you grip the steering wheel for the first time.",
	
	choices = {
		{
			id = "natural",
			text = "You're a natural! Smooth driving from the start.",
			resultText = "After a few lessons, you pass your test on the first try. Freedom at last!",
			effects = {Happiness = 15},
			setFlags = {"has_license", "can_drive", "good_driver", "drivers_license"},
		},
		{
			id = "struggle",
			text = "It takes practice, but you eventually get it.",
			resultText = "A few bumps along the way, but you pass your test on the second attempt. You've earned your license!",
			effects = {Happiness = 10},
			setFlags = {"has_license", "can_drive", "drivers_license"},
		},
		{
			id = "fail",
			text = "Driving is terrifying. Maybe later.",
			resultText = "You're not ready for this. Maybe when you're older.",
			effects = {Happiness = -5},
			setFlags = {"driving_anxiety"},
		},
	},
})

table.insert(events, {
	id = "teen_graduation",
	emoji = "🎓",
	title = "High School Graduation",
	category = "education",
	tags = {"teen", "education", "milestone"},
	
	weight = 25,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 17,
		maxAge = 18,
		requiredAllFlags = {"in_high_school"},
		blockedFlags = {"graduated_high_school"},
	},
	
	text = "It's graduation day! You're wearing a cap and gown, surrounded by classmates who you've known for years. Your family is in the audience, waving proudly.",
	
	choices = {
		{
			id = "celebrate",
			text = "Walk across that stage with pride!",
			resultText = "You receive your diploma to thunderous applause. High school is officially over. The world awaits!",
			effects = {Happiness = 20, Smarts = 10},
			setFlags = {"graduated_high_school", "high_school_diploma"},
		},
	},
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 3: YOUNG ADULT EVENTS (Ages 18-35)
-- College, careers, serious relationships, first home
-- ═══════════════════════════════════════════════════════════════════════════════

table.insert(events, {
	id = "adult_college_decision",
	emoji = "🏛️",
	title = "College Decision",
	category = "education",
	tags = {"adult", "education", "milestone", "career"},
	
	weight = 25,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 17,
		maxAge = 20,
		requiredAllFlags = {"graduated_high_school"},
		blockedFlags = {"college_decision_made"},
	},
	
	getDynamicData = function(state)
		local universities = {"State University", "City College", "Tech Institute", "Liberal Arts College", "Community College"}
		return {
			university = universities[math.random(#universities)],
			tuition = math.random(3, 8) * 10000,
		}
	end,
	
	text = "You've been accepted to %university%! Tuition is $%tuition% per year. This could shape your entire future.",
	
	choices = {
		{
			id = "enroll",
			text = "Enroll and pursue higher education.",
			resultText = "You pack your bags and head to college. New friends, new experiences, and a whole new chapter of life begins!",
			effects = {Happiness = 10, Money = -20000},
			setFlags = {"college_decision_made", "in_college", "enrolled", "college_student"},
		},
		{
			id = "work_instead",
			text = "Skip college. Start working right away.",
			resultText = "You decide college isn't for you. Time to enter the workforce and start earning money!",
			effects = {Happiness = 5},
			setFlags = {"college_decision_made", "skipped_college"},
		},
		{
			id = "gap_year",
			text = "Take a gap year to figure things out.",
			resultText = "You spend a year traveling, working odd jobs, and discovering yourself. Maybe college next year.",
			effects = {Happiness = 15, Money = -5000},
			setFlags = {"college_decision_made", "took_gap_year"},
		},
	},
})

table.insert(events, {
	id = "adult_first_apartment",
	emoji = "🏠",
	title = "Moving Out",
	category = "life",
	tags = {"adult", "milestone", "assets", "property"},
	
	weight = 18,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 18,
		maxAge = 28,
		blockedFlags = {"moved_out"},
		minMoney = 2000,
	},
	
	getDynamicData = function(state)
		return {
			rent = math.random(8, 15) * 100,
		}
	end,
	
	text = "You've found an apartment you can afford! It's small but it's YOURS. Rent is $%rent% per month. Are you ready for independence?",
	
	choices = {
		{
			id = "move_in",
			text = "Sign the lease and move in!",
			resultText = "You spend the weekend moving boxes. Standing in your empty apartment, you feel truly adult for the first time.",
			effects = {Happiness = 15, Money = -3000},
			setFlags = {"moved_out", "renter", "independent"},
		},
		{
			id = "stay_home",
			text = "Stay home a bit longer. Save more money.",
			resultText = "You decide to save up more before making the leap. Your parents are secretly relieved.",
			effects = {Money = 500},
			setFlags = {"living_with_parents"},
		},
	},
})

table.insert(events, {
	id = "adult_first_real_job",
	emoji = "💼",
	title = "Career Opportunity",
	category = "career",
	tags = {"adult", "career", "milestone", "occupation"},
	
	weight = 20,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 20,
		maxAge = 30,
		blockedFlags = {"has_career_job"},
	},
	
	getDynamicData = function(state)
		local jobs = {
			{title = "Office Assistant", salary = 32000, company = "a local business"},
			{title = "Customer Service Rep", salary = 35000, company = "a tech company"},
			{title = "Junior Analyst", salary = 45000, company = "a finance firm"},
			{title = "Marketing Coordinator", salary = 40000, company = "an advertising agency"},
			{title = "Sales Associate", salary = 38000, company = "a retail corporation"},
		}
		local job = jobs[math.random(#jobs)]
		return {
			jobTitle = job.title,
			salary = job.salary,
			company = job.company,
		}
	end,
	
	text = "You've been offered a position as a %jobTitle% at %company%! The salary is $%salary% per year with benefits. This is a real career opportunity.",
	
	choices = {
		{
			id = "accept",
			text = "Accept the offer! Time to start your career!",
			resultText = "You put on your nicest clothes for your first day. You're officially a working professional!",
			effects = {Happiness = 15, Money = 5000},
			setFlags = {"has_career_job", "employed", "has_job", "professional"},
		},
		{
			id = "negotiate",
			text = "Try to negotiate a higher salary.",
			chanceSuccess = 0.40,
			resultTextSuccess = "They counter with a 10% raise! Negotiating paid off!",
			resultTextFail = "They stick with their offer. Take it or leave it.",
			effectsOnSuccess = {Happiness = 20, Money = 8000},
			effectsOnFail = {Happiness = 10, Money = 5000},
			setFlags = {"has_career_job", "employed", "has_job"},
		},
	},
})

table.insert(events, {
	id = "adult_serious_relationship",
	emoji = "💑",
	title = "Finding Love",
	category = "social",
	tags = {"adult", "romance", "relationships", "milestone"},
	
	weight = 15,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 18,
		maxAge = 40,
		blockedFlags = {"in_relationship", "married"},
	},
	
	getDynamicData = function(state)
		local name = randomName()
		local meetPlaces = {"at a coffee shop", "through friends", "at work", "at a party", "on a dating app"}
		return {
			partnerName = name,
			meetPlace = meetPlaces[math.random(#meetPlaces)],
		}
	end,
	
	text = "You met %partnerName% %meetPlace% and there's definitely chemistry. After a few dates, you realize this could be something special.",
	
	choices = {
		{
			id = "commit",
			text = "Make it official! You're in a relationship!",
			resultText = "You and %partnerName% are now officially together. You can't stop smiling!",
			effects = {Happiness = 25},
			setFlags = {"in_relationship", "dating", "has_partner"},
			addRelationship = {type = "romance", role = "Partner", startingRelationship = 75, dynamicNameKey = "partnerName"},
		},
		{
			id = "keep_casual",
			text = "Keep it casual for now.",
			resultText = "You continue seeing each other without labels. Maybe someday it'll be more.",
			effects = {Happiness = 10},
			setFlags = {"casual_dating"},
		},
		{
			id = "not_ready",
			text = "You're not ready for a relationship right now.",
			resultText = "You explain that you need time. They understand, but things fizzle out.",
			effects = {Happiness = -5},
		},
	},
})

table.insert(events, {
	id = "adult_promotion",
	emoji = "📈",
	title = "Big Promotion",
	category = "career",
	tags = {"adult", "career", "money", "occupation"},
	
	weight = 12,
	cooldownYears = 3,
	
	conditions = {
		minAge = 24,
		maxAge = 55,
		requiredAnyFlags = {"has_career_job", "employed", "has_job"},
	},
	
	getDynamicData = function(state)
		local raise = math.random(5, 15) * 1000
		return {
			raiseAmount = raise,
		}
	end,
	
	text = "Your hard work has paid off! Your boss calls you in to discuss a promotion. They're offering a $%raiseAmount% raise and more responsibilities.",
	
	choices = {
		{
			id = "accept",
			text = "Accept the promotion with gratitude!",
			resultText = "Congratulations! Your new title comes with a corner office and the respect of your colleagues.",
			effects = {Happiness = 20, Money = 15000},
			setFlags = {"got_promotion", "career_success"},
		},
		{
			id = "negotiate_more",
			text = "Ask for even more money.",
			chanceSuccess = 0.30,
			resultTextSuccess = "Bold move! They agree to an even higher salary. You're a skilled negotiator!",
			resultTextFail = "They're insulted by your counter-offer. The promotion is withdrawn. You stay where you are.",
			effectsOnSuccess = {Happiness = 25, Money = 25000},
			effectsOnFail = {Happiness = -15, Money = -5000},
			setFlags = {"aggressive_negotiator"},
		},
	},
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 4: MIDDLE AGE EVENTS (Ages 35-55)
-- Family, mid-life decisions, wealth building
-- ═══════════════════════════════════════════════════════════════════════════════

table.insert(events, {
	id = "adult_buy_house",
	emoji = "🏡",
	title = "Buying a Home",
	category = "life",
	tags = {"adult", "assets", "property", "milestone"},
	
	weight = 15,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 25,
		maxAge = 50,
		blockedFlags = {"homeowner"},
		minMoney = 50000,
	},
	
	getDynamicData = function(state)
		local prices = {200000, 300000, 400000, 500000}
		return {
			housePrice = prices[math.random(#prices)],
		}
	end,
	
	text = "You've found the perfect home! It's listed at $%housePrice%. With your savings and a mortgage, you could make an offer.",
	
	choices = {
		{
			id = "buy_it",
			text = "Put in an offer! This is your dream home!",
			chanceSuccess = 0.75,
			resultTextSuccess = "Your offer is accepted! After mountains of paperwork, you get the keys to YOUR house!",
			resultTextFail = "Your offer was outbid. The housing market is brutal right now.",
			effectsOnSuccess = {Happiness = 30, Money = -75000},
			effectsOnFail = {Happiness = -10},
			setFlags = {"homeowner", "property_owner", "owns_house"},
		},
		{
			id = "keep_renting",
			text = "Keep renting for now. That's a lot of money.",
			resultText = "You decide to wait. Maybe the market will cool down.",
			effects = {Money = 5000},
		},
	},
})

table.insert(events, {
	id = "adult_marriage",
	emoji = "💒",
	title = "The Proposal",
	category = "social",
	tags = {"adult", "romance", "relationships", "milestone"},
	
	weight = 15,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 21,
		maxAge = 50,
		requiredAnyFlags = {"in_relationship", "dating", "has_partner"},
		blockedFlags = {"married", "was_married"},
	},
	
	getDynamicData = function(state)
		-- Try to get actual partner name from relationships
		local partnerName = "your partner"
		local relationships = state.Relationships or {}
		for _, rel in pairs(relationships) do
			if rel.type == "romance" and rel.alive ~= false then
				partnerName = rel.name
				break
			end
		end
		return {partnerName = partnerName}
	end,
	
	text = "You and %partnerName% have been together for a while now. The question is hanging in the air. Is it time to take the next step?",
	
	choices = {
		{
			id = "propose",
			text = "Get down on one knee and propose!",
			chanceSuccess = 0.85,
			resultTextSuccess = "%partnerName% says YES! Through tears of joy, you slip the ring on their finger. You're getting married!",
			resultTextFail = "%partnerName% says they're not ready. The rejection stings, but they still love you.",
			effectsOnSuccess = {Happiness = 40, Money = -5000},
			effectsOnFail = {Happiness = -20},
			setFlags = {"engaged"},
		},
		{
			id = "wait",
			text = "Not yet. The timing isn't right.",
			resultText = "You decide to wait. There's no rush.",
			effects = {Happiness = 0},
		},
	},
})

table.insert(events, {
	id = "adult_wedding",
	emoji = "💍",
	title = "Wedding Day",
	category = "social",
	tags = {"adult", "romance", "relationships", "milestone"},
	
	weight = 25,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 21,
		maxAge = 60,
		requiredAllFlags = {"engaged"},
		blockedFlags = {"married"},
	},
	
	getDynamicData = function(state)
		-- Try to get actual partner name from relationships
		local partnerName = "your love"
		local relationships = state.Relationships or {}
		for _, rel in pairs(relationships) do
			if rel.type == "romance" and rel.alive ~= false then
				partnerName = rel.name
				break
			end
		end
		return {
			partnerName = partnerName,
			guests = math.random(50, 200),
		}
	end,
	
	text = "The big day is here! You and %partnerName% exchange vows in front of %guests% loved ones. There's not a dry eye in the house.",
	
	choices = {
		{
			id = "celebrate",
			text = "Kiss your spouse! You're married!",
			resultText = "As you kiss, the crowd cheers. You're now husband/wife! This is the happiest day of your life.",
			effects = {Happiness = 50, Money = -15000},
			setFlags = {"married", "spouse"},
		},
	},
})

table.insert(events, {
	id = "adult_have_baby",
	emoji = "👶",
	title = "A New Life",
	category = "family",
	tags = {"adult", "family", "relationships", "milestone"},
	
	weight = 15,
	oneTime = false,
	cooldownYears = 3,
	milestone = true,
	
	conditions = {
		minAge = 22,
		maxAge = 45,
		requiredAnyFlags = {"married", "in_relationship"},
		blockedFlags = {"pregnant"},
	},
	
	getDynamicData = function(state)
		local gender = math.random(2) == 1 and "boy" or "girl"
		local names = gender == "boy" and MaleNames or FemaleNames
		return {
			babyGender = gender,
			babyName = names[math.random(#names)],
		}
	end,
	
	text = "Wonderful news! You're going to be a parent! After months of anticipation, you welcome a healthy baby %babyGender% into the world.",
	
	choices = {
		{
			id = "name_baby",
			text = "Welcome %babyName% to the family!",
			resultText = "Holding %babyName% for the first time, you're overwhelmed with love. Your life will never be the same.",
			effects = {Happiness = 40, Health = -5, Money = -5000},
			setFlags = {"has_children", "parent"},
			addRelationship = {type = "family", role = "Child", startingRelationship = 100, dynamicNameKey = "babyName"},
		},
	},
})

table.insert(events, {
	id = "adult_midlife_crisis",
	emoji = "😰",
	title = "Midlife Crisis",
	category = "life",
	tags = {"adult", "mental_health", "life"},
	
	weight = 10,
	oneTime = true,
	
	conditions = {
		minAge = 40,
		maxAge = 55,
		blockedFlags = {"had_midlife_crisis"},
	},
	
	text = "You wake up one morning and realize you're not young anymore. Is this really what you wanted from life? The existential dread hits hard.",
	
	choices = {
		{
			id = "embrace_change",
			text = "It's never too late to change! Start something new!",
			resultText = "You take up a new hobby, reconnect with old friends, and start exercising. Midlife can be a new beginning!",
			effects = {Happiness = 10, Health = 10},
			setFlags = {"had_midlife_crisis", "embraced_change"},
		},
		{
			id = "impulsive_purchase",
			text = "Buy a sports car. That'll help.",
			resultText = "The new car is fun but doesn't fill the void. At least it's fast.",
			effects = {Happiness = 5, Money = -50000},
			setFlags = {"had_midlife_crisis", "impulsive_buyer"},
		},
		{
			id = "therapy",
			text = "Talk to a therapist about these feelings.",
			resultText = "Therapy helps you work through your feelings and find meaning. It's okay to not have it all figured out.",
			effects = {Happiness = 15, Money = -2000},
			setFlags = {"had_midlife_crisis", "sought_therapy", "self_aware"},
		},
	},
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 5: SENIOR EVENTS (Ages 55+)
-- Retirement, legacy, health
-- ═══════════════════════════════════════════════════════════════════════════════

table.insert(events, {
	id = "senior_retirement",
	emoji = "🏖️",
	title = "Retirement",
	category = "career",
	tags = {"senior", "career", "milestone", "life"},
	
	weight = 20,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 55,
		maxAge = 70,
		requiredAnyFlags = {"has_career_job", "employed", "has_job"},
		blockedFlags = {"retired"},
	},
	
	getDynamicData = function(state)
		local years = (state.Age or 55) - 22
		return {
			yearsWorked = years,
		}
	end,
	
	text = "After %yearsWorked% years of hard work, it's time to consider retirement. Your colleagues are throwing you a farewell party.",
	
	choices = {
		{
			id = "retire_happy",
			text = "Accept retirement with grace. You've earned it!",
			resultText = "You give an emotional speech, shake hands with everyone, and walk out for the last time. A new chapter begins!",
			effects = {Happiness = 30},
			setFlags = {"retired"},
		},
		{
			id = "keep_working",
			text = "You're not done yet! Keep working!",
			resultText = "You turn down retirement. The work keeps you young. Besides, what would you do all day?",
			effects = {Happiness = 5, Health = -5},
			setFlags = {"workaholic"},
		},
	},
})

table.insert(events, {
	id = "senior_grandchildren",
	emoji = "👴",
	title = "Becoming a Grandparent",
	category = "family",
	tags = {"senior", "family", "milestone", "relationships"},
	
	weight = 15,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 45,
		maxAge = 75,
		requiredAllFlags = {"has_children"},
		blockedFlags = {"is_grandparent"},
	},
	
	getDynamicData = function(state)
		local names = math.random(2) == 1 and MaleNames or FemaleNames
		return {
			grandchildName = names[math.random(#names)],
		}
	end,
	
	text = "Your child calls with incredible news - you're going to be a grandparent! Little %grandchildName% is on the way!",
	
	choices = {
		{
			id = "overjoyed",
			text = "This is the best news ever!",
			resultText = "When you hold %grandchildName% for the first time, your heart melts. Being a grandparent is the best thing ever!",
			effects = {Happiness = 35},
			setFlags = {"is_grandparent", "grandparent_love"},
		},
	},
})

table.insert(events, {
	id = "senior_health_scare",
	emoji = "🏥",
	title = "Health Scare",
	category = "health",
	tags = {"senior", "health"},
	
	weight = 12,
	cooldownYears = 5,
	
	conditions = {
		minAge = 50,
		maxAge = 90,
		maxStats = {Health = 60},
	},
	
	getDynamicData = function(state)
		local conditions = {"high blood pressure", "chest pains", "shortness of breath", "unexplained fatigue"}
		return {
			condition = conditions[math.random(#conditions)],
		}
	end,
	
	text = "You've been experiencing %condition%. The doctor wants to run some tests. The waiting is agony.",
	
	choices = {
		{
			id = "good_news",
			text = "Get the test results...",
			chanceSuccess = 0.70,
			resultTextSuccess = "Good news! It's nothing serious, but you need to take better care of yourself. A wake-up call.",
			resultTextFail = "The news isn't great. You'll need ongoing treatment. Life is fragile.",
			effectsOnSuccess = {Happiness = 5, Health = 5},
			effectsOnFail = {Happiness = -15, Health = -15},
			setFlags = {"had_health_scare"},
		},
	},
})

table.insert(events, {
	id = "senior_legacy",
	emoji = "📜",
	title = "Your Legacy",
	category = "life",
	tags = {"senior", "milestone", "life"},
	
	weight = 10,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 65,
		maxAge = 100,
		blockedFlags = {"planned_legacy"},
	},
	
	getDynamicData = function(state)
		return {
			wealth = state.Money or 0,
		}
	end,
	
	text = "Looking back on your life, you think about what you'll leave behind. Your wealth sits at $%wealth%. How do you want to be remembered?",
	
	choices = {
		{
			id = "family_inheritance",
			text = "Leave everything to your family.",
			resultText = "You set up your will to ensure your loved ones are taken care of. Family is everything.",
			effects = {Happiness = 15},
			setFlags = {"planned_legacy", "family_focused"},
		},
		{
			id = "charity",
			text = "Donate a significant portion to charity.",
			resultText = "Your generosity will help countless people. You'll be remembered for your kindness.",
			effects = {Happiness = 25, Karma = 30, Money = -50000},
			setFlags = {"planned_legacy", "philanthropist"},
		},
		{
			id = "spend_it_all",
			text = "Spend it all while you can!",
			resultText = "You book luxury vacations, buy gifts for everyone, and live your final years in style!",
			effects = {Happiness = 20, Money = -30000},
			setFlags = {"planned_legacy", "lived_fully"},
		},
	},
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 6: RANDOM LIFE EVENTS (All Ages)
-- Unexpected events that can happen anytime
-- ═══════════════════════════════════════════════════════════════════════════════

table.insert(events, {
	id = "random_lottery_win",
	emoji = "🎰",
	title = "Lottery Win!",
	category = "life",
	tags = {"random", "money", "luck"},
	
	weight = 2,  -- Very rare
	cooldownYears = 10,
	
	conditions = {
		minAge = 18,
		maxAge = 100,
	},
	
	getDynamicData = function(state)
		local amounts = {1000, 5000, 10000, 50000, 100000}
		return {
			amount = amounts[math.random(#amounts)],
		}
	end,
	
	text = "You bought a lottery ticket on a whim... and WON $%amount%! You can't believe your luck!",
	
	choices = {
		{
			id = "celebrate",
			text = "Party time! Celebrate your win!",
			resultText = "You throw a huge party and treat all your friends. What a night!",
			effects = {Happiness = 25, Money = 5000},
			setFlags = {"lottery_winner"},
		},
		{
			id = "save",
			text = "Put it straight into savings.",
			resultText = "You invest wisely. Your future self will thank you.",
			effects = {Happiness = 15, Money = 10000},
			setFlags = {"lottery_winner", "smart_saver"},
		},
	},
})

table.insert(events, {
	id = "random_car_accident",
	emoji = "🚗",
	title = "Car Accident",
	category = "health",
	tags = {"random", "health", "driving"},
	
	weight = 5,
	cooldownYears = 5,
	
	conditions = {
		minAge = 16,
		maxAge = 90,
		requiredAnyFlags = {"has_license", "can_drive", "owns_car"},
	},
	
	text = "You're in a car accident! Another driver ran a red light and hit you. Your car is damaged and you're shaken.",
	
	choices = {
		{
			id = "minor_injuries",
			text = "Assess the damage...",
			chanceSuccess = 0.80,
			resultTextSuccess = "Thankfully, you're okay. Just a few bruises. Your car needs repairs, but you're alive.",
			resultTextFail = "You're seriously injured and need to go to the hospital. This will take time to recover from.",
			effectsOnSuccess = {Health = -10, Money = -2000},
			effectsOnFail = {Health = -35, Money = -10000, Happiness = -15},
			setFlags = {"car_accident_survivor"},
		},
	},
})

table.insert(events, {
	id = "random_inheritance",
	emoji = "💰",
	title = "Unexpected Inheritance",
	category = "family",
	tags = {"random", "money", "family"},
	
	weight = 4,
	oneTime = true,
	
	conditions = {
		minAge = 25,
		maxAge = 80,
	},
	
	getDynamicData = function(state)
		local amounts = {10000, 25000, 50000, 100000}
		local relatives = {"a distant aunt", "an uncle you barely knew", "a great-aunt", "a family friend"}
		return {
			amount = amounts[math.random(#amounts)],
			relative = relatives[math.random(#relatives)],
		}
	end,
	
	text = "You receive news that %relative% has passed away and left you $%amount% in their will. You didn't expect this.",
	
	choices = {
		{
			id = "grateful",
			text = "Accept the inheritance with gratitude.",
			resultText = "You honor their memory by using the money wisely. Rest in peace.",
			effects = {Happiness = 10, Money = 25000},
			setFlags = {"received_inheritance"},
		},
		{
			id = "donate_portion",
			text = "Donate a portion to their favorite charity.",
			resultText = "It's what they would have wanted. You feel good about honoring their wishes.",
			effects = {Happiness = 20, Money = 15000, Karma = 10},
			setFlags = {"received_inheritance", "generous"},
		},
	},
})

table.insert(events, {
	id = "random_make_enemy",
	emoji = "😠",
	title = "New Rival",
	category = "social",
	tags = {"random", "relationships", "conflict"},
	
	weight = 6,
	cooldownYears = 4,
	
	conditions = {
		minAge = 15,
		maxAge = 70,
	},
	
	getDynamicData = function(state)
		return {
			enemyName = randomName(),
			reason = ({"a parking spot argument", "a misunderstanding", "jealousy", "a social media dispute", "workplace competition"})[math.random(5)],
		}
	end,
	
	text = "%enemyName% has developed a grudge against you after %reason%. They're spreading rumors and making your life difficult.",
	
	choices = {
		{
			id = "confront",
			text = "Confront them directly.",
			chanceSuccess = 0.50,
			resultTextSuccess = "You talk it out and clear the air. It was all a misunderstanding. No more enemies.",
			resultTextFail = "The confrontation makes things worse. They really hate you now.",
			effectsOnSuccess = {Happiness = 10},
			effectsOnFail = {Happiness = -15},
			setFlags = {"has_enemy"},
		},
		{
			id = "ignore",
			text = "Rise above it. Ignore them.",
			resultText = "You refuse to stoop to their level. Eventually, they get bored and move on.",
			effects = {Happiness = 5, Karma = 5},
			setFlags = {"took_high_road"},
		},
		{
			id = "retaliate",
			text = "Retaliate! Give them a taste of their own medicine!",
			resultText = "The feud escalates. You've made a real enemy now.",
			effects = {Happiness = -10, Karma = -10},
			setFlags = {"has_enemy", "vengeful"},
			addRelationship = {type = "enemy", role = "Rival", startingRelationship = 15, dynamicNameKey = "enemyName"},
		},
	},
})

table.insert(events, {
	id = "random_opportunity",
	emoji = "✨",
	title = "Unexpected Opportunity",
	category = "life",
	tags = {"random", "opportunity", "life"},
	
	weight = 8,
	cooldownYears = 5,
	
	conditions = {
		minAge = 20,
		maxAge = 60,
	},
	
	getDynamicData = function(state)
		local opportunities = {
			{text = "start your own business", effect = "Money", amount = 10000, flag = "entrepreneur"},
			{text = "travel abroad for a year", effect = "Happiness", amount = 20, flag = "world_traveler"},
			{text = "go back to school for a new degree", effect = "Smarts", amount = 15, flag = "lifelong_learner"},
			{text = "relocate to a new city for a fresh start", effect = "Happiness", amount = 15, flag = "new_beginnings"},
		}
		local opp = opportunities[math.random(#opportunities)]
		return {
			opportunity = opp.text,
			effect = opp.effect,
			amount = opp.amount,
			flag = opp.flag,
		}
	end,
	
	text = "An unexpected opportunity arises: you could %opportunity%. It would mean big changes, but it could also be amazing.",
	
	choices = {
		{
			id = "take_chance",
			text = "Take the leap! Life is short!",
			resultText = "You go for it! The change is scary but exhilarating. You feel alive!",
			effects = {Happiness = 15},
			setFlags = {"took_big_chance"},
		},
		{
			id = "play_safe",
			text = "The timing isn't right. Maybe someday.",
			resultText = "You let the opportunity pass. Part of you wonders 'what if?'",
			effects = {Happiness = -5},
			setFlags = {"played_it_safe"},
		},
	},
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 7: ACTIVITIES & SKILLS (Links to ActivitiesScreen)
-- Gym, study, hobbies that boost stats
-- ═══════════════════════════════════════════════════════════════════════════════

table.insert(events, {
	id = "discover_gym",
	emoji = "💪",
	title = "Fitness Discovery",
	category = "activities",
	tags = {"activities", "health", "fitness"},
	
	weight = 10,
	oneTime = true,
	
	conditions = {
		minAge = 14,
		maxAge = 40,
		blockedFlags = {"discovered_gym"},
	},
	
	getDynamicData = function(state)
		local gyms = {"Iron Paradise Gym", "FitLife Center", "PowerHouse Fitness", "The Pump Station"}
		return {
			gymName = gyms[math.random(#gyms)],
		}
	end,
	
	text = "You discover %gymName% in your neighborhood. The trainers look intimidating, but the equipment is top-notch. Maybe it's time to get in shape?",
	
	choices = {
		{
			id = "join",
			text = "Sign up for a membership!",
			resultText = "You start working out regularly. It's tough at first, but you're already seeing results!",
			effects = {Health = 10, Happiness = 5, Money = -500},
			setFlags = {"discovered_gym", "gym_member", "fitness_journey"},
		},
		{
			id = "decline",
			text = "Fitness isn't really your thing.",
			resultText = "You walk past. Maybe someday.",
			effects = {},
			setFlags = {"discovered_gym"},
		},
	},
})

table.insert(events, {
	id = "study_opportunity",
	emoji = "📚",
	title = "Learning Opportunity",
	category = "activities",
	tags = {"activities", "education", "smarts"},
	
	weight = 10,
	cooldownYears = 3,
	
	conditions = {
		minAge = 15,
		maxAge = 60,
	},
	
	getDynamicData = function(state)
		local courses = {
			{name = "programming", desc = "an online coding bootcamp"},
			{name = "language", desc = "a foreign language course"},
			{name = "finance", desc = "an investment workshop"},
			{name = "art", desc = "a creative writing class"},
		}
		local course = courses[math.random(#courses)]
		return {
			courseName = course.name,
			courseDesc = course.desc,
		}
	end,
	
	text = "You hear about %courseDesc% that's accepting new students. It could sharpen your mind and open new doors.",
	
	choices = {
		{
			id = "enroll",
			text = "Enroll and expand your knowledge!",
			resultText = "The course is challenging but rewarding. Your mind feels sharper than ever!",
			effects = {Smarts = 10, Happiness = 5, Money = -1000},
			setFlags = {"took_course", "lifelong_learner"},
		},
		{
			id = "too_busy",
			text = "You're too busy right now.",
			resultText = "Life gets in the way. Maybe another time.",
			effects = {},
		},
	},
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 8: CRIME & LEGAL TROUBLES (Links to ActivitiesScreen)
-- ═══════════════════════════════════════════════════════════════════════════════

table.insert(events, {
	id = "temptation_to_steal",
	emoji = "🕵️",
	title = "Temptation",
	category = "crime",
	tags = {"crime", "moral_choice"},
	
	weight = 6,
	cooldownYears = 5,
	
	conditions = {
		minAge = 13,
		maxAge = 50,
		maxStats = {Money = 5000},  -- More likely when poor
	},
	
	getDynamicData = function(state)
		local items = {"wallet", "smartphone", "laptop", "designer bag"}
		return {
			item = items[math.random(#items)],
			value = math.random(2, 8) * 100,
		}
	end,
	
	text = "You notice someone left their %item% unattended. Nobody's watching. It looks valuable...",
	
	choices = {
		{
			id = "steal",
			text = "Take it. They shouldn't have left it there.",
			chanceSuccess = 0.60,
			resultTextSuccess = "You grab the %item% and walk away casually. Nobody noticed. You feel guilty but $%value% richer.",
			resultTextFail = "Someone sees you! They call security. You're caught and arrested.",
			effectsOnSuccess = {Money = 500, Karma = -15},
			effectsOnFail = {Happiness = -20, Karma = -10},
			setFlags = {"committed_theft"},
		},
		{
			id = "return",
			text = "Find the owner and return it.",
			resultText = "You track down the owner. They're incredibly grateful and give you a reward!",
			effects = {Happiness = 10, Money = 100, Karma = 15},
			setFlags = {"good_citizen"},
		},
		{
			id = "ignore",
			text = "Not your problem. Walk away.",
			resultText = "You leave it there. Someone else probably took it anyway.",
			effects = {},
		},
	},
})

table.insert(events, {
	id = "arrested",
	emoji = "🚔",
	title = "Arrested!",
	category = "crime",
	tags = {"crime", "legal", "prison"},
	
	weight = 5,
	cooldownYears = 10,
	
	conditions = {
		minAge = 18,
		maxAge = 70,
		requiredAnyFlags = {"committed_theft", "committed_crime", "criminal_record"},
	},
	
	getDynamicData = function(state)
		local crimes = {"theft", "fraud", "assault", "vandalism"}
		return {
			crime = crimes[math.random(#crimes)],
			sentence = math.random(1, 5),
		}
	end,
	
	text = "The police knock on your door. They have a warrant for your arrest for %crime%. Your past has caught up with you.",
	
	choices = {
		{
			id = "cooperate",
			text = "Go quietly. Lawyer up.",
			resultText = "You cooperate with authorities. Your lawyer negotiates a reduced sentence of %sentence% years.",
			effects = {Happiness = -30, Money = -20000},
			setFlags = {"in_prison", "was_arrested", "criminal_record"},
		},
		{
			id = "resist",
			text = "Try to run!",
			chanceSuccess = 0.20,
			resultTextSuccess = "Against all odds, you escape! But you're now a fugitive...",
			resultTextFail = "They tackle you. Now you're facing additional charges for resisting arrest.",
			effectsOnSuccess = {Happiness = 5},
			effectsOnFail = {Happiness = -40, Health = -10, Money = -30000},
			setFlags = {"in_prison", "was_arrested", "criminal_record"},
		},
	},
})

table.insert(events, {
	id = "prison_life",
	emoji = "⛓️",
	title = "Prison Life",
	category = "crime",
	tags = {"prison", "life"},
	
	weight = 15,
	cooldownYears = 1,
	
	conditions = {
		minAge = 18,
		maxAge = 90,
		requiredAllFlags = {"in_prison"},
	},
	
	getDynamicData = function(state)
		local situations = {
			{desc = "Another inmate is looking at you funny", danger = true},
			{desc = "The guards are doing a cell inspection", danger = false},
			{desc = "You find a hidden stash of contraband", danger = true},
		}
		local sit = situations[math.random(#situations)]
		return {
			situation = sit.desc,
			isDangerous = sit.danger,
		}
	end,
	
	text = "%situation%. How do you handle it?",
	
	choices = {
		{
			id = "keep_head_down",
			text = "Keep your head down and stay quiet.",
			resultText = "You avoid trouble. Another day survived in here.",
			effects = {Happiness = -5},
		},
		{
			id = "assert_yourself",
			text = "Stand your ground. Show no weakness.",
			chanceSuccess = 0.50,
			resultTextSuccess = "Your confidence earns respect. Other inmates leave you alone now.",
			resultTextFail = "You get into a fight. The guards throw you in solitary.",
			effectsOnSuccess = {Happiness = 5},
			effectsOnFail = {Happiness = -15, Health = -10},
			setFlags = {"prison_survivor"},
		},
	},
})

table.insert(events, {
	id = "prison_release",
	emoji = "🔓",
	title = "Freedom!",
	category = "crime",
	tags = {"prison", "milestone"},
	
	weight = 25,
	oneTime = false,
	milestone = true,
	
	conditions = {
		minAge = 18,
		maxAge = 90,
		requiredAllFlags = {"in_prison"},
	},
	
	text = "The day has finally come. You've served your time. The prison gates open, and you step out into the fresh air. You're free!",
	
	choices = {
		{
			id = "fresh_start",
			text = "Take a deep breath. It's a new beginning.",
			resultText = "You vow to turn your life around. It won't be easy, but you're determined.",
			effects = {Happiness = 30},
			setFlags = {"ex_convict", "fresh_start"},
			clearFlags = {"in_prison"},
		},
	},
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 9: ASSETS & PURCHASES (Links to AssetsScreen)
-- Properties, vehicles, investments
-- ═══════════════════════════════════════════════════════════════════════════════

table.insert(events, {
	id = "first_car",
	emoji = "🚙",
	title = "First Car",
	category = "assets",
	tags = {"assets", "vehicles", "milestone"},
	
	weight = 15,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 17,
		maxAge = 30,
		requiredAnyFlags = {"has_license", "can_drive", "drivers_license"},
		blockedFlags = {"owns_car"},
		minMoney = 5000,
	},
	
	getDynamicData = function(state)
		local cars = {
			{name = "used Honda Civic", price = 5000},
			{name = "old Toyota Camry", price = 4000},
			{name = "beat-up Ford Focus", price = 3500},
			{name = "vintage VW Beetle", price = 6000},
		}
		local car = cars[math.random(#cars)]
		return {
			carName = car.name,
			carPrice = car.price,
		}
	end,
	
	text = "You find a %carName% for sale for $%carPrice%. It's not fancy, but it runs. Having your own wheels would change everything!",
	
	choices = {
		{
			id = "buy_it",
			text = "Buy it! Freedom awaits!",
			resultText = "You hand over the cash and get the keys. YOUR car. The feeling is incredible!",
			effects = {Happiness = 20, Money = -5000},
			setFlags = {"owns_car", "has_vehicle", "mobile"},
		},
		{
			id = "wait",
			text = "Save up for something better.",
			resultText = "You walk away. Someday you'll have the car of your dreams.",
			effects = {},
		},
	},
})

table.insert(events, {
	id = "investment_opportunity",
	emoji = "📈",
	title = "Investment Opportunity",
	category = "assets",
	tags = {"assets", "money", "risk"},
	
	weight = 8,
	cooldownYears = 3,
	
	conditions = {
		minAge = 25,
		maxAge = 70,
		minMoney = 10000,
	},
	
	getDynamicData = function(state)
		local investments = {
			{type = "tech startup", risk = "high", potential = 3},
			{type = "real estate", risk = "medium", potential = 2},
			{type = "index fund", risk = "low", potential = 1.3},
			{type = "cryptocurrency", risk = "very high", potential = 5},
		}
		local inv = investments[math.random(#investments)]
		local amount = math.random(5, 15) * 1000
		return {
			investType = inv.type,
			riskLevel = inv.risk,
			potential = inv.potential,
			investAmount = amount,
		}
	end,
	
	text = "A friend tells you about an opportunity to invest $%investAmount% in a %investType%. The risk is %riskLevel%, but the returns could be significant.",
	
	choices = {
		{
			id = "invest",
			text = "Go for it! Fortune favors the bold!",
			chanceSuccess = 0.55,
			resultTextSuccess = "Your investment pays off! You've made a healthy profit!",
			resultTextFail = "The investment tanks. You've lost your money.",
			effectsOnSuccess = {Money = 15000, Happiness = 15},
			effectsOnFail = {Money = -10000, Happiness = -15},
			setFlags = {"investor"},
		},
		{
			id = "pass",
			text = "Too risky. Keep your money safe.",
			resultText = "You decide to play it safe. Your savings stay intact.",
			effects = {},
			setFlags = {"conservative_investor"},
		},
	},
})

table.insert(events, {
	id = "gambling_invitation",
	emoji = "🎲",
	title = "Casino Night",
	category = "assets",
	tags = {"gambling", "risk", "social"},
	
	weight = 6,
	cooldownYears = 2,
	
	conditions = {
		minAge = 21,
		maxAge = 70,
		minMoney = 1000,
	},
	
	getDynamicData = function(state)
		return {
			friendName = randomName(),
		}
	end,
	
	text = "%friendName% invites you to hit the casino. 'Just for fun,' they say. 'What's the worst that could happen?'",
	
	choices = {
		{
			id = "go_gambling",
			text = "Let's roll the dice!",
			chanceSuccess = 0.40,
			resultTextSuccess = "Lady Luck is on your side! You walk out with your pockets full!",
			resultTextFail = "You got caught up in the moment. You lost track of how much you bet...",
			effectsOnSuccess = {Money = 5000, Happiness = 20},
			effectsOnFail = {Money = -3000, Happiness = -10},
			setFlags = {"gambler"},
		},
		{
			id = "small_bets",
			text = "Go but set a strict limit.",
			resultText = "You have fun with small bets. Win some, lose some. Good times!",
			effects = {Happiness = 10, Money = -200},
			setFlags = {"responsible_gambler"},
		},
		{
			id = "decline",
			text = "Gambling isn't for you.",
			resultText = "You politely decline. %friendName% shrugs and goes without you.",
			effects = {},
		},
	},
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 10: STORY PATHS & LIFE DECISIONS (Links to StoryPathsScreen)
-- Major life paths and career pivots
-- ═══════════════════════════════════════════════════════════════════════════════

table.insert(events, {
	id = "political_awakening",
	emoji = "🏛️",
	title = "Political Calling",
	category = "paths",
	tags = {"paths", "politics", "career"},
	
	weight = 5,
	oneTime = true,
	
	conditions = {
		minAge = 25,
		maxAge = 50,
		blockedFlags = {"on_political_path"},
		minStats = {Smarts = 40},
	},
	
	text = "You've become increasingly frustrated with how things are run in your community. Maybe YOU could make a difference in politics?",
	
	choices = {
		{
			id = "enter_politics",
			text = "Start getting involved in local politics.",
			resultText = "You begin attending town halls and volunteering for campaigns. The political journey begins!",
			effects = {Happiness = 10},
			setFlags = {"on_political_path", "political_interest", "community_active"},
		},
		{
			id = "not_for_me",
			text = "Politics is too dirty. Stay out of it.",
			resultText = "You decide your talents lie elsewhere. Let someone else fight those battles.",
			effects = {},
		},
	},
})

table.insert(events, {
	id = "fame_opportunity",
	emoji = "⭐",
	title = "Shot at Fame",
	category = "paths",
	tags = {"paths", "celebrity", "entertainment"},
	
	weight = 4,
	oneTime = true,
	
	conditions = {
		minAge = 16,
		maxAge = 35,
		blockedFlags = {"on_fame_path"},
		minStats = {Looks = 50},
	},
	
	getDynamicData = function(state)
		local venues = {"talent show", "open mic night", "modeling agency", "reality TV audition"}
		return {
			venue = venues[math.random(#venues)],
		}
	end,
	
	text = "Someone at a %venue% notices you and says you have 'star potential'. They hand you a business card. Could this be your big break?",
	
	choices = {
		{
			id = "pursue_fame",
			text = "Chase the spotlight!",
			chanceSuccess = 0.50,
			resultTextSuccess = "Your audition goes amazingly! They want to sign you. The road to fame begins!",
			resultTextFail = "It doesn't work out this time. But hey, even the biggest stars got rejected before.",
			effectsOnSuccess = {Happiness = 25},
			effectsOnFail = {Happiness = -10},
			setFlags = {"on_fame_path", "entertainment_industry"},
		},
		{
			id = "stay_grounded",
			text = "Fame isn't everything. Stay humble.",
			resultText = "You politely decline. A normal life has its own rewards.",
			effects = {},
		},
	},
})

table.insert(events, {
	id = "criminal_path",
	emoji = "🎭",
	title = "Easy Money",
	category = "paths",
	tags = {"paths", "crime", "illegal"},
	
	weight = 4,
	oneTime = true,
	
	conditions = {
		minAge = 18,
		maxAge = 45,
		blockedFlags = {"on_crime_path"},
		maxStats = {Money = 10000},  -- More appealing when struggling
	},
	
	getDynamicData = function(state)
		return {
			contactName = randomName(),
		}
	end,
	
	text = "%contactName% approaches you with a 'business opportunity'. No questions asked, easy money. You know it's not legal, but the pay is tempting.",
	
	choices = {
		{
			id = "join_crime",
			text = "Money is money. You're in.",
			resultText = "You enter a world of shadows and secrets. The money flows, but at what cost?",
			effects = {Money = 5000, Karma = -20},
			setFlags = {"on_crime_path", "criminal_connections", "shady_business"},
		},
		{
			id = "walk_away",
			text = "No way. You're better than this.",
			resultText = "You walk away. Some lines shouldn't be crossed.",
			effects = {Karma = 5},
			setFlags = {"honest_citizen"},
		},
	},
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 11: EDUCATION MILESTONES (Links to OccupationScreen)
-- ═══════════════════════════════════════════════════════════════════════════════

table.insert(events, {
	id = "grad_school_decision",
	emoji = "🎓",
	title = "Graduate School",
	category = "education",
	tags = {"education", "career", "milestone"},
	
	weight = 12,
	oneTime = true,
	
	conditions = {
		minAge = 21,
		maxAge = 40,
		requiredAnyFlags = {"graduated_college", "has_degree", "bachelor_degree"},
		blockedFlags = {"grad_school_decision_made"},
	},
	
	getDynamicData = function(state)
		local programs = {
			{name = "MBA", field = "Business", cost = 80000},
			{name = "Master's in Computer Science", field = "Technology", cost = 60000},
			{name = "Law School", field = "Law", cost = 100000},
			{name = "Medical School", field = "Medicine", cost = 150000},
		}
		local prog = programs[math.random(#programs)]
		return {
			programName = prog.name,
			field = prog.field,
			tuitionCost = prog.cost,
		}
	end,
	
	text = "You've been accepted to a %programName% program! It's a huge opportunity in %field%, but the tuition is $%tuitionCost%. Is it worth the investment?",
	
	choices = {
		{
			id = "enroll",
			text = "Invest in your future. Enroll!",
			resultText = "You begin the rigorous program. Late nights, hard work, but it'll be worth it!",
			effects = {Money = -50000, Smarts = 10},
			setFlags = {"grad_school_decision_made", "in_grad_school", "pursuing_advanced_degree"},
		},
		{
			id = "decline",
			text = "Your current education is enough.",
			resultText = "You decide your bachelor's degree is sufficient for your goals.",
			effects = {},
			setFlags = {"grad_school_decision_made"},
		},
	},
})

table.insert(events, {
	id = "grad_school_complete",
	emoji = "🎓",
	title = "Graduation Day",
	category = "education",
	tags = {"education", "milestone"},
	
	weight = 20,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 23,
		maxAge = 50,
		requiredAllFlags = {"in_grad_school"},
		blockedFlags = {"advanced_degree"},
	},
	
	text = "After years of grueling study, sleepless nights, and countless exams, you've done it. You're getting your advanced degree!",
	
	choices = {
		{
			id = "celebrate",
			text = "Walk across that stage with pride!",
			resultText = "Your family cheers as you receive your diploma. The sacrifice was worth it. New doors are now open!",
			effects = {Happiness = 25, Smarts = 15},
			setFlags = {"advanced_degree", "highly_educated"},
			clearFlags = {"in_grad_school"},
		},
	},
})

table.insert(events, {
	id = "career_change",
	emoji = "🔄",
	title = "Career Crossroads",
	category = "career",
	tags = {"career", "occupation", "life_change"},
	
	weight = 8,
	cooldownYears = 5,
	
	conditions = {
		minAge = 28,
		maxAge = 55,
		requiredAnyFlags = {"has_career_job", "employed", "has_job"},
	},
	
	getDynamicData = function(state)
		local fields = {"technology", "healthcare", "finance", "creative arts", "entrepreneurship"}
		return {
			newField = fields[math.random(#fields)],
		}
	end,
	
	text = "You've been feeling unfulfilled at work lately. You keep thinking about switching to %newField%. Is it time for a change?",
	
	choices = {
		{
			id = "change_careers",
			text = "Take the leap! Start fresh!",
			resultText = "You resign and begin your journey in a new field. Scary but exciting!",
			effects = {Happiness = 15, Money = -5000},
			setFlags = {"career_changer", "fresh_start"},
		},
		{
			id = "stay_put",
			text = "Stability is important. Stay where you are.",
			resultText = "You recommit to your current path. Maybe you just needed to remember why you started.",
			effects = {Happiness = 5},
		},
	},
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 12: FRIENDSHIP EVENTS (Links to RelationshipsScreen)
-- Building and maintaining friendships
-- ═══════════════════════════════════════════════════════════════════════════════

table.insert(events, {
	id = "friend_betrayal",
	emoji = "💔",
	title = "Betrayed",
	category = "social",
	tags = {"relationships", "friends", "conflict"},
	
	weight = 6,
	cooldownYears = 5,
	
	conditions = {
		minAge = 15,
		maxAge = 60,
		requiredAnyFlags = {"has_friend", "has_first_friend"},
	},
	
	getDynamicData = function(state)
		-- Try to get an actual friend's name
		local friendName = "Your friend"
		local relationships = state.Relationships or {}
		for _, rel in pairs(relationships) do
			if rel.type == "friend" and rel.alive ~= false then
				friendName = rel.name
				break
			end
		end
		return {friendName = friendName}
	end,
	
	text = "You discover that %friendName% has been talking behind your back. They said terrible things about you to others. You feel hurt and angry.",
	
	choices = {
		{
			id = "confront",
			text = "Confront them about it.",
			chanceSuccess = 0.60,
			resultTextSuccess = "They apologize sincerely. It was a misunderstanding. Your friendship is stronger for it.",
			resultTextFail = "The confrontation turns ugly. Your friendship might be over.",
			effectsOnSuccess = {Happiness = 5},
			effectsOnFail = {Happiness = -15},
			setFlags = {"confronted_friend"},
		},
		{
			id = "forgive",
			text = "Let it go. Everyone makes mistakes.",
			resultText = "You choose to be the bigger person. Time heals most wounds.",
			effects = {Happiness = 0, Karma = 5},
			setFlags = {"forgiving_nature"},
		},
		{
			id = "end_friendship",
			text = "Cut them out. You don't need that toxicity.",
			resultText = "You stop talking to them. It hurts, but some relationships are better left behind.",
			effects = {Happiness = -10},
			setFlags = {"lost_friend"},
			changeRelationship = {relType = "friend", delta = -80},
		},
	},
})

table.insert(events, {
	id = "new_coworker_friend",
	emoji = "🤝",
	title = "Work Friend",
	category = "social",
	tags = {"relationships", "friends", "career"},
	
	weight = 10,
	cooldownYears = 3,
	
	conditions = {
		minAge = 20,
		maxAge = 60,
		requiredAnyFlags = {"has_career_job", "employed", "has_job"},
	},
	
	getDynamicData = function(state)
		return {
			coworkerName = randomName(),
		}
	end,
	
	text = "You've been getting along great with your coworker, %coworkerName%. They invite you to hang out outside of work.",
	
	choices = {
		{
			id = "accept",
			text = "Sure! New friends are always welcome!",
			resultText = "You have a great time! Looks like you've made a genuine friend at work.",
			effects = {Happiness = 10},
			setFlags = {"work_friend", "social_at_work"},
			addRelationship = {type = "friend", role = "Work Friend", startingRelationship = 60, dynamicNameKey = "coworkerName"},
		},
		{
			id = "keep_professional",
			text = "Keep things professional. Work and personal life separate.",
			resultText = "You politely decline. Better to keep boundaries.",
			effects = {},
		},
	},
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- Return all events
-- ═══════════════════════════════════════════════════════════════════════════════

print("[general_events] Loaded", #events, "general life events")

return {events = events}
