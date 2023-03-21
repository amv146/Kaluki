//
//  PlayerInfo.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/21/23.
//

import MultipeerConnectivity
import SwiftUI

enum Role: Codable {
    case guest
    case host
    case none

    // MARK: Internal

    /* In another file, I want to show the role of players with special roles in the UI, so I have a static function to easily get text for each
     role */
    static func roleTitle(from role: Role) -> String {
        switch role {
            case .guest:
                return "Guest"

            case .host:
                return "Host"

            default:
                return ""
        }
    }
}

struct PlayerInfo: Codable, Identifiable, Hashable {
    // MARK: Lifecycle

    init(displayName: String, role: Role, id: UUID, scoresByRound: [Int: Int] = [:], profileImage: UIImage) {
        self.displayName = displayName
        self.id = id
        self.role = role
        self.scoresByRound = scoresByRound

        // Archive the MCPeerID object and store the resulting data
        archivedPeerID = MultipeerNetwork.myPeerID.encode()
        archivedProfileImage = profileImage.jpegData(compressionQuality: 0.05)!
    }

    init(fromPlayer player: Player) {
        displayName = player.displayName
        id = player.id
        role = player.role
        scoresByRound = player.scoresByRound

        // Archive the MCPeerID object and store the resulting data
        archivedPeerID = player.peerID.encode()
        archivedProfileImage = player.profileImage.jpegData(compressionQuality: 0.05)!
    }

    // MARK: Internal

    var id: UUID

    var displayName: String
    var role: Role
    var scoresByRound: [Int: Int]
    var standing: Int?

    // Add a new archivedPeerID property to hold the serialized MCPeerID data
    var archivedPeerID: Data
    var archivedProfileImage: Data?

    var profileImage: UIImage? {
        if let archivedProfileImage = archivedProfileImage {
            return UIImage(data: archivedProfileImage)
        }

        return nil
    }

    var peerID: MCPeerID {
        MCPeerID.decode(data: archivedPeerID)
    }
}
