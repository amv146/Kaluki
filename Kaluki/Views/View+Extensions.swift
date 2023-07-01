//
//  ViewExtensions.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/26/23.
//

import SwiftUI

// MARK: - RoundedCorner

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - DismissKeyboardOnTap

public struct DismissKeyboardOnTap: ViewModifier {

    private var tapGesture: some Gesture {
        TapGesture().onEnded(endEditing)
    }

    public func body(content: Content) -> some View {
        #if os(macOS)
        return content
        #else
        return content.gesture(tapGesture)
        #endif
    }

    private func endEditing() {
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?.windows
            .filter(\.isKeyWindow)
            .first?.endEditing(true)
    }
}

public extension View {
    func addBorder(
        _ content: some ShapeStyle,
        width: CGFloat = 1,
        cornerRadius: CGFloat,
        corners: UIRectCorner = .allCorners
    ) -> some View {
        let roundedRect = Rectangle()
            .cornerRadius(cornerRadius, corners: corners)

        return clipShape(roundedRect)
            .overlay(roundedRect.stroke(content, lineWidth: width))
    }

    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some Shape {
        RoundedCorner(radius: radius, corners: corners)
    }

    func grayShadow() -> some View {
        modifier(GrayShadowModifier())
    }

    @ViewBuilder
    func `if`(_ condition: Bool, transform: (Self) -> some View) -> some View {
        if condition { transform(self) }
        else { self }
    }

    func placeholder(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> some View
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }

    func imagePicker(
        isPresented: Binding<Bool>,
        sourceType _: UIImagePickerController.SourceType,
        onImagePicked: @escaping (UIImage) -> Void
    ) -> some View {
        sheet(isPresented: isPresented, content: {
            ImagePickerView(sourceType: .photoLibrary, onImagePicked: onImagePicked)
        })
    }

    func tapDismissesKeyboard() -> some View {
        modifier(DismissKeyboardOnTap())
    }
}
