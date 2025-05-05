//
//  ShimmeringText.swift
//  Hearth
//
//  Created by Aaron McKain on 3/19/25.
//

import SwiftUI

struct ShimmeringText: View {
    var text: String
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.02, paused: false)) { timeline in
            let date = timeline.date.timeIntervalSinceReferenceDate
            let phase = CGFloat(date.truncatingRemainder(dividingBy: 2) * 60) // cycles every 2 sec
            
            Text(text)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(6)
                .background(Color.hearthEmberMain)
                .cornerRadius(8)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .white.opacity(0.5), .clear]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .mask(
                        Text(text).font(.caption).fontWeight(.bold)
                    )
                    .offset(x: phase)
                )
        }
    }
}


#Preview {
    ShimmeringText(text: "text")
}
