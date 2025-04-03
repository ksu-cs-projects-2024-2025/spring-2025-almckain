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
        
        prayerService.deletePrayer(id: id) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    self?.prayers.removeAll { $0.id == id }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    /*
    func fetchPrayers(in range: DateInterval, completion: (() -> Void)? = nil) {
        guard let userID = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not authenticated"
            completion?()
            return
        }

        isLoading = true
        errorMessage = nil
        
        prayerService.fetchPrayers(in: range, forUser: userID) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let prayers):
                    self?.prayers = prayers
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
                completion?()
            }
        }
    }
     */
    
    /*
    func fetchFuturePrayers(limit: Int, completion: (() -> Void)? = nil) {
            guard let userID = Auth.auth().currentUser?.uid else {
                self.errorMessage = "User not authenticated"
                completion?()
                return
            }
            
            isLoading = true
            errorMessage = nil
            
            prayerService.fetchFuturePrayers(limit: limit, forUser: userID) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success(let prayers):
                        self?.prayers = prayers
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                    }
                    completion?()
                }
            }
        }
    */
    
    func fetchAllNeededPrayers() {
            guard let userID = Auth.auth().currentUser?.uid else {
                self.errorMessage = "User not authenticated"
                return
            }

            isLoading = true
            errorMessage = nil
            
            // 7 days ago to 15 days in the future. Adjust as you see fit.
            let now = Date()
            let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -6, to: now.startOfDay) ?? now
            let fifteenDaysFromNow = Calendar.current.date(byAdding: .day, value: 15, to: now.endOfDay) ?? now
            
            let range = DateInterval(start: sevenDaysAgo, end: fifteenDaysFromNow)
            
            prayerService.fetchPrayers(in: range, forUser: userID) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.isLoading = false
                    
                    switch result {
                    case .success(let fetchedPrayers):
                        // Overwrite the entire local array with all needed prayers
                        self.prayers = fetchedPrayers
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
}
