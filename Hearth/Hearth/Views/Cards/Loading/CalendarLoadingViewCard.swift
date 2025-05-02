//
//  CalendarLoadingViewCard.swift
//  Hearth
//
//  Created by Aaron McKain on 5/1/25.
//

import SwiftUI

struct CalendarLoadingViewCard: View {
    
    @State private var days: [Date] = []
    @State private var date = Date.now
    let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                // Title shimmer
                HStack {
                    SkeletonView(.rect(cornerRadius: 24))
                        .frame(width: 80, height: 40)
                    
                    Spacer()
                    
                    SkeletonView(.rect(cornerRadius: 24))
                        .frame(width: 120, height: 40)
                }
                
                SkeletonView(.rect(cornerRadius: 4))
                    .frame(height: 20)
                    .cornerRadius(12)
                
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(days, id: \.self) { day in
                        if day.monthInt != date.monthInt {
                            // Empty cell to maintain grid alignment
                            Color.clear
                                .frame(height: 40)
                        } else {
                            // Skeleton placeholder for day cell
                            SkeletonView(.circle)
                                .frame(width: 40, height: 40)
                                .padding(2)
                        }
                    }
                }
            }
        }
        .onAppear {
            days = date.calendarDisplayDays
        }
        .onChange(of: date) { _, newValue in
            days = newValue.calendarDisplayDays
        }
    }
}

#Preview {
    CalendarLoadingViewCard()
}
