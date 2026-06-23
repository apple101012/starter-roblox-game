local TicTacToeLogic = require("../src/shared/TicTacToeLogic")

local tests = {}

local function test(name, callback)
	table.insert(tests, {
		name = name,
		callback = callback,
	})
end

local function assertEqual(actual, expected, message)
	if actual ~= expected then
		error(
			("%s: expected %s, got %s"):format(message or "assertEqual failed", tostring(expected), tostring(actual)),
			2
		)
	end
end

local function assertTruthy(value, message)
	if not value then
		error(message or "expected value to be truthy", 2)
	end
end

local function boardFromString(value)
	local board = TicTacToeLogic.createBoard()

	for index = 1, 9 do
		local mark = string.sub(value, index, index)

		if mark == "X" or mark == "O" then
			board[index] = mark
		end
	end

	return board
end

test("creates an empty nine-square board", function()
	local board = TicTacToeLogic.createBoard()

	assertEqual(#board, 9, "board length")

	for index = 1, 9 do
		assertEqual(board[index], TicTacToeLogic.empty, ("square %d"):format(index))
	end
end)

test("accepts legal moves and rejects occupied squares", function()
	local board = TicTacToeLogic.createBoard()

	assertTruthy(TicTacToeLogic.applyMove(board, 5, "X"), "center move should apply")
	assertEqual(board[5], "X", "center mark")
	assertEqual(TicTacToeLogic.applyMove(board, 5, "O"), false, "occupied center should reject")
	assertEqual(TicTacToeLogic.applyMove(board, 10, "O"), false, "out of range move should reject")
end)

test("detects row, column, and diagonal wins", function()
	local rowWinner = TicTacToeLogic.checkWinner(boardFromString("XXX......"))
	local columnWinner = TicTacToeLogic.checkWinner(boardFromString("X..X..X.."))
	local diagonalWinner = TicTacToeLogic.checkWinner(boardFromString("X...X...X"))

	assertEqual(rowWinner, "X", "row winner")
	assertEqual(columnWinner, "X", "column winner")
	assertEqual(diagonalWinner, "X", "diagonal winner")
end)

test("detects tie boards", function()
	local winner = TicTacToeLogic.checkWinner(boardFromString("XOXOXXOXO"))

	assertEqual(winner, "Tie", "tie winner")
end)

test("smart AI takes an immediate win", function()
	local board = boardFromString("OO.X.X...")
	local move = TicTacToeLogic.chooseComputerMove(board, "Smart")

	assertEqual(move, 3, "computer winning move")
end)

test("smart AI blocks the player's immediate win", function()
	local board = boardFromString("XX..O....")
	local move = TicTacToeLogic.chooseComputerMove(board, "Smart")

	assertEqual(move, 3, "computer block move")
end)

test("smart AI opens with center when available", function()
	local board = TicTacToeLogic.createBoard()
	local move = TicTacToeLogic.chooseComputerMove(board, "Smart")

	assertEqual(move, 5, "opening move")
end)

test("smart AI chooses a corner after center is taken", function()
	local board = boardFromString("....X....")
	local move = TicTacToeLogic.chooseComputerMove(board, "Smart")

	assertEqual(move, 1, "corner fallback")
end)

test("computer does not move after player wins", function()
	local board = boardFromString("XX..OO...")

	assertTruthy(TicTacToeLogic.applyMove(board, 3, "X"), "player should complete row")

	local winner = TicTacToeLogic.checkWinner(board)
	local move = nil

	if not winner then
		move = TicTacToeLogic.chooseComputerMove(board, "Smart")
	end

	assertEqual(winner, "X", "player should win immediately")
	assertEqual(move, nil, "computer move should not be chosen after player win")
end)

test("tie remains terminal after final player move", function()
	local board = boardFromString("XOXXOOOX.")

	assertTruthy(TicTacToeLogic.applyMove(board, 9, "X"), "final move should apply")

	local winner = TicTacToeLogic.checkWinner(board)

	assertEqual(winner, "Tie", "final full board should tie")
end)

local passed = 0
local failed = 0

for _, entry in ipairs(tests) do
	local ok, err = pcall(entry.callback)

	if ok then
		passed += 1
		print(("PASS %s"):format(entry.name))
	else
		failed += 1
		print(("FAIL %s\n%s"):format(entry.name, err))
	end
end

if failed > 0 then
	error(("%d TicTacToe logic tests failed."):format(failed))
end

print(("All %d TicTacToe logic tests passed."):format(passed))
