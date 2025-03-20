//
//  CalendarView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/6/25.
//

import SwiftUI

struct CalendarView: View {
    
    @ObservedObject var journalEntryViewModel: JournalEntryViewModel
    @ObservedObject var calendarViewModel: CalendarViewModel
    @ObservedObject var reflectionViewModel: VerseReflectionViewModel
    
    @State private var isPresented: Bool = false
    
    
    var body: some View {
        ZStack {
            Color.parchmentLight
                .ignoresSafeArea()
            NavigationStack {
                ScrollView {
                    CalendarCardView(calendarViewModel: calendarViewModel)
                        .navigationDestination(for: Date.self) { date in
                            EntryDayListView(selectedDate: date, calendarViewModel: calendarViewModel, journalEntryViewModel: journalEntryViewModel, reflectionViewModel: reflectionViewModel)
                        }
                    
                    Button(action: {
                        isPresented.toggle()
                    }) {
                        Text("Add to Journal")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .font(.customButton)
                            .foregroundColor(.parchmentLight)
                            .background(RoundedRectangle(cornerRadius: 20).foregroundStyle(.hearthEmberMain))
                            .contentShape(Rectangle())
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
        .onAppear {
            journalEntryViewModel.onEntryUpdate = { [weak calendarViewModel] in
                calendarViewModel?.fetchEntriesInMonth(Date())
                calendarViewModel?.fetchEntries(for: Date())
            }
            reflectionViewModel.onReflectionUpdate = { [weak calendarViewModel] in
                calendarViewModel?.fetchReflectionsInMonth(Date())
            }
        }
        .customSheet(isPresented: $isPresented) {
            CreateNewJournalView(isPresenting: $isPresented, viewModel: journalEntryViewModel, calendarViewModel: calendarViewModel, selectedDate: Date())
        }
        .presentationDetents([.fraction(0.95)])

    }
}

/*
#Preview {
    CalendarView()
}
*/
