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
	milestone = false, -- Career events should NOT be milestones
	
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
	milestone = false, -- Career events should NOT be milestones
	
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
	milestone = false, -- Career events should NOT be milestones
	
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

-- (Truncated: reinsert remainder of original content)

return {events = events}
