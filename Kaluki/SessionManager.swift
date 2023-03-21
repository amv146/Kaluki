//
//  SessionManager.swift
//  MultipeerChat
//
//  Created by Hesham Salama on 3/22/20.
//  Copyright © 2020 Hesham Salama. All rights reserved.
//
import MultipeerConnectivity

class SessionManager: NSObject {
    static let shared = SessionManager()
    private var sessions = [MCSession]()
    
    override private init() {}
    
    var newSession: MCSession {
        let peerID = MultipeerNetwork.myPeerID
        
        print("Creating new session with peerID: \(peerID!.displayName)")
        
        if let session = sessions.first(where: {
            $0.connectedPeers.isEmpty || ($0.connectedPeers.count == 1 && $0.connectedPeers.first == peerID)
        }) {
            return session
        } else {
            sessions.append(MultipeerNetwork.session!)
            return MultipeerNetwork.session!
        }
    }
    
    func getMutualSession(with peerID: MCPeerID) -> MCSession? {
        let session = sessions.first {
            $0.connectedPeers.contains(peerID)
        }
        return session
    }
    
    func removeAllSessions() {
        sessions.forEach { session in
            session.delegate = nil
        }
        sessions = []
    }
}
