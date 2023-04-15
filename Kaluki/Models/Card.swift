//
//  Card.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/10/23.
//

import Foundation

enum CardType: String
{
    case Two = "2"
    case Three = "3"
    case Four = "4"
    case Five = "5"
    case Six = "6"
    case Seven = "7"
    case Eight = "8"
    case Nine = "9"
    case Ten = "10"
    case Jack = "J"
    case Queen = "Q"
    case King = "K"
    case Ace = "A"
    case Joker
}

struct Card
{
    let type: CardType

    var points: Int
    {
        switch type
        {
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
        case .Ten:
            return 10
        case .Jack:
            return 10
        case .Queen:
            return 10
        case .King:
            return 10
        case .Ace:
            return 15
        case .Joker:
            return 15
        }
    }
}
