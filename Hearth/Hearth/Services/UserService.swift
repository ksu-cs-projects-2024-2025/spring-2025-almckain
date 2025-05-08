//
//  UserService.swift
//  Hearth
//
//  Created by Aaron McKain on 2/13/25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class UserService: AuthenticationServiceProtocol {
    private let db = Firestore.firestore()

    func registerUser(firstName: String, lastName: String, email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = authResult?.user else {
                completion(.failure(UserServiceError.userNotFoundAfterRegistration))
                return
            }
            
            let newUser = UserModel(id: user.uid, firstName: firstName, lastName: lastName, email: email, isOnboardingComplete: false, joinedAt: Date())
            self.createUserDocument(newUser, completion: completion)
        }
    }
    
    func loginUser(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let _ = error {
                completion(.failure(UserServiceError.invalidUserID))
            } else {
                completion(.success(()))
            }
        }
    }
    
    private func createUserDocument(_ user: UserModel, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection("users").document(user.id ?? UUID().uuidString).setData(from: user) { error in
                if let error = error {
                    completion(.failure(UserServiceError.documentSerialization(error)))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(UserServiceError.documentSerialization(error)))
        }
    }
    
    func completeUserOnboarding(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(UserServiceError.noLoggedInUser))
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).updateData([
            "isOnboardingComplete": true
        ]) { error in
            if let error = error {
                completion(.failure(UserServiceError.documentSerialization(error)))
            } else {
                completion(.success(()))
            }
        }
    }
}

enum UserServiceError: LocalizedError {
    case userNotFoundAfterRegistration
    case noLoggedInUser
    case invalidUserID
    case documentSerialization(Error)

    var errorDescription: String? {
        switch self {
        case .userNotFoundAfterRegistration:
            return "User was created, but could not be retrieved."
        case .noLoggedInUser:
            return "No user is currently logged in."
        case .invalidUserID:
            return "Invalid user ID. Cannot save user data without a valid identifier."
        case .documentSerialization(let error):
            return "Failed to serialize user data: \(error.localizedDescription)"
        }
    }
}

