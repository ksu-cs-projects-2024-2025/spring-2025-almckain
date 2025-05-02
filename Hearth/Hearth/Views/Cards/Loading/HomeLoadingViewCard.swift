//
//  HomeLoadingViewCard.swift
//  Hearth
//
//  Created by Aaron McKain on 5/1/25.
//

import SwiftUI

struct HomeLoadingViewCard: View {
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                // Title shimmer
                HStack {
                    SkeletonView(.rect(cornerRadius: 24))
                        .frame(width: 200, height: 40)
                    
                    Spacer()
                    
                    SkeletonView(.rect(cornerRadius: 24))
                        .frame(width: 80, height: 40)
                }
                
                CustomDivider(height: 2, color: Color.gray.opacity(0.3))
                
                // Main content block shimmers
                VStack(spacing: 10) {
                    SkeletonView(.rect(cornerRadius: 4))
                        .frame(height: 50)
                        .cornerRadius(12)
                    
                    SkeletonView(.rect(cornerRadius: 4))
                        .frame(height: 20)
                        .cornerRadius(12)
                    
                    SkeletonView(.rect(cornerRadius: 4))
                        .frame(height: 20)
                        .cornerRadius(12)
                }
                
                // Button shimmer
                SkeletonView(.rect(cornerRadius: 48))
                    .frame(height: 50)
                    .padding(.top, 10)
            }
        }
    }
}

#Preview {
    HomeLoadingViewCard()
}
