//
//  LeftRoundedRectangle.swift
//  Hearth
//
//  Created by Aaron McKain on 2/13/25.
//

import SwiftUI

struct LeftRoundedRectangle: Shape {
    var cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: 0, y: cornerRadius))
        
        path.addArc(
            center: CGPoint(x: cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        
        path.addLine(to: CGPoint(x: cornerRadius, y: rect.height))
        
        path.addArc(
            center: CGPoint(x: cornerRadius, y: rect.height - cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )
        
        path.closeSubpath()
        return path
    }
}

