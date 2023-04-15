//
//  ChangeableScoreView.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/6/23.
//

import SwiftUI

// MARK: - TextFieldDynamicWidth

struct TextFieldDynamicWidth: View {
    var text: Binding<String>
    var title: String
    var isEditing: Binding<Bool>?
    
    init(text: Binding<String>, title: String, isEditing: Binding<Bool>? = nil) {
        self.text = text
        self.title = title
        self.isEditing = isEditing
    }

    var body: some View {
        ZStack {
            Text(text.wrappedValue == "" ? title : text.wrappedValue)
                .background(GlobalGeometryGetter(rect: $textRect)).layoutPriority(1)
                .opacity(0)
            HStack {
                TextField(title, text: text, onEditingChanged: { isEditing in
                    self.isEditing?.wrappedValue = isEditing
                })
                .frame(width: textRect.width)
            }
        }
    }

    @State private var textRect = CGRect()
}

// MARK: - GlobalGeometryGetter

///
///  GlobalGeometryGetter
///
/// source: https://stackoverflow.com/a/56729880/3902590
///
struct GlobalGeometryGetter: View {
    @Binding var rect: CGRect

    var body: some View {
        GeometryReader { geometry in
            makeView(geometry: geometry)
        }
    }

    func makeView(geometry: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            rect = geometry.frame(in: .global)
        }

        return Rectangle().fill(Color.clear)
    }
}

// MARK: - ChangeableScoreView

struct ChangeableScoreView: View {
    @State var title: String
    @Binding var score: String
    @Binding var isEditing: Bool

    var body: some View {
        VStack {
            TextFieldDynamicWidth(text: $score.max(3), title: "", isEditing: $isEditing)
                .font(.system(size: 18, weight: .bold))
                .keyboardType(.numberPad)
                .textFieldStyle(DefaultTextFieldStyle())
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
