//
//  NavigationLazyView.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/24/23.
//

import Foundation
import SwiftUI

struct NavigationLazyView<Content: View>: View
{
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content)
    {
        self.build = build
    }

    var body: Content
    {
        build()
    }
}
