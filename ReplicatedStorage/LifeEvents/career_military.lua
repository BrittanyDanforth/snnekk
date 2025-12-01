-- career_military.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- MILITARY CAREER EVENTS - Enlisted, Officer paths
-- ═══════════════════════════════════════════════════════════════════════════════

local events = {}

-- ═══════════════════════════════════════════════════════════════
-- ENLISTMENT / ORIGIN EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "military_enlistment",
	emoji = "🎖️",
	title = "Join the Military?",
	category = "life",
	tags = {"career", "military", "origin"},
	
	weight = 10,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	chainId = "military_origin",
	chainStep = 1,
	
	conditions = {
		minAge = 17,
		maxAge = 35,
		blockedFlags = {"career_military_started", "military_rejected"},
		minStats = {Health = 50},
	},
	
	getDynamicData = function(state)
		local recruiters = {"at a mall", "at your school", "through a friend who enlisted", "from an online ad"}
		return {
			source = recruiters[math.random(#recruiters)]
		}
	end,
	
	text = "A military recruiter you met %source% explains the benefits: job security, travel, education funding, and a chance to serve your country.",
	
	choices = {
		{
			id = "enlist",
			text = "Sign up and serve my country.",
			resultText = "You enlist and begin the journey toward basic training.",
			effects = {Happiness = 3, Karma = 3},
			flags = {set = {"career_military_started", "enlisting"}},
			startCareer = "military",
			careerXP = 15,
		},
		{
			id = "officer_route",
			text = "Ask about officer training programs.",
			resultText = "The recruiter explains ROTC and officer candidate school options.",
			effects = {Smarts = 1},
			flags = {set = {"considering_officer"}},
		},
		{
			id = "not_for_me",
			text = "Military life isn't for me.",
			resultText = "You thank them but decline. There are other ways to serve.",
			effects = {},
			flags = {set = {"military_rejected"}},
		},
	},
})

table.insert(events, {
	id = "military_basic_training",
	emoji = "💪",
	title = "Basic Training",
	category = "military",
	tags = {"career", "military", "basic_training"},
	
	weight = 20,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 17,
		maxAge = 40,
		requiredCareerId = "military",
		requiredCareerMinTier = 1,
		requiredAllFlags = {"enlisting"},
	},
	
	text = "Basic training is brutal. Early mornings, intense physical training, drill sergeants in your face. You're pushed to your limits.",
	
	choices = {
		{
			id = "push_through",
			text = "Push through and graduate.",
			resultText = "You make it through basic. You're officially a soldier now.",
			effects = {Health = 10, Happiness = 4, Smarts = 2},
			flags = {set = {"basic_training_complete"}, clear = {"enlisting"}},
			promoteCareer = true,
			careerXP = 35,
		},
		{
			id = "struggle",
			text = "Struggle but don't quit.",
			resultText = "It's the hardest thing you've ever done, but you refuse to ring that bell.",
			effects = {Health = 5, Happiness = 2},
			flags = {set = {"basic_training_complete"}, clear = {"enlisting"}},
			promoteCareer = true,
			careerXP = 30,
		},
	},
})

table.insert(events, {
	id = "military_deployment",
	emoji = "✈️",
	title = "First Deployment",
	category = "military",
	tags = {"career", "military", "deployment"},
	
	weight = 12,
	cooldownYears = 3,
	oneTime = false,
	
	conditions = {
		minAge = 18,
		maxAge = 55,
		requiredCareerId = "military",
		requiredCareerMinTier = 2,
		requiredAllFlags = {"basic_training_complete"},
	},
	
	getDynamicData = function(state)
		local locations = {"overseas", "to a forward base", "for a peacekeeping mission", "to support allies"}
		return {
			location = locations[math.random(#locations)]
		}
	end,
	
	text = "You receive orders for deployment %location%. This is what you trained for. Time to serve for real.",
	
	choices = {
		{
			id = "serve_proudly",
			text = "Deploy and serve with honor.",
			resultText = "You complete your deployment. The experience changes you.",
			effects = {Health = -5, Happiness = -2, Karma = 5},
			flags = {set = {"deployed_overseas"}},
			careerXP = 40,
			careerReputation = 20,
		},
	},
})

table.insert(events, {
	id = "military_promotion",
	emoji = "⭐",
	title = "Promotion Board",
	category = "military",
	tags = {"career", "military", "nco"},
	
	weight = 10,
	cooldownYears = 3,
	oneTime = false,
	
	conditions = {
		minAge = 21,
		maxAge = 50,
		requiredCareerId = "military",
		requiredCareerMinTier = 2,
	},
	
	getDynamicData = function(state)
		local ranks = {"Sergeant", "Staff Sergeant", "Sergeant First Class"}
		return {
			rank = ranks[math.random(#ranks)]
		}
	end,
	
	text = "You're up for promotion to %rank%. The board will review your record and interview you.",
	
	choices = {
		{
			id = "promoted",
			text = "You get promoted!",
			resultText = "You pin on your new rank. More responsibility, more respect, slightly better pay.",
			effects = {Money = 5000, Happiness = 5},
			flags = {set = {"promoted_nco"}},
			promoteCareer = true,
			careerXP = 30,
		},
		{
			id = "passed_over",
			text = "Passed over this time.",
			resultText = "Not this time. Keep working and try again next cycle.",
			effects = {Happiness = -3},
			flags = {set = {"passed_over"}},
			careerXP = 10,
		},
	},
})

table.insert(events, {
	id = "military_injury",
	emoji = "🩹",
	title = "Service-Related Injury",
	category = "health",
	tags = {"career", "military", "injury"},
	
	weight = 6,
	cooldownYears = 5,
	oneTime = false,
	
	conditions = {
		minAge = 18,
		maxAge = 60,
		requiredCareerId = "military",
		requiredCareerMinTier = 2,
	},
	
	text = "During training or deployment, you sustain an injury. The military doctors assess whether you can continue serving.",
	
	choices = {
		{
			id = "full_recovery",
			text = "Recover and return to duty.",
			resultText = "After rehab, you're cleared to continue your military career.",
			effects = {Health = -10},
			flags = {set = {"service_injury"}},
		},
		{
			id = "medical_discharge",
			text = "The injury ends your military career.",
			resultText = "You receive a medical discharge. The service honors your sacrifice.",
			effects = {Health = -20, Happiness = -5},
			flags = {set = {"medical_discharge"}},
			quitCareer = true,
		},
	},
})

table.insert(events, {
	id = "military_retirement",
	emoji = "🎗️",
	title = "Military Retirement",
	category = "military",
	tags = {"career", "military", "retirement"},
	
	weight = 8,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 38,
		maxAge = 65,
		requiredCareerId = "military",
		requiredCareerMinTier = 3,
	},
	
	text = "After years of service, you're eligible for retirement. Full benefits, pension, and a ceremony to honor your dedication.",
	
	choices = {
		{
			id = "retire_with_honors",
			text = "Retire with full honors.",
			resultText = "You hang up the uniform. The nation thanks you for your service.",
			effects = {Happiness = 6, Karma = 5, Money = 30000},
			flags = {set = {"military_retired"}},
			quitCareer = true,
		},
		{
			id = "keep_serving",
			text = "Re-enlist for more years.",
			resultText = "You're not ready to leave. The military is your family.",
			effects = {Happiness = 2},
			flags = {set = {"career_military"}},
			careerXP = 20,
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- OFFICER PATH EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "military_ocs",
	emoji = "🎓",
	title = "Officer Candidate School",
	category = "military",
	tags = {"career", "military", "junior_officer", "officer"},
	
	weight = 10,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 21,
		maxAge = 35,
		requiredAnyFlags = {"considering_officer", "career_military_started"},
		requiredEducation = "bachelor",
		minStats = {Smarts = 50, Health = 50},
	},
	
	text = "You're accepted into Officer Candidate School. Twelve weeks of intense training to earn your commission as an officer.",
	
	choices = {
		{
			id = "complete_ocs",
			text = "Complete OCS and become an officer.",
			resultText = "You earn your commission and become a Second Lieutenant. Leadership awaits.",
			effects = {Smarts = 5, Happiness = 5},
			flags = {set = {"commissioned_officer", "career_military_started"}},
			startCareer = "military",
			careerBranch = "officer",
			careerXP = 40,
		},
	},
})

table.insert(events, {
	id = "military_command",
	emoji = "🏅",
	title = "Command Opportunity",
	category = "military",
	tags = {"career", "military", "company_command", "officer"},
	
	weight = 8,
	cooldownYears = 5,
	oneTime = false,
	
	conditions = {
		minAge = 26,
		maxAge = 55,
		requiredCareerId = "military",
		requiredCareerMinTier = 3,
		requiredAllFlags = {"commissioned_officer"},
	},
	
	text = "You're selected for command - you'll be responsible for an entire unit of soldiers.",
	
	choices = {
		{
			id = "lead_well",
			text = "Lead with honor and take care of your people.",
			resultText = "Your unit thrives under your leadership. You're making a real difference.",
			effects = {Happiness = 5, Karma = 4},
			flags = {set = {"successful_commander"}},
			promoteCareer = true,
			careerXP = 45,
			careerReputation = 25,
		},
	},
})

return {events = events}
