//
//  ContentView.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/21/23.
//

import MultipeerConnectivity
import SwiftUI

struct MainView: View {
    @Environment(\.dismiss) private var dismiss
    @State var isLinkActive = false
    @ObservedObject var mainViewModel = MainViewModel()

    var backButton: some View { Button(action: {
        self.dismiss()
        self.isLinkActive = false
        MultipeerNetwork.leaveLobby()
    }) {
        HStack {
            Text("Go back")
        }
    }
    }

    var scoreboardView: NavigationLazyView<some View> {
        NavigationLazyView(ScoreboardView().navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: backButton)
            .navigationTitle("")
        )
    }

    var body: some View {
        NavigationView {
            VStack {
                Button(action: {
                    MultipeerNetwork.player.hostGame()
                    self.isLinkActive = true
                }) {
                    Text("Host Game")
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
                .overlay(
                    NavigationLink(
                        destination: scoreboardView,
                        isActive: $isLinkActive,
                        label: { EmptyView() }
                    )
                )
                NavigationLink(destination: BrowserView(browser: MultipeerNetwork.browser!, session: MultipeerNetwork.session!) { peerID in
                    MultipeerNetwork.player.joinGame(host: peerID)
                    self.isLinkActive = true
                }) {
                    Text("Join Game")
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
            }
            .padding()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
