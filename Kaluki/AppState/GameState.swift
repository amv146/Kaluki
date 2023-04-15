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
    //    func game(_ gameID: String, didUpdate playerInfo: [PlayerInfo])
}

// MARK: - GameState

public class GameState: NSObject, ObservableObject {
    @Published var advertiser: MCNearbyServiceAdvertiser?
    @NestedObservableObject var currentPlayer: FirebasePlayer
    @Published var players: [FirebasePlayer]?
    @Published var gameID: String?
    @Published var gameRef: DocumentReference?
    @Published var gamePlayersRef: CollectionReference?
    @Published var round = 0
    let browser: MCNearbyServiceBrowser?
    var delegate: GameDelegate?
    var gameRefSnapshotListener: ListenerRegistration?
    var gamePlayersRefSnapshotListener: ListenerRegistration?
    let myPeerID: MCPeerID
    let session: MCSession?

    override init() {
        let displayName = UserDefaults.displayName.getOrDefault()
        myPeerID = MCPeerID.getPeerIDFromDisplayName(displayName: displayName)
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: "game")
        session = MCSession(
            peer: myPeerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )

        currentPlayer = FirebasePlayer(
            displayName: displayName,
            id: UserDefaults.id.getOrDefault(),
            profileImage: UserDefaults.profileImage.getOrDefault()
        )

        super.init()
    }

    deinit {
        self.advertiser?.stopAdvertisingPeer()
        self.browser?.stopBrowsingForPeers()
        self.session?.disconnect()
    }
}

// MARK: MCNearbyServiceAdvertiserDelegate

/**
 * Multipeer
 */
extension GameState: MCNearbyServiceAdvertiserDelegate {
    public func advertiser(
        _: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer _: MCPeerID,
        withContext _: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        invitationHandler(true, session)
    }

    func startAdvertisingGame(gameID: String) {
        advertiser = MCNearbyServiceAdvertiser(
            peer: myPeerID,
            discoveryInfo: {
                [
                    "displayName": currentPlayer.displayName,
                    "playerID": currentPlayer.id,
                    "gameID": gameID,
                ]
            }(),
            serviceType: "game"
        )

        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }

    func stopAdvertisingGame() {
        advertiser?.stopAdvertisingPeer()
    }
}
