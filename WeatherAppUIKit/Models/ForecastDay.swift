//
//  ForecastDay.swift
//  WeatherAppUIKit
//
//  Created by Sergey Abadzhev on 31.03.26.
//

import Foundation

struct ForecastDay: Codable, Sendable {
    let date: String
    let day: Day
    let hour: [HourWeather]
}
