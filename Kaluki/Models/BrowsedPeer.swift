//
//  BrowsedPeer.swift
//  MultipeerChat
//
//  Created by Hesham Salama on 7/26/20.
//  Copyright © 2020 Hesham Salama. All rights reserved.
//
import MultipeerConnectivity
import SwiftUI

struct BrowsedPeer: Identifiable
{
    let gameID: String
    let peerID: MCPeerID
    let player: FirebasePlayer

    private(set) var id = UUID()

    var currentStatus: Status = .available
    {
        willSet
        {
            // workaround for a bug in SwiftUI for not updating rows content because of ID
            id = UUID()
        }
    }

    init(peerID: MCPeerID, gameID: String, player: FirebasePlayer)
    {
        self.peerID = peerID
        self.gameID = gameID
        self.player = player
    }

    enum Status: String
    {
        case connected
        case connecting
        case available

        var description: String
        {
            switch self
            {
            case .connected:
                return ""
            case .connecting:
                return "Connecting..."
            case .available:
                return ""
            }
        }
    }

}

extension BrowsedPeer: CustomStringConvertible
{
    var description: String
    {
        "Peer: \(peerID.displayName), status: \(currentStatus)"
    }
}
