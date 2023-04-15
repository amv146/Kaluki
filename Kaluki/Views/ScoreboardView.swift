//
//  ScoreboardView.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/22/23.
//

import SwiftUI

// MARK: - ScoreboardView

struct ScoreboardView: View {
    @State var enteredScore = "0"
    @StateObject var viewModel = ScoreboardViewModel()
    @Environment(\.dismiss) var dismiss
    @Environment(\.scenePhase) var scenePhase

    public var body: some View {
        ZStack {
            BackgroundView()
            contentView
        }
        .tapDismissesKeyboard()
        .scrollDismissesKeyboard(.immediately)
        .navigationBarBackButtonHidden(true)
        .navigationTitle("")
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading, content: { backButton })
            ToolbarItem(placement: .navigationBarTrailing, content: { listOrderButton })
        })
        .onChange(of: scenePhase) { phase in
            if phase == .inactive || phase == .background, !viewModel.isGameOver() {
                NotificationHandler
                    .updateRoundNotification(roundDetails: viewModel.currentRoundDetails!)
            }
        }
    }

    private var contentView: some View {
        VStack(alignment: .leading) {
            Group {
                Text(viewModel.getRoundText())
                    .font(.system(size: 20))

                Text(viewModel.getRoundTypeText())
                    .font(.system(size: 25))
                    .foregroundColor(.blue)
            }
            .fontWeight(.semibold)
            .padding(.horizontal, 15)
            .grayShadow()

            ScrollView {
                VStack {
                    ForEach(viewModel.players, id: \.id) { player in
                        PlayerCellView(
                            player: player,
                            standing: viewModel.getStanding(firebasePlayer: player)
                        )
                    }
                }
                .animation(.linear, value: viewModel.players.map(\.score))
                .padding(.horizontal, 15)
                .padding(.top, 2)

                Spacer()
            }
            .overlay(
                addScoreButton
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.bottom, 30)
                    .padding(.trailing, 30),
                alignment: .bottom
            )
        }
        .padding(.top, 30)
    }
}

private extension ScoreboardView {
    var addScoreButton: some View {
        AddScoreButton(score: $enteredScore, action: {
            if let score = Int(enteredScore.isEmpty ? "0" : enteredScore) {
                viewModel.addScore(score: score)
                enteredScore = "0"
            }
        })
        .disabled(!viewModel.canAddScore())
    }

    var backButton: some View {
        BackButton(action: {
            viewModel.gameState.leaveGame()
            dismiss()
        })
    }

    var listOrderButton: some View {
        BaseButton(
            imageSystemName: "arrow.up.arrow.down",
            size: 15,
            action: {
                viewModel.toggleListOrder()
            }
        )
    }
}

let scoreboardView = ScoreboardView()

// MARK: - ScoreboardView_Previews

struct ScoreboardView_Previews: PreviewProvider {
    static var previews: some View {
        scoreboardView.onAppear {
            scoreboardView.viewModel.appState.gameState.round = 1
            scoreboardView.viewModel.appState.gameState.players = []
            scoreboardView.viewModel.appState.gameState.players!.append(FirebasePlayer(
                displayName: "Alex",
                id: UUID().uuidString,
                role: .host,
                scoresByRound: [1: 1, 2: 2]
            ))
            scoreboardView.viewModel.appState.gameState.players!.append(FirebasePlayer(
                displayName: "Alex2",
                id: UUID().uuidString,
                role: .host,

                scoresByRound: [1: 1, 2: 1]
            ))
            scoreboardView.viewModel.appState.gameState.players!.append(FirebasePlayer(
                displayName: "Alex3",
                id: UUID().uuidString,
                role: .host,

                scoresByRound: [1: 1, 2: 1]
            ))
            scoreboardView.viewModel.appState.gameState.players!.append(FirebasePlayer(
                displayName: "Alex4",
                id: UUID().uuidString,
                role: .host,

                scoresByRound: [1: 1, 2: 1]
            ))
            scoreboardView.viewModel.appState.gameState.players!.append(FirebasePlayer(
                displayName: "Alex5",
                id: UUID().uuidString,
                role: .host,

                scoresByRound: [1: 1, 2: 1]
            ))
            scoreboardView.viewModel.appState.gameState.players!.append(FirebasePlayer(
                displayName: "Alex6",
                id: UUID().uuidString,
                role: .host,

                scoresByRound: [1: 1, 2: 1]
            ))

            scoreboardView.viewModel.appState.gameState.players!.append(FirebasePlayer(
                displayName: "Alex7",
                id: UUID().uuidString,
                role: .host,

                scoresByRound: [1: 1, 2: 1]
            ))

            scoreboardView.viewModel.appState.gameState.players!.append(FirebasePlayer(
                displayName: "Alex8",
                id: UUID().uuidString,
                role: .host,

                scoresByRound: [1: 1, 2: 1]
            ))
        }
    }
}

extension Binding where Value == String {
    func max(_ limit: Int) -> Self {
        if wrappedValue.count > limit {
            wrappedValue = String(wrappedValue.prefix(3))
        }
        return self
    }
}
