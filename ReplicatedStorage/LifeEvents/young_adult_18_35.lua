-- LifeEvents/young_adult_18_35.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- YOUNG ADULT EVENTS (Ages 18-35) - MASSIVE EXPANSION
-- 140+ deeply thought-out events for college, career, and early adulthood
-- ═══════════════════════════════════════════════════════════════════════════════

-- LOCAL HELPER FUNCTIONS (no external dependencies)
local FIRST_NAMES = {"Alex", "Jordan", "Taylor", "Casey", "Morgan", "Riley", "Jamie", "Cameron", "Quinn", "Avery", "Parker", "Skyler", "Dakota", "Reese", "Finley", "Sage", "Rowan", "Charlie", "Emerson", "Hayden"}

local function randomFirstName()
	return FIRST_NAMES[math.random(#FIRST_NAMES)]
end

local function hasFriend(state)
	if not state then return false end
	local relationships = state.Relationships or {}
	for _, rel in pairs(relationships) do
		if rel.type == "friend" or rel.category == "friends" then
			return true
		end
	end
	local flags = state.Flags or {}
	return flags.has_friend or flags.has_best_friend or flags.social_butterfly or false
end

local function getFriendName(state)
	if not state then return randomFirstName() end
	local relationships = state.Relationships or {}
	for _, rel in pairs(relationships) do
		if rel.type == "friend" or rel.category == "friends" then
			return rel.name or randomFirstName()
		end
	end
	return randomFirstName()
end

local function hasPartner(state)
	if not state then return false end
	local relationships = state.Relationships or {}
	for _, rel in pairs(relationships) do
		if rel.type == "romance" or rel.category == "romance" then
			return true
		end
	end
	local flags = state.Flags or {}
	return flags.in_relationship or flags.married or flags.dating or false
end

local function getPartnerName(state)
	if not state then return randomFirstName() end
	local relationships = state.Relationships or {}
	for _, rel in pairs(relationships) do
		if rel.type == "romance" or rel.category == "romance" then
			return rel.name or randomFirstName()
		end
	end
	return randomFirstName()
end

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- COLLEGE YEARS (Ages 18-22)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_college_start",
		minAge = 18, maxAge = 18,
		weight = 90, milestone = true, oneTime = true,
		emoji = "🎓", title = "Starting College!",
		category = "school",
		getDynamicData = function()
			local dorms = {"ancient dorm with no AC", "modern suite-style living", "party dorm", "quiet study dorm", "themed living community"}
			local majors = {"Undeclared", "Pre-Med", "Engineering", "Business", "Liberal Arts", "Computer Science", "Psychology", "Communications"}
			return { dorm = dorms[math.random(#dorms)], major = majors[math.random(#majors)] }
		end,
		text = "Welcome to college! You're living in a %dorm% and starting as a %major% major!",
		choices = {
			{ text = "📚 Academic focus!", effects = { Smarts = 10, Happiness = 4 }, resultText = "Dean's list incoming! You're here to learn.", setFlag = "college_student" },
			{ text = "🎉 College experience!", effects = { Happiness = 12, Smarts = 3 }, resultText = "Best four years of your life! Making memories!", setFlag = "college_student" },
			{ text = "🤝 Find your people", effects = { Happiness = 8, Smarts = 4 }, resultText = "Joined clubs, made friends. This is home now!", setFlag = "college_student" },
			{ text = "😰 Homesick already", effects = { Happiness = -4, Smarts = 2 }, resultText = "It's a big adjustment. You'll get through it.", setFlag = "college_student" },
		},
	},
	
	{
		id = "m_roommate_lottery",
		minAge = 18, maxAge = 19,
		weight = 50, oneTime = true,
		emoji = "🛏️", title = "Roommate Situation!",
		category = "social",
		getDynamicData = function()
			return { roommateName = randomFirstName() }
		end,
		text = "You've been paired with %roommateName% as your roommate!",
		choices = {
			{ text = "🤝 Best friends!", effects = { Happiness = 12 }, resultText = "You and %roommateName% are inseparable! Roommate jackpot!", setFlag = "good_roommate" },
			{ text = "😐 Just tolerable", effects = { Happiness = 2 }, resultText = "You coexist. Not friends, not enemies." },
			{ text = "😤 Nightmare roommate", effects = { Happiness = -8 }, resultText = "They're disgusting, loud, and inconsiderate. Housing transfer ASAP." },
			{ text = "🤫 Slowly becoming besties", effects = { Happiness = 8 }, resultText = "Started awkward, became amazing!", setFlag = "good_roommate" },
		},
	},
	
	{
		id = "m_college_major",
		minAge = 19, maxAge = 20,
		weight = 60, oneTime = true,
		emoji = "📋", title = "Declaring Your Major!",
		category = "school",
		getDynamicData = function()
			local majors = {"Computer Science", "Business", "Pre-Med", "Engineering", "Psychology", "English", "Art", "Music", "Biology", "Political Science", "Economics", "Communications", "Nursing", "Education"}
			return { major = majors[math.random(#majors)] }
		end,
		text = "Time to officially declare! You're going with %major%!",
		choices = {
			{ text = "🎯 Perfect fit!", effects = { Smarts = 8, Happiness = 8 }, resultText = "This is your passion! Career path is set!", setFlag = "declared_major" },
			{ text = "💰 Follow the money", effects = { Smarts = 6, Happiness = 2 }, resultText = "Practical choice. Job security matters.", setFlag = "declared_major" },
			{ text = "🤔 Still unsure", effects = { Smarts = 3, Happiness = -2 }, resultText = "Declaring doesn't mean you can't change later!", setFlag = "declared_major" },
			{ text = "😤 Parents' choice", effects = { Smarts = 5, Happiness = -4 }, resultText = "Not what you wanted, but they're paying...", setFlag = "declared_major" },
		},
	},
	
	{
		id = "m_college_party",
		minAge = 18, maxAge = 22,
		weight = 40, cooldown = 2,
		emoji = "🎉", title = "College Party!",
		category = "social",
		getDynamicData = function()
			local types = {"frat party", "house party", "dorm party", "club event", "tailgate"}
			return { partyType = types[math.random(#types)] }
		end,
		text = "There's a huge %partyType% tonight! Everyone's going!",
		choices = {
			{ text = "🎉 Best night ever!", effects = { Happiness = 12, Health = -3 }, resultText = "LEGENDARY night! Stories for years to come!" },
			{ text = "🍻 Maybe too much fun", effects = { Happiness = 4, Health = -8 }, resultText = "You regret some choices... never again. (Until next weekend.)" },
			{ text = "📚 Stay in and study", effects = { Smarts = 6, Happiness = 2 }, resultText = "FOMO is real but exam is tomorrow!" },
			{ text = "🕺 Met someone special", effects = { Happiness = 15 }, resultText = "That party changed everything! New relationship!", setFlag = "college_romance" },
		},
	},
	
	{
		id = "m_spring_break",
		minAge = 18, maxAge = 22,
		weight = 35, cooldown = 2,
		emoji = "🏖️", title = "Spring Break!",
		category = "social",
		requires = hasFriend,  -- MUST have friends to go on spring break with friends
		getDynamicData = function()
			local destinations = {"Cancun", "Miami", "Panama City Beach", "Vegas", "road trip", "home"}
			return { destination = destinations[math.random(#destinations)] }
		end,
		text = "Spring break! You're going to %destination% with friends!",
		choices = {
			{ text = "🏝️ Epic trip!", effects = { Happiness = 15, Money = -800, Health = -3 }, resultText = "Best spring break EVER! Worth every penny!" },
			{ text = "💰 Can't afford it", effects = { Happiness = -4, Money = 0 }, resultText = "You stayed behind while everyone else went. FOMO city." },
			{ text = "📚 Alternative break (volunteer)", effects = { Happiness = 8, Smarts = 3 }, resultText = "Helping others was fulfilling! Different kind of spring break.", setFlag = "volunteer" },
			{ text = "🏠 Went home", effects = { Happiness = 6, Money = 0 }, resultText = "Home-cooked meals and family time. Underrated." },
		},
	},
	
	{
		id = "m_college_grades",
		minAge = 18, maxAge = 22,
		weight = 45, cooldown = 2,
		emoji = "📋", title = "Semester Grades!",
		category = "school",
		text = "Finals are over. How did you approach this semester?",
		choices = {
			{ text = "📚 Studied hard all semester", effects = { Smarts = 12, Happiness = 10 }, resultText = "DEAN'S LIST! 4.0! All those library nights paid off!", setFlag = "deans_list" },
			{ text = "⚖️ Balanced school and fun", effects = { Smarts = 6, Happiness = 4 }, resultText = "Solid B average. Good balance! On track to graduate." },
			{ text = "🎉 Partied too much", effects = { Smarts = 2, Happiness = -3 }, resultText = "Barely passed. Professor curved the final, thank god." },
			{ text = "😴 Skipped way too many classes", effects = { Smarts = -2, Happiness = -8 }, resultText = "Academic probation. One more bad semester and you're out. Wake up!" },
		},
	},
	
	{
		id = "m_study_abroad",
		minAge = 19, maxAge = 21,
		weight = 25, oneTime = true,
		-- Need at least $2500 to study abroad (cheapest option)
		requires = function(state)
			return (state.Money or 0) >= 2500
		end,
		emoji = "✈️", title = "Study Abroad!",
		category = "school",
		getDynamicData = function()
			local countries = {"Italy", "Spain", "England", "France", "Japan", "Australia", "Germany", "South Korea"}
			return { country = countries[math.random(#countries)] }
		end,
		text = "You've been accepted to study abroad in %country% for a semester!",
		choices = {
			{ text = "🌍 Life-changing!", effects = { Smarts = 10, Happiness = 15, Money = -3000 }, resultText = "Best decision ever! You're forever changed!", setFlag = "studied_abroad" },
			{ text = "🤷 Can't afford it", effects = { Happiness = -4 }, resultText = "Too expensive. Wonder what it would have been like..." },
			{ text = "💕 International romance", effects = { Happiness = 12, Smarts = 5, Money = -2500 }, resultText = "Found love abroad! Long-distance is hard though...", setFlags = {"studied_abroad", "international_romance"} },
			{ text = "📚 Academic growth", effects = { Smarts = 15, Happiness = 8, Money = -2500 }, resultText = "Expanded your worldview! So much learning!", setFlags = {"studied_abroad", "worldly"} },
		},
	},
	
	{
		id = "m_college_internship",
		minAge = 20, maxAge = 22,
		weight = 40, cooldown = 2,
		emoji = "💼", title = "College Internship!",
		category = "career",
		requiresFlag = "college_student",
		getDynamicData = function()
			local companies = {"TechStart Inc", "GlobalCorp", "CareFoundation", "Innovation Labs", "MediaMax", "Capital Partners", "City Hospital"}
			return { company = companies[math.random(#companies)] }
		end,
		text = "You landed a summer internship at %company%!",
		choices = {
			{ 
				text = "🌟 Return offer!", 
				effects = { Smarts = 8, Money = 4000, Happiness = 10 }, 
				resultText = "They want you back full-time after graduation!", 
				setFlag = "has_job_offer",
				setJob = { id = "intern", title = "Intern", salary = 20000 }
			},
			{ 
				text = "📚 Great experience", 
				effects = { Smarts = 6, Money = 2500, Happiness = 5 }, 
				resultText = "Resume looks amazing now! Valuable skills learned.",
				setJob = { id = "intern", title = "Intern", salary = 18000 }
			},
			{ 
				text = "😴 Coffee runs and filing", 
				effects = { Smarts = 2, Money = 1500, Happiness = -2 }, 
				resultText = "Grunt work. At least it pays?",
				setJob = { id = "intern", title = "Intern", salary = 15000 }
			},
			{ 
				text = "🔗 Networking gold", 
				effects = { Smarts = 4, Money = 2000, Happiness = 6 }, 
				resultText = "Made invaluable connections!", 
				setFlag = "well_connected",
				setJob = { id = "intern", title = "Intern", salary = 18000 }
			},
		},
	},
	
	{
		id = "m_graduation_college",
		minAge = 21, maxAge = 23,
		weight = 90, milestone = true, oneTime = true,
		emoji = "🎓", title = "COLLEGE GRADUATION!",
		category = "school",
		getDynamicData = function()
			local honors = {"summa cum laude", "magna cum laude", "cum laude", "", ""}
			return { honor = honors[math.random(#honors)] }
		end,
		text = "You did it! Bachelor's degree earned %honor%! Caps in the air!",
		choices = {
			{ text = "🎉 We made it!", effects = { Happiness = 15, Smarts = 5 }, resultText = "Four years of memories! On to the next chapter!", setFlag = "college_graduate" },
			{ text = "😭 Bittersweet", effects = { Happiness = 6, Smarts = 3 }, resultText = "Saying goodbye is hard. But ready for what's next.", setFlag = "college_graduate" },
			{ text = "🎯 Grad school next!", effects = { Smarts = 10, Happiness = 4 }, resultText = "Not done learning! Graduate program awaits!", setFlags = {"college_graduate", "pursuing_grad"} },
			{ text = "💰 Time to make money", effects = { Happiness = 8, Smarts = 2 }, resultText = "Real world, here I come!", setFlag = "college_graduate" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- EARLY CAREER (Ages 22-28)
	-- ═══════════════════════════════════════════════════════════════
	
	-- ═══════════════════════════════════════════════════════════════
	-- CAREER ENTRY - REQUIRES EDUCATION + ACTIVELY SEEKING WORK
	-- In BitLife, you apply for jobs - they don't just appear!
	-- These events fire when player has been seeking employment
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_first_real_job",
		minAge = 22, maxAge = 30,
		weight = 15, oneTime = true, -- LOW weight - should apply through Jobs screen!
		emoji = "💼", title = "Job Opportunity!",
		category = "career",
		blockIfFlag = "employed",
		-- CRITICAL: Must have education AND be actively job seeking OR have job offer
		requiresAnyFlag = {"college_graduate", "ged_graduate", "has_job_offer", "job_seeking", "applied_for_jobs", "internship_completed", "well_connected"},
		-- Must have at least high school equivalent
		requires = function(state)
			local flags = state.Flags or {}
			-- Must have graduated high school at minimum (or GED)
			local hasEducation = flags.high_school_graduate or flags.ged_graduate or flags.college_graduate or flags.advanced_degree
			-- And must NOT be a dropout without GED
			local isDropout = flags.high_school_dropout and not flags.ged_graduate
			return hasEducation and not isDropout
		end,
		getDynamicData = function(state)
			local flags = state and state.Flags or {}
			-- Better jobs for better education
			local hasCollege = flags.college_graduate or flags.advanced_degree
			local hasConnections = flags.well_connected or flags.networker or flags.has_job_offer
			
			local fields
			if hasCollege and hasConnections then
				fields = {
					{ name = "tech", title = "Software Developer", salary = 75000 },
					{ name = "finance", title = "Financial Analyst", salary = 68000 },
					{ name = "consulting", title = "Associate Consultant", salary = 72000 },
					{ name = "engineering", title = "Junior Engineer", salary = 70000 },
				}
			elseif hasCollege then
				fields = {
					{ name = "tech", title = "Junior Developer", salary = 55000 },
					{ name = "finance", title = "Financial Analyst", salary = 52000 },
					{ name = "marketing", title = "Marketing Associate", salary = 45000 },
					{ name = "engineering", title = "Junior Engineer", salary = 58000 },
				}
			else
				-- High school/GED only - entry level positions
				fields = {
					{ name = "retail", title = "Assistant Manager", salary = 32000 },
					{ name = "office", title = "Administrative Assistant", salary = 30000 },
					{ name = "customer service", title = "Customer Service Rep", salary = 28000 },
					{ name = "sales", title = "Sales Associate", salary = 26000 },
				}
			end
			local chosen = fields[math.random(#fields)]
			return { field = chosen.name, title = chosen.title, salary = chosen.salary }
		end,
		text = "After putting yourself out there, you landed a job in %field%! Starting salary: $%salary%!",
		choices = {
			{ 
				text = "🎉 Dream job!", 
				effects = { Happiness = 12, Smarts = 3 }, 
				resultText = "You love what you do! That's the dream!", 
				setFlags = {"employed", "career_starter"},
				clearFlags = {"job_seeking", "applied_for_jobs"},
				setJob = { id = "entry_level", title = "%title%", salary = 50000 }
			},
			{ 
				text = "🤷 It's a job", 
				effects = { Happiness = 4, Smarts = 2 }, 
				resultText = "Not perfect, but pays the bills.", 
				setFlags = {"employed", "career_starter"},
				clearFlags = {"job_seeking", "applied_for_jobs"},
				setJob = { id = "entry_level", title = "%title%", salary = 45000 }
			},
			{ 
				text = "😫 Entry-level grind", 
				effects = { Happiness = 2, Smarts = 4 }, 
				resultText = "Everyone starts somewhere. Working your way up!", 
				setFlags = {"employed", "career_starter"},
				clearFlags = {"job_seeking", "applied_for_jobs"},
				setJob = { id = "entry_level", title = "%title%", salary = 42000 }
			},
			{ 
				text = "💰 Negotiate salary up!", 
				effects = { Happiness = 8, Smarts = 5 }, 
				resultText = "You asked for more and got it! Always negotiate!", 
				setFlags = {"employed", "negotiator", "career_starter"},
				clearFlags = {"job_seeking", "applied_for_jobs"},
				setJob = { id = "entry_level", title = "%title%", salary = 58000 }
			},
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- STRUGGLING ADULT EVENTS - Reality check for unprepared adults
	-- No education + No job = Hard times (like real BitLife)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_struggling_adult_no_education",
		minAge = 19, maxAge = 35,
		weight = 60, cooldown = 2,
		emoji = "😰", title = "Reality Check",
		category = "career",
		blockIfFlag = "employed",
		requiresFlag = "high_school_dropout",
		blockIfFlag2 = "ged_graduate", -- Don't fire if they got GED
		text = "No diploma, no job. Bills are piling up. Parents are asking when you'll get your life together.",
		choices = {
			{ 
				text = "📚 Time to get GED", 
				effects = { Happiness = 4, Smarts = 5, Money = -300 }, 
				resultText = "Enrolled in a GED program. It's time to turn things around!",
				setFlags = {"pursuing_ged", "taking_responsibility"},
				clearFlag = "high_school_dropout"
			},
			{ 
				text = "🔧 Learn a trade", 
				effects = { Happiness = 6, Smarts = 4 }, 
				resultText = "Signed up for trade school. Electricians, plumbers make good money!",
				setFlag = "trade_student"
			},
			{ 
				text = "🏠 Move back home", 
				effects = { Happiness = -6, Money = 500 }, 
				resultText = "Swallowed your pride. Living with parents again. At least rent is free.",
				setFlag = "living_with_parents"
			},
			{ 
				text = "😤 Ignore the problem", 
				effects = { Happiness = -10, Health = -5 }, 
				resultText = "Burying your head in the sand. The problems aren't going away.",
				setFlag = "in_denial"
			},
		},
	},
	
	{
		id = "m_minimum_wage_struggle",
		minAge = 18, maxAge = 40,
		weight = 45, cooldown = 3,
		emoji = "💸", title = "Paycheck to Paycheck",
		category = "career",
		requiresFlag = "employed",
		-- Only for low-level jobs without education
		requires = function(state)
			local flags = state.Flags or {}
			local hasCollege = flags.college_graduate or flags.advanced_degree
			local job = state.CurrentJob or ""
			local isLowPayJob = job == "" or job:match("entry") or job:match("minimum") or job:match("part_time")
			return not hasCollege and (state.Money or 0) < 5000
		end,
		text = "Rent, food, bills... your paycheck barely covers the basics. There's never anything left.",
		choices = {
			{ 
				text = "💪 Second job time", 
				effects = { Money = 800, Health = -8, Happiness = -4 }, 
				resultText = "Picked up a second job. Exhausted but making ends meet.",
				setFlag = "second_job"
			},
			{ 
				text = "📚 Invest in education", 
				effects = { Smarts = 6, Happiness = 4, Money = -1000 }, 
				resultText = "Started night classes. Playing the long game for a better career.",
				setFlag = "continuing_education"
			},
			{ 
				text = "🍜 Cut all expenses", 
				effects = { Money = 400, Happiness = -6 }, 
				resultText = "Ramen every night. No fun. But you're saving something.",
				setFlag = "frugal"
			},
			{ 
				text = "💳 Credit card it", 
				effects = { Money = 1000, Happiness = 2 }, 
				resultText = "Living on credit. This will catch up with you eventually...",
				setFlag = "in_debt"
			},
		},
	},
	
	{
		id = "m_homelessness_warning",
		minAge = 20, maxAge = 50,
		weight = 30, oneTime = true,
		emoji = "🏠", title = "Eviction Notice!",
		category = "career",
		blockIfFlag = "employed",
		blockIfFlag2 = "homeowner",
		-- Must be broke and jobless
		requires = function(state)
			return (state.Money or 0) < 500
		end,
		text = "EVICTION NOTICE on your door. You have 30 days to pay rent or you're out on the street.",
		choices = {
			{ 
				text = "🏠 Move in with family", 
				effects = { Happiness = -8, Money = 200 }, 
				resultText = "Pride shattered, but you have a roof. Family took you in.",
				setFlags = {"living_with_parents", "rock_bottom"},
				clearFlag = "has_apartment"
			},
			{ 
				text = "🆘 Seek emergency assistance", 
				effects = { Happiness = -4, Money = 1500 }, 
				resultText = "Found a housing assistance program. They helped with this month's rent.",
				setFlag = "received_assistance"
			},
			{ 
				text = "💼 Beg for any job", 
				effects = { Happiness = -10, Money = 800 }, 
				resultText = "Took a terrible job but it pays. Barely enough to stay housed.",
				setFlags = {"employed", "desperate_work"},
				setJob = { id = "minimum_wage", title = "Fast Food Worker", salary = 18000 }
			},
			{ 
				text = "😔 Accept fate", 
				effects = { Happiness = -20, Health = -10, Money = -500 }, 
				resultText = "Couldn't pay. Lost everything. You're homeless now.",
				setFlags = {"homeless", "rock_bottom"},
				clearFlags = {"has_apartment", "homeowner"}
			},
		},
	},
	
	{
		id = "m_homeless_life",
		minAge = 18, maxAge = 70,
		weight = 70, cooldown = 1,
		emoji = "🏚️", title = "Life on the Streets",
		category = "health",
		requiresFlag = "homeless",
		text = "Another day without a home. Cold nights, uncertain meals. This is rock bottom.",
		choices = {
			{ 
				text = "🏠 Shelter for the night", 
				effects = { Health = 5, Happiness = 2 }, 
				resultText = "Found a bed at the homeless shelter. Warm meal too. Small mercies.",
				setFlag = "using_shelter"
			},
			{ 
				text = "💼 Look for work", 
				effects = { Happiness = 4, Smarts = 2 }, 
				resultText = "Hard to get hired without an address, but you're trying.",
				setFlag = "job_seeking"
			},
			{ 
				text = "🆘 Seek social services", 
				effects = { Happiness = 6, Money = 200 }, 
				resultText = "Got connected with a case worker. There's hope for getting back on your feet.",
				setFlag = "getting_help"
			},
			{ 
				text = "😔 Give up hope", 
				effects = { Happiness = -15, Health = -10 }, 
				resultText = "Darkness consumes you. Each day is just survival.",
				setFlag = "hopeless"
			},
		},
	},
	
	{
		id = "m_comeback_story",
		minAge = 20, maxAge = 50,
		weight = 40, oneTime = true,
		emoji = "🌅", title = "A Second Chance",
		category = "social",
		requiresFlag = "rock_bottom",
		blockIfFlag = "employed",
		text = "Someone sees potential in you. An opportunity to turn your life around presents itself.",
		choices = {
			{ 
				text = "🙏 Accept with gratitude", 
				effects = { Happiness = 15, Smarts = 5 }, 
				resultText = "You grabbed the lifeline! Someone believed in you when you didn't believe in yourself.",
				setFlags = {"second_chance", "motivated"},
				clearFlags = {"hopeless", "in_denial"}
			},
			{ 
				text = "💼 Prove yourself", 
				effects = { Happiness = 10, Money = 500 }, 
				resultText = "Given a chance to work. You're going to show them they made the right choice!",
				setFlags = {"employed", "second_chance", "proving_myself"},
				setJob = { id = "second_chance", title = "Worker", salary = 24000 }
			},
			{ 
				text = "😰 Scared to fail again", 
				effects = { Happiness = -4 }, 
				resultText = "Fear holds you back. The opportunity passes.",
			},
			{ 
				text = "🔥 This is my moment", 
				effects = { Happiness = 20, Smarts = 8 }, 
				resultText = "Rock bottom became the foundation for your comeback. LET'S GO!",
				setFlags = {"comeback_story", "determined", "motivated"},
				clearFlags = {"hopeless", "rock_bottom", "homeless"}
			},
		},
	},
	
	{
		id = "m_quarter_life_crisis",
		minAge = 24, maxAge = 27,
		weight = 40, oneTime = true,
		emoji = "😰", title = "Quarter-Life Crisis",
		category = "social",
		text = "What am I doing with my life? Is this it? Everyone else seems to have it figured out!",
		choices = {
			{ text = "🔄 Major life change", effects = { Happiness = 8, Smarts = 4 }, resultText = "You quit your job, moved cities, changed everything!", setFlag = "quarter_life_reset" },
			{ text = "🧘 Self-reflection", effects = { Happiness = 4, Smarts = 6 }, resultText = "Therapy and introspection helped. It's okay to not have answers.", setFlag = "self_aware" },
			{ text = "💪 Push through", effects = { Happiness = 2, Smarts = 3 }, resultText = "Crisis? What crisis? Keep grinding." },
			{ text = "🗣️ Talk to friends", effects = { Happiness = 6 }, resultText = "Everyone's going through the same thing. You're not alone." },
		},
	},
	
	{
		id = "m_first_apartment",
		minAge = 22, maxAge = 26,
		weight = 50, oneTime = true,
		emoji = "🏠", title = "First Apartment!",
		category = "family",
		getDynamicData = function()
			local types = {"studio in the city", "1-bedroom with roommate", "cheap place in not-so-great area", "nice apartment (broke now)", "shared house"}
			local rent = math.random(800, 2200)
			return { apartmentType = types[math.random(#types)], rent = rent }
		end,
		text = "You're signing your first lease! A %apartmentType% for $%rent%/month!",
		choices = {
			{ text = "🏠 TRUE independence!", effects = { Happiness = 12, Money = -3000 }, resultText = "Your own space! Finally, adult life!", setFlag = "has_apartment" },
			{ text = "💸 Broke but happy", effects = { Happiness = 6, Money = -4000 }, resultText = "Worth every penny for your own place!", setFlag = "has_apartment" },
			{ text = "🛋️ Furnished with freebies", effects = { Happiness = 8, Money = -2000 }, resultText = "Facebook Marketplace and family hand-me-downs FTW!", setFlag = "has_apartment" },
			{ text = "😰 Adulting is expensive", effects = { Happiness = 2, Money = -3500 }, resultText = "Rent, utilities, groceries... how do adults do this?!", setFlag = "has_apartment" },
		},
	},
	
	{
		id = "m_workplace_romance",
		minAge = 22, maxAge = 35,
		weight = 20, oneTime = true,
		emoji = "💕", title = "Office Romance",
		category = "social",
		requiresFlag = "employed", -- Must have a job to have a workplace romance!
		getDynamicData = function()
			return { coworkerName = randomFirstName() }
		end,
		text = "You've developed feelings for your coworker %coworkerName%! Is this a good idea?",
		choices = {
			{ text = "💕 Go for it!", effects = { Happiness = 12 }, resultText = "You asked them out! They said yes! Worth the risk!", setFlag = "office_romance" },
			{ text = "🙅 Too risky", effects = { Happiness = -2, Smarts = 4 }, resultText = "Don't mix work and love. Smart choice." },
			{ text = "😬 It got awkward", effects = { Happiness = -6 }, resultText = "Things didn't work out and now work is weird." },
			{ text = "💒 Found the one!", effects = { Happiness = 15 }, resultText = "Workplace couple success story!", setFlags = {"office_romance", "serious_relationship"} },
		},
	},
	
	{
		id = "m_promotion_1",
		minAge = 24, maxAge = 30,
		weight = 35, cooldown = 3,
		emoji = "📈", title = "Promotion Opportunity!",
		category = "career",
		requiresFlag = "employed", -- MUST be employed to get a promotion!
		getDynamicData = function()
			local titles = {"Senior", "Team Lead", "Manager", "Specialist", "Associate Director"}
			local raise = math.random(5000, 15000)
			return { title = titles[math.random(#titles)], raise = raise }
		end,
		text = "There's an opening for %title%! $%raise% raise if you get it! How do you approach it?",
		choices = {
			{ text = "📊 Prepare and apply formally", effects = { Happiness = 12, Money = 8000, Smarts = 4 }, resultText = "Your preparation impressed them! PROMOTED! Moving up!", setFlag = "promoted" },
			{ text = "🤷 Don't apply", effects = { Happiness = -8, Smarts = 2 }, resultText = "The position went to someone who did apply. Regret?" },
			{ text = "🗣️ Talk to your boss first", effects = { Happiness = 6, Smarts = 5, Money = 5000 }, resultText = "Didn't get it, but boss knows you're ambitious. Raise anyway!" },
			{ text = "💼 Start looking elsewhere", effects = { Happiness = 4, Money = 10000 }, resultText = "Found a better offer! New job with higher title AND more money!", setFlag = "job_hopper" },
		},
	},
	
	{
		id = "m_side_hustle",
		minAge = 22, maxAge = 35,
		weight = 30, oneTime = true,
		emoji = "💰", title = "Starting a Side Hustle!",
		category = "career",
		getDynamicData = function()
			local hustles = {"freelancing", "online store", "content creation", "tutoring", "rideshare", "investing", "dropshipping", "consulting"}
			return { hustle = hustles[math.random(#hustles)] }
		end,
		text = "You're starting a %hustle% side hustle for extra income!",
		choices = {
			{ text = "💸 It's taking off!", effects = { Money = 5000, Happiness = 10 }, resultText = "Extra income flowing in! Grind paid off!", setFlag = "side_hustler" },
			{ text = "📈 Slow but steady", effects = { Money = 2000, Happiness = 4, Smarts = 3 }, resultText = "Building something. Rome wasn't built in a day.", setFlag = "side_hustler" },
			{ text = "😫 Burnout risk", effects = { Money = 1500, Health = -4, Happiness = -2 }, resultText = "Two jobs is exhausting. Be careful.", setFlag = "side_hustler" },
			{ text = "🚀 Could be a real business!", effects = { Money = 3000, Smarts = 5, Happiness = 8 }, resultText = "This could replace the day job someday!", setFlags = {"side_hustler", "entrepreneur_spark"} },
		},
	},
	
	{
		id = "m_serious_relationship",
		minAge = 23, maxAge = 30,
		weight = 35, oneTime = true,
		emoji = "💕", title = "Serious Relationship!",
		category = "romance",
		-- CRITICAL: Only fire if player actually has a romantic partner!
		requires = function(state)
			return hasPartner(state)
		end,
		requiresAnyFlag = {"dating", "in_relationship", "college_romance", "office_romance", "international_romance"},
		getDynamicData = function(state)
			-- Use actual partner name from relationships, or fallback
			return { partnerName = getPartnerName(state) }
		end,
		text = "You and %partnerName% are getting serious! This could be the one!",
		choices = {
			{ text = "💕 Move in together!", effects = { Happiness = 15, Money = 2000 }, resultText = "Taking the next step! Your place is now 'our' place!", setFlags = {"serious_relationship", "living_together"} },
			{ text = "💍 Talking about the future", effects = { Happiness = 10 }, resultText = "Marriage, kids, life plans... it's real.", setFlag = "serious_relationship" },
			{ text = "🐕 Got a pet together!", effects = { Happiness = 12 }, resultText = "Fur baby! Basically married now.", setFlags = {"serious_relationship", "has_pet"} },
			{ text = "🤔 Taking it slow", effects = { Happiness = 6, Smarts = 2 }, resultText = "No rush. Making sure it's right.", setFlag = "serious_relationship" },
		},
	},
	
	{
		id = "m_engagement",
		minAge = 25, maxAge = 35,
		weight = 30, oneTime = true,
		requiresFlag = "serious_relationship",
		-- Need at least $4000 for an engagement ring (cheapest option)
		requires = function(state)
			return (state.Money or 0) >= 4000
		end,
		emoji = "💍", title = "The Proposal!",
		category = "family",
		getDynamicData = function()
			local settings = {"at a fancy restaurant", "on a beach at sunset", "at home (simple and perfect)", "in front of family", "during a trip"}
			return { setting = settings[math.random(#settings)] }
		end,
		text = "It happened %setting%! Someone got down on one knee!",
		choices = {
			{ text = "💍 THEY SAID YES!", effects = { Happiness = 20, Money = -5000 }, resultText = "YOU'RE ENGAGED! Wedding planning begins!", setFlags = {"engaged", "wedding_planning"} },
			{ text = "💕 Perfect moment", effects = { Happiness = 18, Money = -4000 }, resultText = "Tears of joy! Everything is perfect!", setFlags = {"engaged", "wedding_planning"} },
			{ text = "😰 Said yes but nervous", effects = { Happiness = 10, Money = -4000 }, resultText = "Happy but scared. Big commitment!", setFlags = {"engaged", "wedding_planning"} },
			{ text = "💔 They said no...", effects = { Happiness = -20 }, resultText = "Devastating. The relationship might be over.", clearFlags = {"serious_relationship"} },
		},
	},
	
	{
		id = "m_wedding",
		minAge = 25, maxAge = 35,
		weight = 60, oneTime = true,
		requiresFlag = "engaged",
		-- Need at least $5000 for the cheapest wedding option
		requires = function(state)
			return (state.Money or 0) >= 5000
		end,
		emoji = "💒", title = "YOUR WEDDING DAY!",
		category = "family",
		getDynamicData = function()
			local types = {"big traditional wedding", "intimate ceremony", "destination wedding", "courthouse wedding", "backyard celebration"}
			return { weddingType = types[math.random(#types)] }
		end,
		text = "The day is here! You're having a %weddingType%!",
		choices = {
			{ text = "👰 Best day of my life!", effects = { Happiness = 25, Money = -20000 }, resultText = "PERFECT. Everything was perfect. You're married!", setFlag = "married", clearFlags = {"engaged", "wedding_planning"} },
			{ text = "💕 Simple but beautiful", effects = { Happiness = 18, Money = -5000 }, resultText = "It's not about the party, it's about the person!", setFlag = "married", clearFlags = {"engaged", "wedding_planning"} },
			{ text = "😬 Wedding drama!", effects = { Happiness = 10, Money = -15000 }, resultText = "Family drama, vendor issues... but still married!", setFlag = "married", clearFlags = {"engaged", "wedding_planning"} },
			{ text = "💰 Worth every penny", effects = { Happiness = 22, Money = -25000 }, resultText = "Splurged but no regrets! Dream wedding achieved!", setFlag = "married", clearFlags = {"engaged", "wedding_planning"} },
		},
	},
	
	{
		id = "m_buying_house",
		minAge = 26, maxAge = 35,
		weight = 30, oneTime = true,
		-- Need at least $20000 for down payment (cheapest option)
		requires = function(state)
			return (state.Money or 0) >= 20000
		end,
		emoji = "🏡", title = "Buying a House!",
		category = "family",
		getDynamicData = function()
			local types = {"starter home", "condo", "fixer-upper", "nice suburban home", "urban townhouse"}
			local price = math.random(200000, 500000)
			return { homeType = types[math.random(#types)], price = price }
		end,
		text = "You're buying a %homeType%! Listed at $%price%!",
		choices = {
			{ text = "🏠 HOMEOWNER!", effects = { Happiness = 18, Money = -50000 }, resultText = "The American dream! Your name is on the deed!", setFlag = "homeowner" },
			{ text = "🔨 Fixer but potential", effects = { Happiness = 8, Money = -30000 }, resultText = "Sweat equity! Making it yours over time.", setFlag = "homeowner" },
			{ text = "💰 Stretched budget", effects = { Happiness = 10, Money = -60000 }, resultText = "House poor but happy. It'll appreciate!", setFlag = "homeowner" },
			{ text = "🏙️ Keep renting", effects = { Happiness = 2, Money = 0 }, resultText = "Not ready. Renting has its perks." },
		},
	},
	
	{
		id = "m_first_child",
		minAge = 25, maxAge = 35,
		weight = 30, oneTime = true,
		requiresFlag = "married",
		emoji = "👶", title = "Having a Baby!",
		category = "family",
		getDynamicData = function()
			local names = {"Emma", "Liam", "Olivia", "Noah", "Ava", "Ethan", "Sophia", "Mason", "Isabella", "Lucas"}
			return { babyName = names[math.random(#names)] }
		end,
		text = "You're having a baby! Welcome to the world, %babyName%!",
		choices = {
			{ text = "👶 Best moment ever!", effects = { Happiness = 25, Health = -5, Money = -5000 }, resultText = "Your life is forever changed! So much love!", setFlags = {"parent", "has_child"} },
			{ text = "😴 Sleep? What's that?", effects = { Happiness = 12, Health = -8 }, resultText = "Exhausted but in love. Worth every sleepless night.", setFlags = {"parent", "has_child"} },
			{ text = "💕 Growing family", effects = { Happiness = 20, Money = -4000 }, resultText = "Family of three! This is what life's about.", setFlags = {"parent", "has_child"} },
			{ text = "😰 Terrified but ready", effects = { Happiness = 10, Smarts = 3 }, resultText = "No one's truly ready. But you'll figure it out!", setFlags = {"parent", "has_child"} },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- ESTABLISHING YOURSELF (Ages 28-35)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_career_crossroads",
		minAge = 28, maxAge = 33,
		weight = 35, oneTime = true,
		emoji = "🔀", title = "Career Crossroads",
		category = "career",
		requiresFlag = "employed", -- Must have a career to be at crossroads!
		text = "Stay on current path, or make a big change? Pivot, or climb?",
		choices = {
			{ text = "🔄 Complete career change", effects = { Happiness = 8, Money = -5000, Smarts = 5 }, resultText = "Started over in a new field! Scary but exciting!", setFlag = "career_pivot", clearFlag = "employed" },
			{ text = "🚀 Go all in", effects = { Money = 8000, Happiness = 6, Smarts = 4 }, resultText = "Doubled down on your career. Leadership track!", setFlag = "career_focused" },
			{ text = "🎓 Back to school", effects = { Smarts = 12, Money = -20000, Happiness = 4 }, resultText = "Grad degree to level up!", setFlag = "pursuing_grad" },
			{ text = "💼 Start a business", effects = { Money = -10000, Happiness = 8, Smarts = 6 }, resultText = "Entrepreneur life! Your own boss!", setFlags = {"entrepreneur", "business_owner"} },
		},
	},
	
	{
		id = "m_grad_school",
		minAge = 24, maxAge = 32,
		weight = 25, oneTime = true,
		-- Need at least $5000 (cheapest option with employer help)
		requires = function(state)
			return (state.Money or 0) >= 5000
		end,
		emoji = "🎓", title = "Graduate School!",
		category = "school",
		getDynamicData = function()
			local degrees = {"MBA", "Law Degree (JD)", "Medical Degree (MD)", "Master's", "PhD"}
			return { degree = degrees[math.random(#degrees)] }
		end,
		text = "You're pursuing a %degree%! More school, more loans, more opportunity!",
		choices = {
			{ text = "🎯 Top of class!", effects = { Smarts = 15, Happiness = 8, Money = -30000 }, resultText = "Honors! This will open doors!", setFlag = "advanced_degree" },
			{ text = "📚 Grinding through", effects = { Smarts = 10, Happiness = 2, Money = -25000 }, resultText = "It's hard work but you're doing it!", setFlag = "advanced_degree" },
			{ text = "🤝 Made great connections", effects = { Smarts = 8, Happiness = 6, Money = -25000 }, resultText = "The network is worth the tuition!", setFlags = {"advanced_degree", "well_connected"} },
			{ text = "💰 Employer paid!", effects = { Smarts = 10, Happiness = 8, Money = -5000 }, resultText = "Work subsidized your education! Smart move!", setFlag = "advanced_degree" },
		},
	},
	
	{
		id = "m_career_success",
		minAge = 30, maxAge = 35,
		weight = 30, oneTime = true,
		emoji = "🏆", title = "Major Career Win!",
		category = "career",
		requiresFlag = "employed", -- CRITICAL: Must be employed to have career success!
		blockIfFlag = "career_achiever", -- Only fire once
		getDynamicData = function()
			local wins = {"big promotion", "industry award", "major project completion", "executive position", "salary milestone"}
			return { win = wins[math.random(#wins)] }
		end,
		text = "You achieved a huge %win%! All that hard work paid off!",
		choices = {
			{ text = "🎉 Celebrate big!", effects = { Happiness = 15, Money = 15000 }, resultText = "You earned this! Drinks on you!", setFlag = "career_achiever" },
			{ text = "💪 Stay humble", effects = { Happiness = 8, Money = 12000, Smarts = 3 }, resultText = "Success is a journey, not a destination.", setFlag = "career_achiever" },
			{ text = "🎯 What's next?", effects = { Happiness = 10, Money = 12000, Smarts = 4 }, resultText = "Already planning the next level!", setFlags = {"career_achiever", "ambitious"} },
			{ text = "🙏 Thank those who helped", effects = { Happiness = 12, Money = 11000 }, resultText = "You didn't do it alone. Gratitude matters.", setFlags = {"career_achiever", "grateful"} },
		},
	},
	
	{
		id = "m_investment_windfall",
		minAge = 25, maxAge = 35,
		weight = 15, oneTime = true,
		emoji = "📈", title = "Investment Pays Off!",
		category = "career",
		getDynamicData = function()
			local types = {"stocks", "crypto", "startup equity", "real estate", "side business"}
			local amount = math.random(10000, 100000)
			return { investmentType = types[math.random(#types)], amount = amount }
		end,
		text = "Your %investmentType% investment paid off BIG! $%amount% profit!",
		choices = {
			{ text = "💰 Cash out!", effects = { Money = 50000, Happiness = 15 }, resultText = "Liquid baby! That's a nice payday!" },
			{ text = "📈 Let it ride", effects = { Smarts = 5, Happiness = 6 }, resultText = "Compound growth! Playing the long game.", setFlag = "investor" },
			{ text = "🏠 Buy something big", effects = { Happiness = 12, Money = -20000 }, resultText = "Treat yourself! New car? New house down payment?" },
			{ text = "🎓 Invest in yourself", effects = { Smarts = 10, Money = 10000 }, resultText = "Used winnings for education/growth!", setFlags = {"investor", "lifelong_learner"} },
		},
	},
	
	{
		id = "m_health_wake_up_call",
		minAge = 28, maxAge = 35,
		weight = 20, oneTime = true,
		emoji = "🏥", title = "Health Wake-Up Call",
		category = "health",
		getDynamicData = function()
			local issues = {"high blood pressure", "weight concerns", "stress-related issues", "concerning test results", "burnout symptoms"}
			return { issue = issues[math.random(#issues)] }
		end,
		text = "Doctor flagged %issue%. Time to take health seriously.",
		choices = {
			{ text = "🏋️ Major lifestyle change", effects = { Health = 15, Happiness = 6, Looks = 4 }, resultText = "Gym, diet, sleep - complete overhaul! Feeling amazing!", setFlag = "health_focused" },
			{ text = "🥗 Start eating better", effects = { Health = 8, Happiness = 3 }, resultText = "Cooking more, fast food less. Progress!", setFlag = "healthy_eater" },
			{ text = "😰 Scared straight", effects = { Health = 10, Happiness = -2, Smarts = 3 }, resultText = "Fear is a motivator. You're making changes." },
			{ text = "🤷 Ignore it", effects = { Health = -5, Happiness = 2 }, resultText = "Bad idea. Future you will regret this." },
		},
	},
	
	{
		id = "m_friend_milestone",
		minAge = 27, maxAge = 35,
		weight = 30, cooldown = 3,
		emoji = "🎉", title = "Friend's Big Milestone!",
		category = "social",
		-- CRITICAL: Only fire if player actually has friends!
		requires = function(state)
			return hasFriend(state)
		end,
		requiresAnyFlag = {"has_friend", "has_best_friend", "social_butterfly", "good_roommate", "friendly"},
		getDynamicData = function(state)
			local milestones = {"getting married", "having a baby", "buying a house", "getting promoted", "starting a business"}
			-- Use actual friend name if available
			return { milestone = milestones[math.random(#milestones)], friendName = getFriendName(state) }
		end,
		text = "%friendName% is %milestone%! How do you feel?",
		choices = {
			{ text = "🎉 So happy for them!", effects = { Happiness = 8 }, resultText = "Genuine joy! Their success doesn't diminish yours." },
			{ text = "🤔 Comparing my life...", effects = { Happiness = -4 }, resultText = "Comparison is the thief of joy. You're on your own path." },
			{ text = "🙏 Inspired!", effects = { Happiness = 5, Smarts = 2 }, resultText = "If they can do it, so can you!", setFlag = "inspired" },
			{ text = "😅 When's my turn?", effects = { Happiness = -2 }, resultText = "Adult milestones hit different when you're watching others achieve them." },
		},
	},
	
	{
		id = "m_travel_dream",
		minAge = 22, maxAge = 35,
		weight = 25, cooldown = 3,
		emoji = "✈️", title = "Dream Vacation!",
		category = "social",
		-- MUST have at least $2000 (cheapest option) to even consider a vacation
		requires = function(state)
			return (state.Money or 0) >= 2000
		end,
		getDynamicData = function()
			local destinations = {"Europe", "Japan", "Thailand", "Australia", "South America", "Africa", "tropical islands", "around the world"}
			return { destination = destinations[math.random(#destinations)] }
		end,
		text = "Finally taking that dream trip to %destination%!",
		choices = {
			{ text = "✈️ Life-changing trip!", effects = { Happiness = 20, Money = -5000, Smarts = 4 }, resultText = "Best trip ever! Perspective changed forever!", setFlag = "world_traveler" },
			{ text = "📸 So many memories", effects = { Happiness = 15, Money = -4000 }, resultText = "Photos, experiences, stories! Worth every penny!", setFlag = "world_traveler" },
			{ text = "🎒 Budget backpacking", effects = { Happiness = 12, Money = -2000, Smarts = 5 }, resultText = "Roughing it but seeing the real culture!", setFlags = {"world_traveler", "adventurous"} },
			{ text = "🏝️ Pure relaxation", effects = { Happiness = 15, Health = 5, Money = -4500 }, resultText = "Needed this reset. Recharged and ready.", setFlag = "world_traveler" },
		},
	},
	
	{
		id = "m_pet_adoption",
		minAge = 22, maxAge = 35,
		weight = 25, oneTime = true,
		emoji = "🏠", title = "Pet Shelter Visit",
		category = "family",
		showResultPopup = true,
		getDynamicData = function()
			local petData = {
				{ type = "rescue dog", emoji = "🐕", petKind = "Dog" },
				{ type = "cat", emoji = "🐱", petKind = "Cat" },
				{ type = "puppy", emoji = "🐶", petKind = "Dog" },
				{ type = "kitten", emoji = "🐱", petKind = "Cat" },
				{ type = "rabbit", emoji = "🐰", petKind = "Rabbit" },
				{ type = "bird", emoji = "🐦", petKind = "Bird" },
			}
			local chosen = petData[math.random(#petData)]
			local names = {"Max", "Luna", "Charlie", "Bella", "Cooper", "Lucy", "Milo", "Daisy"}
			return { petType = chosen.type, petName = names[math.random(#names)], petEmoji = chosen.emoji, petKind = chosen.petKind }
		end,
		getDynamicEmoji = function(data)
			return data.petEmoji or "🐾"
		end,
		text = "You visit an animal shelter. A cute %petType% named %petName% looks at you with hopeful eyes. %petEmoji%",
		choices = {
			{ 
				text = "❤️ Adopt them!", 
				effects = { Happiness = 15, Money = -200 }, 
				resultText = "You adopted %petName%! Welcome to the family, little one! 🥰",
				setFlags = {"has_pet", "pet_parent"},
				worldActions = {
					{ type = "spawnPet", petType = "%petKind%" },
				},
			},
			{ 
				text = "🤔 Maybe another pet", 
				effects = { Happiness = 5, Money = -200 }, 
				chanceSuccess = 0.7,
				resultTextSuccess = "You found an even cuter pet and adopted them! Perfect match!",
				resultTextFail = "After looking around, you couldn't find a better fit. You left empty-handed.",
				setFlags = {"has_pet", "pet_parent"},
			},
			{ 
				text = "📅 Come back later", 
				effects = { Happiness = -3 }, 
				resultText = "You left without adopting. %petName%'s sad eyes haunt you...",
			},
			{ 
				text = "😬 Not ready for a pet", 
				effects = { Happiness = 2, Smarts = 2 }, 
				resultText = "Responsible choice. Pets are a big commitment!",
			},
		},
	},
	
	{
		id = "m_volunteer_passion",
		minAge = 24, maxAge = 35,
		weight = 20, cooldown = 3,
		emoji = "❤️", title = "Finding Purpose Through Giving",
		category = "social",
		getDynamicData = function()
			local causes = {"homeless shelter", "food bank", "youth mentor program", "environmental group", "animal rescue", "disaster relief"}
			return { cause = causes[math.random(#causes)] }
		end,
		text = "You started volunteering with a %cause%. It feels meaningful.",
		choices = {
			{ text = "❤️ Found my calling!", effects = { Happiness = 12, Smarts = 3 }, resultText = "This is what matters! Making a difference!", setFlags = {"volunteer", "purposeful"} },
			{ text = "📅 Regular commitment", effects = { Happiness = 6 }, resultText = "Every week you show up. Consistency counts.", setFlag = "volunteer" },
			{ text = "🌟 Leadership role", effects = { Happiness = 8, Smarts = 4 }, resultText = "You're now organizing others to help!", setFlags = {"volunteer", "leader"} },
			{ text = "🤝 New community", effects = { Happiness = 10 }, resultText = "Met amazing people who share your values!", setFlags = {"volunteer", "connected"} },
		},
	},
	
	{
		id = "m_turning_30",
		minAge = 30, maxAge = 30,
		weight = 90, milestone = true, oneTime = true,
		emoji = "3️⃣0️⃣", title = "Turning 30!",
		category = "family",
		text = "The big 3-0! You're officially in your thirties. How are you feeling?",
		choices = {
			{ text = "🎉 Best decade yet!", effects = { Happiness = 12 }, resultText = "You're wiser, more confident. 30s are going to be great!" },
			{ text = "😰 Where did time go?!", effects = { Happiness = -4 }, resultText = "Existential crisis incoming. What have you accomplished?!" },
			{ text = "💪 Prime of my life", effects = { Happiness = 8, Health = 3, Looks = 2 }, resultText = "30 is the new 20! Just getting started!" },
			{ text = "🍷 Aged like fine wine", effects = { Happiness = 10, Looks = 4 }, resultText = "Getting better with age! Self-love unlocked." },
		},
	},
	
	{
		id = "m_networking_event",
		minAge = 23, maxAge = 35,
		weight = 25, cooldown = 3,
		emoji = "🤝", title = "Networking Event",
		category = "career",
		requiresFlag = "employed", -- Must have a job/career to attend career networking
		getDynamicData = function()
			local events = {"industry conference", "alumni mixer", "professional meetup", "business dinner", "charity gala"}
			return { event = events[math.random(#events)] }
		end,
		text = "You're at a %event%! Time to work the room!",
		choices = {
			{ text = "🌟 Made key connection!", effects = { Happiness = 8, Smarts = 4 }, resultText = "Met someone who could change your career!", setFlag = "networker" },
			{ text = "🤝 Lots of good chats", effects = { Happiness = 5, Smarts = 2 }, resultText = "Quality networking! Follow-ups scheduled." },
			{ text = "😅 Awkward small talk", effects = { Happiness = -2 }, resultText = "Networking is hard. You survived." },
			{ text = "💼 Got a job lead!", effects = { Happiness = 10, Money = 2000 }, resultText = "This event paid for itself! Opportunity knocks!", setFlags = {"networker", "opportunity"} },
		},
	},
	
	{
		id = "m_burnout",
		minAge = 25, maxAge = 35,
		weight = 25, oneTime = true,
		emoji = "🔥", title = "Burnout",
		category = "health",
		requiresFlag = "employed", -- Can only burn out if you have a job!
		text = "You hit the wall. Complete burnout. Can't keep going like this.",
		choices = {
			{ text = "🏝️ Take a real break", effects = { Health = 8, Happiness = 6, Money = -2000 }, resultText = "Took time off. Came back refreshed and with new perspective.", setFlag = "recovered_burnout" },
			{ text = "🔄 Change jobs", effects = { Happiness = 4, Smarts = 2 }, resultText = "Sometimes you need a fresh start.", setFlag = "recovered_burnout" },
			{ text = "💆 Self-care priority", effects = { Health = 6, Happiness = 4 }, resultText = "Boundaries, sleep, therapy. Healing takes time.", setFlags = {"recovered_burnout", "self_care"} },
			{ text = "💪 Push through", effects = { Health = -8, Happiness = -5 }, resultText = "Bad choice. You crashed even harder later." },
		},
	},
	
	{
		id = "m_unexpected_money",
		minAge = 22, maxAge = 35,
		weight = 15, cooldown = 3,
		emoji = "💰", title = "Unexpected Money!",
		category = "career",
		getDynamicData = function()
			local sources = {"inheritance", "tax refund", "bonus", "winning scratch-off", "old savings you forgot about", "returned security deposit"}
			local amount = math.random(1000, 20000)
			return { source = sources[math.random(#sources)], amount = amount }
		end,
		text = "You received $%amount% from %source%! What do you do?",
		choices = {
			{ text = "💰 Save it all", effects = { Money = 15000, Happiness = 4, Smarts = 3 }, resultText = "Future you will thank present you!", setFlag = "saver" },
			{ text = "💸 Spend it!", effects = { Money = 5000, Happiness = 10 }, resultText = "YOLO! Enjoyed every penny!" },
			{ text = "📈 Invest it", effects = { Money = 8000, Smarts = 5 }, resultText = "Making money work for you!", setFlag = "investor" },
			{ text = "💳 Pay off debt", effects = { Money = -2000, Happiness = 6, Smarts = 4 }, resultText = "Responsible choice! One step closer to financial freedom!", setFlag = "financially_responsible" },
		},
	},
	
	{
		id = "m_imposter_syndrome",
		minAge = 24, maxAge = 35,
		weight = 30, oneTime = true,
		emoji = "😰", title = "Imposter Syndrome",
		category = "career",
		requiresFlag = "employed", -- Must have a job to feel imposter syndrome at work!
		text = "You feel like a fraud at work. Like any day, everyone will realize you don't belong.",
		choices = {
			{ text = "🗣️ Open up about it", effects = { Happiness = 5, Smarts = 4 }, resultText = "Turns out EVERYONE feels this way! You're not alone.", setFlag = "self_aware" },
			{ text = "📊 Look at accomplishments", effects = { Happiness = 6, Smarts = 3 }, resultText = "The evidence says you earned your spot!" },
			{ text = "💪 Fake it til you make it", effects = { Happiness = 2, Smarts = 2 }, resultText = "Act confident even when you're not. It works." },
			{ text = "😔 Really struggling", effects = { Happiness = -6 }, resultText = "The feeling persists. Consider talking to someone professional." },
		},
	},
	
	{
		id = "m_second_child",
		minAge = 28, maxAge = 35,
		weight = 20, oneTime = true,
		requiresFlag = "has_child",
		emoji = "👶", title = "Baby Number Two!",
		category = "family",
		getDynamicData = function()
			local names = {"Charlotte", "Oliver", "Amelia", "Elijah", "Mia", "James", "Harper", "Benjamin"}
			return { babyName = names[math.random(#names)] }
		end,
		text = "Another baby! Welcome %babyName%! You're a family of four!",
		choices = {
			{ text = "👶 Double the love!", effects = { Happiness = 20, Health = -5, Money = -6000 }, resultText = "Your heart grew even bigger!", setFlag = "multiple_children" },
			{ text = "😱 Twice the chaos", effects = { Happiness = 8, Health = -8, Money = -5000 }, resultText = "You're outnumbered now! Survival mode!", setFlag = "multiple_children" },
			{ text = "🤝 Sibling bond!", effects = { Happiness = 15, Money = -5500 }, resultText = "Your first child has a built-in best friend!", setFlag = "multiple_children" },
			{ text = "💤 Sleep is a memory", effects = { Happiness = 10, Health = -10, Money = -6000 }, resultText = "What year is it? Doesn't matter. Baby needs you.", setFlag = "multiple_children" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- DROPOUT / EDUCATION PATH CONSEQUENCES
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_dropout_job_struggle",
		minAge = 18, maxAge = 30,
		weight = 35, cooldown = 3,
		emoji = "📋", title = "Job Application Pain",
		category = "career",
		requiresFlag = "high_school_dropout",
		blockIfFlag = "employed",
		text = "Every job application asks for education. 'High School Diploma Required.' The checkbox mocks you.",
		choices = {
			{ 
				text = "📝 Apply anyway", 
				effects = { Happiness = -4 },
				chanceSuccess = 0.20,
				effectsOnSuccess = { Happiness = 10, Money = 500 },
				resultText = "They gave you a shot! Hard work can speak louder than paper!",
				resultTextFail = "Rejected again. 'Thank you for your interest, but...'",
				setFlag = "employed"
			},
			{ 
				text = "📚 Get your GED", 
				effects = { Smarts = 8, Happiness = 5, Money = -500 }, 
				resultText = "You enrolled in a GED program. It's not too late to get that credential!",
				setFlag = "pursuing_ged",
				clearFlag = "high_school_dropout"
			},
			{ 
				text = "🔧 Look for trade work", 
				effects = { Happiness = 4, Money = 1000 }, 
				resultText = "Construction, warehouse, delivery... diplomas matter less here.",
				setFlag = "trade_worker"
			},
			{ 
				text = "💼 Start own hustle", 
				effects = { Happiness = 6, Smarts = 3 }, 
				resultText = "No one asks for your diploma when you're the boss!",
				setFlag = "entrepreneur"
			},
		},
	},
	
	{
		id = "m_dropout_regret",
		minAge = 20, maxAge = 35,
		weight = 25, oneTime = true,
		emoji = "😔", title = "What If?",
		category = "social",
		requiresFlag = "high_school_dropout",
		getDynamicData = function()
			local scenarios = {
				"old classmates talking about their college memories on social media",
				"a job posting for your dream job that requires a degree",
				"your younger sibling's graduation",
				"filling out an application that asks about education"
			}
			return { scenario = scenarios[math.random(#scenarios)] }
		end,
		text = "Seeing %scenario% makes you wonder... what if you'd finished school?",
		choices = {
			{ 
				text = "📚 Never too late", 
				effects = { Happiness = 6, Smarts = 4 }, 
				resultText = "You start researching GED programs and community college. There's still time!",
				setFlag = "considering_education"
			},
			{ 
				text = "💪 Forge my own path", 
				effects = { Happiness = 8, Smarts = 2 }, 
				resultText = "Plenty of successful people didn't finish school. You'll prove them wrong!",
				setFlag = "determined"
			},
			{ 
				text = "😔 Deep regret", 
				effects = { Happiness = -10 }, 
				resultText = "The 'what ifs' hit hard. Some doors are closed now.",
				setFlag = "life_regret"
			},
			{ 
				text = "🤷 Different path, not wrong", 
				effects = { Happiness = 4, Smarts = 3 }, 
				resultText = "Life's a journey. Your path is just different, not worse.",
			},
		},
	},
	
	{
		id = "m_ged_success",
		minAge = 19, maxAge = 40,
		weight = 40, oneTime = true,
		emoji = "🎓", title = "GED Victory!",
		category = "school",
		requiresFlag = "pursuing_ged",
		text = "You passed all the GED tests! You now have an official high school equivalency credential!",
		choices = {
			{ 
				text = "🎉 So proud!", 
				effects = { Happiness = 15, Smarts = 5 }, 
				resultText = "Proved everyone wrong! Doors that were closed are opening!",
				setFlags = {"ged_graduate", "perseverance"},
				clearFlags = {"pursuing_ged", "high_school_dropout"}
			},
			{ 
				text = "📚 On to college!", 
				effects = { Happiness = 12, Smarts = 8 }, 
				resultText = "You're enrolling in community college. The comeback story continues!",
				setFlags = {"ged_graduate", "college_bound"},
				clearFlags = {"pursuing_ged", "high_school_dropout"}
			},
			{ 
				text = "💼 Time to job hunt", 
				effects = { Happiness = 10, Smarts = 3 }, 
				resultText = "Now you can check that box on applications!",
				setFlags = {"ged_graduate"},
				clearFlags = {"pursuing_ged", "high_school_dropout"}
			},
		},
	},
	
	{
		id = "m_honors_student_opportunity",
		minAge = 18, maxAge = 25,
		weight = 30, oneTime = true,
		emoji = "🌟", title = "Academic Excellence Pays Off!",
		category = "school",
		requiresAnyFlag = {"honors_student", "honor_student", "valedictorian", "award_winner"},
		blockIfFlag = "high_school_dropout",
		text = "Your academic achievements caught someone's attention! A prestigious program wants you!",
		choices = {
			{ 
				text = "🎓 Full scholarship!", 
				effects = { Happiness = 20, Smarts = 8, Money = 20000 }, 
				resultText = "Your hard work in school paid off HUGE! Free education!",
				setFlags = {"scholarship", "high_achiever"}
			},
			{ 
				text = "💼 Internship offer", 
				effects = { Happiness = 15, Smarts = 5, Money = 5000 }, 
				resultText = "Top company wants YOU! Resume building begins!",
				setFlag = "prestigious_intern"
			},
			{ 
				text = "🔬 Research opportunity", 
				effects = { Happiness = 12, Smarts = 10 }, 
				resultText = "Working with top professors on real research!",
				setFlags = {"researcher", "academic_track"}
			},
			{ 
				text = "🌍 Study abroad", 
				effects = { Happiness = 18, Smarts = 6 }, 
				resultText = "Scholarship to study in another country! Adventure awaits!",
				setFlags = {"world_traveler", "international_experience"}
			},
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- COLLEGE/UNIVERSITY ACADEMIC EVENTS (GPA AFFECTING)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_college_midterm",
		minAge = 18, maxAge = 25,
		weight = 45, cooldown = 2,
		emoji = "📝", title = "College Midterms!",
		category = "school",
		requiresFlag = "college_student",
		getDynamicData = function()
			local courses = {"Organic Chemistry", "Calculus II", "Macroeconomics", "Literary Theory", "Statistics", "Psychology 101"}
			return { course = courses[math.random(#courses)] }
		end,
		text = "Midterm in %course%! This is worth 25% of your grade!",
		choices = {
			{ text = "📚 Studied extensively", effects = { Smarts = 14, Happiness = 8 }, resultText = "A! Your GPA is safe! Professor was impressed!", setFlag = "honor_roll" },
			{ text = "☕ All-nighter cram session", chanceSuccess = 0.55, effectsOnSuccess = { Smarts = 9, Happiness = 3, Health = -4 }, effectsOnFail = { Smarts = 4, Happiness = -5, Health = -6 },
			  resultText = "B! Caffeine and adrenaline saved you!", resultTextFail = "C-. Fell asleep during the exam. Oops." },
			{ text = "🤝 Study group helped", effects = { Smarts = 11, Happiness = 6 }, resultText = "A-! Group study works!", setFlag = "collaborative" },
			{ text = "🎲 Winged it completely", chanceSuccess = 0.25, effectsOnSuccess = { Smarts = 6, Happiness = 10 }, effectsOnFail = { Smarts = 2, Happiness = -8 },
			  resultText = "B-! Your BS skills are legendary!", resultTextFail = "F. Academic probation warning!", setFlag = "academic_probation" },
		},
	},
	
	{
		id = "m_college_finals",
		minAge = 18, maxAge = 25,
		weight = 40, cooldown = 2,
		emoji = "📋", title = "College Finals Week!",
		category = "school",
		requiresFlag = "college_student",
		text = "FINALS! 4 exams in 5 days! Your GPA hangs in the balance!",
		choices = {
			{ text = "📚 Prepared the whole semester", effects = { Smarts = 16, Happiness = 10 }, resultText = "DEAN'S LIST! 4.0 this semester!", setFlags = {"deans_list", "academic_achiever"} },
			{ text = "🏃 Sprint studying mode", effects = { Smarts = 10, Happiness = 2, Health = -5 }, resultText = "B average! GPA survives another semester!" },
			{ text = "😱 Adderall and prayer", chanceSuccess = 0.5, effectsOnSuccess = { Smarts = 8, Happiness = 4 }, effectsOnFail = { Smarts = 4, Happiness = -6, Health = -8 },
			  resultText = "C's get degrees! Scraped by!", resultTextFail = "Failed a class. Have to retake it.", setFlag = "academic_trouble" },
			{ text = "🆘 Emergency tutoring", effects = { Smarts = 12, Happiness = 5, Money = -200 }, resultText = "A-! Worth every penny for that tutoring!" },
		},
	},
	
	{
		id = "m_professor_office_hours",
		minAge = 18, maxAge = 25,
		weight = 30, cooldown = 3,
		emoji = "👨‍🏫", title = "Professor Office Hours",
		category = "school",
		requiresFlag = "college_student",
		getDynamicData = function()
			local issues = {"confused about the material", "need help with an assignment", "want to discuss your grade", "interested in research opportunities"}
			return { issue = issues[math.random(#issues)] }
		end,
		text = "You're %issue%. Should you visit your professor's office hours?",
		choices = {
			{ text = "📚 Yes, get help!", effects = { Smarts = 8, Happiness = 5 }, resultText = "Professor explained it perfectly! You're getting it now!", setFlag = "proactive_student" },
			{ text = "🤝 Ask about research", effects = { Smarts = 10, Happiness = 6 }, resultText = "Professor invited you to join their research team!", setFlag = "research_assistant" },
			{ text = "🙏 Beg for grade bump", chanceSuccess = 0.3, effectsOnSuccess = { Smarts = 3, Happiness = 8 }, effectsOnFail = { Smarts = 1, Happiness = -4 },
			  resultText = "Professor gave you extra credit opportunity!", resultTextFail = "No dice. Earn your grade." },
			{ text = "😬 Too awkward, skip it", effects = { Happiness = -2 }, resultText = "Still confused. Should have gone." },
		},
	},
	
	{
		id = "m_group_project_college",
		minAge = 18, maxAge = 25,
		weight = 35, cooldown = 2,
		emoji = "👥", title = "College Group Project!",
		category = "school",
		requiresFlag = "college_student",
		getDynamicData = function()
			return { slackerName = randomFirstName() }
		end,
		text = "Group project worth 30% of your grade! %slackerName% isn't responding to messages!",
		choices = {
			{ text = "🦸 Do it all yourself", effects = { Smarts = 10, Happiness = -4 }, resultText = "A! But you did ALL the work. Exhausted.", setFlag = "reliable" },
			{ text = "📧 Email the professor", effects = { Smarts = 7, Happiness = 2 }, resultText = "Professor made %slackerName% contribute. Crisis averted!" },
			{ text = "🗣️ Confront the slacker", chanceSuccess = 0.5, effectsOnSuccess = { Smarts = 8, Happiness = 5 }, effectsOnFail = { Smarts = 5, Happiness = -4 },
			  resultText = "They stepped up! Great presentation!", resultTextFail = "Drama. Awkward presentation. B-." },
			{ text = "🤷 Let the grade suffer", effects = { Smarts = 4, Happiness = -3 }, resultText = "C. Could have been worse." },
		},
	},
	
	{
		id = "m_thesis_crunch",
		minAge = 21, maxAge = 30,
		weight = 25, oneTime = true,
		emoji = "📚", title = "Thesis Deadline!",
		category = "school",
		requiresAnyFlag = {"college_student", "grad_student", "advanced_degree"},
		getDynamicData = function()
			local topics = {"machine learning applications", "climate change impacts", "literary analysis", "economic theory", "social psychology", "biomedical research"}
			return { topic = topics[math.random(#topics)] }
		end,
		text = "Your thesis on '%topic%' is due in 2 weeks! You're not done!",
		choices = {
			{ text = "📝 Lock in and grind", effects = { Smarts = 18, Happiness = 2, Health = -6 }, resultText = "SUBMITTED! Advisor says it's publishable quality!", setFlag = "published_research" },
			{ text = "🆘 Request extension", chanceSuccess = 0.6, effectsOnSuccess = { Smarts = 10, Happiness = 5 }, effectsOnFail = { Smarts = 6, Happiness = -4 },
			  resultText = "Got 2 more weeks! Finished with quality!", resultTextFail = "No extension. Had to submit incomplete." },
			{ text = "🤝 Get advisor's help", effects = { Smarts = 14, Happiness = 4 }, resultText = "Advisor guided you to the finish line! A!", setFlag = "mentored" },
			{ text = "😭 Stress breakdown", effects = { Smarts = 5, Happiness = -10, Health = -8 }, resultText = "Barely finished. C. But it's DONE.", setFlag = "burnout" },
		},
	},
	
	{
		id = "m_class_participation",
		minAge = 18, maxAge = 25,
		weight = 30, cooldown = 2,
		emoji = "🙋", title = "Class Participation!",
		category = "school",
		requiresFlag = "college_student",
		getDynamicData = function()
			local questions = {"a tricky philosophical question", "a complex math problem", "a controversial topic", "a literature interpretation"}
			return { question = questions[math.random(#questions)] }
		end,
		text = "Professor asks %question% and looks right at you! 10% of grade is participation!",
		choices = {
			{ text = "🎯 Nail the answer", effects = { Smarts = 10, Happiness = 8 }, resultText = "PERFECT! 'Exactly right!' says the professor!", setFlag = "class_star" },
			{ text = "🤔 Take a shot at it", chanceSuccess = 0.6, effectsOnSuccess = { Smarts = 6, Happiness = 5 }, effectsOnFail = { Smarts = 3, Happiness = -2 },
			  resultText = "Not bad! Professor built on your answer!", resultTextFail = "Close but not quite. At least you tried!" },
			{ text = "🙈 Avoid eye contact", effects = { Smarts = 2, Happiness = -2 }, resultText = "Someone else got picked. Dodged a bullet?" },
			{ text = "🤡 Make a joke about it", effects = { Happiness = 6, Smarts = 4 }, resultText = "Class laughed! Professor smiled! Participation points!", setFlag = "class_clown" },
		},
	},
	
	{
		id = "m_major_paper",
		minAge = 18, maxAge = 25,
		weight = 35, cooldown = 2,
		emoji = "📄", title = "Major Paper Due!",
		category = "school",
		requiresFlag = "college_student",
		getDynamicData = function()
			local pages = {"8", "12", "15", "20"}
			local types = {"research paper", "argumentative essay", "literature review", "case study analysis"}
			return { pages = pages[math.random(#pages)], type = types[math.random(#types)] }
		end,
		text = "Your %pages%-page %type% is due in 3 days! How's it going?",
		choices = {
			{ text = "✅ First draft done!", effects = { Smarts = 14, Happiness = 6 }, resultText = "A! Time for revisions made it perfect!", setFlag = "organized" },
			{ text = "📝 Outline complete, writing now", effects = { Smarts = 10, Happiness = 4 }, resultText = "B+! Solid work under pressure!" },
			{ text = "😅 Haven't started...", chanceSuccess = 0.4, effectsOnSuccess = { Smarts = 6, Happiness = 4, Health = -4 }, effectsOnFail = { Smarts = 3, Happiness = -6, Health = -6 },
			  resultText = "Red Bull-fueled miracle! C+!", resultTextFail = "Barely readable. D." },
			{ text = "🤖 AI 'assistance'", chanceSuccess = 0.35, effectsOnSuccess = { Smarts = 4, Happiness = 5 }, effectsOnFail = { Smarts = -6, Happiness = -12 },
			  resultText = "Got away with it. B-.", resultTextFail = "TURNITIN FLAGGED IT! Academic integrity hearing!", setFlag = "academic_misconduct" },
		},
	},
	
	{
		id = "m_lab_work",
		minAge = 18, maxAge = 25,
		weight = 25, cooldown = 2,
		emoji = "🔬", title = "Lab Report Due!",
		category = "school",
		requiresFlag = "college_student",
		getDynamicData = function()
			local experiments = {"titration", "dissection", "circuit building", "data analysis", "chemical synthesis", "microscopy"}
			return { experiment = experiments[math.random(#experiments)] }
		end,
		text = "Your %experiment% lab report is due! Did you take good notes in lab?",
		choices = {
			{ text = "📋 Detailed notes + photos", effects = { Smarts = 12, Happiness = 6 }, resultText = "A! Your data was perfect!", setFlag = "meticulous" },
			{ text = "📝 Basic notes", effects = { Smarts = 8, Happiness = 4 }, resultText = "B+! Enough to write a solid report!" },
			{ text = "🤝 Borrowed partner's notes", effects = { Smarts = 6, Happiness = 3 }, resultText = "B-. Thank god for lab partners." },
			{ text = "😬 Barely remember the lab", chanceSuccess = 0.3, effectsOnSuccess = { Smarts = 4, Happiness = 5 }, effectsOnFail = { Smarts = 2, Happiness = -5 },
			  resultText = "Made up plausible data. C!", resultTextFail = "Clearly didn't understand. D." },
		},
	},
}

return module
