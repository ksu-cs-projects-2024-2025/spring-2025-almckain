//
//  PrayerCardView.swift
//  Hearth
//
//  Created by Aaron McKain on 3/31/25.
//

import SwiftUI

struct PrayerCardView: View {
    @State private var isAddingNewPrayer = false
    @ObservedObject var prayerViewModel: PrayerViewModel
    
    private var filteredPrayers: [PrayerModel] {
        let now = Date()
        
        // 1. Get all of today's prayers (completed + non-completed)
        let todayPrayers = prayerViewModel.prayers.filter {
            Calendar.current.isDateInToday($0.timeStamp)
        }
        
        // 2. Get future prayers (after today) that are NOT completed
        let futurePrayers = prayerViewModel.prayers.filter {
            $0.timeStamp > now && !$0.completed
        }.sorted { $0.timeStamp < $1.timeStamp }
        
        // 3. Calculate how many future prayers to add (max 5 total)
        let maxVisible = 5
        let remainingSlots = max(maxVisible - todayPrayers.count, 0)
        let extraPrayers = Array(futurePrayers.prefix(remainingSlots))
        
        // 4. Combine today's prayers with future ones (up to 5 total)
        return todayPrayers + extraPrayers
    }
    
    
    private var groupedPrayers: [(date: Date, prayers: [PrayerModel])] {
        let sortedPrayers = filteredPrayers.sorted { $0.timeStamp < $1.timeStamp }
        let groups = Dictionary(grouping: sortedPrayers) { $0.timeStamp.startOfDay }
        let sortedDates = groups.keys.sorted()
        return sortedDates.map { (date: $0, prayers: groups[$0]!) }
    }
    
    var body: some View {
        CardView {
            VStack {
                HStack {
                    Text("Upcoming Reminders")
                        .font(.customTitle3)
                        .foregroundStyle(.hearthEmberMain)
                    Spacer()
                    
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
                }
                CustomDivider(height: 2, color: .hearthEmberDark)
                
                // Using the PrayerView, list todays prayers and the next 5 upcoming prayers. Could be 5 prayers today. Or it could be 1 today, one tomorrow, .... Either way the most displayed will be 5.
                
                if groupedPrayers.isEmpty {
                    Text("No prayers available")
                        .font(.customBody1)
                        .foregroundStyle(.secondary)
                } else {
                    // For each group, display a header and then the prayers for that day
                    ForEach(groupedPrayers, id: \.date) { group in
                        LazyVStack(alignment: .leading, spacing: 4) {
                            Text(formattedDate(for: group.date))
                                .font(.headline)
                                .foregroundColor(.hearthEmberMain)
                            ForEach(group.prayers) { prayer in
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
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .onAppear {
            prayerViewModel.fetchAllNeededPrayers()
            
            // Recalculate on day change
            let midnight = Calendar.current.nextDate(after: Date(), matching: DateComponents(hour: 0), matchingPolicy: .nextTime)!
            let interval = midnight.timeIntervalSinceNow
            
            DispatchQueue.main.asyncAfter(deadline: .now() + interval + 1) {
                prayerViewModel.fetchAllNeededPrayers()
            }
        }
    }
    
    // Helper to format the group header based on the date
    private func formattedDate(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
}

/*
 #Preview {
 PrayerCardView()
 }
 */
