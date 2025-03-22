//
//  AppDelegate.swift
//  Hearth
//
//  Created by Aaron McKain on 3/21/25.
//

import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    weak var notificationViewModel: NotificationViewModel?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let identifier = response.notification.request.identifier
        
        if identifier == "weeklyReflectionReminder" {
            notificationViewModel?.shouldShowReflectionCard = Date().isSunday
        }

        completionHandler()
    }
}
