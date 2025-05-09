//
//  GratitudeService.swift
//  Hearth
//
//  Created by Aaron McKain on 4/17/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class GratitudeService: GratitudeServiceProtocol {
    private let db = Firestore.firestore()
    private let collection = "gratitudeEntries"
    private let userSession: UserSessionProviding
    
    init(userSession: UserSessionProviding = FirebaseUserSessionProvider()) {
        self.userSession = userSession
    }
    
    func fetchGratitudeEntries(forMonth date: Date, completion: @escaping (Result<[GratitudeModel], Error>) -> Void) {
        guard let userID = userSession.currentUserID else {
            completion(.failure(GratitudeServiceError.noLoggedInUser))
            return
        }
        
        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)),
              let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
            completion(.failure(GratitudeServiceError.invalidDateRange))
            return
        }
        
        db.collection(collection)
            .whereField("userID", isEqualTo: userID)
            .whereField("timeStamp", isGreaterThanOrEqualTo: Timestamp(date: startOfMonth))
            .whereField("timeStamp", isLessThan: Timestamp(date: startOfNextMonth))
            .order(by: "timeStamp", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(GratitudeServiceError.firestoreOperationFailed(error)))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                var entries: [GratitudeModel] = []
                for document in documents {
                    do {
                        let entry = try document.data(as: GratitudeModel.self)
                        entries.append(entry)
                    } catch {
                        completion(.failure(GratitudeServiceError.documentSerializationFailed(error)))
                        return
                    }
                }
                completion(.success(entries))
            }
    }
    
    func saveGratitudeEntry(_ entry: GratitudeModel, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = userSession.currentUserID else {
            completion(.failure(GratitudeServiceError.noLoggedInUser))
            return
        }
        
        var entryToSave = entry
        entryToSave.userID = userID
        
        do {
            try db.collection(collection).document(entry.id).setData(from: entryToSave) { error in
                if let error = error {
                    completion(.failure(GratitudeServiceError.firestoreOperationFailed(error)))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(GratitudeServiceError.documentSerializationFailed(error)))
        }
    }
    
    func updateGratitude(_ entry: GratitudeModel, completion: @escaping (Result<Void, Error>) -> Void) {
        guard userSession.currentUserID != nil else {
            completion(.failure(GratitudeServiceError.noLoggedInUser))
            return
        }
        
        do {
            try db.collection(collection)
                .document(entry.id)
                .setData(from: entry, merge: true) { error in
                    if let error = error {
                        completion(.failure(GratitudeServiceError.firestoreOperationFailed(error)))
                    } else {
                        completion(.success(()))
                    }
                }
        } catch {
            completion(.failure(GratitudeServiceError.documentSerializationFailed(error)))
        }
    }
    
    func deleteGratitude(entryID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard userSession.currentUserID != nil else {
            completion(.failure(GratitudeServiceError.noLoggedInUser))
            return
        }
        
        db.collection(collection).document(entryID).delete { error in
            if let error = error {
                completion(.failure(GratitudeServiceError.firestoreOperationFailed(error)))
            } else {
                completion(.success(()))
            }
        }
        
    }
}

enum GratitudeServiceError: LocalizedError {
    case noLoggedInUser
    case invalidDateRange
    case documentSerializationFailed(Error)
    case firestoreOperationFailed(Error)
    case entryUpdateFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .noLoggedInUser:
            return "No user is currently logged in. Please sign in to access gratitude entries."
        case .invalidDateRange:
            return "Could not calculate valid date range for entries."
        case .documentSerializationFailed(let error):
            return "Failed to process gratitude entry: \(error.localizedDescription)"
        case .firestoreOperationFailed(let error):
            return "Firestore operation failed: \(error.localizedDescription)"
        case .entryUpdateFailed(let error):
            return "Failed to update gratitude entry"
        }
    }
}
