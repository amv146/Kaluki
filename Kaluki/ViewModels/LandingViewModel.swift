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

        appState.multipeerState.browser?.startBrowsingForPeers()
        appState.multipeerState.browser?.delegate = self
    }

    func joinGame(host browsedPeer: BrowsedPeer) {
        pressed = true

        appState.gameState.joinGame(gameID: browsedPeer.gameID) { _, _ in
            self.pressed = false
            self.isLinkActive = true

            print(self.isLinkActive)
        }
    }

    func startHostingGame() {
        pressed = true

        appState.gameState.createNewGame { _ in
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
        let displayName = info?["displayName"] ?? peerID.displayName
        let gameID = info?["gameID"]
        let id = info?["playerID"]
        print("Found a new peer: \(displayName)")

        if hosts.contains(where: { $0.id.uuidString == id }) { return }
        guard let id, let gameID else { return }

        FirebasePlayer.from(gameID: gameID, firebasePlayerID: id) { player in
            guard let player else { return }
            player.downloadProfileImage { _ in
                let browsedPeer = BrowsedPeer(
                    peerID: peerID,
                    gameID: gameID,
                    player: player
                )

                self.hosts.append(browsedPeer)
                print("Added \(displayName) to the list of hosts")
            }
        }
    }

    func browser(_: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Peer \(peerID.displayName) is lost. Removing...")
    }

    func browser(_: MCNearbyServiceBrowser, didNotStartBrowsingForPeers _: Error) {}
}
