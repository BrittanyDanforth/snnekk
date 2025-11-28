-- LifeState.lua
-- Server-side representation of a player's life state with story paths.

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

	-- Basic info
	self.Name = nil
	self.Gender = nil

	-- Time
	self.Age = 0
	self.Year = 2025

	-- Economy
	self.Money = 0

	-- Core stats
	self.Stats = {
		Happiness = 80,
		Health = 80,
		Looks = 70,
		Smarts = 70,
	}
	
	-- For backwards compatibility, expose stats at top level too
	self.Happiness = 80
	self.Health = 80
	self.Looks = 70
	self.Smarts = 70

	-- Education & Career
	self.Education = nil  -- "High School", "College", etc.
	self.Job = nil
	self.JobTitle = nil
	self.JobSalary = 0

	-- Criminal/Legal status
	self.InJail = false
	self.JailTime = 0
	self.CriminalRecord = {}

	-- Assets
	self.Assets = {}  -- { [assetId] = { type, value, ... } }
	
	-- Relationships
	self.Relationships = {} -- { [personId] = { name, relation, status, ... } }

	-- Story Flags (for branching narrative)
	self.Flags = {}
	--[[
		Political path flags:
		- political_interest
		- political_experience
		- campaign_experience
		- elected_official
		- state_senator
		- congressman
		- us_senator
		- presidential_candidate
		- president
		- corrupt
		- integrity
		- major_achievement
		
		Criminal path flags:
		- criminal_tendencies
		- car_thief
		- gang_member
		- violent_criminal
		- war_veteran
		- killer
		- prison_respect
		- prison_gang
		- underboss
		- crime_boss
		- empire_expanded
		- fugitive
		- legitimate
		- ex_con
	]]

	-- Event History (for one-time events, cooldowns, milestones)
	self.EventHistory = {
		seenEvents = {},      -- { [eventId] = true }
		lastOccurrence = {},  -- { [eventId] = age }
		milestonesFired = {}, -- { [eventId] = true }
	}

	-- Feed log
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
	-- Sync to top-level for backwards compatibility
	self.Happiness = self.Stats.Happiness
	self.Health = self.Stats.Health
	self.Looks = self.Stats.Looks
	self.Smarts = self.Stats.Smarts
end

function LifeState:SetFlag(flag, value)
	self.Flags[flag] = value ~= false and true or nil
end

function LifeState:HasFlag(flag)
	return self.Flags[flag] == true
end

function LifeState:GetStoryProgress(path)
	if path == "political" then
		if self.Flags.president then return 100
		elseif self.Flags.us_senator then return 85
		elseif self.Flags.congressman then return 70
		elseif self.Flags.state_senator then return 50
		elseif self.Flags.elected_official then return 30
		elseif self.Flags.political_experience then return 15
		elseif self.Flags.political_interest then return 5
		else return 0 end
		
	elseif path == "criminal" then
		if self.Flags.crime_boss then return 100
		elseif self.Flags.underboss then return 75
		elseif self.Flags.gang_member and self.Flags.war_veteran then return 50
		elseif self.Flags.gang_member then return 35
		elseif self.Flags.car_thief then return 20
		elseif self.Flags.criminal_tendencies then return 10
		else return 0 end
	end
	
	return 0
end

function LifeState:GetStoryTitle(path)
	if path == "political" then
		if self.Flags.president then return "President"
		elseif self.Flags.us_senator then return "U.S. Senator"
		elseif self.Flags.congressman then return "Congressman"
		elseif self.Flags.state_senator then return "State Senator"
		elseif self.Flags.elected_official then return "City Council"
		elseif self.Flags.political_experience then return "Political Intern"
		elseif self.Flags.political_interest then return "Interested"
		else return "Citizen" end
		
	elseif path == "criminal" then
		if self.Flags.crime_boss then return "Crime Boss"
		elseif self.Flags.underboss then return "Underboss"
		elseif self.Flags.gang_member and self.Flags.war_veteran then return "Made Member"
		elseif self.Flags.gang_member then return "Gang Member"
		elseif self.Flags.car_thief then return "Car Thief"
		elseif self.Flags.criminal_tendencies then return "Petty Criminal"
		else return "Law-Abiding" end
	end
	
	return "Unknown"
end

return LifeState
