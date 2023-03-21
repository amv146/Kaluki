//
//  Browsing.swift
//  MultipeerChat
//
//  Created by Hesham Salama on 3/18/20.
//  Copyright © 2020 Hesham Salama. All rights reserved.
//
import MultipeerConnectivity

class BrowserViewModel: NSObject, ObservableObject {
    // MARK: Lifecycle

    init(browser: MCNearbyServiceBrowser, session: MCSession, action: @escaping (_ peer: MCPeerID) -> Void) {
        self.browser = browser
        self.session = session
        self.action = action

        super.init()
    }

    // MARK: Internal

    @Published var browsedPeers = [BrowsedPeer]()
    @Published var didNotStartBrowsing = false
    @Published var couldntConnect = false
    var startErrorMessage = ""
    var couldntConnectMessage = ""

    var action: (_ peer: MCPeerID) -> Void

    var availableAndConnectingPeers: [BrowsedPeer] {
        return browsedPeers.filter { $0.currentStatus == .available || $0.currentStatus == .connecting }
    }

    var connectedPeers: [BrowsedPeer] {
        return browsedPeers.filter { $0.currentStatus == .connected }
    }

    func stopBrowsing() {
        print("Browsing has stopped")
        browser.delegate = nil
        browser.stopBrowsingForPeers()
    }

    func startBrowsing() {
        print("Browsing has started")
        browser.delegate = self
        browser.startBrowsingForPeers()
    }

    func peerClicked(browsedPeer: BrowsedPeer) {
        if isPeerAvailableToConnect(peerID: browsedPeer.peerID) {
            print("Inviting \(browsedPeer.peerID.displayName) to session")

            action(browsedPeer.peerID)
            MultipeerNetwork.joinLobby(host: browsedPeer.peerID)
        }
    }

    // MARK: Private

    private let browser: MCNearbyServiceBrowser
    private let invitationTimeout: TimeInterval = 60.0
    private let session: MCSession

    private func isPeerAvailableToConnect(peerID: MCPeerID) -> Bool {
        guard let browsedPeer = (browsedPeers.first { $0.peerID == peerID }) else {
            return false
        }
        return browsedPeer.currentStatus == .available
    }

    private func removeUnavailablePeer(peerID: MCPeerID) {
        browsedPeers.removeAll {
            $0.peerID == peerID
        }
    }

    private func decidePeerStatus(_ peer: BrowsedPeer) {
        if SessionManager.shared.getMutualSession(with: peer.peerID) != nil {
            setStatus(for: peer.peerID, status: .connected)
        } else {
            setStatus(for: peer.peerID, status: .available)
        }
    }

    private func setStatus(for peerID: MCPeerID, status: BrowsedPeer.Status) {
        guard let index = (browsedPeers.firstIndex {
            $0.peerID == peerID
        }) else {
            print("Couldn't find peerID: \(peerID.displayName), so couldn't set its status")
            return
        }
        print("Set peer status of \(peerID.displayName) to \(status)")
        browsedPeers[index].currentStatus = status
    }

    private func showCouldntConnectError(failedToConnectPeer: MCPeerID) {
        couldntConnectMessage = "Couldn't connect to \(failedToConnectPeer.displayName)"
        couldntConnect = true
    }
}

extension BrowserViewModel: MCNearbyServiceBrowserDelegate {
    func browser(_: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        let displayName = info?["displayName"] ?? peerID.displayName
        print("Found a new peer: \(displayName)")

        if browsedPeers.contains(where: { $0.peerID == peerID }) {
            return
        }

        let browsedPeer = BrowsedPeer(peerID: peerID, displayName: displayName)
        browsedPeers.append(browsedPeer)
        decidePeerStatus(browsedPeer)
    }

    func browser(_: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Peer \(peerID.displayName) is lost. Removing...")
        removeUnavailablePeer(peerID: peerID)
    }

    func browser(_: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        startErrorMessage = error.localizedDescription
        didNotStartBrowsing = true
    }
}

extension BrowserViewModel: MCSessionDelegate {
    func session(_: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async { [weak self] in
            switch state {
                case .notConnected:
                    print("Failed to connect to \(peerID.displayName)")
                    self?.showCouldntConnectError(failedToConnectPeer: peerID)
                    self?.setStatus(for: peerID, status: .available)
                case .connecting:
                    print("Connecting to \(peerID.displayName)")
                    self?.setStatus(for: peerID, status: .connecting)
                case .connected:
                    print("Connected to \(peerID.displayName)")
                    self?.setStatus(for: peerID, status: .connected)
                @unknown default:
                    break
            }
        }
    }

    func session(_: MCSession, didReceive _: Data, fromPeer peerID: MCPeerID) {
        print("Browser - Received data from \(peerID.displayName)")
    }

    func session(_: MCSession, didReceive _: InputStream, withName _: String, fromPeer _: MCPeerID) {}

    func session(_: MCSession, didStartReceivingResourceWithName _: String, fromPeer _: MCPeerID, with _: Progress) {}

    func session(_: MCSession, didFinishReceivingResourceWithName _: String, fromPeer _: MCPeerID, at _: URL?, withError _: Error?) {}
}
