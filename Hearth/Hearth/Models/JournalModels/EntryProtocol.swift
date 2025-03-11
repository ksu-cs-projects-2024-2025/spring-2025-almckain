//
//  EntryProtocol.swift
//  Hearth
//
//  Created by Aaron McKain on 2/13/25.
//

import FirebaseFirestore
import Foundation

protocol EntryProtocol: Identifiable, Codable {
    var id: String { get set }
    var userID: String { get set }
    var title: String { get set }
    var timeStamp: Date { get set }
    var entryType: EntryType { get set }
}
