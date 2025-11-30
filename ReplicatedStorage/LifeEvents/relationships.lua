-- LifeEvents/relationships.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- RELATIONSHIP EVENTS
-- Romance, family, friends, social connections
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent.init)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- ROMANCE EVENTS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_meet_someone_special",
		minAge = 16, maxAge = 60,
		weight = 35, cooldown = 3,
		emoji = "💕", title = "Meeting Someone Special",
		category = "romance",
		blockIfFlag = "married",
		getDynamicData = function()
			return { personName = LifeEvents.randomFirstName() }
		end,
		text = "You met %personName% at a party. There's definitely chemistry.",
		choices = {
			{ 
				text = "💕 Ask them out!", 
				effects = { Happiness = 8 }, 
				resultText = "They said yes! You have a date with %personName%.", 
				setFlag = "dating",
				addRelationship = { category = "lovers", dynamicNameKey = "personName", startingRelationship = 55, type = "dating" }
			},
			{ 
				text = "📱 Get their number", 
				effects = { Happiness = 5 }, 
				resultText = "You exchanged contacts with %personName%. Potential!",
				addRelationship = { category = "lovers", dynamicNameKey = "personName", startingRelationship = 35, type = "interest" }
			},
			{ text = "😰 Too nervous", effects = { Happiness = -3 }, resultText = "The moment passed. What if?" },
		},
	},
	
	{
		id = "m_relationship_fight",
		minAge = 16, maxAge = 70,
		weight = 30, cooldown = 2,
		emoji = "💔", title = "Relationship Argument",
		category = "romance",
		requiresFlag = "in_relationship",
		getDynamicData = function()
			local topics = {"money", "jealousy", "future plans", "trust issues", "family drama"}
			return { topic = topics[math.random(#topics)] }
		end,
		text = "You and your partner had a big fight about %topic%.",
		choices = {
			{ text = "🗣️ Talk it out", effects = { Happiness = 3, Smarts = 2 }, resultText = "Communication helped. You're stronger now." },
			{ text = "😤 Stand your ground", effects = { Happiness = -5 }, resultText = "You didn't back down. Cold silence follows." },
			{ text = "😢 Apologize", effects = { Happiness = 2 }, resultText = "You said sorry, even if you weren't wrong." },
			{ text = "💔 Break up", effects = { Happiness = -15 }, resultText = "This was the last straw.", clearFlag = "in_relationship" },
		},
	},
	
	{
		id = "m_cheating_discovered",
		minAge = 18, maxAge = 60,
		weight = 10, oneTime = true,
		emoji = "💔", title = "Infidelity Discovered",
		category = "romance",
		requiresFlag = "in_relationship",
		text = "You discovered your partner has been cheating on you. The betrayal hurts.",
		choices = {
			{ text = "😭 Devastated", effects = { Happiness = -25 }, resultText = "Your heart is shattered." },
			{ text = "💔 Leave them", effects = { Happiness = -15, Smarts = 3 }, resultText = "Self-respect intact.", clearFlags = {"in_relationship", "married"} },
			{ text = "🤝 Try to work through it", effects = { Happiness = -10 }, resultText = "You're trying counseling." },
			{ text = "😤 Get revenge", effects = { Happiness = -5, Smarts = -3 }, resultText = "Two wrongs don't make a right.", clearFlags = {"in_relationship", "married"} },
		},
	},
	
	{
		id = "m_pregnancy_news",
		minAge = 18, maxAge = 45,
		weight = 25, oneTime = false,
		emoji = "🤰", title = "Pregnancy News!",
		category = "romance",
		requiresFlag = "married",
		text = "You're going to be a parent! A baby is on the way.",
		choices = {
			{ text = "🎉 Overjoyed!", effects = { Happiness = 20 }, resultText = "Best news ever!", setFlag = "expecting" },
			{ text = "😰 Nervous", effects = { Happiness = 5 }, resultText = "Big change coming. Are you ready?", setFlag = "expecting" },
			{ text = "😟 Not planned", effects = { Happiness = -5 }, resultText = "This wasn't the timing you wanted.", setFlag = "expecting" },
		},
	},
	
	{
		id = "m_baby_born",
		minAge = 18, maxAge = 50,
		weight = 80, oneTime = false, milestone = true,
		emoji = "👶", title = "Baby Born!",
		category = "family",
		requiresFlag = "expecting",
		getDynamicData = function()
			local genders = {"boy", "girl"}
			return { gender = genders[math.random(#genders)] }
		end,
		text = "It's a %gender%! Welcome to parenthood.",
		choices = {
			{ text = "👶 Pure love!", effects = { Happiness = 25 }, resultText = "You're a parent! Life changed forever.", setFlags = {"parent", "has_children"}, clearFlag = "expecting" },
			{ text = "😴 Exhausted already", effects = { Happiness = 10, Health = -5 }, resultText = "Sleep deprivation begins.", setFlags = {"parent", "has_children"}, clearFlag = "expecting" },
		},
	},
	
	{
		id = "m_divorce_general",
		minAge = 25, maxAge = 70,
		weight = 15, oneTime = false,
		emoji = "💔", title = "Divorce",
		category = "romance",
		requiresFlag = "married",
		text = "The marriage isn't working. Divorce papers are being discussed.",
		choices = {
			{ text = "💔 Go through with it", effects = { Happiness = -20, Money = -30000 }, resultText = "It's over. Financially and emotionally costly.", clearFlags = {"married", "in_relationship"}, setFlag = "divorced" },
			{ text = "🤝 Counseling first", effects = { Happiness = -5, Money = -3000 }, resultText = "One more try..." },
			{ text = "😤 Fight for assets", effects = { Happiness = -15, Money = 10000, Smarts = -2 }, resultText = "Ugly divorce. You got more money at least.", clearFlags = {"married", "in_relationship"}, setFlag = "divorced" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- FAMILY EVENTS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_family_reunion",
		minAge = 10, maxAge = 80,
		weight = 25, cooldown = 5,
		emoji = "👨‍👩‍👧‍👦", title = "Family Reunion",
		category = "family",
		text = "The whole family is getting together! Aunts, uncles, cousins, grandparents.",
		choices = {
			{ text = "🎉 Great time!", effects = { Happiness = 10 }, resultText = "Wonderful memories made!" },
			{ text = "😅 Awkward questions", effects = { Happiness = 2 }, resultText = "So, when are you getting married?" },
			{ text = "😤 Drama happened", effects = { Happiness = -8 }, resultText = "Family politics are exhausting." },
			{ text = "🙅 Skip it", effects = { Happiness = -3 }, resultText = "You avoided the gathering." },
		},
	},
	
	{
		id = "m_parent_health_scare",
		minAge = 25, maxAge = 60,
		weight = 15, cooldown = 5,
		emoji = "🏥", title = "Parent Health Scare",
		category = "family",
		getDynamicData = function()
			local parents = {"mother", "father"}
			return { parent = parents[math.random(#parents)] }
		end,
		text = "Your %parent% had a health scare. They're in the hospital.",
		choices = {
			{ text = "🏥 Rush to their side", effects = { Happiness = -10 }, resultText = "You're there for them. They're recovering." },
			{ text = "😢 Worry from afar", effects = { Happiness = -8 }, resultText = "You couldn't get there in time." },
			{ text = "💪 They pull through!", effects = { Happiness = 5 }, resultText = "False alarm. Everyone is okay!" },
		},
	},
	
	{
		id = "m_parent_death",
		minAge = 30, maxAge = 80,
		weight = 8, oneTime = true,
		emoji = "🕊️", title = "Parent Passes Away",
		category = "family",
		getDynamicData = function()
			local parents = {"mother", "father"}
			return { parent = parents[math.random(#parents)] }
		end,
		text = "Your %parent% has passed away. A profound loss.",
		choices = {
			{ text = "😭 Grief overtakes you", effects = { Happiness = -25, Health = -5 }, resultText = "The loss is devastating." },
			{ text = "💪 Celebrate their life", effects = { Happiness = -10, Smarts = 3 }, resultText = "You honor their memory.", setFlag = "lost_parent" },
			{ text = "😔 Complicated feelings", effects = { Happiness = -15 }, resultText = "The relationship was complex.", setFlag = "lost_parent" },
		},
	},
	
	{
		id = "m_inheritance",
		minAge = 25, maxAge = 70,
		weight = 12, oneTime = true,
		emoji = "💰", title = "Inheritance",
		category = "family",
		requiresFlag = "lost_parent",
		getDynamicData = function()
			local amounts = {10000, 50000, 100000, 250000, 500000}
			return { amount = amounts[math.random(#amounts)] }
		end,
		text = "You've inherited $%amount% from your parent's estate.",
		choices = {
			{ text = "💰 Save it", effects = { Money = 50000, Happiness = 5 }, resultText = "You're financially better off." },
			{ text = "🏠 Buy property", effects = { Money = 30000, Happiness = 8 }, resultText = "Invested in real estate.", setFlag = "inherited_property" },
			{ text = "😔 Bittersweet", effects = { Money = 40000, Happiness = -3 }, resultText = "No amount of money replaces them." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- FRIENDSHIP EVENTS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_make_new_friend",
		minAge = 15, maxAge = 60,
		weight = 30, cooldown = 3,
		emoji = "👥", title = "New Friend!",
		category = "social",
		getDynamicData = function()
			return { friendName = LifeEvents.randomFirstName() }
		end,
		text = "You hit it off with %friendName%! Potential new friend.",
		choices = {
			{ 
				text = "🤝 Become friends!", 
				effects = { Happiness = 8 }, 
				resultText = "You made a new friend! %friendName% is now in your contacts.", 
				addRelationship = { category = "friends", dynamicNameKey = "friendName", startingRelationship = 65, type = "friend" }
			},
			{ 
				text = "📱 Exchange info", 
				effects = { Happiness = 4 }, 
				resultText = "You exchanged contacts with %friendName%. Maybe you'll hang out sometime.",
				addRelationship = { category = "friends", dynamicNameKey = "friendName", startingRelationship = 40, type = "acquaintance" }
			},
			{ text = "🤷 Nice to meet them", effects = { Happiness = 2 }, resultText = "Pleasant but not memorable." },
		},
	},
	
	{
		id = "m_friend_in_need",
		minAge = 15, maxAge = 70,
		weight = 20, cooldown = 3,
		emoji = "🆘", title = "Friend in Need",
		category = "social",
		getDynamicData = function()
			return { friendName = LifeEvents.randomFirstName() }
		end,
		text = "%friendName% needs help. They're going through a tough time.",
		choices = {
			{ text = "🤝 Be there for them", effects = { Happiness = 5, Smarts = 2 }, resultText = "You were a true friend." },
			{ text = "💰 Help financially", effects = { Happiness = 3, Money = -2000 }, resultText = "You lent them money." },
			{ text = "🤷 Not my problem", effects = { Happiness = -3 }, resultText = "You kept your distance." },
		},
	},
	
	{
		id = "m_friend_betrayal",
		minAge = 15, maxAge = 60,
		weight = 15, cooldown = 5,
		emoji = "💔", title = "Friend Betrayal",
		category = "social",
		getDynamicData = function()
			return { friendName = LifeEvents.randomFirstName() }
		end,
		text = "%friendName% betrayed your trust. They shared your secrets.",
		choices = {
			{ text = "😤 Cut them off", effects = { Happiness = -8 }, resultText = "That friendship is over." },
			{ text = "🗣️ Confront them", effects = { Happiness = -3, Smarts = 2 }, resultText = "You called them out. They apologized." },
			{ text = "🤷 Forgive them", effects = { Happiness = -2, Smarts = 3 }, resultText = "People make mistakes. You moved past it." },
		},
	},
	
	{
		id = "m_toxic_friend",
		minAge = 15, maxAge = 50,
		weight = 15, cooldown = 3,
		emoji = "☠️", title = "Toxic Friend",
		category = "social",
		getDynamicData = function()
			return { friendName = LifeEvents.randomFirstName() }
		end,
		text = "%friendName% has become toxic. Always negative, always drama.",
		choices = {
			{ text = "🚪 End the friendship", effects = { Happiness = 5, Smarts = 3 }, resultText = "You prioritized your mental health." },
			{ text = "🗣️ Have a talk", effects = { Happiness = -2 }, resultText = "You tried to help them change." },
			{ text = "🤷 Keep them around", effects = { Happiness = -5 }, resultText = "You tolerate their behavior." },
		},
	},
}

return module
