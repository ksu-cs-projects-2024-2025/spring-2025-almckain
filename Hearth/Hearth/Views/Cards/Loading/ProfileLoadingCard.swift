//
//  ProfileLoadingCard.swift
//  Hearth
//
//  Created by Aaron McKain on 5/1/25.
//

import SwiftUI

enum ProfileLoadingType {
    case name
    case stats
    case notification
}

struct ProfileLoadingCard: View {
    var type: ProfileLoadingType
    
    var body: some View {
        CardView {
            if type == .name {
                VStack(alignment: .center, spacing: 12) {
                    // Title shimmer
                    VStack {
                        SkeletonView(.rect(cornerRadius: 24))
                            .frame(width: 250, height: 60)
                                
                        SkeletonView(.rect(cornerRadius: 24))
                            .frame(width: 120, height: 20)
                    }
                }
            } else if type == .stats {
                CardView {
                    VStack(spacing: 12) {
                        // Title shimmer
                        HStack {
                            SkeletonView(.rect(cornerRadius: 24))
                                .frame(width: 100, height: 40)
                            
                            Spacer()
                        }
                        
                        CustomDivider(height: 2, color: Color.gray.opacity(0.3))
                        
                        Grid(horizontalSpacing: 40, verticalSpacing: 30) {
                            // Row 1
                            GridRow {
                                // Column 1: Journal Entries
                                VStack {
                                    SkeletonView(RoundedRectangle(cornerRadius: 10))
                                        .frame(width: 60, height: 60)
                                }
                                
                                // Column 2: Bible Verse Reflections
                                VStack {
                                    SkeletonView(RoundedRectangle(cornerRadius: 10))
                                        .frame(width: 60, height: 60)
                                }
                                
                                // Column 3: Prayer Reminders
                                VStack {
                                    SkeletonView(RoundedRectangle(cornerRadius: 10))
                                        .frame(width: 60, height: 60)
                                }
                            }
                            
                            // Row 2
                            GridRow {
                                // Column 1: Gratitude Statements
                                VStack {
                                    SkeletonView(RoundedRectangle(cornerRadius: 10))
                                        .frame(width: 60, height: 60)
                                }
                                
                                // Column 2: Self Reflections
                                VStack {
                                    SkeletonView(RoundedRectangle(cornerRadius: 10))
                                        .frame(width: 60, height: 60)
                                }
                                
                                // Column 3: Longest Streak
                                VStack {
                                    SkeletonView(RoundedRectangle(cornerRadius: 10))
                                        .frame(width: 60, height: 60)
                                }
                            }
                        }
                    }
                }
            } else if type == .notification {
                CardView {
                    VStack(spacing: 12) {
                        // Title shimmer
                        HStack {
                            SkeletonView(.rect(cornerRadius: 24))
                                .frame(width: 200, height: 40)
                            
                            Spacer()

                        }
                        
                        CustomDivider(height: 2, color: Color.gray.opacity(0.3))
                        
                        // Main content block shimmers
                        VStack(spacing: 10) {
                            HStack {
                                SkeletonView(Circle())
                                    .frame(width: 40, height: 40)
                                SkeletonView(.rect(cornerRadius: 40))
                                    .frame(height: 40)
                            }
                            
                            HStack {
                                SkeletonView(Circle())
                                    .frame(width: 40, height: 40)
                                SkeletonView(.rect(cornerRadius: 40))
                                    .frame(height: 40)
                            }
                            
                            HStack {
                                SkeletonView(Circle())
                                    .frame(width: 40, height: 40)
                                SkeletonView(.rect(cornerRadius: 40))
                                    .frame(height: 40)
                            }

                        }
                        
                        // Button shimmer
                        SkeletonView(.rect(cornerRadius: 48))
                            .frame(height: 50)
                            .padding(.top, 10)
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileLoadingCard(type: .name)
    ProfileLoadingCard(type: .stats)
    ProfileLoadingCard(type: .notification)
}
