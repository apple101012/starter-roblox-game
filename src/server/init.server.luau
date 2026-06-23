local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local TicTacToeLogic = require(ReplicatedStorage.Shared.TicTacToeLogic)

print(("[Starter Roblox Game] Server running for %s"):format(GameConfig.gameName))

for _, oldName in ipairs({ "CoinDashMap", "DeskTicTacToeMap", "TicTacToeArena" }) do
	local oldMap = workspace:FindFirstChild(oldName)

	if oldMap then
		oldMap:Destroy()
	end
end

local oldResultEvent = ReplicatedStorage:FindFirstChild("TicTacToeResultEvent")

if oldResultEvent then
	oldResultEvent:Destroy()
end

local oldWinEvent = ReplicatedStorage:FindFirstChild("TicTacToeWinEvent")

if oldWinEvent then
	oldWinEvent:Destroy()
end

local gameFunction = ReplicatedStorage:FindFirstChild("TicTacToeGameFunction")

if not gameFunction then
	gameFunction = Instance.new("RemoteFunction")
	gameFunction.Name = "TicTacToeGameFunction"
	gameFunction.Parent = ReplicatedStorage
end

local map = Instance.new("Folder")
map.Name = "TicTacToeArena"
map.Parent = workspace

local sessions = {}

local function makePart(name, size, position, color)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.Position = position
	part.Color = color
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = map

	return part
end

local function addSurfaceText(part, face, text, color, font)
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Face = face
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surfaceGui.PixelsPerStud = 42
	surfaceGui.Parent = part

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Font = font or Enum.Font.GothamBlack
	label.Size = UDim2.fromScale(1, 1)
	label.Text = text
	label.TextColor3 = color
	label.TextScaled = true
	label.Parent = surfaceGui

	return label
end

local floor = makePart(
	"BlueArenaFloor",
	Vector3.new(GameConfig.arenaHalfSize * 2, 2, GameConfig.arenaHalfSize * 2),
	Vector3.new(0, -1, 0),
	Color3.fromRGB(13, 42, 74)
)
floor.Material = Enum.Material.SmoothPlastic

local wallColor = Color3.fromRGB(6, 24, 50)
local wallThickness = 3
local wallHeight = 18
local edge = GameConfig.arenaHalfSize + wallThickness / 2

makePart(
	"NorthWall",
	Vector3.new(GameConfig.arenaHalfSize * 2 + wallThickness * 2, wallHeight, wallThickness),
	Vector3.new(0, wallHeight / 2 - 1, -edge),
	wallColor
)
makePart(
	"SouthWall",
	Vector3.new(GameConfig.arenaHalfSize * 2 + wallThickness * 2, wallHeight, wallThickness),
	Vector3.new(0, wallHeight / 2 - 1, edge),
	wallColor
)
makePart(
	"EastWall",
	Vector3.new(wallThickness, wallHeight, GameConfig.arenaHalfSize * 2),
	Vector3.new(edge, wallHeight / 2 - 1, 0),
	wallColor
)
makePart(
	"WestWall",
	Vector3.new(wallThickness, wallHeight, GameConfig.arenaHalfSize * 2),
	Vector3.new(-edge, wallHeight / 2 - 1, 0),
	wallColor
)

local spawnLocation = Instance.new("SpawnLocation")
spawnLocation.Name = "RojoSpawn"
spawnLocation.Anchored = true
spawnLocation.Size = Vector3.new(12, 1, 12)
spawnLocation.Position = Vector3.new(0, 1, -16)
spawnLocation.Orientation = Vector3.new(0, 180, 0)
spawnLocation.Color = GameConfig.spawnColor
spawnLocation.Material = Enum.Material.Neon
spawnLocation.Parent = map

local light = Instance.new("PointLight")
light.Brightness = 2
light.Color = Color3.fromRGB(0, 170, 255)
light.Range = 32
light.Parent = spawnLocation

local sign = makePart(
	"GameSign",
	Vector3.new(34, 8, 1),
	Vector3.new(0, 8, -GameConfig.arenaHalfSize + 4),
	Color3.fromRGB(0, 91, 171)
)
sign.Material = Enum.Material.Neon

local surfaceGui = Instance.new("SurfaceGui")
surfaceGui.Face = Enum.NormalId.Front
surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
surfaceGui.PixelsPerStud = 36
surfaceGui.Parent = sign

local signText = Instance.new("TextLabel")
signText.BackgroundTransparency = 1
signText.Font = Enum.Font.GothamBlack
signText.Size = UDim2.fromScale(1, 1)
signText.Text = "BLUE TICTACTOE"
signText.TextColor3 = Color3.fromRGB(232, 246, 255)
signText.TextScaled = true
signText.Parent = surfaceGui

local boardLabels = {}
local boardCells = {}
local generatedScene = workspace:FindFirstChild("TicTacToeScene")
local generatedScenePivot = CFrame.new(0, 6, -28)
local tableCenter = generatedScenePivot.Position

Lighting.Ambient = Color3.fromRGB(35, 79, 130)
Lighting.Brightness = 2.8
Lighting.ColorShift_Top = Color3.fromRGB(78, 197, 255)
Lighting.ColorShift_Bottom = Color3.fromRGB(5, 20, 50)
Lighting.EnvironmentDiffuseScale = 0.45
Lighting.EnvironmentSpecularScale = 0.85
Lighting.GlobalShadows = true
Lighting.OutdoorAmbient = Color3.fromRGB(12, 35, 75)

local function addLight(part, color, brightness, range)
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = brightness
	pointLight.Color = color
	pointLight.Range = range
	pointLight.Parent = part

	return pointLight
end

local function makeNeonPart(name, size, position, color)
	local part = makePart(name, size, position, color)
	part.Material = Enum.Material.Neon

	return part
end

local function createLoungeDressing()
	local cyan = Color3.fromRGB(0, 190, 255)
	local deepBlue = Color3.fromRGB(5, 22, 55)
	local panelBlue = Color3.fromRGB(8, 58, 118)
	local tableFocus = generatedScenePivot.Position

	local platform = makePart(
		"TablePresentationPlatform",
		Vector3.new(30, 0.45, 22),
		Vector3.new(tableFocus.X, 0.25, tableFocus.Z),
		Color3.fromRGB(7, 31, 70)
	)
	platform.Material = Enum.Material.SmoothPlastic

	makeNeonPart(
		"PlatformFrontGlow",
		Vector3.new(30, 0.2, 0.35),
		Vector3.new(tableFocus.X, 0.62, tableFocus.Z + 11.1),
		cyan
	)
	makeNeonPart(
		"PlatformBackGlow",
		Vector3.new(30, 0.2, 0.35),
		Vector3.new(tableFocus.X, 0.62, tableFocus.Z - 11.1),
		Color3.fromRGB(90, 145, 255)
	)
	makeNeonPart(
		"PlatformLeftGlow",
		Vector3.new(0.35, 0.2, 22),
		Vector3.new(tableFocus.X - 15.1, 0.62, tableFocus.Z),
		cyan
	)
	makeNeonPart(
		"PlatformRightGlow",
		Vector3.new(0.35, 0.2, 22),
		Vector3.new(tableFocus.X + 15.1, 0.62, tableFocus.Z),
		cyan
	)

	for index = 1, 6 do
		local z = 10 - index * 5.4
		local pathTile = makePart(
			("SpawnRunwayTile%d"):format(index),
			Vector3.new(8, 0.18, 3.6),
			Vector3.new(0, 0.18, z),
			Color3.fromRGB(8, 44, 94)
		)
		pathTile.Material = Enum.Material.SmoothPlastic

		local centerLine = makeNeonPart(
			("SpawnRunwayGlow%d"):format(index),
			Vector3.new(0.45, 0.24, 3.8),
			Vector3.new(0, 0.42, z),
			Color3.fromRGB(55, 226, 255)
		)
		addLight(centerLine, Color3.fromRGB(55, 226, 255), 0.45, 8)
	end

	local archTop = makeNeonPart("SpawnArchTop", Vector3.new(18, 0.7, 1), Vector3.new(0, 11, 8), cyan)
	addLight(archTop, cyan, 1.2, 24)
	makeNeonPart("SpawnArchLeft", Vector3.new(0.8, 9, 1), Vector3.new(-9, 5.8, 8), Color3.fromRGB(0, 135, 255))
	makeNeonPart("SpawnArchRight", Vector3.new(0.8, 9, 1), Vector3.new(9, 5.8, 8), Color3.fromRGB(0, 135, 255))

	local instructionPanel = makePart("InstructionPanel", Vector3.new(24, 6, 0.7), Vector3.new(0, 6.8, -6), panelBlue)
	instructionPanel.Material = Enum.Material.SmoothPlastic
	addSurfaceText(
		instructionPanel,
		Enum.NormalId.Front,
		"WALK TO THE TABLE  •  PRESS E  •  BEAT THE AI",
		Color3.fromRGB(230, 248, 255),
		Enum.Font.GothamBlack
	)

	local titlePanel = makePart("BackWallTitlePanel", Vector3.new(36, 8, 0.8), Vector3.new(0, 8.5, -45), deepBlue)
	titlePanel.Material = Enum.Material.SmoothPlastic
	addSurfaceText(
		titlePanel,
		Enum.NormalId.Front,
		"BLUE TIC TAC TOE LOUNGE",
		Color3.fromRGB(190, 238, 255),
		Enum.Font.GothamBlack
	)

	for _, x in ipairs({ -20, -12, 12, 20 }) do
		local column =
			makePart(("LightColumn%d"):format(x), Vector3.new(1.6, 13, 1.6), Vector3.new(x, 6.5, -38), deepBlue)
		column.Material = Enum.Material.Metal
		local columnGlow =
			makeNeonPart(("LightColumnGlow%d"):format(x), Vector3.new(2, 0.6, 2), Vector3.new(x, 13.2, -38), cyan)
		addLight(columnGlow, cyan, 1.4, 18)
	end

	for index, data in ipairs({
		{ -30, -18, "STREAKS" },
		{ 30, -18, "SMART AI" },
		{ -30, 7, "FAST REMATCH" },
		{ 30, 7, "FUTURE PVP" },
	}) do
		local panel = makePart(
			("FeaturePanel%d"):format(index),
			Vector3.new(13, 5, 0.7),
			Vector3.new(data[1], 5.5, data[2]),
			panelBlue
		)
		panel.Material = Enum.Material.SmoothPlastic
		panel.Orientation = Vector3.new(0, data[1] < 0 and 22 or -22, 0)
		addSurfaceText(panel, Enum.NormalId.Front, data[3], Color3.fromRGB(219, 246, 255), Enum.Font.GothamBold)
	end

	for index, x in ipairs({ -16, -8, 8, 16 }) do
		local ceilingLight = makeNeonPart(
			("CeilingStrip%d"):format(index),
			Vector3.new(5.5, 0.35, 0.7),
			Vector3.new(x, 15.6, -18),
			Color3.fromRGB(64, 222, 255)
		)
		addLight(ceilingLight, Color3.fromRGB(64, 222, 255), 1.1, 20)
	end

	local spawnPadLabel =
		makePart("SpawnPadLabel", Vector3.new(14, 0.2, 2.4), Vector3.new(0, 0.55, -11), Color3.fromRGB(10, 52, 100))
	spawnPadLabel.Material = Enum.Material.Neon
	addSurfaceText(spawnPadLabel, Enum.NormalId.Top, "START HERE", Color3.fromRGB(235, 252, 255), Enum.Font.GothamBlack)
end

createLoungeDressing()

local function createSeat(name, position, rotationY, color)
	local seat = Instance.new("Seat")
	seat.Name = name
	seat.Anchored = true
	seat.Size = Vector3.new(5, 1, 5)
	seat.Position = position
	seat.Orientation = Vector3.new(0, rotationY, 0)
	seat.Color = color
	seat.Material = Enum.Material.SmoothPlastic
	seat.TopSurface = Enum.SurfaceType.Smooth
	seat.BottomSurface = Enum.SurfaceType.Smooth
	seat.Parent = map

	local backOffset = rotationY == 180 and Vector3.new(0, 3, 3.2) or Vector3.new(0, 3, -3.2)
	local back = makePart(
		("%sBack"):format(name),
		Vector3.new(5.4, 6, 0.8),
		position + backOffset,
		color:Lerp(Color3.fromRGB(0, 0, 0), 0.18)
	)
	back.Orientation = Vector3.new(0, rotationY, 0)
	back.Material = Enum.Material.SmoothPlastic

	return seat
end

local function makeTable()
	local tableTop = makePart("AITicTacToeTable", Vector3.new(28, 1.6, 20), tableCenter, Color3.fromRGB(8, 75, 142))
	tableTop.Material = Enum.Material.SmoothPlastic
	addSurfaceText(tableTop, Enum.NormalId.Top, "AI TIC TAC TOE", Color3.fromRGB(229, 246, 255), Enum.Font.GothamBlack)

	local frontApron = makePart(
		"AITableFrontFace",
		Vector3.new(28.4, 3.4, 1),
		tableCenter + Vector3.new(0, -2.5, 10.5),
		Color3.fromRGB(4, 38, 90)
	)
	frontApron.Material = Enum.Material.SmoothPlastic
	addSurfaceText(
		frontApron,
		Enum.NormalId.Front,
		"AI TIC TAC TOE TABLE",
		Color3.fromRGB(210, 242, 255),
		Enum.Font.GothamBlack
	)

	local backApron = makePart(
		"AITableBackFace",
		Vector3.new(28.4, 3.4, 1),
		tableCenter + Vector3.new(0, -2.5, -10.5),
		Color3.fromRGB(4, 38, 90)
	)
	backApron.Material = Enum.Material.SmoothPlastic

	for _, side in ipairs({ -1, 1 }) do
		local sideApron = makePart(
			("AITableSideFace%d"):format(side),
			Vector3.new(1, 3.4, 20),
			tableCenter + Vector3.new(side * 14.2, -2.5, 0),
			Color3.fromRGB(4, 31, 75)
		)
		sideApron.Material = Enum.Material.SmoothPlastic
	end

	local tableGlow = Instance.new("PointLight")
	tableGlow.Brightness = 1.5
	tableGlow.Color = Color3.fromRGB(0, 190, 255)
	tableGlow.Range = 24
	tableGlow.Parent = tableTop

	for index, offset in ipairs({
		Vector3.new(-11.5, -2.4, -7.5),
		Vector3.new(11.5, -2.4, -7.5),
		Vector3.new(-11.5, -2.4, 7.5),
		Vector3.new(11.5, -2.4, 7.5),
	}) do
		local leg = makePart(
			("TableLeg%d"):format(index),
			Vector3.new(2.3, 4.8, 2.3),
			tableCenter + offset,
			Color3.fromRGB(4, 35, 78)
		)
		leg.Material = Enum.Material.Metal
	end

	local boardBase = makePart(
		"PhysicalBoardBase",
		Vector3.new(13.5, 0.5, 13.5),
		tableCenter + Vector3.new(0, 1.05, 0),
		Color3.fromRGB(3, 19, 46)
	)
	boardBase.Material = Enum.Material.SmoothPlastic

	local startX = -3.8
	local startZ = -3.8
	local spacing = 3.8

	for row = 1, 3 do
		for column = 1, 3 do
			local index = (row - 1) * 3 + column
			local cell = makePart(
				("BoardCell%d"):format(index),
				Vector3.new(3.4, 0.25, 3.4),
				tableCenter + Vector3.new(startX + (column - 1) * spacing, 1.45, startZ + (row - 1) * spacing),
				Color3.fromRGB(8, 52, 104)
			)
			cell.Material = Enum.Material.Neon
			boardCells[index] = cell
			boardLabels[index] = addSurfaceText(cell, Enum.NormalId.Top, "", Color3.fromRGB(231, 246, 255))
		end
	end

	return tableTop
end

local function addPromptToPart(part)
	for _, child in ipairs(part:GetChildren()) do
		if child:IsA("ProximityPrompt") and child.Name == "OpenTicTacToePrompt" then
			child:Destroy()
		end
	end

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "OpenTicTacToePrompt"
	prompt.ActionText = "Play AI"
	prompt.ObjectText = "Blue TicTacToe Table"
	prompt.HoldDuration = 0
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.MaxActivationDistance = 14
	prompt.RequiresLineOfSight = false
	prompt.Parent = part
end

local function useGeneratedScene(scene)
	scene:PivotTo(generatedScenePivot)

	local tableTop = scene:FindFirstChild("TableTop", true)

	if tableTop and tableTop:IsA("BasePart") then
		addPromptToPart(tableTop)
	end

	local oldOverlay = scene:FindFirstChild("LiveBoardOverlay")

	if oldOverlay then
		oldOverlay:Destroy()
	end

	local boardPart = scene:FindFirstChild("BoardInner", true) or scene:FindFirstChild("BoardBase", true)

	if not boardPart or not boardPart:IsA("BasePart") then
		return
	end

	local overlay = Instance.new("Model")
	overlay.Name = "LiveBoardOverlay"
	overlay.Parent = scene

	local boardWidth = math.min(boardPart.Size.X, boardPart.Size.Z)
	local spacing = boardWidth / 3
	local cellSize = math.max(spacing * 0.72, 0.7)

	for row = 1, 3 do
		for column = 1, 3 do
			local index = (row - 1) * 3 + column
			local x = (column - 2) * spacing
			local z = (row - 2) * spacing
			local cell = Instance.new("Part")
			cell.Name = ("LiveBoardCell%d"):format(index)
			cell.Anchored = true
			cell.CanCollide = false
			cell.Color = Color3.fromRGB(5, 29, 70)
			cell.Material = Enum.Material.Neon
			cell.Size = Vector3.new(cellSize, 0.08, cellSize)
			cell.CFrame = boardPart.CFrame * CFrame.new(x, boardPart.Size.Y / 2 + 0.18, z)
			cell.Parent = overlay

			boardCells[index] = cell
			boardLabels[index] = addSurfaceText(cell, Enum.NormalId.Top, "", Color3.fromRGB(231, 246, 255))
		end
	end
end

local function makeBlockFigure(name, position, bodyColor, accentColor)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = map

	local function figurePart(partName, size, offset, color)
		local part = Instance.new("Part")
		part.Name = partName
		part.Anchored = true
		part.Size = size
		part.Position = position + offset
		part.Color = color
		part.Material = Enum.Material.SmoothPlastic
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		part.Parent = model

		return part
	end

	figurePart("Torso", Vector3.new(3, 4, 1.5), Vector3.new(0, 3.9, 0), bodyColor)
	figurePart("Head", Vector3.new(2.2, 2.2, 2.2), Vector3.new(0, 7.1, 0), Color3.fromRGB(238, 217, 180))
	figurePart("LeftArm", Vector3.new(0.9, 3.2, 0.9), Vector3.new(-2.1, 4.2, -0.2), accentColor)
	figurePart("RightArm", Vector3.new(0.9, 3.2, 0.9), Vector3.new(2.1, 4.2, -0.2), accentColor)
	figurePart("LeftLeg", Vector3.new(1, 2.7, 1), Vector3.new(-0.8, 1.5, -1.1), bodyColor)
	figurePart("RightLeg", Vector3.new(1, 2.7, 1), Vector3.new(0.8, 1.5, -1.1), bodyColor)

	local namePlate =
		figurePart("NamePlate", Vector3.new(5, 1.2, 0.25), Vector3.new(0, 8.9, -0.3), Color3.fromRGB(0, 121, 217))
	addSurfaceText(namePlate, Enum.NormalId.Front, "AI OPPONENT", Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold)

	return model
end

if generatedScene then
	useGeneratedScene(generatedScene)
else
	local tableTop = makeTable()
	addPromptToPart(tableTop)

	createSeat("PlayerTicTacToeSeat", tableCenter + Vector3.new(0, -1.6, 12), 180, Color3.fromRGB(12, 94, 168))
	local aiSeat =
		createSeat("AITicTacToeSeat", tableCenter + Vector3.new(0, -1.6, -12), 0, Color3.fromRGB(22, 55, 104))
	aiSeat.Disabled = true

	makeBlockFigure(
		"SeatedAIPlayer",
		aiSeat.Position + Vector3.new(0, 0.1, 1.2),
		Color3.fromRGB(0, 174, 239),
		Color3.fromRGB(16, 220, 255)
	)

	local friendTable = makePart(
		"FriendMatchTablePreview",
		Vector3.new(16, 1, 10),
		Vector3.new(26, 2.8, 12),
		Color3.fromRGB(5, 57, 115)
	)
	friendTable.Material = Enum.Material.SmoothPlastic
	addSurfaceText(
		friendTable,
		Enum.NormalId.Top,
		"2 PLAYER TABLE",
		Color3.fromRGB(210, 242, 255),
		Enum.Font.GothamBold
	)
	createSeat("FriendSeatA", Vector3.new(26, 1.2, 21), 180, Color3.fromRGB(12, 94, 168))
	createSeat("FriendSeatB", Vector3.new(26, 1.2, 3), 0, Color3.fromRGB(12, 94, 168))
end

local function updatePhysicalBoard(board, line, winner)
	local winningSquares = {}

	if line then
		for _, index in ipairs(line) do
			winningSquares[index] = true
		end
	end

	for index, label in ipairs(boardLabels) do
		local mark = board[index]
		local cell = boardCells[index]
		label.Text = mark

		if mark == TicTacToeLogic.playerMark then
			label.TextColor3 = Color3.fromRGB(125, 249, 255)
		elseif mark == TicTacToeLogic.computerMark then
			label.TextColor3 = Color3.fromRGB(255, 99, 146)
		else
			label.TextColor3 = Color3.fromRGB(231, 246, 255)
		end

		if winningSquares[index] then
			cell.Color = winner == TicTacToeLogic.playerMark and Color3.fromRGB(36, 215, 255)
				or Color3.fromRGB(149, 52, 108)
		else
			cell.Color = Color3.fromRGB(8, 52, 104)
		end
	end
end

local function getOrCreateStat(parent, name)
	local stat = parent:FindFirstChild(name)

	if not stat then
		stat = Instance.new("IntValue")
		stat.Name = name
		stat.Value = 0
		stat.Parent = parent
	end

	return stat
end

local function ensureLeaderboard(player)
	local leaderstats = player:FindFirstChild("leaderstats")

	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	getOrCreateStat(leaderstats, "Wins")
	getOrCreateStat(leaderstats, "Streak")
	getOrCreateStat(leaderstats, "BestStreak")
	getOrCreateStat(leaderstats, "Losses")
	getOrCreateStat(leaderstats, "Ties")

	return leaderstats
end

local function resetSession(session)
	session.board = TicTacToeLogic.createBoard()
	session.gameOver = false
	session.scored = false
end

local function ensureSession(player)
	local session = sessions[player]

	if not session then
		session = {
			board = TicTacToeLogic.createBoard(),
			difficulty = "Smart",
			gameOver = false,
			randomGenerator = Random.new(),
			scored = false,
		}

		sessions[player] = session
	end

	return session
end

local function buildState(session, status, winner, line)
	updatePhysicalBoard(session.board, line, winner)

	return {
		board = TicTacToeLogic.cloneBoard(session.board),
		difficulty = session.difficulty,
		gameOver = session.gameOver,
		line = line,
		status = status,
		winner = winner,
	}
end

local function recordResult(player, session, winner)
	if session.scored or not winner then
		return
	end

	local leaderstats = ensureLeaderboard(player)
	local wins = leaderstats:FindFirstChild("Wins")
	local streak = leaderstats:FindFirstChild("Streak")
	local bestStreak = leaderstats:FindFirstChild("BestStreak")
	local losses = leaderstats:FindFirstChild("Losses")
	local ties = leaderstats:FindFirstChild("Ties")

	session.scored = true

	if winner == TicTacToeLogic.playerMark then
		wins.Value += 1
		streak.Value += 1

		if streak.Value > bestStreak.Value then
			bestStreak.Value = streak.Value
		end
	elseif winner == TicTacToeLogic.computerMark then
		losses.Value += 1
		streak.Value = 0
	elseif winner == "Tie" then
		ties.Value += 1
	end
end

local function finishIfNeeded(player, session)
	local winner, line = TicTacToeLogic.checkWinner(session.board)

	if not winner then
		return nil, nil, nil
	end

	session.gameOver = true
	recordResult(player, session, winner)

	if winner == TicTacToeLogic.playerMark then
		return winner, line, "You won. Streak increased."
	elseif winner == TicTacToeLogic.computerMark then
		return winner, line, "Computer won. Hit New Round."
	end

	return winner, line, "Tie game. Hit New Round."
end

Players.PlayerAdded:Connect(function(player)
	ensureLeaderboard(player)
	ensureSession(player)
end)

Players.PlayerRemoving:Connect(function(player)
	sessions[player] = nil
end)

for _, player in Players:GetPlayers() do
	ensureLeaderboard(player)
	ensureSession(player)
end

gameFunction.OnServerInvoke = function(player, action, payload)
	ensureLeaderboard(player)
	local session = ensureSession(player)

	if action == "NewRound" then
		resetSession(session)
		return buildState(session, ("Your turn. Mode: %s."):format(session.difficulty))
	end

	if action == "SetDifficulty" then
		session.difficulty = payload == "Chill" and "Chill" or "Smart"
		resetSession(session)
		return buildState(session, ("Your turn. Mode: %s."):format(session.difficulty))
	end

	if action ~= "Move" then
		return buildState(session, "Unknown action.")
	end

	local move = tonumber(payload)

	if session.gameOver then
		return buildState(session, "Round over. Hit New Round.")
	end

	if not TicTacToeLogic.applyMove(session.board, move, TicTacToeLogic.playerMark) then
		return buildState(session, "Pick an empty square.")
	end

	local winner, line, status = finishIfNeeded(player, session)

	if winner then
		return buildState(session, status, winner, line)
	end

	local computerMove = TicTacToeLogic.chooseComputerMove(session.board, session.difficulty, session.randomGenerator)

	if computerMove then
		TicTacToeLogic.applyMove(session.board, computerMove, TicTacToeLogic.computerMark)
	end

	winner, line, status = finishIfNeeded(player, session)

	if winner then
		return buildState(session, status, winner, line)
	end

	return buildState(session, "Your turn. You are X.")
end
