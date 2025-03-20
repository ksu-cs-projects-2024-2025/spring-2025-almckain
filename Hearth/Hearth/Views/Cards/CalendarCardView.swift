//
//  CalendarCardView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/17/25.
//

import SwiftUI

struct CalendarCardView: View {
    
    @ObservedObject var calendarViewModel: CalendarViewModel
    
    @State private var days: [Date] = []
    @State private var date = Date.now
    
    let daysOfWeek = Date.capitalizedFirstLettersOfWeekdays
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        CardView {
            VStack {
                LabeledContent("Date/Time") {
                    DatePicker("", selection: $date, displayedComponents: .date)
                }
                .padding(.bottom, 10)
                
                HStack {
                    ForEach(daysOfWeek.indices, id: \.self) { index in
                        Text(daysOfWeek[index])
                            .fontWeight(.black)
                            .foregroundStyle(.hearthEmberDark)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                LazyVGrid(columns: columns) {
                    ForEach(days, id: \.self) { day in
                        if day.monthInt != date.monthInt {
                            Text(day.formatted(.dateTime.day()))
                                .fontWeight(.bold)
                                .foregroundStyle(.clear)
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .background(
                                    Circle().foregroundStyle(.clear)
                                )
                            
                        }else {
                            let dayStart = day.startOfDay
                            let hasEntries = !(calendarViewModel.monthEntries[dayStart, default: []].isEmpty)
                            let hasReflection = !(calendarViewModel.monthReflections[dayStart, default: []].isEmpty)
                            let isFutureDay = dayStart > Date().startOfDay
                            let isToday = dayStart == Date().startOfDay
                            let hasActivity = hasEntries || hasReflection
                            
                            NavigationLink(value: day) {
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
                                        .foregroundColor(hasActivity ? Color.parchmentLight : Color.parchmentDark
                                        )
                                        .opacity(isFutureDay ? 0.4 : 1.0)
                                }
                                .frame(maxWidth: .infinity, minHeight: 40)
                            }
                            .disabled(isFutureDay)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.top, 8)
                
            }
        }
        .onAppear {
            days = date.calendarDisplayDays
            calendarViewModel.fetchEntriesInMonth(date)
            calendarViewModel.fetchReflectionsInMonth(date)
            
            let appearance = calendarViewModel.navBarAppearance()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        .onChange(of: date) { oldValue, newValue in
            days = newValue.calendarDisplayDays
            calendarViewModel.fetchEntriesInMonth(newValue)
            calendarViewModel.fetchReflectionsInMonth(newValue)
        }
    }
}

/*
#Preview {
    CalendarCardView(calendarViewModel: CalendarViewModel(), journalEntryViewModel: JournalEntryViewModel())
}
*/
