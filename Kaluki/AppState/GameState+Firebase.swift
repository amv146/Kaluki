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
    func addScoreToPlayer(playerID id: String, score: Int, round: Int) {
        currentPlayer.scoresByRound[round] = score
        gamePlayersRef?.document(id)
            .updateData(["scoresByRound.\(round)": score, "score": currentPlayer.score])
    }

    func createNewGame(completion: @escaping (String) -> Void) {
        let timestamp = FirebaseCore.Date.now

        currentPlayer.role = .host
        gameRef = FirebaseUtils.gamesRef.document()
        gamePlayersRef = gameRef!.collection("players")
        gameID = gameRef?.documentID

        gameRef?.setData([
            "round": 1,
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

                self.startAdvertisingGame(gameID: gameID)

                completion(self.gameID!)
                return
            }

            completion("")
        }
    }

    func fetchPlayerInfo(
        playerID: String,
        completion: @escaping (FirebasePlayer?, Error?) -> Void
    ) {
        gamePlayersRef?.document(playerID).getDocument { snapshot, error in
            if let error {
                completion(nil, error)
                return
            }
            if let snapshot, snapshot.exists {
                let firebasePlayer = FirebasePlayer.from(dictionary: snapshot.data()!)

                completion(firebasePlayer, nil)
                return
            }
            completion(nil, nil)
        }
    }

    func fetchPlayerInfos(completion: @escaping ([FirebasePlayer]?, Error?) -> Void) {
        gamePlayersRef?.getDocuments { snapshot, error in
            if let error {
                completion(nil, error)
                return
            }
            if let snapshot {
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
            completion(nil, nil)
        }
    }

    func fetchGameInfo(completion: @escaping (GameInfo?, Error?) -> Void) {
        gameRef?.getDocument { snapshot, error in
            if let error {
                print("Error fetching game info: \(error.localizedDescription)")

                completion(nil, error)
                return
            }
            if let snapshot {
                let round = snapshot.data()?["round"] as? Int ?? 1

                self.fetchPlayerInfos { players, error in
                    if let error {
                        print(
                            "Error fetching player infos: \(error.localizedDescription)"
                        )

                        completion(nil, error)
                        return
                    }
                    if let players {
                        let gameInfo = GameInfo(round: round, players: players)

                        completion(gameInfo, nil)
                        return
                    }
                }

                completion(GameInfo(round: round, players: []), nil)
                return
            }

            completion(nil, nil)
        }
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

                    if let gameInfo {
                        self.downloadProfileImages(for: gameInfo.players) {
                            self.players = gameInfo.players
                            self.round = gameInfo.round

                            self.gameRefSnapshotListener = self.subscribeToGameUpdates()
                            self.gamePlayersRefSnapshotListener = self
                                .subscribeToPlayerUpdates()

                            completion(gameInfo, nil)
                        }
                    } else {
                        completion(nil, nil)
                    }
                }
            }
        }
    }

    func leaveGame() {
        players = nil

        stopAdvertisingGame()

        gameRefSnapshotListener?.remove()
        gamePlayersRefSnapshotListener?.remove()
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
        for player in players ?? [] {
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

        return gameRef?.addSnapshotListener(includeMetadataChanges: true)
            { snapshot, error in
                if let error {
                    print(error)
                } else {
                    if let snapshot {
                        let round = snapshot.data()?["round"] as? Int ?? 1

                        if self.round != round {
                            self.round = round
                            self.delegate?.game(self.gameID!, didUpdate: round)
                        }
                    }
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

                    self.delegate?.game(self.gameID!, didUpdate: self.players!)
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
