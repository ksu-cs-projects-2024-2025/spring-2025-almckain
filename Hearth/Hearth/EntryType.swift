//
//  EntryType.swift
//  Hearth
//
//  Created by Aaron McKain on 2/13/25.
//

import Foundation

enum EntryType: String, Codable, CaseIterable {
    case journal
    case bibleVerseReflection
    case gratitude
    case prayerReminder
}
