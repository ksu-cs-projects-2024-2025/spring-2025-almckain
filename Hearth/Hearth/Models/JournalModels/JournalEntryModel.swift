//
//  JournalEntryModel.swift
//  Hearth
//
//  Created by Aaron McKain on 2/13/25.
//

import FirebaseFirestore
import Foundation

struct JournalEntryModel: EntryProtocol {
    var id: String
    var userID: String
    var title: String
    var content: String
    var timeStamp: Date
    var entryType: EntryType = .journal
}
