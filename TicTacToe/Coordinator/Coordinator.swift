//
//  Coordinator.swift
//  TicTacToe
//
//  Created by Келлер Дмитрий on 30.09.2024.
//

import Foundation

// MARK: - Coordinator

final class Coordinator: ObservableObject {
    // MARK: - Published Properties
    @Published var navigationState: NavigationState = .launchScreen
    
    // MARK: - Private Properties
    private var previousState: NavigationState = .mainScreen
    
    // MARK: - Dependencies
    var userManager: UserManager = UserManager()
    
    // MARK: - NavigationState Enum
    enum NavigationState: Equatable {
        case launchScreen
        case mainScreen
        case selectGame
        case game
        case setting
        case rules
        case result(winner: Player?, playedAgainstAI: Bool)
        case leaderboard
    }
    
    // MARK: - CoordinatorAction Enum
    enum CoordinatorAction {
        case showLaunchScreen
        case showMainScreen
        case selectGame
        case startGame
        case showSettings
        case showRules
        case showResult(winner: Player?, playedAgainstAI: Bool)
        case leaderboard
        case backFromSettings
    }
    
    // MARK: - Navigation Reducer
    private func reduce(_ state: NavigationState, action: CoordinatorAction) -> NavigationState {
        var newState = state
        
        switch action {
        case .showLaunchScreen:
            newState = .launchScreen
        case .showMainScreen:
            resetUserManager()
            newState = .mainScreen
        case .selectGame:
            newState = .selectGame
        case .startGame:
            newState = .game
        case .showSettings:
            previousState = state
            newState = .setting
        case .showRules:
            newState = .rules
        case .showResult(let winner, let playedAgainstAI):
            newState = .result(winner: winner, playedAgainstAI: playedAgainstAI)
        case .leaderboard:
            newState = .leaderboard
        case .backFromSettings:
            newState = previousState
        }
        return newState
    }
    
    // MARK: - Navigation Updates
    func updateNavigationState(action: CoordinatorAction) {
        Task {
            await MainActor.run {
                navigationState = reduce(navigationState, action: action)
            }
        }
    }
    
    // MARK: - User Manager Reset
    func resetUserManager() {
        userManager = UserManager()
    }
}
