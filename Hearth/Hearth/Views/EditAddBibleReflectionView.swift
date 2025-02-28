//
//  EditAddBibleReflectionView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/27/25.
//

import SwiftUI

struct EditAddBibleReflectionView: View {
    @ObservedObject var reflectionViewModel: VerseReflectionViewModel
    let verseText: String
    let verseReference: String
    
    @State private var showingErrorAlert = false
    @State private var content: String = ""
    @Binding var isPresented: Bool
    @FocusState private var textBoxIsFocused: Bool
    
    var body: some View {
        ZStack {
            Color.warmSandLight
                .ignoresSafeArea()
            ScrollView {
                VStack {
                    VStack {
                        HStack {
                            Text("New Verse Refelction")
                                .font(.largeTitle.bold())
                                .foregroundStyle(.parchmentDark)
                            
                            Spacer()
                        }
                        .padding(.bottom, 5)
                        
                        HStack {
                            Text(Date.now.formatted(.dateTime
                                .month(.abbreviated)
                                .day(.defaultDigits)
                                .year()
                                .hour(.twoDigits(amPM: .abbreviated))
                                .minute()
                            ))
                            .font(.customHeadline1)
                            .foregroundStyle(.hearthEmberDark)
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    
                    Rectangle()
                        .fill(Color.parchmentDark)
                        .frame(height: 2)
                        .padding(.trailing, 20)

                    VStack {
                        Text(verseText)
                            .font(.customBody1)
                            .foregroundStyle(.hearthEmberDark)
                        
                        HStack {
                            Spacer()
                            Text(verseReference)
                                .padding(.top)
                        }
                    }
                    .padding()
                    
                    Rectangle()
                        .fill(Color.parchmentDark)
                        .frame(height: 2)
                        .padding(.trailing, 20)
                    
                    TextEditor(text: $content)
                        .frame(minHeight: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .padding()
                        .focused($textBoxIsFocused)
                    
                    Button("Save Reflection") {
                        guard !reflectionViewModel.isSaving, !content.isEmpty else { return }
                        
                        reflectionViewModel.saveReflection(
                            reference: verseReference,
                            verseText: verseText,
                            reflectionText: content
                        ) { result in
                            switch result {
                            case .success:
                                isPresented = false
                            case .failure:
                                showingErrorAlert = true
                            }
                        }
                    }
                    .padding()
                    .frame(width: 200)
                    .background(Color.hearthEmberLight)
                    .foregroundColor(.parchmentLight)
                    .font(.headline)
                    .cornerRadius(15)
                    .disabled(reflectionViewModel.isSaving)

                    
                    Spacer()
                }
                .padding(.bottom)
            }
        }
        .onTapGesture {
            textBoxIsFocused = false
        }
        .alert("Error", isPresented: $showingErrorAlert, presenting: reflectionViewModel.error) { error in
            Button("OK", role: .cancel) { }
        } message: { error in
            Text(error.localizedDescription)
        }
    }
}

#Preview {
    @Previewable @State var isPresented = true
    EditAddBibleReflectionView(reflectionViewModel: VerseReflectionViewModel(), verseText: "This is a bible verse. There should be a decent ammount of text here.", verseReference: "Aaron 4:16",isPresented: $isPresented)
}
