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
            try db.collection("reflections")
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
}
