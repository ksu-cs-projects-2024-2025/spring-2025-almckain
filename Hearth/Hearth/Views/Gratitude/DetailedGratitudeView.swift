//
//  DetailedGratitudeView.swift
//  Hearth
//
//  Created by Aaron McKain on 4/18/25.
//

import SwiftUI

struct DetailedGratitudeView: View {
    @ObservedObject var gratitudeViewModel: GratitudeViewModel
    var entry: GratitudeModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showingDeleteConfirmation = false
    @State private var showEditSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.warmSandLight
                    .ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            Text("For: ")
                                .font(.customHeadline1)
                                .foregroundStyle(.parchmentDark)
                            
                            Text(entry.timeStamp.formatted(date: .abbreviated, time: .omitted))
                                .font(.customHeadline1)
                                .foregroundStyle(.hearthEmberMain)
                            
                            Spacer()
                        }
                        
                        CustomDivider(height: 2, color: .hearthEmberMain)
                        
                        HStack {
                            Text("Prompt:")
                                .font(.customHeadline1)
                                .foregroundStyle(.parchmentDark)
                            
                            Spacer()
                        }
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundStyle(.parchmentLight)
                            
                            Text(entry.prompt)
                                .font(.customBody1)
                                .foregroundStyle(.parchmentDark)
                                .padding()
                        }
                        
                        CustomDivider(height: 2, color: .hearthEmberMain)
                        
                        Text("Your Response")
                            .font(.customHeadline1)
                            .foregroundStyle(.parchmentDark)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundStyle(.white)
                            
                            Text(entry.content)
                                .font(.customBody1)
                                .foregroundStyle(.parchmentDark)
                                .padding()
                        }
                        
                        
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
            }
            .navigationTitle("Gratitude Prompt")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarClearBackground(
                UIColor(named: "WarmSandLight"),
                titleFont: UIFont.systemFont(ofSize: 25, weight: .bold),
                titleColor: UIColor(named: "ParchmentDark")
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "x.circle.fill")
                    }
                }
            }
            .alert("Confirm Delete", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    gratitudeViewModel.deleteGratitude(entryID: entry.id) { success in
                        if success {
                            dismiss()
                        } else {
                            print("Error deleting gratitude prompt")
                        }
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this entry? This action cannot be undone.")
            }
            .customSheet(isPresented: $showEditSheet, content: {
                AddGratitudePromptView(gratitudeViewModel: gratitudeViewModel, entry: entry, isEditing: true)
            })
        }
    }
}

/*
#Preview {
    DetailedGratitudeView()
}
*/
