-- LifeEvents/career_medical.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- MEDICAL & HEALTHCARE CAREER EVENTS
-- BitLife-style: Player picks ACTIONS, game decides OUTCOMES
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent.init)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- EARLY INTEREST IN MEDICINE
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "med_childhood_interest",
		minAge = 8, maxAge = 14,
		weight = 25, oneTime = true,
		emoji = "🏥", title = "Interested in Medicine!",
		category = "school",
		getDynamicData = function()
			local triggers = {"visiting a sick relative", "watching a medical show", "your own hospital visit", "meeting a doctor"}
			return { trigger = triggers[math.random(#triggers)] }
		end,
		text = "After %trigger%, you're fascinated by medicine. What do you do?",
		choices = {
			{ text = "📚 Read medical books", effects = { Smarts = 10, Happiness = 8 }, resultText = "Learning about the human body! Anatomy is fascinating!", setFlags = {"medical_interest", "future_doctor"} },
			{ text = "🩹 Play doctor with toys", effects = { Happiness = 10, Smarts = 5 }, resultText = "Bandaging up stuffed animals! Cute future doctor!", setFlag = "medical_interest" },
			{ text = "🔬 Ask for a microscope", effects = { Smarts = 12, Happiness = 8 }, resultText = "Looking at cells! Science is AMAZING!", setFlags = {"medical_interest", "scientist"} },
			{ text = "🤷 Just a phase", effects = { Happiness = 5 }, resultText = "Interest faded. On to the next thing!" },
		},
	},
	
	{
		id = "med_volunteer_hospital",
		minAge = 14, maxAge = 18,
		weight = 20, oneTime = true,
		emoji = "🏥", title = "Hospital Volunteer Opportunity!",
		category = "school",
		requiresFlag = "medical_interest",
		text = "Local hospital is accepting teen volunteers! Perfect for your med school application! What do you do?",
		choices = {
			{ text = "✅ Sign up immediately", effects = { Happiness = 15, Smarts = 8 }, resultText = "Helping patients! Seeing real medicine! Confirms your calling!", setFlags = {"hospital_volunteer", "confirmed_premed"} },
			{ text = "🩸 Join blood drive instead", effects = { Happiness = 10, Smarts = 5 }, resultText = "Organizing blood drives! Saving lives a different way!", setFlag = "healthcare_helper" },
			{ text = "😰 Too scared of hospitals", effects = { Happiness = -5 }, resultText = "Maybe medicine isn't for you if hospitals scare you..." },
			{ text = "📅 Too busy with school", effects = { Happiness = 3, Smarts = 5 }, resultText = "Focused on grades instead. Different path to medicine." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- EDUCATION PATH
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "med_premed_grind",
		minAge = 18, maxAge = 22,
		weight = 20, oneTime = true,
		emoji = "📚", title = "Pre-Med Life!",
		category = "school",
		requiresFlag = "confirmed_premed",
		text = "Pre-med courses are BRUTAL. Organic chemistry is destroying everyone. How do you handle it?",
		choices = {
			{ text = "📚 Study 24/7", effects = { Smarts = 15, Happiness = -10, Health = -5 }, resultText = "Grades are great but you have no life. Worth it for med school?", setFlags = {"top_of_class", "premed_survivor"} },
			{ text = "👥 Form study groups", effects = { Smarts = 12, Happiness = 5 }, resultText = "Learning together! Made friends AND good grades!", setFlag = "premed_survivor" },
			{ text = "😔 Consider switching majors", effects = { Happiness = 8, Smarts = 5 }, resultText = "Maybe medicine isn't worth this suffering. Other careers exist.", clearFlag = "confirmed_premed" },
			{ text = "💪 Balance is key", effects = { Smarts = 10, Happiness = 8, Health = 5 }, resultText = "Good grades AND a social life! It's possible!", setFlag = "premed_survivor" },
		},
	},
	
	{
		id = "med_mcat_time",
		minAge = 21, maxAge = 24,
		weight = 20, oneTime = true,
		emoji = "📝", title = "MCAT Day!",
		category = "school",
		requiresFlag = "premed_survivor",
		text = "The MCAT. The test that determines your future. 7+ hours of testing. How do you perform?",
		choices = {
			{ text = "🧠 Absolutely crush it", effects = { Happiness = 30, Smarts = 10 }, resultText = "Top percentile! Any med school will want you!", setFlags = {"mcat_success", "med_school_ready"} },
			{ text = "📊 Solid but not stellar", effects = { Happiness = 15, Smarts = 5 }, resultText = "Good score! Competitive for most programs!", setFlag = "med_school_ready" },
			{ text = "😰 Panic and underperform", effects = { Happiness = -15, Smarts = -3 }, resultText = "Test anxiety got you. Can retake but lost a year." },
			{ text = "🤕 Get sick during test", effects = { Happiness = -20, Health = -10 }, resultText = "Of all days! Score tanked. Definitely retaking." },
		},
	},
	
	{
		id = "med_school_acceptance",
		minAge = 22, maxAge = 26,
		weight = 15, oneTime = true,
		emoji = "📬", title = "Med School Decisions!",
		category = "school",
		requiresFlag = "med_school_ready",
		text = "Acceptance/rejection letters arriving! You applied to 20 schools. What happened?",
		choices = {
			{ text = "🎉 Dream school accepted!", effects = { Happiness = 40, Money = -200000 }, resultText = "Harvard/Stanford/Johns Hopkins! FULL debt but full prestige!", setFlags = {"med_student", "elite_med_school"} },
			{ text = "✅ Got in somewhere", effects = { Happiness = 25, Money = -180000 }, resultText = "Not top tier but you're a MED STUDENT! Doctor path confirmed!", setFlag = "med_student" },
			{ text = "📋 Waitlisted everywhere", effects = { Happiness = -10, Smarts = 3 }, resultText = "Limbo. Waiting for spots to open. Stressful summer." },
			{ text = "❌ All rejections", effects = { Happiness = -30 }, resultText = "Devastating. Consider other paths or strengthen application for next cycle." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- MEDICAL SCHOOL & RESIDENCY
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "med_first_cadaver",
		minAge = 22, maxAge = 28,
		weight = 25, oneTime = true,
		emoji = "🔬", title = "First Day of Anatomy Lab!",
		category = "school",
		requiresFlag = "med_student",
		text = "Anatomy lab. Real cadaver. The defining moment for first years. How do you handle it?",
		choices = {
			{ text = "🧠 Fascinated, dive in", effects = { Happiness = 10, Smarts = 8 }, resultText = "This is why you're here! Learning so much! Built for this!", setFlag = "anatomy_lover" },
			{ text = "🤢 Almost pass out", effects = { Happiness = -10, Health = -3 }, resultText = "Nearly fainted. Made it through. It gets easier (they say)." },
			{ text = "😤 Professional, detached", effects = { Happiness = 5, Smarts = 5 }, resultText = "Treated it clinically. Got through it. Not everyone needs to love it." },
			{ text = "😔 Questioning everything", effects = { Happiness = -15, Smarts = 3 }, resultText = "This is really hard. Is medicine right for you? Doubt creeping in." },
		},
	},
	
	{
		id = "med_residency_match",
		minAge = 26, maxAge = 32,
		weight = 15, oneTime = true,
		emoji = "🏥", title = "Match Day!",
		category = "work",
		requiresFlag = "med_student",
		blockIfFlag = "resident", -- Only one match day
		getDynamicData = function()
			local specialties = {"Surgery", "Internal Medicine", "Pediatrics", "Emergency Medicine", "Radiology", "Psychiatry"}
			return { specialty = specialties[math.random(#specialties)] }
		end,
		text = "MATCH DAY! The envelope that determines where you'll train! You wanted %specialty%!",
		choices = {
			{ 
				text = "📬 Open nervously", 
				effects = { Happiness = 35 }, 
				resultText = "YOU MATCHED! At a great program! Doctor journey continues!", 
				setFlags = {"resident", "doctor_in_training", "employed"},
				setJob = { id = "resident", title = "Medical Resident", salary = 60000 }
			},
			{ 
				text = "👥 Open with family", 
				effects = { Happiness = 38 }, 
				resultText = "Shared the moment! Everyone crying! You're going to be a doctor!", 
				setFlags = {"resident", "doctor_in_training", "employed"},
				setJob = { id = "resident", title = "Medical Resident", salary = 58000 }
			},
			{ 
				text = "😰 Didn't match first choice", 
				effects = { Happiness = 15 }, 
				resultText = "Not where you wanted but you MATCHED! Still becoming a doctor!", 
				setFlags = {"resident", "chip_on_shoulder", "employed"},
				setJob = { id = "resident", title = "Medical Resident", salary = 55000 }
			},
			{ text = "💔 Didn't match anywhere", effects = { Happiness = -40 }, resultText = "Devastating. SOAP (backup match) or try again next year. Heartbreaking." },
		},
	},
	
	{
		id = "med_residency_hell",
		minAge = 26, maxAge = 35,
		weight = 25, cooldown = 2,
		emoji = "😴", title = "36-Hour Shift...",
		category = "work",
		requiresFlag = "resident",
		text = "End of a 36-hour shift. Running on fumes. How do you cope?",
		choices = {
			{ text = "☕ More coffee, push through", effects = { Happiness = -10, Health = -8 }, resultText = "Made it. Barely. This is residency. It won't last forever (7 more years)." },
			{ text = "😴 Cry in supply closet", effects = { Happiness = -5, Health = -3 }, resultText = "Had a moment. Let it out. Then back to patients. You're human." },
			{ text = "💪 Remind yourself why", effects = { Happiness = 5, Smarts = 3 }, resultText = "You're saving lives. This suffering has purpose. Renewed strength." },
			{ text = "🎯 Consider quitting", effects = { Happiness = -15, Health = 5 }, resultText = "Thoughts of giving up. Talked to mentor. Decided to continue. For now." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- PRACTICING PHYSICIAN
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "med_first_save",
		minAge = 28, maxAge = 45,
		weight = 20, oneTime = true,
		emoji = "❤️", title = "First Life Saved!",
		category = "work",
		requiresFlag = "resident",
		text = "Patient coding! You took charge! They're ALIVE because of you! How do you feel?",
		choices = {
			{ text = "😭 Overwhelmed with emotion", effects = { Happiness = 35, Smarts = 5 }, resultText = "You saved a life. A real human being. This is why you became a doctor.", setFlags = {"life_saver", "confident_doctor"} },
			{ text = "💪 This is my purpose", effects = { Happiness = 30, Health = 5 }, resultText = "Every brutal shift, every sacrifice was for THIS moment.", setFlag = "confident_doctor" },
			{ text = "🧠 Stay clinical", effects = { Happiness = 15, Smarts = 8 }, resultText = "Good outcome. Analyze what worked. Ready for the next one." },
			{ text = "😰 Can't handle the pressure", effects = { Happiness = -5, Health = -5 }, resultText = "The weight of holding lives in your hands... it's a lot." },
		},
	},
	
	{
		id = "med_first_loss",
		minAge = 28, maxAge = 60,
		weight = 20, cooldown = 4,
		emoji = "💔", title = "Lost a Patient...",
		category = "work",
		requiresFlag = "confident_doctor",
		text = "You did everything right. But they didn't make it. How do you cope?",
		choices = {
			{ text = "💬 Talk to colleagues", effects = { Happiness = 5, Health = 5 }, resultText = "They understand. Everyone loses patients. You're not alone." },
			{ text = "😔 Carry the weight alone", effects = { Happiness = -15, Health = -8 }, resultText = "Bottled it up. Heavy heart. Need to process this eventually." },
			{ text = "🩺 Review the case", effects = { Happiness = -5, Smarts = 8 }, resultText = "Learned for next time. Nothing you could have done differently. But still hurts." },
			{ text = "👨‍👩‍👧 Talk to the family", effects = { Happiness = 8, Smarts = 3 }, resultText = "Comforting them brought closure for you too. Human connection in tragedy." },
		},
	},
	
	{
		id = "med_malpractice_suit",
		minAge = 30, maxAge = 65,
		weight = 15, cooldown = 6,
		emoji = "⚖️", title = "Malpractice Lawsuit!",
		category = "work",
		requiresFlag = "confident_doctor",
		text = "You're being sued! Patient claims you made a mistake. This could ruin your career. What do you do?",
		choices = {
			{ text = "⚖️ Fight it in court", effects = { Happiness = 15, Money = -50000 }, resultText = "Insurance covered defense. Case dismissed! Vindicated but traumatized.", setFlag = "lawsuit_survivor" },
			{ text = "💰 Settle out of court", effects = { Happiness = -10, Money = -100000 }, resultText = "No admission of guilt but the payout hurts. Moved on.", setFlag = "settled_lawsuit" },
			{ text = "😰 Spiral into depression", effects = { Happiness = -25, Health = -15 }, resultText = "The accusation broke you. Even winning didn't fix it. Need help.", setFlag = "burned_out" },
			{ text = "📋 Document everything better", effects = { Happiness = 5, Smarts = 10 }, resultText = "Thorough records proved your innocence! Better documentation from now on.", setFlag = "careful_documenter" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- CAREER ADVANCEMENT
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "med_specialty_choice",
		minAge = 30, maxAge = 45,
		weight = 15, oneTime = true,
		emoji = "🏥", title = "Subspecialty Opportunity!",
		category = "work",
		requiresFlag = "confident_doctor",
		blockIfFlag = "attending_physician", -- Only one specialty choice
		getDynamicData = function()
			local subspecialties = {"Cardiology", "Oncology", "Neurosurgery", "Plastic Surgery", "Orthopedics"}
			return { subspecialty = subspecialties[math.random(#subspecialties)] }
		end,
		text = "Offered fellowship in %subspecialty%! More training but higher earning potential. What do you do?",
		choices = {
			{ 
				text = "🎓 Take the fellowship", 
				effects = { Happiness = 20, Smarts = 10 }, 
				resultText = "More years of training but you'll be elite in your field!", 
				setFlags = {"subspecialist", "fellowship_trained", "attending_physician"},
				setJob = { id = "specialist_md", title = "Specialist Physician", salary = 280000 }
			},
			{ 
				text = "💰 Start earning now", 
				effects = { Happiness = 15 }, 
				resultText = "General practice pays well enough! Time to make money!", 
				setFlag = "attending_physician",
				setJob = { id = "attending_md", title = "Attending Physician", salary = 200000 }
			},
			{ 
				text = "👥 Open your own practice", 
				effects = { Happiness = 18 }, 
				resultText = "Your name on the door! Own boss! Entrepreneur doctor!", 
				setFlags = {"private_practice", "business_owner", "attending_physician"},
				setJob = { id = "private_practice_md", title = "Private Practice Physician", salary = 250000 }
			},
			{ 
				text = "🏥 Stay at academic hospital", 
				effects = { Happiness = 12 }, 
				resultText = "Teaching the next generation. Research opportunities. Prestige.", 
				setFlags = {"academic_medicine", "professor", "attending_physician"},
				setJob = { id = "academic_md", title = "Academic Physician", salary = 180000 }
			},
		},
	},
	
	{
		id = "med_chief_of_department",
		minAge = 45, maxAge = 65,
		weight = 10, oneTime = true,
		emoji = "👔", title = "Chief Position Offered!",
		category = "work",
		requiresFlag = "attending_physician",
		text = "Offered Chief of your department! More politics, less patient care. But influence and prestige. What do you do?",
		choices = {
			{ text = "✅ Accept the position", effects = { Happiness = 25, Money = 100000 }, resultText = "Chief! Running the department! Shape the future of medicine here!", setFlags = {"chief", "hospital_leadership"} },
			{ text = "❌ Stay with patients", effects = { Happiness = 20, Smarts = 5 }, resultText = "This is why you became a doctor. Patients first. No regrets." },
			{ text = "💼 Negotiate better terms", effects = { Happiness = 22, Money = 120000 }, resultText = "Still do some patient care! Best of both worlds!", setFlags = {"chief", "still_practicing"} },
			{ text = "🏥 Go private practice instead", effects = { Happiness = 18, Money = 300000 }, resultText = "More money in private! Built your own empire!", setFlag = "private_practice_king" },
		},
	},
}

return module
