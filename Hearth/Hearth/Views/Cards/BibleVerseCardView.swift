//
//  BibleVerseCardView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/6/25.
//

import SwiftUI

struct BibleVerseCardView: View {
    @ObservedObject var viewModel: BibleVerseViewModel
    @ObservedObject var reflectionViewModel: VerseReflectionViewModel
    
    @State private var isSheetPresented = false
    
    var body: some View {
        CardView{
            VStack {
                Text("Today's Bible Verse")
                    .font(.customTitle3)
                    .foregroundStyle(.hearthEmberMain)
                
                CustomDivider(height: 2, color: .hearthEmberMain)
                
                if let verse = viewModel.bibleVerse {
                    
                    Text(verse.text.trimmingCharacters(in: .whitespacesAndNewlines))
                        .font(.customBody1)
                        .foregroundStyle(.parchmentDark)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 5)
                        .italic()
                    
                    HStack {
                        Spacer()
                        
                        Text(verse.reference)
                            .font(.customBody1)
                            .foregroundStyle(.parchmentDark)
                            .padding(.bottom,5)
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundStyle(.hearthError)
                        .font(.customCaption1)
                }
                
                
                
                HStack {
                    Spacer()
                    if reflectionViewModel.reflectionText.isEmpty {
                        Image(systemName: "square.and.arrow.up")
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.hearthEmberMain)
                    }
                    
                    Text(reflectionViewModel.reflectionText.isEmpty ? "Add Reflection" : "View Reflection")
                        .font(.customButton)
                        .foregroundStyle(.hearthEmberMain)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    isSheetPresented = true
                }
                
            }
        }
        .customSheet(isPresented: $isSheetPresented) {
            if reflectionViewModel.reflectionText.isEmpty {
                EditAddBibleReflectionView(
                    reflectionViewModel: reflectionViewModel,
                    verseText: viewModel.bibleVerse?.text ?? "",
                    verseReference: viewModel.bibleVerse?.reference ?? "",
                    isEditingPresented: $isSheetPresented
                )
            } else {
                if let reflection = reflectionViewModel.reflection {
                    DetailedBVReflectionView(
                        reflectionEntry: reflection,
                        reflectionViewModel: reflectionViewModel,
                        isPresented: $isSheetPresented
                    )
                }
            }
        }
        .presentationDetents([.fraction(0.95)])
        .onAppear {
            if let verse = viewModel.bibleVerse {
                print("A Bible verse exists.")
            }
        }
    }
}

/*
 #Preview {
 BibleVerseCardView(viewModel: BibleVerseViewModel(), reflectionViewModel: VerseReflectionViewModel())
 }
 */
