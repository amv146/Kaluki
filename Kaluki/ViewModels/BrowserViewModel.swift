//
//  Browsing.swift
//  MultipeerChat
//
//  Created by Hesham Salama on 3/18/20.
//  Copyright © 2020 Hesham Salama. All rights reserved.
//
import MultipeerConnectivity

// MARK: - BrowserViewModel

class BrowserViewModel: ViewModel {
    @Published var hosts: [BrowsedPeer]
    var action: (_ peer: BrowsedPeer) -> Void

    init(hosts: [BrowsedPeer], action: @escaping (_ peer: BrowsedPeer) -> Void) {
        self.hosts = hosts
        self.action = action

        super.init()
    }

    func peerClicked(browsedPeer: BrowsedPeer) {
        if isPeerAvailableToConnect(peerID: browsedPeer.peerID) {
            print("Inviting \(browsedPeer.peerID.displayName) to session")

            action(browsedPeer)
        }
    }

    private func isPeerAvailableToConnect(peerID: MCPeerID) -> Bool {
        guard let browsedPeer = (hosts.first { $0.peerID == peerID })
        else {
            return false
        }
        return browsedPeer.currentStatus == .available
    }
}

// MARK: MCSessionDelegate

extension BrowserViewModel: MCSessionDelegate {
    func session(_: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
                case .notConnected:
                    print("Failed to connect to \(peerID.displayName)")

                case .connecting:
                    print("Connecting to \(peerID.displayName)")

                case .connected:
                    print("Connected to \(peerID.displayName)")

                @unknown default:
                    break
            }
        }
    }

    func session(_: MCSession, didReceive _: Data, fromPeer peerID: MCPeerID) {
        print("Browser - Received data from \(peerID.displayName)")
    }

    func session(
        _: MCSession,
        didReceive _: InputStream,
        withName _: String,
        fromPeer _: MCPeerID
    ) {}

    func session(
        _: MCSession,
        didStartReceivingResourceWithName _: String,
        fromPeer _: MCPeerID,
        with _: Progress
    ) {}

    func session(
        _: MCSession,
        didFinishReceivingResourceWithName _: String,
        fromPeer _: MCPeerID,
        at _: URL?,
        withError _: Error?
    ) {}
}
