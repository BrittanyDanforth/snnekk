-- LifeEvents/career_arts.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- ARTS & ENTERTAINMENT CAREER EVENTS
-- Musicians, Artists, Actors, Writers, Entertainers - The creative life
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent.init)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- EARLY CREATIVE DISCOVERY
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "arts_childhood_talent",
		minAge = 6, maxAge = 12,
		weight = 25, oneTime = true,
		emoji = "🎨", title = "Creative Spark!",
		category = "school",
		getDynamicData = function()
			local talents = {
				{ type = "drawing", emoji = "🎨" },
				{ type = "singing", emoji = "🎤" },
				{ type = "playing piano", emoji = "🎹" },
				{ type = "dancing", emoji = "💃" },
				{ type = "acting", emoji = "🎭" },
				{ type = "writing stories", emoji = "✍️" },
			}
			local chosen = talents[math.random(#talents)]
			return { talent = chosen.type, talentEmoji = chosen.emoji }
		end,
		getDynamicEmoji = function(data) return data.talentEmoji or "🎨" end,
		text = "Your teacher noticed you have a natural gift for %talent%!",
		choices = {
			{ text = "🌟 Practice every day!", effects = { Happiness = 10, Smarts = 5 }, resultText = "You're getting better! This could be your calling!", setFlag = "artistic_talent" },
			{ text = "😊 It's just for fun", effects = { Happiness = 8 }, resultText = "A fun hobby to enjoy!" },
			{ text = "🎓 Take lessons", effects = { Happiness = 8, Smarts = 6, Money = -500 }, resultText = "Professional training begins! Your skills are growing fast!", setFlags = {"artistic_talent", "trained_artist"} },
			{ text = "🤷 Not that interested", effects = { Happiness = 2 }, resultText = "Maybe art isn't your thing." },
		},
	},
	
	{
		id = "arts_school_play",
		minAge = 10, maxAge = 17,
		weight = 30, cooldown = 3,
		emoji = "🎭", title = "School Play Auditions!",
		category = "school",
		getDynamicData = function()
			local plays = {"Romeo and Juliet", "The Wizard of Oz", "A Christmas Carol", "Grease", "The Lion King Jr."}
			return { play = plays[math.random(#plays)] }
		end,
		text = "School is putting on %play%! Auditions are open!",
		choices = {
			{ text = "🌟 Go for the lead!", effects = { Happiness = 15, Looks = 3 }, resultText = "YOU GOT THE LEAD ROLE! Everyone's talking about you!", setFlag = "theater_kid" },
			{ text = "🎭 Try for supporting", effects = { Happiness = 10, Smarts = 2 }, resultText = "Got a great part! This is so fun!", setFlag = "theater_kid" },
			{ text = "🎨 Help with sets", effects = { Happiness = 6, Smarts = 3 }, resultText = "Behind the scenes magic! You painted amazing backdrops!" },
			{ text = "😰 Too nervous", effects = { Happiness = -3 }, resultText = "Watched from the audience. Maybe next time..." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- MUSIC CAREER PATH
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "music_first_band",
		minAge = 14, maxAge = 22,
		weight = 25, oneTime = true,
		emoji = "🎸", title = "Starting a Band!",
		category = "social",
		requiresFlag = "artistic_talent",
		getDynamicData = function()
			local genres = {"rock", "pop", "indie", "metal", "punk", "alternative"}
			local bandNames = {"The Midnight Echoes", "Neon Dreams", "Broken Compass", "Electric Youth", "The Last Sunset"}
			return { genre = genres[math.random(#genres)], bandName = bandNames[math.random(#bandNames)] }
		end,
		text = "You and some friends want to start a %genre% band called %bandName%!",
		choices = {
			{ text = "🎸 Let's do it!", effects = { Happiness = 15 }, resultText = "First practice was AMAZING! You might have something here!", setFlag = "in_band" },
			{ text = "🎤 I'll be the singer", effects = { Happiness = 12, Looks = 3 }, resultText = "Front and center! The spotlight feels natural!", setFlags = {"in_band", "lead_singer"} },
			{ text = "🤔 Just for fun", effects = { Happiness = 8 }, resultText = "Garage band vibes! Good times with friends!", setFlag = "in_band" },
			{ text = "🙅 Not my scene", effects = { Happiness = 2 }, resultText = "Bands aren't really your thing." },
		},
	},
	
	{
		id = "music_first_gig",
		minAge = 16, maxAge = 30,
		weight = 30, cooldown = 2,
		emoji = "🎤", title = "First Real Gig!",
		category = "work",
		requiresFlag = "in_band",
		getDynamicData = function()
			local venues = {"a local coffee shop", "a small club", "a house party", "a school talent show", "a street festival"}
			return { venue = venues[math.random(#venues)] }
		end,
		text = "Your band got booked to play at %venue%! Your first real show!",
		choices = {
			{ text = "🔥 Killed it!", effects = { Happiness = 20, Looks = 3, Money = 100 }, resultText = "The crowd went CRAZY! People want you back!", setFlag = "performing_musician" },
			{ text = "😅 Made some mistakes", effects = { Happiness = 8, Smarts = 3 }, resultText = "Not perfect but you learned so much!" },
			{ text = "😰 Froze up", effects = { Happiness = -10, Health = -2 }, resultText = "Stage fright hit hard. You stumbled through it." },
			{ text = "🌟 Got discovered!", effects = { Happiness = 25, Money = 500 }, resultText = "A talent scout was in the audience! They want to talk!", setFlags = {"performing_musician", "industry_contact"} },
		},
	},
	
	{
		id = "music_record_deal",
		minAge = 18, maxAge = 35,
		weight = 15, oneTime = true,
		emoji = "📀", title = "Record Deal Offer!",
		category = "work",
		requiresFlag = "performing_musician",
		getDynamicData = function()
			local labels = {"Universal", "Sony", "Warner", "an indie label", "a small startup label"}
			local advance = math.random(10000, 100000)
			return { label = labels[math.random(#labels)], advance = advance }
		end,
		text = "%label% wants to sign you! They're offering a $%advance% advance!",
		choices = {
			{ text = "✍️ Sign the deal!", effects = { Happiness = 30, Money = 50000 }, resultText = "YOU'RE A SIGNED ARTIST! Dreams coming true!", setFlags = {"signed_artist", "record_deal"} },
			{ text = "📋 Negotiate better terms", effects = { Happiness = 25, Money = 80000, Smarts = 5 }, resultText = "Got a better deal! Smart move!", setFlags = {"signed_artist", "record_deal"} },
			{ text = "🤔 Stay independent", effects = { Happiness = 10, Smarts = 3 }, resultText = "Keeping creative control. Risky but authentic.", setFlag = "indie_artist" },
			{ text = "⚠️ Bad contract!", effects = { Happiness = -15, Money = 20000 }, resultText = "Signed without reading carefully. Terrible terms!", setFlags = {"signed_artist", "bad_contract"} },
		},
	},
	
	{
		id = "music_hit_song",
		minAge = 18, maxAge = 50,
		weight = 10, oneTime = true,
		emoji = "🎵", title = "YOUR SONG IS A HIT!",
		category = "work",
		requiresFlag = "signed_artist",
		getDynamicData = function()
			local positions = {1, 3, 5, 10}
			return { chartPosition = positions[math.random(#positions)] }
		end,
		text = "Your song hit #%chartPosition% on the charts! You're going VIRAL!",
		choices = {
			{ text = "🤩 This is surreal!", effects = { Happiness = 40, Money = 200000, Looks = 10 }, resultText = "Interviews! Awards! Your life changed overnight!", setFlags = {"famous_musician", "chart_hit"} },
			{ text = "🎤 World tour time!", effects = { Happiness = 35, Money = 500000, Health = -5 }, resultText = "50 cities! Exhausting but incredible!", setFlags = {"famous_musician", "touring_artist"} },
			{ text = "😰 Fame is overwhelming", effects = { Happiness = 10, Money = 150000, Health = -8 }, resultText = "Success came with anxiety. Can't go anywhere without being recognized." },
			{ text = "💰 Capitalize on it!", effects = { Happiness = 20, Money = 400000 }, resultText = "Merch, endorsements, brand deals! Making that money!", setFlags = {"famous_musician", "sellout"} },
		},
	},
	
	{
		id = "music_one_hit_wonder",
		minAge = 20, maxAge = 50,
		weight = 20, cooldown = 5,
		emoji = "📉", title = "Career Slump",
		category = "work",
		requiresFlag = "chart_hit",
		text = "Your new album flopped. Critics are calling you a one-hit wonder.",
		choices = {
			{ text = "💪 Prove them wrong!", effects = { Happiness = -5, Smarts = 5 }, resultText = "Back to the studio. You'll show them!", setFlag = "comeback_kid" },
			{ text = "😔 Maybe they're right", effects = { Happiness = -20, Health = -5 }, resultText = "The doubt is crushing. Was it all luck?" },
			{ text = "🔄 Reinvent yourself", effects = { Happiness = 5, Smarts = 8 }, resultText = "New sound, new image. Artists evolve!", setFlag = "reinvented" },
			{ text = "🎸 Go back to small venues", effects = { Happiness = 10, Money = -10000 }, resultText = "Back to your roots. The music is what matters.", setFlag = "humble_artist" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- ACTING CAREER PATH
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "acting_first_audition",
		minAge = 18, maxAge = 35,
		weight = 25, oneTime = true,
		emoji = "🎬", title = "Hollywood Audition!",
		category = "work",
		requiresFlag = "theater_kid",
		getDynamicData = function()
			local roles = {"a small TV role", "a commercial", "an indie film", "a background extra", "a web series"}
			return { role = roles[math.random(#roles)] }
		end,
		text = "You scored an audition for %role%! This could be your break!",
		choices = {
			{ text = "🌟 Nailed it!", effects = { Happiness = 20, Money = 2000 }, resultText = "YOU GOT THE PART! Your acting career begins!", setFlag = "working_actor" },
			{ text = "😅 Did okay", effects = { Happiness = 5, Smarts = 3 }, resultText = "Didn't get it but got great feedback. Keep trying!" },
			{ text = "😰 Terrible audition", effects = { Happiness = -10 }, resultText = "Completely blanked. The rejection stings." },
			{ text = "🤝 Made connections", effects = { Happiness = 8, Smarts = 4 }, resultText = "Didn't get this one but the casting director remembered you!", setFlag = "industry_contact" },
		},
	},
	
	{
		id = "acting_breakout_role",
		minAge = 20, maxAge = 45,
		weight = 12, oneTime = true,
		emoji = "🎭", title = "BREAKOUT ROLE!",
		category = "work",
		requiresFlag = "working_actor",
		getDynamicData = function()
			local shows = {"a hit Netflix series", "a blockbuster movie", "an HBO drama", "a Marvel film", "a critically acclaimed indie"}
			return { production = shows[math.random(#shows)] }
		end,
		text = "You landed a major role in %production%! This is THE ONE!",
		choices = {
			{ text = "🌟 Career-defining!", effects = { Happiness = 40, Money = 500000, Looks = 10 }, resultText = "Critics are raving! You're the next big thing!", setFlags = {"famous_actor", "breakout_star"} },
			{ text = "🏆 Award nomination!", effects = { Happiness = 45, Money = 300000, Looks = 8 }, resultText = "Emmy/Oscar buzz! Your performance is unforgettable!", setFlags = {"famous_actor", "award_nominated"} },
			{ text = "😰 Pressure is intense", effects = { Happiness = 15, Money = 400000, Health = -10 }, resultText = "Success but at what cost? The stress is real." },
			{ text = "🎬 Method acting toll", effects = { Happiness = 30, Money = 350000, Health = -15 }, resultText = "Lost yourself in the role. Brilliant performance but you're drained.", setFlags = {"famous_actor", "method_actor"} },
		},
	},
	
	{
		id = "acting_scandal",
		minAge = 22, maxAge = 60,
		weight = 15, cooldown = 5,
		emoji = "📰", title = "Hollywood Scandal!",
		category = "work",
		requiresFlag = "famous_actor",
		getDynamicData = function()
			local scandals = {"leaked photos", "on-set meltdown video", "controversial tweet", "paparazzi caught you", "tabloid rumors"}
			return { scandal = scandals[math.random(#scandals)] }
		end,
		text = "A %scandal% is all over the news! Your reputation is at stake!",
		choices = {
			{ text = "📱 Apologize publicly", effects = { Happiness = -10, Looks = -5 }, resultText = "Damage control worked. People are forgiving.", clearFlag = "scandalous" },
			{ text = "🤐 No comment", effects = { Happiness = -5, Smarts = 3 }, resultText = "Let it blow over. Old news eventually." },
			{ text = "⚔️ Sue the tabloids", effects = { Happiness = -8, Money = -50000 }, resultText = "Legal battle begins. Stressful but standing your ground." },
			{ text = "😈 Lean into it", effects = { Happiness = 5, Looks = 3 }, resultText = "Any publicity is good publicity? Oddly, your fame grew.", setFlag = "controversial" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- VISUAL ARTS PATH
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "artist_first_gallery",
		minAge = 20, maxAge = 50,
		weight = 20, oneTime = true,
		emoji = "🖼️", title = "First Gallery Show!",
		category = "work",
		requiresFlag = "artistic_talent",
		getDynamicData = function()
			local galleries = {"a small local gallery", "a hip downtown space", "an online exhibition", "a coffee shop", "an art collective"}
			return { gallery = galleries[math.random(#galleries)] }
		end,
		text = "%gallery% wants to display your work! Your first real exhibition!",
		choices = {
			{ text = "🎨 Sold everything!", effects = { Happiness = 25, Money = 5000 }, resultText = "Every piece sold! People love your work!", setFlags = {"professional_artist", "art_sold"} },
			{ text = "😊 Great feedback", effects = { Happiness = 15, Smarts = 3 }, resultText = "Didn't sell much but made amazing connections!", setFlag = "professional_artist" },
			{ text = "😔 Barely noticed", effects = { Happiness = -5 }, resultText = "Nobody showed up. The art world is tough." },
			{ text = "🌟 Collector noticed you!", effects = { Happiness = 20, Money = 10000 }, resultText = "A wealthy collector bought your centerpiece! Patron acquired!", setFlags = {"professional_artist", "art_patron"} },
		},
	},
	
	{
		id = "artist_viral_piece",
		minAge = 18, maxAge = 60,
		weight = 10, oneTime = true,
		emoji = "🔥", title = "Viral Artwork!",
		category = "work",
		requiresFlag = "professional_artist",
		text = "Your latest piece went viral! Millions are seeing your art!",
		choices = {
			{ text = "💰 Sell prints!", effects = { Happiness = 25, Money = 50000 }, resultText = "Print sales through the roof! You're making real money!", setFlag = "successful_artist" },
			{ text = "🏛️ Museum offer!", effects = { Happiness = 30, Money = 20000, Smarts = 5 }, resultText = "A museum wants to acquire it! Your work in a permanent collection!", setFlags = {"successful_artist", "museum_artist"} },
			{ text = "😤 People stealing it", effects = { Happiness = -10, Money = 5000 }, resultText = "Everyone's using it without credit. The internet is brutal." },
			{ text = "🎨 Stay humble", effects = { Happiness = 15, Smarts = 5 }, resultText = "Fame is fleeting. Back to creating.", setFlag = "humble_artist" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- WRITING CAREER PATH
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "writer_first_book",
		minAge = 20, maxAge = 70,
		weight = 20, oneTime = true,
		emoji = "📚", title = "Finished Your First Book!",
		category = "work",
		requiresFlag = "artistic_talent",
		getDynamicData = function()
			local genres = {"a thriller", "a romance novel", "a fantasy epic", "literary fiction", "a memoir", "a self-help book"}
			return { genre = genres[math.random(#genres)] }
		end,
		text = "You finished writing %genre%! Years of work, finally complete!",
		choices = {
			{ text = "📮 Query agents", effects = { Happiness = 10, Smarts = 3 }, resultText = "Rejection letters pouring in... but one said yes!", setFlag = "writer" },
			{ text = "📱 Self-publish", effects = { Happiness = 12, Money = -2000 }, resultText = "You're a published author! Sales are slow but it's out there!", setFlag = "self_published" },
			{ text = "🗑️ Trunk it", effects = { Happiness = -5, Smarts = 4 }, resultText = "Not ready. Back to the drawer. Start the next one." },
			{ text = "🎉 Publishing deal!", effects = { Happiness = 25, Money = 15000 }, resultText = "A publisher wants it! Advance received!", setFlags = {"writer", "published_author"} },
		},
	},
	
	{
		id = "writer_bestseller",
		minAge = 25, maxAge = 80,
		weight = 8, oneTime = true,
		emoji = "🏆", title = "BESTSELLER!",
		category = "work",
		requiresFlag = "published_author",
		getDynamicData = function()
			local weeks = math.random(1, 20)
			return { weeks = weeks }
		end,
		text = "Your book hit the NYT Bestseller list! %weeks% weeks and counting!",
		choices = {
			{ text = "📚 Book tour!", effects = { Happiness = 30, Money = 100000, Health = -5 }, resultText = "Signing books across the country! Exhausting but amazing!", setFlag = "bestselling_author" },
			{ text = "🎬 Movie deal!", effects = { Happiness = 35, Money = 500000 }, resultText = "Hollywood wants to adapt it! Big screen dreams!", setFlags = {"bestselling_author", "movie_deal"} },
			{ text = "✍️ Pressure for next book", effects = { Happiness = 10, Money = 80000, Health = -8 }, resultText = "Publisher wants a sequel ASAP. The pressure is crushing." },
			{ text = "🙏 Grateful and humble", effects = { Happiness = 25, Money = 75000, Smarts = 5 }, resultText = "Dreams do come true. Back to writing with purpose.", setFlag = "bestselling_author" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- LATE CAREER / LEGACY EVENTS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "arts_lifetime_achievement",
		minAge = 55, maxAge = 90,
		weight = 10, oneTime = true,
		emoji = "🏆", title = "Lifetime Achievement Award!",
		category = "work",
		requiresFlag = "successful_artist",
		text = "You're receiving a lifetime achievement award for your contributions to the arts!",
		choices = {
			{ text = "😭 Overwhelmed with gratitude", effects = { Happiness = 40, Looks = 5 }, resultText = "Standing ovation. Your whole career flashes before your eyes. Worth it.", setFlag = "legend" },
			{ text = "🎤 Inspiring speech", effects = { Happiness = 35, Smarts = 5 }, resultText = "Your words moved the audience to tears. Legacy secured.", setFlag = "legend" },
			{ text = "🤔 Feel like a fraud", effects = { Happiness = 15 }, resultText = "Imposter syndrome hits even now. But you accept graciously." },
			{ text = "🌟 Pass the torch", effects = { Happiness = 30, Smarts = 3 }, resultText = "Used the moment to spotlight young artists. Class act.", setFlags = {"legend", "mentor"} },
		},
	},
	
	{
		id = "arts_creative_block",
		minAge = 25, maxAge = 70,
		weight = 25, cooldown = 4,
		emoji = "😔", title = "Creative Block",
		category = "work",
		requiresFlag = "professional_artist",
		text = "You can't create anything. The inspiration is just... gone. Weeks of nothing.",
		choices = {
			{ text = "🏖️ Take a break", effects = { Happiness = 5, Health = 5 }, resultText = "Rest helped. Ideas slowly returning." },
			{ text = "💪 Force through it", effects = { Happiness = -10, Smarts = 3 }, resultText = "Produced work you hate. But you kept going." },
			{ text = "🌍 Travel for inspiration", effects = { Happiness = 10, Money = -3000, Smarts = 5 }, resultText = "New places, new perspectives. The block is lifting!", setFlag = "inspired" },
			{ text = "😰 Depression spiral", effects = { Happiness = -20, Health = -10 }, resultText = "The block fed the darkness. Need to talk to someone.", setFlag = "depressed" },
		},
	},
	
	{
		id = "arts_passing_torch",
		minAge = 50, maxAge = 85,
		weight = 20, oneTime = true,
		emoji = "🎓", title = "Mentoring the Next Generation",
		category = "work",
		requiresFlag = "successful_artist",
		getDynamicData = function()
			return { studentName = LifeEvents.randomFirstName() }
		end,
		text = "%studentName%, a young artist, asks you to be their mentor. They remind you of yourself.",
		choices = {
			{ text = "🤝 Take them under your wing", effects = { Happiness = 20, Smarts = 3 }, resultText = "Watching them grow brings you so much joy. Legacy continues.", setFlag = "mentor" },
			{ text = "📚 Teach a masterclass", effects = { Happiness = 15, Money = 10000 }, resultText = "Sharing your knowledge with dozens of young artists!", setFlag = "teacher" },
			{ text = "🤔 Not ready to mentor", effects = { Happiness = -3 }, resultText = "You have your own work to focus on." },
			{ text = "😢 They surpassed you", effects = { Happiness = 25, Smarts = 5 }, resultText = "%studentName% became bigger than you ever were. You couldn't be prouder.", setFlag = "proud_mentor" },
		},
	},
	
	{
		id = "arts_forgotten",
		minAge = 50, maxAge = 90,
		weight = 15, cooldown = 5,
		emoji = "😔", title = "Fading From Memory",
		category = "work",
		requiresFlag = "famous_musician",
		blockIfFlag = "legend",
		text = "A young person didn't recognize you. 'Who were you again?' Fame is fleeting.",
		choices = {
			{ text = "😔 It hurts", effects = { Happiness = -15 }, resultText = "All that work, and people forget. The industry moves on." },
			{ text = "😂 Kind of funny", effects = { Happiness = 5, Smarts = 3 }, resultText = "Laughed it off. You know who you were. That's enough." },
			{ text = "🎵 Comeback time!", effects = { Happiness = 10, Money = -10000 }, resultText = "Recording new music. You're not done yet!", setFlag = "comeback_kid" },
			{ text = "🙏 At peace with it", effects = { Happiness = 8, Smarts = 5 }, resultText = "Legacy isn't about fame. It's about the art you made.", setFlag = "at_peace" },
		},
	},
	
	{
		id = "arts_masterpiece",
		minAge = 30, maxAge = 80,
		weight = 8, oneTime = true,
		emoji = "✨", title = "Your Magnum Opus",
		category = "work",
		requiresFlag = "professional_artist",
		text = "You created something that feels... different. This might be the best thing you've ever made.",
		choices = {
			{ text = "🎨 It's perfect", effects = { Happiness = 35, Smarts = 8 }, resultText = "This is the one. The piece that defines your entire career. Masterpiece.", setFlag = "created_masterpiece" },
			{ text = "🔥 Destroy it", effects = { Happiness = -10, Smarts = 5 }, resultText = "Burned it. Too personal. Some things aren't meant to be shared." },
			{ text = "🏛️ Donate to museum", effects = { Happiness = 30, Smarts = 5 }, resultText = "Your masterpiece will inspire generations. Immortalized.", setFlags = {"created_masterpiece", "museum_artist"} },
			{ text = "💰 Auction it", effects = { Happiness = 20, Money = 500000 }, resultText = "Sold for a fortune. But part of you wishes you kept it.", setFlag = "created_masterpiece" },
		},
	},
}

return module
