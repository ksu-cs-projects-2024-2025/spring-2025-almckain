//
//  JournalReflectionModel.swift
//  Hearth
//
//  Created by Aaron McKain on 3/18/25.
//

import Foundation

struct JournalEntrySnapshot: Codable {
    let title: String
    let content: String
    let timestamp: Date
}

struct JournalReflectionModel: Codable, Identifiable {
    let id: String
    let userID: String
    let journalEntry: JournalEntrySnapshot  // Snapshot of the journal entry being reflected upon
    let reflectionContent: String
    let reflectionTimestamp: Date
    let spireScore: Double
}

