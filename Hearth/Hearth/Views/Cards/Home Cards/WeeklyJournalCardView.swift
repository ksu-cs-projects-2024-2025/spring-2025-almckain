//
//  WeeklyJournalCardView.swift
//  Hearth
//
//  Created by Aaron McKain on 3/31/25.
//

import SwiftUI

struct WeeklyJournalCardView: View {
    @ObservedObject var entryViewModel: JournalEntryViewModel
    @State private var isPresented: Bool = false

    private var currentWeekDays: [Date] {
        Date().daysOfCurrentWeek
    }
    var body: some View {
        CardView {
            VStack {
                HStack {
                    Text("This Weeks Journal")
                        .font(.customTitle3)
                        .foregroundStyle(.hearthEmberMain)
                    Spacer()
                }
                CustomDivider(height: 2, color: .hearthEmberDark)
                
                HStack {
                    ForEach(currentWeekDays, id: \.self) { day in
                        let hasEntry = entryViewModel.journalEntries.contains {
                            Calendar.current.isDate($0.timeStamp, inSameDayAs: day)
                        }
                        
                        let isToday = Calendar.current.isDateInToday(day)
                        
                        WeekdayRectangle(dayString: entryViewModel.dayFormatted(day), isToday: isToday, hasEntry: hasEntry)
                    }
                }
                
                let today = Date()
                let hasTodayEntry = entryViewModel.journalEntries.contains {
                    Calendar.current.isDate($0.timeStamp, inSameDayAs: today)
                }
                
                VStack(spacing: 18) {
                    Text(hasTodayEntry
                         ? "You've already journaled today. Want to view or add another?"
                         : "You haven’t added to your journal yet today.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if hasTodayEntry {
                        HStack(spacing: 24) {
                            NavigationLink {
                                EntryDayListView(
                                    selectedDate: Date(),
                                    calendarViewModel: CalendarViewModel(),
                                    journalEntryViewModel: JournalEntryViewModel(),
                                    reflectionViewModel: VerseReflectionViewModel(),
                                    journalReflectionViewModel: ReflectionViewModel(),
                                    gratitudeViewModel: GratitudeViewModel()
                                )
                            } label: {
                                Text("View Today")
                                    .font(.customTitle3)
                                    .foregroundColor(.hearthEmberMain)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 20)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        Capsule()
                                            .stroke(Color.hearthEmberMain, lineWidth: 4)
                                    )
                            }


                            CapsuleButton(title: "Add Another", style: .filled, foregroundColor: .parchmentLight, backgroundColor: .hearthEmberMain, action: {
                                isPresented.toggle()
                            })
                        }
                        .padding(.horizontal, 14)
                    } else {
                        CapsuleButton(title: "Add to Journal", style: .filled ,foregroundColor: .parchmentLight, backgroundColor: .hearthEmberMain, action: {
                            isPresented.toggle()
                        })
                    }
                }
                .padding(.top, 5)
            }
        }
        .onAppear {
            let weekStart = currentWeekDays.first ?? Date()
            guard let weekEnd = Calendar.current.date(byAdding: .day,value: 7, to: weekStart) else { return }
            
            entryViewModel.fetchJournalEntries(forWeekStarting: weekStart, ending: weekEnd)
        }
        .customSheet(isPresented: $isPresented) {
            CreateNewJournalView(
                isPresenting: $isPresented,
                viewModel: entryViewModel,
                calendarViewModel: CalendarViewModel(),
                selectedDate: Date()
            )
        }
        .presentationDetents([.fraction(0.95)])

    }
}

/*
#Preview {
    WeeklyJournalCardView()
}
*/
