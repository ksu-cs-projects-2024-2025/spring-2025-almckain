//
//  PrayerViewModel.swift
//  Hearth
//
//  Created by Aaron McKain on 4/1/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine


@MainActor
class PrayerViewModel: ObservableObject {
    @Published var prayers: [PrayerModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var lastUpdated = Date()
    
    var onPrayerUpdate: (() -> Void)?
    
    private let prayerService = PrayerService()
    private var listener: ListenerRegistration?
    
    func addPrayer(_ prayer: PrayerModel) {
        isLoading = true
        errorMessage = nil
        
        prayerService.addPrayer(prayer) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    self?.prayers.append(prayer)
                    self?.lastUpdated = Date()
                    self?.onPrayerUpdate?()
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
                    guard let index = self?.prayers.firstIndex(where: { $0.id == prayer.id }) else { return }
                    self?.prayers[index] = prayer
                    self?.lastUpdated = Date()
                    self?.onPrayerUpdate?()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func deletePrayer(withId id: String) {
        isLoading = true
        errorMessage = nil

        guard let index = prayers.firstIndex(where: { $0.id == id }) else { return }
        let removedPrayer = prayers.remove(at: index)

        prayerService.deletePrayer(id: id) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    self?.refresh()
                    self?.lastUpdated = Date()
                    self?.onPrayerUpdate?()
                case .failure(let error):
                    self?.prayers.insert(removedPrayer, at: index)
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func fetchPrayers(forMonth date: Date, append: Bool = true) {
        guard let userID = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not authenticated"
            return
        }

        isLoading = true
        errorMessage = nil

        prayerService.fetchAllPrayers(inMonth: date, forUser: userID) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let prayersForMonth):
                    print("WE FETCHED THE PRAYERS")
                    prayersForMonth.forEach { print($0) }
                    if append {
                        let newSet = Set(prayersForMonth)
                        let combined = Array(Set(self?.prayers ?? []).union(newSet))
                        self?.prayers = combined.sorted { $0.timeStamp < $1.timeStamp }
                    } else {
                        self?.prayers = prayersForMonth
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func startListening(forUser userID: String) {
        listener = prayerService.listenForPrayers(forUser: userID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let prayers):
                    print("got one")
                    self?.prayers = prayers
                case .failure(let error):
                    // Handle error as needed. Possibly update self.errorMessage, etc.
                    print("Error listening for prayers: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    deinit {
        Task { @MainActor [weak self] in
            self?.stopListening()
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
    
    // MARK: - Helpers
    
    var todayPrayers: [PrayerModel] {
        prayers.filter { Calendar.current.isDateInToday($0.timeStamp) }
    }
    
    var futurePrayers: [PrayerModel] {
        prayers.filter { $0.timeStamp > Date() && !$0.completed }.sorted { $0.timeStamp < $1.timeStamp }
    }
    
    var groupedPrayersByDate: [Date: [PrayerModel]] {
        Dictionary(grouping: prayers) { $0.timeStamp.startOfDay }
    }
    
    var groupedFuturePrayers: [Date: [PrayerModel]] {
        Dictionary(grouping: futurePrayers) { $0.timeStamp.startOfDay }
    }
    
    func prayers(for date: Date) -> [PrayerModel] {
        prayers.filter { Calendar.current.isDate($0.timeStamp, inSameDayAs: date) }
    }
    
    func incompletePrayers(for date: Date) -> [PrayerModel] {
        prayers(for: date).filter { !$0.completed }
    }
    
    var groupedIncompleteByDay: [Date: [PrayerModel]] {
        let filtered = prayers.filter { !$0.completed }
        return Dictionary(grouping: filtered) { $0.timeStamp.startOfDay }
    }
    
    var filteredHomePrayers: [PrayerModel] {
        let maxVisible = 5
        let today = todayPrayers
        let future = futurePrayers.prefix(max(0, maxVisible - today.count))
        return today + future
    }
    
    func refresh() {
        print("REFRESHED! ITS REFRESHED!!!")
        fetchPrayers(forMonth: Date(), append: false)
    }


}
