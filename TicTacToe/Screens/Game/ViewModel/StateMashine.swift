//
//  StateMashine.swift
//  TicTacToe
//
//  Created by Келлер Дмитрий on 17.10.2024.
//
import Foundation

// MARK: - StateMachine Class
final class StateMachine {
    
    // MARK: - Typealiases
    typealias StateChangeHandler = (GameState) -> Void
    
    // MARK: - Properties
    private(set) var currentState: GameState
    
    // MARK: - Closures
    var onStateChange: StateChangeHandler?
    var onToggleActivePlayer: (() -> Void)?
    
    // MARK: - Initialization
    init(initialState: GameState) {
        self.currentState = initialState
    }
    
    // MARK: - Enums
    enum GameState {
        case startGame
        case play
        case gameOver
    }
    
    enum GameEvent: Equatable {
        case refresh
        case move(_ position: Int)
        case moveAI
        case toggleActivePlayer
        case gameOver
        case outOfTime
    }
    
    // MARK: - Event Handling
    func handle(event: GameEvent) {
        // Handle the toggle event separately
        if event == .toggleActivePlayer {
            onToggleActivePlayer?()
        } else if let newState = nextState(from: currentState, event: event) {
            currentState = newState
            onStateChange?(newState)
        }
    }
    
    // MARK: - State Transition Logic
    private func nextState(from state: GameState, event: GameEvent) -> GameState? {
        switch (state, event) {
        case (.startGame, .refresh):
            return .play
        case (.play, .move), (.play, .moveAI), (.play, .toggleActivePlayer):
            return .play
        case (.play, .gameOver), (.play, .outOfTime):
            return .gameOver
        case (.gameOver, .refresh):
            return .startGame
        default:
            return nil
        }
    }
}
