-- career_motorsport.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- Motorsports Career Arc – ultra-detailed BitLife-style storyline.
-- Focuses on a single AAA path so we can iterate career-by-career.
-- Integrates with TraitSystem via choice.traits payloads.
-- ═══════════════════════════════════════════════════════════════════════════════

local TraitSystem = nil
pcall(function()
	local lifeEventsFolder = script.Parent
	if lifeEventsFolder and lifeEventsFolder.Parent and lifeEventsFolder.Parent:FindFirstChild("TraitSystem") then
		TraitSystem = require(lifeEventsFolder.Parent:FindFirstChild("TraitSystem"))
	elseif lifeEventsFolder and lifeEventsFolder:FindFirstChild("TraitSystem") then
		TraitSystem = require(lifeEventsFolder:FindFirstChild("TraitSystem"))
	elseif lifeEventsFolder and lifeEventsFolder.Parent and lifeEventsFolder.Parent.Parent then
		local replicated = lifeEventsFolder.Parent
		if replicated and replicated:FindFirstChild("TraitSystem") then
			TraitSystem = require(replicated:FindFirstChild("TraitSystem"))
		end
	end
end)

local function hasTrait(state, traitId)
	if TraitSystem and TraitSystem.HasTrait then
		return TraitSystem.HasTrait(state, traitId)
	end
	for _, trait in ipairs(state.Traits or {}) do
		if trait == traitId then
			return true
		end
	end
	return false
end

local events = {}

-- Helper to make sure effects tables exist
local function flagSet(...)
	return { set = {...} }
end

-- ═══════════════════════════════════════════════════════════════
-- ORIGIN EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_engine_lullaby",
	emoji = "🏎️",
	title = "Engine Lullaby",
	category = "motorsport",
	tags = {"career", "motorsport", "origin", "childhood"},
	weight = 18,
	cooldownYears = 99,
	oneTime = true,
	milestone = false,
	chainId = "motorsport_life",
	chainStep = 1,
	conditions = {
		minAge = 0,
		maxAge = 3,
		blockedFlags = {"motorsport_origin_locked"},
	},
	text = "Your parents park your stroller against the kart-track fence. Every throttle blip rattles your ribs. Babies cry; you lean toward the noise.",
	choices = {
		{
			id = "imprint_speed",
			text = "Reach toward the roar.",
			resultText = "The vibrations become comfort. Engines feel like lullabies.",
			effects = { Happiness = 2 },
			flags = flagSet("motorsport_speed_imprint"),
			traits = { add = {"RACER"}, resolve = true },
		},
		{
			id = "overstimulated",
			text = "Cover my ears. Too intense.",
			resultText = "You scream until someone wheels you away. Engines = overwhelm for now.",
			effects = { Happiness = -2 },
			flags = flagSet("motorsport_origin_locked"),
			traits = { remove = {"RACER"} },
		},
	},
})

table.insert(events, {
	id = "motorsport_tablet_teardown",
	emoji = "📱",
	title = "Tablet Surgery",
	category = "motorsport",
	tags = {"tech", "motorsport", "origin"},
	weight = 14,
	cooldownYears = 99,
	oneTime = true,
	chainId = "motorsport_life",
	chainStep = 2,
	conditions = {
		minAge = 3,
		maxAge = 5,
		requiredAnyFlags = {"motorsport_speed_imprint"},
	},
	text = "Someone hands you a tablet to keep you calm. Five minutes later it's in pieces because you needed to see \"how the colors leak.\"",
	choices = {
		{
			id = "reverse_engineer",
			text = "Sort the pieces, figure it out.",
			resultText = "Screws organized, ribbon cable noted, casing aligned. Your brain catalogues systems.",
			effects = { Smarts = 2 },
			flags = flagSet("motorsport_systems_brain"),
			traits = { add = {"TECHYKID"}, resolve = true },
		},
		{
			id = "panic",
			text = "Panic because it's broken.",
			resultText = "You sob until someone fixes it. Curiosity takes a hit.",
			effects = { Happiness = -1 },
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- KARTING + EARLY OBSESSION
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_scrapyard_kart",
	emoji = "🛠️",
	title = "Scrapyard Kart Build",
	category = "motorsport",
	tags = {"career", "motorsport", "childhood", "build"},
	weight = 12,
	oneTime = true,
	chainId = "motorsport_life",
	chainStep = 3,
	conditions = {
		minAge = 6,
		maxAge = 9,
		requiredAllFlags = {"motorsport_systems_brain"},
	},
	getDynamicData = function()
		local donors = {"leaf blower", "old lawn mower", "broken golf cart"}
		return { donor = donors[math.random(#donors)] }
	end,
	text = "You raid the junkyard for parts and turn a %donor% engine into something that looks suspiciously like a kart frame.",
	choices = {
		{
			id = "make_it_sing",
			text = "Spend every night perfecting it.",
			resultText = "Neighbors complain about revs at midnight. You map torque in your head.",
			effects = { Intelligence = 2, Creativity = 2 },
			flags = flagSet("motorsport_kart_builder"),
			traits = { add = {"MECHANICAPPT"}, resolve = true },
		},
		{
			id = "sell_parts",
			text = "Flip the parts for cash instead.",
			resultText = "You learn negotiation. The dream pauses but hustler instincts grow.",
			effects = { Money = 200 },
			flags = flagSet("motorsport_hustle_mode"),
		},
	},
})

table.insert(events, {
	id = "motorsport_local_heat",
	emoji = "🔥",
	title = "Local Kart Heats",
	category = "motorsport",
	tags = {"career", "motorsport", "childhood", "competition"},
	weight = 10,
	cooldownYears = 2,
	conditions = {
		minAge = 8,
		maxAge = 12,
		requiredAnyFlags = {"motorsport_kart_builder"},
	},
	getDynamicData = function()
		local rivals = {"Maya", "Tyler", "Jax", "Neve"}
		return { rival = rivals[math.random(#rivals)] }
	end,
	text = "Kids from three towns show up. %rival% punts you in practice, so you spend the night re-gearing.",
	choices = {
		{
			id = "dominate",
			text = "Send it. Win by a lap.",
			resultText = "You lap half the field. Adults whisper \"prodigy.\"",
			effects = { Happiness = 5, Fame = 2 },
			flags = flagSet("motorsport_local_champion", "racing_interest"),
			careerXP = 10,
			traits = { add = {"THRILLSEEKER"}, resolve = true },
		},
		{
			id = "study_data",
			text = "Lose but download telemetry + lessons.",
			resultText = "You chart every delta. Losing becomes fuel.",
			effects = { Smarts = 3 },
			flags = flagSet("motorsport_data_logger"),
			traits = { add = {"DATA_STRATEGIST"} },
		},
	},
})

table.insert(events, {
	id = "motorsport_family_finance_crunch",
	emoji = "💸",
	title = "Family Finance Ultimatum",
	category = "motorsport",
	tags = {"motorsport", "family", "pressure"},
	weight = 11,
	oneTime = false,
	cooldownYears = 3,
	conditions = {
		minAge = 10,
		maxAge = 15,
		requiredAnyFlags = {"motorsport_local_champion", "motorsport_data_logger"},
	},
	text = "Your parents spread overdue bills on the kitchen table. Racing is burning every savings account. Either you find funding or the dream pauses.",
	choices = {
		{
			id = "pitch_sponsors",
			text = "Design a deck, chase sponsors.",
			resultText = "You cold-email local shops with ROI charts and sim footage.",
			effects = { Charisma = 2, Money = 1000 },
			flags = flagSet("motorsport_pitch_ready"),
			traits = { add = {"MEDIA_DARLING"} },
		},
		{
			id = "take_side_jobs",
			text = "Fix neighbors' scooters, mow lawns, grind.",
			resultText = "You smell like gas and grass but entry fees get paid.",
			effects = { Money = 500, Fitness = 2 },
			flags = flagSet("motorsport_grit_hustle"),
		},
		{
			id = "accept_pause",
			text = "Pause racing, focus on school for a bit.",
			resultText = "Painful, but you build patience. The obsession simmers quietly.",
			effects = { Smarts = 2, Happiness = -3 },
			flags = flagSet("motorsport_forced_hiatus"),
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- ACADEMY + CAREER ENTRY
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_academy_scout",
	emoji = "📞",
	title = "Driver Academy Call",
	category = "motorsport",
	tags = {"career", "motorsport", "teen"},
	weight = 9,
	oneTime = true,
	chainId = "motorsport_life",
	chainStep = 4,
	conditions = {
		minAge = 12,
		maxAge = 16,
		requiredAnyFlags = {"motorsport_pitch_ready", "motorsport_grit_hustle"},
	},
	getDynamicData = function()
		local academies = {"Phoenix Performance Program", "NovaWorks Academy", "Stormline Factory School"}
		return { academy = academies[math.random(#academies)] }
	end,
	text = "%academy% offers a seat if you relocate and sign their morality clause. It's the golden ticket... with strings.",
	choices = {
		{
			id = "sign_contract",
			text = "Sign. You're all-in.",
			resultText = "Goodbye hometown. Hello telemetry briefings at 6 AM.",
			effects = { Happiness = 4 },
			flags = flagSet("motorsport_academy_signed", "motorsport_all_in"),
			traits = { add = {"MENTOR_DRIVER"} },
		},
		{
			id = "negotiate",
			text = "Negotiate for creative freedom.",
			resultText = "You demand rights to your brand + sim channel. They grudgingly agree.",
			effects = { Charisma = 3 },
			flags = flagSet("motorsport_academy_signed", "motorsport_brand_control"),
		},
		{
			id = "decline",
			text = "Decline; you smell exploitation.",
			resultText = "You walk away. Maybe street leagues and viral runs instead.",
			effects = { Happiness = -2 },
			flags = flagSet("motorsport_underground_path"),
		},
	},
})

table.insert(events, {
	id = "motorsport_sim_lab",
	emoji = "🖥️",
	title = "Telemetry Sim Lab",
	category = "motorsport",
	tags = {"motorsport", "tech"},
	weight = 10,
	cooldownYears = 2,
	conditions = {
		minAge = 13,
		maxAge = 18,
		requiredAnyFlags = {"motorsport_academy_signed", "motorsport_underground_path"},
	},
	text = "You stay after curfew to run ghost laps against pro telemetry. Engineers either love you... or think you're insubordinate.",
	choices = {
		{
			id = "ghost_master",
			text = "Beat the ghost time with surgical precision.",
			resultText = "Engineers clap. You log every micro adjustment.",
			effects = { Smarts = 2, TechSkill = 2 },
			flags = flagSet("motorsport_sim_beast"),
			traits = { add = {"DATA_STRATEGIST"}, resolve = true },
		},
		{
			id = "burn_down",
			text = "Blow engine temps to see the limit.",
			resultText = "You cook a power unit. Valuable data... expensive invoice.",
			effects = { Money = -2000, RiskAffinity = 1 },
			flags = flagSet("motorsport_rebel_engineer"),
			traits = { add = {"THRILLSEEKER"} },
		},
	},
})

table.insert(events, {
	id = "motorsport_factory_contract",
	emoji = "📝",
	title = "Factory Development Contract",
	category = "motorsport",
	tags = {"career", "motorsport", "contract"},
	weight = 8,
	oneTime = true,
	conditions = {
		minAge = 16,
		maxAge = 20,
		requiredAllFlags = {"motorsport_academy_signed"},
	},
	getDynamicData = function()
		local teams = {"Axiom Velocity", "Helios Works", "Atlas Apex"}
		return {
			team = teams[math.random(#teams)],
			retainer = math.random(25, 60) * 1000,
		}
	end,
	text = "%team% slides over a development contract. Retainer: $%retainer%. Required deliverable: polish their simulator + be ready for emergency call-ups.",
	choices = {
		{
			id = "sign_dev",
			text = "Sign it. Pay the bills.",
			resultText = "You become the driver they call at 2 AM to solve setup nightmares.",
			effects = { Money = 5000, Happiness = 4 },
			flags = flagSet("motorsport_factory_dev"),
			startCareer = "motorsport_icon",
			careerXP = 30,
		},
		{
			id = "demand_race_clause",
			text = "Add a guaranteed race seat clause.",
			resultText = "Negotiations get tense, but you secure a clause for real seat time after two podiums.",
			effects = { Charisma = 2, Money = 3000 },
			flags = flagSet("motorsport_factory_dev", "motorsport_clause_race_seat"),
			startCareer = "motorsport_icon",
			careerXP = 35,
			careerReputation = 10,
		},
	},
})

table.insert(events, {
	id = "motorsport_branch_selection",
	emoji = "🛣️",
	title = "Discipline Declaration",
	category = "motorsport",
	tags = {"career", "motorsport", "branch"},
	weight = 6,
	oneTime = true,
	conditions = {
		minAge = 17,
		maxAge = 22,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 1,
	},
	text = "You're asked to declare a focus: precision single-seaters, brutal endurance, or outlaw street icon status.",
	choices = {
		{
			id = "single_seater",
			text = "Single-Seater ladder (F4 → F3 → F1).",
			resultText = "You lock in physics-perfect apexes and political sponsor dinners.",
			flags = flagSet("motorsport_single_seater"),
			careerBranch = "single_seater",
			careerXP = 15,
		},
		{
			id = "endurance",
			text = "Endurance / Hypercar. Night stints, prototypes.",
			resultText = "You learn to drive in hallucinations and team-think.",
			flags = flagSet("motorsport_endurance"),
			careerBranch = "endurance",
			careerXP = 15,
		},
		{
			id = "street_icon",
			text = "Street icon & viral outlaw scene.",
			resultText = "You weaponize media, neon nights, and risky brand deals.",
			flags = flagSet("motorsport_street_icon"),
			careerBranch = "street_icon",
			careerXP = 15,
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- BRANCH-SPECIFIC EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_single_seater_f2_showdown",
	emoji = "⚙️",
	title = "Junior Formula Showdown",
	category = "motorsport",
	tags = {"career", "motorsport", "single_seater"},
	weight = 7,
	cooldownYears = 2,
	conditions = {
		minAge = 18,
		maxAge = 26,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 2,
		requiredCareerBranch = "single_seater",
		custom = function(state)
			return hasTrait(state, "RACER")
		end,
	},
	text = "The car is twitchy, aero sensitivity brutal. Engineers want safe points. Sponsors want fireworks.",
	choices = {
		{
			id = "safe_points",
			text = "Bring it home for points. Data-trend your way up.",
			resultText = "Consistent podiums. Head hunters notice maturity.",
			effects = { Happiness = 3 },
			flags = flagSet("motorsport_points_machine"),
			careerXP = 25,
			careerReputation = 15,
		},
		{
			id = "send_it_pole",
			text = "Trim downforce and hunt pole.",
			resultText = "Either P1 or carbon fiber confetti. Today? P1.",
			effects = { Fame = 5, Money = 15000 },
			flags = flagSet("motorsport_glory_hunter"),
			careerXP = 35,
			traits = { add = {"THRILLSEEKER"} },
		},
	},
})

table.insert(events, {
	id = "motorsport_endurance_night_stint",
	emoji = "🌙",
	title = "24h Night Stint",
	category = "motorsport",
	tags = {"career", "motorsport", "endurance"},
	weight = 7,
	cooldownYears = 3,
	conditions = {
		minAge = 19,
		maxAge = 32,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 3,
		requiredCareerBranch = "endurance",
	},
	text = "3 AM, rain, triple stint. Teammate pukes from exhaustion. It's you, darkness, and the rhythm of traffic.",
	choices = {
		{
			id = "zen_mode",
			text = "Zone out, conserve tires, keep data perfect.",
			resultText = "Engineers call it \"robotic perfection.\"",
			effects = { Stamina = 3, Happiness = 4 },
			flags = flagSet("motorsport_metronome"),
			careerXP = 30,
			traits = { add = {"DATA_STRATEGIST"} },
		},
		{
			id = "heroics",
			text = "Push double stints, claw back laps.",
			resultText = "You pass three cars in fog. Viral onboard hits 5M views.",
			effects = { Fame = 7 },
			flags = flagSet("motorsport_night_hero"),
			careerXP = 35,
		},
	},
})

table.insert(events, {
	id = "motorsport_streeticon_viral",
	emoji = "📹",
	title = "Viral Street Run",
	category = "motorsport",
	tags = {"career", "motorsport", "street_icon"},
	weight = 8,
	cooldownYears = 2,
	conditions = {
		minAge = 18,
		maxAge = 30,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 2,
		requiredCareerBranch = "street_icon",
	},
	text = "You shut down a city block for a midnight run filmed by drones. Police scanners chirp.",
	choices = {
		{
			id = "control_the_narrative",
			text = "Pre-produce cinematics, sprinkle safety PSA.",
			resultText = "Brands respect the polish. You keep outlaw cred without arrests.",
			effects = { Money = 40000, Fame = 6 },
			flags = flagSet("motorsport_brand_safe_outlaw"),
			traits = { add = {"MEDIA_DARLING"} },
		},
		{
			id = "pure_chaos",
			text = "Live-stream the chaos raw.",
			resultText = "20M views overnight. Cops show up at dawn.",
			effects = { Fame = 10, Karma = -3 },
			flags = flagSet("motorsport_heat_level"),
			careerReputation = -10,
			traits = { add = {"THRILLSEEKER"} },
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- UNIVERSAL CAREER EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_crash_flashpoint",
	emoji = "💥",
	title = "Carbon Flashpoint",
	category = "motorsport",
	tags = {"career", "motorsport", "injury", "vehicle_crash", "high_impact"},
	weight = 6,
	cooldownYears = 4,
	conditions = {
		minAge = 18,
		maxAge = 35,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 2,
	},
	getDynamicData = function()
		local corners = {"Eau Rouge", "130R", "Parabolica", "The Corkscrew"}
		return { corner = corners[math.random(#corners)] }
	end,
	text = "At %corner%, suspension snaps. You go airborne, see sparks, think about funerals, and land upside down.",
	choices = {
		{
			id = "fight_back",
			text = "Rehab + come back louder.",
			resultText = "You livestream physio, inspire millions.",
			effects = { Health = -15, Happiness = -3 },
			flags = flagSet("motorsport_crash_survivor"),
			traits = { add = {"MENTOR_DRIVER"}, resolve = true },
		},
		{
			id = "spiral",
			text = "Withdraw, question everything.",
			resultText = "Nightmares, panic, but also introspection.",
			effects = { Happiness = -8 },
			flags = flagSet("motorsport_crash_spiral"),
			traits = { add = {"ANXIOUS"} },
		},
	},
})

table.insert(events, {
	id = "motorsport_data_brain",
	emoji = "📊",
	title = "Telemetry Coup",
	category = "motorsport",
	tags = {"career", "motorsport", "tech"},
	weight = 7,
	cooldownYears = 2,
	conditions = {
		minAge = 19,
		maxAge = 32,
		requiredCareerId = "motorsport_icon",
		requiredAnyFlags = {"motorsport_sim_beast", "motorsport_data_logger"},
	},
	text = "Engineers can't solve tire deg. You sneak into the truck, rewrite the model, and find a hidden camber window.",
	choices = {
		{
			id = "share_with_team",
			text = "Loop in engineers, be the hero.",
			resultText = "They promote you to development lead + star driver.",
			effects = { Happiness = 4 },
			flags = flagSet("motorsport_team_brain"),
			careerXP = 40,
			traits = { add = {"DATA_STRATEGIST"} },
		},
		{
			id = "keep_secret",
			text = "Use it yourself, drop jaws in race trim.",
			resultText = "You gap the field. Teammates question why they burn rubber.",
			effects = { Fame = 4 },
			flags = flagSet("motorsport_secret_edge"),
			careerXP = 25,
		},
	},
})

table.insert(events, {
	id = "motorsport_world_final",
	emoji = "🏆",
	title = "World Championship Decider",
	category = "motorsport",
	tags = {"career", "motorsport", "milestone"},
	weight = 5,
	cooldownYears = 4,
	milestone = false,
	conditions = {
		minAge = 24,
		maxAge = 35,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 5,
		custom = function(state)
			return hasTrait(state, "RACER") or hasTrait(state, "MENTOR_DRIVER")
		end,
	},
	text = "Media storms, politics, and the whole planet refreshing lap charts. Your championship depends on this final stint.",
	choices = {
		{
			id = "ice_in_veins",
			text = "Drive like data. Perfect, calm, lethal.",
			resultText = "You clinch the title with surgical discipline.",
			effects = { Happiness = 10, Money = 500000 },
			flags = flagSet("motorsport_world_champion", "racing_legend"),
			careerXP = 60,
			careerReputation = 40,
			traits = { add = {"MENTOR_DRIVER"} },
		},
		{
			id = "showman",
			text = "Drift across the line, make cinema.",
			resultText = "Commentators lose their minds. Sponsors double your value.",
			effects = { Fame = 12, Money = 300000 },
			flags = flagSet("motorsport_legendary_finish"),
			careerXP = 55,
			traits = { add = {"MEDIA_DARLING"}, resolve = true },
		},
	},
})

table.insert(events, {
	id = "motorsport_mentor_transition",
	emoji = "🤝",
	title = "Mentor or Maverick?",
	category = "motorsport",
	tags = {"career", "motorsport", "late_career"},
	weight = 7,
	cooldownYears = 3,
	conditions = {
		minAge = 30,
		maxAge = 45,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 5,
	},
	text = "Teams beg you to mentor juniors. Streaming platforms want docuseries. Fans want you forever.",
	choices = {
		{
			id = "mentor",
			text = "Become the mentor you needed.",
			resultText = "You build a driver academy pipeline and change the culture.",
			effects = { Happiness = 6, Karma = 4 },
			flags = flagSet("motorsport_founder", "motorsport_coach_mode"),
			careerXP = 30,
			traits = { add = {"MENTOR_DRIVER"} },
		},
		{
			id = "double_down",
			text = "Stay selfish, chase one more triple crown.",
			resultText = "You alienate some execs but fans love the defiance.",
			effects = { Fame = 5 },
			flags = flagSet("motorsport_one_more_run"),
		},
	},
})

table.insert(events, {
	id = "motorsport_exit_blueprint",
	emoji = "🔧",
	title = "Exit Blueprint",
	category = "motorsport",
	tags = {"career", "motorsport", "retirement"},
	weight = 9,
	oneTime = true,
	conditions = {
		minAge = 32,
		maxAge = 50,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 4,
	},
	text = "Body aches, sponsors whisper succession, your legacy feels fragile. How do you leave?",
	choices = {
		{
			id = "retire_on_top",
			text = "Announce retirement, build a motorsport empire.",
			resultText = "You launch a talent incubator, investment fund, and media house.",
			effects = { Happiness = 8 },
			flags = flagSet("motorsport_retired_icon"),
			quitCareer = true,
			traits = { add = {"MENTOR_DRIVER"} },
		},
		{
			id = "fade_away",
			text = "Keep a low profile, maybe GT racing on weekends.",
			resultText = "No press tour, just you and some quiet lap times.",
			effects = { Happiness = 4 },
			flags = flagSet("motorsport_lowkey_exit"),
			quitCareer = true,
		},
	},
})

return { events = events }
