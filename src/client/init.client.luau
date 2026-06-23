local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local leaderstats = player:WaitForChild("leaderstats")
local coins = leaderstats:WaitForChild("Coins")
local wins = leaderstats:WaitForChild("Wins")

print(("[Rojo Starter] %s loaded for %s"):format(GameConfig.gameName, player.Name))

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoinDashHud"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0, 0)
panel.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
panel.BackgroundTransparency = 0.12
panel.BorderSizePixel = 0
panel.Position = UDim2.fromOffset(18, 18)
panel.Size = UDim2.fromOffset(260, 86)
panel.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = panel

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Position = UDim2.fromOffset(14, 8)
title.Size = UDim2.new(1, -28, 0, 26)
title.Text = GameConfig.gameName
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local stats = Instance.new("TextLabel")
stats.BackgroundTransparency = 1
stats.Font = Enum.Font.GothamMedium
stats.Position = UDim2.fromOffset(14, 40)
stats.Size = UDim2.new(1, -28, 0, 32)
stats.TextColor3 = Color3.fromRGB(235, 239, 245)
stats.TextScaled = true
stats.TextXAlignment = Enum.TextXAlignment.Left
stats.Parent = panel

local function updateHud()
	stats.Text = ("Coins: %d / %d   Wins: %d"):format(coins.Value, GameConfig.winningCoins, wins.Value)
end

coins:GetPropertyChangedSignal("Value"):Connect(updateHud)
wins:GetPropertyChangedSignal("Value"):Connect(updateHud)
updateHud()
