//
//  VerseReflectionService.swift
//  Hearth
//
//  Created by Aaron McKain on 2/13/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class VerseReflectionService {
    private let db = Firestore.firestore()
    
    // VerseReflectionService.swift
    func saveReflection(_ reflection: VerseReflectionModel, completion: @escaping (Result<String, Error>) -> Void) {
        let docRef = db.collection("reflections").document()
        do {
            try docRef.setData(from: reflection) { error in
                if let error = error {
                    print("Firestore Error: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    print("Reflection saved successfully with ID: \(docRef.documentID)")
                    completion(.success(docRef.documentID))
                }
            }
        } catch let error {
            print("Encoding Error: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }

    
    func updateReflection(_ reflection: VerseReflectionModel, completion: @escaping (Result<Void, Error>) -> Void) {
        guard Auth.auth().currentUser != nil else {
            completion(.failure(NSError(
                domain: "AuthError",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "User not logged in"]
            )))
            return
        }
        
        let id = reflection.id
        
        do {
            // Use setData(from:merge:) with a completion closure
            try db.collection("reflections").document(id).setData(from: reflection, merge: true) { error in
                if let error = error {
                    // Asynchronous Firestore error
                    print("Firestore Update Error: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    print("Reflection updated successfully")
                    completion(.success(()))
                }
            }
        } catch let error {
            // Immediate encoding error
            print("Encoding Error: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    func deleteReflection(entryId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard Auth.auth().currentUser != nil else {
            completion(.failure(NSError(
                domain: "AuthError",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "User not logged in"]
            )))
            return
        }
        
        db.collection("reflections").document(entryId).delete { error in
            if let error = error {
                print("Firestore Delete Error: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("Reflection deleted successfully")
                completion(.success(()))
            }
        }
    }
    
    func fetchReflectionsForDay(date: Date, completion: @escaping (Result<[VerseReflectionModel], Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthError", code: 401,
               userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone.current

        guard let localStartOfDay = calendar.date(from: components),
              let localEndOfDay = calendar.date(byAdding: .day, value: 1, to: localStartOfDay) else {
            completion(.failure(NSError(domain: "DateError", code: 400,
               userInfo: [NSLocalizedDescriptionKey: "Error calculating day range."])))
            return
        }
        
        db.collection("reflections")
            .whereField("userID", isEqualTo: userID)
            .whereField("timeStamp", isGreaterThanOrEqualTo: localStartOfDay)
            .whereField("timeStamp", isLessThan: localEndOfDay)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    let reflections: [VerseReflectionModel] = snapshot?.documents.compactMap {
                        try? $0.data(as: VerseReflectionModel.self)
                    } ?? []
                    completion(.success(reflections))
                }
            }
    }
    
    func fetchReflectionsInRange(start: Date, end: Date, completion: @escaping (Result<[VerseReflectionModel], Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthError", code: 401,
                userInfo: [NSLocalizedDescriptionKey: "User not logged in."])))
            return
        }
        
        db.collection("reflections")
            .whereField("userID", isEqualTo: userID)
            .whereField("timeStamp", isGreaterThanOrEqualTo: start)
            .whereField("timeStamp", isLessThan: end)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    let reflections: [VerseReflectionModel] = snapshot?.documents.compactMap {
                        try? $0.data(as: VerseReflectionModel.self)
                    } ?? []
                    completion(.success(reflections))
                }
            }
    }


}

