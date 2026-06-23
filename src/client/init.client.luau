local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local TicTacToeLogic = require(ReplicatedStorage.Shared.TicTacToeLogic)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local leaderstats = player:WaitForChild("leaderstats")
local gameFunction = ReplicatedStorage:WaitForChild("TicTacToeGameFunction")

local wins = leaderstats:WaitForChild("Wins")
local streak = leaderstats:WaitForChild("Streak")
local bestStreak = leaderstats:WaitForChild("BestStreak")
local losses = leaderstats:WaitForChild("Losses")
local ties = leaderstats:WaitForChild("Ties")

local buttons = {}
local buttonStrokes = {}
local celebrationToken = 0
local requestBusy = false
local currentDifficulty = "Smart"
local randomGenerator = Random.new()

local rainbowColors = {
	Color3.fromRGB(255, 77, 109),
	Color3.fromRGB(255, 183, 77),
	Color3.fromRGB(255, 238, 88),
	Color3.fromRGB(74, 222, 128),
	Color3.fromRGB(56, 189, 248),
	Color3.fromRGB(99, 102, 241),
	Color3.fromRGB(217, 70, 239),
}

local function addCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent

	return corner
end

local function addStroke(parent, color, thickness, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness
	stroke.Transparency = transparency or 0
	stroke.Parent = parent

	return stroke
end

local function makeLabel(parent, text, position, size, font, color)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Font = font
	label.Position = position
	label.Size = size
	label.Text = text
	label.TextColor3 = color
	label.TextScaled = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent

	return label
end

local function makeButton(parent, text, position, size, color)
	local button = Instance.new("TextButton")
	button.BackgroundColor3 = color
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.Position = position
	button.Size = size
	button.Text = text
	button.TextColor3 = Color3.fromRGB(238, 248, 255)
	button.TextScaled = true
	button.Parent = parent
	addCorner(button, 7)

	return button
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BlueTicTacToeGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local hintBar = Instance.new("Frame")
hintBar.AnchorPoint = Vector2.new(0.5, 0)
hintBar.BackgroundColor3 = Color3.fromRGB(4, 28, 62)
hintBar.BackgroundTransparency = 0.08
hintBar.BorderSizePixel = 0
hintBar.Position = UDim2.fromScale(0.5, 0.03)
hintBar.Size = UDim2.fromOffset(440, 44)
hintBar.Parent = screenGui
addCorner(hintBar, 8)
addStroke(hintBar, Color3.fromRGB(74, 188, 255), 1, 0.2)

local hintLabel = makeLabel(
	hintBar,
	"Walk to the AI table and press E to play.",
	UDim2.fromOffset(16, 6),
	UDim2.new(1, -32, 1, -12),
	Enum.Font.GothamBold,
	Color3.fromRGB(222, 244, 255)
)
hintLabel.TextXAlignment = Enum.TextXAlignment.Center

local background = Instance.new("Frame")
background.BackgroundColor3 = Color3.fromRGB(2, 8, 23)
background.BackgroundTransparency = 0.05
background.BorderSizePixel = 0
background.Size = UDim2.fromScale(1, 1)
background.Visible = false
background.Parent = screenGui

local backgroundGradient = Instance.new("UIGradient")
backgroundGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(2, 8, 23)),
	ColorSequenceKeypoint.new(0.48, Color3.fromRGB(0, 70, 140)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 28, 74)),
})
backgroundGradient.Rotation = 18
backgroundGradient.Parent = background

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.BackgroundColor3 = Color3.fromRGB(8, 24, 52)
panel.BorderSizePixel = 0
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(480, 560)
panel.Parent = background
addCorner(panel, 8)
addStroke(panel, Color3.fromRGB(74, 188, 255), 2, 0.15)

local panelScale = Instance.new("UIScale")
panelScale.Parent = panel

local panelGradient = Instance.new("UIGradient")
panelGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(11, 43, 83)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 17, 40)),
})
panelGradient.Rotation = 90
panelGradient.Parent = panel

makeLabel(
	panel,
	GameConfig.gameName,
	UDim2.fromOffset(24, 16),
	UDim2.new(1, -92, 0, 40),
	Enum.Font.GothamBlack,
	Color3.fromRGB(232, 246, 255)
)

local closeButton =
	makeButton(panel, "X", UDim2.new(1, -58, 0, 20), UDim2.fromOffset(34, 34), Color3.fromRGB(12, 83, 148))

makeLabel(
	panel,
	"Sit across from the AI and control the board.",
	UDim2.fromOffset(26, 58),
	UDim2.new(1, -52, 0, 22),
	Enum.Font.GothamMedium,
	Color3.fromRGB(158, 220, 255)
)

local statsLabel = makeLabel(
	panel,
	"",
	UDim2.fromOffset(26, 88),
	UDim2.new(1, -52, 0, 28),
	Enum.Font.GothamBold,
	Color3.fromRGB(232, 246, 255)
)

local statusLabel = makeLabel(
	panel,
	"Press New Round to start.",
	UDim2.fromOffset(26, 120),
	UDim2.new(1, -52, 0, 28),
	Enum.Font.GothamBold,
	Color3.fromRGB(191, 230, 255)
)

local chillButton =
	makeButton(panel, "Chill", UDim2.fromOffset(26, 158), UDim2.fromOffset(100, 34), Color3.fromRGB(12, 83, 148))
local smartButton =
	makeButton(panel, "Smart", UDim2.fromOffset(136, 158), UDim2.fromOffset(100, 34), Color3.fromRGB(0, 132, 210))
local newRoundButton =
	makeButton(panel, "New Round", UDim2.new(1, -152, 0, 158), UDim2.fromOffset(126, 34), Color3.fromRGB(0, 145, 214))

local boardFrame = Instance.new("Frame")
boardFrame.BackgroundColor3 = Color3.fromRGB(170, 224, 255)
boardFrame.BorderSizePixel = 0
boardFrame.Position = UDim2.fromOffset(75, 210)
boardFrame.Size = UDim2.fromOffset(330, 330)
boardFrame.Parent = panel
addCorner(boardFrame, 8)
addStroke(boardFrame, Color3.fromRGB(191, 230, 255), 2, 0.08)

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellPadding = UDim2.fromOffset(6, 6)
gridLayout.CellSize = UDim2.fromOffset(106, 106)
gridLayout.FillDirectionMaxCells = 3
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.Parent = boardFrame

local celebrationLabel = makeLabel(
	background,
	"",
	UDim2.fromScale(0, 0.08),
	UDim2.fromScale(1, 0.09),
	Enum.Font.GothamBlack,
	Color3.fromRGB(255, 255, 255)
)
celebrationLabel.TextXAlignment = Enum.TextXAlignment.Center
celebrationLabel.Visible = false

local function updateScale()
	local camera = workspace.CurrentCamera

	if not camera then
		return
	end

	local viewport = camera.ViewportSize
	local scale = math.min(viewport.X / 540, viewport.Y / 640, 1)
	panelScale.Scale = math.max(scale, 0.72)
end

if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
	updateScale()
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(updateScale)

local function updateStats()
	statsLabel.Text = ("Wins %d  Losses %d  Ties %d  Streak %d  Best %d"):format(
		wins.Value,
		losses.Value,
		ties.Value,
		streak.Value,
		bestStreak.Value
	)
end

local function updateDifficultyButtons()
	if currentDifficulty == "Smart" then
		smartButton.BackgroundColor3 = Color3.fromRGB(0, 174, 239)
		chillButton.BackgroundColor3 = Color3.fromRGB(12, 83, 148)
	else
		chillButton.BackgroundColor3 = Color3.fromRGB(0, 174, 239)
		smartButton.BackgroundColor3 = Color3.fromRGB(12, 83, 148)
	end
end

local function clearGlow()
	celebrationToken += 1

	for _, stroke in ipairs(buttonStrokes) do
		stroke.Transparency = 1
	end

	for _, button in ipairs(buttons) do
		button.BackgroundColor3 = Color3.fromRGB(9, 39, 78)
	end

	celebrationLabel.Visible = false
end

local function spawnConfetti()
	for index = 1, 34 do
		local piece = Instance.new("Frame")
		piece.AnchorPoint = Vector2.new(0.5, 0.5)
		piece.BackgroundColor3 = rainbowColors[((index - 1) % #rainbowColors) + 1]
		piece.BorderSizePixel = 0
		piece.Position = UDim2.fromScale(randomGenerator:NextNumber(0.08, 0.92), -0.06)
		piece.Rotation = randomGenerator:NextInteger(0, 180)
		piece.Size = UDim2.fromOffset(randomGenerator:NextInteger(8, 16), randomGenerator:NextInteger(14, 24))
		piece.Parent = background
		addCorner(piece, 3)

		local tween = TweenService:Create(
			piece,
			TweenInfo.new(randomGenerator:NextNumber(1.2, 2.1), Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Position = UDim2.fromScale(
					randomGenerator:NextNumber(0.04, 0.96),
					randomGenerator:NextNumber(0.76, 1.08)
				),
				Rotation = piece.Rotation + randomGenerator:NextInteger(160, 520),
				BackgroundTransparency = 1,
			}
		)

		tween:Play()
		tween.Completed:Connect(function()
			piece:Destroy()
		end)
	end
end

local function startRainbowGlow(line)
	celebrationToken += 1
	local token = celebrationToken

	celebrationLabel.Text = "YOU WIN"
	celebrationLabel.TextTransparency = 0
	celebrationLabel.Visible = true
	spawnConfetti()

	for _, stroke in ipairs(buttonStrokes) do
		stroke.Transparency = 0.05
		stroke.Thickness = 4
	end

	if line then
		for _, index in ipairs(line) do
			buttons[index].BackgroundColor3 = Color3.fromRGB(7, 92, 130)
		end
	end

	task.spawn(function()
		local colorIndex = 1

		while celebrationToken == token do
			local color = rainbowColors[colorIndex]

			for _, stroke in ipairs(buttonStrokes) do
				TweenService:Create(stroke, TweenInfo.new(0.18), { Color = color }):Play()
			end

			for _, button in ipairs(buttons) do
				TweenService
					:Create(
						button,
						TweenInfo.new(0.18),
						{ BackgroundColor3 = color:Lerp(Color3.fromRGB(4, 25, 54), 0.45) }
					)
					:Play()
			end

			colorIndex = (colorIndex % #rainbowColors) + 1
			task.wait(0.2)
		end
	end)
end

local function showLossGlow(line)
	if line then
		for _, index in ipairs(line) do
			buttons[index].BackgroundColor3 = Color3.fromRGB(82, 31, 57)
			buttonStrokes[index].Color = Color3.fromRGB(255, 99, 146)
			buttonStrokes[index].Transparency = 0.05
		end
	end
end

local function applyState(state)
	if not state then
		statusLabel.Text = "The server did not return a game state."
		return
	end

	clearGlow()
	currentDifficulty = state.difficulty or currentDifficulty
	statusLabel.Text = state.status or "Your turn."
	updateDifficultyButtons()

	for index, button in ipairs(buttons) do
		local value = state.board and state.board[index] or TicTacToeLogic.empty
		button.Text = value

		if value == TicTacToeLogic.playerMark then
			button.TextColor3 = Color3.fromRGB(125, 249, 255)
		elseif value == TicTacToeLogic.computerMark then
			button.TextColor3 = Color3.fromRGB(255, 99, 146)
		else
			button.TextColor3 = Color3.fromRGB(232, 246, 255)
		end
	end

	if state.winner == TicTacToeLogic.playerMark then
		startRainbowGlow(state.line)
	elseif state.winner == TicTacToeLogic.computerMark then
		showLossGlow(state.line)
	elseif state.winner == "Tie" then
		for _, stroke in ipairs(buttonStrokes) do
			stroke.Color = Color3.fromRGB(255, 238, 88)
			stroke.Transparency = 0.12
		end
	end
end

local function requestState(action, payload)
	if requestBusy then
		return
	end

	requestBusy = true
	statusLabel.Text = action == "Move" and "AI is thinking..." or "Loading round..."

	local ok, state = pcall(function()
		return gameFunction:InvokeServer(action, payload)
	end)

	requestBusy = false

	if ok then
		applyState(state)
	else
		statusLabel.Text = "Server request failed."
		warn(state)
	end
end

local function openGame()
	background.Visible = true
	hintBar.Visible = false
	requestState("NewRound")
end

for index = 1, 9 do
	local button = Instance.new("TextButton")
	button.BackgroundColor3 = Color3.fromRGB(9, 39, 78)
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBlack
	button.LayoutOrder = index
	button.Text = ""
	button.TextScaled = true
	button.Parent = boardFrame
	addCorner(button, 6)

	local stroke = addStroke(button, Color3.fromRGB(125, 249, 255), 3, 1)

	button.MouseButton1Click:Connect(function()
		requestState("Move", index)
	end)

	buttons[index] = button
	buttonStrokes[index] = stroke
end

wins:GetPropertyChangedSignal("Value"):Connect(updateStats)
losses:GetPropertyChangedSignal("Value"):Connect(updateStats)
ties:GetPropertyChangedSignal("Value"):Connect(updateStats)
streak:GetPropertyChangedSignal("Value"):Connect(updateStats)
bestStreak:GetPropertyChangedSignal("Value"):Connect(updateStats)

chillButton.MouseButton1Click:Connect(function()
	requestState("SetDifficulty", "Chill")
end)

smartButton.MouseButton1Click:Connect(function()
	requestState("SetDifficulty", "Smart")
end)

newRoundButton.MouseButton1Click:Connect(function()
	requestState("NewRound")
end)

closeButton.MouseButton1Click:Connect(function()
	background.Visible = false
	hintBar.Visible = true
	clearGlow()
end)

ProximityPromptService.PromptTriggered:Connect(function(prompt)
	if prompt.Name == "OpenTicTacToePrompt" then
		openGame()
	end
end)

updateStats()
updateDifficultyButtons()
applyState({
	board = TicTacToeLogic.createBoard(),
	difficulty = currentDifficulty,
	status = "Walk to the AI table and press E.",
})
