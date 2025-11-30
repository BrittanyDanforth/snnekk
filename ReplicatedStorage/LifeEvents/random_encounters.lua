-- LifeEvents/random_encounters.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- RANDOM ENCOUNTER EVENTS
-- Life doesn't always go your way - varied outcomes, risks, and surprises
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- STRAY ANIMAL ENCOUNTERS (With realistic varied outcomes!)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_stray_cat_encounter",
		minAge = 8, maxAge = 70,
		weight = 25, cooldown = 3,
		emoji = "🐱", title = "Stray Cat!",
		category = "social",
		getDynamicData = function()
			local conditions = {"skinny and hungry", "friendly but dirty", "hissing and scared", "injured", "with kittens"}
			return { condition = conditions[math.random(#conditions)] }
		end,
		text = "You found a stray cat that looks %condition% in your neighborhood.",
		choices = {
			{ 
				text = "🏥 Take it to a shelter", 
				effects = { Happiness = 5 }, 
				resultText = "The shelter thanked you. The cat will get care.",
				setFlag = "helped_animal"
			},
			{ 
				text = "🏠 Try to adopt it", 
				effects = { Happiness = 10 }, 
				resultText = "You adopted the stray! Meet your new furry friend!",
				setFlag = "has_pet"
			},
			{ 
				text = "🍖 Feed it and let it go", 
				effects = { Happiness = 3 }, 
				resultText = "You gave it some food. It might come back tomorrow."
			},
			{ 
				text = "🤲 Try to pet it",
				effects = { Happiness = -5, Health = -8 },
				resultText = "OUCH! The scared cat scratched you badly! Should've been more careful."
			},
		},
	},
	
	{
		id = "m_stray_dog_encounter",
		minAge = 8, maxAge = 70,
		weight = 25, cooldown = 3,
		emoji = "🐕", title = "Stray Dog!",
		category = "social",
		getDynamicData = function()
			local conditions = {"friendly and waggy", "nervous and growling", "limping", "covered in mud", "wearing a broken collar"}
			return { condition = conditions[math.random(#conditions)] }
		end,
		text = "A stray dog approaches you. It looks %condition%.",
		choices = {
			{ 
				text = "🏥 Call animal control", 
				effects = { Happiness = 2, Smarts = 2 }, 
				resultText = "Animal control came and took the dog. Safe for everyone."
			},
			{ 
				text = "🏠 Take it home", 
				effects = { Happiness = 12 }, 
				resultText = "You've got a new best friend! Time for vet visit and supplies.",
				setFlag = "has_pet"
			},
			{ 
				text = "🔍 Check for owner",
				effects = { Happiness = 8, Smarts = 3 },
				resultText = "Found the owner via the chip! They were so grateful!"
			},
			{ 
				text = "🤲 Approach carefully",
				effects = { Health = -15, Happiness = -10 },
				resultText = "The dog bit you! It was more scared than you thought. Hospital trip needed."
			},
		},
	},
	
	{
		id = "m_wild_animal_encounter",
		minAge = 10, maxAge = 70,
		weight = 15, cooldown = 5,
		emoji = "🦊", title = "Wild Animal!",
		category = "social",
		getDynamicData = function()
			local animals = {
				{ type = "raccoon", emoji = "🦝" },
				{ type = "fox", emoji = "🦊" },
				{ type = "deer", emoji = "🦌" },
				{ type = "skunk", emoji = "🦨" },
				{ type = "snake", emoji = "🐍" },
			}
			local chosen = animals[math.random(#animals)]
			return { animal = chosen.type, animalEmoji = chosen.emoji }
		end,
		getDynamicEmoji = function(data)
			return data.animalEmoji or "🦊"
		end,
		text = "You encountered a %animal% in an unexpected place!",
		choices = {
			{ 
				text = "📸 Take a photo from distance", 
				effects = { Happiness = 8, Smarts = 2 }, 
				resultText = "Great shot! Shared on social media. Nature is amazing!"
			},
			{ 
				text = "🚶 Slowly back away", 
				effects = { Happiness = 2, Smarts = 4 }, 
				resultText = "Smart move. You left the animal alone and it wandered off."
			},
			{ 
				text = "🤲 Try to get closer",
				effects = { Health = -12, Happiness = -8 },
				resultText = "BAD IDEA. The animal attacked in self-defense. You're hurt!"
			},
			{ 
				text = "😱 Run away screaming",
				effects = { Happiness = -3, Health = -2 },
				resultText = "You tripped while running! Scraped knee and bruised ego."
			},
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- STRANGER ENCOUNTERS (Mixed outcomes)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_stranger_needs_help",
		minAge = 16, maxAge = 70,
		weight = 30, cooldown = 2,
		emoji = "🆘", title = "Stranger Asking for Help",
		category = "social",
		getDynamicData = function()
			local situations = {"car broke down", "phone died and needs to call someone", "needs directions", "dropped groceries everywhere", "locked out of their car"}
			return { situation = situations[math.random(#situations)] }
		end,
		text = "A stranger approaches you - their %situation%. They're asking for help.",
		choices = {
			{ 
				text = "🤝 Help them out", 
				effects = { Happiness = 8, Smarts = 2 }, 
				resultText = "You helped and they were very grateful! Good karma!",
				setFlag = "helpful"
			},
			{ 
				text = "🙅 Too busy, sorry",
				effects = { Happiness = -2 },
				resultText = "You walked away. Hope someone else helped them."
			},
			{ 
				text = "📞 Call for help instead",
				effects = { Happiness = 4, Smarts = 3 },
				resultText = "You called professionals to help. Smart and safe approach."
			},
			{
				text = "💰 Help but get scammed",
				effects = { Money = -200, Happiness = -10, Smarts = 2 },
				resultText = "It was a scam! They took your money and ran. Lesson learned."
			},
		},
	},
	
	{
		id = "m_road_rage_encounter",
		minAge = 16, maxAge = 70,
		weight = 20, cooldown = 3,
		emoji = "😠", title = "Road Rage Incident",
		category = "social",
		text = "Someone is aggressively honking and yelling at you in traffic!",
		choices = {
			{ 
				text = "😤 Yell back", 
				effects = { Happiness = -8, Health = -5 }, 
				resultText = "It escalated! They got out of the car. Things got ugly."
			},
			{ 
				text = "🤷 Ignore them", 
				effects = { Happiness = 2, Smarts = 4 }, 
				resultText = "You stayed calm. They eventually drove off still angry."
			},
			{ 
				text = "👋 Apologetic wave", 
				effects = { Happiness = 4, Smarts = 3 }, 
				resultText = "The wave defused the situation. They calmed down."
			},
			{
				text = "📞 Call police",
				effects = { Happiness = -2, Smarts = 5 },
				resultText = "Reported the aggressive driver. Safety first."
			},
		},
	},
	
	{
		id = "m_lost_wallet_found",
		minAge = 12, maxAge = 70,
		weight = 20, cooldown = 4,
		emoji = "👛", title = "Found a Wallet!",
		category = "social",
		getDynamicData = function()
			local amount = math.random(50, 500)
			return { amount = amount }
		end,
		text = "You found a wallet on the ground with $%amount% cash and ID inside!",
		choices = {
			{ 
				text = "🏛️ Turn it in to police", 
				effects = { Happiness = 8, Smarts = 3 }, 
				resultText = "You did the right thing. The owner was so thankful!",
				setFlag = "honest"
			},
			{ 
				text = "📞 Contact the owner", 
				effects = { Happiness = 12, Money = 50 }, 
				resultText = "Found them and returned it. They gave you a reward!",
				setFlag = "honest"
			},
			{ 
				text = "💰 Keep the cash...",
				effects = { Money = 200, Happiness = -5, Smarts = -2 },
				resultText = "You kept it. Guilt lingers. Someone's having a bad day."
			},
			{
				text = "💸 Keep it all",
				effects = { Money = 300, Happiness = -8 },
				resultText = "You took everything. The guilt is real. Was it worth it?"
			},
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- UNEXPECTED SITUATIONS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_flat_tire",
		minAge = 16, maxAge = 80,
		weight = 25, cooldown = 3,
		emoji = "🚗", title = "Flat Tire!",
		category = "social",
		text = "Your car got a flat tire! You're stranded on the side of the road.",
		choices = {
			{ 
				text = "🔧 Change it yourself", 
				effects = { Happiness = 4, Smarts = 4 }, 
				resultText = "You did it! Dirty but proud. Self-sufficiency!",
				setFlag = "handy"
			},
			{ 
				text = "📞 Call for help",
				effects = { Happiness = 2, Money = -100 },
				resultText = "Roadside assistance came. Cost you but you're moving again."
			},
			{
				text = "🔧 Try and fail",
				effects = { Happiness = -6, Health = -3, Money = -150 },
				resultText = "You hurt your back trying and still had to call for help. Ouch."
			},
			{
				text = "👍 Stranger helps you",
				effects = { Happiness = 8, Smarts = 2 },
				resultText = "A kind stranger stopped and helped you change it. Faith in humanity restored!"
			},
		},
	},
	
	{
		id = "m_power_outage",
		minAge = 5, maxAge = 100,
		weight = 20, cooldown = 5,
		emoji = "🔦", title = "Power Outage!",
		category = "family",
		getDynamicData = function()
			local durations = {"a few hours", "overnight", "two days", "a week"}
			return { duration = durations[math.random(#durations)] }
		end,
		text = "The power went out and stayed out for %duration%!",
		choices = {
			{ 
				text = "🏕️ Adventure mode!", 
				effects = { Happiness = 8, Smarts = 3 }, 
				resultText = "Candles, board games, quality time! Made the best of it!",
				setFlag = "adaptable"
			},
			{ 
				text = "😤 Super frustrating",
				effects = { Happiness = -8 },
				resultText = "Everything spoiled in the fridge. Work disrupted. ANNOYING."
			},
			{
				text = "🏨 Go to a hotel",
				effects = { Happiness = 4, Money = -250 },
				resultText = "Escaped the darkness with modern amenities. Worth it."
			},
			{
				text = "🧊 Freezer disaster",
				effects = { Happiness = -6, Money = -200 },
				resultText = "Lost hundreds of dollars in frozen food. Power company isn't paying."
			},
		},
	},
	
	{
		id = "m_package_theft",
		minAge = 18, maxAge = 80,
		weight = 20, cooldown = 4,
		emoji = "📦", title = "Package Stolen!",
		category = "family",
		getDynamicData = function()
			local items = {"new phone", "expensive gift", "work equipment", "birthday present", "collector's item"}
			return { item = items[math.random(#items)] }
		end,
		text = "Your %item% package was stolen from your doorstep!",
		choices = {
			{ 
				text = "📹 Check camera footage", 
				effects = { Happiness = 4, Smarts = 3 }, 
				resultText = "Got the thief on camera! Filed a police report."
			},
			{ 
				text = "😤 Livid!", 
				effects = { Happiness = -10, Health = -2 }, 
				resultText = "The rage! Blood pressure spiked. So unfair!"
			},
			{
				text = "💰 File insurance claim",
				effects = { Happiness = 2, Money = -50 },
				resultText = "Deductible hurt but got most of it back."
			},
			{
				text = "🎁 Neighbor saved it!",
				effects = { Happiness = 10 },
				resultText = "Your neighbor grabbed it before thieves could! Good neighbors are gold!"
			},
		},
	},
	
	{
		id = "m_home_repair_emergency",
		minAge = 25, maxAge = 80,
		weight = 20, cooldown = 4,
		emoji = "🔧", title = "Home Emergency!",
		category = "family",
		getDynamicData = function()
			local problems = {
				{ type = "burst pipe", cost = math.random(500, 2000) },
				{ type = "AC died in summer", cost = math.random(300, 1500) },
				{ type = "roof leak", cost = math.random(500, 3000) },
				{ type = "clogged sewer", cost = math.random(200, 800) },
				{ type = "electrical issue", cost = math.random(200, 1000) },
			}
			local chosen = problems[math.random(#problems)]
			return { problem = chosen.type, cost = chosen.cost }
		end,
		text = "Home emergency: %problem%! This needs immediate attention!",
		choices = {
			{ 
				text = "🔧 DIY fix attempt", 
				effects = { Happiness = -4, Money = -100 }, 
				resultText = "You tried your best but made it worse. Had to call pros anyway."
			},
			{ 
				text = "📞 Call professionals",
				effects = { Happiness = -2, Money = -1000 },
				resultText = "Fixed properly but your wallet hurts. Homeownership is expensive."
			},
			{
				text = "🔧 DIY success!",
				effects = { Happiness = 8, Money = -50, Smarts = 4 },
				resultText = "YouTube tutorial saved you thousands! You fixed it yourself!",
				setFlag = "handy"
			},
			{
				text = "🏠 Insurance covers it",
				effects = { Happiness = 6, Money = -500 },
				resultText = "Thank goodness for insurance! Only paid the deductible."
			},
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- LUCKY/UNLUCKY EVENTS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_lottery_scratch",
		minAge = 18, maxAge = 80,
		weight = 15, cooldown = 3,
		emoji = "🎰", title = "Lottery Scratch Ticket!",
		category = "social",
		text = "You bought a scratch-off lottery ticket. Scratching now...",
		choices = {
			{ 
				text = "💰 Small win!", 
				effects = { Happiness = 8, Money = 50 }, 
				resultText = "Won $50! Not bad! Treating yourself to dinner!"
			},
			{ 
				text = "🎉 Decent win!",
				effects = { Happiness = 15, Money = 500 },
				resultText = "WOW! $500! This made your week!"
			},
			{
				text = "😔 Lost again",
				effects = { Happiness = -4, Money = -10 },
				resultText = "Nothing. Like usual. The house always wins."
			},
			{
				text = "🤑 BIG JACKPOT!",
				effects = { Happiness = 25, Money = 10000 },
				resultText = "OH MY GOD! $10,000 WINNER! This is INSANE!",
				setFlag = "lottery_winner"
			},
		},
	},
	
	{
		id = "m_random_act_of_kindness",
		minAge = 10, maxAge = 100,
		weight = 20, cooldown = 3,
		emoji = "❤️", title = "Random Act of Kindness!",
		category = "social",
		getDynamicData = function()
			local acts = {"paid for your coffee", "helped you carry groceries", "let you go first in line", "complimented your outfit", "gave you their parking spot"}
			return { act = acts[math.random(#acts)] }
		end,
		text = "A stranger %act%! A small gesture that brightened your day.",
		choices = {
			{ 
				text = "😊 Made my day!", 
				effects = { Happiness = 10 }, 
				resultText = "Faith in humanity restored! What a sweet moment!"
			},
			{ 
				text = "🔄 Pay it forward",
				effects = { Happiness = 12, Money = -20 },
				resultText = "You helped someone else in return. The kindness chain continues!",
				setFlag = "kind_soul"
			},
			{
				text = "🤔 Suspicious...",
				effects = { Happiness = 2, Smarts = 2 },
				resultText = "Was it genuine or did they want something? Either way, nothing bad happened."
			},
		},
	},
	
	{
		id = "m_bad_weather_stuck",
		minAge = 10, maxAge = 100,
		weight = 20, cooldown = 4,
		emoji = "🌧️", title = "Caught in Bad Weather!",
		category = "social",
		getDynamicData = function()
			local weather = {
				{ type = "sudden rainstorm", emoji = "🌧️" },
				{ type = "freak hailstorm", emoji = "🌨️" },
				{ type = "surprise snowstorm", emoji = "❄️" },
				{ type = "intense thunderstorm", emoji = "⛈️" },
			}
			local chosen = weather[math.random(#weather)]
			return { weatherType = chosen.type, weatherEmoji = chosen.emoji }
		end,
		getDynamicEmoji = function(data)
			return data.weatherEmoji or "🌧️"
		end,
		text = "You got caught outside in a %weatherType% without preparation!",
		choices = {
			{ 
				text = "🏠 Found shelter quickly", 
				effects = { Happiness = 4 }, 
				resultText = "Made it to safety! A bit wet but okay."
			},
			{ 
				text = "🌧️ Completely soaked",
				effects = { Happiness = -6, Health = -5 },
				resultText = "Drenched to the bone. Caught a cold from this. Miserable."
			},
			{
				text = "🚗 Car got damaged",
				effects = { Happiness = -10, Money = -800 },
				resultText = "Hail damage to your car! Insurance claim incoming."
			},
			{
				text = "☕ Made it to a café",
				effects = { Happiness = 6, Money = -15 },
				resultText = "Cozy café wait! The storm outside made it extra peaceful."
			},
		},
	},
	
	{
		id = "m_traffic_accident_witness",
		minAge = 16, maxAge = 80,
		weight = 15, cooldown = 5,
		emoji = "🚨", title = "Witnessed an Accident!",
		category = "social",
		text = "You witnessed a car accident! People might be hurt!",
		choices = {
			{ 
				text = "📞 Call 911 immediately", 
				effects = { Happiness = 4, Smarts = 4 }, 
				resultText = "First responders came quickly. Your call helped!",
				setFlag = "quick_thinker"
			},
			{ 
				text = "🏃 Rush to help",
				effects = { Happiness = 6, Health = -5 },
				resultText = "You helped pull someone from the wreck. Hero moment! But you got hurt."
			},
			{
				text = "😰 Frozen in shock",
				effects = { Happiness = -8, Health = -2 },
				resultText = "Couldn't move. The trauma lingers. Might need to talk to someone."
			},
			{
				text = "🎥 Record for evidence",
				effects = { Happiness = 2, Smarts = 5 },
				resultText = "Your video helped police and insurance. Practical thinking."
			},
		},
	},
	
	{
		id = "m_wrong_food_order",
		minAge = 10, maxAge = 80,
		weight = 25, cooldown = 2,
		emoji = "🍔", title = "Wrong Food Order!",
		category = "social",
		text = "The restaurant gave you completely the wrong order!",
		choices = {
			{ 
				text = "🗣️ Politely ask to fix it", 
				effects = { Happiness = 4 }, 
				resultText = "They fixed it and gave you a free dessert for the trouble!"
			},
			{ 
				text = "🤷 Eat it anyway",
				effects = { Happiness = 2 },
				resultText = "Actually... this is pretty good! Happy accident!"
			},
			{
				text = "😤 Demand a manager",
				effects = { Happiness = -2, Smarts = -2 },
				resultText = "Got your refund but everyone thinks you're 'that person' now."
			},
			{
				text = "🤢 Allergic reaction!",
				effects = { Happiness = -15, Health = -15, Money = -200 },
				resultText = "You ate it without checking - severe allergic reaction! Hospital trip!"
			},
		},
	},
	
	{
		id = "m_celebrity_sighting",
		minAge = 10, maxAge = 80,
		weight = 10, cooldown = 5,
		emoji = "⭐", title = "Celebrity Sighting!",
		category = "social",
		getDynamicData = function()
			local celebrities = {"a famous actor", "a popular singer", "a sports star", "a famous influencer", "a local news anchor"}
			return { celeb = celebrities[math.random(#celebrities)] }
		end,
		text = "You spotted %celeb% in public! What do you do?",
		choices = {
			{ 
				text = "📸 Ask for a selfie", 
				effects = { Happiness = 15, Looks = 2 }, 
				resultText = "They said yes! Best photo ever! Social media going crazy!",
				setFlag = "met_celebrity"
			},
			{ 
				text = "👋 Just wave and smile",
				effects = { Happiness = 8 },
				resultText = "They waved back! Cool moment. Respectful interaction."
			},
			{
				text = "😬 They ignored you",
				effects = { Happiness = -5 },
				resultText = "You tried to say hi but they walked right past. Ouch."
			},
			{
				text = "🤐 Don't bother them",
				effects = { Happiness = 4, Smarts = 3 },
				resultText = "Celebrities are people too. Nice spotting, kept it cool."
			},
		},
	},
}

return module
