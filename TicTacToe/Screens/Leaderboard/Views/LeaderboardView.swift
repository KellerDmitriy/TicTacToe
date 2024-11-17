//
//  LeaderboardView.swift
//  TicTacToe
//
//  Created by Мария Нестерова on 01.10.2024.
//

import SwiftUI

struct LeaderboardView: View {
    @StateObject var viewModel: LeaderboardViewModel
    @AppStorage("selectedLanguage") private var language = LocalizationService.shared.language
    @State private var showCustomAlert = false
    
    struct Drawing {
        static let headerBottomPadding: CGFloat = 20
        static let roundsSectionTopPadding: CGFloat = 30
        static let gamesSectionTopPadding: CGFloat = 20
        static let roundsSectionBottomPadding: CGFloat = 10
        static let gamesSectionBottomPadding: CGFloat = 10
        static let sectionSpacing: CGFloat = 20
        static let cornerRadius: CGFloat = 30
    }
    
    init(coordinator: Coordinator) {
        self._viewModel = StateObject(wrappedValue: LeaderboardViewModel(coordinator: coordinator))
    }
    
    var body: some View {
        ZStack {
            Color.basicBackground
                .ignoresSafeArea()
            VStack(spacing: 0) {
                HeaderView()
                if viewModel.bestGames.isEmpty && viewModel.bestRound == nil {
                    EmptyLeaderboardView()
                } else {
                    VStack {
                        if viewModel.bestRound != nil {
                            BestRoundsSection()
                                .padding(.top, 5)
                        }
                        if !viewModel.bestGames.isEmpty {
                            BestGamesSection()
                                .padding(.top, Drawing.gamesSectionTopPadding)
                                .frame(maxHeight: .infinity)
                                .layoutPriority(0.1)
                        }
                    }
                    .padding(.bottom, Drawing.roundsSectionBottomPadding)
                    .padding(.horizontal, 21)
                }
            }
            .blur(radius: showCustomAlert ? 5 : 0)
            if showCustomAlert {
                CustomAlertView(
                    message: Resources.Text.leaderboardWarning.localized(language),
                    onDismiss: {
                        withAnimation(.easeInOut) {
                            showCustomAlert = false
                            viewModel.deleteAll()
                        }
                    },
                    showSecondButton: true,
                    secondButtonAction: {
                        withAnimation(.easeInOut) {
                            showCustomAlert = false
                        }
                    }
                )
                .frame(width: 300, height: 400)
                .background(Color.basicBlack.opacity(0.4).edgesIgnoringSafeArea(.all))
                .cornerRadius(Drawing.cornerRadius)
                .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                .zIndex(2)
            }
        }
    }

    private func HeaderView() -> some View {
        ToolBarView(
            showBackButton: true,
            backButtonAction: { viewModel.dismissLeaderboard() },
            showRightButton: true,
            rightButtonAction: { showCustomAlert = true },
            rightButtonImage: .crossPink,
            title: Resources.Text.leaderboard.localized(language)
        )
        .padding(.horizontal)
        .padding(.bottom, Drawing.headerBottomPadding)
    }

    private func BestRoundsSection() -> some View {
        VStack(spacing: Drawing.roundsSectionBottomPadding) {
            if let bestRound = viewModel.bestRound {
                RoundRow(round: bestRound)
                
            }
        }
        .padding(.bottom, Drawing.roundsSectionBottomPadding)
    }

    private func BestGamesSection() -> some View {
        ShadowedCardView {
                VStack(spacing: Drawing.gamesSectionBottomPadding) {
                    Text(Resources.Text.bestGames.localized(language))
                        .font(.headline)
                        .foregroundStyle(.basicBlack)
                        .padding(.vertical)
                    ScrollView {
                        ForEach(0..<viewModel.bestGames.count, id: \.self) { index in
                            GameRow(game: viewModel.bestGames[index], rank: index + 1)
                        }
                    }
                    .padding(.bottom, Drawing.gamesSectionBottomPadding)
                }
            
            
        }
    }
}

#Preview {
    LeaderboardView(coordinator: Coordinator())
}
