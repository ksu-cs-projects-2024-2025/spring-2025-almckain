//
//  EditAddBibleReflectionView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/27/25.
//

import SwiftUI

struct EditAddBibleReflectionView: View {
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
                        Text("Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God. And the peace of God, which transcends all understanding, will guard your hearts and your minds in Christ Jesus.")
                            .font(.customBody1)
                            .foregroundStyle(.hearthEmberDark)
                        
                        HStack {
                            Spacer()
                            Text("Philippians 4:6-7")
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
                        //viewModel.addJournalEntry(title: title, content: content)
                        isPresented = false
                    }
                    .padding()
                    .frame(width: 200)
                    .background(Color.hearthEmberLight)
                    .foregroundColor(.parchmentLight)
                    .font(.headline)
                    .cornerRadius(15)
                    
                    Spacer()
                }
                .padding(.bottom)
            }
        }
        .onTapGesture {
            textBoxIsFocused = false
        }
    }
}

#Preview {
    @Previewable @State var isPresented = true
    EditAddBibleReflectionView(isPresented: $isPresented)
}
