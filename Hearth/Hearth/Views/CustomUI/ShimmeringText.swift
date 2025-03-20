//
//  ShimmeringText.swift
//  Hearth
//
//  Created by Aaron McKain on 3/19/25.
//

import SwiftUI

struct ShimmeringText: View {
    @State private var phase: CGFloat = 0
    var text: String
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(6)
            .background(Color.hearthEmberMain)
            .cornerRadius(8)
            .overlay(
                LinearGradient(gradient: Gradient(colors: [.clear, .white.opacity(0.5), .clear]), startPoint: .leading, endPoint: .trailing)
                    .mask(Text(text).font(.caption).fontWeight(.bold))
                    .offset(x: phase)
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 30
                }
            }
    }
}

#Preview {
    ShimmeringText(text: "text")
}
