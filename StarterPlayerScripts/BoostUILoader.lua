-- BoostUILoader - StarterPlayer.StarterPlayerScripts
-- Loads the boost item UI system

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer

-- Wait for modules
local BoostItemHandler = require(ReplicatedStorage:WaitForChild("BoostItemHandler"))

-- Initialize boost system
local boostHandler = BoostItemHandler.new(localPlayer)

print("✅ Boost UI System loaded!")