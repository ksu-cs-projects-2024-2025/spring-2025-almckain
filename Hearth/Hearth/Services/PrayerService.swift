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
        
        db.collection(collection)
            .whereField("userID", isEqualTo: userID)
            .whereField("timeStamp", isGreaterThan: Date())
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
                
                let prayers = documents.compactMap { doc in
                    try? doc.data(as: PrayerModel.self)
                }
                
                completion(.success(prayers))
            }
    }
    
    func fetchAllPrayers(inMonth date: Date, forUser userID: String, completion: @escaping (Result<[PrayerModel], Error>) -> Void) {
        guard !userID.isEmpty else {
            completion(.failure(NSError(domain: "PrayerService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid user ID."])))
            return
        }
        
        let calendar = Calendar.current
        // Get the start of the month
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let startOfMonth = calendar.date(from: components) else {
            completion(.failure(NSError(domain: "PrayerService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Could not determine start of month."])))
            return
        }
        // Calculate the end of the month (last moment of the month)
        var monthComponent = DateComponents()
        monthComponent.month = 1
        monthComponent.second = -1
        let endOfMonth = calendar.date(byAdding: monthComponent, to: startOfMonth)!
        
        db.collection(collection)
            .whereField("userID", isEqualTo: userID)
            .whereField("timeStamp", isGreaterThanOrEqualTo: startOfMonth)
            .whereField("timeStamp", isLessThanOrEqualTo: endOfMonth)
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
    
    func fetchPrayers(for date: Date, forUser userID: String, completion: @escaping (Result<[PrayerModel], Error>) -> Void) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: startOfDay) else {
            completion(.failure(NSError(domain: "PrayerService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to calculate end of day."])))
            return
        }

        db.collection(collection)
            .whereField("userID", isEqualTo: userID)
            .whereField("timeStamp", isGreaterThanOrEqualTo: startOfDay)
            .whereField("timeStamp", isLessThanOrEqualTo: endOfDay)
            .order(by: "timeStamp", descending: false)
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

}

