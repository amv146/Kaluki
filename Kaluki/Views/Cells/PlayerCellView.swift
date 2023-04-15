//
//  PlayerCellView.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/23/23.
//

import SwiftUI

// MARK: - PlayerCellView

struct PlayerCellView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var player: FirebasePlayer
    @State var expanded = false
    @State var isEditing = false
    @State var pressed = false
    var standing: Int

    var body: some View {
        ZStack {
            contentView
                .onTapGesture {
                    DispatchQueue.main.async {
                        if isEditing { return }
                        pressed.toggle()

                        withAnimation {
                            expanded.toggle()
                            pressed.toggle()
                        }
                    }
                }
        }
    }

    var contentView: some View {
        VStack(spacing: 0) {
            HStack {
                Group {
                    Text("\(standing)")
                        .font(.system(.subheadline, weight: .bold))
                    profileImageView
                    
                    Text(player.displayName)
                        .font(.system(size: 17, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    lastScoreView
                    totalScoreView
                }
                .padding(.leading, 10)
            }
            .padding(.all, 10)
            .padding(.trailing, 10)
            .background(pressed ? Color.gray.opacity(1) : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .gray, radius: 2, x: 0, y: 0)

            if expanded {
                ScoresByRoundCellView(scoresByRound: player.scoresByRound)
                    .zIndex(-1)
            }
        }
    }

}

extension PlayerCellView {
    func updateLastScore() {
        appState.gameState.addScoreToPlayer(
            playerID: player.id,
            score: player.lastScore,
            round: player.scoresByRound.count
        )
    }

    func canEditLastScore() -> Bool {
        return !player.scoresByRound.isEmpty && player.id == appState.gameState
            .currentPlayer.id
    }

}

extension PlayerCellView {
    var hostImage: some View {
        Image(systemName: "crown")
            .font(.system(size: 10, weight: .bold))
            .padding(3)
            .modifier(BlueWhiteModifier(cornerRadius: 20))
            .clipShape(Circle())
            .opacity(player.role == .host ? 1 : 0)
    }

    var lastScoreView: some View {
        ChangeableScoreView(
            title: "Last",
            score: Binding(
                get: { String(player.lastScore) },
                set: { player.lastScore = Int($0) ?? 0 }
            ),
            isEditing: $isEditing
        )
        .disabled(!canEditLastScore())
        .onSubmit { updateLastScore() }
    }

    var profileImageView: some View {
        Image(uiImage: player.profileImage)
            .modifier(BorderedCircleImageModifier(borderWidth: 1.25, size: 50))
            .overlay(hostImage, alignment: .topLeading)
    }

    var totalScoreView: some View {
        VStack {
            Group {
                Text("\(player.score)")
                    .font(.system(size: 18))
                Text("Score")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .fontWeight(.bold)
        }
    }
}

// MARK: - PlayerCellView_Previews

struct PlayerCellView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerCellView(player: FirebasePlayer(
            displayName: "Iphone 14 prollllllla",
            id: UUID().uuidString,
            role: .host,
            scoresByRound: [1: 1, 2: 2],
            completion: { _ in }
        ), standing: 1)
    }
}
