-- LifeEvents/career_sports.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- SPORTS & ATHLETICS CAREER EVENTS
-- BitLife-style: Player picks ACTIONS, game decides OUTCOMES
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent.init)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- EARLY ATHLETIC TALENT
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "sports_childhood_natural",
		minAge = 6, maxAge = 12,
		weight = 25, oneTime = true,
		emoji = "⚽", title = "Coach Sees Potential!",
		category = "school",
		getDynamicData = function()
			local sports = {
				{ name = "soccer", emoji = "⚽" },
				{ name = "basketball", emoji = "🏀" },
				{ name = "baseball", emoji = "⚾" },
				{ name = "swimming", emoji = "🏊" },
				{ name = "gymnastics", emoji = "🤸" },
			}
			local chosen = sports[math.random(#sports)]
			return { sport = chosen.name, sportEmoji = chosen.emoji }
		end,
		getDynamicEmoji = function(data) return data.sportEmoji or "⚽" end,
		text = "Coach says you're a natural at %sport%! Way ahead of other kids! What do you want to do?",
		choices = {
			{ text = "🏆 Train seriously", effects = { Happiness = 15, Health = 10 }, resultText = "Daily practice begins! You're getting really good!", setFlags = {"athlete", "serious_athlete"} },
			{ text = "🎮 Prefer video games", effects = { Happiness = 8, Health = -3 }, resultText = "Sports are okay but gaming is more fun. Talent unused." },
			{ text = "⚖️ Balance with school", effects = { Happiness = 10, Health = 5, Smarts = 5 }, resultText = "Playing AND good grades! Well-rounded approach!", setFlag = "athlete" },
			{ text = "🏅 Dream of going pro", effects = { Happiness = 12, Health = 8 }, resultText = "One day you'll be famous! The dream starts now!", setFlags = {"athlete", "pro_dreams"} },
		},
	},
	
	{
		id = "sports_youth_championship",
		minAge = 10, maxAge = 16,
		weight = 25, cooldown = 2,
		emoji = "🏆", title = "Championship Game!",
		category = "school",
		requiresFlag = "athlete",
		text = "It's the championship game! Tied score, final moments! You have a chance to make a play! What do you do?",
		choices = {
			{ text = "💪 Go for the winning play", effects = { Happiness = 25, Health = 3, Looks = 5 }, resultText = "YOU DID IT! CHAMPIONS! They're chanting your name!", setFlag = "clutch_player" },
			{ text = "🤝 Pass to teammate", effects = { Happiness = 15, Smarts = 3 }, resultText = "They scored! CHAMPIONS! Team effort! Unselfish play!", setFlag = "team_player" },
			{ text = "😰 Choke under pressure", effects = { Happiness = -15, Health = -3 }, resultText = "Missed it. Lost the game. Devastating. But there's next year." },
			{ text = "🤕 Get injured trying", effects = { Happiness = -10, Health = -15 }, resultText = "Hurt yourself making the play. Won the game but at a cost.", setFlag = "injured_athlete" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- HIGH SCHOOL / COLLEGE SPORTS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "sports_varsity_tryouts",
		minAge = 14, maxAge = 18,
		weight = 25, oneTime = true,
		emoji = "🏈", title = "Varsity Tryouts!",
		category = "school",
		requiresFlag = "athlete",
		text = "Varsity tryouts today! This is a big deal. How do you approach it?",
		choices = {
			{ text = "💯 Give 100% effort", effects = { Happiness = 20, Health = 5, Looks = 3 }, resultText = "MADE VARSITY! Coach loved your hustle! Starting lineup!", setFlags = {"varsity", "popular"} },
			{ text = "😤 Show off skills", effects = { Happiness = 10, Health = 3 }, resultText = "Made the team but coach thinks you're cocky. Bench for now." },
			{ text = "🤝 Support teammates", effects = { Happiness = 12, Smarts = 3 }, resultText = "Made the team! Coach appreciates your attitude!", setFlag = "varsity" },
			{ text = "😰 Too nervous", effects = { Happiness = -10, Health = -3 }, resultText = "Choked under pressure. JV for another year. Disappointing." },
		},
	},
	
	{
		id = "sports_scholarship_offer",
		minAge = 17, maxAge = 18,
		weight = 20, oneTime = true,
		emoji = "🎓", title = "Scholarship Offers!",
		category = "school",
		requiresFlag = "varsity",
		getDynamicData = function()
			local schools = {"Duke", "UCLA", "Ohio State", "Alabama", "Stanford", "Michigan"}
			return { school = schools[math.random(#schools)] }
		end,
		text = "Multiple colleges want you! %school% offering a FULL athletic scholarship! What do you do?",
		choices = {
			{ text = "✅ Accept top program", effects = { Happiness = 30, Money = 100000 }, resultText = "FULL RIDE! D1 athlete! Dream school! Future bright!", setFlags = {"college_athlete", "scholarship"} },
			{ text = "📋 Wait for more offers", effects = { Happiness = 20, Money = 100000, Smarts = 5 }, resultText = "Played the recruitment game! Got an even BETTER offer!", setFlags = {"college_athlete", "highly_recruited"} },
			{ text = "🎓 Prioritize academics", effects = { Happiness = 15, Smarts = 8 }, resultText = "Chose the better school, not the better program. Smart long-term." },
			{ text = "😰 Can't decide", effects = { Happiness = 5, Smarts = 3 }, resultText = "Waited too long! Best offers expired. Settled for less." },
		},
	},
	
	{
		id = "sports_college_injury",
		minAge = 18, maxAge = 22,
		weight = 20, cooldown = 3,
		emoji = "🏥", title = "Injured in Practice!",
		category = "health",
		requiresFlag = "college_athlete",
		getDynamicData = function()
			local injuries = {"sprained ankle", "torn ACL", "shoulder injury", "concussion"}
			return { injury = injuries[math.random(#injuries)] }
		end,
		text = "You got a %injury% during practice! Doctor says you need to rest. What do you do?",
		choices = {
			{ text = "🏥 Follow doctor's orders", effects = { Health = 10, Happiness = 5 }, resultText = "Full recovery! Back at 100%! Patience paid off!", setFlag = "comeback_story" },
			{ text = "💪 Play through it", effects = { Health = -20, Happiness = -15 }, resultText = "Made it WAY worse! Season over. Possibly career-threatening now.", setFlag = "career_doubt" },
			{ text = "😔 Depression hits", effects = { Health = -5, Happiness = -20 }, resultText = "Identity crisis. Who are you without sports? Struggling hard." },
			{ text = "🔄 Learn other positions", effects = { Health = 5, Smarts = 5, Happiness = 8 }, resultText = "Used recovery time to study the game. Came back smarter!" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- PROFESSIONAL CAREER
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "sports_draft_day",
		minAge = 20, maxAge = 24,
		weight = 15, oneTime = true,
		emoji = "📺", title = "Draft Day!",
		category = "work",
		requiresFlag = "college_athlete",
		blockIfFlag = "pro_athlete", -- Only one draft event
		text = "The professional draft is today! Your family is watching! Commissioner approaches the mic! What's your mindset?",
		choices = {
			{ 
				text = "🙏 Hopeful and ready", 
				effects = { Happiness = 35 }, 
				resultText = "YOUR NAME CALLED! First round pick! Millions guaranteed!", 
				setFlags = {"pro_athlete", "first_rounder", "employed"},
				setJob = { id = "pro_athlete", title = "Professional Athlete", salary = 2000000 }
			},
			{ 
				text = "😰 Nervous wreck", 
				effects = { Happiness = 15 }, 
				resultText = "Went later than hoped. Chip on shoulder. Prove them wrong!", 
				setFlags = {"pro_athlete", "chip_on_shoulder", "employed"},
				setJob = { id = "pro_athlete", title = "Professional Athlete", salary = 500000 }
			},
			{ 
				text = "😎 Know your worth", 
				effects = { Happiness = 25 }, 
				resultText = "Confidence showed! Good pick! Ready for the league!", 
				setFlags = {"pro_athlete", "employed"},
				setJob = { id = "pro_athlete", title = "Professional Athlete", salary = 1500000 }
			},
			{ text = "😔 Accept any outcome", effects = { Happiness = -10, Money = 100000 }, resultText = "Undrafted. Free agent route. Long shot but possible.", setFlag = "undrafted" },
		},
	},
	
	{
		id = "sports_rookie_season",
		minAge = 21, maxAge = 26,
		weight = 25, cooldown = 2,
		emoji = "⭐", title = "Big Game as Rookie!",
		category = "work",
		requiresFlag = "pro_athlete",
		text = "Huge game! National TV! All eyes on the rookie! How do you approach it?",
		choices = {
			{ text = "🔥 Leave it all out there", effects = { Happiness = 30, Money = 500000, Looks = 5 }, resultText = "BREAKOUT PERFORMANCE! Sportscenter top 10! Star is born!", setFlags = {"breakout_star", "superstar"} },
			{ text = "📚 Stick to the gameplan", effects = { Happiness = 15, Money = 200000, Smarts = 5 }, resultText = "Solid performance. Nothing flashy but coach trusts you now." },
			{ text = "😰 Pressure gets to you", effects = { Happiness = -15, Money = 100000 }, resultText = "Not your best night. Struggled with the spotlight. Keep working." },
			{ text = "🤕 Get hurt during game", effects = { Happiness = -10, Health = -20, Money = 150000 }, resultText = "Injury in the spotlight. Everyone saw it. Long recovery ahead." },
		},
	},
	
	{
		id = "sports_contract_negotiation",
		minAge = 24, maxAge = 35,
		weight = 15, oneTime = true,
		emoji = "💰", title = "Contract Negotiation!",
		category = "work",
		requiresFlag = "superstar",
		getDynamicData = function()
			local years = math.random(3, 6)
			local amount = math.random(100, 300)
			return { years = years, amount = amount }
		end,
		text = "Free agency! Teams bidding! $%amount% million over %years% years on the table! What do you do?",
		choices = {
			{ text = "💰 Take the money!", effects = { Happiness = 30, Money = 50000000 }, resultText = "MEGA CONTRACT! Generational wealth secured! Set for life!", setFlags = {"max_contract", "wealthy_athlete"} },
			{ text = "🏆 Chase championships", effects = { Happiness = 25, Money = 20000000 }, resultText = "Took less to join a contender! Rings over money!", setFlag = "ring_chaser" },
			{ text = "🏠 Stay loyal", effects = { Happiness = 35, Money = 30000000 }, resultText = "Hometown discount! Fans love you forever! Legend status!", setFlags = {"loyal_player", "hometown_hero"} },
			{ text = "😤 Demand more", effects = { Happiness = 10, Money = 60000000 }, resultText = "Hardball worked! More money but burned some bridges." },
		},
	},
	
	{
		id = "sports_championship_game",
		minAge = 22, maxAge = 40,
		weight = 10, oneTime = true,
		emoji = "🏆", title = "THE CHAMPIONSHIP!",
		category = "work",
		requiresFlag = "pro_athlete",
		text = "CHAMPIONSHIP GAME! This is what you've worked your ENTIRE LIFE for! Final moments! What do you do?",
		choices = {
			{ text = "🏆 Take the big shot", effects = { Happiness = 50, Money = 2000000, Looks = 10 }, resultText = "YOU DID IT! CHAMPION! Confetti falling! Trophy in hands! IMMORTALIZED!", setFlags = {"champion", "clutch_legend"} },
			{ text = "🤝 Set up teammate", effects = { Happiness = 40, Money = 1500000 }, resultText = "CHAMPIONS! Team win! You made the winning pass! Selfless!", setFlags = {"champion", "team_player"} },
			{ text = "😔 Come up short", effects = { Happiness = -30, Health = -5 }, resultText = "So close. Lost in the final seconds. Haunting. Will you get another chance?" },
			{ text = "🤕 Injured in final", effects = { Happiness = -20, Health = -20 }, resultText = "Hurt during the championship. Watched the end from sideline. Devastating." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- OLYMPICS PATH
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "sports_olympic_trials",
		minAge = 16, maxAge = 35,
		weight = 12, oneTime = true,
		emoji = "🏅", title = "Olympic Trials!",
		category = "work",
		requiresFlag = "serious_athlete",
		text = "Olympic trials! Chance to represent your country! This is the moment! How do you perform?",
		choices = {
			{ text = "💪 Peak performance", effects = { Happiness = 40, Health = 5, Looks = 5 }, resultText = "MADE THE TEAM! You're an OLYMPIAN! Representing your country!", setFlags = {"olympian", "national_team"} },
			{ text = "😤 Fight through pain", effects = { Happiness = 25, Health = -10 }, resultText = "Made it despite injury! Painful but you're going to the Olympics!", setFlags = {"olympian", "warrior"} },
			{ text = "😔 Just miss the cut", effects = { Happiness = -20, Smarts = 5 }, resultText = "4th place. So close. Four more years of waiting and wondering." },
			{ text = "😰 Pressure crushes you", effects = { Happiness = -25, Health = -5 }, resultText = "Choked when it mattered most. Dreams shattered. Devastating." },
		},
	},
	
	{
		id = "sports_olympic_medal",
		minAge = 16, maxAge = 40,
		weight = 8, oneTime = true,
		emoji = "🥇", title = "Olympic Final!",
		category = "work",
		requiresFlag = "olympian",
		text = "THE OLYMPIC FINAL! Billions watching! Everything you've trained for! How do you compete?",
		choices = {
			{ text = "🥇 Perfect execution", effects = { Happiness = 60, Money = 1000000, Looks = 10 }, resultText = "GOLD MEDAL! National anthem playing! Tears streaming! LEGENDARY!", setFlags = {"olympic_gold", "national_hero"} },
			{ text = "💪 Give everything", effects = { Happiness = 35, Money = 500000 }, resultText = "Silver medal! Second in the WORLD! Incredible achievement!", setFlag = "olympic_medalist" },
			{ text = "🤕 Compete injured", effects = { Happiness = 25, Health = -15, Money = 300000 }, resultText = "Bronze through pain! Medal is medal! Warrior spirit!", setFlag = "olympic_medalist" },
			{ text = "😔 Fall short", effects = { Happiness = -25 }, resultText = "4th place. No medal. The cruelest place to finish. So close to history." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- CAREER END / LEGACY
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "sports_decline",
		minAge = 30, maxAge = 42,
		weight = 25, cooldown = 3,
		emoji = "📉", title = "Father Time Undefeated",
		category = "work",
		requiresFlag = "pro_athlete",
		text = "You're not as fast as you used to be. Younger players passing you. What do you do?",
		choices = {
			{ text = "💪 Adapt your game", effects = { Happiness = 12, Smarts = 8 }, resultText = "Can't rely on athleticism anymore. Playing smarter! Veteran savvy!", setFlag = "veteran_savvy" },
			{ text = "😤 Refuse to accept", effects = { Happiness = -10, Health = -10 }, resultText = "Pushing too hard. Body breaking down. Pride before health." },
			{ text = "🏆 One last run", effects = { Happiness = 15, Health = -8 }, resultText = "Everything for one more championship attempt! Going out swinging!" },
			{ text = "📺 Mentor young players", effects = { Happiness = 15, Smarts = 5 }, resultText = "Passing on wisdom. Your experience is valuable to the next generation." },
		},
	},
	
	{
		id = "sports_retirement_decision",
		minAge = 32, maxAge = 45,
		weight = 20, oneTime = true,
		emoji = "🎤", title = "Time to Retire?",
		category = "work",
		requiresFlag = "pro_athlete",
		text = "The body is tired. Is it time to hang it up? Press conference is scheduled. What do you announce?",
		choices = {
			{ text = "😭 Announce retirement", effects = { Happiness = 25, Health = 10 }, resultText = "Emotional farewell. Standing ovation. Beautiful send-off. Legend.", clearFlag = "pro_athlete", setFlags = {"retired_athlete", "beloved"} },
			{ text = "🏆 One more season", effects = { Happiness = 15, Health = -10 }, resultText = "Not done yet! Going for one more year! They can't stop you!" },
			{ text = "🔄 Try different team", effects = { Happiness = 10, Health = -5 }, resultText = "Fresh start somewhere else! New chapter! Still got gas in the tank!" },
			{ text = "📺 Announce TV career", effects = { Happiness = 20, Money = 500000 }, resultText = "Retiring to the broadcast booth! Analyst life begins!", clearFlag = "pro_athlete", setFlags = {"retired_athlete", "analyst"} },
		},
	},
	
	{
		id = "sports_hall_of_fame",
		minAge = 40, maxAge = 80,
		weight = 8, oneTime = true,
		emoji = "🏛️", title = "Hall of Fame Call!",
		category = "work",
		requiresFlag = "champion",
		text = "THE CALL CAME! You're being inducted into the Hall of Fame! How do you react?",
		choices = {
			{ text = "😭 Overwhelmed with emotion", effects = { Happiness = 50, Looks = 5 }, resultText = "Cried on the phone. Dreams fulfilled. Immortalized forever.", setFlag = "hall_of_famer" },
			{ text = "🎤 Prepare perfect speech", effects = { Happiness = 45, Smarts = 5 }, resultText = "Thanked everyone who helped. Moved the audience. Perfect moment.", setFlag = "hall_of_famer" },
			{ text = "👨‍👩‍👧 Celebrate with family", effects = { Happiness = 48 }, resultText = "Shared the moment with those who sacrificed with you. Full circle.", setFlag = "hall_of_famer" },
			{ text = "🙏 Stay humble", effects = { Happiness = 42, Smarts = 3 }, resultText = "Deflected praise to coaches and teammates. Class until the end.", setFlag = "hall_of_famer" },
		},
	},
	
	{
		id = "sports_coaching_offer",
		minAge = 35, maxAge = 65,
		weight = 20, oneTime = true,
		emoji = "📋", title = "Coaching Offer!",
		category = "work",
		requiresFlag = "retired_athlete",
		getDynamicData = function()
			local levels = {"a college team", "a professional team", "your old team", "a youth program"}
			return { level = levels[math.random(#levels)] }
		end,
		text = "%level% wants you as their coach! Staying in the game! What do you do?",
		choices = {
			{ text = "📋 Accept the job", effects = { Happiness = 25, Money = 500000 }, resultText = "Coach [Your Name]! Leading the next generation! Full circle!", setFlags = {"coach", "employed"} },
			{ text = "🏆 Only if I can win", effects = { Happiness = 20, Money = 700000 }, resultText = "Negotiated full control! Championship expectations! Let's go!", setFlags = {"coach", "championship_coach"} },
			{ text = "🏖️ Enjoy retirement", effects = { Happiness = 15, Health = 5 }, resultText = "Thanks but no. Enjoying life off the field. You've earned it." },
			{ text = "📺 Prefer broadcasting", effects = { Happiness = 18, Money = 400000 }, resultText = "TV is more your speed. Less stress, good money, fame continues.", setFlag = "broadcaster" },
		},
	},
}

return module
