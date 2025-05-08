//
//  AuthenticationServiceProtocol.swift
//  Hearth
//
//  Created by Aaron McKain on 5/7/25.
//

import Foundation

protocol AuthenticationServiceProtocol {
    func registerUser(firstName: String, lastName: String, email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
    func loginUser(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
    func completeUserOnboarding(completion: @escaping (Result<Void, Error>) -> Void)
}

