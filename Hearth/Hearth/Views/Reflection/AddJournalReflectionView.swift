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
    
    init(reflection: JournalReflectionModel, reflectionViewModel: ReflectionViewModel) {
        self.reflection = reflection
        _content = State(initialValue: reflection.reflectionContent)
        self.reflectionViewModel = reflectionViewModel
    }
    
    var body: some View {
        NavigationView {
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
                        
                        Button("Save Reflection") {
                            let updatedReflection = JournalReflectionModel(
                                id: reflection.id,
                                userID: reflection.userID,
                                journalEntry: reflection.journalEntry,
                                reflectionContent: content,
                                reflectionTimestamp: Date(),
                                spireScore: reflection.spireScore
                            )
                            
                            reflectionViewModel.saveReflection(updatedReflection) { success in
                                if success {
                                    dismiss()
                                } else {
                                    print("Failed to save reflection.")
                                }
                            }
                        }
                        .padding()
                        .frame(width: 200)
                        .background(Color.hearthEmberMain)
                        .foregroundColor(.parchmentLight)
                        .font(.headline)
                        .cornerRadius(15)
                        
                        Spacer()
                    }
                    .padding(.bottom, keyboardResponder.currentHeight)
                }
                .navigationTitle("Add Reflection")
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
