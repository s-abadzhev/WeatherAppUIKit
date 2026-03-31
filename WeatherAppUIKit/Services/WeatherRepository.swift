//
//  WeatherRepository.swift
//  WeatherAppUIKit
//
//  Created by Sergey Abadzhev on 31.03.26.
//

import Foundation

final class WeatherRepository: WeatherRepositoryProtocol {

    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func fetchCurrent(lat: Double, lon: Double) async throws -> CurrentResponse {
        try await networkClient.request(.currentWeather(lat: lat, lon: lon))
    }

    func fetchForecast(lat: Double, lon: Double) async throws -> ForecastResponse {
        try await networkClient.request(.forecast(lat: lat, lon: lon))
    }
}

enum WeatherError: LocalizedError {
    case timeout

    var errorDescription: String? { L10n.Error.timeout }
}
