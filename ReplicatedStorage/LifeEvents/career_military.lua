-- LifeEvents/career_military.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- MILITARY & SERVICE CAREER EVENTS
-- BitLife-style: Player picks ACTIONS, game decides OUTCOMES
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent.init)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- ENLISTMENT / JOINING
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "mil_recruiter_visit",
		minAge = 16, maxAge = 18,
		weight = 25, oneTime = true,
		emoji = "🎖️", title = "Military Recruiter at School!",
		category = "school",
		getDynamicData = function()
			local branches = {"Army", "Navy", "Air Force", "Marines"}
			return { branch = branches[math.random(#branches)] }
		end,
		text = "A %branch% recruiter is at your school. They're talking about benefits, college tuition, service. What do you think?",
		choices = {
			{ text = "🎖️ Sign up immediately", effects = { Happiness = 15, Health = 5 }, resultText = "You're committed! Shipping to boot camp after graduation!", setFlags = {"enlisted", "military_bound"} },
			{ text = "📋 Take the info home", effects = { Happiness = 5, Smarts = 3 }, resultText = "Something to consider. Might be the path for you.", setFlag = "military_curious" },
			{ text = "🎓 College first, maybe ROTC", effects = { Happiness = 8, Smarts = 5 }, resultText = "Officer path could be better. Keeping options open.", setFlag = "rotc_interested" },
			{ text = "🙅 Not interested", effects = { Happiness = 3 }, resultText = "Military life isn't for everyone. Respect but no thanks." },
		},
	},
	
	{
		id = "mil_enlistment_decision",
		minAge = 18, maxAge = 24,
		weight = 20, oneTime = true,
		emoji = "🇺🇸", title = "Enlisting!",
		category = "work",
		requiresFlag = "military_curious",
		getDynamicData = function()
			local branches = {"Army", "Navy", "Air Force", "Marines", "Coast Guard"}
			return { branch = branches[math.random(#branches)] }
		end,
		text = "Ready to serve your country in the %branch%! This is a big commitment. Final decision?",
		choices = {
			{ text = "🎖️ Enlist as enlisted", effects = { Happiness = 15, Money = 20000, Health = 8 }, resultText = "You're in! Shipping to basic training! New chapter begins!", setFlags = {"enlisted", "service_member"} },
			{ text = "🎓 Go officer route instead", effects = { Happiness = 12, Smarts = 8, Money = -40000 }, resultText = "OCS/Academy route. More school but you'll be an officer!", setFlags = {"officer_candidate", "service_member"} },
			{ text = "🔧 Pick a technical MOS", effects = { Happiness = 13, Smarts = 10 }, resultText = "Signed up for a skill! Will learn computers/mechanics/etc!", setFlags = {"enlisted", "service_member", "technical_mos"} },
			{ text = "😰 Back out last minute", effects = { Happiness = -10 }, resultText = "Changed your mind at the recruiter's office. Respect but regret?" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- BASIC TRAINING
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "mil_boot_camp",
		minAge = 18, maxAge = 28,
		weight = 25, oneTime = true,
		emoji = "💪", title = "Boot Camp Begins!",
		category = "work",
		requiresFlag = "enlisted",
		text = "First day of basic training! Drill instructor screaming! Everything is hard! How do you handle it?",
		choices = {
			{ text = "💪 Embrace the suck", effects = { Happiness = 15, Health = 20, Smarts = 5 }, resultText = "What doesn't kill you makes you stronger! Thriving!", setFlags = {"boot_camp_star", "tough"} },
			{ text = "🤝 Help struggling recruits", effects = { Happiness = 12, Health = 15, Smarts = 3 }, resultText = "Leadership noticed! Team player! Made friends for life!", setFlags = {"boot_camp_survivor", "natural_leader"} },
			{ text = "😤 Just survive", effects = { Happiness = 5, Health = 10 }, resultText = "Counting down the days. Made it through. Barely.", setFlag = "boot_camp_survivor" },
			{ text = "💔 Wash out", effects = { Happiness = -20, Health = -5 }, resultText = "Couldn't handle it. Medical/behavioral discharge. Dream over.", clearFlags = {"enlisted", "service_member"} },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- DEPLOYMENT
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "mil_deployment_orders",
		minAge = 19, maxAge = 45,
		weight = 20, oneTime = true,
		emoji = "🌍", title = "Deployment Orders!",
		category = "work",
		requiresFlag = "boot_camp_survivor",
		getDynamicData = function()
			local locations = {"Middle East", "Europe", "Pacific", "Africa"}
			return { location = locations[math.random(#locations)] }
		end,
		text = "You're deploying to %location%! First real deployment! Months away from home. How do you prepare?",
		choices = {
			{ text = "🎖️ Ready to serve", effects = { Happiness = 15, Smarts = 5 }, resultText = "This is what you trained for! Shipping out with pride!", setFlags = {"deployed", "combat_veteran"} },
			{ text = "👨‍👩‍👧 Worry about family", effects = { Happiness = -5, Health = -3 }, resultText = "Hard to leave loved ones. But duty calls. Deployed with heavy heart.", setFlags = {"deployed", "family_concern"} },
			{ text = "📝 Get affairs in order", effects = { Happiness = 8, Smarts = 8 }, resultText = "Will updated. Letters written. Prepared for anything.", setFlags = {"deployed", "prepared"} },
			{ text = "😰 Request deferment", effects = { Happiness = -10, Smarts = -5 }, resultText = "Denied. You're going. Marked as reluctant. Not a good look." },
		},
	},
	
	{
		id = "mil_combat_situation",
		minAge = 19, maxAge = 50,
		weight = 15, cooldown = 3,
		emoji = "⚔️", title = "Combat Situation!",
		category = "work",
		requiresFlag = "deployed",
		text = "Under fire! Bullets flying! Chaos everywhere! Training kicks in. What do you do?",
		choices = {
			{ text = "🦸 Heroic action", effects = { Happiness = 20, Health = -10 }, resultText = "Risked your life to save squadmates! Recommended for medal!", setFlags = {"combat_hero", "decorated"} },
			{ text = "🎯 Execute training", effects = { Happiness = 10, Health = -5, Smarts = 5 }, resultText = "Did your job. Stayed calm. Everyone made it. Professional.", setFlag = "proven_soldier" },
			{ text = "😰 Freeze up", effects = { Happiness = -15, Health = -8 }, resultText = "Couldn't move. Someone else had to cover you. Trauma. Survivors guilt." },
			{ text = "🤕 Get wounded", effects = { Happiness = -10, Health = -25 }, resultText = "Hit! Medevac'd out. Purple Heart coming. Long recovery.", setFlags = {"wounded_veteran", "purple_heart"} },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- CAREER ADVANCEMENT
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "mil_promotion_board",
		minAge = 22, maxAge = 45,
		weight = 20, cooldown = 3,
		emoji = "📈", title = "Promotion Board!",
		category = "work",
		requiresFlag = "proven_soldier",
		getDynamicData = function()
			local ranks = {"Sergeant", "Staff Sergeant", "Sergeant First Class", "Captain", "Major"}
			return { rank = ranks[math.random(#ranks)] }
		end,
		text = "Up for promotion to %rank%! Board review today. How do you present yourself?",
		choices = {
			{ text = "💪 Confident and professional", effects = { Happiness = 20, Money = 15000 }, resultText = "PROMOTED! New rank! More responsibility! Well deserved!", setFlag = "nco" },
			{ text = "📋 Perfect record speaks", effects = { Happiness = 18, Money = 12000 }, resultText = "Your service record made the case! Promoted!", setFlag = "nco" },
			{ text = "😰 Nervous mess", effects = { Happiness = -5 }, resultText = "Board saw hesitation. Not this time. Work on leadership presence." },
			{ text = "🤷 Don't really want it", effects = { Happiness = 5 }, resultText = "Turned down promotion. Like where you are. Unusual but respected." },
		},
	},
	
	{
		id = "mil_special_forces",
		minAge = 21, maxAge = 35,
		weight = 12, oneTime = true,
		emoji = "🎖️", title = "Special Forces Selection!",
		category = "work",
		requiresFlag = "proven_soldier",
		text = "Invited to try out for Special Forces! The elite. 90% wash out rate. Will you attempt it?",
		choices = {
			{ text = "💪 Give it everything", effects = { Happiness = 30, Health = 10, Smarts = 8 }, resultText = "YOU MADE IT! One of the few! Special Forces operator!", setFlags = {"special_forces", "elite_soldier"} },
			{ text = "😤 Push until broken", effects = { Happiness = -15, Health = -20 }, resultText = "Washed out with injuries. Pushed too hard. Still a soldier.", setFlag = "selection_washout" },
			{ text = "🎯 Smart about it", effects = { Happiness = 20, Health = -5 }, resultText = "Paced yourself! Made it through! Mind over matter!", setFlags = {"special_forces", "tactical_thinker"} },
			{ text = "🙅 Not ready yet", effects = { Happiness = -5 }, resultText = "Declined the invitation. Maybe someday. Or maybe not your path." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- MILITARY LIFE CHALLENGES
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "mil_family_strain",
		minAge = 22, maxAge = 50,
		weight = 25, cooldown = 3,
		emoji = "👨‍👩‍👧", title = "Family Struggles...",
		category = "family",
		requiresFlag = "service_member",
		text = "Military life is hard on families. Spouse is frustrated with the moves, the deployments. What do you do?",
		choices = {
			{ text = "💬 Have the hard talk", effects = { Happiness = 8, Health = 5 }, resultText = "Worked through it together. Stronger for the honest conversation." },
			{ text = "🙅 Military comes first", effects = { Happiness = -15, Health = -5 }, resultText = "Prioritized career. Relationship suffered. Might be a mistake." },
			{ text = "📋 Request stateside duty", effects = { Happiness = 10, Money = -5000 }, resultText = "Got reassigned! Closer to home! Family stabilizing!" },
			{ text = "😔 Start drifting apart", effects = { Happiness = -20, Health = -8 }, resultText = "Growing distant. Military divorce rate is high for a reason...", setFlag = "marriage_trouble" },
		},
	},
	
	{
		id = "mil_ptsd_symptoms",
		minAge = 22, maxAge = 70,
		weight = 20, cooldown = 5,
		emoji = "😰", title = "Struggling Inside...",
		category = "health",
		requiresFlag = "combat_veteran",
		text = "Nightmares. Hypervigilance. Struggling to adjust. The war followed you home. What do you do?",
		choices = {
			{ text = "🏥 Get VA help", effects = { Happiness = 15, Health = 15 }, resultText = "Therapy helping! Medication if needed. You're not alone. Progress.", clearFlag = "ptsd_struggling", setFlag = "healing" },
			{ text = "💬 Talk to fellow vets", effects = { Happiness = 10, Health = 8 }, resultText = "They understand. Support group making a difference. Brotherhood helps." },
			{ text = "😶 Suffer in silence", effects = { Happiness = -20, Health = -15 }, resultText = "Getting worse. Pride stopping you from help. Please reach out.", setFlag = "ptsd_struggling" },
			{ text = "🍺 Self-medicate", effects = { Happiness = -15, Health = -20 }, resultText = "Making everything worse. Addiction starting. Need real help.", setFlags = {"ptsd_struggling", "substance_issue"} },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- TRANSITION / VETERAN LIFE
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "mil_retirement_decision",
		minAge = 38, maxAge = 55,
		weight = 15, oneTime = true,
		emoji = "🎖️", title = "Retirement Eligible!",
		category = "work",
		requiresFlag = "service_member",
		text = "20 years in! Eligible for retirement with full benefits! Or stay for more rank. What do you do?",
		choices = {
			{ text = "🏖️ Take the retirement", effects = { Happiness = 25, Health = 10, Money = 50000 }, resultText = "Retired military! Pension for life! New chapter begins!", setFlags = {"retired_military", "veteran"}, clearFlag = "service_member" },
			{ text = "🎖️ Go for higher rank", effects = { Happiness = 15, Money = 20000 }, resultText = "Staying in! Colonel/Command Sergeant Major in sight!" },
			{ text = "📋 Reserves/National Guard", effects = { Happiness = 18, Money = 30000 }, resultText = "Part-time military! Best of both worlds! Still serving!", setFlags = {"reserves", "veteran"} },
			{ text = "🔄 Second career time", effects = { Happiness = 20, Money = 40000 }, resultText = "Using skills in civilian world! Defense contractor calling!", setFlags = {"veteran", "civilian_career"} },
		},
	},
	
	{
		id = "mil_veteran_transition",
		minAge = 25, maxAge = 60,
		weight = 20, oneTime = true,
		emoji = "🔄", title = "Civilian World Now",
		category = "work",
		requiresFlag = "veteran",
		text = "Transitioning to civilian life. Different world. How do you approach it?",
		choices = {
			{ text = "💼 Corporate job using skills", effects = { Happiness = 15, Money = 80000 }, resultText = "Leadership and discipline valued! Great job! Smooth transition!", setFlag = "employed_veteran" },
			{ text = "🎓 Use GI Bill for school", effects = { Happiness = 18, Smarts = 15, Money = -10000 }, resultText = "Free degree! Investing in future! Smart move!", setFlag = "educated_veteran" },
			{ text = "🏢 Defense contractor", effects = { Happiness = 12, Money = 120000 }, resultText = "Good money using military knowledge! Familiar environment!", setFlag = "contractor" },
			{ text = "😔 Struggle to adapt", effects = { Happiness = -15, Health = -5 }, resultText = "Civilian world is confusing. Miss the structure. Adjustment is hard.", setFlag = "struggling_veteran" },
		},
	},
	
	{
		id = "mil_veterans_day",
		minAge = 30, maxAge = 90,
		weight = 15, cooldown = 5,
		emoji = "🇺🇸", title = "Veterans Day Recognition",
		category = "social",
		requiresFlag = "veteran",
		text = "Veterans Day. People thanking you for your service. How do you feel about it?",
		choices = {
			{ text = "🙏 Grateful for recognition", effects = { Happiness = 15 }, resultText = "Nice to be appreciated. Thinking of those who didn't come home." },
			{ text = "😔 Thinking of fallen friends", effects = { Happiness = -5, Health = -2 }, resultText = "Hard day. Memories of those lost. You carry them with you." },
			{ text = "🎖️ Proud to have served", effects = { Happiness = 20, Looks = 3 }, resultText = "Wearing medals. Marching in parade. Proud of your service.", setFlag = "proud_veteran" },
			{ text = "😤 Just another day", effects = { Happiness = 5 }, resultText = "Don't need recognition. Did what needed to be done. Move on." },
		},
	},
}

return module
