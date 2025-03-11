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
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(.warmSandLight)
                .shadow(color: Color.parchmentDark.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal, 10)
            
            VStack(alignment: .leading) {
                Text("Today's Bible Verse")
                    .font(.title2)
                    .foregroundStyle(.hearthEmberDark)
                Divider()
                    .foregroundStyle(.hearthEmberDark)
                
                if let verse = viewModel.bibleVerse {
                    
                    Text(verse.text)
                        .font(.customBody1)
                        .foregroundStyle(.hearthEmberDark)
                    
                    HStack {
                        Spacer()
                        
                        Text(verse.reference)
                            .padding()
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
                            .foregroundStyle(.hearthEmberDark)
                    }
                    
                    Text(reflectionViewModel.reflectionText.isEmpty ? "Add Reflection" : "View Reflection")
                        .font(.customButton)
                        .foregroundStyle(.hearthEmberDark)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    isSheetPresented = true
                }
                
            }
            .padding(30)
        }
        .sheet(isPresented: $isSheetPresented) {
            ZStack {
                Color.warmSandLight
                    .ignoresSafeArea()
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "x.circle.fill")
                            .padding(.top)
                            .padding(.trailing, 20)
                            .foregroundStyle(.parchmentDark.opacity(0.6))
                            .font(.customTitle2)
                            .onTapGesture {
                                isSheetPresented.toggle()
                            }
                    }
                    
                    if reflectionViewModel.reflectionText.isEmpty {
                        EditAddBibleReflectionView(
                                        reflectionViewModel: reflectionViewModel,
                                        verseText: viewModel.bibleVerse?.text ?? "",
                                        verseReference: viewModel.bibleVerse?.reference ?? "",
                                        isPresented: $isSheetPresented
                                    )
                            .padding()
                    } else {
                        if let reflection = reflectionViewModel.reflection {  // ✅ Ensure reflection exists
                            DetailedBVReflectionView(
                                reflectionEntry: reflection,  // ✅ Use reflectionViewModel.reflection
                                reflectionViewModel: reflectionViewModel,
                                isPresented: $isSheetPresented
                            )
                            .padding()
                        }
                    }
                }
            }
            .presentationDetents([.fraction(0.95)])
        }
    }
}

/*
 #Preview {
 BibleVerseCardView(viewModel: BibleVerseViewModel(), reflectionViewModel: VerseReflectionViewModel())
 }
 */
