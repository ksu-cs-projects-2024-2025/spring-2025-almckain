//
//  BibleVerseCardView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/6/25.
//

import SwiftUI

struct BibleVerseCardView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(.warmSandLight)
                .shadow(radius: 5, x: 0, y: 2)
                .padding(.horizontal, 10)
            
            VStack(alignment: .leading) {
                Text("Today's Bible Verse")
                    .font(.title2)
                    .foregroundStyle(.hearthEmberDark)
                Divider()
                    .foregroundStyle(.hearthEmberDark)
                Text("Here is a bible verse. It has meaning. The meaning is good and the user might feel like reflecting on it.")
                    .font(.customBody1)
                    .foregroundStyle(.hearthEmberDark)
                HStack {
                    Spacer()
                    Text("Aaron 4:16")
                        .padding()
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
    BibleVerseCardView()
}
