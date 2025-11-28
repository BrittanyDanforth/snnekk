-- LifeState.lua
-- Server-side representation of a player's life state.

local LifeState = {}
LifeState.__index = LifeState

local function clamp(n, minVal, maxVal)
	if n < minVal then
		return minVal
	elseif n > maxVal then
		return maxVal
	else
		return n
	end
end

function LifeState.new(player)
	local self = setmetatable({}, LifeState)

	self.PlayerId = player.UserId

	self.Name = nil
	self.Gender = nil

	self.Age = 0
	self.Year = 2025
	self.Money = 0

	self.Stats = {
		Happiness = 80,
		Health = 80,
		Looks = 70,
		Smarts = 70,
	}

	self.Feed = {}

	return self
end

function LifeState:AddFeed(text)
	table.insert(self.Feed, text)
end

function LifeState:ClampStats()
	for key, value in pairs(self.Stats) do
		self.Stats[key] = clamp(math.floor(value), 0, 100)
	end
end

return LifeState
