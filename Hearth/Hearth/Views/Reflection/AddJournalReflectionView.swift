//
//  AddJournalReflectionView.swift
//  Hearth
//
//  Created by Aaron McKain on 3/22/25.
//
import SwiftUI
import Combine

struct AddJournalReflectionView: View {
    @ObservedObject var reflectionViewModel: ReflectionViewModel
    @ObservedObject private var keyboardResponder = KeyboardResponder()
    
    @Environment(\.dismiss) var dismiss
    
    @State private var content: String
    
    var reflection: JournalReflectionModel
    var isEditing: Bool
    
    init(reflection: JournalReflectionModel, reflectionViewModel: ReflectionViewModel, isEditing: Bool = false) {
        self.reflection = reflection
        _content = State(initialValue: reflection.reflectionContent)
        self.reflectionViewModel = reflectionViewModel
        self.isEditing = isEditing
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.warmSandLight
                    .ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            Text("From: ")
                                .font(.customHeadline1)
                                .foregroundStyle(.parchmentDark)
                            
                            Text(reflection.journalEntry.timestamp.formatted(date: .abbreviated, time: .omitted))
                                .font(.customHeadline1)
                                .foregroundStyle(.hearthEmberMain)
                            Spacer()
                        }
                        
                        CustomDivider(height: 2, color: .hearthEmberMain)
                        

                        VStack(alignment: .leading) {
                            Text(reflection.journalEntry.title)
                                .font(.customHeadline1)
                                .foregroundStyle(.parchmentDark)
                                //.padding(.bottom, 10)
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(.warmSandMain.opacity(0.4))
                                
                                Text("\"\(reflection.journalEntry.content)\"")
                                    .font(.customBody1)
                                    .foregroundStyle(.parchmentDark)
                                    .padding()
                            }
                        }
                        
                        CustomDivider(height: 2, color: .hearthEmberMain)
                        
                        Text("Your Reflection")
                            .font(.customHeadline1)
                            .foregroundStyle(.parchmentDark)
                                  
                        TextEditor(text: $content)
                            .frame(minHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                        
                        let isDisabled = reflectionViewModel.isLoading || content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

                        Button(action: {
                            let updatedReflection = JournalReflectionModel(
                                id: reflection.id,
                                userID: reflection.userID,
                                journalEntry: reflection.journalEntry,
                                reflectionContent: content,
                                reflectionTimestamp: Date(),
                                spireScore: reflection.spireScore
                            )

                            let completion: (Bool) -> Void = { success in
                                if success {
                                    dismiss()
                                } else {
                                    print("Failed to \(isEditing ? "update" : "save") reflection.")
                                }
                            }

                            if isEditing {
                                reflectionViewModel.updateReflection(updatedReflection, completion: completion)
                            } else {
                                reflectionViewModel.saveReflection(updatedReflection, completion: completion)
                            }
                        }) {
                            Text(isEditing ? "Save" : "Save Reflection")
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
                    .padding(.bottom, keyboardResponder.currentHeight)
                }
                .navigationTitle("Add Reflection")
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
    let mockEntry = JournalEntrySnapshot(
        title: "Gratitude in Chaos",
        content: "Today was hectic, but I managed to stay grounded and find peace during a short walk outside. Today was hectic, but I managed to stay grounded and find peace during a short walk outside. Today was hectic, but I managed to stay grounded and find peace during a short walk outside.",
        timestamp: Date()
    )
    
    let mockReflection = JournalReflectionModel(
        id: UUID().uuidString,
        userID: "user123",
        journalEntry: mockEntry,
        reflectionContent: "Reflecting on how I handled the stress, I feel proud of my ability to pause and breathe. I want to continue building that habit.",
        reflectionTimestamp: Date(),
        spireScore: 4.5
    )
    
    return AddJournalReflectionView(reflection: mockReflection)
}
*/

final class KeyboardResponder: ObservableObject {
    @Published var currentHeight: CGFloat = 0
    private var cancellable: AnyCancellable?

    init() {
        cancellable = Publishers.Merge(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
                .compactMap { notification in
                    (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height
                },
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in CGFloat(0) }
        )
        .assign(to: \.currentHeight, on: self)
    }
}
