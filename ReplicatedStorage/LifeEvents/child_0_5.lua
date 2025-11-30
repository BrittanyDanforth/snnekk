-- LifeEvents/child_0_5.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- EARLY CHILDHOOD EVENTS (Ages 0-5) - MASSIVE EXPANSION
-- 100+ deeply thought-out events for infant, toddler, and preschool years
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent.init)

local module = {}

module.events = {

	-- ═══════════════════════════════════════════════════════════════
	-- BIRTH & NEWBORN (Age 0)
	-- ═══════════════════════════════════════════════════════════════

	{
		id = "m_birth",
		minAge = 0, maxAge = 0,
		weight = 100, milestone = true, oneTime = true,
		emoji = "👶", title = "You Are Born!",
		category = "family",
		text = "You came into this world, a tiny bundle of possibility. Your life begins now.",
		choices = {
			{ text = "😭 Cry loudly", effects = { Health = 2, Happiness = 1 }, resultText = "Your strong lungs impressed the doctors. 'What a healthy set of lungs!' they exclaimed." },
			{ text = "😴 Sleep peacefully", effects = { Health = 3, Happiness = 3 }, resultText = "You were a calm, peaceful baby. The nurses called you 'the angel.'" },
			{ text = "👀 Look around curiously", effects = { Smarts = 4 }, resultText = "You observed everything with wide, curious eyes. Already trying to figure out this strange new world." },
		},
	},

	{
		id = "m_birth_complications",
		minAge = 0, maxAge = 0,
		weight = 8, oneTime = true,
		emoji = "🏥", title = "Birth Complications",
		category = "health",
		text = "Your birth was difficult. The doctors had to intervene to make sure you were okay.",
		choices = {
			{ text = "💪 Fight through", effects = { Health = -5, Happiness = -2 }, resultText = "After a scary few hours, you pulled through. You're a fighter from day one.", setFlag = "difficult_birth" },
			{ text = "🏥 NICU stay", effects = { Health = -8, Smarts = 2 }, resultText = "You spent your first weeks in the NICU. But you made it.", setFlag = "premature" },
		},
	},

	{
		id = "m_birth_twin",
		minAge = 0, maxAge = 0,
		weight = 5, oneTime = true,
		emoji = "👶👶", title = "You Have a Twin!",
		category = "family",
		getDynamicData = function()
			local types = {"identical", "fraternal"}
			return { twinType = types[math.random(#types)] }
		end,
		text = "Surprise! You're a %twinType% twin! You have a built-in best friend from birth.",
		choices = {
			{ text = "👶 Bond with twin", effects = { Happiness = 8 }, resultText = "You and your twin share everything - even a womb!", setFlags = {"has_twin", "has_sibling"} },
			{ text = "😤 Compete for attention", effects = { Happiness = 2, Smarts = 2 }, resultText = "Even now, you're vying for your parents' attention.", setFlags = {"has_twin", "competitive_sibling"} },
		},
	},

	{
		id = "m_first_breath",
		minAge = 0, maxAge = 0,
		weight = 60, oneTime = true,
		emoji = "💨", title = "First Breath",
		category = "health",
		text = "The moment you took your first breath, the world became real. Air filled your lungs for the very first time.",
		choices = {
			{ text = "😭 Let out a wail", effects = { Health = 3 }, resultText = "Your cry echoed through the delivery room - music to your parents' ears." },
			{ text = "😮 Gasp quietly", effects = { Health = 2, Smarts = 2 }, resultText = "You took it all in silently, already processing this new world." },
		},
	},

	{
		id = "m_first_smile",
		minAge = 0, maxAge = 1,
		weight = 60, oneTime = true,
		emoji = "😊", title = "First Smile!",
		category = "family",
		text = "You smiled for the first time! Your parents' hearts melted into puddles of joy.",
		choices = {
			{ text = "😄 Smile more!", effects = { Happiness = 6, Looks = 2 }, resultText = "Your smile became your superpower. Everyone fell in love with you." },
			{ text = "🤗 Reach for a hug", effects = { Happiness = 7 }, resultText = "You reached out for human connection. Your parents cried happy tears!" },
			{ text = "😏 Cheeky grin", effects = { Happiness = 5, Smarts = 2 }, resultText = "There was mischief in that smile. Trouble ahead!" },
		},
	},

	{
		id = "m_first_laugh",
		minAge = 0, maxAge = 1,
		weight = 50, oneTime = true,
		emoji = "😂", title = "First Laugh!",
		category = "family",
		text = "Something made you laugh for the first time! Your giggle was the most beautiful sound your parents ever heard.",
		choices = {
			{ text = "😂 Keep laughing!", effects = { Happiness = 10 }, resultText = "Your infectious laughter became the soundtrack of the household!" },
			{ text = "🤭 Shy giggle", effects = { Happiness = 6, Looks = 3 }, resultText = "Your cute little giggle melted everyone's hearts." },
			{ text = "😈 Laughing at chaos", effects = { Happiness = 7, Smarts = 2 }, resultText = "You laughed when something fell. Already finding joy in mischief!", setFlag = "mischievous" },
		},
	},

	{
		id = "m_first_crawl",
		minAge = 0, maxAge = 1,
		weight = 55, oneTime = true,
		emoji = "🐛", title = "First Crawl!",
		category = "family",
		text = "You started crawling! Freedom! Nothing is safe anymore. Your parents scramble to baby-proof everything.",
		choices = {
			{ text = "🏃 Crawl everywhere!", effects = { Health = 4, Smarts = 2 }, resultText = "You became an unstoppable explorer. Every corner must be investigated!" },
			{ text = "🧸 Crawl to toys", effects = { Happiness = 5 }, resultText = "You made a beeline for your favorite teddy bear every time." },
			{ text = "🚪 Crawl for escape", effects = { Smarts = 4, Health = 2 }, resultText = "Already trying to explore beyond your boundaries!", setFlag = "adventurous" },
		},
	},

	{
		id = "m_first_word",
		minAge = 1, maxAge = 2,
		weight = 80, oneTime = true,
		emoji = "🗣️", title = "First Word!",
		category = "family",
		text = "The moment everyone's been waiting for! You're about to speak your first word...",
		choices = {
			{ text = "👩 Say 'Mama'", effects = { Happiness = 6 }, resultText = "Your mother burst into tears of joy. She'll never forget this moment." },
			{ text = "👨 Say 'Dada'", effects = { Happiness = 6 }, resultText = "Your father puffed up with pride. He'll tell this story forever." },
			{ text = "🙅 Say 'NO!'", effects = { Happiness = 4, Smarts = 4 }, resultText = "Your rebellious streak started early! The terrible twos are coming.", setFlag = "strong_willed" },
			{ text = "🐕 Say 'Dog!'", effects = { Happiness = 5, Smarts = 3 }, resultText = "Your first word was about the family pet! Animal lover in the making.", setFlag = "animal_lover" },
		},
	},

	{
		id = "m_first_steps",
		minAge = 1, maxAge = 2,
		weight = 75, oneTime = true, milestone = true,
		emoji = "🚶", title = "First Steps!",
		category = "family",
		text = "You pulled yourself up, wobbled, and took your very first steps! The whole family cheered!",
		choices = {
			{ text = "🏃 Try to run!", effects = { Health = 5, Happiness = 4 }, resultText = "You fell down but immediately got back up. Unstoppable!", setFlag = "determined" },
			{ text = "👐 Walk to parent", effects = { Happiness = 8 }, resultText = "You walked right into their waiting arms. Pure love!" },
			{ text = "🤸 Dance around", effects = { Happiness = 6, Looks = 3 }, resultText = "You've got natural rhythm! Already celebrating your achievement!" },
			{ text = "💥 Crash into furniture", effects = { Health = -2, Smarts = 2 }, resultText = "Learning to walk comes with bumps and bruises. You're okay!" },
		},
	},

	{
		id = "m_first_birthday",
		minAge = 1, maxAge = 1,
		weight = 100, oneTime = true, milestone = true,
		emoji = "🎂", title = "First Birthday!",
		category = "family",
		text = "Happy birthday! You're 1 year old! There's cake, decorations, and so many people who love you.",
		choices = {
			{ text = "🎂 Smash the cake!", effects = { Happiness = 10 }, resultText = "You made a glorious mess! Frosting everywhere, and you loved every second!" },
			{ text = "🤔 What is this?", effects = { Smarts = 4, Happiness = 4 }, resultText = "You examined the cake curiously before cautiously taking a bite." },
			{ text = "😭 Too many people!", effects = { Happiness = -3 }, resultText = "All those strangers overwhelmed you. It's okay, little one." },
			{ text = "🎁 Love the presents!", effects = { Happiness = 8 }, resultText = "You were more interested in the wrapping paper than the actual gifts!" },
		},
	},

	-- ═══════════════════════════════════════════════════════════════
	-- FIRST YEAR EXPERIENCES (Age 0-1)
	-- ═══════════════════════════════════════════════════════════════

	{
		id = "m_first_bath",
		minAge = 0, maxAge = 1,
		weight = 40, oneTime = true,
		emoji = "🛁", title = "First Bath!",
		category = "family",
		text = "Time for your very first bath! The warm water is a new sensation.",
		choices = {
			{ text = "🛁 Love it!", effects = { Happiness = 6, Health = 2 }, resultText = "You splashed and giggled! Bath time became your favorite!" },
			{ text = "😭 Hate it!", effects = { Happiness = -4 }, resultText = "You screamed the entire time. Water is scary!" },
			{ text = "🦆 Fascinated by duck", effects = { Happiness = 5, Smarts = 2 }, resultText = "The rubber ducky became your obsession!" },
		},
	},

	{
		id = "m_teething_begins",
		minAge = 0, maxAge = 1,
		weight = 45, oneTime = true,
		emoji = "🦷", title = "Teething Begins!",
		category = "health",
		text = "Your first teeth are coming in! It's uncomfortable and everything goes in your mouth.",
		choices = {
			{ text = "😤 Be fussy", effects = { Happiness = -5, Health = 1 }, resultText = "You were miserable and let everyone know. Those teeth hurt!" },
			{ text = "🧊 Love the teether", effects = { Happiness = 2, Health = 2 }, resultText = "The cold teething ring became your best friend." },
			{ text = "💪 Tough it out", effects = { Health = 3, Happiness = -2 }, resultText = "You handled it better than expected. Strong baby!", setFlag = "tough_baby" },
		},
	},

	{
		id = "m_baby_sick",
		minAge = 0, maxAge = 2,
		weight = 30, cooldown = 2,
		emoji = "🤒", title = "Baby Gets Sick",
		category = "health",
		getDynamicData = function()
			local illnesses = {"cold", "ear infection", "fever", "cough", "tummy bug"}
			return { illness = illnesses[math.random(#illnesses)] }
		end,
		text = "Oh no! You caught a %illness%! Your parents are worried.",
		choices = {
			{ text = "😴 Sleep lots", effects = { Health = 3, Happiness = -2 }, resultText = "You slept through most of it and recovered quickly." },
			{ text = "😭 Be miserable", effects = { Health = 2, Happiness = -5 }, resultText = "You were unhappy but got through it with lots of cuddles." },
			{ text = "🏥 Doctor visit", effects = { Health = 5, Happiness = -1, Money = -200 }, resultText = "The pediatrician helped you feel better fast." },
		},
	},

	{
		id = "m_first_solid_food",
		minAge = 0, maxAge = 1,
		weight = 50, oneTime = true,
		emoji = "🥣", title = "First Solid Food!",
		category = "family",
		getDynamicData = function()
			local foods = {"mashed banana", "rice cereal", "pureed carrots", "apple sauce"}
			return { food = foods[math.random(#foods)] }
		end,
		text = "Time to try %food%! Your first taste of real food.",
		choices = {
			{ text = "😋 Love it!", effects = { Happiness = 6, Health = 2 }, resultText = "You gobbled it up! A future foodie in the making!" },
			{ text = "🤮 Spit it out", effects = { Happiness = -2 }, resultText = "Nope! You made a face and rejected it completely." },
			{ text = "🤔 Confused", effects = { Smarts = 2, Happiness = 2 }, resultText = "What IS this strange texture? You're still figuring it out." },
		},
	},

	{
		id = "m_rolling_over",
		minAge = 0, maxAge = 1,
		weight = 40, oneTime = true,
		emoji = "🔄", title = "Rolling Over!",
		category = "family",
		text = "You rolled over all by yourself for the first time! A milestone!",
		choices = {
			{ text = "🔄 Keep rolling!", effects = { Health = 3, Happiness = 4 }, resultText = "You couldn't stop! Rolling became your favorite activity." },
			{ text = "😲 Surprise yourself", effects = { Happiness = 3, Smarts = 2 }, resultText = "You looked shocked at your own achievement!" },
		},
	},

	{
		id = "m_stranger_anxiety",
		minAge = 0, maxAge = 1,
		weight = 35, oneTime = true,
		emoji = "😰", title = "Stranger Danger",
		category = "social",
		text = "A stranger tried to hold you and you were NOT happy about it.",
		choices = {
			{ text = "😭 Cry for mommy", effects = { Happiness = -3 }, resultText = "You screamed until your parent took you back. Safety!" },
			{ text = "👀 Suspicious stare", effects = { Smarts = 3 }, resultText = "You gave them the death stare. Trust must be earned." },
			{ text = "🤷 Actually fine", effects = { Happiness = 2 }, resultText = "You're pretty chill with new people!" },
		},
	},

	{
		id = "m_first_haircut",
		minAge = 0, maxAge = 2,
		weight = 30, oneTime = true,
		emoji = "✂️", title = "First Haircut!",
		category = "family",
		text = "Time for your very first haircut! Your parents saved a lock of your hair.",
		choices = {
			{ text = "✂️ Sit still", effects = { Happiness = 3, Looks = 2 }, resultText = "You were so good! The barber was impressed." },
			{ text = "😭 Scream and wiggle", effects = { Happiness = -4, Looks = -1 }, resultText = "It was a disaster! Uneven but... done." },
			{ text = "😴 Sleep through it", effects = { Happiness = 2, Looks = 2 }, resultText = "You dozed off and woke up looking fresh!" },
		},
	},

	-- ═══════════════════════════════════════════════════════════════
	-- TODDLER YEARS (Age 2-3)
	-- ═══════════════════════════════════════════════════════════════

	{
		id = "m_terrible_twos",
		minAge = 2, maxAge = 2,
		weight = 80, oneTime = true, milestone = true,
		emoji = "😈", title = "The Terrible Twos",
		category = "family",
		text = "You've entered the 'terrible twos' phase. Everything is 'NO!' and tantrums are frequent.",
		choices = {
			{ text = "🙅 NO NO NO!", effects = { Happiness = 4, Smarts = 2 }, resultText = "You asserted your independence at maximum volume!", setFlag = "strong_willed" },
			{ text = "😇 Skip the phase", effects = { Happiness = 6, Looks = 2 }, resultText = "You skipped the terrible twos entirely! Your parents are relieved." },
			{ text = "🤔 Why should I?", effects = { Smarts = 6 }, resultText = "You questioned everything. Annoying but brilliant.", setFlag = "curious" },
			{ text = "😤 Epic meltdowns", effects = { Happiness = 2 }, resultText = "Your tantrums were legendary. Floor-pounding, breath-holding, the works." },
		},
	},

	{
		id = "m_potty_training",
		minAge = 2, maxAge = 3,
		weight = 70, oneTime = true,
		emoji = "🚽", title = "Potty Training!",
		category = "family",
		text = "The big challenge begins! Your parents are trying to potty train you.",
		choices = {
			{ text = "✅ Nail it!", effects = { Smarts = 5, Happiness = 6 }, resultText = "You're a potty training prodigy! Diapers are history!" },
			{ text = "😅 Accidents happen", effects = { Happiness = -2 }, resultText = "It took a while with many accidents, but you got there." },
			{ text = "🙅 Refuse to cooperate", effects = { Happiness = 4, Smarts = -2 }, resultText = "You showed them who's boss! (Diapers stay for now)", setFlag = "stubborn" },
			{ text = "🏆 Motivated by rewards", effects = { Smarts = 4, Happiness = 5 }, resultText = "Stickers and treats worked like magic!" },
		},
	},

	{
		id = "m_baby_tantrum",
		minAge = 1, maxAge = 4,
		weight = 35, cooldown = 2,
		emoji = "😠", title = "Tantrum Time!",
		category = "family",
		getDynamicData = function()
			local reasons = {"didn't get candy", "had to leave the park", "wanted the blue cup not the red one", "couldn't watch more TV", "bedtime was called"}
			return { reason = reasons[math.random(#reasons)] }
		end,
		text = "You %reason% and you are NOT happy about it!",
		choices = {
			{ text = "😭 SCREAM!", effects = { Health = 2, Happiness = -4 }, resultText = "You made yourself heard! Didn't get what you wanted though." },
			{ text = "🥺 Puppy eyes", effects = { Looks = 2, Happiness = 6 }, resultText = "Those big sad eyes worked! You got what you wanted." },
			{ text = "🤷 Give up fast", effects = { Smarts = 3 }, resultText = "You learned to pick your battles. Very mature!" },
			{ text = "🚶 Stomp away", effects = { Happiness = -1 }, resultText = "You dramatically stomped to your room." },
		},
	},

	{
		id = "m_baby_sibling",
		minAge = 1, maxAge = 5,
		weight = 20, oneTime = true,
		emoji = "👶", title = "New Baby Sibling!",
		category = "family",
		getDynamicData = function()
			local genders = {"brother", "sister"}
			return { siblingType = genders[math.random(#genders)] }
		end,
		text = "Your parents brought home a new baby %siblingType%! You're a big sibling now!",
		choices = {
			{ text = "🤗 Love them!", effects = { Happiness = 7 }, resultText = "You adore your new sibling! Always wanting to help.", setFlag = "has_sibling" },
			{ text = "😤 Jealous...", effects = { Happiness = -6 }, resultText = "Why does the baby get all the attention?!", setFlags = {"has_sibling", "jealous_sibling"} },
			{ text = "🤷 Indifferent", effects = { Smarts = 2 }, resultText = "You've got your own thing going on.", setFlag = "has_sibling" },
			{ text = "🧸 Share your toys", effects = { Happiness = 5, Smarts = 2 }, resultText = "You offered your teddy to the baby. So sweet!", setFlags = {"has_sibling", "generous"} },
		},
	},

	{
		id = "m_imaginary_friend",
		minAge = 3, maxAge = 6,
		weight = 35, oneTime = true,
		emoji = "👻", title = "Imaginary Friend",
		category = "social",
		getDynamicData = function()
			local names = {"Mr. Whiskers", "Sparkle", "Captain Thunder", "Princess Luna", "Dino", "Flopsy", "Sir Woofs", "Rainbow", "Binky", "Zuzu"}
			return { friendName = names[math.random(#names)] }
		end,
		text = "You've created an imaginary friend named %friendName%! Only you can see them.",
		choices = {
			{ text = "🤝 Best friends forever!", effects = { Happiness = 7, Smarts = 3 }, resultText = "%friendName% goes everywhere with you. Invisible but very real to you!", setFlag = "creative_mind" },
			{ text = "🏰 Build a whole world", effects = { Smarts = 6, Happiness = 5 }, resultText = "You and %friendName% have epic adventures together in your imagination!", setFlag = "imaginative" },
			{ text = "🤷 They're just pretend", effects = { Smarts = 5 }, resultText = "You know %friendName% isn't real. But you play along anyway." },
		},
	},

	{
		id = "m_first_pet_encounter",
		minAge = 2, maxAge = 6,
		weight = 30, oneTime = true,
		emoji = "🐾", title = "Meeting a Pet",
		category = "family",
		getDynamicData = function()
			local petData = {
				{ type = "puppy", emoji = "🐶" },
				{ type = "kitten", emoji = "🐱" },
				{ type = "hamster", emoji = "🐹" },
				{ type = "goldfish", emoji = "🐠" },
				{ type = "bunny", emoji = "🐰" },
				{ type = "parakeet", emoji = "🦜" },
			}
			local chosen = petData[math.random(#petData)]
			local names = {"Max", "Buddy", "Luna", "Bella", "Charlie", "Coco"}
			return { petType = chosen.type, petName = names[math.random(#names)], petEmoji = chosen.emoji }
		end,
		getDynamicEmoji = function(data)
			return data.petEmoji or "🐾"
		end,
		text = "Your family got a %petType% named %petName%! %petEmoji% Your first real pet!",
		choices = {
			{ text = "🤗 Love them!", effects = { Happiness = 10 }, resultText = "You and %petName% are inseparable! Best friends forever!", setFlag = "animal_lover" },
			{ text = "😨 Scared of it", effects = { Happiness = -4 }, resultText = "%petName% scares you. Maybe you'll warm up eventually." },
			{ text = "🔬 Study it", effects = { Smarts = 5, Happiness = 4 }, resultText = "You're fascinated by %petName%! What do they eat? Why do they do that?", setFlag = "science_interest" },
			{ text = "🤕 Got scratched/nipped", effects = { Health = -3, Happiness = -2 }, resultText = "%petName% didn't mean to hurt you. Still friends?" },
		},
	},

	{
		id = "m_daycare_start",
		minAge = 2, maxAge = 3,
		weight = 50, oneTime = true,
		emoji = "🏠", title = "Starting Daycare",
		category = "social",
		getDynamicData = function()
			local names = {"Sunshine Academy", "Little Learners", "Tiny Tots", "Happy Kids", "Rainbow Room"}
			return { daycareName = names[math.random(#names)] }
		end,
		text = "Your parents enrolled you in %daycareName%! Time to socialize with other kids.",
		choices = {
			{ text = "🎉 Make friends!", effects = { Happiness = 7, Smarts = 2 }, resultText = "You made friends on day one!", setFlag = "social_butterfly" },
			{ text = "😭 Miss mommy/daddy", effects = { Happiness = -5 }, resultText = "The separation was hard. You cried for the first week." },
			{ text = "🧸 Play alone", effects = { Smarts = 4, Happiness = 2 }, resultText = "You're comfortable doing your own thing." },
			{ text = "👑 Boss other kids", effects = { Happiness = 4, Smarts = -1 }, resultText = "You quickly established yourself as the leader!", setFlag = "dominant" },
		},
	},

	{
		id = "m_playground_fall",
		minAge = 2, maxAge = 5,
		weight = 25, cooldown = 2,
		emoji = "🤕", title = "Playground Accident",
		category = "health",
		getDynamicData = function()
			local injuries = {"scraped your knee", "bumped your head", "got a splinter", "fell off the swing"}
			return { injury = injuries[math.random(#injuries)] }
		end,
		text = "Oops! You %injury% on the playground!",
		choices = {
			{ text = "😭 Cry!", effects = { Health = -3, Happiness = -4 }, resultText = "It hurt! But you got lots of sympathy and maybe some ice cream." },
			{ text = "💪 Be brave", effects = { Health = -2, Happiness = 3 }, resultText = "You barely shed a tear! So tough!", setFlag = "brave" },
			{ text = "🩹 Need a bandaid", effects = { Health = -2 }, resultText = "A bandaid with cartoon characters made everything better." },
		},
	},

	{
		id = "m_picky_eater",
		minAge = 2, maxAge = 5,
		weight = 30, cooldown = 2,
		emoji = "🥦", title = "Picky Eater",
		category = "health",
		getDynamicData = function()
			local foods = {"broccoli", "spinach", "carrots", "peas", "green beans", "mushrooms"}
			return { food = foods[math.random(#foods)] }
		end,
		text = "Your parents want you to eat %food%. It looks suspicious!",
		choices = {
			{ text = "🤢 Refuse!", effects = { Happiness = 3, Health = -3 }, resultText = "No way that's going in your mouth! You won this battle." },
			{ text = "😤 Eat it grudgingly", effects = { Health = 5, Happiness = -2 }, resultText = "You forced it down. Wasn't THAT bad..." },
			{ text = "🤔 Actually tastes good!", effects = { Health = 6, Happiness = 4 }, resultText = "Hey, %food% is pretty good!", setFlag = "healthy_eater" },
			{ text = "🎭 Hide it", effects = { Smarts = 3 }, resultText = "You hid the %food% under other food. Genius!", setFlag = "sneaky" },
		},
	},

	-- ═══════════════════════════════════════════════════════════════
	-- PRESCHOOL YEARS (Age 3-5)
	-- ═══════════════════════════════════════════════════════════════

	{
		id = "m_preschool_start",
		minAge = 4, maxAge = 4,
		weight = 90, oneTime = true, milestone = true,
		emoji = "🏫", title = "First Day of Preschool!",
		category = "school",
		getDynamicData = function()
			local schools = {"Sunflower Preschool", "Little Stars Academy", "Bright Beginnings", "ABC Learning Center"}
			return { school = schools[math.random(#schools)] }
		end,
		text = "It's your first day at %school%! A big step toward independence!",
		choices = {
			{ text = "🎉 Excited!", effects = { Happiness = 6, Smarts = 3 }, resultText = "You bounced into class with enthusiasm!", setFlag = "social_butterfly" },
			{ text = "😰 Scared", effects = { Happiness = -3 }, resultText = "You clung to your parent but eventually warmed up." },
			{ text = "🤝 Make a friend", effects = { Happiness = 7 }, resultText = "You found a best friend on day one!", setFlag = "has_best_friend" },
			{ text = "🎨 Love the activities", effects = { Smarts = 5, Happiness = 5 }, resultText = "Art, blocks, storytime - you loved it all!" },
		},
	},

	{
		id = "m_playground_incident",
		minAge = 3, maxAge = 6,
		weight = 35, cooldown = 2,
		emoji = "🛝", title = "Playground Drama",
		category = "social",
		getDynamicData = function()
			return { kidName = LifeEvents.randomFirstName() }
		end,
		text = "Another kid named %kidName% pushed you on the playground!",
		choices = {
			{ text = "👊 Push back", effects = { Health = -3, Happiness = 3 }, resultText = "You stood your ground! They won't mess with you again.", setFlag = "fights_back" },
			{ text = "😭 Cry for help", effects = { Happiness = -4 }, resultText = "A teacher came over. %kidName% got in trouble." },
			{ text = "🗣️ Talk it out", effects = { Smarts = 5, Happiness = 2 }, resultText = "You asked why they did that. Very mature for your age!", setFlag = "peacemaker" },
			{ text = "🤝 Become friends", effects = { Happiness = 5, Smarts = 3 }, resultText = "Somehow you ended up playing together!", setFlag = "forgiving" },
		},
	},

	{
		id = "m_first_drawing",
		minAge = 3, maxAge = 5,
		weight = 45, oneTime = true,
		emoji = "🖍️", title = "Your First Drawing!",
		category = "school",
		text = "You drew something and your parents put it on the fridge! It's... abstract.",
		choices = {
			{ text = "🎨 Keep drawing!", effects = { Smarts = 4, Happiness = 6 }, resultText = "Art becomes your passion! Every surface is a canvas.", setFlag = "art_interest" },
			{ text = "🏠 Draw your family", effects = { Happiness = 7 }, resultText = "Your parents were so touched by the family portrait!" },
			{ text = "🤷 Meh, not interested", effects = { Happiness = 2 }, resultText = "Art isn't really your thing. That's okay!" },
			{ text = "✍️ Try to write your name", effects = { Smarts = 5, Happiness = 3 }, resultText = "Letters are interesting! Even if they're backwards." },
		},
	},

	{
		id = "m_learn_abc",
		minAge = 3, maxAge = 5,
		weight = 50, oneTime = true,
		emoji = "📚", title = "Learning the ABCs",
		category = "school",
		text = "A, B, C, D, E, F, G... You're learning the alphabet!",
		choices = {
			{ text = "🎵 Sing the song!", effects = { Smarts = 5, Happiness = 6 }, resultText = "Now you know your ABCs! Next time won't you sing with me!" },
			{ text = "📖 Practice writing", effects = { Smarts = 7, Happiness = 2 }, resultText = "You're writing letters already! Ahead of the curve!", setFlag = "early_reader" },
			{ text = "🤷 Letters are boring", effects = { Smarts = 2 }, resultText = "You'll learn eventually. No rush!" },
			{ text = "📱 Learn on tablet", effects = { Smarts = 4, Happiness = 4 }, resultText = "Educational apps made it fun!" },
		},
	},

	{
		id = "m_counting",
		minAge = 3, maxAge = 5,
		weight = 45, oneTime = true,
		emoji = "🔢", title = "Learning to Count",
		category = "school",
		text = "1, 2, 3, 4, 5... You're learning numbers!",
		choices = {
			{ text = "🔢 Count to 100!", effects = { Smarts = 7, Happiness = 4 }, resultText = "You're a counting champion!", setFlag = "math_talent" },
			{ text = "🧮 Count on fingers", effects = { Smarts = 4, Happiness = 4 }, resultText = "Fingers make great calculators!" },
			{ text = "🤔 Why do we count?", effects = { Smarts = 6 }, resultText = "You asked philosophical questions about numbers. Deep!", setFlag = "curious" },
			{ text = "🍪 Count snacks", effects = { Smarts = 3, Happiness = 5 }, resultText = "Math is more fun with cookies!" },
		},
	},

	{
		id = "m_sharing_lesson",
		minAge = 3, maxAge = 5,
		weight = 35, cooldown = 2,
		emoji = "🤝", title = "Learning to Share",
		category = "social",
		getDynamicData = function()
			local toys = {"favorite toy", "crayons", "snacks", "playdough", "blocks"}
			return { item = toys[math.random(#toys)], kidName = LifeEvents.randomFirstName() }
		end,
		text = "%kidName% wants to use your %item%. Will you share?",
		choices = {
			{ text = "🤝 Share nicely", effects = { Happiness = 5, Smarts = 2 }, resultText = "Sharing is caring! %kidName% became your friend.", setFlag = "generous" },
			{ text = "🙅 MINE!", effects = { Happiness = 3, Smarts = -2 }, resultText = "You held on tight. Sharing is hard!" },
			{ text = "🤔 Trade instead", effects = { Smarts = 6, Happiness = 4 }, resultText = "You negotiated a fair trade! Business genius!", setFlag = "negotiator" },
			{ text = "⏰ Take turns", effects = { Smarts = 4, Happiness = 4 }, resultText = "You learned about taking turns. Compromise!" },
		},
	},

	{
		id = "m_naptime_rebellion",
		minAge = 2, maxAge = 4,
		weight = 30, cooldown = 2,
		emoji = "😴", title = "Naptime Rebellion",
		category = "family",
		text = "It's naptime but you are definitely NOT tired!",
		choices = {
			{ text = "😴 Fine, I'll sleep", effects = { Health = 4, Happiness = -1 }, resultText = "You actually WERE tired. You zonked out immediately." },
			{ text = "🙅 Refuse to nap!", effects = { Happiness = 4, Health = -3 }, resultText = "Victory! (You got super cranky later though)", setFlag = "stubborn" },
			{ text = "🤫 Pretend to sleep", effects = { Smarts = 5, Happiness = 3 }, resultText = "You fooled them! Sneaky little genius.", setFlag = "sneaky" },
			{ text = "📚 Look at books instead", effects = { Smarts = 4, Health = 2 }, resultText = "Quiet time with books was a good compromise." },
		},
	},

	{
		id = "m_make_believe",
		minAge = 3, maxAge = 6,
		weight = 35, cooldown = 3,
		emoji = "👑", title = "Make Believe!",
		category = "social",
		getDynamicData = function()
			local roles = {"superhero", "princess/prince", "dinosaur", "astronaut", "doctor", "pirate", "wizard", "chef"}
			return { role = roles[math.random(#roles)] }
		end,
		text = "You're playing make-believe! Today you're a %role%!",
		choices = {
			{ text = "🦸 Be the hero!", effects = { Happiness = 7, Smarts = 3 }, resultText = "You saved the day in your imagination!", setFlag = "imaginative" },
			{ text = "🎭 Get really into it", effects = { Smarts = 5, Happiness = 6, Looks = 2 }, resultText = "Your performance was Oscar-worthy!" },
			{ text = "👥 Include others", effects = { Happiness = 5, Smarts = 2 }, resultText = "You gave everyone roles to play!", setFlag = "leader" },
			{ text = "🪄 Create magic", effects = { Smarts = 6, Happiness = 5 }, resultText = "Your imagination knows no bounds!", setFlag = "creative_mind" },
		},
	},

	{
		id = "m_fear_dark",
		minAge = 2, maxAge = 6,
		weight = 30, cooldown = 3,
		emoji = "🌙", title = "Fear of the Dark",
		category = "family",
		text = "You're scared of the dark! There might be monsters under the bed!",
		choices = {
			{ text = "😱 Need a nightlight", effects = { Happiness = 3 }, resultText = "The nightlight helps. Darkness defeated!" },
			{ text = "💪 Face your fear", effects = { Happiness = 6, Smarts = 3 }, resultText = "You were brave! No monsters after all.", setFlag = "brave" },
			{ text = "🧸 Hug a teddy", effects = { Happiness = 5 }, resultText = "Teddy protects you from all the monsters!" },
			{ text = "👨‍👩‍👧 Sleep with parents", effects = { Happiness = 4 }, resultText = "Safe in mommy and daddy's bed!" },
		},
	},

	{
		id = "m_birthday_party",
		minAge = 3, maxAge = 5,
		weight = 40, cooldown = 2,
		emoji = "🎈", title = "Birthday Party!",
		category = "social",
		getDynamicData = function()
			return { kidName = LifeEvents.randomFirstName() }
		end,
		text = "You're invited to %kidName%'s birthday party! Cake and games await!",
		choices = {
			{ text = "🎉 Party time!", effects = { Happiness = 10 }, resultText = "Best party ever! Cake, games, and presents!" },
			{ text = "🎁 Give a great gift", effects = { Happiness = 6, Money = -30 }, resultText = "Your gift was a hit! Good friend status confirmed." },
			{ text = "😰 Too shy to go", effects = { Happiness = -4 }, resultText = "You were too nervous. FOMO is real." },
			{ text = "🎂 Win musical chairs!", effects = { Happiness = 8, Smarts = 2 }, resultText = "You dominated the party games!", setFlag = "competitive" },
		},
	},

	{
		id = "m_first_sleepover",
		minAge = 4, maxAge = 6,
		weight = 25, oneTime = true,
		emoji = "🏠", title = "First Sleepover!",
		category = "social",
		requires = LifeEvents.hasFriend,  -- MUST have friends for sleepover invite
		getDynamicData = function(state)
			return { friendName = LifeEvents.getFriendName(state) }
		end,
		text = "You're invited to your first sleepover at %friendName%'s house!",
		choices = {
			{ text = "🎉 So excited!", effects = { Happiness = 10, Smarts = 2 }, resultText = "Best night ever! You stayed up late and had so much fun!" },
			{ text = "😰 Homesick...", effects = { Happiness = -3 }, resultText = "You called home crying. Your parents came to pick you up." },
			{ text = "😴 Fall asleep early", effects = { Happiness = 4, Health = 3 }, resultText = "You slept great! (They might have drawn on your face though)" },
			{ text = "🎬 Movie marathon", effects = { Happiness = 8 }, resultText = "You watched movies until you couldn't keep your eyes open!" },
		},
	},

	{
		id = "m_lost_toy",
		minAge = 2, maxAge = 5,
		weight = 25, cooldown = 3,
		emoji = "🧸", title = "Lost Toy",
		category = "family",
		getDynamicData = function()
			local toys = {"teddy bear", "blankie", "favorite car", "doll", "action figure", "stuffed bunny"}
			return { toy = toys[math.random(#toys)] }
		end,
		text = "Oh no! You can't find your %toy%! It's MISSING!",
		choices = {
			{ text = "😭 Devastated", effects = { Happiness = -8 }, resultText = "You cried and cried. It was your FAVORITE!" },
			{ text = "🔍 Search everywhere", effects = { Happiness = 4, Smarts = 4 }, resultText = "You found it! Under the couch. Phew!" },
			{ text = "🤷 Move on", effects = { Smarts = 3 }, resultText = "You let go. Very mature for your age." },
			{ text = "🆕 Get a new one", effects = { Happiness = 2, Money = -25 }, resultText = "Your parents got you a replacement. Not quite the same though." },
		},
	},

	{
		id = "m_parent_fight",
		minAge = 3, maxAge = 6,
		weight = 12, oneTime = true,
		emoji = "😢", title = "Parents Arguing",
		category = "family",
		text = "You heard your parents having a big argument. It scared you.",
		choices = {
			{ text = "😢 Hide and cry", effects = { Happiness = -10 }, resultText = "It was scary. You just wanted them to stop." },
			{ text = "🤗 Hug them both", effects = { Happiness = 4, Smarts = 2 }, resultText = "Your hug reminded them what's important. They apologized." },
			{ text = "🙈 Pretend it's okay", effects = { Happiness = -5, Smarts = 2 }, resultText = "You learned to cope by ignoring problems." },
			{ text = "🗣️ Ask why", effects = { Smarts = 4, Happiness = -3 }, resultText = "They explained that adults sometimes disagree. You're growing up." },
		},
	},

	{
		id = "m_new_word",
		minAge = 2, maxAge = 4,
		weight = 30, cooldown = 2,
		emoji = "🗣️", title = "New Vocabulary!",
		category = "school",
		getDynamicData = function()
			local words = {"supercalifragilisticexpialidocious", "hippopotamus", "refrigerator", "encyclopedia", "a bad word you shouldn't have heard"}
			return { word = words[math.random(#words)] }
		end,
		text = "You learned a new word: '%word%'! You're so proud!",
		choices = {
			{ text = "🗣️ Say it constantly", effects = { Smarts = 4, Happiness = 5 }, resultText = "You used the word at every opportunity!" },
			{ text = "😈 Was it a bad word?", effects = { Smarts = 2, Happiness = 3 }, resultText = "You repeated it at the worst possible moment. Oops!" },
			{ text = "📚 Learn more words", effects = { Smarts = 6, Happiness = 3 }, resultText = "Your vocabulary is expanding rapidly!", setFlag = "early_reader" },
		},
	},

	{
		id = "m_first_lie",
		minAge = 3, maxAge = 5,
		weight = 25, oneTime = true,
		emoji = "🤥", title = "Your First Lie",
		category = "family",
		getDynamicData = function()
			local situations = {"eating cookies before dinner", "breaking a vase", "hitting your sibling", "drawing on the wall"}
			return { situation = situations[math.random(#situations)] }
		end,
		text = "Your parents asked about %situation%. You said it wasn't you... but it WAS you.",
		choices = {
			{ text = "😇 Confess", effects = { Happiness = -2, Smarts = 3 }, resultText = "You came clean. Your parents appreciated your honesty.", setFlag = "honest" },
			{ text = "🤥 Stick to the lie", effects = { Smarts = -2, Happiness = 2 }, resultText = "You maintained the lie. Your parents knew though." },
			{ text = "😭 Feel guilty", effects = { Happiness = -4 }, resultText = "The guilt ate at you. You couldn't look them in the eye." },
			{ text = "🐕 Blame the pet", effects = { Smarts = 2, Happiness = 3 }, resultText = "You blamed the dog. Classic move." },
		},
	},

	{
		id = "m_helping_parent",
		minAge = 3, maxAge = 5,
		weight = 30, cooldown = 2,
		emoji = "🤝", title = "Helping Out",
		category = "family",
		getDynamicData = function()
			local tasks = {"cooking", "cleaning", "gardening", "laundry", "groceries"}
			return { task = tasks[math.random(#tasks)] }
		end,
		text = "Your parent is %task%. You want to help!",
		choices = {
			{ text = "🤝 Be helpful!", effects = { Happiness = 6, Smarts = 3 }, resultText = "You actually helped! Your parent was touched.", setFlag = "helpful" },
			{ text = "😅 Make a mess", effects = { Happiness = 4, Smarts = 2 }, resultText = "Your help created more work. But they appreciated the effort!" },
			{ text = "🤷 Lose interest quickly", effects = { Happiness = 2 }, resultText = "It wasn't as fun as you thought. You wandered off." },
			{ text = "👀 Watch and learn", effects = { Smarts = 5, Happiness = 3 }, resultText = "You observed carefully. Learning for next time!" },
		},
	},

	{
		id = "m_new_food_adventure",
		minAge = 3, maxAge = 5,
		weight = 25, cooldown = 3,
		emoji = "🍽️", title = "New Food Adventure",
		category = "family",
		getDynamicData = function()
			local foods = {"sushi", "spicy food", "weird vegetable", "blue cheese", "escargot", "tofu"}
			return { food = foods[math.random(#foods)] }
		end,
		text = "Your family wants you to try %food% for the first time!",
		choices = {
			{ text = "😋 Actually delicious!", effects = { Happiness = 6, Smarts = 3 }, resultText = "Surprisingly good! Your palate is expanding.", setFlag = "adventurous_eater" },
			{ text = "🤮 Absolutely not!", effects = { Happiness = -2 }, resultText = "NOPE. You'll stick to chicken nuggets." },
			{ text = "🤔 It's... interesting", effects = { Smarts = 3, Happiness = 2 }, resultText = "You're not sure if you like it. Need more data." },
			{ text = "🎭 Dramatic reaction", effects = { Happiness = 4 }, resultText = "Your theatrical disgust was hilarious to everyone." },
		},
	},

	{
		id = "m_bathroom_accident",
		minAge = 2, maxAge = 4,
		weight = 20, cooldown = 3,
		emoji = "😳", title = "Oops! Accident!",
		category = "health",
		text = "You had an accident... in public. Embarrassing!",
		choices = {
			{ text = "😭 So embarrassed!", effects = { Happiness = -6 }, resultText = "It happens to everyone. Still mortifying though." },
			{ text = "🤷 These things happen", effects = { Happiness = -2, Smarts = 2 }, resultText = "You handled it well. Accidents happen!" },
			{ text = "😂 Laugh it off", effects = { Happiness = 2 }, resultText = "You giggled about it. Way to own it!" },
		},
	},

	{
		id = "m_sibling_fight",
		minAge = 3, maxAge = 6,
		weight = 25, cooldown = 2,
		requiresFlag = "has_sibling",
		emoji = "😤", title = "Sibling Rivalry",
		category = "family",
		text = "You and your sibling are fighting over something. Classic!",
		choices = {
			{ text = "👊 Fight for it!", effects = { Health = -2, Happiness = 2 }, resultText = "You won! But now your sibling is crying." },
			{ text = "🤝 Share/Compromise", effects = { Happiness = 4, Smarts = 3 }, resultText = "You worked it out! Parents are proud.", setFlag = "peacemaker" },
			{ text = "😭 Tattle to parents", effects = { Happiness = 3, Smarts = -1 }, resultText = "Your sibling got in trouble. Sweet revenge!" },
			{ text = "🚶 Walk away", effects = { Happiness = 2, Smarts = 2 }, resultText = "You took the high road. Very mature!" },
		},
	},

	{
		id = "m_questions_phase",
		minAge = 3, maxAge = 5,
		weight = 40, oneTime = true,
		emoji = "❓", title = "The 'Why' Phase",
		category = "family",
		text = "Why is the sky blue? Why do birds fly? Why? Why? WHY? You have entered the 'why' phase!",
		choices = {
			{ text = "❓ Ask EVERYTHING", effects = { Smarts = 8, Happiness = 4 }, resultText = "You drove everyone crazy with questions. But you learned SO much!", setFlag = "curious" },
			{ text = "🤔 Deep philosophical questions", effects = { Smarts = 10, Happiness = 2 }, resultText = "Your questions were surprisingly profound.", setFlag = "philosophical" },
			{ text = "😈 Ask to annoy", effects = { Happiness = 5, Smarts = 2 }, resultText = "You discovered 'why' is the ultimate weapon!" },
			{ text = "📚 Find answers in books", effects = { Smarts = 7, Happiness = 3 }, resultText = "You learned to research your own questions!", setFlag = "bookworm" },
		},
	},

	{
		id = "m_tooth_fairy",
		minAge = 5, maxAge = 6,
		weight = 40, oneTime = true,
		emoji = "🧚", title = "First Loose Tooth!",
		category = "family",
		text = "Your first baby tooth is loose! The Tooth Fairy is coming!",
		choices = {
			{ text = "😁 Wiggle it out!", effects = { Happiness = 6, Health = 1 }, resultText = "You pulled it yourself! $1 under the pillow tomorrow!" },
			{ text = "😰 Scared to pull it", effects = { Happiness = 2 }, resultText = "It fell out on its own eventually." },
			{ text = "🤔 Is the Tooth Fairy real?", effects = { Smarts = 5 }, resultText = "You have doubts... but you still got money for the tooth!" },
			{ text = "💰 Negotiate price", effects = { Smarts = 4, Money = 5 }, resultText = "You left a note asking for more. Got $5!", setFlag = "negotiator" },
		},
	},

	{
		id = "m_swimming_lesson",
		minAge = 4, maxAge = 6,
		weight = 35, oneTime = true,
		emoji = "🏊", title = "First Swimming Lesson",
		category = "health",
		text = "Your parents signed you up for swimming lessons! Time to learn!",
		choices = {
			{ text = "🏊 Natural swimmer!", effects = { Health = 5, Happiness = 6 }, resultText = "You took to water like a fish!", setFlag = "swimmer" },
			{ text = "😰 Terrified of water", effects = { Happiness = -4 }, resultText = "You cried and refused to go in. Maybe next year." },
			{ text = "💪 Slow but steady", effects = { Health = 4, Smarts = 3 }, resultText = "You learned gradually. By summer you were swimming!" },
			{ text = "🎉 Best part: splashing!", effects = { Happiness = 7 }, resultText = "You loved splashing more than actual swimming!" },
		},
	},

	{
		id = "m_kindergarten_prep",
		minAge = 5, maxAge = 5,
		weight = 70, oneTime = true,
		emoji = "🎒", title = "Getting Ready for Kindergarten!",
		category = "school",
		text = "Next year is kindergarten! Big kid school! Time to get ready.",
		choices = {
			{ text = "📚 Already reading!", effects = { Smarts = 8, Happiness = 4 }, resultText = "You're academically ahead! Kindergarten will be easy.", setFlag = "early_reader" },
			{ text = "🤝 Focus on social skills", effects = { Happiness = 6, Smarts = 3 }, resultText = "Making friends is the priority!" },
			{ text = "😰 Nervous about it", effects = { Happiness = -3 }, resultText = "The big school seems scary. But you'll be okay." },
			{ text = "🎒 Excited for new backpack!", effects = { Happiness = 5 }, resultText = "The supplies shopping was the best part!" },
		},
	},

	{
		id = "m_role_model",
		minAge = 4, maxAge = 6,
		weight = 25, oneTime = true,
		emoji = "⭐", title = "Who's Your Role Model?",
		category = "family",
		getDynamicData = function()
			local models = {"superhero", "parent", "older sibling", "teacher", "cartoon character", "athlete"}
			return { roleModel = models[math.random(#models)] }
		end,
		text = "You announced that your role model is a %roleModel%! You want to be just like them!",
		choices = {
			{ text = "🦸 Hero worship!", effects = { Happiness = 6 }, resultText = "You dressed up like your hero every day!" },
			{ text = "📖 Learn about them", effects = { Smarts = 5, Happiness = 4 }, resultText = "You learned everything about your role model!" },
			{ text = "🎭 Imitate them", effects = { Happiness = 5, Looks = 2 }, resultText = "You tried to walk, talk, and act like them!" },
		},
	},

	{
		id = "m_season_discovery",
		minAge = 3, maxAge = 5,
		weight = 30, cooldown = 4,
		emoji = "🍂", title = "Discovering Seasons!",
		category = "school",
		getDynamicData = function()
			local seasons = {
				{ name = "fall", activity = "jumping in leaf piles" },
				{ name = "winter", activity = "playing in snow" },
				{ name = "spring", activity = "seeing flowers bloom" },
				{ name = "summer", activity = "running through sprinklers" }
			}
			local s = seasons[math.random(#seasons)]
			return { season = s.name, activity = s.activity }
		end,
		text = "It's %season%! You experienced %activity% for the first time!",
		choices = {
			{ text = "🎉 Best day ever!", effects = { Happiness = 8, Health = 2 }, resultText = "Nature is amazing! You love %season%!" },
			{ text = "🤔 Why do seasons change?", effects = { Smarts = 6 }, resultText = "Your parents tried to explain. You sort of got it.", setFlag = "curious" },
			{ text = "🏠 Prefer indoors", effects = { Happiness = 2 }, resultText = "Seasons are whatever. TV is always in season." },
		},
	},
}

return module
