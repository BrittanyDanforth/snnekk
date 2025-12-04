--[[
	LifeRemoteHandlers.server.lua
	AAA BitLife-Style Remote Event Handlers
	
	Handles all player actions:
	- Jobs & Career
	- Education
	- Assets
	- Relationships
	- Activities
	- Crime
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--------------------------------------------------------------------------------
-- WAIT FOR MAIN SYSTEM
--------------------------------------------------------------------------------

-- Wait for LifeManager to create remotes
local remotesFolder = ReplicatedStorage:WaitForChild("LifeRemotes", 10)
if not remotesFolder then
	warn("[LifeRemoteHandlers] LifeRemotes folder not found!")
	return
end

-- Wait a moment for all remotes to be created
task.wait(0.1)

local function getRemote(name, isFunction)
	local remote = remotesFolder:WaitForChild(name, 5)
	if not remote then
		warn("[LifeRemoteHandlers] Remote not found: " .. name)
		return nil
	end
	return remote
end

local function getState(player)
	if _G.GetLifeState then
		return _G.GetLifeState(player)
	end
	return nil
end

local function syncState(player, feedText, resultData)
	if _G.SyncPlayerState then
		_G.SyncPlayerState(player, feedText, resultData)
	end
end

--------------------------------------------------------------------------------
-- JOB DATA
--------------------------------------------------------------------------------

local Jobs = {
	-- Entry Level
	{ id = "fastfood", name = "Fast Food Worker", salary = 22000, minAge = 14, category = "entry" },
	{ id = "retail", name = "Retail Associate", salary = 26000, minAge = 16, category = "entry" },
	{ id = "cashier", name = "Cashier", salary = 24000, minAge = 15, category = "entry" },
	
	-- Service
	{ id = "waiter", name = "Waiter/Waitress", salary = 32000, minAge = 16, category = "service" },
	{ id = "bartender", name = "Bartender", salary = 38000, minAge = 21, category = "service" },
	{ id = "barista", name = "Barista", salary = 28000, minAge = 16, category = "service" },
	
	-- Trades
	{ id = "janitor", name = "Janitor", salary = 28000, minAge = 18, category = "trades" },
	{ id = "construction", name = "Construction Worker", salary = 42000, minAge = 18, category = "trades" },
	{ id = "mechanic", name = "Auto Mechanic", salary = 45000, minAge = 18, requirement = "high_school", category = "trades" },
	{ id = "electrician", name = "Electrician", salary = 62000, minAge = 22, requirement = "high_school", category = "trades" },
	{ id = "plumber", name = "Plumber", salary = 58000, minAge = 22, requirement = "high_school", category = "trades" },
	
	-- Office
	{ id = "receptionist", name = "Receptionist", salary = 32000, minAge = 18, requirement = "high_school", category = "office" },
	{ id = "office_assistant", name = "Office Assistant", salary = 35000, minAge = 18, requirement = "high_school", category = "office" },
	{ id = "hr_coordinator", name = "HR Coordinator", salary = 48000, minAge = 22, requirement = "bachelor", category = "office" },
	{ id = "project_manager", name = "Project Manager", salary = 85000, minAge = 28, requirement = "bachelor", category = "office" },
	
	-- Technology
	{ id = "it_support", name = "IT Support", salary = 45000, minAge = 18, requirement = "high_school", category = "tech" },
	{ id = "junior_developer", name = "Junior Developer", salary = 65000, minAge = 21, requirement = "bachelor", category = "tech" },
	{ id = "developer", name = "Software Developer", salary = 95000, minAge = 23, requirement = "bachelor", category = "tech" },
	{ id = "senior_developer", name = "Senior Developer", salary = 145000, minAge = 27, requirement = "bachelor", category = "tech" },
	
	-- Medical
	{ id = "medical_assistant", name = "Medical Assistant", salary = 36000, minAge = 18, requirement = "high_school", category = "medical" },
	{ id = "nurse_rn", name = "Registered Nurse", salary = 78000, minAge = 22, requirement = "bachelor", category = "medical" },
	{ id = "doctor", name = "Doctor", salary = 250000, minAge = 30, requirement = "medical", category = "medical" },
	{ id = "surgeon", name = "Surgeon", salary = 420000, minAge = 34, requirement = "medical", category = "medical" },
	
	-- Legal
	{ id = "paralegal", name = "Paralegal", salary = 52000, minAge = 22, requirement = "bachelor", category = "law" },
	{ id = "lawyer", name = "Attorney", salary = 145000, minAge = 28, requirement = "law", category = "law" },
	{ id = "judge", name = "Judge", salary = 195000, minAge = 45, requirement = "law", category = "law" },
	
	-- Finance
	{ id = "bank_teller", name = "Bank Teller", salary = 34000, minAge = 18, requirement = "high_school", category = "finance" },
	{ id = "accountant", name = "Accountant", salary = 78000, minAge = 25, requirement = "bachelor", category = "finance" },
	{ id = "financial_analyst", name = "Financial Analyst", salary = 85000, minAge = 23, requirement = "bachelor", category = "finance" },
	{ id = "investment_banker", name = "Investment Banker", salary = 225000, minAge = 28, requirement = "master", category = "finance" },
	
	-- Creative
	{ id = "photographer", name = "Photographer", salary = 48000, minAge = 18, category = "creative" },
	{ id = "graphic_designer", name = "Graphic Designer", salary = 62000, minAge = 24, requirement = "bachelor", category = "creative" },
	{ id = "journalist", name = "Journalist", salary = 62000, minAge = 26, requirement = "bachelor", category = "creative" },
	
	-- Government
	{ id = "postal_worker", name = "Postal Worker", salary = 45000, minAge = 18, requirement = "high_school", category = "government" },
	{ id = "police_officer", name = "Police Officer", salary = 58000, minAge = 21, requirement = "high_school", category = "government" },
	{ id = "firefighter", name = "Firefighter", salary = 55000, minAge = 18, requirement = "high_school", category = "government" },
	
	-- Education
	{ id = "teacher_assistant", name = "Teacher Assistant", salary = 32000, minAge = 18, requirement = "high_school", category = "education" },
	{ id = "teacher", name = "Teacher", salary = 55000, minAge = 25, requirement = "bachelor", category = "education" },
	{ id = "professor", name = "Professor", salary = 125000, minAge = 35, requirement = "phd", category = "education" },
}

local JobsById = {}
for _, job in ipairs(Jobs) do
	JobsById[job.id] = job
end

local function meetsJobRequirement(state, requirement)
	if not requirement then return true end
	
	if requirement == "high_school" then
		return state:HasDegree("high_school") or state:HasDegree("bachelor")
	elseif requirement == "bachelor" then
		return state:HasDegree("bachelor")
	elseif requirement == "master" then
		return state:HasDegree("master")
	elseif requirement == "law" then
		return state:HasDegree("law")
	elseif requirement == "medical" then
		return state:HasDegree("medical")
	elseif requirement == "phd" then
		return state:HasDegree("phd")
	end
	
	return false
end

--------------------------------------------------------------------------------
-- JOB HANDLERS
--------------------------------------------------------------------------------

local ApplyForJob = getRemote("ApplyForJob")
if ApplyForJob then
	ApplyForJob.OnServerEvent:Connect(function(player, jobId)
		local state = getState(player)
		if not state then return end
		
		local job = JobsById[jobId]
		if not job then return end
		
		-- Check age
		if state.Age < job.minAge then
			syncState(player, "❌ You're too young for this job.", {
				showPopup = true,
				emoji = "❌",
				title = "Application Denied",
				body = string.format("You must be at least %d years old.", job.minAge),
			})
			return
		end
		
		-- Check requirement
		if job.requirement and not meetsJobRequirement(state, job.requirement) then
			syncState(player, "❌ You don't meet the education requirements.", {
				showPopup = true,
				emoji = "❌",
				title = "Application Denied",
				body = "You need more education for this position.",
			})
			return
		end
		
		-- Check if in prison
		if state:IsInPrison() then
			syncState(player, "❌ You can't work while in prison.")
			return
		end
		
		-- Check if already employed
		if state:HasJob() then
			state:ClearCareer()
		end
		
		-- Apply for job (80% success rate)
		if math.random() < 0.8 then
			state:SetCareer(job.category, job.id, job.name, job.salary)
			state:AddFeed(string.format("💼 You got hired as a %s!", job.name))
			
			syncState(player, string.format("💼 You got hired as a %s!", job.name), {
				showPopup = true,
				emoji = "💼",
				title = "Hired!",
				body = string.format("Congratulations! You're now a %s earning $%s/year.", job.name, job.salary),
				happiness = 10,
			})
		else
			syncState(player, "😔 Your application was rejected.", {
				showPopup = true,
				emoji = "😔",
				title = "Not Hired",
				body = "Unfortunately, they went with another candidate.",
				happiness = -5,
			})
		end
	end)
end

local QuitJob = getRemote("QuitJob")
if QuitJob then
	QuitJob.OnServerEvent:Connect(function(player)
		local state = getState(player)
		if not state then return end
		
		if not state:HasJob() then
			return
		end
		
		local jobTitle = state.Career.title
		state:ClearCareer()
		state:AddFeed(string.format("👋 You quit your job as %s.", jobTitle))
		
		syncState(player, string.format("👋 You quit your job as %s.", jobTitle))
	end)
end

local DoWork = getRemote("DoWork")
if DoWork then
	DoWork.OnServerEvent:Connect(function(player)
		local state = getState(player)
		if not state then return end
		
		if not state:HasJob() then
			return
		end
		
		-- Work hard - increase performance
		state.Career.performance = math.min(100, state.Career.performance + math.random(5, 15))
		state:ModifyStat("Happiness", -5)
		
		syncState(player, "💪 You worked extra hard today!", {
			showPopup = true,
			emoji = "💪",
			title = "Hard Work",
			body = "Your performance improved!",
			happiness = -5,
		})
	end)
end

local RequestPromotion = getRemote("RequestPromotion")
if RequestPromotion then
	RequestPromotion.OnServerEvent:Connect(function(player)
		local state = getState(player)
		if not state then return end
		
		if not state:HasJob() then return end
		
		-- Promotion chance based on performance
		local chance = state.Career.performance / 100 * 0.5
		
		if math.random() < chance then
			local newSalary = math.floor(state.Career.salary * 1.2)
			state.Career.salary = newSalary
			state.Career.tier = state.Career.tier + 1
			state:AddFeed("🎉 You got promoted!")
			
			syncState(player, "🎉 You got promoted!", {
				showPopup = true,
				emoji = "🎉",
				title = "Promoted!",
				body = string.format("Your new salary is $%s/year!", newSalary),
				happiness = 15,
				money = math.floor(newSalary * 0.1),
			})
		else
			syncState(player, "😔 Your promotion request was denied.", {
				showPopup = true,
				emoji = "😔",
				title = "No Promotion",
				body = "Maybe next time. Keep working hard!",
				happiness = -10,
			})
		end
	end)
end

local RequestRaise = getRemote("RequestRaise")
if RequestRaise then
	RequestRaise.OnServerEvent:Connect(function(player)
		local state = getState(player)
		if not state then return end
		
		if not state:HasJob() then return end
		
		-- Raise chance
		local chance = state.Career.performance / 100 * 0.4
		
		if math.random() < chance then
			local raise = math.floor(state.Career.salary * 0.1)
			state.Career.salary = state.Career.salary + raise
			
			syncState(player, "💰 You got a raise!", {
				showPopup = true,
				emoji = "💰",
				title = "Raise!",
				body = string.format("You got a $%s raise!", raise),
				happiness = 10,
			})
		else
			syncState(player, "😔 Your raise request was denied.")
		end
	end)
end

local GetCareerInfo = getRemote("GetCareerInfo")
if GetCareerInfo and GetCareerInfo:IsA("RemoteFunction") then
	GetCareerInfo.OnServerInvoke = function(player)
		local state = getState(player)
		if not state then return nil end
		
		return {
			hasJob = state:HasJob(),
			jobId = state.Career.jobId,
			title = state.Career.title,
			salary = state.Career.salary,
			performance = state.Career.performance,
			tier = state.Career.tier,
			experience = state.Career.experience,
		}
	end
end

--------------------------------------------------------------------------------
-- EDUCATION HANDLERS
--------------------------------------------------------------------------------

local EducationPrograms = {
	{ id = "community", name = "Community College", cost = 5000, years = 2, minAge = 18 },
	{ id = "bachelor", name = "University (Bachelor's)", cost = 40000, years = 4, minAge = 18 },
	{ id = "master", name = "Graduate School (Master's)", cost = 60000, years = 2, minAge = 22, requires = "bachelor" },
	{ id = "law", name = "Law School", cost = 120000, years = 3, minAge = 22, requires = "bachelor" },
	{ id = "medical", name = "Medical School", cost = 200000, years = 4, minAge = 22, requires = "bachelor" },
	{ id = "phd", name = "PhD Program", cost = 80000, years = 4, minAge = 24, requires = "master" },
}

local EducationById = {}
for _, prog in ipairs(EducationPrograms) do
	EducationById[prog.id] = prog
end

local EnrollEducation = getRemote("EnrollEducation")
if EnrollEducation then
	EnrollEducation.OnServerEvent:Connect(function(player, programId)
		local state = getState(player)
		if not state then return end
		
		local program = EducationById[programId]
		if not program then return end
		
		-- Check age
		if state.Age < program.minAge then
			syncState(player, "❌ You're too young for this program.")
			return
		end
		
		-- Check prerequisite
		if program.requires and not state:HasDegree(program.requires) then
			syncState(player, "❌ You need to complete prerequisite education first.")
			return
		end
		
		-- Check if already enrolled
		if state.Education.enrolled then
			syncState(player, "❌ You're already enrolled in a program.")
			return
		end
		
		-- Check if already has this degree
		if state:HasDegree(programId) then
			syncState(player, "❌ You already have this degree.")
			return
		end
		
		-- Check money
		if not state:HasMoney(program.cost) then
			-- Take out student loans
			state.Education.debt = (state.Education.debt or 0) + program.cost
		else
			state:RemoveMoney(program.cost)
		end
		
		state:Enroll(programId, program.name, nil)
		state:AddFeed(string.format("📚 You enrolled in %s!", program.name))
		
		syncState(player, string.format("📚 You enrolled in %s!", program.name), {
			showPopup = true,
			emoji = "📚",
			title = "Enrolled!",
			body = string.format("You're now studying at %s.", program.name),
			money = -program.cost,
		})
	end)
end

local GetEducationInfo = getRemote("GetEducationInfo")
if GetEducationInfo and GetEducationInfo:IsA("RemoteFunction") then
	GetEducationInfo.OnServerInvoke = function(player)
		local state = getState(player)
		if not state then return nil end
		
		return {
			enrolled = state.Education.enrolled,
			level = state.Education.level,
			institution = state.Education.institution,
			yearsCompleted = state.Education.yearsCompleted,
			gpa = state.Education.gpa,
			degrees = state.Education.degrees,
			debt = state.Education.debt,
		}
	end
end

--------------------------------------------------------------------------------
-- ASSET HANDLERS
--------------------------------------------------------------------------------

local BuyAsset = getRemote("BuyAsset")
if BuyAsset then
	BuyAsset.OnServerEvent:Connect(function(player, assetType, assetData)
		local state = getState(player)
		if not state then return end
		
		local price = assetData.price or 0
		
		if not state:HasMoney(price) then
			syncState(player, "❌ You can't afford this.")
			return
		end
		
		state:RemoveMoney(price)
		state:AddAsset(assetType, assetData)
		
		syncState(player, string.format("🎉 You bought a %s!", assetData.name or assetType), {
			showPopup = true,
			emoji = "🛒",
			title = "Purchased!",
			body = string.format("You bought a %s for $%s!", assetData.name or assetType, price),
			money = -price,
		})
	end)
end

local SellAsset = getRemote("SellAsset")
if SellAsset then
	SellAsset.OnServerEvent:Connect(function(player, assetType, assetId)
		local state = getState(player)
		if not state then return end
		
		local asset = state:RemoveAsset(assetType, assetId)
		if asset then
			local salePrice = math.floor((asset.value or asset.price or 0) * 0.8)
			state:AddMoney(salePrice)
			
			syncState(player, string.format("💰 You sold your %s!", asset.name or assetType), {
				showPopup = true,
				emoji = "💰",
				title = "Sold!",
				body = string.format("You sold it for $%s!", salePrice),
				money = salePrice,
			})
		end
	end)
end

local GetAssets = getRemote("GetAssets")
if GetAssets and GetAssets:IsA("RemoteFunction") then
	GetAssets.OnServerInvoke = function(player)
		local state = getState(player)
		if not state then return nil end
		
		return {
			properties = state.Assets.properties,
			vehicles = state.Assets.vehicles,
			items = state.Assets.items,
			crypto = state.Assets.crypto,
			netWorth = state:GetNetWorth(),
		}
	end
end

--------------------------------------------------------------------------------
-- RELATIONSHIP HANDLERS
--------------------------------------------------------------------------------

local InteractRelationship = getRemote("InteractRelationship")
if InteractRelationship then
	InteractRelationship.OnServerEvent:Connect(function(player, relationshipId, action)
		local state = getState(player)
		if not state then return end
		
		local rel = state:GetRelationship(relationshipId)
		if not rel then return end
		
		if action == "spend_time" then
			state:ModifyRelationship(relationshipId, math.random(5, 15))
			state:ModifyStat("Happiness", 5)
			
			syncState(player, string.format("💕 You spent quality time with %s.", rel.name), {
				showPopup = true,
				emoji = "💕",
				title = "Time Together",
				body = string.format("Your relationship with %s improved!", rel.name),
				happiness = 5,
			})
			
		elseif action == "gift" then
			if state:HasMoney(100) then
				state:RemoveMoney(100)
				state:ModifyRelationship(relationshipId, math.random(10, 20))
				
				syncState(player, string.format("🎁 You gave a gift to %s.", rel.name), {
					showPopup = true,
					emoji = "🎁",
					title = "Gift Given",
					body = string.format("%s loved the gift!", rel.name),
					money = -100,
				})
			else
				syncState(player, "❌ You can't afford a gift right now.")
			end
			
		elseif action == "argue" then
			state:ModifyRelationship(relationshipId, -math.random(10, 25))
			state:ModifyStat("Happiness", -10)
			
			syncState(player, string.format("😤 You had an argument with %s.", rel.name), {
				showPopup = true,
				emoji = "😤",
				title = "Argument",
				body = string.format("Your relationship with %s suffered.", rel.name),
				happiness = -10,
			})
		end
	end)
end

local GetRelationships = getRemote("GetRelationships")
if GetRelationships and GetRelationships:IsA("RemoteFunction") then
	GetRelationships.OnServerInvoke = function(player)
		local state = getState(player)
		if not state then return {} end
		
		local relationships = {}
		for id, rel in pairs(state.Relationships) do
			table.insert(relationships, {
				id = id,
				name = rel.name,
				type = rel.type,
				relationship = rel.relationship,
				closeness = rel.closeness,
				age = rel.age,
				alive = rel.alive,
			})
		end
		
		return relationships
	end
end

--------------------------------------------------------------------------------
-- ACTIVITY HANDLERS
--------------------------------------------------------------------------------

local Activities = {
	{ id = "gym", name = "Go to Gym", effect = { Health = 5, Looks = 2 }, cost = 0 },
	{ id = "read", name = "Read a Book", effect = { Smarts = 5 }, cost = 0 },
	{ id = "party", name = "Go Partying", effect = { Happiness = 10, Health = -3 }, cost = 50, minAge = 18 },
	{ id = "vacation", name = "Take a Vacation", effect = { Happiness = 20, Health = 5 }, cost = 2000 },
	{ id = "meditate", name = "Meditate", effect = { Happiness = 10, Health = 3 }, cost = 0 },
	{ id = "spa", name = "Visit Spa", effect = { Happiness = 15, Looks = 5 }, cost = 200 },
	{ id = "doctor", name = "Visit Doctor", effect = { Health = 20 }, cost = 500 },
	{ id = "plastic_surgery", name = "Plastic Surgery", effect = { Looks = 15, Health = -5 }, cost = 15000, minAge = 18 },
}

local ActivitiesById = {}
for _, act in ipairs(Activities) do
	ActivitiesById[act.id] = act
end

local DoActivity = getRemote("DoActivity")
if DoActivity then
	DoActivity.OnServerEvent:Connect(function(player, activityId)
		local state = getState(player)
		if not state then return end
		
		local activity = ActivitiesById[activityId]
		if not activity then return end
		
		-- Check age
		if activity.minAge and state.Age < activity.minAge then
			syncState(player, "❌ You're too young for this activity.")
			return
		end
		
		-- Check cost
		if activity.cost > 0 and not state:HasMoney(activity.cost) then
			syncState(player, "❌ You can't afford this activity.")
			return
		end
		
		-- Deduct cost
		if activity.cost > 0 then
			state:RemoveMoney(activity.cost)
		end
		
		-- Apply effects
		state:ApplyEffects(activity.effect)
		state:AddFeed(string.format("⚡ You did: %s", activity.name))
		
		syncState(player, string.format("⚡ You did: %s", activity.name), {
			showPopup = true,
			emoji = "⚡",
			title = activity.name,
			body = "Activity completed!",
			happiness = activity.effect.Happiness,
			health = activity.effect.Health,
			smarts = activity.effect.Smarts,
			looks = activity.effect.Looks,
			money = activity.cost > 0 and -activity.cost or nil,
		})
	end)
end

--------------------------------------------------------------------------------
-- CRIME HANDLERS
--------------------------------------------------------------------------------

local Crimes = {
	{ id = "shoplift", name = "Shoplift", reward = 50, catchChance = 0.3, sentence = 1 },
	{ id = "pickpocket", name = "Pickpocket", reward = 100, catchChance = 0.25, sentence = 1 },
	{ id = "burglary", name = "Burglary", reward = 5000, catchChance = 0.4, sentence = 3 },
	{ id = "rob_bank", name = "Rob Bank", reward = 50000, catchChance = 0.6, sentence = 10 },
	{ id = "grand_theft_auto", name = "Grand Theft Auto", reward = 20000, catchChance = 0.35, sentence = 5 },
}

local CrimesById = {}
for _, crime in ipairs(Crimes) do
	CrimesById[crime.id] = crime
end

local CommitCrime = getRemote("CommitCrime")
if CommitCrime then
	CommitCrime.OnServerEvent:Connect(function(player, crimeId)
		local state = getState(player)
		if not state then return end
		
		local crime = CrimesById[crimeId]
		if not crime then return end
		
		-- Can't commit crimes in prison
		if state:IsInPrison() then
			syncState(player, "❌ You can't commit crimes while in prison!")
			return
		end
		
		-- Check if caught
		if math.random() < crime.catchChance then
			state:GoToPrison(crime.sentence, crime.name)
			state:AddFeed(string.format("🚔 You got caught committing %s!", crime.name))
			
			syncState(player, string.format("🚔 You got caught and sentenced to %d years!", crime.sentence), {
				showPopup = true,
				emoji = "🚔",
				title = "Arrested!",
				body = string.format("You were caught committing %s and sentenced to %d years.", crime.name, crime.sentence),
				happiness = -30,
			})
		else
			state:AddMoney(crime.reward)
			state:SetFlag("criminal_activity")
			state:AddFeed(string.format("💰 You successfully committed %s!", crime.name))
			
			syncState(player, string.format("💰 You got away with %s!", crime.name), {
				showPopup = true,
				emoji = "💰",
				title = "Crime Successful!",
				body = string.format("You got away with $%s!", crime.reward),
				money = crime.reward,
				happiness = 10,
			})
		end
	end)
end

local EscapePrison = getRemote("EscapePrison")
if EscapePrison then
	EscapePrison.OnServerEvent:Connect(function(player)
		local state = getState(player)
		if not state then return end
		
		if not state:IsInPrison() then return end
		
		-- 20% escape chance
		if math.random() < 0.2 then
			state:ReleaseFromPrison()
			state.Criminal.escaped = true
			state:SetFlag("escaped_prison")
			state:AddFeed("🏃 You escaped from prison!")
			
			syncState(player, "🏃 You escaped from prison!", {
				showPopup = true,
				emoji = "🏃",
				title = "Escaped!",
				body = "You're now a fugitive!",
				happiness = 20,
			})
		else
			-- Add time for failed escape
			state.Criminal.yearsLeft = state.Criminal.yearsLeft + 2
			state:ModifyStat("Health", -10)
			state:AddFeed("🚨 Your escape attempt failed! 2 years added to your sentence.")
			
			syncState(player, "🚨 Escape failed! 2 more years added.", {
				showPopup = true,
				emoji = "🚨",
				title = "Escape Failed!",
				body = "You were caught and punished. 2 years added to your sentence.",
				happiness = -20,
				health = -10,
			})
		end
	end)
end

--------------------------------------------------------------------------------
-- STORY PATHS
--------------------------------------------------------------------------------

local GetStoryPaths = getRemote("GetStoryPaths")
if GetStoryPaths and GetStoryPaths:IsA("RemoteFunction") then
	GetStoryPaths.OnServerInvoke = function(player)
		local state = getState(player)
		if not state then return {} end
		
		local paths = {
			{
				id = "career",
				name = "Career Path",
				progress = state:HasJob() and 50 or 0,
				description = "Build your professional career",
			},
			{
				id = "education",
				name = "Academic Path",
				progress = #state.Education.degrees * 25,
				description = "Pursue higher education",
			},
			{
				id = "family",
				name = "Family Life",
				progress = state:HasFlag("married") and 50 or (state:HasPartner() and 25 or 0),
				description = "Build a family",
			},
			{
				id = "crime",
				name = "Criminal Path",
				progress = state:HasCriminalRecord() and 50 or (state:HasFlag("criminal_activity") and 25 or 0),
				description = "Live outside the law",
			},
			{
				id = "fame",
				name = "Fame & Fortune",
				progress = state.Fame or 0,
				description = "Become famous",
			},
		}
		
		return paths
	end
end

print("[LifeRemoteHandlers] ✅ All handlers initialized")
