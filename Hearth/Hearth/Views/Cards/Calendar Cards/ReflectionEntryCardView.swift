//
//  ReflectionEntryCardView.swift
//  Hearth
//
//  Created by Aaron McKain on 3/10/25.
//

import SwiftUI

struct ReflectionEntryCardView: View {
    let reflectionEntry: VerseReflectionModel
    @ObservedObject var reflectionViewModel: VerseReflectionViewModel
    @State private var isSheetPresented = false
    var selectedDate: Date
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(.warmSandLight)
                .shadow(color: Color.parchmentDark.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal, 10)
            HStack {
                HStack {
                    LeftRoundedRectangle(cornerRadius: 12)
                        .fill(Color.hearthEmberMain)
                        .frame(width: 10)
                        .padding(.horizontal, 10)
                }
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Bible Verse Reflection")
                            .font(.customHeadline2)
                            .foregroundStyle(.hearthEmberMain)
                        Text("•")
                        Text(reflectionEntry.timeStamp.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute()))
                            .font(.customCaption1)
                            .foregroundStyle(.parchmentDark.opacity(0.6))
                    }
                    
                    CustomDivider(height: 2, color: .hearthEmberDark)
                    
                    Text("\(reflectionEntry.bibleVerseText.replacingOccurrences(of: "\n", with: " "))")
                        .font(.customHeadline2)
                        .italic()
                        .foregroundStyle(.parchmentDark)
                        .padding(.trailing, 20)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    
                    Text(reflectionEntry.reflection)
                        .font(.customBody2)
                        .padding(.trailing, 20)
                        .lineLimit(2)
                        .truncationMode(.tail)
                    
                }
                .padding(.vertical, 15)
                Spacer()
            }
        }
        .onTapGesture {
            isSheetPresented = true
        }
        .customSheet(isPresented: $isSheetPresented) {
            DetailedBVReflectionView(
                reflectionEntry: reflectionEntry,
                selectedDate: selectedDate,
                reflectionViewModel: reflectionViewModel,
                isPresented: $isSheetPresented
            )
        }
        .presentationDetents([.fraction(0.95)])
    }
}

/*
 #Preview {
 ReflectionEntryCardView()
 }
 */
