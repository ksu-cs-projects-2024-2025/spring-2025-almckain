//
//  CustomDivider.swift
//  Hearth
//
//  Created by Aaron McKain on 3/19/25.
//

import SwiftUI

struct CustomDivider: View {
    var height: CGFloat
    var color: Color
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: height)
    }
}

#Preview {
    CustomDivider(height: 2, color: .gray)
}
