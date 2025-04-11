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
    @ObservedObject var journalReflectionViewModel: ReflectionViewModel
    @ObservedObject var prayerViewModel: PrayerViewModel

    @State private var showAddJournalSheet: Bool = false
    @State private var showAddPrayerSheet = false
    
    private var prayersForDay: [PrayerModel] {
        prayerViewModel.prayers(for: selectedDate).filter { prayer in
            let hasContent = !prayer.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            return hasContent || !prayer.completed
        }
    }

    
    var body: some View {
        ZStack {
            Color.parchmentLight
                .ignoresSafeArea()
            VStack {
                if calendarViewModel.isLoading {
                    LoadingScreenView()
                } else if calendarViewModel.entries.isEmpty && reflectionViewModel.fetchedReflections.isEmpty && journalReflectionViewModel.reflections.isEmpty && prayersForDay.isEmpty {
                    Text("No entries for this day")
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
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
                            
                            ForEach(journalReflectionViewModel.reflections.filter {
                                Calendar.current.isDate($0.reflectionTimestamp, inSameDayAs: selectedDate)
                                && !$0.reflectionContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            }, id: \.id) { reflection in
                                JournalReflectionCardView(reflection: reflection,
                                                          reflectionViewModel: journalReflectionViewModel)
                            }

                            
                            if !prayersForDay.isEmpty {
                                PrayerCalendarCardView(
                                    prayerViewModel: prayerViewModel,
                                    selectedDate: selectedDate
                                )
                            }
                             

                        }
                        .padding(.top, 15)
                    }
                }
            }
            .customSheet(isPresented: $showAddJournalSheet) {
                CreateNewJournalView(isPresenting: $showAddJournalSheet, viewModel: journalEntryViewModel, calendarViewModel: calendarViewModel, selectedDate: selectedDate)
            }
            .presentationDetents([.fraction(0.95)])
            .customSheet(isPresented: $showAddPrayerSheet) {
                AddPrayerSheetView(prayerViewModel: prayerViewModel)
            }

        }
        .navigationTitle(selectedDate.formatted(.dateTime.month(.abbreviated).day().year()))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    if calendarViewModel.isToday(selectedDate: selectedDate) {
                        Button("Add Journal Entry") {
                            showAddJournalSheet.toggle()
                        }
                    }
                    
                    Button("Add Prayer Reminder") {
                        showAddPrayerSheet.toggle()
                    }
                } label: {
                    Image(systemName: "plus.square")
                        .font(.customTitle3)
                        .foregroundStyle(.hearthEmberMain)
                }
            }
        }
        .onAppear {
            calendarViewModel.fetchEntries(for: selectedDate)
            reflectionViewModel.fetchReflections(for: selectedDate)
            journalReflectionViewModel.fetchReflections(for: selectedDate) { _ in
                print("Fetched journal reflection")
            }
            
            if !prayerViewModel.prayers.contains(where: { Calendar.current.isDate($0.timeStamp, inSameDayAs: selectedDate) }) {
                prayerViewModel.fetchPrayers(forMonth: selectedDate)
            }

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
