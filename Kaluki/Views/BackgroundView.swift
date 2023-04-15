//
//  BackgroundView.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/10/23.
//

import SwiftUI

struct BackgroundView: View
{
    var body: some View
    {
        Color.gray.opacity(0.1).ignoresSafeArea(edges: .all)
    }
}

struct BackgroundView_Previews: PreviewProvider
{
    static var previews: some View
    {
        BackgroundView()
    }
}
