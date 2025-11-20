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

	for _, snakeModel in SNAKES_FOLDER:GetChildren() do
        if not snakeModel:IsA("Model") or not snakeModel:FindFirstChild("Head") then
            continue
        end

        local snakeName = "AI Snake"
        local isPlayer = false

		local userIdAttr = snakeModel:GetAttribute("PlayerUserId")
		local numericId = tonumber(userIdAttr) or tonumber(snakeModel.Name)
		local player = numericId and Players:GetPlayerByUserId(numericId) or nil
        if player then
            snakeName = player.DisplayName
            isPlayer = true
        else
            snakeName = snakeModel:GetAttribute("AIName") or snakeModel.Name
        end

        local snakeLength = snakeModel:GetAttribute("Length") or 0

        table.insert(leaderboardData, {
            Name = snakeName,
            Score = snakeLength,
            IsPlayer = isPlayer,
			PlayerId = player and player.UserId or (numericId or -1)
        })
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
