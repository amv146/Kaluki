//
//  FirebasePlayer.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/28/23.
//

import Foundation
import MultipeerConnectivity
import SwiftUI
import UIKit

class FirebasePlayer: ObservableObject, Identifiable {
    @Published var displayName: String
    @Published var profileImage: UIImage
    @Published var role: Role
    @Published var scoresByRound: [Int: Int]
    var id: String

    var lastScore: Int {
        get { scoresByRound[scoresByRound.count] ?? 0 }
        set { scoresByRound[scoresByRound.count] = newValue }
    }

    var score: Int { scoresByRound.values.reduce(0, +) }

    init(
        displayName: String,
        id: String,
        role: Role = .none,
        scoresByRound: [Int: Int] = [:],
        profileImage: UIImage? = nil,
        completion: ((UIImage?) -> Void)? = nil
    ) {
        self.displayName = displayName
        self.id = id
        self.role = role
        self.scoresByRound = scoresByRound
        self.profileImage = profileImage ?? Constants.defaultProfileImage

        if let completion {
            downloadProfileImage(completion: completion)
        }
    }

    static func from(
        gameID: String,
        firebasePlayerID playerID: String,
        completion: @escaping (FirebasePlayer?) -> Void
    ) {
        let playerRef = FirebaseUtils.gamesRef.document(gameID).collection("players")
            .document(playerID)

        playerRef.getDocument { document, error in
            if let error {
                print("Error getting document: \(error)")
                completion(nil)
            } else {
                if let document, document.exists {
                    let player = FirebasePlayer.from(dictionary: document.data()!)

                    completion(player)
                } else {
                    print("Document does not exist")
                    completion(nil)
                }
            }
        }
    }

    static func from(dictionary: [String: Any]) -> FirebasePlayer {
        let displayName = dictionary["displayName"] as! String
        let id = dictionary["id"] as! String
        let role = Role(rawValue: dictionary["role"] as! String)!

        var scoresByRound = [Int: Int]()

        for round in (dictionary["scoresByRound"] as! [String: Int]).keys {
            let score = (dictionary["scoresByRound"] as! [String: Int])[round]!
            scoresByRound[Int(round)!] = score
        }

        return FirebasePlayer(
            displayName: displayName,
            id: id,
            role: role,
            scoresByRound: scoresByRound
        )
    }

    func downloadProfileImage(
        overwrite: Bool = false,
        completion: ((UIImage?) -> Void)?
    ) {
        if !profileImage.isDefaultProfileImage(), !overwrite {
            completion?(profileImage)
            return
        }

        let profileImageRef = FirebaseUtils.profileImageRef(playerID: id)

        profileImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error {
                print(error)
            } else {
                self.profileImage = UIImage(data: data!)!
                print("Profile Image Downloaded")
                completion?(self.profileImage)

                return
            }

            completion?(nil)
        }
    }

    func reset() {
        scoresByRound = [:]
        role = .none
    }

    func update(
        from player: FirebasePlayer,
        completion: ((UIImage?) -> Void)? = nil
    ) {
        displayName = player.displayName
        scoresByRound = player.scoresByRound

        if profileImage.isDefaultProfileImage() {
            downloadProfileImage(completion: completion)
        } else {
            completion?(profileImage)
        }
    }

    func toDictionary() -> [String: Any] {
        let scoresByRound = Dictionary(
            uniqueKeysWithValues: scoresByRound
                .map { key, value in
                    (String(key), value)
                }
        )

        let score = scoresByRound.values.reduce(0, +)

        let dictionary: [String: Any] = [
            "displayName": displayName,
            "id": id,
            "role": role.rawValue,
            "score": score,
            "scoresByRound": scoresByRound,
        ]

        return dictionary
    }
}
