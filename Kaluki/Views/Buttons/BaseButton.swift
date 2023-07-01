//
//  BaseButtonView.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/31/23.
//

import SwiftUI

// MARK: - BaseButton

struct BaseButton: View {
    let action: () -> Void
    let size: CGFloat
    let imageSystemName: String

    var body: some View {
        Button(action: action) {
            Image(systemName: imageSystemName)
                .font(.system(size: size, weight: .bold))
                .foregroundColor(.white)
                .padding(size * 2 / 3)
                .padding(.horizontal, 4)
                .background(color)
                .clipShape(Circle())
                .cornerRadius(size)
                .grayShadow()
        }
    }

    @Environment(\.isEnabled) private var isEnabled: Bool

    private var color: Color {
        isEnabled ? Color.blue : Color.gray
    }

    init(imageSystemName: String, size: CGFloat, action: @escaping () -> Void = {}) {
        self.action = action
        self.size = size
        self.imageSystemName = imageSystemName
    }

}

// MARK: - BaseButtonView_Previews

struct BaseButtonView_Previews: PreviewProvider {
    static var previews: some View {
        BaseButton(imageSystemName: "chevron.left", size: 10)
    }
}
