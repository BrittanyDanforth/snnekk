-- LifeEvents/random_encounters.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- RANDOM ENCOUNTER EVENTS
-- BitLife-style: Player picks ACTIONS, game decides OUTCOMES
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent.init)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- STRAY ANIMAL ENCOUNTERS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_stray_cat_encounter",
		minAge = 8, maxAge = 70,
		weight = 25, cooldown = 3,
		emoji = "🐱", title = "Stray Cat!",
		category = "social",
		getDynamicData = function()
			local conditions = {"skinny and hungry", "hissing and scared", "friendly but dirty", "injured"}
			return { condition = conditions[math.random(#conditions)] }
		end,
		text = "You found a stray cat that looks %condition%. What do you do?",
		choices = {
			{ 
				text = "🏥 Take it to a shelter", 
				effects = { Happiness = 8, Smarts = 2 }, 
				resultText = "The shelter thanked you! They said the cat will find a good home."
			},
			{ 
				text = "🏠 Try to take it home", 
				effects = { Happiness = 12, Money = -200 }, 
				resultText = "New pet! Had to get food, litter, and vet checkup. Worth it!",
				setFlag = "has_pet"
			},
			{ 
				text = "🍖 Try to feed it", 
				effects = { Happiness = -8, Health = -10 }, 
				resultText = "OUCH! The scared cat scratched your hand badly when you reached for it! Bleeding!"
			},
			{ 
				text = "🤲 Try to pet it",
				effects = { Health = -12, Happiness = -8 },
				resultText = "BAD IDEA! The cat bit you and ran. That might need a tetanus shot..."
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
			local conditions = {"friendly and waggy", "growling nervously", "limping", "wearing a broken collar"}
			return { condition = conditions[math.random(#conditions)] }
		end,
		text = "A stray dog approaches you. It looks %condition%. What do you do?",
		choices = {
			{ 
				text = "📞 Call animal control", 
				effects = { Happiness = 3, Smarts = 3 }, 
				resultText = "They came and took the dog. Safe for everyone. Right call."
			},
			{ 
				text = "🏠 Take it home", 
				effects = { Happiness = 15, Money = -300 }, 
				resultText = "New best friend! Vet visit, food, and supplies needed. So worth it!",
				setFlag = "has_pet"
			},
			{ 
				text = "🤲 Approach slowly",
				effects = { Health = -18, Happiness = -12 },
				resultText = "The dog snapped! It bit your arm HARD. Hospital visit needed. Dogs can be unpredictable!"
			},
			{ 
				text = "🚶 Just walk away",
				effects = { Happiness = -2 },
				resultText = "You left it alone. Hope someone else helps. Slight guilt."
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
				{ type = "skunk", emoji = "🦨" },
				{ type = "snake", emoji = "🐍" },
			}
			local chosen = animals[math.random(#animals)]
			return { animal = chosen.type, animalEmoji = chosen.emoji }
		end,
		getDynamicEmoji = function(data)
			return data.animalEmoji or "🦊"
		end,
		text = "You encountered a %animal% in an unexpected place! What do you do?",
		choices = {
			{ 
				text = "📸 Take photo from distance", 
				effects = { Happiness = 10, Smarts = 3 }, 
				resultText = "Got a great shot! Posted it online. Nature is amazing!"
			},
			{ 
				text = "🚶 Slowly back away", 
				effects = { Happiness = 3, Smarts = 5 }, 
				resultText = "Smart! You left it alone and nothing bad happened."
			},
			{ 
				text = "🤲 Try to get closer",
				effects = { Health = -20, Happiness = -15 },
				resultText = "TERRIBLE IDEA! It attacked in self-defense! You're bleeding and might need rabies shots!"
			},
			{ 
				text = "😱 Run away screaming",
				effects = { Happiness = -5, Health = -5 },
				resultText = "You tripped while running! Scraped up your knee and hands. Embarrassing."
			},
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- STRANGER ENCOUNTERS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_stranger_needs_help",
		minAge = 16, maxAge = 70,
		weight = 30, cooldown = 2,
		emoji = "🆘", title = "Stranger Needs Help",
		category = "social",
		getDynamicData = function()
			local situations = {"car broke down", "phone died and needs a call", "needs directions", "dropped all their groceries"}
			return { situation = situations[math.random(#situations)] }
		end,
		text = "A stranger approaches - their %situation%. They're asking for help. What do you do?",
		choices = {
			{ 
				text = "🤝 Help them out", 
				effects = { Happiness = 10, Smarts = 2 }, 
				resultText = "They were so grateful! Made you feel good. Karma points!"
			},
			{ 
				text = "🙅 Too busy, walk away",
				effects = { Happiness = -5 },
				resultText = "You said no. Their disappointed face lingers in your mind."
			},
			{ 
				text = "💰 Offer money",
				effects = { Money = -150, Happiness = -10 },
				resultText = "It was a SCAM! They took your money and ran. Con artists everywhere!"
			},
			{
				text = "📞 Call someone for them",
				effects = { Happiness = 6, Smarts = 3 },
				resultText = "Called a tow truck/friend for them. Helpful but kept safe distance."
			},
		},
	},
	
	{
		id = "m_road_rage_encounter",
		minAge = 16, maxAge = 70,
		weight = 20, cooldown = 3,
		emoji = "😠", title = "Road Rage!",
		category = "social",
		text = "Someone is FURIOUS at you in traffic! Honking, yelling, gesturing! What do you do?",
		choices = {
			{ 
				text = "😤 Yell back at them", 
				effects = { Happiness = -15, Health = -10 }, 
				resultText = "It ESCALATED! They got out of their car. Things got physical. Bad decision!"
			},
			{ 
				text = "🤷 Ignore completely", 
				effects = { Happiness = 5, Smarts = 5 }, 
				resultText = "Didn't engage. They eventually drove off still angry. You stayed calm. Win."
			},
			{ 
				text = "👋 Wave apologetically", 
				effects = { Happiness = 6, Smarts = 3 }, 
				resultText = "A simple wave defused everything. They calmed down and drove away."
			},
			{
				text = "🖕 Make it worse",
				effects = { Health = -20, Money = -500, Happiness = -20 },
				resultText = "HUGE MISTAKE! They followed you, confronted you. Got into a fight. Cops called."
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
			local amount = math.random(100, 400)
			return { amount = amount }
		end,
		text = "You found a wallet with $%amount% cash and ID inside! What do you do?",
		choices = {
			{ 
				text = "🏛️ Turn it in to police", 
				effects = { Happiness = 10, Smarts = 3 }, 
				resultText = "Right thing to do! Officer said the owner will be contacted."
			},
			{ 
				text = "📞 Try to contact owner", 
				effects = { Happiness = 15, Money = 50 }, 
				resultText = "Found them on social media! They were SO grateful! Gave you a reward!"
			},
			{ 
				text = "💰 Keep the cash",
				effects = { Money = 200, Happiness = -10, Smarts = -3 },
				resultText = "Took the money... someone is having a terrible day because of you. Guilt."
			},
			{
				text = "💸 Keep everything",
				effects = { Money = 350, Happiness = -15 },
				resultText = "You stole from someone. Credit cards, everything. Karma's coming for you."
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
		text = "Your tire just blew out! You're on the side of the road. What do you do?",
		choices = {
			{ 
				text = "🔧 Change it yourself", 
				effects = { Happiness = 8, Smarts = 5, Health = -3 }, 
				resultText = "You did it! Took a while and got dirty, but back on the road!"
			},
			{ 
				text = "📞 Call roadside assistance",
				effects = { Happiness = 3, Money = -150 },
				resultText = "Help arrived in an hour. Cost money but no effort. Easy."
			},
			{
				text = "🔧 Try but mess it up",
				effects = { Happiness = -10, Health = -8, Money = -200 },
				resultText = "Jack slipped! Hurt your hand. Had to call for help anyway. Ouch."
			},
			{
				text = "👍 Flag down help",
				effects = { Happiness = 10, Smarts = 2 },
				resultText = "A kind stranger stopped and helped! Refused any money. Faith in humanity!"
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
			local durations = {"a few hours", "overnight", "two days"}
			return { duration = durations[math.random(#durations)] }
		end,
		text = "Power's out! Looks like it might be %duration%. What do you do?",
		choices = {
			{ 
				text = "🏕️ Make it an adventure!", 
				effects = { Happiness = 12, Smarts = 3 }, 
				resultText = "Candles, board games, telling stories! Actually had a great time!"
			},
			{ 
				text = "😤 Just be miserable",
				effects = { Happiness = -10, Health = -3 },
				resultText = "Sat in the dark complaining. Phone died. Food spoiled. Awful."
			},
			{
				text = "🏨 Go to a hotel",
				effects = { Happiness = 6, Money = -200 },
				resultText = "Checked in somewhere with power. Watched TV in comfort. Worth it."
			},
			{
				text = "😴 Just sleep through it",
				effects = { Happiness = 3, Health = 5 },
				resultText = "Went to bed early. Woke up and power was back. Easiest solution!"
			},
		},
	},
	
	{
		id = "m_package_stolen",
		minAge = 18, maxAge = 80,
		weight = 20, cooldown = 4,
		emoji = "📦", title = "Package Missing!",
		category = "family",
		getDynamicData = function()
			local items = {"new phone", "birthday gift", "work equipment", "expensive order"}
			return { item = items[math.random(#items)] }
		end,
		text = "Your %item% package should be here but it's gone! What do you do?",
		choices = {
			{ 
				text = "📹 Check doorbell camera", 
				effects = { Happiness = 5, Smarts = 4 }, 
				resultText = "Got the thief on video! Filed police report with evidence."
			},
			{ 
				text = "🏃 Ask neighbors",
				effects = { Happiness = 10 },
				resultText = "Neighbor grabbed it for you before thieves could! Good neighbors are gold!"
			},
			{
				text = "😤 Rage on social media",
				effects = { Happiness = -8, Smarts = -3 },
				resultText = "Ranted online. Didn't solve anything. Package still gone. Feel worse."
			},
			{
				text = "📞 Contact seller",
				effects = { Happiness = 3, Money = 0 },
				resultText = "They're sending a replacement! Took a week but got it eventually."
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
				{ type = "burst pipe", desc = "water everywhere!" },
				{ type = "AC broke", desc = "in the middle of summer!" },
				{ type = "toilet overflowing", desc = "bathroom disaster!" },
			}
			local chosen = problems[math.random(#problems)]
			return { problem = chosen.type, desc = chosen.desc }
		end,
		text = "%problem% - %desc% What do you do?",
		choices = {
			{ 
				text = "🔧 Try to fix it yourself", 
				effects = { Money = -50, Health = -5, Happiness = -8 }, 
				resultText = "Made it worse! Water damage. Had to call a pro anyway. Expensive lesson."
			},
			{ 
				text = "📞 Call a professional",
				effects = { Money = -800, Happiness = 5 },
				resultText = "Fixed properly but wallet hurts. Homeownership is expensive."
			},
			{
				text = "📺 YouTube how to fix it",
				effects = { Money = -100, Happiness = 10, Smarts = 5 },
				resultText = "Tutorial worked! Fixed it yourself! Saved hundreds! Skills unlocked!"
			},
			{
				text = "👨‍👩‍👧 Call family for help",
				effects = { Happiness = 8, Money = -50 },
				resultText = "Dad/uncle came and helped fix it! Just bought them pizza. Family comes through!"
			},
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- GAMBLING / LUCK - Action is the gamble itself
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_lottery_scratch",
		minAge = 18, maxAge = 80,
		weight = 15, cooldown = 3,
		emoji = "🎰", title = "Buy Scratch Ticket?",
		category = "social",
		text = "You're at the gas station and see lottery scratch tickets. $5 each. What do you do?",
		choices = {
			{ 
				text = "🎟️ Buy one ticket", 
				effects = { Happiness = -3, Money = -5 }, 
				resultText = "Nothing. Like usual. Threw away $5."
			},
			{ 
				text = "🎟️🎟️ Buy a few",
				effects = { Happiness = 8, Money = 45 },
				resultText = "Won $50! Actually came out ahead this time! Lucky day!"
			},
			{
				text = "💸 Buy a bunch",
				effects = { Money = -50, Happiness = -8 },
				resultText = "Spent $50, won $5. The house always wins. What were you thinking?"
			},
			{
				text = "🙅 Save your money",
				effects = { Smarts = 3, Money = 0 },
				resultText = "Walked away. Smart choice. Gambling is a tax on hope."
			},
		},
	},
	
	{
		id = "m_casino_trip",
		minAge = 21, maxAge = 80,
		weight = 12, cooldown = 5,
		emoji = "🎰", title = "Casino Night!",
		category = "social",
		requires = LifeEvents.hasFriend,  -- MUST have friends to go with friends
		text = "Friends want to hit the casino! You've got some money. What do you do?",
		choices = {
			{ 
				text = "🎰 Set a strict limit", 
				effects = { Happiness = 8, Money = -100 }, 
				resultText = "Lost your limit but had fun and stopped. Responsible gambling!"
			},
			{ 
				text = "🎲 Go all in!",
				effects = { Money = -2000, Happiness = -20 },
				resultText = "DISASTER! Lost way more than you should have. Why didn't you stop?!"
			},
			{
				text = "🍹 Just watch and drink",
				effects = { Happiness = 6, Money = -50 },
				resultText = "Watched friends gamble while sipping drinks. Entertainment without the risk!"
			},
			{
				text = "🍀 Trust your luck",
				effects = { Money = 500, Happiness = 15 },
				resultText = "WON $500! Quit while ahead! Best casino trip ever!"
			},
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- GOOD/BAD ENCOUNTERS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_random_kindness",
		minAge = 10, maxAge = 100,
		weight = 20, cooldown = 3,
		emoji = "❤️", title = "Stranger's Kindness!",
		category = "social",
		getDynamicData = function()
			local acts = {"paid for your coffee", "helped carry your groceries", "gave you their parking spot", "complimented you"}
			return { act = acts[math.random(#acts)] }
		end,
		text = "A stranger %act%! A small gesture that brightened your day. What do you do?",
		choices = {
			{ 
				text = "😊 Thank them warmly", 
				effects = { Happiness = 12 }, 
				resultText = "You connected for a moment. Both of you smiling. Beautiful human moment."
			},
			{ 
				text = "🔄 Pay it forward",
				effects = { Happiness = 15, Money = -20 },
				resultText = "Did something kind for someone else! The chain continues!"
			},
			{
				text = "🤔 Be suspicious",
				effects = { Happiness = 2, Smarts = 2 },
				resultText = "Waited for the catch... there wasn't one. Maybe people are good sometimes."
			},
			{
				text = "😶 Just walk away",
				effects = { Happiness = -3 },
				resultText = "Didn't even acknowledge them. They looked disappointed. Rude."
			},
		},
	},
	
	{
		id = "m_bad_weather_caught",
		minAge = 10, maxAge = 100,
		weight = 20, cooldown = 4,
		emoji = "🌧️", title = "Caught in Rain!",
		category = "social",
		text = "Sudden downpour! You're outside with no umbrella! What do you do?",
		choices = {
			{ 
				text = "🏃 Run for cover", 
				effects = { Happiness = 3, Health = -2 }, 
				resultText = "Made it to shelter! A bit wet but okay."
			},
			{ 
				text = "🌧️ Just walk through it",
				effects = { Happiness = -8, Health = -10 },
				resultText = "SOAKED! Caught a cold from this. Miserable for days."
			},
			{
				text = "☕ Duck into a café",
				effects = { Happiness = 8, Money = -15 },
				resultText = "Cozy coffee while watching the rain! Actually nice!"
			},
			{
				text = "🤝 Share stranger's umbrella",
				effects = { Happiness = 10 },
				resultText = "They offered! Had a nice chat walking together. New friend maybe?",
				setFlag = "has_friend",
				addRelationship = { category = "friends", startingRelationship = 40, type = "friend" }  -- Type must be "friend" for UI
			},
		},
	},
	
	{
		id = "m_wrong_food_order",
		minAge = 10, maxAge = 80,
		weight = 25, cooldown = 2,
		emoji = "🍔", title = "Wrong Order!",
		category = "social",
		text = "Restaurant gave you completely the wrong food! What do you do?",
		choices = {
			{ 
				text = "🗣️ Politely ask to fix it", 
				effects = { Happiness = 6 }, 
				resultText = "They fixed it and gave free dessert for the trouble! Nice!"
			},
			{ 
				text = "🤷 Eat it anyway",
				effects = { Happiness = -5, Health = -12 },
				resultText = "Had something you didn't know you were ALLERGIC to! Reaction! Hospital trip!"
			},
			{
				text = "😤 Demand manager",
				effects = { Happiness = -3, Smarts = -2 },
				resultText = "Made a scene. Got your refund but everyone thinks you're 'that person'."
			},
			{
				text = "📱 Leave bad review",
				effects = { Happiness = -5, Smarts = -3 },
				resultText = "Wrote an angry review without talking to them. Petty. Didn't fix anything."
			},
		},
	},
	
	{
		id = "m_celebrity_sighting",
		minAge = 10, maxAge = 80,
		weight = 10, cooldown = 5,
		emoji = "⭐", title = "Celebrity Spotted!",
		category = "social",
		getDynamicData = function()
			local celebrities = {"a famous actor", "a popular singer", "a sports star", "a famous influencer"}
			return { celeb = celebrities[math.random(#celebrities)] }
		end,
		text = "You spotted %celeb% in public! What do you do?",
		choices = {
			{ 
				text = "📸 Ask for a selfie", 
				effects = { Happiness = 18, Looks = 3 }, 
				resultText = "They said YES! Got an amazing photo! Social media going crazy!"
			},
			{ 
				text = "👋 Wave and smile",
				effects = { Happiness = 8 },
				resultText = "They waved back! Cool moment. Respectful interaction."
			},
			{
				text = "🏃 Run up to them",
				effects = { Happiness = -10, Looks = -3 },
				resultText = "Security stopped you! Embarrassing. They looked uncomfortable. Bad move."
			},
			{
				text = "🤐 Leave them alone",
				effects = { Happiness = 5, Smarts = 3 },
				resultText = "Celebrities are people too. Let them have their moment. Classy choice."
			},
		},
	},
	
	{
		id = "m_witness_crime",
		minAge = 16, maxAge = 80,
		weight = 10, cooldown = 6,
		emoji = "🚨", title = "Witnessed a Crime!",
		category = "social",
		text = "You just saw someone commit a crime! They didn't see you. What do you do?",
		choices = {
			{ 
				text = "📞 Call 911", 
				effects = { Happiness = 8, Smarts = 5 }, 
				resultText = "Reported it safely. Police came. You helped justice. Good citizen."
			},
			{ 
				text = "📱 Record evidence",
				effects = { Happiness = 5, Smarts = 4 },
				resultText = "Got video evidence! Gave it to police. Case solved because of you!"
			},
			{
				text = "🦸 Try to intervene",
				effects = { Health = -20, Happiness = -15 },
				resultText = "They saw you and attacked! You got hurt badly. Leave this to police next time!"
			},
		{
			text = "🚶 Walk away",
			effects = { Happiness = -10, Smarts = -3 },
			resultText = "Did nothing. The guilt eats at you. Someone got hurt because you didn't act."
		},
	},
},

	-- ═══════════════════════════════════════════════════════════════
	-- LIFE-STEERING EVENTS (Based on player's past choices)
	-- These events react to who the player has become
	-- ═══════════════════════════════════════════════════════════════
	
	-- For Ex-Convicts trying to rebuild
	{
		id = "m_ex_con_job_hunt",
		minAge = 20, maxAge = 55,
		weight = 35, cooldown = 3,
		emoji = "📝", title = "Job Application",
		category = "social",
		requiresFlag = "ex_convict",
		blockIfFlag = "employed",
		text = "You're applying for jobs, but the 'Have you been convicted of a crime?' question stares back at you.",
		choices = {
			{ 
				text = "✍️ Be honest", 
				effects = { Happiness = -5, Smarts = 3 }, 
				resultText = "You told the truth. Most won't call back, but at least you were honest.",
				setFlag = "honest_about_record"
			},
			{ 
				text = "🤥 Lie on the form", 
				effects = { Happiness = 3, Smarts = -3 }, 
				resultText = "You checked 'No'. Hope they don't do a background check...",
				setFlag = "lied_on_application"
			},
			{ 
				text = "🔧 Look for second-chance employers", 
				effects = { Happiness = 5, Smarts = 4 }, 
				resultText = "Some companies specifically hire people with records. Smart thinking!",
				setFlag = "seeking_second_chance"
			},
			{ 
				text = "💼 Start own business instead", 
				effects = { Happiness = 8, Money = -5000, Smarts = 5 }, 
				resultText = "Be your own boss! Nobody can reject your application now.",
				setFlags = {"entrepreneur", "self_employed"}
			},
		},
	},
	
	-- Criminal past catching up
	{
		id = "m_past_catches_up",
		minAge = 18, maxAge = 50,
		weight = 25, cooldown = 5,
		emoji = "👮", title = "Knock at the Door",
		category = "social",
		requiresAnyFlag = {"petty_thief", "committed_crime", "gang_member", "criminal_tendencies"},
		blockIfFlag = "in_prison",
		text = "There's a loud knock at your door. Through the peephole, you see police.",
		choices = {
			{ 
				text = "🚪 Answer normally", 
				effects = { Happiness = 5, Smarts = 2 }, 
				resultText = "Just routine questions. They were looking for someone else. Close call.",
			},
			{ 
				text = "🏃 Sneak out the back", 
				effects = { Happiness = -8, Health = -5 }, 
				resultText = "You ran for nothing. Now you look guilty of something.",
				setFlag = "paranoid"
			},
			{ 
				text = "📞 Call a lawyer first", 
				effects = { Happiness = 2, Money = -500, Smarts = 5 }, 
				resultText = "Smart move. Know your rights. They just wanted to ask about a neighbor.",
			},
			{ 
				text = "😰 Panic and confess something", 
				effects = { Happiness = -15, Smarts = -5 }, 
				resultText = "You blurted out details about old crimes. They weren't even here for you. Now they are.",
				setFlag = "under_investigation"
			},
		},
	},
	
	-- Criminal opportunity for those on that path
	{
		id = "m_criminal_opportunity",
		minAge = 18, maxAge = 45,
		weight = 30, cooldown = 3,
		emoji = "💰", title = "Underground Opportunity",
		category = "crime",
		requiresAnyFlag = {"criminal_tendencies", "gang_contact", "petty_thief", "drug_dealer"},
		blockIfFlag = "in_prison",
		getDynamicData = function()
			local jobs = {
				{type = "smuggling goods", pay = 5000},
				{type = "being a lookout", pay = 1000},
				{type = "delivering packages", pay = 2000},
				{type = "hacking a system", pay = 8000},
			}
			local job = jobs[math.random(#jobs)]
			return { jobType = job.type, pay = job.pay }
		end,
		text = "Someone from your past contacts you about %jobType%. They're offering $%pay%.",
		choices = {
			{ 
				text = "✅ Take the job", 
				effectsDynamic = function(data) return { Money = data.pay, Happiness = 5 } end,
				chanceSuccess = 0.65,
				resultText = "Job done. Easy money. But you're deeper in now.",
				resultTextFail = "BUSTED! The cops were waiting. You're going to prison.",
				setFlagOnFail = "in_prison",
				setFlag = "active_criminal"
			},
			{ 
				text = "❌ Decline politely", 
				effects = { Happiness = 2, Smarts = 4 }, 
				resultText = "You're trying to stay clean. Respect.",
				setFlag = "going_straight"
			},
			{ 
				text = "📞 Tip off the police", 
				effects = { Happiness = 5, Smarts = 3 }, 
				resultText = "Anonymous tip sent. Maybe making up for the past.",
				setFlag = "informant"
			},
			{ 
				text = "💲 Negotiate higher pay", 
				effectsDynamic = function(data) return { Money = math.floor(data.pay * 1.5), Happiness = 8 } end,
				chanceSuccess = 0.5,
				resultText = "They agreed! More risk, more reward.",
				resultTextFail = "They didn't like your attitude. Deal's off. And now they don't trust you.",
				setFlagOnFail = "burned_criminal_contact"
			},
		},
	},
	
	-- Good reputation paying off
	{
		id = "m_good_reputation",
		minAge = 25, maxAge = 60,
		weight = 25, cooldown = 5,
		emoji = "🌟", title = "Reputation Matters",
		category = "social",
		requiresAnyFlag = {"generous", "honest", "volunteer", "mentor", "community_pillar"},
		blockIfFlag = "criminal_tendencies",
		getDynamicData = function()
			local opportunities = {
				"offered a board position",
				"nominated for a community award",
				"asked to speak at an event",
				"recommended for a big opportunity"
			}
			return { opportunity = opportunities[math.random(#opportunities)] }
		end,
		text = "Because of your good reputation in the community, you've been %opportunity%!",
		choices = {
			{ 
				text = "🎉 Accept graciously", 
				effects = { Happiness = 15, Smarts = 3 }, 
				resultText = "Your good deeds are being recognized! Feels amazing!",
				setFlag = "community_leader"
			},
			{ 
				text = "😊 Humbly decline", 
				effects = { Happiness = 8, Smarts = 2 }, 
				resultText = "You prefer to do good quietly. That's admirable.",
			},
			{ 
				text = "🤔 Use it strategically", 
				effects = { Happiness = 10, Money = 5000, Smarts = 4 }, 
				resultText = "This opened doors for your career. Good reputation is valuable!",
				setFlag = "networker"
			},
		},
	},
	
	-- Reformed criminal event
	{
		id = "m_redemption_opportunity",
		minAge = 25, maxAge = 55,
		weight = 20, oneTime = true,
		emoji = "🕊️", title = "Chance for Redemption",
		category = "social",
		requiresFlag = "ex_convict",
		requiresFlag2 = "going_straight",
		text = "A youth center asks if you'd share your story with at-risk kids. Your past could help them avoid the same mistakes.",
		choices = {
			{ 
				text = "🎤 Tell your story", 
				effects = { Happiness = 20, Smarts = 5 }, 
				resultText = "The kids listened. Some even cried. You might have changed lives today.",
				setFlags = {"redeemed", "mentor", "speaker"}
			},
			{ 
				text = "📝 Write it down instead", 
				effects = { Happiness = 12, Smarts = 4 }, 
				resultText = "Your written testimony is being shared. Impact without the spotlight.",
				setFlag = "redeemed"
			},
			{ 
				text = "😔 Too painful to share", 
				effects = { Happiness = -5 }, 
				resultText = "You're not ready. That's okay. Healing takes time.",
			},
		},
	},
	
	-- Karma event for good people
	{
		id = "m_karma_good_deed",
		minAge = 20, maxAge = 70,
		weight = 20, cooldown = 5,
		emoji = "🍀", title = "Good Karma",
		category = "social",
		requiresAnyFlag = {"generous", "volunteer", "helped_stranger", "mentor"},
		blockIfFlag = "mean_streak",
		text = "Remember that person you helped a while back? They tracked you down to repay the kindness!",
		choices = {
			{ 
				text = "🤗 Accept their thanks", 
				effects = { Happiness = 15, Money = 2000 }, 
				resultText = "They gave you a gift and heartfelt thanks. Good deeds come back around!",
			},
			{ 
				text = "🤝 Ask them to pay it forward", 
				effects = { Happiness = 18, Smarts = 3 }, 
				resultText = "You asked them to help someone else instead. The chain of kindness continues!",
				setFlag = "chain_of_kindness"
			},
			{ 
				text = "🙈 Don't remember them", 
				effects = { Happiness = 8 }, 
				resultText = "You help so many people you can't remember them all. That's beautiful.",
			},
		},
	},
	
	-- Mean streak consequences
	{
		id = "m_mean_karma",
		minAge = 18, maxAge = 60,
		weight = 25, cooldown = 5,
		emoji = "😠", title = "What Goes Around...",
		category = "social",
		requiresAnyFlag = {"mean_streak", "bully", "fights_back", "aggressive"},
		blockIfFlag = "redeemed",
		text = "Someone you wronged in the past crosses your path. They haven't forgotten.",
		choices = {
			{ 
				text = "🙏 Apologize sincerely", 
				effects = { Happiness = 5, Smarts = 3 }, 
				resultText = "They accepted your apology. Some grudges can heal.",
				clearFlag = "mean_streak"
			},
			{ 
				text = "😤 Stand your ground", 
				effects = { Happiness = -8, Health = -10 }, 
				resultText = "The confrontation got ugly. Your past came back to hurt you.",
			},
			{ 
				text = "🏃 Avoid the situation", 
				effects = { Happiness = -5 }, 
				resultText = "You ducked away. But you can't run forever.",
			},
			{ 
				text = "💰 Offer to make amends", 
				effects = { Happiness = 8, Money = -3000 }, 
				resultText = "Money can't fix everything, but it helped. They agreed to move on.",
				clearFlag = "mean_streak"
			},
		},
	},
}

return module
