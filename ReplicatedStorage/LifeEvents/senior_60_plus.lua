-- LifeEvents/senior_60_plus.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- SENIOR EVENTS (Ages 60+)
-- Retirement, grandchildren, legacy
-- ═══════════════════════════════════════════════════════════════════════════════

local LifeEvents = require(script.Parent)
local module = {}

module.events = {
	{
		id = "m_retirement",
		minAge = 60, maxAge = 70,
		weight = 80, oneTime = true, milestone = true,
		emoji = "🏖️", title = "Retirement!",
		category = "work",
		requiresFlag = "employed",
		text = "After decades of work, it's time to retire. What's next?",
		choices = {
			{ text = "🏖️ Relax finally!", effects = { Happiness = 20, Health = 5 }, resultText = "No more alarm clocks. Freedom!", setFlag = "retired", clearFlag = "employed" },
			{ text = "✈️ Travel the world", effects = { Happiness = 25, Money = -20000 }, resultText = "Time to see everything!", setFlag = "retired" },
			{ text = "📚 Part-time work", effects = { Happiness = 10, Money = 5000 }, resultText = "You're not ready to fully stop.", setFlag = "semi_retired" },
		},
	},
	{
		id = "m_grandchildren",
		minAge = 55, maxAge = 80,
		weight = 40, oneTime = true, milestone = true,
		emoji = "👶", title = "Grandchildren!",
		category = "family",
		requiresFlag = "has_children",
		text = "Your child had a baby! You're a grandparent now!",
		choices = {
			{ text = "👶 So much love!", effects = { Happiness = 25 }, resultText = "Being a grandparent is the best.", setFlag = "grandparent" },
			{ text = "🍼 Babysitting duty", effects = { Happiness = 15, Health = -3 }, resultText = "Exhausting but worth it.", setFlag = "grandparent" },
		},
	},
	{
		id = "m_health_decline",
		minAge = 65, maxAge = 90,
		weight = 35, cooldown = 3,
		emoji = "🏥", title = "Health Decline",
		category = "health",
		text = "Your body isn't what it used to be. New health issues are emerging.",
		choices = {
			{ text = "💊 Manage it", effects = { Health = -10, Happiness = -5 }, resultText = "More pills, more doctors." },
			{ text = "💪 Fight it", effects = { Health = -5, Happiness = 3 }, resultText = "You're not giving up easily." },
			{ text = "😔 Accept it", effects = { Health = -15, Happiness = -8 }, resultText = "The body ages. That's life." },
		},
	},
	{
		id = "m_legacy_planning",
		minAge = 65, maxAge = 90,
		weight = 25, oneTime = true,
		emoji = "📜", title = "Planning Your Legacy",
		category = "family",
		text = "It's time to think about your will and what you'll leave behind.",
		choices = {
			{ text = "💰 Leave everything to family", effects = { Happiness = 5 }, resultText = "Family comes first." },
			{ text = "🏛️ Donate to charity", effects = { Happiness = 10, Money = -50000 }, resultText = "Your legacy will help others." },
			{ text = "📖 Write your memoirs", effects = { Smarts = 5, Happiness = 8 }, resultText = "Your story deserves to be told." },
		},
	},
	{
		id = "m_reunion_old_friend",
		minAge = 60, maxAge = 90,
		weight = 20, cooldown = 5,
		emoji = "👴", title = "Reuniting with Old Friend",
		category = "social",
		getDynamicData = function()
			return { friendName = LifeEvents.randomFirstName() }
		end,
		text = "You reconnected with %friendName%, an old friend you hadn't seen in decades.",
		choices = {
			{ text = "🤝 Great reunion!", effects = { Happiness = 15 }, resultText = "Like no time had passed at all." },
			{ text = "😢 They've changed", effects = { Happiness = -5 }, resultText = "Time changes people." },
			{ text = "💕 Old flames reignite?", effects = { Happiness = 10 }, resultText = "There's still a spark there..." },
		},
	},
}

return module
