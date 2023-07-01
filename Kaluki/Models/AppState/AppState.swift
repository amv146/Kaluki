//
//  AppState.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/1/23.
//

import SwiftUI

// swiftformat:sort
class AppState: ObservableObject {
    @ObservedObject var gameState: GameState
    @Published var gameStateWillChange: Void = ()

    @ObservedObject var multipeerState: MultipeerState

    static let shared = AppState()

    private init() {
        gameState = GameState()
        multipeerState = MultipeerState()

        gameState.objectWillChange.assign(to: &$gameStateWillChange)
    }
}
