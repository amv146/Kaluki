//
//  BlueBorderedCircleImageStyle.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/12/23.
//

import SwiftUI

struct BorderedCircleImageModifier: ImageModifier
{
    let borderColor: Color
    let borderWidth: CGFloat
    let size: CGFloat

    init(borderColor: Color = .blue, borderWidth: CGFloat = 1, size: CGFloat)
    {
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.size = size
    }

    func body(image: Image) -> some View
    {
        image
            .resizable()
            .circular(borderWidth: 1.25, borderColor: .blue)
            .scaledToFill()
            .frame(width: size, height: size)
    }

}
