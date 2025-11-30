-- LifeEvents/career_tech.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- TECHNOLOGY CAREER EVENTS
-- Programmers, Hackers, Data Scientists, Game Devs, Tech Bros - The digital life
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent.init)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- EARLY TECH DISCOVERY
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "tech_first_computer",
		minAge = 6, maxAge = 14,
		weight = 30, oneTime = true,
		emoji = "💻", title = "First Computer!",
		category = "family",
		text = "You got your first computer! A whole new world opens up!",
		choices = {
			{ text = "🎮 Games all day!", effects = { Happiness = 12 }, resultText = "Gaming obsession begins! Maybe too much screen time...", setFlag = "gamer" },
			{ text = "💻 How does this work?", effects = { Happiness = 10, Smarts = 8 }, resultText = "You took it apart! Now to put it back together...", setFlags = {"computer_interest", "tinkerer"} },
			{ text = "🌐 Discovered the internet", effects = { Happiness = 8, Smarts = 5 }, resultText = "Infinite knowledge! And memes! The internet is amazing!", setFlag = "computer_interest" },
			{ text = "👨‍💻 Tried to code", effects = { Happiness = 10, Smarts = 10 }, resultText = "Hello World! Programming is like magic!", setFlags = {"computer_interest", "coder"} },
		},
	},
	
	{
		id = "tech_built_website",
		minAge = 12, maxAge = 20,
		weight = 25, oneTime = true,
		emoji = "🌐", title = "Built Your First Website!",
		category = "school",
		requiresFlag = "computer_interest",
		text = "You built a website from scratch! HTML, CSS, the works!",
		choices = {
			{ text = "🎨 It looks amazing!", effects = { Happiness = 15, Smarts = 5 }, resultText = "Actually looks professional! Friends are impressed!", setFlag = "web_dev" },
			{ text = "🤮 Looks terrible but works", effects = { Happiness = 8, Smarts = 8 }, resultText = "Function over form! The backend is what matters... right?", setFlag = "web_dev" },
			{ text = "💰 Made money from it", effects = { Happiness = 12, Money = 500, Smarts = 5 }, resultText = "People paid you to make THEIR websites!", setFlags = {"web_dev", "freelancer"} },
			{ text = "🔥 It got hacked", effects = { Happiness = -5, Smarts = 10 }, resultText = "Security vulnerability! Learned about cybersecurity the hard way.", setFlags = {"web_dev", "security_interest"} },
		},
	},
	
	{
		id = "tech_hackathon_teen",
		minAge = 14, maxAge = 19,
		weight = 20, cooldown = 2,
		emoji = "🏆", title = "Teen Hackathon!",
		category = "school",
		requiresFlag = "coder",
		getDynamicData = function()
			local projects = {"an app to help students study", "a game in 48 hours", "a tool for environmental tracking", "a social platform for teens", "an AI chatbot"}
			return { project = projects[math.random(#projects)] }
		end,
		text = "24-hour hackathon! You're building %project%!",
		choices = {
			{ text = "🏆 Won first place!", effects = { Happiness = 20, Money = 1000, Smarts = 8 }, resultText = "Your team dominated! Recruiters are watching!", setFlag = "hackathon_winner" },
			{ text = "💤 No sleep, finished!", effects = { Happiness = 10, Health = -5, Smarts = 5 }, resultText = "48 hours no sleep! Project works! Worth it!", setFlag = "hackathon_vet" },
			{ text = "🤝 Made great connections", effects = { Happiness = 12, Smarts = 3 }, resultText = "Met amazing developers! Future co-founders maybe?", setFlag = "tech_network" },
			{ text = "💥 Everything broke", effects = { Happiness = -8, Smarts = 5 }, resultText = "Demo failed spectacularly. Debugging nightmares." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- SOFTWARE ENGINEERING PATH
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "tech_first_dev_job",
		minAge = 18, maxAge = 30,
		weight = 25, oneTime = true,
		emoji = "👨‍💻", title = "First Developer Job!",
		category = "work",
		requiresFlag = "coder",
		getDynamicData = function()
			local companies = {"a startup", "a tech giant", "a consulting firm", "a remote company", "a game studio"}
			local salary = math.random(60, 120)
			return { company = companies[math.random(#companies)], salary = salary }
		end,
		text = "You got hired as a developer at %company%! Starting salary: $%salary%K!",
		choices = {
			{ text = "🎉 Dream job!", effects = { Happiness = 25, Money = 80000 }, resultText = "Free snacks, ping pong, and you get paid to code! Life is good!", setFlags = {"software_engineer", "employed"} },
			{ text = "😰 Imposter syndrome", effects = { Happiness = 8, Money = 75000, Smarts = 5 }, resultText = "Do you actually belong here? Everyone seems smarter...", setFlags = {"software_engineer", "employed", "imposter_syndrome"} },
			{ text = "🤓 Learning so much!", effects = { Happiness = 15, Money = 70000, Smarts = 10 }, resultText = "Senior devs mentoring you! Skills leveling up fast!", setFlags = {"software_engineer", "employed"} },
			{ text = "💼 It's just a job", effects = { Happiness = 10, Money = 85000 }, resultText = "Code, paycheck, go home. Work-life balance matters.", setFlags = {"software_engineer", "employed"} },
		},
	},
	
	{
		id = "tech_burnout",
		minAge = 22, maxAge = 50,
		weight = 25, cooldown = 3,
		emoji = "🔥", title = "Developer Burnout",
		category = "work",
		requiresFlag = "software_engineer",
		text = "Crunch time for months. Endless bugs. You're burnt out.",
		choices = {
			{ text = "🏖️ Take a sabbatical", effects = { Happiness = 15, Health = 10, Money = -20000 }, resultText = "Three months off. Rediscovered why you loved coding.", clearFlag = "burnt_out" },
			{ text = "🏃 Quit!", effects = { Happiness = 10, Money = -10000 }, resultText = "Life's too short for toxic workplaces!", clearFlags = {"employed"}, setFlag = "between_jobs" },
			{ text = "😔 Push through", effects = { Happiness = -15, Health = -10, Money = 20000 }, resultText = "Shipped the product. Feel empty inside.", setFlag = "burnt_out" },
			{ text = "💬 Therapy helps", effects = { Happiness = 10, Health = 5, Money = -2000 }, resultText = "Learning to set boundaries. Slow recovery.", setFlag = "in_therapy" },
		},
	},
	
	{
		id = "tech_faang_offer",
		minAge = 22, maxAge = 45,
		weight = 15, oneTime = true,
		emoji = "🏢", title = "FAANG Offer!",
		category = "work",
		requiresFlag = "software_engineer",
		getDynamicData = function()
			local companies = {"Google", "Meta", "Apple", "Amazon", "Netflix", "Microsoft"}
			local tc = math.random(200, 500)
			return { company = companies[math.random(#companies)], tc = tc }
		end,
		text = "%company% wants you! Total comp: $%tc%K/year!",
		choices = {
			{ text = "💰 Take it!", effects = { Happiness = 25, Money = 300000 }, resultText = "Big tech money! Stock options! The dream!", setFlags = {"faang_engineer", "high_earner"} },
			{ text = "📈 Negotiate higher", effects = { Happiness = 22, Money = 400000, Smarts = 5 }, resultText = "Counter-offered and won! Even better package!", setFlags = {"faang_engineer", "high_earner"} },
			{ text = "🤔 Prefer startup life", effects = { Happiness = 10, Smarts = 3 }, resultText = "Golden handcuffs aren't for you. Equity over salary." },
			{ text = "😰 Failed the interview", effects = { Happiness = -15, Smarts = 5 }, resultText = "Whiteboard coding is brutal. LeetCode grind continues." },
		},
	},
	
	{
		id = "tech_side_project_viral",
		minAge = 18, maxAge = 45,
		weight = 12, oneTime = true,
		emoji = "🚀", title = "Side Project Went Viral!",
		category = "work",
		requiresFlag = "coder",
		getDynamicData = function()
			local projects = {"your open-source tool", "the app you built for fun", "your indie game", "your browser extension", "your AI experiment"}
			local users = math.random(100, 500)
			return { project = projects[math.random(#projects)], users = users }
		end,
		text = "%project% has %users%K users! It's blowing up!",
		choices = {
			{ text = "💰 Monetize it!", effects = { Happiness = 25, Money = 50000 }, resultText = "Added premium features! Passive income flowing!", setFlags = {"indie_dev", "side_income"} },
			{ text = "🆓 Keep it free", effects = { Happiness = 20, Smarts = 5 }, resultText = "Open source hero! The community loves you!", setFlags = {"indie_dev", "open_source"} },
			{ text = "🏢 Got acquisition offers", effects = { Happiness = 20, Money = 500000 }, resultText = "A company wants to buy it! Big payout!", setFlags = {"indie_dev", "acquired"} },
			{ text = "😰 Can't handle the scale", effects = { Happiness = -5, Health = -5 }, resultText = "Server costs, bug reports, feature requests... drowning!" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- GAME DEVELOPMENT PATH
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "tech_first_game",
		minAge = 14, maxAge = 35,
		weight = 20, oneTime = true,
		emoji = "🎮", title = "Made Your First Game!",
		category = "work",
		requiresFlag = "coder",
		getDynamicData = function()
			local genres = {"a platformer", "an RPG", "a puzzle game", "a horror game", "a simulation"}
			return { genre = genres[math.random(#genres)] }
		end,
		text = "You finished developing %genre%! Time to release it!",
		choices = {
			{ text = "🎉 People love it!", effects = { Happiness = 25, Money = 5000, Smarts = 5 }, resultText = "Positive reviews! Players are streaming it!", setFlags = {"game_dev", "released_game"} },
			{ text = "😔 Barely any downloads", effects = { Happiness = -5, Smarts = 5 }, resultText = "Marketing is harder than coding. Lesson learned.", setFlag = "game_dev" },
			{ text = "🎥 Streamer played it!", effects = { Happiness = 20, Money = 20000 }, resultText = "A big streamer featured your game! Sales exploded!", setFlags = {"game_dev", "viral_game"} },
			{ text = "🏆 Won an award!", effects = { Happiness = 30, Money = 10000, Looks = 3 }, resultText = "Indie game award winner! Recognition feels amazing!", setFlags = {"game_dev", "award_winner"} },
		},
	},
	
	{
		id = "tech_game_studio",
		minAge = 22, maxAge = 45,
		weight = 15, oneTime = true,
		emoji = "🏢", title = "Start a Game Studio?",
		category = "work",
		requiresFlag = "game_dev",
		text = "Your games are getting noticed. Time to go bigger?",
		choices = {
			{ text = "🏢 Founded a studio!", effects = { Happiness = 20, Money = -50000 }, resultText = "Hired a small team! Time to make something amazing!", setFlags = {"studio_founder", "game_studio"} },
			{ text = "🤝 Joined a big studio", effects = { Happiness = 15, Money = 120000 }, resultText = "AAA development! Working on massive projects!", setFlags = {"aaa_dev", "employed"} },
			{ text = "🎮 Stay indie", effects = { Happiness = 18, Smarts = 3 }, resultText = "Small but independent. Creative freedom is priceless.", setFlag = "indie_forever" },
			{ text = "📱 Mobile games", effects = { Happiness = 10, Money = 100000 }, resultText = "Free-to-play mobile! Not glamorous but profitable!", setFlag = "mobile_dev" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- CYBERSECURITY / HACKING PATH
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "tech_first_hack",
		minAge = 14, maxAge = 25,
		weight = 15, oneTime = true,
		emoji = "🔓", title = "First Successful Hack",
		category = "social",
		requiresFlag = "security_interest",
		text = "You found a vulnerability in a system. You could exploit it...",
		choices = {
			{ text = "🎩 Report it (white hat)", effects = { Happiness = 15, Smarts = 10, Money = 1000 }, resultText = "Bug bounty reward! Responsible disclosure!", setFlags = {"white_hat", "ethical_hacker"} },
			{ text = "😈 Exploit it (black hat)", effects = { Happiness = 5, Money = 5000, Smarts = 8 }, resultText = "Got access to things you shouldn't. Thrilling but dangerous.", setFlags = {"black_hat", "criminal_hacker"} },
			{ text = "🤔 Just test it", effects = { Happiness = 10, Smarts = 8 }, resultText = "Explored the vulnerability but didn't do anything bad.", setFlag = "grey_hat" },
			{ text = "😰 Too scared", effects = { Happiness = -2, Smarts = 3 }, resultText = "Closed your laptop. Some doors shouldn't be opened." },
		},
	},
	
	{
		id = "tech_security_job",
		minAge = 20, maxAge = 50,
		weight = 20, oneTime = true,
		emoji = "🔐", title = "Cybersecurity Career!",
		category = "work",
		requiresFlag = "ethical_hacker",
		getDynamicData = function()
			local roles = {"penetration tester", "security analyst", "bug bounty hunter", "security consultant", "CISO"}
			local salary = math.random(100, 250)
			return { role = roles[math.random(#roles)], salary = salary }
		end,
		text = "Offered a job as a %role%! Salary: $%salary%K!",
		choices = {
			{ text = "🔐 Dream security job!", effects = { Happiness = 25, Money = 150000 }, resultText = "Getting paid to hack (legally)! Perfect career!", setFlags = {"security_pro", "employed"} },
			{ text = "💰 Bug bounties instead", effects = { Happiness = 20, Money = 100000 }, resultText = "Freelance hunter! Found a critical bug at a major company!", setFlags = {"bug_bounty_hunter", "freelancer"} },
			{ text = "🏛️ Government offer", effects = { Happiness = 15, Money = 120000, Smarts = 5 }, resultText = "Three letter agency... interesting work. Can't talk about it.", setFlags = {"gov_security", "classified"} },
			{ text = "🎓 Teach security", effects = { Happiness = 18, Money = 80000 }, resultText = "Training the next generation of security experts!", setFlags = {"security_teacher", "educator"} },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- AI / CUTTING EDGE
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "tech_ai_breakthrough",
		minAge = 25, maxAge = 55,
		weight = 8, oneTime = true,
		emoji = "🤖", title = "AI Breakthrough!",
		category = "work",
		requiresFlag = "software_engineer",
		text = "Your AI research achieved something significant! The tech world is watching!",
		choices = {
			{ text = "📄 Publish the paper", effects = { Happiness = 25, Smarts = 10 }, resultText = "Cited by everyone! You're a thought leader now!", setFlags = {"ai_researcher", "academic_respect"} },
			{ text = "🏢 Start an AI company", effects = { Happiness = 20, Money = 500000 }, resultText = "VCs throwing money at AI! Massive funding!", setFlags = {"ai_founder", "startup_founder"} },
			{ text = "😰 Ethical concerns", effects = { Happiness = -5, Smarts = 8 }, resultText = "This could be dangerous... should you release it?", setFlag = "ai_ethics" },
			{ text = "💰 Sell to big tech", effects = { Happiness = 15, Money = 5000000 }, resultText = "Acquired by a tech giant! Set for life!", setFlags = {"ai_researcher", "acquired"} },
		},
	},
	
	{
		id = "tech_legacy",
		minAge = 50, maxAge = 80,
		weight = 15, oneTime = true,
		emoji = "🏛️", title = "Tech Legend Status",
		category = "work",
		requiresFlag = "faang_engineer",
		text = "Reflecting on decades in tech. What's your legacy?",
		choices = {
			{ text = "📚 Wrote influential books", effects = { Happiness = 25, Money = 200000, Smarts = 5 }, resultText = "Your books taught millions to code. Legacy secured.", setFlag = "tech_author" },
			{ text = "🎓 Stanford professorship", effects = { Happiness = 22, Money = 150000 }, resultText = "Teaching at a top university. Shaping future innovators.", setFlag = "tech_professor" },
			{ text = "🌍 Tech for good", effects = { Happiness = 30, Money = -100000 }, resultText = "Built technology that helps developing nations. Meaningful work.", setFlag = "tech_philanthropist" },
			{ text = "🏖️ Retire wealthy", effects = { Happiness = 20, Health = 5 }, resultText = "FIRE achieved decades ago. Enjoying the rewards of your career.", setFlag = "retired_tech" },
		},
	},
}

return module
