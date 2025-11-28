# BitLife-Style Roblox Life Simulator

A comprehensive BitLife-style life simulation game built in Roblox with a fully interactive UI system.

## 🎮 Features

### Main Game UI
- **Gender Selection Screen** - Choose male or female with big colorful pill buttons
- **Name Selection Screen** - Pick from three randomly generated characters with colored bars
- **Tutorial Overlay** - Shows players how to use the Age button
- **Life Feed** - Scrolling feed showing life events by age
- **Stats Panel** - Happiness, Health, Smarts, Looks with animated bars and "Boost!" buttons
- **Navigation Bar** - Quick access to all game screens
- **Age Button** - Central green button to progress through life

### Event System
- **Dynamic Event Modals** - Relationship events with avatars, relationship banners
- **Choice System** - Multiple choice buttons for life decisions
- **"Surprise Me!" Option** - Random choice selection

## 📱 Screen Modules (Fully Interactive!)

### 💼 Occupation Screen
- **Current Job Display** - Shows your job title, company, and salary
- **Job Listings** - Apply for various positions from Fast Food Worker to Doctor
  - Each job shows requirements (education, experience)
  - Application modal with confirmation
  - Random acceptance based on qualifications
- **Education** - Enroll in programs from High School to PhD
  - Shows duration, cost, and requirements
  - Enrollment confirmation modal
- **Freelance & Gig Work** - Quick money opportunities
  - Instant results with random pay
  - No requirements
- **Special Careers** - Unique paths like Actor, Athlete, Entrepreneur
  - Risk/reward system
  - Stat requirements

### 💰 Assets Screen
- **Net Worth Display** - Shows total cash and assets
- **Property Market** - Buy real estate
  - Properties from Studio Apartments to Mansions
  - Shows bedrooms, square footage, location
  - Purchase confirmation with affordability check
- **Vehicle Dealership** - Buy vehicles
  - Cars, boats, aircraft
  - Year, type, speed details
- **Shopping** - Buy items (jewelry, electronics, fashion)
- **Crypto Exchange** - Buy cryptocurrency with price changes

### ❤️ Relationships Screen
- **Family Section** - Interact with family members
- **Friends Section** - Manage friendships
- **Enemies Section** - Handle conflicts
- **Interaction System** - Click any person to see options:
  - **Compliment** - Increase relationship
  - **Insult** - Risk damaging relationship
  - **Give Gift** - Costs money, high reward
  - **Spend Time** - Quality time together
  - **Argue** - Risk conflict
  - **Apologize** - Repair relationships
  - **Ask for Money** - Get cash from family
  - **Conversation** - Safe relationship building
- **Outcome System** - Random positive/negative results with stat changes

### 🎭 Activities Screen
- **Mind & Body** - Self-improvement activities
  - Read, Study, Meditate, Gym, Run, Yoga
  - Spa Day, Salon Visit (cost money)
  - Shows stat effects
- **Social** - Social activities
  - Parties, Nightclub, Hang Out
  - Host a Party (costs money)
- **Entertainment** - Fun activities
  - TV, Video Games, Movies
  - Concert, Vacation (expensive)
  - Casino (gambling - win or lose!)
- **Crime** - Risky illegal activities
  - Shoplift, Pickpocket, Burglary
  - Grand Theft Auto, Bank Robbery
  - Shows risk %, potential reward, jail time
  - Get caught or get away!

## 🛠️ Technical Details

### File Structure
```
ReplicatedStorage/
├── EventLibrary.lua      - Event definitions
├── EventRunner.lua       - Event processing
├── LifeState.lua         - State management
└── Screens/
    ├── OccupationScreen.lua   - Jobs, education, freelance
    ├── AssetsScreen.lua       - Properties, vehicles, shopping
    ├── RelationshipsScreen.lua - Family, friends, enemies
    └── ActivitiesScreen.lua   - Activities and crime

ServerScriptService/
└── LifeManager.server.lua - Server-side game logic

StarterPlayerScripts/
└── LifeClient.client.lua  - Main client UI (~1540 lines)
```

### Debug Logging
The client now outputs detailed debug messages:
```
[LifeClient] Found Screens folder, loading modules...
[LifeClient] ✅ OccupationScreen loaded
[LifeClient] ✅ AssetsScreen loaded
[LifeClient] ✅ RelationshipsScreen loaded
[LifeClient] ✅ ActivitiesScreen loaded
[LifeClient] Initializing screen instances...
[LifeClient] ✅ OccupationScreen instance created
[LifeClient] ✅ AssetsScreen instance created
[LifeClient] ✅ RelationshipsScreen instance created
[LifeClient] ✅ ActivitiesScreen instance created
[LifeClient] Screen initialization complete!
```

### UI Features
- **Smooth Animations** - TweenService for all transitions
- **Modal System** - Confirmation dialogs, result displays
- **Hover Effects** - Interactive button feedback
- **Auto-sizing** - Responsive layouts with UIListLayout
- **Color Coding** - Category-based color schemes

### Error Handling
- All module loading wrapped in pcall
- Graceful fallbacks if screens fail to load
- Debug warnings for troubleshooting

## 🎨 Design System

### Colors
- **BitLife Blue** - Primary actions (#2563EB)
- **Success Green** - Positive outcomes (#22C55E)
- **Error Red** - Negative outcomes (#EF4444)
- **Gold** - Special items (#EAB308)
- **Category Colors** - Each screen has its own palette

### Typography
- **GothamBold** - Titles and buttons
- **GothamMedium** - Emphasis text
- **Gotham** - Body text

## 🎯 How to Play

1. **Start** - Pick your gender (Male/Female)
2. **Name** - Choose from three random characters
3. **Age Up** - Press the green Age button to grow older
4. **Events** - Make choices when life events occur
5. **Manage Life** - Use the four screen tabs:
   - 💼 Get a job, education, or freelance
   - 💰 Buy properties, cars, and items
   - ❤️ Build relationships with people
   - 🎭 Do activities (legal and illegal!)

## 📝 Notes

- All interactions have visual feedback (modals, toasts)
- Crime activities can result in jail time
- Relationships affect gameplay outcomes
- Money management is key to success

---

Built with ❤️ for Roblox
