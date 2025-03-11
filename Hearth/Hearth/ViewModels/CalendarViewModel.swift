//
//  CalendarViewModel.swift
//  Hearth
//
//  Created by Aaron McKain on 2/17/25.
//

import Foundation
import SwiftUI

class CalendarViewModel: ObservableObject {
    private let entryService = EntryService()
    private let reflectionService = VerseReflectionService()
    private let calendar = Calendar.current
    
    @Published var monthEntries: [Date: [JournalEntryModel]] = [:]
    @Published var monthReflections: [Date: [VerseReflectionModel]] = [:]
    @Published var entries: [JournalEntryModel] = []
    @Published var isLoading: Bool = false
    
    func isToday(selectedDate: Date) ->  Bool {
        return Calendar.current.isDateInToday(selectedDate)
    }
    
    func fetchEntriesInMonth(_ monthDate: Date) {
        isLoading = true
        
        let startOfMonth = calendar.startOfDay(for: monthDate.startOfMonth)
        // End of month is inclusive, so fetch up to the *start* of the next day
        let endOfMonth = calendar.date(byAdding: .day, value: 1, to: monthDate.endOfMonth)!
        
        entryService.fetchEntriesInRange(start: startOfMonth, end: endOfMonth) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let fetchedEntries):
                    // Group entries by their own startOfDay
                    var grouped: [Date: [JournalEntryModel]] = [:]
                    for entry in fetchedEntries {
                        let dayStart = self?.calendar.startOfDay(for: entry.timeStamp) ?? Date()
                        grouped[dayStart, default: []].append(entry)
                    }
                    self?.monthEntries = grouped
                case .failure(let error):
                    print("Error fetching month entries: \(error.localizedDescription)")
                    self?.monthEntries = [:]
                }
            }
        }
    }
    
    func fetchReflectionsInMonth(_ monthDate: Date) {
        isLoading = true
        let startOfMonth = calendar.startOfDay(for: monthDate.startOfMonth)
        let endOfMonth = calendar.date(byAdding: .day, value: 1, to: monthDate.endOfMonth)!
        
        reflectionService.fetchReflectionsInRange(start: startOfMonth, end: endOfMonth) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let fetchedReflections):
                    var grouped: [Date: [VerseReflectionModel]] = [:]
                    for reflection in fetchedReflections {
                        let dayStart = self?.calendar.startOfDay(for: reflection.timeStamp) ?? Date()
                        grouped[dayStart, default: []].append(reflection)
                    }
                    self?.monthReflections = grouped
                case .failure(let error):
                    print("Error fetching month reflections: \(error.localizedDescription)")
                    self?.monthReflections = [:]
                }
            }
        }
    }
           
    func fetchEntries(for date: Date) {
        isLoading = true
        entryService.fetchEntriesForDay(date: date) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let fetchedEntries):
                    self?.entries = fetchedEntries
                case .failure(let error):
                    print("Error fetching entries: \(error.localizedDescription)")
                    self?.entries = []
                }
            }
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
