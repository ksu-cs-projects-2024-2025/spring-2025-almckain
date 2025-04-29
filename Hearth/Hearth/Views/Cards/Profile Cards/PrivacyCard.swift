//
//  PrivacyCard.swift
//  Hearth
//
//  Created by Aaron McKain on 4/16/25.
//

import SwiftUI

struct PrivacyCard: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @Binding var isOnboardingComplete: Bool
    
    @State private var showingDeleteAlert = false
    @State private var showingReauthSheet = false
    @State private var password = ""
    @State private var reauthError: String?
    
    var body: some View {
        CardView {
            VStack(spacing: 16) {
                // Header
                HStack {
                    Text("Privacy")
                        .font(.customTitle3)
                        .foregroundStyle(.hearthEmberMain)
                    Spacer()
                }
                
                CustomDivider(height: 2, color: .hearthEmberDark)
                
                // Privacy Policy Link
                HStack {
                    Text("Tap here to view the ")
                        .font(.customBody1)
                    Link("Privacy Policy",
                         destination: URL(string: "https://hearthjournal.com")!)
                    .underline()
                    .foregroundStyle(.hearthEmberDark)
                    Spacer()
                }
                .padding(.vertical, 4)
                
                // Delete Account Section
                VStack(spacing: 12) {
                    CustomDivider(height: 1, color: Color(UIColor.systemGray5))
                        .padding(.vertical, 4)
                    
                    HStack {
                        Text("Account Management")
                            .font(.customBody1.bold())
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Delete Account")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.red)
                    .padding(.vertical, 8)
                }
            }
        }
        .alert("Are you sure you want to delete your account?",
               isPresented: $showingDeleteAlert,
               actions: deleteAlertButtons,
               message: {
            Text("""
                        This will permanently delete your account and remove all your data \
                        (reflections, prayers, entry reflections, and journal entries). \
                        This action cannot be undone.
                        """)
        })
        .sheet(isPresented: $showingReauthSheet) {
            NavigationStack {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        Text("Confirm Password")
                            .font(.title.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                            .foregroundStyle(.hearthEmberMain)
                        
                        Text("Please enter your password to confirm account deletion")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        SecureField("Password", text: $password)
                            .textContentType(.password)
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(10)
                        
                        if let err = reauthError {
                            Text(err)
                                .foregroundColor(.red)
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 4)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    HStack {
                        Button("Cancel") {
                            showingReauthSheet = false
                            password = ""
                            reauthError = nil
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.systemGray5))
                        .cornerRadius(10)
                        
                        Button("Delete") {
                            profileViewModel.reauthenticateAndDelete(password: password) { result in
                                switch result {
                                case .success:
                                    notificationViewModel.cancelAllScheduledNotifications()
                                    isOnboardingComplete = false
                                    showingReauthSheet = false
                                case .failure(let err):
                                    reauthError = err.localizedDescription
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(password.isEmpty)
                        .opacity(password.isEmpty ? 0.6 : 1)
                    }
                    .padding()
                }
                .background(Color(UIColor.systemBackground))
            }
        }
    }
    
    private func deleteAlertButtons() -> some View {
        Group {
            Button("Delete", role: .destructive) {
                showingReauthSheet = true
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}
