//
//  Alerts.swift
//  TikTakToe
//
//  Created by Amarjit on 05/05/2025.
//

import SwiftUI
import Foundation

struct AlertItem: Identifiable {
    let id: UUID
    let title: Text
    let message: Text
    let buttonTitle: Text
}

struct AlertContext {
    static let humanWin = AlertItem(id: UUID(),
                             title: Text("Human win"),
                             message: Text("You won"),
                             buttonTitle: Text("Play again"))
    
    static let computerWin = AlertItem(id: UUID(),
                             title: Text("Computer win"),
                             message: Text("You lost"),
                             buttonTitle: Text("Play again"))
    
    static let draw = AlertItem(id: UUID(),
                             title: Text("It's a draw"),
                             message: Text("It's a draw"),
                             buttonTitle: Text("Play again"))
}
