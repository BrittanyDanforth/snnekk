# BloxLife - BitLife Clone for Roblox

A complete BitLife-style life simulation game for Roblox, featuring a pixel-perfect recreation of the iconic BitLife UI.

## Features

### 🎮 Core Gameplay
- **Life Simulation**: Create a character and live their life from birth to death
- **Age Up System**: Press the big green Age button to advance one year at a time
- **Random Events**: Experience life events with multiple choice outcomes
- **Stats System**: Track Happiness, Health, Smarts, and Looks
- **Money System**: Earn and spend money throughout your life

### 🎨 BitLife-Authentic UI

#### Intro Sequence
1. **Gender Selection Screen**
   - Blurred/dimmed background overlay
   - Yellow title text: "Start by picking a gender."
   - Two massive pill buttons (blue for Male ♂, pink for Female ♀)
   - White border outline on buttons with hover glow effect

2. **Name Selection Screen**
   - Same blurred overlay style
   - Yellow title: "Now, pick someone to become."
   - Three colored name pills (Green, Yellow, Orange)
   - Each pill shows an avatar emoji + randomly generated full name

3. **Tutorial Overlay**
   - Pointing hand emoji (👇) animation
   - Yellow instructional text explaining the Age system
   - Red highlight ring pulsing around the Age button

#### Main Game Screen
- **Header Bar**: White bar with avatar circle, name, age/year, and money chip
- **Life Feed**: Scrolling feed of life events with styled entries
- **Stats Panel**: Four stat bars (Happiness 😀, Health ❤️, Smarts 🧠, Looks 💄)
  - Animated progress bars with color-coded fills
  - Orange "Boost!" button appears when stats are low (<25%)
- **Navigation Bar**: Dark blue bottom nav with icon buttons
- **Age Button**: Big green circular button with + icon and white outer ring

#### Event Modal (Relationship Card Style)
- **Blurred Background**: Dark overlay when modal is open
- **Card Design**: 
  - Tall white rounded rectangle with red/orange border
  - Soft drop shadow for elevation effect
- **Header Section** (for relationship events):
  - Avatar circle on left
  - Name text (e.g., "Bradley Allen")
  - Relationship banner pill on right (e.g., "Best Friend" in orange)
- **Title Section**:
  - Large emoji centered
  - Bold title text (e.g., "Unfriended")
- **Description**: Centered multiline text explaining the situation
- **Choice Buttons**: 
  - Full-width blue pill buttons
  - White text, hover state changes color
  - Uniform height for visual consistency
- **"Surprise me!" Option**: Small grey underlined text for random choice

## File Structure

```
/workspace
├── ReplicatedStorage/
│   ├── EventLibrary.lua    # Defines all life events and choices
│   ├── EventRunner.lua     # Event selection and effect application logic
│   └── LifeState.lua       # Player state management (stats, money, etc.)
├── ServerScriptService/
│   └── LifeManager.server.lua  # Server-side game logic and networking
├── StarterPlayerScripts/
│   └── LifeClient.client.lua   # Complete BitLife-style UI (1490 lines)
└── README.md
```

## Color Palette

| Element | Color | RGB |
|---------|-------|-----|
| BitLife Blue | Primary buttons | (37, 99, 235) |
| Age Green | Age button | (34, 197, 94) |
| Relationship Red | Event card border | (239, 68, 68) |
| Best Friend Orange | Relationship banner | (249, 115, 22) |
| Male Blue | Gender button | (56, 189, 248) |
| Female Pink | Gender button | (244, 114, 182) |
| Tutorial Yellow | Intro text | (253, 224, 71) |
| Nav Bar Blue | Navigation | (30, 58, 138) |

## Events Included

### Baby/Toddler (Age 0-2)
- First Steps
- First Words

### Early Childhood (Age 2-5)
- Playground Drama
- Pet Goldfish
- First Day of School

### Childhood (Age 6-12)
- Bully Encounter
- Tooth Fairy
- Science Fair
- Birthday Party

### Teen Years (Age 13-17)
- First Crush
- Driving Test
- Party Invitation

### Relationship Events
- Friend Unfriended (with full relationship header UI)
- New Sibling

### Adult Events (Age 18+)
- College Decision
- Job Offer
- Lottery Ticket

## Technical Details

### Networking
- `SyncState`: Syncs player state from server to client
- `RequestAgeUp`: Client requests to age up
- `PresentEvent`: Server sends event to client
- `SubmitChoice`: Client sends choice back to server
- `SetLifeInfo`: Client sends initial name/gender to server

### UI Components
- All UI is created programmatically (no Roblox Studio required)
- Uses TweenService for smooth animations
- Proper Z-indexing for overlay layering
- AutomaticSize for dynamic content
- UIListLayout for consistent spacing

### Fonts Used
- **Gotham Bold**: Titles and headers
- **Gotham**: Body text
- **Gotham Medium**: Semi-bold text
- **FredokaOne**: Alternative title font

## Installation

1. Copy all files to their respective Roblox service folders
2. The game will automatically create the remote events folder
3. Play to test the intro flow and life simulation

## Credits

Inspired by BitLife by Candywriter, LLC. This is a fan recreation for educational purposes on Roblox.
