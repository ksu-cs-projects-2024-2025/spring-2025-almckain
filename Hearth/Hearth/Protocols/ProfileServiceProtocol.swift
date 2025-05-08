//
//  ProfileServiceProtocol.swift
//  Hearth
//
//  Created by Aaron McKain on 5/7/25.
//

protocol ProfileServiceProtocol {
    func getUserData(completion: @escaping (Result<UserModel, Error>) -> Void)
    func fetchAllCounts(completion: @escaping ([String: Int]) -> Void)
    func logout(completion: @escaping (Bool) -> Void)
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void)

    func fetchPrayerCount(completion: @escaping (Int?) -> Void)
    func fetchJournalEntryCount(completion: @escaping (Int?) -> Void)
    func fetchReflectionCount(completion: @escaping (Int?) -> Void)
    func fetchEntryReflectionCount(completion: @escaping (Int?) -> Void)
    func fetchGratitudeCount(completion: @escaping (Int?) -> Void)
}

