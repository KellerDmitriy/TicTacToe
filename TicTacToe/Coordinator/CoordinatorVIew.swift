//
//  CoordinatorVIew.swift
//  TicTacToe
//
//  Created by Келлер Дмитрий on 30.09.2024.
//

import SwiftUI

struct CoordinatorView: View {
    @ObservedObject var coordinator = Coordinator()
    @AppStorage("themeMode") private var themeMode: ThemeMode = .system
    
    let userManager = UserManager()
    
    var body: some View {
        ZStack {
            switch coordinator.navigationState {
            case .launchScreen:
                LaunchScreen(coordinator: coordinator)
            case .mainScreen:
                StartView(coordinator: coordinator)
            case .selectGame:
                GameSelectView(userManager: userManager, coordinator: coordinator)
            case .game:
                GameView(userManager: userManager, coordinator: coordinator)
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
        .preferredColorScheme(themeMode.colorScheme)
 
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: coordinator.navigationState)
    }
}
