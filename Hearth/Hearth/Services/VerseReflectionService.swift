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
            _ = try db.collection("verseReflections").addDocument(from: reflection) { error in
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

