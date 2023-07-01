//
//  AddScoreView.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/7/23.
//

import SwiftUI

// MARK: - CardView

private struct CardView: View {
    @EnvironmentObject var appState: AppState
    let card: Card
    let count: Int

    var body: some View {
        card.view
            .overlay(alignment: .topTrailing) {
                Text("\(count)")
                    .font(.system(size: 12, weight: .bold))
                    .padding(.all, 5)
                    .modifier(BlueWhiteModifier(cornerRadius: 0))
                    .clipShape(Circle())
                    .alignmentGuide(VerticalAlignment.top) { dimension in
                        dimension[VerticalAlignment.center]
                    }
                    .alignmentGuide(HorizontalAlignment.trailing) { dimension in
                        dimension[HorizontalAlignment.center]
                    }
                    .opacity(count != 0 ? 1 : 0)
            }
            .overlay(alignment: .bottom) {
                Text(
                    "\(appState.gameState.isCurrentRoundASchneid() ? card.points * 2 : card.points) pts"
                )
                .font(.system(size: 12, weight: .bold))
                .padding(.horizontal, 3)
                .modifier(BlueWhiteModifier(cornerRadius: 5))
                .alignmentGuide(VerticalAlignment.bottom) { dimension in
                    dimension[VerticalAlignment.center]
                }
            }
    }
}

// MARK: - AddScoreView

struct AddScoreView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @State var cards: [Card] = []
    @State var editingScore = false
    @State var score = ""

    var body: some View {
        ZStack {
            BackgroundView()
            ScrollView(showsIndicators: false) {
                contentView
            }
            .overlay(alignment: .bottom) {
                AddedCardsView(cards: cards)
                    .padding(.bottom, 20)
            }
            .tapDismissesKeyboard()
            .scrollDismissesKeyboard(.immediately)
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { closeButton }
            ToolbarItem(placement: .navigationBarTrailing) { undoButton }
            ToolbarItem(placement: .confirmationAction) { doneButton }
        }
        .navigationBarBackButtonHidden()
    }

    private var contentView: some View {
        VStack {
            TextFieldDynamicWidth(
                text: appState.gameState.isCurrentRoundASchneid() ? Binding(
                    get: { editingScore ? score : String((Int(score) ?? 0) * 2) },
                    set: { score = $0 }
                ) : $score,
                placeholder: "0",
                isEditing: $editingScore
            )
            .font(.system(size: 70))
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            .if(appState.gameState.isCurrentRoundASchneid()) {
                $0.overlay(alignment: .bottom) {
                    timesTwoText
                        .alignmentGuide(VerticalAlignment.bottom) { dimension in
                            dimension[VerticalAlignment.top]
                        }
                }
            }
            .padding(.top, 30)
            .padding(.bottom, 40)

            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    cardView(card: .Two)
                    cardView(card: .Three)
                    cardView(card: .Four)
                    cardView(card: .Five)
                }
                HStack(spacing: 12) {
                    cardView(card: .Six)
                    cardView(card: .Seven)
                    cardView(card: .Eight)
                    cardView(card: .Nine)
                }
                HStack(spacing: 12) {
                    cardView(card: .Ten)
                    cardView(card: .Jack)
                    cardView(card: .Queen)
                    cardView(card: .King)
                }
                HStack(spacing: 12) {
                    cardView(card: .Ace)
                    cardView(card: .Joker)
                }
            }
            .frame(maxWidth: .infinity)
            Spacer()
        }
        .padding(.bottom, 140)
    }
}

extension AddScoreView {
    var closeButton: some View {
        BaseButton(imageSystemName: "xmark", size: 15) {
            dismiss()
            score = ""
        }
    }

    var doneButton: some View {
        BaseButton(imageSystemName: "checkmark", size: 15) {
            if let score = Int(score.isEmpty ? "0" : score) {
                appState.gameState.addScoreToPlayer(
                    playerID: appState.gameState.currentPlayer.id,
                    score: score,
                    round: appState.gameState.round
                )
            }
            score = ""

            dismiss()
        }
    }

    var timesTwoText: some View {
        Text("Schneid! x2")
            .font(.system(size: 14, weight: .bold))
            .padding(.all, 5)
            .modifier(BlueWhiteModifier(cornerRadius: 7))
    }

    var undoButton: some View {
        BaseButton(imageSystemName: "arrow.uturn.backward", size: 12) {
            withAnimation {
                guard let card = cards.popLast() else { return }

                removeScore(score: String(card.points))
            }
        }
        .disabled(cards.isEmpty)
    }

    func cardView(card: Card) -> some View {
        Button(action: {
            addScore(score: String(card.points))

            withAnimation {
                cards.append(card)
            }
        }) {
            let count = cards.filter { $0 == card }.count
            CardView(card: card, count: count)
        }
    }
}

extension AddScoreView {
    func addScore(score: String) {
        self.score
            = String((Int(self.score) ?? 0) + Int(score)!)
    }

    func removeScore(score: String) {
        self.score
            = String((Int(self.score) ?? 0) - Int(score)!)
        self.score = self.score == "0" ? "" : self.score
    }
}

// MARK: - AddScoreView_Previews

struct AddScoreView_Previews: PreviewProvider {
    static var previews: some View {
        AddScoreView(score: "0")
    }
}
