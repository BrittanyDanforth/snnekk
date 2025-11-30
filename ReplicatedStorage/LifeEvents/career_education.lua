-- LifeEvents/career_education.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- EDUCATION CAREER EVENTS
-- Teachers, Professors, Principals, Tutors - Shaping minds
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent.init)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- EARLY CALLING TO TEACH
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "edu_childhood_teacher_play",
		minAge = 6, maxAge = 12,
		weight = 25, oneTime = true,
		emoji = "👩‍🏫", title = "Playing Teacher!",
		category = "family",
		text = "You set up a classroom and 'teach' your stuffed animals and siblings!",
		choices = {
			{ text = "📚 I love explaining things!", effects = { Happiness = 12, Smarts = 5 }, resultText = "Teaching comes naturally to you! Maybe this is your future?", setFlag = "teacher_interest" },
			{ text = "🎒 School is fun", effects = { Happiness = 10, Smarts = 3 }, resultText = "You actually enjoy learning and sharing knowledge!", setFlag = "loves_learning" },
			{ text = "🤷 Just playing", effects = { Happiness = 6 }, resultText = "It's fun but just a game." },
			{ text = "💯 Giving grades!", effects = { Happiness = 8, Smarts = 3 }, resultText = "The power! Red pen ready! A+ for your teddy bear!", setFlag = "teacher_interest" },
		},
	},
	
	{
		id = "edu_tutoring_peers",
		minAge = 14, maxAge = 22,
		weight = 25, cooldown = 3,
		emoji = "📖", title = "Tutoring Others",
		category = "school",
		requiresFlag = "loves_learning",
		getDynamicData = function()
			local subjects = {"math", "English", "science", "history", "a foreign language"}
			return { subject = subjects[math.random(#subjects)] }
		end,
		text = "You're helping struggling classmates with %subject%. They're actually getting it!",
		choices = {
			{ text = "💡 Love the 'aha' moment", effects = { Happiness = 15, Smarts = 3 }, resultText = "When it clicks for them... best feeling ever! Teaching is rewarding!", setFlags = {"tutor", "teaching_gift"} },
			{ text = "💰 Started charging", effects = { Happiness = 10, Money = 500, Smarts = 2 }, resultText = "Tutoring business! Getting paid to help!", setFlag = "tutor" },
			{ text = "😤 Frustrating", effects = { Happiness = -3, Smarts = 3 }, resultText = "Why don't they get it?! Teaching is harder than it looks." },
			{ text = "🌟 Natural teacher", effects = { Happiness = 12, Smarts = 5 }, resultText = "You have a gift for explaining things simply. Students love you!", setFlags = {"tutor", "teaching_gift"} },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- BECOMING A TEACHER
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "edu_teaching_degree",
		minAge = 20, maxAge = 30,
		weight = 20, oneTime = true,
		emoji = "🎓", title = "Education Degree!",
		category = "school",
		requiresFlag = "teacher_interest",
		getDynamicData = function()
			local specialties = {"Elementary Education", "Secondary Education", "Special Education", "Early Childhood", "Physical Education"}
			return { specialty = specialties[math.random(#specialties)] }
		end,
		text = "Finished your degree in %specialty%! Ready to shape young minds!",
		choices = {
			{ text = "📚 Born to teach!", effects = { Happiness = 20, Smarts = 5 }, resultText = "Certified and ready! Time to make a difference!", setFlags = {"certified_teacher", "education_career"} },
			{ text = "😰 Student teaching was hard", effects = { Happiness = 8, Smarts = 5 }, resultText = "Real classrooms are chaos. But you survived. Degree in hand!", setFlag = "certified_teacher" },
			{ text = "💡 Discovered your passion", effects = { Happiness = 18, Smarts = 3 }, resultText = "Those practice lessons confirmed it. This is YOUR calling!", setFlags = {"certified_teacher", "passionate_teacher"} },
			{ text = "🤔 Reconsidering", effects = { Happiness = -5, Smarts = 3 }, resultText = "Is this really what you want? Teaching isn't for everyone." },
		},
	},
	
	{
		id = "edu_first_job",
		minAge = 22, maxAge = 35,
		weight = 20, oneTime = true,
		emoji = "🏫", title = "First Teaching Job!",
		category = "work",
		requiresFlag = "certified_teacher",
		getDynamicData = function()
			local schools = {"an elementary school", "a middle school", "a high school", "a private academy", "a charter school"}
			local salary = math.random(35, 55)
			return { school = schools[math.random(#schools)], salary = salary }
		end,
		text = "You got hired at %school%! Starting salary: $%salary%K",
		choices = {
			{ text = "🎉 Dream come true!", effects = { Happiness = 25, Money = 40000 }, resultText = "Your own classroom! Your own students! This is it!", setFlags = {"teacher", "employed"} },
			{ text = "💰 Pay is rough", effects = { Happiness = 10, Money = 38000 }, resultText = "You knew teaching doesn't pay well, but still... worth it for the kids.", setFlags = {"teacher", "employed"} },
			{ text = "🏃 Nervous first day", effects = { Happiness = 15, Money = 40000, Health = -3 }, resultText = "Standing in front of 25 kids. Terrifying. Exhilarating.", setFlags = {"teacher", "employed"} },
			{ text = "📍 Tough school", effects = { Happiness = 8, Money = 45000, Smarts = 5 }, resultText = "Title I school. Challenging students. But they need you most.", setFlags = {"teacher", "employed", "tough_school"} },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- TEACHING EXPERIENCES
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "edu_difficult_student",
		minAge = 23, maxAge = 60,
		weight = 30, cooldown = 2,
		emoji = "😤", title = "Difficult Student",
		category = "work",
		requiresFlag = "teacher",
		getDynamicData = function()
			return { studentName = LifeEvents.randomFirstName() }
		end,
		text = "%studentName% is making your life difficult. Disrupting class, talking back, failing on purpose.",
		choices = {
			{ text = "❤️ Breakthrough moment", effects = { Happiness = 25, Smarts = 5 }, resultText = "Stayed after school, talked one-on-one. Discovered their home life is chaos. They just needed someone to care.", setFlag = "changed_lives" },
			{ text = "📞 Called the parents", effects = { Happiness = 5, Smarts = 2 }, resultText = "Parents were useless. Actually made it worse. School system failing this kid." },
			{ text = "😔 They got expelled", effects = { Happiness = -15 }, resultText = "Couldn't save them. Administration stepped in. Feel like you failed." },
			{ text = "💪 Never gave up", effects = { Happiness = 15, Smarts = 5, Health = -3 }, resultText = "Exhausting but by year end, %studentName% was passing. Your persistence paid off.", setFlag = "changed_lives" },
		},
	},
	
	{
		id = "edu_student_success",
		minAge = 25, maxAge = 65,
		weight = 25, cooldown = 3,
		emoji = "🌟", title = "Student Success Story!",
		category = "work",
		requiresFlag = "teacher",
		getDynamicData = function()
			local achievements = {"got into their dream college", "won a scholarship", "thanked you in their graduation speech", "became successful and credited you", "wrote you a heartfelt letter"}
			return { achievement = achievements[math.random(#achievements)], studentName = LifeEvents.randomFirstName() }
		end,
		text = "Former student %studentName% %achievement%!",
		choices = {
			{ text = "😭 Tears of joy", effects = { Happiness = 30 }, resultText = "THIS is why you teach. Seeing them succeed makes everything worth it.", setFlag = "impactful_teacher" },
			{ text = "🙏 So grateful", effects = { Happiness = 25, Smarts = 2 }, resultText = "You made a difference. A real, lasting difference in someone's life." },
			{ text = "💌 Keep the letter forever", effects = { Happiness = 20 }, resultText = "Framed it. Read it on hard days. Reminds you why you do this." },
			{ text = "🌟 Inspired to do more", effects = { Happiness = 22, Smarts = 5 }, resultText = "If you helped one, you can help more. Renewed motivation!" },
		},
	},
	
	{
		id = "edu_burnout",
		minAge = 25, maxAge = 55,
		weight = 25, cooldown = 3,
		emoji = "😫", title = "Teacher Burnout",
		category = "work",
		requiresFlag = "teacher",
		text = "Grading papers at midnight. Buying supplies with your own money. Admin making your life harder. The burnout is real.",
		choices = {
			{ text = "😔 Considering leaving", effects = { Happiness = -20, Health = -5 }, resultText = "50% of teachers quit within 5 years. You understand why now." },
			{ text = "💪 Remember why", effects = { Happiness = 5, Health = -3 }, resultText = "The kids need you. Take a breath. One day at a time." },
			{ text = "🏖️ Mental health day", effects = { Happiness = 10, Health = 5, Money = -100 }, resultText = "Called in sick. Actually sick - of the system. Needed the break." },
			{ text = "🤝 Teachers support group", effects = { Happiness = 8, Smarts = 3 }, resultText = "Your colleagues get it. Venting together. You're not alone in this." },
		},
	},
	
	{
		id = "edu_teacher_of_year",
		minAge = 28, maxAge = 60,
		weight = 10, oneTime = true,
		emoji = "🏆", title = "Teacher of the Year!",
		category = "work",
		requiresFlag = "impactful_teacher",
		getDynamicData = function()
			local levels = {"district", "regional", "state", "national"}
			return { level = levels[math.random(#levels)] }
		end,
		text = "You've been named %level% Teacher of the Year!",
		choices = {
			{ text = "🏆 Incredible honor!", effects = { Happiness = 40, Money = 5000, Looks = 5 }, resultText = "Recognition for years of dedication! Your students cheered!", setFlag = "award_winning_teacher" },
			{ text = "🎤 Inspiring speech", effects = { Happiness = 35, Smarts = 5 }, resultText = "Your acceptance speech moved everyone. Advocacy for teachers everywhere.", setFlag = "award_winning_teacher" },
			{ text = "💰 Should come with a raise", effects = { Happiness = 20, Money = 2000 }, resultText = "Nice trophy but... teachers still underpaid. Thanks though.", setFlag = "award_winning_teacher" },
			{ text = "👨‍👩‍👧 Students are the real winners", effects = { Happiness = 30, Smarts = 3 }, resultText = "This belongs to them. You just showed up.", setFlag = "humble_teacher" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- ADMINISTRATION PATH
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "edu_department_head",
		minAge = 30, maxAge = 50,
		weight = 20, oneTime = true,
		emoji = "📋", title = "Department Head Offer",
		category = "work",
		requiresFlag = "teacher",
		getDynamicData = function()
			local departments = {"Math", "English", "Science", "Social Studies", "Special Education"}
			return { department = departments[math.random(#departments)] }
		end,
		text = "You're offered the %department% Department Head position!",
		choices = {
			{ text = "📋 Leadership role!", effects = { Happiness = 20, Money = 10000, Smarts = 3 }, resultText = "More responsibility but also more influence! Shaping curriculum!", setFlags = {"department_head", "educational_leader"} },
			{ text = "😕 Less teaching", effects = { Happiness = 10, Money = 10000 }, resultText = "More meetings, more paperwork, less students. Trade-offs.", setFlag = "department_head" },
			{ text = "🙅 Stay in classroom", effects = { Happiness = 15, Smarts = 2 }, resultText = "You became a teacher to TEACH. Not to administrate.", setFlag = "classroom_devoted" },
			{ text = "💡 Implement changes", effects = { Happiness = 18, Money = 10000, Smarts = 5 }, resultText = "Finally have power to fix things that annoyed you!", setFlags = {"department_head", "reformer"} },
		},
	},
	
	{
		id = "edu_principal_offer",
		minAge = 35, maxAge = 55,
		weight = 12, oneTime = true,
		emoji = "🏫", title = "Principal Position!",
		category = "work",
		requiresFlag = "educational_leader",
		getDynamicData = function()
			local salary = math.random(80, 120)
			return { salary = salary }
		end,
		text = "You're offered a Principal position! Salary: $%salary%K!",
		choices = {
			{ text = "🏫 Leading a school!", effects = { Happiness = 25, Money = 90000 }, resultText = "From teacher to principal! Your vision for education can become reality!", clearFlag = "teacher", setFlags = {"principal", "school_leader"} },
			{ text = "😔 Miss the classroom", effects = { Happiness = 15, Money = 95000 }, resultText = "No more teaching. All admin. But you can help MORE kids this way.", clearFlag = "teacher", setFlag = "principal" },
			{ text = "😰 So much pressure", effects = { Happiness = 10, Money = 90000, Health = -5 }, resultText = "Test scores, budgets, parents, board meetings... it never ends.", clearFlag = "teacher", setFlag = "principal" },
			{ text = "❌ Stay as teacher", effects = { Happiness = 18 }, resultText = "Principal's office isn't for you. The classroom is home." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- UNIVERSITY / PROFESSOR PATH
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "edu_phd_pursuit",
		minAge = 24, maxAge = 40,
		weight = 15, oneTime = true,
		emoji = "📚", title = "PhD Program!",
		category = "school",
		requiresFlag = "loves_learning",
		getDynamicData = function()
			local fields = {"Education", "Psychology", "History", "Literature", "Economics", "Sociology"}
			return { field = fields[math.random(#fields)] }
		end,
		text = "You've been accepted to a PhD program in %field%!",
		choices = {
			{ text = "📚 Academic journey!", effects = { Happiness = 20, Money = -30000, Smarts = 10 }, resultText = "5+ years of research, writing, and discovery ahead!", setFlags = {"phd_student", "academic"} },
			{ text = "😰 Impostor syndrome", effects = { Happiness = 5, Money = -30000, Smarts = 8 }, resultText = "Everyone seems smarter than you. But you got in for a reason.", setFlags = {"phd_student", "imposter_syndrome"} },
			{ text = "💡 Thesis idea already", effects = { Happiness = 22, Money = -25000, Smarts = 10 }, resultText = "You know exactly what you want to research! Let's go!", setFlags = {"phd_student", "focused"} },
			{ text = "💰 Funded!", effects = { Happiness = 25, Smarts = 10 }, resultText = "Full funding! Paid to learn! Dream scenario!", setFlags = {"phd_student", "funded_phd"} },
		},
	},
	
	{
		id = "edu_dissertation_defense",
		minAge = 28, maxAge = 45,
		weight = 15, oneTime = true,
		emoji = "🎓", title = "Dissertation Defense!",
		category = "school",
		requiresFlag = "phd_student",
		text = "Years of work. Your dissertation is complete. Time to defend it.",
		choices = {
			{ text = "🎉 DOCTOR!", effects = { Happiness = 40, Smarts = 10 }, resultText = "You passed! DR. YOU! Years of sacrifice, validated!", clearFlag = "phd_student", setFlags = {"phd", "doctor_title"} },
			{ text = "📝 Major revisions", effects = { Happiness = 10, Smarts = 5 }, resultText = "Passed with revisions. More work but you'll get there." },
			{ text = "😭 So emotional", effects = { Happiness = 35, Smarts = 8 }, resultText = "Cried after. Relief, pride, exhaustion. You did it.", clearFlag = "phd_student", setFlags = {"phd", "doctor_title"} },
			{ text = "🙏 Thank your advisor", effects = { Happiness = 30, Smarts = 8 }, resultText = "Couldn't have done it without them. Passing the torch.", clearFlag = "phd_student", setFlags = {"phd", "doctor_title"} },
		},
	},
	
	{
		id = "edu_professor_tenure",
		minAge = 32, maxAge = 55,
		weight = 12, oneTime = true,
		emoji = "🏛️", title = "Tenure Decision!",
		category = "work",
		requiresFlag = "phd",
		text = "After years on tenure-track, the committee is deciding your fate. Tenure or out.",
		choices = {
			{ text = "🎉 TENURED!", effects = { Happiness = 40, Money = 80000, Smarts = 5 }, resultText = "Job security for LIFE! Full professor! Academic achievement unlocked!", setFlags = {"tenured_professor", "academic_success"} },
			{ text = "📚 Publish or perish", effects = { Happiness = 30, Money = 75000, Smarts = 8 }, resultText = "Your publication record saved you! Tenure granted!", setFlags = {"tenured_professor", "published_academic"} },
			{ text = "❌ Denied", effects = { Happiness = -30, Money = -20000 }, resultText = "Not enough publications. Not enough grants. Have to find a new job.", setFlag = "denied_tenure" },
			{ text = "💼 Negotiated well", effects = { Happiness = 35, Money = 90000 }, resultText = "Tenured AND got a better package! Named professor!", setFlags = {"tenured_professor", "named_professor"} },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- LEGACY
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "edu_retirement_legacy",
		minAge = 55, maxAge = 75,
		weight = 20, oneTime = true,
		emoji = "📖", title = "Teaching Legacy",
		category = "work",
		requiresFlag = "teacher",
		getDynamicData = function()
			local years = math.random(25, 40)
			local students = math.random(500, 5000)
			return { years = years, students = students }
		end,
		text = "After %years% years, %students% students taught. Retirement beckons.",
		choices = {
			{ text = "😭 Beautiful farewell", effects = { Happiness = 35, Health = 10 }, resultText = "Former students came back for your retirement party. Generations of lives touched.", clearFlag = "teacher", setFlag = "retired_educator" },
			{ text = "📚 Scholarship in your name", effects = { Happiness = 40, Money = -10000 }, resultText = "Students pooled together to create a scholarship. Legacy continues.", setFlags = {"retired_educator", "scholarship_legacy"} },
			{ text = "🏫 Building named after you", effects = { Happiness = 45, Looks = 5 }, resultText = "They're naming the library after you. Immortalized.", setFlags = {"retired_educator", "immortalized"} },
			{ text = "👨‍👩‍👧 Teacher in the family", effects = { Happiness = 38 }, resultText = "Your child/grandchild became a teacher too. The calling continues.", setFlags = {"retired_educator", "teaching_dynasty"} },
		},
	},
}

return module
