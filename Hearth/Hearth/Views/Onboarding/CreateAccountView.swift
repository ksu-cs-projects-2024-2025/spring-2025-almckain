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
        VStack {
            Text("Great! You're all set.")
                .font(.title)
                .padding()

            Button("Finish") {
                onComplete()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

/*
#Preview {
    CreateAccountView()
}
*/
