//
//  ScoreboardViewModel.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/22/23.
//

import Foundation
import MultipeerConnectivity

// MARK: - ScoreboardViewModel

class ScoreboardViewModel: ViewModel {
    var currentRoundDetails: RoundDetails? { Constants.roundType[round] }
    var currentPlayer: FirebasePlayer { gameState.currentPlayer }
    var players: [FirebasePlayer] { gameState.players ?? [] }
    var round: Int { gameState.round }
    var scoresByRound: [Int: Int] { gameState.currentPlayer.scoresByRound }

    override init() {
        super.init()

        appState.multipeerState.browser?.stopBrowsingForPeers()
        gameState.delegate = self
    }

    func addScore(score: Int) {
        gameState.addScoreToPlayer(
            playerID: currentPlayer.id,
            score: score,
            round: round
        )
    }

    func canAddScore() -> Bool {
        scoresByRound.count < round && !isGameOver()
    }

    func getRoundText() -> String {
        if let currentRoundDetails {
            return "Round \(round) (\(currentRoundDetails.numCards) cards)"
        }

        return "Game Over!"
    }

    func getRoundTypeText() -> String {
        if let currentRoundDetails {
            return "\(currentRoundDetails.roundType)"
        } else if isGameOver(), let winner = getWinner() {
            return "Winner: \(winner.displayName)"
        }

        return ""
    }

    func getStanding(firebasePlayer: FirebasePlayer) -> Int {
        let sortedPlayers = players.sorted {
            if $0.score == $1.score { return $0.displayName.lowercased() < $1.displayName.lowercased() }
            else { return $0.score < $1.score }
        }
        
        return sortedPlayers.firstIndex(where: { $0.id == firebasePlayer.id })! + 1
    }

    func getWinner() -> FirebasePlayer? {
        let sortedPlayers = players.sorted { $0.score < $1.score }
        return sortedPlayers.first
    }

    func isGameOver() -> Bool {
        return round > 7
    }

    func toggleListOrder() {
        print(UserDefaults.listOrder.getOrDefault())
        UserDefaults.listOrder.set(value: !UserDefaults.listOrder.getOrDefault())

        if gameState.players != nil {
            ListOrder.sortPlayers(players: &gameState.players!)
        }
    }
}

// MARK: GameDelegate

extension ScoreboardViewModel: GameDelegate {
    func game(_: String, didUpdate round: Int) {
        print("Did Update Round \(round)")

        appState.gameState.round = round
    }

    func game(_: String, didUpdate players: [FirebasePlayer]) {
        currentPlayer.update(
            from: players.first(where: { $0.id == currentPlayer.id })!,
            completion: { _ in }
        )
    }
}
