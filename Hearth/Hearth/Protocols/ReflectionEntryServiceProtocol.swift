//
//  ReflectionEntryServiceProtocol.swift
//  Hearth
//
//  Created by Aaron McKain on 5/9/25.
//

import Foundation

protocol ReflectionEntryServiceProtocol {
    func saveReflection(_ reflection: JournalReflectionModel, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteReflection(reflectionID: String, completion: @escaping (Result<Void, Error>) -> Void)
    func updateReflection(_ reflection: JournalReflectionModel, completion: @escaping (Result<Void, Error>) -> Void)
    func fetchReflection(reflectionID: String, completion: @escaping (Result<JournalReflectionModel, Error>) -> Void)
    func fetchTodayReflection(completion: @escaping (Result<JournalReflectionModel?, Error>) -> Void)
    func fetchReflections(for date: Date, completion: @escaping (Result<[JournalReflectionModel], Error>) -> Void)
}
