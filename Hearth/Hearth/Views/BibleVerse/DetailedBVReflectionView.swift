//
//  DetailedBVReflectionView.swift
//  Hearth
//
//  Created by Aaron McKain on 3/4/25.
//

import SwiftUI

struct DetailedBVReflectionView: View {
    let reflectionEntry: VerseReflectionModel
    var selectedDate: Date?
    @ObservedObject var reflectionViewModel: VerseReflectionViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var isPresented: Bool
    @State private var isEditing = false
    @State private var showingDeleteConfirmation = false
    
    var formattedTimeStamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy 'at' h:mm a"
        return formatter.string(from: reflectionEntry.timeStamp)
    }
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.warmSandLight
                    .ignoresSafeArea()
                VStack {
                    ScrollView {
                        VStack {
                            HStack {
                                (
                                    Text("From: ")
                                        .font(.customHeadline1)
                                        .foregroundStyle(.parchmentDark) +
                                    Text(formattedTimeStamp)
                                        .font(.customHeadline1)
                                        .foregroundStyle(.hearthEmberDark)
                                )
                                Spacer()
                            }

                            
                            CustomDivider(height: 2, color: .hearthEmberMain)
                                .padding(.vertical, 10)

                            VStack {
                                Text("\(reflectionEntry.bibleVerseText)")
                                    .font(.customBody1)
                                    .italic()
                                    .foregroundStyle(.parchmentDark)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                                
                                HStack {
                                    Spacer()
                                    Text(reflectionEntry.title)
                                        .foregroundStyle(.parchmentDark)
                                        .font(.customBody1)
                                }
                            }
                            
                            CustomDivider(height: 2, color: .hearthEmberMain)
                                .padding(.vertical, 10)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(.parchmentLight)
                                
                                Text(reflectionEntry.reflection)
                                    .font(.customBody1)
                                    .foregroundStyle(.parchmentDark)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity)
                                    .padding()
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
                    
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            showingDeleteConfirmation = true
                        }) {
                            Text("Delete")
                                .frame(width: 100)
                                .padding()
                                .foregroundColor(.hearthEmberMain)
                                .font(.headline)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.hearthEmberMain, lineWidth: 4)
                                )
                        }

                        Button(action: {
                            isEditing = true
                        }) {
                            Text("Edit")
                                .frame(width: 100)
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
        .alert("Confirm Delete", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                if !reflectionEntry.id.isEmpty {
                    reflectionViewModel.deleteReflection(withId: reflectionEntry.id) { result in
                        switch result {
                        case .success:
                            isPresented = false
                            
                            reflectionViewModel.fetchReflections(for: selectedDate ?? Date())
                            
                        case .failure(let error):
                            print("Error deleting reflection: \(error.localizedDescription)")
                        }
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this reflection? This action cannot be undone.")
        }
        .customSheet(isPresented: $isEditing) {
            EditAddBibleReflectionView(
                            reflectionViewModel: reflectionViewModel,
                            existingReflection: reflectionEntry,
                            verseText: reflectionEntry.bibleVerseText,
                            verseReference: reflectionEntry.title,
                            isEditingPresented: $isEditing
                        )
        }
        .presentationDetents([.fraction(0.95)])

    }
}


 #Preview {     
     let sampleReflection = VerseReflectionModel(id: "1", userID: "1", title: "Title", bibleVerseText: "Verse Text", reflection: "My Reflection", timeStamp: Date())
     
     
     let viewModel = VerseReflectionViewModel()
     
     DetailedBVReflectionView(
         reflectionEntry: sampleReflection,
         selectedDate: Date(),
         reflectionViewModel: viewModel,
         isPresented: .constant(false)
     )
 }
 
