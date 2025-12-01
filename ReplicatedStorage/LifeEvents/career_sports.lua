-- career_sports.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- SPORTS CAREER EVENTS - Professional Athlete, Coach
-- ═══════════════════════════════════════════════════════════════════════════════

local events = {}

-- ═══════════════════════════════════════════════════════════════
-- ATHLETE ORIGIN EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "sports_natural_talent",
	emoji = "⚽",
	title = "Natural Athlete",
	category = "sports",
	tags = {"career", "athlete", "origin", "youth_sports"},
	
	weight = 12,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	chainId = "athlete_origin",
	chainStep = 1,
	
	conditions = {
		minAge = 8,
		maxAge = 16,
		blockedFlags = {"career_athlete_started", "sports_rejected"},
		minStats = {Health = 40},
	},
	
	getDynamicData = function(state)
		local sports = {"basketball", "football", "soccer", "baseball", "tennis", "swimming"}
		return {
			sport = sports[math.random(#sports)]
		}
	end,
	
	text = "At a youth %sport% tryout, something clicks. You're naturally good - faster, more coordinated than others. Coaches are noticing.",
	
	choices = {
		{
			id = "pursue_sports",
			text = "I want to go pro someday!",
			resultText = "You start training seriously. Early mornings, after-school practice, weekend games.",
			effects = {Health = 5, Happiness = 4},
			flags = {set = {"career_athlete_started", "sports_dream"}},
			startCareer = "athlete",
			careerXP = 15,
		},
		{
			id = "casual_player",
			text = "It's fun, but I want balance.",
			resultText = "You play for fun without the pressure of going pro.",
			effects = {Health = 3, Happiness = 3},
			flags = {set = {"plays_sports"}},
		},
		{
			id = "not_interested",
			text = "Sports aren't really my thing.",
			resultText = "You try other activities instead.",
			effects = {},
			flags = {set = {"sports_rejected"}},
		},
	},
})

table.insert(events, {
	id = "sports_scholarship_offer",
	emoji = "🎓",
	title = "College Scholarship Offer",
	category = "sports",
	tags = {"career", "athlete", "college_sports", "milestone"},
	
	weight = 10,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	chainId = "athlete_career",
	chainStep = 1,
	
	conditions = {
		minAge = 16,
		maxAge = 19,
		requiredCareerId = "athlete",
		requiredCareerMinTier = 2,
		requiredAllFlags = {"sports_dream"},
		minStats = {Health = 60},
	},
	
	getDynamicData = function(state)
		local colleges = {"State University", "Metro College", "National University", "Tech Institute"}
		return {
			college = colleges[math.random(#colleges)]
		}
	end,
	
	text = "%college% is offering you a full athletic scholarship. Free education in exchange for playing on their team. This is huge!",
	
	choices = {
		{
			id = "accept_scholarship",
			text = "Accept! This is the path to the pros.",
			resultText = "You commit to the program. College athletics will test everything you've got.",
			effects = {Happiness = 7},
			flags = {set = {"college_athlete", "full_scholarship"}},
			promoteCareer = true,
			careerXP = 35,
		},
		{
			id = "wait_for_better",
			text = "Wait and see if better offers come.",
			resultText = "You wait, hoping for a bigger program to notice you.",
			effects = {Happiness = 1},
			flags = {set = {"waiting_better_offer"}},
		},
	},
})

table.insert(events, {
	id = "sports_college_star",
	emoji = "⭐",
	title = "College Star",
	category = "sports",
	tags = {"career", "athlete", "college_sports"},
	
	weight = 10,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 19,
		maxAge = 23,
		requiredCareerId = "athlete",
		requiredCareerMinTier = 3,
		requiredAllFlags = {"college_athlete"},
	},
	
	text = "You're having an incredible college season. Sports analysts are talking about you. 'Pro potential,' they say.",
	
	choices = {
		{
			id = "stay_humble",
			text = "Stay focused and keep working.",
			resultText = "You don't let the attention get to your head. The team comes first.",
			effects = {Smarts = 2, Karma = 2},
			flags = {set = {"humble_athlete"}},
			careerXP = 25,
			careerReputation = 15,
		},
		{
			id = "embrace_spotlight",
			text = "Embrace the spotlight. This is my moment!",
			resultText = "You enjoy the attention and start building your personal brand.",
			effects = {Happiness = 4},
			flags = {set = {"flashy_athlete"}},
			careerXP = 20,
		},
	},
})

table.insert(events, {
	id = "sports_draft_day",
	emoji = "📜",
	title = "Draft Day",
	category = "sports",
	tags = {"career", "athlete", "pro_sports", "milestone"},
	
	weight = 8,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 20,
		maxAge = 25,
		requiredCareerId = "athlete",
		requiredCareerMinTier = 3,
		requiredAnyFlags = {"humble_athlete", "flashy_athlete"},
		minStats = {Health = 70},
	},
	
	getDynamicData = function(state)
		local teams = {"the Metro Wolves", "the City Eagles", "the State Spartans", "the Valley Tigers"}
		local round = math.random(1, 5)
		return {
			team = teams[math.random(#teams)],
			round = round,
			contract = math.random(500, 3000) * 1000
		}
	end,
	
	text = "Draft day. You're selected in round %round% by %team%. The contract is worth $%contract%. You made it to the pros!",
	
	choices = {
		{
			id = "celebrate",
			text = "This is the dream come true!",
			resultText = "You sign the contract and begin your professional career.",
			effects = {Money = 100000, Happiness = 10},
			flags = {set = {"professional_athlete", "drafted"}},
			promoteCareer = true,
			careerXP = 50,
		},
	},
})

table.insert(events, {
	id = "sports_major_injury",
	emoji = "🤕",
	title = "Career-Threatening Injury",
	category = "health",
	tags = {"career", "athlete", "injury"},
	
	weight = 6,
	cooldownYears = 5,
	oneTime = false,
	milestone = true,
	
	conditions = {
		minAge = 18,
		maxAge = 45,
		requiredCareerId = "athlete",
		requiredCareerMinTier = 3,
	},
	
	getDynamicData = function(state)
		local injuries = {"ACL tear", "fractured bone", "torn ligament", "concussion protocol"}
		return {
			injury = injuries[math.random(#injuries)]
		}
	end,
	
	text = "During a game, disaster strikes - %injury%. Months of rehab ahead. Some athletes never come back from this.",
	
	choices = {
		{
			id = "fight_back",
			text = "I will come back stronger.",
			resultText = "You dedicate yourself to recovery. The road is long but you're determined.",
			effects = {Health = -20, Happiness = -5},
			flags = {set = {"major_injury", "in_rehab"}},
		},
		{
			id = "face_reality",
			text = "This might be the end of my career.",
			resultText = "You start thinking about life after sports. It's a painful transition.",
			effects = {Health = -15, Happiness = -8},
			flags = {set = {"major_injury", "considering_retirement"}},
		},
	},
})

table.insert(events, {
	id = "sports_comeback",
	emoji = "💪",
	title = "The Comeback",
	category = "sports",
	tags = {"career", "athlete", "comeback"},
	
	weight = 12,
	cooldownYears = 99,
	oneTime = false,
	
	conditions = {
		minAge = 20,
		maxAge = 45,
		requiredCareerId = "athlete",
		requiredAllFlags = {"major_injury", "in_rehab"},
	},
	
	text = "After months of grueling rehab, you're cleared to play. Your first game back, the crowd chants your name.",
	
	choices = {
		{
			id = "strong_return",
			text = "Play the best game of my life.",
			resultText = "You perform beyond everyone's expectations. The comeback is real.",
			effects = {Health = 10, Happiness = 8},
			flags = {set = {"comeback_success"}, clear = {"in_rehab"}},
			careerXP = 40,
			careerReputation = 20,
		},
		{
			id = "cautious_return",
			text = "Take it slow. Don't re-injure.",
			resultText = "You ease back in carefully. It takes time, but you find your form again.",
			effects = {Health = 15, Happiness = 5},
			flags = {set = {"comeback_gradual"}, clear = {"in_rehab"}},
			careerXP = 25,
		},
	},
})

table.insert(events, {
	id = "sports_championship",
	emoji = "🏆",
	title = "Championship Game",
	category = "sports",
	tags = {"career", "athlete", "all_star", "milestone"},
	
	weight = 5,
	cooldownYears = 3,
	oneTime = false,
	milestone = true,
	
	conditions = {
		minAge = 21,
		maxAge = 40,
		requiredCareerId = "athlete",
		requiredCareerMinTier = 5,
		minStats = {Health = 60},
	},
	
	text = "Your team makes it to the championship. Everything you've worked for comes down to this moment.",
	
	choices = {
		{
			id = "clutch_performance",
			text = "Rise to the occasion.",
			resultText = "You deliver when it matters most. Champion!",
			effects = {Money = 50000, Happiness = 10},
			flags = {set = {"champion"}},
			careerXP = 60,
			careerReputation = 30,
		},
		{
			id = "team_effort",
			text = "Trust my teammates.",
			resultText = "Win or lose, you play as a team. That's what matters.",
			effects = {Happiness = 5, Karma = 3},
			flags = {set = {"team_player"}},
			careerXP = 30,
		},
	},
})

table.insert(events, {
	id = "sports_retirement",
	emoji = "👋",
	title = "Hanging Up the Cleats",
	category = "sports",
	tags = {"career", "athlete", "retirement"},
	
	weight = 8,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 30,
		maxAge = 50,
		requiredCareerId = "athlete",
		requiredCareerMinTier = 4,
	},
	
	text = "Your body is telling you it's time. The records, the memories, the championships (or near-misses) - it's been a career worth living.",
	
	choices = {
		{
			id = "retire_gracefully",
			text = "Go out on my own terms.",
			resultText = "You announce your retirement and receive a standing ovation from fans.",
			effects = {Happiness = 5, Karma = 3},
			flags = {set = {"retired_athlete"}},
			quitCareer = true,
		},
		{
			id = "one_more_season",
			text = "One more season. I'm not done yet.",
			resultText = "You push through one more year. Every game counts.",
			effects = {Health = -5, Happiness = 2},
			flags = {set = {"final_season"}},
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- COACH EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "coaching_opportunity",
	emoji = "📋",
	title = "Coaching Call",
	category = "sports",
	tags = {"career", "coach", "origin"},
	
	weight = 8,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 25,
		maxAge = 60,
		requiredAnyFlags = {"retired_athlete", "plays_sports"},
		blockedFlags = {"career_coach_started"},
	},
	
	text = "A local youth team needs a coach. Your sports background makes you a natural fit. Want to give back to the game?",
	
	choices = {
		{
			id = "become_coach",
			text = "I'd love to coach the next generation.",
			resultText = "You start coaching. Seeing young athletes develop is incredibly rewarding.",
			effects = {Happiness = 5, Karma = 4},
			flags = {set = {"career_coach_started", "youth_coach"}},
			startCareer = "coach",
			careerXP = 20,
		},
		{
			id = "not_ready",
			text = "I'm not ready for that responsibility.",
			resultText = "You decline for now. Maybe someday.",
			effects = {},
			flags = {set = {"declined_coaching"}},
		},
	},
})

table.insert(events, {
	id = "coaching_winning_season",
	emoji = "🎉",
	title = "Winning Season",
	category = "sports",
	tags = {"career", "coach"},
	
	weight = 10,
	cooldownYears = 2,
	oneTime = false,
	
	conditions = {
		minAge = 26,
		maxAge = 75,
		requiredCareerId = "coach",
		requiredCareerMinTier = 1,
	},
	
	text = "Your team has an incredible season! The players trust you, the strategies work, and the wins keep coming.",
	
	choices = {
		{
			id = "celebrate_team",
			text = "It's all about the players.",
			resultText = "You deflect credit to your team. They're the real stars.",
			effects = {Happiness = 5, Karma = 3},
			flags = {set = {"humble_coach"}},
			careerXP = 25,
			careerReputation = 15,
		},
		{
			id = "enjoy_success",
			text = "I finally figured out this coaching thing!",
			resultText = "You enjoy the success. Maybe it's time to aim higher.",
			effects = {Happiness = 6},
			flags = {set = {"confident_coach"}},
			careerXP = 20,
		},
	},
})

return {events = events}
