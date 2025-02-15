//
//  VerseReflection.swift
//  Hearth
//
//  Created by Aaron McKain on 2/13/25.
//

import Foundation
import FirebaseFirestore

struct VerseReflection: Codable, Identifiable {
    @DocumentID var id: String?
    var userID: String
    var bibleVerseID: String
    var bibleVerseReference: String
    var reflection: String
    var timestamp: Date
}
