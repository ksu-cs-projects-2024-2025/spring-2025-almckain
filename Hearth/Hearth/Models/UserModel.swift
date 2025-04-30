//
//  UserModel.swift
//  Hearth
//
//  Created by Aaron McKain on 2/13/25.
//

import Foundation
import FirebaseFirestore

struct UserModel: Codable {
    @DocumentID var id: String?
    let firstName: String
    let lastName: String
    let email: String
    var isOnboardingComplete: Bool = false
    let joinedAt: Date
}
