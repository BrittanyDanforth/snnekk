--[[
    VFX SERVER SCRIPT – PET EGG VERSION (REVAMPED)
    Put this Script in ServerScriptService.

    • Spawns real egg models that:
        - Glow, float and spin
        - Are tagged "VFXInteractive"
        - Have attributes the client expects:

            VFXRarity = "Common" | "Rare" | "Epic" | "Legendary"
            VFXType   = "Screen"   (client will still run full PET hatch because PetName exists)
            PetName   = "Axolotl"

    • Only eggs are auto-spawned.
    • No more MagicOrb/PowerCrystal/GodCrystal auto-spawns.
]]

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")

print("🖥️ VFX Server Script (Pet Eggs - REVAMPED) starting...")

----------------------------------------------------------------
-- ASSETS
----------------------------------------------------------------

local Assets = ReplicatedStorage:WaitForChild("Assets", 10)
local EggTemplate = Assets and Assets:FindFirstChild("EggModel")

if not Assets or not EggTemplate then
	warn("⚠️ EggModel not found in ReplicatedStorage.Assets! No eggs will spawn.")
end

-- spawn height (old was 10; ~60% lower → 4)
local GROUND_Y = 4

local RARITY_COLORS = {
	Common    = Color3.fromRGB(200, 200, 200),
	Rare      = Color3.fromRGB(0, 150, 255),
	Epic      = Color3.fromRGB(138, 43, 226),
	Legendary = Color3.fromRGB(255, 215, 0),
}

local function getRarityColor(rarity)
	return RARITY_COLORS[rarity] or RARITY_COLORS.Common
end

----------------------------------------------------------------
-- CREATE INTERACTIVE PET EGG
----------------------------------------------------------------

local function createInteractiveEgg(position, rarity, petName)
	if not EggTemplate then
		warn("❌ Cannot create egg – EggModel missing.")
		return nil
	end

	position = position or Vector3.new(0, GROUND_Y, 0)
	rarity   = rarity   or "Epic"
	petName  = petName  or "Axolotl"

	-- Clone template
	local egg = EggTemplate:Clone()
	egg.Name = string.format("%sEgg", rarity)
	egg.Parent = workspace

	-- Root
	local root =
		egg.PrimaryPart
		or egg:FindFirstChild("EggBase")
		or egg:FindFirstChildWhichIsA("BasePart")

	if not root then
		warn("❌ EggModel has no root part (EggBase / BasePart).")
		egg:Destroy()
		return nil
	end

	egg.PrimaryPart = root
	egg:PivotTo(CFrame.new(position))

	-- Make the whole model move as one piece
	for _, inst in ipairs(egg:GetDescendants()) do
		if inst:IsA("BasePart") then
			inst.CanCollide = false
			inst.Massless = true
			inst.Anchored = false

			if inst ~= root then
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = root
				weld.Part1 = inst
				weld.Parent = root
			end
		end
	end

	root.Anchored = false
	root.CanCollide = false
	root.Name = "EggBase"

	-- Attributes the client reads
	root:SetAttribute("VFXInteractive", true)
	root:SetAttribute("VFXRarity", rarity)
	root:SetAttribute("VFXType", "Screen")
	root:SetAttribute("PetName", petName)

	-- Tag for CollectionService
	CollectionService:AddTag(root, "VFXInteractive")

	-- Light
	local pointLight = root:FindFirstChildWhichIsA("PointLight")
	if not pointLight then
		pointLight = Instance.new("PointLight")
		pointLight.Parent = root
	end

	pointLight.Color = getRarityColor(rarity)
	pointLight.Brightness = 3
	pointLight.Range = 20

	-- Float + spin via Body movers (entire model welded to root)
	local bodyPosition = Instance.new("BodyPosition")
	bodyPosition.Name = "FloatPosition"
	bodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyPosition.P = 6000
	bodyPosition.D = 300
	bodyPosition.Position = position
	bodyPosition.Parent = root

	local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
	bodyAngularVelocity.Name = "Spin"
	bodyAngularVelocity.AngularVelocity = Vector3.new(0, 1.5, 0)
	bodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
	bodyAngularVelocity.P = 2000
	bodyAngularVelocity.Parent = root

	-- Smooth bobbing
	task.spawn(function()
		local baseY = position.Y
		local t = 0
		while egg.Parent and root.Parent do
			t += RunService.Heartbeat:Wait()
			local offset = math.sin(t * 2) * 0.6
			bodyPosition.Position = Vector3.new(position.X, baseY + offset, position.Z)
		end
	end)

	print(string.format("✨ Created %s pet egg at (%.1f, %.1f, %.1f) for pet '%s'",
		rarity, position.X, position.Y, position.Z, petName))

	return egg
end

----------------------------------------------------------------
-- OPTIONAL CRYSTAL HELPER (NO AUTO SPAWN)
----------------------------------------------------------------

local function createInteractiveCrystal(position, rarity, name)
	rarity = rarity or "Rare"
	position = position or Vector3.new(0, GROUND_Y, 0)

	local crystal = Instance.new("Part")
	crystal.Name = name or (rarity .. "Crystal")
	crystal.Size = Vector3.new(4, 4, 4)
	crystal.Position = position
	crystal.Anchored = true
	crystal.Material = Enum.Material.Neon
	crystal.Shape = Enum.PartType.Ball
	crystal.Color = getRarityColor(rarity)
	crystal.Parent = workspace

	crystal:SetAttribute("VFXInteractive", true)
	crystal:SetAttribute("VFXRarity", rarity)
	crystal:SetAttribute("VFXType", "Screen")

	CollectionService:AddTag(crystal, "VFXInteractive")

	local pointLight = Instance.new("PointLight")
	pointLight.Color = crystal.Color
	pointLight.Brightness = 3
	pointLight.Range = 25
	pointLight.Parent = crystal

	print(string.format("💎 Created %s crystal '%s' at (%.1f, %.1f, %.1f)",
		rarity, crystal.Name, position.X, position.Y, position.Z))

	return crystal
end

----------------------------------------------------------------
-- EXPOSE GLOBAL HELPERS
----------------------------------------------------------------

_G.CreateInteractiveEgg     = createInteractiveEgg
_G.CreateInteractiveCrystal = createInteractiveCrystal

----------------------------------------------------------------
-- AUTO TEST SPAWN – EGGS ONLY
----------------------------------------------------------------

task.delay(2, function()
	if not EggTemplate then
		warn("⚠️ Skipping egg test spawns – EggModel missing.")
		return
	end

	print("🎮 Spawning test PET eggs at ground-ish level...")

	local y = GROUND_Y

	createInteractiveEgg(Vector3.new(0,  y, 0),   "Common",    "Axolotl")
	createInteractiveEgg(Vector3.new(10, y, 0),   "Rare",      "Axolotl")
	createInteractiveEgg(Vector3.new(20, y, 0),   "Epic",      "Axolotl")
	createInteractiveEgg(Vector3.new(30, y, 0),   "Legendary", "Axolotl")

	print("✅ VFX Pet Egg Server loaded.")
	print("   _G.CreateInteractiveEgg(Vector3.new(x,y,z), 'Epic', 'Axolotl')")
	print("   _G.CreateInteractiveCrystal(Vector3.new(x,y,z), 'Epic', 'SomeName')")
end)
