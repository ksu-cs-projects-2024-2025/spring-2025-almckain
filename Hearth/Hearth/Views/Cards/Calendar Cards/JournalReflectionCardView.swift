//
//  JournalReflectionCardView.swift
//  Hearth
//
//  Created by Aaron McKain on 3/26/25.
//

import SwiftUI

struct JournalReflectionCardView: View {
    let reflection: JournalReflectionModel
    @State private var showDetailedReflection = false
    @ObservedObject var reflectionViewModel: ReflectionViewModel

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(.warmSandLight)
                .shadow(color: Color.parchmentDark.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal, 10)
            
            HStack {
                LeftRoundedRectangle(cornerRadius: 12)
                    .fill(Color.hearthEmberMain)
                    .frame(width: 10)
                    .padding(.horizontal, 10)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Self Reflection")
                            .font(.customHeadline2)
                            .foregroundStyle(.hearthEmberMain)
                        Text("•")
                        Text(reflection.reflectionTimestamp.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute()))
                            .font(.customCaption1)
                            .foregroundStyle(.parchmentDark.opacity(0.6))
                    }
                    
                    CustomDivider(height: 2, color: .hearthEmberDark)
                    
                    Text(reflection.reflectionContent)
                        .font(.customBody2)
                        .padding(.trailing, 20)
                        .lineLimit(3)
                        .truncationMode(.tail)
                }
                .padding(.vertical, 15)
                Spacer()
            }
        }
        .onTapGesture {
            showDetailedReflection = true
        }
        .customSheet(isPresented: $showDetailedReflection) {
            DetailedEntryReflectionView(reflectionViewModel: reflectionViewModel, reflection: reflection)
        }
        .presentationDetents([.fraction(0.95)])
    }
}

/*
#Preview {
    JournalReflectionCardView()
}
*/
