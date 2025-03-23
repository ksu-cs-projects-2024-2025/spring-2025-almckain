//
//  AddJournalReflectionView.swift
//  Hearth
//
//  Created by Aaron McKain on 3/22/25.
//

import SwiftUI

struct AddJournalReflectionView: View {
    @State private var content: String
    var reflection: JournalReflectionModel
    
    init(reflection: JournalReflectionModel) {
        self.reflection = reflection
        _content = State(initialValue: reflection.reflectionContent)
    }
    
    var body: some View {
        ZStack {
            Color.warmSandLight
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Text("From \(reflection.journalEntry.timestamp.formatted(date: .abbreviated, time: .omitted))")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.parchmentDark)
                        Spacer()
                    }
                    //CustomDivider(height: 2, color: .hearthEmberMain)
                    
                    VStack {
                        Text(reflection.journalEntry.title)
                            .multilineTextAlignment(.center)
                            .font(.customHeadline1)
                            .padding(.bottom, 10)
                        
                        Text(reflection.journalEntry.content)
                            .font(.customBody1)
                            .foregroundStyle(.parchmentDark)
                    }
                    
                    CustomDivider(height: 2, color: .hearthEmberMain)
                    
                    TextEditor(text: $content)
                        .frame(minHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    
                    Button("Save Reflection") {
                        // TODO: - Save Logic here
                    }
                    .padding()
                    .frame(width: 200)
                    .background(Color.hearthEmberLight)
                    .foregroundColor(.parchmentLight)
                    .font(.headline)
                    .cornerRadius(15)
                    
                    Spacer()
                }
            }
        }
    }
}
/*
#Preview {
    AddJournalReflectionView()
}
*/
