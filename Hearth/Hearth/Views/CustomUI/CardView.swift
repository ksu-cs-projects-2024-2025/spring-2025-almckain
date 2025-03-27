//
//  CardView.swift
//  Hearth
//
//  Created by Aaron McKain on 3/19/25.
//

import SwiftUI

struct CardView<Content: View>: View {
    private let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(.warmSandLight)
                .shadow(
                    color: Color.parchmentDark.opacity(0.05),
                    radius: 4, x: 0, y: 2
                )
            
            content
                .padding(.horizontal, 10)
                .padding(.vertical, 20)
        }
        .padding(.horizontal, 10)
    }
}

/*
#Preview {
    CardView()
}
*/
