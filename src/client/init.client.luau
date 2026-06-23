local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local winEvent = ReplicatedStorage:WaitForChild("TicTacToeWinEvent")

local board = table.create(9, "")
local buttons = {}
local gameOpen = false
local gameOver = false

local winningLines = {
	{ 1, 2, 3 },
	{ 4, 5, 6 },
	{ 7, 8, 9 },
	{ 1, 4, 7 },
	{ 2, 5, 8 },
	{ 3, 6, 9 },
	{ 1, 5, 9 },
	{ 3, 5, 7 },
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TicTacToeGui"
screenGui.ResetOnSpawn = false
screenGui.Enabled = false
screenGui.Parent = playerGui

local dim = Instance.new("Frame")
dim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
dim.BackgroundTransparency = 0.35
dim.BorderSizePixel = 0
dim.Size = UDim2.fromScale(1, 1)
dim.Parent = screenGui

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
panel.BorderSizePixel = 0
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(430, 540)
panel.Parent = dim

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 8)
panelCorner.Parent = panel

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Position = UDim2.fromOffset(20, 16)
title.Size = UDim2.new(1, -96, 0, 42)
title.Text = GameConfig.gameName
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local closeButton = Instance.new("TextButton")
closeButton.BackgroundColor3 = Color3.fromRGB(42, 46, 56)
closeButton.BorderSizePixel = 0
closeButton.Font = Enum.Font.GothamBold
closeButton.Position = UDim2.new(1, -62, 0, 20)
closeButton.Size = UDim2.fromOffset(42, 34)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Parent = panel

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

local statusLabel = Instance.new("TextLabel")
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.Position = UDim2.fromOffset(20, 66)
statusLabel.Size = UDim2.new(1, -40, 0, 34)
statusLabel.Text = "You are X. Pick a square."
statusLabel.TextColor3 = Color3.fromRGB(226, 232, 240)
statusLabel.TextScaled = true
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = panel

local boardFrame = Instance.new("Frame")
boardFrame.BackgroundColor3 = Color3.fromRGB(240, 244, 255)
boardFrame.BorderSizePixel = 0
boardFrame.Position = UDim2.fromOffset(40, 118)
boardFrame.Size = UDim2.fromOffset(350, 350)
boardFrame.Parent = panel

local boardCorner = Instance.new("UICorner")
boardCorner.CornerRadius = UDim.new(0, 6)
boardCorner.Parent = boardFrame

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellPadding = UDim2.fromOffset(5, 5)
gridLayout.CellSize = UDim2.fromOffset(113, 113)
gridLayout.FillDirectionMaxCells = 3
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.Parent = boardFrame

local resetButton = Instance.new("TextButton")
resetButton.BackgroundColor3 = Color3.fromRGB(0, 146, 204)
resetButton.BorderSizePixel = 0
resetButton.Font = Enum.Font.GothamBold
resetButton.Position = UDim2.fromOffset(40, 486)
resetButton.Size = UDim2.fromOffset(170, 36)
resetButton.Text = "New Game"
resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
resetButton.TextScaled = true
resetButton.Parent = panel

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 6)
resetCorner.Parent = resetButton

local hint = Instance.new("TextLabel")
hint.BackgroundTransparency = 1
hint.Font = Enum.Font.GothamMedium
hint.Position = UDim2.fromOffset(224, 488)
hint.Size = UDim2.fromOffset(166, 32)
hint.Text = "Walk away or press X to close."
hint.TextColor3 = Color3.fromRGB(176, 185, 198)
hint.TextScaled = true
hint.TextXAlignment = Enum.TextXAlignment.Right
hint.Parent = panel

local function checkWinner()
	for _, line in winningLines do
		local a = line[1]
		local b = line[2]
		local c = line[3]

		if board[a] ~= "" and board[a] == board[b] and board[a] == board[c] then
			return board[a], line
		end
	end

	for index = 1, #board do
		if board[index] == "" then
			return nil, nil
		end
	end

	return "Tie", nil
end

local function setButtonStyle(index)
	local button = buttons[index]
	local value = board[index]

	button.Text = value

	if value == "X" then
		button.TextColor3 = Color3.fromRGB(74, 222, 128)
	elseif value == "O" then
		button.TextColor3 = Color3.fromRGB(248, 113, 113)
	else
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
end

local function refreshBoard()
	for index = 1, #buttons do
		setButtonStyle(index)
	end
end

local function setStatus(text)
	statusLabel.Text = text
end

local function emptySquares()
	local squares = {}

	for index = 1, #board do
		if board[index] == "" then
			table.insert(squares, index)
		end
	end

	return squares
end

local function findWinningMove(mark)
	for _, line in winningLines do
		local marks = 0
		local emptyIndex = nil

		for _, index in line do
			if board[index] == mark then
				marks += 1
			elseif board[index] == "" then
				emptyIndex = index
			end
		end

		if marks == 2 and emptyIndex then
			return emptyIndex
		end
	end

	return nil
end

local function chooseComputerMove()
	return findWinningMove("O")
		or findWinningMove("X")
		or (board[5] == "" and 5)
		or emptySquares()[1]
end

local function finishIfNeeded()
	local winner, line = checkWinner()

	if not winner then
		return false
	end

	gameOver = true

	if line then
		for _, index in line do
			buttons[index].BackgroundColor3 = Color3.fromRGB(55, 80, 58)
		end
	end

	if winner == "X" then
		setStatus("You won. Nice.")
		winEvent:FireServer()
	elseif winner == "O" then
		setStatus("Computer won. Start a new game.")
	else
		setStatus("Tie game. Start a new game.")
	end

	return true
end

local function computerTurn()
	if gameOver then
		return
	end

	local move = chooseComputerMove()

	if not move then
		return
	end

	board[move] = "O"
	refreshBoard()

	if not finishIfNeeded() then
		setStatus("Your turn. Pick a square.")
	end
end

local function playerMove(index)
	if gameOver or board[index] ~= "" then
		return
	end

	board[index] = "X"
	refreshBoard()

	if finishIfNeeded() then
		return
	end

	setStatus("Computer is thinking...")
	task.delay(0.35, computerTurn)
end

local function resetGame()
	for index = 1, #board do
		board[index] = ""
	end

	for _, button in buttons do
		button.BackgroundColor3 = Color3.fromRGB(31, 35, 44)
	end

	gameOver = false
	setStatus("You are X. Pick a square.")
	refreshBoard()
end

local function openGame()
	gameOpen = true
	screenGui.Enabled = true
	resetGame()
end

local function closeGame()
	gameOpen = false
	screenGui.Enabled = false
end

for index = 1, 9 do
	local button = Instance.new("TextButton")
	button.BackgroundColor3 = Color3.fromRGB(31, 35, 44)
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBlack
	button.LayoutOrder = index
	button.Text = ""
	button.TextScaled = true
	button.Parent = boardFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = button

	button.MouseButton1Click:Connect(function()
		playerMove(index)
	end)

	buttons[index] = button
end

closeButton.MouseButton1Click:Connect(closeGame)
resetButton.MouseButton1Click:Connect(resetGame)

ProximityPromptService.PromptTriggered:Connect(function(prompt)
	if prompt.Name == "TicTacToePrompt" then
		openGame()
	end
end)

player.CharacterAdded:Connect(function()
	if gameOpen then
		closeGame()
	end
end)
