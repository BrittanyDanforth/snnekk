# BitLife-Style Roblox Life Simulator

A comprehensive BitLife-style life simulation game with **server-validated** actions. No more 4-year-olds going to law school or broke babies buying mansions!

## 🚀 SETUP INSTRUCTIONS

### Step 1: Create the Remotes Folder

In Roblox Studio, you need to create a folder with all the remotes. You can do this manually OR use the setup script below.

**Option A: Run Setup Script (Recommended)**

Create a **Script** in ServerScriptService with this code, run once, then delete:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local folder = ReplicatedStorage:FindFirstChild("LifeRemotes")
if not folder then
    folder = Instance.new("Folder")
    folder.Name = "LifeRemotes"
    folder.Parent = ReplicatedStorage
end

-- Remote Events (one-way client→server)
local events = {
    "RequestAgeUp", "PresentEvent", "SubmitChoice", 
    "SyncState", "SetLifeInfo", "QuitJob"
}

-- Remote Functions (request→response)
local functions = {
    "ApplyForJob", "DoWork", "EnrollEducation", "DoFreelance", "TrySpecialCareer",
    "BuyProperty", "BuyVehicle", "BuyItem", "BuyCrypto", "SellAsset",
    "InteractPerson", "GiveMoney",
    "DoActivity", "CommitCrime", "Gamble"
}

for _, name in ipairs(events) do
    if not folder:FindFirstChild(name) then
        local r = Instance.new("RemoteEvent")
        r.Name = name
        r.Parent = folder
    end
end

for _, name in ipairs(functions) do
    if not folder:FindFirstChild(name) then
        local r = Instance.new("RemoteFunction")
        r.Name = name
        r.Parent = folder
    end
end

print("✅ All LifeRemotes created! You can delete this script now.")
```

**Option B: Create Manually**

Create this structure in ReplicatedStorage:
```
ReplicatedStorage/
└── LifeRemotes/           (Folder)
    ├── RequestAgeUp       (RemoteEvent)
    ├── PresentEvent       (RemoteEvent)
    ├── SubmitChoice       (RemoteEvent)
    ├── SyncState          (RemoteEvent)
    ├── SetLifeInfo        (RemoteEvent)
    ├── QuitJob            (RemoteEvent)
    ├── ApplyForJob        (RemoteFunction)
    ├── DoWork             (RemoteFunction)
    ├── EnrollEducation    (RemoteFunction)
    ├── DoFreelance        (RemoteFunction)
    ├── TrySpecialCareer   (RemoteFunction)
    ├── BuyProperty        (RemoteFunction)
    ├── BuyVehicle         (RemoteFunction)
    ├── BuyItem            (RemoteFunction)
    ├── BuyCrypto          (RemoteFunction)
    ├── SellAsset          (RemoteFunction)
    ├── InteractPerson     (RemoteFunction)
    ├── GiveMoney          (RemoteFunction)
    ├── DoActivity         (RemoteFunction)
    ├── CommitCrime        (RemoteFunction)
    └── Gamble             (RemoteFunction)
```

### Step 2: Place the Scripts

Copy these files to the correct locations:

| File | Location in Roblox |
|------|-------------------|
| `LifeClient.client.lua` | StarterPlayer → StarterPlayerScripts |
| `LifeManager.server.lua` | ServerScriptService |
| `LifeRemoteHandlers.server.lua` | ServerScriptService |
| `EventLibrary.lua` | ReplicatedStorage |
| `EventRunner.lua` | ReplicatedStorage |
| `LifeState.lua` | ReplicatedStorage |
| `OccupationScreen.lua` | ReplicatedStorage → Screens |
| `AssetsScreen.lua` | ReplicatedStorage → Screens |
| `RelationshipsScreen.lua` | ReplicatedStorage → Screens |
| `ActivitiesScreen.lua` | ReplicatedStorage → Screens |

### Step 3: Create the Screens Folder

In ReplicatedStorage, create a **Folder** called `Screens` and place all 4 screen modules inside it.

---

## 🎮 Features

### Server-Validated Actions

Every action now checks:
- ✅ **Age requirements** - Can't go to nightclub at age 5
- ✅ **Money requirements** - Can't buy a mansion with $0
- ✅ **Education requirements** - Can't be a doctor without medical school
- ✅ **Experience requirements** - Can't be senior developer on day 1

### Occupation Screen (💼)
| Action | Age Req | Other Requirements |
|--------|---------|-------------------|
| Fast Food Worker | 14+ | None |
| Retail Associate | 16+ | None |
| Receptionist | 18+ | High School |
| Software Developer | 22+ | Bachelor's + 2yr exp |
| Doctor | 30+ | Medical School + 8yr exp |
| Lawyer | 28+ | Law School + 5yr exp |

**Education**
| Program | Age | Cost | Prerequisite |
|---------|-----|------|-------------|
| High School | 14-18 | FREE | None |
| Community College | 18+ | $15K | High School |
| Bachelor's | 18+ | $80K | High School |
| Medical School | 22-45 | $200K | Bachelor's |
| Law School | 22-50 | $150K | Bachelor's |

**Freelance Gigs**
| Gig | Age Req | Pay Range |
|-----|---------|-----------|
| Walk Dogs | 10+ | $20-50 |
| Babysit | 12+ | $50-120 |
| Food Delivery | 16+ | $30-80 |
| Drive Rideshare | 21+ | $50-150 |

### Assets Screen (💰)
| Asset Type | Min Age | Examples |
|------------|---------|----------|
| Sneakers | 10+ | $350 |
| Used Car | 16+ | $8,000 |
| Condo | 18+ | $175,000 |
| Crypto | 18+ | Varies |
| Luxury Car | 21+ | $180,000+ |
| Yacht/Jet | 25+ | $2M-$15M |

### Relationships Screen (❤️)
| Action | Age Req | Cost | Notes |
|--------|---------|------|-------|
| Spend Time | 2+ | FREE | Safe option |
| Conversation | 3+ | FREE | Build relationship |
| Compliment | 3+ | FREE | 70% success |
| Apologize | 4+ | FREE | Repair relationships |
| Gift | 5+ | $50 | High success rate |
| Insult | 5+ | FREE | 20% success, high damage |
| Ask Money | 5+ | FREE | Family only |

### Activities Screen (🎭)
| Activity | Age Req | Cost | Notes |
|----------|---------|------|-------|
| Watch TV | 2+ | FREE | +Happiness |
| Hang Out | 5+ | FREE | Social |
| Go to Movies | 5+ | $20 | Entertainment |
| Go to Gym | 14+ | FREE | +Health/Looks |
| Go to Party | 14+ | FREE | Social |
| Spa Day | 16+ | $200 | +Looks |
| Nightclub | 21+ | $50 | Adults only! |
| Casino | 21+ | $100 | Gambling |

**Crime** (Server validates age!)
| Crime | Age | Risk | Reward |
|-------|-----|------|--------|
| Shoplift | 8+ | 25% | $20-150 |
| Pickpocket | 10+ | 35% | $30-300 |
| Burglary | 16+ | 50% | $500-5K |
| Grand Theft Auto | 16+ | 60% | $2K-20K |
| Bank Robbery | 18+ | 80% | $10K-500K |

---

## 📁 File Structure

```
ServerScriptService/
├── LifeManager.server.lua        # Main game logic
└── LifeRemoteHandlers.server.lua # NEW! Handles all screen remotes

ReplicatedStorage/
├── EventLibrary.lua              # Life event definitions
├── EventRunner.lua               # Event processing
├── LifeState.lua                 # State management
├── LifeRemotes/                  # Folder with all remotes
│   ├── (RemoteEvents)
│   └── (RemoteFunctions)
└── Screens/
    ├── OccupationScreen.lua      # Jobs, education, freelance
    ├── AssetsScreen.lua          # Properties, vehicles, items
    ├── RelationshipsScreen.lua   # Family, friends, enemies
    └── ActivitiesScreen.lua      # Activities and crime

StarterPlayerScripts/
└── LifeClient.client.lua         # Main client UI
```

---

## 🔧 How It Works

1. **Player opens a screen** (Occupation, Assets, etc.)
2. **Screen shows current player age/money** from shared state
3. **Player clicks an action** (Apply, Buy, etc.)
4. **Client calls RemoteFunction** with action ID
5. **Server validates:**
   - Is player old enough?
   - Does player have enough money?
   - Does player meet requirements?
6. **Server returns result** (success/fail + message)
7. **Client shows result modal** with outcome

---

## 🎯 Quick Start Guide

1. Pick gender (Male/Female)
2. Pick a character name
3. Press **Age** to grow older
4. Open screens using nav buttons:
   - 💼 Get jobs, education
   - 💰 Buy stuff (when you have money!)
   - ❤️ Build relationships
   - 🎭 Do activities (age-appropriate!)
5. Make choices when events pop up
6. Live your best (or worst) life!

---

## ⚠️ Common Issues

**"Server not available" error**
- Make sure the LifeRemotes folder exists
- Make sure LifeRemoteHandlers.server.lua is in ServerScriptService
- Run the setup script to create missing remotes

**Screens not showing age/money**
- The playerState needs to be synced from server
- Check that SyncState remote is firing properly

**Actions always fail validation**
- Make sure you've aged up your character
- Check that money is being tracked

---

Built with ❤️ for Roblox
