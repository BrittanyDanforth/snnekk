-- LifeEvents/career_medical.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- MEDICAL CAREER EVENTS
-- Doctors, Nurses, Surgeons, EMTs, Therapists - The healing life
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent.init)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- EARLY CALLING
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "med_childhood_calling",
		minAge = 8, maxAge = 16,
		weight = 20, oneTime = true,
		emoji = "🏥", title = "Medical Calling",
		category = "family",
		getDynamicData = function()
			local events = {"grandparent got sick", "you visited someone in the hospital", "watched a medical documentary", "helped an injured animal", "family member is a doctor"}
			return { event = events[math.random(#events)] }
		end,
		text = "After %event%, you realized you want to help people heal.",
		choices = {
			{ text = "🩺 I want to be a doctor!", effects = { Happiness = 15, Smarts = 5 }, resultText = "The dream takes root. Time to study hard!", setFlags = {"medical_interest", "doctor_dream"} },
			{ text = "💉 Maybe a nurse?", effects = { Happiness = 12, Smarts = 3 }, resultText = "Helping people directly. Noble calling.", setFlag = "medical_interest" },
			{ text = "🚑 EMT sounds cool!", effects = { Happiness = 10, Health = 3 }, resultText = "Saving lives in emergencies! Action and purpose!", setFlag = "medical_interest" },
			{ text = "🤔 Too much blood", effects = { Happiness = 2 }, resultText = "Medicine isn't for everyone. That's okay." },
		},
	},
	
	{
		id = "med_volunteer_hospital",
		minAge = 16, maxAge = 22,
		weight = 25, oneTime = true,
		emoji = "🏥", title = "Hospital Volunteer",
		category = "work",
		requiresFlag = "medical_interest",
		text = "You started volunteering at the local hospital. First real taste of healthcare.",
		choices = {
			{ text = "❤️ Found my purpose", effects = { Happiness = 20, Smarts = 5 }, resultText = "Helping patients, even in small ways, feels right. This is your calling.", setFlag = "healthcare_confirmed" },
			{ text = "😔 It's harder than expected", effects = { Happiness = -5, Smarts = 5 }, resultText = "Saw suffering. Death. It's not easy. But you're not giving up." },
			{ text = "🤢 Can't handle it", effects = { Happiness = -10 }, resultText = "The sights, the smells... maybe medicine isn't for you.", clearFlag = "medical_interest" },
			{ text = "📚 More motivated to study", effects = { Happiness = 15, Smarts = 8 }, resultText = "Seeing real patients made it real. Studying harder than ever!", setFlags = {"healthcare_confirmed", "pre_med"} },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- MEDICAL SCHOOL PATH
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "med_mcat_results",
		minAge = 20, maxAge = 26,
		weight = 25, oneTime = true,
		emoji = "📝", title = "MCAT Results!",
		category = "school",
		requiresFlag = "pre_med",
		getDynamicData = function()
			local scores = {520, 515, 510, 505, 495}
			return { score = scores[math.random(#scores)] }
		end,
		text = "Your MCAT score came back: %score%! Medical school applications ahead!",
		choices = {
			{ text = "🎉 Crushed it!", effects = { Happiness = 25, Smarts = 8 }, resultText = "Top tier score! Harvard, Stanford, Johns Hopkins all possible!", setFlag = "mcat_ace" },
			{ text = "📊 Good enough", effects = { Happiness = 15, Smarts = 5 }, resultText = "Solid score. Will get into good schools!", setFlag = "med_school_ready" },
			{ text = "😔 Disappointing", effects = { Happiness = -10, Smarts = 3 }, resultText = "Below what you hoped. Caribbean school? Retake?" },
			{ text = "🔄 Retaking it", effects = { Happiness = -5, Smarts = 5 }, resultText = "Not accepting that score. Studying harder. Round two." },
		},
	},
	
	{
		id = "med_school_acceptance",
		minAge = 21, maxAge = 28,
		weight = 20, oneTime = true,
		emoji = "✉️", title = "Medical School Decision!",
		category = "school",
		requiresFlag = "med_school_ready",
		getDynamicData = function()
			local schools = {"Harvard Medical", "Johns Hopkins", "Stanford Medicine", "Mayo Clinic", "your state medical school"}
			return { school = schools[math.random(#schools)] }
		end,
		text = "Letter from %school%! Your hands are shaking as you open it...",
		choices = {
			{ text = "🎉 ACCEPTED!", effects = { Happiness = 40, Money = -200000, Smarts = 10 }, resultText = "YOU'RE GOING TO BE A DOCTOR! Four years of intense training ahead!", setFlags = {"med_student", "future_doctor"} },
			{ text = "📋 Waitlisted", effects = { Happiness = 5, Smarts = 3 }, resultText = "Not rejected but not accepted. The waiting is torture." },
			{ text = "❌ Rejected", effects = { Happiness = -25, Smarts = 3 }, resultText = "Crushing. Years of work... but other schools might say yes." },
			{ text = "💰 Scholarship!", effects = { Happiness = 45, Smarts = 10 }, resultText = "Full scholarship! Med school without the debt! Dream scenario!", setFlags = {"med_student", "future_doctor", "scholarship"} },
		},
	},
	
	{
		id = "med_school_struggles",
		minAge = 22, maxAge = 30,
		weight = 30, cooldown = 2,
		emoji = "📚", title = "Medical School Struggles",
		category = "school",
		requiresFlag = "med_student",
		getDynamicData = function()
			local struggles = {"anatomy exam", "first cadaver lab", "sleep deprivation", "doubting yourself", "failing a class"}
			return { struggle = struggles[math.random(#struggles)] }
		end,
		text = "Med school is brutal. Currently dealing with: %struggle%",
		choices = {
			{ text = "💪 Pushed through", effects = { Happiness = 5, Health = -5, Smarts = 5 }, resultText = "One day at a time. This is why it's hard. Only the dedicated make it." },
			{ text = "🤝 Study group helps", effects = { Happiness = 10, Smarts = 5 }, resultText = "Your classmates are going through it too. Together you'll survive." },
			{ text = "😰 Breaking point", effects = { Happiness = -15, Health = -10 }, resultText = "Crying in the library at 3am. Is this worth it?" },
			{ text = "💬 Got therapy", effects = { Happiness = 8, Health = 5, Money = -1000 }, resultText = "Mental health matters, especially in medicine. Getting help.", setFlag = "therapy" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- RESIDENCY & SPECIALIZATION
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "med_match_day",
		minAge = 25, maxAge = 32,
		weight = 20, oneTime = true,
		emoji = "✉️", title = "MATCH DAY!",
		category = "work",
		requiresFlag = "med_student",
		getDynamicData = function()
			local specialties = {"Surgery", "Internal Medicine", "Pediatrics", "Emergency Medicine", "Psychiatry", "Dermatology", "Cardiology", "Neurosurgery"}
			local hospitals = {"Mass General", "Cleveland Clinic", "Mayo Clinic", "UCLA Medical", "Johns Hopkins Hospital"}
			return { specialty = specialties[math.random(#specialties)], hospital = hospitals[math.random(#hospitals)] }
		end,
		text = "Match Day! Where will you do your residency?! Opening the envelope...",
		choices = {
			{ text = "🎉 Top choice!", effects = { Happiness = 35, Money = 60000 }, resultText = "%specialty% at %hospital%! Your dream match! The white coat awaits!", clearFlag = "med_student", setFlags = {"resident", "doctor"} },
			{ text = "😊 Good match", effects = { Happiness = 20, Money = 55000 }, resultText = "Not first choice but a great program! Still becoming a doctor!", clearFlag = "med_student", setFlags = {"resident", "doctor"} },
			{ text = "😔 Didn't match", effects = { Happiness = -30, Smarts = 3 }, resultText = "No match. Devastating. Have to SOAP into remaining spots.", clearFlag = "med_student", setFlag = "unmatched" },
			{ text = "🏆 Competitive specialty!", effects = { Happiness = 30, Money = 65000 }, resultText = "Matched into %specialty%! Only the best get this!", clearFlag = "med_student", setFlags = {"resident", "doctor", "elite_specialty"} },
		},
	},
	
	{
		id = "med_residency_hell",
		minAge = 25, maxAge = 35,
		weight = 30, cooldown = 2,
		emoji = "😴", title = "Residency Exhaustion",
		category = "work",
		requiresFlag = "resident",
		getDynamicData = function()
			local hours = math.random(80, 100)
			return { hours = hours }
		end,
		text = "%hours%-hour weeks. Barely sleeping. The residency grind is real.",
		choices = {
			{ text = "☕ Coffee is life", effects = { Happiness = -5, Health = -8, Smarts = 3 }, resultText = "Running on caffeine and determination. It'll be worth it." },
			{ text = "😤 This is abuse", effects = { Happiness = -10, Smarts = 5 }, resultText = "The system is broken. Doctors shouldn't be this exhausted." },
			{ text = "💪 Building character", effects = { Happiness = 5, Health = -5 }, resultText = "If you can survive this, you can handle anything." },
			{ text = "😔 Made a mistake", effects = { Happiness = -20, Health = -5 }, resultText = "Too tired. Made an error. Nothing serious but... scary wake-up call." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- PRACTICING MEDICINE
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "med_first_save",
		minAge = 26, maxAge = 40,
		weight = 20, oneTime = true,
		emoji = "💓", title = "First Life Saved!",
		category = "work",
		requiresFlag = "doctor",
		text = "A patient was coding. You jumped in. Your hands, your training, your decisions...",
		choices = {
			{ text = "💓 They survived!", effects = { Happiness = 40, Smarts = 5 }, resultText = "YOU SAVED A LIFE. The patient's family is sobbing with joy. This is why you do this.", setFlag = "life_saver" },
			{ text = "👨‍👩‍👧 Changed a family", effects = { Happiness = 35, Smarts = 3 }, resultText = "A father gets to go home to his kids. Because of you.", setFlag = "life_saver" },
			{ text = "😰 Shaking afterward", effects = { Happiness = 20, Health = -3 }, resultText = "The adrenaline. The fear. But they lived. You did it.", setFlag = "life_saver" },
			{ text = "🙏 Humbled", effects = { Happiness = 30, Smarts = 5 }, resultText = "Holding life in your hands. The responsibility is immense.", setFlag = "life_saver" },
		},
	},
	
	{
		id = "med_lost_patient",
		minAge = 26, maxAge = 70,
		weight = 25, cooldown = 3,
		emoji = "😢", title = "Lost a Patient",
		category = "work",
		requiresFlag = "doctor",
		getDynamicData = function()
			local patients = {"a young mother", "a child", "an elderly veteran", "a teenager", "someone your age"}
			return { patient = patients[math.random(#patients)] }
		end,
		text = "Despite everything, %patient% didn't make it. You did everything you could.",
		choices = {
			{ text = "😭 Devastated", effects = { Happiness = -25, Health = -5 }, resultText = "Cried in the supply closet. This never gets easier." },
			{ text = "💔 Told the family", effects = { Happiness = -20, Smarts = 3 }, resultText = "The hardest part of medicine. Looking into their eyes..." },
			{ text = "🤔 Could I have done more?", effects = { Happiness = -15, Smarts = 5 }, resultText = "Replaying every decision. The doubt is crushing.", setFlag = "self_doubt" },
			{ text = "💪 Find strength", effects = { Happiness = -10, Smarts = 5 }, resultText = "Honor them by saving the next one. Keep going." },
		},
	},
	
	{
		id = "med_attending_position",
		minAge = 30, maxAge = 45,
		weight = 15, oneTime = true,
		emoji = "👨‍⚕️", title = "Attending Physician!",
		category = "work",
		requiresFlag = "doctor",
		getDynamicData = function()
			local hospitals = {"a prestigious hospital", "a community hospital", "a private practice", "an academic center", "a rural clinic"}
			local salary = math.random(250, 500)
			return { hospital = hospitals[math.random(#hospitals)], salary = salary }
		end,
		text = "%hospital% wants you as an attending! Salary: $%salary%K!",
		choices = {
			{ text = "🏥 Dream job!", effects = { Happiness = 30, Money = 300000 }, resultText = "Residency is OVER! You're a real doctor now! Attending status!", clearFlag = "resident", setFlags = {"attending", "established_doctor"} },
			{ text = "💰 Great pay!", effects = { Happiness = 25, Money = 400000 }, resultText = "After years of poverty wages, finally making real money!", clearFlag = "resident", setFlags = {"attending", "high_earning_doctor"} },
			{ text = "🎓 Academic medicine", effects = { Happiness = 28, Money = 250000, Smarts = 5 }, resultText = "Teaching the next generation while treating patients.", clearFlag = "resident", setFlags = {"attending", "academic_doctor"} },
			{ text = "🏔️ Rural medicine", effects = { Happiness = 25, Money = 280000, Health = 5 }, resultText = "Small town doctor. Less money but more impact. Needed here.", clearFlag = "resident", setFlags = {"attending", "rural_doctor"} },
		},
	},
	
	{
		id = "med_malpractice",
		minAge = 30, maxAge = 65,
		weight = 15, cooldown = 5,
		emoji = "⚖️", title = "Malpractice Lawsuit",
		category = "work",
		requiresFlag = "attending",
		text = "You're being sued for malpractice. Even if you did nothing wrong, this is devastating.",
		choices = {
			{ text = "😰 Terrifying", effects = { Happiness = -25, Health = -10, Money = -50000 }, resultText = "Lawyers, depositions, years of stress. The system is brutal." },
			{ text = "⚖️ Won the case", effects = { Happiness = 10, Money = -20000, Smarts = 5 }, resultText = "Vindicated but traumatized. The process was awful." },
			{ text = "💔 Settled", effects = { Happiness = -15, Money = -100000 }, resultText = "Not guilty but settled anyway. Insurance handled it but... the doubt." },
			{ text = "😔 Considering quitting", effects = { Happiness = -20, Health = -8 }, resultText = "Is practicing medicine worth this risk? So many doctors are leaving." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- SURGERY SPECIALTY
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "med_first_solo_surgery",
		minAge = 28, maxAge = 40,
		weight = 20, oneTime = true,
		emoji = "🔪", title = "First Solo Surgery!",
		category = "work",
		requiresFlag = "elite_specialty",
		text = "The attending stepped back. This operation is ALL YOU. Scalpel in hand...",
		choices = {
			{ text = "✨ Flawless!", effects = { Happiness = 35, Smarts = 8 }, resultText = "Perfect execution. Patient stable. You're a surgeon.", setFlag = "surgeon" },
			{ text = "😰 Hands shaking", effects = { Happiness = 15, Smarts = 5 }, resultText = "Nervous but did it. Not perfect but patient is okay." },
			{ text = "🩸 Complication", effects = { Happiness = -10, Smarts = 5 }, resultText = "Something went wrong. Fixed it. Patient fine but... humbling." },
			{ text = "🙏 Grateful attending", effects = { Happiness = 25, Smarts = 5 }, resultText = "Your mentor was proud. Passing of the torch.", setFlag = "surgeon" },
		},
	},
	
	{
		id = "med_groundbreaking_surgery",
		minAge = 35, maxAge = 60,
		weight = 8, oneTime = true,
		emoji = "🏆", title = "Medical Breakthrough!",
		category = "work",
		requiresFlag = "surgeon",
		text = "You pioneered a new surgical technique! Medical journals are calling!",
		choices = {
			{ text = "📰 Published paper", effects = { Happiness = 35, Money = 50000, Smarts = 10 }, resultText = "Your technique bears your name. Medical textbooks will mention you.", setFlag = "medical_pioneer" },
			{ text = "🎤 Keynote speaker", effects = { Happiness = 30, Money = 100000, Looks = 5 }, resultText = "Speaking at conferences worldwide! Celebrity surgeon status!", setFlags = {"medical_pioneer", "famous_doctor"} },
			{ text = "💰 Patent it", effects = { Happiness = 25, Money = 500000 }, resultText = "Your technique, your profit. Ethical debates but... set for life.", setFlags = {"medical_pioneer", "wealthy_doctor"} },
			{ text = "🆓 Share freely", effects = { Happiness = 40, Smarts = 5 }, resultText = "Medicine should be for everyone. Gave it to the world.", setFlags = {"medical_pioneer", "altruistic"} },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- LEGACY & RETIREMENT
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "med_pandemic_hero",
		minAge = 28, maxAge = 65,
		weight = 10, oneTime = true,
		emoji = "🦠", title = "Pandemic Response",
		category = "work",
		requiresFlag = "doctor",
		text = "A pandemic hit. Healthcare workers on the front lines. Including you.",
		choices = {
			{ text = "💪 Fought through it", effects = { Happiness = 20, Health = -15, Smarts = 5 }, resultText = "Months of chaos, death, fear. But you showed up every day. Hero.", setFlags = {"pandemic_hero", "community_hero"} },
			{ text = "😷 Got sick yourself", effects = { Happiness = -15, Health = -25 }, resultText = "COVID got you. Hospitalized. Terrifying being on the other side.", setFlag = "pandemic_survivor" },
			{ text = "😭 Lost colleagues", effects = { Happiness = -25, Health = -10 }, resultText = "Fellow doctors died. The grief doesn't go away." },
			{ text = "🏅 Community honored you", effects = { Happiness = 30, Looks = 5 }, resultText = "Called a hero. Parades, thank yous. But you're just doing your job.", setFlags = {"pandemic_hero", "local_celebrity"} },
		},
	},
	
	{
		id = "med_retirement",
		minAge = 55, maxAge = 75,
		weight = 20, oneTime = true,
		emoji = "👨‍⚕️", title = "Hanging Up the White Coat",
		category = "work",
		requiresFlag = "established_doctor",
		getDynamicData = function()
			local years = math.random(25, 45)
			local lives = math.random(100, 10000)
			return { years = years, lives = lives }
		end,
		text = "After %years% years of practice. Approximately %lives% patients treated. Time to retire.",
		choices = {
			{ text = "😭 Emotional farewell", effects = { Happiness = 30, Health = 10 }, resultText = "Patients, colleagues, a lifetime of memories. Beautiful send-off.", clearFlags = {"attending", "established_doctor"}, setFlag = "retired_doctor" },
			{ text = "🎓 Train the next gen", effects = { Happiness = 25, Smarts = 5 }, resultText = "Part-time teaching. Passing on everything you learned.", setFlags = {"retired_doctor", "medical_educator"} },
			{ text = "✈️ Doctors Without Borders", effects = { Happiness = 35, Money = -50000, Health = -5 }, resultText = "Still helping, just in different countries now.", setFlags = {"retired_doctor", "humanitarian"} },
			{ text = "🏖️ Actually rest", effects = { Happiness = 20, Health = 15 }, resultText = "No more 4am calls. No more death. Just peace.", setFlag = "retired_doctor" },
		},
	},
	
	{
		id = "med_legacy",
		minAge = 60, maxAge = 90,
		weight = 15, oneTime = true,
		emoji = "🏛️", title = "Medical Legacy",
		category = "family",
		requiresFlag = "retired_doctor",
		text = "Looking back on your career in medicine. What did it all mean?",
		choices = {
			{ text = "💝 Saved countless lives", effects = { Happiness = 40 }, resultText = "The lives you saved, the families you kept together. That's your legacy.", setFlag = "healing_legacy" },
			{ text = "🏥 Building named after you", effects = { Happiness = 35, Looks = 5 }, resultText = "A wing of the hospital bears your name. Permanent impact.", setFlag = "immortalized" },
			{ text = "👨‍👩‍👧 Inspired family", effects = { Happiness = 35 }, resultText = "Your grandchild is starting medical school. The calling continues.", setFlag = "medical_dynasty" },
			{ text = "📚 Wrote the textbook", effects = { Happiness = 30, Smarts = 8 }, resultText = "Your textbook trains doctors worldwide. Knowledge immortalized.", setFlag = "author" },
		},
	},
}

return module
