//
//  NotificationCenter.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/31/23.
//

import NotificationCenter
import SwiftUI

class NotificationHandler: NSObject, UNUserNotificationCenterDelegate
{
    static let shared = NotificationHandler()
    static var gameInfoRequest: UNNotificationRequest?

    static var notificationCenter: UNUserNotificationCenter
    {
        UNUserNotificationCenter.current()
    }

    static func startNotifications()
    {
        NotificationHandler.notificationCenter.delegate = shared
        NotificationHandler.notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
        { granted, _ in
            if granted
            {
                DispatchQueue.main.async
                {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    static func updateRoundNotification(roundDetails: RoundDetails)
    {
        NotificationHandler.notificationCenter.removeAllDeliveredNotifications()

        let content = UNMutableNotificationContent()

        content.title = "Round \(roundDetails.round)"
        content.body = "\(roundDetails.roundType)"
        content.userInfo = ["roundDetails": try! roundDetails.encoded()]
        content.interruptionLevel = .passive
        content.categoryIdentifier = "roundNotification"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

        gameInfoRequest = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        NotificationHandler.notificationCenter.add(gameInfoRequest!)
    }

    /** Handle notification when app is in background */
    func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response:
        UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void)
    {
        let notiName = Notification.Name(response.notification.request.identifier)
        NotificationCenter.default.post(name: notiName, object: response.notification.request.content)
        completionHandler()
        print("Notification received")
    }

    /** Handle notification when the app is in foreground */
    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        let notiName = Notification.Name(notification.request.identifier)
        print(notiName)
        NotificationCenter.default.post(name: notiName, object: notification.request.content)
        completionHandler([.list])
    }
}
