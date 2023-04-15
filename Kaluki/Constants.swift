//
//  Constants.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/12/23.
//

import SwiftUI

class Constants {
    static var defaultProfileImage: UIImage {
        let defaultProfileImage = UIImage(systemName: "person.crop.circle")!
        defaultProfileImage.accessibilityIdentifier = "defaultProfileImage"

        return defaultProfileImage
    }

    static let roundType: [Int: RoundDetails] = [
        1: RoundDetails(
            round: 1,
            roundType: "Two Straights",
            numCards: 11
        ),
        2: RoundDetails(
            round: 2,
            roundType: "Three Trios",
            numCards: 11
        ),
        3: RoundDetails(
            round: 3,
            roundType: "Two Straights, One Trio",
            numCards: 11
        ),
        4: RoundDetails(
            round: 4,
            roundType: "Two Trios, One Straight",
            numCards: 11
        ),
        5: RoundDetails(
            round: 5,
            roundType: "Three Straights",
            numCards: 12
        ),
        6: RoundDetails(
            round: 6,
            roundType: "Four Trios",
            numCards: 12
        ),
        7: RoundDetails(
            round: 7,
            roundType: "Three Quartets",
            numCards: 12
        ),
    ]
}
