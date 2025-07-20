-- Disable Camera Controls - Place in StarterPlayerScripts
-- This ensures camera is completely locked like slither.io

local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Wait for character
player.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid")
	
	-- Disable camera zoom
	player.CameraMinZoomDistance = 128
	player.CameraMaxZoomDistance = 128
	
	-- Set camera mode to prevent any manipulation
	player.CameraMode = Enum.CameraMode.Classic
	
	-- Disable the PlayerModule camera controls
	local playerScripts = player:WaitForChild("PlayerScripts")
	local playerModule = require(playerScripts:WaitForChild("PlayerModule"))
	
	-- Get camera controller and disable it
	task.wait(0.1) -- Small wait to ensure modules are loaded
	local cameraController = playerModule:GetCameras()
	if cameraController then
		-- Disable all default camera behavior
		cameraController:SetCameraType(Enum.CameraType.Scriptable)
		
		-- Override camera update function
		if cameraController.Update then
			cameraController.Update = function() end
		end
	end
end)

-- Also handle it immediately if character already exists
if player.Character then
	player.CharacterAdded:Fire(player.Character)
end

print("Camera controls disabled - Camera fully locked!")