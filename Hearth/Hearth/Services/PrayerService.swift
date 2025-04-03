//
//  PrayerService.swift
//  Hearth
//
//  Created by Aaron McKain on 4/1/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class PrayerService {
    private let db = Firestore.firestore()
    private let collection = "prayers"
    
    func addPrayer(_ prayer: PrayerModel, completion: @escaping (Result<Void, Error>) -> Void) {
        guard Auth.auth().currentUser != nil else {
            completion(.failure(NSError(domain: "PrayerService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated."])))
            return
        }
        
        do {
            try db.collection(collection)
                .document(prayer.id)
                .setData(from: prayer, merge: true) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
        } catch {
            completion(.failure(error))
        }
    }
    
    func updatePrayer(_ prayer: PrayerModel, completion: @escaping (Result<Void, Error>) -> Void) {
        guard Auth.auth().currentUser != nil else {
            completion(.failure(NSError(domain: "PrayerService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated."])))
            return
        }

        let docRef = db.collection(collection).document(prayer.id)
        
        do {
            try docRef.setData(from: prayer, merge: true) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
        
    func deletePrayer(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard Auth.auth().currentUser != nil else {
            completion(.failure(NSError(domain: "PrayerService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated."])))
            return
        }

        db.collection(collection)
            .document(id)
            .delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }

    func fetchPrayers(in range: DateInterval, forUser userID: String, completion: @escaping (Result<[PrayerModel], Error>) -> Void) {
        guard !userID.isEmpty else {
            completion(.failure(NSError(domain: "PrayerService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid user ID."])))
            return
        }
        print("DEBUG: Fetching from \(range.start) to \(range.end) in local time.")

        db.collection(collection)
            .whereField("userID", isEqualTo: userID)
            .whereField("timeStamp", isGreaterThanOrEqualTo: range.start)
            .whereField("timeStamp", isLessThanOrEqualTo: range.end)
            .order(by: "timeStamp", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }

                let prayers = documents.compactMap { doc in
                    try? doc.data(as: PrayerModel.self)
                }

                completion(.success(prayers))
            }
    }
    
    func fetchFuturePrayers(limit: Int, forUser userID: String, completion: @escaping (Result<[PrayerModel], Error>) -> Void) {
            guard !userID.isEmpty else {
                completion(.failure(NSError(domain: "PrayerService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid user ID."])
                ))
                return
            }
            
            // Grab all prayers whose timeStamp is greater than 'now'
            // and limit to the first `limit` entries, sorted ascending by timeStamp
            db.collection(collection)
                .whereField("userID", isEqualTo: userID)
                .whereField("timeStamp", isGreaterThan: Date())   // only future
                .order(by: "timeStamp", descending: false)
                .limit(to: limit)
                .getDocuments { snapshot, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        completion(.success([]))
                        return
                    }
                    
                    // Map each Firestore doc to a PrayerModel
                    let prayers = documents.compactMap { doc in
                        try? doc.data(as: PrayerModel.self)
                    }
                    
                    completion(.success(prayers))
                }
        }
}
