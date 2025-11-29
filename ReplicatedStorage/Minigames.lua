-- Minigames.lua
-- Interactive minigames for deep story events

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Minigames = {}
Minigames.__index = Minigames

-- Premium Colors
local C = {
	Navy = Color3.fromRGB(30, 58, 138),
	NavyDark = Color3.fromRGB(23, 37, 84),
	Blue = Color3.fromRGB(37, 99, 235),
	BlueDark = Color3.fromRGB(29, 78, 216),
	BluePale = Color3.fromRGB(219, 234, 254),
	Green = Color3.fromRGB(34, 197, 94),
	GreenDark = Color3.fromRGB(22, 163, 74),
	GreenPale = Color3.fromRGB(220, 252, 231),
	Red = Color3.fromRGB(239, 68, 68),
	RedDark = Color3.fromRGB(220, 38, 38),
	RedPale = Color3.fromRGB(254, 226, 226),
	Amber = Color3.fromRGB(245, 158, 11),
	AmberDark = Color3.fromRGB(217, 119, 6),
	AmberPale = Color3.fromRGB(254, 243, 199),
	Purple = Color3.fromRGB(147, 51, 234),
	PurplePale = Color3.fromRGB(243, 232, 255),
	Gold = Color3.fromRGB(234, 179, 8),
	White = Color3.fromRGB(255, 255, 255),
	Gray100 = Color3.fromRGB(243, 244, 246),
	Gray200 = Color3.fromRGB(229, 231, 235),
	Gray300 = Color3.fromRGB(209, 213, 219),
	Gray400 = Color3.fromRGB(156, 163, 175),
	Gray500 = Color3.fromRGB(107, 114, 128),
	Gray600 = Color3.fromRGB(75, 85, 99),
	Gray700 = Color3.fromRGB(55, 65, 81),
	Gray800 = Color3.fromRGB(31, 41, 55),
	Gray900 = Color3.fromRGB(17, 24, 39),
	Black = Color3.fromRGB(0, 0, 0),
}

local F = { Title = Enum.Font.GothamBold, Body = Enum.Font.Gotham, Medium = Enum.Font.GothamMedium, Button = Enum.Font.GothamBold }

-- Helpers
local function corner(p, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r); c.Parent = p; return c end
local function pill(p) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0.5, 0); c.Parent = p; return c end
local function stroke(p, t, tr, col) local s = Instance.new("UIStroke"); s.Thickness = t; s.Transparency = tr or 0; s.Color = col or C.White; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = p; return s end
local function pad(p, l, r, t, b) local pd = Instance.new("UIPadding"); pd.PaddingLeft = UDim.new(0, l or 0); pd.PaddingRight = UDim.new(0, r or 0); pd.PaddingTop = UDim.new(0, t or 0); pd.PaddingBottom = UDim.new(0, b or 0); pd.Parent = p; return pd end
local function tween(o, i, p) local t = TweenService:Create(o, i, p); t:Play(); return t end

function Minigames.new(screenGui)
	local self = setmetatable({}, Minigames)
	self.screenGui = screenGui
	self.activeGame = nil
	self.callback = nil
	self:createDebateGame()
	self:createHeistGame()
	self:createGetawayGame()
	self:createQuickTimeGame()
	return self
end

-- ═══════════════════════════════════════════════════════════════
-- DEBATE MINIGAME (Presidential Path)
-- Answer questions quickly to win the debate
-- ═══════════════════════════════════════════════════════════════

function Minigames:createDebateGame()
	self.debateOverlay = Instance.new("Frame")
	self.debateOverlay.Size = UDim2.fromScale(1, 1)
	self.debateOverlay.BackgroundColor3 = C.Black
	self.debateOverlay.BackgroundTransparency = 0.3
	self.debateOverlay.Visible = false
	self.debateOverlay.ZIndex = 200
	self.debateOverlay.Parent = self.screenGui
	
	self.debateCard = Instance.new("Frame")
	self.debateCard.Size = UDim2.new(0.95, 0, 0.85, 0)
	self.debateCard.AnchorPoint = Vector2.new(0.5, 0.5)
	self.debateCard.Position = UDim2.fromScale(0.5, 0.5)
	self.debateCard.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
	self.debateCard.ZIndex = 201
	self.debateCard.Parent = self.debateOverlay
	corner(self.debateCard, 20)
	
	-- Stage background
	local stage = Instance.new("Frame")
	stage.Size = UDim2.new(1, 0, 0, 80)
	stage.BackgroundColor3 = C.Navy
	stage.ZIndex = 202
	stage.Parent = self.debateCard
	corner(stage, 20)
	
	local stageFix = Instance.new("Frame")
	stageFix.Size = UDim2.new(1, 0, 0, 40)
	stageFix.Position = UDim2.new(0, 0, 0, 45)
	stageFix.BackgroundColor3 = C.Navy
	stageFix.ZIndex = 202
	stageFix.Parent = stage
	
	local stageTitle = Instance.new("TextLabel")
	stageTitle.Size = UDim2.new(1, 0, 1, 0)
	stageTitle.BackgroundTransparency = 1
	stageTitle.Font = F.Title
	stageTitle.TextSize = 24
	stageTitle.TextColor3 = C.White
	stageTitle.Text = "🎤 PRESIDENTIAL DEBATE"
	stageTitle.ZIndex = 203
	stageTitle.Parent = stage
	
	-- Score display
	self.debateScoreFrame = Instance.new("Frame")
	self.debateScoreFrame.Size = UDim2.new(0.9, 0, 0, 50)
	self.debateScoreFrame.AnchorPoint = Vector2.new(0.5, 0)
	self.debateScoreFrame.Position = UDim2.new(0.5, 0, 0, 90)
	self.debateScoreFrame.BackgroundTransparency = 1
	self.debateScoreFrame.ZIndex = 202
	self.debateScoreFrame.Parent = self.debateCard
	
	-- Your score
	local yourScoreBox = Instance.new("Frame")
	yourScoreBox.Size = UDim2.new(0.45, 0, 1, 0)
	yourScoreBox.BackgroundColor3 = C.Green
	yourScoreBox.ZIndex = 203
	yourScoreBox.Parent = self.debateScoreFrame
	corner(yourScoreBox, 12)
	
	local yourLabel = Instance.new("TextLabel")
	yourLabel.Size = UDim2.new(1, 0, 0.5, 0)
	yourLabel.BackgroundTransparency = 1
	yourLabel.Font = F.Medium
	yourLabel.TextSize = 11
	yourLabel.TextColor3 = C.White
	yourLabel.Text = "YOU"
	yourLabel.ZIndex = 204
	yourLabel.Parent = yourScoreBox
	
	self.yourScoreLabel = Instance.new("TextLabel")
	self.yourScoreLabel.Size = UDim2.new(1, 0, 0.5, 0)
	self.yourScoreLabel.Position = UDim2.new(0, 0, 0.5, 0)
	self.yourScoreLabel.BackgroundTransparency = 1
	self.yourScoreLabel.Font = F.Title
	self.yourScoreLabel.TextSize = 20
	self.yourScoreLabel.TextColor3 = C.White
	self.yourScoreLabel.Text = "0"
	self.yourScoreLabel.ZIndex = 204
	self.yourScoreLabel.Parent = yourScoreBox
	
	-- Opponent score
	local oppScoreBox = Instance.new("Frame")
	oppScoreBox.Size = UDim2.new(0.45, 0, 1, 0)
	oppScoreBox.Position = UDim2.new(0.55, 0, 0, 0)
	oppScoreBox.BackgroundColor3 = C.Red
	oppScoreBox.ZIndex = 203
	oppScoreBox.Parent = self.debateScoreFrame
	corner(oppScoreBox, 12)
	
	local oppLabel = Instance.new("TextLabel")
	oppLabel.Size = UDim2.new(1, 0, 0.5, 0)
	oppLabel.BackgroundTransparency = 1
	oppLabel.Font = F.Medium
	oppLabel.TextSize = 11
	oppLabel.TextColor3 = C.White
	oppLabel.Text = "OPPONENT"
	oppLabel.ZIndex = 204
	oppLabel.Parent = oppScoreBox
	
	self.oppScoreLabel = Instance.new("TextLabel")
	self.oppScoreLabel.Size = UDim2.new(1, 0, 0.5, 0)
	self.oppScoreLabel.Position = UDim2.new(0, 0, 0.5, 0)
	self.oppScoreLabel.BackgroundTransparency = 1
	self.oppScoreLabel.Font = F.Title
	self.oppScoreLabel.TextSize = 20
	self.oppScoreLabel.TextColor3 = C.White
	self.oppScoreLabel.Text = "0"
	self.oppScoreLabel.ZIndex = 204
	self.oppScoreLabel.Parent = oppScoreBox
	
	-- Timer bar
	self.debateTimerBg = Instance.new("Frame")
	self.debateTimerBg.Size = UDim2.new(0.9, 0, 0, 12)
	self.debateTimerBg.AnchorPoint = Vector2.new(0.5, 0)
	self.debateTimerBg.Position = UDim2.new(0.5, 0, 0, 150)
	self.debateTimerBg.BackgroundColor3 = C.Gray700
	self.debateTimerBg.ZIndex = 202
	self.debateTimerBg.Parent = self.debateCard
	pill(self.debateTimerBg)
	
	self.debateTimerFill = Instance.new("Frame")
	self.debateTimerFill.Size = UDim2.new(1, 0, 1, 0)
	self.debateTimerFill.BackgroundColor3 = C.Amber
	self.debateTimerFill.ZIndex = 203
	self.debateTimerFill.Parent = self.debateTimerBg
	pill(self.debateTimerFill)
	
	-- Question display
	self.debateQuestion = Instance.new("TextLabel")
	self.debateQuestion.Size = UDim2.new(0.9, 0, 0, 80)
	self.debateQuestion.AnchorPoint = Vector2.new(0.5, 0)
	self.debateQuestion.Position = UDim2.new(0.5, 0, 0, 175)
	self.debateQuestion.BackgroundColor3 = C.Gray800
	self.debateQuestion.Font = F.Medium
	self.debateQuestion.TextSize = 16
	self.debateQuestion.TextColor3 = C.White
	self.debateQuestion.TextWrapped = true
	self.debateQuestion.Text = "Question loading..."
	self.debateQuestion.ZIndex = 202
	self.debateQuestion.Parent = self.debateCard
	corner(self.debateQuestion, 12)
	
	-- Answer buttons container
	self.debateAnswers = Instance.new("Frame")
	self.debateAnswers.Size = UDim2.new(0.9, 0, 0, 200)
	self.debateAnswers.AnchorPoint = Vector2.new(0.5, 0)
	self.debateAnswers.Position = UDim2.new(0.5, 0, 0, 270)
	self.debateAnswers.BackgroundTransparency = 1
	self.debateAnswers.ZIndex = 202
	self.debateAnswers.Parent = self.debateCard
	
	local answerLayout = Instance.new("UIListLayout")
	answerLayout.Padding = UDim.new(0, 10)
	answerLayout.Parent = self.debateAnswers
	
	self.debateAnswerBtns = {}
	for i = 1, 4 do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 44)
		btn.BackgroundColor3 = C.Blue
		btn.Font = F.Button
		btn.TextSize = 14
		btn.TextColor3 = C.White
		btn.Text = "Answer " .. i
		btn.TextWrapped = true
		btn.AutoButtonColor = false
		btn.LayoutOrder = i
		btn.ZIndex = 203
		btn.Parent = self.debateAnswers
		corner(btn, 12)
		
		self.debateAnswerBtns[i] = btn
	end
	
	-- Debate questions database
	self.debateQuestions = {
		{
			q = "The moderator asks: What is your plan to address climate change?",
			answers = {
				{ text = "Invest in renewable energy and green jobs", correct = true },
				{ text = "Climate change is a hoax", correct = false },
				{ text = "Let the market figure it out", correct = false },
				{ text = "I don't understand the question", correct = false },
			}
		},
		{
			q = "A citizen asks: How will you make healthcare more affordable?",
			answers = {
				{ text = "Expand coverage and negotiate drug prices", correct = true },
				{ text = "Eliminate all healthcare programs", correct = false },
				{ text = "Healthcare is not a government issue", correct = false },
				{ text = "I'll think about it later", correct = false },
			}
		},
		{
			q = "The moderator asks: How will you handle the economy?",
			answers = {
				{ text = "Invest in infrastructure and education", correct = true },
				{ text = "Cut all government spending immediately", correct = false },
				{ text = "Print more money", correct = false },
				{ text = "Economy? What economy?", correct = false },
			}
		},
		{
			q = "On foreign policy: How will you handle international relations?",
			answers = {
				{ text = "Strengthen alliances and diplomacy first", correct = true },
				{ text = "Isolate America from the world", correct = false },
				{ text = "Declare war on everyone", correct = false },
				{ text = "Foreign policy isn't important", correct = false },
			}
		},
		{
			q = "On education: What's your plan for improving schools?",
			answers = {
				{ text = "Increase funding and teacher pay", correct = true },
				{ text = "Close all public schools", correct = false },
				{ text = "Kids don't need education", correct = false },
				{ text = "Let parents figure it out", correct = false },
			}
		},
		{
			q = "A voter asks: How will you reduce crime?",
			answers = {
				{ text = "Community programs and smart policing", correct = true },
				{ text = "Abolish all laws", correct = false },
				{ text = "Lock everyone up forever", correct = false },
				{ text = "Crime is fine actually", correct = false },
			}
		},
		{
			q = "The moderator asks: What about the national debt?",
			answers = {
				{ text = "Responsible budgeting and growth", correct = true },
				{ text = "Just ignore it", correct = false },
				{ text = "Borrow more money", correct = false },
				{ text = "What's a debt?", correct = false },
			}
		},
		{
			q = "On immigration: What is your policy?",
			answers = {
				{ text = "Comprehensive reform with a path to citizenship", correct = true },
				{ text = "Deport everyone", correct = false },
				{ text = "Open borders with no rules", correct = false },
				{ text = "Build a moat with alligators", correct = false },
			}
		},
	}
end

function Minigames:startDebate(callback)
	self.callback = callback
	self.debateOverlay.Visible = true
	self.activeGame = "debate"
	
	self.yourScore = 0
	self.oppScore = 0
	self.currentQuestion = 0
	self.totalQuestions = 5
	
	self.yourScoreLabel.Text = "0"
	self.oppScoreLabel.Text = "0"
	
	-- Shuffle and pick questions
	self.selectedQuestions = {}
	local shuffled = {}
	for i, q in ipairs(self.debateQuestions) do
		table.insert(shuffled, q)
	end
	for i = #shuffled, 2, -1 do
		local j = math.random(i)
		shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
	end
	for i = 1, math.min(self.totalQuestions, #shuffled) do
		table.insert(self.selectedQuestions, shuffled[i])
	end
	
	self:showNextDebateQuestion()
end

function Minigames:showNextDebateQuestion()
	self.currentQuestion = self.currentQuestion + 1
	
	if self.currentQuestion > #self.selectedQuestions then
		self:endDebate()
		return
	end
	
	local q = self.selectedQuestions[self.currentQuestion]
	self.debateQuestion.Text = "Q" .. self.currentQuestion .. "/" .. #self.selectedQuestions .. ": " .. q.q
	
	-- Shuffle answers
	local shuffledAnswers = {}
	for i, a in ipairs(q.answers) do
		table.insert(shuffledAnswers, a)
	end
	for i = #shuffledAnswers, 2, -1 do
		local j = math.random(i)
		shuffledAnswers[i], shuffledAnswers[j] = shuffledAnswers[j], shuffledAnswers[i]
	end
	
	-- Set up buttons
	for i, btn in ipairs(self.debateAnswerBtns) do
		if shuffledAnswers[i] then
			btn.Visible = true
			btn.Text = shuffledAnswers[i].text
			btn.BackgroundColor3 = C.Blue
			
			local answer = shuffledAnswers[i]
			btn.MouseButton1Click:Connect(function()
				self:handleDebateAnswer(answer.correct)
			end)
		else
			btn.Visible = false
		end
	end
	
	-- Timer animation
	self.debateTimerFill.Size = UDim2.new(1, 0, 1, 0)
	local timerTween = tween(self.debateTimerFill, TweenInfo.new(8, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 1, 0) })
	
	self.debateTimerConnection = task.delay(8, function()
		if self.activeGame == "debate" then
			self:handleDebateAnswer(false) -- Timeout = wrong
		end
	end)
end

function Minigames:handleDebateAnswer(correct)
	if self.debateTimerConnection then
		task.cancel(self.debateTimerConnection)
		self.debateTimerConnection = nil
	end
	
	if correct then
		self.yourScore = self.yourScore + 1
		self.yourScoreLabel.Text = tostring(self.yourScore)
		-- Flash green
		for _, btn in ipairs(self.debateAnswerBtns) do
			if btn.Visible then
				btn.BackgroundColor3 = C.Green
			end
		end
	else
		self.oppScore = self.oppScore + 1
		self.oppScoreLabel.Text = tostring(self.oppScore)
		-- Flash red
		for _, btn in ipairs(self.debateAnswerBtns) do
			if btn.Visible then
				btn.BackgroundColor3 = C.Red
			end
		end
	end
	
	task.delay(0.8, function()
		self:showNextDebateQuestion()
	end)
end

function Minigames:endDebate()
	self.activeGame = nil
	local won = self.yourScore > self.oppScore
	
	self.debateOverlay.Visible = false
	
	if self.callback then
		self.callback(won, { yourScore = self.yourScore, oppScore = self.oppScore })
		self.callback = nil
	end
end

-- ═══════════════════════════════════════════════════════════════
-- HEIST MINIGAME (Criminal Path)
-- Crack the safe by finding the right combination
-- ═══════════════════════════════════════════════════════════════

function Minigames:createHeistGame()
	self.heistOverlay = Instance.new("Frame")
	self.heistOverlay.Size = UDim2.fromScale(1, 1)
	self.heistOverlay.BackgroundColor3 = C.Black
	self.heistOverlay.BackgroundTransparency = 0.2
	self.heistOverlay.Visible = false
	self.heistOverlay.ZIndex = 200
	self.heistOverlay.Parent = self.screenGui
	
	self.heistCard = Instance.new("Frame")
	self.heistCard.Size = UDim2.new(0.95, 0, 0, 500)
	self.heistCard.AnchorPoint = Vector2.new(0.5, 0.5)
	self.heistCard.Position = UDim2.fromScale(0.5, 0.5)
	self.heistCard.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	self.heistCard.ZIndex = 201
	self.heistCard.Parent = self.heistOverlay
	corner(self.heistCard, 20)
	
	-- Title
	local heistTitle = Instance.new("TextLabel")
	heistTitle.Size = UDim2.new(1, 0, 0, 60)
	heistTitle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	heistTitle.Font = F.Title
	heistTitle.TextSize = 24
	heistTitle.TextColor3 = C.White
	heistTitle.Text = "🔓 CRACK THE SAFE"
	heistTitle.ZIndex = 202
	heistTitle.Parent = self.heistCard
	corner(heistTitle, 20)
	
	local titleFix = Instance.new("Frame")
	titleFix.Size = UDim2.new(1, 0, 0, 30)
	titleFix.Position = UDim2.new(0, 0, 0, 35)
	titleFix.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	titleFix.ZIndex = 202
	titleFix.Parent = heistTitle
	
	-- Instructions
	self.heistInstructions = Instance.new("TextLabel")
	self.heistInstructions.Size = UDim2.new(0.9, 0, 0, 40)
	self.heistInstructions.AnchorPoint = Vector2.new(0.5, 0)
	self.heistInstructions.Position = UDim2.new(0.5, 0, 0, 70)
	self.heistInstructions.BackgroundTransparency = 1
	self.heistInstructions.Font = F.Body
	self.heistInstructions.TextSize = 14
	self.heistInstructions.TextColor3 = C.Gray300
	self.heistInstructions.TextWrapped = true
	self.heistInstructions.Text = "Find the 4-digit code! Green = correct digit & position. Yellow = correct digit, wrong position."
	self.heistInstructions.ZIndex = 202
	self.heistInstructions.Parent = self.heistCard
	
	-- Attempts remaining
	self.heistAttempts = Instance.new("TextLabel")
	self.heistAttempts.Size = UDim2.new(0.9, 0, 0, 30)
	self.heistAttempts.AnchorPoint = Vector2.new(0.5, 0)
	self.heistAttempts.Position = UDim2.new(0.5, 0, 0, 110)
	self.heistAttempts.BackgroundTransparency = 1
	self.heistAttempts.Font = F.Button
	self.heistAttempts.TextSize = 16
	self.heistAttempts.TextColor3 = C.Amber
	self.heistAttempts.Text = "Attempts: 6 remaining"
	self.heistAttempts.ZIndex = 202
	self.heistAttempts.Parent = self.heistCard
	
	-- Code input display
	self.heistCodeDisplay = Instance.new("Frame")
	self.heistCodeDisplay.Size = UDim2.new(0.8, 0, 0, 60)
	self.heistCodeDisplay.AnchorPoint = Vector2.new(0.5, 0)
	self.heistCodeDisplay.Position = UDim2.new(0.5, 0, 0, 150)
	self.heistCodeDisplay.BackgroundColor3 = C.Gray800
	self.heistCodeDisplay.ZIndex = 202
	self.heistCodeDisplay.Parent = self.heistCard
	corner(self.heistCodeDisplay, 12)
	
	local codeLayout = Instance.new("UIListLayout")
	codeLayout.FillDirection = Enum.FillDirection.Horizontal
	codeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	codeLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	codeLayout.Padding = UDim.new(0, 8)
	codeLayout.Parent = self.heistCodeDisplay
	
	self.heistDigitLabels = {}
	for i = 1, 4 do
		local digitFrame = Instance.new("Frame")
		digitFrame.Size = UDim2.new(0, 50, 0, 50)
		digitFrame.BackgroundColor3 = C.Gray700
		digitFrame.LayoutOrder = i
		digitFrame.ZIndex = 203
		digitFrame.Parent = self.heistCodeDisplay
		corner(digitFrame, 8)
		
		local digitLabel = Instance.new("TextLabel")
		digitLabel.Size = UDim2.fromScale(1, 1)
		digitLabel.BackgroundTransparency = 1
		digitLabel.Font = F.Title
		digitLabel.TextSize = 28
		digitLabel.TextColor3 = C.White
		digitLabel.Text = "_"
		digitLabel.ZIndex = 204
		digitLabel.Parent = digitFrame
		
		self.heistDigitLabels[i] = { frame = digitFrame, label = digitLabel }
	end
	
	-- Number pad
	self.heistNumpad = Instance.new("Frame")
	self.heistNumpad.Size = UDim2.new(0.8, 0, 0, 180)
	self.heistNumpad.AnchorPoint = Vector2.new(0.5, 0)
	self.heistNumpad.Position = UDim2.new(0.5, 0, 0, 225)
	self.heistNumpad.BackgroundTransparency = 1
	self.heistNumpad.ZIndex = 202
	self.heistNumpad.Parent = self.heistCard
	
	local numpadLayout = Instance.new("UIGridLayout")
	numpadLayout.CellSize = UDim2.new(0.3, 0, 0.22, 0)
	numpadLayout.CellPadding = UDim2.new(0.025, 0, 0.04, 0)
	numpadLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	numpadLayout.Parent = self.heistNumpad
	
	local numOrder = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "⌫", "0", "✓" }
	self.heistNumBtns = {}
	for i, num in ipairs(numOrder) do
		local btn = Instance.new("TextButton")
		btn.BackgroundColor3 = num == "✓" and C.Green or num == "⌫" and C.Red or C.Gray600
		btn.Font = F.Title
		btn.TextSize = 24
		btn.TextColor3 = C.White
		btn.Text = num
		btn.AutoButtonColor = false
		btn.LayoutOrder = i
		btn.ZIndex = 203
		btn.Parent = self.heistNumpad
		corner(btn, 12)
		
		self.heistNumBtns[num] = btn
	end
	
	-- Previous guesses
	self.heistHistory = Instance.new("Frame")
	self.heistHistory.Size = UDim2.new(0.9, 0, 0, 80)
	self.heistHistory.AnchorPoint = Vector2.new(0.5, 0)
	self.heistHistory.Position = UDim2.new(0.5, 0, 0, 415)
	self.heistHistory.BackgroundColor3 = C.Gray800
	self.heistHistory.ZIndex = 202
	self.heistHistory.Parent = self.heistCard
	corner(self.heistHistory, 12)
	
	local historyLayout = Instance.new("UIListLayout")
	historyLayout.FillDirection = Enum.FillDirection.Horizontal
	historyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	historyLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	historyLayout.Padding = UDim.new(0, 8)
	historyLayout.Parent = self.heistHistory
	
	self.heistHistoryLabels = {}
end

function Minigames:startHeist(callback)
	self.callback = callback
	self.heistOverlay.Visible = true
	self.activeGame = "heist"
	
	-- Generate secret code
	self.heistSecretCode = ""
	for i = 1, 4 do
		self.heistSecretCode = self.heistSecretCode .. tostring(math.random(0, 9))
	end
	
	self.heistCurrentInput = ""
	self.heistAttemptsLeft = 6
	self.heistGuesses = {}
	
	self.heistAttempts.Text = "Attempts: " .. self.heistAttemptsLeft .. " remaining"
	
	-- Clear display
	for i, data in ipairs(self.heistDigitLabels) do
		data.label.Text = "_"
		data.frame.BackgroundColor3 = C.Gray700
	end
	
	-- Clear history
	for _, child in ipairs(self.heistHistory:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	
	-- Connect numpad
	for num, btn in pairs(self.heistNumBtns) do
		btn.MouseButton1Click:Connect(function()
			self:handleHeistInput(num)
		end)
	end
end

function Minigames:handleHeistInput(input)
	if self.activeGame ~= "heist" then return end
	
	if input == "⌫" then
		if #self.heistCurrentInput > 0 then
			self.heistCurrentInput = string.sub(self.heistCurrentInput, 1, -2)
		end
	elseif input == "✓" then
		if #self.heistCurrentInput == 4 then
			self:submitHeistGuess()
		end
	else
		if #self.heistCurrentInput < 4 then
			self.heistCurrentInput = self.heistCurrentInput .. input
		end
	end
	
	-- Update display
	for i, data in ipairs(self.heistDigitLabels) do
		local char = string.sub(self.heistCurrentInput, i, i)
		data.label.Text = char ~= "" and char or "_"
	end
end

function Minigames:submitHeistGuess()
	local guess = self.heistCurrentInput
	self.heistAttemptsLeft = self.heistAttemptsLeft - 1
	self.heistAttempts.Text = "Attempts: " .. self.heistAttemptsLeft .. " remaining"
	
	-- Check guess
	local results = {}
	local secretCopy = self.heistSecretCode
	local guessCopy = guess
	
	-- First pass: exact matches (green)
	for i = 1, 4 do
		if string.sub(guess, i, i) == string.sub(self.heistSecretCode, i, i) then
			results[i] = "green"
		end
	end
	
	-- Second pass: wrong position (yellow)
	for i = 1, 4 do
		if not results[i] then
			local guessChar = string.sub(guess, i, i)
			for j = 1, 4 do
				if not results[j] and string.sub(self.heistSecretCode, j, j) == guessChar then
					results[i] = "yellow"
					break
				end
			end
			if not results[i] then
				results[i] = "gray"
			end
		end
	end
	
	-- Update digit display colors
	for i, data in ipairs(self.heistDigitLabels) do
		if results[i] == "green" then
			data.frame.BackgroundColor3 = C.Green
		elseif results[i] == "yellow" then
			data.frame.BackgroundColor3 = C.Amber
		else
			data.frame.BackgroundColor3 = C.Gray500
		end
	end
	
	-- Add to history
	local historyEntry = Instance.new("Frame")
	historyEntry.Size = UDim2.new(0, 60, 0, 50)
	historyEntry.BackgroundColor3 = C.Gray700
	historyEntry.ZIndex = 203
	historyEntry.Parent = self.heistHistory
	corner(historyEntry, 8)
	
	local historyLabel = Instance.new("TextLabel")
	historyLabel.Size = UDim2.fromScale(1, 1)
	historyLabel.BackgroundTransparency = 1
	historyLabel.Font = F.Button
	historyLabel.TextSize = 14
	historyLabel.TextColor3 = C.White
	historyLabel.Text = guess
	historyLabel.ZIndex = 204
	historyLabel.Parent = historyEntry
	
	-- Check for win
	if guess == self.heistSecretCode then
		self:endHeist(true)
		return
	end
	
	-- Check for loss
	if self.heistAttemptsLeft <= 0 then
		self:endHeist(false)
		return
	end
	
	-- Reset input
	self.heistCurrentInput = ""
	task.delay(0.5, function()
		for i, data in ipairs(self.heistDigitLabels) do
			data.label.Text = "_"
			data.frame.BackgroundColor3 = C.Gray700
		end
	end)
end

function Minigames:endHeist(won)
	self.activeGame = nil
	self.heistOverlay.Visible = false
	
	if self.callback then
		self.callback(won, { secretCode = self.heistSecretCode, attempts = 6 - self.heistAttemptsLeft })
		self.callback = nil
	end
end

-- ═══════════════════════════════════════════════════════════════
-- GETAWAY MINIGAME (Criminal Path)
-- Tap buttons in sequence to escape
-- ═══════════════════════════════════════════════════════════════

function Minigames:createGetawayGame()
	self.getawayOverlay = Instance.new("Frame")
	self.getawayOverlay.Size = UDim2.fromScale(1, 1)
	self.getawayOverlay.BackgroundColor3 = C.Black
	self.getawayOverlay.BackgroundTransparency = 0.2
	self.getawayOverlay.Visible = false
	self.getawayOverlay.ZIndex = 200
	self.getawayOverlay.Parent = self.screenGui
	
	self.getawayCard = Instance.new("Frame")
	self.getawayCard.Size = UDim2.new(0.95, 0, 0, 450)
	self.getawayCard.AnchorPoint = Vector2.new(0.5, 0.5)
	self.getawayCard.Position = UDim2.fromScale(0.5, 0.5)
	self.getawayCard.BackgroundColor3 = Color3.fromRGB(25, 35, 45)
	self.getawayCard.ZIndex = 201
	self.getawayCard.Parent = self.getawayOverlay
	corner(self.getawayCard, 20)
	
	-- Title
	local getawayTitle = Instance.new("TextLabel")
	getawayTitle.Size = UDim2.new(1, 0, 0, 60)
	getawayTitle.BackgroundColor3 = Color3.fromRGB(180, 100, 50)
	getawayTitle.Font = F.Title
	getawayTitle.TextSize = 24
	getawayTitle.TextColor3 = C.White
	getawayTitle.Text = "🚗 GETAWAY!"
	getawayTitle.ZIndex = 202
	getawayTitle.Parent = self.getawayCard
	corner(getawayTitle, 20)
	
	local titleFix = Instance.new("Frame")
	titleFix.Size = UDim2.new(1, 0, 0, 30)
	titleFix.Position = UDim2.new(0, 0, 0, 35)
	titleFix.BackgroundColor3 = Color3.fromRGB(180, 100, 50)
	titleFix.ZIndex = 202
	titleFix.Parent = getawayTitle
	
	-- Instructions
	self.getawayInstructions = Instance.new("TextLabel")
	self.getawayInstructions.Size = UDim2.new(0.9, 0, 0, 40)
	self.getawayInstructions.AnchorPoint = Vector2.new(0.5, 0)
	self.getawayInstructions.Position = UDim2.new(0.5, 0, 0, 70)
	self.getawayInstructions.BackgroundTransparency = 1
	self.getawayInstructions.Font = F.Body
	self.getawayInstructions.TextSize = 14
	self.getawayInstructions.TextColor3 = C.Gray300
	self.getawayInstructions.TextWrapped = true
	self.getawayInstructions.Text = "TAP THE HIGHLIGHTED BUTTONS IN ORDER! Don't let the cops catch you!"
	self.getawayInstructions.ZIndex = 202
	self.getawayInstructions.Parent = self.getawayCard
	
	-- Progress bar
	self.getawayProgressBg = Instance.new("Frame")
	self.getawayProgressBg.Size = UDim2.new(0.85, 0, 0, 20)
	self.getawayProgressBg.AnchorPoint = Vector2.new(0.5, 0)
	self.getawayProgressBg.Position = UDim2.new(0.5, 0, 0, 115)
	self.getawayProgressBg.BackgroundColor3 = C.Gray700
	self.getawayProgressBg.ZIndex = 202
	self.getawayProgressBg.Parent = self.getawayCard
	pill(self.getawayProgressBg)
	
	self.getawayProgressFill = Instance.new("Frame")
	self.getawayProgressFill.Size = UDim2.new(0, 0, 1, 0)
	self.getawayProgressFill.BackgroundColor3 = C.Green
	self.getawayProgressFill.ZIndex = 203
	self.getawayProgressFill.Parent = self.getawayProgressBg
	pill(self.getawayProgressFill)
	
	-- Cop progress (chasing you)
	self.copProgressFill = Instance.new("Frame")
	self.copProgressFill.Size = UDim2.new(0, 0, 1, 0)
	self.copProgressFill.AnchorPoint = Vector2.new(1, 0)
	self.copProgressFill.Position = UDim2.new(1, 0, 0, 0)
	self.copProgressFill.BackgroundColor3 = C.Red
	self.copProgressFill.ZIndex = 203
	self.copProgressFill.Parent = self.getawayProgressBg
	pill(self.copProgressFill)
	
	-- Button grid
	self.getawayGrid = Instance.new("Frame")
	self.getawayGrid.Size = UDim2.new(0.9, 0, 0, 260)
	self.getawayGrid.AnchorPoint = Vector2.new(0.5, 0)
	self.getawayGrid.Position = UDim2.new(0.5, 0, 0, 150)
	self.getawayGrid.BackgroundTransparency = 1
	self.getawayGrid.ZIndex = 202
	self.getawayGrid.Parent = self.getawayCard
	
	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0.3, 0, 0.3, 0)
	gridLayout.CellPadding = UDim2.new(0.025, 0, 0.04, 0)
	gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	gridLayout.Parent = self.getawayGrid
	
	local directions = { "↖", "↑", "↗", "←", "⬤", "→", "↙", "↓", "↘" }
	self.getawayBtns = {}
	for i, dir in ipairs(directions) do
		local btn = Instance.new("TextButton")
		btn.BackgroundColor3 = C.Gray600
		btn.Font = F.Title
		btn.TextSize = 36
		btn.TextColor3 = C.White
		btn.Text = dir
		btn.AutoButtonColor = false
		btn.LayoutOrder = i
		btn.ZIndex = 203
		btn.Parent = self.getawayGrid
		corner(btn, 16)
		
		self.getawayBtns[i] = btn
	end
end

function Minigames:startGetaway(callback)
	self.callback = callback
	self.getawayOverlay.Visible = true
	self.activeGame = "getaway"
	
	self.getawayProgress = 0
	self.copProgress = 0
	self.getawaySequence = {}
	self.currentSequenceIndex = 1
	self.getawayRound = 1
	
	self.getawayProgressFill.Size = UDim2.new(0, 0, 1, 0)
	self.copProgressFill.Size = UDim2.new(0, 0, 1, 0)
	
	-- Connect buttons
	for i, btn in ipairs(self.getawayBtns) do
		btn.MouseButton1Click:Connect(function()
			self:handleGetawayInput(i)
		end)
	end
	
	self:showNextGetawaySequence()
	self:startCopChase()
end

function Minigames:showNextGetawaySequence()
	-- Generate sequence
	local seqLength = 2 + self.getawayRound
	self.getawaySequence = {}
	for i = 1, seqLength do
		table.insert(self.getawaySequence, math.random(1, 9))
	end
	self.currentSequenceIndex = 1
	
	-- Reset all buttons
	for _, btn in ipairs(self.getawayBtns) do
		btn.BackgroundColor3 = C.Gray600
	end
	
	-- Show sequence
	for i, btnIndex in ipairs(self.getawaySequence) do
		task.delay(i * 0.4, function()
			if self.activeGame ~= "getaway" then return end
			local btn = self.getawayBtns[btnIndex]
			btn.BackgroundColor3 = C.Amber
			task.delay(0.3, function()
				if self.activeGame ~= "getaway" then return end
				btn.BackgroundColor3 = C.Gray600
			end)
		end)
	end
	
	-- After showing, highlight first to tap
	task.delay((#self.getawaySequence + 1) * 0.4, function()
		if self.activeGame ~= "getaway" then return end
		self:highlightCurrentTarget()
	end)
end

function Minigames:highlightCurrentTarget()
	if self.currentSequenceIndex > #self.getawaySequence then return end
	
	for _, btn in ipairs(self.getawayBtns) do
		btn.BackgroundColor3 = C.Gray600
	end
	
	local targetIndex = self.getawaySequence[self.currentSequenceIndex]
	self.getawayBtns[targetIndex].BackgroundColor3 = C.Blue
end

function Minigames:handleGetawayInput(btnIndex)
	if self.activeGame ~= "getaway" then return end
	if self.currentSequenceIndex > #self.getawaySequence then return end
	
	local targetIndex = self.getawaySequence[self.currentSequenceIndex]
	
	if btnIndex == targetIndex then
		-- Correct!
		self.getawayBtns[btnIndex].BackgroundColor3 = C.Green
		self.currentSequenceIndex = self.currentSequenceIndex + 1
		
		-- Update progress
		self.getawayProgress = self.getawayProgress + 0.1
		tween(self.getawayProgressFill, TweenInfo.new(0.2), { Size = UDim2.new(math.min(1, self.getawayProgress), 0, 1, 0) })
		
		if self.getawayProgress >= 1 then
			self:endGetaway(true)
			return
		end
		
		if self.currentSequenceIndex > #self.getawaySequence then
			-- Round complete, next round
			self.getawayRound = self.getawayRound + 1
			task.delay(0.5, function()
				self:showNextGetawaySequence()
			end)
		else
			task.delay(0.2, function()
				self:highlightCurrentTarget()
			end)
		end
	else
		-- Wrong!
		self.getawayBtns[btnIndex].BackgroundColor3 = C.Red
		self.copProgress = self.copProgress + 0.15
		tween(self.copProgressFill, TweenInfo.new(0.2), { Size = UDim2.new(math.min(1, self.copProgress), 0, 1, 0) })
		
		if self.copProgress >= 1 then
			self:endGetaway(false)
		end
	end
end

function Minigames:startCopChase()
	task.spawn(function()
		while self.activeGame == "getaway" do
			task.wait(2)
			if self.activeGame ~= "getaway" then break end
			
			self.copProgress = self.copProgress + 0.05
			tween(self.copProgressFill, TweenInfo.new(0.3), { Size = UDim2.new(math.min(1, self.copProgress), 0, 1, 0) })
			
			if self.copProgress >= 1 then
				self:endGetaway(false)
				break
			end
		end
	end)
end

function Minigames:endGetaway(escaped)
	self.activeGame = nil
	self.getawayOverlay.Visible = false
	
	if self.callback then
		self.callback(escaped, { progress = self.getawayProgress })
		self.callback = nil
	end
end

-- ═══════════════════════════════════════════════════════════════
-- QUICK TIME EVENT (Universal)
-- Tap rapidly or at the right time
-- ═══════════════════════════════════════════════════════════════

function Minigames:createQuickTimeGame()
	self.qteOverlay = Instance.new("Frame")
	self.qteOverlay.Size = UDim2.fromScale(1, 1)
	self.qteOverlay.BackgroundColor3 = C.Black
	self.qteOverlay.BackgroundTransparency = 0.3
	self.qteOverlay.Visible = false
	self.qteOverlay.ZIndex = 200
	self.qteOverlay.Parent = self.screenGui
	
	self.qteCard = Instance.new("Frame")
	self.qteCard.Size = UDim2.new(0.9, 0, 0, 350)
	self.qteCard.AnchorPoint = Vector2.new(0.5, 0.5)
	self.qteCard.Position = UDim2.fromScale(0.5, 0.5)
	self.qteCard.BackgroundColor3 = C.Gray800
	self.qteCard.ZIndex = 201
	self.qteCard.Parent = self.qteOverlay
	corner(self.qteCard, 24)
	
	-- Title
	self.qteTitle = Instance.new("TextLabel")
	self.qteTitle.Size = UDim2.new(1, 0, 0, 60)
	self.qteTitle.BackgroundTransparency = 1
	self.qteTitle.Font = F.Title
	self.qteTitle.TextSize = 24
	self.qteTitle.TextColor3 = C.White
	self.qteTitle.Text = "⚡ QUICK TIME EVENT"
	self.qteTitle.ZIndex = 202
	self.qteTitle.Parent = self.qteCard
	
	-- Instructions
	self.qteInstructions = Instance.new("TextLabel")
	self.qteInstructions.Size = UDim2.new(0.9, 0, 0, 40)
	self.qteInstructions.AnchorPoint = Vector2.new(0.5, 0)
	self.qteInstructions.Position = UDim2.new(0.5, 0, 0, 60)
	self.qteInstructions.BackgroundTransparency = 1
	self.qteInstructions.Font = F.Body
	self.qteInstructions.TextSize = 16
	self.qteInstructions.TextColor3 = C.Gray300
	self.qteInstructions.Text = "TAP when the bar is in the green zone!"
	self.qteInstructions.ZIndex = 202
	self.qteInstructions.Parent = self.qteCard
	
	-- Timing bar
	self.qteBarBg = Instance.new("Frame")
	self.qteBarBg.Size = UDim2.new(0.85, 0, 0, 60)
	self.qteBarBg.AnchorPoint = Vector2.new(0.5, 0)
	self.qteBarBg.Position = UDim2.new(0.5, 0, 0, 120)
	self.qteBarBg.BackgroundColor3 = C.Gray600
	self.qteBarBg.ZIndex = 202
	self.qteBarBg.Parent = self.qteCard
	corner(self.qteBarBg, 12)
	
	-- Green zone
	self.qteGreenZone = Instance.new("Frame")
	self.qteGreenZone.Size = UDim2.new(0.2, 0, 1, 0)
	self.qteGreenZone.Position = UDim2.new(0.4, 0, 0, 0)
	self.qteGreenZone.BackgroundColor3 = C.Green
	self.qteGreenZone.BackgroundTransparency = 0.3
	self.qteGreenZone.ZIndex = 203
	self.qteGreenZone.Parent = self.qteBarBg
	corner(self.qteGreenZone, 8)
	
	-- Moving indicator
	self.qteIndicator = Instance.new("Frame")
	self.qteIndicator.Size = UDim2.new(0.05, 0, 1.2, 0)
	self.qteIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
	self.qteIndicator.Position = UDim2.new(0, 0, 0.5, 0)
	self.qteIndicator.BackgroundColor3 = C.White
	self.qteIndicator.ZIndex = 204
	self.qteIndicator.Parent = self.qteBarBg
	corner(self.qteIndicator, 4)
	
	-- Tap button
	self.qteTapBtn = Instance.new("TextButton")
	self.qteTapBtn.Size = UDim2.new(0.7, 0, 0, 80)
	self.qteTapBtn.AnchorPoint = Vector2.new(0.5, 0)
	self.qteTapBtn.Position = UDim2.new(0.5, 0, 0, 200)
	self.qteTapBtn.BackgroundColor3 = C.Blue
	self.qteTapBtn.Font = F.Title
	self.qteTapBtn.TextSize = 28
	self.qteTapBtn.TextColor3 = C.White
	self.qteTapBtn.Text = "TAP!"
	self.qteTapBtn.AutoButtonColor = false
	self.qteTapBtn.ZIndex = 202
	self.qteTapBtn.Parent = self.qteCard
	corner(self.qteTapBtn, 16)
	
	-- Result display
	self.qteResult = Instance.new("TextLabel")
	self.qteResult.Size = UDim2.new(1, 0, 0, 40)
	self.qteResult.AnchorPoint = Vector2.new(0.5, 0)
	self.qteResult.Position = UDim2.new(0.5, 0, 0, 295)
	self.qteResult.BackgroundTransparency = 1
	self.qteResult.Font = F.Title
	self.qteResult.TextSize = 20
	self.qteResult.TextColor3 = C.White
	self.qteResult.Text = ""
	self.qteResult.ZIndex = 202
	self.qteResult.Parent = self.qteCard
end

function Minigames:startQTE(callback, difficulty)
	self.callback = callback
	self.qteOverlay.Visible = true
	self.activeGame = "qte"
	self.qteResult.Text = ""
	
	difficulty = difficulty or "medium"
	local greenZoneSize = difficulty == "easy" and 0.3 or difficulty == "hard" and 0.12 or 0.2
	local speed = difficulty == "easy" and 1.5 or difficulty == "hard" and 0.8 or 1.2
	
	self.qteGreenZone.Size = UDim2.new(greenZoneSize, 0, 1, 0)
	self.qteGreenZone.Position = UDim2.new(0.5 - greenZoneSize/2, 0, 0, 0)
	
	-- Animate indicator
	self.qteIndicator.Position = UDim2.new(0, 0, 0.5, 0)
	self.qteAnimating = true
	self.qteDirection = 1
	
	task.spawn(function()
		while self.qteAnimating and self.activeGame == "qte" do
			local currentX = self.qteIndicator.Position.X.Scale
			local newX = currentX + (0.02 * self.qteDirection / speed)
			
			if newX >= 1 then
				newX = 1
				self.qteDirection = -1
			elseif newX <= 0 then
				newX = 0
				self.qteDirection = 1
			end
			
			self.qteIndicator.Position = UDim2.new(newX, 0, 0.5, 0)
			task.wait(0.016)
		end
	end)
	
	-- Connect tap button
	self.qteTapBtn.MouseButton1Click:Connect(function()
		self:handleQTETap()
	end)
end

function Minigames:handleQTETap()
	if self.activeGame ~= "qte" then return end
	
	self.qteAnimating = false
	local indicatorX = self.qteIndicator.Position.X.Scale
	local greenStart = self.qteGreenZone.Position.X.Scale
	local greenEnd = greenStart + self.qteGreenZone.Size.X.Scale
	
	local success = indicatorX >= greenStart and indicatorX <= greenEnd
	
	if success then
		self.qteResult.Text = "✅ PERFECT!"
		self.qteResult.TextColor3 = C.Green
		self.qteIndicator.BackgroundColor3 = C.Green
	else
		self.qteResult.Text = "❌ MISSED!"
		self.qteResult.TextColor3 = C.Red
		self.qteIndicator.BackgroundColor3 = C.Red
	end
	
	task.delay(1, function()
		self:endQTE(success)
	end)
end

function Minigames:endQTE(success)
	self.activeGame = nil
	self.qteOverlay.Visible = false
	
	if self.callback then
		self.callback(success, {})
		self.callback = nil
	end
end

-- ═══════════════════════════════════════════════════════════════
-- PRISON ESCAPE MINIGAME (Criminal Path)
-- Navigate a maze to escape while avoiding the guard
-- ═══════════════════════════════════════════════════════════════

function Minigames:createPrisonEscapeGame()
	self.prisonOverlay = Instance.new("Frame")
	self.prisonOverlay.Size = UDim2.fromScale(1, 1)
	self.prisonOverlay.BackgroundColor3 = C.Black
	self.prisonOverlay.BackgroundTransparency = 0.2
	self.prisonOverlay.Visible = false
	self.prisonOverlay.ZIndex = 200
	self.prisonOverlay.Parent = self.screenGui
	
	self.prisonCard = Instance.new("Frame")
	self.prisonCard.Size = UDim2.new(0.95, 0, 0, 580)
	self.prisonCard.AnchorPoint = Vector2.new(0.5, 0.5)
	self.prisonCard.Position = UDim2.fromScale(0.5, 0.5)
	self.prisonCard.BackgroundColor3 = C.Gray800
	self.prisonCard.ZIndex = 201
	self.prisonCard.Parent = self.prisonOverlay
	corner(self.prisonCard, 24)
	
	-- Title
	local prisonTitle = Instance.new("TextLabel")
	prisonTitle.Size = UDim2.new(1, 0, 0, 60)
	prisonTitle.BackgroundColor3 = Color3.fromRGB(64, 64, 64)
	prisonTitle.Font = F.Title
	prisonTitle.TextSize = 22
	prisonTitle.TextColor3 = C.White
	prisonTitle.Text = "🔐 PRISON ESCAPE"
	prisonTitle.ZIndex = 202
	prisonTitle.Parent = self.prisonCard
	corner(prisonTitle, 24)
	
	local titleFix = Instance.new("Frame")
	titleFix.Size = UDim2.new(1, 0, 0, 30)
	titleFix.Position = UDim2.new(0, 0, 0, 35)
	titleFix.BackgroundColor3 = Color3.fromRGB(64, 64, 64)
	titleFix.ZIndex = 202
	titleFix.Parent = prisonTitle
	
	-- Instructions
	self.prisonInstructions = Instance.new("TextLabel")
	self.prisonInstructions.Size = UDim2.new(0.9, 0, 0, 50)
	self.prisonInstructions.AnchorPoint = Vector2.new(0.5, 0)
	self.prisonInstructions.Position = UDim2.new(0.5, 0, 0, 65)
	self.prisonInstructions.BackgroundTransparency = 1
	self.prisonInstructions.Font = F.Body
	self.prisonInstructions.TextSize = 13
	self.prisonInstructions.TextColor3 = C.Gray300
	self.prisonInstructions.TextWrapped = true
	self.prisonInstructions.Text = "🟢 = You  |  🔴 = Guard  |  🟡 = Exit\nReach the exit before the guard catches you!\nThe guard moves TWICE for every move you make!"
	self.prisonInstructions.ZIndex = 202
	self.prisonInstructions.Parent = self.prisonCard
	
	-- Grid container
	self.prisonGridContainer = Instance.new("Frame")
	self.prisonGridContainer.Size = UDim2.new(0, 280, 0, 280)
	self.prisonGridContainer.AnchorPoint = Vector2.new(0.5, 0)
	self.prisonGridContainer.Position = UDim2.new(0.5, 0, 0, 120)
	self.prisonGridContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
	self.prisonGridContainer.ZIndex = 202
	self.prisonGridContainer.Parent = self.prisonCard
	corner(self.prisonGridContainer, 12)
	stroke(self.prisonGridContainer, 2, 0.5, C.Gray600)
	
	pad(self.prisonGridContainer, 4, 4, 4, 4)
	
	-- Grid cells
	self.prisonCells = {}
	local gridSize = 8
	self.prisonGridSize = gridSize
	local cellSize = 272 / gridSize
	
	for y = 1, gridSize do
		self.prisonCells[y] = {}
		for x = 1, gridSize do
			local cell = Instance.new("Frame")
			cell.Size = UDim2.new(0, cellSize - 2, 0, cellSize - 2)
			cell.Position = UDim2.new(0, (x-1) * cellSize + 4, 0, (y-1) * cellSize + 4)
			cell.BackgroundColor3 = C.Gray700
			cell.ZIndex = 203
			cell.Parent = self.prisonGridContainer
			corner(cell, 4)
			
			local cellLabel = Instance.new("TextLabel")
			cellLabel.Size = UDim2.fromScale(1, 1)
			cellLabel.BackgroundTransparency = 1
			cellLabel.Font = F.Body
			cellLabel.TextSize = 20
			cellLabel.Text = ""
			cellLabel.ZIndex = 204
			cellLabel.Parent = cell
			
			self.prisonCells[y][x] = { frame = cell, label = cellLabel }
		end
	end
	
	-- Arrow buttons container
	local arrowContainer = Instance.new("Frame")
	arrowContainer.Size = UDim2.new(0, 180, 0, 130)
	arrowContainer.AnchorPoint = Vector2.new(0.5, 0)
	arrowContainer.Position = UDim2.new(0.5, 0, 0, 420)
	arrowContainer.BackgroundTransparency = 1
	arrowContainer.ZIndex = 202
	arrowContainer.Parent = self.prisonCard
	
	self.prisonArrows = {}
	local arrows = {
		{ dir = "up", text = "↑", x = 0.5, y = 0, dx = 0, dy = -1 },
		{ dir = "down", text = "↓", x = 0.5, y = 1, dx = 0, dy = 1 },
		{ dir = "left", text = "←", x = 0, y = 0.5, dx = -1, dy = 0 },
		{ dir = "right", text = "→", x = 1, y = 0.5, dx = 1, dy = 0 },
	}
	
	for _, arrow in ipairs(arrows) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 54, 0, 54)
		btn.AnchorPoint = Vector2.new(0.5, 0.5)
		btn.Position = UDim2.new(arrow.x, 0, arrow.y, 0)
		btn.BackgroundColor3 = C.Gray600
		btn.Font = F.Title
		btn.TextSize = 28
		btn.TextColor3 = C.White
		btn.Text = arrow.text
		btn.AutoButtonColor = false
		btn.ZIndex = 203
		btn.Parent = arrowContainer
		corner(btn, 14)
		
		self.prisonArrows[arrow.dir] = { btn = btn, dx = arrow.dx, dy = arrow.dy }
		
		btn.MouseEnter:Connect(function()
			tween(btn, TweenInfo.new(0.1), { BackgroundColor3 = C.Blue })
		end)
		btn.MouseLeave:Connect(function()
			tween(btn, TweenInfo.new(0.1), { BackgroundColor3 = C.Gray600 })
		end)
	end
	
	-- Move counter
	self.prisonMoveCounter = Instance.new("TextLabel")
	self.prisonMoveCounter.Size = UDim2.new(0.9, 0, 0, 24)
	self.prisonMoveCounter.AnchorPoint = Vector2.new(0.5, 0)
	self.prisonMoveCounter.Position = UDim2.new(0.5, 0, 0, 555)
	self.prisonMoveCounter.BackgroundTransparency = 1
	self.prisonMoveCounter.Font = F.Medium
	self.prisonMoveCounter.TextSize = 14
	self.prisonMoveCounter.TextColor3 = C.Gray400
	self.prisonMoveCounter.Text = "Moves: 0"
	self.prisonMoveCounter.ZIndex = 202
	self.prisonMoveCounter.Parent = self.prisonCard
end

function Minigames:startPrisonEscape(callback)
	if not self.prisonOverlay then
		self:createPrisonEscapeGame()
	end
	
	self.callback = callback
	self.prisonOverlay.Visible = true
	self.activeGame = "prison_escape"
	
	-- Initialize positions
	self.prisonPlayerPos = { x = 1, y = 1 }
	self.prisonGuardPos = { x = self.prisonGridSize, y = self.prisonGridSize - 2 }
	self.prisonExitPos = { x = self.prisonGridSize, y = self.prisonGridSize }
	self.prisonMoves = 0
	
	-- Create walls (maze pattern)
	self.prisonWalls = {}
	local gs = self.prisonGridSize
	
	-- Create a simple but challenging maze
	local wallPattern = {
		{2, 2}, {3, 2}, {4, 2}, {5, 2},
		{2, 4}, {3, 4}, {4, 4},
		{6, 3}, {6, 4}, {6, 5},
		{2, 6}, {3, 6}, {4, 6}, {5, 6},
		{7, 6}, {7, 7},
		{4, 7}, {4, 8},
	}
	
	for _, wall in ipairs(wallPattern) do
		if wall[1] <= gs and wall[2] <= gs then
			self.prisonWalls[wall[2] .. "_" .. wall[1]] = true
		end
	end
	
	-- Connect arrow buttons
	for dir, data in pairs(self.prisonArrows) do
		-- Disconnect previous connections
		if data.connection then
			data.connection:Disconnect()
		end
		data.connection = data.btn.MouseButton1Click:Connect(function()
			self:handlePrisonMove(data.dx, data.dy)
		end)
	end
	
	self:updatePrisonVisuals()
end

function Minigames:isPrisonWalkable(x, y)
	-- Check bounds
	if x < 1 or x > self.prisonGridSize or y < 1 or y > self.prisonGridSize then
		return false
	end
	-- Check walls
	if self.prisonWalls[y .. "_" .. x] then
		return false
	end
	return true
end

function Minigames:updatePrisonVisuals()
	-- Clear all cells
	for y = 1, self.prisonGridSize do
		for x = 1, self.prisonGridSize do
			local cell = self.prisonCells[y][x]
			cell.label.Text = ""
			
			-- Check if wall
			if self.prisonWalls[y .. "_" .. x] then
				cell.frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			else
				cell.frame.BackgroundColor3 = C.Gray700
			end
		end
	end
	
	-- Draw exit
	local exitCell = self.prisonCells[self.prisonExitPos.y][self.prisonExitPos.x]
	exitCell.frame.BackgroundColor3 = C.Amber
	exitCell.label.Text = "🚪"
	
	-- Draw guard
	local guardCell = self.prisonCells[self.prisonGuardPos.y][self.prisonGuardPos.x]
	guardCell.frame.BackgroundColor3 = C.Red
	guardCell.label.Text = "👮"
	
	-- Draw player
	local playerCell = self.prisonCells[self.prisonPlayerPos.y][self.prisonPlayerPos.x]
	playerCell.frame.BackgroundColor3 = C.Green
	playerCell.label.Text = "🏃"
	
	-- Update move counter
	self.prisonMoveCounter.Text = "Moves: " .. self.prisonMoves
end

function Minigames:moveGuardTowardPlayer()
	local gx, gy = self.prisonGuardPos.x, self.prisonGuardPos.y
	local px, py = self.prisonPlayerPos.x, self.prisonPlayerPos.y
	
	-- Try horizontal first
	local dx = 0
	local dy = 0
	
	if px < gx and self:isPrisonWalkable(gx - 1, gy) then
		dx = -1
	elseif px > gx and self:isPrisonWalkable(gx + 1, gy) then
		dx = 1
	end
	
	if dx ~= 0 then
		gx = gx + dx
	else
		-- Try vertical
		if py < gy and self:isPrisonWalkable(gx, gy - 1) then
			dy = -1
		elseif py > gy and self:isPrisonWalkable(gx, gy + 1) then
			dy = 1
		end
		
		if dy ~= 0 then
			gy = gy + dy
		end
	end
	
	self.prisonGuardPos.x = gx
	self.prisonGuardPos.y = gy
end

function Minigames:handlePrisonMove(dx, dy)
	if self.activeGame ~= "prison_escape" then return end
	
	-- Try to move player
	local nx = self.prisonPlayerPos.x + dx
	local ny = self.prisonPlayerPos.y + dy
	
	if self:isPrisonWalkable(nx, ny) then
		self.prisonPlayerPos.x = nx
		self.prisonPlayerPos.y = ny
		self.prisonMoves = self.prisonMoves + 1
	end
	
	self:updatePrisonVisuals()
	
	-- Check win
	if self.prisonPlayerPos.x == self.prisonExitPos.x and self.prisonPlayerPos.y == self.prisonExitPos.y then
		task.delay(0.2, function()
			self:endPrisonEscape(true)
		end)
		return
	end
	
	-- Guard moves twice
	for i = 1, 2 do
		self:moveGuardTowardPlayer()
		
		-- Check if guard caught player
		if self.prisonGuardPos.x == self.prisonPlayerPos.x and self.prisonGuardPos.y == self.prisonPlayerPos.y then
			self:updatePrisonVisuals()
			task.delay(0.3, function()
				self:endPrisonEscape(false)
			end)
			return
		end
	end
	
	self:updatePrisonVisuals()
end

function Minigames:endPrisonEscape(escaped)
	self.activeGame = nil
	
	-- Disconnect arrow connections
	for _, data in pairs(self.prisonArrows) do
		if data.connection then
			data.connection:Disconnect()
			data.connection = nil
		end
	end
	
	self.prisonOverlay.Visible = false
	
	if self.callback then
		self.callback(escaped, { moves = self.prisonMoves, escaped = escaped })
		self.callback = nil
	end
end

-- ═══════════════════════════════════════════════════════════════
-- MASH MINIGAME (Universal - Tap rapidly)
-- ═══════════════════════════════════════════════════════════════

function Minigames:createMashGame()
	self.mashOverlay = Instance.new("Frame")
	self.mashOverlay.Size = UDim2.fromScale(1, 1)
	self.mashOverlay.BackgroundColor3 = C.Black
	self.mashOverlay.BackgroundTransparency = 0.3
	self.mashOverlay.Visible = false
	self.mashOverlay.ZIndex = 200
	self.mashOverlay.Parent = self.screenGui
	
	self.mashCard = Instance.new("Frame")
	self.mashCard.Size = UDim2.new(0.9, 0, 0, 380)
	self.mashCard.AnchorPoint = Vector2.new(0.5, 0.5)
	self.mashCard.Position = UDim2.fromScale(0.5, 0.5)
	self.mashCard.BackgroundColor3 = C.Gray800
	self.mashCard.ZIndex = 201
	self.mashCard.Parent = self.mashOverlay
	corner(self.mashCard, 24)
	
	-- Title
	self.mashTitle = Instance.new("TextLabel")
	self.mashTitle.Size = UDim2.new(1, 0, 0, 60)
	self.mashTitle.BackgroundTransparency = 1
	self.mashTitle.Font = F.Title
	self.mashTitle.TextSize = 24
	self.mashTitle.TextColor3 = C.White
	self.mashTitle.Text = "⚡ MASH!"
	self.mashTitle.ZIndex = 202
	self.mashTitle.Parent = self.mashCard
	
	-- Instructions
	self.mashInstructions = Instance.new("TextLabel")
	self.mashInstructions.Size = UDim2.new(0.9, 0, 0, 30)
	self.mashInstructions.AnchorPoint = Vector2.new(0.5, 0)
	self.mashInstructions.Position = UDim2.new(0.5, 0, 0, 60)
	self.mashInstructions.BackgroundTransparency = 1
	self.mashInstructions.Font = F.Body
	self.mashInstructions.TextSize = 14
	self.mashInstructions.TextColor3 = C.Gray300
	self.mashInstructions.Text = "TAP AS FAST AS YOU CAN!"
	self.mashInstructions.ZIndex = 202
	self.mashInstructions.Parent = self.mashCard
	
	-- Progress bar
	self.mashProgressBg = Instance.new("Frame")
	self.mashProgressBg.Size = UDim2.new(0.85, 0, 0, 30)
	self.mashProgressBg.AnchorPoint = Vector2.new(0.5, 0)
	self.mashProgressBg.Position = UDim2.new(0.5, 0, 0, 100)
	self.mashProgressBg.BackgroundColor3 = C.Gray600
	self.mashProgressBg.ZIndex = 202
	self.mashProgressBg.Parent = self.mashCard
	pill(self.mashProgressBg)
	
	self.mashProgressFill = Instance.new("Frame")
	self.mashProgressFill.Size = UDim2.new(0, 0, 1, 0)
	self.mashProgressFill.BackgroundColor3 = C.Green
	self.mashProgressFill.ZIndex = 203
	self.mashProgressFill.Parent = self.mashProgressBg
	pill(self.mashProgressFill)
	
	-- Timer
	self.mashTimer = Instance.new("TextLabel")
	self.mashTimer.Size = UDim2.new(0.9, 0, 0, 30)
	self.mashTimer.AnchorPoint = Vector2.new(0.5, 0)
	self.mashTimer.Position = UDim2.new(0.5, 0, 0, 140)
	self.mashTimer.BackgroundTransparency = 1
	self.mashTimer.Font = F.Title
	self.mashTimer.TextSize = 24
	self.mashTimer.TextColor3 = C.Amber
	self.mashTimer.Text = "5.0s"
	self.mashTimer.ZIndex = 202
	self.mashTimer.Parent = self.mashCard
	
	-- Tap button
	self.mashTapBtn = Instance.new("TextButton")
	self.mashTapBtn.Size = UDim2.new(0.7, 0, 0, 140)
	self.mashTapBtn.AnchorPoint = Vector2.new(0.5, 0)
	self.mashTapBtn.Position = UDim2.new(0.5, 0, 0, 185)
	self.mashTapBtn.BackgroundColor3 = C.Blue
	self.mashTapBtn.Font = F.Title
	self.mashTapBtn.TextSize = 36
	self.mashTapBtn.TextColor3 = C.White
	self.mashTapBtn.Text = "👆\nTAP!"
	self.mashTapBtn.AutoButtonColor = false
	self.mashTapBtn.ZIndex = 202
	self.mashTapBtn.Parent = self.mashCard
	corner(self.mashTapBtn, 20)
	
	-- Tap counter
	self.mashCounter = Instance.new("TextLabel")
	self.mashCounter.Size = UDim2.new(0.9, 0, 0, 30)
	self.mashCounter.AnchorPoint = Vector2.new(0.5, 0)
	self.mashCounter.Position = UDim2.new(0.5, 0, 0, 340)
	self.mashCounter.BackgroundTransparency = 1
	self.mashCounter.Font = F.Title
	self.mashCounter.TextSize = 18
	self.mashCounter.TextColor3 = C.White
	self.mashCounter.Text = "Taps: 0"
	self.mashCounter.ZIndex = 202
	self.mashCounter.Parent = self.mashCard
end

function Minigames:startMash(callback, options)
	if not self.mashOverlay then
		self:createMashGame()
	end
	
	options = options or {}
	self.callback = callback
	self.mashOverlay.Visible = true
	self.activeGame = "mash"
	
	self.mashTaps = 0
	self.mashRequired = options.requiredTaps or 30
	self.mashTimeLimit = options.timeLimit or 5
	self.mashTimeRemaining = self.mashTimeLimit
	
	self.mashProgressFill.Size = UDim2.new(0, 0, 1, 0)
	self.mashCounter.Text = "Taps: 0 / " .. self.mashRequired
	self.mashTimer.Text = string.format("%.1fs", self.mashTimeRemaining)
	
	-- Connect tap button
	if self.mashConnection then
		self.mashConnection:Disconnect()
	end
	self.mashConnection = self.mashTapBtn.MouseButton1Click:Connect(function()
		self:handleMashTap()
	end)
	
	-- Start timer
	task.spawn(function()
		while self.activeGame == "mash" and self.mashTimeRemaining > 0 do
			task.wait(0.1)
			self.mashTimeRemaining = self.mashTimeRemaining - 0.1
			self.mashTimer.Text = string.format("%.1fs", math.max(0, self.mashTimeRemaining))
			
			if self.mashTimeRemaining <= 0 then
				self:endMash(false)
				break
			end
		end
	end)
end

function Minigames:handleMashTap()
	if self.activeGame ~= "mash" then return end
	
	self.mashTaps = self.mashTaps + 1
	self.mashCounter.Text = "Taps: " .. self.mashTaps .. " / " .. self.mashRequired
	
	-- Update progress
	local progress = self.mashTaps / self.mashRequired
	tween(self.mashProgressFill, TweenInfo.new(0.05), { Size = UDim2.new(math.min(1, progress), 0, 1, 0) })
	
	-- Button feedback
	tween(self.mashTapBtn, TweenInfo.new(0.05), { Size = UDim2.new(0.68, 0, 0, 135) })
	task.delay(0.05, function()
		if self.mashTapBtn then
			tween(self.mashTapBtn, TweenInfo.new(0.05), { Size = UDim2.new(0.7, 0, 0, 140) })
		end
	end)
	
	-- Check win
	if self.mashTaps >= self.mashRequired then
		self:endMash(true)
	end
end

function Minigames:endMash(success)
	self.activeGame = nil
	
	if self.mashConnection then
		self.mashConnection:Disconnect()
		self.mashConnection = nil
	end
	
	self.mashOverlay.Visible = false
	
	if self.callback then
		self.callback(success, { taps = self.mashTaps, required = self.mashRequired })
		self.callback = nil
	end
end

-- ═══════════════════════════════════════════════════════════════
-- HACKER TYPING MINIGAME (Hacker Career)
-- Type the code quickly and accurately to hack!
-- ═══════════════════════════════════════════════════════════════

function Minigames:createHackingGame()
	self.hackOverlay = Instance.new("Frame")
	self.hackOverlay.Size = UDim2.fromScale(1, 1)
	self.hackOverlay.BackgroundColor3 = Color3.fromRGB(0, 10, 0)
	self.hackOverlay.BackgroundTransparency = 0.15
	self.hackOverlay.Visible = false
	self.hackOverlay.ZIndex = 200
	self.hackOverlay.Parent = self.screenGui
	
	self.hackCard = Instance.new("Frame")
	self.hackCard.Size = UDim2.new(0.95, 0, 0, 480)
	self.hackCard.AnchorPoint = Vector2.new(0.5, 0.5)
	self.hackCard.Position = UDim2.fromScale(0.5, 0.5)
	self.hackCard.BackgroundColor3 = Color3.fromRGB(15, 25, 15)
	self.hackCard.ZIndex = 201
	self.hackCard.Parent = self.hackOverlay
	corner(self.hackCard, 20)
	stroke(self.hackCard, 2, 0, Color3.fromRGB(0, 255, 0))
	
	-- Scanline effect overlay
	local scanlines = Instance.new("Frame")
	scanlines.Size = UDim2.fromScale(1, 1)
	scanlines.BackgroundColor3 = Color3.fromRGB(0, 50, 0)
	scanlines.BackgroundTransparency = 0.95
	scanlines.ZIndex = 202
	scanlines.Parent = self.hackCard
	corner(scanlines, 20)
	
	-- Title with hacker aesthetic
	local hackTitle = Instance.new("TextLabel")
	hackTitle.Size = UDim2.new(1, 0, 0, 60)
	hackTitle.BackgroundColor3 = Color3.fromRGB(0, 80, 0)
	hackTitle.Font = F.Title
	hackTitle.TextSize = 22
	hackTitle.TextColor3 = Color3.fromRGB(0, 255, 0)
	hackTitle.Text = "💻 SYSTEM BREACH INITIATED"
	hackTitle.ZIndex = 203
	hackTitle.Parent = self.hackCard
	corner(hackTitle, 20)
	
	local titleFix = Instance.new("Frame")
	titleFix.Size = UDim2.new(1, 0, 0, 30)
	titleFix.Position = UDim2.new(0, 0, 0, 35)
	titleFix.BackgroundColor3 = Color3.fromRGB(0, 80, 0)
	titleFix.ZIndex = 202
	titleFix.Parent = hackTitle
	
	-- Status text
	self.hackStatus = Instance.new("TextLabel")
	self.hackStatus.Size = UDim2.new(0.9, 0, 0, 30)
	self.hackStatus.AnchorPoint = Vector2.new(0.5, 0)
	self.hackStatus.Position = UDim2.new(0.5, 0, 0, 70)
	self.hackStatus.BackgroundTransparency = 1
	self.hackStatus.Font = F.Medium
	self.hackStatus.TextSize = 14
	self.hackStatus.TextColor3 = Color3.fromRGB(0, 200, 0)
	self.hackStatus.Text = ">> Type the code below to breach the system..."
	self.hackStatus.ZIndex = 203
	self.hackStatus.Parent = self.hackCard
	
	-- Timer bar
	self.hackTimerBg = Instance.new("Frame")
	self.hackTimerBg.Size = UDim2.new(0.85, 0, 0, 12)
	self.hackTimerBg.AnchorPoint = Vector2.new(0.5, 0)
	self.hackTimerBg.Position = UDim2.new(0.5, 0, 0, 105)
	self.hackTimerBg.BackgroundColor3 = C.Gray700
	self.hackTimerBg.ZIndex = 203
	self.hackTimerBg.Parent = self.hackCard
	pill(self.hackTimerBg)
	
	self.hackTimerFill = Instance.new("Frame")
	self.hackTimerFill.Size = UDim2.new(1, 0, 1, 0)
	self.hackTimerFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	self.hackTimerFill.ZIndex = 204
	self.hackTimerFill.Parent = self.hackTimerBg
	pill(self.hackTimerFill)
	
	-- Code to type display (the target)
	self.hackTargetFrame = Instance.new("Frame")
	self.hackTargetFrame.Size = UDim2.new(0.9, 0, 0, 80)
	self.hackTargetFrame.AnchorPoint = Vector2.new(0.5, 0)
	self.hackTargetFrame.Position = UDim2.new(0.5, 0, 0, 130)
	self.hackTargetFrame.BackgroundColor3 = Color3.fromRGB(10, 30, 10)
	self.hackTargetFrame.ZIndex = 203
	self.hackTargetFrame.Parent = self.hackCard
	corner(self.hackTargetFrame, 12)
	stroke(self.hackTargetFrame, 1, 0.5, Color3.fromRGB(0, 150, 0))
	
	self.hackTargetLabel = Instance.new("TextLabel")
	self.hackTargetLabel.Size = UDim2.fromScale(1, 1)
	self.hackTargetLabel.BackgroundTransparency = 1
	self.hackTargetLabel.Font = Enum.Font.Code
	self.hackTargetLabel.TextSize = 32
	self.hackTargetLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
	self.hackTargetLabel.Text = "HACK123"
	self.hackTargetLabel.ZIndex = 204
	self.hackTargetLabel.Parent = self.hackTargetFrame
	
	-- Player input display
	self.hackInputFrame = Instance.new("Frame")
	self.hackInputFrame.Size = UDim2.new(0.9, 0, 0, 60)
	self.hackInputFrame.AnchorPoint = Vector2.new(0.5, 0)
	self.hackInputFrame.Position = UDim2.new(0.5, 0, 0, 220)
	self.hackInputFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	self.hackInputFrame.ZIndex = 203
	self.hackInputFrame.Parent = self.hackCard
	corner(self.hackInputFrame, 12)
	stroke(self.hackInputFrame, 2, 0, Color3.fromRGB(100, 100, 150))
	
	self.hackInputLabel = Instance.new("TextLabel")
	self.hackInputLabel.Size = UDim2.fromScale(1, 1)
	self.hackInputLabel.BackgroundTransparency = 1
	self.hackInputLabel.Font = Enum.Font.Code
	self.hackInputLabel.TextSize = 28
	self.hackInputLabel.TextColor3 = C.White
	self.hackInputLabel.Text = "_"
	self.hackInputLabel.ZIndex = 204
	self.hackInputLabel.Parent = self.hackInputFrame
	
	-- Round counter
	self.hackRoundLabel = Instance.new("TextLabel")
	self.hackRoundLabel.Size = UDim2.new(0.9, 0, 0, 24)
	self.hackRoundLabel.AnchorPoint = Vector2.new(0.5, 0)
	self.hackRoundLabel.Position = UDim2.new(0.5, 0, 0, 290)
	self.hackRoundLabel.BackgroundTransparency = 1
	self.hackRoundLabel.Font = F.Medium
	self.hackRoundLabel.TextSize = 16
	self.hackRoundLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	self.hackRoundLabel.Text = "Round 1/5"
	self.hackRoundLabel.ZIndex = 203
	self.hackRoundLabel.Parent = self.hackCard
	
	-- Virtual keyboard
	self.hackKeyboard = Instance.new("Frame")
	self.hackKeyboard.Size = UDim2.new(0.95, 0, 0, 150)
	self.hackKeyboard.AnchorPoint = Vector2.new(0.5, 0)
	self.hackKeyboard.Position = UDim2.new(0.5, 0, 0, 320)
	self.hackKeyboard.BackgroundTransparency = 1
	self.hackKeyboard.ZIndex = 203
	self.hackKeyboard.Parent = self.hackCard
	
	-- Create keyboard rows
	local keyRows = {
		"QWERTYUIOP",
		"ASDFGHJKL",
		"ZXCVBNM123",
		"4567890⌫",
	}
	
	self.hackKeys = {}
	for rowIdx, row in ipairs(keyRows) do
		local rowFrame = Instance.new("Frame")
		rowFrame.Size = UDim2.new(1, 0, 0.22, 0)
		rowFrame.Position = UDim2.new(0, 0, (rowIdx-1) * 0.25, 0)
		rowFrame.BackgroundTransparency = 1
		rowFrame.ZIndex = 204
		rowFrame.Parent = self.hackKeyboard
		
		local rowLayout = Instance.new("UIListLayout")
		rowLayout.FillDirection = Enum.FillDirection.Horizontal
		rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		rowLayout.Padding = UDim.new(0, 3)
		rowLayout.Parent = rowFrame
		
		for i = 1, #row do
			local char = string.sub(row, i, i)
			local keyBtn = Instance.new("TextButton")
			keyBtn.Size = UDim2.new(0, 28, 0, 32)
			keyBtn.BackgroundColor3 = char == "⌫" and C.Red or Color3.fromRGB(40, 60, 40)
			keyBtn.Font = Enum.Font.Code
			keyBtn.TextSize = 16
			keyBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
			keyBtn.Text = char
			keyBtn.AutoButtonColor = false
			keyBtn.ZIndex = 205
			keyBtn.Parent = rowFrame
			corner(keyBtn, 6)
			
			self.hackKeys[char] = keyBtn
		end
	end
	
	-- Result display
	self.hackResult = Instance.new("TextLabel")
	self.hackResult.Size = UDim2.new(0.9, 0, 0, 40)
	self.hackResult.AnchorPoint = Vector2.new(0.5, 0)
	self.hackResult.Position = UDim2.new(0.5, 0, 0, 475)
	self.hackResult.BackgroundTransparency = 1
	self.hackResult.Font = F.Title
	self.hackResult.TextSize = 20
	self.hackResult.TextColor3 = Color3.fromRGB(0, 255, 0)
	self.hackResult.Text = ""
	self.hackResult.ZIndex = 203
	self.hackResult.Parent = self.hackCard
	
	-- Hack code words database
	self.hackCodes = {
		easy = {"HACK", "CODE", "ROOT", "SUDO", "PING", "PORT", "SCAN", "EXEC"},
		medium = {"HACK123", "ACCESS1", "BYPASS01", "ROOTKIT", "EXPLOIT", "PAYLOAD", "MALWARE"},
		hard = {"DECRYPT99", "BACKDOOR1", "ZERODAY42", "FIREWALL0", "INJECTION", "OVERFLOW1"},
	}
end

function Minigames:startHacking(callback, options)
	if not self.hackOverlay then
		self:createHackingGame()
	end
	
	options = options or {}
	self.callback = callback
	self.hackOverlay.Visible = true
	self.activeGame = "hacking"
	self.hackResult.Text = ""
	
	-- Difficulty determines code complexity and time
	local difficulty = options.difficulty or "medium"
	self.hackDifficulty = difficulty
	
	local codePool = self.hackCodes[difficulty] or self.hackCodes.medium
	local timePerCode = difficulty == "easy" and 6 or difficulty == "hard" and 3.5 or 4.5
	
	self.hackTotalRounds = options.rounds or 5
	self.hackCurrentRound = 0
	self.hackSuccesses = 0
	self.hackCurrentInput = ""
	self.hackCodePool = codePool
	self.hackTimePerCode = timePerCode
	
	-- Connect keyboard
	for char, btn in pairs(self.hackKeys) do
		btn.MouseButton1Click:Connect(function()
			self:handleHackInput(char)
		end)
	end
	
	-- Start first round
	self:startHackRound()
end

function Minigames:startHackRound()
	self.hackCurrentRound = self.hackCurrentRound + 1
	
	if self.hackCurrentRound > self.hackTotalRounds then
		self:endHacking()
		return
	end
	
	-- Pick a random code
	self.hackTargetCode = self.hackCodePool[math.random(#self.hackCodePool)]
	self.hackCurrentInput = ""
	
	-- Update display
	self.hackTargetLabel.Text = self.hackTargetCode
	self.hackInputLabel.Text = "_"
	self.hackRoundLabel.Text = "Round " .. self.hackCurrentRound .. "/" .. self.hackTotalRounds
	self.hackStatus.Text = ">> Type the code to breach security layer " .. self.hackCurrentRound .. "..."
	
	-- Reset timer
	self.hackTimerFill.Size = UDim2.new(1, 0, 1, 0)
	self.hackTimerFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	
	-- Animate timer
	local timerTween = tween(self.hackTimerFill, TweenInfo.new(self.hackTimePerCode, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 1, 0) })
	
	-- Color change as time runs out
	task.delay(self.hackTimePerCode * 0.5, function()
		if self.activeGame == "hacking" then
			tween(self.hackTimerFill, TweenInfo.new(0.3), { BackgroundColor3 = C.Amber })
		end
	end)
	task.delay(self.hackTimePerCode * 0.8, function()
		if self.activeGame == "hacking" then
			tween(self.hackTimerFill, TweenInfo.new(0.3), { BackgroundColor3 = C.Red })
		end
	end)
	
	-- Timeout
	self.hackTimerConnection = task.delay(self.hackTimePerCode, function()
		if self.activeGame == "hacking" then
			self:handleHackTimeout()
		end
	end)
end

function Minigames:handleHackInput(char)
	if self.activeGame ~= "hacking" then return end
	
	if char == "⌫" then
		-- Backspace
		if #self.hackCurrentInput > 0 then
			self.hackCurrentInput = string.sub(self.hackCurrentInput, 1, -2)
		end
	else
		-- Add character
		self.hackCurrentInput = self.hackCurrentInput .. char
	end
	
	-- Update display with cursor
	if #self.hackCurrentInput > 0 then
		self.hackInputLabel.Text = self.hackCurrentInput .. "_"
	else
		self.hackInputLabel.Text = "_"
	end
	
	-- Check if complete
	if #self.hackCurrentInput >= #self.hackTargetCode then
		self:checkHackAnswer()
	end
end

function Minigames:checkHackAnswer()
	if self.hackTimerConnection then
		task.cancel(self.hackTimerConnection)
		self.hackTimerConnection = nil
	end
	
	local correct = self.hackCurrentInput == self.hackTargetCode
	
	if correct then
		self.hackSuccesses = self.hackSuccesses + 1
		self.hackInputFrame.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
		self.hackStatus.Text = ">> LAYER BREACHED! Security compromised..."
		stroke(self.hackInputFrame, 2, 0, Color3.fromRGB(0, 255, 0))
		
		-- Flash target green
		tween(self.hackTargetFrame, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(0, 100, 0) })
	else
		self.hackInputFrame.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
		self.hackStatus.Text = ">> ERROR! Incorrect input detected..."
		stroke(self.hackInputFrame, 2, 0, C.Red)
		
		-- Flash target red
		tween(self.hackTargetFrame, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(100, 0, 0) })
	end
	
	-- Next round after delay
	task.delay(0.8, function()
		if self.activeGame == "hacking" then
			-- Reset colors
			self.hackInputFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
			self.hackTargetFrame.BackgroundColor3 = Color3.fromRGB(10, 30, 10)
			stroke(self.hackInputFrame, 2, 0, Color3.fromRGB(100, 100, 150))
			
			self:startHackRound()
		end
	end)
end

function Minigames:handleHackTimeout()
	-- Timeout counts as failure
	self.hackInputFrame.BackgroundColor3 = Color3.fromRGB(80, 50, 0)
	self.hackStatus.Text = ">> TIMEOUT! Connection lost..."
	
	task.delay(0.6, function()
		if self.activeGame == "hacking" then
			self.hackInputFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
			self:startHackRound()
		end
	end)
end

function Minigames:endHacking()
	self.activeGame = nil
	
	if self.hackTimerConnection then
		task.cancel(self.hackTimerConnection)
		self.hackTimerConnection = nil
	end
	
	-- Calculate success
	local successRate = self.hackSuccesses / self.hackTotalRounds
	local won = successRate >= 0.6 -- Need at least 60% correct
	
	-- Show result
	if won then
		self.hackResult.Text = "✅ SYSTEM BREACHED! Access granted."
		self.hackResult.TextColor3 = Color3.fromRGB(0, 255, 0)
	else
		self.hackResult.Text = "❌ HACK FAILED! Security alert triggered."
		self.hackResult.TextColor3 = C.Red
	end
	
	task.delay(1.5, function()
		self.hackOverlay.Visible = false
		
		if self.callback then
			self.callback(won, { 
				successes = self.hackSuccesses, 
				rounds = self.hackTotalRounds,
				difficulty = self.hackDifficulty,
			})
			self.callback = nil
		end
	end)
end

-- ═══════════════════════════════════════════════════════════════
-- PUBLIC API
-- ═══════════════════════════════════════════════════════════════

function Minigames:play(gameType, callback, options)
	options = options or {}
	
	if gameType == "debate" then
		self:startDebate(callback)
	elseif gameType == "heist" then
		self:startHeist(callback)
	elseif gameType == "getaway" then
		self:startGetaway(callback)
	elseif gameType == "qte" then
		self:startQTE(callback, options.difficulty)
	elseif gameType == "prison_escape" then
		self:startPrisonEscape(callback)
	elseif gameType == "mash" then
		self:startMash(callback, options)
	elseif gameType == "hacking" then
		self:startHacking(callback, options)
	else
		-- Unknown game type, just call callback with success
		if callback then
			callback(true, { error = "Unknown minigame type: " .. tostring(gameType) })
		end
	end
end

function Minigames:isActive()
	return self.activeGame ~= nil
end

function Minigames:cancel()
	self.activeGame = nil
	if self.debateOverlay then self.debateOverlay.Visible = false end
	if self.heistOverlay then self.heistOverlay.Visible = false end
	if self.getawayOverlay then self.getawayOverlay.Visible = false end
	if self.qteOverlay then self.qteOverlay.Visible = false end
	if self.prisonOverlay then self.prisonOverlay.Visible = false end
	if self.mashOverlay then self.mashOverlay.Visible = false end
	if self.hackOverlay then self.hackOverlay.Visible = false end
	self.callback = nil
end

function Minigames:getAvailableGames()
	return {
		{ id = "debate", name = "Debate", emoji = "🎤", description = "Answer questions correctly" },
		{ id = "heist", name = "Heist", emoji = "🔓", description = "Crack the safe code" },
		{ id = "getaway", name = "Getaway", emoji = "🚗", description = "Escape from the cops" },
		{ id = "qte", name = "Quick Time", emoji = "⚡", description = "Tap at the right moment" },
		{ id = "prison_escape", name = "Prison Escape", emoji = "🔐", description = "Navigate the maze" },
		{ id = "mash", name = "Mash", emoji = "👆", description = "Tap as fast as you can" },
		{ id = "hacking", name = "Hacking", emoji = "💻", description = "Type codes to breach systems" },
	}
end

return Minigames
