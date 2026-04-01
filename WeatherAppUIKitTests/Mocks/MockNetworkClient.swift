//
//  MockNetworkClient.swift
//  WeatherAppUIKitTests
//
//  Created by Sergey Abadzhev on 01.04.26.
//

import Foundation
@testable import WeatherAppUIKit

final class MockNetworkClient: NetworkClient, @unchecked Sendable {
    var currentResult:  Result<CurrentResponse,  Error> = .success(MockData.currentResponse)
    var forecastResult: Result<ForecastResponse, Error> = .success(MockData.forecastResponse)

    private(set) var requestCount = 0
    private(set) var lastEndpoint: APIEndpoint?

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        requestCount += 1
        lastEndpoint = endpoint
        switch endpoint {
        case .currentWeather:
            let value = try currentResult.get()
            guard let typed = value as? T else { throw NetworkError.decodingError(URLError(.unknown)) }
            return typed
        case .forecast:
            let value = try forecastResult.get()
            guard let typed = value as? T else { throw NetworkError.decodingError(URLError(.unknown)) }
            return typed
        }
    }
}
