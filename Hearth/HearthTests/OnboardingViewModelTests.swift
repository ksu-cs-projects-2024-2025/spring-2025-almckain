
//
//  OnboardingViewModelTests.swift
//  HearthTests
//
//  Created by OpenAI on 5/7/25.
//

import XCTest
@testable import Hearth

final class OnboardingViewModelTests: XCTestCase {

    class MockUserService: AuthenticationServiceProtocol {
        var shouldSucceed = true
        var shouldCompleteOnboarding = true
        var errorToReturn = NSError(domain: "Mock", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])

        func registerUser(firstName: String, lastName: String, email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
            shouldSucceed ? completion(.success(())) : completion(.failure(errorToReturn))
        }

        func loginUser(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
            shouldSucceed ? completion(.success(())) : completion(.failure(errorToReturn))
        }

        func completeUserOnboarding(completion: @escaping (Result<Void, Error>) -> Void) {
            shouldCompleteOnboarding ? completion(.success(())) : completion(.failure(errorToReturn))
        }
    }

    var viewModel: OnboardingViewModel!
    var mockService: MockUserService!

    override func setUp() {
        super.setUp()
        mockService = MockUserService()
        viewModel = OnboardingViewModel(userService: mockService)
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }

    func testRegisterUser_withMissingFields_showsError() {
        viewModel.firstName = ""
        viewModel.registerUser { success in
            XCTAssertFalse(success)
            XCTAssertEqual(self.viewModel.errorMessage, "Please fill in all fields")
        }
    }

    func testRegisterUser_withMismatchedPasswords_showsError() {
        viewModel.firstName = "John"
        viewModel.lastName = "Doe"
        viewModel.email = "test@example.com"
        viewModel.password = "1234"
        viewModel.confirmPassword = "5678"
        viewModel.hasAgreedToPrivacyPolicy = true

        viewModel.registerUser { success in
            XCTAssertFalse(success)
            XCTAssertEqual(self.viewModel.errorMessage, "Passwords do not match")
        }
    }

    func testRegisterUser_withPrivacyNotAgreed_showsError() {
        viewModel.firstName = "John"
        viewModel.lastName = "Doe"
        viewModel.email = "test@example.com"
        viewModel.password = "1234"
        viewModel.confirmPassword = "1234"
        viewModel.hasAgreedToPrivacyPolicy = false

        viewModel.registerUser { success in
            XCTAssertFalse(success)
            XCTAssertEqual(self.viewModel.errorMessage, "You must agree to the privacy policy")
        }
    }

    func testRegisterUser_successful() {
        viewModel.firstName = "John"
        viewModel.lastName = "Doe"
        viewModel.email = "test@example.com"
        viewModel.password = "1234"
        viewModel.confirmPassword = "1234"
        viewModel.hasAgreedToPrivacyPolicy = true

        let expectation = XCTestExpectation(description: "Register succeeds")

        viewModel.registerUser { success in
            XCTAssertTrue(success)
            XCTAssertNil(self.viewModel.errorMessage)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testRegisterUser_failure() {
        mockService.shouldSucceed = false

        viewModel.firstName = "John"
        viewModel.lastName = "Doe"
        viewModel.email = "test@example.com"
        viewModel.password = "1234"
        viewModel.confirmPassword = "1234"
        viewModel.hasAgreedToPrivacyPolicy = true

        let expectation = XCTestExpectation(description: "Register fails")

        viewModel.registerUser { success in
            XCTAssertFalse(success)
            XCTAssertEqual(self.viewModel.errorMessage, "Mock error")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testLoginUser_successful() {
        viewModel.email = "test@example.com"
        viewModel.password = "password"

        viewModel.loginUser()

        XCTAssertNil(viewModel.errorMessage)
    }

    func testLoginUser_failure() {
        mockService.shouldSucceed = false
        viewModel.email = "test@example.com"
        viewModel.password = "password"
        
        let expectation = XCTestExpectation(description: "Login failure handled")

        viewModel.loginUser()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.errorMessage, "Mock error")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testLoginUser_missingFields() {
        viewModel.email = ""
        viewModel.password = ""

        viewModel.loginUser()

        XCTAssertEqual(viewModel.errorMessage, "Please enter your email and password")
    }

    func testCompleteOnboarding_success() {
        let expectation = XCTestExpectation(description: "Onboarding completes")

        viewModel.completeOnboarding()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNil(self.viewModel.errorMessage)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testCompleteOnboarding_failure() {
        mockService.shouldCompleteOnboarding = false

        let expectation = XCTestExpectation(description: "Onboarding fails")

        viewModel.completeOnboarding()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.errorMessage, "Mock error")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
}
