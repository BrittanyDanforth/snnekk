# LifeEvents Module Setup Instructions for Roblox Studio

## The Problem
The server output shows: `LifeEvents module not found - using legacy events only`

This happens because Roblox Studio doesn't automatically recognize folder structures with init.lua files like other Lua environments do.

## Solution: Manual Setup in Roblox Studio

### Step 1: Create the LifeEvents ModuleScript
1. In Roblox Studio, go to **ReplicatedStorage**
2. Right-click → **Insert Object** → **ModuleScript**
3. Name it exactly: `LifeEvents`
4. Copy the ENTIRE contents of `init.lua` into this ModuleScript

### Step 2: Add Child Modules
For EACH file in the LifeEvents folder (except init.lua and this README):

1. Right-click on the **LifeEvents** ModuleScript you just created
2. **Insert Object** → **ModuleScript**
3. Name it EXACTLY matching the filename (without .lua):
   - `child_0_5`
   - `child_6_12`
   - `teen_13_17`
   - `young_adult_18_35`
   - `middle_aged_36_55`
   - `senior_55_plus`
   - `career_criminal`
   - `career_political`
   - `career_arts`
   - `career_tech`
   - `career_sports`
   - `career_business`
   - `career_medical`
   - `career_education`
   - `career_legal`
   - `career_military`
   - `relationships`
   - `health`
   - `wealth`
   - `prison`
   - `random_encounters`
   - `disasters`
   - `fame`
4. Copy the contents of each .lua file into its corresponding ModuleScript

### Final Structure in Roblox Studio
```
ReplicatedStorage
├── EventLibrary (ModuleScript)
├── LifeEvents (ModuleScript) ← Contains init.lua content
│   ├── child_0_5 (ModuleScript)
│   ├── child_6_12 (ModuleScript)
│   ├── teen_13_17 (ModuleScript)
│   ├── young_adult_18_35 (ModuleScript)
│   ├── middle_aged_36_55 (ModuleScript)
│   ├── senior_55_plus (ModuleScript)
│   ├── career_criminal (ModuleScript)
│   ├── career_political (ModuleScript)
│   ├── career_arts (ModuleScript)
│   ├── career_tech (ModuleScript)
│   ├── career_sports (ModuleScript)
│   ├── career_business (ModuleScript)
│   ├── career_medical (ModuleScript)
│   ├── career_education (ModuleScript)
│   ├── career_legal (ModuleScript)
│   ├── career_military (ModuleScript)
│   ├── relationships (ModuleScript)
│   ├── health (ModuleScript)
│   ├── wealth (ModuleScript)
│   ├── prison (ModuleScript)
│   ├── random_encounters (ModuleScript)
│   ├── disasters (ModuleScript)
│   └── fame (ModuleScript)
└── LifeEventsBackup (ModuleScript) ← Optional backup
```

## Alternative: Use Rojo for File Sync
If you're using file-based development:
1. Install [Rojo](https://rojo.space/)
2. Create a `default.project.json` file
3. Rojo will automatically convert the folder structure to the correct Roblox hierarchy

## Verification
After setup, you should see in the output:
```
[LifeEvents] ═══════════════════════════════════════════
[LifeEvents] Script: ReplicatedStorage.LifeEvents
[LifeEvents] Loading event modules...
[LifeEvents] ✓ Loaded child_0_5 : XXX events
...
[EventLibrary] ✅ Loaded XXX modular events from LifeEvents system
```

## Quick Fix: Use LifeEventsBackup
If you don't want to set up all the modules, a simpler `LifeEventsBackup.lua` file is provided with essential events. Just make sure it's a ModuleScript named `LifeEventsBackup` in ReplicatedStorage.
