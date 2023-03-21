//
//  BrowsedPeer.swift
//  MultipeerChat
//
//  Created by Hesham Salama on 7/26/20.
//  Copyright © 2020 Hesham Salama. All rights reserved.
//
import MultipeerConnectivity
import SwiftUI

struct BrowsedPeer: Identifiable {
    // MARK: Lifecycle

    init(peerID: MCPeerID, displayName: String) {
        self.peerID = peerID
        self.displayName = displayName
    }

    // MARK: Internal

    enum Status: String {
        case connected
        case connecting
        case available

        // MARK: Internal

        var description: String {
            switch self {
                case .connected:
                    return ""
                case .connecting:
                    return "Connecting..."
                case .available:
                    return ""
            }
        }
    }

    let peerID: MCPeerID
    let displayName: String
    private(set) var id = UUID()

    var currentStatus: Status = .available {
        willSet {
            // workaround for a bug in SwiftUI for not updating rows content because of ID
            id = UUID()
        }
    }
}

extension BrowsedPeer: CustomStringConvertible {
    var description: String {
        return "Peer: \(peerID.displayName), status: \(currentStatus)"
    }
}
