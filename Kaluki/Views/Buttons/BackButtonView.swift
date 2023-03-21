//
//  BackButtonView.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/25/23.
//

import SwiftUI

struct BackButtonView: View {
    // MARK: Lifecycle

    init(action: @escaping () -> Void = {}) {
        self.action = action
    }

    // MARK: Internal

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .padding(10)
                .padding(.horizontal, 2)
                .background(color)
                .cornerRadius(20)
                .shadow(color: Color.gray.opacity(0.5), radius: 10, x: 0, y: 5)
        }
    }

    // MARK: Private

    @Environment(\.isEnabled) private var isEnabled: Bool

    private var color: Color {
        isEnabled ? Color.blue : Color.gray
    }
}

struct BackButtonView_Previews: PreviewProvider {
    static var previews: some View {
        BackButtonView()
    }
}
