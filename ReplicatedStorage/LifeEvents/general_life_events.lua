-- general_life_events.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- MASSIVE GENERAL LIFE EVENTS - Events that fire for EVERYONE
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- These events don't require specific career paths or complex flag chains.
-- They represent universal life experiences that happen to everyone.
-- This ensures players ALWAYS have interesting events firing!
--
-- ═══════════════════════════════════════════════════════════════════════════════

local events = {}

-- ═══════════════════════════════════════════════════════════════════════════════
-- BABY/TODDLER EVENTS (Ages 0-4)
-- ═══════════════════════════════════════════════════════════════════════════════

table.insert(events, {
	id = "baby_first_steps",
	emoji = "👶",
	title = "First Steps",
	category = "milestone",
	milestone = true,
	weight = 20,
	oneTime = true,
	conditions = { minAge = 1, maxAge = 2 },
	text = "You take your first steps! Your parents cheer as you wobble across the living room floor.",
	choices = {
		{ text = "Walk confidently", resultText = "You march forward with determination!", effects = {Happiness = 5, Health = 3} },
		{ text = "Fall and get back up", resultText = "You tumble, but immediately try again. Resilient!", effects = {Happiness = 3, Health = 2}, flags = {set = {"determined"}} },
	},
})

table.insert(events, {
	id = "toddler_tantrum",
	emoji = "😭",
	title = "The Tantrum",
	category = "childhood",
	weight = 15,
	oneTime = true,
	conditions = { minAge = 2, maxAge = 4 },
	text = "You throw an epic tantrum in the middle of a store because you can't have a toy you want.",
	choices = {
		{ text = "Scream louder until you get it", resultText = "Your parents give in. You learn that crying works.", effects = {Happiness = 5}, flags = {set = {"spoiled_tendency"}} },
		{ text = "Eventually calm down", resultText = "You learn that you can't always get what you want.", effects = {Smarts = 2}, flags = {set = {"emotionally_regulated"}} },
	},
})

table.insert(events, {
	id = "toddler_pet_meeting",
	emoji = "🐕",
	title = "Meeting a Pet",
	category = "childhood",
	weight = 15,
	oneTime = true,
	conditions = { minAge = 2, maxAge = 5 },
	getDynamicData = function(state)
		local pets = {"a friendly dog", "a fluffy cat", "a gentle rabbit", "a goldfish in a tank"}
		return { pet = pets[math.random(#pets)] }
	end,
	text = "Your family gets %pet%! This is your first real interaction with an animal.",
	choices = {
		{ text = "Immediately love it", resultText = "You become best friends with your new pet!", effects = {Happiness = 8}, flags = {set = {"animal_lover", "has_family_pet"}} },
		{ text = "Be scared at first", resultText = "It takes time, but you eventually warm up to it.", effects = {Happiness = 3}, flags = {set = {"cautious_around_animals"}} },
		{ text = "Try to ride it", resultText = "That didn't work out, but you learned something.", effects = {Health = -2, Smarts = 1} },
	},
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- EARLY CHILDHOOD (Ages 4-8)
-- ═══════════════════════════════════════════════════════════════════════════════

table.insert(events, {
	id = "childhood_first_friend",
	emoji = "👫",
	title = "Your First Friend",
	category = "social",
	milestone = true,
	weight = 20,
	oneTime = true,
	conditions = { minAge = 4, maxAge = 7 },
	getDynamicData = function(state)
		local names = {"Alex", "Jordan", "Sam", "Casey", "Riley", "Morgan", "Taylor", "Jamie"}
		return { friendName = names[math.random(#names)] }
	end,
	text = "At the playground, you meet %friendName%. You both like the same things! This could be the start of something special.",
	choices = {
		{ text = "Become best friends immediately", resultText = "You and %friendName% are inseparable!", effects = {Happiness = 10}, flags = {set = {"has_best_friend", "social_butterfly"}}, addRelationship = {name = "%friendName%", category = "friends", type = "childhood_friend", startingRelationship = 80} },
		{ text = "Play together sometimes", resultText = "You make a good friend, taking it slow.", effects = {Happiness = 5}, addRelationship = {name = "%friendName%", category = "friends", type = "friend", startingRelationship = 60} },
	},
})

table.insert(events, {
	id = "childhood_scraped_knee",
	emoji = "🩹",
	title = "Scraped Knee",
	category = "childhood",
	weight = 15,
	oneTime = false,
	cooldownYears = 3,
	conditions = { minAge = 4, maxAge = 10 },
	text = "You fall while playing and scrape your knee badly. Blood! Tears! Drama!",
	choices = {
		{ text = "Cry until someone helps", resultText = "An adult bandages you up with lots of sympathy.", effects = {Health = -2, Happiness = -1} },
		{ text = "Be brave about it", resultText = "You tough it out. It still hurts, but you feel proud.", effects = {Health = -1}, flags = {set = {"brave"}} },
		{ text = "Keep playing anyway", resultText = "Who cares about a little blood? Back to fun!", effects = {Health = -3, Happiness = 3}, flags = {set = {"tough_kid"}} },
	},
})

table.insert(events, {
	id = "childhood_imaginary_friend",
	emoji = "👻",
	title = "The Imaginary Friend",
	category = "childhood",
	weight = 12,
	oneTime = true,
	conditions = { minAge = 4, maxAge = 8 },
	text = "You create an imaginary friend named Whiskers. They go everywhere with you and understand you perfectly.",
	choices = {
		{ text = "Have elaborate adventures together", resultText = "Your imagination flourishes. Whiskers is the best!", effects = {Happiness = 5, Smarts = 3}, flags = {set = {"creative_mind", "vivid_imagination"}} },
		{ text = "Keep Whiskers a secret", resultText = "Nobody else needs to know about your special friend.", effects = {Happiness = 3}, flags = {set = {"private_person"}} },
		{ text = "Tell everyone about Whiskers", resultText = "Some kids think it's weird. Others want their own!", effects = {Happiness = 2, Smarts = 1} },
	},
})

table.insert(events, {
	id = "childhood_learned_to_read",
	emoji = "📚",
	title = "Reading Opens Worlds",
	category = "education",
	milestone = true,
	weight = 18,
	oneTime = true,
	conditions = { minAge = 5, maxAge = 7 },
	text = "Something clicks. You can READ! Words become stories become entire worlds!",
	choices = {
		{ text = "Devour every book you can find", resultText = "You become a bookworm. The library is your second home.", effects = {Smarts = 8, Happiness = 5}, flags = {set = {"bookworm", "love_reading"}} },
		{ text = "Prefer picture books", resultText = "Stories with pictures are the best kind.", effects = {Smarts = 4, Happiness = 3}, flags = {set = {"visual_learner"}} },
		{ text = "Only read when you have to", resultText = "Reading is okay, but there are more fun things to do.", effects = {Smarts = 2} },
	},
})

table.insert(events, {
	id = "childhood_first_lie",
	emoji = "🤥",
	title = "The First Lie",
	category = "moral",
	weight = 12,
	oneTime = true,
	conditions = { minAge = 5, maxAge = 9 },
	text = "You break something valuable and lie about it. 'It wasn't me!' Your heart pounds.",
	choices = {
		{ text = "Stick to the lie", resultText = "Nobody finds out. But you feel guilty inside.", effects = {Happiness = -3, Smarts = 1}, flags = {set = {"learned_to_lie"}} },
		{ text = "Confess the truth", resultText = "You're punished, but your conscience is clear.", effects = {Happiness = -1, Karma = 3}, flags = {set = {"honest_kid"}} },
		{ text = "Blame someone else", resultText = "Someone else gets in trouble. You got away with it...", effects = {Karma = -5}, flags = {set = {"scapegoater"}} },
	},
})

table.insert(events, {
	id = "childhood_playground_bully",
	emoji = "😠",
	title = "The Bully",
	category = "social",
	weight = 14,
	oneTime = true,
	conditions = { minAge = 6, maxAge = 12 },
	getDynamicData = function(state)
		local names = {"Tommy", "Derek", "Brittany", "Madison", "Tyler", "Blake"}
		return { bullyName = names[math.random(#names)] }
	end,
	text = "%bullyName% picks on you at school. They push you, call you names, and make fun of you in front of others.",
	choices = {
		{ text = "Stand up to them", resultText = "You push back. They're surprised and back off.", effects = {Happiness = 5}, flags = {set = {"stood_up_for_self", "brave"}} },
		{ text = "Tell an adult", resultText = "The bully gets in trouble. Problem solved... mostly.", effects = {Happiness = 2}, flags = {set = {"trusts_authority"}} },
		{ text = "Try to befriend them", resultText = "Surprisingly, it works. They just wanted attention.", effects = {Happiness = 3, Smarts = 2}, flags = {set = {"diplomatic"}} },
		{ text = "Suffer in silence", resultText = "You avoid them when you can. It's not fair.", effects = {Happiness = -5}, flags = {set = {"bullied"}} },
	},
})

table.insert(events, {
	id = "childhood_lost_tooth",
	emoji = "🦷",
	title = "Lost Tooth",
	category = "milestone",
	weight = 15,
	oneTime = false,
	cooldownYears = 1,
	conditions = { minAge = 5, maxAge = 12 },
	getDynamicData = function(state)
		local money = {1, 2, 5, 10, 20}
		return { amount = money[math.random(#money)] }
	end,
	text = "Your tooth falls out! You put it under your pillow for the Tooth Fairy.",
	choices = {
		{ text = "Wake up to find money!", resultText = "The Tooth Fairy left you $%amount%! Magic is real!", effects = {Happiness = 5, Money = 5} },
		{ text = "Stay awake to catch the Tooth Fairy", resultText = "You fall asleep anyway. But there's money in the morning!", effects = {Happiness = 4, Money = 5} },
	},
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- LATE CHILDHOOD (Ages 8-12)
-- ═══════════════════════════════════════════════════════════════════════════════

table.insert(events, {
	id = "childhood_video_games",
	emoji = "🎮",
	title = "Gaming Discovery",
	category = "hobby",
	weight = 15,
	oneTime = true,
	conditions = { minAge = 6, maxAge = 14 },
	text = "You discover video games. They're amazing! Entire worlds at your fingertips!",
	choices = {
		{ text = "Become obsessed with gaming", resultText = "Gaming becomes your main hobby. You get really good.", effects = {Happiness = 8, Smarts = 2}, flags = {set = {"gamer", "gaming_interest"}} },
		{ text = "Play casually for fun", resultText = "Games are fun, but there's other stuff too.", effects = {Happiness = 5} },
		{ text = "Meh, not really into it", resultText = "You prefer other activities.", effects = {Happiness = 2} },
	},
})

table.insert(events, {
	id = "childhood_sports_tryout",
	emoji = "⚽",
	title = "Sports Tryouts",
	category = "hobby",
	weight = 14,
	oneTime = true,
	conditions = { minAge = 7, maxAge = 14 },
	getDynamicData = function(state)
		local sports = {"soccer", "basketball", "baseball", "swimming", "track and field", "gymnastics"}
		return { sport = sports[math.random(#sports)] }
	end,
	text = "Your school is holding tryouts for %sport%. Do you want to try out?",
	choices = {
		{ text = "Try out and make the team!", chanceSuccess = 0.60, resultTextSuccess = "You made it! Welcome to the team!", resultTextFail = "You didn't make the cut, but you gave it your best.", effectsOnSuccess = {Happiness = 10, Health = 5}, effectsOnFail = {Happiness = -3, Health = 2}, flags = {set = {"athletic"}} },
		{ text = "Try out but don't care about results", resultText = "You gave it a shot. Win or lose, you had fun.", effects = {Health = 3, Happiness = 3} },
		{ text = "Skip it - sports aren't your thing", resultText = "You spend the afternoon doing something else.", effects = {Happiness = 1} },
	},
})

table.insert(events, {
	id = "childhood_school_play",
	emoji = "🎭",
	title = "The School Play",
	category = "school",
	weight = 12,
	oneTime = true,
	conditions = { minAge = 7, maxAge = 14 },
	text = "Your school is putting on a play. There are roles available for actors, stage crew, or you could just watch.",
	choices = {
		{ text = "Audition for a lead role", chanceSuccess = 0.40, resultTextSuccess = "You got the lead! Time to shine!", resultTextFail = "You got a smaller role, but you're still in the show.", effectsOnSuccess = {Happiness = 12, Looks = 3}, effectsOnFail = {Happiness = 5}, flags = {set = {"performer", "drama_interest"}} },
		{ text = "Join the stage crew", resultText = "Behind the scenes is where the real magic happens.", effects = {Happiness = 5, Smarts = 3}, flags = {set = {"behind_scenes_type"}} },
		{ text = "Just watch the show", resultText = "You enjoy watching your classmates perform.", effects = {Happiness = 2} },
	},
})

table.insert(events, {
	id = "childhood_art_talent",
	emoji = "🎨",
	title = "Artistic Discovery",
	category = "hobby",
	weight = 12,
	oneTime = true,
	conditions = { minAge = 6, maxAge = 14 },
	text = "You draw something at school and the teacher is impressed. 'You have real talent!'",
	choices = {
		{ text = "Start drawing all the time", resultText = "You fill notebooks with your art. It's your passion.", effects = {Happiness = 8, Smarts = 2}, flags = {set = {"artistic", "artist_interest"}} },
		{ text = "Take an art class", resultText = "You decide to develop this talent formally.", effects = {Happiness = 5, Smarts = 3}, flags = {set = {"artistic"}} },
		{ text = "Say thanks and move on", resultText = "Nice compliment, but art isn't really your thing.", effects = {Happiness = 2} },
	},
})

table.insert(events, {
	id = "childhood_music_lesson",
	emoji = "🎵",
	title = "First Music Lesson",
	category = "hobby",
	weight = 12,
	oneTime = true,
	conditions = { minAge = 6, maxAge = 14 },
	getDynamicData = function(state)
		local instruments = {"piano", "guitar", "violin", "drums", "flute", "trumpet"}
		return { instrument = instruments[math.random(#instruments)] }
	end,
	text = "Your parents sign you up for %instrument% lessons. Your first lesson is today!",
	choices = {
		{ text = "Love it and practice daily", resultText = "Music becomes a part of your soul.", effects = {Happiness = 8, Smarts = 3}, flags = {set = {"musical", "plays_instrument"}} },
		{ text = "It's okay, keep at it casually", resultText = "You learn to play decently over time.", effects = {Happiness = 4, Smarts = 2} },
		{ text = "Hate it, quit after a few lessons", resultText = "Music lessons just aren't for you.", effects = {Happiness = -2} },
	},
})

table.insert(events, {
	id = "childhood_sleepover",
	emoji = "🌙",
	title = "First Sleepover",
	category = "social",
	weight = 14,
	oneTime = true,
	conditions = { minAge = 7, maxAge = 13 },
	text = "You're invited to your first sleepover at a friend's house! Pizza, movies, staying up late!",
	choices = {
		{ text = "Have the best night ever", resultText = "You stay up until 3 AM laughing. Best. Night. Ever.", effects = {Happiness = 10, Health = -1}, flags = {set = {"party_lover"}} },
		{ text = "Get homesick and call parents", resultText = "You make it until midnight, then need to go home. It's okay.", effects = {Happiness = 2} },
		{ text = "Pull an all-nighter", resultText = "You don't sleep at all. Totally worth it... until tomorrow.", effects = {Happiness = 8, Health = -3}, flags = {set = {"night_owl"}} },
	},
})

table.insert(events, {
	id = "childhood_science_fair",
	emoji = "🔬",
	title = "Science Fair",
	category = "school",
	weight = 12,
	oneTime = true,
	conditions = { minAge = 8, maxAge = 14 },
	getDynamicData = function(state)
		local projects = {"a volcano", "a solar system model", "growing plants in different conditions", "a homemade battery", "testing paper airplane designs"}
		return { project = projects[math.random(#projects)] }
	end,
	text = "The school science fair is coming up. You decide to make %project%.",
	choices = {
		{ text = "Put in maximum effort", chanceSuccess = 0.50, resultTextSuccess = "You win first place! Your project impressed the judges!", resultTextFail = "You don't win, but you learn a lot.", effectsOnSuccess = {Happiness = 12, Smarts = 5, Money = 50}, effectsOnFail = {Smarts = 3, Happiness = 2}, flags = {set = {"science_interest"}} },
		{ text = "Do a decent job", resultText = "Your project is solid. You get a participation ribbon.", effects = {Smarts = 2, Happiness = 3} },
		{ text = "Procrastinate and rush it", resultText = "It's... not your best work. But you finished!", effects = {Smarts = 1, Happiness = -1} },
	},
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- TEEN YEARS (Ages 13-17)
-- ═══════════════════════════════════════════════════════════════════════════════

table.insert(events, {
	id = "teen_puberty",
	emoji = "🌱",
	title = "Growing Up",
	category = "milestone",
	milestone = true,
	weight = 20,
	oneTime = true,
	conditions = { minAge = 11, maxAge = 14 },
	text = "Your body is changing. Puberty has arrived. Things feel... different. Confusing. Intense.",
	choices = {
		{ text = "Roll with the changes", resultText = "It's weird but you handle it with grace.", effects = {Health = 5, Looks = 3, Happiness = 2}, flags = {set = {"going_through_puberty"}} },
		{ text = "Feel self-conscious about everything", resultText = "You're hyper-aware of every change. It's tough.", effects = {Looks = 2, Happiness = -3}, flags = {set = {"going_through_puberty", "self_conscious"}} },
		{ text = "Embrace becoming a new you", resultText = "You see this as exciting! A whole new chapter!", effects = {Health = 3, Happiness = 5, Looks = 4}, flags = {set = {"going_through_puberty", "confident"}} },
	},
})

table.insert(events, {
	id = "teen_first_crush",
	emoji = "💕",
	title = "Your First Crush",
	category = "romance",
	weight = 16,
	oneTime = true,
	conditions = { minAge = 12, maxAge = 16 },
	getDynamicData = function(state)
		local names = {"Riley", "Jordan", "Alex", "Cameron", "Morgan", "Taylor", "Casey", "Jamie"}
		return { crushName = names[math.random(#names)] }
	end,
	text = "You can't stop thinking about %crushName%. Everything they do seems amazing. Your heart races when they're near. Is this... love?",
	choices = {
		{ text = "Confess your feelings", chanceSuccess = 0.40, resultTextSuccess = "They like you too! You're on cloud nine!", resultTextFail = "'Let's just be friends.' Ouch. But you'll survive.", effectsOnSuccess = {Happiness = 15}, effectsOnFail = {Happiness = -8}, flags = {set = {"first_crush"}} },
		{ text = "Admire from afar", resultText = "You never tell them. The fantasy stays perfect.", effects = {Happiness = 3}, flags = {set = {"first_crush", "romantic_daydreamer"}} },
		{ text = "Write them a secret note", chanceSuccess = 0.50, resultTextSuccess = "They find the note and think it's sweet!", resultTextFail = "Someone else finds it and reads it out loud. Mortifying.", effectsOnSuccess = {Happiness = 10}, effectsOnFail = {Happiness = -10}, flags = {set = {"first_crush"}} },
	},
})

table.insert(events, {
	id = "teen_social_media",
	emoji = "📱",
	title = "Social Media Life",
	category = "lifestyle",
	weight = 15,
	oneTime = true,
	conditions = { minAge = 12, maxAge = 18 },
	text = "All your friends are on social media. The pressure to be online, to post, to get likes... it's intense.",
	choices = {
		{ text = "Dive in and love it", resultText = "You become a social media natural. Followers grow!", effects = {Happiness = 5, Looks = 2}, flags = {set = {"social_media_active", "influencer_wannabe"}} },
		{ text = "Use it casually", resultText = "You check it sometimes but don't let it control you.", effects = {Happiness = 3}, flags = {set = {"social_media_casual"}} },
		{ text = "Stay off it entirely", resultText = "You don't need the validation. Real life is enough.", effects = {Happiness = 2, Smarts = 2}, flags = {set = {"social_media_free"}} },
		{ text = "Get caught up in drama", resultText = "Online arguments, comparing yourself to others... it's exhausting.", effects = {Happiness = -5}, flags = {set = {"social_media_drama"}} },
	},
})

table.insert(events, {
	id = "teen_part_time_job",
	emoji = "💼",
	title = "First Part-Time Job",
	category = "work",
	weight = 14,
	oneTime = true,
	conditions = { minAge = 14, maxAge = 18 },
	getDynamicData = function(state)
		local jobs = {"at a fast food restaurant", "at a grocery store", "as a babysitter", "mowing lawns", "at a movie theater", "at a retail store"}
		return { jobType = jobs[math.random(#jobs)] }
	end,
	text = "You get your first job %jobType%. It's not glamorous, but it's YOUR money.",
	choices = {
		{ text = "Work hard and impress the boss", resultText = "You become employee of the month! More hours, more money.", effects = {Money = 500, Happiness = 5, Smarts = 2}, flags = {set = {"has_job", "hard_worker", "first_job"}} },
		{ text = "Do the minimum required", resultText = "A paycheck is a paycheck. You're not here to make friends.", effects = {Money = 300, Happiness = 2}, flags = {set = {"has_job", "first_job"}} },
		{ text = "Quit after a week", resultText = "This wasn't for you. Back to asking parents for money.", effects = {Happiness = -2}, flags = {set = {"quit_first_job"}} },
	},
})

table.insert(events, {
	id = "teen_house_party",
	emoji = "🎉",
	title = "The House Party",
	category = "social",
	weight = 14,
	oneTime = false,
	cooldownYears = 2,
	conditions = { minAge = 14, maxAge = 19 },
	text = "Someone's parents are out of town. There's a big party. Everyone's talking about it.",
	choices = {
		{ text = "Go and have a blast", resultText = "Dancing, laughing, making memories! One of the best nights ever.", effects = {Happiness = 12, Health = -2}, flags = {set = {"party_goer"}} },
		{ text = "Go but stay on the sidelines", resultText = "You observe more than participate. Still fun though.", effects = {Happiness = 5} },
		{ text = "Skip it and stay home", resultText = "FOMO hits when you see the photos... but your weekend was chill.", effects = {Happiness = -2, Health = 2} },
		{ text = "Host a counter-party", resultText = "You throw your own thing. Smaller but more your vibe.", effects = {Happiness = 8, Money = -100}, flags = {set = {"party_host"}} },
	},
})

table.insert(events, {
	id = "teen_exam_pressure",
	emoji = "📝",
	title = "Big Exam Stress",
	category = "school",
	weight = 15,
	oneTime = false,
	cooldownYears = 2,
	conditions = { minAge = 13, maxAge = 18 },
	text = "A major exam is coming up. Your grade depends on it. The pressure is intense.",
	choices = {
		{ text = "Study intensively for days", resultText = "All that effort pays off! You ace it!", effects = {Smarts = 5, Happiness = 8, Health = -2}, flags = {set = {"good_student"}} },
		{ text = "Study a normal amount", resultText = "You do okay. Not amazing, but respectable.", effects = {Smarts = 2, Happiness = 2} },
		{ text = "Barely study at all", chanceSuccess = 0.25, resultTextSuccess = "You wing it and somehow pass! Lucky!", resultTextFail = "You fail. Your parents are not happy.", effectsOnSuccess = {Happiness = 5}, effectsOnFail = {Happiness = -8, Smarts = -1} },
		{ text = "Have a breakdown from stress", resultText = "You cry, you panic, but eventually you push through.", effects = {Happiness = -5, Health = -3, Smarts = 3}, flags = {set = {"anxiety_prone"}} },
	},
})

table.insert(events, {
	id = "teen_prom",
	emoji = "💃",
	title = "Prom Night",
	category = "milestone",
	milestone = true,
	weight = 18,
	oneTime = true,
	conditions = { minAge = 16, maxAge = 18 },
	text = "Prom is here! The dress or suit, the photos, the dancing... this is one of those nights you'll always remember.",
	choices = {
		{ text = "Have the perfect night", resultText = "Everything clicks. Dancing, laughing, feeling like royalty. Magical.", effects = {Happiness = 15, Looks = 3}, flags = {set = {"prom_attendee", "prom_memories"}} },
		{ text = "Go with a group of friends", resultText = "Who needs a date when you have your squad?", effects = {Happiness = 10}, flags = {set = {"prom_attendee"}} },
		{ text = "Ask your crush to prom", chanceSuccess = 0.60, resultTextSuccess = "They say yes! You're going together!", resultTextFail = "They already have a date. You go with friends instead.", effectsOnSuccess = {Happiness = 15}, effectsOnFail = {Happiness = 3} },
		{ text = "Skip prom entirely", resultText = "Not your scene. You do your own thing that night.", effects = {Happiness = 2, Money = 100} },
	},
})

table.insert(events, {
	id = "teen_graduation",
	emoji = "🎓",
	title = "High School Graduation",
	category = "milestone",
	milestone = true,
	weight = 25,
	oneTime = true,
	conditions = { minAge = 17, maxAge = 19 },
	text = "The ceremony is here. You walk across the stage, diploma in hand. Childhood is officially over. What comes next?",
	choices = {
		{ text = "Feel proud and accomplished", resultText = "You did it. Whatever comes next, you earned this moment.", effects = {Happiness = 15, Smarts = 3}, flags = {set = {"high_school_graduate"}} },
		{ text = "Feel uncertain about the future", resultText = "Freedom is scary. But also exciting. Mostly scary.", effects = {Happiness = 5, Smarts = 2}, flags = {set = {"high_school_graduate", "uncertain_future"}} },
		{ text = "Can't wait to leave this place", resultText = "Finally! Time to start your real life.", effects = {Happiness = 10}, flags = {set = {"high_school_graduate", "ready_for_change"}} },
	},
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- YOUNG ADULT (Ages 18-30)
-- ═══════════════════════════════════════════════════════════════════════════════

table.insert(events, {
	id = "adult_college_decision",
	emoji = "🏛️",
	title = "The College Decision",
	category = "education",
	milestone = true,
	weight = 18,
	oneTime = true,
	conditions = { minAge = 17, maxAge = 20 },
	text = "It's time to decide: do you go to college? Trade school? Straight to work? The future awaits.",
	choices = {
		{ text = "Go to a 4-year university", resultText = "Higher education, here you come! Time to expand your mind.", effects = {Money = -10000, Smarts = 5}, flags = {set = {"college_student", "in_school"}} },
		{ text = "Attend community college", resultText = "Smart financial choice. Same knowledge, less debt.", effects = {Money = -2000, Smarts = 3}, flags = {set = {"college_student", "in_school"}} },
		{ text = "Learn a trade", resultText = "Plumbing, electrical, HVAC... real skills, real money.", effects = {Money = -500, Smarts = 2}, flags = {set = {"trade_student", "practical_skills"}} },
		{ text = "Start working right away", resultText = "No student debt for you. Time to earn.", effects = {Money = 5000, Happiness = 3}, flags = {set = {"working_adult", "no_college"}} },
	},
})

table.insert(events, {
	id = "adult_move_out",
	emoji = "🏠",
	title = "Moving Out",
	category = "milestone",
	milestone = true,
	weight = 16,
	oneTime = true,
	conditions = { minAge = 18, maxAge = 28 },
	text = "It's time. You're moving out of your parents' place. Independence awaits! Also bills. Lots of bills.",
	choices = {
		{ text = "Get your own apartment", resultText = "It's small but it's YOURS. Freedom tastes amazing.", effects = {Happiness = 10, Money = -3000}, flags = {set = {"lives_alone", "independent"}} },
		{ text = "Get roommates", resultText = "Cheaper rent, more noise, interesting stories.", effects = {Happiness = 5, Money = -1500}, flags = {set = {"has_roommates"}} },
		{ text = "Stay home a bit longer", resultText = "Save money, deal with parents a bit more. Fair trade.", effects = {Money = 3000, Happiness = -2}, flags = {set = {"lives_with_parents"}} },
	},
})

table.insert(events, {
	id = "adult_first_real_job",
	emoji = "💼",
	title = "The First Real Job",
	category = "career",
	milestone = true,
	weight = 18,
	oneTime = true,
	conditions = { minAge = 18, maxAge = 26 },
	getDynamicData = function(state)
		local jobs = {"at a startup", "at a corporation", "at a small local business", "in retail management", "in an office", "remotely from home"}
		local salaries = {25000, 35000, 45000, 55000}
		return { 
			jobType = jobs[math.random(#jobs)],
			salary = salaries[math.random(#salaries)]
		}
	end,
	text = "You land a full-time job %jobType% making $%salary% a year. Your first 'real' career begins.",
	choices = {
		{ text = "Excel and aim for promotion", resultText = "You throw yourself into the work. Management notices.", effects = {Money = 5000, Happiness = 8, Smarts = 3}, flags = {set = {"employed", "career_focused", "first_real_job"}} },
		{ text = "Do solid work, maintain balance", resultText = "You're good at your job but protect your personal time.", effects = {Money = 3000, Happiness = 5}, flags = {set = {"employed", "work_life_balance", "first_real_job"}} },
		{ text = "Struggle to adjust to corporate life", resultText = "8 hours a day, 5 days a week? This is tough.", effects = {Money = 2000, Happiness = -3}, flags = {set = {"employed", "first_real_job"}} },
	},
})

table.insert(events, {
	id = "adult_dating_scene",
	emoji = "💕",
	title = "Looking for Love",
	category = "romance",
	weight = 14,
	oneTime = false,
	cooldownYears = 2,
	conditions = { minAge = 18, maxAge = 40, blockedFlags = {"married", "in_relationship"} },
	text = "You're single and looking. Dating apps, social events, friends setting you up... the modern search for love.",
	choices = {
		{ text = "Try dating apps", chanceSuccess = 0.50, resultTextSuccess = "Match! You connect with someone special.", resultTextFail = "Lots of matches but no real connection. Keep trying.", effectsOnSuccess = {Happiness = 10}, effectsOnFail = {Happiness = -2}, flags = {set = {"dating"}} },
		{ text = "Meet someone through friends", chanceSuccess = 0.60, resultTextSuccess = "Your friend was right - you two really click!", resultTextFail = "Nice person but no spark. At least you tried.", effectsOnSuccess = {Happiness = 12}, effectsOnFail = {Happiness = 1} },
		{ text = "Focus on yourself instead", resultText = "Single life isn't bad. You work on you.", effects = {Happiness = 5, Smarts = 2}, flags = {set = {"happily_single"}} },
	},
})

table.insert(events, {
	id = "adult_getting_serious",
	emoji = "💑",
	title = "Getting Serious",
	category = "romance",
	milestone = true,
	weight = 14,
	oneTime = false,
	cooldownYears = 5,
	conditions = { minAge = 20, maxAge = 50, requiredAnyFlags = {"dating", "in_relationship"}, blockedFlags = {"married"} },
	getDynamicData = function(state)
		local names = {"Alex", "Jordan", "Sam", "Chris", "Pat", "Morgan", "Taylor", "Jamie"}
		return { partnerName = names[math.random(#names)] }
	end,
	text = "Your relationship with %partnerName% is getting serious. They want to know where this is going.",
	choices = {
		{ text = "Move in together", resultText = "You take the leap. Sharing a home changes everything.", effects = {Happiness = 10, Money = 2000}, flags = {set = {"in_relationship", "cohabiting"}}, addRelationship = {name = "%partnerName%", category = "romance", type = "partner", startingRelationship = 75} },
		{ text = "Keep dating but take it slow", resultText = "No rush. Good things take time.", effects = {Happiness = 5}, flags = {set = {"in_relationship"}} },
		{ text = "Break up - you're not ready", resultText = "They're hurt. You feel guilty. But you weren't ready.", effects = {Happiness = -5, Karma = -2}, flags = {clear = {"in_relationship", "dating"}} },
	},
})

table.insert(events, {
	id = "adult_wedding",
	emoji = "💒",
	title = "Wedding Bells",
	category = "milestone",
	milestone = true,
	weight = 12,
	oneTime = true,
	conditions = { minAge = 22, maxAge = 60, requiredAnyFlags = {"cohabiting", "engaged"}, blockedFlags = {"married"} },
	getDynamicData = function(state)
		local costs = {5000, 15000, 30000, 50000}
		return { weddingCost = costs[math.random(#costs)] }
	end,
	text = "The question was popped. The answer was yes. Now it's time to plan a wedding... for $%weddingCost%.",
	choices = {
		{ text = "Go big - dream wedding", resultText = "The most beautiful day of your life. Worth every penny.", effects = {Happiness = 20, Money = -30000}, flags = {set = {"married"}} },
		{ text = "Keep it simple and intimate", resultText = "Close friends, family, meaningful vows. Perfect.", effects = {Happiness = 15, Money = -5000}, flags = {set = {"married"}} },
		{ text = "Courthouse wedding", resultText = "Just the two of you and the certificate. What matters is the love.", effects = {Happiness = 12, Money = -500}, flags = {set = {"married"}} },
	},
})

table.insert(events, {
	id = "adult_quarter_life_crisis",
	emoji = "😰",
	title = "Quarter-Life Crisis",
	category = "milestone",
	weight = 14,
	oneTime = true,
	conditions = { minAge = 23, maxAge = 28 },
	text = "You're supposed to have it figured out by now, right? But you don't. What are you even doing with your life?",
	choices = {
		{ text = "Make a big change", resultText = "Quit your job, move cities, start fresh. Terrifying and exhilarating.", effects = {Happiness = 5, Money = -5000}, flags = {set = {"risk_taker", "life_change"}} },
		{ text = "Talk to a therapist", resultText = "Professional help gives you perspective. Things feel clearer.", effects = {Happiness = 8, Money = -500, Smarts = 2}, flags = {set = {"self_aware", "therapy_positive"}} },
		{ text = "Push through and keep going", resultText = "This feeling will pass. Just keep swimming.", effects = {Happiness = -2}, flags = {set = {"resilient"}} },
		{ text = "Distract yourself with fun", resultText = "Parties, trips, new hobbies. If you're having fun, are you even lost?", effects = {Happiness = 5, Money = -2000} },
	},
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- ADULT LIFE (Ages 30-50)
-- ═══════════════════════════════════════════════════════════════════════════════

table.insert(events, {
	id = "adult_having_kids",
	emoji = "👶",
	title = "Becoming a Parent",
	category = "milestone",
	milestone = true,
	weight = 12,
	oneTime = true,
	conditions = { minAge = 22, maxAge = 45, requiredAnyFlags = {"married", "in_relationship"}, blockedFlags = {"parent"} },
	text = "A new chapter begins. You're going to be a parent! Excitement, terror, and so much love.",
	choices = {
		{ text = "Embrace parenthood fully", resultText = "It's the hardest and most rewarding thing you've ever done.", effects = {Happiness = 15, Health = -5, Money = -5000}, flags = {set = {"parent", "has_child"}} },
		{ text = "Freak out a little", resultText = "Am I ready for this?! Eventually, you settle in. You've got this.", effects = {Happiness = 8, Health = -3, Money = -5000}, flags = {set = {"parent", "has_child"}} },
	},
})

table.insert(events, {
	id = "adult_buying_house",
	emoji = "🏡",
	title = "Buying a House",
	category = "milestone",
	milestone = true,
	weight = 12,
	oneTime = true,
	conditions = { minAge = 25, maxAge = 55, minMoney = 20000, blockedFlags = {"homeowner"} },
	getDynamicData = function(state)
		local prices = {150000, 250000, 350000, 500000}
		local types = {"a cozy starter home", "a suburban family house", "a downtown condo", "a fixer-upper with potential"}
		local idx = math.random(#prices)
		return { price = prices[idx], houseType = types[idx] }
	end,
	text = "You found it: %houseType% for $%price%. The mortgage is scary but... this could be HOME.",
	choices = {
		{ text = "Buy it!", resultText = "The keys are yours. You're a homeowner. Terrifying and wonderful.", effects = {Happiness = 15, Money = -30000}, flags = {set = {"homeowner"}} },
		{ text = "Keep looking", resultText = "Not quite right. The perfect place is still out there.", effects = {Happiness = 2} },
		{ text = "Rent is fine for now", resultText = "Home ownership isn't for everyone. Flexibility has value.", effects = {Happiness = 3} },
	},
})

table.insert(events, {
	id = "adult_career_crossroads",
	emoji = "🔀",
	title = "Career Crossroads",
	category = "career",
	weight = 14,
	oneTime = false,
	cooldownYears = 5,
	conditions = { minAge = 28, maxAge = 50 },
	getDynamicData = function(state)
		local opportunities = {"a higher paying job at a competitor", "a leadership role", "going back to school for a new field", "starting your own business"}
		return { opportunity = opportunities[math.random(#opportunities)] }
	end,
	text = "An opportunity appears: %opportunity%. It could change everything. Or you could stay where you're comfortable.",
	choices = {
		{ text = "Take the leap", chanceSuccess = 0.65, resultTextSuccess = "Best decision you ever made. Your career transforms.", resultTextFail = "It didn't work out, but at least you tried something new.", effectsOnSuccess = {Money = 15000, Happiness = 12}, effectsOnFail = {Money = -5000, Happiness = -5}, flags = {set = {"risk_taker"}} },
		{ text = "Stay where you are", resultText = "Stability isn't exciting, but it's safe. And that's okay.", effects = {Happiness = 2} },
	},
})

table.insert(events, {
	id = "adult_health_scare",
	emoji = "🏥",
	title = "Health Wake-Up Call",
	category = "health",
	weight = 12,
	oneTime = true,
	conditions = { minAge = 35, maxAge = 65 },
	getDynamicData = function(state)
		local conditions = {"high blood pressure", "high cholesterol", "prediabetes", "a concerning mole"}
		return { condition = conditions[math.random(#conditions)] }
	end,
	text = "The doctor delivers concerning news: you have %condition%. It's manageable, but it's a wake-up call.",
	choices = {
		{ text = "Make serious lifestyle changes", resultText = "Diet, exercise, sleep. You transform your habits.", effects = {Health = 10, Happiness = 5}, flags = {set = {"health_conscious"}} },
		{ text = "Take medication and adjust a little", resultText = "You do what the doctor says, mostly.", effects = {Health = 5, Money = -1000} },
		{ text = "Ignore it and hope for the best", resultText = "Denial isn't a health plan. But you're not ready to change.", effects = {Health = -5, Happiness = 2} },
	},
})

table.insert(events, {
	id = "adult_midlife_crisis",
	emoji = "🏎️",
	title = "Midlife Crisis",
	category = "milestone",
	weight = 12,
	oneTime = true,
	conditions = { minAge = 38, maxAge = 55 },
	text = "Is this all there is? You look in the mirror and don't recognize yourself. Time is running out to do... something. Anything.",
	choices = {
		{ text = "Buy something expensive and impractical", resultText = "A sports car? A boat? Who cares - you deserve it.", effects = {Happiness = 10, Money = -25000}, flags = {set = {"midlife_crisis", "impulsive_buyer"}} },
		{ text = "Reconnect with an old dream", resultText = "That thing you always wanted to do? You finally try it.", effects = {Happiness = 12}, flags = {set = {"midlife_crisis", "dream_chaser"}} },
		{ text = "Accept where you are", resultText = "Maybe this IS the good life. Gratitude replaces regret.", effects = {Happiness = 8, Smarts = 3}, flags = {set = {"self_aware"}} },
		{ text = "Have an affair", resultText = "You make a choice you'll regret. Everything gets complicated.", effects = {Happiness = 5, Karma = -15}, flags = {set = {"affair", "relationship_complicated"}} },
	},
})

table.insert(events, {
	id = "adult_parents_aging",
	emoji = "👴",
	title = "Aging Parents",
	category = "family",
	weight = 14,
	oneTime = true,
	conditions = { minAge = 35, maxAge = 60 },
	text = "Your parents are getting older. They need more help. The roles are reversing.",
	choices = {
		{ text = "Step up and care for them", resultText = "It's hard, but they took care of you. Now it's your turn.", effects = {Happiness = -3, Karma = 10, Money = -5000}, flags = {set = {"caregiver", "family_oriented"}} },
		{ text = "Help when you can", resultText = "You do what you can while balancing your own life.", effects = {Karma = 5, Money = -2000} },
		{ text = "Arrange professional care", resultText = "You can't do it alone. Professionals help them stay comfortable.", effects = {Money = -10000, Karma = 3} },
	},
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- LATER ADULT LIFE (Ages 50-70)
-- ═══════════════════════════════════════════════════════════════════════════════

table.insert(events, {
	id = "senior_grandkids",
	emoji = "👨‍👧‍👦",
	title = "Becoming a Grandparent",
	category = "milestone",
	milestone = true,
	weight = 12,
	oneTime = true,
	conditions = { minAge = 45, maxAge = 75, requiredAnyFlags = {"parent", "has_child"} },
	text = "Your child just had a baby. You're a grandparent. The circle of life continues.",
	choices = {
		{ text = "Spoil them rotten", resultText = "That's what grandparents are for! Candy, toys, and unlimited love.", effects = {Happiness = 20}, flags = {set = {"grandparent"}} },
		{ text = "Be the cool grandparent", resultText = "You're going to teach them all the fun stuff.", effects = {Happiness = 15}, flags = {set = {"grandparent", "cool_grandparent"}} },
	},
})

table.insert(events, {
	id = "senior_empty_nest",
	emoji = "🪹",
	title = "Empty Nest",
	category = "milestone",
	weight = 12,
	oneTime = true,
	conditions = { minAge = 45, maxAge = 65, requiredAnyFlags = {"parent", "has_child"} },
	text = "The last kid moved out. The house is quiet. Too quiet. What do you do now?",
	choices = {
		{ text = "Enjoy the freedom!", resultText = "Travel, hobbies, date nights... this is YOUR time now!", effects = {Happiness = 12, Money = 5000}, flags = {set = {"empty_nester"}} },
		{ text = "Feel lost and lonely", resultText = "Your purpose was being a parent. Now what?", effects = {Happiness = -8}, flags = {set = {"empty_nester", "lonely"}} },
		{ text = "Start a new chapter", resultText = "New hobbies, new friends, new adventures await.", effects = {Happiness = 8}, flags = {set = {"empty_nester", "reinvented"}} },
	},
})

table.insert(events, {
	id = "senior_retirement",
	emoji = "🎣",
	title = "Retirement",
	category = "milestone",
	milestone = true,
	weight = 15,
	oneTime = true,
	conditions = { minAge = 55, maxAge = 75 },
	getDynamicData = function(state)
		return { savings = state.Money or 0 }
	end,
	text = "It's time. After decades of work, you're retiring. You have $%savings% saved up. The rest of your life is unstructured.",
	choices = {
		{ text = "Travel the world", resultText = "All those places you wanted to see? Time to check them off.", effects = {Happiness = 15, Money = -10000, Health = 3}, flags = {set = {"retired", "world_traveler"}} },
		{ text = "Relax and enjoy life", resultText = "Sleep in, garden, read. This is peace.", effects = {Happiness = 12, Health = 5}, flags = {set = {"retired"}} },
		{ text = "Start a passion project", resultText = "That thing you always wanted to do? Finally, you have time.", effects = {Happiness = 15, Smarts = 3}, flags = {set = {"retired", "active_retirement"}} },
		{ text = "Keep working part-time", resultText = "You're not ready to stop entirely. Structure helps.", effects = {Money = 10000, Happiness = 5}, flags = {set = {"semi_retired"}} },
	},
})

table.insert(events, {
	id = "senior_reflection",
	emoji = "🌅",
	title = "Looking Back",
	category = "milestone",
	weight = 12,
	oneTime = true,
	conditions = { minAge = 60, maxAge = 80 },
	text = "You sit quietly and think about your life. The choices, the memories, the people. Was it a good life?",
	choices = {
		{ text = "I lived fully. No regrets.", resultText = "Peace washes over you. Whatever comes next, you're ready.", effects = {Happiness = 15, Health = 5}, flags = {set = {"life_fulfilled"}} },
		{ text = "Some regrets, but mostly joy.", resultText = "Not everything went right, but that's life. And it was beautiful.", effects = {Happiness = 10}, flags = {set = {"life_content"}} },
		{ text = "So many things I wish I'd done differently.", resultText = "Regret is heavy. But it's not too late to make the time remaining matter.", effects = {Happiness = -5, Smarts = 2}, flags = {set = {"regretful"}} },
	},
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- RANDOM UNIVERSAL EVENTS (Any Age)
-- ═══════════════════════════════════════════════════════════════════════════════

table.insert(events, {
	id = "random_found_money",
	emoji = "💵",
	title = "Lucky Find",
	category = "random",
	weight = 10,
	oneTime = false,
	cooldownYears = 5,
	conditions = { minAge = 5, maxAge = 100 },
	getDynamicData = function(state)
		local amounts = {5, 20, 50, 100, 500}
		local locations = {"on the sidewalk", "in a jacket pocket", "in an old book", "under a couch cushion"}
		return { amount = amounts[math.random(#amounts)], location = locations[math.random(#locations)] }
	end,
	text = "You find $%amount% %location%! It's your lucky day!",
	choices = {
		{ text = "Keep it!", resultText = "Finders keepers!", effects = {Money = 50, Happiness = 5} },
		{ text = "Try to find the owner", chanceSuccess = 0.30, resultTextSuccess = "The owner is found and gives you a reward!", resultTextFail = "No owner found. Guess it's yours.", effectsOnSuccess = {Money = 100, Karma = 10, Happiness = 8}, effectsOnFail = {Money = 50, Karma = 3} },
	},
})

table.insert(events, {
	id = "random_rainy_day",
	emoji = "🌧️",
	title = "Rainy Day Mood",
	category = "random",
	weight = 12,
	oneTime = false,
	cooldownYears = 2,
	conditions = { minAge = 8, maxAge = 100 },
	text = "It's raining outside. The sound of rain on the window, the gray skies... what do you do?",
	choices = {
		{ text = "Cozy up with a book or movie", resultText = "Perfect rainy day vibes. Warm and content.", effects = {Happiness = 5, Health = 2} },
		{ text = "Go play in the rain", resultText = "Who cares about getting wet? This is fun!", effects = {Happiness = 8, Health = -1} },
		{ text = "Feel melancholy", resultText = "Sometimes rain makes you think too much.", effects = {Happiness = -2, Smarts = 1} },
	},
})

table.insert(events, {
	id = "random_stranger_kindness",
	emoji = "💝",
	title = "Kindness from a Stranger",
	category = "random",
	weight = 10,
	oneTime = false,
	cooldownYears = 3,
	conditions = { minAge = 10, maxAge = 100 },
	getDynamicData = function(state)
		local acts = {"paid for your coffee", "helped you when you dropped something", "gave you a genuine compliment", "let you go ahead in line", "helped you with directions"}
		return { act = acts[math.random(#acts)] }
	end,
	text = "A complete stranger %act%. Such a small thing, but it made your whole day.",
	choices = {
		{ text = "Pass the kindness forward", resultText = "You do something nice for someone else. The chain continues.", effects = {Happiness = 8, Karma = 5} },
		{ text = "Just appreciate the moment", resultText = "Faith in humanity restored, even a little.", effects = {Happiness = 6} },
	},
})

table.insert(events, {
	id = "random_bad_haircut",
	emoji = "✂️",
	title = "The Bad Haircut",
	category = "random",
	weight = 10,
	oneTime = false,
	cooldownYears = 4,
	conditions = { minAge = 8, maxAge = 80 },
	text = "Your haircut... did NOT turn out well. You look in the mirror in horror.",
	choices = {
		{ text = "Laugh it off", resultText = "Hair grows back. It's a funny story now.", effects = {Happiness = 2, Looks = -2} },
		{ text = "Try to fix it yourself", chanceSuccess = 0.30, resultTextSuccess = "Actually, you made it work!", resultTextFail = "You made it worse. Much worse.", effectsOnSuccess = {Looks = 1}, effectsOnFail = {Looks = -5, Happiness = -5} },
		{ text = "Wear a hat for a month", resultText = "Nobody will ever know.", effects = {Looks = -3} },
	},
})

table.insert(events, {
	id = "random_new_hobby",
	emoji = "🎯",
	title = "Discovering a New Hobby",
	category = "random",
	weight = 12,
	oneTime = false,
	cooldownYears = 3,
	conditions = { minAge = 10, maxAge = 80 },
	getDynamicData = function(state)
		local hobbies = {"photography", "cooking", "gardening", "hiking", "painting", "chess", "yoga", "collecting records", "birdwatching", "woodworking"}
		return { hobby = hobbies[math.random(#hobbies)] }
	end,
	text = "You try %hobby% for the first time, and... you love it!",
	choices = {
		{ text = "Dive in completely", resultText = "This becomes your new obsession (in a good way).", effects = {Happiness = 10, Smarts = 2}, flags = {set = {"hobbyist"}} },
		{ text = "Keep it as a casual interest", resultText = "Nice to have something new to enjoy.", effects = {Happiness = 5} },
	},
})

table.insert(events, {
	id = "random_nightmare",
	emoji = "😱",
	title = "The Nightmare",
	category = "random",
	weight = 10,
	oneTime = false,
	cooldownYears = 3,
	conditions = { minAge = 5, maxAge = 100 },
	text = "You wake up in a cold sweat from a terrifying nightmare. Your heart is racing.",
	choices = {
		{ text = "Shake it off and go back to sleep", resultText = "Just a dream. You drift off again.", effects = {Happiness = -1} },
		{ text = "Stay up the rest of the night", resultText = "Sleep isn't happening. You're exhausted tomorrow.", effects = {Health = -3, Happiness = -2} },
		{ text = "Analyze what it means", resultText = "Was your subconscious trying to tell you something?", effects = {Smarts = 1} },
	},
})

table.insert(events, {
	id = "random_won_prize",
	emoji = "🎰",
	title = "You Won Something!",
	category = "random",
	weight = 8,
	oneTime = false,
	cooldownYears = 5,
	conditions = { minAge = 10, maxAge = 100 },
	getDynamicData = function(state)
		local prizes = {"$100 in a scratch ticket", "a gift card", "a free meal", "concert tickets", "a small lottery prize"}
		return { prize = prizes[math.random(#prizes)] }
	end,
	text = "Against all odds, you won %prize%! Lucky day!",
	choices = {
		{ text = "Celebrate your luck!", resultText = "You're on top of the world!", effects = {Happiness = 10, Money = 100} },
		{ text = "Play more to win more", chanceSuccess = 0.20, resultTextSuccess = "You win again! What are the odds?!", resultTextFail = "You lose everything you won and then some. The house always wins.", effectsOnSuccess = {Money = 500, Happiness = 15}, effectsOnFail = {Money = -200, Happiness = -5} },
	},
})

table.insert(events, {
	id = "random_food_poisoning",
	emoji = "🤢",
	title = "Food Poisoning",
	category = "health",
	weight = 10,
	oneTime = false,
	cooldownYears = 4,
	conditions = { minAge = 8, maxAge = 100 },
	text = "Something you ate was NOT right. You spend the day praying to the porcelain god.",
	choices = {
		{ text = "Suffer through it", resultText = "24 hours of misery, then sweet relief.", effects = {Health = -5, Happiness = -3} },
		{ text = "Go to urgent care", resultText = "They give you something for the nausea. Worth the copay.", effects = {Health = -3, Money = -100} },
	},
})

table.insert(events, {
	id = "random_made_someone_smile",
	emoji = "😊",
	title = "You Made Someone's Day",
	category = "social",
	weight = 10,
	oneTime = false,
	cooldownYears = 2,
	conditions = { minAge = 8, maxAge = 100 },
	text = "Something you said or did made someone genuinely smile. It wasn't planned, it just happened.",
	choices = {
		{ text = "Feel warm inside", resultText = "Making others happy makes you happy too.", effects = {Happiness = 8, Karma = 5} },
		{ text = "Barely notice", resultText = "You were just being you.", effects = {Happiness = 3, Karma = 2} },
	},
})

table.insert(events, {
	id = "random_traffic_jam",
	emoji = "🚗",
	title = "Stuck in Traffic",
	category = "random",
	weight = 10,
	oneTime = false,
	cooldownYears = 2,
	conditions = { minAge = 16, maxAge = 100 },
	text = "You're stuck in traffic for hours. Nothing but brake lights as far as you can see.",
	choices = {
		{ text = "Rage and honk", resultText = "It doesn't help. Your blood pressure rises.", effects = {Happiness = -3, Health = -1} },
		{ text = "Listen to music/podcasts", resultText = "Might as well make the most of it.", effects = {Happiness = 2, Smarts = 1} },
		{ text = "Zen acceptance", resultText = "Can't change it. Deep breaths.", effects = {Happiness = 1} },
	},
})

table.insert(events, {
	id = "random_reconnect_old_friend",
	emoji = "👋",
	title = "Blast from the Past",
	category = "social",
	weight = 10,
	oneTime = false,
	cooldownYears = 5,
	conditions = { minAge = 18, maxAge = 90 },
	getDynamicData = function(state)
		local names = {"an old school friend", "a former coworker", "your childhood best friend", "someone from your past"}
		return { person = names[math.random(#names)] }
	end,
	text = "You randomly run into %person%! It's been years!",
	choices = {
		{ text = "Catch up over coffee", resultText = "You talk for hours. Some connections never die.", effects = {Happiness = 10} },
		{ text = "Exchange numbers to meet up later", resultText = "Maybe you will, maybe you won't. But it was nice seeing them.", effects = {Happiness = 5} },
		{ text = "Keep it brief and awkward", resultText = "Some people are best left in the past.", effects = {Happiness = -1} },
	},
})

table.insert(events, {
	id = "random_perfect_weather",
	emoji = "☀️",
	title = "Perfect Day",
	category = "random",
	weight = 12,
	oneTime = false,
	cooldownYears = 2,
	conditions = { minAge = 5, maxAge = 100 },
	text = "The weather is absolutely perfect today. Clear skies, comfortable temperature, gentle breeze.",
	choices = {
		{ text = "Spend the whole day outside", resultText = "You soak up every minute. What a day!", effects = {Happiness = 10, Health = 3} },
		{ text = "Appreciate it from inside", resultText = "Nice view from the window at least.", effects = {Happiness = 3} },
	},
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- ADDITIONAL UNIVERSAL EVENTS (More variety!)
-- ═══════════════════════════════════════════════════════════════════════════════

table.insert(events, {
	id = "random_lost_wallet",
	emoji = "👛",
	title = "Lost Wallet",
	category = "random",
	weight = 10,
	oneTime = false,
	cooldownYears = 5,
	conditions = { minAge = 14, maxAge = 100 },
	text = "You can't find your wallet anywhere. Panic sets in as you retrace your steps.",
	choices = {
		{ text = "Search frantically", chanceSuccess = 0.70, resultTextSuccess = "Found it! It was in your other pocket.", resultTextFail = "It's gone. Time to cancel all your cards.", effectsOnSuccess = {Happiness = 5}, effectsOnFail = {Money = -100, Happiness = -8} },
		{ text = "Accept the loss", resultText = "Annoying, but replaceable.", effects = {Money = -100, Happiness = -3} },
	},
})

table.insert(events, {
	id = "random_great_meal",
	emoji = "🍝",
	title = "The Best Meal Ever",
	category = "random",
	weight = 10,
	oneTime = false,
	cooldownYears = 3,
	conditions = { minAge = 10, maxAge = 100 },
	getDynamicData = function(state)
		local meals = {"a homemade dinner", "a restaurant meal", "street food", "grandma's cooking", "a new cuisine you'd never tried"}
		return { meal = meals[math.random(#meals)] }
	end,
	text = "You just had %meal%. It was incredible. Possibly the best thing you've ever tasted.",
	choices = {
		{ text = "Savor the memory", resultText = "You'll remember this meal forever.", effects = {Happiness = 8} },
		{ text = "Get the recipe/go back immediately", resultText = "You need this again. And again. And again.", effects = {Happiness = 10, Money = -50} },
	},
})

table.insert(events, {
	id = "random_achievement",
	emoji = "🏆",
	title = "Personal Achievement",
	category = "random",
	weight = 10,
	oneTime = false,
	cooldownYears = 2,
	conditions = { minAge = 10, maxAge = 100 },
	getDynamicData = function(state)
		local achievements = {"finished a difficult project", "overcame a fear", "reached a fitness goal", "learned a new skill", "fixed something broken"}
		return { achievement = achievements[math.random(#achievements)] }
	end,
	text = "You %achievement%! It took effort, but you did it.",
	choices = {
		{ text = "Feel proud of yourself", resultText = "You should! This is a real accomplishment.", effects = {Happiness = 10, Smarts = 2} },
		{ text = "Set an even bigger goal", resultText = "This was just the beginning.", effects = {Happiness = 5, Smarts = 3}, flags = {set = {"ambitious"}} },
	},
})

table.insert(events, {
	id = "random_broken_appliance",
	emoji = "🔧",
	title = "Something Broke",
	category = "random",
	weight = 10,
	oneTime = false,
	cooldownYears = 2,
	conditions = { minAge = 18, maxAge = 100 },
	getDynamicData = function(state)
		local items = {"your phone", "your car", "your computer", "your washing machine", "your refrigerator"}
		local costs = {200, 500, 800, 1000}
		return { item = items[math.random(#items)], cost = costs[math.random(#costs)] }
	end,
	text = "%item% just stopped working. The repair estimate is $%cost%.",
	choices = {
		{ text = "Pay for the repair", resultText = "Fixed, but ouch.", effects = {Money = -500, Happiness = -2} },
		{ text = "Try to fix it yourself", chanceSuccess = 0.40, resultTextSuccess = "YouTube tutorials for the win! You fixed it!", resultTextFail = "You made it worse. Now it's even more expensive.", effectsOnSuccess = {Smarts = 3, Happiness = 5}, effectsOnFail = {Money = -800, Happiness = -5} },
		{ text = "Just buy a new one", resultText = "Out with the old, in with the new.", effects = {Money = -1000, Happiness = 2} },
	},
})

table.insert(events, {
	id = "random_got_sick",
	emoji = "🤒",
	title = "Under the Weather",
	category = "health",
	weight = 12,
	oneTime = false,
	cooldownYears = 2,
	conditions = { minAge = 5, maxAge = 100 },
	text = "You catch a cold. Runny nose, sore throat, general misery.",
	choices = {
		{ text = "Rest and recover", resultText = "You take it easy and bounce back in a few days.", effects = {Health = -3, Happiness = -2} },
		{ text = "Push through it", resultText = "You refuse to let a cold slow you down... but it lingers longer.", effects = {Health = -5, Happiness = -1} },
		{ text = "Load up on medicine", resultText = "Pills, tea, soup - the works. You feel better fast.", effects = {Health = -2, Money = -50} },
	},
})

table.insert(events, {
	id = "random_compliment",
	emoji = "💬",
	title = "A Nice Compliment",
	category = "social",
	weight = 12,
	oneTime = false,
	cooldownYears = 2,
	conditions = { minAge = 8, maxAge = 100 },
	getDynamicData = function(state)
		local compliments = {"your outfit", "your work", "your personality", "something you said", "your smile"}
		return { subject = compliments[math.random(#compliments)] }
	end,
	text = "Someone genuinely compliments %subject%. It catches you off guard.",
	choices = {
		{ text = "Accept it gracefully", resultText = "Thank you! That made your day.", effects = {Happiness = 6, Looks = 1} },
		{ text = "Deflect awkwardly", resultText = "You never know how to handle compliments.", effects = {Happiness = 2} },
	},
})

table.insert(events, {
	id = "random_argument",
	emoji = "😤",
	title = "The Argument",
	category = "social",
	weight = 10,
	oneTime = false,
	cooldownYears = 2,
	conditions = { minAge = 12, maxAge = 100 },
	getDynamicData = function(state)
		local people = {"a family member", "a friend", "a coworker", "a stranger", "your partner"}
		return { person = people[math.random(#people)] }
	end,
	text = "You get into a heated argument with %person%. Tempers flare.",
	choices = {
		{ text = "Stand your ground", resultText = "You don't back down. Maybe you were right. Maybe not.", effects = {Happiness = -3, Karma = -1} },
		{ text = "Apologize and move on", resultText = "Life's too short for grudges.", effects = {Happiness = 1, Karma = 3} },
		{ text = "Walk away without resolution", resultText = "Some things are better left unsaid.", effects = {Happiness = -2} },
	},
})

table.insert(events, {
	id = "random_new_technology",
	emoji = "📱",
	title = "New Gadget",
	category = "lifestyle",
	weight = 10,
	oneTime = false,
	cooldownYears = 3,
	conditions = { minAge = 12, maxAge = 80 },
	getDynamicData = function(state)
		local gadgets = {"a new phone", "a smartwatch", "a gaming console", "a tablet", "a laptop"}
		return { gadget = gadgets[math.random(#gadgets)] }
	end,
	text = "You get %gadget%! That new device smell is intoxicating.",
	choices = {
		{ text = "Set it up immediately", resultText = "Hours disappear as you explore all the features.", effects = {Happiness = 8, Money = -500} },
		{ text = "Spend responsibly", resultText = "Nice to have, but not life-changing.", effects = {Happiness = 5, Money = -300} },
	},
})

table.insert(events, {
	id = "random_nostalgia",
	emoji = "📷",
	title = "Nostalgic Memory",
	category = "random",
	weight = 10,
	oneTime = false,
	cooldownYears = 3,
	conditions = { minAge = 15, maxAge = 100 },
	getDynamicData = function(state)
		local triggers = {"an old photo", "a song from your past", "a familiar smell", "an old item you found", "a place you visited"}
		return { trigger = triggers[math.random(#triggers)] }
	end,
	text = "%trigger% triggers a flood of memories. Suddenly you're transported back in time.",
	choices = {
		{ text = "Enjoy the warm memories", resultText = "Those were good times. You smile.", effects = {Happiness = 8} },
		{ text = "Feel a bittersweet longing", resultText = "You can't go back. But you can remember.", effects = {Happiness = 3, Smarts = 1} },
	},
})

table.insert(events, {
	id = "random_embarrassing_moment",
	emoji = "😳",
	title = "Embarrassing Moment",
	category = "random",
	weight = 10,
	oneTime = false,
	cooldownYears = 3,
	conditions = { minAge = 8, maxAge = 100 },
	getDynamicData = function(state)
		local moments = {"trip and fall in public", "say something stupid", "get caught doing something weird", "wave at someone who wasn't waving at you", "have something in your teeth all day"}
		return { moment = moments[math.random(#moments)] }
	end,
	text = "You %moment%. Your face turns red. Everyone saw. EVERYONE.",
	choices = {
		{ text = "Laugh it off", resultText = "If you can't laugh at yourself... Well, you can, so you do.", effects = {Happiness = 2, Looks = -1} },
		{ text = "Die inside", resultText = "You will remember this at 3 AM for years to come.", effects = {Happiness = -5} },
		{ text = "Own it confidently", resultText = "Power move. You turn awkward into awesome.", effects = {Happiness = 5}, flags = {set = {"confident"}} },
	},
})

table.insert(events, {
	id = "random_unexpected_gift",
	emoji = "🎁",
	title = "Unexpected Gift",
	category = "random",
	weight = 8,
	oneTime = false,
	cooldownYears = 4,
	conditions = { minAge = 5, maxAge = 100 },
	getDynamicData = function(state)
		local gifts = {"a thoughtful present", "money from a relative", "a surprise package in the mail", "a gift card", "something you mentioned wanting"}
		return { gift = gifts[math.random(#gifts)] }
	end,
	text = "You receive %gift%! You weren't expecting anything, which makes it even better.",
	choices = {
		{ text = "Feel grateful and touched", resultText = "Someone thought of you. That means a lot.", effects = {Happiness = 10, Money = 50} },
		{ text = "Plan a thank you", resultText = "You'll find a way to return the kindness.", effects = {Happiness = 8, Karma = 3} },
	},
})

table.insert(events, {
	id = "random_volunteer",
	emoji = "🤝",
	title = "Helping Others",
	category = "social",
	weight = 10,
	oneTime = false,
	cooldownYears = 2,
	conditions = { minAge = 12, maxAge = 100 },
	getDynamicData = function(state)
		local activities = {"at a food bank", "cleaning up a park", "helping a neighbor", "tutoring kids", "visiting a nursing home"}
		return { activity = activities[math.random(#activities)] }
	end,
	text = "You spend time volunteering %activity%. It's not glamorous, but it matters.",
	choices = {
		{ text = "Feel fulfilled", resultText = "Making a difference feels amazing.", effects = {Happiness = 10, Karma = 10} },
		{ text = "Commit to doing more", resultText = "This becomes a regular part of your life.", effects = {Happiness = 8, Karma = 15}, flags = {set = {"volunteer", "charitable"}} },
	},
})

table.insert(events, {
	id = "random_cooking_disaster",
	emoji = "🔥",
	title = "Kitchen Disaster",
	category = "random",
	weight = 10,
	oneTime = false,
	cooldownYears = 3,
	conditions = { minAge = 15, maxAge = 100 },
	text = "You try to cook something ambitious and it goes horribly wrong. Smoke everywhere.",
	choices = {
		{ text = "Order takeout and never speak of this", resultText = "We don't talk about what happened in the kitchen.", effects = {Happiness = 2, Money = -30} },
		{ text = "Eat it anyway", resultText = "It's... edible. Barely. Character building.", effects = {Happiness = -2, Health = -1} },
		{ text = "Learn from the mistake", resultText = "You figure out what went wrong. Next time will be better.", effects = {Smarts = 2}, flags = {set = {"learning_to_cook"}} },
	},
})

table.insert(events, {
	id = "random_late_night",
	emoji = "🌙",
	title = "Late Night Thoughts",
	category = "random",
	weight = 10,
	oneTime = false,
	cooldownYears = 2,
	conditions = { minAge = 14, maxAge = 100 },
	text = "You can't sleep. Your mind races through random thoughts, worries, and ideas.",
	choices = {
		{ text = "Write down your thoughts", resultText = "Getting it out helps. You feel clearer.", effects = {Smarts = 2, Happiness = 2} },
		{ text = "Watch videos until you pass out", resultText = "You'll regret this tomorrow. Worth it.", effects = {Happiness = 2, Health = -2} },
		{ text = "Practice relaxation techniques", resultText = "Deep breaths. Eventually, sleep comes.", effects = {Health = 1} },
	},
})

table.insert(events, {
	id = "random_good_news",
	emoji = "📰",
	title = "Great News!",
	category = "random",
	weight = 8,
	oneTime = false,
	cooldownYears = 3,
	conditions = { minAge = 10, maxAge = 100 },
	getDynamicData = function(state)
		local news = {"you got a small raise", "a friend had great news to share", "something you applied for came through", "good news about your health", "an event you were excited about got confirmed"}
		return { newsItem = news[math.random(#news)] }
	end,
	text = "You receive good news: %newsItem%!",
	choices = {
		{ text = "Celebrate!", resultText = "Good things deserve celebration!", effects = {Happiness = 12, Money = 200} },
		{ text = "Share the joy", resultText = "You tell people who care. Their happiness amplifies yours.", effects = {Happiness = 10} },
	},
})

table.insert(events, {
	id = "random_bad_news",
	emoji = "😔",
	title = "Disappointing News",
	category = "random",
	weight = 8,
	oneTime = false,
	cooldownYears = 3,
	conditions = { minAge = 10, maxAge = 100 },
	getDynamicData = function(state)
		local news = {"something you hoped for didn't happen", "plans got cancelled", "you didn't get what you applied for", "minor setback at work", "something broke that can't be fixed"}
		return { newsItem = news[math.random(#news)] }
	end,
	text = "You receive disappointing news: %newsItem%.",
	choices = {
		{ text = "Let yourself feel sad", resultText = "It's okay to be disappointed. This too shall pass.", effects = {Happiness = -5} },
		{ text = "Find a silver lining", resultText = "Every closed door... something about windows. You cope.", effects = {Happiness = -2, Smarts = 1} },
		{ text = "Distract yourself", resultText = "You throw yourself into something else.", effects = {Happiness = -1} },
	},
})

table.insert(events, {
	id = "random_exercise",
	emoji = "🏃",
	title = "Getting Active",
	category = "health",
	weight = 12,
	oneTime = false,
	cooldownYears = 2,
	conditions = { minAge = 10, maxAge = 80 },
	getDynamicData = function(state)
		local activities = {"go for a run", "hit the gym", "do yoga", "take a long walk", "try a new workout"}
		return { activity = activities[math.random(#activities)] }
	end,
	text = "You decide to %activity%. Time to get the blood pumping!",
	choices = {
		{ text = "Push yourself hard", resultText = "You're sore tomorrow, but stronger today.", effects = {Health = 8, Looks = 2, Happiness = 5} },
		{ text = "Take it easy", resultText = "Movement is movement. Good job.", effects = {Health = 4, Happiness = 3} },
		{ text = "Quit halfway through", resultText = "At least you tried... kind of.", effects = {Health = 1, Happiness = -1} },
	},
})

table.insert(events, {
	id = "random_deep_conversation",
	emoji = "💭",
	title = "Heart to Heart",
	category = "social",
	weight = 10,
	oneTime = false,
	cooldownYears = 2,
	conditions = { minAge = 15, maxAge = 100 },
	getDynamicData = function(state)
		local people = {"a close friend", "a family member", "someone unexpected", "your partner", "a mentor"}
		return { person = people[math.random(#people)] }
	end,
	text = "You have a deep, meaningful conversation with %person%. Real connection happens.",
	choices = {
		{ text = "Open up about your feelings", resultText = "Vulnerability leads to deeper understanding.", effects = {Happiness = 10, Smarts = 2} },
		{ text = "Listen more than you speak", resultText = "Sometimes the best thing is to just be present.", effects = {Happiness = 8, Karma = 3} },
	},
})

table.insert(events, {
	id = "random_movie_night",
	emoji = "🎬",
	title = "Movie Night",
	category = "leisure",
	weight = 12,
	oneTime = false,
	cooldownYears = 1,
	conditions = { minAge = 8, maxAge = 100 },
	getDynamicData = function(state)
		local genres = {"an action movie", "a comedy", "a tearjerker drama", "a thriller", "a classic you'd never seen"}
		return { movie = genres[math.random(#genres)] }
	end,
	text = "You settle in to watch %movie%. Snacks ready, lights dim.",
	choices = {
		{ text = "Get completely absorbed", resultText = "You forget about everything else for two hours. Perfect escape.", effects = {Happiness = 6} },
		{ text = "Fall asleep halfway through", resultText = "To be fair, you were tired.", effects = {Happiness = 2, Health = 2} },
	},
})

table.insert(events, {
	id = "random_learned_something",
	emoji = "💡",
	title = "A-Ha Moment",
	category = "random",
	weight = 10,
	oneTime = false,
	cooldownYears = 2,
	conditions = { minAge = 8, maxAge = 100 },
	getDynamicData = function(state)
		local topics = {"how something works", "a new perspective", "an interesting fact", "a life lesson", "something about yourself"}
		return { topic = topics[math.random(#topics)] }
	end,
	text = "You learn %topic%. A lightbulb goes off in your head!",
	choices = {
		{ text = "Embrace the knowledge", resultText = "Learning is living!", effects = {Smarts = 5, Happiness = 4} },
		{ text = "Share what you learned", resultText = "You love telling people about it.", effects = {Smarts = 3, Happiness = 3} },
	},
})

table.insert(events, {
	id = "random_pet_encounter",
	emoji = "🐕",
	title = "Animal Encounter",
	category = "random",
	weight = 10,
	oneTime = false,
	cooldownYears = 2,
	conditions = { minAge = 3, maxAge = 100 },
	getDynamicData = function(state)
		local animals = {"a friendly dog", "a cute cat", "a squirrel", "a bird", "someone's adorable pet"}
		return { animal = animals[math.random(#animals)] }
	end,
	text = "You encounter %animal% and it makes your day better.",
	choices = {
		{ text = "Pet it (if possible)", resultText = "Soft. Fluffy. Perfect.", effects = {Happiness = 8} },
		{ text = "Admire from afar", resultText = "Nature is beautiful.", effects = {Happiness = 5} },
	},
})

table.insert(events, {
	id = "random_birthday",
	emoji = "🎂",
	title = "Your Birthday",
	category = "milestone",
	weight = 20,
	oneTime = false,
	cooldownYears = 1,
	conditions = { minAge = 1, maxAge = 100 },
	getDynamicData = function(state)
		return { age = state.Age or 1 }
	end,
	text = "Happy Birthday! You're now %age% years old! Time to celebrate!",
	choices = {
		{ text = "Throw a party", resultText = "Friends, cake, and good times!", effects = {Happiness = 15, Money = -100} },
		{ text = "Keep it low-key", resultText = "Just a quiet celebration. Perfect.", effects = {Happiness = 8} },
		{ text = "Treat yourself", resultText = "You buy yourself something nice.", effects = {Happiness = 10, Money = -200} },
	},
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- Return all events
-- ═══════════════════════════════════════════════════════════════════════════════

print("[general_life_events] Loaded", #events, "general life events")

return {events = events}
