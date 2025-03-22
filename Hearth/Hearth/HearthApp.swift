//
//  HearthApp.swift
//  Hearth
//
//  Created by Aaron McKain on 2/6/25.
//

import SwiftUI
import SwiftData
import Firebase

@main
struct HearthApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @AppStorage("isOnboardingComplete") private var isOnboardingComplete: Bool = false
    
    @StateObject var notificationViewModel = NotificationViewModel()
    
    init() {
        FirebaseApp.configure()
        // Testing purposes to control which screen is being presented
        //self.isOnboardingComplete = false
        // UserDefaults.standard.removeObject(forKey: "LastUsedBibleVerseIndex")
        // UserDefaults.standard.removeObject(forKey: "LastBibleVerseUpdateDate")
    }
    
    var body: some Scene {
        WindowGroup {
            if isOnboardingComplete {
                // Parent container for the tab bar and all children views
                MainView()
                    .environmentObject(notificationViewModel)
                    .onAppear {
                        appDelegate.notificationViewModel = notificationViewModel
                    }
            } else {
                // Parent container for the onboarding sequence
                // OnboardingView()
                SplashPageView()
                    .environmentObject(notificationViewModel)
                    .onAppear {
                        appDelegate.notificationViewModel = notificationViewModel
                    }
            }
            
        }
    }
}
