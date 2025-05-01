//
//  NewReflectionCardView.swift
//  Hearth
//
//  Created by Aaron McKain on 3/19/25.
//

import SwiftUI

struct NewReflectionCardView: View {
    var isInCalendarView: Bool = false
    @State private var isPulsing = false
    @State private var showAlert = false
    @State private var showReflectionSheet = false
    @State private var isExpanded = false
    @State private var animateShake = false
    @State private var shakeTimer: Timer?
    
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @ObservedObject var reflectionViewModel: ReflectionViewModel
    
    var todayReflection: JournalReflectionModel? {
        reflectionViewModel.highestSpireReflection
    }
    
    var body: some View {
        CardView {
            VStack(spacing: 10) {
                HStack {
                    ZStack {
                        if !isExpanded {
                            Text("View Your Weekly Reflection")
                                .font(.customTitle3)
                                .foregroundColor(.hearthEmberMain)
                                .transition(.opacity)
                                .id("collapsed")
                        } else {
                            Text("Your Weekly Reflection")
                                .font(.customTitle3)
                                .foregroundColor(.hearthEmberMain)
                                .transition(.opacity)
                                .id("expanded")
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: isExpanded)
                    
                    
                    Spacer ()
                    
                    ShimmeringText(text: "NEW")
                        .padding(.horizontal, 5)
                }
                .contentShape(Rectangle())
                .offset(x: animateShake ? 8 : 0)
                .animation(
                    .easeInOut(duration: 0.1)
                    .repeatCount(3, autoreverses: true), value: animateShake
                )
                .onTapGesture {
                    withAnimation {
                        isExpanded.toggle()
                    }
                    
                }
                if isExpanded {
                    CustomDivider(height: 2, color: .hearthEmberMain)
                    
                    Text("We've identified an impactful journal entry from this week. Tap to reflect on it.")
                        .font(.customBody1)
                        .foregroundColor(.parchmentDark)
                        .multilineTextAlignment(.center)
                    
                    HStack {
                        Button(action: {
                            showReflectionSheet = true
                        }) {
                            Text(todayReflection?.reflectionContent.isEmpty ?? true ? "Complete" : "View")
                                .font(.customButton)
                                .foregroundColor(.parchmentLight)
                                .frame(width: 120)
                                .padding()
                                .background(Color.hearthEmberMain)
                                .cornerRadius(15)
                        }
                        .contentShape(Rectangle())
                        
                    }
                    .padding(.vertical, 5)
                }
            }
            .animation(.easeInOut, value: isExpanded)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                reflectionViewModel.fetchAndAnalyzeEntries()
            }
            
            reflectionViewModel.fetchTodayReflection { _ in
                DispatchQueue.main.async{
                    if !isExpanded && (todayReflection?.reflectionContent.isEmpty == true || todayReflection == nil) {
                        startShakeLoop()
                    }
                }
            }
        }
        .alert("Confirm Remove", isPresented: $showAlert) {
            Button("Remove", role: .destructive) {
                notificationViewModel.shouldShowReflectionCard = false
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to remove this weeks suggestion? This cannot be undone.")
        }
        .customSheet(isPresented: $showReflectionSheet) {
            if let reflection = todayReflection {
                if reflection.reflectionContent.isEmpty {
                    AddJournalReflectionView(reflection: reflection, reflectionViewModel: reflectionViewModel)
                } else {
                    DetailedEntryReflectionView(reflectionViewModel: reflectionViewModel, reflection: reflection)
                }
            }
        }
    }
    
    func startShakeLoop() {
        shakeTimer?.invalidate()
        
        shakeTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            if !isExpanded && (todayReflection?.reflectionContent.isEmpty ?? true || todayReflection == nil) {
                animateShake = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    animateShake = false
                }
            } else {
                shakeTimer?.invalidate()
            }
        }
    }
}

/*
 #Preview {
 NewReflectionCardView()
 }
 */
