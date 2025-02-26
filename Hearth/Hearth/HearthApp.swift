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
    @AppStorage("isOnboardingComplete") private var isOnboardingComplete: Bool = false

    init() {
        FirebaseApp.configure()
        // Testing purposes to control which screen is being presented
        self.isOnboardingComplete = false
    }
    
    var body: some Scene {
        WindowGroup {
            if isOnboardingComplete {
                // Parent container for the tab bar and all children views
                MainView()
            } else {
                // Parent container for the onboarding sequence
                // OnboardingView()
                SplashPageView()
            }
            
        }
    }
}
