//
//  LaunchScreenViewModel.swift
//  TicTacToe
//
//  Created by Келлер Дмитрий on 05.11.2024.
//

import Foundation

final class LaunchScreenViewModel: ObservableObject {
    
    // MARK: - Private Properties
    private let coordinator: Coordinator
    
    // MARK: - Init
    init(coordinator: Coordinator) {
        self.coordinator = coordinator
    }
    
    // MARK: - Navigation
    func startGame() {
        coordinator.updateNavigationState(action: .showMainScreen)
    }
    
}
