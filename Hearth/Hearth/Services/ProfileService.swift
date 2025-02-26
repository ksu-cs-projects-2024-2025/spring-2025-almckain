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
            
            guard let document = document, document.exists, let data = document.data() else {
                completion(.failure(NSError(domain: "ProfileService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User data not found"])))
                return
            }
            
            do {
                let userData = try JSONSerialization.data(withJSONObject: data, options: [])
                let user = try JSONDecoder().decode(UserModel.self, from: userData)
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
}

