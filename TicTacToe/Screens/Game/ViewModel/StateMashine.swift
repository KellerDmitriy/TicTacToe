//
//  StateMashine.swift
//  TicTacToe
//
//  Created by Келлер Дмитрий on 17.10.2024.
//

import Foundation

final class StateMachine {
    // MARK: - State and Event Enums
    enum State {
        case startGame
        case play
        case gameOver
    }
    
    enum GameEvent {
        case refresh
        case move(_ position: Int)
        case moveAI
        case toggleActivePlayer
        case gameOver
        case outOfTime
    }
    
    // MARK: - Properties
    private let gameManager: GameManager
    private let gameMode: GameMode
    
    var currentState: State = .startGame
    
    var player: Player
    var opponent: Player
    var currentPlayer: Player
    
    var winningPattern: [Int]? = nil
    var gameResult: GameResult?
    var boardBlocked = false

    
    // MARK: - Initializer
    init(_ player: Player,_ opponent: Player,_ gameMode: GameMode,_ gameManager: GameManager) {
        self.player = player
        self.opponent = opponent
        self.gameMode = gameMode
        self.gameManager = gameManager
        self.currentPlayer = player
    }

    
    // MARK: - Reducer Logic
    func reduce(state: State, event: GameEvent) -> State {
        currentState = state
        
        switch event {
        case  .refresh:
            self.resetGame()
            
        case .move(let position):
            if !currentPlayer.isAI {
                gameManager.makeMove(at: position, for: currentPlayer)
            }
            
        case .moveAI:
            guard gameMode == .singlePlayer else { return .play }
            
            if currentPlayer.isAI {
                gameManager.aiMove(for: currentPlayer)
            }
            
        case .toggleActivePlayer:
            player.isActive.toggle()
            opponent.isActive = !player.isActive
            currentPlayer = player.isActive ? player : opponent
            return .play
            
        case .outOfTime:
            finishGame()
            return .gameOver
            
        case .gameOver:
            finishGame()
            return .gameOver
        }
        return currentState
    }
    
    // MARK: - Game Reset Methods
    func resetGame() {
        winningPattern = nil
        boardBlocked = false
    }
    
    // MARK: - Finish Game Logic
    private func finishGame() {
        gameResult = gameManager.getGameResult(currentPlayer)
        boardBlocked = true
        winningPattern = gameManager.getWinningPattern()
    }

}
