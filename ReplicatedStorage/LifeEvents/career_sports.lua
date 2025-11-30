-- LifeEvents/career_sports.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- SPORTS & ATHLETICS CAREER EVENTS
-- Athletes, Olympians, Pro Players, Coaches - The competitive life
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
		emoji = "⚽", title = "Natural Athlete!",
		category = "school",
		getDynamicData = function()
			local sports = {
				{ name = "soccer", emoji = "⚽" },
				{ name = "basketball", emoji = "🏀" },
				{ name = "baseball", emoji = "⚾" },
				{ name = "swimming", emoji = "🏊" },
				{ name = "gymnastics", emoji = "🤸" },
				{ name = "tennis", emoji = "🎾" },
			}
			local chosen = sports[math.random(#sports)]
			return { sport = chosen.name, sportEmoji = chosen.emoji }
		end,
		getDynamicEmoji = function(data) return data.sportEmoji or "⚽" end,
		text = "Coach says you're a natural at %sport%! You're way ahead of other kids!",
		choices = {
			{ text = "🏆 Train seriously!", effects = { Happiness = 15, Health = 8, Smarts = 2 }, resultText = "Daily practice begins! You're getting really good!", setFlags = {"athlete", "serious_athlete"} },
			{ text = "🎮 Prefer video games", effects = { Happiness = 8, Health = -2 }, resultText = "Sports are okay but gaming is more fun!" },
			{ text = "🏅 Dream of going pro", effects = { Happiness = 12, Health = 5 }, resultText = "One day you'll play in the big leagues!", setFlags = {"athlete", "pro_dreams"} },
			{ text = "⚖️ Balance with school", effects = { Happiness = 10, Health = 5, Smarts = 5 }, resultText = "Athletics AND academics. Well-rounded approach.", setFlag = "athlete" },
		},
	},
	
	{
		id = "sports_youth_league_star",
		minAge = 10, maxAge = 16,
		weight = 25, cooldown = 2,
		emoji = "🌟", title = "Youth League MVP!",
		category = "school",
		requiresFlag = "athlete",
		getDynamicData = function()
			local stats = {"scored the winning goal", "set a league record", "led your team to the championship", "got a perfect score", "dominated every game"}
			return { achievement = stats[math.random(#stats)] }
		end,
		text = "You %achievement%! Named Youth League MVP!",
		choices = {
			{ text = "🏆 Best feeling ever!", effects = { Happiness = 20, Health = 5, Looks = 3 }, resultText = "The trophy, the cheers... you were born for this!", setFlag = "mvp" },
			{ text = "🤝 Team effort", effects = { Happiness = 15, Smarts = 3 }, resultText = "Couldn't have done it without your teammates. Humble champion.", setFlag = "team_player" },
			{ text = "👀 Scouts are watching", effects = { Happiness = 18, Smarts = 2 }, resultText = "College and pro scouts noticed you! Pressure is on!", setFlags = {"mvp", "scouted"} },
			{ text = "😤 Want more", effects = { Happiness = 12, Health = 3 }, resultText = "MVP isn't enough. You want championships.", setFlags = {"mvp", "competitive"} },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- HIGH SCHOOL / COLLEGE SPORTS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "sports_varsity",
		minAge = 14, maxAge = 18,
		weight = 25, oneTime = true,
		emoji = "🏈", title = "Made Varsity!",
		category = "school",
		requiresFlag = "athlete",
		text = "You made the varsity team as an underclassman! Big deal at your school!",
		choices = {
			{ text = "🌟 Became the star", effects = { Happiness = 25, Health = 5, Looks = 5 }, resultText = "Best player on the team! Everyone knows your name!", setFlags = {"varsity_star", "popular"} },
			{ text = "📺 Local news feature", effects = { Happiness = 20, Looks = 3 }, resultText = "Local paper did a story on you! Mini celebrity!", setFlags = {"varsity_star", "local_fame"} },
			{ text = "🤕 Got injured", effects = { Happiness = -15, Health = -10 }, resultText = "Torn ACL. Season over. Will you recover?", setFlags = {"injured_athlete"}, clearFlag = "varsity_star" },
			{ text = "📚 Grades suffered", effects = { Happiness = 10, Smarts = -5 }, resultText = "Too focused on sports. Academic probation warning.", setFlag = "varsity_star" },
		},
	},
	
	{
		id = "sports_scholarship",
		minAge = 17, maxAge = 18,
		weight = 20, oneTime = true,
		emoji = "🎓", title = "Athletic Scholarship!",
		category = "school",
		requiresFlag = "varsity_star",
		getDynamicData = function()
			local schools = {"Duke", "UCLA", "Ohio State", "Alabama", "Stanford", "Michigan", "Texas"}
			return { school = schools[math.random(#schools)] }
		end,
		text = "%school% is offering you a FULL athletic scholarship!",
		choices = {
			{ text = "🎓 Full ride!", effects = { Happiness = 30, Money = 100000, Smarts = 3 }, resultText = "Free college! D1 athlete! Dream come true!", setFlags = {"college_athlete", "scholarship"} },
			{ text = "📋 Multiple offers", effects = { Happiness = 28, Money = 100000, Smarts = 5 }, resultText = "Choosing between schools! Recruiting wars!", setFlags = {"college_athlete", "highly_recruited"} },
			{ text = "😰 Pressure intense", effects = { Happiness = 15, Money = 100000, Health = -3 }, resultText = "Everyone expects you to go pro. Heavy expectations.", setFlags = {"college_athlete", "high_expectations"} },
			{ text = "❌ Academic requirements", effects = { Happiness = -10, Smarts = -2 }, resultText = "Didn't meet academic standards. Scholarship lost.", clearFlag = "varsity_star" },
		},
	},
	
	{
		id = "sports_college_injury",
		minAge = 18, maxAge = 22,
		weight = 20, cooldown = 3,
		emoji = "🏥", title = "Career-Threatening Injury!",
		category = "health",
		requiresFlag = "college_athlete",
		getDynamicData = function()
			local injuries = {"torn ACL", "broken ankle", "shoulder separation", "back injury", "concussion"}
			return { injury = injuries[math.random(#injuries)] }
		end,
		text = "You suffered a %injury% during the big game. This could end everything.",
		choices = {
			{ text = "💪 Full recovery!", effects = { Happiness = 15, Health = 5 }, resultText = "Rehab was brutal but you're back! Stronger than ever!", setFlag = "comeback_story" },
			{ text = "😔 Never the same", effects = { Happiness = -20, Health = -10 }, resultText = "Lost a step. Not the player you were before.", setFlag = "diminished" },
			{ text = "🔄 Different position", effects = { Happiness = 5, Health = -5, Smarts = 5 }, resultText = "Adapted your game. Different but still competitive." },
			{ text = "💔 Career over", effects = { Happiness = -30, Health = -15 }, resultText = "The injury was too severe. Dreams shattered.", clearFlags = {"college_athlete", "scholarship"}, setFlag = "career_ending_injury" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- PROFESSIONAL CAREER
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "sports_draft_day",
		minAge = 20, maxAge = 24,
		weight = 15, oneTime = true,
		emoji = "📺", title = "DRAFT DAY!",
		category = "work",
		requiresFlag = "college_athlete",
		blockIfFlag = "career_ending_injury",
		getDynamicData = function()
			local rounds = {1, 2, 3, 4, 5}
			local pick = math.random(1, 30)
			return { round = rounds[math.random(#rounds)], pick = pick }
		end,
		text = "The professional draft is today! Your whole family is watching!",
		choices = {
			{ text = "📞 Round 1 pick!", effects = { Happiness = 40, Money = 5000000, Looks = 5 }, resultText = "YOUR NAME IS CALLED! First round! Millions guaranteed!", setFlags = {"pro_athlete", "first_rounder"} },
			{ text = "📺 Later round pick", effects = { Happiness = 25, Money = 500000 }, resultText = "Not first round but you're IN! Prove them wrong!", setFlags = {"pro_athlete", "chip_on_shoulder"} },
			{ text = "😰 Undrafted", effects = { Happiness = -20, Smarts = 5 }, resultText = "Name never called. Devastating. But free agent route exists.", setFlag = "undrafted" },
			{ text = "🌍 Overseas offer", effects = { Happiness = 15, Money = 200000 }, resultText = "Not the NFL/NBA but playing professionally in Europe!", setFlag = "overseas_pro" },
		},
	},
	
	{
		id = "sports_rookie_season",
		minAge = 21, maxAge = 26,
		weight = 25, cooldown = 2,
		emoji = "⭐", title = "Rookie Season!",
		category = "work",
		requiresFlag = "pro_athlete",
		text = "Your first professional season! Time to prove you belong!",
		choices = {
			{ text = "🏆 Rookie of the Year!", effects = { Happiness = 35, Money = 1000000, Looks = 5 }, resultText = "ROTY! Exceeded all expectations! Superstar in the making!", setFlags = {"roty", "superstar"} },
			{ text = "📈 Solid contributor", effects = { Happiness = 20, Money = 500000 }, resultText = "Good rookie year. Building towards something bigger.", setFlag = "solid_pro" },
			{ text = "🪑 Mostly bench", effects = { Happiness = -5, Money = 200000 }, resultText = "Didn't get much playing time. Need to develop." },
			{ text = "😔 Struggled hard", effects = { Happiness = -15, Money = 150000, Health = -5 }, resultText = "The jump to pro level was harder than expected. Doubt creeping in." },
		},
	},
	
	{
		id = "sports_big_contract",
		minAge = 24, maxAge = 35,
		weight = 15, oneTime = true,
		emoji = "💰", title = "MEGA CONTRACT!",
		category = "work",
		requiresFlag = "superstar",
		getDynamicData = function()
			local years = math.random(3, 6)
			local amount = math.random(100, 300)
			return { years = years, amount = amount }
		end,
		text = "You're a free agent and teams are bidding! Offers of $%amount% MILLION over %years% years!",
		choices = {
			{ text = "💰 MAX CONTRACT!", effects = { Happiness = 40, Money = 50000000 }, resultText = "Richest contract in history! Generational wealth!", setFlags = {"max_contract", "wealthy_athlete"} },
			{ text = "🏆 Chase rings", effects = { Happiness = 30, Money = 20000000 }, resultText = "Took less to join a contender. Championships matter more.", setFlag = "ring_chaser" },
			{ text = "🏠 Hometown discount", effects = { Happiness = 35, Money = 30000000 }, resultText = "Stayed loyal to your city. Fans love you forever.", setFlags = {"loyal_player", "hometown_hero"} },
			{ text = "😤 Holdout drama", effects = { Happiness = 10, Money = 40000000 }, resultText = "Contentious negotiations. Got the money but fans are upset." },
		},
	},
	
	{
		id = "sports_championship",
		minAge = 22, maxAge = 40,
		weight = 10, oneTime = true,
		emoji = "🏆", title = "CHAMPIONSHIP GAME!",
		category = "work",
		requiresFlag = "pro_athlete",
		text = "THE CHAMPIONSHIP! This is what you've worked your entire life for!",
		choices = {
			{ text = "🏆 CHAMPION!", effects = { Happiness = 50, Money = 2000000, Looks = 10 }, resultText = "YOU DID IT! Confetti falling! Holding the trophy! CHAMPION!", setFlags = {"champion", "ring_winner"} },
			{ text = "🌟 MVP performance!", effects = { Happiness = 55, Money = 3000000, Looks = 10 }, resultText = "Championship MVP! Legendary performance! Your name is immortal!", setFlags = {"champion", "finals_mvp", "legendary"} },
			{ text = "💔 Lost the final", effects = { Happiness = -25, Health = -5 }, resultText = "So close. The loss haunts you. Will you get another chance?" },
			{ text = "🤕 Injured in game", effects = { Happiness = -15, Health = -15 }, resultText = "Got hurt in the championship. Watched from sidelines.", setFlag = "championship_injury" },
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
		text = "You're competing in the Olympic trials! A chance to represent your country!",
		choices = {
			{ text = "🎉 Made the team!", effects = { Happiness = 40, Health = 5, Looks = 5 }, resultText = "YOU'RE AN OLYMPIAN! Going to the Olympics!", setFlags = {"olympian", "national_team"} },
			{ text = "😔 Just missed", effects = { Happiness = -15, Smarts = 5 }, resultText = "4th place. So close. Four more years..." },
			{ text = "📺 World watching", effects = { Happiness = 30, Looks = 3 }, resultText = "Even though you didn't win, sponsors noticed you!", setFlags = {"olympian", "sponsor_attention"} },
			{ text = "🤕 Injury at worst time", effects = { Happiness = -20, Health = -10 }, resultText = "Got hurt during trials. Olympic dream delayed.", setFlag = "injured_olympian" },
		},
	},
	
	{
		id = "sports_olympic_medal",
		minAge = 16, maxAge = 40,
		weight = 8, oneTime = true,
		emoji = "🥇", title = "OLYMPIC MEDAL!",
		category = "work",
		requiresFlag = "olympian",
		getDynamicData = function()
			local medals = {
				{ type = "gold", emoji = "🥇", points = 50 },
				{ type = "silver", emoji = "🥈", points = 35 },
				{ type = "bronze", emoji = "🥉", points = 25 },
			}
			local chosen = medals[math.random(#medals)]
			return { medal = chosen.type, medalEmoji = chosen.emoji }
		end,
		getDynamicEmoji = function(data) return data.medalEmoji or "🏅" end,
		text = "The Olympic final! Everything you've trained for comes down to this!",
		choices = {
			{ text = "🥇 GOLD MEDAL!", effects = { Happiness = 60, Money = 1000000, Looks = 10 }, resultText = "OLYMPIC CHAMPION! National anthem plays! Tears streaming! LEGENDARY!", setFlags = {"olympic_gold", "national_hero"} },
			{ text = "🥈 Silver medal", effects = { Happiness = 35, Money = 500000 }, resultText = "Second in the WORLD. Incredible achievement. So proud.", setFlag = "olympic_medalist" },
			{ text = "🥉 Bronze medal", effects = { Happiness = 30, Money = 300000 }, resultText = "On the podium! An Olympic medalist forever!", setFlag = "olympic_medalist" },
			{ text = "4️⃣ Fourth place", effects = { Happiness = -20 }, resultText = "So close to a medal. The cruelest place to finish." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- CAREER END / LEGACY
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "sports_decline",
		minAge = 30, maxAge = 42,
		weight = 25, cooldown = 3,
		emoji = "📉", title = "Athletic Decline",
		category = "work",
		requiresFlag = "pro_athlete",
		text = "You're not as fast as you used to be. Father Time is undefeated.",
		choices = {
			{ text = "💪 Adapt your game", effects = { Happiness = 10, Smarts = 5 }, resultText = "Can't rely on athleticism anymore. Playing smarter.", setFlag = "veteran_savvy" },
			{ text = "😔 Losing roster spot", effects = { Happiness = -15, Money = -500000 }, resultText = "Younger players taking your minutes. Writing on the wall." },
			{ text = "🏆 One last run", effects = { Happiness = 15, Health = -5 }, resultText = "Pushing your body for one more championship attempt.", setFlag = "last_dance" },
			{ text = "📺 Become a mentor", effects = { Happiness = 12, Smarts = 3 }, resultText = "Helping young players. Your experience is valuable.", setFlag = "veteran_mentor" },
		},
	},
	
	{
		id = "sports_retirement",
		minAge = 32, maxAge = 45,
		weight = 20, oneTime = true,
		emoji = "🎤", title = "Retirement Press Conference",
		category = "work",
		requiresFlag = "pro_athlete",
		text = "The day has come. Time to hang it up. Press conference scheduled.",
		choices = {
			{ text = "😭 Emotional goodbye", effects = { Happiness = 20, Health = 5 }, resultText = "Tears, standing ovation, thank yous. Beautiful send-off.", clearFlag = "pro_athlete", setFlags = {"retired_athlete", "beloved"} },
			{ text = "🏆 Going out on top", effects = { Happiness = 30, Looks = 3 }, resultText = "Won the championship and retired. Perfect ending.", clearFlag = "pro_athlete", setFlags = {"retired_athlete", "legendary"} },
			{ text = "😔 Forced out", effects = { Happiness = -10 }, resultText = "No team wanted you. Career ended quietly.", clearFlag = "pro_athlete", setFlag = "retired_athlete" },
			{ text = "🔄 Actually, comeback!", effects = { Happiness = 10, Health = -5 }, resultText = "Changed your mind! One more season!", setFlag = "comeback" },
		},
	},
	
	{
		id = "sports_hall_of_fame",
		minAge = 40, maxAge = 80,
		weight = 8, oneTime = true,
		emoji = "🏛️", title = "HALL OF FAME!",
		category = "work",
		requiresFlag = "legendary",
		text = "You're being inducted into the Hall of Fame!",
		choices = {
			{ text = "😭 Greatest honor", effects = { Happiness = 50, Looks = 5 }, resultText = "Your name is immortalized forever. Legendary status confirmed.", setFlag = "hall_of_famer" },
			{ text = "🎤 Amazing speech", effects = { Happiness = 45, Smarts = 5 }, resultText = "Your speech moved everyone to tears. Unforgettable moment.", setFlag = "hall_of_famer" },
			{ text = "👨‍👩‍👧 Family moment", effects = { Happiness = 48 }, resultText = "Seeing your family's pride. This is what it was all for.", setFlag = "hall_of_famer" },
			{ text = "🙏 Thank the fans", effects = { Happiness = 45, Looks = 3 }, resultText = "Without the fans, none of this matters. Gratitude forever.", setFlag = "hall_of_famer" },
		},
	},
	
	{
		id = "sports_coaching",
		minAge = 35, maxAge = 65,
		weight = 20, oneTime = true,
		emoji = "📋", title = "Coaching Offer",
		category = "work",
		requiresFlag = "retired_athlete",
		getDynamicData = function()
			local levels = {"a college team", "a professional team", "your old team", "a youth program", "a national team"}
			return { level = levels[math.random(#levels)] }
		end,
		text = "%level% wants you as their coach! Staying in the game!",
		choices = {
			{ text = "📋 Born to coach!", effects = { Happiness = 25, Money = 500000 }, resultText = "Leading the next generation! Different kind of competition!", setFlags = {"coach", "employed"} },
			{ text = "🏆 Championship coach!", effects = { Happiness = 35, Money = 1000000 }, resultText = "Won it as a player AND coach! Rare air!", setFlags = {"coach", "championship_coach"} },
			{ text = "😔 Harder than playing", effects = { Happiness = 5, Health = -5 }, resultText = "Managing egos, politics... miss just playing." },
			{ text = "🏖️ Enjoy retirement", effects = { Happiness = 15, Health = 5 }, resultText = "Thanks but no. Enjoying life off the field." },
		},
	},
}

return module
