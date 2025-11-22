-- ClientSnakeLoader v4.5
-- High-fidelity loader for beam-based player snakes with graceful fallbacks

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LOCAL_PLAYER = Players.LocalPlayer

local MODULE_CANDIDATES = {
	"OptimizedSnakeSystem",
	"OptimizedSnakeSystemV9",
	"OptimizedSnakeSystemV8_ContinuousBeam",
}

local activeModuleName

local function requireBeamSystem()
	for _, moduleName in ipairs(MODULE_CANDIDATES) do
		local module = ReplicatedStorage:FindFirstChild(moduleName)
		if module and module:IsA("ModuleScript") then
			local ok, lib = pcall(require, module)
			if ok and type(lib) == "table" then
				activeModuleName = moduleName
				print(string.format("✅ ClientSnakeLoader: Loaded %s", moduleName))
				return lib
			else
				warn(string.format("[ClientSnakeLoader] Failed to require %s: %s", moduleName, tostring(lib)))
			end
		end
	end

	warn(string.format(
		"[ClientSnakeLoader] No snake visual module found. Looked for: %s",
		table.concat(MODULE_CANDIDATES, ", ")
	))
	return nil
end

local BeamSnakeSystem = requireBeamSystem()

local function getStubSystem()
	return {
		init = function()
			warn("[ClientSnakeLoader] Stub snake visuals active – drop the real beam module for effects.")
		end,
		createSnake = function()
			return {
				destroy = function() end,
				setLength = function() end,
				applySkin = function() end,
			}
		end,
	}
end

if not BeamSnakeSystem then
	BeamSnakeSystem = getStubSystem()
	activeModuleName = "stub"
end

local ok, initErr = pcall(function()
	if BeamSnakeSystem.init then
		BeamSnakeSystem.init()
	end
end)

if ok then
	print("✅ ClientSnakeLoader: Beam system initialised.")
else
	warn("⚠️ ClientSnakeLoader: Beam init failed:", initErr)
end

local activeSnakes = {}

local function disconnectAll(connections)
	if not connections then
		return
	end
	for _, conn in ipairs(connections) do
		if conn and conn.Disconnect then
			conn:Disconnect()
		end
	end
	table.clear(connections)
end

local function cleanupPlayerSnake(player)
	local entry = activeSnakes[player]
	if not entry then
		return
	end

	disconnectAll(entry.connections)

	if entry.snake and entry.snake.destroy then
		pcall(entry.snake.destroy, entry.snake)
	end

	activeSnakes[player] = nil
end

local function buildConfigForPlayer(targetPlayer)
	return {
		InitialLength = targetPlayer:GetAttribute("SnakeLength") or 10,
		HeadColor = targetPlayer:GetAttribute("HeadColor") or Color3.fromRGB(76, 217, 100),
		SkinName = targetPlayer:GetAttribute("EquippedSkin") or "Default",
		BodyColors = targetPlayer:GetAttribute("BodyColors"),
	}
end

local function spawnVisualSnake(character, owner)
	local config = buildConfigForPlayer(owner)

	if type(BeamSnakeSystem) == "function" then
		return BeamSnakeSystem(character, config)
	end

	local constructor = BeamSnakeSystem.createSnake or BeamSnakeSystem.new or BeamSnakeSystem.CreateSnake
	if type(constructor) ~= "function" then
		error(string.format("[ClientSnakeLoader] Module %s is missing createSnake/new constructor", tostring(activeModuleName)))
	end

	return constructor(character, config)
end

local function createVisualSnake(character)
	local owner = Players:GetPlayerFromCharacter(character)
	if not owner then
		return
	end

	cleanupPlayerSnake(owner)

	task.wait(0.2)

	local snakeInstance
	local success, err = pcall(function()
		snakeInstance = spawnVisualSnake(character, owner)
	end)

	if not success or not snakeInstance then
		warn(string.format("[ClientSnakeLoader] Failed to create visual snake for %s: %s", owner.Name, err))
		return
	end

	print(string.format("✅ ClientSnakeLoader: Visual snake ready for %s", owner.Name))

	local attributeConnections = {}

	attributeConnections[#attributeConnections + 1] = owner:GetAttributeChangedSignal("SnakeLength"):Connect(function()
		local newLength = owner:GetAttribute("SnakeLength")
		if newLength and snakeInstance.setLength then
			pcall(snakeInstance.setLength, snakeInstance, newLength)
		end
	end)

	attributeConnections[#attributeConnections + 1] = owner:GetAttributeChangedSignal("EquippedSkin"):Connect(function()
		local skin = owner:GetAttribute("EquippedSkin")
		if skin and snakeInstance.applySkin then
			pcall(snakeInstance.applySkin, snakeInstance, skin)
		end
	end)

	activeSnakes[owner] = {
		snake = snakeInstance,
		connections = attributeConnections,
	}
end

local function hookPlayer(player)
	player.CharacterAdded:Connect(createVisualSnake)

	if player.Character then
		createVisualSnake(player.Character)
	end
end

local function onPlayerRemoving(player)
	cleanupPlayerSnake(player)
end

for _, existingPlayer in ipairs(Players:GetPlayers()) do
	if existingPlayer ~= LOCAL_PLAYER then
		hookPlayer(existingPlayer)
	end
end

Players.PlayerAdded:Connect(function(plr)
	if plr ~= LOCAL_PLAYER then
		hookPlayer(plr)
	end
end)

Players.PlayerRemoving:Connect(onPlayerRemoving)

RunService.RenderStepped:Connect(function()
	for player, entry in pairs(activeSnakes) do
		if not player.Character or not player.Character.Parent then
			cleanupPlayerSnake(player)
		end
	end
end)

print("✅ ClientSnakeLoader initialised – monitoring beam snakes for all players.")
