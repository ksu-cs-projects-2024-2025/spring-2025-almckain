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
    
    private let last7Days: [Date] = {
        (0..<7).map { offset in
            Calendar.current.startOfDay(for: Date().addingTimeInterval(TimeInterval(-86400 * Double(offset))))
        }
    }()
        
    init(prayerViewModel: PrayerViewModel) {
        self.prayerViewModel = prayerViewModel
    }
    
    func onAppear() {
        fetchLast7DaysOfPrayers()
        fetchFuturePrayers(limit: 15)
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
    
    private func fetchLast7DaysOfPrayers() {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -6, to: Date().startOfDay) ?? Date()
        let range = DateInterval(start: sevenDaysAgo, end: Date().endOfDay)
        
        prayerViewModel.fetchPrayers(in: range) { [weak self] in
            guard let self = self else { return }
            self.prayersByDay = Dictionary(
                grouping: self.prayerViewModel.prayers,
                by: { $0.timeStamp.startOfDay }
            )
        }
    }
    
    private func fetchFuturePrayers(limit: Int) {
        prayerViewModel.fetchFuturePrayers(limit: limit) { [weak self] in
            guard let self = self else { return }
            // Group them by day
            self.futurePrayersByDay = Dictionary(
                grouping: self.prayerViewModel.prayers,
                by: { $0.timeStamp.startOfDay }
            )
        }
    }
}
