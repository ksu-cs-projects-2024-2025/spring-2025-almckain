//
//  DetailedEntryReflectionView.swift
//  Hearth
//
//  Created by Aaron McKain on 3/23/25.
//

import SwiftUI

struct DetailedEntryReflectionView: View {
    @ObservedObject var reflectionViewModel: ReflectionViewModel
    var reflection: JournalReflectionModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showingDeleteConfirmation = false
    @State private var showEditSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.warmSandLight
                    .ignoresSafeArea()
                VStack {
                    ScrollView {
                        VStack(spacing: 20) {
                            HStack {
                                Text("From ")
                                    .font(.customHeadline1)
                                    .foregroundStyle(.parchmentDark)
                                Text(reflection.journalEntry.timestamp.formatted(date: .abbreviated, time: .omitted))
                                    .font(.customHeadline1)
                                    .foregroundStyle(.hearthEmberMain)
                                Spacer()
                            }
                            
                            CustomDivider(height: 2, color: .hearthEmberMain)
                            
                            VStack(spacing: 20) {
                                Text(reflection.journalEntry.title)
                                    .font(.customHeadline1)
                                    .foregroundStyle(.parchmentDark)
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15)
                                        .foregroundStyle(.warmSandMain.opacity(0.4))
                                    
                                    Text("\"\(reflection.journalEntry.content)\"")
                                        .font(.customBody1)
                                        .foregroundStyle(.parchmentDark)
                                        .padding()
                                }
                                
                                
                                CustomDivider(height: 2, color: .hearthEmberMain)
                                
                                HStack {
                                    Text("Your Reflection")
                                        .font(.customHeadline1)
                                        .foregroundStyle(.parchmentDark)
                                    
                                    Text(reflection.reflectionTimestamp.formatted(date: .abbreviated, time: .omitted))
                                        .font(.customHeadline1)
                                        .foregroundStyle(.hearthEmberMain)
                                }
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15)
                                        .foregroundStyle(.parchmentLight)
                                    
                                    Text(reflection.reflectionContent)
                                        .font(.customBody1)
                                        .foregroundStyle(.parchmentDark)
                                        .padding()
                                }
                            }
                            Spacer()
                        }
                    }
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            showingDeleteConfirmation = true
                        }) {
                            Text("Delete")
                                .frame(width: 120)
                                .padding()
                                .foregroundColor(.hearthEmberMain)
                                .font(.headline)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.hearthEmberMain, lineWidth: 4)
                                )
                        }
                        
                        Button(action: {
                            showEditSheet = true
                        }) {
                            Text("Edit")
                                .frame(width: 120)
                                .padding()
                                .background(Color.hearthEmberMain)
                                .foregroundColor(.parchmentLight)
                                .font(.headline)
                                .cornerRadius(15)
                        }
                    }
                }
            }
            .navigationTitle("View Reflection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.warmSandLight, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "x.circle.fill")
                    }
                }
            }
            .alert("Confirm Delete", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    let updatedReflection = JournalReflectionModel(
                        id: reflection.id,
                        userID: reflection.userID,
                        journalEntry: reflection.journalEntry,
                        reflectionContent: "",
                        reflectionTimestamp: Date(),
                        spireScore: reflection.spireScore
                    )
                    reflectionViewModel.updateReflection(updatedReflection) { success in
                        if success {
                            dismiss()
                        } else {
                            print("Error resetting reflection")
                        }
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this entry? This action cannot be undone.")
            }
            .customSheet(isPresented: $showEditSheet, content: {
                AddJournalReflectionView(reflection: reflection, reflectionViewModel: reflectionViewModel, isEditing: true)
            })
        }
    }
}


#Preview {
    let mockEntry = JournalEntrySnapshot(
        title: "Cant believe i shit myself in matrix theory like wtf",
        content: "I shit myself yeah so pretty much what happened was i had like a hexashot of espresso and the night before i had the atomic wings from buggalo wild wings this really doesnt matter im just making sure it doesnt look like compolete shit if the entry is really long",
        timestamp: Date()
    )
    
    let mockReflection = JournalReflectionModel(
        id: UUID().uuidString,
        userID: "user123",
        journalEntry: mockEntry,
        reflectionContent: "ribbit",
        reflectionTimestamp: Date(),
        spireScore: 4.5
    )
    DetailedEntryReflectionView(reflectionViewModel: ReflectionViewModel(), reflection: mockReflection)
}

