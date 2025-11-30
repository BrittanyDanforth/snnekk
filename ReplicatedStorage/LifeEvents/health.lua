-- LifeEvents/health.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- HEALTH EVENTS
-- Diverse health situations across all life stages - not just "declining health"
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- CHILDHOOD HEALTH (0-12)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "h_childhood_flu",
		minAge = 3, maxAge = 12,
		weight = 30, cooldown = 2,
		emoji = "🤒", title = "Got the Flu!",
		category = "health",
		text = "You came home from school with the flu! Fever, chills, the works.",
		choices = {
			{ text = "🛏️ Rest and recover", effects = { Health = 5, Happiness = 4 }, resultText = "Mom's chicken soup and rest did the trick!" },
			{ text = "😭 Miss friend's party", effects = { Happiness = -8 }, resultText = "Had to miss the best party of the year. So unfair!" },
			{ text = "🎮 At least got games", effects = { Happiness = 6, Smarts = 2 }, resultText = "Week off school playing games! Silver lining!" },
			{ text = "🤧 Got everyone sick", effects = { Health = -5, Happiness = -3 }, resultText = "Spread it to the whole family. Oops." },
		},
	},
	
	{
		id = "h_childhood_broken_arm",
		minAge = 5, maxAge = 14,
		weight = 15, cooldown = 8,
		emoji = "🦴", title = "Broken Arm!",
		category = "health",
		getDynamicData = function()
			local causes = {"falling off the monkey bars", "skateboard accident", "tripped while running", "fell off your bike", "playground accident"}
			return { cause = causes[math.random(#causes)] }
		end,
		text = "You broke your arm %cause%! Time for a cast.",
		choices = {
			{ text = "✍️ Cast signatures!", effects = { Happiness = 4 }, resultText = "Everyone at school signed your cast. Kinda cool!" },
			{ text = "😤 Can't play sports", effects = { Happiness = -10 }, resultText = "No recess sports for 6 weeks. This stinks!" },
			{ text = "💪 Healed stronger", effects = { Health = 5 }, resultText = "Doctor says it healed great! Back to normal!" },
			{ text = "😢 Still hurts", effects = { Health = -8, Happiness = -5 }, resultText = "Healing was slow and painful. Rough time." },
		},
	},
	
	{
		id = "h_childhood_allergy_discovery",
		minAge = 3, maxAge = 15,
		weight = 15, oneTime = true,
		emoji = "🥜", title = "Allergy Discovered!",
		category = "health",
		getDynamicData = function()
			local allergies = {"peanuts", "shellfish", "dairy", "bee stings", "gluten"}
			return { allergy = allergies[math.random(#allergies)] }
		end,
		text = "You had a reaction! Turns out you're allergic to %allergy%.",
		choices = {
			{ text = "💉 Got an EpiPen", effects = { Health = 5, Smarts = 3 }, resultText = "Now you know! Staying safe with emergency meds.", setFlag = "has_allergy" },
			{ text = "😢 So many foods off-limits", effects = { Happiness = -8 }, resultText = "No more of your favorite foods. Life is unfair.", setFlag = "has_allergy" },
			{ text = "🏥 Scary hospital trip", effects = { Health = -5, Happiness = -10 }, resultText = "ER visit was terrifying. At least now you know.", setFlag = "has_allergy" },
			{ text = "📚 Learned to manage it", effects = { Smarts = 5 }, resultText = "Researched everything. You're an expert now!", setFlag = "has_allergy" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- TEEN HEALTH (13-17)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "h_teen_acne",
		minAge = 12, maxAge = 19,
		weight = 35, cooldown = 3,
		emoji = "😰", title = "Acne Breakout!",
		category = "health",
		text = "Puberty strikes again! Major acne breakout right before something important.",
		choices = {
			{ text = "💊 Dermatologist help", effects = { Health = 3, Money = -100, Looks = 5 }, resultText = "Treatment is working! Clearing up nicely." },
			{ text = "😭 So embarrassing", effects = { Happiness = -10, Looks = -3 }, resultText = "Didn't want to leave the house. Teen life is hard." },
			{ text = "💅 Makeup covers it", effects = { Happiness = 4, Looks = 2 }, resultText = "Got good at concealer! Can barely tell!" },
			{ text = "🤷 Embraced it", effects = { Happiness = 6, Smarts = 2 }, resultText = "Everyone has acne! Not letting it stop you." },
		},
	},
	
	{
		id = "h_teen_sports_injury",
		minAge = 13, maxAge = 22,
		weight = 25, cooldown = 4,
		emoji = "⚽", title = "Sports Injury!",
		category = "health",
		getDynamicData = function()
			local injuries = {
				{ type = "sprained ankle", severity = "minor" },
				{ type = "torn ACL", severity = "major" },
				{ type = "concussion", severity = "major" },
				{ type = "dislocated shoulder", severity = "moderate" },
				{ type = "pulled hamstring", severity = "minor" },
			}
			local chosen = injuries[math.random(#injuries)]
			return { injury = chosen.type, severity = chosen.severity }
		end,
		text = "Got a %injury% during practice! This could affect your season.",
		choices = {
			{ text = "🏥 Full recovery!", effects = { Health = 5, Happiness = 8 }, resultText = "Physical therapy paid off! Back at 100%!" },
			{ text = "😔 Season over", effects = { Happiness = -15, Health = -5 }, resultText = "Too serious to continue this season. Devastating." },
			{ text = "💪 Pushed through", effects = { Health = -10, Happiness = 4 }, resultText = "Played injured. Not smart but didn't want to let team down." },
			{ text = "🔄 Changed sports", effects = { Happiness = 2, Smarts = 3 }, resultText = "Injury made you try something new. Actually enjoying it!" },
		},
	},
	
	{
		id = "h_teen_mental_health",
		minAge = 13, maxAge = 22,
		weight = 25, cooldown = 5,
		emoji = "🧠", title = "Mental Health Check",
		category = "health",
		text = "You've been feeling really stressed and anxious lately.",
		choices = {
			{ text = "💬 Talked to someone", effects = { Happiness = 10, Health = 5 }, resultText = "Opening up really helped! You're not alone." },
			{ text = "🎨 Found creative outlet", effects = { Happiness = 8, Smarts = 3 }, resultText = "Art/music/writing became your therapy. Beautiful expression." },
			{ text = "😶 Kept it inside", effects = { Happiness = -10, Health = -5 }, resultText = "Bottling it up made things worse. Please reach out." },
			{ text = "🏃 Exercise helped", effects = { Happiness = 8, Health = 8 }, resultText = "Physical activity cleared your head. Natural mood booster!" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- ADULT HEALTH (18-55)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "h_adult_back_pain",
		minAge = 25, maxAge = 65,
		weight = 30, cooldown = 3,
		emoji = "🔙", title = "Back Problems!",
		category = "health",
		getDynamicData = function()
			local causes = {"from sitting at desk all day", "from lifting something heavy", "for no apparent reason", "from sleeping wrong", "from that old injury"}
			return { cause = causes[math.random(#causes)] }
		end,
		text = "Your back has been killing you %cause%!",
		choices = {
			{ text = "💆 Chiropractor visit", effects = { Health = 8, Money = -150 }, resultText = "That adjustment was AMAZING! Relief at last!" },
			{ text = "💊 Pain pills", effects = { Health = 2, Happiness = 4 }, resultText = "Managing with medication. Not ideal but functional." },
			{ text = "🧘 Started yoga", effects = { Health = 10, Happiness = 6 }, resultText = "Yoga is life changing! Why didn't you start sooner?", setFlag = "does_yoga" },
			{ text = "😫 Just suffered", effects = { Health = -8, Happiness = -10 }, resultText = "Ignored it. Got worse. Should've done something earlier." },
		},
	},
	
	{
		id = "h_adult_sleep_issues",
		minAge = 20, maxAge = 70,
		weight = 25, cooldown = 3,
		emoji = "😴", title = "Sleep Problems!",
		category = "health",
		text = "You haven't been sleeping well. Tossing and turning every night.",
		choices = {
			{ text = "☕ Just more coffee", effects = { Health = -5, Smarts = -3 }, resultText = "Caffeinating through it. Zombie mode activated." },
			{ text = "📵 Digital detox", effects = { Health = 8, Happiness = 6 }, resultText = "No screens before bed WORKS! Sleeping like a baby now!" },
			{ text = "💊 Sleep study", effects = { Health = 6, Money = -300 }, resultText = "Discovered you have sleep apnea. Treatment helping!" },
			{ text = "🧘 Better sleep hygiene", effects = { Health = 10, Happiness = 8 }, resultText = "New routine, new mattress, blackout curtains. GAME CHANGER!" },
		},
	},
	
	{
		id = "h_adult_weight_struggle",
		minAge = 22, maxAge = 70,
		weight = 25, cooldown = 4,
		emoji = "⚖️", title = "Weight Concerns",
		category = "health",
		text = "Your clothes are fitting differently. Time to address your weight.",
		choices = {
			{ text = "🥗 Lifestyle change", effects = { Health = 12, Happiness = 8, Looks = 5 }, resultText = "Diet and exercise working! Feel amazing!", setFlag = "healthy_lifestyle" },
			{ text = "🏋️ Started gym", effects = { Health = 8, Happiness = 4, Money = -50 }, resultText = "Gym membership paying off! Getting stronger!" },
			{ text = "😔 Emotional eating", effects = { Health = -8, Happiness = -6 }, resultText = "Stress made you eat more. Cycle continues..." },
			{ text = "🤷 Body positive", effects = { Happiness = 6, Smarts = 3 }, resultText = "Accepted yourself as you are. Mental health matters too!" },
		},
	},
	
	{
		id = "h_adult_health_scare",
		minAge = 30, maxAge = 70,
		weight = 15, cooldown = 6,
		emoji = "😨", title = "Health Scare!",
		category = "health",
		getDynamicData = function()
			local scares = {"suspicious mole", "chest pain episode", "abnormal lab results", "lump you found", "unexplained symptoms"}
			return { scare = scares[math.random(#scares)] }
		end,
		text = "Doctor wants more tests for that %scare%. Scary waiting period.",
		choices = {
			{ text = "😌 False alarm!", effects = { Health = 5, Happiness = 15 }, resultText = "All clear! Best news ever! Life appreciation intensified!" },
			{ text = "⚠️ Need monitoring", effects = { Health = 0, Happiness = -5 }, resultText = "Not serious but needs watching. Annual checkups are important." },
			{ text = "😰 Anxiety spiral", effects = { Health = -5, Happiness = -15 }, resultText = "The waiting was torture. Even good news didn't stop the worry." },
			{ text = "🏥 Caught it early", effects = { Health = 8, Smarts = 3 }, resultText = "Something was found but caught early! Treatment successful!" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- SENIOR HEALTH (55+) - DIVERSE, NOT JUST DECLINING!
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "h_senior_joint_pain",
		minAge = 50, maxAge = 100,
		weight = 30, cooldown = 3,
		emoji = "🦵", title = "Joint Pain",
		category = "health",
		getDynamicData = function()
			local joints = {"knee", "hip", "shoulder", "hands", "back"}
			return { joint = joints[math.random(#joints)] }
		end,
		text = "Your %joint% has been bothering you more than usual lately.",
		choices = {
			{ text = "💊 Anti-inflammatory", effects = { Health = 3, Money = -30 }, resultText = "Medication helping manage the pain." },
			{ text = "🏊 Water aerobics", effects = { Health = 10, Happiness = 8 }, resultText = "Low-impact exercise is perfect! Actually having fun!", setFlag = "active_senior" },
			{ text = "🦿 Surgery option", effects = { Health = 15, Money = -5000 }, resultText = "Replacement surgery was scary but you're like new!" },
			{ text = "🧘 Gentle stretching", effects = { Health = 6, Happiness = 4 }, resultText = "Daily stretching routine makes a big difference!" },
		},
	},
	
	{
		id = "h_senior_hearing_vision",
		minAge = 55, maxAge = 100,
		weight = 25, cooldown = 4,
		emoji = "👓", title = "Sensory Changes",
		category = "health",
		getDynamicData = function()
			local senses = {
				{ type = "vision", solution = "glasses", emoji = "👓" },
				{ type = "hearing", solution = "hearing aids", emoji = "👂" },
			}
			local chosen = senses[math.random(#senses)]
			return { sense = chosen.type, solution = chosen.solution, senseEmoji = chosen.emoji }
		end,
		getDynamicEmoji = function(data) return data.senseEmoji or "👓" end,
		text = "Your %sense% isn't what it used to be. Doctor recommends %solution%.",
		choices = {
			{ text = "✅ Embraced the change", effects = { Health = 5, Happiness = 6 }, resultText = "Amazing difference! Should've done this sooner!" },
			{ text = "😤 Stubbornly refused", effects = { Happiness = -8, Health = -5 }, resultText = "Pride before quality of life. Missing out on conversations/sights." },
			{ text = "😎 Got stylish ones", effects = { Happiness = 8, Looks = 3 }, resultText = "Actually looking pretty good! New look!" },
			{ text = "🔬 Latest technology", effects = { Health = 8, Money = -2000 }, resultText = "Top of the line! Crystal clear! Worth the investment!" },
		},
	},
	
	{
		id = "h_senior_fitness_milestone",
		minAge = 55, maxAge = 90,
		weight = 20, cooldown = 5,
		emoji = "🏆", title = "Fitness Achievement!",
		category = "health",
		getDynamicData = function()
			local achievements = {
				"completed a 5K walk for charity",
				"hiked a challenging trail",
				"won your age group in a golf tournament",
				"completed a senior fitness challenge",
				"got your best health checkup in years",
			}
			return { achievement = achievements[math.random(#achievements)] }
		end,
		text = "You %achievement%! Age is just a number!",
		choices = {
			{ text = "💪 Proud of yourself!", effects = { Health = 10, Happiness = 15 }, resultText = "Proving everyone wrong! Still got it!", setFlag = "active_senior" },
			{ text = "🎯 Set bigger goals", effects = { Health = 8, Happiness = 12, Smarts = 3 }, resultText = "If you can do this, what else is possible?" },
			{ text = "👨‍👩‍👧 Inspiring family", effects = { Happiness = 12 }, resultText = "Grandkids think you're a superhero!" },
			{ text = "🏥 Overdid it a bit", effects = { Health = -5, Happiness = 4 }, resultText = "Pushed too hard but worth it. Rest time." },
		},
	},
	
	{
		id = "h_senior_medication_management",
		minAge = 55, maxAge = 100,
		weight = 25, cooldown = 3,
		emoji = "💊", title = "Medication Review",
		category = "health",
		text = "Doctor reviewing your medications. Time to optimize your health routine.",
		choices = {
			{ text = "💊 Reduced meds!", effects = { Health = 8, Happiness = 10, Money = 100 }, resultText = "Your health improved enough to cut some pills! Great news!" },
			{ text = "🔄 Adjusted dosages", effects = { Health = 5 }, resultText = "Fine-tuned for better effectiveness. Feeling better!" },
			{ text = "➕ Added new one", effects = { Health = 3, Money = -100 }, resultText = "New medication for a new issue. Managing it." },
			{ text = "⚠️ Bad interaction found", effects = { Health = 10, Happiness = 5 }, resultText = "Caught a dangerous drug interaction! Close call!" },
		},
	},
	
	{
		id = "h_senior_fall_prevention",
		minAge = 65, maxAge = 100,
		weight = 25, cooldown = 4,
		emoji = "⚠️", title = "Balance Check",
		category = "health",
		text = "You've had a couple near-falls recently. Time to address it.",
		choices = {
			{ text = "🏠 Home modifications", effects = { Health = 8, Money = -500 }, resultText = "Grab bars, non-slip mats, better lighting. Much safer!" },
			{ text = "🧘 Balance exercises", effects = { Health = 10, Happiness = 5 }, resultText = "Tai Chi classes working wonders! Balance is back!" },
			{ text = "🦯 Got a cane", effects = { Health = 5, Happiness = -2 }, resultText = "Practical choice. Safety over vanity." },
			{ text = "🤷 Ignored the signs", effects = { Health = -15, Happiness = -10 }, resultText = "Had a bad fall. Hospital stay. Should've taken precautions." },
		},
	},
	
	{
		id = "h_senior_memory_concern",
		minAge = 60, maxAge = 100,
		weight = 20, cooldown = 5,
		emoji = "🧠", title = "Memory Moment",
		category = "health",
		text = "You've been forgetting things more often. Family noticed too.",
		choices = {
			{ text = "🧩 Brain exercises", effects = { Smarts = 5, Happiness = 5 }, resultText = "Puzzles, games, reading! Keeping your mind sharp!" },
			{ text = "👨‍⚕️ Got evaluated", effects = { Health = 3, Happiness = 4 }, resultText = "Just normal aging. Strategies to help memory." },
			{ text = "😰 Really worried", effects = { Happiness = -12, Health = -3 }, resultText = "Fear of cognitive decline is consuming you." },
			{ text = "📝 Systems in place", effects = { Smarts = 8, Happiness = 6 }, resultText = "Lists, reminders, routines. Working smarter!" },
		},
	},
	
	{
		id = "h_senior_new_hobby_health",
		minAge = 55, maxAge = 90,
		weight = 20, cooldown = 4,
		emoji = "🎨", title = "Health Through Hobby",
		category = "health",
		getDynamicData = function()
			local hobbies = {
				{ hobby = "gardening", benefit = "exercise and fresh air" },
				{ hobby = "dancing", benefit = "cardio and balance" },
				{ hobby = "swimming", benefit = "low-impact full body workout" },
				{ hobby = "volunteering", benefit = "mental health and purpose" },
				{ hobby = "cooking classes", benefit = "nutrition and social connection" },
			}
			local chosen = hobbies[math.random(#hobbies)]
			return { hobby = chosen.hobby, benefit = chosen.benefit }
		end,
		text = "You started %hobby%! Getting great health benefits from %benefit%.",
		choices = {
			{ text = "❤️ Life-changing!", effects = { Health = 12, Happiness = 15 }, resultText = "This has transformed your life! Why didn't you start earlier?" },
			{ text = "👥 Made friends", effects = { Happiness = 12, Smarts = 3 }, resultText = "The social aspect is as good as the health benefits!" },
			{ text = "🏆 Got really good", effects = { Happiness = 10, Smarts = 5 }, resultText = "Natural talent! Or maybe experience is the best teacher!" },
			{ text = "😔 Didn't stick", effects = { Happiness = -3 }, resultText = "Started strong but lost motivation. Maybe try something else." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- UNIVERSAL HEALTH EVENTS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "h_dental_emergency",
		minAge = 10, maxAge = 100,
		weight = 20, cooldown = 4,
		emoji = "🦷", title = "Dental Emergency!",
		category = "health",
		getDynamicData = function()
			local issues = {"toothache", "cracked tooth", "cavity", "abscess", "wisdom tooth pain"}
			return { issue = issues[math.random(#issues)] }
		end,
		text = "Major %issue%! Can't ignore this one.",
		choices = {
			{ text = "🦷 Emergency dentist", effects = { Health = 8, Money = -500 }, resultText = "Fixed! The relief is incredible!" },
			{ text = "💊 Pain pills for now", effects = { Health = -3, Happiness = -5 }, resultText = "Temporary fix. This will get worse." },
			{ text = "😱 Major procedure needed", effects = { Health = 5, Money = -2000 }, resultText = "Root canal/extraction. Expensive but necessary." },
			{ text = "🍀 Simple fix!", effects = { Health = 5, Money = -100 }, resultText = "Not as bad as feared! Quick fix!" },
		},
	},
	
	{
		id = "h_food_poisoning",
		minAge = 10, maxAge = 100,
		weight = 20, cooldown = 3,
		emoji = "🤮", title = "Food Poisoning!",
		category = "health",
		getDynamicData = function()
			local sources = {"that gas station sushi", "the sketchy restaurant", "something from the fridge", "the potluck dish", "undercooked chicken"}
			return { source = sources[math.random(#sources)] }
		end,
		text = "Definitely %source%. You're paying for it now.",
		choices = {
			{ text = "🚽 24-hour nightmare", effects = { Health = -10, Happiness = -12 }, resultText = "The worst 24 hours. Never eating there again." },
			{ text = "🏥 Had to go to ER", effects = { Health = -15, Money = -800 }, resultText = "Severe dehydration. Hospital stay needed." },
			{ text = "🤢 Mild but miserable", effects = { Health = -5, Happiness = -6 }, resultText = "Could've been worse. Still awful." },
			{ text = "🍵 Tea and rest", effects = { Health = 5, Happiness = 2 }, resultText = "Home remedies worked. Recovery mode." },
		},
	},
	
	{
		id = "h_annual_checkup",
		minAge = 18, maxAge = 100,
		weight = 25, cooldown = 8,
		emoji = "🏥", title = "Annual Checkup Results",
		category = "health",
		text = "Your yearly physical results are in!",
		choices = {
			{ text = "💪 Perfect health!", effects = { Health = 10, Happiness = 12 }, resultText = "Doctor says you're in great shape! Keep it up!" },
			{ text = "⚠️ Some concerns", effects = { Health = -3, Smarts = 3 }, resultText = "Some numbers to watch. Lifestyle changes recommended." },
			{ text = "😅 Cholesterol high", effects = { Health = -5, Happiness = -4 }, resultText = "Diet changes needed. No more bacon?" },
			{ text = "🎉 Better than last year!", effects = { Health = 8, Happiness = 10 }, resultText = "Your changes are working! Improvement across the board!" },
		},
	},
	
	{
		id = "h_exercise_milestone",
		minAge = 15, maxAge = 80,
		weight = 20, cooldown = 4,
		emoji = "🏃", title = "Fitness Progress!",
		category = "health",
		getDynamicData = function()
			local milestones = {"ran your first mile without stopping", "hit a new personal record", "reached your goal weight", "completed a 30-day challenge", "got compliments on your progress"}
			return { milestone = milestones[math.random(#milestones)] }
		end,
		text = "You %milestone%! Hard work paying off!",
		choices = {
			{ text = "💪 So proud!", effects = { Health = 10, Happiness = 12, Looks = 3 }, resultText = "The dedication is showing! Feel amazing!" },
			{ text = "🎯 Setting higher goals", effects = { Health = 8, Smarts = 3 }, resultText = "If you achieved this, what's next?" },
			{ text = "😤 Injury setback", effects = { Health = -8, Happiness = -5 }, resultText = "Pushed too hard. Time to recover and try again." },
			{ text = "📸 Progress pics!", effects = { Happiness = 8, Looks = 5 }, resultText = "The before/after is INCREDIBLE! Motivating others!" },
		},
	},
}

return module
