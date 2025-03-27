//
//  NewReflectionCardView.swift
//  Hearth
//
//  Created by Aaron McKain on 3/19/25.
//

import SwiftUI

struct NewReflectionCardView: View {
    @State private var isPulsing = false
    @State private var showAlert = false
    @State private var showReflectionSheet = false
    
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @ObservedObject var reflectionViewModel: ReflectionViewModel
    
    var todayReflection: JournalReflectionModel? {
        reflectionViewModel.reflections.first { reflection in
            Calendar.current.isDateInToday(reflection.reflectionTimestamp)
        }
    }
    
    var body: some View {
        CardView {
            VStack(spacing: 10) {
                HStack {
                    Text("Your Weekly Reflection")
                        .font(.customTitle3)
                        .foregroundColor(.hearthEmberMain)
                    
                    Spacer ()
                    
                    ShimmeringText(text: "NEW")
                        .padding(.horizontal, 5)
                }
                
                CustomDivider(height: 2, color: .hearthEmberMain)
                
                Text("We've identified an impactful journal entry from this week. Tap to reflect on it.")
                    .font(.customBody1)
                    .foregroundColor(.parchmentDark)
                    .multilineTextAlignment(.center)
                
                HStack {
                    Button("Remove") {
                        showAlert = true
                    }
                    .padding()
                    .frame(width: 120)
                    .foregroundColor(.hearthEmberMain)
                    .font(.headline)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.hearthEmberMain, lineWidth: 4)
                    )
                    
                    Button(todayReflection?.reflectionContent.isEmpty ?? true ? "Complete" : "View") {
                        showReflectionSheet = true
                    }
                    .padding()
                    .frame(width: 120)
                    .background(Color.hearthEmberMain)
                    .foregroundColor(.parchmentLight)
                    .font(.headline)
                    .cornerRadius(15)
                }
                .padding(.vertical, 5)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                reflectionViewModel.fetchAndAnalyzeEntries()
            }
            
            reflectionViewModel.fetchTodayReflection { _ in }
        }
        .alert("Confirm Remove", isPresented: $showAlert) {
            Button("Remove", role: .destructive) {
                notificationViewModel.shouldShowReflectionCard = false
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to remove this from the home screen? You can still view it in your calendar.")
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
}

/*
#Preview {
    NewReflectionCardView()
}
*/
