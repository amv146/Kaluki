//
//  MultipeerLobby.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/23/23.
//

import MultipeerConnectivity

protocol MultipeerLobbyDelegate: AnyObject {
    func updatedLobbyInfo(players: [PlayerInfo], round: Int)
}

class MultipeerLobby: NSObject {
    // MARK: Lifecycle

    init(host: MCPeerID) {
        self.host = host

        super.init()

        MultipeerNetwork.session?.delegate = self

        addPlayer(playerInfo: MultipeerNetwork.player.info)
    }

    // MARK: Internal

    var round: Int = 1

    @Published var host: MCPeerID
    var nextHost: MCPeerID?
    weak var delegate: MultipeerLobbyDelegate?

    @Published var players: [PlayerInfo] = [] {
        didSet {
            if shouldAdvanceRound() {
                round += 1
            }

            delegate?.updatedLobbyInfo(players: players, round: round)
        }
    }

    func addPlayer(playerInfo: PlayerInfo) {
        players.append(playerInfo)
    }

    func isHost(playerInfo: PlayerInfo = MultipeerNetwork.player.info) -> Bool {
        return playerInfo.peerID == host
    }

    func removePlayer(peerID: MCPeerID) {
        players.removeAll(where: { $0.peerID == peerID })

        if isHost() {
            sendLobbyInfo(joinedPlayer: nil, players: players)
        }
    }

    func removePlayer(playerInfo: PlayerInfo) {
        players.removeAll(where: { $0.peerID == playerInfo.peerID })

        if isHost() {
            sendLobbyInfo(joinedPlayer: nil, players: players)
        }
    }

    func sendPlayerJoinedLobbyToHost(playerInfo: PlayerInfo) {
        let playerJoinedLobbyMessage = MultipeerNetworkMessage.playerJoinedLobby(PlayerJoinedLobbyMessage(playerInfo: playerInfo))

        do {
            try MultipeerNetwork.send(data: playerJoinedLobbyMessage.encoded(), to: host)
        } catch {
            print("Error: \(error)")
        }
    }

    func sendNewPlayerInfo(playerInfo: PlayerInfo) {
        let newPlayerInfoMessage = MultipeerNetworkMessage.newPlayerInfo(NewPlayerInfoMessage(playerInfo: playerInfo))

        for player in players.filter({ $0.peerID != playerInfo.peerID }) {
            do {
                print("Sending player joined lobby info to \(player.displayName)")
                try MultipeerNetwork.send(data: newPlayerInfoMessage.encoded(), to: player.peerID)
            } catch {
                print("Error: \(error)")
            }
        }
    }

    func sendLobbyInfo(joinedPlayer peerID: MCPeerID?, players: [PlayerInfo]) {
        print(players)
        var playersWithoutImage = self.players

        for i in 0 ..< self.players.count {
            playersWithoutImage[i].archivedProfileImage = nil
        }

        for playerInfo in players {
            var playerInfosDataMessage: MultipeerNetworkMessage

            if peerID != nil && playerInfo.peerID == peerID {
                playerInfosDataMessage = MultipeerNetworkMessage.lobbyInfo(LobbyInfoMessage(playerInfos: self.players, nextHost: MCPeerIDData(peerID: nextHost!), round: round))
            } else {
                playerInfosDataMessage = MultipeerNetworkMessage.lobbyInfo(LobbyInfoMessage(playerInfos: playersWithoutImage, nextHost: MCPeerIDData(peerID: nextHost ?? MultipeerNetwork.player.peerID), round: round))
            }

            do {
                try MultipeerNetwork.send(data: playerInfosDataMessage.encoded(), to: playerInfo.peerID)
            } catch {
                print("Error: \(error)")
            }
        }
    }

    func handleNewPlayerInfo(playerInfo: PlayerInfo) throws {
        if let _ = players.firstIndex(where: { $0.peerID == playerInfo.peerID }) {
            print(MultipeerNetworkError.playerAlreadyInLobby)
        } else {
            addPlayer(playerInfo: playerInfo)
        }

        if isHost() {
            sendNewPlayerInfo(playerInfo: playerInfo)

            sendLobbyInfo(joinedPlayer: playerInfo.peerID, players: [playerInfo])
        }
    }

    func updateLobbyPlayerInfos(playerInfo: PlayerInfo) throws {
        var newPlayerInfo = playerInfo
        newPlayerInfo.archivedProfileImage = playerInfo.archivedProfileImage ?? players.first(where: { $0.peerID == playerInfo.peerID })?.archivedProfileImage

        players = players.filter { $0.peerID != playerInfo.peerID } + [newPlayerInfo]

        if isHost() {
            sendLobbyInfo(joinedPlayer: nil, players: players)
        } else {
            MultipeerNetwork.sendPlayerInfo(to: host, includeProfileImage: false)
        }
    }

    func reconnect() {
        MultipeerNetwork.session?.delegate = self
        MultipeerNetwork.joinLobby(host: host)
    }

    // MARK: Private

    private func shouldAdvanceRound() -> Bool {
        return players.map { $0.scoresByRound.count == round }.allSatisfy { $0 == true }
    }
}

extension MultipeerLobby: MCSessionDelegate {
    func session(_: MCSession, didReceive data: Data, fromPeer _: MCPeerID) {
        do {
            let message = try data.decoded() as MultipeerNetworkMessage

            switch message {
                case let .playerInfo(playerInfoMessage):
                    print("PlayerInfo: \(playerInfoMessage.playerInfo)")
                    try updateLobbyPlayerInfos(playerInfo: playerInfoMessage.playerInfo)

                case let .newPlayerInfo(newPlayerInfoMessage):
                    print("PlayerInfo: \(newPlayerInfoMessage.playerInfo)")
                    do {
                        try handleNewPlayerInfo(playerInfo: newPlayerInfoMessage.playerInfo)

                    } catch {
                        print("Error: \(error)")
                    }

                case let .playerJoinedLobby(playerJoinedLobbyMessage):
                    print("PlayerJoinedLobby: \(playerJoinedLobbyMessage.playerInfo)")

                    do {
                        try handleNewPlayerInfo(playerInfo: playerJoinedLobbyMessage.playerInfo)
                    } catch {
                        print("Error: \(error)")
                    }

                case let .playerLeftLobby(playerLeftLobbyMessage):
                    print("PlayerLeftLobby: \(playerLeftLobbyMessage.playerInfo.peerID)")
                    removePlayer(peerID: playerLeftLobbyMessage.playerInfo.peerID)

                case let .lobbyInfo(lobbyInfoMessage):
                    var players = lobbyInfoMessage.playerInfos

                    nextHost = lobbyInfoMessage.nextHost.peerID

                    for i in 0 ..< players.count {
                        players[i].archivedProfileImage = self.players.first { $0.peerID == players[i].peerID }?.archivedProfileImage ?? players[i].archivedProfileImage
                    }

                    print(players)

                    self.players = players
                default:
                    print("Unknown message")
            }
        } catch {
            print("Error: \(error)")
        }
    }

    func session(_: MCSession, didReceive _: InputStream, withName _: String, fromPeer _: MCPeerID) {
        print("Received stream")
    }

    func session(_: MCSession, didStartReceivingResourceWithName _: String, fromPeer _: MCPeerID, with _: Progress) {
        print("Started receiving resource")
    }

    func session(_: MCSession, didFinishReceivingResourceWithName _: String, fromPeer _: MCPeerID, at _: URL?, withError _: Error?) {
        print("Finished receiving resource")
    }

    func session(_: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
            case .connected:
                print("\(MultipeerNetwork.myPeerID.displayName) connected to: \(peerID.displayName)")

                if !isHost() {
                    print("Sending player info to host")
                    sendPlayerJoinedLobbyToHost(playerInfo: MultipeerNetwork.player.info)
                } else if nextHost == nil {
                    nextHost = peerID
                }

            case .connecting:
                print("Connecting to \(peerID)")
            case .notConnected:
                if peerID == host, let nextHost = nextHost {
                    print("Disconnected from host")

                    let hostIndex = players.firstIndex { $0.peerID == host }!

                    players[hostIndex].role = .guest

                    host = nextHost

                    if host == MultipeerNetwork.player.peerID {
                        MultipeerNetwork.player.role = .host
                        MultipeerNetwork.startAdvertising()

                        self.nextHost = players.first { $0.peerID != host }?.peerID

                        sendLobbyInfo(joinedPlayer: nil, players: players)
                    }
                } else if peerID == nextHost {
                    print("Disconnected from next host")
                    if isHost() {
                        nextHost = players.first { $0.peerID != host }?.peerID
                        print("Next host is \(nextHost!.displayName)")
                        sendLobbyInfo(joinedPlayer: nil, players: players)
                    }
                }

                print("Disconnected from \(peerID)")
            @unknown default:
                print("Unknown state")
        }
    }
}
