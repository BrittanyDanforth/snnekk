-- LifeEvents/career_legal.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- LEGAL CAREER EVENTS - Lawyers, Judges, Legal System
-- BitLife-style: Player picks ACTIONS, game decides OUTCOMES
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent.init)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- EARLY INTEREST
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "legal_mock_trial",
		minAge = 14, maxAge = 18,
		weight = 25, oneTime = true,
		emoji = "⚖️", title = "Mock Trial Competition!",
		category = "school",
		text = "Your school has a mock trial team! Argue fake cases in front of real judges. Interested?",
		choices = {
			{ text = "⚖️ Join as attorney", effects = { Happiness = 15, Smarts = 10 }, resultText = "OBJECTION! You're a natural! Love the courtroom drama!", setFlags = {"legal_interest", "mock_trial"} },
			{ text = "🎭 Be a witness", effects = { Happiness = 10, Smarts = 5 }, resultText = "Playing characters on the stand! Fun way to participate!", setFlag = "legal_interest" },
			{ text = "📋 Help with research", effects = { Happiness = 8, Smarts = 8 }, resultText = "Behind the scenes work! Learning how cases are built!", setFlag = "legal_interest" },
			{ text = "🙅 Not interested", effects = { Happiness = 3 }, resultText = "Law isn't your thing. That's okay!" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- LAW SCHOOL PATH
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "legal_lsat",
		minAge = 20, maxAge = 25,
		weight = 20, oneTime = true,
		emoji = "📝", title = "LSAT Day!",
		category = "school",
		requiresFlag = "legal_interest",
		text = "The LSAT - the test that determines your law school options! 4 hours of logic puzzles! How do you do?",
		choices = {
			{ text = "🧠 Crush it - 170+", effects = { Happiness = 30, Smarts = 10 }, resultText = "Top percentile! Harvard and Yale are calling!", setFlags = {"lsat_ace", "law_school_bound"} },
			{ text = "📊 Solid score - 160s", effects = { Happiness = 18, Smarts = 5 }, resultText = "Good schools within reach! Competitive applicant!", setFlag = "law_school_bound" },
			{ text = "😰 Underperformed", effects = { Happiness = -10 }, resultText = "Test day nerves got you. Study more, retake later." },
			{ text = "🎯 Just hit your target", effects = { Happiness = 15, Smarts = 3 }, resultText = "Got what you needed! Doors are open!", setFlag = "law_school_bound" },
		},
	},
	
	{
		id = "legal_law_school",
		minAge = 22, maxAge = 28,
		weight = 18, oneTime = true,
		emoji = "🎓", title = "Law School!",
		category = "school",
		requiresFlag = "law_school_bound",
		getDynamicData = function()
			local schools = {"Harvard", "Yale", "Stanford", "Columbia", "a T14 school", "a regional school"}
			return { school = schools[math.random(#schools)] }
		end,
		text = "Accepted to %school% Law! Three years of grueling work ahead. How do you approach it?",
		choices = {
			{ text = "📚 Gunner mode - top of class", effects = { Smarts = 15, Happiness = -5, Health = -5 }, resultText = "Law Review! Top 10%! Big Law is guaranteed!", setFlags = {"law_student", "top_of_class"}, clearFlag = "law_school_bound" },
			{ text = "⚖️ Clinic work focus", effects = { Smarts = 10, Happiness = 10 }, resultText = "Real cases! Helping real people! Public interest calling!", setFlags = {"law_student", "public_interest"}, clearFlag = "law_school_bound" },
			{ text = "🍺 Law school life balance", effects = { Smarts = 8, Happiness = 8 }, resultText = "Good enough grades AND a social life! Healthy approach!", setFlag = "law_student", clearFlag = "law_school_bound" },
			{ text = "😔 Struggle and doubt", effects = { Smarts = 5, Happiness = -10 }, resultText = "This is SO hard. Is law even right for you? Pushing through...", setFlag = "law_student", clearFlag = "law_school_bound" },
		},
	},
	
	{
		id = "legal_bar_exam",
		minAge = 25, maxAge = 32,
		weight = 20, oneTime = true,
		emoji = "📝", title = "Bar Exam!",
		category = "work",
		requiresFlag = "law_student",
		text = "THE BAR EXAM! Two days of testing everything you learned. Pass this or can't practice law. How does it go?",
		choices = {
			{ text = "✅ Passed first try!", effects = { Happiness = 35, Smarts = 5 }, resultText = "YOU'RE A LAWYER! Bar card coming! Can officially practice!", setFlags = {"attorney", "bar_passed"}, clearFlag = "law_student" },
			{ text = "😰 Failed... devastated", effects = { Happiness = -25, Money = -3000 }, resultText = "Didn't pass. SO many people fail. Take it again. You can do this." },
			{ text = "🎯 Passed barely", effects = { Happiness = 20 }, resultText = "A pass is a pass! No one asks your bar score! You're a lawyer!", setFlags = {"attorney", "bar_passed"}, clearFlag = "law_student" },
			{ text = "😬 Still waiting for results", effects = { Happiness = -15 }, resultText = "The anxiety of waiting is the worst part. Months of limbo." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- LEGAL CAREER
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "legal_first_job",
		minAge = 25, maxAge = 32,
		weight = 20, oneTime = true,
		emoji = "💼", title = "First Legal Job!",
		category = "work",
		requiresFlag = "attorney",
		text = "Time to start your legal career! What path do you take?",
		choices = {
			{ text = "🏛️ Big Law firm", effects = { Happiness = 10, Money = 200000, Health = -10 }, resultText = "200k starting! Billing 80 hours a week! Brutal but lucrative!", setFlags = {"biglaw", "corporate_lawyer"} },
			{ text = "⚖️ Public defender", effects = { Happiness = 15, Money = 55000 }, resultText = "Fighting for those who can't afford lawyers! Noble calling!", setFlags = {"public_defender", "courtroom_lawyer"} },
			{ text = "🏛️ Prosecutor", effects = { Happiness = 12, Money = 65000 }, resultText = "Seeking justice! In court every day! Trial experience!", setFlags = {"prosecutor", "courtroom_lawyer"} },
			{ text = "🏠 Start own practice", effects = { Happiness = 18, Money = 30000 }, resultText = "Your own boss! Chasing clients! Entrepreneurial lawyer!", setFlags = {"solo_practice", "own_firm"} },
		},
	},
	
	{
		id = "legal_first_trial",
		minAge = 26, maxAge = 45,
		weight = 20, oneTime = true,
		emoji = "🎤", title = "Your First Trial!",
		category = "work",
		requiresFlag = "courtroom_lawyer",
		text = "First time as lead attorney in a trial! Jury watching. Client depending on you. Opening statement time!",
		choices = {
			{ text = "🔥 Commanding presence", effects = { Happiness = 25, Smarts = 5, Looks = 3 }, resultText = "NAILED IT! Jury was captivated! Won the case! Future trial star!", setFlags = {"trial_lawyer", "winning_record"} },
			{ text = "📋 Methodical and prepared", effects = { Happiness = 18, Smarts = 8 }, resultText = "Solid work. Won on the facts. Not flashy but effective!", setFlag = "trial_lawyer" },
			{ text = "😰 Nervous but got through", effects = { Happiness = 10, Smarts = 3 }, resultText = "Shaky start but found your footing. Experience helps!" },
			{ text = "💔 Lost the case", effects = { Happiness = -15, Smarts = 5 }, resultText = "They found against your client. Devastating but you learned a lot.", setFlag = "trial_experience" },
		},
	},
	
	{
		id = "legal_big_case",
		minAge = 30, maxAge = 55,
		weight = 15, cooldown = 4,
		emoji = "⚖️", title = "Career-Defining Case!",
		category = "work",
		requiresFlag = "trial_lawyer",
		getDynamicData = function()
			local cases = {"murder trial", "class action lawsuit", "high-profile corruption case", "landmark civil rights case"}
			return { caseType = cases[math.random(#cases)] }
		end,
		text = "Assigned to a major %caseType%! Media attention! This could make or break your career. How do you handle it?",
		choices = {
			{ text = "💪 Rise to the occasion", effects = { Happiness = 35, Money = 100000, Looks = 5 }, resultText = "WON THE CASE! You're famous in legal circles! Career made!", setFlags = {"famous_lawyer", "landmark_win"} },
			{ text = "🤝 Build the best team", effects = { Happiness = 28, Money = 80000 }, resultText = "Team effort wins! You're a leader! Reputation enhanced!", setFlag = "respected_attorney" },
			{ text = "😰 Crack under pressure", effects = { Happiness = -20, Money = -10000 }, resultText = "Made mistakes. Lost badly. Very public failure. Recovery needed." },
			{ text = "💰 Settle it out", effects = { Happiness = 15, Money = 50000 }, resultText = "Negotiated a good settlement. No trial glory but good outcome." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- ETHICAL DILEMMAS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "legal_ethics_dilemma",
		minAge = 28, maxAge = 60,
		weight = 20, cooldown = 4,
		emoji = "🤔", title = "Ethical Dilemma!",
		category = "work",
		requiresFlag = "attorney",
		text = "You discover evidence that helps your client but was obtained unethically. What do you do?",
		choices = {
			{ text = "🚫 Report it properly", effects = { Happiness = 10, Smarts = 8 }, resultText = "Did the right thing. Ethics over winning. Sleep well.", setFlag = "ethical_attorney" },
			{ text = "😬 Use it anyway", effects = { Happiness = -10, Money = 20000 }, resultText = "Won the case but compromised your integrity. Worth it?", setFlag = "morally_gray" },
			{ text = "📋 Consult ethics board", effects = { Happiness = 5, Smarts = 10 }, resultText = "Got proper guidance. Covered yourself. Professional approach." },
			{ text = "🔄 Find another way to win", effects = { Happiness = 15, Smarts = 8 }, resultText = "Found legitimate evidence! Won ethically! Best outcome!", setFlag = "ethical_attorney" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- ADVANCEMENT / JUDGESHIP
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "legal_partnership",
		minAge = 32, maxAge = 50,
		weight = 15, oneTime = true,
		emoji = "🏛️", title = "Partnership Offer!",
		category = "work",
		requiresFlag = "biglaw",
		text = "After years of grinding, offered PARTNER at the firm! Your name on the door! But more hours. What do you do?",
		choices = {
			{ text = "✅ Accept partnership", effects = { Happiness = 25, Money = 500000, Health = -5 }, resultText = "PARTNER! Equity stake! Massive income! You've made it!", setFlags = {"law_partner", "made_it"} },
			{ text = "🏠 Leave for work-life balance", effects = { Happiness = 20, Money = 150000, Health = 10 }, resultText = "Left Big Law for sanity. In-house counsel! Normal hours!", setFlag = "in_house_counsel" },
			{ text = "⚖️ Switch to public service", effects = { Happiness = 22, Money = 80000 }, resultText = "Enough money-chasing. Time to do meaningful work.", setFlag = "public_service_lawyer" },
			{ text = "🏛️ Start your own firm", effects = { Happiness = 18, Money = 100000 }, resultText = "Your own name, your own rules! Risky but liberating!", setFlag = "own_firm" },
		},
	},
	
	{
		id = "legal_judgeship",
		minAge = 45, maxAge = 70,
		weight = 10, oneTime = true,
		emoji = "⚖️", title = "Judicial Appointment!",
		category = "work",
		requiresFlag = "famous_lawyer",
		getDynamicData = function()
			local courts = {"state court", "federal district court", "appellate court"}
			return { court = courts[math.random(#courts)] }
		end,
		text = "Nominated for %court% judge! Lifetime appointment possibility! The Senate/governor approval pending!",
		choices = {
			{ text = "🏛️ Accept with honor", effects = { Happiness = 40, Money = 200000, Looks = 5 }, resultText = "Confirmed! Your Honor! Robes and gavel! Dream achieved!", setFlags = {"judge", "judicial"}, clearFlags = {"attorney", "trial_lawyer"} },
			{ text = "📋 Survive confirmation", effects = { Happiness = 30, Money = 180000 }, resultText = "Tough hearing but confirmed! Now dispensing justice!", setFlag = "judge" },
			{ text = "❌ Nomination fails", effects = { Happiness = -20 }, resultText = "Political opposition sank it. Devastating but return to practice." },
			{ text = "🙅 Decline the nomination", effects = { Happiness = 10 }, resultText = "Not ready to give up advocacy. Continued practicing." },
		},
	},
	
	{
		id = "legal_supreme_court",
		minAge = 50, maxAge = 75,
		weight = 3, oneTime = true,
		emoji = "🏛️", title = "SUPREME COURT?!",
		category = "work",
		requiresFlag = "judge",
		text = "The President wants to nominate you for THE SUPREME COURT! The highest honor in law! What do you do?",
		choices = {
			{ text = "✅ Accept the honor", effects = { Happiness = 50, Money = 300000, Looks = 10 }, resultText = "SUPREME COURT JUSTICE! Shaping law for generations! LEGENDARY!", setFlag = "scotus" },
			{ text = "😰 Survive brutal hearings", effects = { Happiness = 35, Money = 280000, Health = -10 }, resultText = "They dug into EVERYTHING. Confirmed but traumatized. Worth it?", setFlag = "scotus" },
			{ text = "❌ Withdraw nomination", effects = { Happiness = -15 }, resultText = "Too much scrutiny. Withdrew before confirmation. Privacy preserved." },
			{ text = "💔 Not confirmed", effects = { Happiness = -30 }, resultText = "Senate rejected you. Public humiliation. But still a respected judge." },
		},
	},
}

return module
