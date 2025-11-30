-- LifeEvents/career_business.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- BUSINESS & ENTREPRENEURSHIP CAREER EVENTS
-- Startups, Corporate Ladder, CEOs, Moguls - The hustle life
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent.init)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- EARLY ENTREPRENEURIAL SPIRIT
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "biz_childhood_lemonade",
		minAge = 7, maxAge = 12,
		weight = 30, oneTime = true,
		emoji = "🍋", title = "Lemonade Stand!",
		category = "work",
		text = "You want to start a lemonade stand in the neighborhood!",
		choices = {
			{ text = "💰 Made good money!", effects = { Happiness = 12, Money = 50, Smarts = 5 }, resultText = "$50 in a day! You're a natural entrepreneur!", setFlag = "business_minded" },
			{ text = "📊 Learned about business", effects = { Happiness = 8, Smarts = 8 }, resultText = "Expenses, profit margins... business is fascinating!", setFlag = "business_minded" },
			{ text = "😅 Nobody came", effects = { Happiness = -3, Smarts = 3 }, resultText = "Location matters. Lesson learned." },
			{ text = "🏆 Best on the block!", effects = { Happiness = 15, Money = 100 }, resultText = "Dominated the competition! Other kids couldn't keep up!", setFlags = {"business_minded", "competitive"} },
		},
	},
	
	{
		id = "biz_teen_hustle",
		minAge = 14, maxAge = 18,
		weight = 25, cooldown = 3,
		emoji = "💼", title = "Teen Side Hustle!",
		category = "work",
		getDynamicData = function()
			local hustles = {"reselling sneakers", "tutoring younger kids", "lawn care business", "social media management", "selling crafts online"}
			return { hustle = hustles[math.random(#hustles)] }
		end,
		text = "You started %hustle% to make some extra money!",
		choices = {
			{ text = "💰 Killing it!", effects = { Happiness = 15, Money = 2000, Smarts = 5 }, resultText = "Making more than most adults! Hustle pays off!", setFlag = "entrepreneur" },
			{ text = "📈 Scaling up!", effects = { Happiness = 12, Money = 1000, Smarts = 8 }, resultText = "Hired friends to help. You're building something!", setFlags = {"entrepreneur", "manager"} },
			{ text = "😅 Barely breaking even", effects = { Happiness = 3, Smarts = 5 }, resultText = "Hard work for little reward. But you're learning." },
			{ text = "❌ Had to shut down", effects = { Happiness = -5, Smarts = 3 }, resultText = "Didn't work out. Failure is part of the journey." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- STARTUP FOUNDER PATH
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "biz_startup_idea",
		minAge = 20, maxAge = 45,
		weight = 20, oneTime = true,
		emoji = "💡", title = "Million Dollar Idea!",
		category = "work",
		requiresFlag = "business_minded",
		getDynamicData = function()
			local ideas = {
				"an app that connects local service providers",
				"a sustainable fashion marketplace",
				"an AI-powered productivity tool",
				"a subscription box for niche hobbies",
				"a platform for freelance professionals",
			}
			return { idea = ideas[math.random(#ideas)] }
		end,
		text = "You have an idea for %idea%! This could be huge!",
		choices = {
			{ text = "🚀 Quit job and build it!", effects = { Happiness = 15, Money = -20000 }, resultText = "All in! Savings depleted but the dream is alive!", setFlag = "startup_founder" },
			{ text = "🌙 Build it nights/weekends", effects = { Happiness = 5, Health = -5, Smarts = 5 }, resultText = "No sleep but making progress. Safe approach.", setFlag = "startup_founder" },
			{ text = "🤝 Find a co-founder", effects = { Happiness = 12, Smarts = 3 }, resultText = "Found someone as crazy as you! Partnership formed!", setFlags = {"startup_founder", "has_cofounder"} },
			{ text = "📋 Too risky", effects = { Happiness = -5 }, resultText = "Filed the idea away. Maybe someday..." },
		},
	},
	
	{
		id = "biz_pitch_competition",
		minAge = 20, maxAge = 50,
		weight = 25, cooldown = 3,
		emoji = "🎤", title = "Pitch Competition!",
		category = "work",
		requiresFlag = "startup_founder",
		getDynamicData = function()
			local competitions = {"a local startup event", "TechCrunch Disrupt", "Y Combinator Demo Day", "a university competition", "Shark Tank auditions"}
			return { competition = competitions[math.random(#competitions)] }
		end,
		text = "You're presenting your startup at %competition%!",
		choices = {
			{ text = "🏆 Won first place!", effects = { Happiness = 25, Money = 50000, Smarts = 5 }, resultText = "Investors are calling! You crushed it!", setFlag = "funded_startup" },
			{ text = "💰 Got seed funding!", effects = { Happiness = 20, Money = 100000 }, resultText = "An investor believed in you! $100K seed round!", setFlag = "funded_startup" },
			{ text = "📊 Good feedback", effects = { Happiness = 8, Smarts = 5 }, resultText = "Didn't win but learned what to improve." },
			{ text = "😰 Bombed the pitch", effects = { Happiness = -15, Health = -3 }, resultText = "Froze up. Stumbled over words. Crushing defeat." },
		},
	},
	
	{
		id = "biz_series_a",
		minAge = 22, maxAge = 50,
		weight = 15, oneTime = true,
		emoji = "📈", title = "Series A Funding!",
		category = "work",
		requiresFlag = "funded_startup",
		getDynamicData = function()
			local amount = math.random(2, 10)
			return { amount = amount }
		end,
		text = "VCs want to invest $%amount% MILLION in your company!",
		choices = {
			{ text = "💰 Take the money!", effects = { Happiness = 30, Money = 500000 }, resultText = "Funded! Time to scale! Hired 20 people!", setFlags = {"venture_backed", "ceo"} },
			{ text = "📋 Negotiate hard", effects = { Happiness = 25, Money = 600000, Smarts = 5 }, resultText = "Better terms, kept more equity. Smart move!", setFlags = {"venture_backed", "ceo"} },
			{ text = "🤔 Bootstrap instead", effects = { Happiness = 10, Smarts = 5 }, resultText = "Turned down the money. Keeping full control.", setFlag = "bootstrapped" },
			{ text = "⚠️ Lost control", effects = { Happiness = 5, Money = 400000 }, resultText = "Took bad terms. VCs now control the board.", setFlags = {"venture_backed", "lost_control"} },
		},
	},
	
	{
		id = "biz_startup_failure",
		minAge = 22, maxAge = 55,
		weight = 20, cooldown = 5,
		emoji = "📉", title = "Startup Failing!",
		category = "work",
		requiresFlag = "startup_founder",
		text = "Runway is running out. Revenue isn't growing. The startup is dying.",
		choices = {
			{ text = "🔄 Pivot!", effects = { Happiness = 5, Smarts = 8 }, resultText = "Completely changed direction. New product, new market. Saved it!", setFlag = "pivoted" },
			{ text = "💔 Shut it down", effects = { Happiness = -25, Money = -50000, Smarts = 5 }, resultText = "Called the investors. Laid off the team. It's over. Devastating.", clearFlags = {"startup_founder", "funded_startup"}, setFlag = "failed_founder" },
			{ text = "🤝 Get acquired", effects = { Happiness = 5, Money = 100000 }, resultText = "Bigger company bought you out. Not the dream but not zero.", clearFlag = "startup_founder", setFlag = "acqui_hired" },
			{ text = "💪 One more push", effects = { Happiness = -10, Health = -10, Money = -30000 }, resultText = "Poured everything in. Either this works or you're done." },
		},
	},
	
	{
		id = "biz_ipo",
		minAge = 28, maxAge = 60,
		weight = 5, oneTime = true,
		emoji = "🔔", title = "IPO DAY!",
		category = "work",
		requiresFlag = "venture_backed",
		getDynamicData = function()
			local valuation = math.random(500, 5000)
			return { valuation = valuation }
		end,
		text = "YOUR COMPANY IS GOING PUBLIC! Valued at $%valuation% MILLION!",
		choices = {
			{ text = "🔔 Ring the bell!", effects = { Happiness = 50, Money = 10000000, Looks = 5 }, resultText = "You rang the NYSE bell! You're worth hundreds of millions! DREAM ACHIEVED!", setFlags = {"ipo_founder", "ultra_wealthy"} },
			{ text = "😭 Tears of joy", effects = { Happiness = 45, Money = 8000000 }, resultText = "From a garage to the stock market. Unbelievable journey.", setFlags = {"ipo_founder", "ultra_wealthy"} },
			{ text = "📉 Stock tanked", effects = { Happiness = 10, Money = 2000000 }, resultText = "IPO flopped. Still rich but not what you dreamed.", setFlag = "ipo_founder" },
			{ text = "🎉 Party like crazy", effects = { Happiness = 40, Money = 7000000, Health = -5 }, resultText = "The celebration lasted a week! You made it!", setFlags = {"ipo_founder", "ultra_wealthy"} },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- CORPORATE LADDER PATH
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "biz_first_promotion",
		minAge = 24, maxAge = 40,
		weight = 30, cooldown = 3,
		emoji = "📈", title = "Promotion Opportunity!",
		category = "work",
		requiresFlag = "employed",
		getDynamicData = function()
			local titles = {"Senior Associate", "Team Lead", "Manager", "Director", "VP"}
			return { title = titles[math.random(#titles)] }
		end,
		text = "There's an opening for %title%. You're in the running!",
		choices = {
			{ text = "💼 Got it!", effects = { Happiness = 20, Money = 15000, Smarts = 3 }, resultText = "PROMOTED! New title, better pay, bigger office!", setFlag = "management" },
			{ text = "😔 Passed over", effects = { Happiness = -15, Smarts = 2 }, resultText = "They gave it to someone else. Politics." },
			{ text = "🤝 Negotiated hard", effects = { Happiness = 18, Money = 20000, Smarts = 5 }, resultText = "Got the promotion AND a bigger raise than offered!", setFlag = "management" },
			{ text = "🏃 Quit instead", effects = { Happiness = 5, Money = -5000 }, resultText = "If they don't see your value, someone else will.", clearFlag = "employed" },
		},
	},
	
	{
		id = "biz_backstabbed",
		minAge = 25, maxAge = 55,
		weight = 20, cooldown = 4,
		emoji = "🗡️", title = "Office Backstabbing!",
		category = "work",
		requiresFlag = "management",
		getDynamicData = function()
			return { traitorName = LifeEvents.randomFirstName() }
		end,
		text = "%traitorName% took credit for your work and got YOUR promotion!",
		choices = {
			{ text = "😤 Confront them", effects = { Happiness = 5, Smarts = 3 }, resultText = "Called them out in front of leadership. Risky but satisfying." },
			{ text = "📧 Document everything", effects = { Happiness = 2, Smarts = 8 }, resultText = "Building a case. Your time will come.", setFlag = "cautious" },
			{ text = "🤝 Play the game", effects = { Happiness = -5, Smarts = 5 }, resultText = "Corporate politics. Two can play at that.", setFlag = "political" },
			{ text = "💔 Devastated", effects = { Happiness = -20, Health = -5 }, resultText = "Betrayed by someone you trusted. The corporate world is cruel." },
		},
	},
	
	{
		id = "biz_ceo_offer",
		minAge = 40, maxAge = 60,
		weight = 8, oneTime = true,
		emoji = "👔", title = "CEO Position Offered!",
		category = "work",
		requiresFlag = "management",
		getDynamicData = function()
			local companies = {"a Fortune 500 company", "a growing tech firm", "an established retailer", "a major bank", "a healthcare company"}
			return { company = companies[math.random(#companies)] }
		end,
		text = "The board of %company% wants YOU as their next CEO!",
		choices = {
			{ text = "💼 Accept!", effects = { Happiness = 35, Money = 2000000 }, resultText = "You're the CEO! Corner office, private jet, golden parachute!", setFlags = {"ceo", "executive"} },
			{ text = "📋 Negotiate package", effects = { Happiness = 30, Money = 3000000, Smarts = 5 }, resultText = "Better salary, more equity, signing bonus. Well played!", setFlags = {"ceo", "executive"} },
			{ text = "🤔 Too much pressure", effects = { Happiness = 5, Smarts = 3 }, resultText = "Turned it down. The golden handcuffs aren't worth the stress." },
			{ text = "😰 Imposter syndrome", effects = { Happiness = 15, Money = 1500000 }, resultText = "Took it but... do you deserve this? The doubt is real.", setFlags = {"ceo", "imposter_syndrome"} },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- BUSINESS STRUGGLES & ETHICS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "biz_layoffs",
		minAge = 30, maxAge = 65,
		weight = 20, cooldown = 4,
		emoji = "📉", title = "Layoffs Decision",
		category = "work",
		requiresFlag = "management",
		getDynamicData = function()
			local people = math.random(10, 100)
			return { people = people }
		end,
		text = "Company needs to cut costs. You have to lay off %people% people.",
		choices = {
			{ text = "😔 Do it humanely", effects = { Happiness = -15, Smarts = 3 }, resultText = "Gave good severance. It's still awful but you did it right." },
			{ text = "😤 Refuse and resign", effects = { Happiness = -5, Money = -50000 }, resultText = "You couldn't fire people. Quit on principle.", clearFlags = {"management", "employed"} },
			{ text = "💼 Just business", effects = { Happiness = -5, Smarts = -2 }, resultText = "Cold but necessary. The bottom line matters.", setFlag = "ruthless" },
			{ text = "😭 Hardest day ever", effects = { Happiness = -25, Health = -5 }, resultText = "Looking people in the eye and ending their careers. Haunting." },
		},
	},
	
	{
		id = "biz_ethical_dilemma",
		minAge = 25, maxAge = 65,
		weight = 20, cooldown = 4,
		emoji = "⚖️", title = "Ethical Dilemma",
		category = "work",
		requiresFlag = "management",
		text = "Your boss wants you to do something unethical to hit quarterly numbers.",
		choices = {
			{ text = "🙅 Refuse", effects = { Happiness = 10, Smarts = 5 }, resultText = "Stood your ground. Might have killed your career but kept your soul.", setFlag = "ethical" },
			{ text = "📧 Whistleblow", effects = { Happiness = 5, Money = -20000, Smarts = 5 }, resultText = "Reported it. Legal battle ahead but doing the right thing.", setFlags = {"whistleblower", "ethical"} },
			{ text = "😔 Comply reluctantly", effects = { Happiness = -15, Money = 10000 }, resultText = "Did it. Hate yourself. But kept the job.", setFlag = "compromised" },
			{ text = "💰 Ask for more money", effects = { Happiness = -10, Money = 30000, Smarts = -3 }, resultText = "If you're going to sell out, at least get paid well.", setFlag = "corrupt" },
		},
	},
	
	{
		id = "biz_bankruptcy",
		minAge = 30, maxAge = 70,
		weight = 10, oneTime = true,
		emoji = "💸", title = "Business Bankruptcy",
		category = "work",
		requiresFlag = "startup_founder",
		text = "Your business is bankrupt. Debts overwhelming. It's over.",
		choices = {
			{ text = "💔 Lost everything", effects = { Happiness = -35, Money = -100000, Health = -10 }, resultText = "Years of work gone. Starting from nothing again.", clearFlags = {"startup_founder", "ceo"}, setFlag = "bankrupt" },
			{ text = "📚 Learn from failure", effects = { Happiness = -15, Smarts = 10 }, resultText = "Failure is the best teacher. You'll come back stronger.", setFlag = "resilient" },
			{ text = "🤝 File Chapter 11", effects = { Happiness = -10, Money = -50000 }, resultText = "Restructuring instead of liquidating. Fighting to survive." },
			{ text = "😰 Depression hits", effects = { Happiness = -40, Health = -15 }, resultText = "Can't get out of bed. Lost everything you built. Need help.", setFlags = {"bankrupt", "depressed"} },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- BUSINESS SUCCESS & LEGACY
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "biz_forbes_list",
		minAge = 35, maxAge = 80,
		weight = 5, oneTime = true,
		emoji = "📰", title = "Forbes List!",
		category = "work",
		requiresFlag = "ultra_wealthy",
		getDynamicData = function()
			local ranking = math.random(50, 400)
			return { ranking = ranking }
		end,
		text = "You made the Forbes Billionaires list! Ranked #%ranking%!",
		choices = {
			{ text = "🎉 Made it!", effects = { Happiness = 40, Looks = 5 }, resultText = "Billionaire status confirmed! The world knows your name!", setFlag = "billionaire" },
			{ text = "🎯 Want higher", effects = { Happiness = 15, Smarts = 3 }, resultText = "Not satisfied yet. Eyes on the top 10.", setFlag = "billionaire" },
			{ text = "🤫 Prefer privacy", effects = { Happiness = 20 }, resultText = "Don't like the attention. Too many people asking for money now.", setFlag = "billionaire" },
			{ text = "💝 Time to give back", effects = { Happiness = 30, Money = -10000000 }, resultText = "Started a foundation. Giving away half your wealth.", setFlags = {"billionaire", "philanthropist"} },
		},
	},
	
	{
		id = "biz_legacy",
		minAge = 55, maxAge = 85,
		weight = 15, oneTime = true,
		emoji = "🏛️", title = "Building Your Legacy",
		category = "work",
		requiresFlag = "ceo",
		text = "Thinking about what you'll leave behind. What kind of legacy do you want?",
		choices = {
			{ text = "🏫 Fund a school", effects = { Happiness = 25, Money = -5000000, Smarts = 5 }, resultText = "A business school bears your name. Educating future entrepreneurs.", setFlag = "legacy_builder" },
			{ text = "🏥 Build a hospital", effects = { Happiness = 30, Money = -10000000, Health = 5 }, resultText = "Saving lives even after you're gone. Meaningful legacy.", setFlag = "legacy_builder" },
			{ text = "👨‍👩‍👧 Family wealth", effects = { Happiness = 20, Smarts = 3 }, resultText = "Trust funds, family office. Generations will be secure.", setFlag = "dynasty_builder" },
			{ text = "🌍 Environmental cause", effects = { Happiness = 25, Money = -3000000 }, resultText = "Fighting climate change. The planet needs help.", setFlags = {"legacy_builder", "environmentalist"} },
		},
	},
	
	{
		id = "biz_retirement",
		minAge = 50, maxAge = 75,
		weight = 20, oneTime = true,
		emoji = "🏖️", title = "Time to Retire?",
		category = "work",
		requiresFlag = "ceo",
		text = "You've achieved everything. Is it time to step back?",
		choices = {
			{ text = "🏖️ Golden retirement", effects = { Happiness = 25, Health = 10 }, resultText = "Sold the company. Beaches, golf, grandkids. You earned it.", clearFlag = "ceo", setFlag = "retired_ceo" },
			{ text = "💼 Never stop", effects = { Happiness = 10, Health = -5 }, resultText = "Retire? What would you even do? Keep building." },
			{ text = "📚 Write memoirs", effects = { Happiness = 20, Money = 500000, Smarts = 5 }, resultText = "Your story needs to be told. Bestseller incoming.", setFlags = {"retired_ceo", "author"} },
			{ text = "🎓 Teach next generation", effects = { Happiness = 22, Money = -100000 }, resultText = "Guest lecturer, mentor, advisor. Sharing everything you learned.", setFlags = {"retired_ceo", "mentor"} },
		},
	},
}

return module
