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
                    Text("Gratitude Entry")
                        .font(.customHeadline2)
                        .foregroundStyle(.hearthEmberMain)
                    Text("•")
                    Text(entry.timeStamp.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute()))
                        .font(.customCaption1)
                        .foregroundStyle(.parchmentDark.opacity(0.6))
                }
                
                CustomDivider(height: 2, color: .hearthEmberDark)
                
                VStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.parchmentLight)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Prompt:")
                                .font(.customBody2)
                                .foregroundStyle(.parchmentDark.opacity(0.8))
                                .padding(.horizontal)
                                .padding(.top, 8)
                            
                            Text(entry.prompt)
                                .font(.customBody1)
                                .foregroundStyle(.parchmentDark)
                                .padding(.horizontal)
                                .padding(.bottom, 8)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.white)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Your Response:")
                                .font(.customBody2)
                                .foregroundStyle(.parchmentDark.opacity(0.8))
                                .padding(.horizontal)
                                .padding(.top, 8)
                            
                            Text(entry.content)
                                .font(.customBody1)
                                .foregroundStyle(.parchmentDark)
                                .lineLimit(3)
                                .padding(.horizontal)
                                .padding(.bottom, 8)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
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
