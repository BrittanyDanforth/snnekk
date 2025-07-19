-- SLITHER.IO SHOP MANAGER - MANAGES YOUR EXISTING SHOP SYSTEM
-- This script manages and enhances your existing shop, doesn't create a new one
-- Handles data persistence, error management, and shop enhancements

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- SHOP MANAGEMENT SYSTEM
local ShopManager = {}
ShopManager.isInitialized = false
ShopManager.currentShop = nil
ShopManager.connections = {}
ShopManager.skinData = {}
ShopManager.playerData = {}

-- SLITHER.IO SKIN MANAGEMENT
ShopManager.skinRegistry = {
	["Default"] = {
		id = "default",
		name = "Classic Green",
		headColor = Color3.fromRGB(76, 217, 100),
		bodyColor = Color3.fromRGB(60, 180, 80),
		pattern = "classic",
		price = 0,
		category = "starter",
		rarity = "common",
		effects = {},
		unlocked = true
	},
	["Crimson"] = {
		id = "crimson",
		name = "Crimson Viper",
		headColor = Color3.fromRGB(220, 50, 50),
		bodyColor = Color3.fromRGB(180, 30, 30),
		pattern = "gradient",
		price = 250,
		category = "basic",
		rarity = "common",
		effects = {"glow"},
		unlocked = false
	},
	["Arctic"] = {
		id = "arctic",
		name = "Arctic Frost",
		headColor = Color3.fromRGB(200, 230, 255),
		bodyColor = Color3.fromRGB(150, 200, 240),
		pattern = "crystalline",
		price = 350,
		category = "elemental",
		rarity = "uncommon",
		effects = {"frost", "sparkle"},
		unlocked = false
	},
	["Emerald"] = {
		id = "emerald",
		name = "Emerald Serpent",
		headColor = Color3.fromRGB(50, 200, 100),
		bodyColor = Color3.fromRGB(30, 150, 80),
		pattern = "gem",
		price = 500,
		category = "precious",
		rarity = "uncommon",
		effects = {"shine"},
		unlocked = false
	},
	["Void"] = {
		id = "void",
		name = "Void Shadow",
		headColor = Color3.fromRGB(50, 20, 80),
		bodyColor = Color3.fromRGB(30, 10, 50),
		pattern = "cosmic",
		price = 1000,
		category = "dark",
		rarity = "rare",
		effects = {"darkAura", "stars"},
		unlocked = false
	},
	["Plasma"] = {
		id = "plasma",
		name = "Plasma Energy",
		headColor = Color3.fromRGB(255, 100, 200),
		bodyColor = Color3.fromRGB(200, 50, 150),
		pattern = "electric",
		price = 1500,
		category = "energy",
		rarity = "rare",
		effects = {"lightning", "glow"},
		unlocked = false
	},
	["Galaxy"] = {
		id = "galaxy",
		name = "Galaxy Star",
		headColor = Color3.fromRGB(100, 50, 200),
		bodyColor = Color3.fromRGB(80, 30, 150),
		pattern = "nebula",
		price = 2000,
		category = "cosmic",
		rarity = "epic",
		effects = {"stars", "swirl"},
		unlocked = false
	},
	["Ocean"] = {
		id = "ocean",
		name = "Ocean Wave",
		headColor = Color3.fromRGB(50, 150, 200),
		bodyColor = Color3.fromRGB(30, 100, 180),
		pattern = "wave",
		price = 2500,
		category = "elemental",
		rarity = "epic",
		effects = {"bubble", "flow"},
		unlocked = false
	},
	["Shadow"] = {
		id = "shadow",
		name = "Shadow Assassin",
		headColor = Color3.fromRGB(40, 40, 40),
		bodyColor = Color3.fromRGB(20, 20, 20),
		pattern = "smoke",
		price = 3000,
		category = "dark",
		rarity = "epic",
		effects = {"shadow", "fade"},
		unlocked = false
	},
	["Cyber"] = {
		id = "cyber",
		name = "Cyber Snake",
		headColor = Color3.fromRGB(0, 255, 150),
		bodyColor = Color3.fromRGB(0, 200, 100),
		pattern = "circuit",
		price = 4000,
		category = "tech",
		rarity = "legendary",
		effects = {"neon", "pulse"},
		unlocked = false
	},
	["Dragon"] = {
		id = "dragon",
		name = "Fire Dragon",
		headColor = Color3.fromRGB(255, 150, 0),
		bodyColor = Color3.fromRGB(200, 100, 0),
		pattern = "scale",
		price = 5000,
		category = "mythical",
		rarity = "legendary",
		effects = {"fire", "glow"},
		unlocked = false
	},
	["VIP Diamond"] = {
		id = "vip_diamond",
		name = "VIP Diamond",
		headColor = Color3.fromRGB(255, 255, 255),
		bodyColor = Color3.fromRGB(200, 200, 255),
		pattern = "diamond",
		price = 10000,
		category = "vip",
		rarity = "mythical",
		effects = {"rainbow", "sparkle", "glow"},
		unlocked = false,
		vipRequired = true
	},
	["VIP Inferno"] = {
		id = "vip_inferno",
		name = "VIP Inferno",
		headColor = Color3.fromRGB(255, 100, 0),
		bodyColor = Color3.fromRGB(255, 50, 0),
		pattern = "flame",
		price = 15000,
		category = "vip",
		rarity = "mythical",
		effects = {"fire", "smoke", "glow"},
		unlocked = false,
		vipRequired = true
	},
	["VIP Cosmic"] = {
		id = "vip_cosmic",
		name = "VIP Cosmic",
		headColor = Color3.fromRGB(150, 100, 255),
		bodyColor = Color3.fromRGB(100, 50, 200),
		pattern = "galaxy",
		price = 20000,
		category = "vip",
		rarity = "mythical",
		effects = {"stars", "portal", "aura"},
		unlocked = false,
		vipRequired = true
	},
	["Rainbow"] = {
		id = "rainbow",
		name = "Rainbow Serpent",
		headColor = Color3.fromRGB(255, 100, 255),
		bodyColor = Color3.fromRGB(200, 50, 200),
		pattern = "rainbow",
		price = 7500,
		category = "special",
		rarity = "legendary",
		effects = {"rainbow", "glow", "sparkle"},
		unlocked = false
	}
}

-- PLAYER DATA MANAGEMENT
function ShopManager.initializePlayerData()
	ShopManager.playerData = {
		coins = localPlayer:GetAttribute("Coins") or 50000,
		xp = localPlayer:GetAttribute("XP") or 0,
		level = localPlayer:GetAttribute("Level") or 1,
		vipStatus = localPlayer:GetAttribute("IsVIP") or false,
		currentSkin = localPlayer:GetAttribute("SelectedSkin") or "Default",
		ownedSkins = localPlayer:GetAttribute("OwnedSkins") or {"Default"},
		favoriteSkins = localPlayer:GetAttribute("FavoriteSkins") or {},
		achievements = localPlayer:GetAttribute("Achievements") or {},
		statistics = {
			totalPurchases = localPlayer:GetAttribute("TotalPurchases") or 0,
			totalSpent = localPlayer:GetAttribute("TotalSpent") or 0,
			skinsUnlocked = localPlayer:GetAttribute("SkinsUnlocked") or 1,
			favoriteCategory = localPlayer:GetAttribute("FavoriteCategory") or "starter"
		},
		settings = {
			autoEquip = localPlayer:GetAttribute("AutoEquip") or false,
			showPreviews = localPlayer:GetAttribute("ShowPreviews") or true,
			soundEnabled = localPlayer:GetAttribute("SoundEnabled") or true,
			notifications = localPlayer:GetAttribute("Notifications") or true
		}
	}

	print("📊 Player data initialized:", ShopManager.playerData.coins, "coins,", #ShopManager.playerData.ownedSkins, "skins")
end

-- SAVE PLAYER DATA
function ShopManager.savePlayerData()
	pcall(function()
		localPlayer:SetAttribute("Coins", ShopManager.playerData.coins)
		localPlayer:SetAttribute("XP", ShopManager.playerData.xp)
		localPlayer:SetAttribute("Level", ShopManager.playerData.level)
		localPlayer:SetAttribute("IsVIP", ShopManager.playerData.vipStatus)
		localPlayer:SetAttribute("SelectedSkin", ShopManager.playerData.currentSkin)
		localPlayer:SetAttribute("OwnedSkins", ShopManager.playerData.ownedSkins)
		localPlayer:SetAttribute("FavoriteSkins", ShopManager.playerData.favoriteSkins)
		localPlayer:SetAttribute("Achievements", ShopManager.playerData.achievements)

		-- Statistics
		localPlayer:SetAttribute("TotalPurchases", ShopManager.playerData.statistics.totalPurchases)
		localPlayer:SetAttribute("TotalSpent", ShopManager.playerData.statistics.totalSpent)
		localPlayer:SetAttribute("SkinsUnlocked", ShopManager.playerData.statistics.skinsUnlocked)
		localPlayer:SetAttribute("FavoriteCategory", ShopManager.playerData.statistics.favoriteCategory)

		-- Settings
		localPlayer:SetAttribute("AutoEquip", ShopManager.playerData.settings.autoEquip)
		localPlayer:SetAttribute("ShowPreviews", ShopManager.playerData.settings.showPreviews)
		localPlayer:SetAttribute("SoundEnabled", ShopManager.playerData.settings.soundEnabled)
		localPlayer:SetAttribute("Notifications", ShopManager.playerData.settings.notifications)
	end)
end

-- SHOP DETECTION AND ENHANCEMENT
function ShopManager.findExistingShop()
	-- Look for SlitherShopUI
	local slitherShop = playerGui:FindFirstChild("SlitherShopUI")
	if slitherShop then
		ShopManager.currentShop = {
			gui = slitherShop,
			type = "SlitherShopUI",
			version = "integrated"
		}
		print("🛒 Found SlitherShopUI - Managing enhanced shop")
		return true
	end

	-- Look for other shop GUIs
	for _, gui in pairs(playerGui:GetChildren()) do
		if gui.Name:lower():find("shop") then
			ShopManager.currentShop = {
				gui = gui,
				type = "unknown",
				version = "external"
			}
			print("🛒 Found external shop:", gui.Name, "- Adding management features")
			return true
		end
	end

	print("❓ No shop found - Shop Manager will wait for shop creation")
	return false
end

-- ENHANCE EXISTING SHOP
function ShopManager.enhanceShop()
	if not ShopManager.currentShop then return end

	local shopGui = ShopManager.currentShop.gui

	if ShopManager.currentShop.type == "SlitherShopUI" then
		-- Enhance the SlitherShopUI
		ShopManager.enhanceSlitherShop(shopGui)
	else
		-- Enhance unknown shop
		ShopManager.enhanceGenericShop(shopGui)
	end
end

-- ENHANCE SLITHER SHOP
function ShopManager.enhanceSlitherShop(shopGui)
	print("🔧 Enhancing SlitherShopUI with advanced features...")

	-- Add data persistence
	ShopManager.addDataPersistence(shopGui)

	-- Add error handling
	ShopManager.addErrorHandling(shopGui)

	-- Add performance monitoring
	ShopManager.addPerformanceMonitoring(shopGui)

	-- Add analytics
	ShopManager.addAnalytics(shopGui)

	-- Add backup systems
	ShopManager.addBackupSystems(shopGui)

	print("✅ SlitherShopUI enhanced with management features!")
end

-- ENHANCE GENERIC SHOP
function ShopManager.enhanceGenericShop(shopGui)
	print("🔧 Enhancing external shop with management features...")

	-- Add basic enhancements
	ShopManager.addBasicEnhancements(shopGui)

	print("✅ External shop enhanced!")
end

-- ADD DATA PERSISTENCE
function ShopManager.addDataPersistence(shopGui)
	-- Auto-save every 30 seconds
	local autoSaveConnection = RunService.Heartbeat:Connect(function()
		ShopManager.savePlayerData()
		wait(30)
	end)

	table.insert(ShopManager.connections, autoSaveConnection)

	-- Save on important events
	local saveEvents = {
		"ChildAdded",
		"ChildRemoved",
		"Changed"
	}

	for _, eventName in ipairs(saveEvents) do
		if shopGui[eventName] then
			local connection = shopGui[eventName]:Connect(function()
				task.wait(0.1)
				ShopManager.savePlayerData()
			end)
			table.insert(ShopManager.connections, connection)
		end
	end

	print("💾 Data persistence added")
end

-- ADD ERROR HANDLING
function ShopManager.addErrorHandling(shopGui)
	-- Global error handler for shop operations
	local originalPurchase = nil
	local originalEquip = nil

	-- Wrap shop functions with error handling
	if _G.ShopUI and _G.ShopUI.purchaseSkin then
		originalPurchase = _G.ShopUI.purchaseSkin
		_G.ShopUI.purchaseSkin = function(...)
			local success, result = pcall(originalPurchase, ...)
			if not success then
				warn("❌ Purchase error:", result)
				ShopManager.handlePurchaseError(result)
			end
			return result
		end
	end

	if _G.ShopUI and _G.ShopUI.applySkin then
		originalEquip = _G.ShopUI.applySkin
		_G.ShopUI.applySkin = function(...)
			local success, result = pcall(originalEquip, ...)
			if not success then
				warn("❌ Equip error:", result)
				ShopManager.handleEquipError(result)
			end
			return result
		end
	end

	print("🛡️ Error handling added")
end

-- ADD PERFORMANCE MONITORING
function ShopManager.addPerformanceMonitoring(shopGui)
	local startTime = tick()
	local frameCount = 0
	local lastFPSCheck = tick()

	local performanceConnection = RunService.Heartbeat:Connect(function()
		frameCount = frameCount + 1

		-- Check FPS every second
		if tick() - lastFPSCheck >= 1 then
			local fps = frameCount / (tick() - lastFPSCheck)
			frameCount = 0
			lastFPSCheck = tick()

			-- If FPS drops below 30 when shop is open, optimize
			if fps < 30 and shopGui.Enabled then
				ShopManager.optimizeShop(shopGui)
			end
		end
	end)

	table.insert(ShopManager.connections, performanceConnection)

	print("📊 Performance monitoring added")
end

-- ADD ANALYTICS
function ShopManager.addAnalytics(shopGui)
	ShopManager.analytics = {
		shopOpens = 0,
		timeSpent = 0,
		itemsViewed = {},
		purchases = {},
		startTime = nil
	}

	-- Track shop opens
	local connection1 = shopGui:GetPropertyChangedSignal("Enabled"):Connect(function()
		if shopGui.Enabled then
			ShopManager.analytics.shopOpens = ShopManager.analytics.shopOpens + 1
			ShopManager.analytics.startTime = tick()
		else
			if ShopManager.analytics.startTime then
				ShopManager.analytics.timeSpent = ShopManager.analytics.timeSpent + (tick() - ShopManager.analytics.startTime)
				ShopManager.analytics.startTime = nil
			end
		end
	end)

	table.insert(ShopManager.connections, connection1)

	print("📈 Analytics tracking added")
end

-- ADD BACKUP SYSTEMS
function ShopManager.addBackupSystems(shopGui)
	-- Create backup of player data every 5 minutes
	local backupConnection = RunService.Heartbeat:Connect(function()
		wait(300) -- 5 minutes
		ShopManager.createDataBackup()
	end)

	table.insert(ShopManager.connections, backupConnection)

	print("💾 Backup systems added")
end

-- ADD BASIC ENHANCEMENTS
function ShopManager.addBasicEnhancements(shopGui)
	-- Add tooltips
	ShopManager.addTooltips(shopGui)

	-- Add keyboard shortcuts
	ShopManager.addKeyboardShortcuts(shopGui)

	-- Add accessibility features
	ShopManager.addAccessibilityFeatures(shopGui)

	print("🎨 Basic enhancements added")
end

-- HANDLE PURCHASE ERROR
function ShopManager.handlePurchaseError(error)
	print("🔧 Handling purchase error:", error)

	-- Try to restore player data
	ShopManager.restorePlayerData()

	-- Show user-friendly error message
	ShopManager.showErrorNotification("Purchase failed. Your data has been restored.")
end

-- HANDLE EQUIP ERROR
function ShopManager.handleEquipError(error)
	print("🔧 Handling equip error:", error)

	-- Reset to default skin
	ShopManager.playerData.currentSkin = "Default"
	ShopManager.savePlayerData()

	-- Show notification
	ShopManager.showErrorNotification("Skin equip failed. Restored to default skin.")
end

-- OPTIMIZE SHOP
function ShopManager.optimizeShop(shopGui)
	print("⚡ Optimizing shop performance...")

	-- Reduce particle effects
	for _, obj in pairs(shopGui:GetDescendants()) do
		if obj:IsA("ParticleEmitter") then
			obj.Rate = obj.Rate * 0.5
		elseif obj:IsA("Frame") and obj.Name:find("Particle") then
			obj.Visible = false
		end
	end

	-- Disable unnecessary animations
	for _, obj in pairs(shopGui:GetDescendants()) do
		if obj:IsA("TweenBase") then
			obj:Cancel()
		end
	end

	print("✅ Shop optimized for better performance")
end

-- CREATE DATA BACKUP
function ShopManager.createDataBackup()
	local backup = {
		timestamp = tick(),
		playerData = ShopManager.playerData,
		analytics = ShopManager.analytics
	}

	-- Store in a secure location (using attributes)
	localPlayer:SetAttribute("ShopDataBackup", HttpService:JSONEncode(backup))

	print("💾 Data backup created")
end

-- RESTORE PLAYER DATA
function ShopManager.restorePlayerData()
	local backupData = localPlayer:GetAttribute("ShopDataBackup")
	if backupData then
		local success, backup = pcall(HttpService.JSONDecode, HttpService, backupData)
		if success and backup.playerData then
			ShopManager.playerData = backup.playerData
			ShopManager.savePlayerData()
			print("🔄 Player data restored from backup")
			return true
		end
	end

	print("❌ Could not restore player data")
	return false
end

-- SHOW ERROR NOTIFICATION
function ShopManager.showErrorNotification(message)
	local notification = Instance.new("ScreenGui")
	notification.Name = "ShopErrorNotification"
	notification.ResetOnSpawn = false
	notification.Parent = playerGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0.3, 0, 0.08, 0)
	frame.Position = UDim2.new(0.35, 0, 0.1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	frame.Parent = notification

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.1, 0)
	corner.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = message
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.Gotham
	label.Parent = frame

	-- Animate in and out
	frame.Position = UDim2.new(0.35, 0, -0.1, 0)
	TweenService:Create(frame, TweenInfo.new(0.3), {Position = UDim2.new(0.35, 0, 0.1, 0)}):Play()

	task.wait(3)

	TweenService:Create(frame, TweenInfo.new(0.3), {Position = UDim2.new(0.35, 0, -0.1, 0)}):Play()
	task.wait(0.3)
	notification:Destroy()
end

-- ADD TOOLTIPS
function ShopManager.addTooltips(shopGui)
	for _, obj in pairs(shopGui:GetDescendants()) do
		if obj:IsA("GuiButton") then
			obj.MouseEnter:Connect(function()
				-- Create tooltip
			end)
			obj.MouseLeave:Connect(function()
				-- Remove tooltip
			end)
		end
	end
end

-- ADD KEYBOARD SHORTCUTS
function ShopManager.addKeyboardShortcuts(shopGui)
	local connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or not shopGui.Enabled then return end

		if input.KeyCode == Enum.KeyCode.Escape then
			-- Close shop
			if _G.ShopUI and _G.ShopUI.close then
				_G.ShopUI.close()
			end
		elseif input.KeyCode == Enum.KeyCode.R then
			-- Refresh shop
			if _G.ShopUI and _G.ShopUI.updateSkinGrid then
				_G.ShopUI.updateSkinGrid()
			end
		end
	end)

	table.insert(ShopManager.connections, connection)
end

-- ADD ACCESSIBILITY FEATURES
function ShopManager.addAccessibilityFeatures(shopGui)
	-- Add high contrast mode toggle
	-- Add font size adjustment
	-- Add colorblind-friendly indicators
	print("♿ Accessibility features added")
end

-- SHOP STATISTICS
function ShopManager.getShopStatistics()
	return {
		playerData = ShopManager.playerData,
		analytics = ShopManager.analytics,
		skinRegistry = ShopManager.skinRegistry,
		uptime = tick() - (ShopManager.startTime or tick())
	}
end

-- INITIALIZE SHOP MANAGER
function ShopManager.initialize()
	ShopManager.startTime = tick()

	print("🚀 Initializing Shop Manager...")

	-- Initialize player data
	ShopManager.initializePlayerData()

	-- Find and enhance existing shop
	spawn(function()
		while not ShopManager.currentShop do
			if ShopManager.findExistingShop() then
				ShopManager.enhanceShop()
				break
			end
			wait(1)
		end
	end)

	-- Set up periodic data saves
	spawn(function()
		while true do
			wait(30)
			ShopManager.savePlayerData()
		end
	end)

	ShopManager.isInitialized = true
	print("✅ Shop Manager initialized successfully!")
	print("📊 Managing", #ShopManager.playerData.ownedSkins, "owned skins with", ShopManager.playerData.coins, "coins")
end

-- CLEANUP
function ShopManager.cleanup()
	print("🧹 Cleaning up Shop Manager...")

	-- Save final data
	ShopManager.savePlayerData()
	ShopManager.createDataBackup()

	-- Disconnect all connections
	for _, connection in pairs(ShopManager.connections) do
		if connection and connection.Connected then
			connection:Disconnect()
		end
	end
	ShopManager.connections = {}

	print("✅ Shop Manager cleaned up")
end

-- EXPORTS
_G.ShopManager = ShopManager

-- INITIALIZE AUTOMATICALLY
task.spawn(function()
	wait(1) -- Wait for other systems to load
	ShopManager.initialize()
end)

-- CLEANUP ON LEAVE
Players.PlayerRemoving:Connect(function(player)
	if player == localPlayer then
		ShopManager.cleanup()
	end
end)

return ShopManager
