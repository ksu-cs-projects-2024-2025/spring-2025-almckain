//
//  ReflectionEntryService.swift
//  Hearth
//
//  Created by Aaron McKain on 3/22/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class ReflectionEntryService {
    private let db = Firestore.firestore()
    
    func saveReflection(_ reflection: JournalReflectionModel, completion: @escaping (Result<Void, Error>) -> Void) {
        // Ensure that the user is logged in
        guard Auth.auth().currentUser != nil else {
            completion(.failure(NSError(domain: "AuthError",
                                        code: 401,
                                        userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        do {
            // Using the Codable support to encode reflection into Firestore format.
            try db.collection("entryReflections")
                .document(reflection.id)
                .setData(from: reflection, merge: true) { error in
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
    
    func deleteReflection(reflectionID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("entryReflections").document(reflectionID).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updateReflection(_ reflection: JournalReflectionModel, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection("entryReflections")
                .document(reflection.id)
                .setData(from: reflection, merge: true) { error in
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
    
    func fetchReflection(reflectionID: String, completion: @escaping (Result<JournalReflectionModel, Error>) -> Void) {
        let docRef = db.collection("entryReflections").document(reflectionID)
        docRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else if let document = document, document.exists {
                do {
                    let reflection = try document.data(as: JournalReflectionModel.self)
                    completion(.success(reflection))
                } catch {
                    completion(.failure(error))
                }
            } else {
                let error = NSError(domain: "FirestoreError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Reflection not found"])
                completion(.failure(error))
            }
        }
    }
    
    func fetchTodayReflection(completion: @escaping (Result<JournalReflectionModel?, Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            print("No current user found. User not logged in.")
            completion(.failure(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            completion(.failure(NSError(domain: "DateError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Date calculation error"])))
            return
        }

        db.collection("entryReflections")
            .whereField("userID", isEqualTo: currentUser.uid)
            .whereField("reflectionTimestamp", isGreaterThanOrEqualTo: startOfDay)
            .whereField("reflectionTimestamp", isLessThan: endOfDay)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching documents: \(error.localizedDescription)")
                    completion(.failure(error))
                } else if let documents = snapshot?.documents {
                    
                    if let document = documents.first {
                        do {
                            let reflection = try document.data(as: JournalReflectionModel.self)
                            print("Successfully decoded reflection.")
                            completion(.success(reflection))
                        } catch {
                            print("Failed to decode reflection: \(error.localizedDescription)")
                            completion(.failure(error))
                        }
                    } else {
                        print("No documents found for today.")
                        completion(.success(nil))
                    }
                } else {
                    print("Snapshot and documents were both nil.")
                    completion(.success(nil))
                }
            }
    }


}
