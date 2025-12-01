-- LifeEvents/career_business.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- BUSINESS & ENTREPRENEURSHIP CAREER EVENTS
-- BitLife-style: Player picks ACTIONS, game decides OUTCOMES
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent.init)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- EARLY BUSINESS INSTINCTS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "biz_childhood_lemonade",
		minAge = 7, maxAge = 12,
		weight = 25, oneTime = true,
		emoji = "🍋", title = "Lemonade Stand Idea!",
		category = "school",
		text = "Hot summer day! You want to set up a lemonade stand. What do you do?",
		choices = {
			{ text = "🍋 Premium lemonade $2!", effects = { Happiness = 15, Money = 50, Smarts = 5 }, resultText = "Sold out! Made $50! The business instinct is STRONG!", setFlag = "entrepreneur_spirit" },
			{ text = "🏪 Undercut with $0.25", effects = { Happiness = 10, Money = 20 }, resultText = "Sold tons but barely made money. Learned about margins!" },
			{ text = "📢 Big marketing push", effects = { Happiness = 12, Money = 35, Smarts = 5 }, resultText = "Signs everywhere! Customers came! Marketing works!", setFlag = "entrepreneur_spirit" },
			{ text = "😤 Too much work", effects = { Happiness = 5 }, resultText = "Gave up after an hour. Business isn't for everyone." },
		},
	},
	
	{
		id = "biz_teen_job",
		minAge = 14, maxAge = 17,
		weight = 25, cooldown = 2,
		emoji = "🍔", title = "First Job Opportunity!",
		category = "work",
		getDynamicData = function()
			local jobs = {"fast food", "grocery store", "movie theater", "retail"}
			return { jobType = jobs[math.random(#jobs)] }
		end,
		text = "Got a job at %jobType%! Your first REAL job. How do you approach it?",
		choices = {
			{ text = "💪 Work hard, learn fast", effects = { Happiness = 10, Money = 500, Smarts = 5 }, resultText = "Promoted to shift lead already! Boss loves your work ethic!", setFlag = "strong_work_ethic" },
			{ text = "🤷 Just collect paycheck", effects = { Happiness = 5, Money = 400 }, resultText = "Did the minimum. Got paid. No promotions but whatever." },
			{ text = "🧠 Study the business", effects = { Happiness = 8, Money = 400, Smarts = 8 }, resultText = "Watched how everything works. Valuable learning experience!", setFlag = "business_observer" },
			{ text = "😤 Quit after week 1", effects = { Happiness = -5, Money = 50 }, resultText = "Couldn't handle it. Quit before first paycheck. Rough start." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- COLLEGE & EARLY CAREER
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "biz_college_major",
		minAge = 18, maxAge = 19,
		weight = 20, oneTime = true,
		emoji = "🎓", title = "Choosing Your Major!",
		category = "school",
		text = "Time to declare a major! What do you choose?",
		choices = {
			{ text = "💼 Business/Finance", effects = { Smarts = 8, Happiness = 5 }, resultText = "The traditional path! Learning accounting, marketing, management!", setFlags = {"business_major", "college_student"} },
			{ text = "🔬 STEM field", effects = { Smarts = 12, Happiness = 3 }, resultText = "Hard but valuable! Technical skills are in demand!", setFlags = {"stem_major", "college_student"} },
			{ text = "🎨 Follow your passion", effects = { Happiness = 15, Smarts = 5 }, resultText = "Studying what you love! Happy but uncertain career path.", setFlag = "college_student" },
			{ text = "🤷 Undeclared", effects = { Happiness = 8, Smarts = 3 }, resultText = "Still figuring it out! Exploring options.", setFlag = "college_student" },
		},
	},
	
	{
		id = "biz_first_internship",
		minAge = 19, maxAge = 22,
		weight = 25, oneTime = true,
		emoji = "👔", title = "Internship Interview!",
		category = "work",
		requiresFlag = "college_student",
		getDynamicData = function()
			local companies = {"Goldman Sachs", "McKinsey", "Google", "JP Morgan", "Deloitte"}
			return { company = companies[math.random(#companies)] }
		end,
		text = "Interview at %company%! Big opportunity! How do you prepare?",
		choices = {
			{ 
				text = "📚 Research everything", 
				effects = { Happiness = 20, Money = 15000, Smarts = 5 }, 
				resultText = "Nailed every question! HIRED! Dream internship secured!", 
				setFlags = {"elite_intern", "resume_builder"},
				setJob = { id = "elite_intern", title = "Business Analyst Intern", salary = 25000 }
			},
			{ 
				text = "😎 Wing it on charm", 
				effects = { Happiness = 5, Money = 5000 }, 
				resultText = "Got a different offer. Not prestigious but it's something.", 
				setFlag = "intern",
				setJob = { id = "intern", title = "Intern", salary = 15000 }
			},
			{ text = "😰 Nervous mess", effects = { Happiness = -10 }, resultText = "Blanked on questions. Rejection email came fast. Ouch." },
			{ 
				text = "🤝 Network beforehand", 
				effects = { Happiness = 18, Money = 12000, Smarts = 5 }, 
				resultText = "Inside connection helped! Got the job! Networking works!", 
				setFlags = {"elite_intern", "networker"},
				setJob = { id = "elite_intern", title = "Consultant Intern", salary = 22000 }
			},
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- CORPORATE LADDER
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "biz_first_corporate_job",
		minAge = 22, maxAge = 28,
		weight = 20, oneTime = true,
		emoji = "💼", title = "First Real Job Offer!",
		category = "work",
		blockIfFlag = "employed", -- Don't fire if already employed
		getDynamicData = function()
			local salaries = {55000, 65000, 75000, 85000}
			return { salary = salaries[math.random(#salaries)] }
		end,
		text = "Job offer! $%salary% per year! Do you take it?",
		choices = {
			{ 
				text = "✅ Accept immediately", 
				effects = { Happiness = 15 }, 
				resultText = "EMPLOYED! First day jitters! Career officially begins!", 
				setFlags = {"employed", "corporate_worker"},
				setJob = { id = "corporate_entry", title = "Associate", salary = 55000 }
			},
			{ 
				text = "📋 Negotiate higher", 
				effects = { Happiness = 18, Smarts = 5 }, 
				resultText = "Got $10k more! Always negotiate! Strong start!", 
				setFlags = {"employed", "corporate_worker", "negotiator"},
				setJob = { id = "corporate_entry", title = "Associate", salary = 65000 }
			},
			{ text = "🙅 Hold out for better", effects = { Happiness = -10, Money = -5000 }, resultText = "Turned it down. Job market dried up. Now desperate. Bad call." },
			{ 
				text = "🤔 Ask for more time", 
				effects = { Happiness = 8 }, 
				resultText = "Used the time to get another offer! Leverage worked!", 
				setFlags = {"employed", "corporate_worker"},
				setJob = { id = "corporate_entry", title = "Associate", salary = 60000 }
			},
		},
	},
	
	{
		id = "biz_office_politics",
		minAge = 23, maxAge = 50,
		weight = 25, cooldown = 3,
		emoji = "🐍", title = "Office Politics!",
		category = "work",
		requiresFlag = "corporate_worker",
		text = "A coworker is taking credit for YOUR work to the boss! What do you do?",
		choices = {
			{ text = "📧 Email proof to boss", effects = { Happiness = 10, Smarts = 5 }, resultText = "Receipts don't lie! Boss knows the truth now! Credit restored!" },
			{ text = "😤 Confront them publicly", effects = { Happiness = -10, Looks = -3 }, resultText = "Made a scene! Now YOU look bad. Should've been strategic." },
			{ text = "🤐 Let it slide", effects = { Happiness = -15, Smarts = -3 }, resultText = "They keep doing it. You're invisible. This will hurt your career." },
			{ text = "🎯 Work directly with boss", effects = { Happiness = 12, Smarts = 8 }, resultText = "Started sending updates directly. No middleman. Smart move!", setFlag = "savvy_worker" },
		},
	},
	
	{
		id = "biz_promotion_opportunity",
		minAge = 25, maxAge = 45,
		weight = 20, cooldown = 3,
		emoji = "📈", title = "Promotion Opening!",
		category = "work",
		requiresFlag = "corporate_worker",
		blockIfFlag = "manager", -- Only promote once via this event
		text = "Management position opened up! Multiple people want it. What do you do?",
		choices = {
			{ 
				text = "📊 Build a case", 
				effects = { Happiness = 20, Smarts = 5 }, 
				resultText = "Presented your accomplishments! GOT THE PROMOTION! Manager now!", 
				setFlags = {"manager", "promoted"},
				setJob = { id = "manager", title = "Manager", salary = 95000 }
			},
			{ 
				text = "🤝 Lobby decision makers", 
				effects = { Happiness = 15 }, 
				resultText = "Relationships paid off! Promoted! Politics matter!", 
				setFlags = {"manager", "political_player"},
				setJob = { id = "manager", title = "Manager", salary = 90000 }
			},
			{ text = "🤷 Hope they notice me", effects = { Happiness = -15 }, resultText = "They didn't. Someone else got it. You have to advocate for yourself!" },
			{ text = "😰 Don't apply", effects = { Happiness = -10, Smarts = -3 }, resultText = "Too scared to try. Watched someone less qualified get it. Regret." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- ENTREPRENEURSHIP PATH
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "biz_startup_idea",
		minAge = 22, maxAge = 45,
		weight = 15, oneTime = true,
		emoji = "💡", title = "Big Startup Idea!",
		category = "work",
		requiresFlag = "entrepreneur_spirit",
		getDynamicData = function()
			local ideas = {"an app that", "a service that", "a platform that", "a product that"}
			local solutions = {"saves people time", "connects communities", "solves a daily problem", "makes life easier"}
			return { ideaType = ideas[math.random(#ideas)], solution = solutions[math.random(#solutions)] }
		end,
		text = "You have an idea for %ideaType% %solution%! Could be big! What do you do?",
		choices = {
			{ text = "🚀 Quit job and build it", effects = { Happiness = 15, Money = -30000 }, resultText = "All in! Scary but exciting! No salary but pursuing the dream!", setFlags = {"startup_founder", "entrepreneur"} },
			{ text = "🌙 Build it on the side", effects = { Happiness = 12, Health = -5 }, resultText = "Nights and weekends! Exhausting but keeping the safety net!", setFlags = {"side_hustle", "entrepreneur"} },
			{ text = "🤝 Find a cofounder", effects = { Happiness = 15, Smarts = 5 }, resultText = "Found a perfect partner! Complementary skills! Let's go!", setFlags = {"startup_founder", "entrepreneur", "has_cofounder"} },
			{ text = "📝 Just file it away", effects = { Happiness = -5 }, resultText = "Great ideas need execution. This one just sits in a notebook..." },
		},
	},
	
	{
		id = "biz_seeking_funding",
		minAge = 23, maxAge = 50,
		weight = 20, oneTime = true,
		emoji = "💰", title = "Investor Meeting!",
		category = "work",
		requiresFlag = "startup_founder",
		getDynamicData = function()
			local vcs = {"Sequoia", "Andreessen Horowitz", "Y Combinator", "a wealthy angel"}
			local amounts = {500000, 1000000, 2000000}
			return { investor = vcs[math.random(#vcs)], amount = amounts[math.random(#amounts)] }
		end,
		text = "Pitching to %investor%! Asking for $%amount%! How do you pitch?",
		choices = {
			{ text = "📊 Data-driven pitch", effects = { Happiness = 25, Money = 1000000, Smarts = 5 }, resultText = "They loved the metrics! FUNDED! Check is in the mail!", setFlags = {"funded_startup", "vc_backed"} },
			{ text = "🎯 Vision and passion", effects = { Happiness = 20, Money = 500000 }, resultText = "They believed in YOU! Smaller check but you have a champion!", setFlag = "funded_startup" },
			{ text = "😰 Freeze in the meeting", effects = { Happiness = -15 }, resultText = "Couldn't articulate your vision. Pass. Practice more." },
			{ text = "😤 Overvalue the company", effects = { Happiness = -10, Smarts = 3 }, resultText = "Asked for too much. They walked. Know your worth but be realistic." },
		},
	},
	
	{
		id = "biz_startup_success",
		minAge = 25, maxAge = 55,
		weight = 12, oneTime = true,
		emoji = "🚀", title = "Startup Taking Off!",
		category = "work",
		requiresFlag = "funded_startup",
		text = "Your startup is growing FAST! Revenue up 500%! Big companies want to talk! What do you do?",
		choices = {
			{ text = "💰 Sell the company!", effects = { Happiness = 35, Money = 10000000 }, resultText = "ACQUIRED! Eight-figure exit! You're a MILLIONAIRE!", setFlags = {"successful_exit", "millionaire"} },
			{ text = "🚀 Keep building!", effects = { Happiness = 25, Money = 500000, Smarts = 5 }, resultText = "Turned down the offer! Going for BILLION dollar company!", setFlag = "unicorn_pursuit" },
			{ text = "📈 Take company public", effects = { Happiness = 30, Money = 20000000 }, resultText = "IPO! On the stock market! Paper wealth through the roof!", setFlags = {"public_company", "ceo"} },
			{ text = "💼 Hire CEO to run it", effects = { Happiness = 20, Money = 3000000 }, resultText = "Brought in professional management. Less control, more free time." },
		},
	},
	
	{
		id = "biz_startup_failure",
		minAge = 23, maxAge = 50,
		weight = 25, oneTime = true,
		emoji = "📉", title = "Startup Struggling...",
		category = "work",
		requiresFlag = "startup_founder",
		text = "It's not working. Running out of money. Team losing faith. What do you do?",
		choices = {
			{ text = "💪 Pivot the business", effects = { Happiness = 8, Smarts = 8 }, resultText = "New direction! The pivot is working! Second chance!", setFlag = "pivot_survivor" },
			{ text = "🚪 Shut it down", effects = { Happiness = -20, Money = -50000 }, resultText = "Painful but necessary. Learned SO much. Will try again.", clearFlag = "startup_founder" },
			{ text = "🙏 One more fundraise", effects = { Happiness = 5, Money = 200000 }, resultText = "Found believers! Got bridge funding! Living to fight another day!", setFlag = "scrappy_survivor" },
			{ text = "😔 Give up and get a job", effects = { Happiness = -15, Money = 50000 }, resultText = "Back to corporate. Dream over. But stability is nice...", clearFlag = "startup_founder", setFlag = "ex_founder" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- EXECUTIVE LEVEL
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "biz_c_suite",
		minAge = 35, maxAge = 60,
		weight = 12, oneTime = true,
		emoji = "👔", title = "C-Suite Opportunity!",
		category = "work",
		requiresFlag = "manager",
		getDynamicData = function()
			local titles = {"CFO", "COO", "CMO", "CTO"}
			return { title = titles[math.random(#titles)] }
		end,
		text = "Offered the %title% position at a major company! Executive level! What do you do?",
		choices = {
			{ text = "✅ Accept immediately", effects = { Happiness = 30, Money = 500000 }, resultText = "Chief Officer! Corner office! Stock options! You've made it!", setFlags = {"c_suite", "executive"} },
			{ text = "📋 Negotiate hard", effects = { Happiness = 25, Money = 750000, Smarts = 5 }, resultText = "Better package! More equity! Smart negotiation!", setFlags = {"c_suite", "executive"} },
			{ text = "🤔 Stay at current company", effects = { Happiness = 10, Money = 100000 }, resultText = "Loyalty has value. They appreciate you even more now." },
			{ text = "🚀 Counter with CEO demand", effects = { Happiness = -10 }, resultText = "Overreached. Offer withdrawn. Know when to push and when to accept." },
		},
	},
	
	{
		id = "biz_ethical_dilemma",
		minAge = 30, maxAge = 65,
		weight = 20, cooldown = 4,
		emoji = "⚖️", title = "Ethical Dilemma!",
		category = "work",
		requiresFlag = "corporate_worker",
		text = "Boss wants you to do something legally gray that will make the company millions. What do you do?",
		choices = {
			{ text = "🚨 Report it", effects = { Happiness = 15, Money = -20000, Smarts = 5 }, resultText = "Whistleblower protections kicked in. Right thing to do. Career complicated.", setFlag = "whistleblower" },
			{ text = "🙅 Refuse quietly", effects = { Happiness = 8, Money = -10000 }, resultText = "Declined without drama. Passed over for promotion. Sleep well though." },
			{ text = "✅ Do it anyway", effects = { Happiness = -10, Money = 100000, Smarts = -5 }, resultText = "Made the money. Soul feels dirty. Hope it doesn't come back to bite you.", setFlag = "morally_compromised" },
			{ text = "📋 Get it in writing first", effects = { Happiness = 5, Smarts = 10 }, resultText = "CYA move! If it blows up, you're protected. Smart but still risky." },
		},
	},
}

return module
