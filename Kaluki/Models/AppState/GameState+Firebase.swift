//
//  GameStateUtils.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/3/23.
//

import FirebaseCore
import FirebaseFirestore
import Foundation

internal extension GameState {
    func addScoreToPlayer(
        playerID id: String,
        score: Int,
        round: Int,
        schneid: Bool = false
    ) {
        guard let player = players?.first(where: { $0.id == id }) else {
            return
        }

        if isCurrentRoundASchneid() {
            player.scoresByRound[round] = score * 2
            gamePlayersRef?.document(id)
                .updateData(["scoresByRound.\(round)": player.lastScore,
                             "score": player.score])
        } else {
            player.scoresByRound[round] = score
            gamePlayersRef?.document(id)
                .updateData(["scoresByRound.\(round)": player.lastScore,
                             "score": player.score])
        }

        if schneid {
            gameRef?.updateData(["schneids.\(round)": currentPlayer.id])
        }

        if id == currentPlayer.id {
            lastAddedScore = AddedScore(schneid: schneid, score: score)
        }
    }

    func canUndo() -> Bool {
        return lastAddedScore != nil
    }

    func createNewGame(completion: @escaping (String) -> Void) {
        let timestamp = FirebaseCore.Date.now

        currentPlayer.reset()
        currentPlayer.role = .host
        gameRef = FirebaseUtils.gamesRef.document()
        gamePlayersRef = gameRef!.collection("players")
        gameID = gameRef?.documentID

        gameRef?.setData([
            "round": 1,
            "schneids": [Int: String](),
            "timestamp:": timestamp.timeIntervalSinceReferenceDate,
            "timestampString": timestamp.description,
        ], merge: true)

        updateFirebase(with: currentPlayer) { error in
            if let error {
                print("Error updating firebase: \(error.localizedDescription)")
            } else if let gameID = self.gameID {
                self.gameRefSnapshotListener = self.subscribeToGameUpdates()
                self.gamePlayersRefSnapshotListener = self.subscribeToPlayerUpdates()
                self.players = [self.currentPlayer]
                self.round = 1

                completion(gameID)
                return
            }

            completion("")
        }
    }

    func fetchPlayerInfo(
        playerID: String,
        completion: @escaping (FirebasePlayer?, Error?) -> Void
    ) {
        gamePlayersRef?.document(playerID).getDocument { document, error in
            if let error {
                completion(nil, error)
                return
            }

            guard let document, document.exists else {
                completion(nil, nil)
                return
            }

            let firebasePlayer = FirebasePlayer.from(dictionary: document.data()!)

            completion(firebasePlayer, nil)
        }
    }

    func fetchPlayerInfos(completion: @escaping ([FirebasePlayer]?, Error?) -> Void) {
        gamePlayersRef?.getDocuments { snapshot, error in
            if let error {
                completion(nil, error)
                return
            }

            guard let snapshot else {
                completion(nil, nil)
                return
            }

            var firebasePlayers = snapshot.documents.map {
                FirebasePlayer.from(dictionary: $0.data())
            }

            firebasePlayers = self.transferProfileImages(
                from: self.players,
                to: firebasePlayers
            )

            completion(firebasePlayers, nil)
            return
        }
    }

    func fetchGameInfo(completion: @escaping (GameInfo?, Error?) -> Void) {
        gameRef?.getDocument { document, error in
            if let error {
                print("Error fetching game info: \(error.localizedDescription)")

                completion(nil, error)
                return
            }

            guard let document, document.exists else {
                completion(nil, nil)
                return
            }

            let round = document.data()?["round"] as? Int ?? 1

            self.fetchPlayerInfos { players, error in
                if let error {
                    print(
                        "Error fetching player infos: \(error.localizedDescription)"
                    )

                    completion(nil, error)
                    return
                }

                guard let players else {
                    completion(nil, nil)
                    return
                }

                let gameInfo = GameInfo(round: round, players: players)

                completion(gameInfo, nil)
            }

            completion(GameInfo(round: round, players: []), nil)
            return
        }
    }

    func isCurrentRoundASchneid() -> Bool {
        return schneids[round] != nil
    }

    func joinGame(gameID: String, completion: @escaping (GameInfo?, Error?) -> Void) {
        if self.gameID != gameID {
            currentPlayer.reset()

            self.gameID = gameID
        }

        gameRef = FirebaseUtils.gamesRef.document(gameID)
        gamePlayersRef = gameRef!.collection("players")

        currentPlayer.role = .guest

        players = [currentPlayer]

        fetchPlayerInfo(playerID: currentPlayer.id) { player, error in
            if let error {
                print("Error fetching player info: \(error.localizedDescription)")

                completion(nil, error)
                return
            }

            if let player {
                self.currentPlayer.update(from: player)
            }

            self.updateFirebase(with: self.currentPlayer) { error in
                if let error {
                    print("Error updating firebase: \(error.localizedDescription)")

                    completion(nil, error)
                    return
                }

                self.fetchGameInfo { gameInfo, error in
                    if let error {
                        print("Error fetching game info: \(error.localizedDescription)")

                        completion(nil, error)
                        return
                    }

                    guard let gameInfo else {
                        completion(nil, nil)
                        return
                    }

                    self.downloadProfileImages(for: gameInfo.players) {
                        self.players = gameInfo.players
                        self.round = gameInfo.round

                        self.gameRefSnapshotListener = self.subscribeToGameUpdates()
                        self.gamePlayersRefSnapshotListener = self
                            .subscribeToPlayerUpdates()

                        completion(gameInfo, nil)
                    }
                }
            }
        }
    }

    func leaveGame() {
        players = nil

        gameRefSnapshotListener?.remove()
        gamePlayersRefSnapshotListener?.remove()
    }

    func undoLastAddedScore() {
        guard let lastAddedScore else { return }
        guard let players else { return }

        if players.allSatisfy({ $0.scoresByRound.count == round - 1 }) {
            round -= 1
        }

        gameRef?.updateData([
            "schneids.\(round)": FieldValue.delete(),
            "round": round,
        ])

        gamePlayersRef?.document(currentPlayer.id).updateData([
            "score": FieldValue.increment(Int64(-lastAddedScore.score)),
            "scoresByRound.\(round)": FieldValue.delete(),
        ])

        if lastAddedScore.schneid {
            schneids[round] = nil

            for player in players {
                if player.id != currentPlayer.id, player.scoresByRound.count >= round {
                    gamePlayersRef?.document(player.id).updateData([
                        "score": FieldValue.increment(Int64(-player.lastScore / 2)),
                        "scoresByRound.\(round)": FieldValue
                            .increment(Int64(-player.lastScore / 2)),
                    ])
                }
            }
        }

        self.lastAddedScore = nil
    }

    func updateFirebase(
        with firebasePlayer: FirebasePlayer,
        completion: @escaping (Error?) -> Void
    ) {
        gamePlayersRef?.document(currentPlayer.id)
            .setData(firebasePlayer.toDictionary(), merge: true) { error in
                print("Updating firebase with: \(self.currentPlayer.id)")
                if let error {
                    completion(error)
                    return
                }

                completion(nil)
            }
    }

    private func transferProfileImages(
        from players: [FirebasePlayer]?,
        to newPlayers: [FirebasePlayer]
    ) -> [FirebasePlayer] {
        players?.forEach { player in
            if let index = newPlayers.firstIndex(where: { $0.id == player.id }) {
                newPlayers[index].profileImage = player.profileImage
            }
        }

        return newPlayers
    }

    private func shouldAdvanceRound() -> Bool {
        guard let players else { return false }

        return players.allSatisfy { $0.scoresByRound.count == round }
    }

    func subscribeToGameUpdates(gameID: String? = nil) -> ListenerRegistration? {
        var gameRef: DocumentReference?

        if let gameID {
            gameRef = FirebaseUtils.gamesRef.document(gameID)
        } else {
            gameRef = self.gameRef
        }

        return gameRef?.addSnapshotListener { document, error in
            if let error {
                print(error)
            } else {
                guard let document, document.exists else { return }

                let data = document.data() ?? [:]
                let round = data["round"] as? Int ?? 1
                var schneids = [Int: String]()

                for round in (data["schneids"] as! [String: String]).keys {
                    let playerID = (data["schneids"] as! [String: String])[round]!
                    schneids[Int(round)!] = playerID
                }
                
                let schneidRound = (self.players?.allSatisfy({ $0.scoresByRound.count == round }) ?? false) ? round - 1 : round

                if
                   schneids[schneidRound] != nil,
                   schneids[schneidRound] != self.currentPlayer.id,
                   self.schneids[schneidRound] == nil,
                   self.currentPlayer.scoresByRound.count == schneidRound
                {
                    self.addScoreToPlayer(
                        playerID: self.currentPlayer.id,
                        score: self.currentPlayer.lastScore * 2,
                        round: schneidRound
                    )
                }

                self.round = round
                self.schneids = schneids
            }
        }
    }

    private func subscribeToPlayerUpdates() -> ListenerRegistration? {
        gamePlayersRef?.addSnapshotListener { snapshot, error in
            if let error {
                print(error)
            } else {
                guard let snapshot else { return }

                var players: [FirebasePlayer] = []

                for document in snapshot.documents {
                    let player = FirebasePlayer.from(dictionary: document.data())

                    players.append(player)
                }

                players = self.transferProfileImages(from: self.players, to: players)

                self.downloadProfileImages(for: players) {
                    ListOrder.sortPlayers(players: &players)

                    self.players = players

                    self.currentPlayer.update(
                        from: players.first(where: { $0.id == self.currentPlayer.id })!
                    )

                    if self.shouldAdvanceRound() {
                        self.round += 1

                        self.gameRef?.setData([
                            "round": self.round,
                        ], merge: true)
                    }
                }
            }
        }
    }

    private func downloadProfileImages(
        for players: [FirebasePlayer],
        completion: @escaping () -> Void
    ) {
        var numCompleted = 0

        for player in players {
            player.downloadProfileImage(completion: { _ in
                numCompleted += 1

                if numCompleted == players.count {
                    completion()
                }
            })
        }
    }
}
