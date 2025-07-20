-- Mobile Setup Script - Place in ServerScriptService
-- This configures StarterPlayer properties for mobile controls

local StarterPlayer = game:GetService("StarterPlayer")

-- Set movement modes to Scriptable to disable default controls
StarterPlayer.DevComputerMovementMode = Enum.DevComputerMovementMode.Scriptable
StarterPlayer.DevTouchMovementMode = Enum.DevTouchMovementMode.Scriptable

-- Additional mobile optimizations
StarterPlayer.CharacterWalkSpeed = 0 -- We control movement manually
StarterPlayer.CharacterJumpPower = 0 -- No jumping in snake game
StarterPlayer.CharacterJumpHeight = 0

print("StarterPlayer configured for mobile/scriptable controls")