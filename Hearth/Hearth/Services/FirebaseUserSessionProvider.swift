//
//  FirebaseUserSessionProvider.swift
//  Hearth
//
//  Created by Aaron McKain on 5/7/25.
//

import Foundation
import FirebaseAuth

class FirebaseUserSessionProvider: UserSessionProviding {
    var currentUserID: String? {
        Auth.auth().currentUser?.uid
    }
    
    var currentUser: User? {
        Auth.auth().currentUser
    }
}
