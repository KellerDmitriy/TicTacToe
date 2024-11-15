//
//  GameManager.swift
//  TicTacToe
//
//  Created by Келлер Дмитрий on 29.09.2024.
//

import Foundation

final class GameManager {
    
    // MARK: - Properties
    private(set) var gameBoard: [PlayerSymbol?] = []
    private(set) var isGameOver: Bool = false
    private let userManager: UserManager
    
    var player: Player
    var opponent: Player
    
    var winner: Player? = nil
    
    var boardSize: BoardSize
    var level: DifficultyLevel
    var gameMode: GameMode { userManager.gameMode }
    
    var onBoardChange: (([PlayerSymbol?]) -> Void)?
    var onGameOver: (() -> Void)?
    
    var activePlayer: Player {
        return player.isActive ? player : opponent
    }
    
    // MARK: - Initialization
    init(_ boardSize: BoardSize,_ level: DifficultyLevel,_ userManager: UserManager) {
        self.userManager = userManager
        
        self.boardSize = boardSize
        self.level = level
        
        self.player = userManager.getPlayer()
        self.opponent = userManager.getOpponent()
        randomizeCurrentActivePlayer()
    }
    
    // MARK: - Game Reset
    func resetGame() {
        let totalCells = boardSize.dimension * boardSize.dimension
        self.gameBoard = Array(repeating: nil, count: totalCells)
        self.winner = nil
        self.isGameOver = false
        randomizeCurrentActivePlayer()
        onBoardChange?(self.gameBoard)
    }
    
    func updatePlayers() {
        self.player = userManager.getPlayer()
        self.opponent = userManager.getOpponent()
    }
    
    // MARK: - Toggle Active Player
    func togglePlayerActive() {
        player.isActive.toggle()
        opponent.isActive = !player.isActive
    }
    
    private func randomizeCurrentActivePlayer() {
        let isPlayerActive = Bool.random()
        player.isActive = isPlayerActive
        opponent.isActive = !isPlayerActive
    }
    
    
    // MARK: - Perform Move
    func makeMove(at position: Int) {
        guard isValidMove(at: position) else { return }
        gameBoard[position] = activePlayer.symbol
        evaluateGameState()
        onBoardChange?(self.gameBoard)
    }
    
    // MARK: - AI Move
    func aiMove() {
        guard !isGameOver else { return }
        if activePlayer.isAI {
            aiDecision(for: activePlayer) { [weak self] move in
                guard let self = self, let move = move else { return }
                self.makeMove(at: move)
            }
        }
    }
    
    // MARK: - Game Result and Pattern
    func getGameResult() -> GameResult {
        if let winner = winner {
            return .win(name: winner.name)
        } else {
            return .draw
        }
    }
    
    // MARK: - Check Winning Patterns
    func getWinningPattern() -> [Int]? {
        for combination in winningCombinations {
            if combination.allSatisfy({ gameBoard[$0] != nil && gameBoard[$0] == gameBoard[combination[0]] }) {
                return combination
            }
        }
        return nil
    }
    
    // MARK: - Private Methods
    private func aiDecision(for aiPlayer: Player, completion: @escaping (Int?) -> Void) {
        let opponentSymbol = self.opponentSymbol(for: aiPlayer.symbol)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let move: Int?
            switch self.level {
            case .easy:
                move = self.findFirstAvailableMove()
            case .normal:
                move = self.findCenterMove()
                ?? self.findWinningMove(for: opponentSymbol)
                ?? self.findFirstAvailableMove()
            case .hard:
                move = self.findWinningMove(for: opponentSymbol)
                ?? self.findWinningMove(for: aiPlayer.symbol)
                ?? self.findCenterMove()
                ?? self.findCornerMove()
                ?? self.findFirstAvailableMove()
            }
            completion(move)
        }
    }
    
    // MARK: - Winning/Available Moves Helpers
    private func opponentSymbol(for aiSymbol: PlayerSymbol) -> PlayerSymbol {
        return aiSymbol == .x ? .o : .x
    }
    
    private func findWinningMove(for symbol: PlayerSymbol) -> Int? {
        for pattern in winningCombinations {
            let values = pattern.map { gameBoard[$0] }
            if values.filter({ $0 == symbol }).count == boardSize.dimension - 1,
               let emptyIndex = pattern.first(where: { gameBoard[$0] == nil }) {
                return emptyIndex
            }
        }
        return nil
    }
    
    private func findFirstAvailableMove() -> Int? {
        return gameBoard.firstIndex(where: { $0 == nil })
    }
    
    private func findCenterMove() -> Int? {
        let centerIndex = (gameBoard.count - 1) / 2
        return gameBoard[centerIndex] == nil ? centerIndex : nil
    }
    
    private func findCornerMove() -> Int? {
        let size = boardSize.dimension
        let corners = [0, size - 1, gameBoard.count - size, gameBoard.count - 1]
        return corners.first(where: { gameBoard[$0] == nil })
    }
    
    
    private func performAIMove(at position: Int) {
        gameBoard[position] = activePlayer.symbol
    }
    
    private func isValidMove(at position: Int) -> Bool {
        return position >= 0 && position < gameBoard.count && gameBoard[position] == nil && !isGameOver
    }
    
    private func evaluateGameState() {
        if checkWin(for: activePlayer.symbol) {
            winner = activePlayer
            isGameOver = true
            onGameOver?()
        } else if isBoardFull() {
            isGameOver = true
            onGameOver?()
        }
    }
    
    private func checkWin(for symbol: PlayerSymbol) -> Bool {
        return winningCombinations.contains { pattern in
            pattern.allSatisfy { gameBoard[$0] == symbol }
        }
    }
    
    private func isBoardFull() -> Bool {
        return gameBoard.allSatisfy { $0 != nil }
    }
    
    private var winningCombinations: [[Int]] {
        let size = boardSize.dimension
        var combinations: [[Int]] = []
        
        for row in 0..<size {
            let start = row * size
            combinations.append(Array(start..<(start + size)))
        }
        
        for col in 0..<size {
            var combination: [Int] = []
            for row in 0..<size {
                combination.append(row * size + col)
            }
            combinations.append(combination)
        }
        
        var diagonal1: [Int] = []
        var diagonal2: [Int] = []
        for i in 0..<size {
            diagonal1.append(i * size + i)
            diagonal2.append(i * size + (size - i - 1))
        }
        combinations.append(diagonal1)
        combinations.append(diagonal2)
        
        return combinations
    }
    
    func finalizeGameResult() {
        if getWinningPattern() != nil {
            winner = activePlayer
            isGameOver = true
            onGameOver?()
        } else if isBoardFull() {
            isGameOver = true
            onGameOver?()
        }
        lockBoard()
    }
    
    private func lockBoard() {
        print("Игра завершена. Блокировка доски.")
    }
}
