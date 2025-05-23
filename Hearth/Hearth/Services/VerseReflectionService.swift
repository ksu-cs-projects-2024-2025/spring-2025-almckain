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
    private let userSession: UserSessionProviding
    
    init(userSession: UserSessionProviding = FirebaseUserSessionProvider()) {
        self.userSession = userSession
    }
    
    func saveReflection(_ reflection: VerseReflectionModel, completion: @escaping (Result<String, Error>) -> Void) {
        guard let userID = userSession.currentUserID else {
            completion(.failure(VerseReflectionServiceError.userNotLoggedIn))
            return
        }
        
        var updatedReflection = reflection
        updatedReflection.userID = userID
        updatedReflection.timeStamp = Date()
        
        let docRef = db.collection("reflections").document()
        do {
            try docRef.setData(from: updatedReflection) { error in
                if let error = error {
                    print("Firestore Error: \(error.localizedDescription)")
                    completion(.failure(VerseReflectionServiceError.firestoreError(error)))
                } else {
                    print("Reflection saved successfully with ID: \(docRef.documentID)")
                    completion(.success(docRef.documentID))
                }
            }
        } catch let error {
            print("Encoding Error: \(error.localizedDescription)")
            completion(.failure(VerseReflectionServiceError.encodingError(error)))
        }
    }

    
    func updateReflection(_ reflection: VerseReflectionModel, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = userSession.currentUserID else {
            completion(.failure(VerseReflectionServiceError.userNotLoggedIn))
            return
        }
        
        guard reflection.userID == userID else {
            completion(.failure(VerseReflectionServiceError.userNotLoggedIn))
            return
        }
        
        let docRef = db.collection("reflections").document(reflection.id)
        do {
            try docRef.setData(from: reflection, merge: true) { error in
                if let error = error {
                    print("Firestore Update Error: \(error.localizedDescription)")
                    completion(.failure(VerseReflectionServiceError.firestoreError(error)))
                } else {
                    completion(.success(()))
                }
                
            }
        } catch let error {
            print("Encoding Error: \(error.localizedDescription)")
            completion(.failure(VerseReflectionServiceError.encodingError(error)))
        }
    }
    
    func deleteReflection(entryId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let _ = userSession.currentUserID else {
            completion(.failure(VerseReflectionServiceError.userNotLoggedIn))
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
        guard let userID = userSession.currentUserID else {
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
                    let reflections: [VerseReflectionModel] = snapshot?.documents.compactMap { doc in
                        guard var reflection = try? doc.data(as: VerseReflectionModel.self) else {
                            return nil
                        }
                        reflection.id = doc.documentID
                        return reflection
                    } ?? []

                    completion(.success(reflections))
                }
            }
    }
    
    func fetchReflectionsInRange(start: Date, end: Date, completion: @escaping (Result<[VerseReflectionModel], Error>) -> Void) {
        guard let userID = userSession.currentUserID else {
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

enum VerseReflectionServiceError: LocalizedError {
    case userNotLoggedIn
    case encodingError(Error)
    case firestoreError(Error)
    case dateRangeError
    
    var errorDescription: String? {
        switch self {
        case .userNotLoggedIn:
            return "User is not logged in."
        case .encodingError(let error):
            return error.localizedDescription
        case .firestoreError(let error):
            return error.localizedDescription
        case .dateRangeError:
            return "Error calculating date range."
        }
    }
}
