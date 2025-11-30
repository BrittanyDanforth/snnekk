-- LifeEvents/disasters.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- DISASTERS, EXTREME WEATHER, AND ACCIDENTS
-- Not everything goes smoothly - varied outcomes with real consequences
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- EXTREME WEATHER EVENTS (Varied outcomes!)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "d_severe_storm",
		minAge = 5, maxAge = 100,
		weight = 25, cooldown = 4,
		emoji = "⛈️", title = "Severe Storm!",
		category = "family",
		getDynamicData = function()
			local storms = {
				{ type = "thunderstorm with hail", emoji = "⛈️" },
				{ type = "severe thunderstorm", emoji = "🌩️" },
				{ type = "windstorm", emoji = "💨" },
				{ type = "ice storm", emoji = "🧊" },
			}
			local chosen = storms[math.random(#storms)]
			return { stormType = chosen.type, stormEmoji = chosen.emoji }
		end,
		getDynamicEmoji = function(data) return data.stormEmoji or "⛈️" end,
		text = "A %stormType% hits your area! Power flickering, trees swaying dangerously!",
		choices = {
			{ 
				text = "🏠 Stayed safe inside", 
				effects = { Happiness = 4 }, 
				resultText = "Rode it out at home. Everything's fine! Just some scary noises."
			},
			{ 
				text = "💥 Tree fell on house!", 
				effects = { Money = -8000, Happiness = -15, Health = -5 }, 
				resultText = "Massive tree crashed through the roof! Insurance nightmare. Months of repairs."
			},
			{ 
				text = "🚗 Car damaged", 
				effects = { Money = -3000, Happiness = -10 }, 
				resultText = "Hail or debris destroyed your car. Rental while getting it fixed."
			},
			{ 
				text = "⚡ Power out for days", 
				effects = { Money = -500, Happiness = -8 }, 
				resultText = "A week without power! Lost all the food in the fridge. Miserable."
			},
		},
	},
	
	{
		id = "d_tornado_warning",
		minAge = 5, maxAge = 100,
		weight = 15, cooldown = 6,
		emoji = "🌪️", title = "Tornado Warning!",
		category = "family",
		text = "TORNADO WARNING! Sirens blaring! You need to take shelter immediately!",
		choices = {
			{ 
				text = "🏠 Made it to shelter!", 
				effects = { Happiness = 8, Health = 2 }, 
				resultText = "Basement saved you! Tornado touched down nearby. So grateful to be safe!"
			},
			{ 
				text = "💔 House destroyed", 
				effects = { Money = -50000, Happiness = -35, Health = -10 }, 
				resultText = "Direct hit. Your home is gone. Everything you owned... insurance will help but... devastating.",
				setFlag = "lost_home"
			},
			{ 
				text = "🚗 Escaped in car", 
				effects = { Happiness = -5, Health = -3 }, 
				resultText = "Drove away just in time! Terrifying experience. Your neighborhood is damaged."
			},
			{ 
				text = "😰 Minor damage", 
				effects = { Money = -5000, Happiness = -8 }, 
				resultText = "Tornado passed close. Lost fence, shingles, some windows. Could've been worse."
			},
		},
	},
	
	{
		id = "d_hurricane_season",
		minAge = 10, maxAge = 100,
		weight = 15, cooldown = 6,
		emoji = "🌀", title = "Hurricane Approaching!",
		category = "family",
		getDynamicData = function()
			local categories = {1, 2, 3, 4}
			return { category = categories[math.random(#categories)] }
		end,
		text = "Category %category% hurricane heading your way! Evacuate or shelter in place?",
		choices = {
			{ 
				text = "🚗 Evacuated safely", 
				effects = { Money = -2000, Happiness = 4 }, 
				resultText = "Got out in time. Hotel for a week. House still standing when you returned!",
				setFlag = "evacuated_hurricane"
			},
			{ 
				text = "🏠 Rode it out", 
				effects = { Happiness = -10, Health = -5 }, 
				resultText = "Terrifying night! House held but it was INTENSE. Never again."
			},
			{ 
				text = "🌊 Flooding damage", 
				effects = { Money = -30000, Happiness = -25 }, 
				resultText = "Storm surge flooded the first floor. Everything destroyed. Rebuilding begins.",
				setFlag = "home_flooded"
			},
			{ 
				text = "💪 Prepared well!", 
				effects = { Happiness = 6, Money = -500 }, 
				resultText = "Generator, supplies, boards on windows. Made it through like a pro!",
				setFlag = "storm_prepper"
			},
		},
	},
	
	{
		id = "d_wildfire_threat",
		minAge = 10, maxAge = 100,
		weight = 12, cooldown = 6,
		emoji = "🔥", title = "Wildfire Warning!",
		category = "family",
		text = "Wildfire burning near your area! Evacuation might be necessary!",
		choices = {
			{ 
				text = "🚗 Evacuated early", 
				effects = { Money = -1500, Happiness = 2 }, 
				resultText = "Got out before the roads jammed. Hotel for a few days. Home is safe!",
				setFlag = "evacuated_fire"
			},
			{ 
				text = "🏠 Home survived!", 
				effects = { Happiness = 10, Health = -3 }, 
				resultText = "Fire came within a mile! Smoke was awful. But the house made it!"
			},
			{ 
				text = "🔥 Lost everything", 
				effects = { Money = -100000, Happiness = -40, Health = -10 }, 
				resultText = "The fire took your home. Photos, memories, everything. Only insurance and starting over.",
				setFlag = "lost_home_fire"
			},
			{ 
				text = "🚒 Firefighters saved it", 
				effects = { Happiness = 8, Money = -500 }, 
				resultText = "They created firebreaks and sprayed your house. Heroes saved your home!"
			},
		},
	},
	
	{
		id = "d_flash_flood",
		minAge = 10, maxAge = 100,
		weight = 20, cooldown = 4,
		emoji = "🌊", title = "Flash Flood!",
		category = "family",
		text = "Heavy rain caused a flash flood! Water rising fast!",
		choices = {
			{ 
				text = "🏔️ Got to high ground", 
				effects = { Happiness = 4 }, 
				resultText = "Smart move! Watched the water rise from safety. Close call!"
			},
			{ 
				text = "🚗 Car swept away!", 
				effects = { Money = -15000, Happiness = -20, Health = -5 }, 
				resultText = "Tried to drive through it. NEVER drive through floods! Lost the car, barely escaped."
			},
			{ 
				text = "🏠 Basement flooded", 
				effects = { Money = -8000, Happiness = -15 }, 
				resultText = "Water rushed in. Everything stored down there is ruined. Weeks of cleanup."
			},
			{ 
				text = "🛟 Rescued by boat!", 
				effects = { Happiness = -10, Health = -3 }, 
				resultText = "Had to be rescued! Terrifying. Grateful for first responders."
			},
		},
	},
	
	{
		id = "d_blizzard",
		minAge = 5, maxAge = 100,
		weight = 20, cooldown = 4,
		emoji = "❄️", title = "Massive Blizzard!",
		category = "family",
		getDynamicData = function()
			local inches = math.random(12, 36)
			return { inches = inches }
		end,
		text = "BLIZZARD! %inches% inches of snow expected! Travel impossible!",
		choices = {
			{ 
				text = "☕ Cozy snow day!", 
				effects = { Happiness = 10 }, 
				resultText = "Stocked up on supplies! Hot cocoa, movies, watching it fall. Actually nice!",
				setFlag = "snow_lover"
			},
			{ 
				text = "🥶 Pipes froze!", 
				effects = { Money = -3000, Happiness = -12 }, 
				resultText = "Pipes burst from the cold! Water damage and no heat. Nightmare!"
			},
			{ 
				text = "🚗 Stranded!", 
				effects = { Health = -8, Happiness = -15 }, 
				resultText = "Got stuck trying to drive. Hours in the cold before rescue. Hypothermia scare."
			},
			{ 
				text = "🏠 Snowed in for days", 
				effects = { Happiness = -5, Money = -200 }, 
				resultText = "Couldn't leave the house for 4 days. Ran low on supplies. Cabin fever!"
			},
		},
	},
	
	{
		id = "d_earthquake",
		minAge = 5, maxAge = 100,
		weight = 10, cooldown = 8,
		emoji = "🏚️", title = "Earthquake!",
		category = "family",
		getDynamicData = function()
			local magnitudes = {4.5, 5.0, 5.5, 6.0, 6.5}
			return { magnitude = magnitudes[math.random(#magnitudes)] }
		end,
		text = "EARTHQUAKE! Magnitude %magnitude%! The ground is shaking violently!",
		choices = {
			{ 
				text = "🛏️ Duck and cover!", 
				effects = { Happiness = 2, Health = 2 }, 
				resultText = "Under a doorframe! Shaking stopped. Some stuff fell but everyone's okay!"
			},
			{ 
				text = "🏚️ Structural damage", 
				effects = { Money = -25000, Happiness = -20 }, 
				resultText = "House is damaged. Cracks in foundation. Engineers say it's still safe but... repairs needed."
			},
			{ 
				text = "💔 Total destruction", 
				effects = { Money = -80000, Happiness = -35, Health = -10 }, 
				resultText = "Building collapsed. You escaped but... home is gone. Red-tagged. Homeless.",
				setFlag = "lost_home_quake"
			},
			{ 
				text = "😰 Traumatic experience", 
				effects = { Happiness = -15, Health = -5 }, 
				resultText = "Minor damage but the fear... can't sleep. Every small shake triggers panic.",
				setFlag = "earthquake_anxiety"
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
		text = "Heat wave! %temperature%°F outside! Dangerously hot!",
		choices = {
			{ 
				text = "❄️ AC working great!", 
				effects = { Happiness = 4, Money = -200 }, 
				resultText = "Stayed cool inside. Electric bill will be brutal but alive!",
			},
			{ 
				text = "💀 AC broke down!", 
				effects = { Health = -10, Happiness = -15, Money = -1500 }, 
				resultText = "AC died on the hottest day! Heat exhaustion. Emergency repair costs."
			},
			{ 
				text = "🏊 Pool/beach day!", 
				effects = { Happiness = 8, Health = 2 }, 
				resultText = "Found water! Beat the heat! Actually fun despite the danger."
			},
			{ 
				text = "🥵 Heatstroke scare", 
				effects = { Health = -20, Happiness = -12 }, 
				resultText = "Got overheated. Dizzy, nauseous. Almost needed hospital. Stay hydrated!"
			},
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- ACCIDENTS AND EMERGENCIES
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "d_car_accident",
		minAge = 16, maxAge = 85,
		weight = 20, cooldown = 4,
		emoji = "🚗", title = "Car Accident!",
		category = "family",
		getDynamicData = function()
			local fault = {"your fault", "other driver's fault", "weather-related", "unavoidable"}
			return { fault = fault[math.random(#fault)] }
		end,
		text = "Car accident! It was %fault%.",
		choices = {
			{ 
				text = "🙏 Everyone's okay", 
				effects = { Happiness = 4, Money = -500 }, 
				resultText = "Just car damage. Insurance handled it. Lucky escape!"
			},
			{ 
				text = "🤕 Minor injuries", 
				effects = { Health = -10, Money = -2000, Happiness = -8 }, 
				resultText = "Whiplash, bruises. Could've been worse. Healing."
			},
			{ 
				text = "🏥 Serious injuries", 
				effects = { Health = -25, Money = -15000, Happiness = -20 }, 
				resultText = "Hospitalized. Long recovery ahead. Life-changing moment."
			},
			{ 
				text = "⚖️ Lawsuit incoming", 
				effects = { Money = -5000, Happiness = -15 }, 
				resultText = "Other party suing. Lawyers. Stress. This will drag on."
			},
		},
	},
	
	{
		id = "d_house_fire",
		minAge = 10, maxAge = 100,
		weight = 10, cooldown = 8,
		emoji = "🔥", title = "House Fire!",
		category = "family",
		getDynamicData = function()
			local causes = {"electrical", "kitchen accident", "candle", "heater malfunction", "unknown"}
			return { cause = causes[math.random(#causes)] }
		end,
		text = "FIRE! Your home is on fire! Cause: %cause%!",
		choices = {
			{ 
				text = "🚒 Put out quickly!", 
				effects = { Money = -5000, Happiness = -10 }, 
				resultText = "Fire department came fast! Kitchen damaged but house saved!"
			},
			{ 
				text = "🐕 Rescued pets first!", 
				effects = { Happiness = 4, Health = -5 }, 
				resultText = "Got the pets out! Some smoke inhalation but everyone's alive!"
			},
			{ 
				text = "🔥 Major damage", 
				effects = { Money = -40000, Happiness = -25 }, 
				resultText = "Half the house is destroyed. Months of rebuilding. Everything in storage."
			},
			{ 
				text = "💔 Total loss", 
				effects = { Money = -80000, Happiness = -35, Health = -10 }, 
				resultText = "It's all gone. Standing there watching it burn... nothing left.",
				setFlag = "lost_home_fire"
			},
		},
	},
	
	{
		id = "d_medical_emergency",
		minAge = 20, maxAge = 100,
		weight = 15, cooldown = 5,
		emoji = "🚑", title = "Medical Emergency!",
		category = "health",
		getDynamicData = function()
			local emergencies = {"severe allergic reaction", "chest pains", "stroke symptoms", "sudden collapse", "appendicitis"}
			return { emergency = emergencies[math.random(#emergencies)] }
		end,
		text = "Medical emergency! %emergency%! Calling 911!",
		choices = {
			{ 
				text = "🏥 Saved by quick action!", 
				effects = { Health = 5, Money = -3000, Happiness = 8 }, 
				resultText = "Got help fast! Doctors said timing saved you. Grateful to be alive!",
				setFlag = "near_death_experience"
			},
			{ 
				text = "💊 Long recovery ahead", 
				effects = { Health = -15, Money = -15000, Happiness = -10 }, 
				resultText = "Survived but it was serious. Months of recovery. Life changed."
			},
			{ 
				text = "😌 False alarm mostly", 
				effects = { Health = 2, Money = -1000, Happiness = -2 }, 
				resultText = "Scary but not as serious as feared. Still, wake-up call!"
			},
			{ 
				text = "💔 Critical condition", 
				effects = { Health = -30, Money = -50000, Happiness = -25 }, 
				resultText = "Touch and go. ICU. Family worried sick. But you pulled through.",
				setFlag = "survived_critical"
			},
		},
	},
	
	{
		id = "d_robbery",
		minAge = 16, maxAge = 85,
		weight = 12, cooldown = 5,
		emoji = "🔫", title = "Robbery!",
		category = "social",
		getDynamicData = function()
			local locations = {"on the street", "at an ATM", "in a parking lot", "walking home"}
			return { location = locations[math.random(#locations)] }
		end,
		text = "You're being robbed %location%! Someone demands your valuables!",
		choices = {
			{ 
				text = "💰 Gave them everything", 
				effects = { Money = -500, Happiness = -10 }, 
				resultText = "Handed over wallet and phone. Lost money but stayed safe. Stuff can be replaced."
			},
			{ 
				text = "🏃 Ran away!", 
				effects = { Happiness = -5, Health = 2 }, 
				resultText = "Bolted and escaped! Heart pounding. Never been so scared. But safe!"
			},
			{ 
				text = "💪 Fought back", 
				effects = { Health = -15, Happiness = -8 }, 
				resultText = "Got hurt fighting them off. They ran but... hospital trip. Not worth it."
			},
			{ 
				text = "📞 Witness called 911", 
				effects = { Happiness = 6 }, 
				resultText = "Someone nearby called cops who arrived fast! Robber caught! Faith restored!"
			},
		},
	},
	
	{
		id = "d_burglary",
		minAge = 18, maxAge = 100,
		weight = 15, cooldown = 6,
		emoji = "🏠", title = "Home Burglarized!",
		category = "family",
		text = "You came home to find your house broken into! Someone was here!",
		choices = {
			{ 
				text = "💻 Electronics stolen", 
				effects = { Money = -5000, Happiness = -15 }, 
				resultText = "TV, laptop, game systems - all gone. Violation of your space. Angry and upset."
			},
			{ 
				text = "💍 Valuables gone", 
				effects = { Money = -10000, Happiness = -20 }, 
				resultText = "Jewelry, cash, irreplaceable items. Insurance won't cover sentimental value."
			},
			{ 
				text = "🔒 Security system helped!", 
				effects = { Happiness = 4, Money = -500 }, 
				resultText = "Alarm scared them off! Minor loss. Getting better security now.",
				setFlag = "has_security"
			},
			{ 
				text = "🐕 Dog scared them off!", 
				effects = { Happiness = 6 }, 
				resultText = "Good boy/girl! Your dog scared the burglar away! Treats for them!",
				requiresFlag = "has_pet"
			},
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- AFTERMATH AND RECOVERY EVENTS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "d_insurance_claim",
		minAge = 18, maxAge = 100,
		weight = 20, cooldown = 4,
		emoji = "📋", title = "Insurance Claim Battle",
		category = "family",
		text = "Filed an insurance claim after the disaster. Now the waiting game...",
		choices = {
			{ 
				text = "💰 Full coverage!", 
				effects = { Money = 30000, Happiness = 15 }, 
				resultText = "Insurance came through! Full payment! Can rebuild and recover!"
			},
			{ 
				text = "📋 Partial payment", 
				effects = { Money = 10000, Happiness = -5 }, 
				resultText = "They found every loophole. Got some money but not enough. Frustrating."
			},
			{ 
				text = "❌ Claim denied!", 
				effects = { Happiness = -20 }, 
				resultText = "DENIED! Fine print exclusions. Fighting it but... might need a lawyer."
			},
			{ 
				text = "⚖️ Had to sue them", 
				effects = { Money = 20000, Happiness = -8 }, 
				resultText = "Lawyer fought and won! Got paid but what a battle. Insurance companies..."
			},
		},
	},
	
	{
		id = "d_community_help",
		minAge = 10, maxAge = 100,
		weight = 15, cooldown = 5,
		emoji = "❤️", title = "Community Support",
		category = "social",
		text = "After the disaster, your community rallied to help!",
		choices = {
			{ 
				text = "🤝 Neighbors incredible", 
				effects = { Happiness = 15 }, 
				resultText = "People you barely knew showed up to help. Food, shelter, supplies. Humanity is good.",
				setFlag = "community_helped"
			},
			{ 
				text = "💵 GoFundMe success", 
				effects = { Happiness = 12, Money = 10000 }, 
				resultText = "Friends and strangers donated! Overwhelmed by the generosity!"
			},
			{ 
				text = "🏠 Temporary housing", 
				effects = { Happiness = 8, Money = -1000 }, 
				resultText = "Church/community center set up shelter. Grateful for the roof."
			},
			{ 
				text = "💔 Felt alone", 
				effects = { Happiness = -10 }, 
				resultText = "No one came. Had to figure it out alone. Who do you have in your corner?"
			},
		},
	},
	
	{
		id = "d_ptsd_aftermath",
		minAge = 15, maxAge = 100,
		weight = 15, cooldown = 6,
		emoji = "😰", title = "Trauma Response",
		category = "health",
		text = "After what happened, you're struggling with trauma. The memories won't fade.",
		choices = {
			{ 
				text = "💬 Got therapy", 
				effects = { Health = 8, Happiness = 10, Money = -2000 }, 
				resultText = "Professional help is making a difference. Processing the trauma. Healing.",
				setFlag = "in_therapy"
			},
			{ 
				text = "👨‍👩‍👧 Family support", 
				effects = { Happiness = 8, Health = 5 }, 
				resultText = "Leaning on loved ones. Not alone in this. Slowly getting better."
			},
			{ 
				text = "😔 Struggling hard", 
				effects = { Happiness = -15, Health = -8 }, 
				resultText = "Nightmares. Anxiety. Can't function normally. Need to seek help.",
				setFlag = "trauma_struggling"
			},
			{ 
				text = "💪 Building resilience", 
				effects = { Happiness = 6, Smarts = 5 }, 
				resultText = "Using this to grow stronger. What doesn't kill you... taking control.",
				setFlag = "resilient"
			},
		},
	},
	
	{
		id = "d_close_call",
		minAge = 10, maxAge = 100,
		weight = 20, cooldown = 3,
		emoji = "😮", title = "Close Call!",
		category = "social",
		getDynamicData = function()
			local calls = {
				"almost got hit by a car",
				"nearly fell from a height",
				"almost choked on food",
				"barely avoided a falling object",
				"slipped but caught yourself",
			}
			return { closecall = calls[math.random(#calls)] }
		end,
		text = "Whoa! You %closecall%! That was WAY too close!",
		choices = {
			{ 
				text = "😰 Heart still pounding", 
				effects = { Happiness = -5 }, 
				resultText = "So close to disaster! Can't stop thinking about what almost happened."
			},
			{ 
				text = "🙏 Grateful to be alive", 
				effects = { Happiness = 10, Smarts = 2 }, 
				resultText = "Life flashed before your eyes. Appreciating every moment now!"
			},
			{ 
				text = "😂 Laughed it off", 
				effects = { Happiness = 4 }, 
				resultText = "Once the fear passed... actually kind of funny? Wild story to tell!"
			},
			{ 
				text = "⚠️ More careful now", 
				effects = { Smarts = 5, Happiness = 2 }, 
				resultText = "Wake-up call! Being more aware and careful. Safety first.",
				setFlag = "safety_conscious"
			},
		},
	},
}

return module
