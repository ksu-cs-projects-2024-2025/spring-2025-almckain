//
//  ReflectionEntryService.swift
//  Hearth
//
//  Created by Aaron McKain on 3/22/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class ReflectionEntryService: ReflectionEntryServiceProtocol {
    private let db = Firestore.firestore()
    private let userSession: UserSessionProviding
    
    init(userSession: UserSessionProviding = FirebaseUserSessionProvider()) {
        self.userSession = userSession
    }
    
    func saveReflection(_ reflection: JournalReflectionModel, completion: @escaping (Result<Void, Error>) -> Void) {
        guard userSession.currentUser != nil else {
            completion(.failure(ReflectionEntryError.noLoggedInUser))
            return
        }
        
        do {
            try db.collection("entryReflections")
                .document(reflection.id)
                .setData(from: reflection, merge: true) { error in
                    if let error = error {
                        completion(.failure(ReflectionEntryError.firestoreOperationFailed(error)))
                    } else {
                        completion(.success(()))
                    }
                }
        } catch {
            completion(.failure(ReflectionEntryError.documentSerializationFailed(error)))
        }
    }
    
    func deleteReflection(reflectionID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard userSession.currentUser != nil else {
            completion(.failure(ReflectionEntryError.noLoggedInUser))
            return
        }
        
        db.collection("entryReflections").document(reflectionID).delete { error in
            if let error = error {
                completion(.failure(ReflectionEntryError.firestoreOperationFailed(error)))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updateReflection(_ reflection: JournalReflectionModel, completion: @escaping (Result<Void, Error>) -> Void) {
        guard userSession.currentUser != nil else {
            completion(.failure(ReflectionEntryError.noLoggedInUser))
            return
        }
        
        do {
            try db.collection("entryReflections")
                .document(reflection.id)
                .setData(from: reflection, merge: true) { error in
                    if let error = error {
                        completion(.failure(ReflectionEntryError.firestoreOperationFailed(error)))
                    } else {
                        completion(.success(()))
                    }
                }
        } catch {
            completion(.failure(ReflectionEntryError.documentSerializationFailed(error)))
        }
    }
    
    func fetchReflection(reflectionID: String, completion: @escaping (Result<JournalReflectionModel, Error>) -> Void) {
        guard userSession.currentUser != nil else {
            completion(.failure(ReflectionEntryError.noLoggedInUser))
            return
        }
        
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
        guard let currentUser = userSession.currentUser else {
            completion(.failure(ReflectionEntryError.noLoggedInUser))
            return
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            completion(.failure(ReflectionEntryError.dateCalculationFailed))
            return
        }

        db.collection("entryReflections")
            .whereField("userID", isEqualTo: currentUser.uid)
            .whereField("reflectionTimestamp", isGreaterThanOrEqualTo: startOfDay)
            .whereField("reflectionTimestamp", isLessThan: endOfDay)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(ReflectionEntryError.firestoreOperationFailed(error)))
                } else if let documents = snapshot?.documents {
                    if let document = documents.first {
                        do {
                            let reflection = try document.data(as: JournalReflectionModel.self)
                            completion(.success(reflection))
                        } catch {
                            completion(.failure(ReflectionEntryError.documentSerializationFailed(error)))
                        }
                    } else {
                        completion(.success(nil))
                    }
                } else {
                    completion(.success(nil))
                }
            }
    }
    
    func fetchReflections(for date: Date, completion: @escaping (Result<[JournalReflectionModel], Error>) -> Void) {
        guard let currentUser = userSession.currentUser else {
            completion(.failure(ReflectionEntryError.noLoggedInUser))
            return
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            completion(.failure(ReflectionEntryError.dateCalculationFailed))
            return
        }

        db.collection("entryReflections")
            .whereField("userID", isEqualTo: currentUser.uid)
            .whereField("reflectionTimestamp", isGreaterThanOrEqualTo: startOfDay)
            .whereField("reflectionTimestamp", isLessThan: endOfDay)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(ReflectionEntryError.firestoreOperationFailed(error)))
                } else if let documents = snapshot?.documents {
                    var reflections = [JournalReflectionModel]()
                    for doc in documents {
                        do {
                            let reflection = try doc.data(as: JournalReflectionModel.self)
                            reflections.append(reflection)
                        } catch {
                            completion(.failure(ReflectionEntryError.documentSerializationFailed(error)))
                            return
                        }
                    }
                    completion(.success(reflections))
                } else {
                    completion(.success([]))
                }
            }
    }
}

enum ReflectionEntryError: LocalizedError {
    case noLoggedInUser
    case dateCalculationFailed
    case documentSerializationFailed(Error)
    case firestoreOperationFailed(Error)
    case reflectionNotFound

    var errorDescription: String? {
        switch self {
        case .noLoggedInUser:
            return "No user is currently logged in. Please sign in to access reflections."
        case .dateCalculationFailed:
            return "Failed to calculate a valid date range."
        case .documentSerializationFailed(let error):
            return "Failed to process reflection entry: \(error.localizedDescription)"
        case .firestoreOperationFailed(let error):
            return "Firestore operation failed: \(error.localizedDescription)"
        case .reflectionNotFound:
            return "The requested reflection entry could not be found."
        }
    }
}

