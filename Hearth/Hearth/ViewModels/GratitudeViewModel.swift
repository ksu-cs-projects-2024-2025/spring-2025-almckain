//
//  GratitudeViewModel.swift
//  Hearth
//
//  Created by Aaron McKain on 4/17/25.
//
import Foundation
import SwiftUI

class GratitudeViewModel: ObservableObject {
    @Published var allEntries: [GratitudeModel] = []
    @Published var todayEntry: GratitudeModel?
    @Published var errorMessage: String?
    
    private let service: GratitudeServiceProtocol
    private let userDefaults = UserDefaults.standard

    private var prompts: [String] = [
        "What's one small thing that brought you joy today?",
        "Who made a positive difference in your life recently, and how?",
        "What's something in your daily routine that you're thankful for?",
        "What's a challenge you've overcome that you now feel grateful for?",
        "What's something in nature that filled you with wonder recently?",
        "What personal quality or strength are you appreciative of today?",
        "What's something you use every day that you're thankful for?",
        "What's a conversation that you're grateful you had recently?",
        "What's a lesson you learned recently that you're thankful for?",
        "What's something about your body or health that you're grateful for?",
        "What opportunity are you thankful for having in your life?",
        "What's a memory that still brings you gratitude when you think about it?",
        "What's something you're looking forward to that fills you with gratitude?",
        "Who's someone that helped shape who you are, and what are you grateful for about them?",
        "What's something beautiful you noticed today?",
        "What meal in the past week brought you the most enjoyment, and what specifically made it special?",
        "Name a piece of technology you used today that made your life easier, and how it helped you.",
        "What's a compliment someone gave you recently that you're still thinking about?",
        "Describe a moment of peace you experienced in the last 24 hours, no matter how brief.",
        "What's something your body allowed you to do today that you might take for granted?",
        "Think of a mistake you made that led to unexpected growth. What are you grateful for about that experience?",
        "What's a song that improved your mood recently, and what feelings did it evoke?",
        "Identify a person who challenged you in a positive way lately. What did they help you see differently?",
        "What's a small luxury in your life that you'd really miss if it were gone?",
        "Recall a moment of laughter you experienced this week. What made it so funny?",
        "What's something in your home that brings you comfort every day that you rarely notice?",
        "Think of a difficult conversation you had recently. What are you grateful for about how it unfolded?",
        "What's something you learned from a family member that you've found valuable?",
        "Describe a time in the past month when a stranger showed you unexpected kindness.",
        "What's a personal habit you've developed that consistently improves your life?"
    ]
    private let allPromptCount = 30
    private let promptsKey = "dailyGratitudePrompts"
    private let completedKey = "completedGratitudePrompts"
    private let lastDateKey = "lastGratitudePromptDate"
    var todaysPrompts: [String] = []
    
    init(service: GratitudeServiceProtocol = GratitudeService()) {
        self.service = service
    }
    
    func fetchEntries(forMonth date: Date) {
        service.fetchGratitudeEntries(forMonth: date) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let entries):
                    self?.allEntries = entries
                    self?.todayEntry = entries.first(where: {
                        Calendar.current.isDateInToday($0.timeStamp)
                    })
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }

            }
        }
    }
    
    func hasTodayEntry() -> Bool {
        return todayEntry != nil
    }
    
    func getRandomPrompt() -> String {
        return prompts.randomElement() ?? "What are you grateful for today?"
    }
    
    func saveEntry(prompt: String, content: String, completion: @escaping(Bool) -> Void) {
        let entry = GratitudeModel(id: UUID().uuidString, userID: "", timeStamp: Date(), prompt: prompt, content: content)
        
        service.saveGratitudeEntry(entry) { [weak self] result in
            switch result {
            case .success:
                self?.todayEntry = entry
                self?.allEntries.insert(entry, at: 0)
                self?.errorMessage = nil
                completion(true)
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                completion(false)
            }
        }
    }
    
    func updateGratitude(_ entry: GratitudeModel, completion: @escaping (Bool) -> Void) {
        service.updateGratitude(entry) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if let index = self?.allEntries.firstIndex(where: { $0.id == entry.id }) {
                        self?.allEntries[index] = entry
                    }
                    self?.errorMessage = nil
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
    
    func deleteGratitude(entryID: String, completion: @escaping (Bool) -> Void) {
        service.deleteGratitude(entryID: entryID) { [weak self] result in
            switch result {
            case .success:
                if let index = self?.allEntries.firstIndex(where: { $0.id == entryID }) {
                    self?.allEntries.remove(at: index)
                    self?.todayEntry = nil
                }
                self?.errorMessage = nil
                completion(true)
                
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                completion(false)
            }
        }
    }
    
    func setupDailyPrompts() {
        let today = Calendar.current.startOfDay(for: Date())
        let storedDate = userDefaults.object(forKey: lastDateKey) as? Date ?? Date()
        
        if storedDate != today {
            var completed = Set(userDefaults.array(forKey: completedKey) as? [Int] ?? [])
            var unusedIndices = Array(0..<allPromptCount).filter { !completed.contains($0) }
            
            var selectedIndices: [Int] = []
            
            if unusedIndices.count < 3 {
                let leftover = unusedIndices
                completed.subtract(leftover)
                userDefaults.set(Array(completed), forKey: completedKey)
                
                unusedIndices = Array(0..<allPromptCount).filter { !completed.contains($0) }
                
                selectedIndices = leftover
                let additional = (Array(unusedIndices).shuffled().prefix(3 - leftover.count))
                selectedIndices.append(contentsOf: additional)
            } else {
                selectedIndices = Array(unusedIndices.shuffled().prefix(3))
            }
            
            userDefaults.set(selectedIndices, forKey: promptsKey)
            userDefaults.set(today, forKey: lastDateKey)
        }
        
        let promptIndices = userDefaults.array(forKey: promptsKey) as? [Int] ?? []
        todaysPrompts = promptIndices.compactMap { prompts[safe: $0] }
    }
    
    func markPromptCompleted(_ prompt: String) {
        guard let index = prompts.firstIndex(of: prompt) else { return }
        
        var completed = Set(userDefaults.array(forKey: completedKey) as? [Int] ?? [])
        completed.insert(index)
        userDefaults.set(Array(completed), forKey: completedKey)
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
