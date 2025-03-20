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
    @State private var showReflectionCard = false
    
    @AppStorage("homeAppearCount") private var homeAppearCount = 0
    
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
                        
                        if showReflectionCard {
                            NewReflectionCardView()
                                .padding(.top, 10)
                                .transition(.move(edge: .leading))
                                .animation(.easeInOut(duration: 0.5), value: showReflectionCard)
                        }
                        
                        BibleVerseCardView(viewModel: homeViewModel.bibleVerseViewModel, reflectionViewModel: reflectionViewModel)
                        
                    }
                    .navigationTitle("\(homeViewModel.fetchGreeting()), \(profileViewModel.user?.firstName ?? "Guest")")
                    .navigationBarTitleDisplayMode(.large)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                showReflectionCard = true
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            profileViewModel.fetchUserData()
            let appearance = homeViewModel.navBarAppearance()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            
            homeAppearCount += 1
            
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    if settings.authorizationStatus == .denied && (homeAppearCount % 20 == 0) {
                        showNotificationAlert = true
                        homeAppearCount = 0
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
