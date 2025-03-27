//
//  LoginView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/25/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        ZStack {
            Color.warmSandLight
                .ignoresSafeArea()
            VStack {
                HStack {
                    Text("Create an Account")
                        .foregroundStyle(.hearthEmberMain)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.vertical)
                    Spacer()
                }
                .padding()
                
                VStack {
                    TextField("Email", text: $viewModel.email)
                        .padding()
                        .background(Color.parchmentLight)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .focused($focusedField, equals: .email)
                        .submitLabel(.done)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    
                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .background(Color.parchmentLight)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .focused($focusedField, equals: .password)
                        .submitLabel(.done)
                        .autocorrectionDisabled()
                }
                .padding(.horizontal)
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: {
                    viewModel.loginUser()
                }) {
                    Text("Log in")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .font(.customButton)
                        .foregroundColor(.white)
                        .background(RoundedRectangle(cornerRadius: 20).fill((!viewModel.email.isEmpty && !viewModel.password.isEmpty) ? Color.hearthEmberMain : Color.gray))
                        .contentShape(Rectangle()) // Expands tappable area to the entire button
                }
                .padding()
                .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty)

                
                Spacer()
            }
        }
    }
}

#Preview {
    LoginView()
}
