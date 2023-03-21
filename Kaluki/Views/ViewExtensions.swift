//
//  ViewExtensions.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/26/23.
//

import SwiftUI

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

public extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some Shape {
        RoundedCorner(radius: radius, corners: corners)
    }

    func addBorder<S>(_ content: S, width: CGFloat = 1, cornerRadius: CGFloat, corners: UIRectCorner) -> some View where S: ShapeStyle {
        let roundedRect = Rectangle()
            .cornerRadius(cornerRadius, corners: corners)

        return clipShape(roundedRect)
            .overlay(roundedRect.stroke(content, lineWidth: width))
    }
}
