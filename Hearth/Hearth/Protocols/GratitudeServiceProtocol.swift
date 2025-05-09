//
//  GratitudeServiceProtocol.swift
//  Hearth
//
//  Created by Aaron McKain on 5/8/25.
//

import Foundation

protocol GratitudeServiceProtocol {
    func fetchGratitudeEntries(forMonth date: Date, completion: @escaping (Result<[GratitudeModel], Error>) -> Void)
    func saveGratitudeEntry(_ entry: GratitudeModel, completion: @escaping (Result<Void, Error>) -> Void)
    func updateGratitude(_ entry: GratitudeModel, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteGratitude(entryID: String, completion: @escaping (Result<Void, Error>) -> Void)
}
