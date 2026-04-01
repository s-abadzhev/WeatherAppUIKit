//
//  MockWeatherRepository.swift
//  WeatherAppUIKitTests
//
//  Created by Sergey Abadzhev on 01.04.26.
//

import Foundation
@testable import WeatherAppUIKit

final class MockWeatherRepository: WeatherRepositoryProtocol, @unchecked Sendable {
    var currentResult:  Result<CurrentResponse,  Error> = .success(MockData.currentResponse)
    var forecastResult: Result<ForecastResponse, Error> = .success(MockData.forecastResponse)

    private(set) var fetchCurrentCallCount  = 0
    private(set) var fetchForecastCallCount = 0
    private(set) var lastLat: Double?
    private(set) var lastLon: Double?

    func fetchCurrent(lat: Double, lon: Double) async throws -> CurrentResponse {
        fetchCurrentCallCount += 1
        lastLat = lat
        lastLon = lon
        return try currentResult.get()
    }

    func fetchForecast(lat: Double, lon: Double) async throws -> ForecastResponse {
        fetchForecastCallCount += 1
        return try forecastResult.get()
    }
}
