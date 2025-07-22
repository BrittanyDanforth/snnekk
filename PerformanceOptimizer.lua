-- PerformanceOptimizer.lua
-- This goes in ServerScriptService
-- Optimizes game performance to reduce ping and lag

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Performance monitoring
local lastPingCheck = 0
local PING_CHECK_INTERVAL = 5 -- Check every 5 seconds

-- Function to estimate server performance
local function getServerLoad()
	local physicsStepTime = game:GetService("Stats").PhysicsStepTimeMs:GetValue()
	local heartbeatTime = game:GetService("Stats").HeartbeatTimeMs:GetValue()
	
	-- High physics step time indicates server lag
	if physicsStepTime > 20 then -- Over 20ms is bad
		return "high"
	elseif physicsStepTime > 15 then
		return "medium"
	else
		return "low"
	end
end

-- Optimize orb settings based on server load
local function optimizeOrbSettings()
	local load = getServerLoad()
	
	-- Send optimization signal to OrbSpawner
	local optimizeRemote = ReplicatedStorage:FindFirstChild("OptimizeSettings")
	if not optimizeRemote then
		optimizeRemote = Instance.new("RemoteEvent")
		optimizeRemote.Name = "OptimizeSettings"
		optimizeRemote.Parent = ReplicatedStorage
	end
	
	local settings = {
		low = {
			maxOrbs = 400,
			spawnInterval = 0.5,
			lodDistance = 200
		},
		medium = {
			maxOrbs = 300,
			spawnInterval = 0.75,
			lodDistance = 150
		},
		high = {
			maxOrbs = 200, -- Drastically reduce orbs when lagging
			spawnInterval = 1.0,
			lodDistance = 100
		}
	}
	
	-- Fire to all clients
	optimizeRemote:FireAllClients(settings[load])
	
	print("🎮 Server Load:", load, "- Optimizing with", settings[load].maxOrbs, "max orbs")
end

-- Monitor and optimize periodically
RunService.Heartbeat:Connect(function()
	local now = tick()
	if now - lastPingCheck > PING_CHECK_INTERVAL then
		lastPingCheck = now
		optimizeOrbSettings()
	end
end)

-- Notify when players join about optimizations
Players.PlayerAdded:Connect(function(player)
	wait(3) -- Let them load in
	local load = getServerLoad()
	if load == "high" then
		-- Warn player about performance
		local warnRemote = ReplicatedStorage:FindFirstChild("PerformanceWarning")
		if not warnRemote then
			warnRemote = Instance.new("RemoteEvent")
			warnRemote.Name = "PerformanceWarning"
			warnRemote.Parent = ReplicatedStorage
		end
		warnRemote:FireClient(player, "⚠️ Server is experiencing high load. Performance optimizations active.")
	end
end)

print("✅ Performance Optimizer loaded - monitoring server performance")