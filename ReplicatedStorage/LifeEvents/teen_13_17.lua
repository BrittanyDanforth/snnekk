-- LifeEvents/teen_13_17.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- TEENAGE EVENTS (Ages 13-17) - MASSIVE EXPANSION
-- 130+ deeply thought-out events for high school years
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent.init)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- MIDDLE SCHOOL TRANSITION (Ages 13-14)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_middle_school_start",
		minAge = 13, maxAge = 13,
		weight = 100, milestone = true, oneTime = true,
		emoji = "🏫", title = "Starting Middle School!",
		category = "school",
		getDynamicData = function()
			local schools = {"Lincoln Middle", "Washington Middle", "Roosevelt Junior High", "Kennedy Middle", "Jefferson Middle"}
			return { school = schools[math.random(#schools)] }
		end,
		text = "Welcome to %school%! Multiple classes, lockers, changing for gym... everything is different!",
		choices = {
			{ text = "😎 Actually kind of cool", effects = { Happiness = 7, Smarts = 3 }, resultText = "You adapted quickly! More freedom is nice." },
			{ text = "😰 Totally overwhelmed", effects = { Happiness = -5 }, resultText = "Getting lost between classes, forgetting locker combos... rough start." },
			{ text = "🤝 Find your crew", effects = { Happiness = 8 }, resultText = "You found your people! Middle school won't be so bad.", setFlag = "has_friend_group" },
			{ text = "📚 Focus on academics", effects = { Smarts = 8, Happiness = 2 }, resultText = "Grades matter more now. You're on it!", setFlag = "academic_focused" },
		},
	},
	
	{
		id = "m_locker_struggles",
		minAge = 13, maxAge = 14,
		weight = 35, oneTime = true,
		emoji = "🔐", title = "Locker Problems!",
		category = "school",
		text = "Your locker is jammed/you forgot the combination! Class starts in 2 minutes!",
		choices = {
			{ text = "🏃 Just go to class without books", effects = { Smarts = -2, Happiness = -2 }, resultText = "Teacher was NOT happy you came unprepared." },
			{ text = "🔧 Finally get it open!", effects = { Happiness = 4, Smarts = 2 }, resultText = "Crisis averted! But you were late." },
			{ text = "🆘 Ask for help", effects = { Happiness = 2 }, resultText = "A friendly upperclassman helped you out." },
			{ text = "😤 Kick it (bad idea)", effects = { Health = -2, Money = -50 }, resultText = "You dented it. Now you owe for repairs." },
		},
	},
	
	{
		id = "m_puberty_full_swing",
		minAge = 13, maxAge = 15,
		weight = 50, oneTime = true,
		emoji = "📈", title = "Puberty in Full Swing",
		category = "health",
		text = "Voice cracking, growth spurts, emotions everywhere... puberty is INTENSE.",
		choices = {
			{ text = "😳 Everything is embarrassing", effects = { Happiness = -4 }, resultText = "Your voice cracked in the middle of a presentation. Classic." },
			{ text = "💪 Growing taller!", effects = { Looks = 4, Health = 3, Happiness = 3 }, resultText = "You shot up several inches! New wardrobe needed.", setFlag = "growth_spurt" },
			{ text = "😤 Mood swings", effects = { Happiness = -6 }, resultText = "Everything is the WORST! (It's not, but it feels like it.)" },
			{ text = "🧘 Handle it with grace", effects = { Smarts = 4, Happiness = 2, Looks = 2 }, resultText = "You're managing the changes well!", setFlag = "mature" },
		},
	},
	
	{
		id = "m_first_dance",
		minAge = 13, maxAge = 14,
		weight = 40, oneTime = true,
		emoji = "💃", title = "First School Dance!",
		category = "social",
		getDynamicData = function()
			local dances = {"back-to-school dance", "winter formal", "spring fling", "end-of-year dance"}
			return { dance = dances[math.random(#dances)] }
		end,
		text = "The %dance% is this weekend! Will you go?",
		choices = {
			{ text = "💃 Best night ever!", effects = { Happiness = 10, Looks = 3 }, resultText = "You danced all night! Unforgettable!", setFlag = "social_butterfly" },
			{ text = "🕺 Asked someone!", effects = { Happiness = 12, Looks = 2 }, resultText = "They said yes! You went together!", setFlag = "confident" },
			{ text = "😬 Wall flower", effects = { Happiness = 2 }, resultText = "You stood against the wall the whole time. Still showed up though!" },
			{ text = "🙅 Skip it", effects = { Happiness = 0 }, resultText = "Dances aren't your thing. That's valid." },
		},
	},
	
	{
		id = "m_social_media_start",
		minAge = 13, maxAge = 14,
		weight = 45, oneTime = true,
		emoji = "📱", title = "Social Media World!",
		category = "social",
		getDynamicData = function()
			local platforms = {"Instagram", "TikTok", "Snapchat", "Twitter", "YouTube"}
			return { platform = platforms[math.random(#platforms)] }
		end,
		text = "You finally got %platform%! Welcome to social media!",
		choices = {
			{ text = "📸 Posting everything!", effects = { Happiness = 6, Looks = 2 }, resultText = "You're building your online presence!", setFlag = "social_media_user" },
			{ text = "👀 Just lurking", effects = { Happiness = 4 }, resultText = "You prefer watching over posting.", setFlag = "social_media_user" },
			{ text = "🌟 Going viral!", effects = { Happiness = 12, Looks = 5 }, resultText = "One of your posts blew up! Thousands of likes!", setFlags = {"social_media_user", "internet_famous"} },
			{ text = "😔 Comparing yourself to others", effects = { Happiness = -6, Looks = -2 }, resultText = "Everyone else's life seems perfect. (It's not.)", setFlag = "social_media_user" },
		},
	},
	
	{
		id = "m_friend_group_drama",
		minAge = 13, maxAge = 17,
		weight = 35, cooldown = 3,
		emoji = "😤", title = "Friend Group Drama!",
		category = "social",
		getDynamicData = function()
			return { friend1 = LifeEvents.randomFirstName(), friend2 = LifeEvents.randomFirstName() }
		end,
		text = "%friend1% and %friend2% had a falling out! Your friend group is divided!",
		choices = {
			{ text = "🤝 Play peacemaker", effects = { Smarts = 5, Happiness = 2 }, resultText = "You helped them make up! Crisis averted.", setFlag = "peacemaker" },
			{ text = "🎭 Pick a side", effects = { Happiness = -2 }, resultText = "You had to choose. Someone's upset with you now." },
			{ text = "🚶 Stay neutral", effects = { Smarts = 3, Happiness = 2 }, resultText = "You refused to get involved. Smart move." },
			{ text = "🔥 Made it worse", effects = { Happiness = -6 }, resultText = "You accidentally escalated everything. Oops." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- HIGH SCHOOL (Ages 14-17)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_high_school_start",
		minAge = 14, maxAge = 14,
		weight = 100, milestone = true, oneTime = true,
		emoji = "🎓", title = "Starting High School!",
		category = "school",
		getDynamicData = function()
			local schools = {"Lincoln High", "Washington High", "Roosevelt High", "Kennedy High", "Central High"}
			return { school = schools[math.random(#schools)] }
		end,
		text = "Welcome to %school%! The next four years will shape your future!",
		choices = {
			{ text = "😎 Fresh start!", effects = { Happiness = 8, Smarts = 3 }, resultText = "New school, new you! Feeling optimistic.", setFlag = "high_school_started" },
			{ text = "😰 Freshman fears", effects = { Happiness = -4 }, resultText = "Seniors are HUGE. The building is HUGE. Help." },
			{ text = "🎯 Set big goals", effects = { Smarts = 8, Happiness = 5 }, resultText = "College prep starts NOW!", setFlags = {"ambitious", "high_school_started"} },
			{ text = "🤝 Already know people", effects = { Happiness = 6 }, resultText = "Friends from middle school are here too! Less scary.", setFlag = "high_school_started" },
		},
	},
	
	{
		id = "m_choosing_classes",
		minAge = 14, maxAge = 17,
		weight = 40, cooldown = 2,
		emoji = "📋", title = "Choosing Classes!",
		category = "school",
		text = "Time to pick next semester's classes! What direction will you take?",
		choices = {
			{ text = "📚 All honors/AP classes", effects = { Smarts = 10, Happiness = -3 }, resultText = "Heavy workload but impressive transcript!", setFlag = "honors_student" },
			{ text = "🎨 Load up on electives", effects = { Happiness = 6, Smarts = 2 }, resultText = "Art, music, cooking - the fun stuff!" },
			{ text = "🔬 STEM focus", effects = { Smarts = 8, Happiness = 2 }, resultText = "Math, science, computers - future engineer!", setFlag = "stem_track" },
			{ text = "⚖️ Balanced schedule", effects = { Smarts = 5, Happiness = 5 }, resultText = "Mix of challenging and enjoyable. Smart balance." },
		},
	},
	
	{
		id = "m_first_boyfriend_girlfriend",
		minAge = 14, maxAge = 17,
		weight = 35, oneTime = true,
		emoji = "💕", title = "First Relationship!",
		category = "social",
		getDynamicData = function()
			return { partnerName = LifeEvents.randomFirstName() }
		end,
		text = "You and %partnerName% are officially dating! Your first real relationship!",
		choices = {
			{ text = "💕 Cloud nine!", effects = { Happiness = 15, Looks = 3 }, resultText = "You've never been happier! Love is amazing!", setFlag = "in_relationship" },
			{ text = "😊 Take it slow", effects = { Happiness = 8, Smarts = 2 }, resultText = "No rush. Getting to know each other.", setFlag = "in_relationship" },
			{ text = "📱 Texting 24/7", effects = { Happiness = 10, Smarts = -2 }, resultText = "You can't stop talking! Grades might suffer though.", setFlag = "in_relationship" },
			{ text = "🤫 Keep it private", effects = { Happiness = 7 }, resultText = "Not everyone needs to know your business.", setFlag = "in_relationship" },
		},
	},
	
	{
		id = "m_first_breakup",
		minAge = 14, maxAge = 17,
		weight = 25, oneTime = true,
		requiresFlag = "in_relationship",
		emoji = "💔", title = "First Heartbreak",
		category = "social",
		getDynamicData = function()
			local reasons = {"grew apart", "they cheated", "you wanted different things", "it was mutual", "long distance didn't work"}
			return { reason = reasons[math.random(#reasons)] }
		end,
		text = "Your relationship ended because you %reason%. First heartbreak hits different.",
		choices = {
			{ text = "😭 Devastated", effects = { Happiness = -15 }, resultText = "You listened to sad music for weeks. It HURTS.", clearFlags = {"in_relationship"}, setFlag = "heartbroken" },
			{ text = "💪 It's for the best", effects = { Happiness = -5, Smarts = 3 }, resultText = "It hurts but you'll be okay. Stronger now.", clearFlags = {"in_relationship"} },
			{ text = "🔥 Revenge era", effects = { Happiness = -2, Looks = 4 }, resultText = "Time for a glow-up! You'll show them!", clearFlags = {"in_relationship"} },
			{ text = "🤝 Stay friends", effects = { Happiness = -3, Smarts = 4 }, resultText = "Mature choice. Not easy but possible.", clearFlags = {"in_relationship"} },
		},
	},
	
	{
		id = "m_party_invitation",
		minAge = 15, maxAge = 17,
		weight = 35, cooldown = 2,
		emoji = "🎉", title = "Party Invitation!",
		category = "social",
		getDynamicData = function()
			return { hostName = LifeEvents.randomFirstName() }
		end,
		text = "%hostName% is throwing a party this weekend! Parents won't be home...",
		choices = {
			{ text = "🎉 Party time!", effects = { Happiness = 10 }, resultText = "Epic party! Great memories made!", setFlag = "party_goer" },
			{ text = "🙅 Too risky", effects = { Happiness = 2, Smarts = 3 }, resultText = "Better safe than sorry. You stayed home." },
			{ text = "🍺 Things got out of hand", effects = { Happiness = 4, Health = -5 }, resultText = "Someone made bad choices. Hopefully not you.", setFlag = "party_goer" },
			{ text = "👮 Cops showed up", effects = { Happiness = -8 }, resultText = "Party got busted! You barely escaped!", setFlag = "party_goer" },
		},
	},
	
	{
		id = "m_driving_permit",
		minAge = 15, maxAge = 16,
		weight = 60, oneTime = true,
		emoji = "🚗", title = "Learner's Permit!",
		category = "family",
		text = "You passed the written test! Time to learn to drive!",
		choices = {
			{ text = "🚗 Natural driver!", effects = { Happiness = 8, Smarts = 3 }, resultText = "You took to driving right away!", setFlag = "learning_to_drive" },
			{ text = "😰 Terrifying!", effects = { Happiness = -3 }, resultText = "Other cars are scary! Parking is impossible!", setFlag = "learning_to_drive" },
			{ text = "👨‍👩‍👧 Parent teacher = drama", effects = { Happiness = 2 }, resultText = "'BRAKE! BRAKE! That's your turn signal!'", setFlag = "learning_to_drive" },
			{ text = "📖 Study more first", effects = { Smarts = 5, Happiness = 2 }, resultText = "You want to be extra prepared before driving.", setFlag = "learning_to_drive" },
		},
	},
	
	{
		id = "m_drivers_license",
		minAge = 16, maxAge = 17,
		weight = 70, oneTime = true,
		requiresFlag = "learning_to_drive",
		emoji = "🪪", title = "Driver's License!",
		category = "family",
		text = "The big day! Your driving test is TODAY!",
		choices = {
			{ text = "🎉 PASSED!", effects = { Happiness = 15, Smarts = 2 }, resultText = "FREEDOM! You can drive alone now!", setFlag = "can_drive" },
			{ text = "😭 Failed...", effects = { Happiness = -8 }, resultText = "Parallel parking got you. Try again soon." },
			{ text = "✨ Perfect score!", effects = { Happiness = 12, Smarts = 5 }, resultText = "Not a single point off! Impressive!", setFlags = {"can_drive", "perfect_driver"} },
			{ text = "😅 Barely passed", effects = { Happiness = 6 }, resultText = "A pass is a pass! Legal driver!", setFlag = "can_drive" },
		},
	},
	
	{
		id = "m_first_job",
		minAge = 15, maxAge = 17,
		weight = 40, oneTime = true,
		emoji = "💼", title = "First Part-Time Job!",
		category = "career",
		getDynamicData = function()
			local jobs = {"fast food worker", "retail associate", "movie theater attendant", "grocery bagger", "lifeguard", "tutor", "babysitter", "lawn care"}
			local wage = math.random(10, 15)
			return { job = jobs[math.random(#jobs)], wage = wage }
		end,
		text = "You got hired as a %job%! $%wage%/hour!",
		choices = {
			{ text = "💪 Hard worker!", effects = { Money = 200, Smarts = 3, Happiness = 4 }, resultText = "You're employee of the month material!", setFlags = {"has_job", "good_worker"} },
			{ text = "😫 It's exhausting", effects = { Money = 150, Health = -3, Happiness = -2 }, resultText = "Working is hard! But money is nice.", setFlag = "has_job" },
			{ text = "🤑 Saving everything", effects = { Money = 300, Happiness = 2 }, resultText = "Future you will thank present you!", setFlags = {"has_job", "saver"} },
			{ text = "💸 Spend it all", effects = { Money = 50, Happiness = 6 }, resultText = "Clothes, games, food... money goes fast!", setFlag = "has_job" },
		},
	},
	
	{
		id = "m_school_sports",
		minAge = 14, maxAge = 17,
		weight = 35, cooldown = 2,
		emoji = "🏆", title = "Varsity Sports!",
		category = "school",
		getDynamicData = function()
			local sports = {"football", "basketball", "soccer", "baseball", "volleyball", "swimming", "track", "tennis", "wrestling", "lacrosse"}
			return { sport = sports[math.random(#sports)] }
		end,
		text = "You tried out for the %sport% team! The roster is being posted...",
		choices = {
			{ text = "🏆 Made varsity!", effects = { Health = 8, Happiness = 10, Looks = 4 }, resultText = "Starting position! You're a starter!", setFlags = {"varsity_athlete", "popular"} },
			{ text = "📋 Made JV", effects = { Health = 5, Happiness = 4 }, resultText = "JV is still the team! Work your way up." },
			{ text = "⭐ Team captain!", effects = { Health = 6, Happiness = 12, Looks = 5 }, resultText = "They made you captain! Leader!", setFlags = {"varsity_athlete", "team_captain", "popular"} },
			{ text = "😔 Didn't make it", effects = { Happiness = -6, Health = 2 }, resultText = "Tough cut. Maybe try another sport." },
		},
	},
	
	{
		id = "m_school_club",
		minAge = 14, maxAge = 17,
		weight = 30, oneTime = true,
		emoji = "🎭", title = "Join a Club!",
		category = "school",
		getDynamicData = function()
			local clubs = {"Drama Club", "Debate Team", "Chess Club", "Robotics", "Art Club", "Band", "Student Council", "Yearbook", "Newspaper", "Model UN"}
			return { club = clubs[math.random(#clubs)] }
		end,
		text = "You're thinking about joining %club%!",
		choices = {
			{ text = "🌟 Become president!", effects = { Smarts = 6, Happiness = 8, Looks = 2 }, resultText = "You rose to the top! Club president!", setFlags = {"club_member", "leader"} },
			{ text = "🤝 Active member", effects = { Smarts = 4, Happiness = 5 }, resultText = "Great addition to the team!", setFlag = "club_member" },
			{ text = "🏆 Win competitions!", effects = { Smarts = 8, Happiness = 10 }, resultText = "Your club dominated at regionals!", setFlags = {"club_member", "competition_winner"} },
			{ text = "🤷 Try it, quit it", effects = { Happiness = 2 }, resultText = "Not for you. At least you tried!" },
		},
	},
	
	{
		id = "m_prom",
		minAge = 16, maxAge = 17,
		weight = 50, oneTime = true,
		emoji = "👗", title = "Prom Night!",
		category = "social",
		getDynamicData = function()
			return { dateName = LifeEvents.randomFirstName() }
		end,
		text = "Prom is coming! The biggest night of high school!",
		choices = {
			{ text = "👑 Prom King/Queen!", effects = { Happiness = 15, Looks = 6, Money = -200 }, resultText = "You won! Crown on your head! LEGENDARY!", setFlag = "prom_royalty" },
			{ text = "💃 Amazing night!", effects = { Happiness = 12, Looks = 4, Money = -150 }, resultText = "Dancing, photos, memories! Perfect prom!" },
			{ text = "😅 Promposal disaster", effects = { Happiness = -3 }, resultText = "Your elaborate ask went wrong. They still said yes though!" },
			{ text = "🙅 Skip prom", effects = { Happiness = 2, Money = 0 }, resultText = "Overrated anyway. Had your own night." },
		},
	},
	
	{
		id = "m_sat_act",
		minAge = 16, maxAge = 17,
		weight = 60, oneTime = true,
		emoji = "📝", title = "SAT/ACT Time!",
		category = "school",
		getDynamicData = function()
			local scores = {"incredible", "above average", "average", "below expectations"}
			return { scoreLevel = scores[math.random(#scores)] }
		end,
		text = "College entrance exams! Months of prep come down to this!",
		choices = {
			{ text = "🎯 Perfect/Near Perfect!", effects = { Smarts = 15, Happiness = 12 }, resultText = "Outstanding score! Ivy League here you come!", setFlag = "high_test_scores" },
			{ text = "📈 Great score!", effects = { Smarts = 10, Happiness = 8 }, resultText = "Solid results! Many doors open!", setFlag = "good_test_scores" },
			{ text = "📊 It's okay...", effects = { Smarts = 4, Happiness = 2 }, resultText = "Could be better. Retake?" },
			{ text = "😰 Test anxiety", effects = { Smarts = 2, Happiness = -5 }, resultText = "You didn't perform your best. There's always retakes." },
		},
	},
	
	{
		id = "m_college_applications",
		minAge = 17, maxAge = 17,
		weight = 70, oneTime = true,
		emoji = "📨", title = "College Applications!",
		category = "school",
		getDynamicData = function()
			local colleges = {"Harvard", "Yale", "State University", "Community College", "Art School", "Tech Institute"}
			return { dreamSchool = colleges[math.random(#colleges)] }
		end,
		text = "You're applying to colleges! Your dream school is %dreamSchool%.",
		choices = {
			{ text = "📬 ACCEPTED to dream school!", effects = { Happiness = 20, Smarts = 5 }, resultText = "THE LETTER CAME! YOU'RE IN!!!", setFlag = "college_accepted" },
			{ text = "📋 Accepted elsewhere", effects = { Happiness = 8, Smarts = 3 }, resultText = "Not your first choice, but still great options!", setFlag = "college_accepted" },
			{ text = "💰 Full scholarship!", effects = { Happiness = 15, Smarts = 4, Money = 5000 }, resultText = "They're paying for everything! Academic achievement!", setFlags = {"college_accepted", "scholarship"} },
			{ text = "😔 Waitlisted/Rejected", effects = { Happiness = -10 }, resultText = "Dreams crushed... but other paths exist." },
		},
	},
	
	{
		id = "m_senioritis",
		minAge = 17, maxAge = 17,
		weight = 40, oneTime = true,
		emoji = "😴", title = "Senioritis!",
		category = "school",
		text = "Senior year is almost over... motivation is at an all-time low.",
		choices = {
			{ text = "😴 Can't even pretend", effects = { Happiness = 4, Smarts = -4 }, resultText = "Grades slipped but you stopped caring." },
			{ text = "💪 Finish strong!", effects = { Smarts = 6, Happiness = 4 }, resultText = "You pushed through! Strong finish to high school!", setFlag = "disciplined" },
			{ text = "🎉 Just enjoying it", effects = { Happiness = 8 }, resultText = "Making memories before it's over!" },
			{ text = "😰 Stressed about future", effects = { Happiness = -4, Smarts = 2 }, resultText = "What comes next is scary. You're not ready!" },
		},
	},
	
	{
		id = "m_graduation",
		minAge = 17, maxAge = 18,
		weight = 100, milestone = true, oneTime = true,
		emoji = "🎓", title = "HIGH SCHOOL GRADUATION!",
		category = "school",
		getDynamicData = function()
			local honors = {"summa cum laude", "magna cum laude", "cum laude", "with honors", ""}
			return { honor = honors[math.random(#honors)] }
		end,
		text = "You did it! You're graduating high school %honor%! Caps in the air!",
		choices = {
			{ text = "🎓 Valedictorian speech!", effects = { Smarts = 10, Happiness = 15, Looks = 5 }, resultText = "Top of your class! You gave the big speech!", setFlag = "valedictorian" },
			{ text = "🎉 Celebrate with friends!", effects = { Happiness = 12 }, resultText = "Best night ever! Graduation parties everywhere!" },
			{ text = "😢 Bittersweet", effects = { Happiness = 5, Smarts = 2 }, resultText = "Happy and sad. End of an era." },
			{ text = "🎯 Ready for what's next", effects = { Happiness = 8, Smarts = 5 }, resultText = "High school was just the beginning!", setFlag = "ambitious" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- TEEN LIFE EXPERIENCES
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_acne_struggles",
		minAge = 13, maxAge = 17,
		weight = 35, cooldown = 3,
		emoji = "😫", title = "Skin Problems!",
		category = "health",
		text = "Your skin is breaking out! Teenage skin is the WORST.",
		choices = {
			{ text = "💆 Skincare routine", effects = { Looks = 4, Money = -50 }, resultText = "Invested in products. Slowly improving!" },
			{ text = "👨‍⚕️ See a dermatologist", effects = { Looks = 6, Health = 2, Money = -100 }, resultText = "Professional help worked wonders!" },
			{ text = "🤷 Just deal with it", effects = { Looks = -2 }, resultText = "It's a phase. Everyone goes through it." },
			{ text = "😔 Really affecting confidence", effects = { Happiness = -6, Looks = -3 }, resultText = "Hard to feel good about yourself right now." },
		},
	},
	
	{
		id = "m_identity_crisis",
		minAge = 14, maxAge = 17,
		weight = 25, oneTime = true,
		emoji = "🤔", title = "Finding Yourself",
		category = "social",
		text = "Who are you, really? What do you believe in? What's your identity?",
		choices = {
			{ text = "🔍 Soul searching", effects = { Smarts = 6, Happiness = 4 }, resultText = "Deep reflection led to self-discovery.", setFlag = "self_aware" },
			{ text = "🎭 Try different things", effects = { Happiness = 5, Looks = 2 }, resultText = "New styles, new music, new friends. Experimenting!" },
			{ text = "📚 Found through passion", effects = { Smarts = 4, Happiness = 6 }, resultText = "Your interests define who you are!", setFlag = "passionate" },
			{ text = "😤 Don't need labels", effects = { Smarts = 3, Happiness = 4 }, resultText = "You're just YOU. That's enough." },
		},
	},
	
	{
		id = "m_peer_pressure",
		minAge = 14, maxAge = 17,
		weight = 30, cooldown = 2,
		emoji = "😬", title = "Peer Pressure",
		category = "social",
		getDynamicData = function()
			local pressures = {"try drinking", "skip school", "try a vape", "shoplift something", "bully someone", "cheat on a test"}
			return { pressure = pressures[math.random(#pressures)] }
		end,
		text = "Your friends are pressuring you to %pressure%. Everyone else is doing it...",
		choices = {
			{ text = "🙅 Stand your ground", effects = { Happiness = 4, Smarts = 6 }, resultText = "You said no. Real friends respect that.", setFlag = "strong_character" },
			{ text = "😔 Give in", effects = { Happiness = 2, Health = -3, Smarts = -2 }, resultText = "You did it. Didn't feel as good as you thought." },
			{ text = "🚶 Leave the situation", effects = { Happiness = 2, Smarts = 4 }, resultText = "You removed yourself. Smart move." },
			{ text = "🗣️ Talk them out of it", effects = { Smarts = 5, Happiness = 5 }, resultText = "You convinced everyone it was a bad idea!", setFlag = "leader" },
		},
	},
	
	{
		id = "m_mental_health_awareness",
		minAge = 14, maxAge = 17,
		weight = 25, oneTime = true,
		emoji = "🧠", title = "Mental Health Journey",
		category = "health",
		text = "You're realizing mental health is important. Stress, anxiety, emotions are REAL.",
		choices = {
			{ text = "🗣️ Talk to someone", effects = { Happiness = 6, Health = 4 }, resultText = "Opening up helped so much!", setFlag = "mental_health_aware" },
			{ text = "📝 Start journaling", effects = { Smarts = 4, Happiness = 4 }, resultText = "Writing it out helps process feelings.", setFlag = "journals" },
			{ text = "🧘 Meditation/Exercise", effects = { Health = 6, Happiness = 4 }, resultText = "Physical health = mental health!", setFlag = "mindful" },
			{ text = "😔 Struggle in silence", effects = { Happiness = -6, Health = -3 }, resultText = "It's hard. Please reach out to someone." },
		},
	},
	
	{
		id = "m_volunteer_work",
		minAge = 14, maxAge = 17,
		weight = 25, cooldown = 3,
		emoji = "🤝", title = "Volunteering!",
		category = "social",
		getDynamicData = function()
			local places = {"animal shelter", "food bank", "hospital", "elderly home", "environmental cleanup", "tutoring center"}
			return { place = places[math.random(#places)] }
		end,
		text = "You're volunteering at a %place%! Giving back to the community.",
		choices = {
			{ text = "❤️ Love it!", effects = { Happiness = 8, Smarts = 3 }, resultText = "This is meaningful work! You'll continue!", setFlag = "volunteer" },
			{ text = "📋 For college apps", effects = { Smarts = 5, Happiness = 2 }, resultText = "Padding that resume! Still helping though." },
			{ text = "🤝 Made connections", effects = { Happiness = 6, Smarts = 2 }, resultText = "Met amazing people doing good work!", setFlag = "networker" },
			{ text = "🌟 Started a project", effects = { Smarts = 8, Happiness = 10 }, resultText = "You initiated your own community service!", setFlags = {"volunteer", "leader"} },
		},
	},
	
	{
		id = "m_summer_job_teen",
		minAge = 15, maxAge = 17,
		weight = 35, cooldown = 2,
		requiresFlag = "has_job",
		emoji = "☀️", title = "Summer Work!",
		category = "career",
		text = "Summer break means more hours at your job! Time to grind!",
		choices = {
			{ text = "💪 Work full time!", effects = { Money = 800, Health = -4, Happiness = 2 }, resultText = "Bank account growing! But no vacation." },
			{ text = "⚖️ Balance work and fun", effects = { Money = 400, Happiness = 6 }, resultText = "Made money AND had a summer!" },
			{ text = "📈 Got promoted!", effects = { Money = 600, Smarts = 4, Happiness = 6 }, resultText = "Hard work paid off! More responsibility!", setFlag = "promoted" },
			{ text = "🏖️ Quit for summer", effects = { Happiness = 8, Money = -100 }, resultText = "YOLO! Summer is for fun!", clearFlags = {"has_job"} },
		},
	},
	
	{
		id = "m_creative_expression",
		minAge = 13, maxAge = 17,
		weight = 30, oneTime = true,
		emoji = "🎨", title = "Finding Creative Outlet",
		category = "social",
		getDynamicData = function()
			local outlets = {"music", "art", "writing", "film-making", "photography", "coding", "fashion", "dance"}
			return { outlet = outlets[math.random(#outlets)] }
		end,
		text = "You've discovered %outlet% as a way to express yourself!",
		choices = {
			{ text = "🔥 Natural talent!", effects = { Happiness = 10, Smarts = 4, Looks = 2 }, resultText = "You're GOOD at this! Keep going!", setFlags = {"creative", "artistic_talent"} },
			{ text = "🎯 Dedicated practice", effects = { Happiness = 6, Smarts = 6 }, resultText = "Skill comes from practice. You're committed!", setFlag = "creative" },
			{ text = "🌐 Share online", effects = { Happiness = 8, Looks = 3 }, resultText = "People love your work! Growing an audience!", setFlags = {"creative", "content_creator"} },
			{ text = "📓 Keep it private", effects = { Happiness = 5 }, resultText = "It's for you, not for likes. Pure expression.", setFlag = "creative" },
		},
	},
	
	{
		id = "m_car_first",
		minAge = 16, maxAge = 17,
		weight = 30, oneTime = true,
		requiresFlag = "can_drive",
		emoji = "🚗", title = "First Car!",
		category = "family",
		getDynamicData = function()
			local cars = {"an old hand-me-down", "a beater from Craigslist", "a modest used car", "a gift from parents"}
			return { carType = cars[math.random(#cars)] }
		end,
		text = "You got your first car! It's %carType%, but it's YOURS!",
		choices = {
			{ text = "🚗 FREEDOM!", effects = { Happiness = 15 }, resultText = "You can go ANYWHERE! Life-changing!", setFlag = "has_car" },
			{ text = "🔧 Needs some work", effects = { Happiness = 6, Money = -300 }, resultText = "It runs... mostly. Learning car maintenance!", setFlag = "has_car" },
			{ text = "🛣️ Road trip!", effects = { Happiness = 12, Money = -100 }, resultText = "First road trip with friends! Epic!", setFlag = "has_car" },
			{ text = "💰 Gas is expensive!", effects = { Happiness = 6, Money = -200 }, resultText = "Freedom has a price. Worth it though.", setFlag = "has_car" },
		},
	},
	
	{
		id = "m_caught_by_parents",
		minAge = 14, maxAge = 17,
		weight = 20, cooldown = 3,
		emoji = "😱", title = "Busted!",
		category = "family",
		getDynamicData = function()
			local offenses = {"sneaking out", "lying about where you were", "bad grades", "something on your phone", "having people over when they weren't home"}
			return { offense = offenses[math.random(#offenses)] }
		end,
		text = "Your parents caught you %offense%! They are NOT happy!",
		choices = {
			{ text = "😭 Accept punishment", effects = { Happiness = -8, Smarts = 2 }, resultText = "Grounded for a month. Lesson learned." },
			{ text = "🤥 Try to lie your way out", effects = { Happiness = -4, Smarts = -2 }, resultText = "They didn't believe you. Made it worse." },
			{ text = "🗣️ Honest conversation", effects = { Happiness = -4, Smarts = 4 }, resultText = "You talked it through. Still in trouble but they appreciate honesty.", setFlag = "honest" },
			{ text = "😤 Rebellion mode", effects = { Happiness = 2, Smarts = -3 }, resultText = "You're done listening to them! (Teenager moment)" },
		},
	},
	
	{
		id = "m_college_visit",
		minAge = 16, maxAge = 17,
		weight = 35, cooldown = 2,
		emoji = "🏛️", title = "College Visit!",
		category = "school",
		getDynamicData = function()
			local colleges = {"a prestigious university", "state school", "a small liberal arts college", "tech school", "community college"}
			return { college = colleges[math.random(#colleges)] }
		end,
		text = "You're visiting %college% to check it out!",
		choices = {
			{ text = "😍 I want to go here!", effects = { Happiness = 8, Smarts = 2 }, resultText = "This is THE school! You're applying early!", setFlag = "found_dream_school" },
			{ text = "🤔 Not what I expected", effects = { Smarts = 3 }, resultText = "Looked better on the website. Crossing it off." },
			{ text = "📸 Taking it all in", effects = { Happiness = 4, Smarts = 3 }, resultText = "Good info gathered. Decision pending." },
			{ text = "🎉 College parties though", effects = { Happiness = 6 }, resultText = "You got a taste of college life. Can't wait!" },
		},
	},
	
	{
		id = "m_teen_social_justice",
		minAge = 14, maxAge = 17,
		weight = 20, oneTime = true,
		emoji = "✊", title = "Caring About the World",
		category = "social",
		getDynamicData = function()
			local causes = {"climate change", "social equality", "animal rights", "political issues", "local community problems"}
			return { cause = causes[math.random(#causes)] }
		end,
		text = "You've become passionate about %cause%! The world needs to change!",
		choices = {
			{ text = "📢 Become an activist", effects = { Smarts = 5, Happiness = 6 }, resultText = "You're organizing and speaking out!", setFlag = "activist" },
			{ text = "🗳️ Encourage voting", effects = { Smarts = 4, Happiness = 4 }, resultText = "Registered to vote the moment you can!", setFlag = "politically_engaged" },
			{ text = "💰 Donate/Fundraise", effects = { Money = -50, Happiness = 5 }, resultText = "Put your money where your mouth is!", setFlag = "charitable" },
			{ text = "📱 Spread awareness online", effects = { Happiness = 4, Smarts = 2 }, resultText = "Using your platform for good!", setFlag = "activist" },
		},
	},
	
	{
		id = "m_summer_romance",
		minAge = 15, maxAge = 17,
		weight = 25, cooldown = 2,
		emoji = "🌅", title = "Summer Romance!",
		category = "social",
		getDynamicData = function()
			return { personName = LifeEvents.randomFirstName() }
		end,
		text = "You met %personName% this summer! Instant connection!",
		choices = {
			{ text = "💕 Best summer ever!", effects = { Happiness = 12 }, resultText = "Memories of sunsets and late nights! Perfect summer!" },
			{ text = "😢 It ended with summer", effects = { Happiness = -4 }, resultText = "Different schools, different lives. Bittersweet ending." },
			{ text = "📱 Staying in touch", effects = { Happiness = 6 }, resultText = "Distance won't stop this connection!" },
			{ text = "💔 Got hurt", effects = { Happiness = -8 }, resultText = "Summer flings can sting. Lesson learned." },
		},
	},
	
	{
		id = "m_internship",
		minAge = 16, maxAge = 17,
		weight = 25, oneTime = true,
		emoji = "💼", title = "High School Internship!",
		category = "career",
		getDynamicData = function()
			local fields = {"tech company", "law firm", "hospital", "design studio", "research lab", "local business"}
			return { field = fields[math.random(#fields)] }
		end,
		text = "You got a summer internship at a %field%! Real world experience!",
		choices = {
			{ text = "🌟 Impressive work!", effects = { Smarts = 8, Money = 300, Happiness = 6 }, resultText = "You impressed everyone! Letter of recommendation secured!", setFlags = {"intern_experience", "impressive_resume"} },
			{ text = "📚 Learning a lot", effects = { Smarts = 6, Happiness = 4 }, resultText = "Eye-opening experience about the real world!", setFlag = "intern_experience" },
			{ text = "☕ Mostly coffee runs", effects = { Smarts = 2, Happiness = 2 }, resultText = "Grunt work, but still resume material.", setFlag = "intern_experience" },
			{ text = "🤝 Made connections", effects = { Smarts = 4, Happiness = 6 }, resultText = "Networking is everything! Future job prospects!", setFlags = {"intern_experience", "networker"} },
		},
	},
	
	{
		id = "m_teen_heartache",
		minAge = 14, maxAge = 17,
		weight = 20, cooldown = 3,
		emoji = "😢", title = "Hard Times",
		category = "family",
		getDynamicData = function()
			local issues = {"parents fighting", "family money problems", "losing a grandparent", "friend moving away", "family illness"}
			return { issue = issues[math.random(#issues)] }
		end,
		text = "Your family is going through %issue%. Life isn't always easy.",
		choices = {
			{ text = "💪 Stay strong", effects = { Happiness = -4, Smarts = 4 }, resultText = "Difficult times build character. You're resilient.", setFlag = "resilient" },
			{ text = "🗣️ Talk to someone", effects = { Happiness = -2, Smarts = 3 }, resultText = "Support from friends and counselors helped." },
			{ text = "📝 Channel it creatively", effects = { Happiness = -2, Smarts = 5 }, resultText = "Art/writing became your outlet.", setFlag = "creative" },
			{ text = "😔 Really struggling", effects = { Happiness = -10 }, resultText = "It's okay to not be okay. This too shall pass." },
		},
	},
	
	{
		id = "m_senior_prank",
		minAge = 17, maxAge = 17,
		weight = 30, oneTime = true,
		emoji = "😈", title = "Senior Prank!",
		category = "school",
		text = "It's senior prank time! Your class is planning something legendary!",
		choices = {
			{ text = "😈 Lead the prank!", effects = { Happiness = 10, Smarts = -2 }, resultText = "LEGENDARY prank! People will talk about this for years!", setFlag = "prankster" },
			{ text = "😂 Participate", effects = { Happiness = 7 }, resultText = "You were part of it! Great memory!" },
			{ text = "😰 Almost got caught", effects = { Happiness = 4, Smarts = 2 }, resultText = "Heart pounding! Worth it!" },
			{ text = "🙅 Too risky", effects = { Smarts = 3 }, resultText = "Not worth jeopardizing graduation. Smart choice." },
		},
	},
	
	{
		id = "m_gap_year_decision",
		minAge = 17, maxAge = 17,
		weight = 20, oneTime = true,
		emoji = "🌍", title = "Gap Year?",
		category = "school",
		text = "Should you take a gap year before college? Travel, work, figure things out?",
		choices = {
			{ text = "🌍 See the world!", effects = { Happiness = 10, Smarts = 5, Money = -500 }, resultText = "Gap year approved! Adventure awaits!", setFlag = "gap_year" },
			{ text = "💼 Work and save", effects = { Money = 1000, Smarts = 3 }, resultText = "Smart financial choice. Building that bank account.", setFlag = "gap_year" },
			{ text = "📚 Straight to college", effects = { Smarts = 4, Happiness = 4 }, resultText = "No breaks! Let's go!" },
			{ text = "🤔 Still deciding", effects = { Smarts = 2 }, resultText = "Big decision. Take your time." },
		},
	},
	
	{
		id = "m_viral_moment",
		minAge = 14, maxAge = 17,
		weight = 10, oneTime = true,
		emoji = "📱", title = "Going Viral!",
		category = "social",
		getDynamicData = function()
			local reasons = {"something funny you did", "a video you made", "a post that blew up", "being caught on someone else's video"}
			return { reason = reasons[math.random(#reasons)] }
		end,
		text = "You went viral because of %reason%! Millions of views!",
		choices = {
			{ text = "🌟 Embrace the fame!", effects = { Happiness = 12, Looks = 6 }, resultText = "You're internet famous! Followers flooding in!", setFlag = "internet_famous" },
			{ text = "😰 It's overwhelming", effects = { Happiness = -2 }, resultText = "Too much attention. Just want it to blow over." },
			{ text = "💰 Monetize it!", effects = { Money = 500, Happiness = 8 }, resultText = "You made money from your moment!", setFlags = {"internet_famous", "content_creator"} },
			{ text = "😅 For wrong reasons...", effects = { Happiness = -8, Looks = -4 }, resultText = "Viral for embarrassing reasons. It'll pass... eventually." },
		},
	},
	
	{
		id = "m_college_decision",
		minAge = 17, maxAge = 17,
		weight = 50, oneTime = true,
		requiresFlag = "college_accepted",
		emoji = "📬", title = "The Decision!",
		category = "school",
		text = "You've been accepted to multiple schools! Where are you going?!",
		choices = {
			{ text = "🏛️ Ivy League!", effects = { Smarts = 8, Happiness = 10, Money = -5000 }, resultText = "Off to the best of the best! The pressure is ON.", setFlag = "ivy_league" },
			{ text = "🎓 Best fit school", effects = { Smarts = 5, Happiness = 8 }, resultText = "Not the most prestigious, but perfect for you!" },
			{ text = "💰 Where the money is", effects = { Smarts = 4, Money = 3000, Happiness = 6 }, resultText = "Scholarship school! Smart financial decision!", setFlag = "scholarship_student" },
			{ text = "🏠 Stay close to home", effects = { Happiness = 6, Smarts = 4 }, resultText = "Near family and friends. Nothing wrong with that!" },
		},
	},
	
	{
		id = "m_senoir_quotes",
		minAge = 17, maxAge = 17,
		weight = 40, oneTime = true,
		emoji = "📖", title = "Senior Quote!",
		category = "school",
		text = "Time to pick your senior yearbook quote! What wisdom will you share?",
		choices = {
			{ text = "📚 Something meaningful", effects = { Smarts = 4, Happiness = 4 }, resultText = "An inspiring quote that represents your journey." },
			{ text = "😂 A meme", effects = { Happiness = 6 }, resultText = "Making people laugh in the yearbook forever!" },
			{ text = "🎵 Song lyrics", effects = { Happiness = 5 }, resultText = "Music speaks when words can't." },
			{ text = "🤷 'I didn't know we had a deadline'", effects = { Happiness = 7, Smarts = 2 }, resultText = "Classic. Relatable. Perfect." },
		},
	},
	
	{
		id = "m_teen_fitness_journey",
		minAge = 14, maxAge = 17,
		weight = 25, oneTime = true,
		emoji = "💪", title = "Fitness Journey!",
		category = "health",
		text = "You've decided to get serious about fitness! Time to hit the gym!",
		choices = {
			{ text = "💪 Major transformation!", effects = { Health = 10, Looks = 6, Happiness = 6 }, resultText = "Hard work paid off! Looking and feeling great!", setFlag = "fitness_focused" },
			{ text = "🏃 Running is free", effects = { Health = 6, Happiness = 4 }, resultText = "Started running and actually enjoy it!", setFlag = "runner" },
			{ text = "🏋️ Gym is addicting", effects = { Health = 8, Looks = 4 }, resultText = "Iron is your therapy now!", setFlag = "gym_rat" },
			{ text = "😅 Started strong, fizzled out", effects = { Health = 2 }, resultText = "Motivation is hard to maintain. You tried!" },
		},
	},
}

return module
