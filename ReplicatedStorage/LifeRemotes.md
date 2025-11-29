# Life Remotes Setup Guide

## Required Folder Structure in ReplicatedStorage

You need to create a **Folder** called `LifeRemotes` in ReplicatedStorage with these RemoteEvents and RemoteFunctions:

```
ReplicatedStorage/
└── LifeRemotes/           (Folder)
    ├── RequestAgeUp       (RemoteEvent) - Already exists
    ├── PresentEvent       (RemoteEvent) - Already exists  
    ├── SubmitChoice       (RemoteEvent) - Already exists
    ├── SyncState          (RemoteEvent) - Already exists
    ├── SetLifeInfo        (RemoteEvent) - Already exists
    │
    │-- NEW REMOTES NEEDED:
    │
    ├── ApplyForJob        (RemoteFunction) - Apply to a job listing
    ├── QuitJob            (RemoteEvent) - Quit current job
    ├── DoWork             (RemoteFunction) - Work at current job
    ├── EnrollEducation    (RemoteFunction) - Enroll in school
    ├── DoFreelance        (RemoteFunction) - Do a freelance gig
    ├── TrySpecialCareer   (RemoteFunction) - Attempt special career
    │
    ├── BuyProperty        (RemoteFunction) - Purchase property
    ├── BuyVehicle         (RemoteFunction) - Purchase vehicle
    ├── BuyItem            (RemoteFunction) - Purchase shop item
    ├── BuyCrypto          (RemoteFunction) - Purchase cryptocurrency
    ├── SellAsset          (RemoteFunction) - Sell owned asset
    │
    ├── InteractPerson     (RemoteFunction) - Interact with a person
    ├── GiveMoney          (RemoteFunction) - Ask family for money
    │
    ├── DoActivity         (RemoteFunction) - Perform an activity
    ├── CommitCrime        (RemoteFunction) - Attempt a crime
    └── Gamble             (RemoteFunction) - Casino gambling
```

## How to Create in Roblox Studio

1. In **Explorer**, right-click `ReplicatedStorage`
2. Select **Insert Object** → **Folder**
3. Name it `LifeRemotes`
4. For each remote listed above:
   - Right-click the `LifeRemotes` folder
   - **Insert Object** → **RemoteEvent** or **RemoteFunction**
   - Rename it to the exact name listed

## Quick Setup Script

Put this in a **Script** in ServerScriptService and run once:

```lua
-- Run this ONCE to create all remotes, then delete this script
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local folder = ReplicatedStorage:FindFirstChild("LifeRemotes")
if not folder then
    folder = Instance.new("Folder")
    folder.Name = "LifeRemotes"
    folder.Parent = ReplicatedStorage
end

local remoteEvents = {
    "RequestAgeUp",
    "PresentEvent", 
    "SubmitChoice",
    "SyncState",
    "SetLifeInfo",
    "QuitJob",
}

local remoteFunctions = {
    "ApplyForJob",
    "DoWork",
    "EnrollEducation",
    "DoFreelance",
    "TrySpecialCareer",
    "BuyProperty",
    "BuyVehicle",
    "BuyItem",
    "BuyCrypto",
    "SellAsset",
    "InteractPerson",
    "GiveMoney",
    "DoActivity",
    "CommitCrime",
    "Gamble",
}

for _, name in ipairs(remoteEvents) do
    if not folder:FindFirstChild(name) then
        local remote = Instance.new("RemoteEvent")
        remote.Name = name
        remote.Parent = folder
    end
end

for _, name in ipairs(remoteFunctions) do
    if not folder:FindFirstChild(name) then
        local remote = Instance.new("RemoteFunction")
        remote.Name = name
        remote.Parent = folder
    end
end

print("✅ All LifeRemotes created!")
```
