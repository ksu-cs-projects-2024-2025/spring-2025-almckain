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

    
    var body: some View {
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
                    
                    Rectangle()
                        .fill(Color.parchmentDark)
                        .frame(height: 2)
                        .padding(.trailing, 20)

                    Text(entry.content)
                        .padding(.vertical)

                    Spacer()

                    HStack {
                        Button("Edit") {
                            isEditing = true
                        }
                        .padding()
                        .frame(width: 100)
                        .foregroundColor(.hearthEmberLight)
                        .font(.headline)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.hearthEmberLight, lineWidth: 4)
                        )

                        
                        Button("Delete") {
                            viewModel.deleteEntry(withId: entry.id ?? "") { result in
                                switch result {
                                case .success:
                                    calendarViewModel.fetchEntries(for: selectedDate)
                                    isPresenting = false
                                case .failure(let error):
                                    print("Error deleting entry: \(error.localizedDescription)")
                                }
                            }
                        }
                        .padding()
                        .frame(width: 100)
                        .background(Color.hearthEmberLight)
                        .foregroundColor(.parchmentLight)
                        .font(.headline)
                        .cornerRadius(15)
                    }
                }
            }
        }
        .sheet(isPresented: $isEditing) {
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
                                isEditing.toggle()
                            }
                    }
                    
                    CreateNewJournalView(isPresenting: $isEditing, viewModel: viewModel, calendarViewModel: calendarViewModel, selectedDate: selectedDate, entry: entry)
                }
            }
            .presentationDetents([.fraction(0.90)])
        }
    }
}
/*
#Preview {
    @Previewable @State var isPresented = true
    DetailedJournalEntryView(entry: JournalEntryModel(userID: "123", title: "Today I got a cool taco", content: "It wasnt like a crazy taco. But it was fs a totally different taco. Like idk who made it but give them a raise because they are putting in the work. \n\n Sometimes, I think tacos look like trash. Not this one. This is my taco, with my taco I am useless. With me, my taco is useless.", timeStamp: Date()), isPresenting: $isPresented )
}
*/
