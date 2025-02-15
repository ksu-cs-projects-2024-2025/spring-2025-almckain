//
//  BibleVerseViewModel.swift
//  Hearth
//
//  Created by Aaron McKain on 2/13/25.
//

import Foundation
import Combine

class BibleVerseViewModel: ObservableObject {

    @Published var bibleVerse: BibleVerseModel?
    @Published var errorMessage: String?
    @Published var reflectionText: String = ""
    @Published var dailyVerseReference: String = ""
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let bibleService: BibleVerseServiceProtocol
    private let reflectionService: VerseReflectionService
    private var dailyBibleVerses: [String] = []
    
    private let lastVerseIndexKey = "LastUsedBibleVerseIndex"
    private let lastUpdateDateKey = "LastBibleVerseUpdateDate"
    
    init(bibleService: BibleVerseServiceProtocol = BibleVerseService(),
         reflectionService: VerseReflectionService = VerseReflectionService()) {
        self.bibleService = bibleService
        self.reflectionService = reflectionService
        
        loadBibleVerses()
        //fetchLocalDailyVerse()
    }
    
    private func loadBibleVerses() {
        if let url = Bundle.main.url(forResource: "bible_verses", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decodedVerses = try? JSONDecoder().decode([String].self, from: data) {
            dailyBibleVerses = decodedVerses
        } else {
            errorMessage = "Failed to load Bible verses"
        }
    }
    
    func fetchLocalDailyVerse(completion: @escaping () -> Void) {
        guard !dailyBibleVerses.isEmpty else {
            errorMessage = "No Bible verses available."
            completion()
            return
        }

        isLoading = true

        if hasNewDayStarted() {
            let currentIndex = getCurrentIndex()
            let verseReference = dailyBibleVerses[currentIndex]
            dailyVerseReference = verseReference
            
            fetchDailyVerse(reference: verseReference) {
                completion()
            }

            saveCurrentIndex((currentIndex + 1) % dailyBibleVerses.count)
            saveLastUpdateDate()
        } else {
            let currentIndex = getCurrentIndex()
            dailyVerseReference = dailyBibleVerses[currentIndex]
            fetchDailyVerse(reference: dailyVerseReference) {
                completion()
            }
        }
    }
    func fetchDailyVerse(reference: String, completion: @escaping () -> Void) {
        let formattedReference = reference.replacingOccurrences(of: " ", with: "%20")
        guard let url = URL(string: "https://bible-api.com/\(formattedReference)") else {
            self.errorMessage = "Invalid API URL"
            self.isLoading = false
            completion()
            return
        }

        bibleService.fetchVerse(from: url)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionResult in
                self?.isLoading = false
                completion()
                if case let .failure(error) = completionResult {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] verse in
                self?.bibleVerse = verse
                self?.isLoading = false
                completion()
            }
            .store(in: &cancellables)
    }
    
    private func getCurrentIndex() -> Int {
        let lastUsedIndex = UserDefaults.standard.integer(forKey: lastVerseIndexKey)
        return lastUsedIndex % dailyBibleVerses.count
    }
    
    private func saveCurrentIndex(_ index: Int) {
        UserDefaults.standard.set(index, forKey: lastVerseIndexKey)
    }
    
    private func hasNewDayStarted() -> Bool {
        guard let lastDate = UserDefaults.standard.object(forKey: lastUpdateDateKey) as? Date else {
            return true
        }
        
        let calendar = Calendar.current
        return !calendar.isDate(Date(), inSameDayAs: lastDate)
    }
    
    private func saveLastUpdateDate() {
            UserDefaults.standard.set(Date(), forKey: lastUpdateDateKey)
        }
    
    func saveReflection(for userID: String) {
        guard let verse = bibleVerse else { return }
        
        let reflection = VerseReflectionModel(
            userID: userID,
            title: "Reflection on \(verse.reference)",
            bibleVerseID: verse.verses.first?.id ?? "",
            bibleVerseReference: verse.reference,
            reflection: reflectionText,
            timeStamp: Date(),
            entryType: .bibleVerseReflection
        )


        
        reflectionService.saveReflection(reflection) { result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    print("Reflection saved successfully!")
                    self.reflectionText = ""
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
