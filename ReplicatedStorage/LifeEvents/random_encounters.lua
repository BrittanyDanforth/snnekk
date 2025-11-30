-- LifeEvents/random_encounters.lua
-- Random life events and encounters

local LifeEvents = require(script.Parent)
local module = {}

module.events = {
	{
		id = "m_stray_pet_encounter",
		minAge = 8, maxAge = 80,
		weight = 20, cooldown = 5,
		emoji = "🐕", title = "Stray Pet Found!",
		category = "random",
		getDynamicData = function()
			local petTypes = {"dog", "cat", "kitten", "puppy"}
			local petType = petTypes[math.random(#petTypes)]
			local petEmoji = "🐕"
			if petType == "cat" or petType == "kitten" then
				petEmoji = "🐱"
			end
			-- Pre-roll outcomes for randomness
			local willScratchShelter = math.random() < 0.3
			local willScratchHome = math.random() < 0.4
			local willAdopt = math.random() >= 0.4
			return { 
				petType = petType, 
				petEmoji = petEmoji,
				willScratchShelter = willScratchShelter,
				willScratchHome = willScratchHome,
				willAdopt = willAdopt,
			}
		end,
		getDynamicEmoji = function(dynamicData)
			return dynamicData and dynamicData.petEmoji or "🐕"
		end,
		text = "You found a stray %petType% wandering the neighborhood. It looks lost and scared.",
		choices = {
			{ 
				text = "🏠 Take it to a shelter", 
				effects = function(dynamicData)
					-- Random outcome - not always good
					if dynamicData and dynamicData.willScratchShelter then
						return { Happiness = 3, Health = -8, Smarts = 2 }
					else
						return { Happiness = 5, Smarts = 2 }
					end
				end,
				resultText = function(dynamicData)
					if dynamicData and dynamicData.willScratchShelter then
						return "The %petType% was scared and scratched you! You got hurt but still helped it to safety. Health -8, but you did the right thing."
					else
						return "You safely took the %petType% to the animal shelter. They'll find it a good home!"
					end
				end,
			},
			{ 
				text = "🏡 Take it home", 
				effects = function(dynamicData)
					if dynamicData and dynamicData.willScratchHome then
						return { Happiness = 6, Health = -5, Money = -500 }
					else
						return { Happiness = 10, Money = -500 }
					end
				end,
				resultText = function(dynamicData)
					if dynamicData and dynamicData.willScratchHome then
						return "The %petType% was aggressive at first and scratched you! But after some time, it warmed up to you. Health -5."
					else
						return "The %petType% is now part of your family! You've gained a new companion."
					end
				end,
				setFlags = function(dynamicData)
					if dynamicData and dynamicData.willAdopt then
						return {"has_pet", "pet_parent"}
					end
					return {}
				end,
			},
			{ 
				text = "🚶 Leave it alone", 
				effects = { Happiness = -2 }, 
				resultText = "You walked away. You hope someone else helps it." 
			},
		},
	},
}

return module
