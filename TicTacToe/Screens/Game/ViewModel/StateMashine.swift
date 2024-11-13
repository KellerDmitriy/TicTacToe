//
//  StateMashine.swift
//  TicTacToe
//
//  Created by Келлер Дмитрий on 17.10.2024.
//
import Foundation

final class StateMachine {
    typealias StateChangeHandler = (GameState) -> Void
  
    private(set) var currentState: GameState
    
    var onStateChange: StateChangeHandler?
    var onToggleActivePlayer: (() -> Void)?
    
    enum GameState {
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
    
    init(initialState: GameState) {
        self.currentState = initialState
    }
    

    func handle(event: GameEvent) {
        switch event {
        case .toggleActivePlayer:
            onToggleActivePlayer?()
            
        default:
            if let newState = nextState(from: currentState, event: event) {
                currentState = newState
                onStateChange?(newState)
            }
        }
    }

    func nextState(from state: GameState, event: GameEvent) -> GameState? {
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
