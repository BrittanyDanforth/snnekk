-- Test Mobile Detection Script
-- Place in StarterPlayerScripts to test if mobile is detected properly

local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create debug GUI
local debugGui = Instance.new("ScreenGui")
debugGui.Name = "MobileDebug"
debugGui.Parent = playerGui

local debugFrame = Instance.new("Frame")
debugFrame.Size = UDim2.new(0, 400, 0, 200)
debugFrame.Position = UDim2.new(0.5, -200, 0.5, -100)
debugFrame.BackgroundColor3 = Color3.new(0, 0, 0)
debugFrame.BackgroundTransparency = 0.3
debugFrame.Parent = debugGui

local debugText = Instance.new("TextLabel")
debugText.Size = UDim2.new(1, -20, 1, -20)
debugText.Position = UDim2.new(0, 10, 0, 10)
debugText.BackgroundTransparency = 1
debugText.TextColor3 = Color3.new(1, 1, 1)
debugText.Font = Enum.Font.SourceSans
debugText.TextScaled = true
debugText.TextXAlignment = Enum.TextXAlignment.Left
debugText.TextYAlignment = Enum.TextYAlignment.Top
debugText.Parent = debugFrame

-- Gather info
local viewport = workspace.CurrentCamera.ViewportSize
local info = {
	"=== MOBILE DETECTION DEBUG ===",
	"TouchEnabled: " .. tostring(UserInputService.TouchEnabled),
	"MouseEnabled: " .. tostring(UserInputService.MouseEnabled),
	"KeyboardEnabled: " .. tostring(UserInputService.KeyboardEnabled),
	"GyroscopeEnabled: " .. tostring(UserInputService.GyroscopeEnabled),
	"AccelerometerEnabled: " .. tostring(UserInputService.AccelerometerEnabled),
	"GamepadEnabled: " .. tostring(UserInputService.GamepadEnabled),
	"TenFootInterface: " .. tostring(GuiService:IsTenFootInterface()),
	"Viewport: " .. viewport.X .. "x" .. viewport.Y,
	"Aspect Ratio: " .. string.format("%.2f", viewport.X / viewport.Y),
	"_G.IsMobile: " .. tostring(_G.IsMobile),
	"Platform: " .. tostring(UserInputService:GetPlatform()),
}

debugText.Text = table.concat(info, "\n")

-- Auto-remove after 10 seconds
task.wait(10)
debugGui:Destroy()