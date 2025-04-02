//
//  FeedView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/6/25.
//


import SwiftUI

struct PrayerReminderView: View {
    /*
    @State private var isPresented: Bool = false
    @StateObject private var viewModel = JournalEntryViewModel()
    
    init() {
        let appearance = navBarAppearance()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    */
    var body: some View {
        NavigationStack {
            ZStack {
                Color.parchmentLight
                    .ignoresSafeArea()
                ScrollView {
                    LazyVStack {
                        PrayerReminderCardView()
                        PrayerReminderCardView()
                    }
                }
            }
            .navigationTitle("Prayer Reminders")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    func navBarAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "WarmSandMain")
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(named: "HearthEmberMain") ?? UIColor.red
        ]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "HearthEmberMain") ?? UIColor.red]
        return appearance
    }

}

#Preview {
    PrayerReminderView()
}

