//
//  JournalCardView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/13/25.
//

import SwiftUI

struct JournalEntryCardView: View {
    let journalEntry: JournalEntryModel
    
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
                        Text("Journal Entry")
                            .font(.customHeadline2)
                            .foregroundStyle(.hearthEmberMain)
                        Text("•")
                            .padding(.leading, 10)
                        Text(journalEntry.timeStamp.formatted(.dateTime.month(.abbreviated).day().year()))
                            .font(.customCaption1)
                            .foregroundStyle(.parchmentDark.opacity(0.6))
                    }
                    
                    Rectangle()
                        .fill(Color.hearthEmberDark)
                        .frame(height: 2)
                        .padding(.trailing, 20)
                    
                    Text(journalEntry.title)
                        .font(.customHeadline2)
                        .foregroundStyle(.parchmentDark)
                        .padding(.trailing, 20)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Text(journalEntry.content)
                        .font(.customBody2)
                        .padding(.trailing, 20)
                        .lineLimit(2)
                        .truncationMode(.tail)
                }
                .padding(.vertical, 20)
                Spacer()
            }
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    let sample = JournalEntryModel(id: nil, userID: "1234", title: "The end of my college career bannana bannana", content: "So I never got more pumpkin bread. I then proceeded to trip in front of the chickfila girl so im pretty much forced to transfer schools now. This is shaping up to be a low light for this semester.", timeStamp: Date.now, entryType: .journal)
    JournalEntryCardView(journalEntry: sample)
}
