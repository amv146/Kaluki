//
//  LoadingView.swift
//  Kaluki
//
//  Created by Alex Vallone on 5/2/23.
//

import SwiftUI

struct LoadingView: View {
    var frameSize: CGFloat = 20
    @State private var isAnimating = false
    
    var foreverAnimation: Animation {
        Animation
            .spring(response: 0.7, dampingFraction: 0.5, blendDuration: 0)
            .repeatForever(autoreverses: false)
    }
    
    var body: some View {
        Image(systemName: "suit.diamond.fill")
            .resizable()
            .frame(width: frameSize, height: frameSize)
            .foregroundColor(.blue)
            .rotationEffect(Angle(degrees: isAnimating ? 360.0 : 0.0))
            .animation(foreverAnimation)
            .onAppear {
                isAnimating = true
            }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
