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
    
    var body: some View {
        ZStack {
            Color.warmSandLight
                .ignoresSafeArea()
            VStack {
                HStack {
                    Text("Allow Notifications")
                        .foregroundStyle(.hearthEmberMain)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                Text("Receive a daily Bible verse, gentle journal reminders, and prayer request notifications to keep your faith journey strong.")
                    .foregroundStyle(.hearthEmberMain)
                    .font(.body)
                    .padding(.horizontal)
                    .padding(.top, 5)
                    .multilineTextAlignment(.center)
                
                if notificationViewModel.notificationsEnabled {
                    Rectangle()
                        .fill(Color.parchmentDark)
                        .frame(height: 1)
                        .padding(.vertical)
                    HStack {
                        
                        VStack(alignment: .leading, spacing: 20) {
                            Toggle("Daily Journal Reminder", isOn: $notificationViewModel.isJournalReminderEnabled)
                                .font(.headline)
                            
                            if notificationViewModel.isJournalReminderEnabled {
                                HStack {
                                    Text("Reminder Time:")
                                        .foregroundStyle(.parchmentDark)
                                        .font(.customBody1)
                                    
                                    Spacer()
                                    
                                    DatePicker("Time", selection: $notificationViewModel.dailyJournalTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                }
                            }
                            
                            Toggle("Bible Verse Reminder", isOn: $notificationViewModel.isBibleVerseReminderEnabled)
                                .font(.headline)
                            
                            if notificationViewModel.isBibleVerseReminderEnabled {
                                HStack {
                                    Text("Reminder Time:")
                                        .foregroundStyle(.parchmentDark)
                                        .font(.customBody1)
                                    
                                    Spacer()
                                    
                                    DatePicker("Time", selection: $notificationViewModel.bibleVerseTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                }
                            }
                            
                            Toggle("Weekly Reflection Reminder", isOn: $notificationViewModel.isWeeklyReflectionReminderEnabled)
                                .font(.headline)
                            
                            if notificationViewModel.isWeeklyReflectionReminderEnabled {
                                HStack {
                                    Text("Reflection reminder time is 9:30am every sunday and cannot be changed.")
                                        .foregroundStyle(.parchmentDark)
                                        .font(.customBody1)
                                }
                            }
                            /*
                             Text("Set Reminder Times")
                             .font(.headline)
                             .padding(.vertical, 10)
                             
                             VStack(alignment: .leading) {
                             Text("Daily Journal Reminder")
                             .font(.subheadline)
                             DatePicker("Select Time", selection: $notificationViewModel.dailyJournalTime, displayedComponents: .hourAndMinute)
                             .datePickerStyle(.compact)
                             .labelsHidden()
                             }
                             .padding(.vertical, 15)
                             
                             VStack(alignment: .leading) {
                             Text("New Bible Verse Reminder")
                             .font(.subheadline)
                             DatePicker("Select Time", selection: $notificationViewModel.bibleVerseTime, displayedComponents: .hourAndMinute)
                             .datePickerStyle(.compact)
                             .labelsHidden()
                             }
                             .padding(.vertical, 15)
                             */
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                Spacer()
                if notificationViewModel.notificationsEnabled {
                    Text("You can change the notification times now or in the app settings later.")
                        .foregroundStyle(.hearthEmberMain)
                        .font(.caption)
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                        .multilineTextAlignment(.center)
                }
                
                Button(action: {
                    notificationViewModel.saveReminderTimes()
                    notificationViewModel.scheduleReminders()
                    notificationViewModel.syncUserActivity()
                    currentStep = 2
                }) {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.hearthEmberMain)
                        .foregroundColor(.parchmentLight)
                        .clipShape(RoundedRectangle(cornerRadius: 21))
                        .font(.customButton)
                }
                
            }
            .padding()
            /*
             .onChange(of: currentStep, { oldValue, newStep in
             print("currentStep changed from \(oldValue) to \(newStep)")
             if newStep == 1 {
             viewModel.checkNotificationStatus()
             }
             })
             */
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
}



#Preview {
    OnboardingNotificationView(currentStep: .constant(1))
        .environmentObject(NotificationViewModel())
}

