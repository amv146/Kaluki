//
//  FirebaseState.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/3/23.
//

import FirebaseCore
import FirebaseFirestore
import Foundation
import MultipeerConnectivity
import SwiftUI

// MARK: - GameDelegate

protocol GameDelegate {
    func game(_ gameID: String, didUpdate players: [FirebasePlayer])
    func game(_ gameID: String, didUpdate round: Int)
}

// MARK: - GameState

public class GameState: NSObject, ObservableObject {
    @NestedObservableObject var currentPlayer: FirebasePlayer
    @Published var players: [FirebasePlayer]?
    @Published var gameID: String?
    @Published var gameRef: DocumentReference?
    @Published var gamePlayersRef: CollectionReference?
    @Published var lastAddedScore: AddedScore?
    @Published var round = 0
    @Published var schneids: [Int: String] = [:]
    var delegate: GameDelegate?
    var gameRefSnapshotListener: ListenerRegistration?
    var gamePlayersRefSnapshotListener: ListenerRegistration?

    override init() {
        currentPlayer = FirebasePlayer(
            displayName: UserDefaults.displayName.getOrDefault(),
            id: UserDefaults.id.getOrDefault(),
            profileImage: UserDefaults.profileImage.getOrDefault()
        )

        super.init()
    }
}
