//
//  JournalService.swift
//  Hearth
//
//  Created by Aaron McKain on 2/13/25.
//

import FirebaseFirestore
import FirebaseAuth
import Foundation

class EntryService: EntryServiceProtocol {
    private let db = Firestore.firestore()
    private let userSession: UserSessionProviding
    
    init(userSession: UserSessionProviding = FirebaseUserSessionProvider()) {
        self.userSession = userSession
    }
    
    func fetchEntriesInRange(start: Date, end: Date, completion: @escaping (Result<[JournalEntryModel], Error>) -> Void) {
        guard let userID = userSession.currentUserID else {
            completion(.failure(EntryServiceError.noLoggedInUser))
            return
        }

        db.collection("entries")
            .whereField("userID", isEqualTo: userID)
            .whereField("entryType", isEqualTo: EntryType.journal.rawValue)
            .whereField("timeStamp", isGreaterThanOrEqualTo: start)
            .whereField("timeStamp", isLessThan: end)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(EntryServiceError.firestoreOperationFailed(error)))
                    return
                }

                do {
                    let entries: [JournalEntryModel] = try snapshot?.documents.map {
                        try $0.data(as: JournalEntryModel.self)
                    } ?? []
                    completion(.success(entries))
                } catch {
                    completion(.failure(EntryServiceError.documentSerializationFailed(error)))
                }
            }
    }
    
    func saveEntry<T: EntryProtocol>(_ entry: T, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = userSession.currentUserID else {
            completion(.failure(EntryServiceError.noLoggedInUser))
            return
        }
        
        var newEntry = entry
        newEntry.userID = userID
        
        do {
            let _ = try db.collection("entries").document(newEntry.id).setData(from: newEntry, merge: true)
            completion(.success(()))
        } catch {
            completion(.failure(EntryServiceError.documentSerializationFailed(error)))
        }
    }
    
    func fetchEntries<T: EntryProtocol>(entryType: EntryType, completion: @escaping (Result<[T], Error>) -> Void) {
        guard let userID = userSession.currentUserID else {
            completion(.failure(EntryServiceError.noLoggedInUser))
            return
        }

        db.collection("entries")
            .whereField("userID", isEqualTo: userID)
            .whereField("entryType", isEqualTo: entryType.rawValue)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(EntryServiceError.firestoreOperationFailed(error)))
                    return
                }

                do {
                    let entries: [T] = try snapshot?.documents.map {
                        try $0.data(as: T.self)
                    } ?? []
                    completion(.success(entries))
                } catch {
                    completion(.failure(EntryServiceError.documentSerializationFailed(error)))
                }
            }
    }
    
    func fetchEntriesForDay(date: Date, completion: @escaping (Result<[JournalEntryModel], Error>) -> Void) {
        guard let userID = userSession.currentUserID else {
            completion(.failure(EntryServiceError.noLoggedInUser))
            return
        }

        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone.current

        guard let localStartOfDay = calendar.date(from: components) else {
            completion(.failure(EntryServiceError.dateCalculationFailed(reason: "Failed to calculate local start of day")))
            return
        }

        guard let localEndOfDay = calendar.date(byAdding: .day, value: 1, to: localStartOfDay) else {
                completion(.failure(EntryServiceError.dateCalculationFailed(reason: "Failed to calculate local end of day")))
            return
        }

        print("Fetching entries from \(localStartOfDay) to \(localEndOfDay) (Local TZ: \(TimeZone.current.identifier))")

        db.collection("entries")
            .whereField("userID", isEqualTo: userID)
            .whereField("entryType", isEqualTo: EntryType.journal.rawValue)
            .whereField("timeStamp", isGreaterThanOrEqualTo: localStartOfDay)
            .whereField("timeStamp", isLessThan: localEndOfDay)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(EntryServiceError.firestoreOperationFailed(error)))
                    return
                }
                
                let entries: [JournalEntryModel] = snapshot?.documents.compactMap {
                    try? $0.data(as: JournalEntryModel.self)
                } ?? []
                
                print("Fetched \(entries.count) entries for \(date) (local time)")
                completion(.success(entries))
            }
    }
    
    func deleteEntry(entryId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard userSession.currentUserID != nil else {
            completion(.failure(EntryServiceError.noLoggedInUser))
            return
        }
        
        db.collection("entries").document(entryId).delete { error in
            if let error = error {
                completion(.failure(EntryServiceError.firestoreOperationFailed(error)))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updateEntry(_ entry: JournalEntryModel, completion: @escaping (Result<Void, Error>) -> Void) {
        guard userSession.currentUserID != nil else {
            completion(.failure(EntryServiceError.noLoggedInUser))
            return
        }
        
        let entryID = entry.id
        
        let data: [String: Any] = [
            "title": entry.title,
            "content": entry.content,
            "timestamp": Timestamp(date: entry.timeStamp)
        ]
        
        Firestore.firestore().collection("entries").document(entryID).updateData(data) { error in
            if let error = error {
                completion(.failure(EntryServiceError.firestoreOperationFailed(error)))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func fetchEntriesForLastWeek(completion: @escaping (Result<[JournalEntryModel], Error>) -> Void) {
        guard let userID = userSession.currentUserID else {
            completion(.failure(EntryServiceError.noLoggedInUser))
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        let weekday = calendar.component(.weekday, from: now)
        let daysSinceSunday = (weekday + 6) % 7
        
        guard let thisSundayMidnight = calendar.date(
            byAdding: .day,
            value: -daysSinceSunday,
            to: calendar.startOfDay(for: now)
        ) else {
            completion(.failure(EntryServiceError.dateCalculationFailed(reason: "Could not compute thisSundayMidnight")))
            return
        }
        
        guard let previousSundayMidnight = calendar.date(byAdding: .day, value: -7, to: thisSundayMidnight) else {
            completion(.failure(EntryServiceError.dateCalculationFailed(reason: "Could not compute previousSundayMidnight")))
            return
        }
        
        db.collection("entries")
            .whereField("userID", isEqualTo: userID)
            .whereField("entryType", isEqualTo: EntryType.journal.rawValue)
            .whereField("timeStamp", isGreaterThanOrEqualTo: previousSundayMidnight)
            .whereField("timeStamp", isLessThan: thisSundayMidnight)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(EntryServiceError.firestoreOperationFailed(error)))
                    return
                }
                
                let entries: [JournalEntryModel] = snapshot?.documents.compactMap {
                    try? $0.data(as: JournalEntryModel.self)
                } ?? []
                
                completion(.success(entries))
            }
    }

}

enum EntryServiceError: LocalizedError {
    case noLoggedInUser
    case dateCalculationFailed(reason: String)
    case firestoreOperationFailed(Error)
    case documentSerializationFailed(Error)

    var errorDescription: String? {
        switch self {
        case .noLoggedInUser:
            return "No user is currently logged in. Please sign in to access journal entries."
        case .dateCalculationFailed(let reason):
            return "Failed to calculate date range: \(reason)"
        case .firestoreOperationFailed(let error):
            return "Firestore operation failed: \(error.localizedDescription)"
        case .documentSerializationFailed(let error):
            return "Failed to parse entry: \(error.localizedDescription)"
        }
    }
}
