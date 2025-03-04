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
    private let savedBibleVerseKey = "SavedBibleVerse"
    private let savedBibleReferenceKey = "SavedBibleReference"
    
    init(bibleService: BibleVerseServiceProtocol = BibleVerseService(),
         reflectionService: VerseReflectionService = VerseReflectionService()) {
        self.bibleService = bibleService
        self.reflectionService = reflectionService
        
        loadBibleVerses()
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
        
        // If it's not a new day, try to load the cached verse data.
        if !hasNewDayStarted() {
            if let savedData = UserDefaults.standard.data(forKey: savedBibleVerseKey),
               let savedVerse = try? JSONDecoder().decode(BibleVerseModel.self, from: savedData),
               let savedReference = UserDefaults.standard.string(forKey: savedBibleReferenceKey) {
                bibleVerse = savedVerse
                dailyVerseReference = savedReference
                isLoading = false
                completion()
                return
            }
        }
        
        // Either it's a new day or no cache exists – fetch a new verse.
        let currentIndex = getCurrentIndex()
        let verseReference = dailyBibleVerses[currentIndex]
        dailyVerseReference = verseReference
        
        fetchDailyVerse(reference: verseReference) { [weak self] in
            guard let self = self else { return }
            if self.hasNewDayStarted() {
                self.saveCurrentIndex((currentIndex + 1) % self.dailyBibleVerses.count)
                self.saveLastUpdateDate()
            }
            completion()
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
                if case let .failure(error) = completionResult {
                    self?.errorMessage = error.localizedDescription
                }
                completion()
            } receiveValue: { [weak self] verse in
                self?.bibleVerse = verse
                self?.saveFetchedVerse(verse, reference: reference)
            }
            .store(in: &cancellables)
    }
    
    private func saveFetchedVerse(_ verse: BibleVerseModel, reference: String) {
        if let encodedVerse = try? JSONEncoder().encode(verse) {
            UserDefaults.standard.set(encodedVerse, forKey: savedBibleVerseKey)
            UserDefaults.standard.set(reference, forKey: savedBibleReferenceKey)
        }
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
}
