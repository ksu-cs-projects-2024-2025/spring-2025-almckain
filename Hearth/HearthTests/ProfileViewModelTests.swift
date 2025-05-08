
//
//  ProfileViewModelTests.swift
//  HearthTests
//
//  Created by OpenAI on 5/7/25.
//

import XCTest
@testable import Hearth

final class ProfileViewModelTests: XCTestCase {

    var viewModel: ProfileViewModel!
    var mockService: MockProfileService!
    var mockSession: MockUserSession!

    override func setUp() {
        super.setUp()
        mockService = MockProfileService()
        mockSession = MockUserSession(userID: "test-user-id")
        viewModel = ProfileViewModel(
            profileService: mockService,
            userSession: mockSession
        )
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        mockSession = nil
        super.tearDown()
    }

    func testFetchUserDataSuccess() {
        let expectation = XCTestExpectation(description: "User data should load")

        mockService.shouldFailGetUser = false
        viewModel.fetchUserData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertNotNil(self.viewModel.user)
            XCTAssertNil(self.viewModel.errorMessage)
            XCTAssertFalse(self.viewModel.isLoading)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchUserDataFailure() {
        let expectation = XCTestExpectation(description: "User data should fail to load")

        mockService.shouldFailGetUser = true
        viewModel.fetchUserData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertNil(self.viewModel.user)
            XCTAssertEqual(self.viewModel.errorMessage, "Failed to load user data")
            XCTAssertFalse(self.viewModel.isLoading)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchStats() {
        let expectation = XCTestExpectation(description: "Stats should load")

        viewModel.fetchProfileStats()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(self.viewModel.stats["prayerCount"], 3)
            XCTAssertEqual(self.viewModel.stats["journalEntryCount"], 5)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testLogout() {
        let expectation = XCTestExpectation(description: "Logout should succeed")

        viewModel.logout {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testDeleteAccountSuccess() {
        let expectation = XCTestExpectation(description: "Delete should succeed")

        mockService.shouldFailDelete = false
        viewModel.deleteAccount { result in
            switch result {
            case .success:
                XCTAssertNil(self.viewModel.user)
                XCTAssertEqual(self.viewModel.stats, [:])
                expectation.fulfill()
            case .failure:
                XCTFail("Delete should not fail")
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testDeleteAccountFailure() {
        let expectation = XCTestExpectation(description: "Delete should fail")

        mockService.shouldFailDelete = true
        viewModel.deleteAccount { result in
            switch result {
            case .success:
                XCTFail("Delete should fail")
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, "User is not logged in.")
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }
}
