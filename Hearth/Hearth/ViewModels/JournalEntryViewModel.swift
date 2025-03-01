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
    
    func addJournalEntry(title: String, content: String, date: Date = Date()) {
        let newEntry = JournalEntryModel(
            id: UUID().uuidString,
            userID: Auth.auth().currentUser?.uid ?? "",
            title: title,
            content: content,
            timeStamp: date
        )
        
        entryService.saveEntry(newEntry) { result in
            DispatchQueue.main.async {
                if case .success = result {
                    self.journalEntries.append(newEntry)
                }
            }
        }
    }
    
    func deleteEntry(withId id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        entryService.deleteEntry(entryId: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if let index = self.journalEntries.firstIndex(where: { $0.id == id }) {
                        self.journalEntries.remove(at: index)
                    }
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    // Other functions eventually
}
