//
//  HomeView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/6/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject var profileViewModel = ProfileViewModel()
    @StateObject var homeViewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.parchmentLight
                    .ignoresSafeArea()
                ScrollView {
                    BibleVerseCardView()
                        .padding(.top, 10)
                }
                .navigationTitle("\(homeViewModel.fetchGreeting()), \(profileViewModel.userName ?? "Guest")")
                .navigationBarTitleDisplayMode(.large)
            }
        }
        .onAppear {
            profileViewModel.fetchUserData()
            let appearance = homeViewModel.navBarAppearance()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    HomeView()
}
