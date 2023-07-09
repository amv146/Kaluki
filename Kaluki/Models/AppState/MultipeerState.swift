//
//  MultipeerState.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/3/23.
//

import Foundation
import MultipeerConnectivity

public class MultipeerState: NSObject, ObservableObject
{
    @Published var advertiser: MCNearbyServiceAdvertiser?
    @Published var browser: MCNearbyServiceBrowser?
    @Published var session: MCSession?
    let myPeerID: MCPeerID
    
    // MARK: Lifecycle

    override init()
    {
        myPeerID = MCPeerID.getPeerIDFromDisplayName(displayName: UserDefaults.displayName.getOrDefault())
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: "game")
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        
        super.init()
    }

    
    deinit {
        self.advertiser?.stopAdvertisingPeer()
        self.browser?.stopBrowsingForPeers()
        self.session?.disconnect()
    }
}

extension MultipeerState: MCNearbyServiceAdvertiserDelegate {
    public func advertiser(
        _: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer _: MCPeerID,
        withContext _: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        invitationHandler(true, session)
    }
    
    func startAdvertisingGame(gameID: String, player: FirebasePlayer) {
        
        advertiser = MCNearbyServiceAdvertiser(
            peer: myPeerID,
            discoveryInfo: try? GameDiscoveryInfo(gameID: gameID, playerID: player.id).dictionary() as? [String: String],
            serviceType: "game"
        )
        
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }
    
    func stopAdvertisingGame() {
        advertiser?.stopAdvertisingPeer()
    }
}
