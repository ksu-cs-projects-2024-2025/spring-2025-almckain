//
//  WeekdayRectangle.swift
//  Hearth
//
//  Created by Aaron McKain on 3/31/25.
//

import SwiftUI

struct WeekdayRectangle: View {
    let dayString: String
    let isToday: Bool
    let hasEntry: Bool
    
    var body: some View {
        if isToday {
            VStack(spacing: 0) {
                ZStack {
                    if hasEntry {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 45, height: 47)
                            .foregroundStyle(.hearthEmberMain)
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.hearthEmberMain, lineWidth: 4)
                            .frame(width: 45, height: 47)
                    }
                    
                    Text(dayString)
                        .font(.customTitle1)
                        .foregroundStyle(hasEntry ? .parchmentLight : .hearthEmberMain)
                }
                
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 45, height: 10)
                    .foregroundStyle(.hearthEmberMain)
                    .offset(y: 3)
            }
        } else {
            ZStack {
                if hasEntry {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 45, height: 60)
                        .foregroundStyle(.hearthEmberMain)
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.hearthEmberMain, lineWidth: 4)
                        .frame(width: 45, height: 60)
                }
                
                Text(dayString)
                    .font(.customTitle1)
                    .foregroundStyle(hasEntry ? .parchmentLight : .hearthEmberMain)
            }
        }
    }
}

/*
#Preview {
    WeekdayRectangle()
}
*/
