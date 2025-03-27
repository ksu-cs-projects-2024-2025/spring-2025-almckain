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
    @ObservedObject var entryReflectionViewModel: ReflectionViewModel
    
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    
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
                        LazyVStack(spacing: 15) {
                            if showReflectionCard {
                                NewReflectionCardView(reflectionViewModel: entryReflectionViewModel)
                                    .transition(.move(edge: .leading))
                            }
                            BibleVerseCardView(viewModel: homeViewModel.bibleVerseViewModel, reflectionViewModel: reflectionViewModel)
                        }
                    }
                    .padding(.top, 15)
                    .navigationTitle("\(homeViewModel.fetchGreeting()), \(profileViewModel.user?.firstName ?? "Guest")")
                    .navigationBarTitleDisplayMode(.large)
                }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showReflectionCard)
        .onAppear {
            notificationViewModel.updateReflectionCardVisibility()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showReflectionCard = notificationViewModel.shouldShowReflectionCard
                }
            }
            
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
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            notificationViewModel.updateReflectionCardVisibility()
            withAnimation(.easeInOut(duration: 0.5)) {
                showReflectionCard = notificationViewModel.shouldShowReflectionCard
            }
        }
        
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            notificationViewModel.updateReflectionCardVisibility()
            withAnimation(.easeInOut(duration: 0.5)) {
                showReflectionCard = notificationViewModel.shouldShowReflectionCard
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
        .onChange(of: notificationViewModel.shouldShowReflectionCard) { oldValue, newValue in
            withAnimation(.easeInOut(duration: 0.5)) {
                showReflectionCard = newValue
            }
        }
    }
}

/*
#Preview {
    HomeView()
}
*/
