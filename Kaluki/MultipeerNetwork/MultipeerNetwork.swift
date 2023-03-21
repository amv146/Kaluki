//
//  MultipeerNetwork.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/23/23.
//

import MultipeerConnectivity

class MultipeerNetwork: NSObject {
    // MARK: Lifecycle

    deinit {
        print("Stopping Network")
        MultipeerNetwork.stopNetwork()
    }

    // MARK: Internal

    static var advertiser: MCNearbyServiceAdvertiser?
    static var browser: MCNearbyServiceBrowser?
    static var lobby: MultipeerLobby?
    static var player: Player!
    static var session: MCSession?
    static var lobbiesByPeerID: [MCPeerID: MultipeerLobby] = [:]

    static var myPeerID: MCPeerID! {
        return player.peerID
    }

    static func createLobby() {
        lobby = MultipeerLobby(host: player.peerID)
        lobbiesByPeerID[player.peerID] = lobby

        advertiser?.startAdvertisingPeer()
    }

    static func getPeerIDFromDisplayName(displayName: String) -> MCPeerID {
        let oldDisplayName = UserDefaults.displayName.fallbackToDefaults() as? String
        var peerID = MCPeerID(displayName: displayName)

        let defaults = Foundation.UserDefaults.standard

        if oldDisplayName == displayName {
            if let peerIDData = defaults.data(forKey: "peerID") {
                peerID = (try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(peerIDData) as? MCPeerID) ?? peerID
            }
        } else {
            do {
                let peerIDData = try NSKeyedArchiver.archivedData(withRootObject: peerID, requiringSecureCoding: false)
                defaults.set(peerIDData, forKey: "peerID")
            } catch {
                print("Error: \(error)")
            }
        }

        return peerID
    }

    static func joinLobby(host peerID: MCPeerID) {
        guard peerID != myPeerID else {
            return
        }

        if let lobby = lobby {
            browser?.invitePeer(peerID, to: session!, withContext: nil, timeout: 10)
            lobby.addPlayer(playerInfo: player.info)

            lobbiesByPeerID[peerID] = lobby

            return
        } else if let lobby = lobbiesByPeerID[peerID] {
            self.lobby = lobby
        } else {
            player.scoresByRound.removeAll()
            lobby = MultipeerLobby(host: peerID)
        }

        browser?.invitePeer(peerID, to: session!, withContext: nil, timeout: 10)
    }

    static func leaveLobby() {
        let playerLeftMessage = MultipeerNetworkMessage.playerLeftLobby(PlayerLeftLobbyMessage(playerInfo: player.info))

        do {
            try MultipeerNetwork.send(data: playerLeftMessage.encoded(), to: lobby!.host)
        } catch {
            print("Error: \(error)")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.lobby = nil
            self.session?.disconnect()
            self.stopAdvertising()
        }
    }

    static func send(data: Data, to peer: MCPeerID) {
        // Attempt system that tries to send data 5 times before giving up

        guard let session = session else {
            return
        }

        var attempts = 0
        var successfullySent = false

        let attemptSend = {
            guard session.connectedPeers.contains(peer) else {
                attempts += 1
                return
            }

            do {
                try session.send(data, toPeers: [peer], with: .reliable)
                successfullySent = true
            } catch {
                attempts += 1
            }
        }

        while !successfullySent, attempts < 5 {
            attemptSend()
        }
    }

    static func sendPlayerInfo(to peerID: MCPeerID, includeProfileImage: Bool) {
        var playerInfo = PlayerInfo(fromPlayer: MultipeerNetwork.player)

        if !includeProfileImage {
            playerInfo.archivedProfileImage = nil
        }

        let playerInfoMessage = MultipeerNetworkMessage.playerInfo(PlayerInfoMessage(playerInfo: playerInfo))

        print(playerInfoMessage)

        do {
            try MultipeerNetwork.send(data: playerInfoMessage.encoded(), to: peerID)
        } catch {
            print("Error: \(error)")
        }
    }

    static func startAdvertising() {
        advertiser?.startAdvertisingPeer()
    }

    static func startBrowsing() {
        browser?.startBrowsingForPeers()
    }

    static func startNetwork() {
        player = Player()

        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: {
            var info = [String: String]()
            info["displayName"] = player.displayName
            return info
        }(),
        serviceType: "game")
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: "game")

        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)

        MultipeerNetwork.advertiser?.delegate = instance
        MultipeerNetwork.browser?.delegate = instance
    }

    static func stopAdvertising() {
        advertiser?.stopAdvertisingPeer()
    }

    static func stopBrowsing() {
        browser?.stopBrowsingForPeers()
    }

    static func stopNetwork() {
        MultipeerNetwork.session?.disconnect()
        MultipeerNetwork.advertiser?.stopAdvertisingPeer()
        MultipeerNetwork.browser?.stopBrowsingForPeers()
    }

    // MARK: Private

    private static let instance = MultipeerNetwork()
}

extension MultipeerNetwork: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Error: \(error)")
    }

    func advertiser(_: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer _: MCPeerID, withContext _: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, MultipeerNetwork.session)
    }
}

extension MultipeerNetwork: MCNearbyServiceBrowserDelegate {
    func browser(_: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("Error: \(error)")
    }

    func browser(_: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo _: [String: String]?) {
        print("Found peer: \(peerID)")

//        MultipeerNetwork.joinLobby(host: peerID)
    }

    func browser(_: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer: \(peerID)")
    }
}

extension MCPeerID {
    func encode() -> Data {
        return try! NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }

    static func decode(data: Data) -> MCPeerID {
        return try! NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: data)!
    }
}

class MCPeerIDData: Codable {
    // MARK: Lifecycle

    init(peerID: MCPeerID) {
        self.peerID = peerID
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let peerIDData = try values.decode(Data.self, forKey: .peerID)
        peerID = MCPeerID.decode(data: peerIDData)
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case peerID
    }

    let peerID: MCPeerID

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(peerID.encode(), forKey: .peerID)
    }
}
