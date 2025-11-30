-- LifeEvents/wealth.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- WEALTH & MONEY EVENTS
-- Investments, Windfalls, Financial Crises, Lottery, Inheritance - Money life
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent.init)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- CHILDHOOD MONEY LESSONS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "wealth_allowance",
		minAge = 6, maxAge = 14,
		weight = 30, oneTime = true,
		emoji = "💰", title = "Allowance!",
		category = "family",
		getDynamicData = function()
			local amounts = {5, 10, 15, 20}
			return { amount = amounts[math.random(#amounts)] }
		end,
		text = "Your parents start giving you $%amount% weekly allowance!",
		choices = {
			{ text = "🐷 Save it all!", effects = { Happiness = 8, Money = 500, Smarts = 5 }, resultText = "Piggy bank getting heavy! Learning to save early!", setFlag = "saver" },
			{ text = "🍬 Spend it all!", effects = { Happiness = 15, Money = 0 }, resultText = "Candy, toys, games! Money gone instantly! But so fun!" },
			{ text = "💵 Half and half", effects = { Happiness = 10, Money = 200, Smarts = 3 }, resultText = "Balance! Some saving, some spending. Smart approach!", setFlag = "balanced_finances" },
			{ text = "📈 Invested in stocks", effects = { Happiness = 5, Money = 1000, Smarts = 8 }, resultText = "Parent helped you buy fractional shares! Learning investing young!", setFlags = {"saver", "young_investor"} },
		},
	},
	
	{
		id = "wealth_birthday_money",
		minAge = 8, maxAge = 18,
		weight = 25, cooldown = 3,
		emoji = "🎂", title = "Birthday Money!",
		category = "family",
		getDynamicData = function()
			local amounts = {50, 100, 200, 500}
			return { amount = amounts[math.random(#amounts)] }
		end,
		text = "Grandparents gave you $%amount% for your birthday!",
		choices = {
			{ text = "🎮 Video games!", effects = { Happiness = 15, Money = 0 }, resultText = "Got exactly what you wanted! Thanks grandma!" },
			{ text = "🏦 Bank it!", effects = { Happiness = 5, Money = 500, Smarts = 3 }, resultText = "Into savings! Compound interest here we come!", setFlag = "saver" },
			{ text = "👕 New clothes", effects = { Happiness = 12, Money = 0, Looks = 3 }, resultText = "Looking fresh! Fashion upgrade!" },
			{ text = "📚 Bought stocks", effects = { Happiness = 8, Money = 800, Smarts = 8 }, resultText = "Grandma would be proud! Your Disney shares are growing!", setFlag = "young_investor" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- YOUNG ADULT FINANCES
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "wealth_first_paycheck",
		minAge = 16, maxAge = 22,
		weight = 25, oneTime = true,
		emoji = "💵", title = "First Paycheck!",
		category = "work",
		getDynamicData = function()
			local amounts = {200, 400, 600, 800}
			return { amount = amounts[math.random(#amounts)] }
		end,
		text = "Your first REAL paycheck! $%amount% for YOUR work!",
		choices = {
			{ text = "🤑 Feeling rich!", effects = { Happiness = 20, Money = 600 }, resultText = "YOUR money! Earned by YOU! The independence feels amazing!", setFlag = "first_income" },
			{ text = "😔 Taxes hurt", effects = { Happiness = 8, Money = 400, Smarts = 5 }, resultText = "Gross vs net is painful to learn. Where did 30% go?!", setFlag = "first_income" },
			{ text = "🏦 Started 401k", effects = { Happiness = 10, Money = 300, Smarts = 8 }, resultText = "Employer match! Free money! Retirement at 16!", setFlags = {"first_income", "retirement_saver"} },
			{ text = "💸 Gone in a day", effects = { Happiness = 15, Money = 0 }, resultText = "Spent it all immediately! Worth it! (Probably not)" },
		},
	},
	
	{
		id = "wealth_credit_card",
		minAge = 18, maxAge = 30,
		weight = 25, oneTime = true,
		emoji = "💳", title = "First Credit Card!",
		category = "work",
		getDynamicData = function()
			local limits = {500, 1000, 2500, 5000}
			return { limit = limits[math.random(#limits)] }
		end,
		text = "Approved for a credit card! $%limit% limit! Power and danger!",
		choices = {
			{ text = "📈 Build credit wisely", effects = { Happiness = 10, Money = 0, Smarts = 8 }, resultText = "Small purchases, pay in full. Credit score climbing!", setFlag = "good_credit" },
			{ text = "💸 Maxed it immediately", effects = { Happiness = 15, Money = -2000 }, resultText = "Bought everything! Now paying 24% interest! Oops!", setFlag = "credit_card_debt" },
			{ text = "🔒 Emergency only", effects = { Happiness = 5, Smarts = 5 }, resultText = "Keeping it for emergencies. Responsible.", setFlag = "good_credit" },
			{ text = "✂️ Cut it up", effects = { Happiness = 8, Smarts = 3 }, resultText = "Too tempting. Cash only lifestyle. Avoiding debt!", setFlag = "debt_free" },
		},
	},
	
	{
		id = "wealth_student_loans",
		minAge = 18, maxAge = 25,
		weight = 25, oneTime = true,
		emoji = "📚", title = "Student Loan Reality",
		category = "school",
		getDynamicData = function()
			local amounts = {20000, 50000, 100000, 150000}
			return { amount = amounts[math.random(#amounts)] }
		end,
		text = "You owe $%amount% in student loans. Payments starting soon.",
		choices = {
			{ text = "😰 Drowning in debt", effects = { Happiness = -15, Money = -50000 }, resultText = "Monthly payments crushing you. Decades to pay off. The American dream?", setFlag = "student_debt" },
			{ text = "💪 Aggressive payoff", effects = { Happiness = 5, Money = -30000, Smarts = 5 }, resultText = "Living frugally to destroy this debt. Freedom in 5 years!", setFlag = "paying_debt" },
			{ text = "📋 Income-based plan", effects = { Happiness = -5, Money = -20000, Smarts = 3 }, resultText = "Manageable payments but... paying forever.", setFlag = "student_debt" },
			{ text = "🎉 Forgiveness program", effects = { Happiness = 25, Money = 0 }, resultText = "Public service loan forgiveness! 10 years of service, debt gone!", clearFlag = "student_debt", setFlag = "debt_free" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- INVESTMENTS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "wealth_stock_market",
		minAge = 20, maxAge = 70,
		weight = 25, cooldown = 3,
		emoji = "📈", title = "Stock Market Move!",
		category = "work",
		getDynamicData = function()
			local stocks = {"tech stocks", "index funds", "a meme stock", "blue chips", "a startup IPO"}
			return { investment = stocks[math.random(#stocks)] }
		end,
		text = "You invested in %investment%. The market is moving!",
		choices = {
			{ text = "📈 Doubled your money!", effects = { Happiness = 30, Money = 50000 }, resultText = "STONKS! 100% gain! Timing is everything!", setFlag = "investor" },
			{ text = "📉 Lost half", effects = { Happiness = -20, Money = -25000 }, resultText = "Market crashed right after you bought. Painful lesson.", setFlag = "investor" },
			{ text = "📊 Steady gains", effects = { Happiness = 15, Money = 10000, Smarts = 5 }, resultText = "7% annual return. Boring but effective. Long game.", setFlags = {"investor", "patient_investor"} },
			{ text = "🚀 10x return!", effects = { Happiness = 40, Money = 200000 }, resultText = "MASSIVE gains! Picked the right one! Financial freedom closer!", setFlags = {"investor", "lucky_investor"} },
		},
	},
	
	{
		id = "wealth_crypto",
		minAge = 18, maxAge = 60,
		weight = 20, cooldown = 3,
		emoji = "🪙", title = "Crypto Investment!",
		category = "work",
		getDynamicData = function()
			local cryptos = {"Bitcoin", "Ethereum", "a meme coin", "an NFT project", "a new altcoin"}
			return { crypto = cryptos[math.random(#cryptos)] }
		end,
		text = "You invested in %crypto%. Crypto is volatile!",
		choices = {
			{ text = "🌙 To the moon!", effects = { Happiness = 35, Money = 100000 }, resultText = "MASSIVE gains! Crypto millionaire! Diamond hands paid off!", setFlags = {"crypto_investor", "crypto_winner"} },
			{ text = "💀 Rug pulled", effects = { Happiness = -25, Money = -30000 }, resultText = "Scam coin. Developers disappeared. Money gone. Lesson expensive.", setFlag = "crypto_burned" },
			{ text = "📉 Bear market", effects = { Happiness = -15, Money = -20000 }, resultText = "Down 70%. Still holding. Maybe it'll come back?", setFlag = "crypto_holder" },
			{ text = "💰 Sold at peak", effects = { Happiness = 30, Money = 80000, Smarts = 5 }, resultText = "Timed it perfectly! Cashed out before crash! Rare win!", setFlag = "crypto_winner" },
		},
	},
	
	{
		id = "wealth_real_estate",
		minAge = 25, maxAge = 65,
		weight = 20, cooldown = 5,
		emoji = "🏠", title = "Real Estate Investment!",
		category = "work",
		getDynamicData = function()
			local properties = {"rental property", "a duplex", "commercial building", "vacation rental", "fixer-upper"}
			return { property = properties[math.random(#properties)] }
		end,
		text = "Opportunity to invest in a %property%!",
		choices = {
			{ text = "🏠 Cash flowing!", effects = { Happiness = 25, Money = 30000 }, resultText = "Rental income exceeds mortgage! Passive income achieved!", setFlags = {"landlord", "real_estate_investor"} },
			{ text = "😤 Nightmare tenants", effects = { Happiness = -15, Money = -10000 }, resultText = "Destroyed the place. Eviction process. Being a landlord is hard.", setFlag = "landlord" },
			{ text = "📈 Property doubled!", effects = { Happiness = 30, Money = 200000 }, resultText = "Market went crazy! Your property worth twice what you paid!", setFlags = {"landlord", "property_rich"} },
			{ text = "🏚️ Money pit", effects = { Happiness = -20, Money = -50000 }, resultText = "Repairs never end. Hemorrhaging money. Should have rented.", setFlag = "bad_investment" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- WINDFALLS & LOSSES
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "wealth_inheritance",
		minAge = 25, maxAge = 70,
		weight = 15, oneTime = true,
		emoji = "💝", title = "Inheritance!",
		category = "family",
		getDynamicData = function()
			local amounts = {10000, 50000, 200000, 500000, 1000000}
			local relatives = {"grandparent", "distant relative", "aunt/uncle", "family friend"}
			return { amount = amounts[math.random(#amounts)], relative = relatives[math.random(#relatives)] }
		end,
		text = "Your %relative% passed away and left you $%amount% in their will!",
		choices = {
			{ text = "😢 Bittersweet", effects = { Happiness = 10, Money = 200000 }, resultText = "Miss them. But grateful for the gift. Will honor their memory.", setFlag = "inherited" },
			{ text = "🏠 Buy a house!", effects = { Happiness = 25, Money = 0 }, resultText = "Down payment sorted! First home! Thank you!", setFlags = {"inherited", "homeowner"} },
			{ text = "📈 Invest it all", effects = { Happiness = 15, Money = 300000, Smarts = 5 }, resultText = "Let it grow! Their gift will multiply!", setFlags = {"inherited", "investor"} },
			{ text = "💸 Spent it fast", effects = { Happiness = 20, Money = 0 }, resultText = "Cars, trips, stuff! Fun but... probably should have saved some." },
		},
	},
	
	{
		id = "wealth_lottery",
		minAge = 18, maxAge = 90,
		weight = 3, oneTime = true,
		emoji = "🎰", title = "LOTTERY WINNER!",
		category = "social",
		getDynamicData = function()
			local amounts = {100000, 1000000, 10000000, 100000000}
			return { amount = amounts[math.random(#amounts)] }
		end,
		text = "YOU WON THE LOTTERY! $%amount%!!! THIS CAN'T BE REAL!",
		choices = {
			{ text = "🤑 INSTANT MILLIONAIRE!", effects = { Happiness = 50, Money = 5000000 }, resultText = "Life changed FOREVER! Never working again! DREAMS COME TRUE!", setFlags = {"lottery_winner", "wealthy"} },
			{ text = "😰 Too much attention", effects = { Happiness = 30, Money = 4000000, Health = -5 }, resultText = "Everyone wants a piece. Family drama. Friends weird now.", setFlags = {"lottery_winner", "wealthy", "lottery_curse"} },
			{ text = "🤫 Stay quiet", effects = { Happiness = 40, Money = 4500000, Smarts = 5 }, resultText = "Told nobody. Hired lawyers. Smart winner!", setFlags = {"lottery_winner", "wealthy", "smart_winner"} },
			{ text = "🎉 Quit job dramatically!", effects = { Happiness = 45, Money = 5000000 }, resultText = "Told your boss EXACTLY what you think! FREEDOM!", setFlags = {"lottery_winner", "wealthy"} },
		},
	},
	
	{
		id = "wealth_bankruptcy",
		minAge = 25, maxAge = 70,
		weight = 10, oneTime = true,
		emoji = "📉", title = "Bankruptcy",
		category = "work",
		requiresFlag = "credit_card_debt",
		text = "Debt is overwhelming. Bankruptcy might be the only option.",
		choices = {
			{ text = "💔 Filed Chapter 7", effects = { Happiness = -25, Money = 0, Smarts = 3 }, resultText = "Debts discharged but credit destroyed. Starting over at zero.", clearFlag = "credit_card_debt", setFlag = "bankrupt" },
			{ text = "📋 Chapter 13 plan", effects = { Happiness = -15, Money = -20000 }, resultText = "Payment plan. 5 years of tight budgets. But keeping assets.", setFlag = "restructuring" },
			{ text = "💪 Dug out manually", effects = { Happiness = 10, Money = -30000, Health = -10 }, resultText = "Three jobs. No sleep. Paid it all off. Never again.", clearFlags = {"credit_card_debt"}, setFlags = {"debt_free", "resilient"} },
			{ text = "😔 Devastated", effects = { Happiness = -30, Health = -10 }, resultText = "Financial ruin. Shame. Depression. Need help.", setFlags = {"bankrupt", "depressed"} },
		},
	},
	
	{
		id = "wealth_scammed",
		minAge = 18, maxAge = 90,
		weight = 15, cooldown = 5,
		emoji = "🚨", title = "Scammed!",
		category = "social",
		getDynamicData = function()
			local scams = {"phishing email", "romance scam", "investment fraud", "identity theft", "phone scam"}
			local amounts = {1000, 5000, 20000, 50000}
			return { scam = scams[math.random(#scams)], amount = amounts[math.random(#amounts)] }
		end,
		text = "You fell victim to a %scam%! Lost $%amount%!",
		choices = {
			{ text = "😭 Devastated", effects = { Happiness = -25, Money = -20000 }, resultText = "How could you be so stupid? The shame is crushing.", setFlag = "scam_victim" },
			{ text = "🚔 Reported it", effects = { Happiness = -15, Money = -15000, Smarts = 5 }, resultText = "Filed police report. Probably won't get money back but... tried.", setFlag = "scam_victim" },
			{ text = "💳 Bank helped", effects = { Happiness = -5, Money = -5000 }, resultText = "Fraud protection! Got most of it back! Always use credit cards!" },
			{ text = "😤 Learned lesson", effects = { Happiness = -10, Money = -10000, Smarts = 8 }, resultText = "Expensive education. Never again. More cautious now.", setFlags = {"scam_victim", "cautious"} },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- WEALTH MILESTONES
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "wealth_first_million",
		minAge = 30, maxAge = 80,
		weight = 8, oneTime = true,
		emoji = "💎", title = "MILLIONAIRE!",
		category = "work",
		requiresFlag = "investor",
		text = "Your net worth just crossed $1,000,000! You're a MILLIONAIRE!",
		choices = {
			{ text = "🎉 Life goal achieved!", effects = { Happiness = 40, Smarts = 5 }, resultText = "Seven figures! All those years of saving and investing paid off!", setFlag = "millionaire" },
			{ text = "📊 Just on paper", effects = { Happiness = 25, Smarts = 5 }, resultText = "Net worth high but can't touch most of it. Still working.", setFlag = "millionaire" },
			{ text = "🎯 Want more", effects = { Happiness = 20 }, resultText = "Million isn't enough anymore. When does it end?", setFlags = {"millionaire", "money_hungry"} },
			{ text = "💝 Give some away", effects = { Happiness = 35, Money = -50000 }, resultText = "Gave to charity. Million doesn't change who you are.", setFlags = {"millionaire", "generous"} },
		},
	},
	
	{
		id = "wealth_fire",
		minAge = 35, maxAge = 60,
		weight = 5, oneTime = true,
		emoji = "🔥", title = "FIRE Achieved!",
		category = "work",
		requiresFlag = "millionaire",
		getDynamicData = function()
			local ages = {"35", "40", "45", "50"}
			return { age = ages[math.random(#ages)] }
		end,
		text = "Financial Independence, Retire Early! You hit your FIRE number at %age%!",
		choices = {
			{ text = "🏖️ Never working again!", effects = { Happiness = 45, Health = 10 }, resultText = "RETIRED! Passive income covers everything! Freedom!", setFlags = {"fire_achieved", "early_retirement"} },
			{ text = "🤔 But what now?", effects = { Happiness = 25, Smarts = 5 }, resultText = "Financially free but... purpose? What do you DO all day?", setFlags = {"fire_achieved", "purposeless"} },
			{ text = "💼 Keep working anyway", effects = { Happiness = 30, Money = 100000 }, resultText = "Don't need to work. Choose to. That's the real freedom.", setFlags = {"fire_achieved", "working_optional"} },
			{ text = "🌍 Travel forever", effects = { Happiness = 40, Health = 5 }, resultText = "Sold everything. Living around the world. True freedom!", setFlags = {"fire_achieved", "nomad"} },
		},
	},
	
	{
		id = "wealth_generational",
		minAge = 55, maxAge = 90,
		weight = 10, oneTime = true,
		emoji = "👨‍👩‍👧", title = "Generational Wealth",
		category = "family",
		requiresFlag = "wealthy",
		text = "You've built enough wealth to pass down to future generations. Legacy planning time.",
		choices = {
			{ text = "📋 Trust fund", effects = { Happiness = 30, Smarts = 5 }, resultText = "Set up trusts. Kids and grandkids will be secure. Legacy sealed.", setFlag = "dynasty" },
			{ text = "💝 Giving pledge", effects = { Happiness = 35, Money = -500000 }, resultText = "Giving most of it away. Family gets enough, rest helps the world.", setFlag = "philanthropist" },
			{ text = "🏫 Education fund", effects = { Happiness = 28, Money = -200000 }, resultText = "Scholarships for family AND community. Knowledge is real wealth.", setFlag = "education_legacy" },
			{ text = "😤 Kids earn their own", effects = { Happiness = 20, Smarts = 3 }, resultText = "Giving them values not cash. They'll build their own fortune.", setFlag = "tough_love" },
		},
	},
}

return module
