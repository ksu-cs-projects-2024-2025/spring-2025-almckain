//
//  PrayerReminderCardView.swift
//  Hearth
//
//  Created by Aaron McKain on 4/1/25.
//

import SwiftUI

struct PrayerReminderCardView: View {
    var body: some View {
        CardView {
            VStack(spacing: 12) {
                HStack {
                    Text("Today")
                        .font(.customTitle3)
                        .foregroundStyle(.hearthEmberMain)
                    
                    Text("•  2 Prayers Left")
                        .font(.customBody1)
                        .foregroundStyle(.parchmentDark.opacity(0.6))
                        .padding(.leading, 10)
                    
                    Spacer()
                    
                    Image(systemName: "plus.circle")
                        .font(.title2)
                        .foregroundStyle(.hearthEmberMain)
                }
                CustomDivider(height: 2, color: .hearthEmberMain)
                
                LazyVStack(spacing: 12) {
                    PrayerView()
                    PrayerView()
                }
            }
        }
    }
}

struct PrayerView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .frame(width: .infinity, height: 43)
                .foregroundStyle(.parchmentLight)
            
            HStack {
                Circle()
                    .stroke(Color.hearthEmberMain, lineWidth: 2)
                    .frame(width: 24, height: 24)
                
                Text("Prayer for piece between the campus ...")
            }
        }
    }
}

#Preview {
    PrayerReminderCardView()
}
