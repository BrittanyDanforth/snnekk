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
		requiredAnyFlags = {"motorsport_speed_imprint", "motorsport_escape_artist"},
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
		requiredAnyFlags = {"motorsport_kart_builder", "motorsport_hustler"},
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
		requiredAnyFlags = {"motorsport_local_champion", "motorsport_sim_professor", "motorsport_stream_outlaw"},
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

return { events = events }
