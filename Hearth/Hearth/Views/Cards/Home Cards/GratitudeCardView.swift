//
//  GratitudeCardView.swift
//  Hearth
//
//  Created by Aaron McKain on 4/17/25.
//

import SwiftUI

struct GratitudeCardView: View {
    @ObservedObject var gratitudeViewModel: GratitudeViewModel
    @State private var isSheetPresented = false
    @State private var currentPrompt: String = ""
    @State private var promptSkipsRemaining = 3
    @State private var promptIndex = 0
    @State private var animationDirection: Edge = .trailing
    
    init(gratitudeViewModel: GratitudeViewModel) {
        self._gratitudeViewModel = ObservedObject(wrappedValue: gratitudeViewModel)
        gratitudeViewModel.setupDailyPrompts()
        let prompts = gratitudeViewModel.todaysPrompts
        self._currentPrompt = State(initialValue: prompts.first ?? "")
    }
    
    private var hasCompletedTodayGratitude: Bool {
        gratitudeViewModel.hasTodayEntry()
    }
    
    var body: some View {
        CardView {
            VStack {
                HStack {
                    Text("Moment of Gratitude")
                        .font(.customTitle3)
                        .foregroundStyle(.hearthEmberMain)
                    Spacer()
                    
                    if hasCompletedTodayGratitude {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.hearthEmberMain)
                            .font(.title2)
                    }
                }
                
                CustomDivider(height: 2, color: .hearthEmberDark)
                
                VStack(spacing: 12) {
                    if hasCompletedTodayGratitude {
                        /*
                        Text("You've completed a gratitude prompt today!")
                            .font(.customBody1)
                            .foregroundStyle(.parchmentDark)
                            .multilineTextAlignment(.center)
                         */
                        VStack(spacing: 12) {
                            HStack {
                                Text("Today's Entry")
                                    .font(.customHeadline1)
                                    .foregroundStyle(.parchmentDark)
                                
                                Spacer()
                                
                                Text(Date().formatted(date: .abbreviated, time: .omitted))
                                    .font(.customBody2)
                                    .foregroundStyle(.hearthEmberMain)
                            }
                            
                            // Preview of the prompt
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(.parchmentLight)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Prompt:")
                                        .font(.customBody2)
                                        .foregroundStyle(.parchmentDark.opacity(0.8))
                                        .padding(.horizontal)
                                        .padding(.top, 8)
                                    
                                    Text(gratitudeViewModel.todayEntry?.prompt ?? "")
                                        .font(.customBody1)
                                        .foregroundStyle(.parchmentDark)
                                        .lineLimit(2)
                                        .padding(.horizontal)
                                        .padding(.bottom, 8)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            // Preview of the response
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(.white)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Your Response:")
                                        .font(.customBody2)
                                        .foregroundStyle(.parchmentDark.opacity(0.8))
                                        .padding(.horizontal)
                                        .padding(.top, 8)
                                    
                                    Text(gratitudeViewModel.todayEntry?.content ?? "")
                                        .font(.customBody1)
                                        .foregroundStyle(.parchmentDark)
                                        .lineLimit(2)
                                        .padding(.horizontal)
                                        .padding(.bottom, 8)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundStyle(.parchmentLight)
                            
                            ZStack {
                                Text(currentPrompt)
                                    .font(.customBody1)
                                    .foregroundStyle(.parchmentDark)
                                    .padding()
                                    .id(currentPrompt)
                                    .transition(.asymmetric(
                                        insertion: .move(edge: animationDirection),
                                        removal: .move(edge: animationDirection == .trailing ? .leading : .trailing)
                                    ))
                                    .animation(.easeInOut(duration: 0.25), value: currentPrompt)
                            }
                        }
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                guard promptIndex > 0 else { return }
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                animationDirection = .leading
                                withAnimation {
                                    promptIndex -= 1
                                    currentPrompt = gratitudeViewModel.todaysPrompts[promptIndex]
                                }
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
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                animationDirection = .trailing
                                withAnimation {
                                    promptIndex += 1
                                    currentPrompt = gratitudeViewModel.todaysPrompts[promptIndex]
                                }
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
                    
                    if hasCompletedTodayGratitude {
                        Button {
                            isSheetPresented = true
                        } label: {
                            Text("View Entry")
                        }
                    } else {
                        CapsuleButton(
                            title: "Complete Prompt",
                            style: .stroke,
                            foregroundColor: .hearthEmberMain,
                            backgroundColor: .hearthEmberMain,
                            action: {
                                isSheetPresented = true
                            }
                        )
                    }
                }
            }
            .customSheet(isPresented: $isSheetPresented) {
                let entry: GratitudeModel = GratitudeModel(id: "", userID: "", timeStamp: Date(), prompt: currentPrompt, content: "")
                
                if hasCompletedTodayGratitude {
                    DetailedGratitudeView(gratitudeViewModel: gratitudeViewModel, entry: gratitudeViewModel.todayEntry ?? entry)
                } else {
                    AddGratitudePromptView(gratitudeViewModel: gratitudeViewModel, entry: entry, isEditing: false)
                }
            }
            .onAppear {
                gratitudeViewModel.fetchEntries(forMonth: Date())
            }
        }
    }
}

/*
 #Preview {
 GratitudeCardView()
 }
 */
