//
//  AddPrayerShhetView.swift
//  Hearth
//
//  Created by Aaron McKain on 4/3/25.
//

import SwiftUI

struct AddPrayerSheetView: View {
    @ObservedObject var prayerViewModel: PrayerViewModel
    @Environment(\.dismiss) var dismiss
    @State private var prayerContent: String = ""
    @State private var reminderDate: Date = Date()
    @State private var receiveReminder: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.warmSandLight
                    .ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 40) {
                        VStack {
                            HStack {
                                Text("Prayer: ")
                                    .font(.customHeadline1)
                                    .foregroundStyle(.parchmentDark)
                                Spacer()
                            }
                            TextEditor(text: $prayerContent)
                                .frame(minHeight: 100, maxHeight: 120)
                                .padding(8)
                                .background(Color.white)
                                .cornerRadius(12)
                                .onChange(of: prayerContent) { _, newValue in
                                    let filtered = newValue.filter { $0 != "\n" }
                                    if filtered.count > 50 {
                                        prayerContent = String(filtered.prefix(100))
                                    }
                                }
                            
                            HStack {
                                Spacer()
                                Text("\(prayerContent.count)/100")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        HStack {
                            Text("Receive Notification: ")
                                .font(.customHeadline1)
                                .foregroundStyle(.parchmentDark)
                            
                            Spacer()
                            
                            Toggle("", isOn: $receiveReminder)
                                .padding(.horizontal)
                                .tint(.hearthEmberMain)
                        }
                        
                        
                        HStack {
                            Text("Reminder Time: ")
                                .font(.customHeadline1)
                                .foregroundStyle(.parchmentDark)
                            
                            Spacer()
                            
                            DatePicker(
                                "Select Date & Time",
                                selection: $reminderDate,
                                in: Date()...,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .labelsHidden()
                        }
                        
                        HStack(alignment: .center, spacing: 32) {
                            Button("Cancel") {
                                dismiss()
                            }
                            .foregroundStyle(.hearthError)
                            
                            Button("Save") {
                                let newPrayer = PrayerModel(
                                    id: UUID().uuidString,
                                    userID: prayerViewModel.prayers.first?.userID ?? "",
                                    content: prayerContent,
                                    timeStamp: reminderDate,
                                    completed: false,
                                    receiveReminder: receiveReminder
                                )
                                prayerViewModel.addPrayer(newPrayer)
                                dismiss()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(prayerContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        .padding(.top, 25)
                    }
                }
            }
            .navigationTitle("New Prayer Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarClearBackground(
                UIColor(named: "WarmSandLight"),
                titleFont: UIFont.systemFont(ofSize: 25, weight: .bold),
                titleColor: UIColor(named: "ParchmentDark")
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "x.circle.fill")
                    }
                }
            }
        }
    }
}

/*
 #Preview {
 AddPrayerSheetView()
 }
 */
