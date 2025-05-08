//
//  MockProfileService.swift
//  Hearth
//
//  Created by Aaron McKain on 5/7/25.
//

import Foundation
@testable import Hearth

class MockProfileService: ProfileServiceProtocol {
    var shouldFailGetUser = false
    var shouldFailDelete = false
    var dummyStats: [String: Int] = [
        "prayerCount": 3,
        "journalEntryCount": 5,
        "reflectionCount": 2,
        "entryReflectionCount": 1,
        "gratitudeCount": 4
    ]

    func getUserData(completion: @escaping (Result<UserModel, Error>) -> Void) {
        if shouldFailGetUser {
            completion(.failure(ProfileServiceError.userDataNotFound))
        } else {
            let dummyUser = UserModel(
                id: "mock-id",
                firstName: "Test",
                lastName: "User",
                email: "test@example.com",
                isOnboardingComplete: true,
                joinedAt: Date()
            )
            completion(.success(dummyUser))
        }
    }

    func fetchAllCounts(completion: @escaping ([String: Int]) -> Void) {
        completion(dummyStats)
    }

    func logout(completion: @escaping (Bool) -> Void) {
        completion(true)
    }

    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        if shouldFailDelete {
            completion(.failure(ProfileServiceError.userNotLoggedIn))
        } else {
            completion(.success(()))
        }
    }

    func fetchPrayerCount(completion: @escaping (Int?) -> Void) {
        completion(dummyStats["prayerCount"])
    }

    func fetchJournalEntryCount(completion: @escaping (Int?) -> Void) {
        completion(dummyStats["journalEntryCount"])
    }

    func fetchReflectionCount(completion: @escaping (Int?) -> Void) {
        completion(dummyStats["reflectionCount"])
    }

    func fetchEntryReflectionCount(completion: @escaping (Int?) -> Void) {
        completion(dummyStats["entryReflectionCount"])
    }

    func fetchGratitudeCount(completion: @escaping (Int?) -> Void) {
        completion(dummyStats["gratitudeCount"])
    }
}
