//
//  CalendarView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/6/25.
//

import SwiftUI

struct CalendarView: View {
    
    @StateObject var calendarViewModel = CalendarViewModel()
    @State private var isPresented: Bool = false
    @StateObject private var viewModel = JournalEntryViewModel()

    
    var body: some View {
        ZStack {
            Color.parchmentLight
                .ignoresSafeArea()
            NavigationStack {
                ScrollView {
                    CalendarCardView(calendarViewModel: calendarViewModel)
                        .navigationDestination(for: Date.self) { date in
                            EntryDayListView(selectedDate: date, calendarViewModel: calendarViewModel)
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
                    
                    CreateNewJournalView(isPresenting: $isPresented, viewModel: viewModel, calendarViewModel: calendarViewModel, selectedDate: Date())
                }
            }
            .presentationDetents([.fraction(0.90)])
        }
    }
}

#Preview {
    CalendarView()
}
