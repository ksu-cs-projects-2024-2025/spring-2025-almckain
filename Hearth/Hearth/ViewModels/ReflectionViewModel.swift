//
//  ReflectionViewModel.swift
//  Hearth
//
//  Created by Aaron McKain on 3/22/25.
//

import Combine
import SwiftUI

@MainActor
class ReflectionViewModel: ObservableObject {
    @Published var reflections: [JournalReflectionModel] = []
    
    private let reflectionService = ReflectionEntryService()
    private let journalEntryService = EntryService()
    
    func saveReflection(_ reflection: JournalReflectionModel, completion: @escaping (Bool) -> Void) {
        reflectionService.saveReflection(reflection) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    completion(true)
                }
            case .failure(let error):
                print("Error saving reflection: \(error)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    func fetchAndAnalyzeEntries() {
        if !reflections.isEmpty { return }

        Task {
            do {
                let entries = try await fetchLastWeekEntries()
                let reflections = await TextAnalysisService.analyzeAllEntriesConcurrently(entries)

                self.reflections = reflections

            } catch {
                print("Error fetching or analyzing entries: \(error)")
            }
        }
    }
    
    private func fetchLastWeekEntries() async throws -> [JournalEntryModel] {
        try await withCheckedThrowingContinuation { continuation in
            journalEntryService.fetchEntriesForLastWeek { result in
                continuation.resume(with: result)
            }
        }
    }

}
