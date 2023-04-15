//
//  AddScoreButtonView.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/25/23.
//

import SwiftUI

struct AddScoreButton: View
{
    @Binding var score: String
    let action: () -> Void

    var body: some View
    {
        NavigationLink(destination: AddScoreView(score: $score, action: action))
        {
            Image(systemName: "plus")
                .font(.system(size: 40, weight: .bold))
                .padding(10)
                .modifier(BlueWhiteModifier(cornerRadius: 40, disabled: !isEnabled))
                .clipShape(Circle())
        }
    }

    @Environment(\.isEnabled) private var isEnabled: Bool
}

struct AddScoreButtonView_Previews: PreviewProvider
{
    static var previews: some View
    {
        AddScoreButton(score: .constant("0"), action: {})
    }
}
