//
//  KalukiApp.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/21/23.
//

import SwiftUI

@main
struct KalukiApp: App {
    // MARK: Lifecycle

    init() {
        MultipeerNetwork.startNetwork()
    }

    // MARK: Internal

    var body: some Scene {
        WindowGroup {
            LandingPageView()
        }
    }
}
