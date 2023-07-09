//
//  Card.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/10/23.
//

import Foundation
import SwiftUI

// MARK: - Card

enum Card: String, Hashable {
    case Two = "2"
    case Three = "3"
    case Four = "4"
    case Five = "5"
    case Six = "6"
    case Seven = "7"
    case Eight = "8"
    case Nine = "9"
    case Ten = "T"
    case Jack = "J"
    case Queen = "Q"
    case King = "K"
    case Ace = "A"
    case Joker

    var image: UIImage {
        let cardSuit = UserDefaults.cardSuit.getOrDefault()
        let imageName = self == .Joker ? "Cards/joker_black" : "Cards/\(rawValue)\(cardSuit.abbreviation)" 
        
        return UIImage(named: imageName)!
    }

    var view: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(width: 65, height: 93)
            .background(Color.white)
            .cornerRadius(3)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }

    var points: Int {
        switch self {
            case .Two:
                return 2
            case .Three:
                return 3
            case .Four:
                return 4
            case .Five:
                return 5
            case .Six:
                return 6
            case .Seven:
                return 7
            case .Eight:
                return 8
            case .Nine:
                return 9
            case .Jack, .King, .Queen, .Ten: return 10
            case .Ace:
                return 15
            case .Joker:
                return 15
        }
    }
}
