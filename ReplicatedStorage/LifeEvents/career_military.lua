-- LifeEvents/career_military.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- MILITARY CAREER EVENTS
-- Soldiers, Officers, Veterans, Special Forces - Service life
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent.init)

local module = {}

module.events = {
	
	-- ═══════════════════════════════════════════════════════════════
	-- ENLISTING / EARLY MILITARY
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "mil_recruiter_visit",
		minAge = 17, maxAge = 25,
		weight = 25, oneTime = true,
		emoji = "🎖️", title = "Military Recruiter",
		category = "work",
		getDynamicData = function()
			local branches = {"Army", "Navy", "Air Force", "Marines", "Coast Guard"}
			return { branch = branches[math.random(#branches)] }
		end,
		text = "A %branch% recruiter is talking about service. Benefits, travel, purpose...",
		choices = {
			{ text = "🎖️ Sign up!", effects = { Happiness = 15, Health = 5 }, resultText = "You're joining the military! Boot camp awaits! Serve your country!", setFlags = {"military_interest", "enlisting"} },
			{ text = "🤔 Consider it", effects = { Happiness = 5, Smarts = 3 }, resultText = "Taking the information. Big decision. Need to think.", setFlag = "military_interest" },
			{ text = "🎓 ROTC instead", effects = { Happiness = 10, Smarts = 5 }, resultText = "College + military. Officer track. Best of both worlds.", setFlags = {"military_interest", "rotc"} },
			{ text = "🙅 Not for me", effects = { Happiness = 2 }, resultText = "Appreciate those who serve but it's not your path." },
		},
	},
	
	{
		id = "mil_boot_camp",
		minAge = 18, maxAge = 28,
		weight = 25, oneTime = true,
		emoji = "🏋️", title = "Boot Camp!",
		category = "work",
		requiresFlag = "enlisting",
		text = "Basic training begins. Drill sergeants screaming. Bodies breaking. Bonds forming.",
		choices = {
			{ text = "💪 Made it through!", effects = { Happiness = 20, Health = 15, Smarts = 3 }, resultText = "Graduated boot camp! Transformed! You're a soldier now!", clearFlag = "enlisting", setFlags = {"soldier", "military"} },
			{ text = "😤 Hardest thing ever", effects = { Happiness = 10, Health = 10, Smarts = 5 }, resultText = "Pushed beyond limits. Crying at night. But you survived.", clearFlag = "enlisting", setFlags = {"soldier", "military"} },
			{ text = "🤝 Brothers/sisters forged", effects = { Happiness = 18, Health = 12 }, resultText = "The bonds formed here are forever. These are your people now.", clearFlag = "enlisting", setFlags = {"soldier", "military", "unit_bond"} },
			{ text = "😔 Washed out", effects = { Happiness = -20, Health = -5 }, resultText = "Couldn't make it. Sent home. The shame is overwhelming.", clearFlag = "enlisting", setFlag = "military_washout" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- MILITARY SERVICE
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "mil_first_deployment",
		minAge = 18, maxAge = 40,
		weight = 25, cooldown = 3,
		emoji = "✈️", title = "First Deployment!",
		category = "work",
		requiresFlag = "soldier",
		getDynamicData = function()
			local locations = {"the Middle East", "Europe", "Asia Pacific", "Africa", "South America"}
			return { location = locations[math.random(#locations)] }
		end,
		text = "You're being deployed to %location%! First real deployment!",
		choices = {
			{ text = "🫡 Serve with honor", effects = { Happiness = 10, Health = -5, Smarts = 5 }, resultText = "Months away from home. But you're doing your duty.", setFlag = "deployed" },
			{ text = "😰 Scared but ready", effects = { Happiness = 5, Health = -3 }, resultText = "Fear is natural. Courage is doing it anyway.", setFlag = "deployed" },
			{ text = "👨‍👩‍👧 Family goodbye", effects = { Happiness = -10, Smarts = 3 }, resultText = "The hardest goodbye. They need you but so does your country.", setFlags = {"deployed", "family_sacrifice"} },
			{ text = "🎖️ Prove yourself", effects = { Happiness = 15, Health = -5 }, resultText = "Time to show what you're made of. Deployment is the real test.", setFlag = "deployed" },
		},
	},
	
	{
		id = "mil_combat",
		minAge = 18, maxAge = 45,
		weight = 20, cooldown = 3,
		emoji = "💥", title = "Combat Situation!",
		category = "work",
		requiresFlag = "deployed",
		text = "Under fire! Real combat! Everything slows down. Training kicks in.",
		choices = {
			{ text = "🦸 Heroic actions", effects = { Happiness = 15, Health = -10, Smarts = 5 }, resultText = "Did what needed to be done. Saved lives. Will never forget this day.", setFlags = {"combat_vet", "hero"} },
			{ text = "😰 Survived", effects = { Happiness = -5, Health = -8 }, resultText = "Made it through. Shaking afterward. Changed forever.", setFlag = "combat_vet" },
			{ text = "💔 Lost friends", effects = { Happiness = -25, Health = -10 }, resultText = "They didn't make it. You did. Survivor's guilt is crushing.", setFlags = {"combat_vet", "lost_comrades"} },
			{ text = "🏥 Wounded", effects = { Happiness = -15, Health = -25, Money = 5000 }, resultText = "Got hit. Medevac'd out. Purple Heart. Long recovery ahead.", setFlags = {"combat_vet", "wounded", "purple_heart"} },
		},
	},
	
	{
		id = "mil_medal_ceremony",
		minAge = 19, maxAge = 50,
		weight = 15, oneTime = true,
		emoji = "🎖️", title = "Medal of Valor!",
		category = "work",
		requiresFlag = "hero",
		getDynamicData = function()
			local medals = {"Bronze Star", "Silver Star", "Distinguished Service Medal", "Medal of Honor nomination"}
			return { medal = medals[math.random(#medals)] }
		end,
		text = "You're being awarded the %medal% for your actions in combat!",
		choices = {
			{ text = "🎖️ Humbled", effects = { Happiness = 25, Looks = 5 }, resultText = "Standing at attention. Medal pinned on. Representing all who served.", setFlag = "decorated" },
			{ text = "😔 Wish they were here", effects = { Happiness = 10, Smarts = 3 }, resultText = "This belongs to those who didn't come home. You wear it for them.", setFlag = "decorated" },
			{ text = "👨‍👩‍👧 Family so proud", effects = { Happiness = 30 }, resultText = "Your family watching. Parents crying. Worth every sacrifice.", setFlag = "decorated" },
			{ text = "🤫 Don't talk about it", effects = { Happiness = 5, Smarts = 3 }, resultText = "The medal goes in a drawer. What happened stays with you.", setFlag = "decorated" },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- ADVANCEMENT / SPECIAL FORCES
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "mil_promotion",
		minAge = 20, maxAge = 50,
		weight = 25, cooldown = 3,
		emoji = "⬆️", title = "Promotion!",
		category = "work",
		requiresFlag = "soldier",
		getDynamicData = function()
			local ranks = {"Corporal", "Sergeant", "Staff Sergeant", "Lieutenant", "Captain", "Major"}
			return { rank = ranks[math.random(#ranks)] }
		end,
		text = "You've been promoted to %rank%! Moving up the ranks!",
		choices = {
			{ text = "🎖️ Earned it!", effects = { Happiness = 20, Money = 10000, Smarts = 3 }, resultText = "New stripes/bars! More responsibility! Leadership role!", setFlag = "nco" },
			{ text = "👥 Leading troops", effects = { Happiness = 18, Smarts = 5 }, resultText = "People's lives in your hands now. Heavy but honored.", setFlags = {"nco", "leader"} },
			{ text = "💰 Better pay", effects = { Happiness = 15, Money = 15000 }, resultText = "Rank has its privileges. Supporting family better now.", setFlag = "nco" },
			{ text = "😰 More pressure", effects = { Happiness = 8, Health = -3 }, resultText = "Higher rank, higher expectations. The weight increases.", setFlag = "nco" },
		},
	},
	
	{
		id = "mil_special_forces_tryout",
		minAge = 21, maxAge = 35,
		weight = 12, oneTime = true,
		emoji = "🎯", title = "Special Forces Selection!",
		category = "work",
		requiresFlag = "combat_vet",
		getDynamicData = function()
			local units = {"Navy SEALs", "Army Rangers", "Green Berets", "Delta Force", "Marine Force Recon"}
			return { unit = units[math.random(#units)] }
		end,
		text = "You've been selected to try out for %unit%! The elite of the elite!",
		choices = {
			{ text = "💀 Hell Week survived!", effects = { Happiness = 30, Health = -15, Smarts = 5 }, resultText = "You made it through the most brutal training on Earth. YOU'RE SPECIAL FORCES!", setFlags = {"special_forces", "elite_soldier"} },
			{ text = "🔔 Rang the bell", effects = { Happiness = -20, Health = -10 }, resultText = "Quit during training. No shame - most do. But it haunts you." },
			{ text = "🤕 Injured out", effects = { Happiness = -15, Health = -20 }, resultText = "Body gave out during selection. Medical drop. Devastating." },
			{ text = "🏆 Top of class", effects = { Happiness = 35, Health = -10, Smarts = 8 }, resultText = "Not just passed - excelled! The best of the best want YOU!", setFlags = {"special_forces", "elite_soldier", "top_performer"} },
		},
	},
	
	{
		id = "mil_classified_mission",
		minAge = 22, maxAge = 45,
		weight = 15, cooldown = 4,
		emoji = "🤫", title = "Classified Mission",
		category = "work",
		requiresFlag = "special_forces",
		text = "Black ops. No records. What happens here never happened. Are you ready?",
		choices = {
			{ text = "🎯 Mission accomplished", effects = { Happiness = 20, Smarts = 5 }, resultText = "Success. Details classified forever. You know what you did.", setFlag = "black_ops_vet" },
			{ text = "💀 Close call", effects = { Happiness = -5, Health = -15 }, resultText = "Almost didn't make it back. Can never talk about it.", setFlag = "black_ops_vet" },
			{ text = "😔 Morally gray", effects = { Happiness = -10, Smarts = 5 }, resultText = "Did what you were ordered. Following orders isn't the same as agreeing.", setFlags = {"black_ops_vet", "moral_conflict"} },
			{ text = "🏆 High-value target", effects = { Happiness = 25, Looks = 3 }, resultText = "HVT neutralized. World is safer. You'll never get public credit.", setFlags = {"black_ops_vet", "hvt_success"} },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- LEAVING SERVICE / VETERAN LIFE
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "mil_ptsd",
		minAge = 20, maxAge = 70,
		weight = 20, cooldown = 4,
		emoji = "😰", title = "PTSD Struggles",
		category = "health",
		requiresFlag = "combat_vet",
		text = "The nightmares. The flashbacks. Loud noises making you jump. It's getting worse.",
		choices = {
			{ text = "💬 Got help", effects = { Happiness = 15, Health = 10 }, resultText = "VA therapy. Group sessions. Slowly healing. Not alone.", setFlags = {"ptsd", "getting_help"} },
			{ text = "😔 Suffering alone", effects = { Happiness = -20, Health = -15 }, resultText = "Too proud to ask for help. The darkness deepens.", setFlags = {"ptsd", "struggling"} },
			{ text = "🐕 Service dog", effects = { Happiness = 20, Health = 10 }, resultText = "Your service dog knows when you're spiraling. Best therapy ever.", setFlags = {"ptsd", "service_dog"} },
			{ text = "🤝 Battle buddies help", effects = { Happiness = 12, Health = 8 }, resultText = "Your unit stays connected. They understand. Checking in saves lives.", setFlags = {"ptsd", "supported"} },
		},
	},
	
	{
		id = "mil_discharge",
		minAge = 22, maxAge = 50,
		weight = 20, oneTime = true,
		emoji = "🏠", title = "End of Service",
		category = "work",
		requiresFlag = "soldier",
		getDynamicData = function()
			local years = math.random(4, 25)
			return { years = years }
		end,
		text = "After %years% years of service, it's time. Honorable discharge. Civilian life awaits.",
		choices = {
			{ text = "🇺🇸 Proud of service", effects = { Happiness = 25, Health = 5 }, resultText = "No regrets. Served your country. Veteran for life.", clearFlags = {"soldier", "deployed"}, setFlags = {"veteran", "honorably_discharged"} },
			{ text = "😰 Transition is hard", effects = { Happiness = -5, Smarts = 3 }, resultText = "Military was identity. Who are you now? Lost.", clearFlags = {"soldier", "deployed"}, setFlags = {"veteran", "struggling_transition"} },
			{ text = "🎓 GI Bill education", effects = { Happiness = 15, Smarts = 8 }, resultText = "Free college! New chapter! Military benefits paying off!", clearFlags = {"soldier", "deployed"}, setFlags = {"veteran", "gi_bill"} },
			{ text = "💼 Contractor work", effects = { Happiness = 12, Money = 100000 }, resultText = "Private security. Same skills, way better pay.", clearFlags = {"soldier", "deployed"}, setFlags = {"veteran", "contractor"} },
		},
	},
	
	{
		id = "mil_veterans_day",
		minAge = 25, maxAge = 95,
		weight = 20, cooldown = 5,
		emoji = "🇺🇸", title = "Veterans Day",
		category = "social",
		requiresFlag = "veteran",
		text = "Veterans Day. People thanking you for your service. Parades. Memories.",
		choices = {
			{ text = "🇺🇸 Proud to march", effects = { Happiness = 20 }, resultText = "Wearing your uniform. Marching with fellow vets. Honored.", setFlag = "veteran_proud" },
			{ text = "😔 Bittersweet", effects = { Happiness = 5, Smarts = 3 }, resultText = "Thinking of those who didn't make it back. Empty chairs at the table." },
			{ text = "🤐 Just another day", effects = { Happiness = 2 }, resultText = "Don't like the attention. Did a job. Don't need thanks." },
			{ text = "👨‍👩‍👧 Teaching the kids", effects = { Happiness = 18, Smarts = 3 }, resultText = "Telling your grandchildren what service meant. Passing the torch." },
		},
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- LEGACY
	-- ═══════════════════════════════════════════════════════════════
	
	{
		id = "mil_arlington",
		minAge = 70, maxAge = 100,
		weight = 10, oneTime = true,
		emoji = "🪦", title = "Final Honors",
		category = "family",
		requiresFlag = "decorated",
		text = "Planning your final wishes. As a decorated veteran, Arlington National Cemetery is an option.",
		choices = {
			{ text = "🇺🇸 Arlington", effects = { Happiness = 25 }, resultText = "Resting among heroes. Flag-draped ceremony. Taps playing. Honorable end.", setFlag = "arlington_burial" },
			{ text = "👨‍👩‍👧 Near family", effects = { Happiness = 20 }, resultText = "Want to be with your family. Service was life, but family is forever." },
			{ text = "🎖️ Medals to museum", effects = { Happiness = 18, Smarts = 3 }, resultText = "Donating medals and uniform to military museum. Story preserved." },
			{ text = "📖 Memoirs written", effects = { Happiness = 22, Smarts = 5 }, resultText = "Your story documented. Future generations will know what you did.", setFlag = "military_author" },
		},
	},
	
	{
		id = "mil_family_legacy",
		minAge = 40, maxAge = 80,
		weight = 15, oneTime = true,
		emoji = "🎖️", title = "Military Family Legacy",
		category = "family",
		requiresFlag = "veteran",
		text = "Your child wants to follow in your footsteps. Join the military.",
		choices = {
			{ text = "🎖️ Proud tradition", effects = { Happiness = 30 }, resultText = "Third generation of service. Your family serves. Legacy continues.", setFlag = "military_dynasty" },
			{ text = "😰 Know the cost", effects = { Happiness = 10, Smarts = 5 }, resultText = "You know what they'll face. The sacrifices. But you support them." },
			{ text = "❌ Try to stop them", effects = { Happiness = -5 }, resultText = "You've seen too much. Want better for them. They enlist anyway." },
			{ text = "🫡 Give your blessing", effects = { Happiness = 20 }, resultText = "If they're called to serve, you support them. Semper Fi." },
		},
	},
}

return module
