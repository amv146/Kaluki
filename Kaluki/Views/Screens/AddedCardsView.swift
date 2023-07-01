//
//  AddedCardsView.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/17/23.
//

import SwiftUI

// MARK: - AddedCardsView

struct AddedCardsView: View {
    var cards: [Card]

    var body: some View {
        HStack(spacing: -55) {
            ForEach(0..<cards.count, id: \.self) { index in
                Image(uiImage: cards[index].image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 100)
                    .background(Color.white)
                    .cornerRadius(3)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                    .transition(.move(edge: .bottom))
            }
        }
    }
}

// MARK: - AddedCardsView_Previews

struct AddedCardsView_Previews: PreviewProvider {
    static var previews: some View {
        AddedCardsView(cards: [])
    }
}
