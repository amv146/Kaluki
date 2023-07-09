//
//  ListOrderButton.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/17/23.
//

import SwiftUI

// MARK: - ListOrderButton

struct SettingsButton: View {
    @EnvironmentObject var appState: AppState
    @State var cardSuit = UserDefaults.cardSuit.getOrDefault()
    @State var listOrder = UserDefaults.listOrder.getOrDefault()

    var body: some View {
        VStack(spacing: 10) {
            Menu {
                Menu {
                    Picker("", selection: $listOrder) {
                        ForEach(ListOrder.allCases, id: \.self) { listOrderCase in
                            Text(listOrderCase.rawValue)
                        }
                    }
                } label: {
                    Label("Sort by", systemImage: "arrow.up.arrow.down")
                }
                Menu {
                    Picker("", selection: $cardSuit) {
                        ForEach(CardSuit.allCases, id: \.self) { cardSuitCase in
                            Label(cardSuitCase.rawValue, systemImage: "suit.\(cardSuitCase.rawValue.prefix(cardSuitCase.rawValue.count - 1).lowercased()).fill")
                        }
                    }
                } label: {
                    Label("Card suit", systemImage: "suit.\(cardSuit.rawValue.prefix(cardSuit.rawValue.count - 1).lowercased()).fill")
                }
            } label: {
                BaseButton(
                    imageSystemName: "gearshape",
                    size: 15,
                    action: {}
                )
            }
            .onChange(of: listOrder) { newValue in
                UserDefaults.listOrder.set(value: newValue)

                if appState.gameState.players != nil {
                    ListOrder.sortPlayers(players: &appState.gameState.players!)
                }
            }
            .onChange(of: cardSuit) { newValue in
                UserDefaults.cardSuit.set(value: newValue)
            }
        }
    }

    func toggleListOrder() {
        UserDefaults.listOrder.set(value: !UserDefaults.listOrder.getOrDefault())

        if appState.gameState.players != nil {
            ListOrder.sortPlayers(players: &appState.gameState.players!)
        }
    }
}

// MARK: - ListOrderButton_Previews

struct SettingsButton_Previews: PreviewProvider {
    static var previews: some View {
        SettingsButton()
    }
}
