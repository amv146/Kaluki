//
//  FirebaseUtils+Firestore.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/12/23.
//

import FirebaseFirestore
import Foundation

extension FirebaseUtils
{
    static let gamesRef = firestore.collection(FirestoreKey.games.rawValue)
    static let playersRef = firestore.collection(FirestoreKey.players.rawValue)

    static func playerRef(playerID id: String) -> DocumentReference
    {
        playersRef.document(id)
    }

    static func playerRef(playerID uuid: UUID) -> DocumentReference
    {
        playersRef.document(uuid.uuidString)
    }
}
