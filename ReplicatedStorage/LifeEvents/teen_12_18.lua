-- LifeEvents/teen_12_18.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- TEENAGE EVENTS (Ages 12-18)
-- Middle School & High School years
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- MIDDLE SCHOOL (Age 12-14)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_middle_school_start",
		minAge = 12, maxAge = 12,
		weight = 100, oneTime = true, milestone = true,
		emoji = "🏫", title = "Middle School Begins!",
		category = "school",
		text = "You're starting middle school! New school, new people, new drama.",
		choices = {
			{ text = "📚 Focus on grades", effects = { Smarts = 5, Happiness = 2 }, resultText = "You prioritized academics.", setFlag = "studious" },
			{ text = "👥 Focus on friends", effects = { Happiness = 6 }, resultText = "Social life is everything to you." },
			{ text = "⚽ Focus on sports", effects = { Health = 4, Happiness = 3 }, resultText = "You tried out for teams.", setFlag = "athletic_teen" },
			{ text = "😰 Feel overwhelmed", effects = { Happiness = -4 }, resultText = "It's a lot to handle." },
		},
	},
	
	{
		id = "m_puberty_starts",
		minAge = 12, maxAge = 14,
		weight = 80, oneTime = true,
		emoji = "🌱", title = "Puberty!",
		category = "health",
		text = "Your body is changing. Welcome to puberty!",
		choices = {
			{ text = "🤷 Just go with it", effects = { Happiness = -2 }, resultText = "Changes happen. You adapt." },
			{ text = "😱 This is weird!", effects = { Happiness = -5 }, resultText = "You felt awkward in your own skin." },
			{ text = "💪 Growing up!", effects = { Happiness = 3, Health = 2 }, resultText = "You embraced the changes." },
		},
	},
	
	{
		id = "m_voice_cracks",
		minAge = 12, maxAge = 14,
		weight = 40, oneTime = true,
		emoji = "🎤", title = "Voice Cracking",
		category = "social",
		text = "Your voice cracked in class and everyone laughed!",
		choices = {
			{ text = "😂 Laugh with them", effects = { Happiness = 4 }, resultText = "You owned the moment!" },
			{ text = "😳 So embarrassing", effects = { Happiness = -5 }, resultText = "You wanted to disappear." },
			{ text = "🤷 Whatever", effects = { Happiness = 1 }, resultText = "It happens to everyone." },
		},
	},
	
	{
		id = "m_first_phone_teen",
		minAge = 12, maxAge = 14,
		weight = 50, oneTime = true,
		blockIfFlag = "has_phone",
		emoji = "📱", title = "First Smartphone!",
		category = "family",
		text = "You finally got a smartphone! Welcome to social media.",
		choices = {
			{ text = "📱 Social media obsessed", effects = { Happiness = 6, Smarts = -2 }, resultText = "You're on your phone 24/7.", setFlag = "social_media_addict" },
			{ text = "🎮 Mobile gaming", effects = { Happiness = 4 }, resultText = "So many games to play!" },
			{ text = "📚 Use it responsibly", effects = { Happiness = 3, Smarts = 2 }, resultText = "You use it as a tool." },
		},
	},
	
	{
		id = "m_middle_school_drama",
		minAge = 12, maxAge = 14,
		weight = 35, cooldown = 2,
		emoji = "💬", title = "School Drama",
		category = "social",
		getDynamicData = function()
			return { personName = LifeEvents.randomFirstName() }
		end,
		text = "%personName% is spreading rumors about you! Middle school is brutal.",
		choices = {
			{ text = "🗣️ Confront them", effects = { Happiness = 3, Smarts = 2 }, resultText = "You stood up for yourself." },
			{ text = "😭 Cry about it", effects = { Happiness = -8 }, resultText = "The drama got to you." },
			{ text = "🤷 Ignore it", effects = { Happiness = 2, Smarts = 3 }, resultText = "You're above the drama.", setFlag = "mature" },
			{ text = "📱 Post about it", effects = { Happiness = 4, Smarts = -2 }, resultText = "The drama escalated online." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- HIGH SCHOOL (Age 14-18)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_high_school_start",
		minAge = 14, maxAge = 14,
		weight = 100, oneTime = true, milestone = true,
		emoji = "🎓", title = "High School Begins!",
		category = "school",
		getDynamicData = function()
			return { school = LifeEvents.randomSchool() }
		end,
		text = "Welcome to %school%! These four years will define your future.",
		choices = {
			{ text = "📚 Academic track", effects = { Smarts = 6 }, resultText = "You're on the college prep path.", setFlag = "college_bound" },
			{ text = "🎭 Arts & Drama", effects = { Happiness = 4, Looks = 2 }, resultText = "You joined the drama club.", setFlag = "drama_club" },
			{ text = "⚽ Athletics", effects = { Health = 5, Happiness = 3 }, resultText = "Sports became your life.", setFlag = "athlete" },
			{ text = "🤘 Be rebellious", effects = { Happiness = 5, Smarts = -2 }, resultText = "Rules are made to be broken.", setFlag = "rebellious" },
		},
	},
	
	{
		id = "m_drivers_license",
		minAge = 16, maxAge = 17,
		weight = 80, oneTime = true, milestone = true,
		emoji = "🚗", title = "Driver's License!",
		category = "milestone",
		text = "Time to take your driver's test! Freedom awaits.",
		choices = {
			{ text = "🏆 Pass first try!", effects = { Happiness = 10, Smarts = 2 }, resultText = "You're a licensed driver!", setFlag = "has_license" },
			{ text = "😬 Barely pass", effects = { Happiness = 5 }, resultText = "You got your license... just barely.", setFlag = "has_license" },
			{ text = "❌ Fail the test", effects = { Happiness = -8 }, resultText = "You'll have to try again." },
		},
	},
	
	{
		id = "m_first_job",
		minAge = 15, maxAge = 17,
		weight = 50, oneTime = true,
		emoji = "💼", title = "First Part-Time Job!",
		category = "work",
		getDynamicData = function()
			local jobs = {"fast food restaurant", "grocery store", "movie theater", "retail store", "coffee shop"}
			return { jobPlace = jobs[math.random(#jobs)] }
		end,
		text = "You got a job at a %jobPlace%! Time to earn your own money.",
		choices = {
			{ text = "💪 Work hard!", effects = { Smarts = 3, Happiness = 4, Money = 500 }, resultText = "You're a great employee!", setFlag = "work_ethic" },
			{ text = "🤷 It's just a job", effects = { Happiness = 2, Money = 300 }, resultText = "You did the bare minimum." },
			{ text = "😴 Hate it", effects = { Happiness = -3, Money = 200 }, resultText = "Work is exhausting." },
		},
	},
	
	{
		id = "m_first_relationship",
		minAge = 14, maxAge = 17,
		weight = 60, oneTime = true,
		emoji = "💕", title = "First Relationship!",
		category = "romance",
		getDynamicData = function()
			return { partnerName = LifeEvents.randomFirstName() }
		end,
		text = "%partnerName% asked you out! You're officially in a relationship!",
		choices = {
			{ text = "💕 So in love!", effects = { Happiness = 12 }, resultText = "You're head over heels!", setFlag = "first_love" },
			{ text = "😊 Taking it slow", effects = { Happiness = 6, Smarts = 2 }, resultText = "You're being mature about it." },
			{ text = "😰 Nervous", effects = { Happiness = 4, Happiness = 3 }, resultText = "New feelings are scary but exciting." },
		},
	},
	
	{
		id = "m_first_breakup",
		minAge = 14, maxAge = 18,
		weight = 40,
		requiresFlag = "first_love",
		emoji = "💔", title = "First Breakup",
		category = "romance",
		getDynamicData = function()
			return { exName = LifeEvents.randomFirstName() }
		end,
		text = "%exName% broke up with you. First heartbreak hurts.",
		choices = {
			{ text = "😭 Devastated", effects = { Happiness = -15 }, resultText = "You thought it would last forever." },
			{ text = "💪 Move on", effects = { Happiness = -5, Smarts = 3 }, resultText = "It's better to have loved and lost.", clearFlag = "first_love" },
			{ text = "😤 Get revenge", effects = { Happiness = 3, Smarts = -3 }, resultText = "You spread rumors about them.", setFlag = "petty" },
		},
	},
	
	{
		id = "m_prom",
		minAge = 16, maxAge = 18,
		weight = 70, oneTime = true,
		emoji = "🎭", title = "Prom Night!",
		category = "social",
		text = "Prom is coming up! The biggest night of high school!",
		choices = {
			{ text = "👑 Prom King/Queen!", effects = { Happiness = 15, Looks = 5 }, resultText = "You were crowned! The most popular!", setFlag = "prom_royalty" },
			{ text = "💃 Have a great night", effects = { Happiness = 10, Looks = 2 }, resultText = "Dancing, photos, memories!" },
			{ text = "😔 No date", effects = { Happiness = -5 }, resultText = "You went alone. Not terrible." },
			{ text = "🙅 Skip it", effects = { Happiness = 2, Money = 300 }, resultText = "Proms are overrated anyway." },
		},
	},
	
	{
		id = "m_college_applications",
		minAge = 17, maxAge = 18,
		weight = 80, oneTime = true,
		emoji = "📝", title = "College Applications",
		category = "school",
		text = "Time to apply to colleges! Your future depends on this.",
		choices = {
			{ text = "🏛️ Apply to Ivy League", effects = { Smarts = 3, Happiness = -3 }, resultText = "High stakes, high rewards.", setFlag = "ivy_league_applicant" },
			{ text = "📚 State school is fine", effects = { Happiness = 2 }, resultText = "A practical choice." },
			{ text = "🤷 Skip college", effects = { Happiness = 5, Smarts = -2 }, resultText = "College isn't for everyone." },
			{ text = "💼 Trade school", effects = { Smarts = 3, Happiness = 2 }, resultText = "Learn a practical skill.", setFlag = "trade_school" },
		},
	},
	
	{
		id = "m_college_acceptance",
		minAge = 17, maxAge = 18,
		weight = 70, oneTime = true,
		requiresFlag = "ivy_league_applicant",
		emoji = "🎉", title = "College Decision!",
		category = "school",
		getDynamicData = function()
			return { university = LifeEvents.randomUniversity() }
		end,
		text = "The acceptance letters are in! Did you get into %university%?",
		choices = {
			{ text = "🎉 Accepted!", effects = { Happiness = 15, Smarts = 5 }, resultText = "You got in! All that hard work paid off!", setFlag = "college_accepted" },
			{ text = "😔 Rejected", effects = { Happiness = -10 }, resultText = "Dreams crushed. What now?" },
			{ text = "📋 Waitlisted", effects = { Happiness = -3 }, resultText = "You're in limbo. Stressful." },
		},
	},
	
	{
		id = "m_graduation",
		minAge = 18, maxAge = 18,
		weight = 100, oneTime = true, milestone = true,
		emoji = "🎓", title = "High School Graduation!",
		category = "milestone",
		text = "You did it! You're graduating high school!",
		choices = {
			{ text = "🎉 Best day ever!", effects = { Happiness = 15 }, resultText = "You made it! Adulthood begins!", setFlag = "high_school_graduate" },
			{ text = "😢 Sad to leave", effects = { Happiness = 5 }, resultText = "These were good years.", setFlag = "high_school_graduate" },
			{ text = "🚀 Ready for more", effects = { Happiness = 8, Smarts = 3 }, resultText = "High school was just the beginning.", setFlag = "high_school_graduate" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- TEEN SOCIAL LIFE
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_house_party",
		minAge = 15, maxAge = 18,
		weight = 40, cooldown = 2,
		emoji = "🎉", title = "House Party!",
		category = "social",
		getDynamicData = function()
			return { hostName = LifeEvents.randomFirstName() }
		end,
		text = "There's a house party at %hostName%'s place! Parents are away.",
		choices = {
			{ text = "🎉 Party hard!", effects = { Happiness = 10, Health = -2 }, resultText = "Epic night! What a party!" },
			{ text = "🍻 Try alcohol", effects = { Happiness = 5, Health = -5, Smarts = -2 }, resultText = "First time drinking. Regrettable.", setFlag = "tried_alcohol" },
			{ text = "🙅 Stay responsible", effects = { Happiness = 4, Smarts = 2 }, resultText = "You had fun without going crazy." },
			{ text = "🏠 Don't go", effects = { Happiness = -3 }, resultText = "FOMO is real." },
		},
	},
	
	{
		id = "m_peer_pressure_drugs",
		minAge = 14, maxAge = 18,
		weight = 20, oneTime = true,
		emoji = "🚬", title = "Peer Pressure",
		category = "social",
		getDynamicData = function()
			return { friendName = LifeEvents.randomFirstName() }
		end,
		text = "%friendName% is pressuring you to try smoking/vaping. Everyone's doing it.",
		choices = {
			{ text = "🚬 Try it", effects = { Happiness = 3, Health = -8 }, resultText = "You gave in to pressure.", setFlag = "smokes" },
			{ text = "🙅 No way", effects = { Happiness = 5, Health = 2 }, resultText = "You stayed strong. Good choice!" },
			{ text = "🚶 Walk away", effects = { Happiness = 2 }, resultText = "You left the situation." },
		},
	},
	
	{
		id = "m_popularity",
		minAge = 14, maxAge = 18,
		weight = 30, oneTime = true,
		emoji = "👑", title = "Social Climbing",
		category = "social",
		text = "You have a chance to join the popular crowd, but you'd have to ditch your old friends.",
		choices = {
			{ text = "👑 Be popular!", effects = { Happiness = 8, Looks = 3 }, resultText = "You're in the in-crowd!", setFlag = "popular" },
			{ text = "🤝 Stay loyal", effects = { Happiness = 5, Smarts = 2 }, resultText = "Real friends > popularity.", setFlag = "loyal" },
			{ text = "🎭 Play both sides", effects = { Happiness = 4 }, resultText = "You balanced friend groups somehow." },
		},
	},
	
	{
		id = "m_cyberbullying",
		minAge = 13, maxAge = 18,
		weight = 20, cooldown = 3,
		emoji = "📱", title = "Cyberbullying",
		category = "social",
		text = "People are posting mean things about you online. It's going viral.",
		choices = {
			{ text = "😭 It destroys you", effects = { Happiness = -15 }, resultText = "The internet can be cruel." },
			{ text = "💪 Rise above", effects = { Happiness = -3, Smarts = 4 }, resultText = "You didn't let them win.", setFlag = "resilient" },
			{ text = "🗣️ Report it", effects = { Happiness = -5, Smarts = 3 }, resultText = "You told adults. Some help." },
			{ text = "🔥 Fight back online", effects = { Happiness = 2, Smarts = -3 }, resultText = "You clapped back. Made it worse." },
		},
	},
	
	{
		id = "m_social_media_famous",
		minAge = 14, maxAge = 18,
		weight = 15, oneTime = true,
		requiresFlag = "content_creator",
		emoji = "📱", title = "Going Viral!",
		category = "social",
		text = "Your post went viral! You're gaining thousands of followers!",
		choices = {
			{ text = "📈 Keep creating", effects = { Happiness = 12, Money = 500 }, resultText = "You're becoming an influencer!", setFlag = "influencer" },
			{ text = "🤑 Monetize it", effects = { Happiness = 8, Money = 1000 }, resultText = "Sponsors are reaching out!" },
			{ text = "😰 Too much attention", effects = { Happiness = -5 }, resultText = "The fame is overwhelming." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- TEEN REBELLION
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_sneaking_out",
		minAge = 14, maxAge = 17,
		weight = 30, cooldown = 2,
		emoji = "🌙", title = "Sneaking Out",
		category = "family",
		text = "Your friends want you to sneak out at midnight. Parents would freak.",
		choices = {
			{ text = "🌙 Sneak out!", effects = { Happiness = 8, Smarts = -2 }, resultText = "The thrill of rebellion!", setFlag = "rebellious" },
			{ text = "🙅 Not worth the risk", effects = { Happiness = 2, Smarts = 2 }, resultText = "You stayed home. Responsible." },
			{ text = "😰 Got caught!", effects = { Happiness = -8 }, resultText = "Parents are FURIOUS." },
		},
	},
	
	{
		id = "m_detention",
		minAge = 13, maxAge = 18,
		weight = 25, cooldown = 2,
		emoji = "📝", title = "Detention!",
		category = "school",
		getDynamicData = function()
			local reasons = {"talking in class", "being late", "phone in class", "dress code violation", "back-talking a teacher"}
			return { reason = reasons[math.random(#reasons)] }
		end,
		text = "You got detention for %reason%!",
		choices = {
			{ text = "😤 This is unfair!", effects = { Happiness = -5, Smarts = -1 }, resultText = "You argued and got more detention." },
			{ text = "😔 Accept it", effects = { Happiness = -3 }, resultText = "You served your time quietly." },
			{ text = "📚 Use time to study", effects = { Happiness = -1, Smarts = 3 }, resultText = "Made the best of a bad situation." },
		},
	},
	
	{
		id = "m_shoplifting",
		minAge = 13, maxAge = 17,
		weight = 15, oneTime = true,
		emoji = "🏪", title = "Shoplifting Dare",
		category = "crime",
		getDynamicData = function()
			return { friendName = LifeEvents.randomFirstName() }
		end,
		text = "%friendName% dares you to shoplift something from the store.",
		choices = {
			{ text = "🏃 Do it!", effects = { Happiness = 5, Money = 20 }, resultText = "You got away with it... this time.", setFlag = "shoplifter" },
			{ text = "🙅 No way", effects = { Happiness = 3, Smarts = 4 }, resultText = "You made the right choice." },
			{ text = "🚔 Get caught!", effects = { Happiness = -15, Money = -100 }, resultText = "Security caught you! Parents called!", setFlag = "juvenile_record" },
		},
	},
	
	{
		id = "m_car_accident",
		minAge = 16, maxAge = 18,
		weight = 10, oneTime = true,
		requiresFlag = "has_license",
		emoji = "💥", title = "Car Accident!",
		category = "health",
		text = "You got into a car accident! Was it your fault?",
		choices = {
			{ text = "😱 Minor fender bender", effects = { Health = -3, Happiness = -5, Money = -500 }, resultText = "Just some damage. Everyone's okay." },
			{ text = "😰 Serious crash", effects = { Health = -15, Happiness = -10, Money = -2000 }, resultText = "You were injured. Recovery takes time." },
			{ text = "🙏 Close call", effects = { Happiness = -3 }, resultText = "Almost crashed. Scared straight." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- TEEN HOBBIES & INTERESTS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_band_started",
		minAge = 14, maxAge = 18,
		weight = 25, oneTime = true,
		emoji = "🎸", title = "Start a Band!",
		category = "social",
		getDynamicData = function()
			local bandNames = {"The Midnight Riders", "Static Storm", "Echo Chamber", "Neon Dreams", "Broken Compass"}
			return { bandName = bandNames[math.random(#bandNames)] }
		end,
		text = "You and your friends started a band called %bandName%!",
		choices = {
			{ text = "🎸 Practice hard!", effects = { Happiness = 8, Smarts = 3 }, resultText = "You're getting good!", setFlag = "band_member" },
			{ text = "🎤 First gig!", effects = { Happiness = 10, Money = 100 }, resultText = "People actually liked you!" },
			{ text = "😅 We're terrible", effects = { Happiness = 4 }, resultText = "At least you're having fun." },
		},
	},
	
	{
		id = "m_sports_championship",
		minAge = 14, maxAge = 18,
		weight = 30, cooldown = 2,
		requiresFlag = "athlete",
		emoji = "🏆", title = "Championship Game!",
		category = "school",
		getDynamicData = function()
			return { sport = LifeEvents.randomSport() }
		end,
		text = "Your team is in the %sport% championship! This is the big one.",
		choices = {
			{ text = "🏆 Win it all!", effects = { Happiness = 15, Health = 3, Looks = 3 }, resultText = "CHAMPIONS! You're a hero!", setFlag = "champion" },
			{ text = "😔 Lose in finals", effects = { Happiness = -8 }, resultText = "So close. Devastating." },
			{ text = "⭐ You're the MVP!", effects = { Happiness = 12, Health = 4, Looks = 4 }, resultText = "Scouts are watching you!", setFlag = "sports_star" },
		},
	},
	
	{
		id = "m_art_competition",
		minAge = 14, maxAge = 18,
		weight = 25, cooldown = 2,
		requiresFlag = "art_interest",
		emoji = "🎨", title = "Art Competition!",
		category = "school",
		text = "Your artwork was entered in a state competition!",
		choices = {
			{ text = "🏆 First Place!", effects = { Happiness = 12, Smarts = 3, Money = 500 }, resultText = "Your talent is recognized!", setFlag = "award_winning_artist" },
			{ text = "🥈 Honorable mention", effects = { Happiness = 6, Smarts = 2 }, resultText = "Good showing!" },
			{ text = "😔 Didn't place", effects = { Happiness = -3 }, resultText = "Art is subjective anyway." },
		},
	},
	
	{
		id = "m_coding_project",
		minAge = 14, maxAge = 18,
		weight = 25, cooldown = 2,
		requiresFlag = "computer_interest",
		emoji = "💻", title = "Coding Project",
		category = "school",
		getDynamicData = function()
			local projects = {"video game", "app", "website", "AI chatbot", "automation script"}
			return { project = projects[math.random(#projects)] }
		end,
		text = "You're working on a %project%! It could be big.",
		choices = {
			{ text = "🚀 It's amazing!", effects = { Smarts = 8, Happiness = 8, Money = 1000 }, resultText = "People love it! You might have a future in tech!", setFlag = "young_programmer" },
			{ text = "💼 Sell it!", effects = { Smarts = 5, Money = 2000 }, resultText = "Someone bought your project!" },
			{ text = "😅 It's buggy", effects = { Smarts = 4, Happiness = 2 }, resultText = "Learning experience at least." },
		},
	},
	
	{
		id = "m_summer_job",
		minAge = 15, maxAge = 17,
		weight = 40, cooldown = 2,
		emoji = "☀️", title = "Summer Job!",
		category = "work",
		getDynamicData = function()
			local jobs = {"lifeguard", "camp counselor", "lawn care", "ice cream shop", "intern"}
			return { job = jobs[math.random(#jobs)] }
		end,
		text = "You got a summer job as a %job%!",
		choices = {
			{ text = "💪 Great experience!", effects = { Happiness = 5, Smarts = 3, Money = 1500 }, resultText = "You learned a lot and made money!" },
			{ text = "🤑 Save everything", effects = { Happiness = 2, Money = 2000 }, resultText = "You're building a nice savings." },
			{ text = "😴 Boring but paid", effects = { Happiness = -2, Money = 1200 }, resultText = "It's just a summer job." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- TEEN FAMILY EVENTS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_parents_strict",
		minAge = 13, maxAge = 17,
		weight = 30, cooldown = 3,
		emoji = "🚫", title = "Strict Parents",
		category = "family",
		text = "Your parents grounded you for a month! No phone, no going out.",
		choices = {
			{ text = "😤 Rebel anyway", effects = { Happiness = 5, Smarts = -3 }, resultText = "You snuck out. Made it worse.", setFlag = "rebellious" },
			{ text = "😔 Accept punishment", effects = { Happiness = -8 }, resultText = "The longest month ever." },
			{ text = "🗣️ Negotiate", effects = { Happiness = -2, Smarts = 3 }, resultText = "You got it reduced to two weeks." },
		},
	},
	
	{
		id = "m_college_pressure",
		minAge = 16, maxAge = 18,
		weight = 35, cooldown = 2,
		emoji = "📚", title = "College Pressure",
		category = "family",
		text = "Your parents are pressuring you about college. GPA, SATs, applications...",
		choices = {
			{ text = "📚 Study constantly", effects = { Smarts = 6, Happiness = -5, Health = -3 }, resultText = "You're burning out but grades are up." },
			{ text = "😤 I'll do it my way", effects = { Happiness = 3, Smarts = 2 }, resultText = "You pushed back on the pressure." },
			{ text = "😰 Anxiety spiral", effects = { Happiness = -10, Smarts = 2 }, resultText = "The pressure is too much.", setFlag = "anxious" },
		},
	},
	
	{
		id = "m_allowance_raise",
		minAge = 13, maxAge = 17,
		weight = 25, cooldown = 2,
		emoji = "💵", title = "Allowance Negotiation",
		category = "family",
		text = "You're trying to get a raise in your allowance.",
		choices = {
			{ text = "📝 Present your case", effects = { Smarts = 3, Money = 200 }, resultText = "Good argument! They agreed!" },
			{ text = "😤 Demand it", effects = { Happiness = -3, Money = 50 }, resultText = "That approach didn't work." },
			{ text = "💼 Offer to do more chores", effects = { Money = 150, Health = -1 }, resultText = "Fair exchange!" },
		},
	},
}

return module
