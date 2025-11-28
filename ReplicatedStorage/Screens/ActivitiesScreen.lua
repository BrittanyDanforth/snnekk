-- ReplicatedStorage/Screens/ActivitiesScreen.lua
-- Activities Screen module used by LifeClient nav button.
-- Place this ModuleScript under ReplicatedStorage/Screens so both server + client can require it.

local ActivitiesScreen = {}

ActivitiesScreen.Buttons = {
	{ key = "relationships", label = "Relationships", emoji = "❤️" },
	{ key = "work",          label = "Find Work",    emoji = "💼" },
	{ key = "education",     label = "Education",    emoji = "🎓" },
	{ key = "crime",         label = "Commit Crime", emoji = "🗡️" },
	{ key = "meditation",    label = "Meditate",     emoji = "🧘" },
	{ key = "gym",           label = "Go to the Gym",emoji = "🏋️" },
}

local Colors = {
	CardWhite     = Color3.fromRGB(255, 255, 255),
	TextDark      = Color3.fromRGB(31, 41, 55),
	TextMuted     = Color3.fromRGB(107, 114, 128),
	BitLifeBlue   = Color3.fromRGB(37, 99, 235),
	BitLifeBlueHi = Color3.fromRGB(59, 130, 246),
	ListBg        = Color3.fromRGB(248, 250, 252),
	Border        = Color3.fromRGB(203, 213, 225),
}

local TITLE_FONT = Enum.Font.FredokaOne
local BODY_FONT  = Enum.Font.Ubuntu
local CHIP_FONT  = Enum.Font.Roboto

local function createUICorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
	return c
end

local function createUIStroke(parent, thickness, color)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = thickness
	stroke.Color = color
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	return stroke
end

--[=[
	@param parent Instance - GuiObject to parent the Activities screen under.
	@param options table? { title: string?, subtitle: string?, callbacks: { [key]: function } }
	@return Frame screenFrame, table refs
]=]
function ActivitiesScreen.mount(parent, options)
	options = options or {}
	local callbacks = options.callbacks or {}
	local titleText = options.title or "Pick an activity."
	local subtitleText = options.subtitle or "Tap something to pass the year."

	local screen = Instance.new("Frame")
	screen.Name = "ActivitiesScreen"
	screen.BackgroundTransparency = 1
	screen.Size = UDim2.fromScale(1, 1)
	screen.Parent = parent

	local card = Instance.new("Frame")
	card.Name = "Card"
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.fromScale(0.5, 0.5)
	card.Size = UDim2.new(0.9, 0, 0.88, 0)
	card.BackgroundColor3 = Colors.CardWhite
	card.Parent = screen
	createUICorner(card, 26)
	createUIStroke(card, 2, Colors.Border)

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 24)
	pad.PaddingBottom = UDim.new(0, 24)
	pad.PaddingLeft = UDim.new(0, 24)
	pad.PaddingRight = UDim.new(0, 24)
	pad.Parent = card

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	layout.VerticalAlignment = Enum.VerticalAlignment.Top
	layout.Padding = UDim.new(0, 20)
	layout.Parent = card

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, 0, 0, 34)
	title.Font = TITLE_FONT
	title.TextSize = 30
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = Colors.TextDark
	title.Text = titleText
	title.Parent = card

	local subtitle = Instance.new("TextLabel")
	subtitle.BackgroundTransparency = 1
	subtitle.Size = UDim2.new(1, 0, 0, 24)
	subtitle.Font = BODY_FONT
	subtitle.TextSize = 18
	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	subtitle.TextColor3 = Colors.TextMuted
	subtitle.Text = subtitleText
	subtitle.Parent = card

	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "ActivitiesList"
	scroll.BackgroundTransparency = 1
	scroll.Size = UDim2.new(1, 0, 1, -120)
	scroll.ScrollBarThickness = 6
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Parent = card

	local scrollLayout = Instance.new("UIListLayout")
	scrollLayout.FillDirection = Enum.FillDirection.Vertical
	scrollLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	scrollLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	scrollLayout.Padding = UDim.new(0, 12)
	scrollLayout.Parent = scroll

	local buttons = {}

	for _, info in ipairs(ActivitiesScreen.Buttons) do
		local button = Instance.new("TextButton")
		button.Name = info.key
		button.BackgroundColor3 = Colors.ListBg
		button.AutoButtonColor = false
		button.Size = UDim2.new(1, 0, 0, 70)
		button.Font = CHIP_FONT
		button.TextSize = 20
		button.TextColor3 = Colors.TextDark
		button.TextXAlignment = Enum.TextXAlignment.Left
		button.Text = string.format("%s  %s", info.emoji, info.label)
		button.Parent = scroll
		createUICorner(button, 20)
		createUIStroke(button, 1, Colors.Border)

		local arrow = Instance.new("TextLabel")
		arrow.BackgroundTransparency = 1
		arrow.AnchorPoint = Vector2.new(1, 0.5)
		arrow.Position = UDim2.new(1, -18, 0.5, 0)
		arrow.Size = UDim2.new(0, 20, 0, 20)
		arrow.Font = BODY_FONT
		arrow.TextSize = 20
		arrow.TextColor3 = Colors.TextMuted
		arrow.Text = "›"
		arrow.Parent = button

		button.MouseEnter:Connect(function()
			button.BackgroundColor3 = Colors.BitLifeBlue
			button.TextColor3 = Color3.new(1, 1, 1)
			arrow.TextColor3 = Color3.new(1, 1, 1)
		end)

		button.MouseLeave:Connect(function()
			button.BackgroundColor3 = Colors.ListBg
			button.TextColor3 = Colors.TextDark
			arrow.TextColor3 = Colors.TextMuted
		end)

		button.MouseButton1Click:Connect(function()
			local handler = callbacks[info.key]
			if handler then
				handler(info)
			end
		end)

		buttons[info.key] = button
	end

	return screen, {
		buttons = buttons,
		destroy = function()
			screen:Destroy()
		end,
	}
end

return ActivitiesScreen
