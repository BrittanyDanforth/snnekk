-- LifeEvents/career_education.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- EDUCATION CAREER EVENTS - Teachers, Professors, Educators
-- BitLife-style: Player picks ACTIONS, game decides OUTCOMES
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent.init)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- EARLY CALLING
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "edu_helping_classmates",
		minAge = 10, maxAge = 16,
		weight = 25, oneTime = true,
		emoji = "📚", title = "Natural Teacher!",
		category = "school",
		text = "You're always helping classmates understand things. Teacher noticed you explaining concepts really well!",
		choices = {
			{ text = "📚 Love helping others learn", effects = { Happiness = 15, Smarts = 8 }, resultText = "Teaching comes naturally! Maybe this is your calling!", setFlags = {"teacher_potential", "helper"} },
			{ text = "🤷 Just being nice", effects = { Happiness = 8, Smarts = 3 }, resultText = "Helping out when you can. Nothing more." },
			{ text = "💰 Start charging for tutoring", effects = { Happiness = 10, Money = 100, Smarts = 5 }, resultText = "Entrepreneurial! Getting paid to help! Smart!", setFlag = "tutor" },
			{ text = "😤 Don't want that reputation", effects = { Happiness = -3 }, resultText = "Being the 'nerd who helps' isn't cool. Or is it?" },
		},
	},
	
	{
		id = "edu_tutoring_gig",
		minAge = 14, maxAge = 22,
		weight = 20, cooldown = 3,
		emoji = "📝", title = "Tutoring Opportunity!",
		category = "school",
		getDynamicData = function()
			local subjects = {"math", "science", "writing", "foreign language", "test prep"}
			return { subject = subjects[math.random(#subjects)] }
		end,
		text = "Someone needs a tutor for %subject%! $20/hour. Do you take it?",
		choices = {
			{ text = "📚 Take the job", effects = { Happiness = 12, Money = 500, Smarts = 5 }, resultText = "Great experience! Student improved! You're a good teacher!", setFlag = "tutoring_experience" },
			{ text = "💰 Negotiate higher rate", effects = { Happiness = 10, Money = 700, Smarts = 3 }, resultText = "$30/hour! Know your worth! Student still happy!", setFlag = "tutoring_experience" },
			{ text = "🙅 Too busy", effects = { Happiness = 3 }, resultText = "Passed on the opportunity. Schedule is packed." },
			{ text = "😬 Terrible at that subject", effects = { Happiness = 5, Smarts = 2 }, resultText = "Not your strength. Referred them to someone else." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- EDUCATION PATH
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "edu_degree_choice",
		minAge = 18, maxAge = 22,
		weight = 18, oneTime = true,
		emoji = "🎓", title = "College Major Decision!",
		category = "school",
		requiresFlag = "teacher_potential",
		text = "Time to choose your path! Education degree or subject specialty?",
		choices = {
			{ text = "🎓 Education major", effects = { Smarts = 10, Happiness = 12 }, resultText = "Learning how to teach! Pedagogy, psychology, classroom management!", setFlags = {"education_major", "college_student"} },
			{ text = "📚 Subject + teaching cert", effects = { Smarts = 12, Happiness = 10 }, resultText = "Deep knowledge in your subject! Will get teaching credential later!", setFlags = {"subject_expert", "college_student"} },
			{ text = "🔬 Go for PhD eventually", effects = { Smarts = 15, Happiness = 8 }, resultText = "Professor path! Research and teaching at the highest level!", setFlags = {"academic_track", "college_student"} },
			{ text = "🤔 Still deciding", effects = { Smarts = 5, Happiness = 5 }, resultText = "Keeping options open for now." },
		},
	},
	
	{
		id = "edu_student_teaching",
		minAge = 21, maxAge = 26,
		weight = 20, oneTime = true,
		emoji = "🏫", title = "Student Teaching!",
		category = "work",
		requiresFlag = "education_major",
		text = "Time for student teaching! First real classroom experience! Mentor teacher watching. How do you do?",
		choices = {
			{ text = "🌟 Natural in the classroom", effects = { Happiness = 25, Smarts = 8, Looks = 3 }, resultText = "Kids love you! Mentor says you're a natural! Teaching is definitely your calling!", setFlags = {"teacher_ready", "classroom_natural"} },
			{ text = "📚 Struggled but learned", effects = { Happiness = 12, Smarts = 10 }, resultText = "Rough start but improved! The learning curve is real!", setFlag = "teacher_ready" },
			{ text = "😰 Classroom management issues", effects = { Happiness = -10, Smarts = 5 }, resultText = "Kids walked all over you. Need to develop authority. Struggle is real." },
			{ text = "💔 This isn't for me", effects = { Happiness = -15 }, resultText = "Realized teaching isn't your path. Saved yourself from wrong career.", clearFlag = "education_major" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- TEACHING CAREER
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "edu_first_job",
		minAge = 22, maxAge = 30,
		weight = 20, oneTime = true,
		emoji = "🏫", title = "First Teaching Job!",
		category = "work",
		requiresFlag = "teacher_ready",
		getDynamicData = function()
			local schools = {"inner-city school", "suburban district", "private academy", "charter school", "rural district"}
			return { school = schools[math.random(#schools)] }
		end,
		text = "Job offer at a %school%! Your own classroom! What's your approach?",
		choices = {
			{ text = "✅ Take it, excited!", effects = { Happiness = 20, Money = 45000 }, resultText = "YOUR classroom! First day jitters! This is really happening!", setFlags = {"teacher", "employed"} },
			{ text = "📋 Negotiate for more", effects = { Happiness = 18, Money = 50000 }, resultText = "Got a bit more! Teachers should negotiate too!", setFlags = {"teacher", "employed"} },
			{ text = "🤔 Hold out for better", effects = { Happiness = -5, Money = 0 }, resultText = "Turned it down. Hope something better comes..." },
			{ text = "🎯 Accept at tough school", effects = { Happiness = 15, Money = 48000 }, resultText = "The kids who need help most. Challenging but meaningful!", setFlags = {"teacher", "employed", "tough_assignment"} },
		},
	},
	
	{
		id = "edu_first_year",
		minAge = 22, maxAge = 32,
		weight = 25, oneTime = true,
		emoji = "😅", title = "First Year Teaching!",
		category = "work",
		requiresFlag = "teacher",
		text = "First year is ROUGH! Lesson planning until midnight! Difficult students! How do you survive?",
		choices = {
			{ text = "💪 Push through it", effects = { Happiness = 8, Health = -10, Smarts = 8 }, resultText = "Survived! Barely. They say second year is easier...", setFlag = "first_year_survivor" },
			{ text = "🤝 Lean on mentor teachers", effects = { Happiness = 15, Smarts = 10 }, resultText = "Veterans helped SO much! Learning from experience!", setFlag = "first_year_survivor" },
			{ text = "😭 Cry a lot", effects = { Happiness = -5, Health = -5 }, resultText = "Lots of tears. Is this worth it? But the kids need you...", setFlag = "first_year_survivor" },
			{ text = "🚪 Quit before winter break", effects = { Happiness = -20 }, resultText = "Couldn't handle it. Joined the 50% who leave teaching early.", clearFlags = {"teacher", "employed"} },
		},
	},
	
	{
		id = "edu_breakthrough_student",
		minAge = 24, maxAge = 60,
		weight = 20, cooldown = 3,
		emoji = "💡", title = "Student Breakthrough!",
		category = "work",
		requiresFlag = "teacher",
		getDynamicData = function()
			return { studentName = LifeEvents.randomFirstName() }
		end,
		text = "%studentName%, who was struggling all year, finally got it! The light bulb moment! How do you feel?",
		choices = {
			{ text = "🥹 This is why I teach", effects = { Happiness = 30 }, resultText = "THIS moment! Worth every hard day! You made a difference!", setFlag = "teacher_passion" },
			{ text = "📈 Document for records", effects = { Happiness = 15, Smarts = 3 }, resultText = "Progress tracked! Evidence for evaluations! Professional win!" },
			{ text = "🎉 Celebrate with class", effects = { Happiness = 20, Looks = 3 }, resultText = "Whole class celebrated! Created a positive culture!" },
			{ text = "🤷 One student, many more", effects = { Happiness = 10 }, resultText = "Good but the work never ends. 29 other students need help." },
		},
	},
	
	{
		id = "edu_difficult_parent",
		minAge = 24, maxAge = 60,
		weight = 20, cooldown = 2,
		emoji = "😤", title = "Angry Parent!",
		category = "work",
		requiresFlag = "teacher",
		text = "Parent is FURIOUS about their child's grade! Demanding answers! What do you do?",
		choices = {
			{ text = "📋 Show all documentation", effects = { Happiness = 10, Smarts = 5 }, resultText = "Had everything documented! Parent backed down. Always keep records!" },
			{ text = "🤝 Listen and empathize", effects = { Happiness = 12, Looks = 3 }, resultText = "Heard them out. Found middle ground. Crisis averted." },
			{ text = "😤 Stand your ground", effects = { Happiness = -5, Smarts = 3 }, resultText = "Wouldn't budge. Grade stays. Parent went to principal. Drama." },
			{ text = "😰 Cave to pressure", effects = { Happiness = -15, Smarts = -5 }, resultText = "Changed the grade... now every parent knows you can be pushed around." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- CAREER ADVANCEMENT
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "edu_department_head",
		minAge = 30, maxAge = 55,
		weight = 15, oneTime = true,
		emoji = "📊", title = "Department Head Offer!",
		category = "work",
		requiresFlag = "teacher_passion",
		text = "Offered Department Head position! More money, more admin work, less direct teaching. What do you do?",
		choices = {
			{ text = "✅ Accept the role", effects = { Happiness = 15, Money = 15000 }, resultText = "Leading the department! Shaping curriculum! Growth opportunity!", setFlags = {"department_head", "admin_track"} },
			{ text = "❌ Stay in classroom", effects = { Happiness = 20, Money = 5000 }, resultText = "Teaching is where your heart is. More impact in the classroom!" },
			{ text = "📋 Negotiate better terms", effects = { Happiness = 18, Money = 18000 }, resultText = "Got more money AND reduced admin meetings! Best of both!" },
			{ text = "🤔 Ask for time to decide", effects = { Happiness = 8 }, resultText = "Taking time to think. Big decision." },
		},
	},
	
	{
		id = "edu_principal_track",
		minAge = 35, maxAge = 55,
		weight = 12, oneTime = true,
		emoji = "🏫", title = "Become a Principal?",
		category = "work",
		requiresFlag = "admin_track",
		text = "District offering to put you on principal track! Lead a whole school! But you'd leave teaching entirely.",
		choices = {
			{ text = "🏫 Go for principal", effects = { Happiness = 20, Money = 40000 }, resultText = "Admin credential program! Principal track! School leader!", setFlags = {"principal_track", "administrator"} },
			{ text = "📚 Stay in instruction", effects = { Happiness = 18, Smarts = 5 }, resultText = "Teaching and curriculum is your zone. Impact from the classroom!" },
			{ text = "🎓 Become a coach instead", effects = { Happiness = 22, Money = 20000 }, resultText = "Instructional coach! Help other teachers improve! Best role!", setFlag = "instructional_coach" },
			{ text = "📊 District admin role", effects = { Happiness = 15, Money = 35000 }, resultText = "Central office! Policy and curriculum at scale!", setFlag = "district_admin" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- PROFESSOR / HIGHER ED PATH
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "edu_phd_decision",
		minAge = 24, maxAge = 35,
		weight = 15, oneTime = true,
		emoji = "🎓", title = "PhD Opportunity!",
		category = "school",
		requiresFlag = "academic_track",
		getDynamicData = function()
			local schools = {"Harvard", "Stanford", "Berkeley", "a top research university", "your dream school"}
			return { school = schools[math.random(#schools)] }
		end,
		text = "Accepted to PhD program at %school%! 5-7 years. Professor path begins. Do you go?",
		choices = {
			{ text = "🎓 Pursue the PhD", effects = { Smarts = 20, Money = -50000, Happiness = 15 }, resultText = "Graduate student life! Research begins! Long road but worth it!", setFlags = {"phd_student", "academic"}, clearFlag = "academic_track" },
			{ text = "💰 Funded position!", effects = { Smarts = 18, Money = 25000, Happiness = 18 }, resultText = "FULLY FUNDED! Stipend and tuition! No debt! Dream!", setFlags = {"phd_student", "academic"} },
			{ text = "🙅 Stay in K-12", effects = { Happiness = 10 }, resultText = "Decided the professor path isn't for you. K-12 is rewarding!" },
			{ text = "⏳ Defer a year", effects = { Happiness = 5 }, resultText = "Taking a gap year before committing. Smart to be sure." },
		},
	},
	
	{
		id = "edu_tenure_track",
		minAge = 30, maxAge = 45,
		weight = 12, oneTime = true,
		emoji = "📚", title = "Tenure-Track Position!",
		category = "work",
		requiresFlag = "phd_student",
		getDynamicData = function()
			local schools = {"a research university", "a liberal arts college", "your alma mater", "a prestigious institution"}
			return { school = schools[math.random(#schools)] }
		end,
		text = "Offered tenure-track professor position at %school%! Publish or perish begins! What do you do?",
		choices = {
			{ text = "✅ Accept the position", effects = { Happiness = 25, Money = 80000 }, resultText = "Professor [Your Name]! Office hours, research, students! Dream job!", setFlags = {"professor", "tenure_track"}, clearFlag = "phd_student" },
			{ text = "📋 Negotiate package", effects = { Happiness = 23, Money = 95000, Smarts = 5 }, resultText = "Better salary, research funds, reduced teaching load! Negotiated well!", setFlags = {"professor", "tenure_track"} },
			{ text = "🤔 Industry instead", effects = { Happiness = 15, Money = 150000 }, resultText = "Left academia for industry! More money, less prestige!", setFlag = "industry_phd" },
			{ text = "😔 No offers", effects = { Happiness = -20, Money = 0 }, resultText = "Job market brutal. Adjunct life for now. Keep applying." },
		},
	},
	
	{
		id = "edu_tenure_decision",
		minAge = 35, maxAge = 50,
		weight = 10, oneTime = true,
		emoji = "🏛️", title = "Tenure Review!",
		category = "work",
		requiresFlag = "tenure_track",
		text = "THE tenure review. 6 years of work. Committee deciding your future. Have you published enough?",
		choices = {
			{ text = "🎉 TENURE GRANTED!", effects = { Happiness = 40, Money = 20000 }, resultText = "TENURED PROFESSOR! Job security! Academic freedom! Made it!", setFlags = {"tenured", "established_professor"} },
			{ text = "📚 Strong research saved you", effects = { Happiness = 35, Money = 15000 }, resultText = "Publications were strong! Tenure earned through scholarship!", setFlags = {"tenured", "respected_researcher"} },
			{ text = "💔 Tenure denied", effects = { Happiness = -30 }, resultText = "Devastating. Have to leave. Six years... for nothing. Start over elsewhere." },
			{ text = "🔄 Given one more year", effects = { Happiness = -10 }, resultText = "Not denied but not granted. One more year to prove yourself. Stressful." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- LEGACY
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "edu_former_student_success",
		minAge = 35, maxAge = 80,
		weight = 15, cooldown = 5,
		emoji = "🌟", title = "Former Student Success!",
		category = "social",
		requiresFlag = "teacher",
		getDynamicData = function()
			local achievements = {"became a doctor", "published a book", "started a successful company", "became a teacher themselves", "won a major award"}
			return { achievement = achievements[math.random(#achievements)] }
		end,
		text = "A former student reached out - they %achievement%! They credited YOU for inspiring them!",
		choices = {
			{ text = "😭 Tears of joy", effects = { Happiness = 35 }, resultText = "THIS is why you became a teacher. Impact that lasts forever." },
			{ text = "🤝 Reconnect with them", effects = { Happiness = 25 }, resultText = "Grabbed coffee. Heard their journey. Beautiful full circle.", addRelationship = { category = "friends", dynamicNameKey = nil, startingRelationship = 80, type = "former_student" } },
			{ text = "📢 Share the story", effects = { Happiness = 20, Looks = 3 }, resultText = "Posted about it! Inspiring others! Teaching matters!" },
			{ text = "🙏 Quietly grateful", effects = { Happiness = 30 }, resultText = "Private joy. No need to share. You know what you did." },
		},
	},
}

return module
