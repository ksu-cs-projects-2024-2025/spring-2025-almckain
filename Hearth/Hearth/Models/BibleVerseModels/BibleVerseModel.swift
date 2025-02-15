//
//  BibleVerseModel.swift
//  Hearth
//
//  Created by Aaron McKain on 2/13/25.
//
import Foundation
import FirebaseFirestore

struct BibleVerseModel: Codable, Identifiable {
    @DocumentID var id: String?
    let reference: String
    let verses: [VerseModel]
    let text: String
    let translationID: String
    let translationName: String
    let translationNote: String?
    
    enum CodingKeys: String, CodingKey {
        case reference, verses, text
        case translationID = "translation_id"
        case translationName = "translation_name"
        case translationNote = "translation_note"
    }
}
