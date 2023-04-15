//
//  ListOrder.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/13/23.
//

import Foundation

enum ListOrder: String, Codable {
    case alphabetical
    case score

    static func description(from listOrder: ListOrder) -> String {
        switch listOrder {
            case .alphabetical:
                return "Alphabetical"
            case .score:
                return "Score"
        }
    }

    static prefix func ! (order: ListOrder) -> ListOrder {
        switch order {
            case .alphabetical:
                return .score
            case .score:
                return .alphabetical
        }
    }

    static func sortPlayers(players: inout [FirebasePlayer]) {
        if UserDefaults.listOrder.getOrDefault() == .score {
            players.sort {
                if $0.score == $1.score { return $0.displayName.lowercased() < $1.displayName.lowercased() }
                else { return $0.score < $1.score }
            }
        } else {
            players.sort {
                if $0.displayName.lowercased() == $1.displayName.lowercased() { return $0.score < $1.score }
                else { return $0.displayName.lowercased() < $1.displayName.lowercased() }
            }
        }
    }
}
