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
    
    @State private var showNotificationAlert = false
    
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
            
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    if settings.authorizationStatus == .denied {
                        showNotificationAlert = true
                    }
                }
            }
        }
        .alert(isPresented: $showNotificationAlert) {
            Alert(
                title: Text("Enable Notifications"),
                message: Text("Hearth works best with notifications! Please enable notifications in Settings."),
                primaryButton: .default(Text("Open Settings"), action: {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }),
                secondaryButton: .cancel()
            )
        }
    }
}

/*
#Preview {
    HomeView()
}
*/
