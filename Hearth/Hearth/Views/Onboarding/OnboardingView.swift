//
//  OnboardingView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/6/25.
//


import SwiftUI
import FirebaseAuth

struct OnboardingView: View {
    //@State private var currentStep = 0
    @AppStorage("isOnboardingComplete") private var isOnboardingComplete: Bool = false
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var currentStep: Int = Auth.auth().currentUser == nil ? 0 : 1
    
    var body: some View {
        TabView(selection: $currentStep) {
            SignupView(viewModel: viewModel, currentStep: $currentStep)
                .tag(0)
            OnboardingNotificationView(currentStep: $currentStep)
                .tag(1)
            CreateAccountView(currentStep: $currentStep, onComplete: {
                viewModel.completeOnboarding()
            })
            .tag(2)
        }
        //.tabViewStyle(PageTabViewStyle())
        //.gesture(DragGesture().onChanged { _ in })
    }
}

#Preview {
    OnboardingView()
}

