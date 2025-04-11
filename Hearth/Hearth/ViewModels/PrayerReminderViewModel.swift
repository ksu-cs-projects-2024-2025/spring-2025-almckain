//
//  PrayerReminderViewModel.swift
//  Hearth
//
//  Created by Aaron McKain on 4/2/25.
//

import Foundation
import Combine
import FirebaseAuth

enum ReminderFilter: String, CaseIterable, Identifiable {
    case today = "Today"
    case future = "Future"
    
    var id: String { rawValue }
}

@MainActor
class PrayerReminderViewModel: ObservableObject {
    let prayerViewModel: PrayerViewModel
    
    @Published var selectedFilter: ReminderFilter = .today
    @Published var prayersByDay: [Date: [PrayerModel]] = [:]
    @Published var futurePrayersByDay: [Date: [PrayerModel]] = [:]
    
    private var cancellables = Set<AnyCancellable>()
    
    private let last7Days: [Date] = {
        (0..<7).map { offset in
            Calendar.current.startOfDay(for: Date().addingTimeInterval(TimeInterval(-86400 * Double(offset))))
        }
    }()
    
    init(prayerViewModel: PrayerViewModel) {
        self.prayerViewModel = prayerViewModel
        prayerViewModel.$prayers
            .receive(on: RunLoop.main)
            .sink { [weak self] updatedPrayers in
                self?.updateDictionaries(with: updatedPrayers)
            }
            .store(in: &cancellables)
    }
    
    private func updateDictionaries(with allPrayers: [PrayerModel]) {
        let now = Date()
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -6, to: now.startOfDay) ?? now
        
        // Filter them
        let last7DaysPrayers = allPrayers.filter {
            $0.timeStamp >= sevenDaysAgo && $0.timeStamp <= now.endOfDay
        }
        
        let futurePrayers = allPrayers.filter {
            $0.timeStamp > now.endOfDay
        }
        
        // Group by day
        prayersByDay = Dictionary(grouping: last7DaysPrayers) {
            $0.timeStamp.startOfDay
        }
        futurePrayersByDay = Dictionary(grouping: futurePrayers) {
            $0.timeStamp.startOfDay
        }
    }
    
    var hasPrayersInLast7Days: Bool {
        for day in last7Days {
            if let dailyPrayers = prayersByDay[day], !dailyPrayers.isEmpty {
                return true
            }
        }
        return false
    }
    
    var sortedFutureDays: [Date] {
        Array(futurePrayersByDay.keys).sorted()
    }
    
    var daysToShow: [Date] {
        last7Days
    }
}
