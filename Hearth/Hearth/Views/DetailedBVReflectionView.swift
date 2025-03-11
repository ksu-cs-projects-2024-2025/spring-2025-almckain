//
//  DetailedBVReflectionView.swift
//  Hearth
//
//  Created by Aaron McKain on 3/4/25.
//

import SwiftUI

struct DetailedBVReflectionView: View {
    @ObservedObject var reflectionViewModel: VerseReflectionViewModel
    @Binding var isPresented: Bool
    @State private var isEditing = false
    @State private var showingDeleteConfirmation = false
    
    var formattedTimeStamp: String {
        if let timeStamp = reflectionViewModel.reflection?.timeStamp {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd, yyyy 'at' h:mm a"
            return formatter.string(from: timeStamp)
        } else {
            return "No date available"
        }
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
                        
                        Rectangle()
                            .fill(Color.parchmentDark)
                            .frame(height: 2)
                        
                        Text(reflectionViewModel.reflection?.bibleVerseText ?? "No bible verse")
                            .font(.customHeadline1)
                            .foregroundStyle(.hearthEmberDark)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                        HStack {
                            Spacer()
                            Text(reflectionViewModel.reflection?.title ?? "No title")
                                .foregroundStyle(.parchmentDark)
                                .font(.customBody1)
                        }
                        
                        Rectangle()
                            .fill(Color.parchmentDark)
                            .frame(height: 2)
                        
                        Text(reflectionViewModel.reflection?.reflection ?? "No reflection")
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
                    if let reflectionId = reflectionViewModel.reflection?.id {
                        reflectionViewModel.deleteReflection(withId: reflectionId) { result in
                            switch result {
                            case .success:
                                isPresented = false
                            case .failure(let error):
                                print("Error deleting reflection: \(error.localizedDescription)")
                            }
                        }
                    } else {
                        print("No reflection available to delete")
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this reflection? This action cannot be undone.")
            }
        .sheet(isPresented: $isEditing) {
            if let reflection = reflectionViewModel.reflection {
                ZStack {
                    Color.warmSandLight
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "x.circle.fill")
                                .padding(.top)
                                .padding(.trailing, 20)
                                .foregroundStyle(.parchmentDark.opacity(0.6))
                                .font(.customTitle2)
                                .onTapGesture {
                                    isEditing.toggle()
                                }
                        }
                        EditAddBibleReflectionView(reflectionViewModel: reflectionViewModel, existingReflection: reflection, verseText: reflection.bibleVerseText, verseReference: reflection.title, isPresented: $isEditing)
                    }
                }
                .presentationDetents([.fraction(0.95)])
            }
        }
    }
}

/*
 #Preview {
 DetailedBVReflectionView()
 }
 */
