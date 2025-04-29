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
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var hasAgreedToPrivacyPolicy: Bool = false
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @AppStorage("isOnboardingComplete") private var isOnboardingComplete: Bool = false
    
    private let userService = UserService()
    
    func registerUser(completion: @escaping (Bool) -> Void) {
        firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        email = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        confirmPassword = confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Please fill in all fields"
            completion(false)
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            completion(false)
            return
        }
        
        guard hasAgreedToPrivacyPolicy else {
            errorMessage = "You must agree to the privacy policy"
            completion(false)
            return
        }
        
        isLoading = true
        
        userService.registerUser(firstName: firstName, lastName: lastName, email: email, password: password) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success:
                    //self.isOnboardingComplete = true
                    completion(true)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion(false)
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
    
    var isFormValid: Bool {
        return !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        hasAgreedToPrivacyPolicy
    }
    
    func completeOnboarding() {
        isLoading = true
        userService.completeUserOnboarding { result in
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
