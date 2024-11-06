//
//  CoordinatorVIew.swift
//  TicTacToe
//
//  Created by Келлер Дмитрий on 30.09.2024.
//

import SwiftUI

struct CoordinatorView: View {
    @ObservedObject var coordinator = Coordinator()
    
    var body: some View {
        ZStack {
            switch coordinator.navigationState {
            case .launchScreen:
                LaunchScreen(coordinator: coordinator)
            case .mainScreen:
                StartView(coordinator: coordinator)
            case .selectGame:
                GameSelectView(coordinator: coordinator)
            case .game:
                GameView(coordinator: coordinator)
            case .setting:
                SettingGameView(coordinator: coordinator)
            case .rules:
                RulesView(coordinator: coordinator)
            case .result(let winner, let playedAgainstAI):
                ResultView(playedAgainstAI: playedAgainstAI, winner: winner, coordinator: coordinator)
            case .leaderboard:
                LeaderboardView(coordinator: coordinator)
            }
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: coordinator.navigationState)
    }
}
