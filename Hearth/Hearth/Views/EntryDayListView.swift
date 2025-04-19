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
    @ObservedObject var gratitudeViewModel: GratitudeViewModel
    @EnvironmentObject var prayerViewModel: PrayerViewModel
    
    @State private var showAddJournalSheet: Bool = false
    @State private var showAddPrayerSheet = false
    @State private var selectedFilters: Set<EntryType> = []
    
    @Namespace private var filterChipAnimation
    
    private var availableFilters: [EntryType] {
        var filters: [EntryType] = []
        if !calendarViewModel.entries.isEmpty { filters.append(.journal) }
        if !reflectionViewModel.fetchedReflections.isEmpty { filters.append(.bibleVerseReflection) }
        if !journalReflectionViewModel.reflections.filter({ Calendar.current.isDate($0.reflectionTimestamp, inSameDayAs: selectedDate) }).isEmpty {
            filters.append(.selfReflection)
        }
        if !prayersForDay.isEmpty { filters.append(.prayerReminder) }
        if !gratitudeEntriesForDay.isEmpty { filters.append(.gratitude) }
        return filters
    }
    
    
    private var prayersForDay: [PrayerModel] {
        prayerViewModel.prayers(for: selectedDate).filter { prayer in
            let hasContent = !prayer.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            return hasContent || !prayer.completed
        }
    }
    
    private var gratitudeEntriesForDay: [GratitudeModel] {
        gratitudeViewModel.allEntries.filter {
            Calendar.current.isDate($0.timeStamp, inSameDayAs: selectedDate)
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
                        HStack(spacing: 5) {
                            ForEach(availableFilters) { filter in
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        if selectedFilters.contains(filter) {
                                            selectedFilters.remove(filter)
                                        } else {
                                            selectedFilters.insert(filter)
                                        }
                                    }
                                } label: {
                                    ZStack {
                                        if selectedFilters.contains(filter) {
                                            Capsule()
                                                .fill(Color.hearthEmberMain)
                                                .matchedGeometryEffect(id: filter, in: filterChipAnimation)
                                        } else {
                                            Capsule()
                                                .fill(Color.white)
                                                .stroke(Color.hearthEmberLight, lineWidth: 2)
                                        }
                                        
                                        Text(filter.label)
                                            .font(.customBody2)
                                            .foregroundStyle(selectedFilters.contains(filter) ? Color.parchmentLight : Color.hearthEmberLight)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                    }
                                    .scaleEffect(selectedFilters.contains(filter) ? 1.05 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedFilters.contains(filter))
                                }
                                .padding(.horizontal, 5)
                            }
                            
                        }
                        .padding(.top, 15)
                        
                        LazyVStack(spacing: 15) {
                            
                            if selectedFilters.isEmpty || selectedFilters.contains(.journal) {
                                ForEach(calendarViewModel.entries, id: \.id) { entry in
                                    JournalEntryCardView(
                                        journalEntry: entry,
                                        calendarViewModel: calendarViewModel,
                                        journalEntryViewModel: journalEntryViewModel,
                                        selectedDate: selectedDate
                                    )
                                }
                            }
                            
                            if selectedFilters.isEmpty || selectedFilters.contains(.bibleVerseReflection) {
                                ForEach(reflectionViewModel.fetchedReflections, id: \.id) { reflection in
                                    ReflectionEntryCardView(
                                        reflectionEntry: reflection,
                                        reflectionViewModel: reflectionViewModel,
                                        selectedDate: selectedDate)
                                }
                            }
                            
                            if selectedFilters.isEmpty || selectedFilters.contains(.selfReflection) {
                                ForEach(journalReflectionViewModel.reflections.filter {
                                    Calendar.current.isDate($0.reflectionTimestamp, inSameDayAs: selectedDate)
                                    && !$0.reflectionContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                }, id: \.id) { reflection in
                                    JournalReflectionCardView(reflection: reflection,
                                                              reflectionViewModel: journalReflectionViewModel)
                                }
                            }
                            
                            if selectedFilters.isEmpty || selectedFilters.contains(.prayerReminder) {
                                if !prayersForDay.isEmpty {
                                    PrayerCalendarCardView(
                                        prayerViewModel: prayerViewModel,
                                        selectedDate: selectedDate
                                    )
                                }
                            }
                            
                            if selectedFilters.isEmpty || selectedFilters.contains(.gratitude) {
                                ForEach(gratitudeEntriesForDay, id: \.id) { entry in
                                    GratitudeCalendarCardView(gratitudeViewModel: gratitudeViewModel, entry: entry)
                                }
                            }
                            
                        }
                        .padding(.vertical, 15)
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
