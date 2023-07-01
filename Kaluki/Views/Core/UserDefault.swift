//
//  UserDefault.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/17/23.
//

import Foundation

import Combine
import SwiftUI

@propertyWrapper
class UserDefault<Value: Codable> {
    let key: UserDefaultsKey
    let userDefaults: Foundation.UserDefaults = .standard

    var wrappedValue: Value {
        get {
            switch key {
                case .displayName:
                    return UserDefaults.displayName.getOrDefault() as! Value
                case .id:
                    return UserDefaults.id.getOrDefault() as! Value
                case .listOrder:
                    return UserDefaults.listOrder.getOrDefault() as! Value
                case .profileImage:
                    return UserDefaults.profileImage.getOrDefault() as! Value
            }
        }
        set {
            switch key {
                case .displayName:
                    return UserDefaults.displayName.set(value: newValue as! String)
                case .id:
                    return UserDefaults.id.set(value: newValue as! String)
                case .listOrder:
                    return UserDefaults.listOrder.set(value: newValue as! ListOrder)
                case .profileImage:
                    return UserDefaults.profileImage.set(value: newValue as! UIImage)
            }
        }
    }

    init(key: UserDefaultsKey) {
        self.key = key
    }
}
