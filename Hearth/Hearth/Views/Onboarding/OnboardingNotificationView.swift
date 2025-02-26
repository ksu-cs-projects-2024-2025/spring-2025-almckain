//
//  OnboardingNotificationView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/26/25.
//

import SwiftUI

struct OnboardingNotificationView: View {
    @Binding var currentStep: Int

    var body: some View {
        VStack {
            Text("Enable notifications")
                .font(.largeTitle)
            
            Button("Enable") {
                //coordinator.goToNextStep()
                currentStep = 2
            }
        }
    }
}

/*
#Preview {
    OnboardingNotificationView()
}
*/
