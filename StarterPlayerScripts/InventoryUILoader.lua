-- InventoryUILoader - Loads the inventory UI system
-- Place this in StarterPlayer > StarterPlayerScripts

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- Wait for character to ensure UI is ready
player.CharacterAdded:Connect(function(character)
	-- Small delay to ensure all systems are loaded
	task.wait(1)
	
	-- Load the InventoryUI module
	local InventoryUI = require(ReplicatedStorage:WaitForChild("InventoryUI"))
	
	-- Make it globally accessible for testing
	_G.InventoryUI = InventoryUI
	_G.OpenInventory = function()
		InventoryUI.open()
	end
	
	print("✅ Inventory system loaded. Press 'I' to open inventory or use _G.OpenInventory()")
end)

-- Also load if character already exists
if player.Character then
	task.wait(1)
	local InventoryUI = require(ReplicatedStorage:WaitForChild("InventoryUI"))
	_G.InventoryUI = InventoryUI
	_G.OpenInventory = function()
		InventoryUI.open()
	end
	print("✅ Inventory system loaded. Press 'I' to open inventory or use _G.OpenInventory()")
end