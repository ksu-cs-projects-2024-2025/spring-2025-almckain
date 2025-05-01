//
//  HearthApp.swift
//  Hearth
//
//  Created by Aaron McKain on 2/6/25.
//

import SwiftUI
import SwiftData
import Firebase
import FirebaseAuth

@main
struct HearthApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @AppStorage("isOnboardingComplete") private var isOnboardingComplete: Bool = false
    
    @State private var isLoading = true
    @StateObject var notificationViewModel = NotificationViewModel()
    
    private let hasRunBeforeKey = "com.Aaron-McKain.Hearth.hasRunBefore"
    
    init() {
        FirebaseApp.configure()
        handleFreshInstall()
        // Testing purposes to control which screen is being presented
        //self.isOnboardingComplete = false
        // UserDefaults.standard.removeObject(forKey: "LastUsedBibleVerseIndex")
        // UserDefaults.standard.removeObject(forKey: "LastBibleVerseUpdateDate")
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isLoading {
                    ProgressView()
                } else {
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
            .onAppear(perform: checkUserStatus)
        }
    }
    
    private func handleFreshInstall() {
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: hasRunBeforeKey) {
            do {
                try Auth.auth().signOut()
                print("DEBUG: User signed out on fresh install")
            } catch {
                print("ERROR: Failed to sign out on fresh install")
            }
            defaults.set(true, forKey: hasRunBeforeKey)
            defaults.synchronize()
        }
    }
    
    private func checkUserStatus() {
        guard let user = Auth.auth().currentUser else {
            // No user logged in, show onboarding
            isOnboardingComplete = false
            isLoading = false
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let onboardingCompleteFromFirestore = data?["isOnboardingComplete"] as? Bool ?? false
                isOnboardingComplete = onboardingCompleteFromFirestore
            } else {
                isOnboardingComplete = false
            }
            isLoading = false
        }
    }
}
