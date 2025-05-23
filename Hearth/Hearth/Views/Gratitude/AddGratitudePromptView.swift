//
//  AddGratitudePromptView.swift
//  Hearth
//
//  Created by Aaron McKain on 4/18/25.
//

import SwiftUI

struct AddGratitudePromptView: View {
    @ObservedObject var gratitudeViewModel: GratitudeViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @State private var content: String
    @State private var selectedPrompt: String
    
    var entry: GratitudeModel
    var isEditing: Bool
    var showPromptSelector: Bool = false
    
    init(gratitudeViewModel: GratitudeViewModel, entry: GratitudeModel, isEditing: Bool, showPromptSelector: Bool = false) {
        self.gratitudeViewModel = gratitudeViewModel
        self.entry = entry
        self.isEditing = isEditing
        self.showPromptSelector = showPromptSelector
        _content = State(initialValue: entry.content)
        let initialPrompt = entry.prompt.isEmpty ? gratitudeViewModel.todaysPrompts.first ?? "" : entry.prompt
        _selectedPrompt = State(initialValue: initialPrompt)
    }
    
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
                        
                        if showPromptSelector {
                            PromptSelectorView(gratitudeViewModel: gratitudeViewModel, selectedPrompt: $selectedPrompt)
                        } else {
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
                        }
                        
                        CustomDivider(height: 2, color: .hearthEmberMain)
                        
                        Text("Your Response")
                            .font(.customHeadline1)
                            .foregroundStyle(.parchmentDark)
                        
                        TextEditor(text: $content)
                            .frame(minHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                        
                        let isDisabled = content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        
                        Button(action: {
                            let updatedEntry = GratitudeModel(
                                id: entry.id,
                                userID: entry.userID,
                                timeStamp: entry.timeStamp,
                                prompt: showPromptSelector ? selectedPrompt : entry.prompt,
                                content: content
                            )
                            
                            let completion: (Bool) -> Void = { success in
                                if success {
                                    gratitudeViewModel.fetchEntries(forMonth: Date())
                                    dismiss()
                                } else {
                                    print("ERROR: Failed to \(isEditing ? "update" : "save") gratitude entry.")
                                }
                            }
                            
                            if isEditing {
                                gratitudeViewModel.updateGratitude(updatedEntry, completion: completion)
                            } else {
                                gratitudeViewModel.saveEntry(prompt: updatedEntry.prompt, content: content, completion: completion)
                            }
                        }) {
                            Text(isEditing ? "Save" : "Save Gratitude")
                                .frame(width: 200)
                                .padding()
                                .background(isDisabled ? Color.parchmentDark.opacity(0.3) : Color.hearthEmberMain)
                                .foregroundColor(.parchmentLight)
                                .font(.headline)
                                .cornerRadius(15)
                        }
                        .disabled(isDisabled)
                    }
                }
                .navigationTitle(isEditing ? "Edit Gratitude" : "Add Gratitude")
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
            }
        }
    }
}

/*
 #Preview {
 AddGratitudePromptView()
 }
 */
