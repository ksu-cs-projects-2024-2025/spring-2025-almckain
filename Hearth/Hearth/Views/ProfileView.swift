//
//  ProfileView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/6/25.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @AppStorage("isOnboardingComplete") private var isOnboardingComplete: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            if let user = viewModel.user {
                Text("Hello, \(user.firstName) \(user.lastName)!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            } else {
                ProgressView()
            }
            
            Button("Log Out") {
                viewModel.logout {
                    isOnboardingComplete = false
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .onAppear {
            viewModel.fetchUserData()
        }
    }
}

#Preview {
    ProfileView()
}
