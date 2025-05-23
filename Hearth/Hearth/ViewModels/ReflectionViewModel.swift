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
    @Published var isLoading: Bool = true
    @Published var isSaving = false

    
    private let reflectionService: ReflectionEntryServiceProtocol
    private let journalEntryService: EntryServiceProtocol
    
    var highestSpireReflection: JournalReflectionModel? {
        reflections.max(by: { $0.spireScore < $1.spireScore })
    }
    
    init(reflectionService: ReflectionEntryServiceProtocol = ReflectionEntryService(), journalEntryService: EntryServiceProtocol = EntryService()) {
        self.reflectionService = reflectionService
        self.journalEntryService = journalEntryService
    }
    
    func saveReflection(_ reflection: JournalReflectionModel, completion: @escaping (Bool) -> Void) {
        isSaving = true
        reflectionService.saveReflection(reflection) { result in
            self.isSaving = false
            switch result {
            case .success:
                DispatchQueue.main.async {
                    if let index = self.reflections.firstIndex(where: { $0.id == reflection.id }) {
                        self.reflections[index] = reflection
                    } else {
                        self.reflections.append(reflection)
                    }
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
        if !reflections.isEmpty {
            self.isLoading = false
            return
        }

        Task {
            do {
                let entries = try await fetchLastWeekEntries()
                let reflections = await TextAnalysisService.analyzeAllEntriesConcurrently(entries)

                self.reflections = reflections

            } catch {
                print("Error fetching or analyzing entries: \(error)")
            }
            self.isLoading = false
        }
    }
    
    private func fetchLastWeekEntries() async throws -> [JournalEntryModel] {
        try await withCheckedThrowingContinuation { continuation in
            journalEntryService.fetchEntriesForLastWeek { result in
                continuation.resume(with: result)
            }
        }
    }
    
    func fetchReflection(reflectionID: String, completion: @escaping (JournalReflectionModel?) -> Void) {
        reflectionService.fetchReflection(reflectionID: reflectionID) { result in
            switch result {
            case .success(let reflection):
                if let index = self.reflections.firstIndex(where: { $0.id == reflection.id }) {
                    self.reflections[index] = reflection
                } else {
                    self.reflections.append(reflection)
                }
                DispatchQueue.main.async {
                    completion(reflection)
                }
            case .failure(let error):
                print("Error fetching reflection: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    func fetchTodayReflection(completion: @escaping (JournalReflectionModel?) -> Void) {
        reflectionService.fetchTodayReflection { result in
            switch result {
            case .success(let reflection):
                if let reflection = reflection {
                    if let index = self.reflections.firstIndex(where: { $0.id == reflection.id }) {
                        self.reflections[index] = reflection
                    } else {
                        self.reflections.append(reflection)
                    }
                }
                DispatchQueue.main.async {
                    completion(reflection)
                }
            case .failure(let error):
                print("Error fetching today reflection: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }

    func updateReflection(_ reflection: JournalReflectionModel, completion: @escaping (Bool) -> Void) {
        isSaving = true
        reflectionService.updateReflection(reflection) { result in
            DispatchQueue.main.async {
                self.isSaving = false
                switch result {
                case .success:
                    if let index = self.reflections.firstIndex(where: { $0.id == reflection.id }) {
                        self.reflections[index] = reflection
                    }
                    DispatchQueue.main.async {
                        completion(true)
                    }
                case .failure(let error):
                    print("Error updating reflection: \(error)")
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            }
        }
    }
    
    func deleteReflection(reflectionID: String, completion: @escaping (Bool) -> Void) {
        reflectionService.deleteReflection(reflectionID: reflectionID) { result in
            switch result {
            case .success:
                if let index = self.reflections.firstIndex(where: { $0.id == reflectionID }) {
                    self.reflections.remove(at: index)
                }
                DispatchQueue.main.async {
                    completion(true)
                }
            case .failure(let error):
                print("Error deleting reflection: \(error)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    func fetchReflections(for date: Date, completion: @escaping ([JournalReflectionModel]) -> Void) {
        reflectionService.fetchReflections(for: date) { result in
            switch result {
            case .success(let fetchedReflections):
                for reflection in fetchedReflections {
                    if let index = self.reflections.firstIndex(where: { $0.id == reflection.id }) {
                        self.reflections[index] = reflection
                    } else {
                        self.reflections.append(reflection)
                    }
                }
                
                let sameDayReflections = fetchedReflections.filter {
                    Calendar.current.isDate($0.reflectionTimestamp, inSameDayAs: date)
                }

                DispatchQueue.main.async {
                    completion(sameDayReflections)
                }
            case .failure(let error):
                print("Error fetching reflections: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
    
    func completedReflections(for date: Date) -> [JournalReflectionModel] {
        reflections.filter {
            Calendar.current.isDate($0.reflectionTimestamp, inSameDayAs: date) &&
            !$0.reflectionContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
}
