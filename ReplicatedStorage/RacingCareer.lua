--!strict
-- RacingCareer.lua
-- ═══════════════════════════════════════════════════════════════════════════════
-- TRIPLE AAA DEEP BACKEND: Motorsport / Racing Career Track
-- 4K+ lines of pure racing narrative depth
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- This is PURELY career-focused; no generic childhood events.
-- Designed to work with TraitSystem-style backend.
--
-- Expected external integration:
--  - You keep a playerCareerState table per life
--  - You keep Traits + Stats in your TraitSystem / playerData
--  - You call RacingCareer.GetEligibleEvents(...) to get events
--  - You pick an event + choice in your UI
--  - You apply outcome via your TraitSystem / stat system
--
-- playerCareerState shape (recommended):
-- {
--     stage: string,       -- "NONE","PREP","KARTING","JUNIOR","PRO","STREET","MECHANIC"
--     xp: number,
--     prestige: number,
--     fame: number,
--     risk: number,
--     outlawPath: boolean,
--     crashes: number,
--     flags: {[string]: boolean},
--     ownedVehicles: {VehicleData},  -- Cars, bikes, karts
--     totalRaces: number,
--     wins: number,
--     podiums: number,
--     deaths: number,  -- Track near-death experiences
-- }
--
-- You decide how to save that. This module just reads/writes these fields.

local RacingCareer = {}

-- Load TraitSystem for dynamic trait interactions
local TraitSystem = nil
pcall(function()
	TraitSystem = require(script.Parent:WaitForChild("TraitSystem", 5))
end)

export type CareerStageId =
    "NONE" |
    "PREP" |
    "KARTING" |
    "JUNIOR_FORMULA" |
    "PRO_CIRCUIT" |
    "STREET_RACER" |
    "MECHANIC"

export type VehicleData = {
	id: string,
	type: string,  -- "kart", "bike", "car", "race_car"
	make: string?,
	model: string?,
	year: number?,
	value: number,
	condition: number,  -- 0-100
	purchaseYear: number?,
	modifications: {string}?,
	raceCount: number?,
	crashes: number?,
}

export type CareerState = {
    stage: CareerStageId,
    xp: number,
    prestige: number,
    fame: number,
    risk: number,
    outlawPath: boolean,
    crashes: number,
    flags: {[string]: boolean},
    ownedVehicles: {VehicleData}?,
    totalRaces: number?,
    wins: number?,
    podiums: number?,
    deaths: number?,
    money: number?,
}

export type Outcome = {
    tags: {string}?,
    severity: number?,
    statDelta: {[string]: number}?,
    addTraits: {string}?,
    removeTraits: {string}?,
    careerDelta: {
        xp: number?,
        prestige: number?,
        fame: number?,
        risk: number?,
        crashes: number?,
        money: number?,
        stageOverride: CareerStageId?,
        wins: number?,
        podiums: number?,
        totalRaces: number?,
    }?,
    flagsAdd: {[string]: boolean}?,
    flagsRemove: {string}?,
    narrative: string?,
    addVehicle: VehicleData?,
    removeVehicle: string?,
    deathRisk: number?,
}

export type Choice = {
    id: string,
    text: string,
    outcome: Outcome,
    requiresMoney: number?,
    requiresVehicle: string?,
    requiresFlag: string?,
    requiresTrait: string?,
}

export type EventRequirement = {
    traitsAny: {string}?,
    traitsAll: {string}?,
    traitsNot: {string}?,

    flagsAny: {string}?,
    flagsAll: {string}?,
    flagsNot: {string}?,

    minPrestige: number?,
    maxPrestige: number?,
    minFame: number?,
    maxFame: number?,
    minAge: number?,
    maxAge: number?,
    minRisk: number?,
    maxRisk: number?,
    requiresVehicle: boolean?,
    requiresOwnedVehicle: string?,
}

export type CareerEvent = {
    id: string,
    title: string,
    description: string,
    minAge: number,
    maxAge: number,
    stages: {CareerStageId}, -- allowed stages
    weight: number,
    requirements: EventRequirement?,
    tags: {string}?,
    choices: {Choice},
}

----------------------------------------------------------------
-- BASIC META
----------------------------------------------------------------

RacingCareer.Id = "RACING"
RacingCareer.Name = "Motorsport / Racing Career"
RacingCareer.Version = "v2.0"

----------------------------------------------------------------
-- DEFAULT CAREER STATE
----------------------------------------------------------------

function RacingCareer.newState(): CareerState
    return {
        stage = "NONE",
        xp = 0,
        prestige = 0,
        fame = 0,
        risk = 0,
        outlawPath = false,
        crashes = 0,
        flags = {},
        ownedVehicles = {},
        totalRaces = 0,
        wins = 0,
        podiums = 0,
        deaths = 0,
        money = 0,
    }
end

----------------------------------------------------------------
-- INTERNAL HELPERS
----------------------------------------------------------------

local function listToSet(list: {string}?): {[string]: boolean}
    local set: {[string]: boolean} = {}
    if list then
        for _,v in ipairs(list) do
            set[v] = true
        end
    end
    return set
end

local function hasAny(set: {[string]: boolean}, list: {string}?): boolean
    if not list or #list == 0 then
        return true
    end
    for _,v in ipairs(list) do
        if set[v] then
            return true
        end
    end
    return false
end

local function hasAll(set: {[string]: boolean}, list: {string}?): boolean
    if not list or #list == 0 then
        return true
    end
    for _,v in ipairs(list) do
        if not set[v] then
            return false
        end
    end
    return true
end

local function hasNone(set: {[string]: boolean}, list: {string}?): boolean
    if not list or #list == 0 then
        return true
    end
    for _,v in ipairs(list) do
        if set[v] then
            return false
        end
    end
    return true
end

local function stageAllowed(stage: CareerStageId, allowed: {CareerStageId}): boolean
    for _,s in ipairs(allowed) do
        if s == stage then
            return true
        end
    end
    return false
end

----------------------------------------------------------------
-- EVENT DEFINITIONS
-- NOTE: These are ONLY racing-career focused.
-- They assume traits like:
--      "RACER", "RECKLESS", "GOODDRIVER", "THRILLSEEKER", "MECHANICAPPT",
--      "FATKID", "BULLYVICTIM", "ANXIOUS", "TECHYKID", "MEDIA_DARLING",
--      "DATA_STRATEGIST", "MENTOR_DRIVER"
--    exist in your TraitSystem.
--  - statDelta keys assume you have stats: DrivingSkill, Fitness, MentalHealth,
--    RiskAffinity, Charisma, Luck, TechSkill, Intelligence, etc.
----------------------------------------------------------------

local Events: {CareerEvent} = {}

local function ev(e: CareerEvent)
    table.insert(Events, e)
end

------------------------------------------------
-- STAGE: NONE / PREP  (10–15, bikes & local)
------------------------------------------------

ev({
    id = "RACE_PREP_NEIGHBORHOOD_BIKE",
    title = "Neighborhood Bike Races",
    description = "Kids on your street start racing bikes down the hill. You feel that itch to prove you're the fastest.",
    minAge = 10,
    maxAge = 14,
    stages = {"NONE", "PREP"},
    weight = 8,
    tags = {"prep","race","bike"},
    requirements = {
        traitsAny = {"RACER"},
        traitsNot = {"ANXIOUS"},
    },
    choices = {
        {
            id = "ALL_OUT",
            text = "Go all out and take the riskiest line.",
            outcome = {
                tags = {"race","risk"},
                severity = 3,
                statDelta = { DrivingSkill = 1, Fitness = 1, RiskAffinity = 1 },
                addTraits = {"THRILLSEEKER"},
                careerDelta = {
                    xp = 5,
                    prestige = 1,
                    risk = 1,
                },
                flagsAdd = { PREP_BIKE_RACER = true },
                narrative = "You slam the pedals, take the sharpest line, and barely hold the bike together. The other kids see you as 'the fast one' now."
            }
        },
        {
            id = "CONTROLLED",
            text = "Ride fast, but stay in control.",
            outcome = {
                tags = {"race","control"},
                severity = 2,
                statDelta = { DrivingSkill = 2, Fitness = 1, RiskAffinity = -1 },
                addTraits = {"GOODDRIVER"},
                careerDelta = {
                    xp = 4,
                    prestige = 1,
                    risk = 0,
                },
                narrative = "You read the hill, brake where it matters, and still cross first. Speed with control feels natural to you."
            }
        },
        {
            id = "SIT_OUT",
            text = "Watch from the sidewalk instead.",
            outcome = {
                tags = {"avoid"},
                severity = 1,
                statDelta = { MentalHealth = -1, RiskAffinity = -1 },
                addTraits = {"ANXIOUS"},
                careerDelta = {
                    xp = 0,
                    prestige = -1,
                },
                narrative = "You stay on the curb and pretend you don't care. Deep down it stings that you didn't even try."
            }
        },
    }
})

ev({
    id = "RACE_PREP_YOUTUBE_ENGINE_DEEPDIVE",
    title = "Nightly Engine Rabbit Hole",
    description = "You fall into a YouTube hole watching kart engine tuning and race onboard footage.",
    minAge = 11,
    maxAge = 15,
    stages = {"NONE", "PREP"},
    weight = 7,
    tags = {"prep","tech","study"},
    requirements = {
        traitsAny = {"RACER","TECHYKID"},
    },
    choices = {
        {
            id = "TAKE_NOTES",
            text = "Take mental notes, rewinding parts obsessively.",
            outcome = {
                tags = {"study","focus"},
                severity = 1,
                statDelta = { DrivingSkill = 1, TechSkill = 1, Intelligence = 1 },
                addTraits = {"MECHANICAPPT"},
                careerDelta = {
                    xp = 3,
                },
                narrative = "You obsess over braking markers, lines, and engine sounds. You start seeing patterns most people miss."
            }
        },
        {
            id = "JUST_VIBES",
            text = "Just vibe to the sounds and speed.",
            outcome = {
                tags = {"vibe"},
                severity = 0,
                statDelta = { DrivingSkill = 1 },
                careerDelta = {
                    xp = 1,
                },
                narrative = "You don't overthink it. You just know you want to be in that cockpit someday."
            }
        },
    }
})

ev({
    id = "RACE_PREP_PARENT_ARGUMENT",
    title = "Parent Argument Over Risk",
    description = "One parent thinks your racing obsession is dangerous; the other thinks it's 'better than drugs.' They argue about whether to support you.",
    minAge = 12,
    maxAge = 16,
    stages = {"NONE", "PREP"},
    weight = 6,
    tags = {"family","conflict","career_gate"},
    requirements = {
        traitsAny = {"RACER"},
    },
    choices = {
        {
            id = "PICK_SIDE_RISK",
            text = "Back the parent who wants to let you race.",
            outcome = {
                tags = {"family","risk"},
                severity = 3,
                statDelta = { MentalHealth = -1, RiskAffinity = 1 },
                careerDelta = {
                    xp = 2,
                    prestige = 1,
                },
                flagsAdd = { PARENT_SUPPORT_RISK = true },
                narrative = "You double down that racing is your life. One parent becomes your ally, the other quietly resents it."
            }
        },
        {
            id = "PICK_SIDE_SAFE",
            text = "Agree it's too dangerous, at least out loud.",
            outcome = {
                tags = {"family","suppress"},
                severity = 2,
                statDelta = { MentalHealth = -2 },
                addTraits = {"ANXIOUS"},
                careerDelta = {
                    xp = 0,
                    prestige = -1,
                },
                flagsAdd = { PARENT_BLOCKED_RACING = true },
                narrative = "You swallow your dream for now. You know they won't back you if anything goes wrong."
            }
        },
        {
            id = "STAY_SILENT",
            text = "Stay quiet and listen, storing every word.",
            outcome = {
                tags = {"observer"},
                severity = 1,
                statDelta = { Intelligence = 1, MentalHealth = -1 },
                careerDelta = {
                    xp = 1,
                },
                narrative = "You keep your mouth shut, but the argument brands racing as a 'problem' in your house."
            }
        },
    }
})

ev({
    id = "RACE_PREP_FIRST_BIKE_PURCHASE",
    title = "First Real Bike",
    description = "You've saved up enough from chores and odd jobs. The local bike shop has a used BMX that's way faster than your hand-me-down.",
    minAge = 12,
    maxAge = 15,
    stages = {"NONE", "PREP"},
    weight = 9,
    tags = {"prep","purchase","vehicle"},
    requirements = {
        traitsAny = {"RACER"},
        flagsNot = {"PARENT_BLOCKED_RACING"},
    },
    choices = {
        {
            id = "BUY_BIKE",
            text = "Spend $200 on the bike. It's worth it.",
            requiresMoney = 200,
            outcome = {
                tags = {"purchase","vehicle"},
                severity = 2,
                statDelta = { DrivingSkill = 2, Fitness = 1 },
                careerDelta = {
                    xp = 5,
                    prestige = 2,
                    money = -200,
                },
                addVehicle = {
                    id = "bike_1",
                    type = "bike",
                    make = "BMX",
                    model = "Racer",
                    value = 200,
                    condition = 75,
                    purchaseYear = nil, -- Will be set by ApplyOutcome
                },
                flagsAdd = { FIRST_VEHICLE_OWNED = true },
                narrative = "You hand over crumpled bills. The bike feels like a rocket. You immediately start planning upgrades."
            }
        },
        {
            id = "SAVE_MORE",
            text = "Keep saving for something better.",
            outcome = {
                tags = {"patience"},
                severity = 1,
                statDelta = { Intelligence = 1 },
                careerDelta = {
                    xp = 1,
                },
                narrative = "You walk away, but the bike haunts your dreams. Maybe next year."
            }
        },
        {
            id = "ASK_PARENT",
            text = "Ask your supportive parent to chip in.",
            outcome = {
                tags = {"family","money"},
                severity = 1,
                statDelta = { Charisma = 1 },
                careerDelta = {
                    xp = 3,
                    prestige = 1,
                    money = -100,
                },
                addVehicle = {
                    id = "bike_1",
                    type = "bike",
                    make = "BMX",
                    model = "Racer",
                    value = 200,
                    condition = 80,
                },
                flagsAdd = { FIRST_VEHICLE_OWNED = true, PARENT_INVESTED = true },
                narrative = "They see the hunger in your eyes and match your savings. The bike becomes a symbol of their belief in you."
            }
        },
    }
})

------------------------------------------------
-- TRANSITION: PREP → KARTING
------------------------------------------------

ev({
    id = "RACE_TRANSITION_LOCAL_KART_TRYOUT",
    title = "Local Kart Track Tryout Day",
    description = "A local kart track hosts a cheap 'tryout day.' It's the first time you can get into a real kart.",
    minAge = 12,
    maxAge = 17,
    stages = {"NONE", "PREP"},
    weight = 9,
    tags = {"gate","kart","career_start"},
    requirements = {
        traitsAny = {"RACER"},
        flagsNot = {"PARENT_BLOCKED_RACING"},
    },
    choices = {
        {
            id = "PAY_AND_DRIVE",
            text = "You scrape together money and drive anyway.",
            requiresMoney = 50,
            outcome = {
                tags = {"kart","risk","money"},
                severity = 4,
                statDelta = { DrivingSkill = 2, Fitness = 1, RiskAffinity = 1 },
                addTraits = {"THRILLSEEKER"},
                careerDelta = {
                    xp = 15,
                    prestige = 3,
                    stageOverride = "KARTING",
                    money = -50,
                },
                flagsAdd = { FIRST_KART_EXPERIENCE = true },
                narrative = "The first time the kart snaps into the corner, you know this is it. Street bikes feel like toys now."
            }
        },
        {
            id = "ASK_PARENT_HELP",
            text = "Ask your supportive parent to cover the fee.",
            outcome = {
                tags = {"kart","family"},
                severity = 2,
                statDelta = { DrivingSkill = 1 },
                careerDelta = {
                    xp = 10,
                    prestige = 2,
                    stageOverride = "KARTING",
                },
                flagsAdd = { FIRST_KART_EXPERIENCE = true, PARENT_INVESTED = true },
                narrative = "They watch from behind the fence, phone out, filming. For once, they look proud instead of worried."
            }
        },
        {
            id = "SKIP",
            text = "You stay home, telling yourself there will be other chances.",
            outcome = {
                tags = {"avoid","regret"},
                severity = 3,
                statDelta = { MentalHealth = -2 },
                careerDelta = {
                    xp = 0,
                    prestige = -2,
                },
                narrative = "You scroll past people's videos from the track that night. It feels like your future is happening without you."
            }
        },
    }
})

------------------------------------------------
-- STAGE: KARTING (14–18)
------------------------------------------------

ev({
    id = "RACE_KART_ROOKIE_SEASON",
    title = "Rookie Karting Season",
    description = "You commit to your first full karting season. New people, new rivalries, and your first real points table.",
    minAge = 14,
    maxAge = 18,
    stages = {"KARTING"},
    weight = 10,
    tags = {"season","kart","rookie"},
    requirements = {
        traitsAny = {"RACER"},
    },
    choices = {
        {
            id = "AGGRESSIVE_STYLE",
            text = "Drive aggressively, sending moves even when they're 50/50.",
            outcome = {
                tags = {"risk","overtake"},
                severity = 4,
                statDelta = { DrivingSkill = 2, RiskAffinity = 2, Fitness = 1 },
                addTraits = {"RECKLESS"},
                careerDelta = {
                    xp = 20,
                    prestige = 4,
                    risk = 3,
                    crashes = 1,
                    totalRaces = 1,
                },
                flagsAdd = { PADDOCK_REPUTATION_DIRTY = true },
                narrative = "You become infamous for last-corner lunges. You win some, but you also collect enemies and bent axles."
            }
        },
        {
            id = "CALCULATED_STYLE",
            text = "Focus on consistency and racecraft, not chaos dives.",
            outcome = {
                tags = {"control","craft"},
                severity = 2,
                statDelta = { DrivingSkill = 3, RiskAffinity = -1 },
                addTraits = {"GOODDRIVER"},
                careerDelta = {
                    xp = 18,
                    prestige = 5,
                    risk = 0,
                    totalRaces = 1,
                    wins = 1,
                },
                flagsAdd = { PADDOCK_REPUTATION_RESPECTED = true },
                narrative = "You rarely make stupid moves. You might not win every race, but the paddock knows you're the real deal."
            }
        },
        {
            id = "PART_TIME",
            text = "Race only when money/time allows, treating it like a hobby.",
            outcome = {
                tags = {"casual"},
                severity = 1,
                statDelta = { DrivingSkill = 1 },
                careerDelta = {
                    xp = 8,
                    prestige = 1,
                    totalRaces = 1,
                },
                narrative = "You learn, but at half-speed. Racing feels more like an expensive hobby than a destiny."
            }
        },
    }
})

ev({
    id = "RACE_KART_CRASH_INJURY",
    title = "Kart Pile-Up Crash",
    description = "On a wet race start, someone spins ahead. A pile-up forms before Turn 1.",
    minAge = 14,
    maxAge = 18,
    stages = {"KARTING"},
    weight = 7,
    tags = {"crash","injury","kart"},
    requirements = {
        traitsAny = {"RACER"},
    },
    choices = {
        {
            id = "SEND_IT",
            text = "You stay flat and try to thread the chaos.",
            outcome = {
                tags = {"crash","risk"},
                severity = 7,
                statDelta = { Fitness = -2, MentalHealth = -2, Luck = -1 },
                addTraits = {"RECKLESS"},
                careerDelta = {
                    xp = 5,
                    risk = 4,
                    crashes = 1,
                },
                flagsAdd = { MAJOR_KART_CRASH = true },
                deathRisk = 0.05,
                narrative = "You clip a spinning kart and get launched. Bruises, maybe worse. The adrenaline fades, leaving a shaking memory."
            }
        },
        {
            id = "BRAKE_ESCAPE",
            text = "You brake early and sacrifice position to survive.",
            outcome = {
                tags = {"safety","control"},
                severity = 3,
                statDelta = { DrivingSkill = 1, RiskAffinity = -1 },
                addTraits = {"GOODDRIVER"},
                careerDelta = {
                    xp = 10,
                    prestige = 1,
                    risk = -1,
                },
                flagsAdd = { AVOIDED_BIG_CRASH = true },
                narrative = "You drop spots but keep your kart intact. Watching the pile-up in your mirrors shakes you anyway."
            }
        },
        {
            id = "PANIC",
            text = "You panic and freeze, reacting too late.",
            outcome = {
                tags = {"crash","panic"},
                severity = 8,
                statDelta = { Fitness = -3, MentalHealth = -4, RiskAffinity = -2 },
                addTraits = {"ANXIOUS","BULLYVICTIM"},
                careerDelta = {
                    xp = 0,
                    prestige = -2,
                    risk = 2,
                    crashes = 1,
                },
                flagsAdd = { CRASH_TRAUMA = true },
                deathRisk = 0.10,
                narrative = "You lock up too late and smash into the mess. The pain is bad, but the replay in your head is worse."
            }
        },
    }
})

ev({
    id = "RACE_KART_SPONSOR_CHOICE",
    title = "First Local Sponsor Offer",
    description = "A local shop offers a small sponsorship: parts discount in exchange for stickers and shoutouts.",
    minAge = 15,
    maxAge = 19,
    stages = {"KARTING"},
    weight = 6,
    tags = {"money","sponsor"},
    requirements = {
        traitsAny = {"RACER"},
        minPrestige = 3,
    },
    choices = {
        {
            id = "ACCEPT",
            text = "Accept and become their 'poster child.'",
            outcome = {
                tags = {"sponsor","money"},
                severity = 1,
                statDelta = { Charisma = 1 },
                careerDelta = {
                    xp = 8,
                    prestige = 3,
                    fame = 2,
                    money = 500,
                },
                flagsAdd = { LOCAL_SPONSOR_LOCKED = true },
                narrative = "You slap their logo on your kart. They brag about you to customers; you get parts for cheaper."
            }
        },
        {
            id = "NEGOTIATE",
            text = "Negotiate for better terms like a pro.",
            outcome = {
                tags = {"sponsor","negotiate"},
                severity = 2,
                statDelta = { Charisma = 2, Intelligence = 1 },
                careerDelta = {
                    xp = 10,
                    prestige = 4,
                    fame = 2,
                    money = 1000,
                },
                flagsAdd = { LOCAL_SPONSOR_LOCKED = true, DRIVER_BUSINESS_BRAIN = true },
                narrative = "You don't just race; you talk like a future pro. They cave and sweeten the deal."
            }
        },
        {
            id = "DECLINE",
            text = "Decline and keep your kart 'clean.'",
            outcome = {
                tags = {"pride"},
                severity = 1,
                statDelta = { MentalHealth = 1 },
                careerDelta = {
                    xp = 3,
                    prestige = 0,
                    fame = 0,
                    money = 0,
                },
                narrative = "You tell yourself you're not gonna be a walking billboard. But you also burn a rare shot at resources."
            }
        },
    }
})

ev({
    id = "RACE_KART_BUY_FIRST_KART",
    title = "Your First Kart",
    description = "You've been renting karts, but now you have a chance to buy your own. A used kart with some battle scars, but it's yours.",
    minAge = 14,
    maxAge = 18,
    stages = {"KARTING"},
    weight = 8,
    tags = {"purchase","kart","vehicle"},
    requirements = {
        traitsAny = {"RACER"},
        flagsAny = {"FIRST_KART_EXPERIENCE"},
    },
    choices = {
        {
            id = "BUY_USED_KART",
            text = "Spend $2,500 on the used kart.",
            requiresMoney = 2500,
            outcome = {
                tags = {"purchase","vehicle"},
                severity = 2,
                statDelta = { DrivingSkill = 1 },
                careerDelta = {
                    xp = 10,
                    prestige = 3,
                    money = -2500,
                },
                addVehicle = {
                    id = "kart_1",
                    type = "kart",
                    make = "Tony Kart",
                    model = "Racer",
                    value = 2500,
                    condition = 65,
                    raceCount = 0,
                    crashes = 0,
                },
                flagsAdd = { OWN_KART = true },
                narrative = "You hand over the cash. The kart smells like fuel and ambition. It's yours to break, fix, and race."
            }
        },
        {
            id = "SAVE_FOR_BETTER",
            text = "Keep saving for a newer kart.",
            outcome = {
                tags = {"patience"},
                severity = 1,
                statDelta = { Intelligence = 1 },
                careerDelta = {
                    xp = 2,
                },
                narrative = "You walk away. Maybe next season you'll have enough for something competitive."
            }
        },
        {
            id = "FIND_SPONSOR",
            text = "Try to find a sponsor to cover it.",
            outcome = {
                tags = {"sponsor","negotiate"},
                severity = 2,
                statDelta = { Charisma = 2 },
                careerDelta = {
                    xp = 5,
                    prestige = 2,
                    money = -1000,
                },
                addVehicle = {
                    id = "kart_1",
                    type = "kart",
                    make = "Tony Kart",
                    model = "Racer",
                    value = 2500,
                    condition = 70,
                },
                flagsAdd = { OWN_KART = true, SPONSORED_KART = true },
                narrative = "You pitch a local business. They see potential and cover half. The kart wears their logo, but it's yours."
            }
        },
    }
})

------------------------------------------------
-- TRANSITION: KARTING → JUNIOR
------------------------------------------------

ev({
    id = "RACE_TRANSITION_JUNIOR_SCOUT",
    title = "Scouted for Junior Formula Test",
    description = "A junior formula team invites you for a test day after watching your karting results.",
    minAge = 16,
    maxAge = 20,
    stages = {"KARTING"},
    weight = 8,
    tags = {"scout","junior","career_step"},
    requirements = {
        traitsAny = {"RACER"},
        minPrestige = 5,
    },
    choices = {
        {
            id = "FOCUS_TEST",
            text = "Treat it like the most important day of your life.",
            outcome = {
                tags = {"focus","opportunity"},
                severity = 3,
                statDelta = { DrivingSkill = 3, Fitness = 1, MentalHealth = -1 },
                careerDelta = {
                    xp = 25,
                    prestige = 6,
                    fame = 3,
                    stageOverride = "JUNIOR_FORMULA",
                },
                flagsAdd = { JUNIOR_SEAT_SECURED = true },
                narrative = "You nail the lines, adapt to aero, and impress the engineers. You leave with a real path upward."
            }
        },
        {
            id = "TRY_BALANCE",
            text = "Balance it with school / work and show up tired.",
            outcome = {
                tags = {"exhaustion"},
                severity = 4,
                statDelta = { DrivingSkill = 1, MentalHealth = -2, Fitness = -1 },
                careerDelta = {
                    xp = 10,
                    prestige = 2,
                    fame = 1,
                    stageOverride = "JUNIOR_FORMULA",
                },
                flagsAdd = { JUNIOR_SEAT_WEAK = true },
                narrative = "You're clearly talented but off your peak. They take you, but as a 'maybe' instead of 'our star.'"
            }
        },
        {
            id = "DECLINE_TEST",
            text = "Decline because the risk, money, or pressure scares you.",
            outcome = {
                tags = {"fear","missed"},
                severity = 5,
                statDelta = { MentalHealth = -3 },
                addTraits = {"ANXIOUS"},
                careerDelta = {
                    xp = 0,
                    prestige = -3,
                },
                narrative = "You push the invite away and tell people it 'wasn't a big deal.' You know that's a lie."
            }
        },
    }
})

------------------------------------------------
-- STAGE: JUNIOR (17–23)
------------------------------------------------

ev({
    id = "RACE_JUNIOR_TEAM_POLITICS",
    title = "Junior Team Politics",
    description = "Your teammate's family brings more money. The team starts favoring them with newer parts.",
    minAge = 17,
    maxAge = 23,
    stages = {"JUNIOR_FORMULA"},
    weight = 7,
    tags = {"politics","team","resentment"},
    requirements = {
        traitsAny = {"RACER"},
    },
    choices = {
        {
            id = "OUTDRIVE_ANYWAY",
            text = "Ignore politics and outdrive them with old parts.",
            outcome = {
                tags = {"grit","prove"},
                severity = 3,
                statDelta = { DrivingSkill = 3, MentalHealth = -1 },
                careerDelta = {
                    xp = 20,
                    prestige = 5,
                    fame = 3,
                    totalRaces = 1,
                    wins = 1,
                },
                flagsAdd = { UNDERDOG_STORY = true },
                narrative = "You drag the old car into places it shouldn't be. People talk: 'If that kid had equal machinery…'"
            }
        },
        {
            id = "PLAY_POLITICS",
            text = "Network, charm sponsors, play the political game.",
            outcome = {
                tags = {"politics","charisma"},
                severity = 2,
                statDelta = { Charisma = 2, Intelligence = 1 },
                careerDelta = {
                    xp = 12,
                    prestige = 4,
                    fame = 4,
                    money = 2000,
                },
                flagsAdd = { PADDOCK_POLITICIAN = true },
                narrative = "You smile, shake hands, and say the right things. You hate it—but doors start nudging open."
            }
        },
        {
            id = "MELTDOWN",
            text = "Blow up publicly about the unfair treatment.",
            outcome = {
                tags = {"anger","self_sabotage"},
                severity = 5,
                statDelta = { MentalHealth = -3, Charisma = -2 },
                addTraits = {"RECKLESS"},
                careerDelta = {
                    xp = 5,
                    prestige = -2,
                    fame = 2,
                },
                flagsAdd = { TEAM_TROUBLEMAKER = true },
                narrative = "You vent in the paddock and online. Some fans love the honesty; the team doesn't."
            }
        },
    }
})

ev({
    id = "RACE_JUNIOR_FIRST_DEATH_IN_PADDOCK",
    title = "Fatal Accident in the Series",
    description = "A driver in your junior series dies in a high-speed accident. The paddock goes silent.",
    minAge = 17,
    maxAge = 23,
    stages = {"JUNIOR_FORMULA"},
    weight = 5,
    tags = {"death","trauma","risk"},
    requirements = {
        traitsAny = {"RACER"},
    },
    choices = {
        {
            id = "HARDEN",
            text = "You compartmentalize it as 'part of the game.'",
            outcome = {
                tags = {"numb","risk"},
                severity = 7,
                statDelta = { MentalHealth = -2, RiskAffinity = 2 },
                addTraits = {"THRILLSEEKER"},
                careerDelta = {
                    xp = 10,
                    prestige = 3,
                    risk = 4,
                },
                narrative = "You feel sick, but you also feel more determined. If it's this serious, you want to conquer it."
            }
        },
        {
            id = "SHAKEN",
            text = "You get shaken and question if this is worth it.",
            outcome = {
                tags = {"fear","trauma"},
                severity = 7,
                statDelta = { MentalHealth = -4, RiskAffinity = -3 },
                addTraits = {"ANXIOUS"},
                careerDelta = {
                    xp = 3,
                    prestige = -1,
                    risk = -2,
                },
                flagsAdd = { SAFETY_OBSESSED = true },
                narrative = "You stare at the empty grid slot. The cost of chasing speed finally sinks in."
            }
        },
    }
})

ev({
    id = "RACE_JUNIOR_ENGINEERING_PATH_PULL",
    title = "Pulled Toward Engineering",
    description = "A senior engineer notices your feedback and says you'd make a great race engineer or mechanic if driving doesn't work out.",
    minAge = 18,
    maxAge = 24,
    stages = {"JUNIOR_FORMULA"},
    weight = 6,
    tags = {"engineering","fallback"},
    requirements = {
        traitsAny = {"MECHANICAPPT","TECHYKID"},
    },
    choices = {
        {
            id = "DOUBLE_DOWN_DRIVING",
            text = "Thank them, but insist you'll make it as a driver.",
            outcome = {
                tags = {"stubborn","drive"},
                severity = 3,
                statDelta = { MentalHealth = -1 },
                careerDelta = {
                    xp = 8,
                    prestige = 3,
                },
                narrative = "You refuse to see it as a fallback. If anything, it pisses you off, fueling your grind."
            }
        },
        {
            id = "EMBRACE_DUAL",
            text = "Start shadowing them casually to learn both sides.",
            outcome = {
                tags = {"dual","engineering"},
                severity = 2,
                statDelta = { TechSkill = 2, Intelligence = 1 },
                careerDelta = {
                    xp = 10,
                    prestige = 2,
                },
                flagsAdd = { ENGINEERING_BACKUP = true },
                narrative = "You start absorbing how set-up decisions really work. It quietly gives your career extra life support."
            }
        },
    }
})

ev({
    id = "RACE_JUNIOR_BUY_FIRST_CAR",
    title = "Your First Street Car",
    description = "You've saved up enough from sponsorships and part-time work. Time to buy your first real car—something you can drive on the street and maybe track.",
    minAge = 16,
    maxAge = 22,
    stages = {"JUNIOR_FORMULA"},
    weight = 7,
    tags = {"purchase","car","vehicle"},
    requirements = {
        traitsAny = {"RACER"},
        minPrestige = 3,
    },
    choices = {
        {
            id = "BUY_CHEAP_SPORTS_CAR",
            text = "Buy a used sports car for $8,000.",
            requiresMoney = 8000,
            outcome = {
                tags = {"purchase","vehicle"},
                severity = 2,
                statDelta = { DrivingSkill = 1, Charisma = 1 },
                careerDelta = {
                    xp = 5,
                    prestige = 2,
                    money = -8000,
                },
                addVehicle = {
                    id = "car_1",
                    type = "car",
                    make = "Mazda",
                    model = "Miata",
                    year = 2005,
                    value = 8000,
                    condition = 70,
                    raceCount = 0,
                    crashes = 0,
                },
                flagsAdd = { FIRST_CAR_OWNED = true },
                narrative = "You hand over the cash. The car isn't fast, but it handles like a dream. You immediately start planning track days."
            }
        },
        {
            id = "BUY_NICE_CAR",
            text = "Spend $25,000 on something nicer.",
            requiresMoney = 25000,
            outcome = {
                tags = {"purchase","vehicle","luxury"},
                severity = 3,
                statDelta = { DrivingSkill = 2, Charisma = 2 },
                careerDelta = {
                    xp = 8,
                    prestige = 4,
                    fame = 2,
                    money = -25000,
                },
                addVehicle = {
                    id = "car_1",
                    type = "car",
                    make = "Subaru",
                    model = "WRX",
                    year = 2015,
                    value = 25000,
                    condition = 85,
                    raceCount = 0,
                    crashes = 0,
                },
                flagsAdd = { FIRST_CAR_OWNED = true, NICE_CAR = true },
                narrative = "You buy something that turns heads. Sponsors notice. The car becomes part of your brand."
            }
        },
        {
            id = "SAVE_MORE",
            text = "Keep saving for something really special.",
            outcome = {
                tags = {"patience"},
                severity = 1,
                statDelta = { Intelligence = 1 },
                careerDelta = {
                    xp = 2,
                },
                narrative = "You resist the urge. Maybe next year you'll have enough for something that matches your ambition."
            }
        },
    }
})

------------------------------------------------
-- TRANSITION: JUNIOR → PRO OR STREET
------------------------------------------------

ev({
    id = "RACE_TRANSITION_PRO_OR_STREET",
    title = "Fork in the Road: Pro Seat vs Street Racing",
    description = "A lower-end pro series offers you a risky underfunded seat. At the same time, a crew invites you into serious illegal street racing with quick cash.",
    minAge = 19,
    maxAge = 27,
    stages = {"JUNIOR_FORMULA"},
    weight = 9,
    tags = {"fork","pro","street"},
    requirements = {
        traitsAny = {"RACER"},
    },
    choices = {
        {
            id = "TAKE_UNDERFUNDED_PRO_SEAT",
            text = "Take the underfunded pro seat and grind.",
            outcome = {
                tags = {"pro","grind"},
                severity = 5,
                statDelta = { MentalHealth = -2, Fitness = 1 },
                careerDelta = {
                    xp = 25,
                    prestige = 8,
                    fame = 5,
                    money = 0,
                    stageOverride = "PRO_CIRCUIT",
                },
                flagsAdd = { UNDERFUNDED_PRO = true },
                narrative = "You sign with a team that runs on duct tape and miracles. It's a brutal ladder, but it's *real*."
            }
        },
        {
            id = "JOIN_STREET",
            text = "Join the illegal street scene and chase cash and chaos.",
            outcome = {
                tags = {"street","illegal","cash"},
                severity = 7,
                statDelta = { RiskAffinity = 3, MentalHealth = -1 },
                addTraits = {"RECKLESS","THRILLSEEKER"},
                careerDelta = {
                    xp = 15,
                    prestige = 3,
                    fame = 4,
                    money = 5000,
                    risk = 6,
                    stageOverride = "STREET_RACER",
                },
                flagsAdd = { OUTLAW_PATH = true },
                narrative = "Neon, sirens, and sketchy payouts. It's not FIA-approved, but it scratches the itch and pays in cash."
            }
        },
        {
            id = "STEP_BACK",
            text = "Step back, consider engineering or normal life instead.",
            outcome = {
                tags = {"stepback","fallback"},
                severity = 4,
                statDelta = { MentalHealth = -1 },
                careerDelta = {
                    xp = 5,
                    prestige = -2,
                },
                flagsAdd = { CONSIDERING_EXIT = true },
                narrative = "You pause chasing the top. Whether it's wisdom or fear depends on what you do next."
            }
        },
    }
})

------------------------------------------------
-- STAGE: PRO CIRCUIT (20+)
------------------------------------------------

ev({
    id = "RACE_PRO_BRUTAL_SEASON",
    title = "Brutal First Pro Season",
    description = "You finally race in a pro series. Travel, jetlag, politics, brutal fitness demands, and tiny mistakes costing big.",
    minAge = 20,
    maxAge = 35,
    stages = {"PRO_CIRCUIT"},
    weight = 9,
    tags = {"pro","season","burnout"},
    requirements = {
        traitsAny = {"RACER"},
    },
    choices = {
        {
            id = "ALL_IN_PRO",
            text = "Go fully all-in: training, simulator, media, everything.",
            outcome = {
                tags = {"all_in"},
                severity = 7,
                statDelta = { Fitness = 3, DrivingSkill = 3, MentalHealth = -3 },
                careerDelta = {
                    xp = 40,
                    prestige = 12,
                    fame = 10,
                    money = 6000,
                    totalRaces = 1,
                    wins = 1,
                },
                flagsAdd = { PRO_ESTABLISHED = true, PRO_BURN_RISK = true },
                narrative = "Your entire life becomes data, travel, and pressure. You earn respect—but at a price."
            }
        },
        {
            id = "MANAGEABLE",
            text = "Find balance to avoid burning out.",
            outcome = {
                tags = {"balance"},
                severity = 4,
                statDelta = { Fitness = 2, DrivingSkill = 2, MentalHealth = -1 },
                careerDelta = {
                    xp = 30,
                    prestige = 8,
                    fame = 7,
                    money = 5000,
                    totalRaces = 1,
                    podiums = 1,
                },
                narrative = "You don't dominate like a maniac, but you also don't shatter yourself. Your career has legs."
            }
        },
        {
            id = "CHECKED_OUT",
            text = "You check out mentally and coast.",
            outcome = {
                tags = {"coast","decline"},
                severity = 6,
                statDelta = { MentalHealth = -2, DrivingSkill = -1 },
                careerDelta = {
                    xp = 10,
                    prestige = -3,
                    fame = -2,
                    money = 3000,
                    totalRaces = 1,
                },
                flagsAdd = { TEAM_CONSIDERING_DROP = true },
                narrative = "You go through the motions. Eventually, everyone can see it—even you."
            }
        },
    }
})

ev({
    id = "RACE_PRO_MAJOR_CRASH_DEATH_RISK",
    title = "High-Speed Crash",
    description = "You're pushing the limits in qualifying. The car snaps at 180mph. Everything goes black.",
    minAge = 20,
    maxAge = 40,
    stages = {"PRO_CIRCUIT"},
    weight = 4,
    tags = {"crash","death","risk"},
    requirements = {
        traitsAny = {"RACER","RECKLESS","THRILLSEEKER"},
        minRisk = 5,
    },
    choices = {
        {
            id = "SURVIVE_BADLY_HURT",
            text = "You survive, but you're badly hurt.",
            outcome = {
                tags = {"crash","injury","survival"},
                severity = 9,
                statDelta = { Fitness = -5, MentalHealth = -4, Health = -10 },
                addTraits = {"ANXIOUS"},
                careerDelta = {
                    xp = 5,
                    prestige = -2,
                    risk = 2,
                    crashes = 1,
                    deaths = 1,
                },
                flagsAdd = { MAJOR_CRASH_SURVIVED = true, CRASH_TRAUMA = true },
                deathRisk = 0.15,
                narrative = "You wake up in a hospital bed. Broken bones, but alive. The crash replays in your head every night."
            }
        },
        {
            id = "MIRACLE_ESCAPE",
            text = "Miraculously, you walk away with minor injuries.",
            outcome = {
                tags = {"crash","luck","survival"},
                severity = 6,
                statDelta = { MentalHealth = -2, Luck = 2 },
                careerDelta = {
                    xp = 10,
                    prestige = 3,
                    risk = 1,
                    crashes = 1,
                },
                flagsAdd = { MIRACLE_ESCAPE = true },
                deathRisk = 0.05,
                narrative = "The car is destroyed, but you climb out. The paddock calls it a miracle. You feel invincible—maybe too much."
            }
        },
        {
            id = "FATAL_CRASH",
            text = "The impact is too severe. You don't survive.",
            outcome = {
                tags = {"crash","death"},
                severity = 10,
                statDelta = { Health = -100 },
                careerDelta = {
                    crashes = 1,
                    deaths = 1,
                },
                flagsAdd = { FATAL_CRASH = true },
                deathRisk = 0.30,
                narrative = "The impact is catastrophic. Your racing career ends in tragedy. The sport mourns another lost talent."
            }
        },
    }
})

ev({
    id = "RACE_PRO_BUY_RACE_CAR",
    title = "Buy Your Own Race Car",
    description = "You've made enough money to buy your own race car. A used GT3 or single-seater that you can run in privateer series.",
    minAge = 22,
    maxAge = 35,
    stages = {"PRO_CIRCUIT"},
    weight = 6,
    tags = {"purchase","race_car","vehicle"},
    requirements = {
        traitsAny = {"RACER"},
        minPrestige = 8,
        flagsAny = {"PRO_ESTABLISHED"},
    },
    choices = {
        {
            id = "BUY_USED_GT3",
            text = "Spend $150,000 on a used GT3 car.",
            requiresMoney = 150000,
            outcome = {
                tags = {"purchase","vehicle"},
                severity = 3,
                statDelta = { DrivingSkill = 2, Charisma = 2 },
                careerDelta = {
                    xp = 15,
                    prestige = 5,
                    fame = 3,
                    money = -150000,
                },
                addVehicle = {
                    id = "race_car_1",
                    type = "race_car",
                    make = "Porsche",
                    model = "911 GT3",
                    year = 2018,
                    value = 150000,
                    condition = 75,
                    raceCount = 0,
                    crashes = 0,
                },
                flagsAdd = { OWN_RACE_CAR = true },
                narrative = "You buy the car. It's yours to race, maintain, and potentially destroy. The freedom is intoxicating."
            }
        },
        {
            id = "BUY_SINGLE_SEATER",
            text = "Spend $200,000 on a single-seater.",
            requiresMoney = 200000,
            outcome = {
                tags = {"purchase","vehicle"},
                severity = 4,
                statDelta = { DrivingSkill = 3, Charisma = 3 },
                careerDelta = {
                    xp = 20,
                    prestige = 6,
                    fame = 4,
                    money = -200000,
                },
                addVehicle = {
                    id = "race_car_1",
                    type = "race_car",
                    make = "Formula",
                    model = "F3",
                    year = 2019,
                    value = 200000,
                    condition = 80,
                    raceCount = 0,
                    crashes = 0,
                },
                flagsAdd = { OWN_RACE_CAR = true, SINGLE_SEATER_OWNER = true },
                narrative = "You buy a proper single-seater. It's raw, fast, and expensive. But it's yours, and that's everything."
            }
        },
        {
            id = "KEEP_RENTING",
            text = "Keep renting and save the money.",
            outcome = {
                tags = {"patience"},
                severity = 1,
                statDelta = { Intelligence = 1 },
                careerDelta = {
                    xp = 3,
                },
                narrative = "You resist. Maybe when you're more established, you'll buy something that matches your status."
            }
        },
    }
})

------------------------------------------------
-- STAGE: STREET (20+) – OUTLAW PATH
------------------------------------------------

ev({
    id = "RACE_STREET_POLICE_HEAT",
    title = "Police Heat Rising",
    description = "Your street racing crew gets more attention from cops and social media.",
    minAge = 20,
    maxAge = 35,
    stages = {"STREET_RACER"},
    weight = 8,
    tags = {"street","police","risk"},
    requirements = {
        traitsAny = {"RACER","RECKLESS"},
    },
    choices = {
        {
            id = "UP_THE_ANTY",
            text = "Escalate with wilder races and viral stunts.",
            outcome = {
                tags = {"street","viral","risk"},
                severity = 8,
                statDelta = { RiskAffinity = 3, MentalHealth = -1 },
                careerDelta = {
                    xp = 20,
                    prestige = 5,
                    fame = 8,
                    money = 6000,
                    risk = 10,
                    crashes = 1,
                    totalRaces = 1,
                },
                flagsAdd = { LAW_ON_YOU = true },
                deathRisk = 0.10,
                narrative = "You chase clout and cash at the same time. Views spike, so does the chance your life ends in a siren."
            }
        },
        {
            id = "LAY_LOW",
            text = "Lay low and race smaller, quiet meets.",
            outcome = {
                tags = {"caution"},
                severity = 4,
                statDelta = { RiskAffinity = -1 },
                careerDelta = {
                    xp = 10,
                    prestige = 2,
                    fame = -1,
                    money = 3000,
                    risk = -4,
                    totalRaces = 1,
                },
                narrative = "You still chase the thrill, but you stop handing the cops a highlight reel for free."
            }
        },
        {
            id = "EXIT_STREET",
            text = "Walk away and try to move into legal motorsport or a normal job.",
            outcome = {
                tags = {"exit","redeem"},
                severity = 6,
                statDelta = { MentalHealth = 2 },
                careerDelta = {
                    xp = 5,
                    prestige = -1,
                    fame = -3,
                    risk = -8,
                },
                flagsAdd = { STREET_EXITED = true },
                narrative = "You kill the engine, maybe for good. Whether anyone believes you changed is another story."
            }
        },
    }
})

ev({
    id = "RACE_STREET_FATAL_CHASE",
    title = "Police Chase Gone Wrong",
    description = "You're running from the cops after a street race. The chase gets out of control.",
    minAge = 20,
    maxAge = 35,
    stages = {"STREET_RACER"},
    weight = 3,
    tags = {"street","police","death"},
    requirements = {
        traitsAny = {"RACER","RECKLESS"},
        flagsAny = {"LAW_ON_YOU"},
        minRisk = 8,
    },
    choices = {
        {
            id = "SURVIVE_CRASH",
            text = "You crash but survive. Jail time awaits.",
            outcome = {
                tags = {"crash","jail","survival"},
                severity = 9,
                statDelta = { Fitness = -3, MentalHealth = -3, Health = -5 },
                careerDelta = {
                    xp = 0,
                    prestige = -5,
                    risk = 3,
                    crashes = 1,
                    deaths = 1,
                },
                flagsAdd = { ARRESTED = true, JAIL_TIME = true },
                deathRisk = 0.20,
                narrative = "You crash into a barrier. Cops swarm. You're going to jail, but at least you're alive."
            }
        },
        {
            id = "ESCAPE",
            text = "You manage to escape, but you're now a wanted person.",
            outcome = {
                tags = {"escape","wanted"},
                severity = 7,
                statDelta = { MentalHealth = -2, RiskAffinity = 2 },
                careerDelta = {
                    xp = 5,
                    prestige = -2,
                    risk = 5,
                },
                flagsAdd = { WANTED = true, ESCAPED_POLICE = true },
                narrative = "You lose them in back alleys. But now you're on their radar. Every siren makes you jump."
            }
        },
        {
            id = "FATAL_CRASH",
            text = "The chase ends in a fatal crash.",
            outcome = {
                tags = {"crash","death"},
                severity = 10,
                statDelta = { Health = -100 },
                careerDelta = {
                    crashes = 1,
                    deaths = 1,
                },
                flagsAdd = { FATAL_CRASH = true },
                deathRisk = 0.40,
                narrative = "You lose control at high speed. The impact is fatal. Your street racing career ends in tragedy."
            }
        },
    }
})

ev({
    id = "RACE_STREET_BUY_TUNED_CAR",
    title = "Buy a Tuned Street Racer",
    description = "You've made enough from street racing to buy a proper tuned car. Something fast, loud, and illegal.",
    minAge = 20,
    maxAge = 32,
    stages = {"STREET_RACER"},
    weight = 7,
    tags = {"purchase","car","vehicle","street"},
    requirements = {
        traitsAny = {"RACER","RECKLESS"},
        flagsAny = {"OUTLAW_PATH"},
    },
    choices = {
        {
            id = "BUY_TUNED_CAR",
            text = "Spend $30,000 on a heavily tuned street racer.",
            requiresMoney = 30000,
            outcome = {
                tags = {"purchase","vehicle"},
                severity = 3,
                statDelta = { DrivingSkill = 2, RiskAffinity = 2 },
                careerDelta = {
                    xp = 12,
                    prestige = 3,
                    fame = 3,
                    money = -30000,
                    risk = 2,
                },
                addVehicle = {
                    id = "street_car_1",
                    type = "car",
                    make = "Nissan",
                    model = "Skyline GT-R",
                    year = 1998,
                    value = 30000,
                    condition = 70,
                    modifications = {"turbo", "tune", "suspension"},
                    raceCount = 0,
                    crashes = 0,
                },
                flagsAdd = { TUNED_CAR_OWNED = true },
                narrative = "You buy the car. It's loud, fast, and illegal. Perfect for street racing. The cops will hate it."
            }
        },
        {
            id = "BUY_SUPERCAR",
            text = "Spend $80,000 on something more exotic.",
            requiresMoney = 80000,
            outcome = {
                tags = {"purchase","vehicle","luxury"},
                severity = 4,
                statDelta = { DrivingSkill = 3, Charisma = 2, RiskAffinity = 2 },
                careerDelta = {
                    xp = 15,
                    prestige = 5,
                    fame = 5,
                    money = -80000,
                    risk = 3,
                },
                addVehicle = {
                    id = "street_car_1",
                    type = "car",
                    make = "Lamborghini",
                    model = "Gallardo",
                    year = 2010,
                    value = 80000,
                    condition = 85,
                    modifications = {"tune", "exhaust"},
                    raceCount = 0,
                    crashes = 0,
                },
                flagsAdd = { TUNED_CAR_OWNED = true, SUPERCAR_OWNED = true },
                narrative = "You buy something that screams money. It turns heads and draws heat. Exactly what you want."
            }
        },
        {
            id = "KEEP_RENTING",
            text = "Keep using borrowed cars.",
            outcome = {
                tags = {"patience"},
                severity = 1,
                statDelta = { Intelligence = 1 },
                careerDelta = {
                    xp = 2,
                },
                narrative = "You resist. Maybe when you're more established in the scene, you'll buy something that matches your status."
            }
        },
    }
})

------------------------------------------------
-- STAGE: MECHANIC (fallback / pivot)
------------------------------------------------

ev({
    id = "RACE_MECHANIC_PIT_CREW",
    title = "Pit Crew Mechanic Role",
    description = "You land a job as a mechanic / pit crew for a serious team.",
    minAge = 20,
    maxAge = 40,
    stages = {"MECHANIC"},
    weight = 9,
    tags = {"mechanic","career_pivot"},
    requirements = {
        traitsAny = {"MECHANICAPPT","TECHYKID"},
    },
    choices = {
        {
            id = "LOVE_IT",
            text = "You lean into it and take pride in making cars fast for others.",
            outcome = {
                tags = {"craft","support"},
                severity = 3,
                statDelta = { TechSkill = 3, Intelligence = 2, MentalHealth = 1 },
                careerDelta = {
                    xp = 25,
                    prestige = 6,
                    fame = 2,
                    money = 5000,
                },
                narrative = "You realize you're just as vital on the spanners as behind the wheel. Wins still feel like yours."
            }
        },
        {
            id = "RESENT_IT",
            text = "You resent not being the one in the cockpit.",
            outcome = {
                tags = {"resent"},
                severity = 4,
                statDelta = { MentalHealth = -3 },
                careerDelta = {
                    xp = 10,
                    prestige = 2,
                    money = 4000,
                },
                flagsAdd = { LINGERING_DRIVER_REGRET = true },
                narrative = "Every time the car leaves the box, you imagine it's you. It eats at you between sessions."
            }
        },
    }
})

------------------------------------------------
-- MORE PREP STAGE EVENTS (10-15)
------------------------------------------------

ev({
    id = "RACE_PREP_GO_KART_BIRTHDAY",
    title = "Go-Kart Birthday Party",
    description = "Your friend's birthday party is at a go-kart track. You've never driven one before, but you're itching to try.",
    minAge = 10,
    maxAge = 14,
    stages = {"NONE", "PREP"},
    weight = 6,
    tags = {"prep","kart","first_time"},
    requirements = {
        traitsAny = {"RACER"},
    },
    choices = {
        {
            id = "DOMINATE",
            text = "You dominate every session and ask for more laps.",
            outcome = {
                tags = {"race","talent"},
                severity = 2,
                statDelta = { DrivingSkill = 2, Fitness = 1 },
                careerDelta = {
                    xp = 4,
                    prestige = 2,
                },
                flagsAdd = { GO_KART_NATURAL = true },
                narrative = "You lap everyone multiple times. The track owner notices and offers you a discount for practice sessions."
            }
        },
        {
            id = "CRASH_LEARN",
            text = "You crash a few times but keep getting back in.",
            outcome = {
                tags = {"crash","persistence"},
                severity = 3,
                statDelta = { DrivingSkill = 1, MentalHealth = -1 },
                careerDelta = {
                    xp = 2,
                    prestige = 0,
                    crashes = 1,
                },
                narrative = "You spin out, hit barriers, but you don't quit. By the end, you're keeping up with the fast kids."
            }
        },
        {
            id = "OBSERVE",
            text = "You watch others and take mental notes.",
            outcome = {
                tags = {"study","observation"},
                severity = 1,
                statDelta = { Intelligence = 1, DrivingSkill = 1 },
                careerDelta = {
                    xp = 1,
                },
                narrative = "You study the lines, braking points, and techniques. When you finally drive, you're surprisingly smooth."
            }
        },
    }
})

ev({
    id = "RACE_PREP_BIKE_CRASH_INJURY",
    title = "Bike Crash Injury",
    description = "You push too hard on a downhill race and crash. Your bike is mangled, and you're hurt.",
    minAge = 11,
    maxAge = 15,
    stages = {"NONE", "PREP"},
    weight = 5,
    tags = {"crash","injury","bike"},
    requirements = {
        traitsAny = {"RACER","THRILLSEEKER"},
        flagsAny = {"PREP_BIKE_RACER"},
    },
    choices = {
        {
            id = "GET_BACK_ON",
            text = "As soon as you're healed, you're back on a bike.",
            outcome = {
                tags = {"resilience","determination"},
                severity = 4,
                statDelta = { Fitness = -2, MentalHealth = -1, RiskAffinity = 1 },
                addTraits = {"THRILLSEEKER"},
                careerDelta = {
                    xp = 3,
                    prestige = 1,
                    crashes = 1,
                },
                flagsAdd = { CRASH_SURVIVOR = true },
                narrative = "The crash doesn't scare you—it makes you hungrier. You're back on two wheels before the doctor clears you."
            }
        },
        {
            id = "FEAR_DEVELOPS",
            text = "The crash leaves you with lasting fear.",
            outcome = {
                tags = {"fear","trauma"},
                severity = 5,
                statDelta = { MentalHealth = -3, RiskAffinity = -2 },
                addTraits = {"ANXIOUS"},
                careerDelta = {
                    xp = 0,
                    prestige = -1,
                    crashes = 1,
                },
                flagsAdd = { CRASH_TRAUMA = true },
                narrative = "Every time you see a bike, you remember the impact. The fear might never leave you."
            }
        },
        {
            id = "SWITCH_FOCUS",
            text = "You decide bikes are too dangerous and focus on karts instead.",
            outcome = {
                tags = {"pivot","wisdom"},
                severity = 3,
                statDelta = { Intelligence = 1, MentalHealth = -1 },
                careerDelta = {
                    xp = 2,
                    prestige = 0,
                    crashes = 1,
                },
                narrative = "You realize karts are safer and more structured. Maybe this is the smarter path."
            }
        },
    }
})

ev({
    id = "RACE_PREP_PARENT_RACE_DAY",
    title = "Parent Takes You to Real Race",
    description = "Your supportive parent takes you to watch a real race. The noise, speed, and atmosphere overwhelm you.",
    minAge = 12,
    maxAge = 16,
    stages = {"NONE", "PREP"},
    weight = 7,
    tags = {"prep","family","inspiration"},
    requirements = {
        traitsAny = {"RACER"},
        flagsAny = {"PARENT_SUPPORT_RISK"},
    },
    choices = {
        {
            id = "INSPIRED",
            text = "You're completely inspired and know this is your future.",
            outcome = {
                tags = {"inspiration","determination"},
                severity = 3,
                statDelta = { DrivingSkill = 1, MentalHealth = 2, Charisma = 1 },
                careerDelta = {
                    xp = 5,
                    prestige = 2,
                },
                flagsAdd = { RACE_INSPIRED = true },
                narrative = "You watch every lap, memorize every corner. This is where you belong. Nothing else matters."
            }
        },
        {
            id = "OVERWHELMED",
            text = "The scale and danger overwhelm you, but you're still drawn to it.",
            outcome = {
                tags = {"fear","attraction"},
                severity = 4,
                statDelta = { MentalHealth = -1, RiskAffinity = 1 },
                careerDelta = {
                    xp = 3,
                    prestige = 1,
                },
                narrative = "You're scared, but you can't look away. The danger is part of the appeal."
            }
        },
        {
            id = "FOCUS_MECHANICS",
            text = "You're more interested in the mechanics than the driving.",
            outcome = {
                tags = {"engineering","pivot"},
                severity = 2,
                statDelta = { TechSkill = 2, Intelligence = 1 },
                addTraits = {"MECHANICAPPT"},
                careerDelta = {
                    xp = 4,
                    prestige = 1,
                },
                flagsAdd = { ENGINEERING_INTEREST = true },
                narrative = "You spend the day in the paddock, asking engineers questions. Maybe you're meant to build, not drive."
            }
        },
    }
})

------------------------------------------------
-- MORE KARTING EVENTS (14-18)
------------------------------------------------

ev({
    id = "RACE_KART_RIVALRY_DEVELOPS",
    title = "Rivalry Develops",
    description = "Another driver keeps beating you. They're faster, richer, and more connected. A rivalry is born.",
    minAge = 14,
    maxAge = 18,
    stages = {"KARTING"},
    weight = 8,
    tags = {"rivalry","competition","kart"},
    requirements = {
        traitsAny = {"RACER"},
        flagsAny = {"FIRST_KART_EXPERIENCE"},
    },
    choices = {
        {
            id = "STUDY_THEM",
            text = "You study their lines, their technique, everything.",
            outcome = {
                tags = {"study","improvement"},
                severity = 3,
                statDelta = { DrivingSkill = 2, Intelligence = 1 },
                careerDelta = {
                    xp = 8,
                    prestige = 2,
                },
                flagsAdd = { RIVALRY_ACTIVE = true },
                narrative = "You become obsessed with beating them. Every race, you get closer. The rivalry makes you better."
            }
        },
        {
            id = "DIRTY_RACING",
            text = "You start racing them dirty, pushing them off track.",
            outcome = {
                tags = {"dirty","aggression"},
                severity = 4,
                statDelta = { RiskAffinity = 2, Charisma = -1 },
                addTraits = {"RECKLESS"},
                careerDelta = {
                    xp = 5,
                    prestige = -1,
                    risk = 2,
                },
                flagsAdd = { RIVALRY_ACTIVE = true, DIRTY_DRIVER = true },
                narrative = "You become known as a dirty driver. You win some races, but you lose respect in the paddock."
            }
        },
        {
            id = "IGNORE_THEM",
            text = "You ignore them and focus on your own improvement.",
            outcome = {
                tags = {"focus","maturity"},
                severity = 2,
                statDelta = { DrivingSkill = 1, MentalHealth = 1 },
                careerDelta = {
                    xp = 6,
                    prestige = 1,
                },
                narrative = "You don't let them get in your head. You focus on being the best version of yourself."
            }
        },
    }
})

ev({
    id = "RACE_KART_CHAMPIONSHIP_FINAL",
    title = "Championship Final",
    description = "The final race of the season. You're in contention for the championship. Everything comes down to this.",
    minAge = 15,
    maxAge = 18,
    stages = {"KARTING"},
    weight = 9,
    tags = {"championship","final","kart"},
    requirements = {
        traitsAny = {"RACER"},
        minPrestige = 4,
        flagsAny = {"OWN_KART"},
    },
    choices = {
        {
            id = "WIN_CHAMPIONSHIP",
            text = "You win the championship with a perfect drive.",
            outcome = {
                tags = {"victory","championship"},
                severity = 5,
                statDelta = { DrivingSkill = 3, MentalHealth = 3, Charisma = 2 },
                careerDelta = {
                    xp = 30,
                    prestige = 10,
                    fame = 5,
                    totalRaces = 1,
                    wins = 1,
                },
                flagsAdd = { KARTING_CHAMPION = true },
                narrative = "You cross the line first. The championship is yours. Scouts from junior formula teams are watching."
            }
        },
        {
            id = "LOSE_CLOSE",
            text = "You finish second by less than a second.",
            outcome = {
                tags = {"defeat","close"},
                severity = 4,
                statDelta = { MentalHealth = -2, DrivingSkill = 1 },
                careerDelta = {
                    xp = 15,
                    prestige = 5,
                    fame = 2,
                    totalRaces = 1,
                    podiums = 1,
                },
                narrative = "You come so close. Second place hurts more than last. But you've proven you belong at this level."
            }
        },
        {
            id = "CRASH_OUT",
            text = "You crash out trying to make a pass for the lead.",
            outcome = {
                tags = {"crash","failure"},
                severity = 6,
                statDelta = { MentalHealth = -4, Fitness = -2 },
                addTraits = {"ANXIOUS"},
                careerDelta = {
                    xp = 5,
                    prestige = -2,
                    crashes = 1,
                },
                flagsAdd = { CHAMPIONSHIP_CRASH = true },
                narrative = "You throw it away. The crash replays in your head for months. You had it, and you lost it."
            }
        },
    }
})

ev({
    id = "RACE_KART_UPGRADE_KART",
    title = "Upgrade Your Kart",
    description = "You've saved enough to upgrade your kart with better parts. New engine, better chassis, or better tires?",
    minAge = 15,
    maxAge = 18,
    stages = {"KARTING"},
    weight = 7,
    tags = {"upgrade","kart","purchase"},
    requirements = {
        traitsAny = {"RACER"},
        flagsAny = {"OWN_KART"},
        minPrestige = 3,
    },
    choices = {
        {
            id = "UPGRADE_ENGINE",
            text = "Spend $1,500 on a better engine.",
            requiresMoney = 1500,
            outcome = {
                tags = {"upgrade","engine"},
                severity = 2,
                statDelta = { DrivingSkill = 2 },
                careerDelta = {
                    xp = 8,
                    prestige = 2,
                    money = -1500,
                },
                flagsAdd = { KART_UPGRADED = true },
                narrative = "The new engine gives you more power. You're noticeably faster on straights."
            }
        },
        {
            id = "UPGRADE_CHASSIS",
            text = "Spend $2,000 on a better chassis.",
            requiresMoney = 2000,
            outcome = {
                tags = {"upgrade","chassis"},
                severity = 3,
                statDelta = { DrivingSkill = 3 },
                careerDelta = {
                    xp = 10,
                    prestige = 3,
                    money = -2000,
                },
                flagsAdd = { KART_UPGRADED = true },
                narrative = "The new chassis handles better. You gain time in corners where it matters most."
            }
        },
        {
            id = "SAVE_MONEY",
            text = "Keep saving for a completely new kart.",
            outcome = {
                tags = {"patience"},
                severity = 1,
                statDelta = { Intelligence = 1 },
                careerDelta = {
                    xp = 2,
                },
                narrative = "You resist the upgrade. Maybe next season you'll have enough for a brand new kart."
            }
        },
    }
})

------------------------------------------------
-- MORE JUNIOR FORMULA EVENTS (17-23)
------------------------------------------------

ev({
    id = "RACE_JUNIOR_FIRST_POLE",
    title = "First Pole Position",
    description = "You qualify on pole for the first time in junior formula. The pressure is immense.",
    minAge = 17,
    maxAge = 23,
    stages = {"JUNIOR_FORMULA"},
    weight = 8,
    tags = {"pole","achievement","junior"},
    requirements = {
        traitsAny = {"RACER"},
        flagsAny = {"JUNIOR_SEAT_SECURED"},
    },
    choices = {
        {
            id = "CONVERT_TO_WIN",
            text = "You convert pole to victory with a perfect race.",
            outcome = {
                tags = {"victory","pole"},
                severity = 4,
                statDelta = { DrivingSkill = 2, MentalHealth = 2 },
                careerDelta = {
                    xp = 25,
                    prestige = 6,
                    fame = 4,
                    totalRaces = 1,
                    wins = 1,
                },
                flagsAdd = { FIRST_POLE_WIN = true },
                narrative = "You lead from start to finish. Perfect race. The team celebrates, and you feel unstoppable."
            }
        },
        {
            id = "LOSE_LEAD",
            text = "You lose the lead on the first lap and finish third.",
            outcome = {
                tags = {"defeat","pressure"},
                severity = 3,
                statDelta = { MentalHealth = -2, DrivingSkill = 1 },
                careerDelta = {
                    xp = 10,
                    prestige = 2,
                    fame = 1,
                    totalRaces = 1,
                    podiums = 1,
                },
                narrative = "You get passed immediately. The pressure got to you. You still finish on the podium, but it feels like failure."
            }
        },
        {
            id = "CRASH_FROM_POLE",
            text = "You crash on the first lap trying to defend the lead.",
            outcome = {
                tags = {"crash","failure"},
                severity = 5,
                statDelta = { MentalHealth = -3, Fitness = -1 },
                careerDelta = {
                    xp = 5,
                    prestige = -1,
                    crashes = 1,
                },
                flagsAdd = { POLE_CRASH = true },
                narrative = "You spin on cold tires. The car is destroyed. You've thrown away your best chance."
            }
        },
    }
})

ev({
    id = "RACE_JUNIOR_TEAMMATE_CONFLICT",
    title = "Teammate Conflict",
    description = "Your teammate keeps taking you out. They have more money, so the team protects them. You're getting fed up.",
    minAge = 18,
    maxAge = 23,
    stages = {"JUNIOR_FORMULA"},
    weight = 7,
    tags = {"conflict","team","politics"},
    requirements = {
        traitsAny = {"RACER"},
        flagsAny = {"JUNIOR_SEAT_SECURED"},
    },
    choices = {
        {
            id = "RETALIATE",
            text = "You take them out in the next race.",
            outcome = {
                tags = {"retaliation","aggression"},
                severity = 5,
                statDelta = { MentalHealth = -2, RiskAffinity = 2 },
                addTraits = {"RECKLESS"},
                careerDelta = {
                    xp = 5,
                    prestige = -3,
                    crashes = 1,
                },
                flagsAdd = { TEAMMATE_FEUD = true },
                narrative = "You punt them off. The team is furious. You might get fired, but at least you stood up for yourself."
            }
        },
        {
            id = "OUTDRIVE_THEM",
            text = "You focus on outdriving them cleanly.",
            outcome = {
                tags = {"skill","maturity"},
                severity = 3,
                statDelta = { DrivingSkill = 3, MentalHealth = 1 },
                careerDelta = {
                    xp = 15,
                    prestige = 4,
                    fame = 2,
                    totalRaces = 1,
                    wins = 1,
                },
                flagsAdd = { CLEAN_DRIVER = true },
                narrative = "You beat them fair and square. The team can't ignore your talent anymore."
            }
        },
        {
            id = "SWITCH_TEAMS",
            text = "You request a transfer to another team.",
            outcome = {
                tags = {"transfer","politics"},
                severity = 4,
                statDelta = { MentalHealth = -1, Charisma = 1 },
                careerDelta = {
                    xp = 8,
                    prestige = 1,
                },
                flagsAdd = { TEAM_SWITCHED = true },
                narrative = "You find a new team that values talent over money. It's a fresh start."
            }
        },
    }
})

ev({
    id = "RACE_JUNIOR_BUY_TRACK_CAR",
    title = "Buy a Track Car",
    description = "You want to practice on track days. A used track-prepped car would help you improve.",
    minAge = 18,
    maxAge = 23,
    stages = {"JUNIOR_FORMULA"},
    weight = 6,
    tags = {"purchase","car","track"},
    requirements = {
        traitsAny = {"RACER"},
        minPrestige = 4,
    },
    choices = {
        {
            id = "BUY_TRACK_CAR",
            text = "Spend $15,000 on a track-prepped car.",
            requiresMoney = 15000,
            outcome = {
                tags = {"purchase","vehicle"},
                severity = 2,
                statDelta = { DrivingSkill = 2 },
                careerDelta = {
                    xp = 10,
                    prestige = 2,
                    money = -15000,
                },
                addVehicle = {
                    id = "track_car_1",
                    type = "car",
                    make = "Honda",
                    model = "S2000",
                    year = 2008,
                    value = 15000,
                    condition = 75,
                    modifications = {"roll_cage", "suspension", "tires"},
                    raceCount = 0,
                    crashes = 0,
                },
                flagsAdd = { TRACK_CAR_OWNED = true },
                narrative = "You buy a track car. Every weekend, you're at the track practicing. The improvement is noticeable."
            }
        },
        {
            id = "RENT_TRACK_TIME",
            text = "Rent track time instead of buying a car.",
            requiresMoney = 5000,
            outcome = {
                tags = {"practice","rental"},
                severity = 1,
                statDelta = { DrivingSkill = 1 },
                careerDelta = {
                    xp = 5,
                    prestige = 1,
                    money = -5000,
                },
                narrative = "You rent track time. It's expensive, but you get practice without the commitment of ownership."
            }
        },
        {
            id = "SKIP_TRACK_DAYS",
            text = "Focus on simulator practice instead.",
            outcome = {
                tags = {"simulator","practice"},
                severity = 1,
                statDelta = { TechSkill = 1, Intelligence = 1 },
                careerDelta = {
                    xp = 3,
                },
                narrative = "You invest in a better simulator setup. It's cheaper and you can practice anytime."
            }
        },
    }
})

------------------------------------------------
-- MORE PRO CIRCUIT EVENTS (20+)
------------------------------------------------

ev({
    id = "RACE_PRO_CHAMPIONSHIP_BATTLE",
    title = "Championship Battle",
    description = "You're in a tight championship fight. Every point matters. The pressure is crushing.",
    minAge = 22,
    maxAge = 35,
    stages = {"PRO_CIRCUIT"},
    weight = 8,
    tags = {"championship","pressure","pro"},
    requirements = {
        traitsAny = {"RACER"},
        flagsAny = {"PRO_ESTABLISHED"},
        minPrestige = 10,
    },
    choices = {
        {
            id = "WIN_CHAMPIONSHIP",
            text = "You win the championship with consistent driving.",
            outcome = {
                tags = {"victory","championship"},
                severity = 6,
                statDelta = { DrivingSkill = 3, MentalHealth = 4, Charisma = 3 },
                careerDelta = {
                    xp = 50,
                    prestige = 15,
                    fame = 12,
                    money = 100000,
                    totalRaces = 1,
                    wins = 1,
                },
                flagsAdd = { PRO_CHAMPION = true },
                narrative = "You win the championship. The celebration is massive. You've proven you belong at the top level."
            }
        },
        {
            id = "LOSE_CHAMPIONSHIP",
            text = "You lose the championship by a few points.",
            outcome = {
                tags = {"defeat","close"},
                severity = 5,
                statDelta = { MentalHealth = -3, DrivingSkill = 1 },
                careerDelta = {
                    xp = 25,
                    prestige = 8,
                    fame = 5,
                    totalRaces = 1,
                    podiums = 1,
                },
                narrative = "You come so close. Second in the championship hurts. But you've proven you can compete at this level."
            }
        },
        {
            id = "CRASH_CHAMPIONSHIP",
            text = "You crash out of the final race and lose the championship.",
            outcome = {
                tags = {"crash","failure"},
                severity = 7,
                statDelta = { MentalHealth = -5, Fitness = -2 },
                addTraits = {"ANXIOUS"},
                careerDelta = {
                    xp = 10,
                    prestige = -3,
                    crashes = 1,
                },
                flagsAdd = { CHAMPIONSHIP_CRASH = true },
                narrative = "You throw it all away. The crash replays in your head. You had it, and you lost it in the worst way."
            }
        },
    }
})

ev({
    id = "RACE_PRO_MAJOR_SPONSOR",
    title = "Major Sponsor Offer",
    description = "A major brand wants to sponsor you. Big money, but they want control over your image.",
    minAge = 22,
    maxAge = 35,
    stages = {"PRO_CIRCUIT"},
    weight = 7,
    tags = {"sponsor","money","image"},
    requirements = {
        traitsAny = {"RACER"},
        minFame = 5,
        flagsAny = {"PRO_ESTABLISHED"},
    },
    choices = {
        {
            id = "ACCEPT_SPONSOR",
            text = "Accept the sponsorship and the image control.",
            outcome = {
                tags = {"sponsor","money"},
                severity = 3,
                statDelta = { Charisma = 2, MentalHealth = -1 },
                careerDelta = {
                    xp = 15,
                    prestige = 5,
                    fame = 3,
                    money = 50000,
                },
                flagsAdd = { MAJOR_SPONSOR = true },
                narrative = "You sign the deal. The money is life-changing, but you feel like you're selling part of yourself."
            }
        },
        {
            id = "NEGOTIATE_CONTROL",
            text = "Negotiate to keep some creative control.",
            outcome = {
                tags = {"sponsor","negotiate"},
                severity = 4,
                statDelta = { Charisma = 3, Intelligence = 2 },
                careerDelta = {
                    xp = 20,
                    prestige = 6,
                    fame = 4,
                    money = 40000,
                },
                flagsAdd = { MAJOR_SPONSOR = true, BRAND_CONTROL = true },
                narrative = "You negotiate a better deal. You keep some control over your image while still getting paid."
            }
        },
        {
            id = "DECLINE_SPONSOR",
            text = "Decline and keep your independence.",
            outcome = {
                tags = {"independence","pride"},
                severity = 2,
                statDelta = { MentalHealth = 2 },
                careerDelta = {
                    xp = 5,
                    prestige = 2,
                },
                narrative = "You walk away. The money would be nice, but your independence is worth more."
            }
        },
    }
})

ev({
    id = "RACE_PRO_FATAL_ACCIDENT_WITNESS",
    title = "Witness Fatal Accident",
    description = "A driver in your series dies in a crash. You saw it happen. The paddock is in shock.",
    minAge = 20,
    maxAge = 40,
    stages = {"PRO_CIRCUIT"},
    weight = 4,
    tags = {"death","trauma","witness"},
    requirements = {
        traitsAny = {"RACER"},
        flagsAny = {"PRO_ESTABLISHED"},
    },
    choices = {
        {
            id = "HARDEN",
            text = "You compartmentalize and keep racing.",
            outcome = {
                tags = {"numb","determination"},
                severity = 7,
                statDelta = { MentalHealth = -3, RiskAffinity = 2 },
                addTraits = {"THRILLSEEKER"},
                careerDelta = {
                    xp = 10,
                    prestige = 2,
                    risk = 3,
                },
                narrative = "You push the memory down. You keep racing. The danger is part of the game, and you accept it."
            }
        },
        {
            id = "QUESTION_CAREER",
            text = "You question if this is worth the risk.",
            outcome = {
                tags = {"doubt","fear"},
                severity = 8,
                statDelta = { MentalHealth = -5, RiskAffinity = -3 },
                addTraits = {"ANXIOUS"},
                careerDelta = {
                    xp = 3,
                    prestige = -2,
                    risk = -2,
                },
                flagsAdd = { QUESTIONING_CAREER = true },
                narrative = "You can't stop thinking about it. Is this worth dying for? The question haunts you."
            }
        },
        {
            id = "BECOME_SAFETY_ADVOCATE",
            text = "You become an advocate for safety improvements.",
            outcome = {
                tags = {"safety","advocacy"},
                severity = 5,
                statDelta = { Charisma = 2, MentalHealth = 1 },
                careerDelta = {
                    xp = 8,
                    prestige = 3,
                    fame = 2,
                },
                flagsAdd = { SAFETY_ADVOCATE = true },
                narrative = "You use your platform to push for better safety. You honor their memory by making the sport safer."
            }
        },
    }
})

ev({
    id = "RACE_PRO_BUY_SUPERCAR",
    title = "Buy a Supercar",
    description = "You've made enough money to buy a real supercar. Something that matches your racing status.",
    minAge = 24,
    maxAge = 40,
    stages = {"PRO_CIRCUIT"},
    weight = 6,
    tags = {"purchase","supercar","luxury"},
    requirements = {
        traitsAny = {"RACER"},
        minPrestige = 12,
        flagsAny = {"PRO_ESTABLISHED"},
    },
    choices = {
        {
            id = "BUY_SUPERCAR",
            text = "Spend $200,000 on a supercar.",
            requiresMoney = 200000,
            outcome = {
                tags = {"purchase","vehicle","luxury"},
                severity = 4,
                statDelta = { DrivingSkill = 2, Charisma = 3 },
                careerDelta = {
                    xp = 15,
                    prestige = 5,
                    fame = 5,
                    money = -200000,
                },
                addVehicle = {
                    id = "supercar_1",
                    type = "car",
                    make = "Ferrari",
                    model = "488 GTB",
                    year = 2018,
                    value = 200000,
                    condition = 95,
                    raceCount = 0,
                    crashes = 0,
                },
                flagsAdd = { SUPERCAR_OWNED = true },
                narrative = "You buy a supercar. It's fast, beautiful, and expensive. It matches your status as a pro racer."
            }
        },
        {
            id = "BUY_HYPERCAR",
            text = "Spend $500,000 on a hypercar.",
            requiresMoney = 500000,
            outcome = {
                tags = {"purchase","vehicle","luxury"},
                severity = 5,
                statDelta = { DrivingSkill = 3, Charisma = 4 },
                careerDelta = {
                    xp = 20,
                    prestige = 7,
                    fame = 8,
                    money = -500000,
                },
                addVehicle = {
                    id = "hypercar_1",
                    type = "car",
                    make = "McLaren",
                    model = "720S",
                    year = 2019,
                    value = 500000,
                    condition = 98,
                    raceCount = 0,
                    crashes = 0,
                },
                flagsAdd = { SUPERCAR_OWNED = true, HYPERCAR_OWNED = true },
                narrative = "You buy a hypercar. It's obscenely fast and expensive. You've made it."
            }
        },
        {
            id = "SAVE_MONEY",
            text = "Keep saving and invest the money instead.",
            outcome = {
                tags = {"patience","investment"},
                severity = 2,
                statDelta = { Intelligence = 2 },
                careerDelta = {
                    xp = 5,
                    prestige = 2,
                },
                narrative = "You resist the temptation. Maybe you'll buy one later, but for now, you're smarter with your money."
            }
        },
    }
})

------------------------------------------------
-- MORE STREET RACER EVENTS (20+)
------------------------------------------------

ev({
    id = "RACE_STREET_UNDERGROUND_RACE",
    title = "Underground Race",
    description = "You're invited to an underground race. High stakes, high risk, high reward.",
    minAge = 20,
    maxAge = 32,
    stages = {"STREET_RACER"},
    weight = 8,
    tags = {"street","underground","risk"},
    requirements = {
        traitsAny = {"RACER","RECKLESS","THRILLSEEKER"},
        flagsAny = {"OUTLAW_PATH"},
    },
    choices = {
        {
            id = "WIN_RACE",
            text = "You win the race and take home the prize money.",
            outcome = {
                tags = {"victory","money"},
                severity = 5,
                statDelta = { DrivingSkill = 2, RiskAffinity = 2 },
                careerDelta = {
                    xp = 20,
                    prestige = 4,
                    fame = 3,
                    money = 15000,
                    risk = 3,
                    totalRaces = 1,
                    wins = 1,
                },
                flagsAdd = { UNDERGROUND_WINNER = true },
                narrative = "You win. The cash is yours. You're becoming a legend in the underground scene."
            }
        },
        {
            id = "CRASH_RACE",
            text = "You crash trying to win. The car is destroyed.",
            outcome = {
                tags = {"crash","loss"},
                severity = 7,
                statDelta = { Fitness = -2, MentalHealth = -2 },
                careerDelta = {
                    xp = 5,
                    prestige = -2,
                    risk = 2,
                    crashes = 1,
                    money = -10000,
                },
                flagsAdd = { UNDERGROUND_CRASH = true },
                deathRisk = 0.10,
                narrative = "You crash hard. The car is totaled. You're lucky to walk away, but you've lost everything."
            }
        },
        {
            id = "POLICE_RAID",
            text = "The race gets raided by police. You escape, but you're now wanted.",
            outcome = {
                tags = {"police","escape"},
                severity = 6,
                statDelta = { MentalHealth = -2, RiskAffinity = 2 },
                careerDelta = {
                    xp = 10,
                    prestige = -1,
                    risk = 5,
                },
                flagsAdd = { WANTED = true, POLICE_RAID = true },
                narrative = "Cops swarm the race. You escape, but you're now on their radar. Every race is riskier now."
            }
        },
    }
})

ev({
    id = "RACE_STREET_FATAL_STREET_RACE",
    title = "Fatal Street Race",
    description = "A street race goes horribly wrong. Someone dies. The scene will never be the same.",
    minAge = 20,
    maxAge = 35,
    stages = {"STREET_RACER"},
    weight = 3,
    tags = {"death","street","tragedy"},
    requirements = {
        traitsAny = {"RACER","RECKLESS"},
        flagsAny = {"OUTLAW_PATH"},
        minRisk = 8,
    },
    choices = {
        {
            id = "SURVIVE_WITNESS",
            text = "You survive but witness the death. It haunts you.",
            outcome = {
                tags = {"survival","trauma"},
                severity = 9,
                statDelta = { MentalHealth = -6, RiskAffinity = -2 },
                addTraits = {"ANXIOUS"},
                careerDelta = {
                    xp = 0,
                    prestige = -3,
                    risk = -3,
                    deaths = 1,
                },
                flagsAdd = { WITNESSED_DEATH = true },
                narrative = "You saw it happen. The memory won't leave you. The scene is over, and you're done with street racing."
            }
        },
        {
            id = "SURVIVE_ESCAPE",
            text = "You escape before police arrive, but you're traumatized.",
            outcome = {
                tags = {"escape","trauma"},
                severity = 8,
                statDelta = { MentalHealth = -4, RiskAffinity = -1 },
                careerDelta = {
                    xp = 5,
                    prestige = -2,
                    risk = -2,
                    deaths = 1,
                },
                flagsAdd = { ESCAPED_TRAGEDY = true },
                narrative = "You get away, but you can't forget what you saw. The scene is dead, and you're done."
            }
        },
        {
            id = "FATAL_CRASH",
            text = "You're involved in the fatal crash. You don't survive.",
            outcome = {
                tags = {"crash","death"},
                severity = 10,
                statDelta = { Health = -100 },
                careerDelta = {
                    crashes = 1,
                    deaths = 1,
                },
                flagsAdd = { FATAL_CRASH = true },
                deathRisk = 0.50,
                narrative = "The crash is fatal. Your street racing career ends in tragedy. Another life lost to speed."
            }
        },
    }
})

------------------------------------------------
-- MORE MECHANIC EVENTS (20+)
------------------------------------------------

ev({
    id = "RACE_MECHANIC_PIT_STOP_MISTAKE",
    title = "Pit Stop Mistake",
    description = "You make a critical mistake during a pit stop. The driver loses the race because of you.",
    minAge = 20,
    maxAge = 40,
    stages = {"MECHANIC"},
    weight = 6,
    tags = {"mistake","pressure","mechanic"},
    requirements = {
        traitsAny = {"MECHANICAPPT","TECHYKID"},
        flagsAny = {"ENGINEERING_BACKUP"},
    },
    choices = {
        {
            id = "LEARN_FROM_MISTAKE",
            text = "You learn from the mistake and become more careful.",
            outcome = {
                tags = {"learning","improvement"},
                severity = 4,
                statDelta = { TechSkill = 2, Intelligence = 1 },
                careerDelta = {
                    xp = 10,
                    prestige = 2,
                },
                narrative = "You never make that mistake again. You become the most reliable mechanic on the team."
            }
        },
        {
            id = "LOSE_CONFIDENCE",
            text = "You lose confidence and start making more mistakes.",
            outcome = {
                tags = {"doubt","decline"},
                severity = 5,
                statDelta = { MentalHealth = -3, TechSkill = -1 },
                careerDelta = {
                    xp = 3,
                    prestige = -2,
                },
                flagsAdd = { LOST_CONFIDENCE = true },
                narrative = "The mistake haunts you. You second-guess everything. The team starts to lose faith in you."
            }
        },
        {
            id = "QUIT_MECHANIC",
            text = "You quit and try to find another path.",
            outcome = {
                tags = {"quit","pivot"},
                severity = 4,
                statDelta = { MentalHealth = -2 },
                careerDelta = {
                    xp = 0,
                    prestige = -3,
                },
                flagsAdd = { QUIT_MECHANIC = true },
                narrative = "You can't handle the pressure. You walk away from racing entirely."
            }
        },
    }
})

ev({
    id = "RACE_MECHANIC_BECOME_ENGINEER",
    title = "Become Race Engineer",
    description = "You're promoted to race engineer. You're now calling strategy and making setup decisions.",
    minAge = 25,
    maxAge = 45,
    stages = {"MECHANIC"},
    weight = 8,
    tags = {"promotion","engineering","career"},
    requirements = {
        traitsAny = {"MECHANICAPPT","TECHYKID","DATA_STRATEGIST"},
        flagsAny = {"ENGINEERING_BACKUP"},
        minPrestige = 5,
    },
    choices = {
        {
            id = "EXCEL_AS_ENGINEER",
            text = "You excel as an engineer and become highly sought after.",
            outcome = {
                tags = {"success","engineering"},
                severity = 4,
                statDelta = { TechSkill = 3, Intelligence = 3, MentalHealth = 2 },
                careerDelta = {
                    xp = 30,
                    prestige = 8,
                    fame = 3,
                    money = 15000,
                },
                flagsAdd = { RACE_ENGINEER = true },
                narrative = "You become one of the best race engineers in the sport. Teams fight to hire you."
            }
        },
        {
            id = "STRUGGLE_PRESSURE",
            text = "You struggle with the pressure of making critical decisions.",
            outcome = {
                tags = {"pressure","struggle"},
                severity = 5,
                statDelta = { MentalHealth = -2, TechSkill = 1 },
                careerDelta = {
                    xp = 15,
                    prestige = 3,
                    money = 10000,
                },
                narrative = "The pressure is intense. You make some good calls, but you also make mistakes. It's a learning curve."
            }
        },
    }
})

------------------------------------------------
-- UNIVERSAL EVENTS (All Stages)
------------------------------------------------

ev({
    id = "RACE_UNIVERSAL_TRAINING_ACCIDENT",
    title = "Training Accident",
    description = "You're training off-track and have an accident. It could end your career before it starts.",
    minAge = 14,
    maxAge = 35,
    stages = {"PREP","KARTING","JUNIOR_FORMULA","PRO_CIRCUIT","STREET_RACER"},
    weight = 3,
    tags = {"accident","injury","training"},
    requirements = {
        traitsAny = {"RACER"},
    },
    choices = {
        {
            id = "MINOR_INJURY",
            text = "You're injured but will recover in time for the season.",
            outcome = {
                tags = {"injury","recovery"},
                severity = 5,
                statDelta = { Fitness = -3, MentalHealth = -2 },
                careerDelta = {
                    xp = 3,
                    prestige = -1,
                },
                narrative = "You're hurt, but you'll be back. The recovery is frustrating, but you're determined."
            }
        },
        {
            id = "CAREER_ENDING",
            text = "The injury is career-ending. You'll never race again.",
            outcome = {
                tags = {"injury","career_ending"},
                severity = 9,
                statDelta = { Fitness = -10, MentalHealth = -8 },
                careerDelta = {
                    xp = 0,
                    prestige = -5,
                },
                flagsAdd = { CAREER_ENDING_INJURY = true },
                narrative = "The doctors say you'll never race again. Your career is over before it really started."
            }
        },
        {
            id = "FATAL_ACCIDENT",
            text = "The accident is fatal. Your racing career ends in tragedy.",
            outcome = {
                tags = {"death","tragedy"},
                severity = 10,
                statDelta = { Health = -100 },
                careerDelta = {
                    deaths = 1,
                },
                flagsAdd = { FATAL_ACCIDENT = true },
                deathRisk = 0.20,
                narrative = "The accident is fatal. Your racing career ends before it could truly begin."
            }
        },
    }
})

ev({
    id = "RACE_UNIVERSAL_SPONSOR_DROPS",
    title = "Sponsor Drops You",
    description = "Your main sponsor drops you. The money is gone, and you're struggling to find funding.",
    minAge = 16,
    maxAge = 40,
    stages = {"KARTING","JUNIOR_FORMULA","PRO_CIRCUIT"},
    weight = 5,
    tags = {"sponsor","money","struggle"},
    requirements = {
        traitsAny = {"RACER"},
        flagsAny = {"LOCAL_SPONSOR_LOCKED","MAJOR_SPONSOR"},
    },
    choices = {
        {
            id = "FIND_NEW_SPONSOR",
            text = "You hustle and find a new sponsor quickly.",
            outcome = {
                tags = {"sponsor","hustle"},
                severity = 3,
                statDelta = { Charisma = 2 },
                careerDelta = {
                    xp = 8,
                    prestige = 2,
                    money = 5000,
                },
                flagsAdd = { NEW_SPONSOR_FOUND = true },
                narrative = "You work the phones and find a new sponsor. The money isn't as much, but it keeps you racing."
            }
        },
        {
            id = "STRUGGLE_FUNDING",
            text = "You struggle to find funding and have to scale back.",
            outcome = {
                tags = {"struggle","money"},
                severity = 5,
                statDelta = { MentalHealth = -3 },
                careerDelta = {
                    xp = 3,
                    prestige = -2,
                    money = -2000,
                },
                flagsAdd = { FUNDING_STRUGGLE = true },
                narrative = "You can't find a new sponsor. You have to skip races and scale back. Your career is in jeopardy."
            }
        },
        {
            id = "SELF_FUND",
            text = "You use your own money to keep racing.",
            outcome = {
                tags = {"self_fund","sacrifice"},
                severity = 4,
                statDelta = { MentalHealth = -1 },
                careerDelta = {
                    xp = 5,
                    prestige = 1,
                    money = -10000,
                },
                narrative = "You drain your savings to keep racing. It's expensive, but you're not giving up."
            }
        },
    }
})

ev({
    id = "RACE_UNIVERSAL_MEDIA_SCANDAL",
    title = "Media Scandal",
    description = "A media scandal breaks about you. Your reputation is damaged, and sponsors are nervous.",
    minAge = 18,
    maxAge = 40,
    stages = {"JUNIOR_FORMULA","PRO_CIRCUIT","STREET_RACER"},
    weight = 4,
    tags = {"media","scandal","reputation"},
    requirements = {
        traitsAny = {"RACER"},
        minFame = 3,
    },
    choices = {
        {
            id = "HANDLE_PUBLICLY",
            text = "You handle it publicly and transparently.",
            outcome = {
                tags = {"transparency","damage_control"},
                severity = 4,
                statDelta = { Charisma = 2, MentalHealth = -2 },
                careerDelta = {
                    xp = 8,
                    prestige = 2,
                    fame = -2,
                },
                flagsAdd = { SCANDAL_HANDLED = true },
                narrative = "You address it head-on. Some people respect your honesty, but your reputation takes a hit."
            }
        },
        {
            id = "IGNORE_SCANDAL",
            text = "You ignore it and hope it goes away.",
            outcome = {
                tags = {"avoidance","damage"},
                severity = 5,
                statDelta = { MentalHealth = -3, Charisma = -2 },
                careerDelta = {
                    xp = 3,
                    prestige = -3,
                    fame = -4,
                },
                flagsAdd = { SCANDAL_IGNORED = true },
                narrative = "You try to ignore it, but it doesn't go away. Your reputation suffers, and sponsors drop you."
            }
        },
        {
            id = "FIGHT_BACK",
            text = "You fight back against false accusations.",
            outcome = {
                tags = {"defense","legal"},
                severity = 4,
                statDelta = { Charisma = 1, MentalHealth = -1 },
                careerDelta = {
                    xp = 5,
                    prestige = 1,
                    money = -5000,
                },
                flagsAdd = { SCANDAL_FOUGHT = true },
                narrative = "You hire lawyers and fight back. It's expensive, but you clear your name."
            }
        },
    }
})

------------------------------------------------
-- MORE PREP STAGE EVENTS (10-15) - CONTINUED
------------------------------------------------

ev({
    id = "RACE_PREP_SCHOOL_RACE_CLUB",
    title = "School Race Club",
    description = "Your school starts a racing club. You join immediately, but it's mostly kids who don't take it seriously.",
    minAge = 12,
    maxAge = 16,
    stages = {"NONE", "PREP"},
    weight = 6,
    tags = {"prep","school","club"},
    requirements = {
        traitsAny = {"RACER"},
    },
    choices = {
        {
            id = "LEAD_CLUB",
            text = "You take charge and turn it into something serious.",
            outcome = {
                tags = {"leadership","organization"},
                severity = 3,
                statDelta = { Charisma = 2, DrivingSkill = 1 },
                careerDelta = {
                    xp = 6,
                    prestige = 2,
                },
                flagsAdd = { CLUB_LEADER = true },
                narrative = "You organize track days, bring in guest speakers, and turn the club into something real."
            }
        },
        {
            id = "FOCUS_SELF",
            text = "You focus on your own improvement and ignore the club.",
            outcome = {
                tags = {"focus","individual"},
                severity = 2,
                statDelta = { DrivingSkill = 2 },
                careerDelta = {
                    xp = 4,
                    prestige = 1,
                },
                narrative = "You use the club for track access but don't get involved in the politics. You just want to drive."
            }
        },
        {
            id = "QUIT_CLUB",
            text = "You quit and find a real racing program outside school.",
            outcome = {
                tags = {"pivot","serious"},
                severity = 2,
                statDelta = { Intelligence = 1 },
                careerDelta = {
                    xp = 3,
                    prestige = 1,
                },
                narrative = "You realize school clubs aren't serious enough. You find a real racing program and commit fully."
            }
        },
    }
})

ev({
    id = "RACE_PREP_FIRST_TROPHY",
    title = "First Trophy",
    description = "You win your first race trophy. It's small, local, but it means everything to you.",
    minAge = 11,
    maxAge = 15,
    stages = {"NONE", "PREP"},
    weight = 7,
    tags = {"victory","trophy","achievement"},
    requirements = {
        traitsAny = {"RACER"},
        flagsAny = {"PREP_BIKE_RACER","GO_KART_NATURAL"},
    },
    choices = {
        {
            id = "INSPIRED",
            text = "The trophy inspires you to chase bigger dreams.",
            outcome = {
                tags = {"inspiration","determination"},
                severity = 3,
                statDelta = { MentalHealth = 3, DrivingSkill = 1 },
                careerDelta = {
                    xp = 5,
                    prestige = 3,
                },
                flagsAdd = { FIRST_TROPHY = true },
                narrative = "You put the trophy on your shelf. Every day, you look at it and remember what you're capable of."
            }
        },
        {
            id = "HUMBLE",
            text = "You stay humble and focus on the next race.",
            outcome = {
                tags = {"humility","focus"},
                severity = 2,
                statDelta = { DrivingSkill = 1, MentalHealth = 1 },
                careerDelta = {
                    xp = 4,
                    prestige = 2,
                },
                narrative = "You're happy, but you know this is just the beginning. You're already thinking about the next race."
            }
        },
    }
})

------------------------------------------------
-- MORE KARTING EVENTS (14-18) - CONTINUED
------------------------------------------------

ev({
    id = "RACE_KART_INJURY_COMEBACK",
    title = "Injury Comeback",
    description = "You're coming back from a serious injury. Everyone doubts you can return to form.",
    minAge = 15,
    maxAge = 18,
    stages = {"KARTING"},
    weight = 6,
    tags = {"injury","comeback","determination"},
    requirements = {
        traitsAny = {"RACER"},
        flagsAny = {"MAJOR_KART_CRASH","CRASH_TRAUMA"},
    },
    choices = {
        {
            id = "COMEBACK_STRONG",
            text = "You come back stronger than ever and win your first race back.",
            outcome = {
                tags = {"comeback","victory"},
                severity = 5,
                statDelta = { DrivingSkill = 2, MentalHealth = 3, Fitness = 1 },
                careerDelta = {
                    xp = 20,
                    prestige = 6,
                    fame = 3,
                    totalRaces = 1,
                    wins = 1,
                },
                flagsAdd = { COMEBACK_STORY = true },
                narrative = "You win your first race back. The comeback story inspires everyone. You've proven you're not done."
            }
        },
        {
            id = "STRUGGLE_COMEBACK",
            text = "You struggle to find your form and finish mid-pack.",
            outcome = {
                tags = {"struggle","recovery"},
                severity = 4,
                statDelta = { MentalHealth = -2, DrivingSkill = 1 },
                careerDelta = {
                    xp = 8,
                    prestige = 2,
                    totalRaces = 1,
                },
                narrative = "You're not the same driver you were. The injury took something from you. It's a long road back."
            }
        },
        {
            id = "RETIRE",
            text = "You realize you can't come back and retire from racing.",
            outcome = {
                tags = {"retirement","acceptance"},
                severity = 6,
                statDelta = { MentalHealth = -4 },
                careerDelta = {
                    xp = 0,
                    prestige = -3,
                },
                flagsAdd = { EARLY_RETIREMENT = true },
                narrative = "You accept that your racing career is over. The injury was too much. You have to find a new path."
            }
        },
    }
})

ev({
    id = "RACE_KART_MENTOR_OFFER",
    title = "Mentor Offers Help",
    description = "An experienced driver offers to mentor you. They see potential, but they want commitment.",
    minAge = 14,
    maxAge = 18,
    stages = {"KARTING"},
    weight = 7,
    tags = {"mentor","guidance","opportunity"},
    requirements = {
        traitsAny = {"RACER"},
        minPrestige = 3,
    },
    choices = {
        {
            id = "ACCEPT_MENTOR",
            text = "You accept the mentorship and commit fully.",
            outcome = {
                tags = {"mentor","commitment"},
                severity = 3,
                statDelta = { DrivingSkill = 2, Intelligence = 1 },
                careerDelta = {
                    xp = 12,
                    prestige = 3,
                },
                flagsAdd = { HAS_MENTOR = true },
                narrative = "You work with your mentor every week. The improvement is rapid. You're learning things you never knew."
            }
        },
        {
            id = "DECLINE_MENTOR",
            text = "You decline, preferring to learn on your own.",
            outcome = {
                tags = {"independence","self_learning"},
                severity = 2,
                statDelta = { Intelligence = 1 },
                careerDelta = {
                    xp = 4,
                    prestige = 1,
                },
                narrative = "You prefer to learn on your own. It's slower, but you feel like you're doing it your way."
            }
        },
    }
})

------------------------------------------------
-- MORE JUNIOR FORMULA EVENTS (17-23) - CONTINUED
------------------------------------------------

ev({
    id = "RACE_JUNIOR_FIRST_PODIUM",
    title = "First Podium",
    description = "You finish on the podium for the first time in junior formula. The feeling is incredible.",
    minAge = 17,
    maxAge = 23,
    stages = {"JUNIOR_FORMULA"},
    weight = 8,
    tags = {"podium","achievement","junior"},
    requirements = {
        traitsAny = {"RACER"},
        flagsAny = {"JUNIOR_SEAT_SECURED"},
    },
    choices = {
        {
            id = "INSPIRED_PODIUM",
            text = "The podium inspires you to chase wins.",
            outcome = {
                tags = {"inspiration","determination"},
                severity = 4,
                statDelta = { MentalHealth = 3, DrivingSkill = 1 },
                careerDelta = {
                    xp = 15,
                    prestige = 5,
                    fame = 2,
                    totalRaces = 1,
                    podiums = 1,
                },
                flagsAdd = { FIRST_PODIUM = true },
                narrative = "Standing on the podium feels incredible. You want this every race. You're hungry for more."
            }
        },
        {
            id = "HUMBLE_PODIUM",
            text = "You stay humble and focus on consistency.",
            outcome = {
                tags = {"humility","consistency"},
                severity = 3,
                statDelta = { DrivingSkill = 1, MentalHealth = 2 },
                careerDelta = {
                    xp = 12,
                    prestige = 4,
                    fame = 1,
                    totalRaces = 1,
                    podiums = 1,
                },
                narrative = "You're happy with the podium, but you know consistency is what matters. You focus on the next race."
            }
        },
    }
})

ev({
    id = "RACE_JUNIOR_ENGINE_FAILURE",
    title = "Engine Failure",
    description = "Your engine fails during a race you were winning. The frustration is overwhelming.",
    minAge = 17,
    maxAge = 23,
    stages = {"JUNIOR_FORMULA"},
    weight = 6,
    tags = {"mechanical","failure","frustration"},
    requirements = {
        traitsAny = {"RACER"},
        flagsAny = {"JUNIOR_SEAT_SECURED"},
    },
    choices = {
        {
            id = "ACCEPT_MECHANICAL",
            text = "You accept that mechanical failures are part of racing.",
            outcome = {
                tags = {"acceptance","maturity"},
                severity = 3,
                statDelta = { MentalHealth = -1, Intelligence = 1 },
                careerDelta = {
                    xp = 5,
                    prestige = 1,
                },
                narrative = "You're frustrated, but you know mechanical failures happen. You focus on what you can control."
            }
        },
        {
            id = "BLAME_TEAM",
            text = "You blame the team and demand better equipment.",
            outcome = {
                tags = {"blame","conflict"},
                severity = 4,
                statDelta = { MentalHealth = -2, Charisma = -1 },
                careerDelta = {
                    xp = 3,
                    prestige = -1,
                },
                flagsAdd = { TEAM_CONFLICT = true },
                narrative = "You're furious with the team. The relationship becomes strained. They're doing their best, but it's not enough."
            }
        },
        {
            id = "LEARN_ENGINEERING",
            text = "You start learning about engines to prevent future failures.",
            outcome = {
                tags = {"learning","engineering"},
                severity = 3,
                statDelta = { TechSkill = 2, Intelligence = 1 },
                addTraits = {"MECHANICAPPT"},
                careerDelta = {
                    xp = 8,
                    prestige = 2,
                },
                flagsAdd = { ENGINEERING_INTEREST = true },
                narrative = "You start studying engines. Understanding the mechanical side makes you a better driver."
            }
        },
    }
})

------------------------------------------------
-- MORE PRO CIRCUIT EVENTS (20+) - CONTINUED
------------------------------------------------

ev({
    id = "RACE_PRO_FIRST_WIN",
    title = "First Pro Win",
    description = "You win your first race in the pro series. The celebration is massive, and your career changes forever.",
    minAge = 20,
    maxAge = 35,
    stages = {"PRO_CIRCUIT"},
    weight = 9,
    tags = {"victory","win","pro"},
    requirements = {
        traitsAny = {"RACER"},
        flagsAny = {"PRO_ESTABLISHED"},
        minPrestige = 8,
    },
    choices = {
        {
            id = "CELEBRATE_WIN",
            text = "You celebrate hard and enjoy the moment.",
            outcome = {
                tags = {"victory","celebration"},
                severity = 5,
                statDelta = { MentalHealth = 4, Charisma = 2, DrivingSkill = 1 },
                careerDelta = {
                    xp = 35,
                    prestige = 10,
                    fame = 8,
                    money = 25000,
                    totalRaces = 1,
                    wins = 1,
                },
                flagsAdd = { FIRST_PRO_WIN = true },
                narrative = "You celebrate like you've never celebrated before. The win changes everything. Sponsors are calling."
            }
        },
        {
            id = "STAY_FOCUSED",
            text = "You stay focused and immediately think about the next race.",
            outcome = {
                tags = {"focus","determination"},
                severity = 4,
                statDelta = { DrivingSkill = 2, MentalHealth = 2 },
                careerDelta = {
                    xp = 30,
                    prestige = 9,
                    fame = 6,
                    money = 20000,
                    totalRaces = 1,
                    wins = 1,
                },
                flagsAdd = { FIRST_PRO_WIN = true, FOCUSED_DRIVER = true },
                narrative = "You're happy, but you're already thinking about the next race. One win isn't enough. You want more."
            }
        },
    }
})

ev({
    id = "RACE_PRO_TEAM_SWITCH",
    title = "Team Switch",
    description = "A better team offers you a seat. It's a huge opportunity, but you'll be leaving your current team.",
    minAge = 22,
    maxAge = 35,
    stages = {"PRO_CIRCUIT"},
    weight = 7,
    tags = {"team","switch","opportunity"},
    requirements = {
        traitsAny = {"RACER"},
        flagsAny = {"PRO_ESTABLISHED"},
        minPrestige = 10,
    },
    choices = {
        {
            id = "SWITCH_TEAMS",
            text = "You switch teams and take the better opportunity.",
            outcome = {
                tags = {"team","opportunity"},
                severity = 4,
                statDelta = { DrivingSkill = 1, MentalHealth = -1 },
                careerDelta = {
                    xp = 20,
                    prestige = 5,
                    fame = 3,
                    money = 15000,
                },
                flagsAdd = { TEAM_SWITCHED = true },
                narrative = "You make the switch. The new team has better resources, and you're immediately faster."
            }
        },
        {
            id = "STAY_LOYAL",
            text = "You stay loyal to your current team.",
            outcome = {
                tags = {"loyalty","commitment"},
                severity = 3,
                statDelta = { MentalHealth = 2, Charisma = 1 },
                careerDelta = {
                    xp = 10,
                    prestige = 3,
                },
                flagsAdd = { LOYAL_DRIVER = true },
                narrative = "You stay with your team. They appreciate your loyalty, and it strengthens your relationship."
            }
        },
        {
            id = "NEGOTIATE_BETTER",
            text = "You use the offer to negotiate a better deal with your current team.",
            outcome = {
                tags = {"negotiation","business"},
                severity = 4,
                statDelta = { Charisma = 2, Intelligence = 1 },
                careerDelta = {
                    xp = 15,
                    prestige = 4,
                    money = 10000,
                },
                flagsAdd = { NEGOTIATED_DEAL = true },
                narrative = "You use the offer as leverage. Your current team matches it, and you stay with better terms."
            }
        },
    }
})

------------------------------------------------
-- MORE STREET RACER EVENTS (20+) - CONTINUED
------------------------------------------------

ev({
    id = "RACE_STREET_LEGEND_STATUS",
    title = "Legend Status",
    description = "You've become a legend in the street racing scene. Everyone knows your name, and the stakes are higher.",
    minAge = 22,
    maxAge = 32,
    stages = {"STREET_RACER"},
    weight = 7,
    tags = {"legend","status","street"},
    requirements = {
        traitsAny = {"RACER","RECKLESS","THRILLSEEKER"},
        flagsAny = {"OUTLAW_PATH"},
        minFame = 5,
    },
    choices = {
        {
            id = "EMBRACE_LEGEND",
            text = "You embrace the legend status and push even harder.",
            outcome = {
                tags = {"legend","escalation"},
                severity = 6,
                statDelta = { RiskAffinity = 3, Charisma = 2 },
                careerDelta = {
                    xp = 25,
                    prestige = 6,
                    fame = 8,
                    money = 20000,
                    risk = 5,
                },
                flagsAdd = { STREET_LEGEND = true },
                deathRisk = 0.15,
                narrative = "You push the limits even further. The legend grows, but so does the danger. Every race could be your last."
            }
        },
        {
            id = "USE_FOR_CAREER",
            text = "You use your legend status to transition to legal racing.",
            outcome = {
                tags = {"transition","career"},
                severity = 4,
                statDelta = { Charisma = 2, MentalHealth = 1 },
                careerDelta = {
                    xp = 15,
                    prestige = 5,
                    fame = 4,
                    risk = -3,
                },
                flagsAdd = { TRANSITIONING_LEGAL = true },
                narrative = "You use your street racing fame to get noticed by legal teams. The transition begins."
            }
        },
        {
            id = "LAY_LOW",
            text = "You lay low and avoid the attention.",
            outcome = {
                tags = {"caution","low_profile"},
                severity = 3,
                statDelta = { RiskAffinity = -2 },
                careerDelta = {
                    xp = 8,
                    prestige = 2,
                    fame = -2,
                    risk = -4,
                },
                narrative = "You avoid the spotlight. The attention is dangerous. You race quietly and stay out of trouble."
            }
        },
    }
})

------------------------------------------------
-- MORE MECHANIC EVENTS (20+) - CONTINUED
------------------------------------------------

ev({
    id = "RACE_MECHANIC_CHAMPIONSHIP_WIN",
    title = "Championship Win as Mechanic",
    description = "Your driver wins the championship, and you're a crucial part of the team. The celebration is incredible.",
    minAge = 25,
    maxAge = 45,
    stages = {"MECHANIC"},
    weight = 8,
    tags = {"championship","victory","mechanic"},
    requirements = {
        traitsAny = {"MECHANICAPPT","TECHYKID","DATA_STRATEGIST"},
        flagsAny = {"RACE_ENGINEER"},
        minPrestige = 8,
    },
    choices = {
        {
            id = "CELEBRATE_VICTORY",
            text = "You celebrate the championship victory with the team.",
            outcome = {
                tags = {"victory","celebration"},
                severity = 5,
                statDelta = { MentalHealth = 4, TechSkill = 1 },
                careerDelta = {
                    xp = 40,
                    prestige = 12,
                    fame = 5,
                    money = 20000,
                },
                flagsAdd = { CHAMPIONSHIP_MECHANIC = true },
                narrative = "You celebrate with the team. The championship is yours as much as the driver's. You've made it."
            }
        },
        {
            id = "FEEL_EMPTY",
            text = "You feel empty. You wanted to be the one driving.",
            outcome = {
                tags = {"regret","emptiness"},
                severity = 6,
                statDelta = { MentalHealth = -3 },
                careerDelta = {
                    xp = 20,
                    prestige = 8,
                    money = 15000,
                },
                flagsAdd = { LINGERING_DRIVER_REGRET = true },
                narrative = "The victory feels hollow. You're happy for the team, but you can't shake the feeling that you should be driving."
            }
        },
    }
})

------------------------------------------------
-- MORE UNIVERSAL EVENTS - CONTINUED
------------------------------------------------

ev({
    id = "RACE_UNIVERSAL_FAMILY_PRESSURE",
    title = "Family Pressure",
    description = "Your family is pressuring you to quit racing and get a 'real job.' They're worried about your future.",
    minAge = 18,
    maxAge = 30,
    stages = {"KARTING","JUNIOR_FORMULA","PRO_CIRCUIT","STREET_RACER"},
    weight = 5,
    tags = {"family","pressure","conflict"},
    requirements = {
        traitsAny = {"RACER"},
    },
    choices = {
        {
            id = "STAND_FIRM",
            text = "You stand firm and continue racing.",
            outcome = {
                tags = {"determination","conflict"},
                severity = 4,
                statDelta = { MentalHealth = -2, DrivingSkill = 1 },
                careerDelta = {
                    xp = 5,
                    prestige = 1,
                },
                flagsAdd = { FAMILY_CONFLICT = true },
                narrative = "You refuse to quit. The family relationship becomes strained, but you're committed to racing."
            }
        },
        {
            id = "COMPROMISE",
            text = "You compromise and get a part-time job while racing.",
            outcome = {
                tags = {"compromise","balance"},
                severity = 3,
                statDelta = { MentalHealth = -1 },
                careerDelta = {
                    xp = 3,
                    prestige = 0,
                    money = 5000,
                },
                narrative = "You get a part-time job to appease your family. It's exhausting, but you keep racing."
            }
        },
        {
            id = "QUIT_RACING",
            text = "You quit racing and get a normal job.",
            outcome = {
                tags = {"quit","surrender"},
                severity = 6,
                statDelta = { MentalHealth = -5 },
                careerDelta = {
                    xp = 0,
                    prestige = -5,
                },
                flagsAdd = { QUIT_RACING = true },
                narrative = "You give up on your dream. The family is happy, but you feel like you've betrayed yourself."
            }
        },
    }
})

ev({
    id = "RACE_UNIVERSAL_FINANCIAL_CRISIS",
    title = "Financial Crisis",
    description = "You hit a financial crisis. Racing is expensive, and you're running out of money.",
    minAge = 16,
    maxAge = 40,
    stages = {"KARTING","JUNIOR_FORMULA","PRO_CIRCUIT","STREET_RACER"},
    weight = 6,
    tags = {"money","crisis","struggle"},
    requirements = {
        traitsAny = {"RACER"},
    },
    choices = {
        {
            id = "HUSTLE_FUNDING",
            text = "You hustle and find creative ways to fund your racing.",
            outcome = {
                tags = {"hustle","determination"},
                severity = 4,
                statDelta = { Charisma = 2, Intelligence = 1 },
                careerDelta = {
                    xp = 8,
                    prestige = 2,
                    money = 5000,
                },
                flagsAdd = { HUSTLER = true },
                narrative = "You find sponsors, sell merchandise, and do whatever it takes. You keep racing."
            }
        },
        {
            id = "SCALE_BACK",
            text = "You scale back and race less frequently.",
            outcome = {
                tags = {"scale_back","realism"},
                severity = 3,
                statDelta = { MentalHealth = -2 },
                careerDelta = {
                    xp = 3,
                    prestige = -1,
                },
                flagsAdd = { SCALED_BACK = true },
                narrative = "You race less frequently. It's frustrating, but it's the only way to keep going."
            }
        },
        {
            id = "TAKE_LOAN",
            text = "You take out a loan to keep racing.",
            outcome = {
                tags = {"loan","risk"},
                severity = 5,
                statDelta = { MentalHealth = -1, RiskAffinity = 1 },
                careerDelta = {
                    xp = 5,
                    prestige = 1,
                    money = 20000,
                },
                flagsAdd = { RACING_LOAN = true },
                narrative = "You take out a loan. It's risky, but you're betting on yourself. The pressure is intense."
            }
        },
    }
})

----------------------------------------------------------------
-- PUBLIC: GET EVENTS / FILTERING
----------------------------------------------------------------

-- traitsList: {"RACER","TECHYKID",...}
-- careerState: CareerState
function RacingCareer.GetEligibleEvents(
    age: number,
    traitsList: {string},
    careerState: CareerState
): {CareerEvent}
    local traitSet = listToSet(traitsList)
    local flags = careerState.flags or {}
    local flagSet: {[string]: boolean} = {}
    for k,v in pairs(flags) do
        if v then
            flagSet[k] = true
        end
    end

    local out: {CareerEvent} = {}

    for _,ev in ipairs(Events) do
        -- Age check
        if age >= ev.minAge and age <= ev.maxAge and stageAllowed(careerState.stage, ev.stages) then
            local req = ev.requirements or {}
            local ok = true

            -- Trait requirements
            if not hasAny(traitSet, req.traitsAny) then ok = false end
            if not hasAll(traitSet, req.traitsAll) then ok = false end
            if not hasNone(traitSet, req.traitsNot) then ok = false end

            -- Flag requirements
            if not hasAny(flagSet, req.flagsAny) then ok = false end
            if not hasAll(flagSet, req.flagsAll) then ok = false end
            if not hasNone(flagSet, req.flagsNot) then ok = false end

            -- Stat requirements
            local p = careerState.prestige or 0
            local f = careerState.fame or 0
            local r = careerState.risk or 0

            if req.minPrestige and p < req.minPrestige then ok = false end
            if req.maxPrestige and p > req.maxPrestige then ok = false end
            if req.minFame and f < req.minFame then ok = false end
            if req.maxFame and f > req.maxFame then ok = false end
            if req.minRisk and r < req.minRisk then ok = false end
            if req.maxRisk and r > req.maxRisk then ok = false end

            -- Vehicle requirements
            if req.requiresVehicle and not careerState.ownedVehicles or #(careerState.ownedVehicles or {}) == 0 then
                ok = false
            end
            if req.requiresOwnedVehicle then
                local hasVehicle = false
                for _, v in ipairs(careerState.ownedVehicles or {}) do
                    if v.type == req.requiresOwnedVehicle then
                        hasVehicle = true
                        break
                    end
                end
                if not hasVehicle then ok = false end
            end

            if ok then
                table.insert(out, ev)
            end
        end
    end

    return out
end

-- Simple weighted choice helper
function RacingCareer.ChooseEvent(events: {CareerEvent}?): CareerEvent?
    if not events or #events == 0 then
        return nil
    end
    local total = 0
    for _,ev in ipairs(events) do
        total += (ev.weight or 1)
    end
    if total <= 0 then
        return events[math.random(1, #events)]
    end
    local pick = math.random() * total
    local acc = 0
    for _,ev in ipairs(events) do
        acc += (ev.weight or 1)
        if pick <= acc then
            return ev
        end
    end
    return events[#events]
end

-- ApplyOutcome:
--  - Mutates careerState according to outcome.careerDelta and flags
--  - Returns statDelta/addTraits/removeTraits so you can pass them to TraitSystem
--  - Handles vehicle additions/removals
--  - Checks for death risk
function RacingCareer.ApplyOutcome(
    careerState: CareerState,
    outcome: Outcome
): {
    statDelta: {[string]: number},
    addTraits: {string},
    removeTraits: {string},
    narrative: string,
    tags: {string},
    severity: number,
    died: boolean?,
}
    careerState.flags = careerState.flags or {}
    careerState.ownedVehicles = careerState.ownedVehicles or {}

    local cd = outcome.careerDelta or {}
    careerState.xp += cd.xp or 0
    careerState.prestige += cd.prestige or 0
    careerState.fame += cd.fame or 0
    careerState.risk += cd.risk or 0
    careerState.crashes += cd.crashes or 0
    careerState.totalRaces = (careerState.totalRaces or 0) + (cd.totalRaces or 0)
    careerState.wins = (careerState.wins or 0) + (cd.wins or 0)
    careerState.podiums = (careerState.podiums or 0) + (cd.podiums or 0)
    careerState.money = (careerState.money or 0) + (cd.money or 0)

    if cd.stageOverride then
        careerState.stage = cd.stageOverride
    end

    if outcome.flagsAdd then
        for k,v in pairs(outcome.flagsAdd) do
            if v then
                careerState.flags[k] = true
            end
        end
    end

    for _,key in ipairs(outcome.flagsRemove or {}) do
        careerState.flags[key] = nil
    end

    -- Handle vehicle additions
    if outcome.addVehicle then
        local vehicle = outcome.addVehicle
        vehicle.purchaseYear = vehicle.purchaseYear or 2025 -- Should be set from player's current year
        table.insert(careerState.ownedVehicles, vehicle)
    end

    -- Handle vehicle removals
    if outcome.removeVehicle then
        for i = #careerState.ownedVehicles, 1, -1 do
            if careerState.ownedVehicles[i].id == outcome.removeVehicle then
                table.remove(careerState.ownedVehicles, i)
                break
            end
        end
    end

    -- Check death risk
    local died = false
    if outcome.deathRisk and outcome.deathRisk > 0 then
        local roll = math.random()
        if roll < outcome.deathRisk then
            died = true
            careerState.deaths = (careerState.deaths or 0) + 1
        end
    end

    local statDelta = outcome.statDelta or {}
    local addTraits = outcome.addTraits or {}
    local removeTraits = outcome.removeTraits or {}

    local narrative = outcome.narrative or ""
    local tags = outcome.tags or {}
    local severity = outcome.severity or 0

    return {
        statDelta = statDelta,
        addTraits = addTraits,
        removeTraits = removeTraits,
        narrative = narrative,
        tags = tags,
        severity = severity,
        died = died,
    }
end

-- Expose raw events if you want to build editors / debug tools
RacingCareer.Events = Events

return RacingCareer
