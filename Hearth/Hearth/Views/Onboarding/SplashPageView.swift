//
//  SplashPageView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/25/25.
//

import SwiftUI

struct SplashPageView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.warmSandLight
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    
                    Text("Hearth")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundStyle(.hearthEmberMain)
                    
                    HStack(spacing: 10) {
                        Text("Journal")
                            .font(.customFootnote)
                        Text("•")
                        Text("Reflect")
                            .font(.customFootnote)
                        Text("•")
                        Text("Pray")
                            .font(.customFootnote)
                    }
                    
                    Spacer()
                    VStack {
                        NavigationLink(destination: LoginView()) {
                            Text("Log In")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .font(.customButton)
                                .foregroundColor(.white)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.hearthEmberMain)
                                )
                        }
                        
                        NavigationLink(destination: OnboardingView()) {
                            Text("Sign Up")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .font(.customButton)
                                .foregroundColor(.hearthEmberMain)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(style: StrokeStyle(lineWidth: 5))
                                        .foregroundColor(Color.hearthEmberMain)
                                )
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            let appearance = navBarAppearance()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            
            let tabAppearance = UITabBarAppearance()
            UITabBar.appearance().standardAppearance = tabAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
            UITabBar.appearance().isHidden = true
        }
    }
    
    func navBarAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground() // Ensures non-translucency
        appearance.backgroundColor = nil // No specific background color
        appearance.titleTextAttributes = [:] // No specific title styling
        appearance.largeTitleTextAttributes = [:] // No specific large title styling
        appearance.shadowColor = .clear // Removes the thin line
        appearance.shadowImage = UIImage() // Ensures no shadow is applied
        return appearance
    }

}

#Preview {
    SplashPageView()
}
