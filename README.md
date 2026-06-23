# Starter Roblox Game

Starter Roblox project managed with [Rojo](https://rojo.space/) and [Rokit](https://github.com/rojo-rbx/rokit).

## Commands

Install the pinned tools:

```bash
rokit install
```

Start live sync for Roblox Studio:

```bash
rojo serve
```

Build a place file:

```bash
rojo build -o "starter-roblox-game.rbxlx"
```

Run verification without opening Roblox Studio:

```bash
stylua --check src tests
selene src tests
lune run tests/TicTacToeLogic.test.luau
rojo build -o "starter-roblox-game.rbxlx"
```

## Studio Workflow

1. Open Roblox Studio.
2. Open or create a baseplate place.
3. In Studio, open the Rojo plugin.
4. Run `rojo serve` in this folder.
5. In the Rojo plugin, connect to the local server.

After connecting, files under `src/server`, `src/client`, and `src/shared` sync into Studio.

Press Play in Studio and the blue TicTacToe game starts immediately. You play as `X`, the computer plays as `O`, and wins trigger a rainbow glow celebration.

## Folder Map

- `src/server` -> `ServerScriptService.Server`
- `src/client` -> `StarterPlayer.StarterPlayerScripts.Client`
- `src/shared` -> `ReplicatedStorage.Shared`
