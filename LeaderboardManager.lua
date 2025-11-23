-- ServerScriptService/LeaderboardManager.lua
-- Optimized High-Performance Leaderboard Manager
-- Handles both Players (via Leaderstats/Attributes) and AI Snakes (via Attributes)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- Create RemoteEvent if it doesn't exist
local LeaderboardUpdated = ReplicatedStorage:FindFirstChild("LeaderboardUpdated")
if not LeaderboardUpdated then
	LeaderboardUpdated = Instance.new("RemoteEvent")
	LeaderboardUpdated.Name = "LeaderboardUpdated"
	LeaderboardUpdated.Parent = ReplicatedStorage
end

local SNAKES_FOLDER = Workspace:FindFirstChild("Snakes") or Instance.new("Folder", Workspace)
SNAKES_FOLDER.Name = "Snakes"

local UPDATE_RATE = 0.25 -- Increased update rate for smoother visuals (4 times/sec)
local LEADERBOARD_SIZE = 10
local lastUpdate = 0

-- Cache for player objects to avoid repeated lookups
local playerCache = {}

Players.PlayerAdded:Connect(function(player)
	playerCache[player.UserId] = player
end)

Players.PlayerRemoving:Connect(function(player)
	playerCache[player.UserId] = nil
end)

for _, player in ipairs(Players:GetPlayers()) do
	playerCache[player.UserId] = player
end

RunService.Heartbeat:Connect(function(dt)
	lastUpdate = lastUpdate + dt
	if lastUpdate < UPDATE_RATE then return end
	lastUpdate = 0

	local entries = {}
	local processedPlayers = {}

	-- 1. Scan AI Snakes and Player Snakes in Folder
	-- Using GetChildren is fast enough for ~100 items
	for _, model in ipairs(SNAKES_FOLDER:GetChildren()) do
		if not model:IsA("Model") then
			continue
		end

		local isAI = model:GetAttribute("IsAI") == true
		local lengthAttr = model:GetAttribute("Length") or 0

		if isAI then
			-- PURE AI: trust the model's Length attribute
			if lengthAttr > 0 then
				local name = model:GetAttribute("AIName") or model.Name
				table.insert(entries, {
					Name = name,
					Score = math.floor(lengthAttr),
					IsPlayer = false,
					PlayerId = -1,
					Rank = 0
				})
			end
		else
			-- PLAYER SNAKE: DO NOT trust model.Length, always use leaderstats
			local playerId = model:GetAttribute("PlayerUserId")
			local player

			if playerId then
				player = playerCache[playerId]
			else
				-- fallback by name if no attribute
				player = Players:FindFirstChild(model.Name)
			end

			if player and not processedPlayers[player.UserId] then
				processedPlayers[player.UserId] = true

				local score = 0
				local stats = player:FindFirstChild("leaderstats")
				local lenStat = stats and stats:FindFirstChild("Length")
				if lenStat then
					score = lenStat.Value
				else
					-- fallback to attributes if no leaderstats (rare)
					score = player:GetAttribute("Length")
						or (player.Character and player.Character:GetAttribute("Length"))
						or 0
				end

				if score > 0 then
					table.insert(entries, {
						Name = player.DisplayName,
						Score = math.floor(score),
						IsPlayer = true,
						PlayerId = player.UserId,
						Rank = 0
					})
				end
			end
		end
	end

	-- 2. Catch any players NOT in the Snakes folder (e.g. just spawned, or using different system)
	for userId, player in pairs(playerCache) do
		if not processedPlayers[userId] then
			local score = 0
			-- Check Leaderstats
			local stats = player:FindFirstChild("leaderstats")
			local lenStat = stats and stats:FindFirstChild("Length")
			if lenStat then
				score = lenStat.Value
			else
				-- Check Attributes on Player or Character
				score = player:GetAttribute("Length") or (player.Character and player.Character:GetAttribute("Length")) or 0
			end

			if score > 0 then
				table.insert(entries, {
					Name = player.DisplayName,
					Score = math.floor(score),
					IsPlayer = true,
					PlayerId = userId,
					Rank = 0
				})
			end
		end
	end

	-- 3. Sort
	table.sort(entries, function(a, b)
		return a.Score > b.Score
	end)

	-- 4. Trim and Rank
	local topEntries = {}
	for i = 1, math.min(#entries, LEADERBOARD_SIZE) do
		local entry = entries[i]
		entry.Rank = i
		table.insert(topEntries, entry)
	end

	-- 5. Broadcast
	LeaderboardUpdated:FireAllClients(topEntries)
end)

print("✅ Leaderboard Manager V2.2 (Synced & Smooth) Loaded")