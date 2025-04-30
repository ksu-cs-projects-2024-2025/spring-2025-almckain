//
//  UserStatsCard.swift
//  Hearth
//
//  Created by Aaron McKain on 4/16/25.
//

import SwiftUI

struct UserStatsCard: View {
    
    @ObservedObject var profileViewModel: ProfileViewModel
    
    var body: some View {
        CardView {
            VStack(spacing: 10) {
                HStack {
                    Text("Stats")
                        .font(.customTitle3)
                        .foregroundStyle(.hearthEmberMain)
                    Spacer()
                }
                
                CustomDivider(height: 2, color: .hearthEmberDark)
                
                Grid(horizontalSpacing: 40, verticalSpacing: 30) {
                    // Row 1
                    GridRow {
                        // Column 1: Journal Entries
                        VStack {
                            Text("Journal\nEntries")
                                .font(.customBody1)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.parchmentDark)
                            Text("\(profileViewModel.stats["journalEntryCount"] ?? 0)")
                                .font(.customFootnote)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.parchmentDark)
                        }
                        
                        // Column 2: Bible Verse Reflections
                        VStack {
                            Text("Bible Verse\nReflections")
                                .font(.customBody1)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.parchmentDark)
                            Text("\(profileViewModel.stats["reflectionCount"] ?? 0)")
                                .font(.customFootnote)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.parchmentDark)
                        }
                        
                        // Column 3: Prayer Reminders
                        VStack {
                            Text("Prayer\nReminders")
                                .font(.customBody1)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.parchmentDark)
                            Text("\(profileViewModel.stats["prayerCount"] ?? 0)")
                                .font(.customFootnote)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.parchmentDark)
                        }
                    }
                    
                    // Row 2
                    GridRow {
                        // Column 1: Gratitude Statements
                        VStack {
                            Text("Gratitude\nStatements")
                                .font(.customBody1)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.parchmentDark)
                            Text("\(profileViewModel.stats["gratitudeCount"] ?? 0)")
                                .font(.customFootnote)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.parchmentDark)
                        }
                        
                        // Column 2: Self Reflections
                        VStack {
                            Text("Self\nReflections")
                                .font(.customBody1)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.parchmentDark)
                            Text("\(profileViewModel.stats["entryReflectionCount"] ?? 0)")
                                .font(.customFootnote)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.parchmentDark)
                        }
                        
                        // Column 3: Longest Streak
                        VStack {
                            Text("Longest\nStreak")
                                .font(.customBody1)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.parchmentDark)
                            Text("-")
                                .font(.customFootnote)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.parchmentDark)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            profileViewModel.fetchProfileStats()
        }
    }
}
