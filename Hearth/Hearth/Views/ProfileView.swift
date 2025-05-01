//
//  ProfileView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/6/25.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var profileViewModel = ProfileViewModel()
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @AppStorage("isOnboardingComplete") private var isOnboardingComplete: Bool = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.parchmentLight
                    .ignoresSafeArea()
                ScrollView {
                    LazyVStack(spacing: 15) {
                        UserCard(profileViewModel: profileViewModel)
                        
                        // Stats Card
                        UserStatsCard(profileViewModel: profileViewModel)
                        
                        // Notification Settings Card
                        NotificationSettingsCard(profileViewModel: profileViewModel)
                        
                        PrivacyCard(profileViewModel: profileViewModel, isOnboardingComplete: $isOnboardingComplete)
                        
                        CapsuleButton(
                            title: "Log Out",
                            style: .filled,
                            foregroundColor: .parchmentLight,
                            backgroundColor: .hearthEmberMain,
                            action: {
                                profileViewModel.logout {
                                    isOnboardingComplete = false
                                    profileViewModel.clearAllUserDefaults()
                                }
                            }
                        )
                        .padding(.horizontal, 10)
                        
                    }
                    .padding(.vertical, 15)
                    .navigationTitle("Profile")
                    .navigationBarTitleDisplayMode(.large)
                }
            }
            .onAppear {
                profileViewModel.fetchUserData()
                notificationViewModel.checkNotificationStatus()
                let appearance = profileViewModel.navBarAppearance()
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

#Preview {
    ProfileView()
}
