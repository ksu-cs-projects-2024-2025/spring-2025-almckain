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
                
                content()
                    .padding(.horizontal, 20)
            }
            .presentationDetents(detents)
        }
    }
}
