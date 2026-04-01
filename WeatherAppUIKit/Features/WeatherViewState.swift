//
//  WeatherViewState.swift
//  WeatherAppUIKit
//
//  Created by Sergey Abadzhev on 01.04.26.
//

import Foundation

struct CurrentWeatherDisplay {
    let cityName: String
    let temperature: String
    let conditionText: String
    let hiLoText: String
    let feelsLike: String
    let humidity: String
    let wind: String
}

struct HourlyItemDisplay {
    let time: String
    let conditionCode: Int
    let temperature: String
}

struct DailyItemDisplay {
    let dayName: String
    let conditionCode: Int
    let low: Double
    let high: Double
    let lowText: String
    let highText: String
    let globalLow: Double
    let globalHigh: Double
}

enum WeatherViewState {
    case loading
    case loaded(
        current: CurrentWeatherDisplay,
        hourly: [HourlyItemDisplay],
        daily: [DailyItemDisplay]
    )
    case error(String)
}
