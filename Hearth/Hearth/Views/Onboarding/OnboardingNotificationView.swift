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
        VStack {
            Text("Enable notifications")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Text("Stay consistent with daily journal entries and daily Bible verses")
                .font(.body)
                .padding(.horizontal)
            
            Spacer()
            
            /*
            Button(action: viewModel.requestNotificationPermission) {
                Text(viewModel.notificationsEnabled ? "Notifications Enabled ✅" : "Enable Notifications")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.notificationsEnabled ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
             */

            if viewModel.notificationsEnabled {
                VStack {
                    Text("Set Reminder Times")
                        .font(.headline)
                        .padding(.top)

                    VStack(alignment: .leading) {
                        Text("Daily Journal Reminder")
                            .font(.subheadline)
                        DatePicker("Select Time", selection: $viewModel.dailyJournalTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    }
                    .padding()

                    VStack(alignment: .leading) {
                        Text("New Bible Verse Reminder")
                            .font(.subheadline)
                        DatePicker("Select Time", selection: $viewModel.bibleVerseTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    }
                    .padding()
                    
                    Button(action: viewModel.scheduleReminders) {
                        Text("Save Reminders")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.top)
                }
            }

            Spacer()

            Button("Next") {
                viewModel.syncUserActivity()
                currentStep = 2
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        .onChange(of: currentStep, { oldValue, newStep in
            if newStep == 1 {
                viewModel.checkNotificationStatus()
            }
        })
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


/*
#Preview {
    OnboardingNotificationView()
}
*/
