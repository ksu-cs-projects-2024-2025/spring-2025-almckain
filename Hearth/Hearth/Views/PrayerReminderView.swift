//
//  FeedView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/6/25.
//


import SwiftUI

struct PrayerReminderView: View {
    @StateObject private var reminderViewModel: PrayerReminderViewModel
    
    init(prayerViewModel: PrayerViewModel) {
        _reminderViewModel = StateObject(wrappedValue: PrayerReminderViewModel(prayerViewModel: prayerViewModel))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.parchmentLight
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack {
                        // Picker is now inside the ScrollView
                        Picker("Filter", selection: $reminderViewModel.selectedFilter) {
                            ForEach(ReminderFilter.allCases) { filter in
                                Text(filter.rawValue).tag(filter)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 50)
                        .padding(.top, 20)
                        
                        switch reminderViewModel.selectedFilter {
                        case .today:
                            renderTodayTab()
                        case .future:
                            renderFutureTab()
                        }
                    }
                }
            }
            .navigationTitle("Prayer Reminders")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                reminderViewModel.onAppear()
            }
        }
    }
    
    func navBarAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "WarmSandMain")
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(named: "HearthEmberMain") ?? UIColor.red
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(named: "HearthEmberMain") ?? UIColor.red
        ]
        return appearance
    }
    
    @ViewBuilder
    private func renderFutureTab() -> some View {
        let sortedDays = reminderViewModel.sortedFutureDays
        
        if sortedDays.isEmpty {
            // Show single "blank" future card
            PrayerReminderCardView(
                prayerViewModel: reminderViewModel.prayerViewModel,
                day: Date(),
                prayers: [],
                isFutureTab: true
            )
        } else {
            LazyVStack(spacing: 12) {
                ForEach(sortedDays, id: \.self) { day in
                    let dailyPrayers = reminderViewModel.futurePrayersByDay[day] ?? []
                    
                    PrayerReminderCardView(
                        prayerViewModel: reminderViewModel.prayerViewModel,
                        day: day,
                        prayers: dailyPrayers,
                        isFutureTab: true
                    )
                }
            }
            .padding(.top, 12)
            .animation(.easeInOut, value: reminderViewModel.prayersByDay)
        }
    }
    
    @ViewBuilder
    private func renderTodayTab() -> some View {
        if reminderViewModel.hasPrayersInLast7Days {
            LazyVStack(spacing: 12) {
                ForEach(reminderViewModel.daysToShow, id: \.self) { day in
                    let dailyPrayers = reminderViewModel.prayersByDay[day] ?? []
                    if !dailyPrayers.isEmpty {
                        PrayerReminderCardView(
                            // Pass the underlying PrayerViewModel here
                            prayerViewModel: reminderViewModel.prayerViewModel,
                            day: day,
                            prayers: dailyPrayers,
                            isFutureTab: false
                        )
                        .transition(.move(edge: .leading))
                    }
                }
            }
            .padding(.top, 12)
            .animation(.easeInOut, value: reminderViewModel.prayersByDay)
        } else {
            // No prayers in the last 7 days → show empty card
            PrayerReminderCardView(
                prayerViewModel: reminderViewModel.prayerViewModel,
                day: Date().startOfDay,
                prayers: [],
                isFutureTab: false
            )
            .padding(.top, 12)
        }
    }
}

/*
 #Preview {
 PrayerReminderView()
 }
 */
