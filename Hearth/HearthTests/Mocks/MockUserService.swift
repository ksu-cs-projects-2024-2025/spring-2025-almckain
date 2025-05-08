//
//  MockUserService.swift
//  Hearth
//
//  Created by Aaron McKain on 5/7/25.
//

import Foundation
import FirebaseAuth
@testable import Hearth

class MockUserSession: UserSessionProviding {
    var currentUserID: String?
    var currentUser: User?

    init(userID: String? = "test-user-id", user: User? = nil) {
        self.currentUserID = userID
        self.currentUser = user
    }
}
