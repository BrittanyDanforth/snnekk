# BloxLife - BitLife Clone for Roblox

A comprehensive BitLife-style life simulation game with **5,000+ lines** of narrative content, 6 deep story paths, 4 minigames, **result popups with stat displays**, **screen shake effects**, and premium AAA-quality UI.

## 🎮 Features

### Core Gameplay
- **Life Simulation**: Age up year by year, making choices that shape your life
- **Stats System**: Happiness, Health, Smarts, and Looks (with rich narrative feedback)
- **Money & Economy**: Earn, spend, gamble, and invest
- **Relationships**: Family, friends, enemies, romance
- **Occupations**: Jobs and education paths
- **Activities**: Mind & body, social, entertainment, and crime
- **Assets**: Property, vehicles, and shop items

## 📚 MASSIVE Content System

### EventLibrary.lua (3,000+ lines, 150+ Unique Events)

#### 6 Deep Career Paths

| Path | Events | Requirements | Final Goal |
|------|--------|--------------|------------|
| **🏛️ President** | 18 milestone events | Political interest + clean record | President of the USA |
| **🔫 Criminal** | 20 milestone events | Criminal tendencies | Crime Boss / Kingpin |
| **👨‍🏫 Teacher** | 15 milestone events | Teaching interest | Superintendent |
| **🏎️ Racer** | 18 milestone events | Racing interest | F1 World Champion / Legend |
| **🎨 Artist** | 15 milestone events | Art interest | Art Legend / Museum |
| **💻 Hacker** | 18 milestone events | Computer interest | Elite Hacker / Tech Billionaire |

#### Life Stage Events
| Stage | Age Range | Event Types |
|-------|-----------|-------------|
| Baby/Toddler | 0-4 | Birth, first words, first steps, preschool |
| Childhood | 5-12 | School start, bullying, talent discovery |
| Teen | 13-18 | High school, driving, prom, graduation |
| Young Adult | 18-35 | College, first job, apartment, dating |
| Adult | 35-60 | Business, family, midlife, career peak |
| Senior | 60+ | Retirement, legacy, reflection |

#### Universal Life Events (50+ events)
- Romance: first crush, dating, proposal, wedding, breakup
- Family: divorce, sibling rivalry, pet adoption, baby born
- Health: illness, broken bone, addiction, recovery
- Social: talent show, charity, travel, celebrity encounter
- Money: lottery, investment, scam, windfall, lawsuit

### NarrativeContent.lua (900+ lines)
Rich BitLife-style text variations for immersive storytelling:

#### Stat Narratives (320+ variations)
- **Happiness**: 80 variations (up/down × magnitude)
- **Health**: 80 variations
- **Smarts**: 80 variations  
- **Looks**: 80 variations

#### Flag Descriptions (120+ life flags)
All career paths, life events, and achievements have unique descriptions.

#### Year Recap Templates
- 9 life stage recaps (baby → elderly)
- 9 special path recaps (criminal, political, teacher, racer, artist, hacker, romantic, wealthy, struggling)

### EventRunner.lua (800+ lines)
The event engine that prevents repetition and builds rich narratives:
- **Smart Flag Checking**: Events check `requires` functions before firing
- **One-Time Events**: Major milestones only happen once
- **Cooldowns**: Repeatable events have minimum year gaps
- **Dynamic Data**: Names, companies, cities generated per event
- **Narrative Builder**: Composes clean prose from stat changes

## 🌟 Deep Story Paths

### 🏛️ Presidential Career Path
Rise from ordinary citizen to the most powerful position!

**Progression (18 events):**
1. Political Interest → Learn about government
2. Political Intern → Work in an office
3. Campaign Volunteer → Learn campaigns
4. School Board → First election win
5. City Council → Local decisions
6. Mayor → Lead your city
7. State Representative → State capitol
8. State Senator → Upper chamber
9. Governor → Executive experience
10. Congressman → Washington DC
11. US Senator → National stage
12. Presidential Primary → Enter the race
13. Presidential Debate → Face opponents (minigame!)
14. Presidential Election → Win the vote
15. Inauguration → Take the oath
16. Presidential Crisis → Handle emergencies
17. Executive Order → Use your power
18. Cabinet/Summit events → Lead the nation

### 🔫 Criminal Empire Path
Build your criminal organization from scratch!

**Progression (20 events):**
1. Temptation → Resist or give in
2. Shoplifting → Start small
3. Getting Bolder → Bigger targets
4. Car Theft → Grand theft auto (minigame!)
5. First Arrest → Get caught
6. Prison Time → Do your time
7. Gang Recruitment → Get noticed
8. Gang Initiation → Prove yourself
9. Drug Dealing → Move product
10. Turf War → Fight for territory (minigame!)
11. Gang Captain → Lead soldiers
12. Heist Opportunity → Big score (minigame!)
13. Underboss → Second in command
14. Power Grab → Take over
15. Criminal Empire → Build your organization
16. FBI Investigation → Evade the feds
17. Money Laundering → Clean the cash
18. Empire Expansion → Grow your reach

### 👨‍🏫 Teacher Path
Shape young minds and rise through education!

**Progression:**
1. Teaching Interest → Discover passion
2. Education Degree → Study teaching
3. Student Teaching → Practice in classroom
4. First Teaching Job → Become a teacher
5. Difficult Student → Handle challenges
6. Inspiring Moment → Change lives
7. Teacher of the Year → Win awards
8. Department Head → Lead teachers
9. Vice Principal → Administration
10. Principal → Run a school
11. Superintendent → Lead the district

### 🏎️ Racer Path
From go-karts to Formula 1 glory!

**Progression:**
1. Racing Interest → Fall in love with speed
2. Karting League → Competitive racing
3. Karting Championship → Win titles (minigame!)
4. Junior Formula → Professional team
5. Junior Championship → More wins
6. F1 Test Driver → Join F1 team
7. F1 Race Driver → Official seat
8. First F1 Race → Debut (minigame!)
9. First F1 Win → Victory!
10. F1 Championship → World Champion
11. Racing Legend → Hall of Fame

### 🎨 Artist Path
Express yourself and become a legend!

**Progression:**
1. Art Interest → Discover talent
2. Art Competition → Win recognition
3. Art School → Study professionally
4. First Gallery Show → Public debut
5. Signature Style → Find your voice
6. First Major Sale → Sell artwork
7. Art Controversy → Handle critics
8. Museum Acquisition → Enter collections
9. Art Celebrity → Public recognition
10. Career Retrospective → Cement legacy

### 💻 Hacker Path
Master the digital world!

**Progression:**
1. Computer Interest → Fascination begins
2. Learn Programming → Study code
3. First Hack → School systems
4. First Exploit → Find vulnerabilities
5. White/Black Hat Choice → Ethical decision
6. Join Hacker Group → Find community
7. Corporate Hack → Business targets
8. Government Target → High stakes
9. FBI Investigation → Evade capture
10. Bug Bounty / Dark Web → Career choices
11. Elite Hacker Status → Recognition
12. Startup Founder → Build company
13. Tech Billionaire → Ultimate success

## 🎮 Minigames

### 🎤 Presidential Debate
Answer 5 political questions correctly to win the debate against your opponent!
- Score points for correct answers
- Timer adds pressure
- Beat opponent's score to win

### 🔓 Safe Cracking (Heist)
Crack the 4-digit code in 6 attempts!
- Green = correct digit in correct position
- Yellow = correct digit, wrong position
- Gray = digit not in code
- Wordle-style gameplay

### 🚗 Getaway
Escape the cops by following the sequence!
- Watch the highlighted buttons
- Tap them in order quickly
- Cops close in if you make mistakes
- Fill your progress bar to escape

### ⚡ Quick Time Event
Hit the button when the marker is in the green zone!
- Difficulty affects zone size
- Test your reflexes
- Used for various skill checks

## 📁 Project Structure

```
/ReplicatedStorage/
├── EventLibrary.lua       # 3,000+ lines, 150+ events
├── NarrativeContent.lua   # 900+ lines of text variations
├── EventRunner.lua        # 800+ lines, event engine
├── LifeState.lua          # Player state management
├── Minigames.lua          # 1,200+ lines, 4 minigames
└── Screens/
    ├── OccupationScreen.lua
    ├── AssetsScreen.lua
    ├── RelationshipsScreen.lua
    ├── ActivitiesScreen.lua
    └── StoryPathsScreen.lua

/ServerScriptService/
├── LifeManager.server.lua       # Core game loop
└── LifeRemoteHandlers.server.lua # Actions handler

/StarterPlayerScripts/
└── LifeClient.client.lua        # Main UI (1,500+ lines)
```

**Total: 4,700+ lines of content across the event system!**

## 🔧 Event System (No Repetition!)

### Event Properties
```lua
{
    id = "unique_id",
    minAge = 18, maxAge = 65,  -- Age range
    weight = 10,               -- Selection probability
    oneTime = true,            -- Fire only once
    cooldown = 5,              -- Years between repeats
    milestone = true,          -- Guaranteed if eligible
    category = "school",       -- For narrative
    
    requires = function(state)
        -- SMART FLAG CHECKING prevents wrong events
        local f = state.Flags or {}
        return f.has_job and not f.already_promoted
    end,
    
    choices = {
        {
            text = "Choice text",
            effects = { Happiness = 10, Money = -100 },
            resultText = "What happens",
            setFlag = "new_flag",        -- Set one flag
            setFlags = {"a", "b"},       -- Set multiple
            clearFlag = "old_flag",      -- Remove flag
            minigame = "debate",         -- Trigger minigame
        }
    }
}
```

### Why Events Don't Repeat
1. **`oneTime = true`**: Major life events (graduation, first job, wedding) only fire once
2. **`cooldown = N`**: Years must pass before event can repeat
3. **`requires` function**: Checks flags to ensure event makes sense
4. **History tracking**: `EventHistory.seenEvents` tracks all fired events
5. **Smart flag checking**: Career events check you don't already have that career

Example: Job offer won't appear if:
- `oneTime = true` and you already saw it
- `requires` function returns false because you already have a job
- Your age is outside the min/max range

## 🎨 UI Features

### Premium BitLife-Style Design
- **Header**: Positioned to avoid Roblox logo overlap
- **Avatar**: Dynamic emoji based on age
- **Money Display**: Formatted with icons
- **Stats Row**: Split LEFT/RIGHT avoiding center Age button
- **Nav Bar**: Split LEFT/RIGHT with centered Age button
- **Event Modals**: Animated slide-in with rich narrative text

### 🆕 Result Popup System (BitLife-Style!)
Every decision now triggers a detailed popup showing:
- **Big emoji** (72px) - visual feedback
- **Large title** (32px) - what happened
- **Detailed description** (20px) - the story
- **Stat change indicators** - see +/- for each stat
- **Money change** - formatted with colors
- **Continue button** - dismiss the popup

### 🆕 Visual Feedback Effects
- **Screen Shake**: Negative outcomes shake the screen (like real BitLife!)
- **Red Flash**: Damage/loss events flash red
- **Green Flash**: Good outcomes flash green  
- **Blue Flash**: New events pop in with blue flash

### 🆕 Bigger Text Everywhere
All event cards now have 20% larger text:
- Event emoji: 60px (was 48px)
- Event title: 32px (was 26px)
- Event body: 20px (was 16px)
- Question text: 18px (was 15px)
- Choice buttons: 58px height with 18px text

### Navigation Layout
```
LEFT                 CENTER               RIGHT
┌────────────────┐   ┌─────────┐   ┌────────────────┐
│ Work   Assets  │   │  AGE+   │   │ People Fun Story│
└────────────────┘   └─────────┘   └────────────────┘
```

## 🚀 Getting Started

1. Place all files in their respective locations in Roblox Studio
2. The `LifeRemotes` folder will be auto-created on first run
3. Play and enjoy your BitLife experience!

## 📝 License

MIT License - Feel free to use and modify!
