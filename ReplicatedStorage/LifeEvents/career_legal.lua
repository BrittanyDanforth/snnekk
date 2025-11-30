-- LifeEvents/career_legal.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- LEGAL CAREER EVENTS
-- Lawyers, Judges, Prosecutors, Public Defenders - Justice system life
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent.init)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- EARLY INTEREST IN LAW
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "law_mock_trial",
		minAge = 14, maxAge = 18,
		weight = 25, oneTime = true,
		emoji = "⚖️", title = "Mock Trial Competition!",
		category = "school",
		text = "Your school's mock trial team needs members. Courtroom drama awaits!",
		choices = {
			{ text = "⚖️ Loved it!", effects = { Happiness = 15, Smarts = 8 }, resultText = "The arguments! The objections! The verdict! This is THRILLING!", setFlags = {"law_interest", "mock_trial"} },
			{ text = "🏆 Won the competition!", effects = { Happiness = 20, Smarts = 8, Looks = 3 }, resultText = "Best attorney award! Natural in the courtroom!", setFlags = {"law_interest", "mock_trial", "born_lawyer"} },
			{ text = "📚 Fascinating but hard", effects = { Happiness = 10, Smarts = 6 }, resultText = "So much research and prep. But arguing is fun!", setFlag = "law_interest" },
			{ text = "😰 Stage fright", effects = { Happiness = -5, Smarts = 3 }, resultText = "Speaking in front of judges is terrifying. Maybe law isn't for you." },
		},
	},
	
	{
		id = "law_debate_champion",
		minAge = 15, maxAge = 22,
		weight = 20, cooldown = 2,
		emoji = "🎤", title = "Debate Champion!",
		category = "school",
		requiresFlag = "law_interest",
		text = "Debate tournament finals! Can you argue your way to victory?",
		choices = {
			{ text = "🏆 Destroyed the opposition!", effects = { Happiness = 20, Smarts = 8 }, resultText = "Logical. Persuasive. Devastating. You won every argument!", setFlags = {"debate_champion", "persuasive"} },
			{ text = "🤝 Close but lost", effects = { Happiness = 5, Smarts = 5 }, resultText = "Second place. So close. But you'll be back." },
			{ text = "💡 Changed minds", effects = { Happiness = 15, Smarts = 6 }, resultText = "Judges said your arguments were compelling. Even opponents respected you.", setFlag = "persuasive" },
			{ text = "😤 Unfair judging", effects = { Happiness = -8, Smarts = 3 }, resultText = "You were robbed! Politics in debate judging? Injustice!" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- LAW SCHOOL
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "law_lsat",
		minAge = 20, maxAge = 30,
		weight = 20, oneTime = true,
		emoji = "📝", title = "LSAT Results!",
		category = "school",
		requiresFlag = "law_interest",
		getDynamicData = function()
			local scores = {175, 170, 165, 160, 155}
			return { score = scores[math.random(#scores)] }
		end,
		text = "Your LSAT score: %score%! Law school applications are next!",
		choices = {
			{ text = "🎉 Crushed it!", effects = { Happiness = 25, Smarts = 8 }, resultText = "Top 1% score! Yale, Harvard, Stanford are possible!", setFlag = "lsat_ace" },
			{ text = "📊 Good enough", effects = { Happiness = 15, Smarts = 5 }, resultText = "Solid score! Many good law schools are options!", setFlag = "law_school_ready" },
			{ text = "😔 Below expectations", effects = { Happiness = -10, Smarts = 3 }, resultText = "Not what you hoped. Study more and retake?" },
			{ text = "🔄 Retaking", effects = { Happiness = -5, Smarts = 5 }, resultText = "Not accepting that score. More prep. Try again." },
		},
	},
	
	{
		id = "law_school_acceptance",
		minAge = 21, maxAge = 32,
		weight = 18, oneTime = true,
		emoji = "✉️", title = "Law School Decision!",
		category = "school",
		requiresFlag = "law_school_ready",
		getDynamicData = function()
			local schools = {"Harvard Law", "Yale Law", "Stanford Law", "Columbia Law", "your state's law school"}
			return { school = schools[math.random(#schools)] }
		end,
		text = "Opening the letter from %school%... heart pounding...",
		choices = {
			{ text = "🎉 ACCEPTED!", effects = { Happiness = 35, Money = -150000, Smarts = 8 }, resultText = "You're going to be a LAWYER! Three years of legal education ahead!", setFlag = "law_student" },
			{ text = "💰 Scholarship!", effects = { Happiness = 40, Money = -50000, Smarts = 8 }, resultText = "Accepted WITH scholarship! Less debt! Perfect!", setFlags = {"law_student", "law_scholarship"} },
			{ text = "📋 Waitlisted", effects = { Happiness = 5, Smarts = 3 }, resultText = "Not rejected... but not accepted. The waiting is torture." },
			{ text = "❌ Rejected", effects = { Happiness = -20, Smarts = 3 }, resultText = "Devastating. But other schools might say yes. Don't give up." },
		},
	},
	
	{
		id = "law_school_grind",
		minAge = 22, maxAge = 35,
		weight = 25, cooldown = 2,
		emoji = "📚", title = "Law School Struggles",
		category = "school",
		requiresFlag = "law_student",
		getDynamicData = function()
			local challenges = {"Constitutional Law exam", "the Socratic method grilling", "legal writing assignment", "moot court competition", "study group tensions"}
			return { challenge = challenges[math.random(#challenges)] }
		end,
		text = "Currently dealing with: %challenge%. Law school is brutal.",
		choices = {
			{ text = "💪 Made Law Review!", effects = { Happiness = 25, Smarts = 8 }, resultText = "Top grades earned you a spot! Resume gold!", setFlag = "law_review" },
			{ text = "📚 Grinding through", effects = { Happiness = 5, Health = -5, Smarts = 5 }, resultText = "Sleep? What's that? But you're learning." },
			{ text = "😰 Imposter syndrome", effects = { Happiness = -10, Smarts = 3 }, resultText = "Everyone seems smarter. Do you belong here?" },
			{ text = "🤝 Study group saved me", effects = { Happiness = 12, Smarts = 5 }, resultText = "Couldn't do it alone. Your group keeps you sane." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- LEGAL CAREER
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "law_bar_exam",
		minAge = 24, maxAge = 35,
		weight = 20, oneTime = true,
		emoji = "📝", title = "Bar Exam!",
		category = "work",
		requiresFlag = "law_student",
		text = "The bar exam. Two days of hell. Everything you learned, tested.",
		choices = {
			{ text = "✅ PASSED!", effects = { Happiness = 35, Smarts = 5 }, resultText = "You're officially a LAWYER! Licensed to practice! Esq.!", clearFlag = "law_student", setFlags = {"lawyer", "bar_passed"} },
			{ text = "😰 Failed", effects = { Happiness = -25, Smarts = 3 }, resultText = "Devastating. But many great lawyers failed their first time. Study and retake." },
			{ text = "🎉 Top score!", effects = { Happiness = 40, Smarts = 8, Looks = 3 }, resultText = "One of the highest scores in the state! Firms are calling!", clearFlag = "law_student", setFlags = {"lawyer", "bar_passed", "top_bar"} },
			{ text = "😅 Barely passed", effects = { Happiness = 20, Smarts = 3 }, resultText = "A pass is a pass! You're a lawyer now!", clearFlag = "law_student", setFlags = {"lawyer", "bar_passed"} },
		},
	},
	
	{
		id = "law_first_job",
		minAge = 25, maxAge = 36,
		weight = 20, oneTime = true,
		emoji = "👔", title = "First Legal Job!",
		category = "work",
		requiresFlag = "lawyer",
		getDynamicData = function()
			local jobs = {
				{ type = "Big Law firm", salary = 190000, hours = "brutal" },
				{ type = "Public Defender's office", salary = 55000, hours = "heavy" },
				{ type = "District Attorney's office", salary = 60000, hours = "demanding" },
				{ type = "small firm", salary = 70000, hours = "reasonable" },
				{ type = "corporate legal department", salary = 100000, hours = "moderate" },
			}
			local chosen = jobs[math.random(#jobs)]
			return { job = chosen.type, salary = chosen.salary, hours = chosen.hours }
		end,
		text = "You got an offer from %job%! Salary: $%salary%! Hours: %hours%!",
		choices = {
			{ text = "💼 Big Law money!", effects = { Happiness = 15, Money = 190000, Health = -5 }, resultText = "Partner track! 80-hour weeks! Golden handcuffs!", setFlags = {"big_law", "employed"} },
			{ text = "⚖️ Public service", effects = { Happiness = 25, Money = 55000 }, resultText = "Defending those who can't afford lawyers. Noble work.", setFlags = {"public_defender", "employed"} },
			{ text = "🔒 Prosecuting criminals", effects = { Happiness = 20, Money = 60000 }, resultText = "Putting bad guys away. Justice served.", setFlags = {"prosecutor", "employed"} },
			{ text = "⚖️ Work-life balance", effects = { Happiness = 22, Money = 80000, Health = 5 }, resultText = "Not the most money but you have a life outside work.", setFlags = {"balanced_lawyer", "employed"} },
		},
	},
	
	{
		id = "law_big_case",
		minAge = 26, maxAge = 55,
		weight = 25, cooldown = 3,
		emoji = "🏛️", title = "Big Case!",
		category = "work",
		requiresFlag = "lawyer",
		getDynamicData = function()
			local cases = {"murder trial", "corporate merger", "civil rights case", "class action lawsuit", "high-profile divorce"}
			return { caseType = cases[math.random(#cases)] }
		end,
		text = "You're lead attorney on a %caseType%! Career-defining moment!",
		choices = {
			{ text = "🏆 Won the case!", effects = { Happiness = 35, Money = 50000, Smarts = 5 }, resultText = "VERDICT IN YOUR FAVOR! Brilliant strategy! Reputation soaring!", setFlag = "winning_lawyer" },
			{ text = "💔 Lost", effects = { Happiness = -20, Smarts = 5 }, resultText = "Did everything you could. Not every case can be won. Hurts though." },
			{ text = "🤝 Settled favorably", effects = { Happiness = 20, Money = 30000 }, resultText = "Not a trial win but your client got what they wanted. Smart lawyering." },
			{ text = "📺 Media attention", effects = { Happiness = 25, Money = 20000, Looks = 5 }, resultText = "Case made headlines! You're on TV! Famous lawyer status!", setFlags = {"winning_lawyer", "famous_lawyer"} },
		},
	},
	
	{
		id = "law_ethical_dilemma",
		minAge = 28, maxAge = 60,
		weight = 20, cooldown = 4,
		emoji = "⚖️", title = "Ethical Dilemma",
		category = "work",
		requiresFlag = "lawyer",
		text = "Your client confessed something to you privately. Do you have to defend them knowing what you know?",
		choices = {
			{ text = "📜 Follow the ethics rules", effects = { Happiness = 5, Smarts = 5 }, resultText = "Everyone deserves a defense. That's the system. You do your job.", setFlag = "ethical_lawyer" },
			{ text = "😔 Withdraw from case", effects = { Happiness = -5, Money = -10000 }, resultText = "Couldn't do it. Lost the fee but kept your conscience." },
			{ text = "⚖️ Justice vs. duty", effects = { Happiness = -10, Smarts = 5 }, resultText = "The conflict tears at you. Law isn't always justice." },
			{ text = "🤫 It haunts you", effects = { Happiness = -15, Health = -3 }, resultText = "You did your job but... knowing what you know... it's hard." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- JUDICIAL PATH
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "law_judgeship",
		minAge = 40, maxAge = 65,
		weight = 10, oneTime = true,
		emoji = "👨‍⚖️", title = "Judgeship Offered!",
		category = "work",
		requiresFlag = "winning_lawyer",
		getDynamicData = function()
			local courts = {"municipal court", "state court", "federal district court", "appeals court"}
			return { court = courts[math.random(#courts)] }
		end,
		text = "You're being considered for a %court% judgeship!",
		choices = {
			{ text = "👨‍⚖️ Your Honor!", effects = { Happiness = 40, Money = 150000 }, resultText = "Robes. Gavel. Judge YOU presiding. Incredible achievement!", clearFlags = {"big_law", "prosecutor", "public_defender"}, setFlags = {"judge", "judicial"} },
			{ text = "⚖️ Heavy responsibility", effects = { Happiness = 30, Money = 150000, Smarts = 5 }, resultText = "Lives in your hands. Sentences you deliver. Weighty.", clearFlags = {"big_law", "prosecutor", "public_defender"}, setFlag = "judge" },
			{ text = "🏛️ Lifetime appointment", effects = { Happiness = 35, Money = 160000 }, resultText = "Federal judge! Appointed for life! Ultimate job security!", clearFlags = {"big_law", "prosecutor", "public_defender"}, setFlags = {"federal_judge", "lifetime_appointment"} },
			{ text = "🙅 Stay an advocate", effects = { Happiness = 15 }, resultText = "You love arguing cases. Being neutral isn't for you." },
		},
	},
	
	{
		id = "law_landmark_ruling",
		minAge = 45, maxAge = 75,
		weight = 8, oneTime = true,
		emoji = "📜", title = "Landmark Ruling!",
		category = "work",
		requiresFlag = "judge",
		text = "A case before you could set precedent. Your ruling will be studied for decades.",
		choices = {
			{ text = "⚖️ Historic decision", effects = { Happiness = 40, Smarts = 10 }, resultText = "Your ruling changed the law. Textbooks will quote you. Legal history made.", setFlag = "landmark_judge" },
			{ text = "📚 Carefully reasoned", effects = { Happiness = 35, Smarts = 8 }, resultText = "Your legal reasoning was airtight. Upheld on appeal. Proud.", setFlag = "respected_judge" },
			{ text = "🔥 Controversial", effects = { Happiness = 20, Looks = -3 }, resultText = "Half the country loves you, half hates you. But you called it as you saw it.", setFlags = {"landmark_judge", "controversial"} },
			{ text = "😔 Overturned", effects = { Happiness = -15, Smarts = 3 }, resultText = "Appeals court reversed you. Stings. But that's the system." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- LEGACY
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "law_supreme_court",
		minAge = 50, maxAge = 70,
		weight = 3, oneTime = true,
		emoji = "🏛️", title = "SUPREME COURT!",
		category = "work",
		requiresFlag = "federal_judge",
		text = "The President wants to nominate you to the SUPREME COURT!",
		choices = {
			{ text = "🏛️ Confirmed!", effects = { Happiness = 60, Money = 250000, Looks = 10, Smarts = 10 }, resultText = "JUSTICE YOU! Highest court in the land! Legacy for the ages!", setFlags = {"supreme_court", "justice"} },
			{ text = "🎤 Brutal hearings", effects = { Happiness = 30, Money = 250000, Health = -10 }, resultText = "Confirmation was ugly but you made it. Justice at last.", setFlags = {"supreme_court", "justice"} },
			{ text = "❌ Nomination failed", effects = { Happiness = -30 }, resultText = "Political opposition tanked you. Heartbreaking. So close to history." },
			{ text = "🙅 Declined nomination", effects = { Happiness = 10, Health = 5 }, resultText = "The spotlight, the politics... not worth it. Happy where you are." },
		},
	},
	
	{
		id = "law_retirement_legacy",
		minAge = 60, maxAge = 80,
		weight = 15, oneTime = true,
		emoji = "⚖️", title = "Legal Legacy",
		category = "work",
		requiresFlag = "lawyer",
		getDynamicData = function()
			local years = math.random(30, 45)
			local cases = math.random(100, 1000)
			return { years = years, cases = cases }
		end,
		text = "After %years% years and %cases% cases. Reflecting on your legal career.",
		choices = {
			{ text = "⚖️ Justice served", effects = { Happiness = 35 }, resultText = "You fought for what was right. Made a difference. That's enough.", setFlag = "retired_lawyer" },
			{ text = "🏫 Law school named after you", effects = { Happiness = 45, Looks = 5 }, resultText = "Your name on the building. Training future lawyers. Immortalized.", setFlags = {"retired_lawyer", "legal_legend"} },
			{ text = "📚 Wrote legal textbook", effects = { Happiness = 35, Money = 100000, Smarts = 5 }, resultText = "Your casebook trains thousands of law students. Knowledge lives on.", setFlag = "retired_lawyer" },
			{ text = "👨‍👩‍👧 Family of lawyers", effects = { Happiness = 38 }, resultText = "Your child became a lawyer too. The tradition continues.", setFlags = {"retired_lawyer", "legal_dynasty"} },
		},
	},
}

return module
