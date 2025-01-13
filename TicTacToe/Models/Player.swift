//
//  Player.swift
//  TicTacToe
//
//  Created by Келлер Дмитрий on 29.09.2024.
//

import Foundation

// MARK: - Player Struct
struct Player: Equatable, Codable {
    let id: UUID
    var name: String
    var symbol: PlayerSymbol
    var style: PlayerStyle
    var isActive: Bool
    var isAI: Bool
    var totalWins: Int = 0
    var totalGameDuration: Int = 0
    var totalLosses: Int = 0

    
    // MARK: - Initializer
    init(name: String, score: Int, symbol: PlayerSymbol, style: PlayerStyle, isActive: Bool = false, isAI: Bool = false) {
        self.id = UUID()
        self.totalWins = score
        self.name = name
        self.symbol = symbol
        self.style = style
        self.isActive = isActive
        self.isAI = isAI
    }
}

// MARK: - LeaderboardRound Struct
struct LeaderboardRound: Codable, Equatable {
    let id: UUID
    let winner: Player
    let date: Date
    let durationRound: Int

    // MARK: - Initializer
    init(winner: Player, durationRound: Int) {
        self.id = UUID()
        self.winner = winner
        self.durationRound = durationRound
        self.date = Date()
    }
}

// MARK: - LeaderboardGame Struct
struct LeaderboardGame: Codable, Identifiable {
    let id: UUID
    let player: Player
    let opponent: Player
    let score: String
    let date: Date

    // MARK: - Initializer
    init(player: Player, opponent: Player, score: String) {
        self.id = UUID()
        self.player = player
        self.opponent = opponent
        self.score = score
        self.date = Date()
    }
}
