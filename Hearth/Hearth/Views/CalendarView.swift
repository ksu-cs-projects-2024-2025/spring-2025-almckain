//
//  CalendarView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/6/25.
//

import SwiftUI

struct CalendarView: View {
    
    @StateObject private var journalEntryViewModel = JournalEntryViewModel()
    @StateObject var calendarViewModel = CalendarViewModel()
    @StateObject var reflectionViewModel = VerseReflectionViewModel()
    
    @State private var isPresented: Bool = false
    
    
    var body: some View {
        ZStack {
            Color.parchmentLight
                .ignoresSafeArea()
            NavigationStack {
                ScrollView {
                    CalendarCardView(calendarViewModel: calendarViewModel)
                        .navigationDestination(for: Date.self) { date in
                            EntryDayListView(selectedDate: date, calendarViewModel: calendarViewModel, journalEntryViewModel: journalEntryViewModel, reflectionViewModel: reflectionViewModel)
                        }
                    
                    Button(action: {
                        isPresented.toggle()
                    }) {
                        Text("Add to Journal")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .font(.customButton)
                            .foregroundColor(.parchmentLight)
                            .background(RoundedRectangle(cornerRadius: 20).foregroundStyle(.hearthEmberMain))
                            .contentShape(Rectangle())
                    }
                }
                .onAppear {
                    let appearance = calendarViewModel.navBarAppearance()
                    UINavigationBar.appearance().standardAppearance = appearance
                    UINavigationBar.appearance().scrollEdgeAppearance = appearance
                }
                .navigationTitle("Calendar")
                .navigationBarTitleDisplayMode(.large)
                .buttonStyle(.plain)
                .padding(.horizontal)
            }
        }
        .onAppear {
            journalEntryViewModel.onEntryUpdate = { [weak calendarViewModel] in
                calendarViewModel?.fetchEntriesInMonth(Date())
                calendarViewModel?.fetchEntries(for: Date())
            }
            reflectionViewModel.onReflectionUpdate = { [weak calendarViewModel] in
                calendarViewModel?.fetchReflectionsInMonth(Date())
            }
        }
        .sheet(isPresented: $isPresented) {
            ZStack {
                Color.warmSandLight
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "x.circle.fill")
                            .padding(.top)
                            .padding(.trailing, 20)
                            .foregroundStyle(.parchmentDark.opacity(0.6))
                            .font(.customTitle2)
                            .onTapGesture {
                                isPresented.toggle()
                            }
                    }
                    
                    CreateNewJournalView(isPresenting: $isPresented, viewModel: journalEntryViewModel, calendarViewModel: calendarViewModel, selectedDate: Date())
                }
            }
            .presentationDetents([.fraction(0.95)])
            
        }
    }
}

#Preview {
    CalendarView()
}
