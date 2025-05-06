//
//  GameView.swift
//  TikTakToe
//
//  Created by Amarjit on 05/05/2025.


import SwiftUI

enum GameState: Int {
    case inProgress, humanWin, computerWin, draw
}

enum Player: Int, CaseIterable {
    case human, computer
    
    var indicator: String {
        return self == .human ? "xmark" : "circle"
    }
}

struct AlertItem: Identifiable {
    let id: UUID
    let title: Text
    let message: Text
    let buttonTitle: Text
}

struct AlertContext {
    static let humanWin = AlertItem(id: UUID(),
                             title: Text("You Win!"),
                             message: Text("You beat the computer. Well done!"),
                             buttonTitle: Text("Play again"))
    
    static let computerWin = AlertItem(id: UUID(),
                             title: Text("You Lost!"),
                             message: Text("Better luck next time"),
                             buttonTitle: Text("Play again"))
    
    static let draw = AlertItem(id: UUID(),
                             title: Text("Draw!"),
                             message: Text("It's a draw"),
                             buttonTitle: Text("Try again"))
}


struct Move {
    let player: Player // Who made the move?
    let boardIndex: Int // Where on the board was it?
}

// MARK: ViewModel

final class TTTViewModel: ObservableObject {
    // Published properties that the view can observe
    @Published var moves: [Move?] = Array(repeating: nil, count: 9)
    @Published var isGameBoardDisabled: Bool = false
    @Published var alertItem: AlertItem?
    
    // Win patterns as a static property (doesn't need to be recreated for each check)
    private static let winPatterns: Set<Set<Int>> = [
        [0, 1, 2], [3, 4, 5], [6, 7, 8],  // Rows
        [0, 3, 6], [1, 4, 7], [2, 5, 8],  // Columns
        [0, 4, 8], [2, 4, 6]              // Diagonals
    ]
    
    // MARK: - Game Logic
    
    /// Process the player's move and then the computer's response
    func processPlayerMove(for position: Int) {
        // If square is occupied, return early
        if isSquareOccupied(at: position) { return }
        
        // Place human move
        moves[position] = Move(player: .human, boardIndex: position)
        
        // Check if human won
        if checkWinCondition(for: .human) {
            alertItem = AlertContext.humanWin
            return
        }
        
        // Check for draw
        if checkForDraw() {
            alertItem = AlertContext.draw
            return
        }
        
        // Disable board during computer's turn
        isGameBoardDisabled = true
        
        // Computer makes a move after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            let computerPosition = self.determineComputerMovePosition()
            self.moves[computerPosition] = Move(player: .computer, boardIndex: computerPosition)
            self.isGameBoardDisabled = false
            
            // Check if computer won
            if self.checkWinCondition(for: .computer) {
                self.alertItem = AlertContext.computerWin
                return
            }
            
            // Check for draw again
            if self.checkForDraw() {
                self.alertItem = AlertContext.draw
                return
            }
        }
    }
    
    /// Reset the game to its initial state
    func resetGame() {
        moves = Array(repeating: nil, count: 9)
    }
    
    // MARK: - Private Helper Methods
    
    /// Check if a position on the board is already occupied
    private func isSquareOccupied(at index: Int) -> Bool {
        return moves.contains { $0?.boardIndex == index }
    }
    
    /// Determine the best move for the computer
    private func determineComputerMovePosition() -> Int {
        // 1. If computer can win, take that move
        if let position = findWinningMove(for: .computer) {
            return position
        }
        
        // 2. If human can win, block that move
        if let position = findWinningMove(for: .human) {
            return position
        }
        
        // 3. Take middle square if available
        let centerSquare = 4
        if !isSquareOccupied(at: centerSquare) {
            return centerSquare
        }
        
        // 4. Take a random available square
        var movePosition = Int.random(in: 0..<9)
        while isSquareOccupied(at: movePosition) {
            movePosition = Int.random(in: 0..<9)
        }
        return movePosition
    }
    
    /// Find a winning move for the specified player
    private func findWinningMove(for player: Player) -> Int? {
        let playerMoves = moves.compactMap { $0 }.filter { $0.player == player }
        let playerPositions = Set(playerMoves.map { $0.boardIndex })
        
        // Check each win pattern to see if player can win with one more move
        for pattern in Self.winPatterns {
            let winPositions = pattern.subtracting(playerPositions)
            
            // If there's just one position left to win and it's available
            if winPositions.count == 1 {
                let position = winPositions.first!
                if !isSquareOccupied(at: position) {
                    return position
                }
            }
        }
        
        return nil
    }
    
    /// Check if the specified player has achieved a winning condition
    private func checkWinCondition(for player: Player) -> Bool {
        let playerMoves = moves.compactMap { $0 }.filter { $0.player == player }
        let playerPositions = Set(playerMoves.map { $0.boardIndex })
        
        // Check if any winning pattern is satisfied
        for pattern in Self.winPatterns where pattern.isSubset(of: playerPositions) {
            return true
        }
        
        return false
    }
    
    /// Check if the game has ended in a draw
    private func checkForDraw() -> Bool {
        return moves.compactMap { $0 }.count == 9
    }
}


// MARK: ContentView

struct GameView: View {
    // Use the view model
    @StateObject private var viewModel = TTTViewModel()
    
    // Grid layout
    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer()
                
                Text("Tic Tac Toe")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                // Game board
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(0..<9) { index in
                        GameSquareView(
                            proxy: geo,
                            index: index,
                            move: viewModel.moves[index]
                        )
                        .padding(10)
                        .onTapGesture {
                            viewModel.processPlayerMove(for: index)
                        }
                    }
                }
                .padding(10)
                
                Spacer()
            }
            .disabled(viewModel.isGameBoardDisabled)
            .padding()
            .alert(item: $viewModel.alertItem) { alertItem in
                Alert(
                    title: alertItem.title,
                    message: alertItem.message,
                    dismissButton: .default(alertItem.buttonTitle) {
                        viewModel.resetGame()
                    }
                )
            }
        }
    }
}

#Preview {
    GameView()
}

// Game squares
struct GameSquareView: View {
    let proxy: GeometryProxy
    let index: Int
    let move: Move?
    
    var body: some View {
        ZStack {
            Circle()
                .fill((move?.player == .human) ? Color.red : Color.black)
                .opacity(0.5)
                .frame(width: squareSize(in: proxy), height: squareSize(in: proxy))
      
            if let move = move {
                Image(systemName: move.player.indicator)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.white)
            }
        }
    }
    
    // Calculate square size based on available space
    private func squareSize(in proxy: GeometryProxy) -> CGFloat {
        return min(
            (proxy.size.width / 4) - 15,
            (proxy.size.height / 4) - 15
        )
    }
}
