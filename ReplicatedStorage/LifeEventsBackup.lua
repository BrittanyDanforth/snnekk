-- LifeEventsBackup.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- BACKUP: All life events in a single file
-- This is used if the modular LifeEvents folder system fails to load
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEventsBackup = {}

-- Helper to pick random from list
local function pick(list)
	return list[math.random(#list)]
end

-- Name generators
local MaleNames = {"James","Michael","David","Chris","Daniel","Matt","Jake","Ryan","Tyler","Brandon","Ethan","Mason","Logan","Lucas","Liam","Noah","Oliver","William"}
local FemaleNames = {"Emma","Sophia","Olivia","Ava","Isabella","Mia","Emily","Abigail","Madison","Elizabeth","Ella","Charlotte","Amelia","Harper","Evelyn"}
local LastNames = {"Smith","Johnson","Williams","Brown","Jones","Garcia","Miller","Davis","Rodriguez","Martinez","Anderson","Taylor","Thomas","Moore","Jackson"}

function LifeEventsBackup.randomFirstName()
	return math.random(2) == 1 and pick(MaleNames) or pick(FemaleNames)
end

function LifeEventsBackup.randomName()
	return LifeEventsBackup.randomFirstName() .. " " .. pick(LastNames)
end

-- All events combined
LifeEventsBackup.events = {
	-- ═══════════════════════════════════════════════════════════════
	-- CHILDHOOD (Ages 0-12) - Sample events
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "backup_birth",
		minAge = 0, maxAge = 0,
		weight = 100, milestone = true, oneTime = true,
		emoji = "👶", title = "You Are Born!",
		category = "family",
		text = "You came into this world, a tiny bundle of possibility. Your life begins now.",
		choices = {
			{ text = "😭 Cry loudly", effects = { Health = 2, Happiness = 1 }, resultText = "Your strong lungs impressed the doctors." },
			{ text = "😴 Sleep peacefully", effects = { Health = 3, Happiness = 3 }, resultText = "You were a calm, peaceful baby." },
			{ text = "👀 Look around curiously", effects = { Smarts = 4 }, resultText = "Already trying to figure out this strange new world." },
		},
	},
	
	{
		id = "backup_first_smile",
		minAge = 0, maxAge = 1,
		weight = 60, oneTime = true,
		emoji = "😊", title = "First Smile!",
		category = "family",
		text = "You smiled for the first time! Your parents' hearts melted.",
		choices = {
			{ text = "😄 Smile more!", effects = { Happiness = 6, Looks = 2 }, resultText = "Your smile became your superpower." },
			{ text = "🤗 Reach for a hug", effects = { Happiness = 7 }, resultText = "Your parents cried happy tears!" },
		},
	},
	
	{
		id = "backup_first_word",
		minAge = 1, maxAge = 2,
		weight = 80, oneTime = true,
		emoji = "🗣️", title = "First Word!",
		category = "family",
		text = "You're about to speak your first word...",
		choices = {
			{ text = "👩 Say 'Mama'", effects = { Happiness = 6 }, resultText = "Your mother burst into tears of joy." },
			{ text = "👨 Say 'Dada'", effects = { Happiness = 6 }, resultText = "Your father puffed up with pride." },
			{ text = "🙅 Say 'NO!'", effects = { Happiness = 4, Smarts = 4 }, resultText = "Your rebellious streak started early!" },
		},
	},
	
	{
		id = "backup_first_steps",
		minAge = 1, maxAge = 2,
		weight = 75, oneTime = true, milestone = true,
		emoji = "🚶", title = "First Steps!",
		category = "family",
		text = "You took your very first steps! The whole family cheered!",
		choices = {
			{ text = "🏃 Try to run!", effects = { Health = 5, Happiness = 4 }, resultText = "You fell down but immediately got back up!" },
			{ text = "👐 Walk to parent", effects = { Happiness = 8 }, resultText = "You walked right into their waiting arms." },
		},
	},
	
	{
		id = "backup_kindergarten",
		minAge = 5, maxAge = 6,
		weight = 100, milestone = true, oneTime = true,
		emoji = "🏫", title = "First Day of School!",
		category = "school",
		text = "It's your first day of kindergarten! Big step toward independence!",
		choices = {
			{ text = "🎉 Excited!", effects = { Happiness = 6, Smarts = 3 }, resultText = "You bounced into class with enthusiasm!" },
			{ text = "😰 Scared", effects = { Happiness = -3 }, resultText = "You clung to your parent but eventually warmed up." },
			{ text = "🤝 Make a friend", effects = { Happiness = 7 }, resultText = "You found a best friend on day one!" },
		},
	},
	
	{
		id = "backup_playground_fall",
		minAge = 4, maxAge = 10,
		weight = 25, cooldown = 2,
		emoji = "🤕", title = "Playground Accident",
		category = "health",
		text = "Oops! You got hurt on the playground!",
		choices = {
			{ text = "😭 Cry!", effects = { Health = -3, Happiness = -4 }, resultText = "It hurt! But you got lots of sympathy." },
			{ text = "💪 Be brave", effects = { Health = -2, Happiness = 3 }, resultText = "You barely shed a tear! So tough!" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- TEEN YEARS (Ages 13-17) - Sample events
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "backup_high_school",
		minAge = 14, maxAge = 14,
		weight = 100, milestone = true, oneTime = true,
		emoji = "🎓", title = "Starting High School!",
		category = "school",
		text = "Welcome to high school! The next four years will shape your future!",
		choices = {
			{ text = "😎 Fresh start!", effects = { Happiness = 8, Smarts = 3 }, resultText = "New school, new you! Feeling optimistic." },
			{ text = "😰 Freshman fears", effects = { Happiness = -4 }, resultText = "Seniors are HUGE. The building is HUGE. Help." },
			{ text = "🎯 Set big goals", effects = { Smarts = 8, Happiness = 5 }, resultText = "College prep starts NOW!" },
		},
	},
	
	{
		id = "backup_first_crush",
		minAge = 12, maxAge = 16,
		weight = 35, oneTime = true,
		emoji = "💕", title = "First Crush!",
		category = "social",
		text = "You've developed a crush! Your face gets red whenever they're around.",
		choices = {
			{ text = "😊 Try to be friends", effects = { Happiness = 6 }, resultText = "You became friends with your crush!" },
			{ text = "🤫 Keep it secret", effects = { Happiness = 4 }, resultText = "You admired from afar." },
			{ text = "💌 Pass a note", effects = { Happiness = 8, Smarts = -1 }, resultText = "They like you too!!" },
		},
	},
	
	{
		id = "backup_drivers_license",
		minAge = 16, maxAge = 17,
		weight = 70, oneTime = true,
		emoji = "🪪", title = "Driver's License!",
		category = "family",
		text = "The big day! Your driving test is TODAY!",
		choices = {
			{ text = "🎉 PASSED!", effects = { Happiness = 15, Smarts = 2 }, resultText = "FREEDOM! You can drive alone now!", setFlag = "can_drive" },
			{ text = "😭 Failed...", effects = { Happiness = -8 }, resultText = "Parallel parking got you. Try again soon." },
			{ text = "✨ Perfect score!", effects = { Happiness = 12, Smarts = 5 }, resultText = "Not a single point off!", setFlags = {"can_drive", "perfect_driver"} },
		},
	},
	
	{
		id = "backup_graduation_hs",
		minAge = 17, maxAge = 18,
		weight = 100, milestone = true, oneTime = true,
		emoji = "🎓", title = "HIGH SCHOOL GRADUATION!",
		category = "school",
		text = "You did it! You're graduating high school! Caps in the air!",
		choices = {
			{ text = "🎓 Valedictorian speech!", effects = { Smarts = 10, Happiness = 15, Looks = 5 }, resultText = "Top of your class! You gave the big speech!" },
			{ text = "🎉 Celebrate with friends!", effects = { Happiness = 12 }, resultText = "Best night ever! Graduation parties everywhere!" },
			{ text = "😢 Bittersweet", effects = { Happiness = 5, Smarts = 2 }, resultText = "Happy and sad. End of an era." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- YOUNG ADULT (Ages 18-35) - Sample events  
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "backup_college_start",
		minAge = 18, maxAge = 19,
		weight = 80, milestone = true, oneTime = true,
		emoji = "🎓", title = "Starting College!",
		category = "school",
		text = "Welcome to college! Time for higher education and new experiences!",
		choices = {
			{ text = "📚 Academic focus!", effects = { Smarts = 10, Happiness = 4 }, resultText = "Dean's list incoming!" },
			{ text = "🎉 College experience!", effects = { Happiness = 12, Smarts = 3 }, resultText = "Best four years of your life!" },
			{ text = "🤝 Find your people", effects = { Happiness = 8, Smarts = 4 }, resultText = "Joined clubs, made friends!" },
		},
	},
	
	{
		id = "backup_first_job",
		minAge = 22, maxAge = 26,
		weight = 70, oneTime = true,
		emoji = "💼", title = "First Real Job!",
		category = "career",
		text = "You got your first full-time job! Welcome to the workforce!",
		choices = {
			{ text = "🎉 Dream job!", effects = { Happiness = 12, Money = 5000, Smarts = 3 }, resultText = "You love what you do!" },
			{ text = "🤷 It's a job", effects = { Happiness = 4, Money = 4000, Smarts = 2 }, resultText = "Not perfect, but pays the bills." },
			{ text = "💰 Negotiate salary up!", effects = { Happiness = 8, Money = 6000, Smarts = 5 }, resultText = "You asked for more and got it!" },
		},
	},
	
	{
		id = "backup_engagement",
		minAge = 24, maxAge = 35,
		weight = 25, oneTime = true,
		emoji = "💍", title = "The Proposal!",
		category = "family",
		text = "Someone got down on one knee!",
		choices = {
			{ text = "💍 THEY SAID YES!", effects = { Happiness = 20, Money = -5000 }, resultText = "YOU'RE ENGAGED!", setFlag = "engaged" },
			{ text = "💕 Perfect moment", effects = { Happiness = 18, Money = -4000 }, resultText = "Tears of joy!", setFlag = "engaged" },
			{ text = "💔 They said no...", effects = { Happiness = -20 }, resultText = "Devastating. The relationship might be over." },
		},
	},
	
	{
		id = "backup_wedding",
		minAge = 25, maxAge = 40,
		weight = 50, oneTime = true,
		requiresFlag = "engaged",
		emoji = "💒", title = "YOUR WEDDING DAY!",
		category = "family",
		text = "The day is here! You're getting married!",
		choices = {
			{ text = "👰 Best day of my life!", effects = { Happiness = 25, Money = -20000 }, resultText = "PERFECT. You're married!", setFlag = "married", clearFlags = {"engaged"} },
			{ text = "💕 Simple but beautiful", effects = { Happiness = 18, Money = -5000 }, resultText = "It's not about the party!", setFlag = "married", clearFlags = {"engaged"} },
		},
	},
	
	{
		id = "backup_first_child",
		minAge = 25, maxAge = 40,
		weight = 30, oneTime = true,
		requiresFlag = "married",
		emoji = "👶", title = "Having a Baby!",
		category = "family",
		text = "You're having a baby! Welcome to parenthood!",
		choices = {
			{ text = "👶 Best moment ever!", effects = { Happiness = 25, Health = -5, Money = -5000 }, resultText = "Your life is forever changed!", setFlags = {"parent", "has_child"} },
			{ text = "😴 Sleep? What's that?", effects = { Happiness = 12, Health = -8 }, resultText = "Exhausted but in love.", setFlags = {"parent", "has_child"} },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- MIDDLE AGE (Ages 36-55) - Sample events
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "backup_midlife",
		minAge = 40, maxAge = 45,
		weight = 50, oneTime = true, milestone = true,
		emoji = "🤔", title = "Midlife Crossroads",
		category = "family",
		text = "You're halfway through life. Is this where you thought you'd be?",
		choices = {
			{ text = "😊 Content and grateful", effects = { Happiness = 12, Smarts = 3 }, resultText = "Life isn't perfect, but it's good." },
			{ text = "🔄 Need a change", effects = { Happiness = 4, Smarts = 5 }, resultText = "Time for reinvention!" },
			{ text = "😰 Midlife crisis!", effects = { Happiness = -8, Money = -10000 }, resultText = "Bought a sports car. What is happening?!" },
		},
	},
	
	{
		id = "backup_grandparent",
		minAge = 50, maxAge = 65,
		weight = 25, oneTime = true,
		requiresFlag = "has_child",
		emoji = "👶", title = "You're a Grandparent!",
		category = "family",
		text = "Your child had a baby! You're a grandparent!",
		choices = {
			{ text = "🥰 Best feeling ever!", effects = { Happiness = 20 }, resultText = "All the love of parenting with none of the sleepless nights!", setFlag = "grandparent" },
			{ text = "👴 Feel old now", effects = { Happiness = 8 }, resultText = "Grandparent?! When did THAT happen?!", setFlag = "grandparent" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- SENIOR YEARS (Ages 55+) - Sample events
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "backup_retirement",
		minAge = 60, maxAge = 70,
		weight = 80, milestone = true, oneTime = true,
		emoji = "🎉", title = "RETIREMENT DAY!",
		category = "career",
		text = "After decades in the workforce, today is your last day! YOU'RE RETIRED!",
		choices = {
			{ text = "🎉 FREEDOM AT LAST!", effects = { Happiness = 25 }, resultText = "The alarm clock is officially your enemy no more!", setFlag = "retired" },
			{ text = "😢 Bittersweet", effects = { Happiness = 10, Smarts = 3 }, resultText = "End of an era. Mixed emotions but mostly joy.", setFlag = "retired" },
		},
	},
	
	{
		id = "backup_turning_80",
		minAge = 80, maxAge = 80,
		weight = 100, milestone = true, oneTime = true,
		emoji = "8️⃣0️⃣", title = "EIGHTY YEARS!",
		category = "family",
		text = "80! An octogenarian! You've outlived so many. What a journey!",
		choices = {
			{ text = "🎉 Party time!", effects = { Happiness = 18 }, resultText = "Four generations celebrating you!" },
			{ text = "💭 Reflecting on life", effects = { Happiness = 12, Smarts = 5 }, resultText = "What a full life. No regrets." },
		},
	},
	
	{
		id = "backup_centenarian",
		minAge = 100, maxAge = 100,
		weight = 100, milestone = true, oneTime = true,
		emoji = "💯", title = "ONE HUNDRED YEARS!!!",
		category = "family",
		text = "100 YEARS OLD! A CENTENARIAN! Truly extraordinary!",
		choices = {
			{ text = "🎉 LEGENDARY!", effects = { Happiness = 50, Health = 10 }, resultText = "100 years of life! INCREDIBLE!", setFlag = "centenarian" },
			{ text = "📺 National news!", effects = { Happiness = 40, Looks = 5 }, resultText = "You're on TV! The whole country celebrates you!", setFlag = "centenarian" },
		},
	},
}

function LifeEventsBackup.getEvents()
	return LifeEventsBackup.events
end

print("[LifeEventsBackup] ✅ Backup events loaded:", #LifeEventsBackup.events, "events")

return LifeEventsBackup
