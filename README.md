# snnekk

## Activities Screen Setup

Follow these exact steps in Roblox Studio to wire up the BitLife-style Activities overlay:

1. **Create the folder path**  
   - In `ReplicatedStorage` add a Folder named `Screens`.  
   - Inside `Screens` create a ModuleScript named `ActivitiesScreen`.

2. **Paste the module code**  
   - Open `ReplicatedStorage/Screens/ActivitiesScreen.lua` from this repo.  
   - Copy the entire contents and replace the default ModuleScript code with it.  
   - Keep the script as a *ModuleScript* (not a LocalScript or Script) so both server and client can require it.

3. **Require the module from your client UI**  
   ```lua
   local ReplicatedStorage = game:GetService("ReplicatedStorage")
   local ActivitiesScreen = require(ReplicatedStorage:WaitForChild("Screens"):WaitForChild("ActivitiesScreen"))

   local screen, refs = ActivitiesScreen.mount(parentFrame, {
   	title = "Choose an activity.",
   	subtitle = "These affect your yearly outcome.",
   	callbacks = {
   		work = function(info)
   			print("Player picked", info.label)
   		end,
   		relationships = function()
   			-- open relationships flow
   		end,
   	},
   })
   ```
   - `parentFrame` should be a container in `StarterPlayerScripts/LifeClient` or any ScreenGui where you want the card to appear.
   - The function returns the created screen plus `refs.buttons` (lookup by key) and `refs.destroy()` helper.

4. **Hook it to the nav button**  
   - From `LifeClient.client.lua`, call `ActivitiesScreen.mount(bottomNavContainer, callbacks)` when the “Activities” nav icon is pressed.  
   - Store the returned `destroy` function so you can close the overlay when the player makes a choice or taps outside.

## Repo Layout (relevant files)

- `StarterPlayerScripts/LifeClient.client.lua` – main BitLife-style HUD.
- `ReplicatedStorage/Screens/ActivitiesScreen.lua` – ModuleScript for the Activities overlay (place under `ReplicatedStorage/Screens`).
- `ReplicatedStorage/EventLibrary.lua` etc. – simulation data.

Keep any future screens under `ReplicatedStorage/Screens` as ModuleScripts; that makes them easy to require from both LocalScripts and server scripts as your life simulation grows.
