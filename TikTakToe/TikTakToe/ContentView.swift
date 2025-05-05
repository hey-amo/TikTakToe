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


struct ContentView: View {
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible()),
                               GridItem(.flexible()),
    ]

    @State private var moves: [Move?] = Array(repeating: nil, count: 9)
    @State private var isHumansTurn: Bool = true
    
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
                            let curPlayer: Player = isHumansTurn ? .human : .computer
                            moves[i] = Move(player: curPlayer, boardIndex: i)
                            isHumansTurn.toggle()
                        }
                    }
                }
                Spacer()
            }.padding(5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)

    }
}

#Preview {
    ContentView()
}
