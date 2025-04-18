//
//  GratitudeModel.swift
//  Hearth
//
//  Created by Aaron McKain on 4/17/25.
//

import Foundation
import FirebaseFirestore

struct GratitudeModel: EntryProtocol {
    var id: String
    var userID: String
    var title: String = "Gratitude"
    var timeStamp: Date
    var entryType: EntryType = .gratitude
    var prompt: String
    var content: String
}
