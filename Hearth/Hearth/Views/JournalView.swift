//
//  FeedView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/6/25.
//

import SwiftUI

struct JournalView: View {
    @State private var isPresented: Bool = false
    @StateObject private var viewModel = JournalEntryViewModel()
    
    init() {
        let appearance = navBarAppearance()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.parchmentLight
                    .ignoresSafeArea()
                ScrollView {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        ForEach(viewModel.journalEntries, id: \.id) { entry in
                            JournalEntryCardView(journalEntry: entry)
                        }
                    }
                }
                .navigationTitle("Journal")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            isPresented.toggle()
                        }) {
                            Image(systemName: "plus.square")
                                .font(.customTitle3)
                                .foregroundStyle(.hearthEmberLight)
                        }
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
                            
                            CreateNewJournalView(isPresenting: $isPresented, viewModel: viewModel)
                        }
                    }
                    .presentationDetents([.fraction(0.90)])
                }
            }
        }
        .onAppear {
            viewModel.fetchJournalEntries()
        }
    }
    
    func navBarAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "WarmSandMain")
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(named: "HearthEmberMain") ?? UIColor.red
        ]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "HearthEmberMain") ?? UIColor.red]
        return appearance
    }
}

#Preview {
    JournalView()
}
