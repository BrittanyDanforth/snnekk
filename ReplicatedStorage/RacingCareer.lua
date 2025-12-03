--!strict
-- RacingCareer.lua
-- Single AAA career track: Motorsport / Racing
-- This is PURELY career-focused; no generic childhood events.
-- Designed to work with your TraitSystem-style backend.
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
-- }
--
-- You decide how to save that. This module just reads/writes these fields.

local RacingCareer = {}

export type CareerStageId =
    "NONE" |
    "PREP" |
    "KARTING" |
    "JUNIOR" |
    "PRO" |
    "STREET" |
    "MECHANIC"

export type CareerState = {
    stage: CareerStageId,
    xp: number,
    prestige: number,
    fame: number,
    risk: number,
    outlawPath: boolean,
    crashes: number,
    flags: {[string]: boolean},
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
    }?,
    flagsAdd: {[string]: boolean}?,
    flagsRemove: {string}?,
    narrative: string?,
}

export type Choice = {
    id: string,
    text: string,
    outcome: Outcome,
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
RacingCareer.Version = "v1.0"

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
----------------------------------------------------------------
-- NOTE:
--  - These are ONLY racing-career focused.
--  - They assume traits like:
--      "RACER", "RECKLESS", "GOODDRIVER", "THRILLSEEKER", "MECHANICAPPT",
--      "FATKID", "BULLYVICTIM", "ANXIOUS"
--    exist in your TraitSystem.
--  - statDelta keys assume you have stats: DrivingSkill, Fitness, MentalHealth,
--    RiskAffinity, Charisma, Luck, TechSkill, etc.

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
            outcome = {
                tags = {"kart","risk","money"},
                severity = 4,
                statDelta = { DrivingSkill = 2, Fitness = 1, RiskAffinity = 1 },
                addTraits = {"THRILLSEEKER"},
                careerDelta = {
                    xp = 15,
                    prestige = 3,
                    stageOverride = "KARTING",
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
                narrative = "You scroll past people’s videos from the track that night. It feels like your future is happening without you."
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
            text = "Drive aggressively, sending moves even when they’re 50/50.",
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
                },
                flagsAdd = { PADDOCK_REPUTATION_RESPECTED = true },
                narrative = "You rarely make stupid moves. You might not win every race, but the paddock knows you’re the real deal."
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
                    money = 1,
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
                    money = 2,
                },
                flagsAdd = { LOCAL_SPONSOR_LOCKED = true, DRIVER_BUSINESS_BRAIN = true },
                narrative = "You don’t just race; you talk like a future pro. They cave and sweeten the deal."
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
                narrative = "You tell yourself you’re not gonna be a walking billboard. But you also burn a rare shot at resources."
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
                    stageOverride = "JUNIOR",
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
                    stageOverride = "JUNIOR",
                },
                flagsAdd = { JUNIOR_SEAT_WEAK = true },
                narrative = "You’re clearly talented but off your peak. They take you, but as a 'maybe' instead of 'our star.'"
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
                narrative = "You push the invite away and tell people it 'wasn’t a big deal.' You know that’s a lie."
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
    description = "Your teammate’s family brings more money. The team starts favoring them with newer parts.",
    minAge = 17,
    maxAge = 23,
    stages = {"JUNIOR"},
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
                },
                flagsAdd = { UNDERDOG_STORY = true },
                narrative = "You drag the old car into places it shouldn’t be. People talk: 'If that kid had equal machinery…'"
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
                    money = 2,
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
                narrative = "You vent in the paddock and online. Some fans love the honesty; the team doesn’t."
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
    stages = {"JUNIOR"},
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
                narrative = "You feel sick, but you also feel more determined. If it’s this serious, you want to conquer it."
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
    description = "A senior engineer notices your feedback and says you'd make a great race engineer or mechanic if driving doesn’t work out.",
    minAge = 18,
    maxAge = 24,
    stages = {"JUNIOR"},
    weight = 6,
    tags = {"engineering","fallback"},
    requirements = {
        traitsAny = {"MECHANICAPPT","TECHYKID"},
    },
    choices = {
        {
            id = "DOUBLE_DOWN_DRIVING",
            text = "Thank them, but insist you’ll make it as a driver.",
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

------------------------------------------------
-- TRANSITION: JUNIOR → PRO OR STREET
------------------------------------------------

ev({
    id = "RACE_TRANSITION_PRO_OR_STREET",
    title = "Fork in the Road: Pro Seat vs Street Racing",
    description = "A lower-end pro series offers you a risky underfunded seat. At the same time, a crew invites you into serious illegal street racing with quick cash.",
    minAge = 19,
    maxAge = 27,
    stages = {"JUNIOR"},
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
                    stageOverride = "PRO",
                },
                flagsAdd = { UNDERFUNDED_PRO = true },
                narrative = "You sign with a team that runs on duct tape and miracles. It’s a brutal ladder, but it’s *real*."
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
                    money = 5,
                    risk = 6,
                    stageOverride = "STREET",
                },
                flagsAdd = { OUTLAW_PATH = true },
                narrative = "Neon, sirens, and sketchy payouts. It’s not FIA-approved, but it scratches the itch and pays in cash."
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
                narrative = "You pause chasing the top. Whether it’s wisdom or fear depends on what you do next."
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
    stages = {"PRO"},
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
                    money = 6,
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
                    money = 5,
                },
                narrative = "You don’t dominate like a maniac, but you also don’t shatter yourself. Your career has legs."
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
                    money = 3,
                },
                flagsAdd = { TEAM_CONSIDERING_DROP = true },
                narrative = "You go through the motions. Eventually, everyone can see it—even you."
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
    stages = {"STREET"},
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
                    money = 6,
                    risk = 10,
                    crashes = 1,
                },
                flagsAdd = { LAW_ON_YOU = true },
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
                    money = 3,
                    risk = -4,
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
                    money = 5,
                },
                narrative = "You realize you’re just as vital on the spanners as behind the wheel. Wins still feel like yours."
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
                    money = 4,
                },
                flagsAdd = { LINGERING_DRIVER_REGRET = true },
                narrative = "Every time the car leaves the box, you imagine it’s you. It eats at you between sessions."
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
        if age >= ev.minAge and age <= ev.maxAge and stageAllowed(careerState.stage, ev.stages) then
            local req = ev.requirements or {}
            local ok = true

            if not hasAny(traitSet, req.traitsAny) then ok = false end
            if not hasAll(traitSet, req.traitsAll) then ok = false end
            if not hasNone(traitSet, req.traitsNot) then ok = false end

            if not hasAny(flagSet, req.flagsAny) then ok = false end
            if not hasAll(flagSet, req.flagsAll) then ok = false end
            if not hasNone(flagSet, req.flagsNot) then ok = false end

            local p = careerState.prestige or 0
            local f = careerState.fame or 0

            if req.minPrestige and p < req.minPrestige then ok = false end
            if req.maxPrestige and p > req.maxPrestige then ok = false end
            if req.minFame and f < req.minFame then ok = false end
            if req.maxFame and f > req.maxFame then ok = false end

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
function RacingCareer.ApplyOutcome(
    careerState: CareerState,
    outcome: Outcome
): {
    statDelta: {[string]: number},
    addTraits: {string},
    removeTraits: {string},
    narrative: string,
    tags: {string},
    severity: number
}
    careerState.flags = careerState.flags or {}

    local cd = outcome.careerDelta or {}
    careerState.xp += cd.xp or 0
    careerState.prestige += cd.prestige or 0
    careerState.fame += cd.fame or 0
    careerState.risk += cd.risk or 0
    careerState.crashes += cd.crashes or 0

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
    }
end

-- Expose raw events if you want to build editors / debug tools
RacingCareer.Events = Events

return RacingCareer
