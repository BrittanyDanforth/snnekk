-- LifeEvents/health.lua
-- Health, illness, wellness events

local LifeEvents = require(script.Parent)
local module = {}

module.events = {
	-- Varied health scares for older people (ages 60+)
	{
		id = "m_elderly_health_scare_1",
		minAge = 60, maxAge = 100,
		weight = 25, cooldown = 4,
		emoji = "🏥", title = "Health Scare",
		category = "health",
		getDynamicData = function()
			local conditions = {"chest pain", "dizziness", "memory lapse", "fall", "high blood pressure", "irregular heartbeat"}
			local outcomes = {"false alarm", "minor issue", "needs monitoring", "medication change", "lifestyle adjustment"}
			return { 
				condition = conditions[math.random(#conditions)],
				outcome = outcomes[math.random(#outcomes)],
				serious = math.random() < 0.3, -- 30% chance of serious
			}
		end,
		text = "You experienced %condition%. Time to see a doctor.",
		choices = {
			{ 
				text = "🏥 See doctor immediately", 
				effects = function(dynamicData)
					if dynamicData and dynamicData.serious then
						return { Health = -5, Money = -2000, Happiness = -8 }
					else
						return { Health = 2, Money = -500, Happiness = 3 }
					end
				end,
				resultText = function(dynamicData)
					if dynamicData and dynamicData.serious then
						return "It was serious. Treatment needed. Health -5, but caught early."
					else
						return "Doctor says it's %outcome%. Relief! Health +2."
					end
				end,
			},
			{ 
				text = "🤷 Wait and see", 
				effects = function(dynamicData)
					if dynamicData and dynamicData.serious then
						return { Health = -12, Happiness = -10 }
					else
						return { Health = -2, Happiness = -1 }
					end
				end,
				resultText = function(dynamicData)
					if dynamicData and dynamicData.serious then
						return "You waited too long. Condition worsened. Health -12."
					else
						return "It passed. But you should have checked. Health -2."
					end
				end,
			},
			{ 
				text = "💊 Take it easy", 
				effects = { Health = 1, Happiness = 2 }, 
				resultText = "Rest helped. Feeling better." 
			},
		},
	},
	{
		id = "m_elderly_health_scare_2",
		minAge = 65, maxAge = 100,
		weight = 20, cooldown = 5,
		emoji = "🩺", title = "Routine Checkup",
		category = "health",
		getDynamicData = function()
			local findings = {"everything normal", "slight concern", "needs follow-up", "medication adjustment", "new diagnosis"}
			local isGood = math.random() < 0.4 -- 40% chance of good news
			return { 
				finding = findings[math.random(#findings)],
				isGood = isGood,
			}
		end,
		text = "Annual checkup results are in.",
		choices = {
			{ 
				text = "📋 Review results", 
				effects = function(dynamicData)
					if dynamicData and dynamicData.isGood then
						return { Health = 5, Happiness = 8 }
					else
						return { Health = -3, Happiness = -5, Money = -1000 }
					end
				end,
				resultText = function(dynamicData)
					if dynamicData and dynamicData.isGood then
						return "Great news! %finding%. Health +5!"
					else
						return "Doctor found: %finding%. Needs attention. Health -3."
					end
				end,
			},
			{ 
				text = "😰 Worry about it", 
				effects = { Happiness = -8, Health = -2 }, 
				resultText = "Anxiety made it worse. Should have checked." 
			},
		},
	},
	{
		id = "m_elderly_health_scare_3",
		minAge = 70, maxAge = 100,
		weight = 18, cooldown = 6,
		emoji = "💊", title = "Medication Side Effects",
		category = "health",
		getDynamicData = function()
			local effects = {"dizziness", "nausea", "fatigue", "confusion", "joint pain"}
			local severity = math.random(3) -- 1-3
			return { 
				effect = effects[math.random(#effects)],
				severity = severity,
			}
		end,
		text = "New medication is causing %effect%.",
		choices = {
			{ 
				text = "📞 Call doctor", 
				effects = function(dynamicData)
					local sev = dynamicData and dynamicData.severity or 2
					return { Health = 3, Money = -300, Happiness = 4 }
				end,
				resultText = "Doctor adjusted dosage. Feeling better. Health +3.",
			},
			{ 
				text = "💪 Push through", 
				effects = function(dynamicData)
					local sev = dynamicData and dynamicData.severity or 2
					return { Health = -sev * 2, Happiness = -sev }
				end,
				resultText = function(dynamicData)
					return "Side effects got worse. Health -" .. ((dynamicData and dynamicData.severity or 2) * 2) .. "."
				end,
			},
			{ 
				text = "🛑 Stop taking it", 
				effects = { Health = -5, Happiness = -3 }, 
				resultText = "Stopping without doctor approval was risky. Health -5." 
			},
		},
	},
}

return module
