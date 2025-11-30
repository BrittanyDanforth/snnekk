-- LifeEvents/young_adult_18_35.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- YOUNG ADULT EVENTS (Ages 18-35) - MASSIVE EXPANSION
-- 140+ deeply thought-out events for college, career, and early adulthood
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent.init)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- COLLEGE YEARS (Ages 18-22)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_college_start",
		minAge = 18, maxAge = 18,
		weight = 90, milestone = true, oneTime = true,
		emoji = "🎓", title = "Starting College!",
		category = "school",
		getDynamicData = function()
			local dorms = {"ancient dorm with no AC", "modern suite-style living", "party dorm", "quiet study dorm", "themed living community"}
			local majors = {"Undeclared", "Pre-Med", "Engineering", "Business", "Liberal Arts", "Computer Science", "Psychology", "Communications"}
			return { dorm = dorms[math.random(#dorms)], major = majors[math.random(#majors)] }
		end,
		text = "Welcome to college! You're living in a %dorm% and starting as a %major% major!",
		choices = {
			{ text = "📚 Academic focus!", effects = { Smarts = 10, Happiness = 4 }, resultText = "Dean's list incoming! You're here to learn.", setFlag = "college_student" },
			{ text = "🎉 College experience!", effects = { Happiness = 12, Smarts = 3 }, resultText = "Best four years of your life! Making memories!", setFlag = "college_student" },
			{ text = "🤝 Find your people", effects = { Happiness = 8, Smarts = 4 }, resultText = "Joined clubs, made friends. This is home now!", setFlag = "college_student" },
			{ text = "😰 Homesick already", effects = { Happiness = -4, Smarts = 2 }, resultText = "It's a big adjustment. You'll get through it.", setFlag = "college_student" },
		},
	},
	
	{
		id = "m_roommate_lottery",
		minAge = 18, maxAge = 19,
		weight = 50, oneTime = true,
		emoji = "🛏️", title = "Roommate Situation!",
		category = "social",
		getDynamicData = function()
			return { roommateName = LifeEvents.randomFirstName() }
		end,
		text = "You've been paired with %roommateName% as your roommate!",
		choices = {
			{ text = "🤝 Best friends!", effects = { Happiness = 12 }, resultText = "You and %roommateName% are inseparable! Roommate jackpot!", setFlag = "good_roommate" },
			{ text = "😐 Just tolerable", effects = { Happiness = 2 }, resultText = "You coexist. Not friends, not enemies." },
			{ text = "😤 Nightmare roommate", effects = { Happiness = -8 }, resultText = "They're disgusting, loud, and inconsiderate. Housing transfer ASAP." },
			{ text = "🤫 Slowly becoming besties", effects = { Happiness = 8 }, resultText = "Started awkward, became amazing!", setFlag = "good_roommate" },
		},
	},
	
	{
		id = "m_college_major",
		minAge = 19, maxAge = 20,
		weight = 60, oneTime = true,
		emoji = "📋", title = "Declaring Your Major!",
		category = "school",
		getDynamicData = function()
			local majors = {"Computer Science", "Business", "Pre-Med", "Engineering", "Psychology", "English", "Art", "Music", "Biology", "Political Science", "Economics", "Communications", "Nursing", "Education"}
			return { major = majors[math.random(#majors)] }
		end,
		text = "Time to officially declare! You're going with %major%!",
		choices = {
			{ text = "🎯 Perfect fit!", effects = { Smarts = 8, Happiness = 8 }, resultText = "This is your passion! Career path is set!", setFlag = "declared_major" },
			{ text = "💰 Follow the money", effects = { Smarts = 6, Happiness = 2 }, resultText = "Practical choice. Job security matters.", setFlag = "declared_major" },
			{ text = "🤔 Still unsure", effects = { Smarts = 3, Happiness = -2 }, resultText = "Declaring doesn't mean you can't change later!", setFlag = "declared_major" },
			{ text = "😤 Parents' choice", effects = { Smarts = 5, Happiness = -4 }, resultText = "Not what you wanted, but they're paying...", setFlag = "declared_major" },
		},
	},
	
	{
		id = "m_college_party",
		minAge = 18, maxAge = 22,
		weight = 40, cooldown = 2,
		emoji = "🎉", title = "College Party!",
		category = "social",
		getDynamicData = function()
			local types = {"frat party", "house party", "dorm party", "club event", "tailgate"}
			return { partyType = types[math.random(#types)] }
		end,
		text = "There's a huge %partyType% tonight! Everyone's going!",
		choices = {
			{ text = "🎉 Best night ever!", effects = { Happiness = 12, Health = -3 }, resultText = "LEGENDARY night! Stories for years to come!" },
			{ text = "🍻 Maybe too much fun", effects = { Happiness = 4, Health = -8 }, resultText = "You regret some choices... never again. (Until next weekend.)" },
			{ text = "📚 Stay in and study", effects = { Smarts = 6, Happiness = 2 }, resultText = "FOMO is real but exam is tomorrow!" },
			{ text = "🕺 Met someone special", effects = { Happiness = 15 }, resultText = "That party changed everything! New relationship!", setFlag = "college_romance" },
		},
	},
	
	{
		id = "m_spring_break",
		minAge = 18, maxAge = 22,
		weight = 35, cooldown = 2,
		emoji = "🏖️", title = "Spring Break!",
		category = "social",
		getDynamicData = function()
			local destinations = {"Cancun", "Miami", "Panama City Beach", "Vegas", "road trip", "home"}
			return { destination = destinations[math.random(#destinations)] }
		end,
		text = "Spring break! You're going to %destination% with friends!",
		choices = {
			{ text = "🏝️ Epic trip!", effects = { Happiness = 15, Money = -800, Health = -3 }, resultText = "Best spring break EVER! Worth every penny!" },
			{ text = "💰 Can't afford it", effects = { Happiness = -4, Money = 0 }, resultText = "You stayed behind while everyone else went. FOMO city." },
			{ text = "📚 Alternative break (volunteer)", effects = { Happiness = 8, Smarts = 3 }, resultText = "Helping others was fulfilling! Different kind of spring break.", setFlag = "volunteer" },
			{ text = "🏠 Went home", effects = { Happiness = 6, Money = 0 }, resultText = "Home-cooked meals and family time. Underrated." },
		},
	},
	
	{
		id = "m_college_grades",
		minAge = 18, maxAge = 22,
		weight = 45, cooldown = 2,
		emoji = "📋", title = "Semester Grades!",
		category = "school",
		text = "Grades are in! How did you do?",
		choices = {
			{ text = "🎓 Dean's List!", effects = { Smarts = 12, Happiness = 10 }, resultText = "4.0! Your hard work paid off!", setFlag = "deans_list" },
			{ text = "📊 Solid B average", effects = { Smarts = 6, Happiness = 4 }, resultText = "Good enough! Still on track." },
			{ text = "😅 Barely passed", effects = { Smarts = 2, Happiness = -3 }, resultText = "That was close. Time to step it up." },
			{ text = "📉 Academic probation", effects = { Smarts = -2, Happiness = -8 }, resultText = "Uh oh. Need to turn things around FAST." },
		},
	},
	
	{
		id = "m_study_abroad",
		minAge = 19, maxAge = 21,
		weight = 25, oneTime = true,
		emoji = "✈️", title = "Study Abroad!",
		category = "school",
		getDynamicData = function()
			local countries = {"Italy", "Spain", "England", "France", "Japan", "Australia", "Germany", "South Korea"}
			return { country = countries[math.random(#countries)] }
		end,
		text = "You've been accepted to study abroad in %country% for a semester!",
		choices = {
			{ text = "🌍 Life-changing!", effects = { Smarts = 10, Happiness = 15, Money = -3000 }, resultText = "Best decision ever! You're forever changed!", setFlag = "studied_abroad" },
			{ text = "🤷 Didn't go", effects = { Happiness = -4 }, resultText = "Decided against it. Wonder what it would have been like..." },
			{ text = "💕 International romance", effects = { Happiness = 12, Smarts = 5, Money = -2500 }, resultText = "Found love abroad! Long-distance is hard though...", setFlags = {"studied_abroad", "international_romance"} },
			{ text = "📚 Academic growth", effects = { Smarts = 15, Happiness = 8, Money = -2500 }, resultText = "Expanded your worldview! So much learning!", setFlags = {"studied_abroad", "worldly"} },
		},
	},
	
	{
		id = "m_college_internship",
		minAge = 20, maxAge = 22,
		weight = 40, cooldown = 2,
		emoji = "💼", title = "College Internship!",
		category = "career",
		getDynamicData = function()
			local companies = {"tech startup", "Fortune 500 company", "non-profit", "research lab", "media company", "finance firm", "hospital"}
			return { company = companies[math.random(#companies)] }
		end,
		text = "You landed a summer internship at a %company%!",
		choices = {
			{ text = "🌟 Return offer!", effects = { Smarts = 8, Money = 4000, Happiness = 10 }, resultText = "They want you back full-time after graduation!", setFlag = "has_job_offer" },
			{ text = "📚 Great experience", effects = { Smarts = 6, Money = 2500, Happiness = 5 }, resultText = "Resume looks amazing now! Valuable skills learned." },
			{ text = "😴 Coffee runs and filing", effects = { Smarts = 2, Money = 1500, Happiness = -2 }, resultText = "Grunt work. At least it pays?" },
			{ text = "🔗 Networking gold", effects = { Smarts = 4, Money = 2000, Happiness = 6 }, resultText = "Made invaluable connections!", setFlag = "well_connected" },
		},
	},
	
	{
		id = "m_graduation_college",
		minAge = 21, maxAge = 23,
		weight = 90, milestone = true, oneTime = true,
		emoji = "🎓", title = "COLLEGE GRADUATION!",
		category = "school",
		getDynamicData = function()
			local honors = {"summa cum laude", "magna cum laude", "cum laude", "", ""}
			return { honor = honors[math.random(#honors)] }
		end,
		text = "You did it! Bachelor's degree earned %honor%! Caps in the air!",
		choices = {
			{ text = "🎉 We made it!", effects = { Happiness = 15, Smarts = 5 }, resultText = "Four years of memories! On to the next chapter!", setFlag = "college_graduate" },
			{ text = "😭 Bittersweet", effects = { Happiness = 6, Smarts = 3 }, resultText = "Saying goodbye is hard. But ready for what's next.", setFlag = "college_graduate" },
			{ text = "🎯 Grad school next!", effects = { Smarts = 10, Happiness = 4 }, resultText = "Not done learning! Graduate program awaits!", setFlags = {"college_graduate", "pursuing_grad"} },
			{ text = "💰 Time to make money", effects = { Happiness = 8, Smarts = 2 }, resultText = "Real world, here I come!", setFlag = "college_graduate" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- EARLY CAREER (Ages 22-28)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_first_real_job",
		minAge = 22, maxAge = 25,
		weight = 70, oneTime = true,
		emoji = "💼", title = "First Real Job!",
		category = "career",
		getDynamicData = function()
			local fields = {"tech", "finance", "healthcare", "marketing", "education", "engineering", "consulting", "retail management", "government"}
			local salary = math.random(35000, 75000)
			return { field = fields[math.random(#fields)], salary = salary }
		end,
		text = "You got your first full-time job in %field%! Starting salary: $%salary%!",
		choices = {
			{ text = "🎉 Dream job!", effects = { Happiness = 12, Money = 5000, Smarts = 3 }, resultText = "You love what you do! That's the dream!", setFlags = {"employed", "career_starter"} },
			{ text = "🤷 It's a job", effects = { Happiness = 4, Money = 4000, Smarts = 2 }, resultText = "Not perfect, but pays the bills.", setFlags = {"employed", "career_starter"} },
			{ text = "😫 Entry-level grind", effects = { Happiness = 2, Money = 3500, Smarts = 4 }, resultText = "Everyone starts somewhere. Working your way up!", setFlags = {"employed", "career_starter"} },
			{ text = "💰 Negotiate salary up!", effects = { Happiness = 8, Money = 6000, Smarts = 5 }, resultText = "You asked for more and got it! Always negotiate!", setFlags = {"employed", "negotiator", "career_starter"} },
		},
	},
	
	{
		id = "m_quarter_life_crisis",
		minAge = 24, maxAge = 27,
		weight = 40, oneTime = true,
		emoji = "😰", title = "Quarter-Life Crisis",
		category = "social",
		text = "What am I doing with my life? Is this it? Everyone else seems to have it figured out!",
		choices = {
			{ text = "🔄 Major life change", effects = { Happiness = 8, Smarts = 4 }, resultText = "You quit your job, moved cities, changed everything!", setFlag = "quarter_life_reset" },
			{ text = "🧘 Self-reflection", effects = { Happiness = 4, Smarts = 6 }, resultText = "Therapy and introspection helped. It's okay to not have answers.", setFlag = "self_aware" },
			{ text = "💪 Push through", effects = { Happiness = 2, Smarts = 3 }, resultText = "Crisis? What crisis? Keep grinding." },
			{ text = "🗣️ Talk to friends", effects = { Happiness = 6 }, resultText = "Everyone's going through the same thing. You're not alone." },
		},
	},
	
	{
		id = "m_first_apartment",
		minAge = 22, maxAge = 26,
		weight = 50, oneTime = true,
		emoji = "🏠", title = "First Apartment!",
		category = "family",
		getDynamicData = function()
			local types = {"studio in the city", "1-bedroom with roommate", "cheap place in not-so-great area", "nice apartment (broke now)", "shared house"}
			local rent = math.random(800, 2200)
			return { apartmentType = types[math.random(#types)], rent = rent }
		end,
		text = "You're signing your first lease! A %apartmentType% for $%rent%/month!",
		choices = {
			{ text = "🏠 TRUE independence!", effects = { Happiness = 12, Money = -3000 }, resultText = "Your own space! Finally, adult life!", setFlag = "has_apartment" },
			{ text = "💸 Broke but happy", effects = { Happiness = 6, Money = -4000 }, resultText = "Worth every penny for your own place!", setFlag = "has_apartment" },
			{ text = "🛋️ Furnished with freebies", effects = { Happiness = 8, Money = -2000 }, resultText = "Facebook Marketplace and family hand-me-downs FTW!", setFlag = "has_apartment" },
			{ text = "😰 Adulting is expensive", effects = { Happiness = 2, Money = -3500 }, resultText = "Rent, utilities, groceries... how do adults do this?!", setFlag = "has_apartment" },
		},
	},
	
	{
		id = "m_workplace_romance",
		minAge = 22, maxAge = 35,
		weight = 20, oneTime = true,
		emoji = "💕", title = "Office Romance",
		category = "social",
		getDynamicData = function()
			return { coworkerName = LifeEvents.randomFirstName() }
		end,
		text = "You've developed feelings for your coworker %coworkerName%! Is this a good idea?",
		choices = {
			{ text = "💕 Go for it!", effects = { Happiness = 12 }, resultText = "You asked them out! They said yes! Worth the risk!", setFlag = "office_romance" },
			{ text = "🙅 Too risky", effects = { Happiness = -2, Smarts = 4 }, resultText = "Don't mix work and love. Smart choice." },
			{ text = "😬 It got awkward", effects = { Happiness = -6 }, resultText = "Things didn't work out and now work is weird." },
			{ text = "💒 Found the one!", effects = { Happiness = 15 }, resultText = "Workplace couple success story!", setFlags = {"office_romance", "serious_relationship"} },
		},
	},
	
	{
		id = "m_promotion_1",
		minAge = 24, maxAge = 30,
		weight = 35, cooldown = 3,
		emoji = "📈", title = "Promotion Opportunity!",
		category = "career",
		getDynamicData = function()
			local titles = {"Senior", "Team Lead", "Manager", "Specialist", "Associate Director"}
			local raise = math.random(5000, 15000)
			return { title = titles[math.random(#titles)], raise = raise }
		end,
		text = "There's an opening for %title%! $%raise% raise if you get it!",
		choices = {
			{ text = "🎉 GOT IT!", effects = { Happiness = 12, Money = 8000, Smarts = 4 }, resultText = "Promotion secured! Moving up!", setFlag = "promoted" },
			{ text = "😔 Passed over", effects = { Happiness = -8, Smarts = 2 }, resultText = "Someone else got it. That stings." },
			{ text = "💪 Made a strong case", effects = { Happiness = 6, Smarts = 5, Money = 5000 }, resultText = "You showed your value. Next time for sure!" },
			{ text = "🚀 Time to job hop", effects = { Happiness = 4, Money = 10000 }, resultText = "If they won't promote you, someone else will!", setFlag = "job_hopper" },
		},
	},
	
	{
		id = "m_side_hustle",
		minAge = 22, maxAge = 35,
		weight = 30, oneTime = true,
		emoji = "💰", title = "Starting a Side Hustle!",
		category = "career",
		getDynamicData = function()
			local hustles = {"freelancing", "online store", "content creation", "tutoring", "rideshare", "investing", "dropshipping", "consulting"}
			return { hustle = hustles[math.random(#hustles)] }
		end,
		text = "You're starting a %hustle% side hustle for extra income!",
		choices = {
			{ text = "💸 It's taking off!", effects = { Money = 5000, Happiness = 10 }, resultText = "Extra income flowing in! Grind paid off!", setFlag = "side_hustler" },
			{ text = "📈 Slow but steady", effects = { Money = 2000, Happiness = 4, Smarts = 3 }, resultText = "Building something. Rome wasn't built in a day.", setFlag = "side_hustler" },
			{ text = "😫 Burnout risk", effects = { Money = 1500, Health = -4, Happiness = -2 }, resultText = "Two jobs is exhausting. Be careful.", setFlag = "side_hustler" },
			{ text = "🚀 Could be a real business!", effects = { Money = 3000, Smarts = 5, Happiness = 8 }, resultText = "This could replace the day job someday!", setFlags = {"side_hustler", "entrepreneur_spark"} },
		},
	},
	
	{
		id = "m_serious_relationship",
		minAge = 23, maxAge = 30,
		weight = 35, oneTime = true,
		emoji = "💕", title = "Serious Relationship!",
		category = "social",
		getDynamicData = function()
			return { partnerName = LifeEvents.randomFirstName() }
		end,
		text = "You and %partnerName% are getting serious! This could be the one!",
		choices = {
			{ text = "💕 Move in together!", effects = { Happiness = 15, Money = 2000 }, resultText = "Taking the next step! Your place is now 'our' place!", setFlags = {"serious_relationship", "living_together"} },
			{ text = "💍 Talking about the future", effects = { Happiness = 10 }, resultText = "Marriage, kids, life plans... it's real.", setFlag = "serious_relationship" },
			{ text = "🐕 Got a pet together!", effects = { Happiness = 12 }, resultText = "Fur baby! Basically married now.", setFlags = {"serious_relationship", "has_pet"} },
			{ text = "🤔 Taking it slow", effects = { Happiness = 6, Smarts = 2 }, resultText = "No rush. Making sure it's right.", setFlag = "serious_relationship" },
		},
	},
	
	{
		id = "m_engagement",
		minAge = 25, maxAge = 35,
		weight = 30, oneTime = true,
		requiresFlag = "serious_relationship",
		emoji = "💍", title = "The Proposal!",
		category = "family",
		getDynamicData = function()
			local settings = {"at a fancy restaurant", "on a beach at sunset", "at home (simple and perfect)", "in front of family", "during a trip"}
			return { setting = settings[math.random(#settings)] }
		end,
		text = "It happened %setting%! Someone got down on one knee!",
		choices = {
			{ text = "💍 THEY SAID YES!", effects = { Happiness = 20, Money = -5000 }, resultText = "YOU'RE ENGAGED! Wedding planning begins!", setFlags = {"engaged", "wedding_planning"} },
			{ text = "💕 Perfect moment", effects = { Happiness = 18, Money = -4000 }, resultText = "Tears of joy! Everything is perfect!", setFlags = {"engaged", "wedding_planning"} },
			{ text = "😰 Said yes but nervous", effects = { Happiness = 10, Money = -4000 }, resultText = "Happy but scared. Big commitment!", setFlags = {"engaged", "wedding_planning"} },
			{ text = "💔 They said no...", effects = { Happiness = -20 }, resultText = "Devastating. The relationship might be over.", clearFlags = {"serious_relationship"} },
		},
	},
	
	{
		id = "m_wedding",
		minAge = 25, maxAge = 35,
		weight = 60, oneTime = true,
		requiresFlag = "engaged",
		emoji = "💒", title = "YOUR WEDDING DAY!",
		category = "family",
		getDynamicData = function()
			local types = {"big traditional wedding", "intimate ceremony", "destination wedding", "courthouse wedding", "backyard celebration"}
			return { weddingType = types[math.random(#types)] }
		end,
		text = "The day is here! You're having a %weddingType%!",
		choices = {
			{ text = "👰 Best day of my life!", effects = { Happiness = 25, Money = -20000 }, resultText = "PERFECT. Everything was perfect. You're married!", setFlag = "married", clearFlags = {"engaged", "wedding_planning"} },
			{ text = "💕 Simple but beautiful", effects = { Happiness = 18, Money = -5000 }, resultText = "It's not about the party, it's about the person!", setFlag = "married", clearFlags = {"engaged", "wedding_planning"} },
			{ text = "😬 Wedding drama!", effects = { Happiness = 10, Money = -15000 }, resultText = "Family drama, vendor issues... but still married!", setFlag = "married", clearFlags = {"engaged", "wedding_planning"} },
			{ text = "💰 Worth every penny", effects = { Happiness = 22, Money = -25000 }, resultText = "Splurged but no regrets! Dream wedding achieved!", setFlag = "married", clearFlags = {"engaged", "wedding_planning"} },
		},
	},
	
	{
		id = "m_buying_house",
		minAge = 26, maxAge = 35,
		weight = 30, oneTime = true,
		emoji = "🏡", title = "Buying a House!",
		category = "family",
		getDynamicData = function()
			local types = {"starter home", "condo", "fixer-upper", "nice suburban home", "urban townhouse"}
			local price = math.random(200000, 500000)
			return { homeType = types[math.random(#types)], price = price }
		end,
		text = "You're buying a %homeType%! Listed at $%price%!",
		choices = {
			{ text = "🏠 HOMEOWNER!", effects = { Happiness = 18, Money = -50000 }, resultText = "The American dream! Your name is on the deed!", setFlag = "homeowner" },
			{ text = "🔨 Fixer but potential", effects = { Happiness = 8, Money = -30000 }, resultText = "Sweat equity! Making it yours over time.", setFlag = "homeowner" },
			{ text = "💰 Stretched budget", effects = { Happiness = 10, Money = -60000 }, resultText = "House poor but happy. It'll appreciate!", setFlag = "homeowner" },
			{ text = "🏙️ Keep renting", effects = { Happiness = 2, Money = 0 }, resultText = "Not ready. Renting has its perks." },
		},
	},
	
	{
		id = "m_first_child",
		minAge = 25, maxAge = 35,
		weight = 30, oneTime = true,
		requiresFlag = "married",
		emoji = "👶", title = "Having a Baby!",
		category = "family",
		getDynamicData = function()
			local names = {"Emma", "Liam", "Olivia", "Noah", "Ava", "Ethan", "Sophia", "Mason", "Isabella", "Lucas"}
			return { babyName = names[math.random(#names)] }
		end,
		text = "You're having a baby! Welcome to the world, %babyName%!",
		choices = {
			{ text = "👶 Best moment ever!", effects = { Happiness = 25, Health = -5, Money = -5000 }, resultText = "Your life is forever changed! So much love!", setFlags = {"parent", "has_child"} },
			{ text = "😴 Sleep? What's that?", effects = { Happiness = 12, Health = -8 }, resultText = "Exhausted but in love. Worth every sleepless night.", setFlags = {"parent", "has_child"} },
			{ text = "💕 Growing family", effects = { Happiness = 20, Money = -4000 }, resultText = "Family of three! This is what life's about.", setFlags = {"parent", "has_child"} },
			{ text = "😰 Terrified but ready", effects = { Happiness = 10, Smarts = 3 }, resultText = "No one's truly ready. But you'll figure it out!", setFlags = {"parent", "has_child"} },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- ESTABLISHING YOURSELF (Ages 28-35)
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "m_career_crossroads",
		minAge = 28, maxAge = 33,
		weight = 35, oneTime = true,
		emoji = "🔀", title = "Career Crossroads",
		category = "career",
		text = "Stay on current path, or make a big change? Pivot, or climb?",
		choices = {
			{ text = "🔄 Complete career change", effects = { Happiness = 8, Money = -5000, Smarts = 5 }, resultText = "Started over in a new field! Scary but exciting!", setFlag = "career_pivot" },
			{ text = "🚀 Go all in", effects = { Money = 8000, Happiness = 6, Smarts = 4 }, resultText = "Doubled down on your career. Leadership track!", setFlag = "career_focused" },
			{ text = "🎓 Back to school", effects = { Smarts = 12, Money = -20000, Happiness = 4 }, resultText = "Grad degree to level up!", setFlag = "pursuing_grad" },
			{ text = "💼 Start a business", effects = { Money = -10000, Happiness = 8, Smarts = 6 }, resultText = "Entrepreneur life! Your own boss!", setFlag = "entrepreneur" },
		},
	},
	
	{
		id = "m_grad_school",
		minAge = 24, maxAge = 32,
		weight = 25, oneTime = true,
		emoji = "🎓", title = "Graduate School!",
		category = "school",
		getDynamicData = function()
			local degrees = {"MBA", "Law Degree (JD)", "Medical Degree (MD)", "Master's", "PhD"}
			return { degree = degrees[math.random(#degrees)] }
		end,
		text = "You're pursuing a %degree%! More school, more loans, more opportunity!",
		choices = {
			{ text = "🎯 Top of class!", effects = { Smarts = 15, Happiness = 8, Money = -30000 }, resultText = "Honors! This will open doors!", setFlag = "advanced_degree" },
			{ text = "📚 Grinding through", effects = { Smarts = 10, Happiness = 2, Money = -25000 }, resultText = "It's hard work but you're doing it!", setFlag = "advanced_degree" },
			{ text = "🤝 Made great connections", effects = { Smarts = 8, Happiness = 6, Money = -25000 }, resultText = "The network is worth the tuition!", setFlags = {"advanced_degree", "well_connected"} },
			{ text = "💰 Employer paid!", effects = { Smarts = 10, Happiness = 8, Money = -5000 }, resultText = "Work subsidized your education! Smart move!", setFlag = "advanced_degree" },
		},
	},
	
	{
		id = "m_career_success",
		minAge = 30, maxAge = 35,
		weight = 30, oneTime = true,
		emoji = "🏆", title = "Major Career Win!",
		category = "career",
		getDynamicData = function()
			local wins = {"big promotion", "industry award", "major project completion", "executive position", "salary milestone"}
			return { win = wins[math.random(#wins)] }
		end,
		text = "You achieved a huge %win%! All that hard work paid off!",
		choices = {
			{ text = "🎉 Celebrate big!", effects = { Happiness = 15, Money = 15000 }, resultText = "You earned this! Drinks on you!", setFlag = "career_achiever" },
			{ text = "💪 Stay humble", effects = { Happiness = 8, Money = 12000, Smarts = 3 }, resultText = "Success is a journey, not a destination.", setFlag = "career_achiever" },
			{ text = "🎯 What's next?", effects = { Happiness = 10, Money = 12000, Smarts = 4 }, resultText = "Already planning the next level!", setFlags = {"career_achiever", "ambitious"} },
			{ text = "🙏 Thank those who helped", effects = { Happiness = 12, Money = 11000 }, resultText = "You didn't do it alone. Gratitude matters.", setFlags = {"career_achiever", "grateful"} },
		},
	},
	
	{
		id = "m_investment_windfall",
		minAge = 25, maxAge = 35,
		weight = 15, oneTime = true,
		emoji = "📈", title = "Investment Pays Off!",
		category = "career",
		getDynamicData = function()
			local types = {"stocks", "crypto", "startup equity", "real estate", "side business"}
			local amount = math.random(10000, 100000)
			return { investmentType = types[math.random(#types)], amount = amount }
		end,
		text = "Your %investmentType% investment paid off BIG! $%amount% profit!",
		choices = {
			{ text = "💰 Cash out!", effects = { Money = 50000, Happiness = 15 }, resultText = "Liquid baby! That's a nice payday!" },
			{ text = "📈 Let it ride", effects = { Smarts = 5, Happiness = 6 }, resultText = "Compound growth! Playing the long game.", setFlag = "investor" },
			{ text = "🏠 Buy something big", effects = { Happiness = 12, Money = -20000 }, resultText = "Treat yourself! New car? New house down payment?" },
			{ text = "🎓 Invest in yourself", effects = { Smarts = 10, Money = 10000 }, resultText = "Used winnings for education/growth!", setFlags = {"investor", "lifelong_learner"} },
		},
	},
	
	{
		id = "m_health_wake_up_call",
		minAge = 28, maxAge = 35,
		weight = 20, oneTime = true,
		emoji = "🏥", title = "Health Wake-Up Call",
		category = "health",
		getDynamicData = function()
			local issues = {"high blood pressure", "weight concerns", "stress-related issues", "concerning test results", "burnout symptoms"}
			return { issue = issues[math.random(#issues)] }
		end,
		text = "Doctor flagged %issue%. Time to take health seriously.",
		choices = {
			{ text = "🏋️ Major lifestyle change", effects = { Health = 15, Happiness = 6, Looks = 4 }, resultText = "Gym, diet, sleep - complete overhaul! Feeling amazing!", setFlag = "health_focused" },
			{ text = "🥗 Start eating better", effects = { Health = 8, Happiness = 3 }, resultText = "Cooking more, fast food less. Progress!", setFlag = "healthy_eater" },
			{ text = "😰 Scared straight", effects = { Health = 10, Happiness = -2, Smarts = 3 }, resultText = "Fear is a motivator. You're making changes." },
			{ text = "🤷 Ignore it", effects = { Health = -5, Happiness = 2 }, resultText = "Bad idea. Future you will regret this." },
		},
	},
	
	{
		id = "m_friend_milestone",
		minAge = 27, maxAge = 35,
		weight = 30, cooldown = 3,
		emoji = "🎉", title = "Friend's Big Milestone!",
		category = "social",
		getDynamicData = function()
			local milestones = {"getting married", "having a baby", "buying a house", "getting promoted", "starting a business"}
			return { milestone = milestones[math.random(#milestones)], friendName = LifeEvents.randomFirstName() }
		end,
		text = "%friendName% is %milestone%! How do you feel?",
		choices = {
			{ text = "🎉 So happy for them!", effects = { Happiness = 8 }, resultText = "Genuine joy! Their success doesn't diminish yours." },
			{ text = "🤔 Comparing my life...", effects = { Happiness = -4 }, resultText = "Comparison is the thief of joy. You're on your own path." },
			{ text = "🙏 Inspired!", effects = { Happiness = 5, Smarts = 2 }, resultText = "If they can do it, so can you!", setFlag = "inspired" },
			{ text = "😅 When's my turn?", effects = { Happiness = -2 }, resultText = "Adult milestones hit different when you're watching others achieve them." },
		},
	},
	
	{
		id = "m_travel_dream",
		minAge = 22, maxAge = 35,
		weight = 25, cooldown = 3,
		emoji = "✈️", title = "Dream Vacation!",
		category = "social",
		getDynamicData = function()
			local destinations = {"Europe", "Japan", "Thailand", "Australia", "South America", "Africa", "tropical islands", "around the world"}
			return { destination = destinations[math.random(#destinations)] }
		end,
		text = "Finally taking that dream trip to %destination%!",
		choices = {
			{ text = "✈️ Life-changing trip!", effects = { Happiness = 20, Money = -5000, Smarts = 4 }, resultText = "Best trip ever! Perspective changed forever!", setFlag = "world_traveler" },
			{ text = "📸 So many memories", effects = { Happiness = 15, Money = -4000 }, resultText = "Photos, experiences, stories! Worth every penny!", setFlag = "world_traveler" },
			{ text = "🎒 Budget backpacking", effects = { Happiness = 12, Money = -2000, Smarts = 5 }, resultText = "Roughing it but seeing the real culture!", setFlags = {"world_traveler", "adventurous"} },
			{ text = "🏝️ Pure relaxation", effects = { Happiness = 15, Health = 5, Money = -4500 }, resultText = "Needed this reset. Recharged and ready.", setFlag = "world_traveler" },
		},
	},
	
	{
		id = "m_pet_adoption",
		minAge = 22, maxAge = 35,
		weight = 25, oneTime = true,
		emoji = "🐕", title = "Adopting a Pet!",
		category = "family",
		getDynamicData = function()
			local petData = {
				{ type = "rescue dog", emoji = "🐕" },
				{ type = "cat", emoji = "🐱" },
				{ type = "puppy", emoji = "🐶" },
				{ type = "kitten", emoji = "🐱" },
				{ type = "rabbit", emoji = "🐰" },
				{ type = "bird", emoji = "🐦" },
			}
			local chosen = petData[math.random(#petData)]
			local names = {"Max", "Luna", "Charlie", "Bella", "Cooper", "Lucy", "Milo", "Daisy"}
			return { petType = chosen.type, petName = names[math.random(#names)], petEmoji = chosen.emoji }
		end,
		getDynamicEmoji = function(data)
			return data.petEmoji or "🐕"
		end,
		text = "You adopted a %petType% named %petName%!",
		choices = {
			{ text = "🥰 Best decision ever!", effects = { Happiness = 15 }, resultText = "%petName% is the love of your life! Unconditional love!", setFlags = {"has_pet", "pet_parent"} },
			{ text = "😅 Didn't expect this much work", effects = { Happiness = 6, Money = -1000 }, resultText = "Pets are expensive and demanding. But worth it!", setFlags = {"has_pet", "pet_parent"} },
			{ text = "📸 Instagram star", effects = { Happiness = 10, Looks = 2 }, resultText = "%petName% has more followers than you!", setFlags = {"has_pet", "pet_parent"} },
			{ text = "🏃 Exercise buddy!", effects = { Happiness = 10, Health = 6 }, resultText = "Daily walks! You're both getting fit!", setFlags = {"has_pet", "pet_parent", "active"} },
		},
	},
	
	{
		id = "m_volunteer_passion",
		minAge = 24, maxAge = 35,
		weight = 20, cooldown = 3,
		emoji = "❤️", title = "Finding Purpose Through Giving",
		category = "social",
		getDynamicData = function()
			local causes = {"homeless shelter", "food bank", "youth mentor program", "environmental group", "animal rescue", "disaster relief"}
			return { cause = causes[math.random(#causes)] }
		end,
		text = "You started volunteering with a %cause%. It feels meaningful.",
		choices = {
			{ text = "❤️ Found my calling!", effects = { Happiness = 12, Smarts = 3 }, resultText = "This is what matters! Making a difference!", setFlags = {"volunteer", "purposeful"} },
			{ text = "📅 Regular commitment", effects = { Happiness = 6 }, resultText = "Every week you show up. Consistency counts.", setFlag = "volunteer" },
			{ text = "🌟 Leadership role", effects = { Happiness = 8, Smarts = 4 }, resultText = "You're now organizing others to help!", setFlags = {"volunteer", "leader"} },
			{ text = "🤝 New community", effects = { Happiness = 10 }, resultText = "Met amazing people who share your values!", setFlags = {"volunteer", "connected"} },
		},
	},
	
	{
		id = "m_turning_30",
		minAge = 30, maxAge = 30,
		weight = 90, milestone = true, oneTime = true,
		emoji = "3️⃣0️⃣", title = "Turning 30!",
		category = "family",
		text = "The big 3-0! You're officially in your thirties. How are you feeling?",
		choices = {
			{ text = "🎉 Best decade yet!", effects = { Happiness = 12 }, resultText = "You're wiser, more confident. 30s are going to be great!" },
			{ text = "😰 Where did time go?!", effects = { Happiness = -4 }, resultText = "Existential crisis incoming. What have you accomplished?!" },
			{ text = "💪 Prime of my life", effects = { Happiness = 8, Health = 3, Looks = 2 }, resultText = "30 is the new 20! Just getting started!" },
			{ text = "🍷 Aged like fine wine", effects = { Happiness = 10, Looks = 4 }, resultText = "Getting better with age! Self-love unlocked." },
		},
	},
	
	{
		id = "m_networking_event",
		minAge = 23, maxAge = 35,
		weight = 25, cooldown = 3,
		emoji = "🤝", title = "Networking Event",
		category = "career",
		getDynamicData = function()
			local events = {"industry conference", "alumni mixer", "professional meetup", "business dinner", "charity gala"}
			return { event = events[math.random(#events)] }
		end,
		text = "You're at a %event%! Time to work the room!",
		choices = {
			{ text = "🌟 Made key connection!", effects = { Happiness = 8, Smarts = 4 }, resultText = "Met someone who could change your career!", setFlag = "networker" },
			{ text = "🤝 Lots of good chats", effects = { Happiness = 5, Smarts = 2 }, resultText = "Quality networking! Follow-ups scheduled." },
			{ text = "😅 Awkward small talk", effects = { Happiness = -2 }, resultText = "Networking is hard. You survived." },
			{ text = "💼 Got a job lead!", effects = { Happiness = 10, Money = 2000 }, resultText = "This event paid for itself! Opportunity knocks!", setFlags = {"networker", "opportunity"} },
		},
	},
	
	{
		id = "m_burnout",
		minAge = 25, maxAge = 35,
		weight = 25, oneTime = true,
		emoji = "🔥", title = "Burnout",
		category = "health",
		text = "You hit the wall. Complete burnout. Can't keep going like this.",
		choices = {
			{ text = "🏝️ Take a real break", effects = { Health = 8, Happiness = 6, Money = -2000 }, resultText = "Took time off. Came back refreshed and with new perspective.", setFlag = "recovered_burnout" },
			{ text = "🔄 Change jobs", effects = { Happiness = 4, Smarts = 2 }, resultText = "Sometimes you need a fresh start.", setFlag = "recovered_burnout" },
			{ text = "💆 Self-care priority", effects = { Health = 6, Happiness = 4 }, resultText = "Boundaries, sleep, therapy. Healing takes time.", setFlags = {"recovered_burnout", "self_care"} },
			{ text = "💪 Push through", effects = { Health = -8, Happiness = -5 }, resultText = "Bad choice. You crashed even harder later." },
		},
	},
	
	{
		id = "m_unexpected_money",
		minAge = 22, maxAge = 35,
		weight = 15, cooldown = 3,
		emoji = "💰", title = "Unexpected Money!",
		category = "career",
		getDynamicData = function()
			local sources = {"inheritance", "tax refund", "bonus", "winning scratch-off", "old savings you forgot about", "returned security deposit"}
			local amount = math.random(1000, 20000)
			return { source = sources[math.random(#sources)], amount = amount }
		end,
		text = "You received $%amount% from %source%! What do you do?",
		choices = {
			{ text = "💰 Save it all", effects = { Money = 15000, Happiness = 4, Smarts = 3 }, resultText = "Future you will thank present you!", setFlag = "saver" },
			{ text = "💸 Spend it!", effects = { Money = 5000, Happiness = 10 }, resultText = "YOLO! Enjoyed every penny!" },
			{ text = "📈 Invest it", effects = { Money = 8000, Smarts = 5 }, resultText = "Making money work for you!", setFlag = "investor" },
			{ text = "💳 Pay off debt", effects = { Money = -2000, Happiness = 6, Smarts = 4 }, resultText = "Responsible choice! One step closer to financial freedom!", setFlag = "financially_responsible" },
		},
	},
	
	{
		id = "m_imposter_syndrome",
		minAge = 24, maxAge = 35,
		weight = 30, oneTime = true,
		emoji = "😰", title = "Imposter Syndrome",
		category = "career",
		text = "You feel like a fraud. Like any day, everyone will realize you don't belong.",
		choices = {
			{ text = "🗣️ Open up about it", effects = { Happiness = 5, Smarts = 4 }, resultText = "Turns out EVERYONE feels this way! You're not alone.", setFlag = "self_aware" },
			{ text = "📊 Look at accomplishments", effects = { Happiness = 6, Smarts = 3 }, resultText = "The evidence says you earned your spot!" },
			{ text = "💪 Fake it til you make it", effects = { Happiness = 2, Smarts = 2 }, resultText = "Act confident even when you're not. It works." },
			{ text = "😔 Really struggling", effects = { Happiness = -6 }, resultText = "The feeling persists. Consider talking to someone professional." },
		},
	},
	
	{
		id = "m_second_child",
		minAge = 28, maxAge = 35,
		weight = 20, oneTime = true,
		requiresFlag = "has_child",
		emoji = "👶", title = "Baby Number Two!",
		category = "family",
		getDynamicData = function()
			local names = {"Charlotte", "Oliver", "Amelia", "Elijah", "Mia", "James", "Harper", "Benjamin"}
			return { babyName = names[math.random(#names)] }
		end,
		text = "Another baby! Welcome %babyName%! You're a family of four!",
		choices = {
			{ text = "👶 Double the love!", effects = { Happiness = 20, Health = -5, Money = -6000 }, resultText = "Your heart grew even bigger!", setFlag = "multiple_children" },
			{ text = "😱 Twice the chaos", effects = { Happiness = 8, Health = -8, Money = -5000 }, resultText = "You're outnumbered now! Survival mode!", setFlag = "multiple_children" },
			{ text = "🤝 Sibling bond!", effects = { Happiness = 15, Money = -5500 }, resultText = "Your first child has a built-in best friend!", setFlag = "multiple_children" },
			{ text = "💤 Sleep is a memory", effects = { Happiness = 10, Health = -10, Money = -6000 }, resultText = "What year is it? Doesn't matter. Baby needs you.", setFlag = "multiple_children" },
		},
	},
}

return module
