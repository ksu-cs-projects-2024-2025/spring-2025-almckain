//
//  JournalEntryViewModel.swift
//  Hearth
//
//  Created by Aaron McKain on 2/13/25.
//

import SwiftUI
import FirebaseAuth
import Foundation

class JournalEntryViewModel: ObservableObject {
    @Published var journalEntries: [JournalEntryModel] = []
    @Published var isLoading = false
    private let entryService = EntryService()
    
    func fetchJournalEntries() {
        isLoading = true
        entryService.fetchEntries(entryType: .journal) { (result: Result<[JournalEntryModel], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let entries):
                    self.journalEntries = entries
                case .failure(let error):
                    print("Error fetching journal entries: \(error.localizedDescription)")
                }
                self.isLoading = false
            }
        }
    }
    
    func addJournalEntry(title: String, content: String) {
        let newEntry = JournalEntryModel(
            id: UUID().uuidString,
            userID: Auth.auth().currentUser?.uid ?? "",
            title: title,
            content: content,
            timeStamp: Date()
        )
        
        entryService.saveEntry(newEntry) { result in
            DispatchQueue.main.async {
                if case .success = result {
                    self.journalEntries.append(newEntry)
                }
            }
        }
    }
    
    // Other functions eventually
}
