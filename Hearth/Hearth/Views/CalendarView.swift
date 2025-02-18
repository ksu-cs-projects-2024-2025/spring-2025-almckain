//
//  CalendarView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/6/25.
//

import SwiftUI

struct CalendarView: View {
    
    @StateObject var calendarViewModel = CalendarViewModel()
    
    var body: some View {
        ZStack {
            Color.parchmentLight
                .ignoresSafeArea()
            NavigationStack {
                ScrollView {
                    CalendarCardView()
                        .navigationDestination(for: Date.self) { date in
                            EntryDayListView(selectedDate: date)
                        }
                }
                .onAppear {
                    let appearance = calendarViewModel.navBarAppearance()
                    UINavigationBar.appearance().standardAppearance = appearance
                    UINavigationBar.appearance().scrollEdgeAppearance = appearance
                }
                .navigationTitle("Calendar")
                .navigationBarTitleDisplayMode(.large)
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    CalendarView()
}
