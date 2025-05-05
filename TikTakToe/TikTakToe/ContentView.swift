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

// #TODO
struct TTT_ViewModel {}


struct ContentView: View {
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible()),
                               GridItem(.flexible()),
    ]

    @State private var moves: [Move?] = Array(repeating: nil, count: 9)
    @State private var isGameBoardDisabled: Bool = false
    @State private var alertItem: AlertItem?
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer()
                Text("Tik Tac Toe")
                    .font(.title)
                    .fontWeight(.bold)
                LazyVGrid(columns: columns, spacing: 5.0) {
                    ForEach(0..<9) { i in
                        ZStack {
                            Circle()
                                .foregroundColor(.red)
                                .opacity(0.5)
                                .frame(width: ((geo.size.width / 3) - 15),
                                       height: ((geo.size.height / 3) - 15) )
                            Image(systemName: moves[i]?.indicator ?? "")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                                
                        }
                        .onTapGesture {
                            print("Tapped")
                            if isSquareOccupied(in: moves, forIndex: i) {
                                return
                            }
                            moves[i] = Move(player: .human, boardIndex: i)
                            
                            
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
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
                    }
                }
                Spacer()
            }
            .disabled(isGameBoardDisabled)
            .padding(5)
            .alert(item: $alertItem, content: {
                alertItem in
                Alert(title: alertItem.title, message: alertItem.message, dismissButton: .default(alertItem.buttonTitle, action: {
                        resetGame()
                    })
                )
            })
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)

    } // end: view
    
    /// Go through moves array to check each item
    /// If it is the index, return true == occupied square
    func isSquareOccupied(in moves:[Move?], forIndex index: Int) -> Bool {
        return moves.contains(where: {
            $0?.boardIndex == index
        })
    }
    
    func determineComputerMovePosition(in moves:[Move?]) -> Int {
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
        
        // remove all nils and get player passed in
        let playerMoves = moves
            .compactMap { $0 }
            .filter { $0.player == player }
        
        // get me a set of integers from player moves
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

#Preview {
    ContentView()
}
