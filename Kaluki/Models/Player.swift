//
//  Player.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/21/23.
//

import Foundation
import MultipeerConnectivity
import SwiftUI

class Player: NSObject, Identifiable, ObservableObject {
    // MARK: Lifecycle

    init(role: Role = .none, scoresByRound: [Int: Int] = [:]) {
        peerID = MultipeerNetwork.getPeerIDFromDisplayName(displayName: UserDefaults.displayName.fallbackToDefaults() as! String)
        id = UUID()

        self.role = role
        self.scoresByRound = scoresByRound

        super.init()
    }

    init(fromPlayerInfo playerInfo: PlayerInfo) {
        id = playerInfo.id
        peerID = playerInfo.peerID
        role = playerInfo.role
        scoresByRound = playerInfo.scoresByRound

        super.init()
    }

    deinit {
        print("Deinitializing Player with display name: \(MultipeerNetwork.myPeerID.displayName)")

        MultipeerNetwork.stopNetwork()
    }

    // MARK: Internal

    let id: UUID
    let peerID: MCPeerID

    @Published var role: Role {
        didSet {
            sendPlayerInfoUpdate()
        }
    }

    @Published var scoresByRound: [Int: Int] {
        didSet {
            sendPlayerInfoUpdate()
        }
    }

    var displayName: String {
        return UserDefaults.displayName.fallbackToDefaults() as! String
    }

    var profileImage: UIImage {
        return UserDefaults.profileImage.fallbackToDefaults() as! UIImage
    }

    var info: PlayerInfo {
        return PlayerInfo(fromPlayer: self)
    }

    func update(fromPlayerInfo playerInfo: PlayerInfo) {
        role = playerInfo.role
        scoresByRound = playerInfo.scoresByRound
    }

    func hostGame() {
        role = .host

        MultipeerNetwork.createLobby()
    }

    func joinGame(host _: MCPeerID) {
        role = .guest
    }

    func sendPlayerInfoUpdate() {
        if MultipeerNetwork.lobby == nil {
            return
        }

        do {
            try MultipeerNetwork.lobby?.updateLobbyPlayerInfos(playerInfo: info)
        } catch {
            print("Error sending player info update: \(error)")
        }
    }
}
