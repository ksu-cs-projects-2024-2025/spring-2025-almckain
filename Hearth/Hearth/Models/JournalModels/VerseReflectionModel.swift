//
//  VerseReflection.swift
//  Hearth
//
//  Created by Aaron McKain on 2/13/25.
//

import Foundation
import FirebaseFirestore

struct VerseReflectionModel: EntryProtocol {
    var id: String?
    var userID: String
    var title: String
    var bibleVerseText: String
    var reflection: String
    var timeStamp: Date
    var entryType: EntryType = .bibleVerseReflection
}

