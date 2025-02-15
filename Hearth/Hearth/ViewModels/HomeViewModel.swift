//
//  HomeViewModel.swift
//  Hearth
//
//  Created by Aaron McKain on 2/13/25.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var isLoading: Bool = true
    @Published var bibleVerseViewModel = BibleVerseViewModel()
    
    init() {
        fetchData()
    }
    
    func fetchData() {
        isLoading = true  // Start loading

        bibleVerseViewModel.fetchLocalDailyVerse { [weak self] in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
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
    
    func fetchGreeting() -> String {
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
}
