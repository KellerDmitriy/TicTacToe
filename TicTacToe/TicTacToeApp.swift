import SwiftUI

@main
struct TicTacToeApp: App {
    
    //MARK: - Main Code
    var body: some Scene {
        WindowGroup {
            CoordinatorView()
                .padding(.all)
        }
    }
}
