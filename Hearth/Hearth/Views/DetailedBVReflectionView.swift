//
//  DetailedBVReflectionView.swift
//  Hearth
//
//  Created by Aaron McKain on 3/4/25.
//

import SwiftUI

struct DetailedBVReflectionView: View {
    @ObservedObject var reflectionViewModel: VerseReflectionViewModel
    @Binding var isPresented: Bool
    @State private var isEditing = false
    var formattedTimeStamp: String {
        if let timeStamp = reflectionViewModel.reflection?.timeStamp {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd, yyyy 'at' h:mm a"
            return formatter.string(from: timeStamp)
        } else {
            return "No date available"
        }
    }

    
    var body: some View {
        ZStack {
            Color.warmSandLight
                .ignoresSafeArea()
            VStack {
                ScrollView {
                    VStack {
                        HStack {
                            Text("Verse Reflection")
                                .font(.customTitle1)
                                .foregroundStyle(.parchmentDark)
                            
                            Spacer()
                        }
                        
                        Rectangle()
                            .fill(Color.parchmentDark)
                            .frame(height: 2)
                        
                        Text(reflectionViewModel.reflection?.bibleVerseText ?? "No bible verse")
                            .font(.customHeadline1)
                            .foregroundStyle(.hearthEmberDark)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                        HStack {
                            Spacer()
                            Text(reflectionViewModel.reflection?.title ?? "No title")
                                .foregroundStyle(.parchmentDark)
                                .font(.customBody1)
                        }
                        
                        Rectangle()
                            .fill(Color.parchmentDark)
                            .frame(height: 2)
                        
                        HStack {
                            Text(formattedTimeStamp)
                                .font(.customHeadline1)
                                .foregroundStyle(.hearthEmberDark)
                            Spacer()
                        }
                        
                        Text(reflectionViewModel.reflection?.reflection ?? "No reflection")
                            .font(.customBody1)
                            .foregroundStyle(.parchmentDark)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                    }
                    
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
                            /*
                            viewModel.deleteEntry(withId: entry.id ?? "") { result in
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
                             */
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
    }
}

/*
#Preview {
    DetailedBVReflectionView()
}
*/
