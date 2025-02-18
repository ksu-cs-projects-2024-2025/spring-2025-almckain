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
        
    @Published var entries: [JournalEntryModel] = []
    @Published var isLoading: Bool = false
    
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
