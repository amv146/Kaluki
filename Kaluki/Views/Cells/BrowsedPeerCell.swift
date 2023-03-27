//
//  BrowsedPeerCell.swift
//  MultipeerChat
//
//  Created by Hesham Salama on 3/22/20.
//  Copyright © 2020 Hesham Salama. All rights reserved.
//
import SwiftUI

struct BrowsedPeerCell: View {
    let buttonText: String
    let statusText: String
    var action: (() -> ())?
    
    var body: some View {
        HStack {
            Button(action: {
                self.action?()
            }) {
                Text(buttonText)
            }.foregroundColor(.black).padding(.leading)
            Spacer()
            Text(statusText).foregroundColor(.black).padding(.trailing)
        }
    }
}

struct BrowsedPeerCell_Previews: PreviewProvider {
    static var previews: some View {
        BrowsedPeerCell(buttonText: "Peer1", statusText: "Connecting")
    }
}
