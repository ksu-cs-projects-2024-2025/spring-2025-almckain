//
//  OnboardingView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/6/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var name: String = ""
    @State private var password: String = ""
    @State private var email: String = ""
    @State private var errorMessage: String? = ""
    @AppStorage("isOnboardingComplete") private var isOnboardingComplete: Bool = false
    
    @StateObject private var viewModel = OnboardingViewModel()
    
    var body: some View {
        VStack {
            Text("Welcome, to Hearth!")
                .font(.largeTitle)
                .padding()
            

            VStack(spacing: 20) {
                Text("Create an Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                TextField("Name", text: $viewModel.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.hearthError)
                        .font(.customCaption1)
                }
                
                if viewModel.isLoading {
                    ProgressView()
                }
                
                Button("Get Started") {
                    viewModel.registerUser()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
    }
}

#Preview {
    OnboardingView()
}
