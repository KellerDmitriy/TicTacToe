//
//  GameViewModel.swift
//  TicTacToe
//
//  Created by Келлер Дмитрий on 30.09.2024.
//
import Foundation

@MainActor
final class GameViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published private(set) var gameBoard: [PlayerSymbol?] = []
    @Published var secondsCount = 0
    @Published var timerDisplay = "00:00"
    @Published private(set) var currentState: StateMachine.GameState = .startGame
    
    // MARK: - Private Properties
    private let stateMachine: StateMachine
    private let coordinator: Coordinator
    private var gameManager: GameManager
    private let userManager: UserManager
    private let timerManager: TimerManager
    private let musicManager: MusicManager
    
    private let storageManager = StorageManager.shared
    
    var boardSize: BoardSize
    var gameMode: GameMode
    var level: DifficultyLevel
    
    // MARK: - Computed Properties
    var activePlayer: Player { gameManager.activePlayer }
    var player: Player { gameManager.player }
    var opponent: Player { gameManager.opponent }
    var currentScore: String { "\(player.totalWins) : \(opponent.totalWins)" }
    var winningPattern: [Int]? = nil
    
    // MARK: - Initialization
    init(userManager: UserManager, coordinator: Coordinator) {
        self.coordinator = coordinator
        self.userManager = userManager
        self.timerManager = TimerManager()
        self.musicManager = MusicManager()
        
        // Load game settings
        self.boardSize = storageManager.getSettings().boardSize
        self.gameMode = userManager.gameMode
        self.level = storageManager.getSettings().level
        
        // Initialize game manager and state machine
        self.gameManager = GameManager(boardSize, level, userManager)
        self.stateMachine = StateMachine(initialState: .startGame)
        
        setupGameBindings()
        handleStateChange(.startGame)
    }
    
    private func setupGameBindings() {
        stateMachine.onStateChange = { [weak self] newState in
            self?.handleStateChange(newState)
        }
        
        stateMachine.onToggleActivePlayer = { [weak self] in
            self?.gameManager.togglePlayerActive()
        }
        
        gameManager.onBoardChange = { [weak self] updatedBoard in
            guard let self else { return }
            self.gameBoard = updatedBoard
            self.triggerEvent(.toggleActivePlayer)
            self.triggerEvent(.moveAI)
        }
        
        gameManager.onGameOver = { [weak self] in
            self?.triggerEvent(.gameOver)
        }
        
        timerManager.onTimeChange = { [weak self] newTime in
            DispatchQueue.main.async {
                self?.secondsCount = newTime
                self?.timerDisplay = self?.formattedTime(newTime) ?? "00:00"
            }
        }
        
        timerManager.outOfTime = { [weak self] in
            self?.triggerEvent(.outOfTime)
        }
    }
    
    private func handleStateChange(_ state: StateMachine.GameState) {
        currentState = state
        
        switch state {
        case .startGame:
            gameManager.resetGame()
            musicManager.playMusic()
            timerManager.startTimer()
            stateMachine.handle(event: .refresh)
            
        case .play:
            if gameManager.activePlayer.isAI {
                gameManager.aiMove()
            }
         
        case .gameOver:
            musicManager.stopMusic()
            timerManager.stopTimer()
            winningPattern = gameManager.getWinningPattern()
            updateScore()
            saveGameResults()
            playFinalMusic()
            gameManager.player.totalGameDuration += secondsCount
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.navigateToResultScreen()
            }
        }
    }
    
    func triggerEvent(_ event: StateMachine.GameEvent) {
        stateMachine.handle(event: event)
    }
    
    func processPlayerMove(at position: Int) {
        if stateMachine.currentState == .play {
            if !activePlayer.isAI {
                gameManager.makeMove(at: position)
            }
        }
    }
    
    private func playFinalMusic() {
        musicManager.playSoundFor(.final)
        musicManager.stopMusic()
    }
    
    // MARK: - Navigation
    private func navigateToResultScreen() {
        coordinator.updateNavigationState(action: .showResult(
            winner: gameManager.winner,
            playedAgainstAI: gameMode == .singlePlayer
        ))
    }
    
    // MARK: - Score Management
    private func updateScore() {
        if let winner = gameManager.winner {
            winner == player
            ? userManager.updatePlayerScore()
            : userManager.updateOpponentScore()
        }
        gameManager.updatePlayers()
    }
    
    private func saveGameResults() {
        if let winner = gameManager.winner {
            storageManager.saveLeaderboardRound(
                winner: winner,
                durationRound: secondsCount
            )
        }
        storageManager.saveLeaderboardGame(
            player: player,
            opponent: opponent,
            score: getGameScore(),
            totalDuration: getGameDuration()
        )
    }
    
    //    MARK: - Methods for LiederBoard
    private func getGameScore() -> String {
        let gameScore = ("\(player.totalWins) : \(opponent.totalWins)")
        return gameScore
    }
    
    private func getGameDuration() -> String {
        let gameDuration = "\(player.totalGameDuration) seconds"
        return gameDuration
    }
    
    // MARK: - Helpers
    private func formattedTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
