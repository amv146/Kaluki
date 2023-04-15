//
//  AddScoreView.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/7/23.
//

import SwiftUI

// MARK: - AddScoreView

struct AddScoreView: View {
    @Binding var score: String
    @State var cards: [Card] = []
    let action: () -> Void

    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            BackgroundView()
            ScrollView {
                contentView
            }
            .tapDismissesKeyboard()
            .scrollDismissesKeyboard(.immediately)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { backButton }
            ToolbarItem(placement: .navigationBarTrailing) { undoButton }
            ToolbarItem(placement: .confirmationAction) { doneButton }
        }
        .navigationBarBackButtonHidden()
    }

    private var contentView: some View {
        VStack {
            TextFieldDynamicWidth(
                text: $score,
                title: "0"
            )
            .font(.system(size: 70))
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            .overlay(alignment: .topTrailing) {
                cards.last != nil ? lastScoreText : nil
            }
            .padding(.vertical, 60)
            VStack(spacing: 60) {
                HStack(spacing: 65) {
                    cardView(card: Card(type: .Two))
                    cardView(card: Card(type: .Three))
                    cardView(card: Card(type: .Four))
                    cardView(card: Card(type: .Five))
                }
                HStack(spacing: 65) {
                    cardView(card: Card(type: .Six))
                    cardView(card: Card(type: .Seven))
                    cardView(card: Card(type: .Eight))
                    cardView(card: Card(type: .Nine))
                }
                HStack(spacing: 65) {
                    cardView(card: Card(type: .Ten))
                    cardView(card: Card(type: .Jack))
                    cardView(card: Card(type: .Queen))
                    cardView(card: Card(type: .King))
                }
                HStack(spacing: 65) {
                    cardView(card: Card(type: .Ace))
                    cardView(card: Card(type: .Joker))
                }
            }
            Spacer()
        }
    }
}

extension AddScoreView {
    var backButton: some View {
        BackButton {
            dismiss()
            score = "0"
        }
    }

    var doneButton: some View {
        BaseButton(imageSystemName: "checkmark", size: 15) {
            action()
            dismiss()
        }
    }

    var lastScoreText: some View {
        Text("+\(cards.last?.points ?? 0)")
            .font(.system(size: 20, weight: .semibold))
            .padding(4)
            .modifier(BlueWhiteModifier(cornerRadius: 20))
            .padding(.bottom, 20)
            .frame(alignment: .leading)
    }

    var undoButton: some View {
        BaseButton(imageSystemName: "arrow.uturn.backward", size: 12) {
            if let card = cards.popLast() {
                removeScore(score: String(card.points))
            }
        }
    }

    func cardView(card: Card) -> some View {
        Button(action: {
            addScore(score: String(card.points))
            cards.append(card)
        }, label: {
            Text(card.type.rawValue)
                .font(.system(size: 35, weight: .semibold))
        })
    }
}

extension AddScoreView {
    func addScore(score: String) {
        print("Score \(self.score)")
        self.score = String((Int(self.score) ?? 0) + Int(score)!)
    }

    func removeScore(score: String) {
        self.score = String((Int(self.score) ?? 0) - Int(score)!)
    }
}

// MARK: - AddScoreView_Previews

struct AddScoreView_Previews: PreviewProvider {
    static var previews: some View {
        AddScoreView(score: .constant("0"), action: {})
    }
}
