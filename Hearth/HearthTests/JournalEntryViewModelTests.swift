//
//  JournalEntryViewModelTests.swift
//  Hearth
//
//  Created by Aaron McKain on 5/7/25.
//

import XCTest
@testable import Hearth

final class JournalEntryViewModelTests: XCTestCase {
    func testAddJournalEntry_succeedsWithValidInput() {
        let mockService = MockEntryService()
        let viewModel = JournalEntryViewModel(entryService: mockService)
        
        let expectation = XCTestExpectation(description: "Entry saved")
        
        viewModel.addJournalEntry(title: "Test", content: "Test content") { result in
            switch result {
            case .success:
                XCTAssertEqual(viewModel.journalEntries.count, 1)
                XCTAssertEqual(mockService.savedEntries.count, 1)
                XCTAssertNil(viewModel.errorMessage)
            case .failure:
                XCTFail("Expected success, got failure")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testAddJournalEntry_failsWithEmptyInput() {
        let mockService = MockEntryService()
        let viewModel = JournalEntryViewModel(entryService: mockService)
        
        let expectation = XCTestExpectation(description: "Entry not saved")
        
        viewModel.addJournalEntry(title: " ", content: " ") { result in
            switch result {
            case .success:
                XCTFail("Expected failure, got success")
            case .failure(let error):
                XCTAssertEqual(viewModel.journalEntries.count, 0)
                XCTAssertEqual(viewModel.errorMessage, "Cannot save an empty entry.")
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testDeleteEntry_succeedsWithValidID() {
        let mockService = MockEntryService()
        let entry = JournalEntryModel(id: "123", userID: "test", title: "Title", content: "Content", timeStamp: Date())
        mockService.savedEntries = [entry]
        
        let viewModel = JournalEntryViewModel(entryService: mockService)
        viewModel.journalEntries = [entry]
        
        let expectation = XCTestExpectation(description: "Entry deleted")
        
        viewModel.deleteEntry(withId: "123") { result in
            switch result {
            case .success:
                XCTAssertTrue(viewModel.journalEntries.isEmpty)
                XCTAssertNil(viewModel.errorMessage)
            case .failure:
                XCTFail("Expected success")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testDeleteEntry_failsWithInvalidID() {
        let mockService = MockEntryService()
        let viewModel = JournalEntryViewModel(entryService: mockService)
        
        let expectation = XCTestExpectation(description: "Entry delete failed")
        
        viewModel.deleteEntry(withId: "") { result in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure(let error):
                XCTAssertEqual(viewModel.errorMessage, "Invalid entry ID.")
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testDeleteEntry_failsFromServiceError() {
        let mockService = MockEntryService()
        mockService.shouldFail = true
        
        let entry = JournalEntryModel(id: "456", userID: "test", title: "Title", content: "Content", timeStamp: Date())
        let viewModel = JournalEntryViewModel(entryService: mockService)
        viewModel.journalEntries = [entry]
        
        let expectation = XCTestExpectation(description: "Delete fails from service")
        
        viewModel.deleteEntry(withId: "456") { result in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure(let error):
                XCTAssertEqual(viewModel.errorMessage, "Failed to delete entry")
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testUpdateJournalEntry_succeeds() {
        let mockService = MockEntryService()
        let original = JournalEntryModel(id: "123", userID: "test", title: "Old Title", content: "Old Content", timeStamp: Date())
        mockService.savedEntries = [original]
        
        let viewModel = JournalEntryViewModel(entryService: mockService)
        viewModel.journalEntries = [original]
        
        let expectation = XCTestExpectation(description: "Entry updated")
        var callbackCalled = false
        viewModel.onEntryUpdate = { callbackCalled = true }
        
        viewModel.updateJournalEntry(entry: original, newTitle: "New Title", newContent: "New Content") { result in
            switch result {
            case .success:
                let updated = viewModel.journalEntries.first!
                XCTAssertEqual(updated.title, "New Title")
                XCTAssertEqual(updated.content, "New Content")
                XCTAssertNil(viewModel.errorMessage)
                XCTAssertTrue(callbackCalled)
            case .failure:
                XCTFail("Expected success")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testUpdateJournalEntry_failsWithEmptyInput() {
        let mockService = MockEntryService()
        let entry = JournalEntryModel(id: "123", userID: "test", title: "Title", content: "Content", timeStamp: Date())
        
        let viewModel = JournalEntryViewModel(entryService: mockService)
        viewModel.journalEntries = [entry]
        
        let expectation = XCTestExpectation(description: "Update fails for empty input")
        
        viewModel.updateJournalEntry(entry: entry, newTitle: " ", newContent: " ") { result in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure(let error):
                XCTAssertEqual(viewModel.errorMessage, "Cannot save an empty entry.")
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testUpdateJournalEntry_failsFromServiceError() {
        let mockService = MockEntryService()
        mockService.shouldFail = true
        let entry = JournalEntryModel(id: "123", userID: "test", title: "Title", content: "Content", timeStamp: Date())
        
        let viewModel = JournalEntryViewModel(entryService: mockService)
        viewModel.journalEntries = [entry]
        
        let expectation = XCTestExpectation(description: "Update fails from service")
        
        viewModel.updateJournalEntry(entry: entry, newTitle: "New", newContent: "Content") { result in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure(let error):
                XCTAssertEqual(viewModel.errorMessage, "Failed to update entry. Please try again later.")
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
}
