//
//  FloatyView.swift
//  Kaluki
//
//  Created by Alex Vallone on 4/25/23.
//

import SwiftUI

struct FloatyView: UIViewRepresentable {
    typealias UIViewType = Floaty
    
    func makeUIView(context: Context) -> FloatyView.UIViewType {
        let floaty = Floaty()
        floaty.buttonColor = .systemBlue
        floaty.buttonImage = UIImage(systemName: "plus")
//        floaty.fabDelegate = context.coordinator
        
        return floaty
    }
    
    func updateUIView(_ uiView: Floaty, context: Context) {
        // Do nothing
    }
}
