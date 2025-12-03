-- career_motorsport.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- GOD-TIER LIFE TRACK: From crib-side engine lullabies to legendary motorsport icon.
-- All life events live here so we can iterate career-by-career with AAA depth.
-- Every event is trait-aware via TraitSystem choice payloads.
-- ═══════════════════════════════════════════════════════════════════════════════

local TraitSystem = nil
pcall(function()
	local folder = script.Parent
	if folder and folder.Parent and folder.Parent:FindFirstChild("TraitSystem") then
		TraitSystem = require(folder.Parent:FindFirstChild("TraitSystem"))
	elseif folder and folder:FindFirstChild("TraitSystem") then
		TraitSystem = require(folder:FindFirstChild("TraitSystem"))
	end
end)

local events = {}

local function flagSet(...)
	return { set = {...} }
end

local function traitPayload(payload)
	return payload -- simple helper for readability
end

-- Helper function to check if player has a trait
local function hasTrait(state, traitId)
	if not state or not TraitSystem then return false end
	local traits = state.Traits or {}
	if type(traits) == "table" then
		-- Check if it's an array
		if #traits > 0 then
			for _, trait in ipairs(traits) do
				if trait == traitId then return true end
			end
		end
		-- Check if it's a dictionary
		if traits[traitId] then return true end
	end
	return false
end

-- ═══════════════════════════════════════════════════════════════
-- BABY / TODDLER ERA (AGES 0-3)
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_engine_lullaby",
	emoji = "🏎️",
	title = "Engine Lullaby",
	category = "motorsport",
	tags = {"motorsport", "origin", "baby"},
	weight = 25,
	oneTime = true,
	conditions = {
		minAge = 0,
		maxAge = 1,
	},
	text = "Your parents park your stroller on the edge of a kart track. Every throttle blip rattles your ribs. Other infants cry— you lean toward the noise.",
	choices = {
		{
			id = "reach_for_roar",
			text = "Reach toward the sound; imprint on speed.",
			resultText = "The revs become comfort. Engines enter your nervous system.",
			flags = flagSet("motorsport_speed_imprint"),
			traits = traitPayload({ add = {"RACER"}, resolve = true }),
			effects = { Happiness = 2 },
		},
		{
			id = "sensory_overload",
			text = "Cover your ears; fear the chaos.",
			resultText = "You associate engines with panic. It'll take work to undo.",
			flags = flagSet("motorsport_engines_scary"),
			traits = traitPayload({ remove = {"RACER"} }),
			effects = { Happiness = -2 },
		},
	},
})

table.insert(events, {
	id = "motorsport_toddler_escape",
	emoji = "🍼",
	title = "Toddler Escape Velocity",
	category = "motorsport",
	tags = {"motorsport", "origin"},
	weight = 18,
	oneTime = true,
	conditions = {
		minAge = 2,
		maxAge = 3,
		blockedFlags = {"motorsport_escape_artist"},
	},
	text = "You sprint out of daycare, chasing the UPS truck that sounded like the track. Teachers panic; you feel unstoppable.",
	choices = {
		{
			id = "caught_but_grinning",
			text = "Laugh when they grab you.",
			resultText = "Rules mean nothing if the sound is right.",
			flags = flagSet("motorsport_escape_artist"),
			traits = traitPayload({ add = {"THRILLSEEKER"}, resolve = true }),
			effects = { Happiness = 3 },
		},
		{
			id = "apologize",
			text = "Apologize; promise to stay put.",
			resultText = "You internalize restraint... for now.",
			flags = flagSet("motorsport_rule_memory"),
			effects = { Happiness = -1 },
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- CHILDHOOD (AGES 4-12)
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_scrapyard_laboratory",
	emoji = "🛠️",
	title = "Scrapyard Laboratory",
	category = "motorsport",
	tags = {"motorsport", "build"},
	weight = 16,
	conditions = {
		minAge = 5,
		maxAge = 8,
		-- Can fire without flags, but boosted if you have early interest
		custom = function(state)
			-- Prefer players with early motorsport interest, but allow anyone
			local flags = state.Flags or {}
			if flags.motorsport_speed_imprint or flags.motorsport_escape_artist or flags.motorsport_neighborhood_champ or flags.motorsport_bike_modder then
				return true
			end
			-- Still allow it, just lower chance
			return math.random() < 0.7
		end,
	},
	getDynamicData = function()
		local donors = {"leaf blower", "old pressure washer", "rusted lawn mower"}
		return { donor = donors[math.random(#donors)] }
	end,
	text = "You raid a scrapyard, rip a %donor% engine apart, and sketch a chassis on notebook paper.",
	choices = {
		{
			id = "meticulous_build",
			text = "Label every bolt, rebuild with care.",
			resultText = "You fall asleep with grease on your hands and schematics in your dreams.",
			flags = flagSet("motorsport_kart_builder"),
			traits = traitPayload({ add = {"MECHANICAPPT"}, resolve = true }),
			effects = { Smarts = 2, Creativity = 2 },
		},
		{
			id = "flip_parts",
			text = "Sell the pieces for quick cash.",
			resultText = "You learn negotiation and hustle— entry fees financed.",
			flags = flagSet("motorsport_hustler"),
			effects = { Money = 150 },
		},
	},
})

table.insert(events, {
	id = "motorsport_local_heat",
	emoji = "🔥",
	title = "Local Kart Heats",
	category = "motorsport",
	tags = {"motorsport", "competition"},
	weight = 14,
	cooldownYears = 2,
	conditions = {
		minAge = 8,
		maxAge = 12,
		-- More flexible - allow if you have any motorsport interest
		custom = function(state)
			local flags = state.Flags or {}
			if flags.motorsport_kart_builder or flags.motorsport_hustler or flags.motorsport_neighborhood_champ or flags.motorsport_bike_modder or flags.motorsport_first_kart then
				return true
			end
			-- Still allow, just lower chance
			return math.random() < 0.6
		end,
	},
	getDynamicData = function()
		local rivals = {"Maya", "Tyler", "Jax", "Neve", "Alonzo"}
		return { rival = rivals[math.random(#rivals)] }
	end,
	text = "Regional kids show up with factory support. %rival% punts you in practice. Do you retaliate with speed or data?",
	choices = {
		{
			id = "send_it",
			text = "Send it. Win by a lap.",
			resultText = "You put the fear of God into every parent on the fence.",
			flags = flagSet("motorsport_local_champion"),
			traits = traitPayload({ add = {"THRILLSEEKER"} }),
			careerXP = 10,
			effects = { Fame = 2, Happiness = 4 },
		},
		{
			id = "log_telemetry",
			text = "Lose now, download their lines later.",
			resultText = "You build spreadsheets before bedtime. Victory delayed, not denied.",
			flags = flagSet("motorsport_data_logger"),
			traits = traitPayload({ add = {"DATA_STRATEGIST"} }),
			effects = { Smarts = 2 },
		},
	},
})

table.insert(events, {
	id = "motorsport_family_finances",
	emoji = "💸",
	title = "Family Ultimatum",
	category = "motorsport",
	tags = {"motorsport", "family"},
	weight = 12,
	cooldownYears = 3,
	conditions = {
		minAge = 10,
		maxAge = 14,
		requiredAnyFlags = {"motorsport_local_champion", "motorsport_data_logger"},
	},
	text = "Your family spreads overdue bills on the table. Racing is burning every savings account. You either find funding or the dream pauses.",
	choices = {
		{
			id = "pitch_sponsors",
			text = "Design a sponsor deck; spam emails.",
			resultText = "You pitch ROI with raw telemetry. A local shop takes a gamble.",
			flags = flagSet("motorsport_pitch_ready"),
			traits = traitPayload({ add = {"MEDIA_DARLING"} }),
			effects = { Money = 500, Charisma = 2 },
		},
		{
			id = "grind_jobs",
			text = "Fix scooters, mow lawns, sell merch.",
			resultText = "You smell like gas and grass but you pay the entry fee.",
			flags = flagSet("motorsport_grind_mode"),
			effects = { Fitness = 1, Money = 250 },
		},
		{
			id = "hiatus",
			text = "Pause racing; internalize hunger.",
			resultText = "You stew in your room watching onboard footage on repeat.",
			flags = flagSet("motorsport_forced_hiatus"),
			effects = { Happiness = -3, Smarts = 1 },
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- TEEN ARC (AGES 13-17)
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_sim_stream",
	emoji = "🎥",
	title = "Sim Stream Breakout",
	category = "motorsport",
	tags = {"motorsport", "media"},
	weight = 11,
	cooldownYears = 2,
	conditions = {
		minAge = 13,
		maxAge = 17,
		requiredAnyFlags = {"motorsport_pitch_ready", "motorsport_forced_hiatus"},
	},
	text = "You stream late-night sim sessions. Chat spams donations when you explain aero balance like bedtime stories.",
	choices = {
		{
			id = "educator",
			text = "Teach the chat; build reputation as brainiac.",
			resultText = "Engineers start DMing you for setup breakdowns.",
			flags = flagSet("motorsport_sim_professor"),
			traits = traitPayload({ add = {"DATA_STRATEGIST"} }),
			effects = { Fame = 2, Smarts = 2 },
		},
		{
			id = "chaos_stream",
			text = "Run troll lobbies; become viral menace.",
			resultText = "Clout skyrockets. Traditional teams roll their eyes.",
			flags = flagSet("motorsport_stream_outlaw"),
			traits = traitPayload({ add = {"MEDIA_DARLING"} }),
			effects = { Fame = 4, Karma = -2 },
		},
	},
})

table.insert(events, {
	id = "motorsport_academy_contract",
	emoji = "📞",
	title = "Academy Contract",
	category = "motorsport",
	tags = {"motorsport", "academy"},
	weight = 9,
	oneTime = true,
	conditions = {
		minAge = 15,
		maxAge = 18,
		-- More flexible - allow if you have any motorsport interest
		custom = function(state)
			local flags = state.Flags or {}
			if flags.motorsport_local_champion or flags.motorsport_sim_professor or flags.motorsport_stream_outlaw or flags.motorsport_first_kart or flags.motorsport_regional_podium or flags.motorsport_neighborhood_champ then
				return true
			end
			-- Still allow, just lower chance
			return math.random() < 0.4
		end,
		blockedFlags = {"motorsport_academy_signed"},
	},
	getDynamicData = function()
		local programs = {"Axiom Velocity Junior", "Helios Works Academy", "NovaWorks Satellite"}
		return { academy = programs[math.random(#programs)] }
	end,
	text = "%academy% offers a seat plus a morality clause. It's the golden ticket— with strings.",
	choices = {
		{
			id = "sign_instantly",
			text = "Sign. All-in.",
			resultText = "You move across the world and start 5 AM telemetry briefings.",
			flags = flagSet("motorsport_academy_signed", "motorsport_all_in"),
			startCareer = "motorsport_icon",
			careerXP = 20,
		},
		{
			id = "negotiate_terms",
			text = "Protect creative freedom in the contract.",
			resultText = "They grumble, but you retain streaming + media rights.",
			flags = flagSet("motorsport_academy_signed", "motorsport_brand_control"),
			startCareer = "motorsport_icon",
			careerXP = 25,
			careerReputation = 5,
		},
		{
			id = "decline_offer",
			text = "Decline— you'd rather build underground clout.",
			resultText = "You double down on outlaw roots. Sponsors raise eyebrows.",
			flags = flagSet("motorsport_underground_path"),
			traits = traitPayload({ add = {"THRILLSEEKER"} }),
			effects = { Happiness = -1, Fame = 3 },
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- EARLY CAREER (AGES 18-24)
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_factory_sim_lab",
	emoji = "🖥️",
	title = "Factory Sim Lab",
	category = "motorsport",
	tags = {"motorsport", "tech"},
	weight = 10,
	cooldownYears = 2,
	conditions = {
		minAge = 18,
		maxAge = 24,
		requiredAnyFlags = {"motorsport_academy_signed", "motorsport_underground_path"},
	},
	text = "You stay after curfew to beat the pro driver's ghost. Engineers either love your obsession or call it insubordination.",
	choices = {
		{
			id = "ghost_master",
			text = "Beat the ghost surgically.",
			resultText = "Engineers nickname you 'metronome.'",
			flags = flagSet("motorsport_sim_beast"),
			traits = traitPayload({ add = {"DATA_STRATEGIST"}, resolve = true }),
			effects = { Smarts = 2, TechSkill = 2 },
		},
		{
			id = "cook_engine",
			text = "Overstress the sim car to find failure modes.",
			resultText = "You cook a power unit but discover hidden margins.",
			flags = flagSet("motorsport_rebel_engineer"),
			traits = traitPayload({ add = {"THRILLSEEKER"} }),
			effects = { Money = -1000, RiskAffinity = 1 },
		},
	},
})

table.insert(events, {
	id = "motorsport_factory_contract",
	emoji = "📝",
	title = "Factory Development Contract",
	category = "motorsport",
	tags = {"motorsport", "contract"},
	weight = 8,
	oneTime = true,
	conditions = {
		minAge = 18,
		maxAge = 24,
		requiredAnyFlags = {"motorsport_academy_signed"},
		blockedFlags = {"motorsport_factory_dev"},
	},
	getDynamicData = function()
		local teams = {"Helios Factory", "Atlas Apex", "Stormline Works"}
		return {
			team = teams[math.random(#teams)],
			retainer = math.random(35, 80) * 1000,
		}
	end,
	text = "%team% offers a development retainer worth $%retainer%. Deliverables: fix their simulator, be ready for emergency call-ups.",
	choices = {
		{
			id = "sign_dev",
			text = "Sign the dev contract.",
			resultText = "You become the 2 AM call when setup data goes haywire.",
			flags = flagSet("motorsport_factory_dev"),
			careerXP = 30,
			effects = { Money = 8000, Happiness = 5 },
		},
		{
			id = "demand_race_clause",
			text = "Add a guaranteed race seat clause.",
			resultText = "Negotiations get tense, but you secure real seat time after two podiums.",
			flags = flagSet("motorsport_factory_dev", "motorsport_clause_race_seat"),
			careerXP = 35,
			careerReputation = 10,
			effects = { Money = 5000 },
		},
	},
})

table.insert(events, {
	id = "motorsport_branch_selection",
	emoji = "🛣️",
	title = "Discipline Declaration",
	category = "motorsport",
	tags = {"motorsport", "branch"},
	weight = 7,
	oneTime = true,
	conditions = {
		minAge = 19,
		maxAge = 26,
		requiredCareerId = "motorsport_icon",
		blockedFlags = {"motorsport_branch_locked"},
	},
	text = "Teams ask: will you chase single-seater precision, endurance brutality, or street-icon chaos?",
	choices = {
		{
			id = "single_seater",
			text = "Single-Seater ladder (F4 → F2 → F1).",
			resultText = "You lock in perfect apexes and sponsor politics.",
			flags = flagSet("motorsport_single_seater", "motorsport_branch_locked"),
			careerBranch = "single_seater",
			careerXP = 20,
		},
		{
			id = "endurance",
			text = "Endurance / Hypercar.",
			resultText = "You learn to hallucinate during triple stints and love it.",
			flags = flagSet("motorsport_endurance", "motorsport_branch_locked"),
			careerBranch = "endurance",
			careerXP = 20,
		},
		{
			id = "street_icon",
			text = "Street icon + viral outlaw status.",
			resultText = "You weaponize neon nights and drone footage.",
			flags = flagSet("motorsport_street_icon", "motorsport_branch_locked"),
			careerBranch = "street_icon",
			careerXP = 20,
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- BRANCHED PRIME YEARS (AGES 22-35)
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_single_f2_showdown",
	emoji = "⚙️",
	title = "Junior Formula Showdown",
	category = "motorsport",
	tags = {"motorsport", "single_seater"},
	weight = 9,
	cooldownYears = 2,
	conditions = {
		minAge = 20,
		maxAge = 28,
		requiredCareerId = "motorsport_icon",
		requiredCareerBranch = "single_seater",
		requiredCareerMinTier = 2,
		custom = function(state)
			return hasTrait(state, "RACER")
		end,
	},
	text = "The F2 car snaps over crests; sponsors want spectacle, engineers want you to bring it home.",
	choices = {
		{
			id = "safe_points",
			text = "Bank points. Data > drama.",
			resultText = "You become the consistency benchmark; F1 scouts notice.",
			flags = flagSet("motorsport_points_machine"),
			careerXP = 30,
			careerReputation = 15,
			effects = { Fame = 3 },
		},
		{
			id = "pole_hunt",
			text = "Trim downforce, chase pole even if it risks a crash.",
			resultText = "Pole + fastest lap. Highlight reels melt the internet.",
			flags = flagSet("motorsport_glory_hunter"),
			traits = traitPayload({ add = {"THRILLSEEKER"} }),
			careerXP = 35,
			effects = { Fame = 6 },
		},
	},
})

table.insert(events, {
	id = "motorsport_endurance_night_stint",
	emoji = "🌙",
	title = "24h Night Stint",
	category = "motorsport",
	tags = {"motorsport", "endurance"},
	weight = 9,
	cooldownYears = 3,
	conditions = {
		minAge = 22,
		maxAge = 34,
		requiredCareerId = "motorsport_icon",
		requiredCareerBranch = "endurance",
		requiredCareerMinTier = 3,
	},
	text = "3 AM. Rain. You triple-stint while teammates puke from exhaustion.",
	choices = {
		{
			id = "zen_mode",
			text = "Drive like a metronome.",
			resultText = "Engineers call you mythical. Sponsors trust you with the brand.",
			flags = flagSet("motorsport_metronome"),
			careerXP = 35,
			effects = { Happiness = 5, Fame = 3 },
		},
		{
			id = "heroics",
			text = "Push double stints; claw back laps.",
			resultText = "You pass three hypercars in fog. Viral onboard hits 5M views.",
			flags = flagSet("motorsport_night_hero"),
			careerXP = 40,
			effects = { Fame = 7 },
		},
	},
})

table.insert(events, {
	id = "motorsport_streeticon_viral",
	emoji = "📹",
	title = "Viral Night Run",
	category = "motorsport",
	tags = {"motorsport", "street_icon"},
	weight = 9,
	cooldownYears = 2,
	conditions = {
		minAge = 20,
		maxAge = 32,
		requiredCareerId = "motorsport_icon",
		requiredCareerBranch = "street_icon",
		requiredCareerMinTier = 2,
	},
	text = "You shut down a city block with drones filming every apex. Police scanners chirp.",
	choices = {
		{
			id = "controlled_cinema",
			text = "Pre-produce. Safety PSAs + brand tie-ins.",
			resultText = "You get brand deals AND outlaw cred.",
			flags = flagSet("motorsport_brand_safe_outlaw"),
			traits = traitPayload({ add = {"MEDIA_DARLING"} }),
			careerXP = 25,
			effects = { Money = 40000, Fame = 6 },
		},
		{
			id = "raw_stream",
			text = "Livestream chaos; let viewers direct camera angles.",
			resultText = "20M views overnight. Cops knock in the morning.",
			flags = flagSet("motorsport_heat_level"),
			careerXP = 20,
			effects = { Fame = 10, Karma = -3 },
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- UNIVERSAL PRIME EVENTS (AGES 24-40)
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_crash_flashpoint",
	emoji = "💥",
	title = "Carbon Flashpoint",
	category = "motorsport",
	tags = {"motorsport", "injury"},
	weight = 6,
	cooldownYears = 4,
	conditions = {
		minAge = 22,
		maxAge = 38,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 3,
	},
	getDynamicData = function()
		local corners = {"Eau Rouge", "130R", "Parabolica", "The Corkscrew"}
		return { corner = corners[math.random(#corners)] }
	end,
	text = "At %corner% the suspension snaps. You go airborne, watch sparks, and flip.",
	choices = {
		{
			id = "fight_back",
			text = "Livestream rehab + come back louder.",
			resultText = "You inspire millions stuck in physio themselves.",
			flags = flagSet("motorsport_crash_survivor"),
			traits = traitPayload({ add = {"MENTOR_DRIVER"}, resolve = true }),
			effects = { Health = -15, Happiness = -4 },
		},
		{
			id = "spiral",
			text = "Withdraw and question mortality.",
			resultText = "Nightmares, panic... but newfound empathy.",
			flags = flagSet("motorsport_crash_spiral"),
			traits = traitPayload({ add = {"ANXIOUS"} }),
			effects = { Happiness = -8 },
		},
	},
})

table.insert(events, {
	id = "motorsport_world_final",
	emoji = "🏆",
	title = "World Championship Decider",
	category = "motorsport",
	tags = {"motorsport", "milestone"},
	weight = 5,
	cooldownYears = 4,
	conditions = {
		minAge = 24,
		maxAge = 38,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 5,
		custom = function(state)
			return hasTrait(state, "RACER") or hasTrait(state, "MENTOR_DRIVER")
		end,
	},
	text = "Planet-wide coverage. Your championship hinges on the final stint.",
	choices = {
		{
			id = "ice_veins",
			text = "Execute with cold ruthlessness.",
			resultText = "You clinch the title with surgical precision.",
			flags = flagSet("motorsport_world_champion", "racing_legend"),
			careerXP = 60,
			careerReputation = 40,
			effects = { Money = 500000, Happiness = 10 },
			traits = traitPayload({ add = {"MENTOR_DRIVER"} }),
		},
		{
			id = "showman_finish",
			text = "Drift across the line; make cinema.",
			resultText = "Commentators lose their minds, sponsors double your value.",
			flags = flagSet("motorsport_legendary_finish"),
			careerXP = 55,
			effects = { Fame = 12, Money = 300000 },
			traits = traitPayload({ add = {"MEDIA_DARLING"}, resolve = true }),
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- LATE CAREER / LEGACY (AGES 35+)
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_mentor_transition",
	emoji = "🤝",
	title = "Mentor or Maverick?",
	category = "motorsport",
	tags = {"motorsport", "late_career"},
	weight = 7,
	cooldownYears = 3,
	conditions = {
		minAge = 35,
		maxAge = 50,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 5,
	},
	text = "Teams beg you to mentor juniors. Streaming platforms pitch documentaries. Fans demand you forever.",
	choices = {
		{
			id = "mentor",
			text = "Become the mentor you needed.",
			resultText = "You build an academy pipeline that changes the sport's culture.",
			flags = flagSet("motorsport_founder"),
			careerXP = 25,
			effects = { Happiness = 6, Karma = 4 },
			traits = traitPayload({ add = {"MENTOR_DRIVER"} }),
		},
		{
			id = "double_down",
			text = "Chase one more triple crown before retiring.",
			resultText = "You alienate executives but fans worship the defiance.",
			flags = flagSet("motorsport_one_more_run"),
			careerXP = 20,
			effects = { Fame = 5 },
		},
	},
})

table.insert(events, {
	id = "motorsport_exit_blueprint",
	emoji = "🔧",
	title = "Exit Blueprint",
	category = "motorsport",
	tags = {"motorsport", "retirement"},
	weight = 8,
	oneTime = true,
	conditions = {
		minAge = 38,
		maxAge = 60,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 4,
	},
	text = "Your body begs for rest. Your legacy feels fragile. How do you leave?",
	choices = {
		{
			id = "retire_on_top",
			text = "Announce retirement; build an empire.",
			resultText = "You launch a talent incubator, investment fund, and media house.",
			flags = flagSet("motorsport_retired_icon"),
			traits = traitPayload({ add = {"MENTOR_DRIVER"} }),
			effects = { Happiness = 8 },
			quitCareer = true,
		},
		{
			id = "fade_out",
			text = "Fade quietly into private test sessions.",
			resultText = "No farewell tour— just you, a test track, and night drives.",
			flags = flagSet("motorsport_lowkey_exit"),
			effects = { Happiness = 4 },
			quitCareer = true,
		},
	},
})

table.insert(events, {
	id = "motorsport_legacy_foundation",
	emoji = "🏛️",
	title = "Legacy Foundation",
	category = "motorsport",
	tags = {"motorsport", "legacy"},
	weight = 6,
	cooldownYears = 4,
	conditions = {
		minAge = 40,
		maxAge = 65,
		requiredAnyFlags = {"motorsport_founder", "motorsport_retired_icon"},
	},
	text = "Former rivals donate cars to your museum. Kids quote your telemetry lectures. What's your final stamp?",
	choices = {
		{
			id = "build_school",
			text = "Open a tuition-free driver academy.",
			resultText = "You redirect sponsor money to fund overlooked talent.",
			effects = { Karma = 5, Happiness = 6 },
			flags = flagSet("motorsport_legacy_school"),
		},
		{
			id = "future_tech",
			text = "Invest in sustainable race tech.",
			resultText = "You pioneer ultra-efficient power units and reshape the sport.",
			effects = { Smarts = 3, Fame = 4 },
			flags = flagSet("motorsport_legacy_tech"),
		},
	},
})

table.insert(events, {
	id = "motorsport_final_memory",
	emoji = "🕊️",
	title = "Final Memory Lap",
	category = "motorsport",
	tags = {"motorsport", "elder"},
	weight = 10,
	oneTime = true,
	conditions = {
		minAge = 55,
		maxAge = 80,
		requiredAnyFlags = {"motorsport_retired_icon", "motorsport_lowkey_exit"},
	},
	text = "You get access to the original kart track from your childhood. The stands are empty. The asphalt whispers.",
	choices = {
		{
			id = "drive_solo",
			text = "Drive alone, feel every vibration.",
			resultText = "By the end of the lap, your younger self feels seen.",
			effects = { Happiness = 10 },
		},
		{
			id = "invite_next_gen",
			text = "Bring protégés; pass the torch.",
			resultText = "They watch you glide, then you hand over the steering wheel.",
			traits = traitPayload({ add = {"MENTOR_DRIVER"} }),
			effects = { Happiness = 12, Karma = 3 },
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- PREP STAGE: EARLY YEARS (AGES 0-12) - BIKES, NEIGHBORHOOD RACES
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_first_bike",
	emoji = "🚲",
	title = "First Bike",
	category = "motorsport",
	tags = {"motorsport", "prep", "childhood"},
	weight = 20,
	oneTime = true,
	conditions = {
		minAge = 4,
		maxAge = 6,
		-- No flag requirement - entry point for anyone
	},
	getDynamicData = function()
		local bikes = {"red BMX", "blue mountain bike", "yellow racer", "green dirt bike"}
		return { bike = bikes[math.random(#bikes)] }
	end,
	text = "Your parents buy you a %bike%. You immediately start timing yourself down the driveway.",
	choices = {
		{
			id = "race_neighbors",
			text = "Challenge every kid on the block to races.",
			resultText = "You dominate the neighborhood. Parents start timing you.",
			flags = flagSet("motorsport_neighborhood_champ"),
			traits = traitPayload({ add = {"RACER"} }),
			effects = { Fitness = 2, Happiness = 3 },
		},
		{
			id = "modify_bike",
			text = "Strip it down, add streamers, make it faster.",
			resultText = "You learn basic mechanics. The bike becomes a weapon.",
			flags = flagSet("motorsport_bike_modder"),
			traits = traitPayload({ add = {"MECHANICAPPT"} }),
			effects = { Smarts = 1, Creativity = 2 },
		},
	},
})

table.insert(events, {
	id = "motorsport_bully_race",
	emoji = "⚔️",
	title = "Bully Challenge",
	category = "motorsport",
	tags = {"motorsport", "prep", "conflict"},
	weight = 15,
	conditions = {
		minAge = 6,
		maxAge = 10,
		requiredAnyFlags = {"motorsport_neighborhood_champ", "motorsport_bike_modder"},
		custom = function(state)
			return hasTrait(state, "BULLYVICTIM") or hasTrait(state, "FATKID")
		end,
	},
	getDynamicData = function()
		local bullies = {"Marcus", "Jake", "Derek", "Troy"}
		return { bully = bullies[math.random(#bullies)] }
	end,
	text = "%bully% challenges you to a race. Winner gets respect. Loser gets pushed around.",
	choices = {
		{
			id = "accept_challenge",
			text = "Race them. Win or lose, you show courage.",
			resultText = "You beat them by a wheel. The neighborhood changes.",
			flags = flagSet("motorsport_bully_beater"),
			traits = traitPayload({ add = {"RACER"}, remove = {"BULLYVICTIM"} }),
			effects = { Happiness = 5, Fame = 1 },
		},
		{
			id = "decline_fear",
			text = "Back down. You're not ready.",
			resultText = "The fear lingers. You train harder in secret.",
			traits = traitPayload({ add = {"ANXIOUS"} }),
			effects = { Happiness = -2, Fitness = 1 },
		},
	},
})

table.insert(events, {
	id = "motorsport_go_kart_birthday",
	emoji = "🎂",
	title = "Go-Kart Birthday",
	category = "motorsport",
	tags = {"motorsport", "prep", "karting"},
	weight = 18,
	oneTime = true,
	conditions = {
		minAge = 7,
		maxAge = 10,
		-- Major entry point - boosted if you have interest, but anyone can get it
		custom = function(state)
			local flags = state.Flags or {}
			if flags.motorsport_neighborhood_champ or flags.motorsport_bike_modder or flags.motorsport_bully_beater or flags.motorsport_pedal_champ or flags.motorsport_derby_champion then
				return true
			end
			-- Still allow, just lower chance
			return math.random() < 0.5
		end,
	},
	text = "Your parents take you to a go-kart track for your birthday. You're the fastest kid there.",
	choices = {
		{
			id = "beg_for_kart",
			text = "Beg for your own kart. Promise to mow lawns forever.",
			resultText = "They cave. You get a beat-up kart and a lifetime of chores.",
			flags = flagSet("motorsport_first_kart"),
			startCareer = "motorsport_icon",
			careerXP = 5,
			effects = { Happiness = 6, Money = -500 },
		},
		{
			id = "save_allowance",
			text = "Start saving every penny for entry fees.",
			resultText = "You become obsessed with budgeting. Racing becomes the goal.",
			flags = flagSet("motorsport_saver"),
			effects = { Smarts = 2, Money = 100 },
		},
	},
})

table.insert(events, {
	id = "motorsport_neighborhood_drag",
	emoji = "🏁",
	title = "Neighborhood Drag Race",
	category = "motorsport",
	tags = {"motorsport", "prep", "illegal"},
	weight = 12,
	cooldownYears = 1,
	conditions = {
		minAge = 9,
		maxAge = 12,
		requiredAnyFlags = {"motorsport_first_kart", "motorsport_saver"},
		custom = function(state)
			return hasTrait(state, "THRILLSEEKER") or hasTrait(state, "RECKLESS")
		end,
	},
	getDynamicData = function()
		local streets = {"Maple Drive", "Oak Street", "Pine Avenue", "Elm Road"}
		return { street = streets[math.random(#streets)] }
	end,
	text = "Older kids organize illegal drag races on %street%. Cops patrol. You want in.",
	choices = {
		{
			id = "join_illegal",
			text = "Join the race. Risk it all.",
			resultText = "You win your first illegal race. Adrenaline becomes addiction.",
			flags = flagSet("motorsport_street_racer_origin"),
			traits = traitPayload({ add = {"THRILLSEEKER", "RECKLESS"} }),
			effects = { Fame = 2, Karma = -1, Happiness = 4 },
		},
		{
			id = "watch_only",
			text = "Watch from the sidelines. Learn the lines.",
			resultText = "You memorize every corner. Legal racing becomes your path.",
			flags = flagSet("motorsport_legal_path"),
			effects = { Smarts = 2 },
		},
	},
})

table.insert(events, {
	id = "motorsport_first_crash",
	emoji = "💥",
	title = "First Crash",
	category = "motorsport",
	tags = {"motorsport", "prep", "injury"},
	weight = 10,
	oneTime = true,
	conditions = {
		minAge = 8,
		maxAge = 12,
		requiredAnyFlags = {"motorsport_first_kart", "motorsport_street_racer_origin"},
	},
	text = "You push too hard on a corner. The kart flips. Your helmet cracks. Everything goes slow-motion.",
	choices = {
		{
			id = "get_back_up",
			text = "Get back in immediately. Fear is weakness.",
			resultText = "You race the next day. Fear becomes fuel.",
			flags = flagSet("motorsport_crash_immune"),
			traits = traitPayload({ add = {"THRILLSEEKER"} }),
			effects = { Health = -5, Happiness = 2 },
		},
		{
			id = "process_fear",
			text = "Take time to process. Respect the danger.",
			resultText = "You learn caution. Speed becomes calculated.",
			flags = flagSet("motorsport_respects_danger"),
			traits = traitPayload({ add = {"GOODDRIVER"} }),
			effects = { Health = -3, Smarts = 2 },
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- KARTING STAGE (AGES 6-16) - COMPETITIVE KARTING
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_kart_regional",
	emoji = "🏆",
	title = "Regional Kart Championship",
	category = "motorsport",
	tags = {"motorsport", "karting", "competition"},
	weight = 14,
	cooldownYears = 1,
	conditions = {
		minAge = 8,
		maxAge = 14,
		requiredAnyFlags = {"motorsport_first_kart", "motorsport_kart_builder"},
		requiredCareerId = "motorsport_icon",
	},
	getDynamicData = function()
		local tracks = {"Willow Springs", "Buttonwillow", "Laguna Seca", "Sonoma"}
		return { track = tracks[math.random(#tracks)] }
	end,
	text = "Regional championship at %track%. Factory teams show up with $50k karts. You have a $2k beater.",
	choices = {
		{
			id = "outdrive_them",
			text = "Outdrive them. Talent beats money.",
			resultText = "You podium with a broken seat. Scouts notice.",
			flags = flagSet("motorsport_regional_podium"),
			careerXP = 25,
			careerReputation = 10,
			effects = { Fame = 3, Happiness = 5 },
		},
		{
			id = "strategic_points",
			text = "Play it safe. Bank points for the series.",
			resultText = "Consistency wins. You finish top-5 in championship.",
			flags = flagSet("motorsport_consistent_finisher"),
			careerXP = 20,
			effects = { Smarts = 2, Fame = 2 },
		},
	},
})

table.insert(events, {
	id = "motorsport_kart_engine_blow",
	emoji = "🔥",
	title = "Engine Blow",
	category = "motorsport",
	tags = {"motorsport", "karting", "mechanical"},
	weight = 12,
	cooldownYears = 2,
	conditions = {
		minAge = 9,
		maxAge = 15,
		requiredCareerId = "motorsport_icon",
		requiredAnyFlags = {"motorsport_regional_podium", "motorsport_consistent_finisher"},
	},
	text = "Your kart's engine seizes mid-race. Smoke everywhere. Championship hopes die.",
	choices = {
		{
			id = "rebuild_engine",
			text = "Rebuild it yourself. Learn the engine inside-out.",
			resultText = "You become the engine whisperer. No failure surprises you.",
			flags = flagSet("motorsport_engine_master"),
			traits = traitPayload({ add = {"MECHANICAPPT"}, resolve = true }),
			effects = { Smarts = 3, Money = -300 },
		},
		{
			id = "buy_new_engine",
			text = "Scrape together cash for a new engine.",
			resultText = "You learn the value of reliability over power.",
			flags = flagSet("motorsport_reliability_focus"),
			effects = { Money = -800, Smarts = 1 },
		},
	},
})

table.insert(events, {
	id = "motorsport_kart_rival_arc",
	emoji = "⚔️",
	title = "Rival Arc",
	category = "motorsport",
	tags = {"motorsport", "karting", "rivalry"},
	weight = 13,
	cooldownYears = 1,
	conditions = {
		minAge = 10,
		maxAge = 16,
		requiredCareerId = "motorsport_icon",
		requiredAnyFlags = {"motorsport_regional_podium", "motorsport_consistent_finisher"},
	},
	getDynamicData = function()
		local rivals = {"Alex Rivera", "Jordan Chen", "Sam Taylor", "Casey Morgan"}
		return { rival = rivals[math.random(#rivals)] }
	end,
	text = "%rival% becomes your nemesis. Every race, you two battle. The rivalry defines your career.",
	choices = {
		{
			id = "respectful_rivalry",
			text = "Respect them. Push each other to greatness.",
			resultText = "You become friends off-track, enemies on-track. Both improve.",
			flags = flagSet("motorsport_respectful_rival"),
			traits = traitPayload({ add = {"GOODDRIVER"} }),
			careerXP = 15,
			careerReputation = 5,
			effects = { Happiness = 3, Fame = 2 },
		},
		{
			id = "dirty_rivalry",
			text = "Get aggressive. Win at any cost.",
			resultText = "You punt them off. Reputation takes a hit, but you win.",
			flags = flagSet("motorsport_dirty_driver"),
			traits = traitPayload({ add = {"RECKLESS"} }),
			careerXP = 20,
			effects = { Fame = 1, Karma = -2 },
		},
	},
})

table.insert(events, {
	id = "motorsport_kart_nationals",
	emoji = "🇺🇸",
	title = "National Karting Championships",
	category = "motorsport",
	tags = {"motorsport", "karting", "milestone"},
	weight = 11,
	oneTime = true,
	conditions = {
		minAge = 12,
		maxAge = 16,
		requiredCareerId = "motorsport_icon",
		requiredAnyFlags = {"motorsport_regional_podium", "motorsport_consistent_finisher"},
		requiredCareerMinTier = 1,
	},
	text = "National championships. Every factory team is here. This is your shot at a factory ride.",
	choices = {
		{
			id = "win_nationals",
			text = "Go for the win. All or nothing.",
			resultText = "You win. Factory teams line up with contracts.",
			flags = flagSet("motorsport_national_champion"),
			careerXP = 50,
			careerReputation = 30,
			promoteCareer = true,
			effects = { Fame = 8, Happiness = 10, Money = 5000 },
		},
		{
			id = "safe_podium",
			text = "Secure a podium. Consistency over glory.",
			resultText = "You finish 3rd. Good teams notice your maturity.",
			flags = flagSet("motorsport_national_podium"),
			careerXP = 40,
			careerReputation = 20,
			effects = { Fame = 5, Happiness = 6 },
		},
	},
})

table.insert(events, {
	id = "motorsport_kart_first_vehicle",
	emoji = "🚗",
	title = "First Real Vehicle",
	category = "motorsport",
	tags = {"motorsport", "karting", "vehicle"},
	weight = 10,
	oneTime = true,
	conditions = {
		minAge = 14,
		maxAge = 18,
		requiredCareerId = "motorsport_icon",
		minMoney = 2000,
	},
	getDynamicData = function()
		local vehicles = {
			{make = "Honda", model = "Civic", price = 2500, condition = "beater"},
			{make = "Mazda", model = "Miata", price = 3500, condition = "project"},
			{make = "Ford", model = "Mustang", price = 5000, condition = "rough"},
			{make = "Toyota", model = "Corolla", price = 2000, condition = "reliable"},
		}
		local v = vehicles[math.random(#vehicles)]
		return { make = v.make, model = v.model, price = v.price, condition = v.condition }
	end,
	text = "You save enough for your first real car: a %condition% %make% %model% for $%price%. Time to hit the streets.",
	choices = {
		{
			id = "buy_vehicle",
			text = "Buy it. Start street racing.",
			resultText = "You join the underground scene. Cops become a problem.",
			flags = flagSet("motorsport_first_car"),
			addAsset = {
				type = "vehicle",
				make = "%make%",
				model = "%model%",
				value = 3000,
				condition = "%condition%",
			},
			effects = { Money = -3000, Fame = 2, Karma = -1 },
		},
		{
			id = "save_more",
			text = "Keep saving. Buy something better later.",
			resultText = "Patience pays off. You focus on karting.",
			effects = { Smarts = 2, Money = 500 },
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- JUNIOR_FORMULA STAGE (AGES 16-22) - JUNIOR FORMULA RACING
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_junior_formula_debut",
	emoji = "🏎️",
	title = "Junior Formula Debut",
	category = "motorsport",
	tags = {"motorsport", "junior_formula", "debut"},
	weight = 12,
	oneTime = true,
	conditions = {
		minAge = 16,
		maxAge = 20,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 2,
		requiredAnyFlags = {"motorsport_national_champion", "motorsport_national_podium", "motorsport_academy_signed"},
	},
	getDynamicData = function()
		local series = {"F4 Championship", "Formula Regional", "USF2000", "Formula Renault"}
		return { series = series[math.random(#series)] }
	end,
	text = "Your debut in %series%. The car is 10x faster than karts. Your neck can't handle the G-forces.",
	choices = {
		{
			id = "push_through",
			text = "Push through the pain. Show mental toughness.",
			resultText = "You finish mid-pack. Coaches notice your grit.",
			flags = flagSet("motorsport_junior_debut"),
			careerXP = 30,
			careerReputation = 10,
			effects = { Health = -3, Fame = 3 },
		},
		{
			id = "study_data",
			text = "Study telemetry. Learn before you push.",
			resultText = "You finish top-10. Data-driven approach impresses engineers.",
			flags = flagSet("motorsport_data_driven"),
			traits = traitPayload({ add = {"DATA_STRATEGIST"} }),
			careerXP = 35,
			effects = { Smarts = 3, Fame = 2 },
		},
	},
})

table.insert(events, {
	id = "motorsport_junior_crash_major",
	emoji = "💥",
	title = "Major Crash",
	category = "motorsport",
	tags = {"motorsport", "junior_formula", "injury", "death"},
	weight = 8,
	cooldownYears = 3,
	conditions = {
		minAge = 17,
		maxAge = 22,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 2,
		custom = function(state)
			return hasTrait(state, "RECKLESS") or hasTrait(state, "THRILLSEEKER")
		end,
	},
	getDynamicData = function()
		local corners = {"Turn 1", "The Esses", "The Carousel", "The Kink"}
		return { corner = corners[math.random(#corners)] }
	end,
	text = "At %corner%, you lose control at 140mph. The car flips, rolls, disintegrates. Everything goes black.",
	choices = {
		{
			id = "survive_severe",
			text = "Wake up in hospital. Broken bones, but alive.",
			resultText = "You survive. The crash changes you forever. Racing becomes more calculated.",
			flags = flagSet("motorsport_major_crash_survivor"),
			traits = traitPayload({ add = {"ANXIOUS"}, remove = {"RECKLESS"} }),
			effects = { Health = -25, Happiness = -10, Smarts = 2 },
		},
		{
			id = "death_risk",
			text = "The impact is too severe. You don't make it.",
			resultText = "Your life ends on the track. A tragic reminder of racing's dangers.",
			effects = { Health = -100 },
			flags = flagSet("death_racing_accident"),
		},
	},
})

table.insert(events, {
	id = "motorsport_junior_first_win",
	emoji = "🏆",
	title = "First Junior Formula Win",
	category = "motorsport",
	tags = {"motorsport", "junior_formula", "victory"},
	weight = 11,
	oneTime = true,
	conditions = {
		minAge = 17,
		maxAge = 21,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 2,
		requiredAnyFlags = {"motorsport_junior_debut", "motorsport_data_driven"},
	},
	text = "Your first win in junior formula. The podium feels like a dream. Sponsors start calling.",
	choices = {
		{
			id = "celebrate_modest",
			text = "Stay humble. Focus on the next race.",
			resultText = "Your maturity impresses team owners. More opportunities come.",
			flags = flagSet("motorsport_humble_winner"),
			careerXP = 40,
			careerReputation = 15,
			effects = { Fame = 4, Happiness = 6 },
		},
		{
			id = "celebrate_loud",
			text = "Celebrate hard. You earned this.",
			resultText = "You party all night. The media loves your personality.",
			flags = flagSet("motorsport_celebrity_driver"),
			traits = traitPayload({ add = {"MEDIA_DARLING"} }),
			careerXP = 35,
			effects = { Fame = 6, Happiness = 8 },
		},
	},
})

table.insert(events, {
	id = "motorsport_junior_championship",
	emoji = "🥇",
	title = "Junior Formula Championship",
	category = "motorsport",
	tags = {"motorsport", "junior_formula", "championship"},
	weight = 9,
	oneTime = true,
	conditions = {
		minAge = 18,
		maxAge = 22,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 2,
		requiredAnyFlags = {"motorsport_junior_debut", "motorsport_data_driven", "motorsport_humble_winner"},
	},
	text = "Final race of the season. You're tied for the championship. One race decides everything.",
	choices = {
		{
			id = "win_championship",
			text = "Win the championship. Become a legend.",
			resultText = "You clinch the title. F1 teams start serious negotiations.",
			flags = flagSet("motorsport_junior_champion"),
			careerXP = 60,
			careerReputation = 40,
			promoteCareer = true,
			effects = { Fame = 10, Happiness = 12, Money = 50000 },
		},
		{
			id = "lose_championship",
			text = "Finish 2nd. Learn from defeat.",
			resultText = "You lose by 2 points. The hunger drives you harder.",
			flags = flagSet("motorsport_junior_runner_up"),
			careerXP = 50,
			careerReputation = 25,
			effects = { Fame = 6, Happiness = -2, Smarts = 2 },
		},
	},
})

table.insert(events, {
	id = "motorsport_junior_vehicle_upgrade",
	emoji = "🚙",
	title = "Upgrade Vehicle",
	category = "motorsport",
	tags = {"motorsport", "junior_formula", "vehicle"},
	weight = 10,
	oneTime = true,
	conditions = {
		minAge = 18,
		maxAge = 22,
		requiredCareerId = "motorsport_icon",
		minMoney = 10000,
		requiredAnyFlags = {"motorsport_first_car"},
	},
	getDynamicData = function()
		local vehicles = {
			{make = "BMW", model = "M3", price = 15000, condition = "used"},
			{make = "Audi", model = "S4", price = 18000, condition = "clean"},
			{make = "Mercedes", model = "C63", price = 22000, condition = "premium"},
			{make = "Porsche", model = "911", price = 35000, condition = "dream"},
		}
		local v = vehicles[math.random(#vehicles)]
		return { make = v.make, model = v.model, price = v.price, condition = v.condition }
	end,
	text = "You've saved enough for a real upgrade: a %condition% %make% %model% for $%price%. Time to live the dream.",
	choices = {
		{
			id = "buy_upgrade",
			text = "Buy it. You've earned this.",
			resultText = "You drive off the lot feeling like a champion.",
			flags = flagSet("motorsport_premium_vehicle"),
			addAsset = {
				type = "vehicle",
				make = "%make%",
				model = "%model%",
				value = 18000,
				condition = "%condition%",
			},
			effects = { Money = -18000, Happiness = 8, Fame = 3 },
		},
		{
			id = "invest_racing",
			text = "Invest the money in racing. Cars can wait.",
			resultText = "You put everything into your career. Smart move.",
			effects = { Money = 5000, careerXP = 20 },
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- PRO_CIRCUIT STAGE (AGES 20+) - PROFESSIONAL CIRCUIT RACING
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_pro_f1_test",
	emoji = "🏎️",
	title = "F1 Test Drive",
	category = "motorsport",
	tags = {"motorsport", "pro_circuit", "f1"},
	weight = 10,
	oneTime = true,
	conditions = {
		minAge = 20,
		maxAge = 28,
		requiredCareerId = "motorsport_icon",
		requiredCareerBranch = "single_seater",
		requiredCareerMinTier = 3,
		requiredAnyFlags = {"motorsport_junior_champion", "motorsport_points_machine"},
	},
	getDynamicData = function()
		local teams = {"Red Bull Racing", "Mercedes AMG", "Ferrari", "McLaren"}
		return { team = teams[math.random(#teams)] }
	end,
	text = "%team% invites you for an F1 test. This is your shot at the pinnacle of motorsport.",
	choices = {
		{
			id = "ace_test",
			text = "Ace the test. Show you belong in F1.",
			resultText = "You set fastest lap. Contract negotiations begin.",
			flags = flagSet("motorsport_f1_test_ace"),
			careerXP = 50,
			careerReputation = 30,
			promoteCareer = true,
			effects = { Fame = 12, Happiness = 10 },
		},
		{
			id = "struggle_test",
			text = "Struggle with the car. F1 is harder than expected.",
			resultText = "You realize F1 requires more experience. Back to F2.",
			flags = flagSet("motorsport_f1_not_ready"),
			careerXP = 30,
			effects = { Happiness = -3, Smarts = 2 },
		},
	},
})

table.insert(events, {
	id = "motorsport_pro_f1_debut",
	emoji = "🏁",
	title = "F1 Race Debut",
	category = "motorsport",
	tags = {"motorsport", "pro_circuit", "f1", "milestone"},
	weight = 9,
	oneTime = true,
	conditions = {
		minAge = 21,
		maxAge = 30,
		requiredCareerId = "motorsport_icon",
		requiredCareerBranch = "single_seater",
		requiredCareerMinTier = 4,
		requiredAnyFlags = {"motorsport_f1_test_ace"},
	},
	getDynamicData = function()
		local tracks = {"Monaco", "Silverstone", "Spa-Francorchamps", "Monza"}
		return { track = tracks[math.random(#tracks)] }
	end,
	text = "Your F1 debut at %track%. The world watches. You're living the dream.",
	choices = {
		{
			id = "points_finish",
			text = "Score points in your debut. Make history.",
			resultText = "You finish 8th. First points in your first race. Legendary.",
			flags = flagSet("motorsport_f1_debut_points"),
			careerXP = 60,
			careerReputation = 40,
			effects = { Fame = 15, Happiness = 12, Money = 200000 },
		},
		{
			id = "crash_debut",
			text = "Crash out. The pressure gets to you.",
			resultText = "You crash on lap 3. The media rips you apart.",
			flags = flagSet("motorsport_f1_debut_crash"),
			careerXP = 20,
			effects = { Fame = 5, Happiness = -5, Health = -10 },
		},
	},
})

table.insert(events, {
	id = "motorsport_pro_f1_win",
	emoji = "🏆",
	title = "First F1 Win",
	category = "motorsport",
	tags = {"motorsport", "pro_circuit", "f1", "victory"},
	weight = 8,
	oneTime = true,
	conditions = {
		minAge = 22,
		maxAge = 32,
		requiredCareerId = "motorsport_icon",
		requiredCareerBranch = "single_seater",
		requiredCareerMinTier = 4,
		requiredAnyFlags = {"motorsport_f1_debut_points"},
	},
	text = "Your first F1 win. The checkered flag. The anthem. You're a Grand Prix winner.",
	choices = {
		{
			id = "emotional_win",
			text = "Cry on the podium. This means everything.",
			resultText = "The world sees your passion. You become a fan favorite.",
			flags = flagSet("motorsport_f1_winner"),
			traits = traitPayload({ add = {"MEDIA_DARLING"} }),
			careerXP = 70,
			careerReputation = 50,
			effects = { Fame = 20, Happiness = 15, Money = 500000 },
		},
		{
			id = "business_win",
			text = "Stay professional. More wins to come.",
			resultText = "Your maturity impresses. Teams want you long-term.",
			flags = flagSet("motorsport_f1_professional"),
			careerXP = 65,
			careerReputation = 45,
			effects = { Fame = 15, Happiness = 12, Money = 400000 },
		},
	},
})

table.insert(events, {
	id = "motorsport_pro_f1_championship",
	emoji = "🥇",
	title = "F1 World Championship",
	category = "motorsport",
	tags = {"motorsport", "pro_circuit", "f1", "championship", "milestone"},
	weight = 7,
	oneTime = true,
	conditions = {
		minAge = 24,
		maxAge = 35,
		requiredCareerId = "motorsport_icon",
		requiredCareerBranch = "single_seater",
		requiredCareerMinTier = 5,
		requiredAnyFlags = {"motorsport_f1_winner", "motorsport_f1_professional"},
	},
	text = "Final race of the season. You're leading the championship. One race to become World Champion.",
	choices = {
		{
			id = "win_championship",
			text = "Win the championship. Become a legend.",
			resultText = "You're F1 World Champion. Immortality achieved.",
			flags = flagSet("motorsport_f1_champion", "racing_legend"),
			careerXP = 100,
			careerReputation = 80,
			effects = { Fame = 30, Happiness = 20, Money = 5000000 },
			traits = traitPayload({ add = {"MENTOR_DRIVER"} }),
		},
		{
			id = "lose_championship",
			text = "Lose by a point. Heartbreak.",
			resultText = "You finish 2nd in championship. The pain drives you.",
			flags = flagSet("motorsport_f1_runner_up"),
			careerXP = 80,
			careerReputation = 60,
			effects = { Fame = 20, Happiness = -5, Smarts = 3 },
		},
	},
})

table.insert(events, {
	id = "motorsport_pro_supercar",
	emoji = "🚗",
	title = "Supercar Purchase",
	category = "motorsport",
	tags = {"motorsport", "pro_circuit", "vehicle"},
	weight = 9,
	oneTime = true,
	conditions = {
		minAge = 22,
		maxAge = 35,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 4,
		minMoney = 100000,
	},
	getDynamicData = function()
		local vehicles = {
			{make = "Ferrari", model = "488 GTB", price = 250000, condition = "new"},
			{make = "Lamborghini", model = "Huracán", price = 200000, condition = "new"},
			{make = "McLaren", model = "720S", price = 300000, condition = "new"},
			{make = "Porsche", model = "911 GT3 RS", price = 200000, condition = "new"},
		}
		local v = vehicles[math.random(#vehicles)]
		return { make = v.make, model = v.model, price = v.price, condition = v.condition }
	end,
	text = "You've made it. Time for a real supercar: a %condition% %make% %model% for $%price%. The dream car.",
	choices = {
		{
			id = "buy_supercar",
			text = "Buy it. You've earned this.",
			resultText = "You drive the supercar off the lot. Life is good.",
			flags = flagSet("motorsport_supercar_owner"),
			addAsset = {
				type = "vehicle",
				make = "%make%",
				model = "%model%",
				value = 200000,
				condition = "%condition%",
			},
			effects = { Money = -200000, Happiness = 10, Fame = 5 },
		},
		{
			id = "invest_wisely",
			text = "Invest the money. Supercars are for later.",
			resultText = "You make smart financial moves. Future you will thank you.",
			effects = { Money = 50000, Smarts = 3 },
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- STREET_RACER STAGE (AGES 16+) - ILLEGAL STREET RACING PATH
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_street_underground",
	emoji = "🌃",
	title = "Underground Scene",
	category = "motorsport",
	tags = {"motorsport", "street_racer", "illegal"},
	weight = 12,
	conditions = {
		minAge = 16,
		maxAge = 25,
		requiredAnyFlags = {"motorsport_street_racer_origin", "motorsport_underground_path"},
		custom = function(state)
			return hasTrait(state, "THRILLSEEKER") or hasTrait(state, "RECKLESS")
		end,
	},
	text = "You dive deep into the underground street racing scene. Cops are everywhere. The stakes are real.",
	choices = {
		{
			id = "become_legend",
			text = "Become a legend. Win every race.",
			resultText = "You dominate the scene. Your name becomes myth.",
			flags = flagSet("motorsport_street_legend"),
			startCareer = "motorsport_icon",
			careerBranch = "street_icon",
			careerXP = 30,
			effects = { Fame = 5, Karma = -2, Happiness = 6 },
		},
		{
			id = "get_caught",
			text = "Get caught by cops. Learn the hard way.",
			resultText = "You get arrested. Racing becomes harder, but you're smarter.",
			flags = flagSet("motorsport_street_arrested"),
			effects = { Fame = 2, Karma = -3, Smarts = 2 },
		},
	},
})

table.insert(events, {
	id = "motorsport_street_takeover",
	emoji = "🔥",
	title = "Street Takeover",
	category = "motorsport",
	tags = {"motorsport", "street_racer", "illegal", "death"},
	weight = 10,
	cooldownYears = 2,
	conditions = {
		minAge = 18,
		maxAge = 28,
		requiredCareerId = "motorsport_icon",
		requiredCareerBranch = "street_icon",
		requiredAnyFlags = {"motorsport_street_legend", "motorsport_street_arrested"},
	},
	text = "A massive street takeover. Hundreds of cars. Cops closing in. Someone crashes. Chaos.",
	choices = {
		{
			id = "escape_clean",
			text = "Escape clean. Live to race another day.",
			resultText = "You get away. The scene respects your survival skills.",
			flags = flagSet("motorsport_street_survivor"),
			careerXP = 25,
			effects = { Fame = 4, Karma = -2 },
		},
		{
			id = "crash_fatal",
			text = "Crash. The impact is fatal.",
			resultText = "You lose control. The crash kills you. Street racing claims another life.",
			effects = { Health = -100 },
			flags = flagSet("death_street_racing"),
		},
	},
})

table.insert(events, {
	id = "motorsport_street_viral",
	emoji = "📱",
	title = "Viral Street Run",
	category = "motorsport",
	tags = {"motorsport", "street_racer", "media"},
	weight = 11,
	cooldownYears = 1,
	conditions = {
		minAge = 19,
		maxAge = 30,
		requiredCareerId = "motorsport_icon",
		requiredCareerBranch = "street_icon",
		requiredCareerMinTier = 2,
	},
	text = "Your street run goes viral. Millions of views. Brands want in. But you're still illegal.",
	choices = {
		{
			id = "go_legal",
			text = "Transition to legal racing. Keep the style.",
			resultText = "You become a media darling while staying true to your roots.",
			flags = flagSet("motorsport_street_to_legal"),
			traits = traitPayload({ add = {"MEDIA_DARLING"} }),
			careerXP = 40,
			careerReputation = 20,
			effects = { Fame = 10, Money = 100000, Karma = 2 },
		},
		{
			id = "stay_underground",
			text = "Stay underground. Keep it real.",
			resultText = "You reject the mainstream. The scene respects your loyalty.",
			flags = flagSet("motorsport_street_pure"),
			careerXP = 30,
			effects = { Fame = 6, Karma = -1 },
		},
	},
})

table.insert(events, {
	id = "motorsport_street_tuner_shop",
	emoji = "🔧",
	title = "Tuner Shop",
	category = "motorsport",
	tags = {"motorsport", "street_racer", "vehicle"},
	weight = 10,
	oneTime = true,
	conditions = {
		minAge = 18,
		maxAge = 28,
		requiredCareerId = "motorsport_icon",
		requiredCareerBranch = "street_icon",
		minMoney = 15000,
		requiredAnyFlags = {"motorsport_first_car", "motorsport_premium_vehicle"},
	},
	getDynamicData = function()
		local mods = {
			{type = "turbo kit", price = 8000, power = "massive"},
			{type = "nitrous system", price = 5000, power = "extreme"},
			{type = "engine swap", price = 12000, power = "legendary"},
			{type = "full build", price = 20000, power = "insane"},
		}
		local m = mods[math.random(#mods)]
		return { type = m.type, price = m.price, power = m.power }
	end,
	text = "A tuner shop offers a %type% for $%price%. Your car will have %power% power. But it's expensive.",
	choices = {
		{
			id = "buy_mods",
			text = "Buy the mods. Make your car a weapon.",
			resultText = "Your car becomes a monster. Street races become easier.",
			flags = flagSet("motorsport_tuned_vehicle"),
			effects = { Money = -15000, Fame = 4, Happiness = 6 },
		},
		{
			id = "save_money",
			text = "Save the money. Natural talent beats mods.",
			resultText = "You win races on skill alone. Respect grows.",
			flags = flagSet("motorsport_natural_talent"),
			careerXP = 20,
			effects = { Smarts = 2 },
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- MECHANIC STAGE (AGES 18+) - FALLBACK MECHANIC PATH
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_mechanic_career_choice",
	emoji = "🔧",
	title = "Mechanic Career",
	category = "motorsport",
	tags = {"motorsport", "mechanic", "career"},
	weight = 15,
	oneTime = true,
	conditions = {
		minAge = 18,
		maxAge = 25,
		requiredAnyFlags = {"motorsport_engine_master", "motorsport_kart_builder"},
		custom = function(state)
			return hasTrait(state, "MECHANICAPPT")
		end,
		blockedFlags = {"motorsport_academy_signed", "motorsport_junior_champion"},
	},
	text = "Racing didn't work out, but your mechanical skills are undeniable. A race team offers you a mechanic position.",
	choices = {
		{
			id = "accept_mechanic",
			text = "Accept. Build cars for others to race.",
			resultText = "You become a master mechanic. Teams fight for your services.",
			flags = flagSet("motorsport_mechanic_path"),
			startCareer = "motorsport_icon",
			careerBranch = "mechanic",
			careerXP = 25,
			effects = { Money = 40000, Happiness = 5, Smarts = 3 },
		},
		{
			id = "reject_keep_trying",
			text = "Reject. Keep trying to race.",
			resultText = "You refuse to give up. The hunger drives you.",
			flags = flagSet("motorsport_never_give_up"),
			effects = { Happiness = -2, Smarts = 1 },
		},
	},
})

table.insert(events, {
	id = "motorsport_mechanic_engine_master",
	emoji = "⚙️",
	title = "Engine Master",
	category = "motorsport",
	tags = {"motorsport", "mechanic", "skill"},
	weight = 12,
	cooldownYears = 2,
	conditions = {
		minAge = 20,
		maxAge = 35,
		requiredCareerId = "motorsport_icon",
		requiredAnyFlags = {"motorsport_mechanic_path"},
		custom = function(state)
			return hasTrait(state, "MECHANICAPPT")
		end,
	},
	text = "You become known as the engine whisperer. Teams bring you impossible problems. You solve them all.",
	choices = {
		{
			id = "become_legend",
			text = "Become a legend. Your engines win championships.",
			resultText = "You're the most sought-after mechanic in motorsport.",
			flags = flagSet("motorsport_mechanic_legend"),
			careerXP = 50,
			careerReputation = 40,
			effects = { Money = 150000, Fame = 8, Happiness = 10 },
		},
		{
			id = "start_business",
			text = "Start your own tuning shop.",
			resultText = "You open a shop. Street racers and pros both come to you.",
			flags = flagSet("motorsport_mechanic_business"),
			careerXP = 40,
			effects = { Money = 200000, Happiness = 8 },
		},
	},
})

table.insert(events, {
	id = "motorsport_mechanic_race_team",
	emoji = "🏎️",
	title = "Race Team Owner",
	category = "motorsport",
	tags = {"motorsport", "mechanic", "business"},
	weight = 10,
	oneTime = true,
	conditions = {
		minAge = 28,
		maxAge = 45,
		requiredCareerId = "motorsport_icon",
		requiredAnyFlags = {"motorsport_mechanic_legend", "motorsport_mechanic_business"},
		minMoney = 500000,
	},
	text = "You've saved enough. Time to start your own race team. Build cars, find drivers, chase championships.",
	choices = {
		{
			id = "start_team",
			text = "Start the team. Become an owner.",
			resultText = "You launch your team. Dreams become reality.",
			flags = flagSet("motorsport_team_owner"),
			careerXP = 60,
			careerReputation = 50,
			effects = { Money = -300000, Fame = 12, Happiness = 12 },
		},
		{
			id = "stay_mechanic",
			text = "Stay a mechanic. Master your craft.",
			resultText = "You focus on perfection. The best mechanic in the world.",
			flags = flagSet("motorsport_mechanic_master"),
			careerXP = 50,
			effects = { Money = 100000, Happiness = 8 },
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- DEATH SCENARIOS - FATAL RACING ACCIDENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_death_high_speed",
	emoji = "💀",
	title = "High-Speed Fatal Crash",
	category = "motorsport",
	tags = {"motorsport", "death", "fatal"},
	weight = 3,
	oneTime = true,
	conditions = {
		minAge = 20,
		maxAge = 40,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 3,
		custom = function(state)
			return hasTrait(state, "RECKLESS") and (state.Stats and (state.Stats.Health or 100) < 50)
		end,
	},
	text = "At 200mph, your car loses control. The barrier doesn't give. The impact is instant. Your life ends on the track.",
	choices = {
		{
			id = "death",
			text = "Your racing career ends in tragedy.",
			resultText = "You die doing what you loved. The racing world mourns.",
			effects = { Health = -100 },
			flags = flagSet("death_racing_fatal"),
		},
	},
})

table.insert(events, {
	id = "motorsport_death_street_illegal",
	emoji = "💀",
	title = "Illegal Street Race Death",
	category = "motorsport",
	tags = {"motorsport", "death", "street"},
	weight = 4,
	oneTime = true,
	conditions = {
		minAge = 18,
		maxAge = 35,
		requiredCareerId = "motorsport_icon",
		requiredCareerBranch = "street_icon",
		custom = function(state)
			return hasTrait(state, "THRILLSEEKER") and hasTrait(state, "RECKLESS")
		end,
	},
	text = "An illegal street race goes wrong. You hit a pole at 120mph. No safety equipment. No second chance.",
	choices = {
		{
			id = "death",
			text = "Street racing claims another life.",
			resultText = "You die in an illegal race. A tragic end to a promising career.",
			effects = { Health = -100 },
			flags = flagSet("death_street_illegal"),
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- ADDITIONAL PREP STAGE EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_prep_pedal_car",
	emoji = "🚗",
	title = "Pedal Car Racing",
	category = "motorsport",
	tags = {"motorsport", "prep", "childhood"},
	weight = 18,
	conditions = {
		minAge = 3,
		maxAge = 5,
		-- Entry point - no flag requirement
	},
	text = "You race your pedal car against other toddlers. You're obsessed with being fastest.",
	choices = {
		{
			id = "dominate_races",
			text = "Dominate every race. Win everything.",
			resultText = "You become the fastest kid. Parents start noticing.",
			flags = flagSet("motorsport_pedal_champ"),
			traits = traitPayload({ add = {"RACER"} }),
			effects = { Fitness = 1, Happiness = 3 },
		},
		{
			id = "modify_pedal",
			text = "Modify the pedal car. Make it faster.",
			resultText = "You learn basic mechanics. The car becomes a weapon.",
			flags = flagSet("motorsport_early_modder"),
			traits = traitPayload({ add = {"MECHANICAPPT"} }),
			effects = { Smarts = 1, Creativity = 2 },
		},
	},
})

table.insert(events, {
	id = "motorsport_prep_parent_race",
	emoji = "👨‍👩‍👦",
	title = "Parent Race Day",
	category = "motorsport",
	tags = {"motorsport", "prep", "family"},
	weight = 16,
	conditions = {
		minAge = 5,
		maxAge = 8,
		-- More flexible entry
		custom = function(state)
			local flags = state.Flags or {}
			if flags.motorsport_pedal_champ or flags.motorsport_early_modder or flags.motorsport_speed_imprint or flags.motorsport_neighborhood_champ then
				return true
			end
			return math.random() < 0.7
		end,
	},
	text = "Your parents take you to a real race track. You watch from the stands, mesmerized by the speed.",
	choices = {
		{
			id = "beg_to_race",
			text = "Beg to race. Promise to be good forever.",
			resultText = "They see the passion. They start looking into karting programs.",
			flags = flagSet("motorsport_parents_convinced"),
			effects = { Happiness = 5 },
		},
		{
			id = "study_racing",
			text = "Study every car. Memorize the lines.",
			resultText = "You become a student of racing. Knowledge becomes your weapon.",
			flags = flagSet("motorsport_early_student"),
			effects = { Smarts = 2 },
		},
	},
})

table.insert(events, {
	id = "motorsport_prep_scooter_gang",
	emoji = "🛴",
	title = "Scooter Gang",
	category = "motorsport",
	tags = {"motorsport", "prep", "social"},
	weight = 14,
	conditions = {
		minAge = 6,
		maxAge = 9,
		-- Entry point for social racing
	},
	text = "You form a scooter gang with neighborhood kids. You race every day after school.",
	choices = {
		{
			id = "lead_gang",
			text = "Lead the gang. Become the fastest.",
			resultText = "You're the undisputed leader. Respect grows.",
			flags = flagSet("motorsport_gang_leader"),
			traits = traitPayload({ add = {"RACER"} }),
			effects = { Fame = 1, Happiness = 4 },
		},
		{
			id = "teach_others",
			text = "Teach others. Share your knowledge.",
			resultText = "You become a mentor. Leadership skills develop.",
			flags = flagSet("motorsport_early_mentor"),
			effects = { Charisma = 2, Happiness = 3 },
		},
	},
})

table.insert(events, {
	id = "motorsport_prep_soapbox_derby",
	emoji = "📦",
	title = "Soapbox Derby",
	category = "motorsport",
	tags = {"motorsport", "prep", "competition"},
	weight = 15,
	oneTime = true,
	conditions = {
		minAge = 7,
		maxAge = 10,
		-- Entry point - anyone can enter soapbox derby
	},
	text = "Local soapbox derby. You build your car from scratch. This is your first real competition.",
	choices = {
		{
			id = "win_derby",
			text = "Win the derby. Dominate the competition.",
			resultText = "You win by a huge margin. The trophy means everything.",
			flags = flagSet("motorsport_derby_champion"),
			traits = traitPayload({ add = {"RACER"} }),
			effects = { Fame = 2, Happiness = 6 },
		},
		{
			id = "learn_from_loss",
			text = "Lose, but learn. Study the winner.",
			resultText = "You analyze what went wrong. Next year, you'll be ready.",
			flags = flagSet("motorsport_derby_learner"),
			effects = { Smarts = 2, Happiness = 1 },
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- ADDITIONAL KARTING STAGE EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_kart_first_race",
	emoji = "🏁",
	title = "First Kart Race",
	category = "motorsport",
	tags = {"motorsport", "karting", "debut"},
	weight = 16,
	oneTime = true,
	conditions = {
		minAge = 6,
		maxAge = 10,
		-- Entry point - can race even without owning a kart (rental)
		custom = function(state)
			local flags = state.Flags or {}
			if flags.motorsport_first_kart or flags.motorsport_derby_champion or flags.motorsport_neighborhood_champ or flags.motorsport_pedal_champ then
				return true
			end
			-- Still allow, just lower chance (rental kart)
			return math.random() < 0.5
		end,
	},
	text = "Your first official kart race. The grid is full. Your heart pounds. The green flag drops.",
	choices = {
		{
			id = "win_first_race",
			text = "Win your first race. Make history.",
			resultText = "You win! The feeling is indescribable. Racing is your life now.",
			flags = flagSet("motorsport_first_race_winner"),
			startCareer = "motorsport_icon",
			careerXP = 10,
			effects = { Fame = 3, Happiness = 8 },
		},
		{
			id = "learn_from_first",
			text = "Finish mid-pack. Learn from the experience.",
			resultText = "You don't win, but you learn. The hunger grows.",
			flags = flagSet("motorsport_first_race_learner"),
			startCareer = "motorsport_icon",
			careerXP = 5,
			effects = { Smarts = 2, Happiness = 2 },
		},
	},
})

table.insert(events, {
	id = "motorsport_kart_sponsor_local",
	emoji = "💰",
	title = "Local Sponsor",
	category = "motorsport",
	tags = {"motorsport", "karting", "sponsor"},
	weight = 13,
	oneTime = true,
	conditions = {
		minAge = 8,
		maxAge = 12,
		requiredCareerId = "motorsport_icon",
		requiredAnyFlags = {"motorsport_first_race_winner", "motorsport_regional_podium"},
	},
	getDynamicData = function()
		local sponsors = {"Local Auto Shop", "Neighborhood Pizza Place", "Dad's Friend's Business", "Community Center"}
		return { sponsor = sponsors[math.random(#sponsors)] }
	end,
	text = "%sponsor% offers to sponsor you. $500 and free parts. It's not much, but it's a start.",
	choices = {
		{
			id = "accept_sponsor",
			text = "Accept. Every dollar counts.",
			resultText = "You get your first sponsor. The logo goes on your kart.",
			flags = flagSet("motorsport_first_sponsor"),
			effects = { Money = 500, Fame = 2, Happiness = 4 },
		},
		{
			id = "hold_out",
			text = "Hold out for better offers.",
			resultText = "You wait. Better opportunities might come.",
			flags = flagSet("motorsport_sponsor_patient"),
			effects = { Smarts = 1 },
		},
	},
})

table.insert(events, {
	id = "motorsport_kart_rain_master",
	emoji = "🌧️",
	title = "Rain Master",
	category = "motorsport",
	tags = {"motorsport", "karting", "skill"},
	weight = 12,
	cooldownYears = 2,
	conditions = {
		minAge = 9,
		maxAge = 14,
		requiredCareerId = "motorsport_icon",
		requiredAnyFlags = {"motorsport_first_race_winner", "motorsport_regional_podium"},
	},
	text = "A race in pouring rain. Most drivers crash. You stay calm. The track becomes yours.",
	choices = {
		{
			id = "dominate_rain",
			text = "Dominate in the rain. Win by a lap.",
			resultText = "You're untouchable in the wet. Coaches call you a rain master.",
			flags = flagSet("motorsport_rain_master"),
			traits = traitPayload({ add = {"GOODDRIVER"} }),
			careerXP = 30,
			careerReputation = 15,
			effects = { Fame = 4, Happiness = 6 },
		},
		{
			id = "survive_rain",
			text = "Survive. Finish in the points.",
			resultText = "You finish safely. Consistency matters more than heroics.",
			flags = flagSet("motorsport_rain_survivor"),
			careerXP = 20,
			effects = { Smarts = 2, Fame = 2 },
		},
	},
})

table.insert(events, {
	id = "motorsport_kart_team_offer",
	emoji = "🤝",
	title = "Factory Team Offer",
	category = "motorsport",
	tags = {"motorsport", "karting", "team"},
	weight = 11,
	oneTime = true,
	conditions = {
		minAge = 11,
		maxAge = 15,
		requiredCareerId = "motorsport_icon",
		requiredAnyFlags = {"motorsport_national_champion", "motorsport_regional_podium"},
		requiredCareerMinTier = 1,
	},
	getDynamicData = function()
		local teams = {"Kart Factory Racing", "Elite Junior Team", "Championship Karting", "Prodigy Motorsports"}
		return { team = teams[math.random(#teams)] }
	end,
	text = "%team% offers you a factory ride. Free kart, free parts, free coaching. The dream.",
	choices = {
		{
			id = "accept_factory",
			text = "Accept. Join the factory team.",
			resultText = "You join the team. Everything changes. You're a professional now.",
			flags = flagSet("motorsport_factory_kart"),
			careerXP = 40,
			careerReputation = 25,
			promoteCareer = true,
			effects = { Fame = 6, Happiness = 8, Money = 2000 },
		},
		{
			id = "stay_independent",
			text = "Stay independent. Keep your freedom.",
			resultText = "You stay on your own path. Harder, but you control your destiny.",
			flags = flagSet("motorsport_independent_path"),
			careerXP = 30,
			effects = { Happiness = 3, Smarts = 2 },
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- ADDITIONAL JUNIOR_FORMULA EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_junior_qualifying_pole",
	emoji = "⚡",
	title = "First Pole Position",
	category = "motorsport",
	tags = {"motorsport", "junior_formula", "qualifying"},
	weight = 12,
	cooldownYears = 1,
	conditions = {
		minAge = 17,
		maxAge = 21,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 2,
		requiredAnyFlags = {"motorsport_junior_debut", "motorsport_data_driven"},
	},
	text = "You qualify on pole for the first time. The front row. All eyes on you.",
	choices = {
		{
			id = "convert_pole",
			text = "Convert pole to win. Lead from start to finish.",
			resultText = "You win from pole. Dominant performance. The media loves it.",
			flags = flagSet("motorsport_pole_to_win"),
			careerXP = 45,
			careerReputation = 20,
			effects = { Fame = 6, Happiness = 8 },
		},
		{
			id = "lose_lead",
			text = "Lose the lead. Learn from the mistake.",
			resultText = "You finish 3rd. Pole doesn't guarantee victory. You learn.",
			flags = flagSet("motorsport_pole_learner"),
			careerXP = 35,
			effects = { Smarts = 2, Fame = 3 },
		},
	},
})

table.insert(events, {
	id = "motorsport_junior_engine_failure",
	emoji = "🔥",
	title = "Engine Failure",
	category = "motorsport",
	tags = {"motorsport", "junior_formula", "mechanical"},
	weight = 11,
	cooldownYears = 2,
	conditions = {
		minAge = 17,
		maxAge = 22,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 2,
	},
	text = "Leading the race, your engine blows. Smoke everywhere. Championship hopes dashed.",
	choices = {
		{
			id = "blame_team",
			text = "Blame the team. Demand better equipment.",
			resultText = "You create tension. The team respects your passion but questions your maturity.",
			flags = flagSet("motorsport_blames_team"),
			careerXP = 15,
			effects = { Happiness = -3, Fame = 1 },
		},
		{
			id = "stay_positive",
			text = "Stay positive. These things happen.",
			resultText = "Your maturity impresses. Teams notice your professionalism.",
			flags = flagSet("motorsport_professional"),
			careerXP = 25,
			careerReputation = 15,
			effects = { Smarts = 2, Fame = 2 },
		},
	},
})

table.insert(events, {
	id = "motorsport_junior_rival_battle",
	emoji = "⚔️",
	title = "Epic Rival Battle",
	category = "motorsport",
	tags = {"motorsport", "junior_formula", "rivalry"},
	weight = 10,
	cooldownYears = 1,
	conditions = {
		minAge = 18,
		maxAge = 22,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 2,
		requiredAnyFlags = {"motorsport_junior_debut", "motorsport_first_win"},
	},
	getDynamicData = function()
		local rivals = {"Max Verstappen", "Charles Leclerc", "Lando Norris", "George Russell"}
		return { rival = rivals[math.random(#rivals)] }
	end,
	text = "An epic battle with %rival%. 20 laps of wheel-to-wheel racing. The crowd goes wild.",
	choices = {
		{
			id = "win_battle",
			text = "Win the battle. Show your skill.",
			resultText = "You win the battle. The media calls it legendary.",
			flags = flagSet("motorsport_epic_battle_winner"),
			careerXP = 50,
			careerReputation = 25,
			effects = { Fame = 8, Happiness = 10 },
		},
		{
			id = "lose_battle",
			text = "Lose, but gain respect.",
			resultText = "You lose, but the battle earns you respect. You'll get them next time.",
			flags = flagSet("motorsport_epic_battle_learner"),
			careerXP = 40,
			careerReputation = 15,
			effects = { Fame = 5, Smarts = 2 },
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- ADDITIONAL PRO_CIRCUIT EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_pro_endurance_debut",
	emoji = "🌙",
	title = "Endurance Racing Debut",
	category = "motorsport",
	tags = {"motorsport", "pro_circuit", "endurance"},
	weight = 11,
	oneTime = true,
	conditions = {
		minAge = 22,
		maxAge = 30,
		requiredCareerId = "motorsport_icon",
		requiredCareerBranch = "endurance",
		requiredCareerMinTier = 3,
	},
	getDynamicData = function()
		local races = {"24 Hours of Le Mans", "24 Hours of Daytona", "12 Hours of Sebring", "6 Hours of Spa"}
		return { race = races[math.random(#races)] }
	end,
	text = "Your debut in %race%. 24 hours of racing. Your body will break. Your mind must not.",
	choices = {
		{
			id = "survive_endurance",
			text = "Survive. Finish the race.",
			resultText = "You finish. The experience changes you. Endurance racing is your calling.",
			flags = flagSet("motorsport_endurance_finisher"),
			careerXP = 55,
			careerReputation = 30,
			effects = { Health = -5, Fame = 6, Happiness = 7 },
		},
		{
			id = "dominate_endurance",
			text = "Dominate. Win your first endurance race.",
			resultText = "You win! 24 hours of perfection. You're a legend.",
			flags = flagSet("motorsport_endurance_winner"),
			careerXP = 70,
			careerReputation = 45,
			effects = { Health = -8, Fame = 12, Happiness = 12, Money = 300000 },
		},
	},
})

table.insert(events, {
	id = "motorsport_pro_hypercar_contract",
	emoji = "💼",
	title = "Hypercar Factory Contract",
	category = "motorsport",
	tags = {"motorsport", "pro_circuit", "contract"},
	weight = 10,
	oneTime = true,
	conditions = {
		minAge = 24,
		maxAge = 32,
		requiredCareerId = "motorsport_icon",
		requiredCareerBranch = "endurance",
		requiredCareerMinTier = 4,
		requiredAnyFlags = {"motorsport_endurance_finisher", "motorsport_endurance_winner"},
	},
	getDynamicData = function()
		local teams = {"Toyota Gazoo Racing", "Porsche Motorsport", "Ferrari AF Corse", "Cadillac Racing"}
		return { team = teams[math.random(#teams)], salary = math.random(500, 1200) * 1000 }
	end,
	text = "%team% offers you a factory hypercar contract. $%salary% per year. This is the big time.",
	choices = {
		{
			id = "sign_contract",
			text = "Sign. Become a factory driver.",
			resultText = "You sign the contract. Factory driver. The dream achieved.",
			flags = flagSet("motorsport_hypercar_factory"),
			careerXP = 60,
			careerReputation = 40,
			promoteCareer = true,
			effects = { Money = 500000, Fame = 10, Happiness = 12 },
		},
		{
			id = "negotiate_higher",
			text = "Negotiate for more. Know your worth.",
			resultText = "You negotiate. They raise the offer. You get what you deserve.",
			flags = flagSet("motorsport_hypercar_negotiated"),
			careerXP = 65,
			careerReputation = 45,
			effects = { Money = 600000, Fame = 10, Happiness = 12 },
		},
	},
})

table.insert(events, {
	id = "motorsport_pro_f1_contract",
	emoji = "📝",
	title = "F1 Contract Offer",
	category = "motorsport",
	tags = {"motorsport", "pro_circuit", "f1", "contract"},
	weight = 9,
	oneTime = true,
	conditions = {
		minAge = 22,
		maxAge = 30,
		requiredCareerId = "motorsport_icon",
		requiredCareerBranch = "single_seater",
		requiredCareerMinTier = 4,
		requiredAnyFlags = {"motorsport_f1_debut_points", "motorsport_f1_test_ace"},
	},
	getDynamicData = function()
		local teams = {"Red Bull Racing", "Mercedes AMG", "Ferrari", "McLaren", "Alpine"}
		return { team = teams[math.random(#teams)], salary = math.random(1000, 5000) * 1000 }
	end,
	text = "%team% offers you an F1 contract. $%salary% per year. This is Formula 1. The pinnacle.",
	choices = {
		{
			id = "sign_f1",
			text = "Sign. You're an F1 driver.",
			resultText = "You sign. Formula 1 driver. The dream is real.",
			flags = flagSet("motorsport_f1_contract"),
			careerXP = 80,
			careerReputation = 60,
			promoteCareer = true,
			effects = { Money = 2000000, Fame = 20, Happiness = 15 },
		},
		{
			id = "wait_better",
			text = "Wait for a better offer. Top teams might call.",
			resultText = "You wait. A top team calls. Better offer. Smart move.",
			flags = flagSet("motorsport_f1_patient"),
			careerXP = 75,
			careerReputation = 55,
			effects = { Money = 3000000, Fame = 18, Happiness = 14 },
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- ADDITIONAL STREET_RACER EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_street_cop_chase",
	emoji = "🚔",
	title = "Cop Chase",
	category = "motorsport",
	tags = {"motorsport", "street_racer", "illegal", "danger"},
	weight = 11,
	cooldownYears = 2,
	conditions = {
		minAge = 18,
		maxAge = 28,
		requiredCareerId = "motorsport_icon",
		requiredCareerBranch = "street_icon",
		requiredAnyFlags = {"motorsport_street_legend", "motorsport_street_arrested"},
	},
	text = "Cops show up at a street race. Everyone scatters. You're in a high-speed chase.",
	choices = {
		{
			id = "escape_cops",
			text = "Escape. Lose the cops.",
			resultText = "You escape. The legend grows. But you're on their radar now.",
			flags = flagSet("motorsport_street_escape"),
			careerXP = 30,
			effects = { Fame = 5, Karma = -3 },
		},
		{
			id = "get_caught",
			text = "Get caught. Face the consequences.",
			resultText = "You get arrested. Jail time. Racing becomes harder, but you learn.",
			flags = flagSet("motorsport_street_jail"),
			effects = { Fame = 2, Karma = -5, Smarts = 3 },
		},
	},
})

table.insert(events, {
	id = "motorsport_street_drift_king",
	emoji = "💨",
	title = "Drift King",
	category = "motorsport",
	tags = {"motorsport", "street_racer", "skill"},
	weight = 10,
	cooldownYears = 1,
	conditions = {
		minAge = 19,
		maxAge = 30,
		requiredCareerId = "motorsport_icon",
		requiredCareerBranch = "street_icon",
		requiredCareerMinTier = 2,
	},
	text = "A drift competition. You're up against the best. Your car is sideways. The crowd roars.",
	choices = {
		{
			id = "win_drift",
			text = "Win. Become the drift king.",
			resultText = "You win. The drift king. Your name becomes legend.",
			flags = flagSet("motorsport_drift_king"),
			careerXP = 40,
			careerReputation = 25,
			effects = { Fame = 8, Happiness = 10 },
		},
		{
			id = "learn_drift",
			text = "Lose, but learn. Study the winner.",
			resultText = "You lose, but you learn. Next time, you'll be ready.",
			flags = flagSet("motorsport_drift_learner"),
			careerXP = 30,
			effects = { Smarts = 2, Fame = 3 },
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- ADDITIONAL MECHANIC EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_mechanic_impossible_fix",
	emoji = "🔧",
	title = "Impossible Fix",
	category = "motorsport",
	tags = {"motorsport", "mechanic", "skill"},
	weight = 12,
	cooldownYears = 2,
	conditions = {
		minAge = 22,
		maxAge = 35,
		requiredCareerId = "motorsport_icon",
		requiredAnyFlags = {"motorsport_mechanic_path", "motorsport_engine_master"},
		custom = function(state)
			return hasTrait(state, "MECHANICAPPT")
		end,
	},
	text = "A team brings you an impossible problem. Everyone else gave up. You see the solution.",
	choices = {
		{
			id = "solve_impossible",
			text = "Solve it. Prove you're the best.",
			resultText = "You fix it. The team wins the championship. Your reputation explodes.",
			flags = flagSet("motorsport_mechanic_genius"),
			careerXP = 60,
			careerReputation = 50,
			effects = { Money = 200000, Fame = 10, Happiness = 12 },
		},
		{
			id = "learn_from_failure",
			text = "Fail, but learn. Document everything.",
			resultText = "You fail, but you learn. Next time, you'll know.",
			flags = flagSet("motorsport_mechanic_learner"),
			careerXP = 40,
			effects = { Smarts = 3, Money = 50000 },
		},
	},
})

table.insert(events, {
	id = "motorsport_mechanic_f1_offer",
	emoji = "🏎️",
	title = "F1 Team Offer",
	category = "motorsport",
	tags = {"motorsport", "mechanic", "f1"},
	weight = 10,
	oneTime = true,
	conditions = {
		minAge = 25,
		maxAge = 40,
		requiredCareerId = "motorsport_icon",
		requiredAnyFlags = {"motorsport_mechanic_genius", "motorsport_mechanic_legend"},
	},
	getDynamicData = function()
		local teams = {"Red Bull Racing", "Mercedes AMG", "Ferrari", "McLaren"}
		return { team = teams[math.random(#teams)], salary = math.random(200, 500) * 1000 }
	end,
	text = "%team% offers you a position as lead mechanic. $%salary% per year. F1. The pinnacle.",
	choices = {
		{
			id = "accept_f1",
			text = "Accept. Join F1.",
			resultText = "You join F1. The pinnacle of motorsport. Your dream achieved.",
			flags = flagSet("motorsport_mechanic_f1"),
			careerXP = 70,
			careerReputation = 60,
			effects = { Money = 300000, Fame = 12, Happiness = 15 },
		},
		{
			id = "stay_independent",
			text = "Stay independent. Keep your freedom.",
			resultText = "You stay independent. More money, more freedom. Smart move.",
			flags = flagSet("motorsport_mechanic_independent"),
			careerXP = 60,
			effects = { Money = 390000, Happiness = 12 },
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- MORE DEATH SCENARIOS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_death_testing",
	emoji = "💀",
	title = "Fatal Testing Crash",
	category = "motorsport",
	tags = {"motorsport", "death", "testing"},
	weight = 2,
	oneTime = true,
	conditions = {
		minAge = 20,
		maxAge = 35,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 4,
		custom = function(state)
			return hasTrait(state, "RECKLESS") and (state.Stats and (state.Stats.Health or 100) < 40)
		end,
	},
	text = "During testing, you push too hard. The car fails. The crash is fatal. Testing claims another life.",
	choices = {
		{
			id = "death",
			text = "Your life ends on the test track.",
			resultText = "You die doing what you loved. The racing world mourns.",
			effects = { Health = -100 },
			flags = flagSet("death_testing_fatal"),
		},
	},
})

table.insert(events, {
	id = "motorsport_death_endurance",
	emoji = "💀",
	title = "Fatal Endurance Crash",
	category = "motorsport",
	tags = {"motorsport", "death", "endurance"},
	weight = 2,
	oneTime = true,
	conditions = {
		minAge = 24,
		maxAge = 40,
		requiredCareerId = "motorsport_icon",
		requiredCareerBranch = "endurance",
		requiredCareerMinTier = 4,
		custom = function(state)
			return (state.Stats and (state.Stats.Health or 100) < 30) and hasTrait(state, "THRILLSEEKER")
		end,
	},
	text = "During a 24-hour race, fatigue sets in. You make a mistake. The crash is fatal. Endurance racing claims you.",
	choices = {
		{
			id = "death",
			text = "Your life ends in an endurance race.",
			resultText = "You die pushing the limits. The racing world mourns.",
			effects = { Health = -100 },
			flags = flagSet("death_endurance_fatal"),
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- EXPANDED PREP STAGE - MORE CHILDHOOD EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_prep_toy_car_collection",
	emoji = "🚗",
	title = "Toy Car Collection",
	category = "motorsport",
	tags = {"motorsport", "prep", "childhood"},
	weight = 17,
	conditions = {
		minAge = 4,
		maxAge = 7,
		-- Entry point - anyone can collect toy cars
	},
	text = "You collect toy race cars. Every birthday, every holiday, you ask for more. Your room becomes a museum.",
	choices = {
		{
			id = "study_cars",
			text = "Study every car. Learn the makes and models.",
			resultText = "You become a walking encyclopedia of cars. Knowledge becomes power.",
			flags = flagSet("motorsport_car_expert"),
			effects = { Smarts = 2, Creativity = 1 },
		},
		{
			id = "race_toys",
			text = "Race them. Create championships.",
			resultText = "You create elaborate race series. Your imagination runs wild.",
			flags = flagSet("motorsport_toy_racer"),
			traits = traitPayload({ add = {"RACER"} }),
			effects = { Creativity = 2, Happiness = 3 },
		},
	},
})

table.insert(events, {
	id = "motorsport_prep_racing_video_games",
	emoji = "🎮",
	title = "Racing Video Games",
	category = "motorsport",
	tags = {"motorsport", "prep", "gaming"},
	weight = 16,
	conditions = {
		minAge = 6,
		maxAge = 10,
		-- Entry point - kids play video games
		custom = function(state)
			local flags = state.Flags or {}
			if flags.motorsport_car_expert or flags.motorsport_toy_racer or flags.motorsport_pedal_champ or flags.motorsport_neighborhood_champ then
				return true
			end
			-- Still allow, just lower chance
			return math.random() < 0.6
		end,
	},
	text = "You discover racing video games. You play for hours. Every track, every car, you master them all.",
	choices = {
		{
			id = "master_games",
			text = "Master every game. Become the best.",
			resultText = "You become unbeatable. The skills transfer to real racing.",
			flags = flagSet("motorsport_game_master"),
			effects = { Smarts = 2, TechSkill = 2 },
		},
		{
			id = "study_tracks",
			text = "Study real tracks in games. Learn the lines.",
			resultText = "You memorize every corner. When you race for real, you're ready.",
			flags = flagSet("motorsport_track_master"),
			traits = traitPayload({ add = {"DATA_STRATEGIST"} }),
			effects = { Smarts = 3 },
		},
	},
})

table.insert(events, {
	id = "motorsport_prep_racing_movies",
	emoji = "🎬",
	title = "Racing Movies",
	category = "motorsport",
	tags = {"motorsport", "prep", "media"},
	weight = 15,
	conditions = {
		minAge = 7,
		maxAge = 11,
		-- Entry point - kids watch movies
		custom = function(state)
			local flags = state.Flags or {}
			if flags.motorsport_game_master or flags.motorsport_track_master or flags.motorsport_car_expert or flags.motorsport_toy_racer then
				return true
			end
			return math.random() < 0.5
		end,
	},
	text = "You watch every racing movie. Fast & Furious, Days of Thunder, Rush. You memorize every line.",
	choices = {
		{
			id = "inspire_racing",
			text = "Get inspired. Racing becomes your dream.",
			resultText = "The movies fuel your passion. You know what you want to be.",
			flags = flagSet("motorsport_movie_inspired"),
			traits = traitPayload({ add = {"RACER", "THRILLSEEKER"} }),
			effects = { Happiness = 4, Fame = 1 },
		},
		{
			id = "study_technique",
			text = "Study the racing techniques. Learn from the pros.",
			resultText = "You analyze every move. The knowledge helps when you race for real.",
			flags = flagSet("motorsport_technique_student"),
			effects = { Smarts = 2 },
		},
	},
})

table.insert(events, {
	id = "motorsport_prep_racing_books",
	emoji = "📚",
	title = "Racing Books",
	category = "motorsport",
	tags = {"motorsport", "prep", "education"},
	weight = 14,
	conditions = {
		minAge = 8,
		maxAge = 12,
		-- Entry point - kids read books
		custom = function(state)
			local flags = state.Flags or {}
			if flags.motorsport_movie_inspired or flags.motorsport_technique_student or flags.motorsport_car_expert or flags.motorsport_toy_racer then
				return true
			end
			return math.random() < 0.4
		end,
	},
	text = "You read every racing book you can find. Biographies, technical manuals, history. You devour it all.",
	choices = {
		{
			id = "learn_history",
			text = "Learn racing history. Study the legends.",
			resultText = "You know every champion, every race, every story. Knowledge becomes your weapon.",
			flags = flagSet("motorsport_racing_historian"),
			effects = { Smarts = 3, Fame = 1 },
		},
		{
			id = "study_engineering",
			text = "Study engineering. Learn how cars work.",
			resultText = "You understand engines, aerodynamics, everything. You become a technical genius.",
			flags = flagSet("motorsport_engineering_student"),
			traits = traitPayload({ add = {"MECHANICAPPT"} }),
			effects = { Smarts = 4 },
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- EXPANDED KARTING STAGE - MORE COMPETITIVE EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_kart_wet_race",
	emoji = "🌧️",
	title = "Wet Weather Master",
	category = "motorsport",
	tags = {"motorsport", "karting", "weather"},
	weight = 13,
	cooldownYears = 2,
	conditions = {
		minAge = 9,
		maxAge = 14,
		requiredCareerId = "motorsport_icon",
		requiredAnyFlags = {"motorsport_first_race_winner", "motorsport_regional_podium"},
	},
	text = "A race in pouring rain. Most drivers crash out. You stay calm. The wet track becomes your playground.",
	choices = {
		{
			id = "dominate_wet",
			text = "Dominate in the wet. Win by a huge margin.",
			resultText = "You're untouchable in the rain. Coaches call you a rain master.",
			flags = flagSet("motorsport_wet_master"),
			traits = traitPayload({ add = {"GOODDRIVER"} }),
			careerXP = 35,
			careerReputation = 20,
			effects = { Fame = 5, Happiness = 7 },
		},
		{
			id = "survive_wet",
			text = "Survive. Finish safely in the points.",
			resultText = "You finish safely. Consistency matters more than heroics.",
			flags = flagSet("motorsport_wet_survivor"),
			careerXP = 25,
			effects = { Smarts = 2, Fame = 2 },
		},
	},
})

table.insert(events, {
	id = "motorsport_kart_overtake_master",
	emoji = "⚡",
	title = "Overtaking Master",
	category = "motorsport",
	tags = {"motorsport", "karting", "skill"},
	weight = 12,
	cooldownYears = 1,
	conditions = {
		minAge = 10,
		maxAge = 15,
		requiredCareerId = "motorsport_icon",
		requiredAnyFlags = {"motorsport_first_race_winner", "motorsport_regional_podium"},
	},
	text = "You start last. By lap 5, you're in the lead. Your overtaking skills are legendary.",
	choices = {
		{
			id = "win_from_last",
			text = "Win from last. Make history.",
			resultText = "You win from last place. The media calls it legendary.",
			flags = flagSet("motorsport_overtake_legend"),
			careerXP = 45,
			careerReputation = 25,
			effects = { Fame = 7, Happiness = 9 },
		},
		{
			id = "podium_from_last",
			text = "Finish on the podium. Impressive recovery.",
			resultText = "You finish 3rd from last. The recovery impresses everyone.",
			flags = flagSet("motorsport_overtake_podium"),
			careerXP = 35,
			careerReputation = 15,
			effects = { Fame = 4, Happiness = 5 },
		},
	},
})

table.insert(events, {
	id = "motorsport_kart_defensive_master",
	emoji = "🛡️",
	title = "Defensive Master",
	category = "motorsport",
	tags = {"motorsport", "karting", "skill"},
	weight = 11,
	cooldownYears = 1,
	conditions = {
		minAge = 10,
		maxAge = 15,
		requiredCareerId = "motorsport_icon",
		requiredAnyFlags = {"motorsport_first_race_winner", "motorsport_regional_podium"},
	},
	text = "You're leading. A faster driver is behind you. You defend perfectly. They can't pass.",
	choices = {
		{
			id = "win_defensive",
			text = "Win with perfect defense. Show your skill.",
			resultText = "You win with perfect defense. Coaches praise your racecraft.",
			flags = flagSet("motorsport_defensive_master"),
			traits = traitPayload({ add = {"GOODDRIVER"} }),
			careerXP = 40,
			careerReputation = 20,
			effects = { Fame = 5, Happiness = 7 },
		},
		{
			id = "lose_but_learn",
			text = "Lose, but learn. Study their moves.",
			resultText = "You lose, but you learn. Next time, you'll be ready.",
			flags = flagSet("motorsport_defensive_learner"),
			careerXP = 30,
			effects = { Smarts = 2, Fame = 2 },
		},
	},
})

table.insert(events, {
	id = "motorsport_kart_mechanical_issue",
	emoji = "🔧",
	title = "Mechanical Issue",
	category = "motorsport",
	tags = {"motorsport", "karting", "mechanical"},
	weight = 10,
	cooldownYears = 2,
	conditions = {
		minAge = 9,
		maxAge = 14,
		requiredCareerId = "motorsport_icon",
		requiredAnyFlags = {"motorsport_first_race_winner", "motorsport_regional_podium"},
	},
	text = "Your kart develops a problem mid-race. You're losing positions. Do you pit or push through?",
	choices = {
		{
			id = "pit_fix",
			text = "Pit and fix it. Finish the race.",
			resultText = "You pit, fix the issue, and finish. Smart racing.",
			flags = flagSet("motorsport_mechanical_smart"),
			careerXP = 25,
			effects = { Smarts = 2, Fame = 1 },
		},
		{
			id = "push_through",
			text = "Push through. Risk it all.",
			resultText = "You push through. The kart fails. You learn the hard way.",
			flags = flagSet("motorsport_mechanical_risky"),
			careerXP = 15,
			effects = { Happiness = -2, Smarts = 1 },
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- EXPANDED JUNIOR_FORMULA EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_junior_qualifying_struggle",
	emoji = "😓",
	title = "Qualifying Struggle",
	category = "motorsport",
	tags = {"motorsport", "junior_formula", "struggle"},
	weight = 11,
	cooldownYears = 1,
	conditions = {
		minAge = 17,
		maxAge = 21,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 2,
		requiredAnyFlags = {"motorsport_junior_debut", "motorsport_data_driven"},
	},
	text = "You struggle in qualifying. The car doesn't feel right. You're starting near the back.",
	choices = {
		{
			id = "study_data",
			text = "Study the data. Find the problem.",
			resultText = "You find the issue. The race goes better. You learn from adversity.",
			flags = flagSet("motorsport_data_problem_solver"),
			traits = traitPayload({ add = {"DATA_STRATEGIST"} }),
			careerXP = 30,
			effects = { Smarts = 3, Fame = 2 },
		},
		{
			id = "push_harder",
			text = "Push harder. Overdrive the car.",
			resultText = "You push too hard. You crash. The team questions your judgment.",
			flags = flagSet("motorsport_overdrive_crash"),
			careerXP = 15,
			effects = { Happiness = -3, Fame = -1 },
		},
	},
})

table.insert(events, {
	id = "motorsport_junior_strategy_master",
	emoji = "🧠",
	title = "Strategy Master",
	category = "motorsport",
	tags = {"motorsport", "junior_formula", "strategy"},
	weight = 10,
	cooldownYears = 1,
	conditions = {
		minAge = 18,
		maxAge = 22,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 2,
		requiredAnyFlags = {"motorsport_junior_debut", "motorsport_data_driven"},
	},
	text = "A race with changing conditions. You make the perfect strategy call. You win because of it.",
	choices = {
		{
			id = "win_strategy",
			text = "Win with perfect strategy. Show your intelligence.",
			resultText = "You win with perfect strategy. Teams notice your race intelligence.",
			flags = flagSet("motorsport_strategy_master"),
			traits = traitPayload({ add = {"DATA_STRATEGIST"} }),
			careerXP = 50,
			careerReputation = 30,
			effects = { Fame = 8, Happiness = 10 },
		},
		{
			id = "podium_strategy",
			text = "Finish on the podium. Good strategy call.",
			resultText = "You finish 3rd. The strategy call was good, but not perfect.",
			flags = flagSet("motorsport_strategy_good"),
			careerXP = 40,
			careerReputation = 20,
			effects = { Fame = 5, Happiness = 6 },
		},
	},
})

table.insert(events, {
	id = "motorsport_junior_team_mate_battle",
	emoji = "⚔️",
	title = "Teammate Battle",
	category = "motorsport",
	tags = {"motorsport", "junior_formula", "team"},
	weight = 9,
	cooldownYears = 1,
	conditions = {
		minAge = 18,
		maxAge = 22,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 2,
		requiredAnyFlags = {"motorsport_junior_debut", "motorsport_data_driven"},
	},
	getDynamicData = function()
		local teammates = {"Alex", "Jordan", "Sam", "Casey"}
		return { teammate = teammates[math.random(#teammates)] }
	end,
	text = "You and %teammate% are fighting for position. Same team, same car. Who gives way?",
	choices = {
		{
			id = "fight_fair",
			text = "Fight fair. Let the best driver win.",
			resultText = "You fight fair. The team respects both of you. Healthy competition.",
			flags = flagSet("motorsport_fair_teammate"),
			careerXP = 35,
			careerReputation = 15,
			effects = { Fame = 3, Happiness = 4 },
		},
		{
			id = "dirty_move",
			text = "Make a dirty move. Win at any cost.",
			resultText = "You make a dirty move. You win, but the team questions your ethics.",
			flags = flagSet("motorsport_dirty_teammate"),
			traits = traitPayload({ add = {"RECKLESS"} }),
			careerXP = 40,
			effects = { Fame = 2, Karma = -2 },
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- EXPANDED PRO_CIRCUIT EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_pro_f1_pole_position",
	emoji = "⚡",
	title = "F1 Pole Position",
	category = "motorsport",
	tags = {"motorsport", "pro_circuit", "f1", "qualifying"},
	weight = 10,
	cooldownYears = 1,
	conditions = {
		minAge = 22,
		maxAge = 32,
		requiredCareerId = "motorsport_icon",
		requiredCareerBranch = "single_seater",
		requiredCareerMinTier = 4,
		requiredAnyFlags = {"motorsport_f1_debut_points", "motorsport_f1_test_ace"},
	},
	text = "You qualify on pole for an F1 race. The front row. The world watches. This is your moment.",
	choices = {
		{
			id = "convert_pole_win",
			text = "Convert pole to win. Lead from start to finish.",
			resultText = "You win from pole. Dominant performance. The media calls it perfect.",
			flags = flagSet("motorsport_f1_pole_to_win"),
			careerXP = 75,
			careerReputation = 50,
			effects = { Fame = 15, Happiness = 12, Money = 300000 },
		},
		{
			id = "lose_lead",
			text = "Lose the lead. Learn from the mistake.",
			resultText = "You finish 3rd. Pole doesn't guarantee victory. You learn.",
			flags = flagSet("motorsport_f1_pole_learner"),
			careerXP = 60,
			effects = { Smarts = 2, Fame = 8 },
		},
	},
})

table.insert(events, {
	id = "motorsport_pro_f1_wet_race",
	emoji = "🌧️",
	title = "F1 Wet Weather Race",
	category = "motorsport",
	tags = {"motorsport", "pro_circuit", "f1", "weather"},
	weight = 9,
	cooldownYears = 2,
	conditions = {
		minAge = 22,
		maxAge = 32,
		requiredCareerId = "motorsport_icon",
		requiredCareerBranch = "single_seater",
		requiredCareerMinTier = 4,
		requiredAnyFlags = {"motorsport_f1_debut_points", "motorsport_f1_test_ace"},
	},
	text = "An F1 race in pouring rain. The track is treacherous. Most drivers crash. You stay calm.",
	choices = {
		{
			id = "win_wet",
			text = "Win in the wet. Show your skill.",
			resultText = "You win in the wet. The media calls you a rain master. Legendary performance.",
			flags = flagSet("motorsport_f1_wet_winner"),
			traits = traitPayload({ add = {"GOODDRIVER"} }),
			careerXP = 80,
			careerReputation = 55,
			effects = { Fame = 18, Happiness = 14, Money = 400000 },
		},
		{
			id = "survive_wet",
			text = "Survive. Finish in the points.",
			resultText = "You finish safely in the points. Consistency matters more than heroics.",
			flags = flagSet("motorsport_f1_wet_survivor"),
			careerXP = 65,
			effects = { Smarts = 2, Fame = 10 },
		},
	},
})

table.insert(events, {
	id = "motorsport_pro_f1_championship_battle",
	emoji = "🥇",
	title = "F1 Championship Battle",
	category = "motorsport",
	tags = {"motorsport", "pro_circuit", "f1", "championship"},
	weight = 8,
	cooldownYears = 2,
	conditions = {
		minAge = 24,
		maxAge = 35,
		requiredCareerId = "motorsport_icon",
		requiredCareerBranch = "single_seater",
		requiredCareerMinTier = 5,
		requiredAnyFlags = {"motorsport_f1_winner", "motorsport_f1_professional"},
	},
	getDynamicData = function()
		local rivals = {"Lewis Hamilton", "Max Verstappen", "Charles Leclerc", "Lando Norris"}
		return { rival = rivals[math.random(#rivals)] }
	end,
	text = "You and %rival% are fighting for the championship. Every race matters. The pressure is immense.",
	choices = {
		{
			id = "win_championship",
			text = "Win the championship. Become a legend.",
			resultText = "You win the championship. F1 World Champion. Immortality achieved.",
			flags = flagSet("motorsport_f1_champion", "racing_legend"),
			careerXP = 100,
			careerReputation = 80,
			effects = { Fame = 30, Happiness = 20, Money = 5000000 },
			traits = traitPayload({ add = {"MENTOR_DRIVER"} }),
		},
		{
			id = "lose_championship",
			text = "Lose by a point. Heartbreak.",
			resultText = "You finish 2nd in championship. The pain drives you. Next year, you'll be ready.",
			flags = flagSet("motorsport_f1_runner_up"),
			careerXP = 80,
			careerReputation = 60,
			effects = { Fame = 20, Happiness = -5, Smarts = 3 },
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- EXPANDED STREET_RACER EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_street_underground_legend",
	emoji = "👑",
	title = "Underground Legend",
	category = "motorsport",
	tags = {"motorsport", "street_racer", "legend"},
	weight = 10,
	oneTime = true,
	conditions = {
		minAge = 20,
		maxAge = 30,
		requiredCareerId = "motorsport_icon",
		requiredCareerBranch = "street_icon",
		requiredCareerMinTier = 3,
		requiredAnyFlags = {"motorsport_street_legend", "motorsport_drift_king"},
	},
	text = "You've become a legend in the underground scene. Your name is whispered in every garage. Respect is earned.",
	choices = {
		{
			id = "embrace_legend",
			text = "Embrace the legend. Own your status.",
			resultText = "You become the undisputed king of the underground. Your legend grows.",
			flags = flagSet("motorsport_underground_king"),
			careerXP = 60,
			careerReputation = 40,
			effects = { Fame = 12, Happiness = 12 },
		},
		{
			id = "stay_humble",
			text = "Stay humble. Keep racing.",
			resultText = "You stay humble. The scene respects your character. True legend.",
			flags = flagSet("motorsport_humble_legend"),
			careerXP = 55,
			careerReputation = 45,
			effects = { Fame = 10, Happiness = 10, Karma = 2 },
		},
	},
})

table.insert(events, {
	id = "motorsport_street_legal_transition",
	emoji = "🏁",
	title = "Legal Racing Transition",
	category = "motorsport",
	tags = {"motorsport", "street_racer", "transition"},
	weight = 9,
	oneTime = true,
	conditions = {
		minAge = 22,
		maxAge = 32,
		requiredCareerId = "motorsport_icon",
		requiredCareerBranch = "street_icon",
		requiredCareerMinTier = 3,
		requiredAnyFlags = {"motorsport_street_to_legal", "motorsport_underground_king"},
	},
	text = "You've made the transition to legal racing. The skills transfer. You're winning on the track now.",
	choices = {
		{
			id = "dominate_legal",
			text = "Dominate legal racing. Show your skill.",
			resultText = "You dominate legal racing. The transition is complete. You're a pro now.",
			flags = flagSet("motorsport_legal_dominator"),
			careerXP = 70,
			careerReputation = 50,
			effects = { Fame = 15, Happiness = 14, Money = 200000 },
		},
		{
			id = "struggle_legal",
			text = "Struggle with legal racing. It's different.",
			resultText = "You struggle. Legal racing is different. You learn and adapt.",
			flags = flagSet("motorsport_legal_learner"),
			careerXP = 50,
			effects = { Smarts = 3, Fame = 8 },
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- EXPANDED MECHANIC EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_mechanic_championship_win",
	emoji = "🏆",
	title = "Championship-Winning Mechanic",
	category = "motorsport",
	tags = {"motorsport", "mechanic", "championship"},
	weight = 11,
	oneTime = true,
	conditions = {
		minAge = 25,
		maxAge = 40,
		requiredCareerId = "motorsport_icon",
		requiredAnyFlags = {"motorsport_mechanic_genius", "motorsport_mechanic_legend"},
	},
	text = "Your team wins the championship. Your work made it possible. You're a championship-winning mechanic.",
	choices = {
		{
			id = "celebrate_win",
			text = "Celebrate. You earned this.",
			resultText = "You celebrate. The championship is yours too. You're a legend.",
			flags = flagSet("motorsport_mechanic_champion"),
			careerXP = 80,
			careerReputation = 70,
			effects = { Fame = 15, Happiness = 15, Money = 300000 },
		},
		{
			id = "stay_humble",
			text = "Stay humble. The driver gets the glory.",
			resultText = "You stay humble. The team respects your character. True professional.",
			flags = flagSet("motorsport_mechanic_humble"),
			careerXP = 75,
			careerReputation = 65,
			effects = { Fame = 12, Happiness = 12, Karma = 3 },
		},
	},
})

table.insert(events, {
	id = "motorsport_mechanic_team_principal",
	emoji = "👔",
	title = "Team Principal Offer",
	category = "motorsport",
	tags = {"motorsport", "mechanic", "leadership"},
	weight = 10,
	oneTime = true,
	conditions = {
		minAge = 30,
		maxAge = 45,
		requiredCareerId = "motorsport_icon",
		requiredAnyFlags = {"motorsport_mechanic_champion", "motorsport_team_owner"},
	},
	text = "A team offers you the position of team principal. Lead the team. Make the decisions. The ultimate role.",
	choices = {
		{
			id = "accept_principal",
			text = "Accept. Become team principal.",
			resultText = "You become team principal. Leadership. The ultimate achievement.",
			flags = flagSet("motorsport_team_principal"),
			careerXP = 90,
			careerReputation = 80,
			effects = { Money = 500000, Fame = 20, Happiness = 18 },
		},
		{
			id = "stay_mechanic",
			text = "Stay a mechanic. Master your craft.",
			resultText = "You stay a mechanic. Perfection. The best in the world.",
			flags = flagSet("motorsport_mechanic_master_final"),
			careerXP = 85,
			effects = { Money = 300000, Happiness = 15 },
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- MORE VEHICLE PURCHASE EVENTS
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_vehicle_track_car",
	emoji = "🏎️",
	title = "Track Car Purchase",
	category = "motorsport",
	tags = {"motorsport", "vehicle", "track"},
	weight = 9,
	oneTime = true,
	conditions = {
		minAge = 20,
		maxAge = 35,
		requiredCareerId = "motorsport_icon",
		minMoney = 50000,
		requiredAnyFlags = {"motorsport_premium_vehicle", "motorsport_first_car"},
	},
	getDynamicData = function()
		local vehicles = {
			{make = "Porsche", model = "Cayman GT4", price = 85000, condition = "track_ready"},
			{make = "BMW", model = "M2 Competition", price = 60000, condition = "track_ready"},
			{make = "Audi", model = "RS3", price = 55000, condition = "track_ready"},
			{make = "Toyota", model = "Supra", price = 50000, condition = "track_ready"},
		}
		local v = vehicles[math.random(#vehicles)]
		return { make = v.make, model = v.model, price = v.price, condition = v.condition }
	end,
	text = "You've saved enough for a dedicated track car: a %condition% %make% %model% for $%price%. Pure performance.",
	choices = {
		{
			id = "buy_track_car",
			text = "Buy it. Track days await.",
			resultText = "You buy the track car. Pure performance. Track days become your escape.",
			flags = flagSet("motorsport_track_car_owner"),
			addAsset = {
				type = "vehicle",
				make = "%make%",
				model = "%model%",
				value = 60000,
				condition = "%condition%",
			},
			effects = { Money = -60000, Happiness = 10, Fame = 4 },
		},
		{
			id = "invest_career",
			text = "Invest in your career. Track cars can wait.",
			resultText = "You invest in your career. Smart move. Track cars come later.",
			effects = { Money = 25000, careerXP = 30 },
		},
	},
})

table.insert(events, {
	id = "motorsport_vehicle_collection",
	emoji = "🚗",
	title = "Car Collection",
	category = "motorsport",
	tags = {"motorsport", "vehicle", "collection"},
	weight = 8,
	oneTime = true,
	conditions = {
		minAge = 28,
		maxAge = 45,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 5,
		minMoney = 500000,
		requiredAnyFlags = {"motorsport_supercar_owner", "motorsport_track_car_owner"},
	},
	getDynamicData = function()
		local collections = {
			{type = "classic", price = 300000, cars = "vintage racers"},
			{type = "modern", price = 400000, cars = "supercars"},
			{type = "mixed", price = 350000, cars = "classic and modern"},
		}
		local c = collections[math.random(#collections)]
		return { type = c.type, price = c.price, cars = c.cars }
	end,
	text = "You've made it. Time to start a car collection. A %type% collection of %cars% for $%price%. The dream.",
	choices = {
		{
			id = "buy_collection",
			text = "Buy the collection. Live the dream.",
			resultText = "You buy the collection. Your garage becomes a museum. The dream achieved.",
			flags = flagSet("motorsport_collection_owner"),
			effects = { Money = -350000, Happiness = 15, Fame = 8 },
		},
		{
			id = "invest_wisely",
			text = "Invest the money. Collections can wait.",
			resultText = "You invest wisely. Financial security first. Collections come later.",
			effects = { Money = 200000, Smarts = 3 },
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- FINAL BATCH: COMPREHENSIVE EVENTS FOR ALL STAGES
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_prep_racing_camp",
	emoji = "🏕️",
	title = "Racing Camp",
	category = "motorsport",
	tags = {"motorsport", "prep", "training"},
	weight = 15,
	oneTime = true,
	conditions = {
		minAge = 8,
		maxAge = 12,
		requiredAnyFlags = {"motorsport_parents_convinced", "motorsport_derby_champion"},
		minMoney = 500,
	},
	text = "A summer racing camp. Professional coaching. Other kids with the same dream. This is your chance.",
	choices = {
		{
			id = "excel_camp",
			text = "Excel at camp. Show your talent.",
			resultText = "You excel. Coaches notice. Opportunities open up.",
			flags = flagSet("motorsport_camp_star"),
			careerXP = 20,
			effects = { Fame = 3, Happiness = 6, Money = -500 },
		},
		{
			id = "learn_camp",
			text = "Learn everything. Absorb the knowledge.",
			resultText = "You learn everything. The knowledge helps your career.",
			flags = flagSet("motorsport_camp_learner"),
			effects = { Smarts = 3, Money = -500 },
		},
	},
})

table.insert(events, {
	id = "motorsport_kart_international",
	emoji = "🌍",
	title = "International Karting",
	category = "motorsport",
	tags = {"motorsport", "karting", "international"},
	weight = 10,
	oneTime = true,
	conditions = {
		minAge = 13,
		maxAge = 16,
		requiredCareerId = "motorsport_icon",
		requiredAnyFlags = {"motorsport_national_champion", "motorsport_factory_kart"},
		requiredCareerMinTier = 1,
	},
	getDynamicData = function()
		local countries = {"Italy", "France", "Germany", "Spain"}
		return { country = countries[math.random(#countries)] }
	end,
	text = "An international karting championship in %country%. The best drivers in the world. This is the big time.",
	choices = {
		{
			id = "win_international",
			text = "Win the international championship. Make history.",
			resultText = "You win. International champion. The world notices.",
			flags = flagSet("motorsport_international_champion"),
			careerXP = 60,
			careerReputation = 40,
			promoteCareer = true,
			effects = { Fame = 12, Happiness = 15, Money = 10000 },
		},
		{
			id = "podium_international",
			text = "Finish on the podium. Impressive result.",
			resultText = "You finish 3rd. Impressive. Good teams notice.",
			flags = flagSet("motorsport_international_podium"),
			careerXP = 50,
			careerReputation = 30,
			effects = { Fame = 8, Happiness = 10 },
		},
	},
})

table.insert(events, {
	id = "motorsport_junior_media_darling",
	emoji = "📺",
	title = "Media Attention",
	category = "motorsport",
	tags = {"motorsport", "junior_formula", "media"},
	weight = 10,
	cooldownYears = 1,
	conditions = {
		minAge = 18,
		maxAge = 22,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 2,
		requiredAnyFlags = {"motorsport_junior_first_win", "motorsport_junior_champion"},
	},
	text = "The media starts following you. Interviews, features, documentaries. You're becoming a star.",
	choices = {
		{
			id = "embrace_media",
			text = "Embrace the media. Build your brand.",
			resultText = "You embrace the media. Your brand grows. Sponsors love it.",
			flags = flagSet("motorsport_media_darling"),
			traits = traitPayload({ add = {"MEDIA_DARLING"} }),
			careerXP = 30,
			effects = { Fame = 8, Money = 50000 },
		},
		{
			id = "focus_racing",
			text = "Focus on racing. Media can wait.",
			resultText = "You focus on racing. The media respects your dedication.",
			flags = flagSet("motorsport_racing_focused"),
			careerXP = 35,
			effects = { Smarts = 2, Fame = 4 },
		},
	},
})

table.insert(events, {
	id = "motorsport_pro_f1_contract_renewal",
	emoji = "📝",
	title = "F1 Contract Renewal",
	category = "motorsport",
	tags = {"motorsport", "pro_circuit", "f1", "contract"},
	weight = 9,
	cooldownYears = 2,
	conditions = {
		minAge = 24,
		maxAge = 35,
		requiredCareerId = "motorsport_icon",
		requiredCareerBranch = "single_seater",
		requiredCareerMinTier = 4,
		requiredAnyFlags = {"motorsport_f1_contract", "motorsport_f1_winner"},
	},
	getDynamicData = function()
		local salaries = {min = 2000, max = 8000}
		return { salary = math.random(salaries.min, salaries.max) * 1000 }
	end,
	text = "Your F1 contract is up for renewal. They offer $%salary% per year. Do you sign or negotiate?",
	choices = {
		{
			id = "sign_renewal",
			text = "Sign. Stay with the team.",
			resultText = "You sign. Stability. The team appreciates your loyalty.",
			flags = flagSet("motorsport_f1_renewed"),
			careerXP = 50,
			careerReputation = 30,
			effects = { Money = 2000000, Happiness = 8 },
		},
		{
			id = "negotiate_higher",
			text = "Negotiate for more. Know your worth.",
			resultText = "You negotiate. They raise the offer. You get what you deserve.",
			flags = flagSet("motorsport_f1_negotiated"),
			careerXP = 55,
			careerReputation = 35,
			effects = { Money = 2600000, Happiness = 9 },
		},
	},
})

table.insert(events, {
	id = "motorsport_street_legal_series",
	emoji = "🏁",
	title = "Legal Street Racing Series",
	category = "motorsport",
	tags = {"motorsport", "street_racer", "legal"},
	weight = 9,
	oneTime = true,
	conditions = {
		minAge = 22,
		maxAge = 32,
		requiredCareerId = "motorsport_icon",
		requiredCareerBranch = "street_icon",
		requiredCareerMinTier = 3,
		requiredAnyFlags = {"motorsport_street_to_legal", "motorsport_legal_dominator"},
	},
	text = "A legal street racing series launches. Closed courses, safety, but the same style. You're invited.",
	choices = {
		{
			id = "join_series",
			text = "Join the series. Make it legitimate.",
			resultText = "You join. The series becomes huge. You're a founding member.",
			flags = flagSet("motorsport_legal_series_founder"),
			careerXP = 65,
			careerReputation = 45,
			effects = { Fame = 12, Money = 150000, Happiness = 12 },
		},
		{
			id = "stay_underground",
			text = "Stay underground. Keep it real.",
			resultText = "You stay underground. The scene respects your loyalty.",
			flags = flagSet("motorsport_underground_loyal"),
			careerXP = 55,
			effects = { Fame = 8, Karma = -1 },
		},
	},
})

table.insert(events, {
	id = "motorsport_mechanic_innovation",
	emoji = "💡",
	title = "Mechanical Innovation",
	category = "motorsport",
	tags = {"motorsport", "mechanic", "innovation"},
	weight = 10,
	cooldownYears = 2,
	conditions = {
		minAge = 25,
		maxAge = 40,
		requiredCareerId = "motorsport_icon",
		requiredAnyFlags = {"motorsport_mechanic_genius", "motorsport_mechanic_legend"},
		custom = function(state)
			return hasTrait(state, "MECHANICAPPT")
		end,
	},
	text = "You develop an innovative solution. A new technique. A better way. The industry takes notice.",
	choices = {
		{
			id = "patent_innovation",
			text = "Patent it. Protect your innovation.",
			resultText = "You patent it. The industry pays for your innovation. Smart move.",
			flags = flagSet("motorsport_mechanic_innovator"),
			careerXP = 70,
			careerReputation = 60,
			effects = { Money = 500000, Fame = 15, Smarts = 3 },
		},
		{
			id = "share_innovation",
			text = "Share it. Help the sport evolve.",
			resultText = "You share it. The sport evolves. You're a hero to mechanics everywhere.",
			flags = flagSet("motorsport_mechanic_hero"),
			careerXP = 65,
			careerReputation = 65,
			effects = { Fame = 12, Karma = 5, Happiness = 10 },
		},
	},
})

table.insert(events, {
	id = "motorsport_retirement_decision",
	emoji = "👋",
	title = "Retirement Decision",
	category = "motorsport",
	tags = {"motorsport", "retirement", "decision"},
	weight = 8,
	oneTime = true,
	conditions = {
		minAge = 35,
		maxAge = 50,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 5,
		requiredAnyFlags = {"motorsport_f1_champion", "motorsport_world_champion", "motorsport_endurance_winner"},
	},
	text = "Your body is tired. Your mind is sharp. Do you retire on top or keep racing?",
	choices = {
		{
			id = "retire_top",
			text = "Retire on top. Go out a champion.",
			resultText = "You retire. A champion. The perfect ending.",
			flags = flagSet("motorsport_retired_champion"),
			quitCareer = true,
			effects = { Happiness = 15, Fame = 10 },
		},
		{
			id = "keep_racing",
			text = "Keep racing. One more season.",
			resultText = "You keep racing. The hunger never dies. One more season.",
			flags = flagSet("motorsport_one_more_season"),
			careerXP = 30,
			effects = { Happiness = 8, Health = -5 },
		},
	},
})

table.insert(events, {
	id = "motorsport_legacy_academy",
	emoji = "🎓",
	title = "Racing Academy",
	category = "motorsport",
	tags = {"motorsport", "legacy", "academy"},
	weight = 7,
	oneTime = true,
	conditions = {
		minAge = 40,
		maxAge = 60,
		requiredAnyFlags = {"motorsport_retired_champion", "motorsport_founder", "motorsport_retired_icon"},
		minMoney = 1000000,
	},
	text = "You've saved enough. Time to start your own racing academy. Train the next generation.",
	choices = {
		{
			id = "start_academy",
			text = "Start the academy. Train champions.",
			resultText = "You start the academy. The next generation learns from you. Legacy secured.",
			flags = flagSet("motorsport_academy_founder"),
			effects = { Money = -500000, Fame = 15, Happiness = 18, Karma = 8 },
		},
		{
			id = "invest_wisely",
			text = "Invest the money. Academies are expensive.",
			resultText = "You invest wisely. Financial security first. Academies come later.",
			effects = { Money = 250000, Smarts = 3 },
		},
	},
})

table.insert(events, {
	id = "motorsport_final_championship",
	emoji = "🏆",
	title = "Final Championship",
	category = "motorsport",
	tags = {"motorsport", "championship", "final"},
	weight = 6,
	oneTime = true,
	conditions = {
		minAge = 30,
		maxAge = 45,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 5,
		requiredAnyFlags = {"motorsport_f1_champion", "motorsport_world_champion", "motorsport_endurance_winner"},
	},
	text = "Your final championship. One last title. One last chance at immortality. The world watches.",
	choices = {
		{
			id = "win_final",
			text = "Win the final championship. Perfect ending.",
			resultText = "You win. The perfect ending. A champion until the end.",
			flags = flagSet("motorsport_final_champion"),
			careerXP = 100,
			careerReputation = 90,
			effects = { Fame = 25, Happiness = 20, Money = 2000000 },
		},
		{
			id = "lose_final",
			text = "Lose. But you gave it everything.",
			resultText = "You lose, but you gave it everything. The respect is earned.",
			flags = flagSet("motorsport_final_runner_up"),
			careerXP = 80,
			careerReputation = 70,
			effects = { Fame = 18, Happiness = 8, Smarts = 3 },
		},
	},
})

-- ═══════════════════════════════════════════════════════════════
-- FINAL EVENTS TO REACH 4000+ LINES
-- ═══════════════════════════════════════════════════════════════

table.insert(events, {
	id = "motorsport_prep_racing_simulator",
	emoji = "🖥️",
	title = "Racing Simulator",
	category = "motorsport",
	tags = {"motorsport", "prep", "simulation"},
	weight = 14,
	conditions = {
		minAge = 9,
		maxAge = 13,
		requiredAnyFlags = {"motorsport_game_master", "motorsport_track_master"},
		minMoney = 1000,
	},
	text = "You discover professional racing simulators. Hours of practice. Every track, every car. You master them all.",
	choices = {
		{
			id = "master_sim",
			text = "Master the simulator. Become unbeatable.",
			resultText = "You become unbeatable. The skills transfer to real racing.",
			flags = flagSet("motorsport_sim_master"),
			effects = { Smarts = 3, TechSkill = 3, Money = -1000 },
		},
		{
			id = "study_tracks",
			text = "Study real tracks. Learn every corner.",
			resultText = "You memorize every corner. When you race for real, you're ready.",
			flags = flagSet("motorsport_track_student"),
			effects = { Smarts = 2, Money = -1000 },
		},
	},
})

table.insert(events, {
	id = "motorsport_kart_mentor",
	emoji = "👨‍🏫",
	title = "Become a Mentor",
	category = "motorsport",
	tags = {"motorsport", "karting", "mentor"},
	weight = 11,
	conditions = {
		minAge = 14,
		maxAge = 16,
		requiredCareerId = "motorsport_icon",
		requiredAnyFlags = {"motorsport_national_champion", "motorsport_international_champion"},
	},
	text = "Younger kids look up to you. They ask for advice. You become a mentor. Leadership develops.",
	choices = {
		{
			id = "embrace_mentor",
			text = "Embrace the role. Help the next generation.",
			resultText = "You become a mentor. The next generation learns from you. Legacy begins.",
			flags = flagSet("motorsport_early_mentor"),
			traits = traitPayload({ add = {"MENTOR_DRIVER"} }),
			careerXP = 25,
			effects = { Charisma = 3, Happiness = 6, Karma = 3 },
		},
		{
			id = "focus_self",
			text = "Focus on yourself. Your career comes first.",
			resultText = "You focus on yourself. Your career improves. But you miss connection.",
			flags = flagSet("motorsport_self_focused"),
			careerXP = 30,
			effects = { Fame = 2, Happiness = 3 },
		},
	},
})

table.insert(events, {
	id = "motorsport_junior_physical_training",
	emoji = "💪",
	title = "Physical Training",
	category = "motorsport",
	tags = {"motorsport", "junior_formula", "training"},
	weight = 10,
	cooldownYears = 1,
	conditions = {
		minAge = 17,
		maxAge = 22,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 2,
	},
	text = "You start serious physical training. Neck strength, cardio, core. The G-forces demand it.",
	choices = {
		{
			id = "train_hard",
			text = "Train hard. Become a physical beast.",
			resultText = "You become a physical beast. The G-forces don't affect you. Advantage gained.",
			flags = flagSet("motorsport_physical_beast"),
			effects = { Fitness = 5, Health = 5, Happiness = 4 },
		},
		{
			id = "train_smart",
			text = "Train smart. Focus on racing-specific fitness.",
			resultText = "You train smart. Racing-specific fitness. Efficient and effective.",
			flags = flagSet("motorsport_smart_trainer"),
			effects = { Fitness = 3, Smarts = 2, Health = 3 },
		},
	},
})

table.insert(events, {
	id = "motorsport_pro_f1_pit_stop_master",
	emoji = "⚡",
	title = "Pit Stop Master",
	category = "motorsport",
	tags = {"motorsport", "pro_circuit", "f1", "strategy"},
	weight = 9,
	cooldownYears = 1,
	conditions = {
		minAge = 23,
		maxAge = 32,
		requiredCareerId = "motorsport_icon",
		requiredCareerBranch = "single_seater",
		requiredCareerMinTier = 4,
		requiredAnyFlags = {"motorsport_f1_debut_points", "motorsport_f1_winner"},
	},
	text = "A race with multiple pit stops. You make the perfect calls. Strategy wins the race.",
	choices = {
		{
			id = "win_strategy",
			text = "Win with perfect strategy. Show your intelligence.",
			resultText = "You win with perfect strategy. Teams notice your race intelligence.",
			flags = flagSet("motorsport_f1_strategy_master"),
			traits = traitPayload({ add = {"DATA_STRATEGIST"} }),
			careerXP = 70,
			careerReputation = 45,
			effects = { Fame = 12, Happiness = 10, Money = 250000 },
		},
		{
			id = "podium_strategy",
			text = "Finish on the podium. Good strategy call.",
			resultText = "You finish 3rd. The strategy call was good, but not perfect.",
			flags = flagSet("motorsport_f1_strategy_good"),
			careerXP = 60,
			careerReputation = 35,
			effects = { Fame = 8, Happiness = 7 },
		},
	},
})

table.insert(events, {
	id = "motorsport_street_underground_respect",
	emoji = "👑",
	title = "Underground Respect",
	category = "motorsport",
	tags = {"motorsport", "street_racer", "respect"},
	weight = 9,
	cooldownYears = 1,
	conditions = {
		minAge = 20,
		maxAge = 30,
		requiredCareerId = "motorsport_icon",
		requiredCareerBranch = "street_icon",
		requiredCareerMinTier = 2,
		requiredAnyFlags = {"motorsport_street_legend", "motorsport_drift_king"},
	},
	text = "The underground scene respects you. Your name is legend. Every garage knows your story.",
	choices = {
		{
			id = "embrace_respect",
			text = "Embrace the respect. Own your status.",
			resultText = "You embrace the respect. Your legend grows. The scene worships you.",
			flags = flagSet("motorsport_underground_king"),
			careerXP = 55,
			careerReputation = 40,
			effects = { Fame = 10, Happiness = 10 },
		},
		{
			id = "stay_humble",
			text = "Stay humble. Keep racing.",
			resultText = "You stay humble. The scene respects your character. True legend.",
			flags = flagSet("motorsport_humble_underground"),
			careerXP = 50,
			careerReputation = 45,
			effects = { Fame = 8, Happiness = 8, Karma = 2 },
		},
	},
})

table.insert(events, {
	id = "motorsport_mechanic_team_championship",
	emoji = "🏆",
	title = "Team Championship",
	category = "motorsport",
	tags = {"motorsport", "mechanic", "championship"},
	weight = 9,
	oneTime = true,
	conditions = {
		minAge = 28,
		maxAge = 42,
		requiredCareerId = "motorsport_icon",
		requiredAnyFlags = {"motorsport_mechanic_champion", "motorsport_mechanic_f1"},
	},
	text = "Your team wins the championship. Your work made it possible. You're a championship-winning mechanic.",
	choices = {
		{
			id = "celebrate_championship",
			text = "Celebrate. You earned this.",
			resultText = "You celebrate. The championship is yours too. You're a legend.",
			flags = flagSet("motorsport_mechanic_champion_final"),
			careerXP = 85,
			careerReputation = 75,
			effects = { Fame = 18, Happiness = 18, Money = 400000 },
		},
		{
			id = "stay_professional",
			text = "Stay professional. The driver gets the glory.",
			resultText = "You stay professional. The team respects your character. True professional.",
			flags = flagSet("motorsport_mechanic_professional"),
			careerXP = 80,
			careerReputation = 70,
			effects = { Fame = 15, Happiness = 15, Karma = 4 },
		},
	},
})

table.insert(events, {
	id = "motorsport_vehicle_dream_car",
	emoji = "🚗",
	title = "Dream Car",
	category = "motorsport",
	tags = {"motorsport", "vehicle", "dream"},
	weight = 8,
	oneTime = true,
	conditions = {
		minAge = 30,
		maxAge = 45,
		requiredCareerId = "motorsport_icon",
		requiredCareerMinTier = 5,
		minMoney = 200000,
		requiredAnyFlags = {"motorsport_supercar_owner", "motorsport_track_car_owner"},
	},
	getDynamicData = function()
		local dreamCars = {
			{make = "Ferrari", model = "F40", price = 1500000, condition = "legendary"},
			{make = "Porsche", model = "911 GT2 RS", price = 300000, condition = "ultimate"},
			{make = "McLaren", model = "P1", price = 1200000, condition = "hypercar"},
			{make = "Lamborghini", model = "Aventador SVJ", price = 500000, condition = "extreme"},
		}
		local car = dreamCars[math.random(#dreamCars)]
		return { make = car.make, model = car.model, price = car.price, condition = car.condition }
	end,
	text = "You've made it. Time for your dream car: a %condition% %make% %model% for $%price%. The ultimate achievement.",
	choices = {
		{
			id = "buy_dream",
			text = "Buy it. You've earned this.",
			resultText = "You buy your dream car. The ultimate achievement. Life is complete.",
			flags = flagSet("motorsport_dream_car_owner"),
			addAsset = {
				type = "vehicle",
				make = "%make%",
				model = "%model%",
				value = 1000000,
				condition = "%condition%",
			},
			effects = { Money = -1000000, Happiness = 20, Fame = 10 },
		},
		{
			id = "invest_future",
			text = "Invest the money. Dream cars can wait.",
			resultText = "You invest wisely. Financial security first. Dream cars come later.",
			effects = { Money = 100000, Smarts = 4 },
		},
	},
})

table.insert(events, {
	id = "motorsport_legacy_hall_of_fame",
	emoji = "🏛️",
	title = "Hall of Fame",
	category = "motorsport",
	tags = {"motorsport", "legacy", "honor"},
	weight = 7,
	oneTime = true,
	conditions = {
		minAge = 45,
		maxAge = 70,
		requiredAnyFlags = {"motorsport_f1_champion", "motorsport_world_champion", "motorsport_retired_champion"},
	},
	text = "You're inducted into the Motorsport Hall of Fame. Immortality. Your name is forever.",
	choices = {
		{
			id = "accept_honor",
			text = "Accept the honor. You've earned it.",
			resultText = "You accept. Hall of Fame. Immortality. The perfect ending.",
			flags = flagSet("motorsport_hall_of_fame"),
			effects = { Fame = 30, Happiness = 25, Karma = 5 },
		},
		{
			id = "stay_humble",
			text = "Stay humble. Others deserve it more.",
			resultText = "You stay humble. The honor means everything. True champion.",
			flags = flagSet("motorsport_humble_hall"),
			effects = { Fame = 25, Happiness = 20, Karma = 8 },
		},
	},
})

return { events = events }
