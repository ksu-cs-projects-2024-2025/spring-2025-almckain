//
//  UserSessionProviding.swift
//  Hearth
//
//  Created by Aaron McKain on 5/7/25.
//

import Foundation
import FirebaseAuth

protocol UserSessionProviding {
    var currentUserID: String? { get }
    var currentUser: User? { get }
}
