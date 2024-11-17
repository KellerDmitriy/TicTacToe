//
//  RoundRow.swift
//  TicTacToe
//
//  Created by Келлер Дмитрий on 10.10.2024.
//

import SwiftUI

struct RoundRow: View {
    @AppStorage("selectedLanguage") private var language = LocalizationService.shared.language
    let round: LeaderboardRound
    
    enum DrawingConstants {
        static let padding: CGFloat = 12
        static let textPadding: CGFloat = 4
    }
    
    var body: some View {
        ShadowedCardView {
            VStack {
                Text(Resources.Text.bestRounds.localized(language))
                    .font(.headline)
                    .padding(.vertical)
                    .foregroundStyle(.basicBlack)
                HStack(spacing: DrawingConstants.padding) {
                    SecondaryPurpleBackgroundView {
                        HStack {
                            Text("\(Resources.Text.winner.localized(language)): \(round.winner.name)")
                                .font(.buttonTitle)
                                .lineLimit(3)
                               
                                .foregroundStyle(.basicBlack)
                                .padding(.leading, DrawingConstants.textPadding)
                            Spacer()
                            Text("\(Resources.Text.time.localized(language)): \(round.durationRound) \(Resources.Text.sec.localized(language))")
                                .font(.number)
                                .foregroundStyle(.basicBlack)
                                .padding(.trailing, DrawingConstants.textPadding)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                }
               
            }
        }
    }
}


