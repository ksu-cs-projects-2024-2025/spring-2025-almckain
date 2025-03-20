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
    @Binding var isPresented: Bool
    @State private var isEditing = false
    @State private var showingDeleteConfirmation = false
    
    var formattedTimeStamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy 'at' h:mm a"
        return formatter.string(from: reflectionEntry.timeStamp)
    }
    
    
    var body: some View {
        ZStack {
            Color.warmSandLight
                .ignoresSafeArea()
            VStack {
                ScrollView {
                    VStack {
                        VStack {
                            HStack {
                                Text("Verse Reflection")
                                    .font(.customTitle1)
                                    .foregroundStyle(.parchmentDark)
                                
                                Spacer()
                            }
                            .padding(.bottom, 5)
                            
                            HStack {
                                Text(formattedTimeStamp)
                                    .font(.customHeadline1)
                                    .foregroundStyle(.hearthEmberDark)
                                Spacer()
                            }
                        }
                        
                        CustomDivider(height: 2, color: .hearthEmberDark)
                        
                        Text("\(reflectionEntry.bibleVerseText)")
                            .font(.customHeadline1)
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
                        
                        CustomDivider(height: 2, color: .hearthEmberDark)
                        
                        Text(reflectionEntry.reflection)
                            .font(.customBody1)
                            .foregroundStyle(.parchmentDark)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                    }
                }
                
                Spacer()
                
                HStack {
                    Button("Edit") {
                        isEditing = true
                    }
                    .padding()
                    .frame(width: 100)
                    .foregroundColor(.hearthEmberLight)
                    .font(.headline)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.hearthEmberLight, lineWidth: 4)
                    )
                    
                    Button("Delete") {
                        showingDeleteConfirmation = true
                    }
                    .padding()
                    .frame(width: 100)
                    .background(Color.hearthEmberLight)
                    .foregroundColor(.parchmentLight)
                    .font(.headline)
                    .cornerRadius(15)
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
 
