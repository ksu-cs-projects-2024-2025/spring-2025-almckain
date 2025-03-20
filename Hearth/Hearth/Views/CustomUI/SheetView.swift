//
//  SheetView.swift
//  Hearth
//
//  Created by Aaron McKain on 3/19/25.
//

import SwiftUI

extension View {
    func customSheet<Content: View>(
        isPresented: Binding<Bool>,
        detents: Set<PresentationDetent> = [.fraction(0.95)],
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            ZStack {
                Color.warmSandLight
                    .ignoresSafeArea()
                
                VStack {
                    // Close Button in top-right
                    HStack {
                        Spacer()
                        Image(systemName: "x.circle.fill")
                            .padding(.top)
                            .padding(.trailing, 20)
                            .foregroundStyle(.parchmentDark.opacity(0.6))
                            .font(.customTitle2)
                            .onTapGesture {
                                isPresented.wrappedValue = false
                            }
                    }
                    
                    // The caller's custom content
                    content()
                        .padding(.top, 10)
                        .padding(.horizontal, 20)
                }
            }
            .presentationDetents(detents)
        }
    }
}
