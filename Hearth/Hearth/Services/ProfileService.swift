//
//  ProfileService.swift
//  Hearth
//
//  Created by Aaron McKain on 2/13/25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class ProfileService: ProfileServiceProtocol {
    private let db = Firestore.firestore()
    private let userSession: UserSessionProviding
    private let batchLimit = 450
    
    init(userSession: UserSessionProviding = FirebaseUserSessionProvider()) {
        self.userSession = userSession
    }
    
    func getUserData(completion: @escaping (Result<UserModel, Error>) -> Void) {
        guard let userId = userSession.currentUserID else {
            completion(.failure(ProfileServiceError.userNotLoggedIn))
            return
        }
        
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                completion(.failure(ProfileServiceError.userDataNotFound))
                return
            }
            
            do {
                let user = try document.data(as: UserModel.self)
                completion(.success(user))
            } catch {
                completion(.failure(ProfileServiceError.firestore(error)))
            }
        }
    }
    
    
    func logout(completion: @escaping (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(true)
        } catch {
            completion(false)
        }
    }
    
    // MARK: - Aggregation queries for stats
    
    private func fetchCount(forCollection collection: String, completion: @escaping (Result<Int, Error>) -> Void) {
        guard let userID = userSession.currentUserID else {
            completion(.failure(ProfileServiceError.userNotLoggedIn))
            return
        }
        
        db.collection(collection)
            .whereField("userID", isEqualTo: userID)
            .count
            .getAggregation(source: .server) { snapshot, error in
                if let error = error {
                    completion(.failure(ProfileServiceError.firestore(error)))
                } else if let snapshot = snapshot {
                    completion(.success(Int(truncating: snapshot.count)))
                } else {
                    completion(.failure(ProfileServiceError.userDataNotFound))
                }
            }
    }
    
    func fetchPrayerCount(completion: @escaping (Int?) -> Void) {
        fetchCount(forCollection: "prayers") { result in
            completion(try? result.get())
        }
    }
    
    func fetchJournalEntryCount(completion: @escaping (Int?) -> Void) {
        fetchCount(forCollection: "entries") { result in
            completion(try? result.get())
        }
    }
    
    func fetchReflectionCount(completion: @escaping (Int?) -> Void) {
        fetchCount(forCollection: "reflections") { result in
            completion(try? result.get())
        }
    }
    
    func fetchEntryReflectionCount(completion: @escaping (Int?) -> Void) {
        fetchCount(forCollection: "entryReflections") { result in
            completion(try? result.get())
        }
    }
    
    func fetchGratitudeCount(completion: @escaping (Int?) -> Void) {
        fetchCount(forCollection: "gratitudeEntries") { result in
            completion(try? result.get())
        }
    }
    
    func fetchAllCounts(completion: @escaping ([String: Int]) -> Void) {
        var counts: [String: Int] = [:]
        let group = DispatchGroup()
        
        let countTasks: [(String, (Int?) -> Void)] = [
            ("prayers", { counts["prayerCount"] = $0 ?? 0 }),
            ("entries", { counts["journalEntryCount"] = $0 ?? 0 }),
            ("reflections", { counts["reflectionCount"] = $0 ?? 0 }),
            ("entryReflections", { counts["entryReflectionCount"] = $0 ?? 0 }),
            ("gratitudeEntries", { counts["gratitudeCount"] = $0 ?? 0 })
        ]
        
        for (collection, handler) in countTasks {
            group.enter()
            fetchCount(forCollection: collection) { result in
                handler(try? result.get())
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(counts)
        }
    }
    
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = userSession.currentUser else {
            completion(.failure(ProfileServiceError.userNotLoggedIn))
            return
        }
        
        let uid = user.uid
        let collections = ["users", "entries", "reflections", "prayers", "entryReflections"]
        var errors: [Error] = []
        let group = DispatchGroup()
        
        var batch = db.batch()
        var opCount = 0
        
        for collection in collections {
            group.enter()
            let query: Query = (collection == "users")
            ? db.collection(collection).whereField(FieldPath.documentID(), isEqualTo: uid)
            : db.collection(collection).whereField("userID", isEqualTo: uid)
            
            query.getDocuments { snapshot, error in
                defer { group.leave() }
                if let error = error {
                    errors.append(error)
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                for doc in documents {
                    batch.deleteDocument(doc.reference)
                    opCount += 1
                    
                    if opCount == self.batchLimit {
                        let currentBatch = batch
                        self.commit(currentBatch, errors: errors) { newBatch, newErrors in
                            batch = newBatch
                            errors = newErrors
                        }
                        opCount = 0
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            self.commit(batch, errors: errors) { _, finalErrors in
                if !finalErrors.isEmpty {
                    completion(.failure(ProfileServiceError.batchCommit(finalErrors)))
                    return
                }
                
                user.delete { error in
                    if let error = error {
                        completion(.failure(ProfileServiceError.firestore(error)))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }
    
    private func commit(_ batch: WriteBatch, errors: [Error], completion: @escaping (WriteBatch, [Error]) -> Void) {
        batch.commit { [weak self] error in
            var updatedErrors = errors
            if let error = error {
                updatedErrors.append(error)
            }
            let newBatch = self?.db.batch() ?? batch
            completion(newBatch, updatedErrors)
        }
    }
}

enum ProfileServiceError: LocalizedError {
    case userNotLoggedIn
    case userDataNotFound
    case firestore(Error)
    case batchCommit([Error])
    
    var errorDescription: String? {
        switch self {
        case .userNotLoggedIn:
            return "User is not logged in."
        case .userDataNotFound:
            return "User data could not be found."
        case .firestore(let err):
            return err.localizedDescription
        case .batchCommit(let errors):
            return "Batch commit failed: \(errors.map(\.localizedDescription).joined(separator: ", "))"
        }
    }
}

