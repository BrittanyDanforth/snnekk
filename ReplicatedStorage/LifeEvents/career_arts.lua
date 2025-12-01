-- career_arts.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- CREATIVE CAREER EVENTS - Musician, Actor, Writer, Artist, Influencer
-- ═══════════════════════════════════════════════════════════════════════════════

local events = {}

-- ═══════════════════════════════════════════════════════════════
-- MUSICIAN EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "music_first_performance",
	emoji = "🎵",
	title = "First Performance",
	category = "creative",
	tags = {"career", "musician", "origin"},
	
	weight = 12,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	chainId = "musician_origin",
	chainStep = 1,
	
	conditions = {
		minAge = 10,
		maxAge = 25,
		blockedFlags = {"career_musician_started", "music_rejected"},
	},
	
	getDynamicData = function(state)
		local venues = {"school talent show", "family gathering", "local open mic", "church event"}
		local instruments = {"guitar", "piano", "drums", "violin", "your voice"}
		return {
			venue = venues[math.random(#venues)],
			instrument = instruments[math.random(#instruments)]
		}
	end,
	
	text = "You perform at a %venue%, playing %instrument%. The audience claps. Some people actually seem impressed.",
	
	choices = {
		{
			id = "this_is_it",
			text = "This is what I want to do with my life!",
			resultText = "You start practicing constantly and dreaming of bigger stages.",
			effects = {Happiness = 5},
			flags = {set = {"career_musician_started", "music_passionate"}},
			startCareer = "musician",
			careerXP = 15,
		},
		{
			id = "fun_hobby",
			text = "That was fun! Good hobby.",
			resultText = "Music stays a fun part of your life, even if it's not a career.",
			effects = {Happiness = 3},
			flags = {set = {"music_hobby"}},
		},
		{
			id = "stage_fright",
			text = "Too scary. I'm never doing that again.",
			resultText = "You decide performing isn't for you. The nerves were too much.",
			effects = {Happiness = -1},
			flags = {set = {"music_rejected", "stage_fright"}},
		},
	},
})

table.insert(events, {
	id = "music_viral_cover",
	emoji = "📱",
	title = "Viral Cover Song",
	category = "creative",
	tags = {"career", "musician", "indie_music", "viral"},
	
	weight = 8,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 13,
		maxAge = 35,
		requiredCareerId = "musician",
		requiredCareerMinTier = 1,
	},
	
	getDynamicData = function(state)
		return {
			views = math.random(100, 500) * 1000
		}
	end,
	
	text = "A cover song you posted online suddenly blows up. %views% views and counting! Your notifications won't stop.",
	
	choices = {
		{
			id = "capitalize",
			text = "Post more! Ride the wave!",
			resultText = "You start uploading consistently. Your following grows rapidly.",
			effects = {Happiness = 6, Money = 1000},
			flags = {set = {"viral_musician", "online_following"}},
			careerXP = 35,
		},
		{
			id = "original_music",
			text = "Use the attention to push original music.",
			resultText = "You release your own songs. Some fans stick around, others leave.",
			effects = {Happiness = 4, Money = 500},
			flags = {set = {"original_artist"}},
			careerXP = 25,
		},
	},
})

table.insert(events, {
	id = "music_record_deal",
	emoji = "📝",
	title = "Record Label Interest",
	category = "creative",
	tags = {"career", "musician", "record_deal", "milestone"},
	
	weight = 6,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 16,
		maxAge = 40,
		requiredCareerId = "musician",
		requiredCareerMinTier = 2,
		requiredAnyFlags = {"viral_musician", "original_artist"},
	},
	
	getDynamicData = function(state)
		local labels = {"Rising Star Records", "Urban Sound Media", "Horizon Music Group", "Elite Artists Label"}
		return {
			label = labels[math.random(#labels)]
		}
	end,
	
	text = "%label% wants to sign you! They're offering an advance and promising to push your music to a bigger audience. But the contract has some tricky clauses.",
	
	choices = {
		{
			id = "sign_deal",
			text = "Sign the deal! This is my big break!",
			resultText = "You sign with the label. Suddenly you have a team behind you.",
			effects = {Money = 50000, Happiness = 6},
			flags = {set = {"signed_artist", "under_contract"}},
			promoteCareer = true,
			careerXP = 50,
		},
		{
			id = "negotiate",
			text = "Negotiate for better terms.",
			resultText = "After some back and forth, you get a better deal. Smart move.",
			effects = {Money = 75000, Happiness = 5},
			flags = {set = {"signed_artist", "good_negotiator"}},
			promoteCareer = true,
			careerXP = 45,
		},
		{
			id = "stay_indie",
			text = "Stay independent. Keep my freedom.",
			resultText = "You walk away from the deal. Independence means everything to you.",
			effects = {Happiness = 3, Karma = 2},
			flags = {set = {"indie_forever"}},
			careerXP = 20,
		},
	},
})

table.insert(events, {
	id = "music_creative_block",
	emoji = "😶",
	title = "Creative Block",
	category = "creative",
	tags = {"career", "musician", "challenge"},
	
	weight = 10,
	cooldownYears = 3,
	oneTime = false,
	
	conditions = {
		minAge = 18,
		maxAge = 70,
		requiredCareerId = "musician",
		requiredCareerMinTier = 2,
	},
	
	text = "You haven't written anything good in months. Every melody sounds forced. The label is asking where the new album is.",
	
	choices = {
		{
			id = "push_through",
			text = "Lock yourself in and force it.",
			resultText = "You eventually produce something. It's not your best, but it's done.",
			effects = {Happiness = -3, Health = -2},
			flags = {set = {"forced_album"}},
			careerXP = 15,
		},
		{
			id = "take_break",
			text = "Take a break and live life.",
			resultText = "You step away from music for a while. Inspiration will come when it comes.",
			effects = {Happiness = 3, Health = 2},
			flags = {set = {"took_creative_break"}},
		},
		{
			id = "collaborate",
			text = "Collaborate with other artists.",
			resultText = "Working with others sparks new ideas. The creative juices flow again.",
			effects = {Happiness = 4, Smarts = 2},
			flags = {set = {"collaborator"}},
			careerXP = 20,
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- ACTOR EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "acting_first_role",
	emoji = "🎭",
	title = "First Acting Role",
	category = "creative",
	tags = {"career", "actor", "origin"},
	
	weight = 10,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	chainId = "actor_origin",
	chainStep = 1,
	
	conditions = {
		minAge = 10,
		maxAge = 30,
		blockedFlags = {"career_actor_started", "acting_rejected"},
	},
	
	getDynamicData = function(state)
		local roles = {"school play", "community theater", "local commercial", "student film"}
		return {
			role = roles[math.random(#roles)]
		}
	end,
	
	text = "You land a small role in a %role%. On performance day, something clicks - you lose yourself in the character.",
	
	choices = {
		{
			id = "pursue_acting",
			text = "I need to do more of this!",
			resultText = "You start auditioning for everything you can find.",
			effects = {Happiness = 4},
			flags = {set = {"career_actor_started", "acting_bug"}},
			startCareer = "actor",
			careerXP = 15,
		},
		{
			id = "fun_experience",
			text = "That was a fun experience.",
			resultText = "You enjoy the memory but don't pursue it seriously.",
			effects = {Happiness = 2},
			flags = {set = {"acting_experience"}},
		},
	},
})

table.insert(events, {
	id = "acting_audition_streak",
	emoji = "🎬",
	title = "The Audition Grind",
	category = "creative",
	tags = {"career", "actor", "acting_extra"},
	
	weight = 12,
	cooldownYears = 2,
	oneTime = false,
	
	conditions = {
		minAge = 18,
		maxAge = 50,
		requiredCareerId = "actor",
		requiredCareerMinTier = 1,
	},
	
	getDynamicData = function(state)
		return {
			rejections = math.random(10, 30)
		}
	end,
	
	text = "You've been rejected from %rejections% auditions this month alone. The casting directors barely look at you.",
	
	choices = {
		{
			id = "keep_going",
			text = "Keep going. Every rejection is practice.",
			resultText = "You keep auditioning. Your skin gets thicker. Eventually, something will hit.",
			effects = {Happiness = -2, Smarts = 1},
			flags = {set = {"persistent_actor"}},
			careerXP = 10,
		},
		{
			id = "take_classes",
			text = "Take acting classes to improve.",
			resultText = "You invest in your craft. Your auditions get better.",
			effects = {Money = -2000, Smarts = 3},
			flags = {set = {"trained_actor"}},
			careerXP = 20,
		},
		{
			id = "consider_quitting",
			text = "Maybe this isn't meant to be.",
			resultText = "You start looking at backup plans. The dream is fading.",
			effects = {Happiness = -4},
			flags = {set = {"doubting_acting"}},
		},
	},
})

table.insert(events, {
	id = "acting_breakthrough",
	emoji = "⭐",
	title = "The Breakthrough Role",
	category = "creative",
	tags = {"career", "actor", "supporting_role", "milestone"},
	
	weight = 6,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 18,
		maxAge = 60,
		requiredCareerId = "actor",
		requiredCareerMinTier = 1,
		requiredAnyFlags = {"persistent_actor", "trained_actor"},
	},
	
	getDynamicData = function(state)
		local shows = {"a hit TV drama", "an indie film", "a streaming series", "a popular sitcom"}
		return {
			show = shows[math.random(#shows)]
		}
	end,
	
	text = "After countless auditions, you land a significant role in %show%! It's not the lead, but it's real. This could change everything.",
	
	choices = {
		{
			id = "give_everything",
			text = "Give this role everything I have.",
			resultText = "You pour your heart into the performance. Critics start to notice you.",
			effects = {Happiness = 8, Money = 20000},
			flags = {set = {"breakthrough_role", "rising_star"}},
			promoteCareer = true,
			careerXP = 50,
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- WRITER EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "writing_first_story",
	emoji = "✍️",
	title = "First Story",
	category = "creative",
	tags = {"career", "writer", "origin"},
	
	weight = 12,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	chainId = "writer_origin",
	chainStep = 1,
	
	conditions = {
		minAge = 10,
		maxAge = 35,
		blockedFlags = {"career_writer_started", "writing_rejected"},
		minStats = {Smarts = 35},
	},
	
	text = "You write your first complete story - beginning, middle, and end. Reading it back, you're surprised by what came out of your head.",
	
	choices = {
		{
			id = "keep_writing",
			text = "I have more stories to tell!",
			resultText = "You fill notebooks with ideas. Writing becomes part of who you are.",
			effects = {Smarts = 2, Happiness = 3},
			flags = {set = {"career_writer_started", "writing_passion"}},
			startCareer = "writer",
			careerXP = 15,
		},
		{
			id = "share_story",
			text = "Share it online and see what people think.",
			resultText = "You post it to a writing community. Some feedback is harsh, some encouraging.",
			effects = {Smarts = 1, Happiness = 1},
			flags = {set = {"career_writer_started", "shares_work"}},
			startCareer = "writer",
			careerXP = 10,
		},
	},
})

table.insert(events, {
	id = "writing_first_book",
	emoji = "📚",
	title = "Finish Your First Book",
	category = "creative",
	tags = {"career", "writer", "published_book", "milestone"},
	
	weight = 8,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 18,
		maxAge = 70,
		requiredCareerId = "writer",
		requiredCareerMinTier = 1,
	},
	
	text = "You type the final words. After months of work, you've finished writing an entire book. Now comes the hard part: getting it published.",
	
	choices = {
		{
			id = "traditional_publishing",
			text = "Query literary agents for traditional publishing.",
			resultText = "You send dozens of query letters. The waiting game begins.",
			effects = {Happiness = 2},
			flags = {set = {"seeking_publication", "traditional_route"}},
			careerXP = 20,
		},
		{
			id = "self_publish",
			text = "Self-publish as an ebook.",
			resultText = "You format, design a cover, and publish yourself. It's available immediately!",
			effects = {Happiness = 4, Money = -500},
			flags = {set = {"self_published", "published_author"}},
			promoteCareer = true,
			careerXP = 25,
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- INFLUENCER EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "social_media_viral",
	emoji = "📱",
	title = "Going Viral",
	category = "creative",
	tags = {"career", "influencer", "origin", "viral"},
	
	weight = 10,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	chainId = "influencer_origin",
	chainStep = 1,
	
	conditions = {
		minAge = 13,
		maxAge = 35,
		blockedFlags = {"career_influencer_started"},
	},
	
	getDynamicData = function(state)
		local content = {"a funny video", "a relatable post", "a dance trend", "a hot take"}
		return {
			content = content[math.random(#content)],
			followers = math.random(10, 100) * 1000
		}
	end,
	
	text = "You post %content% without thinking much about it. Then it blows up. You go from nobody to %followers% followers overnight.",
	
	choices = {
		{
			id = "become_creator",
			text = "This could be a real thing. Let's build on it!",
			resultText = "You start creating content consistently. The algorithm gods smile upon you.",
			effects = {Happiness = 5, Money = 500},
			flags = {set = {"career_influencer_started", "viral_success"}},
			startCareer = "influencer",
			careerXP = 25,
		},
		{
			id = "one_hit_wonder",
			text = "That was wild, but I don't want this lifestyle.",
			resultText = "You enjoy the moment but don't pursue influencing. Just a cool story to tell.",
			effects = {Happiness = 3},
			flags = {set = {"went_viral_once"}},
		},
	},
})

table.insert(events, {
	id = "influencer_brand_deal",
	emoji = "💰",
	title = "First Brand Deal",
	category = "creative",
	tags = {"career", "influencer", "brand_deals"},
	
	weight = 12,
	cooldownYears = 1,
	oneTime = false,
	
	conditions = {
		minAge = 16,
		maxAge = 50,
		requiredCareerId = "influencer",
		requiredCareerMinTier = 2,
	},
	
	getDynamicData = function(state)
		local brands = {"a gaming chair company", "an energy drink brand", "a fashion label", "a skincare brand", "a tech company"}
		return {
			brand = brands[math.random(#brands)],
			pay = math.random(500, 5000)
		}
	end,
	
	text = "%brand% wants you to promote their product. They're offering $%pay% for a single sponsored post.",
	
	choices = {
		{
			id = "take_deal",
			text = "Take the deal.",
			resultText = "You make the sponsored content. Some followers complain about 'selling out.'",
			effects = {Money = 2500, Karma = -1},
			flags = {set = {"takes_sponsorships"}},
			careerXP = 15,
		},
		{
			id = "negotiate_more",
			text = "Counter with a higher number.",
			resultText = "They agree to pay more. Know your worth!",
			effects = {Money = 4000},
			flags = {set = {"takes_sponsorships", "good_negotiator"}},
			careerXP = 20,
		},
		{
			id = "decline",
			text = "Decline. It doesn't fit my brand.",
			resultText = "You pass on the money to stay authentic. Your core fans appreciate it.",
			effects = {Karma = 2},
			flags = {set = {"selective_sponsor"}},
			careerReputation = 5,
		},
	},
})

table.insert(events, {
	id = "influencer_cancel_attempt",
	emoji = "😱",
	title = "Cancel Mob",
	category = "creative",
	tags = {"career", "influencer", "drama"},
	
	weight = 6,
	cooldownYears = 5,
	oneTime = false,
	
	conditions = {
		minAge = 16,
		maxAge = 60,
		requiredCareerId = "influencer",
		requiredCareerMinTier = 2,
	},
	
	text = "Something you said or did (maybe years ago) surfaces online. People are calling for you to be cancelled. The hashtag is trending.",
	
	choices = {
		{
			id = "apologize",
			text = "Post a genuine apology.",
			resultText = "You apologize and take accountability. Some accept it, others don't.",
			effects = {Happiness = -5, Karma = 2},
			flags = {set = {"survived_cancel"}},
			careerReputation = -10,
		},
		{
			id = "ignore",
			text = "Ignore it and wait for it to blow over.",
			resultText = "You stay quiet. Eventually the mob moves on to someone else.",
			effects = {Happiness = -3},
			flags = {set = {"survived_cancel"}},
			careerReputation = -5,
		},
		{
			id = "address_directly",
			text = "Address it head-on with context.",
			resultText = "You explain your side. It's a mixed response, but at least you faced it.",
			effects = {Happiness = -4},
			flags = {set = {"survived_cancel", "addressed_controversy"}},
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- ARTIST EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "art_first_exhibition",
	emoji = "🎨",
	title = "First Gallery Show",
	category = "creative",
	tags = {"career", "artist", "origin"},
	
	weight = 10,
	cooldownYears = 99,
	oneTime = true,
	milestone = true,
	
	chainId = "artist_origin",
	chainStep = 1,
	
	conditions = {
		minAge = 16,
		maxAge = 50,
		blockedFlags = {"career_artist_started"},
	},
	
	getDynamicData = function(state)
		local venues = {"a local coffee shop", "a small gallery", "a community center", "an online platform"}
		return {
			venue = venues[math.random(#venues)]
		}
	end,
	
	text = "Your artwork is displayed at %venue%. Strangers are looking at something you created. Someone actually wants to buy one.",
	
	choices = {
		{
			id = "pursue_art",
			text = "This is my path. I'm an artist.",
			resultText = "You commit to making art your life. It won't be easy, but it's what you love.",
			effects = {Happiness = 5, Money = 200},
			flags = {set = {"career_artist_started", "sold_first_piece"}},
			startCareer = "artist",
			careerXP = 20,
		},
		{
			id = "keep_hobby",
			text = "Keep it as a beloved hobby.",
			resultText = "You keep creating art without the pressure of making it a career.",
			effects = {Happiness = 3, Money = 200},
			flags = {set = {"art_hobby", "sold_first_piece"}},
		},
	},
})

table.insert(events, {
	id = "art_commission_flood",
	emoji = "✏️",
	title = "Commission Overload",
	category = "creative",
	tags = {"career", "artist", "freelance_art"},
	
	weight = 10,
	cooldownYears = 2,
	oneTime = false,
	
	conditions = {
		minAge = 18,
		maxAge = 70,
		requiredCareerId = "artist",
		requiredCareerMinTier = 2,
	},
	
	text = "Your commission requests are piling up. More people want custom art than you can handle. Good problem to have, but still stressful.",
	
	choices = {
		{
			id = "take_them_all",
			text = "Accept as many as possible. Make that money!",
			resultText = "You work overtime. The money is good, but you're exhausted.",
			effects = {Money = 8000, Health = -3, Happiness = -2},
			flags = {set = {"busy_artist"}},
			careerXP = 25,
		},
		{
			id = "raise_prices",
			text = "Raise prices and take fewer commissions.",
			resultText = "You charge more and work less. The right balance.",
			effects = {Money = 5000, Happiness = 2},
			flags = {set = {"premium_artist"}},
			careerXP = 20,
		},
		{
			id = "close_commissions",
			text = "Close commissions temporarily.",
			resultText = "You take a break to create personal work again.",
			effects = {Happiness = 4},
			flags = {set = {}},
			careerXP = 10,
		},
	},
})

return {events = events}
