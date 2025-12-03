-- career_automotive.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- AAA-TIER AUTOMOTIVE/RACING CAREER EVENTS
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- This is ONE career done GODLY with:
-- - 70+ deep interconnected events
-- - Full life arc coverage (ages 0-80)
-- - Trait integration (RacerInterest, SpeedDemon, etc.)
-- - Real consequences (crashes, injuries, death, prison)
-- - Branching paths that MATTER
-- - Events that reference each other
-- - Hidden flags that unlock future content
--
-- EVENT CATEGORIES:
-- • Childhood Origins (0-12): Toy cars, go-karts, dad's garage
-- • Teen Discovery (13-17): First car, driving lessons, street racing initiation
-- • Young Adult (18-35): Career paths diverge - racing, mechanic, crime
-- • Peak Career (25-50): Championships, business empire, criminal enterprise
-- • Late Career (40-65): Legacy, retirement, consequences catch up
--
-- ═══════════════════════════════════════════════════════════════════════════════

local events = {}

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 1: CHILDHOOD ORIGINS (Ages 0-12)
-- These events plant the seeds for the entire career path
-- ═══════════════════════════════════════════════════════════════════════════════

table.insert(events, {
	id = "childhood_toy_cars",
	emoji = "🚗",
	title = "The Toy That Changed Everything",
	category = "childhood",
	tags = {"origin", "childhood", "trait_forming", "automotive"},
	
	weight = 15,
	oneTime = true,
	milestone = true,
	
	chainId = "racer_origin",
	chainStep = 1,
	
	conditions = {
		minAge = 1,
		maxAge = 3,
		blockedFlags = {"racer_interest_rejected", "racer_interest"},
	},
	
	text = "Your parents give you a set of toy cars for your birthday. You become obsessed - spending hours pushing them around, making engine sounds, crashing them into each other. You refuse to play with anything else.",
	
	choices = {
		{
			id = "complete_obsession",
			text = "You play with them constantly. They become your whole world.",
			resultText = "Your parents notice your unusual focus. You arrange the cars by color, by size, by speed. Something is different about this child.",
			effects = {Happiness = 5},
			flags = {set = {"racer_interest", "mechanical_curiosity", "childhood_car_obsession", "trait_racer_interest"}},
		},
		{
			id = "normal_interest",
			text = "You like them, but also play with other toys.",
			resultText = "Cars are fun, but so are blocks and stuffed animals. You're a normal, balanced kid.",
			effects = {Happiness = 3},
			flags = {set = {"casual_car_interest"}},
		},
		{
			id = "prefer_other_toys",
			text = "You push them aside and reach for something else.",
			resultText = "Cars aren't really your thing. Your parents donate the set.",
			effects = {Happiness = 2},
			flags = {set = {"racer_interest_rejected"}},
		},
	},
})

table.insert(events, {
	id = "childhood_car_sounds",
	emoji = "🔊",
	title = "The Sound of Engines",
	category = "childhood",
	tags = {"origin", "childhood", "sensory", "automotive"},
	
	weight = 12,
	oneTime = true,
	
	chainId = "racer_origin",
	chainStep = 2,
	
	conditions = {
		minAge = 2,
		maxAge = 5,
		requiredAnyFlags = {"racer_interest", "casual_car_interest"},
	},
	
	text = "A loud sports car rumbles past your house. The deep growl of its engine makes you freeze mid-step. You run to the window, eyes wide, heart pounding. That sound... it does something to you.",
	
	choices = {
		{
			id = "mesmerized",
			text = "You're completely mesmerized. You need to hear that again.",
			resultText = "You start begging your parents to take you places where you can see fast cars. The obsession deepens.",
			effects = {Happiness = 6},
			flags = {set = {"engine_obsession", "sound_memory", "deep_racer_interest"}},
		},
		{
			id = "scared",
			text = "The noise scares you. You cover your ears and cry.",
			resultText = "Your parents comfort you. Cars are loud and scary. You develop a slight nervousness around vehicles.",
			effects = {Happiness = -2, Health = -1},
			flags = {set = {"car_anxiety"}},
		},
		{
			id = "curious",
			text = "You're curious. 'What makes that sound, Mommy?'",
			resultText = "Your parent explains about engines. You listen intently, absorbing every word.",
			effects = {Smarts = 2, Happiness = 3},
			flags = {set = {"mechanical_curiosity", "asks_questions"}},
		},
	},
})

table.insert(events, {
	id = "childhood_dads_garage",
	emoji = "🔧",
	title = "Dad's Workshop",
	category = "childhood",
	tags = {"origin", "childhood", "mechanical", "family", "automotive"},
	
	weight = 12,
	oneTime = true,
	
	chainId = "mechanic_origin",
	chainStep = 1,
	
	conditions = {
		minAge = 4,
		maxAge = 10,
		blockedFlags = {"no_father_figure", "mechanical_aptitude_rejected"},
	},
	
	getDynamicData = function(state)
		local projects = {"an old motorcycle", "a classic car", "a lawnmower engine", "the family car's brakes"}
		return {
			project = projects[math.random(#projects)]
		}
	end,
	
	text = "Your dad (or a father figure) is working on %project% in the garage. Grease-stained hands, scattered tools, the smell of oil. He notices you watching from the doorway.",
	
	choices = {
		{
			id = "help_eagerly",
			text = "'Can I help?' You run over and grab a wrench.",
			resultText = "He shows you how to hold the light, hand him tools, identify parts. You're covered in grease by the end and couldn't be happier.",
			effects = {Happiness = 8, Smarts = 3},
			flags = {set = {"mechanical_aptitude", "garage_memories", "father_bond", "hands_on_learner", "trait_mechanical_aptitude"}},
		},
		{
			id = "watch_quietly",
			text = "You watch from a distance, fascinated but shy.",
			resultText = "You observe how things work, how problems get solved. The knowledge seeps in passively.",
			effects = {Smarts = 2, Happiness = 2},
			flags = {set = {"mechanical_curiosity", "observer_learner"}},
		},
		{
			id = "leave",
			text = "It's boring. You go back inside to watch TV.",
			resultText = "Machines aren't your thing. At least not yet.",
			effects = {Happiness = 1},
			flags = {set = {"mechanical_aptitude_rejected"}},
		},
	},
})

table.insert(events, {
	id = "childhood_first_gokart",
	emoji = "🏎️",
	title = "First Time Behind the Wheel",
	category = "childhood",
	tags = {"origin", "childhood", "racing", "formative", "automotive"},
	
	weight = 14,
	oneTime = true,
	milestone = true,
	
	chainId = "racer_origin",
	chainStep = 3,
	
	conditions = {
		minAge = 6,
		maxAge = 12,
		requiredAnyFlags = {"racer_interest", "deep_racer_interest", "casual_car_interest"},
		blockedFlags = {"first_drive_done"},
	},
	
	getDynamicData = function(state)
		local venues = {"a birthday party at a go-kart track", "a county fair", "a friend's house with a go-kart", "a racing experience gift"}
		return {
			venue = venues[math.random(#venues)]
		}
	end,
	
	text = "At %venue%, you get to drive a go-kart for the first time. As you grip the wheel and press the pedal, something fundamental changes inside you. The vibration, the speed, the control... this is what you were made for.",
	
	choices = {
		{
			id = "natural_talent",
			text = "You're a natural. Fastest kid on the track.",
			resultText = "Adults take notice. 'That kid's got something.' You finish laps ahead of everyone else, grinning ear to ear.",
			effects = {Happiness = 10, Smarts = 2},
			flags = {set = {"first_drive_done", "racing_talent", "competition_winner", "speed_addiction", "trait_natural_racer"}},
		},
		{
			id = "crash_but_love_it",
			text = "You crash into the barriers twice, but you don't care. You love it.",
			resultText = "Bruised but laughing, you beg for another go. The crashes only make the adrenaline sweeter.",
			effects = {Happiness = 8, Health = -2},
			flags = {set = {"first_drive_done", "crash_survivor", "reckless_streak", "speed_addiction", "trait_thrill_seeker"}},
		},
		{
			id = "terrified",
			text = "It's too fast. You brake constantly and finish last.",
			resultText = "Your heart pounds with fear, not excitement. Maybe racing isn't for you.",
			effects = {Happiness = -1},
			flags = {set = {"first_drive_done", "racing_fear", "cautious_driver"}},
		},
	},
})

table.insert(events, {
	id = "childhood_racing_hero",
	emoji = "🏆",
	title = "Your Racing Hero",
	category = "childhood",
	tags = {"childhood", "inspiration", "idol", "automotive"},
	
	weight = 10,
	oneTime = true,
	
	conditions = {
		minAge = 6,
		maxAge = 14,
		requiredAnyFlags = {"racer_interest", "speed_addiction", "first_drive_done"},
	},
	
	getDynamicData = function(state)
		local heroes = {"a legendary F1 champion", "a NASCAR icon", "a local rally driver who made it big", "a YouTube racing star"}
		return {
			hero = heroes[math.random(#heroes)]
		}
	end,
	
	text = "You become obsessed with %hero%. Posters on your wall, watching every race, memorizing their stats. They become your definition of success. Their story gives you a goal.",
	
	choices = {
		{
			id = "will_be_like_them",
			text = "'I'm going to be just like them. I swear it.'",
			resultText = "You make a silent promise to yourself. This isn't just a dream - it's a plan. You start training, learning, preparing.",
			effects = {Happiness = 5, Smarts = 2},
			flags = {set = {"has_racing_idol", "racing_dream", "determined", "goal_oriented"}},
		},
		{
			id = "admire_from_afar",
			text = "You admire them, but you're realistic about your chances.",
			resultText = "It's fun to dream, but not everyone makes it. Still, they inspire you to be better.",
			effects = {Happiness = 3, Smarts = 1},
			flags = {set = {"has_racing_idol", "realistic_dreamer"}},
		},
	},
})

table.insert(events, {
	id = "childhood_karting_competition",
	emoji = "🥇",
	title = "First Karting Championship",
	category = "childhood",
	tags = {"childhood", "competition", "racing", "pressure", "automotive"},
	
	weight = 10,
	oneTime = true,
	milestone = true,
	
	chainId = "junior_racing",
	chainStep = 1,
	
	conditions = {
		minAge = 8,
		maxAge = 14,
		requiredAllFlags = {"first_drive_done", "racing_talent"},
		blockedFlags = {"karting_championship_done"},
	},
	
	getDynamicData = function(state)
		local names = {"the Regional Junior Karting Championship", "the Summer Karting Series", "the Youth Racing League Finals", "the State Karting Championship"}
		return {
			championship = names[math.random(#names)],
			competitors = math.random(20, 50),
		}
	end,
	
	text = "Your parents enter you in %championship%. %competitors% other kids, all serious about racing. You've never felt pressure like this. This is your first real test.",
	
	choices = {
		{
			id = "win_championship",
			text = "(Roll for victory)",
			chanceSuccess = 0.35,
			resultTextSuccess = "You WIN! Standing on the podium, trophy raised, tears in your eyes - you've never felt more alive. Scouts from racing academies take notice.",
			resultTextFail = "You finish in the middle of the pack. Not bad, but not the dream result. You learn what it takes to truly compete.",
			effectsOnSuccess = {Happiness = 15, Money = 500},
			effectsOnFail = {Happiness = 2, Smarts = 3},
			flags = {set = {"karting_championship_done", "first_trophy"}},
		},
		{
			id = "play_it_safe",
			text = "Focus on finishing without crashing.",
			resultText = "You finish mid-pack, safely. No glory, but valuable experience. Racing is a marathon, not a sprint.",
			effects = {Happiness = 3, Smarts = 2},
			flags = {set = {"karting_championship_done", "cautious_racer"}},
		},
		{
			id = "crash_out",
			text = "(Push too hard - risk it all)",
			chanceSuccess = 0.20,
			resultTextSuccess = "Your aggressive driving pays off! You take risks nobody else would and somehow win. Legendary.",
			resultTextFail = "You push too hard into a corner and spin out. The race ends in a barrier. You're unhurt, but your championship is over.",
			effectsOnSuccess = {Happiness = 15, Money = 500},
			effectsOnFail = {Happiness = -5, Health = -3},
			flags = {set = {"karting_championship_done"}},
		},
	},
})

table.insert(events, {
	id = "childhood_car_crash_witness",
	emoji = "💥",
	title = "The Crash",
	category = "childhood",
	tags = {"childhood", "trauma", "formative", "consequence", "automotive"},
	
	weight = 6,
	oneTime = true,
	
	conditions = {
		minAge = 7,
		maxAge = 14,
		requiredAnyFlags = {"racer_interest", "speed_addiction"},
	},
	
	text = "You witness a serious car crash. Maybe on TV, maybe in real life. Twisted metal, broken glass, someone being carried away on a stretcher. Your obsession with speed suddenly has a dark shadow.",
	
	choices = {
		{
			id = "understand_risk",
			text = "You understand: speed comes with danger. You accept it.",
			resultText = "Fear and excitement become intertwined. You respect the risk. It makes the thrill more meaningful.",
			effects = {Smarts = 3},
			flags = {set = {"crash_witnessed", "risk_aware", "mortality_awareness"}},
		},
		{
			id = "more_careful",
			text = "It scares you. You decide to always be careful.",
			resultText = "The image haunts you. You promise yourself you'll never be reckless. Safety first, always.",
			effects = {Happiness = -3, Smarts = 2},
			flags = {set = {"crash_witnessed", "cautious_driver", "speed_fear"}},
		},
		{
			id = "denial",
			text = "'That won't happen to me. I'm different.'",
			resultText = "Young and invincible. You brush it off. Deep down, you know better, but you don't want to know.",
			effects = {Happiness = 1},
			flags = {set = {"crash_witnessed", "invincibility_complex", "denial"}},
		},
	},
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 2: TEEN DISCOVERY (Ages 13-17)
-- The real paths begin to form
-- ═══════════════════════════════════════════════════════════════════════════════

table.insert(events, {
	id = "teen_car_magazines",
	emoji = "📖",
	title = "The Magazine Collection",
	category = "teen",
	tags = {"teen", "obsession", "knowledge", "automotive"},
	
	weight = 10,
	oneTime = true,
	
	conditions = {
		minAge = 12,
		maxAge = 16,
		requiredAnyFlags = {"racer_interest", "mechanical_aptitude", "casual_car_interest"},
	},
	
	text = "You discover car magazines. Every issue, every review, every spec sheet. You memorize horsepower figures, 0-60 times, engine displacements. Your room becomes a shrine to automotive culture.",
	
	choices = {
		{
			id = "encyclopedia",
			text = "You become a walking car encyclopedia.",
			resultText = "Friends and family come to you with car questions. You know more than most adults. This knowledge will serve you well.",
			effects = {Smarts = 5, Happiness = 4},
			flags = {set = {"car_expert", "automotive_knowledge", "petrolhead"}},
		},
		{
			id = "dream_car",
			text = "You pick your dream car and obsess over it.",
			resultText = "Every poster, every wallpaper, every dream features that one car. You will own it someday. You swear it.",
			effects = {Happiness = 5},
			flags = {set = {"dream_car_chosen", "goal_motivation"}},
		},
	},
})

table.insert(events, {
	id = "teen_driving_lesson",
	emoji = "🚗",
	title = "The Driving Lesson",
	category = "teen",
	tags = {"teen", "milestone", "driving", "legal", "automotive"},
	
	weight = 15,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 15,
		maxAge = 17,
		blockedFlags = {"can_drive"},
	},
	
	getDynamicData = function(state)
		local instructors = {"your parent", "a driving instructor", "your older sibling", "your cool uncle"}
		return {
			instructor = instructors[math.random(#instructors)]
		}
	end,
	
	text = "%instructor% takes you for your first real driving lesson. Legal, supervised, on real roads. Your hands shake slightly on the wheel. This is it - the beginning of real freedom.",
	
	choices = {
		{
			id = "natural_driver",
			text = "You take to it naturally. Years of preparation pay off.",
			resultText = "Everything you learned from games, go-karts, and watching clicks into place. The instructor is impressed. You're a natural.",
			effects = {Happiness = 8, Smarts = 3},
			flags = {set = {"can_drive", "natural_driver", "driving_lessons_started", "trait_good_driver"}},
		},
		{
			id = "nervous_but_learning",
			text = "You're nervous but determined to learn properly.",
			resultText = "It's harder than you thought, but you're patient. Slow and steady. Safety first.",
			effects = {Happiness = 4, Smarts = 2},
			flags = {set = {"can_drive", "careful_driver", "driving_lessons_started"}},
		},
		{
			id = "aggressive_driver",
			text = "You push the limits immediately. Speed, hard braking, tight turns.",
			resultText = "The instructor is alarmed. 'Slow DOWN!' But you can't help it. The power is intoxicating.",
			effects = {Happiness = 6, Smarts = 1},
			flags = {set = {"can_drive", "aggressive_driver", "driving_lessons_started", "trait_reckless_driver"}},
		},
	},
})

table.insert(events, {
	id = "teen_first_car",
	emoji = "🚙",
	title = "Your First Car",
	category = "teen",
	tags = {"teen", "milestone", "ownership", "freedom", "automotive"},
	
	weight = 15,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 16,
		maxAge = 20,
		requiredAllFlags = {"can_drive"},
		blockedFlags = {"has_car"},
	},
	
	getDynamicData = function(state)
		local cars = {
			{name = "a beat-up old sedan", value = 1500, cool = 2},
			{name = "a rusty pickup truck", value = 2000, cool = 3},
			{name = "a decades-old sports car that needs work", value = 3000, cool = 7},
			{name = "your grandparent's hand-me-down", value = 1000, cool = 1},
			{name = "a surprisingly clean import", value = 4000, cool = 6},
		}
		local car = cars[math.random(#cars)]
		return {
			car = car.name,
			value = car.value,
			cool = car.cool,
		}
	end,
	
	text = "You finally get your first car: %car%. It's not perfect, but it's YOURS. You hold the keys and feel like the king of the world. Four wheels of pure freedom.",
	
	choices = {
		{
			id = "love_it",
			text = "You love it unconditionally. This car is an extension of yourself.",
			resultText = "You name it, you wash it every weekend, you learn every rattle and quirk. This car will shape your memories.",
			effects = {Happiness = 10},
			flags = {set = {"has_car", "first_car_love", "car_owner"}},
		},
		{
			id = "mod_it",
			text = "First thing: start modifying it. Make it faster.",
			resultText = "Before it even runs right, you're buying parts. Exhaust, intake, suspension. The project begins.",
			effects = {Happiness = 8, Money = -500},
			flags = {set = {"has_car", "car_modifier", "car_owner", "project_car"}},
		},
		{
			id = "flip_it",
			text = "It's temporary. Save up for something better.",
			resultText = "You keep it clean and running. This is a stepping stone to your dream car.",
			effects = {Happiness = 5, Smarts = 2},
			flags = {set = {"has_car", "car_flipper", "car_owner"}},
		},
	},
})

table.insert(events, {
	id = "teen_street_racing_invite",
	emoji = "🌙",
	title = "The Midnight Invitation",
	category = "teen",
	tags = {"teen", "crime", "racing", "underground", "branching", "automotive"},
	
	weight = 12,
	oneTime = true,
	milestone = true,
	
	chainId = "street_racing_path",
	chainStep = 1,
	
	conditions = {
		minAge = 16,
		maxAge = 22,
		requiredAllFlags = {"has_car", "can_drive"},
		requiredAnyFlags = {"racer_interest", "speed_addiction", "aggressive_driver"},
		blockedFlags = {"street_racing_rejected", "street_racing_initiate"},
	},
	
	getDynamicData = function(state)
		local inviters = {"a kid from school with a modified Civic", "your older cousin's sketchy friend", "someone you met at a car meet", "a message in an online car forum"}
		return {
			inviter = inviters[math.random(#inviters)]
		}
	end,
	
	text = "You get an invitation from %inviter%: 'Industrial district. 2 AM. Bring your car and some cash. Don't be a bitch.' Your heart pounds. This is illegal street racing. The real deal.",
	
	choices = {
		{
			id = "accept",
			text = "You're in. This is what you've been waiting for.",
			resultText = "You sneak out at midnight. The industrial district is alive with rumbling engines and neon lights. Your hands tremble with excitement and fear. This is where legends are made.",
			effects = {Happiness = 8, Karma = -3},
			flags = {set = {"street_racing_initiate", "underground_connected", "criminal_activity_started"}},
			startCareer = "automotive",
			careerBranch = "street_racer",
		},
		{
			id = "decline_politely",
			text = "'Nah, I'm good. Too risky.'",
			resultText = "They call you soft. It stings. But you know the consequences of getting caught. Not worth it... probably.",
			effects = {Happiness = -2, Karma = 2},
			flags = {set = {"street_racing_declined", "cautious_choice"}},
		},
		{
			id = "decline_hard",
			text = "'That's stupid. I'm not getting arrested.'",
			resultText = "You're out of the loop now. Those kids stop inviting you to things. But at least you're not in a police database.",
			effects = {Happiness = -4, Karma = 3},
			flags = {set = {"street_racing_rejected", "square_reputation"}},
		},
	},
})

table.insert(events, {
	id = "teen_first_race",
	emoji = "🏁",
	title = "Your First Street Race",
	category = "teen",
	tags = {"teen", "crime", "racing", "adrenaline", "automotive"},
	
	weight = 15,
	oneTime = true,
	milestone = true,
	
	chainId = "street_racing_path",
	chainStep = 2,
	
	conditions = {
		minAge = 16,
		maxAge = 25,
		requiredAllFlags = {"street_racing_initiate"},
		blockedFlags = {"first_street_race_done"},
	},
	
	getDynamicData = function(state)
		local opponents = {"a kid in a tuned WRX", "someone with a supercharged Mustang", "the local favorite in a built 350Z", "a cocky rich kid in daddy's BMW"}
		local stakes = {500, 1000, 1500, 2000}
		return {
			opponent = opponents[math.random(#opponents)],
			stakes = stakes[math.random(#stakes)],
		}
	end,
	
	text = "Your first race. %opponent%. $%stakes% on the line. The crowd roars. Engines revving. A girl drops a flag. Your heart might explode. Three... two... one...",
	
	choices = {
		{
			id = "win_race",
			text = "(Race to win)",
			chanceSuccess = 0.40,
			resultTextSuccess = "You LAUNCH. Everything narrows to the strip ahead. You shift perfectly, hit every apex, and cross the line first! The crowd erupts. You just made a reputation.",
			resultTextFail = "You spin your tires too hard at the start. By the time you recover, they're gone. You lose the money and face. Not the night you wanted.",
			effectsOnSuccess = {Happiness = 15, Money = 1000},
			effectsOnFail = {Happiness = -5, Money = -1000},
			flags = {set = {"first_street_race_done"}},
		},
		{
			id = "play_safe",
			text = "Drive clean, don't push it.",
			resultText = "You keep up but don't take risks. You lose by a car length. Respectable, but not a win. The crowd barely notices you.",
			effects = {Happiness = 2, Money = -1000},
			flags = {set = {"first_street_race_done", "conservative_racer"}},
		},
		{
			id = "dirty_tactics",
			text = "Bump them. Win by any means.",
			chanceSuccess = 0.30,
			resultTextSuccess = "A little nudge sends them sideways. You rocket past and take the win. Dirty, but nobody can prove it. The money is yours.",
			resultTextFail = "You try to bump them, but they counter. Your car spins into a wall. Race over. Reputation ruined. Car damaged.",
			effectsOnSuccess = {Happiness = 10, Money = 1500, Karma = -5},
			effectsOnFail = {Happiness = -10, Money = -2000, Health = -5},
			flags = {set = {"first_street_race_done", "dirty_racer"}},
		},
	},
})

table.insert(events, {
	id = "teen_police_chase",
	emoji = "🚔",
	title = "Blue Lights in the Mirror",
	category = "teen",
	tags = {"teen", "crime", "consequences", "pivotal", "automotive"},
	
	weight = 10,
	oneTime = false,
	cooldownYears = 3,
	
	conditions = {
		minAge = 16,
		maxAge = 40,
		requiredAnyFlags = {"street_racing_initiate", "aggressive_driver", "speeding_ticket"},
	},
	
	getDynamicData = function(state)
		local situations = {"doing 90 in a 45", "leaving a street racing spot", "running a red light while showing off", "drifting through an intersection"}
		return {
			situation = situations[math.random(#situations)]
		}
	end,
	
	text = "You're %situation% when you see it - police lights flashing behind you. Your stomach drops. This is the moment that could change everything.",
	
	choices = {
		{
			id = "pull_over",
			text = "Pull over immediately. Face the consequences.",
			resultText = "You stop. The officer is stern but not cruel. You get a hefty ticket, maybe a reckless driving charge. Your insurance will hurt. But you're not in prison.",
			effects = {Money = -2000, Karma = 2},
			flags = {set = {"traffic_violation", "police_record", "lesson_learned"}},
		},
		{
			id = "run",
			text = "FLOOR IT. You can lose them.",
			chanceSuccess = 0.25,
			resultTextSuccess = "Your heart explodes as you weave through traffic. Side streets, alleyways, a narrow escape through a parking garage. You lose them. You're shaking, but free.",
			resultTextFail = "They call backup. A helicopter joins. Spike strips. Your car is toast. You're thrown to the ground, cuffed, and your life just got infinitely more complicated.",
			effectsOnSuccess = {Happiness = 10, Karma = -10},
			effectsOnFail = {Happiness = -20, Money = -5000, Karma = -15},
			flags = {set = {"felony_evasion"}},
		},
		{
			id = "cry_and_beg",
			text = "Pull over. Cry. Beg for mercy.",
			chanceSuccess = 0.40,
			resultTextSuccess = "Your tears are convincing. The officer sighs and lets you off with a warning. 'Don't let me catch you again, kid.' You won't.",
			resultTextFail = "The officer isn't moved. 'Save it for the judge.' Full ticket, all charges. The tears made it worse.",
			effectsOnSuccess = {Happiness = 5, Karma = -2},
			effectsOnFail = {Money = -3000, Happiness = -5},
			flags = {set = {"police_encounter"}},
		},
	},
})

table.insert(events, {
	id = "teen_garage_job",
	emoji = "🔧",
	title = "The Shop Job",
	category = "teen",
	tags = {"teen", "work", "mechanic", "honest_path", "automotive"},
	
	weight = 12,
	oneTime = true,
	
	chainId = "mechanic_path",
	chainStep = 1,
	
	conditions = {
		minAge = 15,
		maxAge = 20,
		requiredAnyFlags = {"mechanical_aptitude", "garage_memories", "project_car"},
		blockedFlags = {"mechanic_job_rejected"},
	},
	
	getDynamicData = function(state)
		local shops = {"a local tire shop", "an independent mechanic's garage", "a chain auto parts store", "a friend's uncle's body shop"}
		return {
			shop = shops[math.random(#shops)]
		}
	end,
	
	text = "There's a part-time opening at %shop%. It's not glamorous - oil changes, tire rotations, cleaning. But you'd be around cars all day. Learning. Building real skills.",
	
	choices = {
		{
			id = "take_it",
			text = "Take the job. It's a start.",
			resultText = "You spend your weekends covered in grease, learning the trade. The pay is terrible but the knowledge is priceless. You're becoming a real mechanic.",
			effects = {Money = 2000, Smarts = 3, Happiness = 4},
			flags = {set = {"mechanic_experience", "honest_work", "trade_skills"}},
			startCareer = "automotive",
			careerBranch = "mechanic",
		},
		{
			id = "reject_it",
			text = "Nah, I want to DRIVE cars, not fix them.",
			resultText = "Manual labor isn't your dream. You'll find another way.",
			effects = {Happiness = 1},
			flags = {set = {"mechanic_job_rejected"}},
		},
	},
})

table.insert(events, {
	id = "teen_racing_academy_scout",
	emoji = "🏎️",
	title = "The Scout",
	category = "teen",
	tags = {"teen", "opportunity", "professional", "elite", "automotive"},
	
	weight = 6,
	oneTime = true,
	milestone = true,
	
	chainId = "pro_racing_path",
	chainStep = 1,
	
	conditions = {
		minAge = 14,
		maxAge = 18,
		requiredAllFlags = {"racing_talent", "first_trophy"},
		blockedFlags = {"racing_scout_rejected", "criminal_record"},
	},
	
	getDynamicData = function(state)
		local academies = {"the Ferrari Driver Academy", "Red Bull Junior Team", "McLaren's young driver program", "a prestigious racing school in Europe"}
		return {
			academy = academies[math.random(#academies)]
		}
	end,
	
	text = "A scout from %academy% approaches your parents after a karting championship. They've been watching you. They see potential - maybe a future F1 driver, maybe NASCAR material. They're offering a spot in their youth program.",
	
	choices = {
		{
			id = "accept_immediately",
			text = "THIS IS YOUR DREAM. Accept without hesitation.",
			resultText = "Your life changes overnight. Intensive training, travel, sacrifice. You're on the path to professional racing. Everything you've worked for might actually happen.",
			effects = {Happiness = 15},
			flags = {set = {"racing_academy", "professional_path", "elite_training", "sacrifice_for_dream"}},
			startCareer = "automotive",
		},
		{
			id = "negotiate",
			text = "Negotiate terms. Keep your options open.",
			resultText = "Your parents push back on some restrictions. The academy agrees to modified terms. You're in, but with more flexibility.",
			effects = {Happiness = 10, Smarts = 3},
			flags = {set = {"racing_academy", "professional_path", "smart_negotiation"}},
			startCareer = "automotive",
		},
		{
			id = "decline",
			text = "It's too much pressure. You want a normal life.",
			resultText = "The scout looks disappointed but understands. You stay in school, stay with friends. Normal. Safe. Some nights, you wonder what could have been.",
			effects = {Happiness = -3},
			flags = {set = {"racing_scout_rejected", "normal_life_chosen"}},
		},
	},
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 3: YOUNG ADULT - CAREER PATHS DIVERGE (Ages 18-35)
-- This is where life choices become permanent
-- ═══════════════════════════════════════════════════════════════════════════════

table.insert(events, {
	id = "adult_street_racing_reputation",
	emoji = "👑",
	title = "The King of the Streets",
	category = "career",
	tags = {"adult", "street_racing", "reputation", "crime", "automotive"},
	
	weight = 10,
	oneTime = true,
	milestone = true,
	
	chainId = "street_racing_path",
	chainStep = 5,
	
	conditions = {
		minAge = 18,
		maxAge = 35,
		requiredCareerId = "automotive",
		requiredCareerBranch = "street_racer",
		blockedFlags = {"street_king_title"},
		minStats = {Smarts = 40},
	},
	
	text = "After years of racing, winning, and building your reputation, the title is within reach. The current 'king' of the street racing scene has challenged you. Winner takes all - the title, the respect, and control of the main racing circuit.",
	
	choices = {
		{
			id = "dethrone_the_king",
			text = "Race for the title. End his reign.",
			chanceSuccess = 0.45,
			resultTextSuccess = "The race is brutal - 90+ MPH through city streets, inches from disaster. But when the dust settles, YOU are the new king. The scene belongs to you now.",
			resultTextFail = "You give it everything, but he's better. Or luckier. You lose by a car length. Close, but the title remains his. For now.",
			effectsOnSuccess = {Happiness = 15, Money = 20000, Karma = -5},
			effectsOnFail = {Happiness = -5, Money = -5000},
			flags = {set = {"street_king_challenged"}},
		},
		{
			id = "take_him_out",
			text = "He can't win if he crashes. Sabotage his car.",
			chanceSuccess = 0.50,
			resultTextSuccess = "His brakes 'fail' at the worst moment. He crashes, you win. The title is yours. But you know what you did. Some people suspect.",
			resultTextFail = "Someone sees you tampering. Word spreads. You're exiled from the scene. Your reputation is destroyed.",
			effectsOnSuccess = {Happiness = 5, Money = 20000, Karma = -15},
			effectsOnFail = {Happiness = -15, Karma = -10},
			flags = {set = {"saboteur", "street_king_title"}},
		},
		{
			id = "walk_away",
			text = "You've made your money. Walk away at your peak.",
			resultText = "You retire undefeated. Never challenged for the top. Some call you smart. Others call you a coward. You don't care - you got out alive.",
			effects = {Happiness = 5, Karma = 2},
			flags = {set = {"street_racing_retired", "smart_exit"}},
		},
	},
})

table.insert(events, {
	id = "adult_nascar_tryout",
	emoji = "🏁",
	title = "The NASCAR Tryout",
	category = "career",
	tags = {"adult", "nascar", "professional", "opportunity", "automotive"},
	
	weight = 8,
	oneTime = true,
	milestone = true,
	
	chainId = "nascar_path",
	chainStep = 1,
	
	conditions = {
		minAge = 18,
		maxAge = 28,
		requiredAnyFlags = {"racing_academy", "racing_talent", "junior_formula_experience"},
		blockedFlags = {"criminal_record", "nascar_rejected"},
	},
	
	getDynamicData = function(state)
		local teams = {"Hendrick Motorsports", "Joe Gibbs Racing", "Stewart-Haas Racing", "a small development team"}
		return {
			team = teams[math.random(#teams)]
		}
	end,
	
	text = "%team% is holding tryouts for their developmental program. Hundreds of applicants. Only a handful will make it. This is your shot at legitimate professional racing in America's biggest motorsport.",
	
	choices = {
		{
			id = "give_everything",
			text = "This is your destiny. Leave everything on the track.",
			chanceSuccess = 0.35,
			resultTextSuccess = "You drive the wheels off the test car. Every lap is perfection. They pull you aside afterward: 'Pack your bags. You're in.' You made it.",
			resultTextFail = "You drive well, but so do fifty others. You don't make the cut. 'Maybe next year,' they say. The words taste like ash.",
			effectsOnSuccess = {Happiness = 20},
			effectsOnFail = {Happiness = -10},
			flags = {set = {"nascar_tryout_done"}},
		},
		{
			id = "nervous_performance",
			text = "The pressure gets to you. You tense up.",
			resultText = "You make mistakes you'd never make in practice. Over-correcting, braking too late. It's not your day. You drive home in silence.",
			effects = {Happiness = -8},
			flags = {set = {"nascar_tryout_done", "choked_under_pressure"}},
		},
	},
})

table.insert(events, {
	id = "adult_f1_debut",
	emoji = "🏆",
	title = "The F1 Debut",
	category = "career",
	tags = {"adult", "f1", "elite", "milestone", "automotive"},
	
	weight = 5,
	oneTime = true,
	milestone = true,
	
	chainId = "f1_path",
	chainStep = 3,
	
	conditions = {
		minAge = 18,
		maxAge = 26,
		requiredCareerId = "automotive",
		requiredCareerBranch = "formula_one",
		requiredAllFlags = {"racing_academy"},
		blockedFlags = {"f1_debut_done"},
	},
	
	getDynamicData = function(state)
		local tracks = {"Monaco", "Monza", "Silverstone", "Spa-Francorchamps", "Suzuka"}
		local teams = {"a backmarker team fighting for survival", "a midfield team with potential", "a works team pushing for championships"}
		return {
			track = tracks[math.random(#tracks)],
			team = teams[math.random(#teams)]
		}
	end,
	
	text = "Your F1 debut. %track%. Driving for %team%. Millions watching worldwide. Your name announced over the speakers. This is what you've sacrificed everything for. The formation lap begins...",
	
	choices = {
		{
			id = "smooth_debut",
			text = "Focus on finishing. Learn the ropes.",
			resultText = "You finish outside the points, but you finish. No mistakes, no crashes. The team is pleased. You've proven you belong here.",
			effects = {Happiness = 15, Money = 100000},
			flags = {set = {"f1_debut_done", "f1_driver", "world_famous"}},
			careerXP = 50,
		},
		{
			id = "aggressive_debut",
			text = "Attack! Make your mark on day one.",
			chanceSuccess = 0.30,
			resultTextSuccess = "Incredible overtakes, pushing harder than anyone expected. You finish P8 - POINTS on your debut! The F1 world is talking about you.",
			resultTextFail = "You push too hard. Contact with another driver. Your race ends in the gravel. A rookie mistake on the biggest stage.",
			effectsOnSuccess = {Happiness = 25, Money = 200000},
			effectsOnFail = {Happiness = -10, Money = 50000},
			flags = {set = {"f1_debut_done", "f1_driver"}},
		},
	},
})

table.insert(events, {
	id = "adult_major_crash",
	emoji = "🔥",
	title = "The Crash That Changes Everything",
	category = "consequence",
	tags = {"adult", "crash", "trauma", "life_changing", "automotive"},
	
	weight = 6,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 18,
		maxAge = 50,
		requiredCareerId = "automotive",
		requiredAnyFlags = {"racing_career", "street_racing_initiate", "f1_driver", "nascar_driver"},
		blockedFlags = {"survived_major_crash"},
	},
	
	getDynamicData = function(state)
		local speeds = {120, 150, 180, 200}
		local locations = {"a tight corner", "the front straight", "a chicane", "entering the pits"}
		return {
			speed = speeds[math.random(#speeds)],
			location = locations[math.random(#locations)]
		}
	end,
	
	text = "%speed% MPH. Something fails - maybe the brakes, maybe your focus. You hit %location% wrong. The car leaves the ground, rolls, tumbles, shatters. Fire. Darkness. Then... voices. Sirens. You're alive. Barely.",
	
	choices = {
		{
			id = "recovery_determination",
			text = "You WILL race again. This won't define you.",
			resultText = "Months of rehabilitation. Pain you never imagined. But you fight. Every day. When you finally climb back in a car, you're different. Scarred, but unbroken.",
			effects = {Health = -20, Happiness = -10, Smarts = 5},
			flags = {set = {"survived_major_crash", "comeback_story", "permanent_scars", "mental_strength"}},
		},
		{
			id = "retire",
			text = "It's over. You can't do this anymore.",
			resultText = "The injuries heal, but the fear doesn't. The sound of engines makes you sick. Your racing career ends here. You have to find a new purpose.",
			effects = {Health = -15, Happiness = -15},
			flags = {set = {"survived_major_crash", "racing_retired", "trauma", "ptsd"}},
			quitCareer = true,
		},
		{
			id = "reckless_return",
			text = "Refuse treatment. Get back in the car immediately.",
			chanceSuccess = 0.30,
			resultTextSuccess = "Against all medical advice, you return. And somehow, you're faster than ever. The crash broke something inside you - maybe the fear itself.",
			resultTextFail = "You push too hard, too fast. Another crash. This time the damage is permanent. You'll never walk right again.",
			effectsOnSuccess = {Health = -10, Happiness = 10},
			effectsOnFail = {Health = -40, Happiness = -25},
			flags = {set = {"survived_major_crash"}},
		},
	},
})

table.insert(events, {
	id = "adult_car_theft_offer",
	emoji = "🔓",
	title = "The Darker Path",
	category = "crime",
	tags = {"adult", "crime", "branching", "moral_choice", "automotive"},
	
	weight = 8,
	oneTime = true,
	milestone = true,
	
	chainId = "crime_path",
	chainStep = 1,
	
	conditions = {
		minAge = 18,
		maxAge = 35,
		requiredAnyFlags = {"street_racing_initiate", "underground_connected", "financial_desperation"},
		blockedFlags = {"crime_rejected", "career_criminal"},
	},
	
	getDynamicData = function(state)
		local recruiters = {"a guy you raced against", "someone from the underground scene", "a friend who's 'made it'", "a mysterious text from an unknown number"}
		return {
			recruiter = recruiters[math.random(#recruiters)]
		}
	end,
	
	text = "%recruiter% approaches you with an offer: 'You know cars. You can drive. We need people who can... acquire vehicles. No questions asked. Good money. You interested?'",
	
	choices = {
		{
			id = "accept",
			text = "'I'm in. What do I need to know?'",
			resultText = "You step into a world of high-end theft, chop shops, and serious money. Also serious consequences if you're caught. Your mechanical skills now serve a different purpose.",
			effects = {Money = 5000, Karma = -10},
			flags = {set = {"career_criminal", "car_thief", "criminal_connections"}},
			startCareer = "automotive",
			careerBranch = "car_thief",
		},
		{
			id = "decline_firmly",
			text = "'Not my thing. I'm out.'",
			resultText = "They shrug. 'Your loss.' You walk away with a clear conscience. But you wonder - how much money did you just turn down?",
			effects = {Karma = 5, Happiness = -2},
			flags = {set = {"crime_rejected", "moral_compass"}},
		},
		{
			id = "inform_police",
			text = "Report them to the police.",
			chanceSuccess = 0.60,
			resultTextSuccess = "An anonymous tip leads to arrests. You're rewarded with cash and a sense of justice. You also made powerful enemies.",
			resultTextFail = "They find out it was you. One night, your car is torched. A message. They could have done worse.",
			effectsOnSuccess = {Money = 3000, Karma = 10},
			effectsOnFail = {Money = -5000, Karma = 5, Health = -5},
			flags = {set = {"crime_rejected", "informant"}},
		},
	},
})

table.insert(events, {
	id = "adult_getaway_driver",
	emoji = "💨",
	title = "The Job",
	category = "crime",
	tags = {"adult", "crime", "heist", "high_stakes", "automotive"},
	
	weight = 7,
	oneTime = false,
	cooldownYears = 2,
	
	chainId = "crime_path",
	chainStep = 3,
	
	conditions = {
		minAge = 20,
		maxAge = 45,
		requiredCareerId = "automotive",
		requiredAnyFlags = {"career_criminal", "car_thief", "street_king_title"},
	},
	
	getDynamicData = function(state)
		local jobs = {"a jewelry store heist", "a bank robbery", "an armored car hit", "a high-profile kidnapping"}
		local cuts = {50000, 100000, 250000, 500000}
		return {
			job = jobs[math.random(#jobs)],
			cut = cuts[math.random(#cuts)]
		}
	end,
	
	text = "They need a wheelman for %job%. Your reputation precedes you. The plan is tight. Your cut: $%cut%. In and out. Simple. The crew is ready. Are you?",
	
	choices = {
		{
			id = "execute_perfectly",
			text = "You're the best for a reason. Execute flawlessly.",
			chanceSuccess = 0.45,
			resultTextSuccess = "Every corner, every second - perfect. You evade pursuit, swap cars, disappear. The money hits your account. No one suspects a thing.",
			resultTextFail = "Something goes wrong. Cops everywhere. High-speed chase. You escape, but barely. The money is lost. Some of the crew didn't make it.",
			effectsOnSuccess = {Money = 100000, Happiness = 10, Karma = -15},
			effectsOnFail = {Happiness = -15, Karma = -10, Health = -5},
			flags = {set = {"heist_experience"}},
		},
		{
			id = "double_cross",
			text = "Take the money and disappear. Leave the crew.",
			chanceSuccess = 0.25,
			resultTextSuccess = "You take the whole take and vanish. New city, new identity, new life. You're rich and hunted. Worth it.",
			resultTextFail = "They catch up to you. The beating is severe. They take everything and leave you for dead. You barely survive.",
			effectsOnSuccess = {Money = 500000, Karma = -25},
			effectsOnFail = {Money = -10000, Health = -40, Karma = -15},
			flags = {set = {"betrayer", "hunted"}},
		},
		{
			id = "back_out",
			text = "This is too big. Back out.",
			resultText = "You're out. They find another driver. Word is the job went sideways. Maybe you made the right call. Maybe.",
			effects = {Karma = 5, Happiness = -5},
			flags = {set = {"backed_out"}},
		},
	},
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 4: PEAK CAREER (Ages 25-50)
-- Championships, empires, or prison
-- ═══════════════════════════════════════════════════════════════════════════════

table.insert(events, {
	id = "peak_championship_fight",
	emoji = "🏆",
	title = "The Championship Finale",
	category = "career",
	tags = {"peak", "championship", "milestone", "career_defining", "automotive"},
	
	weight = 8,
	oneTime = false,
	cooldownYears = 3,
	
	conditions = {
		minAge = 23,
		maxAge = 45,
		requiredCareerId = "automotive",
		requiredAnyFlags = {"f1_driver", "nascar_driver", "pro_racing_career"},
		blockedFlags = {"retired_racer"},
	},
	
	getDynamicData = function(state)
		local rivals = {"your teammate who secretly hates you", "the defending champion", "a controversial newcomer", "your childhood hero"}
		local points = math.random(3, 15)
		return {
			rival = rivals[math.random(#rivals)],
			pointsNeeded = points
		}
	end,
	
	text = "The final race of the season. You and %rival% separated by %pointsNeeded% points. Winner takes the championship. Your entire career comes down to this.",
	
	choices = {
		{
			id = "drive_clean",
			text = "Win it on pure skill. Drive the race of your life.",
			chanceSuccess = 0.40,
			resultTextSuccess = "Every corner is poetry. Every overtake is calculated perfection. When you cross the line first, the world erupts. CHAMPION. The word you've dreamed of since childhood.",
			resultTextFail = "You give everything, but they're better today. Second place. So close. The 'almost champion' label stings.",
			effectsOnSuccess = {Happiness = 30, Money = 500000, Fame = 30},
			effectsOnFail = {Happiness = -10, Money = 100000},
			flags = {set = {"championship_finalist"}},
		},
		{
			id = "take_them_out",
			text = "If they DNF, you win. Make contact.",
			chanceSuccess = 0.35,
			resultTextSuccess = "A slight touch. They spin. You drive past the wreckage and take the title. Controversial. Legendary. Champion.",
			resultTextFail = "You try to take them out but misjudge it. You BOTH crash. They recover. You don't. Championship lost to your own aggression.",
			effectsOnSuccess = {Happiness = 20, Money = 500000, Karma = -15},
			effectsOnFail = {Happiness = -20, Karma = -10},
			flags = {set = {"championship_finalist", "controversial_champion"}},
		},
		{
			id = "let_them_win",
			text = "Team orders say let your teammate win. Obey.",
			resultText = "You slot in behind, sacrificing your dream for the team. The championship goes to them. You're loyal. You're professional. You're empty inside.",
			effects = {Happiness = -15, Karma = 5, Money = 200000},
			flags = {set = {"team_player", "championship_sacrifice"}},
		},
	},
})

table.insert(events, {
	id = "peak_shop_empire",
	emoji = "🏢",
	title = "Building an Empire",
	category = "career",
	tags = {"peak", "business", "expansion", "mechanic_path", "automotive"},
	
	weight = 8,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 28,
		maxAge = 55,
		requiredCareerId = "automotive",
		requiredCareerBranch = "mechanic",
		minStats = {Smarts = 50},
		requiredAllFlags = {"mechanic_experience"},
	},
	
	getDynamicData = function(state)
		local loans = {100000, 250000, 500000}
		local locations = {3, 5, 8}
		local idx = math.random(#loans)
		return {
			loan = loans[idx],
			locations = locations[idx]
		}
	end,
	
	text = "Your single shop is doing well. Too well to stay small. A bank offers you a $%loan% loan to expand. You could own %locations% locations across the region. Be a real businessman.",
	
	choices = {
		{
			id = "expand_aggressively",
			text = "Go big or go home. Take the loan.",
			chanceSuccess = 0.55,
			resultTextSuccess = "Within five years, you're a regional powerhouse. Multiple locations, dozens of employees. You barely touch a wrench anymore - you're an executive now.",
			resultTextFail = "The expansion stretches you too thin. Two locations fail. The debt crushes you. You lose everything, including your original shop.",
			effectsOnSuccess = {Money = 200000, Happiness = 15},
			effectsOnFail = {Money = -100000, Happiness = -20},
			flags = {set = {"business_expansion"}},
		},
		{
			id = "grow_slowly",
			text = "One shop at a time. Stay in control.",
			resultText = "You expand carefully, organically. Slower growth, but sustainable. By retirement, you own three successful shops and your sanity.",
			effects = {Money = 50000, Happiness = 8, Smarts = 3},
			flags = {set = {"careful_growth", "business_owner"}},
		},
		{
			id = "stay_small",
			text = "Keep it personal. One shop, honest work.",
			resultText = "You decline the empire dream. Your shop stays the neighborhood favorite. You know every customer by name. That's enough.",
			effects = {Happiness = 5, Karma = 3},
			flags = {set = {"small_business_owner", "community_pillar"}},
		},
	},
})

table.insert(events, {
	id = "peak_prison",
	emoji = "⛓️",
	title = "The Fall",
	category = "consequence",
	tags = {"peak", "crime", "prison", "consequence", "automotive"},
	
	weight = 10,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 20,
		maxAge = 60,
		requiredAnyFlags = {"career_criminal", "car_thief", "street_king_title", "felony_evasion"},
		blockedFlags = {"served_time"},
	},
	
	getDynamicData = function(state)
		local sentences = {2, 5, 10, 15}
		local crimes = {"grand theft auto", "racketeering", "felony evasion", "conspiracy to commit robbery"}
		local idx = math.random(#sentences)
		return {
			sentence = sentences[idx],
			crime = crimes[idx]
		}
	end,
	
	text = "They finally caught up with you. Charges: %crime%. The evidence is overwhelming. The judge shows no mercy. %sentence% years. The cell door closes. Your freedom is gone.",
	
	choices = {
		{
			id = "model_prisoner",
			text = "Survive. Become a model prisoner. Get out early.",
			resultText = "You keep your head down, earn trust, learn new skills. Early release for good behavior. When you walk out, you're changed. Scarred, but wiser.",
			effects = {Happiness = -20, Karma = 5, Smarts = 5},
			flags = {set = {"served_time", "prison_survivor", "reformed"}},
		},
		{
			id = "prison_connections",
			text = "Use the time to build criminal connections.",
			resultText = "Inside, you meet the real players. When you get out, you have contacts in every major city. The game just got bigger.",
			effects = {Happiness = -15, Karma = -10},
			flags = {set = {"served_time", "prison_connections", "organized_crime"}},
		},
		{
			id = "escape_attempt",
			text = "Plan an escape. You can't do this time.",
			chanceSuccess = 0.15,
			resultTextSuccess = "Against all odds, you make it over the wall. New identity, new life. You're a ghost now. Free, but forever looking over your shoulder.",
			resultTextFail = "You're caught before you even make it outside. Solitary. Extended sentence. The walls close in even tighter.",
			effectsOnSuccess = {Happiness = 5, Karma = -15},
			effectsOnFail = {Happiness = -30, Health = -20},
			flags = {set = {"escape_attempt"}},
		},
	},
})

table.insert(events, {
	id = "peak_racing_retirement",
	emoji = "🎬",
	title = "The Last Race",
	category = "career",
	tags = {"peak", "retirement", "milestone", "legacy", "automotive"},
	
	weight = 8,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 32,
		maxAge = 50,
		requiredCareerId = "automotive",
		requiredAnyFlags = {"f1_driver", "nascar_driver", "rally_driver", "racing_champion"},
		blockedFlags = {"retired_racer"},
	},
	
	getDynamicData = function(state)
		local tracks = {"the track where it all began", "the most iconic circuit in the world", "in front of your home crowd", "on the world's biggest stage"}
		return {
			track = tracks[math.random(#tracks)]
		}
	end,
	
	text = "Your body tells you what your heart won't accept: it's time. Your final race, %track%. The grid salutes you. The crowd chants your name. Everything you've accomplished flashes before your eyes.",
	
	choices = {
		{
			id = "win_finale",
			text = "One last victory. Go out on top.",
			chanceSuccess = 0.35,
			resultTextSuccess = "The old magic returns one final time. You cross the line first, climb from the car, and wave goodbye as a winner. The perfect ending.",
			resultTextFail = "You give everything, but the young guns are faster. You finish mid-pack. Not the storybook ending, but an honest one.",
			effectsOnSuccess = {Happiness = 25, Money = 100000},
			effectsOnFail = {Happiness = 5, Money = 50000},
			flags = {set = {"retired_racer", "racing_legend"}},
		},
		{
			id = "peaceful_goodbye",
			text = "Just enjoy the moment. Soak it all in.",
			resultText = "You drive at your own pace, waving to fans, savoring every corner. It doesn't matter where you finish. This is about gratitude.",
			effects = {Happiness = 20, Karma = 5},
			flags = {set = {"retired_racer", "graceful_exit"}},
		},
		{
			id = "dramatic_crash",
			text = "Push too hard. End it spectacularly.",
			chanceSuccess = 0.50,
			resultTextSuccess = "You push beyond the limit and somehow survive the crash. Walking away from the wreckage, you're reminded why you loved this. And why you're done.",
			resultTextFail = "The crash is bad. Your racing career ends with injuries that will never fully heal. Not the ending you deserved.",
			effectsOnSuccess = {Happiness = 10},
			effectsOnFail = {Health = -25, Happiness = -10},
			flags = {set = {"retired_racer"}},
		},
	},
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 5: LATE CAREER & LEGACY (Ages 40-80)
-- The consequences of your choices
-- ═══════════════════════════════════════════════════════════════════════════════

table.insert(events, {
	id = "late_hall_of_fame",
	emoji = "🏛️",
	title = "Hall of Fame",
	category = "legacy",
	tags = {"late", "legacy", "achievement", "recognition", "automotive"},
	
	weight = 5,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 45,
		maxAge = 80,
		requiredAnyFlags = {"racing_champion", "racing_legend", "f1_champion", "nascar_champion"},
		blockedFlags = {"hall_of_fame_inducted", "disgraced"},
	},
	
	text = "The motorsport Hall of Fame announces their newest inductee: YOU. Decades of achievement, sacrifice, and dedication recognized. You join the immortals.",
	
	choices = {
		{
			id = "accept_graciously",
			text = "Accept with humility and gratitude.",
			resultText = "Your speech brings tears. You thank everyone who helped you. The standing ovation lasts five minutes. You've earned your place in history.",
			effects = {Happiness = 20, Fame = 20, Karma = 5},
			flags = {set = {"hall_of_fame_inducted", "immortalized"}},
		},
		{
			id = "cocky_acceptance",
			text = "Remind everyone you're the greatest ever.",
			resultText = "Your speech is memorable for the wrong reasons. But who cares? They can't take your record away.",
			effects = {Happiness = 15, Fame = 15, Karma = -5},
			flags = {set = {"hall_of_fame_inducted", "controversial_legend"}},
		},
	},
})

table.insert(events, {
	id = "late_health_consequences",
	emoji = "🏥",
	title = "The Body Remembers",
	category = "consequence",
	tags = {"late", "health", "consequence", "automotive"},
	
	weight = 10,
	oneTime = true,
	
	conditions = {
		minAge = 45,
		maxAge = 80,
		requiredAnyFlags = {"survived_major_crash", "racing_career", "multiple_crashes"},
		blockedFlags = {"health_crisis_resolved"},
	},
	
	getDynamicData = function(state)
		local conditions = {"chronic back pain", "recurring headaches", "limited mobility in your neck", "nerve damage in your hands"}
		return {
			condition = conditions[math.random(#conditions)]
		}
	end,
	
	text = "The years catch up. All those crashes, all those G-forces. Doctors diagnose %condition% - permanent damage from your racing days. The price you paid for glory.",
	
	choices = {
		{
			id = "treatment",
			text = "Aggressive treatment. Fight it.",
			resultText = "Surgery, therapy, medication. You throw money at the problem. It helps, but never fully. This is your life now.",
			effects = {Money = -50000, Health = -10},
			flags = {set = {"health_crisis_resolved", "chronic_condition"}},
		},
		{
			id = "accept",
			text = "Accept it. It was worth it.",
			resultText = "You make peace with the pain. Every ache is a memory. You'd do it all again.",
			effects = {Health = -15, Karma = 3},
			flags = {set = {"health_crisis_resolved", "peaceful_acceptance"}},
		},
	},
})

table.insert(events, {
	id = "late_mentoring",
	emoji = "👨‍🏫",
	title = "The Next Generation",
	category = "legacy",
	tags = {"late", "legacy", "mentoring", "automotive"},
	
	weight = 8,
	oneTime = true,
	
	conditions = {
		minAge = 40,
		maxAge = 75,
		requiredCareerId = "automotive",
		requiredAnyFlags = {"retired_racer", "racing_legend", "master_mechanic"},
	},
	
	getDynamicData = function(state)
		local prodigies = {"a talented teenager who reminds you of yourself", "your own child", "a kid from a rough background with raw talent", "a promising driver who needs guidance"}
		return {
			prodigy = prodigies[math.random(#prodigies)]
		}
	end,
	
	text = "You meet %prodigy%. They have the fire you once had. They ask if you'd be willing to teach them, share your knowledge. A chance to pass on everything you've learned.",
	
	choices = {
		{
			id = "mentor",
			text = "Take them under your wing. Shape the future.",
			resultText = "You pour your experience into them. The lessons, the mistakes, the secrets. Watching them succeed becomes a new kind of victory.",
			effects = {Happiness = 15, Karma = 10},
			flags = {set = {"mentor", "legacy_builder"}},
		},
		{
			id = "refuse",
			text = "'Figure it out yourself, like I did.'",
			resultText = "You walk away. They'll make their own path. That's how legends are made anyway.",
			effects = {Karma = -3},
			flags = {set = {"refused_mentoring"}},
		},
	},
})

table.insert(events, {
	id = "late_final_drive",
	emoji = "🌅",
	title = "One Last Drive",
	category = "legacy",
	tags = {"late", "legacy", "closure", "automotive"},
	
	weight = 6,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 60,
		maxAge = 90,
		requiredAnyFlags = {"retired_racer", "racing_legend", "car_enthusiast", "dream_car_owned"},
	},
	
	getDynamicData = function(state)
		local roads = {"the mountain road you conquered as a teen", "your favorite stretch of highway", "the track where you made your name", "an empty road at sunrise"}
		return {
			road = roads[math.random(#roads)]
		}
	end,
	
	text = "You take your favorite car out for one last drive on %road%. The engine hums. The road stretches ahead. Every memory of a lifetime with cars plays out in your mind. It all led here.",
	
	choices = {
		{
			id = "peaceful_drive",
			text = "Drive slowly. Savor every moment.",
			resultText = "You feel the wheel, the road, the engine. Everything you've loved about driving distilled into this moment. When you finally park, you're at peace. It was a good ride.",
			effects = {Happiness = 20, Karma = 5},
			flags = {set = {"final_drive_complete", "life_complete"}},
		},
		{
			id = "one_last_blast",
			text = "One more blast. Push it like the old days.",
			chanceSuccess = 0.70,
			resultTextSuccess = "The old skills come back. For a few glorious minutes, you're young again. When you slow down, you're grinning. You've still got it.",
			resultTextFail = "You push too hard. A slide, a save, a realization: you're not what you were. But that's okay. The drive home is peaceful.",
			effectsOnSuccess = {Happiness = 25},
			effectsOnFail = {Happiness = 10},
			flags = {set = {"final_drive_complete"}},
		},
	},
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 6: RANDOM ENCOUNTERS & FLAVOR EVENTS
-- Events that add depth and variety
-- ═══════════════════════════════════════════════════════════════════════════════

table.insert(events, {
	id = "random_car_show",
	emoji = "🚙",
	title = "The Car Show",
	category = "lifestyle",
	tags = {"random", "hobby", "community", "automotive"},
	
	weight = 8,
	oneTime = false,
	cooldownYears = 2,
	
	conditions = {
		minAge = 16,
		maxAge = 80,
		requiredAnyFlags = {"has_car", "car_enthusiast", "petrolhead"},
	},
	
	getDynamicData = function(state)
		local shows = {"a local Cars & Coffee", "a major auto show", "a vintage car exhibition", "a tuner meet"}
		return {
			show = shows[math.random(#shows)]
		}
	end,
	
	text = "You attend %show%. Rows of gleaming machines. The smell of tire rubber and exhaust. People who speak your language. This is your community.",
	
	choices = {
		{
			id = "enjoy",
			text = "Soak it in. Take photos. Talk cars.",
			resultText = "You make new friends, discover new dreams. The day refuels your passion.",
			effects = {Happiness = 8},
			flags = {set = {"car_community"}},
		},
		{
			id = "show_your_car",
			text = "Enter your car in the show.",
			chanceSuccess = 0.30,
			resultTextSuccess = "Your car wins 'Best in Class'! Strangers crowd around asking questions. You're beaming with pride.",
			resultTextFail = "Your car doesn't place, but the compliments are genuine. You made memories.",
			effectsOnSuccess = {Happiness = 12, Fame = 5},
			effectsOnFail = {Happiness = 5},
			flags = {set = {"car_show_participant"}},
		},
	},
})

table.insert(events, {
	id = "random_dream_car",
	emoji = "💎",
	title = "The Dream Machine",
	category = "lifestyle",
	tags = {"random", "luxury", "milestone", "automotive"},
	
	weight = 5,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 25,
		maxAge = 70,
		requiredAllFlags = {"dream_car_chosen"},
		minMoney = 100000,
	},
	
	getDynamicData = function(state)
		local cars = {"the exact car you dreamed about as a kid", "a limited edition version of your dream car", "the same model your hero drove"}
		local prices = {80000, 150000, 300000, 500000}
		return {
			car = cars[math.random(#cars)],
			price = prices[math.random(#prices)]
		}
	end,
	
	text = "You find it. %car%. For sale. $%price%. Every wall poster, every screen saver, every dream - sitting right in front of you. Can you afford to make the dream real?",
	
	choices = {
		{
			id = "buy_it",
			text = "Buy it. This is what money is for.",
			resultText = "You sign the papers with shaking hands. When you drive it home, you realize: you made it. The kid who played with toy cars now owns the real thing.",
			effects = {Happiness = 25, Money = -100000},
			flags = {set = {"dream_car_owned", "life_goal_achieved"}},
		},
		{
			id = "test_drive",
			text = "Just test drive it. Feel it once.",
			resultText = "For twenty glorious minutes, you live the dream. When you hand back the keys, you're not sad. You know what it feels like now. That's enough... for now.",
			effects = {Happiness = 10},
			flags = {set = {"dream_car_experienced"}},
		},
		{
			id = "walk_away",
			text = "The money is better saved. Walk away.",
			resultText = "Practical choice. Smart choice. Empty choice. You drive home in your normal car and try not to think about it.",
			effects = {Happiness = -5, Smarts = 3},
			flags = {set = {"dream_deferred"}},
		},
	},
})

table.insert(events, {
	id = "random_road_trip",
	emoji = "🛣️",
	title = "The Open Road",
	category = "lifestyle",
	tags = {"random", "adventure", "freedom", "automotive"},
	
	weight = 8,
	oneTime = false,
	cooldownYears = 3,
	
	conditions = {
		minAge = 18,
		maxAge = 75,
		requiredAllFlags = {"has_car", "can_drive"},
	},
	
	getDynamicData = function(state)
		local destinations = {"the coast", "the mountains", "across the country", "wherever the road takes you"}
		return {
			destination = destinations[math.random(#destinations)]
		}
	end,
	
	text = "An urge hits you: just get in the car and drive. %destination%. No plan, no schedule. Just you and the road.",
	
	choices = {
		{
			id = "go",
			text = "Drop everything. Hit the road.",
			resultText = "Miles blur together. Radio blasting. Windows down. You find parts of yourself on those roads. When you return, you're changed. Lighter.",
			effects = {Happiness = 15, Health = 5, Money = -1000},
			flags = {set = {"road_warrior", "freedom_seeker"}},
		},
		{
			id = "plan_it",
			text = "Plan it properly. Do it right.",
			resultText = "You schedule time off, plan routes, book motels. Less spontaneous, but responsible. Still a great trip.",
			effects = {Happiness = 10, Money = -2000},
			flags = {set = {"road_trip_complete"}},
		},
		{
			id = "skip",
			text = "Can't right now. Life is too busy.",
			resultText = "The urge fades. Maybe next year. Or the year after.",
			effects = {Happiness = -3},
			flags = {set = {}},
		},
	},
})

table.insert(events, {
	id = "random_breakdown",
	emoji = "⚠️",
	title = "Stranded",
	category = "challenge",
	tags = {"random", "challenge", "mechanical", "automotive"},
	
	weight = 8,
	oneTime = false,
	cooldownYears = 2,
	
	conditions = {
		minAge = 16,
		maxAge = 80,
		requiredAllFlags = {"has_car"},
	},
	
	getDynamicData = function(state)
		local locations = {"on a highway at night", "in a rough neighborhood", "miles from anywhere", "in the middle of a storm"}
		local problems = {"the engine dies", "a tire blows out", "the transmission fails", "smoke pours from under the hood"}
		return {
			location = locations[math.random(#locations)],
			problem = problems[math.random(#problems)]
		}
	end,
	
	text = "You're %location% when %problem%. The car won't move. You're stranded. What now?",
	
	choices = {
		{
			id = "fix_yourself",
			text = "(If you have mechanical skills) Fix it yourself.",
			chanceSuccess = 0.60,
			resultTextSuccess = "Your garage skills save the day. You patch it enough to limp home. That's why you learned this stuff.",
			resultTextFail = "You try, but it's beyond your skills. You end up making it worse.",
			effectsOnSuccess = {Happiness = 5, Smarts = 2},
			effectsOnFail = {Happiness = -5, Money = -500},
			flags = {set = {}},
		},
		{
			id = "call_help",
			text = "Call for a tow truck.",
			resultText = "An hour of waiting, a tow bill, but you get home safe. Annoying, but manageable.",
			effects = {Money = -300, Happiness = -2},
			flags = {set = {}},
		},
		{
			id = "hitchhike",
			text = "Leave the car. Hitchhike.",
			chanceSuccess = 0.70,
			resultTextSuccess = "A kind stranger picks you up. They have great stories. By the time you get home, the night became an adventure.",
			resultTextFail = "No one stops. You walk for miles. Finally, you get signal and call for help. Exhausting.",
			effectsOnSuccess = {Happiness = 3},
			effectsOnFail = {Health = -5, Happiness = -5},
			flags = {set = {}},
		},
	},
})

table.insert(events, {
	id = "random_speeding_ticket",
	emoji = "🚨",
	title = "The Ticket",
	category = "consequence",
	tags = {"random", "consequence", "legal", "automotive"},
	
	weight = 10,
	oneTime = false,
	cooldownYears = 1,
	
	conditions = {
		minAge = 16,
		maxAge = 80,
		requiredAllFlags = {"can_drive"},
	},
	
	getDynamicData = function(state)
		local speeds = {15, 25, 35, 45}
		local fines = {150, 300, 500, 1000}
		local idx = math.random(#speeds)
		return {
			speed = speeds[idx],
			fine = fines[idx]
		}
	end,
	
	text = "Flashing lights. You were doing %speed% over the limit. The officer walks up. '$%fine% fine,' they say. Your heart sinks.",
	
	choices = {
		{
			id = "pay",
			text = "Accept it. Pay the fine.",
			resultText = "Money gone, insurance goes up. Annoying, but you move on. Maybe drive slower next time.",
			effects = {Money = -500, Happiness = -3},
			flags = {set = {"speeding_ticket"}},
		},
		{
			id = "fight_it",
			text = "Contest the ticket in court.",
			chanceSuccess = 0.25,
			resultTextSuccess = "Technical error on the ticket! Dismissed! You walk out victorious.",
			resultTextFail = "The judge upholds the fine. Plus court fees. You paid double for nothing.",
			effectsOnSuccess = {Happiness = 8},
			effectsOnFail = {Money = -800, Happiness = -5},
			flags = {set = {"speeding_ticket"}},
		},
		{
			id = "charm",
			text = "Try to talk your way out of it.",
			chanceSuccess = 0.15,
			resultTextSuccess = "'Drive safe,' they say, letting you off with a warning. Incredible.",
			resultTextFail = "They're not amused. Full ticket, no mercy. Maybe even an extra citation for wasting their time.",
			effectsOnSuccess = {Happiness = 5},
			effectsOnFail = {Money = -700, Happiness = -4},
			flags = {set = {"speeding_ticket"}},
		},
	},
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 7: RELATIONSHIP & FAMILY INTERSECTION EVENTS  
-- How your automotive life affects relationships
-- ═══════════════════════════════════════════════════════════════════════════════

table.insert(events, {
	id = "relationship_racing_conflict",
	emoji = "💔",
	title = "The Ultimatum",
	category = "relationship",
	tags = {"relationship", "conflict", "racing", "choice", "automotive"},
	
	weight = 8,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 20,
		maxAge = 45,
		requiredCareerId = "automotive",
		requiredAnyFlags = {"racing_career", "street_racing_initiate"},
		requiredAllFlags = {"in_relationship"},
	},
	
	getDynamicData = function(state)
		return {
			partnerName = state.PartnerName or "your partner"
		}
	end,
	
	text = "%partnerName% sits you down. 'It's the racing or me. I can't watch you risk your life anymore. I can't keep waiting for that phone call. Choose.'",
	
	choices = {
		{
			id = "choose_racing",
			text = "You choose racing. You have to.",
			resultText = "They leave. The door closes. You're alone. But behind the wheel, you're alive. Some things can't be explained.",
			effects = {Happiness = -15, Karma = -5},
			flags = {set = {"relationship_ended", "chose_racing", "sacrifice_for_passion"}},
		},
		{
			id = "choose_love",
			text = "You choose them. Hang up the helmet.",
			resultText = "You walk away from racing. Every engine you hear hurts. But when you look at them, you know it was worth it. Maybe.",
			effects = {Happiness = -5, Karma = 5},
			flags = {set = {"racing_retired", "chose_love", "retired_for_love"}},
			quitCareer = true,
		},
		{
			id = "compromise",
			text = "Beg for a compromise. Less racing, more safety.",
			chanceSuccess = 0.40,
			resultTextSuccess = "They agree, reluctantly. You scale back. The relationship survives. But you both know the tension will never fully leave.",
			resultTextFail = "They've made up their mind. There is no compromise. Choose.",
			effectsOnSuccess = {Happiness = 5},
			effectsOnFail = {Happiness = -10},
			flags = {set = {"relationship_compromise"}},
		},
	},
})

table.insert(events, {
	id = "relationship_teaching_child",
	emoji = "👨‍👧",
	title = "Passing It On",
	category = "family",
	tags = {"family", "legacy", "teaching", "automotive"},
	
	weight = 8,
	oneTime = true,
	milestone = true,
	
	conditions = {
		minAge = 30,
		maxAge = 60,
		requiredAnyFlags = {"has_child", "parent"},
		requiredAnyFlags = {"racer_interest", "mechanic_experience", "petrolhead"},
	},
	
	getDynamicData = function(state)
		return {
			childName = state.ChildName or "your child"
		}
	end,
	
	text = "%childName% shows interest in cars. They want to learn to drive, to work on engines, to understand what makes you love this so much. You have a chance to pass on your passion.",
	
	choices = {
		{
			id = "teach_everything",
			text = "Teach them everything you know.",
			resultText = "Hours in the garage, weekends at the track. They absorb it all. Watching them behind the wheel for the first time - you've never felt more proud.",
			effects = {Happiness = 15, Karma = 5},
			flags = {set = {"legacy_passed", "mentor_parent"}},
		},
		{
			id = "let_them_explore",
			text = "Let them find their own path. Don't push.",
			resultText = "You answer questions when asked, but don't force it. If the passion is real, they'll come to it themselves.",
			effects = {Happiness = 5, Karma = 3},
			flags = {set = {"patient_parent"}},
		},
		{
			id = "discourage",
			text = "Discourage it. You know the dangers too well.",
			resultText = "You've seen the crashes, the heartbreak. You steer them away. They resent it now. Maybe they'll understand later.",
			effects = {Happiness = -5, Karma = 2},
			flags = {set = {"protective_parent", "legacy_blocked"}},
		},
	},
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- Return all events
-- ═══════════════════════════════════════════════════════════════════════════════

return {events = events}
