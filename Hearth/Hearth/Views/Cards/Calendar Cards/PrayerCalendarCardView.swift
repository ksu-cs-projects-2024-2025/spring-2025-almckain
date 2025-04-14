//
//  PrayerCalendarCardView.swift
//  Hearth
//
//  Created by Aaron McKain on 4/8/25.
//

import SwiftUI

struct PrayerCalendarCardView: View {
    @ObservedObject var prayerViewModel: PrayerViewModel
    let selectedDate: Date
    
    private var prayersForSelectedDate: [PrayerModel] {
        prayerViewModel.prayers(for: selectedDate)
    }
    
    var body: some View {
        
        CustomCalendarCardView {
            VStack(alignment: .leading, spacing: 8) {
                CardHeaderView(
                    title: "Prayer Reminders",
                    secondary: prayerViewModel.secondaryText(for: selectedDate, prayers: prayersForSelectedDate)
                )
                
                CustomDivider(height: 2, color: .hearthEmberDark)
                
                ForEach(
                    prayersForSelectedDate
                        .sorted {
                            if !$0.completed && $1.completed {
                                return true
                            } else if $0.completed && !$1.completed {
                                return false
                            } else {
                                return $0.timeStamp < $1.timeStamp
                            }
                        }
                ) { prayer in
                    PrayerView(
                        prayer: prayer,
                        isFuturePrayer: prayer.timeStamp > Date()
                    ) { updatedPrayer in
                        withAnimation {
                            prayerViewModel.updatePrayer(updatedPrayer)
                        }
                    } onDelete: {
                        withAnimation {
                            prayerViewModel.deletePrayer(withId: prayer.id)
                        }
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .onChange(of: prayerViewModel.lastUpdated) { _, _ in
                prayerViewModel.refresh()
            }
            .onAppear {
                prayerViewModel.onPrayerUpdate = { [weak prayerViewModel] in
                    prayerViewModel?.refresh()
                }
            }
        }
    }
}
