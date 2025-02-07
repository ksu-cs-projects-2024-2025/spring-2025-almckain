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
    
    // Stylizes tab bar
    init() {
        let appearance = tabBarAppearance()
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: 0) {
                HomeView()
            }
            Tab("Calendar", systemImage: "calendar", value: 1) {
                CalendarView()
            }
            Tab("Feed", systemImage: "newspaper.fill", value: 2) {
                FeedView()
            }
            Tab("Profile", systemImage: "person.fill", value: 3) {
                ProfileView()
            }
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

#Preview {
    MainView()
}
