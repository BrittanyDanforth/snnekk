-- LifeEvents/senior_55_plus.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- SENIOR EVENTS (Ages 55+) - MASSIVE EXPANSION
-- 100+ deeply thought-out events for retirement and golden years
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent.init)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- PRE-RETIREMENT (Ages 55-65)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_retirement_countdown",
		minAge = 55, maxAge = 64,
		weight = 40, cooldown = 3,
		emoji = "⏰", title = "Counting Down to Retirement",
		category = "career",
		requiresFlag = "employed", -- Must be employed to be counting down to retirement!
		getDynamicData = function()
			local years = math.random(1, 10)
			return { years = years }
		end,
		text = "Only %years% years until you can retire! The finish line is in sight!",
		choices = {
			{ text = "🎉 Can't wait!", effects = { Happiness = 8 }, resultText = "Every day closer! The countdown continues!" },
			{ text = "😰 Not ready yet", effects = { Happiness = -2, Smarts = 3 }, resultText = "Still things to accomplish. Not ready to slow down." },
			{ text = "💰 Crunching numbers", effects = { Smarts = 5, Happiness = 4 }, resultText = "Making sure the money is there. Planning carefully.", setFlag = "retirement_planner" },
			{ text = "🏖️ Planning adventures", effects = { Happiness = 10 }, resultText = "Making the bucket list for retirement!", setFlag = "retirement_planner" },
		},
	},
	
	{
		id = "m_early_retirement_offer",
		minAge = 55, maxAge = 62,
		weight = 20, oneTime = true,
		emoji = "💼", title = "Early Retirement Package!",
		category = "career",
		requiresFlag = "employed", -- Must be employed to get retirement package!
		getDynamicData = function()
			local amount = math.random(50000, 200000)
			return { amount = amount }
		end,
		text = "Company offering early retirement package: $%amount%! Take it or leave it?",
		choices = {
			{ text = "💰 Take the money!", effects = { Happiness = 15, Money = 100000 }, resultText = "Golden handshake accepted! Freedom early!", setFlags = {"retired_early", "retired"}, clearFlag = "employed" },
			{ text = "🤔 Negotiate more", effects = { Happiness = 8, Money = 150000, Smarts = 4 }, resultText = "You got a better deal! Smart negotiation!", setFlags = {"retired_early", "retired"}, clearFlag = "employed" },
			{ text = "🙅 Keep working", effects = { Happiness = 2, Money = 10000 }, resultText = "Not ready yet. Still have things to do." },
			{ text = "😰 Feeling pushed out", effects = { Happiness = -8, Money = 80000 }, resultText = "Didn't feel like a choice. Bitter exit.", setFlags = {"retired_early", "retired"}, clearFlag = "employed" },
		},
	},
	
	{
		id = "m_grandchildren_joys",
		minAge = 55, maxAge = 80,
		weight = 35, cooldown = 2,
		requiresFlag = "grandparent",
		emoji = "👶", title = "Grandparent Moments",
		category = "family",
		getDynamicData = function()
			local moments = {"first word", "first steps", "started school", "lost a tooth", "sports game", "school play", "holiday visit"}
			return { moment = moments[math.random(#moments)] }
		end,
		text = "Your grandchild's %moment%! These moments are precious!",
		choices = {
			{ text = "🥰 Heart is full!", effects = { Happiness = 15 }, resultText = "This is what it's all about! Pure love!" },
			{ text = "📸 Got it on video!", effects = { Happiness = 12, Smarts = 2 }, resultText = "Memory captured forever! Showing everyone!" },
			{ text = "🎁 Spoiling time!", effects = { Happiness = 10, Money = -200 }, resultText = "Grandparents get to spoil! It's the best!", setFlag = "spoiling_grandparent" },
			{ text = "💭 Remember when...", effects = { Happiness = 8, Smarts = 2 }, resultText = "Reminds you of your own kids at that age. Full circle." },
		},
	},
	
	{
		id = "m_retirement_day",
		minAge = 60, maxAge = 68,
		weight = 80, milestone = true, oneTime = true,
		emoji = "🎉", title = "RETIREMENT DAY!",
		category = "career",
		requiresFlag = "employed", -- Must be employed to retire from job!
		blockIfFlag = "retired", -- Can only retire once
		getDynamicData = function()
			local years = math.random(30, 45)
			return { years = years }
		end,
		text = "After %years% years in the workforce, today is your last day! YOU'RE RETIRED!",
		choices = {
			{ text = "🎉 FREEDOM AT LAST!", effects = { Happiness = 25 }, resultText = "The alarm clock is officially your enemy no more!", setFlag = "retired", clearFlag = "employed" },
			{ text = "😢 Bittersweet", effects = { Happiness = 10, Smarts = 3 }, resultText = "End of an era. Mixed emotions but mostly joy.", setFlag = "retired", clearFlag = "employed" },
			{ text = "🍾 Epic retirement party!", effects = { Happiness = 20, Money = -1000 }, resultText = "Coworkers sent you off in style! Legendary!", setFlag = "retired", clearFlag = "employed" },
			{ text = "🤷 Now what?", effects = { Happiness = 6 }, resultText = "Identity was tied to work. Time to figure out who you are.", setFlag = "retired", clearFlag = "employed" },
		},
	},
	
	{
		id = "m_social_security",
		minAge = 62, maxAge = 70,
		weight = 50, oneTime = true,
		emoji = "💵", title = "Social Security Decision",
		category = "career",
		getDynamicData = function()
			local earlyAmount = math.random(1800, 2200)
			local fullAmount = math.random(2400, 2900)
			return { earlyAmount = earlyAmount, fullAmount = fullAmount }
		end,
		text = "When to start Social Security? Early ($%earlyAmount%/mo) or wait for full ($%fullAmount%/mo)?",
		choices = {
			{ text = "⏰ Take it early!", effects = { Money = 20000, Happiness = 6 }, resultText = "Bird in hand! Money now!", setFlag = "collecting_ss" },
			{ text = "⏳ Wait for max", effects = { Money = 30000, Smarts = 4 }, resultText = "Patience pays. Bigger checks later.", setFlag = "collecting_ss" },
			{ text = "📊 Math says wait", effects = { Money = 25000, Smarts = 5 }, resultText = "Break-even analysis complete. Optimized!", setFlag = "collecting_ss" },
			{ text = "💰 Need it now", effects = { Money = 18000, Happiness = 2 }, resultText = "No choice but to start early. Bills don't wait.", setFlag = "collecting_ss" },
		},
	},
	
	{
		id = "m_downsizing",
		minAge = 58, maxAge = 72,
		weight = 25, oneTime = true,
		emoji = "🏠", title = "Downsizing Decision",
		category = "family",
		getDynamicData = function()
			local options = {"condo", "smaller house", "retirement community", "55+ community", "closer to kids"}
			return { option = options[math.random(#options)] }
		end,
		text = "Big house, empty rooms. Time to consider moving to a %option%?",
		choices = {
			{ text = "🏠 Love the new place!", effects = { Happiness = 12, Money = 100000 }, resultText = "Less house, less stress! Money from equity!", setFlag = "downsized" },
			{ text = "💔 Hard to leave memories", effects = { Happiness = 4, Money = 80000 }, resultText = "Said goodbye to the family home. Emotional.", setFlag = "downsized" },
			{ text = "🏡 Staying put!", effects = { Happiness = 6, Money = -5000 }, resultText = "This is HOME. Not going anywhere." },
			{ text = "🤝 Near the grandkids!", effects = { Happiness = 15, Money = 50000 }, resultText = "Best decision! See them all the time now!", setFlags = {"downsized", "near_family"} },
		},
	},
	
	{
		id = "m_retirement_hobby",
		minAge = 60, maxAge = 80,
		weight = 35, cooldown = 3,
		requiresFlag = "retired",
		emoji = "🎨", title = "Retirement Hobbies!",
		category = "social",
		getDynamicData = function()
			local hobbies = {"golf", "painting", "gardening", "woodworking", "travel", "volunteering", "fishing", "photography", "birdwatching", "genealogy"}
			return { hobby = hobbies[math.random(#hobbies)] }
		end,
		text = "Retirement means time for %hobby%! Finally pursuing what you love!",
		choices = {
			{ text = "🔥 New obsession!", effects = { Happiness = 15, Smarts = 3 }, resultText = "Found your retirement passion! Every day doing what you love!", setFlag = "active_retiree" },
			{ text = "🤝 Made new friends", effects = { Happiness = 12 }, resultText = "The %hobby% community is wonderful! New social circle!", setFlag = "active_retiree" },
			{ text = "🏆 Getting good!", effects = { Happiness = 10, Smarts = 5 }, resultText = "All this free time = mastery! Impressive!", setFlags = {"active_retiree", "hobby_master"} },
			{ text = "🤷 Tried it, not for me", effects = { Happiness = 2 }, resultText = "Eh, moving on to try something else." },
		},
	},
	
	{
		id = "m_travel_retirement",
		minAge = 60, maxAge = 80,
		weight = 30, cooldown = 2,
		requiresFlag = "retired",
		emoji = "✈️", title = "Retirement Travel!",
		category = "social",
		getDynamicData = function()
			local destinations = {"Alaska cruise", "European river cruise", "national parks road trip", "Australia/New Zealand", "African safari", "South American adventure", "Asian tour"}
			return { destination = destinations[math.random(#destinations)] }
		end,
		text = "Time for that %destination% you've always dreamed about!",
		choices = {
			{ text = "✈️ Trip of a lifetime!", effects = { Happiness = 20, Money = -8000, Health = 2 }, resultText = "Everything you hoped for and more! Incredible!", setFlag = "world_traveler" },
			{ text = "📸 So many memories", effects = { Happiness = 15, Money = -6000 }, resultText = "Photo albums full of adventures!", setFlag = "world_traveler" },
			{ text = "😴 Tiring but worth it", effects = { Happiness = 10, Money = -7000, Health = -2 }, resultText = "Travel is harder now but still amazing!", setFlag = "world_traveler" },
			{ text = "🌍 Caught the travel bug", effects = { Happiness = 18, Money = -5000 }, resultText = "Where to next?! Can't stop now!", setFlags = {"world_traveler", "travel_addicted"} },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- GOLDEN YEARS (Ages 65-75)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_turning_65",
		minAge = 65, maxAge = 65,
		weight = 100, milestone = true, oneTime = true,
		emoji = "6️⃣5️⃣", title = "65 Years Young!",
		category = "family",
		text = "65! Medicare kicks in, senior discounts galore! How's life?",
		choices = {
			{ text = "🎉 Senior and proud!", effects = { Happiness = 12, Health = 2 }, resultText = "Experience is wisdom! Embracing this chapter!" },
			{ text = "💪 Healthier than ever!", effects = { Happiness = 15, Health = 5, Looks = 2 }, resultText = "Age is just a number! Feeling fantastic!", setFlag = "healthy_senior" },
			{ text = "💵 Loving those discounts", effects = { Happiness = 10, Money = 2000 }, resultText = "Finally getting something back! Senior perks!", setFlag = "senior_saver" },
			{ text = "🤔 Where did time go?", effects = { Happiness = 4, Smarts = 3 }, resultText = "65 already? Seems like yesterday you were 40." },
		},
	},
	
	{
		id = "m_medicare_decision",
		minAge = 65, maxAge = 66,
		weight = 60, oneTime = true,
		emoji = "🏥", title = "Medicare Enrollment!",
		category = "health",
		text = "Medicare time! Original Medicare, Advantage plan, or supplement? It's confusing!",
		choices = {
			{ text = "📋 Figured it out!", effects = { Health = 4, Smarts = 4, Happiness = 6 }, resultText = "Picked the right plan! Healthcare covered!", setFlag = "medicare_enrolled" },
			{ text = "🤯 So confusing", effects = { Happiness = -2, Smarts = 2 }, resultText = "Picked something. Hope it's right!", setFlag = "medicare_enrolled" },
			{ text = "💰 Saving money with it", effects = { Happiness = 8, Money = 5000 }, resultText = "Lower healthcare costs! Medicare is a blessing!", setFlag = "medicare_enrolled" },
			{ text = "📞 Got help deciding", effects = { Happiness = 5, Smarts = 3 }, resultText = "Insurance advisor helped navigate. Worth it.", setFlag = "medicare_enrolled" },
		},
	},
	
	{
		id = "m_health_management",
		minAge = 65, maxAge = 85,
		weight = 35, cooldown = 3,
		emoji = "💊", title = "Managing Health",
		category = "health",
		getDynamicData = function()
			local conditions = {"blood pressure", "cholesterol", "arthritis", "diabetes", "heart health", "joint issues"}
			return { condition = conditions[math.random(#conditions)] }
		end,
		text = "Doctor wants to discuss your %condition%. Managing health becomes a bigger focus.",
		choices = {
			{ text = "💊 Managing it well!", effects = { Health = 5, Happiness = 4 }, resultText = "Following doctor's orders. Conditions under control!", setFlag = "health_managed" },
			{ text = "🥗 Lifestyle changes", effects = { Health = 8, Happiness = 2 }, resultText = "Diet and exercise adjustments. Feeling better!", setFlags = {"health_managed", "healthy_lifestyle"} },
			{ text = "😤 Frustrated with aging", effects = { Health = -2, Happiness = -4 }, resultText = "Body not cooperating like it used to. Annoying." },
			{ text = "🤷 It is what it is", effects = { Health = 2, Smarts = 2 }, resultText = "Accepting the changes. Doing what you can." },
		},
	},
	
	{
		id = "m_reconnecting_old_friends",
		minAge = 60, maxAge = 80,
		weight = 25, cooldown = 3,
		emoji = "🤝", title = "Reconnecting with Old Friends",
		category = "social",
		getDynamicData = function()
			return { friendName = LifeEvents.randomFirstName() }
		end,
		text = "Got back in touch with %friendName% from decades ago! Time to catch up!",
		choices = {
			{ text = "🤗 Like no time passed!", effects = { Happiness = 12 }, resultText = "True friendship survives time! Amazing reconnection!", setFlag = "reconnected" },
			{ text = "📞 Regular calls now", effects = { Happiness = 8 }, resultText = "Staying in touch! Friendship rekindled!" },
			{ text = "😢 Learned they passed", effects = { Happiness = -10, Smarts = 2 }, resultText = "Too late. A reminder to stay connected.", setFlag = "lost_old_friend" },
			{ text = "🤔 We've grown apart", effects = { Happiness = 2 }, resultText = "Different people now. That's okay." },
		},
	},
	
	{
		id = "m_great_grandparent",
		minAge = 68, maxAge = 85,
		weight = 15, oneTime = true,
		requiresFlag = "grandparent",
		emoji = "👶", title = "Great-Grandparent!",
		category = "family",
		getDynamicData = function()
			local names = {"Rose", "James", "Eleanor", "William", "Grace", "Henry"}
			return { babyName = names[math.random(#names)] }
		end,
		text = "Your grandchild had a baby! You're a GREAT-grandparent! Meet %babyName%!",
		choices = {
			{ text = "🥰 Four generations!", effects = { Happiness = 20 }, resultText = "Four generations alive! What a blessing!", setFlag = "great_grandparent" },
			{ text = "😭 Never thought I'd see this", effects = { Happiness = 15, Health = 2 }, resultText = "Living long enough to meet them. Grateful!", setFlag = "great_grandparent" },
			{ text = "👴 Feel ancient now", effects = { Happiness = 8 }, resultText = "Great-grandparent sounds so old! But worth it!", setFlag = "great_grandparent" },
			{ text = "📸 Family photo time!", effects = { Happiness = 12 }, resultText = "Four generations in one picture! Frame-worthy!", setFlag = "great_grandparent" },
		},
	},
	
	{
		id = "m_legacy_planning",
		minAge = 65, maxAge = 80,
		weight = 30, oneTime = true,
		emoji = "📝", title = "Estate Planning",
		category = "family",
		text = "Time to get serious about wills, trusts, and what happens after you're gone.",
		choices = {
			{ text = "📝 Everything in order", effects = { Happiness = 8, Smarts = 5 }, resultText = "Will done, trust set up, family informed. Peace of mind.", setFlag = "estate_planned" },
			{ text = "💰 Leaving a legacy", effects = { Happiness = 10, Smarts = 4 }, resultText = "Set up inheritance and charitable giving. Meaningful.", setFlag = "estate_planned" },
			{ text = "😰 Hard to think about", effects = { Happiness = -4 }, resultText = "Uncomfortable but necessary. Getting through it." },
			{ text = "👨‍👩‍👧 Family conversation", effects = { Happiness = 4, Smarts = 3 }, resultText = "Talked to kids about plans. Important discussion.", setFlag = "estate_planned" },
		},
	},
	
	{
		id = "m_anniversary_milestone",
		minAge = 55, maxAge = 85,
		weight = 25, cooldown = 5,
		requiresFlag = "married",
		emoji = "💍", title = "Wedding Anniversary Milestone!",
		category = "family",
		getDynamicData = function()
			local years = {25, 30, 40, 50, 60}
			return { years = years[math.random(#years)] }
		end,
		text = "%years% years of marriage! Time to celebrate this incredible milestone!",
		choices = {
			{ text = "💕 More in love than ever", effects = { Happiness = 15 }, resultText = "Decades together and still going strong!", setFlag = "long_marriage" },
			{ text = "🎉 Big celebration!", effects = { Happiness = 18, Money = -3000 }, resultText = "Vow renewal, party with family! Beautiful!", setFlag = "long_marriage" },
			{ text = "🤷 We survived!", effects = { Happiness = 8, Smarts = 2 }, resultText = "Marriage is work. You both put in the effort." },
			{ text = "💭 Remembering the journey", effects = { Happiness = 12, Smarts = 3 }, resultText = "All the ups and downs... still together.", setFlag = "long_marriage" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- LATER YEARS (Ages 75+)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_turning_75",
		minAge = 75, maxAge = 75,
		weight = 100, milestone = true, oneTime = true,
		emoji = "7️⃣5️⃣", title = "75 Years of Life!",
		category = "family",
		text = "Three-quarters of a century! You've seen so much change in this world!",
		choices = {
			{ text = "🎉 Still going strong!", effects = { Happiness = 15, Health = 3 }, resultText = "75 and feeling alive! Every day is a gift!" },
			{ text = "📖 So many stories", effects = { Happiness = 10, Smarts = 5 }, resultText = "What a life you've lived! The stories you could tell!" },
			{ text = "🙏 Grateful for longevity", effects = { Happiness = 12, Smarts = 3 }, resultText = "Not everyone makes it this far. Truly blessed." },
			{ text = "💪 Defying expectations", effects = { Happiness = 14, Health = 5 }, resultText = "Doctors said... you showed them! Still kicking!", setFlag = "healthy_at_75" },
		},
	},
	
	{
		id = "m_mobility_challenges",
		minAge = 70, maxAge = 90,
		weight = 30, cooldown = 3,
		emoji = "🦽", title = "Mobility Changes",
		category = "health",
		getDynamicData = function()
			local challenges = {"need a cane", "knee replacement", "hip issues", "balance concerns", "stairs are harder", "driving at night"}
			return { challenge = challenges[math.random(#challenges)] }
		end,
		text = "Body's changing: %challenge%. Adapting to new limitations.",
		choices = {
			{ text = "💪 Staying active anyway!", effects = { Health = 4, Happiness = 6 }, resultText = "Modified activities but still moving! Not giving up!", setFlag = "adapted_mobility" },
			{ text = "🏥 Medical help", effects = { Health = 6, Money = -5000 }, resultText = "Surgery/treatment helped! Getting around better!", setFlag = "adapted_mobility" },
			{ text = "😤 Frustrated", effects = { Happiness = -6, Health = -2 }, resultText = "Independence slipping. It's hard to accept." },
			{ text = "🤝 Accepting help", effects = { Happiness = 4, Smarts = 3 }, resultText = "Pride aside. Family and aids helping.", setFlag = "adapted_mobility" },
		},
	},
	
	-- MEANINGFUL MOBILITY EVENTS WITH REAL CONSEQUENCES
	{
		id = "m_mobility_aid_decision",
		minAge = 68, maxAge = 88,
		weight = 25, oneTime = true,
		emoji = "🦯", title = "Mobility Aid Decision",
		category = "health",
		text = "Doctor recommends you start using a cane or walker. Your pride says no, safety says yes.",
		choices = {
			{ 
				text = "🦯 Use the cane", 
				effects = { Health = 10, Happiness = 2, Looks = -2 }, 
				resultText = "Smart choice! Much safer getting around. You avoid falls that could end your independence.",
				setFlag = "uses_mobility_aid"
			},
			{ 
				text = "🦽 Get a nice walker", 
				effects = { Health = 12, Happiness = 4, Money = -300 }, 
				resultText = "Got a premium one with a seat! Actually quite useful. Rest when needed.",
				setFlag = "uses_mobility_aid"
			},
			{ 
				text = "💪 Refuse - I'm fine!", 
				effects = { Happiness = 4, Health = -5 }, 
				resultText = "Pride wins... for now. But you feel unsteady. This might come back to bite you.",
				setFlag = "refused_mobility_aid"
			},
			{ 
				text = "🏠 Just use it at home", 
				effects = { Health = 5, Happiness = -2 }, 
				resultText = "Compromise. Nobody sees you use it. Still risky outside though." 
			},
		},
	},
	
	{
		id = "m_fall_consequences",
		minAge = 70, maxAge = 95,
		weight = 35, cooldown = 4,
		requiresFlag = "refused_mobility_aid",
		emoji = "😰", title = "A Serious Fall!",
		category = "health",
		text = "You fell! Lost balance and went down hard. This is what they warned you about.",
		choices = {
			{ 
				text = "🦴 Broken hip!", 
				effects = { Health = -30, Happiness = -25, Money = -15000 }, 
				resultText = "Hospital. Surgery. Months of rehab. Life changed in a second. Should have used that cane.",
				setFlags = {"hip_injury", "uses_mobility_aid"},
				clearFlag = "refused_mobility_aid"
			},
			{ 
				text = "🤕 Concussion", 
				effects = { Health = -20, Happiness = -15, Money = -5000 }, 
				resultText = "Head hit the ground. Memory issues. Now you HAVE to use a walker.",
				setFlags = {"head_injury", "uses_mobility_aid"},
				clearFlag = "refused_mobility_aid"
			},
			{ 
				text = "💪 Lucky - just bruises", 
				effects = { Health = -8, Happiness = -6 }, 
				resultText = "Got lucky this time! But it scared you. Maybe reconsider that cane?",
				clearFlag = "refused_mobility_aid"
			},
			{ 
				text = "📞 Couldn't get up - 911", 
				effects = { Health = -15, Happiness = -20, Money = -3000 }, 
				resultText = "Lay on the floor for 2 hours before help came. Terrifying. Using that aid now.",
				setFlag = "uses_mobility_aid",
				clearFlag = "refused_mobility_aid"
			},
		},
	},
	
	{
		id = "m_mobility_aid_benefits",
		minAge = 70, maxAge = 95,
		weight = 25, cooldown = 3,
		requiresFlag = "uses_mobility_aid",
		emoji = "😊", title = "Mobility Aid Working!",
		category = "health",
		text = "That mobility aid is actually making a big difference in your daily life!",
		choices = {
			{ 
				text = "🚶 Walking more!", 
				effects = { Health = 8, Happiness = 10 }, 
				resultText = "With support, you're actually MORE active! Getting out more!"
			},
			{ 
				text = "💪 Confidence returned", 
				effects = { Happiness = 12, Health = 5 }, 
				resultText = "No fear of falling! Going places you'd stopped visiting!"
			},
			{ 
				text = "🌳 Enjoying walks again", 
				effects = { Health = 10, Happiness = 15 }, 
				resultText = "Back to your favorite park! Fresh air and independence!"
			},
			{ 
				text = "😎 Got a stylish one", 
				effects = { Happiness = 8, Looks = 3, Money = -200 }, 
				resultText = "Upgraded to a sleek carbon fiber cane. Looking good!"
			},
		},
	},
	
	{
		id = "m_driving_decision",
		minAge = 72, maxAge = 88,
		weight = 25, oneTime = true,
		emoji = "🚗", title = "Driving - Time to Quit?",
		category = "health",
		text = "Family is worried about your driving. Vision and reflexes aren't what they were.",
		choices = {
			{ 
				text = "🔑 Give up the keys", 
				effects = { Happiness = -15, Smarts = 5 }, 
				resultText = "Hardest decision. But safer for everyone. Lost independence stings.",
				setFlag = "gave_up_driving"
			},
			{ 
				text = "🚙 Daytime only", 
				effects = { Happiness = -5, Smarts = 3, Health = 5 }, 
				resultText = "Compromise. No night driving, no highways. Still some freedom.",
				setFlag = "limited_driving"
			},
			{ 
				text = "🚕 Use rideshares", 
				effects = { Happiness = 2, Money = -200, Smarts = 4 }, 
				resultText = "Actually convenient! No parking, no stress. Uber is great!",
				setFlag = "gave_up_driving"
			},
			{ 
				text = "💪 I'm fine!", 
				effects = { Happiness = 8, Health = -5 }, 
				resultText = "Kept driving against advice. Pride over safety. What could go wrong?",
				setFlag = "refused_stop_driving"
			},
		},
	},
	
	{
		id = "m_driving_incident",
		minAge = 72, maxAge = 90,
		weight = 30, cooldown = 5,
		requiresFlag = "refused_stop_driving",
		emoji = "🚨", title = "Driving Incident!",
		category = "health",
		text = "Something happened while driving. The family was right to be worried.",
		choices = {
			{ 
				text = "💥 Fender bender", 
				effects = { Money = -2000, Happiness = -10, Health = -3 }, 
				resultText = "Hit a parked car. Insurance up. Family insisting you stop now.",
				clearFlag = "refused_stop_driving"
			},
			{ 
				text = "🚗 Got lost", 
				effects = { Happiness = -15, Smarts = -2 }, 
				resultText = "Couldn't find way home. Confusion set in. Scary moment.",
				clearFlag = "refused_stop_driving"
			},
			{ 
				text = "🚨 Police pulled you over", 
				effects = { Money = -500, Happiness = -12 }, 
				resultText = "Officer suggested you stop driving. Humiliating but maybe right.",
				clearFlag = "refused_stop_driving"
			},
			{ 
				text = "😰 Serious accident", 
				effects = { Health = -20, Money = -10000, Happiness = -25 }, 
				resultText = "Major crash. You're okay but... license is gone. It's over.",
				setFlag = "gave_up_driving",
				clearFlag = "refused_stop_driving"
			},
		},
	},
	
	{
		id = "m_exercise_for_seniors",
		minAge = 65, maxAge = 85,
		weight = 25, cooldown = 3,
		emoji = "🏊", title = "Senior Exercise Options",
		category = "health",
		text = "Doctor says exercise is crucial but you need something joint-friendly.",
		choices = {
			{ 
				text = "🏊 Water aerobics!", 
				effects = { Health = 12, Happiness = 10, Money = -100 }, 
				resultText = "Perfect low-impact! Made friends in class too! Life-changing!",
				setFlag = "senior_exercise"
			},
			{ 
				text = "🧘 Chair yoga", 
				effects = { Health = 8, Happiness = 8 }, 
				resultText = "Gentle stretching with support. Balance improving!",
				setFlag = "senior_exercise"
			},
			{ 
				text = "🚶 Daily walking", 
				effects = { Health = 10, Happiness = 6 }, 
				resultText = "Simple but effective! 30 minutes a day makes a difference!",
				setFlag = "senior_exercise"
			},
			{ 
				text = "🤷 Too tired", 
				effects = { Health = -8, Happiness = -5 }, 
				resultText = "Skipping exercise. Doctor disappointed. Strength fading faster."
			},
		},
	},
	
	{
		id = "m_home_safety_modifications",
		minAge = 70, maxAge = 90,
		weight = 20, oneTime = true,
		emoji = "🏠", title = "Home Safety Upgrades",
		category = "family",
		text = "Time to make the house safer. Falls are the biggest risk at this age.",
		choices = {
			{ 
				text = "🛁 Full bathroom upgrade", 
				effects = { Health = 10, Money = -5000, Happiness = 8 }, 
				resultText = "Grab bars, walk-in tub, non-slip everything! Peace of mind!",
				setFlag = "home_modified"
			},
			{ 
				text = "💡 Basic modifications", 
				effects = { Health = 5, Money = -1000, Happiness = 4 }, 
				resultText = "Better lighting, remove rugs, add rails. Much safer!",
				setFlag = "home_modified"
			},
			{ 
				text = "📲 Medical alert system", 
				effects = { Health = 3, Money = -600, Happiness = 2 }, 
				resultText = "Help button around your neck. Falls won't leave you stranded.",
				setFlag = "has_medical_alert"
			},
			{ 
				text = "🙅 House is fine", 
				effects = { Happiness = 2, Health = -5 }, 
				resultText = "No changes. Pride over practicality. Risky choice."
			},
		},
	},
	
	{
		id = "m_memory_concerns",
		minAge = 72, maxAge = 90,
		weight = 25, cooldown = 4,
		emoji = "🧠", title = "Memory Moments",
		category = "health",
		getDynamicData = function()
			local moments = {"forgot why you walked into a room", "can't find the right word", "misplaced something important", "forgot an appointment"}
			return { moment = moments[math.random(#moments)] }
		end,
		text = "You %moment%. Is this normal aging or something more?",
		choices = {
			{ text = "🧠 Just normal aging", effects = { Health = 2, Happiness = 4 }, resultText = "Doctor says it's normal. Everyone forgets things!" },
			{ text = "📝 Brain exercises!", effects = { Smarts = 6, Happiness = 4, Health = 3 }, resultText = "Puzzles, reading, staying sharp! Mind over matter!", setFlag = "brain_active" },
			{ text = "😰 Worried", effects = { Happiness = -6 }, resultText = "Monitoring it closely. Hope it's nothing serious." },
			{ text = "🏥 Getting checked", effects = { Health = 4, Smarts = 2, Money = -1000 }, resultText = "Better safe than sorry. Early detection matters.", setFlag = "memory_checked" },
		},
	},
	
	{
		id = "m_losing_spouse",
		minAge = 65, maxAge = 95,
		weight = 10, oneTime = true,
		requiresFlag = "married",
		emoji = "🕊️", title = "Losing Your Life Partner",
		category = "family",
		text = "Your spouse passed away. After all those years together... the loss is immense.",
		choices = {
			{ text = "💔 Devastated", effects = { Happiness = -30, Health = -10 }, resultText = "A piece of you is gone. Grief has no timeline.", clearFlags = {"married"}, setFlag = "widowed" },
			{ text = "🙏 Celebrating their life", effects = { Happiness = -15, Smarts = 3 }, resultText = "They lived well. Honoring their memory.", clearFlags = {"married"}, setFlag = "widowed" },
			{ text = "👨‍👩‍👧 Family rallying around", effects = { Happiness = -12 }, resultText = "Kids and grandkids are your support. Not alone.", clearFlags = {"married"}, setFlag = "widowed" },
			{ text = "💕 Grateful for the years", effects = { Happiness = -10, Smarts = 4 }, resultText = "What a journey you shared. Lucky to have had them.", clearFlags = {"married"}, setFlag = "widowed" },
		},
	},
	
	{
		id = "m_living_arrangements",
		minAge = 75, maxAge = 90,
		weight = 25, oneTime = true,
		emoji = "🏠", title = "Living Arrangement Decision",
		category = "family",
		text = "Living alone is getting harder. Time to think about options.",
		choices = {
			{ text = "🏠 Move in with family", effects = { Happiness = 8, Money = 30000 }, resultText = "Living with kids/grandkids. Not easy but safe.", setFlag = "living_with_family" },
			{ text = "🏥 Assisted living", effects = { Happiness = 4, Money = -50000 }, resultText = "Professional care, activities, peers. Adjusting.", setFlag = "assisted_living" },
			{ text = "💪 Staying independent!", effects = { Happiness = 10, Money = -10000 }, resultText = "Home modifications, help visits. Still on your own!", setFlag = "independent_senior" },
			{ text = "👫 Senior community", effects = { Happiness = 12, Money = -30000 }, resultText = "Independent living but with community. Best of both!", setFlag = "senior_community" },
		},
	},
	
	{
		id = "m_turning_80",
		minAge = 80, maxAge = 80,
		weight = 100, milestone = true, oneTime = true,
		emoji = "8️⃣0️⃣", title = "EIGHTY YEARS!",
		category = "family",
		text = "80! An octogenarian! You've outlived so many. What a journey!",
		choices = {
			{ text = "🎉 Party time!", effects = { Happiness = 18 }, resultText = "Four generations celebrating you! Amazing party!" },
			{ text = "💭 Reflecting on life", effects = { Happiness = 12, Smarts = 5 }, resultText = "What a full life. No regrets. Well, maybe a few." },
			{ text = "📝 Writing memoirs", effects = { Happiness = 10, Smarts = 6 }, resultText = "Documenting your story for future generations.", setFlag = "memoir_writer" },
			{ text = "🙏 Every day a bonus", effects = { Happiness = 15, Health = 2 }, resultText = "Living on bonus time. Gratitude for each morning." },
		},
	},
	
	{
		id = "m_wisdom_sharing",
		minAge = 70, maxAge = 95,
		weight = 25, cooldown = 3,
		emoji = "📖", title = "Passing Down Wisdom",
		category = "family",
		getDynamicData = function()
			local lessons = {"life advice", "family history", "your mistakes to avoid", "what really matters", "how to be happy"}
			return { lesson = lessons[math.random(#lessons)] }
		end,
		text = "Grandchild asked you about %lesson%. Sharing your years of wisdom!",
		choices = {
			{ text = "📖 Meaningful conversation", effects = { Happiness = 15, Smarts = 3 }, resultText = "They actually listened! Your wisdom lives on!", setFlag = "wisdom_sharer" },
			{ text = "😂 They'll learn themselves", effects = { Happiness = 6, Smarts = 2 }, resultText = "Some things can only be learned through experience." },
			{ text = "📝 Wrote it down", effects = { Happiness = 8, Smarts = 5 }, resultText = "Created a wisdom document for future generations!", setFlag = "wisdom_sharer" },
			{ text = "💕 Connected deeper", effects = { Happiness = 12 }, resultText = "This conversation brought you closer. Special bond.", setFlag = "wisdom_sharer" },
		},
	},
	
	{
		id = "m_daily_joys",
		minAge = 70, maxAge = 100,
		weight = 35, cooldown = 2,
		emoji = "☀️", title = "Simple Daily Joys",
		category = "social",
		getDynamicData = function()
			local joys = {"morning coffee ritual", "sitting in the garden", "watching birds", "reading the paper", "calling a friend", "afternoon nap", "sunset watching"}
			return { joy = joys[math.random(#joys)] }
		end,
		text = "Finding happiness in %joy%. Life's simple pleasures.",
		choices = {
			{ text = "☀️ Perfect moment", effects = { Happiness = 10, Health = 2 }, resultText = "This is what happiness feels like. Contentment." },
			{ text = "🙏 Grateful for small things", effects = { Happiness = 12, Smarts = 2 }, resultText = "Youth chases big things. Wisdom appreciates small ones.", setFlag = "content" },
			{ text = "📸 Documenting the routine", effects = { Happiness = 8 }, resultText = "Even mundane things are precious now." },
			{ text = "💭 Who knew this would bring joy?", effects = { Happiness = 8, Smarts = 3 }, resultText = "Younger you wouldn't believe this is happiness now." },
		},
	},
	
	{
		id = "m_outliving_friends",
		minAge = 78, maxAge = 95,
		weight = 25, cooldown = 3,
		emoji = "🕊️", title = "Losing Peers",
		category = "social",
		getDynamicData = function()
			return { friendName = LifeEvents.randomFirstName() }
		end,
		text = "%friendName%, your old friend, has passed away. Another one gone.",
		choices = {
			{ text = "😢 The club is shrinking", effects = { Happiness = -8 }, resultText = "Fewer people who remember the old days. Lonely feeling." },
			{ text = "🙏 Grateful you're still here", effects = { Happiness = 4, Smarts = 2 }, resultText = "Each day is a gift. Don't take it for granted." },
			{ text = "💕 Remembering good times", effects = { Happiness = 2, Smarts = 3 }, resultText = "The stories you shared. They live on in memory." },
			{ text = "📞 Calling other old friends", effects = { Happiness = 6 }, resultText = "Reminded to stay connected while you can." },
		},
	},
	
	{
		id = "m_health_miracle",
		minAge = 75, maxAge = 95,
		weight = 10, oneTime = true,
		emoji = "✨", title = "Health Surprise",
		category = "health",
		text = "Doctors are amazed! Your health at this age is remarkable!",
		choices = {
			{ text = "💪 Good genes!", effects = { Health = 10, Happiness = 15 }, resultText = "Thank the family tree! Still going strong!", setFlag = "remarkable_health" },
			{ text = "🥗 Lifestyle paid off", effects = { Health = 12, Happiness = 12 }, resultText = "Years of good habits = golden years!", setFlag = "remarkable_health" },
			{ text = "🍀 Just lucky", effects = { Health = 8, Happiness = 10 }, resultText = "No explanation. Just grateful!", setFlag = "remarkable_health" },
			{ text = "🤷 No secrets, just living", effects = { Health = 10, Happiness = 12, Smarts = 2 }, resultText = "Don't overthink it. Just enjoy!", setFlag = "remarkable_health" },
		},
	},
	
	{
		id = "m_turning_90",
		minAge = 90, maxAge = 90,
		weight = 100, milestone = true, oneTime = true,
		emoji = "9️⃣0️⃣", title = "NINETY YEARS!",
		category = "family",
		text = "90 YEARS OLD! A nonagenarian! This is truly remarkable!",
		choices = {
			{ text = "🎂 Biggest celebration!", effects = { Happiness = 25 }, resultText = "Everyone came! What an incredible party!" },
			{ text = "📰 Local news story!", effects = { Happiness = 18, Looks = 3 }, resultText = "You're famous! The paper did a story on you!" },
			{ text = "💭 Seen it all", effects = { Happiness = 15, Smarts = 6 }, resultText = "Wars, tech revolution, moon landing, internet... what a world." },
			{ text = "💪 Still got it!", effects = { Happiness = 20, Health = 5 }, resultText = "90 and still sharp! Defying all odds!", setFlag = "legendary_longevity" },
		},
	},
	
	{
		id = "m_centenarian",
		minAge = 100, maxAge = 100,
		weight = 100, milestone = true, oneTime = true,
		emoji = "💯", title = "ONE HUNDRED YEARS!!!",
		category = "family",
		text = "100 YEARS OLD! A CENTENARIAN! You've achieved something truly extraordinary!",
		choices = {
			{ text = "🎉 LEGENDARY!", effects = { Happiness = 50, Health = 10 }, resultText = "100 years of life! Letter from the President! INCREDIBLE!", setFlag = "centenarian" },
			{ text = "📺 National news!", effects = { Happiness = 40, Looks = 5 }, resultText = "You're on TV! The whole country celebrates you!", setFlag = "centenarian" },
			{ text = "👨‍👩‍👧 5 generations!", effects = { Happiness = 45 }, resultText = "Great-great grandchildren! What a legacy!", setFlag = "centenarian" },
			{ text = "💬 The secret?", effects = { Happiness = 35, Smarts = 10 }, resultText = "'Good humor and not dying!' - Your words of wisdom.", setFlag = "centenarian" },
		},
	},
	
	{
		id = "m_end_of_life_peace",
		minAge = 85, maxAge = 110,
		weight = 20, oneTime = true,
		emoji = "🕊️", title = "Finding Peace",
		category = "family",
		text = "Reflecting on a life fully lived. Are you at peace?",
		choices = {
			{ text = "🙏 Complete peace", effects = { Happiness = 20, Smarts = 5 }, resultText = "A good life. No regrets. Ready for whatever comes.", setFlag = "at_peace" },
			{ text = "💕 Family is everything", effects = { Happiness = 18 }, resultText = "Surrounded by love. That's all that matters.", setFlag = "at_peace" },
			{ text = "📖 Quite a story", effects = { Happiness = 15, Smarts = 6 }, resultText = "What an adventure it's been. Worth every moment.", setFlag = "at_peace" },
			{ text = "💫 Ready when it's time", effects = { Happiness = 12, Smarts = 4 }, resultText = "Acceptance. You've made your peace with mortality.", setFlag = "at_peace" },
		},
	},
}

return module
