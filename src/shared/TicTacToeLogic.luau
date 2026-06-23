local TicTacToeLogic = {}

TicTacToeLogic.empty = ""
TicTacToeLogic.playerMark = "X"
TicTacToeLogic.computerMark = "O"

TicTacToeLogic.winningLines = {
	{ 1, 2, 3 },
	{ 4, 5, 6 },
	{ 7, 8, 9 },
	{ 1, 4, 7 },
	{ 2, 5, 8 },
	{ 3, 6, 9 },
	{ 1, 5, 9 },
	{ 3, 5, 7 },
}

function TicTacToeLogic.createBoard()
	local board = {}

	for index = 1, 9 do
		board[index] = TicTacToeLogic.empty
	end

	return board
end

function TicTacToeLogic.cloneBoard(board)
	local copy = {}

	for index = 1, 9 do
		copy[index] = board[index]
	end

	return copy
end

function TicTacToeLogic.isValidMove(board, index)
	return type(index) == "number" and index >= 1 and index <= 9 and board[index] == TicTacToeLogic.empty
end

function TicTacToeLogic.applyMove(board, index, mark)
	if not TicTacToeLogic.isValidMove(board, index) then
		return false
	end

	board[index] = mark

	return true
end

function TicTacToeLogic.emptySquares(board)
	local squares = {}

	for index = 1, 9 do
		if board[index] == TicTacToeLogic.empty then
			table.insert(squares, index)
		end
	end

	return squares
end

function TicTacToeLogic.checkWinner(board)
	for _, line in ipairs(TicTacToeLogic.winningLines) do
		local a = line[1]
		local b = line[2]
		local c = line[3]

		if board[a] ~= TicTacToeLogic.empty and board[a] == board[b] and board[a] == board[c] then
			return board[a], line
		end
	end

	if #TicTacToeLogic.emptySquares(board) == 0 then
		return "Tie", nil
	end

	return nil, nil
end

function TicTacToeLogic.findWinningMove(board, mark)
	for _, line in ipairs(TicTacToeLogic.winningLines) do
		local marks = 0
		local emptyIndex = nil

		for _, index in ipairs(line) do
			if board[index] == mark then
				marks += 1
			elseif board[index] == TicTacToeLogic.empty then
				emptyIndex = index
			end
		end

		if marks == 2 and emptyIndex then
			return emptyIndex
		end
	end

	return nil
end

function TicTacToeLogic.firstAvailable(board, list)
	for _, index in ipairs(list) do
		if board[index] == TicTacToeLogic.empty then
			return index
		end
	end

	return nil
end

function TicTacToeLogic.chooseRandomMove(board, randomGenerator)
	local squares = TicTacToeLogic.emptySquares(board)

	if #squares == 0 then
		return nil
	end

	if randomGenerator and randomGenerator.NextInteger then
		return squares[randomGenerator:NextInteger(1, #squares)]
	end

	return squares[math.random(1, #squares)]
end

function TicTacToeLogic.chooseComputerMove(board, difficulty, randomGenerator)
	if difficulty == "Chill" then
		return TicTacToeLogic.chooseRandomMove(board, randomGenerator)
	end

	return TicTacToeLogic.findWinningMove(board, TicTacToeLogic.computerMark)
		or TicTacToeLogic.findWinningMove(board, TicTacToeLogic.playerMark)
		or (board[5] == TicTacToeLogic.empty and 5)
		or TicTacToeLogic.firstAvailable(board, { 1, 3, 7, 9 })
		or TicTacToeLogic.firstAvailable(board, { 2, 4, 6, 8 })
		or TicTacToeLogic.chooseRandomMove(board, randomGenerator)
end

return TicTacToeLogic
