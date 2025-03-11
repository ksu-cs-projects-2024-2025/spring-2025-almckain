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
        
        guard let id = reflection.id else {
            let idError = NSError(domain: "Firestore", code: 0, userInfo: [NSLocalizedDescriptionKey: "Reflection ID is nil"])
            completion(.failure(idError))
            return
        }
        
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
}

