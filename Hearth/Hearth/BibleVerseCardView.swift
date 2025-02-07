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
                .foregroundStyle(.thinMaterial)
                .shadow(radius: 5, x: 0, y: 2)
                .padding(.horizontal, 10)
            
            VStack(alignment: .leading) {
                Text("Today's Bible Verse")
                    .font(.title2)
                Divider()
                Text("Here is a bible verse. It has meaning. The meaning is good and the user might feel like reflecting on it.")
                HStack {
                    Spacer()
                    Text("Aaron 4:16")
                }
            }
            .padding(30)
        }
    }
}

#Preview {
    BibleVerseCardView()
}
