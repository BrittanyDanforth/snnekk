-- LifeEvents/prison.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- PRISON EVENTS
-- Events that occur while incarcerated
-- ═══════════════════════════════════════════════════════════════════════════════

-- LOCAL HELPER FUNCTIONS (no external dependencies)
local FIRST_NAMES = {"Alex", "Jordan", "Taylor", "Casey", "Morgan", "Riley", "Jamie", "Cameron", "Quinn", "Avery", "Parker", "Skyler", "Dakota", "Reese", "Finley", "Sage", "Rowan", "Charlie", "Emerson", "Hayden"}

local function randomFirstName()
	return FIRST_NAMES[math.random(#FIRST_NAMES)]
end

local MALE_NAMES = {"Mike", "Tony", "Marcus", "Darnell", "Big Rick", "Tiny", "Razor", "Snake", "Bull", "Ace", "Ghost", "Bruno", "Vinny", "Carlos", "Jose", "Tommy", "Bobby", "Frank", "Sal", "Vince"}

local function randomMaleName()
	return MALE_NAMES[math.random(#MALE_NAMES)]
end

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- ARRIVAL & FIRST DAYS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_prison_first_day",
		minAge = 14, maxAge = 80,
		weight = 100, oneTime = true, milestone = true,
		emoji = "⛓️", title = "First Day in Prison",
		category = "prison",
		requiresFlag = "in_prison",
		blockIfFlag = "served_time",
		text = "The cell door slams behind you. This is your new home. The reality of incarceration hits hard.",
		choices = {
			{ text = "😰 Keep your head down", effects = { Happiness = -10 }, resultText = "You try to be invisible. Smart move for now.", setFlag = "served_time" },
			{ text = "💪 Show strength", effects = { Happiness = -5, Health = -3 }, resultText = "You puffed up your chest. Some noticed.", setFlag = "served_time" },
			{ text = "😭 Break down", effects = { Happiness = -15, Health = -5 }, resultText = "The tears came. Weakness shows.", setFlag = "served_time" },
		},
	},
	
	{
		id = "m_prison_intake",
		minAge = 14, maxAge = 80,
		weight = 80, oneTime = true,
		emoji = "📋", title = "Prison Intake",
		category = "prison",
		requiresFlag = "in_prison",
		blockIfFlag = "prison_processed",
		text = "Strip search, orange jumpsuit, inmate number. You're processed into the system.",
		choices = {
			{ text = "😤 This is humiliating", effects = { Happiness = -8 }, resultText = "The guards don't care about your dignity.", setFlag = "prison_processed" },
			{ text = "🤐 Stay silent", effects = { Happiness = -4, Smarts = 2 }, resultText = "You didn't give them a reason to make it worse.", setFlag = "prison_processed" },
			{ text = "🗣️ Ask about your rights", effects = { Smarts = 3, Happiness = -3 }, resultText = "The guards laughed. 'Rights?' Still, good to know.", setFlag = "prison_processed" },
		},
	},
	
	{
		id = "m_prison_cell_assignment",
		minAge = 14, maxAge = 80,
		weight = 70, oneTime = true,
		emoji = "🚪", title = "Cell Assignment",
		category = "prison",
		requiresFlag = "in_prison",
		requiresFlag2 = "prison_processed",
		blockIfFlag = "has_cellmate",
		getDynamicData = function()
			local types = {"quiet guy", "big intimidating dude", "talkative veteran", "nervous first-timer"}
			return { cellmateType = types[math.random(#types)] }
		end,
		text = "You've been assigned a cell with a %cellmateType%.",
		choices = {
			{ text = "🤝 Introduce yourself", effects = { Happiness = 3 }, resultText = "Your cellmate nodded. Not enemies, at least.", setFlag = "has_cellmate" },
			{ text = "🤐 Keep to yourself", effects = { Happiness = -2, Smarts = 2 }, resultText = "You claimed your space silently.", setFlag = "has_cellmate" },
			{ text = "💪 Assert dominance", effects = { Health = -5, Happiness = 3 }, resultText = "You got into a scuffle. Message sent.", setFlag = "has_cellmate" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- DAILY PRISON LIFE
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_prison_yard_time",
		minAge = 14, maxAge = 80,
		weight = 40, cooldown = 2,
		emoji = "🏋️", title = "Yard Time",
		category = "prison",
		requiresFlag = "in_prison",
		text = "It's yard time. An hour of fresh air and exercise.",
		choices = {
			{ text = "🏋️ Work out", effects = { Health = 5, Happiness = 2 }, resultText = "You're getting stronger in here." },
			{ text = "🚶 Walk the perimeter", effects = { Happiness = 3, Smarts = 2 }, resultText = "You observed the layout. Knowledge is power." },
			{ text = "👥 Socialize", effects = { Happiness = 4 }, resultText = "You made some connections." },
			{ text = "🧘 Find peace", effects = { Happiness = 5, Smarts = 3 }, resultText = "You meditated in the corner. Mental clarity." },
		},
	},
	
	{
		id = "m_prison_cafeteria",
		minAge = 14, maxAge = 80,
		weight = 35, cooldown = 2,
		emoji = "🍽️", title = "Cafeteria Incident",
		category = "prison",
		requiresFlag = "in_prison",
		getDynamicData = function()
			return { inmateName = randomFirstName() }
		end,
		text = "%inmateName% cuts in front of you in the food line.",
		choices = {
			{ text = "😤 Confront them", effects = { Health = -5, Happiness = 3 }, resultText = "You stood your ground. Risky but respected." },
			{ text = "🤷 Let it go", effects = { Happiness = -3, Smarts = 2 }, resultText = "You picked your battles. Smart." },
			{ text = "🗣️ Call them out loud", effects = { Health = -8, Happiness = 5 }, resultText = "Fight broke out. Solitary time." },
		},
	},
	
	{
		id = "m_prison_contraband",
		minAge = 16, maxAge = 80,
		weight = 25, cooldown = 3,
		emoji = "📦", title = "Contraband Offer",
		category = "prison",
		requiresFlag = "in_prison",
		getDynamicData = function()
			local items = {"phone", "cigarettes", "drugs", "weapon"}
			return { item = items[math.random(#items)] }
		end,
		text = "Someone offers you %item% for a favor.",
		choices = {
			{ text = "🤝 Accept the deal", effects = { Happiness = 5, Smarts = -3 }, resultText = "You got the goods. Risky move.", setFlag = "prison_dealer" },
			{ text = "🙅 Refuse", effects = { Happiness = -2, Smarts = 3 }, resultText = "You stayed clean. Safer." },
			{ text = "🐀 Snitch", effects = { Happiness = -5, Smarts = 2 }, resultText = "You reported it. Guard's pet now.", setFlag = "prison_snitch" },
		},
	},
	
	{
		id = "m_prison_fight",
		minAge = 14, maxAge = 80,
		weight = 30, cooldown = 2,
		emoji = "👊", title = "Prison Fight!",
		category = "prison",
		requiresFlag = "in_prison",
		getDynamicData = function()
			return { opponent = randomFirstName() }
		end,
		text = "%opponent% is picking a fight with you! The guards aren't looking.",
		choices = {
			{ text = "👊 Fight back!", effects = { Health = -15, Happiness = 5 }, resultText = "You won the fight! Reputation boosted.", setFlag = "prison_fighter" },
			{ text = "🏃 Try to escape", effects = { Health = -8, Happiness = -3 }, resultText = "You got away but looked weak." },
			{ text = "😵 Get beaten", effects = { Health = -20, Happiness = -10 }, resultText = "You got destroyed. Target on your back." },
			{ text = "🗣️ Talk your way out", effects = { Smarts = 5, Happiness = 2 }, resultText = "Surprisingly, words worked. Respect earned differently." },
		},
	},
	
	{
		id = "m_prison_gang_recruitment",
		minAge = 16, maxAge = 60,
		weight = 25, oneTime = true,
		emoji = "⚔️", title = "Gang Recruitment",
		category = "prison",
		requiresFlag = "in_prison",
		blockIfFlag = "prison_gang_member",
		getDynamicData = function()
			local gangs = {"Aryan Brotherhood", "MS-13", "Latin Kings", "Crips", "Bloods"}
			return { gang = gangs[math.random(#gangs)] }
		end,
		text = "The %gang% is offering protection. But joining means doing their dirty work.",
		choices = {
			{ text = "⚔️ Join them", effects = { Health = -5, Happiness = 5 }, resultText = "You're in. Protection granted, loyalty expected.", setFlags = {"prison_gang_member", "gang_affiliated"} },
			{ text = "🙅 Decline", effects = { Happiness = -5 }, resultText = "You'll have to survive alone." },
			{ text = "🕐 Ask for time", effects = { Smarts = 2 }, resultText = "They gave you a week to decide." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- PRISON RELATIONSHIPS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_prison_mentor",
		minAge = 16, maxAge = 70,
		weight = 20, oneTime = true,
		emoji = "🧙", title = "Prison Mentor",
		category = "prison",
		requiresFlag = "in_prison",
		getDynamicData = function()
			return { mentorName = randomMaleName() }
		end,
		text = "%mentorName%, an old-timer, takes you under his wing. 'Let me teach you how to survive in here.'",
		choices = {
			{ text = "📚 Learn from him", effects = { Smarts = 8, Happiness = 5 }, resultText = "His wisdom might save your life.", setFlag = "prison_mentor" },
			{ text = "🤔 Be suspicious", effects = { Smarts = 3, Happiness = -2 }, resultText = "You kept your distance. Trust no one." },
			{ text = "🤝 Become friends", effects = { Happiness = 8, Smarts = 5 }, resultText = "You found a genuine friend in here.", setFlag = "prison_mentor" },
		},
	},
	
	{
		id = "m_prison_enemy",
		minAge = 14, maxAge = 80,
		weight = 25, oneTime = true,
		emoji = "😠", title = "Made an Enemy",
		category = "prison",
		requiresFlag = "in_prison",
		blockIfFlag = "prison_enemy",
		getDynamicData = function()
			return { enemyName = randomFirstName() }
		end,
		text = "%enemyName% has it out for you. You stepped on their turf somehow.",
		choices = {
			{ text = "⚔️ Handle it now", effects = { Health = -10, Happiness = 3 }, resultText = "You fought. Message sent.", setFlag = "prison_enemy" },
			{ text = "🕐 Watch your back", effects = { Happiness = -8, Smarts = 3 }, resultText = "You're on edge constantly.", setFlag = "prison_enemy" },
			{ text = "🤝 Try to squash it", effects = { Happiness = 2, Smarts = 4 }, resultText = "You negotiated peace. For now.", setFlag = "prison_enemy" },
		},
	},
	
	{
		id = "m_prison_visit",
		minAge = 14, maxAge = 80,
		weight = 35, cooldown = 3,
		emoji = "👨‍👩‍👧", title = "Family Visit",
		category = "prison",
		requiresFlag = "in_prison",
		getDynamicData = function()
			local visitors = {"mother", "father", "sibling", "partner", "child", "friend"}
			return { visitor = visitors[math.random(#visitors)] }
		end,
		text = "Your %visitor% came to visit. Seeing them through the glass is bittersweet.",
		choices = {
			{ text = "😢 Emotional reunion", effects = { Happiness = 8, Health = 2 }, resultText = "The visit gave you strength to keep going." },
			{ text = "😔 Hard to face them", effects = { Happiness = -5 }, resultText = "The shame was overwhelming." },
			{ text = "💪 Stay strong for them", effects = { Happiness = 5, Smarts = 2 }, resultText = "You put on a brave face." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- ESCAPE & RELEASE
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_prison_escape_opportunity",
		minAge = 16, maxAge = 60,
		weight = 15, oneTime = true,
		emoji = "🔓", title = "Escape Opportunity!",
		category = "prison",
		requiresFlag = "in_prison",
		requiresFlag2 = "prison_mentor",
		getDynamicData = function()
			local methods = {"tunnel", "laundry truck", "guard bribe", "roof access"}
			return { method = methods[math.random(#methods)] }
		end,
		text = "A group is planning an escape via %method%. They need one more person.",
		choices = {
			{ 
				text = "🏃 Join the escape!", 
				effects = { Happiness = 10 }, 
				resultText = "You're in. Freedom or death.",
				minigame = "prison_escape",
			},
			{ text = "🙅 Too risky", effects = { Happiness = -3, Smarts = 4 }, resultText = "You'll wait for parole." },
			{ text = "🐀 Report it", effects = { Happiness = -10, Smarts = 2 }, resultText = "You snitched. Time reduced, reputation destroyed.", setFlag = "prison_snitch" },
		},
	},
	
	{
		id = "m_prison_parole_hearing",
		minAge = 14, maxAge = 80,
		weight = 40, cooldown = 5,
		emoji = "⚖️", title = "Parole Hearing",
		category = "prison",
		requiresFlag = "in_prison",
		text = "You have a parole hearing! This could be your ticket out.",
		choices = {
			{ text = "😇 Show remorse", effects = { Happiness = 5, Smarts = 3 }, resultText = "You expressed genuine regret. They'll consider it." },
			{ text = "😤 I'm innocent!", effects = { Happiness = -5, Smarts = -2 }, resultText = "Your defiance didn't help." },
			{ text = "📝 Present your case", effects = { Smarts = 5, Happiness = 3 }, resultText = "You made a logical argument for release." },
		},
	},
	
	{
		id = "m_prison_release_day",
		minAge = 14, maxAge = 80,
		weight = 100, oneTime = true, milestone = true,
		emoji = "🔓", title = "Release Day!",
		category = "prison",
		requiresFlag = "in_prison",
		requiresFlag2 = "sentence_complete",
		text = "The gates open. You're free. The sun feels different on this side of the walls.",
		choices = {
			{ 
				text = "🎉 Fresh start!", 
				effects = { Happiness = 20 }, 
				resultText = "You vowed never to come back. Freedom!",
				clearFlags = {"in_prison", "sentence_complete"},
				setFlag = "ex_convict",
			},
			{ 
				text = "😰 Nervous about outside", 
				effects = { Happiness = 10, Smarts = 2 }, 
				resultText = "The world changed while you were inside.",
				clearFlags = {"in_prison", "sentence_complete"},
				setFlag = "ex_convict",
			},
			{ 
				text = "😤 Ready for revenge", 
				effects = { Happiness = 5, Smarts = -3 }, 
				resultText = "You have scores to settle.",
				clearFlags = {"in_prison", "sentence_complete"},
				setFlags = {"ex_convict", "seeking_revenge"},
			},
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- PRISON PROGRAMS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_prison_ged",
		minAge = 16, maxAge = 60,
		weight = 30, oneTime = true,
		emoji = "📚", title = "GED Program",
		category = "prison",
		requiresFlag = "in_prison",
		blockIfFlag = "prison_ged",
		text = "The prison offers a GED program. Education could help when you get out.",
		choices = {
			{ text = "📚 Sign up!", effects = { Smarts = 10, Happiness = 5 }, resultText = "You're working toward your GED!", setFlag = "prison_ged" },
			{ text = "🤷 Not interested", effects = { Happiness = -2 }, resultText = "School wasn't for you anyway." },
		},
	},
	
	{
		id = "m_prison_job",
		minAge = 16, maxAge = 80,
		weight = 35, oneTime = true,
		emoji = "🔧", title = "Prison Work Detail",
		category = "prison",
		requiresFlag = "in_prison",
		blockIfFlag = "prison_job",
		getDynamicData = function()
			local jobs = {"kitchen duty", "laundry", "library", "yard maintenance", "workshop"}
			return { job = jobs[math.random(#jobs)] }
		end,
		text = "You can apply for %job%. It pays pennies but passes the time.",
		choices = {
			{ text = "👷 Take the job", effects = { Smarts = 3, Happiness = 3, Money = 50 }, resultText = "Work gives you purpose in here.", setFlag = "prison_job" },
			{ text = "🙅 Rather not", effects = { Happiness = -2 }, resultText = "More time in your cell." },
		},
	},
	
	{
		id = "m_prison_chapel",
		minAge = 14, maxAge = 80,
		weight = 25, cooldown = 3,
		emoji = "⛪", title = "Prison Chapel",
		category = "prison",
		requiresFlag = "in_prison",
		text = "The prison chaplain invites you to services.",
		choices = {
			{ text = "🙏 Find faith", effects = { Happiness = 8, Smarts = 3 }, resultText = "You found comfort in spirituality.", setFlag = "found_religion" },
			{ text = "😇 Attend for show", effects = { Happiness = 3, Smarts = 2 }, resultText = "Looks good for parole." },
			{ text = "🙅 Not for me", effects = { Happiness = -1 }, resultText = "Religion isn't your thing." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- PRISON DANGERS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_prison_solitary",
		minAge = 14, maxAge = 80,
		weight = 15, cooldown = 5,
		emoji = "🚪", title = "Solitary Confinement",
		category = "prison",
		requiresFlag = "in_prison",
		text = "You've been sent to solitary confinement. 23 hours a day alone.",
		choices = {
			{ text = "😵 Lose your mind", effects = { Happiness = -20, Smarts = -5, Health = -5 }, resultText = "The isolation broke something in you." },
			{ text = "🧘 Meditate through it", effects = { Happiness = -5, Smarts = 5 }, resultText = "You used the time for reflection.", setFlag = "survived_solitary" },
			{ text = "💪 Stay strong", effects = { Happiness = -10, Health = -3 }, resultText = "You counted the days. Made it through." },
		},
	},
	
	{
		id = "m_prison_riot",
		minAge = 16, maxAge = 70,
		weight = 10, oneTime = true,
		emoji = "🔥", title = "Prison Riot!",
		category = "prison",
		requiresFlag = "in_prison",
		text = "A riot breaks out! Chaos everywhere. Guards losing control.",
		choices = {
			{ text = "🔥 Join the riot!", effects = { Health = -15, Happiness = 10 }, resultText = "You fought in the chaos! More time added." },
			{ text = "🏃 Find cover", effects = { Health = -5, Happiness = -5, Smarts = 3 }, resultText = "You hid until it was over. Smart." },
			{ text = "🚪 Try to escape!", effects = { Health = -10, Happiness = 15 }, resultText = "You made a break for it in the confusion!", minigame = "prison_escape" },
		},
	},
	
	{
		id = "m_prison_shank",
		minAge = 16, maxAge = 70,
		weight = 15, oneTime = true,
		emoji = "🔪", title = "Shanked!",
		category = "prison",
		requiresFlag = "in_prison",
		requiresFlag2 = "prison_enemy",
		getDynamicData = function()
			return { attackerName = randomFirstName() }
		end,
		text = "%attackerName% attacked you with a shank! You're bleeding!",
		choices = {
			{ text = "😵 Badly wounded", effects = { Health = -30, Happiness = -15 }, resultText = "You barely survived. Hospital wing for weeks." },
			{ text = "👊 Fight back!", effects = { Health = -15, Happiness = 5 }, resultText = "You defended yourself! Both to solitary." },
			{ text = "🏃 Escape injury", effects = { Health = -5, Happiness = 3 }, resultText = "You got cut but avoided major damage." },
		},
	},
	
	{
		id = "m_prison_drugs",
		minAge = 16, maxAge = 70,
		weight = 20, cooldown = 3,
		emoji = "💊", title = "Drugs in Prison",
		category = "prison",
		requiresFlag = "in_prison",
		text = "Drugs are offered to you. A way to escape the reality of prison.",
		choices = {
			{ text = "💊 Use them", effects = { Happiness = 10, Health = -10, Smarts = -5 }, resultText = "Temporary escape, long-term damage.", setFlag = "prison_addict" },
			{ text = "🙅 Stay clean", effects = { Happiness = -3, Smarts = 3 }, resultText = "You refused. Clear head." },
			{ text = "💰 Deal them", effects = { Money = 500, Health = -5 }, resultText = "You saw a business opportunity.", setFlag = "prison_dealer" },
		},
	},
	
	{
		id = "m_prison_good_behavior",
		minAge = 14, maxAge = 80,
		weight = 30, cooldown = 3,
		emoji = "⭐", title = "Good Behavior",
		category = "prison",
		requiresFlag = "in_prison",
		blockIfFlag = "prison_fighter",
		text = "You've been on good behavior. The guards noticed.",
		choices = {
			{ text = "😇 Keep it up", effects = { Happiness = 5, Smarts = 3 }, resultText = "Your sentence might get reduced.", setFlag = "model_prisoner" },
			{ text = "😤 Don't care", effects = { Happiness = 2 }, resultText = "You did your own thing." },
			{ text = "📝 Request privileges", effects = { Happiness = 4, Smarts = 2 }, resultText = "Extra yard time granted!" },
		},
	},
}

return module
