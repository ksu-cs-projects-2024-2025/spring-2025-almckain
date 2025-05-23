//
//  PrayerReminderView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/6/25.
//


import SwiftUI

struct PrayerReminderView: View {
    @ObservedObject var reminderViewModel: PrayerReminderViewModel
    @State private var showUtilitySheet: Bool = false
    @State private var showAddedToTodayBanner: Bool = false
    @State private var showInitialLoading = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.parchmentLight
                    .ignoresSafeArea()
                
                if showInitialLoading {
                    VStack{
                        LazyVStack(spacing: 12) {
                            SkeletonView(RoundedRectangle(cornerRadius: 10))
                                .frame(height: 30)
                                .padding(.horizontal, 50)
                            
                            PrayerReminderLoadingCard()
                            
                            PrayerReminderLoadingCard()
                            
                            PrayerReminderLoadingCard()
                        }
                        .padding(.top, 20)
                        Spacer()
                    }
                    
                } else {
                    VStack {
                        Picker("Filter", selection: $reminderViewModel.selectedFilter) {
                            ForEach(ReminderFilter.allCases) { filter in
                                Text(filter.rawValue).tag(filter)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 50)
                        .padding(.top, 20)
                        ScrollView {
                            
                            switch reminderViewModel.selectedFilter {
                            case .today:
                                renderTodayTab()
                            case .future:
                                renderFutureTab()
                            }
                            
                        }
                    }
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                showUtilitySheet = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.largeTitle)
                                    .padding()
                            }
                            .background(Circle().fill(Color.hearthEmberMain))
                            .foregroundStyle(.white)
                            .padding()
                        }
                    }
                }
            }
            .onAppear {
                if showInitialLoading {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        withAnimation {
                            showInitialLoading = false
                        }
                    }
                }
            }
            .navigationTitle("Prayer Reminders")
            .navigationBarTitleDisplayMode(.large)
            .customSheet(isPresented: $showUtilitySheet) {
                AddPrayerSheetView(prayerViewModel: reminderViewModel.prayerViewModel)
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
            PrayerReminderCardView(
                prayerViewModel: reminderViewModel.prayerViewModel,
                day: Date(),
                prayers: [],
                isFutureTab: true
            )
            .padding(.top, 12)
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
        let currentDay = Date().startOfDay
        let todayPrayers = reminderViewModel.prayersByDay[currentDay] ?? []
        
        PrayerReminderCardView(
            prayerViewModel: reminderViewModel.prayerViewModel,
            day: currentDay,
            prayers: todayPrayers,
            isFutureTab: false
        )
        .padding(.top, 12)
        
        let otherDays = reminderViewModel.daysToShow.filter { $0 != currentDay }
        
        if !otherDays.isEmpty {
            LazyVStack(spacing: 12) {
                ForEach(otherDays, id: \.self) { day in
                    let dailyPrayers = reminderViewModel.prayersByDay[day] ?? []
                    if !dailyPrayers.isEmpty {
                        PrayerReminderCardView(
                            prayerViewModel: reminderViewModel.prayerViewModel,
                            day: day,
                            prayers: dailyPrayers,
                            isFutureTab: false
                        )
                        .padding(.top, 12)
                        .transition(.move(edge: .leading))
                    }
                }
            }
            .animation(.easeInOut, value: reminderViewModel.prayersByDay)
        }
    }
    
}

/*
 #Preview {
 PrayerReminderView()
 }
 */
