//
//  GratitudeCalendarCardView.swift
//  Hearth
//
//  Created by Aaron McKain on 4/19/25.
//

import SwiftUI

struct GratitudeCalendarCardView: View {
    @ObservedObject var gratitudeViewModel: GratitudeViewModel
    
    @State private var showSheet: Bool = false
    
    let entry: GratitudeModel
    
    var body: some View {
        CustomCalendarCardView {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Gratitude Prompt")
                        .font(.customHeadline2)
                        .foregroundStyle(.hearthEmberMain)
                    Text("•")
                    Text(entry.timeStamp.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute()))
                        .font(.customCaption1)
                        .foregroundStyle(.parchmentDark.opacity(0.6))
                }
                
                CustomDivider(height: 2, color: .hearthEmberDark)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundStyle(.parchmentLight)
                    
                    Text(entry.prompt)
                        .font(.customBody1)
                        .foregroundStyle(.parchmentDark)
                        .padding(10)
                }
                
                Text(entry.content)
                    .font(.customBody2)
                    .foregroundStyle(.parchmentDark)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
            }
        }
        .onTapGesture {
            showSheet = true
        }
        .customSheet(isPresented: $showSheet) {
            DetailedGratitudeView(gratitudeViewModel: gratitudeViewModel, entry: entry)
        }
        .presentationDetents([.fraction(0.95)])
    }
}

/*
 #Preview {
 GratitudeCalendarCardView()
 }
 */
