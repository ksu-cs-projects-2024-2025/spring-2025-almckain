//
//  CapsuleButton.swift
//  Hearth
//
//  Created by Aaron McKain on 3/31/25.
//

import SwiftUI

struct CapsuleButton: View {
    enum Style {
        case filled
        case stroke
    }
    
    let title: String
    let style: Style
    let foregroundColor: Color
    let backgroundColor: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.customTitle3)
                .foregroundStyle(foregroundColor)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                .background(
                    Capsule()
                        .fill(style == .filled ? backgroundColor : .clear)
                )
                .overlay(
                    Capsule()
                        .stroke(backgroundColor, lineWidth: style == .stroke ? 4 : 0)
                )
                .opacity(isPressed ? 0.6 : 1.0)
                //.scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

