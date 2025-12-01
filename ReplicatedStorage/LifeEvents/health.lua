-- LifeEvents/health.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- HEALTH EVENTS
-- BitLife-style: Player picks ACTIONS, game decides OUTCOMES
-- ═══════════════════════════════════════════════════════════════════════════════

-- LOCAL HELPER FUNCTIONS (no external dependencies) - health.lua has no friend calls but keeping pattern consistent
local FIRST_NAMES = {"Alex", "Jordan", "Taylor", "Casey", "Morgan", "Riley", "Jamie", "Cameron", "Quinn", "Avery", "Parker", "Skyler", "Dakota", "Reese", "Finley", "Sage", "Rowan", "Charlie", "Emerson", "Hayden"}

local function randomFirstName()
	return FIRST_NAMES[math.random(#FIRST_NAMES)]
end

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
		text = "You're sick with the flu! Fever and chills. Mom says you need to rest. What do you do?",
		choices = {
			{ text = "🛏️ Stay in bed like told", effects = { Health = 8, Happiness = 3 }, resultText = "Rested and recovered quickly! Mom's soup really helped!" },
			{ text = "🎮 Sneak to play games", effects = { Happiness = 5, Health = -5 }, resultText = "Got caught! Mom wasn't happy. Also got sicker. Worth it?" },
			{ text = "😭 Complain constantly", effects = { Happiness = -5, Health = 2 }, resultText = "Everyone's tired of the whining. But you got extra attention..." },
			{ text = "🏫 Try to go to school anyway", effects = { Health = -10, Smarts = -3 }, resultText = "Got way worse! Sent home after an hour. Spread it to three classmates. Bad call." },
		},
	},
	
	{
		id = "h_childhood_broken_arm",
		minAge = 5, maxAge = 14,
		weight = 15, cooldown = 8,
		emoji = "🦴", title = "Broke Your Arm!",
		category = "health",
		getDynamicData = function()
			local causes = {"falling off the monkey bars", "skateboard trick gone wrong", "bike crash", "tripped while running"}
			return { cause = causes[math.random(#causes)] }
		end,
		text = "You broke your arm %cause%! Doctor put it in a cast. 6 weeks to heal. What's your attitude?",
		choices = {
			{ text = "✍️ Show off the cast", effects = { Happiness = 8, Looks = 2 }, resultText = "Everyone signed it! You're basically a celebrity at school!" },
			{ text = "😤 Be mad about it", effects = { Happiness = -10, Health = 2 }, resultText = "Sulked for weeks. Missing out on sports was the worst." },
			{ text = "💪 Try to do stuff anyway", effects = { Health = -8, Happiness = -5 }, resultText = "Re-injured it being dumb! Reset the healing time. Doctor was not impressed." },
			{ text = "📚 Focus on other things", effects = { Smarts = 5, Happiness = 3 }, resultText = "Read more books, got better grades. Made the best of it!" },
		},
	},
	
	{
		id = "h_childhood_allergy_reaction",
		minAge = 3, maxAge = 15,
		weight = 15, oneTime = true,
		emoji = "🥜", title = "Allergic Reaction!",
		category = "health",
		getDynamicData = function()
			local foods = {"peanuts", "shellfish", "dairy", "eggs", "tree nuts"}
			return { food = foods[math.random(#foods)] }
		end,
		text = "You ate something with %food% and your throat is swelling! Can't breathe well! What do you do?",
		choices = {
			{ 
				text = "💉 Use EpiPen", 
				chanceSuccess = 0.90, -- EpiPen is very effective
				effectsOnSuccess = { Health = 5, Smarts = 5 }, 
				effectsOnFail = { Health = -15, Money = -1000, Happiness = -10 },
				resultText = "The EpiPen worked! You're okay but that was SCARY. Now you know your allergy.", 
				resultTextFail = "The EpiPen helped but you still needed the hospital! Severe reaction.", 
				setFlag = "has_allergy" 
			},
			{ 
				text = "🏥 Rush to hospital", 
				chanceSuccess = 0.80, -- Good chance if you get there in time
				effectsOnSuccess = { Health = -5, Money = -500, Happiness = -5 }, 
				effectsOnFail = { Health = -25, Money = -3000, Happiness = -15 },
				resultText = "Emergency room trip! They stabilized you in time. Terrifying experience.", 
				resultTextFail = "You didn't get there fast enough! ICU stay, barely survived.", 
				setFlag = "has_allergy" 
			},
			{ 
				text = "😰 Wait it out", 
				chanceSuccess = 0.40, -- Risky to not seek help
				effectsOnSuccess = { Health = -3, Happiness = -5 }, 
				effectsOnFail = { Health = -30, Money = -2000, Happiness = -20 },
				resultText = "Got lucky! It was a mild reaction. Hives and discomfort but nothing deadly.", 
				resultTextFail = "BAD IDEA! Throat closed up. Someone called 911. Almost died!", 
				setFlag = "has_allergy" 
			},
			{ 
				text = "🆘 Call 911 immediately", 
				chanceSuccess = 0.85, -- Emergency services are effective
				effectsOnSuccess = { Health = -8, Money = -800, Happiness = -8, Smarts = 3 }, 
				effectsOnFail = { Health = -20, Money = -2500, Happiness = -12 },
				resultText = "Paramedics arrived fast! They treated you on the spot. Smart thinking.", 
				resultTextFail = "Help came but it was a close call. Ambulance ride to ICU.", 
				setFlag = "has_allergy" 
			},
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
		text = "Major acne breakout! Right before something important. What do you do?",
		choices = {
			{ text = "👨‍⚕️ Go to dermatologist", effects = { Health = 5, Money = -150, Looks = 5 }, resultText = "Got prescription treatment. Working great! Worth the cost." },
			{ text = "💊 Pop them all", effects = { Looks = -5, Health = -3 }, resultText = "Made it SO much worse! Scarring and more breakouts. Don't do that!" },
			{ text = "💅 Cover with makeup", effects = { Looks = 3, Happiness = 3 }, resultText = "Concealer is magic! Got through the event. Confidence saved." },
			{ text = "🤷 Just deal with it", effects = { Happiness = -8, Smarts = 2 }, resultText = "Went anyway. It was fine. No one cared as much as you did." },
		},
	},
	
	{
		id = "h_teen_sports_injury",
		minAge = 13, maxAge = 22,
		weight = 25, cooldown = 4,
		emoji = "⚽", title = "Sports Injury!",
		category = "health",
		getDynamicData = function()
			local injuries = {"sprained ankle", "knee pain", "shoulder issue", "back strain"}
			return { injury = injuries[math.random(#injuries)] }
		end,
		text = "You got a %injury% during practice! Coach says take it easy. What do you do?",
		choices = {
			{ text = "🏥 Get it properly checked", effects = { Health = 10, Money = -200 }, resultText = "Doctor said rest 2 weeks. Followed orders. Full recovery!" },
			{ text = "💪 Play through the pain", effects = { Health = -15, Happiness = -8 }, resultText = "Made it WAY worse! Now out for the whole season. Should've rested." },
			{ text = "🧊 Ice and rest at home", effects = { Health = 5, Happiness = 2 }, resultText = "Took care of it yourself. Minor injury healed fine!" },
			{ text = "😤 Refuse to sit out", effects = { Health = -25, Happiness = -15 }, resultText = "Tore something! Surgery needed. Career-threatening. Pride has a price." },
		},
	},
	
	{
		id = "h_teen_mental_health",
		minAge = 13, maxAge = 22,
		weight = 25, cooldown = 5,
		emoji = "🧠", title = "Feeling Down...",
		category = "health",
		text = "You've been feeling really down, stressed, and anxious lately. What do you do about it?",
		choices = {
			{ text = "💬 Talk to someone", effects = { Happiness = 12, Health = 8 }, resultText = "Opened up to a friend/parent. Felt so much better not being alone in it." },
			{ text = "😶 Keep it to yourself", effects = { Happiness = -15, Health = -10 }, resultText = "Bottled it up. Got worse. Please reach out - you don't have to suffer alone." },
			{ text = "🎨 Express it creatively", effects = { Happiness = 8, Smarts = 5 }, resultText = "Art/music/writing became your outlet. Beautiful expression of hard feelings." },
			{ text = "🏃 Exercise it out", effects = { Happiness = 10, Health = 12 }, resultText = "Physical activity really helped! Natural mood booster. Feeling better!" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- ADULT HEALTH (18-55)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "h_adult_back_pain",
		minAge = 25, maxAge = 65,
		weight = 30, cooldown = 3,
		emoji = "🔙", title = "Back Pain!",
		category = "health",
		getDynamicData = function()
			local causes = {"from sitting all day", "from lifting wrong", "for no reason", "from sleeping weird"}
			return { cause = causes[math.random(#causes)] }
		end,
		text = "Your back is killing you %cause%! What do you do about it?",
		choices = {
			{ text = "💆 Go to chiropractor", effects = { Health = 10, Money = -150, Happiness = 5 }, resultText = "That adjustment was AMAZING! Relief! Walking out feeling new!" },
			{ text = "💊 Just take pain pills", effects = { Health = -5, Happiness = -3 }, resultText = "Masking the problem. Didn't fix anything. Still hurts." },
			{ text = "🧘 Start doing yoga", effects = { Health = 15, Happiness = 8 }, resultText = "Game changer! Flexibility and strength fixing the root cause!", setFlag = "does_yoga" },
			{ text = "😫 Ignore it", effects = { Health = -12, Happiness = -10 }, resultText = "Got way worse! Now can barely move. Should've done something earlier." },
		},
	},
	
	{
		id = "h_adult_checkup_results",
		minAge = 25, maxAge = 70,
		weight = 20, cooldown = 5,
		emoji = "🏥", title = "Doctor Wants to Talk",
		category = "health",
		text = "Your test results came back and the doctor wants to discuss them. You're nervous. What's your approach?",
		choices = {
			{ text = "😰 Prepare for worst", effects = { Happiness = -10, Health = 10 }, resultText = "Good news! You're fine! All that worry for nothing. But good to check!" },
			{ text = "🙏 Stay positive", effects = { Happiness = 5, Health = -5 }, resultText = "Some concerns found. Treatable but need lifestyle changes. Caught early at least." },
			{ text = "🗓️ Keep delaying the call", effects = { Health = -15, Happiness = -15 }, resultText = "Avoided it for months. Problem got worse. Now it's serious. Don't do this!" },
			{ text = "📋 Ask lots of questions", effects = { Smarts = 5, Health = 5 }, resultText = "Understanding your health is power! Made a plan with the doctor. Proactive!" },
		},
	},
	
	{
		id = "h_adult_weight_issue",
		minAge = 22, maxAge = 70,
		weight = 25, cooldown = 4,
		emoji = "⚖️", title = "Weight Concerns",
		category = "health",
		text = "You've noticed significant weight change. Clothes fitting differently. What do you do?",
		choices = {
			{ text = "🥗 Change diet seriously", effects = { Health = 15, Happiness = 5, Looks = 5 }, resultText = "Committed to change! Seeing results! Feel so much better!" },
			{ text = "🏋️ Start exercising", effects = { Health = 10, Happiness = 8, Money = -50 }, resultText = "Gym membership paying off! Stronger, healthier, more energy!" },
			{ text = "🍕 Keep same habits", effects = { Health = -10, Happiness = -5 }, resultText = "Problem got worse. Doctors concerned now. Should've acted earlier." },
			{ text = "💊 Try a fad diet", effects = { Health = -8, Happiness = -5, Money = -100 }, resultText = "Didn't work. Lost then gained it all back. No shortcuts." },
		},
	},
	
	{
		id = "h_adult_health_scare",
		minAge = 30, maxAge = 70,
		weight = 15, cooldown = 6,
		emoji = "😨", title = "Health Scare!",
		category = "health",
		getDynamicData = function()
			local scares = {"suspicious lump", "chest pains", "abnormal test", "worrying symptoms"}
			return { scare = scares[math.random(#scares)] }
		end,
		text = "You found a %scare%. Doctor ordered more tests. Waiting for results. What do you do?",
		choices = {
			{ text = "📅 Keep the appointment", effects = { Health = 10, Happiness = 8 }, resultText = "FALSE ALARM! All clear! Relief washes over you. So grateful!" },
			{ text = "😰 Spiral with worry", effects = { Health = -5, Happiness = -20 }, resultText = "Results were fine but the anxiety was awful. The wait was torture." },
			{ text = "🗓️ Delay getting results", effects = { Health = -15, Happiness = -15 }, resultText = "Something WAS wrong. Delaying made it worse. Could've been caught earlier." },
			{ text = "💪 Stay busy, stay calm", effects = { Health = 5, Happiness = 5, Smarts = 3 }, resultText = "Results showed minor issue, easily treatable. Good attitude helped!" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- SENIOR HEALTH (55+)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "h_senior_joint_pain",
		minAge = 50, maxAge = 100,
		weight = 30, cooldown = 3,
		emoji = "🦵", title = "Joint Pain!",
		category = "health",
		getDynamicData = function()
			local joints = {"knee", "hip", "shoulder", "hands"}
			return { joint = joints[math.random(#joints)] }
		end,
		text = "Your %joint% has been really bothering you. What do you do about it?",
		choices = {
			{ text = "💊 Take anti-inflammatory", effects = { Health = 3, Money = -30 }, resultText = "Medication helps manage the pain. Not fixed but functional." },
			{ text = "🏊 Try water exercises", effects = { Health = 12, Happiness = 10 }, resultText = "Low-impact aqua aerobics is perfect! Actually enjoying it!", setFlag = "active_senior" },
			{ text = "😤 Tough it out", effects = { Health = -10, Happiness = -8 }, resultText = "Got way worse! Now need serious intervention. Should've addressed it." },
			{ text = "👨‍⚕️ See a specialist", effects = { Health = 15, Money = -500 }, resultText = "Physical therapy plan is working! Mobility improving!" },
		},
	},
	
	{
		id = "h_senior_vision_hearing",
		minAge = 55, maxAge = 100,
		weight = 25, cooldown = 4,
		emoji = "👓", title = "Senses Changing",
		category = "health",
		getDynamicData = function()
			local issues = {
				{ type = "vision", fix = "glasses" },
				{ type = "hearing", fix = "hearing aids" },
			}
			local chosen = issues[math.random(#issues)]
			return { sense = chosen.type, fix = chosen.fix }
		end,
		text = "Your %sense% isn't what it used to be. Doctor recommends %fix%. What do you do?",
		choices = {
			{ text = "✅ Get them right away", effects = { Health = 8, Happiness = 10, Money = -500 }, resultText = "Wow! What a difference! Should've done this sooner!" },
			{ text = "😤 Refuse, you're fine", effects = { Health = -8, Happiness = -10 }, resultText = "Stubborn pride. Missing conversations, can't read signs. Quality of life suffering." },
			{ text = "💰 Wait, too expensive", effects = { Health = -5, Happiness = -5 }, resultText = "Delayed getting help. Problems got worse. Eventually had to anyway." },
			{ text = "😎 Get fancy stylish ones", effects = { Health = 8, Looks = 5, Money = -800, Happiness = 10 }, resultText = "Looking good AND seeing/hearing great! Top quality!" },
		},
	},
	
	{
		id = "h_senior_fall",
		minAge = 65, maxAge = 100,
		weight = 25, cooldown = 4,
		emoji = "⚠️", title = "You Fell!",
		category = "health",
		text = "You took a fall! Lying on the ground. What do you do?",
		choices = {
			{ text = "📞 Call for help", effects = { Health = -5, Happiness = 5 }, resultText = "Help arrived. Minor injury. Good thing you had your phone!" },
			{ text = "💪 Try to get up alone", effects = { Health = -15, Happiness = -10 }, resultText = "Made it worse trying! Hurt yourself more. Don't do that!" },
			{ text = "🆘 Press medical alert", effects = { Health = 0, Happiness = 8, Money = -30 }, resultText = "Worth every penny! Help arrived fast. So glad you had it." },
			{ text = "😤 Lie there in denial", effects = { Health = -20, Happiness = -15 }, resultText = "Hours before someone found you. Hypothermia. Hospitalized. Scary." },
		},
	},
	
	{
		id = "h_senior_memory",
		minAge = 60, maxAge = 100,
		weight = 20, cooldown = 5,
		emoji = "🧠", title = "Memory Concerns",
		category = "health",
		text = "You've been forgetting things more often. Where did you put the keys? What were you saying? What do you do?",
		choices = {
			{ text = "🧩 Brain exercises daily", effects = { Smarts = 8, Happiness = 5 }, resultText = "Puzzles, games, learning! Keeping your mind sharp!" },
			{ text = "👨‍⚕️ Get evaluated", effects = { Health = 5, Happiness = 3 }, resultText = "Doctor says it's normal aging. Gave you strategies to help. Relief!" },
			{ text = "😰 Panic about it", effects = { Happiness = -15, Health = -5 }, resultText = "The worry makes it worse! Anxiety affecting memory more than age." },
			{ text = "📝 Create systems", effects = { Smarts = 10, Happiness = 8 }, resultText = "Lists, routines, reminders everywhere! Working smarter not harder!" },
		},
	},
	
	{
		id = "h_senior_staying_active",
		minAge = 55, maxAge = 85,
		weight = 20, cooldown = 4,
		emoji = "🚶", title = "Staying Active?",
		category = "health",
		text = "Friends invite you to join a senior fitness class. What do you do?",
		choices = {
			{ text = "✅ Join enthusiastically", effects = { Health = 15, Happiness = 12 }, resultText = "LOVE IT! New friends, better health, more energy! Best decision!", setFlag = "active_senior" },
			{ text = "🤷 Make excuses", effects = { Health = -8, Happiness = -5 }, resultText = "Stayed home. Getting stiffer and lonelier. Should've gone." },
			{ text = "😬 Try once and quit", effects = { Health = 3, Happiness = -3 }, resultText = "Too hard. Embarrassing. Gave up after one class." },
			{ text = "🏆 Become the star", effects = { Health = 20, Happiness = 15, Looks = 3 }, resultText = "You're the most dedicated one there! Inspiring others! Age is just a number!" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- UNIVERSAL HEALTH EVENTS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "h_dental_emergency",
		minAge = 10, maxAge = 100,
		weight = 20, cooldown = 4,
		emoji = "🦷", title = "Tooth Pain!",
		category = "health",
		text = "OUCH! Severe tooth pain! Can't ignore this. What do you do?",
		choices = {
			{ text = "🦷 Emergency dentist NOW", effects = { Health = 10, Money = -400, Happiness = 5 }, resultText = "Fixed! The relief is incredible! Worth every penny." },
			{ text = "💊 Pain pills and wait", effects = { Health = -10, Happiness = -8 }, resultText = "Infection got worse! Now need root canal. Should've gone immediately." },
			{ text = "🍺 Try to numb it yourself", effects = { Health = -5, Happiness = -5 }, resultText = "Didn't work. Still hurts. Delayed the inevitable trip." },
			{ text = "😬 Pull it yourself", effects = { Health = -25, Happiness = -20 }, resultText = "TERRIBLE IDEA! Made everything worse. Infection, damage, hospital trip. NEVER do this!" },
		},
	},
	
	{
		id = "h_food_poisoning",
		minAge = 10, maxAge = 100,
		weight = 20, cooldown = 3,
		emoji = "🤮", title = "Food Poisoning!",
		category = "health",
		getDynamicData = function()
			local sources = {"that sketchy restaurant", "gas station sushi", "old leftovers", "undercooked chicken"}
			return { source = sources[math.random(#sources)] }
		end,
		text = "Pretty sure it was %source%. You're MISERABLE. What do you do?",
		choices = {
			{ text = "🛏️ Rest and hydrate", effects = { Health = 5, Happiness = -5 }, resultText = "Rough 24 hours but recovered. Never eating there again!" },
			{ text = "💊 Try to tough it out", effects = { Health = -10, Happiness = -12 }, resultText = "Made it last longer! Should've just rested properly." },
			{ text = "🏥 Go to ER", effects = { Health = 8, Money = -500 }, resultText = "Was dehydrated. They helped. Better safe than sorry." },
			{ text = "😤 Complain to restaurant", effects = { Happiness = 3, Money = 50 }, resultText = "They gave you a refund. Small consolation for this suffering." },
		},
	},
	
	{
		id = "h_exercise_decision",
		minAge = 15, maxAge = 80,
		weight = 25, cooldown = 3,
		emoji = "🏃", title = "Time to Exercise?",
		category = "health",
		text = "You've been thinking about getting in shape. What do you do?",
		choices = {
			{ text = "🏋️ Start a routine", effects = { Health = 12, Happiness = 10, Looks = 3 }, resultText = "Stuck with it! Feeling better every day! Best decision!" },
			{ text = "🛋️ Start tomorrow...", effects = { Health = -5, Happiness = -3 }, resultText = "Tomorrow never came. Still on the couch months later." },
			{ text = "💪 Go too hard too fast", effects = { Health = -8, Happiness = -5 }, resultText = "Injured yourself! Now can't exercise at all. Start slow next time." },
			{ text = "🚶 Just walk more", effects = { Health = 8, Happiness = 6 }, resultText = "Simple but effective! Energy up, weight down! Easy wins!" },
		},
	},
	
	{
		id = "h_sick_choice",
		minAge = 18, maxAge = 70,
		weight = 25, cooldown = 2,
		emoji = "🤧", title = "Feeling Sick",
		category = "health",
		text = "You're coming down with something. Feel awful. What do you do?",
		choices = {
			{ text = "🏠 Stay home and rest", effects = { Health = 10, Happiness = 5 }, resultText = "Good call! Recovered quickly. Body needed the rest." },
			{ text = "💼 Go to work anyway", effects = { Health = -10, Happiness = -8 }, resultText = "Got everyone else sick! Boss mad. You're worse now. Stay home when sick!" },
			{ text = "💊 Pop cold medicine and push", effects = { Health = -5, Happiness = -3 }, resultText = "Dragged on for 2 weeks instead of 3 days. Should've rested." },
			{ text = "👨‍⚕️ See a doctor", effects = { Health = 12, Money = -100 }, resultText = "Got proper treatment! Knocked it out fast. Worth the copay." },
		},
	},
}

return module
