-- career_legal.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- LEGAL CAREER EVENTS - Lawyer, Judge
-- ═══════════════════════════════════════════════════════════════════════════════

local events = {}

-- ═══════════════════════════════════════════════════════════════
-- LAWYER EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "law_school_accepted",
	emoji = "⚖️",
	title = "Law School Admission",
	category = "education",
	tags = {"career", "lawyer", "origin", "law_school"},
	
	weight = 10,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	chainId = "lawyer_origin",
	chainStep = 1,
	
	conditions = {
		minAge = 21,
		maxAge = 40,
		blockedFlags = {"career_lawyer_started"},
		requiredEducation = "bachelor",
		minStats = {Smarts = 55},
	},
	
	getDynamicData = function(state)
		local schools = {"Metropolitan Law School", "State Law Academy", "National Legal Institute", "Capital University Law"}
		return {
			school = schools[math.random(#schools)]
		}
	end,
	
	text = "You've been accepted to %school%! Three years of intense study, mountains of debt, but the potential to change lives through law.",
	
	choices = {
		{
			id = "accept_law",
			text = "I'm ready to become a lawyer!",
			resultText = "You begin the long journey through law school. Case briefs become your life.",
			effects = {Money = -80000, Smarts = 5, Happiness = 3},
			flags = {set = {"career_lawyer_started", "law_student"}},
			startCareer = "lawyer",
			careerXP = 20,
		},
		{
			id = "defer",
			text = "Defer for a year to prepare.",
			resultText = "You take a year to save money and mentally prepare for the grind.",
			effects = {Happiness = 1},
			flags = {set = {"law_deferred"}},
		},
	},
})

table.insert(events, {
	id = "law_school_moot_court",
	emoji = "🏛️",
	title = "Moot Court Competition",
	category = "school",
	tags = {"career", "lawyer", "law_school"},
	
	weight = 12,
	cooldownYears = 99,
	oneTime = true,
	
	conditions = {
		minAge = 22,
		maxAge = 45,
		requiredCareerId = "lawyer",
		requiredCareerMinTier = 1,
		requiredAllFlags = {"law_student"},
	},
	
	text = "You enter the moot court competition - arguing mock cases before fake judges. It's terrifying and exhilarating.",
	
	choices = {
		{
			id = "win_competition",
			text = "Argue your heart out.",
			resultText = "You make compelling arguments and win the competition! Recruiters take notice.",
			effects = {Smarts = 4, Happiness = 5},
			flags = {set = {"moot_court_winner"}},
			careerXP = 25,
			careerReputation = 10,
		},
		{
			id = "learn_from_loss",
			text = "You lose, but learn valuable lessons.",
			resultText = "You don't win, but you grow as an advocate. That's what law school is for.",
			effects = {Smarts = 3, Happiness = 1},
			flags = {set = {"moot_court_participant"}},
			careerXP = 15,
		},
	},
})

table.insert(events, {
	id = "law_bar_exam",
	emoji = "📜",
	title = "The Bar Exam",
	category = "education",
	tags = {"career", "lawyer", "bar_exam", "milestone"},
	
	weight = 15,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 24,
		maxAge = 50,
		requiredCareerId = "lawyer",
		requiredCareerMinTier = 1,
		requiredAllFlags = {"law_student"},
	},
	
	text = "The bar exam - the final boss of becoming a lawyer. Two days of grueling tests. Years of preparation come down to this.",
	
	choices = {
		{
			id = "pass_bar",
			text = "You pass! You're officially a lawyer!",
			resultText = "Years of work pay off. You can now practice law and represent clients.",
			effects = {Happiness = 8, Smarts = 3},
			flags = {set = {"bar_passed", "licensed_lawyer"}, clear = {"law_student"}},
			promoteCareer = true,
			careerXP = 40,
		},
		{
			id = "fail_bar",
			text = "You fail and have to retake it.",
			resultText = "Devastation. But many great lawyers failed their first attempt. You'll try again.",
			effects = {Happiness = -6, Money = -3000},
			flags = {set = {"bar_failed_once"}},
		},
	},
})

table.insert(events, {
	id = "law_first_case",
	emoji = "👔",
	title = "First Real Case",
	category = "work",
	tags = {"career", "lawyer", "junior_lawyer"},
	
	weight = 12,
	cooldownYears = 99,
	oneTime = true,
	
	conditions = {
		minAge = 25,
		maxAge = 55,
		requiredCareerId = "lawyer",
		requiredCareerMinTier = 2,
		requiredAllFlags = {"licensed_lawyer"},
	},
	
	text = "Your first case as lead attorney. A real client depending on you. Everything you learned gets put to the test.",
	
	choices = {
		{
			id = "win_case",
			text = "Prepare exhaustively and win.",
			resultText = "Your preparation pays off. You win the case and your client is grateful.",
			effects = {Happiness = 6, Money = 5000, Karma = 2},
			flags = {set = {"first_case_won"}},
			careerXP = 30,
			careerReputation = 15,
		},
		{
			id = "lose_learn",
			text = "You lose, but handle it with grace.",
			resultText = "Not every case can be won. You learn from the loss and move forward.",
			effects = {Happiness = -2, Smarts = 2},
			flags = {set = {"first_case_lost"}},
			careerXP = 15,
		},
	},
})

table.insert(events, {
	id = "law_career_path_choice",
	emoji = "🔀",
	title = "Legal Specialization",
	category = "work",
	tags = {"career", "lawyer", "branch_choice"},
	
	weight = 10,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 26,
		maxAge = 45,
		requiredCareerId = "lawyer",
		requiredCareerMinTier = 2,
		blockedFlags = {"law_specialization_chosen"},
	},
	
	text = "It's time to specialize. What kind of lawyer do you want to be?",
	
	choices = {
		{
			id = "corporate_law",
			text = "Corporate law - big money, big clients.",
			resultText = "You join a corporate firm. The hours are long but the paychecks are fat.",
			effects = {Money = 30000, Happiness = 2},
			flags = {set = {"law_specialization_chosen", "corporate_lawyer"}},
			careerBranch = "corporate",
			careerXP = 25,
		},
		{
			id = "criminal_defense",
			text = "Criminal defense - fight for the accused.",
			resultText = "You become a defense attorney, ensuring everyone gets fair representation.",
			effects = {Karma = 3, Happiness = 3},
			flags = {set = {"law_specialization_chosen", "criminal_defense_lawyer"}},
			careerBranch = "criminal_defense",
			careerXP = 25,
		},
		{
			id = "public_interest",
			text = "Public interest - help those who need it most.",
			resultText = "You take a lower salary to serve the public good. Not all value is monetary.",
			effects = {Karma = 5, Happiness = 4, Money = -10000},
			flags = {set = {"law_specialization_chosen", "public_interest_lawyer"}},
			careerBranch = "public_interest",
			careerXP = 25,
		},
	},
})

table.insert(events, {
	id = "law_partner_offer",
	emoji = "🎩",
	title = "Partner Track",
	category = "work",
	tags = {"career", "lawyer", "law_partner", "milestone"},
	
	weight = 6,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 32,
		maxAge = 55,
		requiredCareerId = "lawyer",
		requiredCareerMinTier = 3,
		requiredAllFlags = {"corporate_lawyer"},
	},
	
	text = "After years of billing hours and winning cases, the firm offers you partnership. Equity stake, your name on the door.",
	
	choices = {
		{
			id = "accept_partner",
			text = "Accept and become a partner.",
			resultText = "You're a partner now. More responsibility, more money, more prestige.",
			effects = {Money = 100000, Happiness = 6},
			flags = {set = {"law_firm_partner"}},
			promoteCareer = true,
			careerXP = 50,
		},
		{
			id = "start_own_firm",
			text = "Decline and start your own firm.",
			resultText = "You go solo. Terrifying, but the freedom is worth it.",
			effects = {Money = -50000, Happiness = 5},
			flags = {set = {"solo_practitioner"}},
			careerXP = 40,
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- JUDGE EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "judicial_appointment",
	emoji = "🧑‍⚖️",
	title = "Judicial Appointment",
	category = "work",
	tags = {"career", "judge", "origin", "milestone"},
	
	weight = 4,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 35,
		maxAge = 65,
		requiredCareerId = "lawyer",
		requiredCareerMinTier = 3,
		requiredAllFlags = {"licensed_lawyer"},
		minStats = {Karma = 50},
	},
	
	text = "Based on your legal career and reputation, you're offered a judicial appointment. You could become a judge.",
	
	choices = {
		{
			id = "become_judge",
			text = "Accept the appointment. It's an honor.",
			resultText = "You trade your practice for the bench. Now you dispense justice itself.",
			effects = {Happiness = 7, Karma = 3},
			flags = {set = {"career_judge_started"}},
			startCareer = "judge",
			careerXP = 40,
		},
		{
			id = "stay_practicing",
			text = "Stay a practicing lawyer.",
			resultText = "You decline the judicial role. The courtroom is where you belong.",
			effects = {Happiness = 2},
			flags = {set = {"declined_judgeship"}},
		},
	},
})

return {events = events}
