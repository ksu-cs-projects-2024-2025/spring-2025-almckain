//
//  JournalService.swift
//  Hearth
//
//  Created by Aaron McKain on 2/13/25.
//

import FirebaseFirestore
import FirebaseAuth
import Foundation

class EntryService {
    private let db = Firestore.firestore()
    
    func fetchEntriesInRange(start: Date, end: Date, completion: @escaping (Result<[JournalEntryModel], Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthError", code: 401,
               userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        
        db.collection("entries")
            .whereField("userID", isEqualTo: userID)
            .whereField("entryType", isEqualTo: EntryType.journal.rawValue)
            .whereField("timeStamp", isGreaterThanOrEqualTo: start)
            .whereField("timeStamp", isLessThan: end)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let entries: [JournalEntryModel] = snapshot?.documents.compactMap {
                    try? $0.data(as: JournalEntryModel.self)
                } ?? []
                
                completion(.success(entries))
            }
    }
    
    
    func saveEntry<T: EntryProtocol>(_ entry: T, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        
        var newEntry = entry
        newEntry.userID = user.uid
        
        do {
            let _ = try db.collection("entries").document(newEntry.id ?? UUID().uuidString).setData(from: newEntry, merge: true)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchEntries<T: EntryProtocol>(entryType: EntryType, completion: @escaping (Result<[T], Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        
        db.collection("entries")
            .whereField("userID", isEqualTo: userID)
            .whereField("entryType", isEqualTo: entryType.rawValue)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let entries: [T] = snapshot?.documents.compactMap{
                    try? $0.data(as: T.self)
                } ?? []
                
                completion(.success(entries))
            }
    }
    
    func fetchEntriesForDay(date: Date, completion: @escaping (Result<[JournalEntryModel], Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }

        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone.current // Ensure local time zone

        guard let localStartOfDay = calendar.date(from: components) else {
            completion(.failure(NSError(domain: "DateError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to calculate local start of day"])))
            return
        }

        guard let localEndOfDay = calendar.date(byAdding: .day, value: 1, to: localStartOfDay) else {
            completion(.failure(NSError(domain: "DateError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to calculate local end of day"])))
            return
        }

        print("🔥 Fetching entries from \(localStartOfDay) to \(localEndOfDay) (Local TZ: \(TimeZone.current.identifier))")

        db.collection("entries")
            .whereField("userID", isEqualTo: userID)
            .whereField("entryType", isEqualTo: EntryType.journal.rawValue)
            .whereField("timeStamp", isGreaterThanOrEqualTo: localStartOfDay)
            .whereField("timeStamp", isLessThan: localEndOfDay)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let entries: [JournalEntryModel] = snapshot?.documents.compactMap {
                    try? $0.data(as: JournalEntryModel.self)
                } ?? []
                
                print("✅ Fetched \(entries.count) entries for \(date) (local time)")
                completion(.success(entries))
            }
    }

}
