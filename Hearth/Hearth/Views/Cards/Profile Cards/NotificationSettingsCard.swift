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
    
    @AppStorage("isJournalReminderEnabled") private var isJournalReminderEnabled = true
    @AppStorage("isBibleVerseReminderEnabled") private var isBibleVerseReminderEnabled = true
    @AppStorage("isWeeklyReflectionReminderEnabled") private var isWeeklyReflectionReminderEnabled = true
    
    var body: some View {
        CardView {
            VStack(spacing: 16) {
                HStack {
                    Text("Notification Settings")
                        .font(.customTitle3)
                        .foregroundStyle(.hearthEmberMain)
                    Spacer()
                }
                
                CustomDivider(height: 2, color: .hearthEmberDark)
                    .padding(.bottom, 4)
                
                if notificationViewModel.notificationsEnabled {
                    VStack(spacing: 20) {
                        NotificationListItem(
                            title: "Daily Journal",
                            description: "Reminder to reflect on your day",
                            iconName: "book.fill",
                            isEnabled: $isJournalReminderEnabled,
                            timeView: {
                                DatePicker("Time", selection: $notificationViewModel.dailyJournalTime, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .tint(.hearthEmberMain)
                            }
                        )
                        
                        Divider()
                            .opacity(0.6)
                        
                        NotificationListItem(
                            title: "Bible Verse",
                            description: "New Bible verse notification",
                            iconName: "bookmark.fill",
                            isEnabled: $isBibleVerseReminderEnabled,
                            timeView: {
                                DatePicker("Time", selection: $notificationViewModel.bibleVerseTime, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .tint(.hearthEmberMain)
                            }
                        )
                        
                        Divider()
                            .opacity(0.6)
                        
                        NotificationListItem(
                            title: "Weekly Reflection",
                            description: "Sunday morning reflection time",
                            iconName: "sun.max.fill",
                            isEnabled: $isWeeklyReflectionReminderEnabled,
                            timeView: {
                                Text(formattedTime(date: notificationViewModel.weeklyReflectionTime))
                                    .foregroundStyle(.hearthEmberMain.opacity(0.7))
                                    .font(.subheadline)
                            },
                            infoMessage: "9:00 AM every Sunday (cannot be changed)"
                        )
                        
                        CapsuleButton(
                            title: "Update Notifications",
                            style: .filled,
                            foregroundColor: .parchmentLight,
                            backgroundColor: .hearthEmberMain,
                            action: {
                                withAnimation(.spring()) {
                                    notificationViewModel.scheduleReminders()
                                }
                            }
                        )
                        .padding(.top, 8)
                    }
                } else {
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: "bell.slash")
                                .font(.title2)
                                .foregroundStyle(.gray)
                            
                            Text("Notifications are currently disabled")
                                .font(.headline)
                                .foregroundStyle(.gray)
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        
                        Button {
                            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(settingsURL)
                            }
                        } label: {
                            Label("Enable in Settings", systemImage: "gear")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.hearthEmberMain)
                                )
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private func formattedTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
