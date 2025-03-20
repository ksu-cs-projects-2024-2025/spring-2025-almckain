//
//  CreateNewJournalView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/12/25.
//

import SwiftUI

struct CreateNewJournalView: View {
    @State private var title: String
    @State private var content: String
    @Binding var isPresenting: Bool
    
    var viewModel: JournalEntryViewModel
    var calendarViewModel: CalendarViewModel
    var selectedDate: Date
    var entry: JournalEntryModel?
    
    init(isPresenting: Binding<Bool>, viewModel: JournalEntryViewModel, calendarViewModel: CalendarViewModel, selectedDate: Date, entry: JournalEntryModel? = nil) {
        self._isPresenting = isPresenting
        self.viewModel = viewModel
        self.calendarViewModel = calendarViewModel
        self.selectedDate = selectedDate
        self.entry = entry
        self._title = State(initialValue: entry?.title ?? "")
        self._content = State(initialValue: entry?.content ?? "")
    }
    
    private var entryDate: Date {
        entry?.timeStamp ?? selectedDate
    }
    
    var body: some View {
        NavigationStack {
            ZStack{
                Color.warmSandLight
                    .ignoresSafeArea()
                ScrollView {
                    
                    HStack {
                        Text("New Journal Entry")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.parchmentDark)
                        Spacer()
                    }
                    
                    HStack {
                        Text(Date.now.formatted(.dateTime
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
                    TextField("Title", text: $title)
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    
                    TextEditor(text: $content)
                        .frame(minHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .padding(.vertical)
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.customCaption1)
                            .foregroundStyle(.hearthError)
                    }
                    
                    
                    Button(entry != nil ? "Update Entry" : "Add to Journal") {
                        if let entry = entry {
                            viewModel.updateJournalEntry(entry: entry, newTitle: title, newContent: content) { result in
                                DispatchQueue.main.async {
                                    switch result {
                                    case .success:
                                        calendarViewModel.fetchEntriesInMonth(Date())
                                        calendarViewModel.fetchEntries(for: selectedDate)
                                        isPresenting = false
                                    case .failure(let error):
                                        print("Failed to update entry: \(error.localizedDescription)")
                                    }
                                }
                            }
                        } else {
                            viewModel.addJournalEntry(title: title, content: content) { result in
                                DispatchQueue.main.async {
                                    switch result {
                                    case .success:
                                        calendarViewModel.fetchEntriesInMonth(Date())
                                        calendarViewModel.fetchEntries(for: selectedDate)
                                        isPresenting = false
                                    case .failure(let error):
                                        print("Failed to add entry: \(error.localizedDescription)")
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(width: 200)
                    .background(Color.hearthEmberLight)
                    .foregroundColor(.parchmentLight)
                    .font(.headline)
                    .cornerRadius(15)
                    
                    Spacer()
                }
                
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .padding()
                        .background(.warmSandLight)
                        .foregroundStyle(.hearthEmberMain)
                        .cornerRadius(10)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var isPresented = true
    let sampleEntry = JournalEntryModel(
        id: "",
        userID: "",
        title: "Sample Title",
        content: "Sample Content",
        timeStamp: Date()
    )
    CreateNewJournalView(
        isPresenting: $isPresented,
        viewModel: JournalEntryViewModel(),
        calendarViewModel: CalendarViewModel(),
        selectedDate: Date(),
        entry: sampleEntry
    )
}
