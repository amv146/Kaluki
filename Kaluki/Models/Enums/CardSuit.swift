//
//  CardSuit.swift
//  Kaluki
//
//  Created by Alex Vallone on 7/1/23.
//

import Foundation

enum CardSuit: String, Codable, CaseIterable, Hashable {
    case spades = "Spades"
    case hearts = "Hearts"
    case diamonds = "Diamonds"
    case clubs = "Clubs"
    
    var abbreviation: String {
        switch self {
            case .spades:
                return "S"
            case .hearts:
                return "H"
            case .diamonds:
                return "D"
            case .clubs:
                return "C"
        }
    }
    

    static func description(from cardSuit: CardSuit) -> String {
        switch cardSuit {
            case .spades:
                return "Spades"
            case .hearts:
                return "Hearts"
            case .diamonds:
                return "Diamonds"
            case .clubs:
                return "Clubs"
        }
    }
    
    static func icon(from cardSuit: CardSuit) -> String {
        switch cardSuit {
            case .spades:
                return "♠"
            case .hearts:
                return "♥"
            case .diamonds:
                return "♦"
            case .clubs:
                return "♣"
        }
    }
}
