-- LifeEvents/adult_18_35.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- YOUNG ADULT EVENTS (Ages 18-35)
-- College, early career, relationships, independence
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- TURNING 18 / ADULTHOOD
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_adult_birthday",
		minAge = 18, maxAge = 18,
		weight = 100, oneTime = true, milestone = true,
		emoji = "🎉", title = "You're 18! Legal Adult!",
		category = "milestone",
		text = "Happy 18th birthday! You're legally an adult now. The world is yours.",
		choices = {
			{ text = "🎉 Party hard!", effects = { Happiness = 15 }, resultText = "Best birthday party ever!" },
			{ text = "📝 Register to vote", effects = { Smarts = 3, Happiness = 5 }, resultText = "Civic duty!", setFlag = "can_vote" },
			{ text = "🚗 Road trip!", effects = { Happiness = 10 }, resultText = "Freedom on the open road!" },
		},
	},
	
	{
		id = "m_move_out",
		minAge = 18, maxAge = 25,
		weight = 50, oneTime = true,
		emoji = "🏠", title = "Moving Out!",
		category = "family",
		getDynamicData = function()
			return { city = LifeEvents.randomCity() }
		end,
		text = "Time to leave the nest! You're moving to %city%.",
		choices = {
			{ text = "🏠 First apartment!", effects = { Happiness = 10, Money = -5000 }, resultText = "Your own place! Freedom!", setFlag = "moved_out" },
			{ text = "👥 Get roommates", effects = { Happiness = 6, Money = -2000 }, resultText = "Splitting rent makes it affordable.", setFlag = "moved_out" },
			{ text = "🏠 Stay home longer", effects = { Happiness = -3, Money = 3000 }, resultText = "Saving money but losing independence." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- COLLEGE YEARS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_college_start",
		minAge = 18, maxAge = 22,
		weight = 70, oneTime = true, milestone = true,
		emoji = "🎓", title = "Starting College!",
		category = "school",
		requiresFlag = "college_accepted",
		getDynamicData = function()
			return { university = LifeEvents.randomUniversity() }
		end,
		text = "Welcome to %university%! Four years of education ahead.",
		choices = {
			{ text = "📚 Focus on studies", effects = { Smarts = 8, Happiness = 3, Money = -20000 }, resultText = "You're here to learn!", setFlag = "college_student" },
			{ text = "🎉 Party life!", effects = { Happiness = 10, Smarts = -2, Money = -25000 }, resultText = "College is for experiences!", setFlag = "college_student" },
			{ text = "⚖️ Balance both", effects = { Smarts = 5, Happiness = 6, Money = -22000 }, resultText = "Work hard, play hard.", setFlag = "college_student" },
		},
	},
	
	{
		id = "m_college_major",
		minAge = 19, maxAge = 21,
		weight = 60, oneTime = true,
		emoji = "📖", title = "Declaring a Major",
		category = "school",
		requiresFlag = "college_student",
		getDynamicData = function()
			local majors = {"Computer Science", "Business", "Biology", "Psychology", "Engineering", "Art", "Communications", "Economics"}
			return { major = majors[math.random(#majors)] }
		end,
		text = "Time to declare your major. You're leaning toward %major%.",
		choices = {
			{ text = "📚 %major% it is!", effects = { Smarts = 5, Happiness = 3 }, resultText = "You've chosen your path." },
			{ text = "🤔 Change it later", effects = { Smarts = 2, Happiness = -2 }, resultText = "You're still figuring it out." },
			{ text = "📚 Double major", effects = { Smarts = 8, Happiness = -3, Health = -3 }, resultText = "Ambitious but exhausting!" },
		},
	},
	
	{
		id = "m_college_graduation",
		minAge = 21, maxAge = 26,
		weight = 80, oneTime = true, milestone = true,
		emoji = "🎓", title = "College Graduation!",
		category = "school",
		requiresFlag = "college_student",
		text = "You did it! Bachelor's degree earned. What comes next?",
		choices = {
			{ text = "🎓 Celebrate!", effects = { Happiness = 15 }, resultText = "You're a college graduate!", setFlags = {"college_graduate", "bachelors_degree"}, clearFlag = "college_student" },
			{ text = "📚 Graduate school?", effects = { Smarts = 5, Happiness = 3 }, resultText = "Maybe more education...", setFlags = {"college_graduate", "considering_grad_school"}, clearFlag = "college_student" },
			{ text = "💼 Time to work", effects = { Happiness = 8, Smarts = 2 }, resultText = "Ready to start your career!", setFlags = {"college_graduate", "job_hunting"}, clearFlag = "college_student" },
		},
	},
	
	{
		id = "m_student_loans",
		minAge = 22, maxAge = 35,
		weight = 40, cooldown = 3,
		emoji = "💸", title = "Student Loan Bills",
		category = "money",
		requiresFlag = "college_graduate",
		text = "Those student loans are coming due. $50,000 in debt.",
		choices = {
			{ text = "💰 Pay them off", effects = { Money = -10000, Happiness = -3 }, resultText = "Making progress on debt." },
			{ text = "😰 Minimum payments", effects = { Happiness = -5 }, resultText = "Interest keeps growing." },
			{ text = "🎓 Loan forgiveness?", effects = { Smarts = 3, Happiness = 2 }, resultText = "You're exploring options." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- EARLY CAREER
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_first_real_job",
		minAge = 20, maxAge = 28,
		weight = 60, oneTime = true,
		emoji = "💼", title = "First Full-Time Job!",
		category = "work",
		getDynamicData = function()
			return { company = LifeEvents.randomCompany() }
		end,
		text = "You landed a job at %company%! Your career begins.",
		choices = {
			{ text = "💪 Work your way up!", effects = { Happiness = 8, Smarts = 3, Money = 5000 }, resultText = "You're determined to succeed!", setFlag = "employed" },
			{ text = "😎 Just do the job", effects = { Happiness = 5, Money = 3000 }, resultText = "It's just a paycheck.", setFlag = "employed" },
			{ text = "🚀 Impress everyone", effects = { Happiness = 6, Smarts = 5, Health = -3, Money = 4000 }, resultText = "Working overtime to stand out.", setFlag = "employed" },
		},
	},
	
	{
		id = "m_job_promotion_early",
		minAge = 22, maxAge = 32,
		weight = 35, cooldown = 3,
		emoji = "⬆️", title = "Promotion!",
		category = "work",
		requiresFlag = "employed",
		getDynamicData = function()
			local titles = {"Senior Associate", "Team Lead", "Manager", "Supervisor"}
			return { title = titles[math.random(#titles)] }
		end,
		text = "You've been promoted to %title%! More responsibility, more pay.",
		choices = {
			{ text = "🎉 Accept gladly!", effects = { Happiness = 12, Money = 10000 }, resultText = "Moving up the ladder!", setFlag = "promoted" },
			{ text = "💰 Negotiate higher", effects = { Smarts = 3, Happiness = 8, Money = 15000 }, resultText = "You got even more!" },
			{ text = "🤔 Not sure I want it", effects = { Happiness = -3 }, resultText = "Pressure isn't for everyone." },
		},
	},
	
	{
		id = "m_startup_opportunity",
		minAge = 22, maxAge = 35,
		weight = 20, oneTime = true,
		emoji = "🚀", title = "Startup Opportunity!",
		category = "work",
		getDynamicData = function()
			local startups = {"tech startup", "e-commerce venture", "app idea", "service platform"}
			return { idea = startups[math.random(#startups)] }
		end,
		text = "A friend wants you to join their %idea%. Ground floor opportunity!",
		choices = {
			{ text = "🚀 Join the startup!", effects = { Happiness = 10, Money = -10000 }, resultText = "High risk, high reward!", setFlag = "startup_founder" },
			{ text = "💼 Stay with safe job", effects = { Happiness = 3, Money = 5000 }, resultText = "Stability is underrated." },
			{ text = "💰 Invest only", effects = { Money = -5000, Smarts = 2 }, resultText = "You put in some money, kept your job." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- RELATIONSHIPS & LOVE
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_serious_relationship",
		minAge = 20, maxAge = 35,
		weight = 40, oneTime = true,
		emoji = "💕", title = "Serious Relationship",
		category = "romance",
		getDynamicData = function()
			return { partnerName = LifeEvents.randomFirstName() }
		end,
		text = "You've been dating %partnerName% for a while. It's getting serious.",
		choices = {
			{ text = "💕 Fall deeper in love", effects = { Happiness = 15 }, resultText = "This could be the one.", setFlag = "in_relationship" },
			{ text = "🏠 Move in together", effects = { Happiness = 12, Money = -3000 }, resultText = "Big step! Living together.", setFlag = "living_together" },
			{ text = "🤔 Pump the brakes", effects = { Happiness = -5 }, resultText = "You're not ready for this level." },
		},
	},
	
	{
		id = "m_proposal",
		minAge = 22, maxAge = 40,
		weight = 30, oneTime = true, milestone = true,
		emoji = "💍", title = "The Proposal!",
		category = "romance",
		requiresFlag = "living_together",
		getDynamicData = function()
			return { partnerName = LifeEvents.randomFirstName() }
		end,
		text = "It's time. You're going to propose to %partnerName%!",
		choices = {
			{ text = "💍 They said YES!", effects = { Happiness = 25, Money = -8000 }, resultText = "You're engaged!", setFlag = "engaged" },
			{ text = "😢 They said no...", effects = { Happiness = -20 }, resultText = "Devastating. The relationship might be over." },
			{ text = "🤔 Not yet", effects = { Happiness = -3 }, resultText = "You chickened out. The ring stays in your pocket." },
		},
	},
	
	{
		id = "m_wedding",
		minAge = 22, maxAge = 45,
		weight = 50, oneTime = true, milestone = true,
		emoji = "💒", title = "Wedding Day!",
		category = "romance",
		requiresFlag = "engaged",
		text = "The big day is here! You're getting married!",
		choices = {
			{ text = "💒 Perfect wedding!", effects = { Happiness = 30, Money = -25000 }, resultText = "The happiest day of your life!", setFlags = {"married", "wedding_ceremony"}, clearFlag = "engaged" },
			{ text = "🏛️ Small ceremony", effects = { Happiness = 20, Money = -5000 }, resultText = "Intimate and meaningful.", setFlags = {"married"}, clearFlag = "engaged" },
			{ text = "📝 Courthouse wedding", effects = { Happiness = 15, Money = -500 }, resultText = "Simple and efficient.", setFlags = {"married"}, clearFlag = "engaged" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- LIFE CHALLENGES
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_quarter_life_crisis",
		minAge = 24, maxAge = 28,
		weight = 30, oneTime = true,
		emoji = "😰", title = "Quarter Life Crisis",
		category = "health",
		text = "What am I doing with my life? Everyone else seems to have it figured out.",
		choices = {
			{ text = "🧘 Find yourself", effects = { Happiness = 5, Smarts = 5 }, resultText = "You took time for self-discovery." },
			{ text = "🌎 Travel the world", effects = { Happiness = 15, Money = -10000 }, resultText = "You went on a journey of self-discovery.", setFlag = "world_traveler" },
			{ text = "💪 Double down on work", effects = { Happiness = -5, Money = 10000, Smarts = 3 }, resultText = "You buried yourself in productivity." },
			{ text = "😭 Have a breakdown", effects = { Happiness = -15, Health = -5 }, resultText = "It all became too much." },
		},
	},
	
	{
		id = "m_buying_first_car",
		minAge = 18, maxAge = 30,
		weight = 45, oneTime = true,
		emoji = "🚗", title = "Buying Your First Car!",
		category = "money",
		getDynamicData = function()
			local cars = {"used Honda Civic", "Toyota Camry", "Chevy sedan", "Ford compact"}
			return { car = cars[math.random(#cars)] }
		end,
		text = "Time to buy your first car! A %car% is in your budget.",
		choices = {
			{ text = "🚗 Buy it!", effects = { Happiness = 10, Money = -15000 }, resultText = "You have wheels!", setFlag = "car_owner" },
			{ text = "🚗 Go fancier", effects = { Happiness = 12, Money = -30000 }, resultText = "You got a nicer car!", setFlag = "car_owner" },
			{ text = "🚌 Keep using transit", effects = { Happiness = -3, Money = 5000 }, resultText = "Saving money but less convenient." },
		},
	},
	
	{
		id = "m_first_home_purchase",
		minAge = 25, maxAge = 38,
		weight = 30, oneTime = true, milestone = true,
		emoji = "🏠", title = "Buying Your First Home!",
		category = "money",
		requiresFlag = "employed",
		getDynamicData = function()
			local homes = {"small condo", "starter home", "townhouse", "fixer-upper"}
			return { home = homes[math.random(#homes)] }
		end,
		text = "You can afford a %home%! Time to stop renting.",
		choices = {
			{ text = "🏠 Buy it!", effects = { Happiness = 20, Money = -50000 }, resultText = "You're a homeowner!", setFlag = "homeowner" },
			{ text = "🏠 Bigger place", effects = { Happiness = 15, Money = -100000 }, resultText = "Stretch for something nicer.", setFlag = "homeowner" },
			{ text = "🤔 Keep renting", effects = { Happiness = -3 }, resultText = "Not ready for that commitment." },
		},
	},
}

return module
