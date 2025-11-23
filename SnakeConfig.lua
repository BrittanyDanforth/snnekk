-- Global SnakeConfig for AI snakes (NOT used by player snakes!)
-- Player snake config is in SnakeSystemIntegration's DEFAULT_CONFIG
-- This is a ModuleScript inside ReplicatedStorage

return {
	-- SNAKE DIMENSIONS (Synced to Player System V9.5)
	HeadSize = Vector3.new(3.675, 3.675, 3.675), -- 3.5 * 1.05 (Matches player)
	SegmentSize = Vector3.new(3.5, 3.5, 3.5),    -- 3.5 (Matches player)
	SegmentSpacing = 1.75,                       -- 3.5 * 0.5 (Matches player)
	SegmentGap = 3.0, -- For legacy/other systems

	-- BODY SETTINGS (FOR AI ONLY - Players use SnakeSystemIntegration)
	InitialLength = 15,      -- REDUCED from 85 to 15 to match player spawn size
	MaxSegments = 2450,

	-- ENHANCED COLORS (Default skin - better green gradient)
	HeadColor = Color3.fromRGB(76, 217, 100),
	BodyColors = {
		Color3.fromRGB(60, 180, 80),
		Color3.fromRGB(80, 200, 100),
		Color3.fromRGB(100, 220, 120),
		Color3.fromRGB(80, 200, 100),
		Color3.fromRGB(60, 180, 80),
	},
	SegmentColor = Color3.fromRGB(80, 200, 100),

	-- MOVEMENT SETTINGS
	FollowSpeed = 0.95,
	BoostFollowSpeed = 0.99,
	UpdateRate = 1,
	MinDistance = 0.02,
	PathSmoothness = 0.9,

	-- MATERIALS
	HeadMaterial = Enum.Material.ForceField,
	BodyMaterial = Enum.Material.Neon,

	-- VISUAL ENHANCEMENTS
	GlowIntensity = 1.5,
	GlowRange = 4,
	LODDistance = 120,

	-- GAMEPLAY SETTINGS
	OrbValue = 5,
	BoostDrainRate = 3,

	-- DEATH ORB VALUES
	DeathOrbReturn = {
		small = 0.30,
		medium = 0.25,
		large = 0.20,
		huge = 0.15,
		cap = 150
	},

	-- AI SNAKE SPECIFIC SETTINGS
	AI = {
		-- Movement
		BaseSpeed = 10,
		BoostSpeed = 24,
		TurnSpeed = 1.8,

		-- Visual adjustments
		BeamWidthMultiplier = 0.7,  -- Thinner beams for AI to avoid "fat" look
		GlowIntensity = 1.8,

		-- Behavior settings
		OrbSeekRange = 80,
		ThreatDetectionRange = 60,
		BoostChance = 0.15,

		-- Growth settings
		MaxLength = 2000,
	}
}