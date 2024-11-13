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
    
    // Инициализация с начальным состоянием
    init(initialState: GameState) {
        self.currentState = initialState
    }
    
    // Метод для обработки события и перехода в новое состояние
    func handle(event: GameEvent) {
        guard let newState = nextState(from: currentState, event: event) else { return }
           
           // Обновляем текущее состояние
           if newState != currentState {
               currentState = newState
               
               // Вызываем колбэк, если он установлен
               onStateChange?(newState)
           }
       }
    
    // Метод, который определяет переход между состояниями. Его нужно переопределить в подклассах.
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
