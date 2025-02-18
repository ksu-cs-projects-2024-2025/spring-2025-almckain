//
//  CalendarCardView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/17/25.
//

import SwiftUI

struct CalendarCardView: View {
    
    @StateObject var calendarViewModel = CalendarViewModel()
    
    @State private var date = Date.now
    let daysOfWeek = Date.capitalizedFirstLettersOfWeekdays
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    @State private var days: [Date] = []

    @State private var selectedDate: Date?
    
    var body: some View {
        VStack {
            LabeledContent("Date/Time") {
                DatePicker("", selection: $date)
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
                        NavigationLink(value: day) {
                            Text(day.formatted(.dateTime.day()))
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .background(
                                    Circle().foregroundStyle(
                                        Date.now.startOfDay == day.startOfDay ? Color.red.opacity(0.7) : Color.red.opacity(0.25)
                                    )
                                )
                        }
                    }
                }
                .padding(.top, 8)
            }
            .padding(.top, 8)
        }
        .padding()
        .onAppear {
            days = date.calendarDisplayDays
            let appearance = calendarViewModel.navBarAppearance()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        .onChange(of: date) { newValue in
            days = date.calendarDisplayDays
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(.warmSandLight)
                .shadow(color: Color.parchmentDark.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .padding(.vertical, 10)
    }
}


#Preview {
    CalendarCardView()
}
