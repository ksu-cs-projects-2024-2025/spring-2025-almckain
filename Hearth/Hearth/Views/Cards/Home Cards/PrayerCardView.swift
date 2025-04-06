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
    
    private var todayPrayers: [PrayerModel] {
        prayerViewModel.prayers.filter { Calendar.current.isDateInToday($0.timeStamp) }
    }
    
    private var filteredPrayers: [PrayerModel] {
        let now = Date()
        let todayPrayers = prayerViewModel.prayers.filter {
            Calendar.current.isDateInToday($0.timeStamp)
        }
        let futurePrayers = prayerViewModel.prayers.filter {
            $0.timeStamp > now && !$0.completed
        }.sorted { $0.timeStamp < $1.timeStamp }
        
        let maxVisible = 5
        let remainingSlots = max(maxVisible - todayPrayers.count, 0)
        let extraPrayers = Array(futurePrayers.prefix(remainingSlots))
        
        return todayPrayers + extraPrayers
    }
    
    private var groupedPrayers: [(date: Date, prayers: [PrayerModel])] {
        let sortedPrayers = filteredPrayers.sorted { $0.timeStamp < $1.timeStamp }
        let groups = Dictionary(grouping: sortedPrayers) { $0.timeStamp.startOfDay }
        let sortedDates = groups.keys.sorted()
        return sortedDates.map { (date: $0, prayers: groups[$0]!) }
    }
    
    private var futureGroups: [(date: Date, prayers: [PrayerModel])] {
        groupedPrayers.filter { !Calendar.current.isDateInToday($0.date) }
    }
    
    var body: some View {
        CardView {
            VStack {
                HStack {
                    Text("Prayer Reminders")
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
                
                VStack(spacing: 4) {
                    HStack {
                        Text("Today")
                            .font(.headline)
                            .foregroundColor(.hearthEmberMain)
                        
                        Spacer()
                    }
                    
                    if todayPrayers.isEmpty && !isAddingNewPrayer {
                        VStack(spacing: 8) {
                            Text("You have no prayer reminders for today yet.")
                                .font(.customBody1)
                                .foregroundStyle(.secondary)
                            Button("Add First Prayer") {
                                withAnimation {
                                    isAddingNewPrayer = true
                                }
                            }
                            .font(.headline)
                        }
                        .padding(.vertical, 12)
                    } else {
                        LazyVStack {
                            if isAddingNewPrayer {
                                let newPrayer = PrayerModel.empty
                                PrayerView(
                                    prayer: newPrayer,
                                    isFuturePrayer: false,
                                    initialEditing: true
                                ) { finalPrayer in
                                    prayerViewModel.addPrayer(finalPrayer)
                                    isAddingNewPrayer = false
                                } onCancel: {
                                    isAddingNewPrayer = false
                                }
                                .id(newPrayer.id)
                            }
                            
                            ForEach(todayPrayers) { prayer in
                                PrayerView(
                                    prayer: prayer,
                                    isFuturePrayer: prayer.timeStamp > Date(),
                                    displayInHome: true
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
                    }
                }
                .padding(.vertical, 4)
                
                if !futureGroups.isEmpty {
                    ForEach(futureGroups, id: \.date) { group in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(formattedDate(for: group.date))
                                .font(.headline)
                                .foregroundColor(.hearthEmberMain)
                            ForEach(group.prayers) { prayer in
                                PrayerView(
                                    prayer: prayer,
                                    isFuturePrayer: prayer.timeStamp > Date(),
                                    displayInHome: true
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
                
                if todayPrayers.isEmpty && futureGroups.isEmpty && !isAddingNewPrayer {
                    Text("No prayers available")
                        .font(.customBody1)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 12)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .onAppear {
            prayerViewModel.fetchAllNeededPrayers()
            
            let midnight = Calendar.current.nextDate(
                after: Date(),
                matching: DateComponents(hour: 0),
                matchingPolicy: .nextTime
            )!
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
