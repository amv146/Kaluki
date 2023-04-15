//
//  BlueWhiteStyle.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/12/23.
//

import SwiftUI

struct BlueWhiteModifier: ViewModifier
{
    let cornerRadius: CGFloat
    let disabled: Bool
    
    private var backgroundColor: Color {
        disabled ? .gray : .blue
    }
    
    init(cornerRadius: CGFloat = 0.0, disabled: Bool = false) {
        self.cornerRadius = cornerRadius
        self.disabled = disabled
    }
    
    func body(content: Content) -> some View
    {
        content
            .foregroundColor(.white)
            .background(backgroundColor.animation(.easeInOut))
            .cornerRadius(cornerRadius)
            .grayShadow()
    }
}
