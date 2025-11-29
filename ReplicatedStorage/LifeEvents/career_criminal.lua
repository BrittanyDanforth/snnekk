-- LifeEvents/career_criminal.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- CRIMINAL CAREER EVENTS
-- Crime, gangs, and underworld path
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- EARLY CRIMINAL TENDENCIES
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_criminal_awakening",
		minAge = 12, maxAge = 18,
		weight = 20, oneTime = true,
		emoji = "😈", title = "Criminal Tendencies",
		category = "crime",
		blockIfFlag = "criminal_tendencies",
		text = "You've been getting into trouble lately. Something about breaking rules feels... good.",
		choices = {
			{ text = "😈 Embrace it", effects = { Happiness = 5, Smarts = -2 }, resultText = "The thrill of being bad is addicting.", setFlag = "criminal_tendencies" },
			{ text = "🙅 Fight the urge", effects = { Happiness = 2, Smarts = 3 }, resultText = "You resisted the dark path." },
			{ text = "🤔 Just testing limits", effects = { Happiness = 3 }, resultText = "You're just exploring. Not committed." },
		},
	},
	
	{
		id = "m_first_theft",
		minAge = 10, maxAge = 16,
		weight = 20, oneTime = true,
		emoji = "🤫", title = "First Theft",
		category = "crime",
		requiresFlag = "criminal_tendencies",
		blockIfFlag = "petty_thief",
		getDynamicData = function()
			local items = {"candy bar", "small toy", "keychain", "cheap jewelry"}
			return { item = items[math.random(#items)] }
		end,
		text = "You stole a %item% from a store. Heart pounding, you got away with it.",
		choices = {
			{ text = "😈 That was easy!", effects = { Happiness = 6, Smarts = -2 }, resultText = "The rush was incredible. More next time?", setFlag = "petty_thief" },
			{ text = "😰 Feel guilty", effects = { Happiness = -3, Smarts = 2 }, resultText = "You returned it secretly. Never again." },
			{ text = "🎯 Want bigger scores", effects = { Happiness = 4 }, resultText = "Small stuff is for amateurs.", setFlags = {"petty_thief", "ambitious_thief"} },
		},
	},
	
	{
		id = "m_gang_encounter",
		minAge = 14, maxAge = 25,
		weight = 15, oneTime = true,
		emoji = "⚔️", title = "Gang Encounter",
		category = "crime",
		requiresFlag = "criminal_tendencies",
		blockIfFlag = "gang_contact",
		getDynamicData = function()
			local gangs = {"Street Kings", "Southside Bloods", "Eastside Crips", "Latin Lords", "Vice Kings"}
			return { gang = gangs[math.random(#gangs)] }
		end,
		text = "The %gang% noticed you. Their recruiter approaches.",
		choices = {
			{ text = "🤝 Hear them out", effects = { Happiness = 3 }, resultText = "They explained how things work. Interesting.", setFlag = "gang_contact" },
			{ text = "🙅 Not interested", effects = { Happiness = 2, Smarts = 3 }, resultText = "You walked away. They'll be watching." },
			{ text = "😤 Get aggressive", effects = { Health = -10, Happiness = -5 }, resultText = "Bad move. They taught you a lesson." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- GANG PROGRESSION
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_gang_initiation",
		minAge = 14, maxAge = 30,
		weight = 25, oneTime = true, milestone = true,
		emoji = "⚔️", title = "Gang Initiation",
		category = "crime",
		requiresFlag = "gang_contact",
		blockIfFlag = "gang_member",
		getDynamicData = function()
			local tasks = {"jumping in ceremony", "robbery", "delivery run", "fight a rival"}
			return { task = tasks[math.random(#tasks)] }
		end,
		text = "To join, you need to complete the initiation: %task%.",
		choices = {
			{ text = "⚔️ Do it!", effects = { Health = -10, Happiness = 8 }, resultText = "You're officially a gang member now.", setFlag = "gang_member" },
			{ text = "🙅 Back out", effects = { Happiness = -5, Health = -5 }, resultText = "They didn't take rejection well." },
			{ text = "🤔 Ask for something else", effects = { Smarts = 2, Happiness = 2 }, resultText = "They gave you a different task. You're in.", setFlag = "gang_member" },
		},
	},
	
	{
		id = "m_gang_first_job",
		minAge = 14, maxAge = 35,
		weight = 30, cooldown = 2,
		emoji = "💼", title = "Gang Assignment",
		category = "crime",
		requiresFlag = "gang_member",
		getDynamicData = function()
			local jobs = {"drug run", "territory patrol", "debt collection", "weapon transport"}
			return { job = jobs[math.random(#jobs)] }
		end,
		text = "Your first real job for the gang: %job%.",
		choices = {
			{ text = "💪 Execute perfectly", effects = { Happiness = 8, Money = 2000 }, resultText = "You impressed the bosses. Rising star.", setFlag = "gang_trusted" },
			{ text = "😰 Barely complete it", effects = { Happiness = 3, Money = 500 }, resultText = "You got it done. Barely." },
			{ text = "❌ Fail the mission", effects = { Happiness = -10, Health = -10 }, resultText = "The gang doesn't tolerate failure." },
		},
	},
	
	{
		id = "m_gang_promotion_soldier",
		minAge = 16, maxAge = 40,
		weight = 20, oneTime = true,
		emoji = "⬆️", title = "Promoted to Soldier",
		category = "crime",
		requiresFlag = "gang_trusted",
		blockIfFlag = "gang_soldier",
		text = "Your work has been noticed. You're being promoted to soldier.",
		choices = {
			{ text = "💪 Accept with pride", effects = { Happiness = 10, Money = 5000 }, resultText = "More responsibility, more reward.", setFlag = "gang_soldier" },
			{ text = "🤔 What's expected?", effects = { Smarts = 3, Happiness = 5, Money = 3000 }, resultText = "You learned the responsibilities first.", setFlag = "gang_soldier" },
		},
	},
	
	{
		id = "m_gang_promotion_captain",
		minAge = 20, maxAge = 50,
		weight = 15, oneTime = true,
		emoji = "👑", title = "Promoted to Captain",
		category = "crime",
		requiresFlag = "gang_soldier",
		blockIfFlag = "gang_captain",
		text = "A captain position opened up. The boss is considering you.",
		choices = {
			{ text = "👑 Take command", effects = { Happiness = 15, Money = 15000 }, resultText = "You now run your own crew.", setFlag = "gang_captain" },
			{ text = "🤝 Share power", effects = { Happiness = 8, Money = 8000, Smarts = 3 }, resultText = "You co-captain with another. Political move.", setFlag = "gang_captain" },
		},
	},
	
	{
		id = "m_underboss_opportunity",
		minAge = 25, maxAge = 60,
		weight = 10, oneTime = true,
		emoji = "🎭", title = "Underboss Position",
		category = "crime",
		requiresFlag = "gang_captain",
		blockIfFlag = "underboss",
		getDynamicData = function()
			return { bossName = LifeEvents.randomMaleName() }
		end,
		text = "%bossName% wants you as underboss. Second in command of everything.",
		choices = {
			{ text = "👑 Accept the throne", effects = { Happiness = 20, Money = 50000 }, resultText = "You're now the right hand of the boss.", setFlag = "underboss" },
			{ text = "🤔 Negotiate terms", effects = { Happiness = 15, Money = 40000, Smarts = 5 }, resultText = "You secured better terms.", setFlag = "underboss" },
			{ text = "🔪 Why stop there?", effects = { Happiness = 10, Smarts = -3 }, resultText = "You're plotting to take it all...", setFlags = {"underboss", "plotting_takeover"} },
		},
	},
	
	{
		id = "m_become_boss",
		minAge = 30, maxAge = 70,
		weight = 8, oneTime = true, milestone = true,
		emoji = "👑", title = "Become the Boss!",
		category = "crime",
		requiresFlag = "underboss",
		blockIfFlag = "crime_boss",
		getDynamicData = function()
			local methods = {"The old boss retired", "A power vacuum formed", "You orchestrated a coup", "Natural succession"}
			return { method = methods[math.random(#methods)] }
		end,
		text = "%method%. The throne is yours for the taking.",
		choices = {
			{ text = "👑 Claim the crown!", effects = { Happiness = 25, Money = 100000 }, resultText = "You are now THE BOSS. The criminal empire is yours.", setFlag = "crime_boss" },
			{ text = "🤝 Rule wisely", effects = { Happiness = 20, Money = 80000, Smarts = 5 }, resultText = "You took power with diplomacy.", setFlag = "crime_boss" },
			{ text = "🔪 Eliminate rivals first", effects = { Happiness = 15, Health = -10 }, resultText = "You secured power through violence.", setFlags = {"crime_boss", "ruthless_boss"} },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- CRIMINAL OPERATIONS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_drug_dealing",
		minAge = 16, maxAge = 60,
		weight = 25, cooldown = 2,
		emoji = "💊", title = "Drug Deal",
		category = "crime",
		requiresFlag = "gang_member",
		getDynamicData = function()
			local amounts = {2000, 5000, 10000, 25000, 50000}
			return { amount = amounts[math.random(#amounts)] }
		end,
		text = "A drug deal worth $%amount% is going down. You're the point man.",
		choices = {
			{ text = "💰 Clean deal", effects = { Money = 5000, Happiness = 5 }, resultText = "Everything went smooth. Nice profit." },
			{ text = "🔫 Got robbed!", effects = { Money = -2000, Health = -10, Happiness = -8 }, resultText = "They took your product and cash!" },
			{ text = "🚔 Cops showed up!", effects = { Health = -5, Happiness = -10 }, resultText = "You barely escaped! Too close." },
		},
	},
	
	{
		id = "m_heist_planning",
		minAge = 18, maxAge = 55,
		weight = 15, cooldown = 5,
		emoji = "🎯", title = "Heist Planning",
		category = "crime",
		requiresFlag = "gang_soldier",
		getDynamicData = function()
			local targets = {"jewelry store", "bank", "casino", "armored truck", "warehouse"}
			return { target = targets[math.random(#targets)] }
		end,
		text = "There's a score planned: hitting a %target%. Big money if it works.",
		choices = {
			{ 
				text = "🎯 Lead the heist!", 
				effects = { Happiness = 10 }, 
				resultText = "You're in charge. Let's do this.",
				minigame = "heist",
			},
			{ text = "🤝 Join as crew", effects = { Happiness = 5, Money = 10000 }, resultText = "You played your part. Split was good." },
			{ text = "🙅 Too risky", effects = { Happiness = -3, Smarts = 3 }, resultText = "You sat this one out." },
		},
	},
	
	{
		id = "m_gang_war",
		minAge = 16, maxAge = 50,
		weight = 20, cooldown = 3,
		emoji = "⚔️", title = "Gang War!",
		category = "crime",
		requiresFlag = "gang_member",
		getDynamicData = function()
			local rivals = {"Westside Killers", "Northside Mafia", "Downtown Devils", "Harbor Crew"}
			return { rival = rivals[math.random(#rivals)] }
		end,
		text = "War has broken out with the %rival%! Blood in the streets.",
		choices = {
			{ text = "⚔️ Fight on front lines!", effects = { Health = -20, Happiness = 8 }, resultText = "You survived the war. Battle scars.", setFlag = "war_veteran" },
			{ text = "🧠 Strategic operations", effects = { Health = -5, Smarts = 5, Happiness = 5 }, resultText = "You planned attacks. Valuable." },
			{ text = "🏃 Lay low", effects = { Happiness = -5, Health = 2 }, resultText = "You avoided the bloodshed. Some call it cowardice." },
		},
	},
	
	{
		id = "m_money_laundering",
		minAge = 20, maxAge = 60,
		weight = 20, cooldown = 3,
		emoji = "🏦", title = "Money Laundering",
		category = "crime",
		requiresFlag = "gang_captain",
		getDynamicData = function()
			local businesses = {"car wash", "restaurant", "nightclub", "laundromat", "construction company"}
			return { business = businesses[math.random(#businesses)] }
		end,
		text = "You need to clean $500K through a %business%.",
		choices = {
			{ text = "💰 Execute perfectly", effects = { Money = 50000, Smarts = 3 }, resultText = "Clean money in the bank. Smooth operation." },
			{ text = "😰 IRS gets suspicious", effects = { Money = 20000, Happiness = -8 }, resultText = "You had to scale back. Too close." },
			{ text = "🚔 Feds investigate", effects = { Money = -10000, Happiness = -15 }, resultText = "Lawyers fees and frozen assets. Disaster." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- CRIMINAL CONSEQUENCES
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_arrested_crime",
		minAge = 14, maxAge = 70,
		weight = 25, cooldown = 5,
		emoji = "🚔", title = "Arrested!",
		category = "crime",
		requiresFlag = "criminal_tendencies",
		getDynamicData = function()
			local charges = {"possession", "assault", "robbery", "drug trafficking", "weapons charges"}
			return { charge = charges[math.random(#charges)] }
		end,
		text = "The cops got you on %charge%! You're in cuffs.",
		choices = {
			{ text = "🤐 Say nothing", effects = { Smarts = 5, Happiness = -5 }, resultText = "You lawyered up. Smart move." },
			{ text = "😭 Confess", effects = { Happiness = -10 }, resultText = "You spilled everything. Years added.", setFlag = "convicted" },
			{ text = "🐀 Cooperate", effects = { Happiness = -15, Smarts = -3 }, resultText = "You gave up names. Sentence reduced, but...", setFlag = "snitch" },
		},
	},
	
	{
		id = "m_trial_crime",
		minAge = 14, maxAge = 70,
		weight = 30, oneTime = false,
		emoji = "⚖️", title = "Criminal Trial",
		category = "crime",
		requiresFlag = "convicted",
		blockIfFlag = "in_prison",
		getDynamicData = function()
			local years = {2, 5, 10, 15, 25}
			return { sentence = years[math.random(#years)] }
		end,
		text = "Your trial is today. Facing %sentence% years if convicted.",
		choices = {
			{ text = "😇 Found not guilty!", effects = { Happiness = 15 }, resultText = "The jury acquitted you! Free!" },
			{ text = "😔 Convicted", effects = { Happiness = -20 }, resultText = "Guilty. You're going to prison.", setFlag = "in_prison" },
			{ text = "⚖️ Plea deal", effects = { Happiness = -10 }, resultText = "Reduced sentence. Still prison time.", setFlag = "in_prison" },
		},
	},
	
	{
		id = "m_betrayal_crime",
		minAge = 18, maxAge = 60,
		weight = 15, cooldown = 5,
		emoji = "🔪", title = "Betrayed!",
		category = "crime",
		requiresFlag = "gang_member",
		getDynamicData = function()
			return { traitorName = LifeEvents.randomFirstName() }
		end,
		text = "%traitorName%, someone you trusted, sold you out to the feds or rivals.",
		choices = {
			{ text = "🔪 Get revenge", effects = { Happiness = 10, Health = -10 }, resultText = "You handled it. Message sent.", setFlag = "made_example" },
			{ text = "😔 Accept it", effects = { Happiness = -15 }, resultText = "Trust no one. Lesson learned." },
			{ text = "🏃 Go into hiding", effects = { Happiness = -8, Money = -5000 }, resultText = "You disappeared for a while.", setFlag = "laying_low" },
		},
	},
	
	{
		id = "m_near_death_crime",
		minAge = 16, maxAge = 60,
		weight = 12, cooldown = 5,
		emoji = "💀", title = "Near Death Experience",
		category = "crime",
		requiresFlag = "gang_member",
		text = "A rival crew ambushed you. Bullets flying. You barely escaped with your life.",
		choices = {
			{ text = "💀 This is my life now", effects = { Happiness = -10, Health = -15 }, resultText = "Another day survived in the game." },
			{ text = "🤔 Maybe time to get out", effects = { Smarts = 5, Happiness = -5 }, resultText = "You're reconsidering this path...", setFlag = "considering_leaving" },
			{ text = "🔥 Time for payback", effects = { Health = -5, Happiness = 5 }, resultText = "They'll regret not finishing the job.", setFlag = "seeking_revenge" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- GOING LEGIT / REDEMPTION
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_go_legit",
		minAge = 25, maxAge = 60,
		weight = 10, oneTime = true,
		emoji = "🌅", title = "Going Legitimate",
		category = "crime",
		requiresFlag = "considering_leaving",
		text = "You've been thinking about leaving the criminal life. Is it possible?",
		choices = {
			{ text = "🌅 Leave it all behind", effects = { Happiness = 15, Money = -50000 }, resultText = "You paid your debts and walked away.", clearFlags = {"gang_member", "criminal_tendencies"}, setFlag = "reformed" },
			{ text = "💼 Go semi-legit", effects = { Happiness = 8, Money = 20000 }, resultText = "You still have connections but run a real business now.", setFlag = "semi_legit" },
			{ text = "🔙 Can't escape", effects = { Happiness = -10 }, resultText = "They don't let you just leave. You're in for life." },
		},
	},
	
	{
		id = "m_federal_witness",
		minAge = 20, maxAge = 60,
		weight = 8, oneTime = true,
		emoji = "🛡️", title = "Federal Witness Offer",
		category = "crime",
		requiresFlag = "gang_captain",
		text = "The FBI offers you witness protection. Testify against the organization, start a new life.",
		choices = {
			{ text = "🛡️ Take the deal", effects = { Happiness = 5, Money = 10000 }, resultText = "New identity, new life. But always looking over your shoulder.", clearFlags = {"gang_member", "gang_captain"}, setFlags = {"witness_protection", "snitch"} },
			{ text = "🙅 Never snitch", effects = { Happiness = -5 }, resultText = "You refused. Loyalty to the end." },
			{ text = "🔪 Set up the feds", effects = { Happiness = 8, Smarts = 5 }, resultText = "You fed them false info. Dangerous game." },
		},
	},
}

return module
