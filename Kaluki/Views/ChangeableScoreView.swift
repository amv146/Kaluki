//
//  ChangeableScoreView.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/6/23.
//

import SwiftUI

// MARK: - ChangeableScoreView

struct ChangeableScoreView: View {
    @State var title: String
    @Binding var score: String
    @Binding var isEditing: Bool

    var body: some View {
        VStack {
            TextFieldDynamicWidth(
                text: $score.max(3),
                placeholder: "",
                isEditing: $isEditing
            )
            .font(.system(size: 18, weight: .bold))
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)

            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.gray)
        }
    }
}

// MARK: - ChangeableScoreView_Previews

struct ChangeableScoreView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeableScoreView(
            title: "Score",
            score: .constant("0"),
            isEditing: .constant(false)
        )
    }
}
