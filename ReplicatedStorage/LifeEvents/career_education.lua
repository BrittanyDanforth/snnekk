-- career_education.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- EDUCATION CAREER EVENTS - Teacher, Professor
-- ═══════════════════════════════════════════════════════════════════════════════

local events = {}

-- ═══════════════════════════════════════════════════════════════
-- TEACHER EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "teaching_inspiration",
	emoji = "📚",
	title = "The Teaching Call",
	category = "life",
	tags = {"career", "teacher", "origin"},
	
	weight = 10,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	chainId = "teacher_origin",
	chainStep = 1,
	
	conditions = {
		minAge = 16,
		maxAge = 40,
		blockedFlags = {"career_teacher_started", "teaching_rejected"},
		minStats = {Smarts = 40},
	},
	
	getDynamicData = function(state)
		local moments = {
			"You tutor a struggling student and watch the lightbulb moment happen.",
			"A teacher who changed your life inspires you to pay it forward.",
			"Volunteering at a school shows you how rewarding education can be."
		}
		return {
			moment = moments[math.random(#moments)]
		}
	end,
	
	text = "%moment% You start thinking about becoming a teacher.",
	
	choices = {
		{
			id = "pursue_teaching",
			text = "I want to shape young minds!",
			resultText = "You start researching education programs and teaching credentials.",
			effects = {Happiness = 3, Karma = 2},
			flags = {set = {"teaching_interest"}},
		},
		{
			id = "not_patient_enough",
			text = "I don't have the patience for that.",
			resultText = "You admire teachers but know it's not the path for you.",
			effects = {},
			flags = {set = {"teaching_rejected"}},
		},
	},
})

table.insert(events, {
	id = "teaching_credential",
	emoji = "📜",
	title = "Get Your Teaching Credential",
	category = "education",
	tags = {"career", "teacher", "origin", "credential"},
	
	weight = 12,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 21,
		maxAge = 55,
		requiredAllFlags = {"teaching_interest"},
		requiredEducation = "bachelor",
		blockedFlags = {"career_teacher_started"},
	},
	
	getDynamicData = function(state)
		local programs = {"a traditional credential program", "an alternative certification path", "Teach For America"}
		return {
			program = programs[math.random(#programs)]
		}
	end,
	
	text = "You enroll in %program% to get your teaching credential. Student teaching awaits!",
	
	choices = {
		{
			id = "complete_credential",
			text = "Get certified and start teaching!",
			resultText = "You complete the program and earn your teaching credential.",
			effects = {Money = -15000, Smarts = 3, Happiness = 4},
			flags = {set = {"career_teacher_started", "teaching_certified"}},
			startCareer = "teacher",
			careerXP = 25,
		},
	},
})

table.insert(events, {
	id = "teaching_first_day",
	emoji = "🏫",
	title = "First Day as a Teacher",
	category = "work",
	tags = {"career", "teacher", "classroom_teaching"},
	
	weight = 15,
	cooldownYears = 99,
	oneTime = true,
	
	conditions = {
		minAge = 22,
		maxAge = 60,
		requiredCareerId = "teacher",
		requiredCareerMinTier = 1,
		requiredAllFlags = {"teaching_certified"},
	},
	
	getDynamicData = function(state)
		return {
			students = math.random(20, 35)
		}
	end,
	
	text = "Your first day as a real teacher. %students% pairs of eyes are looking at you, waiting. This is terrifying and exciting.",
	
	choices = {
		{
			id = "nail_first_day",
			text = "Take a deep breath and own the room.",
			resultText = "You find your teacher voice. The students respond well. You've got this!",
			effects = {Happiness = 5, Smarts = 2},
			flags = {set = {"first_day_success"}},
			careerXP = 20,
		},
		{
			id = "struggle_but_learn",
			text = "Stumble through but learn from mistakes.",
			resultText = "It's messy, but you survive. Every teacher has a rough first day.",
			effects = {Happiness = 2, Smarts = 1},
			flags = {set = {"first_day_struggle"}},
			careerXP = 15,
		},
	},
})

table.insert(events, {
	id = "teaching_difficult_student",
	emoji = "😤",
	title = "The Difficult Student",
	category = "work",
	tags = {"career", "teacher", "classroom_teaching"},
	
	weight = 12,
	cooldownYears = 2,
	oneTime = false,
	
	conditions = {
		minAge = 22,
		maxAge = 70,
		requiredCareerId = "teacher",
		requiredCareerMinTier = 2,
	},
	
	getDynamicData = function(state)
		local names = {"Alex", "Jordan", "Taylor", "Morgan", "Casey"}
		return {
			student = names[math.random(#names)]
		}
	end,
	
	text = "%student% is disrupting your class constantly. Other students are losing learning time. You need to address this.",
	
	choices = {
		{
			id = "connect_personally",
			text = "Try to connect with them personally.",
			resultText = "You spend extra time understanding their situation. Slowly, they start to open up.",
			effects = {Happiness = 2, Karma = 4},
			flags = {set = {"reached_difficult_student"}},
			careerXP = 20,
		},
		{
			id = "strict_discipline",
			text = "Apply strict discipline consistently.",
			resultText = "You set firm boundaries. Some students need structure.",
			effects = {Happiness = 1},
			flags = {set = {"firm_disciplinarian"}},
			careerXP = 10,
		},
		{
			id = "send_to_admin",
			text = "Escalate to administration.",
			resultText = "You involve the principal. The problem moves elsewhere, but did you help?",
			effects = {Karma = -1},
			flags = {set = {}},
			careerXP = 5,
		},
	},
})

table.insert(events, {
	id = "teaching_student_success",
	emoji = "🌟",
	title = "Student Success Story",
	category = "work",
	tags = {"career", "teacher", "experienced_teacher"},
	
	weight = 10,
	cooldownYears = 2,
	oneTime = false,
	
	conditions = {
		minAge = 25,
		maxAge = 70,
		requiredCareerId = "teacher",
		requiredCareerMinTier = 2,
	},
	
	getDynamicData = function(state)
		local achievements = {"got accepted to their dream college", "won a competition they never thought they could", "finally understood a subject they struggled with for years"}
		return {
			achievement = achievements[math.random(#achievements)]
		}
	end,
	
	text = "A former student reaches out to tell you they %achievement%. They credit you as the teacher who believed in them.",
	
	choices = {
		{
			id = "feel_proud",
			text = "This is why I became a teacher.",
			resultText = "You save the message. On hard days, you'll read it again.",
			effects = {Happiness = 6, Karma = 3},
			flags = {set = {"student_success_story"}},
			careerXP = 15,
			careerReputation = 10,
		},
	},
})

table.insert(events, {
	id = "teaching_burnout",
	emoji = "😓",
	title = "Teacher Burnout",
	category = "health",
	tags = {"career", "teacher", "burnout"},
	
	weight = 8,
	cooldownYears = 3,
	oneTime = false,
	
	conditions = {
		minAge = 25,
		maxAge = 65,
		requiredCareerId = "teacher",
		requiredCareerMinTier = 2,
		maxStats = {Happiness = 35},
	},
	
	text = "The endless grading, the difficult parents, the underfunding, the disrespect... you're exhausted. Teaching is hard.",
	
	choices = {
		{
			id = "take_summer",
			text = "Use summer to really recover.",
			resultText = "You actually rest during break instead of prepping. You need it.",
			effects = {Health = 5, Happiness = 5},
			flags = {set = {"teacher_recovered"}},
		},
		{
			id = "push_through",
			text = "The kids need me. Push through.",
			resultText = "You keep going on empty. Your dedication is admirable but costly.",
			effects = {Health = -5, Karma = 2},
			flags = {set = {"martyr_teacher"}},
		},
		{
			id = "leave_teaching",
			text = "I can't do this anymore. I need to leave.",
			resultText = "You resign at the end of the year. It's painful but necessary.",
			effects = {Health = 5, Happiness = 2},
			quitCareer = true,
			flags = {set = {"left_teaching"}},
		},
	},
})

table.insert(events, {
	id = "teaching_promotion",
	emoji = "📋",
	title = "Administrative Opportunity",
	category = "work",
	tags = {"career", "teacher", "school_admin", "milestone"},
	
	weight = 7,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 30,
		maxAge = 60,
		requiredCareerId = "teacher",
		requiredCareerMinTier = 3,
	},
	
	text = "The district offers you an administrative position - Assistant Principal. More pay, but you'd leave the classroom.",
	
	choices = {
		{
			id = "take_admin",
			text = "Move into administration.",
			resultText = "You trade lesson plans for budget meetings. Different challenges, broader impact.",
			effects = {Money = 15000, Happiness = 2},
			flags = {set = {"school_administrator"}},
			promoteCareer = true,
			careerXP = 35,
		},
		{
			id = "stay_classroom",
			text = "Stay in the classroom. That's where I belong.",
			resultText = "You turn down the promotion. Teaching is your calling.",
			effects = {Karma = 3, Happiness = 3},
			flags = {set = {"classroom_teacher_forever"}},
			careerXP = 15,
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- PROFESSOR EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "phd_program_start",
	emoji = "🎓",
	title = "PhD Program",
	category = "education",
	tags = {"career", "professor", "origin", "grad_school"},
	
	weight = 8,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	chainId = "professor_origin",
	chainStep = 1,
	
	conditions = {
		minAge = 22,
		maxAge = 45,
		blockedFlags = {"career_professor_started"},
		requiredEducation = "bachelor",
		minStats = {Smarts = 60},
	},
	
	getDynamicData = function(state)
		local fields = {"Literature", "Physics", "History", "Computer Science", "Psychology", "Economics"}
		local universities = {"State University", "Metropolitan University", "National Research Institute"}
		return {
			field = fields[math.random(#fields)],
			university = universities[math.random(#universities)]
		}
	end,
	
	text = "You're accepted into the %field% PhD program at %university%. Five to seven years of intensive research and teaching await.",
	
	choices = {
		{
			id = "start_phd",
			text = "Begin the academic journey.",
			resultText = "You become a graduate student. The path to professor starts here.",
			effects = {Money = -5000, Smarts = 5, Happiness = 3},
			flags = {set = {"career_professor_started", "phd_student"}},
			startCareer = "professor",
			careerXP = 25,
		},
		{
			id = "reconsider",
			text = "The opportunity cost is too high.",
			resultText = "You decide against academia. There are other paths.",
			effects = {},
			flags = {set = {}},
		},
	},
})

table.insert(events, {
	id = "phd_dissertation",
	emoji = "📝",
	title = "Dissertation Defense",
	category = "education",
	tags = {"career", "professor", "phd_research", "milestone"},
	
	weight = 15,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 26,
		maxAge = 55,
		requiredCareerId = "professor",
		requiredCareerMinTier = 1,
		requiredAllFlags = {"phd_student"},
	},
	
	text = "After years of research, you defend your dissertation before a committee of experts. They question every aspect of your work.",
	
	choices = {
		{
			id = "defend_successfully",
			text = "Defend your research confidently.",
			resultText = "You answer every question. The committee congratulates you - you're now Dr. You.",
			effects = {Smarts = 5, Happiness = 8},
			flags = {set = {"phd_earned", "doctor_title"}, clear = {"phd_student"}},
			promoteCareer = true,
			careerXP = 50,
		},
	},
})

table.insert(events, {
	id = "professor_tenure_track",
	emoji = "🏛️",
	title = "Tenure-Track Position",
	category = "work",
	tags = {"career", "professor", "assistant_professor", "milestone"},
	
	weight = 10,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 28,
		maxAge = 55,
		requiredCareerId = "professor",
		requiredCareerMinTier = 2,
		requiredAllFlags = {"phd_earned"},
	},
	
	getDynamicData = function(state)
		local universities = {"Regional University", "State College", "Research University", "Liberal Arts College"}
		return {
			university = universities[math.random(#universities)]
		}
	end,
	
	text = "%university% offers you a tenure-track assistant professor position. Six years to prove yourself worthy of lifetime job security.",
	
	choices = {
		{
			id = "accept_position",
			text = "Accept and begin the tenure clock.",
			resultText = "You start as an assistant professor. Publish or perish - the clock is ticking.",
			effects = {Money = 10000, Happiness = 5},
			flags = {set = {"tenure_track"}},
			promoteCareer = true,
			careerXP = 40,
		},
	},
})

table.insert(events, {
	id = "professor_publish",
	emoji = "📰",
	title = "Publish or Perish",
	category = "work",
	tags = {"career", "professor", "assistant_professor", "research"},
	
	weight = 12,
	cooldownYears = 2,
	oneTime = false,
	
	conditions = {
		minAge = 28,
		maxAge = 70,
		requiredCareerId = "professor",
		requiredCareerMinTier = 3,
		requiredAllFlags = {"tenure_track"},
	},
	
	text = "The pressure to publish research is immense. Your tenure case depends on a strong publication record.",
	
	choices = {
		{
			id = "publish_success",
			text = "Your paper gets accepted to a top journal!",
			resultText = "Your research makes waves in the field. One step closer to tenure.",
			effects = {Smarts = 3, Happiness = 5},
			flags = {set = {"published_paper"}},
			careerXP = 30,
			careerReputation = 15,
		},
		{
			id = "rejected_revise",
			text = "Rejected, but with helpful feedback.",
			resultText = "Back to the drawing board. Revision is part of the process.",
			effects = {Happiness = -2, Smarts = 1},
			flags = {set = {}},
			careerXP = 10,
		},
	},
})

table.insert(events, {
	id = "professor_tenure",
	emoji = "🎉",
	title = "Tenure Decision",
	category = "work",
	tags = {"career", "professor", "associate_professor", "milestone"},
	
	weight = 8,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 34,
		maxAge = 60,
		requiredCareerId = "professor",
		requiredCareerMinTier = 3,
		requiredAllFlags = {"tenure_track", "published_paper"},
	},
	
	text = "After six years, the tenure committee meets to decide your fate. Your career hangs in the balance.",
	
	choices = {
		{
			id = "tenure_granted",
			text = "Tenure granted! You made it!",
			resultText = "Job security for life. You can now pursue the research that truly matters to you.",
			effects = {Happiness = 10, Money = 15000},
			flags = {set = {"tenured_professor"}, clear = {"tenure_track"}},
			promoteCareer = true,
			careerXP = 60,
			careerReputation = 25,
		},
		{
			id = "tenure_denied",
			text = "Tenure denied. You have to leave.",
			resultText = "Devastation. After years of work, you have to find a new position elsewhere.",
			effects = {Happiness = -10},
			flags = {set = {"tenure_denied"}, clear = {"tenure_track"}},
			quitCareer = true,
		},
	},
})

return {events = events}
