local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

print(("[Starter Roblox Game] Server running for %s"):format(GameConfig.gameName))

local oldCoinMap = workspace:FindFirstChild("CoinDashMap")

if oldCoinMap then
	oldCoinMap:Destroy()
end

local oldMap = workspace:FindFirstChild("DeskTicTacToeMap")

if oldMap then
	oldMap:Destroy()
end

local map = Instance.new("Folder")
map.Name = "DeskTicTacToeMap"
map.Parent = workspace

local winEvent = ReplicatedStorage:FindFirstChild("TicTacToeWinEvent")

if not winEvent then
	winEvent = Instance.new("RemoteEvent")
	winEvent.Name = "TicTacToeWinEvent"
	winEvent.Parent = ReplicatedStorage
end

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

local function addSurfaceText(part, face, text, textColor)
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Face = face
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surfaceGui.PixelsPerStud = 36
	surfaceGui.Parent = part

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Size = UDim2.fromScale(1, 1)
	label.Text = text
	label.TextColor3 = textColor
	label.TextScaled = true
	label.Parent = surfaceGui
end

local floor = makePart(
	"RoomFloor",
	Vector3.new(GameConfig.arenaHalfSize * 2, 2, GameConfig.arenaHalfSize * 2),
	Vector3.new(0, -1, 0),
	Color3.fromRGB(52, 56, 62)
)
floor.Material = Enum.Material.WoodPlanks

local wallColor = Color3.fromRGB(35, 39, 48)
local wallThickness = 3
local wallHeight = 18
local edge = GameConfig.arenaHalfSize + wallThickness / 2

makePart("BackWall", Vector3.new(GameConfig.arenaHalfSize * 2 + wallThickness * 2, wallHeight, wallThickness), Vector3.new(0, wallHeight / 2 - 1, -edge), wallColor)
makePart("FrontWall", Vector3.new(GameConfig.arenaHalfSize * 2 + wallThickness * 2, wallHeight, wallThickness), Vector3.new(0, wallHeight / 2 - 1, edge), wallColor)
makePart("LeftWall", Vector3.new(wallThickness, wallHeight, GameConfig.arenaHalfSize * 2), Vector3.new(-edge, wallHeight / 2 - 1, 0), wallColor)
makePart("RightWall", Vector3.new(wallThickness, wallHeight, GameConfig.arenaHalfSize * 2), Vector3.new(edge, wallHeight / 2 - 1, 0), wallColor)

local spawnLocation = Instance.new("SpawnLocation")
spawnLocation.Name = "RojoSpawn"
spawnLocation.Anchored = true
spawnLocation.Size = Vector3.new(12, 1, 12)
spawnLocation.Position = Vector3.new(0, 1, 26)
spawnLocation.Color = GameConfig.spawnColor
spawnLocation.Material = Enum.Material.Neon
spawnLocation.Parent = map

local tableTop = makePart("TicTacToeDesk", Vector3.new(20, 1.4, 12), Vector3.new(0, 3, -7), Color3.fromRGB(116, 74, 42))
tableTop.Material = Enum.Material.Wood

local legColor = Color3.fromRGB(84, 50, 28)
local legOffsets = {
	Vector3.new(-8, 1.1, -11),
	Vector3.new(8, 1.1, -11),
	Vector3.new(-8, 1.1, -3),
	Vector3.new(8, 1.1, -3),
}

for index, offset in legOffsets do
	local leg = makePart(("DeskLeg%d"):format(index), Vector3.new(1.2, 4, 1.2), offset, legColor)
	leg.Material = Enum.Material.Wood
end

local boardBase = makePart("DeskBoard", Vector3.new(11, 0.25, 11), Vector3.new(0, 3.85, -7), Color3.fromRGB(20, 23, 29))
boardBase.Material = Enum.Material.SmoothPlastic

local gridColor = Color3.fromRGB(240, 244, 255)

makePart("BoardLineVerticalLeft", Vector3.new(0.25, 0.3, 10.4), Vector3.new(-1.85, 4.05, -7), gridColor)
makePart("BoardLineVerticalRight", Vector3.new(0.25, 0.3, 10.4), Vector3.new(1.85, 4.05, -7), gridColor)
makePart("BoardLineHorizontalTop", Vector3.new(10.4, 0.3, 0.25), Vector3.new(0, 4.06, -8.85), gridColor)
makePart("BoardLineHorizontalBottom", Vector3.new(10.4, 0.3, 0.25), Vector3.new(0, 4.06, -5.15), gridColor)

addSurfaceText(boardBase, Enum.NormalId.Top, "TIC TAC TOE", Color3.fromRGB(255, 255, 255))

local chairSeat = makePart("PlayerChairSeat", Vector3.new(8, 1, 7), Vector3.new(0, 1.8, 5), Color3.fromRGB(60, 92, 130))
chairSeat.Material = Enum.Material.SmoothPlastic

local chairBack = makePart("PlayerChairBack", Vector3.new(8, 8, 1), Vector3.new(0, 5, 8.5), Color3.fromRGB(45, 70, 104))
chairBack.Material = Enum.Material.SmoothPlastic

local prompt = Instance.new("ProximityPrompt")
prompt.Name = "TicTacToePrompt"
prompt.ActionText = "Play"
prompt.ObjectText = "TicTacToe Desk"
prompt.HoldDuration = 0
prompt.KeyboardKeyCode = Enum.KeyCode.E
prompt.MaxActivationDistance = 14
prompt.RequiresLineOfSight = false
prompt.Parent = tableTop

local sign = makePart("DeskSign", Vector3.new(28, 8, 1), Vector3.new(0, 8, -GameConfig.arenaHalfSize + 4), Color3.fromRGB(34, 82, 112))
sign.Material = Enum.Material.SmoothPlastic
addSurfaceText(sign, Enum.NormalId.South, "Walk to the desk and press E to play", Color3.fromRGB(255, 255, 255))

local function addLeaderboard(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local wins = Instance.new("IntValue")
	wins.Name = "TicTacToeWins"
	wins.Value = 0
	wins.Parent = leaderstats
end

Players.PlayerAdded:Connect(function(player)
	if not player:FindFirstChild("leaderstats") then
		addLeaderboard(player)
	end
end)

for _, player in Players:GetPlayers() do
	if not player:FindFirstChild("leaderstats") then
		addLeaderboard(player)
	end
end

winEvent.OnServerEvent:Connect(function(player)
	local leaderstats = player:FindFirstChild("leaderstats")

	if not leaderstats then
		return
	end

	local wins = leaderstats:FindFirstChild("TicTacToeWins")

	if wins then
		wins.Value += 1
	end
end)
