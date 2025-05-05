//
//  DetailedJournalEntryView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/17/25.
//

import SwiftUI

struct DetailedJournalEntryView: View {
    let entry: JournalEntryModel
    var selectedDate: Date
    
    @Binding var isPresenting: Bool
    @ObservedObject var viewModel: JournalEntryViewModel
    @ObservedObject var calendarViewModel: CalendarViewModel
    @State private var isEditing = false
    @State private var showingDeleteConfirmation = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack{
                Color.warmSandLight
                    .ignoresSafeArea()
                VStack {
                    ScrollView {
                        HStack {
                            Text(entry.timeStamp.formatted(.dateTime
                                .month(.abbreviated)
                                .day(.defaultDigits)
                                .year()
                                .hour(.twoDigits(amPM: .abbreviated))
                                .minute()
                            ))
                            .font(.customHeadline1)
                            .foregroundStyle(.hearthEmberDark)
                            
                            Spacer()
                        }
                        HStack {
                            Text(entry.title)
                                .font(.customTitle1)
                                .foregroundStyle(.parchmentDark)
                            Spacer()
                        }
                        .padding(.vertical)
                        
                        CustomDivider(height: 2, color: .hearthEmberMain)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundStyle(.parchmentLight)
                            
                            Text(entry.content)
                                .padding(.vertical)
                                .foregroundStyle(.parchmentDark)
                                .font(.customBody1)
                                .padding(.vertical, 5)
                                .padding(.horizontal)
                        }
                        
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.customCaption1)
                                .foregroundStyle(.hearthError)
                        }
                        
                        Spacer()
                    }
                    .navigationTitle("View Journal Entry")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(Color.warmSandLight, for: .navigationBar)
                    .toolbarColorScheme(.light, for: .navigationBar)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: { dismiss() }) {
                                Image(systemName: "x.circle.fill")
                            }
                        }
                    }
                    
                    HStack {
                        Button(action: {
                            showingDeleteConfirmation = true
                        }) {
                            Text("Delete")
                                .frame(width: 100)
                                .padding()
                                .foregroundColor(.hearthEmberMain)
                                .font(.customButton)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.hearthEmberMain, lineWidth: 4)
                                )
                        }

                        Button(action: {
                            isEditing = true
                        }) {
                            Text("Edit")
                                .frame(width: 100)
                                .padding()
                                .background(Color.hearthEmberMain)
                                .foregroundColor(.parchmentLight)
                                .font(.customButton)
                                .cornerRadius(15)
                        }
                    }
                }
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .padding()
                        .background(.parchmentLight)
                        .foregroundStyle(.hearthEmberMain)
                        .cornerRadius(10)
                }
            }
        }
        .alert("Confirm Delete", isPresented: $showingDeleteConfirmation){
            Button("Delete", role: .destructive) {
                if !entry.id.isEmpty {
                    viewModel.deleteEntry(withId: entry.id) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success:
                                calendarViewModel.fetchEntries(for: selectedDate)
                                isPresenting = false
                            case .failure(let error):
                                print("Error deleting entry: \(error.localizedDescription)")
                            }
                        }
                    }
                } else {
                    print("Invalid entry id")
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this entry? This action cannot be undone.")
        }
        .customSheet(isPresented: $isEditing) {
            CreateNewJournalView(isPresenting: $isEditing, viewModel: viewModel, calendarViewModel: calendarViewModel, selectedDate: selectedDate, entry: entry)
        }
        .presentationDetents([.fraction(0.95)])

    }
}

#Preview {
    DetailedJournalEntryView(
        entry: JournalEntryModel(
            id: "", userID: "123",
            title: "Today I got a cool taco",
            content: """
                It wasn't like a crazy taco. But it was a totally different taco. Like, I don't know who made it, but give them a raise because they are putting in the work.
                
                Sometimes, I think tacos look like trash. Not this one. This is my taco, with my taco I am useless. With me, my taco is useless.
                """,
            timeStamp: Date()
        ),
        selectedDate: Date(),
        isPresenting: .constant(true),
        viewModel: JournalEntryViewModel(),
        calendarViewModel: CalendarViewModel()
    )
}

