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
}
