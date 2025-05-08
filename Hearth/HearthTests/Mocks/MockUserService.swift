//
//  MockUserService.swift
//  Hearth
//
//  Created by Aaron McKain on 5/7/25.
//

import Foundation
@testable import Hearth

class MockUserSession: UserSessionProviding {
    var currentUserID: String?

    init(userID: String? = "test-user-id") {
        self.currentUserID = userID
    }
}
