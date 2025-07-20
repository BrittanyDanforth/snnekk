-- Mobile Setup Script - Place in ServerScriptService
-- This configures StarterPlayer properties for mobile controls

local StarterPlayer = game:GetService("StarterPlayer")

-- Keep default controls for PC, only set Scriptable for mobile
-- Mobile detection will be handled client-side
StarterPlayer.DevComputerMovementMode = Enum.DevComputerMovementMode.UserChoice
StarterPlayer.DevTouchMovementMode = Enum.DevTouchMovementMode.Scriptable

-- Additional optimizations
StarterPlayer.CharacterWalkSpeed = 16 -- Default speed for PC
StarterPlayer.CharacterJumpPower = 50 -- Default jump for PC
StarterPlayer.CharacterJumpHeight = 7.2

print("StarterPlayer configured - PC controls preserved, mobile set to scriptable")