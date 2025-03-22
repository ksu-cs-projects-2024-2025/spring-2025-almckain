//
//  ProfileView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/6/25.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @AppStorage("isOnboardingComplete") private var isOnboardingComplete: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            if let user = viewModel.user {
                Text("Hello, \(user.firstName) \(user.lastName)!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            } else {
                ProgressView()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Notification Settings")
                    .font(.customTitle2)
                    .fontWeight(.semibold)
                
                if notificationViewModel.notificationsEnabled {
                    HStack {
                        Text("Daily Journal:")
                        Spacer()
                        DatePicker(
                            "",
                            selection: $notificationViewModel.dailyJournalTime,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.compact)
                    }
                    .padding(.vertical, 5)
                    
                    HStack {
                        Text("Bible Verse:")
                        Spacer()
                        DatePicker(
                            "",
                            selection: $notificationViewModel.bibleVerseTime,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.compact)
                    }
                    .padding(.vertical, 5)
                    
                    HStack {
                        Text("Weekly Reflection:")
                        Spacer()
                        DatePicker(
                            "",
                            selection: $notificationViewModel.weeklyReflectionTime,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.compact)
                    }
                    .padding(.vertical, 5)
                    
                    Button("Update Reminder Times") {
                        notificationViewModel.scheduleReminders()
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Text("Notifications are disabled.")
                        .foregroundStyle(.parchmentMedium)
                    
                    Button("Enable Notifications") {
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .background(Color(uiColor: .systemGroupedBackground))
            .clipShape(
                RoundedRectangle(cornerRadius: 12)
            )
            .shadow(radius: 2)
            
            Button("Log Out") {
                viewModel.logout {
                    isOnboardingComplete = false
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .onAppear {
            viewModel.fetchUserData()
        }
    }
}

#Preview {
    ProfileView()
}
