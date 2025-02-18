//
//  OnboardingView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/6/25.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var isLoginMode = false

    var body: some View {
        VStack {
            Text("Welcome to Hearth!")
                .font(.largeTitle)
                .padding()

            VStack(spacing: 20) {
                Text(isLoginMode ? "Login" : "Create an Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                if !isLoginMode {
                    TextField("Name", text: $viewModel.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }

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
                        .foregroundColor(.red)
                        .font(.caption)
                }

                if viewModel.isLoading {
                    ProgressView()
                }

                Button(isLoginMode ? "Login" : "Get Started") {
                    if isLoginMode {
                        viewModel.loginUser()
                    } else {
                        viewModel.registerUser()
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()

                Button(isLoginMode ? "Need an account? Sign up" : "Already have an account? Log in") {
                    isLoginMode.toggle()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
