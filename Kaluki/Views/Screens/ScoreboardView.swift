//
//  ScoreboardView.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/22/23.
//

import SwiftUI

// MARK: - ScoreboardView

struct ScoreboardView: View {
    @State var addScoreButtonExpanded = false
    @State var enteredScore = ""
    @State var isPresentingHostConfirmLeaveDialog = false
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
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .navigationTitle("")
        .onChange(of: scenePhase) { phase in
            if phase == .inactive || phase == .background, !viewModel.isGameOver() {
                NotificationHandler
                    .updateRoundNotification(
                        roundDetails: viewModel
                            .currentRoundDetails!
                    )
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading, content: { backButton })
            ToolbarItem(placement: .navigationBarTrailing, content: { undoButton })
            ToolbarItem(
                placement: .confirmationAction,
                content: { SettingsButton() }
            )
        }
        .confirmationDialog(
            "Are you sure you want to leave the game? As the host, you will stop advertising the game to other players to join.",
            isPresented: $isPresentingHostConfirmLeaveDialog,
            titleVisibility: .visible
        ) {
            Button("Yes", role: .destructive) {
                viewModel.gameState.leaveGame()
                viewModel.multipeerState.stopAdvertisingGame()
                dismiss()
            }
            Button("No", role: .cancel) {}
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
                        .allowsHitTesting(!addScoreButtonExpanded)
                    }
                }
                .animation(.linear, value: viewModel.players.map(\.score))
                .padding(.horizontal, 15)
                .padding(.top, 2)
                .padding(.bottom, 110)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onTapGesture {
            withAnimation {
                addScoreButtonExpanded = false
            }
        }
        .blur(radius: addScoreButtonExpanded ? 5 : 0)
        .overlay(
            addScoreButton
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.bottom, 30)
                .padding(.trailing, 30),
            alignment: .bottom
        )
        .padding(.top, 30)
    }
}

private extension ScoreboardView {
    var addScoreButton: some View {
        AddScoreButton(expanded: $addScoreButtonExpanded)
            .disabled(!viewModel.canAddScore())
    }

    var backButton: some View {
        BackButton {
            if viewModel.gameState.currentPlayer.role == .host {
                isPresentingHostConfirmLeaveDialog = true
            } else {
                viewModel.gameState.leaveGame()
                viewModel.multipeerState.stopAdvertisingGame()
                dismiss()
            }
        }
    }

    var undoButton: some View {
        BaseButton(imageSystemName: "arrow.uturn.backward", size: 12) {
            withAnimation {
                viewModel.gameState.undoLastAddedScore()
            }
        }
        .disabled(!viewModel.gameState.canUndo())
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
