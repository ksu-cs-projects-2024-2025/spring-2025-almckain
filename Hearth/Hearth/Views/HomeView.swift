//
//  HomeView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/6/25.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    @ObservedObject var homeViewModel: HomeViewModel
    @ObservedObject var reflectionViewModel: VerseReflectionViewModel
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        NavigationStack {
            if profileViewModel.isLoading || homeViewModel.isLoading {
                LoadingScreenView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ZStack {
                    Color.parchmentLight
                        .ignoresSafeArea()
                    ScrollView {
                        BibleVerseCardView(viewModel: homeViewModel.bibleVerseViewModel, reflectionViewModel: reflectionViewModel)
                            .padding(.top, 10)
                        
                        /*
                        Button("Clear cache") {
                            reflectionViewModel.manuallyClearReflectionCache()
                        }
                         */
                        
                    }
                    .navigationTitle("\(homeViewModel.fetchGreeting()), \(profileViewModel.user?.firstName ?? "Guest")")
                    .navigationBarTitleDisplayMode(.large)
                }
            }
        }
        .onAppear {
            //reflectionViewModel.debugPrintPersistentReflection()
            profileViewModel.fetchUserData()
            let appearance = homeViewModel.navBarAppearance()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

/*
#Preview {
    HomeView()
}
*/
