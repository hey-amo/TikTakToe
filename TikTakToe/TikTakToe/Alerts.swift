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
