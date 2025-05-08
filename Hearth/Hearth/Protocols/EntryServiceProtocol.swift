//
//  EntryServiceProtocol.swift
//  Hearth
//
//  Created by Aaron McKain on 5/7/25.
//
import Foundation

protocol EntryServiceProtocol {
    func fetchEntries<T: EntryProtocol>(entryType: EntryType, completion: @escaping (Result<[T], Error>) -> Void)
    func saveEntry<T: EntryProtocol>(_ entry: T, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteEntry(entryId: String, completion: @escaping (Result<Void, Error>) -> Void)
    func updateEntry(_ entry: JournalEntryModel, completion: @escaping (Result<Void, Error>) -> Void)
    func fetchEntriesInRange(start: Date, end: Date, completion: @escaping (Result<[JournalEntryModel], Error>) -> Void)
    func fetchEntriesForDay(date: Date, completion: @escaping (Result<[JournalEntryModel], Error>) -> Void)
    func fetchEntriesForLastWeek(completion: @escaping (Result<[JournalEntryModel], Error>) -> Void)
}
