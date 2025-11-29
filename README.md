# BloxLife - BitLife Clone for Roblox

A comprehensive BitLife-style life simulation game built for Roblox with polished AAA-quality UI, deep story paths, interactive minigames, and complete server-side validation.

## 🎮 Features

### Core Systems

- **Complete Life Simulation** - Birth to death with age-based events
- **Life Stage System** - 10 distinct life stages (Infant → Elder) with stage-specific events
- **6 Deep Career Paths** - President, Criminal, Teacher, Racer, Artist, Hacker
- **Dynamic Events** - 200+ unique events with branching choices
- **BitLife-Style UI** - Premium cards, modals, and animations
- **Server-Side Validation** - All actions validated on server via LifeStageSystem
- **Minigames** - Debate, Heist, Getaway, QTE, Prison Escape, Mash
- **Death System** - Age and health-based death probability

## 🧬 Life Stage System

The game uses a comprehensive `LifeStageSystem` that controls what's available at each age:

| Stage | Age | School | Work | Date | Crime | Drink |
|-------|-----|--------|------|------|-------|-------|
| 👶 Infant | 0-2 | ❌ | ❌ | ❌ | ❌ | ❌ |
| 💒 Toddler | 3-4 | Daycare | ❌ | ❌ | ❌ | ❌ |
| 🧒 Child | 5-11 | Elementary | ❌ | ❌ | ❌ | ❌ |
| 🧑 Tween | 12-13 | Middle | ❌ | ❌ | Minor | ❌ |
| 🧑‍🎤 Teen | 14-17 | High | Part-time | ✅ | ✅ | ❌ |
| 🧑‍💼 Young Adult | 18-25 | College | ✅ | ✅ | ✅ | 21+ |
| 🧑‍💻 Adult | 26-45 | ❌ | ✅ | ✅ | ✅ | ✅ |
| 🧔 Middle Age | 46-60 | ❌ | ✅ | ✅ | ✅ | ✅ |
| 🧓 Senior | 61-75 | ❌ | Optional | ✅ | ✅ | ✅ |
| 👴 Elder | 76+ | ❌ | ❌ | ✅ | ❌ | ✅ |

### Stage Transitions
When you transition between life stages, you get a special milestone event:
- "Off to School!" (Age 5)
- "High School!" (Age 14)
- "You're an Adult!" (Age 18)
- "Retirement!" (Age 61)

### Event Validation
Every event is validated server-side before being shown:
- Age range check
- Category availability for current stage
- One-time/cooldown checks
- Custom requirements (flags, stats, etc.)
- Prison status checks
- Career path requirements

### Career Paths

| Path | Description | Key Milestones |
|------|-------------|----------------|
| 🏛️ Political | Rise from intern to President | City Council → State Senator → Congress → President |
| 💀 Criminal | Build a crime empire | Petty Thief → Gang Member → Underboss → Kingpin |
| 📚 Teacher | Shape young minds | Teacher → Department Head → Principal → Superintendent |
| 🏎️ Racer | Become a racing legend | Karting → Junior Formula → F1 → World Champion |
| 🎨 Artist | Create masterpieces | Art School → Gallery Shows → Museum Pieces → Celebrity |
| 💻 Hacker | Master the digital realm | Script Kiddie → Black Hat → Hacker Group → Elite |

## 📁 Project Structure

```
BloxLife/
├── ReplicatedStorage/
│   ├── LifeState.lua          # Player state management (extended)
│   ├── EventLibrary.lua       # 300+ event definitions
│   ├── EventRunner.lua        # Event processing & narrative
│   ├── NarrativeContent.lua   # Text templates & flavor
│   ├── Minigames.lua          # Interactive minigames (6 types)
│   ├── UIManager.lua          # Centralized UI components
│   └── Screens/
│       ├── OccupationScreen.lua    # Jobs & education
│       ├── AssetsScreen.lua        # Property, vehicles, gambling
│       ├── RelationshipsScreen.lua # Family, friends, enemies
│       ├── ActivitiesScreen.lua    # Activities & crimes
│       └── StoryPathsScreen.lua    # Career progression
├── ServerScriptService/
│   ├── LifeManager.server.lua      # Core game loop
│   └── LifeRemoteHandlers.server.lua # Screen action handlers
└── StarterPlayerScripts/
    └── LifeClient.client.lua       # Main UI & rendering
```

## 🎯 Key Components

### LifeState (Extended)

```lua
-- New helper methods
state:ApplyEffects({ Happiness = 10, Health = -5, Money = 1000 })
state:SetFlag("gang_member")
state:ClearFlag("student")
state:HasFlag("president")
state:AddMoney(5000)
state:GetNetWorth()
state:GetStoryProgress("criminal") -- Returns 0-100
state:GetStoryTitle("political")   -- Returns "State Senator"

-- Relationships
state:AddRelationship("friends", { name = "John", relationship = 75 })
state:ModifyRelationship("friends", "john_id", 10)
state:GetRandomRelationship("classmates")

-- Career
state:SetCareer("teacher", "Math Teacher", "Lincoln High", 55000)
state:HasJob()
state:GetAnnualIncome()

-- Assets
state:AddAsset("houses", { name = "Beach House", value = 500000 })
state:AddAsset("cars", { make = "Ferrari", model = "488", value = 250000 })
```

### EventRunner Flow

```lua
-- 1. Check available events
local events = EventRunner.pickEvent(state, EventLibrary.Events)

-- 2. Build client payload with dynamic text
local payload, dynamicData = EventRunner.buildClientPayload(event, state)

-- 3. Apply choice and get narrative
local results = EventRunner.applyChoice(state, event, choiceIndex, dynamicData)
-- results.resultText = "You became a gang member!"
-- results.flagsSet = {"gang_member"}
-- results.effects = {Happiness = 10, Money = 5000}
```

### Minigames

```lua
-- Available minigame types
minigames:play("debate", callback)        -- Answer political questions
minigames:play("heist", callback)         -- Crack a safe code
minigames:play("getaway", callback)       -- Tap sequences to escape
minigames:play("qte", callback)           -- Quick time events
minigames:play("prison_escape", callback) -- Navigate maze to exit
minigames:play("mash", callback)          -- Tap rapidly

-- Callback receives: (success: boolean, data: table)
```

### UIManager

```lua
local UIManager = require(game.ReplicatedStorage.UIManager)
local ui = UIManager.new(screenGui)

-- Create BitLife-style event card
local card = ui:createEventCard({
    parent = screenGui,
    category = "crime",
    emoji = "🔫",
    title = "Bank Heist",
    text = "Your crew is ready. Are you in?",
    choices = {
        { text = "🎯 I'm in!" },
        { text = "🚫 Too risky" },
    },
    showSurpriseMe = true,
    onChoice = function(index) print("Chose:", index) end,
})

-- Create result popup
ui:createResultCard({
    parent = screenGui,
    success = true,
    emoji = "💰",
    title = "Heist Successful!",
    body = "You got away with $500,000!",
    statChanges = { Happiness = 15 },
    moneyChange = 500000,
})

-- Show stat toast (BitLife-style "Much Smarter")
ui:showStatToast({
    parent = screenGui,
    statName = "Smarts",
    oldValue = 50,
    newValue = 65,
    reason = "You read a lot of books this year.",
})
```

## 🎨 UI Colors

The `UIManager.Colors` table provides consistent colors:

```lua
-- Accents
UIManager.Colors.Blue, BlueDark, BluePale
UIManager.Colors.Green, GreenDark, GreenPale
UIManager.Colors.Red, RedDark, RedPale
UIManager.Colors.Amber, AmberDark, AmberPale
UIManager.Colors.Purple, Pink, Cyan, Orange

-- Neutrals
UIManager.Colors.White, Gray100-900, Black

-- Category colors
UIManager.Colors.Education  -- Blue
UIManager.Colors.Crime      -- Red
UIManager.Colors.Money      -- Green
UIManager.Colors.Social     -- Purple
```

## 📡 Remote Events

### Client → Server

| Remote | Purpose |
|--------|---------|
| `RequestAgeUp` | Advance age by 1 year |
| `SubmitChoice` | Submit event choice |
| `MinigameResult` | Report minigame outcome |
| `SetLifeInfo` | Set name & gender |
| `ApplyForJob` | Apply for a job |
| `EnrollEducation` | Enroll in school |
| `DoActivity` | Perform an activity |
| `CommitCrime` | Attempt a crime |
| `InteractPerson` | Interact with relationship |
| `BuyProperty/Vehicle` | Purchase assets |
| `DoSpecialAction` | Career-specific actions |

### Server → Client

| Remote | Purpose |
|--------|---------|
| `SyncState` | Sync full player state |
| `PresentEvent` | Show event card |
| `ShowResult` | Show result popup |

## 🎮 How Events Work

### Event Definition

```lua
{
    id = "join_gang",
    minAge = 16, maxAge = 30,
    weight = 15,
    cooldown = 3,           -- Can't fire again for 3 years
    oneTime = false,        -- Can fire multiple times
    milestone = false,      -- Not a forced milestone
    
    emoji = "🔪",
    title = "Gang Recruitment",
    category = "crime",
    
    requires = function(state)
        return state:HasFlag("criminal_tendencies")
            and not state:HasFlag("gang_member")
            and not state.InJail
    end,
    
    getDynamicData = function(state)
        return {
            gangName = pickRandom({"Bloods", "Crips", "Latin Kings"}),
            recruiterName = randomName(),
        }
    end,
    
    text = "A member of the %gangName% approaches you. %recruiterName% says they've been watching you...",
    
    choices = {
        {
            text = "Join the gang",
            effects = { Happiness = 10, Money = 2000 },
            setFlags = {"gang_member", "criminal"},
            resultText = "You're now part of the %gangName%.",
        },
        {
            text = "Refuse",
            effects = { Happiness = -5 },
            resultText = "You walked away. Maybe it's for the best.",
        },
        {
            text = "🎮 Fight your way in",
            minigame = "qte",
            effects = { Health = -10, Happiness = 20 },
            setFlag = "gang_member",
            resultText = "You proved yourself in a brutal initiation.",
        },
    },
}
```

### Event Flow

1. **Age Up** → Server picks eligible event
2. **Present Event** → Client shows BitLife card
3. **Player Chooses** → Client sends choice to server
4. **If Minigame** → Client plays minigame, sends result
5. **Apply Effects** → Server modifies state, sets flags
6. **Show Result** → Client shows result popup with stat changes
7. **Update Feed** → Add narrative text to life feed

## 🚀 Getting Started

1. Copy all files to their respective locations in Roblox Studio
2. Ensure `LifeRemotes` folder exists in `ReplicatedStorage`
3. Run the game - intro screen will appear
4. Pick gender and name to start your life
5. Press the Age button to advance through life

## 📝 Adding New Events

1. Open `EventLibrary.lua`
2. Add new event to the `events` table
3. Follow the event definition structure above
4. Use `requires` function for complex conditions
5. Use `getDynamicData` for random names/values
6. Test with different ages and flag combinations

## 🎮 Adding New Minigames

1. Open `Minigames.lua`
2. Create `createXXXGame()` function for UI
3. Create `startXXX(callback)` function
4. Add to `play()` function's if-else chain
5. Add to `cancel()` function
6. Add to `getAvailableGames()` list

## ⛓️ Prison System

When in jail, the Activities screen transforms to show prison-specific options:

| Activity | Effect | Risk |
|----------|--------|------|
| 🔐 Escape Prison | Freedom (minigame) | Very High |
| 💪 Yard Workout | +Health +Looks | None |
| 📚 Get GED | +Smarts | None |
| ⛓️ Join Prison Gang | +Protection -Health | Medium |
| 🔥 Start Riot | Chaos! | Very High |
| 🐀 Snitch | -Sentence +Danger | High |
| ⚖️ Appeal Sentence | Legal help ($5K) | None |
| 😇 Good Behavior | -Sentence | Low |

### Prison Event Path

The criminal story path includes deep prison events:
- **Prison Life** - Daily choices and survival
- **Yard Confrontation** - Handle conflicts
- **Contraband** - Risk vs reward
- **Cellmate Stories** - Learn from other inmates
- **Parole Hearing** - Early release chances
- **Prison Riot** - Chaos opportunities
- **Escape Route** - Plan your breakout

### Fugitive Path (After Escape)

If you escape prison, new events unlock:
- **Finding Shelter** - Where to hide
- **Close Call** - Avoid police
- **New Identity** - Start over ($10K)
- **Recapture Risk** - Stay hidden or get caught

## 📊 Statistics

- **Events**: 200+ unique events (including prison path)
- **Career Paths**: 6 deep progression paths
- **Minigames**: 6 interactive minigames
- **Relationships**: Family, Friends, Lovers, Enemies
- **Assets**: Houses, Cars, Businesses, Pets
- **Activities**: Mind & Body, Social, Entertainment, Crime, Prison

## 🔧 Configuration

Key values you might want to adjust:

```lua
-- LifeManager.server.lua
local SIGNIFICANT_HAPPINESS_CHANGE = 15  -- Popup threshold
local SIGNIFICANT_MONEY_CHANGE = 5000    -- Popup threshold

-- EventLibrary.lua  
local DEFAULT_WEIGHT = 10               -- Event selection weight

-- Minigames.lua
local DEBATE_TIME_PER_QUESTION = 8      -- Seconds
local HEIST_MAX_ATTEMPTS = 6            -- Code guesses
```

## 📜 License

Created for Roblox game development. Feel free to use and modify.

---

**Built with ❤️ for the ultimate BitLife experience on Roblox**
