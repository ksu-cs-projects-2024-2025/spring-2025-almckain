//
//  CalendarCardView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/17/25.
//

import SwiftUI

struct CalendarCardView: View {
    
    @ObservedObject var calendarViewModel: CalendarViewModel
    @ObservedObject var gratitudeViewModel: GratitudeViewModel
    @EnvironmentObject var prayerViewModel: PrayerViewModel
    
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
                            let hasGratitude = gratitudeViewModel.allEntries.contains {
                                Calendar.current.isDate($0.timeStamp, inSameDayAs: dayStart)
                            }
                            
                            let hasActivity = hasEntries || hasReflection || hasGratitude
                            
                            let hasPrayer = !prayerViewModel.prayers(for: dayStart).isEmpty
                           

                            
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
                                    
                                    if hasPrayer {
                                        VStack {
                                            HStack {
                                                Spacer()
                                                Image(systemName: "bell.fill")
                                                    .font(.caption)
                                                    .foregroundColor(Color.yellow)
                                                    .padding(6)
                                                
                                                    .background(
                                                        Circle()
                                                            .fill(Color.warmSandLight)
                                                    )
                                                    .offset(x: 13, y: -13)

                                            }
                                            Spacer()
                                        }
                                        .padding(4)
                                    }
                                    
                                }
                                .frame(maxWidth: .infinity, minHeight: 40)
                            }
                            //.disabled(isFutureDay)
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
            prayerViewModel.fetchPrayers(forMonth: date)
            gratitudeViewModel.fetchEntries(forMonth: date)
            
            let appearance = calendarViewModel.navBarAppearance()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        .onChange(of: date) { _, newValue in
            days = newValue.calendarDisplayDays
            calendarViewModel.fetchEntriesInMonth(newValue)
            calendarViewModel.fetchReflectionsInMonth(newValue)
            prayerViewModel.fetchPrayers(forMonth: newValue)
            gratitudeViewModel.fetchEntries(forMonth: newValue)
        }
    }
}

/*
 #Preview {
 CalendarCardView(calendarViewModel: CalendarViewModel(), journalEntryViewModel: JournalEntryViewModel())
 }
 */
