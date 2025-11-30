-- LifeEvents/fame.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- FAME & CELEBRITY EVENTS
-- Social Media, Influencers, Reality TV, Paparazzi - The spotlight life
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent.init)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- SOCIAL MEDIA JOURNEY
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "fame_first_viral",
		minAge = 13, maxAge = 50,
		weight = 15, oneTime = true,
		emoji = "📱", title = "Your First Viral Moment!",
		category = "social",
		getDynamicData = function()
			local content = {"a funny video", "a hot take tweet", "a dance challenge", "a cooking fail", "a pet video", "an embarrassing moment"}
			local views = math.random(100, 5000)
			return { content = content[math.random(#content)], views = views }
		end,
		text = "You posted %content% and it got %views%K views! Going viral!",
		choices = {
			{ text = "😲 This is insane!", effects = { Happiness = 25, Looks = 3 }, resultText = "Notifications blowing up! People sharing it everywhere! VIRAL!", setFlags = {"went_viral", "social_media_presence"} },
			{ text = "📈 Capitalize on it!", effects = { Happiness = 20, Money = 1000, Smarts = 5 }, resultText = "Quick follow-up content! Growing the audience! Smart move!", setFlags = {"went_viral", "content_creator"} },
			{ text = "😰 Wrong kind of attention", effects = { Happiness = -10, Looks = -3 }, resultText = "It went viral for the WRONG reasons. Memes about you. Mortifying.", setFlag = "viral_embarrassment" },
			{ text = "🤷 Delete it", effects = { Happiness = 5 }, resultText = "Too much attention. Deleted everything. Privacy matters." },
		},
	},
	
	{
		id = "fame_influencer_journey",
		minAge = 16, maxAge = 40,
		weight = 20, cooldown = 3,
		emoji = "⭐", title = "Influencer Growth!",
		category = "work",
		requiresFlag = "content_creator",
		getDynamicData = function()
			local followers = math.random(10, 500)
			local platforms = {"TikTok", "Instagram", "YouTube", "Twitch", "Twitter"}
			return { followers = followers, platform = platforms[math.random(#platforms)] }
		end,
		text = "You hit %followers%K followers on %platform%! Growing fast!",
		choices = {
			{ text = "📊 Full-time creator!", effects = { Happiness = 25, Money = 50000 }, resultText = "Quit your job! Living the dream! Content is life now!", setFlags = {"influencer", "full_time_creator"} },
			{ text = "💰 Brand deals rolling in!", effects = { Happiness = 22, Money = 30000 }, resultText = "Sponsors want you! Getting paid to post! Wild!", setFlags = {"influencer", "sponsored"} },
			{ text = "😰 Burnout incoming", effects = { Happiness = -5, Health = -5 }, resultText = "Algorithm pressure! Always creating! Can't stop or you'll die!", setFlags = {"influencer", "creator_burnout"} },
			{ text = "🎯 Stayed authentic", effects = { Happiness = 20, Smarts = 5 }, resultText = "Didn't sell out. Slower growth but real community.", setFlags = {"influencer", "authentic"} },
		},
	},
	
	{
		id = "fame_million_followers",
		minAge = 16, maxAge = 50,
		weight = 8, oneTime = true,
		emoji = "💫", title = "ONE MILLION FOLLOWERS!",
		category = "work",
		requiresFlag = "influencer",
		text = "1,000,000 followers! You're officially a major influencer!",
		choices = {
			{ text = "🎉 MEGA INFLUENCER!", effects = { Happiness = 40, Money = 200000, Looks = 5 }, resultText = "Seven figures of fans! Brand deals worth hundreds of thousands! MADE IT!", setFlags = {"mega_influencer", "famous"} },
			{ text = "🔔 YouTube play button!", effects = { Happiness = 35, Money = 150000 }, resultText = "Gold play button in hand! Real recognition! Dreams come true!", setFlags = {"mega_influencer", "youtuber"} },
			{ text = "😰 Can't handle it", effects = { Happiness = 15, Money = 100000, Health = -10 }, resultText = "Too much. Can't read comments. Anxiety through the roof.", setFlags = {"mega_influencer", "overwhelmed"} },
			{ text = "💎 Built a business", effects = { Happiness = 30, Money = 500000, Smarts = 8 }, resultText = "Launched merch, courses, app! Diversified! Real CEO!", setFlags = {"mega_influencer", "creator_ceo"} },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- REALITY TV
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "fame_reality_show",
		minAge = 18, maxAge = 45,
		weight = 10, oneTime = true,
		emoji = "📺", title = "Reality TV Casting!",
		category = "work",
		getDynamicData = function()
			local shows = {"a dating show", "a competition show", "a house show", "a talent show", "a makeover show"}
			return { show = shows[math.random(#shows)] }
		end,
		text = "Producers want you for %show%! National TV exposure!",
		choices = {
			{ text = "⭐ Became the star!", effects = { Happiness = 30, Money = 50000, Looks = 8 }, resultText = "Fan favorite! Everyone knows your catchphrase! Reality TV legend!", setFlags = {"reality_star", "famous"} },
			{ text = "😈 Villain edit", effects = { Happiness = 10, Money = 30000, Looks = -5 }, resultText = "They made you the villain! Hate-famous but... still famous?", setFlags = {"reality_star", "controversial"} },
			{ text = "💔 Eliminated early", effects = { Happiness = -10, Money = 5000 }, resultText = "First one out. Brief fame. Back to normal life." },
			{ text = "🏆 Won the whole thing!", effects = { Happiness = 45, Money = 250000, Looks = 10 }, resultText = "WINNER! Prize money! Career launched! Set for life!", setFlags = {"reality_champion", "famous"} },
		},
	},
	
	{
		id = "fame_dating_show_love",
		minAge = 21, maxAge = 40,
		weight = 8, oneTime = true,
		emoji = "💕", title = "Reality TV Romance!",
		category = "social",
		requiresFlag = "reality_star",
		getDynamicData = function()
			return { loverName = LifeEvents.randomFirstName() }
		end,
		text = "You fell in love with %loverName% on the show! Cameras caught everything!",
		choices = {
			{ text = "💍 Still together!", effects = { Happiness = 35, Looks = 3 }, resultText = "Defied the odds! Reality TV couple that actually lasted! People magazine!", setFlags = {"reality_couple", "famous_relationship"}, addRelationship = { category = "romantic", dynamicNameKey = "loverName", startingRelationship = 85, type = "partner" } },
			{ text = "💔 Broke up on camera", effects = { Happiness = -15, Looks = -2 }, resultText = "Filmed the breakup for season 2. Humiliating. But ratings gold." },
			{ text = "📰 Tabloid obsession", effects = { Happiness = 10, Money = 20000 }, resultText = "Your relationship is public property now. Exhausting but lucrative.", setFlags = {"tabloid_couple"}, addRelationship = { category = "romantic", dynamicNameKey = "loverName", startingRelationship = 70, type = "partner" } },
			{ text = "🤫 Kept it private", effects = { Happiness = 25 }, resultText = "Stopped filming your relationship. Some things aren't content.", addRelationship = { category = "romantic", dynamicNameKey = "loverName", startingRelationship = 75, type = "partner" } },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- DEALING WITH FAME
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "fame_paparazzi",
		minAge = 18, maxAge = 70,
		weight = 20, cooldown = 3,
		emoji = "📸", title = "Paparazzi!",
		category = "social",
		requiresFlag = "famous",
		text = "Paparazzi everywhere! Can't go anywhere without being photographed!",
		choices = {
			{ text = "😤 Confronted them", effects = { Happiness = -5, Looks = -3 }, resultText = "Yelled at them. Now THAT's the story. Angry celeb meltdown.", setFlag = "paparazzi_incident" },
			{ text = "🕶️ Master of disguise", effects = { Happiness = 10, Smarts = 5 }, resultText = "Wigs, sunglasses, decoys. Can still have a life sometimes.", setFlag = "privacy_savvy" },
			{ text = "📸 Posed and smiled", effects = { Happiness = 5, Looks = 5 }, resultText = "Give them what they want. Control the narrative. Media trained.", setFlag = "media_trained" },
			{ text = "😔 It's exhausting", effects = { Happiness = -15, Health = -5 }, resultText = "No privacy. No normal moments. Fame has a price." },
		},
	},
	
	{
		id = "fame_cancel_culture",
		minAge = 16, maxAge = 60,
		weight = 15, cooldown = 4,
		emoji = "🚫", title = "Getting Cancelled!",
		category = "social",
		requiresFlag = "famous",
		getDynamicData = function()
			local reasons = {"old tweets resurfaced", "a hot mic moment leaked", "controversial opinion", "association with problematic person", "tone deaf post"}
			return { reason = reasons[math.random(#reasons)] }
		end,
		text = "CANCELLED! %reason%! #IsOverParty trending! Sponsors dropping!",
		choices = {
			{ text = "📱 Apologized sincerely", effects = { Happiness = -10, Looks = -3, Smarts = 5 }, resultText = "Owned it. Learned from it. Slow comeback possible.", setFlag = "survived_cancel" },
			{ text = "😤 Doubled down", effects = { Happiness = 5, Looks = -5, Money = -50000 }, resultText = "Refused to apologize! Lost mainstream but gained loyal fans.", setFlags = {"controversial", "uncancellable"} },
			{ text = "😔 Disappeared", effects = { Happiness = -25, Health = -10 }, resultText = "Off social media. The mob won. Mental health destroyed.", setFlags = {"cancelled", "retired_fame"} },
			{ text = "🎭 Comeback era", effects = { Happiness = 15, Money = 30000 }, resultText = "Year later, apology tour, documentary. Public loves a redemption arc!", setFlags = {"survived_cancel", "comeback"} },
		},
	},
	
	{
		id = "fame_stalker",
		minAge = 18, maxAge = 70,
		weight = 10, cooldown = 5,
		emoji = "😰", title = "Stalker Situation",
		category = "social",
		requiresFlag = "famous",
		text = "Someone's been following you. Showing up everywhere. Police involved.",
		choices = {
			{ text = "🚔 Restraining order", effects = { Happiness = -15, Money = -10000, Health = -5 }, resultText = "Legal protection but... the fear doesn't go away.", setFlag = "stalker_victim" },
			{ text = "🔐 Full security now", effects = { Happiness = -10, Money = -50000 }, resultText = "Bodyguards everywhere. Necessary but isolating.", setFlags = {"security_detail"} },
			{ text = "😱 Terrifying close call", effects = { Happiness = -25, Health = -15 }, resultText = "They got too close. Will never feel safe again.", setFlags = {"stalker_victim", "trauma"} },
			{ text = "😔 Questioning fame", effects = { Happiness = -20, Smarts = 5 }, resultText = "Is this worth it? Fame came at the cost of feeling safe." },
		},
	},
	
	{
		id = "fame_substance_abuse",
		minAge = 18, maxAge = 60,
		weight = 15, cooldown = 5,
		emoji = "💊", title = "Fame's Dark Side",
		category = "health",
		requiresFlag = "famous",
		text = "The pressure. The parties. The access. Substances becoming a problem.",
		choices = {
			{ text = "🏥 Got help early", effects = { Happiness = 10, Health = 10, Smarts = 5 }, resultText = "Recognized the signs. Went to rehab. Saved yourself.", setFlag = "recovery" },
			{ text = "😔 Spiraling", effects = { Happiness = -30, Health = -20, Money = -100000 }, resultText = "Lost control. Tabloid headlines. Career in jeopardy.", setFlags = {"addiction", "tabloid_fodder"} },
			{ text = "🎤 Spoke publicly about it", effects = { Happiness = 15, Health = 5, Looks = 3 }, resultText = "Used platform to help others. Destigmatizing. Brave.", setFlags = {"recovery", "mental_health_advocate"} },
			{ text = "💔 Lost someone close", effects = { Happiness = -35, Health = -10 }, resultText = "Wake up call in the worst way. Never again. For them.", setFlags = {"recovery", "grief"} },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- FAME ACHIEVEMENTS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "fame_award_show",
		minAge = 18, maxAge = 70,
		weight = 12, cooldown = 3,
		emoji = "🏆", title = "Award Nomination!",
		category = "work",
		requiresFlag = "famous",
		getDynamicData = function()
			local awards = {"People's Choice", "MTV Award", "Grammy", "Emmy", "Oscar", "Golden Globe"}
			return { award = awards[math.random(#awards)] }
		end,
		text = "You're nominated for a %award%! Red carpet awaits!",
		choices = {
			{ text = "🏆 WON!", effects = { Happiness = 45, Money = 100000, Looks = 10 }, resultText = "YOUR NAME CALLED! Speech time! Holding the trophy! PEAK FAME!", setFlags = {"award_winner", "legendary"} },
			{ text = "📸 Best dressed!", effects = { Happiness = 30, Looks = 8, Money = 50000 }, resultText = "Your outfit went viral! Fashion icon status!", setFlag = "style_icon" },
			{ text = "😊 Honor to be nominated", effects = { Happiness = 20, Looks = 3 }, resultText = "Didn't win but... being there is incredible. Next time." },
			{ text = "🎤 Memorable speech", effects = { Happiness = 40, Smarts = 5 }, resultText = "Your acceptance speech moved millions. More than the award.", setFlags = {"award_winner", "eloquent"} },
		},
	},
	
	{
		id = "fame_documentary",
		minAge = 25, maxAge = 70,
		weight = 10, oneTime = true,
		emoji = "🎬", title = "Documentary About You!",
		category = "work",
		requiresFlag = "mega_influencer",
		getDynamicData = function()
			local streamers = {"Netflix", "HBO", "Amazon", "YouTube", "Hulu"}
			return { streamer = streamers[math.random(#streamers)] }
		end,
		text = "%streamer% wants to make a documentary about your life!",
		choices = {
			{ text = "📺 Revealing everything", effects = { Happiness = 25, Money = 500000, Smarts = 3 }, resultText = "Raw and honest. Critics loved it. New respect earned.", setFlags = {"documentary_subject", "legacy"} },
			{ text = "😰 Too invasive", effects = { Happiness = -10, Money = 300000 }, resultText = "They dug too deep. Regret participating. Some things should stay private." },
			{ text = "💰 Record payday", effects = { Happiness = 30, Money = 2000000 }, resultText = "Controlled the narrative AND got paid! Win-win!", setFlags = {"documentary_subject", "smart_celebrity"} },
			{ text = "🎬 Career resurgence", effects = { Happiness = 35, Looks = 5 }, resultText = "New generation discovered you! Relevance restored!", setFlags = {"documentary_subject", "comeback"} },
		},
	},
	
	{
		id = "fame_hall_of_fame_social",
		minAge = 30, maxAge = 70,
		weight = 5, oneTime = true,
		emoji = "⭐", title = "Social Media Pioneer",
		category = "work",
		requiresFlag = "mega_influencer",
		text = "You're being recognized as a pioneer of social media! First generation of influencers!",
		choices = {
			{ text = "🏆 Legacy secured", effects = { Happiness = 40, Looks = 5 }, resultText = "Interviews about the early days. You helped create an industry.", setFlag = "pioneer" },
			{ text = "📚 Wrote the book", effects = { Happiness = 35, Money = 500000, Smarts = 5 }, resultText = "Your guide to building a following is a bestseller!", setFlags = {"pioneer", "author"} },
			{ text = "🎓 Teaching others", effects = { Happiness = 30, Money = 200000 }, resultText = "Consulting, courses, mentoring. Passing on what you learned.", setFlags = {"pioneer", "mentor"} },
			{ text = "😔 Bittersweet", effects = { Happiness = 20, Smarts = 5 }, resultText = "Pioneer of an industry that broke your mental health. Complicated legacy." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- FADING FAME / LEGACY
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "fame_relevance",
		minAge = 30, maxAge = 60,
		weight = 20, cooldown = 4,
		emoji = "📉", title = "Fading Relevance",
		category = "social",
		requiresFlag = "famous",
		getDynamicData = function()
			local reasons = {"younger creators taking over", "algorithm changes", "platform dying", "content feels dated", "audience grew up"}
			return { reason = reasons[math.random(#reasons)] }
		end,
		text = "Numbers dropping. %reason%. Are your 15 minutes over?",
		choices = {
			{ text = "🔄 Reinvented!", effects = { Happiness = 20, Looks = 3, Smarts = 5 }, resultText = "New platform, new style, new audience! Evolution is survival!", setFlag = "reinvented" },
			{ text = "😔 Accepting it", effects = { Happiness = -5, Smarts = 5 }, resultText = "Good run. Not everyone stays famous forever. Moving on.", setFlag = "former_famous" },
			{ text = "😤 Desperate content", effects = { Happiness = -10, Looks = -5 }, resultText = "Doing anything for views. Dignity fading. Is it worth it?" },
			{ text = "💼 Business pivot", effects = { Happiness = 15, Money = 100000, Smarts = 8 }, resultText = "Built a business while famous. Fame was a means to an end.", setFlags = {"business_owner", "smart_exit"} },
		},
	},
	
	{
		id = "fame_legacy_reflection",
		minAge = 50, maxAge = 90,
		weight = 15, oneTime = true,
		emoji = "📖", title = "Fame Legacy",
		category = "social",
		requiresFlag = "famous",
		text = "Looking back on your time in the spotlight. What did it all mean?",
		choices = {
			{ text = "🌟 Changed the game", effects = { Happiness = 35, Smarts = 5 }, resultText = "You influenced culture. People quote you. Impact is immortal.", setFlag = "cultural_icon" },
			{ text = "💔 Cost too much", effects = { Happiness = -10, Smarts = 8 }, resultText = "Missed too much. Relationships sacrificed. Fame isn't free." },
			{ text = "😊 Worth every moment", effects = { Happiness = 40 }, resultText = "The experiences, the connections, the platform. No regrets. Magic life.", setFlag = "gratful_celebrity" },
			{ text = "📚 Wrote memoirs", effects = { Happiness = 30, Money = 1000000, Smarts = 5 }, resultText = "Your story in your words. Bestseller. Final control of the narrative.", setFlags = {"memoirist", "author"} },
		},
	},
}

return module
