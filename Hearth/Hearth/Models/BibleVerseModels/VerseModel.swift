//
//  VerseModel.swift
//  Hearth
//
//  Created by Aaron McKain on 2/13/25.
//

import Foundation
import FirebaseFirestore

struct VerseModel: Codable, Identifiable {
    var id: String { "\(book_id)_\(chapter)_\(verse)" }
    let book_id: String
    let book_name: String
    let chapter: Int
    let verse: Int
    let text: String
}
