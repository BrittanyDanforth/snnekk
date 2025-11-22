-- Temporary compatibility shim so Roblox places still referencing
-- `ServerScriptService.SnakeCollisionHandler` keep working.
local parent = script.Parent

local ok, moduleOrError = pcall(function()
	return require(parent:WaitForChild("SnakeCollisionHandler_V10_Fixed"))
end)

if not ok then
	error(string.format(
		"[SnakeCollisionHandler] Failed to require V10 module: %s",
		tostring(moduleOrError)
	))
end

return moduleOrError
