//
//  SignupView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/25/25.
//

import SwiftUI

struct SignupView: View {
    @StateObject var viewModel: OnboardingViewModel
    @FocusState private var focusedField: Field?
    @Binding var currentStep: Int
    
    enum Field {
        case firstName, lastName, email, password, confirmPassword
    }

    var body: some View {
        NavigationStack {
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
                        TextField("First name", text: $viewModel.firstName)
                            .padding()
                            .background(Color.parchmentLight)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .focused($focusedField, equals: .firstName)
                            .submitLabel(.done)
                            .autocorrectionDisabled()

                        
                        TextField("Last name", text: $viewModel.lastName)
                            .padding()
                            .background(Color.parchmentLight)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .focused($focusedField, equals: .lastName)
                            .submitLabel(.done)
                            .autocorrectionDisabled()
                        
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
                        
                        
                        SecureField("Confirm", text: $viewModel.confirmPassword)
                            .padding()
                            .background(Color.parchmentLight)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .focused($focusedField, equals: .confirmPassword)
                            .submitLabel(.done)

                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Button(action: {
                            viewModel.hasAgreedToPrivacyPolicy.toggle()
                        }) {
                            Image(systemName: viewModel.hasAgreedToPrivacyPolicy ? "checkmark.square.fill" : "square")
                                .foregroundColor(viewModel.hasAgreedToPrivacyPolicy ? .hearthEmberMain : .gray)
                                .font(.customButton)
                        }
                        
                        Text("I agree to the ")
                        
                        Button(action: {
                            if let url = URL(string: "https://hearthjournal.com") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("Privacy Policy")
                                .foregroundColor(.hearthEmberDark)
                                .underline()
                        }
                        
                        Text(" and Terms of Service.")
                        
                        Spacer()
                    }
                    .padding()
                    .font(.footnote)
                    
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Button(action: {
                        viewModel.registerUser { success in
                            if success {
                                currentStep = 1
                            }
                        }
                    }) {
                        Text("Create Account")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .font(.customButton)
                            .foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 20).fill(viewModel.isFormValid ? Color.hearthEmberMain : Color.gray))
                            .contentShape(Rectangle())
                    }
                    .padding()
                    .disabled(!viewModel.isFormValid)
                    
                    Spacer()
                }
            }
        }
    }
}

/*
#Preview {
    SignupView()
}
*/
