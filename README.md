# BloxLife - BitLife Clone for Roblox

A comprehensive BitLife-style life simulation game with deep story paths, minigames, and premium UI.

## 🎮 Features

### Core Gameplay
- **Life Simulation**: Age up year by year, making choices that shape your life
- **Stats System**: Happiness, Health, Smarts, and Looks
- **Money & Economy**: Earn, spend, gamble, and invest
- **Relationships**: Family, friends, and enemies
- **Occupations**: Jobs and education paths
- **Activities**: Mind & body, social, entertainment, and crime
- **Assets**: Property, vehicles, and shop items

### 🌟 Deep Story Paths (NEW!)

#### Presidential Career Path 🏛️
Rise from ordinary citizen to the most powerful position in the country!

**Progression:**
1. **Citizen** → Join student council, develop political interest
2. **Political Intern** → Work on campaigns, learn the ropes
3. **City Council** → Win your first local election
4. **State Senator** → Pass legislation, build your reputation
5. **Congressman** → Go to Washington DC
6. **U.S. Senator** → National stage politics
7. **President** → Lead the nation!

**Special Events:**
- Congressional internships
- Campaign volunteering
- Corruption opportunities (stay clean or take bribes!)
- Landmark legislation
- Presidential debates (with minigame!)
- National crises
- Inauguration ceremony

**Special Actions (as President):**
- Sign executive orders
- Address the nation
- Handle crises

#### Criminal Empire Path 🔫
Build your criminal organization from petty thief to crime boss!

**Progression:**
1. **Law-Abiding** → Resist temptation or...
2. **Petty Criminal** → Shoplifting, small crimes
3. **Car Thief** → Joyriding, chop shops
4. **Gang Member** → Join an organization
5. **Made Member** → Prove yourself in turf wars
6. **Underboss** → Second in command
7. **Crime Boss** → Run the whole operation!

**Special Events:**
- Gang recruitment
- Turf wars
- Drug deals (with heist minigame!)
- Prison time
- RICO investigations
- The coup (take over the organization)
- Going legitimate

**Special Actions (as Crime Boss):**
- Collect debts
- Launder money
- Order hits
- Hold meetings

### 🎮 Minigames (NEW!)

#### Presidential Debate 🎤
Answer political questions correctly to win debates!
- Multiple choice questions on policy
- Time pressure
- Score against opponent
- Win to boost campaign success

#### Safe Cracking 🔓
Crack the 4-digit code to complete heists!
- Wordle-style guessing game
- Green = correct digit and position
- Yellow = correct digit, wrong position
- 6 attempts to crack the safe

#### Getaway 🚗
Escape from the cops!
- Memory sequence game
- Tap buttons in the correct order
- Cops are chasing - move fast!
- Complete sequences to fill escape bar

#### Quick Time Events ⚡
Precision timing challenges!
- Tap when indicator is in the green zone
- Variable difficulty
- Used for various skill checks

## 📁 Project Structure

```
/ReplicatedStorage/
├── EventLibrary.lua      # All life events with story paths
├── EventRunner.lua       # Event selection, history, flags
├── LifeState.lua         # Player state management
├── Minigames.lua         # All minigame implementations
└── Screens/
    ├── OccupationScreen.lua
    ├── AssetsScreen.lua
    ├── RelationshipsScreen.lua
    ├── ActivitiesScreen.lua
    └── StoryPathsScreen.lua  # Story path progress UI

/ServerScriptService/
├── LifeManager.server.lua       # Core game loop, events
└── LifeRemoteHandlers.server.lua # Extended actions handler

/StarterPlayerScripts/
└── LifeClient.client.lua        # Main UI, minigames integration
```

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
- **Stats Row**: Horizontal layout above nav bar
- **Event Modals**: Animated slide-in with shadows

### Navigation
- Work (💼) - Jobs & Education
- Assets (🏠) - Property, Vehicles, Casino
- People (❤️) - Relationships
- Activities (🎭) - Mind/Body, Social, Fun, Crime
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
            result = "Result text",
            setFlag = "some_flag",
            minigame = "debate",  -- Triggers minigame
        }
    }
}
```

### Flags System
Flags track story progression and unlock events:
- `political_interest` → Unlocks political events
- `gang_member` → Unlocks gang events
- `president` → Unlocks presidential actions
- `crime_boss` → Unlocks crime boss actions

## 🎯 Future Enhancements

- [ ] Save/Load game progress
- [ ] More minigames (stock trading, sports)
- [ ] Celebrity path
- [ ] Military path
- [ ] More relationship dynamics
- [ ] Achievements system
- [ ] Leaderboards

## 📄 License

MIT License - Feel free to use and modify!
