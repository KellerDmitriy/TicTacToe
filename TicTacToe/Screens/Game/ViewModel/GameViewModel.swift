//
//  GameViewModel.swift
//  TicTacToe
//
//  Created by Келлер Дмитрий on 30.09.2024.
//
import Foundation
import Combine

@MainActor
final class GameViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published private(set) var gameBoard: [PlayerSymbol?] = []
    @Published var secondsCount = 0
    @Published var timerDisplay = "00:00"
    @Published private(set) var stateMachineState: StateMachine.State
    
    // MARK: - Private Properties
    private let coordinator: Coordinator
    private var gameManager: GameManager
    private let userManager: UserManager
    private let timerManager: TimerManager
    private let musicManager: MusicManager
    private let stateMachine: StateMachine
    
    private let storageManager = StorageManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    var boardSize: BoardSize
    var gameMode: GameMode
    var level: DifficultyLevel
    
    // MARK: - Computed Properties
    var activePlayer: Player { gameManager.activePlayer }
    var player: Player { gameManager.player }
    var opponent: Player { gameManager.opponent }
    var currentScore: String { "\(player.score) : \(opponent.score)" }
    var winningPattern: [Int]? = nil
    
    // MARK: - Initialization
    init(coordinator: Coordinator) {
        self.coordinator = coordinator
        self.userManager = UserManager()
        self.timerManager = TimerManager()
        self.musicManager = MusicManager()
        
        // Load game settings
        self.boardSize = storageManager.getSettings().boardSize
        self.gameMode = userManager.gameMode
        self.level = storageManager.getSettings().level
        
        // Initialize game manager and state machine
        self.gameManager = GameManager(boardSize, level, userManager)
        self.stateMachine = StateMachine(gameManager: gameManager)
        self.stateMachineState = .startGame
        
        setupBindings()
        startGame()
    }
    
    // MARK: - Setup Bindings
    private func setupBindings() {
        gameManager.onBoardChange = { [weak self] updatedBoard in
            DispatchQueue.main.async {
                self?.gameBoard = updatedBoard
            }
        }
        
        timerManager.onTimeChange = { [weak self] newTime in
            DispatchQueue.main.async {
                self?.updateTimer(newTime)
            }
        }
        
        timerManager.outOfTime = { [weak self] in
            self?.stateMachine.handle(event: .outOfTime)
        }
        
        stateMachine.onStateChange = { [weak self] newState in
            guard let self = self else { return }
            self.stateMachineState = newState
            self.handleStateChange()
        }
    }
    
    // MARK: - Handle State Changes
    private func handleStateChange() {
        switch stateMachineState {
        case .startGame:
            musicManager.playMusic()
            timerManager.startTimer()
//            stateMachine.handle(event: .refresh)
            
        case .play:
            if activePlayer.isAI {
                stateMachine.handle(event: .moveAI)
            }
            
        case .gameOver:
            musicManager.stopMusic()
            timerManager.stopTimer()
            winningPattern = gameManager.getWinningPattern()
            updateScore()
            playFinalMusic()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.navigateToResultScreen()
            }
        }
    }
    
    // MARK: - Game Actions
    func playerMove(at position: Int) {
        guard !activePlayer.isAI else { return }
        stateMachine.handle(event: .move(position))
    }
    
    private func startGame() {
        stateMachine.handle(event: .refresh)
    }
    
    private func updateTimer(_ seconds: Int) {
        self.secondsCount = seconds
        timerDisplay = formatTime(seconds)
    }
    
    private func playFinalMusic() {
        musicManager.playSoundFor(.final)
        musicManager.stopMusic()
    }
    
    private func updateScore() {
        if let winner = gameManager.winner {
            winner == player ? userManager.updatePlayerScore() : userManager.updateOpponentScore()
        }
    }
    
    private func navigateToResultScreen() {
        coordinator.updateNavigationState(action: .showResult(
            winner: gameManager.winner,
            playedAgainstAI: gameMode == .singlePlayer
        ))
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
