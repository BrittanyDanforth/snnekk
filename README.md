# BloxLife - BitLife Clone for Roblox

A complete BitLife-style life simulation game for Roblox, featuring a pixel-perfect recreation of the iconic BitLife UI with full navigation screens.

## Features

### 🎮 Core Gameplay
- **Life Simulation**: Create a character and live their life from birth to death
- **Age Up System**: Press the big green Age button to advance one year at a time
- **Random Events**: Experience life events with multiple choice outcomes
- **Stats System**: Track Happiness, Health, Smarts, and Looks
- **Money System**: Earn and spend money throughout your life

### 🎨 BitLife-Authentic UI

#### Intro Sequence
1. **Gender Selection Screen** - Blurred overlay with yellow title, two massive pill buttons (blue Male ♂, pink Female ♀)
2. **Name Selection Screen** - Three colored name pills (Green, Yellow, Orange) with avatar emojis
3. **Tutorial Overlay** - Pointing hand emoji, instructional text, pulsing red ring around Age button

#### Main Game Screen
- **Header Bar**: Avatar circle, name, age/year, and blue money chip
- **Life Feed**: Scrolling feed with styled entry bubbles
- **Stats Panel**: Four animated stat bars with boost buttons when low
- **Navigation Bar**: Dark blue nav with 4 functional buttons
- **Age Button**: Big green circular button with white outer ring

#### Event Modal
- White rounded card with red/orange border
- Optional relationship header (avatar + name + "Best Friend" banner)
- Large emoji + bold title
- Centered description text
- Full-width blue pill choice buttons
- "Surprise me!" random choice option

### 📱 Full Navigation Screens

#### 💼 Occupation Screen (`OccupationScreen.lua` - 984 lines)
- **Current Job Section**: Shows current employment or unemployed state
- **Job Listings**: Entry-level to professional positions with salary, company, requirements
- **Education**: High School, Community College, University, Graduate/Medical/Law School
- **Freelance & Gig Work**: Food delivery, rideshare, freelance writing, tutoring
- **Special Careers**: Military, YouTuber, Business owner, Musician, Actor

#### 🏠 Assets Screen (`AssetsScreen.lua` - 969 lines)
- **Net Worth Card**: Total value with breakdown by category
- **My Assets**: Owned properties, vehicles, and items
- **Property Market**: Apartments, houses, estates ($85K - $50M)
- **Vehicle Dealership**: Economy cars to supercars, yachts, private jets
- **Shopping**: Electronics, luxury items, crypto investments

#### ❤️ Relationships Screen (`RelationshipsScreen.lua` - 796 lines)
- **Family**: Parents, siblings, grandparents with relationship bars
- **Friends**: Best friends, close friends with status indicators
- **Love Life**: Dating, partners, marriage options
- **Enemies**: Rivals with reconciliation or conflict options
- **Find Someone**: Dating app, school/work, social events, online

#### 🎭 Activities Screen (`ActivitiesScreen.lua` - 939 lines)
- **Mind & Body**: Reading, meditation, gym, yoga, martial arts, spa
- **Social**: Parties, hangouts, dates, nightclub
- **Entertainment**: TV, gaming, movies, concerts, vacation, casino
- **Crime**: Shoplifting to bank robbery with risk/reward/jail time
- **Special**: Lottery, emigration, witch doctor

## File Structure

```
/workspace
├── ReplicatedStorage/
│   ├── EventLibrary.lua       # Life events and choices (594 lines)
│   ├── EventRunner.lua        # Event selection logic (82 lines)
│   ├── LifeState.lua          # Player state management (51 lines)
│   └── Screens/
│       ├── OccupationScreen.lua   # Jobs, education, careers (984 lines)
│       ├── AssetsScreen.lua       # Properties, vehicles, items (969 lines)
│       ├── RelationshipsScreen.lua # Family, friends, dating (796 lines)
│       └── ActivitiesScreen.lua   # Hobbies, social, crime (939 lines)
├── ServerScriptService/
│   └── LifeManager.server.lua # Server-side game logic (204 lines)
├── StarterPlayerScripts/
│   └── LifeClient.client.lua  # Main UI client (1447 lines)
└── README.md

Total: 6,066 lines of Lua code
```

## Color Palette

| Element | Color | RGB |
|---------|-------|-----|
| BitLife Blue | Primary buttons | (37, 99, 235) |
| Age Green | Age button | (34, 197, 94) |
| Relationship Red | Event borders | (239, 68, 68) |
| Best Friend Orange | Relationship banner | (249, 115, 22) |
| Male Blue | Gender button | (56, 189, 248) |
| Female Pink | Gender button | (244, 114, 182) |
| Tutorial Yellow | Intro text | (253, 224, 71) |
| Nav Bar Blue | Navigation | (30, 58, 138) |
| Jobs Green | Occupation section | (34, 197, 94) |
| Education Purple | School section | (139, 92, 246) |
| Crime Red | Crime section | (220, 38, 38) |

## Events Included (25+)

### Baby/Toddler (Age 0-2)
- First Steps, First Words

### Early Childhood (Age 2-5)
- Playground Drama, Pet Goldfish, First Day of School

### Childhood (Age 6-12)
- Bully Encounter, Tooth Fairy, Science Fair, Birthday Party

### Teen Years (Age 13-17)
- First Crush, Driving Test, Party Invitation

### Relationship Events
- Friend Unfriended (with full header UI), New Sibling

### Adult Events (Age 18+)
- College Decision, Job Offer, Lottery Ticket

## Screen Module Architecture

Each screen is a self-contained ModuleScript with:
- `new(screenGui, blurOverlay, showBlur, hideBlur, playerState)` - Constructor
- `createUI()` - Builds all UI elements
- `show()` / `hide()` / `toggle()` - Visibility controls
- Slide-in/out animations using TweenService
- Section headers with colored gradients
- Card-based layouts for items/options
- Hover and click interactions

## Technical Details

### Networking
- `SyncState`: Server → Client state synchronization
- `RequestAgeUp`: Client requests age advancement
- `PresentEvent`: Server sends events to client
- `SubmitChoice`: Client sends choices to server
- `SetLifeInfo`: Client sends initial name/gender

### UI Features
- All UI created programmatically (no Studio required)
- TweenService for smooth animations
- Proper Z-indexing for overlay layering
- AutomaticSize for dynamic content
- UIListLayout for consistent spacing
- Pill and rounded corner styles throughout

### Fonts
- **GothamBold**: Titles and headers
- **Gotham**: Body text
- **GothamMedium**: Semi-bold text

## Installation

1. Copy all files to their respective Roblox service folders
2. The game automatically creates the remote events folder
3. Play to test the intro flow and life simulation

## Bugs Fixed
- Removed shadow frame from event card that was causing UIListLayout issues
- Fixed nav buttons to properly open their respective screens
- Proper event data passing from server to client

## Credits

Inspired by BitLife by Candywriter, LLC. This is a fan recreation for educational purposes on Roblox.
