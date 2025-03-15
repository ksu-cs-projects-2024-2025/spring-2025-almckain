//
//  OnboardingNotificationView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/26/25.
//

import SwiftUI

struct OnboardingNotificationView: View {
    @Binding var currentStep: Int
    @StateObject private var viewModel = NotificationViewModel()
    
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
                
                if viewModel.notificationsEnabled {
                    Rectangle()
                        .fill(Color.parchmentDark)
                        .frame(height: 1)
                        .padding(.vertical)
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Set Reminder Times")
                                .font(.headline)
                                .padding(.vertical, 10)
                            
                            VStack(alignment: .leading) {
                                Text("Daily Journal Reminder")
                                    .font(.subheadline)
                                DatePicker("Select Time", selection: $viewModel.dailyJournalTime, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                            }
                            .padding(.vertical, 15)
                            
                            VStack(alignment: .leading) {
                                Text("New Bible Verse Reminder")
                                    .font(.subheadline)
                                DatePicker("Select Time", selection: $viewModel.bibleVerseTime, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                            }
                            .padding(.vertical, 15)
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                Spacer()
                if viewModel.notificationsEnabled {
                    Text("You can change the notification times now or in the app settings later.")
                        .foregroundStyle(.hearthEmberMain)
                        .font(.caption)
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                        .multilineTextAlignment(.center)
                }
                
                Button(action: {
                    viewModel.scheduleReminders()
                    viewModel.syncUserActivity()
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
                    viewModel.checkNotificationStatus()
                }
            }
            .alert(isPresented: $viewModel.showNotificationAlert) {
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
}

