-- CareerSystem.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- GODLY CAREER MANAGEMENT SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- Handles:
-- - Starting careers
-- - Tier progression and promotions
-- - Branch selection (ethical vs unethical, specialty choices)
-- - Career income calculations
-- - Career requirements checking
-- - Multiple simultaneous careers support
--
-- ═══════════════════════════════════════════════════════════════════════════════

-- Safe require CareerLibrary
local CareerLibrary = nil
local clSuccess, clResult = pcall(function()
	return require(script.Parent.CareerLibrary)
end)
if clSuccess then
	CareerLibrary = clResult
else
	warn("[CareerSystem] ⚠️ CareerLibrary not loaded:", clResult)
	-- Provide minimal fallback
	CareerLibrary = {
		getCareer = function() return nil end,
		getAllCareers = function() return {} end,
		getTier = function() return nil end,
		getTierByBranch = function() return nil end,
	}
end

local CareerSystem = {}

-- ═══════════════════════════════════════════════════════════════
-- TYPES (for documentation)
-- ═══════════════════════════════════════════════════════════════

--[[
CareerInstance = {
	careerId: string,        -- "software_developer", "musician", etc.
	tierIndex: number,       -- Current tier (1, 2, 3...)
	branch: string?,         -- "ethical", "corporate", etc. or nil
	xp: number,              -- Experience points
	reputation: number,      -- Reputation in this career
	yearsInCareer: number,   -- How long they've been in this career
	yearStarted: number,     -- Age when started
	status: string,          -- "active", "retired", "fired", "on_leave"
	achievements: {string},  -- List of achievement IDs
}

LifeState.Careers = {
	primary: CareerInstance?,    -- Main career
	side: {CareerInstance}?,     -- Side careers/gigs
	history: {CareerInstance}?,  -- Past careers
}
]]

-- ═══════════════════════════════════════════════════════════════
-- CORE CAREER FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

-- Initialize careers table if needed
local function ensureCareersTable(state)
	if not state.Careers then
		state.Careers = {
			primary = nil,
			side = {},
			history = {},
		}
	end
	return state.Careers
end

-- Start a new career
function CareerSystem.startCareer(state, careerId, asSide)
	local careerDef = CareerLibrary.getCareer(careerId)
	if not careerDef then
		warn("[CareerSystem] Career not found:", careerId)
		return false, "Career not found"
	end
	
	local careers = ensureCareersTable(state)
	local age = state.Age or 18
	
	-- Check minimum age for first tier
	local firstTier = careerDef.tiers[1]
	if firstTier and firstTier.minAge and age < firstTier.minAge then
		return false, "Too young for this career"
	end
	
	-- Check education requirement
	if careerDef.requiresEducation then
		local playerEdu = state.Education or "none"
		-- Simple check - you could make this more sophisticated
		local eduRanks = {none = 0, high_school = 1, community = 2, bachelor = 3, master = 4, law = 5, medical = 5, phd = 6}
		local reqRank = eduRanks[careerDef.requiresEducation] or 0
		local playerRank = eduRanks[playerEdu] or 0
		if playerRank < reqRank then
			return false, "Need " .. careerDef.requiresEducation .. " education"
		end
	end
	
	-- Create career instance
	local instance = {
		careerId = careerId,
		tierIndex = 1,
		branch = nil, -- Will be set when they choose
		xp = 0,
		reputation = 0,
		yearsInCareer = 0,
		yearStarted = age,
		status = "active",
		achievements = {},
	}
	
	if asSide then
		table.insert(careers.side, instance)
	else
		-- If already has primary, move it to history
		if careers.primary then
			careers.primary.status = "left"
			table.insert(careers.history, careers.primary)
		end
		careers.primary = instance
	end
	
	-- Set career flag
	local flags = state.Flags or {}
	flags["career_" .. careerId] = true
	flags["career_" .. careerId .. "_started"] = true
	state.Flags = flags
	
	print("[CareerSystem] Started career:", careerId, "as", asSide and "side" or "primary")
	return true, "Career started!"
end

-- Get current career instance
function CareerSystem.getPrimaryCareer(state)
	local careers = ensureCareersTable(state)
	return careers.primary
end

-- Get career definition for current career
function CareerSystem.getCurrentCareerDef(state)
	local instance = CareerSystem.getPrimaryCareer(state)
	if not instance then return nil end
	return CareerLibrary.getCareer(instance.careerId)
end

-- Get current tier
function CareerSystem.getCurrentTier(state)
	local instance = CareerSystem.getPrimaryCareer(state)
	if not instance then return nil end
	
	local careerDef = CareerLibrary.getCareer(instance.careerId)
	if not careerDef then return nil end
	
	-- If career has branches, filter by branch
	if instance.branch and careerDef.branches then
		return CareerLibrary.getTierByBranch(instance.careerId, instance.branch, instance.tierIndex)
	end
	
	return careerDef.tiers[instance.tierIndex]
end

-- ═══════════════════════════════════════════════════════════════
-- PROGRESSION FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

-- Add XP to career
function CareerSystem.addXP(state, amount)
	local instance = CareerSystem.getPrimaryCareer(state)
	if not instance then return false end
	
	instance.xp = (instance.xp or 0) + amount
	
	-- Check for auto-promotion based on XP thresholds
	local careerDef = CareerLibrary.getCareer(instance.careerId)
	if careerDef then
		local nextTierIndex = instance.tierIndex + 1
		local nextTier = careerDef.tiers[nextTierIndex]
		
		-- Simple XP threshold: 100 XP per tier level
		local xpNeeded = nextTierIndex * 100
		if instance.xp >= xpNeeded and nextTier then
			-- Check if branch matches
			if not nextTier.branch or nextTier.branch == instance.branch then
				-- Auto-promote
				CareerSystem.promote(state)
			end
		end
	end
	
	return true
end

-- Add reputation
function CareerSystem.addReputation(state, amount)
	local instance = CareerSystem.getPrimaryCareer(state)
	if not instance then return false end
	
	instance.reputation = math.clamp((instance.reputation or 0) + amount, -100, 100)
	return true
end

-- Promote to next tier
function CareerSystem.promote(state)
	local instance = CareerSystem.getPrimaryCareer(state)
	if not instance then return false, "No active career" end
	
	local careerDef = CareerLibrary.getCareer(instance.careerId)
	if not careerDef then return false, "Career definition not found" end
	
	-- Find next valid tier (respecting branch)
	local currentIndex = instance.tierIndex
	local nextTier = nil
	local nextIndex = nil
	
	for i = currentIndex + 1, #careerDef.tiers do
		local tier = careerDef.tiers[i]
		-- Check if tier is valid for current branch
		if not tier.branch or tier.branch == instance.branch or not instance.branch then
			-- Check age requirement
			local age = state.Age or 0
			if not tier.minAge or age >= tier.minAge then
				nextTier = tier
				nextIndex = i
				break
			end
		end
	end
	
	if not nextTier then
		return false, "Already at max tier or no valid promotion available"
	end
	
	instance.tierIndex = nextIndex
	
	-- Set promotion flag
	local flags = state.Flags or {}
	flags["career_" .. instance.careerId .. "_tier_" .. nextIndex] = true
	flags[nextTier.id] = true
	state.Flags = flags
	
	print("[CareerSystem] Promoted to tier", nextIndex, ":", nextTier.label)
	return true, "Promoted to " .. nextTier.label .. "!"
end

-- Set career branch
function CareerSystem.setBranch(state, branch)
	local instance = CareerSystem.getPrimaryCareer(state)
	if not instance then return false, "No active career" end
	
	local careerDef = CareerLibrary.getCareer(instance.careerId)
	if not careerDef or not careerDef.branches then
		return false, "Career has no branches"
	end
	
	-- Verify branch is valid
	local validBranch = false
	for _, b in ipairs(careerDef.branches) do
		if b == branch then
			validBranch = true
			break
		end
	end
	
	if not validBranch then
		return false, "Invalid branch: " .. branch
	end
	
	instance.branch = branch
	
	-- Update tier index to first tier of this branch
	for i, tier in ipairs(careerDef.tiers) do
		if tier.branch == branch then
			instance.tierIndex = i
			break
		end
	end
	
	-- Set branch flag
	local flags = state.Flags or {}
	flags["career_" .. instance.careerId .. "_branch_" .. branch] = true
	flags[instance.careerId .. "_" .. branch] = true
	state.Flags = flags
	
	print("[CareerSystem] Set branch to:", branch)
	return true, "Branch set to " .. branch
end

-- Increment years in career (call on age-up)
function CareerSystem.yearPassed(state)
	local instance = CareerSystem.getPrimaryCareer(state)
	if not instance or instance.status ~= "active" then return end
	
	instance.yearsInCareer = (instance.yearsInCareer or 0) + 1
	
	-- Add some passive XP
	CareerSystem.addXP(state, 10 + math.random(0, 10))
end

-- ═══════════════════════════════════════════════════════════════
-- CONDITION CHECKING (for events)
-- ═══════════════════════════════════════════════════════════════

-- Check if player has a specific career
function CareerSystem.hasCareer(state, careerId)
	local instance = CareerSystem.getPrimaryCareer(state)
	return instance and instance.careerId == careerId and instance.status == "active"
end

-- Check if player meets career requirements for an event
function CareerSystem.meetsCareerRequirements(state, requiredCareerId, requiredMinTier, requiredBranch)
	if not requiredCareerId then return true end
	
	local instance = CareerSystem.getPrimaryCareer(state)
	if not instance then return false end
	if instance.status ~= "active" then return false end
	if instance.careerId ~= requiredCareerId then return false end
	
	if requiredMinTier and instance.tierIndex < requiredMinTier then
		return false
	end
	
	if requiredBranch and instance.branch ~= requiredBranch then
		return false
	end
	
	return true
end

-- Get career weight boost for an event based on tags
function CareerSystem.getCareerEventBoost(state, eventTags)
	if not eventTags then return 0 end
	
	local tier = CareerSystem.getCurrentTier(state)
	if not tier or not tier.eventTags then return 0 end
	
	-- Check for tag overlap
	for _, eventTag in ipairs(eventTags) do
		for _, careerTag in ipairs(tier.eventTags) do
			if eventTag == careerTag then
				return 25 -- +25 weight boost for matching career events
			end
		end
	end
	
	return 0
end

-- ═══════════════════════════════════════════════════════════════
-- INCOME FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

-- Calculate current income
function CareerSystem.calculateIncome(state)
	local tier = CareerSystem.getCurrentTier(state)
	if not tier or not tier.baseIncome then return 0 end
	
	local instance = CareerSystem.getPrimaryCareer(state)
	if not instance or instance.status ~= "active" then return 0 end
	
	local minIncome = tier.baseIncome.min
	local maxIncome = tier.baseIncome.max
	
	-- Base income in range
	local baseIncome = minIncome + (maxIncome - minIncome) * 0.5
	
	-- Modify by reputation (-50 to +50%)
	local repModifier = 1 + (instance.reputation or 0) / 200
	
	-- Modify by years of experience (+2% per year, max +30%)
	local expModifier = 1 + math.min((instance.yearsInCareer or 0) * 0.02, 0.3)
	
	local finalIncome = baseIncome * repModifier * expModifier
	
	return math.floor(finalIncome)
end

-- Get yearly salary for display
function CareerSystem.getYearlySalary(state)
	return CareerSystem.calculateIncome(state)
end

-- ═══════════════════════════════════════════════════════════════
-- CAREER STATUS FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

-- Quit career
function CareerSystem.quitCareer(state)
	local careers = ensureCareersTable(state)
	local instance = careers.primary
	
	if not instance then return false, "No career to quit" end
	
	instance.status = "quit"
	table.insert(careers.history, instance)
	careers.primary = nil
	
	-- Clear active career flag but keep history flag
	local flags = state.Flags or {}
	flags["career_" .. instance.careerId] = nil
	flags["career_" .. instance.careerId .. "_quit"] = true
	state.Flags = flags
	
	return true, "You quit your job"
end

-- Get fired
function CareerSystem.getFired(state)
	local careers = ensureCareersTable(state)
	local instance = careers.primary
	
	if not instance then return false, "No career" end
	
	instance.status = "fired"
	table.insert(careers.history, instance)
	careers.primary = nil
	
	local flags = state.Flags or {}
	flags["career_" .. instance.careerId] = nil
	flags["got_fired"] = true
	flags["career_" .. instance.careerId .. "_fired"] = true
	state.Flags = flags
	
	return true, "You got fired"
end

-- Retire from career
function CareerSystem.retire(state)
	local careers = ensureCareersTable(state)
	local instance = careers.primary
	
	if not instance then return false, "No career to retire from" end
	
	instance.status = "retired"
	table.insert(careers.history, instance)
	careers.primary = nil
	
	local flags = state.Flags or {}
	flags["retired_from_" .. instance.careerId] = true
	flags["retired"] = true
	state.Flags = flags
	
	return true, "You retired"
end

-- ═══════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

-- Get career display info
function CareerSystem.getDisplayInfo(state)
	local instance = CareerSystem.getPrimaryCareer(state)
	if not instance then
		return {
			hasCareer = false,
			title = "Unemployed",
			emoji = "🤷",
			salary = 0,
		}
	end
	
	local careerDef = CareerLibrary.getCareer(instance.careerId)
	local tier = CareerSystem.getCurrentTier(state)
	
	return {
		hasCareer = true,
		careerId = instance.careerId,
		title = tier and tier.label or careerDef.label,
		emoji = careerDef.emoji or "💼",
		salary = CareerSystem.calculateIncome(state),
		yearsInCareer = instance.yearsInCareer,
		tierIndex = instance.tierIndex,
		branch = instance.branch,
		reputation = instance.reputation,
		xp = instance.xp,
	}
end

-- Get all available careers for player
function CareerSystem.getAvailableCareers(state)
	local age = state.Age or 0
	local education = state.Education or "none"
	local available = {}
	
	local eduRanks = {none = 0, high_school = 1, community = 2, bachelor = 3, master = 4, law = 5, medical = 5, phd = 6}
	local playerEduRank = eduRanks[education] or 0
	
	for _, career in ipairs(CareerLibrary.getAllCareers()) do
		local firstTier = career.tiers[1]
		local minAge = firstTier and firstTier.minAge or 18
		
		local meetsAge = age >= minAge
		local meetsEdu = true
		
		if career.requiresEducation then
			local reqRank = eduRanks[career.requiresEducation] or 0
			meetsEdu = playerEduRank >= reqRank
		end
		
		if meetsAge and meetsEdu then
			table.insert(available, {
				career = career,
				meetsRequirements = true,
			})
		end
	end
	
	return available
end

return CareerSystem
