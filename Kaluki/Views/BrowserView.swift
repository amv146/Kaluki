//
//  BrowserView.swift
//  MultipeerChat
//
//  Created by Hesham Salama on 3/20/20.
//  Copyright © 2020 Hesham Salama. All rights reserved.
//
import MultipeerConnectivity
import SwiftUI

struct BrowserView: View
{
    // MARK: Lifecycle

    init(hosts: [BrowsedPeer], action: @escaping (BrowsedPeer) -> Void)
    {
        viewModel = BrowserViewModel(hosts: hosts, action: action)
    }

    // MARK: Internal

    @State var pressed = false
    @ObservedObject var viewModel: BrowserViewModel

    var body: some View
    {
        ZStack
        {
            BackgroundView()
            ScrollView
            {
                VStack
                {
                    ForEach(viewModel.hosts)
                    { host in
                        HostCellView(
                            peer: host
                        )
                        {
                            pressed = true
                            viewModel.peerClicked(browsedPeer: host)
                        }
                    }
                    Spacer()
                }
                .padding(.top, 30)
                .disabled(pressed)
            }
        }
        .navigationBarTitle(Text("Join Game"))
        .onAppear(perform: {
            pressed = false
        })
    }

    // MARK: Private
}

let firebasePlayer2 = FirebasePlayer(displayName: "Alex", id: "09230D0D-C50B-4D6A-A0FA-CE465B34155D", profileImage: Constants.defaultProfileImage)

let firebasePlayer3 = FirebasePlayer(displayName: "Hi", id: "09230D0D-C50B-4D6A-A0FA-CE465B34155D", profileImage: Constants.defaultProfileImage)

struct BrowserView_Previews: PreviewProvider
{
    static var previews: some View
    {
        ZStack
        {
            BrowserView(hosts: [
                BrowsedPeer(
                    peerID: MCPeerID(displayName: "Alex"),
                    gameID: "123",
                    player: firebasePlayer2), BrowsedPeer(
                    peerID: MCPeerID(displayName: "Hi"),
                    gameID: "123",
                    player: firebasePlayer3),
            ])
            { _ in
            }
        }
    }
}
