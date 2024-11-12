//
//  StateMashine.swift
//  TicTacToe
//
//  Created by Келлер Дмитрий on 17.10.2024.
//
import Foundation

final class StateMachine {
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
    
    var onStateChange: ((State) -> Void)?
    private(set) var currentState: State = .startGame {
        didSet {
            onStateChange?(currentState)
        }
    }
    
    private var gameMode: GameMode { gameManager.gameMode }
    
    // MARK: - Initialization
    init(gameManager: GameManager) {
        self.gameManager = gameManager
    }
    
    // MARK: - State Transition
    func handle(event: GameEvent) {
        switch (currentState, event) {
        case (.startGame, .refresh):
            resetGame()
            currentState = .startGame

        case (.play, .move(let position)):
            if !gameManager.player.isAI {
                gameManager.makeMove(at: position)
                currentState = gameManager.isGameOver ? .gameOver : .play
            }

        case (.play, .moveAI):
            guard gameMode == .singlePlayer else { return }
            if gameManager.player.isAI {
                gameManager.aiMove()
                currentState = gameManager.isGameOver ? .gameOver : .play
            }

        case (.play, .toggleActivePlayer):
            gameManager.toggleActivePlayer()
            currentState = .play

        case (.gameOver, .outOfTime):
            currentState = .gameOver
            finishGame()
            
        case (.gameOver, .gameOver):
            currentState = .gameOver
            finishGame()
            
        default:
            break
        }
    }

    // MARK: - Private Methods
    private func resetGame() {
        gameManager.resetGame()
    }
    
    private func finishGame() {
        gameManager.finalizeGameResult()
    }
}
