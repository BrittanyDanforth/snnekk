-- EventLibrary.lua
-- Defines life events and their choices.

local EventLibrary = {}

local events = {
	{
		id = "first_steps",
		minAge = 1,
		maxAge = 1,
		weight = 10,
		text = "You're learning to walk! What's your approach?",
		choices = {
			{
				id = "take_time",
				text = "🚶 Take your time",
				effects = {
					Stats = { Health = 2, Happiness = 5 },
				},
				resultText = "You took careful steps and didn't fall! Everyone clapped!",
			},
			{
				id = "run_immediately",
				text = "🏃 Run immediately",
				effects = {
					Stats = { Health = -5, Happiness = 3 },
				},
				resultText = "You tried to run before you were ready and took a small tumble.",
			},
		},
	},

	{
		id = "playground_toy",
		minAge = 2,
		maxAge = 4,
		weight = 8,
		text = "Another kid at the playground steals your toy. How do you react?",
		choices = {
			{
				id = "tell_teacher",
				text = "🧑‍🏫 Tell a teacher",
				effects = {
					Stats = { Happiness = 3, Smarts = 2 },
				},
				resultText = "You told a nearby teacher. They made the kid give the toy back.",
			},
			{
				id = "swing_on_kid",
				text = "👊 Swing on the kid",
				effects = {
					Stats = { Happiness = -2, Health = -4 },
				},
				resultText = "You swung on the kid and started a tiny brawl. Staff broke it up.",
			},
		},
	},
	
	{
		id = "unfriended",
		minAge = 10,
		maxAge = 100,
		weight = 5,
		text = "Your best friend, Bradley, has unfriended you.\nWhat will you do?",
		choices = {
			{
				id = "insult",
				text = "Insult him one last time",
				effects = {
					Stats = { Happiness = -5 },
				},
				resultText = "You sent one final insult. It felt good, but you lost a friend.",
			},
			{
				id = "let_go",
				text = "Let him go",
				effects = {
					Stats = { Happiness = -2, Smarts = 3 },
				},
				resultText = "You accepted the situation and moved on with dignity.",
			},
			{
				id = "salvage",
				text = "Try to salvage our friendship",
				effects = {
					Stats = { Happiness = 5, Smarts = 2 },
				},
				resultText = "You reached out and managed to patch things up!",
			},
		},
	},
}

EventLibrary.Events = events

local byId = {}
for _, ev in ipairs(events) do
	byId[ev.id] = ev
end

EventLibrary.ById = byId

return EventLibrary
