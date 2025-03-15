//
//  CreateAccountView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/26/25.
//

import SwiftUI

struct CreateAccountView: View {
    @Binding var currentStep: Int

    var onComplete: () -> Void
    
    var body: some View {
        ZStack {
            Color.warmSandLight
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Text("Great! \nYou're all set.")
                    .multilineTextAlignment(.center)
                    .font(.customDisplay)
                    .foregroundStyle(.hearthEmberMain)
                    .padding()
                
                Text("Tap the button to complete the onboarding")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.hearthEmberDark)
                
                Spacer()
                
                Button(action: onComplete) {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.hearthEmberMain)
                        .foregroundColor(.parchmentLight)
                        .clipShape(RoundedRectangle(cornerRadius: 21))
                        .font(.customButton)
                }
            }
            .padding()
        }
    }
}


#Preview {
    CreateAccountView(currentStep: .constant(2), onComplete: {})
}

