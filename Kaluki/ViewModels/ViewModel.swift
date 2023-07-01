//
//  ViewModel.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/3/23.
//

import Combine
import Foundation

class ViewModel: NSObject, ObservableObject {
    @NestedObservableObject var appState = AppState.shared
    @NestedObservableObject var gameState = AppState.shared.gameState

    var multipeerState: MultipeerState {
        appState.multipeerState
    }
}
