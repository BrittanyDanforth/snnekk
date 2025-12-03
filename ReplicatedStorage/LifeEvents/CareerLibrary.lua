-- CareerLibrary.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- ONE AAA CAREER: Motorsport Icon. We rebuild other careers later once this rail is perfect.
-- ═══════════════════════════════════════════════════════════════════════════════

local CareerLibrary = {}

CareerLibrary["motorsport_icon"] = {
	id = "motorsport_icon",
	label = "Motorsport Icon",
	emoji = "🏎️",
	category = "motorsport",
	entryEventId = "motorsport_academy_contract",
	branches = {"single_seater", "endurance", "street_icon"},
	tiers = {
		{ id = "kart_prodigy", label = "Kart Prodigy", minAge = 6, baseIncome = {min = 0, max = 0}, eventTags = {"motorsport_child", "karting"} },
		{ id = "academy_dev", label = "Factory Academy Prospect", minAge = 14, baseIncome = {min = 0, max = 5000}, eventTags = {"motorsport_academy"} },
		{ id = "junior_formula", label = "Junior Formula Contender", minAge = 18, baseIncome = {min = 30000, max = 90000}, eventTags = {"motorsport_junior"} },

		{ id = "single_seater_f2", label = "Single-Seater Ladder", minAge = 20, baseIncome = {min = 120000, max = 400000}, eventTags = {"single_seater", "f2"}, branch = "single_seater" },
		{ id = "single_seater_elite", label = "World Series / F1", minAge = 23, baseIncome = {min = 500000, max = 12000000}, eventTags = {"single_seater", "world_stage"}, branch = "single_seater" },

		{ id = "endurance_factory", label = "Hypercar Factory Driver", minAge = 22, baseIncome = {min = 200000, max = 700000}, eventTags = {"endurance", "hypercar"}, branch = "endurance" },
		{ id = "endurance_icon", label = "Le Mans Legend", minAge = 26, baseIncome = {min = 600000, max = 1800000}, eventTags = {"endurance", "lemans"}, branch = "endurance" },

		{ id = "street_icon_headliner", label = "Street Icon Headliner", minAge = 20, baseIncome = {min = 150000, max = 800000}, eventTags = {"street_icon", "viral"}, branch = "street_icon" },
		{ id = "street_mogul", label = "Global Street Mogul", minAge = 24, baseIncome = {min = 400000, max = 2200000}, eventTags = {"street_icon", "media"}, branch = "street_icon" },

		{ id = "worldwide_icon", label = "Worldwide Motorsport Icon", minAge = 25, baseIncome = {min = 2000000, max = 15000000}, eventTags = {"motorsport_world"} },
		{ id = "legacy_founder", label = "Legacy Founder", minAge = 32, baseIncome = {min = 5000000, max = 40000000}, eventTags = {"motorsport_legend", "team_owner"} },
	},
}

function CareerLibrary.getCareer(careerId)
	return CareerLibrary[careerId]
end

function CareerLibrary.getAllCareers()
	local careers = {}
	for _, career in pairs(CareerLibrary) do
		if type(career) == "table" and career.id then
			table.insert(careers, career)
		end
	end
	return careers
end

function CareerLibrary.getCareersByCategory(category)
	local careers = {}
	for _, career in pairs(CareerLibrary) do
		if type(career) == "table" and career.category == category then
			table.insert(careers, career)
		end
	end
	return careers
end

function CareerLibrary.getTier(careerId, tierIndex)
	local career = CareerLibrary.getCareer(careerId)
	if career and career.tiers then
		return career.tiers[tierIndex]
	end
	return nil
end

function CareerLibrary.getTierByBranch(careerId, branch, tierIndex)
	local career = CareerLibrary.getCareer(careerId)
	if not career or not career.tiers then return nil end

	local branchTiers = {}
	for _, tier in ipairs(career.tiers) do
		if tier.branch == nil or tier.branch == branch then
			table.insert(branchTiers, tier)
		end
	end

	return branchTiers[tierIndex]
end

return CareerLibrary
