-- LifeEvents/fame.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- FAME & CELEBRITY EVENTS
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
	-- EARLY FAME / SOCIAL MEDIA
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "fame_first_viral",
		minAge = 13, maxAge = 35,
		weight = 20, oneTime = true,
		emoji = "📱", title = "Post Going Viral!",
		category = "social",
		getDynamicData = function()
			local types = {"a funny video", "a photo", "a hot take", "a dance", "a meme you made"}
			return { postType = types[math.random(#types)] }
		end,
		text = "You posted %postType% and it's BLOWING UP! 100k views and climbing! What do you do?",
		choices = {
			{ text = "📈 Ride the wave!", effects = { Happiness = 25, Looks = 5 }, resultText = "Posted more! Building followers! Influencer arc begins!", setFlags = {"viral_creator", "social_media_famous"} },
			{ text = "😱 Delete from embarrassment", effects = { Happiness = -10 }, resultText = "Took it down! Too much attention! But screenshots live forever..." },
			{ text = "💰 Try to monetize", effects = { Happiness = 15, Money = 500 }, resultText = "Brands reaching out! Small sponsorship! Making money from content!", setFlags = {"viral_creator", "content_monetizer"} },
			{ text = "🤷 Ignore it", effects = { Happiness = 5 }, resultText = "One-hit wonder. Didn't capitalize. Followers came and went." },
		},
	},
	
	{
		id = "fame_influencer_grind",
		minAge = 15, maxAge = 40,
		weight = 18, cooldown = 3,
		emoji = "📸", title = "Influencer Life!",
		category = "social",
		requiresFlag = "viral_creator",
		text = "Building your following! Content creation is exhausting. The algorithm demands constant posts! What's your approach?",
		choices = {
			{ text = "📱 Post everything daily", effects = { Happiness = 10, Looks = 5, Health = -8 }, resultText = "Followers growing! But no privacy, no breaks. Is this sustainable?", setFlags = {"influencer", "always_on"} },
			{ text = "🎯 Quality over quantity", effects = { Happiness = 15, Looks = 3 }, resultText = "Fewer posts but better. Audience respects it. Growing slower but loyal!", setFlags = {"influencer", "quality_creator"} },
			{ text = "😔 Burning out", effects = { Happiness = -15, Health = -10 }, resultText = "The constant performance is exhausting. Taking a break. Followers disappointed." },
			{ text = "💼 Hire a team", effects = { Happiness = 18, Money = -5000, Looks = 5 }, resultText = "Manager, photographer, editor! Professional operation! Scaling up!", setFlags = {"influencer", "professional_creator"} },
		},
	},
	
	{
		id = "fame_brand_deal",
		minAge = 18, maxAge = 50,
		weight = 15, cooldown = 3,
		emoji = "💰", title = "Brand Deal Offer!",
		category = "social",
		requiresFlag = "influencer",
		getDynamicData = function()
			local brands = {"a makeup brand", "a fashion company", "an energy drink", "a tech company", "a fitness brand"}
			local amounts = {5000, 15000, 30000, 50000}
			return { brand = brands[math.random(#brands)], amount = amounts[math.random(#amounts)] }
		end,
		text = "%brand% wants to sponsor you! $%amount% for posts and promotion! What do you do?",
		choices = {
			{ text = "✅ Take the money!", effects = { Happiness = 20, Money = 25000, Looks = 3 }, resultText = "Easy money! Posts did well! They want more!", setFlags = {"sponsored", "sellout"} },
			{ text = "📋 Negotiate higher", effects = { Happiness = 18, Money = 40000 }, resultText = "Got way more! Know your worth! They needed you!", setFlag = "sponsored" },
			{ text = "🙅 Doesn't fit my brand", effects = { Happiness = 8, Smarts = 5 }, resultText = "Turned it down. Audience respects authenticity. Right call?", setFlag = "authentic_creator" },
			{ text = "⚠️ Bad product, took deal", effects = { Happiness = -10, Money = 20000, Looks = -5 }, resultText = "Product was garbage. Followers mad. Lost trust for money. Worth it?" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- RISING FAME
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "fame_million_followers",
		minAge = 16, maxAge = 50,
		weight = 10, oneTime = true,
		emoji = "🎉", title = "1 MILLION FOLLOWERS!",
		category = "social",
		requiresFlag = "influencer",
		text = "You just hit ONE MILLION FOLLOWERS! Verification badge! How do you celebrate?",
		choices = {
			{ text = "🎉 Big celebration post", effects = { Happiness = 35, Looks = 10 }, resultText = "Thanked everyone! Massive engagement! Celebrity status!", setFlags = {"mega_influencer", "verified"} },
			{ text = "💰 Announce merch drop", effects = { Happiness = 25, Money = 100000 }, resultText = "Sold out in minutes! Your brand is REAL now!", setFlags = {"mega_influencer", "merch_empire"} },
			{ text = "❤️ Charity livestream", effects = { Happiness = 30, Looks = 8 }, resultText = "Raised $50k for charity! Used platform for good!", setFlags = {"mega_influencer", "charitable_influencer"} },
			{ text = "🤷 Just another number", effects = { Happiness = 15, Smarts = 3 }, resultText = "Stayed humble. Numbers don't define you. But still cool!" },
		},
	},
	
	{
		id = "fame_reality_show_offer",
		minAge = 18, maxAge = 45,
		weight = 12, oneTime = true,
		emoji = "📺", title = "Reality Show Offer!",
		category = "social",
		requiresFlag = "mega_influencer",
		getDynamicData = function()
			local shows = {"a dating show", "a competition show", "a lifestyle documentary", "a house show"}
			return { show = shows[math.random(#shows)] }
		end,
		text = "Producers want you on %show%! National TV exposure! But cameras EVERYWHERE. Do you do it?",
		choices = {
			{ text = "📺 Sign up!", effects = { Happiness = 25, Money = 50000, Looks = 8 }, resultText = "TV STAR! Millions watching! Fame exploded!", setFlags = {"reality_star", "tv_famous"} },
			{ text = "😈 Create drama", effects = { Happiness = 15, Money = 70000, Looks = 10 }, resultText = "Villain edit! Hate-famous! But everyone knows your name!", setFlags = {"reality_star", "infamous"} },
			{ text = "😇 Be authentic", effects = { Happiness = 30, Money = 40000, Looks = 5 }, resultText = "Fan favorite! Real personality shone through! Loved!", setFlags = {"reality_star", "beloved"} },
			{ text = "🙅 Turn it down", effects = { Happiness = 10, Smarts = 5 }, resultText = "Privacy over fame. Some things money can't buy." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- DARK SIDE OF FAME
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "fame_paparazzi",
		minAge = 18, maxAge = 60,
		weight = 20, cooldown = 3,
		emoji = "📸", title = "Paparazzi Everywhere!",
		category = "social",
		requiresFlag = "tv_famous",
		text = "Can't go anywhere without photographers! No privacy! How do you handle it?",
		choices = {
			{ text = "😎 Embrace it, pose", effects = { Happiness = 10, Looks = 8 }, resultText = "If they're gonna shoot, give them good shots! Control the narrative!" },
			{ text = "😤 Confront them", effects = { Happiness = -15, Looks = -5 }, resultText = "Got aggressive. Video went viral. Bad look. They win." },
			{ text = "🥸 Master of disguise", effects = { Happiness = 15, Smarts = 5 }, resultText = "Wigs, glasses, decoy cars! Living like a spy! Kind of fun!" },
			{ text = "😔 It's exhausting", effects = { Happiness = -20, Health = -5 }, resultText = "The constant surveillance is draining. Fame has a price.", setFlag = "fame_weary" },
		},
	},
	
	{
		id = "fame_cancel_culture",
		minAge = 16, maxAge = 60,
		weight = 15, cooldown = 5,
		emoji = "🚫", title = "Getting Cancelled!",
		category = "social",
		requiresFlag = "mega_influencer",
		getDynamicData = function()
			local reasons = {"old tweets surfaced", "a bad joke", "a misunderstanding", "something you actually did wrong"}
			return { reason = reasons[math.random(#reasons)] }
		end,
		text = "#YouAreOverParty trending! %reason%! Sponsors dropping! Career at risk! What do you do?",
		choices = {
			{ text = "📱 Sincere apology video", effects = { Happiness = 8, Looks = 5 }, resultText = "Owned it. Apologized genuinely. Some forgave. Survived.", setFlag = "scandal_survivor" },
			{ text = "⚖️ Deny everything", effects = { Happiness = -10, Looks = -8 }, resultText = "Made it worse. Evidence against you. Deeper in the hole." },
			{ text = "🤐 Go silent, wait it out", effects = { Happiness = -5 }, resultText = "Disappeared for months. Internet moved on. Quietly returned.", setFlag = "scandal_survivor" },
			{ text = "😤 Attack the critics", effects = { Happiness = -20, Looks = -15, Money = -50000 }, resultText = "TERRIBLE IDEA! Doubled the backlash! Reputation destroyed!", setFlag = "cancelled" },
		},
	},
	
	{
		id = "fame_stalker",
		minAge = 18, maxAge = 60,
		weight = 12, cooldown = 5,
		emoji = "😨", title = "Stalker Problem!",
		category = "social",
		requiresFlag = "tv_famous",
		text = "Someone is stalking you. Showing up everywhere. Sending creepy messages. This is scary. What do you do?",
		choices = {
			{ text = "👮 Go to police", effects = { Happiness = 5, Money = -5000 }, resultText = "Filed reports. Restraining order. Security hired. Safe but shaken.", setFlag = "stalker_survivor" },
			{ text = "🔐 Beef up security", effects = { Happiness = 8, Money = -20000 }, resultText = "Bodyguards, new locks, cameras. Living in a fortress. Is this worth it?" },
			{ text = "🏠 Move to new place", effects = { Happiness = 3, Money = -50000 }, resultText = "Relocated. New address secret. Starting over. Fame has costs." },
			{ text = "😰 Live in fear", effects = { Happiness = -25, Health = -15 }, resultText = "Constant anxiety. Can't enjoy anything. The price of fame.", setFlag = "trauma" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- PEAK FAME
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "fame_award_show",
		minAge = 20, maxAge = 60,
		weight = 10, oneTime = true,
		emoji = "🏆", title = "Award Nomination!",
		category = "social",
		requiresFlag = "mega_influencer",
		getDynamicData = function()
			local awards = {"Social Media Personality", "Influencer of the Year", "Breakout Star", "Fan Favorite"}
			return { award = awards[math.random(#awards)] }
		end,
		text = "Nominated for %award% at a major awards show! Red carpet! How do you show up?",
		choices = {
			{ text = "👗 Iconic outfit", effects = { Happiness = 30, Looks = 15, Money = -10000 }, resultText = "STUNNING! Everyone talking about your look! Fashion moment!", setFlags = {"award_winner", "fashion_icon"} },
			{ text = "🎤 Memorable speech", effects = { Happiness = 35, Smarts = 5 }, resultText = "WON! Speech went viral! Cemented your legacy!", setFlag = "award_winner" },
			{ text = "😭 Emotional moment", effects = { Happiness = 38, Looks = 5 }, resultText = "Tears of joy! Authentic reaction! Internet loved it!", setFlag = "award_winner" },
			{ text = "😔 Didn't win", effects = { Happiness = -10 }, resultText = "Lost to someone else. Smiled through it. Next time." },
		},
	},
	
	{
		id = "fame_talk_show",
		minAge = 18, maxAge = 60,
		weight = 15, cooldown = 3,
		emoji = "🎤", title = "Talk Show Interview!",
		category = "social",
		requiresFlag = "tv_famous",
		getDynamicData = function()
			local shows = {"Jimmy Fallon", "Jimmy Kimmel", "a morning show", "a podcast with millions of listeners"}
			return { show = shows[math.random(#shows)] }
		end,
		text = "Invited on %show%! National audience! How do you approach the interview?",
		choices = {
			{ text = "😂 Be hilarious", effects = { Happiness = 25, Looks = 8 }, resultText = "Had the host and audience dying! Clip went viral! More invites coming!" },
			{ text = "💬 Open up emotionally", effects = { Happiness = 20, Looks = 5 }, resultText = "Shared real story. Connected with viewers. Humanized your image." },
			{ text = "🤐 Play it safe", effects = { Happiness = 10, Smarts = 3 }, resultText = "Kept it professional. Nothing memorable but nothing bad either." },
			{ text = "😬 Made it awkward", effects = { Happiness = -15, Looks = -5 }, resultText = "Nervous! Weird answers! Became a meme for all the wrong reasons." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- LEGACY / LATE FAME
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "fame_staying_relevant",
		minAge = 30, maxAge = 55,
		weight = 18, cooldown = 4,
		emoji = "📉", title = "Relevance Fading...",
		category = "social",
		requiresFlag = "mega_influencer",
		text = "New, younger stars taking over. Your engagement dropping. The spotlight moving on. What do you do?",
		choices = {
			{ text = "🔄 Reinvent yourself", effects = { Happiness = 20, Looks = 5 }, resultText = "New platform! New content style! Comeback tour! Still got it!", setFlag = "reinvented" },
			{ text = "📺 Pivot to traditional media", effects = { Happiness = 15, Money = 100000 }, resultText = "TV hosting gig! Books! Mainstream legitimacy! Evolved!", setFlag = "mainstream_crossover" },
			{ text = "🏖️ Enjoy what you built", effects = { Happiness = 25, Health = 10 }, resultText = "Made your money. Had your moment. Time to enjoy life.", setFlag = "graceful_exit" },
			{ text = "😔 Desperately cling on", effects = { Happiness = -15, Looks = -5 }, resultText = "Trying too hard. Sad content. Becoming a cautionary tale.", setFlag = "washed_up" },
		},
	},
	
	{
		id = "fame_legacy",
		minAge = 40, maxAge = 80,
		weight = 12, oneTime = true,
		emoji = "⭐", title = "Fame Legacy",
		category = "social",
		requiresFlag = "award_winner",
		text = "Looking back at your journey from nobody to famous. What will your legacy be?",
		choices = {
			{ text = "❤️ Helped others rise", effects = { Happiness = 35 }, resultText = "Mentored new creators. Used platform to lift people up. Respected.", setFlag = "mentor_legend" },
			{ text = "💼 Built an empire", effects = { Happiness = 30, Money = 500000 }, resultText = "Brands, investments, businesses. Fame became fortune. Mogul status.", setFlag = "mogul" },
			{ text = "🎭 The art mattered most", effects = { Happiness = 32, Smarts = 5 }, resultText = "Content that mattered. Creative legacy. Remembered for the work.", setFlag = "artistic_legacy" },
			{ text = "😌 Lived authentically", effects = { Happiness = 40 }, resultText = "Stayed true to yourself throughout. Rare in this industry. Admired.", setFlag = "authentic_legend" },
		},
	},
}

return module
