-- OrbSpawnerInit: Server script to initialize the OrbSpawner module
-- This ensures OrbSpawner is loaded and available for death orb registration

print("🚀 OrbSpawnerInit starting...")

local OrbSpawner = require(game.Workspace:WaitForChild("OrbSpawner"))

-- Initialize the spawner
if OrbSpawner.start then
    OrbSpawner:start()
    print("✅ OrbSpawner initialized successfully with start method")
else
    -- If no start method, the module self-initializes
    print("✅ OrbSpawner loaded (self-initializing)")
end

-- Make it globally accessible for death orb registration
_G.OrbSpawner = OrbSpawner

-- Verify the registerExternalOrb function exists
if OrbSpawner.registerExternalOrb then
    print("✅ OrbSpawner.registerExternalOrb is available")
else
    warn("❌ OrbSpawner.registerExternalOrb is NOT available!")
end