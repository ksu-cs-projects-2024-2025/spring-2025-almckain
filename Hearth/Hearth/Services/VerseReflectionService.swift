//
//  VerseReflectionService.swift
//  Hearth
//
//  Created by Aaron McKain on 2/13/25.
//

import Foundation
import FirebaseFirestore

class VerseReflectionService {
    private let db = Firestore.firestore()
    
    func saveReflection(_ reflection: VerseReflectionModel, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let _ = try db.collection("reflections").addDocument(from: reflection) { error in
                if let error = error {
                    print("Firestore Error: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    print("Reflection saved successfully")
                    completion(.success(()))
                }
            }
        } catch let error {
            print("Encoding Error: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
}

