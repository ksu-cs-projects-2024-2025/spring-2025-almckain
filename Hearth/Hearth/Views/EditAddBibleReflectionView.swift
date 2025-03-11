//
//  EditAddBibleReflectionView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/27/25.
//

import SwiftUI

struct EditAddBibleReflectionView: View {
    @ObservedObject var reflectionViewModel: VerseReflectionViewModel
    
    var existingReflection: VerseReflectionModel?
    
    let verseText: String
    let verseReference: String
    
    @State private var showingErrorAlert = false
    @State private var content: String = ""
    @Binding var isPresented: Bool
    @FocusState private var textBoxIsFocused: Bool
    
    private var isEditingExistingReflection: Bool {
        existingReflection?.id != nil
    }
    
    init(reflectionViewModel: VerseReflectionViewModel, existingReflection: VerseReflectionModel? = nil, verseText: String, verseReference: String, isPresented: Binding<Bool>) {
        self.reflectionViewModel = reflectionViewModel
        self.existingReflection = existingReflection
        self.verseText = verseText
        self.verseReference = verseReference
        self._isPresented = isPresented
        
        _content = State(initialValue: existingReflection?.reflection ?? "")
    }
    
    var body: some View {
        ZStack {
            Color.warmSandLight
                .ignoresSafeArea()
            ScrollView {
                VStack {
                    VStack {
                        HStack {
                            VStack {
                                Text(isEditingExistingReflection ? "Edit Verse Reflection" : "New Verse Refelction")
                                    .font(.largeTitle.bold())
                                    .foregroundStyle(.parchmentDark)
                            }
                            
                            Spacer()
                        }
                        .padding(.bottom, 5)
                        
                        HStack {
                            let displayTimestamp = existingReflection?.timeStamp ?? Date.now
                            Text(displayTimestamp.formatted(.dateTime
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
                        Text((isEditingExistingReflection ? existingReflection?.bibleVerseText : verseText) ?? "")
                            .font(.customBody1)
                            .foregroundStyle(.hearthEmberDark)
                        
                        HStack {
                            Spacer()
                            Text((isEditingExistingReflection ? existingReflection?.title : verseReference) ?? "")
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
                    
                    Button(isEditingExistingReflection ? "Update Reflection" : "Save Reflection") {
                        guard !reflectionViewModel.isSaving, !content.isEmpty else { return }
                        
                        if isEditingExistingReflection, let existingReflection = existingReflection {
                            let updatedReflection = VerseReflectionModel(
                                id: existingReflection.id,
                                userID: existingReflection.userID,
                                title: existingReflection.title,
                                bibleVerseText: existingReflection.bibleVerseText,
                                reflection: content,
                                timeStamp: existingReflection.timeStamp,
                                entryType: .bibleVerseReflection
                            )

                            reflectionViewModel.updateReflection(updatedReflection) { result in
                                switch result {
                                case .success:
                                    isPresented = false
                                case .failure:
                                    showingErrorAlert = true
                                }
                            }
                        } else {
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
        .alert("Error", isPresented: $showingErrorAlert, presenting: reflectionViewModel.errorMessage) { error in
            Button("OK", role: .cancel) { }
        } message: { error in
            Text(error)
        }
    }
}

#Preview {
    @Previewable @State var isPresented = true
    EditAddBibleReflectionView(reflectionViewModel: VerseReflectionViewModel(), verseText: "This is a bible verse. There should be a decent ammount of text here.", verseReference: "Aaron 4:16",isPresented: $isPresented)
}
