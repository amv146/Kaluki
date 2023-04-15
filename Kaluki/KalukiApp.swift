//
//  KalukiApp.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/21/23.
//

import FirebaseCore
import SwiftUI

@main
struct KalukiApp: App {
    var body: some Scene {
        WindowGroup {
            LandingPageView()
                .environmentObject(AppState.shared)
        }
    }

    init() {
        FirebaseApp.configure()

        NotificationHandler.startNotifications()
    }

}
