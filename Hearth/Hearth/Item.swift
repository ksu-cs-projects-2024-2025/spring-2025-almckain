//
//  Item.swift
//  Hearth
//
//  Created by Aaron McKain on 2/6/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
