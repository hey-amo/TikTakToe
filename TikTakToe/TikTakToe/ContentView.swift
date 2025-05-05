//
//  ContentView.swift
//  TikTakToe
//
//  Created by Amarjit on 05/05/2025.
//  :Follows Sean Allen tutorial on https://www.youtube.com/watch?v=MCLiPW2ns2w


import SwiftUI

enum Player: Int, CaseIterable {
    case human, computer
}

struct Move {
    let player: Player // Who made the move?
    let boardIndex: Int // Where on the board was it?
    
    var indicator: String {
        return player == .human ? "xmark" : "circle"
    }
}

// MARK: ViewModel

// #TODO
final class TTTViewModel: ObservableObject {
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible()),
                               GridItem(.flexible()),
    ]
    
    @Published var moves: [Move?] = Array(repeating: nil, count: 9)
    @Published var isGameBoardDisabled: Bool = false
    @Published var alertItem: AlertItem?
    
    // ---
    
    func processPlayerPosition(for position: Int) {
        if isSquareOccupied(in: moves, forIndex: position) {
            return
        }
        moves[position] = Move(player: .human, boardIndex: position)
        
        
        // check for win condition or draw
        if checkWinCondition(for: .human, in: moves) {
            print ("Human wins")
            alertItem = AlertContext.humanWin
            return
        }
        if checkForDraw(in: moves) {
            print ("Draw")
            alertItem = AlertContext.draw
            return
        }
        isGameBoardDisabled = true
        
        // make computer move after 0.5 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            print ("computer makes a move")
            let computerPosition = determineComputerMovePosition(in: moves)
            moves[computerPosition] = Move(player: .computer, boardIndex: computerPosition)
            isGameBoardDisabled = false
            
            // check for win condition or draw
            if checkWinCondition(for: .computer, in: moves) {
                print ("Computer wins")
                alertItem = AlertContext.computerWin
                return
            }
            if checkForDraw(in: moves) {
                print ("Draw")
                alertItem = AlertContext.computerWin
                return
            }
        }
    }
    
    // ---
    
    /// Go through moves array to check each item
    /// If it is the index, return true == occupied square
    func isSquareOccupied(in moves:[Move?], forIndex index: Int) -> Bool {
        return moves.contains(where: {
            $0?.boardIndex == index
        })
    }
    
    // If AI can win, then win
    // If AI cannot win, then block
    // If AI cannot block, take middle square
    // If AI can't take middle square, take random available square
    func determineComputerMovePosition(in moves:[Move?]) -> Int {
        
        // -----
        // #1 - If AI can win, then win:
        /// A collection set of all possible win conditions in tic-tac-toe
        let winPatterns: Set<Set<Int>> = [
            [0,1,2],
            [3,4,5],
            [6,7,8],
            [0,3,6],
            [1,4,7],
            [2,5,8],
            [0,4,8],
            [2,4,6]
        ]
        
        let computerMoves = moves
            .compactMap { $0 }
            .filter { $0.player == .computer }
        
        let computerPositions = Set(computerMoves.map {
            $0.boardIndex
        })
        
        // subtract computerPositions
        for pattern in winPatterns {
            let winPositions = pattern.subtracting(computerPositions)
            if winPositions.count == 1 {
                let isAvailable = !isSquareOccupied(in: moves, forIndex: winPositions.first!)
                if isAvailable { return winPositions.first! }
            }
        }
        
        // -----
        // #2 - Blocking
        
        let humanMoves = moves
            .compactMap { $0 }
            .filter { $0.player == .human }
        
        let humanPositions = Set(humanMoves.map {
            $0.boardIndex
        })
        
        // subtract humanPositions
        for pattern in winPatterns {
            let winPositions = pattern.subtracting(humanPositions)
            if winPositions.count == 1 {
                let isAvailable = !isSquareOccupied(in: moves, forIndex: winPositions.first!)
                if isAvailable { return winPositions.first! }
            }
        }
        
        // -----
        // #3 - Take middle square
        let centerSquare = 4
        if !isSquareOccupied(in: moves, forIndex: centerSquare) {
            return centerSquare
        }
        
        // -----
        // #4 - Take Random square
        var movePosition = Int.random(in: 0..<9)

        while isSquareOccupied(in: moves, forIndex: movePosition) {
            movePosition = Int.random(in: 0..<9)
        }
        return movePosition
    }
    
    func checkWinCondition(for player: Player, in moves: [Move?]) -> Bool {
        
        /// A collection set of all possible win conditions in tic-tac-toe
        let winPatterns: Set<Set<Int>> = [
            [0,1,2],
            [3,4,5],
            [6,7,8],
            [0,3,6],
            [1,4,7],
            [2,5,8],
            [0,4,8],
            [2,4,6]
        ]
        
        let playerMoves = moves
            .compactMap { $0 }
            .filter { $0.player == player }
        
        let playerPositions = Set(playerMoves.map {
            $0.boardIndex
        })
        
        // check subset, to see if there is at least 1 match
        for pattern in winPatterns where pattern.isSubset(of: playerPositions) {
            return true
        }
        
        return false
    }
    
    func checkForDraw(in moves:[Move?]) -> Bool {
        return moves.compactMap{ $0 }.count == 9
    }
    
    func resetGame() {
        print ("Resetting game")
        moves = Array(repeating: nil, count: 9)
    }
}


// MARK: ContentView

struct ContentView: View {
    @StateObject private var viewModel = TTTViewModel()
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer()
                Text("Tik Tac Toe")
                    .font(.title)
                    .fontWeight(.bold)
                LazyVGrid(columns: viewModel.columns, spacing: 5.0) {
                    ForEach(0..<9) { i in
                        ZStack {
                            GameSquareView(proxy: geo)
                            
                            PlayerIndicatorView(systemImageName: viewModel.moves[i]?.indicator ?? "")
                        }
                        .onTapGesture {
                            print("Tapped")
                            viewModel.processPlayerPosition(for: i)
                        }
                    }
                }
                Spacer()
            }
            .disabled(viewModel.isGameBoardDisabled)
            .padding(5)
            .alert(item: $viewModel.alertItem, content: {
                alertItem in
                Alert(title: alertItem.title, message: alertItem.message, dismissButton: .default(alertItem.buttonTitle, action: {
                    viewModel.resetGame()
                    })
                )
            })
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)

    } // end: view
    
}

#Preview {
    ContentView()
}

struct GameSquareView: View {
    var proxy: GeometryProxy
    
    var body: some View {
        Circle()
            .foregroundColor(.red)
            .opacity(0.5)
            .frame(width: ((proxy.size.width / 3) - 15),
                   height: ((proxy.size.height / 3) - 15) )
    }
}

struct PlayerIndicatorView: View {
    var systemImageName: String
    
    var body: some View {
        Image(systemName: self.systemImageName)
            .resizable()
            .frame(width: 40, height: 40)
            .foregroundColor(.white)
    }
}
