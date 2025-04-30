//
//  ProfileService.swift
//  Hearth
//
//  Created by Aaron McKain on 2/13/25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class ProfileService {
    private let db = Firestore.firestore()
    
    func getUserData(completion: @escaping (Result<UserModel, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "ProfileService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                completion(.failure(NSError(domain: "ProfileService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User data not found"])))
                return
            }
            
            do {
                let user = try document.data(as: UserModel.self)
                completion(.success(user))
            } catch {
                completion(.failure(error))
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
    
    private func fetchCount(forCollection collection: String, completion: @escaping (Int?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }
        
        let query = db.collection(collection)
            .whereField("userID", isEqualTo: userID)
        
        query.count.getAggregation(source: .server) { snapchat, error in
            if let error = error {
                print("Error fetching count for \(collection): \(error.localizedDescription)")
                completion(nil)
            } else if let snapchat = snapchat {
                completion(Int(truncating: snapchat.count))
            } else {
                completion(nil)
            }
        }
    }
    
    func fetchPrayerCount(completion: @escaping (Int?) -> Void) {
        fetchCount(forCollection: "prayers", completion: completion)
    }
    
    func fetchJournalEntryCount(completion: @escaping (Int?) -> Void) {
        fetchCount(forCollection: "entries", completion: completion)
    }
    
    func fetchReflectionCount(completion: @escaping (Int?) -> Void) {
        fetchCount(forCollection: "reflections", completion: completion)
    }
    
    func fetchEntryReflectionCount(completion: @escaping (Int?) -> Void) {
        fetchCount(forCollection: "entryReflections", completion: completion)
    }
    
    func fetchAllCounts(completion: @escaping ([String: Int]) -> Void) {
        var counts: [String: Int] = [:]
        let group = DispatchGroup()
        
        group.enter()
        fetchPrayerCount { count in
            counts["prayerCount"] = count ?? 0
            group.leave()
        }
        
        group.enter()
        fetchJournalEntryCount { count in
            counts["journalEntryCount"] = count ?? 0
            group.leave()
        }
        
        group.enter()
        fetchReflectionCount { count in
            counts["reflectionCount"] = count ?? 0
            group.leave()
        }
        
        group.enter()
        fetchEntryReflectionCount { count in
            counts["entryReflectionCount"] = count ?? 0
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(counts)
        }
    }
    
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "ProfileService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not signed in"])))
            return
        }
        
        let uid = user.uid
        let collections = ["users", "entries", "reflections", "prayers", "entryReflections"]
        var errors: [Error] = []
        let dispatchGroup = DispatchGroup()
        
        var batch = db.batch()
        var opCount = 0
        
        for collection in collections {
            dispatchGroup.enter()
            let colRef = db.collection(collection)
            let query: Query
            if collection == "users" {
                query = colRef.whereField(FieldPath.documentID(), isEqualTo: uid)
            } else {
                query = colRef.whereField("userID", isEqualTo: uid)
            }
            
            query.getDocuments { snap, err in
                defer { dispatchGroup.leave() }
                if let err = err {
                    errors.append(err)
                    return
                }
                guard let docs = snap?.documents else { return }
                for doc in docs {
                    batch.deleteDocument(doc.reference)
                    opCount += 1
                    if opCount == 450 {
                        batch.commit { commitErr in
                            if let commitErr = commitErr {
                                errors.append(commitErr)
                            }
                        }
                        batch = self.db.batch()
                        opCount = 0
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            batch.commit { commitErr in
                if let commitErr = commitErr {
                    errors.append(commitErr)
                }
                
                if let first = errors.first {
                    completion(.failure(first)); return
                }
                
                user.delete { authErr in
                    if let authErr = authErr {
                        completion(.failure(authErr))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }
}

