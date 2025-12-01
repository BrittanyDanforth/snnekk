-- LifeEvents/middle_aged_36_55.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- MIDDLE AGE EVENTS (Ages 36-55) - MASSIVE EXPANSION
-- 100+ deeply thought-out events for peak career and family years
-- ═══════════════════════════════════════════════════════════════════════════════

-- LOCAL HELPER FUNCTIONS (no external dependencies)
local FIRST_NAMES = {"Alex", "Jordan", "Taylor", "Casey", "Morgan", "Riley", "Jamie", "Cameron", "Quinn", "Avery", "Parker", "Skyler", "Dakota", "Reese", "Finley", "Sage", "Rowan", "Charlie", "Emerson", "Hayden"}

local function randomFirstName()
	return FIRST_NAMES[math.random(#FIRST_NAMES)]
end

local function hasFriend(state)
	if not state then return false end
	local relationships = state.Relationships or {}
	for _, rel in pairs(relationships) do
		if rel.type == "friend" or rel.category == "friends" then
			return true
		end
	end
	local flags = state.Flags or {}
	return flags.has_friend or flags.has_best_friend or flags.social_butterfly or false
end

local function getFriendName(state)
	if not state then return randomFirstName() end
	local relationships = state.Relationships or {}
	for _, rel in pairs(relationships) do
		if rel.type == "friend" or rel.category == "friends" then
			return rel.name or randomFirstName()
		end
	end
	return randomFirstName()
end

-- Returns actual friend name or nil if no friend exists
-- Use this for events that REQUIRE an existing relationship
local function getActualFriendName(state)
	if not state then return nil end
	local relationships = state.Relationships or {}
	for _, rel in pairs(relationships) do
		if rel.type == "friend" or rel.category == "friends" then
			return rel.name
		end
	end
	return nil
end

-- Check if player has any actual relationships of a given type
local function hasRelationshipOfType(state, relType)
	if not state then return false end
	local relationships = state.Relationships or {}
	for _, rel in pairs(relationships) do
		if rel.type == relType or rel.category == relType then
			return true
		end
	end
	return false
end

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- CAREER PEAK (Ages 36-45)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_executive_promotion",
		minAge = 36, maxAge = 50,
		weight = 25, oneTime = true,
		emoji = "👔", title = "Executive Opportunity!",
		category = "career",
		requiresFlag = "employed", -- CRITICAL: Must have a job to get executive promotion!
		blockIfFlag = "executive", -- Only one executive promotion
		getDynamicData = function()
			local titles = {"Vice President", "Director", "Senior Director", "Chief Officer", "Partner"}
			local salary = math.random(150000, 350000)
			return { title = titles[math.random(#titles)], salary = salary }
		end,
		text = "There's an opening for %title%! Salary: $%salary%! How do you approach it?",
		choices = {
			{ 
				text = "📊 Prepare a strong pitch", 
				effects = { Happiness = 18, Smarts = 5 }, 
				resultText = "Nailed it! Promoted! Corner office, here you come!", 
				setFlag = "executive",
				setJob = { id = "executive", title = "%title%", salary = 200000 }
			},
			{ 
				text = "💼 Express interest formally", 
				effects = { Happiness = 10, Smarts = 4 }, 
				resultText = "Got it! Big responsibility but bigger paycheck!", 
				setFlag = "executive",
				setJob = { id = "executive", title = "%title%", salary = 175000 }
			},
			{ text = "⚖️ Decline - work-life balance", effects = { Happiness = 4, Smarts = 3, Money = 20000 }, resultText = "Turned it down for sanity. Got a smaller raise for staying." },
			{ text = "🤷 Don't pursue it", effects = { Happiness = -10 }, resultText = "Someone more aggressive got it. Watching them in the corner office stings." },
		},
	},
	
	{
		id = "m_midlife_reflection",
		minAge = 40, maxAge = 45,
		weight = 50, oneTime = true, milestone = true,
		emoji = "🤔", title = "Midlife Crossroads",
		category = "family",
		text = "You're halfway through life. Is this where you thought you'd be?",
		choices = {
			{ text = "😊 Content and grateful", effects = { Happiness = 12, Smarts = 3 }, resultText = "Life isn't perfect, but it's good. Gratitude unlocked.", setFlag = "content" },
			{ text = "🔄 Need a change", effects = { Happiness = 4, Smarts = 5 }, resultText = "Time for reinvention! It's not too late!", setFlag = "midlife_change" },
			{ text = "😰 Midlife crisis!", effects = { Happiness = -8, Money = -10000 }, resultText = "Bought a sports car. Might get a tattoo. What is happening?!" },
			{ text = "🎯 Doubling down", effects = { Happiness = 8, Smarts = 4 }, resultText = "This path is right. Full steam ahead!", setFlag = "focused" },
		},
	},
	
	{
		id = "m_kids_growing_up",
		minAge = 38, maxAge = 50,
		weight = 35, cooldown = 3,
		requiresFlag = "has_child",
		emoji = "👨‍👩‍👧", title = "Watching Kids Grow",
		category = "family",
		getDynamicData = function()
			local events = {"graduated middle school", "started high school", "got their license", "had first date", "got into college"}
			return { event = events[math.random(#events)] }
		end,
		text = "Your child %event%! Where did the time go?!",
		choices = {
			{ text = "😭 So proud!", effects = { Happiness = 12 }, resultText = "Tears of joy! They're growing up so fast!" },
			{ text = "📸 Documenting everything", effects = { Happiness = 8 }, resultText = "Every milestone recorded! Future memories." },
			{ text = "🤯 Feeling old", effects = { Happiness = 2 }, resultText = "When did they get so big? Time flies." },
			{ text = "💪 Great parenting moment", effects = { Happiness = 10, Smarts = 2 }, resultText = "You raised them right. They're thriving!" },
		},
	},
	
	{
		id = "m_teenager_drama",
		minAge = 38, maxAge = 52,
		weight = 30, cooldown = 2,
		requiresFlag = "has_child",
		emoji = "😤", title = "Parenting a Teenager",
		category = "family",
		getDynamicData = function()
			local dramas = {"caught them sneaking out", "found concerning texts", "got called to school", "they failed a class", "door-slamming fights", "they said they hate you"}
			return { drama = dramas[math.random(#dramas)] }
		end,
		text = "Parenting a teen is HARD. Today: %drama%!",
		choices = {
			{ text = "🗣️ Open conversation", effects = { Happiness = 4, Smarts = 4 }, resultText = "You talked it through. Progress made.", setFlag = "good_parent" },
			{ text = "😤 Grounded them", effects = { Happiness = -2, Smarts = 2 }, resultText = "Consequences served. They're furious but you're the parent." },
			{ text = "😭 Where did I go wrong?", effects = { Happiness = -6 }, resultText = "Questioning everything. This stage is tough." },
			{ text = "🤷 Pick your battles", effects = { Happiness = 2, Smarts = 3 }, resultText = "Not everything needs a fight. Let some things slide." },
		},
	},
	
	{
		id = "m_empty_nest",
		minAge = 45, maxAge = 55,
		weight = 35, oneTime = true,
		requiresFlag = "has_child",
		emoji = "🏠", title = "Empty Nest!",
		category = "family",
		text = "The last kid moved out. The house is quiet. Too quiet.",
		choices = {
			{ text = "😢 Miss them already", effects = { Happiness = -6 }, resultText = "The silence is deafening. You did your job." },
			{ text = "🎉 FREEDOM!", effects = { Happiness = 12, Money = 5000 }, resultText = "Walk around naked! Spontaneous trips! YOUR time!", setFlag = "empty_nester" },
			{ text = "🤗 Proud of them", effects = { Happiness = 8 }, resultText = "You raised independent adults. Success!", setFlag = "empty_nester" },
			{ text = "🔄 Reinvent yourself", effects = { Happiness = 6, Smarts = 4 }, resultText = "Time to rediscover who YOU are!", setFlags = {"empty_nester", "self_discovery"} },
		},
	},
	
	{
		id = "m_career_pivot_midlife",
		minAge = 40, maxAge = 50,
		weight = 20, oneTime = true,
		emoji = "🔀", title = "Late Career Change",
		category = "career",
		requiresFlag = "employed", -- Must have a career to pivot from!
		getDynamicData = function()
			local changes = {"consulting", "teaching", "starting a business", "non-profit work", "creative field", "complete industry change"}
			return { change = changes[math.random(#changes)] }
		end,
		text = "You're considering switching to %change%. Is it too late to start over?",
		choices = {
			{ text = "🚀 Go for it!", effects = { Happiness = 12, Money = -10000, Smarts = 5 }, resultText = "Never too late! Your experience is valuable!", setFlag = "career_reinvention" },
			{ text = "🤔 Too much to lose", effects = { Happiness = -4, Smarts = 2 }, resultText = "The golden handcuffs are real. You stayed put." },
			{ text = "📈 Side transition", effects = { Happiness = 8, Smarts = 4 }, resultText = "Slowly moving over while keeping safety net!", setFlag = "career_reinvention" },
			{ text = "🎯 Found new passion!", effects = { Happiness = 15, Smarts = 6 }, resultText = "This is what you were meant to do all along!", setFlags = {"career_reinvention", "passionate"} },
		},
	},
	
	{
		id = "m_buying_dream_home",
		minAge = 38, maxAge = 52,
		weight = 20, oneTime = true,
		emoji = "🏡", title = "Upgrading to Dream Home!",
		category = "family",
		getDynamicData = function()
			local features = {"pool", "home office", "beautiful yard", "gourmet kitchen", "extra bedrooms", "amazing view"}
			return { feature = features[math.random(#features)] }
		end,
		text = "Finally! The dream home with a %feature%! You've worked hard for this.",
		choices = {
			{ text = "🏡 Worth every penny!", effects = { Happiness = 18, Money = -100000 }, resultText = "This is HOME. Everything you wanted!", setFlag = "dream_home" },
			{ text = "🔨 Fixer but dream location", effects = { Happiness = 10, Money = -60000 }, resultText = "Needs work but the location is perfect!", setFlag = "dream_home" },
			{ text = "😅 House poor", effects = { Happiness = 6, Money = -120000 }, resultText = "Stretched thin but you made it!", setFlag = "dream_home" },
			{ text = "🏠 Staying put", effects = { Happiness = 4, Money = 0 }, resultText = "Maybe the dream was inside all along?" },
		},
	},
	
	{
		id = "m_health_screening",
		minAge = 40, maxAge = 55,
		weight = 35, cooldown = 3,
		emoji = "🏥", title = "Health Screening Time",
		category = "health",
		getDynamicData = function()
			local screenings = {"colonoscopy", "mammogram/prostate exam", "cardiac stress test", "full bloodwork", "comprehensive physical"}
			return { screening = screenings[math.random(#screenings)] }
		end,
		text = "Time for your %screening%. Preventive care matters at this age. What do you do?",
		choices = {
			{ text = "✅ Schedule and go", effects = { Health = 5, Happiness = 10 }, resultText = "All clear! Clean bill of health! Good choice scheduling that!", setFlag = "health_conscious" },
			{ text = "📅 Put it off a bit", effects = { Health = -2, Happiness = -4, Smarts = 3 }, resultText = "Eventually went. Found something to monitor. Should've gone sooner." },
			{ text = "😬 Skip it entirely", effects = { Happiness = 2, Health = -8 }, resultText = "Ignored it. Hope nothing's brewing. Probably should schedule..." },
			{ text = "🥗 Go AND improve lifestyle", effects = { Health = 8, Happiness = 4 }, resultText = "Went, got good results, AND started eating better! Double win!", setFlags = {"health_conscious", "lifestyle_change"} },
		},
	},
	
	{
		id = "m_aging_parents",
		minAge = 40, maxAge = 55,
		weight = 35, cooldown = 3,
		emoji = "👴", title = "Caring for Aging Parents",
		category = "family",
		getDynamicData = function()
			local issues = {"mobility issues", "memory concerns", "medical emergency", "can't live alone anymore", "financial troubles"}
			return { issue = issues[math.random(#issues)] }
		end,
		text = "Your parent is dealing with %issue%. The roles are reversing.",
		choices = {
			{ text = "🏠 Move them in", effects = { Happiness = -4, Money = -5000, Smarts = 2 }, resultText = "Difficult but right. Family takes care of family.", setFlag = "caregiver" },
			{ text = "🏥 Assisted living", effects = { Happiness = -6, Money = -20000 }, resultText = "Hard decision but they need professional care.", setFlag = "caregiver" },
			{ text = "🤝 Share the load", effects = { Happiness = 2, Money = -3000 }, resultText = "Siblings/family helping together. Team effort.", setFlag = "caregiver" },
			{ text = "😔 Struggling to cope", effects = { Happiness = -8, Health = -3 }, resultText = "Caregiver burnout is real. Get support." },
		},
	},
	
	{
		id = "m_divorce",
		minAge = 35, maxAge = 55,
		weight = 15, oneTime = true,
		requiresFlag = "married",
		emoji = "💔", title = "Marriage Ending",
		category = "family",
		text = "After years together, your marriage is ending. This is devastating.",
		choices = {
			{ text = "💔 Devastated", effects = { Happiness = -25, Money = -50000 }, resultText = "Everything you built... gone. One day at a time.", clearFlags = {"married"}, setFlag = "divorced" },
			{ text = "⚖️ Amicable split", effects = { Happiness = -10, Money = -30000 }, resultText = "Sad but civil. Better for everyone, especially kids.", clearFlags = {"married"}, setFlag = "divorced" },
			{ text = "💪 Fresh start", effects = { Happiness = -5, Money = -40000, Smarts = 3 }, resultText = "It wasn't working. Time for chapter two.", clearFlags = {"married"}, setFlag = "divorced" },
			{ text = "😤 Ugly battle", effects = { Happiness = -20, Money = -80000 }, resultText = "Lawyers, fights, heartache. Years of recovery ahead.", clearFlags = {"married"}, setFlag = "divorced" },
		},
	},
	
	{
		id = "m_finding_love_again",
		minAge = 40, maxAge = 55,
		weight = 20, oneTime = true,
		requiresFlag = "divorced",
		emoji = "💕", title = "Finding Love Again",
		category = "social",
		getDynamicData = function()
			return { partnerName = randomFirstName() }
		end,
		text = "You met %partnerName%. Could this be a second chance at love?",
		choices = {
			{ text = "💕 Falling again!", effects = { Happiness = 15 }, resultText = "Love at this age hits different. It's real.", setFlag = "new_relationship" },
			{ text = "🤔 Taking it slow", effects = { Happiness = 6, Smarts = 3 }, resultText = "Been hurt before. Not rushing.", setFlag = "new_relationship" },
			{ text = "💒 Got remarried!", effects = { Happiness = 18, Money = -10000 }, resultText = "Second time's the charm! You found the one!", setFlags = {"remarried", "married"}, clearFlags = {"divorced"} },
			{ text = "🚶 Better alone", effects = { Happiness = 4, Smarts = 2 }, resultText = "You're happy single. That's valid too." },
		},
	},
	
	{
		id = "m_grandparent",
		minAge = 45, maxAge = 60,
		weight = 25, oneTime = true,
		requiresFlag = "has_child",
		emoji = "👶", title = "You're a Grandparent!",
		category = "family",
		getDynamicData = function()
			local names = {"Oliver", "Emma", "Charlotte", "Liam", "Amelia", "Noah"}
			return { grandchildName = names[math.random(#names)] }
		end,
		text = "Your child had a baby! Say hello to %grandchildName%! You're a grandparent!",
		choices = {
			{ text = "🥰 Best feeling ever!", effects = { Happiness = 20 }, resultText = "All the love of parenting with none of the sleepless nights!", setFlag = "grandparent" },
			{ text = "👴 Feel old now", effects = { Happiness = 8 }, resultText = "Grandparent?! When did THAT happen?!", setFlag = "grandparent" },
			{ text = "🎁 Spoiling season!", effects = { Happiness = 15, Money = -2000 }, resultText = "Grandparents get to spoil. It's the rules!", setFlag = "grandparent" },
			{ text = "👨‍👩‍👧 Circle of life", effects = { Happiness = 12, Smarts = 2 }, resultText = "Watching your child become a parent. Beautiful.", setFlag = "grandparent" },
		},
	},
	
	{
		id = "m_bucket_list",
		minAge = 42, maxAge = 55,
		weight = 25, cooldown = 3,
		emoji = "📝", title = "Bucket List Adventure!",
		category = "social",
		getDynamicData = function()
			local items = {"skydiving", "exotic trip", "learning an instrument", "writing a book", "running a marathon", "seeing Northern Lights", "learning a language"}
			return { item = items[math.random(#items)] }
		end,
		text = "Time to cross '%item%' off your bucket list!",
		choices = {
			{ text = "🎉 DID IT!", effects = { Happiness = 18, Health = 3, Money = -3000 }, resultText = "Bucket list ACHIEVEMENT! Life is for living!", setFlag = "adventurous" },
			{ text = "😅 Almost died but worth it", effects = { Happiness = 12, Health = -2, Money = -2000 }, resultText = "Scary but exhilarating! Story for life!" },
			{ text = "🤔 Changed my mind", effects = { Happiness = 2 }, resultText = "Maybe it was better as a dream. That's okay." },
			{ text = "📝 Added more to list", effects = { Happiness = 8, Smarts = 2 }, resultText = "One down, many more to go! Life is an adventure!", setFlag = "adventurous" },
		},
	},
	
	{
		id = "m_workplace_politics",
		minAge = 36, maxAge = 55,
		weight = 25, cooldown = 3,
		emoji = "😤", title = "Office Politics!",
		category = "career",
		requiresFlag = "employed", -- Must be employed to deal with office politics!
		getDynamicData = function()
			local situations = {"someone took credit for your work", "layoff rumors", "toxic boss", "backstabbing colleague", "merger anxiety"}
			return { situation = situations[math.random(#situations)] }
		end,
		text = "Workplace drama: %situation%. Corporate life is exhausting.",
		choices = {
			{ text = "🎭 Play the game", effects = { Happiness = -2, Smarts = 4, Money = 3000 }, resultText = "Sometimes you gotta play politics. Survived." },
			{ text = "🚶 Above it all", effects = { Happiness = 4, Smarts = 2 }, resultText = "Not getting involved. Do your job, go home." },
			{ text = "🗣️ Confront it directly", effects = { Happiness = 4, Smarts = 3 }, resultText = "Called it out. Risky but respected now.", setFlag = "direct_communicator" },
			{ text = "📦 Update the resume", effects = { Happiness = 2, Smarts = 2 }, resultText = "Life's too short. Exploring other options." },
		},
	},
	
	{
		id = "m_financial_milestone",
		minAge = 40, maxAge = 55,
		weight = 25, cooldown = 3,
		emoji = "💰", title = "Financial Milestone!",
		category = "career",
		requiresFlag = "employed", -- Must have income to hit financial milestones!
		getDynamicData = function()
			local milestones = {"paid off the house", "hit six figures", "retirement account goal", "college fund complete", "became debt-free"}
			return { milestone = milestones[math.random(#milestones)] }
		end,
		text = "Huge financial win: %milestone%! Years of hard work paid off!",
		choices = {
			{ text = "🎉 Celebrate!", effects = { Happiness = 15, Money = 20000 }, resultText = "Pop the champagne! You earned this!", setFlag = "financially_secure" },
			{ text = "📈 Keep building", effects = { Happiness = 8, Money = 30000, Smarts = 2 }, resultText = "Great milestone but there's more to achieve!", setFlag = "financially_secure" },
			{ text = "🙏 Grateful", effects = { Happiness = 12, Smarts = 2 }, resultText = "Not everyone gets here. Appreciation mode.", setFlag = "financially_secure" },
			{ text = "🎁 Help others", effects = { Happiness = 10, Money = 10000 }, resultText = "Paid off parents' mortgage. Giving back!", setFlags = {"financially_secure", "generous"} },
		},
	},
	
	{
		id = "m_hobby_mastery",
		minAge = 38, maxAge = 55,
		weight = 25, cooldown = 3,
		emoji = "⭐", title = "Hobby Achievement!",
		category = "social",
		getDynamicData = function()
			local hobbies = {"golf", "cooking", "woodworking", "gardening", "photography", "music", "art", "writing", "collecting"}
			local achievements = {"won a competition", "got featured somewhere", "reached expert level", "taught others", "sold your work"}
			return { hobby = hobbies[math.random(#hobbies)], achievement = achievements[math.random(#achievements)] }
		end,
		text = "Your %hobby% hobby: You %achievement%!",
		choices = {
			{ text = "🏆 Peak hobby life!", effects = { Happiness = 12, Smarts = 3 }, resultText = "All those hours paid off! Mastery achieved!", setFlag = "hobby_master" },
			{ text = "🤔 Could turn pro?", effects = { Happiness = 8, Money = 2000, Smarts = 4 }, resultText = "People are paying for your skills!", setFlag = "hobby_master" },
			{ text = "🎓 Teaching others", effects = { Happiness = 10, Smarts = 4 }, resultText = "Passing on knowledge. Full circle!", setFlags = {"hobby_master", "mentor"} },
			{ text = "🏅 Humble about it", effects = { Happiness = 8, Smarts = 2 }, resultText = "Still learning. Always a student.", setFlag = "hobby_master" },
		},
	},
	
	{
		id = "m_health_scare",
		minAge = 45, maxAge = 60,
		weight = 20, oneTime = true,
		emoji = "🏥", title = "Health Scare",
		category = "health",
		getDynamicData = function()
			local scares = {"suspicious test results", "chest pain scare", "scary symptoms", "emergency room visit", "waiting for biopsy results"}
			return { scare = scares[math.random(#scares)] }
		end,
		text = "A %scare% has you facing your mortality. Life feels fragile.",
		choices = {
			{ text = "✅ False alarm!", effects = { Health = 2, Happiness = 15 }, resultText = "Thank goodness! Clean bill of health. Wake-up call.", setFlag = "health_scare_survivor" },
			{ text = "🏥 Need treatment", effects = { Health = -10, Happiness = -10, Money = -20000 }, resultText = "Caught early. Treatment ahead but prognosis good.", setFlag = "health_battle" },
			{ text = "🔄 Complete lifestyle change", effects = { Health = 8, Happiness = 6 }, resultText = "Scared you into taking care of yourself!", setFlags = {"health_scare_survivor", "health_focused"} },
			{ text = "🙏 New perspective", effects = { Health = 4, Happiness = 8, Smarts = 5 }, resultText = "Every day is a gift. Prioritizing what matters.", setFlags = {"health_scare_survivor", "grateful"} },
		},
	},
	
	{
		id = "m_mentor_role",
		minAge = 40, maxAge = 55,
		weight = 25, oneTime = true,
		emoji = "🎓", title = "Becoming a Mentor",
		category = "career",
		requiresFlag = "employed", -- Must have work experience to mentor!
		getDynamicData = function()
			return { menteeName = randomFirstName() }
		end,
		text = "Young professional %menteeName% looks up to you at work. Want to mentor them?",
		choices = {
			{ text = "🤝 Happy to guide!", effects = { Happiness = 10, Smarts = 4 }, resultText = "Paying it forward! Helping the next generation.", setFlag = "mentor" },
			{ text = "📚 Sharing wisdom", effects = { Happiness = 8, Smarts = 5 }, resultText = "Your experience matters to someone. Beautiful.", setFlag = "mentor" },
			{ text = "🔄 Learning too!", effects = { Happiness = 8, Smarts = 6 }, resultText = "They teach you as much as you teach them!", setFlags = {"mentor", "lifelong_learner"} },
			{ text = "⏰ No bandwidth", effects = { Happiness = -2, Smarts = 2 }, resultText = "Too busy right now. Maybe later." },
		},
	},
	
	{
		id = "m_reunion",
		minAge = 38, maxAge = 55,
		weight = 20, cooldown = 5,
		emoji = "🎓", title = "Class Reunion!",
		category = "social",
		getDynamicData = function()
			local years = {20, 25, 30}
			return { years = years[math.random(#years)] }
		end,
		text = "Your %years%-year reunion! Time to see how everyone turned out!",
		choices = {
			{ text = "🌟 Looking great!", effects = { Happiness = 12, Looks = 3 }, resultText = "You've aged well! People noticed!", setFlag = "aged_well" },
			{ text = "🤝 Reconnecting!", effects = { Happiness = 10 }, resultText = "Found old friends! Some bonds never break." },
			{ text = "🤔 Weird comparisons", effects = { Happiness = -2 }, resultText = "Everyone's on different paths. Hard not to compare." },
			{ text = "🏆 Success story!", effects = { Happiness = 15, Looks = 2 }, resultText = "You're the one who 'made it'! Feels good.", setFlag = "successful" },
		},
	},
	
	{
		id = "m_turning_50",
		minAge = 50, maxAge = 50,
		weight = 100, milestone = true, oneTime = true,
		emoji = "5️⃣0️⃣", title = "The Big 5-0!",
		category = "family",
		text = "Half a century! 50 years of life! How are you celebrating?",
		choices = {
			{ text = "🎉 Huge party!", effects = { Happiness = 15, Money = -5000 }, resultText = "Epic celebration! Everyone you love together!" },
			{ text = "🌴 Trip of a lifetime", effects = { Happiness = 18, Money = -10000, Health = 2 }, resultText = "50th birthday vacation! Bucket list location!", setFlag = "milestone_traveler" },
			{ text = "🤔 Quiet reflection", effects = { Happiness = 6, Smarts = 5 }, resultText = "50 years of wisdom. Not bad, self. Not bad." },
			{ text = "💪 Best shape of my life!", effects = { Happiness = 12, Health = 8, Looks = 4 }, resultText = "50 is the new 30! Peak fitness!", setFlag = "fit_at_50" },
		},
	},
	
	{
		id = "m_kid_wedding",
		minAge = 48, maxAge = 60,
		weight = 20, oneTime = true,
		requiresFlag = "has_child",
		emoji = "💒", title = "Your Child's Wedding!",
		category = "family",
		getDynamicData = function()
			return { spouseName = randomFirstName() }
		end,
		text = "Your baby is getting married to %spouseName%! How are you feeling?",
		choices = {
			{ text = "😭 Emotional wreck", effects = { Happiness = 12 }, resultText = "Tears all day! But happy tears. Mostly.", setFlag = "child_married" },
			{ text = "💸 Paying for it", effects = { Happiness = 6, Money = -30000 }, resultText = "Worth every penny to see them happy!", setFlag = "child_married" },
			{ text = "🥂 Father/Mother speech!", effects = { Happiness = 15, Looks = 2 }, resultText = "Your speech was perfect! Not a dry eye!", setFlag = "child_married" },
			{ text = "🤝 Welcoming new family", effects = { Happiness = 10 }, resultText = "Gained a new son/daughter. Family grows!", setFlag = "child_married" },
		},
	},
	
	{
		id = "m_retirement_planning",
		minAge = 50, maxAge = 58,
		weight = 40, oneTime = true,
		emoji = "📊", title = "Retirement Planning Serious",
		category = "career",
		requiresFlag = "employed", -- Must have job to plan retirement from it!
		text = "Meeting with financial advisor. Is retirement actually possible?",
		choices = {
			{ text = "✅ On track!", effects = { Happiness = 12, Smarts = 4 }, resultText = "The numbers work! Retirement is in sight!", setFlag = "retirement_ready" },
			{ text = "😰 Need to catch up", effects = { Happiness = -4, Smarts = 5 }, resultText = "Behind schedule. Max out contributions starting NOW." },
			{ text = "🏡 Downsize plans", effects = { Happiness = 4, Smarts = 4 }, resultText = "Adjusted expectations. Still achievable!", setFlag = "retirement_planned" },
			{ text = "💼 Work forever?", effects = { Happiness = -6 }, resultText = "Retirement seems like a dream. Keep working." },
		},
	},
	
	{
		id = "m_parent_loss",
		minAge = 40, maxAge = 60,
		weight = 15, oneTime = true,
		emoji = "🕊️", title = "Losing a Parent",
		category = "family",
		text = "Your parent passed away. No matter how prepared you think you are...",
		choices = {
			{ text = "😭 Devastating", effects = { Happiness = -20, Health = -5 }, resultText = "The grief is overwhelming. One day at a time.", setFlag = "lost_parent" },
			{ text = "🤗 Celebrating their life", effects = { Happiness = -8, Smarts = 3 }, resultText = "A life well-lived. Honoring their memory.", setFlag = "lost_parent" },
			{ text = "💔 Regrets", effects = { Happiness = -15 }, resultText = "Things left unsaid. Things undone. Process the guilt.", setFlag = "lost_parent" },
			{ text = "🙏 Grateful for time had", effects = { Happiness = -10, Smarts = 4 }, resultText = "Lucky to have had them this long. Cherished memories.", setFlag = "lost_parent" },
		},
	},
	
	{
		id = "m_affair_discovery",
		minAge = 38, maxAge = 55,
		weight = 8, oneTime = true,
		requiresFlag = "married",
		emoji = "💔", title = "Betrayal",
		category = "family",
		text = "You discovered infidelity in your marriage. Everything is shattered.",
		choices = {
			{ text = "💔 Divorce", effects = { Happiness = -20, Money = -40000 }, resultText = "Trust destroyed. Marriage over.", clearFlags = {"married"}, setFlag = "divorced_betrayed" },
			{ text = "🤝 Try to work through it", effects = { Happiness = -10, Money = -5000 }, resultText = "Therapy, hard conversations. Long road to maybe." },
			{ text = "😔 You were the one...", effects = { Happiness = -15, Smarts = -2 }, resultText = "The guilt is crushing. You made a terrible mistake." },
			{ text = "🔥 Rage mode", effects = { Happiness = -12, Smarts = -3, Money = -10000 }, resultText = "Anger takes over. Destructive but understandable." },
		},
	},
	
	{
		id = "m_community_leadership",
		minAge = 40, maxAge = 55,
		weight = 20, oneTime = true,
		emoji = "🏛️", title = "Community Leadership Role",
		category = "social",
		getDynamicData = function()
			local roles = {"school board", "local council", "HOA president", "charity board", "community organization", "religious leadership"}
			return { role = roles[math.random(#roles)] }
		end,
		text = "You've been asked to serve on the %role%. Community needs you!",
		choices = {
			{ text = "🙋 Happy to serve!", effects = { Happiness = 8, Smarts = 3 }, resultText = "Making a difference locally! This matters!", setFlag = "community_leader" },
			{ text = "😅 Thankless job", effects = { Happiness = -2, Smarts = 4 }, resultText = "Everyone has opinions. Politics even at local level." },
			{ text = "🌟 Making real change", effects = { Happiness = 12, Smarts = 5 }, resultText = "Your initiatives are improving the community!", setFlags = {"community_leader", "changemaker"} },
			{ text = "⏰ No time", effects = { Happiness = 2 }, resultText = "Life is too full. Can't take this on." },
		},
	},
	
	{
		id = "m_legacy_thinking",
		minAge = 50, maxAge = 60,
		weight = 25, oneTime = true,
		emoji = "📖", title = "Thinking About Legacy",
		category = "family",
		text = "What will you be remembered for? What mark will you leave?",
		choices = {
			{ text = "👨‍👩‍👧 Family is legacy", effects = { Happiness = 12, Smarts = 3 }, resultText = "Raised good humans. That's what matters." },
			{ text = "💼 Professional impact", effects = { Happiness = 8, Smarts = 4 }, resultText = "Your work changed things. Career mattered." },
			{ text = "❤️ Lives touched", effects = { Happiness = 10, Smarts = 3 }, resultText = "The people you helped, loved, influenced. That's legacy." },
			{ text = "📝 Write it down", effects = { Happiness = 6, Smarts = 5 }, resultText = "Started memoirs, documenting your story.", setFlag = "writing_legacy" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- EXTENDED MIDDLE AGE EVENTS
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_career_plateau",
		minAge = 40, maxAge = 50,
		weight = 35, oneTime = true,
		emoji = "📊", title = "Career Plateau",
		category = "career",
		requiresFlag = "employed", -- CRITICAL: Must have a career to plateau!
		text = "You've been at the same level for years. Is this it? Have you peaked?",
		choices = {
			{ text = "🚀 Push for promotion", effects = { Smarts = 6, Happiness = 4, Money = 5000 }, resultText = "Extra effort paid off! Moving up!", setFlag = "ambitious" },
			{ text = "😌 Content where you are", effects = { Happiness = 8 }, resultText = "Not everyone needs to be CEO. You're happy." },
			{ text = "🔄 Complete career change", effects = { Happiness = 4, Smarts = 8, Money = -10000 }, resultText = "Starting fresh in a new field. Scary but exciting!", setFlag = "career_changer" },
			{ text = "💼 Start your own business", effects = { Smarts = 10, Happiness = 6, Money = -20000 }, resultText = "Entrepreneurship at 40+? Why not!", setFlag = "entrepreneur" },
		},
	},
	
	{
		id = "m_aging_parent",
		minAge = 40, maxAge = 55,
		weight = 30, cooldown = 5,
		emoji = "👴", title = "Aging Parent Needs Help",
		category = "family",
		text = "Your parent's health is declining. They need more care than they'll admit.",
		choices = {
			{ text = "🏠 Move them in with you", effects = { Happiness = 4, Money = -8000 }, resultText = "Family under one roof. It's hard but right." },
			{ text = "🏥 Help find assisted living", effects = { Happiness = -2, Money = -30000 }, resultText = "They need professional care. Expensive but necessary." },
			{ text = "📅 Visit more often", effects = { Happiness = 2, Money = -2000 }, resultText = "Weekly visits. Trying to be there more." },
			{ text = "💔 Too far away to help", effects = { Happiness = -8 }, resultText = "Distance makes this so hard. Guilt is heavy." },
		},
	},
	
	{
		id = "m_health_scare",
		minAge = 42, maxAge = 55,
		weight = 25, oneTime = true,
		emoji = "⚕️", title = "Health Scare",
		category = "health",
		getDynamicData = function()
			local issues = {"high blood pressure", "suspicious mole", "chest pain", "elevated cholesterol", "pre-diabetes"}
			return { issue = issues[math.random(#issues)] }
		end,
		text = "Doctor found %issue%. It's a wake-up call.",
		choices = {
			{ text = "🏃 Complete lifestyle overhaul", effects = { Health = 15, Happiness = 4 }, resultText = "Diet, exercise, stress management. New you!", setFlag = "health_focused" },
			{ text = "💊 Medication if needed", effects = { Health = 8, Money = -2000 }, resultText = "Modern medicine helping manage it." },
			{ text = "😰 Anxiety about mortality", effects = { Happiness = -10, Health = 5 }, resultText = "The fear motivates some changes at least." },
			{ text = "🙈 Ignore it", effects = { Health = -10 }, resultText = "Bad idea. This could get worse.", setFlag = "health_denial" },
		},
	},
	
	{
		id = "m_empty_nest",
		minAge = 45, maxAge = 55,
		weight = 35, oneTime = true,
		emoji = "🪺", title = "Empty Nest",
		category = "family",
		requiresFlag = "has_children",
		text = "Last kid moved out. The house is suddenly... quiet.",
		choices = {
			{ text = "😢 Sad and lost", effects = { Happiness = -10 }, resultText = "Your purpose was raising them. What now?" },
			{ text = "🎉 FREEDOM!", effects = { Happiness = 15, Money = 3000 }, resultText = "Privacy! No more schedules! Travel!", setFlag = "empty_nester" },
			{ text = "🛠️ Renovate their room", effects = { Happiness = 6, Money = -8000 }, resultText = "Guest room? Home gym? The possibilities!" },
			{ text = "💑 Rediscover your partner", effects = { Happiness = 12 }, resultText = "It's like dating again! Just the two of you!" },
		},
	},
	
	{
		id = "m_peak_earning",
		minAge = 45, maxAge = 55,
		weight = 30, oneTime = true,
		emoji = "💰", title = "Peak Earning Years",
		category = "career",
		requiresFlag = "employed", -- CRITICAL: Must have income to be in peak earning years!
		text = "You're in your prime earning years. Salary is highest it's ever been!",
		choices = {
			{ text = "💵 Max retirement savings", effects = { Money = 20000, Happiness = 4 }, resultText = "401k maxed! Future you says thanks!", setFlag = "retirement_saver" },
			{ text = "🏠 Upgrade lifestyle", effects = { Money = -15000, Happiness = 10, Looks = 3 }, resultText = "Nice car, nice house, nice everything!" },
			{ text = "📊 Invest aggressively", effects = { Money = 30000, Happiness = 5 }, resultText = "Making your money work harder than you!", setFlag = "investor" },
			{ text = "🌴 What's money for?", effects = { Money = -20000, Happiness = 12 }, resultText = "You only live once! Experiences over savings!" },
		},
	},
	
	{
		id = "m_mentoring_next_gen",
		minAge = 40, maxAge = 55,
		weight = 25, cooldown = 4,
		emoji = "🎓", title = "Mentoring the Next Generation",
		category = "career",
		requiresFlag = "employed", -- CRITICAL: Must be working to mentor at work!
		getDynamicData = function()
			return { menteeName = randomFirstName() }
		end,
		text = "Young %menteeName% at work looks up to you. They could use guidance.",
		choices = {
			{ text = "🌟 Be their mentor", effects = { Happiness = 10, Smarts = 3 }, resultText = "Passing on your wisdom. They're flourishing!", setFlag = "mentor" },
			{ text = "📚 Share resources, not time", effects = { Happiness = 4, Smarts = 2 }, resultText = "Sent them books, courses. Helpful but distant." },
			{ text = "😤 Earn it like I did", effects = { Happiness = -2 }, resultText = "Nobody helped you. Why should you?" },
			{ text = "🤝 Become lifelong friends", effects = { Happiness = 12, Smarts = 4 }, resultText = "Great mentor-mentee bond became genuine friendship!" },
		},
	},
	
	{
		id = "m_hobby_mastery",
		minAge = 40, maxAge = 55,
		weight = 25, cooldown = 5,
		emoji = "🎯", title = "Hobby Mastery",
		category = "social",
		getDynamicData = function()
			local hobbies = {"woodworking", "painting", "music", "gardening", "photography", "writing", "cooking"}
			return { hobby = hobbies[math.random(#hobbies)] }
		end,
		text = "Your %hobby% skills have reached an impressive level after years of practice!",
		choices = {
			{ text = "🏆 Enter competitions", effects = { Happiness = 10, Smarts = 4 }, resultText = "Won third place! Not bad for a hobbyist!", setFlag = "hobby_competitor" },
			{ text = "💵 Sell your work", effects = { Happiness = 8, Money = 5000 }, resultText = "People pay for quality! Side income!", setFlag = "artisan" },
			{ text = "🎓 Teach others", effects = { Happiness = 12, Smarts = 5 }, resultText = "Teaching classes now. Fulfilling!", setFlag = "hobby_teacher" },
			{ text = "🧘 It's just for me", effects = { Happiness = 10 }, resultText = "No monetization needed. Pure joy." },
		},
	},
	
	{
		id = "m_reconnecting_old_friends",
		minAge = 40, maxAge = 55,
		weight = 20, cooldown = 4,
		emoji = "👋", title = "Reconnecting with Old Friends",
		category = "social",
		-- This event introduces a NEW old acquaintance, so random name is appropriate
		-- But add a flag so player has some social history
		requiresAnyFlag = {"ever_had_friend", "college_graduate", "high_school_diploma", "social_butterfly", "had_childhood_friend"},
		getDynamicData = function()
			return { friendName = randomFirstName() }
		end,
		text = "%friendName% from college/high school reached out after decades. Virtual reunion happening!",
		choices = {
			{ text = "🥳 Amazing to catch up!", effects = { Happiness = 12 }, resultText = "So many memories! Promised to stay in touch this time!" },
			{ text = "😬 So different now", effects = { Happiness = 2 }, resultText = "People change. It was nice but... awkward." },
			{ text = "🍻 Plan a trip together", effects = { Happiness = 10, Money = -3000 }, resultText = "Road trip like the old days! Well, with more bathroom breaks." },
			{ text = "👻 Ghost them", effects = { Happiness = -2 }, resultText = "That chapter is closed. No response sent." },
		},
	},
	
	{
		id = "m_kids_success",
		minAge = 45, maxAge = 55,
		weight = 25, cooldown = 5,
		emoji = "🎓", title = "Children's Success!",
		category = "family",
		requiresFlag = "has_children",
		getDynamicData = function()
			local achievements = {"graduated college", "got their dream job", "got engaged", "published something", "started a business"}
			return { achievement = achievements[math.random(#achievements)] }
		end,
		text = "Your kid just %achievement%! You're so proud!",
		choices = {
			{ text = "😭 Happy tears", effects = { Happiness = 15 }, resultText = "All those years of parenting... this makes it worth it." },
			{ text = "🎉 Throw a celebration", effects = { Happiness = 12, Money = -5000 }, resultText = "Party time! Everyone must know!" },
			{ text = "📸 Social media brag", effects = { Happiness = 8 }, resultText = "All your friends are jealous. As they should be." },
			{ text = "🤔 Did I do that right?", effects = { Happiness = 6, Smarts = 3 }, resultText = "Reflecting on your parenting journey. Did okay!" },
		},
	},
	
	{
		id = "m_tech_generational_gap",
		minAge = 45, maxAge = 55,
		weight = 30, cooldown = 3,
		emoji = "📱", title = "Technology Gap",
		category = "social",
		getDynamicData = function()
			local tech = {"TikTok", "cryptocurrency", "AI chatbots", "the metaverse", "NFTs", "smart home devices"}
			return { tech = tech[math.random(#tech)] }
		end,
		text = "Everyone's talking about %tech% and you feel completely lost.",
		choices = {
			{ text = "📚 Learn to keep up", effects = { Smarts = 8, Happiness = 4 }, resultText = "You figured it out! Not as young as them but not that old either!" },
			{ text = "🧑‍🦳 Embrace being 'old'", effects = { Happiness = 6 }, resultText = "You don't need to know everything. That's fine." },
			{ text = "👶 Ask the kids to teach you", effects = { Happiness = 5, Smarts = 5 }, resultText = "Role reversal! They love being the expert for once." },
			{ text = "😤 Technology is overrated", effects = { Happiness = 2 }, resultText = "Things were better before all this. Get off my lawn." },
		},
	},
}

return module
