//
//  TextFieldDynamicWidth.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/17/23.
//

import SwiftUI

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

import Foundation

// MARK: - TextFieldDynamicWidth

struct TextFieldDynamicWidth: View {
    var text: Binding<String>
    var placeholder: String
    var isEditing: Binding<Bool>?

    var body: some View {
        ZStack {
            Text(text.wrappedValue.isEmpty ? placeholder : text.wrappedValue)
                .background(GlobalGeometryGetter(rect: $textRect)).layoutPriority(1)
                .allowsHitTesting(false)
                .opacity(0)
            HStack {
                TextField(placeholder, text: text, onEditingChanged: { isEditing in
                    self.isEditing?.wrappedValue = isEditing
                })
                .placeholder(when: text.wrappedValue.isEmpty, placeholder: {
                    Text(placeholder).foregroundColor(Color(UIColor.systemGray))
                })
                .frame(width: textRect.width)
            }
        }
    }

    @State private var textRect = CGRect()

    init(text: Binding<String>, placeholder: String, isEditing: Binding<Bool>? = nil) {
        self.text = text
        self.placeholder = placeholder
        self.isEditing = isEditing
    }
}
