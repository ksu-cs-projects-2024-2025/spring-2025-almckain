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
}

#Preview {
    MainView()
}
