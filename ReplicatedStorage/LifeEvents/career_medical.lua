-- career_medical.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- MEDICAL CAREER EVENTS - Doctor, Nurse, Surgeon
-- ═══════════════════════════════════════════════════════════════════════════════
-- 
-- Contains events for:
-- - Doctor path (from med school to department head)
-- - Nurse path
-- - Surgeon specialization
-- - General medical industry events
--
-- ═══════════════════════════════════════════════════════════════════════════════

local events = {}

-- ═══════════════════════════════════════════════════════════════
-- MEDICAL ORIGIN / DISCOVERY EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "medical_inspiration",
	emoji = "🏥",
	title = "A Life Changed",
	category = "life",
	tags = {"career", "medical", "origin"},
	
	weight = 10,
	cooldownYears = 99,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	chainId = "medical_origin",
	chainStep = 1,
	
	conditions = {
		minAge = 10,
		maxAge = 22,
		blockedFlags = {"medical_interest_sparked", "medical_rejected"},
		minStats = {Smarts = 40},
	},
	
	getDynamicData = function(state)
		local scenarios = {
			"A family member gets seriously ill. Watching the doctors work to save them leaves a deep impression.",
			"You volunteer at a hospital for a school project. The work is harder than you expected, but also more meaningful.",
			"A medical show on TV sparks your curiosity. You start reading about how the human body actually works."
		}
		return {
			scenario = scenarios[math.random(#scenarios)]
		}
	end,
	
	text = "%scenario%",
	
	choices = {
		{
			id = "inspired",
			text = "I want to help people like this someday.",
			resultText = "You start paying more attention in science class and looking into what it takes to become a doctor.",
			effects = {Smarts = 2, Happiness = 2, Karma = 2},
			flags = {set = {"medical_interest_sparked", "wants_to_be_doctor"}},
		},
		{
			id = "nursing_interest",
			text = "The nurses seem to really make a difference.",
			resultText = "You notice how nurses are the ones who spend the most time with patients, comforting them.",
			effects = {Smarts = 1, Happiness = 2, Karma = 3},
			flags = {set = {"medical_interest_sparked", "wants_to_be_nurse"}},
		},
		{
			id = "not_for_me",
			text = "This is too intense for me.",
			resultText = "You decide medicine isn't your calling. That's okay - not everyone is cut out for it.",
			effects = {},
			flags = {set = {"medical_rejected"}},
		},
	},
})

table.insert(events, {
	id = "pre_med_grind",
	emoji = "📚",
	title = "The Pre-Med Grind",
	category = "school",
	tags = {"career", "medical", "education"},
	
	weight = 15,
	cooldownYears = 99,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	chainId = "medical_origin",
	chainStep = 2,
	
	conditions = {
		minAge = 18,
		maxAge = 26,
		requiredAllFlags = {"wants_to_be_doctor"},
		requiredEducation = "high_school",
		minStats = {Smarts = 50},
	},
	
	text = "College pre-med courses are brutal. Organic chemistry alone has broken many dreams. Everyone around you is competitive, stressed, and running on caffeine.",
	
	choices = {
		{
			id = "embrace_grind",
			text = "I'll work harder than everyone else.",
			resultText = "You study constantly. Your social life suffers, but your grades don't.",
			effects = {Smarts = 5, Happiness = -3},
			flags = {set = {"pre_med_survivor"}},
		},
		{
			id = "find_balance",
			text = "I need to find some balance.",
			resultText = "You study hard but also make time for friends. Your grades are good, not perfect.",
			effects = {Smarts = 3, Happiness = 1},
			flags = {set = {"pre_med_balanced"}},
		},
		{
			id = "switch_paths",
			text = "Maybe I should look at other healthcare careers.",
			resultText = "You decide the doctor path isn't for you, but stay interested in healthcare.",
			effects = {Happiness = 2},
			flags = {set = {"considering_other_healthcare"}, clear = {"wants_to_be_doctor"}},
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- MEDICAL SCHOOL EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "medical_school_accepted",
	emoji = "📬",
	title = "Medical School Acceptance",
	category = "education",
	tags = {"career", "medical", "doctor", "milestone"},
	
	weight = 12,
	cooldownYears = 99,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	chainId = "doctor_career",
	chainStep = 1,
	
	conditions = {
		minAge = 21,
		maxAge = 35,
		requiredAllFlags = {"pre_med_survivor"},
		requiredEducation = "bachelor",
		minStats = {Smarts = 60},
	},
	
	getDynamicData = function(state)
		local schools = {"Metropolitan Medical School", "University of Health Sciences", "National Medical Academy", "Central Medical Institute"}
		return {
			school = schools[math.random(#schools)]
		}
	end,
	
	text = "The letter arrives. %school% has accepted you to their medical program! Four years of intense training ahead. This is really happening.",
	
	choices = {
		{
			id = "accept_immediately",
			text = "Accept immediately. This is my dream!",
			resultText = "You're officially a medical student. The hardest years of your life are about to begin.",
			effects = {Happiness = 8, Money = -50000},
			flags = {set = {"medical_student", "career_doctor_started"}},
			startCareer = "doctor",
			careerXP = 20,
		},
		{
			id = "negotiate_aid",
			text = "Accept, but first negotiate financial aid.",
			resultText = "You secure some scholarships and loans. Still expensive, but manageable.",
			effects = {Happiness = 6, Money = -35000},
			flags = {set = {"medical_student", "career_doctor_started", "med_school_scholarship"}},
			startCareer = "doctor",
			careerXP = 15,
		},
	},
})

table.insert(events, {
	id = "med_school_anatomy",
	emoji = "🔬",
	title = "First Anatomy Lab",
	category = "school",
	tags = {"career", "medical", "doctor", "med_school"},
	
	weight = 12,
	cooldownYears = 99,
	oneTime = true,
	
	conditions = {
		minAge = 22,
		maxAge = 40,
		requiredCareerId = "doctor",
		requiredCareerMinTier = 1,
		requiredAllFlags = {"medical_student"},
	},
	
	text = "Your first day in the anatomy lab. You're about to work with a real cadaver. Some classmates look pale already.",
	
	choices = {
		{
			id = "handle_it",
			text = "Stay professional and focused.",
			resultText = "You approach it clinically. This is what you signed up for. You do well.",
			effects = {Smarts = 3, Happiness = 1},
			flags = {set = {"anatomy_done"}},
			careerXP = 15,
		},
		{
			id = "struggle_through",
			text = "It's harder than expected, but push through.",
			resultText = "You feel queasy but don't show it. You get through the session and feel proud.",
			effects = {Smarts = 2, Health = -1},
			flags = {set = {"anatomy_done", "anatomy_struggle"}},
			careerXP = 10,
		},
	},
})

table.insert(events, {
	id = "med_school_clinical_rotations",
	emoji = "👨‍⚕️",
	title = "Clinical Rotations Begin",
	category = "school",
	tags = {"career", "medical", "doctor", "med_school"},
	
	weight = 10,
	cooldownYears = 99,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	conditions = {
		minAge = 24,
		maxAge = 40,
		requiredCareerId = "doctor",
		requiredCareerMinTier = 1,
		requiredAllFlags = {"anatomy_done"},
	},
	
	text = "Third year of med school: clinical rotations. You'll rotate through different specialties - surgery, pediatrics, psychiatry, internal medicine. Which one calls to you?",
	
	choices = {
		{
			id = "love_surgery",
			text = "Surgery is intense but exhilarating.",
			resultText = "The OR feels like home. You love the precision and the immediate impact.",
			effects = {Smarts = 2, Happiness = 3},
			flags = {set = {"interested_surgery"}},
			careerXP = 20,
		},
		{
			id = "love_internal",
			text = "Internal medicine - solving medical puzzles.",
			resultText = "You enjoy figuring out what's wrong with patients. Like being a detective.",
			effects = {Smarts = 3, Happiness = 2},
			flags = {set = {"interested_internal"}},
			careerXP = 20,
		},
		{
			id = "love_pediatrics",
			text = "Pediatrics - helping kids is so rewarding.",
			resultText = "Working with children is challenging but incredibly fulfilling.",
			effects = {Happiness = 4, Karma = 2},
			flags = {set = {"interested_pediatrics"}},
			careerXP = 20,
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- RESIDENCY EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "residency_match",
	emoji = "✉️",
	title = "Match Day",
	category = "work",
	tags = {"career", "medical", "doctor", "residency", "milestone"},
	
	weight = 15,
	cooldownYears = 99,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	conditions = {
		minAge = 25,
		maxAge = 40,
		requiredCareerId = "doctor",
		requiredCareerMinTier = 1,
		requiredAnyFlags = {"interested_surgery", "interested_internal", "interested_pediatrics"},
	},
	
	getDynamicData = function(state)
		local hospitals = {"City General Hospital", "University Medical Center", "Memorial Hospital", "Regional Medical Center"}
		return {
			hospital = hospitals[math.random(#hospitals)]
		}
	end,
	
	text = "Match Day - the envelope that determines where you'll spend the next 3-7 years of your life. You matched at %hospital%!",
	
	choices = {
		{
			id = "excited_match",
			text = "This is perfect! Let's do this!",
			resultText = "You move and start your residency. The real training begins now.",
			effects = {Happiness = 6},
			flags = {set = {"residency_started"}},
			promoteCareer = true,
			careerXP = 30,
		},
		{
			id = "disappointed_match",
			text = "Not my first choice, but I'll make it work.",
			resultText = "It wasn't your dream hospital, but you're determined to succeed anyway.",
			effects = {Happiness = 2},
			flags = {set = {"residency_started", "underdog_motivation"}},
			promoteCareer = true,
			careerXP = 25,
		},
	},
})

table.insert(events, {
	id = "residency_hell",
	emoji = "😴",
	title = "Resident Life",
	category = "work",
	tags = {"career", "medical", "doctor", "residency"},
	
	weight = 12,
	cooldownYears = 1,
	oneTime = false,
	
	conditions = {
		minAge = 26,
		maxAge = 45,
		requiredCareerId = "doctor",
		requiredCareerMinTier = 2,
		requiredAllFlags = {"residency_started"},
	},
	
	getDynamicData = function(state)
		return {
			hours = math.random(70, 100),
		}
	end,
	
	text = "Another %hours%-hour week. You've lost count of how many cups of coffee you've had. A patient codes at 3 AM and you're there to help save them.",
	
	choices = {
		{
			id = "this_is_why",
			text = "This is why I became a doctor.",
			resultText = "Despite the exhaustion, saving lives makes it all worth it.",
			effects = {Health = -3, Happiness = 3, Karma = 3},
			flags = {set = {"residency_dedicated"}},
			careerXP = 20,
		},
		{
			id = "burning_out",
			text = "I'm barely holding it together.",
			resultText = "You push through, but the toll is real. You start counting down the days.",
			effects = {Health = -5, Happiness = -3},
			flags = {set = {"residency_struggling"}},
			careerXP = 15,
		},
	},
})

table.insert(events, {
	id = "residency_first_death",
	emoji = "💔",
	title = "First Patient Loss",
	category = "work",
	tags = {"career", "medical", "doctor", "emotional"},
	
	weight = 8,
	cooldownYears = 99,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	conditions = {
		minAge = 26,
		maxAge = 50,
		requiredCareerId = "doctor",
		requiredCareerMinTier = 2,
		requiredAllFlags = {"residency_started"},
	},
	
	text = "Despite everyone's best efforts, a patient you worked hard to save doesn't make it. The attending puts a hand on your shoulder. 'You did everything right. Sometimes, it's just not enough.'",
	
	choices = {
		{
			id = "process_grief",
			text = "Take time to process this.",
			resultText = "You let yourself feel the loss. It's part of being a doctor, but it never gets easy.",
			effects = {Happiness = -4, Karma = 2},
			flags = {set = {"first_patient_loss", "emotionally_aware"}},
			careerXP = 15,
		},
		{
			id = "compartmentalize",
			text = "Compartmentalize and keep working.",
			resultText = "You bury the feelings and focus on your other patients. The work must go on.",
			effects = {Happiness = -2, Health = -1},
			flags = {set = {"first_patient_loss", "emotionally_guarded"}},
			careerXP = 10,
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- ATTENDING / PRACTICING DOCTOR EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "attending_position",
	emoji = "🎓",
	title = "Residency Complete",
	category = "work",
	tags = {"career", "medical", "doctor", "attending_doctor", "milestone"},
	
	weight = 15,
	cooldownYears = 99,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	conditions = {
		minAge = 29,
		maxAge = 50,
		requiredCareerId = "doctor",
		requiredCareerMinTier = 2,
		requiredAllFlags = {"residency_started", "first_patient_loss"},
	},
	
	getDynamicData = function(state)
		local specialties = {"internal medicine", "cardiology", "pediatrics", "emergency medicine"}
		return {
			specialty = specialties[math.random(#specialties)]
		}
	end,
	
	text = "After years of grueling training, you've completed your residency in %specialty%. You're now a fully licensed attending physician. Dr. You.",
	
	choices = {
		{
			id = "hospital_job",
			text = "Accept a position at a hospital.",
			resultText = "You join a hospital as an attending. The salary is finally real, and so is the responsibility.",
			effects = {Money = 50000, Happiness = 7},
			flags = {set = {"attending_physician"}},
			promoteCareer = true,
			careerXP = 40,
		},
		{
			id = "private_practice",
			text = "Consider opening a private practice.",
			resultText = "You start thinking about being your own boss. More risk, potentially more reward.",
			effects = {Money = 20000, Happiness = 5},
			flags = {set = {"attending_physician", "considering_private_practice"}},
			promoteCareer = true,
			careerXP = 35,
		},
	},
})

table.insert(events, {
	id = "doctor_malpractice_scare",
	emoji = "⚠️",
	title = "Malpractice Lawsuit",
	category = "work",
	tags = {"career", "medical", "doctor", "legal"},
	
	weight = 5,
	cooldownYears = 8,
	oneTime = false,
	
	conditions = {
		minAge = 30,
		maxAge = 70,
		requiredCareerId = "doctor",
		requiredCareerMinTier = 3,
	},
	
	text = "A patient's family files a malpractice lawsuit. Your lawyers say the case is weak, but it's still terrifying and stressful.",
	
	choices = {
		{
			id = "fight_it",
			text = "Fight the lawsuit. I did nothing wrong.",
			resultText = "After months of stress, the case is dismissed. But it changes how you practice.",
			effects = {Money = -20000, Happiness = -5, Health = -2},
			flags = {set = {"survived_lawsuit"}},
		},
		{
			id = "settle_quickly",
			text = "Settle to make it go away.",
			resultText = "You settle out of court. It feels wrong, but the stress is over.",
			effects = {Money = -50000, Happiness = -3},
			flags = {set = {"lawsuit_settled"}},
		},
	},
})

table.insert(events, {
	id = "doctor_difficult_diagnosis",
	emoji = "🔍",
	title = "The Mystery Patient",
	category = "work",
	tags = {"career", "medical", "doctor"},
	
	weight = 10,
	cooldownYears = 2,
	oneTime = false,
	
	conditions = {
		minAge = 30,
		maxAge = 70,
		requiredCareerId = "doctor",
		requiredCareerMinTier = 3,
	},
	
	text = "A patient comes in with symptoms that don't match any obvious diagnosis. Every test comes back normal, but they're clearly suffering.",
	
	choices = {
		{
			id = "dig_deeper",
			text = "Order more tests. Something's there.",
			resultText = "Your persistence pays off. You find a rare condition and start treatment. The patient improves.",
			effects = {Smarts = 3, Happiness = 4, Karma = 3},
			flags = {set = {"diagnostic_hero"}},
			careerXP = 25,
			careerReputation = 10,
		},
		{
			id = "refer_specialist",
			text = "Refer to a specialist.",
			resultText = "You refer them to a specialist who eventually figures it out. Good call.",
			effects = {Happiness = 2, Karma = 1},
			flags = {set = {"good_referrer"}},
			careerXP = 10,
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- NURSING CAREER EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "nursing_school_start",
	emoji = "📖",
	title = "Nursing School",
	category = "education",
	tags = {"career", "medical", "nurse", "nursing_school"},
	
	weight = 12,
	cooldownYears = 99,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	chainId = "nurse_career",
	chainStep = 1,
	
	conditions = {
		minAge = 18,
		maxAge = 45,
		requiredAnyFlags = {"wants_to_be_nurse", "medical_interest_sparked", "considering_other_healthcare"},
		requiredEducation = "high_school",
		minStats = {Smarts = 35},
	},
	
	getDynamicData = function(state)
		local schools = {"Community College of Nursing", "State Nursing Academy", "Regional Healthcare Institute"}
		return {
			school = schools[math.random(#schools)]
		}
	end,
	
	text = "You've been accepted into the nursing program at %school%. It's demanding, but nurses are the backbone of healthcare.",
	
	choices = {
		{
			id = "start_nursing",
			text = "Start the program with enthusiasm!",
			resultText = "You dive into the nursing curriculum. The clinical hours are intense but rewarding.",
			effects = {Smarts = 3, Happiness = 3, Money = -15000},
			flags = {set = {"nursing_student", "career_nurse_started"}},
			startCareer = "nurse",
			careerXP = 15,
		},
		{
			id = "reconsider",
			text = "Maybe I should reconsider...",
			resultText = "You decide to wait and think more about your career path.",
			effects = {},
			flags = {set = {}},
		},
	},
})

table.insert(events, {
	id = "nursing_first_patient",
	emoji = "💉",
	title = "First Patient Care",
	category = "work",
	tags = {"career", "medical", "nurse", "nursing_school"},
	
	weight = 12,
	cooldownYears = 99,
	oneTime = true,
	
	conditions = {
		minAge = 19,
		maxAge = 50,
		requiredCareerId = "nurse",
		requiredCareerMinTier = 1,
		requiredAllFlags = {"nursing_student"},
	},
	
	text = "Your first day of clinical rotations. A real patient looks at you nervously as you prepare to draw blood. Your hands are shaking a little.",
	
	choices = {
		{
			id = "stay_calm",
			text = "Take a breath and stay calm.",
			resultText = "You find the vein on the first try. The patient relaxes. So do you.",
			effects = {Happiness = 3, Smarts = 2},
			flags = {set = {"first_clinical_success"}},
			careerXP = 15,
		},
		{
			id = "ask_instructor",
			text = "Ask your instructor for guidance.",
			resultText = "Your instructor walks you through it. It takes two tries, but you get it.",
			effects = {Happiness = 2, Smarts = 1},
			flags = {set = {"first_clinical_assisted"}},
			careerXP = 10,
		},
	},
})

table.insert(events, {
	id = "nursing_license",
	emoji = "📜",
	title = "Registered Nurse License",
	category = "work",
	tags = {"career", "medical", "nurse", "hospital_nurse", "milestone"},
	
	weight = 15,
	cooldownYears = 99,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	conditions = {
		minAge = 21,
		maxAge = 55,
		requiredCareerId = "nurse",
		requiredCareerMinTier = 1,
		requiredAnyFlags = {"first_clinical_success", "first_clinical_assisted"},
	},
	
	text = "You passed the NCLEX! You're officially a Registered Nurse. Time to find your first job.",
	
	choices = {
		{
			id = "hospital_rn",
			text = "Apply to hospitals.",
			resultText = "You get hired at a busy hospital. Long shifts, but meaningful work.",
			effects = {Money = 3000, Happiness = 5},
			flags = {set = {"rn_licensed", "hospital_nurse_job"}},
			promoteCareer = true,
			careerXP = 25,
		},
		{
			id = "clinic_rn",
			text = "Look for clinic positions.",
			resultText = "You find a position at a clinic. More regular hours, less emergency chaos.",
			effects = {Money = 2500, Happiness = 5},
			flags = {set = {"rn_licensed", "clinic_nurse_job"}},
			promoteCareer = true,
			careerXP = 20,
		},
	},
})

table.insert(events, {
	id = "nursing_gratitude",
	emoji = "❤️",
	title = "Patient Gratitude",
	category = "work",
	tags = {"career", "medical", "nurse"},
	
	weight = 12,
	cooldownYears = 2,
	oneTime = false,
	
	conditions = {
		minAge = 22,
		maxAge = 70,
		requiredCareerId = "nurse",
		requiredCareerMinTier = 2,
	},
	
	text = "A patient you cared for during a difficult time sends you a heartfelt thank-you card. They say you made all the difference during their stay.",
	
	choices = {
		{
			id = "touched",
			text = "This is why I became a nurse.",
			resultText = "You hang the card in your locker. On hard days, you look at it.",
			effects = {Happiness = 5, Karma = 2},
			flags = {set = {"patient_gratitude"}},
			careerXP = 15,
		},
		{
			id = "humble",
			text = "Just doing my job.",
			resultText = "You're humble about it, but it still feels good to be appreciated.",
			effects = {Happiness = 3, Karma = 1},
			careerXP = 10,
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- SURGEON SPECIALIZATION EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "surgery_residency_match",
	emoji = "🔪",
	title = "Surgical Residency",
	category = "work",
	tags = {"career", "medical", "surgeon", "surgery_training"},
	
	weight = 10,
	cooldownYears = 99,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	conditions = {
		minAge = 26,
		maxAge = 40,
		requiredCareerId = "doctor",
		requiredCareerMinTier = 2,
		requiredAllFlags = {"interested_surgery"},
	},
	
	text = "You've matched into a surgical residency. This is one of the longest and most demanding paths in medicine - 5 to 7 years of intense training.",
	
	choices = {
		{
			id = "embrace_surgery",
			text = "I was born for the OR. Let's go.",
			resultText = "You begin surgical residency. The hours are brutal, but you love the work.",
			effects = {Happiness = 3},
			flags = {set = {"surgical_resident", "career_surgeon_started"}},
			startCareer = "surgeon",
			careerXP = 30,
		},
	},
})

table.insert(events, {
	id = "surgery_first_solo",
	emoji = "🩺",
	title = "First Solo Surgery",
	category = "work",
	tags = {"career", "medical", "surgeon", "surgery_training"},
	
	weight = 10,
	cooldownYears = 99,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	conditions = {
		minAge = 28,
		maxAge = 50,
		requiredCareerId = "surgeon",
		requiredCareerMinTier = 1,
		requiredAllFlags = {"surgical_resident"},
	},
	
	text = "Your attending steps back. 'This one's yours.' Your first surgery where you're the lead surgeon, not the assistant. The patient is trusting you with their life.",
	
	choices = {
		{
			id = "confidence",
			text = "I've trained for this. Scalpel.",
			resultText = "The surgery goes perfectly. You close up, and the patient is stable. You did it.",
			effects = {Happiness = 6, Smarts = 3},
			flags = {set = {"first_solo_surgery_success"}},
			careerXP = 35,
			careerReputation = 15,
		},
		{
			id = "nervous_but_ready",
			text = "Deep breath. I can do this.",
			resultText = "There are a few tense moments, but you get through it. Success.",
			effects = {Happiness = 5, Smarts = 2},
			flags = {set = {"first_solo_surgery_success"}},
			careerXP = 30,
		},
	},
})

table.insert(events, {
	id = "surgery_complication",
	emoji = "⚡",
	title = "Surgical Complication",
	category = "work",
	tags = {"career", "medical", "surgeon"},
	
	weight = 7,
	cooldownYears = 3,
	oneTime = false,
	
	conditions = {
		minAge = 30,
		maxAge = 70,
		requiredCareerId = "surgeon",
		requiredCareerMinTier = 2,
	},
	
	text = "Mid-surgery, something goes wrong. Unexpected bleeding. Your team looks to you. Every second counts.",
	
	choices = {
		{
			id = "stay_cool",
			text = "Stay calm. Address the bleed.",
			resultText = "You handle the complication expertly. The patient pulls through. Your team is impressed.",
			effects = {Smarts = 4, Happiness = 2},
			flags = {set = {"handled_complication"}},
			careerXP = 25,
			careerReputation = 10,
		},
		{
			id = "call_backup",
			text = "Call for senior surgeon backup.",
			resultText = "You make the smart call. Backup arrives and together you save the patient.",
			effects = {Smarts = 2, Karma = 2},
			flags = {set = {"called_backup"}},
			careerXP = 15,
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- GENERAL MEDICAL EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "medical_pandemic",
	emoji = "😷",
	title = "Healthcare Crisis",
	category = "work",
	tags = {"career", "medical", "crisis"},
	
	weight = 4,
	cooldownYears = 10,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	conditions = {
		minAge = 22,
		maxAge = 70,
		requiredAnyFlags = {"rn_licensed", "attending_physician", "surgical_resident"},
	},
	
	text = "A healthcare crisis hits. Hospitals are overwhelmed. They're asking everyone to work extra shifts. The country needs healthcare workers now more than ever.",
	
	choices = {
		{
			id = "step_up",
			text = "I'll work as many shifts as needed.",
			resultText = "You work tirelessly through the crisis. It's exhausting but you help save countless lives.",
			effects = {Health = -10, Happiness = -5, Karma = 10},
			flags = {set = {"healthcare_hero"}},
			careerXP = 50,
			careerReputation = 30,
		},
		{
			id = "sustainable_pace",
			text = "Help, but maintain a sustainable pace.",
			resultText = "You do your part without destroying yourself. You can't help anyone if you burn out.",
			effects = {Health = -3, Karma = 5},
			flags = {set = {"crisis_helper"}},
			careerXP = 25,
		},
	},
})

table.insert(events, {
	id = "medical_burnout",
	emoji = "🔥",
	title = "Medical Burnout",
	category = "health",
	tags = {"career", "medical", "burnout"},
	
	weight = 8,
	cooldownYears = 4,
	oneTime = false,
	
	conditions = {
		minAge = 25,
		maxAge = 70,
		requiredAnyFlags = {"rn_licensed", "attending_physician", "surgical_resident"},
		maxStats = {Happiness = 35, Health = 40},
	},
	
	text = "The emotional toll of healthcare is catching up. You've seen too much suffering. The paperwork never ends. You wonder if you can keep doing this.",
	
	choices = {
		{
			id = "take_leave",
			text = "Take a medical leave to recover.",
			resultText = "You step away for a while. It's what you need to come back stronger.",
			effects = {Health = 10, Happiness = 8, Money = -5000},
			flags = {set = {"took_medical_leave"}},
		},
		{
			id = "therapy",
			text = "Start seeing a therapist.",
			resultText = "You begin processing the trauma properly. It helps more than you expected.",
			effects = {Health = 5, Happiness = 5},
			flags = {set = {"in_therapy"}},
		},
		{
			id = "push_through",
			text = "Push through. Patients need me.",
			resultText = "You keep going, but something inside feels different.",
			effects = {Health = -5, Happiness = -5, Karma = 2},
			flags = {set = {"ignored_burnout"}},
		},
	},
})

return {events = events}
