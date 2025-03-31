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
    @Binding var isEditingPresented: Bool
    @FocusState private var textBoxIsFocused: Bool
    @Environment(\.dismiss) var dismiss
    
    var existingReflection: VerseReflectionModel?
    private var isEditingExistingReflection: Bool {
        existingReflection?.id != nil
    }
    
    init(reflectionViewModel: VerseReflectionViewModel, existingReflection: VerseReflectionModel? = nil, verseText: String, verseReference: String, isEditingPresented: Binding<Bool>) {
        self.reflectionViewModel = reflectionViewModel
        self.existingReflection = existingReflection
        self.verseText = verseText
        self.verseReference = verseReference
        self._isEditingPresented = isEditingPresented
        
        _content = State(initialValue: existingReflection?.reflection ?? "")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.warmSandLight
                    .ignoresSafeArea()
                ScrollView {
                    VStack {
                        VStack {
                            HStack {
                                let displayTimestamp = existingReflection?.timeStamp ?? Date.now
                                (
                                    Text(isEditingExistingReflection ? "From: " : "Date: ")
                                        .font(.customHeadline1)
                                        .foregroundStyle(.parchmentDark) +
                                    Text(displayTimestamp.formatted(.dateTime
                                        .month(.abbreviated)
                                        .day(.defaultDigits)
                                        .year()
                                        .hour(.twoDigits(amPM: .abbreviated))
                                        .minute()
                                    ))
                                    .font(.customHeadline1)
                                    .foregroundStyle(.hearthEmberDark)
                                )
                                
                                Spacer()
                            }
                        }
                        
                        
                        CustomDivider(height: 2, color: .hearthEmberMain)
                        
                        VStack {
                            Text((isEditingExistingReflection ? existingReflection?.bibleVerseText : verseText) ?? "")
                                .font(.customBody1)
                                .foregroundStyle(.parchmentDark)
                                .multilineTextAlignment(.center)
                                .italic()
                            
                            
                            HStack {
                                Spacer()
                                Text((isEditingExistingReflection ? existingReflection?.title : verseReference) ?? "")
                                    .foregroundStyle(.parchmentDark)
                                    .font(.customBody1)
                            }
                        }
                        .padding(.vertical)
                        
                        CustomDivider(height: 2, color: .hearthEmberMain)
                        
                        TextEditor(text: $content)
                            .frame(minHeight: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .padding(.vertical)
                            .focused($textBoxIsFocused)
                        
                        let isDisabled = reflectionViewModel.isSaving || content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        
                        Button(action: {
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
                                        DispatchQueue.main.async {
                                            isEditingPresented = false
                                            reflectionViewModel.fetchReflections(for: updatedReflection.timeStamp)
                                        }
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
                                        isEditingPresented = false
                                    case .failure:
                                        showingErrorAlert = true
                                    }
                                }
                            }
                        }) {
                            Text(isEditingExistingReflection ? "Update Reflection" : "Save Reflection")
                                .frame(width: 200)
                                .padding()
                                .background(isDisabled ? Color.parchmentDark.opacity(0.3) : Color.hearthEmberMain)
                                .foregroundColor(.parchmentLight)
                                .font(.headline)
                                .cornerRadius(15)
                        }
                        .disabled(isDisabled)                        
                        
                        Spacer()
                    }
                    .padding(.bottom)
                }
                .navigationTitle(isEditingExistingReflection ? "Edit Reflection" : "New Reflection")
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
    EditAddBibleReflectionView(
        reflectionViewModel: VerseReflectionViewModel(),
        verseText: "This is a bible verse. There should be a decent amount of text here.",
        verseReference: "Aaron 4:16",
        isEditingPresented: .constant(true)
    )
}

