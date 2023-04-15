//
//  Extensions.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/28/23.
//

import Foundation
import MultipeerConnectivity

extension MCPeerID {
    func encode() -> Data {
        try! NSKeyedArchiver.archivedData(
            withRootObject: self,
            requiringSecureCoding: false
        )
    }

    static func decode(data: Data) -> MCPeerID {
        try! NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: data)!
    }

    static func getPeerIDFromDisplayName(displayName: String) -> MCPeerID {
        let oldDisplayName = UserDefaults.displayName.getOrDefault()
        var peerID = MCPeerID(displayName: displayName)

        let defaults = Foundation.UserDefaults.standard

        if oldDisplayName == displayName {
            if let peerIDData = defaults.data(forKey: "peerID") {
                peerID = (
                    try? NSKeyedUnarchiver
                        .unarchiveTopLevelObjectWithData(peerIDData) as? MCPeerID
                ) ?? peerID
            }
        } else {
            do {
                let peerIDData = try NSKeyedArchiver.archivedData(
                    withRootObject: peerID,
                    requiringSecureCoding: false
                )
                defaults.set(peerIDData, forKey: "peerID")
            } catch {
                print("Error: \(error)")
            }
        }

        return peerID
    }
}

// MARK: - MCPeerIDData

class MCPeerIDData: Codable {
    let peerID: MCPeerID

    init(peerID: MCPeerID) {
        self.peerID = peerID
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let peerIDData = try values.decode(Data.self, forKey: .peerID)
        peerID = MCPeerID.decode(data: peerIDData)
    }

    enum CodingKeys: String, CodingKey {
        case peerID
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(peerID.encode(), forKey: .peerID)
    }
}
