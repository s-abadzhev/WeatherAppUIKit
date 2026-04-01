//
//  NetworkErrorTests.swift
//  WeatherAppUIKitTests
//
//  Created by Sergey Abadzhev on 01.04.26.
//

import Testing
import Foundation
@testable import WeatherAppUIKit

@Suite("NetworkError")
struct NetworkErrorTests {

    // MARK: - Error Descriptions

    @Test("invalidURL has a non-empty description")
    func invalidURLDescription() {
        #expect(!(NetworkError.invalidURL.errorDescription ?? "").isEmpty)
    }

    @Test("noInternetConnection has a non-empty description")
    func noInternetDescription() {
        #expect(!(NetworkError.noInternetConnection.errorDescription ?? "").isEmpty)
    }

    @Test("timeout has a non-empty description")
    func timeoutDescription() {
        #expect(!(NetworkError.timeout.errorDescription ?? "").isEmpty)
    }

    @Test("serverError description contains the status code")
    func serverErrorContainsCode() {
        let desc = NetworkError.serverError(statusCode: 503).errorDescription ?? ""
        #expect(desc.contains("503"))
    }

    @Test("decodingError has a non-empty description")
    func decodingErrorDescription() {
        #expect(!(NetworkError.decodingError(URLError(.unknown)).errorDescription ?? "").isEmpty)
    }

    // MARK: - Equatable

    @Test("Identical cases are equal")
    func equalitySameCases() {
        #expect(NetworkError.invalidURL == .invalidURL)
        #expect(NetworkError.noInternetConnection == .noInternetConnection)
        #expect(NetworkError.timeout == .timeout)
        #expect(NetworkError.serverError(statusCode: 404) == .serverError(statusCode: 404))
    }

    @Test("serverError with different status codes are not equal")
    func serverErrorDifferentCodes() {
        #expect(NetworkError.serverError(statusCode: 404) != .serverError(statusCode: 500))
    }

    @Test("Different cases are not equal")
    func differentCasesNotEqual() {
        #expect(NetworkError.invalidURL != .noInternetConnection)
        #expect(NetworkError.timeout != .invalidURL)
        #expect(NetworkError.noInternetConnection != .timeout)
    }
}
