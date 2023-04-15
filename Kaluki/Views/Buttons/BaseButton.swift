//
//  BaseButtonView.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/31/23.
//

import SwiftUI

struct BaseButton: View
{
    // MARK: Lifecycle

    init(imageSystemName: String, size: CGFloat, action: @escaping () -> Void = {})
    {
        self.action = action
        self.size = size
        self.imageSystemName = imageSystemName
    }

    // MARK: Internal

    let action: () -> Void
    let size: CGFloat
    let imageSystemName: String

    var body: some View
    {
        Button(action: action)
        {
            Image(systemName: imageSystemName)
                .font(.system(size: size, weight: .bold))
                .foregroundColor(.white)
                .padding(size * 2 / 3)
                .background(color)
                .clipShape(Circle())
                .cornerRadius(size)
                .grayShadow()
        }
    }

    // MARK: Private

    @Environment(\.isEnabled) private var isEnabled: Bool

    private var color: Color
    {
        isEnabled ? Color.blue : Color.gray
    }
}

struct BaseButtonView_Previews: PreviewProvider
{
    static var previews: some View
    {
        BaseButton(imageSystemName: "chevron.left", size: 10)
    }
}
