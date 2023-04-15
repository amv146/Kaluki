//
//  Image+Extensions.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/12/23.
//

import SwiftUI

extension Image
{
    func circular(borderWidth: CGFloat = 0, borderColor: Color = .white) -> some View
    {
        clipShape(Circle())
            .overlay(Circle().stroke(borderColor, lineWidth: borderWidth))
    }

    func modifier(_ modifier: some ImageModifier) -> some View
    {
        modifier.body(image: self)
    }
}
