//
//  OnboardingNotificationView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/26/25.
//

import SwiftUI

struct OnboardingNotificationView: View {
    @Binding var currentStep: Int
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    
    @AppStorage("isJournalReminderEnabled") private var isJournalReminderEnabled = true
    @AppStorage("isBibleVerseReminderEnabled") private var isBibleVerseReminderEnabled = true
    @AppStorage("isWeeklyReflectionReminderEnabled") private var isWeeklyReflectionReminderEnabled = true
    
    var body: some View {
        ZStack {
            Color.warmSandLight
                .ignoresSafeArea()
            
            VStack(spacing: 4) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Allow Notifications")
                        .foregroundStyle(.hearthEmberMain)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Receive a daily Bible verse, journal reminders, and reflection notifications to keep your journey strong.")
                        .foregroundStyle(.parchmentDark)
                        .font(.customBody1)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                if notificationViewModel.notificationsEnabled {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Journal Reminder Card
                            NotificationCardView(
                                title: "Daily Journal",
                                description: "Set a gentle reminder to reflect on your day",
                                iconName: "book.fill",
                                isEnabled: $isJournalReminderEnabled,
                                timePickerView: {
                                    DatePicker("Time", selection: $notificationViewModel.dailyJournalTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .tint(.hearthEmberMain)
                                }
                            )
                            
                            // Bible Verse Card
                            NotificationCardView(
                                title: "Bible Verse",
                                description: "Daily scripture to inspire your walk",
                                iconName: "bookmark.fill",
                                isEnabled: $isBibleVerseReminderEnabled,
                                timePickerView: {
                                    DatePicker("Time", selection: $notificationViewModel.bibleVerseTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .tint(.hearthEmberMain)
                                }
                            )
                            
                            // Weekly Reflection Card
                            NotificationCardView(
                                title: "Weekly Reflection",
                                description: "Sunday morning reflection time",
                                iconName: "sun.max.fill",
                                isEnabled: $isWeeklyReflectionReminderEnabled,
                                timePickerView: {
                                    Text("9:00 AM every Sunday")
                                        .foregroundStyle(.hearthEmberMain)
                                        .font(.subheadline)
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 5)
                                },
                                infoMessage: "Weekly reflection is set for 9:00 AM every Sunday and cannot be changed."
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    Text("You can change these settings anytime in the app.")
                        .foregroundStyle(.hearthEmberMain)
                        .font(.caption)
                }
                
                Spacer()
                
                // Continue Button
                Button(action: {
                    withAnimation(.spring()) {
                        notificationViewModel.saveReminderTimes()
                        notificationViewModel.scheduleReminders()
                        notificationViewModel.syncUserActivity()
                        currentStep = 2
                    }
                }) {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.hearthEmberMain)
                        .foregroundColor(.parchmentLight)
                        .clipShape(RoundedRectangle(cornerRadius: 21))
                        .font(.customButton)
                        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding(.top)
        }
        .onAppear {
            if currentStep == 1 {
                notificationViewModel.checkNotificationStatus()
            }
        }
        .alert(isPresented: $notificationViewModel.showNotificationAlert) {
            Alert(
                title: Text("Enable Notifications"),
                message: Text("Hearth works best with notifications! Please enable notifications in Settings."),
                primaryButton: .default(Text("Open Settings"), action: {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }),
                secondaryButton: .cancel()
            )
        }
    }
}

#Preview {
    OnboardingNotificationView(currentStep: .constant(1))
        .environmentObject(NotificationViewModel())
}

