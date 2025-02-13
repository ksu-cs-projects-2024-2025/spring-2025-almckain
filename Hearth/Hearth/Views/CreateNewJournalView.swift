//
//  CreateNewJournalView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/12/25.
//

import SwiftUI

struct CreateNewJournalView: View {
    @State private var title: String = ""
    @State private var content: String = ""
    @Binding var isPresenting: Bool
    
    var viewModel: JournalEntryViewModel
    
    var body: some View {
        NavigationStack {
            ZStack{
                Color.warmSandLight
                    .ignoresSafeArea()
                VStack {
                    HStack {
                        Text("New Journal Entry")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.parchmentDark)
                        Spacer()
                    }
                    
                    ScrollView {
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
                        TextField("Title", text: $title)
                            .padding()
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 15))

                        TextEditor(text: $content)
                            .frame(minHeight: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .padding(.vertical)


                        Button("Add to Journal") {
                            viewModel.addJournalEntry(title: title, content: content)
                            isPresenting = false
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
                .padding()
            }
        }
    }
        
}

#Preview {
    @Previewable @State var isPresented = true
    CreateNewJournalView(isPresenting: $isPresented, viewModel: JournalEntryViewModel())
}

