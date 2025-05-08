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
    @Published var errorMessage: String?
    
    private let entryService: EntryServiceProtocol
    
    var onEntryUpdate: (() -> Void)?
    
    init(entryService: EntryServiceProtocol = EntryService(userSession: FirebaseUserSessionProvider())) {
        self.entryService = entryService
    }
    
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
    
    func addJournalEntry(title: String, content: String, date: Date = Date(), completion: @escaping (Result<Void, Error>) -> Void) {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
              !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            self.errorMessage = "Cannot save an empty entry."
            let error = NSError(domain: "JournalEntryError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot save an empty entry."])
            completion(.failure(error))
            return
        }
        
        let newEntry = JournalEntryModel(
            id: UUID().uuidString,
            userID: Auth.auth().currentUser?.uid ?? "",
            title: title,
            content: content,
            timeStamp: date
        )
        
        self.isLoading = true
        entryService.saveEntry(newEntry) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success:
                    self.errorMessage = nil
                    self.journalEntries.append(newEntry)
                    completion(.success(()))
                case .failure(let error):
                    self.errorMessage = "Could not add to journal. Please try again later."
                    completion(.failure(error))
                }
            }
        }
    }
    
    func deleteEntry(withId id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !id.isEmpty else {
            self.errorMessage = "Invalid entry ID."
            let error = NSError(domain: "JournalEntryError", code: 5, userInfo: [NSLocalizedDescriptionKey: "Invalid entry ID."])
            completion(.failure(error))
            return
        }
        self.isLoading = true
        entryService.deleteEntry(entryId: id) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success:
                    if let index = self.journalEntries.firstIndex(where: { $0.id == id }) {
                        self.journalEntries.remove(at: index)
                    }
                    self.errorMessage = nil
                    completion(.success(()))
                case .failure(let error):
                    self.errorMessage = "Failed to delete entry"
                    completion(.failure(error))
                }
            }
        }
    }
    
    func updateJournalEntry(entry: JournalEntryModel, newTitle: String, newContent: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
              !newContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            self.errorMessage = "Cannot save an empty entry."
            let error = NSError(domain: "JournalEntryError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Cannot save an empty entry."])
            completion(.failure(error))
            return
        }

        
        var updatedEntry = entry
        updatedEntry.title = newTitle
        updatedEntry.content = newContent
        
        self.isLoading = true
        entryService.updateEntry(updatedEntry) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    if let index = self?.journalEntries.firstIndex(where: { $0.id == updatedEntry.id }) {
                        self?.journalEntries[index] = updatedEntry
                    }
                    self?.errorMessage = nil
                    self?.onEntryUpdate?()
                    completion(.success(()))
                case .failure(let error):
                    self?.errorMessage = "Failed to update entry. Please try again later."
                    print("Error updating entry: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchJournalEntries(forWeekStarting start: Date, ending end: Date) {
        isLoading = true
        entryService.fetchEntriesInRange(start: start, end: end) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let entries):
                    self.journalEntries = entries
                case .failure(let error):
                    print("Error fetching weekly journal entries: \(error.localizedDescription)")
                    self.errorMessage = "Failed to load this week's journal entries."
                }
            }
        }
    }
    
    func dayFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        let short = formatter.string(from: date)
        guard let firstLetter = short.first else { return "" }
        return String(firstLetter).capitalized
    }
}
