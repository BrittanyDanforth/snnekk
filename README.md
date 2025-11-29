# BloxLife - BitLife Clone for Roblox

A comprehensive BitLife-style life simulation game with **3,300+ lines** of narrative content, deep story paths, minigames, and premium UI.

## 🎮 Features

### Core Gameplay
- **Life Simulation**: Age up year by year, making choices that shape your life
- **Stats System**: Happiness, Health, Smarts, and Looks (with rich narrative feedback)
- **Money & Economy**: Earn, spend, gamble, and invest
- **Relationships**: Family, friends, enemies, romance
- **Occupations**: Jobs and education paths
- **Activities**: Mind & body, social, entertainment, and crime
- **Assets**: Property, vehicles, and shop items

## 📚 MASSIVE Content System (NEW!)

### NarrativeContent.lua (1,200+ lines)
Rich BitLife-style text variations for immersive storytelling:

#### Stat Narratives (640+ variations)
- **Happiness**: 80 variations (up/down × small/medium/big/huge × 20 each)
- **Health**: 80 variations
- **Smarts**: 80 variations  
- **Looks**: 80 variations

#### Money Narratives (60+ variations)
- **Gains**: small/medium/large with 20+ templates each
- **Losses**: small/medium/large with 20+ templates each

#### Flag Descriptions (100+ life flags)
- Political path (interest → intern → official → senator → president)
- Criminal path (tendencies → thief → gang member → underboss → boss)
- Education (GED, degrees, PhD, trade certification)
- Career (employed, CEO, retired, famous)
- Relationships (dating, engaged, married, divorced)
- Health & Lifestyle (athlete, addict, recovering, disabled)
- Military (enlisted, veteran, combat, PTSD)

#### Year Recap Templates (BitLife-style summaries)
- Baby recaps (ages 0-1)
- Toddler recaps (ages 2-4)
- Early childhood (ages 5-9)
- Childhood (ages 10-12)
- Tween (ages 13-15)
- Teenage (ages 16-19)
- Young adult (ages 20-35)
- Adult (ages 36-60)
- Senior (ages 61+)
- **Special path recaps**: Criminal, Political, Romantic, Wealthy, Struggling

### EventLibrary.lua (1,300+ lines, 100+ Events)

#### Life Stage Events
| Stage | Age Range | Event Count |
|-------|-----------|-------------|
| Baby | 0-2 | 6 events |
| Early Childhood | 3-5 | 7 events |
| Childhood | 6-12 | 15 events |
| Teen | 13-19 | 18 events |
| Young Adult | 19-29 | 15 events |
| Adult | 30-60 | 12 events |
| Senior | 60+ | 5 events |
| Random | Any age | 15+ events |

#### Story Arc Events
| Path | Events | Final Goal |
|------|--------|------------|
| **Political** | 8 milestone events | President of the USA |
| **Criminal** | 10 milestone events | Crime Boss / Kingpin |
| **Celebrity** | 5 events | A-List Celebrity |
| **Business** | 5 events | Billionaire CEO |

## 🌟 Deep Story Paths

### Presidential Career Path 🏛️
Rise from ordinary citizen to the most powerful position in the country!

**Progression:**
1. **Citizen** → Develop political interest
2. **Political Volunteer** → Work on campaigns
3. **City Council** → Win your first local election
4. **Mayor** → Lead your city
5. **State Senator** → Pass state legislation
6. **Congressman** → Go to Washington DC
7. **U.S. Senator** → National stage politics
8. **President** → Lead the nation!

**Special Actions (as President):**
- Sign executive orders
- Address the nation
- Veto bills
- Grant pardons

### Criminal Empire Path 🔫
Build your criminal organization from petty thief to crime boss!

**Progression:**
1. **Law-Abiding** → Resist temptation or...
2. **Petty Criminal** → Shoplifting, small crimes
3. **Car Thief** → Joyriding, chop shops
4. **Gang Prospect** → Prove yourself
5. **Gang Member** → Join an organization
6. **Gang Captain** → Lead operations
7. **Underboss** → Second in command
8. **Crime Boss** → Run the whole operation!

**Special Actions (as Crime Boss):**
- Collect debts
- Launder money
- Order hits
- Bribe officials
- Hold meetings

### Celebrity Path ⭐
- Become an influencer
- Pursue acting, music, or writing
- Land brand deals
- Achieve A-list status

### Business Path 💼
- Start your own company
- Become CEO
- Make millions/billions
- Go public with IPO

## 🎮 Minigames

### Presidential Debate 🎤
Answer political questions correctly to win debates!

### Safe Cracking 🔓
Crack the 4-digit code to complete heists!

### Getaway 🚗
Memory sequence game - escape from the cops!

### Quick Time Events ⚡
Precision timing challenges for skill checks!

## 📁 Project Structure

```
/ReplicatedStorage/
├── NarrativeContent.lua   # 1,200+ lines of text variations (NEW!)
├── EventLibrary.lua       # 1,300+ lines, 100+ events (EXPANDED!)
├── EventRunner.lua        # 800+ lines, event engine + narrative builder
├── LifeState.lua          # Player state management
├── Minigames.lua          # All minigame implementations
└── Screens/
    ├── OccupationScreen.lua
    ├── AssetsScreen.lua
    ├── RelationshipsScreen.lua
    ├── ActivitiesScreen.lua
    └── StoryPathsScreen.lua

/ServerScriptService/
├── LifeManager.server.lua       # Core game loop, events
└── LifeRemoteHandlers.server.lua # Extended actions handler

/StarterPlayerScripts/
└── LifeClient.client.lua        # Main UI, minigames integration
```

**Total Content: 3,379 lines of Lua across the event system!**

## 🔌 Remote Events & Functions

### LifeRemotes Folder

#### Remote Events
| Name | Direction | Description |
|------|-----------|-------------|
| `RequestAgeUp` | Client → Server | Request to age up one year |
| `PresentEvent` | Server → Client | Send event data for display |
| `SubmitChoice` | Client → Server | Submit event choice (eventId, choiceIndex) |
| `SyncState` | Server → Client | Sync player state |
| `SetLifeInfo` | Client → Server | Set name and gender |
| `MinigameResult` | Client → Server | Send minigame outcome |

#### Remote Functions
| Name | Description |
|------|-------------|
| `GetStoryPaths` | Get player's story path progress |
| `GetSpecialActions` | Get available special actions |
| `DoSpecialAction` | Execute a special action |
| `ApplyForJob` | Apply for a job |
| `EnrollEducation` | Enroll in education |
| `BuyAsset` | Purchase an asset |
| `DoActivity` | Perform an activity |
| `DoCrime` | Commit a crime |
| `RelationshipAction` | Interact with relationship |

## 🎨 UI Features

### Premium BitLife-Style Design
- **Header**: Positioned to avoid Roblox logo overlap
- **Avatar**: Dynamic emoji based on age
- **Money Display**: Formatted with icons
- **Stats Row**: Split LEFT/RIGHT layout avoiding Age button
- **Nav Bar**: Split LEFT/RIGHT layout with centered Age button
- **Event Modals**: Animated slide-in with rich narrative text

### Navigation (Split Layout)
**LEFT side:**
- Work (💼) - Jobs & Education
- Assets (🏠) - Property, Vehicles, Casino

**CENTER:**
- Age Button (+) - Big circular button

**RIGHT side:**
- People (❤️) - Relationships
- Fun (🎭) - Activities
- Story (⭐) - Life path progress

## 🚀 Getting Started

1. Place all files in their respective locations in Roblox Studio
2. The `LifeRemotes` folder will be auto-created on first run
3. Play and enjoy your BitLife experience!

## 📝 Event System

### Event Properties
```lua
{
    id = "unique_id",
    minAge = 18,           -- Minimum age to fire
    maxAge = 65,           -- Maximum age to fire
    weight = 10,           -- Selection weight
    oneTime = false,       -- Only fire once ever
    cooldown = 5,          -- Years between firings
    milestone = true,      -- Guaranteed to fire if eligible
    category = "school",   -- For category flavor text
    
    emoji = "🎉",
    title = "Event Title",
    text = "Event description with %dynamicData% placeholders",
    
    getDynamicData = function(state)
        return { name = "Random Name" }
    end,
    
    requires = function(state)
        return state.Flags.some_flag == true
    end,
    
    choices = {
        {
            text = "Choice text",
            effects = { Happiness = 10, Money = -100 },
            result = "Result text (feeds into narrative builder)",
            setFlag = "some_flag",
            setFlags = {"flag1", "flag2"},  -- Set multiple flags
            clearFlag = "old_flag",
            minigame = "debate",  -- Triggers minigame
            getDynamicMoney = function(data) return data.amount end,
        }
    }
}
```

### Narrative Builder
The `EventRunner.buildNarrativeText()` function creates rich BitLife-style output:

1. **Explicit result text** from the choice
2. **Money narrative** (dynamic text based on gain/loss magnitude)
3. **Stat narratives** (happiness, health, smarts, looks changes)
4. **Flag descriptions** (story path milestones)
5. **Category flavor** (school, family, work, crime, etc.)

Example output:
```
You got the job at TechCorp!
You scored a solid payout of $2K. Your money climbed to $5K.
Your happiness noticeably improved (+10%, now 65%).
You started paying real attention to politics.
Your career story took another step here.
```

### Flags System
100+ flags track story progression:
- `political_interest` → Unlocks political events
- `gang_member` → Unlocks gang events
- `president` → Unlocks presidential actions
- `crime_boss` → Unlocks crime boss actions
- `married` → Unlocks family events
- And 95+ more!

## 🎯 Future Enhancements

- [ ] Save/Load game progress
- [ ] More minigames (stock trading, sports)
- [ ] More celebrity path events
- [ ] Military career path
- [ ] More relationship dynamics
- [ ] Achievements system
- [ ] Leaderboards

## 📄 License

MIT License - Feel free to use and modify!
