//
//  PrayerReminderLoadingCard.swift
//  Hearth
//
//  Created by Aaron McKain on 5/1/25.
//

import SwiftUI

struct PrayerReminderLoadingCard: View {
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                // Title shimmer
                HStack {
                    SkeletonView(.rect(cornerRadius: 24))
                        .frame(width: 70, height: 30)
                    
                    SkeletonView(.rect(cornerRadius: 24))
                        .frame(width: 100, height: 30)
                    
                    Spacer()
                    
                    SkeletonView(.circle)
                        //.frame(width: 80, height: 30)
                        .frame(width: 40)
                }
                
                CustomDivider(height: 2, color: Color.gray.opacity(0.3))
                
                // Main content block shimmers
                VStack(spacing: 10) {
                    SkeletonView(.rect(cornerRadius: 40))
                        .frame(height: 45)
                    
                    SkeletonView(.rect(cornerRadius: 40))
                        .frame(height: 45)
                }
            }
        }
    }
}

#Preview {
    PrayerReminderLoadingCard()
}
