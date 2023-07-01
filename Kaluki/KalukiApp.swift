//
//  KalukiApp.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/21/23.
//

import FirebaseCore
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        NotificationHandler.startNotifications()
        return true
    }
}

@main
struct KalukiApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    var body: some Scene {
        WindowGroup {
            LandingPageView()
                .environmentObject(AppState.shared)
        }
    }

}
