//
//  GrayShadowModifier.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/15/23.
//

import SwiftUI

//
//  BlueWhiteStyle.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/12/23.
//

import SwiftUI

struct GrayShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(
                color: Color.gray.opacity(0.3),
                radius: 5,
                x: 2,
                y: 3
            )
    }
}
