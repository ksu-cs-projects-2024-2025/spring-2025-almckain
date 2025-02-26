//
//  OnboardingView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/6/25.
//


import SwiftUI

struct OnboardingView: View {
    @State private var currentStep = 0
    @AppStorage("isOnboardingComplete") private var isOnboardingComplete: Bool = false

    var body: some View {
        TabView(selection: $currentStep) {
            SignupView(currentStep: $currentStep)
                .tag(0)
            OnboardingNotificationView(currentStep: $currentStep)
                .tag(1)
            CreateAccountView(currentStep: $currentStep, onComplete: {
                isOnboardingComplete = true
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

