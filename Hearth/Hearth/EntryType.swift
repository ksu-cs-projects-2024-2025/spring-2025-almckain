//
//  EntryType.swift
//  Hearth
//
//  Created by Aaron McKain on 2/13/25.
//

import Foundation

enum EntryType: String, Codable, CaseIterable, Identifiable {
    case journal
    case bibleVerseReflection
    case gratitude
    case prayerReminder
    case selfReflection
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .journal: return "Journal"
        case .bibleVerseReflection: return "Verse Reflection"
        case .gratitude: return "Gratitude Prompt"
        case .prayerReminder: return "Prayers"
        case .selfReflection: return "Reflection"
        }
    }
}
