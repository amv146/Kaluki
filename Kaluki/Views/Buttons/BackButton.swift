//
//  BackButtonView.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/25/23.
//

import SwiftUI

struct BackButton: View
{
    // MARK: Internal

    let action: () -> Void

    var body: some View
    {
        Button(action: action)
        {
            Image(systemName: "chevron.left")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .padding(10)
                .padding(.horizontal, 4)
                .background(color)
                .clipShape(Circle())
                .cornerRadius(30)
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

struct BackButtonView_Previews: PreviewProvider
{
    static var previews: some View
    {
        BackButton {}
    }
}
