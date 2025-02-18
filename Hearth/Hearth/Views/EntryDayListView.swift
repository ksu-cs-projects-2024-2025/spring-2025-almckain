//
//  EntryDayView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/17/25.
//

import SwiftUI

struct EntryDayListView: View {
    let selectedDate: Date
    @StateObject private var calendarViewModel = CalendarViewModel()
    
    var body: some View {
        ZStack {
            Color.parchmentLight
                .ignoresSafeArea()
            VStack {
                if calendarViewModel.isLoading {
                    LoadingScreenView()
                } else if calendarViewModel.entries.isEmpty {
                    Text("No entries for this day")
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    ScrollView {
                        ForEach(calendarViewModel.entries, id: \.id) { entry in
                            JournalEntryCardView(journalEntry: entry)
                        }
                    }
                }
            }
        }
        .navigationTitle(selectedDate.formatted(.dateTime.month(.abbreviated).day().year()))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            calendarViewModel.fetchEntries(for: selectedDate)
            let appearance = calendarViewModel.navBarAppearance()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().tintColor = UIColor(named: "HearthEmberMain")
        }
    }
}

#Preview {
    EntryDayListView(selectedDate: Date())
}
