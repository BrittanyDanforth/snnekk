-- LifeEvents/adult_35_60.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- MIDDLE AGE EVENTS (Ages 35-60)
-- Career peak, midlife, family growth
-- ═══════════════════════════════════════════════════════════════════════════════
-- STUB FILE - Add events here to expand this category

local LifeEvents = require(script.Parent)
local module = {}

module.events = {
	{
		id = "m_midlife_crisis",
		minAge = 35, maxAge = 50,
		weight = 30, oneTime = true,
		emoji = "🏎️", title = "Midlife Crisis",
		category = "health",
		text = "Is this all there is? You're questioning everything about your life.",
		choices = {
			{ text = "🏎️ Buy a sports car", effects = { Happiness = 10, Money = -40000 }, resultText = "Vroom vroom! That felt good.", addAsset = { type = "vehicle", id = "midlife_sports_car", name = "Midlife Crisis Sports Car", value = 40000 } },
			{ text = "🧘 Find inner peace", effects = { Happiness = 8, Smarts = 5 }, resultText = "You started meditating and found clarity." },
			{ text = "💔 Affair", effects = { Happiness = 5, Smarts = -5 }, resultText = "You made a terrible decision.", setFlag = "had_affair" },
			{ text = "💪 Reinvent yourself", effects = { Happiness = 12, Health = 3 }, resultText = "You started a new chapter.", setFlag = "reinvented" },
		},
	},
	{
		id = "m_kids_leaving",
		minAge = 40, maxAge = 55,
		weight = 35, oneTime = true,
		emoji = "🎓", title = "Empty Nest",
		category = "family",
		requiresFlag = "has_children",
		text = "Your kids are moving out. The house feels empty.",
		choices = {
			{ text = "😢 Sad to see them go", effects = { Happiness = -10 }, resultText = "You miss them already." },
			{ text = "🎉 Freedom!", effects = { Happiness = 15 }, resultText = "Time for yourself again!" },
			{ text = "🏠 Downsize", effects = { Happiness = 5, Money = 50000 }, resultText = "You sold the big house." },
		},
	},
	{
		id = "m_career_peak",
		minAge = 40, maxAge = 55,
		weight = 25, oneTime = true,
		emoji = "📈", title = "Career Peak",
		category = "work",
		requiresFlag = "employed",
		text = "You've reached the top of your field. This is what success looks like.",
		choices = {
			{ text = "🎉 Enjoy it!", effects = { Happiness = 15, Money = 30000 }, resultText = "You've made it!" },
			{ text = "🤔 Is this enough?", effects = { Happiness = 5, Smarts = 5 }, resultText = "Material success doesn't fill the void." },
			{ text = "🚀 Aim higher", effects = { Happiness = 8, Money = 20000 }, resultText = "There's always another mountain." },
		},
	},
	{
		id = "m_health_checkup",
		minAge = 40, maxAge = 60,
		weight = 30, cooldown = 5,
		emoji = "🏥", title = "Health Checkup",
		category = "health",
		text = "Time for your annual physical. The doctor has news.",
		choices = {
			{ text = "💪 Perfect health!", effects = { Health = 5, Happiness = 8 }, resultText = "Clean bill of health!" },
			{ text = "⚠️ Need lifestyle changes", effects = { Health = -5, Happiness = -5 }, resultText = "Doctor says to eat better and exercise." },
			{ text = "😰 Concerning results", effects = { Health = -15, Happiness = -15 }, resultText = "Follow-up tests needed. Worrying.", setFlag = "health_concern" },
		},
	},
}

return module
