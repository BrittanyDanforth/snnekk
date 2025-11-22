local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Robust error handling for module loading
local function loadModule()
	local moduleName = "SnakeCollisionHandler"
	local module
	
	-- Try ServerScriptService first
	module = ServerScriptService:FindFirstChild(moduleName)
	
	-- Try ReplicatedStorage fallback
	if not module then
		module = ReplicatedStorage:FindFirstChild(moduleName)
	end
	
	-- Wait if not found immediately
	if not module then
		module = ServerScriptService:WaitForChild(moduleName, 5)
	end
	
	if not module then
		warn("❌ InitializeCollisionHandler: Could not find " .. moduleName)
		return nil
	end
	
	if not module:IsA("ModuleScript") then
		warn("❌ InitializeCollisionHandler: " .. moduleName .. " is a " .. module.ClassName .. ", not a ModuleScript! Please convert it to a ModuleScript.")
		return nil
	end
	
	return require(module)
end

local SnakeCollisionHandler = loadModule()

if SnakeCollisionHandler then
	-- Initialize the collision handler
	local collisionHandler = SnakeCollisionHandler.new()

	-- Optional: Store reference globally for other scripts
	_G.CollisionHandler = collisionHandler

	print("✅ Snake game collision system initialized!")
	print("📋 Features: Modern spatial queries, Trove pattern, Fixed death orbs, ReviveUI")

	-- Optional: Cleanup on server shutdown
	game:BindToClose(function()
		if collisionHandler and collisionHandler.destroy then
			collisionHandler:destroy()
		end
	end)
else
	warn("⚠️ SnakeCollisionHandler failed to load - Collision system may be inactive")
end