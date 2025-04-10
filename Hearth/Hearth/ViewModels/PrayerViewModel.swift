//
//  PrayerViewModel.swift
//  Hearth
//
//  Created by Aaron McKain on 4/1/25.
//

import Foundation
import FirebaseAuth
import Combine


@MainActor
class PrayerViewModel: ObservableObject {
    @Published var prayers: [PrayerModel] = []
    @Published var allPrayers: [PrayerModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let prayerService = PrayerService()
    
    func addPrayer(_ prayer: PrayerModel) {
        isLoading = true
        errorMessage = nil
        
        prayerService.addPrayer(prayer) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    self?.prayers.insert(prayer, at: 0)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func updatePrayer(_ prayer: PrayerModel) {
        isLoading = true
        errorMessage = nil
        
        prayerService.updatePrayer(prayer) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    if let index = self?.prayers.firstIndex(where: { $0.id == prayer.id }) {
                        self?.prayers[index] = prayer
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func deletePrayer(withId id: String) {
        isLoading = true
        errorMessage = nil
        
        if let index = self.prayers.firstIndex(where: { $0.id == id }) {
            let removedPrayer = self.prayers.remove(at: index)
            
            prayerService.deletePrayer(id: id) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success:
                        break
                    case .failure(let error):
                        self?.prayers.insert(removedPrayer, at: index)
                        self?.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
    
    
    func fetchAllNeededPrayers() {
        guard let userID = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not authenticated"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let now = Date()
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -6, to: now.startOfDay) ?? now
        let fifteenDaysFromNow = Calendar.current.date(byAdding: .day, value: 30, to: now.endOfDay) ?? now
        
        let range = DateInterval(start: sevenDaysAgo, end: fifteenDaysFromNow)
        
        prayerService.fetchPrayers(in: range, forUser: userID) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let fetchedPrayers):
                    self.prayers = fetchedPrayers
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func fetchPrayersForMonth(_ date: Date) {
        guard let userID = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not authenticated"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        prayerService.fetchAllPrayers(inMonth: date, forUser: userID) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let prayers):
                    self.allPrayers = prayers
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func fetchPrayers(for date: Date) {
        guard let userID = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not authenticated"
            return
        }

        isLoading = true
        errorMessage = nil

        prayerService.fetchPrayers(for: date, forUser: userID) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                switch result {
                case .success(let fetchedPrayers):
                    self.prayers = fetchedPrayers
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func secondaryText(for date: Date, prayers: [PrayerModel]) -> String {
        let calendar = Calendar.current
        let prayersForDay = prayers.filter { calendar.isDate($0.timeStamp, inSameDayAs: date) }
        let totalCount = prayersForDay.count
        let incompleteCount = prayersForDay.filter { !$0.completed }.count

        let today = calendar.isDateInToday(date)
        let future = date > Date()
        let past = date < calendar.startOfDay(for: Date())

        if totalCount == 0 {
            return ""
        } else if today {
            return incompleteCount == 0 ? "All Done!" : "\(incompleteCount) Prayer\(incompleteCount == 1 ? "" : "s") Left"
        } else if future {
            return "\(totalCount) Scheduled"
        } else if past {
            return incompleteCount == 0 ? "All Done!" : "\(incompleteCount) Past Due!"
        } else {
            return "\(totalCount) \(totalCount == 1 ? "Prayer" : "Prayers")"
        }
    }
    
    func getPrayersForDay(for selectedDate: Date) -> [PrayerModel] {
        return prayers.filter { Calendar.current.isDate($0.timeStamp, inSameDayAs: selectedDate) }
    }
}
