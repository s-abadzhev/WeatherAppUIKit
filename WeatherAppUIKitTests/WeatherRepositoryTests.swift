//
//  WeatherRepositoryTests.swift
//  WeatherAppUIKitTests
//
//  Created by Sergey Abadzhev on 01.04.26.
//

import Testing
@testable import WeatherAppUIKit

@Suite("WeatherRepository")
struct WeatherRepositoryTests {

    @Test("fetchCurrent calls networkClient with .currentWeather endpoint")
    func fetchCurrentCallsCorrectEndpoint() async throws {
        let client = MockNetworkClient()
        let repo = WeatherRepository(networkClient: client)

        _ = try await repo.fetchCurrent(lat: 55.75, lon: 37.61)

        #expect(client.requestCount == 1)
        if let endpoint = client.lastEndpoint, case .currentWeather(let lat, let lon) = endpoint {
            #expect(lat == 55.75)
            #expect(lon == 37.61)
        } else {
            Issue.record("Expected .currentWeather endpoint")
        }
    }

    @Test("fetchForecast calls networkClient with .forecast endpoint")
    func fetchForecastCallsCorrectEndpoint() async throws {
        let client = MockNetworkClient()
        let repo = WeatherRepository(networkClient: client)

        _ = try await repo.fetchForecast(lat: 55.75, lon: 37.61)

        #expect(client.requestCount == 1)
        if let endpoint = client.lastEndpoint, case .forecast(let lat, let lon) = endpoint {
            #expect(lat == 55.75)
            #expect(lon == 37.61)
        } else {
            Issue.record("Expected .forecast endpoint")
        }
    }

    @Test("fetchCurrent propagates NetworkError from the client")
    func fetchCurrentPropagatesError() async {
        let client = MockNetworkClient()
        client.currentResult = .failure(NetworkError.noInternetConnection)
        let repo = WeatherRepository(networkClient: client)

        await #expect(throws: NetworkError.noInternetConnection) {
            _ = try await repo.fetchCurrent(lat: 0, lon: 0)
        }
    }

    @Test("fetchForecast propagates NetworkError from the client")
    func fetchForecastPropagatesError() async {
        let client = MockNetworkClient()
        client.forecastResult = .failure(NetworkError.timeout)
        let repo = WeatherRepository(networkClient: client)

        await #expect(throws: NetworkError.timeout) {
            _ = try await repo.fetchForecast(lat: 0, lon: 0)
        }
    }

    @Test("fetchCurrent returns the decoded response on success")
    func fetchCurrentReturnsResponse() async throws {
        let repo = WeatherRepository(networkClient: MockNetworkClient())
        let response = try await repo.fetchCurrent(lat: 0, lon: 0)
        #expect(response.location.name == "Moscow")
    }

    @Test("fetchForecast returns all 3 forecast days on success")
    func fetchForecastReturnsDays() async throws {
        let repo = WeatherRepository(networkClient: MockNetworkClient())
        let response = try await repo.fetchForecast(lat: 0, lon: 0)
        #expect(response.forecast.forecastday.count == 3)
    }
}
