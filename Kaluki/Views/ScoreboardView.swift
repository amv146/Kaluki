//
//  ScoreboardView.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/22/23.
//

import SwiftUI

struct RoundDetails {
    var round: Int
    var roundType: String
    var numCards: Int
}

let roundType: [Int: RoundDetails] = [
    1: RoundDetails(round: 1, roundType: "2 Straights", numCards: 11),
    2: RoundDetails(round: 2, roundType: "Three Trios",
                    numCards: 11),
    3: RoundDetails(round: 3, roundType: "Two Straights, One Trio", numCards: 11),
    4: RoundDetails(round: 4, roundType: "Two Trios, One Straight", numCards: 11),
    5: RoundDetails(round: 5, roundType: "Three Straights",
                    numCards: 12),
    6: RoundDetails(round: 6, roundType: "Four Trios",
                    numCards: 12),
    7: RoundDetails(round: 7, roundType: "Three Quartets",
                    numCards: 12),
]

struct ScoreboardView: View {
    // MARK: Internal

    @ObservedObject var scoreboardViewModel = ScoreboardViewModel()

    var addScoreButton: some View {
        AddScoreButtonView(action: {
            showingAlert = true
            print("Add Score")
        })
        .disabled(!scoreboardViewModel.canAddScore())
        .alert("Add Score", isPresented: $showingAlert, actions: {
            TextField("Score", text: $enteredScore)
                .keyboardType(.numberPad)

            Button("Add") {
                if let score = Int(enteredScore) {
                    scoreboardViewModel.addScore(score: score)
                    enteredScore = ""
                }
            }

            Button("Cancel", role: .cancel) {
                showingAlert = false
            }
        })
    }

    var body: some View {
        ZStack {
            Color.gray.opacity(0.1).ignoresSafeArea(edges: .all)
            VStack {
                VStack(alignment: .leading) {
                    Text("Round \(scoreboardViewModel.round)  (\(roundType[scoreboardViewModel.round]?.numCards ?? 0) cards)"
                    )
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.leading, 15)
                    .padding(.top, 30)
                    .padding(.bottom, -5)
                    .shadow(color: Color.gray.opacity(0.3), radius: 0.5, x: -1, y: 1)
                    Text("\(roundType[scoreboardViewModel.round]?.roundType ?? "Unknown")")
                        .font(.system(size: 25, weight: .semibold))
                        .foregroundColor(.blue)
                        .padding(.leading, 15)
                        .padding(.bottom, 1)
                        .shadow(color: Color.gray.opacity(0.3), radius: 0.5, x: -1, y: 1)
                    ForEach(scoreboardViewModel.players.indices, id: \.self) { index in
                        PlayerCellView(playerInfo: scoreboardViewModel.players[index], standing: index + 1)
                    }
                    .padding(.top, 5)
                    Spacer()
                    addScoreButton
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.bottom, 30)
                        .padding(.trailing, 30)
                }
            }
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
                case .active:
                    print("active")
                    if let host = scoreboardViewModel.host {
                        print(host)
                        MultipeerNetwork.player.joinGame(host: host)
                        MultipeerNetwork.joinLobby(host: host)
                    }
                case .inactive:
                    print("inactive")
                case .background:
                    print("background")
                default:
                    break
            }
        }
    }

    // MARK: Private

    @State private var showingAlert: Bool = false
    @State private var enteredScore: String = ""
    @Environment(\.scenePhase) private var scenePhase
}

// Update lobby memebrs
let scoreboardView = ScoreboardView()

struct ScoreboardView_Previews: PreviewProvider {
    static var previews: some View {
        scoreboardView.onAppear {
            scoreboardView.scoreboardViewModel.players.append(PlayerInfo(displayName: "Alex", role: .host, id: UUID(), scoresByRound: [1: 1, 2: 2], profileImage: UIImage(systemName: "person.fill")!))
            scoreboardView.scoreboardViewModel.players.append(PlayerInfo(displayName: "Alex2", role: .host, id: UUID(), profileImage: UIImage(systemName: "person.fill")!))
        }
    }
}
