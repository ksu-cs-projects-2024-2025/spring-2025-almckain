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
    private let profileService = ProfileService()
    
    init() {
        fetchUserData()
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
}
