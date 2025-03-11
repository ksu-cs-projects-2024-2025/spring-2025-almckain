//
//  EntryDayView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/17/25.
//

import SwiftUI

struct EntryDayListView: View {
    let selectedDate: Date
    @ObservedObject var calendarViewModel: CalendarViewModel
    @StateObject var journalEntryViewModel: JournalEntryViewModel
    @ObservedObject var reflectionViewModel: VerseReflectionViewModel

    @State private var isPresented: Bool = false
    
    var body: some View {
        ZStack {
            Color.parchmentLight
                .ignoresSafeArea()
            VStack {
                if calendarViewModel.isLoading {
                    LoadingScreenView()
                } else if calendarViewModel.entries.isEmpty && reflectionViewModel.fetchedReflections.isEmpty {
                    Text("No entries for this day")
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    ScrollView {
                        ForEach(calendarViewModel.entries, id: \.id) { entry in
                            JournalEntryCardView(
                                journalEntry: entry,
                                calendarViewModel: calendarViewModel,
                                journalEntryViewModel: journalEntryViewModel,
                                selectedDate: selectedDate
                            )
                        }
                        
                        ForEach(reflectionViewModel.fetchedReflections, id: \.id) { reflection in
                            ReflectionEntryCardView(
                                reflectionEntry: reflection,
                                reflectionViewModel: reflectionViewModel,
                                selectedDate: selectedDate)
                        }
                    }
                }
            }
            .sheet(isPresented: $isPresented) {
                ZStack {
                    Color.warmSandLight
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "x.circle.fill")
                                .padding(.top)
                                .padding(.trailing, 20)
                                .foregroundStyle(.parchmentDark.opacity(0.6))
                                .font(.customTitle2)
                                .onTapGesture {
                                    isPresented.toggle()
                                }
                        }
                        
                        CreateNewJournalView(isPresenting: $isPresented, viewModel: journalEntryViewModel, calendarViewModel: calendarViewModel, selectedDate: selectedDate)
                    }
                }
                .presentationDetents([.fraction(0.95)])
            }
        }
        .navigationTitle(selectedDate.formatted(.dateTime.month(.abbreviated).day().year()))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if calendarViewModel.isToday(selectedDate: selectedDate) {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isPresented.toggle()
                    }) {
                        Image(systemName: "plus.square")
                            .font(.customTitle3)
                            .foregroundStyle(.hearthEmberMain)
                    }
                }
            }
        }
        .onAppear {
            calendarViewModel.fetchEntries(for: selectedDate)
            reflectionViewModel.fetchReflections(for: selectedDate)
            let appearance = calendarViewModel.navBarAppearance()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().tintColor = UIColor(named: "HearthEmberMain")
        }
    }
}
/*
#Preview {
    EntryDayListView(selectedDate: Date(), calendarViewModel: CalendarViewModel(), journalEntryViewModel: JournalEntryViewModel())
}
*/
