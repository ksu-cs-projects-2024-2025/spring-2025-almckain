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

    var body: some View {
        CardView {
            VStack(spacing: 10) {
                header
                CustomDivider(height: 2, color: .hearthEmberDark)
                content
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
    }

    private var header: some View {
        HStack {
            Text("Privacy")
                .font(.customTitle3)
                .foregroundStyle(.hearthEmberMain)
            Spacer()
        }
    }

    private var content: some View {
        VStack(spacing: 16) {
            LinkRow()
            deleteButton
        }
    }

    private struct LinkRow: View {
        var body: some View {
            HStack {
                Text("Tap here to view the ")
                    .font(.customBody1)
                Link("Privacy Policy",
                     destination: URL(string: "https://hearthjournal.com")!)
                    .underline()
                    .foregroundStyle(.hearthEmberDark)
                Spacer()
            }
        }
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            showingDeleteAlert = true
        } label: {
            HStack {
                Image(systemName: "trash")
                Text("Delete Account")
            }
            .font(.customBody1)
            .foregroundColor(.red)
        }
    }

    private func deleteAlertButtons() -> some View {
        Group {
            Button("Delete", role: .destructive) {
                profileViewModel.deleteAccount { result in
                    switch result {
                    case .success:
                        notificationViewModel.cancelAllScheduledNotifications()
                        isOnboardingComplete = false
                    case .failure(let error):
                        print("Failed to delete account:", error.localizedDescription)
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}
