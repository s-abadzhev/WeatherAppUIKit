//
//  WeatherRepositoryProtocol.swift
//  WeatherAppUIKit
//
//  Created by Sergey Abadzhev on 31.03.26.
//

import Foundation

protocol WeatherRepositoryProtocol: Sendable {
    func fetchCurrent(lat: Double, lon: Double) async throws -> CurrentResponse
    func fetchForecast(lat: Double, lon: Double) async throws -> ForecastResponse
}
