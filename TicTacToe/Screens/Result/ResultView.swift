//
//  ResultView.swift
//  TicTacToe
//
//  Created by Келлер Дмитрий on 30.09.2024.
//

import SwiftUI

struct ResultView: View {
    @AppStorage("selectedLanguage") private var language = LocalizationService.shared.language
    @StateObject var viewModel: ResultViewModel
    
    init(playedAgainstAI: Bool, winner: Player?, coordinator: Coordinator) {
        self._viewModel = StateObject(wrappedValue: ResultViewModel(coordinator: coordinator, winner: winner, playedAgainstAI: playedAgainstAI))
    }
    var body: some View {
        ZStack {
            Color.basicBackground.ignoresSafeArea(.all)
            VStack {
                Spacer()
                switch viewModel.gameResult {
                case .win(let name):
                    Text(name + " " + Resources.Text.winResult.localized(language))
                        .font(.basicTitle)
                        .padding(10)
                    Image(.winIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.horizontal, 60)
                case .lose:
                    Text(Resources.Text.loseResult.localized(language))
                        .font(.basicTitle)
                        .padding(10)
                    Image(.loseIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.horizontal, 60)
                case .draw:
                    Text(Resources.Text.drawResult.localized(language))
                        .font(.basicTitle)
                        .padding(10)
                    Image(.drawIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.horizontal, 60)
                }
                Spacer()
                BasicButton(
                    styleType: .primary,
                    title: Resources.Text.playAgain.localized(language),
                    tapHandler: viewModel.restartGame
                )
                BasicButton(
                    styleType: .secondary,
                    title: Resources.Text.back.localized(language),
                    tapHandler: viewModel.openLaunch
                )
            }
            .padding(.horizontal, 21)
        }
    }
}

#Preview {
    ResultView(
        playedAgainstAI: true ,
        winner: Player(name: Resources.Text.ai, score: 0, symbol: .x, style: .burgerFries),
        coordinator: Coordinator()
    )
}
