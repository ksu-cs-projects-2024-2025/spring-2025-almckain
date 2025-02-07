//
//  HomeView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/6/25.
//

import SwiftUI

struct HomeView: View {
    /// Todo: Replace with data acquired from onboarding
    let usersFirstName = "Aaron"
    
    // Initializes styles for navbar
    init() {
        let appearance = navBarAppearance()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.parchmentLight
                    .ignoresSafeArea()
                ScrollView {
                    BibleVerseCardView()
                    BibleVerseCardView()
                    BibleVerseCardView()
                    BibleVerseCardView()
                    BibleVerseCardView()
                }
                .navigationTitle("\(greeting()), \(usersFirstName)")
                .navigationBarTitleDisplayMode(.large)
            }
        }
    }
    
    
    
    func greeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 0..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        case 17..<23:
            return "Good Evening"
        default:
            return "Welcome Back"
        }
    }
    
    func navBarAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "WarmSandMain")
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(named: "HearthEmberMain") ?? UIColor.red
        ]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "HearthEmberMain") ?? UIColor.red]
        return appearance
    }
}

#Preview {
    HomeView()
}
