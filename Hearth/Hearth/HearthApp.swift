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
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    // Testing purposes to control which screen is being presented
    init() {
        FirebaseApp.configure()
        self.hasCompletedOnboarding = false
    }
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                // Parent container for the tab bar and all children views
                MainView()
            } else {
                // Parent container for the onboarding sequence
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
            
        }
    }
}
