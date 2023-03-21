//
//  AddScoreButtonView.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/25/23.
//

import SwiftUI

struct AddScoreButtonView: View {
    // MARK: Lifecycle

    init(action: @escaping () -> Void = {}) {
        self.action = action
    }

    // MARK: Internal

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.white)
                .padding(10)
                .background(color.animation(.easeInOut))
                .cornerRadius(40)
                .shadow(color: Color.gray.opacity(0.5), radius: 10, x: 0, y: 5)
        }
    }

    // MARK: Private

    @Environment(\.isEnabled) private var isEnabled: Bool

    private var color: Color {
        isEnabled ? Color.blue : Color.gray
    }
}

struct AddScoreButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AddScoreButtonView()
    }
}
