//
//  PrayerModel.swift
//  Hearth
//
//  Created by Aaron McKain on 4/1/25.
//

import Foundation
import FirebaseAuth

struct PrayerModel: Identifiable, Codable, Equatable, Hashable {
    var id: String
    var userID: String
    var content: String
    var timeStamp: Date
    var completed: Bool
    var entryType: EntryType = .prayerReminder
}

extension PrayerModel {
    static var empty: PrayerModel {
        PrayerModel(id: UUID().uuidString, userID: Auth.auth().currentUser?.uid ?? "", content: "", timeStamp: Date(), completed: false)
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(timeStamp)
    }
    
    var isFuture: Bool {
        timeStamp > Date()
    }
    
    var isPast: Bool {
        !isToday && timeStamp < Date()
    }
}
