//
//  DayCellView.swift
//  Hearth
//
//  Created by Aaron McKain on 4/10/25.
//

import SwiftUI

struct DayCellView: View {
    let day: Date
    let isToday: Bool
    let isFutureDay: Bool
    let hasActivity: Bool
    let hasPrayer: Bool
    
    var body: some View {
        ZStack {
            if isToday {
                if hasActivity {
                    Circle().foregroundStyle(Color.hearthEmberMain)
                } else {
                    Circle().stroke(Color.hearthEmberDark, lineWidth: 3)
                }
            } else {
                if hasActivity {
                    Circle().foregroundStyle(Color.hearthEmberLight)
                } else {
                    Circle().stroke(Color.hearthEmberLight, lineWidth: 3)
                }
            }
            
            Text(day.formatted(.dateTime.day()))
                .fontWeight(.bold)
                .foregroundColor(hasActivity ? Color.parchmentLight : Color.parchmentDark)
                .opacity(isFutureDay ? 0.4 : 1.0)
            
            if hasPrayer {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "bell.fill")
                            .font(.caption)
                            .foregroundColor(Color.yellow)
                            .padding(6)
                            .background(Circle().fill(Color.warmSandLight))
                            .offset(x: 13, y: -13)
                    }
                    Spacer()
                }
                .padding(4)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 40)
    }
}

/*
#Preview {
    DayCellView()
}
*/
