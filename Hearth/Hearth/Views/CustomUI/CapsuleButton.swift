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
        }
    }
}

