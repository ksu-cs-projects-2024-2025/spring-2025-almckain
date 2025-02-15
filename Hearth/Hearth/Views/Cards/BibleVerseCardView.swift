//
//  BibleVerseCardView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/6/25.
//

import SwiftUI

struct BibleVerseCardView: View {
    @ObservedObject var viewModel: BibleVerseViewModel
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
                    Image(systemName: "square.and.arrow.up")
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.hearthEmberDark)
                    
                    /// TODO: If the user has entered a reflection for the bible verse change text to "View Reflection"
                    Text("Add Reflection")
                        .font(.customButton)
                        .foregroundStyle(.hearthEmberDark)
                    Spacer()
                }
                
            }
            .padding(30)
        }
    }
}

#Preview {
    BibleVerseCardView(viewModel: BibleVerseViewModel())
}
