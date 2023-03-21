//
//  SentData.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/23/23.
//

import MultipeerConnectivity

let jsonEncoder = JSONEncoder()

struct PlayerInfoMessage: Codable {
    var playerInfo: PlayerInfo
}

struct NextHostMessage: Codable {
    var nextHost: MCPeerIDData
}

struct LobbyInfoMessage: Codable {
    var playerInfos: [PlayerInfo]
    var nextHost: MCPeerIDData
    var round: Int
}

struct NewPlayerInfoMessage: Codable {
    var playerInfo: PlayerInfo
}

struct PlayerJoinedLobbyMessage: Codable {
    var playerInfo: PlayerInfo
}

struct PlayerLeftLobbyMessage: Codable {
    var playerInfo: PlayerInfo
}

enum MultipeerNetworkMessage: Codable {
    case lobbyInfo(LobbyInfoMessage)
    case newPlayerInfo(NewPlayerInfoMessage)
    case playerInfo(PlayerInfoMessage)
    case playerJoinedLobby(PlayerJoinedLobbyMessage)
    case playerLeftLobby(PlayerLeftLobbyMessage)
}

extension Encodable {
    func encoded() throws -> Data {
        return try JSONEncoder().encode(self)
    }
}

extension Data {
    func decoded<T: Decodable>() throws -> T {
        return try JSONDecoder().decode(T.self, from: self)
    }
}
