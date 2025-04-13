//
//  MainView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/6/25.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @State private var selectedTab = 0
    
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var profileViewModel = ProfileViewModel()
    @StateObject var homeViewModel = HomeViewModel()
    @StateObject var reflectionViewModel = VerseReflectionViewModel()
    @StateObject var calendarViewModel = CalendarViewModel()
    @StateObject var journalEntryViewModel = JournalEntryViewModel()
    @StateObject var entryReflectionViewModel = ReflectionViewModel()
    
    @StateObject var prayerViewModel = PrayerViewModel()
    @StateObject var prayerReminderViewModel: PrayerReminderViewModel
    
    // Stylizes tab bar
    init() {
        let prayerVM = PrayerViewModel()
        _prayerViewModel = StateObject(wrappedValue: prayerVM)
        _prayerReminderViewModel = StateObject(wrappedValue: PrayerReminderViewModel(prayerViewModel: prayerVM))
        
        let appearance = tabBarAppearance()
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().isHidden = false
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: 0) {
                /*
                HomeView(
                    profileViewModel: profileViewModel, homeViewModel: homeViewModel, reflectionViewModel: reflectionViewModel, entryReflectionViewModel: entryReflectionViewModel, journalEntryViewModel: journalEntryViewModel,
                    prayerViewModel: prayerViewModel
                )
                 */
                HomeView(
                    profileViewModel: profileViewModel, homeViewModel: homeViewModel, reflectionViewModel: reflectionViewModel, entryReflectionViewModel: entryReflectionViewModel, journalEntryViewModel: journalEntryViewModel
                )
                .environmentObject(prayerViewModel)
            }
            Tab("Calendar", systemImage: "calendar", value: 1) {
                /*
                CalendarView(
                    journalEntryViewModel: journalEntryViewModel, calendarViewModel: calendarViewModel, reflectionViewModel: reflectionViewModel, journalReflectionViewModel: entryReflectionViewModel,
                        prayerViewModel: prayerViewModel
                )
                 */
                CalendarView(
                    journalEntryViewModel: journalEntryViewModel, calendarViewModel: calendarViewModel, reflectionViewModel: reflectionViewModel, journalReflectionViewModel: entryReflectionViewModel
                )
                .environmentObject(prayerViewModel)
            }
            Tab("Prayers", systemImage: "list.bullet.clipboard", value: 2) {
                // PrayerReminderView(reminderViewModel: prayerReminderViewModel)
                PrayerReminderView(reminderViewModel: prayerReminderViewModel)
                    .environmentObject(prayerViewModel)
            }
            Tab("Profile", systemImage: "person.fill", value: 3) {
                ProfileView()
                    .environmentObject(prayerViewModel)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                notificationViewModel.checkNotificationStatus()
            }
        }
        .onAppear {
            prayerViewModel.fetchPrayers(forMonth: Date())
        }
    }
    
    func tabBarAppearance() -> UITabBarAppearance {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "WarmSandMain")
        
        if let selectedColor = UIColor(named: "HearthEmberMain") {
            appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]
        }
        
        if let unselectedColor = UIColor(named: "ParchmentDark")?.withAlphaComponent(0.6) {
            appearance.stackedLayoutAppearance.normal.iconColor = unselectedColor
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: unselectedColor]
        }
        return appearance
    }
}
/*
 #Preview {
 MainView()
 }
 */
