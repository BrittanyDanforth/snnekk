-- career_political.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- POLITICAL CAREER EVENTS - Activist to President
-- ═══════════════════════════════════════════════════════════════════════════════

local events = {}

-- ═══════════════════════════════════════════════════════════════
-- POLITICAL ORIGIN EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "political_awakening",
	emoji = "📢",
	title = "Political Awakening",
	category = "life",
	tags = {"career", "politician", "origin", "activism"},
	
	weight = 10,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	chainId = "political_origin",
	chainStep = 1,
	
	conditions = {
		minAge = 15,
		maxAge = 35,
		blockedFlags = {"career_politician_started", "politically_apathetic"},
		minStats = {Smarts = 40},
	},
	
	getDynamicData = function(state)
		local issues = {"local schools being underfunded", "environmental concerns", "community safety", "economic inequality"}
		return {
			issue = issues[math.random(#issues)]
		}
	end,
	
	text = "News about %issue% ignites something in you. Complaining isn't enough - you want to actually change things.",
	
	choices = {
		{
			id = "become_activist",
			text = "Get involved and make my voice heard!",
			resultText = "You start attending meetings, organizing events, and speaking up.",
			effects = {Karma = 3, Happiness = 3},
			flags = {set = {"career_politician_started", "political_activist"}},
			startCareer = "politician",
			careerXP = 15,
		},
		{
			id = "stay_informed",
			text = "Stay informed but don't get too involved.",
			resultText = "You follow politics closely but don't actively participate.",
			effects = {Smarts = 1},
			flags = {set = {"politically_aware"}},
		},
		{
			id = "tune_out",
			text = "Politics is all corrupt anyway. Ignore it.",
			resultText = "You disengage from political discussions. Less stress, less impact.",
			effects = {},
			flags = {set = {"politically_apathetic"}},
		},
	},
})

table.insert(events, {
	id = "political_campaign_start",
	emoji = "🗳️",
	title = "Run for Local Office",
	category = "government",
	tags = {"career", "politician", "local_politics"},
	
	weight = 8,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	chainId = "political_career",
	chainStep = 1,
	
	conditions = {
		minAge = 21,
		maxAge = 70,
		requiredCareerId = "politician",
		requiredCareerMinTier = 1,
		requiredAllFlags = {"political_activist"},
	},
	
	getDynamicData = function(state)
		local positions = {"city council", "school board", "local commission", "town committee"}
		return {
			position = positions[math.random(#positions)]
		}
	end,
	
	text = "Friends encourage you to run for %position%. It's a small position, but it's where political careers begin.",
	
	choices = {
		{
			id = "run_campaign",
			text = "Let's do this! I'm running.",
			resultText = "You file the paperwork and start your first political campaign.",
			effects = {Money = -5000, Happiness = 4},
			flags = {set = {"ran_for_office", "campaign_active"}},
			careerXP = 25,
		},
		{
			id = "not_ready",
			text = "I'm not ready for that yet.",
			resultText = "You decide to gain more experience before running for anything.",
			effects = {},
			flags = {set = {}},
		},
	},
})

table.insert(events, {
	id = "political_first_win",
	emoji = "🎉",
	title = "Election Night",
	category = "government",
	tags = {"career", "politician", "local_politics", "milestone"},
	
	weight = 12,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 21,
		maxAge = 75,
		requiredCareerId = "politician",
		requiredAllFlags = {"campaign_active"},
	},
	
	text = "Election night. The results come in. Your heart is pounding as they count the final votes...",
	
	choices = {
		{
			id = "win_election",
			text = "You won! The people chose you!",
			resultText = "Victory! You're now an elected official. Time to actually deliver on those promises.",
			effects = {Happiness = 8, Karma = 2},
			flags = {set = {"elected_official"}, clear = {"campaign_active"}},
			promoteCareer = true,
			careerXP = 40,
			careerReputation = 20,
		},
		{
			id = "lose_election",
			text = "You lost. But it was close.",
			resultText = "Defeat stings, but you made connections. Maybe next time.",
			effects = {Happiness = -5},
			flags = {set = {"lost_election"}, clear = {"campaign_active"}},
			careerXP = 15,
		},
	},
})

table.insert(events, {
	id = "political_scandal_accusation",
	emoji = "📰",
	title = "Political Attack",
	category = "government",
	tags = {"career", "politician", "scandal"},
	
	weight = 7,
	cooldownYears = 4,
	oneTime = false,
	
	conditions = {
		minAge = 25,
		maxAge = 80,
		requiredCareerId = "politician",
		requiredCareerMinTier = 2,
	},
	
	text = "Your opponents dig up something from your past and blast it to the media. True or not, it's damaging your reputation.",
	
	choices = {
		{
			id = "address_head_on",
			text = "Address it head-on with transparency.",
			resultText = "You hold a press conference and face the accusations. Some respect your honesty.",
			effects = {Happiness = -3},
			flags = {set = {"survived_scandal"}},
			careerReputation = -5,
		},
		{
			id = "attack_back",
			text = "Go negative on your opponents.",
			resultText = "You dig up dirt on them too. Politics gets ugly fast.",
			effects = {Karma = -4, Happiness = -2},
			flags = {set = {"plays_dirty"}},
			careerReputation = -10,
		},
		{
			id = "ignore_and_focus",
			text = "Ignore it and focus on the issues.",
			resultText = "You refuse to engage with mudslinging. Voters notice your composure.",
			effects = {Karma = 2},
			flags = {set = {"above_the_fray"}},
			careerReputation = 5,
		},
	},
})

table.insert(events, {
	id = "political_higher_office",
	emoji = "🏛️",
	title = "Run for Higher Office",
	category = "government",
	tags = {"career", "politician", "state_politics", "milestone"},
	
	weight = 6,
	cooldownYears = 99,
	oneTime = false,
	milestone = true,
	
	conditions = {
		minAge = 28,
		maxAge = 70,
		requiredCareerId = "politician",
		requiredCareerMinTier = 2,
		requiredAllFlags = {"elected_official"},
	},
	
	getDynamicData = function(state)
		local positions = {"State Representative", "State Senator", "Mayor"}
		return {
			position = positions[math.random(#positions)]
		}
	end,
	
	text = "Your success at the local level opens doors. Party leaders are encouraging you to run for %position%.",
	
	choices = {
		{
			id = "run_higher",
			text = "It's time to move up.",
			resultText = "You launch a campaign for higher office. The stakes are bigger now.",
			effects = {Money = -50000, Happiness = 3},
			flags = {set = {"seeking_higher_office"}},
			careerXP = 35,
		},
		{
			id = "stay_local",
			text = "I prefer staying close to my community.",
			resultText = "You continue serving locally where you can make the most direct impact.",
			effects = {Karma = 2},
			flags = {set = {"committed_to_local"}},
			careerXP = 15,
		},
	},
})

table.insert(events, {
	id = "political_senate_run",
	emoji = "🗽",
	title = "Senate Campaign",
	category = "government",
	tags = {"career", "politician", "senator", "milestone"},
	
	weight = 4,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 35,
		maxAge = 75,
		requiredCareerId = "politician",
		requiredCareerMinTier = 4,
		minStats = {Smarts = 60},
	},
	
	text = "After years of public service, you're positioned to run for the Senate. This is the big leagues.",
	
	choices = {
		{
			id = "run_for_senate",
			text = "This is my moment. I'm running.",
			resultText = "You launch a statewide campaign. It will take everything you have.",
			effects = {Money = -200000, Happiness = 3},
			flags = {set = {"senate_candidate"}},
			careerXP = 50,
		},
	},
})

table.insert(events, {
	id = "political_president_consideration",
	emoji = "🇺🇸",
	title = "The Biggest Stage",
	category = "government",
	tags = {"career", "politician", "president", "milestone"},
	
	weight = 2,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 45,
		maxAge = 75,
		requiredCareerId = "politician",
		requiredCareerMinTier = 5,
		minStats = {Smarts = 70, Karma = 50},
	},
	
	text = "Your name is being mentioned for the highest office in the land. Do you dare to dream that big?",
	
	choices = {
		{
			id = "run_for_president",
			text = "I believe I can lead this nation.",
			resultText = "You announce your candidacy for President. History awaits.",
			effects = {Money = -500000, Happiness = 5},
			flags = {set = {"presidential_candidate"}},
			careerXP = 100,
		},
		{
			id = "support_others",
			text = "I can serve better by supporting the right candidate.",
			resultText = "You become a kingmaker, helping others reach the top.",
			effects = {Karma = 3},
			flags = {set = {"political_kingmaker"}},
			careerXP = 40,
		},
	},
})

return {events = events}
