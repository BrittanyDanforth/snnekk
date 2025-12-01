-- LifeEvents/disasters.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- DISASTERS, EXTREME WEATHER, AND ACCIDENTS
-- BitLife-style: Player picks ACTIONS, game decides OUTCOMES
-- ═══════════════════════════════════════════════════════════════════════════════

-- LOCAL HELPER FUNCTIONS (no external dependencies)
local FIRST_NAMES = {"Alex", "Jordan", "Taylor", "Casey", "Morgan", "Riley", "Jamie", "Cameron", "Quinn", "Avery", "Parker", "Skyler", "Dakota", "Reese", "Finley", "Sage", "Rowan", "Charlie", "Emerson", "Hayden"}

local function randomFirstName()
	return FIRST_NAMES[math.random(#FIRST_NAMES)]
end

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- EXTREME WEATHER EVENTS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "d_severe_storm",
		minAge = 5, maxAge = 100,
		weight = 25, cooldown = 4,
		emoji = "⛈️", title = "Severe Storm Warning!",
		category = "family",
		text = "A severe storm is approaching! Thunder rumbling, sky turning dark. What do you do?",
		choices = {
			{ 
				text = "🏠 Stay inside and wait it out", 
				effects = { Happiness = 2 }, 
				resultText = "Smart choice! Storm passed without incident. A bit scary but safe."
			},
			{ 
				text = "🚗 Try to drive home quickly", 
				effects = { Money = -3000, Happiness = -12, Health = -5 }, 
				resultText = "Bad idea! A tree fell on your car while driving. You're okay but the car is totaled."
			},
			{ 
				text = "📱 Keep watching TV/phone", 
				effects = { Happiness = -8, Money = -500 }, 
				resultText = "Should've paid attention! Power surge fried your electronics when lightning hit nearby."
			},
			{ 
				text = "🔦 Prepare emergency supplies", 
				effects = { Happiness = 5, Smarts = 3 }, 
				resultText = "Good thinking! Power went out but you were ready with flashlights and food."
			},
		},
	},
	
	{
		id = "d_tornado_warning",
		minAge = 5, maxAge = 100,
		weight = 15, cooldown = 6,
		emoji = "🌪️", title = "TORNADO WARNING!",
		category = "family",
		text = "SIRENS BLARING! A tornado has been spotted! You need to act NOW!",
		choices = {
			{ 
				text = "🏠 Get to the basement!", 
				effects = { Happiness = 8 }, 
				resultText = "You made it! Tornado touched down nearby but you were safe underground. Close call!"
			},
			{ 
				text = "📸 Try to film it", 
				effects = { Health = -25, Happiness = -20, Money = -5000 }, 
				resultText = "STUPID DECISION! Flying debris hit you. Hospitalized with serious injuries. Not worth the video."
			},
			{ 
				text = "🚗 Try to outrun it", 
				effects = { Health = -10, Money = -15000, Happiness = -15 }, 
				resultText = "Terrible choice! Car flipped by the wind. You survived but barely. Car is gone."
			},
			{ 
				text = "🛁 Get in bathtub with mattress", 
				effects = { Happiness = 5, Health = -2 }, 
				resultText = "No basement but you improvised! House damaged but you're alive!"
			},
		},
	},
	
	{
		id = "d_hurricane_approaching",
		minAge = 10, maxAge = 100,
		weight = 15, cooldown = 6,
		emoji = "🌀", title = "Hurricane Approaching!",
		category = "family",
		getDynamicData = function()
			local categories = {1, 2, 3, 4}
			return { category = categories[math.random(#categories)] }
		end,
		text = "Category %category% hurricane making landfall tomorrow! Evacuation orders issued. What do you do?",
		choices = {
			{ 
				text = "🚗 Evacuate now", 
				effects = { Money = -2000, Happiness = 5 }, 
				resultText = "You left early and avoided the chaos. Hotel stay was expensive but home survived. Good call!"
			},
			{ 
				text = "🏠 Ride it out at home", 
				effects = { Health = -15, Happiness = -20, Money = -25000 }, 
				resultText = "BAD CHOICE! Storm surge flooded your house. Trapped on the roof until rescue. Lost almost everything."
			},
			{ 
				text = "🔨 Board up windows and stay", 
				effects = { Happiness = -10, Health = -5 }, 
				resultText = "The preparation helped but it was TERRIFYING. Minor damage. You got lucky."
			},
			{ 
				text = "🏃 Wait too long to leave", 
				effects = { Health = -5, Money = -500, Happiness = -15 }, 
				resultText = "Roads jammed! Stuck in traffic during the storm. Terrifying experience but survived."
			},
		},
	},
	
	{
		id = "d_wildfire_threat",
		minAge = 10, maxAge = 100,
		weight = 12, cooldown = 6,
		emoji = "🔥", title = "Wildfire Approaching!",
		category = "family",
		text = "Wildfire is burning toward your area! Smoke visible in the sky. What do you do?",
		choices = {
			{ 
				text = "🚗 Evacuate immediately", 
				effects = { Money = -1500, Happiness = 8 }, 
				resultText = "Left early with important documents. Home survived! The firefighters saved your neighborhood."
			},
			{ 
				text = "💧 Stay and defend with hose", 
				effects = { Health = -20, Money = -50000, Happiness = -30 }, 
				resultText = "Foolish! Fire moved too fast. Had to flee with nothing. Lost your home. You barely escaped alive."
			},
			{ 
				text = "📦 Pack valuables then leave", 
				effects = { Money = -1000, Happiness = 3 }, 
				resultText = "Took time to grab photos and documents. Made it out. House had some damage but standing."
			},
			{ 
				text = "🤷 Ignore the warnings", 
				effects = { Health = -30, Money = -80000, Happiness = -35 }, 
				resultText = "CATASTROPHIC MISTAKE! Surrounded by fire. Emergency helicopter rescue. Lost everything. Nearly died."
			},
		},
	},
	
	{
		id = "d_flash_flood",
		minAge = 10, maxAge = 100,
		weight = 20, cooldown = 4,
		emoji = "🌊", title = "Flash Flood!",
		category = "family",
		text = "Water rising FAST! Streets turning into rivers! What do you do?",
		choices = {
			{ 
				text = "🏔️ Get to higher ground", 
				effects = { Happiness = 5 }, 
				resultText = "Smart move! Watched the flood from safety. Your car got flooded but you're alive!"
			},
			{ 
				text = "🚗 Drive through the water", 
				effects = { Health = -20, Money = -20000, Happiness = -25 }, 
				resultText = "NEVER DO THIS! Car swept away. You almost drowned. Rescued by emergency services. Car is gone."
			},
			{ 
				text = "🏠 Go to second floor", 
				effects = { Happiness = -10, Money = -15000 }, 
				resultText = "First floor flooded. Safe upstairs but everything below is destroyed."
			},
			{ 
				text = "🆘 Call for help", 
				effects = { Happiness = -5, Health = -3 }, 
				resultText = "Rescue boat came! Scary but you're safe. Home has water damage but you're okay."
			},
		},
	},
	
	{
		id = "d_blizzard",
		minAge = 5, maxAge = 100,
		weight = 20, cooldown = 4,
		emoji = "❄️", title = "Blizzard Warning!",
		category = "family",
		getDynamicData = function()
			local inches = math.random(18, 36)
			return { inches = inches }
		end,
		text = "%inches% inches of snow expected! White-out conditions! What do you do?",
		choices = {
			{ 
				text = "🏠 Stock up and stay home", 
				effects = { Happiness = 8, Money = -100 }, 
				resultText = "Cozy inside with food and warmth! Actually kind of nice watching it fall."
			},
			{ 
				text = "🚗 Try to drive somewhere", 
				effects = { Health = -15, Money = -2000, Happiness = -15 }, 
				resultText = "TERRIBLE IDEA! Car went off road. Stranded for hours. Frostbite on your fingers. Tow truck cost a fortune."
			},
			{ 
				text = "😤 Go to work anyway", 
				effects = { Health = -8, Happiness = -10 }, 
				resultText = "Got stuck at work for 2 days! Sleeping on office floor. Boss didn't even appreciate it."
			},
			{ 
				text = "🔥 Check the heating", 
				effects = { Happiness = 5, Smarts = 3 }, 
				resultText = "Good thinking! Found an issue before it became a problem. Warm and safe!"
			},
		},
	},
	
	{
		id = "d_earthquake",
		minAge = 5, maxAge = 100,
		weight = 10, cooldown = 8,
		emoji = "🏚️", title = "EARTHQUAKE!",
		category = "family",
		getDynamicData = function()
			local magnitudes = {4.5, 5.5, 6.0, 6.5}
			return { magnitude = magnitudes[math.random(#magnitudes)] }
		end,
		text = "The ground is SHAKING! Magnitude %magnitude% earthquake! What do you do?",
		choices = {
			{ 
				text = "🛏️ Drop, cover, and hold", 
				effects = { Happiness = 5, Health = 2 }, 
				resultText = "Textbook response! You got under a sturdy table. Some things fell but you're uninjured!"
			},
			{ 
				text = "🏃 Run outside", 
				effects = { Health = -15, Happiness = -10 }, 
				resultText = "Bad move! A brick from the building hit you on the way out. Injured but alive."
			},
			{ 
				text = "🚪 Stand in doorway", 
				effects = { Health = -5, Happiness = -3 }, 
				resultText = "Old advice, not the best. Door swung and hit you. Minor injuries."
			},
			{ 
				text = "😱 Freeze and panic", 
				effects = { Health = -8, Happiness = -12 }, 
				resultText = "Stuff fell on you while frozen in fear. Nothing serious but shaken up badly."
			},
		},
	},
	
	{
		id = "d_heat_wave",
		minAge = 5, maxAge = 100,
		weight = 25, cooldown = 3,
		emoji = "🌡️", title = "Extreme Heat Wave!",
		category = "family",
		getDynamicData = function()
			local temp = math.random(105, 118)
			return { temperature = temp }
		end,
		text = "%temperature%°F outside! Dangerous heat advisory in effect. What do you do?",
		choices = {
			{ 
				text = "🏠 Stay inside with AC", 
				effects = { Happiness = 4, Money = -150 }, 
				resultText = "Cranked the AC! Electric bill will hurt but you survived the heat wave safely."
			},
			{ 
				text = "🏃 Go for a run anyway", 
				effects = { Health = -25, Happiness = -15 }, 
				resultText = "HEATSTROKE! Collapsed during the run. Ambulance called. You could have died!"
			},
			{ 
				text = "🏊 Go to the pool/beach", 
				effects = { Happiness = 10, Health = 3 }, 
				resultText = "Perfect choice! Stayed cool in the water. Actually a great day!"
			},
			{ 
				text = "🛠️ Work outside anyway", 
				effects = { Health = -15, Money = 100, Happiness = -8 }, 
				resultText = "Heat exhaustion! Dizzy, nauseous. Had to stop. Not worth the money."
			},
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- ACCIDENTS - Player actions lead to outcomes
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "d_car_accident_oncoming",
		minAge = 16, maxAge = 85,
		weight = 20, cooldown = 4,
		emoji = "🚗", title = "Accident About to Happen!",
		category = "family",
		text = "A car is swerving toward you! Split second to react!",
		choices = {
			{ 
				text = "🔀 Swerve to avoid", 
				effects = { Money = -1000, Happiness = -5 }, 
				resultText = "You avoided them but hit a guardrail. Car damaged but you're okay!"
			},
			{ 
				text = "🛑 Slam the brakes", 
				effects = { Health = -10, Money = -3000, Happiness = -10 }, 
				resultText = "Couldn't stop in time! Collision. Whiplash and car damage. Other driver's fault - insurance fight ahead."
			},
			{ 
				text = "📯 Honk and hope", 
				effects = { Health = -20, Money = -15000, Happiness = -20 }, 
				resultText = "They didn't react! Major collision. You're injured, car totaled. Months of recovery ahead."
			},
			{ 
				text = "🚗 Accelerate through", 
				effects = { Happiness = 5, Health = 2 }, 
				resultText = "Quick thinking! Punched it and barely got past them. Heart pounding but safe!"
			},
		},
	},
	
	{
		id = "d_house_fire_starts",
		minAge = 10, maxAge = 100,
		weight = 10, cooldown = 8,
		emoji = "🔥", title = "Fire in the House!",
		category = "family",
		text = "You smell smoke! There's a fire starting in your home! What do you do?",
		choices = {
			{ 
				text = "🚪 Get everyone out NOW", 
				effects = { Happiness = 5, Money = -10000 }, 
				resultText = "Everyone escaped! Fire department arrived. Kitchen destroyed but house saved. Insurance covers it."
			},
			{ 
				text = "🧯 Try to put it out", 
				effects = { Health = -5, Money = -3000, Happiness = 2 }, 
				resultText = "Grabbed the extinguisher! Fire was small enough - you stopped it! Minor damage only."
			},
			{ 
				text = "📦 Save valuables first", 
				effects = { Health = -15, Money = -40000, Happiness = -25 }, 
				resultText = "Wasted critical time! Fire spread. You got out but house is destroyed. Stuff isn't worth your life!"
			},
			{ 
				text = "🐕 Find the pets", 
				effects = { Health = -10, Happiness = 10 }, 
				resultText = "Found them and got out! Smoke inhalation but everyone alive - pets included! Worth it."
			},
		},
	},
	
	{
		id = "d_medical_emergency_witness",
		minAge = 15, maxAge = 100,
		weight = 15, cooldown = 5,
		emoji = "🚑", title = "Someone Collapsed!",
		category = "health",
		text = "Someone just collapsed in front of you! They're not responsive! What do you do?",
		choices = {
			{ 
				text = "📞 Call 911 immediately", 
				effects = { Happiness = 10, Smarts = 3 }, 
				resultText = "Help arrived quickly! Your fast action may have saved their life. Real hero moment!"
			},
			{ 
				text = "💓 Start CPR", 
				effects = { Happiness = 15, Health = -2 }, 
				resultText = "You knew CPR! Kept them going until paramedics arrived. They survived because of YOU!"
			},
			{ 
				text = "😨 Freeze up", 
				effects = { Happiness = -15, Health = -3 }, 
				resultText = "Couldn't move. Someone else called 911. The guilt of freezing haunts you."
			},
			{ 
				text = "👀 Look for others to help", 
				effects = { Happiness = 5 }, 
				resultText = "Found a nurse nearby who took over! They handled it. Good thinking finding help!"
			},
		},
	},
	
	{
		id = "d_robbery_confrontation",
		minAge = 16, maxAge = 70,
		weight = 12, cooldown = 5,
		emoji = "🔫", title = "You're Being Robbed!",
		category = "social",
		text = "Someone is demanding your wallet and phone! They look serious! What do you do?",
		choices = {
			{ 
				text = "💰 Hand everything over", 
				effects = { Money = -500, Happiness = -8 }, 
				resultText = "Smart. Gave them what they wanted and they ran. Stuff can be replaced, you can't."
			},
			{ 
				text = "👊 Fight back", 
				effects = { Health = -25, Money = -200, Happiness = -15 }, 
				resultText = "They had a weapon! You got hurt badly. Hospital trip. Not worth it."
			},
			{ 
				text = "🏃 RUN!", 
				effects = { Happiness = 5, Health = 2 }, 
				resultText = "You bolted and escaped! Heart racing but kept everything and you're safe!"
			},
			{ 
				text = "😱 Scream for help", 
				effects = { Happiness = 3 }, 
				resultText = "People came running! The robber fled. Witnesses helped identify them to police."
			},
		},
	},
	
	{
		id = "d_home_intruder",
		minAge = 18, maxAge = 100,
		weight = 10, cooldown = 6,
		emoji = "🏠", title = "Intruder in Your Home!",
		category = "family",
		text = "You hear someone breaking in downstairs! You're home! What do you do?",
		choices = {
			{ 
				text = "📞 Call 911 and hide", 
				effects = { Happiness = 5, Smarts = 3 }, 
				resultText = "Stayed quiet, cops came fast. Intruder fled when they heard sirens. You're safe!"
			},
			{ 
				text = "⚾ Grab something to defend", 
				effects = { Health = -10, Happiness = -5 }, 
				resultText = "Confronted them! Got into a fight. They ran but you got hurt. Scary."
			},
			{ 
				text = "🪟 Escape out window", 
				effects = { Happiness = 8, Health = -2 }, 
				resultText = "Got out safely! Minor scrapes from the window but called cops from neighbor's house."
			},
			{ 
				text = "📢 Make lots of noise", 
				effects = { Happiness = 3 }, 
				resultText = "Started yelling and turning on lights! They fled immediately. Didn't want confrontation!"
			},
		},
	},
	
	{
		id = "d_choking",
		minAge = 10, maxAge = 100,
		weight = 15, cooldown = 5,
		emoji = "😨", title = "Someone's Choking!",
		category = "health",
		text = "Someone at your table is choking! They can't breathe! What do you do?",
		choices = {
			{ 
				text = "💪 Heimlich maneuver", 
				effects = { Happiness = 15, Smarts = 3 }, 
				resultText = "You knew what to do! Dislodged the food. They're okay! You saved their life!"
			},
			{ 
				text = "😱 Panic and yell for help", 
				effects = { Happiness = -5, Health = -2 }, 
				resultText = "Someone else helped while you panicked. They're okay but you feel useless."
			},
			{ 
				text = "🥤 Give them water", 
				effects = { Happiness = -10, Smarts = -3 }, 
				resultText = "WRONG! That made it worse! Luckily someone else did Heimlich. Learn first aid!"
			},
			{ 
				text = "👋 Back slaps", 
				effects = { Happiness = 10, Health = 2 }, 
				resultText = "Five firm back blows worked! Food came out. Quick thinking!"
			},
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- AFTERMATH EVENTS - Still action-based
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "d_insurance_battle",
		minAge = 18, maxAge = 100,
		weight = 20, cooldown = 4,
		emoji = "📋", title = "Insurance Claim Time",
		category = "family",
		requiresFlag = "lost_home",
		text = "Insurance company is giving you the runaround on your claim. What do you do?",
		choices = {
			{ 
				text = "📞 Keep calling and pushing", 
				effects = { Happiness = 8, Money = 25000 }, 
				resultText = "Persistence paid off! After 47 calls, they approved full coverage!"
			},
			{ 
				text = "⚖️ Hire a lawyer", 
				effects = { Money = 35000, Happiness = 5 }, 
				resultText = "Lawyer got you more than expected! Their fee was worth it."
			},
			{ 
				text = "😔 Accept their low offer", 
				effects = { Money = 10000, Happiness = -10 }, 
				resultText = "Took the lowball. Not enough but you were tired of fighting."
			},
			{ 
				text = "📺 Go to local news", 
				effects = { Money = 40000, Happiness = 12 }, 
				resultText = "Story went viral! Insurance paid up FAST to avoid PR nightmare. Power of media!"
			},
		},
	},
	
	{
		id = "d_trauma_aftermath",
		minAge = 15, maxAge = 100,
		weight = 15, cooldown = 6,
		emoji = "😰", title = "Dealing with Trauma",
		category = "health",
		text = "After everything that happened, you're struggling. Nightmares, anxiety, flashbacks. What do you do?",
		choices = {
			{ 
				text = "💬 See a therapist", 
				effects = { Health = 12, Happiness = 10, Money = -1500 }, 
				resultText = "Professional help is working. Processing the trauma. Slowly healing."
			},
			{ 
				text = "🍺 Drink to forget", 
				effects = { Health = -15, Happiness = -10, Money = -500 }, 
				resultText = "Made everything worse. Developing a problem now. Need real help."
			},
			{ 
				text = "💪 Push through alone", 
				effects = { Health = -5, Happiness = -8 }, 
				resultText = "Struggling. Some days okay, some days terrible. Should probably talk to someone."
			},
			{ 
				text = "👨‍👩‍👧 Lean on family", 
				effects = { Happiness = 8, Health = 5 }, 
				resultText = "Family support is helping. Not alone in this. Healing together."
			},
		},
	},
	
	{
		id = "d_rebuild_decision",
		minAge = 25, maxAge = 100,
		weight = 12, cooldown = 8,
		emoji = "🏗️", title = "Rebuilding After Disaster",
		category = "family",
		requiresFlag = "lost_home",
		text = "Your home was destroyed. Time to decide what's next. What do you do?",
		choices = {
			{ 
				text = "🏗️ Rebuild on same land", 
				effects = { Money = -50000, Happiness = 10 }, 
				resultText = "Rebuilding. It'll be better than before. Making this YOUR home again."
			},
			{ 
				text = "🚚 Move somewhere new", 
				effects = { Money = -20000, Happiness = 8 }, 
				resultText = "Fresh start in a new place. Maybe that disaster was a sign to change."
			},
			{ 
				text = "👨‍👩‍👧 Move in with family", 
				effects = { Happiness = 5, Money = 10000 }, 
				resultText = "Family took you in. Saving money while figuring out next steps."
			},
			{ 
				text = "🏢 Rent for now", 
				effects = { Happiness = 3, Money = -5000 }, 
				resultText = "Temporary apartment while you decide. No rush. Take your time."
			},
		},
	},
}

return module
