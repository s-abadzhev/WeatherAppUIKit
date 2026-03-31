//
//  Forecast.swift
//  WeatherAppUIKit
//
//  Created by Sergey Abadzhev on 31.03.26.
//

import Foundation

struct Forecast: Codable, Sendable {
    let forecastday: [ForecastDay]
}
