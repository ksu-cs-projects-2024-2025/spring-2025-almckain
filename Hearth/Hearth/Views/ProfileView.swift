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

struct NotificationSettingRow: View {
    let title: String
    @Binding var isEnabled: Bool
    @Binding var time: Date
    var isTimeEditable: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Toggle(isOn: $isEnabled) {
                    Text(title)
                        .font(.customBody1)
                        .foregroundStyle(.parchmentDark)
                }
            }
            
            if isEnabled && isTimeEditable {
                DatePicker(
                    "Reminder Time",
                    selection: $time,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.compact)
                .labelsHidden()
            } else if title == "Weekly Reflection" {
                Text("Time: \(formattedTime(date: time))")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
        .padding(.vertical, 5)
    }
    
    private func formattedTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}



#Preview {
    ProfileView()
}
