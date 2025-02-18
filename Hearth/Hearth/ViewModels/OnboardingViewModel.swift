//
//  OnboardingViewModel.swift
//  Hearth
//
//  Created by Aaron McKain on 2/13/25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @AppStorage("isOnboardingComplete") private var isOnboardingComplete: Bool = false

    private let userService = UserService()
    
    func registerUser() {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        isLoading = true

        userService.registerUser(name: name, email: email, password: password) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success:
                    self.isOnboardingComplete = true
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func loginUser() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter your email and password"
            return
        }
        
        isLoading = true

        userService.loginUser(email: email, password: password) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success:
                    self.isOnboardingComplete = true
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
