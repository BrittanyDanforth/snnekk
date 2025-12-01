-- LifeEvents/wealth.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- WEALTH & MONEY EVENTS
-- BitLife-style: Player picks ACTIONS, game decides OUTCOMES
-- ═══════════════════════════════════════════════════════════════════════════════

-- LOCAL HELPER FUNCTIONS (no external dependencies)
local FIRST_NAMES = {"Alex", "Jordan", "Taylor", "Casey", "Morgan", "Riley", "Jamie", "Cameron", "Quinn", "Avery", "Parker", "Skyler", "Dakota", "Reese", "Finley", "Sage", "Rowan", "Charlie", "Emerson", "Hayden"}

local function randomFirstName()
	return FIRST_NAMES[math.random(#FIRST_NAMES)]
end

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- EARLY MONEY LESSONS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "wealth_allowance",
		minAge = 8, maxAge = 14,
		weight = 25, oneTime = true,
		emoji = "💰", title = "Getting Allowance!",
		category = "family",
		getDynamicData = function()
			local amounts = {5, 10, 15, 20}
			return { amount = amounts[math.random(#amounts)] }
		end,
		text = "Parents giving you $%amount%/week allowance! What do you do with it?",
		choices = {
			{ text = "🐷 Save it all", effects = { Smarts = 8, Happiness = 5 }, resultText = "Piggy bank growing! Learning to save! Good habits early!", setFlag = "saver" },
			{ text = "🍬 Spend immediately", effects = { Happiness = 10 }, resultText = "Candy! Toys! Games! Living in the moment!" },
			{ text = "💰 Save half, spend half", effects = { Smarts = 5, Happiness = 8 }, resultText = "Balance! Enjoying AND saving! Smart approach!", setFlag = "balanced_spender" },
			{ text = "📈 Ask to invest it", effects = { Smarts = 12, Happiness = 5, Money = 20 }, resultText = "Parents opened a savings account! Interest! Compound growth!", setFlags = {"investor_mindset", "saver"} },
		},
	},
	
	{
		id = "wealth_first_paycheck",
		minAge = 15, maxAge = 18,
		weight = 20, oneTime = true,
		emoji = "💵", title = "First Paycheck!",
		category = "work",
		-- CRITICAL: Must have a job to get a paycheck!
		requiresFlag = "has_job",
		getDynamicData = function()
			local amounts = {300, 400, 500, 600}
			return { amount = amounts[math.random(#amounts)] }
		end,
		text = "First real paycheck: $%amount%! Earned with your own labor! What do you do?",
		choices = {
			{ text = "🏦 Open savings account", effects = { Smarts = 10, Money = 200 }, resultText = "Bank account opened! Building financial foundation!", setFlag = "has_savings" },
			{ text = "🛍️ Shopping spree!", effects = { Happiness = 15, Money = -200 }, resultText = "New clothes! Gadgets! Feels good to spend YOUR money!" },
			{ text = "📱 Buy something wanted forever", effects = { Happiness = 12, Money = -300 }, resultText = "Finally got that thing! Earned it yourself! So satisfying!" },
			{ text = "👨‍👩‍👧 Give some to family", effects = { Happiness = 10, Smarts = 3 }, resultText = "Helped out at home. Growing up! Responsibility!", setFlag = "generous" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- INVESTING
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "wealth_stock_market",
		minAge = 18, maxAge = 70,
		weight = 20, cooldown = 3,
		emoji = "📈", title = "Stock Market Opportunity!",
		category = "social",
		showResultPopup = true,
		getDynamicData = function()
			local tips = {"a friend's hot tip", "your own research", "a viral social media post", "a financial advisor"}
			return { source = tips[math.random(#tips)] }
		end,
		text = "Based on %source%, there's a stock investment opportunity! How much do you invest?",
		choices = {
			{ 
				text = "💰 Invest heavily ($5000)", 
				requires = { Money = 5000 },
				effects = { Money = -5000 }, -- Risk the money
				chanceSuccess = 0.55,
				effectsOnSuccess = { Money = 12000, Happiness = 18 },
				resultTextSuccess = "IT WENT UP! Made $7000 profit! Feeling like a genius! 📈",
				effectsOnFail = { Money = -3000, Happiness = -12 },
				resultTextFail = "Stock tanked. Lost $8000 total. Ouch. That's the market. 📉",
				setFlag = "stock_investor" 
			},
			{ 
				text = "🤏 Small investment ($1000)", 
				requires = { Money = 1000 },
				effects = { Money = -1000 },
				chanceSuccess = 0.6,
				effectsOnSuccess = { Money = 2500, Happiness = 10 },
				resultTextSuccess = "Nice modest gains! Made $1500 profit! Playing it safe worked!",
				effectsOnFail = { Money = -500, Happiness = -5 },
				resultTextFail = "Lost $1500 total. At least you didn't bet big.",
				setFlag = "cautious_investor" 
			},
			{ 
				text = "🙅 Stay out of market", 
				effects = { Happiness = 3, Smarts = 3 }, 
				resultText = "Didn't invest. Either missed gains or dodged losses. Sleep well!" 
			},
		},
	},
	
	{
		id = "wealth_crypto",
		minAge = 18, maxAge = 60,
		weight = 18, cooldown = 4,
		emoji = "🪙", title = "Crypto Investment?",
		category = "social",
		showResultPopup = true,
		getDynamicData = function()
			local coins = {"Bitcoin", "Ethereum", "a random altcoin", "a meme coin"}
			return { coin = coins[math.random(#coins)] }
		end,
		text = "Everyone's talking about %coin%! FOMO is real! How much do you put in?",
		choices = {
			{ 
				text = "🚀 YOLO big ($10,000)!", 
				requires = { Money = 10000 },
				effects = { Money = -10000 },
				chanceSuccess = 0.4, -- Crypto is risky!
				effectsOnSuccess = { Money = 50000, Happiness = 30 },
				resultTextSuccess = "TO THE MOON! 5x gains! You're a crypto genius! Diamond hands! 💎🙌",
				effectsOnFail = { Money = -8000, Happiness = -20 },
				resultTextFail = "Crashed 80% right after you bought. Classic. REKT. Paper hands? Should've held? Who knows.",
				setFlags = {"crypto_investor"} 
			},
			{ 
				text = "🤏 Small fun money ($500)", 
				requires = { Money = 500 },
				effects = { Money = -500 },
				chanceSuccess = 0.5,
				effectsOnSuccess = { Money = 2000, Happiness = 12 },
				resultTextSuccess = "Made 4x! Not life-changing but fun! Smart gambling!",
				effectsOnFail = { Money = -400, Happiness = -5 },
				resultTextFail = "Lost most of it. At least it was just fun money.",
				setFlag = "crypto_dabbler" 
			},
			{ 
				text = "🙅 Too risky for me", 
				effects = { Happiness = 5, Smarts = 5 }, 
				resultText = "Stayed out of the madness. Slept well at night. Maybe you missed gains. Maybe you dodged a bullet.", 
				setFlag = "crypto_skeptic" 
			},
		},
	},
	
	{
		id = "wealth_real_estate",
		minAge = 25, maxAge = 65,
		weight = 15, cooldown = 5,
		emoji = "🏠", title = "Real Estate Opportunity!",
		category = "social",
		showResultPopup = true,
		getDynamicData = function()
			local properties = {"a fixer-upper", "rental property", "vacant land", "a condo"}
			local prices = {150000, 200000, 250000, 300000}
			return { property = properties[math.random(#properties)], price = prices[math.random(#prices)] }
		end,
		text = "Opportunity to buy %property% for $%price%! Real estate builds wealth! Do you invest?",
		choices = {
			{ 
				text = "🏠 Buy it!", 
				requires = { Money = 30000 },
				effects = { Money = -30000 }, -- Down payment
				chanceSuccess = 0.65,
				effectsOnSuccess = { Money = 80000, Happiness = 18 },
				resultTextSuccess = "Great investment! Property appreciated! Made $50k profit! Building wealth!",
				effectsOnFail = { Money = -40000, Happiness = -15 },
				resultTextFail = "Market crashed right after you bought. Property value dropped. Lost money. Bad timing!",
				setFlags = {"property_owner", "real_estate_investor"} 
			},
			{ 
				text = "🔨 Buy cheap and flip", 
				requires = { Money = 20000 },
				effects = { Money = -20000, Health = -5 },
				chanceSuccess = 0.55,
				effectsOnSuccess = { Money = 60000, Happiness = 15 },
				resultTextSuccess = "Fixed it up and sold for profit! Hard work paid off!",
				effectsOnFail = { Money = -10000, Happiness = -10 },
				resultTextFail = "Renovation costs exploded. Sold at a loss. House flipping is risky!",
				setFlag = "house_flipper" 
			},
			{ 
				text = "📉 Wait for better timing", 
				effects = { Smarts = 3, Happiness = 2 }, 
				resultText = "Staying out for now. Patience might pay off later." 
			},
			{ 
				text = "🙅 Can't afford it", 
				effects = { Happiness = -3 }, 
				resultText = "Not in a position to buy. Maybe next time." 
			},
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- WINDFALLS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "wealth_inheritance",
		minAge = 25, maxAge = 70,
		weight = 10, oneTime = true,
		emoji = "📜", title = "Inheritance!",
		category = "family",
		showResultPopup = true,
		getDynamicData = function()
			local amounts = {10000, 50000, 100000, 500000}
			local sources = {"grandparent", "distant relative", "family friend", "great aunt"}
			return { amount = amounts[math.random(#amounts)], source = sources[math.random(#sources)] }
		end,
		text = "Your %source% passed away and left you $%amount%! Unexpected inheritance! What do you do?",
		choices = {
			{ 
				text = "🏦 Save/invest it all", 
				effects = { Smarts = 8 }, 
				-- Dynamic effect: get full inheritance amount
				effectsDynamic = function(data) return { Money = data.amount or 50000 } end,
				resultText = "Secured the future! Honoring their memory wisely!", 
				setFlags = {"inherited_wealth", "responsible"} 
			},
			{ 
				text = "🛍️ Treat yourself", 
				effects = { Happiness = 15 }, 
				-- Dynamic effect: get 40% of inheritance (spent rest)
				effectsDynamic = function(data) return { Money = math.floor((data.amount or 50000) * 0.4) } end,
				resultText = "Bought nice things! Life's short! They'd want you happy!", 
				setFlag = "inherited_wealth" 
			},
			{ 
				text = "🏠 Down payment on house", 
				effects = { Happiness = 20 }, 
				-- Dynamic effect: money goes to house (no cash gain but get homeowner flag)
				effectsDynamic = function(data) return { Money = 0 } end,
				resultText = "Finally a homeowner! Their gift made it possible!", 
				setFlags = {"inherited_wealth", "homeowner"} 
			},
			{ 
				text = "❤️ Give some to charity", 
				effects = { Happiness = 18, Smarts = 3 }, 
				-- Dynamic effect: keep 60% of inheritance
				effectsDynamic = function(data) return { Money = math.floor((data.amount or 50000) * 0.6) } end,
				resultText = "Donated in their name. Kept some. Perfect balance.", 
				setFlags = {"inherited_wealth", "charitable"} 
			},
		},
	},
	
	{
		id = "wealth_lottery_win",
		minAge = 18, maxAge = 80,
		weight = 3, oneTime = true,
		emoji = "🎰", title = "LOTTERY WINNER!",
		category = "social",
		showResultPopup = true,
		getDynamicData = function()
			local amounts = {100000, 500000, 1000000, 5000000}
			return { amount = amounts[math.random(#amounts)] }
		end,
		text = "YOU WON THE LOTTERY! $%amount%! (After taxes) Life-changing money! What do you do?!",
		choices = {
			{ 
				text = "🏦 Hire financial advisor", 
				effects = { Happiness = 30, Smarts = 10 }, 
				-- Dynamic: keep full amount with smart management
				effectsDynamic = function(data) return { Money = data.amount or 500000 } end,
				resultText = "Smart! Protected the money! Set for life!", 
				setFlags = {"lottery_winner", "wealthy", "smart_winner"} 
			},
			{ 
				text = "🎉 Tell everyone!", 
				effects = { Happiness = 20 }, 
				-- Dynamic: lose 60% to moochers and bad decisions
				effectsDynamic = function(data) return { Money = math.floor((data.amount or 500000) * 0.4) } end,
				resultText = "Friends and family asking for loans... money disappearing fast...", 
				setFlags = {"lottery_winner", "money_problems"} 
			},
			{ 
				text = "🙊 Keep it secret", 
				effects = { Happiness = 35, Smarts = 8 }, 
				-- Dynamic: keep 80% (some goes to setup/security)
				effectsDynamic = function(data) return { Money = math.floor((data.amount or 500000) * 0.8) } end,
				resultText = "Quiet wealth. No one knows. Peace of mind.", 
				setFlags = {"lottery_winner", "wealthy", "secret_millionaire"} 
			},
			{ 
				text = "💸 Blow it all", 
				effects = { Happiness = 25 }, 
				-- Dynamic: it's all gone!
				effectsDynamic = function(data) return { Money = 0 } end,
				resultText = "Cars! Parties! Trips! And... it's gone. Classic lottery winner.", 
				setFlags = {"lottery_winner", "broke_again"} 
			},
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- FINANCIAL STRUGGLES
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "wealth_debt_crisis",
		minAge = 22, maxAge = 60,
		weight = 20, cooldown = 5,
		emoji = "💳", title = "Debt Problem!",
		category = "family",
		getDynamicData = function()
			local amounts = {5000, 15000, 30000, 50000}
			return { amount = amounts[math.random(#amounts)] }
		end,
		text = "Credit card debt hit $%amount%! Interest eating you alive! What do you do?",
		choices = {
			{ text = "📋 Create strict budget", effects = { Happiness = 8, Money = 5000, Smarts = 8 }, resultText = "Rice and beans! No fun! But debt shrinking! Discipline!", setFlags = {"debt_fighter", "budgeter"} },
			{ text = "🏦 Balance transfer", effects = { Happiness = 5, Money = 3000, Smarts = 5 }, resultText = "0% APR for 18 months! Breathing room! Pay it down!", setFlag = "debt_strategy" },
			{ text = "😔 Minimum payments only", effects = { Happiness = -10, Money = -5000 }, resultText = "Barely keeping up. Debt growing. This is a trap." },
			{ text = "💼 Get second job", effects = { Happiness = -5, Money = 10000, Health = -8 }, resultText = "Working ALL the time. But debt going down FAST!", setFlags = {"debt_fighter", "workaholic"} },
		},
	},
	
	{
		id = "wealth_bankruptcy",
		minAge = 25, maxAge = 65,
		weight = 8, oneTime = true,
		emoji = "📉", title = "Bankruptcy Decision",
		category = "family",
		requiresFlag = "debt_fighter",
		text = "Debt is overwhelming. Bankruptcy might be the only way out. What do you do?",
		choices = {
			{ text = "⚖️ File Chapter 7", effects = { Happiness = 10, Money = 0 }, resultText = "Debts discharged! Fresh start! But credit destroyed for 7 years.", setFlag = "bankruptcy_survivor", clearFlag = "debt_fighter" },
			{ text = "📋 Chapter 13 plan", effects = { Happiness = 5, Money = -5000 }, resultText = "Structured repayment plan. Keeping some assets. Crawling out.", setFlag = "bankruptcy_survivor" },
			{ text = "💪 Refuse, keep fighting", effects = { Happiness = -10, Health = -10, Money = -10000 }, resultText = "Pride over pragmatism. The struggle continues. Exhausting." },
			{ text = "🤝 Negotiate with creditors", effects = { Happiness = 8, Money = 5000 }, resultText = "They agreed to reduced payments! Avoiding bankruptcy!", clearFlag = "debt_fighter", setFlag = "debt_negotiator" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- WEALTH MILESTONES
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "wealth_first_million",
		minAge = 25, maxAge = 80,
		weight = 50, oneTime = true, milestone = false,  -- NOT a milestone - requires money condition
		emoji = "💰", title = "MILLIONAIRE!",
		category = "social",
		-- MUST actually have $1M+ to trigger this event!
		minMoney = 1000000,  -- Use direct money check instead of function
		blockIfFlag = "millionaire",  -- Don't fire twice
		text = "Your net worth just crossed ONE MILLION DOLLARS! How do you feel?",
		choices = {
			{ text = "🎉 Celebrate!", effects = { Happiness = 35, Money = -5000 }, resultText = "Champagne! Nice dinner! You made it! MILLIONAIRE!", setFlags = {"millionaire", "celebrating"} },
			{ text = "🎯 Eyes on next goal", effects = { Happiness = 20, Smarts = 5 }, resultText = "One down, ten million to go! Keep building!", setFlags = {"millionaire", "ambitious"} },
			{ text = "🙏 Stay humble", effects = { Happiness = 25, Smarts = 3 }, resultText = "Grateful but not arrogant. Money doesn't change who you are.", setFlags = {"millionaire", "humble"} },
			{ text = "❤️ Give back", effects = { Happiness = 30, Money = -50000 }, resultText = "Donated significantly! Helping others with your success!", setFlags = {"millionaire", "philanthropist"} },
		},
	},
	
	{
		id = "wealth_retirement_ready",
		minAge = 55, maxAge = 70,
		weight = 15, oneTime = true,
		emoji = "🏖️", title = "Retirement Numbers!",
		category = "family",
		text = "Financial advisor says you can retire comfortably! All those years of saving! Do you pull the trigger?",
		choices = {
			{ text = "✅ Retire now!", effects = { Happiness = 40, Health = 10 }, resultText = "RETIRED! No more alarm clocks! Living the dream!", setFlags = {"retired", "financially_free"} },
			{ text = "📈 One more year", effects = { Happiness = 20, Money = 50000 }, resultText = "One more year of income! Padding the nest egg!", setFlag = "working_retiree" },
			{ text = "🔄 Semi-retirement", effects = { Happiness = 30, Money = 30000, Health = 5 }, resultText = "Part-time! Best of both worlds! Still engaged!", setFlags = {"semi_retired", "financially_free"} },
			{ text = "😰 Not confident enough", effects = { Happiness = 10, Smarts = 3 }, resultText = "What if the money runs out? Keeping working for security." },
		},
	},
}

return module
