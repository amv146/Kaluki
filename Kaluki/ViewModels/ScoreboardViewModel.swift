//
//  ScoreboardViewModel.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/22/23.
//

import Foundation
import MultipeerConnectivity

class ScoreboardViewModel: NSObject, ObservableObject, MultipeerLobbyDelegate {
    // MARK: Lifecycle

    override init() {
        players = [MultipeerNetwork.player.info]
        host = MultipeerNetwork.lobby?.host

        super.init()

        MultipeerNetwork.lobby?.delegate = self
    }

    // MARK: Internal

    @Published var players: [PlayerInfo]
    @Published var round: Int = 1

    var host: MCPeerID?

    var player: Player {
        return MultipeerNetwork.player.self
    }

    func canAddScore() -> Bool {
        return MultipeerNetwork.player.scoresByRound.count < round
    }

    func updatedLobbyInfo(players: [PlayerInfo], round: Int) {
        DispatchQueue.global().async {
            DispatchQueue.main.sync {
                self.players = players.sorted(by: { PlayerInfo1, PlayerInfo2 in
                    PlayerInfo1.scoresByRound.values.reduce(0, +) < PlayerInfo2.scoresByRound.values.reduce(0, +)
                })

                self.round = round
            }
        }
    }

    func addScore(score: Int) {
        // Display text box for the player to enter the score to send using SwiftUI
        let lastRound = MultipeerNetwork.player.scoresByRound.count
        MultipeerNetwork.player.scoresByRound[lastRound] = score
    }
}
