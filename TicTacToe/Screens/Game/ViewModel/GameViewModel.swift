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
        self.stateMachine = StateMachine(initialState: .startGame)
        
        setupGameBindings()
        triggerEvent(.refresh)
    }
    
    private func setupGameBindings() {
        stateMachine.onStateChange = { [weak self] newState in
            self?.handleStateChange(newState)
        }
        
        gameManager.onBoardChange = { [weak self] updatedBoard in
            guard let self else { return }
            self.gameBoard = updatedBoard
        }
        
        gameManager.onGameOver = { [weak self] in
            self?.triggerEvent(.gameOver)
        }
        
        timerManager.onTimeChange = { [weak self] newTime in
            DispatchQueue.main.async {
                self?.secondsCount = newTime
            }
        }
        
        timerManager.outOfTime = { [weak self] in
            self?.triggerEvent(.outOfTime)
        }
    }
    
    // Метод для обработки изменений состояния
    private func handleStateChange(_ state: StateMachine.GameState) {
        print("Текущее состояние: \(state)")
        currentState = state
        
        switch state {
        case .startGame:
            stateMachine.handle(event: .refresh)
            gameManager.resetGame()
            musicManager.playMusic()
            timerManager.startTimer()
            
        case .play:
            if gameManager.activePlayer.isAI {
                gameManager.aiMove()
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
    
    // Функция для записи событий и изменения состояния
    func triggerEvent(_ event: StateMachine.GameEvent) {
        stateMachine.handle(event: event)
    }
    
    // Пример использования
    func processPlayerMove(at position: Int) {
        if stateMachine.currentState == .play {
            gameManager.makeMove(at: position)
            if gameManager.isGameOver {
                triggerEvent(.gameOver)
            } else {
                triggerEvent(.toggleActivePlayer)
            }
        }
    }
    
    // Пример обработки события по истечении времени
    private func handleOutOfTime() {
        if stateMachine.currentState == .play {
            triggerEvent(.outOfTime)
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
    }
    
    // MARK: - Result Recording
    //       private func recordRoundResult() {
    //           let resultString = "\(player.name) : \(player.score) - \(opponent.name) : \(opponent.score) (Duration: \(totalGameDuration) seconds)"
    //           roundResults.append(resultString)
    //       }
    
}
