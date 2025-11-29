-- NarrativeContent.lua
-- BitLife-style narrative text generation for rich storytelling
-- Contains templates for stat changes, money events, flags, and life stages

local NarrativeContent = {}

----------------------------------------------------------------------
-- STAT NARRATIVE TEMPLATES
----------------------------------------------------------------------

NarrativeContent.StatNarrative = {
	Happiness = {
		up = {
			small = {
				"You feel a bit more cheerful.",
				"A small smile crosses your face.",
				"Things are looking up a little.",
			},
			medium = {
				"You're feeling pretty good about life!",
				"Your mood has noticeably improved.",
				"A wave of contentment washes over you.",
			},
			big = {
				"You're absolutely thrilled!",
				"Life feels wonderful right now.",
				"You can't stop smiling!",
			},
			huge = {
				"You've never been happier in your entire life!",
				"Pure joy fills every fiber of your being!",
				"This is what cloud nine feels like!",
			},
		},
		down = {
			small = {
				"You feel a bit down.",
				"Your mood dips slightly.",
				"Something's bothering you.",
			},
			medium = {
				"You're feeling pretty sad.",
				"A cloud of gloom settles over you.",
				"You're having a rough time.",
			},
			big = {
				"You're really struggling emotionally.",
				"Deep sadness grips your heart.",
				"Everything feels hopeless.",
			},
			huge = {
				"You've hit rock bottom emotionally.",
				"Depression consumes you entirely.",
				"You've never felt this miserable.",
			},
		},
	},
	Health = {
		up = {
			small = {
				"You feel slightly healthier.",
				"Your body feels a bit better.",
				"You're on the mend.",
			},
			medium = {
				"Your health is improving nicely!",
				"You feel much more energetic.",
				"Your body is recovering well.",
			},
			big = {
				"You feel amazing! Full of energy!",
				"Your health has made a remarkable recovery!",
				"You're in great shape!",
			},
			huge = {
				"You're in peak physical condition!",
				"You've never felt this healthy before!",
				"Your body is a temple of wellness!",
			},
		},
		down = {
			small = {
				"You feel a bit under the weather.",
				"Your body aches slightly.",
				"You're not feeling 100%.",
			},
			medium = {
				"Your health is declining.",
				"You're feeling pretty sick.",
				"Your body is struggling.",
			},
			big = {
				"Your health has taken a serious hit.",
				"You're in bad shape physically.",
				"Your body is failing you.",
			},
			huge = {
				"You're gravely ill.",
				"Your health is in critical condition.",
				"Death feels closer than ever.",
			},
		},
	},
	Smarts = {
		up = {
			small = {
				"You learned something new today.",
				"Your mind feels a bit sharper.",
				"You had a small intellectual breakthrough.",
			},
			medium = {
				"Your intelligence is growing!",
				"You're getting noticeably smarter.",
				"Your brain power is increasing.",
			},
			big = {
				"You're becoming quite the intellectual!",
				"Your mental abilities have improved dramatically!",
				"People notice how smart you've become!",
			},
			huge = {
				"You're approaching genius-level intellect!",
				"Your mind is incredibly sharp!",
				"You could outsmart almost anyone!",
			},
		},
		down = {
			small = {
				"You feel a bit foggy mentally.",
				"Your mind seems slightly duller.",
				"You forgot something important.",
			},
			medium = {
				"Your mental sharpness is declining.",
				"You're having trouble thinking clearly.",
				"Your brain feels sluggish.",
			},
			big = {
				"Your cognitive abilities are suffering.",
				"You're struggling to think straight.",
				"Mental tasks are becoming difficult.",
			},
			huge = {
				"Your mental faculties are severely impaired.",
				"You can barely think anymore.",
				"Your mind is in a fog.",
			},
		},
	},
	Looks = {
		up = {
			small = {
				"You look slightly better today.",
				"Your appearance has improved a bit.",
				"You're glowing a little more.",
			},
			medium = {
				"You're looking good!",
				"People are noticing your improved appearance.",
				"You feel more attractive.",
			},
			big = {
				"You look absolutely stunning!",
				"Heads turn when you walk by!",
				"Your beauty is undeniable!",
			},
			huge = {
				"You're drop-dead gorgeous!",
				"You could be a model!",
				"Your looks are absolutely breathtaking!",
			},
		},
		down = {
			small = {
				"You're not looking your best today.",
				"Your appearance has slipped a bit.",
				"You look a little tired.",
			},
			medium = {
				"Your looks are declining.",
				"You're not as attractive as you used to be.",
				"The mirror isn't being kind.",
			},
			big = {
				"Your appearance has taken a hit.",
				"You're looking rough these days.",
				"People avoid looking at you.",
			},
			huge = {
				"Your looks have completely deteriorated.",
				"You're barely recognizable.",
				"Mirrors have become your enemy.",
			},
		},
	},
}

----------------------------------------------------------------------
-- MONEY NARRATIVE TEMPLATES
----------------------------------------------------------------------

NarrativeContent.MoneyNarrative = {
	gain = {
		small = {
			"You earned a bit of pocket money.",
			"A small windfall comes your way.",
			"You found some extra cash.",
		},
		medium = {
			"You made a nice chunk of change!",
			"Your bank account is looking healthier.",
			"That's some serious money!",
		},
		large = {
			"You hit the jackpot!",
			"You're swimming in cash!",
			"That's life-changing money!",
		},
	},
	loss = {
		small = {
			"You spent a bit of money.",
			"A small expense came up.",
			"You're a little lighter in the wallet.",
		},
		medium = {
			"That was an expensive mistake.",
			"Your savings took a hit.",
			"Money flies out the window.",
		},
		large = {
			"You lost a fortune!",
			"Financial disaster strikes!",
			"You're hemorrhaging money!",
		},
	},
}

----------------------------------------------------------------------
-- FLAG DESCRIPTIONS
----------------------------------------------------------------------

NarrativeContent.FlagDescriptions = {
	-- Political path
	political_interest = "🏛️ You've developed an interest in politics.",
	political_experience = "🏛️ You're gaining political experience.",
	political_volunteer = "🏛️ You've started volunteering for political campaigns.",
	elected_official = "🏛️ You've been elected to public office!",
	city_council = "🏙️ You're now on the city council!",
	mayor = "🏙️ You've become the mayor!",
	state_representative = "🏛️ You're a state representative!",
	state_senator = "🏛️ You're a state senator!",
	governor = "🏛️ You've been elected governor!",
	congressman = "🏛️ You're a member of Congress!",
	us_senator = "🏛️ You're a U.S. Senator!",
	president = "🏛️ You've become President of the United States!",
	
	-- Criminal path
	criminal_tendencies = "😈 You're developing criminal tendencies...",
	petty_thief = "🕵️ You've become a petty thief.",
	shoplifter = "🛒 You've taken up shoplifting.",
	car_thief = "🚗 You're now stealing cars.",
	burglar = "🏠 You've become a burglar.",
	drug_dealer = "💊 You're dealing drugs now.",
	gang_prospect = "⛓️ You're being considered for gang membership.",
	gang_member = "⛓️ You've joined a gang!",
	gang_captain = "⛓️ You're now a gang captain!",
	underboss = "💀 You've risen to underboss!",
	crime_boss = "👑 You're the crime boss now!",
	kingpin = "👑 You've become a kingpin!",
	
	-- Education
	college_graduate = "🎓 You graduated from college!",
	graduate_degree = "🎓 You earned a graduate degree!",
	doctorate = "🎓 You earned your doctorate!",
	
	-- Relationships
	in_love = "💕 You've fallen in love!",
	engaged = "💍 You're engaged!",
	married = "💒 You got married!",
	has_children = "👶 You have children!",
	divorced = "💔 You got divorced.",
	widowed = "🖤 You've been widowed.",
	
	-- Wealth
	millionaire = "💰 You're a millionaire!",
	billionaire = "💎 You're a billionaire!",
	bankrupt = "📉 You've gone bankrupt.",
	homeless = "🏚️ You're homeless.",
	
	-- Career milestones
	teacher = "📚 You've become a teacher!",
	principal = "📚 You're now a principal!",
	superintendent = "📚 You're the superintendent!",
	f1_driver = "🏎️ You're an F1 driver!",
	world_champion = "🏆 You're a world champion!",
	racing_legend = "🏎️ You're a racing legend!",
	elite_hacker = "💻 You're an elite hacker!",
	famous_artist = "🎨 You're a famous artist!",
	
	-- Legal
	in_prison = "🔒 You're in prison.",
	ex_con = "⛓️ You're an ex-convict.",
	escaped_prison = "🔓 You escaped from prison!",
	
	-- Personality
	brave = "🦁 You're known for your bravery.",
	compassionate = "❤️ You're known for compassion.",
	creative_mind = "🎨 You have a creative mind.",
}

----------------------------------------------------------------------
-- YEAR RECAP TEMPLATES
----------------------------------------------------------------------

NarrativeContent.YearRecapTemplates = {
	-- Life stages
	baby = {
		"At age %d, you're still figuring out this whole 'existing' thing.",
		"Year %d: mostly crying, eating, and sleeping.",
	},
	toddler = {
		"At %d, you're discovering the world one tantrum at a time.",
		"Year %d: everything is fascinating and terrifying.",
	},
	early_childhood = {
		"At %d, school is your whole world.",
		"Year %d: making friends and learning stuff.",
	},
	childhood = {
		"At %d, life is still pretty simple.",
		"Year %d: childhood adventures continue.",
	},
	tween = {
		"At %d, you're not a kid but not quite a teen.",
		"Year %d: the awkward years begin.",
	},
	teenage = {
		"At %d, everything feels intense.",
		"Year %d: teenage drama and dreams.",
	},
	young_adult = {
		"At %d, you're building your life.",
		"Year %d: the world is your oyster.",
	},
	adult = {
		"At %d, life is in full swing.",
		"Year %d: adulting continues.",
	},
	senior = {
		"At %d, you reflect on a life well-lived.",
		"Year %d: enjoying your golden years.",
	},
	elderly = {
		"At %d, every day is precious.",
		"Year %d: cherishing what matters most.",
	},
	
	-- Special paths
	criminal_path = {
		"Year %d in the criminal underworld...",
		"At %d, you walk the path of shadows.",
	},
	political_path = {
		"Year %d in the political arena...",
		"At %d, you navigate the halls of power.",
	},
	racer_path = {
		"Year %d on the racing circuit...",
		"At %d, speed is your life.",
	},
	teacher_path = {
		"Year %d shaping young minds...",
		"At %d, you continue to inspire students.",
	},
	artist_path = {
		"Year %d as an artist...",
		"At %d, you create beauty.",
	},
	hacker_path = {
		"Year %d in the digital underground...",
		"At %d, code is your weapon.",
	},
	romantic_path = {
		"Year %d of love and romance...",
		"At %d, your heart is full.",
	},
	wealthy_path = {
		"Year %d of wealth and luxury...",
		"At %d, money is no object.",
	},
	struggling_path = {
		"Year %d of hard times...",
		"At %d, you're fighting to survive.",
	},
}

----------------------------------------------------------------------
-- LIFE STAGE TRANSITIONS
----------------------------------------------------------------------

NarrativeContent.LifeStageTransitions = {
	toddler = {
		emoji = "👶",
		title = "Growing Up!",
		text = "You're no longer a baby! You can walk and talk now.",
	},
	early_childhood = {
		emoji = "🎒",
		title = "School Time!",
		text = "Time for your first day of school!",
	},
	childhood = {
		emoji = "🚸",
		title = "Getting Bigger!",
		text = "You're growing up so fast!",
	},
	tween = {
		emoji = "😬",
		title = "The Tween Years",
		text = "Welcome to the awkward years.",
	},
	teenage = {
		emoji = "🎸",
		title = "Teenage Dreams",
		text = "You're officially a teenager!",
	},
	young_adult = {
		emoji = "🎓",
		title = "Adulthood Begins!",
		text = "You're an adult now. The world awaits!",
	},
	adult = {
		emoji = "💼",
		title = "Prime Years",
		text = "You're in the prime of your life.",
	},
	senior = {
		emoji = "👴",
		title = "Golden Years",
		text = "Time to enjoy your retirement.",
	},
	elderly = {
		emoji = "🕯️",
		title = "Twilight Years",
		text = "Every moment is precious now.",
	},
}

----------------------------------------------------------------------
-- RELATIONSHIP LINES
----------------------------------------------------------------------

NarrativeContent.RelationshipLines = {
	family = {
		positive = {
			"Your bond with %s grows stronger.",
			"You and %s share a heartfelt moment.",
			"%s tells you they love you.",
		},
		negative = {
			"Things are tense with %s.",
			"You had an argument with %s.",
			"%s seems distant lately.",
		},
	},
	friends = {
		positive = {
			"You and %s had a great time together!",
			"%s is such a good friend.",
			"Your friendship with %s deepens.",
		},
		negative = {
			"You're drifting apart from %s.",
			"%s said something hurtful.",
			"Your friendship with %s is strained.",
		},
	},
	lovers = {
		positive = {
			"You and %s are deeply in love.",
			"%s makes your heart flutter.",
			"Romance blooms with %s.",
		},
		negative = {
			"Things are rocky with %s.",
			"You and %s had a fight.",
			"The spark with %s is fading.",
		},
	},
}

return NarrativeContent
