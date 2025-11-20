-- LeaderboardManager
-- Periodically scans all snakes (player and AI) and broadcasts the top scores

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LeaderboardUpdated = ReplicatedStorage:WaitForChild("LeaderboardUpdated")
local SNAKES_FOLDER = Workspace:WaitForChild("Snakes")

local UPDATE_INTERVAL = 1
local LEADERBOARD_SIZE = 10

	while true do
		task.wait(UPDATE_INTERVAL)

		local leaderboardData = {}
		local playerEntries = {}

		for _, snakeModel in SNAKES_FOLDER:GetChildren() do
			if not snakeModel:IsA("Model") or not snakeModel:FindFirstChild("Head") then
				continue
			end

			local snakeName = snakeModel:GetAttribute("AIName") or snakeModel.Name or "AI Snake"
			local isPlayer = false
			local playerId = snakeModel:GetAttribute("PlayerUserId")
			playerId = tonumber(playerId) or tonumber(snakeModel.Name)
			local player = playerId and Players:GetPlayerByUserId(playerId) or nil

			if player then
				snakeName = player.DisplayName
				isPlayer = true
			end

			local snakeLength = snakeModel:GetAttribute("Length") or 0
			local entry = {
				Name = snakeName,
				Score = snakeLength,
				IsPlayer = isPlayer,
				PlayerId = playerId or -1
			}

			if isPlayer and entry.PlayerId and entry.PlayerId ~= -1 then
				local existing = playerEntries[entry.PlayerId]
				if not existing or entry.Score > existing.Score then
					playerEntries[entry.PlayerId] = entry
				end
			else
				table.insert(leaderboardData, entry)
			end
		end

		for _, entry in pairs(playerEntries) do
			table.insert(leaderboardData, entry)
		end

		for _, player in ipairs(Players:GetPlayers()) do
			if not playerEntries[player.UserId] then
				local leaderstats = player:FindFirstChild("leaderstats")
				local lengthValue = leaderstats and leaderstats:FindFirstChild("Length")
				local score = lengthValue and lengthValue.Value or 0

				table.insert(leaderboardData, {
					Name = player.DisplayName,
					Score = score,
					IsPlayer = true,
					PlayerId = player.UserId
				})
			end
		end

		table.sort(leaderboardData, function(a, b)
			return a.Score > b.Score
		end)

		local topScores = {}
		for i = 1, math.min(#leaderboardData, LEADERBOARD_SIZE) do
			table.insert(topScores, leaderboardData[i])
		end

		LeaderboardUpdated:FireAllClients(topScores)
	end
