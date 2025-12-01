-- career_business.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- BUSINESS CAREER EVENTS - Entrepreneur, Finance, Real Estate
-- ═══════════════════════════════════════════════════════════════════════════════

local events = {}

-- ═══════════════════════════════════════════════════════════════
-- ENTREPRENEUR EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "business_idea_spark",
	emoji = "💡",
	title = "The Business Idea",
	category = "business",
	tags = {"career", "entrepreneur", "origin"},
	
	weight = 12,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	chainId = "entrepreneur_origin",
	chainStep = 1,
	
	conditions = {
		minAge = 14,
		maxAge = 40,
		blockedFlags = {"career_entrepreneur_started"},
		minStats = {Smarts = 35},
	},
	
	getDynamicData = function(state)
		local ideas = {"an app that solves a common problem", "a product you wish existed", "a service your neighborhood needs", "an improvement to something that already exists"}
		return {
			idea = ideas[math.random(#ideas)]
		}
	end,
	
	text = "You have an idea for %idea%. You can't stop thinking about it. Maybe it could actually work...",
	
	choices = {
		{
			id = "start_planning",
			text = "Let's make it happen!",
			resultText = "You start researching, planning, and sketching out how to make it real.",
			effects = {Smarts = 2, Happiness = 4},
			flags = {set = {"career_entrepreneur_started", "business_dreamer"}},
			startCareer = "entrepreneur",
			careerXP = 15,
		},
		{
			id = "side_project",
			text = "Work on it as a side project.",
			resultText = "You tinker with the idea in your spare time.",
			effects = {Happiness = 2},
			flags = {set = {"has_business_idea"}},
		},
		{
			id = "forget_it",
			text = "It's probably too hard. Forget it.",
			resultText = "You let the idea fade. Someone else will probably do it.",
			effects = {Happiness = -1},
			flags = {set = {}},
		},
	},
})

table.insert(events, {
	id = "business_first_sale",
	emoji = "💰",
	title = "First Sale!",
	category = "business",
	tags = {"career", "entrepreneur", "side_business"},
	
	weight = 15,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	chainId = "entrepreneur_origin",
	chainStep = 2,
	
	conditions = {
		minAge = 15,
		maxAge = 50,
		requiredCareerId = "entrepreneur",
		requiredCareerMinTier = 1,
	},
	
	getDynamicData = function(state)
		return {
			amount = math.random(20, 500)
		}
	end,
	
	text = "Someone actually paid you $%amount% for your product/service! A real customer. This is validation!",
	
	choices = {
		{
			id = "reinvest",
			text = "Reinvest every penny into growth!",
			resultText = "You put all profits back into the business. This is how empires are built.",
			effects = {Smarts = 2, Happiness = 5},
			flags = {set = {"first_sale", "reinvestor"}},
			careerXP = 25,
		},
		{
			id = "pocket_it",
			text = "Finally, some money for my effort!",
			resultText = "You treat yourself. You earned it.",
			effects = {Money = 200, Happiness = 4},
			flags = {set = {"first_sale"}},
			careerXP = 15,
		},
	},
})

table.insert(events, {
	id = "business_investor_meeting",
	emoji = "🤝",
	title = "Investor Interest",
	category = "business",
	tags = {"career", "entrepreneur", "startup_life"},
	
	weight = 8,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 18,
		maxAge = 55,
		requiredCareerId = "entrepreneur",
		requiredCareerMinTier = 2,
		requiredAllFlags = {"first_sale"},
	},
	
	getDynamicData = function(state)
		local firms = {"Blue Sky Capital", "Venture Partners", "Growth Fund", "Angel Group"}
		return {
			firm = firms[math.random(#firms)],
			amount = math.random(50, 500) * 1000
		}
	end,
	
	text = "%firm% wants to invest $%amount% in your business for equity. This could accelerate everything - or you could lose control.",
	
	choices = {
		{
			id = "take_investment",
			text = "Take the money and scale!",
			resultText = "You sign the deal. Now you have real resources - and real pressure to perform.",
			effects = {Money = 50000, Happiness = 4},
			flags = {set = {"funded_startup", "has_investors"}},
			promoteCareer = true,
			careerXP = 40,
		},
		{
			id = "negotiate_terms",
			text = "Negotiate for better terms.",
			resultText = "After tough negotiations, you get a better deal. They respect your spine.",
			effects = {Money = 60000, Happiness = 3},
			flags = {set = {"funded_startup", "has_investors", "good_negotiator"}},
			promoteCareer = true,
			careerXP = 45,
		},
		{
			id = "bootstrap",
			text = "Stay bootstrapped. I want full control.",
			resultText = "You turn down the money. Slower growth, but it's 100% yours.",
			effects = {Happiness = 2, Karma = 2},
			flags = {set = {"bootstrapped"}},
			careerXP = 20,
		},
	},
})

table.insert(events, {
	id = "business_pivot",
	emoji = "🔄",
	title = "Time to Pivot?",
	category = "business",
	tags = {"career", "entrepreneur", "startup_life"},
	
	weight = 10,
	cooldownYears = 3,
	oneTime = false,
	
	conditions = {
		minAge = 18,
		maxAge = 60,
		requiredCareerId = "entrepreneur",
		requiredCareerMinTier = 2,
	},
	
	text = "The original vision isn't working as well as hoped. Your customers want something slightly different. Do you pivot?",
	
	choices = {
		{
			id = "pivot",
			text = "Pivot and follow the customers.",
			resultText = "You adapt. It's not the original dream, but it's what people will pay for.",
			effects = {Smarts = 3, Happiness = 1},
			flags = {set = {"pivoted_business"}},
			careerXP = 25,
		},
		{
			id = "stay_course",
			text = "Stay the course. The vision is right.",
			resultText = "You double down on your original plan. Time will tell if you're right.",
			effects = {Happiness = -1},
			flags = {set = {"vision_focused"}},
			careerXP = 15,
		},
	},
})

table.insert(events, {
	id = "business_acquisition_offer",
	emoji = "📝",
	title = "Acquisition Offer",
	category = "business",
	tags = {"career", "entrepreneur", "scaling_business", "milestone"},
	
	weight = 5,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 22,
		maxAge = 65,
		requiredCareerId = "entrepreneur",
		requiredCareerMinTier = 4,
	},
	
	getDynamicData = function(state)
		local buyers = {"MegaCorp Industries", "Global Holdings", "Tech Giants Inc", "Consolidated Brands"}
		return {
			buyer = buyers[math.random(#buyers)],
			offer = math.random(2, 20) * 1000000
		}
	end,
	
	text = "%buyer% wants to acquire your company for $%offer%. This is life-changing money. But is it the right choice?",
	
	choices = {
		{
			id = "sell_company",
			text = "Sell and take the money.",
			resultText = "You sign the papers. You're wealthy beyond imagination. But it's no longer your baby.",
			effects = {Money = 5000000, Happiness = 7},
			flags = {set = {"sold_company", "wealthy"}},
			quitCareer = true,
		},
		{
			id = "keep_building",
			text = "Reject the offer. This is just the beginning.",
			resultText = "You bet on yourself. The company is worth more to you than any offer.",
			effects = {Happiness = 3, Karma = 2},
			flags = {set = {"rejected_acquisition"}},
			careerXP = 30,
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- FINANCE EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "finance_internship",
	emoji = "📊",
	title = "Finance Internship",
	category = "business",
	tags = {"career", "finance", "origin"},
	
	weight = 12,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	chainId = "finance_origin",
	chainStep = 1,
	
	conditions = {
		minAge = 19,
		maxAge = 26,
		blockedFlags = {"career_finance_started"},
		requiredEducation = "high_school",
		minStats = {Smarts = 50},
	},
	
	getDynamicData = function(state)
		local firms = {"Goldman & Sterling", "Morgan Hill Partners", "Capital First Group", "WealthMax Advisory"}
		return {
			firm = firms[math.random(#firms)]
		}
	end,
	
	text = "%firm% offers you a summer internship. The hours will be brutal, but the pay and networking are incredible.",
	
	choices = {
		{
			id = "accept_internship",
			text = "Accept and grind hard!",
			resultText = "You work 80-hour weeks. It's exhausting but you learn more than you ever thought possible.",
			effects = {Smarts = 5, Money = 15000, Happiness = -2},
			flags = {set = {"career_finance_started", "finance_intern"}},
			startCareer = "finance",
			careerXP = 30,
		},
		{
			id = "decline",
			text = "The hours are too much. Decline.",
			resultText = "You value your work-life balance. Finance probably isn't for you anyway.",
			effects = {Happiness = 1},
			flags = {set = {"declined_finance"}},
		},
	},
})

table.insert(events, {
	id = "finance_big_deal",
	emoji = "💵",
	title = "Close the Deal",
	category = "business",
	tags = {"career", "finance", "investment_banking"},
	
	weight = 10,
	cooldownYears = 2,
	oneTime = false,
	
	conditions = {
		minAge = 23,
		maxAge = 55,
		requiredCareerId = "finance",
		requiredCareerMinTier = 2,
	},
	
	getDynamicData = function(state)
		local deals = {"a major merger", "an IPO", "a leveraged buyout", "a restructuring"}
		return {
			deal = deals[math.random(#deals)],
			bonus = math.random(10, 100) * 1000
		}
	end,
	
	text = "You've been working on %deal% for months. It's about to close. If it goes through, the bonus could be $%bonus%.",
	
	choices = {
		{
			id = "all_in",
			text = "Go all in to close it.",
			resultText = "You work through the night. The deal closes. You're exhausted but richer.",
			effects = {Money = 50000, Health = -3, Smarts = 2},
			flags = {set = {"big_deal_closed"}},
			careerXP = 30,
			careerReputation = 15,
		},
		{
			id = "delegate",
			text = "Delegate and manage from above.",
			resultText = "You trust your team. The deal closes, and you keep your sanity.",
			effects = {Money = 40000, Happiness = 2},
			flags = {set = {"deal_delegator"}},
			careerXP = 20,
		},
	},
})

table.insert(events, {
	id = "finance_ethical_dilemma",
	emoji = "⚖️",
	title = "Gray Area",
	category = "business",
	tags = {"career", "finance", "morality"},
	
	weight = 7,
	cooldownYears = 4,
	oneTime = false,
	
	conditions = {
		minAge = 25,
		maxAge = 60,
		requiredCareerId = "finance",
		requiredCareerMinTier = 2,
	},
	
	text = "Your boss wants you to recommend a product to clients that has high fees and poor returns - but it pays you great commissions.",
	
	choices = {
		{
			id = "follow_orders",
			text = "Do what the boss says.",
			resultText = "You push the product. The commissions are nice, but you feel dirty.",
			effects = {Money = 10000, Karma = -5, Happiness = -2},
			flags = {set = {"finance_compromised"}},
			careerXP = 10,
		},
		{
			id = "push_back",
			text = "Push back and recommend better options.",
			resultText = "Your boss is annoyed, but your clients appreciate your honesty.",
			effects = {Karma = 5, Happiness = 2},
			flags = {set = {"finance_ethical"}},
			careerReputation = 5,
		},
		{
			id = "quit",
			text = "This firm has bad values. I quit.",
			resultText = "You leave for a firm with better ethics. Not everyone agrees with that choice.",
			effects = {Karma = 6, Happiness = 3},
			quitCareer = true,
			flags = {set = {"quit_unethical_firm"}},
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- REAL ESTATE EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "real_estate_license",
	emoji = "🏠",
	title = "Get Your License",
	category = "business",
	tags = {"career", "real_estate", "origin"},
	
	weight = 10,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	chainId = "real_estate_origin",
	chainStep = 1,
	
	conditions = {
		minAge = 18,
		maxAge = 55,
		blockedFlags = {"career_real_estate_started"},
		requiredEducation = "high_school",
	},
	
	text = "You're considering getting a real estate license. The market can be lucrative, but it's also competitive and unpredictable.",
	
	choices = {
		{
			id = "get_license",
			text = "Study, take the exam, get licensed!",
			resultText = "After weeks of studying, you pass! You're officially a licensed real estate agent.",
			effects = {Money = -2000, Smarts = 3, Happiness = 4},
			flags = {set = {"career_real_estate_started", "real_estate_licensed"}},
			startCareer = "real_estate",
			careerXP = 20,
		},
		{
			id = "not_now",
			text = "Maybe later.",
			resultText = "You put the idea on hold for now.",
			effects = {},
			flags = {set = {}},
		},
	},
})

table.insert(events, {
	id = "real_estate_first_sale",
	emoji = "🔑",
	title = "First Home Sale",
	category = "business",
	tags = {"career", "real_estate", "real_estate_agent"},
	
	weight = 15,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 18,
		maxAge = 60,
		requiredCareerId = "real_estate",
		requiredCareerMinTier = 1,
	},
	
	getDynamicData = function(state)
		return {
			commission = math.random(5, 15) * 1000
		}
	end,
	
	text = "After weeks of showings and negotiations, you close your first deal! The commission check is $%commission%.",
	
	choices = {
		{
			id = "celebrate_hustle",
			text = "This hustle is worth it!",
			resultText = "You feel the rush of closing deals. Time to find the next one!",
			effects = {Money = 10000, Happiness = 6},
			flags = {set = {"first_home_sold", "real_estate_hooked"}},
			careerXP = 30,
		},
	},
})

table.insert(events, {
	id = "real_estate_property_investment",
	emoji = "🏢",
	title = "Investment Property",
	category = "business",
	tags = {"career", "real_estate", "property_investor"},
	
	weight = 8,
	cooldownYears = 3,
	oneTime = false,
	
	conditions = {
		minAge = 25,
		maxAge = 70,
		requiredCareerId = "real_estate",
		requiredCareerMinTier = 2,
		minStats = {Money = 50000},
	},
	
	getDynamicData = function(state)
		local properties = {"a small rental unit", "a fixer-upper house", "a commercial space", "a multi-family building"}
		return {
			property = properties[math.random(#properties)],
			price = math.random(100, 300) * 1000
		}
	end,
	
	text = "You find %property% for $%price%. It could generate passive income or flip for profit - if you can make the deal work.",
	
	choices = {
		{
			id = "buy_property",
			text = "Make an offer and close the deal.",
			resultText = "You become a property owner. Now the real work begins - managing or renovating.",
			effects = {Money = -100000, Happiness = 3},
			flags = {set = {"property_owner"}},
			promoteCareer = true,
			careerXP = 35,
		},
		{
			id = "pass_this_time",
			text = "The numbers don't work. Pass.",
			resultText = "You walk away from this one. Better opportunities will come.",
			effects = {},
			flags = {set = {}},
		},
	},
})

table.insert(events, {
	id = "real_estate_market_crash",
	emoji = "📉",
	title = "Market Downturn",
	category = "business",
	tags = {"career", "real_estate", "crisis"},
	
	weight = 5,
	cooldownYears = 10,
	oneTime = false,
	
	conditions = {
		minAge = 22,
		maxAge = 75,
		requiredCareerId = "real_estate",
		requiredCareerMinTier = 2,
	},
	
	text = "The real estate market crashes. Property values plummet. Deals dry up. Many agents leave the industry.",
	
	choices = {
		{
			id = "ride_it_out",
			text = "Ride it out and find opportunities.",
			resultText = "You tighten your belt and look for deals others miss. Markets recover eventually.",
			effects = {Money = -20000, Happiness = -4},
			flags = {set = {"survived_crash"}},
			careerXP = 20,
		},
		{
			id = "buy_distressed",
			text = "Buy distressed properties cheap.",
			resultText = "You scoop up properties at rock-bottom prices. Risky, but could pay off huge.",
			effects = {Money = -50000, Happiness = -2},
			flags = {set = {"opportunistic_buyer", "survived_crash"}},
			careerXP = 30,
		},
	},
})

return {events = events}
