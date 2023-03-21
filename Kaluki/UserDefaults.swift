//
//  UserDefaults.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/25/23.
//

import Foundation
import MultipeerConnectivity
import SwiftUI

enum UserDefaults: String {
    case displayName
    case peerID
    case profileImage = "imageData"

    // MARK: Internal

    var userDefaults: Foundation.UserDefaults {
        Foundation.UserDefaults.standard
    }

    func fallbackToDefaults() -> Any? {
        let key = rawValue

        switch self {
            case .displayName:
                return userDefaults.string(forKey: key) ?? getDefaultValue() as! String
            case .peerID:
                return userDefaults.data(forKey: key) ?? getDefaultValue() as! MCPeerID
            case .profileImage:
                let profileImageData = userDefaults.data(forKey: key)

                if let data = profileImageData, let image = UIImage(data: data) {
                    return image
                } else {
                    return getDefaultValue()
                }
        }
    }

    func set(value: Any?) {
        let key = rawValue

        userDefaults.set(value, forKey: key)
    }

    // MARK: Private

    private func getDefaultValue() -> Any {
        switch self {
            case .displayName:
                return "Player"
            case .profileImage:
                return UIImage(systemName: "person.crop.circle")!
            case .peerID:
                return MCPeerID(displayName: UserDefaults.displayName.fallbackToDefaults() as! String)
        }
    }
}
