-- EventLibrary.lua
-- Comprehensive life events with deep story paths for President & Criminal careers

local EventLibrary = {}

-- Random name generators
local MaleNames = {"James","Michael","Robert","David","William","Richard","Joseph","Thomas","Christopher","Daniel","Matthew","Anthony","Mark","Donald","Steven","Paul","Andrew","Joshua","Kenneth","Kevin","Brian","George","Timothy","Ronald","Edward","Jason","Jeffrey","Ryan","Jacob","Gary","Nicholas","Eric","Jonathan","Stephen","Larry","Justin","Scott","Brandon","Benjamin","Samuel","Raymond","Gregory","Frank","Alexander","Patrick","Jack","Dennis","Jerry","Tyler","Aaron","Jose","Adam","Nathan","Henry","Douglas","Zachary","Peter","Kyle","Noah","Ethan","Jeremy","Walter","Christian","Keith","Roger","Terry","Austin","Sean","Gerald","Carl","Harold","Dylan","Arthur","Lawrence","Jordan","Jesse","Bryan","Billy","Bruce","Gabriel","Joe","Logan","Albert","Willie","Alan","Vincent","Eugene","Russell","Bobby","Johnny","Philip"}
local FemaleNames = {"Mary","Patricia","Jennifer","Linda","Barbara","Elizabeth","Susan","Jessica","Sarah","Karen","Lisa","Nancy","Betty","Margaret","Sandra","Ashley","Kimberly","Emily","Donna","Michelle","Dorothy","Carol","Amanda","Melissa","Deborah","Stephanie","Rebecca","Sharon","Laura","Cynthia","Kathleen","Amy","Angela","Shirley","Anna","Brenda","Pamela","Emma","Nicole","Helen","Samantha","Katherine","Christine","Debra","Rachel","Carolyn","Janet","Catherine","Maria","Heather","Diane","Ruth","Julie","Olivia","Joyce","Virginia","Victoria","Kelly","Lauren","Christina","Joan","Evelyn","Judith","Megan","Andrea","Cheryl","Hannah","Jacqueline","Martha","Gloria","Teresa","Ann","Sara","Madison","Frances","Kathryn","Janice","Jean","Abigail","Alice","Judy","Sophia","Grace","Denise","Amber","Doris","Marilyn","Danielle","Beverly","Isabella","Theresa","Diana","Natalie","Brittany","Charlotte","Marie","Kayla","Alexis","Lori"}
local LastNames = {"Smith","Johnson","Williams","Brown","Jones","Garcia","Miller","Davis","Rodriguez","Martinez","Hernandez","Lopez","Gonzalez","Wilson","Anderson","Thomas","Taylor","Moore","Jackson","Martin","Lee","Perez","Thompson","White","Harris","Sanchez","Clark","Ramirez","Lewis","Robinson","Walker","Young","Allen","King","Wright","Scott","Torres","Nguyen","Hill","Flores","Green","Adams","Nelson","Baker","Hall","Rivera","Campbell","Mitchell","Carter","Roberts","Turner","Phillips","Evans","Parker","Edwards","Collins","Stewart","Morris","Murphy","Cook","Rogers","Morgan","Peterson","Cooper","Reed","Bailey","Bell","Gomez","Kelly","Howard","Ward","Cox","Diaz","Richardson","Wood","Watson","Brooks","Bennett","Gray","James","Reyes","Cruz","Hughes","Price","Myers","Long","Foster","Sanders","Ross","Morales","Powell","Sullivan","Russell","Ortiz","Jenkins","Gutierrez","Perry","Butler","Barnes","Fisher"}

local function randomMaleName() return MaleNames[math.random(#MaleNames)] end
local function randomFemaleName() return FemaleNames[math.random(#FemaleNames)] end
local function randomName() return math.random(2) == 1 and randomMaleName() or randomFemaleName() end
local function randomLastName() return LastNames[math.random(#LastNames)] end
local function randomFullName() return randomName() .. " " .. randomLastName() end

local Companies = {"TechCorp","GlobalBank","MegaMart","United Industries","Pacific Holdings","Atlantic Group","Summit Enterprises","Horizon Inc","Pinnacle Systems","Vanguard Solutions","Apex Technologies","Prime Industries","Elite Corp","Dynasty Holdings","Empire Group","Titan Industries","Phoenix Corp","Stellar Systems","Quantum Dynamics","Nova Enterprises"}
local function randomCompany() return Companies[math.random(#Companies)] end

local Cities = {"New York","Los Angeles","Chicago","Houston","Phoenix","Philadelphia","San Antonio","San Diego","Dallas","San Jose","Austin","Jacksonville","Fort Worth","Columbus","Charlotte","Seattle","Denver","Boston","Detroit","Nashville","Portland","Las Vegas","Memphis","Louisville","Baltimore","Milwaukee","Albuquerque","Tucson","Fresno","Sacramento","Miami","Atlanta","Cleveland","Oakland","Minneapolis"}
local function randomCity() return Cities[math.random(#Cities)] end

local Countries = {"France","Japan","Italy","Germany","Spain","Australia","Brazil","Canada","Mexico","UK","China","India","Russia","South Korea","Thailand","Egypt","Greece","Turkey","Switzerland","Netherlands"}
local function randomCountry() return Countries[math.random(#Countries)] end

-- ═══════════════════════════════════════════════════════════════
-- STANDARD LIFE EVENTS (Childhood, Teen, Adult)
-- ═══════════════════════════════════════════════════════════════

local StandardEvents = {
	-- BABY/TODDLER (0-4)
	{
		id = "first_steps", minAge = 1, maxAge = 2, weight = 100, milestone = true, oneTime = true,
		emoji = "👶", title = "First Steps!",
		text = "You took your first steps today! Your parents couldn't be prouder as you wobbled across the living room.",
		choices = {
			{ text = "Giggle happily", effects = { Happiness = 10 }, result = "You clapped your tiny hands in delight!" },
			{ text = "Fall down", effects = { Happiness = 5 }, result = "Oops! But you got right back up. Resilient little one!" },
		}
	},
	{
		id = "first_words", minAge = 1, maxAge = 3, weight = 100, milestone = true, oneTime = true,
		emoji = "🗣️", title = "First Words",
		text = "You spoke your first word today! What was it?",
		choices = {
			{ text = '"Mama"', effects = { Happiness = 15 }, result = "Your mother burst into happy tears!" },
			{ text = '"Dada"', effects = { Happiness = 15 }, result = "Your father beamed with pride!" },
			{ text = '"No!"', effects = { Happiness = 5 }, result = "Already showing your independent spirit!" },
		}
	},
	
	-- EARLY CHILDHOOD (5-10)
	{
		id = "first_day_school", minAge = 5, maxAge = 6, weight = 100, milestone = true, oneTime = true,
		emoji = "🏫", title = "First Day of School",
		text = "Today is your first day of elementary school. The building looks huge and there are so many kids...",
		choices = {
			{ text = "Walk in confidently", effects = { Happiness = 10, Smarts = 5 }, result = "You made three new friends by lunchtime!" },
			{ text = "Cling to parent", effects = { Happiness = -5 }, result = "It was scary, but you eventually settled in." },
			{ text = "Explore everything", effects = { Smarts = 10 }, result = "You found the library and stayed there all recess!" },
		}
	},
	{
		id = "playground_bully", minAge = 6, maxAge = 10, weight = 15, cooldown = 3,
		emoji = "😠", title = "Playground Trouble",
		getDynamicData = function() return { bullyName = randomName() } end,
		text = "%bullyName% pushed you off the swings and called you names. What do you do?",
		choices = {
			{ text = "Tell a teacher", effects = { Smarts = 5 }, result = "The teacher handled it. %bullyName% got detention." },
			{ text = "Push back", effects = { Health = -5 }, result = "You got in a fight. Both of you got in trouble." },
			{ text = "Walk away", effects = { Happiness = -5 }, result = "It hurt, but you stayed out of trouble." },
			{ text = "Try to befriend them", effects = { Happiness = 5 }, result = "Surprisingly, %bullyName% apologized and you became friends!" },
		}
	},
	{
		id = "talent_show", minAge = 7, maxAge = 12, weight = 12, cooldown = 2,
		emoji = "🎤", title = "School Talent Show",
		text = "The school talent show is coming up. Do you want to participate?",
		choices = {
			{ text = "Sing a song", effects = { Happiness = 10, Looks = 5 }, result = "You brought the house down! Standing ovation!" },
			{ text = "Do a magic trick", effects = { Smarts = 5, Happiness = 5 }, result = "The audience was amazed!" },
			{ text = "Skip it", effects = {}, result = "You watched from the audience instead." },
		}
	},
	{
		id = "pet_adoption", minAge = 6, maxAge = 14, weight = 10, oneTime = true,
		emoji = "🐕", title = "A New Friend",
		text = "Your family is at the animal shelter. There's a puppy looking at you with big sad eyes...",
		choices = {
			{ text = "Adopt the puppy!", effects = { Happiness = 20 }, result = "You named him Max. He's your best friend now!" },
			{ text = "Choose a kitten instead", effects = { Happiness = 15 }, result = "You got a fluffy orange cat named Whiskers!" },
			{ text = "Not ready for a pet", effects = {}, result = "Maybe someday..." },
		}
	},
	
	-- TEENAGE YEARS (13-17)
	{
		id = "first_crush", minAge = 12, maxAge = 16, weight = 20, oneTime = true,
		emoji = "💕", title = "First Crush",
		getDynamicData = function() return { crushName = randomFullName() } end,
		text = "You can't stop thinking about %crushName%. Every time they walk by, your heart races...",
		choices = {
			{ text = "Write them a love note", effects = { Happiness = 10 }, result = "They smiled when they read it! Maybe there's hope!" },
			{ text = "Ask them out", effects = { Happiness = 15 }, result = "They said yes! Your first date is Friday!" },
			{ text = "Admire from afar", effects = { Happiness = -5 }, result = "You never found out if they liked you back..." },
			{ text = "Have a friend talk to them", effects = { Happiness = 5 }, result = "Your friend reported back: they think you're cute!" },
		}
	},
	{
		id = "house_party", minAge = 15, maxAge = 18, weight = 15, cooldown = 1,
		emoji = "🎉", title = "House Party",
		getDynamicData = function() return { hostName = randomName() } end,
		text = "%hostName%'s parents are out of town and they're throwing a party. Everyone's going...",
		choices = {
			{ text = "Party hard!", effects = { Happiness = 15, Health = -5 }, result = "Best night ever! Though you feel rough the next day..." },
			{ text = "Go but stay responsible", effects = { Happiness = 10 }, result = "You had fun and made it home safely!" },
			{ text = "Skip it", effects = { Happiness = -5, Smarts = 5 }, result = "You studied instead. Good grades incoming!" },
			{ text = "Call the cops", effects = { Happiness = -10 }, result = "Party's over. %hostName% will never forgive you." },
		}
	},
	{
		id = "drivers_license", minAge = 16, maxAge = 17, weight = 100, milestone = true, oneTime = true,
		emoji = "🚗", title = "Driver's Test",
		text = "Today's the big day - your driving test! Your palms are sweaty as you get behind the wheel...",
		choices = {
			{ text = "Stay calm and focused", effects = { Happiness = 20 }, result = "You passed! Freedom awaits!" },
			{ text = "Speed through it", effects = { Happiness = -10 }, result = "Failed for reckless driving. Try again in 2 weeks." },
		}
	},
	{
		id = "prom_night", minAge = 17, maxAge = 18, weight = 100, milestone = true, oneTime = true,
		emoji = "👗", title = "Prom Night",
		getDynamicData = function() return { dateName = randomFullName() } end,
		text = "Prom is here! %dateName% agreed to be your date. The limo is waiting...",
		choices = {
			{ text = "Dance the night away", effects = { Happiness = 25, Looks = 5 }, result = "Magical night! You even won Prom Royalty!" },
			{ text = "Hang with friends", effects = { Happiness = 15 }, result = "Great memories with your crew!" },
			{ text = "Leave early for afterparty", effects = { Happiness = 10, Health = -5 }, result = "The afterparty was wild..." },
		}
	},
	
	-- YOUNG ADULT (18-25)
	{
		id = "college_acceptance", minAge = 17, maxAge = 18, weight = 100, milestone = true, oneTime = true,
		emoji = "📬", title = "College Decision",
		getDynamicData = function() return { collegeName = randomCity() .. " University" } end,
		text = "The letter from %collegeName% arrived. This is the moment you've been waiting for...",
		choices = {
			{ text = "Open it!", effects = { Happiness = 20, Smarts = 10 }, result = "ACCEPTED! Your future is bright!" },
			{ text = "Have someone else open it", effects = { Happiness = 15, Smarts = 10 }, result = "Your mom screamed - you got in!" },
		}
	},
	{
		id = "college_roommate", minAge = 18, maxAge = 19, weight = 50, oneTime = true,
		emoji = "🏠", title = "College Roommate",
		getDynamicData = function() return { roommateName = randomFullName() } end,
		text = "You meet your college roommate, %roommateName%. They seem... interesting.",
		choices = {
			{ text = "Be friendly and open", effects = { Happiness = 10 }, result = "You two became best friends!" },
			{ text = "Set clear boundaries", effects = { Happiness = 5 }, result = "Professional relationship. Could be worse!" },
			{ text = "Request a room change", effects = { Happiness = -5 }, result = "Awkward, but you got a new room." },
		}
	},
	{
		id = "spring_break", minAge = 18, maxAge = 22, weight = 20, cooldown = 1,
		emoji = "🏖️", title = "Spring Break!",
		getDynamicData = function() return { destination = randomCity() } end,
		text = "Spring break is here! Your friends want to go to %destination%...",
		choices = {
			{ text = "Road trip!", effects = { Happiness = 20, Money = -500 }, result = "Best week of your life!" },
			{ text = "Stay home and work", effects = { Happiness = -5, Money = 800 }, result = "At least your bank account is happy." },
			{ text = "Study for midterms", effects = { Smarts = 15 }, result = "You aced your exams!" },
		}
	},
	{
		id = "graduation_college", minAge = 22, maxAge = 24, weight = 100, milestone = true, oneTime = true,
		requires = function(state) return state.Education == "College" end,
		emoji = "🎓", title = "College Graduation",
		text = "Four years of hard work have led to this moment. You're about to graduate!",
		choices = {
			{ text = "Celebrate with family", effects = { Happiness = 25 }, result = "Your family is so proud!" },
			{ text = "Already thinking about career", effects = { Happiness = 10, Smarts = 5 }, result = "Focused on the future!" },
		}
	},
	
	-- ADULT LIFE (25+)
	{
		id = "job_promotion", minAge = 25, maxAge = 55, weight = 15, cooldown = 3,
		requires = function(state) return state.Job ~= nil end,
		emoji = "📈", title = "Promotion Opportunity",
		getDynamicData = function() return { salary = math.random(5, 20) * 10000 } end,
		text = "Your boss called you into the office. There's a promotion available with a raise to $%salary%/year!",
		choices = {
			{ text = "Accept enthusiastically", effects = { Happiness = 15, Money = 5000 }, result = "Congratulations! You've moved up!" },
			{ text = "Negotiate for more", effects = { Happiness = 20, Money = 10000 }, result = "They agreed to even more money!" },
			{ text = "Decline - too much stress", effects = { Happiness = 5 }, result = "Work-life balance is important too." },
		}
	},
	{
		id = "marriage_proposal", minAge = 24, maxAge = 40, weight = 10, oneTime = true,
		emoji = "💍", title = "The Big Question",
		getDynamicData = function() return { partnerName = randomFullName() } end,
		text = "After years together, %partnerName% gets down on one knee with a ring...",
		choices = {
			{ text = '"Yes! A thousand times yes!"', effects = { Happiness = 30 }, result = "You're engaged! Wedding planning begins!" },
			{ text = '"I need time to think..."', effects = { Happiness = -10 }, result = "They understood, but looked hurt." },
			{ text = '"I\'m sorry, but no"', effects = { Happiness = -20 }, result = "It was heartbreaking, but you knew it wasn't right." },
		}
	},
	{
		id = "baby_born", minAge = 25, maxAge = 45, weight = 8, oneTime = true,
		emoji = "👶", title = "A New Life",
		getDynamicData = function() return { babyName = randomName(), gender = math.random(2) == 1 and "boy" or "girl" } end,
		text = "It's a %gender%! You hold your newborn, %babyName%, for the first time...",
		choices = {
			{ text = "Cry tears of joy", effects = { Happiness = 30 }, result = "The happiest moment of your life!" },
			{ text = "Promise to be the best parent", effects = { Happiness = 25 }, result = "You're going to give them everything." },
		}
	},
	{
		id = "midlife_crisis", minAge = 40, maxAge = 50, weight = 15, oneTime = true,
		emoji = "🏎️", title = "Midlife Reflection",
		text = "You wake up and realize you're not young anymore. What have you done with your life?",
		choices = {
			{ text = "Buy a sports car", effects = { Happiness = 10, Money = -50000 }, result = "VROOM VROOM! You feel 20 again!" },
			{ text = "Start a new hobby", effects = { Happiness = 15, Health = 5 }, result = "You discovered a passion for painting!" },
			{ text = "Appreciate what you have", effects = { Happiness = 20 }, result = "Life is good. Really good." },
			{ text = "Make drastic changes", effects = { Happiness = -5 }, result = "You quit your job and dyed your hair. Now what?" },
		}
	},
	{
		id = "lottery_win", minAge = 18, maxAge = 80, weight = 1,
		emoji = "🎰", title = "Lucky Numbers!",
		getDynamicData = function() return { amount = math.random(10, 100) * 10000 } end,
		text = "You bought a lottery ticket on a whim and... YOU WON $%amount%!",
		choices = {
			{ text = "Invest it wisely", effects = { Happiness = 20 }, getDynamicMoney = function(d) return d.amount end, result = "Smart move! Your future is secure." },
			{ text = "Quit your job!", effects = { Happiness = 25 }, getDynamicMoney = function(d) return d.amount end, result = "Freedom! But maybe keep a budget..." },
			{ text = "Give to charity", effects = { Happiness = 30 }, getDynamicMoney = function(d) return d.amount / 2 end, result = "You changed so many lives. Hero!" },
		}
	},
}

-- ═══════════════════════════════════════════════════════════════
-- POLITICAL CAREER PATH (President Track)
-- ═══════════════════════════════════════════════════════════════

local PoliticalEvents = {
	-- EARLY POLITICAL AWAKENING
	{
		id = "pol_student_council", minAge = 14, maxAge = 18, weight = 20, oneTime = true,
		emoji = "🗳️", title = "Student Council",
		text = "Elections for student council president are coming up. You've always had strong opinions...",
		choices = {
			{ text = "Run for president!", effects = { Happiness = 10, Smarts = 5 }, result = "You won! Your political journey begins.", setFlag = "political_interest" },
			{ text = "Join the debate team instead", effects = { Smarts = 10 }, result = "You became a master debater!", setFlag = "political_interest" },
			{ text = "Not interested in politics", effects = {}, result = "Politics isn't for everyone." },
		}
	},
	{
		id = "pol_internship", minAge = 18, maxAge = 24, weight = 25,
		requires = function(state) return state.Flags and state.Flags.political_interest end,
		emoji = "🏛️", title = "Congressional Internship",
		getDynamicData = function() return { senatorName = "Senator " .. randomFullName() } end,
		text = "%senatorName% is offering internships. This could launch your political career!",
		choices = {
			{ text = "Apply immediately", effects = { Happiness = 15, Smarts = 10 }, result = "You got it! You're learning the ropes of Washington.", setFlag = "political_experience" },
			{ text = "Focus on school first", effects = { Smarts = 5 }, result = "Maybe after graduation..." },
		}
	},
	{
		id = "pol_campaign_volunteer", minAge = 18, maxAge = 30, weight = 20,
		requires = function(state) return state.Flags and state.Flags.political_interest end,
		emoji = "📢", title = "Campaign Trail",
		getDynamicData = function() return { candidateName = randomFullName(), party = math.random(2) == 1 and "Progressive" or "Conservative" } end,
		text = "%candidateName% is running for governor on the %party% ticket. They need volunteers!",
		choices = {
			{ text = "Join the campaign", effects = { Happiness = 10 }, result = "You learned grassroots organizing!", setFlag = "campaign_experience" },
			{ text = "Donate money instead", effects = { Money = -1000 }, result = "Every dollar helps!" },
			{ text = "Stay neutral", effects = {}, result = "You watched from the sidelines." },
		}
	},
	
	-- POLITICAL CAREER LAUNCH
	{
		id = "pol_city_council", minAge = 25, maxAge = 40, weight = 15, oneTime = true,
		requires = function(state) return state.Flags and state.Flags.political_experience end,
		emoji = "🏙️", title = "City Council Race",
		getDynamicData = function() return { city = randomCity() } end,
		text = "A seat on the %city% City Council is open. Your supporters think you should run!",
		choices = {
			{ text = "Launch your campaign!", effects = { Happiness = 15, Money = -20000 }, result = "After a hard-fought race... YOU WON!", setFlag = "elected_official" },
			{ text = "Wait for a better opportunity", effects = {}, result = "Patience is a political virtue." },
			{ text = "Run negative ads", effects = { Happiness = 5, Money = -30000 }, result = "You won, but made enemies.", setFlag = "elected_official" },
		}
	},
	{
		id = "pol_corruption_scandal", minAge = 28, maxAge = 60, weight = 10, cooldown = 5,
		requires = function(state) return state.Flags and state.Flags.elected_official end,
		emoji = "💰", title = "Bribery Offer",
		getDynamicData = function() return { company = randomCompany(), amount = math.random(50, 500) * 1000 } end,
		text = "A lobbyist from %company% offers you $%amount% to vote their way. Nobody would know...",
		choices = {
			{ text = "Take the money", effects = { Money = 100000, Happiness = -10 }, result = "You're richer, but at what cost?", setFlag = "corrupt" },
			{ text = "Report them to ethics committee", effects = { Happiness = 20 }, result = "You're a hero! Major news coverage!", setFlag = "integrity" },
			{ text = "Politely decline", effects = { Happiness = 5 }, result = "You kept your hands clean." },
		}
	},
	{
		id = "pol_state_senate", minAge = 30, maxAge = 50, weight = 12, oneTime = true,
		requires = function(state) return state.Flags and state.Flags.elected_official end,
		emoji = "🏛️", title = "State Senate Bid",
		text = "You've built a strong reputation. Time to aim higher - the State Senate!",
		choices = {
			{ text = "Run a positive campaign", effects = { Happiness = 15, Money = -100000 }, result = "Your message resonated! Senator elect!", setFlag = "state_senator" },
			{ text = "Go negative on opponent", effects = { Happiness = 5, Money = -150000 }, result = "Ugly race, but you won.", setFlag = "state_senator" },
			{ text = "Not ready yet", effects = {}, result = "You'll get there someday." },
		}
	},
	{
		id = "pol_major_legislation", minAge = 32, maxAge = 55, weight = 15,
		requires = function(state) return state.Flags and state.Flags.state_senator end,
		emoji = "📜", title = "Landmark Bill",
		getDynamicData = function()
			local bills = {
				{ name = "Universal Healthcare Act", effect = "Smarts" },
				{ name = "Education Reform Bill", effect = "Smarts" },
				{ name = "Environmental Protection Act", effect = "Health" },
				{ name = "Economic Stimulus Package", effect = "Money" },
			}
			return { bill = bills[math.random(#bills)] }
		end,
		text = "You have a chance to sponsor the %bill.name%. This could define your legacy!",
		choices = {
			{ text = "Champion the bill", effects = { Happiness = 20 }, result = "After months of debate... IT PASSED! Historic!", setFlag = "major_achievement" },
			{ text = "Compromise for bipartisan support", effects = { Happiness = 15 }, result = "Watered down, but it passed with broad support." },
			{ text = "It's too controversial", effects = { Happiness = -5 }, result = "You played it safe." },
		}
	},
	{
		id = "pol_congress", minAge = 35, maxAge = 55, weight = 10, oneTime = true,
		requires = function(state) return state.Flags and state.Flags.state_senator and state.Flags.major_achievement end,
		emoji = "🇺🇸", title = "Congressional Race",
		text = "The people want you in Washington! Will you run for U.S. Congress?",
		choices = {
			{ text = "Run for Congress!", effects = { Happiness = 20, Money = -500000 }, result = "CONGRESSMAN/WOMAN ELECT! You're going to DC!", setFlag = "congressman" },
			{ text = "Run for U.S. Senate instead", effects = { Happiness = 25, Money = -2000000 }, result = "You aimed even higher... SENATOR ELECT!", setFlag = "us_senator" },
			{ text = "Stay at state level", effects = { Happiness = 5 }, result = "Local politics has its rewards too." },
		}
	},
	{
		id = "pol_presidential_primary", minAge = 40, maxAge = 65, weight = 8, oneTime = true,
		requires = function(state) return state.Flags and (state.Flags.congressman or state.Flags.us_senator) end,
		emoji = "🎖️", title = "Presidential Ambition",
		text = "Party leaders are talking about you as a potential presidential candidate. The White House...",
		choices = {
			{ text = "Announce your candidacy!", effects = { Happiness = 20, Money = -5000000 }, result = "The campaign begins! Primary season awaits!", setFlag = "presidential_candidate", minigame = "debate" },
			{ text = "Test the waters first", effects = { Happiness = 10, Money = -1000000 }, result = "You're exploring a run, gauging support..." },
			{ text = "Not yet - need more experience", effects = {}, result = "Maybe in 4 years..." },
		}
	},
	{
		id = "pol_debate_night", minAge = 40, maxAge = 70, weight = 100,
		requires = function(state) return state.Flags and state.Flags.presidential_candidate end,
		emoji = "🎤", title = "Presidential Debate",
		getDynamicData = function() return { opponentName = randomFullName() } end,
		text = "Tonight's debate against %opponentName% will be watched by 80 million people. Are you ready?",
		choices = {
			{ text = "Stick to policy points", effects = { Happiness = 15, Smarts = 5 }, result = "Solid performance! Pundits say you won!", minigame = "debate" },
			{ text = "Go on the attack", effects = { Happiness = 10 }, result = "Brutal zingers! Social media is exploding!" },
			{ text = "Connect emotionally", effects = { Happiness = 20 }, result = "Your personal story moved the nation to tears." },
		}
	},
	{
		id = "pol_election_night", minAge = 40, maxAge = 70, weight = 100, oneTime = true,
		requires = function(state) return state.Flags and state.Flags.presidential_candidate end,
		emoji = "🗳️", title = "Election Night",
		text = "This is it. Years of work, millions of miles traveled, countless handshakes. The results are coming in...",
		choices = {
			{ text = "Watch with family", effects = { Happiness = 30 }, result = "The networks call it... YOU ARE THE PRESIDENT-ELECT!", setFlag = "president" },
			{ text = "Work the phone banks til close", effects = { Happiness = 25 }, result = "Your dedication paid off. MR./MADAM PRESIDENT!", setFlag = "president" },
		}
	},
	{
		id = "pol_inauguration", minAge = 40, maxAge = 75, weight = 100, milestone = true, oneTime = true,
		requires = function(state) return state.Flags and state.Flags.president end,
		emoji = "🎊", title = "Inauguration Day",
		text = 'You stand on the steps of the Capitol. Chief Justice: "Do you solemnly swear to faithfully execute the Office of President..."',
		choices = {
			{ text = '"I do solemnly swear..."', effects = { Happiness = 50 }, result = "CONGRATULATIONS, MR./MADAM PRESIDENT! You did it!" },
		}
	},
	{
		id = "pol_crisis", minAge = 40, maxAge = 75, weight = 15, cooldown = 2,
		requires = function(state) return state.Flags and state.Flags.president end,
		emoji = "🚨", title = "National Crisis",
		getDynamicData = function()
			local crises = {
				{ type = "pandemic", desc = "A deadly virus is spreading rapidly" },
				{ type = "economic", desc = "The stock market crashed 40% overnight" },
				{ type = "military", desc = "Foreign troops have invaded an ally" },
				{ type = "disaster", desc = "A massive earthquake devastated the West Coast" },
			}
			return { crisis = crises[math.random(#crises)] }
		end,
		text = "BREAKING: %crisis.desc%. The nation looks to you for leadership!",
		choices = {
			{ text = "Address the nation immediately", effects = { Happiness = 15 }, result = "Your calm leadership steadied the nation." },
			{ text = "Convene emergency cabinet meeting", effects = { Smarts = 10 }, result = "Swift, decisive action. History will judge you well." },
			{ text = "Blame the previous administration", effects = { Happiness = -20 }, result = "Poor optics. Approval rating tanks." },
		}
	},
}

-- ═══════════════════════════════════════════════════════════════
-- CRIMINAL CAREER PATH (Crime Boss Track)
-- ═══════════════════════════════════════════════════════════════

local CriminalEvents = {
	-- EARLY CRIMINAL BEHAVIOR
	{
		id = "crime_shoplifting", minAge = 10, maxAge = 16, weight = 15, cooldown = 2,
		emoji = "🏪", title = "Five-Finger Discount",
		text = "Your friends dare you to steal a candy bar from the corner store. The cashier isn't looking...",
		choices = {
			{ text = "Swipe it!", effects = { Happiness = 5 }, result = "Easy money! Well, easy candy. You feel a rush.", setFlag = "criminal_tendencies" },
			{ text = "Refuse", effects = { Happiness = 5 }, result = "Your friends called you chicken, but who cares?" },
			{ text = "Get caught on purpose", effects = { Happiness = -10 }, result = "The store called your parents. Grounded for a month!" },
		}
	},
	{
		id = "crime_car_theft", minAge = 14, maxAge = 20, weight = 12,
		requires = function(state) return state.Flags and state.Flags.criminal_tendencies end,
		emoji = "🚗", title = "Joyride",
		text = "There's a nice car with the keys left in it. Your heart is pounding...",
		choices = {
			{ text = "Take it for a spin", effects = { Happiness = 15 }, result = "What a rush! You ditched it before anyone noticed.", setFlag = "car_thief", minigame = "getaway" },
			{ text = "Steal it for real", effects = { Happiness = 10, Money = 5000 }, result = "You sold it to a chop shop. Quick cash!", setFlag = "car_thief" },
			{ text = "Walk away", effects = { Happiness = -5 }, result = "You're not ready for the big leagues." },
		}
	},
	{
		id = "crime_gang_recruitment", minAge = 15, maxAge = 25, weight = 15, oneTime = true,
		requires = function(state) return state.Flags and state.Flags.criminal_tendencies end,
		emoji = "🔫", title = "Gang Invitation",
		getDynamicData = function() return { gangName = math.random(2) == 1 and "The Serpents" or "Blood Ravens", leaderName = randomFullName() } end,
		text = "%leaderName% from %gangName% approaches you. 'We've been watching you. You've got skills. Want in?'",
		choices = {
			{ text = "Join the gang", effects = { Happiness = 10 }, result = "You're initiated. %gangName% has your back now.", setFlag = "gang_member" },
			{ text = "Work freelance", effects = {}, result = "You prefer to operate alone." },
			{ text = "Go straight", effects = { Happiness = 5 }, result = "You walked away from that life." },
		}
	},
	
	-- BUILDING CRIMINAL EMPIRE
	{
		id = "crime_drug_deal", minAge = 18, maxAge = 40, weight = 15, cooldown = 1,
		requires = function(state) return state.Flags and state.Flags.gang_member end,
		emoji = "💊", title = "Big Score",
		getDynamicData = function() return { amount = math.random(10, 100) * 1000, buyerName = randomFullName() } end,
		text = "%buyerName% wants to buy $%amount% worth of product. This is a major deal...",
		choices = {
			{ text = "Make the deal", effects = { Money = 50000, Happiness = 10 }, result = "Clean exchange. You're moving up!", minigame = "heist" },
			{ text = "Set up a sting", effects = { Happiness = -20 }, result = "You became an informant. Witness protection awaits." },
			{ text = "Rob the buyer", effects = { Money = 75000, Happiness = -10 }, result = "Double cross! But now you have enemies...", setFlag = "violent_criminal" },
		}
	},
	{
		id = "crime_turf_war", minAge = 18, maxAge = 45, weight = 12, cooldown = 2,
		requires = function(state) return state.Flags and state.Flags.gang_member end,
		emoji = "⚔️", title = "Turf War",
		getDynamicData = function() return { rivalGang = math.random(2) == 1 and "The Cobras" or "Shadow Kings" } end,
		text = "%rivalGang% is moving into your territory. This means war!",
		choices = {
			{ text = "Fight for every block", effects = { Health = -20, Happiness = 10 }, result = "Bloody battles, but you held the line!", setFlag = "war_veteran" },
			{ text = "Negotiate a truce", effects = { Happiness = 5 }, result = "Diplomacy won. You split the territory." },
			{ text = "Eliminate their leader", effects = { Health = -10 }, result = "With the head gone, %rivalGang% fell apart.", setFlag = "killer", minigame = "heist" },
		}
	},
	{
		id = "crime_prison_sentence", minAge = 18, maxAge = 60, weight = 10, cooldown = 5,
		requires = function(state) return state.Flags and state.Flags.gang_member end,
		emoji = "⛓️", title = "Busted!",
		getDynamicData = function() return { years = math.random(2, 10), charge = math.random(3) == 1 and "drug trafficking" or "racketeering" } end,
		text = "The feds kicked down your door at 5 AM. You're charged with %charge%. Facing %years% years...",
		choices = {
			{ text = "Go to trial", effects = { Happiness = -15, Money = -100000 }, result = "Found guilty. %years% years in federal prison.", setFlag = "ex_con" },
			{ text = "Take a plea deal", effects = { Happiness = -10 }, result = "3 years. You can do that standing on your head.", setFlag = "ex_con" },
			{ text = "Cooperate with feds", effects = { Happiness = -30 }, result = "You're a rat now. New identity, new city." },
		}
	},
	{
		id = "crime_prison_life", minAge = 18, maxAge = 65, weight = 50,
		requires = function(state) return state.Flags and state.Flags.ex_con and state.InJail end,
		emoji = "🏛️", title = "Behind Bars",
		getDynamicData = function() return { inmateName = randomFullName() } end,
		text = "Prison is rough. %inmateName% is testing you in the yard...",
		choices = {
			{ text = "Stand your ground", effects = { Health = -15, Happiness = 5 }, result = "You earned respect the hard way.", setFlag = "prison_respect" },
			{ text = "Join a prison gang", effects = { Happiness = 10 }, result = "Protection comes with obligations.", setFlag = "prison_gang" },
			{ text = "Keep your head down", effects = { Happiness = -10 }, result = "You survived by staying invisible." },
		}
	},
	
	-- RISE TO POWER
	{
		id = "crime_underboss", minAge = 25, maxAge = 50, weight = 10, oneTime = true,
		requires = function(state) return state.Flags and state.Flags.gang_member and state.Flags.war_veteran end,
		emoji = "🎖️", title = "Promotion",
		getDynamicData = function() return { bossName = randomFullName() } end,
		text = "%bossName% is impressed with your work. 'I'm making you my underboss. Don't disappoint me.'",
		choices = {
			{ text = "Accept with gratitude", effects = { Happiness = 20, Money = 100000 }, result = "You're second in command now. Power feels good.", setFlag = "underboss" },
			{ text = "Already planning to take over", effects = { Happiness = 15 }, result = "Smile and nod. Your time will come.", setFlag = "underboss" },
		}
	},
	{
		id = "crime_assassination_attempt", minAge = 28, maxAge = 55, weight = 12,
		requires = function(state) return state.Flags and state.Flags.underboss end,
		emoji = "🔫", title = "Hit Ordered",
		getDynamicData = function() return { targetName = randomFullName() } end,
		text = "The boss wants %targetName% eliminated. They know too much.",
		choices = {
			{ text = "Handle it personally", effects = { Happiness = -15, Health = -10 }, result = "It's done. No witnesses.", setFlag = "killer", minigame = "heist" },
			{ text = "Send someone else", effects = { Money = -50000 }, result = "Delegation is key to leadership." },
			{ text = "Warn the target", effects = { Happiness = 5 }, result = "They disappeared. The boss suspects nothing... for now." },
		}
	},
	{
		id = "crime_coup", minAge = 30, maxAge = 55, weight = 8, oneTime = true,
		requires = function(state) return state.Flags and state.Flags.underboss and state.Flags.killer end,
		emoji = "👑", title = "The Coup",
		getDynamicData = function() return { bossName = randomFullName() } end,
		text = "The boss is getting old and weak. You have loyal soldiers. Tonight, you make your move on %bossName%...",
		choices = {
			{ text = "Strike!", effects = { Happiness = 20, Money = 500000 }, result = "It's done. Long live the new boss. YOU.", setFlag = "crime_boss", minigame = "heist" },
			{ text = "Wait for natural succession", effects = { Happiness = 5 }, result = "Patience. Your time will come legally... well, 'legally.'" },
			{ text = "Stay loyal", effects = { Happiness = 10 }, result = "Loyalty has its rewards. The boss trusts you completely." },
		}
	},
	{
		id = "crime_empire_building", minAge = 32, maxAge = 60, weight = 15, cooldown = 2,
		requires = function(state) return state.Flags and state.Flags.crime_boss end,
		emoji = "🏰", title = "Expanding the Empire",
		getDynamicData = function() return { territory = randomCity(), amount = math.random(100, 500) * 10000 } end,
		text = "There's an opportunity to expand into %territory%. It'll cost $%amount% to set up operations...",
		choices = {
			{ text = "Expand aggressively", effects = { Money = -1000000, Happiness = 15 }, result = "New territory secured! Your empire grows.", setFlag = "empire_expanded" },
			{ text = "Send scouts first", effects = { Money = -100000 }, result = "Careful planning pays off. Smooth expansion." },
			{ text = "Focus on home turf", effects = { Happiness = 5 }, result = "Consolidation over expansion. Smart." },
		}
	},
	{
		id = "crime_rico_case", minAge = 35, maxAge = 65, weight = 8, oneTime = true,
		requires = function(state) return state.Flags and state.Flags.crime_boss end,
		emoji = "🚔", title = "RICO Investigation",
		getDynamicData = function() return { agentName = "Agent " .. randomFullName() } end,
		text = "%agentName% from the FBI has been building a RICO case against you for years. The walls are closing in...",
		choices = {
			{ text = "Lawyer up and fight", effects = { Money = -5000000 }, result = "The case fell apart. Your lawyers are worth every penny.", minigame = "heist" },
			{ text = "Flee the country", effects = { Money = -2000000, Happiness = -20 }, result = "You're living in luxury... but you can never go home.", setFlag = "fugitive" },
			{ text = "Cut a deal", effects = { Happiness = -30 }, result = "15 years. But you kept your mouth shut about everyone else." },
		}
	},
	{
		id = "crime_legitimate", minAge = 40, maxAge = 65, weight = 12, oneTime = true,
		requires = function(state) return state.Flags and state.Flags.crime_boss end,
		emoji = "🏢", title = "Going Legitimate",
		getDynamicData = function() return { businessName = randomCompany() } end,
		text = "You have enough money to go straight. Buy %businessName% and become a 'legitimate' businessman?",
		choices = {
			{ text = "Clean money is better", effects = { Happiness = 25, Money = -10000000 }, result = "You're a respected business owner now. The past stays buried.", setFlag = "legitimate" },
			{ text = "Keep the streets", effects = { Happiness = 10 }, result = "You are what you are. The game chose you." },
			{ text = "Do both", effects = { Happiness = 15, Money = -5000000 }, result = "Diversification. Legal front, illegal back." },
		}
	},
	{
		id = "crime_legacy", minAge = 50, maxAge = 75, weight = 10, oneTime = true,
		requires = function(state) return state.Flags and state.Flags.crime_boss end,
		emoji = "👨‍👧", title = "The Next Generation",
		getDynamicData = function() return { childName = randomName() } end,
		text = "Your child, %childName%, wants to join the family business. They know everything...",
		choices = {
			{ text = "Welcome them", effects = { Happiness = 20 }, result = "The dynasty continues. You trained them well." },
			{ text = "Send them away", effects = { Happiness = -10 }, result = "You wanted better for them. College, normal life." },
			{ text = "Test their loyalty first", effects = {}, result = "They passed. Blood is thicker than water." },
		}
	},
}

-- ═══════════════════════════════════════════════════════════════
-- COMBINE ALL EVENTS
-- ═══════════════════════════════════════════════════════════════

EventLibrary.Events = {}

-- Add all standard events
for _, event in ipairs(StandardEvents) do
	table.insert(EventLibrary.Events, event)
end

-- Add political events
for _, event in ipairs(PoliticalEvents) do
	table.insert(EventLibrary.Events, event)
end

-- Add criminal events
for _, event in ipairs(CriminalEvents) do
	table.insert(EventLibrary.Events, event)
end

-- Export helpers for other modules
EventLibrary.randomFullName = randomFullName
EventLibrary.randomCity = randomCity
EventLibrary.randomCompany = randomCompany
EventLibrary.randomCountry = randomCountry

return EventLibrary
