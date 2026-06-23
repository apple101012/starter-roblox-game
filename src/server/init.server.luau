local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

print(("[Rojo Starter] Server running for %s"):format(GameConfig.gameName))

local map = workspace:FindFirstChild("CoinDashMap")

if map then
	map:Destroy()
end

map = Instance.new("Folder")
map.Name = "CoinDashMap"
map.Parent = workspace

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

local floor = makePart(
	"Arena",
	Vector3.new(GameConfig.arenaHalfSize * 2, 2, GameConfig.arenaHalfSize * 2),
	Vector3.new(0, -1, 0),
	Color3.fromRGB(45, 48, 56)
)
floor.Material = Enum.Material.Slate

local function makeWall(name, size, position)
	local wall = makePart(name, size, position, Color3.fromRGB(25, 28, 35))
	wall.Material = Enum.Material.Concrete
end

local wallThickness = 4
local wallHeight = 18
local edge = GameConfig.arenaHalfSize + wallThickness / 2

makeWall("NorthWall", Vector3.new(GameConfig.arenaHalfSize * 2 + wallThickness * 2, wallHeight, wallThickness), Vector3.new(0, wallHeight / 2 - 1, -edge))
makeWall("SouthWall", Vector3.new(GameConfig.arenaHalfSize * 2 + wallThickness * 2, wallHeight, wallThickness), Vector3.new(0, wallHeight / 2 - 1, edge))
makeWall("EastWall", Vector3.new(wallThickness, wallHeight, GameConfig.arenaHalfSize * 2), Vector3.new(edge, wallHeight / 2 - 1, 0))
makeWall("WestWall", Vector3.new(wallThickness, wallHeight, GameConfig.arenaHalfSize * 2), Vector3.new(-edge, wallHeight / 2 - 1, 0))

local spawnLocation = Instance.new("SpawnLocation")
spawnLocation.Name = "RojoSpawn"
spawnLocation.Anchored = true
spawnLocation.Size = Vector3.new(14, 1, 14)
spawnLocation.Position = Vector3.new(0, 1, 0)
spawnLocation.Color = GameConfig.spawnColor
spawnLocation.Material = Enum.Material.Neon
spawnLocation.Parent = map

local function addLeaderboard(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = 0
	coins.Parent = leaderstats

	local wins = Instance.new("IntValue")
	wins.Name = "Wins"
	wins.Value = 0
	wins.Parent = leaderstats
end

Players.PlayerAdded:Connect(addLeaderboard)

for _, player in Players:GetPlayers() do
	if not player:FindFirstChild("leaderstats") then
		addLeaderboard(player)
	end
end

local coinsFolder = Instance.new("Folder")
coinsFolder.Name = "Coins"
coinsFolder.Parent = map

local randomGenerator = Random.new()
local coinDebounces = {}

local function randomCoinPosition()
	local padding = 16
	local x = randomGenerator:NextInteger(-GameConfig.arenaHalfSize + padding, GameConfig.arenaHalfSize - padding)
	local z = randomGenerator:NextInteger(-GameConfig.arenaHalfSize + padding, GameConfig.arenaHalfSize - padding)

	return Vector3.new(x, 3, z)
end

local function moveCoin(coin)
	coin.Position = randomCoinPosition()
	coin.Transparency = 0
	coin.CanTouch = true
end

local function getPlayerFromHit(hit)
	local character = hit:FindFirstAncestorOfClass("Model")

	if not character then
		return nil
	end

	return Players:GetPlayerFromCharacter(character)
end

local function awardCoin(player)
	local leaderstats = player:FindFirstChild("leaderstats")

	if not leaderstats then
		return
	end

	local coins = leaderstats:FindFirstChild("Coins")
	local wins = leaderstats:FindFirstChild("Wins")

	if not coins or not wins then
		return
	end

	coins.Value += GameConfig.coinValue

	if coins.Value >= GameConfig.winningCoins then
		coins.Value = 0
		wins.Value += 1
	end
end

local function createCoin(index)
	local coin = Instance.new("Part")
	coin.Name = ("Coin%02d"):format(index)
	coin.Shape = Enum.PartType.Ball
	coin.Size = Vector3.new(3, 3, 3)
	coin.Anchored = true
	coin.CanCollide = false
	coin.Color = Color3.fromRGB(255, 205, 70)
	coin.Material = Enum.Material.Neon
	coin.Parent = coinsFolder

	local light = Instance.new("PointLight")
	light.Brightness = 1.5
	light.Color = coin.Color
	light.Range = 12
	light.Parent = coin

	moveCoin(coin)

	coin.Touched:Connect(function(hit)
		local player = getPlayerFromHit(hit)

		if not player or coinDebounces[coin] then
			return
		end

		coinDebounces[coin] = true
		coin.CanTouch = false
		coin.Transparency = 1
		awardCoin(player)

		task.delay(1.25, function()
			moveCoin(coin)
			coinDebounces[coin] = nil
		end)
	end)
end

for index = 1, GameConfig.coinCount do
	createCoin(index)
end

local sign = makePart("GoalSign", Vector3.new(28, 12, 1), Vector3.new(0, 8, -GameConfig.arenaHalfSize + 5), Color3.fromRGB(32, 80, 120))
sign.Material = Enum.Material.SmoothPlastic

local surfaceGui = Instance.new("SurfaceGui")
surfaceGui.Face = Enum.NormalId.South
surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
surfaceGui.PixelsPerStud = 32
surfaceGui.Parent = sign

local signText = Instance.new("TextLabel")
signText.BackgroundTransparency = 1
signText.Font = Enum.Font.GothamBold
signText.Size = UDim2.fromScale(1, 1)
signText.Text = ("Collect %d coins to score a win"):format(GameConfig.winningCoins)
signText.TextColor3 = Color3.fromRGB(255, 255, 255)
signText.TextScaled = true
signText.Parent = surfaceGui
	spawnLocation = Instance.new("SpawnLocation")
	spawnLocation.Name = "RojoSpawn"
	spawnLocation.Anchored = true
	spawnLocation.Size = Vector3.new(12, 1, 12)
	spawnLocation.Position = Vector3.new(0, 1, 0)
	spawnLocation.Parent = workspace
end

spawnLocation.Color = GameConfig.spawnColor
