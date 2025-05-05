//
//  PromptSelectorView.swift
//  Hearth
//
//  Created by Aaron McKain on 5/4/25.
//

import SwiftUI

struct PromptSelectorView: View {
    @ObservedObject var gratitudeViewModel: GratitudeViewModel
    @Binding var selectedPrompt: String
    
    @State private var promptIndex: Int = 0
    @State private var animationDirection: Edge = .trailing
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(.parchmentLight)
                
                Text(selectedPrompt)
                    .font(.customBody1)
                    .foregroundStyle(.parchmentDark)
                    .padding()
                    .id(selectedPrompt)
                    .transition(.asymmetric(
                        insertion: .move(edge: animationDirection),
                        removal: .move(edge: animationDirection == .trailing ? .leading : .trailing)
                    ))
                    .animation(.easeInOut(duration: 0.25), value: selectedPrompt)
            }
            
            HStack(spacing: 12) {
                Button(action: {
                    guard promptIndex > 0 else { return }
                    animationDirection = .leading
                    withAnimation {
                        promptIndex -= 1
                        selectedPrompt = gratitudeViewModel.todaysPrompts[promptIndex]
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }) {
                    Image(systemName: "arrow.backward.circle")
                        .foregroundStyle(promptIndex == 0 ? .parchmentMedium : .hearthEmberMain)
                        .font(.title2)
                        .scaleEffect(promptIndex == 0 ? 1.0 : 1.1)
                        .opacity(promptIndex == 0 ? 0.5 : 1.0)
                }
                .disabled(promptIndex == 0)
                
                Text("Skip")
                    .foregroundStyle(.parchmentDark)
                    .font(.customBody2)
                
                Button(action: {
                    guard promptIndex < gratitudeViewModel.todaysPrompts.count - 1 else { return }
                    animationDirection = .trailing
                    withAnimation {
                        promptIndex += 1
                        selectedPrompt = gratitudeViewModel.todaysPrompts[promptIndex]
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }) {
                    Image(systemName: "arrow.forward.circle")
                        .foregroundStyle(promptIndex == gratitudeViewModel.todaysPrompts.count - 1 ? .parchmentMedium : .hearthEmberMain)
                        .font(.title2)
                        .scaleEffect(promptIndex == gratitudeViewModel.todaysPrompts.count - 1 ? 1.0 : 1.1)
                        .opacity(promptIndex == gratitudeViewModel.todaysPrompts.count - 1 ? 0.5 : 1.0)
                }
                .disabled(promptIndex == gratitudeViewModel.todaysPrompts.count - 1)
            }
            .padding(.vertical, 6)
        }
        .onAppear {
            if let first = gratitudeViewModel.todaysPrompts.first {
                selectedPrompt = first
            }
        }
    }
}
