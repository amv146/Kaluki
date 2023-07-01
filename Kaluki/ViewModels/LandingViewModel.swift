import MultipeerConnectivity
import PhotosUI
import SwiftUI

// MARK: - LandingViewModel

// swiftformat:sort
class LandingViewModel: ViewModel {
    @Published var displayName: String {
        didSet {
            UserDefaults.displayName.set(value: displayName)
            appState.gameState.currentPlayer.displayName = displayName
        }
    }

    @Published var hosts: [BrowsedPeer] = []
    @Published var isLinkActive = false
    @Published var pressed = false

    override init() {
        displayName = UserDefaults.displayName.getOrDefault()

        super.init()

        multipeerState.browser?.delegate = self
    }

    func joinGame(host browsedPeer: BrowsedPeer) {
        pressed = true

        gameState.joinGame(gameID: browsedPeer.gameID) { _, _ in
            self.pressed = false
            self.isLinkActive = true

            print(self.isLinkActive)
        }
    }

    func startHostingGame() {
        pressed = true

        gameState.createNewGame { gameID in
            self.multipeerState.startAdvertisingGame(gameID: gameID, player: self.gameState.currentPlayer)
            self.pressed = false
            self.isLinkActive = true
        }
    }
}

// MARK: MCNearbyServiceBrowserDelegate

extension LandingViewModel: MCNearbyServiceBrowserDelegate {
    func browser(
        _: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String: String]?
    ) {
        guard let info, let gameDiscoveryInfo = try? GameDiscoveryInfo(dict: info) else { return }
        print("Found peer \(gameDiscoveryInfo.playerID)")

        if hosts.contains(where: { $0.id.uuidString == gameDiscoveryInfo.playerID }) { return }

        FirebasePlayer.from(gameID: gameDiscoveryInfo.gameID, playerID: gameDiscoveryInfo.playerID) { player in
            guard let player else { return }
            player.downloadProfileImage { _ in
                let browsedPeer = BrowsedPeer(
                    peerID: peerID,
                    gameID: gameDiscoveryInfo.gameID,
                    player: player
                )

                self.hosts.append(browsedPeer)
            }
        }
    }

    func browser(_: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Peer \(peerID.displayName) is lost. Removing...")
        
        self.hosts.removeAll(where: { $0.peerID == peerID })
    }

    func browser(_: MCNearbyServiceBrowser, didNotStartBrowsingForPeers _: Error) {}
}
