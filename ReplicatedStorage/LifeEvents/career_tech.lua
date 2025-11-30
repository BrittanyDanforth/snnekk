-- LifeEvents/career_tech.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- TECHNOLOGY & PROGRAMMING CAREER EVENTS
-- BitLife-style: Player picks ACTIONS, game decides OUTCOMES
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent.init)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- EARLY TECH INTEREST
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "tech_first_computer",
		minAge = 8, maxAge = 14,
		weight = 25, oneTime = true,
		emoji = "💻", title = "Got a Computer!",
		category = "school",
		text = "You got your first computer! What do you spend most of your time doing?",
		choices = {
			{ text = "💻 Try to learn coding", effects = { Smarts = 15, Happiness = 10 }, resultText = "Hello World! Your first program! You're hooked!", setFlags = {"programmer", "tech_natural"} },
			{ text = "🎮 Just play games", effects = { Happiness = 12, Smarts = 3 }, resultText = "Gaming is life! Maybe you'll make games someday?", setFlag = "gamer" },
			{ text = "🔧 Take it apart", effects = { Smarts = 10, Happiness = 8 }, resultText = "Learned how it all works! Put it back together (mostly)!", setFlag = "hardware_curious" },
			{ text = "📱 Social media only", effects = { Happiness = 8 }, resultText = "Spending hours online. Not learning much but connected!" },
		},
	},
	
	{
		id = "tech_teen_hacking",
		minAge = 13, maxAge = 17,
		weight = 20, oneTime = true,
		emoji = "🔓", title = "Discovered Something!",
		category = "school",
		requiresFlag = "programmer",
		text = "You found a security flaw in your school's network! What do you do?",
		choices = {
			{ text = "🎓 Report it to IT", effects = { Happiness = 15, Smarts = 8 }, resultText = "They were impressed! Offered you a student IT job!", setFlags = {"white_hat", "cybersecurity"} },
			{ text = "😈 Exploit it for grades", effects = { Happiness = 10, Smarts = -5, Money = 0 }, resultText = "Changed some grades... got caught. Suspended! Bad idea.", setFlag = "black_hat" },
			{ text = "🤫 Tell no one", effects = { Happiness = 5, Smarts = 3 }, resultText = "Kept the secret. Nothing bad happened. Opportunity wasted?" },
			{ text = "📢 Brag to friends", effects = { Happiness = -10, Smarts = 3 }, resultText = "Word got back to administration. In trouble but not expelled. Close call!" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- EDUCATION & EARLY CAREER
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "tech_college_path",
		minAge = 17, maxAge = 19,
		weight = 20, oneTime = true,
		emoji = "🎓", title = "College Decision!",
		category = "school",
		requiresFlag = "programmer",
		text = "College time! What path do you take for your tech career?",
		choices = {
			{ text = "🎓 CS degree at university", effects = { Smarts = 15, Money = -80000 }, resultText = "Stanford/MIT/etc! Rigorous education! Networking opportunities!", setFlags = {"cs_degree", "college_grad"} },
			{ text = "🏫 Coding bootcamp", effects = { Smarts = 10, Money = -15000 }, resultText = "3 months of intensive training! Job-ready fast!", setFlag = "bootcamp_grad" },
			{ text = "📚 Self-taught route", effects = { Smarts = 12, Happiness = 5 }, resultText = "YouTube, docs, and Stack Overflow! The free path!", setFlag = "self_taught" },
			{ text = "💼 Skip education, just work", effects = { Happiness = 8, Money = 30000 }, resultText = "Started at a startup that doesn't care about degrees!", setFlag = "school_of_hard_knocks" },
		},
	},
	
	{
		id = "tech_first_job",
		minAge = 20, maxAge = 28,
		weight = 20, oneTime = true,
		emoji = "👨‍💻", title = "First Tech Job Interview!",
		category = "work",
		requiresFlag = "programmer",
		getDynamicData = function()
			local companies = {"Google", "Facebook", "a hot startup", "Microsoft", "Amazon"}
			return { company = companies[math.random(#companies)] }
		end,
		text = "Interview at %company%! The coding challenge is hard. How do you approach it?",
		choices = {
			{ text = "🧠 Solve it cleanly", effects = { Happiness = 25, Money = 120000, Smarts = 5 }, resultText = "NAILED IT! Offer letter incoming! Six figures!", setFlags = {"software_engineer", "employed"} },
			{ text = "🤔 Talk through your thinking", effects = { Happiness = 18, Money = 100000 }, resultText = "Didn't solve it perfectly but they liked your process! Hired!", setFlags = {"software_engineer", "employed"} },
			{ text = "😰 Panic and blank", effects = { Happiness = -15 }, resultText = "Froze under pressure. Rejection email. Practice more." },
			{ text = "🤷 Guess randomly", effects = { Happiness = -10 }, resultText = "They could tell you were guessing. No offer. Not ready yet." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- MID CAREER
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "tech_side_project",
		minAge = 22, maxAge = 40,
		weight = 25, cooldown = 3,
		emoji = "🚀", title = "Side Project Idea!",
		category = "work",
		requiresFlag = "software_engineer",
		getDynamicData = function()
			local projects = {"a mobile app", "a browser extension", "a SaaS tool", "an open source project"}
			return { project = projects[math.random(#projects)] }
		end,
		text = "You have an idea for %project%! Do you build it?",
		choices = {
			{ text = "🌙 Build nights/weekends", effects = { Happiness = 15, Health = -5, Smarts = 5 }, resultText = "It's DONE! Launched it! Now to see if anyone uses it...", setFlag = "side_project" },
			{ text = "🚀 Go full time on it", effects = { Happiness = 12, Money = -20000 }, resultText = "Quit to focus! All in! Startup founder mode!", setFlag = "indie_developer" },
			{ text = "🤝 Find a cofounder", effects = { Happiness = 10, Smarts = 3 }, resultText = "Partnered with someone! Sharing the work and the vision!", setFlags = {"side_project", "has_partner"} },
			{ text = "📝 Never start", effects = { Happiness = -5 }, resultText = "The idea sits in a notes app forever. Another what-if." },
		},
	},
	
	{
		id = "tech_project_viral",
		minAge = 22, maxAge = 45,
		weight = 15, oneTime = true,
		emoji = "📈", title = "Project Going Viral!",
		category = "work",
		requiresFlag = "side_project",
		text = "Your side project is BLOWING UP! Hacker News front page! 100k users overnight! What do you do?",
		choices = {
			{ text = "🚀 Drop everything for it", effects = { Happiness = 30, Money = -10000 }, resultText = "Quit your job! Going all in! This is the opportunity!", setFlags = {"founder", "startup_mode"} },
			{ text = "💰 Monetize quick", effects = { Happiness = 20, Money = 50000 }, resultText = "Added premium tier! Money flowing in! Keeping day job for now!", setFlag = "profitable_project" },
			{ text = "🆓 Keep it free forever", effects = { Happiness = 15, Smarts = 3 }, resultText = "Community loves you! No money but tons of respect and GitHub stars!" },
			{ text = "💼 Sell it to a company", effects = { Happiness = 18, Money = 200000 }, resultText = "Acquisition! Nice payout! Someone else's problem now!", setFlag = "had_exit" },
		},
	},
	
	{
		id = "tech_faang_offer",
		minAge = 24, maxAge = 40,
		weight = 15, oneTime = true,
		emoji = "🏢", title = "FAANG Company Offer!",
		category = "work",
		requiresFlag = "software_engineer",
		getDynamicData = function()
			local companies = {"Google", "Apple", "Meta", "Amazon", "Netflix"}
			local packages = {350000, 400000, 450000, 500000}
			return { company = companies[math.random(#companies)], package = packages[math.random(#packages)] }
		end,
		text = "%company% offering $%package%/year total comp! The dream! What do you do?",
		choices = {
			{ text = "✅ Accept!", effects = { Happiness = 30, Money = 200000, Looks = 3 }, resultText = "You work at %company% now! Prestige unlocked! Golden handcuffs on!", setFlags = {"faang_engineer", "big_tech"} },
			{ text = "📋 Negotiate higher", effects = { Happiness = 28, Money = 250000, Smarts = 5 }, resultText = "Got a signing bonus bump! Always negotiate!", setFlags = {"faang_engineer", "big_tech"} },
			{ text = "🚀 Reject for startup", effects = { Happiness = 20, Money = 50000 }, resultText = "Chose equity over salary! High risk high reward!", setFlag = "startup_bet" },
			{ text = "😰 Fail the interview", effects = { Happiness = -15 }, resultText = "Bombed the system design round. No offer. Try again in 6 months." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- SENIOR / MANAGEMENT
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "tech_management_track",
		minAge = 28, maxAge = 45,
		weight = 20, oneTime = true,
		emoji = "👥", title = "Management Opportunity!",
		category = "work",
		requiresFlag = "software_engineer",
		text = "Offered to lead a team of engineers! But you'd write less code. What do you do?",
		choices = {
			{ text = "👥 Become a manager", effects = { Happiness = 15, Money = 50000 }, resultText = "Engineering Manager now! Different skills! Leading people!", setFlags = {"engineering_manager", "people_leader"} },
			{ text = "💻 Stay technical (IC)", effects = { Happiness = 18, Money = 40000, Smarts = 5 }, resultText = "Principal Engineer path! Deep technical work! Individual contributor!", setFlag = "senior_ic" },
			{ text = "⚖️ Try manager, can switch back", effects = { Happiness = 12, Money = 40000 }, resultText = "Trying it out! Can always return to coding if you hate it!" },
			{ text = "🚀 Leave for CTO role", effects = { Happiness = 20, Money = 30000 }, resultText = "Startup offered CTO title! Smaller company, bigger role!", setFlags = {"cto", "startup_executive"} },
		},
	},
	
	{
		id = "tech_burnout",
		minAge = 25, maxAge = 50,
		weight = 25, cooldown = 4,
		emoji = "😴", title = "Burning Out...",
		category = "health",
		requiresFlag = "software_engineer",
		text = "Constant on-call, tight deadlines, endless Slack. You're exhausted. What do you do?",
		choices = {
			{ text = "🏖️ Take a sabbatical", effects = { Happiness = 20, Health = 15, Money = -20000 }, resultText = "Unplugged for 3 months! Came back refreshed! Worth it!", clearFlag = "burnout" },
			{ text = "🏃 Leave for calmer job", effects = { Happiness = 15, Health = 10, Money = -30000 }, resultText = "New company, better work-life balance! Sanity restored!", clearFlag = "burnout" },
			{ text = "💪 Push through it", effects = { Happiness = -15, Health = -20 }, resultText = "Made it worse. Now you REALLY need to stop.", setFlag = "severe_burnout" },
			{ text = "🧘 Set strict boundaries", effects = { Happiness = 10, Health = 8 }, resultText = "No more after-hours Slack! Calendar blocked! Self-care activated!", clearFlag = "burnout" },
		},
	},
	
	{
		id = "tech_layoffs",
		minAge = 23, maxAge = 55,
		weight = 20, cooldown = 5,
		emoji = "📉", title = "Company Layoffs!",
		category = "work",
		requiresFlag = "software_engineer",
		text = "Mass layoffs announced! 20% of the company! Your meeting is tomorrow. What do you do?",
		choices = {
			{ text = "📄 Prepare resume just in case", effects = { Happiness = 5, Smarts = 5 }, resultText = "SURVIVED! Not on the list! But resume is ready now.", setFlag = "layoff_survivor" },
			{ text = "😰 Lose sleep worrying", effects = { Happiness = -20, Health = -5 }, resultText = "You're SAFE! But the anxiety was brutal. Still traumatized." },
			{ text = "💼 Already interviewing elsewhere", effects = { Happiness = 15, Money = 20000 }, resultText = "Got laid off BUT had another offer ready! Smooth transition!" },
			{ text = "🎯 Perform extra hard", effects = { Happiness = 8, Health = -3 }, resultText = "They noticed your effort! Kept you! Hard work paid off!" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- AI / CUTTING EDGE
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "tech_ai_transition",
		minAge = 25, maxAge = 50,
		weight = 20, oneTime = true,
		emoji = "🤖", title = "AI Revolution!",
		category = "work",
		requiresFlag = "software_engineer",
		text = "AI is changing everything! Your skills might become obsolete. What do you do?",
		choices = {
			{ text = "🧠 Learn AI/ML deeply", effects = { Happiness = 15, Smarts = 15 }, resultText = "Upskilled! Now an AI engineer! More valuable than ever!", setFlags = {"ai_engineer", "future_proof"} },
			{ text = "🤖 Use AI to 10x output", effects = { Happiness = 18, Smarts = 10 }, resultText = "AI tools making you way more productive! Embracing the future!", setFlag = "ai_augmented" },
			{ text = "😤 Refuse to change", effects = { Happiness = -10, Smarts = -5 }, resultText = "Falling behind. Companies want AI-native developers now. Adapt or..." },
			{ text = "🎓 Get an AI-focused degree", effects = { Smarts = 20, Money = -50000 }, resultText = "Back to school for ML masters! Investing in the future!", setFlags = {"ai_specialist", "grad_student"} },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- BUG BOUNTY & SECURITY
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "tech_bug_bounty",
		minAge = 18, maxAge = 45,
		weight = 18, cooldown = 2,
		emoji = "🐛", title = "Bug Bounty Hunt!",
		category = "work",
		showResultPopup = true,
		getDynamicData = function()
			local companies = {"a major bank", "a social media company", "a tech giant", "a crypto exchange", "a gaming platform"}
			local rewards = {1000, 2500, 5000, 10000, 15000}
			return { company = companies[math.random(#companies)], reward = rewards[math.random(#rewards)] }
		end,
		text = "%company% is offering $%reward% for finding security bugs in their website. Do you try?",
		choices = {
			{ 
				text = "👨‍💻 Hunt for bugs (minigame!)", 
				requires = { Smarts = 40 },
				effects = { Smarts = 3 },
				minigame = {
					id = "typing",
					difficulty = "medium",
					rewardOnSuccess = { Money = 5000, Smarts = 5 },
					rewardOnFail = { Happiness = -5 },
				},
				chanceSuccess = 0.6,
				effectsOnSuccess = { Money = 5000, Happiness = 15 },
				resultTextSuccess = "FOUND A CRITICAL VULNERABILITY! $%reward% deposited! Bug bounty hunter status: ACTIVE! 💰",
				effectsOnFail = { Happiness = -8 },
				resultTextFail = "Searched for hours but found nothing exploitable. Someone else probably got the bugs first.",
				setFlag = "bug_bounty_hunter"
			},
			{ 
				text = "📚 Study their systems first", 
				effects = { Smarts = 5, Happiness = 2 },
				chanceSuccess = 0.7,
				effectsOnSuccess = { Money = 2000, Happiness = 10 },
				resultTextSuccess = "Research paid off! Found a low-severity bug! Small payout but it's honest work!",
				effectsOnFail = { Happiness = -3 },
				resultTextFail = "Learned a lot but didn't find any bugs this time. Next time!",
				setFlag = "security_researcher"
			},
			{ 
				text = "🙅 Too risky, skip it", 
				effects = { Happiness = 2 }, 
				resultText = "Probably wise. Bug bounties are competitive and time-consuming." 
			},
		},
	},
	
	{
		id = "tech_freelance_gig",
		minAge = 20, maxAge = 50,
		weight = 20, cooldown = 2,
		emoji = "💻", title = "Freelance Opportunity!",
		category = "work",
		requiresFlag = "programmer",
		showResultPopup = true,
		getDynamicData = function()
			local projects = {"build a website", "create a mobile app", "set up a database", "automate some tasks"}
			local payments = {500, 1500, 3000, 5000}
			return { project = projects[math.random(#projects)], payment = payments[math.random(#payments)] }
		end,
		text = "Someone on a freelance platform wants you to %project% for $%payment%. Take the job?",
		choices = {
			{ 
				text = "✅ Accept the gig!", 
				effects = { Health = -3 }, -- Work is tiring
				chanceSuccess = 0.75,
				effectsOnSuccess = { Money = 3000, Happiness = 12, Smarts = 3 },
				resultTextSuccess = "Delivered on time! Client is THRILLED! 5-star review! More gigs coming!",
				effectsOnFail = { Happiness = -10, Money = -500 },
				resultTextFail = "Project scope creeped. Client unhappy. Partial payment. Lesson learned about contracts.",
				setFlag = "freelancer"
			},
			{ 
				text = "📋 Negotiate higher rate", 
				effects = { Smarts = 2 },
				chanceSuccess = 0.5,
				effectsOnSuccess = { Money = 5000, Happiness = 15 },
				resultTextSuccess = "They agreed to pay more! Your skills are worth it! 💰",
				effectsOnFail = { Happiness = -5 },
				resultTextFail = "They said no and found someone cheaper. Maybe too aggressive.",
			},
			{ 
				text = "❌ Too busy, decline", 
				effects = { Happiness = 3 }, 
				resultText = "Passed on this one. Work-life balance matters." 
			},
		},
	},
}

return module
