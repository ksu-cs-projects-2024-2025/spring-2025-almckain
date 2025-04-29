//
//  ProfileViewModel.swift
//  Hearth
//
//  Created by Aaron McKain on 2/13/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class ProfileViewModel: ObservableObject {
    @Published var user: UserModel?
    @Published var isLoading: Bool = true
    @Published var stats: [String: Int] = [:]
    
    private let profileService = ProfileService()
    
    init() {
        fetchUserData()
        fetchProfileStats()
    }
    
    func fetchProfileStats() {
        profileService.fetchAllCounts { [weak self] counts in
            DispatchQueue.main.async {
                self?.stats = counts
            }
        }
    }
    
    func fetchUserData() {
        profileService.getUserData { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self?.user = user
                case .failure:
                    self?.user = UserModel(id: "", firstName: "", lastName: "", email: "")
                }
                self?.isLoading = false
            }
        }
    }
    
    func logout(completion: @escaping () -> Void) {
        profileService.logout { success in
            if success {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    func navBarAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "WarmSandMain")
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(named: "HearthEmberMain") ?? UIColor.red
        ]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "HearthEmberMain") ?? UIColor.red]
        return appearance
    }
    
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        profileService.deleteAccount { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.user = nil
                    self?.stats = [:]
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func reauthenticateAndDelete(password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            let err = NSError(domain: "Auth", code: 0,
                              userInfo: [NSLocalizedDescriptionKey: "No signed-in user"])
            return completion(.failure(err))
        }
        
        let credential = EmailAuthProvider.credential(
            withEmail: email,
            password: password
        )
        
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                return completion(.failure(error))
            }
            self.deleteAccount(completion: completion)
        }
    }
}
