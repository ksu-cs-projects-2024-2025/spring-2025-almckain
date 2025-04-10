//
//  CustomCalendarCardView.swift
//  Hearth
//
//  Created by Aaron McKain on 4/8/25.
//

import SwiftUI

struct CustomCalendarCardView<Content: View>: View {
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
            
            HStack {
                HStack {
                    LeftRoundedRectangle(cornerRadius: 12)
                        .fill(Color.hearthEmberMain)
                        .frame(width: 10)
                }
                
                content
                    .padding(.horizontal, 10)
                    .padding(.vertical, 20)
                
                Spacer()
            }
        }
        .padding(.horizontal, 10)
    }
}

struct CardHeaderView: View {
    let title: String
    let secondary: String

    var body: some View {
        HStack {
            Text(title)
                .font(.customHeadline2)
                .foregroundStyle(.hearthEmberMain)
            Text("•")
            Text(secondary)
                .font(.customCaption1)
                .foregroundStyle(.parchmentDark.opacity(0.6))
        }
    }
}


/*
 #Preview {
 CustomCalendarCardView()
 }
 */
