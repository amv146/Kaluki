//
//  ListOrderButton.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/17/23.
//

import SwiftUI

// MARK: - ListOrderButton

struct ListOrderButton: View {
    @EnvironmentObject var appState: AppState
    @State var listOrder = UserDefaults.listOrder.getOrDefault()

    var body: some View {
        VStack(spacing: 10) {
            Menu {
                Picker("", selection: $listOrder) {
                    ForEach(ListOrder.allCases, id: \.self) { listOrderCase in
                        Text(listOrderCase.rawValue)
                    }
                }
            } label: {
                BaseButton(
                    imageSystemName: "arrow.up.arrow.down",
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

struct ListOrderButton_Previews: PreviewProvider {
    static var previews: some View {
        ListOrderButton()
    }
}
