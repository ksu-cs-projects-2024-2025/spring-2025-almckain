//
//  CalendarView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/6/25.
//

import SwiftUI

struct CalendarView: View {
    
    @ObservedObject var journalEntryViewModel: JournalEntryViewModel
    @ObservedObject var calendarViewModel: CalendarViewModel
    @ObservedObject var reflectionViewModel: VerseReflectionViewModel
    @ObservedObject var journalReflectionViewModel: ReflectionViewModel
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    
    @State private var isPresented: Bool = false
    @State private var showReflectionCard = false
    
    var body: some View {
        ZStack {
            Color.parchmentLight
                .ignoresSafeArea()
            NavigationStack {
                ScrollView {
                    LazyVStack(spacing: 15) {
                        NewReflectionCardView(isInCalendarView: true, reflectionViewModel: journalReflectionViewModel)
                            .transition(.move(edge: .leading))
                        
                        CalendarCardView(calendarViewModel: calendarViewModel)
                        
                        Button(action: {
                            isPresented.toggle()
                        }) {
                            Text("Add to Journal")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .font(.customButton)
                                .foregroundColor(.parchmentLight)
                                .background(RoundedRectangle(cornerRadius: 30).foregroundStyle(.hearthEmberMain))
                                .contentShape(Rectangle())
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, 50)
                    }
                }
                .padding(.top, 15)
                .onAppear {
                    let appearance = calendarViewModel.navBarAppearance()
                    UINavigationBar.appearance().standardAppearance = appearance
                    UINavigationBar.appearance().scrollEdgeAppearance = appearance
                }
                .navigationTitle("Calendar")
                .navigationBarTitleDisplayMode(.large)
                .buttonStyle(.plain)
                
                .navigationDestination(for: Date.self) { date in
                    EntryDayListView(selectedDate: date, calendarViewModel: calendarViewModel, journalEntryViewModel: journalEntryViewModel, reflectionViewModel: reflectionViewModel, journalReflectionViewModel: journalReflectionViewModel)
                }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showReflectionCard)
        .onAppear {
            notificationViewModel.updateReflectionCardVisibility()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showReflectionCard = notificationViewModel.shouldShowReflectionCard
                }
            }
            
            journalEntryViewModel.onEntryUpdate = { [weak calendarViewModel] in
                calendarViewModel?.fetchEntriesInMonth(Date())
                calendarViewModel?.fetchEntries(for: Date())
            }
            reflectionViewModel.onReflectionUpdate = { [weak calendarViewModel] in
                calendarViewModel?.fetchReflectionsInMonth(Date())
            }
        }
        .customSheet(isPresented: $isPresented) {
            CreateNewJournalView(isPresenting: $isPresented, viewModel: journalEntryViewModel, calendarViewModel: calendarViewModel, selectedDate: Date())
        }
        .presentationDetents([.fraction(0.95)])
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            notificationViewModel.updateReflectionCardVisibility()
            withAnimation(.easeInOut(duration: 0.5)) {
                showReflectionCard = notificationViewModel.shouldShowReflectionCard
            }
        }
        
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            notificationViewModel.updateReflectionCardVisibility()
            withAnimation(.easeInOut(duration: 0.5)) {
                showReflectionCard = notificationViewModel.shouldShowReflectionCard
            }
        }
        
    }
}

/*
 #Preview {
 CalendarView()
 }
 */
