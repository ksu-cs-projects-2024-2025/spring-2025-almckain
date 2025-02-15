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
    @Published var userName: String?
    @Published var isLoading: Bool = true
    private let profileService = ProfileService()
    
    init() {
        fetchUserData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isLoading = false
        }
    }

    func fetchUserData() {
        profileService.getUserData { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let name):
                    self?.userName = name
                case .failure:
                    self?.userName = "Guest"
                }
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
}
