-- career_tech.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- TECH CAREER EVENTS - Software Development, Cybersecurity, Game Dev, Data Science
-- ═══════════════════════════════════════════════════════════════════════════════
-- 
-- Contains events for:
-- - Software Developer path
-- - Cybersecurity / Security Analyst path (with ethical/gray hat branches)
-- - Game Developer path
-- - Data Scientist path
-- - General tech industry events
--
-- ═══════════════════════════════════════════════════════════════════════════════

local events = {}

-- ═══════════════════════════════════════════════════════════════
-- ORIGIN / DISCOVERY EVENTS (What sparks interest in tech)
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "tech_first_coding_project",
	emoji = "💻",
	title = "First Lines of Code",
	category = "tech",
	tags = {"career", "tech", "origin", "software_developer"},
	
	weight = 12,
	cooldownYears = 99,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	chainId = "software_dev_origin",
	chainStep = 1,
	
	conditions = {
		minAge = 12,
		maxAge = 25,
		blockedFlags = {"career_software_developer_started", "career_tech_rejected"},
		minStats = {Smarts = 30},
	},
	
	getDynamicData = function(state)
		local projects = {"a simple calculator", "a guessing game", "a to-do list app", "a text adventure", "a basic website"}
		return {
			project = projects[math.random(#projects)]
		}
	end,
	
	text = "You spend a weekend following online tutorials and manage to build %project%. It actually works! The feeling of making something from nothing is incredible.",
	
	choices = {
		{
			id = "keep_learning",
			text = "This is amazing! I want to learn more.",
			resultText = "You dive deeper into programming, spending hours watching tutorials and building small projects.",
			effects = {Smarts = 3, Happiness = 4},
			flags = {set = {"tech_interested", "coding_hobby"}},
			careerXP = 5,
		},
		{
			id = "cool_but_hard",
			text = "It's cool, but also really hard...",
			resultText = "You bookmark some resources for later. Maybe you'll come back to it someday.",
			effects = {Smarts = 1},
			flags = {set = {"tech_curious"}},
		},
		{
			id = "not_for_me",
			text = "This isn't for me. Too much typing.",
			resultText = "You close the laptop and do something else. Code isn't your thing.",
			effects = {Happiness = 1},
			flags = {set = {"career_tech_rejected"}},
		},
	},
})

table.insert(events, {
	id = "security_interest_sparked",
	emoji = "🔐",
	title = "The Security Rabbit Hole",
	category = "tech",
	tags = {"career", "tech", "origin", "cybersecurity"},
	
	weight = 10,
	cooldownYears = 99,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	chainId = "security_origin",
	chainStep = 1,
	
	conditions = {
		minAge = 14,
		maxAge = 28,
		blockedFlags = {"career_cybersecurity_started", "security_rejected"},
		minStats = {Smarts = 35},
		requiredAnyFlags = {"tech_interested", "coding_hobby", "tech_curious"},
	},
	
	text = "You stumble across a video about how websites get compromised. The techniques are fascinating - like digital lockpicking. You realize security is basically a puzzle where the stakes are real.",
	
	choices = {
		{
			id = "deep_dive",
			text = "This is exactly what I want to do!",
			resultText = "You spend weeks learning about networks, encryption, and how systems can be protected - or broken.",
			effects = {Smarts = 4, Happiness = 3},
			flags = {set = {"security_interested", "security_hobby"}},
			careerXP = 10,
		},
		{
			id = "interesting_scary",
			text = "Interesting, but also kind of scary.",
			resultText = "You learn the basics of staying safe online but don't go too deep.",
			effects = {Smarts = 2},
			flags = {set = {"security_aware"}},
		},
	},
})

table.insert(events, {
	id = "first_game_project",
	emoji = "🎮",
	title = "Your First Game",
	category = "tech",
	tags = {"career", "tech", "origin", "game_developer"},
	
	weight = 12,
	cooldownYears = 99,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	chainId = "game_dev_origin",
	chainStep = 1,
	
	conditions = {
		minAge = 10,
		maxAge = 25,
		blockedFlags = {"career_game_developer_started", "game_dev_rejected"},
	},
	
	getDynamicData = function(state)
		local engines = {"a block-based coding tool", "a simple game engine", "Roblox Studio", "a visual programming app"}
		return {
			engine = engines[math.random(#engines)]
		}
	end,
	
	text = "Using %engine%, you create your first playable game - a simple platformer where a square jumps over obstacles. When you show your friend and they actually have fun playing it, something clicks.",
	
	choices = {
		{
			id = "this_is_it",
			text = "I want to make games for a living!",
			resultText = "You start planning bigger projects and learning proper game development.",
			effects = {Happiness = 5, Smarts = 2},
			flags = {set = {"game_dev_passionate", "game_dev_hobby"}},
			careerXP = 10,
		},
		{
			id = "fun_hobby",
			text = "This is a fun hobby.",
			resultText = "You keep making small games on the side when you have time.",
			effects = {Happiness = 3},
			flags = {set = {"game_dev_hobby"}},
		},
		{
			id = "too_much_work",
			text = "It's cool, but games are too hard to make.",
			resultText = "You decide to just play games instead of making them.",
			effects = {Happiness = 1},
			flags = {set = {"game_dev_rejected"}},
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- SOFTWARE DEVELOPER CAREER EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "software_dev_internship",
	emoji = "🏢",
	title = "Tech Internship Offer",
	category = "work",
	tags = {"career", "tech", "software_developer", "job_offer"},
	
	weight = 15,
	cooldownYears = 3,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	chainId = "software_dev_career",
	chainStep = 1,
	
	conditions = {
		minAge = 18,
		maxAge = 26,
		requiredAnyFlags = {"tech_interested", "coding_hobby", "cs_degree"},
		blockedFlags = {"career_software_developer"},
		requiredEducation = "high_school",
	},
	
	getDynamicData = function(state)
		local companies = {"TechStart Inc", "CodeCraft Labs", "Digital Dynamics", "ByteWave Solutions", "InnovateTech"}
		return {
			company = companies[math.random(#companies)],
			salary = math.random(40, 60) * 1000,
		}
	end,
	
	text = "%company% sees your GitHub projects and offers you a summer internship. The pay is $%salary% for three months, and they hint it could become full-time.",
	
	choices = {
		{
			id = "accept_internship",
			text = "Accept the internship!",
			resultText = "You spend the summer learning from senior developers and shipping real code.",
			effects = {Money = 15000, Smarts = 5, Happiness = 4},
			flags = {set = {"tech_internship_done", "career_software_developer_started"}},
			startCareer = "software_developer",
			careerXP = 20,
		},
		{
			id = "negotiate",
			text = "Try to negotiate for more money.",
			resultText = "They bump the offer up slightly. You accept and learn a ton.",
			effects = {Money = 18000, Smarts = 4, Happiness = 3},
			flags = {set = {"tech_internship_done", "career_software_developer_started", "good_negotiator"}},
			startCareer = "software_developer",
			careerXP = 15,
		},
		{
			id = "decline",
			text = "Decline - I have other plans.",
			resultText = "You turn down the offer to focus on other things.",
			effects = {Happiness = -1},
			flags = {set = {}},
		},
	},
})

table.insert(events, {
	id = "software_dev_first_job",
	emoji = "💼",
	title = "Junior Developer Position",
	category = "work",
	tags = {"career", "tech", "software_developer", "tech_junior"},
	
	weight = 15,
	cooldownYears = 99,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	chainId = "software_dev_career",
	chainStep = 2,
	
	conditions = {
		minAge = 20,
		maxAge = 35,
		requiredAnyFlags = {"tech_internship_done", "cs_degree", "coding_portfolio"},
		blockedFlags = {"software_dev_employed"},
		requiredCareerId = "software_developer",
		requiredCareerMinTier = 1,
	},
	
	getDynamicData = function(state)
		local companies = {"Nexus Technologies", "CloudByte Systems", "Fusion Software", "Apex Digital", "Quantum Code"}
		return {
			company = companies[math.random(#companies)],
			salary = math.random(60, 85) * 1000,
		}
	end,
	
	text = "After a grueling interview process with coding challenges and system design questions, %company% offers you a junior developer position at $%salary% per year.",
	
	choices = {
		{
			id = "accept_job",
			text = "Accept the position!",
			resultText = "You join the team and start contributing to real products used by thousands.",
			effects = {Money = 5000, Happiness = 5},
			flags = {set = {"software_dev_employed", "has_tech_job"}},
			careerXP = 30,
		},
		{
			id = "keep_looking",
			text = "Keep interviewing for better offers.",
			resultText = "You continue the job hunt, hoping for a better opportunity.",
			effects = {Happiness = -2},
			flags = {set = {"job_hunting"}},
		},
	},
})

table.insert(events, {
	id = "software_dev_code_review_drama",
	emoji = "🔍",
	title = "The Code Review",
	category = "work",
	tags = {"career", "tech", "software_developer", "tech_junior"},
	
	weight = 12,
	cooldownYears = 2,
	oneTime = false,
	
	conditions = {
		minAge = 20,
		maxAge = 60,
		requiredCareerId = "software_developer",
		requiredCareerMinTier = 1,
		requiredAllFlags = {"software_dev_employed"},
	},
	
	text = "A senior developer absolutely tears apart your pull request in the code review. Some feedback is valid, but the tone is harsh and public.",
	
	choices = {
		{
			id = "take_feedback",
			text = "Accept the feedback gracefully and improve.",
			resultText = "You fix every issue and learn a lot. The senior dev notices your growth.",
			effects = {Smarts = 3, Happiness = -1},
			flags = {set = {"takes_feedback_well"}},
			careerXP = 15,
			careerReputation = 5,
		},
		{
			id = "push_back",
			text = "Defend your code choices professionally.",
			resultText = "You explain your reasoning. Some points stand, others don't. It's a learning moment for both.",
			effects = {Smarts = 2},
			flags = {set = {"confident_developer"}},
			careerXP = 10,
		},
		{
			id = "escalate",
			text = "Complain to your manager about the harsh tone.",
			resultText = "Your manager talks to the senior dev. Things get awkward for a while.",
			effects = {Happiness = -2},
			flags = {set = {"escalated_conflict"}},
			careerReputation = -5,
		},
	},
})

table.insert(events, {
	id = "software_dev_promotion",
	emoji = "📈",
	title = "Promotion Discussion",
	category = "work",
	tags = {"career", "tech", "software_developer", "tech_mid"},
	
	weight = 10,
	cooldownYears = 3,
	oneTime = false,
	milestone = false, -- Career events should NOT be milestones
	
	conditions = {
		minAge = 23,
		maxAge = 50,
		requiredCareerId = "software_developer",
		requiredCareerMinTier = 1,
		requiredAllFlags = {"software_dev_employed"},
	},
	
	getDynamicData = function(state)
		return {
			raisePercent = math.random(15, 25),
		}
	end,
	
	text = "Your manager pulls you into a meeting. Based on your performance, they're recommending you for promotion to mid-level developer with a %raisePercent%% raise.",
	
	choices = {
		{
			id = "accept_promotion",
			text = "Accept and thank them!",
			resultText = "You're officially a mid-level developer with new responsibilities and better pay.",
			effects = {Happiness = 6, Money = 10000},
			flags = {set = {"promoted_once"}},
			promoteCareer = true,
			careerXP = 25,
		},
		{
			id = "negotiate_more",
			text = "Push for a bigger raise.",
			resultText = "After some back and forth, they meet you in the middle with a slightly better package.",
			effects = {Happiness = 5, Money = 15000},
			flags = {set = {"promoted_once", "good_negotiator"}},
			promoteCareer = true,
			careerXP = 20,
		},
	},
})

table.insert(events, {
	id = "software_dev_burnout",
	emoji = "😵",
	title = "Tech Burnout",
	category = "health",
	tags = {"career", "tech", "software_developer", "burnout"},
	
	weight = 8,
	cooldownYears = 3,
	oneTime = false,
	
	conditions = {
		minAge = 22,
		maxAge = 60,
		requiredCareerId = "software_developer",
		requiredCareerMinTier = 1,
		maxStats = {Happiness = 40},
	},
	
	text = "The constant pressure to ship features, the endless meetings, the on-call rotations... you're exhausted. You stare at code and nothing makes sense anymore.",
	
	choices = {
		{
			id = "take_pto",
			text = "Take some PTO and disconnect completely.",
			resultText = "You turn off Slack, leave your laptop at home, and actually relax for once.",
			effects = {Health = 5, Happiness = 8, Money = -1000},
			flags = {set = {"took_mental_health_break"}},
		},
		{
			id = "push_through",
			text = "Push through it. Deadlines don't care about feelings.",
			resultText = "You keep going, but you can feel it taking a toll on you.",
			effects = {Health = -5, Happiness = -3, Smarts = -2},
			flags = {set = {"burnout_ignored"}},
			careerXP = 10,
		},
		{
			id = "quit_job",
			text = "Quit and take time off between jobs.",
			resultText = "You hand in your notice and spend some time rediscovering why you loved coding in the first place.",
			effects = {Health = 10, Happiness = 5},
			quitCareer = true,
			flags = {set = {"quit_for_health"}},
		},
	},
})

table.insert(events, {
	id = "software_dev_big_tech_offer",
	emoji = "🌟",
	title = "Big Tech Opportunity",
	category = "work",
	tags = {"career", "tech", "software_developer", "tech_senior"},
	
	weight = 6,
	cooldownYears = 5,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	conditions = {
		minAge = 25,
		maxAge = 45,
		requiredCareerId = "software_developer",
		requiredCareerMinTier = 2,
		minStats = {Smarts = 60},
	},
	
	getDynamicData = function(state)
		local companies = {"Nexus Corp", "TitanTech", "Apex Industries", "GlobalCode", "OmniSoft"}
		return {
			company = companies[math.random(#companies)],
			salary = math.random(150, 250) * 1000,
		}
	end,
	
	text = "A recruiter from %company% reaches out. After a tough interview process, they offer you a senior position at $%salary% with stock options and amazing benefits.",
	
	choices = {
		{
			id = "accept_big_tech",
			text = "Accept the life-changing offer!",
			resultText = "You join one of the biggest tech companies in the world. The work is challenging but the rewards are immense.",
			effects = {Money = 50000, Happiness = 6},
			flags = {set = {"big_tech_employee", "senior_developer"}},
			promoteCareer = true,
			careerXP = 50,
			careerReputation = 20,
		},
		{
			id = "decline_stay",
			text = "Decline - I like my current company.",
			resultText = "You stay where you're comfortable, valuing work-life balance over prestige.",
			effects = {Happiness = 2},
			flags = {set = {"chose_comfort"}},
			careerReputation = 5,
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- CYBERSECURITY CAREER EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "security_first_bug_bounty",
	emoji = "🐛",
	title = "Your First Bug Bounty",
	category = "tech",
	tags = {"career", "cybersecurity", "bug_bounty", "security_basics"},
	
	weight = 10,
	cooldownYears = 99,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	chainId = "security_career",
	chainStep = 1,
	
	conditions = {
		minAge = 16,
		maxAge = 35,
		requiredAnyFlags = {"security_interested", "security_hobby"},
		minStats = {Smarts = 40},
	},
	
	getDynamicData = function(state)
		local companies = {"StreamFlix", "CloudBank", "SocialHub", "GameVault", "ShopMart"}
		return {
			company = companies[math.random(#companies)],
			bounty = math.random(5, 15) * 100,
		}
	end,
	
	text = "While testing %company%'s website (legally, through their bug bounty program), you find a vulnerability that could expose user emails. They award you $%bounty% for the find!",
	
	choices = {
		{
			id = "report_professionally",
			text = "Write a detailed report and suggest fixes.",
			resultText = "Your professional report impresses them. They thank you publicly and invite you to test more.",
			effects = {Money = 800, Smarts = 4, Happiness = 5},
			flags = {set = {"bug_bounty_hunter", "security_professional"}},
			startCareer = "cybersecurity",
			careerXP = 25,
		},
		{
			id = "just_claim_bounty",
			text = "Submit the minimum info needed for the bounty.",
			resultText = "You get paid, but the report is mediocre. It's money in your pocket though.",
			effects = {Money = 500, Smarts = 2, Happiness = 3},
			flags = {set = {"bug_bounty_hunter"}},
			startCareer = "cybersecurity",
			careerXP = 15,
		},
	},
})

table.insert(events, {
	id = "security_ethical_choice",
	emoji = "⚖️",
	title = "The Ethical Line",
	category = "tech",
	tags = {"career", "cybersecurity", "morality", "branch_choice"},
	
	weight = 100,
	cooldownYears = 99,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	chainId = "security_branch",
	chainStep = 1,
	
	conditions = {
		minAge = 18,
		maxAge = 35,
		requiredCareerId = "cybersecurity",
		requiredCareerMinTier = 1,
		blockedFlags = {"security_branch_chosen"},
	},
	
	text = "You discover a major vulnerability in a company that doesn't have a bug bounty program. You could report it responsibly and get nothing, sell the info to the highest bidder, or just ignore it.",
	
	choices = {
		{
			id = "ethical_report",
			text = "Report it responsibly anyway.",
			resultText = "You do the right thing. The company thanks you privately and offers you a consulting gig.",
			effects = {Karma = 8, Money = 2000, Happiness = 3},
			flags = {set = {"security_branch_chosen", "cybersecurity_ethical"}},
			careerBranch = "ethical",
			careerXP = 30,
			careerReputation = 15,
		},
		{
			id = "gray_area",
			text = "Reach out to them first, then negotiate payment.",
			resultText = "It's a gray area, but you manage to get paid for your work without crossing legal lines.",
			effects = {Karma = -2, Money = 8000, Happiness = 2},
			flags = {set = {"security_branch_chosen", "cybersecurity_gray"}},
			careerBranch = "gray_hat",
			careerXP = 20,
		},
		{
			id = "ignore",
			text = "Not my problem. Ignore it.",
			resultText = "You move on. Someone else will probably find it eventually.",
			effects = {Karma = -1},
			flags = {set = {"security_branch_chosen"}},
		},
	},
})

table.insert(events, {
	id = "security_job_offer",
	emoji = "🛡️",
	title = "Security Analyst Position",
	category = "work",
	tags = {"career", "cybersecurity", "job_offer", "security_analyst"},
	
	weight = 12,
	cooldownYears = 99,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	chainId = "security_career",
	chainStep = 2,
	
	conditions = {
		minAge = 20,
		maxAge = 40,
		requiredCareerId = "cybersecurity",
		requiredCareerMinTier = 1,
		requiredAllFlags = {"cybersecurity_ethical"},
	},
	
	getDynamicData = function(state)
		local companies = {"SecureNet Corp", "CyberShield Inc", "Guardian Systems", "Fortress Digital", "SafeHaven Tech"}
		return {
			company = companies[math.random(#companies)],
			salary = math.random(70, 100) * 1000,
		}
	end,
	
	text = "Based on your bug bounty reputation, %company% offers you a full-time security analyst position at $%salary% per year. You'd be doing penetration testing and vulnerability assessments.",
	
	choices = {
		{
			id = "accept_security_job",
			text = "Accept the position!",
			resultText = "You become a professional ethical hacker, getting paid to find vulnerabilities legally.",
			effects = {Money = 5000, Happiness = 5},
			flags = {set = {"security_employed", "pentester"}},
			promoteCareer = true,
			careerXP = 35,
		},
		{
			id = "stay_freelance",
			text = "Stay freelance and independent.",
			resultText = "You prefer the freedom of bug bounties and consulting over a 9-to-5.",
			effects = {Happiness = 2},
			flags = {set = {"security_freelancer"}},
			careerXP = 15,
		},
	},
})

table.insert(events, {
	id = "security_major_discovery",
	emoji = "🔓",
	title = "Critical Vulnerability Discovery",
	category = "tech",
	tags = {"career", "cybersecurity", "pentester", "ethical_hacking"},
	
	weight = 8,
	cooldownYears = 4,
	oneTime = false,
	milestone = false, -- Career events should NOT be milestones
	
	conditions = {
		minAge = 22,
		maxAge = 60,
		requiredCareerId = "cybersecurity",
		requiredCareerMinTier = 2,
		requiredAllFlags = {"security_employed"},
	},
	
	getDynamicData = function(state)
		local targets = {"a major bank's mobile app", "a healthcare provider's database", "a government contractor's system", "a Fortune 500 company's cloud"}
		return {
			target = targets[math.random(#targets)],
			bounty = math.random(20, 75) * 1000,
		}
	end,
	
	text = "During an authorized penetration test, you discover a critical vulnerability in %target% that could have affected millions of users. The client is shocked but grateful.",
	
	choices = {
		{
			id = "detailed_report",
			text = "Document everything and help them fix it.",
			resultText = "Your thorough work prevents a potential disaster. They pay a bonus of $%bounty% and give you a glowing recommendation.",
			effects = {Money = 25000, Happiness = 6, Smarts = 3},
			flags = {set = {"security_hero"}},
			careerXP = 40,
			careerReputation = 25,
		},
		{
			id = "quick_fix",
			text = "Point out the issue and move on.",
			resultText = "You report the basics and let them handle the rest. Job done.",
			effects = {Money = 5000, Happiness = 2},
			careerXP = 15,
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- GAME DEVELOPER CAREER EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "game_dev_first_release",
	emoji = "🎮",
	title = "Your Game Goes Live",
	category = "tech",
	tags = {"career", "game_developer", "indie_game"},
	
	weight = 15,
	cooldownYears = 99,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	chainId = "game_dev_career",
	chainStep = 1,
	
	conditions = {
		minAge = 14,
		maxAge = 40,
		requiredAnyFlags = {"game_dev_hobby", "game_dev_passionate"},
	},
	
	getDynamicData = function(state)
		local genres = {"puzzle game", "platformer", "RPG", "survival game", "simulation"}
		return {
			genre = genres[math.random(#genres)],
			downloads = math.random(100, 5000),
		}
	end,
	
	text = "After months of work, you finally release your %genre% to the public. Within the first week, %downloads% people download it. Some even leave positive reviews!",
	
	choices = {
		{
			id = "celebrate_and_continue",
			text = "This is incredible! Start planning the next game.",
			resultText = "The validation pushes you to keep creating. You start sketching ideas for a bigger project.",
			effects = {Happiness = 7, Smarts = 2},
			flags = {set = {"published_game", "career_game_developer_started"}},
			startCareer = "game_developer",
			careerXP = 30,
		},
		{
			id = "monetize",
			text = "Try to monetize with ads or in-app purchases.",
			resultText = "You add some monetization. It's not much, but every dollar counts.",
			effects = {Money = 500, Happiness = 4},
			flags = {set = {"published_game", "career_game_developer_started", "monetized_game"}},
			startCareer = "game_developer",
			careerXP = 25,
		},
	},
})

table.insert(events, {
	id = "game_dev_viral_moment",
	emoji = "📈",
	title = "Your Game Goes Viral",
	category = "tech",
	tags = {"career", "game_developer", "indie_game", "viral"},
	
	weight = 5,
	cooldownYears = 99,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	chainId = "game_dev_career",
	chainStep = 2,
	
	conditions = {
		minAge = 15,
		maxAge = 50,
		requiredCareerId = "game_developer",
		requiredCareerMinTier = 1,
		requiredAllFlags = {"published_game"},
	},
	
	getDynamicData = function(state)
		local influencers = {"a popular streamer", "a famous YouTuber", "a gaming journalist", "a celebrity"}
		return {
			influencer = influencers[math.random(#influencers)],
			downloads = math.random(100, 500) * 1000,
		}
	end,
	
	text = "%influencer% plays your game on stream and loves it. Suddenly, your download count explodes to %downloads%! Your inbox is flooded with messages.",
	
	choices = {
		{
			id = "embrace_fame",
			text = "Ride the wave and engage with the community!",
			resultText = "You become a known indie developer. Publishers and studios start reaching out.",
			effects = {Money = 50000, Happiness = 8},
			flags = {set = {"game_dev_famous", "indie_success"}},
			careerXP = 60,
			careerReputation = 30,
		},
		{
			id = "stay_quiet",
			text = "Stay focused on making the game better.",
			resultText = "You use the attention to fund updates and polish. The game gets even better.",
			effects = {Money = 30000, Happiness = 5, Smarts = 3},
			flags = {set = {"game_dev_dedicated"}},
			careerXP = 40,
		},
	},
})

table.insert(events, {
	id = "game_dev_studio_offer",
	emoji = "🏢",
	title = "Studio Job Offer",
	category = "work",
	tags = {"career", "game_developer", "game_studio_junior", "job_offer"},
	
	weight = 10,
	cooldownYears = 99,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	conditions = {
		minAge = 18,
		maxAge = 40,
		requiredCareerId = "game_developer",
		requiredCareerMinTier = 1,
		requiredAllFlags = {"published_game"},
	},
	
	getDynamicData = function(state)
		local studios = {"Pixel Forge Studios", "Neon Games", "Thunderbolt Entertainment", "Starlight Interactive", "Iron Crown Games"}
		return {
			studio = studios[math.random(#studios)],
			salary = math.random(55, 80) * 1000,
		}
	end,
	
	text = "%studio% sees your work and offers you a junior game programmer position at $%salary% per year. You'd be working on actual AAA games!",
	
	choices = {
		{
			id = "join_studio",
			text = "Join the studio and go pro!",
			resultText = "You become part of a real game development team. The crunch is real, but so is the experience.",
			effects = {Money = 10000, Happiness = 5},
			flags = {set = {"studio_employee", "game_dev_professional"}},
			promoteCareer = true,
			careerXP = 35,
		},
		{
			id = "stay_indie",
			text = "Stay independent. I want creative freedom.",
			resultText = "You turn down the stability for the freedom to make your own games.",
			effects = {Happiness = 3},
			flags = {set = {"indie_for_life"}},
			careerXP = 10,
		},
	},
})

table.insert(events, {
	id = "game_dev_crunch",
	emoji = "😰",
	title = "Crunch Time",
	category = "work",
	tags = {"career", "game_developer", "crunch", "game_programming"},
	
	weight = 12,
	cooldownYears = 2,
	oneTime = false,
	
	conditions = {
		minAge = 18,
		maxAge = 60,
		requiredCareerId = "game_developer",
		requiredCareerMinTier = 2,
		requiredAllFlags = {"studio_employee"},
	},
	
	text = "The game's deadline is in two weeks and the studio declares mandatory crunch. 12-hour days, weekends included. Management promises bonuses.",
	
	choices = {
		{
			id = "embrace_crunch",
			text = "Buckle down and crunch hard.",
			resultText = "You survive the crunch and the game ships on time. You're exhausted but proud.",
			effects = {Health = -8, Happiness = -4, Money = 5000},
			flags = {set = {"survived_crunch"}},
			careerXP = 20,
		},
		{
			id = "healthy_boundaries",
			text = "Set boundaries and work reasonable hours.",
			resultText = "Some coworkers resent you, but you keep your sanity intact.",
			effects = {Health = 2, Happiness = 2},
			flags = {set = {"healthy_boundaries"}},
			careerReputation = -5,
		},
		{
			id = "quit_during_crunch",
			text = "This is toxic. I quit.",
			resultText = "You walk out mid-crunch. It burns bridges but you don't regret it.",
			effects = {Health = 5, Happiness = 3},
			quitCareer = true,
			flags = {set = {"quit_crunch"}},
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- GENERAL TECH EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "tech_conference",
	emoji = "🎤",
	title = "Tech Conference Opportunity",
	category = "work",
	tags = {"career", "tech", "networking"},
	
	weight = 10,
	cooldownYears = 2,
	oneTime = false,
	
	conditions = {
		minAge = 20,
		maxAge = 60,
		requiredAnyFlags = {"has_tech_job", "software_dev_employed", "security_employed", "studio_employee"},
	},
	
	getDynamicData = function(state)
		local conferences = {"TechCrunch Disrupt", "DevCon", "CodeFest", "HackSummit", "InnovateCon"}
		return {
			conference = conferences[math.random(#conferences)],
		}
	end,
	
	text = "Your company offers to send you to %conference%, an industry conference. It's a chance to learn and network with tech leaders.",
	
	choices = {
		{
			id = "attend_actively",
			text = "Go and network like crazy.",
			resultText = "You meet interesting people and come back with new ideas and connections.",
			effects = {Smarts = 3, Happiness = 2},
			flags = {set = {"conference_networker"}},
			careerXP = 15,
			careerReputation = 10,
		},
		{
			id = "attend_casually",
			text = "Go but mostly enjoy the free food and swag.",
			resultText = "You pick up a few things and get some nice t-shirts.",
			effects = {Happiness = 2},
			careerXP = 5,
		},
		{
			id = "skip_it",
			text = "Skip it. Conferences are overwhelming.",
			resultText = "You stay home and enjoy the quiet office while everyone else is gone.",
			effects = {Happiness = 1},
			flags = {set = {}},
		},
	},
})

table.insert(events, {
	id = "tech_layoffs",
	emoji = "📉",
	title = "Company Layoffs",
	category = "work",
	tags = {"career", "tech", "layoffs"},
	
	weight = 6,
	cooldownYears = 4,
	oneTime = false,
	
	conditions = {
		minAge = 20,
		maxAge = 65,
		requiredAnyFlags = {"has_tech_job", "software_dev_employed", "security_employed", "studio_employee"},
	},
	
	text = "The economy takes a hit and your company announces layoffs. You watch coworkers get let go. You're called into HR's office...",
	
	choices = {
		{
			id = "survived",
			text = "(You survived the cut)",
			resultText = "They tell you you're safe... for now. The office feels empty and morale is low.",
			effects = {Happiness = -3},
			flags = {set = {"survived_layoffs"}},
		},
		{
			id = "laid_off",
			text = "(You got laid off)",
			resultText = "They hand you a severance package and thank you for your service. You're out.",
			effects = {Happiness = -6, Money = 15000},
			quitCareer = true,
			flags = {set = {"got_laid_off"}},
		},
	},
})

table.insert(events, {
	id = "tech_startup_opportunity",
	emoji = "🚀",
	title = "Join a Startup?",
	category = "work",
	tags = {"career", "tech", "startup"},
	
	weight = 8,
	cooldownYears = 5,
	oneTime = false,
	
	conditions = {
		minAge = 22,
		maxAge = 45,
		requiredAnyFlags = {"has_tech_job", "software_dev_employed", "security_employed"},
	},
	
	getDynamicData = function(state)
		local startups = {"FluxAI", "QuantumLeap", "NexGen Labs", "Horizon Ventures", "Catalyst Tech"}
		return {
			startup = startups[math.random(#startups)],
			equity = math.random(1, 3) / 10,
		}
	end,
	
	text = "A friend's startup %startup% is growing fast and they want you to join as an early employee. Lower salary, but %equity%% equity. If they make it big...",
	
	choices = {
		{
			id = "take_the_risk",
			text = "Take the risk! Join the startup.",
			resultText = "You jump into the chaos of startup life. Long hours, but the energy is electric.",
			effects = {Money = -10000, Happiness = 3},
			flags = {set = {"startup_employee", "equity_holder"}},
			careerXP = 25,
		},
		{
			id = "stay_stable",
			text = "Stay at your stable job.",
			resultText = "You wish them luck but prefer your predictable paycheck.",
			effects = {Happiness = 1},
			flags = {set = {}},
		},
	},
})

table.insert(events, {
	id = "tech_side_project_success",
	emoji = "💡",
	title = "Side Project Takes Off",
	category = "tech",
	tags = {"career", "tech", "entrepreneurship"},
	
	weight = 6,
	cooldownYears = 5,
	oneTime = false,
	
	conditions = {
		minAge = 18,
		maxAge = 55,
		requiredAnyFlags = {"tech_interested", "coding_hobby", "has_tech_job"},
		minStats = {Smarts = 45},
	},
	
	getDynamicData = function(state)
		local projects = {"a productivity tool", "an automation script", "a browser extension", "a developer utility", "an open source library"}
		return {
			project = projects[math.random(#projects)],
			users = math.random(5, 50) * 100,
		}
	end,
	
	text = "A side project you built - %project% - suddenly gets noticed. It now has %users% active users and people are asking if they can pay for premium features.",
	
	choices = {
		{
			id = "monetize_it",
			text = "Add a paid tier and see what happens.",
			resultText = "Some users upgrade to paid plans. You're making passive income!",
			effects = {Money = 5000, Happiness = 5},
			flags = {set = {"side_project_income", "indie_entrepreneur"}},
		},
		{
			id = "keep_free",
			text = "Keep it free and open source.",
			resultText = "The community loves you for it. Your GitHub stars grow.",
			effects = {Happiness = 3, Karma = 3},
			flags = {set = {"open_source_maintainer"}},
			careerReputation = 10,
		},
		{
			id = "sell_it",
			text = "Look for someone to acquire it.",
			resultText = "A small company buys your project outright. Quick cash!",
			effects = {Money = 20000, Happiness = 3},
			flags = {set = {"sold_project"}},
		},
	},
})

return {events = events}
