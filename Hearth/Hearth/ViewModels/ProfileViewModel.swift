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
    @Published var errorMessage: String?
    
    private let profileService: ProfileServiceProtocol
    private let userSession: UserSessionProviding
    
    init(
        profileService: ProfileServiceProtocol = ProfileService(),
        userSession: UserSessionProviding = FirebaseUserSessionProvider()
    ) {
        self.profileService = profileService
        self.userSession = userSession
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
                    self?.user = nil
                    self?.errorMessage = "Failed to load user data"
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
        guard let user = userSession.currentUser,
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
    
    func formattedDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: user?.joinedAt ?? Date())
    }
    
    func clearAllUserDefaults() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
            print("DEBUG: Cleared all user defaults")
        }
    }
}
