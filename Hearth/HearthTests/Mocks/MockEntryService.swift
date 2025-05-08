//
//  MockEntryService.swift
//  Hearth
//
//  Created by Aaron McKain on 5/7/25.
//

import Foundation
@testable import Hearth

class MockEntryService: EntryServiceProtocol {
    var savedEntries: [JournalEntryModel] = []
    var shouldFail: Bool = false
    
    func fetchEntries<T>(entryType: EntryType, completion: @escaping (Result<[T], Error>) -> Void) where T : EntryProtocol {
        if shouldFail {
            completion(.failure(MockError.generic))
        } else {
            completion(.success([]))
        }
    }
    
    func saveEntry<T>(_ entry: T, completion: @escaping (Result<Void, Error>) -> Void) where T : EntryProtocol {
        if shouldFail {
            completion(.failure(MockError.generic))
        } else if let journalEntry = entry as? JournalEntryModel {
            savedEntries.append(journalEntry)
            completion(.success(()))
        } else {
            completion(.failure(MockError.invalidType))
        }
    }
    
    func deleteEntry(entryId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        completion(shouldFail ? .failure(MockError.generic) : .success(()))
    }
    
    func updateEntry(_ entry: JournalEntryModel, completion: @escaping (Result<Void, Error>) -> Void) {
        completion(shouldFail ? .failure(MockError.generic) : .success(()))
    }
    
    func fetchEntriesInRange(start: Date, end: Date, completion: @escaping (Result<[JournalEntryModel], Error>) -> Void) {
        completion(shouldFail ? .failure(MockError.generic) : .success([]))
    }
    
    func fetchEntriesForDay(date: Date, completion: @escaping (Result<[JournalEntryModel], Error>) -> Void) {
        completion(shouldFail ? .failure(MockError.generic) : .success([]))
    }
    
    func fetchEntriesForLastWeek(completion: @escaping (Result<[JournalEntryModel], Error>) -> Void) {
        completion(shouldFail ? .failure(MockError.generic) : .success([]))
    }
    
    enum MockError: Error {
        case generic
        case invalidType
    }
}
