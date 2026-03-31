//
//  ForecastResponse.swift
//  WeatherAppUIKit
//
//  Created by Sergey Abadzhev on 31.03.26.
//

import Foundation

struct ForecastResponse: Codable, Sendable {
    let location: Location
    let current: CurrentWeather
    let forecast: Forecast
}
