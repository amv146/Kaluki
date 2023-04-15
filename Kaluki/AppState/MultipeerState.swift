//
//  MultipeerState.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/3/23.
//

import Foundation
import MultipeerConnectivity

public class MultipeerState: ObservableObject
{
    // MARK: Lifecycle

    init()
    {
        myPeerID = MCPeerID.getPeerIDFromDisplayName(displayName: UserDefaults.displayName.getOrDefault())
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: "game")
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
    }

    // MARK: Internal

    @Published var advertiser: MCNearbyServiceAdvertiser?
    @Published var browser: MCNearbyServiceBrowser?
    @Published var session: MCSession?
    let myPeerID: MCPeerID
}
