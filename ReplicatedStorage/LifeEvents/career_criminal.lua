-- career_criminal.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- CRIMINAL CAREER EVENTS - Street Life, Cons, Car Theft, Burglary
-- ═══════════════════════════════════════════════════════════════════════════════
-- 
-- ROBLOX TOS COMPLIANT - All content is cartoonish/generic, no real crime details
-- Focus is on consequences, choices, and redemption arcs
--
-- Contains events for:
-- - Street Hustler path
-- - Con Artist path  
-- - Car Thief path
-- - Burglar path
-- - Prison/Redemption events
--
-- ═══════════════════════════════════════════════════════════════════════════════

local events = {}

-- ═══════════════════════════════════════════════════════════════
-- STREET LIFE ORIGIN EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "hustle_opportunity",
	emoji = "🎲",
	title = "The Wrong Crowd",
	category = "life",
	tags = {"career", "criminal", "origin", "street_hustler"},
	
	weight = 8,
	cooldownYears = 99,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	chainId = "street_life_origin",
	chainStep = 1,
	
	conditions = {
		minAge = 14,
		maxAge = 25,
		blockedFlags = {"career_street_hustler_started", "crime_rejected"},
		maxStats = {Money = 1000},
	},
	
	getDynamicData = function(state)
		local names = {"Rico", "Marcus", "Dex", "Tyrone", "Santos"}
		return {
			name = names[math.random(#names)]
		}
	end,
	
	text = "%name% from the neighborhood approaches you. They know people who need help with 'deliveries' and other small jobs. Easy money, they say.",
	
	choices = {
		{
			id = "join_hustle",
			text = "Sure, I could use the cash.",
			resultText = "You start running small errands. The money comes fast, but you know this path has risks.",
			effects = {Money = 500, Karma = -3},
			flags = {set = {"career_street_hustler_started", "street_connected"}},
			startCareer = "street_hustler",
			careerXP = 10,
		},
		{
			id = "decline_politely",
			text = "Nah, I'm good. Thanks though.",
			resultText = "You walk away. Maybe it's better to struggle the honest way.",
			effects = {Karma = 2},
			flags = {set = {"crime_rejected"}},
		},
		{
			id = "snitch",
			text = "That sounds illegal. I should tell someone.",
			resultText = "You mention it to an adult. It doesn't make you popular in the neighborhood.",
			effects = {Karma = 3, Happiness = -2},
			flags = {set = {"crime_rejected", "neighborhood_snitch"}},
		},
	},
})

table.insert(events, {
	id = "street_first_job",
	emoji = "💵",
	title = "First Real Job",
	category = "crime",
	tags = {"career", "criminal", "street_hustler", "petty_crime"},
	
	weight = 15,
	cooldownYears = 2,
	oneTime = true,
	
	chainId = "street_life_origin",
	chainStep = 2,
	
	conditions = {
		minAge = 15,
		maxAge = 30,
		requiredCareerId = "street_hustler",
		requiredCareerMinTier = 1,
		requiredAllFlags = {"street_connected"},
	},
	
	getDynamicData = function(state)
		return {
			pay = math.random(200, 500),
		}
	end,
	
	text = "The crew needs someone to be a lookout during a 'meeting'. All you have to do is stand on the corner and text if you see anything suspicious. Easy $%pay%.",
	
	choices = {
		{
			id = "do_the_job",
			text = "I can handle being a lookout.",
			resultText = "You spend an hour watching the street. Nothing happens. Easy money.",
			effects = {Money = 350, Karma = -2},
			flags = {set = {"did_first_job"}},
			careerXP = 15,
		},
		{
			id = "back_out",
			text = "Actually, this feels wrong. I'm out.",
			resultText = "You walk away before you get in too deep. The crew thinks you're soft.",
			effects = {Karma = 3},
			flags = {set = {"backed_out_early"}},
			careerReputation = -10,
		},
	},
})

table.insert(events, {
	id = "street_promotion",
	emoji = "📈",
	title = "Moving Up",
	category = "crime",
	tags = {"career", "criminal", "street_hustler", "street_life"},
	
	weight = 10,
	cooldownYears = 3,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	conditions = {
		minAge = 17,
		maxAge = 35,
		requiredCareerId = "street_hustler",
		requiredCareerMinTier = 1,
		requiredAllFlags = {"did_first_job"},
	},
	
	getDynamicData = function(state)
		local bosses = {"King", "Ghost", "Bishop", "Ace", "Shadow"}
		return {
			boss = bosses[math.random(#bosses)],
		}
	end,
	
	text = "%boss% notices you've been reliable. They offer you a bigger role - you'd manage your own corner and some younger kids. More money, more responsibility, more risk.",
	
	choices = {
		{
			id = "accept_promotion",
			text = "I'm ready. Let's do this.",
			resultText = "You step up in the organization. The money is better, but so is the heat.",
			effects = {Money = 2000, Karma = -4},
			flags = {set = {"street_manager"}},
			promoteCareer = true,
			careerXP = 30,
		},
		{
			id = "stay_low",
			text = "I'd rather stay low-key.",
			resultText = "You stick to smaller jobs. Less money, less attention.",
			effects = {Karma = 1},
			flags = {set = {"prefers_low_profile"}},
		},
		{
			id = "try_to_leave",
			text = "Actually, I think I want out.",
			resultText = "Getting out isn't that simple, but %boss% respects your honesty. You're on thin ice though.",
			effects = {Karma = 3, Happiness = -2},
			flags = {set = {"trying_to_leave"}},
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- CON ARTIST EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "first_con",
	emoji = "🎭",
	title = "The Natural Talent",
	category = "crime",
	tags = {"career", "criminal", "con_artist", "origin"},
	
	weight = 8,
	cooldownYears = 99,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	chainId = "con_artist_origin",
	chainStep = 1,
	
	conditions = {
		minAge = 16,
		maxAge = 30,
		blockedFlags = {"career_con_artist_started", "honest_to_fault"},
		minStats = {Smarts = 40},
	},
	
	text = "You realize you have a gift for reading people and telling them exactly what they want to hear. A tourist asks for directions and you 'help' them find a restaurant... for a generous tip.",
	
	choices = {
		{
			id = "embrace_gift",
			text = "This is too easy. I should use this.",
			resultText = "You start looking for more opportunities to use your persuasion skills.",
			effects = {Money = 100, Karma = -3, Happiness = 2},
			flags = {set = {"career_con_artist_started", "smooth_talker"}},
			startCareer = "con_artist",
			careerXP = 15,
		},
		{
			id = "feel_guilty",
			text = "That felt wrong. I shouldn't do that again.",
			resultText = "You give them honest directions and refuse the tip. Integrity preserved.",
			effects = {Karma = 3},
			flags = {set = {"honest_to_fault"}},
		},
	},
})

table.insert(events, {
	id = "con_bigger_score",
	emoji = "🃏",
	title = "A Bigger Score",
	category = "crime",
	tags = {"career", "criminal", "con_artist", "grifting"},
	
	weight = 10,
	cooldownYears = 2,
	oneTime = false,
	
	conditions = {
		minAge = 18,
		maxAge = 50,
		requiredCareerId = "con_artist",
		requiredCareerMinTier = 1,
	},
	
	getDynamicData = function(state)
		local cons = {"fake charity fundraiser", "too-good-to-be-true investment", "exclusive club membership", "rare collectible sale"}
		return {
			con = cons[math.random(#cons)],
			payout = math.random(2, 10) * 1000,
		}
	end,
	
	text = "You spot an opportunity for a bigger con - a %con%. If it works, you could walk away with around $%payout%.",
	
	choices = {
		{
			id = "run_the_con",
			text = "Set it up and run the play.",
			resultText = "Everything goes smoothly. The mark never suspects a thing.",
			effects = {Money = 5000, Karma = -5},
			flags = {set = {"successful_con"}},
			careerXP = 25,
		},
		{
			id = "too_risky",
			text = "Too risky. Stick to small stuff.",
			resultText = "You let it pass. Maybe you're getting too cautious.",
			effects = {Karma = 1},
			careerXP = 5,
		},
	},
})

table.insert(events, {
	id = "con_almost_caught",
	emoji = "😰",
	title = "Close Call",
	category = "crime",
	tags = {"career", "criminal", "con_artist", "close_call"},
	
	weight = 8,
	cooldownYears = 3,
	oneTime = false,
	
	conditions = {
		minAge = 18,
		maxAge = 60,
		requiredCareerId = "con_artist",
		requiredCareerMinTier = 1,
		requiredAllFlags = {"successful_con"},
	},
	
	text = "One of your marks starts asking around. They're getting suspicious and asking neighbors if they've seen you. The heat is on.",
	
	choices = {
		{
			id = "lay_low",
			text = "Disappear for a while. Lay low.",
			resultText = "You go quiet for months. Eventually the heat dies down.",
			effects = {Happiness = -2, Money = -1000},
			flags = {set = {"laying_low"}},
		},
		{
			id = "skip_town",
			text = "Time to relocate.",
			resultText = "You move to a new city. Fresh start, fresh marks.",
			effects = {Money = -3000, Happiness = -1},
			flags = {set = {"relocated"}},
		},
		{
			id = "brazen_it_out",
			text = "Act normal. They can't prove anything.",
			resultText = "You play it cool. Eventually they give up. Lucky this time.",
			effects = {Happiness = 1},
			flags = {set = {"brazen"}},
			careerXP = 10,
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- CAR THIEF EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "first_car_boost",
	emoji = "🚗",
	title = "First Joyride",
	category = "crime",
	tags = {"career", "criminal", "car_thief", "origin"},
	
	weight = 8,
	cooldownYears = 99,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	chainId = "car_thief_origin",
	chainStep = 1,
	
	conditions = {
		minAge = 15,
		maxAge = 25,
		blockedFlags = {"career_car_thief_started", "car_theft_rejected"},
	},
	
	getDynamicData = function(state)
		local cars = {"an old sedan", "a sports car", "a muscle car", "a convertible"}
		return {
			car = cars[math.random(#cars)]
		}
	end,
	
	text = "Someone left %car% running outside a convenience store. Your friend dares you to hop in and take it for a spin around the block.",
	
	choices = {
		{
			id = "take_the_ride",
			text = "Let's go for a ride!",
			resultText = "The thrill is unreal. You drive it around and ditch it a few blocks away. Your heart is pounding.",
			effects = {Happiness = 3, Karma = -4},
			flags = {set = {"career_car_thief_started", "first_joyride"}},
			startCareer = "car_thief",
			careerXP = 10,
		},
		{
			id = "refuse",
			text = "No way. That's grand theft auto.",
			resultText = "You walk away. Some lines shouldn't be crossed.",
			effects = {Karma = 3},
			flags = {set = {"car_theft_rejected"}},
		},
	},
})

table.insert(events, {
	id = "car_theft_crew",
	emoji = "🔧",
	title = "Join a Boost Crew",
	category = "crime",
	tags = {"career", "criminal", "car_thief", "car_theft_basic"},
	
	weight = 12,
	cooldownYears = 99,
	oneTime = true,
	
	chainId = "car_thief_career",
	chainStep = 1,
	
	conditions = {
		minAge = 17,
		maxAge = 35,
		requiredCareerId = "car_thief",
		requiredCareerMinTier = 1,
		requiredAllFlags = {"first_joyride"},
	},
	
	getDynamicData = function(state)
		local names = {"the Chrome Kings", "the Midnight Runners", "the Chop Shop Boys"}
		return {
			crew = names[math.random(#names)],
		}
	end,
	
	text = "Word gets around about your driving skills. %crew% want you to join their operation. They boost cars and sell them to... interested parties.",
	
	choices = {
		{
			id = "join_crew",
			text = "I'm in. Let's make some real money.",
			resultText = "You're part of the crew now. The jobs are bigger and the pay is better.",
			effects = {Money = 3000, Karma = -5},
			flags = {set = {"boost_crew_member"}},
			promoteCareer = true,
			careerXP = 30,
		},
		{
			id = "solo_work",
			text = "I prefer working alone.",
			resultText = "You stick to solo jobs. Less money, but nobody to snitch.",
			effects = {Money = 500, Karma = -2},
			flags = {set = {"solo_thief"}},
			careerXP = 15,
		},
	},
})

table.insert(events, {
	id = "car_theft_luxury",
	emoji = "🏎️",
	title = "Luxury Target",
	category = "crime",
	tags = {"career", "criminal", "car_thief", "car_theft_pro"},
	
	weight = 8,
	cooldownYears = 3,
	oneTime = false,
	
	conditions = {
		minAge = 19,
		maxAge = 45,
		requiredCareerId = "car_thief",
		requiredCareerMinTier = 2,
	},
	
	getDynamicData = function(state)
		local cars = {"a limited edition sports car", "a rare vintage classic", "a custom luxury sedan"}
		return {
			car = cars[math.random(#cars)],
			payout = math.random(15, 30) * 1000,
		}
	end,
	
	text = "A buyer wants %car% specifically. They'll pay $%payout% if you can get it to them within 48 hours. The security will be tight.",
	
	choices = {
		{
			id = "take_the_job",
			text = "Challenge accepted.",
			resultText = "After careful planning, you pull it off. The payout is everything you hoped for.",
			effects = {Money = 22000, Karma = -6, Happiness = 3},
			flags = {set = {"luxury_job_done"}},
			careerXP = 35,
		},
		{
			id = "pass_on_it",
			text = "Too hot. I'll pass.",
			resultText = "You let someone else take the risk. Smart, maybe.",
			effects = {Karma = 1},
			careerXP = 5,
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- BURGLAR EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "first_break_in",
	emoji = "🏠",
	title = "Easy Mark",
	category = "crime",
	tags = {"career", "criminal", "burglar", "origin"},
	
	weight = 7,
	cooldownYears = 99,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	chainId = "burglar_origin",
	chainStep = 1,
	
	conditions = {
		minAge = 15,
		maxAge = 28,
		blockedFlags = {"career_burglar_started", "burglary_rejected"},
		maxStats = {Money = 500},
	},
	
	text = "Walking home late, you notice a house with an open window. The family is clearly on vacation - mail piled up, no cars. The temptation is real.",
	
	choices = {
		{
			id = "break_in",
			text = "Just a quick look around...",
			resultText = "You slip in and grab some valuables. Quick, quiet, and profitable.",
			effects = {Money = 800, Karma = -5},
			flags = {set = {"career_burglar_started", "first_break_in_done"}},
			startCareer = "burglar",
			careerXP = 15,
		},
		{
			id = "walk_away",
			text = "No. This is someone's home.",
			resultText = "You keep walking. Some lines you won't cross.",
			effects = {Karma = 4},
			flags = {set = {"burglary_rejected"}},
		},
	},
})

table.insert(events, {
	id = "burglar_upgrade",
	emoji = "🎯",
	title = "Bigger Scores",
	category = "crime",
	tags = {"career", "criminal", "burglar", "burglary_basic"},
	
	weight = 10,
	cooldownYears = 2,
	oneTime = false,
	
	conditions = {
		minAge = 18,
		maxAge = 50,
		requiredCareerId = "burglar",
		requiredCareerMinTier = 1,
	},
	
	getDynamicData = function(state)
		local targets = {"a wealthy neighborhood", "vacation homes", "a small business after hours"}
		return {
			target = targets[math.random(#targets)],
		}
	end,
	
	text = "You've scoped out %target%. The security looks manageable and the potential haul could be significant.",
	
	choices = {
		{
			id = "do_the_job",
			text = "Plan it out and make a move.",
			resultText = "Careful planning pays off. You get in and out without issues.",
			effects = {Money = 5000, Karma = -5},
			flags = {set = {"successful_burglary"}},
			careerXP = 25,
		},
		{
			id = "abort",
			text = "Something feels off. Abort.",
			resultText = "You trust your instincts and walk away. Maybe next time.",
			effects = {Karma = 1},
			flags = {set = {"cautious_burglar"}},
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- PRISON / CONSEQUENCES EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "criminal_arrested",
	emoji = "🚔",
	title = "Caught",
	category = "crime",
	tags = {"career", "criminal", "arrest", "consequences"},
	
	weight = 6,
	cooldownYears = 5,
	oneTime = false,
	milestone = false, -- Career events should NOT be milestones
	
	conditions = {
		minAge = 16,
		maxAge = 70,
		requiredAnyFlags = {"street_connected", "boost_crew_member", "first_break_in_done", "successful_con"},
		blockedFlags = {"in_prison", "just_released"},
	},
	
	text = "The police finally catch up with you. You're arrested and charged. This could mean serious time.",
	
	choices = {
		{
			id = "plead_guilty",
			text = "Plead guilty and hope for leniency.",
			resultText = "The judge appreciates your cooperation and gives you a lighter sentence.",
			effects = {Happiness = -8, Karma = 2},
			flags = {set = {"in_prison", "criminal_record", "pleaded_guilty"}},
		},
		{
			id = "fight_charges",
			text = "Get a lawyer and fight the charges.",
			resultText = "Your lawyer does their best. The outcome is uncertain...",
			effects = {Money = -10000, Happiness = -5},
			flags = {set = {"fighting_charges"}},
		},
		{
			id = "cooperate",
			text = "Cooperate with authorities and give names.",
			resultText = "You become an informant. Reduced charges, but now you have enemies.",
			effects = {Karma = -3, Happiness = -4},
			flags = {set = {"informant", "reduced_sentence"}},
		},
	},
})

table.insert(events, {
	id = "prison_life",
	emoji = "⛓️",
	title = "Behind Bars",
	category = "crime",
	tags = {"prison", "criminal", "consequences"},
	
	weight = 20,
	cooldownYears = 1,
	oneTime = false,
	
	conditions = {
		minAge = 16,
		maxAge = 80,
		requiredAllFlags = {"in_prison"},
	},
	
	text = "Another year passes in prison. The days blur together. How will you spend your time?",
	
	choices = {
		{
			id = "education",
			text = "Take educational classes.",
			resultText = "You study and earn some credits. It's something positive at least.",
			effects = {Smarts = 3, Karma = 2},
			flags = {set = {"prison_education"}},
		},
		{
			id = "workout",
			text = "Hit the yard and work out.",
			resultText = "You get stronger and earn some respect.",
			effects = {Health = 5, Looks = 2},
			flags = {set = {"prison_fitness"}},
		},
		{
			id = "keep_head_down",
			text = "Keep your head down and do your time.",
			resultText = "You avoid trouble and wait for release day.",
			effects = {Happiness = -2, Karma = 1},
			flags = {set = {"good_behavior"}},
		},
		{
			id = "make_connections",
			text = "Network with other inmates.",
			resultText = "You make some connections that might be useful later. Or dangerous.",
			effects = {Karma = -2},
			flags = {set = {"prison_connections"}},
		},
	},
})

table.insert(events, {
	id = "prison_release",
	emoji = "🕊️",
	title = "Freedom",
	category = "crime",
	tags = {"prison", "release", "fresh_start"},
	
	weight = 15,
	cooldownYears = 99,
	oneTime = false,
	milestone = false, -- Career events should NOT be milestones
	
	conditions = {
		minAge = 18,
		maxAge = 80,
		requiredAllFlags = {"in_prison"},
	},
	
	text = "Your sentence is up. The gates open and you step into the world again. Everything looks different. What now?",
	
	choices = {
		{
			id = "go_straight",
			text = "Go straight. Start over.",
			resultText = "You're determined to leave that life behind. It won't be easy with a record, but you'll try.",
			effects = {Happiness = 4, Karma = 5},
			flags = {set = {"going_straight", "just_released"}, clear = {"in_prison"}},
			quitCareer = true,
		},
		{
			id = "back_to_old_ways",
			text = "Hit up old contacts. Back to business.",
			resultText = "The straight world doesn't want you anyway. Might as well do what you know.",
			effects = {Happiness = 1, Karma = -3},
			flags = {set = {"back_in_game", "just_released"}, clear = {"in_prison"}},
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- REDEMPTION / EXIT EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "criminal_redemption_chance",
	emoji = "✨",
	title = "Second Chance",
	category = "life",
	tags = {"criminal", "redemption", "fresh_start"},
	
	weight = 6,
	cooldownYears = 99,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	conditions = {
		minAge = 20,
		maxAge = 60,
		requiredAnyFlags = {"going_straight", "trying_to_leave"},
		requiredAllFlags = {"criminal_record"},
	},
	
	getDynamicData = function(state)
		local opportunities = {"a job training program", "a small business owner willing to hire", "a community organization"}
		return {
			opportunity = opportunities[math.random(#opportunities)]
		}
	end,
	
	text = "Despite your record, %opportunity% is willing to give you a chance. It's not glamorous, but it's honest work.",
	
	choices = {
		{
			id = "take_chance",
			text = "Thank you. I won't let you down.",
			resultText = "You start fresh with honest work. It's hard, but you sleep better at night.",
			effects = {Happiness = 5, Karma = 8},
			flags = {set = {"legitimate_job", "redemption_started"}},
		},
		{
			id = "reject_chance",
			text = "The pay is terrible. I can't live on this.",
			resultText = "You turn it down. The easy money is still tempting.",
			effects = {Happiness = -2, Karma = -2},
			flags = {set = {"rejected_redemption"}},
		},
	},
})

table.insert(events, {
	id = "criminal_boss_offer",
	emoji = "👑",
	title = "Rise to the Top",
	category = "crime",
	tags = {"career", "criminal", "promotion", "crime_boss"},
	
	weight = 5,
	cooldownYears = 99,
	oneTime = true,
	milestone = false, -- Career events should NOT be milestones
	
	conditions = {
		minAge = 28,
		maxAge = 50,
		requiredAnyFlags = {"street_manager", "boost_crew_member", "luxury_job_done"},
		blockedFlags = {"crime_boss", "going_straight"},
	},
	
	text = "The old boss is retiring. Everyone agrees you should take over the operation. You'd be running things now.",
	
	choices = {
		{
			id = "take_crown",
			text = "It's my time. I'll lead.",
			resultText = "You become the boss. More power, more money, but also more targets on your back.",
			effects = {Money = 50000, Karma = -8, Happiness = 3},
			flags = {set = {"crime_boss"}},
			promoteCareer = true,
			careerXP = 100,
		},
		{
			id = "pass_the_crown",
			text = "I don't want that heat. Pass it to someone else.",
			resultText = "You let someone else take the throne. You're still respected, just not in charge.",
			effects = {Karma = 2},
			flags = {set = {"declined_boss"}},
		},
		{
			id = "use_to_exit",
			text = "Use this moment to get out entirely.",
			resultText = "You announce you're done. They respect your years of service and let you walk.",
			effects = {Karma = 5, Happiness = 4},
			flags = {set = {"retired_criminal"}},
			quitCareer = true,
		},
	},
})

table.insert(events, {
	id = "criminal_close_call_death",
	emoji = "☠️",
	title = "Too Close",
	category = "crime",
	tags = {"criminal", "danger", "mortality"},
	
	weight = 5,
	cooldownYears = 5,
	oneTime = false,
	
	conditions = {
		minAge = 18,
		maxAge = 70,
		requiredAnyFlags = {"street_connected", "boost_crew_member", "crime_boss"},
		blockedFlags = {"going_straight"},
	},
	
	text = "A deal goes bad. You barely escape with your life. Lying in bed that night, you stare at the ceiling and wonder if this is worth it.",
	
	choices = {
		{
			id = "shake_it_off",
			text = "Part of the game. I'll be more careful.",
			resultText = "You double down on your security and keep going.",
			effects = {Health = -5, Happiness = -3},
			flags = {set = {"survivor"}},
		},
		{
			id = "reconsider_life",
			text = "This isn't worth dying over.",
			resultText = "The brush with death makes you question everything.",
			effects = {Health = -3, Karma = 3},
			flags = {set = {"reconsidering"}},
		},
	},
})

return {events = events}
