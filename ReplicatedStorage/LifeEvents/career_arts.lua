-- LifeEvents/career_arts.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- ARTS & ENTERTAINMENT CAREER EVENTS
-- BitLife-style: Player picks ACTIONS, game decides OUTCOMES
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
		emoji = "🎨", title = "Teacher Noticed Something!",
		category = "school",
		getDynamicData = function()
			local talents = {
				{ type = "drawing", emoji = "🎨" },
				{ type = "singing", emoji = "🎤" },
				{ type = "playing piano", emoji = "🎹" },
				{ type = "dancing", emoji = "💃" },
				{ type = "acting", emoji = "🎭" },
			}
			local chosen = talents[math.random(#talents)]
			return { talent = chosen.type, talentEmoji = chosen.emoji }
		end,
		getDynamicEmoji = function(data) return data.talentEmoji or "🎨" end,
		text = "Your teacher says you have natural talent for %talent%! They suggest you pursue it. What do you do?",
		choices = {
			{ text = "🌟 Practice every day", effects = { Happiness = 12, Smarts = 5 }, resultText = "You're getting really good! This could be your calling!", setFlag = "artistic_talent" },
			{ text = "🎓 Ask for lessons", effects = { Happiness = 8, Smarts = 6, Money = -500 }, resultText = "Parents enrolled you in classes! Professional training begins!", setFlags = {"artistic_talent", "trained_artist"} },
			{ text = "😊 Just do it for fun", effects = { Happiness = 6 }, resultText = "A nice hobby! No pressure, just enjoy it." },
			{ text = "🤷 Not interested", effects = { Happiness = 0 }, resultText = "Teacher was disappointed but you moved on to other things." },
		},
	},
	
	{
		id = "arts_school_play",
		minAge = 10, maxAge = 17,
		weight = 30, cooldown = 3,
		emoji = "🎭", title = "School Play Auditions!",
		category = "school",
		getDynamicData = function()
			local plays = {"Romeo and Juliet", "The Wizard of Oz", "A Christmas Carol", "Grease"}
			return { play = plays[math.random(#plays)] }
		end,
		text = "School is putting on %play%! Auditions are today! What do you do?",
		choices = {
			{ text = "🌟 Audition for the lead", effects = { Happiness = 15, Looks = 3 }, resultText = "You nailed it! GOT THE LEAD! Everyone's talking about you!", setFlag = "theater_kid" },
			{ text = "🎭 Audition for supporting", effects = { Happiness = 10, Smarts = 2 }, resultText = "Got a fun supporting role! Perfect amount of stage time!", setFlag = "theater_kid" },
			{ text = "🎨 Volunteer for backstage", effects = { Happiness = 6, Smarts = 3 }, resultText = "Painting sets and handling props! The unsung heroes of theater!" },
			{ text = "😰 Skip the audition", effects = { Happiness = -5 }, resultText = "Too nervous. Watched from the audience on opening night. Regret." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- MUSIC CAREER PATH
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "music_first_band",
		minAge = 14, maxAge = 22,
		weight = 25, oneTime = true,
		emoji = "🎸", title = "Start a Band?",
		category = "social",
		requiresFlag = "artistic_talent",
		getDynamicData = function()
			local genres = {"rock", "pop", "indie", "punk", "alternative"}
			local bandNames = {"The Midnight Echoes", "Neon Dreams", "Broken Compass", "Electric Youth"}
			return { genre = genres[math.random(#genres)], bandName = bandNames[math.random(#bandNames)] }
		end,
		text = "Friends want to start a %genre% band called %bandName%! They need you! What do you do?",
		choices = {
			{ text = "🎸 Join as guitarist", effects = { Happiness = 15 }, resultText = "First jam session was electric! This band has potential!", setFlag = "in_band" },
			{ text = "🎤 Only if I can sing", effects = { Happiness = 12, Looks = 3 }, resultText = "They agreed! You're the frontperson! Spotlight feels natural!", setFlags = {"in_band", "lead_singer"} },
			{ text = "🤔 Just help out sometimes", effects = { Happiness = 6 }, resultText = "Casual involvement. Show up when you can. Low pressure.", setFlag = "in_band" },
			{ text = "🙅 Pass on it", effects = { Happiness = 0 }, resultText = "Not your thing. They found someone else." },
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
			local venues = {"a local coffee shop", "a small club", "a house party", "a street festival"}
			return { venue = venues[math.random(#venues)] }
		end,
		text = "Your band got booked at %venue%! First real show! How do you approach it?",
		choices = {
			{ text = "💪 Give it 110%!", effects = { Happiness = 20, Looks = 3, Money = 100 }, resultText = "CRUSHED IT! Crowd went wild! People want you back!", setFlag = "performing_musician" },
			{ text = "😎 Play it cool", effects = { Happiness = 10, Smarts = 3 }, resultText = "Solid performance! Nothing flashy but no mistakes either!" },
			{ text = "🍺 Get drunk first", effects = { Happiness = -15, Looks = -3 }, resultText = "DISASTER! Forgot lyrics, fell off stage. Embarrassing night." },
			{ text = "😰 Almost cancel", effects = { Happiness = 5 }, resultText = "Nervous wreck but did it anyway. Not great but you survived!" },
		},
	},
	
	{
		id = "music_record_deal",
		minAge = 18, maxAge = 35,
		weight = 15, oneTime = true,
		emoji = "📀", title = "Record Label Interested!",
		category = "work",
		requiresFlag = "performing_musician",
		blockIfFlag = "signed_artist", -- Only one record deal
		getDynamicData = function()
			local labels = {"a major label", "an indie label", "a startup label"}
			local advance = math.random(20000, 80000)
			return { label = labels[math.random(#labels)], advance = advance }
		end,
		text = "%label% wants to sign you! $%advance% advance offered. What do you do?",
		choices = {
			{ 
				text = "✍️ Sign immediately!", 
				effects = { Happiness = 20, Money = 50000 }, 
				resultText = "Signed! You're officially a recording artist! Dreams coming true!", 
				setFlags = {"signed_artist", "record_deal", "employed"},
				setJob = { id = "recording_artist", title = "Recording Artist", salary = 50000 }
			},
			{ 
				text = "📋 Hire a lawyer first", 
				effects = { Happiness = 25, Money = 70000, Smarts = 5 }, 
				resultText = "Lawyer found bad clauses! Negotiated better terms! Smart move!", 
				setFlags = {"signed_artist", "record_deal", "employed"},
				setJob = { id = "recording_artist", title = "Recording Artist", salary = 70000 }
			},
			{ 
				text = "🤔 Stay independent", 
				effects = { Happiness = 8, Smarts = 3 }, 
				resultText = "Keeping creative control. Harder path but YOUR path.", 
				setFlags = {"indie_artist", "employed"},
				setJob = { id = "indie_musician", title = "Independent Musician", salary = 25000 }
			},
			{ 
				text = "😬 Don't read the contract", 
				effects = { Happiness = -10, Money = 20000 }, 
				resultText = "Signed blind. TERRIBLE terms! They own everything. Big mistake!", 
				setFlags = {"signed_artist", "bad_contract", "employed"},
				setJob = { id = "recording_artist", title = "Recording Artist", salary = 20000 }
			},
		},
	},
	
	{
		id = "music_hit_song",
		minAge = 18, maxAge = 50,
		weight = 10, oneTime = true,
		emoji = "🎵", title = "Song Going Viral!",
		category = "work",
		requiresFlag = "signed_artist",
		text = "Your new song is blowing up! Millions of streams! Labels and press calling! How do you handle it?",
		choices = {
			{ text = "🎤 Do every interview", effects = { Happiness = 30, Money = 200000, Looks = 10, Health = -5 }, resultText = "Non-stop press! Exhausting but your name is EVERYWHERE!", setFlags = {"famous_musician", "chart_hit"} },
			{ text = "🎸 Focus on the music", effects = { Happiness = 25, Money = 100000, Smarts = 5 }, resultText = "Let the music speak. Earned respect as a real artist.", setFlags = {"famous_musician", "respected_artist"} },
			{ text = "💰 Chase the money", effects = { Happiness = 15, Money = 300000, Looks = -3 }, resultText = "Brand deals, merch, sellout collabs. Rich but respect down.", setFlags = {"famous_musician", "sellout"} },
			{ text = "😰 Hide from spotlight", effects = { Happiness = 5, Money = 80000 }, resultText = "Turned down most offers. Missed the moment. One hit wonder?" },
		},
	},
	
	{
		id = "music_one_hit_wonder",
		minAge = 20, maxAge = 50,
		weight = 20, cooldown = 5,
		emoji = "📉", title = "New Album Flopping!",
		category = "work",
		requiresFlag = "chart_hit",
		text = "Your new album isn't doing well. Critics calling you a one-hit wonder. What do you do?",
		choices = {
			{ text = "💪 Work even harder", effects = { Happiness = 10, Smarts = 5, Health = -5 }, resultText = "Back to the studio! Determined to prove them wrong! Comeback loading..." },
			{ text = "🔄 Completely reinvent", effects = { Happiness = 15, Smarts = 8 }, resultText = "New sound, new image! Risky but people are intrigued!", setFlag = "reinvented" },
			{ text = "😔 Give up music", effects = { Happiness = -25, Health = -5 }, resultText = "The rejection broke you. Walked away from the industry.", clearFlags = {"signed_artist", "famous_musician"} },
			{ text = "🎸 Go back to basics", effects = { Happiness = 12, Money = -20000 }, resultText = "Small venues, real fans. Less money, more soul. Pure again." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- ACTING CAREER PATH
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "acting_audition",
		minAge = 18, maxAge = 35,
		weight = 25, cooldown = 2,
		emoji = "🎬", title = "Audition Opportunity!",
		category = "work",
		requiresFlag = "theater_kid",
		getDynamicData = function()
			local roles = {"a TV commercial", "an indie film", "a small TV role", "a web series"}
			return { role = roles[math.random(#roles)] }
		end,
		text = "You got an audition for %role%! Big opportunity! How do you prepare?",
		choices = {
			{ text = "📚 Study the script deeply", effects = { Happiness = 18, Money = 2000 }, resultText = "Your preparation showed! BOOKED THE ROLE! Acting career begins!", setFlag = "working_actor" },
			{ text = "🎭 Just wing it", effects = { Happiness = -10 }, resultText = "Not prepared enough. They could tell. Rejection email came fast." },
			{ text = "😰 Overthink everything", effects = { Happiness = 5 }, resultText = "So nervous you blanked! But they saw potential. Callback!" },
			{ text = "🍺 Party the night before", effects = { Happiness = -15, Looks = -3 }, resultText = "Showed up hungover. TERRIBLE audition. Burned that bridge." },
		},
	},
	
	{
		id = "acting_big_break",
		minAge = 20, maxAge = 45,
		weight = 12, oneTime = true,
		emoji = "🎭", title = "Big Role Offered!",
		category = "work",
		requiresFlag = "working_actor",
		getDynamicData = function()
			local shows = {"a Netflix series", "a major movie", "an HBO drama", "a blockbuster film"}
			return { production = shows[math.random(#shows)] }
		end,
		text = "You're offered a major role in %production%! This is THE break! What do you do?",
		choices = {
			{ text = "✅ Accept immediately!", effects = { Happiness = 40, Money = 300000, Looks = 10 }, resultText = "Career-defining role! Critics raving! Awards buzz! MADE IT!", setFlags = {"famous_actor", "breakout_star"} },
			{ text = "📋 Negotiate aggressively", effects = { Happiness = 30, Money = 500000, Smarts = 5 }, resultText = "Got way more money! But they remember you being difficult...", setFlag = "famous_actor" },
			{ text = "🤔 Ask for script changes", effects = { Happiness = 15, Money = 200000 }, resultText = "Some changes made. Good role but tension with director.", setFlag = "famous_actor" },
			{ text = "😬 Turn it down", effects = { Happiness = -20 }, resultText = "They gave it to someone else who became a HUGE star. Regret forever." },
		},
	},
	
	{
		id = "acting_scandal",
		minAge = 22, maxAge = 60,
		weight = 15, cooldown = 5,
		emoji = "📰", title = "Scandal Breaking!",
		category = "work",
		requiresFlag = "famous_actor",
		getDynamicData = function()
			local scandals = {"leaked photos", "on-set meltdown video", "controversial interview", "past tweets surfaced"}
			return { scandal = scandals[math.random(#scandals)] }
		end,
		text = "OH NO! %scandal% all over the news! Sponsors threatening to drop you! What do you do?",
		choices = {
			{ text = "📱 Apologize immediately", effects = { Happiness = -5, Looks = -3 }, resultText = "Owned it. Apologized sincerely. People appreciated the honesty. Survived." },
			{ text = "⚖️ Sue the tabloids", effects = { Happiness = -10, Money = -100000 }, resultText = "Long legal battle. Exhausting. Won eventually but at what cost?" },
			{ text = "😤 Double down", effects = { Happiness = -20, Looks = -10, Money = -200000 }, resultText = "Made it SO much worse! Sponsors fled. Reputation tanked. Bad move!" },
			{ text = "🤐 Go completely silent", effects = { Happiness = -8, Looks = -5 }, resultText = "Waited it out. Mostly blew over. Some damage but recovered eventually." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- VISUAL ARTS PATH
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "artist_gallery_offer",
		minAge = 20, maxAge = 50,
		weight = 20, cooldown = 4,
		emoji = "🖼️", title = "Gallery Show Offer!",
		category = "work",
		requiresFlag = "artistic_talent",
		getDynamicData = function()
			local galleries = {"a local gallery", "a downtown space", "an art collective", "a coffee shop"}
			return { gallery = galleries[math.random(#galleries)] }
		end,
		text = "%gallery% wants to display your work! Your first real exhibition! How do you prepare?",
		choices = {
			{ text = "🎨 Create new pieces", effects = { Happiness = 20, Money = 5000 }, resultText = "Fresh work impressed everyone! Sold several pieces! Success!", setFlags = {"professional_artist", "art_sold"} },
			{ text = "🖼️ Show existing work", effects = { Happiness = 12, Money = 2000 }, resultText = "Solid showing! Some interest. Good experience!", setFlag = "professional_artist" },
			{ text = "📢 Market aggressively", effects = { Happiness = 15, Money = 8000, Looks = 3 }, resultText = "Huge turnout from your promotion! Sold everything! Smart!", setFlags = {"professional_artist", "art_sold"} },
			{ text = "😰 Rush unprepared", effects = { Happiness = -10 }, resultText = "Work wasn't ready. Embarrassing night. Gallery won't call back." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- WRITING CAREER PATH
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "writer_first_book",
		minAge = 20, maxAge = 70,
		weight = 20, oneTime = true,
		emoji = "📚", title = "Finished Your Book!",
		category = "work",
		requiresFlag = "artistic_talent",
		text = "You finished writing your first book! Years of work done. What do you do with it?",
		choices = {
			{ text = "📮 Query literary agents", effects = { Happiness = 20, Money = 15000 }, resultText = "An agent signed you! Publisher interested! Book deal!", setFlags = {"writer", "published_author"} },
			{ text = "📱 Self-publish on Amazon", effects = { Happiness = 12, Money = 2000 }, resultText = "You're published! Sales slow but it's OUT THERE!", setFlag = "self_published" },
			{ text = "🗑️ Trunk it, start over", effects = { Happiness = -5, Smarts = 5 }, resultText = "Decided it wasn't good enough. Painful but maybe wise." },
			{ text = "👨‍👩‍👧 Just share with family", effects = { Happiness = 8 }, resultText = "Family loved it! That's enough for now." },
		},
	},
	
	{
		id = "writer_bestseller",
		minAge = 25, maxAge = 80,
		weight = 8, oneTime = true,
		emoji = "🏆", title = "Book Taking Off!",
		category = "work",
		requiresFlag = "published_author",
		text = "Your book is climbing the bestseller lists! Publisher wants you to promote it HARD. What do you do?",
		choices = {
			{ text = "📚 Full book tour", effects = { Happiness = 25, Money = 100000, Health = -8 }, resultText = "50 cities! Exhausting but BESTSELLING AUTHOR status!", setFlag = "bestselling_author" },
			{ text = "🎬 Sell movie rights", effects = { Happiness = 30, Money = 500000 }, resultText = "HOLLYWOOD CALLED! Movie deal signed! Life changing!", setFlags = {"bestselling_author", "movie_deal"} },
			{ text = "✍️ Focus on next book", effects = { Happiness = 15, Money = 50000, Smarts = 5 }, resultText = "Let success speak for itself. Working on the follow-up." },
			{ text = "🏖️ Enjoy the moment", effects = { Happiness = 20, Money = 80000 }, resultText = "Took a break to appreciate it. Smart self-care." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- LATE CAREER / LEGACY
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "arts_lifetime_achievement",
		minAge = 55, maxAge = 90,
		weight = 10, oneTime = true,
		emoji = "🏆", title = "Lifetime Achievement Award!",
		category = "work",
		requiresFlag = "famous_musician",
		text = "You're receiving a lifetime achievement award for your contributions to the arts! How do you accept?",
		choices = {
			{ text = "😭 Emotional speech", effects = { Happiness = 40, Looks = 5 }, resultText = "Brought the house to tears. Standing ovation. Beautiful moment.", setFlag = "legend" },
			{ text = "🎤 Thank everyone", effects = { Happiness = 35, Smarts = 3 }, resultText = "Gracious and humble. Mentioned everyone who helped. Class act.", setFlag = "legend" },
			{ text = "🌟 Spotlight young artists", effects = { Happiness = 38, Smarts = 5 }, resultText = "Used your moment to highlight new talent. Legendary generosity.", setFlags = {"legend", "mentor"} },
			{ text = "🎸 Perform instead of speak", effects = { Happiness = 42, Health = -3 }, resultText = "One more performance. Pure magic. They'll never forget this.", setFlag = "legend" },
		},
	},
	
	{
		id = "arts_creative_block",
		minAge = 25, maxAge = 70,
		weight = 25, cooldown = 4,
		emoji = "😔", title = "Creative Block!",
		category = "work",
		requiresFlag = "professional_artist",
		text = "You can't create anything. The inspiration is just... gone. Weeks of nothing. What do you do?",
		choices = {
			{ text = "🏖️ Take a real break", effects = { Happiness = 10, Health = 8 }, resultText = "Rest helped! Ideas slowly returning. Sometimes you need to stop." },
			{ text = "💪 Force through it", effects = { Happiness = -15, Smarts = 3 }, resultText = "Produced work you hate. But kept going. Maybe quantity leads to quality." },
			{ text = "🌍 Travel for inspiration", effects = { Happiness = 15, Money = -3000, Smarts = 5 }, resultText = "New places sparked new ideas! Breakthrough coming!", setFlag = "inspired" },
			{ text = "🍺 Self-medicate", effects = { Happiness = -20, Health = -15 }, resultText = "Made everything worse. Block is deeper now. Need real help.", setFlag = "struggling" },
		},
	},
	
	{
		id = "arts_mentor_request",
		minAge = 40, maxAge = 85,
		weight = 20, cooldown = 5,
		emoji = "🎓", title = "Young Artist Asks for Guidance",
		category = "work",
		requiresFlag = "professional_artist",
		getDynamicData = function()
			return { studentName = LifeEvents.randomFirstName() }
		end,
		text = "%studentName%, a talented young artist, asks you to mentor them. They remind you of yourself. What do you do?",
		choices = {
			{ text = "🤝 Take them under your wing", effects = { Happiness = 20, Smarts = 3 }, resultText = "Watching them grow is deeply fulfilling. Legacy through teaching.", setFlag = "mentor" },
			{ text = "📚 Point them to resources", effects = { Happiness = 8 }, resultText = "Gave them book recommendations and advice. Helped but from a distance." },
			{ text = "😤 Too busy for mentoring", effects = { Happiness = -5 }, resultText = "Turned them down. They found someone else. Slight regret." },
			{ text = "💰 Offer paid lessons", effects = { Happiness = 10, Money = 2000 }, resultText = "Professional arrangement. Good for both! Teaching is rewarding." },
		},
	},
}

return module
