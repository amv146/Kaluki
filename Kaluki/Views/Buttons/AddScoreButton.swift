//
//  AddScoreButtonView.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/25/23.
//

import SwiftUI

// MARK: - AddScoreButton

extension HorizontalAlignment {
    private enum MyLeadingAlignment: AlignmentID {
        static func defaultValue(in dimensions: ViewDimensions) -> CGFloat {
            return dimensions[HorizontalAlignment.center]
        }
    }

    static let myLeading = HorizontalAlignment(MyLeadingAlignment.self)
}

// MARK: - FloatingActionButtonOption

struct FloatingActionButtonOption: View {
    @Binding var shown: Bool
    let text: String
    let imageSystemName: String
    let delay: Double
    let action: (() -> Void)?

    var body: some View {
        HStack {
            Group {
                Text(text)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.trailing)
                    .scaleEffect(shown ? 1 : 0, anchor: .trailing)
                BaseButton(imageSystemName: imageSystemName, size: 20) {
                    action?()

                    withAnimation {
                        shown = false
                    }
                }
                .alignmentGuide(.myLeading) {
                    $0[HorizontalAlignment.center]
                }
                .disabled(!shown)
                .scaleEffect(shown ? 1 : 0, anchor: .center)
            }
            .animation(.easeInOut.delay(delay), value: shown)
        }
    }

    init(
        shown: Binding<Bool>,
        text: String,
        imageSystemName: String,
        delay: Double,
        action: (() -> Void)? = nil
    ) {
        _shown = shown
        self.text = text
        self.imageSystemName = imageSystemName
        self.delay = delay
        self.action = action
    }

}

// MARK: - AddScoreButton

struct AddScoreButton: View {
    @EnvironmentObject var appState: AppState
    @State var isAddScoreViewPresented = false
    @Binding var expanded: Bool
    
    var body: some View {
        ZStack {
            VStack(alignment: .myLeading, spacing: 13) {
                FloatingActionButtonOption(
                    shown: $expanded,
                    text: "Schneid",
                    imageSystemName: "scissors",
                    delay: 0.15
                ) {
                    appState.gameState.addScoreToPlayer(
                        playerID: appState.gameState.currentPlayer.id,
                        score: 0,
                        round: appState.gameState.round,
                        schneid: true
                    )
                }

                FloatingActionButtonOption(
                    shown: $expanded,
                    text: "Win",
                    imageSystemName: "crown",
                    delay: 0.1
                ) {
                    appState.gameState.addScoreToPlayer(
                        playerID: appState.gameState.currentPlayer.id,
                        score: 0,
                        round: appState.gameState.round
                    )
                }

                FloatingActionButtonOption(
                    shown: $expanded,
                    text: "Add Score",
                    imageSystemName: "plus",
                    delay: 0.05
                ) {
                    isAddScoreViewPresented = true
                }

                addScoreButton
            }
            .navigationDestination(
                isPresented: $isAddScoreViewPresented
            ) {
                AddScoreView()
            }
        }
    }

    var addScoreButton: some View {
        Button(action: {
            withAnimation {
                expanded.toggle()
            }

        }) {
            Image(systemName: "plus")
                .rotationEffect(.degrees(expanded ? 45 : 0))
                .font(.system(size: 40, weight: .bold))
                .padding(10)
                .modifier(BlueWhiteModifier(cornerRadius: 40, disabled: !isEnabled))
                .clipShape(Circle())
        }
    }

    @Environment(\.isEnabled) private var isEnabled: Bool

    init(expanded: Binding<Bool>) {
        _expanded = expanded
    }

}

// MARK: - AddScoreButtonView_Previews

struct AddScoreButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AddScoreButton(expanded: .constant(false))
    }
}
