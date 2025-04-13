//
//  PrayerReminderCardView.swift
//  Hearth
//
//  Created by Aaron McKain on 4/1/25.
//

import SwiftUI

struct PrayerReminderCardView: View {
    
    @ObservedObject var prayerViewModel: PrayerViewModel
    
    let day: Date
    let prayers: [PrayerModel]
    let isFutureTab: Bool
    @State private var isAddingNewPrayer = false
    
    // MARK: - Computed Properties
    
    private var leftText: String {
        let incomplete = prayers.filter { !$0.completed }.count
        if incomplete == 0 {
            return "All Done!"
        }
        else if isFutureTab{
            return ("\(prayers.count) Scheduled")
        } else {
            return "\(incomplete) \(incomplete == 1 ? "Prayer" : "Prayers") Left"
        }
    }
    
    private var dayLabel: String {
        if Calendar.current.isDateInToday(day) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(day) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, MMM d"
            return formatter.string(from: day)
        }
    }
    
    init(
        prayerViewModel: PrayerViewModel,
        day: Date,
        prayers: [PrayerModel],
        isFutureTab: Bool
    ) {
        self.prayerViewModel = prayerViewModel
        self.day = day
        self.prayers = prayers
        self.isFutureTab = isFutureTab
    }

    
    // MARK: - Body
    var body: some View {
        CardView {
            VStack(spacing: 12) {
                if !prayers.isEmpty {
                    HStack {
                        Text(dayLabel)
                            .font(.customTitle3)
                            .foregroundStyle(.hearthEmberMain)
                        
                        if !prayers.isEmpty {
                            Text("•  \(leftText)")
                                .font(.customBody1)
                                .foregroundStyle(.parchmentDark.opacity(0.6))
                                .padding(.leading, 10)
                        }
                        
                        Spacer()
                        
                        if isFutureTab || Calendar.current.isDateInToday(day) {
                            Button(action: {
                                withAnimation {
                                    if !isAddingNewPrayer {
                                        isAddingNewPrayer = true
                                    }
                                }
                            }) {
                                Image(systemName: "plus.circle")
                                    .font(.title2)
                                    .foregroundStyle(.hearthEmberMain)
                            }
                            .disabled(isAddingNewPrayer)
                        }
                    }
                    
                    CustomDivider(height: 2, color: .hearthEmberMain)
                }
                
                
                if prayers.isEmpty && !isAddingNewPrayer {
                    if Calendar.current.isDateInToday(day) {
                        VStack(spacing: 8) {
                            Text(isFutureTab
                                 ? "You have no reminders scheduled yet."
                                 : "You have no prayer reminders for this day yet.")
                            .font(.customBody1)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            
                            Button(isFutureTab ? "Schedule Prayer Reminder" : "Add First Prayer") {
                                withAnimation {
                                    isAddingNewPrayer = true
                                }
                            }
                            .font(.headline)
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .padding(.vertical, 12)
                    }
                } else if isAddingNewPrayer {
                    let newPrayer = PrayerModel.empty
                    
                    PrayerView(
                        prayer: newPrayer,
                        isFuturePrayer: true,
                        initialEditing: true,
                        displayInHome: false,
                        onSave: { finalPrayer in
                            prayerViewModel.addPrayer(finalPrayer)
                            isAddingNewPrayer = false
                        },
                        onDelete: nil,
                        onCancel: {
                            isAddingNewPrayer = false
                        }
                    )
                    .id(newPrayer.id)
                    
                }
                
                LazyVStack(spacing: 12) {
                    ForEach(prayers.sorted { !$0.completed && $1.completed }) { prayer in
                        PrayerView(
                            prayer: prayer,
                            isFuturePrayer: isFutureTab
                        ) { updated in
                            prayerViewModel.updatePrayer(updated)
                        } onDelete: {
                            prayerViewModel.deletePrayer(withId: prayer.id)
                        }
                    }
                    .animation(.easeInOut, value: prayerViewModel.prayers)
                }
            }
            .animation(.easeInOut, value: isAddingNewPrayer)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    
    
    
    private var prayersLeft: Int {
        prayers.filter { !$0.completed }.count
    }
}



/*
 #Preview {
 PrayerReminderCardView()
 }
 */
