-- ServerScriptService/SnakeSystemIntegration.lua
-- Handles player joining, character spawning, and snake creation
-- Bridges the gap between Roblox characters and the custom Snake system

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

-- Load the core snake system
local OptimizedSnakeSystem = require(Workspace:WaitForChild("OptimizedSnakeSystem"))

-- Load collision handler if needed
local SnakeCollisionHandler = nil
task.spawn(function()
	-- Wait for collision handler to be ready
	local handler = _G.CollisionHandler
	while not handler do
		task.wait(0.5)
		handler = _G.CollisionHandler
	end
	SnakeCollisionHandler = handler
end)

local DEFAULT_CONFIG = {
	InitialLength = 15, -- Changed from 55 to 15 to match AI/Config default
	MaxSegments = 5000,
	
	HeadColor = Color3.fromRGB(76, 217, 100), -- Standard green
	BodyColors = {
		Color3.fromRGB(60, 180, 80),
		Color3.fromRGB(80, 200, 100),
		Color3.fromRGB(100, 220, 120),
		Color3.fromRGB(80, 200, 100),
		Color3.fromRGB(60, 180, 80),
	}
}

-- Ensure optimized system is initialized
if OptimizedSnakeSystem.init then
	OptimizedSnakeSystem.init()
end

local function onCharacterAdded(character)
	local player = Players:GetPlayerFromCharacter(character)
	if not player then return end
	
	-- Wait for root part
	local rootPart = character:WaitForChild("HumanoidRootPart", 10)
	if not rootPart then return end
	
	print("🐍 Creating snake for " .. player.Name .. " with config: " .. DEFAULT_CONFIG.InitialLength .. " length")
	
	-- Check for existing length in leaderstats or attributes to restore progress
	local startLength = DEFAULT_CONFIG.InitialLength
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local lenStat = leaderstats:FindFirstChild("Length")
		if lenStat and lenStat.Value > 0 then
			startLength = lenStat.Value
		end
	end
	
	-- Also check attribute backup
	local attrLen = player:GetAttribute("Length")
	if attrLen and attrLen > startLength then
		startLength = attrLen
	end
	
	-- Create configuration for this specific snake
	local config = table.clone(DEFAULT_CONFIG)
	config.InitialLength = startLength
	
	-- Apply skin colors if available
	local skinData = player:GetAttribute("SkinData") -- Assuming JSON or similar if used
	-- (Add skin loading logic here if you have a skin system)
	
	-- Create the snake
	local snake = OptimizedSnakeSystem.createSnake(character, config)
	
	if snake then
		-- Store reference
		_G.PlayerSnakes = _G.PlayerSnakes or {}
		_G.PlayerSnakes[player] = snake
		
		-- Register with collision handler
		if SnakeCollisionHandler and SnakeCollisionHandler.registerPlayer then
			SnakeCollisionHandler.registerPlayer(player, snake)
		end
		
		print("✅ Snake created successfully for " .. player.Name)
	else
		warn("❌ Failed to create snake for " .. player.Name)
	end
end

local function onPlayerAdded(player)
	-- Create leaderstats
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	
	local length = Instance.new("IntValue")
	length.Name = "Length"
	length.Value = DEFAULT_CONFIG.InitialLength -- Init with 15
	length.Parent = leaderstats
	
	player.CharacterAdded:Connect(onCharacterAdded)
	
	-- Handle initial character if already exists
	if player.Character then
		onCharacterAdded(player.Character)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)

-- Handle existing players
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

-- Cleanup on leave
Players.PlayerRemoving:Connect(function(player)
	if _G.PlayerSnakes then
		local snake = _G.PlayerSnakes[player]
		if snake and snake.destroy then
			snake:destroy()
		end
		_G.PlayerSnakes[player] = nil
	end
end)

-- Optional: Spawn Request Handler
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpawnRequest = Instance.new("RemoteEvent")
SpawnRequest.Name = "SpawnRequest"
SpawnRequest.Parent = ReplicatedStorage

SpawnRequest.OnServerEvent:Connect(function(player)
	player:LoadCharacter()
end)

print("✅ Snake System Integration loaded!")