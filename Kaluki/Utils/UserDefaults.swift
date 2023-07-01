//
//  UserDefaults.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/25/23.
//

import Foundation
import MultipeerConnectivity
import SwiftUI

// MARK: - UserDefaultType

protocol UserDefaultType: Hashable {
    associatedtype T

    var key: String { get }
    var userDefaults: Foundation.UserDefaults { get }

    func getOrDefault() -> T
    func set(value: T)
}

// MARK: - UserDefaultDisplayName

struct UserDefaultDisplayName: UserDefaultType {
    var key = "displayName"
    var userDefaults: Foundation.UserDefaults = .standard

    typealias T = String

    func getOrDefault() -> String {
        userDefaults.string(forKey: key) ?? "Player"
    }

    func set(value: String) {
        userDefaults.set(value, forKey: key)
    }
}

// MARK: - UserDefaultProfileImage

// struct UserDefaultPeerID: UserDefaultType {
//    typealias T = MCPeerID
//
//    var key = "peerID"
//
//    var userDefaults: Foundation.UserDefaults = .standard
//
//    func getOrDefault() -> MCPeerID {
//        userDefaults.data(forKey: key) as! MCPeerID ?? MCPeerID(displayName: "Player")
//    }
//
//    func set(value: MCPeerID) {
//        userDefaults.set(value, forKey: key)
//    }
// }

struct UserDefaultProfileImage: UserDefaultType {
    var key = "profileImageData"

    var userDefaults: Foundation.UserDefaults = .standard

    typealias T = UIImage

    func getOrDefault() -> UIImage {
        let profileImageData = userDefaults.data(forKey: key)

        if let data = profileImageData, let image = UIImage(data: data) {
            print("Image data exists")
            return image
        } else {
            return Constants.defaultProfileImage
        }
    }

    func set(value: Data) {
        userDefaults.set(value, forKey: key)
    }

    func set(value: UIImage) {
        userDefaults.set(value.jpegData(compressionQuality: 0.5), forKey: key)
    }
}

// MARK: - UserDefaultListOrder

struct UserDefaultListOrder: UserDefaultType {
    var key = "listOrder"

    var userDefaults: Foundation.UserDefaults = .standard

    typealias T = ListOrder

    func getOrDefault() -> ListOrder {
        ListOrder(
            rawValue: userDefaults.string(forKey: key) ?? ListOrder.score.rawValue
        ) ??
            ListOrder.score
    }

    func set(value: ListOrder) {
        userDefaults.set(value.rawValue, forKey: key)
    }
}

// MARK: - UserDefaultID

struct UserDefaultID: UserDefaultType {
    var key = "id"
    var userDefaults: Foundation.UserDefaults = .standard

    typealias T = String

    func getOrDefault() -> String {
        if let id = userDefaults.string(forKey: key) {
            return id
        } else {
            let id = UUID().uuidString
            userDefaults.set(id, forKey: key)
            return id
        }
    }

    func set(value: String) {
        userDefaults.set(value, forKey: key)
    }
}

// MARK: - UserDefaults

struct UserDefaults {
    static let displayName = UserDefaultDisplayName()
    static let profileImage = UserDefaultProfileImage()
    static let listOrder = UserDefaultListOrder()
    static let id = UserDefaultID()

    var userDefaults: Foundation.UserDefaults {
        Foundation.UserDefaults.standard
    }

    static func value(for key: UserDefaultsKey) -> any UserDefaultType {
        switch key {
            case .displayName:
                return displayName
            case .id:
                return id
            case .listOrder:
                return listOrder
            case .profileImage:
                return profileImage
        }
    }
}
