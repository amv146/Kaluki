//
//  HostCellView.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/30/23.
//

import MultipeerConnectivity
import SwiftUI

struct HostCellView: View
{
    @State var peer: BrowsedPeer

    var action: (() -> Void)?
    @State var pressed = false

    var body: some View
    {
        VStack(spacing: 0)
        {
            HStack
            {
                VStack(alignment: .leading)
                {
                    HStack
                    {
                        Image(uiImage: peer.player.profileImage)
                            .modifier(BorderedCircleImageModifier(borderWidth: 1.25, size: 50))
                            .padding(.horizontal, 10)
                        Text("\(peer.player.displayName)'s Game")
                            .font(.system(size: 17, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(10)
            .background(pressed ? Color.gray.opacity(0.2) : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .gray, radius: 2, x: 0, y: 0)
            .padding(.horizontal, 15)
        }
        .onLongPressGesture(minimumDuration: 0.01)
        {
            withAnimation
            {
                pressed.toggle()
                action?()
            }
        }
    }
}

struct HostCellView_Previews: PreviewProvider
{
    static var previews: some View
    {
        HostCellView(
            peer: BrowsedPeer(peerID: MCPeerID(displayName: "Alex"), gameID: "123", player: FirebasePlayer(displayName: "Alex", id: "09230D0D-C50B-4D6A-A0FA-CE465B34155D", profileImage: UIImage(systemName: "person.fill")!))
        )
    }
}
