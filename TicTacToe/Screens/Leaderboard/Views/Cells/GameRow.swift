//
//  GameRow.swift
//  TicTacToe
//
//  Created by Келлер Дмитрий on 10.10.2024.
//

import SwiftUI

struct GameRow: View {
    // MARK: - Properties
    @AppStorage("selectedLanguage") private var language = LocalizationService.shared.language
    
    // MARK: - Drawing Constants
    enum Drawing {
        static let circleSize: CGFloat = 38
        static let imageSize: CGFloat = 20
        static let spacing: CGFloat = 4
        static let horizontalPadding: CGFloat = 4
        static let dividerOpacity: CGFloat = 0.6
    }
    
    let game: LeaderboardGame
    let rank: Int
    
    // MARK: - Computed Properties
    private var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        return dateFormatter.string(from: game.date)
    }
    
    // MARK: - Body
    var body: some View {
        LightBlueBackgroundView {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.secondaryPurple)
                        .frame(width: Drawing.circleSize, height: Drawing.circleSize)
                    Text("\(rank)")
                        .font(.number)
                        .foregroundStyle(.basicBlack)
                }
                VStack(alignment: .leading) {
                    playerInfoRow
                    Divider()
                        .background(Color.gray.opacity(Drawing.dividerOpacity))
                    durationRow
                }
            }
            .layoutPriority(0.1)
        }
    }
    
    // MARK: - Subviews
    private var playerInfoRow: some View {
        HStack {
            HStack(spacing: Drawing.spacing) {
                playerImage(for: game.player)
                playerName(game.player.name)
                Text(" / ")
                    .font(.basicSubtitle)
                    .foregroundStyle(.basicBlack)
                playerImage(for: game.opponent)
                playerName(game.opponent.name)
            }
            Spacer()
            scoreAndDate
        }
    }
    
    private var durationRow: some View {
        Text("\(Resources.Text.duration.localized(language)): \(game.player.totalGameDuration) \(Resources.Text.sec.localized(language))")
            .font(.basicSubtitleMini)
            .padding(.horizontal, Drawing.horizontalPadding)
            .foregroundStyle(.basicBlack)
    }
    
    private var scoreAndDate: some View {
        VStack {
            Text("\(game.score)")
                .font(.basicSubtitle)
                .padding(.horizontal, Drawing.horizontalPadding)
                .foregroundStyle(.basicBlack)
            Text("\(formattedDate)")
                .font(.caption)
                .padding(.horizontal, Drawing.horizontalPadding)
                .foregroundStyle(.basicBlue)
        }
    }
    
    // MARK: - Helpers
    private func playerImage(for player: Player) -> some View {
        Image(player.symbol == .x ? player.style.imageNames.player1 : player.style.imageNames.player2)
            .resizable()
            .frame(width: Drawing.imageSize, height: Drawing.imageSize)
            .scaledToFit()
            .padding(.leading, Drawing.horizontalPadding)
    }
    
    private func playerName(_ name: String) -> some View {
        Text(name)
            .font(.basicSubtitle)
            .foregroundStyle(.basicBlack)
            .multilineTextAlignment(.center)
    }
}
