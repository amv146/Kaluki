//
//  ViewModel.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/3/23.
//

import Combine
import Foundation

class ViewModel: NSObject, ObservableObject
{
    @Published var appState = AppState.shared
    @Published var gameState = AppState.shared.gameState
    @Published private var gameStateWillChange: Void = ()

    override init()
    {
        super.init()

        gameState.objectWillChange.assign(to: &$gameStateWillChange)
    }
}
