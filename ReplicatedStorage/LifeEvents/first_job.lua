-- first_job.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- FIRST JOB EVENTS - Generic entry-level job opportunities
-- These events help players get their first job and start working
-- ═══════════════════════════════════════════════════════════════════════════════

local events = {}

local function flagSet(...)
	return { set = {...} }
end

-- ═══════════════════════════════════════════════════════════════
-- TEENAGE FIRST JOBS (AGES 14-18)
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "first_job_retail",
	emoji = "🛒",
	title = "First Job: Retail",
	category = "work",
	tags = {"work", "first_job", "retail", "teen"},
	weight = 25,
	oneTime = true,
	conditions = {
		minAge = 14,
		maxAge = 18,
		blockedFlags = {"employed", "has_job", "ever_worked", "first_job"},
	},
	text = "A local store is hiring part-time. This could be your first job. It's not glamorous, but everyone starts somewhere.",
	choices = {
		{
			id = "apply_retail",
			text = "Apply for the retail job.",
			resultText = "You got the job! Your first paycheck feels amazing.",
			flags = flagSet("first_job", "employed", "retail_worker", "ever_worked"),
			effects = { Money = 800, Happiness = 2 },
		},
		{
			id = "decline_retail",
			text = "Wait for something better.",
			resultText = "You decide to wait. Maybe something better will come along.",
			effects = { Happiness = -1 },
		},
	},
})

table.insert(events, {
	id = "first_job_fast_food",
	emoji = "🍔",
	title = "First Job: Fast Food",
	category = "work",
	tags = {"work", "first_job", "fast_food", "teen"},
	weight = 22,
	oneTime = true,
	conditions = {
		minAge = 14,
		maxAge = 18,
		blockedFlags = {"employed", "has_job", "ever_worked", "first_job"},
	},
	text = "A fast food restaurant needs workers. The hours are flexible and they hire teenagers. Could be a good first job.",
	choices = {
		{
			id = "apply_fast_food",
			text = "Apply for the fast food job.",
			resultText = "You got hired! Your first shift is exhausting but you're earning money.",
			flags = flagSet("first_job", "employed", "fast_food_worker", "ever_worked"),
			effects = { Money = 600, Happiness = 1, Health = -1 },
		},
		{
			id = "decline_fast_food",
			text = "Not interested in fast food.",
			resultText = "You pass on this opportunity.",
			effects = { Happiness = -1 },
		},
	},
})

table.insert(events, {
	id = "first_job_lifeguard",
	emoji = "🏊",
	title = "First Job: Lifeguard",
	category = "work",
	tags = {"work", "first_job", "lifeguard", "teen"},
	weight = 18,
	oneTime = true,
	conditions = {
		minAge = 16,
		maxAge = 20,
		blockedFlags = {"employed", "has_job", "ever_worked", "first_job"},
		minStats = { Health = 40 },
	},
	text = "The local pool needs lifeguards. You need to be certified, but it pays well and you get to be outside.",
	choices = {
		{
			id = "apply_lifeguard",
			text = "Get certified and apply.",
			resultText = "You become a certified lifeguard and get the job! Great pay and you stay fit.",
			flags = flagSet("first_job", "employed", "lifeguard", "ever_worked", "lifeguard_certified"),
			effects = { Money = 1200, Happiness = 3, Health = 2 },
		},
		{
			id = "decline_lifeguard",
			text = "Not interested in lifeguarding.",
			resultText = "You decide against it.",
			effects = { Happiness = -1 },
		},
	},
})

table.insert(events, {
	id = "first_job_tutoring",
	emoji = "📚",
	title = "First Job: Tutoring",
	category = "work",
	tags = {"work", "first_job", "tutoring", "teen"},
	weight = 20,
	oneTime = true,
	conditions = {
		minAge = 15,
		maxAge = 20,
		blockedFlags = {"employed", "has_job", "ever_worked", "first_job"},
		minStats = { Smarts = 60 },
	},
	text = "Parents are looking for tutors for their kids. You're good at school - you could help others and earn money.",
	choices = {
		{
			id = "start_tutoring",
			text = "Start tutoring.",
			resultText = "You start tutoring. It's rewarding and pays well.",
			flags = flagSet("first_job", "employed", "tutor", "ever_worked"),
			effects = { Money = 1000, Happiness = 2, Smarts = 1 },
		},
		{
			id = "decline_tutoring",
			text = "Not interested in tutoring.",
			resultText = "You pass on this opportunity.",
			effects = { Happiness = -1 },
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- YOUNG ADULT FIRST JOBS (AGES 18-25)
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "first_job_office_intern",
	emoji = "💼",
	title = "First Job: Office Intern",
	category = "work",
	tags = {"work", "first_job", "intern", "office", "young_adult"},
	weight = 24,
	oneTime = true,
	conditions = {
		minAge = 18,
		maxAge = 25,
		blockedFlags = {"employed", "has_job", "ever_worked", "first_job"},
		requiredEducation = "high_school",
	},
	text = "A local company is offering an internship. It's entry-level but could lead to a real job. Good experience.",
	choices = {
		{
			id = "accept_internship",
			text = "Accept the internship.",
			resultText = "You start your internship. You're learning valuable skills.",
			flags = flagSet("first_job", "employed", "intern", "intern_experience", "ever_worked"),
			effects = { Money = 1500, Happiness = 2, Smarts = 2 },
		},
		{
			id = "decline_internship",
			text = "Look for paid work instead.",
			resultText = "You decide to look for a paid position.",
			effects = { Happiness = -1 },
		},
	},
})

table.insert(events, {
	id = "first_job_construction",
	emoji = "🔨",
	title = "First Job: Construction",
	category = "work",
	tags = {"work", "first_job", "construction", "manual_labor", "young_adult"},
	weight = 21,
	oneTime = true,
	conditions = {
		minAge = 18,
		maxAge = 30,
		blockedFlags = {"employed", "has_job", "ever_worked", "first_job"},
		minStats = { Health = 50 },
	},
	text = "A construction crew needs workers. It's hard physical work but pays well. No experience required.",
	choices = {
		{
			id = "apply_construction",
			text = "Apply for the construction job.",
			resultText = "You get hired! The work is tough but the pay is good.",
			flags = flagSet("first_job", "employed", "construction_worker", "ever_worked"),
			effects = { Money = 2000, Happiness = 1, Health = 3 },
		},
		{
			id = "decline_construction",
			text = "Too physically demanding.",
			resultText = "You decide it's not for you.",
			effects = { Happiness = -1 },
		},
	},
})

table.insert(events, {
	id = "first_job_delivery",
	emoji = "🚚",
	title = "First Job: Delivery Driver",
	category = "work",
	tags = {"work", "first_job", "delivery", "driving", "young_adult"},
	weight = 23,
	oneTime = true,
	conditions = {
		minAge = 18,
		maxAge = 30,
		blockedFlags = {"employed", "has_job", "ever_worked", "first_job"},
		requiredAnyFlags = {"has_license", "drivers_license", "can_drive"},
	},
	text = "A delivery company needs drivers. You need a license, but it's flexible work and you get to drive around.",
	choices = {
		{
			id = "apply_delivery",
			text = "Apply for the delivery job.",
			resultText = "You get hired as a delivery driver! Good pay and flexible hours.",
			flags = flagSet("first_job", "employed", "delivery_driver", "ever_worked"),
			effects = { Money = 1800, Happiness = 2 },
		},
		{
			id = "decline_delivery",
			text = "Not interested in delivery.",
			resultText = "You pass on this opportunity.",
			effects = { Happiness = -1 },
		},
	},
})

table.insert(events, {
	id = "first_job_restaurant",
	emoji = "🍽️",
	title = "First Job: Restaurant Server",
	category = "work",
	tags = {"work", "first_job", "restaurant", "service", "young_adult"},
	weight = 22,
	oneTime = true,
	conditions = {
		minAge = 18,
		maxAge = 30,
		blockedFlags = {"employed", "has_job", "ever_worked", "first_job"},
		minStats = { Looks = 40 },
	},
	text = "A restaurant is hiring servers. Tips can be good, and it's a social job. Could be a decent first job.",
	choices = {
		{
			id = "apply_restaurant",
			text = "Apply for the server job.",
			resultText = "You get hired! Tips are good and you meet interesting people.",
			flags = flagSet("first_job", "employed", "restaurant_server", "ever_worked"),
			effects = { Money = 1600, Happiness = 2, Looks = 1 },
		},
		{
			id = "decline_restaurant",
			text = "Not interested in serving.",
			resultText = "You decide against it.",
			effects = { Happiness = -1 },
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- COLLEGE STUDENT JOBS (AGES 18-25, requires education)
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "first_job_campus_job",
	emoji = "🏫",
	title = "First Job: Campus Job",
	category = "work",
	tags = {"work", "first_job", "campus", "student", "college"},
	weight = 26,
	oneTime = true,
	conditions = {
		minAge = 18,
		maxAge = 25,
		blockedFlags = {"employed", "has_job", "ever_worked", "first_job"},
		requiredAnyFlags = {"in_school", "college_student", "enrolled"},
	},
	text = "Your school has campus jobs available. They work around your class schedule and are convenient.",
	choices = {
		{
			id = "apply_campus",
			text = "Apply for a campus job.",
			resultText = "You get a campus job! It fits perfectly with your schedule.",
			flags = flagSet("first_job", "employed", "campus_worker", "ever_worked"),
			effects = { Money = 1200, Happiness = 2, Smarts = 1 },
		},
		{
			id = "decline_campus",
			text = "Focus on studies instead.",
			resultText = "You decide to focus on your studies.",
			effects = { Smarts = 1 },
		},
	},
})

return { events = events }
