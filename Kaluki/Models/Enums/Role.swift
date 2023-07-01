//
//  Role.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/13/23.
//

import Foundation

enum Role: String, Codable {
    case guest
    case host
    case none

    /** In another file, I want to show the role of players with special roles in the UI, so I have a static function to easily get text for each
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
