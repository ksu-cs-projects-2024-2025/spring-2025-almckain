//
//  NotificationSettingsCard.swift
//  Hearth
//
//  Created by Aaron McKain on 4/16/25.
//

import SwiftUI

struct NotificationSettingsCard: View {
    
    @ObservedObject var profileViewModel: ProfileViewModel
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    
    var body: some View {
        CardView {
            VStack(spacing: 10) {
                HStack {
                    Text("Notification Settings")
                        .font(.customTitle3)
                        .foregroundStyle(.hearthEmberMain)
                    Spacer()
                }
                
                CustomDivider(height: 2, color: .hearthEmberDark)
                
                if notificationViewModel.notificationsEnabled {
                    VStack(spacing: 16) {
                        NotificationSettingRow(
                            title: "Daily Journal Reminder",
                            isEnabled: $notificationViewModel.isJournalReminderEnabled,
                            time: $notificationViewModel.dailyJournalTime
                        )
                        
                        NotificationSettingRow(
                            title: "Bible Verse Reminder",
                            isEnabled: $notificationViewModel.isBibleVerseReminderEnabled,
                            time: $notificationViewModel.bibleVerseTime
                        )
                        
                        NotificationSettingRow(
                            title: "Weekly Reflection",
                            isEnabled: $notificationViewModel.isWeeklyReflectionReminderEnabled,
                            time: $notificationViewModel.weeklyReflectionTime,
                            isTimeEditable: false
                        )
                        
                        CapsuleButton(
                            title: "Update Reminder Times",
                            style: .filled,
                            foregroundColor: .parchmentLight,
                            backgroundColor: .hearthEmberMain,
                            action: {
                                notificationViewModel.scheduleReminders()
                            }
                        )
                        
                    }
                } else {
                    VStack {
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
            }
        }
    }
}
