//
//  URLSessionNetworkClientTests.swift
//  WeatherAppUIKitTests
//
//  Created by Sergey Abadzhev on 01.04.26.
//

import Testing
import Foundation
@testable import WeatherAppUIKit

@Suite("URLSessionNetworkClient")
struct URLSessionNetworkClientTests {

    // MARK: - Success

    @Test("Successful 200 response decodes the model correctly")
    func successfulDecode() async throws {
        let session = MockURLSession(data: MockData.currentResponseJSON,
                                     response: httpResponse(status: 200))
        let client = URLSessionNetworkClient(session: session)

        let result: CurrentResponse = try await client.request(.currentWeather(lat: 55.75, lon: 37.61))
        #expect(result.location.name == "Moscow")
        #expect(result.current.tempC == 20.5)
        #expect(result.current.humidity == 60)
    }

    @Test("Any HTTP 2xx response does not throw")
    func http2xxRangeDoesNotThrow() async throws {
        for status in [200, 201, 204, 299] {
            let session = MockURLSession(data: MockData.currentResponseJSON,
                                         response: httpResponse(status: status))
            let client = URLSessionNetworkClient(session: session)
            let _: CurrentResponse = try await client.request(.currentWeather(lat: 0, lon: 0))
        }
    }

    // MARK: - HTTP Errors

    @Test("HTTP 404 throws serverError(404)")
    func http404ThrowsServerError() async {
        let session = MockURLSession(data: Data(), response: httpResponse(status: 404))
        let client = URLSessionNetworkClient(session: session)

        await #expect(throws: NetworkError.serverError(statusCode: 404)) {
            let _: CurrentResponse = try await client.request(.currentWeather(lat: 0, lon: 0))
        }
    }

    @Test("HTTP 500 throws serverError(500)")
    func http500ThrowsServerError() async {
        let session = MockURLSession(data: Data(), response: httpResponse(status: 500))
        let client = URLSessionNetworkClient(session: session)

        await #expect(throws: NetworkError.serverError(statusCode: 500)) {
            let _: CurrentResponse = try await client.request(.currentWeather(lat: 0, lon: 0))
        }
    }

    // MARK: - URLError Mapping

    @Test("URLError.notConnectedToInternet maps to noInternetConnection")
    func notConnectedMapsToNoInternet() async {
        let session = MockURLSession(error: URLError(.notConnectedToInternet))
        let client = URLSessionNetworkClient(session: session)

        await #expect(throws: NetworkError.noInternetConnection) {
            let _: CurrentResponse = try await client.request(.currentWeather(lat: 0, lon: 0))
        }
    }

    @Test("URLError.networkConnectionLost maps to noInternetConnection")
    func connectionLostMapsToNoInternet() async {
        let session = MockURLSession(error: URLError(.networkConnectionLost))
        let client = URLSessionNetworkClient(session: session)

        await #expect(throws: NetworkError.noInternetConnection) {
            let _: CurrentResponse = try await client.request(.currentWeather(lat: 0, lon: 0))
        }
    }

    @Test("URLError.timedOut maps to NetworkError.timeout")
    func timedOutMapsToTimeout() async {
        let session = MockURLSession(error: URLError(.timedOut))
        let client = URLSessionNetworkClient(session: session)

        await #expect(throws: NetworkError.timeout) {
            let _: CurrentResponse = try await client.request(.currentWeather(lat: 0, lon: 0))
        }
    }

    // MARK: - Decoding Errors

    @Test("Malformed JSON throws decodingError")
    func malformedJSONThrowsDecodingError() async {
        let session = MockURLSession(data: "not json".data(using: .utf8)!,
                                     response: httpResponse(status: 200))
        let client = URLSessionNetworkClient(session: session)

        do {
            let _: CurrentResponse = try await client.request(.currentWeather(lat: 0, lon: 0))
            Issue.record("Expected decodingError to be thrown")
        } catch let error as NetworkError {
            guard case .decodingError = error else {
                Issue.record("Expected .decodingError, got \(error)"); return
            }
        } catch {
            Issue.record("Expected NetworkError, got \(error)")
        }
    }
}
